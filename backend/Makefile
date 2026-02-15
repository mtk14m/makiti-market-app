.PHONY: help install dev-install format lint type-check test clean docker-up docker-down migrate upgrade downgrade

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install dependencies
	poetry install

dev-install: ## Install dependencies including dev dependencies
	poetry install --with dev,test

format: ## Format code with black
	poetry run black app tests

lint: ## Lint code with ruff
	poetry run ruff check app tests

type-check: ## Type check with mypy
	poetry run mypy app

test: ## Run tests
	poetry run pytest

test-cov: ## Run tests with coverage
	poetry run pytest --cov=app --cov-report=html --cov-report=term-missing

clean: ## Clean cache and temporary files
	find . -type d -name __pycache__ -exec rm -r {} +
	find . -type f -name "*.pyc" -delete
	find . -type d -name "*.egg-info" -exec rm -r {} +
	rm -rf .pytest_cache .mypy_cache .ruff_cache
	rm -rf htmlcov .coverage

docker-up: ## Start Docker containers
	docker-compose up -d

docker-down: ## Stop Docker containers
	docker-compose down

docker-logs: ## Show Docker logs
	docker-compose logs -f

migrate: ## Create a new migration
	poetry run alembic revision --autogenerate -m "$(msg)"

upgrade: ## Run database migrations
	poetry run alembic upgrade head

downgrade: ## Rollback last migration
	poetry run alembic downgrade -1

shell: ## Open Python shell
	poetry run python -i

run: ## Run the development server
	poetry run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

worker: ## Run RQ worker
	poetry run rq worker --url redis://localhost:6379/0

seed: ## Seed products database
	poetry run python scripts/seed_products.py

download-images: ## Download and upload product images to MinIO
	poetry run python scripts/download_and_upload_images.py


