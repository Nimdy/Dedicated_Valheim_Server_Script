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




function script_check_update() {
BRANCH="https://github.com/Nimdy/Dedicated_Valheim_Server_Script.git"
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
	echo "Installing Valheim"
	echo "Oh for Loki, its starting"
	echo "This will work add code from build_dedicated_valheim_server.sh"
	echo ""
}

function valheim_update_check() {
    echo ""
	echo "Checking for Valheim Server Updates "
	echo "This will work add code later"
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
    echo "look into /home/steam/backups"
    echo "print list"
    echo "allow list for selection"
    echo "take user input for select file"
    echo "confirm file to be restored"
    echo "stop valheim service"
    echo "copy backup file into /home/steam/.config/unity3d/IronGate/Valheim/worlds/"
    echo "untar files whateverfile.db and whateverfile.fwl"
    echo "chown steam:steam to files"
    echo "start valheim service"
    echo "print restore completed"
    echo ""

}

function check_server_updates() {
    echo ""
    echo "Not Working Yet Add Code"
    echo ""

}

function apply_server_updates() {
    echo ""
    echo "Not Working Yet Add Code"
    echo ""

}


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
