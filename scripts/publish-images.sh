#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
source "$ROOT_DIR/scripts/require-deployment-authorization.sh"
TF_BIN=${TERRAFORM_BIN:-terraform}
TASK_REGION=${AWS_REGION:-us-east-1}
TASK_REGISTRY="$EXPECTED_AWS_ACCOUNT.dkr.ecr.$TASK_REGION.amazonaws.com"
aws ecr get-login-password --region "$TASK_REGION" | docker login --username AWS --password-stdin "$TASK_REGISTRY"
# EKS nodes are amd64; local Apple Silicon builds must target that platform.
for COMPONENT in backstage service-v0; do
  TASK_REPO=$("$TF_BIN" -chdir="$ROOT_DIR/terraform" output -json ecr_repository_urls | python3 -c 'import json,sys;v=json.load(sys.stdin);print(next(url for name,url in v.items() if name.endswith("/"+sys.argv[1])))' "$COMPONENT")
  TASK_CONTEXT="$ROOT_DIR/backstage"
  [[ "$COMPONENT" != service-v0 ]] || TASK_CONTEXT="$ROOT_DIR/services/service-v0"
  docker buildx build --platform linux/amd64 --tag "$TASK_REPO:v1" --push "$TASK_CONTEXT"
done
