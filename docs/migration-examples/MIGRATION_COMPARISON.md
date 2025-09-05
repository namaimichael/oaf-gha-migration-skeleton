# Migration Comparison: Azure DevOps vs GitHub Actions

## Side-by-Side Pipeline Comparison

### Key Structural Changes

| Aspect | Azure DevOps | GitHub Actions |
|--------|--------------|----------------|
| File Location | azure-pipelines.yml (root) | .github/workflows/*.yml |
| Execution Model | Sequential stages | Parallel jobs by default |
| Authentication | Service Principal secrets | OIDC Federation |
| Container Registry | Single (ACR) | Dual (GHCR + ACR) |
| Variable Syntax | $(variableName) | ${{ vars.VARIABLE_NAME }} |
| Dependencies | dependsOn: | needs: |

## Security Improvements

### Before (Azure DevOps)
- Service Principal with client secret stored in Variable Groups
- Broad subscription-level permissions
- Manual secret rotation (24 months)
- Limited audit logging

### After (GitHub Actions)
- OIDC Federation (no stored secrets)
- Environment-scoped permissions
- Automatic token rotation
- Complete GitHub audit trail

## Performance Enhancements

### Parallel Execution
**ADO**: Build → Deploy (sequential)
**GHA**: build-test + build-push-image (can run in parallel after conditions met)

### Caching Strategy
**ADO**: Limited caching options
**GHA**: Built-in npm cache via actions/setup-node

### Registry Strategy
**ADO**: Single registry deployment
**GHA**: Dual registry for redundancy and flexibility

## Key Migration Benefits

1. **Eliminated Secrets**: No service principal credentials to manage
2. **Improved Security**: OIDC federation with least-privilege access
3. **Better Performance**: Parallel job execution and caching
4. **Dual Registry**: Both GHCR and ACR for flexibility
5. **Enhanced Audit**: Complete GitHub security logging

## Example Files

- **Before**: docs/migration-examples/before-ado/customer-service-ado.yml
- **After**: docs/migration-examples/after-gha/customer-service-gha.yml

## Migration Steps Applied

1. Replaced Variable Groups with GitHub secrets/vars
2. Changed task syntax to GitHub Actions marketplace actions
3. Implemented OIDC authentication
4. Added dual registry push capability
5. Configured parallel job execution
