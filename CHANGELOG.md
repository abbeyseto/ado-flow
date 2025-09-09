# Changelog

All notable changes to the ado-flow project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project structure and documentation
- Cross-platform installation scripts for Windows, macOS, and Linux
- Comprehensive README with installation instructions
- Contributing guidelines and license

### Changed
- N/A (initial release)

### Deprecated
- N/A (initial release)

### Removed
- N/A (initial release)

### Fixed
- N/A (initial release)

### Security
- N/A (initial release)

## [1.0.0] - 2024-01-XX

### Added

#### Core Features
- **Cross-platform ado-flow tool** - Streamlined Azure DevOps workflow automation on Windows, macOS, and Linux
- **Smart work item creation** - Automatically handles required fields for different work item types
  - Epic: Title and description
  - Feature: Auto-adds Target Date (30 days) and Acceptance Criteria template
  - User Story: Auto-adds Risk level, Acceptance Criteria, and Story Points
  - Task: Auto-adds work estimates and Activity type
- **Git workflow integration** - Automatic branch creation and work item state management
- **Flexible configuration** - Global and project-specific configuration support
- **Claude Code integration** - Enhanced AI-powered development workflow support

#### Installation & Setup
- **One-command installation** - Simple curl/PowerShell installation
- **Automatic dependency management** - Auto-installs Azure CLI and extensions
- **Cross-platform compatibility** - Native installers for each platform
- **Configuration templates** - Pre-configured templates for quick setup

#### Commands
- `ado setup` - Interactive Azure DevOps configuration
- `ado list` - List all work items
- `ado my` - Show assigned work items
- `ado search [query]` - Search work items by title/content
- `ado show [id]` - Display detailed work item information
- `ado create [type] [title] [description]` - Create work items with validation
- `ado update [id] [options]` - Update work item fields and status
- `ado comment [id] [text]` - Add comments to work items
- `ado start [id]` - Create feature branch and activate work item
- `ado complete [id]` - Mark work item as resolved and ready for review

#### Documentation
- **Comprehensive README** - Complete setup and usage guide
- **Command reference** - Detailed documentation for all commands
- **Troubleshooting guide** - Common issues and solutions
- **Examples** - Real-world usage scenarios
- **Integration guide** - Advanced integration patterns
- **Contributing guidelines** - How to contribute to the project

#### Configuration
- **Hierarchical configuration** - Project-level overrides global settings
- **Environment variable support** - Flexible configuration options
- **Secure credential storage** - Safe PAT token handling
- **Multiple project support** - Different configurations per project

### Technical Details

#### Platform Support
- **macOS** - Native bash integration with Homebrew support
- **Linux** - Universal installer supporting major distributions
- **Windows** - PowerShell and batch file wrappers with WSL/Git Bash support

#### Prerequisites Handling
- **Azure CLI** - Automatic installation and version checking
- **Azure DevOps Extension** - Automatic installation if missing
- **Git** - Version checking and integration setup
- **JSON parsing** - Platform-specific JSON handling (jq on Unix, native on Windows)

#### Security Features
- **Secure token storage** - PAT tokens stored with restricted permissions
- **No credential logging** - Tokens never appear in logs or console output
- **HTTPS-only communication** - All API calls use secure connections
- **Scope-limited permissions** - Minimal required permissions for tokens

### Infrastructure
- **GitHub repository** - Complete project hosting with issues and discussions
- **MIT License** - Open source license for community contributions
- **Semantic versioning** - Standard versioning scheme for releases
- **GitHub Actions** - Automated testing and release pipeline (planned)

### Known Issues
- Windows requires Git Bash or WSL for bash script execution
- Some Azure DevOps custom fields may not be supported initially
- Rate limiting not implemented for bulk operations

### Migration Notes
- This is the initial release, no migration required
- Configuration files use environment variable format
- Global configuration stored in `~/.claude/ado-config.env`
- Project-specific configuration in `.env.azure-devops`

---

## Release Notes Template

### [X.Y.Z] - YYYY-MM-DD

#### Added
- New features

#### Changed
- Changes in existing functionality

#### Deprecated
- Soon-to-be removed features

#### Removed
- Now removed features

#### Fixed
- Any bug fixes

#### Security
- In case of vulnerabilities