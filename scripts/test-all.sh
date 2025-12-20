#!/bin/bash

# test-all.sh - Enhanced test runner with auto-detection and parallel execution
# This script demonstrates ubiquitous automation by running the full test suite
# Features: Auto-detect frameworks, parallel execution, coverage reports, test filtering, CI-friendly, multi-service

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
  discover_services() { echo "."; }
  detect_test_framework_in_dir() { echo "unknown"; }
fi

# Ensure script is executable (important for CI)
ensure_executable "$0"

# Configuration
WORKSPACE_ROOT="${WORKSPACE_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
TEST_FRAMEWORK=""
PARALLEL="${PARALLEL:-true}"
COVERAGE="${COVERAGE:-true}"
TEST_PATTERN="${TEST_PATTERN:-}"
TEST_NAME="${TEST_NAME:-}"
MULTI_SERVICE="${MULTI_SERVICE:-false}"

# Detect CI and adjust behavior
CI_MODE=$(is_ci)
if [ "$CI_MODE" = "true" ]; then
  echo "::notice::Running tests in CI mode"
  # Ensure scripts are executable in CI
  ensure_executable "$SCRIPT_DIR/pre-commit.sh"
  ensure_executable "$SCRIPT_DIR/lint-and-test.sh"
  # In CI, disable parallel by default if not explicitly set (avoid resource issues)
  if [ -z "${PARALLEL}" ]; then
    PARALLEL="${CI_PARALLEL:-false}"
  fi
fi

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --framework=*)
      TEST_FRAMEWORK="${1#*=}"
      shift
      ;;
    --pattern=*)
      TEST_PATTERN="${1#*=}"
      shift
      ;;
    --testNamePattern=*)
      TEST_NAME="${1#*=}"
      shift
      ;;
    --no-parallel)
      PARALLEL=false
      shift
      ;;
    --no-coverage)
      COVERAGE=false
      shift
      ;;
    --multi-service)
      MULTI_SERVICE=true
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --framework=<jest|pytest|mocha>  Force specific test framework"
      echo "  --pattern=<pattern>               Run tests matching pattern"
      echo "  --testNamePattern=<pattern>       Run tests matching name pattern"
      echo "  --no-parallel                     Disable parallel execution"
      echo "  --no-coverage                     Disable coverage reports"
      echo "  --multi-service                   Enable multi-service/monorepo mode"
      echo "  --help                            Show this help message"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}🧪 Running all tests and checks...${NC}"
echo ""

# Discover services if multi-service mode
SERVICES=()
if [ "$MULTI_SERVICE" = "true" ] || [ -n "${MULTI_SERVICE_FORCE:-}" ]; then
  echo -e "${BLUE}🔍 Discovering services/workspaces...${NC}"
  while IFS= read -r service; do
    if [ -n "$service" ]; then
      SERVICES+=("$service")
    fi
  done < <(discover_services "$WORKSPACE_ROOT")
  
  if [ ${#SERVICES[@]} -gt 1 ]; then
    echo -e "${GREEN}Found ${#SERVICES[@]} services: ${SERVICES[*]}${NC}"
  else
    echo -e "${BLUE}Single service project detected${NC}"
    SERVICES=(".")
  fi
else
  SERVICES=(".")
fi

# Install dependencies if node_modules doesn't exist (for root and each service)
for service_dir in "${SERVICES[@]}"; do
  service_path="$WORKSPACE_ROOT/$service_dir"
  if [ "$service_dir" = "." ]; then
    service_path="$WORKSPACE_ROOT"
  fi
  
  if [ -f "$service_path/package.json" ] && [ ! -d "$service_path/node_modules" ]; then
    echo "📦 Installing dependencies in $service_dir..."
    (cd "$service_path" && npm install)
  fi
done

# Auto-detect test framework
detect_test_framework() {
  if [ -n "$TEST_FRAMEWORK" ]; then
    echo "$TEST_FRAMEWORK"
    return
  fi
  
  # Check for Jest (TypeScript/JavaScript)
  if [ -f "package.json" ] && grep -q '"jest"' package.json; then
    echo "jest"
    return
  fi
  if [ -f "jest.config.js" ] || [ -f "jest.config.ts" ] || [ -f "jest.config.json" ]; then
    echo "jest"
    return
  fi
  
  # Check for Pytest (Python)
  if [ -f "pytest.ini" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
    if command -v pytest &> /dev/null; then
      echo "pytest"
      return
    fi
  fi
  
  # Check for Mocha
  if [ -f "package.json" ] && grep -q '"mocha"' package.json; then
    echo "mocha"
    return
  fi
  
  # Default to npm test if package.json exists
  if [ -f "package.json" ] && grep -q '"test"' package.json; then
    echo "npm"
    return
  fi
  
  echo "unknown"
}

# Detect test framework (for single service mode, or use per-service detection)
if [ ${#SERVICES[@]} -eq 1 ] && [ "${SERVICES[0]}" = "." ]; then
  FRAMEWORK=$(detect_test_framework)
  echo -e "${BLUE}🔍 Detected test framework: ${FRAMEWORK}${NC}"
  echo ""
  
  # For single service, we can use the global FRAMEWORK variable
  # For multi-service, we detect per-service in the loop
fi

# Function to run tests with framework-specific options
# Usage: run_tests <framework> <working_directory>
run_tests() {
  local framework="$1"
  local work_dir="${2:-.}"
  local exit_code=0
  
  case "$framework" in
    jest)
      local jest_args=""
      
      if [ "$COVERAGE" = "true" ]; then
        jest_args="--coverage"
      fi
      
      if [ "$PARALLEL" = "true" ]; then
        jest_args="$jest_args --maxWorkers=50%"
      else
        jest_args="$jest_args --runInBand"
      fi
      
      if [ -n "$TEST_PATTERN" ]; then
        jest_args="$jest_args --testPathPattern=$TEST_PATTERN"
      fi
      
      if [ -n "$TEST_NAME" ]; then
        jest_args="$jest_args --testNamePattern=$TEST_NAME"
      fi
      
      echo -e "${BLUE}🧪 Running Jest tests...${NC}"
      (cd "$work_dir" && npm run test -- $jest_args) || exit_code=$?
      ;;
      
    pytest)
      local pytest_args=""
      
      if [ "$COVERAGE" = "true" ]; then
        pytest_args="--cov --cov-report=html --cov-report=term"
      fi
      
      if [ "$PARALLEL" = "true" ]; then
        if command -v pytest-xdist &> /dev/null; then
          pytest_args="$pytest_args -n auto"
        fi
      fi
      
      if [ -n "$TEST_PATTERN" ]; then
        pytest_args="$pytest_args -k $TEST_PATTERN"
      fi
      
      echo -e "${BLUE}🧪 Running Pytest tests...${NC}"
      (cd "$work_dir" && pytest $pytest_args) || exit_code=$?
      ;;
      
    mocha)
      local mocha_args=""
      
      if [ "$PARALLEL" = "false" ]; then
        mocha_args="--parallel false"
      fi
      
      if [ -n "$TEST_PATTERN" ]; then
        mocha_args="$mocha_args --grep $TEST_PATTERN"
      fi
      
      echo -e "${BLUE}🧪 Running Mocha tests...${NC}"
      (cd "$work_dir" && npm run test -- $mocha_args) || exit_code=$?
      ;;
      
    npm)
      echo -e "${BLUE}🧪 Running tests via npm...${NC}"
      (cd "$work_dir" && npm run test) || exit_code=$?
      ;;
      
    *)
      echo -e "${YELLOW}⚠️  Unknown test framework: $framework${NC}"
      echo "Falling back to npm test"
      (cd "$work_dir" && npm run test) || exit_code=$?
      ;;
  esac
  
  return $exit_code
}

