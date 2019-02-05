-include *.mk

WS_VERSION ?= $(shell cat wormbase.conf | sed -rn 's|wormbase_release.*(WS[0-9]+).*|\1|p')
LOWER_WS_VERSION ?= $(shell echo ${WS_VERSION} | tr A-Z a-z)
CATALYST_PORT ?= 9013

export GOOGLE_CLIENT_ID=$(shell cat credentials/google/client_id.txt)
export GOOGLE_CLIENT_SECRET=$(shell cat credentials/google/client_secret.txt)
export GITHUB_TOKEN=$(shell cat credentials/github_token.txt)
export JWT_SECRET="$(shell cat credentials/jwt_secret.txt)"

.PHONY: bare-dev-start
bare-dev-start:
	./script/wormbase_server.pl -p $(CATALYST_PORT) -d -r

.PHONY: bare-starman-start
bare-starman-start:
	./script/wormbase-daemon.sh

.PHONY: env
env:
	docker build -t wormbase/website-env -f docker/Dockerfile.env .

.PHONY: dev-start
dev-start:
	docker run -it \
		-v ${PWD}:/usr/local/wormbase/website \
		-v /usr/local/wormbase/website-shared-files/html:/usr/local/wormbase/website-shared-files/html \
		-v /usr/local/wormbase/services:/usr/local/wormbase/services \
		-v /usr/local/wormbase/databases:/usr/local/wormbase/databases \
		--network=wb-network \
		-p ${CATALYST_PORT}:5000 \
		-e ACEDB_HOST=acedb \
		-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
		-e GOOGLE_CLIENT_ID=$(GOOGLE_CLIENT_ID) \
		-e GOOGLE_CLIENT_SECRET=$(GOOGLE_CLIENT_SECRET) \
		-e GITHUB_TOKEN=$(GITHUB_TOKEN) \
		-e JWT_SECRET=$(JWT_SECRET) \
		wormbase/website-env

.PHONY: env-bash
env-bash:
	docker run -it \
		--entrypoint /bin/bash \
		-v ${PWD}:/usr/local/wormbase/website \
		-v /usr/local/wormbase/website-shared-files/html:/usr/local/wormbase/website-shared-files/html \
		-v /usr/local/wormbase/services:/usr/local/wormbase/services \
		-v /usr/local/wormbase/databases:/usr/local/wormbase/databases \
		--network=wb-network \
		-p ${CATALYST_PORT}:5000 \
		-e ACEDB_HOST=acedb \
		-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
		-e GOOGLE_CLIENT_ID=$(GOOGLE_CLIENT_ID) \
		-e GOOGLE_CLIENT_SECRET=$(GOOGLE_CLIENT_SECRET) \
		-e GITHUB_TOKEN=$(GITHUB_TOKEN) \
		-e JWT_SECRET=$(JWT_SECRET) \
		wormbase/website-env

.PHONY: build
build:
	(cd client/ && yarn install --frozen-lockfile && yarn run build)  # build JS and CSS
	docker build -t wormbase/website -f docker/Dockerfile .

.PHONY: build-start
build-start:
	docker run -it \
		-v /usr/local/wormbase/website-shared-files/html:/usr/local/wormbase/website-shared-files/html \
		-v /usr/local/wormbase/services:/usr/local/wormbase/services \
		-v /usr/local/wormbase/databases:/usr/local/wormbase/databases \
		-v ${PWD}/logs:/usr/local/wormbase/website/logs \
		--network=wb-network \
		-p ${CATALYST_PORT}:5000 \
		-e ACEDB_HOST=acedb \
		-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
		-e GOOGLE_CLIENT_ID=$(GOOGLE_CLIENT_ID) \
		-e GOOGLE_CLIENT_SECRET=$(GOOGLE_CLIENT_SECRET) \
		-e GITHUB_TOKEN=$(GITHUB_TOKEN) \
		-e JWT_SECRET=$(JWT_SECRET) \
		wormbase/website

