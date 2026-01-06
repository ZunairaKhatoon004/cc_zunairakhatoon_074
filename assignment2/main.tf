# Get the latest Amazon Linux 2023 AMI for your region
data "aws_ssm_parameter" "latest_amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# -----------------------------
# Networking module
# -----------------------------
module "networking" {
  source           = "./modules/networking"
  vpc_cidr_block    = var.vpc_cidr_block
  subnet_cidr_block = var.subnet_cidr_block
  availability_zone = var.availability_zone
  env_prefix        = var.env_prefix
}

# -----------------------------
# Security module
# -----------------------------
module "security" {
  source     = "./modules/security"
  vpc_id     = module.networking.vpc_id
  env_prefix = var.env_prefix
  my_ip      = local.my_ip
}

# -----------------------------
# Nginx Webserver Module
# -----------------------------
module "nginx_server" {
  source            = "./modules/webserver"
  env_prefix        = var.env_prefix
  instance_name     = "nginx-proxy"
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  vpc_id            = module.networking.vpc_id
  subnet_id         = module.networking.subnet_id
  security_group_id = module.security.nginx_sg_id
  public_key        = var.public_key
  script_path       = "./scripts/nginx-setup.sh"  # <-- correct path
  instance_suffix   = "nginx"
  common_tags       = local.common_tags
}


# -----------------------------
# Backend Servers Module (3 servers)
# -----------------------------
module "backend_servers" {
  source = "./modules/webserver"

  for_each = { for server in local.backend_servers : server.name => server }

  env_prefix        = var.env_prefix
  instance_name     = each.value.name
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  vpc_id            = module.networking.vpc_id
  subnet_id         = module.networking.subnet_id
  security_group_id = module.security.backend_sg_id
  public_key        = var.public_key
  script_path       = "./scripts/apache-setup.sh" # same Apache script for all
  instance_suffix   = each.key                        # will use the server name as suffix
  common_tags       = local.common_tags
}
