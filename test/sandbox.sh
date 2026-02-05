#!/usr/bin/env bash
# Test Sandbox Helper
# Activates test mode and starts a test session

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
  echo -e "${YELLOW}║       SANDBOX / TEST MODE              ║${NC}"
  echo -e "${YELLOW}║  Your production setup is safe         ║${NC}"
  echo -e "${YELLOW}╚════════════════════════════════════════╝${NC}"
  echo ""
}

# Main function
main() {
  print_test_banner
  print_header "Test Sandbox Activation"

  # Check if test-devstack is installed
  if [ ! -f "$HOME/bin/test-devstack" ]; then
    print_error "test-devstack not installed"
    echo ""
    echo -e "${BOLD}To install test mode:${NC}"
    echo -e "  ${YELLOW}cd $SCRIPT_DIR${NC}"
    echo -e "  ${YELLOW}./skills/install.sh --test${NC}"
    echo ""
    echo -e "Or for interactive setup:"
    echo -e "  ${YELLOW}./skills/install.sh --test --interactive${NC}"
    echo ""
    exit 1
  fi

  print_success "Test installation found"

  # Check if test config exists
  if [ ! -f "$HOME/.tmux-test.conf" ]; then
    print_warning "Test tmux config not found, using default"
  else
    print_success "Test tmux config: ~/.tmux-test.conf"
  fi

  echo ""
  echo -e "${BOLD}Test environment details:${NC}"
  echo -e "  Session name: ${CYAN}test-stack${NC}"
  echo -e "  Script: ${CYAN}~/bin/test-devstack${NC}"
  echo -e "  Config: ${CYAN}~/.tmux-test.conf${NC}"
  echo ""

  echo -e "${BOLD}Options:${NC}"
  echo -e "  ${CYAN}1${NC} - Start test session (basic)"
  echo -e "  ${CYAN}2${NC} - Start test session with Claude"
  echo -e "  ${CYAN}3${NC} - Start test session with custom tmux config"
  echo -e "  ${CYAN}4${NC} - Compare themes"
  echo -e "  ${CYAN}5${NC} - Clean up and exit"
  echo -e "  ${CYAN}q${NC} - Exit without starting"
  echo ""

  read -p "Your choice: " choice

  case $choice in
    1)
      echo ""
      print_success "Starting test session..."
      echo ""
      exec test-devstack
      ;;
    2)
      echo ""
      print_success "Starting test session with Claude..."
      echo ""
      exec test-devstack --claude
      ;;
    3)
      echo ""
      print_success "Starting test session with custom config..."
      echo ""
      if [ -f "$HOME/.tmux-test.conf" ]; then
        exec tmux -f "$HOME/.tmux-test.conf" attach -t test-stack || test-devstack
      else
        print_error "~/.tmux-test.conf not found"
        exit 1
      fi
      ;;
    4)
      echo ""
      print_success "Launching theme comparison..."
      echo ""
      if [ -f "$SCRIPT_DIR/test/compare-themes.sh" ]; then
        exec "$SCRIPT_DIR/test/compare-themes.sh"
      else
        print_error "compare-themes.sh not found"
        exit 1
      fi
      ;;
    5)
      echo ""
      print_warning "Launching cleanup..."
      echo ""
      exec "$SCRIPT_DIR/test/cleanup.sh"
      ;;
    q|Q)
      echo ""
      print_success "Exiting sandbox"
      exit 0
      ;;
    *)
      print_error "Invalid choice"
      exit 1
      ;;
  esac
}

# Run main function
main
