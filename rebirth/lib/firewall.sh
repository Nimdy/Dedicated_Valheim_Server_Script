#!/bin/bash
###############################################################################################
###############################################################################################
####
#### File name: firewall.sh
####
###############################################################################################
#### Firewall configuration and management for Valheim server
#### Handles firewall rules for various firewall systems
###############################################################################################

########################################################################
############# Firewall control section START #####################
########################################################################

# Check if admin firewall is installed
function is_admin_firewall_installed() {
    if command -v "$fwbeingused" >/dev/null; then
        is_admin_firewall_installed=y
    else
        is_admin_firewall_installed=n
    fi
    echo -e '\E[32m'"$is_admin_firewall_installed"
}

# Check if any firewall is installed
function is_any_firewall_installed() {
    fwiufw=n
    fwifwd=n
    fwiipt=n
    fwiipt6=n
    fwiebt=n

    if command -v ufw >/dev/null; then
        fwiufw=y
        echo -ne "
$(ColorOrange "Uncomplicated Firewall (ufw) is installed.")"
    fi

    if command -v firewalld >/dev/null; then
        fwifwd=y
        echo -ne "
$(ColorOrange "FireWALLD is installed.")"
    fi

    if command -v iptables >/dev/null; then
        fwiipt=y
        echo -ne "
$(ColorOrange "IPTables is installed.")"
    fi

    if command -v ip6tables >/dev/null; then
        fwiipt6=y
        echo -ne "
$(ColorOrange "IP6Tables is installed.")"
    fi

    if command -v ebtables >/dev/null; then
        fwiebt=y
        echo -ne "
$(ColorOrange "EBTables is installed.")"
    fi

    if [[ "$fwiufw" == "y" || "$fwifwd" == "y" || "$fwiipt" == "y" || "$fwiipt6" == "y" || "$fwiebt" == "y" ]]; then
        is_any_firewall_installed=y
    else
        is_any_firewall_installed=n
    fi
    #echo -e '\E[32m'"$is_any_firewall_installed"
}

# Check if admin firewall is enabled
function is_admin_firewall_enabled(){
    if command -v ${fwbeingused} >/dev/null; then
        is_admin_firewall_enabled=$(systemctl is-enabled $fwbeingused)
    fi
    echo -e '\E[32m'"$is_admin_firewall_enabled "
}

# Check if any firewall is enabled
function is_any_firewall_enabled() {
    local fwearp=n fweebt=n fwefwd=n fweipt=n fweipt6=n fweufw=n

    if command -v arptables >/dev/null; then 
        systemctl is-enabled arptables >/dev/null 2>&1 && fwearp=y
    fi

    if command -v ebtables >/dev/null; then 
        systemctl is-enabled ebtables >/dev/null 2>&1 && fweebt=y
    fi

    if command -v firewalld >/dev/null; then
        systemctl is-enabled firewalld >/dev/null 2>&1 && fwefwd=y
    fi

    if command -v iptables >/dev/null; then 
        systemctl is-enabled iptables >/dev/null 2>&1 && fweipt=y
    fi

    if command -v ip6tables >/dev/null; then 
        systemctl is-enabled ip6tables >/dev/null 2>&1 && fweipt6=y
    fi

    if command -v ufw >/dev/null; then 
        systemctl is-enabled ufw >/dev/null 2>&1 && fweufw=y
    fi

    if [[ "$fwearp" == "y" || "$fweebt" == "y" || "$fwefwd" == "y" || "$fweipt" == "y" || "$fweipt6" == "y" || "$fweufw" == "y" ]]; then
        is_any_firewall_enabled="y"
    else
        is_any_firewall_enabled="n"
    fi

    # Testing for now...
    if [ "$is_any_firewall_enabled" == "y" ]; then 
        echo -ne "
$(ColorOrange "Firewall(s) Enabled: -- UFW: ${fweufw} -- Firewalld: ${fwefwd} -- Iptables: ${fweipt} -- Ip6tables: ${fweipt6} -- ARPTables: ${fwearp} -- EBTables: ${fweebt}")"
    else
        echo -ne "
$(ColorOrange "No Firewall enabled.")"
    fi
    # echo -e '\E[32m'"$is_any_firewall_enabled"
}

# Get firewall status
function get_firewall_status() {
    if [ "$usefw" == "y" ]; then
        is_admin_firewall_enabled

        if [ "$is_admin_firewall_enabled" == "enabled" ]; then
            get_firewall_status="NA"

            if command -v "$fwbeingused" >/dev/null; then
                get_firewall_status=$(systemctl is-active "$fwbeingused")
            else
                get_firewall_status="Error"
            fi
        else
            get_firewall_status="NotEnabled"
        fi
    else
        get_firewall_status="NoFWAdmin"
    fi
    echo -e '\E[32m'"$get_firewall_status"
}

