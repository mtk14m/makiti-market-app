.PHONY: help install dev-install format lint type-check test clean docker-up docker-down migrate upgrade downgrade

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install dependencies
	uv sync

dev-install: ## Install dependencies including dev dependencies
	uv sync --group dev --group test

format: ## Format code with black
	uv run black app tests

lint: ## Lint code with ruff
	uv run ruff check app tests

type-check: ## Type check with mypy
	uv run mypy app

test: ## Run tests
	uv run pytest

test-cov: ## Run tests with coverage
	uv run pytest --cov=app --cov-report=html --cov-report=term-missing

clean: ## Clean cache and temporary files
	find . -type d -name __pycache__ -exec rm -r {} +
	find . -type f -name "*.pyc" -delete
	find . -type d -name "*.egg-info" -exec rm -r {} +
	rm -rf .pytest_cache .mypy_cache .ruff_cache
	rm -rf htmlcov .coverage

docker-up: ## Start Docker containers
	docker compose -f ../docker-compose.yml up -d

docker-down: ## Stop Docker containers
	docker compose -f ../docker-compose.yml down

docker-logs: ## Show Docker logs
	docker compose -f ../docker-compose.yml logs -f

migrate: ## Create a new migration
	uv run alembic revision --autogenerate -m "$(msg)"

upgrade: ## Run database migrations
	uv run alembic upgrade head

downgrade: ## Rollback last migration
	uv run alembic downgrade -1

shell: ## Open Python shell
	uv run python -i

run: ## Run the development server
	uv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

worker: ## Run RQ worker
	uv run rq worker --url redis://localhost:6379/0

setup-minio: ## Configure MinIO bucket for public read access
	uv run python scripts/setup_minio_public.py

check-minio: ## Check objects in MinIO bucket
	uv run python scripts/check_minio_objects.py
