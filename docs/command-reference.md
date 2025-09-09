# ado-flow - Command Reference

Complete reference for all ado-flow commands.

## Setup Commands

### `ado setup`
Configure global ado-flow settings.

**Usage:**
```bash
ado setup
```

**Interactive Setup:**
- Organization URL input
- Project name input
- Personal Access Token input (hidden)
- User email detection and confirmation
- Connection testing
- Configuration file creation

**Configuration File:** `~/.claude/ado-config.env`
**Includes:** PAT, Organization URL, Project, User Email for auto-assignment

**What it does:** Sets up ado-flow with your Azure DevOps organization and configures intelligent workflow automation.

---

## Query Commands

### `ado list`
List all work items in the current project.

**Usage:**
```bash
ado list
```

**Output:** JSON array of work items with ID, Title, State, AssignedTo, WorkItemType

### `ado my`
Show work items assigned to current user.

**Usage:**
```bash
ado my
```

**Auto-Detection:** Uses logged-in Azure account email

### `ado search [query]`
Search work items by title content.

**Usage:**
```bash
ado search "authentication"
ado search "login bug"
```

**Search Scope:** Work item titles only

### `ado show [id]`
Display detailed information for a specific work item.

**Usage:**
```bash
ado show 123
ado show 456
```

**Output:** Complete work item details including description, comments, history

---

## Work Item Management

### `ado create [type] [title] [description]`
Create new work items with automatic assignment and hierarchical linking.

**Usage:**
```bash
ado create Task "Fix authentication bug" "Update JWT validation logic"
ado create Bug "Login page crashes on mobile" "NullPointerException on iOS Safari"
ado create "User Story" "As a user I want to reset my password" "Password reset via email"
ado create Feature "User dashboard" "Comprehensive user profile and settings"
ado create Epic "Authentication system overhaul" "Complete redesign of auth system"
```

**Work Item Types:**
- **Epic** - High-level business objectives
- **Feature** - Major functionality areas  
- **User Story** - User-focused requirements
- **Task** - Implementation work items
- **Bug** - Defects and issues

**Auto-Features:**
- **Assignment**: Automatically assigned to creator's email
- **Type-Specific Fields**: Each work item type gets appropriate default fields
- **Hierarchical Linking**: Interactive prompts to link to parent work items
  - Features → Epics
  - User Stories → Features  
  - Tasks → User Stories
  - Bugs → Any work item type (flexible)
- **Smart Defaults**: Description includes creation context and branch info

**Type-Specific Fields:**
- **Epic**: Minimal fields (title + description)
- **Feature**: Target Date (+30 days), Acceptance Criteria template
- **User Story**: Risk (Medium), Acceptance Criteria, Story Points (3)
- **Task**: Time estimates (4h), Activity (Development)
- **Bug**: Severity (Medium), Priority (2), Reproduction Steps template

### `ado link [child-id] [parent-id]`
Link work items in parent-child relationships.

**Usage:**
```bash
ado link 456 123    # Link task 456 to story 123
ado link 789 456    # Link bug 789 to task 456
```

**Link Types:**
- Creates "parent" relationship from child to parent
- Supports Azure DevOps hierarchical work item structure
- Validates that both work items exist before linking

### `ado assign [id] [email-or-me]`
Assign work items to users.

**Usage:**
```bash
ado assign 123 me                    # Assign to yourself
ado assign 123 user@company.com      # Assign to specific user
```

**Email Detection:**
- "me" automatically resolves to your configured email
- Uses Azure CLI account email or git config email
- Falls back to configured user email from setup

### `ado update [id] [options]`
Update work item fields.

**Usage:**
```bash
ado update 123 --state "Active"
ado update 123 --assigned-to "user@domain.com"
ado update 123 --state "Resolved" --assigned-to "reviewer@domain.com"
```

**Common Update Options:**
- `--state [state]` - Change work item state
- `--assigned-to [email]` - Assign to user
- `--title [new-title]` - Update title
- `--description [text]` - Update description
- `--tags [tag1,tag2]` - Set tags

**Common States:**
- New, Active, Resolved, Closed, Removed

### `ado comment [id] [text]`
Add comments to work items.

**Usage:**
```bash
ado comment 123 "Started working on authentication fix"
ado comment 123 "Completed initial implementation, ready for review"
```

**Comment Features:**
- Markdown formatting supported
- Automatic timestamp and author
- Email notifications to watchers

---

## Git Integration Commands

### `ado start [id]`
Start work on a work item with git integration.

**Usage:**
```bash
ado start 123
```

**Actions Performed:**
1. **Fetch work item details** from Azure DevOps
2. **Create feature branch** with format: `workitem-[id]-[sanitized-title]`
3. **Switch to new branch** (git checkout)
4. **Update work item state** to "Active"
5. **Add comment** with branch information

