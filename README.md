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
