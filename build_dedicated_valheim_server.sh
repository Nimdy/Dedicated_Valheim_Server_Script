#!/bin/bash

# All in one Script to install Valheim Dedicated Server
# Change PASSWORDS and CHANGE ME AREAS for launching

#switch to root if not already
sudo -s

#check for updates and upgrade the system auto yes
apt update && apt upgrade -y

#add multiverse repo
add-apt-repository -y multiverse

#add i386 architecture
dpkg --add-architecture i386

#update system again
apt update

#install steamcmd
apt install steamcmd -y

#build account to run Valheim CHANGE PASSWORD PLEASE
useradd --create-home --shell /bin/bash --password CHANGEME steam

# switch to newly created steam user
su - steam

#build symbolic link for steamcmd
ln -s /usr/games/steamcmd steamcmd

#set steamcmd execution 
steamcmd +login anonymous +force_install_dir /home/steam/valheimserver +app_update 896660 validate +exit

#build config for start_valheim.sh

cat >> /home/steam/valheimserver/start_valheim.sh <<EOF
#!/bin/bash
export templdpath=$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=./linux64:$LD_LIBRARY_PATH
export SteamAppId=892970

# Tip: Make a local copy of this script to avoid it being overwritten by steam.
# NOTE: Minimum password length is 5 characters & Password cant be in the server name.
# NOTE: You need to make sure the ports 2456-2458 is being forwarded to your server through your local router & firewall.
./valheim_server.x86_64 -name "DISPLAYNAMECHANGEME" -port 2456 -nographics -batchmode -world "CHANGEMEWORLDNAME" -password "CHANGEME PASSWORD" -public 1

export LD_LIBRARY_PATH=$templdpath
EOF

#build check log script

cat >> /home/steam/check_log.sh <<EOF
journalctl --unit=valheimserver --reverse
EOF

#set execute permissions
chmod +x /home/steam/valheimserver/start_valheim.sh
chmod +x /home/steam/check_log.sh

#leave steam user bash envoriment and enter back into root
exit

#build systemctl configurations for execution of processes for Valheim Server

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
ExecStop=/bin/kill -s INT $MAINPID
WorkingDirectory=/home/steam/valheimserver
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF

# Reload daemons
systemctl daemon-reload
# Start server
systemctl start valheimserver
# Enable server on restarts
systemctl enable valheimserver
