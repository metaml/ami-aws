.DEFAULT_GOAL = plan

export TF_LOG ?= TRACE
export TF_LOG_PATH := /tmp/tf.log
export TF_VAR_db_password := $(shell aws secretsmanager get-secret-value --secret-id db-password | awk '{print $$4}')

plan: ## terraform plan
	echo $(TF_VAR_db_password)
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

help: ## help
	@grep -E '^[a-zA-Z00-9_%-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}'

init: update ## terraform init

login-aws: ## login to aws to fetch/refresh token
	PYTHONPATH= aws sso login # AdministratorAccess-975050288432

terraform-update:; terraform init
