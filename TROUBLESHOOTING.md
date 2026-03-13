# Troubleshooting

## Known Issues

### PrivateLink Destroy Fails with 500 Error

**Symptom:**
```
Error: failed when deleting PrivateLink 500 INTERNAL_SERVER_ERROR - GENERAL_ERROR: 
General error occurred. Please contact Redis support with your task ID
```

**Cause:**
The `rediscloud_private_link` resource fails to delete when the AWS VPC Endpoint is destroyed first. This appears to be a provider bug in `redislabs/rediscloud v2.12.0`.

**Workaround:**

Option 1 - Remove from state before destroy:
```bash
terraform state rm 'rediscloud_private_link.private_link[0]'
terraform destroy
```

Option 2 - Manually delete PrivateLink first:
1. Go to Redis Cloud Console → Subscriptions → Connectivity → PrivateLink
2. Delete the PrivateLink connection
3. Run `terraform destroy`

**Status:** Reported to Redis Cloud provider team.

---

## Common Issues

### VPC Endpoint Creation Fails

**Symptom:**
```
Error: creating EC2 VPC Endpoint: InvalidServiceName
```

**Cause:**
The RAM Resource Share was not accepted before creating the VPC Endpoint.

**Solution:**
Wait a few seconds and retry. The `aws_ram_resource_share_accepter` resource should handle this automatically.

---

### Connection Refused from Application

**Symptom:**
Cannot connect to Redis from application in VPC.

**Checklist:**
1. ✅ VPC Endpoint is in "Available" state
2. ✅ Security Group allows inbound traffic on Redis port (10000-19999)
3. ✅ Application is in the same VPC as the VPC Endpoint
4. ✅ DNS resolution is enabled in VPC settings
5. ✅ Using the private endpoint (not public)

**Verify:**
```bash
# Check VPC Endpoint status
terraform output aws_vpc_endpoint_state

# Get private endpoint
terraform output -raw database_private_endpoint

# Test from EC2 instance in the VPC
redis-cli -h <private-endpoint-host> -p <port> -a <password> ping
```

---

## Getting Help

- **Redis Cloud Support:** https://redis.com/company/support/
- **Provider Issues:** https://github.com/RedisLabs/terraform-provider-rediscloud/issues
- **AWS PrivateLink Docs:** https://redis.io/docs/latest/operate/rc/security/aws-privatelink/

