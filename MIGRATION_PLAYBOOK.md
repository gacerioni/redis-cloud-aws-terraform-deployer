# Playbook de Migração: AWS ElastiCache para Redis Cloud

## 📋 Premissas

Esta migração assume:
1. **Sem Multi-Tenancy** (um redis database por subscription)
2. **Dados voláteis** (cache que pode ser reconstruído)
3. **Zero downtime** (migração gradual com blue/green deployment)

---

## Estimativa de Esforço

| Etapa | Descrição | Duração |
|-------|-----------|---------|
| 1. Configuração | Editar `terraform.tfvars` | 2 minutos |
| 2. Deploy | `terraform apply` | 15 minutos |
| 3. Atualizar App | Atualizar endpoint na app | 3 minutos |
| **Total** |  | **20 minutos** |

---

## ⚡ Modo Rápido: Automação Completa

Se você tem permissões AWS, pode fazer **tudo** com um único comando:

```bash
# Configure terraform.tfvars com create_aws_vpc_endpoint = true
terraform apply
```

**Pronto!** Redis Cloud + VPC Endpoint + Security Group + DNS = tudo configurado.

---

## 🚀 Migração em 3 Passos

### 1️⃣ Configure

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

### 2️⃣ Deploy

```bash
terraform init
terraform apply
```

### 3️⃣ Atualize sua App

```bash
# Pegue a connection string
terraform output redis_connection_string
```

Atualize o endpoint na sua aplicação e faça deploy gradual (blue/green).

---
