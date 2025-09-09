#!/bin/bash

# Quick Task Creation Script
# Usage: ./scripts/create-task.sh [task-title]

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Load environment
if [ -f ".env.azure-devops" ]; then
    source .env.azure-devops
    export AZURE_DEVOPS_EXT_PAT
else
    echo "❌ .env.azure-devops file not found!"
    exit 1
fi

if [ -z "$1" ]; then
    echo -e "${BLUE}Quick Task Creator${NC}"
    echo ""
    echo "Usage: ./scripts/create-task.sh \"Task title\""
    echo ""
    echo -e "${YELLOW}Quick templates:${NC}"
    echo "  fix-bug [description]     - Create bug fix task"
    echo "  feature [description]     - Create feature task"  
    echo "  test [description]        - Create testing task"
    echo "  docs [description]        - Create documentation task"
    echo "  refactor [description]    - Create refactoring task"
    echo ""
    echo "Example: ./scripts/create-task.sh fix-bug \"Authentication not working\""
    exit 1
fi

# Get current git branch for context
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")
USER_EMAIL=$(git config user.email 2>/dev/null || echo "")

case "$1" in
    "fix-bug")
        TITLE="🐛 Bug Fix: $2"
        TYPE="Bug"
        DESCRIPTION="Fix: $2\n\nBranch: $BRANCH"
        ;;
    "feature")
        TITLE="✨ Feature: $2"  
        TYPE="Task"
        DESCRIPTION="Implement: $2\n\nBranch: $BRANCH"
        ;;
    "test")
        TITLE="🧪 Testing: $2"
        TYPE="Task"
        DESCRIPTION="Test: $2\n\nBranch: $BRANCH"
        ;;
    "docs")
        TITLE="📚 Documentation: $2"
        TYPE="Task"
        DESCRIPTION="Document: $2\n\nBranch: $BRANCH"
        ;;
    "refactor")
        TITLE="♻️ Refactor: $2"
        TYPE="Task"  
        DESCRIPTION="Refactor: $2\n\nBranch: $BRANCH"
        ;;
    *)
        TITLE="$1"
        TYPE="Task"
        DESCRIPTION="$1\n\nBranch: $BRANCH"
        ;;
esac

echo -e "${BLUE}🚀 Creating work item...${NC}"
echo -e "Title: $TITLE"
echo -e "Type: $TYPE"
echo ""

# Create the work item
RESULT=$(az boards work-item create \
    --type "$TYPE" \
    --title "$TITLE" \
    --description "$DESCRIPTION" \
    --output json)

# Extract ID and URL
ID=$(echo "$RESULT" | jq -r '.id')
URL=$(echo "$RESULT" | jq -r '.url')

echo -e "${GREEN}✅ Work item created successfully!${NC}"
echo -e "ID: #$ID"
echo -e "URL: $URL"

# Auto-assign to current user if email is available
if [ ! -z "$USER_EMAIL" ]; then
    echo -e "${YELLOW}🔄 Auto-assigning to $USER_EMAIL...${NC}"
    az boards work-item update --id "$ID" --assigned-to "$USER_EMAIL" > /dev/null
    echo -e "${GREEN}✅ Assigned to $USER_EMAIL${NC}"
fi