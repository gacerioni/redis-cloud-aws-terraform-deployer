# Redis Cloud AWS Terraform Deployer

Deploy Redis Cloud on AWS with PrivateLink using Terraform.

## 🎯 Overview

This Terraform configuration deploys:
- **Redis Cloud Subscription** on AWS
- **Redis Database** with configurable sizing and HA
- **AWS PrivateLink** for secure private connectivity

Perfect for migrating from AWS ElastiCache to Redis Cloud.

## 📋 Prerequisites

- Terraform >= 1.0
- Redis Cloud account with API keys
- AWS account (for PrivateLink)

## 🚀 Quick Start

### 1. Get Redis Cloud API Keys

1. Login to [Redis Cloud Console](https://app.redislabs.com)
2. Go to **Access Management** → **API Keys**
3. Create new API key (save both Account Key and Secret Key)

### 2. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 3. Deploy

```bash
terraform init
terraform plan
terraform apply
```

### 4. Get Connection Details

```bash
# Get connection string
terraform output -raw redis_connection_string

# Get password
terraform output -raw database_password

# Get PrivateLink service name (for VPC Endpoint)
terraform output privatelink_service_name
```

## 📝 Configuration

### Required Variables

- `redis_api_key`: Redis Cloud API Account Key
- `redis_secret_key`: Redis Cloud Secret Key

### Important Variables

- `cloud_account_id`: For BYOC (Bring Your Own Cloud), leave empty for Redis-managed
- `aws_region`: AWS region for deployment
- `networking_deployment_cidr`: CIDR for Redis Cloud (must be /24)
- `dataset_size_in_gb`: Memory limit for database
- `throughput_measurement_value`: Ops/sec or number of shards
- `replication`: Enable HA (true/false)
- `enable_tls`: Enable TLS (default: false)
- `enable_privatelink`: Enable AWS PrivateLink
- `private_link_principals`: List of AWS account IDs for PrivateLink access

## 🔐 Security Best Practices

1. **Never commit** `terraform.tfvars` to git
2. Use **PrivateLink** for production workloads
3. Enable **TLS** for encrypted connections
4. Use **strong passwords** or let Redis generate them
5. Enable **replication** for high availability

## 📊 Outputs

- `subscription_id`: Redis Cloud subscription ID
- `database_id`: Database ID
- `database_public_endpoint`: Public endpoint (testing only)
- `database_private_endpoint`: Private endpoint (via PrivateLink)
- `redis_connection_string`: Full connection string
- `privatelink_service_name`: AWS PrivateLink service name
- `next_steps`: Instructions for completing setup

## 🔗 PrivateLink Setup

After `terraform apply`, complete the AWS side:

1. Get the PrivateLink service name:
   ```bash
   terraform output privatelink_service_name
   ```

2. Create VPC Endpoint in AWS Console:
   - Go to **VPC** → **Endpoints** → **Create endpoint**
   - Service name: Use output from step 1
   - VPC: Select your application VPC
   - Subnets: Select appropriate subnets
   - Security Group: Allow inbound on Redis port

3. Test connectivity from your VPC

## 📚 Documentation

- [Redis Cloud Terraform Provider](https://registry.terraform.io/providers/RedisLabs/rediscloud/latest/docs)
- [Redis Cloud PrivateLink](https://docs.redis.com/latest/rc/security/vpc-peering/)
- [AWS PrivateLink](https://docs.aws.amazon.com/vpc/latest/privatelink/)

## 🤝 Contributing

This is a reference implementation for Redis Cloud deployments. Feel free to customize for your needs.

## 📄 License

MIT

