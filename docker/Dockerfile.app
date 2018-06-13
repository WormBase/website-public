FROM wormbase/website-env

RUN mkdir /website

COPY . /website/

WORKDIR /website

CMD chmod u+x /website/
