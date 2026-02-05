# Tmux Control Room - Claude Code Skill Documentation

## Overview

This is a Claude Code skill that provides interactive installation and customization of tmux-based development control rooms.

## Skill Architecture

### Manifest (`claude.json`)

Defines the skill metadata, capabilities, and invocation methods for Claude Code integration.

### Configuration System

Four YAML files provide complete customization:

1. **setup.yaml** - Repository paths, session settings, git config, feature flags
2. **colors.yaml** - Color theme definitions (7 built-in themes + custom)
3. **layouts.yaml** - Pane layout configurations (5 built-in layouts)
4. **defaults.yaml** - Fallback values and validation rules

### Template System

Two templates enable dynamic script generation:

1. **devstack.template** - Generates the main session startup script
2. **tmux.conf.template** - Generates tmux configuration additions

Templates use `{{VARIABLE}}` syntax for substitution during installation.

### Skill Commands

Two main skill commands:

1. **install.sh** - Interactive installer with YAML-based configuration
   - Reads config files
   - Generates scripts from templates
   - Installs to ~/bin
   - Updates ~/.tmux.conf and ~/.zshrc
   - Creates backups

2. **customize.sh** - Interactive customization helper
   - Change themes
   - Switch layouts
   - Manage repositories
   - Toggle features
   - Create custom themes

## File Structure

```
~/dev/tmux-setup/
├── claude.json                      # Skill manifest
├── README.md                        # Main documentation
├── QUICKSTART.md                    # Quick reference guide
├── SKILL_DOCUMENTATION.md           # This file
├── test-installation.sh             # Validation script
├── install.sh                       # Legacy installer (v1.0)
│
├── config/                          # Configuration files
│   ├── setup.yaml                   # Main configuration
│   ├── colors.yaml                  # Color themes
│   ├── layouts.yaml                 # Layout definitions
│   ├── defaults.yaml                # Default values
│   ├── tmux.conf.additions          # Static tmux config
│   └── zshrc.additions              # Static zsh config
│
├── skills/                          # Skill commands
│   ├── install.sh                   # Interactive installer
│   └── customize.sh                 # Customization helper
│
├── templates/                       # Script templates
│   ├── devstack.template            # Session startup template
│   └── tmux.conf.template           # Tmux config template
│
├── bin/                             # Generated scripts
│   ├── devstack                     # Session startup script
│   └── tmux-send-to-children        # Helper utility
│
├── examples/                        # Example configurations
│   ├── custom-config-example.yaml   # Basic custom config
│   └── multi-project-example.yaml   # Multi-project setup
│
└── docs/                            # Additional documentation
    └── tmux-control-room-plan.md    # Original design doc
```

## How It Works

### Installation Flow

1. User runs `./skills/install.sh [--interactive] [--config=PATH]`
2. Script loads configuration from YAML files
3. Templates are processed with variable substitution
4. Generated scripts are copied to ~/bin
5. ~/.tmux.conf and ~/.zshrc are updated (with backups)
6. User sources ~/.zshrc and starts using devstack

### Configuration Flow

