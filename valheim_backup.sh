#!/bin/bash

# Extract and store the world names from the default path from the main script
filename="/home/steam/worlds.txt"

declare -a worldNames
i=0

while IFS= read -r line; do
    worldNames[i]=$line
    i=i+1
done < "$filename"

# Paths and naming conventions from the main script
# Generate logs of the process in /var/log/
backupPath=/home/steam/backups
TODAY=$(date +%Y-%m-%d-%T)
logfile=/var/log/valheim-backup

echo "Automated backup and reboot done at $TODAY" >> $logfile

# Iterate over all world names, turn them off and 
# create a backup according to the same convention
# as in the main script. Also write details to the
# log file. Then reboot the server running the Valheim
# servers.

# ToDo: Create error catching and logging.
for name in "${worldNames[@]}"
do
    echo "Stopping server $name" >>  $logfile

    systemctl stop valheimserver_$name.service

    sleep 10

    echo "$name stopped" >>  $logfile

    find "$backupPath/$name/"* -mtime +14 -type f -delete

    sleep 1

    echo "Backing up $name" >>  $logfile

    tar czf "$backupPath/$name/valheim-backup-$TODAY.tgz" "/home/steam/.config/unity3d/IronGate/Valheim/$name/"*

    sleep 10
done

echo "Backed up ${#worldNames[@]} servers" >>  $logfile

echo "Rebooting" >>  $logfile

reboot
