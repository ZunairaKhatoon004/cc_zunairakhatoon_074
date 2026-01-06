🚀 Advanced Terraform & Nginx Multi-Tier Architecture
📌 Project Overview

This project demonstrates the deployment of a production-ready, highly available multi-tier web architecture on Amazon Web Services (AWS) using Terraform and Nginx.

The infrastructure is designed using Infrastructure as Code (IaC) principles and includes secure networking, load balancing, caching, HTTPS, and failover mechanisms.

🏗 Architecture Overview

The deployed architecture follows a three-tier model:

🌐 Nginx Reverse Proxy

Acts as load balancer

Handles HTTPS traffic

Implements caching and security headers

🖥 Apache Backend Servers

web-1 (Primary)

web-2 (Primary)

web-3 (Backup / Failover)

☁ AWS Networking

Custom VPC

Public Subnet

Internet Gateway

📐 Architecture Diagram (Text-Based)
                   ┌───────────────┐
                   │   Internet    │
                   └───────┬───────┘
                           │ HTTPS (443)
                           ▼
               ┌────────────────────────┐
               │      Nginx Server       │
               │  Reverse Proxy / LB     │
               └───────────┬────────────┘
                           │
            ┌──────────────┴──────────────┐
            │                             │
      ┌──────────────┐            ┌──────────────┐
      │   Web-1       │            │   Web-2       │
      │   Apache      │            │   Apache      │
      └──────────────┘            └──────────────┘
                    ┌─────────────────────┐
                    │   Web-3 (Backup)    │
                    └─────────────────────┘

📁 Project Structure
Assignment2/
├── main.tf
├── variables.tf
├── outputs.tf
├── locals.tf
├── terraform.tfvars
├── .gitignore
├── modules/
│   ├── networking/
│   ├── security/
│   └── webserver/
├── scripts/
│   ├── nginx-setup.sh
│   └── apache-setup.sh
└── README.md

⚙️ Prerequisites
🔧 Required Tools

Terraform

AWS CLI

Git

SSH Client

🔐 AWS Credentials Setup
aws configure

🔑 SSH Key Generation
ssh-keygen -t ed25519

🚀 Deployment Instructions
Step-by-Step Deployment
terraform init
terraform validate
terraform plan
terraform apply -auto-approve

🔧 Post-Deployment Configuration
Update Backend IPs in Nginx
ssh ec2-user@<nginx-public-ip>
sudo vim /etc/nginx/nginx.conf

upstream backend_servers {
    server <web-1-private-ip>:80;
    server <web-2-private-ip>:80;
    server <web-3-private-ip>:80 backup;
}

sudo nginx -t
sudo systemctl restart nginx

🧪 Testing &️ Procedures
🔁 Load Balancing Test

Reload browser multiple times

Verify alternating responses from web-1 and web-2

Confirm web-3 is used only as backup

🗃 Cache Test

First request → X-Cache-Status: MISS

Second request → X-Cache-Status: HIT

🔄 High Availability Test

Stop Apache on web-1 and web-2

Verify traffic switches to web-3

Restart services

🔐 Security Architecture
🔒 Security Groups

Nginx Security Group

SSH (22): My IP only

HTTP (80): Anywhere

HTTPS (443): Anywhere

Backend Security Group

SSH (22): My IP only

HTTP (80): Nginx SG only

🛡 Security Features

HTTPS enforced

HTTP → HTTPS redirect

Security headers enabled

Restricted SSH access

⚡ Performance Optimization

Nginx caching enabled

Gzip compression

Load balancing with backup server

Optimized worker processes

🧰 Troubleshooting
📂 Log Locations
/var/log/nginx/access.log
/var/log/nginx/error.log

🛠 Debug Commands
sudo nginx -t
sudo systemctl status nginx
sudo tail -f /var/log/nginx/error.log

🏁 Conclusion

This project successfully demonstrates a secure, scalable, and highly available cloud infrastructure using Terraform and Nginx, fulfilling all assignment requirements.


👩‍💻 Submitted By

Zunaira Khatoon
Roll No: 2023-BSE-074
Section: V-B