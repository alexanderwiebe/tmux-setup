# Tmux Plan: "Starter + Children" Control Room

## Goal
Create a single, repeatable tmux setup optimized for running **Claude Code CLI instances** across `aj-starter-gold` (ancestor) and its 3 child repos, where:
- Each pane runs a Claude instance in its respective repo
- **Pane titles clearly identify which repo you're in** (critical since CLI content looks similar)
- Layout emphasizes the ancestor (top half, full width) with children below
- Easy workflow: make changes in ancestor → pull changes into children via `git remote`
- Start everything with **one command** (`devstack`)

**Repos:**
- **Ancestor:** `aj-starter-gold` at `~/dev/aj-starter-gold`
- **Children:**
  - `ai-document` at `~/dev/ai-document`
  - `svg-node-editor` at `~/dev/svg-node-editor`
  - `tmux-dev` at `~/dev/tmux-dev`

**Git Workflow:**
Children track ancestor via `gold` remote → `git fetch gold && git pull gold/main`

---

## Success Criteria (What "Done" Looks Like)
- Running `devstack` attaches to tmux session (creates it if it doesn't exist)
- Resulting tmux window has **4 panes** in this layout:
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
- Each pane is `cd`'d into its respective repo
- Pane borders show **title + path**, active pane is visually obvious
- All child repos have `gold` remote configured (auto-added if missing)
- (Optional) Claude CLI auto-starts in each pane

---

## Tmux-Level Design

### Session & Window Convention
- **Session name:** `aj-stack`
- **Window name:** `stack`
- **Pane titles** encode hierarchy:
  - `ROOT: aj-starter-gold`
  - `CHILD: ai-document`
  - `CHILD: svg-node-editor`
  - `CHILD: tmux-dev`

### Pane Layout
**Layout Strategy:** Top/Bottom split emphasizing ancestor

1. Create session, starting in `~/dev/aj-starter-gold` (pane 0)
2. Split horizontally (50% height) → creates pane 1 below
3. Select pane 1, split vertically (33% width) → creates pane 2
4. Select pane 2, split vertically (50% width) → creates pane 3

**Result:** Ancestor gets top half (full width), children split bottom half equally

**Tmux commands:**
```bash
tmux new-session -d -s aj-stack -n stack -c ~/dev/aj-starter-gold
tmux split-window -h -t aj-stack:stack.0 -c ~/dev/ai-document
tmux split-window -v -t aj-stack:stack.1 -c ~/dev/svg-node-editor
tmux split-window -v -t aj-stack:stack.2 -c ~/dev/tmux-dev
tmux select-layout -t aj-stack:stack main-horizontal
```

---

## Visibility & Distinctness Plan

### Pane Border Labels (PRIMARY UI - CRITICAL)
**Why critical:** All 4 panes will show Claude CLI prompts (similar appearance) → borders are your primary navigation aid.

**Configuration (in `~/.tmux.conf`):**
```tmux
# Enable pane borders with titles
set -g pane-border-status top
set -g pane-border-format "#{?pane_active,#[bold]#[fg=cyan],#[fg=colour240]} [#{pane_index}] #T #[fg=colour237]│ #{pane_current_path} "

# Active pane border - high contrast
set -g pane-active-border-style "fg=cyan,bg=default"
set -g pane-border-style "fg=colour237,bg=default"
```

**Key elements:**
- Active pane shows **bold, cyan** title
- Inactive panes are dim (colour240/237)
- Shows: pane index, title (#T), current path
- Separator character (│) for visual clarity

### Status Bar Identity (Secondary UI)
Keep it minimal but always present for orientation.

**Configuration:**
```tmux
# Status bar at bottom
set -g status-position bottom
set -g status-style "fg=colour255,bg=colour234"
set -g status-left "#[fg=cyan,bold] #{session_name} #[fg=colour237]│ "
set -g status-right "#[fg=colour240] %H:%M #[fg=colour237]│ #[fg=colour255]#{window_index}:#{pane_index} "
set -g status-left-length 30
set -g status-right-length 40
```

**Shows:**
- Session name (left)
- Time (right)
- Window:pane index (right)

### Pane Background Theming (Optional - LOW PRIORITY)
**Status:** Defer until after testing with Claude CLI content.

**Reasoning:**
- Claude CLI is a TUI that may override background colors
- Pane borders/titles remain the reliable indicator
- If readability is fine without backgrounds, skip this feature

---

## Command Distribution Plan

### Workflow Pattern
**Common sequence:**
1. Work in ancestor pane (pane 0) → make changes
2. Send update command to all 3 child panes: `git fetch gold && git pull gold/main`

### Implementation Options

**Option A: Manual + Tmux Navigation**
- Use `prefix + q` to show pane numbers
- Navigate with `prefix + ↑↓←→` or `prefix + o` (cycle)
- Type command in each pane
- **Pro:** Simple, no setup
- **Con:** Repetitive for frequent operations

**Option B: Synchronize-Panes Mode**
- Built-in tmux feature: `set synchronize-panes on`
- Bind toggle to `prefix + S`:
  ```tmux
  bind S set-window-option synchronize-panes\; display-message "synchronize-panes is now #{?pane_synchronized,on,off}"
  ```
- **Pro:** Built-in, no scripting
- **Con:** Affects ALL 4 panes (including ancestor) - may not want this

**Option C: Targeted Send-Keys Script**
Create helper functions for precise control:
```bash
# In ~/bin/tmux-send-to-children
#!/usr/bin/env bash
SESSION="aj-stack"
WINDOW="stack"
COMMAND="$*"

# Send to panes 1, 2, 3 (children only)
for pane in 1 2 3; do
  tmux send-keys -t "$SESSION:$WINDOW.$pane" "$COMMAND" C-m
done
```

**Pro:** Precise control, excludes ancestor
**Con:** Requires helper script

**Decision:**
- **Option A** (manual) - Always available, no setup needed
- **Option B** (synchronize-panes toggle) - Included in tmux.conf (see Keybindings section)
- **Option C** (helper script) - **INCLUDED in initial implementation** (see Installation Steps)

---

## Startup Automation Plan ("One Command")

### Script: `~/bin/devstack`

**Behavior:**
1. Check if session `aj-stack` exists
   - If yes: attach to it
   - If no: proceed to create it
2. Create session and 4 panes with proper layout
3. Set pane titles using `printf '\033]2;%s\033\\'`
4. For each child repo: check for `gold` remote, add if missing
5. (Optional) Auto-start Claude CLI in each pane
6. Attach to session

**Implementation:**
```bash
#!/usr/bin/env bash
set -e

SESSION="aj-stack"
WINDOW="stack"
ANCESTOR="$HOME/dev/aj-starter-gold"
CHILDREN=(
  "$HOME/dev/ai-document"
  "$HOME/dev/svg-node-editor"
  "$HOME/dev/tmux-dev"
)
GOLD_REMOTE="https://github.com/alexanderwiebe/aj-starter-gold.git"

# Parse flags
AUTO_START_CLAUDE=false
if [[ "$1" == "--claude" ]]; then
  AUTO_START_CLAUDE=true
fi

# Check if session exists
if tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "Session '$SESSION' already exists. Attaching..."
  tmux attach-session -t "$SESSION"
  exit 0
fi

echo "Creating new session '$SESSION'..."

# Create session with pane 0 (ancestor)
tmux new-session -d -s "$SESSION" -n "$WINDOW" -c "$ANCESTOR"

# Create panes 1-3 (children)
tmux split-window -h -t "$SESSION:$WINDOW.0" -c "${CHILDREN[0]}"
tmux split-window -v -t "$SESSION:$WINDOW.1" -c "${CHILDREN[1]}"
tmux split-window -v -t "$SESSION:$WINDOW.2" -c "${CHILDREN[2]}"

# Apply main-horizontal layout (large top pane, smaller panes below)
tmux select-layout -t "$SESSION:$WINDOW" main-horizontal

# Set pane titles
tmux select-pane -t "$SESSION:$WINDOW.0" -T "ROOT: aj-starter-gold"
tmux select-pane -t "$SESSION:$WINDOW.1" -T "CHILD: ai-document"
tmux select-pane -t "$SESSION:$WINDOW.2" -T "CHILD: svg-node-editor"
tmux select-pane -t "$SESSION:$WINDOW.3" -T "CHILD: tmux-dev"

# Check/add 'gold' remote in each child repo
for i in "${!CHILDREN[@]}"; do
  PANE_NUM=$((i + 1))
  REPO_PATH="${CHILDREN[$i]}"

  # Send commands to check and add remote
  tmux send-keys -t "$SESSION:$WINDOW.$PANE_NUM" "cd $REPO_PATH" C-m
  tmux send-keys -t "$SESSION:$WINDOW.$PANE_NUM" \
    "git remote get-url gold &>/dev/null || git remote add gold $GOLD_REMOTE" C-m
done

# Auto-start Claude CLI if --claude flag is provided
if [[ "$AUTO_START_CLAUDE" == true ]]; then
  echo "Auto-starting Claude CLI in all panes..."
  for pane in 0 1 2 3; do
    tmux send-keys -t "$SESSION:$WINDOW.$pane" "claude" C-m
  done
fi

# Select ancestor pane (pane 0) and attach
tmux select-pane -t "$SESSION:$WINDOW.0"
tmux attach-session -t "$SESSION"
```

**Usage:**
```bash
# Start session without auto-starting Claude
devstack

# Start session and auto-start Claude CLI in all panes
devstack --claude
```

**Custom Layout String (If Needed):**
If `main-horizontal` doesn't give the desired layout, you can capture and use a custom layout string:
```bash
# After manually arranging panes to your liking:
tmux list-windows -F "#{window_layout}"
# Copy the layout string and replace main-horizontal in the script with:
tmux select-layout -t "$SESSION:$WINDOW" "LAYOUT_STRING_HERE"
```

---

## Tmux Configuration (`~/.tmux.conf`)

### Required Additions
Add these to your existing `~/.tmux.conf`:

```tmux
# ============================================================================
# Pane Border & Title Configuration (for aj-stack control room)
# ============================================================================

# Enable pane border titles (top position)
set -g pane-border-status top
set -g pane-border-format "#{?pane_active,#[bold]#[fg=cyan],#[fg=colour240]} [#{pane_index}] #T #[fg=colour237]│ #{pane_current_path} "

# Active pane border - high contrast cyan
set -g pane-active-border-style "fg=cyan,bg=default"

# Inactive pane border - dim gray
set -g pane-border-style "fg=colour237,bg=default"

# ============================================================================
# Status Bar Configuration
# ============================================================================

# Status bar position and style
set -g status-position bottom
set -g status-style "fg=colour255,bg=colour234"

# Left side: session name
set -g status-left "#[fg=cyan,bold] #{session_name} #[fg=colour237]│ "
set -g status-left-length 30

# Right side: time and pane info
set -g status-right "#[fg=colour240] %H:%M #[fg=colour237]│ #[fg=colour255]#{window_index}:#{pane_index} "
set -g status-right-length 40

# Window status format
set -g window-status-format " #I:#W "
set -g window-status-current-format "#[fg=cyan,bold] #I:#W "

# ============================================================================
# Keybindings
# ============================================================================

# Toggle synchronize-panes (send to all panes at once)
bind S set-window-option synchronize-panes\; display-message "synchronize-panes: #{?pane_synchronized,ON,OFF}"

# ============================================================================
# Existing Configuration (keep your TPM and plugins)
# ============================================================================
# ... your existing tmux.conf content stays here ...
```

### Testing Configuration
After editing `~/.tmux.conf`:
```bash
# Reload config in running tmux session
tmux source-file ~/.tmux.conf

# Or restart tmux entirely
```

---

## Installation Steps

### 1. Create `~/bin/` Directory
```bash
mkdir -p ~/bin
```

### 2. Add to PATH (if not already)
Check if `~/bin` is in your PATH:
```bash
echo $PATH | grep -q "$HOME/bin" && echo "Already in PATH" || echo "Not in PATH"
```

If not in PATH, add to `~/.zshrc`:
```bash
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### 3. Create `devstack` Script
```bash
# Create script
touch ~/bin/devstack
chmod +x ~/bin/devstack

# Edit with your preferred editor
# (Paste the script from "Startup Automation Plan" section above)
```

### 3b. Create `tmux-send-to-children` Helper Script
```bash
# Create script
touch ~/bin/tmux-send-to-children
chmod +x ~/bin/tmux-send-to-children

# Add this content:
cat > ~/bin/tmux-send-to-children << 'EOF'
#!/usr/bin/env bash
SESSION="aj-stack"
WINDOW="stack"
COMMAND="$*"

# Send to panes 1, 2, 3 (children only)
for pane in 1 2 3; do
  tmux send-keys -t "$SESSION:$WINDOW.$pane" "$COMMAND" C-m
done
EOF
```

### 4. Update `~/.tmux.conf`
```bash
# Back up existing config
cp ~/.tmux.conf ~/.tmux.conf.backup

# Edit and add the new configuration from above
# (Append to existing file, keep TPM plugins)
```

### 5. Test the Setup
```bash
# Reload tmux config (if in a session)
tmux source-file ~/.tmux.conf

# Run devstack
devstack
```

**Expected result:**
- Tmux session `aj-stack` with 4 panes
- Top pane (ancestor) full width
- Bottom 3 panes (children) split equally
- Pane borders show titles: "ROOT: aj-starter-gold", "CHILD: ai-document", etc.
- Active pane border is cyan/bold
- All child repos have `gold` remote configured

---

## Key Interactions (Quality of Life)

### Navigate Between Panes
- `prefix + q` → Show pane numbers
- `prefix + ↑↓←→` → Navigate to pane in direction
- `prefix + o` → Cycle through panes

### Send Commands to Multiple Panes
**Option 1: Helper script (children only)**
```bash
tmux-send-to-children "git fetch gold && git pull gold/main"
```

**Option 2: Synchronize-panes mode (all panes)**
1. `prefix + S` → Toggle synchronize-panes
2. Type command (goes to all panes including ancestor)
3. `prefix + S` → Toggle off

**Option 3: Manual (for different commands per pane)**
1. Navigate to each pane
2. Type/paste command
3. Repeat

**Common workflow example:**
```bash
# In ancestor (pane 0): Make changes, commit, push

# Send to all children at once:
tmux-send-to-children "git fetch gold && git pull gold/main"
```

### Zoom/Maximize Pane Temporarily
- `prefix + z` → Zoom current pane to full window
- `prefix + z` again → Restore layout

### Rename Pane Title (Optional - Future Enhancement)
Not implemented in initial version. Could add:
```tmux
bind T command-prompt -p "Pane title:" "select-pane -T '%%'"
```

### Detach/Reattach Session
- `prefix + d` → Detach from session (keeps running)
- `devstack` → Reattach (script detects existing session)

---

## Stretch Goals (Future Enhancements)

### 1. Second Window for "Ops"
Add a second tmux window for operations:
- Pane for running tests across all repos
- Pane for git status monitoring
- Pane for build/deploy commands

### 2. Custom Keybindings with tmux-which-key
Leverage your existing `tmux-which-key` plugin:
```tmux
# Add custom menu for aj-stack operations
bind C-a display-menu -T "aj-stack" \
  "Sync children" s "run-shell 'tmux-send-to-children \"git fetch gold && git pull gold/main\"'" \
  "Toggle sync-panes" S "set-window-option synchronize-panes" \
  "Zoom pane" z "resize-pane -Z"
```

### 3. Pane Background Theming
If Claude CLI doesn't override backgrounds, add subtle colors:
```tmux
# Per-pane background (test readability first)
tmux select-pane -t aj-stack:stack.0 -P 'bg=colour234'  # Ancestor: dark gray
tmux select-pane -t aj-stack:stack.1 -P 'bg=colour235'  # Child 1: slightly lighter
tmux select-pane -t aj-stack:stack.2 -P 'bg=colour235'  # Child 2
tmux select-pane -t aj-stack:stack.3 -P 'bg=colour235'  # Child 3
```

### 4. Vim-style Pane Navigation
If you prefer vim keybindings for pane navigation, add to `~/.tmux.conf`:
```tmux
bind -r h select-pane -L
bind -r j select-pane -D
bind -r k select-pane -U
bind -r l select-pane -R
```
Note: This overrides `prefix + l` (last window) binding.

---

## Risks / Notes

### Known Limitations
- **Pane backgrounds:** Claude CLI (TUI) may override background colors → pane borders/titles are the reliable UI
- **Layout precision:** Getting exact 50% top / 3x equal bottom split may require custom layout string (use `tmux list-windows -F "#{window_layout}"` after manual adjustment)
- **Terminal capability:** Ensure iTerm2 supports 256 colors (`echo $TERM` should show `screen-256color` or `tmux-256color` in tmux)

### Git Workflow Note
This tmux setup makes it *easy* to run commands across repos, but the actual sync workflow is still a Git concern:
- Ancestor changes → commit & push to ancestor repo
- Children → `git fetch gold && git pull gold/main` (or merge)
- Handle conflicts manually if they arise

The tmux control room just makes the mechanical steps faster.

### Tmux Session Persistence
- Session persists until explicitly killed (`tmux kill-session -t aj-stack`)
- Detaching (`prefix + d`) keeps it running in background
- `devstack` will attach to existing session (idempotent)

### Alternative: Use tmuxinator or tmuxp
If this setup grows more complex, consider:
- **tmuxinator:** Ruby-based tmux session manager (YAML config)
- **tmuxp:** Python-based tmux session manager (YAML/JSON config)

These can replace the `devstack` script with declarative configuration.

---

## Implementation Checklist

- [ ] **Create `~/bin/` directory** and ensure it's in PATH
- [ ] **Back up existing `~/.tmux.conf`**: `cp ~/.tmux.conf ~/.tmux.conf.backup`
- [ ] **Add pane border & status bar settings** to `~/.tmux.conf`
- [ ] **Add keybindings** (`prefix + S` for synchronize-panes)
- [ ] **Reload tmux config**: `tmux source-file ~/.tmux.conf`
- [ ] **Create `~/bin/devstack` script** (paste from "Startup Automation Plan" section)
- [ ] **Create `~/bin/tmux-send-to-children` helper script**
- [ ] **Make scripts executable**: `chmod +x ~/bin/devstack ~/bin/tmux-send-to-children`
- [ ] **Test layout** - run `devstack`, verify main-horizontal layout works
- [ ] **Adjust layout if needed** - capture custom layout string if main-horizontal doesn't work
- [ ] **Verify pane titles** are clearly visible in borders (test with Claude CLI running)
- [ ] **Test git remote check** - verify `gold` remote is added to tmux-dev
- [ ] **Test helper script** - `tmux-send-to-children "echo test"` should print in 3 child panes
- [ ] **Test --claude flag** - `devstack --claude` should auto-start Claude in all panes
- [ ] **Document any custom layout string** in this plan or in the script (if needed)

---

## Quick Reference

### Start/Attach Session
```bash
devstack                # Start without auto-launching Claude
devstack --claude       # Start and auto-launch Claude in all panes
```

### Send Command to All Children
```bash
# Option 1: Helper script (children only - RECOMMENDED)
tmux-send-to-children "git fetch gold && git pull gold/main"

# Option 2: Manual with sync mode (all panes including ancestor)
prefix + S              # Toggle synchronize-panes ON
git fetch gold && git pull gold/main
prefix + S              # Toggle OFF
```

### Navigate Panes
```bash
prefix + q              # Show pane numbers
prefix + o              # Cycle through panes
prefix + ↑↓←→           # Arrow navigation
```

### Zoom Pane
```bash
prefix + z              # Toggle zoom
```

### Detach/Kill Session
```bash
prefix + d              # Detach (session keeps running)
tmux kill-session -t aj-stack  # Kill session entirely
```

### Reload Tmux Config
```bash
tmux source-file ~/.tmux.conf
```

---

## Next Steps

1. **Review this plan** - make any final adjustments
2. **Implement configuration changes** - follow "Installation Steps"
3. **Test the setup** - run `devstack`, verify layout and functionality
4. **Iterate** - adjust colors, layout, keybindings as needed
5. **Add helpers** - implement stretch goals if the workflow demands it
