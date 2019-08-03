#!/bin/bash
function log {
    _icon=$1
    _msg=$2
    echo "$(date +'%F %T') $1 $2"
}

function logInternal { log " ^ " "$1"; }
function logVerbose { log "   " "$1"; }
function logDebug { log " * " "$1"; }
function logInfo { log "[i]" "$1"; }
function logWarn { log "[!]" "$1"; }
function logError { log "/!\\" "$1"; }
function logFatal { >&2 log "!!!" "$1"; }

function echoErr { >&2 echo $1; }

logInternal "Included utils"
