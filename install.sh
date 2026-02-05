#!/usr/bin/env bash

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Tmux Control Room Setup - Installation${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# ============================================================================
# Step 1: Create ~/bin directory if it doesn't exist
# ============================================================================
echo -e "${CYAN}[1/6]${NC} Creating ~/bin directory..."
if [ ! -d "$HOME/bin" ]; then
  mkdir -p "$HOME/bin"
  echo -e "${GREEN}✓${NC} Created $HOME/bin"
else
  echo -e "${YELLOW}→${NC} $HOME/bin already exists"
fi
echo ""

# ============================================================================
# Step 2: Copy bin scripts and make them executable
# ============================================================================
echo -e "${CYAN}[2/6]${NC} Installing scripts to ~/bin..."
cp "$SCRIPT_DIR/bin/devstack" "$HOME/bin/"
cp "$SCRIPT_DIR/bin/tmux-send-to-children" "$HOME/bin/"
chmod +x "$HOME/bin/devstack"
chmod +x "$HOME/bin/tmux-send-to-children"
echo -e "${GREEN}✓${NC} Installed devstack"
echo -e "${GREEN}✓${NC} Installed tmux-send-to-children"
echo ""

# ============================================================================
# Step 3: Backup and update ~/.tmux.conf
# ============================================================================
echo -e "${CYAN}[3/6]${NC} Configuring ~/.tmux.conf..."
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Check if .tmux.conf exists
if [ ! -f "$HOME/.tmux.conf" ]; then
  echo -e "${YELLOW}→${NC} ~/.tmux.conf doesn't exist, creating new file"
  touch "$HOME/.tmux.conf"
fi

# Check if our additions are already present
if grep -q "Pane Border & Title Configuration (for aj-stack control room)" "$HOME/.tmux.conf"; then
  echo -e "${YELLOW}→${NC} tmux.conf additions already present, skipping"
else
  # Backup existing config
  BACKUP_FILE="$HOME/.tmux.conf.backup-$TIMESTAMP"
  cp "$HOME/.tmux.conf" "$BACKUP_FILE"
  echo -e "${GREEN}✓${NC} Backed up to $BACKUP_FILE"

  # Append additions
  echo "" >> "$HOME/.tmux.conf"
  echo "# ============================================================================" >> "$HOME/.tmux.conf"
  echo "# Tmux Control Room Setup - Added by install.sh on $(date)" >> "$HOME/.tmux.conf"
  echo "# ============================================================================" >> "$HOME/.tmux.conf"
  cat "$SCRIPT_DIR/config/tmux.conf.additions" >> "$HOME/.tmux.conf"
  echo -e "${GREEN}✓${NC} Added tmux configuration"
fi
echo ""

# ============================================================================
# Step 4: Backup and update ~/.zshrc
# ============================================================================
echo -e "${CYAN}[4/6]${NC} Configuring ~/.zshrc..."

# Check if .zshrc exists
if [ ! -f "$HOME/.zshrc" ]; then
  echo -e "${YELLOW}→${NC} ~/.zshrc doesn't exist, creating new file"
  touch "$HOME/.zshrc"
fi

# Check if ~/bin is already in PATH in .zshrc
if grep -q 'export PATH=.*\$HOME/bin' "$HOME/.zshrc" || grep -q 'export PATH=.*~/bin' "$HOME/.zshrc"; then
  echo -e "${YELLOW}→${NC} ~/bin already in PATH in .zshrc, skipping"
else
  # Backup existing config
  BACKUP_FILE="$HOME/.zshrc.backup-$TIMESTAMP"
  cp "$HOME/.zshrc" "$BACKUP_FILE"
  echo -e "${GREEN}✓${NC} Backed up to $BACKUP_FILE"

  # Append additions
  echo "" >> "$HOME/.zshrc"
  echo "# ============================================================================" >> "$HOME/.zshrc"
  echo "# Tmux Control Room Setup - Added by install.sh on $(date)" >> "$HOME/.zshrc"
  echo "# ============================================================================" >> "$HOME/.zshrc"
  cat "$SCRIPT_DIR/config/zshrc.additions" >> "$HOME/.zshrc"
  echo -e "${GREEN}✓${NC} Added zsh configuration"
fi
echo ""

# ============================================================================
# Step 5: Verify PATH in current session
# ============================================================================
echo -e "${CYAN}[5/6]${NC} Verifying PATH..."
if echo "$PATH" | grep -q "$HOME/bin"; then
  echo -e "${GREEN}✓${NC} ~/bin is already in PATH for current session"
else
  echo -e "${YELLOW}→${NC} ~/bin not in current PATH (will be available after sourcing ~/.zshrc)"
fi
echo ""

# ============================================================================
# Step 6: Final summary
# ============================================================================
echo -e "${CYAN}[6/6]${NC} Installation complete!"
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Installation Summary${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Scripts installed:"
echo -e "  ${GREEN}✓${NC} ~/bin/devstack"
echo -e "  ${GREEN}✓${NC} ~/bin/tmux-send-to-children"
echo ""
echo -e "Configuration files updated:"
echo -e "  ${GREEN}✓${NC} ~/.tmux.conf"
echo -e "  ${GREEN}✓${NC} ~/.zshrc"
echo ""
echo -e "${CYAN}Next Steps:${NC}"
echo -e "  1. Source your zshrc to update PATH in current shell:"
echo -e "     ${YELLOW}source ~/.zshrc${NC}"
echo ""
echo -e "  2. If you're in a tmux session, reload tmux config:"
echo -e "     ${YELLOW}tmux source-file ~/.tmux.conf${NC}"
echo ""
echo -e "  3. Start using the control room:"
echo -e "     ${YELLOW}devstack${NC}          # Start without Claude CLI"
echo -e "     ${YELLOW}devstack --claude${NC}  # Start with Claude CLI auto-started"
echo ""
echo -e "${CYAN}Helper Commands:${NC}"
echo -e "  ${YELLOW}tmux-send-to-children \"command\"${NC}  # Send command to child panes only"
echo ""
echo -e "For more information, see ${CYAN}README.md${NC}"
echo ""
