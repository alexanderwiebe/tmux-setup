# Installation Guide for Users

This guide is for users who want to install and use the tmux-setup skill.

## Quick Install

```bash
# 1. Clone the repository
cd ~/dev
git clone git@github.com:alexanderwiebe/tmux-setup.git

# 2. Tell Claude to help you set it up
# In Claude Code, just say:
"Help me set up my tmux control room using ~/dev/tmux-setup"

# Or invoke the skill directly:
/tmux-setup
```

## What Happens Next?

When you invoke `/tmux-setup`, Claude will:

### 1. Ask About Your Workflow
```
"How many projects/repositories do you typically work on simultaneously?"
```

Example answers:
- "I have 1 main project and 3 supporting projects"
- "I work on 4 equal projects"
- "Just 2 projects"

### 2. Configure Each Pane

For each pane, Claude will ask:

```
"Let's configure pane 1:
- What's the directory path? (e.g., ~/dev/my-project)
- What should we call it? (e.g., my-project)
- Is this your primary/root project, or a child/supporting project?"
```

You answer with:
- Path: `~/dev/my-awesome-app`
- Name: `awesome-app`
- Type: `primary` or `supporting`

### 3. Choose a Color Theme

Claude will show you available themes:

- **default** - Gold, blue, green, magenta (high contrast)
- **ocean** - Calming blues and cyans
- **forest** - Easy on the eyes greens
- **fire** - Energetic reds and oranges
- **purple** - Distinctive purples
- **monochrome** - Minimal grayscale
- **cyberpunk** - Bold neon colors

Pick the one that appeals to you!

### 4. Choose a Layout

Based on your workflow, Claude will recommend a layout:

- **main-horizontal** - Large top pane, smaller bottom panes
- **main-vertical** - Large left pane, smaller right panes
- **tiled** - Equal-sized grid (2x2)
- **even-horizontal** - Equal stacked panes
- **even-vertical** - Equal side-by-side panes

### 5. Name Your Session

Claude will ask what to name your session (default: `dev-stack`)

You could use:
- `my-stack`
- `work`
- `projects`
- `dev`

### 6. Review and Confirm

Claude will show you a summary:

```
📋 Configuration Summary:
• Session name: my-stack
• Layout: main-horizontal
• Theme: ocean

Panes:
  1. [ROOT] awesome-app → ~/dev/awesome-app (cyan border)
  2. [CHILD] frontend → ~/dev/frontend (blue border)
  3. [CHILD] backend → ~/dev/backend (deep-blue border)
  4. [CHILD] docs → ~/dev/docs (navy border)

Does this look correct? (yes/no)
```

### 7. Installation

Once you confirm, Claude will:
1. Generate your configuration files
2. Run the installation script
3. Set up your shell environment
4. Create the tmux session script

### 8. Start Using It!

```bash
# Reload your shell
source ~/.zshrc

# Start your control room
my-stack  # or whatever you named it

# Or the default:
devstack
```

## Example Complete Session

```
You: "/tmux-setup"

Claude: "I'll help you set up your tmux control room! First, tell me about
your workflow - how many projects do you typically work on simultaneously?"

You: "I have one main project and 3 supporting projects"

Claude: "Perfect! That sounds like a main + supporting setup. I'll recommend
the 'main-horizontal' layout where your main project gets a large top pane.

Let's configure pane 1 (your main project):
- What's the directory path?"

You: "~/dev/ai-platform"

Claude: "Great! What should we call this project?"

You: "platform"

Claude: "Perfect. This will be your PRIMARY/ROOT project.

Now pane 2 (supporting project):
- What's the directory path?"

You: "~/dev/frontend-app"

Claude: "What should we call it?"

You: "frontend"

[... continues for remaining panes ...]

Claude: "Excellent! Now let's choose a color theme. Which appeals to you?"
[Shows theme options]

You: "ocean"

Claude: "Great choice! The ocean theme has calming blues.

What would you like to name your tmux session?"

You: "work"

Claude: "Perfect! Here's your configuration summary:

📋 Configuration Summary:
• Session name: work
• Layout: main-horizontal
• Theme: ocean

Panes:
  1. [ROOT] platform → ~/dev/ai-platform (cyan)
  2. [CHILD] frontend → ~/dev/frontend-app (blue)
  3. [CHILD] backend → ~/dev/backend-api (deep-blue)
  4. [CHILD] docs → ~/dev/documentation (navy)

Does this look correct?"

You: "yes"

Claude: [Generates configs and installs]

"Installation complete! ✓

To start your control room:
  source ~/.zshrc
  work

Key commands:
  Ctrl+b S - Sync all panes (send commands to all)
  Ctrl+b d - Detach (keeps session running)
  tmux-send-to-children 'git pull' - Send to only child panes

Customize anytime: cd ~/dev/tmux-setup && ./skills/customize.sh"

You: "work"

[Your tmux control room starts with all 4 panes!]
```

