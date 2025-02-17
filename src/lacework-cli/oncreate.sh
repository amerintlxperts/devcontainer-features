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
