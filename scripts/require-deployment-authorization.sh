#!/usr/bin/env bash
# Source from every script that writes to AWS or an AWS cluster.
[[ "${GOLDENPATH_ALLOW_DEPLOY:-0}" == "1" ]] || { echo 'Deployment is disabled. Explicit authorization is required before enabling GOLDENPATH_ALLOW_DEPLOY=1.' >&2; exit 1; }
[[ -n "${EXPECTED_AWS_ACCOUNT:-}" ]] || { echo 'EXPECTED_AWS_ACCOUNT is required.' >&2; exit 1; }
TASK_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
[[ "$TASK_ACCOUNT" == "$EXPECTED_AWS_ACCOUNT" ]] || { echo 'AWS account mismatch.' >&2; exit 1; }
