# Dedicated_Valheim_Server_Script
# Setup script for linux installations
# Twitch Channel: zerobandwidth
# Credit and modivation from GeekHead https://www.youtube.com/channel/UCG4EFg9NAskd3X7RoyiomuA
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
cd Dedicated_Valheim_Server_Script/
```

Allow script to execute
=
```sh
sudo chmod +x build_dedicated_valheim_server.sh
```

Change PASSWORDS and CHANGE ME AREAS before launching
=
```sh
sudo vi build_dedicated_valheim_server.sh
make edits in 4 locations
(press ESC and save/exit by entering)
:wq!
```


Execute installation file
=
```sh
sudo ./build_dedicated_valheim_server.sh
```
A new version of /boot/grub/menu.lst is available  -  Do this twice
=
```sh
Select  keep the local version currently installed
```

Agree to STEAM LICENSE AGREEMENT
=
```sh
Select Ok
Select Agree
Press Enter
```
