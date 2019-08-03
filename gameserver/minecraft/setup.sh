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
P_JAVA_PATH="java"
P_SERVER_PORT=25565
P_LEVEL_NAME="world"
P_LEVEL_SEED=""
P_SERVER_CAPACITY=10
P_CONFIGURE=1
P_INSTALL_DAEMON=1
P_BUILD=1

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
        P_INSTALL_DAEMON=0
        shift
        ;;
        --skip-auto-config)
        P_CONFIGURE=0
        shift
        ;;
        --skip-build)
        P_BUILD=0
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
        --java-path)
        P_JAVA_PATH="$2"
        shift; shift;
        ;;
        --mc-version)
        P_MC_VERSION="$2"
        shift; shift;
        ;;
        --mc-server-port)
        P_SERVER_PORT="$2"
        shift; shift;
        ;;
        --mc-level-name)
        P_LEVEL_NAME="$2"
        shift; shift;
        ;;
        --mc-level-seed)
        P_LEVEL_SEED="$2"
        shift; shift;
        ;;
        --mc-max-players)
        P_SERVER_CAPACITY=$2
        shift; shift;
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
sleep 2
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
if [[ $P_BUILD -eq 1 ]]; then
    logVerbose "Now starting ${buildtools_path} for version \"${P_MC_VERSION}\", this could take a while ..."
    ${P_JAVA_PATH} -jar ${buildtools_path} --rev ${P_MC_VERSION}
    build_success=$?
    if [[ ${build_success} -ne 0 ]]; then
        logFatal "Build failed with exit code ${build_success}!"
        exit 2
    else
        logInfo "Build completed!"
    fi
else
    logWarn "Skipped build!"
fi

# Configuring server as intended
if [[ $P_CONFIGURE -eq 1 ]]; then
    logVerbose "Configuring server ..."
    # - Accepting EULA
    logVerbose " - Accepting EULA ..."
    echo "eula=true" > eula.txt

    logVerbose " - Creating Server Configuration ..."
    cat << EOF > server.properties
# Minecraft Server Configuration
# == Generated by rGunti's ServerToolkit at $(date +"%F %T") ==

level-name=${P_LEVEL_NAME}
level-seed=${P_LEVEL_SEED}
max-players=${P_SERVER_CAPACITY}
motd=${P_INSTANCE_NAME} - a Minecraft Server provided by rGunti's ServerToolkit
server-port=${P_SERVER_PORT}

allow-flight=false
allow-nether=true
broadcast-console-to-ops=true
broadcast-rcon-to-ops=true
debug=false
difficulty=easy
enable-command-block=false
enable-query=false
enable-rcon=false
enforce-whitelist=false
force-gamemode=false
function-permission-level=2
gamemode=survival
generate-structures=true
generator-settings=
hardcore=false
level-type=default
max-build-height=256
max-tick-time=60000
max-world-size=29999984
network-compression-threshold=256
online-mode=true
op-permission-level=4
player-idle-timeout=0
prevent-proxy-connections=false
pvp=true
query.port=25565
rcon.password=
rcon.port=25575
resource-pack=
resource-pack-sha1=
server-ip=
snooper-enabled=false
spawn-animals=true
spawn-monsters=true
spawn-npcs=true
spawn-protection=16
use-native-transport=true
view-distance=15
white-list=true
EOF

    logVerbose " - Creating Startup Script ..."
    spigot_path=$(ls -1 spigot-*.jar)
    logVerbose "   Server binary is ${spigot_path}"

    cat << EOF > startup.sh
#!/bin/bash
SCRIPT_LOCATION="\$(cd "\$(dirname \${BASH_SOURCE[0]})"; pwd -P)"
java -Xms2048M -Xmx4096M -XX:ParallelGCThreads=2 -XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10 -jar "\${SCRIPT_LOCATION}/${spigot_path}" nogui
EOF
    chmod +x ./startup.sh
else
    logWarn "Skipped configuration ..."
fi

# Installing as daemon
if [[ $P_INSTALL_DAEMON -eq 1 ]]; then
    daemon_name="game-minecraft-${P_INSTANCE_NAME}"
    daemon_path="/etc/systemd/system/${daemon_name}.service"
    logVerbose "Installing daemon \"${daemon_name}\"..."

    cat << EOF > "${daemon_path}"
[Unit]
Description=Game Server: Minecraft ${P_INSTANCE_NAME} (${P_SERVER_PORT})
After=network.target

[Service]
Type=simple
WorkingDirectory=${P_TARGET_DIR}
ExecStart=${P_TARGET_DIR}/startup.sh
User=${P_USER}
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

    logVerbose "Reloading system daemons ..."
    systemctl daemon-reload
else
    logWarn "Skipped daemon installation ..."
fi

# Setting permissions to server owner
if [[ $P_SKIP_ROOT -ne 1 ]]; then
    logVerbose "Assigning ownership ..."
    chown -R ${P_USER}:games "${P_TARGET_DIR}"
else
    logWarn "Skipped ownership assignment. Please assign ownership of the server folder to the accounut running the server using chown."
fi

# COMPLETED!
logInfo "Server installation completed!"
logInfo "Your server has been installed here: ${P_TARGET_DIR}"
logWarn "Please make sure that you start the server manually once to assign OP permissions to your account."
