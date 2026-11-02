.PHONY: deps seed run test docs lint check clean

deps:
	dbt deps

seed:
	dbt seed

run:
	dbt run

test:
	dbt test

docs:
	dbt docs generate

lint:
	cd .. && sqlfluff lint --config dbt/.sqlfluff dbt/models dbt/tests

check: deps seed run test lint

clean:
	dbt clean
