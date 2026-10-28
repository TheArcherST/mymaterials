#!/usr/bin/env bash
# Upload a new immutable release, then atomically switch the public symlink.
set -euo pipefail
artifact=${1:-.build/public}
: "${DEPLOY_HOST:?Set DEPLOY_HOST}"
: "${DEPLOY_USER:=mymaterials-deploy}"
: "${DEPLOY_PORT:=22}"
: "${DEPLOY_ROOT:=/var/www/mymaterials-releases}"
[[ "$DEPLOY_HOST" =~ ^[a-zA-Z0-9.-]+$ && "$DEPLOY_USER" =~ ^[a-zA-Z0-9_-]+$ && "$DEPLOY_PORT" =~ ^[0-9]+$ ]]
[[ "$DEPLOY_ROOT" == /var/www/mymaterials-releases ]]
test -f "$artifact/index.html"
test -f "$artifact/pdf-manifest.json"
# Never deploy a directory containing symlinks or private source material.
if find "$artifact" \( -type l -o -name '*.typ' -o -name print \) -print -quit | grep -q .; then
  echo 'Unexpected private source or symlink in release' >&2
  exit 1
fi
release="$(date -u +%Y%m%dT%H%M%SZ)-${GITHUB_SHA:-local}-${GITHUB_RUN_ID:-$$}-${GITHUB_RUN_ATTEMPT:-1}"
[[ "$release" =~ ^[a-zA-Z0-9_-]+$ ]]
ssh_args=(-o BatchMode=yes -o StrictHostKeyChecking=yes -p "$DEPLOY_PORT")
if [[ -n "${DEPLOY_SSH_KEY_FILE:-}" ]]; then
  [[ "$DEPLOY_SSH_KEY_FILE" =~ ^[a-zA-Z0-9_./-]+$ ]]
  ssh_args+=(-i "$DEPLOY_SSH_KEY_FILE")
fi
if [[ -n "${DEPLOY_KNOWN_HOSTS_FILE:-}" ]]; then
  [[ "$DEPLOY_KNOWN_HOSTS_FILE" =~ ^[a-zA-Z0-9_./-]+$ ]]
  ssh_args+=(-o "UserKnownHostsFile=$DEPLOY_KNOWN_HOSTS_FILE")
fi
target="$DEPLOY_USER@$DEPLOY_HOST"
ssh "${ssh_args[@]}" "$target" "mkdir '$DEPLOY_ROOT/$release'"
rsync -az --safe-links -e "ssh -o BatchMode=yes -o StrictHostKeyChecking=yes -p $DEPLOY_PORT${DEPLOY_SSH_KEY_FILE:+ -i $DEPLOY_SSH_KEY_FILE}${DEPLOY_KNOWN_HOSTS_FILE:+ -o UserKnownHostsFile=$DEPLOY_KNOWN_HOSTS_FILE}" \
  "$artifact/" "$target:$DEPLOY_ROOT/$release/"
ssh "${ssh_args[@]}" "$target" "python3 '$DEPLOY_ROOT/activate.py' '$release'"
echo "Published release $release"
