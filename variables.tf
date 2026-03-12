#######################
# Redis Cloud Authentication
#######################

variable "redis_global_api_key" {
  description = "Global API key for Redis Cloud account"
  type        = string
  sensitive   = true
}

variable "redis_global_secret_key" {
  description = "Global API Secret (USER KEY) for Redis Cloud account"
  type        = string
  sensitive   = true
}

#######################
# Subscription Configuration
#######################

variable "subscription_name" {
  description = "Name of the Redis Cloud subscription"
  type        = string
  default     = "redis-cloud-subscription"
}

variable "cloud_account_id" {
  description = "Cloud account ID (use '1' for Redis-managed, or your specific cloud account ID for BYOC)"
  type        = string
  default     = "1"
}

variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

variable "networking_deployment_cidr" {
  description = "CIDR block for Redis Cloud subscription (must be /24)"
  type        = string
  default     = "10.0.0.0/24"
}

variable "preferred_availability_zones" {
  description = "Preferred availability zones for the subscription"
  type        = list(string)
  default     = []
}

#######################
# Database Configuration
#######################

variable "database_name" {
  description = "Name of the Redis database"
  type        = string
  default     = "redis-db"
}

variable "user_password" {
  description = "Database password (leave empty for auto-generated)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "dataset_size_in_gb" {
  description = "Dataset size in GB (memory limit)"
  type        = number
  default     = 1
}

variable "throughput_measurement_by" {
  description = "Throughput measurement method: operations-per-second or number-of-shards"
  type        = string
  default     = "operations-per-second"
}

variable "throughput_measurement_value" {
  description = "Throughput measurement in operations per second"
  type        = number
  default     = 10000
}

variable "replication" {
  description = "Enable replication for high availability"
  type        = bool
  default     = true
}

variable "enable_tls" {
  description = "Enable TLS/SSL for connections"
  type        = bool
  default     = false
}

variable "data_persistence" {
  description = "Data persistence: none, aof-every-1-second, aof-every-write, snapshot-every-1-hour, snapshot-every-6-hours, snapshot-every-12-hours"
  type        = string
  default     = "aof-every-1-second"
}

variable "data_eviction" {
  description = "Data eviction policy"
  type        = string
  default     = "volatile-lru"
}

variable "support_oss_cluster_api" {
  description = "Support OSS Cluster API"
  type        = bool
  default     = false
}

variable "external_endpoint_for_oss_cluster_api" {
  description = "Use external endpoint for OSS Cluster API"
  type        = bool
  default     = false
}

#######################
# PrivateLink Configuration
#######################

variable "enable_privatelink" {
  description = "Enable AWS PrivateLink"
  type        = bool
  default     = true
}

variable "private_link_share_name" {
  description = "Share name for Redis Cloud PrivateLink"
  type        = string
  default     = ""
}

variable "private_link_principals" {
  description = "Principals to allow on the PrivateLink"
  type = list(object({
    principal       = string
    principal_type  = string # aws_account, organization, organization_unit, iam_role, iam_user, service_principal
    principal_alias = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for p in var.private_link_principals :
      contains(
        ["aws_account", "organization", "organization_unit", "iam_role", "iam_user", "service_principal"],
        p.principal_type
      )
    ])
    error_message = "Each principal_type must be one of: aws_account, organization, organization_unit, iam_role, iam_user, service_principal."
  }
}

#######################
# Alerts Configuration
#######################

variable "dataset_size_alert_percentage" {
  description = "Alert threshold for dataset size (percentage)"
  type        = number
  default     = 80
}

variable "throughput_alert_percentage" {
  description = "Alert threshold for throughput (percentage)"
  type        = number
  default     = 80
}

#######################
# Tags
#######################

variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

