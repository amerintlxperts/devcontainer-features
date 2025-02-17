#!/usr/bin/env bash

set -e

TARGET="/dc/lacework-cli"

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

create_symlink() {
  LINK="${1}"

  if [ ! -d "$(dirname "$LINK")" ]; then
    mkdir -p "$(dirname "$LINK")"
  fi

  if [ -e "$LINK" ]; then
    if [ -L "$LINK" ]; then
      current_target=$(readlink "$LINK")
      if [ "$current_target" = "$TARGET" ]; then
        echo "Symlink already exists and points to the correct target: $TARGET"
      else
        echo "Symlink exists but points to $current_target. Recreating symlink..."
        rm "$LINK"
        ln -sd "$TARGET" "$LINK"
      fi
    elif [ -d "$LINK" ]; then
      echo "$LINK exists as a directory. Moving its contents to $TARGET and replacing it with a symlink..."

      if [ ! -d "$TARGET" ]; then
        mkdir -p "$TARGET"
        echo "Created target directory: $TARGET"
      fi

      shopt -s dotglob
      if [ "$(ls -A "$LINK")" ]; then
        mv "$LINK"/* "$TARGET"/ 2>/dev/null
      fi
      shopt -u dotglob

      rm -rf "$LINK"
      ln -sd "$TARGET" "$LINK"
    else
      echo "$LINK exists but is neither a symlink nor a directory. Please remove it manually and re-run the script."
      exit 1
    fi
  else
    echo "$LINK does not exist. Creating symlink..."
    ln -sd "$TARGET" "$LINK"
  fi
}

create_symlink "${HOME}/.config/lacework"
create_symlink "${HOME}/.config/sca"

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
