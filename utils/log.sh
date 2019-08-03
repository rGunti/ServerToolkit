#!/bin/bash
COLOR_RED='\033[0;31m'
COLOR_LRED='\033[1;31m'
COLOR_DGRAY='\033[1;30m'
COLOR_LGRAY='\033[0;37m'
COLOR_LBLUE='\033[1;34m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_NONE='\033[0m'

function log {
    _icon="${1}"
    _msg="${2}"
    _color="${3}"
    echo -e "${_color}${_icon} ${_msg}${COLOR_NONE}"
}

function logWithTimestamp {
    _icon=$1
    _msg=$2
    echo -e "$(date +'%F %T') $1 $2"
}

function logInternal {
    if [ ! -z $ST_INTERNAL ]; then
        log " ^ " "${1}" ${COLOR_DGRAY}
    fi
}
function logVerbose { log "   " "${1}"; }
function logDebug { log " * " "${1}" ${COLOR_LBLUE}; }
function logInfo { log "[i]" "${1}" ${COLOR_GREEN}; }
function logWarn { log "[!]" "${1}" ${COLOR_YELLOW}; }
function logError { log "/!\\" "${1}" ${COLOR_LRED}; }
function logFatal { >&2 log "!!!" "${1}" ${COLOR_RED}; }

function echoErr { >&2 echo $1; }

logInternal "Included utils"
