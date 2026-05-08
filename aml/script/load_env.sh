#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Load .env and configure Azure CLI defaults
#
# Prerequisites:
#   - .env file with: AZURE_SUBSCRIPTION_ID, AZURE_RESOURCE_GROUP,
#     AZURE_WORKSPACE_NAME
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/../../.env"

if [[ ! -f "${ENV_FILE}" ]]; then
    echo "Error: .env file not found at ${ENV_FILE}" >&2
    exit 1
fi

# Load variables from .env
set -a
source "${ENV_FILE}"
set +a

# Set az cli defaults
az configure --defaults \
    group="${AZURE_RESOURCE_GROUP}" \
    workspace="${AZURE_WORKSPACE_NAME}"
az account set --subscription "${AZURE_SUBSCRIPTION_ID}"
