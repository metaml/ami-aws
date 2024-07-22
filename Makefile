.DEFAULT_GOAL = help

export TF_LOG ?= TRACE
export TF_LOG_PATH = /tmp/tf.log

plan: ## terraform plan
	terraform plan

init: update ## terraform init

update: ## update terraform modules
	terraform init

#token-tfc: ## terraform token for CLI access
#	terraform login

aws-id: ## aws identity
	aws sts get-caller-identity

# impure needed to read the above env var
dev: export NIXPKGS_ALLOW_UNFREE=1
dev: ## nix develop
	nix develop --impure

help: ## help
	@grep -E '^[a-zA-Z00-9_%-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}'


terraform-update:; terraform init
