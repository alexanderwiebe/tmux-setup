# Tmux Control Room Setup

A Claude Code skill for creating customizable tmux-based "control rooms" optimized for running multiple Claude Code CLI instances across related repositories.

## 🚀 For New Users

**Want to use this skill?** See [INSTALL_FOR_USERS.md](INSTALL_FOR_USERS.md) for a complete step-by-step guide!

**Quick start:**
```bash
# 1. Clone this repository
git clone git@github.com:alexanderwiebe/tmux-setup.git ~/dev/tmux-setup

# 2. In Claude Code, type:
/tmux-setup

# 3. Follow Claude's interactive setup!
```

Claude will guide you through customizing:
- Number of panes (2-6)
- Directory paths for each pane
- Color themes (7 options)
- Layout preferences (5 options)
- Session naming
- And more!

---

## What's New in Version 2.0

This package is now a **Claude Code skill** with:

- **Interactive installation** with guided setup
- **YAML-based configuration** for easy customization
- **Multiple color themes** (default, ocean, forest, fire, purple, monochrome, cyberpunk)
- **Multiple layouts** (main-horizontal, tiled, main-vertical, even-horizontal, even-vertical)
- **Template-based script generation** for full control
- **Interactive customization tool** to modify settings
- **Test mode & sandbox** for safe experimentation (NEW!)
- **Dry run mode** to preview changes before installing (NEW!)
- **Theme comparison tool** to find your perfect colors (NEW!)
- **Backward compatibility** with existing installations

## What This Setup Does

This package provides a complete tmux environment for managing development workflows across multiple related repositories (one "ancestor" and three "children"). It creates a 4-pane layout with:

- **One large top pane** for the ancestor repository (`aj-starter-gold`)
- **Three equal bottom panes** for child repositories (`ai-document`, `svg-node-editor`, `tmux-dev`)
- **Clear visual pane identification** with custom borders and titles
- **One-command session startup** (`devstack`)
- **Helper utilities** for sending commands to specific panes

### Key Features

- **Color-coded pane borders** for instant visual identification:
  - 🟡 **Gold** border for `aj-starter-gold` (ancestor/ROOT)
  - 🔵 **Blue** border for `ai-document`
  - 🟢 **Green** border for `svg-node-editor`
  - 🟣 **Magenta** border for `tmux-dev`
- Pane titles showing repository hierarchy (ROOT/CHILD labels)
- Bold border styling for the active pane
- Custom status bar with session info and time
- Helper script to send commands to all child panes at once
- Optional auto-start of Claude CLI in all panes
- Git remote management (automatically adds `gold` remote to children)

### Use Case

This setup is ideal for workflows where:
1. You make changes in an ancestor repository
2. You need to pull those changes into multiple child repositories
3. You run similar commands (like Claude CLI) across all repositories
4. You need clear visual indicators of which pane contains which repository

## Prerequisites

- **tmux** - Install with `brew install tmux` (macOS) or your system's package manager
- **zsh** - Default shell on macOS
- **Git** - For repository management

Optional:
- **Claude CLI** - If you want to use the `--claude` auto-start flag

## Installation

### Using as a Claude Code Skill

This package can be used as a Claude Code skill. Simply tell Claude:

```
"Set up my tmux control room"
```

Claude will guide you through the installation and customization process.

### Quick Install (Direct)

```bash
cd ~/dev/tmux-setup
./skills/install.sh
```

### Interactive Install

For guided setup with customization prompts:

```bash
cd ~/dev/tmux-setup
./skills/install.sh --interactive
```

### Test Installation (Safe Sandbox)

**NEW!** Try out configurations without affecting your production setup:

```bash
# Install in test mode (uses separate files)
./skills/install.sh --test --interactive

# Start test session
test-devstack

# Or use the sandbox helper
./test/sandbox.sh

# Compare themes
./test/compare-themes.sh

# Clean up when done
./test/cleanup.sh
```

See [TEST_MODE.md](TEST_MODE.md) for complete testing guide.

### Dry Run (Preview Only)

Preview what would be installed without making any changes:

```bash
# Show what would be installed
./skills/install.sh --dry-run

# Preview with custom config
./skills/install.sh --dry-run --config=/path/to/my-config.yaml
```

### Custom Configuration

To use a custom configuration file:

```bash
cd ~/dev/tmux-setup
./skills/install.sh --config=/path/to/my-config.yaml
```

### What the Installer Does

