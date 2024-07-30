#!/bin/bash
###############################################################################################
###############################################################################################
####
#### From: Zerobandwidth
####
#### Thank you for using the menu script, this started out as just me and blew up quickly.
#### If Frankenstein was a bash script, this is what you would get, so please help me improve it.
#### Feel free to use and change this as you wish just not for profit. 
#### If you need anything, please visit our Discord Server: https://discord.gg/ejgQUfc
#### *** GLHF - V/r, Zerobandwidth and Team
####
###############################################################################################
####
#### File name: ldadvmenu.sh
####
###############################################################################################
####
#### Modifier: Lord/Ranger(Dumoss)
#### Forked from: Njord advancemenu.ld (beta) Updated: 29-APR-2021
####
#### I would like to thank "Dr." Zerobandwidth "Frankenstein"
#### and the development team of "Igor's" for putting 
#### this wonderfull "monster" script together. :)
####
#### The main focus of this was to add Linux support for 
#### Fedora-Cento-RHEL-OEL-yum/dnf based systems.
#### 
#### To allow control multiple Valheim servers running on a single node
#### based on WORLDNAME and is installed under "${worldpath}/${worldname}"
####
#### TO have some simple firewall security control related to these systems. - (WIP)
####
#### *** - Dumoss
####
###############################################################################################
###############################################################################################
#### Current Options: DE=German, EN=English, FR=French, SP=Spanish"
###############################################################################################
###############################################################################################
# All linux systems should have this 
# If not .. <> install os-release
source /etc/os-release


if [ "$1" == "" ] 
then 
	LANGUAGE=EN
else 
	LANGUAGE=$1
fi 
source lang/$LANGUAGE.conf
#############################################################
########################  Santiy Check  #####################
#############################################################
echo "$(tput setaf 4)"$DRAW60""
echo "$(tput setaf 0)$(tput setab 7)"$CHECKSUDO"$(tput sgr 0)"
echo "$(tput setaf 0)$(tput setab 7)"$CHECKSUDO1"$(tput sgr 0)"    
echo "$(tput setaf 4)"$DRAW60""
#    ###################################################### 
[[ "$EUID" -eq 0 ]] || exec sudo "$0" "$@"
clear
###############################################################
################### Default Variables #########################
###############################################################
### NOTE: Only change this if you know what you are doing   ###    
###############################################################
###############################################################
### Valheim Server Install location(Default) 
valheimInstallPath=/home/steam/valheimserver
### Valheim World Data Path(Default)
worldpath=/home/steam/.config/unity3d/IronGate/Valheim
### Keeps a list of created Valheim Worlds
worldfilelist=/home/steam/worlds.txt
### Backup Directory ( Default )
backupPath=/home/steam/backups
###
###  Configs for Advance Users ###
### This option is only for the steamcmd install where it 
### is not included in the "steam" client install ... ie RH/OEL-yum
### Set this to delete all files from the /home/steam/steamcmd directory to install steamcmd fresh.
### Defaults are "n" on the below parameters.
### <n : no>
### <y : yes>
freshinstall="n"
### **** Firewall setup ***
### Do you use a firewall?
usefw="n" 
### what firewall do you want to use? 
#Change the following value to one listed in the fwsystems list below or use 'none'.
fwbeingused="firewalld"
# Do not changed this only add to it.
fwsystems=( arptables ebtables firewalld iptables ip6tables ufw )
###############################################################
debugmsg="n"
# if [ "$debugmsg" == "y" ] ; then echo "something" ; fi
###############################################################
# Set Menu Version for menu display
mversion="4.0-Thor"
ldversion="0.4.051120211500ET.dev"
###      -- Use are your own risk -- 
### dev   -- Still working on firewall code. 
###       -- Currently adding ufw commands. 
###       -- And then finish the firewall menu (make pro).
### alpha -- Dev team review.
### beta  -- Public Testing.
###
### Please note that this is a play ground file for me and 
### allows Zerobandwidth do determine what to pull into the main advance(menu).sh file.
### 
### I have done a lot ( and still ) testing of this new code 
### and it seams to be working as original intended, but
### now for OEL/REL/Fedora and centos tested.
###
### If you are using the above server versions of Linux and the added repos cause issues,
### I have provided the 3 most causes and fixes in the function ***linux_server_update*** text.
###
### I am still in design mode for the firewall stuff.
### Current it works 99% for FireWallD only at this time.
###
### Other Linux flavors and firewall systems to be added.
########################################################################
#############################Set COLOR VARS#############################
########################################################################
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
clear='\e[0m'
##
# Color Functions
##
ColorRed(){ 
        echo -ne $RED$1$clear 
}
ColorGreen(){
         echo -ne $GREEN$1$clear
}
ColorOrange(){
	echo -ne $ORANGE$1$clear
}
ColorBlue(){
	echo -ne $BLUE$1$clear
}
ColorPurple(){
	echo -ne $PURPLE$1$clear
}
ColorCyan(){
	echo -ne $CYAN$1$clear
}
ColorLightRed(){
	echo -ne $LIGHTRED$1$clear
}
ColorLightGreen(){
	echo -ne $LIGHTGREEN$1$clear
}
ColorYellow(){
	echo -ne $LIGHTYELLOW$1$clear
}
ColorWhite(){
	echo -ne $WHITE$1$clear
}
########################################################################
#####################Check for Menu Updates#############################
########################################################################
MENUSCRIPT="$(readlink -f "$0")"
SCRIPTFILE="$(basename "$MENUSCRIPT")"            
SCRIPTPATH="$(dirname "$SCRIPT")"
SCRIPTNAME="$0"
ARGS=( "$@" )  
BRANCH=$(git rev-parse --abbrev-ref HEAD)
UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{upstream})

function script_check_update() {
    # Look for updates from repo tag
    echo "1"

    git fetch

    # Check if there are updates available
    if [ -n "$(git diff --name-only "$UPSTREAM" "$SCRIPTFILE")" ]; then
        echo "$GIT_ECHO_CHECK"
        sleep 1
        git pull --force
        git stash
        git checkout "$BRANCH"
        git pull --force
        echo "$GIT_ECHO_UPDATING"
        sleep 1
        chmod +x *menu.sh
        sleep 1
        # Restart the script with the same arguments
        exec "$SCRIPTNAME" "${ARGS[@]}"
        # Exit the old instance
        exit 1
    else
        echo "$GIT_ECHO_NO_UPDATES"
    fi
}


########################################################################
##############MAIN VALHEIM SERVER ADMIN FUNCTIONS START#################
########################################################################

