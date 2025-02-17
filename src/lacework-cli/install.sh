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

create_symlink_file() {
  local local_file="${1}"
  local cache_file="${2}"
  local username="${3}"

  # Ensure the parent directory for the symlink exists.
  runuser -u "${username}" -- mkdir -p "$(dirname "${local_file}")"

  # If a file (or symlink) already exists, move it aside.
  if [ -e "${local_file}" ]; then
    echo "Moving existing ${local_file} to ${local_file}-old"
    mv "${local_file}" "${local_file}-old"
  fi

  echo "Symlink ${local_file} to ${cache_file} for ${username}..."
  runuser -u "${username}" -- ln -s "${cache_file}" "${local_file}"
}

# Create cache directory for Lacework CLI configuration.
create_cache_dir "/dc/lacework-cli" "${USERNAME}"

# Create the file that will serve as the target of the symlink.
touch "/dc/lacework-cli/.lacework.toml"

echo "Finished installing ${FEATURE_ID}"
