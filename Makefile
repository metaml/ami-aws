.DEFAULT_GOAL = plan

export TF_LOG ?= TRACE
export TF_LOG_PATH = /tmp/tf.log

plan: ## terraform plan
	terraform plan

apply: ## terraform apply
	terraform apply

update: ## update terraform modules
	terraform init

#token-tfc: ## terraform token for CLI access
#	terraform login

aws-id: ## aws identity
	aws sts get-caller-identity

aws-token: ## refresh aws access token
	aws sso login --profile AdministratorAccess-975050288432

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
