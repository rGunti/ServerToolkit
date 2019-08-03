# Minecraft Server Scripts
- [setup.sh](setup.sh) - Setup a new Minecraft server instance using SpigotMC

## setup.sh
**Usage**:
```
$ [sudo] bash setup.sh -n <Instance Name> [<more parameters>]
```

This script automatically sets up a new Minecraft server instance using SpigotMC's Build Tools. As a little overview, here is what the script does:

1. Create a directory for the game server
2. Download BuildTools.jar from spigotmc.org
3. Create a new build of SpigotMC with the appropriate version of Minecraft
4. Create some configuration files for you and prefills some of the values
5. Create a launcher script
6. Setup a systemd daemon so the server can run in the background
7. Provide ownership to a dedicated user that runs the server

Due to its administrative nature, this script needs to run as root in order to work properly (best combined with `sudo`).

### Pre-requirements
For installing a minecraft server, you will need the following:
- **Root access** (or `sudo` permissions)<br>
  Note that you can also run this without root access by using
  `--skip-root`. However this will prevent you from e.g. setting up
  a daemon or configuring the server for another user.
- **Java 8** or later<br>
  Your java should be in your PATH for this to work, but you can provide
  your own Java instance using `--java-path`.
- **GIT**

Note that this script has been tested on Ubuntu Server and Windows
using Git Bash, however you will have reduced functionality on Windows.

### Parameters
#### Required parameters
- `-n <name>` / `--instance-name <name>`: Server Instance Name<br>
  This name will be used when generating the installation directory,
  it will be referenced in the daemon name and in the server
  configuration.

#### General flow parameters
- `--skip-root`: Skips the root check.<br>
  This allows you to run the script without root permissions but you
  will be limited to actions your own user account can do.
- `--skip-build`: Skips the SpigotMC build process
- `--skip-auto-config`: Skips auto-configuring the server
- `--skip-daemon`: Skips installing a systemd daemon

#### Setup parameters
- `--gs-user <username>`: The user with which the server will run<br>
  Default value: `gameserver`<br>
  This will also determin where the server instance will be installed
  to, namely in the users home directory.
- `--gs-home <path>`: Override user home<br>
  Default value: empty<br>
  Providing this value allows you to set the home directory of the
  user. This is useful when auto-detection of the users home fails.
- `--target-dir <path>`: Override install directory<br>
  When this value is not provided, the script will automatically decide
  where the server should be installed to (normally the server users 
  home directory). Providing this value will allow you to override this 
  behaviour.<br>
  This value will also override `--gs-home`.

- `--java-path <path>`: Override Java binary path<br>
  Default value: `java`<br>
  The script will use your installed Java instance from your systems
  PATH variable. This allows you to provide a custom Java instance.

- `--mc-version <Version>`: Defines what Minecraft version will be
  installed<br>
  Default value: `latest` (see SpigotMC documentation for definition)<br>
  Use this parameter to set the specific Minecraft version you want to
  install.

#### Auto-configuration parameters
**Note**: These parameters will have no effect if `--skip-auto-config` is
enabled.

- `--mc-server-port <Port>`: Set port where server will run on<br>
  Default value: `25565`
- `--mc-level-name <name>`: Set a custom name for the server level<br>
  Default value: `world`
- `--mc-level-seed <seed>`: Provide a custom level seed for the server
  level<br>
  Default value: empty
- `--mc-max-players <number>`: Sets the maximum amount of players permitted
  on the server<br>
  Default value: `10`

### Running on Windows
You can run this script on Windows however you will need to have the
following set of parameters in your call for this to work:

```
$ ./setup.sh -n <Instance Name> --skip-root --skip-daemon --gs-home <Home Folder>
```
