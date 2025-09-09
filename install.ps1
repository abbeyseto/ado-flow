# ado-flow - Windows PowerShell Installation Script
# Supports Windows 10/11 with automatic dependency installation
# Author: Adenle Abiodun <adenleabbey@gmail.com>
# Requires: PowerShell 5.1 or later, Administrator privileges for system-wide install

param(
    [switch]$User = $false,
    [switch]$Force = $false,
    [switch]$Help = $false
)

# Version and repository information
$Version = "1.0.0"
$RepoUrl = "https://github.com/abbeyseto/ado-flow"

# Installation directories
$InstallDir = if ($User) { "$env:USERPROFILE\.ado-cli" } else { "$env:ProgramFiles\ADO-CLI" }
$ConfigDir = "$env:USERPROFILE\.claude"
$BinDir = if ($User) { "$env:USERPROFILE\.local\bin" } else { "$env:ProgramFiles\ADO-CLI\bin" }

# Colors for console output
$Red = [System.ConsoleColor]::Red
$Green = [System.ConsoleColor]::Green
$Blue = [System.ConsoleColor]::Blue
$Yellow = [System.ConsoleColor]::Yellow
$White = [System.ConsoleColor]::White

function Write-ColoredOutput {
    param(
        [string]$Text,
        [System.ConsoleColor]$Color = $White
    )
    $originalColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Host $Text
    $Host.UI.RawUI.ForegroundColor = $originalColor
}

function Show-Help {
    Write-ColoredOutput "ado-flow Installer for Windows" $Blue
    Write-Host ""
    Write-Host "Usage: .\install.ps1 [options]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -User     Install for current user only (no admin required)"
    Write-Host "  -Force    Force reinstall even if already installed"
    Write-Host "  -Help     Show this help message"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  .\install.ps1              # System-wide install (requires admin)"
    Write-Host "  .\install.ps1 -User        # User-only install"
    Write-Host "  .\install.ps1 -Force -User # Force reinstall for user"
    Write-Host ""
}

function Test-AdminPrivileges {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-PowerShellVersion {
    $version = $PSVersionTable.PSVersion
    if ($version.Major -lt 5) {
        Write-ColoredOutput "❌ PowerShell 5.1 or later is required. Current version: $($version.ToString())" $Red
        Write-ColoredOutput "Please update PowerShell: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell" $Yellow
        exit 1
    }
    Write-ColoredOutput "✅ PowerShell version: $($version.ToString())" $Green
}

function Install-Prerequisites {
    Write-ColoredOutput "📦 Checking prerequisites..." $Blue
    
    # Check for Git
    try {
        $gitVersion = git --version
        Write-ColoredOutput "✅ Git found: $gitVersion" $Green
    }
    catch {
        Write-ColoredOutput "⚠️  Git not found. Installing Git..." $Yellow
        
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
        }
        elseif (Get-Command choco -ErrorAction SilentlyContinue) {
            choco install git -y
        }
        else {
            Write-ColoredOutput "❌ Please install Git manually from: https://git-scm.com/download/win" $Red
            Write-ColoredOutput "Or install Chocolatey/winget for automatic package management" $Yellow
            exit 1
        }
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        try {
            $gitVersion = git --version
            Write-ColoredOutput "✅ Git installed successfully: $gitVersion" $Green
        }
        catch {
            Write-ColoredOutput "❌ Git installation failed. Please install manually." $Red
            exit 1
        }
    }
    
    # Check for Azure CLI
    try {
        $azVersion = az --version | Select-Object -First 1
        Write-ColoredOutput "✅ Azure CLI found: $azVersion" $Green
    }
    catch {
        Write-ColoredOutput "⚠️  Azure CLI not found. Installing..." $Yellow
        Install-AzureCLI
    }
    
    # Check for Azure DevOps extension
    try {
        $extensions = az extension list --output json | ConvertFrom-Json
        $devopsExtension = $extensions | Where-Object { $_.name -eq "azure-devops" }
        
        if ($devopsExtension) {
            Write-ColoredOutput "✅ Azure DevOps extension found" $Green
        }
        else {
            Write-ColoredOutput "📦 Installing Azure DevOps CLI extension..." $Yellow
            az extension add --name azure-devops
            Write-ColoredOutput "✅ Azure DevOps extension installed" $Green
        }
    }
    catch {
        Write-ColoredOutput "❌ Failed to check/install Azure DevOps extension" $Red
        exit 1
    }
}

