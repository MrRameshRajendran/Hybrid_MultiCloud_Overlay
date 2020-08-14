# MultiCloud_Overlay

MutiCloud_Overlay demonstrates a use case of overlay over multi clouds such as AWS, Azure, GCP, OCI, Alibaba and a vSphere private infrastructure in a hub and spoke topology. Two or more clouds are sufficient to run the script. Overlay protocols IPv6 and IPv4 independent of underlying infrastructure. This project uses 
 

 ![sample LAN - watermark](https://user-images.githubusercontent.com/42124227/90287026-eea85700-de6e-11ea-8510-4aca7e13aa5c.jpg) 
#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sample Overlay deployment
&nbsp;  
&nbsp;  
&nbsp;  
    
![hub and spoke watermark](https://user-images.githubusercontent.com/42124227/90286728-59a55e00-de6e-11ea-9bee-2f15827c9a65.jpg)
#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Sample hub and spoke topology
&nbsp;  
&nbsp;  
&nbsp;    
Even if you don’t want to deploy overlay or Multi-Cloud, you should be able to use just subset of the scripts to create Jenkins multi parallel pipelines, configure security policies, build virtual machines and attach multi NIC cards in the major cloud environment.  
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

Jenkins Multi Parallel pipeline is implemented to accomplish the build, test and destroy stages. Below screenshots are showing the sample pipeline output.   

![Multi Pipeline watermark](https://user-images.githubusercontent.com/42124227/90286729-5ad68b00-de6e-11ea-8a7c-fe636030e455.jpg)
#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Jenkins - multi parallel pipeline
&nbsp;  
&nbsp;  
&nbsp;  
![Multi Pipeline - skip - watermark](https://user-images.githubusercontent.com/42124227/90286725-58743100-de6e-11ea-8796-a88652742fb9.jpg) 
#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Jenkins - multi parallel pipeline – Skipping stages
&nbsp;  
&nbsp;  
&nbsp;    
![Multi Pipeline - error - watermark](https://user-images.githubusercontent.com/42124227/90286730-5b6f2180-de6e-11ea-9c14-291b283ac62a.jpg)
#### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Jenkins - multi parallel pipeline – Failed stage
&nbsp;  
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
## *Environment variables:*
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
&nbsp;  
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
&nbsp;  
// Do not check secrets_file into github. You can use either the command "git update-index --skip-worktree secrets/aws_secrets.tfvars" or .gitignore file  
AWS_SECRETS_FILE=	"$HOME/scripts/L2_Overlay_Cloud_Dockers/secrets/aws_secrets.tfvars"  
TF_VAR_AWS_REGION=	"eu-west-2"  
TF_VAR_AWS_CIDR	=	"192.168.0.0/16"  
TF_VAR_AWS_FRONT_SUBNET	=	"192.168.0.0/24"  
TF_VAR_AWS_UNDERLAY_SUBNET=	"192.168.1.0/24"  
//Refer TF_VAR_L2_OVERLAY_NETWORK. This should be subset of it.  
AWS_OVERLAY_IP_RANGE	=	"192.168.2.32/28"  
	
	
// ******AZURE variables******
&nbsp;  
// Do not check secrets_file into github. You can use either the command "git update-index --skip-worktree secrets/azure_secrets.tfvars" or .gitignore file  
AZURE_SECRETS_FILE=	"$HOME/scripts/L2_Overlay_Cloud_Dockers/secrets/azure_secrets.tfvars"  
TF_VAR_AZURE_LOCATION	=	"westeurope"  
TF_VAR_AZURE_CIDR=	"192.168.0.0/16"  
TF_VAR_AZURE_FRONT_SUBNET=	"192.168.0.0/24"  
TF_VAR_AZURE_UNDERLAY_SUBNET	=	"192.168.1.0/24"  
//Refer TF_VAR_L2_OVERLAY_NETWORK. This should be subset of it.  
AZURE_OVERLAY_IP_RANGE	=	"192.168.2.48/28"  


// ******GCP variables******  
&nbsp;  
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
&nbsp;  
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
