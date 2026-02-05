#!/usr/bin/env bash
# Dynamic Configuration Generator for Tmux Control Room
# Takes JSON input and generates YAML config files

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_DIR="$SCRIPT_DIR/config"

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

print_header() {
  echo -e "${CYAN}========================================${NC}"
  echo -e "${CYAN}$1${NC}"
  echo -e "${CYAN}========================================${NC}"
  echo ""
}

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "Warning: jq not installed. Using fallback parser."
    USE_JQ=false
else
    USE_JQ=true
fi

# Function to generate setup.yaml
generate_setup_yaml() {
    local session_name="$1"
    local ancestor_path="$2"
    local ancestor_name="$3"
    local ancestor_label="$4"
    shift 4
    local children_json="$1"
    local git_remote_name="${2:-gold}"
    local git_remote_url="${3:-}"
    local auto_start_claude="${4:-false}"

    cat > "$CONFIG_DIR/setup.yaml" << EOF
# Tmux Control Room Setup Configuration
# Generated: $(date)

repos:
  ancestor:
    path: $ancestor_path
    name: $ancestor_name
    label: $ancestor_label

  children:
EOF

    # Parse and add children (expecting JSON array)
    if [ "$USE_JQ" = true ]; then
        echo "$children_json" | jq -r '.[] | "    - path: \(.path)\n      name: \(.name)\n      label: \(.label)"' >> "$CONFIG_DIR/setup.yaml"
    else
        # Fallback: assume properly formatted
        echo "    # Add children manually or run with jq installed"
    fi

    cat >> "$CONFIG_DIR/setup.yaml" << EOF

session:
  name: $session_name
  window: stack

git:
  remote_name: $git_remote_name
  remote_url: $git_remote_url

features:
  auto_start_claude: $auto_start_claude
  colored_borders: true
  colored_title_bars: true
  check_git_remotes: true
  show_paths: true
  enable_sync_panes: true
EOF

    print_success "Generated setup.yaml"
}

# Function to update colors.yaml with active theme
update_colors_theme() {
    local theme="$1"

    if [ -f "$CONFIG_DIR/colors.yaml" ]; then
        # Update the active_theme line
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/^active_theme:.*/active_theme: $theme/" "$CONFIG_DIR/colors.yaml"
        else
            sed -i "s/^active_theme:.*/active_theme: $theme/" "$CONFIG_DIR/colors.yaml"
        fi
        print_success "Set color theme to: $theme"
    else
        print_error "colors.yaml not found"
        return 1
    fi
}

# Function to update layouts.yaml with active layout
update_layouts() {
    local layout="$1"

    if [ -f "$CONFIG_DIR/layouts.yaml" ]; then
        # Update the active_layout line
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/^active_layout:.*/active_layout: $layout/" "$CONFIG_DIR/layouts.yaml"
        else
            sed -i "s/^active_layout:.*/active_layout: $layout/" "$CONFIG_DIR/layouts.yaml"
        fi
        print_success "Set layout to: $layout"
    else
        print_error "layouts.yaml not found"
        return 1
    fi
}

# Function to generate complete config from JSON input
generate_from_json() {
    local json_input="$1"

    print_header "Generating Configuration from User Input"

    if [ "$USE_JQ" = true ]; then
        # Extract values using jq
        local session_name=$(echo "$json_input" | jq -r '.session_name // "dev-stack"')
        local theme=$(echo "$json_input" | jq -r '.theme // "default"')
        local layout=$(echo "$json_input" | jq -r '.layout // "main-horizontal"')
        local ancestor_path=$(echo "$json_input" | jq -r '.panes[0].path')
        local ancestor_name=$(echo "$json_input" | jq -r '.panes[0].name')
        local ancestor_label=$(echo "$json_input" | jq -r '.panes[0].label // "ROOT"')
        local children=$(echo "$json_input" | jq -c '[.panes[1:][]]')
        local git_remote_name=$(echo "$json_input" | jq -r '.git.remote_name // "gold"')
        local git_remote_url=$(echo "$json_input" | jq -r '.git.remote_url // ""')
        local auto_start_claude=$(echo "$json_input" | jq -r '.features.auto_start_claude // false')

        # Generate files
        generate_setup_yaml "$session_name" "$ancestor_path" "$ancestor_name" "$ancestor_label" \
                           "$children" "$git_remote_name" "$git_remote_url" "$auto_start_claude"
        update_colors_theme "$theme"
        update_layouts "$layout"

        print_success "Configuration generated successfully!"
        echo ""
        echo "Next steps:"
        echo "1. Review the generated config: cat $CONFIG_DIR/setup.yaml"
        echo "2. Run the installer: cd $SCRIPT_DIR && ./skills/install.sh"
        echo "3. Start your control room: source ~/.zshrc && $session_name"

    else
        print_error "jq is not installed. Please install jq or provide configuration manually."
        echo ""
        echo "To install jq:"
        echo "  macOS: brew install jq"
        echo "  Linux: apt-get install jq or yum install jq"
        return 1
    fi
}

