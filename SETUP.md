# ADO_CLI_Integration Setup Instructions

Complete setup guide for Azure DevOps integration with CLI.

## 🚀 Automated Installation (Recommended)

### Quick Install

```bash
cd /Users/abiodun/Downloads/ADO_CLI_Integration
./INSTALL.sh
```

The installer will:

1. ✅ Check prerequisites (Azure CLI, DevOps extension, Git, jq)
2. ✅ Install global integration to `~/.claude/`
3. ✅ Update Claude Code framework files
4. ✅ Create shell alias for `ado` command
5. ✅ Run initial Azure DevOps configuration

### What Gets Installed

**Global Files:**

- `~/.claude/ado-integration.sh` - Main integration script
- `~/.claude/ADO.md` - Claude Code framework documentation
- `~/.claude/ado-config.env` - Your global configuration

**Framework Updates:**

- Adds `@ADO.md` to `~/.claude/CLAUDE.md`
- Adds `/ado` command section to `~/.claude/COMMANDS.md`

**Shell Integration:**

- Adds `alias ado='~/.claude/ado-integration.sh'` to shell profile

---

## 🛠 Manual Installation

### Prerequisites

```bash
# Install Azure CLI
brew install azure-cli                    # macOS
# or follow: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

# Install Azure DevOps extension
az extension add --name azure-devops

# Install jq for JSON parsing
brew install jq                           # macOS
sudo apt-get install jq                   # Ubuntu/Debian
```

### Step 1: Install Global Integration

```bash
# Create Claude directory if needed
mkdir -p ~/.claude

# Copy integration script
cp global-integration/ado-integration.sh ~/.claude/
chmod +x ~/.claude/ado-integration.sh

# Copy framework documentation
cp global-integration/ADO.md ~/.claude/
```

### Step 2: Update Claude Code Framework

**Add to `~/.claude/CLAUDE.md`:**

```markdown
@ADO.md
```

**Add to `~/.claude/COMMANDS.md`:**
See `global-integration/commands-template.md` for the complete section to add.

### Step 3: Create Shell Alias

Add to your shell profile (`~/.bashrc` or `~/.zshrc`):

```bash
# Azure DevOps Integration
alias ado='~/.claude/ado-integration.sh'
```

Reload your shell:

```bash
source ~/.bashrc    # or ~/.zshrc
```

### Step 4: Configure Azure DevOps

```bash
ado setup
```

---

## 📁 Project-Specific Setup

For projects that need different Azure DevOps settings:

### Option 1: Override Configuration

```bash
cd your-project

# Copy project template
cp /Users/abiodun/Downloads/ADO_CLI_Integration/config/project-config-template.env .env.azure-devops

# Edit with project-specific values
nano .env.azure-devops
```

### Option 2: Project Scripts (Legacy)

```bash
cd your-project

# Copy all project scripts
mkdir -p scripts
cp /Users/abiodun/Downloads/ADO_CLI_Integration/project-scripts/* scripts/
chmod +x scripts/*.sh

# Run project setup
./scripts/setup-azure-devops.sh
```

---

## ⚙️ Configuration

### Global Configuration (`~/.claude/ado-config.env`)

```bash
AZURE_DEVOPS_EXT_PAT=your_personal_access_token
AZURE_DEVOPS_ORG_URL=https://dev.azure.com/YourOrganization
AZURE_DEVOPS_PROJECT=YourDefaultProject
```

### Personal Access Token Setup

1. Go to Azure DevOps: `https://dev.azure.com/[your-org]`
2. Click User Settings → Personal Access Tokens
3. Create New Token with scopes:
   - **Work Items**: Read & Write
   - **Code**: Read (for git integration)
4. Copy token and use in configuration

### Project Override (`project/.env.azure-devops`)

```bash
AZURE_DEVOPS_EXT_PAT=project_specific_token
AZURE_DEVOPS_ORG_URL=https://dev.azure.com/ProjectOrg
AZURE_DEVOPS_PROJECT=SpecificProject
```

---

## ✅ Verification

### Test Installation

