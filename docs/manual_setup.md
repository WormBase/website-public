Manual Setup Guide for WormBase Website
=================================

It is easier and recommended to setup environments using docker and compose as described in the [README.md](../README.md).

The instructions for manual setup is here for reference, in case of troubleshooting.


Installation
------------

Execute the following commands in a BASH terminal:

    git clone https://github.com/WormBase/website-public.git
    cd wormbase
    git submodule init
    git submodule update
    export approot=`pwd`
    perl Makefile.PL FIRST_MAKEFILE=MakefilePL.mk
    make installdeps

Then, setup githook to automatically re-build the static assets _after checking out a branch_

    # Before setting up the automation,
    # run the following commands to ensure static assets can be built manually without error
    cd client/
    npm install  # alternatively, yarn install
    npm run build  # alternatively, yarn run build

    yarn --version  # check if Yarn (https://yarnpkg.com) is installed, install it if necessary

    # Setup githook that automates static asset re-build
    cd ..  # ensure you are at project root
    ln -s ../../githooks/post-checkout .git/hooks/post-checkout

- **Note**: **Only** works for checking out a branch. If you modify a JS or CSS file, or if you merge in changes involving JS or CSS, you still need to manually re-build with `npm install` (or `yarn install`) and `npm run build` (or `yarn run build`).
- `yarn` is mostly equivalent to `npm`. Yarn is required here, because `yarn install` is faster than `npm install`, hence can be run frequently, such as after `git checkout`.


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
**First, build the static assets:**

    cd client/
    npm install  # alternatively, yarn install
    npm run build  # alternatively, yarn run build

- **Note**: You might see `npm install` and `npm run build` several times in this README. Here is some explanation:
    - The former needs to be re-run when and **only when** new (devD/d)ependencies are declared in client/package.json
    - The latter needs to be re-run when and **only when** a JS, CSS, or image file is modified
    - It’s always safe to do either command any time during development
    - The client/mode_modules and client/build folder contain only derived/auto-generated content. The client/node_modules folder is created and modified by `npm install`. the client/build folder is created and modified by `npm run build`. Both are considered safe to delete and recreate by calling the respective command during development. (So please don’t modify content of the folder manually, as the change won’t persist).
- **Note**: If you have setup a **post-checkout** githook to automate static asset re-build, you may skip this step when and **only when you checkout a branch**. This **does not help**, if you modify a JS or CSS file, or if you merge in changes involving JS or CSS. In those cases, you still need to manually re-build with `npm install` (or `yarn install`) and `npm run build` (or `yarn run build`).
- **Note**: If you are making changes to JS, CSS and images, you may want to automate and speed up the re-build step with instructions below to Setup development enviroment for JS and CSS development.

**Then, to run the app using the built-in Catalyst server:**

    # ensure you are at project root (for example `cd ..` if necessary)
    ./script/wormbase_server.pl -p 8000 -r -d

- **-p** port
- **-r** auto restart server, when change in code is detected
- **-d** debug

(Additional hightly recommended) Setup development enviroment for JS and CSS development
-----------------------------------------------------
By default, client-side assets (such as JS, CSS, and images) require a full re-build every time a change is made. This step is slow and requires the developer to manually enter `npm run build`.

**During development**, you might want to automate the process and speed things up. To do so, you can enable automatic incremental build by running a Webpack Dev Server. Catalyst server is configured to load static assets from the Webpack Dev Server (if it detects one) instead of the client/build/ folder in the local files system. Webpack Dev Server re-builds the assets when source code is modified.

**Note**: the webpack dev server does **not** modify the content in client/build (but only re-build and serve what is memory). To change the content, you will need to run `npm run build`.

To start Webpack dev server:

* On the same machine where Catalyst server is running, choose a free port MY_PORT_NUMBER (
different from the port that runs your Catalyst server). Then:

```
    cd client/
    PORT=[MY_PORT_NUMBER] HOST=[MY_HOST_URL] npm run start
```

* In wormbase_local.conf, set the URL of Webpack dev server (such as):

```
    webpack_dev_server = "http://dev.wormbase.org:[MY_PORT_NUMBER]"
```

Prior to deployment
----------------------
Re-build the static assets:

    cd client/
    npm install
    npm run build


Running the application via Starman
-----------------------------------

    starman --port 8000 --workers 10 wormbase.psgi


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
