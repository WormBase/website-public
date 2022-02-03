WormBase Website Repository
===========================

This repository contains the [WormBase](http://www.wormbase.org) Web application.

**The repository for [WormBase Mobile](http://m.wormbase.org) can be found at [WormBase/website-mobile](https://github.com/WormBase/website-mobile)**

Technical Overview
--------------------------------------------

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

For Devops, we use Docker, docker-compose, Jenkins, AWS Elastic Beanstalk.

Development Environments
--------------------------------------------

*This section describes how to set up a private development environment of the WormBase website.*

### EC2 option (preferred)

Development environment can be setup easily, using a shared development machine and `docker-compose`.

_For Legacy instructions_ that set up without docker or docker-compose, please visit the [Manual Setup Guide](/docs/manual_setup.md).

**Prerequisites:**

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

#### Development Environment Troubleshooting

**`make dev` appears stuck**

The first time that `make dev` runs, it takes longer due to installation of dependencies. Subsequent startup should take a few seconds.

**`stdout` is jumbled**

The `stdout` of docker-compose combines the stdouts of the containers. To make it easier to read, stdout of individual containers can be accessed via `SERVICE=[name_of_service] make console`, where the name of service could be website, webpack, etc as found in [docker-compose.yml](docker-compose.yml) and [docker-compose.dev.yml](docker-compose.dev.yml).

**`docker-compose` cli commands not taking effect**

The Makefile exports user-specific environment variable `COMPOSE_PROJECT_NAME` to allow multiple instances of the development stack to run on the same machine. If you use docker-compose cli directly, please set `COMPOSE_PROJECT_NAME` accordingly to interact with your particular development instance.

**Unable to connect to ACeDB**

ACeDB container isn't started as part the development stack to reduce memory footprint. Instead, we rely on a shared acedb container, which is expected to run on the docker networked `wb-network`. If the shared acedb container is down, instructions to start the shared acedb container is found [here](https://github.com/WormBase/wormbase-architecture/blob/develop/roles/acedb/files/startserver.sh).

**Prettier git pre-commit hook doesn't trigger**

JavaScript dependencies (such as `prettier` and `husky`) need to be installed on the host for code formatting and other git pre-commit hooks to work.

**Compilation failure: You must configure a default store type unless you use exactly one store plugin.**

This problem seems to show up occasionally, when I modify the wormbase_local.conf while the server is running. Try `make dev-down` and then `make dev`, and repeat a few times until the problem resolves itself.

### Local option (experimental)

If a local development environment is preferred, this option would allow you to
setup a barebone development environment, without requiring credentials, such as
those for accessing cloud resources. As a result, some features of the website
will not work in this environment. But it should have enough functionality for UI
development and testing.

**Prerequisites**

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


Contributing
--------------------------------------------

Our development workflow can be found here:

[http://wiki.wormbase.org/index.php/Development_workflow_-_webdev](http://wiki.wormbase.org/index.php/Development_workflow_-_webdev)

Todd Harris (todd@wormbase.org)

Acknowledgements
--------------------------------------------

<a href="https://www.browserstack.com/"><img src="https://www.browserstack.com/images/mail/browserstack-logo-footer.png" alt="BrowserStack" width="120px" /></a>

Thanks to BrowserStack for allowing us to perform interactive cross browser and cross OS testing.
