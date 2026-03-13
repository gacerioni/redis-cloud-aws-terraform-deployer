terraform {
  required_version = ">= 1.0"

  required_providers {
    rediscloud = {
      source  = "RedisLabs/rediscloud"
      version = "~> 2.12.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

#######################
# Redis Cloud Provider
#######################
# API keys can be obtained from Redis Cloud Console > Access Management > API Keys
provider "rediscloud" {
  api_key    = var.redis_global_api_key
  secret_key = var.redis_global_secret_key
}

#######################
# AWS Provider
#######################
# Only used if create_aws_vpc_endpoint = true
provider "aws" {
  region = var.region
}

