# Usage Examples

Practical examples for common Azure DevOps workflows using ado-flow.

## Installation and Initial Setup

### Quick Installation

```bash
# macOS/Linux - One command installation
curl -sSL https://raw.githubusercontent.com/abbeyseto/ado-flow/main/install.sh | bash

# Windows - PowerShell installation
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/abbeyseto/ado-flow/main/install.ps1'))
```

### First Time Setup

```bash
# Configure Azure DevOps connection
ado setup

# Follow interactive prompts:
# Organization URL: https://dev.azure.com/your-organization
# Project Name: YourProject
# Personal Access Token: [paste your PAT token]

# Test the installation
ado --help
ado my
```

### Project-Specific Configuration

```bash
# For projects with different organization/project settings
cd my-special-project

# Create project-specific configuration
echo "AZURE_DEVOPS_ORG_URL=https://dev.azure.com/different-org
AZURE_DEVOPS_PROJECT=DifferentProject
AZURE_DEVOPS_EXT_PAT=your_project_specific_token" > .env.azure-devops

# Test project-specific config
ado my
```

---

## Daily Workflow Examples

### Morning Standup Preparation

```bash
# Check your assigned work items
ado my

# Review specific work item details
ado show 123

# Check team's active work items
ado search "Active"
```

### Starting New Work

#### Scenario: Bug Fix

```bash
# 1. Create bug work item (with auto-assignment and optional linking)
ado create Bug "Login button not working on mobile devices" "Button click events not firing on iOS Safari"

# System will:
# - Auto-assign to your email
# - Prompt to link to existing Epic/Feature/Story/Task
# - Set appropriate bug fields (Severity: Medium, Priority: 2)
# Output: Work item #456 created successfully!
# Output: Assigned to: your.email@company.com
# Output: Successfully linked to parent work item #123

# 2. Start working on it
ado start 456

# This creates branch: workitem-456-login-button-not-working-on-mobile-devices
# Sets work item to Active state
# Adds comment about starting work
```

#### Scenario: Feature Development

```bash
# 1. Create hierarchical work items
ado create Epic "User Account Management"
# Output: Work item #100 created successfully!

ado create Feature "Password Reset System" "Comprehensive password reset with email verification"
# System prompts: Available Epics for linking:
# [Select Epic #100 - User Account Management]
# Output: Work item #200 created successfully!
# Output: Successfully linked to parent work item #100

ado create "User Story" "As a user I want to reset my password via email" "User can request password reset through forgot password link"
# System prompts: Available Features for linking:
# [Select Feature #200 - Password Reset System]  
# Output: Work item #789 created successfully!
# Output: Successfully linked to parent work item #200

# 2. Start development
ado start 789

# 3. Add progress updates during development
git commit -m "Add password reset form"
ado comment 789 "Completed password reset form implementation"

git commit -m "Add email service integration"  
ado comment 789 "Integrated with email service, testing in progress"

# 4. Create related tasks
ado create Task "Implement email template" "Create responsive HTML email template"
# System prompts to link to User Story #789
# Output: Successfully linked to parent work item #789
```

### Code Review Workflow

```bash
# 1. Complete your work
ado complete 456

# This sets work item to Resolved
# Adds completion comment with branch info

# 2. Create pull request (using GitHub CLI example)
gh pr create --title "[#456] Fix login button on mobile" --body "Fixes work item #456 - Login button not working on mobile devices"

# 3. After PR approval and merge, update work item
ado update 456 --state "Closed"
ado comment 456 "PR merged, deployed to production"
```

---

## Team Collaboration Examples

### Sprint Planning

