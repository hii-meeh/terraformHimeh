#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# post-create.sh
# Runs once after the Codespace container is created.
# Installs all tools needed for Terraform: Up & Running 3rd Edition.
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

echo "============================================================"
echo " Terraform: Up & Running — Codespace Post-Create Setup"
echo "============================================================"

# ── 1. System packages ───────────────────────────────────────────────────────
echo "[1/8] Installing system packages..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
  curl \
  wget \
  unzip \
  git \
  jq \
  make \
  build-essential \
  ca-certificates \
  gnupg \
  lsb-release \
  bash-completion \
  groff \
  less

# ── 2. Terraform tools ───────────────────────────────────────────────────────
echo "[2/8] Installing Terraform ecosystem tools..."

# tfenv — manage multiple Terraform versions (great for the book examples)
if [ ! -d "$HOME/.tfenv" ]; then
  git clone --depth=1 https://github.com/tfutils/tfenv.git ~/.tfenv
  echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
  echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
fi
export PATH="$HOME/.tfenv/bin:$PATH"

# Install Terraform versions used in book (1.0+ stable + latest)
~/.tfenv/bin/tfenv install latest
~/.tfenv/bin/tfenv use latest

# tflint — Terraform linter
echo "Installing tflint..."
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# terraform-docs — auto-generate module docs
echo "Installing terraform-docs..."
TFDOCS_VERSION=$(curl -s https://api.github.com/repos/terraform-docs/terraform-docs/releases/latest | jq -r .tag_name)
curl -sSLo /tmp/terraform-docs.tar.gz \
  "https://github.com/terraform-docs/terraform-docs/releases/download/${TFDOCS_VERSION}/terraform-docs-${TFDOCS_VERSION}-linux-amd64.tar.gz"
tar -xzf /tmp/terraform-docs.tar.gz -C /tmp
sudo mv /tmp/terraform-docs /usr/local/bin/terraform-docs
chmod +x /usr/local/bin/terraform-docs

# tfsec — security scanner
echo "Installing tfsec..."
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
sudo mv ./tfsec /usr/local/bin/tfsec 2>/dev/null || true

# ── 3. Checkov — IaC security scanner ───────────────────────────────────────
echo "[3/8] Installing Checkov..."
pip3 install --quiet checkov

# ── 4. AWS tools ─────────────────────────────────────────────────────────────
echo "[4/8] Configuring AWS tools..."

# AWS CLI should already be installed via feature, verify
aws --version

# Install AWS Session Manager plugin (needed for SSM bastion examples)
echo "Installing AWS Session Manager plugin..."
curl -s "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" \
  -o /tmp/session-manager-plugin.deb
sudo dpkg -i /tmp/session-manager-plugin.deb 2>/dev/null || true

# eksctl — EKS cluster management (Ch 7 Kubernetes examples)
echo "Installing eksctl..."
ARCH=amd64
PLATFORM=$(uname -s)_$ARCH
curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_${PLATFORM}.tar.gz"
tar -xzf "eksctl_${PLATFORM}.tar.gz" -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
rm "eksctl_${PLATFORM}.tar.gz"

# ── 5. Packer — used in book for AMI building ───────────────────────────────
echo "[5/8] Installing Packer..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update -qq
sudo apt-get install -y -qq packer

# ── 6. Python packages ───────────────────────────────────────────────────────
echo "[6/8] Installing Python packages..."
pip3 install --quiet \
  boto3 \
  botocore \
  awscli \
  pre-commit \
  checkov \
  requests

# ── 7. Pre-commit hooks setup ────────────────────────────────────────────────
echo "[7/8] Setting up pre-commit..."
cat > ~/.pre-commit-config-template.yaml << 'EOF'
# Copy this to your repo root as .pre-commit-config.yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.5
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_tflint
      - id: terraform_tfsec
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-json
EOF
echo "Pre-commit template saved to ~/.pre-commit-config-template.yaml"

# ── 8. Shell aliases & helpers ───────────────────────────────────────────────
echo "[8/8] Setting up aliases and helpers..."
cat >> ~/.bashrc << 'ALIASES'

# ── Terraform: Up & Running aliases ──────────────────────────────────────────
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfaa='terraform apply -auto-approve'
alias tfd='terraform destroy'
alias tfda='terraform destroy -auto-approve'
alias tfo='terraform output'
alias tfs='terraform show'
alias tfv='terraform validate'
alias tffmt='terraform fmt -recursive'
alias tfws='terraform workspace'

# tflint shortcut
alias lint='tflint --recursive'

# AWS shortcuts
alias awsid='aws sts get-caller-identity'
alias awsregion='aws configure get region'

# terraform-docs
alias tfdocs='terraform-docs markdown table --output-file README.md .'

# Checkov scan current directory
alias tfscan='checkov -d .'

# Print current workspace
alias tfwho='terraform workspace show'

# Initialize + plan in one command
tfip() { terraform init && terraform plan "$@"; }

# Init + apply in one command
tfiaa() { terraform init && terraform apply -auto-approve "$@"; }

# Full destroy with init
tfclean() { terraform init && terraform destroy -auto-approve "$@"; }

ALIASES

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "============================================================"
echo " Setup complete! Tools installed:"
echo "============================================================"
terraform version
aws --version
packer version
tflint --version
terraform-docs --version
checkov --version
python3 --version
echo ""
echo " Aliases loaded (restart terminal or: source ~/.bashrc)"
echo " tfenv available: use 'tfenv install X.X.X' to switch versions"
echo "============================================================"
