#!/bin/bash

# Fetch public IPs from Terraform output
frontend_ip=$(terraform output -raw frontend_public_ip)
backend_ip=$(terraform output -raw backend_public_ip)
db_ip=$(terraform output -raw db_public_ip)

# Create hosts.ini file
cat <<EOF > ./ansible/inventory/hosts.ini
[frontend]
frontend_host ansible_host=$frontend_ip

[backend]
backend_host ansible_host=$backend_ip

[database]
database_host ansible_host=$db_ip

[all:children]
frontend
backend
database
EOF

echo "hosts.ini file has been generated."
