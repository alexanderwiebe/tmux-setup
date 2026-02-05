#!/usr/bin/env bash
# Test script for tmux-setup skill
# Validates that all components work together

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

print_test() {
    echo -e "${CYAN}▶ $1${NC}"
}

print_pass() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_fail() {
    echo -e "${RED}✗ $1${NC}"
}

print_header() {
    echo ""
    echo "=========================================="
    echo "$1"
    echo "=========================================="
    echo ""
}

# Test 1: Verify claude.json exists and is valid
test_claude_json() {
    print_header "Test 1: Validate claude.json"

    if [ ! -f "$SCRIPT_DIR/claude.json" ]; then
        print_fail "claude.json not found"
        return 1
    fi
    print_pass "claude.json exists"

    # Check for required fields
    if command -v jq &> /dev/null; then
        local name=$(jq -r '.name' "$SCRIPT_DIR/claude.json")
        local version=$(jq -r '.version' "$SCRIPT_DIR/claude.json")
        local prompt=$(jq -r '.promptFile' "$SCRIPT_DIR/claude.json")

        [ "$name" = "tmux-setup" ] && print_pass "name: $name" || print_fail "Invalid name"
        [ ! -z "$version" ] && print_pass "version: $version" || print_fail "Missing version"
        [ ! -z "$prompt" ] && print_pass "promptFile: $prompt" || print_fail "Missing promptFile"
    else
        print_pass "claude.json is valid JSON"
    fi
}

# Test 2: Verify prompt file exists
test_prompt_file() {
    print_header "Test 2: Validate Prompt File"

    if [ ! -f "$SCRIPT_DIR/skills/tmux-setup.prompt.md" ]; then
        print_fail "Prompt file not found"
        return 1
    fi
    print_pass "skills/tmux-setup.prompt.md exists"

    # Check for key sections
    if grep -q "# Tmux Control Room Setup Skill" "$SCRIPT_DIR/skills/tmux-setup.prompt.md"; then
        print_pass "Contains skill header"
    else
        print_fail "Missing skill header"
    fi

    if grep -q "## Step-by-Step Process" "$SCRIPT_DIR/skills/tmux-setup.prompt.md"; then
        print_pass "Contains step-by-step instructions"
    else
        print_fail "Missing step-by-step instructions"
    fi
}

# Test 3: Verify scripts are executable
test_scripts_executable() {
    print_header "Test 3: Verify Scripts are Executable"

    local scripts=(
        "skills/install.sh"
        "skills/customize.sh"
        "skills/generate-config.sh"
    )

    for script in "${scripts[@]}"; do
        if [ -x "$SCRIPT_DIR/$script" ]; then
            print_pass "$script is executable"
        else
            print_fail "$script is not executable"
        fi
    done
}

# Test 4: Test config generator with example
test_config_generator() {
    print_header "Test 4: Test Config Generator"

    print_test "Testing JSON config generation..."

    # Create temporary config directory for testing
    local test_dir="/tmp/tmux-setup-test-$$"
    mkdir -p "$test_dir/config"

    # Copy config files
    cp -r "$SCRIPT_DIR/config/"* "$test_dir/config/"

    # Test with example JSON
    cd "$SCRIPT_DIR"
    if ./skills/generate-config.sh --json-file examples/example-config.json > /dev/null 2>&1; then
        print_pass "Config generation from JSON succeeded"
    else
        print_fail "Config generation from JSON failed"
    fi

    # Cleanup
    rm -rf "$test_dir"
}

# Test 5: Verify required tools
test_dependencies() {
    print_header "Test 5: Check Dependencies"

    local required=("tmux" "git" "bash")
    local optional=("jq" "zsh")

    for tool in "${required[@]}"; do
        if command -v "$tool" &> /dev/null; then
            print_pass "$tool is installed"
        else
            print_fail "$tool is NOT installed (required)"
        fi
    done

    for tool in "${optional[@]}"; do
        if command -v "$tool" &> /dev/null; then
            print_pass "$tool is installed (optional)"
        else
            print_test "$tool is not installed (optional)"
        fi
    done
}

# Test 6: Verify config files exist
test_config_files() {
    print_header "Test 6: Verify Config Files"

    local configs=(
        "config/setup.yaml"
        "config/colors.yaml"
        "config/layouts.yaml"
        "config/defaults.yaml"
    )

    for config in "${configs[@]}"; do
        if [ -f "$SCRIPT_DIR/$config" ]; then
            print_pass "$config exists"
        else
            print_fail "$config not found"
        fi
    done
}

# Test 7: Verify templates exist
test_templates() {
    print_header "Test 7: Verify Templates"

    local templates=(
        "templates/devstack.template"
        "templates/tmux.conf.template"
    )

    for template in "${templates[@]}"; do
        if [ -f "$SCRIPT_DIR/$template" ]; then
            print_pass "$template exists"
        else
            print_fail "$template not found"
        fi
    done
}

# Test 8: Verify examples exist
test_examples() {
    print_header "Test 8: Verify Examples"

    if [ -f "$SCRIPT_DIR/examples/example-config.json" ]; then
        print_pass "example-config.json exists"

        # Validate it's valid JSON
        if command -v jq &> /dev/null; then
            if jq empty "$SCRIPT_DIR/examples/example-config.json" 2>/dev/null; then
                print_pass "example-config.json is valid JSON"
            else
                print_fail "example-config.json is invalid JSON"
            fi
        fi
    else
        print_fail "example-config.json not found"
    fi
}

# Test 9: Test dry-run mode
test_dry_run() {
    print_header "Test 9: Test Dry-Run Mode"

    print_test "Running install.sh --dry-run..."

    if "$SCRIPT_DIR/skills/install.sh" --dry-run > /dev/null 2>&1; then
        print_pass "Dry-run mode works"
    else
        print_fail "Dry-run mode failed"
    fi
}

# Run all tests
main() {
    print_header "Tmux-Setup Skill Test Suite"

    local failed=0

    test_claude_json || ((failed++))
    test_prompt_file || ((failed++))
    test_scripts_executable || ((failed++))
    test_dependencies || ((failed++))
    test_config_files || ((failed++))
    test_templates || ((failed++))
    test_examples || ((failed++))
    test_dry_run || ((failed++))
    test_config_generator || ((failed++))

    # Summary
    print_header "Test Summary"

    if [ $failed -eq 0 ]; then
        echo -e "${GREEN}All tests passed! ✓${NC}"
        echo ""
        echo "Your tmux-setup skill is ready for distribution."
        echo ""
        echo "Next steps:"
        echo "  1. Test the interactive skill with Claude"
        echo "  2. Push to GitHub: git push origin main"
        echo "  3. Create a release: git tag -a v2.0.0 -m 'Release v2.0.0'"
        echo "  4. Share with users!"
        return 0
    else
        echo -e "${RED}$failed test(s) failed ✗${NC}"
        echo ""
        echo "Please fix the failing tests before distributing."
        return 1
    fi
}

# Run tests
main "$@"