function Install-AzureCLI {
    try {
        # Try winget first
        if (Get-Command winget -ErrorAction SilentlyContinue) {
            winget install --id Microsoft.AzureCLI -e --source winget --accept-package-agreements --accept-source-agreements
        }
        # Try Chocolatey
        elseif (Get-Command choco -ErrorAction SilentlyContinue) {
            choco install azure-cli -y
        }
        # Try direct MSI download
        else {
            Write-ColoredOutput "⚠️  Downloading Azure CLI installer..." $Yellow
            $msiPath = "$env:TEMP\azure-cli.msi"
            Invoke-WebRequest -Uri "https://aka.ms/installazurecliwindows" -OutFile $msiPath
            
            Write-ColoredOutput "⚠️  Installing Azure CLI (this may take a few minutes)..." $Yellow
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", $msiPath, "/quiet", "/norestart" -Wait
            
            Remove-Item $msiPath -Force
        }
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        # Test installation
        $azVersion = az --version | Select-Object -First 1
        Write-ColoredOutput "✅ Azure CLI installed successfully: $azVersion" $Green
    }
    catch {
        Write-ColoredOutput "❌ Failed to install Azure CLI automatically" $Red
        Write-ColoredOutput "Please install manually from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows" $Yellow
        exit 1
    }
}