# Get firewall substate
function get_firewall_substate(){
    if [ "${usefw}" == "y" ] ; then
        is_admin_firewall_enabled
        if [ "$is_admin_firewall_enabled" == "enabled" ] ; then
            get_firewall_substate="NA"
            #Is this better and does it work?
            if command -v $fwbeingused >/dev/null; then
                get_firewall_substate=$(systemctl show -p SubState ${fwbeingused})
            else
                get_firewall_substate="Error"
            fi
        else
            get_firewall_substate="NotEnabled"
        fi
    else
        get_firewall_substate="NoFWAdmin"
    fi
    echo -e '\E[32m'"$get_firewall_substate "
}

# Get detailed firewall information
function get_firewall_moreinfo(){
    if [ "${usefw}" == "y" ] ; then
        get_firewall_moreinfo="NA"
        
        if [ "${fwbeingused}" == "firewalld" ] ; then
            if command -v firewalld >/dev/null; then 
                firewall-cmd --state
                firewall-cmd --get-default-zone
                firewall-cmd --get-active-zones
                firewall-cmd --get-zones 
                firewall-cmd --get-services 
                firewall-cmd --zone=public --permanent --list-all
                get_firewall_moreinfo="Success"
            fi
        else
            get_firewall_moreinfo="Firewall config not complete."
        fi
    else
        get_firewall_moreinfo="Firewall Admin not enabled."
    fi
    echo -e '\E[32m'"$get_firewall_moreinfo "
}

# Check if port is added to firewall
function is_port_added_firewall() {
    is_port_added_firewall="n"
    ((currentPortPlus=$currentPort+2))
    
    if ! command -v ${fwbeingused} >/dev/null; then
        is_port_added_firewall="z"  # Command not found
        echo -e '\E[32m'"$is_port_added_firewall "
        return
    fi
    
    if [ "${fwbeingused}" == "firewalld" ]; then
        # Use grep directly instead of looping through an array
        portTestString="$currentPort-$currentPortPlus/udp"
        
        if sudo firewall-cmd --zone=public --permanent --list-ports | grep -q "$portTestString"; then
            is_port_added_firewall="y"  # Port found
        else
            is_port_added_firewall="n"  # Port not found
        fi
    else
        is_port_added_firewall="x"  # Unsupported firewall
    fi
    
    echo -e '\E[32m'"$is_port_added_firewall "
}

# Enable preferred firewall
function enable_prefered_firewall(){
    #Is this better and does it work?
    if command -v ${fwbeingused} >/dev/null; then
        sudo systemctl unmask ${fwbeingused} && systemctl enable ${fwbeingused} && systemctl start ${fwbeingused}    
        enable_prefered_firewall="Completed"
    else
        enable_prefered_firewall="Firewall Admin not enabled."
    fi
    echo -e '\E[32m'"$enable_prefered_firewall "    
}

# Disable all firewalls
function disable_all_firewalls(){
    #Is this better and does it work?
    for fws in ${fwsystems[@]}
    do
        echo "$fws is being stopped."
        if command -v $fws >/dev/null; then
            sudo systemctl stop $fws && systemctl disable $fws
            ## && systemctl mask $fws
        fi
    done 
    disable_all_firewalls="All known Firewall systems disabled."
    echo -e '\E[32m'"$disable_all_firewalls "
}

# Add Valheim server ports to firewall
function add_Valheim_server_public_ports(){
    if [ "${usefw}" == "y" ] ; then 
        if [ "${fwbeingused}" == "firewalld" ] ; then
            if [ "$sftc" == "ste" ] ; then
                sudo firewall-cmd --zone=public --permanent --add-port={1200/udp,27000-27015/udp,27020/udp,27015-27016/tcp,27030-27039/tcp}
            elif [ "$sftc" == "val" ] ; then   
                #sudo firewall-cmd --zone=public --permanent --add-port=${Vportnumber}-${Vportnumber+2}/udp
                sudo firewall-cmd --zone=public --permanent --add-port=${currentPort}-${currentPort+2}/udp
                
            else
                echo ""

            fi
            sudo firewall-cmd --reload
            sudo firewall-cmd --zone=public --permanent --list-ports
        fi    
    fi
}