1. Creates `~/bin/` directory if it doesn't exist
2. Copies `devstack` and `tmux-send-to-children` scripts to `~/bin/`
3. Makes scripts executable
4. Backs up `~/.tmux.conf` (if not already backed up) with timestamp
5. Appends tmux configuration to `~/.tmux.conf` (checks for duplicates)
6. Backs up `~/.zshrc` (if not already backed up) with timestamp
7. Appends PATH configuration to `~/.zshrc` (checks for duplicates)
8. Provides clear feedback about what was done

### Post-Installation

After running the installer, you need to:

1. **Update your current shell's PATH:**
   ```bash
   source ~/.zshrc
   ```

2. **If you're in a tmux session, reload the config:**
   ```bash
   tmux source-file ~/.tmux.conf
   ```

3. **Verify installation:**
   ```bash
   which devstack
   # Should output: /Users/[username]/bin/devstack
   ```

## Usage

### Starting the Control Room

**Basic usage (no auto-start):**
```bash
devstack
```

**With Claude CLI auto-start:**
```bash
devstack --claude
```

**Named instances (for multiple parallel sessions):**
```bash
devstack --instance=feature        # Creates session: aj-stack-feature
devstack --instance=bugfix         # Creates session: aj-stack-bugfix
devstack --instance=experiment     # Creates session: aj-stack-experiment
```

**Combine flags:**
```bash
devstack --instance=feature --claude    # Named instance + auto-start Claude
```

This creates a tmux session (default name: `aj-stack`) with 4 panes:

```
┌─────────────────────────────────────┐
│                                     │
│  Pane 0: ROOT: aj-starter-gold      │
│                                     │
├───────────┬───────────┬─────────────┤
│ Pane 1    │ Pane 2    │ Pane 3      │
│ CHILD:    │ CHILD:    │ CHILD:      │
│ ai-doc    │ svg-edit  │ tmux-dev    │
└───────────┴───────────┴─────────────┘
```

### Managing Multiple Instances

**List all running devstack sessions:**
```bash
tmux list-sessions | grep aj-stack
```

**Switch between instances (from outside tmux):**
```bash
tmux attach-session -t aj-stack-feature
tmux attach-session -t aj-stack-bugfix
```

**Switch between instances (from inside tmux):**
```bash
# Detach from current session
prefix + d

# Then attach to another
devstack --instance=feature
```

**Kill a specific instance:**
```bash
tmux kill-session -t aj-stack-feature
```

**Kill all devstack instances:**
```bash
tmux list-sessions | grep aj-stack | awk '{print $1}' | sed 's/://' | xargs -I {} tmux kill-session -t {}
```

### Sending Commands to Child Panes

**Send a command to all three child panes (excludes ancestor):**
```bash
tmux-send-to-children "git fetch gold && git pull gold/main"
```

The script is **instance-aware**:
- If run **inside a tmux session**, it automatically targets the current session
- If run **outside tmux**, it defaults to `aj-stack`
- Works seamlessly with named instances when you're inside the session

**Common workflow:**
```bash
# From within the control room session:
# 1. Make changes in ancestor pane (pane 0)
# 2. Commit and push changes
# 3. Send update command to all children:
tmux-send-to-children "git fetch gold && git pull gold/main"
```

### Tmux Keybindings

The configuration adds these keybindings (prefix = `Ctrl+b` by default):

- **`prefix + S`** - Toggle synchronize-panes (send to ALL panes including ancestor)
- **`prefix + q`** - Show pane numbers
- **`prefix + o`** - Cycle through panes
- **`prefix + ↑↓←→`** - Navigate to pane in direction
- **`prefix + z`** - Zoom/unzoom current pane
- **`prefix + d`** - Detach from session (keeps running)

### Managing Sessions

**Attach to existing session:**
```bash
devstack
# Will attach if session already exists
```

**Kill the session:**
```bash
tmux kill-session -t aj-stack
```

**List all tmux sessions:**
```bash
tmux ls
```

## Configuration

### Directory Structure

```
~/dev/tmux-setup/
├── claude.json                      # Claude Code skill manifest
├── README.md                        # This file
├── config/
│   ├── setup.yaml                   # User-editable configuration
│   ├── colors.yaml                  # Color scheme definitions
│   ├── layouts.yaml                 # Layout templates
│   ├── defaults.yaml                # Default settings
│   ├── tmux.conf.additions          # Tmux configuration additions
│   └── zshrc.additions              # Zsh PATH additions
├── skills/
│   ├── install.sh                   # Interactive install script
│   └── customize.sh                 # Customization helper
├── bin/
│   ├── devstack                     # Main session startup script
│   └── tmux-send-to-children        # Helper for command distribution
├── templates/
│   ├── devstack.template            # Script template
│   └── tmux.conf.template           # Tmux config template
└── docs/
    └── tmux-control-room-plan.md    # Detailed design document
```

