#!/bin/bash
SCRIPT_LOCATION="$(cd "$(dirname ${BASH_SOURCE[0]})"; pwd -P)"

source "${SCRIPT_LOCATION}/../../utils/functions.sh"

# ### Parameters ###
P_SKIP_ROOT=0
P_USER="gameserver"
#P_HOME=autodetect/optional
P_INSTANCE_NAME=""
P_TARGET_DIR=""
P_MC_VERSION="latest"

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
        --target-dir)
        P_TARGET_DIR="$2"
        shift; shift;
        ;;
        --mc-version)
        P_MC_VERSION="$2"
        shift; shift;
        ;;
        *)
        POSITIONAL+=("$1")
        shift
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
    logWarn "Skipped Root check ..."
fi

if [[ -z $P_INSTANCE_NAME ]]; then
    logFatal "Failed to provide instance name for server (-n, --instance-name)"
    exit 1
else
    logDebug "We're going to install a new instance called \"${P_INSTANCE_NAME}\""
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
    logDebug "Installing server \"${P_INSTANCE_NAME}\" at ${P_TARGET_DIR}"
else
    logDebug "Installing server \"${P_INSTANCE_NAME}\" at provided location ${P_TARGET_DIR}"
fi

# Create server directory
logVerbose "Creating server directory ${P_TARGET_DIR}"
mkdir -p "${P_TARGET_DIR}" &2> /dev/null

logVerbose "Changing to ${P_TARGET_DIR}"
cd "${P_TARGET_DIR}"

if [[ $? -ne 0 ]]; then
    logFatal "Could not create / change to server directory!"
    exit 1
fi

# Download BuildTools.jar
buildtools_src="https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar"
buildtools_path="BuildTools.jar"

if [[ ! -f "${buildtools_path}" ]]; then
    logVerbose "Downloading SpigotMC Build Tools ${buildtools_path} ..."
    curl "${buildtools_src}" --output "${buildtools_path}" --silent
    if [[ $? -ne 0 ]]; then
        logFatal "Could not download ${buildtools_path}!"
        exit 1
    elif [[ ! -f "${buildtools_path}" ]]; then
        logFatal "Could not find downloaded file ${buildtools_path}!"
        exit 1
    else
    logInfo "${buildtools_path} downloaded successfully"
    fi
else
    logInfo "${buildtools_path} already downloaded, skipping download"
fi

# Running BuildTools
buildtools_java_path=java

logVerbose "Now starting ${buildtools_path} for version \"${P_MC_VERSION}\", this could take a while ..."

${buildtools_java_path} -jar ${buildtools_path} --rev ${P_MC_VERSION}
