#!/bin/bash
# Error handling utilities for DevOps Productivity Suite
# Standardized error codes and logging - integrates with existing lib.sh

# Exit codes (standardized across all tools)
EXIT_SUCCESS=0
EXIT_FAILURE=1
EXIT_PARTIAL=2
EXIT_CONFIG_ERROR=3
EXIT_USAGE_ERROR=4

# Source existing lib.sh if available for CI detection
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/../lib.sh" ]; then
  source "$SCRIPT_DIR/../lib.sh"
fi

# Detect CI environment (use existing function if available, otherwise detect)
if command -v detect_ci &> /dev/null; then
  if detect_ci; then
    CI_MODE=true
    export NO_COLOR=1
  else
    CI_MODE=false
  fi
elif [ "$CI" = "true" ] || [ -n "$GITHUB_ACTIONS" ] || [ -n "$GITLAB_CI" ] || [ -n "$CIRCLECI" ]; then
  CI_MODE=true
  export NO_COLOR=1
else
  CI_MODE=false
fi

# Get tool name from script path or environment
TOOL_NAME="${TOOL_NAME:-$(basename "${BASH_SOURCE[1]}" .sh)}"

# Logging functions (use existing ci_* functions if available, otherwise create)
if command -v ci_info &> /dev/null; then
  log_info() {
    ci_info "$1"
  }
  log_warn() {
    ci_warning "$1"
  }
  log_error() {
    ci_error "$1"
  }
else
  # Fallback logging functions
  log_error() {
    local message="$1"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%d %H:%M:%S")
    echo "[$TOOL_NAME] [ERROR] [$timestamp] $message" >&2
  }

  log_warn() {
    local message="$1"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%d %H:%M:%S")
    if [ "$QUIET" != "true" ]; then
      echo "[$TOOL_NAME] [WARN] [$timestamp] $message" >&2
    fi
  }

  log_info() {
    local message="$1"
    if [ "$QUIET" != "true" ]; then
      echo "[$TOOL_NAME] [INFO] $message"
    fi
  }
fi

log_debug() {
  local message="$1"
  if [ "$VERBOSE" = "true" ] && [ "$QUIET" != "true" ]; then
    if command -v ci_info &> /dev/null; then
      ci_info "[DEBUG] $message"
    else
      echo "[$TOOL_NAME] [DEBUG] $message"
    fi
  fi
}

# Usage error
usage_error() {
  local message="$1"
  local usage_text="$2"
  log_error "$message"
  if [ -n "$usage_text" ]; then
    echo "$usage_text" >&2
  fi
  exit $EXIT_USAGE_ERROR
}

# Config error
config_error() {
  local message="$1"
  log_error "$message"
  exit $EXIT_CONFIG_ERROR
}

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}
