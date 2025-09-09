#!/bin/bash

# Git + Azure DevOps Integration Script
# Usage: ./scripts/git-workitem.sh [command] [work-item-id]

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Load environment
if [ -f ".env.azure-devops" ]; then
    source .env.azure-devops
    export AZURE_DEVOPS_EXT_PAT
else
    echo -e "${RED}❌ .env.azure-devops file not found!${NC}"
    exit 1
fi

show_help() {
    echo -e "${BLUE}Git + Azure DevOps Integration${NC}"
    echo ""
    echo "Usage: ./scripts/git-workitem.sh [command] [work-item-id]"
    echo ""
    echo -e "${YELLOW}Commands:${NC}"
    echo "  start [id]       Create branch and set work item to Active"
    echo "  progress [id]    Update work item with progress comment"  
    echo "  complete [id]    Set work item to Resolved"
    echo "  link [id]        Link current commit to work item"
    echo "  pr [id]          Create PR and link to work item"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  ./scripts/git-workitem.sh start 123"
    echo "  ./scripts/git-workitem.sh progress 123"
    echo "  ./scripts/git-workitem.sh complete 123"
}

# Start work on an item
start_work() {
    if [ -z "$1" ]; then
        echo -e "${RED}❌ Please provide work item ID${NC}"
        exit 1
    fi
    
    WORK_ITEM_ID="$1"
    
    # Get work item details
    echo -e "${BLUE}📋 Getting work item details...${NC}"
    TITLE=$(az boards work-item show --id "$WORK_ITEM_ID" --query "fields.'System.Title'" -o tsv)
    
    # Create branch name from title
    BRANCH_NAME="workitem-$WORK_ITEM_ID-$(echo "$TITLE" | sed 's/[^a-zA-Z0-9]/-/g' | sed 's/--*/-/g' | tr '[:upper:]' '[:lower:]' | sed 's/^-\|-$//g')"
    
    echo -e "${BLUE}🌿 Creating branch: $BRANCH_NAME${NC}"
    git checkout -b "$BRANCH_NAME"
    
    echo -e "${BLUE}🔄 Setting work item to Active...${NC}"
    az boards work-item update --id "$WORK_ITEM_ID" --state "Active"
    
    # Add comment
    COMMENT="Started work on this item. Branch: $BRANCH_NAME"
    az boards work-item update --id "$WORK_ITEM_ID" --discussion "$COMMENT"
    
    echo -e "${GREEN}✅ Ready to work on #$WORK_ITEM_ID${NC}"
    echo -e "Branch: $BRANCH_NAME"
    echo -e "Work item set to Active"
}

# Update progress
update_progress() {
    if [ -z "$1" ]; then
        echo -e "${RED}❌ Please provide work item ID${NC}"
        exit 1
    fi
    
    WORK_ITEM_ID="$1"
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    LAST_COMMIT=$(git log -1 --pretty=format:"%s")
    
    COMMENT="Progress update from branch: $BRANCH\nLatest commit: $LAST_COMMIT"
    
    echo -e "${BLUE}📝 Updating progress for #$WORK_ITEM_ID...${NC}"
    az boards work-item update --id "$WORK_ITEM_ID" --discussion "$COMMENT"
    
    echo -e "${GREEN}✅ Progress updated${NC}"
}

# Complete work item
complete_work() {
    if [ -z "$1" ]; then
        echo -e "${RED}❌ Please provide work item ID${NC}"
        exit 1
    fi
    
    WORK_ITEM_ID="$1"
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    
    echo -e "${BLUE}✅ Completing work item #$WORK_ITEM_ID...${NC}"
    az boards work-item update --id "$WORK_ITEM_ID" --state "Resolved"
    
    # Add completion comment
    COMMENT="Work completed on branch: $BRANCH. Ready for review."
    az boards work-item update --id "$WORK_ITEM_ID" --discussion "$COMMENT"
    
    echo -e "${GREEN}✅ Work item #$WORK_ITEM_ID marked as Resolved${NC}"
}

# Link commit to work item
link_commit() {
    if [ -z "$1" ]; then
        echo -e "${RED}❌ Please provide work item ID${NC}"
        exit 1
    fi
    
    WORK_ITEM_ID="$1"
    COMMIT_HASH=$(git rev-parse HEAD)
    COMMIT_MSG=$(git log -1 --pretty=format:"%s")
    
    COMMENT="Linked commit: $COMMIT_HASH\nMessage: $COMMIT_MSG"
    
    echo -e "${BLUE}🔗 Linking commit to #$WORK_ITEM_ID...${NC}"
    az boards work-item update --id "$WORK_ITEM_ID" --discussion "$COMMENT"
    
    echo -e "${GREEN}✅ Commit linked to work item${NC}"
}

# Create PR and link
create_pr() {
    if [ -z "$1" ]; then
        echo -e "${RED}❌ Please provide work item ID${NC}"
        exit 1
    fi
    
    WORK_ITEM_ID="$1"
    BRANCH=$(git rev-parse --abbrev-ref HEAD)
    
    # Get work item title for PR
    TITLE=$(az boards work-item show --id "$WORK_ITEM_ID" --query "fields.'System.Title'" -o tsv)
    PR_TITLE="[#$WORK_ITEM_ID] $TITLE"
    
    echo -e "${BLUE}🔀 Creating pull request...${NC}"
    
    # This would need to be adapted based on your git hosting (GitHub, Azure Repos, etc.)
    echo -e "${YELLOW}⚠️  PR creation depends on your git hosting platform${NC}"
    echo -e "Suggested PR title: $PR_TITLE"
    echo -e "Branch: $BRANCH"
    
    # Update work item with PR info
    COMMENT="Pull request created for this work item. Branch: $BRANCH"
    az boards work-item update --id "$WORK_ITEM_ID" --discussion "$COMMENT"
}

# Main execution
case "$1" in
    "start")
        start_work "$2"
        ;;
    "progress")
        update_progress "$2"
        ;;
    "complete")
        complete_work "$2"
        ;;
    "link")
        link_commit "$2"
        ;;
    "pr")
        create_pr "$2"
        ;;
    "help"|"--help"|"-h"|"")
        show_help
        ;;
    *)
        echo -e "${RED}❌ Unknown command: $1${NC}"
        show_help
        exit 1
        ;;
esac