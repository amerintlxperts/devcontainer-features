#!/bin/bash
set -e

curl https://raw.githubusercontent.com/lacework/go-sdk/main/cli/install.sh | bash -s --

USERNAME="${USERNAME:-${_REMOTE_USER}}"
FEATURE_ID="lacework-cli"

create_cache_dir() {
  if [ -d "${1}" ]; then
    echo "Cache directory ${1} already exists. Skip creation..."
  else
    echo "Create cache directory ${1}..."
    mkdir -p "${1}"
  fi

  if [ -n "${2}" ]; then
    echo "Change owner of ${1} to ${2}..."
    chown -R "${2}:${2}" "${1}"
  else
    echo "No username provided. Skip chown..."
  fi
}

# Create cache directory for Lacework CLI configuration.
create_cache_dir "/dc/lacework-cli" "${USERNAME}"

echo "Finished installing ${FEATURE_ID}"
