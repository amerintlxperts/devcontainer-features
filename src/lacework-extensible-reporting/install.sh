#!/bin/bash
set -e

LACEWORK_VERSION=$(curl -s "https://api.github.com/repos/lacework/extensible-reporting/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

#ARCHTYPE=$(dpkg-architecture -q DEB_BUILD_ARCH)

#if [[ "${ARCHTYPE}" == "amd64" ]]; then
#  ARCHTYPE="x86_64"
#fi

curl -L -o lw_report_gen "https://github.com/lacework/extensible-reporting/releases/download/v${LACEWORK_VERSION}/lw_report_gen_linux_x86_64"
install lw_report_gen /usr/local/bin
rm lw_report_gen
