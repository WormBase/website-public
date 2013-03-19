#!/bin/bash
# This webhook fires when /rest/admin/webhook
# is called with a JSON payload with single
# top-level key of "payload"

# To test the webhook URL and this util script:
# curl -H "Content-Type: application/json" -w "%{http_code} %{url_effective}\\n  --data @update_and_restart_sample_data.json -X POST http://yoursite:port/rest/admin/webhook

# To test the webhook service at Github, this
# script and will need to be on staging.wormbase.org
# with the application running.

echo "GitHub webhook is calling!"


APP_PATH=$1
cd $APP_PATH

LOGFILE=$APP_PATH/logs/webhook_restarter.log
exec > $LOGFILE 2>&1

echo "  Our app is at ${APP_PATH}."

# Do we have a suitable ENV file in order of priority? Source it.
if [ -e /usr/local/wormbase/wormbase.env ]
then
    source /usr/local/wormbase/wormbase.env
fi

if [ -e $APP_PATH/../wormbse.env ]
then
    source $APP_PATH/../wormbase.env
fi

if [ -e $APP_PATH/wormbase.env ]
then 
    source $APP_PATH/wormbase.env
fi

echo "    1. checking out the staging branch ..."
echo "    2. fetching head ..."
git checkout staging
#git pull origin staging
git pull

echo "    3. stopping the starman service ..."
./script/wormbase-init.sh stop

echo "    4. restarting starman ..."
./script/wormbase-init.sh start
echo "    --  And we're back! --"

echo '

                         oooo$$$$$$$$$$$$oooo
                      oo$$$$$$$$$$$$$$$$$$$$$$$$o
                   oo$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$o         o$   $$ o$
   o $ oo        o$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$o       $$ $$ $$o$
oo $ $ "$      o$$$$$$$$$    $$$$$$$$$$$$$    $$$$$$$$$o       $$$o$$o$
"$$$$$$o$     o$$$$$$$$$      $$$$$$$$$$$      $$$$$$$$$$o    $$$$$$$$
  $$$$$$$    $$$$$$$$$$$      $$$$$$$$$$$      $$$$$$$$$$$$$$$$$$$$$$$
  $$$$$$$$$$$$$$$$$$$$$$$    $$$$$$$$$$$$$    $$$$$$$$$$$$$$  """$$$
   "$$$""""$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$     "$$$
    $$$   o$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$     "$$$o
   o$$"   $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$       $$$o
   $$$    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$" "$$$$$$ooooo$$$$o
  o$$$oooo$$$$$  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$   o$$$$$$$$$$$$$$$$$
  $$$$$$$$"$$$$   $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$     $$$$""""""""
 """"       $$$$    "$$$$$$$$$$$$$$$$$$$$$$$$$$$$"      o$$$
            "$$$o     """$$$$$$$$$$$$$$$$$$"$$"         $$$
              $$$o          "$$""$$$$$$""""           o$$$
               $$$$o                                o$$$"
                "$$$$o      o$$$$$$o"$$$$o        o$$$$
                  "$$$$$oo     ""$$$$o$$$$$o   o$$$$""
                     ""$$$$$oooo  "$$$o$$$$$$$$$"""
                        ""$$$$$$$oo $$$$$$$$$$
                                """"$$$$$$$$$$$
                                    $$$$$$$$$$$$
                                     $$$$$$$$$$"
                                      "$$$""  



'