.PHONY: build-bash
build-bash:
	docker run -it \
		--entrypoint /bin/bash \
		-v /usr/local/wormbase/website-shared-files/html:/usr/local/wormbase/website-shared-files/html \
		-v /usr/local/wormbase/services:/usr/local/wormbase/services \
		-v /usr/local/wormbase/databases:/usr/local/wormbase/databases \
		-v ${PWD}/logs:/usr/local/wormbase/website/logs \
		--network=wb-network \
		-p ${CATALYST_PORT}:5000 \
		-e ACEDB_HOST=acedb \
		-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
		-e GOOGLE_CLIENT_ID=$(GOOGLE_CLIENT_ID) \
		-e GOOGLE_CLIENT_SECRET=$(GOOGLE_CLIENT_SECRET) \
		-e GITHUB_TOKEN=$(GITHUB_TOKEN) \
		-e JWT_SECRET=$(JWT_SECRET) \
		wormbase/website

.PHONY: build-run-test
build-run-test:
	docker run -i \
		-a stdout \
		--entrypoint "" \
		-v /usr/local/wormbase/website-shared-files/html:/usr/local/wormbase/website-shared-files/html \
		-v /usr/local/wormbase/services:/usr/local/wormbase/services \
		-v /usr/local/wormbase/databases:/usr/local/wormbase/databases \
		-v ${PWD}/logs:/usr/local/wormbase/website/logs \
		--network=wb-network \
		-p ${CATALYST_PORT}:5000 \
		-e ACEDB_HOST=acedb \
		-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
		-e GOOGLE_CLIENT_ID=$(GOOGLE_CLIENT_ID) \
		-e GOOGLE_CLIENT_SECRET=$(GOOGLE_CLIENT_SECRET) \
		-e GITHUB_TOKEN=$(GITHUB_TOKEN) \
		-e JWT_SECRET=$(JWT_SECRET) \
		wormbase/website \
		/bin/bash -c "API_TESTS=1 perl t/api.t; perl t/rest.t"

.PHONY: eb-local-run
eb-local-run: CATALYST_APP ?= staging

eb-local-run:
	 @eb local run \
		--envvars APP=${CATALYST_APP},AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID},AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY},GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID},GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET},GITHUB_TOKEN=${GITHUB_TOKEN},JWT_SECRET='${JWT_SECRET}'

.PHONY: eb-setenv
eb-setenv:
	@eb setenv \
		APP=${CATALYST_APP} \
		AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
		AWS_SECRET_KEY=${AWS_SECRET_ACCESS_KEY} \
		AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
		GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID} \
		GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET} \
		GITHUB_TOKEN=${GITHUB_TOKEN} \
		JWT_SECRET='${JWT_SECRET}'

.PHONY: eb-create
eb-create: CATALYST_APP ?= production
eb-create: CNAME ?= wormbase-website-preproduction
eb-create: EB_ENV_NAME ?= wormbase-website-${LOWER_WS_VERSION}
eb-create:
	@eb create ${EB_ENV_NAME} --cfg v1.3 --cname ${CNAME} --keyname search-admin --envvars APP=${CATALYST_APP},AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID},AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY},GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID},GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET},GITHUB_TOKEN=${GITHUB_TOKEN},JWT_SECRET='${JWT_SECRET}'

.PHONY: eb-create-staging
eb-create-staging:
	CATALYST_APP=staging EB_ENV_NAME=wormbase-website-staging CNAME=wormbase-website-staging $(MAKE) eb-create

.PHONY: dockerrun-latest
dockerrun-latest:
	@sed -i -r 's/website:[^"]+/website:'"latest"'/g' Dockerrun.aws.json


.PHONY: staging-deploy
staging-deploy:
	eb use wormbase-website-staging
	CATALYST_APP=staging $(MAKE) eb-setenv
	eb deploy --region us-east-1 --timeout 10
	eb tags --delete Purpose
	eb tags --add Purpose=staging

.PHONY: release
release: VERSION ?= ${WS_VERSION}
release:
	VERSION=${VERSION} ./release.sh

.PHONY: production-deploy
production-deploy:
	eb use wormbase-website-${LOWER_WS_VERSION}  # assuming rolling update
	CATALYST_APP=production $(MAKE) eb-setenv
	eb deploy --region us-east-1 --timeout 10
	eb tags --delete Purpose
	eb tags --add Purpose=production
