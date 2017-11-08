WormBase Website Repository
===========================

This repository contains the [WormBase](http://www.wormbase.org) Web application.

**The repository for [WormBase Mobile](http://m.wormbase.org) can be found at [WormBase/website-mobile](https://github.com/WormBase/website-mobile)**

Installation
------------

Execute the following commands in a BASH terminal:

    git clone git://github.com/WormBase/website.git wormbase
    cd wormbase
    git submodule init
    git submodule update
    export approot=`pwd`
    perl Makefile.PL
    make installdeps

    cd client/
    npm install
    npm run build

If you did not start off in `/usr/local`, then you can either change the preset paths in the application's configuration files, or alternatively, carry out these two steps:

    sudo -E su
    cd /usr/local
    ln -s $approot

### Dependencies
Most backend dependencies will be installed with `make installdeps`, but `perl Makefile.PL` itself is depending on some prerequisites:

1.  a development environment: Perl, make, gcc & co.
2.  `sudo cpan Module::Install`

On Mac OS X, Perl comes preinstalled. The C development tools are installed from within Xcode, which is free, and then selecting from the menu/dialogs: Xcode -> Preferences... -> Downloads -> Components -> "Command Line Tools" -> "Install".

For client-side application (`client/`), Node.js (>=6) and NPM (>=3) needs to be installed . Once NPM is installed, addition dependencies needs to be installed by running `npm install` command in the `client/` directory.

Run the application in development
-----------------------
First, build the static assets:

    cd client/
    npm install  # install dependencies, only necessary if (devD/d)ependencies in package.json have changed
    npm run build

- **Note**: static assets **need to be re-build** whenever a JS, CSS, or image file is modified
- **Note**: If developing the client-side application, you may want to automate and speed up the re-build step with [Setup client-side development enviroment](#setup-client-side-development-enviroment) below.

Then, to run the app using the built-in Catalyst server:

    script/wormbase_server.pl -p 8000 -r -d

-**-p** port
-**-r** auto restart server, when change in code is detected
-**-d** debug

Prior to deployment
----------------------
Re-build the static assets:

    cd client/
    npm install
    npm run build


Running the application via Starman
-----------------------------------

    starman --port 8000 --workers 10 wormbase.psgi


Setup client-side development enviroment
-----------------------------------------------------
By default, client-side assets (such as JS, CSS, and images) require a full re-build every time a change is made. This step is slow and requires the developer to manually enter `npm run build`.

**During development**, you might want to automate the process and speed things up. To do so, you can enable automatic incremental build by running a Webpack Dev Server. Catalyst server is configured to load static assets from the Webpack Dev Server (if it detects one) instead of the client/build/ folder in the local files system. Webpack Dev Server re-builds the assets when source code is modified.

To start Webpack dev server:

* On the same machine where Catalyst server is running, choose a free port MY_PORT_NUMBER (
different from the port that runs your Catalyst server). Then:

```
    cd client/
    PORT=[MY_PORT_NUMBER] npm run start
```

* In wormbase_local.conf, set the URL of Webpack dev server (such as):

```
    webpack_dev_server = "http://dev.wormbase.org:[MY_PORT_NUMBER]"
```

Unit Testing
------------

We provide two sets of unit tests for the REST API and WormBase Perl API respectively. The tests are based on [Test::More](http://perldoc.perl.org/Test/More.html), they run on a fully populated WormBase database backend, they autonomously start and stop a Catalyst web server (random port between 28,000 and 31,999).

Running REST API tests:

    perl t/rest.t


Running WormBase Perl API tests:

    API_TESTS=1 perl t/api.t

Running WormBase Perl API tests for just the gene class:

    API_TESTS=gene perl t/api.t

Running WormBase Perl API tests with blacklist

    API_TESTS=1 API_TESTS_BLACKLIST=gene:cds perl t/api.t

Comparative Testing
-------------------

For testing GBrowse installations, we provide a test implementation that compares `gbrowse_img` images to a reference set.

Running comparative GBrowse tests:

    perl t/gbrowse.t --base http://dev.wormbase.org:4466/cgi-bin/gb2/gbrowse_img

Creating a reference image set that is used for the comparative tests:

    perl t/gbrowse.t --base http://dev.wormbase.org:4466/cgi-bin/gb2/gbrowse_img --reference

A summary log and a full disclosure of broken URLs is written to the logfile `logs/gbrowse_test.log`.

Contributing
------------

Our development workflow can be found here:

[http://wiki.wormbase.org/index.php/Development_workflow_-_webdev](http://wiki.wormbase.org/index.php/Development_workflow_-_webdev)

Todd Harris (todd@wormbase.org)
