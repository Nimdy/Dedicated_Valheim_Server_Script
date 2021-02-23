#!/bin/bash
# 
# If Frankenstein was a bash script
# Please help improve this script
# Easy Valheim Server Menu
# Open to other commands that should be used... 
clear
###############################################################
#Only change this if you know what you are doing
#Valheim Server Install location(Default) 
worldpath=/home/steam/.config/unity3d/IronGate/Valheim/worlds
#Backup Directory (Default)
backupPath=/home/steam/backups
###############################################################

# Set Menu Version
mversion="Version 1.0"
##
# System script that checks:
#   - Display System Info
#   - Display Network Info
##
##
# Server Install:
#   - Install or Reinstall - Valheim Server
##
##
# Server Tools:
# Do Manual Backup
# Do Manual Restore | Make sure -world and whatever.db and whatever.fwl are the same
# Stop Valheim Server
# Start Valheim Server
# Restart Valheim Server
# Display Valheim Server Status
# Check for Official Valheim updates and apply them
##
##
# Tech Support Tools
# Display start_valheim.sh configuration
# Display Valheim Server Status
# Display Valheim World Data Folder
##
##
# Color  Variables
##


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



function script_check_update() {
BRANCH="https://github.com/Nimdy/Dedicated_Valheim_Server_Script/tree/main"
    git stash
    LAST_UPDATE=`git show --no-notes --format=format:"%H" $BRANCH | head -n 1`
    LAST_COMMIT=`git show --no-notes --format=format:"%H" origin/$BRANCH | head -n 1`
        if [ $LAST_COMMIT != $LAST_UPDATE ]; then
            echo "Updating your branch $BRANCH"
            git pull --no-edit
        else
            echo "No updates available"
        fi
}

function system_info() {
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
    echo -e "Memory Usage:\t"`free | awk '/Mem/{printf("%.2f%"), $3/$2*100}'`
    echo -e "CPU Usage:\t"`cat /proc/stat | awk '/cpu/{printf("%.2f%\n"), ($2+$4)*100/($2+$4+$5)}' |  awk '{print $0}' | head -1`
echo ""
    echo -e "-------------------------------Disk Usage >80%-------------------------------"
    df -Ph | sed s/%//g | awk '{ if($5 > 80) print $0;}'
echo ""
}

function network_info() {
echo ""
sudo netstat -atunp | grep valheim
echo ""

}

function all_checks() {
	system_info
	network_info
}

