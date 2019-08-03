#!/bin/bash
LIB_DIR="$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd -P)"
source "${LIB_DIR}/log.sh"

function ensureRoot {
    if [[ $EUID -ne 0 ]]; then
        logFatal "This script must be run as root"
        exit 1
    fi
}


logInternal "Included functions"