########################################################################
#####################Install Valheim Server START#######################
########################################################################
function valheim_server_steam_account_creation() {
    # Create steam account
    echo "$START_INSTALL_1_PARA"

    while true; do
        tput setaf 2; echo "$DRAW60" ; tput setaf 9;
        tput setaf 2; echo "$STEAM_NON_ROOT_STEAM_PASSWORD" ; tput setaf 9;
        tput setaf 2; echo "$DRAW60" ; tput setaf 9;
        tput setaf 1; echo "$STEAM_PASS_MUST_BE" ; tput setaf 9;
        tput setaf 1; echo "$STEAM_PASS_MUST_BE_1" ; tput setaf 9;
        tput setaf 2; echo "$DRAW60" ; tput setaf 9;
        tput setaf 2; echo "$STEAM_GOOD_EXAMPLE" ; tput setaf 9;
        tput setaf 1; echo "$STEAM_BAD_EXAMPLE" ; tput setaf 9;
        tput setaf 2; echo "$DRAW60" ; tput setaf 9;
        echo ""

        read -p "$STEAM_PLEASE_ENTER_STEAM_PASSWORD" userpassword

        tput setaf 2; echo "$DRAW60" ; tput setaf 9;
        
        if [[ ${#userpassword} -ge 6 && "$userpassword" == *[[:lower:]]* && "$userpassword" == *[[:upper:]]* && "$userpassword" =~ ^[[:alnum:]]+$ ]]; then
            break
        else
            tput setaf 2; echo "$STEAM_PASS_NOT_ACCEPTED" ; tput setaf 9;
            tput setaf 2; echo "$STEAM_PASS_NOT_ACCEPTED_1" ; tput setaf 9;
        fi
    done

    echo ""

    # Set the environment and bash profile information for steam user
    tput setaf 1; echo "$INSTALL_BUILD_NON_ROOT_STEAM_ACCOUNT" ; tput setaf 9;
    sleep 1

    if command -v apt-get >/dev/null; then
        useradd --create-home --shell /bin/bash --password "$userpassword" steam
        cp /etc/skel/.bashrc /home/steam/.bashrc
        cp /etc/skel/.profile /home/steam/.profile
    elif command -v yum >/dev/null; then
        useradd -mU -s /bin/bash -p "$userpassword" steam
        # All files from /etc/skel/ are auto copied on RH.
    else
        echo "Package manager not recognized."
    fi

    tput setaf 2; echo "$ECHO_DONE" ; tput setaf 9;
}


function valheim_server_public_server_display_name() {
    echo ""
    
    # Display instructions for Valheim Server Public Display Name
    for msg in "$DRAW60" "$PUBLIC_SERVER_DISPLAY_NAME" "$DRAW60" "$PUBLIC_SERVER_DISPLAY_NAME_1" \
               "$PUBLIC_SERVER_DISPLAY_NAME_2" "$DRAW60" "$PUBLIC_SERVER_DISPLAY_GOOD_EXAMPLE" \
               "$PUBLIC_SERVER_DISPLAY_GOOD_EXAMPLE_1" "$PUBLIC_SERVER_DISPLAY_BAD_EXAMPLE" "$DRAW60"; do
        tput setaf 2; echo "$msg"; tput setaf 9;
    done

    echo ""

    # Prompt user for Valheim Server Public Display Name
    read -p "$PUBLIC_SERVER_ENTER_NAME" displayname

    tput setaf 2; echo "------------------------------------------------------------"; tput setaf 9;
    echo ""
}

function valheim_server_local_world_name() {
    # Set world name function that will be used for .db and .fwl files
    echo ""

    while true; do
        # Display instructions for setting the world name
        for msg in "$DRAW60" "$WORLD_SET_WORLD_NAME_HEADER" "$DRAW60" "$WORLD_SET_CHAR_RULES" \
                   "$WORLD_SET_NO_SPECIAL_CHAR_RULES" "$DRAW60" "$WORLD_GOOD_EXAMPLE" \
                   "$WORLD_BAD_EXAMPLE" "$DRAW60"; do
            tput setaf 2; echo "$msg"; tput setaf 9;
        done

        echo ""
        read -p "$WORLD_SET_WORLD_NAME_VAR" worldname
        tput setaf 2; echo "------------------------------------------------------------"; tput setaf 9;

        # Validate the world name
        if [[ ${#worldname} -ge 4 && "$worldname" =~ ^[[:alnum:]]+$ ]]; then
            break
        else
            tput setaf 2; echo "$WORLD_SET_ERROR"; tput setaf 9;
            tput setaf 2; echo "$WORLD_SET_ERROR_1"; tput setaf 9;
        fi
    done

    clear
    echo ""
}


function valheim_server_public_valheim_port() {
    # Take user input for Valheim Server port and display instructions
    echo ""

    for msg in "$DRAW60" "$FUNCTION_VALHEIM_SERVER_INSTALL_LD_SETPORTNEW_HEADER" "$DRAW60" \
               "$FUNCTION_VALHEIM_SERVER_INSTALL_LD_SETPORTNEW_INFO1" "$FUNCTION_VALHEIM_SERVER_INSTALL_LD_SETPORTNEW_INFO2" \
               "$DRAW60" "$FUNCTION_VALHEIM_SERVER_INSTALL_LD_SETPORTNEW_INFO3" "$FUNCTION_VALHEIM_SERVER_INSTALL_LD_SETPORTNEW_INFO4" \
               "$FUNCTION_VALHEIM_SERVER_INSTALL_LD_SETPORTNEW_INFO5" "$DRAW60"; do
        tput setaf 2; echo "$msg"; tput setaf 9;
    done

    echo ""

    while true; do
        read -p "$FUNCTION_VALHEIM_SERVER_INSTALL_LD_SETPORTNEW_ENTER" portnumber
        # Validate port number
        if [[ ${#portnumber} -ge 4 && ${#portnumber} -le 6 ]] && [[ $portnumber -gt 1024 && $portnumber -le 65530 ]] && [[ "$portnumber" =~ ^[[:alnum:]]+$ ]]; then
            break
        fi
    done

    tput setaf 2; echo "------------------------------------------------------------"; tput setaf 9;
    clear
    echo ""
}


function valheim_server_public_listing() {
    # Set public listing: 1 = Display Server, 0 = LAN or do not display server public
    echo ""

    for msg in "$DRAW60" "$PUBLIC_ENABLED_DISABLE_HEADER" "$DRAW60" "$PUBLIC_ENABLED_DISABLE_INFO" \
               "$DRAW60" "$PUBLIC_ENABLED_DISABLE_EXAMPLE_SHOW" "$PUBLIC_ENABLED_DISABLE_EXAMPLE_LAN_NO_SHOW" "$DRAW60"; do
        tput setaf 2; echo "$msg"; tput setaf 9;
    done

    echo ""
    read -p "$PUBLIC_ENABLED_DISABLE_INPUT" publicList

    tput setaf 2; echo "------------------------------------------------------------"; tput setaf 9;
    echo ""

    # Display credentials
    echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_HEADER"
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    tput setaf 2; echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_STEAM_PASSWORD $userpassword"; tput setaf 9;
    tput setaf 2; echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_SERVER_NAME $displayname"; tput setaf 9;
    tput setaf 2; echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_WORLD_NAME $worldname"; tput setaf 9;
    tput setaf 2; echo "Port number being used: $portnumber"; tput setaf 9;
    tput setaf 2; echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_ACCESS_PASS $password"; tput setaf 9;
    tput setaf 2; echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_SHOW_PUBLIC $publicList"; tput setaf 9;
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    echo ""
}



function valheim_server_public_access_password() {
    # Added security for password complexity
    echo ""

    for msg in "$DRAW60" "$SERVER_ACCESS_PASS_HEADER" "$DRAW60" "$SERVER_ACCESS_INFO" \
               "$DRAW60" "$SERVER_ACCESS_PUBLIC_NAME_INFO $displayname" "$SERVER_ACCESS_WORLD_NAME_INFO $worldname" "$DRAW60"; do
        tput setaf 2; echo "$msg"; tput setaf 9;
    done

    while true; do
        for msg in "$SERVER_ACCESS_WARN_INFO" "$SERVER_ACCESS_WARN_INFO_1" "$DRAW60" \
                   "$SERVER_ACCESS_GOOD_EXAMPLE" "$SERVER_ACCESS_BAD_EXAMPLE" "$DRAW60"; do
            tput setaf 1; echo "$msg"; tput setaf 9;
        done

        read -p "$SERVER_ACCESS_ENTER_PASSWORD" password
        tput setaf 2; echo "------------------------------------------------------------"; tput setaf 9;

        # Validate password complexity
        if [[ ${#password} -ge 5 && "$password" == *[[:lower:]]* && "$password" == *[[:upper:]]* && "$password" =~ ^[[:alnum:]]+$ ]]; then
            break
        else
            tput setaf 2; echo "$SERVER_ACCESS_PASSWORD_ERROR"; tput setaf 9;
            tput setaf 2; echo "$SERVER_ACCESS_PASSWORD_ERROR_1"; tput setaf 9;
        fi
    done
}

function valheim_server_set_crossplay() {
    echo ""

    for msg in "$DRAW60" "Set up Crossplay" "$DRAW60" \
               "Crossplay allows you to play with friends on other platforms" \
               "Crossplay 1 = Enabled" "Crossplay 0 = Disabled" \
               "$DRAW60" "Do you wish to enable Crossplay?" "$DRAW60"; do
        tput setaf 2; echo "$msg"; tput setaf 9;
    done

    echo ""
    read -p "Enter 1 for Yes or 0 for No: " crossplay
    tput setaf 2; echo "------------------------------------------------------------"; tput setaf 9;
    echo ""
}


function build_configuration_env_files_set_permissions() {
    # Populate Admin/config files
    config_file="/home/steam/serverSetup.txt"
    world_file="/home/steam/worlds.txt"

    {
        echo "$DRAW60"
        echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_STEAM_PASSWORD $userpassword"
        echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_SERVER_NAME $displayname"
        echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_WORLD_NAME $worldname"
        echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_PORT_USED $portnumber"
        echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_ACCESS_PASS $password"
        echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_SHOW_PUBLIC $publicList"
        echo "CrossPlay Option 1 = Enabled - 0 = Disabled $crossplay"
        echo "$DRAW60"
    } >> "$config_file"

    sleep 1

    echo "$worldname" >> "$world_file"

    sleep 1

    chown steam:steam /home/steam/*.txt

    clear
}


function valheim_server_install() {
    clear
    echo ""

    # Initial setup for first-time installation
    if [ "$newinstall" == "y" ]; then
        for msg in "Thank you for using the Njord Menu system." \
                   "This appears to be the first time the menu has" \
                   "been run on this system." \
                   "Installing the first Valheim server started."; do
            tput setaf 2; echo "$msg"; tput setaf 9;
        done
        
        linux_server_update
        valheim_server_steam_account_creation
        valheim_server_public_server_display_name
        valheim_server_local_world_name
        portnumber=2456
        valheim_server_public_listing
        valheim_server_public_access_password
        valheim_server_set_crossplay
        build_configuration_env_files_set_permissions
        Install_steamcmd_client
    else
        # For adding another Valheim install on the same server skipping steam user creation
        valheim_server_public_server_display_name
        valheim_server_local_world_name
        valheim_server_public_valheim_port
        valheim_server_public_listing
        valheim_server_public_access_password
        valheim_server_set_crossplay
        build_configuration_env_files_set_permissions
    fi

    nocheck_valheim_update_install

    tput setaf 1; echo "$INSTALL_BUILD_SET_STEAM_PERM"; tput setaf 9;
    chown steam:steam -Rf /home/steam/*
    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Configure firewall settings if enabled
    if [ "${usefw}" == "y" ]; then
        case "${fwbeingused}" in
            ufw)
                if command -v ufw >/dev/null; then
                    sudo ufw allow ${portnumber}:${portnumber+2}/udp
                    echo "Adding ports to the UFW system."
                fi
                ;;
            iptables)
                if command -v iptables >/dev/null; then
                    # sudo iptables –A INPUT –p udp ––dport ${portnumber},${portnumber}+1,${portnumber}+2) –j ACCEPT
                    # sudo /sbin/iptables-save
                    echo "Configuring iptables."
                fi
                ;;
            firewalld)
                if command -v firewalld >/dev/null; then
                    if [ "$is_firewall_enabled" == "y" ] && [ "$get_firewall_status" == "y" ]; then
                        sftc="val"
                        add_Valheim_server_public_ports
                    fi
                fi
                ;;
            *)
                echo "No firewall configuration detected."
                ;;
        esac
    else
        if [ "${is_firewall_enabled}" == "y" ]; then 
            disable_all_firewalls
        fi
    fi

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Build config for start_valheim.sh
    tput setaf 1; echo "$INSTALL_BUILD_DELETE_OLD_CONFIGS"; tput setaf 9;
    tput setaf 1; echo "$INSTALL_BUILD_DELETE_OLD_CONFIGS_1"; tput setaf 9;
    [ -e ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh ] && rm ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh
    sleep 1

    cat > ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh <<EOF
#!/bin/bash
export templdpath=\$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:\$LD_LIBRARY_PATH
export SteamAppId=892970
./valheim_server.x86_64 -name "${displayname}" -port "${portnumber}" -nographics -batchmode -world "${worldname}" -password "${password}" -public "${publicList}" -savedir "${worldpath}/${worldname}" -logfile "${worldpath}/${worldname}/valheim_server.log" -crossplay "${crossplay}"
export LD_LIBRARY_PATH=\$templdpath
EOF

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Delete old check log script
    tput setaf 1; echo "$INSTALL_BUILD_DELETE_OLD_SCRIPT"; tput setaf 9;
    [ -e /home/steam/check_log.sh ] && rm /home/steam/check_log.sh

    # Set execute permissions
    tput setaf 1; echo "$INSTALL_BUILD_SET_PERM_ON_START_VALHEIM"; tput setaf 9;
    chmod +x ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh
    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Build systemctl configurations for execution of processes for Valheim Server
    tput setaf 1; echo "$INSTALL_BUILD_DEL_OLD_SERVICE_CONFIG"; tput setaf 9;
    tput setaf 1; echo "$INSTALL_BUILD_DEL_OLD_SERVICE_CONFIG_1"; tput setaf 9;

    # Remove old Valheim Server Service
    [ -e /etc/systemd/system/valheimserver_${worldname}.service ] && rm /etc/systemd/system/valheimserver_${worldname}.service
    [ -e /lib/systemd/system/valheimserver_${worldname}.service ] && rm /lib/systemd/system/valheimserver_${worldname}.service
    sleep 1

    # Add new Valheim Server Service
    cat > /lib/systemd/system/valheimserver_${worldname}.service <<EOF
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
ExecStart=${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh
ExecReload=/bin/kill -s HUP \$MAINPID
KillSignal=SIGINT
WorkingDirectory=${valheimInstallPath}/${worldname}
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Chown steam user permissions to all of user steam dir location
    tput setaf 1; echo "$INSTALL_BUILD_SET_STEAM_PERMS"; tput setaf 9;
    chown steam:steam -Rf /home/steam/*
    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Reload daemons
    tput setaf 1; echo "$INSTALL_BUILD_RELOAD_DAEMONS"; tput setaf 9;
    systemctl daemon-reload
    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Start server
    tput setaf 1; echo "$INSTALL_BUILD_START_VALHEIM_SERVICE"; tput setaf 9;
    systemctl start valheimserver_${worldname}.service
    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Enable server on restarts
    tput setaf 1; echo "$INSTALL_BUILD_ENABLE_VALHEIM_SERVICE"; tput setaf 9;
    systemctl enable valheimserver_${worldname}.service
    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 2

    clear
    tput setaf 2; echo "$INSTALL_BUILD_FINISH_THANK_YOU"; tput setaf 9;
    echo ""
    echo ""
}


########################################################################
#####################Install Valheim Server END#########################
########################################################################

########################################################################
############     Linux server update - requirement         #############
########################################################################
# LordDumoss (LD): Add yum support. Might be a better way. But it works. 
# LD: Changed where the steamcmd required libs are installed.
########################################################################
# SUDO?
#########
function linux_server_update() {
    # Check for updates and upgrade the system automatically
    echo "$ID"
    echo "$VERSION"
    echo "${VERSION:0:1}"

    tput setaf 1; echo "$CHECK_FOR_UPDATES"; tput setaf 9;

    # Update system based on package manager
    if command -v apt-get >/dev/null; then
        sudo apt update && sudo apt upgrade -y
    elif command -v pkg >/dev/null; then
        echo "Insert command here."
    elif command -v yum >/dev/null; then
        if [[ "$ID" == "fedora" ]] || [[ "$ID" =~ ^(centos|ol|rhel)$ && "${VERSION:0:1}" == "8" ]]; then
            sudo dnf clean all && sudo dnf update -y && sudo dnf upgrade -y
        elif [[ "$ID" =~ ^(centos|ol|rhel)$ && "${VERSION:0:1}" == "7" ]]; then
            sudo yum clean all && sudo yum update -y && sudo yum upgrade -y
        else
            echo "Unsupported version for yum/dnf."
        fi
    else
        echo "Unsupported package manager."
    fi

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Install additional packages
    tput setaf 1; echo "$INSTALL_ADDITIONAL_FILES"; tput setaf 9;
    if command -v apt-get >/dev/null; then
        sudo apt install -y lib32gcc1 libsdl2-2.0-0 libsdl2-2.0-0:i386 git mlocate net-tools unzip curl isof
    elif command -v yum >/dev/null; then
        if [[ "$ID" == "fedora" ]] || [[ "$ID" =~ ^(centos|ol|rhel)$ && "${VERSION:0:1}" == "8" ]]; then
            sudo dnf install -y glibc.i686 libstdc++.i686 git mlocate net-tools unzip curl isof
        elif [[ "$ID" =~ ^(centos|ol|rhel)$ && "${VERSION:0:1}" == "7" ]]; then
            sudo yum install -y glibc.i686 libstdc++.i686 git mlocate net-tools unzip curl isof
        else
            echo "Unsupported version for yum/dnf."
        fi
    else
        echo "Unsupported package manager."
    fi

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Install software-properties-common for add-apt-repository command
    tput setaf 1; echo "$INSTALL_SPCP"; tput setaf 9;
    if command -v apt-get >/dev/null; then
        sudo apt install -y software-properties-common
    else
        echo "$FUNCTION_LINUX_SERVER_UPDATE_YUM_REQUIRED_NO"
    fi

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Add the MULTIVERSE repo(s) per Linux Flavor
    tput setaf 1; echo "$ADD_MULTIVERSE"; tput setaf 9;
    if command -v apt-get >/dev/null; then
        sudo add-apt-repository -y multiverse
    elif command -v yum >/dev/null; then
        if [[ "$ID" == "fedora" ]] || [[ "$ID" =~ ^(centos|ol|rhel)$ && "${VERSION:0:1}" == "8" ]]; then
            sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
            sudo dnf config-manager --add-repo=http://mirror.centos.org/centos/8/os/x86_64/
            sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                                 https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
            sudo dnf config-manager --add-repo=https://negativo17.org/repos/fedora-negativo17.repo
        elif [[ "$ID" =~ ^(centos|ol|rhel)$ && "${VERSION:0:1}" == "7" ]]; then
            sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
            sudo yum-config-manager --add-repo=http://mirror.centos.org/centos/7/os/x86_64/
            sudo yum localinstall --nogpgcheck -y https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-7.noarch.rpm \
                                             https://mirrors.rpmfusion.org/free/el/rpmfusion-nonfree-release-7.noarch.rpm
            sudo yum-config-manager --add-repo=https://negativo17.org/repos/epel-negativo17.repo
        else
            echo "Unsupported version for yum/dnf."
        fi
    else
        echo "Unsupported package manager."
    fi

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Add i386 architecture
    tput setaf 1; echo "$ADD_I386"; tput setaf 9;
    if command -v apt-get >/dev/null; then
        sudo dpkg --add-architecture i386
    else
        echo "$FUNCTION_LINUX_SERVER_UPDATE_RHL_REQUIRED_NO"
    fi

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Update system again
    tput setaf 1; echo "$CHECK_FOR_UPDATES_AGAIN"; tput setaf 9;
    if command -v apt-get >/dev/null; then
        sudo apt update && sudo apt install -y libpulse-dev libatomic1 libc6
    elif command -v yum >/dev/null; then
        if [[ "$ID" == "fedora" ]] || [[ "$ID" =~ ^(centos|ol|rhel)$ && "${VERSION:0:1}" == "8" ]]; then
            sudo dnf update -y
        elif [[ "$ID" =~ ^(centos|ol|rhel)$ && "${VERSION:0:1}" == "7" ]]; then
            sudo yum update -y
        else
            echo "Unsupported version for yum/dnf."
        fi
    fi

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1
}


########################################################################
################# LD: Install the steamcmd                 #############
########################################################################
function Install_steamcmd_client() {
    # Install steamcmd and related dependencies based on the Linux flavor
    tput setaf 1; echo "$INSTALL_STEAMCMD_LIBSD12"; tput setaf 9;

    if command -v apt-get >/dev/null; then
        echo steam steam/license note '' | sudo debconf-set-selections
        echo steam steam/question select 'I AGREE' | sudo debconf-set-selections
        sudo apt install -y steamcmd libsdl2-2.0-0 libsdl2-2.0-0:i386
        tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    elif command -v yum >/dev/null; then
        if [[ "$ID" == "fedora" ]] || [[ "$ID" =~ ^(centos|ol|rhel)$ && "${VERSION:0:1}" == "8" ]]; then
            sudo dnf -y install steam kernel-modules-extra
        elif [[ "$ID" =~ ^(centos|ol|rhel)$ && "${VERSION:0:1}" == "7" ]]; then
            sudo yum -y install steam
        else
            echo "Unsupported version for yum/dnf."
        fi

        # Download and install steamcmd manually for yum systems
        steamzipfile="/home/steam/steamcmd/steamcmd_linux.tar.gz"
        mkdir -p /home/steam/steamcmd
        cd /home/steam/steamcmd

        [ -e $steamzipfile ] && rm $steamzipfile
        [ "$freshinstall" == "y" ] && rm -rfv /home/steam/steamcmd/*

        wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
        tar xf steamcmd_linux.tar.gz
        tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    else
        echo "Unsupported package manager."
    fi

    # Configure firewall settings for steamcmd
    if [ "${usefw}" == "y" ]; then
        case "${fwbeingused}" in
            ufw)
                if command -v ufw >/dev/null; then
                    sudo ufw allow 1200/udp
                    sudo ufw allow 27020/udp
                    sudo ufw allow 27000-27015/udp
                    sudo ufw allow 27015-27016/both
                    sudo ufw allow 27030-27039/both
                    echo "UFW rules added."
                fi
                ;;
            iptables)
                echo "IPTables configuration not implemented."
                ;;
            firewalld)
                if command -v firewalld >/dev/null; then
                    if [ "$is_firewall_enabled" == "y" ] && [ "$get_firewall_status" == "y" ]; then
                        sftc="ste"
                        add_Valheim_server_public_ports
                    fi
                fi
                ;;
            *)
                echo "Unsupported firewall configuration."
                ;;
        esac
    else
        [ "${is_firewall_enabled}" == "y" ] && disable_all_firewalls
    fi

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1

    # Build symbolic link for steamcmd
    tput setaf 1; echo "$INSTALL_BUILD_SYM_LINK_STEAMCMD"; tput setaf 9;

    if command -v apt-get >/dev/null; then
        ln -s /usr/games/steamcmd /home/steam/steamcmd
    elif command -v yum >/dev/null; then
        ln -s /usr/games/steamcmd /home/steam/steamcmd/linux32/steamcmd
    else
        echo "Unsupported package manager."
    fi

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
    sleep 1
}

########################################################################
##########Backup and Restore World DB and FWL Files START###############
########################################################################

#Backup World DB and FWL Files
function backup_world_data() {
    echo ""
    echo ""

    # Read user input confirmation
    tput setaf 1; echo "$BACKUP_WORLD_DATA_HEADER"; tput setaf 9;
    tput setaf 1; echo "$BACKUP_WORLD_INFO_CONFIRM"; tput setaf 9;
    read -p "$BACKUP_WORLD_INPUT_CONFIRM_Y_N" confirmBackup

    # If 'y', then continue, else cancel
    if [ "$confirmBackup" == "y" ]; then
        # Get the current date as variable
        TODAY=$(date +%Y-%m-%d-%T)

        tput setaf 5; echo "$BACKUP_WORLD_CHECK_DIRECTORY"; tput setaf 9;
        tput setaf 5; echo "$BACKUP_WORLD_CHECK_DIRECTORY_1"; tput setaf 9;
        dldir="$backupPath/$worldname"
        [ ! -d "$dldir" ] && mkdir -p "$dldir"
        sleep 1

        # Clean up files older than 2 weeks and create a new backup
        tput setaf 1; echo "$BACKUP_WORLD_CONDUCT_CLEANING"; tput setaf 9;
        find "$backupPath/$worldname/"* -mtime +14 -type f -delete
        tput setaf 2; echo "$BACKUP_WORLD_CONDUCT_CLEANING_LOKI"; tput setaf 9;
        sleep 1

        # Stop Valheim server
        tput setaf 1; echo "$BACKUP_WORLD_STOPPING_SERVICES"; tput setaf 9;
        systemctl stop valheimserver_${worldname}.service
        tput setaf 1; echo "$BACKUP_WORLD_STOP_INFO"; tput setaf 9;
        tput setaf 2; echo "$BACKUP_WORLD_STOP_INFO_1"; tput setaf 9;
        tput setaf 2; echo "$BACKUP_WORLD_STOP_WAIT_10_SEC"; tput setaf 9;
        sleep 10

        # Create a backup tarball
        tput setaf 1; echo "$BACKUP_WORLD_MAKING_TAR"; tput setaf 9;
        tar czf "$backupPath/$worldname/valheim-backup-$TODAY.tgz" "$worldpath/$worldname/"*
        tput setaf 2; echo "$BACKUP_WORLD_MAKING_TAR_COMPLETE"; tput setaf 9;
        sleep 1

        # Restart Valheim server
        tput setaf 2; echo "$BACKUP_WORLD_RESTARTING_SERVICES"; tput setaf 9;
        systemctl start valheimserver_${worldname}.service
        tput setaf 2; echo "$BACKUP_WORLD_RESTARTING_SERVICES_1"; tput setaf 9;
        echo ""

        # Set permissions for backup files
        tput setaf 2; echo "$BACKUP_WORLD_SET_PERMS_FILES"; tput setaf 9;
        chown -Rf steam:steam "$backupPath/$worldname"
        tput setaf 2; echo "$BACKUP_WORLD_PROCESS_COMPLETE"; tput setaf 9;
        echo ""
    else
        tput setaf 3; echo "$BACKUP_WORLD_PROCESS_CANCELED"; tput setaf 9;
    fi
}


# Restore World Files DB and FWL
# Thanks to GITHUB @LachlanMac and @Kurt
function restore_world_data() {
    # Initialize empty array
    declare -a backups

    # Loop through backups and put in array
    for file in "${backupPath}/${worldname}"/*.tgz; do
        backups+=("$file")
    done

    # Counter index
    bIndex=1
    for item in "${backups[@]}"; do
        # Print option [index]> [file name]
        basefile=$(basename "$item")
        echo "$bIndex> $basefile"
        # Increment
        bIndex=$((bIndex + 1))
    done

    # Prompt user for index
    tput setaf 2; echo "$RESTORE_WORLD_DATA_HEADER"; tput setaf 9;
    tput setaf 2; echo "$RESTORE_WORLD_DATA_CONFIRM"; tput setaf 9;
    read -p "$RESTORE_WORLD_DATA_SELECTION" selectedIndex

    # Show confirmation message
    restorefile=$(basename "${backups[selectedIndex - 1]}")
    echo -ne "
$(ColorRed '------------------------------------------------------------')
$(ColorGreen ' '"$RESTORE_WORLD_DATA_SHOW_FILE"' $restorefile ?')
$(ColorGreen ' '"$RESTORE_WORLD_DATA_ARE_YOU_SURE"' ')
$(ColorOrange ' '"$RESTORE_WORLD_DATA_VALIDATE_DATA_WITH_CONFIG"' ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh')
$(ColorOrange ' '"$RESTORE_WORLD_DATA_INFO"' ')
$(ColorGreen ' '"$RESTORE_WORLD_DATA_CONFIRM_1"' ') "
    
    # Read user input confirmation
    read -p "" confirmBackupRestore

    # If 'y', then continue, else cancel
    if [ "$confirmBackupRestore" == "y" ]; then
        # Stop Valheim server
        tput setaf 1; echo "$RESTORE_WORLD_DATA_STOP_VALHEIM_SERVICE"; tput setaf 9;
        systemctl stop valheimserver_${worldname}.service
        tput setaf 2; echo "$RESTORE_WORLD_DATA_STOP_VALHEIM_SERVICE_1"; tput setaf 9;
        sleep 5

        # Copy backup to worlds folder
        tput setaf 2; echo "$RESTORE_WORLD_DATA_COPYING ${backups[selectedIndex - 1]} to ${worldpath}/${worldname}/"; tput setaf 9;
        cp "${backups[selectedIndex - 1]}" "${worldpath}/${worldname}/"

        # Unpack backup
        tput setaf 2; echo "$RESTORE_WORLD_DATA_UNPACKING ${worldpath}/${restorefile}"; tput setaf 9;
        tar xzf "${worldpath}/${worldname}/${restorefile}" --strip-components=7 --directory "${worldpath}/${worldname}/"
        chown -Rf steam:steam "${worldpath}/${worldname}/"
        rm "${worldpath}/${worldname}"/*.tgz

        # Start Valheim server
        tput setaf 2; echo "$RESTORE_WORLD_DATA_STARTING_VALHEIM_SERVICES"; tput setaf 9;
        tput setaf 2; echo "$RESTORE_WORLD_DATA_CUSS_LOKI"; tput setaf 9;
        systemctl start valheimserver_${worldname}.service
    else
        tput setaf 2; echo "$RESTORE_WORLD_DATA_CANCEL_CUSS_LOKI"; tput setaf 9;
    fi
}

########################################################################
##########Backup and Restore World DB and FWL Files END#################
########################################################################

########################################################################
###############LD: Download Valheim from steam #########################
########################################################################
function nocheck_valheim_update_install() {
    # Set Steam executable and update/install Valheim
    tput setaf 1; echo "$INSTALL_BUILD_DOWNLOAD_INSTALL_STEAM_VALHEIM"; tput setaf 9;
    sleep 1

    # Execute the steamcmd command to install/update Valheim
    $steamexe +login anonymous +force_install_dir "${valheimInstallPath}/${worldname}" +app_update 896660 validate +exit

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
}


########################################################################
#############Install Official Update of Valheim Updates#################
########################################################################
function continue_with_valheim_update_install() {
    clear
    echo ""
    echo -ne "
$(ColorOrange "$FUNCTION_INSTALL_VALHEIM_UPDATES")
$(ColorRed "$DRAW60")"
    echo ""
    tput setaf 2; echo "$FUNCTION_INSTALL_VALHEIM_FOUND"; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_INSTALL_VALHEIM_UPDATE_INFO"; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_INSTALL_VALHEIM_UPDATE_CONFIRM"; tput setaf 9;
    echo -ne "
$(ColorRed "$DRAW60")"
    echo ""
    read -p "$PLEASE_CONFIRM" confirmOfficialUpdates

    # If 'y', then continue, else cancel
    if [ "$confirmOfficialUpdates" == "y" ]; then
        tput setaf 2; echo "$FUNCTION_INSTALL_VALHEIM_UPDATE_APPLY_INFO"; tput setaf 9;
        $steamexe +login anonymous +force_install_dir "${valheimInstallPath}/${worldname}" +app_update 896660 validate +exit
        chown -R steam:steam "${valheimInstallPath}/${worldname}"
        echo ""
    else
        tput setaf 2; echo "$FUNCTION_INSTALL_VALHEIM_UPDATES_CANCEL"; tput setaf 9;
        sleep 3
        clear
    fi
}



########################################################################
######################beta updater for Valheim##########################
########################################################################
function check_apply_server_updates_beta() {
    echo ""
    echo "Downloading Official Valheim Repo Log Data for comparison only"
    
    # Remove appinfo.vdf files
    find "/home" "/root" -wholename "*/.steam/appcache/appinfo.vdf" -exec rm -f {} +

    # Get the official Valheim version from the repository
    repoValheim=$($steamexe +login anonymous +app_info_update 1 +app_info_print 896660 +quit | grep -A10 branches | grep -A2 public | grep buildid | cut -d'"' -f4)
    echo "Official Valheim: $repoValheim"
    
    # Get the local Valheim version
    localValheim=$(grep buildid "${valheimInstallPath}/${worldname}/steamapps/appmanifest_896660.acf" | cut -d'"' -f4)
    echo "Local Valheim Ver: $localValheim"
    
    if [ "$repoValheim" == "$localValheim" ]; then
        echo "No new updates found"
        sleep 2
    else
        echo "Update found, initiating update process!"
        sleep 2
        continue_with_valheim_update_install
        systemctl restart valheimserver_${worldname}.service
        echo ""
    fi
    
    echo ""
}


########################################################################
##############Verify Checking Updates for Valheim Server################
########################################################################
function confirm_check_apply_server_updates() {
    while true; do
        echo -ne "
$(ColorRed "$DRAW60")"
        echo ""
        tput setaf 2; echo "$FUNCTION_CONFIRM_CHECK_APPLY_SERVER_UPDATES_INFO"; tput setaf 9;
        tput setaf 2; echo "$FUNCTION_CONFIRM_CHECK_APPLY_SERVER_UPDATES_INFO_1"; tput setaf 9;
        tput setaf 2; echo "$FUNCTION_CONFIRM_CHECK_APPLY_SERVER_UPDATES_INFO_2"; tput setaf 9;
        tput setaf 2; echo "$PLEASE_CONFIRM"; tput setaf 9;
        echo -ne "
$(ColorRed "------------------------------------------------------------")"
        echo ""
        tput setaf 2; read -p "$FUNCTION_CONFIRM_CHECK_APPLY_SERVER_UPDATES_CONTINUE" yn; tput setaf 9;
        echo -ne "
$(ColorRed "------------------------------------------------------------")"
        
        case $yn in
            [Yy]* )
                check_apply_server_updates_beta
                break
                ;;
            [Nn]* )
                break
                ;;
            * )
                echo "$PLEASE_CONFIRM"
                ;;
        esac
    done
}



########################################################################
##############Valheim Server Service CONTROL START######################
########################################################################

# Stop Valheim Server Service
function stop_valheim_server() {
    clear
    echo ""
    echo -ne "
$(ColorOrange "$FUNCTION_STOP_VALHEIM_SERVER_SERVICE_HEADER")
$(ColorRed "$DRAW60")"
    echo ""
    tput setaf 2; echo "$FUNCTION_STOP_VALHEIM_SERVER_SERVICE_INFO"; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_STOP_VALHEIM_SERVER_SERVICE_INFO_1"; tput setaf 9;
    echo -ne "
$(ColorRed "$DRAW60")"
    echo ""
    read -p "$PLEASE_CONFIRM" confirmStop

    # If 'y', then continue, else cancel
    if [ "$confirmStop" == "y" ]; then
        echo ""
        echo "$FUNCTION_STOP_VALHEIM_SERVER_SERVICE_STOPPING"
        sudo systemctl stop valheimserver_${worldname}.service
        echo ""
    else
        echo "$FUNCTION_STOP_VALHEIM_SERVER_SERVICE_CANCEL"
        sleep 3
        clear
    fi
}


# Start Valheim Server Service
function start_valheim_server() {
    clear
    echo ""
    echo -ne "
$(ColorOrange ''"$FUNCTION_START_VALHEIM_SERVER_SERVICE_HEADER"'')
$(ColorRed ''"$DRAW60"'')"
	echo ""
	tput setaf 2; echo "$FUNCTION_START_VALHEIM_SERVER_SERVICE_INFO" ; tput setaf 9;
	tput setaf 2; echo "$FUNCTION_START_VALHEIM_SERVER_SERVICE_INFO_1" ; tput setaf 9;
	echo -ne "
$(ColorRed ''"$DRAW60"'')"
	echo ""
		read -p "$PLEASE_CONFIRM" confirmStart
	#if y, then continue, else cancel
    if [ "$confirmStart" == "y" ]; then
		echo ""
		tput setaf 2; echo "$FUNCTION_START_VALHEIM_SERVER_SERVICE_START" ; tput setaf 9;
		sudo systemctl start valheimserver_${worldname}.service
		echo ""
    else
		echo "$FUNCTION_START_VALHEIM_SERVER_SERVICE_CANCEL"
        sleep 3
		clear
	fi
}

# Restart Valheim Server Service
function restart_valheim_server() {
    clear
    echo ""
    echo -ne "
$(ColorOrange ''"$FUNCTION_RESTART_VALHEIM_SERVICE_SERVICE_HEADER"'')
$(ColorRed ''"$DRAW60"'')"
	echo ""
	tput setaf 2; echo "$FUNCTION_RESTART_VALHEIM_SERVICE_SERVICE_INFO" ; tput setaf 9; 
	tput setaf 2; echo "$FUNCTION_RESTART_VALHEIM_SERVICE_SERVICE_INF0_1" ; tput setaf 9; 
	echo -ne "
$(ColorRed ''"$DRAW60"'')"
	echo ""
		read -p "$PLEASE_CONFIRM" confirmRestart
	#if y, then continue, else cancel
    if [ "$confirmRestart" == "y" ]; then
		tput setaf 2; echo "$FUNCTION_RESTART_VALHEIM_SERVICE_SERVICE_RESTART" ; tput setaf 9; 
		sudo systemctl restart valheimserver_${worldname}.service
		echo ""
    else
        echo "$FUNCTION_RESTART_VALHEIM_SERVICE_SERVICE_CANCEL"
        sleep 3
		clear
	fi
}

# Display Valheim Server Status
function display_valheim_server_status() {
    echo ""
    sudo systemctl status --no-pager -l valheimserver_${worldname}.service
    echo ""
    echo "Returning to menu in 5 Seconds"
    sleep 5
}

########################################################################
##############Valheim Server Service CONTROL END########################
########################################################################


########################################################################
##############Valheim Server Information output START###################
########################################################################

# Display Valheim Vanilla Configuration File
function display_start_valheim() {
    echo ""
    sudo cat ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh
    echo ""
    echo "Returning to menu in 5 Seconds"
    sleep 5
}


# Display Valheim Start Configuration
function display_start_valheim() {
    echo ""
    sudo cat ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh
    echo ""
    echo "Returning to menu in 5 Seconds"
    sleep 5
}

# Display Valheim World Data Folder
function display_world_data_folder() {
    echo ""
    sudo ls -lisa $worldpath/$worldname/worlds
    echo ""
    echo "Returning to menu in 5 Seconds"
    sleep 5
}

# Print System INFOS
function display_system_info() {
    echo ""
    echo -e "$DRAW80"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_HEADER"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_HOSTNAME $(hostname)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_UPTIME $(uptime -p)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_MANUFACTURER $(cat /sys/class/dmi/id/chassis_vendor)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_PRODUCT_NAME $(cat /sys/class/dmi/id/product_name)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_VERSION $(cat /sys/class/dmi/id/product_version)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_SERIAL_NUMBER $(cat /sys/class/dmi/id/product_serial)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_MACHINE_TYPE $(if lscpu | grep -q Hypervisor; then echo "VM"; else echo "Physical"; fi)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_OPERATION_SYSTEM $(hostnamectl | grep "Operating System" | cut -d ' ' -f5-)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_KERNEL $(uname -r)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_ARCHITECTURE $(arch)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_PROCESSOR_NAME $(awk -F':' '/^model name/ {print $2}' /proc/cpuinfo | uniq | sed -e 's/^[ \t]*//')"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_ACTIVE_USER $(w -h | awk '{print $1}' | sort | uniq)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_SYSTEM_MAIN_IP $(hostname -I | awk '{print $1}')"
    echo ""
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_CPU_MEM_HEADER"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_MEMORY_USAGE $(free | awk '/Mem/{printf("%.2f %%"), $3/$2*100}')"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_CPU_USAGE $(awk -v sum=0 -v idle=0 '{if ($1 ~ /^cpu/) {sum += $2+$3+$4+$5+$6+$7+$8; idle += $5}} END {printf("%.2f %%\n"), (sum-idle)*100/sum}' /proc/stat)"
    echo ""
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_DISK_HEADER"
    df -Ph | awk '$5+0 > 80'
    echo -e "$DRAW80"
    echo ""
    echo "Returning to menu in 5 seconds"
    sleep 5
}


# PRINT NETWORK INFO
function display_network_info() {
    echo ""
    sudo netstat -atunp | grep valheim
    echo ""
    echo "Returning to menu in 5 Seconds"
    sleep 5
}

# Display History of Connected Players
function display_player_history() {
    echo ""
    grep ZDOID ${worldpath}/${worldname}/valheim_server.log
    grep *HAND* ${worldpath}/${worldname}/valheim_server.log
    echo ""
    echo "Returning to menu in 5 Seconds"
    sleep 5
}
function get_worldseed() {
    # Extract the world seed from the .fwl file
    worldseed=$(hexdump -s 9 -n 10 -e '2/1 "%02x"' "${worldpath}/${worldname}/worlds_local/${worldname}.fwl" | tr -d ' ')

    echo ""
    echo -e '\E[32m'"$worldseed"
    echo ""
    echo "Returning to menu in 5 seconds - This might not be working 100% still testing"
    sleep 5
}


########################################################################
##############Valheim Server Information output END#####################
########################################################################

########################################################################
############# (WIP) Firewall control section START #####################
########################################################################

## LD: Going to add disable / enable firewall and then
## call use them in the start and stop service actions above.
# I am sure this will always return y .. Who does not have some firewall system installed. But ...

function is_admin_firewall_installed() {
    if command -v "$fwbeingused" >/dev/null; then
        is_admin_firewall_installed=y
    else
        is_admin_firewall_installed=n
    fi
    echo -e '\E[32m'"$is_admin_firewall_installed"
}

function is_any_firewall_installed() {
    fwiufw=n
    fwifwd=n
    fwiipt=n
    fwiipt6=n
    fwiebt=n

    if command -v ufw >/dev/null; then
        fwiufw=y
        echo -ne "
$(ColorOrange "Uncomplicated Firewall (ufw) is installed.")"
    fi

    if command -v firewalld >/dev/null; then
        fwifwd=y
        echo -ne "
$(ColorOrange "FireWALLD is installed.")"
    fi

    if command -v iptables >/dev/null; then
        fwiipt=y
        echo -ne "
$(ColorOrange "IPTables is installed.")"
    fi

    if command -v ip6tables >/dev/null; then
        fwiipt6=y
        echo -ne "
$(ColorOrange "IP6Tables is installed.")"
    fi

    if command -v ebtables >/dev/null; then
        fwiebt=y
        echo -ne "
$(ColorOrange "EBTables is installed.")"
    fi

    if [[ "$fwiufw" == "y" || "$fwifwd" == "y" || "$fwiipt" == "y" || "$fwiipt6" == "y" || "$fwiebt" == "y" ]]; then
        is_any_firewall_installed=y
    else
        is_any_firewall_installed=n
    fi
    #echo -e '\E[32m'"$is_any_firewall_installed"
}


function is_admin_firewall_enabled(){
        if command -v ${fwbeingused} >/dev/null; then
                is_admin_firewall_enabled=$(systemctl is-enabled $fwbeingused)

        fi
        echo -e '\E[32m'"$is_admin_firewall_enabled "
}


function is_any_firewall_enabled() {
    local fwearp=n fweebt=n fwefwd=n fweipt=n fweipt6=n fweufw=n

    if command -v arptables >/dev/null; then 
        systemctl is-enabled arptables >/dev/null 2>&1 && fwearp=y
    fi

    if command -v ebtables >/dev/null; then 
        systemctl is-enabled ebtables >/dev/null 2>&1 && fweebt=y
    fi

    if command -v firewalld >/dev/null; then
        systemctl is-enabled firewalld >/dev/null 2>&1 && fwefwd=y
    fi

    if command -v iptables >/dev/null; then 
        systemctl is-enabled iptables >/dev/null 2>&1 && fweipt=y
    fi

    if command -v ip6tables >/dev/null; then 
        systemctl is-enabled ip6tables >/dev/null 2>&1 && fweipt6=y
    fi

    if command -v ufw >/dev/null; then 
        systemctl is-enabled ufw >/dev/null 2>&1 && fweufw=y
    fi

    if [[ "$fwearp" == "y" || "$fweebt" == "y" || "$fwefwd" == "y" || "$fweipt" == "y" || "$fweipt6" == "y" || "$fweufw" == "y" ]]; then
        is_any_firewall_enabled="y"
    else
        is_any_firewall_enabled="n"
    fi

    # Testing for now...
    if [ "$is_any_firewall_enabled" == "y" ]; then 
        echo -ne "
$(ColorOrange "Firewall(s) Enabled: -- UFW: ${fweufw} -- Firewalld: ${fwefwd} -- Iptables: ${fweipt} -- Ip6tables: ${fweipt6} -- ARPTables: ${fwearp} -- EBTables: ${fweebt}")"
    else
        echo -ne "
$(ColorOrange "No Firewall enabled.")"
    fi
    # echo -e '\E[32m'"$is_any_firewall_enabled"
}

function get_firewall_status() {
    if [ "$usefw" == "y" ]; then
        is_admin_firewall_enabled

        if [ "$is_admin_firewall_enabled" == "enabled" ]; then
            get_firewall_status="NA"

            if command -v "$fwbeingused" >/dev/null; then
                get_firewall_status=$(systemctl is-active "$fwbeingused")
            else
                get_firewall_status="Error"
            fi
        else
            get_firewall_status="NotEnabled"
        fi
    else
        get_firewall_status="NoFWAdmin"
    fi
    echo -e '\E[32m'"$get_firewall_status"
}



function get_firewall_substate(){
	if [ "${usefw}" == "y" ] ; then
		is_admin_firewall_enabled
        if [ "$is_admin_firewall_enabled" == "enabled" ] ; then
			get_firewall_substate="NA"
			#Is this better and does it work?
			if command -v $fwbeingused >/dev/null; then
				get_firewall_substate=$(systemctl show -p SubState ${fwbeingused})
			else
				get_firewall_substate="Error"
			fi
		else
			get_firewall_substate="NotEnabled"
		fi
	else
		get_firewall_substate="NoFWAdmin"
	fi
	echo -e '\E[32m'"$get_firewall_substate "
}

function get_firewall_moreinfo(){
	if [ "${usefw}" == "y" ] ; then
		get_firewall_moreinfo="NA"
		
		#if [ "${fwused}" == "a" ] ; then
		#	echo ""
		#elif [ "${fwused}" == "e" ] ; then
		#	echo ""
		#elif [ "${fwused}" == "f" ] ; then
		if [ "${fwbeingused}" == "firewalld" ] ; then
			if command -v firewalld >/dev/null; then 
				firewall-cmd --state
				firewall-cmd --get-default-zone
				firewall-cmd --get-active-zones
				firewall-cmd --get-zones 
				firewall-cmd --get-services 
				firewall-cmd --zone=public --permanent --list-all
				get_firewall_moreinfo="Success"
			fi
		#elif [ "${fwused}" == "i" ] ; then
		#	echo ""		
		#elif [ "${fwused}" == "u" ] ; then
		#	echo ""
		else
			get_firewall_moreinfo="Firewall config not concomplete."
		fi
	else
		get_firewall_moreinfo="Firewall Admin not enabled."
	fi
	echo -e '\E[32m'"$get_firewall_moreinfo "
}

function is_port_added_firewall(){
        is_port_added_firewall="n"
        ((currentPortPlus=$currentPort+2))
        if command -v ${fwbeingused} >/dev/null; then
            if [ "${fwbeingused}" == "firewalld" ] ; then
                portlistarray=( $(sudo firewall-cmd --zone=public --permanent --list-ports) )
                idx=0
                while [ $idx -le ${#portlistarray[@]} ] && [ "$is_port_added_firewall" != "y" ] ;
                do
                    portTestString="$currentPort-$currentPortPlus/udp"
                    if [ "$portTestString" == "${portlistarray[$idx]}" ] ; then
                            is_port_added_firewall="y"
                    else
                            is_port_added_firewall="e"
                    fi
                    ((idx=$idx+1))
                done
            else
                    is_port_added_firewall="x"
            fi
        else
                is_port_added_firewall="z"
        fi
        echo -e '\E[32m'"$is_port_added_firewall "
}

function enable_prefered_firewall(){
	#Is this better and does it work?
	if command -v ${fwbeingused} >/dev/null; then
		sudo systemctl unmask ${fwbeingused} && systemctl enable ${fwbeingused} && systemctl start ${fwbeingused}	
		enable_prefered_firewall="Completed"
	else
		enable_prefered_firewall"Firewall Admin not enabled."
    fi


	#if [ "${fwused}" == "a" ] ; then		
	#	if command -v arptables >/dev/null; then
	#		sudo systemctl unmask arptables && systemctl enable arptables && systemctl start arptables		  
	#	fi
	#elif [ "${fwused}" == "e" ] ; then		
	#	if command -v ebtables >/dev/null; then
	#		sudo systemctl unmask ebtables && systemctl enable ebtables && systemctl start ebtables		  
	#	fi
    #elif [ "${fwinuse}" == "f" ] ; then
	#	if command -v firewalld >/dev/null; then
	#		sudo systemctl unmask firewalld && systemctl enable firewalld && systemctl start firewalld		  
	#	fi	
    #elif [ "${fwinuse}" == "i" ] ; then
	#	if command -v iptables >/dev/null; then
	#		sudo systemctl unmask iptables && systemctl enable iptables && systemctl start iptables		  
	#	fi
	#	#if command -v ip6tables >/dev/null; then
	#	#	sudo systemctl unmask ip6tables && systemctl enable ip6tables && systemctl start ip6tables		
	#	#fi
    #elif [ "${fwinuse}" == "u" ] ; then
	#	if command -v ufw >/dev/null; then
	#		sudo systemctl unmask ufw && systemctl enable ufw && systemctl start ufw
	#	fi	
	#else
	#	echo "No firewalls to enable"
    #fi
	echo -e '\E[32m'"$enable_prefered_firewall "	
}

function disable_all_firewalls(){
	#Is this better and does it work?
	for fws in ${fwsystems[@]}
	do
		echo "$fws is being stopped."
		if command -v $fws >/dev/null; then
			sudo systemctl stop $fws && systemctl disable $fws
			## && systemctl mask $fws
		fi
	done 
	# if command -v arptables >/dev/null; then
	# 	 sudo systemctl stop arptables && systemctl disable arptables 
	# 	 ## && systemctl mask arptables
	# fi	
	# if command -v ebtables >/dev/null; then
	# 	 sudo systemctl stop ebtables && systemctl disable ebtables 
	# 	 ## && systemctl mask ebtables
	# fi	
    # if command -v firewalld >/dev/null; then
    #      sudo systemctl stop firewalld && sudo systemctl disable firewalld 
	# 	 ## && systemctl mask firewalld	  
    # fi
	# if command -v iptables >/dev/null; then
    #      sudo systemctl stop iptables && systemctl disable iptables 
	# 	 ## && systemctl mask iptables
	# fi
	# if command -v ip6tables >/dev/null; then
	# 	 sudo systemctl stop ip6tables && systemctl disable ip6tables 
	# 	 ## && systemctl mask ip6tables
	# fi
    # if command -v ufw >/dev/null; then
    #      sudo systemctl stop ufw && systemctl disable ufw 
	# 	 ## && systemctl mask ufw		  
	# fi	
	disable_all_firewalls="All known Firewall systems disabled."
	echo -e '\E[32m'"$disable_all_firewalls "
}

function add_Valheim_server_public_ports(){
	if [ "${usefw}" == "y" ] ; then 
		if [ "${fwbeingused}" == "fierwalld" ] ; then
			if [ "$sftc" == "ste" ] ; then
				sudo firewall-cmd --zone=public --permanent --add-port={1200/udp,27000-27015/udp,27020/udp,27015-27016/tcp,27030-27039/tcp}
			elif [ "$sftc" == "val" ] ; then   
			    #sudo firewall-cmd --zone=public --permanent --add-port=${Vportnumber}-${Vportnumber+2}/udp
				sudo firewall-cmd --zone=public --permanent --add-port=${currentPort}-${currentPort+2}/udp
				
			else
				echo ""

			fi
			sudo firewall-cmd --reload
			sudo firewall-cmd --zone=public --permanent --list-ports
		fi	
	fi
}

function remove_Valheim_server_public_ports(){
	if [ "${usefw}" == "y" ] ; then 
		if [ "${fwbeingused}" == "firewalld" ] ; then
			if [ "$sftc" == "ste" ] ; then
				sudo firewall-cmd --zone=public --permanent --remove-port={1200/udp,27000-27015/udp,27020/udp,27015-27016/tcp,27030-27039/tcp}
			elif [ "$sftc" == "val" ] ; then 
			    #Need to write a get_current_port function.
				#sudo firewall-cmd --zone=public --permanent --remove-port=${Vportnumber}-${Vportnumber+2}/udp
				sudo firewall-cmd --zone=public --permanent --remove-port=${currentPort}-${currentPort+2}/udp				
			else				
				echo ""
			fi
			sudo firewall-cmd --reload
			sudo firewall-cmd --zone=public --permanent --list-ports
		fi	
	fi
}


# for all other FW systems
function add_to_etc_services_file(){
	echo "idea only for now"
}

# These are created for FireWALLD only. 
# As an idea when I thought the other system might have the same type thing.
# I am going back to add the ports only. But leaving this code here.

function create_firewalld_service_file(){
	if [ "${usefw}" == "y" ] ; then 
		if [ "${fwbeingused}" == "firewalld" ] ; then
			if [ "$sftc" == "ste" ] ; then
				checkfile=/usr/lib/firewalld/services/steam.xml
				if [ -f "$checkfile" ] ; then
					echo "Steam<cmd> Firewalld service file already created."
				else
					cat >> /usr/lib/firewalld/services/steam.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>Steam service</short>
  <description>These are the ports needed for Steam and Steamcmd</description>
  <port protocol="upd" port="1200"/>
  <port protocol="upd" port="27000-27015"/>
  <port protocol="upd" port="27020"/>
  <port protocol="tcp" port="27015-27016"/>
  <port protocol="tcp" port="27030-27039"/>
</service>
EOF
				fi
			elif [ "$sftc" == "val" ] ; then    
				checkfile=/usr/lib/firewalld/services/valheimserver-${worldname}.xml
				if [ -f "$checkfile" ] ; then
					echo "Steam<cmd> Firewalld service file already created."
				else
					cat >> /usr/lib/firewalld/services/valheimserver_${worldname}.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<service>
   <short>Valheim ${worldname} Server</short>
   <description>Valheim ${worldname} game server ports</description>
   <port protocol="upd" port="${currentPort}-${currentPort+2}"/>
 </service>
EOF
				fi
			else
				echo ""
			fi 
		fi
	fi
	sudo firewall-cmd --reload
	cat "$checkfile"

}

function delete_firewalld_service_file(){
	if [ "${usefw}" == "y" ] ; then 
		if [ "${fwbeingused}" == "firewalld" ] ; then
			if [ "$sftc" == "ste" ] ; then
				checkfile=/usr/lib/firewalld/services/steam.xml
				if [ -f "$checkfile" ] ; then
					rm /usr/lib/firewalld/services/steam.xml
				else
					echo "File does not exist."
				fi
			elif [ "$sftc" == "val" ] ; then   
				checkfile=/usr/lib/firewalld/services/valheimserver-${worldname}.xml
				if [ -f "$checkfile" ] ; then
					rm /usr/lib/firewalld/services/valheimserver-${worldname}.xml
				else
					echo "File does not exist."
				fi
			else
				echo ""
			fi 
		fi
	fi
	sudo firewall-cmd --reload
	cat "$checkfile"
}

function add_firewalld_public_service(){
	if [ "${usefw}" == "y" ] ; then 
		if [ "${fwbeingused}" == "firewalld" ] ; then
			if [ "$sftc" == "ste" ] ; then
				sudo firewall-cmd --zone=public --permanent --add-service=steam
			elif [ "$sftc" == "val" ] ; then   
				sudo firewall-cmd --zone=public --permanent --add-service=valheim-${worldname}
			else
				echo ""

			fi
		fi	
	fi
	sudo firewall-cmd --reload
	sudo firewall-cmd --zone=public --permanent --list-services
}

function remove_firewalld_public_service(){
	if [ "${usefw}" == "y" ] ; then 
		if [ "${fwbeingused}" == "f" ] ; then
			if [ "$sftc" == "ste" ] ; then
				sudo firewall-cmd --zone=public --permanent --remove-service=steam
			elif [ "$sftc" == "val" ] ; then 
				sudo firewall-cmd --zone=public --permanent --remove-service=valheim-${worldname}
			else				
				echo ""
				# firewall-cmd --zone=public --permanent --remove-service=*
				
			fi
		fi	
		
	fi
	sudo firewall-cmd --reload
	sudo firewall-cmd --zone=public --permanent --list-services
}

########################################################################
############# (WIP) Firewall control section END    ####################
########################################################################

########################################################################
##############MAIN VALHEIM SERVER ADMIN FUNCTIONS END###################
########################################################################
########################################################################

########################################################################
##################CHANGE VALHEIM START CONFIG START#####################
function get_current_config() {
    # Check if the world file list exists, if not, unset worldlistarray and read the world file list
    if [ -f "$worldfilelist" ]; then
        readarray -t worldlistarray < "$worldfilelist"
    else
        unset worldlistarray
    fi

    set_world_server
    set_steamexe

    config_file="${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh"

    currentDisplayName=$(perl -n -e '/\-name "?([^"]+)"? \-port/ && print "$1\n"' "$config_file")
    currentPort=$(perl -n -e '/\-port "?([^"]+)"? \-nographics/ && print "$1\n"' "$config_file")
    currentWorldName=$(perl -n -e '/\-world "?([^"]+)"? \-password/ && print "$1\n"' "$config_file")
    currentPassword=$(perl -n -e '/\-password "?([^"]+)"? \-public/ && print "$1\n"' "$config_file")
    currentPublicSet=$(perl -n -e '/\-public "?([^"]+)"? \-savedir/ && print "$1\n"' "$config_file")
    currentSaveDir=$(perl -n -e '/\-savedir "?([^"]+)"? \-logfile/ && print "$1\n"' "$config_file")
    currentLogfileDir=$(perl -n -e '/\-logfile "?([^"]+)"? \-crossplay/ && print "$1\n"' "$config_file")
    currentCrossplayStatus=$(perl -n -e '/\-crossplay "?([^"]+)"?$/ && print "$1\n"' "$config_file")
}


function print_current_config() {
    echo -e "$FUNCTION_PRINT_CURRENT_CONFIG_PUBLIC_NAME $(tput setaf 2)${currentDisplayName}$(tput setaf 9)"
    echo -e "$FUNCTION_PRINT_CURRENT_CONFIG_PORT $(tput setaf 2)${currentPort}$(tput setaf 9)"
    echo -e "$FUNCTION_PRINT_CURRENT_CONFIG_LOCAL_WORLD_NAME $(tput setaf 2)${currentWorldName}$(tput setaf 9)"
    echo -e "$FUNCTION_PRINT_CURRENT_CONFIG_LOCAL_WORLD_NAME_INFO"
    echo -e "$FUNCTION_PRINT_CURRENT_CONFIG_ACCESS_PASSWORD $(tput setaf 2)${currentPassword}$(tput setaf 9)"
    echo -e "$FUNCTION_PRINT_CURRENT_CONFIG_PUBLIC_LISTING $(tput setaf 2)${currentPublicSet}$(tput setaf 9)"
    echo -e "Current Crossplay setting: 1 = Enable, 2 = Disabled $(tput setaf 2)${currentCrossplayStatus}$(tput setaf 9)"
    echo -e "This is the save path: $(tput setaf 2)${currentSaveDir}$(tput setaf 9)"
    echo -e "$FUNCTION_PRINT_CURRENT_CONFIG_PUBLIC_LISTING_INFO"
}


function set_config_defaults() {
    #assign current variables to set variables
    #if no changes are made, set variables will write to new config file anyways. No harm done
    #if changes are made, set variables are updated with new data and will be wrote to new config file
    setCurrentDisplayName=$currentDisplayName
    setCurrentPort=$currentPort
    setCurrentWorldName=$currentWorldName
    setCurrentPassword=$currentPassword
    setCurrentPublicSet=$currentPublicSet
    setCurrentSaveDir=$currentSaveDir
    setCurrentLogfileDir=$currentLogfileDir
    setCurrentCrossplayStatus=$currentCrossplayStatus
}

function write_config_and_restart() {
    tput setaf 1; echo "$FUNCTION_WRITE_CONFIG_RESTART_INFO"; tput setaf 9;
    sleep 1

    config_file="${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh"

    cat > "$config_file" <<EOF
#!/bin/bash
export templdpath=\$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:\$LD_LIBRARY_PATH
export SteamAppId=892970
# Tip: Make a local copy of this script to avoid it being overwritten by steam.
# NOTE: Minimum password length is 5 characters & Password can't be in the server name.
# NOTE: You need to make sure the ports 2456-2458 are being forwarded to your server through your local router & firewall.
./valheim_server.x86_64 -name "${setCurrentDisplayName}" -port "${setCurrentPort}" -nographics -batchmode -world "${setCurrentWorldName}" -password "${setCurrentPassword}" -public "${setCurrentPublicSet}" -savedir "${worldpath}/${worldname}" -logfile "${setCurrentLogfileDir}" -crossplay "${setCurrentCrossplayStatus}"
export LD_LIBRARY_PATH=\$templdpath
EOF

    echo "$FUNCTION_WRITE_CONFIG_RESTART_SET_PERMS $config_file"
    chown steam:steam "$config_file"
    chmod +x "$config_file"
    echo "$ECHO_DONE"
    echo "$FUNCTION_WRITE_CONFIG_RESTART_SERVICE_INFO"
    sudo systemctl restart valheimserver_${worldname}.service
    echo ""
}


function change_public_display_name() {
    get_current_config
    print_current_config
    set_config_defaults
    echo ""
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_CHANGE_PUBLIC_DISPLAY_NAME_HEADER"; tput setaf 9;
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_PUBLIC_DISPLAY_NAME_INFO"; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_PUBLIC_DISPLAY_NAME_INFO_1"; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_PUBLIC_DISPLAY_NAME_INFO_2"; tput setaf 9;
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_CHANGE_PUBLIC_DISPLAY_CURRENT_NAME ${currentDisplayName}"; tput setaf 9;
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    echo ""
    read -p "$FUNCTION_CHANGE_PUBLIC_DISPLAY_EDIT_NAME_INFO" setCurrentDisplayName
    echo ""
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    echo ""
    tput setaf 5; echo "$FUNCTION_CHANGE_PUBLIC_DISPLAY_OLD_PUBLIC_NAME ${currentDisplayName}"; tput setaf 9;
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    echo ""
    tput setaf 1; echo "$FUNCTION_CHANGE_PUBLIC_DISPLAY_NEW_PUBLIC_NAME ${setCurrentDisplayName}"; tput setaf 9;
    echo ""
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    echo ""
    read -p "$PLEASE_CONFIRM" confirmPublicNameChange
    # If 'y', then continue, else cancel
    if [ "$confirmPublicNameChange" == "y" ]; then
        write_config_and_restart
    else
        echo "$FUNCTION_CHANGE_PUBLIC_DISPLAY_CANCEL_CHANGING"
        sleep 3
        clear
    fi
}


function change_crossplay_status() {
    get_current_config
    set_config_defaults
    currentCrossplayStatus=$(perl -n -e '/\-crossplay "?([^"]+)"?$/ && print "$1\n"' "${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh")

    echo ""
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    tput setaf 2; echo "You are about to change the crossplay options"; tput setaf 9;
    tput setaf 2; echo "$DRAW60"; tput setaf 9;

    if [ "$currentCrossplayStatus" == "1" ]; then
        tput setaf 1; echo "Crossplay is currently set to: $(tput setaf 2)Enabled$(tput setaf 9)"; tput setaf 9;
    else
        tput setaf 1; echo "Crossplay is currently set to: $(tput setaf 1)Disabled$(tput setaf 9)"; tput setaf 9;
    fi

    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    echo ""
    read -p "Please enter 1 to Enable Crossplay or 0 to Disable Crossplay: " setCurrentCrossplayStatus
    echo ""
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    echo ""
    tput setaf 5; echo "Crossplay option old settings: ${currentCrossplayStatus}"; tput setaf 9;
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    echo ""
    tput setaf 1; echo "Crossplay option new settings: ${setCurrentCrossplayStatus}"; tput setaf 9;
    echo ""
    tput setaf 1; echo "WARNING: Many people are having issues with Crossplay... this has nothing to do with the script."; tput setaf 9;
    tput setaf 1; echo "We will update configs if needed, when the community has it 100% figured out. If it doesn't work for you, congrats!"; tput setaf 9;
    echo ""
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    echo ""
    read -p "$PLEASE_CONFIRM" confirmCrossplayStatusChange

    # If 'y', then continue, else cancel
    if [ "$confirmCrossplayStatusChange" == "y" ]; then
        write_config_and_restart
    else
        echo "Updating Crossplay option cancelled"
        sleep 3
        clear
    fi

    echo "Crossplay is disabled from auto configurations."
    echo "Please edit the start_valheim_${worldname}.sh file and change the -crossplay 1 to -crossplay 0"
    echo "Then restart the service with sudo systemctl restart valheimserver_${worldname}.service"
    echo "You will not be able to join the server with just IP:Port, if crossplay is enabled or disabled."
    echo "You will need to use the Invite Code to join the server."
    echo "Look into the logs for Invite Code to join your server."
    echo "If you need help, please join the discord and ask for help."
    sleep 5
}

function change_default_server_port() {
    get_current_config
    print_current_config
    set_config_defaults
    echo ""
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_HEADER"; tput setaf 9;
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_INFO"; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_INFO_1"; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_INFO_2"; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_INFO_3"; tput setaf 9;
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_CURRENT ${currentPort}"; tput setaf 9;
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    echo ""

    while true; do
        read -p "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_EDIT_PORT" setCurrentPort
        echo ""
        # Check for valid port number
        if [[ ${#setCurrentPort} -ge 4 && ${#setCurrentPort} -le 6 ]] && [[ $setCurrentPort -gt 1024 && $setCurrentPort -le 65530 ]] && [[ "$setCurrentPort" =~ ^[[:alnum:]]+$ ]]; then
            break
        fi
        echo ""
        echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_ERROR_CHECK_MSG"
    done

    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    tput setaf 5; echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_OLD_PORT ${currentPort}"; tput setaf 9;
    tput setaf 6; echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_NEW_PORT ${setCurrentPort}"; tput setaf 9;
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    read -p "$PLEASE_CONFIRM" confirmServerPortChange
    echo ""

    # If 'y', then continue, else cancel
    if [ "$confirmServerPortChange" == "y" ]; then
        write_config_and_restart
    else
        echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_CANCEL"
        sleep 3
        clear
    fi
}

function change_local_world_name() {

	echo ""
	echo "$FUNCTION_CHANGE_LOCAL_WORLD_NAME_MSG"
	echo "Advance Users do this manually because you know the errors can be catastrophic"
	echo ""

##### Placing in for compare of adv menu.
### get_current_config
### print_current_config
### set_config_defaults
### echo ""
### while true; do
###     tput setaf 2; echo "$DRAW60" ; tput setaf 9;
###     tput setaf 2; echo "$WORLD_SET_WORLD_NAME_HEADER" ; tput setaf 9;
###     tput setaf 2; echo "$DRAW60" ; tput setaf 9;
###     tput setaf 1; echo "$WORLD_SET_CHAR_RULES" ; tput setaf 9;
###     tput setaf 1; echo "$WORLD_SET_NO_SPECIAL_CHAR_RULES" ; tput setaf 9;
### tput setaf 2; echo "$DRAW60" ; tput setaf 9;
### tput setaf 2; echo "$WORLD_GOOD_EXAMPLE" ; tput setaf 9;
###     tput setaf 1; echo "$WORLD_BAD_EXAMPLE" ; tput setaf 9;
### tput setaf 2; echo "$DRAW60" ; tput setaf 9;
###     tput setaf 5; echo "$FUNCTION_CHANGE_CURRENT_WORLD_NAME" ${currentWorldName} ; tput setaf 9;
### echo ""
###     read -p "$WORLD_SET_WORLD_NAME_VAR" setCurrentWorldName
### tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
###         [[ ${#setCurrentWorldName} -ge 4 && "$setCurrentWorldName" =~ ^[[:alnum:]]+$ ]] && break
###     tput setaf 2; echo "$WORLD_SET_ERROR" ; tput setaf 9; 
### tput setaf 2; echo "$WORLD_SET_ERROR_1" ; tput setaf 9; 
###     done
###     echo ""
###     tput setaf 5; echo "$FUNCTION_CHANGE_CURRENT_WORLD_NAME" ${currentWorldName} ; tput setaf 9;
###     tput setaf 5; echo "$FUNCTION_CHANGE_CURRENT_WORLD_NAME_NEW" ${setCurrentWorldName} ; tput setaf 9;
###     read -p "$PLEASE_CONFIRM" confirmChangeWorldName
###     #if y, then continue, else cancel
###     if [ "$confirmChangeWorldName" == "y" ]; then
###        write_config_and_restart
###     else
###        echo "$FUNCTION_CHANGE_SERVER_WORLD_NAME_CANCEL"
###        sleep 3
###        clear
###  fi

}


function change_server_access_password() {
    get_current_config
    print_current_config
    set_config_defaults
    echo ""
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_HEADER"; tput setaf 9;
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_INFO"; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_INFO_1"; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_INFO_2"; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_INFO_3"; tput setaf 9;
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    tput setaf 5; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_CURRENT_DISPLAY_NAME ${currentDisplayName}"; tput setaf 9;
    tput setaf 5; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_CURRENT_WORLD_NAME ${currentWorldName}"; tput setaf 9;
    tput setaf 2; echo "$DRAW60"; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_CURRENT_PASS ${currentPassword}"; tput setaf 9;
    tput setaf 2; echo "$DRAW60"; tput setaf 9;

    while true; do
        tput setaf 1; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_INFO_RULES"; tput setaf 9;
        tput setaf 1; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_INFO_RULES_1"; tput setaf 9;
        tput setaf 2; echo "$DRAW60"; tput setaf 9;
        tput setaf 2; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_GOOD"; tput setaf 9;
        tput setaf 1; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_BAD"; tput setaf 9;
        tput setaf 2; echo "$DRAW60"; tput setaf 9;
        read -p "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_ENTER_NEW" setCurrentPassword
        tput setaf 2; echo "------------------------------------------------------------"; tput setaf 9;
        if [[ ${#setCurrentPassword} -ge 5 && "$setCurrentPassword" == *[[:lower:]]* && "$setCurrentPassword" == *[[:upper:]]* && "$setCurrentPassword" =~ ^[[:alnum:]]+$ ]]; then
            break
        fi
        tput setaf 2; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_ERROR_MSG"; tput setaf 9;
        tput setaf 2; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_ERROR_MSG_1"; tput setaf 9;
    done

    echo ""
    tput setaf 5; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_OLD_PASS ${currentPassword}"; tput setaf 9;
    tput setaf 5; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_NEW_PASS ${setCurrentPassword}"; tput setaf 9;
    read -p "$PLEASE_CONFIRM" confirmServerAccessPassword

    # If 'y', then continue, else cancel
    if [ "$confirmServerAccessPassword" == "y" ]; then
        write_config_and_restart
    else
        echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_CANCEL"
        sleep 3
        clear
    fi
}

function write_public_on_config_and_restart() {
    get_current_config
    set_config_defaults
    setCurrentPublicSet=1
    write_config_and_restart
}
function write_public_off_config_and_restart() {
    get_current_config
    set_config_defaults
    setCurrentPublicSet=0
    write_config_and_restart
}
function display_full_config() {
    get_current_config
    print_current_config
}
########################################################################
####################CHANGE VALHEIM START CONFIG END#####################
########################################################################


#######################################################################################################################################################
#########################################################START VALHEIM PLUS SECTION####################################################################
#######################################################################################################################################################
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
        | grep '"tag_name":' | cut -d'"' -f4 > localValheimPlusVersion

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

function valheim_plus_update() {
    check_valheim_plus_repo
    clear
    tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_UPDATE_INFO"; tput setaf 9;

    vpLocalCheck=$(cat "${valheimInstallPath}/${worldname}/localValheimPlusVersion")
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
            cp "${valheimInstallPath}/${worldname}/BepInEx/config/valheim_plus.cfg" "${backupPath}/valheim_plus-${worldname}-${TODAYMK}.cfg"

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


function valheimplus_mod_options() {
clear
    nano ${valheimInstallPath}/${worldname}/BepInEx/config/valheim_plus.cfg
    echo ""
    tput setaf 2; echo "$DRAW80" ; tput setaf 9;
    tput setaf 2;  echo "$FUNCTION_VALHEIM_PLUS_EDIT_VPLUS_CONFIG_SAVE_RESTART" ; tput setaf 9; 
    tput setaf 2;  echo "$FUNCTION_VALHEIM_PLUS_EDIT_VPLUS_CONFIG_SAVE_RESTART_1" ; tput setaf 9; 
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

function bepinex_mod_options() {
clear
    nano ${valheimInstallPath}/${worldname}/BepInEx/config/BepInEx.cfg
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
		    *)  echo -ne " $(ColorRed ''"$WRONG_MENU_OPTION"'')" ; mods_menu ;;
        esac
}

# Check ValheimPlus Github Latest for menu display
function check_valheim_plus_repo() {
    latestValPlus=$(curl --connect-timeout 10 -s https://api.github.com/repos/Grantapher/ValheimPlus/releases/latest | grep -oP '"tag_name": "\K[^"]+')
    echo "$latestValPlus"
}


# Check Local ValheimPlus Build for menu display
function check_local_valheim_plus_build() {
localValheimPlusVer=${valheimInstallPath}/${worldname}/localValheimPlusVersion
   if [[ -e $localValheimPlusVer ]] ; then
    localValheimPlusBuild=$(cat ${localValheimPlusVer})
        echo $localValheimPlusBuild
    else 
        echo "$NO_DATA";
  fi
}

#######################################################################################################################################################
###############################################################FINISH VALHEIM MOD SECTION##############################################################
#######################################################################################################################################################

#######################################################################################################################################################
######################################################START VALHEIM BEPINEX SECTION####################################################################
#######################################################################################################################################################
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
    grep '"version"' manifest.json | cut -d'"' -f4 > "${valheimInstallPath}/${worldname}/localValheimBepinexVersion"
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

function valheim_bepinex_update() {
clear
    tput setaf 2;  echo "$FUNCTION_BEPINEX_UPDATE_INFO" ; tput setaf 9; 
    officialBepInEx=$(curl -sL https://valheim.thunderstore.io/package/denikson/BepInExPack_Valheim/ | grep og:title | cut -d'"' -f 4 | cut -d' ' -f 3 | cut -d'v' -f2) 
    localBepInEx=$(cat ${valheimInstallPath}/${worldname}/localValheimBepinexVersion)    
    echo $officialBepInEx
    echo $localBepInEx
    if [[ $officialBepInEx == $localBepInEx ]]; then
    tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_NO_UPDATE_FOUND" ; tput setaf 9; 
    else
    tput setaf 2;  echo "$FUNCTION_BEPINEX_UPDATE_UPDATE_FOUND" ; tput setaf 9; 
	 tput setaf 2;  echo "$FUNCTION_BEPINEX_UPDATE_CONTINUE" ; tput setaf 9; 
	   read -p "$PLEASE_CONFIRM" confirmValBepinexUpdate
	  if [ "$confirmValBepinexUpdate" == "y" ]; then
	    tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_BACKING_UP_BEPINEX_CONFIG" ; tput setaf 9; 
	    dldir=$backupPath
	    [ ! -d "$dldir" ] && mkdir -p "$dldir"
            sleep 1
	    TODAYMK="$(date +%Y-%m-%d-%T)"
	    cp ${valheimInstallPath}/${worldname}/BepInEx/config/BepInEx.cfg ${backupPath}/BepInEx.cfg-$TODAYMK.cfg
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

function bepinex_mod_options() {
clear
    nano ${valheimInstallPath}/${worldname}/BepInEx/config/BepInEx.cfg
    echo ""
    tput setaf 2; echo "$DRAW80" ; tput setaf 9;
    tput setaf 2;  echo "$FUNCTION_BEPINEX_EDIT_CONFIG_SAVE_RESTART" ; tput setaf 9; 
    tput setaf 2;  echo "$FUNCTION_BEPINEX_EDIT_CONFIG_SAVE_RESTART_1" ; tput setaf 9; 
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

# Check bepinex Github Latest for menu display
#curl -s https://valheim.thunderstore.io/package/denikson/BepInExPack_Valheim/ | grep og:title | cut -d'"' -f 4 | cut -d' ' -f 3 | cut -d'v' -f2 > officialBepInEx
function check_bepinex_repo() {
latestBepinex=$(curl -s https://valheim.thunderstore.io/package/denikson/BepInExPack_Valheim/ | grep og:title | cut -d'"' -f 4 | cut -d' ' -f 3 | cut -d'v' -f2)
echo $latestBepinex
}


# Check Local Bepinex Build for menu display
function check_local_bepinex_build() {
localValheimBepinexVer=${valheimInstallPath}/${worldname}/localValheimBepinexVersion
   if [[ -e $localValheimBepinexVer ]] ; then
    localValheimBepinexBuild=$(cat ${localValheimBepinexVer})
        echo $localValheimBepinexBuild
    else 
        echo "$NO_DATA";
  fi
}


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
		    *)  echo -ne " $(ColorRed ''"$WRONG_MENU_OPTION"'')" ; mods_menu ;;
        esac
}


#######################################################################################################################################################
###############################################################FINISH BEPINEX MOD SECTION##############################################################
#######################################################################################################################################################



########################################################################
###############UPGRADE FROM OLD MENUS to NJORD MENU ####################
########################################################################


### This function is for people upgrading from the old menu system to the new menu system
### The function will restruc the whole file system for the Valheim Install directories
function get_current_config_upgrade_menu() {
        echo "Rebuilding Configuration Files for New Njord Menu"
        echo "Stopping Valheim Services"
	    systemctl stop valheimserver.service
	    echo "Waiting 5 seconds for complete shutdown"
	    sleep 5
		echo "Shutdown of Valheim Services complete"
		echo "Making Folder Structure Backup"
		cp -Rf /home/steam /home/steambackup
		sleep 1
		echo "Backup complete"
		echo "Starting Njord Menu upgrade process"
		echo "Creating world array file for future Valheim instance installs"
	    #Check for worlds.txt that holds all the Worlds running on a server
        [ -f "$worldfilelist" ] || perl -n -e '/\-world "?([^"]+)"? \-password/ && print "$1\n"' /home/steam/valheimserver/start_valheim.sh > /home/steam/worlds.txt
	    sleep 1
	    chown steam:steam /home/steam/worlds.txt
		echo "Worlds.txt file created"
        setNewWorldNamePathing=$(cat /home/steam/worlds.txt)
		echo "Rebuilding folder structure for Valheim installs"
	    mkdir ${valheimInstallPath}/${setNewWorldNamePathing}
		echo "New Structure path created"
		echo "Moving Valheim data to new folder structure"
	    rsync -a --exclude ${setNewWorldNamePathing} ${valheimInstallPath}/ /home/steam/valheimserver/${setNewWorldNamePathing}
	    sleep 1
		echo "Valheim data successfully moved"
		echo "Removing old Valheim data"
		# removing and cleaning up the files left over from the rsync.... if any exist and ignore the removal of the new folder structure
	    find ${valheimInstallPath} -mindepth 1 -maxdepth 1 -type d,f -not -name ${setNewWorldNamePathing} -exec rm -Rf '{}' \; 
	    sleep 1
		echo "Removal of old Valheim data complete"
		echo "Rebuilding Valheim Start up script and Valheim Service File"
	    # Rename the old startup script to match the current worldname and change to the new start up world name script
	    mv ${valheimInstallPath}/${setNewWorldNamePathing}/start_valheim.sh ${valheimInstallPath}/${setNewWorldNamePathing}/start_valheim_${setNewWorldNamePathing}.sh
        # Rebuild start_valheim configuration file adding -savedir startup flag
        get_current_config
		# Checks to see if the start server file already exists if so delete and rewrite
		#[ -e ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh ] && rm  ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh
  cat > ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh <<EOF
#!/bin/bash
export templdpath=\$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:\$LD_LIBRARY_PATH
export SteamAppId=892970
# Tip: Make a local copy of this script to avoid it being overwritten by steam.
# NOTE: Minimum password length is 5 characters & Password cant be in the server name.
# NOTE: You need to make sure the ports 2456-2458 is being forwarded to your server through your local router & firewall.
./valheim_server.x86_64 -name "${setCurrentDisplayName}" -port "${setCurrentPort}" -nographics -batchmode -world "${setCurrentWorldName}" -password "${setCurrentPassword}" -public "${setCurrentPublicSet}" -savedir "${worldpath}/${worldname}" -logfile "${setCurrentLogfileDir}" -crossplay "${setCurrentCrossplayStatus}"
export LD_LIBRARY_PATH=\$templdpath
EOF
		echo "Rebuilding New Valheim startup script complete"
        # Delete Old Service Files
		echo "Deleting old Valheim Service File"
        find /. -name valheimserver.service -exec rm -rf {} \;
		echo "Old Valheim Service File deleted"
        # Set Temp WorldName VAR for Service File
	    worldname=$(cat /home/steam/worlds.txt)
	    # Build new Service File
		echo "Building new Valheim Server Service File"
cat > /lib/systemd/system/valheimserver_${worldname}.service <<EOF
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
ExecStart=${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh
ExecReload=/bin/kill -s HUP \$MAINPID
KillSignal=SIGINT
WorkingDirectory=${valheimInstallPath}/${worldname}
LimitNOFILE=100000
[Install]
WantedBy=multi-user.target
EOF
		echo "New Valheim Server Service File Created"
    	# Reset Permissions and Ownership to Steam DIR
    	chown steam:steam /home/steam/worlds.txt
		echo "Moving ${worldname}.db and ${worldname}.fwl files to new location"
    	mkdir ${worldpath}/${worldname}
		rsync -a --exclude ${worldname} ${worldpath}/ /${worldpath}/${worldname}
    	# Set steam permissions again for double check to everything within the /home/steam/ directory
    	chown -Rf steam:steam /home/steam
    	# Reload daemon services to clear out old valheimserver.service
    	systemctl daemon-reload
    	sleep 1
    	# Start New Services
    	systemctl start valheimserver_${worldname}.service
    	echo "Upgrade Complete"
    	echo "Please restart the Njord Menu"
    	sleep 3
       
}

########################################################################
########################MENUS STATUS VARIBLES START ####################
########################################################################

# Check Current Valheim REPO Build for menu display
function check_official_valheim_release_build() {
    official_build_file="${valheimInstallPath}/${worldname}/officialvalheimbuild"

    update_official_repo() {
        find "/home" "/root" -wholename "*/.steam/appcache/appinfo.vdf" | xargs -r rm -f --
        currentOfficialRepo=$($steamexe +login anonymous +app_info_update 1 +app_info_print 896660 +quit | grep -A10 branches | grep -A2 public | grep buildid | cut -d'"' -f4)
        echo "$currentOfficialRepo" > "$official_build_file"
        chown steam:steam "$official_build_file"
        echo "$currentOfficialRepo"
    }

    if [[ $(find "$official_build_file" -mmin +59 -print) ]]; then
        update_official_repo
    elif [ ! -f "$official_build_file" ]; then
        update_official_repo
    elif [ -f "$official_build_file" ]; then
        currentOfficialRepo=$(cat "$official_build_file")
        echo "$currentOfficialRepo"
    else
        echo "$NO_DATA"
    fi
}


# Check Local Valheim Build for menu display
function check_local_valheim_build() {
localValheimAppmanifest=${valheimInstallPath}/${worldname}/steamapps/appmanifest_896660.acf
   if [[ -e $localValheimAppmanifest ]]; then
    localValheimBuild=$(grep buildid ${localValheimAppmanifest} | cut -d'"' -f4)
        echo $localValheimBuild
    else 
        echo "$NO_DATA";
  fi
}

function check_menu_script_repo() {
latestScript=$(curl --connect-timeout 5 -s https://api.github.com/repos/Nimdy/Dedicated_Valheim_Server_Script/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
echo $latestScript
}

function display_public_status_on_or_off() {
    currentPublicStatus=$(perl -n -e '/\-public "([0-1])"? \-savedir/ && print "$1\n"' ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh)
    if [[ $currentPublicStatus == 1 ]]; then 
      echo "$ECHO_ON"
    else
      echo "$ECHO_OFF"
  fi
}

function display_crossplay_status() {
	currentCrossplayStatus=$(perl -n -e '/\-crossplay "?([^"]+)"?$/ && print "$1\n"' ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh)
	if [ "$currentCrossplayStatus" == "1" ]; then 
	  echo  $(ColorGreen ''"Enabled"'')
	else
	  echo  $(ColorRed ''"Disabled"'')
  fi
}

function display_last_join_code() {
    local currentGameCode joinCode
    local logFile="/home/steam/.config/unity3d/IronGate/Valheim/${worldname}/valheim_server.log"

    # Search for the pattern and store the result in 'currentGameCode'
    currentGameCode=$(tac "$logFile" | grep -m1 -E " registered with join code [0-9]{6}")

    # Check if 'currentGameCode' is not empty before extracting the join code
    if [ -n "$currentGameCode" ]; then
        # Extract the last six digits and store them in 'joinCode'
        joinCode=$(echo "$currentGameCode" | grep -oP '(?<=join code )[0-9]{6}')
        echo "$joinCode"
    else
        echo "No join code found."
    fi
}


function current_player_count() {
    local connectedPeers playerCount
    local logFile="/home/steam/.config/unity3d/IronGate/Valheim/${worldname}/valheim_server.log"
    local timeLimit=$(date -d "30 minutes ago" '+%Y-%m-%dT%H:%M:%S')

    # Search for the pattern within the time limit and store the result in 'connectedPeers'
    connectedPeers=$(awk -v timeLimit="$timeLimit" -F'[][]' '$1 > timeLimit' "$logFile" | grep -E "Server: New peer connected,sending global keys")

    # Check if 'connectedPeers' is not empty before counting the occurrences
    if [ -n "$connectedPeers" ]; then
        # Count the occurrences of "Server: New peer connected,sending global keys" in the last 30 minutes
        playerCount=$(echo "$connectedPeers" | wc -l)
        echo "Players connected in the last 30 minutes: $playerCount"
    else
        echo "No players connected in the last 30 minutes."
    fi
}


function display_public_IP() {
    local externalip
    externalip=$(curl -s ipecho.net/plain)
    echo "$EXTERNAL_IP $whateverzerowantstocalthis $(ColorGreen "$externalip")"
    tput setaf 9
}

function display_local_IP() {
    local internalip
    internalip=$(hostname -I)
    echo "$INTERNAL_IP $mymommyboughtmeaputerforchristmas $(ColorGreen "$internalip")"
    tput setaf 9
}

function server_status() {
    local server_status
    server_status=$(systemctl is-active valheimserver_${worldname}.service)
    echo -e '\E[32m'"$server_status"
}

function server_substate() {
    local server_substate
    server_substate=$(systemctl show -p SubState valheimserver_${worldname}.service | cut -d'=' -f2)
    echo -e '\E[32m'"$server_substate"
}

function are_you_connected() {
    local status
    if ping -c 1 google.com &> /dev/null; then
        status=$(ColorGreen "$INTERNET_MSG_CONNECTED")
    else
        status=$(ColorRed "$INTERNET_MSG_DISCONNECTED")
    fi
    echo "$INTERNET_MSG $tecreset $status"
}

function are_mods_enabled() {
    local modstrue var2 var3
    modstrue=$(grep -F "ExecStart=${valheimInstallPath}/${worldname}/start" /lib/systemd/system/valheimserver_${worldname}.service)
    var2="ExecStart=${valheimInstallPath}/${worldname}/start_server_bepinex.sh"
    var3="ExecStart=${valheimInstallPath}/${worldname}/start_valw_bepinex.sh"

    if [[ $modstrue == *"$var2"* ]]; then
        echo "Enabled with ValheimPlus"
    elif [[ $modstrue == *"$var3"* ]]; then
        echo "Enabled with BepInEx"
    else
        echo "Disabled"
    fi
}

# LD: Set steamcmd based on Linux Flavor
function set_steamexe() {
	if [ "$debugmsg" == "y" ] ; then 
		tput setaf 1; echo -ne "$FUNCTION_SET_STEAMEXE_INFO" ; tput setaf 9;
	fi	
	if command -v apt-get >/dev/null; then
		steamexe=/home/steam/steamcmd
	elif command -v yum >/dev/null; then
	    steamexe=/home/steam/steamcmd/steamcmd.sh
	else
		echo ""
	fi
	if [ "$debugmsg" == "y" ] ; then 
		tput setaf 2; echo -ne "$ECHO_DONE" ; tput setaf 9;
	fi	
	sleep 1
}

# LD: Set the world server name.
function set_world_server() {
    if [ -z "$worldname" ] && [ -n "$worldlistarray" ] && [ "$request99" != "y" ]; then
        worldname="${worldlistarray[0]}"
    elif [ -n "$worldlistarray" ] && [ "$request99" = "y" ]; then
        echo "$FUNCTION_SET_WORLD_SERVER_INFO"
        select world in "${worldlistarray[@]}"; do
            if [ -n "$REPLY" ]; then
                worldname="$world"
                echo "You selected $world ($REPLY)"
                echo "World name is ${world}"
                echo "World menu selection: ${world}"
                break
            else
                echo "Invalid selection"
            fi
        done
    elif [ -z "$worldname" ] && [ -n "$worldlistarray" ]; then
        worldname="Default"
        echo ""
    else
        echo ""
    fi
    request99="n"
    clear
}


### Port Validation for creating additional Valheim installs
function validateUsedValheimPorts() {
    local starting_port=2459
    local ending_port=2600
    local port_in_use

    for (( i=$starting_port; i<=$ending_port; i++ )); do
        port_in_use=$(sudo netstat -plnt | grep ":$i")
        if [[ -z "$port_in_use" ]]; then
            echo "$i not in use, Recommend choosing this one"
            return
        elif [[ "$i" -eq "$ending_port" ]]; then
            echo "No ports to use"
        fi
    done
}


function currentHostName(){
var="$(hostname)"
echo $var
}
########################################################################
##########################MENUS STATUS VARIBLES END#####################
########################################################################

########################################################################
####################### MENU SECTION START       #######################
########################################################################

# NJORD Headers

function menu_header_vplus_enable() {
get_current_config
echo -ne "
$(ColorPurple '╔════════════════════')$(ColorOrange 'Valheim+')$(ColorPurple '═══════════════════╗')
$(ColorPurple '║~~~~~~~~~~~~~~~~~~')$(ColorLightGreen '-Njord Menu-')$(ColorPurple '~~~~~~~~~~~~~~~~~║')
$(ColorPurple '╠═══════════════════════════════════════════════╝')
$(ColorPurple '║')$(ColorLightGreen ' Welcome to Valheim+ Intergrated Menu System')
$(ColorPurple '║')$(ColorLightGreen ' Valheim+ Support: https://discord.gg/WU69A2JTcn')
$(ColorPurple '║ '"$FUNCTION_HEADER_MENU_INFO_2"'')
$(ColorPurple '╠═══════════════════════════════════════════════')
$(ColorPurple '║ Mods:') $(are_mods_enabled)
$(ColorPurple '╠═══════════════════════════════════════════════')
$(ColorPurple '║') ValheimPlus Official Build:" $(check_valheim_plus_repo)
echo -ne "
$(ColorPurple '║') ValheimPlus Server Build:" $(check_local_valheim_plus_build)
echo -ne "
$(ColorPurple '╠═══════════════════════════════════════════════')
$(ColorPurple '║ '"$FUNCTION_HEADER_MENU_INFO_VALHEIM_OFFICIAL_BUILD"'')" $(check_official_valheim_release_build)
echo -ne "
$(ColorPurple '║ '"$FUNCTION_HEADER_MENU_INFO_VALHEIM_LOCAL_BUILD"' ')"        $(check_local_valheim_build)
echo -ne "
$(ColorPurple '╠═══════════════════════════════════════════════')"
echo -ne "
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_SERVER_NAME " ${currentDisplayName}
echo -ne "
$(ColorPurple '║')" $FUNCTION_HEADER_MENU_INFO_LD_SEVER_SESSION $(ColorGreen ''"${worldname}"'')
echo -ne " 
$(ColorPurple '║') $(are_you_connected)
$(ColorPurple '║')" $(display_public_IP)
echo -ne "
$(ColorPurple '║')" $(display_local_IP)
echo -ne "
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_SERVER_PORT " ${currentPort}
echo -ne "
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_PUBLIC_LIST " $(display_public_status_on_or_off)
echo -ne "
$(ColorPurple '╠═══════════════════════════════════════════════')
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_CURRENT_NJORD_RELEASE $(check_menu_script_repo)
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_LOCAL_NJORD_VERSION ${mversion}
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_GG_ZEROBANDWIDTH
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_1
$(ColorPurple '╚═══════════════════════════════════════════════')"
}							  
						
function menu_header_bepinex_enable() {
get_current_config
echo -ne "
$(ColorCyan '╔═════════════════════')$(ColorOrange 'BepInEx')$(ColorCyan '═══════════════════╗')
$(ColorCyan '║~~~~~~~~~~~~~~~~~~')$(ColorLightGreen '-Njord Menu-')$(ColorCyan '~~~~~~~~~~~~~~~~~║')
$(ColorCyan '╠═══════════════════════════════════════════════╝')
$(ColorCyan '║')$(ColorLightGreen ' Welcome to BepInEx Intergrated Menu System')
$(ColorCyan '║')$(ColorLightGreen ' BepInEx Support: https://discord.gg/MpFEDAg')
$(ColorCyan '║ '"$FUNCTION_HEADER_MENU_INFO_2"'')
$(ColorCyan '╠═══════════════════════════════════════════════')
$(ColorCyan '║ Mods:') $(are_mods_enabled)
$(ColorCyan '╠═══════════════════════════════════════════════')
$(ColorCyan '║') BepInEx Official Build:" $(check_bepinex_repo)
echo -ne "
$(ColorCyan '║') BepInEx Server Build:" $(check_local_bepinex_build)
echo -ne "
$(ColorCyan '╠═══════════════════════════════════════════════')
$(ColorCyan '║ '"$FUNCTION_HEADER_MENU_INFO_VALHEIM_OFFICIAL_BUILD"'')" $(check_official_valheim_release_build)
echo -ne "
$(ColorCyan '║ '"$FUNCTION_HEADER_MENU_INFO_VALHEIM_LOCAL_BUILD"' ')"        $(check_local_valheim_build)
echo -ne "
$(ColorCyan '╠═══════════════════════════════════════════════')"
echo -ne "
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_SERVER_NAME" ${currentDisplayName}
echo -ne "
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_LD_SEVER_SESSION" ${worldname}
echo -ne " 
$(ColorCyan '║') $(are_you_connected)
$(ColorCyan '║')" $(display_public_IP)
echo -ne "
$(ColorCyan '║')" $(display_local_IP)
echo -ne "
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_SERVER_PORT " ${currentPort}
echo -ne "
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_PUBLIC_LIST " $(display_public_status_on_or_off)
echo -ne "
$(ColorCyan '╠═══════════════════════════════════════════════')
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_CURRENT_NJORD_RELEASE $(check_menu_script_repo)
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_LOCAL_NJORD_VERSION ${mversion}
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_GG_ZEROBANDWIDTH
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_1
$(ColorCyan '╚═══════════════════════════════════════════════')"
}

function menu_header() {
get_current_config
echo -ne "
$(ColorOrange '╔══════════════════════════════════════════════════════════╗')
$(ColorOrange '║~~~~~~~~~~*****~~~~~~~~-Njord Menu-~~~~~~~~~*****~~~~~~~~~║')
$(ColorOrange '╠══════════════════════════════════════════════════════════╝')
$(ColorOrange '║'" $FUNCTION_HEADER_MENU_INFO_VALHEIM_OFFICIAL_BUILD"'')" $(check_official_valheim_release_build)
	echo -ne "
$(ColorOrange '║'" $FUNCTION_HEADER_MENU_INFO_VALHEIM_LOCAL_BUILD"' ') $(check_local_valheim_build)
$(ColorOrange '║')" $FUNCTION_HEADER_MENU_INFO_LD_SEVER_SESSION $(ColorGreen ''"${worldname}"'')
	echo -ne "
$(ColorOrange '║')" $FUNCTION_HEADER_MENU_INFO_SERVER_NAME $(ColorGreen ''"${currentDisplayName}"'')
	echo -ne " 
$(ColorOrange '║') $(are_you_connected)
$(ColorOrange '║')" $(display_public_IP)
	echo -ne "
$(ColorOrange '║')" $(display_local_IP) 
	echo -ne "
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_SERVER_PORT" $(ColorGreen ''"${currentPort}"'')
	echo -ne " 
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_PUBLIC_LIST" $(ColorGreen ''"$(display_public_status_on_or_off)"'')
	echo -ne "
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_SERVER_AT_GLANCE" $(server_status) and $(server_substate)
	echo -ne "
$(ColorOrange '║') Crossplay status:" $(display_crossplay_status)	
echo -ne " 
$(ColorOrange '║') Crossplay Game Code:" $(display_last_join_code)	
echo -ne " 
$(ColorOrange '╠═══════════════════════════════════════════════════════════')"
echo -ne " 
$(ColorOrange '║') Current Players Online:" $(current_player_count)	
echo -ne " 
$(ColorOrange '╠═══════════════════════════════════════════════════════════')"
	echo -ne "
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_SERVER_UFW" $(get_firewall_status)
	echo -ne "
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_SERVER_UFW_SUBSTATE -- substatus" $(get_firewall_substate) 
	echo -ne " 
$(ColorOrange '╠═══════════════════════════════════════════════════════════')"
	echo -ne "
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_CURRENT_NJORD_RELEASE $(ColorGreen ''"$(check_menu_script_repo)"'')
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_LOCAL_NJORD_VERSION $(ColorGreen ''"${mversion}"'')
$(ColorOrange '║ '"$FUNCTION_HEADER_MENU_INFO"'')
$(ColorOrange '║ '"$FUNCTION_HEADER_MENU_INFO_1"'')
$(ColorOrange '║ '"$FUNCTION_HEADER_MENU_INFO_2"'')
$(ColorOrange '╚═══════════════════════════════════════════════════════════')"
}

## Notes: FUNCTION_HEADER_MENU_INFO_SERVER_UFW_SUBSTATE is missing in nls files.

# Sub Server Menu System
function server_install_menu() {
	echo ""
	echo -ne "
$(ColorOrange ''"$FUNCTION_SERVER_INSTALL_MENU_HEADER"'')
$(ColorOrange '-')$(ColorGreen '1)') "$FUNCTION_SERVER_INSTALL_MENU_OPT_1."
$(ColorOrange '-')$(ColorGreen '2)') "Setup another Valheim server on diff port."
$(ColorOrange '-')$(ColorGreen '0)') "$RETURN_MAIN_MENU."
$(ColorOrange ''"$DRAW60"'')
$(ColorPurple ''"$CHOOSE_MENU_OPTION"'') "
    read a
    case $a in
	    1) newinstall="y"
	       valheim_server_install ; 
		   server_install_menu ;;
		2) newinstall="n"
		   valheim_server_install ; 
		   server_install_menu ;;
        0) menu ; menu ;;
		*)  echo -ne " $(ColorRed ''"$WRONG_MENU_OPTION"'')" ; server_install_menu ;;
    esac
}

function firewall_admin_menu() {
	menu_header
	if [ "${usefw}" == "n" ] ; then
		echo ""
		echo "The firewall admin system is not enabled."
		echo "Please open the njordmenu.sh file and modify the header parameters to enable."
		echo "Returning to main menu."
		echo ""
		sleep 2
		menu
	else
		echo -ne "
$(ColorOrange '"╔══Valheim Server Firewall Infomation and control Center═══╗"'')
$(ColorOrange '║~~~~~~~~~~~~~~~~~~')$(ColorLightGreen '-Njord Menu-')$(ColorCyan '~~~~~~~~~~~~~~~~~║')
$(ColorOrange '╠═══════════════════════════════════════════════╝')"
is_admin_firewall_installed
is_admin_firewall_enabled
is_any_firewall_installed
is_any_firewall_enabled
		echo -ne "
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ "FireWallD actions for this Valheim server"'')
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ ')$(ColorGreen '1)') Show system status            
$(ColorOrange '║ ')$(ColorGreen '2)') Show system substate          
$(ColorOrange '║ ')$(ColorGreen '3)') Dump all information on the firewall 
$(ColorOrange '║ ')$(ColorGreen '4)') Add the Steam ports to the firewall
$(ColorOrange '║ ')$(ColorGreen '5)') Remove the Steam ports from the firewall
$(ColorOrange '║ ')$(ColorGreen '6)') Add this Valheim service port to the firewall
$(ColorOrange '║ ')$(ColorGreen '7)') Remove this Valheim service port from the firewall "
		if [ "${fwbeingused}" == "firewalld" ] ; then
		echo -ne "
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange ''"Specifc to FireWallD for this Valheim world."'')
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ ')$(ColorGreen '50)') Create the service file
$(ColorOrange '║ ')$(ColorGreen '51)') Delete the service file
$(ColorOrange '║ ')$(ColorGreen '52)') Add the public service  
$(ColorOrange '║ ')$(ColorGreen '53)') Remove the public service for Valheim server "
		fi
		echo -ne "
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ "To help verify/install perfered firewall system"'')
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ ')$(ColorGreen '100)') Verify/install the perfered firewall system.
$(ColorOrange '║ ')$(ColorGreen '101)') Verify/enable the prefered firewall system.
$(ColorOrange '║ ')$(ColorGreen '102)') Stop all known firewall systems.             
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ ')$(ColorGreen '0)') "$RETURN_MAIN_MENU."
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ "$DRAW60"'')
$(ColorPurple '║ "$CHOOSE_MENU_OPTION"'')
$(ColorPurple '╚═══════════════════════════════════════════════')"
		read a
		case $a in
	    1) get_firewall_status ; firewall_admin_menu ;;
		2) get_firewall_substate ; firewall_admin_menu ;;
		3) get_firewall_info ; firewall_admin_menu ;;
		4) sftc="ste" ; add_Valheim_server_public_ports ; firewall_admin_menu ;;
		5) sftc="ste" ; remove_Valheim_server_public_ports ; firewall_admin_menu ;;
		6) sftc="val" ; add_Valheim_server_public_ports ; firewall_admin_menu ;;
		7) sftc="val" ; remove_Valheim_server_public_ports ; firewall_admin_menu ;;
		50) create_firewalld_service_file ; firewall_admin_menu ;;
		51) delete_firewalld_service_file ; firewall_admin_menu ;;
		52) add_firewalld_public_service ; firewall_admin_menu ;;
		53) remove_firewalld_public_service ; firewall_admin_menu ;;
		100) is_admin_firewall_installed ; firewall_admin_menu ;;
		101) is_admin_firewall_enabled ; firewall_admin_menu ;;
		102) disable_all_firewalls ; firewall_admin_menu ;;
        0) menu ; menu ;;
		*)  echo -ne " $(ColorRed ''"$WRONG_MENU_OPTION"'')" ; firewall_admin_menu ;;
		esac
	fi
}



