---
name: glab
description: Comprehensive GitLab CLI tool for managing merge requests, issues, CI pipelines, repositories, and API access. Use when working with any GitLab operations including creating/updating MRs or issues, checking CI status, managing repositories, or making API calls.
---

# GitLab CLI (glab) Comprehensive Guide

This skill provides complete coverage of `glab` CLI operations for GitLab management. It includes proper syntax, common patterns, and troubleshooting for all major glab functionality.

---

## Table of Contents

1. [Merge Requests](#merge-requests)
2. [Issues](#issues)
3. [CI/Pipelines](#cipipelines)
4. [Repository Operations](#repository-operations)
5. [Labels](#labels)
6. [Releases](#releases)
7. [CI Schedules](#ci-schedules)
8. [Config](#config)
9. [API Access](#api-access)
10. [Authentication](#authentication)
11. [Common Patterns](#common-patterns)
12. [String Escaping](#string-escaping)

---

## Merge Requests

### Creating MRs

```bash
# Basic MR creation
glab mr create --title "Title" --description "Description" --target-branch BRANCH --assignee @me

# Draft MR
glab mr create --title "WIP: Feature" --draft --target-branch master --assignee @me

# Multi-line description with heredoc
glab mr create --title "Feature: Add X" \
  --description "$(cat <<'EOF'
## Summary
Feature description

## Changes
- Change 1
- Change 2

## Testing
Test details
EOF
)" \
  --target-branch master --assignee @me
```

**Key flags**:

- `--title, -t`: MR title
- `--description, -d`: MR description
- `--target-branch, -b`: Target branch (required - e.g., master, RC2, ACI)
- `--assignee, -a`: Assign MR (use `@me` for yourself)
- `--draft`: Mark as draft/WIP
- `--label, -l`: Add labels (can use multiple times)
- `--milestone, -m`: Set milestone

### Viewing MRs

```bash
# View specific MR
glab mr view MR_ID

# View with comments/activity
glab mr view MR_ID --comments

# View in web browser
glab mr view MR_ID --web

# View MR for current branch
glab mr view

# List all open MRs
glab mr list

# List closed MRs
glab mr list --state closed

# List MRs assigned to me
glab mr list --assignee @me

# List MRs by source branch
glab mr list --source-branch BRANCH_NAME

# List MRs by target branch
glab mr list --target-branch BRANCH_NAME

# List draft MRs
glab mr list --draft

# Filter by reviewer
glab mr list --reviewer @me

# Filter by author
glab mr list --author USERNAME

# Search by keyword in title/description
glab mr list --search "keyword"

# Exclude a label
glab mr list --not-label "wontfix"
```

### Updating MRs

```bash
# Update description
glab mr update MR_ID --description "New description"

# Update title
glab mr update MR_ID --title "New title"

# Update multiple fields
glab mr update MR_ID --title "Title" --description "Desc" --assignee @user

# Mark as ready (remove draft status)
glab mr update MR_ID --ready

# Add labels
glab mr update MR_ID --label "bug" --label "priority"

# Multi-line description update
glab mr update MR_ID --description "$(cat <<'EOF'
## Summary
Updated summary

## Key Points
- Point 1
- Point 2
EOF
)"
```

### MR Comments

```bash
# Add comment (note)
glab mr note MR_ID --message "Comment text"

# Multi-line comment
glab mr note MR_ID --message "$(cat <<'EOF'
## Feedback
Detailed feedback here

Points:
- Item 1
- Item 2
EOF
)"
```

**CRITICAL**: Use `--message` flag, NOT bare string.

- ❌ Wrong: `glab mr note 4502 "comment"`
- ✅ Correct: `glab mr note 4502 --message "comment"`

### Merging MRs

```bash
# Merge when pipeline succeeds
glab mr merge MR_ID --when-pipeline-succeeds

# Merge immediately
glab mr merge MR_ID

# Merge and remove source branch
glab mr merge MR_ID --remove-source-branch

# Squash merge
glab mr merge MR_ID --squash

# Merge with all options
glab mr merge MR_ID --squash --remove-source-branch --when-pipeline-succeeds
```

### Other MR Operations

```bash
# Close MR
glab mr close MR_ID

# Reopen MR
glab mr reopen MR_ID

# Approve MR
glab mr approve MR_ID

# Revoke approval
glab mr revoke MR_ID

# Check out MR branch locally
glab mr checkout MR_ID

# Get diff
glab mr diff MR_ID
```

---

## Issues

### Creating Issues

```bash
# Basic issue
glab issue create --title "Issue title" --description "Description"

# Issue with labels
glab issue create --title "Bug: Something broken" \
  --description "Bug description" \
  --label "bug" --label "priority"

# Issue with assignee and milestone
glab issue create --title "Feature request" \
  --description "Details" \
  --assignee @me \
  --milestone "v2.0"

# Multi-line description
glab issue create --title "Complex Issue" \
  --description "$(cat <<'EOF'
## Problem
Description of problem

## Steps to Reproduce
1. Step 1
2. Step 2

## Expected Behavior
What should happen

## Actual Behavior
What actually happens
EOF
)"
```

**Key flags**:

- `--title, -t`: Issue title
- `--description, -d`: Issue description
- `--assignee, -a`: Assign issue
- `--label, -l`: Add labels (repeatable)
- `--milestone, -m`: Set milestone
- `--confidential`: Mark as confidential
- `--weight, -w`: Set issue weight

### Viewing Issues

```bash
# View specific issue
glab issue view ISSUE_ID

# View in web browser
glab issue view ISSUE_ID --web

# List all open issues
glab issue list

# List closed issues
glab issue list --state closed

# List issues assigned to me
glab issue list --assignee @me

# List issues with specific label
glab issue list --label "bug"

# Search issues
glab issue list --search "keyword"
```

### Updating Issues

```bash
# Update title
glab issue update ISSUE_ID --title "New title"

# Update description
glab issue update ISSUE_ID --description "New description"

# Add labels
glab issue update ISSUE_ID --label "bug" --label "urgent"

# Remove labels
glab issue update ISSUE_ID --unlabel "old-label"

# Change assignee
glab issue update ISSUE_ID --assignee @newuser

# Lock/unlock issue
glab issue update ISSUE_ID --lock
glab issue update ISSUE_ID --unlock
```

### Issue Comments

```bash
# Add comment (note)
glab issue note ISSUE_ID --message "Comment text"

# Multi-line comment
glab issue note ISSUE_ID --message "$(cat <<'EOF'
## Update
Status update here

Progress:
- Completed X
- Working on Y
EOF
)"
```

### Other Issue Operations

```bash
# Close issue
glab issue close ISSUE_ID

# Reopen issue
glab issue reopen ISSUE_ID

# Delete issue
glab issue delete ISSUE_ID

# Subscribe to issue notifications
glab issue subscribe ISSUE_ID

# Unsubscribe
glab issue unsubscribe ISSUE_ID
```

---

## CI/Pipelines

### Viewing Pipelines

```bash
# View CI for current branch
glab ci view

# View CI for specific branch
glab ci view --branch BRANCH_NAME

# View specific pipeline
glab ci view PIPELINE_ID

# List pipelines
glab ci list

# Filter by status (valid values: running|pending|success|failed|canceled|skipped|created|manual|waiting_for_resource|preparing|scheduled)
glab ci list --status failed
glab ci list --status running
glab ci list --status pending

# Order and sort
glab ci list --orderBy updated_at --sort desc
```

### Pipeline Operations

```bash
# Retry a job (by ID, name, or interactively)
glab ci retry JOB_ID
glab ci retry JOB_NAME
glab ci retry                   # interactively select

# Cancel pipeline
glab ci cancel PIPELINE_ID

# Delete pipeline
glab ci delete PIPELINE_ID

# Trace/logs for a job in real time (outputs ANSI escape codes)
glab ci trace JOB_ID
glab ci trace JOB_NAME          # can use job name instead of ID (e.g. "build_14_3")
glab ci trace                   # interactively select a job if no arg given

# Strip ANSI codes from trace output
glab ci trace JOB_ID | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g'
# Note: GitLab CI section markers (section_start:..., section_end:...) are NOT ANSI codes
# and will remain in the output after stripping. They can be further removed with:
glab ci trace JOB_ID | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g' | sed 's/section_[a-z]*:[0-9]*:[a-z_]*//g'

# Job IDs can be found via:
glab ci get --with-job-details

# Trigger a manual CI job
glab ci trigger JOB_ID

# Download artifacts from last pipeline
glab ci artifact JOB_ID --path artifacts/
```

### Running Pipelines

```bash
# Run a new pipeline on current branch
glab ci run

# Run pipeline on specific branch
glab ci run --branch BRANCH_NAME

# Run pipeline with variables
glab ci run --branch BRANCH_NAME --variables-env KEY:value

# Lint .gitlab-ci.yml
glab ci lint
glab ci lint path/to/.gitlab-ci.yml
```

### Pipeline Status & Info

```bash
# Get status of latest pipeline
glab ci status

# Get status for specific branch
glab ci status --branch BRANCH_NAME

# Get JSON details of pipeline
glab ci get
glab ci get --branch BRANCH_NAME
glab ci get --pipeline-id PIPELINE_ID
glab ci get --output-format json | jq .
glab ci get --output-format json | jq '{status: .status, jobs: [.jobs[] | {name: .name, status: .status, duration: .duration}]}'
glab ci get --with-job-details
glab ci get --with-variables

# Interactive TUI view of pipeline jobs (requires a real TTY - will crash in non-interactive shells)
glab ci view
```

---

## Repository Operations

### Repository Info

```bash
# View current repository
glab repo view

# View specific repository
glab repo view OWNER/REPO

# View in web browser
glab repo view --web

# Clone repository
glab repo clone OWNER/REPO

# Fork repository
glab repo fork OWNER/REPO
```

### Repository Management

```bash
# List repositories
glab repo list

# List user's repositories
glab repo list --owner USERNAME

# Search repositories
glab repo search QUERY

# Create repository
glab repo create NEW_REPO_NAME --description "Description"

# Archive repository (get archive/download)
glab repo archive OWNER/REPO

# Delete repository
glab repo delete OWNER/REPO

# List contributors
glab repo contributors

# Mirror a repository (pull or push)
glab repo mirror

# Transfer repository to new namespace
glab repo transfer OWNER/REPO NEW_NAMESPACE
```

### Repository Settings

```bash
# View repository settings
glab repo view --with-projects-enabled

# Get repository variables
glab variable list

# Set repository variable
glab variable set VAR_NAME VALUE

# Delete repository variable
glab variable delete VAR_NAME
```

---

## Labels

```bash
# List labels in project
glab label list

# Create a label
glab label create --name "bug" --color "#FF0000" --description "Bug report"
```

---

## Releases

```bash
# List releases
glab release list

# View a release
glab release view TAG_NAME

# Create a release
glab release create TAG_NAME --name "v1.0.0" --notes "Release notes"

# Create with asset file
glab release create TAG_NAME --assets-links '[{"name":"binary","url":"https://..."}]'

# Upload asset to existing release
glab release upload TAG_NAME ./binary.tar.gz

# Download release assets
glab release download TAG_NAME

# Delete a release
glab release delete TAG_NAME
```

---

## CI Schedules

```bash
# List CI schedules
glab schedule list

# Create a schedule
glab schedule create --cron "0 * * * *" --description "Hourly pipeline" --ref master

# Run a scheduled pipeline immediately
glab schedule run SCHEDULE_ID

# Delete a schedule
glab schedule delete SCHEDULE_ID
```

---

## Config

```bash
# View current config
glab config get token
glab config get host

# Set config values
glab config set editor vim
glab config set browser firefox
glab config set glamour_style dark   # dark, light, notty
glab config set glab_pager "less -R"
glab config set check_update false
glab config set display_hyperlinks true

# Global config (vs per-repo)
glab config set --global token YOUR_TOKEN

# Interactive setup
glab config init
```

---

## API Access

### Making API Calls

```bash
# GET request
glab api projects/:id/merge_requests

# POST request
glab api projects/:id/issues -F title="Bug" -F description="Details"

# PUT request
glab api projects/:id/merge_requests/:mr_iid -X PUT -F description="Updated"

# DELETE request
glab api projects/:id/issues/:issue_iid -X DELETE

# Get with pagination
glab api projects/:id/merge_requests --paginate

# Pretty print JSON
glab api projects/:id | jq .
```

### Common API Endpoints

```bash
# List project MRs
glab api projects/:id/merge_requests

# Get specific MR
glab api projects/:id/merge_requests/:mr_iid

# List project issues
glab api projects/:id/issues

# Get user info
glab api user

# List project members
glab api projects/:id/members

# Get project details
glab api projects/:id

# List branches
glab api projects/:id/repository/branches

# List commits
glab api projects/:id/repository/commits
```

---

## Authentication

### Login/Authentication

```bash
# Login interactively
glab auth login

# Login with token
glab auth login --token YOUR_TOKEN

# Login to specific GitLab instance
glab auth login --hostname gitlab.example.com

# Check authentication status
glab auth status

# List authenticated accounts
glab auth status --show-token
```

### Token Management

```bash
# Use token from environment
export GITLAB_TOKEN=your_token_here
glab mr list

# Use token from file
export GITLAB_TOKEN=$(cat ~/.gitlab-token)

# Per-command token
glab mr list --token YOUR_TOKEN
```

### Environment Variables

```bash
GITLAB_TOKEN         # Authentication token for API requests
GITLAB_HOST          # Self-managed GitLab URL (e.g. https://gitlab.example.com)
GL_HOST              # Alternative to GITLAB_HOST
REMOTE_ALIAS         # Git remote alias that contains the GitLab URL (default: origin)
VISUAL / EDITOR      # Editor for authoring text (in order of precedence)
BROWSER              # Web browser for opening links
GLAMOUR_STYLE        # Markdown renderer style: dark, light, notty
NO_PROMPT=1          # Disable interactive prompts
NO_COLOR             # Disable ANSI color output (set to any value)
GLAB_CONFIG_DIR      # Override global configuration directory
FORCE_HYPERLINKS=1   # Force hyperlinks in output even when not a TTY
```

---

## Common Patterns

### Working with Current Branch

```bash
# Create MR for current branch
glab mr create --fill --target-branch master --assignee @me

# View MR for current branch
glab mr view

# Check CI status for current branch
glab ci status
```

### Bulk Operations

```bash
# Close all MRs with specific label
for mr in $(glab mr list --label "wontfix" --per-page 100 | awk '{print $1}' | grep -E '^[0-9]+$'); do
  glab mr close $mr
done

# List all open issues assigned to me
glab issue list --assignee @me --state opened

# Approve all MRs assigned to me
for mr in $(glab mr list --assignee @me | awk '{print $1}' | grep -E '^[0-9]+$'); do
  glab mr approve $mr
done
```

### Working with Multiple Projects

```bash
# Specify repository explicitly
glab mr list -R owner/repo

# View MR in different project
glab mr view 123 -R owner/other-repo

# Create issue in different project
glab issue create -R owner/repo --title "Title"
```

### MR Description Updates (Cumulative)

**IMPORTANT**: Always check the MR's target branch first and diff against that, not a hardcoded branch like "master".

```bash
# Step 1: Find the MR for current branch
glab mr list --source-branch $(git branch --show-current)

# Step 2: View the MR to see its target branch
glab mr view MR_ID

# Step 3: Extract target branch programmatically (if needed)
TARGET_BRANCH=$(glab api projects/:id/merge_requests/MR_IID | jq -r '.target_branch')

# Step 4: View commits since target branch
git log origin/${TARGET_BRANCH}..HEAD --oneline

# Or manually if you know the target (e.g., RC2, master, ACI)
git log origin/RC2..HEAD --oneline
git diff origin/RC2..HEAD --stat

# Step 5: Generate comprehensive description based on actual diff
glab mr update MR_ID --description "$(cat <<'EOF'
## Summary
[Cumulative summary of ALL changes since branching from target branch]

## Key Changes
- Feature/fix 1 (commit abc123)
- Feature/fix 2 (commit def456)
- Feature/fix 3 (commit ghi789)

## Testing
How these changes were tested

## Notes
Any additional context
EOF
)"
```

**Why this matters**: MRs may target different branches (RC2, RC1, master, ACI, etc.). Using the wrong base branch for git log/diff will show too many or too few commits.

---

## String Escaping

### Heredoc Best Practices

Use single quotes in heredoc delimiter to prevent shell expansion:

```bash
# Correct - prevents variable expansion
glab mr create --title "Title" --description "$(cat <<'EOF'
Content with $variables and `backticks`
EOF
)"

# Wrong - will expand $variables
glab mr create --title "Title" --description "$(cat <<EOF
Content with $variables
EOF
)"
```

### Special Characters

```bash
# Backticks in code blocks - escape them
glab mr update 123 --description "Use \`code\` for inline code"

# Multi-line with code blocks
glab mr update 123 --description "$(cat <<'EOF'
## Code Example

\`\`\`python
def hello():
    print("world")
\`\`\`
EOF
)"

# Dollar signs - use single quotes in heredoc
glab issue note 456 --message "$(cat <<'EOF'
The variable $PATH should be set
EOF
)"
```

### Quotes and Escaping

```bash
# Double quotes in message - escape them
glab mr note 123 --message "He said \"hello\""

# Or use single quotes
glab mr note 123 --message 'He said "hello"'

# Newlines in simple messages - use heredoc
glab mr note 123 --message "$(cat <<'EOF'
Line 1
Line 2
Line 3
EOF
)"
```

---

## Troubleshooting

### Common Issues

**Authentication Errors**:

```bash
# Check auth status
glab auth status

# Re-authenticate
glab auth login
```

**Project Not Found**:

```bash
# Verify current project
glab repo view

# Specify project explicitly
glab mr list -R owner/repo
```

**Rate Limiting**:

```bash
# Use pagination for large results
glab api projects/:id/merge_requests --paginate
```

**Finding IDs**:

```bash
# Find MR number for current branch
glab mr list --source-branch $(git branch --show-current)

# Find issue by search
glab issue list --search "keyword"

# Find pipeline ID
glab ci list --branch $(git branch --show-current)
```

### Debugging

```bash
# See raw API response
glab api projects/:id/merge_requests/123

# Get JSON pipeline details
glab ci get --output-format json | jq .

# Check version
glab version
glab check-update
```

---

## Best Practices

1. **Always specify target branch** for MRs - don't rely on defaults
2. **Check MR target branch before diffing** - use `glab mr view MR_ID` to see what branch the MR targets, then diff against that (e.g., `origin/RC2`, not hardcoded `master`)
3. **Use heredoc for multi-line content** - prevents escaping issues
4. **Update MR descriptions cumulatively** - include ALL changes since branching from the MR's target branch
5. **Use `@me` for self-assignment** - clearer than username
6. **Add meaningful labels** - helps with organization and filtering
7. **Comment on significant updates** - keep stakeholders informed
8. **Use `--draft` for WIP** - prevents premature merging
9. **Check CI status before merging** - use `glab ci status`
10. **Use descriptive titles** - format as "[Component] Brief description"
11. **Leverage `--web` flag** - open in browser for complex operations

---

## Quick Reference

### Most Common Commands

```bash
# MRs
glab mr create --title "..." --description "..." --target-branch master --assignee @me
glab mr list
glab mr view MR_ID
glab mr update MR_ID --description "..."
glab mr note MR_ID --message "..."
glab mr merge MR_ID

# Issues
glab issue create --title "..." --description "..."
glab issue list
glab issue view ISSUE_ID
glab issue close ISSUE_ID
glab issue note ISSUE_ID --message "..."

# CI
glab ci view
glab ci status
glab ci list

# Repo
glab repo view
glab repo clone OWNER/REPO

# API
glab api ENDPOINT
glab auth status
```

### Common Flags

- `--title, -t`: Set title
- `--description, -d`: Set description
- `--assignee, -a`: Assign to user (use `@me`)
- `--label, -l`: Add label (repeatable)
- `--milestone, -m`: Set milestone
- `--web, -w`: Open in web browser
- `--draft`: Mark as draft
- `-R, --repo`: Specify repository
- `--message`: Message for notes/comments

---

## Examples from Real Usage

### Example: Create comprehensive MR

```bash
glab mr create \
  --title "OpenWifi: Add automatic certificate sync from APs" \
  --description "$(cat <<'EOF'
## Summary
Implements automatic certificate synchronization from OpenWifi access points to rXg database on AP startup.

## Changes
- Added cert_sync ingestor to handle CSR/certificate updates
- Implemented PEM extraction to handle OpenSSL command output
- Added test coverage for cert_sync command
- Simplified implementation to use batch queue directly

## Testing
Tested with real APs showing CSR/certificate sync to database

## Related Issues
Closes #1234
EOF
)" \
  --target-branch master \
  --assignee @me \
  --label "feature" \
  --label "openwifi"
```

### Example: Update MR after code review

```bash
# View feedback
glab mr view 4502

# Make code changes
git add .
git commit -m "Address review feedback"
git push

# Update MR description with all changes
glab mr update 4502 --description "$(cat <<'EOF'
## Summary
[Updated summary reflecting all cumulative changes]

## Changes
- Original changes
- Updates from review feedback

## Testing
Expanded test coverage
EOF
)"

# Add comment about changes
glab mr note 4502 --message "Updated implementation based on review feedback: simplified error handling and added additional test cases"
```

### Example: Create bug issue

```bash
glab issue create \
  --title "Bug: Certificate sync fails with OpenSSL output" \
  --description "$(cat <<'EOF'
## Problem
Certificate sync fails when certificate includes OpenSSL subject/issuer lines.

## Steps to Reproduce
1. Run cert_sync command on AP
2. Certificate includes extra output
3. PEM extraction fails

## Expected Behavior
Should extract just the PEM portion

## Actual Behavior
Fails to parse certificate

## Environment
- Version: 2.5.0
- Component: OpenWifi cert sync

## Logs
\`\`\`
Error: Invalid certificate format
\`\`\`
EOF
)" \
  --label "bug" \
  --label "openwifi" \
  --assignee @me
```

### Example: Check CI and merge

```bash
# Check CI status
glab ci status

# View pipeline details
glab ci view

# If CI passing, merge MR
glab mr merge 4502 --when-pipeline-succeeds --remove-source-branch
```
