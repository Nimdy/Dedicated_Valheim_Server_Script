#!/bin/bash
###############################################################################################
###############################################################################################
####
#### File name: valheimplus.sh
####
###############################################################################################
#### ValheimPlus mod functionality for Valheim server
#### Handles installation, configuration and management of the ValheimPlus mod
###############################################################################################

# Set ValheimPlus specific variables
valheimPlusConfigPath="${valheimInstallPath}/${worldname}/BepInEx/config"
valheimPlusVersionFile="${valheimInstallPath}/${worldname}/localValheimPlusVersion"

########################################################################
################## ValheimPlus Installation Functions ###################
########################################################################

# Install ValheimPlus
function install_valheim_plus() {
    clear
    echo ""

    if [ ! -f /usr/bin/unzip ]; then
        apt install unzip -y
    fi

    tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_INSTALL_CHANGING_DIR"; tput setaf 9;
    cd "${valheimInstallPath}/${worldname}"

    tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_INSTALL_CHECKING_OLD_INSTALL"; tput setaf 9;
    [ -e UnixServer.zip ] && rm UnixServer.zip

    tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_INSTALL_DOWNLOADING_VALHEIM_PLUS_FROM_REPO"; tput setaf 9;
    curl -s https://api.github.com/repos/Grantapher/ValheimPlus/releases/latest \
        | grep "browser_download_url.*UnixServer\.zip" \
        | cut -d ":" -f 2,3 | tr -d \" \
        | wget -P "${valheimInstallPath}/${worldname}" -qi -
    echo ""
    sleep 1

    tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_INSTALL_CREATING_VER_STAMP"; tput setaf 9;
    curl -sL https://api.github.com/repos/Grantapher/ValheimPlus/releases/latest \
        | grep '"tag_name":' | cut -d'"' -f4 > "$valheimPlusVersionFile"

    tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_INSTALL_UNPACKING_FILES"; tput setaf 9;
    unzip -o UnixServer.zip

    tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_INSTALL_REMOVING_OLD_BEPINEX_CONFIG"; tput setaf 9;
    [ -e start_game_bepinex.sh ] && rm start_game_bepinex.sh

    tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_INSTALL_BUILDING_NEW_BEPINEX_CONFIG"; tput setaf 9;
    build_start_server_bepinex_configuration_file

    tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_INSTALL_SETTING_STEAM_OWNERSHIP"; tput setaf 9;
    chown steam:steam -Rf /home/steam/*
    chmod +x start_server_bepinex.sh
    rm UnixServer.zip
    echo ""

    tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_INSTALL_GET_THEIR_VIKING_ON"; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_INSTALL_LETS_GO"; tput setaf 9;
}

# Enable ValheimPlus
function valheim_plus_enable() {
    clear
    echo ""
    tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_ENABLE" ; tput setaf 9; 
    valheimVanilla=2
    set_valheim_server_vanillaOrPlus_operations
    sleep 1
    systemctl daemon-reload
    sleep 1
    echo "$FUNCTION_VALHEIM_PLUS_RESTARTING"
    systemctl restart valheimserver_${worldname}.service
    sleep 1
    tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_ENABLED_ACTIVE" ; tput setaf 9; 
    echo ""
}

# Disable ValheimPlus
function valheim_plus_disable() {
    clear
    echo ""
    tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_DISABLE" ; tput setaf 9; 
    valheimVanilla=1
    set_valheim_server_vanillaOrPlus_operations
    sleep 1
    systemctl daemon-reload
    sleep 1
    echo "$FUNCTION_VALHEIM_PLUS_DISABLE_RESTARTING"
    systemctl restart valheimserver_${worldname}.service
    sleep 1    
    tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_DISABLE_INFO" ; tput setaf 9; 
    echo ""
}

# Update ValheimPlus
function valheim_plus_update() {
    check_valheim_plus_repo
    clear
    tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_UPDATE_INFO"; tput setaf 9;

    vpLocalCheck=$(cat "${valheimPlusVersionFile}")
    echo "$vpLocalCheck"
    echo "$latestValPlus"

    if [[ "$latestValPlus" == "$vpLocalCheck" ]]; then
        echo ""
        tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_UPDATE_NO_UPDATE_FOUND"; tput setaf 9;
        echo ""
    else
        tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_UPDATE_UPDATE_FOUND"; tput setaf 9;
        tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_UPDATE_CONTINUE"; tput setaf 9;
        read -p "$PLEASE_CONFIRM" confirmValPlusUpdate

        if [ "$confirmValPlusUpdate" == "y" ]; then
            tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_UPDATE_BACKING_UP_VPLUS_CONFIG"; tput setaf 9;
            dldir=$backupPath
            [ ! -d "$dldir" ] && mkdir -p "$dldir"
            sleep 1

            TODAYMK="$(date +%Y-%m-%d-%T)"
            cp "${valheimPlusConfigPath}/valheim_plus.cfg" "${backupPath}/valheim_plus-${worldname}-${TODAYMK}.cfg"

            tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_UPDATE_DOWNLOADING_VPLUS"; tput setaf 9;
            install_valheim_plus
            sleep 2

            tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_UPDATE_RESTARTING_SERVICES"; tput setaf 9;
            restart_valheim_server
        else
            echo "$FUNCTION_VALHEIM_PLUS_UPDATE_CANCELED"; tput setaf 9;
            sleep 2
        fi
    fi
}

# Edit ValheimPlus config options
function valheimplus_mod_options() {
    clear
    nano ${valheimPlusConfigPath}/valheim_plus.cfg
    echo ""
    tput setaf 2; echo "$DRAW80" ; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_EDIT_VPLUS_CONFIG_SAVE_RESTART" ; tput setaf 9; 
    tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_EDIT_VPLUS_CONFIG_SAVE_RESTART_1" ; tput setaf 9; 
    tput setaf 2; echo "$DRAW80" ; tput setaf 9;
    echo ""
    read -p "$PLEASE_CONFIRM" confirmRestart
    #if y, then continue, else cancel
    if [ "$confirmRestart" == "y" ]; then
        echo ""
        echo "$FUNCTION_VALHEIM_PLUS_EDIT_VPLUS_RESTART_SERVICES"
        sudo systemctl restart valheimserver_${worldname}.service
        echo ""
    else
        echo "$FUNCTION_VALHEIM_PLUS_EDIT_VPLUS_CANCEL"
        sleep 2
        clear
    fi
}

# Edit BepInEx config options
function bepinex_mod_options() {
    clear
    nano ${valheimPlusConfigPath}/BepInEx.cfg
    echo ""
    tput setaf 2; echo "$DRAW80" ; tput setaf 9;
    echo "$FUNCTION_VALHEIM_PLUS_EDIT_BEPINEX_CONFIG_RESTART"
    echo "$FUNCTION_VALHEIM_PLUS_EDIT_BEPINEX_CONFIG_RESTART_1"
    tput setaf 2; echo "$DRAW80" ; tput setaf 9;
    echo ""
    read -p "$PLEASE_CONFIRM" confirmRestart
    #if y, then continue, else cancel
    if [ "$confirmRestart" == "y" ]; then
        echo ""
        echo "$FUNCTION_VALHEIM_PLUS_EDIT_BEPINEX_RESTART_SERVICE_INFO"
        sudo systemctl restart valheimserver_${worldname}.service
        echo ""
    else
        echo "$FUNCTION_VALHEIM_PLUS_EDIT_BEPINEX_CANCEL"
        sleep 2
        clear
    fi
}

########################################################################
###################### Configuration Functions #########################
########################################################################

# Set up systemd service for ValheimPlus
function set_valheim_server_vanillaOrPlus_operations() {
    # Build systemctl configurations for execution of processes for Valheim Server
    tput setaf 1; echo "$FUNCTION_VALHEIM_PLUS_BUILD_CONFIG_INFO"; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_VALHEIM_PLUS_BUILD_CONFIG_INFO_1"; tput setaf 9;

    # Remove old Valheim Server Service
    [ -e /etc/systemd/system/valheimserver_${worldname}.service ] && rm /etc/systemd/system/valheimserver_${worldname}.service
    sleep 1

    # Add new Valheim Server Service
    cat <<EOF > /lib/systemd/system/valheimserver_${worldname}.service
[Unit]
Description=Valheim Server
Wants=network-online.target
After=syslog.target network.target nss-lookup.target network-online.target

[Service]
Type=simple
Restart=on-failure
RestartSec=5
StartLimitInterval=60s
StartLimitBurst=3
User=steam
Group=steam
ExecStartPre=$steamexe +login anonymous +force_install_dir ${valheimInstallPath}/${worldname} +app_update 896660 validate +exit
EOF

    if [ "$valheimVanilla" == "1" ]; then
        echo "$FUNCTION_VALHEIM_PLUS_BUILD_CONFIG_SET_VANILLA"
        cat >> /lib/systemd/system/valheimserver_${worldname}.service <<EOF
ExecStart=${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh
ExecReload=/bin/kill -s HUP \$MAINPID
KillSignal=SIGINT
WorkingDirectory=${valheimInstallPath}/${worldname}
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF
    else
        echo "$FUNCTION_VALHEIM_PLUS_BUILD_CONFIG_SET_PLUS"
        cat >> /lib/systemd/system/valheimserver_${worldname}.service <<EOF
ExecStart=${valheimInstallPath}/${worldname}/start_server_bepinex.sh
ExecReload=/bin/kill -s HUP \$MAINPID
KillSignal=SIGINT
WorkingDirectory=${valheimInstallPath}/${worldname}
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF
    fi

    tput setaf 2; echo "Done"; tput setaf 9;
    sleep 1
}

# Create the BepInEx configuration file
function build_start_server_bepinex_configuration_file() {

cat > ${valheimInstallPath}/${worldname}/start_server_bepinex.sh <<'EOF'
#!/bin/sh
# BepInEx running script
#
# This script is used to run a Unity game with BepInEx enabled.
#
# Usage: Configure the script below and simply run this script when you want to run your game modded.

# -------- SETTINGS --------
# ---- EDIT AS NEEDED ------
worldname=$(pwd | cut -d'/' -f5)

# EDIT THIS: The name of the executable to run
# LINUX: This is the name of the Unity game executable [preconfigured]
# MACOS: This is the name of the game app folder, including the .app suffix [must provide if needed]
executable_name="valheim_server.x86_64"


													   

# EDIT THIS: Valheim server parameters
# Can be overriden by script parameters named exactly like the ones for the Valheim executable
# (e.g. ./start_server_bepinex.sh -name "MyValheimPlusServer" -password "somethingsafe" -port 2456 -world "myworld" -public 1)

server_name="$(perl -n -e '/\-name "?([^"]+)"? \-port/ && print "$1\n"' start_valheim_${worldname}.sh)"
server_password="$(perl -n -e '/\-password "?([^"]+)"? \-public/ && print "$1\n"' start_valheim_${worldname}.sh)"
server_port="$(perl -n -e '/\-port "?([^"]+)"? \-nographics/ && print "$1\n"' start_valheim_${worldname}.sh)"
server_world="$(perl -n -e '/\-world "?([^"]+)"? \-password/ && print "$1\n"' start_valheim_${worldname}.sh)"
server_public="$(perl -n -e '/\-public "?([^"]+)"? \-savedir/  && print "$1\n"' start_valheim_${worldname}.sh)"
server_savedir=$(perl -n -e '/\-savedir "?([^"]+)"? \-logfile/ && print "$1\n"' start_valheim_${worldname}.sh)
server_logfiledir=$(perl -n -e '/\-logfile "?([^"]+)"?$/ && print "$1\n"' start_valheim_${worldname}.sh)


# The rest is automatically handled by BepInEx for Valheim+

# Set base path of start_server_bepinex.sh location
export VALHEIM_PLUS_SCRIPT="$(readlink -f "$0")"
export VALHEIM_PLUS_PATH="$(dirname "$VALHEIM_PLUS_SCRIPT")"

# Whether or not to enable Doorstop. Valid values: TRUE or FALSE
export DOORSTOP_ENABLE=TRUE

# What .NET assembly to execute. Valid value is a path to a .NET DLL that mono can execute.
export DOORSTOP_INVOKE_DLL_PATH="${VALHEIM_PLUS_PATH}/BepInEx/core/BepInEx.Preloader.dll"

# Which folder should be put in front of the Unity dll loading path
export DOORSTOP_CORLIB_OVERRIDE_PATH="${VALHEIM_PLUS_PATH}/unstripped_corlib"

# ----- DO NOT EDIT FROM THIS LINE FORWARD  ------
# ----- (unless you know what you're doing) ------

if [ ! -x "$1" -a ! -x "${VALHEIM_PLUS_PATH}/$executable_name" ]; then
	echo "Please open start_server_bepinex.sh in a text editor and provide the correct executable."
	exit 1
fi

doorstop_libs="${VALHEIM_PLUS_PATH}/doorstop_libs"
arch=""
executable_path=""
lib_postfix=""

os_type=$(uname -s)
case $os_type in
	Linux*)
		executable_path="${VALHEIM_PLUS_PATH}/${executable_name}"
		lib_postfix="so"
		;;
	Darwin*)
		executable_name="$(basename "${executable_name}" .app)"
		real_executable_name="$(defaults read "${VALHEIM_PLUS_PATH}/${executable_name}.app/Contents/Info" CFBundleExecutable)"
		executable_path="${VALHEIM_PLUS_PATH}/${executable_name}.app/Contents/MacOS/${real_executable_name}"
		lib_postfix="dylib"
		;;
	*)
		echo "Cannot identify OS (got $(uname -s))!"
		echo "Please create an issue at https://github.com/BepInEx/BepInEx/issues."
		exit 1
		;;
esac

executable_type=$(LD_PRELOAD="" file -b "${executable_path}");

case $executable_type in
	*64-bit*)
		arch="x64"
		;;
	*32-bit*|*i386*)
		arch="x86"
		;;
	*)
		echo "Cannot identify executable type (got ${executable_type})!"
		echo "Please create an issue at https://github.com/BepInEx/BepInEx/issues."
		exit 1
		;;
esac

doorstop_libname=libdoorstop_${arch}.${lib_postfix}
export LD_LIBRARY_PATH="${doorstop_libs}":"${LD_LIBRARY_PATH}"
export LD_PRELOAD="$doorstop_libname":"${LD_PRELOAD}"
export DYLD_LIBRARY_PATH="${doorstop_libs}"
export DYLD_INSERT_LIBRARIES="${doorstop_libs}/$doorstop_libname"

export templdpath="$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="${VALHEIM_PLUS_PATH}/linux64":"${LD_LIBRARY_PATH}"
export SteamAppId=892970

for arg in "$@"
do
	case $arg in
	-name)
	server_name=$2
	shift 2
	;;
	-password)
	server_password=$2
	shift 2
	;;
	-port)
	server_port=$2
	shift 2
	;;
	-world)
	server_world=$2
	shift 2
	;;
	-public)
	server_public=$2
	shift 2
	;;
	-savedir)
	server_savedir=$2
	shift 2
	;;
	esac
done

"${VALHEIM_PLUS_PATH}/${executable_name}" -name "${server_name}" -password "${server_password}" -port "${server_port}" -world "${server_world}" -public "${server_public}" -savedir "${server_savedir}" -logfile "${server_logfiledir}" -logappend -logflush

export LD_LIBRARY_PATH=$templdpath
EOF
}

# Check ValheimPlus Github Latest for menu display
function check_valheim_plus_repo() {
    latestValPlus=$(curl --connect-timeout 10 -s https://api.github.com/repos/Grantapher/ValheimPlus/releases/latest | grep -oP '"tag_name": "\K[^"]+')
    echo "$latestValPlus"
}

# Check Local ValheimPlus Build for menu display
function check_local_valheim_plus_build() {
    if [[ -e "$valheimPlusVersionFile" ]]; then
        localValheimPlusBuild=$(cat "$valheimPlusVersionFile")
        echo $localValheimPlusBuild
    else 
        echo "$NO_DATA"
    fi
}

# ValheimPlus menu
function mods_menu(){
    echo ""
    menu_header_vplus_enable
    echo -ne "
$(ColorCyan '--------------'"$FUNCTION_VALHEIM_PLUS_MENU_HEADER"'--------------')
$(ColorCyan '-')$(ColorGreen ' 1)') $FUNCTION_VALHEIM_PLUS_MENU_INSTALL
$(ColorCyan '---------------'"$FUNCTION_VALHEIM_PLUS_MENU_ADMIN_HEADER"'--------------')
$(ColorCyan '-')$(ColorGreen ' 2)') $FUNCTION_VALHEIM_PLUS_MENU_ENABLE
$(ColorCyan '-')$(ColorGreen ' 3)') $FUNCTION_VALHEIM_PLUS_MENU_DISABLE
$(ColorCyan '-')$(ColorGreen ' 4)') $FUNCTION_VALHEIM_PLUS_MENU_START
$(ColorCyan '-')$(ColorGreen ' 5)') $FUNCTION_VALHEIM_PLUS_MENU_STOP
$(ColorCyan '-')$(ColorGreen ' 6)') $FUNCTION_VALHEIM_PLUS_MENU_RESTART
$(ColorCyan '-')$(ColorGreen ' 7)') $FUNCTION_VALHEIM_PLUS_MENU_STATUS
$(ColorCyan '-')$(ColorGreen ' 8)') $FUNCTION_VALHEIM_PLUS_MENU_UPDATE
$(ColorCyan '------'"$FUNCTION_VALHEIM_PLUS_MENU_MOD_PLUGIN_HEADER"'------')
$(ColorCyan ''"$FUNCTION_VALHEIM_PLUS_MENU_MOD_INFO"'')
$(ColorCyan ''"$FUNCTION_VALHEIM_PLUS_MENU_MOD_INFO_1"'')
$(ColorCyan ''"$FUNCTION_VALHEIM_PLUS_MENU_MOD_INFO_2"'')
$(ColorCyan ''"$FUNCTION_VALHEIM_PLUS_MENU_MOD_INFO_3"'')
$(ColorCyan ''"$FUNCTION_VALHEIM_PLUS_MENU_MOD_INFO_4"'')
$(ColorCyan '-')$(ColorGreen ' 9)') $FUNCTION_VALHEIM_PLUS_MENU_VPLUS_CONFIG_EDIT
$(ColorCyan '-')$(ColorGreen ' 10)') $FUNCTION_VALHEIM_PLUS_MENU_BEPINEX_CONFIG_EDIT
$(ColorCyan '------------------------------------------------')
$(ColorCyan '-')$(ColorGreen ' 0)') $FUNCTION_VALHEIM_PLUS_MENU_RETURN_MAIN
$(ColorPurple ''"$CHOOSE_MENU_OPTION"'')"
    read a
    case $a in
        1) install_valheim_plus ; mods_menu ;;
        2) valheim_plus_enable ; mods_menu ;;
        3) valheim_plus_disable ; mods_menu ;;
        4) start_valheim_server ; mods_menu ;;
        5) stop_valheim_server ; mods_menu ;;
        6) restart_valheim_server ; mods_menu ;;
        7) display_valheim_server_status ; mods_menu ;;
        8) valheim_plus_update ; mods_menu ;;
        9) valheimplus_mod_options ; mods_menu ;;
        10) bepinex_mod_options ; mods_menu ;;
        0) menu ; menu ;;
        *) echo -ne " $(ColorRed ''"$WRONG_MENU_OPTION"'')" ; mods_menu ;;
    esac
}