```bash
# List all work items for planning
ado list

# Search for specific features
ado search "user authentication"
ado search "payment processing"

# Create epic for major initiative
ado create Epic "User Management System Overhaul" "Complete redesign of user authentication and profile management"
# Output: Work item #500 created successfully!

# Create features under the epic
ado create Feature "User Authentication" "OAuth 2.0 and multi-factor authentication"
# System prompts to link to Epic #500
# Output: Successfully linked to parent work item #500

ado create Feature "User Profile Management" "Profile editing, preferences, and data export"
# System prompts to link to Epic #500

# Create user stories under features
ado create "User Story" "User registration with email verification" "New users can create accounts with email confirmation"
# System prompts to link to Feature (User Authentication)

ado create "User Story" "Multi-factor authentication" "Users can enable 2FA for enhanced security"
# System prompts to link to Feature (User Authentication)

# Assign work items to team members
ado assign 501 developer1@company.com
ado assign 502 developer2@company.com

# Link existing bugs to new features if relevant
ado link 450 501  # Link existing auth bug to User Authentication feature
```

### Bug Triage

```bash
# Find all bugs
az boards query --wiql "SELECT [System.Id], [System.Title], [System.State] FROM WorkItems WHERE [System.WorkItemType] = 'Bug'"

# Create high priority bug
ado create Bug "Critical: Payment processing fails for credit cards"

# Assign to team member
ado update [new-bug-id] --assigned-to "developer@company.com" --priority 1

# Add detailed description
ado comment [new-bug-id] "Issue occurs on checkout page when using Visa/Mastercard. Users see 'Payment failed' error. Appears to be related to payment gateway integration."
```

### Code Review Process

```bash
# Reviewer workflow
# 1. Check work items ready for review
az boards query --wiql "SELECT [System.Id], [System.Title] FROM WorkItems WHERE [System.State] = 'Resolved' AND [System.AssignedTo] = @Me"

# 2. Review specific work item
ado show 123

# 3. Add review comments
ado comment 123 "Code review completed. Please address the following:
- Add unit tests for error scenarios
- Update documentation for new API endpoints  
- Consider edge case for empty input validation"

# 4. Move back to active if changes needed
ado update 123 --state "Active"

# 5. Or close if approved
ado update 123 --state "Closed"
```

---

## Advanced Workflows

### Release Management

```bash
# Track release-related work items
az boards query --wiql "SELECT [System.Id], [System.Title], [System.State] FROM WorkItems WHERE [System.Tags] CONTAINS 'release-v2.1'"

# Create release tracking epic
ado create Epic "Version 2.1 Release"

# Link related work items (manual process in web interface)
# Add release notes
ado comment [epic-id] "Release 2.1 includes:
- New user dashboard (#456)
- Payment processing improvements (#789)
- Mobile app bug fixes (#123, #124)"
```

### Hot Fix Workflow

```bash
# 1. Create critical bug
ado create Bug "CRITICAL: Production database connection timeout"

# 2. Start immediate work
ado start [bug-id]

# 3. Fast-track development
git commit -m "Quick fix for DB timeout issue"
ado comment [bug-id] "Applied temporary fix, monitoring production"

# 4. Complete and deploy
ado complete [bug-id]
ado comment [bug-id] "Hot fix deployed to production at $(date). Issue resolved."
```

### Research and Investigation

```bash
# 1. Create investigation task
ado create Task "Investigate performance degradation in search functionality"

# 2. Start research
ado start [task-id]

# 3. Document findings
ado comment [task-id] "Performance analysis results:
- Search queries taking 3x longer than baseline
- Database index fragmentation detected  
- Recommendation: Rebuild indexes and optimize query structure"

# 4. Create follow-up work items
ado create Task "Rebuild database indexes for search optimization"
ado create Task "Refactor search query structure for performance"

# 5. Complete investigation
ado complete [investigation-id]
```

---

## Integration with Other Tools

### GitHub Integration

```bash
# 1. Start work with ADO
ado start 456

# 2. Develop with meaningful commits
git commit -m "Fix login validation logic

Addresses work item #456 - Login button not working on mobile devices.
Updated form validation to properly handle mobile input events."

# 3. Create PR with work item reference
gh pr create \
  --title "[#456] Fix mobile login validation" \
  --body "Fixes #456

## Changes
- Updated mobile form validation
- Added touch event handlers  
- Fixed CSS for mobile responsiveness

## Testing
- Tested on iOS Safari and Android Chrome
- All login scenarios working correctly"

# 4. Complete work item after PR merge
ado complete 456
```

