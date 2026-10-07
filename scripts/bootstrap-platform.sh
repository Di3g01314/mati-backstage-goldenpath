#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
source "$ROOT_DIR/scripts/require-deployment-authorization.sh"
PYTHON_BIN=${PYTHON_BIN:-python3}
"$PYTHON_BIN" "$ROOT_DIR/scripts/export-platform-values.py"
VALUES="$ROOT_DIR/.generated/platform-values.yaml"
TASK_CLUSTER=$("$PYTHON_BIN" -c 'import sys,yaml;print(yaml.safe_load(open(sys.argv[1]))["clusterName"])' "$VALUES")
TASK_REGION=$("$PYTHON_BIN" -c 'import sys,yaml;print(yaml.safe_load(open(sys.argv[1]))["aws"]["region"])' "$VALUES")
TASK_KUBECONFIG="$ROOT_DIR/.generated/aws-kubeconfig"
aws eks update-kubeconfig --name "$TASK_CLUSTER" --region "$TASK_REGION" --kubeconfig "$TASK_KUBECONFIG" >/dev/null
kubectl --kubeconfig "$TASK_KUBECONFIG" get nodes --request-timeout=15s
helm upgrade --install argocd argo-cd --repo https://argoproj.github.io/argo-helm --version 10.9.6 --namespace argocd --create-namespace --kubeconfig "$TASK_KUBECONFIG" -f "$ROOT_DIR/platform/argocd-values.yaml" --wait --timeout 10m
# Seed private Git credentials once. External Secrets assumes lifecycle management later.
"$PYTHON_BIN" "$ROOT_DIR/scripts/seed-argocd-credentials.py" "$VALUES" "$TASK_KUBECONFIG"
helm upgrade --install goldenpath-root "$ROOT_DIR/platform/charts/bootstrap" --namespace argocd --kubeconfig "$TASK_KUBECONFIG" -f "$VALUES" --set controllersOnly=false --wait --timeout 5m
# Remaining cluster resources are reconciled by Argo CD from Git.
echo 'Bootstrap complete. Inspect Argo CD and wait for all platform applications to become Healthy.'