function Install-AdoCLI {
    Write-ColoredOutput "📥 Installing ado-flow..." $Blue
    
    # Create installation directories
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null
    New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
    
    # Check if installing from local repository
    if (Test-Path ".\global-integration\ado-integration.sh") {
        Write-ColoredOutput "📋 Installing from local repository..." $Blue
        
        # Copy main script and convert to PowerShell wrapper
        Copy-Item ".\global-integration\ado-integration.sh" "$InstallDir\ado-integration.sh"
        
        # Copy Claude Code integration files
        if (Test-Path ".\global-integration\ADO.md") {
            Copy-Item ".\global-integration\ADO.md" "$ConfigDir\" -ErrorAction SilentlyContinue
        }
        
        # Copy documentation
        if (Test-Path ".\docs") {
            Copy-Item ".\docs" "$InstallDir\" -Recurse -Force
        }
    }
    else {
        # Download from GitHub
        Write-ColoredOutput "🌐 Downloading from GitHub..." $Blue
        
        $tempDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }
        $zipPath = Join-Path $tempDir "repo.zip"
        
        try {
            Invoke-WebRequest -Uri "$RepoUrl/archive/main.zip" -OutFile $zipPath
            Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force
            
            $repoDir = Get-ChildItem -Path $tempDir -Directory | Select-Object -First 1
            
            Copy-Item "$($repoDir.FullName)\global-integration\ado-integration.sh" "$InstallDir\"
            
            if (Test-Path "$($repoDir.FullName)\global-integration\ADO.md") {
                Copy-Item "$($repoDir.FullName)\global-integration\ADO.md" "$ConfigDir\" -ErrorAction SilentlyContinue
            }
            
            if (Test-Path "$($repoDir.FullName)\docs") {
                Copy-Item "$($repoDir.FullName)\docs" "$InstallDir\" -Recurse -Force
            }
        }
        finally {
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    
    # Create Windows wrapper script
    Create-WindowsWrapper
    
    Write-ColoredOutput "✅ ado-flow installed successfully" $Green
}

function Create-WindowsWrapper {
    # Create batch file wrapper
    $batchScript = @"
@echo off
REM ADO CLI Integration Windows wrapper
bash "$InstallDir\ado-integration.sh" %*
"@
    
    $batchScript | Out-File -FilePath "$BinDir\ado.bat" -Encoding ASCII
    
    # Create PowerShell wrapper for better Windows integration
    $psScript = @"
# ADO CLI Integration PowerShell wrapper
param([Parameter(ValueFromRemainingArguments)][string[]]`$Arguments)

# Check if WSL/Git Bash is available
if (Get-Command bash -ErrorAction SilentlyContinue) {
    & bash "$InstallDir\ado-integration.sh" @Arguments
}
elseif (Get-Command wsl -ErrorAction SilentlyContinue) {
    `$scriptPath = `$InstallDir.Replace('\', '/').Replace('C:', '/mnt/c') + '/ado-integration.sh'
    & wsl bash `$scriptPath @Arguments
}
else {
    Write-Host "❌ Bash environment required. Please install Git for Windows or WSL." -ForegroundColor Red
    Write-Host "Git for Windows: https://git-scm.com/download/win"
    Write-Host "WSL: https://docs.microsoft.com/en-us/windows/wsl/install"
    exit 1
}
"@
    
    $psScript | Out-File -FilePath "$BinDir\ado.ps1" -Encoding UTF8
    
    # Add to PATH if not already there
    Add-ToPath $BinDir
}

function Add-ToPath {
    param([string]$Directory)
    
    $currentPath = if ($User) { 
        [Environment]::GetEnvironmentVariable("Path", "User") 
    } else { 
        [Environment]::GetEnvironmentVariable("Path", "Machine") 
    }
    
    if ($currentPath -notlike "*$Directory*") {
        Write-ColoredOutput "📝 Adding $Directory to PATH..." $Blue
        
        $newPath = if ($currentPath) { "$currentPath;$Directory" } else { $Directory }
        
        [Environment]::SetEnvironmentVariable("Path", $newPath, $(if ($User) { "User" } else { "Machine" }))
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        
        Write-ColoredOutput "✅ PATH updated" $Green
    }
}

function Create-ConfigTemplates {
    Write-ColoredOutput "📝 Creating configuration templates..." $Blue
    
    # Global config template
    $globalConfigTemplate = @"
# Global Azure DevOps Configuration Template
# Copy this file to ~/.claude/ado-config.env and customize

# Your Azure DevOps organization URL
AZURE_DEVOPS_ORG_URL=https://dev.azure.com/YourOrganization

# Default project name
AZURE_DEVOPS_PROJECT=YourProject

# Personal Access Token (create at: https://dev.azure.com/YourOrg/_usersSettings/tokens)
AZURE_DEVOPS_EXT_PAT=your_personal_access_token_here
"@
    
    $globalConfigTemplate | Out-File -FilePath "$ConfigDir\ado-config-template.env" -Encoding UTF8
    
    # Project config template
    $projectConfigTemplate = @"
# Project-specific Azure DevOps Configuration Template
# Copy this file to your project root as .env.azure-devops

# Project-specific Azure DevOps organization URL (if different from global)
AZURE_DEVOPS_ORG_URL=https://dev.azure.com/YourProjectOrganization

# Project name
AZURE_DEVOPS_PROJECT=YourSpecificProject

# Personal Access Token (if different from global)
AZURE_DEVOPS_EXT_PAT=your_project_specific_token_here
"@
    
    $projectConfigTemplate | Out-File -FilePath "$InstallDir\project-config-template.env" -Encoding UTF8
    
    Write-ColoredOutput "✅ Configuration templates created" $Green
}

function Show-CompletionMessage {
    Write-Host ""
    Write-ColoredOutput "🎉 Installation completed successfully!" $Green
    Write-Host ""
    
    Write-ColoredOutput "📋 Next steps:" $Blue
    Write-ColoredOutput "1. Open a new PowerShell/Command Prompt window" $Yellow
    Write-ColoredOutput "2. Set up your Azure DevOps connection:" $Yellow
    Write-ColoredOutput "   ado setup" $Blue
    Write-Host ""
    Write-ColoredOutput "3. Test the installation:" $Yellow
    Write-ColoredOutput "   ado --help" $Blue
    Write-Host ""
    Write-ColoredOutput "4. Start using ADO CLI:" $Yellow
    Write-ColoredOutput "   ado list    # List work items" $Blue
    Write-ColoredOutput "   ado my      # Show your assigned work items" $Blue
    Write-Host ""
    
    Write-ColoredOutput "📖 Documentation:" $Blue
    Write-ColoredOutput "   • Command reference: $InstallDir\docs\command-reference.md" $Blue
    Write-ColoredOutput "   • Troubleshooting: $InstallDir\docs\troubleshooting.md" $Blue
    Write-ColoredOutput "   • Examples: $InstallDir\docs\examples.md" $Blue
    Write-Host ""
    
    Write-ColoredOutput "🔧 Configuration files:" $Blue
    Write-ColoredOutput "   • Global config template: $ConfigDir\ado-config-template.env" $Blue
    Write-ColoredOutput "   • Project config template: $InstallDir\project-config-template.env" $Blue
    Write-Host ""
    
    Write-ColoredOutput "💡 Tips:" $Yellow
    Write-ColoredOutput "   • Use 'ado.ps1' for PowerShell integration" $Blue
    Write-ColoredOutput "   • Use 'ado.bat' for Command Prompt" $Blue
    Write-ColoredOutput "   • Requires Git Bash or WSL for bash script execution" $Blue
    Write-Host ""
    
    Write-ColoredOutput "🚀 Happy coding with Azure DevOps!" $Green
}

# Main installation function
function Start-Installation {
    Write-ColoredOutput "🚀 Azure DevOps CLI Integration Installer v$Version" $Blue
    Write-ColoredOutput "Repository: $RepoUrl" $Blue
    Write-Host ""
    
    # Check PowerShell version
    Test-PowerShellVersion
    
    # Check admin privileges for system-wide install
    if (-not $User -and -not (Test-AdminPrivileges)) {
        Write-ColoredOutput "❌ Administrator privileges required for system-wide installation" $Red
        Write-ColoredOutput "Run PowerShell as Administrator or use -User flag for user installation" $Yellow
        exit 1
    }
    
    # Check if already installed
    if (-not $Force -and (Test-Path "$InstallDir\ado-integration.sh")) {
        Write-ColoredOutput "⚠️  ADO CLI Integration is already installed" $Yellow
        Write-ColoredOutput "Use -Force to reinstall" $Blue
        exit 1
    }
    
    Install-Prerequisites
    Install-AdoCLI
    Create-ConfigTemplates
    Show-CompletionMessage
}

# Handle command line arguments
if ($Help) {
    Show-Help
    exit 0
}

# Start installation
try {
    Start-Installation
}
catch {
    Write-ColoredOutput "❌ Installation failed: $($_.Exception.Message)" $Red
    exit 1
}