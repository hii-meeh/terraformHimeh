#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# setup-aws-creds.sh
# Run this ONCE after your Codespace starts to configure AWS credentials.
# Uses GitHub Codespaces Secrets (recommended) or manual input.
# ─────────────────────────────────────────────────────────────────────────────

echo "============================================================"
echo " AWS Credentials Setup for Terraform: Up & Running"
echo "============================================================"
echo ""
echo "RECOMMENDED: Set these as GitHub Codespaces Secrets:"
echo "  Settings → Codespaces → Secrets → New secret"
echo ""
echo "  Secret name: AWS_ACCESS_KEY_ID"
echo "  Secret name: AWS_SECRET_ACCESS_KEY"
echo "  Secret name: AWS_DEFAULT_REGION  (e.g. us-east-1)"
echo ""
echo "These secrets auto-inject as env vars into your Codespace."
echo "No .env file or plaintext credentials needed."
echo ""

# Check if already configured via Codespaces secrets
if [ -n "${AWS_ACCESS_KEY_ID:-}" ] && [ -n "${AWS_SECRET_ACCESS_KEY:-}" ]; then
  echo "✅ AWS credentials detected from Codespaces Secrets!"
  echo ""
  aws sts get-caller-identity
  echo ""
  echo "You're ready to run Terraform against AWS."
else
  echo "⚠️  AWS credentials not found in environment."
  echo ""
  echo "Options:"
  echo "  1. Add GitHub Codespaces Secrets (recommended — see above)"
  echo "  2. Run: aws configure  (stores in ~/.aws/credentials)"
  echo "  3. Export manually:"
  echo "     export AWS_ACCESS_KEY_ID=YOUR_KEY"
  echo "     export AWS_SECRET_ACCESS_KEY=YOUR_SECRET"
  echo "     export AWS_DEFAULT_REGION=us-east-1"
  echo ""
  echo "After setting credentials, verify with:"
  echo "  aws sts get-caller-identity"
fi
