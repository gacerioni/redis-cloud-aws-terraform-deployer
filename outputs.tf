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

output "database_private_endpoint_host" {
  description = "Private endpoint hostname (without port)"
  value       = var.enable_privatelink ? try(split(":", rediscloud_subscription_database.database.private_endpoint)[0], null) : null
}

output "redis_connection_info" {
  description = "Redis connection information (non-sensitive)"
  value = {
    host     = var.enable_privatelink ? try(split(":", rediscloud_subscription_database.database.private_endpoint)[0], rediscloud_subscription_database.database.public_endpoint) : rediscloud_subscription_database.database.public_endpoint
    port     = try(rediscloud_subscription_database.database.port, null)
    endpoint = var.enable_privatelink ? rediscloud_subscription_database.database.private_endpoint : rediscloud_subscription_database.database.public_endpoint
  }
}

output "connection_summary" {
  description = "📋 Complete connection summary (copy-paste ready!)"
  value = <<-EOT

  ╔════════════════════════════════════════════════════════════════════════════╗
  ║                    🎉 REDIS CLOUD CONNECTION INFO                          ║
  ╚════════════════════════════════════════════════════════════════════════════╝

  📍 ENDPOINT DETAILS:
  ────────────────────────────────────────────────────────────────────────────
  Host:     ${coalesce(try(var.enable_privatelink ? try(split(":", rediscloud_subscription_database.database.private_endpoint)[0], null) : try(split(":", rediscloud_subscription_database.database.public_endpoint)[0], null), null), "N/A")}
  Port:     ${coalesce(try(tostring(rediscloud_subscription_database.database.port), null), "N/A")}
  Endpoint: ${coalesce(try(var.enable_privatelink ? rediscloud_subscription_database.database.private_endpoint : rediscloud_subscription_database.database.public_endpoint, null), "N/A")}

  🔐 AUTHENTICATION:
  ────────────────────────────────────────────────────────────────────────────
  Password: Run 'terraform output -raw database_password' to get password

  ${var.create_aws_vpc_endpoint ? "🔗 AWS VPC ENDPOINT:\n  ────────────────────────────────────────────────────────────────────────────\n  VPC Endpoint ID: ${coalesce(try(aws_vpc_endpoint.redis_cloud[0].id, null), "N/A")}\n  Status:          ${coalesce(try(aws_vpc_endpoint.redis_cloud[0].state, null), "N/A")}\n  RAM Share:       ${coalesce(try(aws_ram_resource_share_accepter.redis_cloud[0].status, null), "N/A")}\n  " : ""}
  🧪 TEST CONNECTION:
  ────────────────────────────────────────────────────────────────────────────
  redis-cli -h ${coalesce(try(var.enable_privatelink ? try(split(":", rediscloud_subscription_database.database.private_endpoint)[0], null) : try(split(":", rediscloud_subscription_database.database.public_endpoint)[0], null), null), "N/A")} \
            -p ${coalesce(try(tostring(rediscloud_subscription_database.database.port), null), "N/A")} \
            -a $(terraform output -raw database_password) \
            ping

  📊 DATABASE INFO:
  ────────────────────────────────────────────────────────────────────────────
  Database ID:   ${coalesce(try(tostring(rediscloud_subscription_database.database.db_id), null), "N/A")}
  Database Name: ${var.database_name}
  Memory:        ${var.dataset_size_in_gb} GB
  Throughput:    ${var.throughput_measurement_value} ${var.throughput_measurement_by}
  HA Enabled:    ${var.replication}
  TLS Enabled:   ${var.enable_tls}

  ╔════════════════════════════════════════════════════════════════════════════╗
  ║  💡 TIP: Use 'terraform output -raw database_password' to get password    ║
  ╚════════════════════════════════════════════════════════════════════════════╝

  EOT
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
# AWS VPC Lattice Outputs
#######################

output "aws_ram_share_status" {
  description = "AWS RAM Resource Share acceptance status (if created)"
  value       = var.create_aws_vpc_endpoint ? try(aws_ram_resource_share_accepter.redis_cloud[0].status, null) : null
}

output "aws_vpc_endpoint_id" {
  description = "AWS VPC Endpoint ID for Lattice Resource Configuration (if created)"
  value       = var.create_aws_vpc_endpoint ? try(aws_vpc_endpoint.redis_cloud[0].id, null) : null
}

output "aws_vpc_endpoint_state" {
  description = "AWS VPC Endpoint state (if created)"
  value       = var.create_aws_vpc_endpoint ? try(aws_vpc_endpoint.redis_cloud[0].state, null) : null
}

output "aws_vpc_endpoint_dns_entries" {
  description = "AWS VPC Endpoint DNS entries (if created)"
  value       = var.create_aws_vpc_endpoint ? try(aws_vpc_endpoint.redis_cloud[0].dns_entry, []) : []
}

output "aws_security_group_id" {
  description = "AWS Security Group ID for VPC Lattice (if created)"
  value       = local.create_security_group ? try(aws_security_group.redis_vpc_endpoint[0].id, null) : null
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

