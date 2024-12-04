.DEFAULT_GOAL = help

EC2 ?= ami

install: ## copy configuration.nix to ec2 host $EC2 (default ami)
	scp configuration.nix ${EC2}

rebuild: ## nixos-rebuild switch on $EC2 host
rebuild: install
	ssh ${EC2} nixos-rebuild switch

help: ## help
	@grep -E '^[a-zA-Z00-9_%-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}'
