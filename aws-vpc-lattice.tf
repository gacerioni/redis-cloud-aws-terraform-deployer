#######################
# AWS VPC Lattice Resource Endpoint for Redis Cloud PrivateLink
#######################
# Redis Cloud uses VPC Lattice Resource Endpoints
# This creates the consumer side of the PrivateLink connection
# Requires: create_aws_vpc_endpoint = true

# Step 1: Accept the RAM Resource Share
resource "aws_ram_resource_share_accepter" "redis_cloud" {
  count = var.create_aws_vpc_endpoint && var.enable_privatelink ? 1 : 0

  share_arn = rediscloud_private_link.private_link[0].share_arn
}

# Step 2: Create VPC Endpoint for Lattice Resource Configuration
resource "aws_vpc_endpoint" "redis_cloud" {
  count = var.create_aws_vpc_endpoint && var.enable_privatelink ? 1 : 0

  vpc_id              = var.aws_vpc_id
  vpc_endpoint_type   = "Resource"
  resource_configuration_arn = rediscloud_private_link.private_link[0].resource_configuration_arn
  security_group_ids  = local.vpc_endpoint_security_groups
  subnet_ids          = var.aws_subnet_ids

  # Enable private DNS for automatic resolution
  private_dns_enabled = true

  tags = merge(
    var.tags,
    {
      Name = "${var.subscription_name}-redis-cloud-endpoint"
    }
  )

  depends_on = [
    aws_ram_resource_share_accepter.redis_cloud
  ]

  lifecycle {
    # Prevent destroy before PrivateLink is destroyed
    # This helps avoid the 500 error when destroying PrivateLink
    create_before_destroy = false
  }
}

