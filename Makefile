plan: ## terraform plan
	terraform plan

apply: ## terraform apply
	terraform apply

login-aws: OIDC-CLIENT-ID=0oa7at3tgywbIKdo0697
login-aws: ## login to aws via Okta
	okta-aws-cli --write-aws-credentials \
		--oidc-client-id=$(OIDC-CLIENT-ID) \
		--org-domain=karmanplus-ext.okta.com \
		--open-browser

login-tfc: ## login to teraform for API key
	terraform login

aws-id: ## aws identity
	aws sts get-caller-identity
