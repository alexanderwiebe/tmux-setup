# Test Mode & Sandbox Guide

**Safe Testing Without Affecting Your Production Setup**

This guide explains how to test themes, configurations, and layouts without touching your production tmux setup. Test mode uses completely separate files so you can experiment freely.

## Table of Contents

- [Quick Start](#quick-start)
- [What is Test Mode?](#what-is-test-mode)
- [Test Mode vs Production](#test-mode-vs-production)
- [Using Test Mode](#using-test-mode)
- [Using Dry Run Mode](#using-dry-run-mode)
- [Comparing Themes](#comparing-themes)
- [Customizing Test Setup](#customizing-test-setup)
- [Promoting Test to Production](#promoting-test-to-production)
- [Cleaning Up](#cleaning-up)
- [Side-by-Side Testing](#side-by-side-testing)

---

## Quick Start

```bash
# Install in test mode (safe)
./skills/install.sh --test --interactive

# Start test session
test-devstack

# Or use the sandbox helper
./test/sandbox.sh

# Compare themes visually
./test/compare-themes.sh

# Clean up when done
./test/cleanup.sh
```

---

## What is Test Mode?

Test mode creates a completely separate installation that doesn't affect your production setup. It's perfect for:

- Testing new themes before committing
- Trying different layouts
- Experimenting with configurations
- Learning how the system works
- Previewing changes before production

### Visual Indicators

When in test mode, you'll see clear banners:

```
╔════════════════════════════════════════╗
║          TEST MODE ACTIVE              ║
║  Your production setup is safe         ║
╚════════════════════════════════════════╝
```

---

## Test Mode vs Production

| Aspect | Production | Test Mode |
|--------|-----------|-----------|
| Session name | `aj-stack` | `test-stack` |
| Script name | `devstack` | `test-devstack` |
| Tmux config | `~/.tmux.conf` | `~/.tmux-test.conf` |
| Modifies `.zshrc` | Yes | No (uses existing PATH) |
| Cleanup script | N/A | Auto-generated |

**Important:** Test and production can coexist! You can have both running simultaneously.

---

## Using Test Mode

### Install Test Mode

```bash
# Basic test installation
./skills/install.sh --test

# Interactive test installation (recommended)
./skills/install.sh --test --interactive

# With custom config
./skills/install.sh --test --config=my-config.yaml
```

### Start Test Session

```bash
# Direct command
test-devstack

# With Claude
test-devstack --claude

# Using sandbox helper (recommended)
./test/sandbox.sh
```

### What Gets Installed

1. **`~/bin/test-devstack`** - Test version of devstack script
2. **`~/.tmux-test.conf`** - Separate tmux configuration
3. **`~/bin/test-devstack-cleanup`** - Auto-generated cleanup script

### What Doesn't Change

Your production files remain untouched:
- `~/bin/devstack` - Safe
- `~/.tmux.conf` - Safe
- `~/.zshrc` - Not modified in test mode
- Any running production sessions - Safe

---

## Using Dry Run Mode

Dry run shows exactly what would be installed **without making any changes**. Use this to preview before installing.

```bash
# Preview installation
./skills/install.sh --dry-run

# Preview with custom config
./skills/install.sh --dry-run --config=my-config.yaml

# Preview interactive mode
./skills/install.sh --dry-run --interactive
```

### Dry Run Output

Dry run shows:
- Files that would be created
- Paths that would be modified
- Generated script previews
- Configuration file previews
- No actual changes are made

Example output:
```
╔════════════════════════════════════════╗
║         DRY RUN MODE                   ║
║  No changes will be made               ║
╚════════════════════════════════════════╝

[DRY RUN] Would install: /path/to/devstack -> ~/bin/devstack
[DRY RUN] Would configure: ~/.tmux.conf

Preview of devstack:
#!/usr/bin/env bash
...
```

---

## Comparing Themes

The theme comparison tool helps you choose the perfect color scheme.

### Using Compare Themes

```bash
# Launch theme comparison
./test/compare-themes.sh

# Or from sandbox
./test/sandbox.sh
# Select option 4 (Compare themes)
```

### Theme Comparison Features

**View Individual Themes:**
- See color descriptions
- View color values
- Apply to test or production

**Auto-Cycle Mode:**
- Automatically cycles through all themes
- 3 seconds per theme
- Press Ctrl+C to stop

**Available Themes:**
1. **default** - Gold, Blue, Green, Magenta
2. **ocean** - Aquatic blues and cyans
3. **forest** - Nature greens with gold
4. **fire** - Warm reds, oranges, yellows
5. **purple** - Royal purples and magentas
6. **monochrome** - Grayscale for focus
7. **cyberpunk** - High-contrast neon colors

### Workflow

```bash
# 1. Compare themes
./test/compare-themes.sh

# 2. Select a theme to view
# Enter 1-7

# 3. Apply to test mode
# Press 't' to apply to test only

# 4. Install test mode with new theme
./skills/install.sh --test

# 5. Start test session to see it
test-devstack

# 6. If you like it, apply to production
./skills/install.sh

# 7. Or try another theme
./test/cleanup.sh
./test/compare-themes.sh
```

---

## Customizing Test Setup

Use the customization helper in test mode:

```bash
# Customize test configuration
./skills/customize.sh --test
```

This opens the interactive customization menu in test mode. Changes will be applied only to test installations.

### Customization Options

1. **Change color theme** - Switch between 7 themes
2. **Change layout** - Choose from 5 layouts
3. **Manage repositories** - Add/remove repos
4. **Toggle features** - Enable/disable features
5. **View current configuration** - See all settings
6. **Create custom theme** - Design your own colors

After customizing, apply changes:

```bash
# Apply customizations to test mode
./skills/install.sh --test

# Start test session
test-devstack
```

---

## Promoting Test to Production

When you're happy with your test configuration, promote it to production:

### Method 1: Simple Re-install

```bash
# After testing and liking your setup
./skills/install.sh

# This uses the same config files
# But installs to production paths
```

### Method 2: Copy Configuration First

```bash
# Copy test config to backup
cp ~/.tmux-test.conf ~/.tmux-test.conf.backup

# Install to production
./skills/install.sh

# Verify production works
devstack

# Clean up test installation
./test/cleanup.sh
```

### Method 3: Keep Both

You can keep test mode installed alongside production:

```bash
# Test session
test-devstack

# Production session (in another terminal)
devstack

# Both can run simultaneously!
```

---

## Cleaning Up

Remove test installation when you're done:

### Using Cleanup Script

```bash
# Run cleanup script
./test/cleanup.sh

# Or use auto-generated version
~/bin/test-devstack-cleanup
```

### What Gets Removed

The cleanup script removes:
- `~/bin/test-devstack`
- `~/.tmux-test.conf`
- `test-stack` tmux session (if running)
- Auto-generated cleanup script

### What Stays Safe

Your production setup is never touched:
- `~/bin/devstack` - Intact
- `~/.tmux.conf` - Intact
- `~/.zshrc` - Intact
- Production sessions - Running

### Cleanup Confirmation

The script asks for confirmation before removing anything:

```
Test Devstack Cleanup
========================================

This will remove:
  - ~/bin/test-devstack
  - ~/.tmux-test.conf
  - Test tmux session (test-stack)

Your production setup will NOT be affected:
  - ~/bin/devstack (safe)
  - ~/.tmux.conf (safe)
  - Regular tmux sessions (safe)

Continue with cleanup? (y/N):
```

---

## Side-by-Side Testing

Run test and production simultaneously to compare:

### Setup

```bash
# Terminal 1: Start production
devstack

# Terminal 2: Start test
test-devstack

# Now you can compare them side-by-side!
```

### Comparison Workflow

```bash
# 1. Start production session
devstack

# 2. In another terminal, try different themes in test
./test/compare-themes.sh
# Select theme and apply to test

./skills/install.sh --test
test-devstack

# 3. Compare visually in split terminals

# 4. Choose your favorite and apply to production
./skills/install.sh
```

### Attach to Sessions

```bash
# Attach to production
tmux attach -t aj-stack

# Attach to test (in another terminal)
tmux attach -t test-stack

# Or use tmux split windows
tmux split-window -h "tmux attach -t test-stack"
```

---

## Advanced Usage

### Custom Test Configurations

Create a custom config for testing:

```bash
# Copy default config
cp config/setup.yaml my-test-config.yaml

# Edit your test config
vim my-test-config.yaml

# Install with custom test config
./skills/install.sh --test --config=my-test-config.yaml
```

### Preview Before Test Install

```bash
# First, preview what would be installed
./skills/install.sh --dry-run --config=my-config.yaml

# If it looks good, install to test mode
./skills/install.sh --test --config=my-config.yaml

# If test works well, install to production
./skills/install.sh --config=my-config.yaml
```

### Multiple Test Iterations

```bash
# Try one theme
./test/compare-themes.sh  # Select ocean
./skills/install.sh --test
test-devstack
# Check it out...

# Try another without cleanup
./test/cleanup.sh
./test/compare-themes.sh  # Select fire
./skills/install.sh --test
test-devstack
# Compare...

# Settle on favorite
./test/compare-themes.sh  # Select forest
./skills/install.sh --test
test-devstack
# Perfect!

# Install to production
./skills/install.sh
```

---

## Safety Guarantees

Test mode provides these safety guarantees:

1. **Separate Session Names** - `test-stack` vs `aj-stack`
2. **Separate Scripts** - `test-devstack` vs `devstack`
3. **Separate Configs** - `~/.tmux-test.conf` vs `~/.tmux.conf`
4. **No Production Modifications** - `.zshrc` not touched in test mode
5. **Easy Cleanup** - Dedicated cleanup scripts
6. **Visual Indicators** - Clear TEST MODE banners
7. **Isolated State** - Test and production never interfere

**You cannot accidentally affect production when in test mode.**

---

## Troubleshooting

### Test Script Not Found

```bash
# Error: test-devstack: command not found

# Solution: Reinstall test mode
./skills/install.sh --test
```

### Test Session Won't Start

```bash
# Error: Session already exists

# Solution: Kill old test session
tmux kill-session -t test-stack

# Then start fresh
test-devstack
```

### Can't See Changes

```bash
# After changing theme, don't see colors

# Solution: Reload tmux config
tmux source-file ~/.tmux-test.conf

# Or restart test session
tmux kill-session -t test-stack
test-devstack
```

### Production Accidentally Changed

**This shouldn't happen!** Test mode uses separate files.

If you think production was changed:

```bash
# Check what's installed
ls -la ~/bin/devstack
ls -la ~/bin/test-devstack

# Check configs
ls -la ~/.tmux.conf
ls -la ~/.tmux-test.conf

# Restore from backup if needed
cp ~/.tmux.conf.backup-* ~/.tmux.conf
```

---

## Summary

Test mode provides a safe sandbox for experimentation:

**Installation:**
```bash
./skills/install.sh --test --interactive
```

**Preview (no changes):**
```bash
./skills/install.sh --dry-run
```

**Usage:**
```bash
test-devstack                # Start test session
./test/sandbox.sh            # Interactive sandbox
./test/compare-themes.sh     # Compare themes
./skills/customize.sh --test # Customize test config
```

**Cleanup:**
```bash
./test/cleanup.sh            # Remove test installation
```

**Promote to Production:**
```bash
./skills/install.sh          # After testing
```

---

## Related Documentation

- [README.md](README.md) - Main documentation
- [QUICKSTART.md](QUICKSTART.md) - Quick start guide
- [INSTALLATION_SUMMARY.md](INSTALLATION_SUMMARY.md) - Installation details
- [config/colors.yaml](config/colors.yaml) - Theme definitions
- [config/layouts.yaml](config/layouts.yaml) - Layout definitions

---

**Happy testing!** Remember: Test mode is completely safe. Your production setup cannot be affected.
