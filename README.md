# vs-code-companion.nvim

Import VS Code AI prompts into Neovim's [CodeCompanion](https://codecompanion.olimorris.dev/). Share prompts across editors without friction.

Perfect for teams using VS Code prompts or developers migrating from VS Code to Neovim.

## Quick Start

1. **Install** this plugin (requires [CodeCompanion](https://codecompanion.olimorris.dev/))
2. **Create VS Code prompt files** in `.github/prompts/` in your project (or configure custom directories)
3. **Import prompts**: Run `:VsccImport` to add VS Code prompts to CodeCompanion's library
4. **Use prompts**: Run `:VsccSelect` to browse and apply prompts in CodeCompanion chat

## Why Use This Plugin?

✅ **Use existing VS Code prompts** in Neovim  
✅ **Share prompt libraries** across team members and editors  
✅ **Zero conversion needed** - works with [VS Code's standard format](https://code.visualstudio.com/docs/copilot/customization/prompt-files#_prompt-file-format)  
✅ **Fuzzy search with previews** via Telescope integration  
✅ **Smart AI model detection** from VS Code frontmatter

## Installation

**Dependencies:**
- [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim) - Required
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Optional, for enhanced picker with previews

### lazy.nvim

```lua
{
  'olimorris/codecompanion.nvim',
  dependencies = {
    '3ZsForInsomnia/vs-code-companion.nvim',
  },
  opts = {
    -- your codecompanion config
  }
}
```

### packer.nvim

```lua
use {
  'olimorris/codecompanion.nvim',
  requires = {
    '3ZsForInsomnia/vs-code-companion.nvim',
  },
  config = function()
    require("codecompanion").setup({
      -- your codecompanion config
    })
  end
}
```

## Basic Usage

### 1. Create VS Code Prompt Files

Create markdown files with YAML frontmatter in your project (default: `.github/prompts/`):

```markdown
---
description: "Review code for bugs and improvements"  
model: "Claude Sonnet 3.5"
---

Please review this code for potential bugs, performance issues, and improvements...
```

Learn more about [VS Code's prompt format](https://code.visualstudio.com/docs/copilot/customization/prompt-files#_prompt-file-format) and see [examples](https://code.visualstudio.com/docs/copilot/customization/custom-chat-modes#_custom-chat-modes).

### 2. Import Prompts

```vim
:VsccImport
```

This reads VS Code prompt files from configured directories and adds them to CodeCompanion's prompt library as slash commands.

### 3. Use Prompts

```vim
:VsccSelect
```

Browse and select from ALL prompts (both imported VS Code prompts and existing CodeCompanion prompts). The selected prompt is added to a CodeCompanion chat buffer.

**Note:** You can run `:VsccSelect` without importing first - it will show existing CodeCompanion prompts. Import with `:VsccImport` to include your VS Code prompts.

## CodeCompanion Integration

### Slash Commands in Chat Buffers

Add VS Code prompt functionality directly to CodeCompanion chat buffers by configuring slash commands:

```lua
{
  'olimorris/codecompanion.nvim',
  dependencies = {
    '3ZsForInsomnia/vs-code-companion.nvim',
  },
  opts = {
    strategies = {
      chat = {
        slash_commands = {
          vs_import = require("vs-code-companion").import_slash_command,
          vs_select = require("vs-code-companion").select_slash_command,
        },
      },
    },
    -- your other codecompanion config
  }
}
```

This enables:
- `/vs_import` - Import VS Code prompts from within a CodeCompanion buffer
- `/vs_select` - Select and apply prompts from within a CodeCompanion buffer

### VS Code Prompt Format

VS Code prompts use markdown files with YAML frontmatter. Supported fields:

```markdown
---
description: "Required - Brief description shown in picker"
model: "Optional - AI model name (see docs/models.md)"
tools: ["Optional", "array", "of", "tool", "names"]
---

Your prompt content here...
```

**Required:**
- `description` - Short description shown in pickers and command descriptions

**Optional:**
- `model` - AI model name (automatically converted from display names to technical names)
- `tools` - Array of tool names (currently replaced with CodeCompanion's `@{full_stack_dev}`)

## Configuration

Basic configuration options:

```lua
{
  '3ZsForInsomnia/vs-code-companion.nvim',
  opts = {
    directories = {'.github/prompts', '.github/chatmodes'}, -- Where to find prompt files
    picker = "auto", -- "auto", "telescope", or "vim_ui"  
  }
}
```

### Options

  - `"auto"` - Use Telescope if available, fall back to vim.ui.select
  - `"telescope"` - Force Telescope (better experience with file previews)
  - `"vim_ui"` - Force vim.ui.select

## Picker Integration

### Telescope (Recommended)

If you have [Telescope](https://github.com/nvim-telescope/telescope.nvim) installed, you'll get a better experience with fuzzy search and prompt previews.

### Other Pickers

Want to use [snacks.nvim](https://github.com/folke/snacks.nvim) or another picker? Use the public API functions:

```lua
-- Get all prompts
local prompts = require("vs-code-companion").get_all_prompts()

-- Create display text for a prompt
local display = require("vs-code-companion").create_prompt_display_text(prompt_info)

-- Handle selection (opens CodeCompanion chat with prompt)
require("vs-code-companion.ui.handlers").handle_file_selection(selected_prompt)
```

## Troubleshooting

**"No prompts found"**

**"X files failed to process"**

**"Not in git repository"**  

**Telescope not working**

**Commands not working**

## Advanced Usage

For advanced configuration, CodeCompanion integration, and technical details, see:

- Git repository (for relative path resolution)  
- [CodeCompanion.nvim](https://github.com/olimorris/codecompanion.nvim)