#!/bin/bash
###############################################################################################
###############################################################################################
####
#### File name: ui.sh
####
###############################################################################################
#### User interface functions for Valheim server management
#### Contains menu systems and display functionality
###############################################################################################

########################################################################
################### Menu Header and UI Functions #######################
########################################################################

# Display header for main menu
function menu_header() {
    get_current_config
    echo -ne "
$(ColorOrange '╔══════════════════════════════════════════════════════════╗')
$(ColorOrange '║~~~~~~~~~~*****~~~~~~~~-Njord Menu-~~~~~~~~~*****~~~~~~~~~║')
$(ColorOrange '╠══════════════════════════════════════════════════════════╝')
$(ColorOrange '║'" $FUNCTION_HEADER_MENU_INFO_VALHEIM_OFFICIAL_BUILD"'')" $(check_official_valheim_release_build)
    echo -ne "
$(ColorOrange '║'" $FUNCTION_HEADER_MENU_INFO_VALHEIM_LOCAL_BUILD"' ') $(check_local_valheim_build)
$(ColorOrange '║')" $FUNCTION_HEADER_MENU_INFO_LD_SEVER_SESSION $(ColorGreen ''"${worldname}"'')
    echo -ne "
$(ColorOrange '║')" $FUNCTION_HEADER_MENU_INFO_SERVER_NAME $(ColorGreen ''"${currentDisplayName}"'')
    echo -ne " 
$(ColorOrange '║') $(are_you_connected)
$(ColorOrange '║')" $(display_public_IP)
    echo -ne "
$(ColorOrange '║')" $(display_local_IP) 
    echo -ne "
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_SERVER_PORT" $(ColorGreen ''"${currentPort}"'')
    echo -ne " 
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_PUBLIC_LIST" $(ColorGreen ''"$(display_public_status_on_or_off)"'')
    echo -ne "
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_SERVER_AT_GLANCE" $(server_status) and $(server_substate)
    echo -ne "
$(ColorOrange '║') Crossplay status:" $(display_crossplay_status)    
echo -ne " 
$(ColorOrange '║') Crossplay Game Code:" $(display_last_join_code)    
echo -ne " 
$(ColorOrange '╠═══════════════════════════════════════════════════════════')"
echo -ne " 
$(ColorOrange '║') Current Players Online:" $(current_player_count)    
echo -ne " 
$(ColorOrange '╠═══════════════════════════════════════════════════════════')"
    echo -ne "
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_SERVER_UFW" $(get_firewall_status)
    echo -ne "
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_SERVER_UFW_SUBSTATE -- substatus" $(get_firewall_substate) 
    echo -ne " 
$(ColorOrange '╠═══════════════════════════════════════════════════════════')"
    echo -ne "
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_CURRENT_NJORD_RELEASE $(ColorGreen ''"$(check_menu_script_repo)"'')
$(ColorOrange '║') $FUNCTION_HEADER_MENU_INFO_LOCAL_NJORD_VERSION $(ColorGreen ''"${mversion}"'')
$(ColorOrange '║ '"$FUNCTION_HEADER_MENU_INFO"'')
$(ColorOrange '║ '"$FUNCTION_HEADER_MENU_INFO_1"'')
$(ColorOrange '║ '"$FUNCTION_HEADER_MENU_INFO_2"'')
$(ColorOrange '╚═══════════════════════════════════════════════════════════')"
}

