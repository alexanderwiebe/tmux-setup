# Using Multiple Configurations

With the `--config` flag, you can maintain multiple tmux control room setups on the same machine without reinstalling!

## Use Case

You might want different tmux setups for:
- **Work projects** vs **personal projects**
- **Client A** vs **Client B**
- **Frontend work** vs **Backend work**
- **Different teams** or **different repositories**

Instead of reinstalling each time, just use different config files!

## How It Works

1. **One-time setup**: Install tmux-setup once
   ```bash
   cd ~/dev/tmux-setup
   ./setup-wizard.sh
   ```

2. **Create alternate configs**: Copy and modify config files
   ```bash
   # Create a directory for your configs
   mkdir -p ~/configs/tmux

   # Copy the example
   cp ~/dev/tmux-setup/examples/alternate-project.yaml ~/configs/tmux/work.yaml

   # Edit it for your work projects
   vim ~/configs/tmux/work.yaml
   ```

3. **Use different configs**: Run devstack with --config flag
   ```bash
   devstack --config=~/configs/tmux/work.yaml
   devstack --config=~/configs/tmux/personal.yaml
   devstack --config=~/configs/tmux/client-a.yaml
   ```

## Quick Example

```bash
# Work projects
devstack --config=~/configs/work.yaml

# Creates session with:
# - Pane 0: ~/work/main-project
# - Pane 1: ~/work/frontend
# - Pane 2: ~/work/backend
# - Pane 3: ~/work/docs

# Personal projects
devstack --config=~/configs/personal.yaml --instance=side-project

# Creates session with:
# - Pane 0: ~/personal/my-app
# - Pane 1: ~/personal/side-project-1
# - Pane 2: ~/personal/side-project-2
# - Pane 3: ~/personal/experiments
```

## Creating Your Config Files

### Method 1: Copy Example
```bash
cp ~/dev/tmux-setup/examples/alternate-project.yaml ~/configs/my-project.yaml
vim ~/configs/my-project.yaml
```

### Method 2: Copy Your Current Config
```bash
cp ~/dev/tmux-setup/config/setup.yaml ~/configs/another-project.yaml
vim ~/configs/another-project.yaml
```

### Method 3: Use the Wizard (Creates config but doesn't install)
```bash
cd ~/dev/tmux-setup
./setup-wizard.sh
# Answer questions
# When asked "Install now?", say "n"
# Copy the generated config: cp config/setup.yaml ~/configs/my-new-project.yaml
```

## Config File Format

Your config file should follow this structure:

```yaml
repos:
  ancestor:
    path: ~/path/to/main-project
    name: main-project
    label: ROOT

  children:
    - path: ~/path/to/child-1
      name: child-1
      label: CHILD

    - path: ~/path/to/child-2
      name: child-2
      label: CHILD

    - path: ~/path/to/child-3
      name: child-3
      label: CHILD

session:
  name: my-custom-stack
  window: stack

git:
  remote_name: origin
  remote_url: https://github.com/user/repo.git

features:
  auto_start_claude: false
  colored_borders: true
  colored_title_bars: true
  check_git_remotes: true
  show_paths: true
  enable_sync_panes: true
```

### Key Fields

**repos.ancestor.path**: Main/root project directory
**repos.children[].path**: Supporting project directories (3 required)
**session.name**: Session name for this config (e.g., "work-stack", "personal-stack")

The session name from the config will be used as the base name. You can still use `--instance=NAME` to create multiple instances.

## Combining Flags

You can combine `--config` with other flags:

```bash
# Use alternate config + Claude CLI
devstack --config=~/configs/work.yaml --claude

# Use alternate config + named instance
devstack --config=~/configs/client-a.yaml --instance=feature-123

# All flags together
devstack --config=~/configs/personal.yaml --instance=experiment --claude
```

## Practical Workflows

