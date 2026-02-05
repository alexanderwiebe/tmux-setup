#!/usr/bin/env bash
# Example workflow for using test mode
# This demonstrates how to safely test configurations

# ============================================================================
# Example 1: Try a new theme safely
# ============================================================================

echo "Example 1: Testing a new theme"
echo "================================"
echo ""

# Step 1: Install in test mode
echo "$ ./skills/install.sh --test --interactive"
echo "  (This creates test-devstack and ~/.tmux-test.conf)"
echo ""

# Step 2: Compare themes
echo "$ ./test/compare-themes.sh"
echo "  (Browse and select a theme to try)"
echo ""

# Step 3: Start test session
echo "$ test-devstack"
echo "  (See the theme in action)"
echo ""

# Step 4: If you like it, apply to production
echo "$ ./skills/install.sh"
echo "  (Installs to production)"
echo ""

# Step 5: Clean up test
echo "$ ./test/cleanup.sh"
echo "  (Removes test installation)"
echo ""

# ============================================================================
# Example 2: Preview changes before installing
# ============================================================================

echo "Example 2: Preview before installing"
echo "====================================="
echo ""

# Step 1: Make configuration changes
echo "$ vim config/colors.yaml"
echo "  (Edit active_theme: ocean)"
echo ""

# Step 2: Preview what would happen
echo "$ ./skills/install.sh --dry-run"
echo "  (Shows what would be installed, makes no changes)"
echo ""

# Step 3: If it looks good, install to test first
echo "$ ./skills/install.sh --test"
echo "  (Installs to test environment)"
echo ""

# Step 4: Try it out
echo "$ test-devstack"
echo "  (Test the configuration)"
echo ""

# Step 5: Apply to production
echo "$ ./skills/install.sh"
echo "  (Install for real)"
echo ""

# ============================================================================
# Example 3: Compare themes side-by-side
# ============================================================================

echo "Example 3: Side-by-side comparison"
echo "==================================="
echo ""

# Terminal 1
echo "Terminal 1:"
echo "$ devstack"
echo "  (Production session with current theme)"
echo ""

# Terminal 2
echo "Terminal 2:"
echo "$ ./test/compare-themes.sh"
echo "  (Select 'ocean' theme)"
echo "$ ./skills/install.sh --test"
echo "$ test-devstack"
echo "  (Test session with ocean theme)"
echo ""
echo "Now you can see both themes side-by-side!"
echo ""

# ============================================================================
# Example 4: Using the sandbox helper
# ============================================================================

echo "Example 4: Interactive sandbox"
echo "==============================="
echo ""

echo "$ ./test/sandbox.sh"
echo ""
echo "This opens an interactive menu:"
echo "  1. Start test session (basic)"
echo "  2. Start test session with Claude"
echo "  3. Start with custom tmux config"
echo "  4. Compare themes"
echo "  5. Clean up and exit"
echo ""

# ============================================================================
# Example 5: Custom configuration testing
# ============================================================================

echo "Example 5: Test custom configuration"
echo "====================================="
echo ""

# Step 1: Create custom config
echo "$ cp config/setup.yaml my-test-config.yaml"
echo "$ vim my-test-config.yaml"
echo "  (Make your changes)"
echo ""

# Step 2: Preview with dry run
echo "$ ./skills/install.sh --dry-run --config=my-test-config.yaml"
echo "  (Preview what would be installed)"
echo ""

# Step 3: Install to test mode
echo "$ ./skills/install.sh --test --config=my-test-config.yaml"
echo "  (Test the custom configuration)"
echo ""

# Step 4: Start test session
echo "$ test-devstack"
echo "  (Try it out)"
echo ""

# Step 5: If perfect, install to production
echo "$ ./skills/install.sh --config=my-test-config.yaml"
echo "  (Use your custom config in production)"
echo ""

# ============================================================================
# Safety Notes
# ============================================================================

echo "Safety Guarantees:"
echo "=================="
echo ""
echo "✓ Test mode never modifies production files"
echo "✓ Separate session names (test-stack vs aj-stack)"
echo "✓ Separate scripts (test-devstack vs devstack)"
echo "✓ Separate configs (~/.tmux-test.conf vs ~/.tmux.conf)"
echo "✓ Easy cleanup that preserves production"
echo "✓ Clear visual indicators (TEST MODE banners)"
echo ""
echo "Your production setup is always safe!"
