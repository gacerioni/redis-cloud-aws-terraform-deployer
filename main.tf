#######################
# Redis Cloud Subscription
#######################

resource "rediscloud_subscription" "subscription" {
  name           = var.subscription_name
  payment_method = "credit-card"
  memory_storage = "ram"

  cloud_provider {
    provider = "AWS"

    cloud_account_id = var.cloud_account_id

    region {
      region                       = var.region
      networking_deployment_cidr   = var.networking_deployment_cidr
      preferred_availability_zones = var.preferred_availability_zones
    }
  }

  creation_plan {
    memory_limit_in_gb           = var.dataset_size_in_gb
    quantity                     = 1
    replication                  = var.replication
    support_oss_cluster_api      = var.support_oss_cluster_api
    throughput_measurement_by    = var.throughput_measurement_by
    throughput_measurement_value = var.throughput_measurement_value
    modules                      = []
  }
}

#######################
# Redis Database
#######################

resource "rediscloud_subscription_database" "database" {
  subscription_id = rediscloud_subscription.subscription.id
  name            = var.database_name
  protocol        = "redis"
  
  memory_limit_in_gb           = var.dataset_size_in_gb
  data_persistence             = var.data_persistence
  data_eviction                = var.data_eviction
  replication                  = var.replication
  throughput_measurement_by    = var.throughput_measurement_by
  throughput_measurement_value = var.throughput_measurement_value
  
  password = var.user_password != "" ? var.user_password : null
  
  support_oss_cluster_api               = var.support_oss_cluster_api
  external_endpoint_for_oss_cluster_api = var.external_endpoint_for_oss_cluster_api
  enable_tls                            = var.enable_tls
  
  alert {
    name  = "dataset-size"
    value = var.dataset_size_alert_percentage
  }
  
  alert {
    name  = "throughput-higher-than"
    value = var.throughput_alert_percentage
  }
}

