
git clone -b beta https://github.com/Nimdy/Dedicated_Valheim_Server_Script.git

after install use option 1337 (it will show up after Valheim installation is detected)

Launch in the web browser


Need to work the www-data so it only can use functions outline within the commands.php script
-Service stop, start, restart, status (Valheim...etc)
-Work Valheim+ information (is using)
-Work Bepindex install, remove, display mods (if using)

Add whatever we think needs to be added to make it awesome and user friendly

THIS NEEDS TO BE BETTER BELOW - How to limit www-data without giving it access to pop shells and hack user installs?
```
# Valheim web server commands
www-data                ALL=(ALL) NOPASSWD: ALL
```

Do this instead.... needs testing
```
www-data ALL=(ALL) NOPASSWD: systemctl stop valheimserver_$worldname.service
www-data ALL=(ALL) NOPASSWD: systemctl start valheimserver_$worldname.service
www-data ALL=(ALL) NOPASSWD: systemctl status valheimserver_$worldname.service
www-data ALL=(ALL) NOPASSWD: systemctl restart valheimserver_$worldname.service
www-data ALL=(ALL) NOPASSWD: systemctl stop apache2
www-data ALL=(ALL) NOPASSWD: systemctl start apache2
www-data ALL=(ALL) NOPASSWD: systemctl status apache2
www-data ALL=(ALL) NOPASSWD: systemctl restart apache2
www-data ALL=(ALL) NOPASSWD: chown -Rf steam:steam /home/steam *



maybe turn commands.php into commands.sh to allow all www-data to execute commands only found in commands.sh
This might just be the best way
www-data ALL=(ALL) NOPASSWD: /opt/Dedicated_Valheim_Server_Script/gui/commands.sh 

```
ENjoy....



Open to anything else and @Peabo gets 100% for getting us started! Thanks Peabo!!!!!
