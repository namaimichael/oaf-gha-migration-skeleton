# GitHub Actions Migration Skeleton

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

Tag with `v*` (e.g., `v1.0.0`) to trigger automatic GitHub release generation.
