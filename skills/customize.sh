#!/usr/bin/env bash
# Tmux Control Room Customization Helper
# Interactive tool for modifying configuration

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Configuration files
SETUP_FILE="$SCRIPT_DIR/config/setup.yaml"
COLORS_FILE="$SCRIPT_DIR/config/colors.yaml"
LAYOUTS_FILE="$SCRIPT_DIR/config/layouts.yaml"

# Test mode flag
TEST_MODE=false

# Parse command line arguments
for arg in "$@"; do
  case $arg in
    --test)
      TEST_MODE=true
      shift
      ;;
  esac
done

# ============================================================================
# Utility Functions
# ============================================================================

print_header() {
  echo -e "${CYAN}========================================${NC}"
  echo -e "${CYAN}$1${NC}"
  echo -e "${CYAN}========================================${NC}"
  echo ""
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
  echo -e "${YELLOW}║  Changes for test installation only    ║${NC}"
  echo -e "${YELLOW}╚════════════════════════════════════════╝${NC}"
  echo ""
}

get_yaml_value() {
  local file="$1"
  local key="$2"
  grep "^[[:space:]]*${key}:" "$file" | head -1 | awk -F': ' '{print $2}' | tr -d '"' | tr -d "'"
}

set_yaml_value() {
  local file="$1"
  local key="$2"
  local value="$3"

  # Create backup
  cp "$file" "${file}.backup"

  # Replace value (simplified - in production use proper YAML editor)
  if grep -q "^[[:space:]]*${key}:" "$file"; then
    sed -i.tmp "s/^\\([[:space:]]*${key}:\\).*/\\1 ${value}/" "$file"
    rm "${file}.tmp"
    print_success "Updated $key to $value"
  else
    print_error "Key '$key' not found in $file"
    return 1
  fi
}

# ============================================================================
# Menu Functions
# ============================================================================

show_main_menu() {
  clear
  if [[ "$TEST_MODE" == true ]]; then
    print_test_banner
  fi

  print_header "Tmux Control Room Customization"

  if [[ "$TEST_MODE" == true ]]; then
    echo -e "${YELLOW}Mode: TEST${NC}"
    echo -e "${YELLOW}Apply changes with: ./skills/install.sh --test${NC}"
    echo ""
  fi

  echo -e "${BOLD}What would you like to customize?${NC}"
  echo ""
  echo -e "  ${CYAN}1${NC} - Change color theme"
  echo -e "  ${CYAN}2${NC} - Change layout"
  echo -e "  ${CYAN}3${NC} - Manage repositories"
  echo -e "  ${CYAN}4${NC} - Toggle features"
  echo -e "  ${CYAN}5${NC} - View current configuration"
  echo -e "  ${CYAN}6${NC} - Create custom theme"
  echo -e "  ${CYAN}q${NC} - Quit"
  echo ""
}

# ============================================================================
# Theme Customization
# ============================================================================

