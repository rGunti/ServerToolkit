#!/bin/bash
SCRIPT_LOCATION="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPT_LOCATION}/log.sh"

logInternal "Internal"
logVerbose "Verbose"
logDebug "Debug"
logInfo "Info"
logWarn "Warning"
logError "Error"
logFatal "Fatal"
