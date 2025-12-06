#!/bin/bash

# test-all.sh - Run all tests and checks
# This script demonstrates ubiquitous automation by running the full test suite

set -e  # Exit on any error

echo "🧪 Running all tests and checks..."
echo ""

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
  echo "📦 Installing dependencies..."
  npm install
fi

# Run linter
echo "🔍 Running linter..."
npm run lint

# Run tests
echo "🧪 Running tests..."
npm run test

# Build the project
echo "🏗️  Building project..."
npm run build

echo ""
echo "✅ All tests and checks passed!"

