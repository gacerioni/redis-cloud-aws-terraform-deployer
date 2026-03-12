#######################
# Subscription Outputs
#######################

output "subscription_id" {
  description = "Redis Cloud subscription ID"
  value       = rediscloud_subscription.subscription.id
}

output "subscription_name" {
  description = "Subscription name"
  value       = rediscloud_subscription.subscription.name
}

#######################
# Database Outputs
#######################

output "database_id" {
  description = "Database ID"
  value       = rediscloud_subscription_database.database.db_id
}

output "database_name" {
  description = "Database name"
  value       = rediscloud_subscription_database.database.name
}

output "database_public_endpoint" {
  description = "Public endpoint (for testing only)"
  value       = rediscloud_subscription_database.database.public_endpoint
}

output "database_private_endpoint" {
  description = "Private endpoint (via PrivateLink)"
  value       = rediscloud_subscription_database.database.private_endpoint
}

output "database_port" {
  description = "Database port"
  value       = rediscloud_subscription_database.database.port
}

output "database_password" {
  description = "Database password"
  value       = rediscloud_subscription_database.database.password
  sensitive   = true
}

#######################
# PrivateLink Outputs
#######################

output "privatelink_share_arn" {
  description = "PrivateLink Share ARN"
  value       = var.enable_privatelink ? try(rediscloud_private_link.private_link[0].share_arn, null) : null
}

output "privatelink_resource_configuration_id" {
  description = "PrivateLink Resource Configuration ID"
  value       = var.enable_privatelink ? try(rediscloud_private_link.private_link[0].resource_configuration_id, null) : null
}

output "privatelink_resource_configuration_arn" {
  description = "PrivateLink Resource Configuration ARN"
  value       = var.enable_privatelink ? try(rediscloud_private_link.private_link[0].resource_configuration_arn, null) : null
}

output "privatelink_connections" {
  description = "PrivateLink connections"
  value       = var.enable_privatelink ? try(rediscloud_private_link.private_link[0].connections, []) : []
}

output "privatelink_databases" {
  description = "PrivateLink databases"
  value       = var.enable_privatelink ? try(rediscloud_private_link.private_link[0].databases, []) : []
}

#######################
# Connection Information
#######################

output "redis_connection_string" {
  description = "Redis connection string"
  value = var.enable_tls ? (
    var.enable_privatelink ?
      "rediss://:${rediscloud_subscription_database.database.password}@${rediscloud_subscription_database.database.private_endpoint}:${coalesce(rediscloud_subscription_database.database.port, "PORT")}" :
      "rediss://:${rediscloud_subscription_database.database.password}@${rediscloud_subscription_database.database.public_endpoint}:${coalesce(rediscloud_subscription_database.database.port, "PORT")}"
  ) : (
    var.enable_privatelink ?
      "redis://:${rediscloud_subscription_database.database.password}@${rediscloud_subscription_database.database.private_endpoint}:${coalesce(rediscloud_subscription_database.database.port, "PORT")}" :
      "redis://:${rediscloud_subscription_database.database.password}@${rediscloud_subscription_database.database.public_endpoint}:${coalesce(rediscloud_subscription_database.database.port, "PORT")}"
  )
  sensitive = true
}

#######################
# Configuration Summary
#######################

output "configuration_summary" {
  description = "Configuration summary"
  value = {
    subscription_name = var.subscription_name
    aws_region        = var.region
    cidr              = var.networking_deployment_cidr
    memory_gb         = var.dataset_size_in_gb
    high_availability = var.replication
    tls_enabled       = var.enable_tls
    persistence       = var.data_persistence
    eviction_policy   = var.data_eviction
    throughput        = "${var.throughput_measurement_value} ${var.throughput_measurement_by}"
    privatelink       = var.enable_privatelink
    byoc              = var.cloud_account_id != "1" ? "enabled (${var.cloud_account_id})" : "disabled"
  }
}

#######################
# Next Steps
#######################

output "next_steps" {
  description = "Next steps to complete setup"
  value = var.enable_privatelink ? join("", [
    "\n",
    "✅ Redis Cloud Subscription and Database created successfully!\n",
    "\n",
    "📋 NEXT STEPS (AWS PrivateLink):\n",
    "\n",
    "1. Get PrivateLink Resource Configuration ARN:\n",
    "   terraform output privatelink_resource_configuration_arn\n",
    "\n",
    "2. Create VPC Endpoint in your AWS account:\n",
    "   - Go to AWS Console → VPC → Endpoints → Create endpoint\n",
    "   - Service category: Find service by name\n",
    "   - Service name: Use the ARN from step 1\n",
    "   - VPC: Select your application VPC\n",
    "   - Subnets: Select appropriate subnets\n",
    "   - Security Group: Allow inbound on port ${coalesce(rediscloud_subscription_database.database.port, "PORT")}\n",
    "\n",
    "3. Get connection details:\n",
    "   terraform output -raw redis_connection_string\n",
    "   terraform output -raw database_password\n",
    "\n",
    "4. Check PrivateLink databases for endpoint:\n",
    "   terraform output privatelink_databases\n",
    "\n",
    "5. Test connectivity from your application VPC\n",
    "\n",
    "📚 Documentation: https://docs.redis.com/latest/rc/security/vpc-peering/\n",
    "\n"
  ]) : join("", [
    "\n",
    "✅ Redis Cloud Subscription and Database created successfully!\n",
    "\n",
    "📋 NEXT STEPS:\n",
    "\n",
    "1. Get connection string:\n",
    "   terraform output -raw redis_connection_string\n",
    "\n",
    "2. Get password:\n",
    "   terraform output -raw database_password\n",
    "\n",
    "3. Connect to Redis:\n",
    "   Endpoint: ${rediscloud_subscription_database.database.public_endpoint}\n",
    "   Port: ${coalesce(rediscloud_subscription_database.database.port, "PORT")}\n",
    "   TLS: ${var.enable_tls ? "Enabled (use rediss://)" : "Disabled (use redis://)"}\n",
    "\n",
    "⚠️  WARNING: Using public endpoint. For production, enable PrivateLink!\n",
    "\n"
  ])
}

