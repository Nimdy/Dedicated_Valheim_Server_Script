# Dedicated_Valheim_Server_Script
# Setup script for linux installations
# Twitch Channel: zerobandwidth
Build Valheim server with one script

DONT USE ON PRODUCTION SERVER UNLESS YOU KNOW WHAT YOU ARE DOING

Tested on Ubuntu 18 64 LTS DigitalOcean, AWS and Azure

CPU: x4
RAM: 8GB
HD: 250GB+


Use my referral link if you do not already have a DigitalOcean Account
https://m.do.co/c/9d2217a2725c


Run as root(if brave enough) or sudo current user 


Install GIT to pull down script
=
```sh
sudo apt-get install -y git net-tools
```
Change to OPT Dir
=
```sh
cd /opt
```

Clone GIT from Nimdy (Zero Bandwidth)
=
```sh
sudo git clone https://github.com/Nimdy/Dedicated_Valheim_Server_Script.git
```
Change dir to Dedicated_Valheim_Server_Script
=
```sh
cd cd Dedicated_Valheim_Server_Script/
```

Allow script to execute
=
sudo chmod +x build_dedicated_valheim_server.sh

Change PASSWORDS and CHANGE ME AREAS before launching
= 
sudo vi build_dedicated_valheim_server.sh


Execute installation file
=
sudo ./build_dedicated_valheim_server.sh
