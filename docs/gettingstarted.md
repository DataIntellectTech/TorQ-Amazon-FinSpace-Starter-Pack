Getting Started
===============

The TorQ Finspace Starter Pack is designed to run on Amazon Managed kdb Insights. It contains an optional small initial
database of 260MB. As the system runs, data is fed in and written to S3 at end of day.

It is assumed that most users will be running with the free 32-bit version of kdb+. TorQ and the TorQ demo pack will run
in exactly the same way on both the 32-bit and 64-bit versions of kdb+.

Installation and Configuration
------------------------------

### Prerequisites

1. An AWS account with an AdministratorAccess policy to create the Managed kdb Insights resources.

2. You need a KX insights license applied to our account. If you don’t have one see [Activate your Managed kdb Insights license - Amazon FinSpace](https://docs.aws.amazon.com/finspace/latest/userguide/kdb-licensing.html).

3. Inside a Linux system you will need to download the [TorQ](https://github.com/DataIntellectTech/TorQ/tree/master) and [TorQ FinSpace Starter Pack](https://github.com/DataIntellectTech/TorQ-Finspace-Starter-Pack/tree/master) GitHub code repos.

Start Up
--------

1. Zip up TorQ and TorQ-Finspace-Starter-Pack and name it code.zip

2. Follow the steps in our [Terraform documentation](https://dataintellecttech.github.io/TorQ-Finspace-Starter-Pack/terraform/) to get your environment and clusters (processes) started.

The process of setting up a working Managed kdb Insights environment manually can take some time - especially if you are new to AWS. To aid this process we have a Terraform deployment option which should allow you to boot TorQ in Managed kdb Insights in a few simple commands. This Terraform script can be used to deploy an entire environment from scratch. Including creating and uploading data to s3 buckets with required policies, creating IAM roles, and creating network and transit gateway, as well as deploying clusters.

It is split into two modules, one for the environment and one for the clusters - which makes the directory more organised and easier to manage cluster deployment. The cluster module is still dependent on the environment module as it will import some variables from here that are needed for cluster creation.

For setting up your environment and/or clusters manually, more details will become available in our AWS workshop which is due to be published December 2023 - January 2023.

### Check If the System Is Running

Below is an example of what running clusters look like. You can find this page by going to the AWS console -> Amazon Finspace -> Kdb Environment -> select your environment -> clusters tab

![Clusters running example image](graphics/clustersrunning.png)

### Connecting To A Running Process

- On the users tab, copy the ARN from the IAM role of the user

- Open the AWS CloudShell and run the following 2 commands (Be sure to edit the below commands with your environment details)

        export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s" \
        $(aws sts assume-role \
        --role-arn <ARN_COPIED_FROM_ABOVE> \
        --role-session-name "connect-to-finTorq" \
        --query "Credentials.[AccessKeyId,SecretAccessKey,SessionToken]" \
        --output text))

        Amazon FinSpace get-kx-connection-string --environment-id <YOUR_KDB_ENVIRONMENT_ID> --user-arn <USER_ARN_COPIED_ABOVE>  --cluster-name <NAME_OF_CLUSTER>

Trouble Shooting
----------------

All the processes logs can be found in AWS Cloudwatch. In general each process writes three logs: a standard out log, a standard
error log and a usage log (the queries which have been run against the process remotely). Check these log files for errors.

### Errors in cluster creation
On cluster creation, most errors will result in your cluster going to a “Create failed” state. If that is the case you should:

1. Click the cluster name in the “Cluster” section of your environment

2. Scroll down the page and open the “Logs” tab. This should have a message with a more individualised error you can check.

3. If you click the LogStream for an individual log it will take you to AWS CloudWatch where you can filter the messages for keywords or for messages in a certain time window. 

It is worthwhile checking the logs even for clusters that have been created and searching for terms like “err”, “error” or “fail” 

Make It Your Own
----------------

The system is production ready. To customize it for a specific data set, modify the schema file and replace the feed process
with a feed of data from a live system.