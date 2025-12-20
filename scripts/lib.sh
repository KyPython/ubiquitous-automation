#!/bin/bash

# lib.sh - Shared utility functions for automation scripts
# Provides CI detection, workspace discovery, and common helpers

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect if running in CI environment
detect_ci() {
  # Common CI environment variables
  if [ -n "${CI}" ] || \
     [ -n "${GITHUB_ACTIONS}" ] || \
     [ -n "${GITLAB_CI}" ] || \
     [ -n "${JENKINS_URL}" ] || \
     [ -n "${TRAVIS}" ] || \
     [ -n "${CIRCLECI}" ] || \
     [ -n "${BITBUCKET_BUILD_NUMBER}" ] || \
     [ -n "${TEAMCITY_VERSION}" ] || \
     [ -n "${APPVEYOR}" ] || \
     [ -n "${AZURE_HTTP_USER_AGENT}" ]; then
    return 0  # true
  else
    return 1  # false
  fi
}

# Check if running in CI
is_ci() {
  if detect_ci; then
    echo "true"
  else
    echo "false"
  fi
}

# Make scripts executable (safe for CI)
ensure_executable() {
  local script_path="$1"
  if [ -f "$script_path" ] && [ ! -x "$script_path" ]; then
    chmod +x "$script_path" 2>/dev/null || true
  fi
}

# Find workspace root (directory containing package.json, pyproject.toml, etc.)
find_workspace_root() {
  local dir="${1:-$(pwd)}"
  local original_dir="$dir"
  
  while [ "$dir" != "/" ]; do
    # Check for common root indicators
    if [ -f "$dir/package.json" ] || \
       [ -f "$dir/pyproject.toml" ] || \
       [ -f "$dir/Cargo.toml" ] || \
       [ -f "$dir/go.mod" ] || \
       [ -f "$dir/.git/config" ] && [ -f "$dir/Makefile" ]; then
      echo "$dir"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  
  # Fallback to current directory
  echo "$original_dir"
}

# Discover services/workspaces in monorepo
discover_services() {
  local root="${1:-$(pwd)}"
  local services=()
  
  # Check root level
  if [ -f "$root/package.json" ] || [ -f "$root/pyproject.toml" ] || [ -f "$root/Cargo.toml" ]; then
    services+=(".")
  fi
  
  # Check common service directories
  for dir in frontend backend api services packages apps; do
    if [ -d "$root/$dir" ]; then
      # Check subdirectories
      for subdir in "$root/$dir"/*; do
        if [ -d "$subdir" ]; then
          if [ -f "$subdir/package.json" ] || \
             [ -f "$subdir/pyproject.toml" ] || \
             [ -f "$subdir/Cargo.toml" ] || \
             [ -f "$subdir/go.mod" ]; then
            services+=("$subdir")
          fi
        fi
      done
    fi
  done
  
  # Also check direct subdirectories at root
  for subdir in "$root"/*; do
    if [ -d "$subdir" ] && [ "$subdir" != "$root/node_modules" ] && [ "$subdir" != "$root/dist" ]; then
      if [ -f "$subdir/package.json" ] || \
         [ -f "$subdir/pyproject.toml" ] || \
         [ -f "$subdir/Cargo.toml" ] || \
         [ -f "$subdir/go.mod" ]; then
        # Avoid duplicates
        local already_added=false
        for service in "${services[@]}"; do
          if [ "$service" = "$subdir" ]; then
            already_added=true
            break
          fi
        done
        if [ "$already_added" = "false" ]; then
          services+=("$subdir")
        fi
      fi
    fi
  done
  
  # Output services, one per line
  for service in "${services[@]}"; do
    echo "$service"
  done
}

# Detect test framework in a directory
detect_test_framework_in_dir() {
  local dir="$1"
  
  if [ ! -d "$dir" ]; then
    echo "unknown"
    return
  fi
  
  # Check for Jest (TypeScript/JavaScript)
  if [ -f "$dir/package.json" ] && grep -q '"jest"' "$dir/package.json" 2>/dev/null; then
    echo "jest"
    return
  fi
  if [ -f "$dir/jest.config.js" ] || [ -f "$dir/jest.config.ts" ] || [ -f "$dir/jest.config.json" ]; then
    echo "jest"
    return
  fi
  
  # Check for Pytest (Python)
  if [ -f "$dir/pytest.ini" ] || [ -f "$dir/setup.py" ] || [ -f "$dir/requirements.txt" ]; then
    if command -v pytest &> /dev/null; then
      echo "pytest"
      return
    fi
  fi
  
  # Check for Mocha
  if [ -f "$dir/package.json" ] && grep -q '"mocha"' "$dir/package.json" 2>/dev/null; then
    echo "mocha"
    return
  fi
  
  # Check for npm test script
  if [ -f "$dir/package.json" ] && grep -q '"test"' "$dir/package.json" 2>/dev/null; then
    echo "npm"
    return
  fi
  
  echo "unknown"
}

# Run command with graceful failure (for optional checks in CI)
run_optional() {
  local description="$1"
  shift
  local command="$@"
  
  if detect_ci; then
    # In CI, allow failures but log them
    if eval "$command"; then
      return 0
    else
      echo -e "${YELLOW}⚠️  $description failed (non-blocking in CI)${NC}" >&2
      return 0  # Return success even on failure for optional checks
    fi
  else
    # Local: run normally
    eval "$command"
  fi
}

# Run command with error handling appropriate for CI
run_with_ci_handling() {
  local description="$1"
  local optional="${2:-false}"
  shift 2
  local command="$@"
  
  if [ "$optional" = "true" ]; then
    run_optional "$description" "$command"
  else
    if detect_ci; then
      # In CI, ensure scripts are executable and run
      ensure_executable "$(which $1)" 2>/dev/null || true
    fi
    eval "$command"
  fi
}

# Print CI-aware messages
ci_info() {
  local message="$1"
  if detect_ci; then
    echo "::notice::$message"
  else
    echo -e "${BLUE}ℹ️  $message${NC}"
  fi
}

ci_warning() {
  local message="$1"
  if detect_ci; then
    echo "::warning::$message"
  else
    echo -e "${YELLOW}⚠️  $message${NC}"
  fi
}

ci_error() {
  local message="$1"
  if detect_ci; then
    echo "::error::$message"
  else
    echo -e "${RED}❌ $message${NC}"
  fi
}
