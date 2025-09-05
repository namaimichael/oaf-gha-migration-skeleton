#!/usr/bin/env fish

echo "Azure DevOps to GitHub Actions Migration Demonstration"
echo "=================================================="
echo ""

echo "Repository Structure:"
ls -la docs/migration-examples/
echo ""

echo "1. BEFORE - Azure DevOps Pipeline"
echo "   File: docs/migration-examples/before-ado/customer-service-ado.yml"
echo "   Key characteristics:"
echo "   - Sequential stages (Build -> Deploy)"
echo "   - Service Principal authentication"
echo "   - Single container registry (ACR)"
echo ""

echo "2. AFTER - GitHub Actions Workflow"  
echo "   File: docs/migration-examples/after-gha/customer-service-gha.yml"
echo "   Key improvements:"
echo "   - Parallel job execution"
echo "   - OIDC authentication (no stored secrets)"
echo "   - Dual registry support (GHCR + ACR)"
echo ""

echo "3. Migration Benefits:"
echo "   - Eliminated service principal secrets"
echo "   - Parallel execution improves performance"
echo "   - Dual registry redundancy"
echo ""

echo "4. View detailed comparison:"
echo "   cat docs/migration-examples/MIGRATION_COMPARISON.md"
echo ""

echo "Demonstration complete."
