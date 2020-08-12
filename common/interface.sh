#!/bin/bash
#This script configures static ip address on the 2nd NIC
ip=$1
subnetmask=$2
sudo echo $(ls -t  /sys/class/net/)
backend=$(sudo ip link | awk -F: '$0 !~ "ovs|br|docker|vxlan|lo|vir|wl|^[^0-9]"{print $2;getline}' | sed -n 2p)
sudo echo $backend
sudo ifconfig $backend $ip netmask $subnetmask
sudo ifconfig $backend up
