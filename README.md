# One Acre Fund – GitHub Actions Migration Skeleton
Minimal reference repo to accompany the Final Interview Assessment.
Date: 2025-09-04

## Environment Strategy
- **dev** — fast feedback. Auto-deploys on push to `dev`. No approval gates.
- **staging** — release candidate. Deployed via workflow dispatch or PR promote; 1 approval required.
- **production** — customer-facing. Deployed via PR from `staging` to `main`; 2 approvals and signed commits required.
- **Governance** — Branch protections via Rulesets; required checks: service-ci (+ CodeQL). service-deploy can be required on staging/main once stable.
- **Provenance** — All commits are GPG/GitHub-signed; CODEOWNERS gate workflows and infra paths.

## Release Process
1. **Promote Dev → Staging**  
   Merge a PR from `dev` into `staging`. This creates a release candidate, auto-deployed to the Staging environment (requires 1 approval).
2. **Promote Staging → Main**  
   Merge a PR from `staging` into `main`. This deploys to Production (requires 2 approvals and signed commits).
3. **Tag and Release**  
   After merging to `main`, create a tag (`vX.Y.Z`). A GitHub Actions workflow generates release notes from merged PRs and publishes a GitHub Release.