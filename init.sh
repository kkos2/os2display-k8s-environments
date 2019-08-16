#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
source _variables.source

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SCRIPT_DIR}"

if [[ $# -lt 2 ]] ; then
    echo "Syntax: $0 <environment> <initial-admin-release-number>"
    echo "eg. $0 production 1234"
    exit 1
fi

ENV=$1
ENV_STATE_DIR="${SCRIPT_DIR}/state/${ENV}"
ADMIN_RELEASE_NUMBER=$2
TEMPLATES_PATH="${SCRIPT_DIR}/templates"
VALUES_PATH="${ENV_STATE_DIR}/values.yaml"
SECRETS_PATH="${ENV_STATE_DIR}/secrets.yaml"

if [[ -d "${ENV_STATE_DIR}" ]] ; then 
  echo "The ${ENV_STATE_DIR} directory already exists, aborting init"
  exit 1
fi

if ! [ -x "$(command -v envsubst)" ]; then
  echo 'Error: envsubst is not installed.' >&2
  exit 1
fi

mkdir "${ENV_STATE_DIR}"

export ENVIRONMENT=$ENV
export ADMIN_SECRET=$(head /dev/urandom | tr -dc a-z0-9 | head -c50)
export RELEASE_IMAGE_PATH=$RELEASE_IMAGE_PATH
export RELEASE_TAG_PREFIX=$RELEASE_TAG_PREFIX
export BASE_URL=$BASE_URL
export ADMIN_RELEASE_NUMBER=$ADMIN_RELEASE_NUMBER
export SEARCH_SECRET=$(head /dev/urandom | tr -dc a-z0-9 | head -c50)
export SEARCH_ADMIN_USERNAME=admin-$(head /dev/urandom | tr -dc a-z0-9 | head -c5)
export SEARCH_ADMIN_PASSWORD=$(head /dev/urandom | tr -dc a-z0-9 | head -c10)
export MIDDLEWARE_SECRET=$(head /dev/urandom | tr -dc a-z0-9 | head -c50)
export MIDDLEWARE_ADMIN_USERNAME=admin-$(head /dev/urandom | tr -dc a-z0-9 | head -c5)
export MIDDLEWARE_ADMIN_PASSWORD=$(head /dev/urandom | tr -dc a-z0-9 | head -c10)

envsubst < "${TEMPLATES_PATH}/values-template.yaml" > "${VALUES_PATH}"
envsubst < "${TEMPLATES_PATH}/secrets-template.yaml" > "${SECRETS_PATH}"

echo "${VALUES_PATH} and ${SECRETS_PATH} has been generated, inspect the files and when you are ready, proceede to executing"
echo "./install.sh ${ENV}"
