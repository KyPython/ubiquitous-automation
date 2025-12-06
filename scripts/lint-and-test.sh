#!/bin/bash

# lint-and-test.sh - Quick lint and test script
# This script automates the common workflow of linting and testing

set -e  # Exit on any error

echo "🔍 Running linter and tests..."
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

echo ""
echo "✅ Lint and tests completed successfully!"

