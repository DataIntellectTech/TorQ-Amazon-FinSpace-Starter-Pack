Creating and Connect to an EC2 Instance
===============

## Create a Windows EC2 Instance

Navigate to the EC2 service.

![Navigate to the EC2 service](workshop/graphics/navigate_ec2.png)

Select "launch instance" to create a new EC2 instance.

![Select launch instance](workshop/graphics/ec2_launch.png)

Most options here can be left as their defaults. Here are the ones that need selected/changing:

1. Select "Windows" from the Quick Start options.

    ![select windows quick start](workshop/graphics/ec2_application.png)

2. We need to create a new key pair: Select "Create new key pair".

    ![Select create new key pair](workshop/graphics/ec2_keypair_button.png)

3. Enter a name for your key pair, leave the key pair type as ``RSA`` and the file format as ``.pem``. This will download a key file to you PC which you will use to connect to the instance.

    ![Create new key pair](workshop/graphics/create_key_pair.png)

The network should be in the same VPC as your cluster. Select create a new security group that allows connections from anywhere.
    - This is only for the purposes of the MVP. For customising see [this page](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/working-with-security-groups.html) on security groups.

![EC2 network](workshop/graphics/ec2_network.png)

## Adding your new security group to you EC2

Now we need to add the security group of your cluster to your EC2.

Navigate to EC2 service.

![Navigate to EC2](workshop/graphics/ec2_navigate.png)

Select "Instances (running)".

![Select Instance running](workshop/graphics/ec2_navigate2.png)

Open your EC2 Instance.

![Open EC2 instance](workshop/graphics/EC2_connect1.png)

Select "Actions", "Security" then "Change security groups".

![Select change security groups](workshop/graphics/ec2_add_security.png)

Search and select the security group that is on your clusters, select "Add security group" then "save".

![Add security group](workshop/graphics/ec2_add_security2.png)

You should now have two security groups, one from the launch wizard, and the one you added manually that is also attached to your clusters.

![security group example](workshop/graphics/ec2_security.png)

## Connecting to your EC2 Instance

Open your EC2 Instance.

![Open EC2 instance](workshop/graphics/EC2_connect1.png)

Select connect.

![Select connect](workshop/graphics/EC2_connect2.png)

### Get your password

this only needs to be done once. Once you have this password you can skip this step.

Select get password.

![Get password](workshop/graphics/EC2_connect3.png)

Upload the ``.pem`` that was saved to you PC earlier (alternativly you can just paste the contents of this file in the text box).

![upload .pem file](workshop/graphics/EC2_connect4.png)

This will return the value of your password. Keep a note of this password as you will need it to connect your EC2.

### Connect

Download the remote desktop file.

![dowload remote desktop file](workshop/graphics/EC2_connect5.png)

Run this file and enter the password you recieved above when promted. You should now be connected to the Windows remote desktop.