.PHONY: help build up down logs clean dev dev-down dev-logs restart health

# Default target
help:
	@echo "Available commands:"
	@echo "  make build     - Build all Docker images"
	@echo "  make up        - Start production environment"
	@echo "  make down      - Stop production environment"
	@echo "  make logs      - View production logs"
	@echo "  make clean     - Stop and remove volumes (WARNING: deletes data)"
	@echo "  make dev       - Start development environment"
	@echo "  make dev-down  - Stop development environment"
	@echo "  make dev-logs  - View development logs"
	@echo "  make restart   - Restart production environment"
	@echo "  make health    - Check service health status"

# Production commands
build:
	docker-compose build

up:
	docker-compose up -d

down:
	docker-compose down

logs:
	docker-compose logs -f

clean:
	docker-compose down -v
	docker system prune -f

restart:
	docker-compose restart

health:
	docker-compose ps

# Development commands
dev:
	docker-compose -f docker-compose.dev.yml up -d

dev-down:
	docker-compose -f docker-compose.dev.yml down

dev-logs:
	docker-compose -f docker-compose.dev.yml logs -f

# Utility commands
backend-shell:
	docker-compose exec backend sh

frontend-shell:
	docker-compose exec frontend sh

mongo-shell:
	docker-compose exec mongodb mongosh -u root -p toor --authenticationDatabase admin
