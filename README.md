# ado-flow

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-blue.svg)]()
[![Shell](https://img.shields.io/badge/Shell-Bash%20%7C%20PowerShell-green.svg)]()
[![Azure DevOps CLI](https://img.shields.io/badge/Built%20on-Azure%20DevOps%20CLI-blue.svg)](https://learn.microsoft.com/en-us/azure/devops/cli/?view=azure-devops)

**Streamlined Azure DevOps workflow automation with intelligent work item management.**

ado-flow is a powerful wrapper around the [Azure DevOps CLI extension](https://learn.microsoft.com/en-us/azure/devops/cli/?view=azure-devops) that makes your Azure DevOps workflow *flow* with intelligent automation, hierarchical work item management, and seamless Git integration.

## 🔧 What This Tool Does

This tool enhances the official Azure DevOps CLI extension (`az boards`) with:

- **Intelligent work item creation** with auto-assignment and linking
- **Hierarchical work item management** (Epic→Feature→Story→Task)
- **Streamlined Git workflow integration**
- **Smart field handling** and type-specific templates
- **Cross-platform installation and setup**

> **Built on Microsoft's Azure DevOps CLI**: This tool uses the official [Azure DevOps CLI extension](https://learn.microsoft.com/en-us/azure/devops/cli/?view=azure-devops) under the hood, adding a user-friendly layer with workflow automation and enhanced productivity features.

## ✨ Features

- **Cross-platform support** - Works on Windows (PowerShell/WSL), macOS, and Linux
- **Smart work item creation** - Auto-handles required fields for different work item types (Epic, Feature, User Story, Task, Bug)
- **Hierarchical work item linking** - Automatic parent-child relationships (Epic→Feature→User Story→Task)
- **Automatic assignment** - Auto-assigns work items to the creator or specified user
- **Git workflow integration** - Automatic branch creation and work item state management  
- **Flexible configuration** - Global and project-specific configuration options
- **Claude Code integration** - Optional AI enhancement for intelligent workflow assistance
- **Easy installation** - One-command installation with automatic dependency setup

## 🚀 Quick Install

### Option 1: One-Command Install (Recommended)

**macOS/Linux:**

```bash
curl -sSL https://raw.githubusercontent.com/abbeyseto/ado-flow/main/install.sh | bash
```

**Windows (PowerShell):**

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/abbeyseto/ado-flow/main/install.ps1'))
```

### Option 2: Manual Installation

1. **Download the latest release**

   ```bash
   git clone https://github.com/abbeyseto/ado-flow.git
   cd ado-flow
   ```

2. **Run the installation script**

   **macOS/Linux:**

   ```bash
   ./install.sh
   ```

   **Windows (PowerShell as Administrator):**

   ```powershell
   .\install.ps1
   ```

3. **Setup Azure DevOps connection**

   ```bash
   ado setup
   ```

## 📋 Prerequisites

### Core Dependencies (Automatically Installed)

This tool is built on top of Microsoft's official Azure DevOps tooling:

- **[Azure CLI](https://docs.microsoft.com/en-us/cli/azure/)** - Microsoft's official Azure command-line tool
- **[Azure DevOps CLI Extension](https://learn.microsoft.com/en-us/azure/devops/cli/?view=azure-devops)** - Official extension for Azure DevOps operations
- **Git** - Required for Git workflow integration
- **Personal Access Token** - Azure DevOps authentication (created during setup)

> **Note**: The installation script automatically detects and installs missing prerequisites. This tool essentially provides a user-friendly wrapper around `az boards` commands with added workflow intelligence.

### What Gets Installed

```bash
# The tool installs and configures:
az --version                    # Azure CLI
az extension list               # Azure DevOps extension  
ado --help                      # This wrapper tool

# Optional: Claude Code integration (auto-detected)
# If ~/.claude/ directory exists, enables enhanced AI features
```

**Auto-Detection**: The installer automatically detects if you have Claude Code installed and configures enhanced AI integration accordingly.

## 📁 Package Contents

### Global Integration (`global-integration/`)

- `ado-integration.sh` - Global Azure DevOps command handler
- `ADO.md` - Claude Code framework integration
- `commands-template.md` - Template for adding to COMMANDS.md

### Project Scripts (`project-scripts/`)

- `setup-azure-devops.sh` - Project setup script
- `ado.sh` - Main Azure DevOps CLI tool
- `create-task.sh` - Quick task creator
- `git-workitem.sh` - Git workflow integration

### Documentation (`docs/`)

- `integration-guide.md` - Complete integration guide
- `command-reference.md` - All available commands
- `troubleshooting.md` - Common issues and solutions
- `examples.md` - Usage examples

### Configuration (`config/`)

- `ado-config-template.env` - Configuration template
- `project-config-template.env` - Project-specific template

## 🎯 Features

### Global Commands (Available Everywhere)

- `ado setup` - One-time global configuration
- `ado list` - List work items
- `ado my` - Show your assigned work items  
- `ado create [type] [title] [description]` - Create work items with field validation
  - Supports: Epic, Feature, 'User Story', Task
  - Auto-handles required fields for each work item type
- `ado start [id]` - Start work with git branch
- `ado complete [id]` - Complete and mark resolved

### Smart Work Item Creation & Linking

- **Field Validation**: Automatically handles Azure DevOps field constraints
- **Epic**: Title and description only (minimal requirements)
- **Feature**: Auto-adds Target Date (30 days) and Acceptance Criteria template
- **User Story**: Auto-adds Risk level, Acceptance Criteria, and Story Points
- **Task**: Auto-adds work estimates (Remaining/Original/Completed) and Activity type
- **Bug**: Auto-adds Severity, Priority, and Reproduction Steps template
- **Automatic Linking**: Features link to Epics, User Stories to Features, Tasks to User Stories
- **Bug Flexibility**: Bugs can link to any work item type
- **Auto-Assignment**: Work items automatically assigned to creator or specified user
- **Cross-Platform**: Works on Windows, macOS, and Linux

### Git Workflow Integration

- Automatic branch creation from work item titles
- Work item state management (New → Active → Resolved)
- Progress tracking with comments
- Commit linking to work items

### Configuration Hierarchy

1. **Project-level**: `./.env.azure-devops` (overrides global)
2. **Global**: `~/.claude/ado-config.env` (default for all projects)

## 🔧 Configuration

### Setting up Environment Variables

After installation, you'll need to configure your Azure DevOps connection:

#### Option 1: Interactive Setup (Recommended)

```bash
ado setup
```

This will guide you through the setup process and automatically configure all required environment variables.

#### Option 2: Manual Environment Variable Setup

**Create a Personal Access Token:**

1. Go to your Azure DevOps organization → User Settings → Personal Access Tokens
2. Create a new token with "Work Items (Read & Write)" permissions
3. Copy the token value

**Set Environment Variables:**

**Windows (PowerShell):**

```powershell
# Temporary (current session)
$env:AZURE_DEVOPS_EXT_PAT = "your-personal-access-token"
$env:AZURE_DEVOPS_ORG_URL = "https://dev.azure.com/YourOrg"
$env:AZURE_DEVOPS_PROJECT = "YourProject"

# Permanent (add to PowerShell profile)
Add-Content $PROFILE "`n`$env:AZURE_DEVOPS_EXT_PAT = 'your-personal-access-token'"
Add-Content $PROFILE "`n`$env:AZURE_DEVOPS_ORG_URL = 'https://dev.azure.com/YourOrg'"
Add-Content $PROFILE "`n`$env:AZURE_DEVOPS_PROJECT = 'YourProject'"
```

**macOS/Linux (Bash):**

```bash
# Temporary (current session)
export AZURE_DEVOPS_EXT_PAT="your-personal-access-token"
export AZURE_DEVOPS_ORG_URL="https://dev.azure.com/YourOrg"
export AZURE_DEVOPS_PROJECT="YourProject"

# Permanent (add to ~/.bashrc or ~/.zshrc)
echo 'export AZURE_DEVOPS_EXT_PAT="your-personal-access-token"' >> ~/.bashrc
echo 'export AZURE_DEVOPS_ORG_URL="https://dev.azure.com/YourOrg"' >> ~/.bashrc
echo 'export AZURE_DEVOPS_PROJECT="YourProject"' >> ~/.bashrc
source ~/.bashrc
```

### Configuration Files

The tool uses a hierarchical configuration approach:

1. **Global Configuration** (`~/.claude/ado-config.env`)
   - Used as default for all projects
   - Created automatically by `ado setup`

2. **Project-Specific Configuration** (`./.env.azure-devops`)
   - Overrides global settings for specific projects
   - Create manually when different projects use different Azure DevOps organizations

**Example project-specific configuration:**

```bash
# Copy template and edit
cp ~/.claude/ado-config-template.env ./.env.azure-devops
# Edit with project-specific values
```

## 📖 Quick Reference

### Work Item Management

```bash
ado list                          # List all work items
ado my                            # My assigned work items
ado search "authentication"       # Search work items
ado show 123                      # Show work item details

# Create work items (with auto-assignment and optional parent linking)
ado create Epic "User Management System"                    # Create epic
ado create Feature "User authentication" "OAuth 2.0 integration"  # Create feature (prompts to link to Epic)
ado create "User Story" "Login functionality" "As a user I want to login"  # Create user story (prompts to link to Feature)
ado create Task "Fix login bug" "Update JWT validation logic"      # Create task (prompts to link to User Story)
ado create Bug "Login button broken" "Button not responsive on mobile"  # Create bug (prompts to link to any work item)

# Work item operations
ado update 123 --state Active     # Update work item state
ado comment 123 "Progress update" # Add comment
ado link 456 123                  # Link work item 456 to parent 123
ado assign 123 me                 # Assign work item to yourself
ado assign 123 user@company.com   # Assign to specific user
```

### Git Integration

```bash
ado start 123     # Create branch & set work item to Active
ado complete 123  # Set work item to Resolved
```

### Available Work Item Types

- **Epic** - High-level business objectives
- **Feature** - Major functionality areas  
- **User Story** - User-focused requirements
- **Task** - Implementation work items
- **Bug** - Defects and issues

### Work Item Hierarchy

```text
Epic
 └─ Feature
    └─ User Story
       └─ Task

Bug (can link to any level)
```

### Common States

- New, Active, Resolved, Closed, Removed

## 🐛 Troubleshooting

### Authentication Issues

```bash
# Verify Azure CLI login
az account show

# Test Azure DevOps connection
az boards query --wiql "SELECT [System.Id] FROM WorkItems" --top 1

# Re-run setup if issues persist
ado setup
```

### Command Not Found

```bash
# Make sure script is executable
chmod +x ~/.claude/ado-integration.sh

# Verify path (add to .bashrc/.zshrc if needed)
alias ado='~/.claude/ado-integration.sh'
```

## 🚀 Advanced Usage

### Custom Workflows

The integration supports custom workflows through:

- Project-specific configuration overrides
- Pre/post command hooks
- Custom state transitions

## 🤖 Claude Code Integration

**Enhanced AI Experience**: ado-flow includes optional integration with [Claude Code](https://claude.ai/code) - Anthropic's official CLI tool for Claude AI.

### 🎯 What This Means for You

**If you use Claude Code** (Anthropic's official CLI), ado-flow automatically enhances your AI experience:

✅ **Smart Context Awareness**: Claude automatically understands your Azure DevOps workflow context
✅ **Auto-Persona Activation**: AI switches to DevOps/Analyzer modes based on your tasks
✅ **Intelligent Suggestions**: Get better work item creation and troubleshooting advice
✅ **Enhanced Error Handling**: AI provides contextual help when things go wrong

### 🔧 How It Works

```bash
# When you run ado-flow commands in Claude Code:
ado create Feature "User Auth"     # Claude understands this is Azure DevOps work
ado start 123                      # AI knows you're starting development work
ado complete 123                   # Claude can help with completion workflows
```

Or simpley when you mention `ado` in Claude Code, it will understand you are working on Azure DevOps work items.

**The AI automatically knows:**

- Your current Azure DevOps project context
- Work item relationships and hierarchies  
- Git workflow patterns and best practices
- Common Azure DevOps troubleshooting steps

### 📋 Standalone vs Enhanced Mode

| Feature | Standalone | With Claude Code |
|---------|------------|------------------|
| All ado-flow commands | ✅ Works perfectly | ✅ Works perfectly |
| Work item management | ✅ Full functionality | ✅ Full functionality |
| Git integration | ✅ Complete workflow | ✅ Complete workflow |
| AI context awareness | ❌ Not available | ✅ **Enhanced AI help** |
| Smart troubleshooting | ❌ Basic error messages | ✅ **AI-powered guidance** |
| Workflow optimization | ❌ Manual process | ✅ **AI suggestions** |

### 🚀 Getting Started

**Option 1: Standalone Use** (Most users)

```bash
# Install and use ado-flow independently
curl -sSL https://raw.githubusercontent.com/abbeyseto/ado-flow/main/install.sh | bash
ado setup
ado create Task "My first task"
```

**Option 2: Enhanced with Claude Code*

```bash
# 1. Install Claude Code: https://claude.ai/code
# 2. Install ado-flow (auto-detects Claude Code)
curl -sSL https://raw.githubusercontent.com/abbeyseto/ado-flow/main/install.sh | bash
# 3. Use ado-flow in Claude Code for enhanced AI assistance
```

> **Note**: ado-flow works perfectly as a standalone tool. Claude Code integration is an optional enhancement for AI-powered development workflows.

### ❓ Frequently Asked Questions

**Q: Do I need Claude Code to use ado-flow?**
A: No! ado-flow works completely independently. Claude Code integration is an optional bonus.

**Q: How do I know if Claude Code integration is active?**
A: If you're using Claude Code and have ado-flow installed, the integration is automatic. Claude will understand your Azure DevOps context when you mention work items, branches, or use ado-flow commands.

**Q: What's the difference between using ado-flow alone vs with Claude Code?**
A: Standalone = full ado-flow functionality. With Claude Code = same functionality + AI understands your Azure DevOps workflow and provides smarter assistance.

**Q: Can I disable the Claude Code integration?**
A: The integration doesn't interfere with normal ado-flow usage. If you want purely standalone operation, simply don't use ado-flow commands within Claude Code sessions.

### Bulk Operations

```bash
# Update multiple work items
ado update 123,124,125 --state "In Progress"

# Bulk comments (via Azure CLI)
az boards work-item update --ids 123,124 --discussion "Sprint update"
```

## 👥 Authors and Contributors

**Created by:** [Adenle Abiodun](https://github.com/abbeyseto)

**Built on:** [Microsoft Azure DevOps CLI Extension](https://learn.microsoft.com/en-us/azure/devops/cli/?view=azure-devops)

**AI Enhanced:** [Claude Code](https://claude.ai/code) integration available for intelligent workflow assistance

### Contributors

We welcome contributions! See our [contribution guidelines](CONTRIBUTING.md) for details.

<!-- Add contributors here -->
- [Contributor Name](https://github.com/contributor) - Feature description
- [Another Contributor](https://github.com/contributor2) - Bug fixes and improvements

*Want to contribute? Check out our [Contributing Guide](CONTRIBUTING.md) and [open issues](https://github.com/abbeyseto/ado-flow/issues).*

## 📝 Contributing

We welcome contributions from the community! Here's how you can help:

### Quick Contribution Guide

1. **Fork the repository**

   ```bash
   git clone https://github.com/abbeyseto/ado-flow.git
   cd ado-flow
   ```

2. **Create a feature branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Add new commands to `ado-integration.sh`
   - Update documentation
   - Add tests if applicable

4. **Test your changes**

   ```bash
   # Test on your platform
   ./install.sh
   ado setup
   # Test your new features
   ```

5. **Submit a pull request**
   - Describe your changes
   - Include screenshots for UI changes
   - Reference any related issues

### Development Setup

```bash
# Clone the repo
git clone https://github.com/abbeyseto/ado-flow.git
cd ado-flow

# Install in development mode
./install.sh --dev

# Make changes and test
# Your changes are immediately available for testing
```

For detailed contribution guidelines, see [CONTRIBUTING.md](CONTRIBUTING.md).

## 📞 Support

### Getting Help

1. **Check the documentation**
   - [Troubleshooting Guide](docs/troubleshooting.md)
   - [Command Reference](docs/command-reference.md)
   - [Examples](docs/examples.md)

2. **Common Issues**
   - Verify Azure CLI and DevOps extension are updated
   - Test with minimal configuration
   - Check Azure DevOps permissions

3. **Report Issues**
   - [GitHub Issues](https://github.com/abbeyseto/ado-flow/issues)
   - Include your OS, Azure CLI version, and error messages
   - Provide steps to reproduce the issue

4. **Community Support**
   - [Discussions](https://github.com/abbeyseto/ado-flow/discussions) - Questions and general help
   - [Discord/Slack Community](#) - Real-time support (if applicable)

## 🔗 Resources

### Official Microsoft Documentation

- **[Azure DevOps CLI Extension](https://learn.microsoft.com/en-us/azure/devops/cli/?view=azure-devops)** - Official Microsoft documentation for the underlying CLI tool
- **[Azure CLI Boards Commands](https://docs.microsoft.com/en-us/cli/azure/boards)** - Complete reference for `az boards` commands
- **[Personal Access Tokens](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)** - Authentication setup guide
- **[Work Item Query Language (WIQL)](https://docs.microsoft.com/en-us/azure/devops/boards/queries/wiql-syntax)** - Query syntax for advanced searches

### This Tool's Enhancements

- **[Command Reference](docs/command-reference.md)** - Complete guide to enhanced commands
- **[Usage Examples](docs/examples.md)** - Real-world workflow examples
- **[Troubleshooting](docs/troubleshooting.md)** - Common issues and solutions

### Command Mapping

This tool provides simplified commands that map to Azure DevOps CLI operations:

| This Tool | Maps to Azure CLI | Enhancement |
|-----------|-------------------|-------------|
| `ado create Epic "Title"` | `az boards work-item create --type Epic --title "Title"` | + Auto-assignment + Linking prompts |
| `ado my` | `az boards query --wiql "[System.AssignedTo] = @Me"` | + Smart email detection |
| `ado start 123` | `az boards work-item update --id 123 --state Active` | + Git branch creation + Comments |
| `ado link 456 123` | `az boards work-item relation add --id 456 --target-id 123` | + Validation + User-friendly prompts |

> **Tip**: You can still use the underlying `az boards` commands directly for advanced operations not covered by this tool's simplified interface.
