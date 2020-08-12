#!/bin/bash
#This script configures metric on the 2nd NIC and enables DHCP
sudo echo $(ls -t  /sys/class/net/)
backend=$(sudo ip link | awk -F: '$0 !~ "ovs|br|docker|vxlan|lo|vir|wl|^[^0-9]"{print $2;getline}' | sed -n 2p)
sudo echo $backend
sudo ifconfig $backend up
sudo dhclient -e IF_METRIC=200 $backend 
