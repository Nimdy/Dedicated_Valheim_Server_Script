#!/bin/bash
###############################################################################################
###############################################################################################
####
#### File name: server.sh
####
###############################################################################################
#### Server installation and management functions for Valheim server
#### Handles installation, updating, and service control for the Valheim dedicated server
###############################################################################################

########################################################################
#################### Server Installation Functions #####################
########################################################################

# Create steam account for server operation
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

# Install steamcmd client based on OS type
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

# Update system packages and install required dependencies
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

# Download and install Valheim from Steam
function nocheck_valheim_update_install() {
    # Set Steam executable and update/install Valheim
    tput setaf 1; echo "$INSTALL_BUILD_DOWNLOAD_INSTALL_STEAM_VALHEIM"; tput setaf 9;
    sleep 1

    # Execute the steamcmd command to install/update Valheim
    $steamexe +login anonymous +force_install_dir "${valheimInstallPath}/${worldname}" +app_update 896660 validate +exit

    tput setaf 2; echo "$ECHO_DONE"; tput setaf 9;
}

# Get server configuration parameters from user
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

# Create configuration and environment files with permissions
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

# Main server installation function
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
################# Server Service Management Functions ##################
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

# Display Valheim configuration file
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

########################################################################
################## Server Configuration Management #####################
########################################################################

# Get current server configuration values
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

# Print the current configuration
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

# Set default configuration values
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

# Write configuration to file and restart the server
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

# Change the server's public display name
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

# Change crossplay settings
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
}

# Change the server port
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

# Change server password
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

# Set public listing to On
function write_public_on_config_and_restart() {
    get_current_config
    set_config_defaults
    setCurrentPublicSet=1
    write_config_and_restart
}

# Set public listing to Off
function write_public_off_config_and_restart() {
    get_current_config
    set_config_defaults
    setCurrentPublicSet=0
    write_config_and_restart
}

# Display full current configuration
function display_full_config() {
    get_current_config
    print_current_config
}

########################################################################
################ Server Update and Maintenance Functions ###############
########################################################################

# Apply Valheim Updates
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

# Check for and apply server updates (beta version)
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

# Confirm and check for server updates
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

# Check official Valheim release version
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

# Check local Valheim build version
function check_local_valheim_build() {
    localValheimAppmanifest=${valheimInstallPath}/${worldname}/steamapps/appmanifest_896660.acf
    if [[ -e $localValheimAppmanifest ]]; then
        localValheimBuild=$(grep buildid ${localValheimAppmanifest} | cut -d'"' -f4)
        echo $localValheimBuild
    else 
        echo "$NO_DATA";
    fi
}

# Function to upgrade from old menu structure to new structure
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

# Function to check and display crossplay status
function display_crossplay_status() {
    currentCrossplayStatus=$(perl -n -e '/\-crossplay "?([^"]+)"?$/ && print "$1\n"' ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh)
    if [ "$currentCrossplayStatus" == "1" ]; then 
        echo "$(ColorGreen 'Enabled')"
    else
        echo "$(ColorRed 'Disabled')"
    fi
}

# Function to display public status (on/off)
function display_public_status_on_or_off() {
    currentPublicStatus=$(perl -n -e '/\-public "([0-1])"? \-savedir/ && print "$1\n"' ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh)
    if [[ $currentPublicStatus == 1 ]]; then 
        echo "$ECHO_ON"
    else
        echo "$ECHO_OFF"
    fi
}