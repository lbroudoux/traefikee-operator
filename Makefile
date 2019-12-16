
TAG_NAME := $(shell git tag -l --contains HEAD)
SHA := $(shell git rev-parse HEAD)
VERSION := $(if $(TAG_NAME),$(TAG_NAME),$(SHA))

OF_RELEASE_VERSION=v0.13.0

default: tools check test-ci build

tools: /usr/local/bin/operator-sdk  /usr/local/bin/operator-courier ## Download toolings

/usr/local/bin/operator-sdk:
	curl -o /usr/local/bin/operator-sdk -L https://github.com/operator-framework/operator-sdk/releases/download/${OF_RELEASE_VERSION}/operator-sdk-${OF_RELEASE_VERSION}-x86_64-linux-gnu
	chmod +x /usr/local/bin/operator-sdk

/usr/local/bin/operator-courier:
	pip3 install operator-courier

build: tools ## Build the operator
	operator-sdk build containous/traefikee-operator:$(VERSION)

check: ## Check the operator
	operator-courier verify --ui_validate_io deploy/olm-catalog/traefikee-operator

test-ci:
	molecule test -s test-local

docker-push:
	echo "$(DOCKER_PASSWORD)" | docker login -u "$(DOCKER_USERNAME)" --password-stdin
	docker push containous/traefikee-operator:$(VERSION)

## Help
help: ## this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)


.PHONY: tools check test-ci build help