customize_theme() {
  clear
  print_header "Color Theme Selection"

  local current_theme=$(get_yaml_value "$COLORS_FILE" "active_theme")
  echo -e "${BOLD}Current theme:${NC} ${CYAN}$current_theme${NC}"
  echo ""

  echo -e "${BOLD}Available themes:${NC}"
  echo ""
  echo -e "  ${CYAN}1${NC} - default     (Gold, Blue, Green, Magenta)"
  echo -e "  ${CYAN}2${NC} - ocean       (Aquatic blues and cyans)"
  echo -e "  ${CYAN}3${NC} - forest      (Nature greens with gold)"
  echo -e "  ${CYAN}4${NC} - fire        (Warm reds, oranges, yellows)"
  echo -e "  ${CYAN}5${NC} - purple      (Royal purples and magentas)"
  echo -e "  ${CYAN}6${NC} - monochrome  (Grayscale for focus)"
  echo -e "  ${CYAN}7${NC} - cyberpunk   (Neon colors)"
  echo ""
  echo -e "  ${CYAN}0${NC} - Back to main menu"
  echo ""

  read -p "Select theme (1-7, 0 to cancel): " choice

  case $choice in
    1) set_yaml_value "$COLORS_FILE" "active_theme" "default" ;;
    2) set_yaml_value "$COLORS_FILE" "active_theme" "ocean" ;;
    3) set_yaml_value "$COLORS_FILE" "active_theme" "forest" ;;
    4) set_yaml_value "$COLORS_FILE" "active_theme" "fire" ;;
    5) set_yaml_value "$COLORS_FILE" "active_theme" "purple" ;;
    6) set_yaml_value "$COLORS_FILE" "active_theme" "monochrome" ;;
    7) set_yaml_value "$COLORS_FILE" "active_theme" "cyberpunk" ;;
    0) return ;;
    *)
      print_error "Invalid choice"
      sleep 2
      return
      ;;
  esac

  echo ""
  if [[ "$TEST_MODE" == true ]]; then
    print_success "Theme updated! Run './skills/install.sh --test' to apply changes."
  else
    print_success "Theme updated! Run './skills/install.sh' to apply changes."
  fi
  echo ""
  read -p "Press Enter to continue..."
}

# ============================================================================
# Layout Customization
# ============================================================================

customize_layout() {
  clear
  print_header "Layout Selection"

  local current_layout=$(get_yaml_value "$LAYOUTS_FILE" "active_layout")
  echo -e "${BOLD}Current layout:${NC} ${CYAN}$current_layout${NC}"
  echo ""

  echo -e "${BOLD}Available layouts:${NC}"
  echo ""
  echo -e "  ${CYAN}1${NC} - main-horizontal  (Large top, three bottom)"
  echo -e "  ${CYAN}2${NC} - tiled            (2x2 grid)"
  echo -e "  ${CYAN}3${NC} - main-vertical    (Large left, three right)"
  echo -e "  ${CYAN}4${NC} - even-horizontal  (Four stacked)"
  echo -e "  ${CYAN}5${NC} - even-vertical    (Four side-by-side)"
  echo ""
  echo -e "  ${CYAN}0${NC} - Back to main menu"
  echo ""

  read -p "Select layout (1-5, 0 to cancel): " choice

  case $choice in
    1) set_yaml_value "$LAYOUTS_FILE" "active_layout" "main-horizontal" ;;
    2) set_yaml_value "$LAYOUTS_FILE" "active_layout" "tiled" ;;
    3) set_yaml_value "$LAYOUTS_FILE" "active_layout" "main-vertical" ;;
    4) set_yaml_value "$LAYOUTS_FILE" "active_layout" "even-horizontal" ;;
    5) set_yaml_value "$LAYOUTS_FILE" "active_layout" "even-vertical" ;;
    0) return ;;
    *)
      print_error "Invalid choice"
      sleep 2
      return
      ;;
  esac

  echo ""
  if [[ "$TEST_MODE" == true ]]; then
    print_success "Layout updated! Run './skills/install.sh --test' to apply changes."
  else
    print_success "Layout updated! Run './skills/install.sh' to apply changes."
  fi
  echo ""
  read -p "Press Enter to continue..."
}

# ============================================================================
# Repository Management
# ============================================================================

manage_repositories() {
  clear
  print_header "Repository Management"

  echo -e "${BOLD}Current repositories:${NC}"
  echo ""

  # Display current repos (simplified extraction)
  echo -e "${CYAN}Ancestor:${NC}"
  grep -A2 "ancestor:" "$SETUP_FILE" | grep "path:" | awk '{print "  " $2}'
  echo ""

  echo -e "${CYAN}Children:${NC}"
  grep -A20 "children:" "$SETUP_FILE" | grep "path:" | awk '{print "  " $2}'
  echo ""

  echo -e "${BOLD}Options:${NC}"
  echo -e "  ${CYAN}1${NC} - Add child repository"
  echo -e "  ${CYAN}2${NC} - Remove child repository"
  echo -e "  ${CYAN}3${NC} - Change ancestor repository"
  echo -e "  ${CYAN}0${NC} - Back to main menu"
  echo ""

  read -p "Select option (1-3, 0 to cancel): " choice

  case $choice in
    1) add_repository ;;
    2) remove_repository ;;
    3) change_ancestor ;;
    0) return ;;
    *)
      print_error "Invalid choice"
      sleep 2
      ;;
  esac
}

