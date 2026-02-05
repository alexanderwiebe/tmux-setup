# Distribution Guide for Tmux-Setup Skill

This guide explains how to distribute and install this tmux-setup skill for other users.

## For Users: How to Install This Skill

### Option 1: Manual Installation (Current Standard)

1. **Clone the repository:**
   ```bash
   cd ~/dev
   git clone git@github.com:alexanderwiebe/tmux-setup.git
   # or
   git clone https://github.com/alexanderwiebe/tmux-setup.git
   ```

2. **Tell Claude about it:**
   When using Claude Code, simply say:
   ```
   "I've installed tmux-setup in ~/dev/tmux-setup. Please help me set it up."
   ```

   Or invoke directly:
   ```
   /tmux-setup
   ```

3. **Claude will then:**
   - Read the `skills/tmux-setup.prompt.md` file
   - Guide you through an interactive Q&A
   - Generate your configuration files
   - Run the installation script

### Option 2: Direct Skill Invocation

If Claude Code supports skill discovery from local directories:

1. **Add to Claude's skill path:**
   ```bash
   # Add to ~/.claude/config or similar
   CLAUDE_SKILLS_PATH="$HOME/dev/tmux-setup:$CLAUDE_SKILLS_PATH"
   ```

2. **Invoke the skill:**
   ```
   /tmux-setup
   ```

### Option 3: Future Plugin Marketplace (When Available)

When Claude Code launches a plugin marketplace, users will be able to:

```bash
# Hypothetical future command
claude plugin add git@github.com:alexanderwiebe/tmux-setup.git
# or
claude skill install tmux-setup
```

Then invoke with:
```
/tmux-setup
```

## For Developers: Preparing for Distribution

### Repository Structure

Ensure your repository has:

```
tmux-setup/
├── claude.json                           # ✅ Skill manifest
├── skills/
│   ├── tmux-setup.prompt.md             # ✅ Interactive prompt
│   ├── generate-config.sh               # ✅ Config generator
│   ├── install.sh                       # ✅ Installation script
│   └── customize.sh                     # ✅ Customization tool
├── config/                              # ✅ Default configs
├── templates/                           # ✅ Templates
├── README.md                            # ✅ Documentation
└── DISTRIBUTION.md                      # ✅ This file
```

### Claude.json Requirements

Your `claude.json` must include:

```json
{
  "name": "tmux-setup",
  "version": "2.0.0",
  "description": "Interactive tmux control room installer",
  "promptFile": "skills/tmux-setup.prompt.md",
  "invocation": {
    "type": "command",
    "command": "tmux-setup",
    "aliases": ["tmux", "devstack-setup"]
  }
}
```

Key fields:
- `promptFile` - Points to your interactive prompt
- `invocation.command` - The command users type (`/tmux-setup`)
- `aliases` - Alternative command names

### Prompt File (`skills/tmux-setup.prompt.md`)

This is the instruction set for Claude when the skill is invoked. It should:

1. **Explain the goal** - What the skill does
2. **Provide step-by-step instructions** - How to guide the user
3. **Include examples** - Sample interactions
4. **Handle errors** - What to do when things go wrong

See `skills/tmux-setup.prompt.md` for the complete example.

### Testing Your Skill

Before distributing:

1. **Test local installation:**
   ```bash
   cd ~/dev/tmux-setup
   ./skills/install.sh --test
   ```

2. **Test with Claude:**
   - Open Claude Code
   - Navigate to the skill directory
   - Ask Claude: "Help me set up tmux-setup"
   - Verify Claude reads and follows the prompt file

3. **Test config generation:**
   ```bash
   ./skills/generate-config.sh --session test-stack \
     --theme ocean \
     --layout main-horizontal \
     --ancestor ~/dev/test-main \
     --children ~/dev/test-child1 ~/dev/test-child2
   ```

4. **Test JSON input:**
   ```bash
   ./skills/generate-config.sh --json '{
     "session_name": "test",
     "theme": "ocean",
     "layout": "main-horizontal",
     "panes": [
       {"path": "~/dev/main", "name": "main", "label": "ROOT"},
       {"path": "~/dev/child1", "name": "child1", "label": "CHILD"}
     ]
   }'
   ```

## Publishing Your Skill

### GitHub Repository

1. **Create a public repository:**
   ```bash
   gh repo create tmux-setup --public --source=. --remote=origin
   git push -u origin main
   ```

2. **Add a comprehensive README:**
   - Installation instructions
   - Usage examples
   - Screenshots/demos
   - Requirements

3. **Tag releases:**
   ```bash
   git tag -a v2.0.0 -m "Release 2.0.0: Interactive skill"
   git push origin v2.0.0
   ```

### Documentation

Ensure you have:
- [ ] `README.md` - Main documentation
- [ ] `QUICKSTART.md` - Quick reference
- [ ] `DISTRIBUTION.md` - This file
- [ ] `LICENSE` - License file (MIT recommended)
- [ ] `CHANGELOG.md` - Version history

### Promotion

Share your skill:
- Post on Claude Code forums/Discord
- Add to skill registries (when available)
- Blog post with demo
- Twitter/social media

## Example User Flow

### Installation
```bash
User: "I want to install the tmux-setup skill"

[User clones repo to ~/dev/tmux-setup]

User: "I've cloned tmux-setup. Help me set it up."

Claude: "Great! I see the tmux-setup skill. Let me help you configure
your tmux control room. First, tell me about your workflow - how many
projects do you typically work on simultaneously?"

[Interactive Q&A proceeds as defined in tmux-setup.prompt.md]
```

### Direct Invocation
```bash
User: "/tmux-setup"

Claude: [Reads skills/tmux-setup.prompt.md]
"I'll help you set up your tmux control room! First, tell me about
your workflow - how many projects do you typically work on at the
same time?"

[Proceeds with interactive setup]
```

## Troubleshooting Distribution

### Issue: Claude doesn't recognize the skill

**Solutions:**
1. Ensure `claude.json` is in the repository root
2. Check that `promptFile` path is correct
3. Verify `invocation.command` is set
4. Make sure scripts are executable (`chmod +x`)

### Issue: Prompt file not loading

**Solutions:**
1. Check file path in `claude.json` is relative to repo root
2. Ensure file is committed to git
3. Verify file is not in `.gitignore`

### Issue: Scripts fail when run

**Solutions:**
1. Test scripts independently first
2. Check permissions (`chmod +x`)
3. Verify dependencies (bash, jq, tmux, git)
4. Add error handling to scripts

## Future Enhancements

When Claude Code adds official plugin support, consider:

1. **Plugin Registry Submission:**
   - Submit to official Claude Code plugin registry
   - Follow official guidelines
   - Maintain compatibility

2. **Auto-Updates:**
   - Implement version checking
   - Add update mechanism
   - Notify users of new versions

3. **Dependency Management:**
   - Specify dependencies in `claude.json`
   - Auto-install dependencies if possible
   - Provide clear error messages for missing deps

4. **Configuration Sharing:**
   - Allow users to export/share configurations
   - Provide config templates
   - Community config repository

## Resources

- [Claude Code Documentation](https://docs.anthropic.com/claude/docs)
- [Skill Development Guide](https://docs.anthropic.com/claude/docs/skills)
- [Example Skills Repository](https://github.com/anthropics/claude-skills)

## Support

For issues or questions:
- GitHub Issues: https://github.com/alexanderwiebe/tmux-setup/issues
- Discussions: https://github.com/alexanderwiebe/tmux-setup/discussions

## License

Specify your license here (MIT recommended for open source skills).