# Display header for ValheimPlus menu
function menu_header_vplus_enable() {
    get_current_config
    echo -ne "
$(ColorPurple '╔════════════════════')$(ColorOrange 'Valheim+')$(ColorPurple '═══════════════════╗')
$(ColorPurple '║~~~~~~~~~~~~~~~~~~')$(ColorLightGreen '-Njord Menu-')$(ColorPurple '~~~~~~~~~~~~~~~~~║')
$(ColorPurple '╠═══════════════════════════════════════════════╝')
$(ColorPurple '║')$(ColorLightGreen ' Welcome to Valheim+ Intergrated Menu System')
$(ColorPurple '║')$(ColorLightGreen ' Valheim+ Support: https://discord.gg/WU69A2JTcn')
$(ColorPurple '║ '"$FUNCTION_HEADER_MENU_INFO_2"'')
$(ColorPurple '╠═══════════════════════════════════════════════')
$(ColorPurple '║ Mods:') $(are_mods_enabled)
$(ColorPurple '╠═══════════════════════════════════════════════')
$(ColorPurple '║') ValheimPlus Official Build:" $(check_valheim_plus_repo)
echo -ne "
$(ColorPurple '║') ValheimPlus Server Build:" $(check_local_valheim_plus_build)
echo -ne "
$(ColorPurple '╠═══════════════════════════════════════════════')
$(ColorPurple '║ '"$FUNCTION_HEADER_MENU_INFO_VALHEIM_OFFICIAL_BUILD"'')" $(check_official_valheim_release_build)
echo -ne "
$(ColorPurple '║ '"$FUNCTION_HEADER_MENU_INFO_VALHEIM_LOCAL_BUILD"' ')"        $(check_local_valheim_build)
echo -ne "
$(ColorPurple '╠═══════════════════════════════════════════════')"
echo -ne "
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_SERVER_NAME " ${currentDisplayName}
echo -ne "
$(ColorPurple '║')" $FUNCTION_HEADER_MENU_INFO_LD_SEVER_SESSION $(ColorGreen ''"${worldname}"'')
echo -ne " 
$(ColorPurple '║') $(are_you_connected)
$(ColorPurple '║')" $(display_public_IP)
echo -ne "
$(ColorPurple '║')" $(display_local_IP)
echo -ne "
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_SERVER_PORT " ${currentPort}
echo -ne "
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_PUBLIC_LIST " $(display_public_status_on_or_off)
echo -ne "
$(ColorPurple '╠═══════════════════════════════════════════════')
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_CURRENT_NJORD_RELEASE $(check_menu_script_repo)
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_LOCAL_NJORD_VERSION ${mversion}
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_GG_ZEROBANDWIDTH
$(ColorPurple '║') $FUNCTION_HEADER_MENU_INFO_1
$(ColorPurple '╚═══════════════════════════════════════════════')"
}

# Display header for BepInEx menu
function menu_header_bepinex_enable() {
    get_current_config
    echo -ne "
$(ColorCyan '╔═════════════════════')$(ColorOrange 'BepInEx')$(ColorCyan '═══════════════════╗')
$(ColorCyan '║~~~~~~~~~~~~~~~~~~')$(ColorLightGreen '-Njord Menu-')$(ColorCyan '~~~~~~~~~~~~~~~~~║')
$(ColorCyan '╠═══════════════════════════════════════════════╝')
$(ColorCyan '║')$(ColorLightGreen ' Welcome to BepInEx Intergrated Menu System')
$(ColorCyan '║')$(ColorLightGreen ' BepInEx Support: https://discord.gg/MpFEDAg')
$(ColorCyan '║ '"$FUNCTION_HEADER_MENU_INFO_2"'')
$(ColorCyan '╠═══════════════════════════════════════════════')
$(ColorCyan '║ Mods:') $(are_mods_enabled)
$(ColorCyan '╠═══════════════════════════════════════════════')
$(ColorCyan '║') BepInEx Official Build:" $(check_bepinex_repo)
echo -ne "
$(ColorCyan '║') BepInEx Server Build:" $(check_local_bepinex_build)
echo -ne "
$(ColorCyan '╠═══════════════════════════════════════════════')
$(ColorCyan '║ '"$FUNCTION_HEADER_MENU_INFO_VALHEIM_OFFICIAL_BUILD"'')" $(check_official_valheim_release_build)
echo -ne "
$(ColorCyan '║ '"$FUNCTION_HEADER_MENU_INFO_VALHEIM_LOCAL_BUILD"' ')"        $(check_local_valheim_build)
echo -ne "
$(ColorCyan '╠═══════════════════════════════════════════════')"
echo -ne "
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_SERVER_NAME" ${currentDisplayName}
echo -ne "
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_LD_SEVER_SESSION" ${worldname}
echo -ne " 
$(ColorCyan '║') $(are_you_connected)
$(ColorCyan '║')" $(display_public_IP)
echo -ne "
$(ColorCyan '║')" $(display_local_IP)
echo -ne "
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_SERVER_PORT " ${currentPort}
echo -ne "
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_PUBLIC_LIST " $(display_public_status_on_or_off)
echo -ne "
$(ColorCyan '╠═══════════════════════════════════════════════')
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_CURRENT_NJORD_RELEASE $(check_menu_script_repo)
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_LOCAL_NJORD_VERSION ${mversion}
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_GG_ZEROBANDWIDTH
$(ColorCyan '║') $FUNCTION_HEADER_MENU_INFO_1
$(ColorCyan '╚═══════════════════════════════════════════════')"
}

