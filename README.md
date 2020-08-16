# MultiCloud_Overlay

MutiCloud_Overlay demonstrates a use case of overlay over multi clouds such as AWS, Azure, GCP, OCI, Alibaba and a vSphere private infrastructure in Hub and spoke topology, point to point topology and in a Single cloud. Overlay protocols IPv6 and IPv4 independent of underlying infrastructure. This solution can be integrated with encryption and additional security features. 
 

 ![sample LAN - watermark](https://user-images.githubusercontent.com/42124227/90287026-eea85700-de6e-11ea-8510-4aca7e13aa5c.jpg) 
#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sample overlay deployment
&nbsp;  
&nbsp;  
&nbsp;  
    
![hub and spoke watermark](https://user-images.githubusercontent.com/42124227/90286728-59a55e00-de6e-11ea-9bee-2f15827c9a65.jpg)
#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sample hub and spoke topology
&nbsp;  
&nbsp;  
&nbsp;    
![point to point watermark](https://user-images.githubusercontent.com/42124227/90312396-1396db80-defc-11ea-9bd9-f2f9eff71be6.jpg)
#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sample point to point topology
&nbsp;  
&nbsp;  
&nbsp;  


I have named the virtual machine that establishes tunnel with other public clouds as a router and the virtual machine, from the same cloud, that establishes tunnel with the router as a Client. Traffic between two spoke sites always send via Router in Hub site. Router virtual machine hosts atleast three docker containers in each environment. All virtual machines and containers have dual stack configurations. Virtual machines are built using Ubuntu. All router virtual machines have two interfaces. Client virtual machine in public cloud has only one interface. One difference is that client virtual machine in VMware has two interfaces because I preferred to have dedicated management interface in private cloud. All public cloud virtual machines are managed over internet and private cloud virtual machines are managed within the environment over dedicated management interface. 
&nbsp;  
&nbsp;  
![Components - Cloud - watermark](https://user-images.githubusercontent.com/42124227/90312733-ba7c7700-defe-11ea-9342-a63939c3a683.jpg)
#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Components in a Cloud 
&nbsp;  
&nbsp;  
&nbsp;  
![Components - vSphere - watermark](https://user-images.githubusercontent.com/42124227/90312735-c10aee80-defe-11ea-8eb6-a6e61081f3c5.jpg)
#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Components in a vSphere infrastructure
&nbsp;  
&nbsp;  
&nbsp; 

Even if you don’t want to deploy overlay or Multi-Cloud, you should be able to use just subset of the scripts to create Jenkins multi parallel pipelines, configure security policies, build virtual machines and attach multi NIC cards in a cloud environment.  
This project utilizes below tools and scripts extensively.   

#### •	OVS – OpenvSwitch  
#### •	CI/CD – Jenkins   
#### •	Shell  
#### •	Ansible  
#### •	Terraform  
#### •	Packer  
#### •	Groovy  
#### •	Docker  
#### •	Ubuntu Virtual machines  
&nbsp;  
&nbsp;   

Jenkins Multi Parallel pipeline is implemented to accomplish the build, test and destroy stages. Below screenshots are showing the sample pipeline output.   

![Multi Pipeline watermark](https://user-images.githubusercontent.com/42124227/90286729-5ad68b00-de6e-11ea-8a7c-fe636030e455.jpg)
#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Jenkins - multi parallel pipeline
&nbsp;  
&nbsp;  
&nbsp;  
![Multi Pipeline with a Single Cloud](https://user-images.githubusercontent.com/42124227/90329954-0849bb80-dfa1-11ea-9019-fc54412fdb86.JPG)
#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Jenkins - multi parallel pipeline – single cloud
&nbsp;  
&nbsp;  
&nbsp;    
![Multi Pipeline - skip - watermark](https://user-images.githubusercontent.com/42124227/90286725-58743100-de6e-11ea-8796-a88652742fb9.jpg) 
#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Jenkins - multi parallel pipeline – skipping stages
&nbsp;  
&nbsp;  
&nbsp;    
![Multi Pipeline - error - watermark](https://user-images.githubusercontent.com/42124227/90286730-5b6f2180-de6e-11ea-9c14-291b283ac62a.jpg)
#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Jenkins - multi parallel pipeline – failed stage
&nbsp;  
&nbsp;  



You can find a brief description on the each stage below.
&nbsp;  
In the first stage, as name states, I am assigning values for the variables. If you want to assign values dynamically prior to creating resources, you can do in this stage.  
&nbsp;  
&nbsp;  
In the 2nd stage, Infrastructure change, terraform script is bringing up virtual machines in all environment. This stage also provisions the virtual machines with necessary packages.  
&nbsp;  
&nbsp;   
In the 3rd stage, “Containers & VMs config”, ansible scripts are bringing up containers in all router virtual machines. We are also gathering IP addresses to terminate tunnels in this stage.  
&nbsp;  
&nbsp;   
In the fourth stage, tunnel config, this is where all magic happens, connectivity is established based on the information prepared in the previous step. Ansible scripts are bringing up tunnels between hub and spoke sites over router virtual machines. Initially, I thought of writing the tunnel configurations in Python. However, I managed to accommodate within Groovy.      
&nbsp;  
&nbsp;   
In the final stage, testing, connectivity is tested from the client virtual machine located in hub site to the all containers and client virtual machines located in all spoke sites.  
&nbsp;  
&nbsp;  
Once the testing is completed, scripted stage “unconfig” will be called from the main script to destroy the all resources created in previous stages.  
&nbsp;  
&nbsp;  
All parameters required for the scripts are configured using environment variables. Below is the list of environment variables that can be configured before any running the scripts.  
&nbsp;  
&nbsp;  
&nbsp;  



## *Environment variables:*
```
//Please configure the below environment variables in either Jenkins GUI or here

//You can add/remove "cloud keywords" from below line. You need to specify atleast two cloud. 
CLOUD_LIST=	"aws_azure_gcp_ali_oracle_vsphere"  
//CLOUD_LIST	=	"oracle_ali"  

//You can make any cloud as hub in the hub & spoke topology.   
HUB=	"vsphere"  

//If you want to remove all resources post testing, Please set the below variable to "yes"  
REMOVE_CONFIG	=	"yes"	  
//Please note that all terraform state files are created in workspace directory.   
//If you intend to keep all resources, please take backup of tf state files before next build overwrites them.  

//TUNNEL_TYPE can be configured as geneve or vxlan;   
//Please note that only TCP/UDP/ICMP based ACLs are allowed in public clouds,and GRE is always blocked in certain clouds.   
TUNNEL_TYPE=	"geneve"  

//Disabling ansible ssh host key checking   
ANSIBLE_HOST_KEY_CHECKING=	"False"  

//Below subnet will be used as overlay subnet in all cloud. This will not be visible in underlying infrastructure.   
//This network will be further divided into multiple smaller subnets and assigned to each cloud.  
//TF_VAR_L2_OVERLAY_NETWORK includes the subnet and prefix length; TF_VAR_L2_OVERLAY_SUBNETMASK refers to the subnetmask  
//Containers & Client VM machines will use the addresses from this address space  
//This can be managed easily using IPAM driver, still an experimental/private feature under docker  
TF_VAR_L2_OVERLAY_NETWORK=	"192.168.2.0/24"  
TF_VAR_L2_OVERLAY_SUBNETMASK	=	"255.255.255.0"	  

//Some cloud environments require subnet mask instead of prefix length. Underlay subnets are defined further below.   
//This should match the underlay prefix length. For eg /24 should be 255.255.255.0  
//Automatic subnet calculation is for future improvements  
TF_VAR_UNDERLAY_SUBNETMASK=	"255.255.255.0"  

//Below variables cover the IPv6 network and subnet mask. They will be used in Overlay network  
TF_VAR_L2_OVERLAY_v6NETWORK=	"fc00::"  
TF_VAR_L2_OVERLAY_v6PREFIX_LEN	=	"64"  

//Below files will be used for authenticating VMs. SSH key will be uploaded onto virtual machines during the build process.  
TF_VAR_VM_SSH_KEY_FILE 	=	"$HOME/.ssh/ssh_key.pem"  
TF_VAR_VM_SSH_PUBLICKEY_FILE	=	"$HOME/.ssh/ssh_public_key"  
	
	
//Below username will be configured in all virtual machines. The password will be used expecially in vsphere VMs during initial setup   
//and then packer will change the SSH password authentication to SSH public key.   
TF_VAR_VM_USER	=	"ramesh"  
TF_VAR_VM_PASSWORD=	"ramesh"  
  
// *****VSPHERE variables*****  
//I used ESXi server without any VCENTER license. Hence, I couldn't clone any VM. I used packer(registered on) for creating VMs and ansible for destroying VMs   
// Do not check secrets_file into github. Use either "git update-index --skip-worktree secrets/vsphere_secrets.tfvars" or .gitignore  
VSPHERE_SECRETS_FILE	=	"$HOME/scripts/L2_Overlay_Cloud_Dockers/secrets/vsphere_secrets.tfvars"  

//You can define below usernames and passwords under Jenkins environment variables or here   
//TF_VAR_VSPHERE_USER	=	""  
//TF_VAR_VSPHERE_PASSWORD =	""  

TF_VAR_ESXI_HOST	 	=	"localhost.localdomain"  
TF_VAR_ESXI_DATASTORE	=	"data"  
TF_VAR_ESXI_DATACENTER	=	"ha-datacenter"  

//Reserved an IP for vsphere router using mac-address. Router always picks up same IP based on DHCP reservation and public IP is tied up with the private IP.  
TF_VAR_VSPHERE_ROUTER_PUBLIC_IP =	"77.102.63.40"  
TF_VAR_VSPHERE_ROUTER_FRONT_INTF_MAC	=	"a4:34:d9:12:cc:0d"  

//My laptop is connected to same private network as vpshere client. Hence, public management address is not required   
TF_VAR_VSPHERE_UNDERLAY_SUBNET	=	"192.168.1.0"  
TF_VAR_VSPHERE_CLIENT1_IP=	"192.168.1.15"  
TF_VAR_VSPHERE_ROUTER_BACKEND_IP=	"192.168.1.14"  

//ESXI Management port group can be specified below, Vsphere VMs requires two interfaces, management & backend.   
//Management interface will have access to the internet and tunnels will be created over this interface  
TF_VAR_ESXI_MGMT_PG=	"Management"  

//Using variables for the VMs' names in VSPHERE.  
TF_VAR_ESXI_ROUTER_NAME	=	"layer2-vsphere-router"  
TF_VAR_ESXI_CLIENT1_NAME=	"layer2-vsphere-client1"  

//Refer TF_VAR_L2_OVERLAY_NETWORK. This should be subset of it.  
VSPHERE_OVERLAY_IP_RANGE=	"192.168.2.16/28"	  
	
//Below images will be loaded onto Vsphere VMs, Get the checksum from the ubuntu website. Packer can automatically determine the checksum type from the checksum length  
//Don't forget to check the sources.list file located in vsphere/packer/. If you have a private ISO and your ISO doesn't have proper sources.list, populate your servers' list in sources.list  
TF_VAR_VSPHERE_UBUNTU_ISO_URLS	=	'''/var/cache/iso/ubuntu-18.04.4-server-amd64.iso'''  
//TF_VAR_VSPHERE_UBUNTU_ISO_URLS=	'''http://cdimage.ubuntu.com/releases/bionic/release/ubuntu-18.04.4-server-amd64.iso'''  
TF_VAR_VSPHERE_UBUNTU_ISO_CHECKSUM=	"e2ecdace33c939527cbc9e8d23576381c493b071107207d2040af72595f8990b"  
TF_VAR_VSPHERE_UBUNTU_ISO_CHECKSUM_TYPE	=	"sha256"  

  
// ******AWS variables******  
// Do not check secrets_file into github. You can use either the command "git update-index --skip-worktree secrets/aws_secrets.tfvars" or .gitignore file  
AWS_SECRETS_FILE=	"$HOME/scripts/L2_Overlay_Cloud_Dockers/secrets/aws_secrets.tfvars"  
TF_VAR_AWS_REGION=	"eu-west-2"  
TF_VAR_AWS_CIDR	=	"192.168.0.0/16"  
TF_VAR_AWS_FRONT_SUBNET	=	"192.168.0.0/24"  
TF_VAR_AWS_UNDERLAY_SUBNET=	"192.168.1.0/24"  
//Refer TF_VAR_L2_OVERLAY_NETWORK. This should be subset of it.  
AWS_OVERLAY_IP_RANGE	=	"192.168.2.32/28"  

// ******AZURE variables******  
// Do not check secrets_file into github. You can use either the command "git update-index --skip-worktree secrets/azure_secrets.tfvars" or .gitignore file  
AZURE_SECRETS_FILE=	"$HOME/scripts/L2_Overlay_Cloud_Dockers/secrets/azure_secrets.tfvars"  
TF_VAR_AZURE_LOCATION	=	"westeurope"  
TF_VAR_AZURE_CIDR=	"192.168.0.0/16"  
TF_VAR_AZURE_FRONT_SUBNET=	"192.168.0.0/24"  
TF_VAR_AZURE_UNDERLAY_SUBNET	=	"192.168.1.0/24"  
//Refer TF_VAR_L2_OVERLAY_NETWORK. This should be subset of it.  
AZURE_OVERLAY_IP_RANGE	=	"192.168.2.48/28"  

  
// ******GCP variables******  
// Do not check secrets_file into github. You can use either the command "git update-index --skip-worktree secrets/gcp_secrets.tfvars" or .gitignore file  
TF_VAR_GCP_KEY_FILE=	"$HOME/.ssh/gcp-key.json"  
TF_VAR_GCP_FRONT_SUBNET	=	"192.168.0.0/24"  
TF_VAR_GCP_PROJECT=	"round-vent-223215"  
TF_VAR_GCP_REGION=	"europe-west2"  
TF_VAR_GCP_ZONE	=	"europe-west2-a"  
TF_VAR_GCP_UNDERLAY_SUBNET=	"192.168.1.0/24"  	
//Refer TF_VAR_L2_OVERLAY_NETWORK. This should be subset of it.  
GCP_OVERLAY_IP_RANGE	=	"192.168.2.64/28"  


// ******OCI variables******  
// Do not check secrets_file into github. You can use either the command "git update-index --skip-worktree secrets/oci_secrets.tfvars" or .gitignore file  
OCI_SECRETS_FILE=	"$HOME/scripts/L2_Overlay_Cloud_Dockers/secrets/oci_secrets.tfvars"  
TF_VAR_OCI_REGION=	"uk-london-1"  
TF_VAR_OCI_CIDR	=	"192.168.0.0/16"  
TF_VAR_OCI_FRONT_SUBNET	=	"192.168.0.0/24"  
TF_VAR_OCI_UNDERLAY_SUBNET=	"192.168.1.0/24"	  
//Refer TF_VAR_L2_OVERLAY_NETWORK. This should be subset of it.  
OCI_OVERLAY_IP_RANGE	=	"192.168.2.80/28"  

  
// ******ALIBABA CLOUD variables******  
// Do not check secrets_file into github. You can use either the command "git update-index --skip-worktree secrets/aws_secrets.tfvars" or .gitignore file  
ALI_SECRETS_FILE=	"$HOME/scripts/L2_Overlay_Cloud_Dockers/secrets/ali_secrets.tfvars"  
TF_VAR_ALI_REGION=	"eu-west-1"  
TF_VAR_ALI_CIDR	=	"192.168.0.0/16"  
TF_VAR_ALI_FRONT_SUBNET	=	"192.168.0.0/24"  
TF_VAR_ALI_UNDERLAY_SUBNET=	"192.168.1.0/24"  
//Refer TF_VAR_L2_OVERLAY_NETWORK. This should be subset of it.  
ALI_OVERLAY_IP_RANGE	=	"192.168.2.96/28"  
```

## *Scripts without Jenkins:*  
It is possible to run terraform, ansible, packer and shell scripts on their own outside of Jenkins pipeline. I assumed that you will be using environment variables. However, if you prefer not to use environment variables, pass them as command line variables. All the relevant variables are documented above under “Environment variables” section. Below are list of examples.  
&nbsp;
&nbsp;

### *vSphere:*  
&nbsp;  
Below script creates logical switch and port-groups. This script also switches on the virtual machines.
&nbsp;  
```terraform apply -var-file=/home/jenkins/scripts/MultiCloud_Overlay/secrets/vsphere_secrets.tfvars -var CLIENT1_MGMT_IP=192.168.0.28 -var ROUTER_MGMT_IP=192.168.0.29 -auto-approve terraform/```

&nbsp;  
Below script builds virtual machines from ISO files in a vSphere environment.
&nbsp;  
```packer build -force vsphere/packer/ubuntu.json```


### *GCP:*  
&nbsp;  
Below script creates networks, security groups and virtual machines in GCP.
&nbsp;  
```terraform apply -auto-approve terraform/```  
### *OCI:*  
&nbsp;  
Below script creates networks, security groups and virtual machines in OCI.
&nbsp;  
```terraform apply -var-file=/home/jenkins/scripts/MultiCloud_Overlay/secrets/oci_secrets.tfvars -auto-approve terraform/```  
&nbsp;  
### *Alibaba:*  
&nbsp;  
Below script creates networks, security groups and virtual machines in Alibaba Cloud.
&nbsp;  
```terraform apply -var-file=/home/jenkins/scripts/MultiCloud_Overlay/secrets/ali_secrets.tfvars -auto-approve terraform/```

### *AWS:*  
&nbsp;  
Below script creates networks, security groups and virtual machines in AWS.
&nbsp;  
```terraform apply -var-file=/home/jenkins/scripts/MultiCloud_Overlay/secrets/aws_secrets.tfvars -auto-approve terraform/```

### *Azure:*  
&nbsp;  
Below script creates networks, security groups and virtual machines in Azure.  
```terraform apply -var-file=/home/jenkins/scripts/MultiCloud_Overlay/secrets/azure_secrets.tfvars -auto-approve terraform/```  

### *Common:*  
&nbsp;  
Below script creates docker containers. IPv4 and IPv6 addresses are picked up from global variables and command line arguments.  
```ansible-playbook /home/jenkins/workspace/MultiCloud_Overlay_master/common/Containers.yml -i 3.11.55.25, --extra-vars  ip_range=192.168.2.32/28 ipv6_index=2 file=aws_containers``` 

&nbsp;  
Below script removes known host from the ssh file. IPv4 and IPv6 addresses are configured on the bridge interface.  
```ansible-playbook /home/jenkins/workspace/MultiCloud_Overlay_master/common/VMs.yml -i 140.238.85.40, --extra-vars  ip_address=192.168.2.80 ipv6_index=26```

&nbsp;  
Below script configures a tunnel in a virtual machine.  
&nbsp;   
```ansible-playbook /home/jenkins/workspace/MultiCloud_Overlay_master/common/tunnelConfig.yml -i 13.81.202.147, --extra-vars  tunnel_id=0 remote_ip=192.168.1.5```

&nbsp;  
Below script runs a ping test. 
&nbsp;   
```ansible-playbook /home/jenkins/workspace/MultiCloud_Overlay_master/common/ping.yml -i 192.168.0.28, --extra-vars remote_client=192.168.2.81```