add_repository() {
  echo ""
  echo -e "${BOLD}Add Child Repository${NC}"
  echo ""

  read -p "Repository path (e.g., ~/dev/my-project): " repo_path
  read -p "Repository name: " repo_name
  read -p "Label (default: CHILD): " label
  label=${label:-CHILD}

  echo ""
  print_warning "Manual edit required to add repository."
  print_warning "Edit $SETUP_FILE and add under 'children:':"
  echo ""
  echo -e "${CYAN}    - path: $repo_path${NC}"
  echo -e "${CYAN}      name: $repo_name${NC}"
  echo -e "${CYAN}      label: $label${NC}"
  echo ""
  read -p "Press Enter to continue..."
}

remove_repository() {
  echo ""
  print_warning "Manual edit required to remove repository."
  print_warning "Edit $SETUP_FILE and remove the repository entry."
  echo ""
  read -p "Press Enter to continue..."
}

change_ancestor() {
  echo ""
  echo -e "${BOLD}Change Ancestor Repository${NC}"
  echo ""

  read -p "New ancestor path (e.g., ~/dev/my-ancestor): " repo_path
  read -p "Repository name: " repo_name

  echo ""
  print_warning "Manual edit required to change ancestor."
  print_warning "Edit $SETUP_FILE and update the 'ancestor:' section."
  echo ""
  read -p "Press Enter to continue..."
}

# ============================================================================
# Feature Toggles
# ============================================================================

toggle_features() {
  clear
  print_header "Feature Toggles"

  echo -e "${BOLD}Current features:${NC}"
  echo ""

  # Extract feature values (simplified)
  local auto_claude=$(grep -A10 "^features:" "$SETUP_FILE" | grep "auto_start_claude:" | awk '{print $2}')
  local colored_borders=$(grep -A10 "^features:" "$SETUP_FILE" | grep "colored_borders:" | awk '{print $2}')
  local check_remotes=$(grep -A10 "^features:" "$SETUP_FILE" | grep "check_git_remotes:" | awk '{print $2}')

  echo -e "  ${CYAN}1${NC} - Auto-start Claude CLI:     ${YELLOW}$auto_claude${NC}"
  echo -e "  ${CYAN}2${NC} - Colored borders:            ${YELLOW}$colored_borders${NC}"
  echo -e "  ${CYAN}3${NC} - Check git remotes:          ${YELLOW}$check_remotes${NC}"
  echo ""
  echo -e "  ${CYAN}0${NC} - Back to main menu"
  echo ""

  read -p "Toggle feature (1-3, 0 to cancel): " choice

  case $choice in
    1)
      if [[ "$auto_claude" == "false" ]]; then
        toggle_feature "auto_start_claude" "true"
      else
        toggle_feature "auto_start_claude" "false"
      fi
      ;;
    2)
      if [[ "$colored_borders" == "false" ]]; then
        toggle_feature "colored_borders" "true"
      else
        toggle_feature "colored_borders" "false"
      fi
      ;;
    3)
      if [[ "$check_remotes" == "false" ]]; then
        toggle_feature "check_git_remotes" "true"
      else
        toggle_feature "check_git_remotes" "false"
      fi
      ;;
    0) return ;;
    *)
      print_error "Invalid choice"
      sleep 2
      return
      ;;
  esac

  echo ""
  if [[ "$TEST_MODE" == true ]]; then
    print_success "Feature toggled! Run './skills/install.sh --test' to apply changes."
  else
    print_success "Feature toggled! Run './skills/install.sh' to apply changes."
  fi
  echo ""
  read -p "Press Enter to continue..."
}

