#!/bin/bash

# ado-flow - Streamlined Azure DevOps workflow automation
# This script provides intelligent Azure DevOps work item management with Git integration

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Global Azure DevOps configuration file
GLOBAL_ADO_CONFIG="$HOME/.claude/ado-config.env"

# Get current user email for work item assignment
get_user_email() {
    # Try multiple sources for user email
    local user_email=""
    
    # First try Azure CLI
    user_email=$(az account show --query user.name -o tsv 2>/dev/null || echo "")
    
    # If not available, try git config
    if [ -z "$user_email" ]; then
        user_email=$(git config --global user.email 2>/dev/null || echo "")
    fi
    
    # If still not available, check config file
    if [ -z "$user_email" ] && [ -f "$GLOBAL_ADO_CONFIG" ]; then
        user_email=$(grep "^AZURE_DEVOPS_USER_EMAIL=" "$GLOBAL_ADO_CONFIG" | cut -d'=' -f2 2>/dev/null || echo "")
    fi
    
    echo "$user_email"
}

# Interactive work item parent selection
select_parent_work_item() {
    local work_item_type="$1"
    local parent_type=""
    
    case "$work_item_type" in
        "Feature")
            parent_type="Epic"
            ;;
        "User Story")
            parent_type="Feature"
            ;;
        "Task")
            parent_type="User Story"
            ;;
        "Bug")
            echo -e "${YELLOW}Bugs can be linked to any work item type. Choose parent type:${NC}"
            echo "1) Epic"
            echo "2) Feature" 
            echo "3) User Story"
            echo "4) Task"
            echo "5) Skip linking"
            read -p "Select parent type (1-5): " parent_choice
            case "$parent_choice" in
                1) parent_type="Epic" ;;
                2) parent_type="Feature" ;;
                3) parent_type="User Story" ;;
                4) parent_type="Task" ;;
                *) return 1 ;; # Skip linking
            esac
            ;;
        *)
            return 1 # No linking for other types
            ;;
    esac
    
    if [ -n "$parent_type" ]; then
        echo -e "${BLUE}Available ${parent_type}s for linking:${NC}"
        local wiql="SELECT [System.Id], [System.Title] FROM WorkItems WHERE [System.WorkItemType] = '$parent_type' AND [System.State] != 'Closed' ORDER BY [System.Id] DESC"
        local parents=$(az boards query --wiql "$wiql" --output table 2>/dev/null)
        
        if [ -n "$parents" ]; then
            echo "$parents"
            echo ""
            read -p "Enter parent work item ID (or press Enter to skip): " parent_id
            if [[ "$parent_id" =~ ^[0-9]+$ ]]; then
                echo "$parent_id"
                return 0
            fi
        else
            echo -e "${YELLOW}No available ${parent_type}s found.${NC}"
        fi
    fi
    
    return 1
}

# Load global configuration
load_global_config() {
    if [ -f "$GLOBAL_ADO_CONFIG" ]; then
        source "$GLOBAL_ADO_CONFIG"
        export AZURE_DEVOPS_EXT_PAT
        export AZURE_DEVOPS_ORG_URL
        export AZURE_DEVOPS_PROJECT
        return 0
    else
        echo -e "${RED}❌ Global ado-flow configuration not found!${NC}"
        echo "Run 'ado setup' to configure ado-flow integration"
        return 1
    fi
}

