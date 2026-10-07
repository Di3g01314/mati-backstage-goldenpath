#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
TF_BIN=${TERRAFORM_BIN:-terraform}
INPUT=${1:?Usage: plan-aws.sh path/to/environment.tfvars.json}
EXPECTED_ACCOUNT=${EXPECTED_AWS_ACCOUNT:?Set the target AWS account explicitly.}
ACTUAL_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
[[ "$ACTUAL_ACCOUNT" == "$EXPECTED_ACCOUNT" ]] || { echo 'AWS account mismatch' >&2; exit 1; }
mkdir -p "$ROOT_DIR/.generated"
# Only a plan. The tracked default remains deployment_enabled=false.
if [[ -f "$ROOT_DIR/terraform/backend.tf" ]]; then
  "$TF_BIN" -chdir="$ROOT_DIR/terraform" init -input=false -lockfile=readonly
else
  "$TF_BIN" -chdir="$ROOT_DIR/terraform" init -backend=false -input=false -lockfile=readonly
fi
"$TF_BIN" -chdir="$ROOT_DIR/terraform" plan -input=false -var-file="$INPUT" -var=deployment_enabled=true -out="$ROOT_DIR/.generated/aws.tfplan"
"$TF_BIN" -chdir="$ROOT_DIR/terraform" show -json "$ROOT_DIR/.generated/aws.tfplan" > "$ROOT_DIR/.generated/aws-plan.json"
python3 "$ROOT_DIR/scripts/summarize-plan.py" "$ROOT_DIR/.generated/aws-plan.json"