########################################################################
######################## Menu Systems #################################
########################################################################

# Server installation menu
function server_install_menu() {
    echo ""
    echo -ne "
$(ColorOrange ''"$FUNCTION_SERVER_INSTALL_MENU_HEADER"'')
$(ColorOrange '-')$(ColorGreen '1)') "$FUNCTION_SERVER_INSTALL_MENU_OPT_1."
$(ColorOrange '-')$(ColorGreen '2)') "Setup another Valheim server on diff port."
$(ColorOrange '-')$(ColorGreen '0)') "$RETURN_MAIN_MENU."
$(ColorOrange ''"$DRAW60"'')
$(ColorPurple ''"$CHOOSE_MENU_OPTION"'') "
    read a
    case $a in
        1) newinstall="y"
           valheim_server_install ; 
           server_install_menu ;;
        2) newinstall="n"
           valheim_server_install ; 
           server_install_menu ;;
        0) menu ; menu ;;
        *)  echo -ne " $(ColorRed ''"$WRONG_MENU_OPTION"'')" ; server_install_menu ;;
    esac
}

# Firewall administration menu
function firewall_admin_menu() {
    menu_header
    if [ "${usefw}" == "n" ] ; then
        echo ""
        echo "The firewall admin system is not enabled."
        echo "Please open the njordmenu.sh file and modify the header parameters to enable."
        echo "Returning to main menu."
        echo ""
        sleep 2
        menu
    else
        echo -ne "
$(ColorOrange '"╔══Valheim Server Firewall Infomation and control Center═══╗"'')
$(ColorOrange '║~~~~~~~~~~~~~~~~~~')$(ColorLightGreen '-Njord Menu-')$(ColorCyan '~~~~~~~~~~~~~~~~~║')
$(ColorOrange '╠═══════════════════════════════════════════════╝')"
is_admin_firewall_installed
is_admin_firewall_enabled
is_any_firewall_installed
is_any_firewall_enabled
        echo -ne "
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ "FireWallD actions for this Valheim server"'')
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ ')$(ColorGreen '1)') Show system status            
$(ColorOrange '║ ')$(ColorGreen '2)') Show system substate          
$(ColorOrange '║ ')$(ColorGreen '3)') Dump all information on the firewall 
$(ColorOrange '║ ')$(ColorGreen '4)') Add the Steam ports to the firewall
$(ColorOrange '║ ')$(ColorGreen '5)') Remove the Steam ports from the firewall
$(ColorOrange '║ ')$(ColorGreen '6)') Add this Valheim service port to the firewall
$(ColorOrange '║ ')$(ColorGreen '7)') Remove this Valheim service port from the firewall "
        if [ "${fwbeingused}" == "firewalld" ] ; then
        echo -ne "
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange ''"Specifc to FireWallD for this Valheim world."'')
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ ')$(ColorGreen '50)') Create the service file
$(ColorOrange '║ ')$(ColorGreen '51)') Delete the service file
$(ColorOrange '║ ')$(ColorGreen '52)') Add the public service  
$(ColorOrange '║ ')$(ColorGreen '53)') Remove the public service for Valheim server "
        fi
        echo -ne "
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ "To help verify/install perfered firewall system"'')
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ ')$(ColorGreen '100)') Verify/install the perfered firewall system.
$(ColorOrange '║ ')$(ColorGreen '101)') Verify/enable the prefered firewall system.
$(ColorOrange '║ ')$(ColorGreen '102)') Stop all known firewall systems.             
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ ')$(ColorGreen '0)') "$RETURN_MAIN_MENU."
$(ColorOrange '╠═══════════════════════════════════════════════')
$(ColorOrange '║ "$DRAW60"'')
$(ColorPurple '║ "$CHOOSE_MENU_OPTION"'')
$(ColorPurple '╚═══════════════════════════════════════════════')"
        read a
        case $a in
        1) get_firewall_status ; firewall_admin_menu ;;
        2) get_firewall_substate ; firewall_admin_menu ;;
        3) get_firewall_info ; firewall_admin_menu ;;
        4) sftc="ste" ; add_Valheim_server_public_ports ; firewall_admin_menu ;;
        5) sftc="ste" ; remove_Valheim_server_public_ports ; firewall_admin_menu ;;
        6) sftc="val" ; add_Valheim_server_public_ports ; firewall_admin_menu ;;
        7) sftc="val" ; remove_Valheim_server_public_ports ; firewall_admin_menu ;;
        50) create_firewalld_service_file ; firewall_admin_menu ;;
        51) delete_firewalld_service_file ; firewall_admin_menu ;;
        52) add_firewalld_public_service ; firewall_admin_menu ;;
        53) remove_firewalld_public_service ; firewall_admin_menu ;;
        100) is_admin_firewall_installed ; firewall_admin_menu ;;
        101) is_admin_firewall_enabled ; firewall_admin_menu ;;
        102) disable_all_firewalls ; firewall_admin_menu ;;
        0) menu ; menu ;;
        *)  echo -ne " $(ColorRed ''"$WRONG_MENU_OPTION"'')" ; firewall_admin_menu ;;
        esac
    fi
}

