#!/bin/bash
# BETA TESTING USE AT YOUR OWN RISK!!!
# Please fill free to add/change
# Easy Valheim Server Menu
# Open to other commands that should be used... 
clear
##
# System script that checks:
#   - Display System Info
#   - Display Network Info
#   - other stuff? 
#  
##

##
# Server Install:
#   - Install Server
##

##
# Server Tools:
#   - List Admins
#   - Add Admin
#   - Remove Admin

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
BRANCH="https://github.com/Nimdy/Dedicated_Valheim_Server_Script/tree/beta"
    git remote update
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
    echo -e "Swap Usage:\t"`free | awk '/Swap/{printf("%.2f%"), $3/$2*100}'`
    echo -e "CPU Usage:\t"`cat /proc/stat | awk '/cpu/{printf("%.2f%\n"), ($2+$4)*100/($2+$4+$5)}' |  awk '{print $0}' | head -1`
echo ""
    echo -e "-------------------------------Disk Usage >80%-------------------------------"
    df -Ph | sed s/%//g | awk '{ if($5 > 80) print $0;}'
echo ""
}

function network_info() {
echo ""
echo "add stuff"
echo ""

}

function all_checks() {
	system_info
	network_info
}

function confirmed_valheim_install() {
    #check for updates and upgrade the system auto yes
    tput setaf 2; echo "Checking for upgrades"
    apt update && apt upgrade -y
    tput setaf 2; echo "Done"
    tput setaf 9;
    sleep 1

#add multiverse repo
    tput setaf 2; echo "Adding multiverse REPO"
    add-apt-repository -y multiverse
    tput setaf 2; echo "Done"
    tput setaf 9;
    sleep 1

#add i386 architecture
    tput setaf 1; echo "Adding i386 architecture"
    dpkg --add-architecture i386
    tput setaf 2; echo "Done" 
    tput setaf 9;
    sleep 1

#update system again
    tput setaf 1; echo "Checking and updating system again"
    apt update
    tput setaf 2; echo "Done"
    tput setaf 9;
    sleep 1

# Linux Steam Local Account Password input
    echo ""
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
      echo "Good Example: Viking12"
      echo "Bad Example: Vik!"
        read -p "Please give steam a password: " userpassword
            [[ ${#userpassword} -ge 5 && "$userpassword" == *[[:lower:]]* && "$userpassword" == *[[:upper:]]* && "$userpassword" =~ ^[[:alnum:]]+$ ]] && break
        echo "Password not accepted - Too Short or has Special Characters"
        echo "I swear to LOKI, you better NOT use Special Characters" 
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
        read -p "Please give steam a password: " worldname
            [[ ${#worldname} -ge 8 && "$worldname" =~ ^[[:alnum:]]+$ ]] && break
        echo "World Name not set: Too Short or has Special Characters"
    done
    clear
    echo ""
    # Password for Server
    echo ""
    echo "Now for Loki, please follow instructions"
    echo "Your server is required to have a password"
    echo "Your password cannot match your public display name nor world name"
    echo "Make your password unique"
    echo "Your public display name: $displayname "
    echo "Your world name: $worldname "
    while true; do
      echo "This password must be 5 Characters or more"
  echo "At least one number, one uppercase letter and one lowercase letter"
  echo "Good Example: Viking12"
  echo "Bad Example: Vik!"
    read -p "Enter Password to Enter your Valheim Server: " password
        [[ ${#password} -ge 5 && "$password" == *[[:lower:]]* && "$password" == *[[:upper:]]* && "$password" =~ ^[[:alnum:]]+$ ]] && break
    echo "Password not accepted - Too Short, Special Characters"
    echo "I swear to LOKI, you better NOT use Special Characters" 
done
clear
#read -p "Enter Password to Enter your Valheim Server: " password
echo ""
clear
echo "Here is the information you entered"
echo "---------------------------------------"
echo "nonroot steam password:  $userpassword "
echo "Public Server Name:      $displayname "
echo "Local World Name:        $worldname "
echo "Valheim Server Password: $password "
echo "---------------------------------------"
echo ""


#install steamcmd
tput setaf 1; echo "Installing steamcmd"
apt install steamcmd -y
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#EDIT HERE #1
#build account to run Valheim
tput setaf 1; echo "Building steam account NONROOT"
sleep 1
useradd --create-home --shell /bin/bash --password $userpassword steam
cp /etc/skel/.bashrc /home/steam/.bashrc
cp /etc/skel/.profile /home/steam/.profile
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#build symbolic link for steamcmd
tput setaf 1; echo "Building symbolic link for steamcmd"
ln -s /usr/games/steamcmd /home/steam/steamcmd
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#chown steam user to steam
tput setaf 1; echo "Setting steam permissions"
chown steam:steam /home/steam/steamcmd
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#Download Valheim from steam
tput setaf 1; echo "Downloading and installing Valheim from Steam"
sleep 1
tput setaf 9;
/home/steam/steamcmd +login anonymous +force_install_dir /home/steam/valheimserver +app_update 896660 validate +exit
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#build config for start_valheim.sh
tput setaf 1; echo "Deleting old configuration if file exist"
tput setaf 1; echo "Building Valheim start_valheim server configuration"
rm /home/steam/valheimserver/start_valheim.sh
sleep 1
cat >> /home/steam/valheimserver/start_valheim.sh <<EOF
#!/bin/bash
export templdpath=$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH
export SteamAppId=892970
# Tip: Make a local copy of this script to avoid it being overwritten by steam.
# NOTE: You need to make sure the ports 2456-2458 is being forwarded to your server through your local router & firewall.
./valheim_server.x86_64 -name $displayname -port 2456 -nographics -batchmode -world $worldname -password $password
export LD_LIBRARY_PATH=$templdpath
EOF
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#build check log script
tput setaf 1; echo "Deleting old configuration if file exist"
tput setaf 1; echo "Building check log script"
rm /home/steam/check_log.sh
sleep 1
cat >> /home/steam/check_log.sh <<EOF
journalctl --unit=valheimserver --reverse
EOF
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#set execute permissions
tput setaf 1; echo "Setting execute permissions on start_valheim.sh"
chmod +x /home/steam/valheimserver/start_valheim.sh
tput setaf 2; echo "Done"
tput setaf 1; echo "Setting execute permissions on check_log.sh"
chmod +x /home/steam/check_log.sh
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#build systemctl configurations for execution of processes for Valheim Server
tput setaf 1; echo "Deleting old configuration if file exist"
tput setaf 1; echo "Building systemctl instructions for Valheim"
rm /etc/systemd/system/valheimserver.service
sleep 1
cat >> /etc/systemd/system/valheimserver.service <<EOF
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
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#chown steam user permissions to all of user steam dir location
tput setaf 1; echo "Setting steam account permissions to /home/steam/*"
chown steam:steam -Rf /home/steam/*
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

# Reload daemons
tput setaf 1; echo "Reloading daemons"
systemctl daemon-reload
tput setaf 2; echo "Done"
sleep 1

# Start server
tput setaf 1; echo "Starting Valheim Server"
systemctl start valheimserver
tput setaf 2; echo "Done"
sleep 1

# Enable server on restarts
tput setaf 1; echo "Enabling Valheim Server on start or after reboots"
systemctl enable valheimserver
tput setaf 2; echo "Done"
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
    echo ""
    echo "Not ready yet, come back soon"
    echo ""
    echo ""
}



function valheim_server_install() {

while true; do
    read -p "Do you wish to install Valheim Server?" yn
    case $yn in
        [Yy]* ) confirmed_valheim_install; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

}


function backup_world_data() {
    echo ""
    echo " Uncomment for testing"
         ## Get the current date as variable.
         #TODAY="$(date +%Y-%m-%d)"
	 #
	 #dldir="/home/steam/backup"
	 #[ ! -d "$dldir" ] && mkdir -p "$dldir"
         #
         ## Clean up files older than 2 weeks. Create a new backup.
         #find /home/steam/backups/ -mtime +14 -type f -delete

         ## Tar Section. Create a backup file, with the current date in its name.
         ## Add -h to convert the symbolic links into a regular files.
         ## Backup some system files, also the entire `/home` directory, etc.
         ## --exclude some directories, for example the the browser's cache, `.bash_history`, etc.
         #tar zcvf "/home/steam/backups/valheim-backup-$TODAY.tgz" /home/steam/.config/unity3d/IronGate/Valheim/worlds/* 
         #chown steam:steam /home/steam/backups/valheim-backup-$TODAY.tgz
    echo ""

}

function restore_world_data() {
    echo ""
    echo "Not ready yet, come back soon"
#    echo "look into /home/steam/backups"
#    echo "print list"
#    echo "allow list for selection"
#    echo "take user input for select file"
#    echo "confirm file to be restored"
#    echo "stop valheim service"
#    echo "copy backup file into /home/steam/.config/unity3d/IronGate/Valheim/worlds/"
#    echo "untar files whateverfile.db and whateverfile.fwl"
#    echo "chown steam:steam to files"
#    echo "start valheim service"
#    echo "print restore completed"
    echo ""

}

function check_server_updates() {
    echo ""
    echo "Not ready yet, come back soon"
    echo ""

}

function apply_server_updates() {
    echo ""
    echo "Not ready yet, come back soon"
    echo ""

}


server_install_menu(){
echo -ne "
$(ColorOrange '-----Server System Information-----')
$(ColorGreen '1)') Fresh Valheim Server
$(ColorGreen '0)') Go to Main Menu
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) valheim_server_install ; server_install_menu ;;
           	    0) menu ; menu ;;
		    *) echo -e $RED"Wrong option."$CLEAR; WrongCommand;;
        esac
}

admin_tools_menu(){
echo -ne "
$(ColorOrange '-----Valheim Admin Tools-----')
$(ColorGreen '1)') Backup World
$(ColorGreen '2)') Restore World
$(ColorGreen '3)') Check for Valheim Updates
$(ColorGreen '4)') Apply Valheim Updates
$(ColorGreen '5)') Fresh Valheim Server
$(ColorGreen '0)') Go to Main Menu
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) backup_world_data ; admin_tools_menu ;;
		2) restore_world_data ; admin_tools_menu ;;
		3) check_server_updates ; admin_tools_menu ;;
		4) apply_server_updates ; admin_tools_menu ;;
		5) valheim_server_install ; admin_tools_menu ;;
		   0) menu ; menu ;;
		    *) echo -e $RED"Wrong option."$CLEAR; WrongCommand;;
        esac
}



menu(){
echo -ne "
$(ColorOrange '~*~*~*~*Valheim Toolbox Menu*~*~*~*~')
$(ColorOrange '-----Server System Information-----')
$(ColorGreen '1)') Check for Nimdy Script Updates
$(ColorGreen '2)') System Info
$(ColorGreen '3)') Network Info 
$(ColorGreen '4)') Check All
$(ColorOrange '-----Valheim Server Commands-----')
$(ColorGreen '5)') Server Admin Tools 
$(ColorGreen '6)') Install Valheim Server
$(ColorGreen '0)') Exit
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) script_check_update ; menu ;;
		2) system_info ; menu ;;
	        3) network_info ; menu ;;
	        4) all_checks ; menu ;;
		5) admin_tools_menu ; menu ;;
		6) server_install_menu ; menu ;;
		    0) exit 0 ;;
		    *) echo -e $RED"Wrong option."$CLEAR; WrongCommand;;
        esac
}



# Call the menu function
menu
