#!/bin/bash

# Azure DevOps CLI Integration - Unix/Linux Installation Script
# Supports macOS and Linux with automatic dependency installation
# Author: Adenle Abiodun <adenleabbey@gmail.com>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Installation paths
CLAUDE_DIR="$HOME/.claude"
GLOBAL_INTEGRATION_DIR="./global-integration"
PROJECT_SCRIPTS_DIR="./project-scripts"
CONFIG_DIR="./config"

# Banner
echo -e "${BLUE}
╔══════════════════════════════════════════════════════════════╗
║                    ado-flow Installer                        ║
║         by Adenle Abiodun (adenleabbey@gmail.com)            ║
╚══════════════════════════════════════════════════════════════╝
${NC}"

# Check if running from correct directory
if [[ ! -d "$GLOBAL_INTEGRATION_DIR" ]] || [[ ! -d "$PROJECT_SCRIPTS_DIR" ]]; then
    echo -e "${RED}❌ Please run this script from the ADO_CLI_Integration directory${NC}"
    echo "Expected structure:"
    echo "  ADO_CLI_Integration/"
    echo "  ├── global-integration/"
    echo "  ├── project-scripts/"
    echo "  └── INSTALL.sh"
    exit 1
fi

# Function to check prerequisites
check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"
    
    # Check Azure CLI
    if ! command -v az &> /dev/null; then
        echo -e "${RED}❌ Azure CLI not found${NC}"
        echo "Please install Azure CLI first:"
        echo "  macOS: brew install azure-cli"
        echo "  Other: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        exit 1
    else
        echo -e "${GREEN}✅ Azure CLI found: $(az --version | head -1)${NC}"
    fi
    
    # Check Azure DevOps extension
    if ! az extension show --name azure-devops &> /dev/null; then
        echo -e "${YELLOW}⚠️  Azure DevOps extension not found. Installing...${NC}"
        az extension add --name azure-devops
        echo -e "${GREEN}✅ Azure DevOps extension installed${NC}"
    else
        echo -e "${GREEN}✅ Azure DevOps extension found${NC}"
    fi
    
    # Check jq for JSON parsing
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}⚠️  jq not found. Installing...${NC}"
        if command -v brew &> /dev/null; then
            brew install jq
        elif command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y jq
        elif command -v yum &> /dev/null; then
            sudo yum install -y jq
        else
            echo -e "${RED}❌ Please install jq manually${NC}"
            exit 1
        fi
        echo -e "${GREEN}✅ jq installed${NC}"
    else
        echo -e "${GREEN}✅ jq found${NC}"
    fi
    
    # Check Git
    if ! command -v git &> /dev/null; then
        echo -e "${RED}❌ Git not found. Please install Git first.${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ Git found: $(git --version)${NC}"
    fi
}

# Function to install global integration
install_global() {
    echo -e "${BLUE}🚀 Installing ado-flow...${NC}"
    
    # Create Claude directory if it doesn't exist
    if [[ ! -d "$CLAUDE_DIR" ]]; then
        echo -e "${YELLOW}Creating ~/.claude directory...${NC}"
        mkdir -p "$CLAUDE_DIR"
    fi
    
    # Copy global integration script
    echo "Installing ado-integration.sh..."
    cp "$GLOBAL_INTEGRATION_DIR/ado-integration.sh" "$CLAUDE_DIR/"
    chmod +x "$CLAUDE_DIR/ado-integration.sh"
    
    # Copy ADO framework documentation
    echo "Installing ADO.md..."
    cp "$GLOBAL_INTEGRATION_DIR/ADO.md" "$CLAUDE_DIR/"
    
    echo -e "${GREEN}✅ ado-flow installed${NC}"
}

# Function to update CLI framework
update_claude_framework() {
    echo -e "${BLUE}🔧 Updating CLI framework...${NC}"
    
    # Check if CLAUDE.md exists
    if [[ -f "$CLAUDE_DIR/CLAUDE.md" ]]; then
        # Add @ADO.md if not already present
        if ! grep -q "@ADO.md" "$CLAUDE_DIR/CLAUDE.md"; then
            echo "Adding @ADO.md to CLAUDE.md..."
            echo "@ADO.md" >> "$CLAUDE_DIR/CLAUDE.md"
        else
            echo "@ADO.md already present in CLAUDE.md"
        fi
    else
        echo -e "${YELLOW}⚠️  CLAUDE.md not found. Creating basic structure...${NC}"
        cat > "$CLAUDE_DIR/CLAUDE.md" << 'EOF'
# SuperClaude Entry Point

@COMMANDS.md
@FLAGS.md
@PRINCIPLES.md
@RULES.md
@MCP.md
@PERSONAS.md
@ORCHESTRATOR.md
@MODES.md
@ADO.md
EOF
    fi
    
    # Update COMMANDS.md
    if [[ -f "$CLAUDE_DIR/COMMANDS.md" ]]; then
        if ! grep -q "/ado" "$CLAUDE_DIR/COMMANDS.md"; then
            echo "Adding /ado command section to COMMANDS.md..."
            cat "$GLOBAL_INTEGRATION_DIR/commands-template.md" | sed -n '/^```markdown/,/^```/p' | sed '1d;$d' >> "$CLAUDE_DIR/COMMANDS.md"
        else
            echo "/ado command already present in COMMANDS.md"
        fi
    else
        echo -e "${YELLOW}⚠️  COMMANDS.md not found. Please add manually later.${NC}"
    fi
    
    echo -e "${GREEN}✅ CLI framework updated${NC}"
}

