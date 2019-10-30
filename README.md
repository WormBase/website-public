WormBase Website Repository
===========================

This repository contains the [WormBase](http://www.wormbase.org) Web application.

**The repository for [WormBase Mobile](http://m.wormbase.org) can be found at [WormBase/website-mobile](https://github.com/WormBase/website-mobile)**

Technical Overview
------------------

The technical stack of WormBase website consits of:
- A web server based on a MVC framework, [Catalyst](http://www.catalystframework.org/) and [Template Toolkit](http://www.template-toolkit.org/)
- React for some portions of the UI
- Database engines: ACeDB, MySQL, Datomic
- Nginx
- BLAST, and other bioinformatics tools
- [A RESTful data API](https://github.com/WormBase/wormbase_rest)
- [A RESTful search API](https://github.com/WormBase/wb-search)

For devOps, we use Docker, docker-compose, Jenkins, AWS Elastic Beanstalk.


Development
--------------------------------------------------------

Development environment can be setup easily and without installing any dependency, using a shared development machine and `docker-compose`.

_For Legacy instructions_ that set up without docker or docker-compose, please visit the [Manual Setup Guide](/docs/manual_setup.md).

Prerequisite:

- Obtain access and login to the shared development instance, where data and legacy software are stored.

- Ensure environment variable `CATALYST_PORT` and `WEBPACK_SERVER_PORT` are set.

- Ensure `/usr/local/bin/` is on your $PATH, as dependencies such as `docker-compose` and `yarn` are installed there.

To start your development stack:

`make dev` and wait for website/Catalyst and webpack(DevServer) to start.

To shutdown your development stack cleanly:

`make dev-down`


### Development Environment Troubleshooting

**`make dev` appears stuck**

The first time that `make dev` runs, it takes longer due to installation of dependencies.

**The stdout is jumbled**

The `stdout` of docker-compose combines the stdouts of the containers. To make it easier to read, stdout of individual containers can be accessed via `SERVICE=[name_of_service] make console`, where the name of service could be website, webpack, etc as found in [docker-compose.yml](docker-compose.yml) and [docker-compose.dev.yml](docker-compose.dev.yml).

**`docker-compose` cli commands not taking effect**

The Makefile exports user-specific environment variable `COMPOSE_PROJECT_NAME` to allow multiple instances of the development stack to run on the same machine. If you use docker-compose cli directly, please set `COMPOSE_PROJECT_NAME` accordingly to interact with your particular development instance.

**Unable to connect to ACeDB**

ACeDB container isn't started as part the development stack to reduce memory footprint. Instead, we rely on a shared acedb container, by joining the docker networked called `wb-network` where the acedb runs on. If the shared acedb container is down, instructions to start the shared acedb container is found [here](https://github.com/WormBase/wormbase-architecture/blob/develop/roles/acedb/files/startserver.sh).

**Prettier git pre-commit hook doesn't trigger**

JavaScript dependencies are installed both on the host and in the container. The former is necessary to enable code formatting with Prettier and git pre-commit hooks with Husky.


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


Staging Deployment on AWS ElasticBeanstalk
---------------------------------------------

Staging deployment is mostly automated and continuously deployed. The only manual step is to inform EB of the correct volume (file system) snapshot to use for a particular WS release.

The file system contains data and certain scripts that aren't dockerized. For more details for data and File System access, refer to EB deployment overview section above.

Continuous deploying of the staging site to AWS EB is handled by Jenkins. It's triggered by commits to the staging branch on Github.

Jenkins runs the [jenkins-ci-deploy.sh](jenkins-ci-deploy.sh) script to deploy changes.

For detailed setup, please visit the Jenkins web console.

Production Deployment on AWS ElasticBeanstalk
---------------------------------------------

Deploying to production involves the following steps:

- change the release number in wormbase.conf
- Make a release
  ```
  # at the appropriate git branch for production
  make release
  ```

- Deploy to the pre-production environment

  ```console
  # at the appropriate git branch for production
  make eb-create

  # If ACeDB TreeView isn't working, which seems to be caused by a race condition
  # between setting up the file system and starting ACeDB container,
  # can generally be fixed by re-do the deployment step
  make production-deploy
  ```

- Swap the URL between the pre-production environment and the exiting production environment
	- This can be done through the web console of AWS ElasticBeanstalk.

- After making sure the new production environment is working, shut down the previous production environment
	- This can be done through the web console of AWS ElasticBeanstalk.


Applying Hotfix on AWS ElasticBeanstalk
-----------------------------------------

- Prior to applying the hotfix, ensure you are at the appropriate git branch for production.

- Then run the following commands,


	```
	VERSION=[GIT_TAG_TO_BE_CREATED] make release  # the tag should look like WS268.12
	make production-deploy
	```

Production Deployment without AWS Beanstalk
------------------------------------------
For instances not managed by Beanstalk, deployment can be performed with:

```
# ensure port 5000 is available, then
make production-deploy-no-eb
```

Contributing
------------

Our development workflow can be found here:

[http://wiki.wormbase.org/index.php/Development_workflow_-_webdev](http://wiki.wormbase.org/index.php/Development_workflow_-_webdev)

Todd Harris (todd@wormbase.org)

Acknowledgements
----------------

<a href="https://www.browserstack.com/"><img src="https://www.browserstack.com/images/mail/browserstack-logo-footer.png" alt="BrowserStack" width="120px" /></a>

Thanks to BrowserStack for allowing us to perform interactive cross browser and cross OS testing.
