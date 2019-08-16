#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

source _variables.source
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SCRIPT_DIR}"

if [[ $# -eq 0 ]] ; then
    echo "Syntax: $0 <environment>"
    exit 1
fi

ENV=$1
ENV_STATE_DIR="${SCRIPT_DIR}/state/${ENV}"
RELEASE_NAME="${ENVIRONMENT_PREFIX}-${ENV}"
VALUES_PATH="${ENV_STATE_DIR}/values.yaml"
SECRETS_PATH="${ENV_STATE_DIR}/secrets.yaml"

if [[ ! -f "${VALUES_PATH}" ]] ; then
    echo "Missing values-file ${VALUES_PATH}"
    exit 1
fi

if ! [ -x "$(command -v helm)" ]; then
  echo 'Error: Helm client is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v kubectl)" ]; then
  echo 'Error: kubectl is not installed.' >&2
  exit 1
fi

KUBE_CONTEXT=$(kubectl config current-context)
echo "Doing an initial install of ${ENV}."
echo
echo "Will"
echo "- Create the namespace ${RELEASE_NAME} to host the ${ENV} environment"
echo "- Install release ${RELEASE_NAME} into the ${ENV} environment using the chart ${CHART_PATH}"
echo
echo "Your current kubectl context is ${KUBE_CONTEXT}"
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Aborting"
    exit 1
fi

echo "Creating namespace ${RELEASE_NAME}"
kubectl create namespace "${RELEASE_NAME}"

echo "Installing the $ENV environment - waiting for all assets to be created..."
helm install \
  --wait \
  --namespace="${RELEASE_NAME}" \
  --name="${RELEASE_NAME}" \
  --values="${VALUES_PATH}" \
  --values="${SECRETS_PATH}" \
  "${CHART_PATH}" 

