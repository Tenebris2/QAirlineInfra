# script to automate ip address generation to ansible inventory

import json
from helper import run_cmd


def generate_inventory():
    """
    Generate an Ansible inventory file with IP addresses.
    """
    # Get the list of IP addresses from the command
    workers_ip_list = json.loads(
        run_cmd("terraform output -json worker_nodes_public_ips")
    )
    masters_ip_list = json.loads(
        run_cmd("terraform output -json master_nodes_public_ips")
    )
    # Split the IP addresses into a list
    # Create the inventory file
    with open("./ansible/inventory/hosts.ini", "w") as f:
        f.write("[worker]\n")
        for i, ip in enumerate(workers_ip_list):
            f.write(f"worker-{i} ansible_host={ip}\n")
        f.write("[master]\n")
        for i, ip in enumerate(masters_ip_list):
            f.write(f"master-{i} ansible_host={ip}\n")

        f.write("[all:children]\nmaster\nworker")

    print("Inventory file generated: inventory.ini")


generate_inventory()
