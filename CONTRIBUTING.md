# Contributing to ado-flow

We welcome contributions from the community! This document provides guidelines for contributing to the project.

## 🚀 Getting Started

### Prerequisites

- Git
- Bash (for Unix/Linux/macOS) or PowerShell (for Windows)
- Azure CLI with DevOps extension
- Basic knowledge of shell scripting

### Setting Up Development Environment

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/abbeyseto/ado-flow.git
   cd ado-flow
   ```

2. **Install in development mode**
   
   **Unix/Linux/macOS:**
   ```bash
   ./INSTALL.sh
   ```
   
   **Windows (PowerShell as Administrator):**
   ```powershell
   .\install.ps1 -User
   ```

3. **Set up your test environment**
   ```bash
   # Configure with your test Azure DevOps organization
   ado setup
   ```

## 📝 How to Contribute

### Reporting Bugs

1. **Check existing issues** to avoid duplicates
2. **Use the bug report template** when creating new issues
3. **Include system information**:
   - OS and version
   - Shell type and version
   - Azure CLI version
   - Error messages with full stack trace

### Suggesting Enhancements

1. **Check existing feature requests** to avoid duplicates
2. **Use the feature request template**
3. **Explain the use case** and expected behavior
4. **Provide examples** of how the feature would be used

### Contributing Code

#### Types of Contributions We Welcome

- **Bug fixes** - Fix reported issues
- **New features** - Add new ADO CLI commands or functionality
- **Documentation** - Improve existing docs or add new guides
- **Cross-platform support** - Improve Windows/macOS/Linux compatibility
- **Test coverage** - Add or improve test scripts
- **Performance improvements** - Optimize existing functionality

#### Development Process

1. **Create a feature branch from dev**
   ```bash
   # Start from the dev branch (default branch)
   git checkout dev
   git pull origin dev
   
   # Create your feature branch
   git checkout -b feature/your-feature-name
   # or
   git checkout -b bugfix/issue-number-description
   ```

2. **Make your changes**
   - Follow existing code style and conventions
   - Add comments for complex logic
   - Update documentation if needed
   - Test your changes on multiple platforms if possible

3. **Test your changes**
   ```bash
   # Test installation
   ./INSTALL.sh  # or .\install.ps1 on Windows
   
   # Test core functionality
   ado setup
   ado --help
   ado list
   
   # Test your specific changes
   # Add any specific test commands for your feature
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "type: brief description of changes
   
   - Detailed explanation of what was changed
   - Why the change was necessary
   - Any breaking changes or migration notes
   
   Fixes #issue-number"
   ```

5. **Push and create a Pull Request to dev branch**
   ```bash
   git push origin feature/your-feature-name
   ```
   
   **Important**: All pull requests should be submitted against the `dev` branch, not `main`. 
   The `main` branch is protected and only the repository owner can merge to it.

#### Commit Message Convention

We follow conventional commit messages:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

Examples:
```
feat: add support for Epic work item creation

fix: handle special characters in work item titles

docs: update installation instructions for Windows 11