1. User edits config/*.yaml files OR runs `./skills/customize.sh`
2. Changes are saved to YAML files
3. User reruns `./skills/install.sh` to regenerate scripts
4. New scripts replace old ones in ~/bin
5. User reloads tmux config: `tmux source-file ~/.tmux.conf`

### Template Processing

Templates contain placeholder variables like:
- `{{SESSION_NAME}}` - Session name from setup.yaml
- `{{WINDOW_NAME}}` - Window name from setup.yaml
- `{{ANCESTOR_PATH}}` - Ancestor repo path
- `{{THEME_NAME}}` - Active theme name
- `{{LAYOUT_NAME}}` - Active layout name
- `{{PANE_0_CONFIG}}` - Generated pane 0 configuration
- etc.

The installer reads values from YAML and substitutes them into templates.

## Usage Patterns

### As a Claude Code Skill

Users can ask Claude:
- "Set up my tmux control room"
- "Change my devstack theme to ocean"
- "Add a new repository to my control room"
- "Show me my tmux configuration"

Claude will:
1. Read the relevant config files
2. Modify them as requested
3. Run the installer to apply changes
4. Provide feedback on what changed

### Direct Command Line

```bash
# Install
cd ~/dev/tmux-setup
./skills/install.sh --interactive

# Customize
./skills/customize.sh

# Test
./test-installation.sh

# Use
devstack
devstack --claude
devstack --instance=feature
```

## Customization Points

### Themes

7 built-in themes in colors.yaml:
- default (gold/blue/green/magenta)
- ocean (blues and cyans)
- forest (greens with gold)
- fire (reds/oranges/yellows)
- purple (purples and magentas)
- monochrome (grayscale)
- cyberpunk (neon colors)

Users can create custom themes by adding to colors.yaml.

### Layouts

5 built-in layouts in layouts.yaml:
- main-horizontal (large top pane)
- tiled (2x2 grid)
- main-vertical (large left pane)
- even-horizontal (four stacked)
- even-vertical (four side-by-side)

### Features

Toggle-able features in setup.yaml:
- auto_start_claude - Start Claude CLI automatically
- colored_borders - Use colored pane borders
- colored_title_bars - Colored title bars
- check_git_remotes - Auto-add git remotes
- show_paths - Show paths in borders
- enable_sync_panes - Sync-panes keybinding

### Repositories

Configure in setup.yaml:
- One ancestor repository (parent/shared)
- Multiple child repositories (dependents)
- Custom labels (ROOT, CHILD, or custom)

## Backward Compatibility

Version 2.0 maintains backward compatibility with 1.0:
- Existing ~/bin/devstack continues to work
- Existing ~/.tmux.conf additions remain valid
- New config files provide additional control
- Legacy install.sh still works (v1.0 style)

## Testing

Run `./test-installation.sh` to validate:
- Directory structure
- Configuration files
- Skill scripts
- Templates
- Required tools
- Installation status

## Extension Points

### Adding New Themes

Edit `config/colors.yaml`:

```yaml
themes:
  mytheme:
    name: "My Theme"
    description: "Custom colors"
    pane_0: colour226
    pane_1: colour39
    pane_2: colour46
    pane_3: colour201
    active_border: brightcyan
    inactive_border: colour240
    status_bg: colour234
    status_fg: colour255
```

### Adding New Layouts

Edit `config/layouts.yaml`:

```yaml
layouts:
  mylayout:
    name: "My Layout"
    description: "Custom arrangement"
    tmux_layout: tiled  # or custom layout string
    pane_arrangement: |
      [ASCII art showing layout]
```

### Adding New Features

1. Add feature flag to `config/setup.yaml`
2. Modify templates to use the feature
3. Update installer to process the feature
4. Document in README.md

### Custom Configuration Files

Create custom YAML files and use:

```bash
./skills/install.sh --config=my-custom-setup.yaml
```

## Integration with Claude Code

The skill integrates with Claude Code via:

1. **Manifest detection** - claude.json makes it discoverable
2. **Natural language** - Users can describe what they want
3. **File operations** - Claude reads/writes config files
4. **Command execution** - Claude runs install/customize scripts
5. **Feedback** - Claude explains what changed

Example interaction:

```
User: Change my tmux control room to use the ocean theme

Claude: I'll update your theme configuration...
[Reads config/colors.yaml]
[Updates active_theme: ocean]
[Runs ./skills/install.sh]
[Confirms changes applied]

Done! Your control room now uses the ocean theme (aquatic blues 
and cyans). Run `devstack` to see the new colors.
```

## Maintenance

### Updating Templates

When updating templates:
1. Edit templates/*.template
2. Update variable documentation
3. Test with various configurations
4. Update SKILL_DOCUMENTATION.md

### Adding Configuration Options

When adding new config options:
1. Add to appropriate YAML file
2. Add default to defaults.yaml
3. Update template processing in install.sh
4. Document in README.md and QUICKSTART.md

### Version Management

Semantic versioning in claude.json:
- Major: Breaking changes to config format
- Minor: New features, themes, layouts
- Patch: Bug fixes, documentation updates

## Known Limitations

1. YAML parsing is simplified (not full YAML spec)
2. Template system is basic (no conditionals/loops)
3. Only supports 4 panes (ancestor + 3 children)
4. macOS/zsh focused (bash support possible)
5. Requires manual tmux config reload

## Future Enhancements

Potential improvements:
- Full YAML parser (yq integration)
- Advanced template engine (jinja2/mustache)
- Support for N panes (configurable)
- Auto-reload tmux config
- Theme preview command
- Layout preview command
- Git integration helpers
- Session management UI
- Config validation CLI
- Migration tools

