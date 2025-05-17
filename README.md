
# QAirline Cloud Infrastructure

## Infrastructure Overview

End users initiate requests through **Amazon CloudFront**, a global content delivery network (CDN) that ensures low-latency access, HTTPS encryption, and support for custom domains.

Static assets for the **ReactJS frontend** are stored in an **Amazon S3** bucket, with CloudFront efficiently caching and delivering these assets to users worldwide.

Once the frontend is loaded, client-side API calls are routed through **CloudFront** using the `/api/*` path prefix. These requests are forwarded to an **Application Load Balancer (ALB)**, which serves as the entry point for backend traffic.

The ALB is integrated with a self managed **Kubernetes cluster **via a target group. Inside the cluster, backend services are deployed as scalable Pods that handle application logic and respond to API requests.

These services interact with a **relational database** hosted on **Amazon RDS**, ensuring reliable and persistent data storage.

This architecture provides a secure, scalable, and high-performance environment for delivering modern web applications.

# How to run


## Infrastructure Provisioning
To provision the cloud infrastructure, first create a profile named devops-user, with enough permissions to create S3 buckets, EC2 instances, RDS, VPCs, CDNs.

Then run 

```  bash
terraform init
terraform plan 
terraform apply
```

## Creating The K8s Cluster


To populate hosts.ini with updated ip address, run the **generate_inventory** python file in **scripts** directory
Note you will have to have created a ssh key before hand at "~/.ssh/id_rsa.pub"
To create the k8s cluster, cd into the ansible dir, then run

``` bash
ansible-playbook -i inventory/hosts.ini -u ubuntu master_playbook.yml
```

## Deploying React Frontend

Run the **deploy_frontend_to_s3** python file in **scripts** directory
