#!/bin/bash
# Updates the git repository to the newest version and makes all scripts executable
SCRIPT_LOCATION="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "${SCRIPT_LOCATION}/utils/log.sh"

cd "$SCRIPT_LOCATION"

logVerbose "Resetting ..."
git reset --hard HEAD

logVerbose "Pulling updates ..."
git pull

if [ $? -ne 0 ]; then
    logFatal "Failed to update scripts!"
    exit 1
fi

logVerbose "Making scripts executable ..."
chmod +x **/*.sh
chmod +x ./update.sh

logInfo "Update completed!"
