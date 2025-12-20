# Integration Patterns

This document describes the integration patterns implemented in the ubiquitous-automation project.

## 1. NPM Script Integration

All automation scripts are accessible via npm scripts following the `tool:action` naming pattern:

### Available Scripts

```json
{
  "scripts": {
    "test:all": "./scripts/test-all.sh",
    "lint:test": "./scripts/lint-and-test.sh",
    "pre-commit": "./scripts/pre-commit.sh",
    "quality:check": "./scripts/test-all.sh",
    "quality:lint": "./scripts/lint-and-test.sh",
    "git:pre-commit": "./scripts/pre-commit.sh"
  }
}
```

### Usage

```bash
# Quick quality check
npm run quality:check

# Quick lint and test
npm run quality:lint

# Pre-commit checks
npm run pre-commit
```

**Benefits:**
- Consistent naming pattern across all tools
- Easy to remember and discover
- Works across all platforms (Windows, macOS, Linux)
- Integrated with npm ecosystem

## 2. Multi-Service Project Support

Scripts automatically detect and handle multiple services/workspaces in monorepo structures.

### Auto-Discovery

The scripts look for services in:
- Root directory (`.`)
- `frontend/`, `backend/`, `api/`, `services/`, `packages/`, `apps/` directories
- Any subdirectory containing:
  - `package.json` (Node.js/TypeScript)
  - `pyproject.toml` (Python)
  - `Cargo.toml` (Rust)
  - `go.mod` (Go)

### Usage

```bash
# Auto-detect (single service by default)
./scripts/test-all.sh

# Explicitly enable multi-service mode
./scripts/test-all.sh --multi-service

# Or via environment variable
MULTI_SERVICE=true ./scripts/test-all.sh
```

### Example Structure

```
project-root/
├── package.json          # Root service
├── frontend/
│   └── package.json      # Frontend service
├── backend/
│   └── package.json      # Backend service
└── automation/
    └── pyproject.toml    # Python automation service
```

When `--multi-service` is enabled, the script will:
1. Discover all services
2. Run tests/lint/build for each service
3. Aggregate results
4. Report failures per service

## 3. CI/CD Integration

All scripts are CI-friendly and work seamlessly in CI environments.

### Auto-Detection

Scripts automatically detect CI environments via environment variables:
- `CI=true`
- `GITHUB_ACTIONS`
- `GITLAB_CI`
- `JENKINS_URL`
- `TRAVIS`
- `CIRCLECI`
- And many more...

### CI-Specific Behavior

When running in CI:

1. **Script Execution**: Scripts are automatically made executable
2. **Git Diff Strategy**: Uses appropriate git diff commands (PR diff, merge-base, etc.)
3. **Output Format**: Uses CI-native annotations (GitHub Actions, GitLab CI, etc.)
4. **Graceful Failures**: Optional checks fail gracefully with warnings
5. **Parallel Execution**: Can be disabled if needed (`CI_PARALLEL=false`)

### GitHub Actions Example

```yaml
- name: Make scripts executable
  run: chmod +x scripts/*.sh || true

- name: Run quality checks
  run: npm run quality:check || echo "⚠️ Some optional checks failed (continuing)"

- name: Run tests
  run: npm run test:all
```

### Environment Variables

```bash
# Force CI mode
CI=true ./scripts/test-all.sh

# Disable parallel in CI
CI_PARALLEL=false ./scripts/test-all.sh

# Custom cache directory
CACHE_DIR=.custom-cache ./scripts/pre-commit.sh

# Custom config file
PRE_COMMIT_CONFIG=my-config.json ./scripts/pre-commit.sh
```

### Graceful Failures

Optional checks use `|| true` pattern in CI:

```bash
# This will warn but not fail the build in CI
npm run quality:lint || echo "⚠️ Some optional linting checks failed (continuing)"
```

## 4. Shared Utilities

A shared library (`scripts/lib.sh`) provides common functionality:

### Functions Available

- `detect_ci()` - Detect if running in CI
- `is_ci()` - Return CI status as string
- `ensure_executable()` - Make scripts executable
- `find_workspace_root()` - Find project root
- `discover_services()` - Discover services in monorepo
- `detect_test_framework_in_dir()` - Detect test framework
- `run_optional()` - Run optional commands (fail gracefully in CI)
- `ci_info()`, `ci_warning()`, `ci_error()` - CI-aware logging

### Usage in Scripts

```bash
# Source the library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/lib.sh" ]; then
  source "$SCRIPT_DIR/lib.sh"
fi

# Use functions
if [ "$(is_ci)" = "true" ]; then
  ci_info "Running in CI mode"
fi
```

## 5. Configuration

### Pre-commit Configuration

Create `.pre-commit-config.json` to customize pre-commit behavior:

```json
{
  "run_lint": true,
  "run_test": true,
  "run_build": true,
  "parallel": true,
  "cache": true
}
```

Copy `.pre-commit-config.json.example` to get started.

### Cache Management

Caching is enabled by default and stores results in `.pre-commit-cache/`:

```bash
# Custom cache directory
CACHE_DIR=.custom-cache ./scripts/pre-commit.sh

# Disable caching
CACHE_ENABLED=false ./scripts/pre-commit.sh
```

## Best Practices

1. **Use npm scripts**: Prefer `npm run` over direct script execution for consistency
2. **Enable multi-service**: Use `--multi-service` flag in monorepo projects
3. **CI-friendly**: Scripts are automatically CI-friendly, no extra config needed
4. **Cache results**: Caching is enabled by default to speed up checks
5. **Incremental checks**: Use `lint-and-test.sh` for faster feedback on changed files only

## Troubleshooting

### Scripts not executable

```bash
chmod +x scripts/*.sh
```

Or set in CI:
```yaml
- run: chmod +x scripts/*.sh || true
```

### Multi-service not working

Ensure you're using the `--multi-service` flag or set `MULTI_SERVICE=true`.

### CI detection not working

Explicitly set `CI=true`:
```bash
CI=true ./scripts/test-all.sh
```

### Cache issues

Clear cache directory:
```bash
rm -rf .pre-commit-cache
```
