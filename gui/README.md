## Install instructions
These instrcutions assume you are working on Ubuntu server as outlined by Nimdy.

1) Follow Nimdy's instuctions for setting up and configuring your Valheim server ( https://github.com/Nimdy/Dedicated_Valheim_Server_Script#readme )

2) Install PHP and Apache2

```
sudo apt install php libapache2-mod-php
```

Verify that the install was successful by putting the IP of the server in your web browser. You should see the default Apache2 Ubuntu page. If you have connection issues with this default page, you should verify that HTTP is enabled on the VM.

Note: If you click the little open arrow in the GCP VM management panel next to the server IP it will go to http<b><u>s</u></b>://your-IP, which will not work without further configuration.

3) Remove the default html folder from /var/www/ and then install repository to /var/www/

```
sudo rm -R /var/www/
cd ~
git clone https://github.com/Peabo83/Valheim-Server-Web-GUI.git
sudo cp -R ~/Valheim-Server-Web-GUI/www/ /var/
```

Now when visting the IP of the server you should see the main GUI screen.

4) Change the default username/password/hash keys. Using your preferred text editor open /var/www/VSW-GUI-CONFIG, you will see the inital section with the variables to change:
```
// *************************************** //
// *              VARIABLES              * //
// *************************************** //
	$username = 'Default_Admin';
	$password = 'ch4n93m3';
	$random1 = 'secret_key1';
	$random2 = 'secret_key2';
	$hash = md5($random1.$pass.$random2); 
	$self = $_SERVER['REQUEST_URI'];
	$show_mods = true;
	$cfg_editor = false;
	$make_seed_public = false;
```
Change $username and $password to your preffered values. Change $random1 and $random2 to any variables of your choice, like 'Valheim365' and 'OdinRules'.

5) To execute systemctl commands the PHP user (www-data) needs to be able to run systemctl commands, which by default it can not. The following will allow www-data to run the specific commands used to make the GUI work.

```
sudo visudo
```
This will open your sudo file, add the following at the bottom:

```
# Valheim web server commands
www-data                ALL=(ALL) NOPASSWD: ALL
```

Then hit <kbd>CTRL</kbd> + <kbd>X</kbd> to exit VI, you will be prompted to save, so press <kbd>Y</kbd> and then <kbd>Enter</kbd>. VI will then ask where to save a .tmp file, just hit <kbd>Enter</kbd> again. After you save the .tmp visudo will check the file for errors, if there are none it will push the content to the live file automatically.

6) Enable .htaccess files

Enable the use of .htaccess files for security

add the following to /etc/apache2/sites-enabled/000-default.conf inside the <VirtualHost> tags. 

```
<Directory /var/www/html/content>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
</Directory>
```
