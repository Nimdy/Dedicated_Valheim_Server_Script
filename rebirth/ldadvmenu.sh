#!/bin/bash
###############################################################################################
###############################################################################################
####
#### File name: ldadvmenu.sh
####
###############################################################################################
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
#### Modifier: Lord/Ranger(Dumoss)
#### Forked from: Njord advancemenu.ld (beta) Updated: 29-APR-2021
####
###############################################################################################

# Set script directory
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Load language configuration
if [ "$1" == "" ]; then 
    LANGUAGE=EN
else 
    LANGUAGE=$1
fi

# Ensure the language file exists
if [ ! -f "$SCRIPT_DIR/lang/$LANGUAGE.conf" ]; then
    echo "Error: Language file for $LANGUAGE not found."
    echo "Please check that $SCRIPT_DIR/lang/$LANGUAGE.conf exists."
    exit 1
fi

source "$SCRIPT_DIR/lang/$LANGUAGE.conf"

# Check for root privileges
echo "$(tput setaf 4)$DRAW60"
echo "$(tput setaf 0)$(tput setab 7)$CHECKSUDO$(tput sgr 0)"
echo "$(tput setaf 0)$(tput setab 7)$CHECKSUDO1$(tput sgr 0)"    
echo "$(tput setaf 4)$DRAW60"
[[ "$EUID" -eq 0 ]] || exec sudo "$0" "$@"
clear

# Load configuration
if [ -f "$SCRIPT_DIR/config.sh" ]; then
    source "$SCRIPT_DIR/config.sh"
else
    echo "Error: Configuration file not found."
    echo "Please ensure $SCRIPT_DIR/config.sh exists."
    exit 1
fi

# Check for required directories
if [ ! -d "$SCRIPT_DIR/lib" ]; then
    echo "Error: Library directory not found."
    echo "Please ensure $SCRIPT_DIR/lib directory exists with needed modules."
    exit 1
fi

# Global variables for mod management
MOD_STATE=""
MOD_TYPE=""

# Load core modules
for module in core.sh server.sh backup.sh firewall.sh ui.sh update.sh; do
    if [ -f "$SCRIPT_DIR/lib/$module" ]; then
        source "$SCRIPT_DIR/lib/$module"
    else
        echo "Warning: Module $module not found in $SCRIPT_DIR/lib/"
        echo "Some functionality may be limited."
    fi
done

# Initialize system
initialize_system

# Conditionally load mod files based on specific parameters
function load_mods() {
    # Check if mods directory exists
    if [ -d "$SCRIPT_DIR/mods" ]; then
        # Check if specific mod is requested and load only that one
        if [ "$1" = "valheimplus" ] && [ -f "$SCRIPT_DIR/mods/valheimplus.sh" ]; then
            source "$SCRIPT_DIR/mods/valheimplus.sh"
            MOD_TYPE="valheimplus"
            MOD_STATE="loaded"
            return 0
        elif [ "$1" = "bepinex" ] && [ -f "$SCRIPT_DIR/mods/bepinex.sh" ]; then
            source "$SCRIPT_DIR/mods/bepinex.sh"
            MOD_TYPE="bepinex"
            MOD_STATE="loaded"
            return 0
        elif [ "$1" = "all" ]; then
            # Load all available mod scripts
            for mod_file in "$SCRIPT_DIR/mods/"*.sh; do
                if [ -f "$mod_file" ]; then
                    source "$mod_file"
                    MOD_STATE="loaded_all"
                fi
            done
            return 0
        fi
    else
        echo "Mods directory not found. Creating $SCRIPT_DIR/mods directory..."
        mkdir -p "$SCRIPT_DIR/mods"
        echo "Please add mod scripts to this directory."
    fi
    # No mods were loaded or requested mod doesn't exist
    return 1
}

# Custom mod menu handler - will load appropriate mod files when needed
function handle_mod_menu() {
    if [ "$1" = "valheimplus" ]; then
        if [ "$MOD_STATE" != "loaded" ] || [ "$MOD_TYPE" != "valheimplus" ]; then
            load_mods "valheimplus"
        fi
        mods_menu
    elif [ "$1" = "bepinex" ]; then
        if [ "$MOD_STATE" != "loaded" ] || [ "$MOD_TYPE" != "bepinex" ]; then
            load_mods "bepinex"
        fi
        bepinex_menu
    else
        echo "Unknown mod type: $1"
        sleep 2
        menu
    fi
}

# Override menu options from ui.sh to use mod handler
function override_menu_options() {
    # Save original menu function
    if type ui_original_menu > /dev/null 2>&1; then
        # Already overridden
        return
    fi
    
    # Only override if the menu function exists
    if type menu > /dev/null 2>&1; then
        # Rename the original function
        eval "$(declare -f menu | sed 's/^menu/ui_original_menu/')"
        
        # Define the new menu function with mod handler
        function menu() {
            # Call the original menu function
            ui_original_menu
            
            # Handle special cases for mod options
            case $a in
                20) handle_mod_menu "valheimplus" ;;
                21) handle_mod_menu "bepinex" ;;
                *) ;;
            esac
        }
    fi
}

# Apply the menu override
override_menu_options

# Print banner
echo "Valheim Server Management System - Njord Menu"
echo "Version: $mversion"
echo "LD Version: $ldversion"
echo "------------------------------------------------------------"
echo "Type 'help' for additional command-line options"
echo ""

# Help function for command-line usage
function show_help() {
    echo "Usage: $0 [LANGUAGE] [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start         - Start the Valheim server"
    echo "  stop          - Stop the Valheim server"
    echo "  restart       - Restart the Valheim server"
    echo "  status        - Show status of the Valheim server"
    echo "  update        - Check and apply Valheim server updates"
    echo "  backup        - Create a backup of world data"
    echo "  valheimplus   - Launch ValheimPlus mod menu"
    echo "  bepinex       - Launch BepInEx mod menu"
    echo "  mods          - Load all mods and show menu"
    echo "  help          - Show this help message"
    echo ""
    echo "Languages: DE (German), EN (English), FR (French), SP (Spanish)"
    echo "Default language is EN if not specified."
    echo ""
    exit 0
}

# Call the menu function or the shortcut called in arg
if [ $# = 0 ]; then
    # No arguments, load the main menu
    menu
else
    case "$1" in
    start)   start_valheim_server ;;
    stop)    stop_valheim_server ;;
    restart) restart_valheim_server ;;
    update)  check_apply_server_updates_beta ;;
    backup)  backup_world_data ;;
    status)  display_valheim_server_status ;;
    valheimplus)
        load_mods "valheimplus"
        mods_menu
        ;;
    bepinex)
        load_mods "bepinex"
        bepinex_menu
        ;;
    mods)
        load_mods "all"
        menu
        ;;
    help)
        show_help
        ;;
    *)
        if [ "$2" != "" ]; then
            # If second argument provided, first is language and second is command
            case "$2" in
            start)   start_valheim_server ;;
            stop)    stop_valheim_server ;;
            restart) restart_valheim_server ;;
            update)  check_apply_server_updates_beta ;;
            backup)  backup_world_data ;;
            status)  display_valheim_server_status ;;
            valheimplus)
                load_mods "valheimplus"
                mods_menu
                ;;
            bepinex)
                load_mods "bepinex"
                bepinex_menu
                ;;
            mods)
                load_mods "all"
                menu
                ;;
            help)
                show_help
                ;;
            *)
                menu
                ;;
            esac
        else
            # Only one argument, assume it's a command
            menu
        fi
        ;;
    esac
fi