# Tech support menu
function tech_support(){
    menu_header
    echo ""
    echo -ne "
$(ColorOrange ''"$FUNCTION_VALHEIM_TECH_SUPPORT_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 1)') $FUNCTION_VALHEIM_TECH_SUPPORT_DISPLAY_CONFIG
$(ColorOrange '-')$(ColorGreen ' 2)') $FUNCTION_VALHEIM_TECH_SUPPORT_DISPLAY_VALHEIM_SERVICE
$(ColorOrange '-')$(ColorGreen ' 3)') $FUNCTION_VALHEIM_TECH_SUPPORT_DISPLAY_WORLD_DATA
$(ColorOrange '-')$(ColorGreen ' 4)') $FUNCTION_VALHEIM_TECH_SUPPORT_DISPLAY_SYSTEM_INFO
$(ColorOrange '-')$(ColorGreen ' 5)') $FUNCTION_VALHEIM_TECH_SUPPORT_DISPLAY_NETWORK_INFO
$(ColorOrange '-')$(ColorGreen ' 6)') $FUNCTION_VALHEIM_TECH_SUPPORT_DISPLAY_CONNECTED_PLAYER_HISTORY
$(ColorOrange '-')$(ColorGreen ' 7)') Show World Seed
$(ColorOrange '-')$(ColorGreen ' 8)') System preformance (TOP)
$(ColorOrange '------------------------------------------------------------')
$(ColorOrange '-')$(ColorGreen ' 0)') "$RETURN_MAIN_MENU"
$(ColorOrange '------------------------------------------------------------')
$(ColorPurple ''"$CHOOSE_MENU_OPTION"'') "
        read a
        case $a in
            1) display_start_valheim ; tech_support ;; 
            2) display_valheim_server_status ; tech_support ;;
            3) display_world_data_folder ; tech_support ;;
            4) display_system_info ; tech_support ;;
            5) display_network_info ; tech_support ;;
            6) display_player_history ; tech_support ;;
            7) get_worldseed ; tech_support ;;
            8) top -u steam ; tech_support ;; 
            0) menu ; menu ;;
            *)  echo -ne " $(ColorRed ''"$WRONG_MENU_OPTION"'')" ; tech_support ;;
        esac
}

