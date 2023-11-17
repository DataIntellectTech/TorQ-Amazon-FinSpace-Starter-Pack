TorQ in Managed kdb Insights Demo Pack
==============

The purpose of the TorQ on Managed kdb Insights Demo Pack is to set up an example TorQ
installation on Managed kdb Insights and to show how applications can be built and
deployed on top of the TorQ framework. The example installation contains
all the key features of a production data capture installation, including
persistence and resilience. The demo pack includes:

-   a slightly modified version of kdb+tick from Kx Systems

-   an example set of historic data

-   a dummy data feed

-   configuration changes for base TorQ

-   start and stop scripts using Terraform

Once started, TorQ will generate dummy data and push it into an
in-memory real-time database inside the rdb cluster. It will persist this
data to S3 every day at midnight. The system will operate 24\*7.

Further information can be found in the [TorQ on Managed kdb Insights Manual](https://dataintellecttech.github.io/TorQ-Finspace-Starter-Pack/).

*email:* <torqsupport@dataintellect.com>

*web:* [www.dataintellect.com](http://www.dataintellect.com)