Deployment with AWS ElasticBeanstalk Overview
----------------------------------------

AWS ElasticBeanstalk (AWS EB) allow us to deploy our multi-container build easily. It provides health monitoring, load balancing, rolling updates, etc.

Here, we highlight some important aspects for working with AWS EB.

### Credentials

Appropriate AWS permission is setup on the development server instance through an [instance profile](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-ec2_instance-profiles.html). The permissions are granted to the role `wb-web-team-dev-instance-role` that is attached to the development server instance.

In production deployment with beanstalk, the instance profile role `wb-catalyst-beanstalk-ec2-role` is used by instances created by Beanstalk.

Note: WormBase developers no longer need user-level AWS permission to perform the tasks below.

### Environments

We maintain two kinds of deployments on EB:

* A perpetual staging environment
* A release specific production

It’s important to know which environment you are working with, when making changes to a deployment.

To learn about their differences and how to work with them, please read the Staging Deployment and Production Deployment sections below, as well as parts of the Makefile, in particular tasks such as `make eb-create`, `make production-deploy`, and `make staging-deploy`.


### Configuration

While the EB web management console provides easy ways to experimenting with configuration options, we consider the _source of truth_ for configuration to be:
* saved configuration used by `make eb-create`, AND
* configurations in [.ebextensions/](.ebextensions/)

Staging ane Production configuration should be kept virtually the same to facilitate reproducibility and testing.

What this means in practice:
* Please test a configuration on staging environment before applying it to production environment
* If there is a configuration change that you applied through the WB web management console that you intent to keep (to future builds/releases), please make a “Saved Configuration” through the web management console, give a version name (like v.1.0), and update the Makefile task `eb-create` to use the new version (such as `--cfg v1.0`
* `.ebextensions` is intended for more obscure config options that’s not available through the web management console.


### Docker Containers

Website (Catalyst) code in this repository are running inside containers when deployed to Beanstalk.

For more details, please refer to the staging deployment and production elopement sections below, as well as the Makefile task `eb-create`.

### Data and File System access

Data associated with a particular release (such as data in ACeDB and BLAST) are deployed to EB through a mounted volume based on a volume snapshot.

**EB needs to be manually configured to use a volume snapshot for each WS release.**

A volume snapshot is created at the end of the "staging process" and is unique each release. The volume ID can be located from AWS console under Services > EC2 > Snapshots.

The exact configuration is done at [.ebextensions/01-setup-volumes.config](.ebextensions/01-setup-volumes.config).