# Main menu
function menu(){
    if [ "${worldname}" = "" ] ; then  set_world_server ; fi
    menu_header
    echo -ne "
$(ColorOrange '-'"$FUNCTION_MAIN_MENU_CHECK_SCRIPT_UPDATES_HEADER"' ')
$(ColorOrange '-')$(ColorGreen ' 1)') $FUNCTION_MAIN_MENU_UPDATE_NJORD_MENU
$(ColorOrange ''"$FUNCTION_MAIN_MENU_SERVER_COMMANDS_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 2)') $FUNCTION_MAIN_MENU_TECH_MENU
$(ColorOrange '-')$(ColorGreen ' 3)') $FUNCTION_MAIN_MENU_INSTALL_VALHEIM
$(ColorOrange ''"$FUNCTION_MAIN_MENU_FIREWALL_VALHEIM_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 4)') $FUNCTION_MAIN_MENU_FIREWALL_VALHEIM
$(ColorOrange ''"$FUNCTION_MAIN_MENU_OFFICAL_VALHEIM_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 5)') $FUNCTION_MAIN_MENU_CHECK_APPLY_VALHEIM_UPDATES
$(ColorOrange ''"$FUNCTION_MAIN_MENU_EDIT_VALHEIM_CONFIG_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 6)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_DISPLAY_CONFIG
$(ColorOrange '-')$(ColorGreen ' 7)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_CHANGE_WORLD_NAME
$(ColorOrange '-')$(ColorGreen ' 8)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_CHANGE_PUBLIC_NAME
$(ColorOrange '-')$(ColorGreen ' 9)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_CHANGE_SERVER_PORT
$(ColorOrange '-')$(ColorGreen ' 10)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_CHANGE_ACCESS_PASS
$(ColorOrange '-')$(ColorGreen ' 11)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_ENABLE_PUBLIC_LISTING
$(ColorOrange '-')$(ColorGreen ' 12)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_DISABLE_PUBLIC_LISTING
$(ColorOrange '-')$(ColorGreen ' 13)') Set Crossplay options
$(ColorOrange ''"$DRAW60"'')
$(ColorOrange '-')$(ColorGreen ' 14)') $FUNCTION_ADMIN_TOOLS_MENU_STOP_SERVICE
$(ColorOrange '-')$(ColorGreen ' 15)') $FUNCTION_ADMIN_TOOLS_MENU_START_SERVICE
$(ColorOrange '-')$(ColorGreen ' 16)') $FUNCTION_ADMIN_TOOLS_MENU_RESTART_SERVICE
$(ColorOrange '-')$(ColorGreen ' 17)') $FUNCTION_ADMIN_TOOLS_MENU_STATUS_SERVICE
$(ColorOrange ''"$DRAW60"'')
$(ColorOrange '-')$(ColorGreen ' 18)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_BACKUP_WORLD_DATA
$(ColorOrange '-')$(ColorGreen ' 19)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_RESTORE_WORLD_DATA
$(ColorOrange ''"$FUNCTION_MAIN_MENU_EDIT_VALHEIM_MODS_HEADER"'')
$(ColorOrange '-')$(ColorGreen ' 20)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_MODS_MSG_YES
$(ColorOrange '-')$(ColorGreen ' 21)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_MODS_MSG_YES_BEP
$(ColorOrange ''"$DRAW60"'')
$(ColorOrange '-')$(ColorGreen ' 99)') " $FUNCTION_MAIN_MENU_LD_CHANGE_SESSION_CURRENT_WORLD
[ -f "$worldfilelist" ] || echo -ne "
$(ColorOrange '-')$(ColorGreen ' 0000)') " Upgrade Old Menu to New Njord Menu
echo -ne "
$(ColorOrange ''"$DRAW60"'')
$(ColorGreen ' 0)') $FUNCTION_MAIN_MENU_EDIT_VALHEIM_EXIT
$(ColorOrange ''"$DRAW60"'')
$(ColorPurple ''"$CHOOSE_MENU_OPTION"'') "
        read a
        case $a in
            1) script_check_update ; menu ;;
            2) tech_support ; menu ;;
            3) server_install_menu ; menu ;;
            4) firewall_admin_menu ; menu ;; 
            5) confirm_check_apply_server_updates ; menu ;;    
            6) display_full_config ; echo "BACK TO MENU IN 5 SECONDS" ; sleep 5 ; menu ;;
            7) change_local_world_name ; menu ;;
            8) change_public_display_name ; menu ;;        
            9) change_default_server_port ; menu ;;
            10) change_server_access_password ; menu ;;
            11) write_public_on_config_and_restart ; menu ;;
            12) write_public_off_config_and_restart ; menu ;;
            13) change_crossplay_status ; menu ;;
            14) stop_valheim_server ; menu ;;
            15) start_valheim_server ; menu ;;
            16) restart_valheim_server ; menu ;;
            17) display_valheim_server_status ; menu ;;
            18) backup_world_data ; menu ;;
            19) restore_world_data ; menu ;;
            20) mods_menu ; mods_menu ;;
            21) bepinex_menu ; bepinex_menu ;;            
            99) request99="y" ; set_world_server ; menu ;;
            0000) get_current_config_upgrade_menu ; menu ;;
            0) exit 0 ;;
            *)  echo -ne " $(ColorRed 'Wrong option.')" ; menu ;;
        esac
}

