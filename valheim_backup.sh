#!/bin/bash

###############################################################################
# Valheim Server Backup and Management Script
# 
# Purpose: Automatically backup Valheim game servers and manage server shutdown
# Author: GingerSwede
# Last Updated: 2025-01-07
#
# This script performs the following operations:
# 1. Reads world names from a configuration file
# 2. Safely stops each game server
# 3. Ensures complete process termination
# 4. Clears system memory cache
# 5. Creates dated backups
# 6. Removes old backups
# 7. Logs all operations
# 8. Reboots server if all operations successful
###############################################################################

#------------------------------------------------------------------------------
# Configuration Variables
#------------------------------------------------------------------------------

# File containing list of world names to backup
FILENAME="/home/steam/worlds.txt"

# Directory where backups will be stored
BACKUP_PATH="/home/steam/backups"

# Path for logging operations
LOGFILE="/var/log/valheim-backup"

# Base directory where Valheim stores world data
VALHEIM_BASE_PATH="/home/steam/.config/unity3d/IronGate/Valheim"

# Number of days to keep backups before deletion
BACKUP_RETENTION_DAYS=14

# Maximum time in seconds to wait for server shutdown
MAX_WAIT_TIME=60

#------------------------------------------------------------------------------
# Error Handling Configuration
#------------------------------------------------------------------------------

# Exit script immediately if any command exits with non-zero status
set -e

#------------------------------------------------------------------------------
# Utility Functions
#------------------------------------------------------------------------------

# Function: log
# Purpose: Write timestamped messages to log file
# Parameters: $1 - Message to log
log() {
    local timestamp=$(date +"%Y-%m-%d %T")
    echo "[$timestamp] $1" >> "$LOGFILE"
}

# Function: wait_for_server_shutdown
# Purpose: Ensure server processes are completely terminated
# Parameters: $1 - World name to check
# Returns: 0 on success, 1 on failure
wait_for_server_shutdown() {
    local world_name="$1"
    local wait_time=0
    
    log "Waiting for $world_name processes to fully terminate"
    
    while true; do
        # Check for both service process and game server process
        # Returns true if NO processes are found (desired state)
        if ! pgrep -f "valheimserver_$world_name" > /dev/null && \
           ! pgrep -f "valheim_server.x86_64.*$world_name" > /dev/null; then
            log "Server $world_name processes have terminated"
            return 0
        fi
        
        # Increment wait counter and check timeout
        ((wait_time++))
        if [[ $wait_time -ge $MAX_WAIT_TIME ]]; then
            log "ERROR: Server $world_name failed to shut down completely after $MAX_WAIT_TIME seconds"
            # Force kill any remaining processes
            pkill -9 -f "valheimserver_$world_name" || true
            pkill -9 -f "valheim_server.x86_64.*$world_name" || true
            sleep 2
            return 1
        fi
        
        sleep 1
    done
}

# Function: clear_system_cache
# Purpose: Flush filesystem buffers and clear system memory cache
clear_system_cache() {
    log "Clearing system cache"
    # Sync forces cached writes to disk
    sync
    # Write '3' to drop_caches clears both page cache and slab objects/dentries
    echo 3 > /proc/sys/vm/drop_caches || log "WARNING: Failed to clear system cache"
}

# Function: check_paths
# Purpose: Verify all required paths exist before starting operations
check_paths() {
    if [[ ! -f "$FILENAME" ]]; then
        log "ERROR: Worlds file not found at $FILENAME"
        exit 1
    fi
    
    if [[ ! -d "$BACKUP_PATH" ]]; then
        log "ERROR: Backup directory not found at $BACKUP_PATH"
        exit 1
    fi
}

# Function: backup_world
# Purpose: Perform complete backup operation for a single world
# Parameters: $1 - World name to backup
# Returns: 0 on success, 1 on failure
backup_world() {
    local world_name="$1"
    local today=$(date +%Y-%m-%d-%T)
    local world_backup_path="$BACKUP_PATH/$world_name"
    
    # Ensure backup directory exists
    mkdir -p "$world_backup_path"
    
    # Stop the server service
    log "Stopping server $world_name"
    if ! systemctl stop "valheimserver_$world_name.service"; then
        log "ERROR: Failed to stop server $world_name"
        exit 1
    fi
    
    # Ensure complete shutdown
    if ! wait_for_server_shutdown "$world_name"; then
        log "WARNING: Server shutdown may not be complete for $world_name"
    fi
    
    # Clear memory cache to ensure all data is written to disk
    clear_system_cache
    
    # Remove backups older than retention period
    log "Cleaning old backups for $world_name"
    find "$world_backup_path/" -name "valheim-backup-*.tgz" -mtime +"$BACKUP_RETENTION_DAYS" -type f -delete
    
    # Create new backup
    log "Creating backup for $world_name"

    # backupresult

    if ! tar czf "$world_backup_path/valheim-backup-$today.tgz" "$VALHEIM_BASE_PATH/$world_name/"*; then
        log "ERROR: Backup failed for $world_name"
        exit 1
    fi
    exit 1
}

#------------------------------------------------------------------------------
# Main Program Function
#------------------------------------------------------------------------------

main() {
    local success_count=0
    local total_worlds=0
    
    log "Starting automated backup process"
    check_paths
    
    # Read world names into array using mapfile for better handling of special characters
    mapfile -t world_names < "$FILENAME"
    total_worlds=${#world_names[@]}
    
    # Verify we have worlds to process
    if [[ $total_worlds -eq 0 ]]; then
        log "ERROR: No worlds found in $FILENAME"
        exit 1
    fi
        
    # Process each world
    for world in "${world_names[@]}"; do
        local backup_success=$(backup_world "$world")
        if $backup_success; then
            log "Successfully backed up $world"
            success_count=$((success_count+1))
        fi
    done
    
    # Log final results
    log "Backup complete: $success_count/$total_worlds servers backed up successfully"
    
    # Only reboot if all backups were successful
    if [[ $success_count -eq $total_worlds ]]; then
        log "All backups successful, initiating reboot"
        sync  # Final filesystem sync before reboot
        echo "We're rebooting"
        # reboot
    else
        log "WARNING: Some backups failed, manual intervention required"
        exit 1
    fi
}

#------------------------------------------------------------------------------
# Script Execution
#------------------------------------------------------------------------------

# Execute main program
main

# reboot
