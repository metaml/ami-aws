.DEFAULT_GOAL = plan

export TF_LOG ?= TRACE
export TF_LOG_PATH := /tmp/tf.log

export ACCOUNT_ID = 975050288432
export REGION = us-east-2

plan: ## terraform plan
	terraform plan

apply: ## terraform apply
	terraform apply

apply-approve: ## terraform apply --auto-approve
	terraform apply --auto-approve

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

image-update: image docker-login ## create a docker image for aws lambda
	docker tag ami-lambda:latest $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/ami-lambda:latest
	docker push $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/ami-lambda:latest

docker-login: ## docker login
	aws ecr get-login-password --region $(REGION) \
	| docker login --username AWS --password-stdin $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com

lambda-update: image-update ## update lambda after image-push
	aws lambda update-function-code \
	--no-cli-pager \
	--function-name=sns2s3 \
	--image-uri=$(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/ami-lambda:latest
	aws lambda update-function-code \
	--no-cli-pager \
	--function-name=s32rds \
	--image-uri=$(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/ami-lambda:latest
	aws lambda update-function-code \
	--no-cli-pager \
	--function-name=analytics \
	--image-uri=$(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/ami-lambda:latest

clean: ## clean
	find . -name \*~ -o -regex '.*#.*' | xargs rm -f
	rm -f *.zip

clean-prune: ## docker system prune
	docker system prune --all --volumes

help: ## help
	@grep -E '^[a-zA-Z00-9_%-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}'

login-aws: ## login to aws to fetch/refresh token
	PYTHONPATH= aws sso login # AdministratorAccess-975050288432

terraform-update:; terraform init

ssh-ec2-private-key: ## copy private key from secretsmanager to ~/.ssh
	aws secretsmanager get-secret-value --secret-id=key-private-openssh --query=SecretString > ~/.ssh/ec2.pem

sns-publish: ## publish a message to the ami sns-topic
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

rsync: HOST = ec2-3-136-167-53.us-east-2.compute.amazonaws.com
rsync: ## rsync ami to ec2 instance
	rsync --verbose \
	--archive \
	--compress \
	--delete \
	--progress \
	--rsh='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null' \
	. ec2-3-136-167-53.us-east-2.compute.amazonaws.com:ami-aws
	ssh ami 'cd ami-aws && chown -R root .'
