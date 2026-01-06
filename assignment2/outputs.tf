# -----------------------------
# Local variables for backend info
# -----------------------------
locals {
  backend_lines = join("\n", [
    for name, server in module.backend_servers :
    "       - ${server.instance_id}: ${server.private_ip}"
  ])

  backend_list = [
    for name, server in module.backend_servers :
    "- ${name}: ${server.public_ip} (private: ${server.private_ip})"
  ]
}

# -----------------------------
# Quick Configuration Guide Output
# -----------------------------
output "configuration_guide" {
  description = "Instructions and server info after deployment"
  value = <<-EOT

    ========================================
    DEPLOYMENT SUCCESSFUL!
    ========================================

    Next Steps:
    1. SSH into Nginx server: ssh ec2-user@${module.nginx_server.public_ip}
    2. Edit Nginx config: sudo vim /etc/nginx/nginx.conf
    3. Update backend IPs in upstream block:
${local.backend_lines}
    4. Restart Nginx: sudo systemctl restart nginx
    5. Test: https://${module.nginx_server.public_ip}

    Backend Servers:
    ${join("\n    ", local.backend_list)}

    ========================================
  EOT
}
