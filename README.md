# Ubiquitous Automation Demo

> **"Automate Everything You Can"** - The Pragmatic Programmer

[![CI](https://github.com/KyPython/ubiquitous-automation/actions/workflows/ci.yml/badge.svg)](https://github.com/KyPython/ubiquitous-automation/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This project demonstrates **Ubiquitous Automation** principles from [The Pragmatic Programmer](https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/) by Hunt & Thomas. It showcases how to automate routine development tasks and establish continuous integration practices.

## 🎯 What is Ubiquitous Automation?

Ubiquitous Automation is the practice of automating repetitive, mundane tasks that developers encounter daily. As Hunt & Thomas explain:

> "Computers are supposed to make our lives easier, and that means not having to do the same things over and over. Any process you do more than once should be automated. This includes:
> - Building your project
> - Running tests
> - Generating documentation
> - Deploying your application"

This demo puts these principles into practice by automating:

- ✅ **Testing** - Automated test execution
- ✅ **Linting** - Code quality checks
- ✅ **Building** - Compilation and artifact generation
- ✅ **CI/CD** - Continuous Integration via GitHub Actions

## 📁 Project Structure

```
ubiquitous-automation/
├── app/                    # Application source code (src/app/)
│   ├── calculator.ts      # Simple calculator class
│   ├── greeter.ts         # Greeting utility
│   └── task-runner.ts     # Task execution simulator
├── scripts/               # Local automation scripts
│   ├── test-all.sh        # Run all tests and checks
│   ├── lint-and-test.sh   # Quick lint + test
│   └── pre-commit.sh      # Pre-commit validation
├── .github/workflows/     # CI/CD automation
│   └── ci.yml            # GitHub Actions workflow
└── src/                   # TypeScript source files
```

## 🚀 Getting Started

### Prerequisites

- Node.js 18.x or higher
- npm or yarn

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd ubiquitous-automation

# Install dependencies
npm install
```

### Running the Application

```bash
# Development mode (with ts-node)
npm run dev

# Build and run
npm run build
npm start
```

### Running Tests

```bash
# Run all tests
npm test

# Watch mode
npm run test:watch

# Run all checks (lint + test + build)
npm run test:all
```

### Linting

```bash
# Check for issues
npm run lint

# Auto-fix issues
npm run lint:fix
```

## 🤖 Automation Scripts

The `scripts/` directory contains shell scripts that automate common workflows:

### `test-all.sh`

Comprehensive test suite runner that executes linting, testing, and building:

```bash
./scripts/test-all.sh
```

This script:
- Installs dependencies if needed
- Runs the linter
- Executes all tests
- Builds the project

### `lint-and-test.sh`

Quick workflow for linting and testing before committing:

```bash
./scripts/lint-and-test.sh
```

### `pre-commit.sh`

Pre-commit validation script (can be used as a git hook):

```bash
./scripts/pre-commit.sh
```

This script:
- Auto-fixes linting issues
- Runs tests
- Verifies the build

## 🔄 Continuous Integration

The project includes a GitHub Actions workflow (`.github/workflows/ci.yml`) that automatically:

1. **Installs dependencies** on every push and pull request
2. **Runs linter** to ensure code quality
3. **Executes tests** across multiple Node.js versions (18.x, 20.x)
4. **Builds the project** to verify compilation
5. **Uploads coverage reports** (optional, using Codecov)

### CI Workflow Triggers

The CI pipeline runs on:
- Push to `main` or `develop` branches
- Pull requests targeting `main` or `develop` branches

### Viewing CI Results

1. Navigate to the **Actions** tab in your GitHub repository
2. Select a workflow run to view detailed logs
3. See test results, build status, and any failures

## 📚 Key Concepts Demonstrated

### 1. **Don't Repeat Yourself (DRY)**

All automation is centralized:
- Scripts eliminate manual command repetition
- CI pipeline ensures consistent execution
- NPM scripts provide simple interface

### 2. **Automated Testing**

Tests are automated at multiple levels:
- **Local**: `npm test` or `./scripts/test-all.sh`
- **Pre-commit**: `./scripts/pre-commit.sh`
- **CI**: Automatic on every push/PR

### 3. **Fail Fast**

The automation scripts use `set -e` to exit immediately on any error, catching issues early.

### 4. **Single Command Execution**

Complex workflows are reduced to simple commands:
- `npm run test:all` - Complete validation
- `./scripts/test-all.sh` - Comprehensive check

## 🔧 Customization

### Adding New Tasks

1. **Add NPM script** in `package.json`:
   ```json
   "scripts": {
     "your-task": "your-command"
   }
   ```

2. **Update automation scripts** to include the new task

3. **Update CI workflow** if needed

### Extending the CI Pipeline

Edit `.github/workflows/ci.yml` to add:
- Additional Node.js versions
- Deployment steps
- Security scans
- Performance tests

## 📖 Learn More

- [The Pragmatic Programmer](https://pragprog.com/titles/tpp20/the-pragmatic-programmer-20th-anniversary-edition/) - Chapter 3: The Basic Tools
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Jest Testing Framework](https://jestjs.io/)
- [ESLint](https://eslint.org/)

## 🤝 Contributing

This is a demo project, but contributions are welcome! When contributing:

1. Run `./scripts/pre-commit.sh` before committing
2. Ensure all tests pass
3. Follow the existing code style

## 🌐 Deployment

This project is configured for deployment to [Vercel](https://vercel.com), providing automatic deployments from GitHub.

### Automatic Deployment Setup

1. **Connect to Vercel**:
   - Visit [vercel.com](https://vercel.com)
   - Sign in with your GitHub account
   - Click "Import Project"
   - Select the `ubiquitous-automation` repository
   - Vercel will automatically detect the configuration

2. **Deploy**:
   - Click "Deploy"
   - Your app will be live at `https://ubiquitous-automation.vercel.app`
   - Every push to `main` will trigger a new deployment

### API Endpoints

Once deployed, the following endpoints are available:

- **`/api`** - Main API information
- **`/api/health`** - Enhanced health check with system metrics
- **`/api/demo`** - Demo endpoint showcasing application features
- **`/api/monitor`** - Monitoring and observability endpoint

### Error Handling & Monitoring

This project includes comprehensive error handling and monitoring:

- **Error Handling**: All endpoints use centralized error handling with proper error codes and status codes
- **Input Validation**: Request validation with detailed error messages
- **Logging**: Structured logging with different log levels (DEBUG, INFO, WARN, ERROR)
- **Monitoring**: Request metrics, system metrics, and error tracking
- **Health Checks**: Enhanced health endpoint with memory usage, uptime, and request statistics

#### Monitoring Endpoint Usage

```bash
# Get system metrics
GET /api/monitor?action=metrics

# Get recent logs
GET /api/monitor?action=logs&level=ERROR&limit=50

# Get recent requests
GET /api/monitor?action=requests&limit=100

# Reset monitoring (requires token)
GET /api/monitor?action=reset&token=YOUR_TOKEN
```

### Manual Deployment

You can also deploy manually using the Vercel CLI:

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel

# Deploy to production
vercel --prod
```

## 💼 DevOps Productivity Suite

This project is part of the **DevOps Productivity Suite** - a comprehensive package combining 5 production-ready DevOps tools:

- **Shell Games Toolkit** - Automation scripts
- **Ubiquitous Automation** (this project) - CI/CD pipelines
- **Git Workflows Sample** - Source control best practices
- **Code Generator Tool** - Boilerplate generation
- **Software Entropy** - Code quality scanner

**Package Details:** $2,997 setup + $297/month  
**Includes:** Custom configuration, team training, documentation, ongoing support

📖 See `DEVOPS_PRODUCTIVITY_SUITE.md` for complete package information.  
📋 Quick reference: `PACKAGE_QUICK_REFERENCE.md`  
📅 Book a call: https://calendly.com/kyjahn-smith/consultation

---

## 📝 License

MIT License - feel free to use this as a template for your own projects!

---

**Remember**: The goal of ubiquitous automation isn't just to save time—it's to eliminate the possibility of human error in repetitive tasks. Automate what you can, so you can focus on what matters: solving problems and building great software.

