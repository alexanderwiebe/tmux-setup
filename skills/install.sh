#!/usr/bin/env bash
# Tmux Control Room Interactive Installer
# Reads configuration from YAML files and generates customized scripts

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Default paths
CONFIG_FILE="$SCRIPT_DIR/config/setup.yaml"
COLORS_FILE="$SCRIPT_DIR/config/colors.yaml"
LAYOUTS_FILE="$SCRIPT_DIR/config/layouts.yaml"
DEFAULTS_FILE="$SCRIPT_DIR/config/defaults.yaml"
DEVSTACK_TEMPLATE="$SCRIPT_DIR/templates/devstack.template"
TMUX_CONF_TEMPLATE="$SCRIPT_DIR/templates/tmux.conf.template"

# Flags
INTERACTIVE=false
CUSTOM_CONFIG=""
TEST_MODE=false
DRY_RUN=false

# ============================================================================
# Utility Functions
# ============================================================================

print_header() {
  echo -e "${CYAN}========================================${NC}"
  echo -e "${CYAN}$1${NC}"
  echo -e "${CYAN}========================================${NC}"
  echo ""
}

print_step() {
  echo -e "${CYAN}[$1/$2]${NC} $3"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}→${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_test_banner() {
  echo -e "${YELLOW}╔════════════════════════════════════════╗${NC}"
  echo -e "${YELLOW}║          TEST MODE ACTIVE              ║${NC}"
  echo -e "${YELLOW}║  Your production setup is safe         ║${NC}"
  echo -e "${YELLOW}╚════════════════════════════════════════╝${NC}"
  echo ""
}

print_dry_run_banner() {
  echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
  echo -e "${CYAN}║         DRY RUN MODE                   ║${NC}"
  echo -e "${CYAN}║  No changes will be made               ║${NC}"
  echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
  echo ""
}

# Simple YAML parser for our specific structure
parse_yaml() {
  local file="$1"
  local prefix="$2"

  # Read YAML and convert to shell variables
  # This is a simplified parser for our specific YAML structure
  while IFS= read -r line; do
    # Skip comments and empty lines
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$line" ]] && continue

    # Parse key-value pairs
    if [[ "$line" =~ ^[[:space:]]*([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*:[[:space:]]*(.+)$ ]]; then
      local key="${BASH_REMATCH[1]}"
      local value="${BASH_REMATCH[2]}"

      # Remove quotes and trim
      value="${value#\"}"
      value="${value%\"}"
      value="${value#\'}"
      value="${value%\'}"

      # Export variable
      eval "${prefix}${key}='${value}'"
    fi
  done < "$file"
}

# Get value from YAML file
get_yaml_value() {
  local file="$1"
  local key_path="$2"

  # Use grep and awk to extract value
  # This is simplified - for production, use yq or python
  grep "^[[:space:]]*${key_path}:" "$file" | head -1 | awk -F': ' '{print $2}' | tr -d '"' | tr -d "'"
}

# Get active theme from colors.yaml
get_active_theme() {
  get_yaml_value "$COLORS_FILE" "active_theme"
}

# Get active layout from layouts.yaml
get_active_layout() {
  get_yaml_value "$LAYOUTS_FILE" "active_layout"
}

# ============================================================================
# Parse Command-line Arguments
# ============================================================================

parse_arguments() {
  for arg in "$@"; do
    case $arg in
      --interactive|-i)
        INTERACTIVE=true
        shift
        ;;
      --config=*)
        CUSTOM_CONFIG="${arg#*=}"
        shift
        ;;
      --test)
        TEST_MODE=true
        shift
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --help|-h)
        show_help
        exit 0
        ;;
      *)
        # Unknown argument
        ;;
    esac
  done

  # Use custom config if provided
  if [[ -n "$CUSTOM_CONFIG" ]]; then
    if [[ -f "$CUSTOM_CONFIG" ]]; then
      CONFIG_FILE="$CUSTOM_CONFIG"
    else
      print_error "Config file not found: $CUSTOM_CONFIG"
      exit 1
    fi
  fi
}

