#!/bin/bash
function log {
    _icon=$1
    _msg=$2
    echo "$(date +'%F %T') $1 $2"
}

function logInternal { log " ^ " "$2"; }
function logVerbose { log "   " "$2"; }
function logDebug { log " * " "$2"; }
function logInfo { log "[i]" "$2"; }
function logWarn { log "[!]" "$2"; }
function logError { log "/!\\" "$2"; }
function logFatal { >&2 log "!!!" "$2"; }

function echoErr { >&2 echo $1; }

logInternal "Included utils"
