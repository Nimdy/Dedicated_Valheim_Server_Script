#!/bin/bash
###############################################################################################
###############################################################################################
####
#### File name: core.sh
####
###############################################################################################
#### Core functionality for Valheim server management system
#### Contains common utility functions, OS detection, and other shared functions
###############################################################################################

# Source OS information (used for OS-specific functionality)
source /etc/os-release

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
    echo -ne $YELLOW$1$clear
}
ColorWhite(){
    echo -ne $WHITE$1$clear
}

########################################################################
################### System Detection and Information ###################
########################################################################

# Detect OS type and version
function detect_os() {
    if command -v apt-get >/dev/null; then
        echo "debian"
    elif command -v yum >/dev/null; then
        if [[ "$ID" == "fedora" ]]; then
            echo "fedora"
        elif [[ "$ID" =~ ^(centos|ol|rhel)$ && "${VERSION:0:1}" == "8" ]]; then
            echo "rhel8"
        elif [[ "$ID" =~ ^(centos|ol|rhel)$ && "${VERSION:0:1}" == "7" ]]; then
            echo "rhel7"
        else
            echo "unknown_redhat"
        fi
    else
        echo "unknown"
    fi
}

# Check if a command exists
function command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if the server is connected to the internet
function check_internet_connection() {
    if ping -c 1 google.com &> /dev/null; then
        echo "connected"
    else
        echo "disconnected"
    fi
}

# Get the external IP address of the server
function get_external_ip() {
    curl -s ipecho.net/plain || echo "unknown"
}

# Get internal IP addresses
function get_internal_ip() {
    hostname -I
}

# Display system information
function display_system_info() {
    echo ""
    echo -e "$DRAW80"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_HEADER"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_HOSTNAME $(hostname)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_UPTIME $(uptime -p)"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_MANUFACTURER $(cat /sys/class/dmi/id/chassis_vendor 2>/dev/null || echo 'Unknown')"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_PRODUCT_NAME $(cat /sys/class/dmi/id/product_name 2>/dev/null || echo 'Unknown')"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_VERSION $(cat /sys/class/dmi/id/product_version 2>/dev/null || echo 'Unknown')"
    echo -e "$FUNCTION_DISPLAY_SYSTEM_INFO_SERIAL_NUMBER $(cat /sys/class/dmi/id/product_serial 2>/dev/null || echo 'Unknown')"
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

# Display network information
function display_network_info() {
    echo ""
    sudo netstat -atunp | grep valheim
    echo ""
    echo "Returning to menu in 5 Seconds"
    sleep 5
}

########################################################################
######################### Log Functions ################################
########################################################################

# Basic logging function
function log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    
    # Customize this path as needed
    local log_file="/var/log/valheim_server.log"
    
    echo "[$timestamp] [$level] $message" >> "$log_file"
    
    # Also output to console if debug mode is enabled
    if [ "$debugmsg" == "y" ]; then
        case "$level" in
            "ERROR")
                echo -e "${RED}[$timestamp] [$level] $message${NOCOLOR}"
                ;;
            "WARNING")
                echo -e "${YELLOW}[$timestamp] [$level] $message${NOCOLOR}"
                ;;
            "INFO")
                echo -e "${GREEN}[$timestamp] [$level] $message${NOCOLOR}"
                ;;
            *)
                echo "[$timestamp] [$level] $message"
                ;;
        esac
    fi
}

# Log error messages
function log_error() {
    log_message "ERROR" "$1"
}

# Log warning messages
function log_warning() {
    log_message "WARNING" "$1"
}

# Log info messages
function log_info() {
    log_message "INFO" "$1"
}

########################################################################
####################### World Management ###############################
########################################################################

# Set the correct game world path based on world name
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

# Set the steam executable path based on OS
function set_steamexe() {
    if [ "$debugmsg" == "y" ]; then 
        tput setaf 1; echo -ne "$FUNCTION_SET_STEAMEXE_INFO"; tput setaf 9;
    fi    
    if command -v apt-get >/dev/null; then
        steamexe=/home/steam/steamcmd
    elif command -v yum >/dev/null; then
        steamexe=/home/steam/steamcmd/steamcmd.sh
    else
        echo ""
    fi
    if [ "$debugmsg" == "y" ]; then 
        tput setaf 2; echo -ne "$ECHO_DONE"; tput setaf 9;
    fi    
    sleep 1
}

# Validate ports to make sure they aren't already in use
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

# Get current hostname
function currentHostName() {
    hostname
}

# Extract world seed from FWL file
function get_worldseed() {
    # Extract the world seed from the .fwl file
    worldseed=$(hexdump -s 9 -n 10 -e '2/1 "%02x"' "${worldpath}/${worldname}/worlds_local/${worldname}.fwl" | tr -d ' ')

    echo ""
    echo -e '\E[32m'"$worldseed"
    echo ""
    echo "Returning to menu in 5 seconds - This might not be working 100% still testing"
    sleep 5
}

# Display connected players
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

# Display the player connection history
function display_player_history() {
    echo ""
    grep ZDOID ${worldpath}/${worldname}/valheim_server.log
    grep *HAND* ${worldpath}/${worldname}/valheim_server.log
    echo ""
    echo "Returning to menu in 5 Seconds"
    sleep 5
}

# Display the last join code from logs
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

# Initialize the system by reading any existing configuration
function initialize_system() {
    # Check if the world file list exists
    if [ -f "$worldfilelist" ]; then
        readarray -t worldlistarray < "$worldfilelist"
    else
        unset worldlistarray
    fi

    # Set default world and steam executable
    set_world_server
    set_steamexe
}

# Main function to check if we need to do an upgrade from old menu format
function check_for_upgrade_required() {
    if [ ! -f "$worldfilelist" ]; then
        echo "World list file not found. You may need to upgrade from old menu format."
        return 1
    fi
    return 0
}