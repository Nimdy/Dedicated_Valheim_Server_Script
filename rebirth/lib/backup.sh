#!/bin/bash
###############################################################################################
###############################################################################################
####
#### File name: backup.sh
####
###############################################################################################
#### Backup and restore functionality for Valheim server
#### Handles world data backup and restore operations
###############################################################################################

########################################################################
##########Backup and Restore World DB and FWL Files START###############
########################################################################

# Backup World DB and FWL Files
function backup_world_data() {
    echo ""
    echo ""

    # Read user input confirmation
    tput setaf 1; echo "$BACKUP_WORLD_DATA_HEADER"; tput setaf 9;
    tput setaf 1; echo "$BACKUP_WORLD_INFO_CONFIRM"; tput setaf 9;
    read -p "$BACKUP_WORLD_INPUT_CONFIRM_Y_N" confirmBackup

    # If 'y', then continue, else cancel
    if [ "$confirmBackup" == "y" ]; then
        # Get the current date as variable
        TODAY=$(date +%Y-%m-%d-%T)

        tput setaf 5; echo "$BACKUP_WORLD_CHECK_DIRECTORY"; tput setaf 9;
        tput setaf 5; echo "$BACKUP_WORLD_CHECK_DIRECTORY_1"; tput setaf 9;
        dldir="$backupPath/$worldname"
        [ ! -d "$dldir" ] && mkdir -p "$dldir"
        sleep 1

        # Clean up files older than 2 weeks and create a new backup
        tput setaf 1; echo "$BACKUP_WORLD_CONDUCT_CLEANING"; tput setaf 9;
        find "$backupPath/$worldname/"* -mtime +14 -type f -delete
        tput setaf 2; echo "$BACKUP_WORLD_CONDUCT_CLEANING_LOKI"; tput setaf 9;
        sleep 1

        # Stop Valheim server
        tput setaf 1; echo "$BACKUP_WORLD_STOPPING_SERVICES"; tput setaf 9;
        systemctl stop valheimserver_${worldname}.service
        tput setaf 1; echo "$BACKUP_WORLD_STOP_INFO"; tput setaf 9;
        tput setaf 2; echo "$BACKUP_WORLD_STOP_INFO_1"; tput setaf 9;
        tput setaf 2; echo "$BACKUP_WORLD_STOP_WAIT_10_SEC"; tput setaf 9;
        sleep 10

        # Create a backup tarball
        tput setaf 1; echo "$BACKUP_WORLD_MAKING_TAR"; tput setaf 9;
        tar czf "$backupPath/$worldname/valheim-backup-$TODAY.tgz" "$worldpath/$worldname/"*
        tput setaf 2; echo "$BACKUP_WORLD_MAKING_TAR_COMPLETE"; tput setaf 9;
        sleep 1

        # Restart Valheim server
        tput setaf 2; echo "$BACKUP_WORLD_RESTARTING_SERVICES"; tput setaf 9;
        systemctl start valheimserver_${worldname}.service
        tput setaf 2; echo "$BACKUP_WORLD_RESTARTING_SERVICES_1"; tput setaf 9;
        echo ""

        # Set permissions for backup files
        tput setaf 2; echo "$BACKUP_WORLD_SET_PERMS_FILES"; tput setaf 9;
        chown -Rf steam:steam "$backupPath/$worldname"
        tput setaf 2; echo "$BACKUP_WORLD_PROCESS_COMPLETE"; tput setaf 9;
        echo ""
    else
        tput setaf 3; echo "$BACKUP_WORLD_PROCESS_CANCELED"; tput setaf 9;
    fi
}

# Restore World Files DB and FWL
# Thanks to GITHUB @LachlanMac and @Kurt
function restore_world_data() {
    # Initialize empty array
    declare -a backups

    # Loop through backups and put in array
    for file in "${backupPath}/${worldname}"/*.tgz; do
        backups+=("$file")
    done

    # Counter index
    bIndex=1
    for item in "${backups[@]}"; do
        # Print option [index]> [file name]
        basefile=$(basename "$item")
        echo "$bIndex> $basefile"
        # Increment
        bIndex=$((bIndex + 1))
    done

    # Prompt user for index
    tput setaf 2; echo "$RESTORE_WORLD_DATA_HEADER"; tput setaf 9;
    tput setaf 2; echo "$RESTORE_WORLD_DATA_CONFIRM"; tput setaf 9;
    read -p "$RESTORE_WORLD_DATA_SELECTION" selectedIndex

    # Show confirmation message
    restorefile=$(basename "${backups[selectedIndex - 1]}")
    echo -ne "
$(ColorRed '------------------------------------------------------------')
$(ColorGreen ' '"$RESTORE_WORLD_DATA_SHOW_FILE"' $restorefile ?')
$(ColorGreen ' '"$RESTORE_WORLD_DATA_ARE_YOU_SURE"' ')
$(ColorOrange ' '"$RESTORE_WORLD_DATA_VALIDATE_DATA_WITH_CONFIG"' ${valheimInstallPath}/${worldname}/start_valheim_${worldname}.sh')
$(ColorOrange ' '"$RESTORE_WORLD_DATA_INFO"' ')
$(ColorGreen ' '"$RESTORE_WORLD_DATA_CONFIRM_1"' ') "
    
    # Read user input confirmation
    read -p "" confirmBackupRestore

    # If 'y', then continue, else cancel
    if [ "$confirmBackupRestore" == "y" ]; then
        # Stop Valheim server
        tput setaf 1; echo "$RESTORE_WORLD_DATA_STOP_VALHEIM_SERVICE"; tput setaf 9;
        systemctl stop valheimserver_${worldname}.service
        tput setaf 2; echo "$RESTORE_WORLD_DATA_STOP_VALHEIM_SERVICE_1"; tput setaf 9;
        sleep 5

        # Copy backup to worlds folder
        tput setaf 2; echo "$RESTORE_WORLD_DATA_COPYING ${backups[selectedIndex - 1]} to ${worldpath}/${worldname}/"; tput setaf 9;
        cp "${backups[selectedIndex - 1]}" "${worldpath}/${worldname}/"

        # Unpack backup
        tput setaf 2; echo "$RESTORE_WORLD_DATA_UNPACKING ${worldpath}/${restorefile}"; tput setaf 9;
        tar xzf "${worldpath}/${worldname}/${restorefile}" --strip-components=7 --directory "${worldpath}/${worldname}/"
        chown -Rf steam:steam "${worldpath}/${worldname}/"
        rm "${worldpath}/${worldname}"/*.tgz

        # Start Valheim server
        tput setaf 2; echo "$RESTORE_WORLD_DATA_STARTING_VALHEIM_SERVICES"; tput setaf 9;
        tput setaf 2; echo "$RESTORE_WORLD_DATA_CUSS_LOKI"; tput setaf 9;
        systemctl start valheimserver_${worldname}.service
    else
        tput setaf 2; echo "$RESTORE_WORLD_DATA_CANCEL_CUSS_LOKI"; tput setaf 9;
    fi
}