#!/usr/bin/env bash
# Interactive Setup Wizard for Tmux Control Room
# Run this to configure your tmux setup without needing Claude

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_header() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

print_step() {
    echo -e "${CYAN}▶${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Welcome message
print_header "Tmux Control Room Setup Wizard"

echo "This wizard will help you create a customized tmux environment."
echo "I'll ask you about your projects, preferences, and then generate"
echo "a configuration tailored to your workflow."
echo ""
echo -e "${YELLOW}Note: If you have Claude Code, you can also run: 'claude' and ask${NC}"
echo -e "${YELLOW}'Help me set up my tmux control room' for a guided experience.${NC}"
echo ""
read -p "Press Enter to continue..."

# Step 1: Number of panes
print_header "Step 1: Number of Panes"
echo "How many projects/directories do you want to manage?"
echo "You can have 2-6 panes (each pane = one project directory)"
echo ""
while true; do
    read -p "Number of panes (2-6): " num_panes
    if [[ "$num_panes" =~ ^[2-6]$ ]]; then
        break
    else
        print_error "Please enter a number between 2 and 6"
    fi
done

# Step 2: Workflow type
print_header "Step 2: Workflow Type"
echo "Do you have:"
echo "  1) One main project with supporting projects"
echo "  2) All projects are equal in importance"
echo ""
read -p "Choose (1 or 2): " workflow_type

if [ "$workflow_type" = "1" ]; then
    layout_recommendation="main-horizontal"
    echo ""
    print_step "Recommending 'main-horizontal' layout (large top pane for main project)"
else
    layout_recommendation="tiled"
    echo ""
    print_step "Recommending 'tiled' layout (equal-sized panes)"
fi

# Step 3: Collect pane information
declare -a pane_paths
declare -a pane_names
declare -a pane_labels

print_header "Step 3: Configure Panes"

for ((i=1; i<=num_panes; i++)); do
    echo ""
    echo -e "${BOLD}Pane $i:${NC}"

    # Get path
    while true; do
        read -p "  Directory path (e.g., ~/dev/my-project): " path
        # Expand tilde
        path="${path/#\~/$HOME}"

        if [ -d "$path" ]; then
            print_success "Directory exists"
            break
        else
            print_warning "Directory doesn't exist yet"
            read -p "  Continue anyway? (y/n): " continue_anyway
            if [ "$continue_anyway" = "y" ]; then
                break
            fi
        fi
    done
    pane_paths+=("$path")

    # Get name
    default_name=$(basename "$path")
    read -p "  Display name (default: $default_name): " name
    name=${name:-$default_name}
    pane_names+=("$name")

    # Get label
    if [ $i -eq 1 ] && [ "$workflow_type" = "1" ]; then
        pane_labels+=("ROOT")
        echo "  Label: ROOT (main project)"
    else
        read -p "  Label (ROOT/CHILD/custom, default: CHILD): " label
        label=${label:-CHILD}
        pane_labels+=("$label")
    fi
done

# Step 4: Color theme
print_header "Step 4: Color Theme"
echo "Choose a color theme:"
echo "  1) default    - Gold, blue, green, magenta (classic)"
echo "  2) ocean      - Aquatic blues and cyans (calm)"
echo "  3) forest     - Nature greens (easy on eyes)"
echo "  4) fire       - Warm reds and oranges (energetic)"
echo "  5) purple     - Royal purples (distinctive)"
echo "  6) monochrome - Grayscale (minimal)"
echo "  7) cyberpunk  - High-contrast neons (bold)"
echo ""
read -p "Choose theme (1-7, default: 1): " theme_choice
theme_choice=${theme_choice:-1}

case $theme_choice in
    1) theme="default" ;;
    2) theme="ocean" ;;
    3) theme="forest" ;;
    4) theme="fire" ;;
    5) theme="purple" ;;
    6) theme="monochrome" ;;
    7) theme="cyberpunk" ;;
    *) theme="default" ;;
esac

# Step 5: Layout
print_header "Step 5: Layout"
echo "Choose a layout (recommended: $layout_recommendation):"
echo "  1) main-horizontal - Large top pane, smaller bottom panes"
echo "  2) main-vertical   - Large left pane, smaller right panes"
echo "  3) tiled           - Equal-sized panes in grid"
echo "  4) even-horizontal - All panes stacked horizontally"
echo "  5) even-vertical   - All panes side-by-side vertically"
echo ""
read -p "Choose layout (1-5, default: use recommendation): " layout_choice

