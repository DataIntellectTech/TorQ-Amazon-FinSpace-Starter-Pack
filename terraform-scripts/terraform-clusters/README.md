# Terraform Clusters

Terraform program to deploy/manage clusters within a finspace environment

# Pre-requisites

1. Latest versions of terraform and aws cli installed and configured
2. the following should already be created on your aws account:
	- finspace environment
	- s3 buckets containing code and hdb, with necessary permissions applied
	- kx user role attached to environment
	- database created with changeset applied on environment

This should all be covered in the aws workshop

# Steps to deploy TorQ

1. Make any required changes to the code
2. Upload required code to code bucket
3. Update terraform.tfvars file
4. Update vpc network settings for each cluster (might move this to .tfvars file)
5. (Optionally) Configure cluster settings in each cluster file in the clusters directory
6. Run `terraform apply` -> `terraform plan`


