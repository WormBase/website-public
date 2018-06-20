FROM wormbase/website-env

RUN mkdir /usr/local/wormbase/website

COPY . /usr/local/wormbase/website/

WORKDIR /usr/local/wormbase/website

CMD chmod u+x /usr/local/wormbase/website

# Define default command.
CMD ["/bin/bash", "-c", "perl script/wormbase_server.pl -p 8000 -r -d"]
