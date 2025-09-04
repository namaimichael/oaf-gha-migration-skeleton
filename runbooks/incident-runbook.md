# Incident Runbook
1. Inspect failing job logs; re-run with debug if needed.
2. Validate OIDC claims/role scopes in Azure.
3. If rollout failed: helm rollback app N-1.
4. Notify stakeholders; incident + RCA.
