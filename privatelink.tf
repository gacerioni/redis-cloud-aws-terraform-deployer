#######################
# AWS PrivateLink Configuration
#######################

resource "rediscloud_private_link" "private_link" {
  count           = var.enable_privatelink ? 1 : 0
  subscription_id = rediscloud_subscription.subscription.id
  share_name      = var.private_link_share_name != "" ? var.private_link_share_name : "${var.subscription_name}-privatelink"

  dynamic "principal" {
    for_each = var.private_link_principals
    content {
      principal       = principal.value.principal
      principal_type  = principal.value.principal_type
      principal_alias = principal.value.principal_alias
    }
  }
}

