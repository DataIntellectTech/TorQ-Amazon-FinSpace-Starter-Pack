# Terraform Deployment

This terraform setup can be used to deploy and manage a finspace environment running a FinTorq stack

# Pre Requisites

1. Have latest version of  aws cli installed (already done on homer)
2. Have latest version of terraform installed (also done on homer)
3. Configure aws cli to your aws account 
4. Create a kms key on the region you are setting up your environment
5. Finspace environment are limited to one per region - so you should not already have an environment set up on this region

# How to Use - Initial Deployment

1. Download this repo along with latest version of TorQ
2. Move TorQ into FinTorQ directory, alongisde TorQ-Amazon-FinSpace-Starter-Pack
3. Zip TorQ and TorQ-Amazon-FinSpace-Starter-Pack together using `zip -r code.zip TorQ/ TorQ-Amazon-FinSpace-Starter-Pack/` this will form the base code for each cluster
4. (Optional) If you have a hdb you want to migrate over to finspace, replace the dummy hdb in `/TorQ-Amazon-FinSpace-Starter-Pack/hdb`
4. Move into `terraform-deployment` directory, this will be the terraform working directory from which you should run all `terraform` commands
5. Modify variables inside `terraform.tfvars` file
6. (Optional) Use the `cluster.tf` files in the `cluster` directory to configure settings for each cluster individually
7. From your Terraform wd, run `terraform init`
8. If initialised succesfully, run `terraform plan`, this will show all resources set to be created or destroyed by terraform
9. Run `terraform apply` to execute this plan - Initial deployment can take ~45 minutes and connection losses can cause errors with deployment - so it can be a good idea to run this in `nohup`

# Managing Your Infrastructure

Once your environment is up and running - you can use this configuration to manage it 

1. Code updates - if you make any code changes in `TorQ` or `TorQ-Amazon-FinSpace-Starter-Pack` and want to apply these to your clusters - just rezip these directories and run the terraform deployment again - this will recreate clusters with the updated code
2. Cluster Config - if you want to make some changes to a cluster's config settings i.e. node size of the RDB, update this in `clusters/rdb.tf` and run terraform again - the RDB will recreated with this new node size
3. Delete/Create Clusters - clusters can be deleted/created individually or all at once from the `terraform.tfvars` file - to delete a cluster just set it's count to 0, to delete all clusters set `create-clusters` to 0  
