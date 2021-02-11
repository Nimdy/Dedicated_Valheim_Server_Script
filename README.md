[![Thumbnail](https://img.youtube.com/vi/0YPLf7Bw5W4/0.jpg)](https://www.youtube.com/watch?v=0YPLf7Bw5W4)

# Single installation script for setting up Valheim on a dedicated Linux server with steamcmd.
###### Tested on: AWS, Azure and DigitalOcean
###### OS - Ubuntu 18.06 LTS 64bit and Ubuntu 20.04 LTS (tested 10 FEB 2021)
###### Recommended server settings:  CPU: 4 (2 will work but meh)  RAM: 8GB+  Harddrive: 250GB+
###### My Twitch Channel: https://www.twitch.tv/zerobandwidth
###### My Discord for Tech Support https://discord.gg/ejgQUfc
###### Credit and modivation from YT GeekHead
###### Credit to nicolas-martin for variable assignment within script

### Game is in Early Access meaning tons of updates and broken servers. Please post issues so we can make our edits and keep you up and running!
Worlds are saved: /home/steam/.config/unity3d/IronGate/Valheim/worlds/(here.fwl)

How to set up a Linux Valheim dedicated server:

Use my referral link if you do not already have a DigitalOcean Account, gives me free credit on my account, if not no biggie!
https://m.do.co/c/9d2217a2725c

Use my code and you get $100 in credit over 60 days. (good way to test your dedicated server)

Never run any script on a production server, unless you know what you are doing.

```
Create VM with minimum 2 CPUs and 4GB of ram. Otherwise server won't start.
```


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


1.Install GIT to pull down script
=
```sh
sudo apt-get install -y git net-tools
```
2.Change to OPT Dir
=
```sh
cd /opt
```
3.Clone GIT from Nimdy (Zero Bandwidth)
=
```sh
sudo git clone https://github.com/Nimdy/Dedicated_Valheim_Server_Script.git
```
4.Change dir to Dedicated_Valheim_Server_Script
=
```sh
cd Dedicated_Valheim_Server_Script/
```
5.Allow script to execute
=
```sh
sudo chmod +x build_dedicated_valheim_server.sh
```

6.Change PASSWORDS and CHANGE ME AREAS before launching
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

7.Execute installation file
=
```sh
sudo ./build_dedicated_valheim_server.sh
```
8.A new version of /boot/grub/menu.lst promotx2 - Keep local version
=
```sh
Select  keep the local version currently installed
```
9.Agree to STEAM LICENSE AGREEMENT
=
```sh
Select Ok
Select I Agree
Press Enter
```
10.Allow ports 2456,2457,2458 on your server UDP (TCP shouldnt matter but whatever)
=
```sh
sudo ufw allow 2456:2458/tcp
sudo ufw allow 2456:2458/udp
```
11.Stop Valheim service
=
```sh
sudo systemctl stop valheimserver.service
```
12.Reboot Server for the lawls!
=
```sh
sudo reboot
```

13.Once your server comes back online wait 2-5 mins and check Valheim service
=
```sh
sudo systemctl status valheimserver.service
```

###Congratz! You did it, now get out there and start exploring with your friends!!!