show_help() {
  cat <<EOF
${BOLD}Tmux Control Room Interactive Installer${NC}

${BOLD}USAGE:${NC}
  ./install.sh [OPTIONS]

${BOLD}OPTIONS:${NC}
  -i, --interactive       Run in interactive mode (prompt for customization)
  --config=PATH           Use custom configuration file
  --test                  Install in test mode (safe sandbox, no production changes)
  --dry-run               Show what would be installed without making changes
  -h, --help              Show this help message

${BOLD}EXAMPLES:${NC}
  ./install.sh                           # Quick install with default config
  ./install.sh --interactive             # Interactive setup with prompts
  ./install.sh --config=my-config.yaml   # Use custom config file
  ./install.sh --test --interactive      # Test installation (safe to experiment)
  ./install.sh --dry-run                 # Preview changes without installing

${BOLD}CONFIGURATION:${NC}
  Default config: config/setup.yaml
  Color themes:   config/colors.yaml
  Layouts:        config/layouts.yaml

${BOLD}WHAT IT DOES:${NC}
  1. Reads your configuration from YAML files
  2. Generates customized scripts from templates
  3. Installs scripts to ~/bin
  4. Updates ~/.tmux.conf and ~/.zshrc
  5. Creates backups of existing files

${BOLD}TEST MODE:${NC}
  Test mode uses separate files so your production setup is safe:
  - Session name: test-stack (instead of aj-stack)
  - Script: ~/bin/test-devstack (instead of ~/bin/devstack)
  - Tmux config: ~/.tmux-test.conf (instead of ~/.tmux.conf)
  - No .zshrc modifications (PATH already has ~/bin)
  Run ./test/cleanup.sh to remove test installation

${BOLD}DRY RUN MODE:${NC}
  Dry run shows exactly what would be installed without making any changes.
  Use this to preview configurations before actual installation.

EOF
}

# ============================================================================
# Interactive Configuration
# ============================================================================

