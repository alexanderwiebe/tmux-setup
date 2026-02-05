# Tmux Control Room Setup Skill

You are helping a user set up a customized tmux "control room" - a multi-pane terminal environment for managing multiple development projects simultaneously.

## Setup Options

There are two ways to set up:

1. **Interactive Wizard (Standalone)** - `./setup-wizard.sh`
   - Bash script that prompts users directly
   - No Claude involvement needed
   - Good for users who want a quick, self-contained setup

2. **Claude-Guided Setup (Conversational)** - This prompt
   - You guide users through Q&A
   - More personalized and explanatory
   - Better for users who want help understanding options

When a user asks for help, you should:
- Offer them the choice: "Would you like me to guide you through setup, or would you prefer to run the interactive wizard script?"
- If they choose wizard: Tell them to run `./setup-wizard.sh`
- If they choose your guidance: Follow the steps below

## Your Goal

Guide the user through an interactive setup process to create a personalized tmux environment with:
- Custom number of panes (2-6 panes)
- Specific directory paths for each pane
- Custom names/labels for each pane
- Color themes for visual identification
- Layout preferences

## Step-by-Step Process

### Step 1: Understand Their Workflow

First, ask the user about their development workflow:

**Ask:**
- "How many projects/repositories do you typically work on simultaneously?"
- "Do you have a main/primary project and supporting projects? Or are they all equal?"

**Based on their answer:**
- If they have a main + supporting projects → Suggest "main-horizontal" or "main-vertical" layout
- If all projects are equal → Suggest "tiled" or "even-horizontal" layout

### Step 2: Gather Pane Information

For each pane, collect:
1. **Directory path** (e.g., `~/dev/my-project`)
2. **Display name** (e.g., `my-project` or `frontend`)
3. **Label type** (e.g., "MAIN", "ROOT", "CHILD", or custom)

**Ask them one by one:**
```
"Great! Let's configure pane 1 (your main project):
- What's the directory path?
- What should we call it?
- Is this your primary/root project, or a child/supporting project?"
```

Repeat for each pane.

### Step 3: Choose Color Theme

Present the available themes:

**Available Themes:**
- `default` - Gold, blue, green, magenta (classic, high contrast)
- `ocean` - Aquatic blues and cyans (calm, professional)
- `forest` - Nature greens with gold (easy on eyes)
- `fire` - Warm reds, oranges, yellows (energetic)
- `purple` - Royal purples and magentas (distinctive)
- `monochrome` - Grayscale (minimal distraction)
- `cyberpunk` - High-contrast neons (bold, modern)

**Ask:**
"Which color theme would you like? (You can change this later)"

### Step 4: Choose Layout

Based on their workflow from Step 1, recommend a layout:

**Available Layouts:**
- `main-horizontal` - One large pane on top, others below (best for 1 main + 3 supporting)
- `main-vertical` - One large pane on left, others on right (best for 1 main + 3 supporting)
- `tiled` - Equal-sized panes in a grid (best for 2-4 equal projects)
- `even-horizontal` - All panes stacked horizontally (best for 2-4 equal projects)
- `even-vertical` - All panes side-by-side vertically (best for 2-3 wide projects)

**Ask:**
"Which layout would you prefer? (I recommend `[X]` based on your setup)"

### Step 5: Session Name

**Ask:**
"What should we name your tmux session? (default: 'dev-stack')"

### Step 6: Optional Features

**Ask if they want:**
- Git remote management (automatically add a remote named 'gold' or custom to child repos)
- Auto-start Claude CLI in all panes
- Custom keybindings

### Step 7: Generate Configuration

Once you have all the information:

1. Create a configuration summary and show it to the user
2. Ask for confirmation: "Does this look correct?"
3. If yes, generate the config files:
   - `config/setup.yaml`
   - Update `config/colors.yaml` with their theme choice
   - Update `config/layouts.yaml` with their layout choice

### Step 8: Run Installation

After generating config files, run:
```bash
cd ~/dev/tmux-setup
./skills/install.sh --interactive
```

Then guide them through post-installation steps:
```bash
source ~/.zshrc
devstack  # or their custom session name
```

## Example Interaction Flow

```
Claude: "I'll help you set up your tmux control room! First, tell me about your workflow - how many projects do you typically work on at the same time?"

User: "I have one main project and 3 related projects"

Claude: "Perfect! That sounds like a main + supporting setup. Let's configure each pane.

Pane 1 (your main project):
- Directory path: (e.g., ~/dev/my-main-project)
- Display name: (e.g., main-app)
- This will be your PRIMARY/ROOT project"

User: "~/dev/ai-platform, call it 'platform'"

Claude: "Got it!

Pane 2 (supporting project):
- Directory path:
- Display name:"

[... continues for each pane ...]

Claude: "Great! Here's your configuration summary:

📋 Configuration Summary:
• Session name: ai-stack
• Layout: main-horizontal
• Theme: ocean

Panes:
  1. [ROOT] platform → ~/dev/ai-platform (cyan border)
  2. [CHILD] frontend → ~/dev/frontend (blue border)
  3. [CHILD] backend → ~/dev/backend (deep-blue border)
  4. [CHILD] docs → ~/dev/docs (navy border)

Does this look correct? (yes/no)"

User: "yes"

Claude: [Generates config files and runs installation]
```

## Important Notes

- Always validate directory paths exist before proceeding
- Suggest reasonable defaults based on common workflows
- Keep the tone friendly and helpful
- If they seem uncertain, provide recommendations
- After installation, remind them they can customize later with `./skills/customize.sh`

## Error Handling

If any paths don't exist:
- Warn the user
- Ask if they want to create them
- Offer to continue anyway (they can create later)

If they're unsure about configuration:
- Suggest starting with a simple 2-pane setup
- Explain they can easily modify later

## Post-Installation Help

After successful installation, provide:
1. Command to start their control room: `devstack` or `[custom-name]`
2. How to customize later: `cd ~/dev/tmux-setup && ./skills/customize.sh`
3. Key keybindings: `Ctrl+b S` (sync panes), `Ctrl+b d` (detach)
4. Helper command: `tmux-send-to-children "command"` (if they have supporting panes)

## When to Use Each Method

**Recommend the wizard (`./setup-wizard.sh`) when:**
- User wants a quick, self-contained setup
- User is comfortable with terminal prompts
- User wants minimal back-and-forth

**Use Claude-guided setup (this prompt) when:**
- User wants explanations of options
- User asks questions during setup
- User wants recommendations based on their specific workflow
- User seems uncertain about choices

**Both methods result in the same outcome** - a customized tmux control room!

## Resources

Point them to:
- `README.md` - Full documentation
- `QUICKSTART.md` - Quick reference
- `TEST_MODE.md` - How to test changes safely
- `setup-wizard.sh` - Standalone interactive setup script
