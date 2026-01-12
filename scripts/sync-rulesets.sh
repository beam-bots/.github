#!/usr/bin/env bash
# Sync repository rulesets across all repos in the beam-bots organisation
set -euo pipefail

ORG="beam-bots"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RULESETS_DIR="${SCRIPT_DIR}/../rulesets"

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No colour

log_info() { echo -e "${GREEN}[INFO]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Days before expiry to start warning
EXPIRY_WARNING_DAYS=30

# Check token expiration and warn/fail appropriately
check_token_expiration() {
  local response
  response=$(gh api /user --include 2>&1) || {
    log_error "Failed to authenticate with GitHub API. Check your token."
    exit 1
  }

  # Extract expiration header (format: "2027-01-12 00:00:00 UTC")
  local expiry_header
  expiry_header=$(echo "$response" | grep -i "GitHub-Authentication-Token-Expiration:" | sed 's/.*: //' | tr -d '\r' || true)

  if [[ -z "$expiry_header" ]]; then
    log_info "Token has no expiration date set"
    return 0
  fi

  # Parse expiry date (handle format: "2027-01-12 00:00:00 UTC")
  local expiry_epoch
  expiry_epoch=$(date -j -f "%Y-%m-%d %H:%M:%S %Z" "$expiry_header" "+%s" 2>/dev/null) || \
  expiry_epoch=$(date -d "$expiry_header" "+%s" 2>/dev/null) || {
    log_warn "Could not parse token expiration date: ${expiry_header}"
    return 0
  }

  local now_epoch
  now_epoch=$(date "+%s")

  local days_until_expiry
  days_until_expiry=$(( (expiry_epoch - now_epoch) / 86400 ))

  if [[ $days_until_expiry -lt 0 ]]; then
    log_error "Token has EXPIRED (${expiry_header})"
    log_error "Create a new token at: https://github.com/settings/tokens?type=beta"
    log_error "Then update the RULESET_SYNC_TOKEN secret in organisation settings"
    exit 1
  elif [[ $days_until_expiry -le $EXPIRY_WARNING_DAYS ]]; then
    log_warn "Token expires in ${days_until_expiry} days (${expiry_header})"
    log_warn "Create a new token at: https://github.com/settings/tokens?type=beta"
    log_warn "Then update the RULESET_SYNC_TOKEN secret in organisation settings"
  else
    log_info "Token valid for ${days_until_expiry} days (expires: ${expiry_header})"
  fi
}

# Look up team ID by slug
get_team_id() {
  local team_slug="$1"
  gh api "orgs/${ORG}/teams/${team_slug}" --jq '.id' 2>/dev/null || echo ""
}

# Get all repos in the org (excluding .github, archived, and forks)
get_repos() {
  gh api "orgs/${ORG}/repos" --paginate --jq '
    .[] | select(.archived == false and .fork == false and .name != ".github") | .name
  '
}

# Get existing rulesets for a repo
get_existing_rulesets() {
  local repo="$1"
  gh api "repos/${ORG}/${repo}/rulesets" 2>/dev/null || echo "[]"
}

# Find ruleset ID by name
find_ruleset_id() {
  local existing="$1"
  local name="$2"
  echo "$existing" | jq -r --arg name "$name" '.[] | select(.name == $name) | .id // empty'
}

# Prepare ruleset JSON by resolving team names to IDs
prepare_ruleset() {
  local ruleset_file="$1"
  local ruleset_json
  ruleset_json=$(cat "$ruleset_file")

  # Check if there are any team bypass actors with actor_name
  if echo "$ruleset_json" | jq -e '.bypass_actors[]? | select(.actor_type == "Team" and .actor_name)' >/dev/null 2>&1; then
    # Resolve team names to IDs
    local team_names
    team_names=$(echo "$ruleset_json" | jq -r '.bypass_actors[] | select(.actor_type == "Team" and .actor_name) | .actor_name')

    for team_name in $team_names; do
      local team_id
      team_id=$(get_team_id "$team_name")
      if [[ -n "$team_id" ]]; then
        ruleset_json=$(echo "$ruleset_json" | jq --arg name "$team_name" --argjson id "$team_id" '
          .bypass_actors |= map(
            if .actor_type == "Team" and .actor_name == $name then
              .actor_id = $id | del(.actor_name)
            else .
            end
          )
        ')
      else
        log_warn "Could not find team: ${team_name}"
      fi
    done
  fi

  echo "$ruleset_json"
}

# Create a new ruleset
create_ruleset() {
  local repo="$1"
  local ruleset_json="$2"
  local name
  name=$(echo "$ruleset_json" | jq -r '.name')

  log_info "Creating ruleset '${name}' for ${repo}"
  if gh api "repos/${ORG}/${repo}/rulesets" --method POST --input - <<< "$ruleset_json" >/dev/null; then
    log_info "Created ruleset '${name}' for ${repo}"
  else
    log_error "Failed to create ruleset '${name}' for ${repo}"
    return 1
  fi
}

# Update an existing ruleset
update_ruleset() {
  local repo="$1"
  local ruleset_id="$2"
  local ruleset_json="$3"
  local name
  name=$(echo "$ruleset_json" | jq -r '.name')

  log_info "Updating ruleset '${name}' (ID: ${ruleset_id}) for ${repo}"
  if gh api "repos/${ORG}/${repo}/rulesets/${ruleset_id}" --method PUT --input - <<< "$ruleset_json" >/dev/null; then
    log_info "Updated ruleset '${name}' for ${repo}"
  else
    log_error "Failed to update ruleset '${name}' for ${repo}"
    return 1
  fi
}

# Sync a single ruleset to a repo
sync_ruleset_to_repo() {
  local repo="$1"
  local ruleset_file="$2"
  local existing_rulesets="$3"

  local ruleset_json
  ruleset_json=$(prepare_ruleset "$ruleset_file")

  local name
  name=$(echo "$ruleset_json" | jq -r '.name')

  local existing_id
  existing_id=$(find_ruleset_id "$existing_rulesets" "$name")

  if [[ -n "$existing_id" ]]; then
    update_ruleset "$repo" "$existing_id" "$ruleset_json"
  else
    create_ruleset "$repo" "$ruleset_json"
  fi
}

# Main sync function
main() {
  log_info "Starting ruleset sync for organisation: ${ORG}"

  # Verify token is valid and not expiring soon
  check_token_expiration

  # Check for ruleset files
  if [[ ! -d "$RULESETS_DIR" ]] || [[ -z "$(ls -A "$RULESETS_DIR"/*.json 2>/dev/null)" ]]; then
    log_error "No ruleset files found in ${RULESETS_DIR}"
    exit 1
  fi

  local repos
  repos=$(get_repos)

  if [[ -z "$repos" ]]; then
    log_warn "No repositories found"
    exit 0
  fi

  local repo_count=0
  local error_count=0

  for repo in $repos; do
    log_info "Processing repository: ${repo}"
    repo_count=$((repo_count + 1))

    local existing_rulesets
    existing_rulesets=$(get_existing_rulesets "$repo")

    for ruleset_file in "$RULESETS_DIR"/*.json; do
      if ! sync_ruleset_to_repo "$repo" "$ruleset_file" "$existing_rulesets"; then
        error_count=$((error_count + 1))
      fi
    done
  done

  log_info "Sync complete. Processed ${repo_count} repositories with ${error_count} errors."

  if [[ $error_count -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
