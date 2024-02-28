Prerequisites
===============

- An [AWS account with an AdministratorAccess policy](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AdministratorAccess.html) to create the Managed kdb resources.
- A KX insights license applied to your account. If you don’t have one see [Activate your Managed kdb Insights license - Amazon FinSpace](https://docs.aws.amazon.com/finspace/latest/userguide/kdb-licensing.html).
- Inside a Linux system you will need to download code from the [TorQ](https://github.com/DataIntellectTech/TorQ/tree/master) and [TorQ-Amazon-FinSpace-Starter-Pack](https://github.com/DataIntellectTech/TorQ-Amazon-FinSpace-Starter-Pack/tree/master) GitHub repositories - Instructions below.
- If you are **NOT** using our Terraform deployment option to create and set up your Kdb Environment, follow [this AWS workshop](https://catalog.us-east-1.prod.workshops.aws/workshops/a1575309-1f43-4945-a5fa-a4d62d5e821d/en-US/envcreate) to do so.

## Downloading the Code

### TorQ

Take note of the latest version of code from the [TorQ Latest Release Page](https://github.com/DataIntellectTech/TorQ/releases/latest) - release name are v#.#.# e.g. v1.0.0

Run the following code - ensure you replace `<copied_version_name>` with the release version you took note of above.

    git clone --depth 1 --branch <copied_version_name> https://github.com/DataIntellectTech/TorQ.git

### TorQ Amazon FinSpace Starter Pack

Take note of the latest version of code from the [TorQ-Amazon-FinSpace-Starter-Pack Latest Release Page](https://github.com/DataIntellectTech/TorQ-Amazon-FinSpace-Starter-Pack/releases/latest) - release name are v#.#.# e.g. v1.0.0

Run the following code - ensure you replace `<copied_version_name>` with the release version you took note of above.

    git clone --depth 1 --branch <copied_version_name> https://github.com/DataIntellectTech/TorQ-Amazon-FinSpace-Starter-Pack.git

### Zip them up together

Now we will zip these files together:

    zip -r code.zip TorQ/ TorQ-Amazon-FinSpace-Starter-Pack/ -x "TorQ*/.git*"

### Upload to S3 (For Non Terraform Deployment Only)

Then upload them to your AWS S3 codebucket:

    aws S3 cp code.zip s3://<you S3 codebucket name>