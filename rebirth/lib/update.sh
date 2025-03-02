#!/bin/bash
###############################################################################################
###############################################################################################
####
#### File name: update.sh
####
###############################################################################################
#### Update functionality for Valheim server
#### Handles checking for updates and applying updates to the server
###############################################################################################

########################################################################
###################### Update Version Functions ########################
########################################################################

# Check for updates to the Valheim server from Steam
function check_apply_server_updates_beta() {
    echo ""
    echo "Downloading Official Valheim Repo Log Data for comparison only"
    
    # Remove appinfo.vdf files
    find "/home" "/root" -wholename "*/.steam/appcache/appinfo.vdf" -exec rm -f {} +

    # Get the official Valheim version from the repository
    repoValheim=$($steamexe +login anonymous +app_info_update 1 +app_info_print 896660 +quit | grep -A10 branches | grep -A2 public | grep buildid | cut -d'"' -f4)
    echo "Official Valheim: $repoValheim"
    
    # Get the local Valheim version
    localValheim=$(grep buildid "${valheimInstallPath}/${worldname}/steamapps/appmanifest_896660.acf" | cut -d'"' -f4)
    echo "Local Valheim Ver: $localValheim"
    
    if [ "$repoValheim" == "$localValheim" ]; then
        echo "No new updates found"
        sleep 2
    else
        echo "Update found, initiating update process!"
        sleep 2
        continue_with_valheim_update_install
        systemctl restart valheimserver_${worldname}.service
        echo ""
    fi
    
    echo ""
}

# Apply official Valheim updates when found
function continue_with_valheim_update_install() {
    clear
    echo ""
    echo -ne "
$(ColorOrange "$FUNCTION_INSTALL_VALHEIM_UPDATES")
$(ColorRed "$DRAW60")"
    echo ""
    tput setaf 2; echo "$FUNCTION_INSTALL_VALHEIM_FOUND"; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_INSTALL_VALHEIM_UPDATE_INFO"; tput setaf 9;
    tput setaf 2; echo "$FUNCTION_INSTALL_VALHEIM_UPDATE_CONFIRM"; tput setaf 9;
    echo -ne "
$(ColorRed "$DRAW60")"
    echo ""
    read -p "$PLEASE_CONFIRM" confirmOfficialUpdates

    # If 'y', then continue, else cancel
    if [ "$confirmOfficialUpdates" == "y" ]; then
        tput setaf 2; echo "$FUNCTION_INSTALL_VALHEIM_UPDATE_APPLY_INFO"; tput setaf 9;
        $steamexe +login anonymous +force_install_dir "${valheimInstallPath}/${worldname}" +app_update 896660 validate +exit
        chown -R steam:steam "${valheimInstallPath}/${worldname}"
        echo ""
    else
        tput setaf 2; echo "$FUNCTION_INSTALL_VALHEIM_UPDATES_CANCEL"; tput setaf 9;
        sleep 3
        clear
    fi
}

# Confirm and check for Valheim server updates
function confirm_check_apply_server_updates() {
    while true; do
        echo -ne "
$(ColorRed "$DRAW60")"
        echo ""
        tput setaf 2; echo "$FUNCTION_CONFIRM_CHECK_APPLY_SERVER_UPDATES_INFO"; tput setaf 9;
        tput setaf 2; echo "$FUNCTION_CONFIRM_CHECK_APPLY_SERVER_UPDATES_INFO_1"; tput setaf 9;
        tput setaf 2; echo "$FUNCTION_CONFIRM_CHECK_APPLY_SERVER_UPDATES_INFO_2"; tput setaf 9;
        tput setaf 2; echo "$PLEASE_CONFIRM"; tput setaf 9;
        echo -ne "
$(ColorRed "------------------------------------------------------------")"
        echo ""
        tput setaf 2; read -p "$FUNCTION_CONFIRM_CHECK_APPLY_SERVER_UPDATES_CONTINUE" yn; tput setaf 9;
        echo -ne "
$(ColorRed "------------------------------------------------------------")"
        
        case $yn in
            [Yy]* )
                check_apply_server_updates_beta
                break
                ;;
            [Nn]* )
                break
                ;;
            * )
                echo "$PLEASE_CONFIRM"
                ;;
        esac
    done
}

