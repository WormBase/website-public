#!/bin/bash
# This webhook fires when /rest/admin/webhook
# is called with a JSON payload with single
# top-level key of "payload"

# To test the webhook URL and this util script:
# curl -H "Content-Type: application/json" -w "%{http_code} %{url_effective}\\n" 
#     \ --data @update_and_restart_sample_data.json
#     \ -X POST http://yoursite:port/rest/admin/webhook

# To test the webhook service at Github, this
# script and will need to be on staging.wormbase.org
# with the application running.

APP_PATH=$1
cd $APP_PATH

# Do we have a suitable ENV file in order of priority? Source it.
source /usr/local/wormbase/wormbase.env
source ../wormbase.env
source $APP_PATH/wormbase.env

git checkout staging
#git pull origin staging
git pull
./script/wormbase-init.sh stop
./script/wormbase-init.sh start