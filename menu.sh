#!/bin/bash
# BETA TESTING USE AT YOUR OWN RISK!!!
# Please fill free to add/change
# Easy Valheim Server Menu
# Open to other commands that should be used... 
clear
##
# System script that checks:
#   - Memory usage
#   - CPU load
#   - Number of TCP/UDP connections 
#   - Kernel version
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
    echo ""
	echo "Add script update check "
	echo "check if Master Repo is updated"
	echo " if true download and replace"
	echo " if not print already up todate nothing to do"
    echo ""
}

function memory_check() {
    echo ""
	echo "Memory usage on ${server_name} is: "
	free -h
	echo ""
}

function cpu_check() {
    echo ""
	echo "CPU load on ${server_name} is: "
    echo ""
	uptime
    echo ""
}

function tcp_check() {
    echo ""
	echo "TCP connections on ${server_name}: "
    echo ""
	cat  /proc/net/tcp | wc -l
    echo ""
}

function udp_check() {
    echo ""
	echo "UDP connections on ${server_name}: "
    echo ""
	cat  /proc/net/udp | wc -l
    echo ""
}

function kernel_check() {
    echo ""
	echo "Kernel version on ${server_name} is: "
	echo ""
	uname -r
    echo ""
}

function confirmed_valheim_install() {
	echo "Installing Valheim"
	echo "Oh for Loki, its starting"
	echo "This will work add code later"
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
    read -p "Do you wish to install this program?" yn
    case $yn in
        [Yy]* ) confirmed_valheim_install; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

}


function all_checks() {
	memory_check
	cpu_check
	tcp_check
	udp_check
	kernel_check
}

function backup_world_data() {
    echo ""
         ## Get the current date as variable.
         TODAY="$(date +%Y-%m-%d)"
	 
	 dldir="/home/steam/backup"
	 [ ! -d "$dldir" ] && mkdir -p "$dldir"

         ## Clean up files older than 2 weeks. Create a new backup.
         find /home/steam/backups/ -mtime +14 -type f -delete

         ## Tar Section. Create a backup file, with the current date in its name.
         ## Add -h to convert the symbolic links into a regular files.
         ## Backup some system files, also the entire `/home` directory, etc.
         ## --exclude some directories, for example the the browser's cache, `.bash_history`, etc.
         tar zcvf "/home/steam/backups/valheim-backup-$TODAY.tgz" /home/steam/.config/unity3d/IronGate/Valheim/worlds/* 
         chown steam:steam /home/steam/backups/valheim-backup-$TODAY.tgz
    echo ""

}

function restore_world_data() {
    echo ""
    echo "Not Working Yet Add Code"
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
$(ColorGreen '3)') Check for Server Updates
$(ColorGreen '4)') Apply Server Updates
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
$(ColorGreen '2)') Memory usage
$(ColorGreen '3)') CPU load
$(ColorGreen '4)') Number of TCP connections 
$(ColorGreen '5)') Number of UDP connections 
$(ColorGreen '6)') Kernel version
$(ColorGreen '7)') Check All
$(ColorOrange '-----Valheim Server Commands-----')
$(ColorGreen '8)') Server Admin Tools 
$(ColorGreen '9)') Install Valheim Server
$(ColorGreen '0)') Exit
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) script_check_update ; menu ;;
		2) memory_check ; menu ;;
	        3) cpu_check ; menu ;;
	        4) tcp_check ; menu ;;
	        5) udp_check ; menu ;;
	        6) kernel_check ; menu ;;
	        7) all_checks ; menu ;;
		8) admin_tools_menu ; menu ;;
		9) server_install_menu ; menu ;;
		    0) exit 0 ;;
		    *) echo -e $RED"Wrong option."$CLEAR; WrongCommand;;
        esac
}



# Call the menu function
menu
