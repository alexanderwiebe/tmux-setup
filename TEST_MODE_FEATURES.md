# Test Mode Features - Summary

**Version 2.1 - Test Mode & Sandbox Capabilities**

## What Was Added

This update adds comprehensive testing and sandbox capabilities to tmux-setup, allowing users to safely experiment with themes, configurations, and layouts without affecting their production setup.

## New Features

### 1. Test Mode Installation (`--test` flag)

**File:** `skills/install.sh`

**What it does:**
- Installs to separate files (`test-devstack`, `~/.tmux-test.conf`)
- Uses session name `test-stack` instead of `aj-stack`
- Doesn't modify `~/.zshrc` (uses existing PATH)
- Shows clear "TEST MODE" banners
- Auto-generates cleanup script

**Usage:**
```bash
./skills/install.sh --test
./skills/install.sh --test --interactive
```

**Files created:**
- `~/bin/test-devstack` (instead of `devstack`)
- `~/.tmux-test.conf` (instead of modifying `~/.tmux.conf`)
- `~/bin/test-devstack-cleanup` (auto-generated cleanup)

### 2. Dry Run Mode (`--dry-run` flag)

**File:** `skills/install.sh`

**What it does:**
- Shows exactly what would be installed
- Previews generated scripts and configs
- Makes zero changes to the system
- Perfect for understanding what will happen

**Usage:**
```bash
./skills/install.sh --dry-run
./skills/install.sh --dry-run --config=my-config.yaml
```

**Output:**
- Lists files that would be created
- Shows script previews
- Displays configuration snippets
- No actual installation

### 3. Test Cleanup Script

**File:** `test/cleanup.sh`

**What it does:**
- Removes all test installation files
- Kills test-stack session if running
- Never touches production files
- Provides confirmation before removing

**Usage:**
```bash
./test/cleanup.sh
```

**Removes:**
- `~/bin/test-devstack`
- `~/.tmux-test.conf`
- `test-stack` tmux session
- Auto-generated cleanup script

**Preserves:**
- `~/bin/devstack` (production)
- `~/.tmux.conf` (production)
- All production sessions

### 4. Sandbox Helper

**File:** `test/sandbox.sh`

**What it does:**
- Interactive test environment launcher
- Menu-driven interface
- Start test sessions with options
- Access theme comparison
- Quick cleanup

**Usage:**
```bash
./test/sandbox.sh
```

**Menu options:**
1. Start test session (basic)
2. Start test session with Claude
3. Start with custom tmux config
4. Compare themes
5. Clean up and exit

### 5. Theme Comparison Tool

**File:** `test/compare-themes.sh`

**What it does:**
- Visual theme comparison
- Auto-cycle through all themes
- Apply to test or production
- View color details
- Restore original theme

**Usage:**
```bash
./test/compare-themes.sh
```

**Features:**
- View all 7 themes individually
- See color descriptions and values
- Auto-cycle mode (3 seconds per theme)
- Apply to test mode first
- Restore backup if needed

**Available themes:**
- default (Gold, Blue, Green, Magenta)
- ocean (Aquatic blues and cyans)
- forest (Nature greens with gold)
- fire (Warm reds, oranges, yellows)
- purple (Royal purples and magentas)
- monochrome (Grayscale for focus)
- cyberpunk (High-contrast neon)

### 6. Test Mode Support in Customize

**File:** `skills/customize.sh`

**What it does:**
- Adds `--test` flag support
- Shows TEST MODE banner
- Updates apply instructions
- Same interactive menu

**Usage:**
```bash
./skills/customize.sh --test
```

**Changes:**
- Clear test mode indicators
- Instructions show `--test` flag
- All other functionality identical

### 7. Comprehensive Documentation

**File:** `TEST_MODE.md`

**What it covers:**
- Complete test mode guide
- Dry run mode explanation
- Theme comparison workflow
- Side-by-side testing
- Cleanup procedures
- Safety guarantees
- Troubleshooting
- Advanced usage patterns

## Updated Files

### Modified Files

