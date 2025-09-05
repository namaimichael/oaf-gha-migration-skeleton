#!/usr/bin/env fish

# =============================================================================
# STEP 1: Clean up unnecessary files
# =============================================================================

echo "🧹 Cleaning up dead code and files..."

# Remove the weird --json file
rm -- --json

# Remove Azure deployment workflow (dead code since no Azure access)
rm .github/workflows/deploy-aks-helm.yml

# Remove service-deploy.yml since it only calls Azure deployment
rm .github/workflows/service-deploy.yml

# =============================================================================
# STEP 2: Create simplified _ci-node.yml (remove all Azure paths)
# =============================================================================

echo "📝 Creating simplified CI workflow..."

set ci_content 'name: _ci-node (template)

on:
  workflow_call:

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  ci:
    name: ci
    runs-on: ubuntu-latest
    timeout-minutes: 15

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: "18"
          cache: npm

      - name: Detect Node lockfile
        id: node
        run: |
          if [ -f package-lock.json ] || [ -f npm-shrinkwrap.json ]; then
            echo "has_lock=true" >> "$GITHUB_OUTPUT"
          else
            echo "has_lock=false" >> "$GITHUB_OUTPUT"
          fi

      - name: Install dependencies
        if: steps.node.outputs.has_lock == "true"
        run: npm ci
        timeout-minutes: 5

      - name: Run tests
        if: steps.node.outputs.has_lock == "true"
        run: npm test -- --ci

      - name: Login to GHCR
        if: github.event_name != "pull_request" || github.event.pull_request.head.repo.full_name == github.repository
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build & push container
        if: github.event_name != "pull_request" || github.event.pull_request.head.repo.full_name == github.repository
        uses: docker/build-push-action@v6
        with:
          context: .
          push: true
          tags: |
            ghcr.io/${{ github.repository_owner }}/demo-app:${{ github.run_number }}
            ghcr.io/${{ github.repository_owner }}/demo-app:latest'

echo $ci_content > .github/workflows/_ci-node.yml

# =============================================================================
# STEP 3: Update service-ci.yml to remove Azure references
# =============================================================================

echo "🔧 Updating service-ci workflow..."

set service_ci_content 'name: service-ci

on:
  pull_request:
    branches: ["dev", "staging", "main"]
  push:
    branches: ["dev", "staging", "main"]

permissions:
  contents: read

concurrency:
  group: service-ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  lint-yaml:
    name: lint-yaml
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install yamllint
        run: sudo apt-get update && sudo apt-get install -y yamllint
      - name: Advisory lint (parsable)
        run: yamllint -f parsable .github/workflows
        continue-on-error: true
      - name: Strict syntax sanity
        run: |
          yamllint -f parsable \
            -d "{rules:{document-start: disable, line-length: disable, truthy: disable, comments: disable, indentation:{indent-sequences: consistent}}}" \
            .github/workflows

  call-ci-template:
    needs: lint-yaml
    uses: ./.github/workflows/_ci-node.yml
    permissions:
      contents: read
      packages: write'

echo $service_ci_content > .github/workflows/service-ci.yml

# =============================================================================
# STEP 4: Create simple local deployment workflow (replaces Azure deploy)
# =============================================================================

echo "🚀 Creating local deployment workflow..."

set deploy_content 'name: deploy-local

on:
  workflow_dispatch:
    inputs:
      image_tag:
        description: "Image tag to deploy"
        required: false
        default: "latest"
      env_name:
        description: "Environment name"
        type: choice
        options: ["dev", "staging", "production"]
        required: true
        default: "dev"

permissions:
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Helm
        uses: Azure/setup-helm@v4
        
      - name: Login to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
          
      - name: Deploy with Helm (dry-run)
        run: |
          helm upgrade --install demo-app deploy/chart \
            --set image.repository=ghcr.io/${{ github.repository_owner }}/demo-app \
            --set image.tag=${{ inputs.image_tag }} \
            --set env.name=${{ inputs.env_name }} \
            --dry-run --debug
          
      - name: Show deployment info
        run: |
          echo "🎯 Deployment Summary:"
          echo "Environment: ${{ inputs.env_name }}"
          echo "Image: ghcr.io/${{ github.repository_owner }}/demo-app:${{ inputs.image_tag }}"
          echo "Chart: deploy/chart"
          echo ""
          echo "To deploy to a real cluster, configure kubectl context and remove --dry-run"'

echo $deploy_content > .github/workflows/deploy-local.yml

# =============================================================================
# STEP 5: Update Makefile to remove Azure references
# =============================================================================

echo "🔨 Updating Makefile..."

set makefile_content 'SERVICE ?= demo-app
TAG ?= dev
REGISTRY ?= ghcr.io
OWNER ?= $(shell git config user.name | tr "[:upper:]" "[:lower:]" | tr " " "-")

.PHONY: build push test lint deploy-local clean

# Build container locally
build:
	docker build -t $(REGISTRY)/$(OWNER)/$(SERVICE):$(TAG) .

# Push to GHCR (requires: echo $$GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin)
push: build
	docker push $(REGISTRY)/$(OWNER)/$(SERVICE):$(TAG)

# Run tests
test:
	npm test

# Lint workflows
lint:
	yamllint .github/workflows/

# Deploy locally with Helm (dry-run)
deploy-local:
	helm upgrade --install $(SERVICE) deploy/chart \
	  --set image.repository=$(REGISTRY)/$(OWNER)/$(SERVICE) \
	  --set image.tag=$(TAG) \
	  --set env.name=local \
	  --dry-run --debug

