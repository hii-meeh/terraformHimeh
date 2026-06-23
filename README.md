# Terraform: Up & Running — 3rd Edition
## GitHub Codespaces Dev Environment

Ready-to-go Codespace for working through every chapter of
**Terraform: Up & Running, 3rd Edition** by Yevgeniy Brikman.

---

## What's Included

### HashiCorp Tools
| Tool | Purpose |
|---|---|
| **Terraform** (latest via tfenv) | Core IaC tool — all chapters |
| **tfenv** | Switch between Terraform versions |
| **Packer** | Build AMIs (Chapter 8) |
| **HashiCorp Terraform extension** | HCL syntax, fmt, validate, language server |
| **HashiCorp HCL extension** | HCL file support |
| **HashiCorp Sentinel extension** | Policy as code |

### AWS Tools
| Tool | Purpose |
|---|---|
| **AWS CLI v2** | Interact with AWS, verify deployments |
| **AWS Toolkit** (VS Code) | Lambda, S3, CloudWatch from editor |
| **eksctl** | EKS cluster management (Ch 7) |
| **AWS Session Manager plugin** | SSM bastion access |
| **boto3** | Python AWS SDK |

### Terraform Quality Tools
| Tool | Purpose |
|---|---|
| **tflint** | Lint HCL for errors + best practices |
| **tfsec** | Security scan IaC |
| **Checkov** | Additional IaC security scanner |
| **terraform-docs** | Auto-generate module READMEs |
| **pre-commit** | Run checks before every commit |

---

## First-Time Setup

### 1. Create the Codespace
```
GitHub repo → Code → Codespaces → Create codespace on main
```
Wait ~3-5 minutes for `post-create.sh` to finish installing tools.

### 2. Configure AWS Credentials (IMPORTANT)
**Recommended — GitHub Codespaces Secrets (no plaintext credentials):**

```
GitHub → Settings → Codespaces → Secrets → New secret
```

Add these three secrets:
```
AWS_ACCESS_KEY_ID      = your-access-key
AWS_SECRET_ACCESS_KEY  = your-secret-key
AWS_DEFAULT_REGION     = us-east-1
```

These auto-inject into every Codespace as environment variables.

**Verify credentials work:**
```bash
bash .devcontainer/setup-aws-creds.sh
# or
aws sts get-caller-identity
```

### 3. Verify all tools
```bash
terraform version
aws --version
packer version
tflint --version
terraform-docs --version
checkov --version
```

---

## Aliases Available

| Alias | Command |
|---|---|
| `tf` | `terraform` |
| `tfi` | `terraform init` |
| `tfp` | `terraform plan` |
| `tfa` | `terraform apply` |
| `tfaa` | `terraform apply -auto-approve` |
| `tfd` | `terraform destroy` |
| `tfda` | `terraform destroy -auto-approve` |
| `tffmt` | `terraform fmt -recursive` |
| `tfv` | `terraform validate` |
| `tfscan` | `checkov -d .` |
| `tfdocs` | Auto-generate README from module |
| `awsid` | `aws sts get-caller-identity` |
| `tfip` | `terraform init && terraform plan` |
| `tfiaa` | `terraform init && terraform apply -auto-approve` |
| `tfclean` | `terraform init && terraform destroy -auto-approve` |

---

## Chapter Reference

| Chapter | Topics | Key Tools |
|---|---|---|
| 1 | Why Terraform | terraform, aws cli |
| 2 | Getting Started | EC2, S3, security groups |
| 3 | State | S3 backend, DynamoDB lock |
| 4 | Modules | Module structure, reuse |
| 5 | Tips & Tricks | Loops, conditionals, zero-downtime |
| 6 | Production | Multiple environments, workspaces |
| 7 | Testing | Terratest (Go), plan testing |
| 8 | How Terraform Works | Packer, AMIs |
| 9 | Terraform at Scale | Teams, CI/CD |

---

## Switching Terraform Versions

```bash
tfenv list-remote          # see available versions
tfenv install 1.5.7        # install specific version
tfenv use 1.5.7            # switch to it
terraform version          # verify
```

---

## ⚠️ Cost Reminder

Running through this book **will create real AWS resources that cost money.**

Always destroy resources after each chapter:
```bash
tfda    # terraform destroy -auto-approve
```

Set up AWS billing alerts:
```
AWS Console → Billing → Budgets → Create budget
Recommended: $20/month alert
```

---

## Security Notes

- **Never commit `.tfvars` files with real values** — covered in `.gitignore`
- **Never commit AWS credentials** — use Codespaces Secrets instead
- **Never commit `.terraform/` directory** — covered in `.gitignore`
- State files (`.tfstate`) contain sensitive data — use S3 remote backend (Ch 3)
