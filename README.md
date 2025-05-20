
# QAirline Cloud Infrastructure

## Infrastructure Overview

End users initiate requests through **Amazon CloudFront**, a global content delivery network (CDN) that ensures low-latency access, HTTPS encryption, and support for custom domains.

Static assets for the **ReactJS frontend** are stored in an **Amazon S3** bucket, with CloudFront efficiently caching and delivering these assets to users worldwide.

Once the frontend is loaded, client-side API calls are routed through **CloudFront** using the `/api/*` path prefix. These requests are forwarded to an **Application Load Balancer (ALB)**, which serves as the entry point for backend traffic.

The ALB is integrated with a self managed **Kubernetes cluster **via a target group. Inside the cluster, backend services are deployed as scalable Pods that handle application logic and respond to API requests.

These services interact with a **relational database** hosted on **Amazon RDS**, ensuring reliable and persistent data storage.

This architecture provides a secure, scalable, and high-performance environment for delivering modern web applications.

# QairlineInfra Setup and Run Guide

## Setup Instructions

### 1. Clone the Repositories

Clone both the `qairlineinfra` and `QairlineCiCd` repositories to your local machine. Ensure they are in the same directory level.

```bash
git clone <qairlineinfra-repo-url>
git clone <QairlineCiCd-repo-url>
```

Replace `<qairlineinfra-repo-url>` and `<QairlineCiCd-repo-url>` with the actual repository URLs.

### 2. Create an IAM User with AdministratorAccess

To quickly set up an IAM user with full administrative privileges:

1. Log in to the AWS Management Console.
2. Navigate to **IAM** > **Users** > **Add users**.
3. Enter a username.
4. Select **Access key - Programmatic access** for CLI access.
5. Attach the `AdministratorAccess` policy:
   - Go to **Permissions** > **Attach existing policies directly**.
   - Search for and select `AdministratorAccess`.
6. Complete the user creation process and download the `.csv` file containing the **Access Key ID** and **Secret Access Key**. Save these securely.

**Note**: Using `AdministratorAccess` is convenient for testing but not recommended for production due to its broad permissions. Consider using least-privilege policies in production.

### 3. Configure AWS CLI Profile

Configure the AWS CLI with the `devops-user` profile using the access key and secret key from the IAM user.

Run the following command:

```bash
aws configure --profile devops-user
```

Provide the following details when prompted:
- **AWS Access Key ID**: Enter the Access Key ID from the `.csv` file.
- **AWS Secret Access Key**: Enter the Secret Access Key from the `.csv` file.
- **Default region name**: Enter your preferred AWS region (e.g., `us-east-1`).
- **Default output format**: Enter `json` (or your preferred format).

This creates a `devops-user` profile in your `~/.aws/credentials` and `~/.aws/config` files.

### 4. Download dependencies
Install Ansible:
```bash
pip install ansible
```
Go to this link and download Terraform: https://developer.hashicorp.com/terraform/install#darwin

Run the following command:
```bash
cd qairlineinfra
terraform init
```
### 5. Run the Infrastructure Setup

Navigate to the `qairlineinfra` directory:

```bash
cd qairlineinfra
```

Execute the `start.sh` script to deploy the infrastructure:

```bash
./start.sh
```

The `start.sh` script is assumed to handle the IaC deployment (e.g., using Terraform, AWS CloudFormation, or another tool). Refer to the script or repository documentation for specific details on what it does.

### 5. Destroying the Infrastructure 

To save, destroy the infrastructure after testing using

``` bash
./demolish.sh
```
