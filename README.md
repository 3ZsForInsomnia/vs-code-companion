# vs-code-companion.nvim

A Neovim plugin for managing markdown-based AI prompts with CodeCompanion integration.

## Features

 - Simple unified interface for prompt selection
 - Automatic Telescope integration when available (no separate commands needed)

## Installation
**Requirements**: This plugin requires your project to be in a git repository, as it searches for markdown files relative to the git root.

**Dependencies**: 
- [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim) - Required for chat integration
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Optional, for enhanced file picker

Using lazy.nvim:

```lua
{
  'your-username/vs-code-companion.nvim',
  dependencies = {
    'olimorris/codecompanion.nvim', -- Required
    'nvim-telescope/telescope.nvim', -- Optional
    'nvim-lua/plenary.nvim', -- Required by telescope
  },
  config = function()
    require('vs-code-companion').setup({
        directories = {
          'prompts',
          '.github/prompts',
          'docs/ai-prompts',
      },
    })
    
    -- Optional: Load telescope extension
    require('telescope').load_extension('vs_code_companion')
    
      -- Optional: Load CodeCompanion extension for slash command
      -- This enables the /prompts slash command in CodeCompanion chat
      
    -- Optional: Create keymaps
      vim.keymap.set('n', '<leader>p', '<cmd>VsPrompts<cr>', { desc = 'Select Prompts' })
  end,
}
```

## Usage

### Basic Workflow

1. **Open a CodeCompanion chat buffer** (using `:CodeCompanionChat` or similar)
2. **Select a prompt** using either:
   - `:VsPrompts` command (automatically uses Telescope if available)
   - `/prompts` slash command (if CodeCompanion extension is loaded)
3. **The plugin will automatically**:
   - Set the model based on frontmatter
   - Add the prompt as a user message with tools
   - Include tools from frontmatter in the message

### Lua API

```lua
-- Main function
require('vs-code-companion').select_prompt()
```

### CodeCompanion Slash Command

If you have CodeCompanion and load the vs-code-companion extension, you get:

- `/prompts` - Search and apply prompts directly in CodeCompanion chat

### Telescope Extension

```lua
require('telescope').load_extension('vs_code_companion')

 -- The main VsPrompts command will automatically use Telescope if available
```

### Vim Commands

The plugin provides these built-in commands:


## Markdown File Format

The plugin expects markdown files with YAML frontmatter:

```markdown
---
description: Generate an implementation plan for new features or refactoring existing code.
tools: ['codebase', 'fetch', 'findTestFiles', 'githubRepo', 'search', 'usages']
model: Claude Sonnet 4
---

Your prompt content goes here...
```

## Configuration

```lua
require('vs-code-companion').setup({
  directories = {
    'prompts',
    '.github/prompts',
    'docs/ai-prompts',
  },
})
```

## Supported Models

The plugin automatically converts "nice" model names from frontmatter to technical names:

| Display Name | Technical Name |
|--------------|----------------|
| Claude Sonnet 4 | claude-4-sonnet |
| Claude Sonnet 3.5 | claude-3-5-sonnet-20241022 |
| Claude Haiku 3.5 | claude-3-5-haiku-20241022 |
| Claude Opus 3 | claude-3-opus-20240229 |
| GPT-4o | gpt-4o |
| GPT-4o Mini | gpt-4o-mini |
| GPT-4 Turbo | gpt-4-turbo-preview |
| Gemini 2.5 Pro | gemini-2.5-pro |
| Gemini 2.5 Flash | gemini-2.5-flash |

You can extend the model mappings by modifying `lua/vs-code-companion/utils/models.lua`.

## Health Check

Run `:checkhealth vs-code-companion` to verify:
- Plugin is loaded correctly
- Git repository is detected
- Configured directories exist
- CodeCompanion is available
- Telescope is available (if using telescope extension)
## Troubleshooting

### "Not in a git repository" error
Ensure you're running Neovim from within a git repository. The plugin needs a git root to resolve relative directory paths.

### "Please open or navigate to a CodeCompanion chat buffer first"
Open a CodeCompanion chat session before selecting prompts:
```vim
:CodeCompanionChat
```

### "No markdown files found in configured directories"
1. Check that your directories exist relative to the git root
2. Verify the directories contain `.md` files
3. Run `:checkhealth vs-code-companion` to see resolved paths

### Model not being set
1. Ensure CodeCompanion is properly installed
2. Check that the model name in frontmatter is supported (see model mapping table)
3. Verify you're in a CodeCompanion chat buffer when selecting prompts

### Tools not working as expected
1. Verify the `tools` array in frontmatter is properly formatted: `tools: ['tool1', 'tool2']`
2. Check CodeCompanion documentation for supported tool names
3. Ensure your CodeCompanion version supports the tools feature
