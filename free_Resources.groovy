#!/usr/bin/env groovy
def free_Resources(workspace) {
	node {	
		stage('unconfig') {	
			script {
				def unconf = [:]
				CLOUD_LIST.split('_').each {
					unconf["${it}"] = {
						node ('master') {
							stage("${it}") {
								try {
									if(it.contains("vsphere")) {				
										echo "Removing vsphere resources"	
										sh "ansible-playbook $workspace/vsphere/ansible/vsphere-playbook.yml -i $TF_VAR_ESXI_HOST, --extra-vars \" variable_hosts=$TF_VAR_ESXI_HOST  \
										ESXI_ROUTER_NAME=$TF_VAR_ESXI_ROUTER_NAME ESXI_CLIENT1_NAME=$TF_VAR_ESXI_CLIENT1_NAME\" "

										sh "cd $workspace/vsphere;terraform destroy -var-file=$VSPHERE_SECRETS_FILE -var CLIENT1_MGMT_IP=$cloudVariable.vsphere.client1_mgmt_ip  -var ROUTER_MGMT_IP=$cloudVariable.vsphere.router_mgmt_ip \
										-state=${workspace}/vsphere/terraform.tfstate -auto-approve terraform/"	
									}
									if(it.contains("aws")) {		
										echo "Removing aws resources"
										sh "cd $workspace/aws;terraform destroy -var-file=$AWS_SECRETS_FILE -auto-approve terraform/"	
									}
									if(it.contains("azure")) {
										echo "Removing azure resources"
										sh "cd $workspace/azure;terraform destroy -var-file=$AZURE_SECRETS_FILE -auto-approve terraform/"			
									}							
									if(it.contains("gcp")) {
										echo "Removing gcp resources"
										sh "cd $workspace/gcp;terraform destroy -auto-approve terraform/"
									} 
									if(it.contains("oracle")) {
										echo "Removing oci resources"
										sh "cd $workspace/oracle;terraform destroy -var-file=$OCI_SECRETS_FILE -auto-approve terraform/"
									} 
									if(it.contains("ali")) {
										echo "Removing alicloud resources"
										sh "cd $workspace/ali;terraform destroy -var-file=$ALI_SECRETS_FILE -auto-approve terraform/"
									} 	
								} catch (exc) {
									echo "$it Caught: " + exc.toString()
									result = 'FAILED'
								}
							}
						}
					}
				}	
				parallel unconf			
			} 
		}
	}
}
return this	