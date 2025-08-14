# ==============================================
# SRECHA INVOICE DOCKER MANAGEMENT
# ==============================================

# Variables
COMPOSE_FILE = docker-compose.yml
PROJECT_NAME = srecha-invoice
ENV_FILE = .env

# Colors for output
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

.PHONY: help build up down restart logs clean backup restore dev prod monitoring

# Default target
help: ## Show this help message
	@echo "$(BLUE)Srecha Invoice Management System$(NC)"
	@echo "$(BLUE)================================$(NC)"
	@echo ""
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

# Setup commands
setup: ## Initial setup - copy environment file
	@echo "$(YELLOW)Setting up environment...$(NC)"
	@if [ ! -f $(ENV_FILE) ]; then \
		cp env.docker $(ENV_FILE); \
		echo "$(GREEN)✅ Environment file created from env.docker$(NC)"; \
		echo "$(YELLOW)⚠️  Please edit .env file with your settings$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  Environment file already exists$(NC)"; \
	fi

# Build commands
build: ## Build all Docker images
	@echo "$(YELLOW)Building Docker images...$(NC)"
	docker-compose -f $(COMPOSE_FILE) build
	@echo "$(GREEN)✅ Build completed$(NC)"

build-no-cache: ## Build all Docker images without cache
	@echo "$(YELLOW)Building Docker images without cache...$(NC)"
	docker-compose -f $(COMPOSE_FILE) build --no-cache
	@echo "$(GREEN)✅ Build completed$(NC)"

# Run commands
up: ## Start all services
	@echo "$(YELLOW)Starting all services...$(NC)"
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)✅ All services started$(NC)"
	@echo "$(BLUE)Frontend: http://localhost:8080$(NC)"
	@echo "$(BLUE)Backend API: http://localhost:3000$(NC)"

dev: ## Start in development mode
	@echo "$(YELLOW)Starting in development mode...$(NC)"
	BUILD_TARGET=development docker-compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)✅ Development environment started$(NC)"

prod: ## Start in production mode
	@echo "$(YELLOW)Starting in production mode...$(NC)"
	BUILD_TARGET=production docker-compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)✅ Production environment started$(NC)"

down: ## Stop and remove all containers
	@echo "$(YELLOW)Stopping all services...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down
	@echo "$(GREEN)✅ All services stopped$(NC)"

restart: ## Restart all services
	@echo "$(YELLOW)Restarting all services...$(NC)"
	docker-compose -f $(COMPOSE_FILE) restart
	@echo "$(GREEN)✅ All services restarted$(NC)"

# Monitoring commands
logs: ## Show logs for all services
	docker-compose -f $(COMPOSE_FILE) logs -f

logs-backend: ## Show backend logs
	docker-compose -f $(COMPOSE_FILE) logs -f backend

logs-frontend: ## Show frontend logs
	docker-compose -f $(COMPOSE_FILE) logs -f frontend

logs-db: ## Show database logs
	docker-compose -f $(COMPOSE_FILE) logs -f postgres

status: ## Show status of all services
	@echo "$(BLUE)Service Status:$(NC)"
	docker-compose -f $(COMPOSE_FILE) ps

# Database commands
migrate: ## Run database migrations
	@echo "$(YELLOW)Running database migrations...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec backend npm run migrate
	@echo "$(GREEN)✅ Migrations completed$(NC)"

seed: ## Seed database with initial data
	@echo "$(YELLOW)Seeding database...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec backend npm run seed
	@echo "$(GREEN)✅ Database seeded$(NC)"

db-shell: ## Connect to database shell
	docker-compose -f $(COMPOSE_FILE) exec postgres psql -U postgres -d srecha_invoice

# Backup commands
backup: ## Create database backup
	@echo "$(YELLOW)Creating database backup...$(NC)"
	docker-compose -f $(COMPOSE_FILE) run --rm backup
	@echo "$(GREEN)✅ Backup completed$(NC)"

