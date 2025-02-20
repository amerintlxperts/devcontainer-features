#!/usr/bin/env bash
set -e

TARGET="/dc/lacework-cli"

# Ensure the oh-my-zsh completions directory exists
if [ ! -d "${HOME}/.oh-my-zsh/completions" ]; then
  mkdir -p "${HOME}/.oh-my-zsh/completions"
fi

# Generate zsh completion for lacework and save it
lacework completion zsh >"${HOME}/.oh-my-zsh/completions/_lacework"

# If a .lacework.toml file exists in the home directory, move it; otherwise, create an empty one
if [ -L "${HOME}/.lacework.toml" ]; then
  toml_link=$(readlink "${HOME}/.lacework.toml")
  if [ "$toml_link" = "$TARGET/.lacework.toml" ]; then
    echo "Symlink already exists and points to the correct target: $TARGET/.lacework.toml"
  else
    echo "Symlink exists but points to $toml_link. Recreating symlink..."
    rm "${HOME}/.lacework.toml"
    ln -s "${TARGET}/.lacework.toml" "${HOME}/.lacework.toml"
  fi
elif [ -f "${HOME}/.lacework.toml" ]; then
  mv "${HOME}/.lacework.toml" "${TARGET}/.lacework.toml"
fi
touch "${TARGET}/.lacework.toml"

# Create a symlink from the target .lacework.toml to the home directory
ln -sf "${TARGET}/.lacework.toml" "${HOME}/.lacework.toml"

# Function to create a symlink for a given directory.
create_symlink() {
  local LINK="${1}"

  # Ensure the parent directory exists
  if [ ! -d "$(dirname $LINK)" ]; then
    mkdir -p "$(dirname $LINK)"
  fi

  if [ -e "$LINK" ]; then
    if [ -L "$LINK" ]; then
      current_target=$(readlink "$LINK")
      if [ "$current_target" = "$TARGET" ]; then
        echo "Symlink already exists and points to the correct target: $TARGET"
      else
        echo "Symlink exists but points to $current_target. Recreating symlink..."
        rm -rf "$LINK" && ln -sf "$TARGET" "$LINK"
      fi
    elif [ -d "$LINK" ]; then
      echo "$LINK exists as a directory. Copying its contents to $TARGET and replacing it with a symlink..."
      if [ ! -d "$TARGET" ]; then
        mkdir -p "$TARGET"
        echo "Created target directory: $TARGET"
      fi
      shopt -s dotglob
      if [ "$(ls -A $LINK)" ]; then
        cp -a ${LINK}/* ${TARGET} && rm -rf "${LINK}" && ln -sf "${TARGET}" "${LINK}"
      fi
      shopt -u dotglob
    else
      echo "$LINK exists but is neither a symlink nor a directory. Please remove it manually and re-run the script."
    fi
  else
    echo "$LINK does not exist. Creating symlink..."
    ln -s "$TARGET" "$LINK"
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
  lacework component install preflight --nocolor --noninteractive
  lacework component install remediate --nocolor --noninteractive
  lacework component install sca --nocolor --noninteractive
  lacework component install vuln-scanner --nocolor --noninteractive
fi
