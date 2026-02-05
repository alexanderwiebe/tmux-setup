#!/usr/bin/env bash
# Theme Comparison Tool
# Cycles through all available themes to help choose the best one

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

COLORS_FILE="$SCRIPT_DIR/config/colors.yaml"

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

# Get active theme
get_active_theme() {
  grep "^active_theme:" "$COLORS_FILE" | awk '{print $2}'
}

# Set active theme
set_active_theme() {
  local theme="$1"
  # Create backup
  cp "$COLORS_FILE" "${COLORS_FILE}.backup"
  # Update theme
  sed -i.tmp "s/^active_theme:.*/active_theme: $theme/" "$COLORS_FILE"
  rm "${COLORS_FILE}.tmp" 2>/dev/null || true
}

# Display theme info
show_theme_info() {
  local theme="$1"

  echo -e "${BOLD}Theme: ${CYAN}$theme${NC}"

  # Extract theme description
  local desc=$(awk "/^  $theme:/,/^  [a-z_]+:/" "$COLORS_FILE" | grep "description:" | sed 's/.*description: "\(.*\)"/\1/')
  if [ -n "$desc" ]; then
    echo -e "${desc}"
  fi

  # Extract color values
  local pane0=$(awk "/^  $theme:/,/^  [a-z_]+:/" "$COLORS_FILE" | grep "pane_0:" | awk '{print $2}')
  local pane1=$(awk "/^  $theme:/,/^  [a-z_]+:/" "$COLORS_FILE" | grep "pane_1:" | awk '{print $2}')
  local pane2=$(awk "/^  $theme:/,/^  [a-z_]+:/" "$COLORS_FILE" | grep "pane_2:" | awk '{print $2}')
  local pane3=$(awk "/^  $theme:/,/^  [a-z_]+:/" "$COLORS_FILE" | grep "pane_3:" | awk '{print $2}')

  echo ""
  echo -e "${BOLD}Colors:${NC}"
  echo -e "  Ancestor (pane 0): $pane0"
  echo -e "  Child 1 (pane 1):  $pane1"
  echo -e "  Child 2 (pane 2):  $pane2"
  echo -e "  Child 3 (pane 3):  $pane3"
  echo ""
}

# Available themes
THEMES=("default" "ocean" "forest" "fire" "purple" "monochrome" "cyberpunk")

main() {
  clear
  print_header "Theme Comparison Tool"

  local current_theme=$(get_active_theme)
  echo -e "${BOLD}Current active theme:${NC} ${CYAN}$current_theme${NC}"
  echo ""

  echo -e "${BOLD}Available themes:${NC}"
  echo ""

  local i=1
  for theme in "${THEMES[@]}"; do
    echo -e "  ${CYAN}$i${NC} - $theme"
    ((i++))
  done

  echo ""
  echo -e "${BOLD}Options:${NC}"
  echo -e "  ${CYAN}1-7${NC}   - View and apply theme"
  echo -e "  ${CYAN}a${NC}     - Auto-cycle through all themes"
  echo -e "  ${CYAN}r${NC}     - Restore original theme"
  echo -e "  ${CYAN}q${NC}     - Quit"
  echo ""

  read -p "Your choice: " choice

  case $choice in
    [1-7])
      local idx=$((choice - 1))
      local selected_theme="${THEMES[$idx]}"

      clear
      print_header "Theme Preview: $selected_theme"
      show_theme_info "$selected_theme"

      echo -e "${BOLD}Actions:${NC}"
      echo -e "  ${CYAN}a${NC} - Apply this theme"
      echo -e "  ${CYAN}t${NC} - Apply to test mode only"
      echo -e "  ${CYAN}b${NC} - Back to menu"
      echo ""

      read -p "Your choice: " action

      case $action in
        a)
          set_active_theme "$selected_theme"
          print_success "Theme set to: $selected_theme"
          echo ""
          echo -e "${YELLOW}Run './skills/install.sh' to apply changes${NC}"
          echo ""
          read -p "Press Enter to continue..."
          exec "$0"
          ;;
        t)
          set_active_theme "$selected_theme"
          print_success "Theme set to: $selected_theme"
          echo ""
          echo -e "${YELLOW}Run './skills/install.sh --test' to apply to test mode${NC}"
          echo ""
          read -p "Press Enter to continue..."
          exec "$0"
          ;;
        b)
          exec "$0"
          ;;
        *)
          print_error "Invalid choice"
          sleep 1
          exec "$0"
          ;;
      esac
      ;;
    a|A)
      # Auto-cycle through themes
      echo ""
      print_warning "Auto-cycling through themes (3 seconds each)..."
      echo -e "${CYAN}Press Ctrl+C to stop${NC}"
      echo ""
      sleep 2

      while true; do
        for theme in "${THEMES[@]}"; do
          clear
          print_header "Auto-Preview: $theme"
          show_theme_info "$theme"
          echo -e "${YELLOW}Press Ctrl+C to stop cycling${NC}"
          sleep 3
        done
      done
      ;;
    r|R)
      # Restore original
      if [ -f "${COLORS_FILE}.backup" ]; then
        mv "${COLORS_FILE}.backup" "$COLORS_FILE"
        print_success "Restored original theme"
      else
        print_warning "No backup found"
      fi
      echo ""
      read -p "Press Enter to continue..."
      exec "$0"
      ;;
    q|Q)
      echo ""
      print_success "Exiting theme comparison"
      exit 0
      ;;
    *)
      print_error "Invalid choice"
      sleep 1
      exec "$0"
      ;;
  esac
}

# Run main
main
