#!/bin/bash

terraform apply --auto-approve

python3 scripts/generate_inventory.py 
python3 scripts/generate_db.py
python3 scripts/deploy_frontend_to_s3.py

cd ansible
ansible-playbook -i inventory/hosts.ini -u ubuntu master_playbook.yml