interactive_setup() {
  print_header "Interactive Configuration"

  echo -e "${BOLD}Current configuration:${NC}"
  echo -e "  Config file: ${CYAN}$CONFIG_FILE${NC}"
  echo -e "  Theme: ${CYAN}$(get_active_theme)${NC}"
  echo -e "  Layout: ${CYAN}$(get_active_layout)${NC}"
  echo ""

  read -p "Do you want to customize the configuration? (y/N): " customize
  if [[ "$customize" =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${YELLOW}Opening customization helper...${NC}"
    echo -e "${YELLOW}(This would launch customize.sh - not yet implemented)${NC}"
    echo ""
    read -p "Press Enter to continue with current configuration..."
  fi

  echo ""
}

# ============================================================================
# Configuration Loading
# ============================================================================

load_configuration() {
  print_step "1" "8" "Loading configuration..."

  # Check if config files exist
  if [[ ! -f "$CONFIG_FILE" ]]; then
    print_error "Configuration file not found: $CONFIG_FILE"
    exit 1
  fi

  if [[ ! -f "$COLORS_FILE" ]]; then
    print_error "Colors file not found: $COLORS_FILE"
    exit 1
  fi

  if [[ ! -f "$LAYOUTS_FILE" ]]; then
    print_error "Layouts file not found: $LAYOUTS_FILE"
    exit 1
  fi

  # Load active theme and layout
  ACTIVE_THEME=$(get_active_theme)
  ACTIVE_LAYOUT=$(get_active_layout)

  print_success "Loaded configuration: $CONFIG_FILE"
  print_success "Active theme: $ACTIVE_THEME"
  print_success "Active layout: $ACTIVE_LAYOUT"
  echo ""
}

# ============================================================================
# Template Processing
# ============================================================================

process_devstack_template() {
  print_step "2" "8" "Generating devstack script from template..."

  # Extract values from YAML (simplified - in production use proper YAML parser)
  local session_name=$(get_yaml_value "$CONFIG_FILE" "name" | grep -A1 "^session:" | tail -1 | awk '{print $2}')
  local window_name=$(get_yaml_value "$CONFIG_FILE" "window" | grep -A1 "^session:" | tail -1 | awk '{print $2}')
  local ancestor_path=$(get_yaml_value "$CONFIG_FILE" "path" | grep -A1 "^ancestor:" | tail -1 | awk '{print $2}')
  local ancestor_name=$(get_yaml_value "$CONFIG_FILE" "name" | grep -A1 "^ancestor:" | tail -1 | awk '{print $2}')

  # Override session name in test mode
  if [[ "$TEST_MODE" == true ]]; then
    session_name="test-stack"
    print_warning "Test mode: Using session name 'test-stack'"
  fi

  # Copy and modify devstack script
  cp "$SCRIPT_DIR/bin/devstack" "$SCRIPT_DIR/bin/devstack.generated"

  # Replace session name in the generated script if test mode
  if [[ "$TEST_MODE" == true ]]; then
    sed -i.tmp "s/SESSION_NAME=\"[^\"]*\"/SESSION_NAME=\"test-stack\"/" "$SCRIPT_DIR/bin/devstack.generated"
    rm "$SCRIPT_DIR/bin/devstack.generated.tmp" 2>/dev/null || true
  fi

  print_success "Generated devstack script"
  if [[ "$TEST_MODE" == true ]]; then
    print_success "Configured for test session: test-stack"
  fi
  echo ""
}

process_tmux_conf_template() {
  print_step "3" "8" "Generating tmux.conf from template..."

  # Get theme colors
  # In production, properly parse YAML theme section

  # For now, use existing tmux.conf.additions
  cp "$SCRIPT_DIR/config/tmux.conf.additions" "$SCRIPT_DIR/config/tmux.conf.generated"

  print_success "Generated tmux.conf additions"
  echo ""
}

# ============================================================================
# Installation Steps
# ============================================================================

create_bin_directory() {
  print_step "4" "8" "Creating ~/bin directory..."

  if [[ "$DRY_RUN" == true ]]; then
    if [ ! -d "$HOME/bin" ]; then
      print_warning "[DRY RUN] Would create: $HOME/bin"
    else
      print_warning "[DRY RUN] Directory exists: $HOME/bin"
    fi
  else
    if [ ! -d "$HOME/bin" ]; then
      mkdir -p "$HOME/bin"
      print_success "Created $HOME/bin"
    else
      print_warning "$HOME/bin already exists"
    fi
  fi
  echo ""
}

install_scripts() {
  print_step "5" "8" "Installing scripts to ~/bin..."

  # Use generated script if available, otherwise use original
  local devstack_source="$SCRIPT_DIR/bin/devstack"
  if [[ -f "$SCRIPT_DIR/bin/devstack.generated" ]]; then
    devstack_source="$SCRIPT_DIR/bin/devstack.generated"
  fi

  # Determine script name based on test mode
  local script_name="devstack"
  if [[ "$TEST_MODE" == true ]]; then
    script_name="test-devstack"
  fi

  if [[ "$DRY_RUN" == true ]]; then
    print_warning "[DRY RUN] Would install: $devstack_source -> $HOME/bin/$script_name"
    print_warning "[DRY RUN] Would install: $SCRIPT_DIR/bin/tmux-send-to-children -> $HOME/bin/"
    echo ""
    echo -e "${CYAN}Preview of $script_name:${NC}"
    head -20 "$devstack_source"
    echo "..."
  else
    cp "$devstack_source" "$HOME/bin/$script_name"
    cp "$SCRIPT_DIR/bin/tmux-send-to-children" "$HOME/bin/"
    chmod +x "$HOME/bin/$script_name"
    chmod +x "$HOME/bin/tmux-send-to-children"

    print_success "Installed $script_name"
    print_success "Installed tmux-send-to-children"

    if [[ "$TEST_MODE" == true ]]; then
      print_warning "Test mode: Use 'test-devstack' to start test session"
    fi
  fi
  echo ""
}

update_tmux_conf() {
  local tmux_conf_file="$HOME/.tmux.conf"
  local step_desc="Configuring ~/.tmux.conf..."

  if [[ "$TEST_MODE" == true ]]; then
    tmux_conf_file="$HOME/.tmux-test.conf"
    step_desc="Configuring ~/.tmux-test.conf (test mode)..."
  fi

  print_step "6" "8" "$step_desc"

  local timestamp=$(date +%Y%m%d_%H%M%S)

  # Use generated config if available, otherwise use original
  local tmux_conf_source="$SCRIPT_DIR/config/tmux.conf.additions"
  if [[ -f "$SCRIPT_DIR/config/tmux.conf.generated" ]]; then
    tmux_conf_source="$SCRIPT_DIR/config/tmux.conf.generated"
  fi

  if [[ "$DRY_RUN" == true ]]; then
    print_warning "[DRY RUN] Would configure: $tmux_conf_file"
    echo ""
    echo -e "${CYAN}Preview of tmux configuration:${NC}"
    head -20 "$tmux_conf_source"
    echo "..."
  else
    # Check if .tmux.conf exists
    if [ ! -f "$tmux_conf_file" ]; then
      print_warning "$tmux_conf_file doesn't exist, creating new file"
      touch "$tmux_conf_file"
    fi

    # Check if our additions are already present
    if grep -q "Tmux Control Room" "$tmux_conf_file"; then
      print_warning "tmux.conf additions already present, skipping"
    else
      # Backup existing config (not for test mode if file is new)
      if [[ -s "$tmux_conf_file" ]]; then
        local backup_file="${tmux_conf_file}.backup-$timestamp"
        cp "$tmux_conf_file" "$backup_file"
        print_success "Backed up to $backup_file"
      fi

      # Append additions
      echo "" >> "$tmux_conf_file"
      echo "# ============================================================================" >> "$tmux_conf_file"
      if [[ "$TEST_MODE" == true ]]; then
        echo "# Tmux Control Room Setup (TEST MODE) - Added by install.sh on $(date)" >> "$tmux_conf_file"
      else
        echo "# Tmux Control Room Setup - Added by install.sh on $(date)" >> "$tmux_conf_file"
      fi
      echo "# ============================================================================" >> "$tmux_conf_file"

      cat "$tmux_conf_source" >> "$tmux_conf_file"
      print_success "Added tmux configuration to $tmux_conf_file"
    fi
  fi
  echo ""
}

update_zshrc() {
  if [[ "$TEST_MODE" == true ]]; then
    print_step "7" "8" "Skipping ~/.zshrc (test mode, PATH already configured)..."
    print_warning "Test mode: Not modifying ~/.zshrc"
    echo ""
    return
  fi

  print_step "7" "8" "Configuring ~/.zshrc..."

  if [[ "$DRY_RUN" == true ]]; then
    print_warning "[DRY RUN] Would configure: ~/.zshrc"
    echo ""
    echo -e "${CYAN}Preview of zshrc additions:${NC}"
    cat "$SCRIPT_DIR/config/zshrc.additions"
    echo ""
    return
  fi

  local timestamp=$(date +%Y%m%d_%H%M%S)

  # Check if .zshrc exists
  if [ ! -f "$HOME/.zshrc" ]; then
    print_warning "~/.zshrc doesn't exist, creating new file"
    touch "$HOME/.zshrc"
  fi

  # Check if ~/bin is already in PATH in .zshrc
  if grep -q 'export PATH=.*\$HOME/bin' "$HOME/.zshrc" || grep -q 'export PATH=.*~/bin' "$HOME/.zshrc"; then
    print_warning "~/bin already in PATH in .zshrc, skipping"
  else
    # Backup existing config
    local backup_file="$HOME/.zshrc.backup-$timestamp"
    cp "$HOME/.zshrc" "$backup_file"
    print_success "Backed up to $backup_file"

    # Append additions
    echo "" >> "$HOME/.zshrc"
    echo "# ============================================================================" >> "$HOME/.zshrc"
    echo "# Tmux Control Room Setup - Added by install.sh on $(date)" >> "$HOME/.zshrc"
    echo "# ============================================================================" >> "$HOME/.zshrc"
    cat "$SCRIPT_DIR/config/zshrc.additions" >> "$HOME/.zshrc"
    print_success "Added zsh configuration"
  fi
  echo ""
}

# ============================================================================
# Test Mode Cleanup Script Generation
# ============================================================================

create_test_cleanup_script() {
  local cleanup_script="$HOME/bin/test-devstack-cleanup"

  cat > "$cleanup_script" <<'EOF'
#!/usr/bin/env bash
# Test Devstack Cleanup Script
# Generated by install.sh --test
# This script removes test installation files

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Test Devstack Cleanup${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

echo -e "${YELLOW}This will remove:${NC}"
echo "  - ~/bin/test-devstack"
echo "  - ~/.tmux-test.conf"
echo "  - Test tmux session (if running)"
echo ""
echo -e "${GREEN}Your production setup will not be affected.${NC}"
echo ""

read -p "Continue? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 0
fi

echo ""

# Kill test session if running
if tmux has-session -t test-stack 2>/dev/null; then
  echo -e "${YELLOW}Killing test-stack tmux session...${NC}"
  tmux kill-session -t test-stack
  echo -e "${GREEN}✓${NC} Killed test-stack session"
fi

# Remove test-devstack script
if [ -f "$HOME/bin/test-devstack" ]; then
  echo -e "${YELLOW}Removing ~/bin/test-devstack...${NC}"
  rm "$HOME/bin/test-devstack"
  echo -e "${GREEN}✓${NC} Removed test-devstack"
fi

# Remove test tmux config
if [ -f "$HOME/.tmux-test.conf" ]; then
  echo -e "${YELLOW}Removing ~/.tmux-test.conf...${NC}"
  rm "$HOME/.tmux-test.conf"
  echo -e "${GREEN}✓${NC} Removed .tmux-test.conf"
fi

# Remove this cleanup script
if [ -f "$HOME/bin/test-devstack-cleanup" ]; then
  echo -e "${YELLOW}Removing cleanup script...${NC}"
  rm "$HOME/bin/test-devstack-cleanup"
  echo -e "${GREEN}✓${NC} Removed cleanup script"
fi

echo ""
echo -e "${GREEN}Test installation cleaned up successfully!${NC}"
echo ""
EOF

  chmod +x "$cleanup_script"
  print_success "Created cleanup script: $cleanup_script"
}

# ============================================================================
# Final Summary
# ============================================================================

show_summary() {
  if [[ "$DRY_RUN" == true ]]; then
    print_step "8" "8" "Dry run complete!"
    echo ""
    print_header "Dry Run Summary"
    echo -e "${CYAN}No changes were made to your system.${NC}"
    echo ""
    echo -e "${BOLD}To install for real:${NC}"
    echo -e "   ${YELLOW}$SCRIPT_DIR/skills/install.sh${NC}          # Production install"
    echo -e "   ${YELLOW}$SCRIPT_DIR/skills/install.sh --test${NC}   # Test install (safe)"
    echo ""
    return
  fi

  print_step "8" "8" "Installation complete!"
  echo ""

  if [[ "$TEST_MODE" == true ]]; then
    print_test_banner
  fi

  print_header "Installation Summary"

  echo -e "${BOLD}Configuration:${NC}"
  echo -e "  Theme: ${CYAN}$ACTIVE_THEME${NC}"
  echo -e "  Layout: ${CYAN}$ACTIVE_LAYOUT${NC}"
  echo -e "  Config: ${CYAN}$CONFIG_FILE${NC}"
  if [[ "$TEST_MODE" == true ]]; then
    echo -e "  Mode: ${YELLOW}TEST MODE${NC}"
  fi
  echo ""

  echo -e "${BOLD}Scripts installed:${NC}"
  if [[ "$TEST_MODE" == true ]]; then
    echo -e "  ${GREEN}✓${NC} ~/bin/test-devstack"
  else
    echo -e "  ${GREEN}✓${NC} ~/bin/devstack"
  fi
  echo -e "  ${GREEN}✓${NC} ~/bin/tmux-send-to-children"
  echo ""

  echo -e "${BOLD}Configuration files updated:${NC}"
  if [[ "$TEST_MODE" == true ]]; then
    echo -e "  ${GREEN}✓${NC} ~/.tmux-test.conf"
    echo -e "  ${YELLOW}→${NC} ~/.zshrc (not modified in test mode)"
  else
    echo -e "  ${GREEN}✓${NC} ~/.tmux.conf"
    echo -e "  ${GREEN}✓${NC} ~/.zshrc"
  fi
  echo ""

  print_header "Next Steps"

  if [[ "$TEST_MODE" == true ]]; then
    echo -e "${BOLD}1. Start your test session:${NC}"
    echo -e "   ${YELLOW}test-devstack${NC}                    # Start test session"
    echo -e "   ${YELLOW}./test/sandbox.sh${NC}                # Or use sandbox helper"
    echo ""

    echo -e "${BOLD}2. Load tmux test configuration:${NC}"
    echo -e "   ${YELLOW}tmux -f ~/.tmux-test.conf${NC}"
    echo ""

    echo -e "${BOLD}3. Try different themes:${NC}"
    echo -e "   ${YELLOW}./test/compare-themes.sh${NC}         # Preview all themes"
    echo -e "   ${YELLOW}./skills/customize.sh --test${NC}     # Change test config"
    echo ""

    echo -e "${BOLD}4. Clean up when done:${NC}"
    echo -e "   ${YELLOW}./test/cleanup.sh${NC}                # Remove test installation"
    echo ""

    echo -e "${BOLD}5. Install for production:${NC}"
    echo -e "   ${YELLOW}./skills/install.sh${NC}              # Install production setup"
    echo ""
  else
    echo -e "${BOLD}1. Update your shell environment:${NC}"
    echo -e "   ${YELLOW}source ~/.zshrc${NC}"
    echo ""

    echo -e "${BOLD}2. If in tmux, reload configuration:${NC}"
    echo -e "   ${YELLOW}tmux source-file ~/.tmux.conf${NC}"
    echo ""

    echo -e "${BOLD}3. Start your control room:${NC}"
    echo -e "   ${YELLOW}devstack${NC}          # Basic start"
    echo -e "   ${YELLOW}devstack --claude${NC}  # With Claude CLI"
    echo ""

    echo -e "${BOLD}4. Customize further:${NC}"
    echo -e "   ${YELLOW}$SCRIPT_DIR/skills/customize.sh${NC}"
    echo ""
  fi

  echo -e "For more information, see ${CYAN}$SCRIPT_DIR/README.md${NC}"
  echo ""
}

# ============================================================================
# Main Installation Flow
# ============================================================================

main() {
  # Parse arguments
  parse_arguments "$@"

  print_header "Tmux Control Room Setup - Installation"

  # Show mode banners
  if [[ "$DRY_RUN" == true ]]; then
    print_dry_run_banner
  elif [[ "$TEST_MODE" == true ]]; then
    print_test_banner
  fi

  # Interactive setup if requested
  if [[ "$INTERACTIVE" == true ]]; then
    interactive_setup
  fi

  # Run installation steps
  load_configuration
  process_devstack_template
  process_tmux_conf_template
  create_bin_directory
  install_scripts
  update_tmux_conf
  update_zshrc

  # Create test cleanup script if in test mode
  if [[ "$TEST_MODE" == true && "$DRY_RUN" == false ]]; then
    create_test_cleanup_script
  fi

  show_summary
}

# Run main function
main "$@"
