.DEFAULT_GOAL = plan

export TF_LOG ?= TRACE
export TF_LOG_PATH := /tmp/tf.log

plan: ## terraform plan
	terraform plan

apply: ## terraform apply
	terraform apply

update: ## update terraform modules
	terraform init

aws-id: ## aws identity
	aws sts get-caller-identity

# impure needed to read the above env var
dev: export NIXPKGS_ALLOW_UNFREE=1
dev: ## nix develop
	nix develop --impure

clean: ## clean
	find . -name \*~ | xargs rm -f
	rm -f *.zip

help: ## help
	@grep -E '^[a-zA-Z00-9_%-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}'

init: update ## terraform init

login-aws: ## login to aws to fetch/refresh token
	PYTHONPATH= aws sso login # AdministratorAccess-975050288432

terraform-update:; terraform init

publish-sns: ## publish a message to the aip sns-topic
	aws sns publish \
	--topic-arn "arn:aws:sns:us-east-2:975050288432:aip" \
	--message file://etc/msg.json

linux-aws: ## pull amazon linux (docker) image
	docker pull public.ecr.aws/amazonlinux/amazonlinux:2023

linux-run: ## shell into aws linux
	docker run \
	--interactive \
	--tty \
	--volume $$(pwd)/src/s32rds:/s32rds \
	--security-opt seccomp=unconfined \
	public.ecr.aws/amazonlinux/amazonlinux:2023 \
	/bin/bash

