# Tmux Control Room - File Manifest

Complete listing of all files in the project with descriptions.

## Core Skill Files

| File | Purpose | Type |
|------|---------|------|
| `claude.json` | Claude Code skill manifest | JSON |
| `.gitignore` | Git ignore patterns | Config |

## Configuration Files (config/)

| File | Purpose | Type |
|------|---------|------|
| `config/setup.yaml` | Main configuration (repos, session, git, features) | YAML |
| `config/colors.yaml` | Color theme definitions (7 built-in themes) | YAML |
| `config/layouts.yaml` | Layout definitions (5 built-in layouts) | YAML |
| `config/defaults.yaml` | Default values and validation rules | YAML |
| `config/tmux.conf.additions` | Static tmux configuration additions | Config |
| `config/zshrc.additions` | Static zsh PATH additions | Config |

## Skill Commands (skills/)

| File | Purpose | Type |
|------|---------|------|
| `skills/install.sh` | Interactive installer with YAML config support, test mode, dry run | Bash |
| `skills/customize.sh` | Interactive customization menu tool with test mode support | Bash |

## Templates (templates/)

| File | Purpose | Type |
|------|---------|------|
| `templates/devstack.template` | Script generation template for devstack | Template |
| `templates/tmux.conf.template` | Tmux config generation template | Template |

## Binary Scripts (bin/)

| File | Purpose | Type |
|------|---------|------|
| `bin/devstack` | Main session startup script | Bash |
| `bin/tmux-send-to-children` | Helper for sending commands to child panes | Bash |

## Examples (examples/)

| File | Purpose | Type |
|------|---------|------|
| `examples/custom-config-example.yaml` | Example custom configuration | YAML |
| `examples/multi-project-example.yaml` | Multi-project setup example | YAML |

## Test & Sandbox Tools (test/)

| File | Purpose | Type |
|------|---------|------|
| `test/cleanup.sh` | Remove test installation without affecting production | Bash |
| `test/sandbox.sh` | Interactive test environment launcher | Bash |
| `test/compare-themes.sh` | Visual theme comparison and testing tool | Bash |

## Documentation (root)

| File | Purpose | Type |
|------|---------|------|
| `README.md` | Main documentation with full feature list | Markdown |
| `QUICKSTART.md` | Quick reference guide | Markdown |
| `TEST_MODE.md` | Complete guide to test mode and sandbox testing | Markdown |
| `SKILL_DOCUMENTATION.md` | Technical documentation for the skill | Markdown |
| `INSTALLATION_SUMMARY.md` | Summary of what was created in v2.0 | Markdown |
| `FILE_MANIFEST.md` | This file - complete file listing | Markdown |

## Documentation (docs/)

| File | Purpose | Type |
|------|---------|------|
| `docs/tmux-control-room-plan.md` | Original design document | Markdown |

## Scripts (root)

| File | Purpose | Type |
|------|---------|------|
| `install.sh` | Legacy installer (v1.0 compatible) | Bash |
| `test-installation.sh` | Installation validation script | Bash |

## File Statistics

- **Total files**: 26
- **Configuration files**: 4 YAML + 2 static configs
- **Skill scripts**: 2 (install, customize)
- **Templates**: 2 (devstack, tmux.conf)
- **Binary scripts**: 2 (devstack, tmux-send-to-children)
- **Examples**: 2 YAML configs
- **Documentation**: 7 markdown files
- **Test/Sandbox scripts**: 4 (cleanup, sandbox, compare-themes, test-installation)
- **Manifests**: 1 skill manifest + 1 gitignore

## File Purposes by Category

### Configuration Management
- YAML config files define all settings
- Templates generate scripts from config
- Static configs provide base functionality

### User Interface
- Interactive install script with prompts
- Interactive customize tool with menus
- Command-line tools for direct use

### Generated Outputs
- devstack script (startup)
- tmux.conf additions (styling)
- Installed to ~/bin/

### Documentation
- README for comprehensive info
- QUICKSTART for quick tasks
- SKILL_DOCUMENTATION for technical details
- INSTALLATION_SUMMARY for what's new

### Testing & Validation
- test-installation.sh validates setup
- Examples provide templates

### Backward Compatibility
- Legacy install.sh (v1.0)
- Original bin/devstack
- Static config additions