1. **skills/install.sh**
   - Added `--test` flag support
   - Added `--dry-run` flag support
   - Test mode banners
   - Separate file paths for test mode
   - Auto-generate cleanup script
   - Updated help text

2. **skills/customize.sh**
   - Added `--test` flag support
   - Test mode banner display
   - Updated apply instructions

3. **README.md**
   - Added test mode section
   - Added dry run section
   - Updated feature list
   - New quick start examples

4. **FILE_MANIFEST.md**
   - Added test/ directory files
   - Updated statistics
   - Added test mode installation targets
   - Updated usage examples

### New Files

1. **test/cleanup.sh**
   - Executable script
   - Safe test removal
   - Production preservation

2. **test/sandbox.sh**
   - Executable script
   - Interactive menu
   - Multiple launch options

3. **test/compare-themes.sh**
   - Executable script
   - Visual theme comparison
   - Auto-cycle mode

4. **TEST_MODE.md**
   - Comprehensive documentation
   - Step-by-step guides
   - Safety guarantees

5. **TEST_MODE_FEATURES.md** (this file)
   - Feature summary
   - Implementation details

## File Structure

```
tmux-setup/
├── test/                          # NEW DIRECTORY
│   ├── cleanup.sh                 # NEW - Remove test installation
│   ├── sandbox.sh                 # NEW - Interactive test launcher
│   └── compare-themes.sh          # NEW - Theme comparison tool
├── skills/
│   ├── install.sh                 # MODIFIED - Added --test, --dry-run
│   └── customize.sh               # MODIFIED - Added --test
├── TEST_MODE.md                   # NEW - Complete guide
├── TEST_MODE_FEATURES.md          # NEW - This file
├── README.md                      # MODIFIED - Added test mode sections
└── FILE_MANIFEST.md               # MODIFIED - Added test files
```

## Safety Guarantees

### Test Mode Never Touches Production

When using `--test` flag:
- ✓ Separate session name (`test-stack` vs `aj-stack`)
- ✓ Separate script (`test-devstack` vs `devstack`)
- ✓ Separate config (`~/.tmux-test.conf` vs `~/.tmux.conf`)
- ✓ No `.zshrc` modifications
- ✓ Easy cleanup script
- ✓ Visual TEST MODE banners

### Dry Run Makes Zero Changes

When using `--dry-run` flag:
- ✓ No files created
- ✓ No files modified
- ✓ No directories created
- ✓ Preview-only output
- ✓ Safe to run anytime

### Cleanup Preserves Production

When running `./test/cleanup.sh`:
- ✓ Only removes test files
- ✓ Confirms before removing
- ✓ Production files untouched
- ✓ Can reinstall test anytime

## Usage Workflows

### Workflow 1: Try a New Theme

```bash
# 1. Install test mode
./skills/install.sh --test --interactive

# 2. Compare themes
./test/compare-themes.sh

# 3. Select and apply to test
# (choose theme, press 't')

# 4. Reinstall test with new theme
./skills/install.sh --test

# 5. Start test session
test-devstack

# 6. If you like it, apply to production
./skills/install.sh

# 7. Clean up test
./test/cleanup.sh
```

### Workflow 2: Preview Changes

```bash
# 1. Make config changes
vim config/colors.yaml

# 2. Preview what would happen
./skills/install.sh --dry-run

# 3. If looks good, test it
./skills/install.sh --test

# 4. Start test session
test-devstack

# 5. If perfect, install production
./skills/install.sh
```

### Workflow 3: Side-by-Side Comparison

```bash
# Terminal 1: Production
devstack

# Terminal 2: Test with different theme
./test/compare-themes.sh  # Select different theme
./skills/install.sh --test
test-devstack

# Now compare them side-by-side!
```

### Workflow 4: Using Sandbox Helper

```bash
# Launch interactive sandbox
./test/sandbox.sh

# Menu appears with options:
# 1. Start test session (basic)
# 2. Start test session with Claude
# 3. Start with custom config
# 4. Compare themes
# 5. Clean up and exit

# Select option 4 to compare themes
# Select option 1 to start test session
# Select option 5 when done
```