# Sub Tech Support Menu System
# Options 7 and 8 added. And needs more work.
function tech_support(){
	menu_header
	echo ""
	echo -ne "
$(ColorOrange ''"$FUNCTION_VALHEIM_TECH_SUPPORT_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 1)') $FUNCTION_VALHEIM_TECH_SUPPORT_DISPLAY_CONFIG
$(ColorOrange '-')$(ColorGreen ' 2)') $FUNCTION_VALHEIM_TECH_SUPPORT_DISPLAY_VALHEIM_SERVICE
$(ColorOrange '-')$(ColorGreen ' 3)') $FUNCTION_VALHEIM_TECH_SUPPORT_DISPLAY_WORLD_DATA
$(ColorOrange '-')$(ColorGreen ' 4)') $FUNCTION_VALHEIM_TECH_SUPPORT_DISPLAY_SYSTEM_INFO
$(ColorOrange '-')$(ColorGreen ' 5)') $FUNCTION_VALHEIM_TECH_SUPPORT_DISPLAY_NETWORK_INFO
$(ColorOrange '-')$(ColorGreen ' 6)') $FUNCTION_VALHEIM_TECH_SUPPORT_DISPLAY_CONNECTED_PLAYER_HISTORY
$(ColorOrange '-')$(ColorGreen ' 7)') Show World Seed
$(ColorOrange '-')$(ColorGreen ' 8)') System preformance (TOP)
$(ColorOrange '------------------------------------------------------------')
$(ColorOrange '-')$(ColorGreen ' 0)') "$RETURN_MAIN_MENU"
$(ColorOrange '------------------------------------------------------------')
$(ColorPurple ''"$CHOOSE_MENU_OPTION"'') "
        read a
        case $a in
			1) display_start_valheim ; tech_support ;; 
			2) display_valheim_server_status ; tech_support ;;
	        3) display_world_data_folder ; tech_support ;;
			4) display_system_info ; tech_support ;;
			5) display_network_info ; tech_support ;;
	        6) display_player_history ; tech_support ;;
			7) get_worldseed ; tech_support ;;
			8) top -u steam ; tech_support ;; 			
			0) menu ; menu ;;
		    *)  echo -ne " $(ColorRed ''"$WRONG_MENU_OPTION"'')" ; tech_support ;;
        esac
}

