# Architecture Documentation
---

## Overview
This document describes the architecture of **Assignment 2 – Multi-Tier Web Infrastructure** deployed on AWS using Terraform.

The system follows a **highly available multi-tier design** with a reverse proxy, load balancing, caching, and secure communication.

---

## Architecture Components
---

### Nginx Server (Reverse Proxy & Load Balancer)
- Acts as the public entry point
- Handles HTTP and HTTPS traffic
- Performs load balancing between backend servers
- Implements caching for performance optimization
- Configured with SSL/TLS and security headers

---

### Backend Web Servers
- **Web-1**: Primary Apache server
- **Web-2**: Primary Apache server
- **Web-3**: Backup Apache server (failover)

All backend servers serve dynamic content and are accessed only through the Nginx server.

---

## Network Topology
---
- One custom VPC
- One public subnet
- Internet Gateway attached to VPC
- Route table with default internet route

All EC2 instances are launched inside the same subnet for simplicity.

---

## Load Balancing & High Availability
---
- Nginx distributes traffic between Web-1 and Web-2
- Web-3 is configured as a backup server
- Backup server is activated only when primary servers are unavailable

---

## Security Design
---
- SSH access restricted to user's IP
- Backend servers allow HTTP traffic only from Nginx
- HTTPS enforced using self-signed SSL certificate
- Security headers enabled

---

## Performance Optimization
---
- Nginx proxy caching enabled
- Gzip compression configured
- Optimized worker processes

---

## Conclusion
---
This architecture ensures security, scalability, and high availability while following Infrastructure as Code (IaC) best practices.
