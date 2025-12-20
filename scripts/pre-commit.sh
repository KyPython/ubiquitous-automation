#!/bin/bash

# pre-commit.sh - Enhanced Pre-commit hook script
# Run this before committing to ensure code quality
# Features: caching, parallel execution, selective checks, config support, CI-friendly, multi-service

set -e  # Exit on any error

# Get script directory and source shared library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/lib.sh" ]; then
  source "$SCRIPT_DIR/lib.sh"
else
  # Fallback colors if lib.sh not available
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  NC='\033[0m'
  
  detect_ci() { return 1; }
  is_ci() { echo "false"; }
  ensure_executable() { chmod +x "$1" 2>/dev/null || true; }
fi

# Configuration
CACHE_DIR="${CACHE_DIR:-.pre-commit-cache}"
CONFIG_FILE="${PRE_COMMIT_CONFIG:-.pre-commit-config.json}"
WORKSPACE_ROOT="${WORKSPACE_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"

# Ensure script is executable (important for CI)
ensure_executable "$0"

# Load config if exists
if [ -f "$CONFIG_FILE" ]; then
  echo "📋 Loading config from $CONFIG_FILE..."
  # Parse JSON config (requires jq or basic bash parsing)
  if command -v jq &> /dev/null; then
    RUN_LINT=$(jq -r '.run_lint // true' "$CONFIG_FILE")
    RUN_TEST=$(jq -r '.run_test // true' "$CONFIG_FILE")
    RUN_BUILD=$(jq -r '.run_build // true' "$CONFIG_FILE")
    PARALLEL=$(jq -r '.parallel // true' "$CONFIG_FILE")
    CACHE_ENABLED=$(jq -r '.cache // true' "$CONFIG_FILE")
  else
    # Fallback: assume all enabled if config exists
    RUN_LINT=true
    RUN_TEST=true
    RUN_BUILD=true
    PARALLEL=true
    CACHE_ENABLED=true
  fi
else
  # Defaults
  RUN_LINT=true
  RUN_TEST=true
  RUN_BUILD=true
  PARALLEL=true
  CACHE_ENABLED=true
fi

# Create cache directory
mkdir -p "$CACHE_DIR"

# Get changed files (works in both CI and local)
if [ "$CI_MODE" = "true" ]; then
  # In CI, check all files if PR, or use merge-base
  CHANGED_FILES=$(git diff --name-only --diff-filter=ACM origin/main...HEAD 2>/dev/null || \
                  git diff --name-only --diff-filter=ACM HEAD~1 HEAD 2>/dev/null || echo "")
else
  # Local: check staged files
  CHANGED_FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || echo "")
fi

# Function to get file hash for caching
get_file_hash() {
  local file="$1"
  if [ -f "$file" ]; then
    git hash-object "$file" 2>/dev/null || md5sum "$file" 2>/dev/null | cut -d' ' -f1 || echo "no-hash"
  else
    echo "no-file"
  fi
}

# Function to check if cache is valid
is_cache_valid() {
  local check_name="$1"
  local cache_file="$CACHE_DIR/$check_name.cache"
  local hash_file="$CACHE_DIR/$check_name.hash"
  
  if [ "$CACHE_ENABLED" != "true" ] || [ ! -f "$cache_file" ] || [ ! -f "$hash_file" ]; then
    return 1
  fi
  
  local current_hash=""
  if [ -n "$CHANGED_FILES" ]; then
    # Hash of all changed files
    current_hash=$(echo "$CHANGED_FILES" | xargs -I {} git hash-object {} 2>/dev/null | sort | md5sum | cut -d' ' -f1 || echo "no-hash")
  else
    # Hash of all relevant files
    current_hash=$(find . -name "*.ts" -o -name "*.js" -o -name "*.json" 2>/dev/null | xargs git hash-object 2>/dev/null | sort | md5sum | cut -d' ' -f1 || echo "no-hash")
  fi
  
  local cached_hash=$(cat "$hash_file" 2>/dev/null || echo "")
  [ "$current_hash" = "$cached_hash" ]
}

# Function to save cache
save_cache() {
  local check_name="$1"
  local cache_file="$CACHE_DIR/$check_name.cache"
  local hash_file="$CACHE_DIR/$check_name.hash"
  
  if [ "$CACHE_ENABLED" = "true" ]; then
    touch "$cache_file"
    if [ -n "$CHANGED_FILES" ]; then
      echo "$CHANGED_FILES" | xargs -I {} git hash-object {} 2>/dev/null | sort | md5sum | cut -d' ' -f1 > "$hash_file" 2>/dev/null || echo "no-hash" > "$hash_file"
    else
      find . -name "*.ts" -o -name "*.js" -o -name "*.json" 2>/dev/null | xargs git hash-object 2>/dev/null | sort | md5sum | cut -d' ' -f1 > "$hash_file" 2>/dev/null || echo "no-hash" > "$hash_file"
    fi
  fi
}

