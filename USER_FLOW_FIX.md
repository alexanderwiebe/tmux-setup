# User Flow Fix - Interactive Setup

## Problem Identified

When users ran `./skills/install.sh` directly, it would install with example/placeholder repository paths instead of prompting them for their actual projects. This violated the expected user experience of being asked:

1. "How many panes do you want?"
2. "For pane 1, what's the path?"
3. "For pane 1, what's the name?"
4. "What color for this pane?"
5. etc.

## Root Cause

The `install.sh` script reads from existing config files (`config/setup.yaml`, etc.) which contained example values. If users ran install.sh directly, it would just use those example values without any prompting.

The interactive prompt (`skills/tmux-setup.prompt.md`) is instructions for Claude to follow, but only works when users ask Claude for help - not when they run scripts directly.

## Solutions Implemented

### 1. Setup Wizard (`setup-wizard.sh`) ✓

**NEW FILE**: A standalone interactive bash script that:
- Asks users how many panes they want (2-6)
- Prompts for path, name, and label for each pane
- Offers color theme selection (7 options)
- Offers layout selection (5 options)
- Asks for session name
- Shows a summary and asks for confirmation
- Generates config JSON and calls `generate-config.sh`
- Runs `install.sh` with the new configuration

**Usage:**
```bash
cd ~/dev/tmux-setup
./setup-wizard.sh
```

This gives users the interactive experience they expected!

### 2. Config Validation in install.sh ✓

**MODIFIED**: `skills/install.sh`

Added a `check_config_values()` function that:
- Detects if config files contain example/placeholder values
- Warns the user with clear messaging
- Offers four options:
  1. Run the setup wizard
  2. Use Claude for guided setup
  3. Edit config manually
  4. Continue anyway (not recommended)

This prevents users from accidentally installing with example values.

### 3. Updated README ✓

**MODIFIED**: `README.md`

Added clear installation methods section showing:
- **Method 1**: Setup Wizard (recommended)
- **Method 2**: Claude-Guided Setup (most interactive)
- **Method 3**: Quick Install (advanced users only)

With warnings that Method 3 should only be used if config is already customized.

## User Flow Now

### For New Users on Fresh Machine

**Option A: Setup Wizard**
```bash
git clone git@github.com:alexanderwiebe/tmux-setup.git ~/dev/tmux-setup
cd tmux-setup
./setup-wizard.sh
```

The wizard prompts for everything, generates config, installs.

**Option B: Claude-Guided**
```bash
git clone git@github.com:alexanderwiebe/tmux-setup.git ~/dev/tmux-setup
cd tmux-setup
claude
```

Then say: "Help me set up my tmux control room"

Claude reads the prompt file and guides them through Q&A.

**Option C: Manual (accidentally running install.sh)**
```bash
./skills/install.sh
```

Now gets intercepted with:
```
⚠️  Detected example/placeholder values in configuration!

Your config contains example paths like:
  • ~/dev/main-project
  • ~/dev/frontend-app

Options:
  1) Run the setup wizard: ./setup-wizard.sh
  2) Ask Claude to help: claude then say 'Help me set up tmux-setup'
  3) Edit config manually: vim config/setup.yaml
  4) Continue anyway (not recommended)

What would you like to do? (1/2/3/4):
```

User is guided to the right path!

## Distribution Impact

### Before
❌ Users clone repo
❌ Run `./skills/install.sh`
❌ Get example repos installed (~/dev/main-project, etc.)
❌ Confusion: "Why is it using these paths?"

### After
✅ Users clone repo
✅ Run `./setup-wizard.sh` (clear in README)
✅ Interactive prompts for their actual projects
✅ Custom configuration generated
✅ Installation with their values

OR

✅ Run `./skills/install.sh` accidentally
✅ Get intercepted with helpful message
✅ Redirected to setup wizard or Claude
✅ Proper setup completed

## Files Changed

1. **NEW**: `setup-wizard.sh` - Standalone interactive setup
2. **MODIFIED**: `skills/install.sh` - Added config validation
3. **MODIFIED**: `README.md` - Updated installation instructions
4. **NEW**: `USER_FLOW_FIX.md` - This document

## Testing

Test the wizard:
```bash
cd ~/dev/tmux-setup
./setup-wizard.sh
```

Test the validation:
```bash
cd ~/dev/tmux-setup
./skills/install.sh
# Should detect example values and prompt
```

Test with Claude:
```bash
cd ~/dev/tmux-setup
claude
# Say: "Help me set up tmux-setup"
```

## Next Steps

1. ✅ Setup wizard created
2. ✅ Validation added to install.sh
3. ✅ README updated
4. TODO: Commit and push
5. TODO: Update release notes
6. TODO: Test on fresh machine

## User Feedback Addressed

> "I expected it to ask: 'how many panes do you want?', 'what's the name?', 'what's the path?', 'what color?'"

✅ **FIXED**: Setup wizard now asks exactly these questions!

> "It went with the default repositories ~/dev/aj-starter-gold"

✅ **FIXED**: Config validation prevents installing with example values!

> "Why did it use hardcoded defaults and not prompt the user?"

✅ **FIXED**: Users are now directed to interactive setup methods!