case $layout_choice in
    1) layout="main-horizontal" ;;
    2) layout="main-vertical" ;;
    3) layout="tiled" ;;
    4) layout="even-horizontal" ;;
    5) layout="even-vertical" ;;
    *) layout="$layout_recommendation" ;;
esac

# Step 6: Session name
print_header "Step 6: Session Name"
read -p "What should we name your tmux session? (default: dev-stack): " session_name
session_name=${session_name:-dev-stack}

# Step 7: Summary
print_header "Configuration Summary"
echo ""
echo -e "${BOLD}📋 Your Configuration:${NC}"
echo "  • Session name: $session_name"
echo "  • Layout: $layout"
echo "  • Theme: $theme"
echo "  • Number of panes: $num_panes"
echo ""
echo -e "${BOLD}Panes:${NC}"
for ((i=0; i<num_panes; i++)); do
    echo "  $((i+1)). [${pane_labels[$i]}] ${pane_names[$i]} → ${pane_paths[$i]}"
done
echo ""
read -p "Does this look correct? (y/n): " confirm

if [ "$confirm" != "y" ]; then
    print_error "Setup cancelled. Run ./setup-wizard.sh to start over."
    exit 0
fi

# Step 8: Generate configuration
print_header "Generating Configuration"

# Build JSON
json_config="{"
json_config+="\"session_name\":\"$session_name\","
json_config+="\"theme\":\"$theme\","
json_config+="\"layout\":\"$layout\","
json_config+="\"panes\":["

for ((i=0; i<num_panes; i++)); do
    [ $i -gt 0 ] && json_config+=","
    json_config+="{"
    json_config+="\"path\":\"${pane_paths[$i]}\","
    json_config+="\"name\":\"${pane_names[$i]}\","
    json_config+="\"label\":\"${pane_labels[$i]}\""
    json_config+="}"
done

json_config+="]}"

# Save to temp file
temp_json="/tmp/tmux-setup-config-$$.json"
echo "$json_config" > "$temp_json"

print_step "Generated configuration file"

# Generate config files
if "$SCRIPT_DIR/skills/generate-config.sh" --json "$json_config"; then
    print_success "Configuration files created"
else
    print_error "Failed to generate configuration"
    rm "$temp_json"
    exit 1
fi

rm "$temp_json"

# Step 9: Install
print_header "Installation"
echo "Ready to install your tmux control room!"
echo ""
read -p "Install now? (y/n): " install_now

if [ "$install_now" = "y" ]; then
    "$SCRIPT_DIR/skills/install.sh"

    print_header "Setup Complete!"
    echo ""
    print_success "Your tmux control room is ready!"
    echo ""

    echo -e "${YELLOW}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║  IMPORTANT: PATH Update Required                          ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo "The '$session_name' command won't work yet. Update your PATH first:"
    echo ""
    echo -e "${CYAN}Quick start (choose one):${NC}"
    echo ""
    echo "  Option A - This terminal only:"
    echo -e "    ${YELLOW}export PATH=\"\$HOME/bin:\$PATH\"${NC}"
    echo -e "    ${YELLOW}$session_name${NC}"
    echo ""
    echo "  Option B - Permanent (recommended):"
    echo -e "    ${YELLOW}source ~/.zshrc${NC}"
    echo -e "    ${YELLOW}$session_name${NC}"
    echo ""
    echo "  Option C - New terminal:"
    echo "    Open a new terminal, then run:"
    echo -e "    ${YELLOW}$session_name${NC}"
    echo ""
    echo "  Option D - Use full path:"
    echo -e "    ${YELLOW}$HOME/bin/$session_name${NC}"
    echo ""
    echo -e "${BOLD}Useful tmux commands:${NC}"
    echo "  • Ctrl+b S - Toggle synchronize-panes (send to all)"
    echo "  • Ctrl+b d - Detach (keeps session running)"
    echo "  • tmux-send-to-children 'command' - Send to child panes only"
    echo ""
    echo "To customize later: cd $SCRIPT_DIR && ./skills/customize.sh"
else
    echo ""
    print_step "Configuration saved. To install later, run:"
    echo "  cd $SCRIPT_DIR && ./skills/install.sh"
fi
