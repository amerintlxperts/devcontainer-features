#!/bin/sh

set -e

# if the user is not root, chown /dc/lacework-cli to the user
if [ "$(id -u)" != "0" ]; then
    echo "Running post-start.sh for user $USER"
    sudo chown -R "$USER:$USER" /dc/lacework-cli
fi
