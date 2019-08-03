#!/bin/bash
SCRIPT_LOCATION="$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd -P)"

source "${SCRIPT_LOCATION}/../../utils/functions.sh"

# ### Functions ###
function ensureGameserver {
    _gameserverUser=${1:-gameserver}

    userInfo=$(cat /etc/passwd | grep ${_gameserverUser})
    if [[ $? -ne 0 ]]; then
        logFatal "User \"${_gameserverUser}\" could not be found!"
        exit 1
        return
    fi

    IFS=':' read -ra ADDR <<< "${userInfo}"
    export GAMESERVER_HOMEDIR="${ADDR[5]}"
}

# ### main() ###
ensureRoot
ensureGameserver "gameserver"

echo "Gameserver Home Directory: ${GAMESERVER_HOMEDIR}"
