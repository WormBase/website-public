FROM wormbase/website-env

COPY . /usr/local/wormbase/website/

RUN chmod u+x /usr/local/wormbase/website

WORKDIR /usr/local/wormbase/website

# Define default command.
ENTRYPOINT ["dumb-init", "--", "./script/wormbase-daemon-for-docker.sh"]
