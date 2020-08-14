//You have to set the values for environment variables inside the environment block
clients = []
cloudVariable = [:]
active_cloud_list = ""
result = "PASS"
no_of_clouds = 0
ipv6_index = 2 
def hub_public_ip = ""
def spoke_public_ips = ""
def test_client = ""

pipeline {
	agent any
	environment { 
		//Please configure the below environment variables in either Jenkins GUI or here

		//You can add/remove "cloud keywords" from below line. You need to specify atleast two cloud. 
		CLOUD_LIST								=	"aws_azure_gcp_ali_oracle_vsphere"
		//CLOUD_LIST							=	"oracle_ali"
		
		//You can make any cloud as hub in the hub & spoke topology. 		
		HUB										=	"vsphere"

		//If you want to remove all resources post testing, Please set the below variable to "yes"
		REMOVE_CONFIG							=	"yes"	
		//Please note that all terraform state files are created in workspace directory. 
		//If you intend to keep all resources, please take backup of tf state files before next build overwrites them.
		
		//TUNNEL_TYPE can be configured as geneve or vxlan; 
		//Please note that only TCP/UDP/ICMP based ACLs are allowed in public clouds,and GRE is always blocked in certain clouds. 
		TUNNEL_TYPE								=	"geneve"
		
		//Disabling ansible ssh host key checking 
		ANSIBLE_HOST_KEY_CHECKING				=	"False"
		
		//Below subnet will be used as overlay subnet in all cloud. This will not be visible in underlying infrastructure. 
		//This network will be further divided into multiple smaller subnets and assigned to each cloud.
		//TF_VAR_L2_OVERLAY_NETWORK includes the subnet and prefix length; TF_VAR_L2_OVERLAY_SUBNETMASK refers to the subnetmask
		//Containers & Client VM machines will use the addresses from this address space
		//This can be managed easily using IPAM driver, still an experimental/private feature under docker
		TF_VAR_L2_OVERLAY_NETWORK				=	"192.168.2.0/24"
		TF_VAR_L2_OVERLAY_SUBNETMASK			=	"255.255.255.0"	
		
		//Some cloud environments require subnet mask instead of prefix length. Underlay subnets are defined further below. 
		//This should match the underlay prefix length. For eg /24 should be 255.255.255.0
		//Automatic subnet calculation is for future improvements
		TF_VAR_UNDERLAY_SUBNETMASK				=	"255.255.255.0"				

		//Below variables cover the IPv6 network and subnet mask. They will be used in Overlay network
		TF_VAR_L2_OVERLAY_v6NETWORK				=	"fc00::"
		TF_VAR_L2_OVERLAY_v6PREFIX_LEN			=	"64"
				
		//Below files will be used for authenticating VMs. SSH key will be uploaded onto virtual machines during the build process.
		TF_VAR_VM_SSH_KEY_FILE 					=	"$HOME/.ssh/ssh_key.pem"
		TF_VAR_VM_SSH_PUBLICKEY_FILE			=	"$HOME/.ssh/ssh_public_key"
	
	
		//Below username will be configured in all virtual machines. The password will be used expecially in vsphere VMs during initial setup 
		//and then packer will change the SSH password authentication to SSH public key. 
		TF_VAR_VM_USER							=	"ramesh"
		TF_VAR_VM_PASSWORD						=	"ramesh"

		// ******VSPHERE variables******	
		//I used ESXi server without any VCENTER license. Hence, I couldn't clone any VM. I used packer(registered on) for creating VMs and ansible for destroying VMs 
		// Do not check secrets_file into github. Use either "git update-index --skip-worktree secrets/vsphere_secrets.tfvars" or .gitignore
		VSPHERE_SECRETS_FILE					=	"$HOME/scripts/L2_Overlay_Cloud_Dockers/secrets/vsphere_secrets.tfvars"
		
		//You can define below usernames and passwords under Jenkins environment variables or here 
		//TF_VAR_VSPHERE_USER					=	""
		//TF_VAR_VSPHERE_PASSWORD 				=	""
		
		TF_VAR_ESXI_HOST	 					=	"localhost.localdomain"
		TF_VAR_ESXI_DATASTORE					=	"data"
		TF_VAR_ESXI_DATACENTER					=	"ha-datacenter"		
		
		//Reserved an IP for vsphere router using mac-address. Router always picks up same IP based on DHCP reservation and public IP is tied up with the private IP.
		TF_VAR_VSPHERE_ROUTER_PUBLIC_IP 		=	"77.102.63.40"
		TF_VAR_VSPHERE_ROUTER_FRONT_INTF_MAC	=	"a4:34:d9:12:cc:0d"
		
		//My laptop is connected to same private network as vpshere client. Hence, public management address is not required 
		TF_VAR_VSPHERE_UNDERLAY_SUBNET			=	"192.168.1.0"
		TF_VAR_VSPHERE_CLIENT1_IP				=	"192.168.1.15"
		TF_VAR_VSPHERE_ROUTER_BACKEND_IP		=	"192.168.1.14"

		//ESXI Management port group can be specified below, Vsphere VMs requires two interfaces, management & backend. 
		//Management interface will have access to the internet and tunnels will be created over this interface
		TF_VAR_ESXI_MGMT_PG						=	"Management"
		
		//Using variables for the VMs' names in VSPHERE.
		TF_VAR_ESXI_ROUTER_NAME					=	"layer2-vsphere-router"
		TF_VAR_ESXI_CLIENT1_NAME				=	"layer2-vsphere-client1"
		
		//Refer TF_VAR_L2_OVERLAY_NETWORK. This should be subset of it.
		VSPHERE_OVERLAY_IP_RANGE				=	"192.168.2.16/28"	
			
		//Below images will be loaded onto Vsphere VMs, Get the checksum from the ubuntu website. Packer can automatically determine the checksum type from the checksum length
		//Don't forget to check the sources.list file located in vsphere/packer/. If you have a private ISO and your ISO doesn't have proper sources.list, populate your servers' list in sources.list
		TF_VAR_VSPHERE_UBUNTU_ISO_URLS			=	'''/var/cache/iso/ubuntu-18.04.4-server-amd64.iso'''
		//TF_VAR_VSPHERE_UBUNTU_ISO_URLS		=	'''http://cdimage.ubuntu.com/releases/bionic/release/ubuntu-18.04.4-server-amd64.iso'''
		TF_VAR_VSPHERE_UBUNTU_ISO_CHECKSUM		=	"e2ecdace33c939527cbc9e8d23576381c493b071107207d2040af72595f8990b"
		TF_VAR_VSPHERE_UBUNTU_ISO_CHECKSUM_TYPE	=	"sha256"


		// ******AWS variables******	
		// Do not check secrets_file into github. You can use either the command "git update-index --skip-worktree secrets/aws_secrets.tfvars" or .gitignore file
		AWS_SECRETS_FILE						=	"$HOME/scripts/L2_Overlay_Cloud_Dockers/secrets/aws_secrets.tfvars"
		TF_VAR_AWS_REGION						=	"eu-west-2"
		TF_VAR_AWS_CIDR							=	"192.168.0.0/16"
		TF_VAR_AWS_FRONT_SUBNET					=	"192.168.0.0/24"
		TF_VAR_AWS_UNDERLAY_SUBNET				=	"192.168.1.0/24"		
		//Refer TF_VAR_L2_OVERLAY_NETWORK. This should be subset of it.
		AWS_OVERLAY_IP_RANGE					=	"192.168.2.32/28"
			
					
		// ******AZURE variables******
		// Do not check secrets_file into github. You can use either the command "git update-index --skip-worktree secrets/azure_secrets.tfvars" or .gitignore file
		AZURE_SECRETS_FILE						=	"$HOME/scripts/L2_Overlay_Cloud_Dockers/secrets/azure_secrets.tfvars"		
		TF_VAR_AZURE_LOCATION					=	"westeurope"
		TF_VAR_AZURE_CIDR						=	"192.168.0.0/16"
		TF_VAR_AZURE_FRONT_SUBNET				=	"192.168.0.0/24"
		TF_VAR_AZURE_UNDERLAY_SUBNET			=	"192.168.1.0/24"		
		//Refer TF_VAR_L2_OVERLAY_NETWORK. This should be subset of it.
		AZURE_OVERLAY_IP_RANGE					=	"192.168.2.48/28"


		// ******GCP variables******
		// Do not check secrets_file into github. You can use either the command "git update-index --skip-worktree secrets/gcp_secrets.tfvars" or .gitignore file
		TF_VAR_GCP_KEY_FILE						=	"$HOME/.ssh/gcp-key.json"
		TF_VAR_GCP_FRONT_SUBNET					=	"192.168.0.0/24"
		TF_VAR_GCP_PROJECT						=	"round-vent-223215"
		TF_VAR_GCP_REGION						=	"europe-west2"
		TF_VAR_GCP_ZONE							=	"europe-west2-a"
		TF_VAR_GCP_UNDERLAY_SUBNET				=	"192.168.1.0/24"	
		//Refer TF_VAR_L2_OVERLAY_NETWORK. This should be subset of it.		
		GCP_OVERLAY_IP_RANGE					=	"192.168.2.64/28"			
		
		
		// ******OCI variables******
		// Do not check secrets_file into github. You can use either the command "git update-index --skip-worktree secrets/oci_secrets.tfvars" or .gitignore file
		OCI_SECRETS_FILE						=	"$HOME/scripts/L2_Overlay_Cloud_Dockers/secrets/oci_secrets.tfvars"
		TF_VAR_OCI_REGION						=	"uk-london-1"
		TF_VAR_OCI_CIDR							=	"192.168.0.0/16"
		TF_VAR_OCI_FRONT_SUBNET					=	"192.168.0.0/24"
		TF_VAR_OCI_UNDERLAY_SUBNET				=	"192.168.1.0/24"	
		//Refer TF_VAR_L2_OVERLAY_NETWORK. This should be subset of it.
		OCI_OVERLAY_IP_RANGE					=	"192.168.2.80/28"	

		
		// ******ALIBABA CLOUD variables******	
		// Do not check secrets_file into github. You can use either the command "git update-index --skip-worktree secrets/aws_secrets.tfvars" or .gitignore file
		ALI_SECRETS_FILE						=	"$HOME/scripts/L2_Overlay_Cloud_Dockers/secrets/ali_secrets.tfvars"
		TF_VAR_ALI_REGION						=	"eu-west-1"
		TF_VAR_ALI_CIDR							=	"192.168.0.0/16"
		TF_VAR_ALI_FRONT_SUBNET					=	"192.168.0.0/24"
		TF_VAR_ALI_UNDERLAY_SUBNET				=	"192.168.1.0/24"		
		//Refer TF_VAR_L2_OVERLAY_NETWORK. This should be subset of it.
		ALI_OVERLAY_IP_RANGE					=	"192.168.2.96/28"		
		
	}
	stages {
		stage('Initializing variables') {
			steps {
				script {
					workspace			=	sh (script: 'pwd', returnStdout: true).trim()
					//sh "export TF_LOG=TRACE"
					//active_cloud_list variable helps to remove failed cloud environment from the setup
					active_cloud_list = CLOUD_LIST
				}
			}
		}
		stage('Infrastructure changes') {
			when {
				branch 'master'
			}
			failFast true	
			//Preferred to use parallel pipeline to build the virtual machines across all environment at the same time 	
			parallel {	
				stage('VSphere') {
					when {
						expression { 
							env.CLOUD_LIST.contains("vsphere")
						}
					}
					steps {		
						script {
							try {
								//Adding username and password into preseed file as it is difficult to send as variable					
								sh "sed -i 's/ramesh/${env.TF_VAR_VM_USER}/g' vsphere/packer/ubuntu.cfg"
								sh "sed -i 's/mypass/${env.TF_VAR_VM_PASSWORD}/g' vsphere/packer/ubuntu.cfg"
								
								echo "Calling packer to build VMs in VSphere"
								//I am using standalone ESXI(without vcenter). Finished files will be copied directly from workspace environment to ESXI server
								sh "packer build -force vsphere/packer/ubuntu.json"			 							
			
								//My Jenkins server and Automation/Management servers are connected to vsphere environment over management networks		
		 						vsphere_client1_mgmt_ip	=	sh (script: "cat ${TF_VAR_ESXI_CLIENT1_NAME}.txt", returnStdout: true).trim()
		 						echo "vsphere_client1_mgmt_ip ${vsphere_client1_mgmt_ip}"
		 						vsphere_router_mgmt_ip	=	sh (script: "cat ${TF_VAR_ESXI_ROUTER_NAME}.txt", returnStdout: true).trim()
		 						echo "vsphere_router_mgmt_ip ${vsphere_router_mgmt_ip}"
		
		
		 						echo "Calling terraform to build Infra in VSphere"
			 					sh "cd vsphere;terraform init terraform/;cd -"
			 					sh "cd vsphere;terraform apply -var-file=$VSPHERE_SECRETS_FILE -var CLIENT1_MGMT_IP=$vsphere_client1_mgmt_ip  -var ROUTER_MGMT_IP=$vsphere_router_mgmt_ip -auto-approve terraform/;cd -"
		
			 					//If you are using SDN/cloud and dynamic public IP allocations, you can get public IP from API instead of static allocations
			 					//def VSPHERE_ROUTER_PUBLIC_IP = sh(script:'terraform apply -auto-approve /home/jenkins/scripts/Layer2Project/vsphere/terraform/', returnStdout:true).trim()
			 					//sh """set VSPHERE_ROUTER_PUBLIC_IP = ${env.VSPHERE_ROUTER_PUBLIC_IP}"""	
			 					
		 						cloudVariable.vsphere	=	[router_backend_ip: "$TF_VAR_VSPHERE_ROUTER_BACKEND_IP", client1_ip: "$TF_VAR_VSPHERE_CLIENT1_IP",
		 													router_mgmt_ip: "$vsphere_router_mgmt_ip", client1_mgmt_ip: "$vsphere_client1_mgmt_ip",
		 													overlay_ip_range: "$VSPHERE_OVERLAY_IP_RANGE", tunnel_source_ip: "$TF_VAR_VSPHERE_ROUTER_PUBLIC_IP"]
			 					echo "$cloudVariable.vsphere"	
							} catch (exc) {
								echo "Caught: " + exc.toString()
								unstable("${STAGE_NAME} failed!")
								active_cloud_list = active_cloud_list.replaceAll("vsphere","").replaceAll("__","_").replaceAll("(_+\$)|(^_+)","")
							}	
						}	
					}		
				}		
				stage('aws') {
					when {
						expression { 
							env.CLOUD_LIST.contains("aws")
						}
					}					
					steps {
						script {
							try {
								echo "Calling terraform to build Infra in aws"									
								sh "cd aws;terraform init terraform/;cd -"
								sh "cd aws;terraform apply -var-file=$AWS_SECRETS_FILE -auto-approve terraform/;cd -"

								aws_router_backend_ip	=	sh (script: "terraform output -state aws/terraform.tfstate router_backend_ip", returnStdout: true).trim()	
		 						aws_client1_ip			=	sh (script: "terraform output -state aws/terraform.tfstate client1_ip", returnStdout: true).trim()				 					
								aws_client1_public_ip	=	sh (script: "terraform output -state aws/terraform.tfstate client1_public_ip", returnStdout: true).trim()	
								aws_router_public_ip	=	sh (script: "terraform output -state aws/terraform.tfstate router_public_ip", returnStdout: true).trim()	
								
								cloudVariable.aws		=	[router_backend_ip: "$aws_router_backend_ip", client1_ip: "$aws_client1_ip",
															router_mgmt_ip: "$aws_router_public_ip", client1_mgmt_ip: "$aws_client1_public_ip",
															overlay_ip_range: "$AWS_OVERLAY_IP_RANGE", tunnel_source_ip: "$aws_router_public_ip"]
								echo "$cloudVariable.aws"			
							} catch (exc) {
								echo "Caught: " + exc.toString()
								unstable("${STAGE_NAME} failed!")
								active_cloud_list = active_cloud_list.replaceAll("aws","").replaceAll("__","_").replaceAll("(_+\$)|(^_+)","")								
							}		
						}
					}
				}
				stage('azure') {
					when {
						expression { 
							env.CLOUD_LIST.contains("azure")
						}
					}					
					steps {
						script {
							try {
								echo "Calling terraform to build Infra in azure"	
			 					sh "cd azure;terraform init terraform/;cd -"
			 					//Public IPs are not assigned to output variables during first run. Hence, I am refreshing terraform to get the public IPs
			 					sh "cd azure;terraform apply -var-file=$AZURE_SECRETS_FILE -auto-approve terraform/;terraform refresh -var-file=$AZURE_SECRETS_FILE terraform/;cd -"

								azure_router_backend_ip	=	sh (script: "terraform output -state azure/terraform.tfstate router_backend_ip", returnStdout: true).trim()	
		 						azure_client1_ip			=	sh (script: "terraform output -state azure/terraform.tfstate client1_ip", returnStdout: true).trim()				 					
			 					azure_client1_public_ip		=	sh (script: "terraform output -state azure/terraform.tfstate client1_public_ip", returnStdout: true).trim()	
			 					azure_router_public_ip		=	sh (script: "terraform output -state azure/terraform.tfstate router_public_ip", returnStdout: true).trim()	
			 					
							
								cloudVariable.azure		=	[router_backend_ip: "$azure_router_backend_ip", client1_ip: "$azure_client1_ip",
															router_mgmt_ip: "$azure_router_public_ip", client1_mgmt_ip: "$azure_client1_public_ip",
															overlay_ip_range: "$AZURE_OVERLAY_IP_RANGE", tunnel_source_ip: "$azure_router_public_ip"]
												
			 					echo "$cloudVariable.azure" 												
							} catch (exc) {
								echo "Caught: " + exc.toString()
								unstable("${STAGE_NAME} failed!")
								active_cloud_list = active_cloud_list.replaceAll("azure","").replaceAll("__","_").replaceAll("(_+\$)|(^_+)","")
							}	
						}
					}
				}
				stage('gcp') {
					when {
						expression { 
							env.CLOUD_LIST.contains("gcp")
						}
					}					
					steps {
						script {
							try {
								echo "Calling terraform to build Infra in gcp"	
			 					sh "cd gcp;terraform init terraform/;cd -"
			 					sh "cd gcp;terraform apply -auto-approve terraform/;cd -"

								gcp_router_backend_ip	=	sh (script: "terraform output -state gcp/terraform.tfstate router_backend_ip", returnStdout: true).trim()	
		 						gcp_client1_ip			=	sh (script: "terraform output -state gcp/terraform.tfstate client1_ip", returnStdout: true).trim()				 					
			 					gcp_client1_public_ip	=	sh (script: "terraform output -state gcp/terraform.tfstate client1_public_ip", returnStdout: true).trim()	
			 					gcp_router_public_ip		=	sh (script: "terraform output -state gcp/terraform.tfstate router_public_ip", returnStdout: true).trim()	
			 					
								cloudVariable.gcp		=	[router_backend_ip: "$gcp_router_backend_ip", client1_ip: "$gcp_client1_ip",
															router_mgmt_ip: "$gcp_router_public_ip", client1_mgmt_ip: "$gcp_client1_public_ip",
															overlay_ip_range: "$GCP_OVERLAY_IP_RANGE", tunnel_source_ip: "$gcp_router_public_ip"]
												
								echo "$cloudVariable.gcp"				 														 												
							} catch (exc) {
								echo "Caught: " + exc.toString()
								unstable("${STAGE_NAME} failed!")
								active_cloud_list = active_cloud_list.replaceAll("gcp","").replaceAll("__","_").replaceAll("(_+\$)|(^_+)","")
							}
						}
					}
				}
				stage('oracle') {
					when {
						expression { 
							env.CLOUD_LIST.contains("oracle")
						}
					}					
					steps {
						script {
							try {
								echo "Calling terraform to build Infra in oracle cloud"									
		 						sh "cd oracle;terraform init terraform/;cd -"
			 					sh "cd oracle;terraform apply -var-file=$OCI_SECRETS_FILE -auto-approve terraform/;cd -"

								oracle_router_backend_ip	=	sh (script: "terraform output -state oracle/terraform.tfstate router_backend_ip", returnStdout: true).trim()	
		 						oracle_client1_ip			=	sh (script: "terraform output -state oracle/terraform.tfstate client1_ip", returnStdout: true).trim()	
			 					oracle_client1_public_ip	=	sh (script: "terraform output -state oracle/terraform.tfstate client1_public_ip", returnStdout: true).trim()	
			 					oracle_router_public_ip		=	sh (script: "terraform output -state oracle/terraform.tfstate router_public_ip", returnStdout: true).trim()	
		 						
		 						cloudVariable.oracle		=	[router_backend_ip: "$oracle_router_backend_ip", client1_ip: "$oracle_client1_ip",
		 														router_mgmt_ip: "$oracle_router_public_ip", client1_mgmt_ip: "$oracle_client1_public_ip",
		 														overlay_ip_range: "$OCI_OVERLAY_IP_RANGE", tunnel_source_ip: "$oracle_router_public_ip"]
							
								echo "$cloudVariable.oracle"
							} catch (exc) {
								echo "Caught: " + exc.toString()
								unstable("${STAGE_NAME} failed!")
								active_cloud_list = active_cloud_list.replaceAll("oracle","").replaceAll("__","_").replaceAll("(_+\$)|(^_+)","")
							}			
						}
					}
				}
				stage('ali') {
					when {
						expression { 
							env.CLOUD_LIST.contains("ali")
						}
					}					
					steps {
						script {
							try {
							if(env.CLOUD_LIST.contains("ali")) { 	
									echo "Calling terraform to build Infra in alibaba cloud"
									sh "cd ali;terraform init terraform/ || true;cd -"
									sh "cd ali;terraform apply -var-file=$ALI_SECRETS_FILE -auto-approve terraform/;cd -"

									ali_router_backend_ip	=	sh (script: "terraform output -state ali/terraform.tfstate router_backend_ip", returnStdout: true).trim()	
			 						ali_client1_ip			=	sh (script: "terraform output -state ali/terraform.tfstate client1_ip", returnStdout: true).trim()										
									ali_client1_public_ip	=	sh (script: "terraform output -state ali/terraform.tfstate client1_public_ip", returnStdout: true).trim()	
									ali_router_public_ip	=	sh (script: "terraform output -state ali/terraform.tfstate router_public_ip", returnStdout: true).trim()	
									
									cloudVariable.ali	=	[router_backend_ip: "$ali_router_backend_ip", client1_ip: "$ali_client1_ip",
															router_mgmt_ip: "$ali_router_public_ip", client1_mgmt_ip: "$ali_client1_public_ip",
															overlay_ip_range: "$ALI_OVERLAY_IP_RANGE", tunnel_source_ip: "$ali_router_public_ip"]
									
									echo "$cloudVariable.ali"							
								} else {
									echo "Skipping config in alibaba cloud"
								}
							} catch (exc) {
								echo "Caught: " + exc.toString()
								unstable("${STAGE_NAME} failed!")
								active_cloud_list = active_cloud_list.replaceAll("ali","").replaceAll("__","_").replaceAll("(_+\$)|(^_+)","")
							}			
						}
					}
				}								
			}
		}		
		stage('Containers & VMs config') {
			steps {	
				script {
					def containers_vm_config_list = [:]
					active_cloud_list.split('_').each {
						containers_vm_config_list["${it}"] = {
							node ('master') {
								stage("${it}") {			
									try {
										Containers_VMs_config("${it}")		
									} catch (exc) {
										echo "Caught: " + exc.toString()
										unstable("${STAGE_NAME} failed!")
										currentBuild.currentResult = 'FAILURE'
										active_cloud_list = active_cloud_list.replaceAll("${it}","").replaceAll("__","_").replaceAll("(_+\$)|(^_+)","")										
									}
								}	
							}
						}				
					}		
					parallel containers_vm_config_list
				}
			}					
		}	
		//Prereq to this stage: There shouldn't be any error in your Hub build			
		stage('Tunnel config') {
			steps {	
				script {
					def tunnel_config_list = [:]
					tunnel_number	=	1
					no_of_clouds	=	active_cloud_list.count("_") + 1
					active_cloud_list.split('_').each {
						tunnel_config_list["${it}"] = {
							node ('master') {
								stage("${it}") {			
									try {
										echo " ${cloudVariable."$it".router_mgmt_ip}"
										sh "ansible-playbook ${workspace}/common/tunnelConfig.yml -i  ${cloudVariable."$it".client1_mgmt_ip}, \
										--extra-vars \" tunnel_id=0 remote_ip=${cloudVariable."$it".router_backend_ip} \" "	
												
										sh "ansible-playbook ${workspace}/common/tunnelConfig.yml -i  ${cloudVariable."$it".router_mgmt_ip}, \
										--extra-vars \" tunnel_id=0 remote_ip=${cloudVariable."$it".client1_ip} \" "
											
										if(!HUB.contains("$it") && no_of_clouds > 1) {	
											sh "ansible-playbook ${workspace}/common/tunnelConfig.yml -i  ${cloudVariable."$it".router_mgmt_ip}, \
											--extra-vars \" tunnel_id=1 remote_ip=${cloudVariable."$HUB".tunnel_source_ip} \" "										
											lock("Hub tunnel config lock") {
												sh "ansible-playbook ${workspace}/common/tunnelConfig.yml -i  ${cloudVariable."$HUB".router_mgmt_ip}, \
												--extra-vars \" tunnel_id=$tunnel_number remote_ip=${cloudVariable."$it".tunnel_source_ip} \" "	
												tunnel_number++			
											}
										}
									} catch (exc) {
										echo "Caught: " + exc.toString()
										unstable("${STAGE_NAME} failed!")
										currentBuild.Result = 'FAILURE'
										active_cloud_list = active_cloud_list.replaceAll("${it}","").replaceAll("__","_").replaceAll("(_+\$)|(^_+)","")	
									}
								}	
							}
						}				
					}		
					parallel tunnel_config_list
				}
			}					
		}			
		stage('Testing') {
			steps {
				script {
					try {
						sleep 45
						echo "clients list ${clients}"
						sh " ssh-keygen  -R ${cloudVariable."$HUB".client1_mgmt_ip} || true"						
						for (remote_client in clients) {
							echo "Testing ${remote_client} reachability"
							ping_result	=	sh (script: """ansible-playbook ${workspace}/common/ping.yml   -i ${cloudVariable."$HUB".client1_mgmt_ip}, \
							--extra-vars \"remote_client=$remote_client \" """, returnStdout: true).trim()
							echo "$ping_result"
							if(ping_result.contains("5 packets transmitted, 5 received, 0% packet loss")) {
								echo "${remote_client} is reachable from $HUB client1 "
							} else {
								echo "${remote_client} is not reachable from $HUB client1 "
						 		result	=	'FAILURE'
							}
						}	
				 	} catch (exc) {
						echo "Caught: " + exc.toString()
						unstable("${STAGE_NAME} failed!")
					}	
					if(result.contains("FAIL")) {
						unstable("${STAGE_NAME} failed!")
						currentBuild.currentResult = 'FAILURE'
						echo "result contains fail"					
					}						
				}
			}
		}	
	}
	post {
		always {			
			script {
				def postMethod
				sh "cd $workspace"
				postMethod = load "free_Resources.groovy"
				if(REMOVE_CONFIG.contains("yes")) {
					RemoveConfig_Result = postMethod.free_Resources(workspace)			
					if(RemoveConfig_Result.toString().contains("FAIL")) {
						unstable("${STAGE_NAME} failed!")
						echo "Remove config RESULT: ${stageResult}"
					}	
				}		 	
				if(result.contains("FAIL")) {
					currentBuild.result = 'FAILURE'
					echo "result contains fail"					
				}
			
				echo "RESULT: ${currentBuild.result}"				
			}		
		}	
	}
}
def Containers_VMs_config(thiscloud) {
	def prefixlen
	def ip_addresses
	def containers_ip_addresses
	def vm_ipaddress
	def starting_index
	echo "inside containers vms"
	echo "$thiscloud"
	lock("ipv6 allocations lock") {
		starting_index = ipv6_index
		
		//Docker gateway ipv6 address. It doesn't need to be added into clients list
		ReserveIPv6_address(1)
		
		//Containers' ipv6 addresses
		ReserveIPv6_address(3)
	}	
	sh " ssh-keygen  -R ${cloudVariable."$thiscloud".router_mgmt_ip} || true"

	sh "ansible-playbook ${workspace}/common/Containers.yml -i ${cloudVariable."$thiscloud".router_mgmt_ip}, \
	--extra-vars \" ip_range=${cloudVariable."$thiscloud".overlay_ip_range} ipv6_index=$starting_index file=${thiscloud}_containers \" "
	
	ip_addresses	=	sh (script: "cat ${workspace}/common/${thiscloud}_containers", returnStdout: true).trim()
	containers_ip_addresses = ip_addresses.tokenize(',')
	clients.addAll(containers_ip_addresses)
	echo "$clients"
	
	vm_ipaddress	=	cloudVariable."$thiscloud".overlay_ip_range.split('/')


	lock("ipv6 allocations lock") {
		echo "$ipv6_index"
		starting_index = ipv6_index
		clients.add(ReserveIPv6_address())
	}			
	
	sh "ssh-keygen  -R ${cloudVariable."$thiscloud".client1_mgmt_ip} || true"

	sh "ansible-playbook ${workspace}/common/VMs.yml -i ${cloudVariable."$thiscloud".client1_mgmt_ip}, \
	--extra-vars \" ip_address=${vm_ipaddress[0]} ipv6_index=$starting_index \" "

	clients.add("${vm_ipaddress[0]}")	
	echo "$clients"
}
def ReserveIPv6_address(def no_of_IPs=1) {
	current_ipv6_address = TF_VAR_L2_OVERLAY_v6NETWORK + ipv6_index.toString()
	ipv6_index = ipv6_index + no_of_IPs	
	if (ipv6_index > 99) {
		echo "IPv6 allocations are exhausted"
		return 0
	}	
	return current_ipv6_address
}