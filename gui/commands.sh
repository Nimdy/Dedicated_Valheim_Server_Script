#1/bin/bash

#trying some different things here to limit www-data and php access but giving it enough power to function correctly


$valheimStart = sudo systemctl start valheimserver_*
$valheimStop = sudo systemctl stop valheimserver_*
$valheimRestart = sudo systemctl restart valheimserver_*
$valheimStatus = sudo systemctl status valheimserver_*

$valheimCopy = sudo cp -R /home/steam/*
$valheimSteamPermissions = sudo chown -Rf steam:steam /home/steam/*


sudo systemctl start valheimserver_*
sudo systemctl stop valheimserver_*
sudo systemctl restart valheimserver_*
sudo systemctl status valheimserver_*

sudo cp -R /home/steam/*
sudo chown -Rf steam:steam /home/steam/*