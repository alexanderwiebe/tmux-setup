# Testing & Sandbox Features - Quick Reference

**Safe testing without affecting your production setup**

## Quick Start

```bash
# Install test mode
./skills/install.sh --test --interactive

# Start test session
test-devstack

# Or use sandbox helper
./test/sandbox.sh

# Compare themes
./test/compare-themes.sh

# Clean up when done
./test/cleanup.sh
```

## What Gets Installed

### Test Mode (`--test`)

| What | Where | Purpose |
|------|-------|---------|
| Script | `~/bin/test-devstack` | Test session launcher |
| Config | `~/.tmux-test.conf` | Separate tmux config |
| Session | `test-stack` | Separate session name |
| Cleanup | `~/bin/test-devstack-cleanup` | Auto-generated cleanup |

### Production (default)

| What | Where | Purpose |
|------|-------|---------|
| Script | `~/bin/devstack` | Production launcher |
| Config | `~/.tmux.conf` | Production tmux config |
| Session | `aj-stack` | Production session name |
| Shell | `~/.zshrc` | PATH configuration |

## Available Commands

### Installation

```bash
# Production install
./skills/install.sh

# Interactive install
./skills/install.sh --interactive

# Test mode install (safe)
./skills/install.sh --test

# Dry run (preview only, no changes)
./skills/install.sh --dry-run
```

### Test Tools

```bash
# Start test session
test-devstack

# Interactive sandbox
./test/sandbox.sh

# Compare themes
./test/compare-themes.sh

# Customize in test mode
./skills/customize.sh --test

# Clean up test installation
./test/cleanup.sh
```

### Session Management

```bash
# Start production
devstack

# Start test
test-devstack

# List sessions
tmux list-sessions

# Attach to production
tmux attach -t aj-stack

# Attach to test
tmux attach -t test-stack

# Kill test session
tmux kill-session -t test-stack
```

## Test Mode vs Production

| Feature | Production | Test Mode |
|---------|-----------|-----------|
| Session name | `aj-stack` | `test-stack` |
| Script path | `~/bin/devstack` | `~/bin/test-devstack` |
| Tmux config | `~/.tmux.conf` | `~/.tmux-test.conf` |
| Modifies .zshrc | Yes | No |
| Visual banner | No | Yes (TEST MODE) |
| Cleanup script | No | Yes (auto-generated) |
| Can coexist | N/A | Yes (both can run) |

## Common Workflows

### Try a New Theme

```bash
1. ./skills/install.sh --test
2. ./test/compare-themes.sh     # Select theme
3. test-devstack                 # See it in action
4. ./skills/install.sh           # Apply to production
5. ./test/cleanup.sh             # Remove test
```

### Preview Changes

```bash
1. vim config/colors.yaml        # Make changes
2. ./skills/install.sh --dry-run # Preview
3. ./skills/install.sh --test    # Test
4. ./skills/install.sh           # Install
```

### Side-by-Side Comparison

```bash
# Terminal 1
devstack                         # Production

# Terminal 2
./test/compare-themes.sh         # Select theme
./skills/install.sh --test
test-devstack                    # Test

# Compare them visually!
```

### Safe Experimentation

```bash
1. ./test/sandbox.sh             # Launch sandbox
2. Select option 4               # Compare themes
3. Choose a theme
4. Apply to test (press 't')
5. Select option 1               # Start test session
6. Test it out
7. Select option 5               # Cleanup when done
```

## Available Themes

| Theme | Description |
|-------|-------------|
| `default` | Gold, Blue, Green, Magenta (original) |
| `ocean` | Aquatic blues and cyans |
| `forest` | Nature greens with gold |
| `fire` | Warm reds, oranges, yellows |
| `purple` | Royal purples and magentas |
| `monochrome` | Grayscale for focus |
| `cyberpunk` | High-contrast neon colors |

## Safety Guarantees

### Test Mode Is Isolated

- Separate session name (`test-stack`)
- Separate script (`test-devstack`)
- Separate config (`~/.tmux-test.conf`)
- No `.zshrc` modifications
- Clear TEST MODE banners
- Easy cleanup

### Dry Run Makes No Changes

- Zero files created
- Zero files modified
- Preview-only output
- Safe to run anytime

### Cleanup Preserves Production

- Only removes test files
- Confirms before removing
- Production untouched
- Can reinstall test anytime

