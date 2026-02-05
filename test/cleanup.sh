#!/usr/bin/env bash
# Test Devstack Cleanup Script
# Removes all test installation files and sessions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

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

# Main cleanup function
cleanup_test_installation() {
  print_header "Test Devstack Cleanup"

  echo -e "${YELLOW}This will remove:${NC}"
  echo "  - ~/bin/test-devstack"
  echo "  - ~/.tmux-test.conf"
  echo "  - Test tmux session (test-stack)"
  echo ""
  echo -e "${GREEN}Your production setup will NOT be affected:${NC}"
  echo "  - ~/bin/devstack (safe)"
  echo "  - ~/.tmux.conf (safe)"
  echo "  - Regular tmux sessions (safe)"
  echo ""

  read -p "Continue with cleanup? (y/N): " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo ""
    print_warning "Cleanup cancelled"
    exit 0
  fi

  echo ""

  # Kill test session if running
  if tmux has-session -t test-stack 2>/dev/null; then
    print_warning "Killing test-stack tmux session..."
    tmux kill-session -t test-stack 2>/dev/null || true
    print_success "Killed test-stack session"
  else
    print_warning "No test-stack session running"
  fi

  # Remove test-devstack script
  if [ -f "$HOME/bin/test-devstack" ]; then
    print_warning "Removing ~/bin/test-devstack..."
    rm "$HOME/bin/test-devstack"
    print_success "Removed test-devstack script"
  else
    print_warning "test-devstack script not found"
  fi

  # Remove test tmux config
  if [ -f "$HOME/.tmux-test.conf" ]; then
    print_warning "Removing ~/.tmux-test.conf..."
    rm "$HOME/.tmux-test.conf"
    print_success "Removed test tmux config"
  else
    print_warning "Test tmux config not found"
  fi

  # Remove generated test cleanup script if it exists
  if [ -f "$HOME/bin/test-devstack-cleanup" ]; then
    print_warning "Removing auto-generated cleanup script..."
    rm "$HOME/bin/test-devstack-cleanup"
    print_success "Removed auto-generated cleanup script"
  fi

  echo ""
  print_header "Cleanup Complete"

  echo -e "${GREEN}Test installation removed successfully!${NC}"
  echo ""
  echo -e "${BOLD}Your production setup is intact:${NC}"
  echo -e "  ${GREEN}✓${NC} ~/bin/devstack"
  echo -e "  ${GREEN}✓${NC} ~/.tmux.conf"
  echo -e "  ${GREEN}✓${NC} ~/.zshrc"
  echo ""
  echo -e "${BOLD}To install test mode again:${NC}"
  echo -e "  ${YELLOW}./skills/install.sh --test${NC}"
  echo ""
}

# Run cleanup
cleanup_test_installation