# ValheimPlus mods menu
function mods_menu(){
    echo ""
    menu_header_vplus_enable
    echo -ne "
$(ColorCyan '--------------'"$FUNCTION_VALHEIM_PLUS_MENU_HEADER"'--------------')
$(ColorCyan '-')$(ColorGreen ' 1)') $FUNCTION_VALHEIM_PLUS_MENU_INSTALL
$(ColorCyan '---------------'"$FUNCTION_VALHEIM_PLUS_MENU_ADMIN_HEADER"'--------------')
$(ColorCyan '-')$(ColorGreen ' 2)') $FUNCTION_VALHEIM_PLUS_MENU_ENABLE
$(ColorCyan '-')$(ColorGreen ' 3)') $FUNCTION_VALHEIM_PLUS_MENU_DISABLE
$(ColorCyan '-')$(ColorGreen ' 4)') $FUNCTION_VALHEIM_PLUS_MENU_START
$(ColorCyan '-')$(ColorGreen ' 5)') $FUNCTION_VALHEIM_PLUS_MENU_STOP
$(ColorCyan '-')$(ColorGreen ' 6)') $FUNCTION_VALHEIM_PLUS_MENU_RESTART
$(ColorCyan '-')$(ColorGreen ' 7)') $FUNCTION_VALHEIM_PLUS_MENU_STATUS
$(ColorCyan '-')$(ColorGreen ' 8)') $FUNCTION_VALHEIM_PLUS_MENU_UPDATE
$(ColorCyan '------'"$FUNCTION_VALHEIM_PLUS_MENU_MOD_PLUGIN_HEADER"'------')
$(ColorCyan ''"$FUNCTION_VALHEIM_PLUS_MENU_MOD_INFO"'')
$(ColorCyan ''"$FUNCTION_VALHEIM_PLUS_MENU_MOD_INFO_1"'')
$(ColorCyan ''"$FUNCTION_VALHEIM_PLUS_MENU_MOD_INFO_2"'')
$(ColorCyan ''"$FUNCTION_VALHEIM_PLUS_MENU_MOD_INFO_3"'')
$(ColorCyan ''"$FUNCTION_VALHEIM_PLUS_MENU_MOD_INFO_4"'')
$(ColorCyan '-')$(ColorGreen ' 9)') $FUNCTION_VALHEIM_PLUS_MENU_VPLUS_CONFIG_EDIT
$(ColorCyan '-')$(ColorGreen ' 10)') $FUNCTION_VALHEIM_PLUS_MENU_BEPINEX_CONFIG_EDIT
$(ColorCyan '------------------------------------------------')
$(ColorCyan '-')$(ColorGreen ' 0)') $FUNCTION_VALHEIM_PLUS_MENU_RETURN_MAIN
$(ColorPurple ''"$CHOOSE_MENU_OPTION"'')"
        read a
        case $a in
            1) install_valheim_plus ; mods_menu ;;
            2) valheim_plus_enable ; mods_menu ;;
            3) valheim_plus_disable ; mods_menu ;;
            4) start_valheim_server ; mods_menu ;;
            5) stop_valheim_server ; mods_menu ;;
            6) restart_valheim_server ; mods_menu ;;
            7) display_valheim_server_status ; mods_menu ;;
            8) valheim_plus_update ; mods_menu ;;
            9) valheimplus_mod_options ; mods_menu ;;
            10) bepinex_mod_options ; mods_menu ;;
               0) menu ; menu ;;
                *)  echo -ne " $(ColorRed ''"$WRONG_MENU_OPTION"'')" ; mods_menu ;;
        esac
}

