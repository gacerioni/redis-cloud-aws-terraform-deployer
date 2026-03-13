# Playbook de Migração: AWS ElastiCache para Redis Cloud

## 🎯 TL;DR

**Tempo:** 15 minutos | **Downtime:** Zero | **Comandos:** 1 (com automação completa)

Migrar para Valkey = 1 clique. Migrar para Redis Cloud = 1 comando Terraform.
**Mesmo esforço. Resultado completamente diferente.**

---

## ⚡ Modo Rápido: Automação Completa

Se você tem permissões AWS, pode fazer **tudo** com um único comando:

```bash
# Configure terraform.tfvars com create_aws_vpc_endpoint = true
terraform apply
```

**Pronto!** Redis Cloud + VPC Endpoint + Security Group + DNS = tudo configurado.

---

## 🚀 Migração em 4 Passos (Modo Manual)

### 1️⃣ Configure (2 minutos)

Edite `terraform.tfvars` com suas credenciais e configuração:

```hcl
redis_global_api_key    = "sua-api-key"      # Pegue em app.redislabs.com
redis_global_secret_key = "sua-secret-key"

region                       = "us-east-1"   # Mesma do ElastiCache
dataset_size_in_gb           = 1             # Mesmo tamanho
throughput_measurement_value = 1000          # Mesmas ops/sec
replication                  = true

enable_privatelink           = true
private_link_principals = [
  {
    principal       = "123456789012"         # Seu AWS Account ID
    principal_type  = "aws_account"
    principal_alias = "producao"
  }
]

# 🚀 OPCIONAL: Automação completa (cria VPC Endpoint automaticamente)
create_aws_vpc_endpoint = true
aws_vpc_id              = "vpc-xxxxx"
aws_subnet_ids          = ["subnet-xxxxx", "subnet-yyyyy"]
aws_allowed_cidr_blocks = ["10.0.0.0/16"]
```

### 2️⃣ Deploy (3 minutos)

```bash
terraform init
terraform apply
```

### 3️⃣ Configure VPC Endpoint (5 minutos ou 0 se usou automação)

**Se `create_aws_vpc_endpoint = true`:** Pule este passo! Já está pronto. ✅

**Se `create_aws_vpc_endpoint = false`:**

```bash
# Pegue o ARN do PrivateLink
terraform output privatelink_resource_configuration_arn
```

**AWS Console** → **VPC** → **Endpoints** → **Create endpoint**
Cole o ARN, selecione sua VPC e subnets. Pronto.

### 4️⃣ Atualize sua App (5 minutos)

```bash
# Pegue a connection string
terraform output redis_connection_string
```

Atualize o endpoint na sua aplicação e faça deploy gradual (blue/green).

---

## 🎁 Por Que Redis Cloud?

| | Valkey (fork) | Redis Cloud |
|---|---|---|
| **Versão** | Fork congelado | Redis oficial sempre atualizado |
| **Features** | Básico | JSON, Search, TimeSeries, Bloom |
| **Multi-cloud** | ❌ | ✅ AWS, GCP, Azure |
| **Suporte** | AWS (lento) | Redis experts 24/7 |
| **Custo** | $150/mês | $120/mês (-20%) |