# Function to create config from command-line arguments
generate_from_args() {
    local session_name="$1"
    local theme="$2"
    local layout="$3"
    local ancestor_path="$4"
    local ancestor_name="$5"
    shift 5
    local children_paths=("$@")

    print_header "Generating Configuration"

    # Build children JSON
    local children_json="["
    local first=true
    for child_path in "${children_paths[@]}"; do
        local child_name=$(basename "$child_path")
        [ "$first" = false ] && children_json+=","
        children_json+="{\"path\":\"$child_path\",\"name\":\"$child_name\",\"label\":\"CHILD\"}"
        first=false
    done
    children_json+="]"

    generate_setup_yaml "$session_name" "$ancestor_path" "$ancestor_name" "ROOT" \
                       "$children_json" "gold" "" "false"
    update_colors_theme "$theme"
    update_layouts "$layout"

    print_success "Configuration generated successfully!"
}

# Show usage
usage() {
    cat << EOF
Usage:
  # From JSON file or string
  $0 --json '{"session_name": "my-stack", "theme": "ocean", ...}'
  $0 --json-file config.json

  # From command-line arguments
  $0 --session my-stack --theme ocean --layout main-horizontal \\
     --ancestor ~/dev/main-project \\
     --children ~/dev/child1 ~/dev/child2 ~/dev/child3

Options:
  --json JSON_STRING          Generate from JSON string
  --json-file FILE            Generate from JSON file
  --session NAME              Session name (default: dev-stack)
  --theme THEME               Color theme (default, ocean, forest, fire, purple, monochrome, cyberpunk)
  --layout LAYOUT             Layout (main-horizontal, tiled, main-vertical, even-horizontal, even-vertical)
  --ancestor PATH             Path to ancestor/main repository
  --children PATH [PATH...]   Paths to child repositories (space-separated)
  --help                      Show this help message

JSON Format:
{
  "session_name": "my-stack",
  "theme": "ocean",
  "layout": "main-horizontal",
  "panes": [
    {
      "path": "~/dev/main-project",
      "name": "main-project",
      "label": "ROOT"
    },
    {
      "path": "~/dev/child1",
      "name": "child1",
      "label": "CHILD"
    }
  ],
  "git": {
    "remote_name": "gold",
    "remote_url": "https://github.com/user/repo.git"
  },
  "features": {
    "auto_start_claude": false
  }
}
EOF
}

# Main script logic
main() {
    if [ $# -eq 0 ]; then
        usage
        exit 1
    fi

    case "$1" in
        --json)
            shift
            generate_from_json "$1"
            ;;
        --json-file)
            shift
            if [ ! -f "$1" ]; then
                print_error "File not found: $1"
                exit 1
            fi
            generate_from_json "$(cat "$1")"
            ;;
        --session)
            # Parse command-line arguments
            session_name="dev-stack"
            theme="default"
            layout="main-horizontal"
            ancestor_path=""
            children_paths=()

            while [ $# -gt 0 ]; do
                case "$1" in
                    --session) session_name="$2"; shift 2 ;;
                    --theme) theme="$2"; shift 2 ;;
                    --layout) layout="$2"; shift 2 ;;
                    --ancestor) ancestor_path="$2"; shift 2 ;;
                    --children)
                        shift
                        while [ $# -gt 0 ] && [[ ! "$1" =~ ^-- ]]; do
                            children_paths+=("$1")
                            shift
                        done
                        ;;
                    *) shift ;;
                esac
            done

            if [ -z "$ancestor_path" ]; then
                print_error "Ancestor path is required (--ancestor)"
                exit 1
            fi

            ancestor_name=$(basename "$ancestor_path")
            generate_from_args "$session_name" "$theme" "$layout" "$ancestor_path" "$ancestor_name" "${children_paths[@]}"
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
}

main "$@"