# BepInEx mods menu
function bepinex_menu(){
    echo ""
    menu_header_bepinex_enable
    echo -ne "
$(ColorCyan '--------------'"$FUNCTION_BEPINEX_MENU_HEADER"'--------------')
$(ColorCyan '-')$(ColorGreen ' 1)') $FUNCTION_BEPINEX_MENU_INSTALL
$(ColorCyan '---------------'"$FUNCTION_BEPINEX_MENU_ADMIN_HEADER"'--------------')
$(ColorCyan '-')$(ColorGreen ' 2)') $FUNCTION_BEPINEX_MENU_ENABLE
$(ColorCyan '-')$(ColorGreen ' 3)') $FUNCTION_BEPINEX_MENU_DISABLE
$(ColorCyan '-')$(ColorGreen ' 4)') $FUNCTION_BEPINEX_MENU_START
$(ColorCyan '-')$(ColorGreen ' 5)') $FUNCTION_BEPINEX_MENU_STOP
$(ColorCyan '-')$(ColorGreen ' 6)') $FUNCTION_BEPINEX_MENU_RESTART
$(ColorCyan '-')$(ColorGreen ' 7)') $FUNCTION_BEPINEX_MENU_STATUS
$(ColorCyan '-')$(ColorGreen ' 8)') $FUNCTION_BEPINEX_MENU_UPDATE
$(ColorCyan '------'"$FUNCTION_BEPINEX_MENU_MOD_PLUGIN_HEADER"'------')
$(ColorCyan ''"$FUNCTION_BEPINEX_MENU_MOD_INFO"'')
$(ColorCyan ''"$FUNCTION_BEPINEX_MENU_MOD_INFO_1"'')
$(ColorCyan ''"$FUNCTION_BEPINEX_MENU_MOD_INFO_2"'')
$(ColorCyan ''"$FUNCTION_BEPINEX_MENU_MOD_INFO_3"'')
$(ColorCyan ''"$FUNCTION_BEPINEX_MENU_MOD_INFO_4"'')
$(ColorCyan '-')$(ColorGreen ' 9)') $FUNCTION_BEPINEX_MENU_BEPINEX_CONFIG_EDIT
$(ColorCyan '------------------------------------------------')
$(ColorCyan '-')$(ColorGreen ' 0)') $FUNCTION_BEPINEX_MENU_RETURN_MAIN
$(ColorPurple ''"$CHOOSE_MENU_OPTION"'')"
        read a
        case $a in
            1) install_valheim_bepinex ; bepinex_menu ;;
            2) valheim_bepinex_enable ; bepinex_menu ;;
            3) valheim_bepinex_disable ; bepinex_menu ;;
            4) start_valheim_server ; bepinex_menu ;;
            5) stop_valheim_server ; bepinex_menu ;;
            6) restart_valheim_server ; bepinex_menu ;;
            7) display_valheim_server_status ; bepinex_menu ;;
            8) valheim_bepinex_update ; bepinex_menu ;;
            9) bepinex_mod_options ; bepinex_menu ;;
               0) menu ; menu ;;
                *)  echo -ne " $(ColorRed ''"$WRONG_MENU_OPTION"'')" ; mods_menu ;;
        esac
}

