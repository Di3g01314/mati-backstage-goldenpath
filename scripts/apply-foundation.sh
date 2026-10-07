#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
source "$ROOT_DIR/scripts/require-deployment-authorization.sh"
TF_BIN=${TERRAFORM_BIN:-terraform}
PLAN=${1:?Provide the reviewed saved Terraform plan}
[[ -f "$ROOT_DIR/terraform/backend.tf" ]] || { echo 'Configure the dedicated remote state backend first.' >&2; exit 1; }
"$TF_BIN" -chdir="$ROOT_DIR/terraform" apply -input=false "$PLAN"
