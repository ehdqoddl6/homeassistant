#!/usr/bin/with-contenv bashio
set -euo pipefail

export TOSS_CLIENT_ID="$(bashio::config 'toss_client_id')"
export TOSS_CLIENT_SECRET="$(bashio::config 'toss_client_secret')"
export TOSS_ACCOUNT_NO="$(bashio::config 'toss_account_no')"

if [[ -z "${TOSS_CLIENT_ID}" || -z "${TOSS_CLIENT_SECRET}" ]]; then
  bashio::log.error "toss_client_id and toss_client_secret must be configured"
  exit 1
fi

exec mcp-proxy --host=0.0.0.0 --port=8080 -- mcp-toss
