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

Running the application
-----------------------

To run the app using the built-in Catalyst server:

    script/wormbase_server.pl -p 8000

Running the application via Starman
-----------------------------------

    starman --port 8000 --workers 10 wormbase.psgi


Develop and deploy JavaScript/Client-Side application
-----------------------------------------------------

To build the static assets **for deployment**:

    cd client/
    npm run build

To run Webpack dev server with hot module replacement **for development**:

* Ensure the Catalyst server is running. Choose a free port MY_PORT_NUMBER (
different from the port that runs your Catalyst server). Then:

```
    cd client/
    PORT=[MY_PORT_NUMBER] npm run start
```

* In wormbase_local.conf, let Catalyst server know to Webpack dev server to
use for static assets

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