## Features You'll Get

### Visual Organization
- **Colored borders** - Each pane has a distinct color
- **Clear labels** - Shows which is ROOT vs CHILD
- **Clean layout** - Professional, organized workspace

### Productivity Helpers
- **One command startup** - `work` (or your name) starts everything
- **Sync mode** - Send commands to all panes at once
- **Helper script** - `tmux-send-to-children` for child panes only
- **Named sessions** - Run multiple instances: `--instance=feature`

### Easy Customization
- Change themes anytime
- Switch layouts on the fly
- Add/remove repositories
- Test changes safely with test mode

## Common Workflows

### Multi-repo Development
```bash
# Start your control room
work

# In ancestor pane (top), make changes and commit
git add .
git commit -m "Update feature"
git push

# Send update to all child panes
tmux-send-to-children "git fetch gold && git pull gold/main"
```

### Running Claude CLI Everywhere
```bash
# Start with Claude auto-start
work --claude

# Now all panes have Claude CLI running!
```

### Multiple Projects at Once
```bash
# Start different sessions for different project groups
work --instance=feature-a     # One set of repos
work --instance=feature-b     # Another set
work --instance=bugfix        # Yet another

# Switch between them
tmux attach -t work-feature-a
```

## Customization Later

Don't worry if you want to change things:

```bash
# Interactive customization tool
cd ~/dev/tmux-setup
./skills/customize.sh

# Or edit configs directly
vim ~/dev/tmux-setup/config/setup.yaml
vim ~/dev/tmux-setup/config/colors.yaml
vim ~/dev/tmux-setup/config/layouts.yaml

# Then regenerate
./skills/install.sh
```

## Testing Before Installing

Want to try it out first?

```bash
cd ~/dev/tmux-setup
./skills/install.sh --test

# This creates test versions (test-devstack) that don't affect your real setup
test-devstack

# Compare themes
./test/compare-themes.sh

# Clean up when done
./test/cleanup.sh
```

## Troubleshooting

### "Command not found"
```bash
source ~/.zshrc
which devstack  # Should show ~/bin/devstack
```

### "Pane borders not showing"
```bash
tmux source-file ~/.tmux.conf
```

### "Colors look wrong"
- Check your terminal supports 256 colors
- iTerm2, modern Terminal.app work great
- Try different theme: `./skills/customize.sh`

### "I made a mistake"
- Re-run: `/tmux-setup` in Claude
- Or: `cd ~/dev/tmux-setup && ./skills/customize.sh`
- Backups are at `~/.tmux.conf.backup-*` and `~/.zshrc.backup-*`

## Need Help?

- Read the full docs: `~/dev/tmux-setup/README.md`
- Quick reference: `~/dev/tmux-setup/QUICKSTART.md`
- Open an issue: https://github.com/alexanderwiebe/tmux-setup/issues
- Ask Claude: "Help me customize my tmux setup"

## Uninstall

If you want to remove it:

```bash
# Remove scripts
rm ~/bin/devstack
rm ~/bin/tmux-send-to-children

# Restore configs from backup
cp ~/.tmux.conf.backup-[timestamp] ~/.tmux.conf
cp ~/.zshrc.backup-[timestamp] ~/.zshrc

# Reload
source ~/.zshrc
tmux source-file ~/.tmux.conf
```

Backups are created automatically, so you can always restore!