restore: ## Restore database from backup (requires BACKUP_FILE variable)
	@if [ -z "$(BACKUP_FILE)" ]; then \
		echo "$(RED)❌ Please specify BACKUP_FILE variable$(NC)"; \
		echo "Example: make restore BACKUP_FILE=srecha_invoice_backup_20240101_120000.sql.custom"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Restoring database from $(BACKUP_FILE)...$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec postgres pg_restore -U postgres -d srecha_invoice --clean --if-exists /backups/$(BACKUP_FILE)
	@echo "$(GREEN)✅ Database restored$(NC)"

list-backups: ## List available backups
	@echo "$(BLUE)Available backups:$(NC)"
	docker-compose -f $(COMPOSE_FILE) exec postgres ls -la /backups/

# Monitoring commands
monitoring: ## Start monitoring stack (Prometheus + Grafana)
	@echo "$(YELLOW)Starting monitoring stack...$(NC)"
	docker-compose -f $(COMPOSE_FILE) --profile monitoring up -d
	@echo "$(GREEN)✅ Monitoring started$(NC)"
	@echo "$(BLUE)Prometheus: http://localhost:9090$(NC)"
	@echo "$(BLUE)Grafana: http://localhost:3001 (admin/admin123)$(NC)"

monitoring-down: ## Stop monitoring stack
	@echo "$(YELLOW)Stopping monitoring stack...$(NC)"
	docker-compose -f $(COMPOSE_FILE) --profile monitoring down
	@echo "$(GREEN)✅ Monitoring stopped$(NC)"

# Maintenance commands
clean: ## Clean up Docker resources
	@echo "$(YELLOW)Cleaning up Docker resources...$(NC)"
	docker-compose -f $(COMPOSE_FILE) down -v --remove-orphans
	docker system prune -f
	@echo "$(GREEN)✅ Cleanup completed$(NC)"

clean-all: ## Clean up everything including images and volumes
	@echo "$(RED)⚠️  This will remove all containers, images, and volumes!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo ""; \
		docker-compose -f $(COMPOSE_FILE) down -v --rmi all --remove-orphans; \
		docker system prune -a -f; \
		echo "$(GREEN)✅ Complete cleanup finished$(NC)"; \
	else \
		echo ""; \
		echo "$(YELLOW)Cleanup cancelled$(NC)"; \
	fi

# Update commands
update: ## Update and rebuild all services
	@echo "$(YELLOW)Updating all services...$(NC)"
	docker-compose -f $(COMPOSE_FILE) pull
	docker-compose -f $(COMPOSE_FILE) build --pull
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)✅ Update completed$(NC)"

# Health check commands
health: ## Check health of all services
	@echo "$(BLUE)Health Check Results:$(NC)"
	@echo "$(YELLOW)Backend API:$(NC)"
	@curl -f http://localhost:3000/health 2>/dev/null && echo " $(GREEN)✅ Healthy$(NC)" || echo " $(RED)❌ Unhealthy$(NC)"
	@echo "$(YELLOW)Frontend:$(NC)"
	@curl -f http://localhost:8080 2>/dev/null >/dev/null && echo " $(GREEN)✅ Healthy$(NC)" || echo " $(RED)❌ Unhealthy$(NC)"
	@echo "$(YELLOW)Database:$(NC)"
	@docker-compose -f $(COMPOSE_FILE) exec postgres pg_isready -U postgres -d srecha_invoice 2>/dev/null && echo " $(GREEN)✅ Healthy$(NC)" || echo " $(RED)❌ Unhealthy$(NC)"

# Development helpers
shell-backend: ## Open shell in backend container
	docker-compose -f $(COMPOSE_FILE) exec backend sh

shell-frontend: ## Open shell in frontend container
	docker-compose -f $(COMPOSE_FILE) exec frontend sh

# Quick start
quick-start: setup build up migrate seed ## Quick start - setup, build, start, migrate and seed
	@echo "$(GREEN)🎉 Srecha Invoice System is ready!$(NC)"
	@echo "$(BLUE)Frontend: http://localhost:8080$(NC)"
	@echo "$(BLUE)Backend API: http://localhost:3000$(NC)"
	@echo "$(YELLOW)Default login: BrankoFND / MoskvaSlezamNeVeryt2024$(NC)"
