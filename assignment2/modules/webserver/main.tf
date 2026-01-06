# AWS Key Pair
resource "aws_key_pair" "this" {
  key_name   = "${var.env_prefix}-${var.instance_name}-${var.instance_suffix}-key"
  public_key = file(var.public_key)
  tags       = var.common_tags
}
# Get the latest Amazon Linux 2023 AMI for your region
data "aws_ssm_parameter" "latest_amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# EC2 Instance
resource "aws_instance" "this" {
  ami = data.aws_ssm_parameter.latest_amazon_linux_2023.value # Amazon Linux 2023 (update for your region if needed)
  instance_type           = var.instance_type
  subnet_id               = var.subnet_id
  vpc_security_group_ids  = [var.security_group_id]
  key_name                = aws_key_pair.this.key_name
  associate_public_ip_address = true
  availability_zone       = var.availability_zone

  user_data = file(var.script_path)

  tags = merge(var.common_tags, {
    Name = "${var.env_prefix}-${var.instance_name}-${var.instance_suffix}"
  })
}
