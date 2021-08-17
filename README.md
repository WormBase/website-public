WormBase Website Repository
===========================

This repository contains the [WormBase](http://www.wormbase.org) Web application.

**The repository for [WormBase Mobile](http://m.wormbase.org) can be found at [WormBase/website-mobile](https://github.com/WormBase/website-mobile)**

Technical Overview
------------------

The technical stack of WormBase website consits of:
- A web server based on a MVC framework, [Catalyst](http://www.catalystframework.org/) and [Template Toolkit](http://www.template-toolkit.org/)
- React for some portions of the UI
- Database engines: ACeDB, _MySQL_, _Datomic_
- Nginx
- BLAST, and other bioinformatics tools
- [_A RESTful data API_](https://github.com/WormBase/wormbase_rest)
- [_A RESTful search API_](https://github.com/WormBase/wb-search)
- [The auxiliary (Amplify) backends](wb-amplify-auxiliary-backend/)

_Italic indicates services whose deployment are managed separately from what is in this repository._

For devOps, we use Docker, docker-compose, Jenkins, AWS Elastic Beanstalk.


Development environment - EC2 option
--------------------------------------------------------

Development environment can be setup easily, using a shared development machine and `docker-compose`.

_For Legacy instructions_ that set up without docker or docker-compose, please visit the [Manual Setup Guide](/docs/manual_setup.md).

**Prerequisite:**

- Obtain access and login to the shared development instance, where data and legacy software are stored.

- Ensure environment variable `CATALYST_PORT` and `WEBPACK_SERVER_PORT` are set.

- Ensure `/usr/local/bin/` is on your $PATH, as dependencies such as `docker-compose` and `yarn` are installed there.

- Copy the file [wormbase_local.conf.template](wormbase_local.conf.template) into a new file named `wormbase_local.conf`, and configure, if necessary :
```
rest_server =    # to override REST API base URL
search_server =     # to override search API base URL
```

**To start your development stack:**

`make dev` and wait for website/Catalyst and webpack(DevServer) to start.

**To shutdown your development stack cleanly:**

`make dev-down`


### Development Environment Troubleshooting

**`make dev` appears stuck**

The first time that `make dev` runs, it takes longer due to installation of dependencies. Subsequent startup should take a few seconds.

**The stdout is jumbled**

The `stdout` of docker-compose combines the stdouts of the containers. To make it easier to read, stdout of individual containers can be accessed via `SERVICE=[name_of_service] make console`, where the name of service could be website, webpack, etc as found in [docker-compose.yml](docker-compose.yml) and [docker-compose.dev.yml](docker-compose.dev.yml).

**`docker-compose` cli commands not taking effect**

The Makefile exports user-specific environment variable `COMPOSE_PROJECT_NAME` to allow multiple instances of the development stack to run on the same machine. If you use docker-compose cli directly, please set `COMPOSE_PROJECT_NAME` accordingly to interact with your particular development instance.

**Unable to connect to ACeDB**

ACeDB container isn't started as part the development stack to reduce memory footprint. Instead, we rely on a shared acedb container, which is expected to run on the docker networked `wb-network`. If the shared acedb container is down, instructions to start the shared acedb container is found [here](https://github.com/WormBase/wormbase-architecture/blob/develop/roles/acedb/files/startserver.sh).

**Prettier git pre-commit hook doesn't trigger**

JavaScript dependencies (such as `prettier` and `husky`) need to be installed on the host for code formatting and other git pre-commit hooks to work.

**Compilation failure: You must configure a default store type unless you use exactly one store plugin.**

This problem seems to show up occasionally, when I modify the wormbase_local.conf while the server is running. Try `make dev-down` and then `make dev`, and repeat a few times until the problem resolves itself.


(Experimental) Development environment - Local option
--------------------------------------------------------

If a local development environment is preferred, this option would allow you to
setup a barebone development environment, without requiring credentials, such as
those for accessing cloud resources. As a result, some features of the website
will not work in this environment. But it should have enough functionalities for UI
development and testing.

**Prerequisite:**

- Ensure [Docker](https://docs.docker.com/) (18.06.0+) and [docker-compose](https://docs.docker.com/compose/install/) are installed.

- Ensure [node.js](https://nodejs.org/en/) (10+) and [Yarn](https://yarnpkg.com/) are installed.

- Ensure environment variable `CATALYST_PORT` and `WEBPACK_SERVER_PORT` are set.

- Copy the file [wormbase_local.conf.template](wormbase_local.conf.template) into a new file named `wormbase_local.conf`, and add the following configuration:
```
<Model::Schema>
  schema_class = WormBase::Schema
  <connect_info>
        dsn =  dbi:mysql:wormbase_user:hostname=mysql
        user = wormbase
        password = test
   </connect_info>
</Model::Schema>

webpack_dev_server = "http://webpack:__ENV(WEBPACK_SERVER_PORT)__"
```

**To start your development stack:**

`make local` and wait for website/Catalyst and webpack(DevServer) to start. _(Running this for the first time will take some time, due to the download of container images and npm dependencies. Subsequent runs will be much faster.)_

Please browse to the `http://localhost:CATALYST_PORT` (instead of the WEBPACK_SERVER_PORT) for testing of the website.

**To shutdown your development stack cleanly:**

`make local-down`

Staging A New Release
---------------------------------------------

### Mirror / unpack / process a new release:

#### Mirror a new release from Hinxton to the official WormBase FTP site (on the `proxy` instance):
```
cd /usr/local/wormbase/website-admin/update/staging
./steps/mirror_new_release.pl --release WSXXX
```

#### On the `rdbms` instance, mirror the GFF and clustal files:
```
cd /usr/local/wormbase/website-admin/update/staging
./steps/mirror_gff_and_clustal.pl --release WSXXX
// It may be necessary to first remove old releases from `/usr/local/ftp/pub/wormbase/releases` and databases from `/var/lib/mysql`. `df` first.

// Unpack the clustalw database
./steps/unpack_clustalw.pl --release WSXXX

// Prepare Bio::DB::SeqFeature::Store databases (requires overnight)
./steps/load_genomic_gff_databases.pl --release WSXXX
```

#### Mirror to the staging instance (`dev`):
```
// It may be necessary to first remove old releases from `/usr/local/wormbase/acedb` and `/usr/local/ftp/pub/wormbase`.
cd /usr/local/wormbase/website-admin/update/staging
./steps/mirror_new_release.pl --release WSXXX
./steps/unpack_acedb.pl --release WSXXX

// The current version of the acedb database is referenced by a symlink at /usr/local/wormbase/acedb/wormbase.
// Update this symlink to point to the newly unpacked acedb database.
./steps/adjust_symlinks.pl --release WSXXX.
```

  

Staging Environment
---------------------------------------------

WormBase staging site is hosted on the shared development instance. Its deployment is automated, triggered by committing to the staging branch on Github.

Continuous integration for staging environment is handled by Jenkins. Jenkins runs the [jenkins-ci-deploy.sh](jenkins-ci-deploy.sh) script to for deployment and testing. For detailed setup, please visit the Jenkins web console.


Production Environment
---------------------------------------------

WormBase production site is hosted with AWS Elastic Beanstalk. For details about customizing the production deployment, please visit the [WormBase Beanstalk Guide for Website](docs/beanstalk.md).

### Website release checklist

**After the Datomic database has been staged:**

- Index search with the new database release and deploy search API (based on [WormBase/wb-search](https://github.com/WormBase/wb-search))
-- Can be run on the shared development instance (permissions provided by role)
- Change the WS release number in wormbase.conf in the `website` repository, in particular, `wormbase_release`, `rest_server`, and `search_server` properties
- Commit these changes to the staging branch

**When JBrowse container is available:**

- Update JBrowse container version in [Dockerrun.aws.json](./Dockerrun.aws.json) and [docker-compose.yml](docker-compose.yml)
- We may be able to get rid of the JBrowse container (it resides in a multi-container environment built with docker-compose, side-by-side with the Catalyst app)
- Grepping for JBrowse if we want to remove...
- 

**About 10 days before the release date:**

- Create a snapshot of the primary filesystem (containing ACeDB and blast databases) on the shared development instance (it's around 1024GB)
-- TODO: This step is currently handled manually via the console. Consider automation.
- Create ACeDB deployment using AWS Launch Template:
-- EC2 > Instances > Launch Template > "acedb-ec2-launch-template".
-- Change the following:
--- Under "Storage", update the snapshot for the non-root volume to use the filesystem snapshot just created
--- Under "Networking", configure subnet as needed; "use auxiliary"
--- Configure tags as needed

The Catalyst app and EB deployment also needs to know about the snapshot:
- Update the volume snapshot for the WS release [here](.ebextensions/01-setup-volumes.config)

AceDB is managed outside of EB because of speed issues.
- Deploy ACeDB using the EC2 Launch Template: `acedb-ec2-launch-template` and set the environment variable `ACEDB_HOST_STAND_ALONE` in the Makefile
- Create the release branch, such as `release/273` and commit 

- At the release branch:

  ```console
  make release  # to build the assets (ie containers, minified JS, etc) required for deployment
  ```

Only needed when modifying the container.

  ```console
  make eb-create  # to create and deploy to the pre-production environment
  ```

- Login to the AWS Management Console, and navigate to Elastic Beanstalk, and then to the `website` Application.
    - Wait for the deployment to complete, and verify the pre-production environment is working, including spot checking
        - Search and Autocompletion
	- A example gene page and all the widgets
        - ACeDB TreeView
	- JBrowse (to be signed off by JBrowse development)


- Coordinate with REST API development to have the REST API deployed to take preaching traffic
- Pre-caching slow endpoints as described in [WormBase/wb-cache-warmer](https://github.com/WormBase/wb-cache-warmer). Monitor the progress and terminate the process when done.(The cache is still handled by Catalyst and Couchdb)

### Go live with a release
- Login to the AWS Management Console, and navigate to Elastic Beanstalk, and then to the `website` Application.
    - Swap the URL between the pre-production environment and the current production environment
    - After making sure the new production environment is working, wait until the DNS TTL passes on Nginx before shutting down the previous production environment

### Website post-release checklist

After production is stable for a few days, tear down unused resources.
* Elastic Beanstalk environment from the previous release from the EB console:
    * wormbase-website
    * wormbase-search
* AWS EC2 console, terminate the ACeDB instance from the previous release
* Clean up snapshots as appropriate
* Coordinate with REST API development to tear down resources that the API depends on



### Hotfix production environment

- Grant permission to the instance by attaching the `wb-catalyst-beanstalk-ec2-role`.

- Prior to applying the hotfix, ensure you are at the appropriate git branch for production, such as `release/273`.

- Then run the following commands from the `website` repo:

	```console
	VERSION=[GIT_TAG_TO_BE_CREATED] make release  # the tag should look like WS273.1
	make production-deploy // can be used to recover from most failed EB
	```

	Note: the makefile passes in lots of variables to EB, such as cfg file versions. These config files can be refered to by version, and edited/referenced in the EB web console.

### Production Deployment without AWS Beanstalk

For instances not managed by Beanstalk, deployment can be performed with:

- Checkout the latest of the release branch, such as `release/273`

- Ensure port 5000 is available, and run:

```console
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