### Work vs Personal
```bash
# Create work config
cat > ~/configs/work.yaml << 'EOF'
repos:
  ancestor:
    path: ~/work/company-main
    name: company-main
    label: ROOT
  children:
    - {path: ~/work/frontend, name: frontend, label: CHILD}
    - {path: ~/work/backend, name: backend, label: CHILD}
    - {path: ~/work/infra, name: infra, label: CHILD}
session:
  name: work
  window: stack
EOF

# Create personal config
cat > ~/configs/personal.yaml << 'EOF'
repos:
  ancestor:
    path: ~/personal/main-app
    name: main-app
    label: ROOT
  children:
    - {path: ~/personal/hobby-1, name: hobby-1, label: CHILD}
    - {path: ~/personal/hobby-2, name: hobby-2, label: CHILD}
    - {path: ~/personal/learning, name: learning, label: CHILD}
session:
  name: personal
  window: stack
EOF

# Easy switching
devstack --config=~/configs/work.yaml      # Session: work
devstack --config=~/configs/personal.yaml  # Session: personal
```

### Multiple Clients
```bash
# Client A
devstack --config=~/configs/client-a.yaml --instance=feature-x
# Session: client-a-stack-feature-x

# Client B
devstack --config=~/configs/client-b.yaml --instance=feature-y
# Session: client-b-stack-feature-y

# List all sessions
tmux ls
```

### Feature Branches
```bash
# Main development
devstack --config=~/configs/project.yaml

# Feature branch in same repos
devstack --config=~/configs/project.yaml --instance=feature-123

# Bug fix in same repos
devstack --config=~/configs/project.yaml --instance=bugfix-456
```

## Shell Aliases (Optional)

Make it even easier with aliases:

```bash
# Add to ~/.zshrc or ~/.bashrc
alias work='devstack --config=~/configs/work.yaml'
alias personal='devstack --config=~/configs/personal.yaml'
alias client-a='devstack --config=~/configs/client-a.yaml'
alias client-b='devstack --config=~/configs/client-b.yaml'

# Then just run:
work
personal
client-a --instance=feature-x
```

## Managing Multiple Sessions

### List all sessions
```bash
tmux ls
```

### Attach to specific session
```bash
tmux attach -t work
tmux attach -t personal-side-project
```

### Kill specific session
```bash
tmux kill-session -t work
```

### Switch between sessions (from within tmux)
```bash
# Press: Ctrl+b s
# Shows list of all sessions, use arrows to select
```

## Tips

1. **Organize configs**: Keep all configs in `~/configs/tmux/` for easy management

2. **Use descriptive session names**: Makes it easy to identify sessions in `tmux ls`

3. **Document your configs**: Add comments in YAML files explaining what each config is for

4. **Version control**: Keep your configs in a git repo for backup and sharing across machines
   ```bash
   cd ~/configs
   git init
   git add tmux/
   git commit -m "My tmux configs"
   ```

5. **Template configs**: Create template configs for common setups you use frequently

## Troubleshooting

### "Config file not found"
Make sure the path is correct and use absolute paths:
```bash
devstack --config=~/configs/work.yaml  # Good
devstack --config=configs/work.yaml    # May fail if not in right directory
```

### Paths with spaces
Paths with spaces work fine in the YAML:
```yaml
path: ~/My Documents/Projects/main-app
```

### Wrong number of panes
Currently, configs must have exactly 3 children (4 panes total). If you need different numbers, you'll need to reinstall with a new configuration.

## Advanced: Config Library

Create a library of reusable configs:

```bash
~/configs/tmux/
├── work/
│   ├── team-alpha.yaml
│   ├── team-beta.yaml
│   └── infrastructure.yaml
├── personal/
│   ├── side-projects.yaml
│   ├── learning.yaml
│   └── experiments.yaml
└── clients/
    ├── client-a.yaml
    ├── client-b.yaml
    └── client-c.yaml
```

Then use them easily:
```bash
devstack --config=~/configs/tmux/work/team-alpha.yaml
devstack --config=~/configs/tmux/personal/side-projects.yaml
devstack --config=~/configs/tmux/clients/client-a.yaml --instance=feature-123
```

## What Gets Overridden

When you use `--config`, these values are overridden:
- ✅ Session name (from config)
- ✅ Ancestor repository path
- ✅ All children repository paths

These values are NOT overridden (use default installation):
- ❌ Color theme
- ❌ Layout
- ❌ Pane border styles

To change themes/layouts, use the customization tool:
```bash
cd ~/dev/tmux-setup
./skills/customize.sh
```

## Questions?

- See full docs: `~/dev/tmux-setup/README.md`
- Examples: `~/dev/tmux-setup/examples/`
- Help: `devstack --help`
