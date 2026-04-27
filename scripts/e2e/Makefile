.PHONY: e2e-up e2e-down e2e-test e2e-seed

COMPOSE := docker compose -f ../../deploy/compose.local.yaml

e2e-up:
	$(COMPOSE) up -d
	@echo "Waiting 20s for services to settle..."
	@sleep 20

e2e-down:
	$(COMPOSE) down

e2e-seed:
	cd ../.. && python -m scripts.e2e.seed_user

e2e-test: e2e-seed
	cd ../.. && python -m scripts.e2e.full_writing_flow
