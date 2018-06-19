FROM wormbase/website-env

RUN mkdir /website

COPY . /website/

WORKDIR /website

CMD chmod u+x /website/

# Define default command.
CMD ["perl script/wormbase_server.pl -p 8000 -r -d"]