# Setup global configuration
setup_global_config() {
    echo -e "${BLUE}🚀 Setting up ado-flow${NC}"
    echo ""
    
    # Check if Azure CLI and DevOps extension are installed
    if ! command -v az &> /dev/null; then
        echo -e "${RED}❌ Azure CLI not found. Please install Azure CLI first.${NC}"
        echo "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
        exit 1
    fi
    
    if ! az extension show --name azure-devops &> /dev/null; then
        echo -e "${YELLOW}Installing Azure DevOps CLI extension...${NC}"
        az extension add --name azure-devops
    fi
    
    # Collect configuration
    echo -e "${YELLOW}Enter your Azure DevOps details:${NC}"
    read -p "Organization URL (e.g., https://dev.azure.com/YourOrg): " org_url
    read -p "Default Project Name: " project_name
    read -s -p "Personal Access Token: " pat_token
    echo ""
    
    # Get user email for auto-assignment
    default_email=$(get_user_email)
    if [ -n "$default_email" ]; then
        echo -e "${YELLOW}Detected email: $default_email${NC}"
        read -p "Use this email for work item assignment? (Y/n): " use_detected
        if [[ $use_detected != [nN] ]]; then
            user_email="$default_email"
        else
            read -p "Enter your work email for assignments: " user_email
        fi
    else
        read -p "Enter your work email for automatic assignment: " user_email
    fi
    
    # Create global configuration
    cat > "$GLOBAL_ADO_CONFIG" << EOF
# Global Azure DevOps Configuration for Claude Code
AZURE_DEVOPS_EXT_PAT=$pat_token
AZURE_DEVOPS_ORG_URL=$org_url
AZURE_DEVOPS_PROJECT=$project_name
AZURE_DEVOPS_USER_EMAIL=$user_email
EOF
    
    chmod 600 "$GLOBAL_ADO_CONFIG"
    
    # Test connection
    echo -e "${BLUE}🔍 Testing connection...${NC}"
    if load_global_config && az boards query --wiql "SELECT [System.Id], [System.Title] FROM WorkItems" --top 1 &> /dev/null; then
        echo -e "${GREEN}✅ Azure DevOps integration configured successfully!${NC}"
        echo -e "Organization: $AZURE_DEVOPS_ORG_URL"
        echo -e "Project: $AZURE_DEVOPS_PROJECT"
    else
        echo -e "${RED}❌ Failed to connect. Please check your configuration.${NC}"
        rm -f "$GLOBAL_ADO_CONFIG"
        exit 1
    fi
}

# Override project-specific settings if local config exists
load_project_config() {
    local project_config="$PWD/.env.azure-devops"
    if [ -f "$project_config" ]; then
        echo -e "${YELLOW}ℹ️  Using project-specific Azure DevOps configuration${NC}"
        source "$project_config"
        export AZURE_DEVOPS_EXT_PAT
        export AZURE_DEVOPS_ORG_URL  
        export AZURE_DEVOPS_PROJECT
        return 0
    fi
    return 1
}

