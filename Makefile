.DEFAULT_GOAL = plan

export TF_LOG ?= TRACE
export TF_LOG_PATH := /tmp/tf.log

export ACCOUNT_ID = 975050288432
export REGION = us-east-2

plan: ## terraform plan
	terraform plan

apply: ## terraform apply
	terraform apply

update: ## update/init terraform modules
	terraform init

aws-id: ## aws identity
	aws sts get-caller-identity

# impure needed to read the above env var
dev: export NIXPKGS_ALLOW_UNFREE=1
dev: ## nix develop
	nix develop --impure

image: ## create a docker image for aws lambda
	cd src && make image

image-update: image ## create a docker image for aws lambda
	docker tag aip-lambda:latest $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/aip-lambda:latest
	aws ecr get-login-password --region $(REGION) \
        | docker login --username AWS --password-stdin $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com
	docker push $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/aip-lambda:latest

lambda-update: image-update ## update lambda after image-push
	aws lambda update-function-code \
	--function-name=sns2s3 \
	--image-uri=$(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/aip-lambda:latest

	aws lambda update-function-code \
	--function-name=s32rds \
	--image-uri=$(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/aip-lambda:latest


clean: ## clean
	find . -name \*~ | xargs rm -f
	rm -f *.zip

clean-prune: ## docker system prune
	docker system prune --all

help: ## help
	@grep -E '^[a-zA-Z00-9_%-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}'

login-aws: ## login to aws to fetch/refresh token
	PYTHONPATH= aws sso login # AdministratorAccess-975050288432

terraform-update:; terraform init

sns-publish: ## publish a message to the aip sns-topic
	aws sns publish \
	--topic-arn "arn:aws:sns:us-east-2:975050288432:aip" \
	--message file://etc/msg.json

rds-db: export PGUSER = $(shell aws secretsmanager get-secret-value --secret-id=db-user|awk '{print $$4}')
rds-db: export PGPASSWORD = $(shell aws secretsmanager get-secret-value --secret-id=db-password|awk '{print $$4}')
rds-db: export PGHOST = aip.c7eaoykysgcc.us-east-2.rds.amazonaws.com
rds-db: ## connect to the postgresql instance
	psql aip

sqitch-init: ## initialize sqitch
	mkdir -p schema
	cd schema && make init
