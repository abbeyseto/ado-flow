# Troubleshooting Guide

Common issues and solutions for Azure DevOps integration.

## Setup Issues

### Azure CLI Not Found

**Error:**
```bash
-bash: az: command not found
```

**Solution:**
Install Azure CLI:
- **macOS:** `brew install azure-cli`
- **Windows:** Download from [Microsoft Docs](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- **Linux:** Use package manager or install script

### Azure DevOps Extension Not Installed

**Error:**
```bash
ERROR: 'boards' is misspelled or not recognized by the system.
```

**Solution:**
```bash
az extension add --name azure-devops
```

### Authentication Issues

**Error:**
```bash
ERROR: Please run 'az login' to setup account.
```

**Solution:**
```bash
az login
# or for accounts without subscriptions:
az login --allow-no-subscriptions
```

---

## Configuration Issues

### Global Configuration Not Found

**Error:**
```bash
❌ Global Azure DevOps configuration not found!
Run 'ado setup' to configure Azure DevOps integration
```

**Solution:**
```bash
ado setup
```

Follow the interactive setup to create `~/.claude/ado-config.env`

### Personal Access Token Issues

**Error:**
```bash
ERROR: TF400813: The user '[user]' is not authorized to access this resource.
```

**Possible Causes:**
1. **Expired PAT:** Token has expired
2. **Insufficient Scopes:** Token doesn't have required permissions
3. **Wrong Organization:** PAT created for different organization

**Solutions:**
1. **Create New PAT:**
   - Go to Azure DevOps → User Settings → Personal Access Tokens
   - Create new token with scopes: Work Items (Read & Write), Code (Read)
   - Update configuration with new token

2. **Verify Organization Access:**
   - Ensure you have access to the specified organization
   - Check organization URL format: `https://dev.azure.com/[org-name]`

3. **Check Token Scopes:**
   - Verify PAT has Work Items Read & Write permissions
   - Add Code Read permission for git integration

### Project Not Found

**Error:**
```bash
ERROR: TF200016: The following project does not exist: [ProjectName]
```

**Solution:**
1. **Verify Project Name:**
   ```bash
   az devops project list
   ```

2. **Update Configuration:**
   Edit `~/.claude/ado-config.env` with correct project name

3. **Check Permissions:**
   Ensure you have access to the specified project

---

## Command Execution Issues

### Work Item Not Found

**Error:**
```bash
ERROR: TF401232: Work item [ID] does not exist, or you do not have permissions to read it.
```

**Solutions:**
1. **Verify Work Item ID:**
   - Check the ID exists in Azure DevOps web interface
   - Ensure ID belongs to current project

2. **Check Permissions:**
   - Verify you have read access to the work item
   - Check if work item is in accessible area path

3. **Verify Project Context:**
   - Ensure you're working in the correct project
   - Check project-specific configuration

### Work Item Creation Fails

**Error:**
```bash
ERROR: TF401320: Rule Error for field [FieldName]. Error code: Required, InvalidEmpty.
```

**Common Causes:**
1. **Missing Required Fields:** Work item type requires additional fields
2. **Field Validation:** Field values don't meet validation rules
3. **Process Template:** Organization uses custom process template

**Solutions:**
1. **Check Work Item Template:**
   - Review required fields in Azure DevOps web interface
   - Create work item manually to see required fields

2. **Use Minimal Creation:**
   ```bash
   # Try with just title first
   ado create Task "Test work item"
   
   # Then update with additional fields
   ado update [id] --description "Detailed description"
   ```

3. **Project-Specific Configuration:**
   Create `.env.azure-devops` with project-specific settings:
   ```bash
   AZURE_DEVOPS_AREA_PATH=ProjectName\\TeamName
   AZURE_DEVOPS_ITERATION_PATH=ProjectName\\Sprint1
   ```

### Git Integration Issues

**Branch Creation Fails:**
```bash
fatal: A branch named 'workitem-123-fix-bug' already exists.
```

**Solutions:**
1. **Switch to Existing Branch:**
   ```bash
   git checkout workitem-123-fix-bug
   ```

2. **Delete and Recreate:**
   ```bash
   git branch -D workitem-123-fix-bug
   ado start 123
   ```

3. **Manual Branch Creation:**
   ```bash
   git checkout -b workitem-123-fix-bug-v2
   ado comment 123 "Started work on branch workitem-123-fix-bug-v2"
   ```

### State Transition Failures

**Error:**
```bash
ERROR: TF401320: Rule Error for field State. The transition from [CurrentState] to [NewState] is not valid.
```

**Solutions:**
1. **Check Valid Transitions:**
   - Review work item state flow in Azure DevOps
   - Transition through intermediate states if needed

2. **Manual State Update:**
   ```bash
   # Instead of directly going to Resolved
   ado update 123 --state "Active"
   ado update 123 --state "Resolved"
   ```

---

## Performance Issues

### Slow Command Execution

**Symptoms:**
- Commands take >10 seconds to execute
- Timeouts during operations

**Solutions:**
1. **Network Connectivity:**
   ```bash
   # Test Azure DevOps connectivity
   ping dev.azure.com
   curl -I https://dev.azure.com
   ```

2. **Azure CLI Performance:**
   ```bash
   # Clear Azure CLI cache
   az cache purge
   
   # Update Azure CLI
   az upgrade
   ```

3. **Optimize Queries:**
   ```bash
   # Use specific queries instead of listing all work items
   ado my                    # Instead of: ado list
   ado search "specific"     # Instead of: ado list | grep
   ```

### Rate Limiting

**Error:**
```bash
ERROR: Request rate limit exceeded. Please wait before making more requests.
```

**Solutions:**
1. **Reduce Request Frequency:**
   - Add delays between bulk operations
   - Use batch operations when possible

2. **Implement Retry Logic:**
   ```bash
   # Manual retry with delay
   sleep 30
   ado list
   ```

---

## Integration Issues

### Claude Code Integration

**Command Not Found in Claude Code:**

**Solutions:**
1. **Verify Installation:**
   ```bash
   ls -la ~/.claude/ado-integration.sh
   chmod +x ~/.claude/ado-integration.sh
   ```

2. **Check Framework Integration:**
   - Ensure `@ADO.md` is added to `~/.claude/CLAUDE.md`
   - Verify `/ado` command is added to `~/.claude/COMMANDS.md`

3. **Test Direct Execution:**
   ```bash
   ~/.claude/ado-integration.sh help
   ```

### Shell Integration

**Alias Not Working:**

**Solutions:**
1. **Add to Shell Profile:**
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   alias ado='~/.claude/ado-integration.sh'
   
   # Reload shell
   source ~/.bashrc
   ```

2. **Create Symbolic Link:**
   ```bash
   sudo ln -s ~/.claude/ado-integration.sh /usr/local/bin/ado
   ```

---

## Diagnostic Commands

### Health Check Script

```bash
#!/bin/bash
echo "Azure DevOps Integration Health Check"
echo "====================================="

# Check Azure CLI
echo "1. Azure CLI:"
if command -v az &> /dev/null; then
    echo "   ✅ Installed: $(az --version | head -1)"
else
    echo "   ❌ Not installed"
fi

# Check Azure DevOps Extension
echo "2. Azure DevOps Extension:"
if az extension show --name azure-devops &> /dev/null; then
    echo "   ✅ Installed"
else
    echo "   ❌ Not installed"
fi

# Check Authentication
echo "3. Azure Authentication:"
if az account show &> /dev/null; then
    echo "   ✅ Authenticated: $(az account show --query user.name -o tsv)"
else
    echo "   ❌ Not authenticated"
fi

# Check Configuration
echo "4. Configuration:"
if [ -f ~/.claude/ado-config.env ]; then
    echo "   ✅ Global config exists"
    source ~/.claude/ado-config.env
    if [ -n "$AZURE_DEVOPS_EXT_PAT" ] && [ -n "$AZURE_DEVOPS_ORG_URL" ] && [ -n "$AZURE_DEVOPS_PROJECT" ]; then
        echo "   ✅ Required variables set"
    else
        echo "   ❌ Missing required variables"
    fi
else
    echo "   ❌ Global config not found"
fi

# Check Project Override
if [ -f .env.azure-devops ]; then
    echo "   ✅ Project config override exists"
fi

# Test Connection
echo "5. Azure DevOps Connection:"
if ~/.claude/ado-integration.sh list &> /dev/null; then
    echo "   ✅ Connection successful"
else
    echo "   ❌ Connection failed"
fi

echo ""
echo "Health check complete!"
```

### Debug Mode

Add debug output to commands:
```bash
# Enable debug mode
export ADO_DEBUG=1

# Run command with debug output
ado list
```

---

## Getting Help

### Documentation Resources
1. **Package Documentation:** Check `docs/` folder
2. **Azure DevOps CLI:** `az boards --help`
3. **Microsoft Docs:** [Azure DevOps CLI Reference](https://docs.microsoft.com/en-us/cli/azure/boards)

### Community Support
1. **Azure DevOps Community:** [Developer Community](https://developercommunity.visualstudio.com/spaces/21/index.html)
2. **Azure CLI Issues:** [GitHub Repository](https://github.com/Azure/azure-cli)

### Reporting Issues
When reporting issues, include:
1. **Environment Information:**
   - Operating system
   - Azure CLI version
   - Azure DevOps extension version

2. **Configuration Details:**
   - Organization and project names (redacted)
   - Work item types being used
   - Process template (if known)

3. **Error Messages:**
   - Complete error messages
   - Steps to reproduce
   - Expected vs actual behavior

4. **Debug Information:**
   ```bash
   # Run with verbose output
   az boards work-item show --id 123 --debug
   ```