# Main command dispatcher
execute_ado_command() {
    # Handle setup command first (doesn't need existing config)
    if [ "$1" = "setup" ]; then
        setup_global_config
        return
    fi
    
    # For all other commands, try to load project-specific config first, then global
    if ! load_project_config && ! load_global_config; then
        exit 1
    fi
    
    case "$1" in
        "list")
            echo -e "${BLUE}📋 Listing work items...${NC}"
            az boards query --wiql "SELECT [System.Id], [System.Title], [System.State], [System.AssignedTo], [System.WorkItemType] FROM WorkItems ORDER BY [System.Id] DESC"
            ;;
        "my")
            user_email=$(az account show --query user.name -o tsv 2>/dev/null || echo "")
            echo -e "${BLUE}👤 My assigned work items:${NC}"
            if [ ! -z "$user_email" ]; then
                az boards query --wiql "SELECT [System.Id], [System.Title], [System.State], [System.WorkItemType] FROM WorkItems WHERE [System.AssignedTo] = '$user_email'"
            else
                echo -e "${YELLOW}⚠️  Unable to determine user email. Showing all work items assigned to @Me${NC}"
                az boards query --wiql "SELECT [System.Id], [System.Title], [System.State], [System.WorkItemType] FROM WorkItems WHERE [System.AssignedTo] = @Me"
            fi
            ;;
        "create")
            if [ -z "$2" ] || [ -z "$3" ]; then
                echo -e "${RED}❌ Usage: ado create [type] [title] [description]${NC}"
                echo -e "${YELLOW}Supported types: Epic, Feature, 'User Story', Task, Bug${NC}"
                exit 1
            fi
            echo -e "${BLUE}✨ Creating $2: $3${NC}"
            BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
            DESCRIPTION="${4:-Created from ado-flow\n\nBranch: $BRANCH}"
            
            # Get user email for assignment
            USER_EMAIL=$(get_user_email)
            ASSIGNED_TO_FIELD=""
            if [ -n "$USER_EMAIL" ]; then
                ASSIGNED_TO_FIELD="\"System.AssignedTo=$USER_EMAIL\""
            fi
            
            # Check for parent linking
            PARENT_ID=""
            if select_parent_work_item "$2" >/dev/null; then
                PARENT_ID=$(select_parent_work_item "$2")
            fi
            
            # Set fields based on work item type
            case "$2" in
                "Epic")
                    TYPE_FIELDS=""
                    ;;
                "Feature")
                    # Calculate target date (30 days from now) - works on both Linux and macOS
                    if date -v+30d >/dev/null 2>&1; then
                        # macOS
                        TARGET_DATE=$(date -v+30d '+%Y-%m-%d')
                    else
                        # Linux
                        TARGET_DATE=$(date -d '+30 days' '+%Y-%m-%d')
                    fi
                    TYPE_FIELDS="\"Microsoft.VSTS.Scheduling.TargetDate=$TARGET_DATE\" \"Microsoft.VSTS.Common.AcceptanceCriteria=Feature acceptance criteria to be defined\""
                    ;;
                "User Story")
                    TYPE_FIELDS="\"Microsoft.VSTS.Common.Risk=2 - Medium\" \"Microsoft.VSTS.Common.AcceptanceCriteria=User story acceptance criteria to be defined\" \"Microsoft.VSTS.Scheduling.StoryPoints=3\""
                    ;;
                "Task")
                    TYPE_FIELDS="\"Microsoft.VSTS.Scheduling.RemainingWork=4\" \"Microsoft.VSTS.Scheduling.OriginalEstimate=4\" \"Microsoft.VSTS.Scheduling.CompletedWork=0\" \"Microsoft.VSTS.Common.Activity=Development\""
                    ;;
                "Bug")
                    TYPE_FIELDS="\"Microsoft.VSTS.Common.Severity=2 - Medium\" \"Microsoft.VSTS.Common.Priority=2\" \"Microsoft.VSTS.TCM.ReproSteps=Steps to reproduce will be added\""
                    ;;
                *)
                    echo -e "${YELLOW}⚠️  Unknown work item type. Trying with minimal fields...${NC}"
                    TYPE_FIELDS=""
                    ;;
            esac
            
            # Combine all fields
            ALL_FIELDS=""
            if [ -n "$ASSIGNED_TO_FIELD" ] && [ -n "$TYPE_FIELDS" ]; then
                ALL_FIELDS="--fields $ASSIGNED_TO_FIELD $TYPE_FIELDS"
            elif [ -n "$ASSIGNED_TO_FIELD" ]; then
                ALL_FIELDS="--fields $ASSIGNED_TO_FIELD"
            elif [ -n "$TYPE_FIELDS" ]; then
                ALL_FIELDS="--fields $TYPE_FIELDS"
            fi
            
            # Create the work item with appropriate fields
            if [ -z "$ALL_FIELDS" ]; then
                RESULT=$(az boards work-item create --type "$2" --title "$3" --description "$DESCRIPTION" --output json 2>&1)
            else
                eval "RESULT=\$(az boards work-item create --type \"$2\" --title \"$3\" --description \"$DESCRIPTION\" $ALL_FIELDS --output json 2>&1)"
            fi
            
            # Parse result
            if echo "$RESULT" | jq -e '.id' >/dev/null 2>&1; then
                ID=$(echo "$RESULT" | jq -r '.id')
                echo -e "${GREEN}✅ Work item #$ID created successfully!${NC}"
                echo -e "URL: $(echo "$RESULT" | jq -r '.url')"
                
                # Link to parent if selected
                if [[ "$PARENT_ID" =~ ^[0-9]+$ ]]; then
                    echo -e "${BLUE}🔗 Linking to parent work item #$PARENT_ID...${NC}"
                    LINK_RESULT=$(az boards work-item relation add --id "$ID" --relation-type "parent" --target-id "$PARENT_ID" 2>&1)
                    if echo "$LINK_RESULT" | grep -q "error\|Error\|ERROR" 2>/dev/null; then
                        echo -e "${YELLOW}⚠️  Could not link to parent: $LINK_RESULT${NC}"
                    else
                        echo -e "${GREEN}✅ Successfully linked to parent work item #$PARENT_ID${NC}"
                    fi
                fi
                
                # Show assignment info
                if [ -n "$USER_EMAIL" ]; then
                    echo -e "${GREEN}👤 Assigned to: $USER_EMAIL${NC}"
                fi
            elif echo "$RESULT" | grep -q "ERROR"; then
                echo -e "${RED}❌ Failed to create work item:${NC}"
                echo "$RESULT" | grep "ERROR"
            else
                echo -e "${YELLOW}⚠️  Work item creation status unclear${NC}"
                echo "$RESULT"
            fi
            ;;
        "show")
            if [ -z "$2" ]; then
                echo -e "${RED}❌ Usage: ado show [work-item-id]${NC}"
                exit 1
            fi
            echo -e "${BLUE}📄 Work Item #$2 Details:${NC}"
            az boards work-item show --id "$2"
            ;;
        "update")
            if [ -z "$2" ]; then
                echo -e "${RED}❌ Usage: ado update [work-item-id] [options]${NC}"
                exit 1
            fi
            shift 2
            echo -e "${BLUE}📝 Updating work item #$2${NC}"
            az boards work-item update --id "$2" "$@"
            ;;
        "comment")
            if [ -z "$2" ] || [ -z "$3" ]; then
                echo -e "${RED}❌ Usage: ado comment [work-item-id] [comment]${NC}"
                exit 1
            fi
            echo -e "${BLUE}💬 Adding comment to #$2${NC}"
            az boards work-item update --id "$2" --discussion "$3"
            ;;
        "start")
            if [ -z "$2" ]; then
                echo -e "${RED}❌ Usage: ado start [work-item-id]${NC}"
                exit 1
            fi
            WORK_ITEM_ID="$2"
            
            # Get work item details
            TITLE=$(az boards work-item show --id "$WORK_ITEM_ID" --query "fields.'System.Title'" -o tsv 2>/dev/null || echo "work-item")
            
            # Create branch name from title
            BRANCH_NAME="workitem-$WORK_ITEM_ID-$(echo "$TITLE" | sed 's/[^a-zA-Z0-9]/-/g' | sed 's/--*/-/g' | tr '[:upper:]' '[:lower:]' | sed 's/^-\|-$//g')"
            
            echo -e "${BLUE}🌿 Creating branch: $BRANCH_NAME${NC}"
            git checkout -b "$BRANCH_NAME" 2>/dev/null || echo -e "${YELLOW}⚠️  Branch may already exist${NC}"
            
            echo -e "${BLUE}🔄 Setting work item to Active...${NC}"
            az boards work-item update --id "$WORK_ITEM_ID" --state "Active" 2>/dev/null || echo -e "${YELLOW}⚠️  Could not update state${NC}"
            
            COMMENT="Started work on this item via ado-flow. Branch: $BRANCH_NAME"
            az boards work-item update --id "$WORK_ITEM_ID" --discussion "$COMMENT" 2>/dev/null || echo -e "${YELLOW}⚠️  Could not add comment${NC}"
            
            echo -e "${GREEN}✅ Ready to work on #$WORK_ITEM_ID${NC}"
            ;;
        "complete")
            if [ -z "$2" ]; then
                echo -e "${RED}❌ Usage: ado complete [work-item-id]${NC}"
                exit 1
            fi
            WORK_ITEM_ID="$2"
            BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
            
            echo -e "${BLUE}✅ Completing work item #$WORK_ITEM_ID...${NC}"
            az boards work-item update --id "$WORK_ITEM_ID" --state "Resolved" 2>/dev/null || echo -e "${YELLOW}⚠️  Could not update state${NC}"
            
            COMMENT="Work completed via ado-flow on branch: $BRANCH. Ready for review."
            az boards work-item update --id "$WORK_ITEM_ID" --discussion "$COMMENT" 2>/dev/null || echo -e "${YELLOW}⚠️  Could not add comment${NC}"
            
            echo -e "${GREEN}✅ Work item #$WORK_ITEM_ID marked as Resolved${NC}"
            ;;
        "search")
            if [ -z "$2" ]; then
                echo -e "${RED}❌ Usage: ado search [query]${NC}"
                exit 1
            fi
            echo -e "${BLUE}🔍 Searching for: $2${NC}"
            az boards query --wiql "SELECT [System.Id], [System.Title], [System.State], [System.AssignedTo] FROM WorkItems WHERE [System.Title] CONTAINS '$2'"
            ;;
        "link")
            if [ -z "$2" ] || [ -z "$3" ]; then
                echo -e "${RED}❌ Usage: ado link [child-id] [parent-id]${NC}"
                echo -e "${YELLOW}Links child work item to parent work item${NC}"
                exit 1
            fi
            CHILD_ID="$2"
            PARENT_ID="$3"
            
            echo -e "${BLUE}🔗 Linking work item #$CHILD_ID to parent #$PARENT_ID...${NC}"
            LINK_RESULT=$(az boards work-item relation add --id "$CHILD_ID" --relation-type "parent" --target-id "$PARENT_ID" 2>&1)
            
            if echo "$LINK_RESULT" | grep -q "error\|Error\|ERROR" 2>/dev/null; then
                echo -e "${RED}❌ Failed to link work items:${NC}"
                echo "$LINK_RESULT"
            else
                echo -e "${GREEN}✅ Successfully linked work item #$CHILD_ID to parent #$PARENT_ID${NC}"
            fi
            ;;
        "assign")
            if [ -z "$2" ]; then
                echo -e "${RED}❌ Usage: ado assign [work-item-id] [email-or-'me']${NC}"
                exit 1
            fi
            WORK_ITEM_ID="$2"
            ASSIGNEE="${3:-me}"
            
            if [ "$ASSIGNEE" = "me" ]; then
                ASSIGNEE=$(get_user_email)
                if [ -z "$ASSIGNEE" ]; then
                    echo -e "${RED}❌ Could not determine your email. Please specify email explicitly.${NC}"
                    exit 1
                fi
            fi
            
            echo -e "${BLUE}👤 Assigning work item #$WORK_ITEM_ID to $ASSIGNEE...${NC}"
            az boards work-item update --id "$WORK_ITEM_ID" --assigned-to "$ASSIGNEE"
            echo -e "${GREEN}✅ Work item #$WORK_ITEM_ID assigned to $ASSIGNEE${NC}"
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

