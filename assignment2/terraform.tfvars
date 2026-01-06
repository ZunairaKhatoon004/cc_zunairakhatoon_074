vpc_cidr_block    = "10.0.0.0/16"
subnet_cidr_block = "10.0.10.0/24"
availability_zone = "me-central-1a"
env_prefix        = "prod"
instance_type     = "t3.micro"
public_key        = "~/.ssh/id_ed25519.pub"
private_key       = "~/.ssh/id_ed25519"

backend_servers = [
  { name = "backend1", script_path = "scripts/backend1.sh" },
  { name = "backend2", script_path = "scripts/backend2.sh" },
  { name = "backend3", script_path = "scripts/backend3.sh" }
]