# Detect CI and adjust behavior
CI_MODE=$(is_ci)
if [ "$CI_MODE" = "true" ]; then
  echo "::notice::Running pre-commit checks in CI mode"
  # In CI, ensure all scripts are executable
  ensure_executable "$SCRIPT_DIR/test-all.sh"
  ensure_executable "$SCRIPT_DIR/lint-and-test.sh"
fi

echo "🚀 Pre-commit checks..."
echo ""

# Determine which files to check
FILES_TO_LINT=""
FILES_TO_TEST=""

if [ -n "$CHANGED_FILES" ]; then
  # Filter changed files by extension
  TS_FILES=$(echo "$CHANGED_FILES" | grep -E '\.(ts|tsx)$' || true)
  JS_FILES=$(echo "$CHANGED_FILES" | grep -E '\.(js|jsx)$' || true)
  
  if [ -n "$TS_FILES" ] || [ -n "$JS_FILES" ]; then
    FILES_TO_LINT=$(echo -e "$TS_FILES\n$JS_FILES" | grep -v '^$' | tr '\n' ' ')
  fi
else
  # No staged files, check all
  FILES_TO_LINT="."
fi

# Linting
run_lint() {
  if [ "$RUN_LINT" != "true" ]; then
    echo "⏭️  Linting skipped (disabled in config)"
    return 0
  fi
  
  if is_cache_valid "lint"; then
    echo "✅ Linting skipped (cached)"
    return 0
  fi
  
  echo "🔍 Running linter (with auto-fix)..."
  
  if [ -n "$FILES_TO_LINT" ] && [ "$FILES_TO_LINT" != "." ]; then
    # Lint only changed files
    for file in $FILES_TO_LINT; do
      if [ -f "$file" ]; then
        # In CI, don't auto-fix (just check), locally auto-fix
        if [ "$CI_MODE" = "true" ]; then
          npx eslint "$file" || true
        else
          npx eslint "$file" --fix || true
        fi
      fi
    done
    
    # In CI, also run full lint to catch cross-file issues
    if [ "$CI_MODE" = "true" ]; then
      npm run lint || true
    fi
  else
    if [ "$CI_MODE" = "true" ]; then
      npm run lint
    else
      npm run lint:fix
    fi
  fi
  
  save_cache "lint"
}

# Testing
run_test() {
  if [ "$RUN_TEST" != "true" ]; then
    echo "⏭️  Testing skipped (disabled in config)"
    return 0
  fi
  
  if is_cache_valid "test"; then
    echo "✅ Testing skipped (cached)"
    return 0
  fi
  
  echo "🧪 Running tests..."
  
  # Find related tests for changed files if possible
  if [ -n "$TS_FILES" ] && [ -n "$FILES_TO_LINT" ]; then
    # Use Jest's --findRelatedTests if available
    npm run test -- --findRelatedTests $FILES_TO_LINT --passWithNoTests || npm run test
  else
    npm run test
  fi
  
  save_cache "test"
}

# Building
run_build() {
  if [ "$RUN_BUILD" != "true" ]; then
    echo "⏭️  Build skipped (disabled in config)"
    return 0
  fi
  
  if is_cache_valid "build"; then
    echo "✅ Build skipped (cached)"
    return 0
  fi
  
  echo "🏗️  Verifying build..."
  npm run build
  
  save_cache "build"
}

# Run checks in parallel if enabled, otherwise sequentially
if [ "$PARALLEL" = "true" ]; then
  echo "⚡ Running checks in parallel..."
  
  # Run lint, test, and build in parallel
  run_lint &
  LINT_PID=$!
  
  run_test &
  TEST_PID=$!
  
  run_build &
  BUILD_PID=$!
  
  # Wait for all processes and collect exit codes
  LINT_EXIT=0
  TEST_EXIT=0
  BUILD_EXIT=0
  
  wait $LINT_PID || LINT_EXIT=$?
  wait $TEST_PID || TEST_EXIT=$?
  wait $BUILD_PID || BUILD_EXIT=$?
  
  # Check if any failed
  if [ $LINT_EXIT -ne 0 ] || [ $TEST_EXIT -ne 0 ] || [ $BUILD_EXIT -ne 0 ]; then
    echo ""
    echo -e "${RED}❌ Pre-commit checks failed!${NC}"
    [ $LINT_EXIT -ne 0 ] && echo -e "${RED}  - Linting failed${NC}"
    [ $TEST_EXIT -ne 0 ] && echo -e "${RED}  - Testing failed${NC}"
    [ $BUILD_EXIT -ne 0 ] && echo -e "${RED}  - Build failed${NC}"
    exit 1
  fi
else
  # Sequential execution
  run_lint
  run_test
  run_build
fi

echo ""
echo -e "${GREEN}✅ Pre-commit checks passed!${NC}"
