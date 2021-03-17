#!/bin/bash
# Thank you for using the menu script, this started out as just me and blew up quickly.
# If Frankenstein was a bash script, this is what you would get, so please help me improve it.
# Feel free to use and change this as you wish just not for profit. 
# If you need anything, please visit our Discord Server: https://discord.gg/ejgQUfc
# GLHF




#Current Options: DE=German, EN=English, FR=French, SP=Spanish"
if [ "$1" == "" ]
then
        LANGUAGE=EN
else
        LANGUAGE=DE
fi
source lang/$LANGUAGE.conf


# Sanity Check
#    #######################################################
echo "$(tput setaf 4)"$DRAW60""
echo "$(tput setaf 0)$(tput setab 7)"$CHECKSUDO"$(tput sgr 0)"
echo "$(tput setaf 0)$(tput setab 7)"$CHECKSUDO1"$(tput sgr 0)"    
echo "$(tput setaf 4)"$DRAW60""
#    ###################################################### 
[[ "$EUID" -eq 0 ]] || exec sudo "$0" "$@"


clear
###############################################################
#Only change this if you know what you are doing
#Valheim Server Install location(Default) 
valheimInstallPath=/home/steam/valheimserver
#Valheim World Data Path(Default)
worldpath=/home/steam/.config/unity3d/IronGate/Valheim/worlds
#Backup Directory ( Default )
backupPath=/home/steam/backups
###############################################################

# Set Menu Version for menu display
mversion="2.1.8-Lofn"


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
CLEAR='\e[0m'

##
# Color Functions
##
ColorRed(){ 
        echo -ne $RED$1$CLEAR 
}
ColorGreen(){
         echo -ne $GREEN$1$CLEAR
}
ColorOrange(){
	echo -ne $ORANGE$1$CLEAR
}
ColorBlue(){
	echo -ne $BLUE$1$CLEAR
}
ColorPurple(){
	echo -ne $PURPLE$1$CLEAR
}
ColorCyan(){
	echo -ne $CYAN$1$CLEAR
}
ColorLightRed(){
	echo -ne $LIGHTRED$1$CLEAR
}
ColorLightGreen(){
	echo -ne $LIGHTGREEN$1$CLEAR
}
ColorYellow(){
	echo -ne $LIGHTYELLOW$1$CLEAR
}
ColorWhite(){
	echo -ne $WHITE$1$CLEAR
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
#Look for updates from repo tag
    git fetch
      [ -n "$(git diff --name-only "$UPSTREAM" "$SCRIPTFILE")" ] && {
      echo "$GIT_ECHO_CHECK"
      sleep 1
        git pull --force
	git stash
        git checkout "$BRANCH"
        git pull --force
	echo "$GIT_ECHO_UPDATING"
      	sleep 1
	chmod +x menu.sh
	sleep 1
	chmod +x advancemenu.sh
	sleep 1
        exec "$SCRIPTNAME" "${ARGS[@]}"

        # Now exit this old instance
        exit 1
    }
   echo "$GIT_ECHO_NO_UPDATES"
}




########################################################################
########################Install Valheim Server##########################
########################################################################

