#!/bin/bash
# Sanity Check
#    #######################################################
echo "$(tput setaf 4)-------------------------------------------------------"
echo "$(tput setaf 0)$(tput setab 7)Since we need to run the menu with elevated privileges$(tput sgr 0)"
echo "$(tput setaf 0)$(tput setab 7)Please enter your password now.$(tput sgr 0)"
echo "$(tput setaf 4)-------------------------------------------------------"
#    ###################################################### 
[[ "$EUID" -eq 0 ]] || exec sudo "$0" "$@"

# MAIN BRANCH MENU
#  THIS IS STILL A WORK IN PROGRESS BUT ALL THE FUNCTIONS WORK
#  I NEED TO JUST CLEAN IT UP AND FORMAT BETTER
#  PLEASE LET ME KNOW ABOUT ISSUES
#  UPDATE THE MENU BEFORE YOU USE IT 
# If Frankenstein was a bash script
# Please help improve this script
# Easy Valheim Server Menu super duper easy
# Open to other commands that should be used... 
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

#Required for initial install of Valheim. DONT TOUCH THIS!!
#Seriously! The menu system will switch this on and off.
#Dont even look at it... dont even think about making that a 0
#Set valheim to operate in vanilla mode and not with Valheim+ Mods
valheimVanilla=1
# Set Menu Version for menu display
mversion="2.0-Lofn"

##
# Update Menu script 
##

##
# Admin Tools:
# -Backup World: Manual backups of .db and .fwl files
# -Restore World: Manual restore of .db and .fwl files
# -Stop Valheim Server: Stops the Valheim Service
# -Start Valheim Server: Starts the Valheim Service
# -Restart Valheim Server: Restarts the Valheim Service (stop/start)
# -Status Valheim Server: Displays the current status of the Valheim Server Service
# -Check and Apply Valheim Server Update: Reaches out to to Steam with steamcmd and looks for official updates. If found applies them and restarts Valheim services
# -Edit Valheim Configuration File from menu
# -Fresh Valheim Server: Installs Valheim server from official Steam repo. 
##

##
# Tech Support Tools
#Display Valheim Config File
#Display Valheim Server Service
#Display World Data Folder
#Display System Info
#Display Network Info
#Display Connected Players History
##

##
# Adding Valheim Mod Support
##

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
#Look I know this is not pretty like Loki's face but it works!
    git fetch
      [ -n "$(git diff --name-only "$UPSTREAM" "$SCRIPTFILE")" ] && {
      echo "BY THORS HAMMER take a peek inside Valhalla!!"
        git pull --force
	git stash
        git checkout "$BRANCH"
        git pull --force
	echo " Updating"
	chmod +x menu.sh
        exec "$SCRIPTNAME" "${ARGS[@]}"

        # Now exit this old instance
        exit 1
    }
        echo "Oh for Loki sakes! No updates to be had... back to choring! "
}



########################################################################
########################Install Valheim Server##########################
########################################################################

