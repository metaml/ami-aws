.DEFAULT_GOAL = help

AWS := PYTHONPATH= aws

add: NB ?= "add ${OBJ}"
add: ## add a sqitch file: $OBJ required, $NB optional
	sqitch add ${OBJ} --requires schema --note '${NB}'

update: ## modify db schema
	source ./.creds && sqitch deploy db:pg:aip-dev

verify: ## verify db schema
	source ./.creds && sqitch verify db:pg:aip-dev

schema: ## init sqitch schema (second)
	sqitch add schema -n 'schema for aip'

init: ## init sqitch (first)
	source ./.creds && sqitch init aip --uri https://github.com/sqitchers/sqitch-intro/ --engine pg

# db-create: ## create db (third)
# 	source ./.creds && createdb --encoding=UTF8 --locale=en_US.UTF-8 aip

db-creds: ## save db crendentials for prod
	cp /dev/null .creds
	echo 'export PGUSER=aip-dev' > .creds
	$(AWS) secretsmanager get-secret-value --secret-id=db-password | head -1 | awk '{ print "export PGPASSWORD="$$4 }' >> .creds
	echo 'export PGHOST=' >> .creds
	@echo ".creds created"

clean: ## clean
	find . -name \*~ | xargs rm -f
	rm -f *.zip

help: ## help
	@grep -E '^[a-zA-Z00-9_%-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}'

.PHONY: verify
