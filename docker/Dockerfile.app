FROM wormbase/website-env

RUN mkdir -p /usr/local/wormbase/website

COPY . /usr/local/wormbase/website/

RUN chmod u+x /usr/local/wormbase/website

WORKDIR /usr/local/wormbase/website

# Define default command.
CMD ["/bin/bash", "-c", "./script/wormbase_server.pl -p 5000 -r -d"]
