#!/bin/bash
set -e

curl https://raw.githubusercontent.com/lacework/go-sdk/main/cli/install.sh | bash -s --

USERNAME="${USERNAME:-${_REMOTE_USER}}"
FEATURE_ID="lacework-cli"

if [ -d "/dc/lacework-cli" ]; then
  echo "Cache directory /dc/lacework-cli already exists. Skip creation..."
else
  echo "Create cache directory /dc/lacework-cli..."
  mkdir -p "/dc/lacework-cli"
fi

if [ -n "${USERNAME}" ]; then
  echo "Change owner of /dc/lacework-cli to ${USERNAME}..."
  chown -R "${USERNAME}:${USERNAME}" "/dc/lacework-cli"
else
  echo "No username provided. Skip chown..."
fi

echo "Finished installing ${FEATURE_ID}"
