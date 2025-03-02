#!/bin/bash
###############################################################################################
###############################################################################################
####
#### File name: config.sh
####
###############################################################################################
#### Configuration settings for Valheim server management
#### Contains all user-configurable settings
###############################################################################################

###############################################################
################### Default Variables #########################
###############################################################
### NOTE: Only change this if you know what you are doing   ###    
###############################################################
###############################################################

### Valheim Server Install location(Default) 
valheimInstallPath=/home/steam/valheimserver

### Valheim World Data Path(Default)
worldpath=/home/steam/.config/unity3d/IronGate/Valheim

### Keeps a list of created Valheim Worlds
worldfilelist=/home/steam/worlds.txt

### Backup Directory (Default)
backupPath=/home/steam/backups

###
###  Configs for Advanced Users ###
###

### This option is only for the steamcmd install where it 
### is not included in the "steam" client install ... i.e., RH/OEL-yum
### Set this to delete all files from the /home/steam/steamcmd directory to install steamcmd fresh.
### Defaults are "n" on the below parameters.
### <n : no>
### <y : yes>
freshinstall="n"

### **** Firewall setup ***
### Do you use a firewall?
usefw="n" 

### what firewall do you want to use? 
# Change the following value to one listed in the fwsystems list below or use 'none'.
fwbeingused="firewalld"

# Do not change this - only add to it.
fwsystems=( arptables ebtables firewalld iptables ip6tables ufw )

###############################################################
debugmsg="n"
# if [ "$debugmsg" == "y" ] ; then echo "something" ; fi
###############################################################

# Set Menu Version for menu display
mversion="4.0-Thor"
ldversion="0.4.051120211500ET.dev"