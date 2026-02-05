#!/usr/bin/env bash
# Test script to validate tmux-setup installation
# Run this after installation to verify everything works

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

ERRORS=0

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Tmux Control Room - Installation Test${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Test 1: Check directory structure
echo -e "${CYAN}[1/10] Checking directory structure...${NC}"
if [[ -d "config" && -d "skills" && -d "templates" && -d "bin" ]]; then
  echo -e "${GREEN}✓${NC} All directories present"
else
  echo -e "${RED}✗${NC} Missing directories"
  ERRORS=$((ERRORS + 1))
fi

# Test 2: Check configuration files
echo -e "${CYAN}[2/10] Checking configuration files...${NC}"
CONFIG_FILES=("config/setup.yaml" "config/colors.yaml" "config/layouts.yaml" "config/defaults.yaml")
for file in "${CONFIG_FILES[@]}"; do
  if [[ -f "$file" ]]; then
    echo -e "${GREEN}✓${NC} Found $file"
  else
    echo -e "${RED}✗${NC} Missing $file"
    ERRORS=$((ERRORS + 1))
  fi
done

# Test 3: Check skill manifest
echo -e "${CYAN}[3/10] Checking Claude skill manifest...${NC}"
if [[ -f "claude.json" ]]; then
  echo -e "${GREEN}✓${NC} Found claude.json"
else
  echo -e "${RED}✗${NC} Missing claude.json"
  ERRORS=$((ERRORS + 1))
fi

# Test 4: Check template files
echo -e "${CYAN}[4/10] Checking template files...${NC}"
TEMPLATE_FILES=("templates/devstack.template" "templates/tmux.conf.template")
for file in "${TEMPLATE_FILES[@]}"; do
  if [[ -f "$file" ]]; then
    echo -e "${GREEN}✓${NC} Found $file"
  else
    echo -e "${RED}✗${NC} Missing $file"
    ERRORS=$((ERRORS + 1))
  fi
done

# Test 5: Check skill scripts
echo -e "${CYAN}[5/10] Checking skill scripts...${NC}"
SKILL_SCRIPTS=("skills/install.sh" "skills/customize.sh")
for script in "${SKILL_SCRIPTS[@]}"; do
  if [[ -f "$script" && -x "$script" ]]; then
    echo -e "${GREEN}✓${NC} Found executable $script"
  else
    echo -e "${RED}✗${NC} Missing or not executable: $script"
    ERRORS=$((ERRORS + 1))
  fi
done

# Test 6: Check bin scripts
echo -e "${CYAN}[6/10] Checking bin scripts...${NC}"
BIN_SCRIPTS=("bin/devstack" "bin/tmux-send-to-children")
for script in "${BIN_SCRIPTS[@]}"; do
  if [[ -f "$script" && -x "$script" ]]; then
    echo -e "${GREEN}✓${NC} Found executable $script"
  else
    echo -e "${RED}✗${NC} Missing or not executable: $script"
    ERRORS=$((ERRORS + 1))
  fi
done

# Test 7: Validate YAML syntax (basic)
echo -e "${CYAN}[7/10] Validating YAML syntax...${NC}"
for file in "${CONFIG_FILES[@]}"; do
  if grep -q "^[[:space:]]*#" "$file" && grep -q ":" "$file"; then
    echo -e "${GREEN}✓${NC} $file appears valid"
  else
    echo -e "${YELLOW}?${NC} $file may have issues (basic check only)"
  fi
done

# Test 8: Check for required tools
echo -e "${CYAN}[8/10] Checking required tools...${NC}"
TOOLS=("tmux" "git" "bash")
for tool in "${TOOLS[@]}"; do
  if command -v "$tool" &> /dev/null; then
    echo -e "${GREEN}✓${NC} $tool is installed"
  else
    echo -e "${RED}✗${NC} $tool is NOT installed"
    ERRORS=$((ERRORS + 1))
  fi
done

# Test 9: Check ~/bin installation (if install.sh was run)
echo -e "${CYAN}[9/10] Checking ~/bin installation...${NC}"
if [[ -f "$HOME/bin/devstack" ]]; then
  echo -e "${GREEN}✓${NC} devstack installed to ~/bin"
else
  echo -e "${YELLOW}→${NC} devstack not yet installed to ~/bin (run install.sh)"
fi

if [[ -f "$HOME/bin/tmux-send-to-children" ]]; then
  echo -e "${GREEN}✓${NC} tmux-send-to-children installed to ~/bin"
else
  echo -e "${YELLOW}→${NC} tmux-send-to-children not yet installed to ~/bin (run install.sh)"
fi

# Test 10: Check PATH
echo -e "${CYAN}[10/10] Checking PATH configuration...${NC}"
if echo "$PATH" | grep -q "$HOME/bin"; then
  echo -e "${GREEN}✓${NC} ~/bin is in PATH"
else
  echo -e "${YELLOW}→${NC} ~/bin not in PATH (run: source ~/.zshrc)"
fi

# Summary
echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Test Summary${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

if [[ $ERRORS -eq 0 ]]; then
  echo -e "${GREEN}✓ All tests passed!${NC}"
  echo ""
  echo -e "${CYAN}Next steps:${NC}"
  echo -e "  1. Run ${YELLOW}./skills/install.sh${NC} to install"
  echo -e "  2. Run ${YELLOW}source ~/.zshrc${NC} to update PATH"
  echo -e "  3. Run ${YELLOW}devstack${NC} to start your control room"
  exit 0
else
  echo -e "${RED}✗ Found $ERRORS error(s)${NC}"
  echo ""
  echo -e "${YELLOW}Please fix the errors above before proceeding.${NC}"
  exit 1
fi
