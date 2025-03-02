#!/bin/bash
###############################################################################################
###############################################################################################
####
#### File name: bepinex.sh
####
###############################################################################################
#### BepInEx mod functionality for Valheim server
#### Handles installation, configuration and management of the BepInEx mod framework
###############################################################################################

# Set BepInEx specific variables
bepinexConfigPath="${valheimInstallPath}/${worldname}/BepInEx/config"
bepinexVersionFile="${valheimInstallPath}/${worldname}/localValheimBepinexVersion"

########################################################################
################## BepInEx Installation Functions ######################
########################################################################

# Install BepInEx
function install_valheim_bepinex() {
    clear
    echo ""

    # Check and install unzip if not already installed
    if command -v apt >/dev/null 2>&1; then
        if [ ! -f /usr/bin/unzip ]; then
            apt install unzip -y
        fi
    elif command -v yum >/dev/null 2>&1; then
        if [ ! -f /usr/bin/unzip ]; then
            yum install unzip -y
        fi
    else
        echo "Neither apt nor yum found. Please install unzip manually."
        return 1
    fi

    tput setaf 2; echo "$FUNCTION_BEPINEX_INSTALL_CHANGING_DIR"; tput setaf 9;
    cd /opt
    mkdir -p bepinexdl
    cd bepinexdl

    tput setaf 2; echo "$FUNCTION_BEPINEX_INSTALL_CHECKING_OLD_INSTALL"; tput setaf 9;

    tput setaf 2; echo "$FUNCTION_BEPINEX_INSTALL_DOWNLOADING_BEPINEX_FROM_REPO"; tput setaf 9;
    officialBepInEx=$(curl -sL https://thunderstore.io/package/download/denikson/BepInExPack_Valheim/5.4.2202/ | grep og:title | cut -d'"' -f 4 | cut -d' ' -f 3 | cut -d'v' -f2)
    wget -O bepinex.zip "https://thunderstore.io/package/download/denikson/BepInExPack_Valheim/5.4.2202/"

    unzip -o bepinex.zip
    cp -a BepInExPack_Valheim/. "${valheimInstallPath}/${worldname}"

    tput setaf 2; echo "$FUNCTION_BEPINEX_INSTALL_CREATING_VER_STAMP"; tput setaf 9;
    grep '"version"' manifest.json | cut -d'"' -f4 > "$bepinexVersionFile"
    rm -rf bepinexdl
    echo ""
    sleep 1

    tput setaf 2; echo "$FUNCTION_BEPINEX_INSTALL_UNPACKING_FILES"; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_BEPINEX_INSTALL_REMOVING_OLD_BEPINEX_CONFIG"; tput setaf 9;
    cd "${valheimInstallPath}/${worldname}"
    [ -e start_valw_bepinex.sh ] && rm start_valw_bepinex.sh

    tput setaf 2; echo "$FUNCTION_BEPINEX_INSTALL_BUILDING_NEW_BEPINEX_CONFIG"; tput setaf 9;
    build_valw_bepinex_configuration_file

    tput setaf 2; echo "$FUNCTION_BEPINEX_INSTALL_SETTING_STEAM_OWNERSHIP"; tput setaf 9;
    chown -R steam:steam /home/steam/*
    chmod +x start_valw_bepinex.sh
    echo ""

    tput setaf 2; echo "$FUNCTION_BEPINEX_INSTALL_GET_THEIR_VIKING_ON"; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_BEPINEX_INSTALL_LETS_GO"; tput setaf 9;
}

# Enable BepInEx
function valheim_bepinex_enable() {
    clear
    echo ""
    tput setaf 2; echo "$FUNCTION_BEPINEX_ENABLE" ; tput setaf 9; 
    valheimVanilla=2
    set_valheim_server_vanillaOrBepinex_operations
    sleep 1
    systemctl daemon-reload
    sleep 1
    echo "$FUNCTION_BEPINEX_RESTARTING"
    systemctl restart valheimserver_${worldname}.service
    sleep 1
    tput setaf 2; echo "$FUNCTION_BEPINEX_ENABLED_ACTIVE" ; tput setaf 9; 
    echo ""
}

# Disable BepInEx
function valheim_bepinex_disable() {
    clear
    echo ""
    tput setaf 2; echo "$FUNCTION_BEPINEX_DISABLE" ; tput setaf 9; 
    valheimVanilla=1
    set_valheim_server_vanillaOrBepinex_operations
    sleep 1
    systemctl daemon-reload
    sleep 1
    echo "$FUNCTION_BEPINEX_DISABLE_RESTARTING"
    systemctl restart valheimserver_${worldname}.service
    sleep 1    
    tput setaf 2; echo "$FUNCTION_BEPINEX_DISABLE_INFO" ; tput setaf 9; 
    echo ""
}

# Update BepInEx
function valheim_bepinex_update() {
    clear
    tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_INFO" ; tput setaf 9; 
    officialBepInEx=$(curl -sL https://valheim.thunderstore.io/package/denikson/BepInExPack_Valheim/ | grep og:title | cut -d'"' -f 4 | cut -d' ' -f 3 | cut -d'v' -f2) 
    localBepInEx=$(cat "$bepinexVersionFile")    
    echo $officialBepInEx
    echo $localBepInEx
    if [[ $officialBepInEx == $localBepInEx ]]; then
        tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_NO_UPDATE_FOUND" ; tput setaf 9; 
    else
        tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_UPDATE_FOUND" ; tput setaf 9; 
        tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_CONTINUE" ; tput setaf 9; 
        read -p "$PLEASE_CONFIRM" confirmValBepinexUpdate
        if [ "$confirmValBepinexUpdate" == "y" ]; then
            tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_BACKING_UP_BEPINEX_CONFIG" ; tput setaf 9; 
            dldir=$backupPath
            [ ! -d "$dldir" ] && mkdir -p "$dldir"
            sleep 1
            TODAYMK="$(date +%Y-%m-%d-%T)"
            cp ${bepinexConfigPath}/BepInEx.cfg ${backupPath}/BepInEx.cfg-$TODAYMK.cfg
            tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_DOWNLOADING_BEPINEX" ; tput setaf 9; 
            install_valheim_bepinex
            sleep 2
            tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_RESTARTING_SERVICES" ; tput setaf 9; 
            restart_valheim_server
        else
            echo "$FUNCTION_BEPINEX_UPDATE_CANCELED" ; tput setaf 9; 
            sleep 2
        fi
    fi
}

# Edit BepInEx config options
function bepinex_mod_options() {
    clear
    nano ${bepinexConfigPath}/BepInEx.cfg
    echo ""
    tput setaf 2; echo "$DRAW80" ; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_BEPINEX_EDIT_CONFIG_SAVE_RESTART" ; tput setaf 9; 
    tput setaf 2; echo "$FUNCTION_BEPINEX_EDIT_CONFIG_SAVE_RESTART_1" ; tput setaf 9; 
    tput setaf 2; echo "$DRAW80" ; tput setaf 9;
    echo ""
    read -p "$PLEASE_CONFIRM" confirmRestart
    #if y, then continue, else cancel
    if [ "$confirmRestart" == "y" ]; then
        echo ""
        echo "$FUNCTION_BEPINEX_EDIT_RESTART_SERVICES"
        sudo systemctl restart valheimserver_${worldname}.service
        echo ""
    else
        echo "$FUNCTION_BEPINEX_EDIT_CANCEL"
        sleep 2
        clear
    fi
}

########################################################################
###################### Configuration Functions #########################
########################################################################

# Set up systemd service for BepInEx
function set_valheim_server_vanillaOrBepinex_operations() {
    # Build systemctl configurations for execution of processes for Valheim Server
    tput setaf 1; echo "$FUNCTION_BEPINEX_BUILD_CONFIG_INFO"; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_BEPINEX_BUILD_CONFIG_INFO_1"; tput setaf 9;

    # Remove old Valheim Server Service
    [ -e /etc/systemd/system/valheimserver_${worldname}.service ] && rm /etc/systemd/system/valheimserver_${worldname}.service

    # Remove past Valheim Server Service
    [ -e /lib/systemd/system/valheimserver_${worldname}.service ] && rm /lib/systemd/system/valheimserver_${worldname}.service

    sleep 1

    # Add new Valheim Server Service for BEPINEX
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
        echo "$FUNCTION_BEPINEX_BUILD_CONFIG_SET_VANILLA"
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
        echo "$FUNCTION_BEPINEX_BUILD_CONFIG_SET"
        cat >> /lib/systemd/system/valheimserver_${worldname}.service <<EOF
ExecStart=${valheimInstallPath}/${worldname}/start_valw_bepinex.sh
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
function build_valw_bepinex_configuration_file() {
  cat > ${valheimInstallPath}/${worldname}/start_valw_bepinex.sh <<'EOF'
#!/bin/sh
# BepInEx running script
#
# This script is used to run a Unity game with BepInEx enabled.
#
# Usage: Configure the script below and simply run this script when you want to run your game modded.

# -------- SETTINGS --------
# ---- EDIT AS NEEDED ------

# EDIT THIS: The name of the executable to run
# LINUX: This is the name of the Unity game executable
# MACOS: This is the name of the game app folder, including the .app suffix
export VALHEIM_BEP_SCRIPT="$(readlink -f "$0")"
export VALHEIM_BEP_PATH="$(dirname "$VALHEIM_BEP_SCRIPT")"
worldname=$(pwd | cut -d'/' -f5)

#importing server parms to BepInEx
server_name="$(perl -n -e '/\-name "?([^"]+)"? \-port/ && print "$1\n"' start_valheim_${worldname}.sh)"
server_password="$(perl -n -e '/\-password "?([^"]+)"? \-public/ && print "$1\n"' start_valheim_${worldname}.sh)"
server_port="$(perl -n -e '/\-port "?([^"]+)"? \-nographics/ && print "$1\n"' start_valheim_${worldname}.sh)"
server_world="$(perl -n -e '/\-world "?([^"]+)"? \-password/ && print "$1\n"' start_valheim_${worldname}.sh)"
server_public="$(perl -n -e '/\-public "?([^"]+)"? \-savedir/  && print "$1\n"' start_valheim_${worldname}.sh)"
server_savedir=$(perl -n -e '/\-savedir "?([^"]+)"? \-logfile/ && print "$1\n"' start_valheim_${worldname}.sh)
server_logfiledir=$(perl -n -e '/\-logfile "?([^"]+)"?$/ && print "$1\n"' start_valheim_${worldname}.sh)

# The rest is automatically handled by BepInEx

# Whether or not to enable Doorstop. Valid values: TRUE or FALSE

#!/bin/sh
# BepInEx-specific settings
# NOTE: Do not edit unless you know what you are doing!
####
export DOORSTOP_ENABLE=TRUE
export DOORSTOP_INVOKE_DLL_PATH=./BepInEx/core/BepInEx.Preloader.dll
export DOORSTOP_CORLIB_OVERRIDE_PATH=./unstripped_corlib

export LD_LIBRARY_PATH="./doorstop_libs:$LD_LIBRARY_PATH"
export LD_PRELOAD="libdoorstop_x64.so:$LD_PRELOAD"
####


export LD_LIBRARY_PATH="./linux64:$LD_LIBRARY_PATH"
export SteamAppId=892970

echo "Starting server PRESS CTRL-C to exit"

# Tip: Make a local copy of this script to avoid it being overwritten by steam.
# NOTE: Minimum password length is 5 characters & Password cant be in the server name.
# NOTE: You need to make sure the ports 2456-2458 is being forwarded to your server through your local router & firewall.
exec "${VALHEIM_BEP_PATH}/valheim_server.x86_64" -name "${server_name}" -password "${server_password}" -port "${server_port}" -world "${server_world}" -public "${server_public}" -savedir "${server_savedir}" -logfile "${server_logfiledir}"
EOF
}

# Check BepInEx Github Latest for menu display
function check_bepinex_repo() {
    latestBepinex=$(curl -s https://valheim.thunderstore.io/package/denikson/BepInExPack_Valheim/ | grep og:title | cut -d'"' -f 4 | cut -d' ' -f 3 | cut -d'v' -f2)
    echo $latestBepinex
}

# Check Local BepInEx Build for menu display
function check_local_bepinex_build() {
    if [[ -e "$bepinexVersionFile" ]]; then
        localValheimBepinexBuild=$(cat "$bepinexVersionFile")
        echo $localValheimBepinexBuild
    else 
        echo "$NO_DATA"
    fi
}

# BepInEx menu
function bepinex_menu(){
    echo ""
    menu_header_bepinex_enable
    echo -ne "
$(ColorCyan '--------------'"$FUNCTION_BEPINEX_MENU_HEADER"'--------------')
$(ColorCyan '-')$(ColorGreen ' 1)') $FUNCTION_BEPINEX_MENU_INSTALL
$(ColorCyan '---------------'"$FUNCTION_BEPINEX_MENU_ADMIN_HEADER"'--------------')
$(ColorCyan '-')$(ColorGreen ' 2)') $FUNCTION_BEPINEX_MENU_ENABLE
$(ColorCyan '-')$(ColorGreen ' 3)') $FUNCTION_BEPINEX_MENU_DISABLE
$(ColorCyan '-')$(ColorGreen ' 4)') $FUNCTION_BEPINEX_MENU_START
$(ColorCyan '-')$(ColorGreen ' 5)') $FUNCTION_BEPINEX_MENU_STOP
$(ColorCyan '-')$(ColorGreen ' 6)') $FUNCTION_BEPINEX_MENU_RESTART
$(ColorCyan '-')$(ColorGreen ' 7)') $FUNCTION_BEPINEX_MENU_STATUS
$(ColorCyan '-')$(ColorGreen ' 8)') $FUNCTION_BEPINEX_MENU_UPDATE
$(ColorCyan '------'"$FUNCTION_BEPINEX_MENU_MOD_PLUGIN_HEADER"'------')
$(ColorCyan ''"$FUNCTION_BEPINEX_MENU_MOD_INFO"'')
$(ColorCyan ''"$FUNCTION_BEPINEX_MENU_MOD_INFO_1"'')
$(ColorCyan ''"$FUNCTION_BEPINEX_MENU_MOD_INFO_2"'')
$(ColorCyan ''"$FUNCTION_BEPINEX_MENU_MOD_INFO_3"'')
$(ColorCyan ''"$FUNCTION_BEPINEX_MENU_MOD_INFO_4"'')
$(ColorCyan '-')$(ColorGreen ' 9)') $FUNCTION_BEPINEX_MENU_BEPINEX_CONFIG_EDIT
$(ColorCyan '------------------------------------------------')
$(ColorCyan '-')$(ColorGreen ' 0)') $FUNCTION_BEPINEX_MENU_RETURN_MAIN
$(ColorPurple ''"$CHOOSE_MENU_OPTION"'')"
    read a
    case $a in
        1) install_valheim_bepinex ; bepinex_menu ;;
        2) valheim_bepinex_enable ; bepinex_menu ;;
        3) valheim_bepinex_disable ; bepinex_menu ;;
        4) start_valheim_server ; bepinex_menu ;;
        5) stop_valheim_server ; bepinex_menu ;;
        6) restart_valheim_server ; bepinex_menu ;;
        7) display_valheim_server_status ; bepinex_menu ;;
        8) valheim_bepinex_update ; bepinex_menu ;;
        9) bepinex_mod_options ; bepinex_menu ;;
        0) menu ; menu ;;
        *) echo -ne " $(ColorRed ''"$WRONG_MENU_OPTION"'')" ; mods_menu ;;
    esac
}