show_help() {
    echo -e "${BLUE}ado-flow - Streamlined Azure DevOps workflow automation${NC}"
    echo ""
    echo -e "${YELLOW}Global Commands:${NC}"
    echo "  ado setup                   Setup global Azure DevOps configuration"
    echo "  ado list                    List all work items"
    echo "  ado my                      Show my assigned work items"
    echo "  ado search [query]          Search work items"
    echo "  ado show [id]               Show work item details"
    echo ""
    echo -e "${YELLOW}Work Item Management:${NC}"
    echo "  ado create [type] [title] [description]   Create new work item"
    echo "      Types: Epic, Feature, 'User Story', Task, Bug"
    echo "      Auto-handles required fields, assignment, and parent linking"
    echo "  ado update [id] [options]   Update work item"
    echo "  ado comment [id] [text]     Add comment to work item"
    echo "  ado link [child-id] [parent-id]          Link work items (child to parent)"
    echo "  ado assign [id] [email-or-'me']          Assign work item to user"
    echo ""
    echo -e "${YELLOW}Git Integration:${NC}"
    echo "  ado start [id]              Create branch and set work item to Active"
    echo "  ado complete [id]           Mark work item as Resolved"
    echo ""
    echo -e "${YELLOW}Configuration:${NC}"
    echo "  Global config: ~/.claude/ado-config.env"
    echo "  Project config: ./.env.azure-devops (overrides global)"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  ado setup"
    echo "  ado my"
    echo "  ado create Epic 'User Management System'"
    echo "  ado create Feature 'User Authentication' 'OAuth 2.0 integration'"
    echo "  ado create 'User Story' 'User login functionality' 'As a user I want to login'"
    echo "  ado create Task 'Fix authentication bug' 'Update JWT validation logic'"
    echo "  ado create Bug 'Login button not working' 'Button click not responsive on mobile'"
    echo "  ado link 456 123           # Link task 456 to story 123"
    echo "  ado assign 456 me          # Assign work item to yourself"
    echo "  ado start 123"
    echo "  ado complete 123"
}

# Execute the command
execute_ado_command "$@"