#!/bin/bash

# All in one Script to install Valheim Dedicated Server
# Thanks to nicolas-martin for the variable assignment changes
# Thanks to YT: GeekHead for modivating me to do this
#making changes to push beta


# There are 4 things you need to change!
# NOTE: Minimum password length is 5 characters & Password cant be in the server name.
userpassword='"user_password"'
password='"passw0rd"'
displayname='"server display name"'
worldname='"111111111"'
port='"2456"'

#check for updates and upgrade the system auto yes
tput setaf 2; echo "Checking for upgrades"
apt update && apt upgrade -y
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#add multiverse repo
tput setaf 2; echo "Adding multiverse REPO"
add-apt-repository -y multiverse
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#add i386 architecture
tput setaf 1; echo "Adding i386 architecture"
dpkg --add-architecture i386
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#update system again
tput setaf 1; echo "Checking and updating system again"
apt update
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#install steamcmd
tput setaf 1; echo "Installing steamcmd and libsdl2"
apt install steamcmd libsdl2-2.0-0 libsdl2-2.0-0:i386 -y
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#EDIT HERE #1
#build account to run Valheim
tput setaf 1; echo "Building steam account NONROOT"
sleep 1
useradd --create-home --shell /bin/bash --password $userpassword steam
cp /etc/skel/.bashrc /home/steam/.bashrc
cp /etc/skel/.profile /home/steam/.profile
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#build symbolic link for steamcmd
tput setaf 1; echo "Building symbolic link for steamcmd"
ln -s /usr/games/steamcmd /home/steam/steamcmd
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#chown steam user to steam
tput setaf 1; echo "Setting steam permissions"
chown steam:steam /home/steam/steamcmd
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#Download Valheim from steam
tput setaf 1; echo "Downloading and installing Valheim from Steam"
sleep 1
tput setaf 9;
/home/steam/steamcmd +login anonymous +force_install_dir /home/steam/valheimserver +app_update 896660 validate +exit
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#build config for start_valheim.sh
tput setaf 1; echo "Deleting old configuration if file exist"
tput setaf 1; echo "Building Valheim start_valheim server configuration"
rm /home/steam/valheimserver/start_valheim.sh
sleep 1
cat >> /home/steam/valheimserver/start_valheim.sh <<EOF
#!/bin/bash
export templdpath=$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH
export SteamAppId=892970

# Tip: Make a local copy of this script to avoid it being overwritten by steam.
# NOTE: You need to make sure the ports 2456-2458 is being forwarded to your server through your local router & firewall.
./valheim_server.x86_64 -name $displayname -port $port -nographics -batchmode -world $worldname -password $password

export LD_LIBRARY_PATH=$templdpath
EOF
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#build check log script
tput setaf 1; echo "Deleting old configuration if file exist"
tput setaf 1; echo "Building check log script"
rm /home/steam/check_log.sh
sleep 1
cat >> /home/steam/check_log.sh <<EOF
journalctl --unit=valheimserver --reverse
EOF
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#set execute permissions
tput setaf 1; echo "Setting execute permissions on start_valheim.sh"
chmod +x /home/steam/valheimserver/start_valheim.sh
tput setaf 2; echo "Done"
tput setaf 1; echo "Setting execute permissions on check_log.sh"
chmod +x /home/steam/check_log.sh
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#build systemctl configurations for execution of processes for Valheim Server
tput setaf 1; echo "Deleting old configuration if file exist"
tput setaf 1; echo "Building systemctl instructions for Valheim"
rm /etc/systemd/system/valheimserver.service
sleep 1
cat >> /etc/systemd/system/valheimserver.service <<EOF
[Unit]
Description=Valheim Server
Wants=network-online.target
After=syslog.target network.target nss-lookup.target network-online.target

[Service]
Type=simple
Restart=on-failure
RestartSec=5
StartLimitInterval=60s
StartLimitBurst=3
User=steam
Group=steam
ExecStartPre=/home/steam/steamcmd +login anonymous +force_install_dir /home/steam/valheimserver +app_update 896660 validate +exit
ExecStart=/home/steam/valheimserver/start_valheim.sh
ExecReload=/bin/kill -s HUP $MAINPID
KillSignal=SIGINT
WorkingDirectory=/home/steam/valheimserver
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

#chown steam user permissions to all of user steam dir location
tput setaf 1; echo "Setting steam account permissions to /home/steam/*"
chown steam:steam -Rf /home/steam/*
tput setaf 2; echo "Done"
tput setaf 9;
sleep 1

# Reload daemons
tput setaf 1; echo "Reloading daemons"
systemctl daemon-reload
tput setaf 2; echo "Done"
sleep 1

# Start server
tput setaf 1; echo "Starting Valheim Server"
systemctl start valheimserver
tput setaf 2; echo "Done"
sleep 1

# Enable server on restarts
tput setaf 1; echo "Enabling Valheim Server on start or after reboots"
systemctl enable valheimserver
tput setaf 2; echo "Done"
sleep 2
clear
tput setaf 2; echo "Check server status by typing systemctl status valheimserver.service"
tput setaf 2; echo "Thank you for using the script."
tput setaf 2; echo "Twitch: ZeroBandwidth"
tput setaf 2; echo "GLHF"
tput setaf 9;