### Configuration Files

#### `config/setup.yaml`

Main configuration file defining your repositories, session settings, and features:

```yaml
repos:
  ancestor:
    path: ~/dev/aj-starter-gold
    name: aj-starter-gold
    label: ROOT

  children:
    - path: ~/dev/ai-document
      name: ai-document
      label: CHILD

session:
  name: aj-stack
  window: stack

git:
  remote_name: gold
  remote_url: https://github.com/alexanderwiebe/aj-starter-gold.git

features:
  auto_start_claude: false
  colored_borders: true
  check_git_remotes: true
```

#### `config/colors.yaml`

Define color themes for your control room:

```yaml
themes:
  default:
    pane_0: colour220  # Gold
    pane_1: colour33   # Blue
    pane_2: colour34   # Green
    pane_3: colour201  # Magenta

  ocean:
    pane_0: colour39   # Cyan
    pane_1: colour33   # Blue
    pane_2: colour27   # Deep blue
    pane_3: colour21   # Navy

active_theme: default
```

Available themes:
- `default` - Gold, blue, green, magenta (original)
- `ocean` - Aquatic blues and cyans
- `forest` - Nature greens with gold
- `fire` - Warm reds, oranges, yellows
- `purple` - Royal purples and magentas
- `monochrome` - Grayscale for focus
- `cyberpunk` - High-contrast neons

#### `config/layouts.yaml`

Define pane arrangements:

```yaml
layouts:
  main-horizontal:
    description: "Large top pane, three equal bottom panes"
    tmux_layout: main-horizontal

  tiled:
    description: "Four equal panes in 2x2 grid"
    tmux_layout: tiled

active_layout: main-horizontal
```

Available layouts:
- `main-horizontal` - Large top pane for ancestor
- `tiled` - 2x2 grid, equal panes
- `main-vertical` - Large left pane for ancestor
- `even-horizontal` - Four stacked horizontal panes
- `even-vertical` - Four side-by-side vertical panes

### Tmux Configuration Additions

The installation adds these settings to your `~/.tmux.conf`:

- **Pane borders:** Top position with custom formatting
  - Active panes: Bold cyan border
  - Inactive panes: Dim gray border
  - Shows: pane index, title, current path

- **Status bar:** Bottom position with session and time info
  - Left: Session name
  - Right: Time and pane coordinates

- **Keybindings:** Toggle for synchronize-panes mode

### Zsh Configuration Additions

Adds `~/bin` to your PATH:
```bash
export PATH="$HOME/bin:$PATH"
```

## Customization

### Interactive Customization Tool

Use the interactive customization helper to modify your configuration:

```bash
cd ~/dev/tmux-setup
./skills/customize.sh
```

This provides a menu-driven interface to:
- Change color themes
- Switch layouts
- Manage repositories
- Toggle features
- View current configuration
- Create custom themes

### Manual Configuration Editing

#### Changing Repository Paths

Edit `config/setup.yaml`:

```yaml
repos:
  ancestor:
    path: ~/dev/your-ancestor
    name: your-ancestor
    label: ROOT

  children:
    - path: ~/dev/child-1
      name: child-1
      label: CHILD
```

Then run `./skills/install.sh` to regenerate scripts.

#### Changing Color Theme

**Option 1: Use the theme comparison tool (recommended)**

```bash
# Compare themes visually
./test/compare-themes.sh

# Or test safely first
./skills/install.sh --test
test-devstack
./test/compare-themes.sh
```

**Option 2: Edit directly**

Edit `config/colors.yaml` to set `active_theme`:

```yaml
active_theme: ocean  # or forest, fire, purple, monochrome, cyberpunk
```

Or create your own theme:

```yaml
themes:
  mytheme:
    name: "My Theme"
    description: "Custom colors"
    pane_0: colour226  # Yellow
    pane_1: colour39   # Cyan
    pane_2: colour46   # Green
    pane_3: colour201  # Magenta
    active_border: brightcyan
    inactive_border: colour240
    status_bg: colour234
    status_fg: colour255

active_theme: mytheme
```

