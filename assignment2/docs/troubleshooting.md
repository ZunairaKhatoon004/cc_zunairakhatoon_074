# Troubleshooting Guide
---

This document lists common issues encountered during deployment and testing, along with their solutions.

---

## Issue 1: Nginx shows 502 Bad Gateway
**Cause:** Backend Apache service is not running.

**Solution:**
```bash
sudo systemctl start httpd
sudo systemctl status httpd