# Check current Valheim official release build
function check_official_valheim_release_build() {
    official_build_file="${valheimInstallPath}/${worldname}/officialvalheimbuild"

    update_official_repo() {
        find "/home" "/root" -wholename "*/.steam/appcache/appinfo.vdf" | xargs -r rm -f --
        currentOfficialRepo=$($steamexe +login anonymous +app_info_update 1 +app_info_print 896660 +quit | grep -A10 branches | grep -A2 public | grep buildid | cut -d'"' -f4)
        echo "$currentOfficialRepo" > "$official_build_file"
        chown steam:steam "$official_build_file"
        echo "$currentOfficialRepo"
    }

    if [[ $(find "$official_build_file" -mmin +59 -print) ]]; then
        update_official_repo
    elif [ ! -f "$official_build_file" ]; then
        update_official_repo
    elif [ -f "$official_build_file" ]; then
        currentOfficialRepo=$(cat "$official_build_file")
        echo "$currentOfficialRepo"
    else
        echo "$NO_DATA"
    fi
}

# Check local Valheim build
function check_local_valheim_build() {
    localValheimAppmanifest=${valheimInstallPath}/${worldname}/steamapps/appmanifest_896660.acf
    if [[ -e $localValheimAppmanifest ]]; then
        localValheimBuild=$(grep buildid ${localValheimAppmanifest} | cut -d'"' -f4)
        echo $localValheimBuild
    else 
        echo "$NO_DATA";
    fi
}

# Update ValheimPlus
function valheim_plus_update() {
    check_valheim_plus_repo
    clear
    tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_UPDATE_INFO"; tput setaf 9;

    vpLocalCheck=$(cat "${valheimInstallPath}/${worldname}/localValheimPlusVersion")
    echo "$vpLocalCheck"
    echo "$latestValPlus"

    if [[ "$latestValPlus" == "$vpLocalCheck" ]]; then
        echo ""
        tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_UPDATE_NO_UPDATE_FOUND"; tput setaf 9;
        echo ""
    else
        tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_UPDATE_UPDATE_FOUND"; tput setaf 9;
        tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_UPDATE_CONTINUE"; tput setaf 9;
        read -p "$PLEASE_CONFIRM" confirmValPlusUpdate

        if [ "$confirmValPlusUpdate" == "y" ]; then
            tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_UPDATE_BACKING_UP_VPLUS_CONFIG"; tput setaf 9;
            dldir=$backupPath
            [ ! -d "$dldir" ] && mkdir -p "$dldir"
            sleep 1

            TODAYMK="$(date +%Y-%m-%d-%T)"
            cp "${valheimInstallPath}/${worldname}/BepInEx/config/valheim_plus.cfg" "${backupPath}/valheim_plus-${worldname}-${TODAYMK}.cfg"

            tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_UPDATE_DOWNLOADING_VPLUS"; tput setaf 9;
            install_valheim_plus
            sleep 2

            tput setaf 2; echo "$FUNCTION_VALHEIM_PLUS_UPDATE_RESTARTING_SERVICES"; tput setaf 9;
            restart_valheim_server
        else
            echo "$FUNCTION_VALHEIM_PLUS_UPDATE_CANCELED"; tput setaf 9;
            sleep 2
        fi
    fi
}

# Update BepInEx
function valheim_bepinex_update() {
    clear
    tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_INFO"; tput setaf 9;
    officialBepInEx=$(curl -sL https://valheim.thunderstore.io/package/denikson/BepInExPack_Valheim/ | grep og:title | cut -d'"' -f 4 | cut -d' ' -f 3 | cut -d'v' -f2) 
    localBepInEx=$(cat ${valheimInstallPath}/${worldname}/localValheimBepinexVersion)    
    echo $officialBepInEx
    echo $localBepInEx
    if [[ $officialBepInEx == $localBepInEx ]]; then
        tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_NO_UPDATE_FOUND"; tput setaf 9;
    else
        tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_UPDATE_FOUND"; tput setaf 9;
        tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_CONTINUE"; tput setaf 9;
        read -p "$PLEASE_CONFIRM" confirmValBepinexUpdate
        if [ "$confirmValBepinexUpdate" == "y" ]; then
            tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_BACKING_UP_BEPINEX_CONFIG"; tput setaf 9;
            dldir=$backupPath
            [ ! -d "$dldir" ] && mkdir -p "$dldir"
            sleep 1
            TODAYMK="$(date +%Y-%m-%d-%T)"
            cp ${valheimInstallPath}/${worldname}/BepInEx/config/BepInEx.cfg ${backupPath}/BepInEx.cfg-$TODAYMK.cfg
            tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_DOWNLOADING_BEPINEX"; tput setaf 9;
            install_valheim_bepinex
            sleep 2
            tput setaf 2; echo "$FUNCTION_BEPINEX_UPDATE_RESTARTING_SERVICES"; tput setaf 9;
            restart_valheim_server
        else
            echo "$FUNCTION_BEPINEX_UPDATE_CANCELED"; tput setaf 9;
            sleep 2
        fi
    fi
}