```bash
# Check command availability
which ado
ado --help

# Test connection
ado list

# Check your work items
ado my
```

### Troubleshooting

If commands fail:

1. **Check Azure CLI authentication:**

   ```bash
   az account show
   # If not logged in:
   az login --allow-no-subscriptions
   ```

2. **Verify configuration:**

   ```bash
   cat ~/.claude/ado-config.env
   ```

3. **Test Azure DevOps connection:**

   ```bash
   az boards query --wiql "SELECT [System.Id] FROM WorkItems" --top 1
   ```

4. **Re-run setup if needed:**

   ```bash
   ado setup
   ```

---

## 🎯 Quick Start Guide

### First Use Workflow

```bash
# 1. List your assigned work items
ado my

# 2. Create a new task
ado create Task "Test Azure DevOps integration"

# 3. Start working on it (creates git branch)
ado start [work-item-id]

# 4. Make some progress
git commit -m "Initial implementation"
ado comment [work-item-id] "Started implementation, basic structure in place"

# 5. Complete the work
ado complete [work-item-id]
```

### Daily Workflow

```bash
# Morning standup prep
ado my                              # Check assigned work
ado search "sprint-current"         # Find sprint work items

# Start new work
ado start 123                       # Creates branch, sets to Active

# Progress updates
ado comment 123 "Progress update"   # Add comments during development

# Complete work  
ado complete 123                    # Mark as Resolved when done
```

---

## 🔧 Customization

### Custom Commands

Add your own commands by editing `~/.claude/ado-integration.sh`:

```bash
# Add to the case statement in execute_ado_command()
"mycustom")
    echo "Running my custom command..."
    # Your custom logic here
    ;;
```

### Project Templates

Create project-specific templates in your dotfiles:

```bash
# ~/.config/ado-templates/
├── frontend-project.env
├── backend-project.env
└── microservice.env
```

### Git Hooks Integration

Add to `.git/hooks/post-commit`:

```bash
#!/bin/bash
# Auto-update work item on commit
WORK_ITEM=$(git rev-parse --abbrev-ref HEAD | grep -o 'workitem-[0-9]*' | cut -d'-' -f2)
if [[ -n "$WORK_ITEM" ]]; then
    ado comment "$WORK_ITEM" "New commit: $(git log -1 --oneline)"
fi
```

---

## 📚 Additional Resources

### Documentation Files

- `README.md` - Package overview and quick start
- `docs/command-reference.md` - Complete command documentation  
- `docs/examples.md` - Real-world usage examples
- `docs/troubleshooting.md` - Common issues and solutions

### External Resources

- [Azure DevOps CLI Documentation](https://docs.microsoft.com/en-us/cli/azure/boards)
- [Personal Access Tokens Guide](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)
- [Work Item Query Language (WIQL)](https://docs.microsoft.com/en-us/azure/devops/boards/queries/wiql-syntax)

### Community

- Share improvements and customizations
- Report issues and suggest features
- Contribute additional project templates

---

## 🔄 Updates and Maintenance

### Updating the Integration

```bash
# Backup current config
cp ~/.claude/ado-config.env ~/.claude/ado-config.env.backup

# Download new version
cd /Users/abiodun/Downloads/ADO_CLI_Integration
git pull  # if using git
./INSTALL.sh

# Restore config if needed
cp ~/.claude/ado-config.env.backup ~/.claude/ado-config.env
```

### Regular Maintenance

- **PAT Renewal**: Update tokens before expiration
- **Azure CLI Updates**: Keep Azure CLI and extensions current
- **Configuration Cleanup**: Remove unused project configurations

### Health Check

Run this periodically:

```bash
# Check all prerequisites
az --version
az extension show --name azure-devops
ado my
```

---

## 🎉 You're Ready

Your Azure DevOps integration is now fully set up and ready to use across all your projects. The global configuration will work everywhere, with the ability to override settings per project as needed.

**Next Steps:**

1. Try the workflow with a test work item
2. Explore the documentation files for advanced usage
3. Customize commands and templates for your team's needs
4. Share the integration with your team members

Happy coding with seamless Azure DevOps integration! 🚀
