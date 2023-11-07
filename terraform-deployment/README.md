# Terraform Deployment

This terraform setup can be used to deploy and manage a finspace environment running a FinTorq stack

# Pre Requisites

1. Have latest version of  aws cli installed (already done on homer)
2. Have latest version of terraform installed (also done on homer)
3. Configure aws cli to your aws account 
4. Create a kms key on the region you are setting up your environment - Will also need to edit key policy to give FinSpace permissions
5. Finspace environment are limited to one per region - so you should not already have an environment set up on this region

# How to Use - Initial Deployment

1. Download this repo along with latest version of TorQ
2. Move TorQ into FinTorQ directory, alongisde finTorq-App
3. Zip TorQ and finTorq-App together using `zip -r code.zip TorQ/ finTorq-App/` this will form the base code for each cluster
4. (Optional) If you have a hdb you want to migrate over to finspace, replace the dummy hdb in `/finTorq-App/hdb`
4. Move into `terraform/deployments` directory, this will be the terraform working directory from which you should run all `terraform` commands
5. Modify variables inside `terraform.tfvars` file
6. (Optional) Use the `cluster.tf` files in the `cluster` directory to configure settings for each cluster individually
7. From your Terraform wd, run `terraform init`
8. run `aws configure` in terminal to set up your access key and sercret key from your aws account, this is needed inorder to connect to your account and use the terraform deployment. (check our resource link for more instruction on how to find your access key and serccret key)
8. If initialised succesfully, run `terraform plan`, this will show all resources set to be created or destroyed by terraform
9. Run `terraform apply` to execute this plan - Initial deployment can take ~45 minutes and connection losses can cause errors with deployment - so it can be a good idea to run this in `nohup`

## Resource Link

Terraform deployment full instruction [FinTorq Deployment / Terraform](https://data-intellect.atlassian.net/wiki/spaces/TK/pages/238944400/FinTorq+Deployment+Terraform).
 
# Managing Your Infrastructure

Once your environment is up and running - you can use this configuration to manage it 

1. Code updates - if you make any code changes in `TorQ` or `finTorq-App` and want to apply these to your clusters - just rezip these directories and run the terraform deployment again - this will recreate clusters with the updated code
2. Cluster Config - if you want to make some changes to a cluster's config settings i.e. node size of the RDB, update this in `clusters/rdb.tf` and run terraform again - the RDB will recreated with this new node size
3. Delete/Create Clusters - clusters can be deleted/created individually or all at once from the `terraform.tfvars` file - to delete a cluster just set it's count to 0, to delete all clusters set `create-clusters` to 0  



# For Deploying With Terraform But With Existing Structure

 We can use import statement on Terraform. Inside the terraform deployment folder, there is a imports.tf folder( currently empty) This imports.tf is automaticlly be run before Terraform apply any changes to the structure, importing exsiting structure from your AWS to the deployment system.  

### List of AWS Structures that will be created with our Terraform deployment
* module.environment.data.aws_iam_policy_document.iam-policy
* module.environment.data.aws_iam_policy_document.s3-code-policy
* module.environment.data.aws_iam_policy_document.s3-data-policy
* module.environment.aws_ec2_transit_gateway.test
* module.environment.aws_finspace_kx_database.database
* module.environment.aws_finspace_kx_environment.environment
* module.environment.aws_finspace_kx_user.finspace-user
* module.environment.aws_iam_policy.finspace-policy
* module.environment.aws_iam_role.finspace-test-role
* module.environment.aws_iam_role_policy_attachment.policy_attachment
* module.environment.aws_s3_bucket.finspace-code-bucket
* module.environment.aws_s3_bucket.finspace-data-bucket
* module.environment.aws_s3_bucket_policy.code-policy
* module.environment.aws_s3_bucket_policy.data-policy
* module.environment.aws_s3_bucket_public_access_block.code_bucket
* module.environment.aws_s3_bucket_public_access_block.data_bucket
* module.environment.aws_s3_bucket_versioning.versioning
* module.environment.null_resource.create_changeset
* module.environment.null_resource.upload_hdb
* module.lambda.data.aws_iam_policy_document.finspace-extra
* module.lambda.aws_cloudwatch_event_rule.trigger_finSpace-rdb-lambda
* module.lambda.aws_cloudwatch_event_target.target_finSpace-rdb-lambda
* module.lambda.aws_cloudwatch_metric_alarm.RDBOverCPUUtilization
* module.lambda.aws_iam_policy.lambda_basic_policy
* module.lambda.aws_iam_policy.lambda_ec2_policy
* module.lambda.aws_iam_policy.lambda_finspace_policy
* module.lambda.aws_iam_role.lambda_execution_role
* module.lambda.aws_iam_role_policy_attachment.attach1
* module.lambda.aws_iam_role_policy_attachment.attach2
* module.lambda.aws_iam_role_policy_attachment.attach3
* module.lambda.aws_lambda_function.finSpace-rdb-lambda
* module.lambda.aws_lambda_permission.lambda_from_cw_permission
* module.network.aws_internet_gateway.finspace-igw
* module.network.aws_route.finspace-route
* module.network.aws_route_table.finspace-route-table
* module.network.aws_security_group.finspace-security-group
* module.network.aws_subnet.finspace-subnets[0]
* module.network.aws_subnet.finspace-subnets[1] 
* module.network.aws_subnet.finspace-subnets[2]
* module.network.aws_subnet.finspace-subnets[3] 
* module.network.aws_vpc.finspace-vpc