## Key File Relationships

```
config/setup.yaml ──┐
config/colors.yaml ──┼──> skills/install.sh ──> bin/devstack
config/layouts.yaml ─┤                       └─> ~/.tmux.conf
config/defaults.yaml ┘                       └─> ~/.zshrc

templates/devstack.template ──> processed ──> bin/devstack
templates/tmux.conf.template ──> processed ──> ~/.tmux.conf

skills/customize.sh ──> modifies ──> config/*.yaml
```

## Installation Targets

### Production Installation

| Source | Destination | Purpose |
|--------|-------------|---------|
| `bin/devstack` | `~/bin/devstack` | Session startup |
| `bin/tmux-send-to-children` | `~/bin/tmux-send-to-children` | Helper utility |
| `config/tmux.conf.additions` | `~/.tmux.conf` (appended) | Tmux styling |
| `config/zshrc.additions` | `~/.zshrc` (appended) | PATH setup |

### Test Mode Installation (--test flag)

| Source | Destination | Purpose |
|--------|-------------|---------|
| `bin/devstack` (modified) | `~/bin/test-devstack` | Test session startup |
| `bin/tmux-send-to-children` | `~/bin/tmux-send-to-children` | Helper utility |
| `config/tmux.conf.additions` | `~/.tmux-test.conf` | Test tmux config (separate) |
| Auto-generated | `~/bin/test-devstack-cleanup` | Test cleanup script |
| N/A | `~/.zshrc` (not modified) | PATH already configured |

## Files Generated During Install

- `bin/devstack.generated` (intermediate, copied to ~/bin)
- `config/tmux.conf.generated` (intermediate, appended to ~/.tmux.conf)
- `~/.tmux.conf.backup-[timestamp]` (backup of original)
- `~/.zshrc.backup-[timestamp]` (backup of original)

## Files NOT in Repository

These are user-specific and not tracked:

- `~/.tmux.conf` (user's tmux config, we append to it)
- `~/.zshrc` (user's zsh config, we append to it)
- `~/bin/devstack` (installed script)
- `~/bin/tmux-send-to-children` (installed script)
- `*.backup*` (backup files)
- `*.generated` (temporary generated files)

## Usage Examples by File

### config/setup.yaml
```bash
# Edit to change repositories
vim config/setup.yaml
./skills/install.sh
```

### config/colors.yaml
```bash
# Edit to change theme
vim config/colors.yaml  # set active_theme
./skills/install.sh
tmux source-file ~/.tmux.conf
```

### config/layouts.yaml
```bash
# Edit to change layout
vim config/layouts.yaml  # set active_layout
./skills/install.sh
```

### skills/install.sh
```bash
# Install with defaults
./skills/install.sh

# Install interactively
./skills/install.sh --interactive

# Install with custom config
./skills/install.sh --config=examples/custom-config-example.yaml

# Test mode (safe sandbox)
./skills/install.sh --test --interactive

# Dry run (preview only)
./skills/install.sh --dry-run
```

### skills/customize.sh
```bash
# Interactive customization
./skills/customize.sh
# Choose from menu: themes, layouts, repos, features

# Test mode customization
./skills/customize.sh --test
```

### test/cleanup.sh
```bash
# Remove test installation
./test/cleanup.sh
# Removes: test-devstack, ~/.tmux-test.conf, test session
```

### test/sandbox.sh
```bash
# Interactive test environment
./test/sandbox.sh
# Menu: start test, compare themes, cleanup
```

### test/compare-themes.sh
```bash
# Visual theme comparison
./test/compare-themes.sh
# View and apply themes interactively
```

### test-installation.sh
```bash
# Validate installation
./test-installation.sh
# Output: ✓ All tests passed!
```

### bin/devstack
```bash
# Start control room
devstack

# With Claude CLI
devstack --claude

# Named instance
devstack --instance=feature
```

## Version History

- **v2.0.0** (2026-02-04) - Claude Code skill release
  - Added all configuration, template, and skill files
  - Added interactive tools
  - Added comprehensive documentation
  
- **v1.0.0** (2026-02-04) - Initial release
  - bin/devstack
  - bin/tmux-send-to-children
  - install.sh
  - config additions

