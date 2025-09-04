# Release Runbook
1. Merge PR to main (checks green).
2. CI builds/scans and pushes image to ACR.
3. Deploy to staging (env approval), verify, then promote to production.
4. Post-release checks and comms.
