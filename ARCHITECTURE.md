# Arquitetura do Projeto

## 📁 Estrutura de Arquivos

```
├── providers.tf                              # Providers: Redis Cloud + AWS
├── variables.tf                              # Todas as variáveis
├── main.tf                                   # Redis Cloud: Subscription + Database
├── privatelink.tf                            # Redis Cloud: PrivateLink
├── aws-security-group.tf                     # AWS: Security Group (opcional)
├── aws-vpc-endpoint.tf                       # AWS: VPC Endpoint (opcional)
├── outputs.tf                                # Outputs de todos os recursos
├── terraform.tfvars                          # Sua configuração (gitignored)
├── terraform.tfvars.example                  # Template básico
├── terraform.tfvars.full-automation-example  # Template com automação AWS
├── MIGRATION_PLAYBOOK.md                     # Guia de migração
└── README.md                                 # Documentação principal
```

## 🏗️ Arquitetura de Deployment

### Modo 1: Redis Cloud Only (default)

```
┌─────────────────────────────────────────────────────────────┐
│ Terraform Apply                                             │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ Redis Cloud (Automated)                                     │
│  ├─ Subscription                                            │
│  ├─ Database                                                │
│  └─ PrivateLink (provider side)                             │
└─────────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│ AWS (Manual)                                                │
│  └─ VPC Endpoint (você cria manualmente)                    │
└─────────────────────────────────────────────────────────────┘
```

### Modo 2: Full Automation (create_aws_vpc_endpoint = true)

```
┌─────────────────────────────────────────────────────────────┐
│ Terraform Apply (ONE COMMAND!)                              │
└─────────────────────────────────────────────────────────────┘
                          │
          ┌───────────────┴───────────────┐
          ▼                               ▼
┌──────────────────────┐      ┌──────────────────────┐
│ Redis Cloud          │      │ AWS                  │
│  ├─ Subscription     │      │  ├─ VPC Endpoint     │
│  ├─ Database         │◄─────┤  ├─ Security Group   │
│  └─ PrivateLink      │      │  └─ DNS Resolution   │
└──────────────────────┘      └──────────────────────┘
                          │
                          ▼
              ✅ PRONTO PARA USAR!
```

## 🔧 Componentes

### Redis Cloud (sempre criado)

1. **Subscription** (`main.tf`)
   - Região AWS
   - CIDR de deployment
   - Cloud account (BYOC ou Redis-managed)

2. **Database** (`main.tf`)
   - Sizing (GB + ops/sec)
   - High Availability
   - Persistência
   - Alertas

3. **PrivateLink** (`privatelink.tf`)
   - Share name
   - Principals (AWS accounts/roles)
   - Service ARN

### AWS (opcional - `create_aws_vpc_endpoint = true`)

4. **Security Group** (`aws-security-group.tf`)
   - Criado automaticamente se não fornecer um existente
   - Regras de ingress para portas Redis (10000-19999)
   - Permite tráfego dos CIDRs especificados

5. **VPC Endpoint** (`aws-vpc-endpoint.tf`)
   - Interface endpoint para PrivateLink
   - DNS privado habilitado
   - Conectado às subnets especificadas

## 🎯 Fluxo de Dados

```
Application (VPC)
      │
      │ (private connection)
      ▼
VPC Endpoint (AWS)
      │
      │ (PrivateLink)
      ▼
Redis Cloud PrivateLink
      │
      ▼
Redis Database
```

## 🔐 Segurança

### Secrets Management

- ✅ `terraform.tfvars` está no `.gitignore`
- ✅ Passwords são marcados como `sensitive`
- ✅ Outputs sensíveis não aparecem em logs

### Network Security

- ✅ PrivateLink = tráfego nunca sai da rede AWS
- ✅ Security Group controla acesso
- ✅ Sem IPs públicos expostos

## 📊 Variáveis Principais

| Variável | Obrigatória | Default | Descrição |
|----------|-------------|---------|-----------|
| `redis_global_api_key` | ✅ | - | API key do Redis Cloud |
| `redis_global_secret_key` | ✅ | - | Secret key do Redis Cloud |
| `create_aws_vpc_endpoint` | ❌ | `false` | Criar VPC Endpoint automaticamente |
| `aws_vpc_id` | ⚠️ | `""` | VPC ID (obrigatório se automação AWS) |
| `aws_subnet_ids` | ⚠️ | `[]` | Subnet IDs (obrigatório se automação AWS) |
| `enable_privatelink` | ❌ | `true` | Habilitar PrivateLink |
| `dataset_size_in_gb` | ❌ | `5` | Tamanho do database |
| `throughput_measurement_value` | ❌ | `10000` | Ops/sec |
| `replication` | ❌ | `true` | High Availability |

⚠️ = Obrigatório apenas se `create_aws_vpc_endpoint = true`

## 🚀 Casos de Uso

### Caso 1: Demo/POC Rápida
```hcl
create_aws_vpc_endpoint = true
# Tudo automatizado, perfeito para demos
```

### Caso 2: Produção com Controle AWS Separado
```hcl
create_aws_vpc_endpoint = false
# Redis Cloud via Terraform, AWS VPC Endpoint via outro processo
```

### Caso 3: Cliente sem Permissões AWS
```hcl
create_aws_vpc_endpoint = false
# Terraform só cria Redis Cloud, cliente cria VPC Endpoint manualmente
```

## 💡 Dicas

1. **Para demos**: Use `create_aws_vpc_endpoint = true` - impacto máximo!
2. **Para produção**: Considere separar AWS resources em outro módulo
3. **Para clientes**: Deixe `create_aws_vpc_endpoint = false` por padrão

