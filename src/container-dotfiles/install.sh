#!/bin/bash
set -e

check_packages() {
  if ! dpkg -s "$@" >/dev/null 2>&1; then
    apt-get update -y
    apt-get -y install --no-install-recommends "$@"
  fi
}

export DEBIAN_FRONTEND=noninteractive

check_packages locales locales-all

# shellcheck disable=SC2016
su -l "${_REMOTE_USER}" -c "echo 'eval \"\$(oh-my-posh init zsh --config /usr/local/share/oh-my-posh/powerlevel10k.omp.json)\"' >> ${_REMOTE_USER_HOME}/.zshrc"
# shellcheck disable=SC2016
su -l "${_REMOTE_USER}" -c "echo 'eval \"\$(oh-my-posh init bash --config /usr/local/share/oh-my-posh/powerlevel10k.omp.json)\"' >> ${_REMOTE_USER_HOME}/.bashrc"

if command -v az &>/dev/null; then
  su -l "${_REMOTE_USER}" -c "yes y | az config set auto-upgrade.enable=yes"
  su -l "${_REMOTE_USER}" -c "yes y | az config set auto-upgrade.prompt=no"
  if [ ! -d "${_REMOTE_USER_HOME}/.oh-my-zsh/custom" ]; then
    su -l "${_REMOTE_USER}" -c "mkdir -p ${_REMOTE_USER_HOME}/.oh-my-zsh/custom && chown $_REMOTE_USER:${_REMOTE_USER} ${_REMOTE_USER_HOME}/.oh-my-zsh/custom"
  fi
  su -l "${_REMOTE_USER}" -c "curl -L -o ${_REMOTE_USER_HOME}/.oh-my-zsh/custom/az.zsh https://raw.githubusercontent.com/Azure/azure-cli/dev/az.completion"
fi

if command -v tmux &>/dev/null; then
  su -l "${_REMOTE_USER}" -c "curl -L -o ${_REMOTE_USER_HOME}/.tmux.conf https://raw.githubusercontent.com/amerintlxperts/dotfiles/main/.tmux.conf"
  su -l "${_REMOTE_USER}" -c "mkdir -p ${_REMOTE_USER_HOME}/.tmux/plugins"
  su -l "${_REMOTE_USER}" -c "git clone https://github.com/tmux-plugins/tpm ${_REMOTE_USER_HOME}/.tmux/plugins/tpm"
fi

if command -v /opt/conda/bin/conda &>/dev/null; then
  su -l "${_REMOTE_USER}" -c "/opt/conda/bin/conda init --all"
  su -l "${_REMOTE_USER}" -c "/opt/conda/bin/conda config --set changeps1 False"
fi

su -l "${_REMOTE_USER}" -c "echo '(gh auth status >/dev/null 2>&1 | grep -q \"Logged in to github.com account\") || echo \"run the command:\ngh auth login\n\"' >> ${_REMOTE_USER_HOME}/.bashrc"
su -l "${_REMOTE_USER}" -c "echo '(gh auth status >/dev/null 2>&1 | grep -q \"Logged in to github.com account\") || echo \"run the command:\ngh auth login\n\"' >> ${_REMOTE_USER_HOME}/.zshrc"
