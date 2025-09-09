#!/bin/bash

# Azure DevOps Work Items Management Script
# Usage: ./scripts/ado.sh [command] [options]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Load environment variables
load_env() {
    if [ -f ".env.azure-devops" ]; then
        source .env.azure-devops
        export AZURE_DEVOPS_EXT_PAT
        export AZURE_DEVOPS_ORG_URL
        export AZURE_DEVOPS_PROJECT
    else
        echo -e "${RED}❌ .env.azure-devops file not found!${NC}"
        echo "Run ./scripts/setup-azure-devops.sh first"
        exit 1
    fi
}

# Help function
show_help() {
    echo -e "${BLUE}Azure DevOps Work Items CLI${NC}"
    echo ""
    echo "Usage: ./scripts/ado.sh [command] [options]"
    echo ""
    echo -e "${YELLOW}Commands:${NC}"
    echo "  list                    List all work items"
    echo "  search [query]          Search work items by title"
    echo "  show [id]               Show work item details"
    echo "  create [type] [title]   Create new work item"
    echo "  update [id] [field=value] Update work item"
    echo "  comment [id] [text]     Add comment to work item"
    echo "  assign [id] [email]     Assign work item"
    echo "  state [id] [state]      Change work item state"
    echo "  my                      Show my assigned work items"
    echo ""
    echo -e "${YELLOW}Work Item Types:${NC}"
    echo "  Task, Bug, User Story, Feature, Epic, Issue"
    echo ""
    echo -e "${YELLOW}Common States:${NC}"
    echo "  New, Active, Resolved, Closed, Removed"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  ./scripts/ado.sh list"
    echo "  ./scripts/ado.sh create Task \"Fix authentication bug\""
    echo "  ./scripts/ado.sh update 123 --state \"In Progress\""
    echo "  ./scripts/ado.sh assign 123 user@domain.com"
    echo "  ./scripts/ado.sh my"
}

# List work items
list_items() {
    echo -e "${BLUE}📋 Listing work items...${NC}"
    az boards query --wiql "SELECT [System.Id], [System.Title], [System.State], [System.AssignedTo], [System.WorkItemType] FROM WorkItems ORDER BY [System.Id] DESC"
}

# Search work items
search_items() {
    if [ -z "$1" ]; then
        echo -e "${RED}❌ Please provide a search query${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}🔍 Searching for: $1${NC}"
    az boards query --wiql "SELECT [System.Id], [System.Title], [System.State], [System.AssignedTo] FROM WorkItems WHERE [System.Title] CONTAINS '$1'"
}

# Show work item details
show_item() {
    if [ -z "$1" ]; then
        echo -e "${RED}❌ Please provide work item ID${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}📄 Work Item #$1 Details:${NC}"
    az boards work-item show --id "$1"
}

# Create work item
create_item() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo -e "${RED}❌ Please provide work item type and title${NC}"
        echo "Usage: create [type] [title]"
        exit 1
    fi
    
    echo -e "${BLUE}✨ Creating $1: $2${NC}"
    az boards work-item create --type "$1" --title "$2"
}

# Update work item
update_item() {
    if [ -z "$1" ]; then
        echo -e "${RED}❌ Please provide work item ID${NC}"
        exit 1
    fi
    
    shift
    echo -e "${BLUE}📝 Updating work item #$1${NC}"
    az boards work-item update --id "$1" "$@"
}

# Add comment
add_comment() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo -e "${RED}❌ Please provide work item ID and comment${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}💬 Adding comment to #$1${NC}"
    az boards work-item update --id "$1" --discussion "$2"
}

# Assign work item
assign_item() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo -e "${RED}❌ Please provide work item ID and email${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}👤 Assigning #$1 to $2${NC}"
    az boards work-item update --id "$1" --assigned-to "$2"
}

# Change state
change_state() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo -e "${RED}❌ Please provide work item ID and state${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}🔄 Changing #$1 to $2${NC}"
    az boards work-item update --id "$1" --state "$2"
}

# Show my work items
my_items() {
    user_email=$(az account show --query user.name -o tsv)
    echo -e "${BLUE}👤 My assigned work items:${NC}"
    az boards query --wiql "SELECT [System.Id], [System.Title], [System.State], [System.WorkItemType] FROM WorkItems WHERE [System.AssignedTo] = '$user_email'"
}

# Main execution
load_env

case "$1" in
    "list")
        list_items
        ;;
    "search")
        search_items "$2"
        ;;
    "show")
        show_item "$2"
        ;;
    "create")
        create_item "$2" "$3"
        ;;
    "update")
        update_item "$@"
        ;;
    "comment")
        add_comment "$2" "$3"
        ;;
    "assign")
        assign_item "$2" "$3"
        ;;
    "state")
        change_state "$2" "$3"
        ;;
    "my")
        my_items
        ;;
    "help"|"--help"|"-h"|"")
        show_help
        ;;
    *)
        echo -e "${RED}❌ Unknown command: $1${NC}"
        echo "Run './scripts/ado.sh help' for usage information"
        exit 1
        ;;
esac