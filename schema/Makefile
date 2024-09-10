.DEFAULT_GOAL = help

add: NB ?= "add ${OBJ}"
add: ## add a sqitch file: $OBJ required, $NB optional
	sqitch add ${OBJ} --requires schema --note '${NB}'

update: ## modify db schema
	source ./.creds && sqitch deploy db:pg:aip

verify: ## verify db schema
	source ./.creds && sqitch verify db:pg:aip

schema: ## init sqitch schema (second)
	sqitch add schema -n 'schema for aips'

init: ## init sqitch (first)
	sqitch init aip --uri https://github.com/sqitchers/sqitch-intro/ --engine pg

db-create: ## create db (third)
	source ./.creds && createdb --encoding=UTF8 --locale=en_US.UTF-8 aip

db-creds: export PGUSER = $(shell aws secretsmanager get-secret-value --secret-id=db-user|awk '{print $$4}')
db-creds: export PGPASSWORD = $(shell aws secretsmanager get-secret-value --secret-id=db-password|awk '{print $$4}')
db-creds: export PGHOST = aip.c7eaoykysgcc.us-east-2.rds.amazonaws.com
db-creds: ## save db crendentials
	@cp /dev/null .creds \
	&& echo "export PGUSER=$(PGUSER)" >> .creds  \
	&& echo "export PGPASSWORD=$(PGPASSWORD)" >> .creds \
	&& echo "export PGHOST=$(PGHOST)" >> .creds
	@echo ".creds created"

clean: ## clean
	find . -name \*~ | xargs rm -f
	rm -f *.zip

help: ## help
	@grep -E '^[a-zA-Z00-9_%-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-18s\033[0m %s\n", $$1, $$2}'

.PHONY: verify