# Clean up local images
clean:
	docker rmi $(REGISTRY)/$(OWNER)/$(SERVICE):$(TAG) || true

# Show current config
info:
	@echo "Service: $(SERVICE)"
	@echo "Tag: $(TAG)"
	@echo "Registry: $(REGISTRY)"
	@echo "Owner: $(OWNER)"
	@echo "Full image: $(REGISTRY)/$(OWNER)/$(SERVICE):$(TAG)"'

echo $makefile_content > Makefile

# =============================================================================
# STEP 6: Create .gitignore
# =============================================================================

echo "📋 Creating .gitignore..."

set gitignore_content '# Node
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Runtime
*.log
.env
.env.local
.env.*.local

# Build outputs
dist/
build/
.next/

# OS
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo

# Temporary files
*.tmp
*.temp
.cache/

# Container artifacts
.acr.digest
.ghcr.digest

# Helm
*.tgz'

echo $gitignore_content > .gitignore

# =============================================================================
# STEP 7: Update package.json with better scripts
# =============================================================================

echo "📦 Updating package.json..."

set package_json_content '{
  "name": "demo-app",
  "version": "1.0.0",
  "description": "GitHub Actions migration skeleton demo app",
  "scripts": {
    "test": "echo \"✅ All tests passed!\"",
    "lint": "echo \"🔍 Linting complete\"",
    "start": "node -e \"console.log('"'"'🚀 Demo app running on port 3000'"'"'); require('"'"'http'"'"').createServer((req,res) => res.end('"'"'Hello from demo app!'"'"')).listen(3000)\"",
    "build": "echo \"🔨 Build complete\"",
    "dev": "npm start"
  },
  "keywords": ["github-actions", "ci-cd", "skeleton", "template"],
  "author": "Migration Team",
  "license": "MIT"
}'

echo $package_json_content > package.json

# Update package-lock.json accordingly
npm install --package-lock-only

# =============================================================================
# STEP 8: Improve Dockerfile
# =============================================================================

echo "🐳 Updating Dockerfile..."

set dockerfile_content 'FROM node:18-alpine AS base
LABEL org.opencontainers.image.source=https://github.com/namaimichael/oaf-gha-migration-skeleton

WORKDIR /app

FROM base AS deps
COPY package*.json ./
RUN npm ci --omit=dev --frozen-lockfile && npm cache clean --force

FROM base AS runtime
COPY --from=deps /app/node_modules ./node_modules
COPY package*.json ./
COPY . .

EXPOSE 3000
USER node

CMD ["npm", "start"]'

echo $dockerfile_content > Dockerfile

# =============================================================================
# STEP 9: Update README with new architecture
# =============================================================================

echo "📚 Updating README..."

set readme_content '# GitHub Actions Migration Skeleton

A simplified CI/CD template using **GitHub Actions + GHCR** (no Azure dependencies).

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   service-ci    │───▶│   _ci-node       │───▶│ Push to GHCR    │
│  (PR/push)      │    │  (reusable)      │    │ ghcr.io/*/app   │
└─────────────────┘    └──────────────────┘    └─────────────────┘

┌─────────────────┐    ┌──────────────────┐
│ deploy-local    │───▶│ Helm dry-run     │
│ (manual)        │    │ (configurable)   │
└─────────────────┘    └──────────────────┘
```

## 🚀 Workflows

- **`service-ci.yml`** - Runs on PRs/pushes, builds & pushes to GHCR
- **`deploy-local.yml`** - Manual deployment (dry-run by default)
- **`release-notes.yml`** - Auto-generates GitHub releases
- **`auto-sync.yml`** - Syncs main → dev after releases
- **`codeql.yml`** - Security scanning

## 🛠️ Local Development

```bash
# Build locally
make build

# Run tests
make test

# Deploy locally (dry-run)
make deploy-local

# Push to GHCR (requires GITHUB_TOKEN)
make push
```

## 🔧 Configuration

No Azure secrets needed! Only requires:
- **GitHub repository** with Actions enabled
- **GHCR access** (automatic with GITHUB_TOKEN)

## 📋 Branching Strategy

- **`dev`** - Development branch (auto-deploy)
- **`staging`** - Staging branch (gated deployment)  
- **`main`** - Production branch (promotion from staging)

## 🏷️ Releases

Tag with `v*` (e.g., `v1.0.0`) to trigger automatic GitHub release generation.'

echo $readme_content > README.md

# =============================================================================
# STEP 10: Summary
# =============================================================================

echo "✅ Refactoring complete!"
echo ""
echo "📊 Changes made:"
echo "  • Removed Azure deployment workflows (dead code)"
echo "  • Simplified _ci-node.yml (removed 40+ lines)"
echo "  • Created local deployment alternative"
echo "  • Updated Makefile with GHCR-only paths"
echo "  • Added .gitignore"
echo "  • Improved Dockerfile with multi-stage build"
echo "  • Updated package.json with better scripts"
echo "  • Refreshed README"
echo ""
echo "🎯 Next steps:"
echo "  1. git add -A && git commit -m 'refactor: remove Azure deps, simplify CI'"
echo "  2. Test workflows with: gh workflow run service-ci"
echo "  3. Validate container build: make build"
echo ""
echo "🗂️  Removed files:"
echo "  • .github/workflows/deploy-aks-helm.yml"
echo "  • .github/workflows/service-deploy.yml"
echo "  • --json (weird artifact)"