#!/bin/bash
#This script updates ubuntu and installs required packages
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -qq update 
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -qq update --fix-missing
sudo DEBIAN_FRONTEND=noninteractive apt -y -qq -o Acquire::Check-Valid-Until=false update
sudo cat /etc/apt/sources.list
sleep 5
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -qq install software-properties-common
sudo add-apt-repository main
sudo add-apt-repository universe
sudo add-apt-repository restricted
sudo add-apt-repository multiverse
sudo cat /etc/apt/sources.list
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -qq install -f
sudo DEBIAN_FRONTEND=noninteractive apt install -y -qq net-tools
sudo DEBIAN_FRONTEND=noninteractive apt install -y -qq openvswitch-switch
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -qq install python
#Some ubuntu operating systems fail to install python due to repository issues
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -qq install python3
if [ -f /usr/bin/python3 ] && [ ! -f /usr/bin/python ]; then 
  ln --symbolic /usr/bin/python3 /usr/bin/python; 
fi
sudo DEBIAN_FRONTEND=noninteractive apt install -y -qq ansible	
sudo service openvswitch-switch start
sudo service ovs-vswitchd start
sudo apt-get remove -qy docker docker-engine docker.io
sudo apt install -qy docker.io
sudo apt install -qy iputils-ping
export DOCKER_CLI_EXPERIMENTAL=enabled
sudo systemctl enable docker
sudo systemctl start docker