# Display Main Menu System
menu(){
	if [ "${worldname}" = "" ] ; then  set_world_server ; fi
	menu_header
	echo -ne "
$(ColorOrange '-'"$FUNCTION_MAIN_MENU_CHECK_SCRIPT_UPDATES_HEADER"' ')
$(ColorOrange '-')$(ColorGreen ' 1)') $FUNCTION_MAIN_MENU_UPDATE_NJORD_MENU
$(ColorOrange ''"$FUNCTION_MAIN_MENU_SERVER_COMMANDS_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 2)') $FUNCTION_MAIN_MENU_TECH_MENU
$(ColorOrange '-')$(ColorGreen ' 3)') $FUNCTION_MAIN_MENU_INSTALL_VALHEIM
$(ColorOrange ''"$FUNCTION_MAIN_MENU_FIREWALL_VALHEIM_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 4)') $FUNCTION_MAIN_MENU_FIREWALL_VALHEIM
$(ColorOrange ''"$FUNCTION_MAIN_MENU_OFFICAL_VALHEIM_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 5)') $FUNCTION_MAIN_MENU_CHECK_APPLY_VALHEIM_UPDATES
$(ColorOrange ''"$FUNCTION_MAIN_MENU_EDIT_VALHEIM_CONFIG_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 6)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_DISPLAY_CONFIG
$(ColorOrange '-')$(ColorGreen ' 7)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_CHANGE_WORLD_NAME
$(ColorOrange '-')$(ColorGreen ' 8)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_CHANGE_PUBLIC_NAME
$(ColorOrange '-')$(ColorGreen ' 9)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_CHANGE_SERVER_PORT
$(ColorOrange '-')$(ColorGreen ' 10)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_CHANGE_ACCESS_PASS
$(ColorOrange '-')$(ColorGreen ' 11)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_ENABLE_PUBLIC_LISTING
$(ColorOrange '-')$(ColorGreen ' 12)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_DISABLE_PUBLIC_LISTING
$(ColorOrange '-')$(ColorGreen ' 13)') Set Crossplay options
$(ColorOrange ''"$DRAW60"'')
$(ColorOrange '-')$(ColorGreen ' 14)') $FUNCTION_ADMIN_TOOLS_MENU_STOP_SERVICE
$(ColorOrange '-')$(ColorGreen ' 15)') $FUNCTION_ADMIN_TOOLS_MENU_START_SERVICE
$(ColorOrange '-')$(ColorGreen ' 16)') $FUNCTION_ADMIN_TOOLS_MENU_RESTART_SERVICE
$(ColorOrange '-')$(ColorGreen ' 17)') $FUNCTION_ADMIN_TOOLS_MENU_STATUS_SERVICE
$(ColorOrange ''"$DRAW60"'')
$(ColorOrange '-')$(ColorGreen ' 18)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_BACKUP_WORLD_DATA
$(ColorOrange '-')$(ColorGreen ' 19)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_RESTORE_WORLD_DATA
$(ColorOrange ''"$FUNCTION_MAIN_MENU_EDIT_VALHEIM_MODS_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 20)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_MODS_MSG_YES
$(ColorOrange '-')$(ColorGreen ' 21)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_MODS_MSG_YES_BEP
$(ColorOrange ''"$DRAW60"'')
$(ColorOrange '-')$(ColorGreen ' 99)') " $FUNCTION_MAIN_MENU_LD_CHANGE_SESSION_CURRENT_WORLD
[ -f "$worldfilelist" ] || echo -ne "
$(ColorOrange '-')$(ColorGreen ' 0000)') " Upgrade Old Menu to New Njord Menu
echo -ne "
$(ColorOrange ''"$DRAW60"'')
$(ColorGreen ' 0)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_EXIT
$(ColorOrange ''"$DRAW60"'')
$(ColorPurple ''"$CHOOSE_MENU_OPTION"'') "
        read a
        case $a in
			1) script_check_update ; menu ;;
			2) tech_support ; menu ;;
			3) server_install_menu ; menu ;;
			4) firewall_admin_menu ; menu ;; 
			5) confirm_check_apply_server_updates ; menu ;;	
			6) display_full_config ; echo "BACK TO MENU IN 5 SECONDS" ; sleep 5 ; menu ;;
			7) change_local_world_name ; menu ;;
			8) change_public_display_name ; menu ;;		
			9) change_default_server_port ; menu ;;
			10) change_server_access_password ; menu ;;
			11) write_public_on_config_and_restart ; menu ;;
			12) write_public_off_config_and_restart ; menu ;;
			13) change_crossplay_status ; menu ;;
			14) stop_valheim_server ; menu ;;
			15) start_valheim_server ; menu ;;
			16) restart_valheim_server ; menu ;;
			17) display_valheim_server_status ; menu ;;
			18) backup_world_data ; menu ;;
			19) restore_world_data ; menu ;;
			20) mods_menu ; mods_menu ;;
			21) bepinex_menu ; bepinex_menu ;;			
			99) request99="y" ; set_world_server ; menu ;;
			0000) get_current_config_upgrade_menu ; menu ;;
			0) exit 0 ;;
			*)  echo -ne " $(ColorRed 'Wrong option.')" ; menu ;;
        esac
}
# Call the menu function or the shortcut called in arg
if [ $# = 0 ]; then
    menu
else
    case "$1" in
    start)   start_valheim_server ;;
    stop)    stop_valheim_server  ;;
    restart) restart_valheim_server ;;
    update)  check_apply_server_updates_beta ;;
    backup)  backup_world_data ;;
    status)  display_valheim_server_status ;;
    *)
        menu
        ;;
    esac
fi 
########################################################################
####################### MENU SECTION END         #######################
########################################################################
