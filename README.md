# Single installation script for setting up Valheim on a dedicated Linux server.
# Tested on: AWS, Azure and DigitalOcean
# OS - Ubuntu 18.06 LTS 64bit
# Recommended server settings:  CPU: 4 (2 will work but meh)  RAM: 8GB+  Harddrive: 250GB+
# Twitch Channel: zerobandwidth
# Credit and modivation from GeekHead https://www.youtube.com/channel/UCG4EFg9NAskd3X7RoyiomuA
# Credit to nicolas-martin for variable assignment within script

How to set up a Linux Valheim dedicated server:

Use my referral link if you do not already have a DigitalOcean Account, gives me free credit on my account, if not no biggie!
https://m.do.co/c/9d2217a2725c

Never run any script on a production server, unless you know what you are doing.


```sh
DigitalOcean private IP and routing fix for Valheim:

edit 50-cloud-init.yaml

vi /etc/netplan/50-cloud-init.yaml

remove private IP address on eth0 (might be 10.10.something - do not remove your public IP the same one you use to SSH into the server or access it)

netplan apply
systemctl status valheimserver.service
reboot
```

ENJOY!!!


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
(I live in vi... use whatever you wish)
sudo vi build_dedicated_valheim_server.sh

# There are 4 things you need to change!
# NOTE: Minimum password length is 5 characters & Password cant be in the server name.
userpassword="user_password"        <---password for the new Linux User it creates
password="passw0rd"                 <---password for the Valheim Server Access
displayname="server display name"   <---Public display name for server
worldname="111111111"               <---local inside world name

#Save the file
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