#### Changing Layout

Edit `config/layouts.yaml` to set `active_layout`:

```yaml
active_layout: tiled  # or main-vertical, even-horizontal, even-vertical
```

#### Toggle Features

Edit `config/setup.yaml`:

```yaml
features:
  auto_start_claude: true      # Auto-start Claude CLI
  colored_borders: true        # Use colored borders
  colored_title_bars: true     # Colored title bars
  check_git_remotes: true      # Check git remotes
  show_paths: true             # Show paths in borders
  enable_sync_panes: true      # Sync-panes keybinding
```

### Applying Changes

After editing configuration files, regenerate and reinstall:

```bash
cd ~/dev/tmux-setup
./skills/install.sh
```

Then reload tmux configuration:

```bash
tmux source-file ~/.tmux.conf
```

### Testing Changes Safely

**NEW!** Test changes before applying to production:

```bash
# 1. Make configuration changes
./skills/customize.sh --test

# 2. Install in test mode
./skills/install.sh --test

# 3. Start test session
test-devstack

# 4. If you like it, apply to production
./skills/install.sh

# 5. Clean up test installation
./test/cleanup.sh
```

See [TEST_MODE.md](TEST_MODE.md) for complete guide.

### Template Customization

For advanced users, you can modify the templates directly:

- `templates/devstack.template` - Script generation template
- `templates/tmux.conf.template` - Tmux config template

Templates use `{{VARIABLE}}` syntax for substitution.

## Uninstall Instructions

### Manual Uninstall

1. **Remove scripts:**
   ```bash
   rm ~/bin/devstack
   rm ~/bin/tmux-send-to-children
   ```

2. **Remove tmux additions:**
   - Open `~/.tmux.conf`
   - Remove the section marked with "Tmux Control Room Setup"
   - Or restore from backup: `cp ~/.tmux.conf.backup-[timestamp] ~/.tmux.conf`

3. **Remove zsh additions:**
   - Open `~/.zshrc`
   - Remove the section marked with "Tmux Control Room Setup"
   - Or restore from backup: `cp ~/.zshrc.backup-[timestamp] ~/.zshrc`

4. **Reload configurations:**
   ```bash
   source ~/.zshrc
   tmux source-file ~/.tmux.conf  # if in tmux
   ```

### Restoring from Backups

The installer creates timestamped backups:

```bash
# List available backups
ls -la ~/.tmux.conf.backup-*
ls -la ~/.zshrc.backup-*

# Restore from backup (replace [timestamp] with actual timestamp)
cp ~/.tmux.conf.backup-[timestamp] ~/.tmux.conf
cp ~/.zshrc.backup-[timestamp] ~/.zshrc
```

## Troubleshooting

### Scripts not found after installation

**Problem:** `devstack: command not found`

**Solution:**
```bash
# Ensure ~/bin is in PATH for current shell
source ~/.zshrc

# Verify PATH
echo $PATH | grep "$HOME/bin"

# Verify script exists and is executable
ls -la ~/bin/devstack
```

### Tmux config not taking effect

**Problem:** Pane borders don't show up or colors are wrong

**Solution:**
```bash
# Reload tmux config
tmux source-file ~/.tmux.conf

# Or restart tmux entirely
# Exit all tmux sessions, then start fresh
```

### Session already exists error

**Problem:** `devstack` doesn't attach to existing session

**Solution:**
```bash
# The script should handle this, but you can manually attach:
tmux attach-session -t aj-stack

# Or kill and recreate:
tmux kill-session -t aj-stack
devstack
```

### Pane titles not showing

**Problem:** Can't see repository names in pane borders

**Solution:**
1. Check that `pane-border-status` is set:
   ```bash
   tmux show-options -g | grep pane-border-status
   # Should show: pane-border-status top
   ```

2. Ensure terminal supports it (iTerm2, modern terminal required)

3. Try reloading config:
   ```bash
   tmux source-file ~/.tmux.conf
   ```

### Colors look wrong

**Problem:** Colors are dim or not showing correctly

**Solution:**
```bash
# Check TERM variable inside tmux
echo $TERM
# Should show: screen-256color or tmux-256color

# If not, add to ~/.tmux.conf:
set -g default-terminal "screen-256color"

# Then reload:
tmux source-file ~/.tmux.conf
```

## Using as a Claude Code Skill

### Skill Manifest

