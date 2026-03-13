#######################
# AWS Security Group for Redis VPC Endpoint
#######################
# This security group is created only if:
# - create_aws_vpc_endpoint = true
# - aws_security_group_ids is empty (user didn't provide existing SG)

locals {
  create_security_group = var.create_aws_vpc_endpoint && length(var.aws_security_group_ids) == 0
  
  # Use provided SGs or the created one
  vpc_endpoint_security_groups = var.create_aws_vpc_endpoint ? (
    length(var.aws_security_group_ids) > 0 ? 
      var.aws_security_group_ids : 
      [aws_security_group.redis_vpc_endpoint[0].id]
  ) : []
}

resource "aws_security_group" "redis_vpc_endpoint" {
  count = local.create_security_group ? 1 : 0
  
  name_prefix = "${var.subscription_name}-redis-endpoint-"
  description = "Security group for Redis Cloud VPC Endpoint"
  vpc_id      = var.aws_vpc_id
  
  tags = merge(
    var.tags,
    {
      Name = "${var.subscription_name}-redis-endpoint"
    }
  )
  
  lifecycle {
    create_before_destroy = true
  }
}

# Ingress rule: Allow Redis traffic from specified CIDR blocks
resource "aws_vpc_security_group_ingress_rule" "redis_from_cidr" {
  count = local.create_security_group && length(var.aws_allowed_cidr_blocks) > 0 ? length(var.aws_allowed_cidr_blocks) : 0
  
  security_group_id = aws_security_group.redis_vpc_endpoint[0].id
  description       = "Allow Redis traffic from ${var.aws_allowed_cidr_blocks[count.index]}"
  
  from_port   = 10000
  to_port     = 19999
  ip_protocol = "tcp"
  cidr_ipv4   = var.aws_allowed_cidr_blocks[count.index]
  
  tags = merge(
    var.tags,
    {
      Name = "redis-from-${replace(var.aws_allowed_cidr_blocks[count.index], "/", "-")}"
    }
  )
}

# Ingress rule: If no CIDR blocks specified, allow from VPC CIDR
resource "aws_vpc_security_group_ingress_rule" "redis_from_vpc" {
  count = local.create_security_group && length(var.aws_allowed_cidr_blocks) == 0 ? 1 : 0
  
  security_group_id = aws_security_group.redis_vpc_endpoint[0].id
  description       = "Allow Redis traffic from VPC"
  
  from_port   = 10000
  to_port     = 19999
  ip_protocol = "tcp"
  cidr_ipv4   = data.aws_vpc.selected[0].cidr_block
  
  tags = merge(
    var.tags,
    {
      Name = "redis-from-vpc"
    }
  )
}

# Egress rule: Allow all outbound (default)
resource "aws_vpc_security_group_egress_rule" "allow_all" {
  count = local.create_security_group ? 1 : 0
  
  security_group_id = aws_security_group.redis_vpc_endpoint[0].id
  description       = "Allow all outbound traffic"
  
  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
  
  tags = var.tags
}

# Data source to get VPC CIDR if needed
data "aws_vpc" "selected" {
  count = var.create_aws_vpc_endpoint ? 1 : 0
  id    = var.aws_vpc_id
}

