# Terraform

Updating code locally and running script should update code stored in s3 bucket and replace clusters to apply the new code

# How to use

1. Install aws cli (already installed on homer)
2. Install terraform (not installed on homer)
3. Configure aws cli
4. Move into terraform wd and run `terraform init` to initialise working directory
5. Create kms key using aws cli or console, following steps [here](https://data-intellect.atlassian.net/wiki/spaces/TSD/pages/199459206/AWS+Finspace+Getting+Started)
6. Update details in `terraform.tfvars` - buckets/environments etc do not need to exist already, will be created with names you enter. If these names are already taken then those resources will be replaced.
7. Update `clusters.tf` specifying details of any clusters you want to create/update - configuration options for different cluster types can be found [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/finspace_kx_cluster)
8. Run `terraform plan` from terraform directory, this should show any changes planned - or any errors in the code
9. If changes planned look ok - run `terraform apply` - will need to confirm with `yes`. 
10. If you want to change code on the clusters, update code in zip file locally, keep the same name and in the same location, run `terraform plan` -> `terraform apply` - this should replace clusters and update with new code

# Issues
1. Currently waits for cluster to fully delete before creating a new one which takes an extra 30 mins. 
2. When creating hdb cluster - cache configuration must be specified when attaching database (min 1200gb) - this isn't the case from the console
3. Ideally would use versioning on s3 bucket containing code - but that gives issues when creating a cluster - so currently changes name of zip filein s3 bucket when content is updated using sha1
4. Only creates kdb-user for one cluster - can be changed easily in main.tf if you have more clusters - should be able to change to automatically add user to each cluster at some point 
