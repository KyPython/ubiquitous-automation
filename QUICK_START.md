# 🚀 Quick Start Guide - Ubiquitous Automation

## ⚡ 30-Second Setup

```bash
# Clone and setup
git clone <repo-url> && cd ubiquitous-automation
npm run setup

# Make a change and commit (hooks run automatically!)
git add . && git commit -m "Test commit"
```

---

## 📝 Common Commands

### Local Development

| Command | Purpose | Speed |
|---------|---------|-------|
| `make lint` | Check code style | ~10s |
| `make test` | Run tests | ~30s |
| `make build` | Build project | ~20s |
| `make all` | Run all checks | ~1min |
| `make pre-commit` | Fast pre-commit check | ~30s |

### Alternative (npm)

| Command | Purpose |
|---------|---------|
| `npm run lint` | Check code style |
| `npm run lint:fix` | Auto-fix style issues |
| `npm test` | Run tests |
| `npm run test:watch` | Run tests in watch mode |
| `npm run test:all` | Run all checks |
| `npm run build` | Build project |

---

## 🎯 Typical Workflows

### Making Changes

```bash
# 1. Create feature branch
git checkout -b feature/my-feature

# 2. Make your changes
vim src/app/calculator.ts

# 3. Run checks locally (optional - pre-commit hooks will do this)
make pre-commit

# 4. Commit (hooks run automatically)
git add .
git commit -m "Add new calculator feature"

# 5. Push (CI will run automatically)
git push origin feature/my-feature
```

### What Happens Automatically

```
Your commit attempt
    ↓
Pre-commit hooks run (~10s)
├── ESLint (auto-fix)
├── Prettier (format)
├── YAML/JSON validation
└── Tests for changed files
    ↓
Commit succeeds ✅
    ↓
Push to GitHub
    ↓
CI Pipeline runs
├── Stage 1: Lint (~30s)
├── Stage 2: Tests (~2min)
└── Stage 3: Build (~30s)
    ↓
All green ✅
```

---

## 🐛 Troubleshooting

### Pre-commit hooks not running?

```bash
# Reinstall hooks
npx husky install
```

### Want to skip hooks (emergency only)?

```bash
git commit --no-verify -m "Emergency fix"
```

**⚠️ Warning**: This bypasses all safety checks. CI will still catch issues.

### CI failing but local passes?

```bash
# Run the exact same commands as CI
make lint
make test
make build
```

### Reset everything

```bash
# Clean and reinstall
make clean
rm -rf node_modules package-lock.json
npm install
make setup
```

---

## 📊 Understanding Feedback Times

| Layer | Check | Time | When |
|-------|-------|------|------|
| **Local** | Pre-commit hooks | ~10s | Every commit |
| **CI Stage 1** | Lint | ~30s | Every push |
| **CI Stage 2** | Tests | ~2min | If lint passes |
| **CI Stage 3** | Build | ~30s | If tests pass |

**Total CI time**: 3-4 minutes (if all pass), 30s if lint fails

---

## 🎓 Learn More

- **Security & monitoring**: `HARDENING.md`
- **Complete documentation**: `README.md`

---

## 🆘 Common Issues

### `make: command not found`

**macOS**: `make` is pre-installed  
**Linux**: `sudo apt install build-essential`  
**Windows**: Use WSL or Git Bash

### `husky: command not found`

```bash
npm install
npx husky install
```

### CI uses `make` but I don't have it

No problem! The CI will use `make`, but locally you can use:
```bash
npm run lint
npm test
npm run build
```

---

## ✅ Checklist for New Projects

Want to apply these patterns to your own project? Follow this checklist:

- [ ] Copy `.pre-commit-config.yaml`
- [ ] Copy `.lintstagedrc.json`
- [ ] Copy `Makefile` (customize for your stack)
- [ ] Copy `.prettierrc.json`
- [ ] Add `husky` and `lint-staged` to `devDependencies`
- [ ] Update `package.json` scripts (add `setup`, `prepare`, `pre-commit`)
- [ ] Update CI workflow to use `make` commands
- [ ] Add `fail-fast: true` to CI matrix
- [ ] Structure CI in stages (lint → test → build)
- [ ] Run `npm run setup` to test

---

**That's it!** You now have production-grade automation that saves ~35 min/day per developer. 🎉
