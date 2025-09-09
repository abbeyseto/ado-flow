# Commands Template for COMMANDS.md

Add this section to your `~/.claude/COMMANDS.md` file:

```markdown
### Azure DevOps Integration Commands

**`/ado $ARGUMENTS`**
```yaml
---
command: "/ado"
category: "Project Management & Integration"
purpose: "Azure DevOps work item management and git workflow integration"
wave-enabled: false
performance-profile: "standard"
---
```

- **Auto-Persona**: DevOps, Analyzer, Scribe (context-dependent)
- **MCP Integration**: Sequential (work planning), Context7 (DevOps patterns)
- **Tool Orchestration**: [Bash (az cli), Git integration, TodoWrite]
- **Arguments**: `[operation]`, `[work-item-id]`, `[options]`, `--<flags>`

**Core Operations**:

- `ado setup` - Configure global Azure DevOps integration
- `ado list` - List all work items in current project
- `ado my` - Show work items assigned to current user
- `ado search [query]` - Search work items by title/content
- `ado show [id]` - Display detailed work item information
- `ado create [type] [title]` - Create new work items (Task, Bug, Story, Feature, Epic)
- `ado update [id] [options]` - Update work item fields and status
- `ado comment [id] [text]` - Add comments to work items

**Git Integration**:

- `ado start [id]` - Create feature branch and activate work item
- `ado complete [id]` - Mark work item as resolved and ready for review
- `ado link [id]` - Link current commit to work item (via comment)

**Configuration Hierarchy**:

1. **Project-level**: `./.env.azure-devops` (overrides global)
2. **Global**: `~/.claude/ado-config.env` (default for all projects)

**Auto-Activation Triggers**:

- Keywords: "work item", "azure devops", "ado", "ticket", "issue tracking"
- Project management workflows and sprint planning
- Git workflow integration with work tracking

## Update Command Categories

Also update the Command Categories section:

```markdown
### Command Categories
- **Development**: build, implement, design
- **Planning**: workflow, estimate, task
- **Analysis**: analyze, troubleshoot, explain
- **Quality**: improve, cleanup
- **Testing**: test
- **Documentation**: document
- **Version-Control**: git
- **Project-Management**: ado
- **Meta**: index, load, spawn
```

## Update CLAUDE.md

Add this line to your `~/.claude/CLAUDE.md`:

```markdown
@ADO.md
```
