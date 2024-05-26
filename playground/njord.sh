#!/bin/bash

# Load external configurations
CONFIG_FILE="/path/to/your/config.conf"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
else
    echo "Error: Configuration file not found."
    exit 1
fi

# Define color codes
declare -A colors=(
    [nocolor]='\033[0m'
    [red]='\033[0;31m'
    [green]='\033[0;32m'
    [orange]='\033[0;33m'
    [blue]='\033[0;34m'
    [purple]='\033[0;35m'
    [cyan]='\033[0;36m'
    [lightred]='\033[1;31m'
    [lightgreen]='\033[1;32m'
    [yellow]='\033[1;33m'
    [white]='\033[1;37m'
    [clear]='\e[0m'
)

# Utility function to print colored text
print_color() {
    echo -ne "${colors[$1]}$2${colors[clear]}"
}

# Initial check for root privileges
check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        print_color "red" "Error: This script must be run as root.\n"
        exec sudo "$0" "$@"
        exit 1
    fi
}

# Define a logging function
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >>/path/to/valheim_server.log
}

# Error handling function
handle_error() {
    local error_message=$1
    local exit_code=${2:-1} # Default exit code is 1
    print_color "red" "Error: $error_message\n"
    exit $exit_code
}

# Function to read user input
read_setting() {
    local prompt=$1
    local regex=$2
    local input
    while true; do
        read -p "$prompt" input
        if [[ $input =~ $regex ]]; then
            echo $input
            break
        else
            echo "Invalid input. Please try again."
        fi
    done
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Display welcome message
welcome_message() {
    clear
    print_color "blue" "-------------------------------------------------------\n"
    print_color "white" "Since we need to run the menu with elevated privileges\n"
    print_color "white" "Please enter your password now.\n"
    print_color "blue" "-------------------------------------------------------\n"
}

# Refactored function to check for script updates
check_script_update() {
    local upstream_status
    upstream_status=$(git fetch && git status -uno)
    if [[ $upstream_status == *"Your branch is behind"* ]]; then
        echo "Update available. Applying updates..."
        git pull --force
        git stash
        git checkout "$BRANCH"
        git pull --force
        chmod +x "$SCRIPTNAME"
        echo "Script updated. Restarting with new version..."
        exec "$SCRIPTNAME" "${ARGS[@]}"
        exit 1
    else
        echo "No updates available."
    fi
}

# Function to install required packages
install_required_packages() {
    echo "Installing required system packages..."
    command_exists apt-get || handle_error "apt-get command not found."

    apt-get update || handle_error "Failed to update package lists."
    apt-get install -y git mlocate net-tools unzip curl software-properties-common || handle_error "Failed to install required packages."
    add-apt-repository -y multiverse || handle_error "Failed to add multiverse repository."
    dpkg --add-architecture i386 || handle_error "Failed to add i386 architecture."
    apt-get update || handle_error "Failed to update package lists after adding repositories."
}

# Function to handle user inputs for server configuration
configure_server() {
    echo "Configuring server..."
    # Implement the configuration logic here
    # Example: Read and validate server name, world name, and passwords
}

# Main server installation function
install_valheim_server() {
    echo "Starting Valheim server installation..."
    install_required_packages
    configure_server
    # Additional installation steps can be called here
}

# Function to backup world data
backup_world_data() {
    local backup_dir=$backupPath
    local date_stamp=$(date +%Y-%m-%d-%T)
    local backup_file="valheim-backup-${date_stamp}.tgz"

    echo "Initiating backup of world data..."
    mkdir -p "$backup_dir"

    # Stop the server safely before backup
    systemctl stop valheimserver.service
    echo "Server stopped. Performing backup..."

    # Creating tarball of world data
    tar -czf "${backup_dir}/${backup_file}" "$worldpath" || {
        echo "Backup failed: Unable to create backup file."
        return 1
    }

    # Restart server after backup
    systemctl start valheimserver.service
    echo "Server restarted. Backup successful."

    # Optional: Clean up old backups
    find "$backup_dir"/* -mtime +14 -type f -delete
    echo "Old backups cleaned up."

    # Set proper permissions
    chown -R steam:steam "$backup_dir"
    echo "Backup permissions adjusted."
}

# Function to restore world data from backup
restore_world_data() {
    local backup_dir=$backupPath
    local backups=($(ls $backup_dir/*.tgz))
    local choice
    local selected_backup

    echo "Available backups:"
    for i in "${!backups[@]}"; do
        echo "$((i + 1))) ${backups[$i]}"
    done

    read -p "Select backup to restore (number): " choice
    selected_backup="${backups[$((choice - 1))]}"

    if [[ -z "$selected_backup" ]]; then
        echo "Invalid selection. Restoration cancelled."
        return 1
    fi

    # Confirm restoration
    read -p "Confirm restoration from $selected_backup? [y/N]: " confirm
    if [[ $confirm != [yY] ]]; then
        echo "Restoration cancelled."
        return 1
    fi

    # Stop server, restore backup, and restart server
    systemctl stop valheimserver.service
    echo "Server stopped. Restoring data..."

    tar -xzf "$selected_backup" -C "$worldpath" || {
        echo "Restore failed: Unable to extract backup file."
        return 1
    }

    chown -R steam:steam "$worldpath"
    systemctl start valheimserver.service
    echo "Server restarted. Restoration successful."
}

# Start Valheim Server
start_valheim_server() {
    echo "Starting Valheim server..."
    systemctl start valheimserver.service && echo "Server started successfully." || echo "Failed to start server."
}

# Stop Valheim Server
stop_valheim_server() {
    echo "Stopping Valheim server..."
    systemctl stop valheimserver.service && echo "Server stopped successfully." || echo "Failed to stop server."
}

# Restart Valheim Server
restart_valheim_server() {
    echo "Restarting Valheim server..."
    systemctl restart valheimserver.service && echo "Server restarted successfully." || echo "Failed to restart server."
}

# Display Valheim Server Status
display_valheim_server_status() {
    systemctl status valheimserver.service --no-pager -l
}

# Change Server Configuration
change_server_configuration() {
    local new_setting="$1"
    local config_file="${valheimInstallPath}/start_valheim.sh"

    echo "Changing server configuration to: $new_setting"
    sed -i "s/old_setting/$new_setting/" "$config_file" && systemctl restart valheimserver.service
    echo "Configuration updated and server restarted."
}

# Function to check for Valheim server updates
check_for_valheim_updates() {
    echo "Checking for Valheim server updates..."
    local current_version=$(grep buildid "${valheimInstallPath}/steamapps/appmanifest_896660.acf" | cut -d'"' -f4)
    local repository_version=$(/home/steam/steamcmd +login anonymous +app_info_print 896660 +quit | grep -A10 branches | grep -A2 public | grep buildid | cut -d'"' -f4)

    echo "Current Version: $current_version"
    echo "Repository Version: $repository_version"

    if [[ "$current_version" != "$repository_version" ]]; then
        echo "Update available: $repository_version"
        return 0 # Return 0 to indicate that an update is available
    else
        echo "No updates available."
        return 1 # Return 1 to indicate no updates are available
    fi
}

# Function to apply updates
apply_valheim_updates() {
    echo "Applying updates to Valheim server..."
    if /home/steam/steamcmd +login anonymous +force_install_dir "${valheimInstallPath}" +app_update 896660 validate +quit; then
        echo "Valheim server updated successfully."
        log_action "Valheim server updated to latest version."
    else
        echo "Failed to update Valheim server."
        log_action "Failed to update Valheim server."
        # Implement recovery or notification
    fi
}

# Main function to manage updates
manage_valheim_updates() {
    if check_for_valheim_updates; then
        read -p "Do you wish to apply the update now? [y/N]: " confirm
        if [[ $confirm == [yY] ]]; then
            apply_valheim_updates
        else
            echo "Update postponed."
        fi
    fi
}

# Function to update server configuration settings
update_server_setting() {
    local setting_name="$1"
    local new_value="$2"
    local config_file="${valheimInstallPath}/start_valheim.sh"

    echo "Updating $setting_name to $new_value..."
    sed -i "s/^$setting_name=.*/$setting_name=\"$new_value\"/" "$config_file" &&
        echo "$setting_name updated successfully." ||
        echo "Failed to update $setting_name."
}

# Function to manage server settings
manage_server_settings() {
    local setting
    local value

    echo "Available settings to update:"
    echo "1) Server Name"
    echo "2) Server Port"
    echo "3) World Name"
    echo "4) Server Password"
    echo "5) Public Visibility"
    echo "Enter the number of the setting you want to change: "
    read setting

    case $setting in
    1) setting="Server Name" ;;
    2) setting="Server Port" ;;
    3) setting="World Name" ;;
    4) setting="Server Password" ;;
    5) setting="Public Visibility" ;;
    *)
        echo "Invalid option selected."
        return
        ;;
    esac

    echo "Enter new value for $setting:"
    read value

    update_server_setting "$setting" "$value"
}

# Display the main menu
display_main_menu() {
    echo "Valheim Server Management Menu"
    echo "1) Start Server"
    echo "2) Stop Server"
    echo "3) Restart Server"
    echo "4) Update Server"
    echo "5) Backup World Data"
    echo "6) Restore World Data"
    echo "7) Manage Server Settings"
    echo "8) Exit"
    echo "Choose an option: "
}

# Main function handling menu selection
handle_menu_selection() {
    local choice
    read choice
    case $choice in
    1) start_valheim_server ;;
    2) stop_valheim_server ;;
    3) restart_valheim_server ;;
    4) manage_valheim_updates ;;
    5) backup_world_data ;;
    6) restore_world_data ;;
    7) manage_server_settings ;;
    8)
        echo "Exiting..."
        exit 0
        ;;
    *) echo "Invalid option selected. Please try again." ;;
    esac
}

# Main function that integrates the overall functionality
main() {
    # Initial script update check
    check_root
    welcome_message
    check_script_update

    while true; do
        display_main_menu
        handle_menu_selection
    done
}

# Execute the main function
main "$@"