# Remove Valheim server ports from firewall
function remove_Valheim_server_public_ports(){
    if [ "${usefw}" == "y" ] ; then 
        if [ "${fwbeingused}" == "firewalld" ] ; then
            if [ "$sftc" == "ste" ] ; then
                sudo firewall-cmd --zone=public --permanent --remove-port={1200/udp,27000-27015/udp,27020/udp,27015-27016/tcp,27030-27039/tcp}
            elif [ "$sftc" == "val" ] ; then 
                #Need to write a get_current_port function.
                #sudo firewall-cmd --zone=public --permanent --remove-port=${Vportnumber}-${Vportnumber+2}/udp
                sudo firewall-cmd --zone=public --permanent --remove-port=${currentPort}-${currentPort+2}/udp                
            else                
                echo ""
            fi
            sudo firewall-cmd --reload
            sudo firewall-cmd --zone=public --permanent --list-ports
        fi    
    fi
}

# Add to /etc/services file
function add_to_etc_services_file(){
    echo "idea only for now"
}

# Create firewalld service file
function create_firewalld_service_file(){
    if [ "${usefw}" == "y" ] ; then 
        if [ "${fwbeingused}" == "firewalld" ] ; then
            if [ "$sftc" == "ste" ] ; then
                checkfile=/usr/lib/firewalld/services/steam.xml
                if [ -f "$checkfile" ] ; then
                    echo "Steam<cmd> Firewalld service file already created."
                else
                    cat >> /usr/lib/firewalld/services/steam.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>Steam service</short>
  <description>These are the ports needed for Steam and Steamcmd</description>
  <port protocol="upd" port="1200"/>
  <port protocol="upd" port="27000-27015"/>
  <port protocol="upd" port="27020"/>
  <port protocol="tcp" port="27015-27016"/>
  <port protocol="tcp" port="27030-27039"/>
</service>
EOF
                fi
            elif [ "$sftc" == "val" ] ; then    
                checkfile=/usr/lib/firewalld/services/valheimserver-${worldname}.xml
                if [ -f "$checkfile" ] ; then
                    echo "Steam<cmd> Firewalld service file already created."
                else
                    cat >> /usr/lib/firewalld/services/valheimserver_${worldname}.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<service>
   <short>Valheim ${worldname} Server</short>
   <description>Valheim ${worldname} game server ports</description>
   <port protocol="upd" port="${currentPort}-${currentPort+2}"/>
 </service>
EOF
                fi
            else
                echo ""
            fi 
        fi
    fi
    sudo firewall-cmd --reload
    cat "$checkfile"
}

# Delete firewalld service file
function delete_firewalld_service_file(){
    if [ "${usefw}" == "y" ] ; then 
        if [ "${fwbeingused}" == "firewalld" ] ; then
            if [ "$sftc" == "ste" ] ; then
                checkfile=/usr/lib/firewalld/services/steam.xml
                if [ -f "$checkfile" ] ; then
                    rm /usr/lib/firewalld/services/steam.xml
                else
                    echo "File does not exist."
                fi
            elif [ "$sftc" == "val" ] ; then   
                checkfile=/usr/lib/firewalld/services/valheimserver-${worldname}.xml
                if [ -f "$checkfile" ] ; then
                    rm /usr/lib/firewalld/services/valheimserver-${worldname}.xml
                else
                    echo "File does not exist."
                fi
            else
                echo ""
            fi 
        fi
    fi
    sudo firewall-cmd --reload
    cat "$checkfile"
}

# Add firewalld public service
function add_firewalld_public_service(){
    if [ "${usefw}" == "y" ] ; then 
        if [ "${fwbeingused}" == "firewalld" ] ; then
            if [ "$sftc" == "ste" ] ; then
                sudo firewall-cmd --zone=public --permanent --add-service=steam
            elif [ "$sftc" == "val" ] ; then   
                sudo firewall-cmd --zone=public --permanent --add-service=valheim-${worldname}
            else
                echo ""
            fi
        fi    
    fi
    sudo firewall-cmd --reload
    sudo firewall-cmd --zone=public --permanent --list-services
}

# Remove firewalld public service
function remove_firewalld_public_service(){
    if [ "${usefw}" == "y" ] ; then 
        if [ "${fwbeingused}" == "f" ] ; then
            if [ "$sftc" == "ste" ] ; then
                sudo firewall-cmd --zone=public --permanent --remove-service=steam
            elif [ "$sftc" == "val" ] ; then 
                sudo firewall-cmd --zone=public --permanent --remove-service=valheim-${worldname}
            else
                echo ""
            fi
        fi    
    fi
    sudo firewall-cmd --reload
    sudo firewall-cmd --zone=public --permanent --list-services
}