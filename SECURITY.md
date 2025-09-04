# SECURITY
- No long-lived cloud credentials in workflows.
- Use OIDC federation; env-scoped subjects.
- Required reviewers on staging/production environments.

### Signed commits (required)

We require signed commits and tags.

**Setup (developer):**
1. Install GPG (gnupg / Gpg4win).
2. `gpg --quick-generate-key "Your Name <you@example.com>" ed25519 sign 3y`
3. `gpg --armor --export <KEYID>` → Add to GitHub: Settings → SSH and GPG keys.
4. `git config --global user.signingkey <KEYID>`
5. `git config --global commit.gpgsign true`
6. (Optional) `git config --global tag.gpgsign true`

**Verification:** GitHub PRs must show **Verified** for all commits. Branch protection blocks unsigned commits.