## Implementation Notes

### Session Name Override

Test mode changes session name from `aj-stack` to `test-stack` by:
1. Modifying `SESSION_NAME` variable in generated script
2. Using `sed` to replace session name
3. Ensuring all tmux commands use correct session

### File Path Separation

Test mode uses separate paths:
- Script: `~/bin/test-devstack` (not `~/bin/devstack`)
- Config: `~/.tmux-test.conf` (not `~/.tmux.conf`)
- Session: `test-stack` (not `aj-stack`)

### Cleanup Script Generation

When installing in test mode:
1. Auto-generates cleanup script
2. Saves to `~/bin/test-devstack-cleanup`
3. Makes it executable
4. Includes safety checks

### Visual Indicators

Test mode shows banners:
```
╔════════════════════════════════════════╗
║          TEST MODE ACTIVE              ║
║  Your production setup is safe         ║
╚════════════════════════════════════════╝
```

Dry run shows banners:
```
╔════════════════════════════════════════╗
║         DRY RUN MODE                   ║
║  No changes will be made               ║
╚════════════════════════════════════════╝
```

### Test Mode Flag Propagation

The `--test` flag is recognized by:
- `skills/install.sh` - Main installation
- `skills/customize.sh` - Customization tool

Both show appropriate indicators and instructions.

## Testing the Test Mode

To verify test mode works correctly:

```bash
# 1. Install test mode
./skills/install.sh --test

# 2. Verify files created
ls -la ~/bin/test-devstack          # Should exist
ls -la ~/.tmux-test.conf            # Should exist
ls -la ~/bin/devstack               # Should NOT exist (or unchanged)

# 3. Start test session
test-devstack

# 4. Verify session name
tmux list-sessions | grep test-stack  # Should exist
tmux list-sessions | grep aj-stack    # Should NOT exist

# 5. Clean up
./test/cleanup.sh

# 6. Verify cleanup
ls -la ~/bin/test-devstack          # Should NOT exist
ls -la ~/.tmux-test.conf            # Should NOT exist
tmux list-sessions | grep test-stack  # Should NOT exist
```

## Benefits

### For Users

1. **Safe Experimentation** - Try themes without risk
2. **Preview Changes** - See what will happen before installing
3. **Easy Comparison** - Compare themes side-by-side
4. **Clean Sandbox** - Test and cleanup easily
5. **No Fear** - Production setup always safe

### For Development

1. **Test Changes** - Test modifications before committing
2. **Multiple Configs** - Test different configurations
3. **Verify Scripts** - Ensure scripts work correctly
4. **Documentation** - Test examples in docs

### For Learning

1. **Explore Features** - Learn how it works safely
2. **Try Themes** - See all color schemes
3. **Understand Flow** - Preview installation steps
4. **Build Confidence** - Safe to experiment

## Future Enhancements

Potential additions for future versions:

1. **Compare Mode** - Split-screen theme comparison
2. **Test Profiles** - Save multiple test configurations
3. **Theme Editor** - Visual theme creation tool
4. **Layout Preview** - Visual layout comparison
5. **Config Diff** - Compare test vs production configs
6. **Batch Testing** - Test multiple themes automatically
7. **Export Config** - Export test config for sharing

## Version History

- **v2.1.0** (2026-02-04) - Test mode and sandbox features
  - Added `--test` flag
  - Added `--dry-run` flag
  - Added test/ directory with 3 scripts
  - Added TEST_MODE.md documentation
  - Updated existing scripts
  - Updated documentation

- **v2.0.0** (2026-02-04) - Claude Code skill release
  - Initial skill implementation

## Summary

Test mode provides a complete sandbox environment for safely experimenting with tmux-setup configurations. Users can:

- Install to separate files (`--test`)
- Preview without installing (`--dry-run`)
- Compare themes visually (`compare-themes.sh`)
- Use interactive sandbox (`sandbox.sh`)
- Clean up completely (`cleanup.sh`)

**Production setup is always safe and never affected by test mode.**
