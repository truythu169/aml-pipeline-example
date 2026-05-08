#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Create the credit-card data asset in Azure ML
#
# Prerequisites:
#   - .env file with: DATASET_NAME, DATASET_VERSION, DATA_URL
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/load_env.sh"

LOCAL_FILE="default_of_credit_card_clients.csv"

# Archive existing data asset if it exists
az ml data archive \
    --name "${DATASET_NAME}" \
    --version "${DATASET_VERSION}" \
    &>/dev/null || true

# Download the CSV file
echo "Downloading ${LOCAL_FILE}..."
wget -q "${DATA_URL}" -O "${LOCAL_FILE}"

# Create the data asset
echo "Creating data asset: ${DATASET_NAME} (version: ${DATASET_VERSION})..."
az ml data create \
    --name "${DATASET_NAME}" \
    --version "${DATASET_VERSION}" \
    --description "Credit card data" \
    --path "${LOCAL_FILE}" \
    --type uri_file

echo "Data asset created. Name: ${DATASET_NAME}, version: ${DATASET_VERSION}"

# Clean up the local file
rm -f "${LOCAL_FILE}"
echo "Cleaned up local file."
