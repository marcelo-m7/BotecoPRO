# ============================================================
# BotecoPRO – Development Makefile
# ============================================================
COMPOSE := docker compose -f infrastructure/docker/docker-compose.yml --env-file .env
FLUTTER := cd apps/mobile &&

.PHONY: help setup up down logs restart shell-odoo shell-db \
        flutter-get flutter-run flutter-test flutter-analyze \
        odoo-test odoo-lint website-dev website-build \
        test lint

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ---- Environment setup -------------------------------------

setup: ## First-time setup: copy .env.example, pull images
	@test -f .env || (cp .env.example .env && echo "Created .env – please fill in passwords before running 'make up'")
	$(COMPOSE) pull

# ---- Docker / Odoo -----------------------------------------

up: ## Start Odoo + PostgreSQL
	$(COMPOSE) up -d

down: ## Stop all services
	$(COMPOSE) down

logs: ## Tail logs (all services)
	$(COMPOSE) logs -f

restart: ## Restart Odoo only
	$(COMPOSE) restart odoo

shell-odoo: ## Open shell inside Odoo container
	$(COMPOSE) exec odoo bash

shell-db: ## Open psql inside PostgreSQL container
	$(COMPOSE) exec db psql -U $${POSTGRES_USER:-odoo} $${POSTGRES_DB:-botecopro_dev}

# ---- Flutter -----------------------------------------------

flutter-get: ## Run flutter pub get
	$(FLUTTER) flutter pub get

flutter-run: ## Run Flutter app (debug)
	$(FLUTTER) flutter run

flutter-analyze: ## Run flutter analyze
	$(FLUTTER) flutter analyze

flutter-test: ## Run Flutter tests
	$(FLUTTER) flutter test

# ---- Odoo addons -------------------------------------------

odoo-lint: ## Lint Python code in addons/
	python3 -m ruff check addons/ || echo "ruff not installed – run: pip install ruff"

odoo-test: ## Run Odoo addon tests (requires running Odoo container)
	$(COMPOSE) exec odoo odoo --test-enable --stop-after-init \
	  --database=$${ODOO_DB:-botecopro_dev} \
	  --addons-path=/mnt/extra-addons

# ---- Website -----------------------------------------------

website-dev: ## Start website dev server
	cd apps/website && npm run dev

website-build: ## Build website
	cd apps/website && npm run build

# ---- Aggregates --------------------------------------------

test: flutter-test odoo-test ## Run all tests

lint: flutter-analyze odoo-lint ## Run all linters
