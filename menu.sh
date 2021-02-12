#!/bin/bash
# Easy Valheim Server Menu
# Open to other commands that should be used... 
clear
title="~*~*~*~*Valheim Toolbox Menu*~*~*~*~"

##
# System script that checks:
#   - Memory usage
#   - CPU load
#   - Number of TCP/UDP connections 
#   - Kernel version
##

##
# Server Tools:
#   - List Admins
#   - Add Admin
#   - Remove Admin

##

server_name=$(hostname)

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

function valheim_server_install() {
    echo ""
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

function all_checks() {
	memory_check
	cpu_check
	tcp_check
	udp_check
	kernel_check
}

##
# Color  Variables
##
green='\e[32m'
blue='\e[34m'
clear='\e[0m'

##
# Color Functions
##

ColorGreen(){
	echo -ne $green$1$clear
}
ColorBlue(){
	echo -ne $blue$1$clear
}

menu(){
echo -ne "
Server System Information
$(ColorGreen '1)') Memory usage
$(ColorGreen '2)') CPU load
$(ColorGreen '3)') Number of TCP connections 
$(ColorGreen '4)') Number of UDP connections 
$(ColorGreen '5)') Kernel version
$(ColorGreen '6)') Check All
Valheim Server Commands
$(ColorGreen '7)') Install Valheim Server
$(ColorGreen '8)') Valheim Server Update Check



$(ColorGreen '0)') Exit
$(ColorBlue 'Choose an option:') "
        read a
        case $a in
	        1) memory_check ; menu ;;
	        2) cpu_check ; menu ;;
	        3) tcp_check ; menu ;;
	        4) udp_check ; menu ;;
	        5) kernel_check ; menu ;;
	        6) all_checks ; menu ;;
		    7) valheim_server_install ; menu ;;
	    	8) valheim_update_check ; menu ;;
		    0) exit 0 ;;
		    *) echo -e $red"Wrong option."$clear; WrongCommand;;
        esac
}

# Call the menu function
menu
