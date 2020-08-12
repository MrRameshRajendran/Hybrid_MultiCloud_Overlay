#!/bin/bash
git update-index --skip-worktree secrets/aws_secrets.tfvars 
git update-index --skip-worktree secrets/azure_secrets.tfvars 
git update-index --skip-worktree secrets/ali_secrets.tfvars 
git update-index --skip-worktree secrets/oci_secrets.tfvars
git update-index --skip-worktree secrets/vsphere_secrets.tfvars
