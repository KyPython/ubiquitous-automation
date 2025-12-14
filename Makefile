# Makefile for Ubiquitous Automation
# Makes automation portable across CI platforms

.PHONY: help install lint test build clean all pre-commit

# Default target
help:
	@echo "Ubiquitous Automation - Available Commands"
	@echo "==========================================="
	@echo "make install     - Install dependencies"
	@echo "make lint        - Run linter"
	@echo "make test        - Run tests"
	@echo "make build       - Build project"
	@echo "make all         - Run lint + test + build"
	@echo "make pre-commit  - Pre-commit checks (fast)"
	@echo "make clean       - Clean build artifacts"

# Install dependencies
install:
	@echo "📦 Installing dependencies..."
	npm ci

# Run linter
lint:
	@echo "🔍 Running linter..."
	npm run lint

# Run linter with auto-fix
lint-fix:
	@echo "🔧 Running linter with auto-fix..."
	npm run lint:fix

# Run tests
test:
	@echo "🧪 Running tests..."
	npm test

# Build project
build:
	@echo "🏗️  Building project..."
	npm run build

# Run all checks (fail-fast)
all: lint test build
	@echo "✅ All checks passed!"

# Pre-commit checks (fast version for local development)
pre-commit: lint-fix test
	@echo "✅ Pre-commit checks passed!"

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	rm -rf dist coverage node_modules/.cache
	@echo "✅ Clean complete!"

# Setup development environment
setup: install
	@echo "🔧 Setting up git hooks..."
	npm install -D husky lint-staged
	npx husky install
	npx husky add .husky/pre-commit "npx lint-staged"
	@echo "✅ Setup complete! Pre-commit hooks installed."
