#!/bin/bash
# Easy Valheim Server Menu
# Open to other commands that should be used... 
clear
title="~*~*~*~*Valheim Toolbox Menu*~*~*~*~"
echo "$title"
PS3='Select SELKS option: '
options=("Valheim Full Server Install" "Check Valheim Server Status" "Stop Valheim Server" "Backup world files" "Restore world files" "Check for Valheim Server updates" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Valheim Full Server Install")
            echo "Oh for Loki, I am building it"
            sudo apt-get install -y git net-tools
            cd /opt
            sudo git clone https://github.com/Nimdy/Dedicated_Valheim_Server_Script.git
            cd Dedicated_Valheim_Server_Script/
            sudo chmod +x build_dedicated_valheim_server.sh
            sudo ufw allow 2456:2458/udp
            sudo ./build_dedicated_valheim_server.sh
            ;;
        "Check Valheim Server Status")
            echo "Check Valheim Server Status"
            sudo systemctl status valheimserver.service 
            ;;
        "Stop Valheim Server")
            echo "Stopping Valheim Server"
            sudo systemctl stop valheimserver.service 
            ;;
        "Backup world files")
            echo "Clearing database logs"
            echo "not added yet"
            ;;
         "Restore world files")
            echo "Clearing database logs"
            echo "not added yet"
            ;;
         "Check for Valheim Server updates")
            echo "Checking for updates"
            echo "not added yet"
            ;;   
         "Quit")
            break
            ;;
       *) echo invalid option;;
    esac
    counter=1
    SAVEIFS=$IFS
    echo "~*~*~*~*Valheim Toolbox Menu*~*~*~*~"
    IFS=$(echo -en "\n\b")
    for i in ${options[@]};
    do
        echo $counter')' $i
        let 'counter+=1'
    done
    IFS=$SAVEIFS
done