refactor: improve error handling in ado-integration.sh
```

#### Branching Strategy

We use a three-branch workflow:

- **`main`** - Production-ready code. Protected branch, only repository owner can merge.
- **`staging`** - Pre-production testing. Used for release preparation.
- **`dev`** - Active development. **Default branch for all pull requests.**

**Workflow:**
1. Contributors create feature branches from `dev`
2. Pull requests are submitted to `dev` branch
3. Repository owner merges `dev` → `staging` for testing
4. Repository owner merges `staging` → `main` for releases

**Branch Protection:**
- `main` branch requires pull requests and prevents direct pushes
- All CI checks must pass before merging
- Only the repository owner (@abbeyseto) can approve merges to `main`

#### Code Style Guidelines

**Shell Scripts (Bash):**
- Use 4-space indentation
- Include error handling with `set -e`
- Use descriptive variable names
- Add comments for complex logic
- Use color coding for user output
- Follow existing function naming patterns

**PowerShell Scripts:**
- Use PascalCase for function names
- Use approved verbs (Get-, Set-, New-, etc.)
- Include parameter validation
- Use Write-ColoredOutput for consistent formatting
- Handle errors gracefully

**Documentation:**
- Use clear, concise language
- Include code examples
- Update table of contents if needed
- Test all commands and examples

### Testing

#### Manual Testing Checklist

Before submitting a PR, test on your target platform(s):

**Installation Testing:**
- [ ] Fresh installation works
- [ ] Prerequisites are properly detected/installed
- [ ] Configuration templates are created
- [ ] Shell aliases/PATH updates work
- [ ] Uninstallation is clean (if applicable)

**Functionality Testing:**
- [ ] `ado setup` completes successfully
- [ ] `ado list` returns work items
- [ ] `ado my` shows assigned work items
- [ ] `ado create` creates work items with proper fields
- [ ] `ado start` creates branches and updates work items
- [ ] `ado complete` marks work items as resolved
- [ ] Git integration works correctly
- [ ] Error handling is appropriate

**Cross-Platform Testing:**
- [ ] Works on macOS (if you have access)
- [ ] Works on Linux (Ubuntu/Debian preferred)
- [ ] Works on Windows (PowerShell 5.1+)
- [ ] Works with different shell environments

#### Automated Testing (Future)

We're working on adding automated testing. Contributions to test infrastructure are welcome!

## 📚 Documentation

### Types of Documentation

1. **README.md** - Main project documentation
2. **docs/** - Detailed documentation
   - `command-reference.md` - Complete command documentation
   - `troubleshooting.md` - Common issues and solutions
   - `examples.md` - Usage examples
   - `integration-guide.md` - Advanced integration scenarios

### Documentation Standards

- Keep language clear and beginner-friendly
- Include working code examples
- Update relevant sections when adding features
- Test all commands before documenting them
- Include screenshots for UI-related features

## 🔍 Code Review Process

### What We Look For

1. **Functionality** - Does the code work as intended?
2. **Quality** - Is the code well-written and maintainable?
3. **Testing** - Has the code been tested adequately?
4. **Documentation** - Are changes properly documented?
5. **Compatibility** - Does it work across target platforms?

### Review Timeline

- **Initial response:** Within 3-5 days
- **Full review:** Within 1-2 weeks
- **Feedback incorporation:** Ongoing discussion

## 🏷️ Release Process

### Versioning

We use [Semantic Versioning](https://semver.org/):
- **MAJOR.MINOR.PATCH** (e.g., 1.2.3)
- **Major:** Breaking changes
- **Minor:** New features (backward compatible)
- **Patch:** Bug fixes

### Release Checklist

1. Update version numbers in scripts
2. Update CHANGELOG.md
3. Test on all supported platforms
4. Create GitHub release with release notes
5. Update installation URLs in README

## 🙋‍♂️ Getting Help

### Communication Channels

- **GitHub Issues** - Bug reports and feature requests
- **GitHub Discussions** - Questions and general discussion
- **Pull Request Comments** - Code review discussions

### Mentorship

New contributors are welcome! If you're new to:
- **Open source** - We'll help guide you through the process
- **Shell scripting** - We can provide code review and suggestions
- **Azure DevOps** - We can help explain the APIs and concepts

Don't hesitate to ask questions in issues or discussions.

## 🎯 Project Roadmap

### Current Focus Areas

1. **Cross-platform compatibility** - Better Windows support
2. **Error handling** - More robust error messages and recovery
3. **Testing** - Automated test suite
4. **Documentation** - Video tutorials and advanced guides
5. **Performance** - Faster operations and caching

### Future Features

- **Configuration management** - Multiple profile support
- **Bulk operations** - Batch work item updates
- **Custom fields** - Support for custom work item fields
- **Reporting** - Basic reporting and analytics
- **Integration** - Better IDE and editor integration

## 💡 Tips for Contributors

### Making Good PRs

1. **Keep PRs focused** - One feature/fix per PR
2. **Write clear descriptions** - Explain what and why
3. **Include tests** - Show that your code works
4. **Update docs** - Help others use your feature
5. **Be responsive** - Engage with review feedback

### Common Gotchas

1. **Path handling** - Windows vs. Unix path differences
2. **Line endings** - Use `.gitattributes` for consistency
3. **Environment variables** - Different shells handle them differently
4. **Dependencies** - Check availability before using
5. **Error messages** - Make them helpful and actionable

## 📄 License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.

## 🙏 Recognition

Contributors will be:
- Listed in the README.md Contributors section
- Mentioned in release notes for significant contributions
- Given credit in commit messages and PR descriptions

Thank you for helping make Azure DevOps CLI Integration better! 🚀