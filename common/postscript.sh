#!/bin/bash
# This file is no longer used. Groovy scripts/stages can be replaced with this script when Jenkins stages need to be removed	
hub_public_ip=$1
spoke_public_ips=$2
hub_flag=$3
TUNNEL_TYPE=$4

v_hostname=$(sudo hostname)
echo $v_hostname
if [[ $v_hostname == *router* ]]
then
	v_interface=$(sudo route | grep default | sed -n '1p' | awk '{print $NF}')	
	echo $v_interface
	sudo ovs-vsctl add-br l2-br
	sudo ovs-vsctl add-br gateway-br
	sudo ifconfig l2-br up
	sudo ifconfig gateway-br up	
# Adding default interface into gateway bridge and other interfaces into backend bridge	
	for intf in /sys/class/net/*; do
		echo $intf
		if [[ $intf == *$v_interface* ]]
		then
			echo $v_interface
			sudo dhclient -r $v_interface
			sudo ifconfig $v_interface down			
			sudo ovs-vsctl add-port gateway-br $v_interface
			sudo ifconfig $v_interface up
			sudo dhclient gateway-br
		elif [[ `basename $intf` != *lo* ]] && [[ `basename $intf` != *ovs* ]] && [[ `basename $intf` != *br* ]]
		then
			sudo ovs-vsctl add-port l2-br `basename $intf`
			sudo ifconfig `basename $intf` up
		fi
	done
	tunnel_id=0
# Configuring tunnels in hub and spoke routers	
	if [[ $hub_flag == 0 ]]
	then
		for spoke in $(echo $spoke_public_ips | sed "s/,/ /g"); do  
			sudo ovs-vsctl add-port l2-br $tunnel_id -- set interface $tunnel_id type=$TUNNEL_TYPE options:remote_ip=$spoke
#			tunnel_id can be used for creating multiple tunnels
# 			((tunnel_id++))
		done
	else
		sudo ovs-vsctl add-port l2-br $tunnel_id -- set interface $tunnel_id type=$TUNNEL_TYPE options:remote_ip=$hub_public_ip
	fi
fi