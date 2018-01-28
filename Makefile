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
	fly -t $(CI_TARGET) trigger-job -j $(PIPELINE_NAME)/$(PIPELINE_NAME)
	fly -t $(CI_TARGET) watch -j $(PIPELINE_NAME)/$(PIPELINE_NAME)
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
	fly -t dev login -n dev -c https://ci.correia.io

watch-pipeline:
	fly -t $(CI_TARGET) watch -j $(PIPELINE_NAME)/$(PIPELINE_NAME)
.PHONY: watch-pipeline

destroy-pipeline:
	fly -t $(CI_TARGET) destroy-pipeline -p $(PIPELINE_NAME)
.PHONY: destroy-pipeline

docs:
	grip -b