########################################################################
################## Menu Helper Functions ###############################
########################################################################

# Helper function to check if mods are enabled
function are_mods_enabled() {
    local modstrue var2 var3
    modstrue=$(grep -F "ExecStart=${valheimInstallPath}/${worldname}/start" /lib/systemd/system/valheimserver_${worldname}.service)
    var2="ExecStart=${valheimInstallPath}/${worldname}/start_server_bepinex.sh"
    var3="ExecStart=${valheimInstallPath}/${worldname}/start_valw_bepinex.sh"

    if [[ $modstrue == *"$var2"* ]]; then
        echo "Enabled with ValheimPlus"
    elif [[ $modstrue == *"$var3"* ]]; then
        echo "Enabled with BepInEx"
    else
        echo "Disabled"
    fi
}

# Helper function to check server status
function server_status() {
    local server_status
    server_status=$(systemctl is-active valheimserver_${worldname}.service)
    echo -e '\E[32m'"$server_status"
}

# Helper function to get server substate
function server_substate() {
    local server_substate
    server_substate=$(systemctl show -p SubState valheimserver_${worldname}.service | cut -d'=' -f2)
    echo -e '\E[32m'"$server_substate"
}

# Helper function to check Valheim Plus repository version
function check_valheim_plus_repo() {
    latestValPlus=$(curl --connect-timeout 10 -s https://api.github.com/repos/Grantapher/ValheimPlus/releases/latest | grep -oP '"tag_name": "\K[^"]+')
    echo "$latestValPlus"
}

# Helper function to check local ValheimPlus version
function check_local_valheim_plus_build() {
    localValheimPlusVer=${valheimInstallPath}/${worldname}/localValheimPlusVersion
    if [[ -e $localValheimPlusVer ]] ; then
        localValheimPlusBuild=$(cat ${localValheimPlusVer})
        echo $localValheimPlusBuild
    else 
        echo "$NO_DATA";
    fi
}

# Helper function to check BepInEx repository version
function check_bepinex_repo() {
    latestBepinex=$(curl -s https://valheim.thunderstore.io/package/denikson/BepInExPack_Valheim/ | grep og:title | cut -d'"' -f 4 | cut -d' ' -f 3 | cut -d'v' -f2)
    echo $latestBepinex
}

# Helper function to check local BepInEx version
function check_local_bepinex_build() {
    localValheimBepinexVer=${valheimInstallPath}/${worldname}/localValheimBepinexVersion
    if [[ -e $localValheimBepinexVer ]] ; then
        localValheimBepinexBuild=$(cat ${localValheimBepinexVer})
        echo $localValheimBepinexBuild
    else 
        echo "$NO_DATA";
    fi
}

# Helper function to check menu script repository version
function check_menu_script_repo() {
    latestScript=$(curl --connect-timeout 10 -s https://api.github.com/repos/Nimdy/Dedicated_Valheim_Server_Script/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
    echo $latestScript
}

# Helper function to update menu script
function script_check_update() {
    # Look for updates from repo tag
    echo "1"

    git fetch

    # Check if there are updates available
    if [ -n "$(git diff --name-only "$UPSTREAM" "$SCRIPTFILE")" ]; then
        echo "$GIT_ECHO_CHECK"
        sleep 1
        git pull --force
        git stash
        git checkout "$BRANCH"
        git pull --force
        echo "$GIT_ECHO_UPDATING"
        sleep 1
        chmod +x *menu.sh
        sleep 1
        # Restart the script with the same arguments
        exec "$SCRIPTNAME" "${ARGS[@]}"
        # Exit the old instance
        exit 1
    else
        echo "$GIT_ECHO_NO_UPDATES"
    fi
}