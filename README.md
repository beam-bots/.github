# Beam Bots GitHub Organisation Configuration

[![CI](https://github.com/beam-bots/.github/actions/workflows/sync-rulesets.yml/badge.svg)](https://github.com/beam-bots/.github/actions/workflows/sync-rulesets.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache--2.0-green.svg)](https://opensource.org/licenses/Apache-2.0)
[![REUSE status](https://api.reuse.software/badge/github.com/beam-bots/.github)](https://api.reuse.software/info/github.com/beam-bots/.github)

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
- **Repository permissions**:
  - Administration: Read and write (for rulesets)
  - Metadata: Read-only (required)
  - Issues: Read and write (for failure notifications)
- **Organisation permissions**:
  - Members: Read-only (to resolve team names in bypass actors)

To create the token:

1. Go to https://github.com/settings/tokens?type=beta
2. Generate new token with the permissions above
3. Add as organisation secret: Settings → Secrets and variables → Actions → New organisation secret