function confirmed_valheim_install() {
    #check for updates and upgrade the system auto yes
    tput setaf 2; echo "Checking for upgrades" ; tput setaf 9;
    apt update && apt upgrade -y
    tput setaf 2; echo "Done" ; tput setaf 9;
    sleep 1

tput setaf 2; echo "Install Git and Net-Tools" ; tput setaf 9;
apt install git net-tools -y
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1

#add multiverse repo
    tput setaf 2; echo "Adding multiverse REPO" ; tput setaf 9;
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
    echo "This account is named steam"
    while true; do
      echo "Password must be 5 Characters or more"
      echo "At least one number, one uppercase letter and one lowercase letter"
      tput setaf 2;  echo "Good Example: Viking12" ; tput setaf 9;
      tput setaf 1;  echo "Bad Example: Vik!" ; tput setaf 9;
      echo ""
        read -p "Please give steam a password: " userpassword
            [[ ${#userpassword} -ge 5 && "$userpassword" == *[[:lower:]]* && "$userpassword" == *[[:upper:]]* && "$userpassword" =~ ^[[:alnum:]]+$ ]] && break
      tput setaf 2; echo "Password not accepted - Too Short or has Special Characters" ; tput setaf 9;
      tput setaf 2; echo "I swear to LOKI, you better NOT use Special Characters" ; tput setaf 9; 
    done
    clear
    echo ""
    # Take user input for Valheim Server Public Display
    echo ""
    echo "Enter a name for your Valheim Server"
    echo "This is for the Public Steam Browser Listing"
    read -p "Enter public server display name: " displayname
    echo ""
    clear
    # Take user input for Valheim Server World Database Generation
    echo ""
    echo "What do you want to call your in game world?"
    while true; do
        echo "Name must be 8 Characters or more"
        echo "No Special Characters not even a space"
	tput setaf 2;  echo "Good Example: ThorsHammer" ; tput setaf 9;
        tput setaf 1;  echo "Bad Example: Loki is a Trickster" ; tput setaf 9;
        read -p "Please make a world name: " worldname
            [[ ${#worldname} -ge 8 && "$worldname" =~ ^[[:alnum:]]+$ ]] && break
        tput setaf 2;  echo "World Name not set: Too Short or has Special Characters" ; tput setaf 9; 
	tput setaf 2; echo "I swear to LOKI, you better NOT use Special Characters" ; tput setaf 9; 
    done
    clear
    echo ""
    # Password for Server
    echo ""
    echo "Now for Loki, please follow instructions"
    echo "Your server is required to have a password"
    echo "Your password cannot match your public display name nor world name"
    echo "Make your password unique"
    tput setaf 2; echo "Your public display name: $displayname " ; tput setaf 9;
    tput setaf 2; echo "Your world name: $worldname " ; tput setaf 9;
    while true; do
    echo "This password must be 5 Characters or more"
    echo "At least one number, one uppercase letter and one lowercase letter"
    tput setaf 2;  echo "Good Example: Viking12" ; tput setaf 9;
    tput setaf 1;  echo "Bad Example: Vik!" ; tput setaf 9;
    read -p "Enter Password to Enter your Valheim Server: " password
        [[ ${#password} -ge 5 && "$password" == *[[:lower:]]* && "$password" == *[[:upper:]]* && "$password" =~ ^[[:alnum:]]+$ ]] && break
    tput setaf 2; echo "Password not accepted - Too Short, Special Characters" ; tput setaf 9; 
    tput setaf 2; echo "I swear to LOKI, you better NOT use Special Characters" ; tput setaf 9;
    echo ""
    clear
    echo ""
done
# Server port
echo ""
echo "Do you want to change the port used by the server ?"
read -p "Enter the port used by the Valheim Server (default=2456): " -i 2456 -e port
clear
echo "Here is the information you entered"
echo "This information is only saved in the valheim_server.sh file"
tput setaf 2; echo "---------------------------------------" ; tput setaf 9;
tput setaf 2; echo "nonroot steam password:  $userpassword " ; tput setaf 9;
tput setaf 2; echo "Public Server Name:      $displayname " ; tput setaf 9;
tput setaf 2; echo "Local World Name:        $worldname " ; tput setaf 9;
tput setaf 2; echo "Valheim Server Password: $password " ; tput setaf 9;
tput setaf 2; echo "Valheim Server Port: $port " ; tput setaf 9;
tput setaf 2; echo "---------------------------------------" ; tput setaf 9;
echo ""
sleep 5

#install steamcmd and libsd12-2
tput setaf 1; echo "Installing steamcmd and libsdl2"
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
chown steam:steam /home/steam/steamcmd
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1

#Download Valheim from steam
tput setaf 1; echo "Downloading and installing Valheim from Steam" ; tput setaf 9;
sleep 1
/home/steam/steamcmd +login anonymous +force_install_dir /home/steam/valheimserver +app_update 896660 validate +exit
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1

#build config for start_valheim.sh
tput setaf 1; echo "Deleting old configuration if file exist" ; tput setaf 9;  
tput setaf 1; echo "Building Valheim start_valheim server configuration" ; tput setaf 9;
rm /home/steam/valheimserver/start_valheim.sh
sleep 1
cat >> /home/steam/valheimserver/start_valheim.sh <<EOF
#!/bin/bash
export templdpath=$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH
export SteamAppId=892970
# Tip: Make a local copy of this script to avoid it being overwritten by steam.
# NOTE: You need to make sure the ports 2456-2458 is being forwarded to your server through your local router & firewall.
./valheim_server.x86_64 -name $displayname -port $port -nographics -batchmode -world $worldname -password $password
export LD_LIBRARY_PATH=$templdpath
EOF
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1

#build check log script
tput setaf 1; echo "Deleting old configuration if file exist" ; tput setaf 9; 
tput setaf 1; echo "Building check log script" ; tput setaf 9;
rm /home/steam/check_log.sh
sleep 1
cat >> /home/steam/check_log.sh <<EOF
journalctl --unit=valheimserver --reverse
EOF
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1

#set execute permissions
tput setaf 1; echo "Setting execute permissions on start_valheim.sh" ; tput setaf 9;
chmod +x /home/steam/valheimserver/start_valheim.sh
tput setaf 2; echo "Done" ; tput setaf 9;
tput setaf 1; echo "Setting execute permissions on check_log.sh" ; tput setaf 9; 
chmod +x /home/steam/check_log.sh
tput setaf 2; echo "Done" ; tput setaf 9;
sleep 1

#build systemctl configurations for execution of processes for Valheim Server
tput setaf 1; echo "Deleting old configuration if file exist" ; tput setaf 9; 
tput setaf 1; echo "Building systemctl instructions for Valheim" ; tput setaf 9; 
# remove old Valheim Server Service
rm /etc/systemd/system/valheimserver.service
# remove past Valheim Server Service
rm /lib/systemd/system/valheimserver.service
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
ExecStartPre=/home/steam/steamcmd +login anonymous +force_install_dir /home/steam/valheimserver +app_update 896660 validate +exit
ExecStart=/home/steam/valheimserver/start_valheim.sh
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGINT
WorkingDirectory=/home/steam/valheimserver
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
tput setaf 2; echo "Twitch: ZeroBandwidth"
tput setaf 2; echo "GLHF"
tput setaf 9;
echo ""
}

function valheim_update_check() {
#default install dir
valheiminstall=/home/steam/valheimserver/
#make temp directory for this Loki file dump
vaheiminstall_temp=/tmp/lokidump/
loki_started=true

dltmpdir=vaheiminstall_temp
[ ! -d "$dltmpdir" ] && mkdir -p "$dltmpdir"

    logfile="$(mktemp)"
    echo "Update and Check Valheim Server"
    steamcmd +login anonymous +force_install_dir $valheiminstall_temp +app_update 896660 -validate +quit
    rsync -a --chown=steam:steam--itemize-changes --delete --exclude server_exit.drp --exclude steamapps --exclude start_valheim.sh $valheiminstall_temp $valheiminstall | tee "$logfile"
    grep '^[*>]' "$logfile" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Valheim Server was updated - restarting"
        systemctl restart valheimserver.service
    else
        echo "Valheim Server is already the latest version"
        if [ $loki_started = true ]; then
            systemctl start valheimserver.service
        fi
    fi
    loki_started=false
    rm -f "$logfile"

}

function valheim_server_install() {

while true; do
$(ColorRed '--------------------------------------')
tput setaf 2; read -p "Do you wish to install Valheim Server?" yn ; tput setaf 9;
$(ColorRed '--------------------------------------')
    case $yn in
        [Yy]* ) confirmed_valheim_install; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done;

}


function backup_world_data() {
    echo ""
    echo ""
         ## Get the current date as variable.
         TODAY="$(date +%Y-%m-%d-%X)"
	 
	 dldir=$backupPath
	 [ ! -d "$dldir" ] && mkdir -p "$dldir"
         
         ## Clean up files older than 2 weeks. Create a new backup.
         find $backupPath/* -mtime +14 -type f -delete

         ## Tar Section. Create a backup file, with the current date in its name.
         ## Add -h to convert the symbolic links into a regular files.
         ## Backup some system files, also the entire `/home` directory, etc.
         ##--exclude some directories, for example the the browser's cache, `.bash_history`, etc.
         tar czf $backupPath/valheim-backup-$TODAY.tgz $worldpath/*
	 chown -Rf steam:steam /home/steam/backups
         chown -Rf steam:steam $backupPath/*
    echo ""

}


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
    echo "Select Backup File you wish to restore"
    read -p "" selectedIndex
#show confirmation message


restorefile=$(basename "${backups[$selectedIndex-1]}")
    echo "${restorefile}"
    echo "Restore "${restorefile}" ?"
    echo "Are you sure you want to do this?"
    echo "Remember to match world name with /home/steam/valheimserver/start_valheim.sh"
    echo "The param for -world "worldname" much match restore file worldname.db and worldname.fwl"
    echo "Press y(yes) or n(no)"
#read user input confirmation
    read -p "" confirmBackup
#if y, then continue, else cancel
        if [ "$confirmBackup" == "y" ]; then
 #stop valheim server
        systemctl stop valheimserver
        echo "Stopping Valheim Server"
 #give it a few
        sleep 5
 #copy backup to worlds folder
        echo "Copying ${backups[$selectedIndex-1]} to ${worldpath}/"
        cp ${backups[$selectedIndex-1]} ${worldpath}/
 #untar
        echo "Unpacking ${worldpath}/${restorefile}"
        tar xzf ${worldpath}/${restorefile} --strip-components=7 --directory ${worldpath}/  
	chown -Rf steam:steam $worldpath
 #start valheim server
        echo "Starting Valheim Services"
        echo "This better work Loki!"
        systemctl start valheimserver
	systemctl status valheimserver
else
        echo "Canceling restore process because Loki sucks"
fi

}




function check_apply_server_updates() {
    echo ""
    echo "Oh for Loki! This is not ready yet."
    #Thanks to @lloesche for the throught process and function
    valheiminstall=/home/steam/valheimserver/
    #make temp directory for this Loki file dump
    vaheiminstall_temp=/tmp/lokidump/
    loki_started=true

    dltmpdir=vaheiminstall_temp
    [ ! -d "$dltmpdir" ] && mkdir -p "$dltmpdir"

    logfile="$(mktemp)"
    echo "Update and Check Valheim Server"
    steamcmd +login anonymous +force_install_dir $valheiminstall_temp +app_update 896660 -validate +quit
    rsync -a --chown=steam:steam --itemize-changes --delete --exclude server_exit.drp --exclude steamapps --exclude start_valheim.sh $valheiminstall_temp $valheiminstall | tee "$logfile"
    grep '^[*>]' "$logfile" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Valheim Server was updated - restarting"
        systemctl restart valheimserver.service
    else
        echo "Valheim Server is already the latest version"
        if [ $loki_started = true ]; then
            systemctl start valheimserver.service
        fi
    fi
    loki_started=false
    rm -f "$logfile"

    echo ""

}

function confirm_check_apply_server_updates() {

while true; do
$(ColorRed '-----------------------------------------------')
tput setaf 2; echo "WARNING DOING THIS WILL SHUTDOWN THE SERVER" ; tput setaf 9;
tput setaf 2; echo "MAKE SURE EVERYBODY IS LOGGED OUT OF THE SERVER" ; tput setaf 9;
tput setaf 2; echo "Press y(YES) and n(NO)" ; tput setaf 9;
tput setaf 2; read -p "Do you wish to continue?" yn ; tput setaf 9; 
$(ColorRed '-----------------------------------------------')
    case $yn in
        [Yy]* ) check_apply_server_updates; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

}


function display_start_valheim() {
    clear
    echo ""
    sudo cat /home/steam/valheimserver/start_valheim.sh
    echo ""

}


function display_world_data_folder() {
    clear
    echo ""
    sudo ls -lisa $worldpath
    echo ""

}

function stop_valheim_server() {
    clear
    echo ""
$(ColorRed '----------------------------------------------------')
tput setaf 2; echo "You are about to STOP the Valheim Server" ; tput setaf 9; 
tput setaf 2; echo "You are you sure y(YES) or n(NO)?" ; tput setaf 9; 
$(ColorRed '----------------------------------------------------')
    read -p "" confirmStop
#if y, then continue, else cancel
        if [ "$confirmStop" == "y" ]; then
    sudo systemctl stop valheimserver.service
    echo ""
    else
    echo "Canceling Stopping of Valheim Server Service - because Loki sucks"
fi

}

function start_valheim_server() {
    clear
    echo ""
 $(ColorRed '----------------------------------------------------')
 tput setaf 2; echo "You are about to START the Valheim Server" ; tput setaf 9; 
 tput setaf 2; echo "You are you sure y(YES) or n(NO)?" ; tput setaf 9; 
 $(ColorRed '----------------------------------------------------')
    read -p "" confirmStart
#if y, then continue, else cancel
        if [ "$confirmStart" == "y" ]; then
    sudo systemctl start valheimserver.service
    echo ""
    else
        echo "Canceling Starting of Valheim Server Service - because Loki sucks"
fi

}

function restart_valheim_server() {
    clear
    echo ""
$(ColorRed '----------------------------------------------------')
tput setaf 2; echo "You are about to RESTART the Valheim Server" ; tput setaf 9; 
tput setaf 2; echo "You are you sure y(YES) or n(NO)?" ; tput setaf 9; 
$(ColorRed '----------------------------------------------------')
read -p "" confirmRestart
#if y, then continue, else cancel
        if [ "$confirmRestart" == "y" ]; then
    sudo systemctl restart valheimserver.service
    echo ""
    else
        echo "Canceling Restarting of Valheim Server Service - because Loki sucks"
fi

}


function display_valheim_server_status() {
    clear
    echo ""
    sudo systemctl status valheimserver.service
    echo ""

}

function display_start_valheim() {
    clear
    echo ""
    sudo cat /home/steam/valheimserver/start_valheim.sh
    echo ""

}



server_install_menu(){
echo -ne "
$(ColorOrange '-')$(ColorOrange '---------Server System Information--------')
$(ColorOrange '-')$(ColorGreen '1)') Fresh or Reinstall Valheim Server
$(ColorOrange '-')$(ColorGreen '0)') Go to Main Menu
$(ColorOrange '-------------------------------------------')
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) valheim_server_install ; server_install_menu ;;
           	    0) menu ; menu ;;
		    *) echo -e $RED"Wrong option."$CLEAR; WrongCommand;;
        esac
}

tech_support(){
echo -ne "
$(ColorOrange '--------------Valheim Tech Support--------------')
$(ColorOrange '-')$(ColorGreen ' 1)') Display Valheim Config File
$(ColorOrange '-')$(ColorGreen ' 2)') Display Valheim Server Service
$(ColorOrange '-')$(ColorGreen ' 3)') Display World Data Folder
$(ColorOrange '-')$(ColorGreen ' 0)') Go to Main Menu
$(ColorOrange '-------------------------------------------------')
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) display_start_valheim ; tech_support ;; 
		2) display_valheim_server_status ; tech_support ;;
	        3) display_world_data_folder ; tech_support ;;
		  0) menu ; menu ;;
		    *) echo -e $RED"Wrong option."$CLEAR; WrongCommand;;
        esac
}

admin_tools_menu(){
echo -ne "
$(ColorOrange '--------------------Valheim Admin Tools---------------------')
$(ColorOrange '-')$(ColorGreen ' 1)') Backup World
$(ColorOrange '-')$(ColorGreen ' 2)') Restore World
$(ColorOrange '-')$(ColorGreen ' 3)') Stop Valheim Server
$(ColorOrange '-')$(ColorGreen ' 4)') Start Valheim Server
$(ColorOrange '-')$(ColorGreen ' 5)') Restart Valheim Server
$(ColorOrange '-')$(ColorGreen ' 6)') Status Valheim Server
$(ColorOrange '-')$(ColorGreen ' 7)') Check and Apply Valheim Server Update
$(ColorOrange '------------------First Time or Reinstall-------------------')
$(ColorOrange '-')$(ColorGreen ' 8)') Fresh Valheim Server
$(ColorOrange '-')$(ColorGreen ' 0)') Go to Main Menu
$(ColorOrange '------------------------------------------------------------')
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
		1) backup_world_data ; admin_tools_menu ;;
		2) restore_world_data ; admin_tools_menu ;;
		3) stop_valheim_server ; admin_tools_menu ;;
		4) start_valheim_server ; admin_tools_menu ;;
		5) restart_valheim_server ; admin_tools_menu ;;
		6) display_valheim_server_status ; admin_tools_menu ;;
		7) confirm_check_apply_server_updates ; admin_tools_menu ;;
		8) valheim_server_install ; admin_tools_menu ;;
		   0) menu ; menu ;;
		    *) echo -e $RED"Wrong option."$CLEAR; WrongCommand;;
        esac
}



menu(){
echo -ne "
$(ColorOrange '╔═════════════════════════════════════╗')
$(ColorOrange '║ -ZeroBandwidths Easy Valheim Menu -   ║')
$(ColorOrange '╠═════════════════════════════════════╝')
$(ColorOrange '║ open to improvements')
$(ColorOrange '║ Loki hides within this script')
$(ColorOrange '╚ ')${mversion} or beta 

$(ColorOrange '----------Server System Information---------')
$(ColorOrange '-')$(ColorGreen ' 1)') Check for Nimdy Script Updates
$(ColorOrange '-')$(ColorGreen ' 2)') System Info
$(ColorOrange '-')$(ColorGreen ' 3)') Network Info 
$(ColorOrange '-')$(ColorGreen ' 4)') Check All
$(ColorOrange '-----------Valheim Server Commands---------')
$(ColorOrange '-')$(ColorGreen ' 5)') Server Admin Tools 
$(ColorOrange '-')$(ColorGreen ' 6)') Tech Support Tools
$(ColorOrange '-')$(ColorGreen ' 7)') Install Valheim Server
$(ColorOrange '-')$(ColorGreen ' 0)') Exit
$(ColorOrange '-------------------------------------------')
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) script_check_update ; menu ;;
		2) system_info ; menu ;;
	        3) network_info ; menu ;;
	        4) all_checks ; menu ;;
		5) admin_tools_menu ; menu ;;
		6) tech_support ; menu ;;
		7) server_install_menu ; menu ;;
		    0) exit 0 ;;
		    *) echo -e $RED"Wrong option."$CLEAR; WrongCommand;;
        esac
}



# Call the menu function
menu
