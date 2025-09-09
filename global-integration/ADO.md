# ADO.md - Azure DevOps Integration Implementation

Azure DevOps integration implementation for Claude Code SuperClaude framework.

## Command Implementation

### `/ado` Command Router

The `/ado` command is implemented as a global integration that works across all projects:

**Command Structure**: `/ado [operation] [arguments] [flags]`

**Implementation Path**: `~/.claude/ado-integration.sh`

**Configuration Priority**:

1. Project-specific: `./.env.azure-devops`
2. Global default: `~/.claude/ado-config.env`

## Auto-Activation Logic

### Persona Activation

```yaml
devops_keywords: ["ado", "azure devops", "work item", "ticket", "sprint", "backlog"]
analyzer_keywords: ["troubleshoot", "investigate", "track", "status"]
scribe_keywords: ["document", "comment", "update", "description"]
```

### Context Detection

- Project management workflows
- Git branch operations with work item references
- Sprint planning and backlog management
- Work item lifecycle management

## Command Execution Flow

### Setup Phase (`/ado setup`)

1. **Prerequisite Check**: Azure CLI and DevOps extension
2. **Credential Collection**: Organization, Project, PAT
3. **Configuration Storage**: `~/.claude/ado-config.env`
4. **Connection Validation**: Test API connectivity

### Work Item Operations

1. **Configuration Load**: Project → Global → Error
2. **Authentication**: Export PAT token
3. **API Execution**: Azure CLI commands
4. **Response Processing**: Parse and format output
5. **Git Integration**: Branch operations when applicable

### Git Workflow Integration

1. **Branch Creation**: `workitem-[id]-[sanitized-title]`
2. **State Management**: Automatic work item state transitions
3. **Comment Tracking**: Progress updates and completion notes
4. **Context Preservation**: Branch and commit information

## Error Handling

### Configuration Errors

- Missing Azure CLI → Installation guidance
- Invalid credentials → Credential verification steps
- Network connectivity → Connection troubleshooting

### API Errors

- Work item not found → ID validation
- Permission denied → Access rights guidance
- Rate limiting → Retry with backoff

### Git Integration Errors

- Branch conflicts → Safe branch name generation
- Repository not found → Git status check
- Uncommitted changes → Working directory warnings

## Performance Optimization

### Caching Strategy

- Work item metadata caching (5-minute TTL)
- User information caching (session-based)
- Project configuration caching (persistent)

### Batch Operations

- Multiple work item queries
- Bulk state updates
- Comment batch processing

## Security Considerations

### Credential Management

- PAT storage in user home directory
- File permissions: 600 (user read/write only)
- No credential logging or echoing

### API Security

- HTTPS-only communication
- Token-based authentication
- Scope-limited permissions

## Integration Points

### Claude Code Framework

- Command registration in COMMANDS.md
- Persona auto-activation
- Error handling integration
- Progress tracking via TodoWrite

### External Dependencies

- Azure CLI (`az` command)
- Azure DevOps CLI extension
- Git (for workflow integration)
- jq (for JSON parsing)

## Usage Analytics

### Success Metrics

- Setup completion rate
- Command execution success rate
- Git workflow adoption
- Error resolution rate

### Performance Metrics

- Response time per operation
- API call efficiency
- Cache hit rates
- User satisfaction scores

## Extensibility

### Custom Commands

- Template for project-specific operations
- Plugin architecture for additional functionality
- Custom field mapping

### Integration Hooks

- Pre/post command execution hooks
- Custom state transition logic
- External system integration points

## Troubleshooting Guide

### Common Issues

1. **Authentication Failures**
   - PAT expiration → Token renewal
   - Scope limitations → Permission adjustment
   - Organization access → Membership verification

2. **Command Execution Errors**
   - Missing work item → ID verification
   - State transition failures → Workflow rules
   - Network timeouts → Retry mechanism

3. **Git Integration Problems**
   - Branch naming conflicts → Sanitization logic
   - Repository access → Git configuration
   - Merge conflicts → Workflow guidance

### Diagnostic Commands

```bash
# Test global configuration
~/.claude/ado-integration.sh setup

# Verify connectivity
az boards query --wiql "SELECT [System.Id] FROM WorkItems" --top 1

# Check permissions
az boards work-item create --type Task --title "Test" --dry-run
```

## Maintenance

### Regular Tasks

- PAT renewal (before expiration)
- Configuration cleanup
- Cache management
- Performance monitoring

### Updates

- Azure CLI extension updates
- Command enhancement releases
- Security patch applications
- Feature additions
