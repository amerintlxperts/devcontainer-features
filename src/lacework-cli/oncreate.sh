#!/usr/bin/env bash

set -e

# if the user is not root, chown /dc/lacework-cli to the user
if [ "$(id -u)" != "0" ]; then
  echo "Running oncreate.sh for user ${USER}"
  sudo chown -R "${USER}:${USER}" /dc/lacework-cli
fi

lacework completion zsh >${HOME}/.oh-my-zsh/completions/_lacework

if [ -f ${HOME}/.lacework.toml ]; then
  mv ${HOME}/.lacework.toml /dc/lacework-cli/.lacework.toml
else
  touch /dc/lacework-cli/.lacework.toml
fi

ln -sf /dc/lacework-cli/.lacework.toml ${HOME}/.lacework.toml

# Run the "lacework account list" command and capture both stdout and stderr
output=$(lacework account list 2>&1)

# Check if the output contains the word "ERROR"
if echo "$output" | grep -q "ERROR"; then
  # If "ERROR" is found, exit with status 0
  exit 0
else
  lacework component install chronicle-alert-channel --nocolor --noninteractive
  lacework component install component-example --nocolor --noninteractive
  lacework component install iac --nocolor --noninteractive
  lacework component install preflight --nocolor --noninteractive
  lacework component install remediate --nocolor --noninteractive
  lacework component install sca --nocolor --noninteractive
fi
