# Azure DevOps Integration Guide

This document explains how to use the Azure DevOps integration with this project.

## Quick Start

1. **Setup (one time):**
   ```bash
   ./scripts/setup-azure-devops.sh
   ```

2. **List your work items:**
   ```bash
   ./scripts/ado.sh my
   ```

3. **Create a quick task:**
   ```bash
   ./scripts/create-task.sh "Fix authentication bug"
   ```

## Available Scripts

### Main ADO Tool (`./scripts/ado.sh`)

#### List and Search
- `./scripts/ado.sh list` - List all work items
- `./scripts/ado.sh search "keyword"` - Search work items by title
- `./scripts/ado.sh my` - Show your assigned work items
- `./scripts/ado.sh show 123` - Show details of work item #123

#### Create and Update
- `./scripts/ado.sh create Task "Task title"` - Create new work item
- `./scripts/ado.sh update 123 --state "In Progress"` - Update work item
- `./scripts/ado.sh assign 123 user@domain.com` - Assign work item
- `./scripts/ado.sh comment 123 "Progress update"` - Add comment

### Quick Task Creator (`./scripts/create-task.sh`)

Quick templates for common development tasks:

- `./scripts/create-task.sh fix-bug "Authentication not working"`
- `./scripts/create-task.sh feature "Add user dashboard"`
- `./scripts/create-task.sh test "Integration tests for API"`
- `./scripts/create-task.sh docs "Update API documentation"`
- `./scripts/create-task.sh refactor "Clean up user service"`

### Git Integration (`./scripts/git-workitem.sh`)

Link your git workflow with Azure DevOps:

- `./scripts/git-workitem.sh start 123` - Create branch and set work item to Active
- `./scripts/git-workitem.sh progress 123` - Update work item with progress
- `./scripts/git-workitem.sh complete 123` - Mark work item as Resolved
- `./scripts/git-workitem.sh link 123` - Link current commit to work item

## Work Item Types Available

- **Task** - Individual work items
- **Bug** - Bug fixes
- **User Story** - User-focused features  
- **Feature** - Major feature development
- **Epic** - Large initiatives
- **Issue** - General issues

## Common States

- **New** - Just created
- **Active** - Currently being worked on
- **Resolved** - Work completed, ready for review
- **Closed** - Completed and verified
- **Removed** - Cancelled

## Integration Workflow

### Starting Work
1. Find or create a work item: `./scripts/ado.sh create Task "Your task"`
2. Start work on it: `./scripts/git-workitem.sh start [work-item-id]`
3. This creates a branch and sets the work item to Active

### During Development
1. Make commits as usual
2. Update progress: `./scripts/git-workitem.sh progress [work-item-id]`
3. Link important commits: `./scripts/git-workitem.sh link [work-item-id]`

### Completing Work
1. Complete the work item: `./scripts/git-workitem.sh complete [work-item-id]`
2. This sets the work item to Resolved
3. Create PR as usual (script provides suggested title)

## Configuration

Your Azure DevOps configuration is stored in `.env.azure-devops`:

```bash
AZURE_DEVOPS_EXT_PAT=your_personal_access_token
AZURE_DEVOPS_ORG_URL=https://dev.azure.com/parallelscore
AZURE_DEVOPS_PROJECT=ParallelScorePortfolio
```

## Troubleshooting

### Authentication Issues
- Ensure your Personal Access Token has the correct permissions (Work Items: Read & Write)
- Check that the token hasn't expired
- Re-run `./scripts/setup-azure-devops.sh` to test connection

### Work Item Creation Fails
- Some work item types require additional fields (Description, Area Path, etc.)
- Check the project's work item template requirements
- Use the web interface to see what fields are required

### Commands Not Found
- Make sure scripts are executable: `chmod +x scripts/*.sh`
- Check that Azure DevOps CLI extension is installed
- Verify you're in the correct directory

## Tips

1. **Commit Messages**: Include work item ID in commit messages: `git commit -m "Fix auth bug #123"`
2. **Branch Naming**: Use the auto-generated branch names for consistency
3. **Progress Updates**: Regular progress updates help with project visibility
4. **Linking**: Link commits to work items for traceability

## Advanced Usage

### Custom Queries
```bash
# Find all your active work items
az boards query --wiql "SELECT [System.Id], [System.Title] FROM WorkItems WHERE [System.AssignedTo] = @Me AND [System.State] = 'Active'"

# Find bugs assigned to you
az boards query --wiql "SELECT [System.Id], [System.Title] FROM WorkItems WHERE [System.WorkItemType] = 'Bug' AND [System.AssignedTo] = @Me"
```

### Bulk Operations
```bash
# Update multiple work items to a new iteration
az boards work-item update --ids 123,124,125 --iteration "Sprint 2"
```

## Resources

- [Azure DevOps CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/boards)
- [Work Item Query Language (WIQL)](https://docs.microsoft.com/en-us/azure/devops/boards/queries/wiql-syntax)
- [Personal Access Tokens](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)