## What Each Tool Does

### `./skills/install.sh --test`

Creates test installation with separate files:
- `~/bin/test-devstack`
- `~/.tmux-test.conf`
- `~/bin/test-devstack-cleanup`

### `./skills/install.sh --dry-run`

Shows what would be installed without making changes:
- Lists files to create
- Shows script previews
- Displays config snippets
- Makes zero changes

### `./test/sandbox.sh`

Interactive menu for test environment:
- Start test session (basic/claude)
- Compare themes
- Launch with custom config
- Clean up

### `./test/compare-themes.sh`

Visual theme comparison:
- View all themes
- See color details
- Auto-cycle mode
- Apply to test/production
- Restore backups

### `./test/cleanup.sh`

Remove test installation:
- Kills test-stack session
- Removes test-devstack script
- Removes test tmux config
- Preserves production

## Flags Reference

### install.sh Flags

| Flag | Purpose | Example |
|------|---------|---------|
| `--interactive` | Guided setup | `./skills/install.sh --interactive` |
| `--test` | Test mode | `./skills/install.sh --test` |
| `--dry-run` | Preview only | `./skills/install.sh --dry-run` |
| `--config=FILE` | Custom config | `./skills/install.sh --config=my.yaml` |

### customize.sh Flags

| Flag | Purpose | Example |
|------|---------|---------|
| `--test` | Test mode | `./skills/customize.sh --test` |

### devstack Flags

| Flag | Purpose | Example |
|------|---------|---------|
| `--claude` | Auto-start Claude | `devstack --claude` |
| `--instance=NAME` | Named instance | `devstack --instance=feature` |

## File Locations

### Production Files

```
~/bin/devstack                    # Production script
~/bin/tmux-send-to-children       # Helper utility
~/.tmux.conf                      # Production config (appended)
~/.zshrc                          # PATH config (appended)
```

### Test Files

```
~/bin/test-devstack               # Test script
~/bin/test-devstack-cleanup       # Auto-generated cleanup
~/.tmux-test.conf                 # Test config (separate)
```

### Repository Files

```
tmux-setup/
├── test/                         # Test tools
│   ├── cleanup.sh
│   ├── sandbox.sh
│   └── compare-themes.sh
├── skills/
│   ├── install.sh                # Main installer
│   └── customize.sh              # Customization tool
├── config/                       # Configuration files
│   ├── setup.yaml
│   ├── colors.yaml
│   └── layouts.yaml
└── examples/
    └── test-mode-workflow.sh     # Example workflows
```

## Troubleshooting

### Test Script Not Found

```bash
# Problem: test-devstack: command not found
# Solution:
./skills/install.sh --test
```

### Session Already Exists

```bash
# Problem: Session test-stack already exists
# Solution:
tmux kill-session -t test-stack
test-devstack
```

### Can't See Changes

```bash
# Problem: Theme changes not visible
# Solution:
tmux source-file ~/.tmux-test.conf
# Or restart session
tmux kill-session -t test-stack
test-devstack
```

### Production Accidentally Modified

```bash
# This shouldn't happen with test mode!
# But if worried, check:
ls -la ~/bin/devstack
ls -la ~/.tmux.conf

# Restore from backup:
cp ~/.tmux.conf.backup-* ~/.tmux.conf
```

## Documentation

| File | Purpose |
|------|---------|
| `README.md` | Main documentation |
| `TEST_MODE.md` | Complete test mode guide |
| `QUICKSTART.md` | Quick reference |
| `TEST_MODE_FEATURES.md` | Feature implementation details |
| `TESTING_SUMMARY.md` | This file - quick reference |

## Key Takeaways

1. **Test mode is completely safe** - Uses separate files, never touches production
2. **Dry run makes no changes** - Perfect for understanding what will happen
3. **Easy cleanup** - One command removes all test files
4. **Side-by-side testing** - Run test and production simultaneously
5. **Visual indicators** - Clear TEST MODE banners when in test mode

## Getting Help

- Read `TEST_MODE.md` for comprehensive guide
- Run `./skills/install.sh --help` for install options
- Run `./test/sandbox.sh` for interactive menu
- Check `examples/test-mode-workflow.sh` for example workflows

---

**Remember:** Test mode is your safe sandbox. Experiment freely - your production setup cannot be affected!
