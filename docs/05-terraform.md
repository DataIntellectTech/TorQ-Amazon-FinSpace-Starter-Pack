Terraform
===============

The process of setting up a working Managed kdb environment manually can take some time - especially if you are new to AWS. To aid this process we have a [Terraform deployment option](https://dataintellecttech.github.io/TorQ-Amazon-FinSpace-Starter-Pack/terraformdeloyment/) which should allow you to boot TorQ in Managed kdb Insights in a few simple commands. 

This Terraform script can be used to deploy an entire environment from scratch. This will include:

- creating and uploading data to S3 buckets with required policies

- creating IAM roles

- creating network and transit gateway

- as well as deploying clusters.

It is split into two modules, one for the environment and one for the clusters. This makes the directory more organised and cluster deployments easier to manage. The cluster module is still dependent on the environment module as it will import some variables from here that are needed for cluster creation.

![Terraform Module Diagram](workshop/graphics\terraform_modules.png)