This package includes a `claude.json` skill manifest that makes it discoverable by Claude Code.

### Skill Capabilities

When used as a Claude Code skill, you can ask Claude to:

- "Install my tmux control room"
- "Customize my devstack colors"
- "Change my tmux layout to ocean theme"
- "Add a new repository to my control room"
- "Show me my tmux control room configuration"

### Skill Commands

The skill provides these commands:

```bash
tmux-setup install [--interactive] [--config=PATH]
tmux-setup customize [theme|layout|repos|features]
```

### Integration Examples

**Example 1: Initial Setup**
```
User: Set up my tmux control room with the ocean theme

Claude: I'll install the tmux control room with the ocean theme...
[Runs install.sh with theme configuration]
```

**Example 2: Customization**
```
User: Change my control room to use the tiled layout

Claude: I'll update your layout configuration...
[Updates config/layouts.yaml and reruns install]
```

**Example 3: Adding Repositories**
```
User: Add ~/dev/new-project as a child repository

Claude: I'll add that repository to your configuration...
[Updates config/setup.yaml and regenerates scripts]
```

### Configuration as Code

All configuration is stored in YAML files, making it:
- Version controllable
- Easy to backup
- Shareable across machines
- Documented and readable

## Advanced Usage

### Using with tmuxinator

If you prefer declarative configuration, you can convert this setup to tmuxinator:

```yaml
# ~/.tmuxinator/aj-stack.yml
name: aj-stack
root: ~/dev/aj-starter-gold

windows:
  - stack:
      layout: main-horizontal
      panes:
        - # ancestor (pane 0)
        - cd ~/dev/ai-document  # child 1
        - cd ~/dev/svg-node-editor  # child 2
        - cd ~/dev/tmux-dev  # child 3
```

### Custom Layout String

If the default `main-horizontal` layout doesn't suit your needs:

1. Manually arrange panes to your liking
2. Capture the layout: `tmux list-windows -F "#{window_layout}"`
3. Edit `devstack` and replace the `tmux select-layout` line with:
   ```bash
   tmux select-layout -t "$SESSION:$WINDOW" "CAPTURED_LAYOUT_STRING"
   ```

### Adding More Panes

To add a fourth child repository:

1. Edit `~/bin/devstack`:
   ```bash
   CHILDREN=(
     "$HOME/dev/ai-document"
     "$HOME/dev/svg-node-editor"
     "$HOME/dev/tmux-dev"
     "$HOME/dev/new-repo"  # Add new repo
   )
   ```

2. Add split command after existing splits:
   ```bash
   tmux split-window -v -t "$SESSION:$WINDOW.3" -c "${CHILDREN[3]}"
   ```

3. Set pane title:
   ```bash
   tmux select-pane -t "$SESSION:$WINDOW.4" -T "CHILD: new-repo"
   ```

4. Update `~/bin/tmux-send-to-children` to include pane 4:
   ```bash
   for pane in 1 2 3 4; do
   ```

## Resources

- [Tmux Manual](https://man.openbsd.org/tmux)
- [Tmux Cheat Sheet](https://tmuxcheatsheet.com/)
- [Claude CLI Documentation](https://docs.anthropic.com/claude/docs/claude-cli)

## License

This is a personal configuration setup. Feel free to use and modify as needed.

## Contributing

This is a personal tool, but if you have suggestions:
1. Document your changes
2. Test thoroughly
3. Update this README

## Version History

- **2.0.0** (2026-02-04) - Claude Code Skill Release
  - Converted to Claude Code skill with claude.json manifest
  - YAML-based configuration system (setup.yaml, colors.yaml, layouts.yaml)
  - Interactive installation with `--interactive` flag
  - Template-based script generation
  - Interactive customization tool (customize.sh)
  - 7 pre-defined color themes
  - 5 layout options
  - Backward compatibility with 1.0.0

- **1.0.0** (2026-02-04) - Initial release
  - Core devstack script
  - tmux-send-to-children helper
  - Automated installation script
  - Comprehensive documentation

## Migration from 1.0.0 to 2.0.0

If you have an existing 1.0.0 installation:

1. Your existing `~/bin/devstack` and `~/.tmux.conf` will continue to work
2. Configuration files are now in `config/setup.yaml` (edit these instead of scripts)
3. Run `./skills/install.sh` to regenerate scripts from your configuration
4. Use `./skills/customize.sh` for interactive customization
5. All backups are preserved (`.backup-[timestamp]` files)
