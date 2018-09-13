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

.PHONY: build-env
build-env:
	docker build -t wormbase/website-env -f docker/Dockerfile.env .

.PHONY: build-app
build-app:
	docker build -t wormbase/website-app -f docker/Dockerfile.app .

.PHONY: dev-start
dev-start:
	docker run -it \
		-v ${PWD}:/usr/local/wormbase/website \
		-v /usr/local/wormbase/website-shared-files/html:/usr/local/wormbase/website-shared-files/html \
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

.PHONY: bash-start
bash-start:
	docker run -it \
		-v ${PWD}:/usr/local/wormbase/website \
		-v /usr/local/wormbase/website-shared-files/html:/usr/local/wormbase/website-shared-files/html \
		--network=wb-network \
		-p ${CATALYST_PORT}:5000 \
		-e ACEDB_HOST=acedb \
		-e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
		-e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
		-e GOOGLE_CLIENT_ID=$(GOOGLE_CLIENT_ID) \
		-e GOOGLE_CLIENT_SECRET=$(GOOGLE_CLIENT_SECRET) \
		-e GITHUB_TOKEN=$(GITHUB_TOKEN) \
		-e JWT_SECRET=$(JWT_SECRET) \
		wormbase/website-env /bin/bash

.PHONY: app-start
app-start:
	docker run -it \
		-v /usr/local/wormbase/website-shared-files/html:/usr/local/wormbase/website-shared-files/html \
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
		wormbase/website-app
