# vs-code-companion.nvim

Want to use all the fancy prompts your VS Code using teammates are using with AI? Now you can use them in Neovim too, with this plugin and CodeCompanion!

This plugin imports VS Code AI prompts for seamless use with [CodeCompanion](https://codecompanion.olimorris.dev/) in Neovim, allowing the sharing of prompts across editors without friction. Perfect for teams working across different editors or developers switching from VS Code to Neovim!

## Why Use This Plugin?

- **Cross-Editor Compatibility**: Use VS Code Chat Mode prompts in Neovim
- **Team Consistency**: Share the same prompt library across VS Code and Neovim users
- **Migration-Friendly**: Seamlessly import existing VS Code prompt collections
- **Zero Conversion**: Works with VS Code's standard markdown + YAML frontmatter format
- **Instant Access**: Browse and apply prompts via Telescope or vim.ui.select
- **Smart Integration**: Automatically sets AI models and tools from VS Code frontmatter

## Features

- **VS Code Format Support**: Reads VS Code Chat Mode markdown files with YAML frontmatter
- **Prompt Library Import**: Import VS Code prompts into CodeCompanion's prompt library
- **Telescope Integration**: Beautiful fuzzy search with file previews when available

## Installation and configuration

**Dependencies**: 
- [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim) - Required for AI chat integration
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) - Optional, for enhanced file picker

**Config options**:
- **`directories`** (table): List of directories to search for markdown prompts
  - Paths are relative to the git repository root
  - Searches recursively in each directory listed for `*.md` files
  - Default: `{'.github/prompts', '.github/chatmodes'}`

Using lazy.nvim:

```lua
{
  'olimorris/codecompanion.nvim',
  dependencies = {
    {
      '3ZsForInsomnia/vs-code-companion.nvim',
      opts = {
        directories = {
          '.github/chatmodes',
          '.github/prompts',
          'docs/ai-prompts',
        }
      }
  },
  opts = {...}
  config = function(_, opts)
    -- Optional, but a nicer way to quickly import prompts when in a CodeCompanion buffer
    opts.strategies.chat.slash_commands = {
      vs_import = require("vs-code-companion").import_slash_command,
      vs_select = require("vs-code-companion").select_slash_command,
    }
    require("codecompanion").setup(opts)
  end,
}
```

## Usage

**Requirements**: This plugin requires your project to be in a git repository, as it searches for markdown files relative to the git root.

#### Importing prompts

`:VsccImport` 
- Import all prompts found, and creates CodeCompanion slash commands for each one
- Creates individual `/command_name` slash commands for each prompt file
- Command names are generated from filenames (sanitized for Lua), prefixed with `vsc_` for easy finding

#### Selecting prompts

`VsccSelect`
- **`:VsccSelect`** - Browse and select prompts from the configured directories
- Automatically uses Telescope if available, falls back to vim.ui.select
- Works from any buffer - will open CodeCompanion chat after a selection is made
- Immediately adds the prompt text to the CodeCompanion chat buffer, but does not _send_ the message
  - This makes it easy to add your own text!

## Supported Models

The plugin automatically converts "nice" model names in the markdown frontmatter to their "actual" names:


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

## VS Code Chat Mode Format

This plugin reads VS Code's standard Chat Mode format, which are simple markdown files with YAML frontmatter. For an example of how VS Code uses these files, see [VS Code's Chat Modes documentation](https://code.visualstudio.com/docs/copilot/chat/chat-modes).

### YAML Frontmatter Options

```markdown
---
description: "Brief description shown in picker (VS Code standard)"
model: "Claude Sonnet 4"
tools: ['codebase', 'search', 'usages']
---

Your VS Code Chat Mode prompt content here...
```

- **`description`** (string): Short description shown in pickers (VS Code standard field)
- **`model`** (string): AI model name (VS Code format, automatically converted)
- **`tools`** (array): VS Code tool names (currently replaced by using CodeCompanion's `@{full_stack_dev}` for simplicity until a better mapping setup is created)

## Roadmap

- [ ] Add support for determining if a markdown file actually is or is not a prompt, and filter out non-prompt files found
- [ ] Support separate lists in config for system vs user prompts
- [ ] Add support for mapping VS Code tools to CodeCompanion tools to the extent possible