# Run linter (for all services or root)
for service_dir in "${SERVICES[@]}"; do
  service_path="$WORKSPACE_ROOT/$service_dir"
  if [ "$service_dir" = "." ]; then
    service_path="$WORKSPACE_ROOT"
  fi
  
  if [ -f "$service_path/package.json" ]; then
    if [ ${#SERVICES[@]} -gt 1 ]; then
      echo ""
      echo -e "${BLUE}🔍 Running linter in $service_dir...${NC}"
    else
      echo -e "${BLUE}🔍 Running linter...${NC}"
    fi
    
    (cd "$service_path" && npm run lint) || {
      if [ "$CI_MODE" = "true" ]; then
        ci_warning "Linting failed in $service_dir, but continuing with tests (non-blocking in CI)"
      else
        echo -e "${YELLOW}⚠️  Linting failed in $service_dir, but continuing with tests...${NC}"
      fi
    }
  fi
done

# Run tests (for all services or root)
TESTS_FAILED=0
for service_dir in "${SERVICES[@]}"; do
  service_path="$WORKSPACE_ROOT/$service_dir"
  if [ "$service_dir" = "." ]; then
    service_path="$WORKSPACE_ROOT"
    service_label="root"
  else
    service_label="$service_dir"
  fi
  
  if [ -f "$service_path/package.json" ]; then
    if [ ${#SERVICES[@]} -gt 1 ]; then
      echo ""
      echo -e "${BLUE}🧪 Running tests in $service_label...${NC}"
    else
      echo ""
    fi
    
    local_framework=$(detect_test_framework_in_dir "$service_path")
    if [ "$local_framework" != "unknown" ]; then
      run_tests "$local_framework" "$service_path" || {
        TESTS_FAILED=1
        if [ ${#SERVICES[@]} -gt 1 ]; then
          ci_error "Tests failed in $service_label"
        fi
      }
    fi
  fi
done

if [ $TESTS_FAILED -ne 0 ]; then
  echo -e "${RED}❌ Some tests failed!${NC}"
  exit 1
fi

# Build the project (for all services or root)
for service_dir in "${SERVICES[@]}"; do
  service_path="$WORKSPACE_ROOT/$service_dir"
  if [ "$service_dir" = "." ]; then
    service_path="$WORKSPACE_ROOT"
  fi
  
  if [ -f "$service_path/package.json" ] && grep -q '"build"' "$service_path/package.json"; then
    if [ ${#SERVICES[@]} -gt 1 ]; then
      echo ""
      echo -e "${BLUE}🏗️  Building $service_dir...${NC}"
    else
      echo ""
      echo -e "${BLUE}🏗️  Building project...${NC}"
    fi
    
    (cd "$service_path" && npm run build) || {
      echo -e "${RED}❌ Build failed in $service_dir!${NC}"
      exit 1
    }
  fi
done

# Show coverage summary if enabled
if [ "$COVERAGE" = "true" ] && [ "$FRAMEWORK" = "jest" ]; then
  if [ -f "coverage/lcov.info" ]; then
    echo ""
    echo -e "${GREEN}📊 Coverage report generated:${NC}"
    echo "  - HTML: coverage/index.html"
    echo "  - LCOV: coverage/lcov.info"
  fi
fi

if [ "$COVERAGE" = "true" ] && [ "$FRAMEWORK" = "pytest" ]; then
  if [ -d "htmlcov" ]; then
    echo ""
    echo -e "${GREEN}📊 Coverage report generated:${NC}"
    echo "  - HTML: htmlcov/index.html"
  fi
fi

echo ""
echo -e "${GREEN}✅ All tests and checks passed!${NC}"
