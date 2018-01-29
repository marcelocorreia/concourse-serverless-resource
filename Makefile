REPOSITORY=concourse-serverless-resource
CONTAINER=concourse-serverless-resource
NAMESPACE=marcelocorreia
VERSION=$(shell cat version)
PIPELINE_NAME=$(REPOSITORY)
CI_TARGET=dev

git-push:
	git add .; git commit -m "Pipeline WIP"; git push

docker-build:
	cat Dockerfile | sed  's/ARG version=".*"/ARG version="$(VERSION)"/' > /tmp/Dockerfile.tmp
	cat /tmp/Dockerfile.tmp > Dockerfile
	rm /tmp/Dockerfile.tmp
	docker build -t $(NAMESPACE)/$(CONTAINER):latest .
.PHONY: build

docker-shell:
	docker run --rm -it $(NAMESPACE)/$(CONTAINER):latest bash

set-pipeline: git-push
	fly -t $(CI_TARGET) set-pipeline \
		-n -p $(PIPELINE_NAME) \
		-c pipeline.yml \
		-l $(HOME)/.ssh/ci-credentials.yml \
		-v git_repo_url=git@github.com:$(NAMESPACE)/$(REPOSITORY).git \
        -v container_fullname=$(NAMESPACE)/$(CONTAINER) \
        -v container_name=$(CONTAINER) \
		-v git_repo=$(REPOSITORY) \
        -v git_branch=master \
        -v release_version=$(VERSION)

	fly -t $(CI_TARGET) unpause-pipeline -p $(PIPELINE_NAME)
.PHONY: set-pipeline

test-pipeline: git-push
	fly -t $(CI_TARGET) set-pipeline \
    		-n -p serverless-test \
    		-c test-pipeline.yml \
    		-l $(HOME)/.ssh/ci-credentials.yml \
    		-v git_repo_url=git@github.com:$(NAMESPACE)/$(REPOSITORY).git \
            -v container_fullname=$(NAMESPACE)/$(CONTAINER) \
            -v container_name=$(CONTAINER) \
    		-v git_repo=$(REPOSITORY) \
            -v git_branch=master \
            -v release_version=$(VERSION)

pipeline-login:
	fly -t $(CI_TARGET) login -n main -c http://localhost:8080

watch-pipeline:
	fly -t $(CI_TARGET) watch -j $(PIPELINE_NAME)/$(PIPELINE_NAME)
.PHONY: watch-pipeline

destroy-pipeline:
	fly -t $(CI_TARGET) destroy-pipeline -p $(PIPELINE_NAME)
.PHONY: destroy-pipeline

docs:
	grip -b

concourse-pull:
	cd concourse && docker-compose pull

concourse-up:
	cd concourse && CONCOURSE_EXTERNAL_URL=http://localhost:8080 docker-compose up -d

concourse-down:
	cd concourse && docker-compose down

concourse-stop:
	cd concourse && docker-compose stop

concourse-start:
	cd concourse && docker-compose start

concourse-logs:
	cd concourse && docker-compose logs -f

concourse-keys:
	@[ -f ./concourse/keys ] && echo ./concourse/keys folder found || $(call create-concourse-keys)


define create-concourse-keys
	echo "Creating Concourse keys"
	mkdir -p ./concourse/keys/web ./concourse/keys/worker;
	ssh-keygen -t rsa -f ./concourse/keys/web/tsa_host_key -N ''
	ssh-keygen -t rsa -f ./concourse/keys/web/session_signing_key -N ''
	ssh-keygen -t rsa -f ./concourse/keys/worker/worker_key -N ''
	cp ./concourse/keys/worker/worker_key.pub ./concourse/keys/web/authorized_worker_keys
	cp ./concourse/keys/web/tsa_host_key.pub ./concourse/keys/worker
endef
