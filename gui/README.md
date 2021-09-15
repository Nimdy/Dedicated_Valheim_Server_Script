git clone -b beta https://github.com/Nimdy/Dedicated_Valheim_Server_Script.git

after install use option 1337 (it will show up after Valheim installation is detected)

Launch in the web browser

ENjoy....

TO-DO! -Work Player edit for ban,admin...etc

-Work Valheim+ information (if using)

-Work Bepindex install, remove, display mods (if using)

Add whatever we think needs to be added to make it awesome and user friendly

# Is this be best way to secure it?? NO its a huge security punching bag... but we need to do something
# Valheim www-data entry for sudoers

escapeshellcmd(string $command): string

```
www-data   ALL=(ALL) NOPASSWD: /usr/bin/*,/var/www/njordgui/commands.php
```

current sudoer

```
www-data   ALL=(ALL) NOPASSWD: /usr/bin/cp
www-data   ALL=(ALL) NOPASSWD: /usr/bin/systemctl
www-data   ALL=(ALL) NOPASSWD: /usr/bin/echo
www-data   ALL=(ALL) NOPASSWD: /usr/bin/tee
www-data   ALL=(ALL) NOPASSWD: /usr/bin/sed
www-data   ALL=(ALL) NOPASSWD: /usr/bin/unzip
www-data   ALL=(ALL) NOPASSWD: /usr/bin/grep
```

Open to anything else and @Peabo gets 100% for getting us started! Thanks Peabo!!!!!