**Branch Naming:**
- Non-alphanumeric characters converted to hyphens
- Multiple hyphens consolidated
- Leading/trailing hyphens removed
- Converted to lowercase

**Example:**
- Work Item: "Fix Authentication Bug!"
- Branch: `workitem-123-fix-authentication-bug`

### `ado complete [id]`
Mark work item as completed.

**Usage:**
```bash
ado complete 123
```

**Actions Performed:**
1. **Update work item state** to "Resolved"
2. **Add completion comment** with current branch info
3. **Include completion timestamp**

**Best Practice:** Run this when your code is ready for review, before creating pull requests.

---

## Configuration

### Configuration Hierarchy

1. **Project-level** (`./.env.azure-devops`)
   - Overrides global configuration
   - Project-specific settings
   - Team-specific defaults

2. **Global** (`~/.claude/ado-config.env`)
   - Default for all projects
   - Personal settings
   - Organization defaults

### Configuration Variables

**Required:**
```bash
AZURE_DEVOPS_EXT_PAT=your_token
AZURE_DEVOPS_ORG_URL=https://dev.azure.com/yourorg
AZURE_DEVOPS_PROJECT=YourProject
```

**Optional:**
```bash
AZURE_DEVOPS_AREA_PATH=Project\\Team
AZURE_DEVOPS_ITERATION_PATH=Project\\Sprint1
DEFAULT_ASSIGNEE=user@domain.com
DEFAULT_TAGS=tag1,tag2
```

### Personal Access Token (PAT)

**Required Scopes:**
- Work Items: Read & Write
- Code: Read (for git integration)

**Creation Steps:**
1. Go to Azure DevOps → User Settings → Personal Access Tokens
2. Create new token with required scopes
3. Copy token (shown only once)
4. Use in configuration

---

## Error Handling

### Common Error Scenarios

**Authentication Errors:**
```
ERROR: Please run 'az login' to setup account.
```
**Solution:** Run `az login` and authenticate

**Work Item Not Found:**
```
ERROR: TF401232: Work item [ID] does not exist
```
**Solution:** Verify work item ID exists in current project

**Permission Denied:**
```
ERROR: TF401027: You need the Generic Write permission
```
**Solution:** Check PAT scopes and Azure DevOps permissions

**Network Connectivity:**
```
ERROR: Please check your connection and try again
```
**Solution:** Verify internet connection and Azure DevOps availability

### Troubleshooting Steps

1. **Verify Azure CLI Installation:**
   ```bash
   az --version
   az extension list --query "[?name=='azure-devops']"
   ```

2. **Test Authentication:**
   ```bash
   az account show
   ```

3. **Test Azure DevOps Connection:**
   ```bash
   az boards query --wiql "SELECT [System.Id] FROM WorkItems" --top 1
   ```

4. **Check Configuration:**
   ```bash
   cat ~/.claude/ado-config.env
   ```

---

## Advanced Usage

### Custom Queries

**All Active Work Items:**
```bash
az boards query --wiql "SELECT [System.Id], [System.Title] FROM WorkItems WHERE [System.State] = 'Active'"
```

**Bugs Assigned to Me:**
```bash
az boards query --wiql "SELECT [System.Id], [System.Title] FROM WorkItems WHERE [System.WorkItemType] = 'Bug' AND [System.AssignedTo] = @Me"
```

**Work Items in Current Sprint:**
```bash
az boards query --wiql "SELECT [System.Id], [System.Title] FROM WorkItems WHERE [System.IterationPath] = @CurrentIteration"
```

### Bulk Operations

**Update Multiple Work Items:**
```bash
az boards work-item update --ids 123,124,125 --state "Resolved"
```

**Add Comments to Multiple Items:**
```bash
for id in 123 124 125; do ado comment $id "Sprint completed"; done
```

### Integration with Other Tools

**Git Commit Messages:**
```bash
git commit -m "Fix authentication bug

Addresses work item #123"
```

**Pull Request Templates:**
- Include work item ID in PR title
- Link to work item in PR description
- Reference completion status

---

## Best Practices

### Workflow Recommendations

1. **Start work:** `ado start [id]` before coding
2. **Regular updates:** `ado comment [id]` for progress
3. **Complete work:** `ado complete [id]` when ready for review
4. **Clean branches:** Delete feature branches after PR merge

### Branch Management

- Use `ado start` for consistent branch naming
- Keep branches focused on single work items
- Delete branches after successful merge

### Communication

- Add meaningful comments during development
- Include progress updates and blockers
- Tag relevant team members in comments

### Security

- Rotate PAT tokens regularly
- Use minimum required scopes
- Store configuration securely (600 permissions)
- Never commit tokens to version control