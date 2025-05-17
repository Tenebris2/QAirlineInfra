#!/bin/bash

aws s3 rm s3://qairlines-website-react-bucket/ --recursive --profile devops-user
terraform destroy -auto-approve
