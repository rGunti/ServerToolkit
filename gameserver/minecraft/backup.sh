#!/bin/bash
CURRENT_LOCATION="$(pwd -P)"
SCRIPT_LOCATION="$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd -P)"

source "${SCRIPT_LOCATION}/../../utils/functions.sh"

# ### Parameters ###
P_SKIP_ROOT=0
P_SKIP_DAEMON=0
P_SIMULATE=0
P_USER="gameserver"
#P_HOME=autodetect/optional
P_INSTANCE_NAME=""
P_TARGET_DIR=""
P_STORAGE_DIR="${CURRENT_LOCATION}"
P_WORLD_NAME=""

# ### Arguments ###
POSITIONAL=()
while [[ $# -gt 0 ]]
do
    key="$1"

    case ${key} in
        --skip-root)
        P_SKIP_ROOT=1
        shift
        ;;
        --skip-daemon)
        P_SKIP_DAEMON=1
        shift
        ;;
        --gs-user)
        P_USER="$2"
        shift; shift
        ;;
        --gs-home)
        P_HOME="$2"
        shift; shift;
        ;;
        -n|--instance-name)
        P_INSTANCE_NAME="$2"
        shift; shift;
        ;;
        --world-name)
        P_WORLD_NAME="$2"
        shift; shift;
        ;;
        --target-dir)
        P_TARGET_DIR="$2"
        shift; shift;
        ;;
        --backup-dir)
        P_STORAGE_DIR="$2"
        shift; shift;
        ;;
        --simulate)
        P_SIMULATE=1
        shift;
        ;;
        *)
        logFatal "Invalid parameter provided: $1"
        logWarn "Please refer to README.md provided with this script for more information."
        exit 1
        ;;
    esac
done

# ### Functions ###
function ensureGameserverUser {
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
# Pre-checks
if [[ $P_SKIP_ROOT -eq 0 ]]; then
    ensureRoot
else
    logWarn "Skipped Root check! The server daemon will not be shut down."
fi

if [[ -z $P_INSTANCE_NAME ]]; then
    logFatal "Failed to provide instance name for server (-n, --instance-name)"
    exit 1
else
    logDebug "We're going to backup the instance called \"${P_INSTANCE_NAME}\""
fi

if [[ -z $P_HOME ]]; then
    logDebug "Checking for gameserver home ..."
    ensureGameserverUser "${P_USER}"
    P_HOME=${GAMESERVER_HOMEDIR}
else
    logInfo "Gameserver User Home provided, skipping detection ..."
fi
logDebug "Gameserver User Home is ${P_HOME}"

if [[ -z $P_TARGET_DIR ]]; then
    P_TARGET_DIR="${P_HOME}/minecraft/${P_INSTANCE_NAME}/"
    logDebug "Backing up server \"${P_INSTANCE_NAME}\" at ${P_TARGET_DIR}"
else
    logDebug "Backing up server \"${P_INSTANCE_NAME}\" at provided location ${P_TARGET_DIR}"
fi

# Shutdown service
daemon_name="game-minecraft-${P_INSTANCE_NAME}"

if [[ $P_SKIP_ROOT -eq 0 ]] && [[ $P_SKIP_DAEMON -eq 0 ]]; then
    if [[ $P_SIMULATE -eq 0 ]]; then
        logVerbose "Shutting down server ..."
        systemctl stop "${daemon_name}"
    else
        logDebug "Simulation: Shutting down server ..."
    fi
fi

# Prepare the ZIP
backup_timestamp="$(date +'%Y%m%d-%H%M')"
zip_filename="${P_INSTANCE_NAME}-${backup_timestamp}.zip"
zip_filelist="${zip_filename}.LST"
zip_filelist_path="${P_STORAGE_DIR}/${zip_filelist}"

cd "${P_TARGET_DIR}"

if [[ -z $P_WORLD_NAME ]]; then
    logVerbose "Detecting world name ..."
    P_WORLD_NAME=$(cat "server.properties" | grep "level-name=" | cut -d'=' -f2)
    if [[ $? -ne 0 ]]; then
        logFatal "Cannot create backup because could not extract world name"
        exit 1
    fi
fi
logDebug "Storing world \"${P_WORLD_NAME}\""

logVerbose "Generating file list ..."
touch "${zip_filelist}"
find *.json \
    *.yml \
    *.txt \
    *.png \
    *.properties \
    *.sh \
    > "${zip_filelist_path}"
find plugins/ >> "${zip_filelist_path}"
find ${P_WORLD_NAME}*/ >> "${zip_filelist_path}"

# ZIP it
if [[ $P_SIMULATE -eq 0 ]]; then
    SECONDS=0

    logDebug "Packing the server ..."
    cat "${zip_filelist_path}" | zip -@ "${P_STORAGE_DIR}/${zip_filename}"
    if [[ $? -eq 0 ]]; then
        logInfo "Packing completed, took ${SECONDS} seconds"
    else
        logError "Failed to pack files"
    fi

    # Cleanup
    logVerbose "Deleting file list ..."
    rm "${zip_filelist_path}"
else
    logDebug "Simulation: Packing files listed in \"${zip_filelist_path}\""
fi

# Start server back up again
if [[ $P_SKIP_ROOT -eq 0 ]] && [[ $P_SKIP_DAEMON -eq 0 ]]; then
    if [[ $P_SIMULATE -eq 0 ]]; then
        logDebug "Starting server back up ..."
        systemctl start "${daemon_name}"
    else
        logDebug "Simulation: Starting server back up ..."
    fi
fi

# Finish
logInfo "Backup finished!"
logInfo "Backup stored here: ${P_STORAGE_DIR}/${zip_filename}"
