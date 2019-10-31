Deployment with AWS ElasticBeanstalk Overview
----------------------------------------

AWS ElasticBeanstalk (AWS EB) allow us to deploy our multi-container build easily. It provides health monitoring, load balancing, rolling updates, etc.

Here, we highlight some important aspects for working with AWS EB.


### Permissions

Deploying to EB requires permissions to do so.

Appropriate AWS permission is setup on the shared development server instance through an [instance profile](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html). The permissions are granted to the role `wb-web-team-dev-instance-role` that is attached to the development server instance.

In production deployment with EB, the instance profile role `wb-catalyst-beanstalk-ec2-role` is used by instances created by EB.

Note: WormBase developers no longer need user-level AWS permission to perform the tasks below.


### Environments

Multiple environments (ie. deployments) of the website tier could be running on EB, such as the current production site, the pre-production site (for the next release) and an on-demand staging/test site. It’s important to know which environment you are working with, when deploying changes.

Commands, such as `make eb-create` and `make production-deploy`, detect the WS release from the wormbase.conf and use the EB environment that matches the release.

For more details on creating and deploying to different environments, please refer to [Makefile](../Makefile).


### Configuration

While the EB web management console provides easy ways to experimenting with configuration options, these changes are lost when the environment is terminated. To avoid this issue and allow future environments to be created with the changes, you need to create saved configurations through either the EB management console or the EB CLI.

We consider the following configuration options to be the  _source of truth_ (with precedence, from highest to lowest):
* saved configuration used by `make eb-create`, AND
* configurations in [.ebextensions/](../.ebextensions/)

**How to change EB configurations**
* Create an environment for testing the configurations, such as `make eb-create-staging`
* Apply configuration changes through the WB management console if possible
* When you are happy with the configuration, make a “Saved Configuration” and give a version name (like v2)
* Udate the Makefile task `eb-create` to use the new version (such as `--cfg v2`
* Use`.ebextensions` for more obscure config options not available through the management console


### Docker Containers

Website site tier is deployed as a multi-containers on EB.

For details about the containers and their configurations, please refer to the [Dockerrun.aws.json](../Dockerrun.aws.json).


### Data and File System access

Data associated with a particular release (such as data in ACeDB and BLAST) are deployed to EB through a mounted volume based on a volume snapshot.

**EB needs to be manually configured to use a volume snapshot for each WS release.**

A volume snapshot is created at the end of the "staging process" and is unique to the release. The volume ID can be located from AWS console under Services > EC2 > Snapshots.

The exact configuration is done at [.ebextensions/01-setup-volumes.config](../.ebextensions/01-setup-volumes.config).
