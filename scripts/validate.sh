#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
TF_BIN=${TERRAFORM_BIN:-terraform}
command -v "$TF_BIN" >/dev/null || { echo "Terraform is required." >&2; exit 1; }
# No backend, AWS authentication, plan/apply or Kubernetes calls.
"$TF_BIN" -chdir="$ROOT_DIR/terraform" fmt -check -recursive
"$TF_BIN" -chdir="$ROOT_DIR/terraform" init -backend=false -input=false -lockfile=readonly
"$TF_BIN" -chdir="$ROOT_DIR/terraform" validate -no-color
# Every test uses mock_provider aws; run blocks use command = plan.
"$TF_BIN" -chdir="$ROOT_DIR/terraform" test -no-color
# Validate the independently bootstrapped backend and reusable module.
"$TF_BIN" -chdir="$ROOT_DIR/terraform/modules/pod-identity" init -backend=false -input=false -lockfile=readonly
"$TF_BIN" -chdir="$ROOT_DIR/terraform/modules/pod-identity" validate -no-color
"$TF_BIN" -chdir="$ROOT_DIR/terraform/bootstrap-state" init -backend=false -input=false -lockfile=readonly
"$TF_BIN" -chdir="$ROOT_DIR/terraform/bootstrap-state" validate -no-color
for file in "$ROOT_DIR"/scripts/*.sh; do bash -n "$file"; done
python3 "$ROOT_DIR/scripts/check-repository.py"