function valheim_server_install() {
    clear
    echo ""
    echo -ne "
$(ColorOrange '-----------------Install Valheim Server------------------')
$(ColorRed '------------------------------------------------------------')"
echo ""
tput setaf 2; echo "You are about to INSTALL the Valheim Server" ; tput setaf 9; 
tput setaf 2; echo "You are you sure y(YES) or n(NO)?" ; tput setaf 9; 
echo -ne "
$(ColorRed '------------------------------------------------------------')"
echo ""
 read -p "Please confirm:" confirmStartInstall
#if y, then continue, else cancel
        if [ "$confirmStartInstall" == "y" ]; then
    echo ""

#check for updates and upgrade the system auto yes
    tput setaf 1; echo "Checking for upgrades" ; tput setaf 9;
    apt update && apt upgrade -y
    tput setaf 2; echo "Done" ; tput setaf 9;
    sleep 1
    
#check for updates and upgrade the system auto yes WTF is curl not installed by default... come on man!
    tput setaf 1; echo "Install Git, Locate, Curl and Net-Tools" ; tput setaf 9;
    apt install git mlocate net-tools curl -y
    tput setaf 2; echo "Done" ; tput setaf 9;
    sleep 1
    
#install software-properties-common for add-apt-repository command below
    tput setaf 1; echo "Installing software-properties-common package" ; tput setaf 9;
    apt install software-properties-common
    tput setaf 2; echo "Done" ; tput setaf 9;
    sleep 1

#add multiverse repo
    tput setaf 1; echo "Adding multiverse REPO" ; tput setaf 9;
    add-apt-repository -y multiverse
    tput setaf 2; echo "Done" ; tput setaf 9;
    sleep 1

#add i386 architecture
    tput setaf 1; echo "Adding i386 architecture" ; tput setaf 9;
    dpkg --add-architecture i386
    tput setaf 2; echo "Done" ; tput setaf 9;
    sleep 1

#update system again
    tput setaf 1; echo "Checking and updating system again" ; tput setaf 9;
    apt update
    tput setaf 2; echo "Done" ; tput setaf 9;
    sleep 1

# Linux Steam Local Account Password input
    echo ""
    clear
    echo "Thanks for downloading the script, let's get started"
    echo "The following information is required for configuration files"
    echo "Read each step carefully"
    echo "A printout of data entered will be displayed to you"
    echo ""
    echo "A non-root account will be created to run Valheim Server"
    echo "This account is named steam and will act as a service account only"
    while true; do
      tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
      tput setaf 2; echo "----------------NONROOT STEAM ACCOUNT PASSWORD--------------" ; tput setaf 9;
      tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
      tput setaf 1; echo "Password must be 6 Characters or more" ; tput setaf 9;
      tput setaf 1 ;echo "At least one number, one uppercase letter and one lowercase letter" ; tput setaf 9;
      tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
      tput setaf 2;  echo "Good Example: Viking12" ; tput setaf 9;
      tput setaf 1;  echo "Bad Example: Vik!" ; tput setaf 9;
      tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
      echo ""
        read -p "Please give steam a password: " userpassword
      tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
            [[ ${#userpassword} -ge 6 && "$userpassword" == *[[:lower:]]* && "$userpassword" == *[[:upper:]]* && "$userpassword" =~ ^[[:alnum:]]+$ ]] && break
      tput setaf 2; echo "Password not accepted - Too Short or has Special Characters" ; tput setaf 9;
      tput setaf 2; echo "I swear to LOKI, you better NOT use Special Characters" ; tput setaf 9;
    done
    clear
    echo ""
# Take user input for Valheim Server Public Display
    echo ""
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 2; echo "------------------Public Server Display Name----------------" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 1;  echo "Enter a name for your Valheim Server" ; tput setaf 9;
    tput setaf 1;  echo "This is for the Public Steam Browser Listing" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 2;  echo "Good Example: Zero's Viking Server" ; tput setaf 9;
    tput setaf 1;  echo "Bad Example: Zero's #1 Server Cash Signs hashtags or other special chars, it will break the script!" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    echo ""
      read -p "Enter public server display name: " displayname
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    echo ""
    clear
# Take user input for Valheim Server World Database Generation
    echo ""
     while true; do
        tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
        tput setaf 2; echo "----------------------Set your World Name-------------------" ; tput setaf 9;
        tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
        tput setaf 1;  echo "Name must be 4 Characters or more" ; tput setaf 9;
        tput setaf 1;  echo "No Special Characters not even a space" ; tput setaf 9;
	tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
	tput setaf 2;  echo "Good Example: ThorsHammer" ; tput setaf 9;
        tput setaf 1;  echo "Bad Example: Loki is a Trickster" ; tput setaf 9;
	tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
	echo ""
        read -p "Please make a world name: " worldname
	tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
            [[ ${#worldname} -ge 4 && "$worldname" =~ ^[[:alnum:]]+$ ]] && break
        tput setaf 2;  echo "World Name not set: Too Short or has Special Characters" ; tput setaf 9; 
	tput setaf 2; echo "I swear to LOKI, you better NOT use Special Characters" ; tput setaf 9; 
    done
    clear
    echo ""
# Take user input for Valheim Server password
# Added security for harder passwords
    echo ""        
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 2; echo "--------------------Set Server Access Password--------------" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 1; echo "Now for Loki, please follow instructions" ; tput setaf 9;
    tput setaf 1; echo "Server is required to have a password" ; tput setaf 9;
    tput setaf 1; echo "Password cannot match public display name or world name" ; tput setaf 9;
    tput setaf 1; echo "Make your password unique" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 2; echo "Your public display name: $displayname " ; tput setaf 9;
    tput setaf 2; echo "Your world name: $worldname " ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    while true; do
    tput setaf 1;  echo "This password must be 5 Characters or more" ; tput setaf 9;
    tput setaf 1;  echo "At least one number, one uppercase letter and one lowercase letter" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 2;  echo "Good Example: Viking12" ; tput setaf 9;
    tput setaf 1;  echo "Bad Example: Vik!" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    read -p "Enter Password to Enter your Valheim Server: " password
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
        [[ ${#password} -ge 5 && "$password" == *[[:lower:]]* && "$password" == *[[:upper:]]* && "$password" =~ ^[[:alnum:]]+$ ]] && break
    tput setaf 2; echo "Password not accepted - Too Short, Special Characters" ; tput setaf 9;
    tput setaf 2; echo "I swear to LOKI, you better NOT use Special Characters" ; tput setaf 9;
    done
    echo ""
cat >> /home/steam/serverSetup.txt <<EOF
Here is the information you entered
This information is for you to ref later, in case you forgot
---------------------------------------------------------------
nonroot steam password:  $userpassword
Public Server Name:      $displayname
Local World Name:        $worldname
Valheim Server Password: $password
---------------------------------------------------------------
Each time this is ran, the past info will be added to each line
---------------------------------------------------------------
EOF
chown steam:steam /home/steam/serverSetup.txt
clear
echo "Here is the information you entered"
echo "This information is saved in the valheim_server.sh file"
echo "This information is saved in /home/steam/serverSetup.txt for referance later, if you forget"
tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
tput setaf 2; echo "nonroot steam password:  $userpassword " ; tput setaf 9;
tput setaf 2; echo "Public Server Name:      $displayname " ; tput setaf 9;
tput setaf 2; echo "Local World Name:        $worldname " ; tput setaf 9;
tput setaf 2; echo "Valheim Server Password: $password " ; tput setaf 9;
tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
echo ""
sleep 5

#install steamcmd and libsd12-2
tput setaf 1; echo "Installing steamcmd and libsdl2" ; tput setaf 9;
echo steam steam/question select "I AGREE" | sudo debconf-set-selections
echo steam steam/license note '' | sudo debconf-set-selections
apt install steamcmd libsdl2-2.0-0 libsdl2-2.0-0:i386 -y
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1
#EDIT HERE #1
#build account to run Valheim
tput setaf 1; echo "Building steam account NONROOT" ; tput setaf 9;
sleep 1
useradd --create-home --shell /bin/bash --password $userpassword steam
cp /etc/skel/.bashrc /home/steam/.bashrc
cp /etc/skel/.profile /home/steam/.profile
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1
#build symbolic link for steamcmd
tput setaf 1; echo "Building symbolic link for steamcmd" ; tput setaf 9;
ln -s /usr/games/steamcmd /home/steam/steamcmd
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1
#chown steam user to steam
tput setaf 1; echo "Setting steam permissions" ; tput setaf 9;
chown steam:steam -Rf /home/steam/*
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1
#Download Valheim from steam
tput setaf 1; echo "Downloading and installing Valheim from Steam" ; tput setaf 9;
sleep 1
/home/steam/steamcmd +login anonymous +force_install_dir ${valheimInstallPath} +app_update 896660 validate +exit
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1
#build config for start_valheim.sh
tput setaf 1; echo "Deleting old configuration if file exist" ; tput setaf 9;  
tput setaf 1; echo "Building Valheim start_valheim server configuration" ; tput setaf 9;
[ -e ${valheimInstallPath}/start_valheim.sh ] && rm ${valheimInstallPath}/start_valheim.sh
sleep 1
cat >> ${valheimInstallPath}/start_valheim.sh <<EOF
#!/bin/bash
export templdpath=\$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:\$LD_LIBRARY_PATH
export SteamAppId=892970
# Tip: Make a local copy of this script to avoid it being overwritten by steam.
# NOTE: You need to make sure the ports 2456-2458 is being forwarded to your server through your local router & firewall.
./valheim_server.x86_64 -name "${displayname}" -port "2456" -nographics -batchmode -world "${worldname}" -password "${password}" -public "1"
export LD_LIBRARY_PATH=\$templdpath
EOF
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1
#delete old check log script, not required any longer.
tput setaf 1; echo "Deleting old check log script if exist" ; tput setaf 9; 
[ -e /home/steam/check_log.sh ] && rm /home/steam/check_log.sh
#set execute permissions
tput setaf 1; echo "Setting execute permissions on start_valheim.sh" ; tput setaf 9;
chmod +x ${valheimInstallPath}/start_valheim.sh
tput setaf 2; echo "Done" ; tput setaf 9;
tput setaf 1; echo "Setting execute permissions on check_log.sh" ; tput setaf 9; 
chmod +x /home/steam/check_log.sh
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1
#build systemctl configurations for execution of processes for Valheim Server
tput setaf 1; echo "Deleting old configuration if file exist" ; tput setaf 9; 
tput setaf 1; echo "Building systemctl instructions for Valheim" ; tput setaf 9; 
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
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1
#chown steam user permissions to all of user steam dir location
tput setaf 1; echo "Setting steam account permissions to /home/steam/*" ; tput setaf 9; 
chown steam:steam -Rf /home/steam/*
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1
# Reload daemons
tput setaf 1; echo "Reloading daemons and spawning Necks" ; tput setaf 9; 
systemctl daemon-reload
tput setaf 2; echo "Done" ; tput setaf 9; 
sleep 1
# Start server
tput setaf 1; echo "By Thors Hammer we are Starting the Valheim Server" ; tput setaf 9; 
systemctl start valheimserver
tput setaf 2; echo "Done" ; tput setaf 9; 
sleep 1
# Enable server on restarts
tput setaf 1; echo "Enabling Valheim Server on start or after reboots" ; tput setaf 9; 
systemctl enable valheimserver
tput setaf 2; echo "Done" ; tput setaf 9; 
sleep 2
clear
tput setaf 2; echo "Check server status by typing systemctl status valheimserver.service"
tput setaf 2; echo "Thank you for using the script."
tput setaf 2; echo "AND A HUGE THANKS TO github: @Lachlanmac, @JamieeLee, @RedKrieg, @bherbruck "
tput setaf 2; echo "@xaviablaza, @joaoanes, @amasover, @madmozg, @nicolas-martin, @devdavi and others!"
tput setaf 2; echo "If your name is missing! Let me know!"
tput setaf 2; echo "-ZeroBandwidth"
tput setaf 2; echo "GLHF"
tput setaf 9;
echo ""
  
    echo ""    
    else
        echo "Canceling the INSTALL of Valheim Server Service - because Loki sucks"
fi
}
########################################################################
###################Backup World DB and FWL Files########################
########################################################################
function backup_world_data() {
    echo ""
    echo ""
    #read user input confirmation
      tput setaf 1; echo "This will stop and start Valheim Services." ; tput setaf 9;
      tput setaf 1; echo "Are you okay with this? (y=Yes, n=No)" ; tput setaf 9;
         read -p "Press y or n:" confirmBackup
         #if y, then continue, else cancel
         if [ "$confirmBackup" == "y" ]; then
         ## Get the current date as variable.
         TODAY="$(date +%Y-%m-%d-%T)"
	 tput setaf 5; echo "Checking to see if backup directory is created" ; tput setaf 9;
	 tput setaf 5; echo "If not, one will be created" ; tput setaf 9;
	 dldir=$backupPath
	 [ ! -d "$dldir" ] && mkdir -p "$dldir"
         sleep 1
         ## Clean up files older than 2 weeks. Create a new backup.
	 tput setaf 1; echo "Cleaning up old backup files. Older than 2 weeks" ; tput setaf 9;
         find $backupPath/* -mtime +14 -type f -delete
	 tput setaf 2; echo "Cleaned up better than Loki" ; tput setaf 9;
         sleep 1
         ## Tar Section. Create a backup file, with the current date in its name.
         ## Add -h to convert the symbolic links into a regular files.
         ## Backup some system files, also the entire `/home` directory, etc.
         ##--exclude some directories, for example the the browser's cache, `.bash_history`, etc.
	  #stop valheim server
         tput setaf 1; echo "Stopping Valheim Server for clean backups" ; tput setaf 9;
         systemctl stop valheimserver.service
         tput setaf 1; echo "Stopped" ; tput setaf 9;
	 tput setaf 1; echo "Making tar file of world data" ; tput setaf 9;
         tar czf $backupPath/valheim-backup-$TODAY.tgz $worldpath/*
	 tput setaf 2; echo "Process complete!" ; tput setaf 9;
	 sleep 1
	 tput setaf 2; echo "Restarting the best Valheim Server in the world" ; tput setaf 9;
         systemctl start valheimserver.service
         tput setaf 2; echo "Valheim Server Service Started" ; tput setaf 9;
	 echo ""
	 tput setaf 2; echo "Setting permissions for steam on backup file" ; tput setaf 9;
	 chown -Rf steam:steam ${backupPath}
	 tput setaf 2; echo "Process complete!" ; tput setaf 9;
    echo ""
 else 
   tput setaf 3; echo "Backuping up of the world files .db and .fwl canceled" ; tput setaf 9;
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
tput setaf 2; echo "Select Backup File you wish to restore" ; tput setaf 9;
tput setaf 2; echo "To CANCEL select any file. Next are you can confirm or back out" ; tput setaf 9;
    read -p "" selectedIndex
#show confirmation message
restorefile=$(basename "${backups[$selectedIndex-1]}")
echo -ne "
$(ColorRed '------------------------------------------------------------')
$(ColorGreen 'Restore '${restorefile}' ?')
$(ColorGreen 'Are you sure you want to do this? ')
$(ColorOrange 'Remember to match world name with '${valheimInstallPath}'/start_valheim.sh')
$(ColorOrange 'The param for -world "worldname" much match restore file worldname.db and worldname.fwl')
$(ColorGreen 'Press y (for yes) or n (for no)') "
#read user input confirmation
    read -p "" confirmBackupRestore
#if y, then continue, else cancel
        if [ "$confirmBackupRestore" == "y" ]; then
 #stop valheim server
        tput setaf 1; echo "Stopping Valheim Server" ; tput setaf 9;
        systemctl stop valheimserver.service
        tput setaf 2; echo "Valheim Services successfully Stopped" ; tput setaf 9;
 #give it a few
        sleep 5
 #copy backup to worlds folder
        tput setaf 2; echo "Copying ${backups[$selectedIndex-1]} to ${worldpath}/" ; tput setaf 9;
        cp ${backups[$selectedIndex-1]} ${worldpath}/
 #untar
        tput setaf 2; echo "Unpacking ${worldpath}/${restorefile}" ; tput setaf 9;
        tar xzf ${worldpath}/${restorefile} --strip-components=7 --directory ${worldpath}/  
	chown -Rf steam:steam ${worldpath}
	rm  ${worldpath}/*.tgz
        tput setaf 2; echo "Starting Valheim Services" ; tput setaf 9;
        tput setaf 2; echo "This better work Loki!" ; tput setaf 9;
        systemctl start valheimserver.service
else
        tput setaf 2; echo "Canceling restore process because Loki sucks" ; tput setaf 9;
fi
}

########################################################################
#############Install Official Update of Valheim Updates#################
########################################################################
function continue_with_valheim_update_install() {
    clear
    echo ""
    echo -ne "
$(ColorOrange '-----------------Installing Valheim Updates-----------------')
$(ColorRed '------------------------------------------------------------')"
echo ""
tput setaf 2; echo "A NEW update was found!" ; tput setaf 9;
tput setaf 2; echo "You are about to apply Official Valheim Updates" ; tput setaf 9; 
tput setaf 2; echo "You are you sure y(YES) or n(NO)?" ; tput setaf 9; 
echo -ne "
$(ColorRed '------------------------------------------------------------')"
echo ""
 read -p "Please confirm:" confirmOfficialUpdates
#if y, then continue, else cancel
if [ "$confirmOfficialUpdates" == "y" ]; then
    tput setaf 2; echo "Using Thor's Hammer to apply Official Updates!" ; tput setaf 9; 
    /home/steam/steamcmd +login anonymous +force_install_dir ${valheimInstallPath} +app_update 896660 validate +exit
    chown -R steam:steam ${valheimInstallPath}
    echo ""
else
    echo "Canceling all Official Updates for Valheim Server - because Loki sucks"
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
    echo "Downloading Official Valheim Repo Log Data for comparison only"
      [ ! -d /opt/valheimtemp ] && mkdir -p /opt/valheimtemp
      /home/steam/steamcmd +login anonymous +force_install_dir /opt/valheimtemp +app_update 896660 validate +exit
      sed -e 's/[\t ]//g;/^$/d' /opt/valheimtemp/steamapps/appmanifest_896660.acf > appmanirepo.log
      repoValheim=$(sed -n '11p' appmanirepo.log)
      echo "Official Valheim-: $repoValheim"
      sed -e 's/[\t ]//g;/^$/d' ${valheimInstallPath}/steamapps/appmanifest_896660.acf > appmanilocal.log
      localValheim=$(sed -n '11p' appmanilocal.log)
      echo "Local Valheim Ver: $localValheim"
      if [ "$repoValheim" == "$localValheim" ]; then
        echo "No new Updates found"
        echo "Cleaning up TEMP FILES"
        rm -Rf /opt/valheimtemp
        rm appmanirepo.log
        rm appmanilocal.log
    sleep 2
    else
    echo "Update Found kicking process to Odin for updating!"
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
$(ColorRed '------------------------------------------------------------')"
echo ""
tput setaf 2; echo "The Script will download the Log Data from the official" ; tput setaf 9;
tput setaf 2; echo "Steam Valheim Repo and compare the data." ; tput setaf 9;
tput setaf 2; echo "No changes will be made, until you agree later." ; tput setaf 9;
tput setaf 2; echo "Press y(YES) and n(NO)" ; tput setaf 9;
echo -ne "
$(ColorRed '------------------------------------------------------------')"
echo ""
tput setaf 2; read -p "Do you wish to continue?" yn ; tput setaf 9; 
echo -ne "
$(ColorRed '------------------------------------------------------------')"
    case $yn in
        [Yy]* ) check_apply_server_updates_beta; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
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
$(ColorOrange '--------------------Stop Valheim Server---------------------')
$(ColorRed '------------------------------------------------------------')"
echo ""
tput setaf 2; echo "You are about to STOP the Valheim Server" ; tput setaf 9; 
tput setaf 2; echo "You are you sure y(YES) or n(NO)?" ; tput setaf 9; 
echo -ne "
$(ColorRed '------------------------------------------------------------')"
echo ""
 read -p "Please confirm:" confirmStop
#if y, then continue, else cancel
        if [ "$confirmStop" == "y" ]; then
    echo ""
    echo "Stopping Valheim Server Services"
    sudo systemctl stop valheimserver.service
    echo ""
    else
    echo "Canceling Stopping of Valheim Server Service - because Loki sucks"
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
$(ColorOrange '-------------------Start Valheim Server---------------------')
$(ColorRed '------------------------------------------------------------')"
echo ""
tput setaf 2; echo "You are about to START the Valheim Server" ; tput setaf 9;
tput setaf 2; echo "You are you sure y(YES) or n(NO)?" ; tput setaf 9;
echo -ne "
$(ColorRed '------------------------------------------------------------')"
echo ""
 read -p "Please confirm:" confirmStart
#if y, then continue, else cancel
        if [ "$confirmStart" == "y" ]; then
    echo ""
    tput setaf 2; echo "Starting Valheim Server with Thor's Hammer!!!!" ; tput setaf 9;
    sudo systemctl start valheimserver.service
    echo ""
    else
        echo "Canceling Starting of Valheim Server Service - because Loki sucks"
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
$(ColorOrange '------------------Restart Valheim Server--------------------')
$(ColorRed '------------------------------------------------------------')"
echo ""
tput setaf 2; echo "You are about to RESTART the Valheim Server" ; tput setaf 9; 
tput setaf 2; echo "You are you sure y(YES) or n(NO)?" ; tput setaf 9; 
echo -ne "
$(ColorRed '------------------------------------------------------------')"
echo ""
 read -p "Please confirm:" confirmRestart
#if y, then continue, else cancel
        if [ "$confirmRestart" == "y" ]; then
tput setaf 2; echo "Restarting Valheim Server with Thor's Hammer!!!!" ; tput setaf 9; 
    sudo systemctl restart valheimserver.service
    echo ""
    else
        echo "Canceling Restarting of Valheim Server Service - because Loki sucks"
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

$(ColorOrange '----------------Server System Information-------------------')
$(ColorOrange '-')$(ColorGreen '1)') Fresh or Reinstall Valheim Server
$(ColorOrange '-')$(ColorGreen '0)') Go to Main Menu
$(ColorOrange '------------------------------------------------------------')
$(ColorPurple 'Choose an option:') "
        read a
        case $a in
	        1) valheim_server_install ; server_install_menu ;;
           	    0) menu ; menu ;;
		    *)  echo -ne " $(ColorRed 'Wrong option.')" ; server_install_menu ;;
        esac
}
########################################################################
#########################Print System INFOS#############################
########################################################################
function display_system_info() {
clear
echo ""
    echo -e "-------------------------------System Information----------------------------"
    echo -e "Hostname:\t\t"`hostname`
    echo -e "uptime:\t\t\t"`uptime | awk '{print $3,$4}' | sed 's/,//'`
    echo -e "Manufacturer:\t\t"`cat /sys/class/dmi/id/chassis_vendor`
    echo -e "Product Name:\t\t"`cat /sys/class/dmi/id/product_name`
    echo -e "Version:\t\t"`cat /sys/class/dmi/id/product_version`
    echo -e "Serial Number:\t\t"`cat /sys/class/dmi/id/product_serial`
    echo -e "Machine Type:\t\t"`vserver=$(lscpu | grep Hypervisor | wc -l); if [ $vserver -gt 0 ]; then echo "VM"; else echo "Physical"; fi`
    echo -e "Operating System:\t"`hostnamectl | grep "Operating System" | cut -d ' ' -f5-`
    echo -e "Kernel:\t\t\t"`uname -r`
    echo -e "Architecture:\t\t"`arch`
    echo -e "Processor Name:\t\t"`awk -F':' '/^model name/ {print $2}' /proc/cpuinfo | uniq | sed -e 's/^[ \t]*//'`
    echo -e "Active User:\t\t"`w | cut -d ' ' -f1 | grep -v USER | xargs -n1`
    echo -e "System Main IP:\t\t"`hostname -I`
echo ""
    echo -e "-------------------------------CPU/Memory Usage------------------------------"
    echo -e "Memory Usage:\t"`free | awk '/Mem/{printf("%.2f %%"), $3/$2*100}'`
    echo -e "CPU Usage:\t"`cat /proc/stat | awk '/cpu/{printf("%.2f %%\n"), ($2+$4)*100/($2+$4+$5)}' |  awk '{print $0}' | head -1`
echo ""
    echo -e "-------------------------------Disk Usage >80%-------------------------------"
    df -Ph | sed s/%//g | awk '{ if($5 > 80) print $0;}'
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
$(ColorOrange '--------------------Valheim Tech Support--------------------')
$(ColorOrange '-')$(ColorGreen ' 1)') Display Valheim Config File
$(ColorOrange '-')$(ColorGreen ' 2)') Display Valheim Server Service
$(ColorOrange '-')$(ColorGreen ' 3)') Display World Data Folder
$(ColorOrange '-')$(ColorGreen ' 4)') Display System Info
$(ColorOrange '-')$(ColorGreen ' 5)') Display Network Info
$(ColorOrange '-')$(ColorGreen ' 6)') Display Connected Players History
$(ColorOrange '------------------------------------------------------------')
$(ColorOrange '-')$(ColorGreen ' 0)') Go to Main Menu
$(ColorOrange '------------------------------------------------------------')
$(ColorPurple 'Choose an option:') "
        read a
        case $a in
	        1) display_start_valheim ; tech_support ;; 
		2) display_valheim_server_status ; tech_support ;;
	        3) display_world_data_folder ; tech_support ;;
		4) display_system_info ; tech_support ;;
		5) display_network_info ; tech_support ;;
	        6) display_player_history ; tech_support ;;
		  0) menu ; menu ;;
		    *)  echo -ne " $(ColorRed 'Wrong option.')" ; tech_support ;;
        esac
}
########################################################################
########################Sub Admin Menu System###########################
########################################################################
admin_tools_menu(){
menu_header
echo ""
echo -ne "
$(ColorOrange '---------------Valheim Backup and Restore Tools-------------')
$(ColorOrange '-')$(ColorGreen ' 1)') Backup World (stop/starts Valheim)
$(ColorOrange '-')$(ColorGreen ' 2)') Restore World
$(ColorOrange '--------------------Valheim Service Tools-------------------')
$(ColorOrange '-')$(ColorGreen ' 3)') Stop Valheim Server
$(ColorOrange '-')$(ColorGreen ' 4)') Start Valheim Server
$(ColorOrange '-')$(ColorGreen ' 5)') Restart Valheim Server
$(ColorOrange '-')$(ColorGreen ' 6)') Status Valheim Server
$(ColorOrange '----------------Official Valheim Server Update--------------')
$(ColorOrange '-')$(ColorGreen ' 7)') Check and Apply Valheim Server Update
$(ColorOrange '-------------Edit start_valehim.sh Configuration------------')
$(ColorOrange '-')$(ColorGreen ' 8)') Display or Edit Valheim Config File
$(ColorOrange '------------------------------------------------------------')
$(ColorOrange '-')$(ColorGreen ' 0)') Go to Main Menu
$(ColorPurple 'Choose an option:') "
        read a
        case $a in
		1) backup_world_data ; admin_tools_menu ;;
		2) restore_world_data ; admin_tools_menu ;;
		3) stop_valheim_server ; admin_tools_menu ;;
		4) start_valheim_server ; admin_tools_menu ;;
		5) restart_valheim_server ; admin_tools_menu ;;
		6) display_valheim_server_status ; admin_tools_menu ;;
		7) confirm_check_apply_server_updates ; admin_tools_menu ;;
		8) admin_valheim_config_edit ; admin_tools_menu ;;		
		   0) menu ; menu ;;
		    *)  echo -ne " $(ColorRed 'Wrong option.')" ; admin_tools_menu ;;
        esac
}
#######################################################################################################################################################
#########################################################START VALHEIM PLUS SECTION####################################################################
#######################################################################################################################################################


