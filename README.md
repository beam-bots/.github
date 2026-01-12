# Beam Bots GitHub Organisation Configuration

This repository contains organisation-wide configuration for beam-bots:

- **Community health files** - Default CODE_OF_CONDUCT, CONTRIBUTING, SECURITY, etc.
- **Repository rulesets** - Branch and tag protection rules synced to all repos

See: https://docs.github.com/en/communities/setting-up-your-project-for-healthy-contributions/creating-a-default-community-health-file

## Repository Rulesets

The `rulesets/` directory contains JSON configuration for branch and tag protection rules that are automatically synced to all repositories in the organisation.

### Current Rulesets

| File | Target | Description |
|------|--------|-------------|
| `branch-main.json` | Default branch | Prevents deletion, force-push, direct commits; requires PR with 1 review and signed commits |
| `tag-all.json` | All tags | Prevents deletion and modification; requires signed tags; release team can bypass |

### How It Works

A GitHub Action runs daily (and on config changes) to sync these rulesets to all non-archived, non-fork repositories in the organisation. New repositories are automatically configured on the next sync.

### Making Changes

1. Edit the JSON files in `rulesets/`
2. Create a PR (changes to this repo require review)
3. Once merged, the sync workflow runs automatically

### Token Requirements

The sync workflow requires a fine-grained Personal Access Token stored as `RULESET_SYNC_TOKEN` with:

- **Resource owner**: beam-bots organisation
- **Repository access**: All repositories
- **Permissions**:
  - Administration: Read and write (for rulesets)
  - Metadata: Read-only (required)

To create the token:

1. Go to https://github.com/settings/tokens?type=beta
2. Generate new token with the permissions above
3. Add as organisation secret: Settings → Secrets and variables → Actions → New organisation secret
