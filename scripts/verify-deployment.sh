#!/usr/bin/env bash
# Read-only post-deployment checks. Does not create a service or expose credentials.
set -euo pipefail
ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
TASK_KUBECONFIG=${KUBECONFIG_GOLDENPATH:-"$ROOT_DIR/.generated/aws-kubeconfig"}
[[ -f "$TASK_KUBECONFIG" ]] || { echo 'GoldenPath kubeconfig missing; bootstrap must complete first.' >&2; exit 1; }
KUBECTL=(kubectl --kubeconfig "$TASK_KUBECONFIG" --request-timeout=30s)
"${KUBECTL[@]}" get nodes
"${KUBECTL[@]}" -n argocd get applications
"${KUBECTL[@]}" get providers.pkg.crossplane.io functions.pkg.crossplane.io
"${KUBECTL[@]}" -n backstage get externalsecrets
"${KUBECTL[@]}" -n backstage rollout status deployment/backstage --timeout=120s
"${KUBECTL[@]}" -n equipo-piloto get postgresqlinstances,deployments,services
"${KUBECTL[@]}" -n argocd get applications -o json | python3 -c 'import json,sys; apps=json.load(sys.stdin)["items"]; bad=[a["metadata"]["name"] for a in apps if a.get("status",{}).get("health",{}).get("status")!="Healthy" or a.get("status",{}).get("sync",{}).get("status")!="Synced"]; print("Unready Applications:",bad); sys.exit(bool(bad) or not apps)'
echo 'Control plane checks passed. Verify HTTPS login, a real Golden Path request and SELECT 1 next.'
