REPOSITORY=concourse-serverless-resource
CONTAINER=concourse-serverless-resource
NAMESPACE=marcelocorreia
VERSION=$(shell git show version:version)
PIPELINE_NAME=$(REPOSITORY)
CI_TARGET?=main
CI_TEAM_NAME?=main
CI_CREDS_FILE?=$(HOME)/.ssh/ci-credentials.yml
CONCOURSE_EXTERNAL_URL?=http://localhost:8080
#CONCOURSE_EXTERNAL_URL?=https://ci.correia.io

# Git
git-push:
	git add .; git commit -m "Pipeline WIP"; git push

# Docker
docker-build:
	cat Dockerfile | sed  's/ARG version=".*"/ARG version="$(VERSION)"/' > /tmp/Dockerfile.tmp
	cat /tmp/Dockerfile.tmp > Dockerfile
	rm /tmp/Dockerfile.tmp
	docker build -t $(NAMESPACE)/$(CONTAINER):dev .
.PHONY: docker-build

docker-shell:
	docker run --rm -it $(NAMESPACE)/$(CONTAINER):dev bash
.PHONY: docker-shell

# Pipeline
pipeline-set: git-push
	fly -t $(CI_TARGET) set-pipeline \
		-n -p $(PIPELINE_NAME) \
		-c pipeline.yml \
		-l $(CI_CREDS_FILE) \
		-v git_repo_url=git@github.com:$(NAMESPACE)/$(REPOSITORY).git \
        -v container_fullname=$(NAMESPACE)/$(CONTAINER) \
        -v container_name=$(CONTAINER) \
		-v git_repo=$(REPOSITORY) \
        -v git_branch=master \
        -v release_version=$(VERSION)

	fly -t $(CI_TARGET) unpause-pipeline -p $(PIPELINE_NAME)

pipeline-login:
	@fly -t $(CI_TARGET) login -n $(CI_TEAM_NAME) -c $(CONCOURSE_EXTERNAL_URL)

pipeline-watch:
	fly -t $(CI_TARGET) watch -j $(PIPELINE_NAME)/$(PIPELINE_NAME)

pipeline-destroy:
	fly -t $(CI_TARGET) destroy-pipeline -p $(PIPELINE_NAME)

# Concourse
concourse-pull:
	$(call concourse_compose,pull)

concourse-up: _concourse-keys
	$(call concourse_compose,up -d)

concourse-down:
	$(call concourse_compose,down)

concourse-stop:
	$(call concourse_compose,stop)

concourse-start:
	$(call concourse_compose,start)

concourse-logs:
	$(call concourse_compose,logs -f)

_concourse-keys:
	@if [ ! -d ./concourse/keys ];then \
 		echo "Creating Concourse keys"; \
        mkdir -p ./concourse/keys/web ./concourse/keys/worker; \
        ssh-keygen -t rsa -f ./concourse/keys/web/tsa_host_key -N ''; \
        ssh-keygen -t rsa -f ./concourse/keys/web/session_signing_key -N ''; \
        ssh-keygen -t rsa -f ./concourse/keys/worker/worker_key -N ''; \
        cp ./concourse/keys/worker/worker_key.pub ./concourse/keys/web/authorized_worker_keys; \
        cp ./concourse/keys/web/tsa_host_key.pub ./concourse/keys/worker; \
	fi

deploy-hello:
	cd lambda/hello && serverless deploy -s labs

# Defined Functions
define concourse_compose
	cd concourse && CONCOURSE_EXTERNAL_URL=$(CONCOURSE_EXTERNAL_URL) docker-compose $1
endef

