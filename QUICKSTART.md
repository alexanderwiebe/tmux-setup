# Tmux Control Room - Quick Start Guide

## Installation (30 seconds)

```bash
cd ~/dev/tmux-setup
./skills/install.sh
source ~/.zshrc
```

## Start Your Control Room

```bash
devstack                # Basic start
devstack --claude       # With Claude CLI
devstack --instance=feat # Named instance
```

## Customize

```bash
cd ~/dev/tmux-setup
./skills/customize.sh   # Interactive menu
```

Or edit directly:
- `config/setup.yaml` - Repositories and settings
- `config/colors.yaml` - Color themes
- `config/layouts.yaml` - Pane layouts

## Common Tasks

### Change Theme

```bash
# Edit config/colors.yaml
active_theme: ocean  # or: forest, fire, purple, monochrome, cyberpunk

# Regenerate
./skills/install.sh
tmux source-file ~/.tmux.conf
```

### Change Layout

```bash
# Edit config/layouts.yaml
active_layout: tiled  # or: main-vertical, even-horizontal, even-vertical

# Regenerate
./skills/install.sh
```

### Add Repository

Edit `config/setup.yaml`:

```yaml
children:
  - path: ~/dev/ai-document
    name: ai-document
    label: CHILD
  - path: ~/dev/new-project  # Add this
    name: new-project
    label: CHILD
```

Then regenerate: `./skills/install.sh`

### Send Commands to Children

```bash
tmux-send-to-children "git fetch gold && git pull gold/main"
```

## Available Themes

- `default` - Gold, blue, green, magenta
- `ocean` - Aquatic blues and cyans
- `forest` - Nature greens with gold
- `fire` - Warm reds, oranges, yellows
- `purple` - Royal purples and magentas
- `monochrome` - Grayscale
- `cyberpunk` - High-contrast neons

## Available Layouts

- `main-horizontal` - Large top, three bottom (default)
- `tiled` - 2x2 grid, equal panes
- `main-vertical` - Large left, three right
- `even-horizontal` - Four stacked
- `even-vertical` - Four side-by-side

## Key Bindings (in tmux)

- `Ctrl+b S` - Toggle synchronize-panes (send to all)
- `Ctrl+b q` - Show pane numbers
- `Ctrl+b o` - Cycle through panes
- `Ctrl+b ↑↓←→` - Navigate panes
- `Ctrl+b z` - Zoom/unzoom current pane
- `Ctrl+b d` - Detach (session keeps running)

## Troubleshooting

### Scripts not found
```bash
source ~/.zshrc
which devstack  # Should show ~/bin/devstack
```

### Config not taking effect
```bash
cd ~/dev/tmux-setup
./skills/install.sh  # Regenerate
tmux source-file ~/.tmux.conf  # Reload
```

### Kill all instances
```bash
tmux list-sessions | grep aj-stack | awk '{print $1}' | sed 's/://' | xargs -I {} tmux kill-session -t {}
```

## Files You Care About

- `config/setup.yaml` - Your repositories and settings
- `config/colors.yaml` - Your color theme
- `config/layouts.yaml` - Your layout preference
- `~/bin/devstack` - Generated script (don't edit, regenerate instead)
- `~/.tmux.conf` - Contains your tmux config

## Getting Help

```bash
./skills/install.sh --help
./skills/customize.sh  # Interactive menu
```

Read `README.md` for complete documentation.