# Function to create shell alias
create_alias() {
    echo -e "${BLUE}🔗 Setting up shell alias...${NC}"
    
    # Detect shell
    SHELL_RC=""
    if [[ "$SHELL" == */zsh ]]; then
        SHELL_RC="$HOME/.zshrc"
    elif [[ "$SHELL" == */bash ]]; then
        SHELL_RC="$HOME/.bashrc"
    fi
    
    if [[ -n "$SHELL_RC" ]]; then
        # Add alias if not already present
        ALIAS_LINE="alias ado='~/.claude/ado-integration.sh'"
        if ! grep -q "$ALIAS_LINE" "$SHELL_RC" 2>/dev/null; then
            echo "Adding ado alias to $SHELL_RC..."
            echo "" >> "$SHELL_RC"
            echo "# Azure DevOps Integration" >> "$SHELL_RC"
            echo "$ALIAS_LINE" >> "$SHELL_RC"
            echo -e "${GREEN}✅ Alias added to $SHELL_RC${NC}"
            echo -e "${YELLOW}Note: Run 'source $SHELL_RC' or restart terminal to use 'ado' command${NC}"
        else
            echo "Alias already exists in $SHELL_RC"
        fi
    else
        echo -e "${YELLOW}⚠️  Could not detect shell. Manually add this alias:${NC}"
        echo "alias ado='~/.claude/ado-integration.sh'"
    fi
}

# Function to run initial setup
run_setup() {
    echo -e "${BLUE}⚙️  Running initial Azure DevOps setup...${NC}"
    
    read -p "Do you want to configure Azure DevOps now? (y/N): " configure_now
    if [[ $configure_now == [yY] ]]; then
        # Make sure the script is executable and run setup
        chmod +x "$CLAUDE_DIR/ado-integration.sh"
        "$CLAUDE_DIR/ado-integration.sh" setup
    else
        echo -e "${YELLOW}⚠️  Skipping setup. Run 'ado setup' when ready.${NC}"
    fi
}

# Function to install project scripts (optional)
install_project_scripts() {
    echo -e "${BLUE}📁 Project scripts installation...${NC}"
    
    read -p "Do you want to install project scripts to current directory? (y/N): " install_scripts
    if [[ $install_scripts == [yY] ]]; then
        if [[ ! -d "./scripts" ]]; then
            mkdir -p "./scripts"
        fi
        
        cp "$PROJECT_SCRIPTS_DIR"/* "./scripts/"
        chmod +x ./scripts/*.sh
        
        echo -e "${GREEN}✅ Project scripts installed in ./scripts/${NC}"
    else
        echo "Project scripts available in: $PROJECT_SCRIPTS_DIR"
        echo "Copy manually when needed for specific projects."
    fi
}

# Function to show completion message
show_completion() {
    echo -e "${GREEN}
╔══════════════════════════════════════════════════════════════╗
║                    Installation Complete!                   ║
╚══════════════════════════════════════════════════════════════╝
${NC}"

    echo -e "${BLUE}🎉 Azure DevOps integration is now installed!${NC}"
    echo ""
    echo -e "${YELLOW}Quick Start:${NC}"
    echo "1. Restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"
    echo "2. Configure Azure DevOps: ado setup"
    echo "3. Test the integration: ado my"
    echo ""
    echo -e "${YELLOW}Available Commands:${NC}"
    echo "  ado setup                 - Configure global Azure DevOps settings"
    echo "  ado list                  - List all work items"
    echo "  ado my                    - Show your assigned work items"
    echo "  ado create Task \"title\"   - Create new work item"
    echo "  ado start [id]            - Start work with git integration"
    echo "  ado complete [id]         - Mark work item as completed"
    echo ""
    echo -e "${BLUE}Documentation:${NC}"
    echo "  README.md                 - Complete setup and usage guide"
    echo "  docs/command-reference.md - All available commands"
    echo "  docs/examples.md          - Usage examples"
    echo "  docs/troubleshooting.md   - Common issues and solutions"
    echo ""
    echo -e "${GREEN}Happy coding! 🚀${NC}"
}

# Main installation flow
main() {
    check_prerequisites
    install_global
    update_claude_framework
    create_alias
    run_setup
    install_project_scripts
    show_completion
}

# Run installation
main "$@"