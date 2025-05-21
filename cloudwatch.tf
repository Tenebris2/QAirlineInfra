resource "aws_s3_bucket" "alb_logs" {
  bucket        = "qairline-alb-logs-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AWSLogDeliveryWrite",
        Effect    = "Allow",
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        },
        Action    = [
          "s3:PutObject"
        ],
        Resource  = "${aws_s3_bucket.alb_logs.arn}/*"
      },
      {
        Sid       = "AWSLogDeliveryAclCheck",
        Effect    = "Allow",
        Principal = {
          Service = "logdelivery.elasticloadbalancing.amazonaws.com"
        },
        Action    = [
          "s3:GetBucketAcl"
        ],
        Resource  = aws_s3_bucket.alb_logs.arn
      }
    ]
  })
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "cloudfront_logs" {
  bucket        = "qairline-cloudfront-logs-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "cloudfront_logs" {
  depends_on = [aws_s3_bucket_ownership_controls.cloudfront_logs]
  bucket     = aws_s3_bucket.cloudfront_logs.id
  acl        = "log-delivery-write"
}



resource "aws_cloudwatch_log_group" "apigw_log_group" {
  name              = "/qairline/apigateway"
  retention_in_days = 14
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_alarm" {
  alarm_name          = "ALB-5XX-Error-Alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "ALB 5XX errors > 1"
  dimensions = {
    LoadBalancer = aws_lb.k8s_alb.arn_suffix
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_alarm" {
  alarm_name          = "RDS-CPU-Utilization-Alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS CPU > 80%"
  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres_db.id
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu_alarm" {
  count               = local.worker_nodes_count
  alarm_name          = "EC2-CPU-Utilization-Alarm-${count.index}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EC2 CPU > 80%"
  dimensions = {
    InstanceId = aws_instance.worker_nodes[count.index].id
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_sns_topic" "alerts" {
  name = "cloudwatch-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}