function set_valheim_server_vanillaOrPlus_operations() {

#build systemctl configurations for execution of processes for Valheim Server
tput setaf 1; echo "Deleting old configuration if file exist" ; tput setaf 9; 
tput setaf 1; echo "Building systemctl instructions for Valheim" ; tput setaf 9; 
# remove old Valheim Server Service
[ -e /etc/systemd/system/valheimserver.service ] && rm /etc/systemd/system/valheimserver.service
# remove past Valheim Server Service
[ -e /lib/systemd/system/valheimserver.service ] && rm /lib/systemd/system/valheimserver.service
sleep 1
# Add new Valheim Server Service
# Thanks @QuadeHale
cat <<EOF > /lib/systemd/system/valheimserver.service 
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
EOF
if [ $valheimVanilla == 1]; then
   echo "Setting Server for Valheim Vanilla"
   {
   echo 'ExecStart=${valheimInstallPath}/start_valheim.sh'
   echo 'ExecStart=${valheimInstallPath}/start_game_bepinex.sh' 
   echo 'ExecReload=/bin/kill -s HUP \$MAINPID'
   echo 'KillSignal=SIGINT'
   echo 'WorkingDirectory=${valheimInstallPath}'
   echo 'LimitNOFILE=100000'
   echo '[Install]'
   echo 'WantedBy=multi-user.target'
   } >> start_valheim.sh
else 
   echo "Setting Server for Valheim Modded using Valheim+"
   {
   echo 'ExecStart=${valheimInstallPath}/start_game_bepinex.sh' >> lib/systemd/system/valheimserver.service
   echo 'ExecReload=/bin/kill -s HUP \$MAINPID'
   echo 'KillSignal=SIGINT'
   echo 'WorkingDirectory=${valheimInstallPath}'
   echo 'LimitNOFILE=100000'
   echo '[Install]'
   echo 'WantedBy=multi-user.target'
   } >> start_game_bepinex.sh
fi
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1
}

