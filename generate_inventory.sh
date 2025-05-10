#!/bin/bash

# Fetch public IPs from Terraform output
worker_nodes_ip = $(terraform output -raw worker_nodes_public_ip)
master_nodes_ip = $(terraform output -raw master_nodes_public_ip)
db_ip=$(terraform output -raw db_public_ip)

# Create hosts.ini file
cat <<EOF > ./ansible/inventory/hosts.ini
[workers]
frontend_host ansible_host=$frontend_ip

[masters]
backend_host ansible_host=$backend_ip

[all:children]
workers 
masters
EOF

echo "hosts.ini file has been generated."
