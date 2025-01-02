#!/bin/bash
set -e

curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | bash
apt-get update
apt-get install speedtest