toggle_feature() {
  local feature="$1"
  local value="$2"

  # Use sed to toggle value (simplified)
  sed -i.tmp "s/^\\([[:space:]]*${feature}:\\).*/\\1 ${value}/" "$SETUP_FILE"
  rm "${SETUP_FILE}.tmp"
}

# ============================================================================
# View Configuration
# ============================================================================

view_configuration() {
  clear
  print_header "Current Configuration"

  echo -e "${BOLD}Theme:${NC} ${CYAN}$(get_yaml_value "$COLORS_FILE" "active_theme")${NC}"
  echo -e "${BOLD}Layout:${NC} ${CYAN}$(get_yaml_value "$LAYOUTS_FILE" "active_layout")${NC}"
  echo ""

  echo -e "${BOLD}Session:${NC}"
  grep -A5 "^session:" "$SETUP_FILE" | sed 's/^/  /'
  echo ""

  echo -e "${BOLD}Features:${NC}"
  grep -A10 "^features:" "$SETUP_FILE" | sed 's/^/  /'
  echo ""

  echo -e "${BOLD}Repositories:${NC}"
  echo -e "${CYAN}Ancestor:${NC}"
  grep -A3 "ancestor:" "$SETUP_FILE" | grep -E "path:|name:" | sed 's/^/  /'
  echo ""

  echo -e "${CYAN}Children:${NC}"
  grep -A20 "children:" "$SETUP_FILE" | grep -E "path:|name:" | sed 's/^/  /'
  echo ""

  read -p "Press Enter to continue..."
}

# ============================================================================
# Create Custom Theme
# ============================================================================

create_custom_theme() {
  clear
  print_header "Create Custom Theme"

  echo -e "${BOLD}Creating a custom theme${NC}"
  echo ""

  read -p "Theme name: " theme_name
  read -p "Description: " description
  echo ""

  echo -e "${BOLD}Enter colors (0-255):${NC}"
  read -p "Pane 0 (ancestor) color: " pane0
  read -p "Pane 1 (child 1) color: " pane1
  read -p "Pane 2 (child 2) color: " pane2
  read -p "Pane 3 (child 3) color: " pane3
  echo ""

  print_warning "Manual edit required to add custom theme."
  print_warning "Edit $COLORS_FILE and add:"
  echo ""
  echo -e "${CYAN}  $theme_name:${NC}"
  echo -e "${CYAN}    name: \"$theme_name\"${NC}"
  echo -e "${CYAN}    description: \"$description\"${NC}"
  echo -e "${CYAN}    pane_0: colour$pane0${NC}"
  echo -e "${CYAN}    pane_1: colour$pane1${NC}"
  echo -e "${CYAN}    pane_2: colour$pane2${NC}"
  echo -e "${CYAN}    pane_3: colour$pane3${NC}"
  echo -e "${CYAN}    active_border: brightcyan${NC}"
  echo -e "${CYAN}    inactive_border: colour240${NC}"
  echo -e "${CYAN}    status_bg: colour234${NC}"
  echo -e "${CYAN}    status_fg: colour255${NC}"
  echo ""

  read -p "Press Enter to continue..."
}

# ============================================================================
# Main Menu Loop
# ============================================================================

main() {
  while true; do
    show_main_menu

    read -p "Your choice: " choice

    case $choice in
      1) customize_theme ;;
      2) customize_layout ;;
      3) manage_repositories ;;
      4) toggle_features ;;
      5) view_configuration ;;
      6) create_custom_theme ;;
      q|Q)
        echo ""
        print_success "Goodbye!"
        exit 0
        ;;
      *)
        print_error "Invalid choice"
        sleep 1
        ;;
    esac
  done
}

# Run main function
main