function install_valheim_plus() {
clear
    echo ""
    echo "Changing into Valheim Install Directory"
    cd $valheimInstallPath
    echo "Checking for older Valheim+ Package files and removing"
    [ -e UnixServer.zip ] && rm UnixServer.zip
    echo "Downloading Latest Valheim+ UnixServer.zip from Official Github"
    wget https://github.com/valheimPlus/ValheimPlus/releases/download/0.9.3/UnixServer.zip
    echo "Unpacking zip file"
    unzip -o UnixServer.zip
    echo "Removing old bepinex config"
    [ ! -e start_game_bepinex.sh ] && rm start_game_bepinex.sh
    echo "Building Start Configuration File for Modded Server with bepinex filled information"
    build_start_server_bepinex_configuration_file
    echo "Setting steam ownership to Directories, Folders and Files"
    chown steam:steam -Rf /home/steam/*
    chmod +x start_game_bepinex.sh
    echo ""
    echo "Who wants to get their Viking mod on HUH!"
    echo "Let's GO!!!!"
}
function valheim_plus_enable() {
clear
    echo ""
    echo "Valheim+ Enable"
    set_valheim_server_vanillaOrPlus_operations
    echo "Coming Soon"
    echo ""
}
function valheim_plus_disable() {
clear
    echo ""
    echo "Valheim+ Disable"
    echo "Coming Soon"
    echo ""
}
function valheim_plus_start() {
clear
    echo ""
    echo "Valheim+ Starting"
    echo "Coming Soon"
    echo ""
}
function valheim_plus_stop() {
clear
    echo ""
    echo "Valheim+ Stopping"
    echo "Coming Soon"
    echo ""
}
function valheim_plus_restart() {
clear
    echo ""
    echo "Valheim+ Restarting"
    echo "Coming Soon"
    echo ""
}
function valheim_plus_status() {
clear
    echo "Scripting As Fast as I can"
    echo "Valheim+ Status"
    echo "Coming Soon"
    echo ""
}
function valheim_plus_update() {
clear
    echo "Scripting As Fast as I can"
    echo "Valheim+ Update"
    #valheimplus_type=UnixServer.zip
    #$vplusdl=(curl -s https://api.github.com/valheimPlus/ValheimPlus/releases/latest | jq -r ".assets[] | select(.name | test(\"${valheimplus_type}\")) | .browser_download_url")
    #wget ${vplusdl}
    #do stuff duh
    echo ""
}
function valheim_mod_options() {
clear
    echo "Scripting As Fast as I can"
    echo "Valheim+ Mod Options"
    echo "Coming Soon"
    echo ""
}
function remove_mod_valheim() {
clear
    echo ""
    echo "Deleting Valheim+ Mods from server"
    echo "Coming Soon"
    echo ""
}
########################################################################
######################START MOD SECTION AREAS###########################
########################################################################
function server_mods() {
    clear
    echo "Scripting As Fast as I can"
    echo "Server Related Mods"
    echo "Coming Soon"
    echo ""
}
function player_mods() {
    clear
    echo "Scripting As Fast as I can"
    echo "Player Related Mods"
    echo "Coming Soon"
    echo ""
}
function building_mods() {
    clear
    echo "Scripting As Fast as I can"
    echo "Building Related Mods"
    echo "Coming Soon"
    echo ""
}
function other_mods() {
    clear
    echo "Scripting As Fast as I can"
    echo "Other Related Mods"
    echo "Coming Soon"
    echo ""
}


function build_start_server_bepinex_configuration_file() {
  cat > ${valheimInstallPath}/start_server_bepinex.sh <<'EOF'
#!/bin/sh
# BepInEx running script
#
# This script is used to run a Unity game with BepInEx enabled.
#
# Usage: Configure the script below and simply run this script when you want to run your game modded.

# -------- SETTINGS --------
# ---- EDIT AS NEEDED ------

# EDIT THIS: The name of the executable to run
# LINUX: This is the name of the Unity game executable [preconfigured]
# MACOS: This is the name of the game app folder, including the .app suffix [must provide if needed]
executable_name="valheim_server.x86_64"

# EDIT THIS: Valheim server parameters
# Can be overriden by script parameters named exactly like the ones for the Valheim executable
# (e.g. ./start_server_bepinex.sh -name "MyValheimPlusServer" -password "somethingsafe" -port 2456 -world "myworld" -public 1)
server_name="$(perl -n -e '/\-name "?([^"]+)"? \-port/ && print "$1\n"' start_valheim.sh)"
server_port="$(perl -n -e '/\-port "?([^"]+)"? \-nographics/ && print "$1\n"' start_valheim.sh)"
server_world="$(perl -n -e '/\-world "?([^"]+)"? \-password/ && print "$1\n"' start_valheim.sh)"
server_password="$(perl -n -e '/\-password "?([^"]+)"? \-public/ && print "$1\n"' start_valheim.sh)"
server_public="$(perl -n -e '/\-public "?([^"]+)"?$/ && print "$1\n"' start_valheim.sh)"

# The rest is automatically handled by BepInEx for Valheim+

# Whether or not to enable Doorstop. Valid values: TRUE or FALSE
export DOORSTOP_ENABLE=TRUE
# What .NET assembly to execute. Valid value is a path to a .NET DLL that mono can execute.
export DOORSTOP_INVOKE_DLL_PATH="${PWD}/BepInEx/core/BepInEx.Preloader.dll"
# Which folder should be put in front of the Unity dll loading path
export DOORSTOP_CORLIB_OVERRIDE_PATH=./unstripped_corlib
# ----- DO NOT EDIT FROM THIS LINE FORWARD  ------
# ----- (unless you know what you're doing) ------
if [ ! -x "$1" -a ! -x "$executable_name" ]; then
	echo "Please open start_server_bepinex.sh in a text editor and provide the correct executable."
	exit 1
fi
doorstop_libs="${PWD}/doorstop_libs"
arch=""
executable_path=""
lib_postfix=""
os_type=`uname -s`
case $os_type in
	Linux*)
		executable_path="${PWD}/${executable_name}"
		lib_postfix="so"
		;;
	Darwin*)
		executable_name=`basename "${executable_name}" .app`
		real_executable_name=`defaults read "${PWD}/${executable_name}.app/Contents/Info" CFBundleExecutable`
		executable_path="${PWD}/${executable_name}.app/Contents/MacOS/${real_executable_name}"
		lib_postfix="dylib"
		;;
	*)
		echo "Cannot identify OS (got $(uname -s))!"
		echo "Please create an issue at https://github.com/BepInEx/BepInEx/issues."
		exit 1
		;;
esac
executable_type=`LD_PRELOAD="" file -b "${executable_path}"`;
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
export LD_LIBRARY_PATH="${doorstop_libs}":${LD_LIBRARY_PATH}
export LD_PRELOAD=$doorstop_libname:$LD_PRELOAD
export DYLD_LIBRARY_PATH="${doorstop_libs}"
export DYLD_INSERT_LIBRARIES="${doorstop_libs}/$doorstop_libname"
export templdpath=$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH
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
	esac
done
"${PWD}/${executable_name}" -name "$server_name" -password "$server_password" -port "$server_port" -world "$server_world" -public "$server_public"
EOF
}


########################################################################
######################END MOD SECTION AREAS###########################
########################################################################
function valheim_mods_options(){
echo ""
menu_header_vplus_enable
echo -ne "
$(ColorRed '--------NOT ADDED YET BUILDING FRAME WORK--------')
$(ColorCyan '--------------Valheim+ Mod Menu-----------------')
$(ColorCyan '-')$(ColorGreen ' 1)') Server Mods
$(ColorCyan '-')$(ColorGreen ' 2)') Player Mods
$(ColorCyan '-')$(ColorGreen ' 3)') Building Mods
$(ColorCyan '-')$(ColorGreen ' 4)') Other Mods
$(ColorCyan '------------------------------------------------')
$(ColorCyan '-')$(ColorGreen ' 0)') Go to Valheim Mod Main Menu
$(ColorCyan '-')$(ColorGreen ' 00)') Go to Main Menu
$(ColorPurple 'Choose an option:') "
        read a
        case $a in
		1) server_mods ; valheim_mods_options ;;
		2) player_mods ; valheim_mods_options ;;
		3) building_mods ; valheim_mods_options ;;
		4) other_mods ; valheim_mods_options ;;
		   0) mods_menu ; menu ;;
		   00) menu ; menu ;;
		    *)  echo -ne " $(ColorRed 'Wrong option.')" ; valheim_mods_options ;;
        esac
}
function mods_menu(){
echo ""
menu_header_vplus_enable
echo -ne "
$(ColorCyan '-------Valheim+ Mod Install Remove Update-------')
$(ColorCyan '-')$(ColorGreen ' 1)') Install Valheim Mods 
$(ColorCyan '--------------SUPER FREAKING BETA---------------')
$(ColorCyan '-')$(ColorGreen ' 2)') Enable Valheim+ on Server
$(ColorCyan '-')$(ColorGreen ' 3)') Disable Valheim+ on Server
$(ColorCyan '-')$(ColorGreen ' 4)') Start Valheim+ Service 
$(ColorCyan '-')$(ColorGreen ' 5)') Stop Valheim+ Service
$(ColorCyan '-')$(ColorGreen ' 6)') Restart Valheim+ Service
$(ColorCyan '-')$(ColorGreen ' 7)') Status Valheim+ Service 
$(ColorCyan '-')$(ColorGreen ' 8)') Update Valheim+ File System
$(ColorCyan '--------------Valheim+ Mod Menu-----------------')
$(ColorCyan '-')$(ColorGreen ' 9)') Valheim+ Mods Options
$(ColorCyan '------------------------------------------------')
$(ColorCyan '-')$(ColorGreen ' 10)') Remove Valheim Mods 
$(ColorCyan '------------------------------------------------')
$(ColorCyan '-')$(ColorGreen ' 0)') Go to Main Menu
$(ColorPurple 'Choose an option:') "
        read a
        case $a in
		1) install_valheim_plus ; mods_menu ;;
		2) valheim_plus_enable ; mods_menu ;;
		3) valheim_plus_disble ; mods_menu ;;
		4) valheim_plus_start ; mods_menu ;;
		5) valheim_plus_stop ; mods_menu ;;
		6) valheim_plus_restart ; mods_menu ;;
		7) valheim_plus_status ; mods_menu ;;
		8) valheim_plus_update ; mods_menu ;;
		9) valheim_mods_options ; mods_menu ;;
		10) remove_mod_valheim ; mods_menu ;;
		   0) menu ; menu ;;
		    *)  echo -ne " $(ColorRed 'Wrong option.')" ; mods_menu ;;
        esac
}
#######################################################################################################################################################
###############################################################FINISH VALHEIM MOD SECTION##############################################################
#######################################################################################################################################################

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
    clear
    echo "Current Public Server Name:-------------> $(tput setaf 2)${currentDisplayName} $(tput setaf 9) "
    echo "Current Port Information(default:2456):-> $(tput setaf 2)${currentPort} $(tput setaf 9) "
    echo "Current Local World Name:---------------> $(tput setaf 2)${currentWorldName} $(tput setaf 1) Do not change unless you know what you are doing $(tput setaf 9)"
    echo "Current Server Access Password:---------> $(tput setaf 2)${currentPassword} $(tput setaf 9) "
    echo "Current Public Option is:---------------> $(tput setaf 2)${currentPublicSet}  $(tput setaf 9)          0 Is OFF or LAN Parties - 1  ON for Public Listing"
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
    tput setaf 1; echo "Rebuilding Valheim start_valheim.sh configuration file" ; tput setaf 9;
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
   echo "Setting Ownership to steam user and execute permissions on " ${valheimInstallPath}/start_valheim.sh
   chown steam:steam ${valheimInstallPath}/start_valheim.sh
   chmod +x ${valheimInstallPath}/start_valheim.sh
   echo "done"
   echo "Restarting Valheim Server Service"
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
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 2; echo "------------------Set New Public Display Name---------------" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 1; echo "Now for Loki, please follow instructions" ; tput setaf 9;
    tput setaf 1; echo "The Server is required to have a public display name" ; tput setaf 9;
    tput setaf 1; echo "Do not use SPECIAL characters:" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 2; echo "Current Public Display Name: ${currentDisplayName}" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    echo ""
    read -p "Enter new public server display name: " setCurrentDisplayName
    echo ""
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    echo ""
    tput setaf 5; echo "Old Public Display Name: " ${currentDisplayName} ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    echo ""
    tput setaf 1; echo "New Public Display Name:" ${setCurrentDisplayName} ; tput setaf 9;
    echo ""
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    echo ""
    read -p "Do you wish to continue with these changes? (y=Yes, n=No):" confirmPublicNameChange
    #if y, then continue, else cancel
    if [ "$confirmPublicNameChange" == "y" ]; then
        write_config_and_restart
    else
        echo "Canceled the renaming of Public Valheim Server Display Name - because Loki sucks"
        sleep 3
        clear
    fi
}
    
function change_default_server_port() {
    get_current_config
    print_current_config
    set_config_defaults
    echo ""
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 2; echo "---------------------Set New Server Port--------------------" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 1; echo "Now for Loki, please follow instructions" ; tput setaf 9;
    tput setaf 1; echo "The Server is required to have a port to operate on" ; tput setaf 9;
    tput setaf 1; echo "Do not use SPECIAL characters:" ; tput setaf 9;
    tput setaf 1; echo "New assigned port must be greater than 3000:" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 2; echo "Current Server Port: ${currentPort} " ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    echo ""
    while true; do
        read -p "Enter new Server Port (Default:2456): " setCurrentPort
        echo ""
         #check to make sure nobody types stupid Loki Jokes in here
        [[ ${#setCurrentPort} -ge 4 && ${#setCurrentPort} -le 6 ]] && [[ $setCurrentPort -gt 1024 && $setCurrentPort -le 65530 ]] && [[ "$setCurrentPort" =~ ^[[:alnum:]]+$ ]] && break
        echo ""
        echo "Try again, Loki got you or you typed something wrong or your port range is incorrect"
    done
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 5; echo "Old Server Port: " ${currentPort} ; tput setaf 9;
    tput setaf 6; echo "New Server Port: " ${setCurrentPort} ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    read -p "Do you wish to continue with these changes? (y=Yes, n=No):" confirmServerPortChange
    echo ""
    #if y, then continue, else cancel
    if [ "$confirmServerPortChange" == "y" ]; then
        write_config_and_restart
    else
        echo "Canceled the changing of Server Port for Valheim - because Loki sucks"
        sleep 3
        clear
    fi
}

function change_local_world_name() {
    echo ""
    echo "Not sure if I should allow people to do this"
    echo "Follow the wiki, if you feel the need to change your world name"
    echo "https://github.com/Nimdy/Dedicated_Valheim_Server_Script/wiki/Migrate-Valheim-Map-Data-from-server-to-server"
    echo "I fear too many people will end up breaking their servers, if I add this now"
    echo "Don't you have some bees to go check on?"
    echo ""
}

function change_server_access_password() {
    get_current_config
    print_current_config
    set_config_defaults
    echo ""
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 2; echo "---------------Set New Server Access Password---------------" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 1; echo "Now for Loki, please follow instructions" ; tput setaf 9;
    tput setaf 1; echo "Valheim requires a UNIQUE password 6 characaters or longer" ; tput setaf 9;
    tput setaf 1; echo "UNIQUE means Password can not match Public and World Names" ; tput setaf 9;
    tput setaf 1; echo "Do not use SPECIAL characters:" ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 5; echo "Current Public Display Name:" ${currentDisplayName} ; tput setaf 9;
    tput setaf 5; echo "Current World Name:" ${currentWorldName} ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    tput setaf 2; echo "Current Access Password: ${currentPassword} " ; tput setaf 9;
    tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
    while true; do
        tput setaf 1; echo "This password must be 5 Characters or more" ; tput setaf 9;
        tput setaf 1; echo "At least one number, one uppercase letter and one lowercase letter" ; tput setaf 9;
        tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
        tput setaf 2; echo "Good Example: Viking12" ; tput setaf 9;
        tput setaf 1; echo "Bad Example: Vik!" ; tput setaf 9;
        tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
        read -p "Enter Password to Enter your Valheim Server: " setCurrentPassword
        tput setaf 2; echo "------------------------------------------------------------" ; tput setaf 9;
        [[ ${#setCurrentPassword} -ge 5 && "$setCurrentPassword" == *[[:lower:]]* && "$setCurrentPassword" == *[[:upper:]]* && "$setCurrentPassword" =~ ^[[:alnum:]]+$ ]] && break
        tput setaf 2; echo "Password not accepted - Too Short, Special Characters" ; tput setaf 9;
        tput setaf 2; echo "I swear to LOKI, you better NOT use Special Characters" ; tput setaf 9;
    done
    echo ""
    tput setaf 5; echo "Old Server Access Password:" ${currentPassword} ; tput setaf 9;
    tput setaf 5; echo "New Server Access Password:" ${setCurrentPassword} ; tput setaf 9;
    read -p "Do you wish to continue with these changes? (y=Yes, n=No):" confirmServerAccessPassword
    #if y, then continue, else cancel
    if [ "$confirmServerAccessPassword" == "y" ]; then
        write_config_and_restart
    else
        echo "Canceled the renaming of Public Valheim Server Display Name - because Loki sucks"
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
function admin_valheim_config_edit(){
echo ""
menu_header
echo -ne "
$(ColorOrange '-------Change Valheim Startup Config File-------')
$(ColorOrange '-')$(ColorGreen ' 1)') Display Current Start Vahleim Config
$(ColorOrange '-')$(ColorGreen ' 2)') Change Public Display Name
$(ColorOrange '-')$(ColorGreen ' 3)') Change Default Server Port
$(ColorOrange '-')$(ColorGreen ' 4)') Change Local World Name
$(ColorOrange '-')$(ColorGreen ' 5)') Change Server Access Password
$(ColorOrange '------------------------------------------------')
$(ColorOrange '-')$(ColorGreen ' 6)') Enable Public Listing (Restarts Valheim without asking)
$(ColorOrange '-')$(ColorGreen ' 7)') Disable Public Listing (Restarts Valehim without asking)
$(ColorOrange '------------------------------------------------')
$(ColorOrange '-')$(ColorGreen ' 0)') Go to Admin Tools Menu
$(ColorOrange '-')$(ColorGreen ' 00)') Go to Main Menu
$(ColorOrange '------------------------------------------------')
$(ColorPurple 'Choose an option:') "
        read a
        case $a in
		1) display_full_config ; admin_valheim_config_edit ;; 
	        2) change_public_display_name ; admin_valheim_config_edit ;; 
		3) change_default_server_port ; admin_valheim_config_edit ;;
	        4) change_local_world_name ; admin_valheim_config_edit ;;
		5) change_server_access_password ; admin_valheim_config_edit ;;
		6) write_public_on_config_and_restart ; admin_valheim_config_edit ;;
		7) write_public_off_config_and_restart ; admin_valheim_config_edit ;;
		  0) admin_tools_menu ; admin_tools_menu ;;
		  00) menu ; menu ;;
		    *)  echo -ne " $(ColorRed 'Wrong option.')" ; tech_support ;;
        esac
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
        echo "No Data";
  fi
}

# Check Local Valheim Build for menu display
function check_local_valheim_build() {
localValheimAppmanifest=${valheimInstallPath}/steamapps/appmanifest_896660.acf
   if [[ -e $localValheimAppmanifest ]] ; then
    localValheimBuild=$(grep buildid ${localValheimAppmanifest} | cut -d'"' -f4)
        echo $localValheimBuild
    else 
        echo "No Data";
  fi
}

function check_menu_script_repo() {

latestScript=$(curl --connect-timeout 10 -s https://api.github.com/repos/Nimdy/Dedicated_Valheim_Server_Script/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
echo $latestScript
}

function display_public_status_on_or_off() {
get_current_config
    if [[ $currentPublicSet == 1 ]]; then 
      publicON=$(echo "On")
    else
      publicOFF=$(echo "Off")
  fi
}


function display_public_IP() {
externalip=$(curl -s ipecho.net/plain;echo)
echo -e '\E[32m'"External IP : $whateverzerowantstocalthis "$externalip ; tput setaf 9;
}

function display_local_IP() {
internalip=$(hostname -I)
echo -e '\E[32m'"Internal IP :" $mymommyboughtmeaputerforchristmas $internalip ; tput setaf 9;

}

function are_you_connected() {
ping -c 1 google.com &> /dev/null && echo -e '\E[32m'"Internet: $tecreset Connected" || echo -e '\E[32m'"Internet: $tecreset Disconnected"

}

function menu_header() {
get_current_config
display_public_status_on_or_off
echo -ne "
$(ColorOrange '╔═══════════════════════════════════════════════╗')
$(ColorOrange '║~~~~~~~~~~~~~~~~~~-Njord Menu-~~~~~~~~~~~~~~~~~║')
$(ColorOrange '╠═══════════════════════════════════════════════╝')
$(ColorOrange '║ Welcome Viking! Do not forget about your bees')
$(ColorOrange '║ Visit our discord: https://discord.gg/ejgQUfc')
$(ColorOrange '║ Beware Loki hides within this script')
$(ColorOrange '║') 
$(ColorOrange '║') Valheim Official Build:" $(check_official_valheim_release_build)
echo -ne "
$(ColorOrange '║') Valheim Server Build:" $(check_local_valheim_build)
echo -ne "
$(ColorOrange '║') Server Name: ${currentDisplayName}
$(ColorOrange '║') $(are_you_connected)
$(ColorOrange '║')" $(display_public_IP)
echo -ne "
$(ColorOrange '║')" $(display_local_IP)
echo -ne "
$(ColorOrange '║') Your Server Port:" ${currentPort}
echo -ne "
$(ColorOrange '║') Public Listing:" $publicON $publicOFF
echo -ne "
$(ColorOrange '║') Current Menu Release: $(check_menu_script_repo)
$(ColorOrange '║') Local Installed Menu: ${mversion}
$(ColorOrange '║') Happy Gaming - ZeroBandwidth
$(ColorOrange '╚═══════════════════════════════════════════════')"
}

function menu_header_vplus_enable() {
get_current_config
display_public_status_on_or_off
echo -ne "
$(ColorPurple '╔════════════════════Valheim+═══════════════════╗')
$(ColorPurple '║~~~~~~~~~~~~~~~~~~-Njord Menu-~~~~~~~~~~~~~~~~~║')
$(ColorPurple '╠═══════════════════════════════════════════════╝')
$(ColorPurple '║ Welcome Viking! Do not forget about your bees')
$(ColorPurple '║ Visit our discord: https://discord.gg/ejgQUfc')
$(ColorPurple '║ Beware Loki hides within this script')
$(ColorPurple '║') 
$(ColorPurple '║') Valheim Official Build:" $(check_official_valheim_release_build)
echo -ne "
$(ColorPurple '║') Valheim Server Build:" $(check_local_valheim_build)
echo -ne "
$(ColorPurple '║') Server Name: ${currentDisplayName}
$(ColorPurple '║') $(are_you_connected)
$(ColorPurple '║')" $(display_public_IP)
echo -ne "
$(ColorPurple '║')" $(display_local_IP)
echo -ne "
$(ColorPurple '║') Your Server Port:" ${currentPort}
echo -ne "
$(ColorPurple '║') Public Listing:" $publicON $publicOFF
echo -ne "
$(ColorPurple '║') Current Menu Release: $(check_menu_script_repo)
$(ColorPurple '║') Local Installed Menu: ${mversion}
$(ColorPurple '║') Happy Gaming - ZeroBandwidth
$(ColorPurple '╚═══════════════════════════════════════════════')"
}

########################################################################
#######################Display Main Menu System#########################
########################################################################
menu(){
#get_current_config
menu_header
echo -ne "
$(ColorOrange '-------------Check for Script Updates-----------')
$(ColorOrange '-')$(ColorGreen ' 1)') Update Menu Script from GitHub
$(ColorOrange '--------------Valheim Server Commands-----------')
$(ColorOrange '-')$(ColorGreen ' 2)') Server Admin Tools 
$(ColorOrange '-')$(ColorGreen ' 3)') Tech Support Tools
$(ColorOrange '-')$(ColorGreen ' 4)') Install Valheim Server
$(ColorOrange '---------Official Valheim Server Update---------')
$(ColorOrange '-')$(ColorGreen ' 5)') Check and Apply Valheim Server Update
$(ColorOrange '-----Edit start_valehim.sh Configuration--------')
$(ColorOrange '-')$(ColorGreen ' 6)') Display or Edit Valheim Config File
$(ColorOrange '------------------Valheim+ Menu-----------------')
$(ColorOrange '-')$(ColorGreen ' 7)') Valiheim+
$(ColorOrange '------------------------------------------------')
$(ColorGreen ' 0)') Exit
$(ColorOrange '------------------------------------------------')
$(ColorPurple 'Choose an option:') "
        read a
        case $a in
	        1) script_check_update ; menu ;;
		2) admin_tools_menu ; menu ;;
		3) tech_support ; menu ;;
		4) server_install_menu ; menu ;;
		5) confirm_check_apply_server_updates ; menu ;;	
	        6) admin_valheim_config_edit ; menu ;;
		7) mods_menu ; menu ;;
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
