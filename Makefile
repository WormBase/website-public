CATALYST_PORT ?= 9013

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
		-w=/usr/local/wormbase/website \
		--network=wb-network \
		-p ${CATALYST_PORT}:5000 \
		-e ACEDB_HOST=acedb \
		wormbase/website-env

.PHONY: bash-start
bash-start:
	docker run -it \
		-v ${PWD}:/usr/local/wormbase/website \
		-v /usr/local/wormbase/website-shared-files/html:/usr/local/wormbase/website-shared-files/html \
		-w=/usr/local/wormbase/website \
		--network=wb-network \
		-p ${CATALYST_PORT}:5000 \
		-e ACEDB_HOST=acedb \
		wormbase/website-env /bin/bash
