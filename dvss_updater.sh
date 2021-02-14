#!/bin/bash
//simple check and verify script to compare data from master GIT to locally installed dvss script
BRANCH="https://github.com/Nimdy/Dedicated_Valheim_Server_Script.git"
git remote update
LAST_UPDATE=`git show --no-notes --format=format:"%H" $BRANCH | head -n 1`
LAST_COMMIT=`git show --no-notes --format=format:"%H" origin/$BRANCH | head -n 1`
if [ $LAST_COMMIT != $LAST_UPDATE ]; then
        echo "Updating your branch $BRANCH"
        git pull --no-edit
else
        echo "No updates available"
fi
