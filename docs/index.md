TorQ in Managed kdb Insights Demo Pack
==============

The purpose of the TorQ on Managed kdb Insights Demo Pack is to set up an example TorQ
installation on Managed kdb Insights and to show how applications can be built and
deployed on top of the TorQ framework. The example installation contains
key features of a production data capture installation, including
persistence. The demo pack includes:

-   an example set of historic data

-   a simulated data feed

-   configuration changes for base TorQ

-   start and stop scripts using Terraform

Once started, TorQ will generate simulated data and push it into an
in-memory real-time database inside the rdb cluster. It will persist this
data to a Managed kdb database every day at midnight. The system will operate 24\*7.

*email:* <torqsupport@dataintellect.com>

*web:* [www.dataintellect.com](http://www.dataintellect.com)