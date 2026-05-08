#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Create the custom environment in Azure ML
#
# Prerequisites:
#   - .env file with: ENV_NAME, ENV_VERSION, ENV_IMAGE
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/load_env.sh"

CONDA_FILE="${SCRIPT_DIR}/../dependencies/conda.yaml"

# Archive existing environment if it exists
az ml environment archive \
    --name "${ENV_NAME}" \
    --version "${ENV_VERSION}" \
    &>/dev/null || true

# Create the environment
echo "Creating environment: ${ENV_NAME} (version: ${ENV_VERSION})..."
az ml environment create \
    --name "${ENV_NAME}" \
    --version "${ENV_VERSION}" \
    --description "Custom environment for Credit Card Defaults pipeline" \
    --conda-file "${CONDA_FILE}" \
    --image "${ENV_IMAGE}" \
    --tags "scikit-learn=0.24.2"

echo "Environment with name ${ENV_NAME} is registered to workspace, the environment version is ${ENV_VERSION}"