### Slack Integration (via webhooks/automation)

```bash
# Custom script for Slack notifications
notify_slack() {
    local work_item_id=$1
    local action=$2
    local message="Work item #${work_item_id} ${action} by $(git config user.name)"
    
    curl -X POST -H 'Content-type: application/json' \
      --data "{\"text\":\"$message\"}" \
      $SLACK_WEBHOOK_URL
}

# Use in workflow
ado start 456
notify_slack 456 "started"

ado complete 456  
notify_slack 456 "completed"
```

### JIRA Migration (if transitioning)

```bash
# Export work items for migration
az boards query --wiql "SELECT [System.Id], [System.Title], [System.Description], [System.State] FROM WorkItems" --output table > work_items_export.txt

# Create equivalent work items in new system
while IFS= read -r line; do
    # Parse and create work items
    # Implementation depends on target system
done < work_items_export.txt
```

---

## Troubleshooting Examples

### Connection Issues

```bash
# Test authentication
az account show

# Test Azure DevOps access
az boards query --wiql "SELECT [System.Id] FROM WorkItems" --top 1

# If authentication fails
az login --allow-no-subscriptions

# Re-run setup if needed
ado setup
```

### Work Item Issues

```bash
# If work item creation fails with validation errors
# Try minimal creation first
ado create Task "Test work item"

# Then add details via updates
ado update [id] --description "Detailed description here"
ado comment [id] "Additional context and requirements"
```

### Git Integration Issues

```bash
# If branch already exists
git branch -D workitem-123-existing-branch
ado start 123

# If you need to link existing branch
git checkout existing-feature-branch
ado comment 123 "Continuing work on existing branch: existing-feature-branch"
```

---

## Best Practices in Action

### Consistent Workflow

```bash
# Daily routine
morning_standup() {
    echo "=== Daily Standup Preparation ==="
    echo "My assigned work items:"
    ado my
    
    echo -e "\n=== Yesterday's Progress ==="  
    # Show work items updated in last 24 hours
    # (requires custom query)
    
    echo -e "\n=== Today's Plan ==="
    # Review active work items
}

# End of day routine  
end_of_day() {
    echo "=== End of Day Summary ==="
    echo "Completed work items:"
    # Show resolved work items from today
    
    echo -e "\n=== Tomorrow's Priorities ==="
    ado my | grep "Active"
}
```

### Documentation Standards

```bash
# Consistent comment format
add_progress_comment() {
    local work_item_id=$1
    local progress=$2
    local blockers=${3:-"None"}
    
    local comment="## Progress Update - $(date +%Y-%m-%d)

**Completed:**
$progress

**Blockers:** 
$blockers

**Next Steps:**
- [List next actions]

**Branch:** $(git rev-parse --abbrev-ref HEAD)"

    ado comment $work_item_id "$comment"
}

# Usage
add_progress_comment 123 "Implemented user authentication API" "Waiting for security review"
```

### Quality Gates

```bash
# Pre-completion checklist
complete_work_item() {
    local work_item_id=$1
    
    echo "Pre-completion checklist for work item #$work_item_id:"
    echo "[ ] All code committed and pushed"
    echo "[ ] Unit tests passing" 
    echo "[ ] Code review completed"
    echo "[ ] Documentation updated"
    echo "[ ] Ready for deployment"
    
    read -p "Complete work item? (y/N): " confirm
    if [[ $confirm == [yY] ]]; then
        ado complete $work_item_id
        echo "Work item #$work_item_id marked as completed!"
    fi
}
```

These examples demonstrate real-world usage patterns and can be adapted to your specific team workflows and requirements.