function valheim_server_install() {
    clear
    echo ""
    echo -ne "
$(ColorOrange ''"$INSTALLVALSERVER"'')
$(ColorRed ''"$DRAW60"'')"
echo ""
tput setaf 2; echo "$CONFIRMVALINSTALL" ; tput setaf 9; 
tput setaf 2; echo "$CONFIRMVALINSTALL_1" ; tput setaf 9; 
echo -ne "
$(ColorRed ''"$DRAW60"'')"
echo ""
 read -p "$PLEASE_CONFIRM" confirmStartInstall
#if y, then continue, else cancel
        if [ "$confirmStartInstall" == "y" ]; then
    echo ""

#check for updates and upgrade the system auto yes
    tput setaf 1; echo "$CHECK_FOR_UPDATES" ; tput setaf 9;
    apt update && apt upgrade -y
    tput setaf 2; echo "$ECHO_DONE" ; tput setaf 9;
    sleep 1
    
#check for updates and upgrade the system auto yes WTF is curl not installed by default... come on man!
    tput setaf 1; echo "$INSTALL_ADDITIONAL_FILES" ; tput setaf 9;
    apt install git mlocate net-tools unzip curl -y
    tput setaf 2; echo "$ECHO_DONE" ; tput setaf 9;
    sleep 1
    
#install software-properties-common for add-apt-repository command below
    tput setaf 1; echo "$INSTALL_SPCP" ; tput setaf 9;
    apt install software-properties-common
    tput setaf 2; echo "$ECHO_DONE" ; tput setaf 9;
    sleep 1

#add multiverse repo
    tput setaf 1; echo "$ADD_MULTIVERSE" ; tput setaf 9;
    add-apt-repository -y multiverse
    tput setaf 2; echo "$ECHO_DONE" ; tput setaf 9;
    sleep 1

#add i386 architecture
    tput setaf 1; echo "$ADD_I386" ; tput setaf 9;
    dpkg --add-architecture i386
    tput setaf 2; echo "$ECHO_DONE" ; tput setaf 9;
    sleep 1

#update system again
    tput setaf 1; echo "$CHECK_FOR_UPDATES_AGAIN" ; tput setaf 9;
    apt update
    tput setaf 2; echo "$ECHO_DONE" ; tput setaf 9;
    sleep 1

# Linux Steam Local Account Password input
    echo ""
    clear
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
            [[ ${#userpassword} -ge 6 && "$userpassword" == *[[:lower:]]* && "$userpassword" == *[[:upper:]]* && "$userpassword" =~ ^[[:alnum:]]+$ ]] && break
      tput setaf 2; echo "$STEAM_PASS_NOT_ACCEPTED" ; tput setaf 9;
      tput setaf 2; echo "$STEAM_PASS_NOT_ACCEPTED_1" ; tput setaf 9;
    done
    clear
    echo ""
# Take user input for Valheim Server Public Display
    echo ""
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 2; echo "$PUBLIC_SERVER_DISPLAY_NAME" ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 1; echo "$PUBLIC_SERVER_DISPLAY_NAME_1" ; tput setaf 9;
    tput setaf 1; echo "$PUBLIC_SERVER_DISPLAY_NAME_2" ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 2; echo "$PUBLIC_SERVER_DISPLAY_GOOD_EXAMPLE" ; tput setaf 9;
    tput setaf 2; echo "$PUBLIC_SERVER_DISPLAY_GOOD_EXAMPLE_1" ; tput setaf 9;
    tput setaf 1; echo "$PUBLIC_SERVER_DISPLAY_BAD_EXAMPLE" ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    echo ""
      read -p "$PUBLIC_SERVER_ENTER_NAME" displayname
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    echo ""
    clear
# Take user input for Valheim Server World Database Generation
    echo ""
     while true; do
        tput setaf 2; echo "$DRAW60" ; tput setaf 9;
        tput setaf 2; echo "$WORLD_SET_WORLD_NAME_HEADER" ; tput setaf 9;
        tput setaf 2; echo "$DRAW60" ; tput setaf 9;
        tput setaf 1; echo "$WORLD_SET_CHAR_RULES" ; tput setaf 9;
        tput setaf 1; echo "$WORLD_SET_NO_SPECIAL_CHAR_RULES" ; tput setaf 9;
	tput setaf 2; echo "$DRAW60" ; tput setaf 9;
	tput setaf 2; echo "$WORLD_GOOD_EXAMPLE" ; tput setaf 9;
        tput setaf 1; echo "$WORLD_BAD_EXAMPLE" ; tput setaf 9;
	tput setaf 2; echo "$DRAW60" ; tput setaf 9;
	echo ""
        read -p "$WORLD_SET_WORLD_NAME_VAR" worldname
	tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
            [[ ${#worldname} -ge 4 && "$worldname" =~ ^[[:alnum:]]+$ ]] && break
        tput setaf 2; echo "$WORLD_SET_ERROR" ; tput setaf 9; 
	tput setaf 2; echo "$WORLD_SET_ERROR_1" ; tput setaf 9; 
    done
    clear
    echo ""
# Take user input for Valheim Server password
# Added security for harder passwords
    echo ""        
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 2; echo "$SERVER_ACCESS_PASS_HEADER" ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 1; echo "$SERVER_ACCESS_INFO" ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 2; echo "$SERVER_ACCESS_PUBLIC_NAME_INFO $displayname " ; tput setaf 9;
    tput setaf 2; echo "$SERVER_ACCESS_WORLD_NAME_INFO $worldname " ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    while true; do
    tput setaf 1; echo "$SERVER_ACCESS_WARN_INFO" ; tput setaf 9;
    tput setaf 1; echo "$SERVER_ACCESS_WARN_INFO_1" ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 2; echo "$SERVER_ACCESS_GOOD_EXAMPLE" ; tput setaf 9;
    tput setaf 1; echo "$SERVER_ACCESS_BAD_EXAMPLE" ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    read -p "$SERVER_ACCESS_ENTER_PASSWORD" password
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
        [[ ${#password} -ge 5 && "$password" == *[[:lower:]]* && "$password" == *[[:upper:]]* && "$password" =~ ^[[:alnum:]]+$ ]] && break
    tput setaf 2; echo "$SERVER_ACCESS_PASSWORD_ERROR" ; tput setaf 9;
    tput setaf 2; echo "$SERVER_ACCESS_PASSWORD_ERROR_1" ; tput setaf 9;
    done
        # Take user input to Show Server Public
    echo ""
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 2; echo "$PUBLIC_ENABLED_DISABLE_HEADER" ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 1; echo "$PUBLIC_ENABLED_DISABLE_INFO" ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 2; echo "$PUBLIC_ENABLED_DISABLE_EXAMPLE_SHOW" ; tput setaf 9;
    tput setaf 1; echo "$PUBLIC_ENABLED_DISABLE_EXAMPLS_LAN_NO_SHOW" ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    echo ""
      read -p "$PUBLIC_ENABLED_DISABLE_INPUT" publicList
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    echo ""


echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_HEADER"
tput setaf 2; echo "$DRAW60" ; tput setaf 9;
tput setaf 2; echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_STEAM_PASSWORD $userpassword " ; tput setaf 9;
tput setaf 2; echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_SERVER_NAME $displayname " ; tput setaf 9;
tput setaf 2; echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_WORLD_NAME $worldname " ; tput setaf 9;
tput setaf 2; echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_ACCESS_PASS $password " ; tput setaf 9; 
tput setaf 2; echo "$CREDS_DISPLAY_CREDS_PRINT_OUT_SHOW_PUBLIC $publicList " ; tput setaf 9; 
tput setaf 2; echo "$DRAW60" ; tput setaf 9;
echo ""
sleep 5

#install steamcmd and libsd12-2
tput setaf 1; echo "$INSTALL_STEAMCMD_LIBSD12" ; tput setaf 9;
echo steam steam/question select "I AGREE" | sudo debconf-set-selections
echo steam steam/license note '' | sudo debconf-set-selections
apt install steamcmd libsdl2-2.0-0 libsdl2-2.0-0:i386 -y
tput setaf 2; echo "$ECHO_DONE" ; tput setaf 9;
sleep 1
#EDIT HERE #1
#build account to run Valheim
tput setaf 1; echo "$INSTALL_BUILD_NON_ROOT_STEAM_ACCOUNT" ; tput setaf 9;
sleep 1
useradd --create-home --shell /bin/bash --password $userpassword steam
cp /etc/skel/.bashrc /home/steam/.bashrc
cp /etc/skel/.profile /home/steam/.profile
tput setaf 2; echo "$ECHO_DONE" ; tput setaf 9;
sleep 1
echo "$DRAW60" >> /home/steam/serverSetup.txt
echo $CREDS_DISPLAY_CREDS_PRINT_OUT_STEAM_PASSWORD $userpassword >> /home/steam/serverSetup.txt
echo $CREDS_DISPLAY_CREDS_PRINT_OUT_SERVER_NAME $displayname >> /home/steam/serverSetup.txt
echo $CREDS_DISPLAY_CREDS_PRINT_OUT_WORLD_NAME $worldname >> /home/steam/serverSetup.txt
echo $CREDS_DISPLAY_CREDS_PRINT_OUT_ACCESS_PASS $password >> /home/steam/serverSetup.txt
echo $CREDS_DISPLAY_CREDS_PRINT_OUT_SHOW_PUBLIC $publicList >> /home/steam/serverSetup.txt
echo "$DRAW60" >> /home/steam/serverSetup.txt
sleep 1
chown steam:steam /home/steam/serverSetup.txt
clear
#build symbolic link for steamcmd
tput setaf 1; echo "$INSTALL_BUILD_SYM_LINK_STEAMCMD" ; tput setaf 9;
ln -s /usr/games/steamcmd /home/steam/steamcmd
tput setaf 2; echo "$ECHO_DONE" ; tput setaf 9;
sleep 1
#chown steam user to steam
tput setaf 1; echo "$INSTALL_BUILD_SET_STEAM_PERM" ; tput setaf 9;
chown steam:steam -Rf /home/steam/*
tput setaf 2; echo "$ECHO_DONE" ; tput setaf 9;
sleep 1
#Download Valheim from steam
tput setaf 1; echo "$INSTALL_BUILD_DOWNLOAD_INSTALL_STEAM_VALHEIM" ; tput setaf 9;
sleep 1
/home/steam/steamcmd +login anonymous +force_install_dir ${valheimInstallPath} +app_update 896660 validate +exit
tput setaf 2; echo "$ECHO_DONE" ; tput setaf 9;
sleep 1
#build config for start_valheim.sh
tput setaf 1; echo "$INSTALL_BUILD_DELETE_OLD_CONFIGS" ; tput setaf 9;  
tput setaf 1; echo "$INSTALL_BUILD_DELETE_OLD_CONFIGS_1" ; tput setaf 9;
[ -e ${valheimInstallPath}/start_valheim.sh ] && rm ${valheimInstallPath}/start_valheim.sh
sleep 1
cat >> ${valheimInstallPath}/start_valheim.sh <<EOF
#!/bin/bash
export templdpath=\$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:\$LD_LIBRARY_PATH
export SteamAppId=892970
# Tip: Make a local copy of this script to avoid it being overwritten by steam.
# NOTE: Minimum password length is 5 characters & Password cant be in the server name.
# NOTE: You need to make sure the ports 2456-2458 is being forwarded to your server through your local router & firewall.
./valheim_server.x86_64 -name "${displayname}" -port "2456" -nographics -batchmode -world "${worldname}" -password "${password}" -public "${publicList}"
export LD_LIBRARY_PATH=\$templdpath
EOF
tput setaf 2; echo "$ECHO_DONE" ; tput setaf 9;
sleep 1
#delete old check log script, not required any longer.
tput setaf 1; echo "$INSTALL_BUILD_DELETE_OLD_SCRIPT" ; tput setaf 9; 
[ -e /home/steam/check_log.sh ] && rm /home/steam/check_log.sh
#set execute permissions
tput setaf 1; echo "$INSTALL_BUILD_SET_PERM_ON_START_VALHEIM" ; tput setaf 9;
chmod +x ${valheimInstallPath}/start_valheim.sh
tput setaf 2; echo "$ECHO_DONE" ; tput setaf 9;
sleep 1
#build systemctl configurations for execution of processes for Valheim Server
tput setaf 1; echo "$INSTALL_BUILD_DEL_OLD_SERVICE_CONFIG" ; tput setaf 9; 
tput setaf 1; echo "$INSTALL_BUILD_DEL_OLD_SERVICE_CONFIG_1" ; tput setaf 9; 
# remove old Valheim Server Service
[ -e /etc/systemd/system/valheimserver.service ] && rm /etc/systemd/system/valheimserver.service
# remove past Valheim Server Service
[ -e /lib/systemd/system/valheimserver.service ] && rm /lib/systemd/system/valheimserver.service
sleep 1
# Add new Valheim Server Service
# Thanks @QuadeHale
cat >> /lib/systemd/system/valheimserver.service <<EOF
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
ExecStartPre=/home/steam/steamcmd +login anonymous +force_install_dir ${valheimInstallPath} +app_update 896660 validate +exit
ExecStart=${valheimInstallPath}/start_valheim.sh
ExecReload=/bin/kill -s HUP \$MAINPID
KillSignal=SIGINT
WorkingDirectory=${valheimInstallPath}
LimitNOFILE=100000
[Install]
WantedBy=multi-user.target
EOF
tput setaf 2; echo "$ECHO_DONE" ; tput setaf 9;
sleep 1
#chown steam user permissions to all of user steam dir location
tput setaf 1; echo "$INSTALL_BUILD_SET_STEAM_PERMS" ; tput setaf 9; 
chown steam:steam -Rf /home/steam/*
tput setaf 2; echo "$ECHO_DONE" ; tput setaf 9;
sleep 1
# Reload daemons
tput setaf 1; echo "$INSTALL_BUILD_RELOAD_DAEMONS" ; tput setaf 9; 
systemctl daemon-reload
tput setaf 2; echo "$ECHO_DONE" ; tput setaf 9; 
sleep 1
# Start server
tput setaf 1; echo "$INSTALL_BUILD_START_VALHEIM_SERVICE" ; tput setaf 9; 
systemctl start valheimserver.service
tput setaf 2; echo "$ECHO_DONE" ; tput setaf 9; 
sleep 1
# Enable server on restarts
tput setaf 1; echo "$INSTALL_BUILD_ENABLE_VALHEIM_SERVICE" ; tput setaf 9; 
systemctl enable valheimserver.service
tput setaf 2; echo "$ECHO_DONE" ; tput setaf 9; 
sleep 2
clear
tput setaf 2; echo "$INSTALL_BUILD_FINISH_THANK_YOU" ; tput setaf 9;
echo ""
  
    echo ""    
    else
        echo "$INSTALL_BUILD_CANCEL"
fi
}
########################################################################
###################Backup World DB and FWL Files########################
########################################################################
function backup_world_data() {
    echo ""
    echo ""
    #read user input confirmation
      tput setaf 1; echo "$BACKUP_WORLD_DATA_HEADER" ; tput setaf 9;
      tput setaf 1; echo "$BACKUP_WORLD_INFO_CONFIRM" ; tput setaf 9;
         read -p "$BACKUP_WORLD_INPUT_CONFIRM_Y_N" confirmBackup
         #if y, then continue, else cancel
         if [ "$confirmBackup" == "y" ]; then
         ## Get the current date as variable.
         TODAY="$(date +%Y-%m-%d-%T)"
	 tput setaf 5; echo "$BACKUP_WORLD_CHECK_DIRECTORY" ; tput setaf 9;
	 tput setaf 5; echo "$BACKUP_WORLD_CHECK_DIRECTORY_1" ; tput setaf 9;
	 dldir=$backupPath
	 [ ! -d "$dldir" ] && mkdir -p "$dldir"
         sleep 1
         ## Clean up files older than 2 weeks. Create a new backup.
	 tput setaf 1; echo "$BACKUP_WORLD_CONDUCT_CLEANING" ; tput setaf 9;
         find $backupPath/* -mtime +14 -type f -delete
	 tput setaf 2; echo "$BACKUP_WORLD_CONDUCT_CLEANING_LOKI" ; tput setaf 9;
         sleep 1
         ## Tar Section. Create a backup file, with the current date in its name.
         ## Add -h to convert the symbolic links into a regular files.
         ## Backup some system files, also the entire `/home` directory, etc.
         ##--exclude some directories, for example the the browser's cache, `.bash_history`, etc.
	  #stop valheim server
         tput setaf 1; echo "$BACKUP_WORLD_STOPPING_SERVICES" ; tput setaf 9;
         systemctl stop valheimserver.service
         tput setaf 1; echo "$BACKUP_WORLD_STOP_INFO" ; tput setaf 9;
	 tput setaf 2; echo "$BACKUP_WORLD_STOP_INFO_1" ; tput setaf 9;
	 tput setaf 2; echo "$BACKUP_WORLD_STOP_WAIT_10_SEC" ; tput setaf 9;
         #give it a few
         sleep 10
	 tput setaf 1; echo "$BACKUP_WORLD_MAKING_TAR" ; tput setaf 9;
         tar czf $backupPath/valheim-backup-$TODAY.tgz $worldpath/*
	 tput setaf 2; echo "$BACKUP_WORLD_MAKING_TAR_COMPLETE" ; tput setaf 9;
	 sleep 1
	 tput setaf 2; echo "$BACKUP_WORLD_RESTARTING_SERVICES" ; tput setaf 9;
         systemctl start valheimserver.service
         tput setaf 2; echo "$BACKUP_WORLD_RESTARTING_SERVICES_1" ; tput setaf 9;
	 echo ""
	 tput setaf 2; echo "$BACKUP_WORLD_SET_PERMS_FILES" ; tput setaf 9;
	 chown -Rf steam:steam ${backupPath}
	 tput setaf 2; echo "$BACKUP_WORLD_PROCESS_COMPLETE" ; tput setaf 9;
    echo ""
 else 
   tput setaf 3; echo "$BACKUP_WORLD_PROCESS_CANCELED" ; tput setaf 9;
 fi
}
########################################################################
##################Restore World Files DB and FWL########################
########################################################################
# Thanks to GITHUB @LachlanMac and @Kurt
function restore_world_data() {
#init empty array
    declare -a backups
#loop through backups and put in array
    for file in ${backupPath}/*.tgz
    do
        backups=(${backups[*]} "$file")
    done;
#counter index
    bIndex=1
    for item in "${backups[@]}";do
 #print option [index]> [file name]
        basefile=$(basename "$item")
         echo "$bIndex> ${basefile} "
#increment
    bIndex=$((bIndex+1))
    done
#promt user for index
tput setaf 2; echo "$RESTORE_WORLD_DATA_HEADER" ; tput setaf 9;
tput setaf 2; echo "$RESTORE_WORLD_DATA_CONFIRM" ; tput setaf 9;
    read -p "$RESTORE_WORLD_DATA_SELECTION" selectedIndex
#show confirmation message
restorefile=$(basename "${backups[$selectedIndex-1]}")
echo -ne "
$(ColorRed '------------------------------------------------------------')
$(ColorGreen ' '"$RESTORE_WORLD_DATA_SHOW_FILE"' '${restorefile}' ?')
$(ColorGreen ' '"$RESTORE_WORLD_DATA_ARE_YOU_SURE"' ')
$(ColorOrange ' '"$RESTORE_WORLD_DATA_VALIDATE_DATA_WITH_CONFIG"' '${valheimInstallPath}'/start_valheim.sh')
$(ColorOrange ' '"$RESTORE_WORLD_DATA_INFO"' ')
$(ColorGreen ' '"$RESTORE_WORLD_DATA_CONFIRM_1"' ') "
#read user input confirmation
    read -p "" confirmBackupRestore
#if y, then continue, else cancel
        if [ "$confirmBackupRestore" == "y" ]; then
 #stop valheim server
        tput setaf 1; echo "$RESTORE_WORLD_DATA_STOP_VALHEIM_SERVICE" ; tput setaf 9;
        systemctl stop valheimserver.service
        tput setaf 2; echo "$RESTORE_WORLD_DATA_STOP_VALHEIM_SERVICE_1" ; tput setaf 9;
 #give it a few
        sleep 5
 #copy backup to worlds folder
        tput setaf 2; echo "$RESTORE_WORLD_DATA_COPYING ${backups[$selectedIndex-1]} to ${worldpath}/" ; tput setaf 9;
        cp ${backups[$selectedIndex-1]} ${worldpath}/
 #untar
        tput setaf 2; echo "$RESTORE_WORLD_DATA_UNPACKING ${worldpath}/${restorefile}" ; tput setaf 9;
        tar xzf ${worldpath}/${restorefile} --strip-components=7 --directory ${worldpath}/  
	chown -Rf steam:steam ${worldpath}
	rm  ${worldpath}/*.tgz
        tput setaf 2; echo "$RESTORE_WORLD_DATA_STARTING_VALHEIM_SERVICES" ; tput setaf 9;
        tput setaf 2; echo "$RESTORE_WORLD_DATA_CUSS_LOKI" ; tput setaf 9;
        systemctl start valheimserver.service
else
        tput setaf 2; echo "$RESTORE_WORLD_DATA_CANCEL_CUSS_LOKI" ; tput setaf 9;
fi
}

########################################################################
#############Install Official Update of Valheim Updates#################
########################################################################
function continue_with_valheim_update_install() {
    clear
    echo ""
    echo -ne "
$(ColorOrange ''"$FUNCTION_INSTALL_VALHEIM_UPDATES"'')
$(ColorRed ''"$DRAW60"'')"
echo ""
tput setaf 2; echo "$FUNCTION_INSTALL_VALHEIM_FOUND" ; tput setaf 9;
tput setaf 2; echo "$FUNCTION_INSTALL_VALHEIM_UPDATE_INFO" ; tput setaf 9; 
tput setaf 2; echo "$FUNCTION_INSTALL_VALHEIM_UPDATE_CONFIRM" ; tput setaf 9; 
echo -ne "
$(ColorRed ''"$DRAW60"'')"
echo ""
 read -p "$PLEASE_CONFIRM" confirmOfficialUpdates
#if y, then continue, else cancel
if [ "$confirmOfficialUpdates" == "y" ]; then
    tput setaf 2; echo "$FUNCTION_INSTALL_VALHEIM_UPDATE_APPLY_INFO" ; tput setaf 9; 
    /home/steam/steamcmd +login anonymous +force_install_dir ${valheimInstallPath} +app_update 896660 validate +exit
    chown -R steam:steam ${valheimInstallPath}
    echo ""
else
    echo "$FUNCTION_INSTALL_VALHEIM_UPDATES_CANCEL"
    sleep 3
    clear
fi
}
########################################################################
######################beta updater for Valheim##########################
########################################################################
#function check_apply_server_updates_beta() {
#    echo ""
#    echo "Downloading Official Valheim Repo Log Data for comparison only"
#      repoValheim=$(/home/steam/steamcmd +login anonymous +app_info_update 1 +app_info_print 896660 +quit | grep -A10 branches | grep -A2 public | grep buildid | cut -d'"' -f4)
#      echo "Official Valheim-: $repoValheim"
#      localValheim=$(grep buildid ${valheimInstallPath}/steamapps/appmanifest_896660.acf | cut -d'"' -f4)
#      echo "Local Valheim Ver: $localValheim"
#      if [ "$repoValheim" == "$localValheim" ]; then
#        echo "No new Updates found"
#	sleep 2
#	else
#	echo "Update Found kicking process to Odin for updating!"
#	sleep 2
#        continue_with_valheim_update_install
#        echo ""
#     fi
#     echo ""
#}

function check_apply_server_updates_beta() {
    echo ""
    echo "$FUNCTION_APPLY_SERVER_UPDATES"
      [ ! -d /opt/valheimtemp ] && mkdir -p /opt/valheimtemp
      /home/steam/steamcmd +login anonymous +force_install_dir /opt/valheimtemp +app_update 896660 validate +exit
      sed -e 's/[\t ]//g;/^$/d' /opt/valheimtemp/steamapps/appmanifest_896660.acf > appmanirepo.log
      repoValheim=$(sed -n '11p' appmanirepo.log)
      echo "$FUNCTION_APPLY_SERVER_UPDATES_OFFICIAL_VALHEIM_REPO $repoValheim"
      sed -e 's/[\t ]//g;/^$/d' ${valheimInstallPath}/steamapps/appmanifest_896660.acf > appmanilocal.log
      localValheim=$(sed -n '11p' appmanilocal.log)
      echo "$FUNCTION_APPLY_SERVER_UPDATES_OFFICIAL_VALHEIM_LOCAL $localValheim"
      if [ "$repoValheim" == "$localValheim" ]; then
        echo "$FUNCTION_APPLY_SERVER_UPDATES_NO"
        echo "$FUNCTION_APPLY_SERVER_UPDATES_CLEAN_TMP"
        rm -Rf /opt/valheimtemp
        rm appmanirepo.log
        rm appmanilocal.log
    sleep 2
    else
    echo "$FUNCTION_APPLY_SERVER_UPDATES_INFO"
    sleep 2
        continue_with_valheim_update_install
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
$(ColorRed ''"$DRAW60"'')"
echo ""
tput setaf 2; echo "$FUNCTION_CONFIRM_CHECK_APPLY_SERVER_UPDATES_INFO" ; tput setaf 9;
tput setaf 2; echo "$FUNCTION_CONFIRM_CHECK_APPLY_SERVER_UPDATES_INFO_1" ; tput setaf 9;
tput setaf 2; echo "$FUNCTION_CONFIRM_CHECK_APPLY_SERVER_UPDATES_INFO_2" ; tput setaf 9;
tput setaf 2; echo "$PLEASE_CONFIRM" ; tput setaf 9;
echo -ne "
$(ColorRed '------------------------------------------------------------')"
echo ""
tput setaf 2; read -p "$FUNCTION_CONFIRM_CHECK_APPLY_SERVER_UPDATES_CONTINUE" yn ; tput setaf 9; 
echo -ne "
$(ColorRed '------------------------------------------------------------')"
    case $yn in
        [Yy]* ) check_apply_server_updates_beta; break;;
        [Nn]* ) break;;
        * ) echo "$PLEASE_CONFIRM";;
    esac
done
}
########################################################################
###############Display Valheim Start Configuration######################
########################################################################
function display_start_valheim() {
    clear
    echo ""
    sudo cat ${valheimInstallPath}/start_valheim.sh
    echo ""
}
########################################################################
###############Display Valheim World Data Folder########################
########################################################################
function display_world_data_folder() {
    clear
    echo ""
    sudo ls -lisa $worldpath
    echo ""
}
########################################################################
######################Stop Valheim Server Service#######################
########################################################################
function stop_valheim_server() {
    clear
    echo ""
    echo -ne "
$(ColorOrange ''"$FUNCTION_STOP_VALHEIM_SERVER_SERVICE_HEADER"'')
$(ColorRed ''"$DRAW60"'')"
echo ""
tput setaf 2; echo "$FUNCTION_STOP_VALHEIM_SERVER_SERVICE_INFO" ; tput setaf 9; 
tput setaf 2; echo "$FUNCTION_STOP_VALHEIM_SERVER_SERVICE_INFO_1" ; tput setaf 9; 
echo -ne "
$(ColorRed ''"$DRAW60"'')"
echo ""
 read -p "$PLEASE_CONFIRM" confirmStop
#if y, then continue, else cancel
        if [ "$confirmStop" == "y" ]; then
    echo ""
    echo "$FUNCTION_STOP_VALHEIM_SERVER_SERVICE_STOPPING"
    sudo systemctl stop valheimserver.service
    echo ""
    else
    echo "$FUNCTION_STOP_VALHEIM_SERVER_SERVICE_CANCEL"
    sleep 3
    clear
fi
}
########################################################################
###################Start Valheim Server Service#########################
########################################################################
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
    sudo systemctl start valheimserver.service
    echo ""
    else
        echo "$FUNCTION_START_VALHEIM_SERVER_SERVICE_CANCEL"
        sleep 3
    clear
fi
}
########################################################################
####################Restart Valheim Server Service######################
########################################################################
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
    sudo systemctl restart valheimserver.service
    echo ""
    else
        echo "$FUNCTION_RESTART_VALHEIM_SERVICE_SERVICE_CANCEL"
        sleep 3
    clear
fi
}
########################################################################
#####################Display Valheim Server Status######################
########################################################################
function display_valheim_server_status() {
    clear
    echo ""
    sudo systemctl status --no-pager -l valheimserver.service
    echo ""
}
########################################################################
##############Display Valheim Vanilla Configuration File################
########################################################################
function display_start_valheim() {
    clear
    echo ""
    sudo cat ${valheimInstallPath}/start_valheim.sh
    echo ""
}
########################################################################
#######################Sub Server Menu System###########################
########################################################################
function server_install_menu() {
echo ""
echo -ne "

$(ColorOrange ''"$FUNCTION_SERVER_INSTALL_MENU_HEADER"'')
$(ColorOrange '-')$(ColorGreen '1)') '"$FUNCTION_SERVER_INSTALL_MENU_OPT_1"'
$(ColorOrange '-')$(ColorGreen '0)') '"$RETURN_MAIN_MENU"'
$(ColorOrange ''"$DRAW60"'')
$(ColorPurple ''"$CHOOSE_MENU_OPTION"'') "
        read a
        case $a in
	        1) valheim_server_install ; server_install_menu ;;
           	    0) menu ; menu ;;
		    *)  echo -ne " $(ColorRed ''"$WRONG_MENU_OPTION"'')" ; server_install_menu ;;
        esac
}
########################################################################
#########################Print System INFOS#############################
########################################################################
function display_system_info() {
clear
echo ""
    echo -e "$DRAW80"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_HEADER"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_HOSTNAME"`hostname`
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_UPTIME"`uptime | awk '{print $3,$4}' | sed 's/,//'`
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_MANUFACTURER"`cat /sys/class/dmi/id/chassis_vendor`
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_PRODUCT_NAME"`cat /sys/class/dmi/id/product_name`
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_VERSION"`cat /sys/class/dmi/id/product_version`
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_SERIAL_NUMBER"`cat /sys/class/dmi/id/product_serial`
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_MACHINE_TYPE"`vserver=$(lscpu | grep Hypervisor | wc -l); if [ $vserver -gt 0 ]; then echo "VM"; else echo "Physical"; fi`
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_OPERATION_SYSTEM"`hostnamectl | grep "Operating System" | cut -d ' ' -f5-`
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_KERNEL"`uname -r`
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_ARCHITECTURE"`arch`
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_PROCESSOR_NAME"`awk -F':' '/^model name/ {print $2}' /proc/cpuinfo | uniq | sed -e 's/^[ \t]*//'`
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_ACTIVE_USER"`w | cut -d ' ' -f1 | grep -v USER | xargs -n1`
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_SYSTEM_MAIN_IP"`hostname -I`
echo ""
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_CPU_MEM_HEADER"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_MEMORY_USAGE"`free | awk '/Mem/{printf("%.2f %%"), $3/$2*100}'`
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_CPU_USAGE"`cat /proc/stat | awk '/cpu/{printf("%.2f %%\n"), ($2+$4)*100/($2+$4+$5)}' |  awk '{print $0}' | head -1`
echo ""
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_DISK_HEADER"
    df -Ph | sed s/%//g | awk '{ if($5 > 80) print $0;}'
    echo -e "$DRAW80"
echo ""
}
########################################################################
#############################PRINT NETWORK INFO#########################
########################################################################
function display_network_info() {
clear
    echo ""
    sudo netstat -atunp | grep valheim
    echo ""
}
########################################################################
################Display History of Connected Players####################
########################################################################
function display_player_history() {
clear
    echo ""
    sudo grep ZDOID /var/log/syslog*
    echo ""
}
########################################################################
#####################Sub Tech Support Menu System#######################
########################################################################
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
		  0) menu ; menu ;;
		    *)  echo -ne " $(ColorRed ''"$WRONG_MENU_OPTION"'')" ; tech_support ;;
        esac
}

########################################################################
##################START CHANGE VALHEIM START CONFIG#####################
########################################################################
function get_current_config() {
    currentDisplayName=$(perl -n -e '/\-name "?([^"]+)"? \-port/ && print "$1\n"' ${valheimInstallPath}/start_valheim.sh)
    currentPort=$(perl -n -e '/\-port "?([^"]+)"? \-nographics/ && print "$1\n"' ${valheimInstallPath}/start_valheim.sh)
    currentWorldName=$(perl -n -e '/\-world "?([^"]+)"? \-password/ && print "$1\n"' ${valheimInstallPath}/start_valheim.sh)
    currentPassword=$(perl -n -e '/\-password "?([^"]+)"? \-public/ && print "$1\n"' ${valheimInstallPath}/start_valheim.sh)
    currentPublicSet=$(perl -n -e '/\-public "?([^"]+)"?$/ && print "$1\n"' ${valheimInstallPath}/start_valheim.sh)
}

function print_current_config() {
    echo "$FUNCTION_PRINT_CURRENT_CONFIG_PUBLIC_NAME $(tput setaf 2)${currentDisplayName} $(tput setaf 9) "
    echo "$FUNCTION_PRINT_CURRENT_CONFIG_PORT $(tput setaf 2)${currentPort} $(tput setaf 9) "
    echo "$FUNCTION_PRINT_CURRENT_CONFIG_LOCAL_WORLD_NAME $(tput setaf 2)${currentWorldName} $(tput setaf 9)"
    echo "$FUNCTION_PRINT_CURRENT_CONFIG_LOCAL_WORLD_NAME_INFO"
    echo "$FUNCTION_PRINT_CURRENT_CONFIG_ACCESS_PASSWORD $(tput setaf 2)${currentPassword} $(tput setaf 9) "
    echo "$FUNCTION_PRINT_CURRENT_CONFIG_PUBLIC_LISTING $(tput setaf 2)${currentPublicSet}  $(tput setaf 9) "
    echo "$FUNCTION_PRINT_CURRENT_CONFIG_PUBLIC_LISTING_INFO"
}

function set_config_defaults() {
    #assign current varibles to set variables
    #if no are changes are made set variables will write to new config file anyways. No harm done
    #if changes are made set variables are updated with new data and will be wrote to new config file
    setCurrentDisplayName=$currentDisplayName
    setCurrentPort=$currentPort
    setCurrentWorldName=$currentWorldName
    setCurrentPassword=$currentPassword
    setCurrentPublicSet=$currentPublicSet
}

function write_config_and_restart() {
    tput setaf 1; echo "$FUNCTION_WRITE_CONFIG_RESTART_INFO" ; tput setaf 9;
    sleep 1
    cat > ${valheimInstallPath}/start_valheim.sh <<EOF
#!/bin/bash
export templdpath=\$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:\$LD_LIBRARY_PATH
export SteamAppId=892970
# Tip: Make a local copy of this script to avoid it being overwritten by steam.
# NOTE: You need to make sure the ports 2456-2458 is being forwarded to your server through your local router & firewall.
./valheim_server.x86_64 -name "${setCurrentDisplayName}" -port ${setCurrentPort} -nographics -batchmode -world "${setCurrentWorldName}" -password "${setCurrentPassword}" -public "${setCurrentPublicSet}"
export LD_LIBRARY_PATH=\$templdpath
EOF
   echo "$FUNCTION_WRITE_CONFIG_RESTART_SET_PERMS" ${valheimInstallPath}/start_valheim.sh
   chown steam:steam ${valheimInstallPath}/start_valheim.sh
   chmod +x ${valheimInstallPath}/start_valheim.sh
   echo "$ECHO_DONE"
   echo "$FUNCTION_WRITE_CONFIG_RESTART_SERVICE_INFO"
   sudo systemctl restart valheimserver.service
   echo ""
}

function write_public_on_config_and_restart() {
    get_current_config
    print_current_config
    set_config_defaults
    write_public_on_config_and_restart
}

function write_public_off_config_and_restart() {
    get_current_config
    print_current_config
    set_config_defaults
    write_config_and_restart
}

function change_public_display_name() {
    get_current_config
    print_current_config
    set_config_defaults
    echo ""
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_CHANGE_PUBLIC_DISPLAY_NAME_HEADER" ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_PUBLIC_DISPLAY_NAME_INFO" ; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_PUBLIC_DISPLAY_NAME_INFO_1" ; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_PUBLIC_DISPLAY_NAME_INFO_2" ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_CHANGE_PUBLIC_DISPLAY_CURRENT_NAME ${currentDisplayName}" ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    echo ""
    read -p "$FUNCTION_CHANGE_PUBLIC_DISPLAY_EDIT_NAME_INFO" setCurrentDisplayName
    echo ""
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    echo ""
    tput setaf 5; echo "$FUNCTION_CHANGE_PUBLIC_DISPLAY_OLD_PUBLIC_NAME" ${currentDisplayName} ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    echo ""
    tput setaf 1; echo "$FUNCTION_CHANGE_PUBLIC_DISPLAY_NEW_PUBLIC_NAME" ${setCurrentDisplayName} ; tput setaf 9;
    echo ""
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    echo ""
    read -p "$PLEASE_CONFIRM" confirmPublicNameChange
    #if y, then continue, else cancel
    if [ "$confirmPublicNameChange" == "y" ]; then
        write_config_and_restart
    else
        echo "$FUNCTION_CHANGE_PUBLIC_DISPLAY_CANCEL_CHANGING"
        sleep 3
        clear
    fi
}
    
function change_default_server_port() {
    get_current_config
    print_current_config
    set_config_defaults
    echo ""
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_HEADER" ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_INFO" ; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_INFO_1" ; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_INFO_2" ; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_INFO_3" ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_CURRENT ${currentPort} " ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    echo ""
    while true; do
        read -p "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_EDIT_PORT " setCurrentPort
        echo ""
         #check to make sure nobody types stupid Loki Jokes in here
        [[ ${#setCurrentPort} -ge 4 && ${#setCurrentPort} -le 6 ]] && [[ $setCurrentPort -gt 1024 && $setCurrentPort -le 65530 ]] && [[ "$setCurrentPort" =~ ^[[:alnum:]]+$ ]] && break
        echo ""
        echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_ERROR_CHECK_MSG"
    done
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 5; echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_OLD_PORT" ${currentPort} ; tput setaf 9;
    tput setaf 6; echo "$FUNCTION_CHANGE_DEFAULT_SERVER_PORT_NEW_PORT" ${setCurrentPort} ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    read -p "$PLEASE_CONFIRM" confirmServerPortChange
    echo ""
    #if y, then continue, else cancel
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
    echo ""
}

function change_server_access_password() {
    get_current_config
    print_current_config
    set_config_defaults
    echo ""
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_HEADER" ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_INFO" ; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_INFO_1" ; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_INFO_2" ; tput setaf 9;
    tput setaf 1; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_INFO_3" ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 5; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_CURRENT_DISPLAY_NAME" ${currentDisplayName} ; tput setaf 9;
    tput setaf 5; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_CURRENT_WORLD_NAME" ${currentWorldName} ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_CURRENT_PASS ${currentPassword} " ; tput setaf 9;
    tput setaf 2; echo "$DRAW60" ; tput setaf 9;
    while true; do
        tput setaf 1; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_INFO_RULES" ; tput setaf 9;
        tput setaf 1; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_INFO_RULES_1" ; tput setaf 9;
        tput setaf 2; echo "$DRAW60" ; tput setaf 9;
        tput setaf 2; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_GOOD" ; tput setaf 9;
        tput setaf 1; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_BAD" ; tput setaf 9;
        tput setaf 2; echo "$DRAW60" ; tput setaf 9;
        read -p "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_ENTER_NEW  " setCurrentPassword
        tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
        [[ ${#setCurrentPassword} -ge 5 && "$setCurrentPassword" == *[[:lower:]]* && "$setCurrentPassword" == *[[:upper:]]* && "$setCurrentPassword" =~ ^[[:alnum:]]+$ ]] && break
        tput setaf 2; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_ERROR_MSG" ; tput setaf 9;
        tput setaf 2; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_ERROR_MSG_1" ; tput setaf 9;
    done
    echo ""
    tput setaf 5; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_OLD_PASS" ${currentPassword} ; tput setaf 9;
    tput setaf 5; echo "$FUNCTION_CHANGE_SERVER_ACCESS_PASSWORD_NEW_PASS" ${setCurrentPassword} ; tput setaf 9;
    read -p "$PLEASE_CONFIRM" confirmServerAccessPassword
    #if y, then continue, else cancel
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
####################END CHANGE VALHEIM START CONFIG#####################
########################################################################

########################################################################
##########################MENUS STATUS VARIBLES#########################
########################################################################
# Check Current Valheim REPO Build for menu display

function check_official_valheim_release_build() {
    if [[ -e "/home/steam/steamcmd" ]] ; then
    currentOfficialRepo=$(/home/steam/steamcmd +login anonymous +app_info_update 1 +app_info_print 896660 +quit | grep -A10 branches | grep -A2 public | grep buildid | cut -d'"' -f4) 
        echo $currentOfficialRepo
    else 
        echo "$NO_DATA";
  fi
}

# Check Local Valheim Build for menu display
function check_local_valheim_build() {
localValheimAppmanifest=${valheimInstallPath}/steamapps/appmanifest_896660.acf
   if [[ -e $localValheimAppmanifest ]] ; then
    localValheimBuild=$(grep buildid ${localValheimAppmanifest} | cut -d'"' -f4)
        echo $localValheimBuild
    else 
        echo "$NO_DATA";
  fi
}

function check_menu_script_repo() {

latestScript=$(curl --connect-timeout 10 -s https://api.github.com/repos/Nimdy/Dedicated_Valheim_Server_Script/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
echo $latestScript
}

function display_public_status_on_or_off() {
currentPortCheck=$(perl -n -e '/\-public "?([^"]+)"?$/ && print "$1\n"' ${valheimInstallPath}/start_valheim.sh)
    if [[ $currentPortCheck == 1 ]]; then 
      echo "$ECHO_ON"
    else
      echo "$ECHO_OFF"
  fi
}


function display_public_IP() {
externalip=$(curl -s ipecho.net/plain;echo)
echo -e '\E[32m'"$EXTERNAL_IP $whateverzerowantstocalthis "$externalip ; tput setaf 9;
}

function display_local_IP() {
internalip=$(hostname -I)
echo -e '\E[32m'"$INTERNAL_IP $mymommyboughtmeaputerforchristmas "$internalip ; tput setaf 9;

}

function are_you_connected() {
ping -c 1 google.com &> /dev/null && echo -e '\E[32m'"$INTERNET_MSG $tecreset $INTERNET_MSG_CONNECTED" || echo -e '\E[32m'"$INTERNET_MSG $tecreset $INTERNET_MSG_DISCONNECTED"

}
function menu_header() {
get_current_config
echo -ne "
$(ColorOrange '╔══════════════════════════════════════════════════════════╗')
$(ColorOrange '║~~~~~~~~~~*****~~~~~~~~-Njord Menu-~~~~~~~~~*****~~~~~~~~~║')
$(ColorOrange '╠══════════════════════════════════════════════════════════╝')
$(ColorOrange '║ '"$FUNCTION_HEADER_MENU_INFO"'')
$(ColorOrange '║ '"$FUNCTION_HEADER_MENU_INFO_1"'')
$(ColorOrange '║ '"$FUNCTION_HEADER_MENU_INFO_2"'')
$(ColorOrange '║')
$(ColorOrange '║ '"$FUNCTION_HEADER_MENU_INFO_VALHEIM_OFFICIAL_BUILD"'')" $(check_official_valheim_release_build)
echo -ne "
$(ColorOrange '║ '"$FUNCTION_HEADER_MENU_INFO_VALHEIM_LOCAL_BUILD"' ')"        $(check_local_valheim_build)
echo -ne "
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_SERVER_NAME ${currentDisplayName}
$(ColorOrange '║') $(are_you_connected)
$(ColorOrange '║')" $(display_public_IP)
echo -ne "
$(ColorOrange '║')" $(display_local_IP)
echo -ne "
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_SERVER_PORT " ${currentPort}
echo -ne "
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_PUBLIC_LIST " $(display_public_status_on_or_off)
echo -ne "
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_CURRENT_NJORD_RELEASE $(check_menu_script_repo)
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_LOCAL_NJORD_VERSION ${mversion}
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_GG_ZEROBANDWIDTH
$(ColorOrange '╚═══════════════════════════════════════════════════════════')"
}


########################################################################
#######################Display Main Menu System#########################
########################################################################
menu(){
menu_header
echo -ne "
$(ColorOrange ' '"$FUNCTION_MAIN_MENU_CHECK_SCRIPT_UPDATES_HEADER"' ')
$(ColorOrange '-')$(ColorGreen ' 1)') $FUNCTION_MAIN_MENU_UPDATE_NJORD_MENU
$(ColorOrange ''"$FUNCTION_MAIN_MENU_SERVER_COMMANDS_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 2)') $FUNCTION_MAIN_MENU_TECH_MENU
$(ColorOrange '-')$(ColorGreen ' 3)') $FUNCTION_MAIN_MENU_INSTALL_VALHEIM
$(ColorOrange ''"$FUNCTION_MAIN_MENU_OFFICAL_VALHEIM_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 4)') $FUNCTION_MAIN_MENU_CHECK_APPLY_VALHEIM_UPDATES
$(ColorOrange ''"$FUNCTION_MAIN_MENU_EDIT_VALHEIM_CONFIG_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 5)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_DISPLAY_CONFIG
$(ColorOrange '-')$(ColorGreen ' 6)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_CHANGE_PUBLIC_NAME
$(ColorOrange '-')$(ColorGreen ' 7)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_CHANGE_SERVER_PORT
$(ColorOrange '-')$(ColorGreen ' 8)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_CHANGE_WORLD_NAME
$(ColorOrange '-')$(ColorGreen ' 9)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_CHANGE_ACCESS_PASS
$(ColorOrange '-')$(ColorGreen ' 10)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_ENABLE_PUBLIC_LISTING
$(ColorOrange '-')$(ColorGreen ' 11)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_DISABLE_PUBLIC_LISTING
$(ColorOrange ''"$DRAW60"'')
$(ColorOrange '-')$(ColorGreen ' 12)') $FUNCTION_ADMIN_TOOLS_MENU_STOP_SERVICE
$(ColorOrange '-')$(ColorGreen ' 13)') $FUNCTION_ADMIN_TOOLS_MENU_START_SERVICE
$(ColorOrange '-')$(ColorGreen ' 14)') $FUNCTION_ADMIN_TOOLS_MENU_RESTART_SERVICE
$(ColorOrange '-')$(ColorGreen ' 15)') $FUNCTION_ADMIN_TOOLS_MENU_STATUS_SERVICE
$(ColorOrange ''"$DRAW60"'')
$(ColorOrange '-')$(ColorGreen ' 16)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_BACKUP_WORLD_DATA
$(ColorOrange '-')$(ColorGreen ' 17)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_RESTORE_WORLD_DATA
$(ColorOrange ''"$FUNCTION_MAIN_MENU_EDIT_VALHEIM_MODS_HEADER"'')
$(ColorOrange '-')$(ColorGreen '') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_MODS_MSG
$(ColorOrange ''"$DRAW60"'')
$(ColorGreen ' 0)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_EXIT
$(ColorOrange ''"$DRAW60"'')
$(ColorPurple ''"$CHOOSE_MENU_OPTION"'') "
        read a
        case $a in
	        1) script_check_update ; menu ;;
		2) tech_support ; menu ;;
		3) server_install_menu ; menu ;;
		4) confirm_check_apply_server_updates ; menu ;;	
	        5) display_full_config ; menu ;;
	        6) change_public_display_name ; menu ;;
	        7) change_default_server_port ; menu ;;		
	        8) change_local_world_name ; menu ;;
	        9) change_server_access_password ; menu ;;
		10) write_public_on_config_and_restart ; menu ;;
		11) write_public_off_config_and_restart ; menu ;;
	        12) stop_valheim_server ; menu ;;
		13) start_valheim_server ; menu ;;
		14) restart_valheim_server ; menu ;;
		15) display_valheim_server_status ; menu ;;
		16) backup_world_data ; menu ;;
		17) restore_world_data ; menu ;;
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
