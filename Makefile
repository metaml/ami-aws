.DEFAULT_GOAL = help

plan: ## terraform plan
	terraform plan

apply: ## terraform apply
	terraform apply

init: ## terraform init
	terraform init

token-aws: OIDC-CLIENT-ID=0oa7at3tgywbIKdo0697
token-aws: ## AWS token for CLI access
	okta-aws-cli --write-aws-credentials \
		--oidc-client-id=$(OIDC-CLIENT-ID) \
		--org-domain=karmanplus-ext.okta.com \
		--open-browser

token-tfc: ## terraform token for CLI access
	terraform login

aws-id: ## aws identity
	aws sts get-caller-identity

dev: ## nix develop
	nix develop

help: ## help
	@grep -E '^[a-zA-Z00-9_%-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}'
