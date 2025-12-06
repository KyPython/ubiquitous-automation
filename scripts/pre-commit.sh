#!/bin/bash

# pre-commit.sh - Pre-commit hook script
# Run this before committing to ensure code quality

set -e  # Exit on any error

echo "🚀 Pre-commit checks..."
echo ""

# Run linter with auto-fix
echo "🔍 Running linter (with auto-fix)..."
npm run lint:fix

# Run tests
echo "🧪 Running tests..."
npm run test

# Build to ensure compilation succeeds
echo "🏗️  Verifying build..."
npm run build

echo ""
echo "✅ Pre-commit checks passed!"

