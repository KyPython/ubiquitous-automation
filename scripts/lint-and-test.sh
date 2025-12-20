#!/bin/bash

# lint-and-test.sh - Enhanced quick lint and test script with incremental checks
# This script automates the common workflow of linting and testing
# Features: Incremental linting, optional watch mode, CI-friendly, multi-service

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

# Ensure script is executable (important for CI)
ensure_executable "$0"

# Configuration
WORKSPACE_ROOT="${WORKSPACE_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"

# Configuration
WATCH_MODE="${WATCH_MODE:-false}"
INCREMENTAL="${INCREMENTAL:-true}"
LINT_ONLY="${LINT_ONLY:-false}"
TEST_ONLY="${TEST_ONLY:-false}"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --watch|-w)
      WATCH_MODE=true
      shift
      ;;
    --all|-a)
      INCREMENTAL=false
      shift
      ;;
    --lint-only)
      LINT_ONLY=true
      shift
      ;;
    --test-only)
      TEST_ONLY=true
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --watch, -w              Enable watch mode (re-runs on file changes)"
      echo "  --all, -a                Lint/test all files (not just changed)"
      echo "  --lint-only              Run only linting"
      echo "  --test-only              Run only tests"
      echo "  --help                   Show this help message"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Detect CI and adjust behavior
CI_MODE=$(is_ci)
if [ "$CI_MODE" = "true" ]; then
  echo "::notice::Running lint and tests in CI mode"
  ensure_executable "$SCRIPT_DIR/pre-commit.sh"
  ensure_executable "$SCRIPT_DIR/test-all.sh"
fi

echo -e "${BLUE}🔍 Running linter and tests...${NC}"
echo ""

# Install dependencies if node_modules doesn't exist
if [ ! -d "$WORKSPACE_ROOT/node_modules" ]; then
  echo "📦 Installing dependencies..."
  (cd "$WORKSPACE_ROOT" && npm install)
fi

# Function to get changed files (works in both CI and local)
get_changed_files() {
  if [ "$CI_MODE" = "true" ]; then
    # In CI, check files changed in PR or since last commit
    local changed=$(git diff --name-only --diff-filter=ACM origin/main...HEAD 2>/dev/null || \
                   git diff --name-only --diff-filter=ACM HEAD~1 HEAD 2>/dev/null || echo "")
    echo "$changed"
  else
    # Local: Try to get staged files first (for pre-commit scenarios)
    local staged=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || echo "")
    
    # If no staged files, get modified files
    if [ -z "$staged" ]; then
      staged=$(git diff --name-only --diff-filter=ACM 2>/dev/null || echo "")
    fi
    
    # If still no files, get files changed in last commit
    if [ -z "$staged" ]; then
      staged=$(git diff HEAD~1 --name-only --diff-filter=ACM 2>/dev/null || echo "")
    fi
    
    echo "$staged"
  fi
}

# Function to run linting (incremental or all)
run_lint() {
  if [ "$TEST_ONLY" = "true" ]; then
    return 0
  fi
  
  echo -e "${BLUE}🔍 Running linter...${NC}"
  
  if [ "$INCREMENTAL" = "true" ] && [ "$WATCH_MODE" = "false" ]; then
    local changed_files=$(get_changed_files)
    local ts_files=$(echo "$changed_files" | grep -E '\.(ts|tsx)$' || true)
    
    if [ -n "$ts_files" ]; then
      echo -e "${YELLOW}📝 Linting changed files only...${NC}"
      local file_list=$(echo "$ts_files" | tr '\n' ' ')
      for file in $file_list; do
        if [ -f "$file" ]; then
          echo "  → $file"
          npx eslint "$file" --fix || {
            echo -e "${YELLOW}⚠️  Linting issues found in $file (non-blocking)${NC}"
          }
        fi
      done
      
      # Also run full lint to catch any cross-file issues
      echo -e "${YELLOW}🔍 Running full lint check...${NC}"
      npm run lint || {
        echo -e "${YELLOW}⚠️  Full lint check found issues${NC}"
      }
    else
      echo -e "${YELLOW}📝 No TypeScript files changed, running full lint...${NC}"
      npm run lint
    fi
  else
    npm run lint
  fi
}

# Function to run tests (incremental or all)
run_test() {
  if [ "$LINT_ONLY" = "true" ]; then
    return 0
  fi
  
  echo ""
  echo -e "${BLUE}🧪 Running tests...${NC}"
  
  if [ "$INCREMENTAL" = "true" ] && [ "$WATCH_MODE" = "false" ]; then
    local changed_files=$(get_changed_files)
    local ts_files=$(echo "$changed_files" | grep -E '\.(ts|tsx)$' || true)
    
    if [ -n "$ts_files" ]; then
      echo -e "${YELLOW}📝 Running tests for changed files...${NC}"
      # Use Jest's --findRelatedTests to only run tests for changed files
      (cd "$WORKSPACE_ROOT" && npm run test -- --findRelatedTests $(echo "$ts_files" | tr '\n' ' ') --passWithNoTests) || {
        ci_error "Related tests failed!"
        return 1
      }
    else
      echo -e "${YELLOW}📝 No TypeScript files changed, running all tests...${NC}"
      (cd "$WORKSPACE_ROOT" && npm run test)
    fi
  else
    (cd "$WORKSPACE_ROOT" && npm run test)
  fi
}

# Main execution
if [ "$WATCH_MODE" = "true" ]; then
  echo -e "${GREEN}👀 Watch mode enabled - will re-run on file changes${NC}"
  echo ""
  
  # Check if chokidar-cli or nodemon is available for file watching
  if command -v chokidar &> /dev/null || npm list chokidar-cli &> /dev/null; then
    echo "Using chokidar for file watching..."
    chokidar "**/*.ts" "**/*.js" --ignore "node_modules/**" --ignore "dist/**" --ignore "coverage/**" -c "bash $0 --all"
  elif command -v nodemon &> /dev/null || npm list nodemon &> /dev/null; then
    echo "Using nodemon for file watching..."
    nodemon --watch src --watch api --ext ts,js --exec "bash $0 --all"
  else
    echo -e "${YELLOW}⚠️  No file watcher found. Install chokidar-cli or nodemon for better watch mode.${NC}"
    echo "Falling back to Jest watch mode..."
    
    if [ "$TEST_ONLY" != "true" ]; then
      run_lint
    fi
    if [ "$LINT_ONLY" != "true" ]; then
      (cd "$WORKSPACE_ROOT" && npm run test:watch)
    fi
  fi
else
  # Normal execution
  run_lint
  run_test
  
  echo ""
  echo -e "${GREEN}✅ Lint and tests completed successfully!${NC}"
fi
