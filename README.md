# vs-code-companion.nvim

Import VS Code AI prompts into Neovim's [CodeCompanion](https://codecompanion.olimorris.dev/). Share prompts across editors without friction.

Perfect for teams using VS Code prompts or developers migrating from VS Code to Neovim.

> **Looking for prompt browsing and selection?** Check out [code-companion-picker](https://github.com/3ZsForInsomnia/code-companion-picker) for advanced prompt selection with fuzzy search, previews, and customizable UI.

## Quick Start

1. **Install** this plugin (requires [CodeCompanion](https://codecompanion.olimorris.dev/))
2. **Create VS Code prompt files** in `.github/prompts/` in your project (or configure custom directories)
3. **Import prompts**: Run `:VsccImport` to add VS Code prompts to CodeCompanion's library
4. **Use prompts**: Access imported prompts as slash commands (e.g., `/vsc_my_prompt`) in CodeCompanion chat buffers

## Why Use This Plugin?

✅ **Use existing VS Code prompts** in Neovim
✅ **Share prompt libraries** across team members and editors
✅ **Zero conversion needed** - works with [VS Code's standard format](https://code.visualstudio.com/docs/copilot/customization/prompt-files#_prompt-file-format)
✅ **Flexible transformation system** - customize how prompts are converted to CodeCompanion format
✅ **Smart AI model detection** from VS Code frontmatter

## Installation

**Dependencies:**
- [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim) - Required

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

## Advanced Configuration

### Customizing Prompt Transformation

The plugin uses a flexible transformation system to convert VS Code markdown prompts into CodeCompanion format. You can customize how properties are extracted and transformed:

```lua
local getters = require("vs-code-companion").getters()
local transforms = require("vs-code-companion").transforms()
local defaults = require("vs-code-companion").defaults()

{
  '3ZsForInsomnia/vs-code-companion.nvim',
  opts = {
    directories = {'.github/prompts'},
    transform = {
      -- Use defaults for most properties
      description = defaults.description,
      content = defaults.content,
      strategy = defaults.strategy,

      -- Customize tools handling
      tools = {
        getter = getters.get_tools,
        transform = transforms.transform_tools_full_stack_dev,
      },

      -- Disable certain properties
      mapping = false,

      -- Add custom getter/transform
      custom_property = {
        getter = function(file_info) 
          -- Custom logic to extract value
          return "custom_value"
        end,
        transform = function(value)
          -- Custom logic to transform for CodeCompanion
          return value
        end,
      },
    }
  }
}
```

### Built-in Tool Variants

The plugin provides several built-in approaches for handling VS Code tools:

```lua
-- No tools (default)
local config1 = require("vs-code-companion").create_config_with_tools("none")

-- Use CodeCompanion's full_stack_dev tool for all VS Code tool
local config2 = require("vs-code-companion").create_config_with_tools("full_stack_dev")

-- Attempt to map VS Code tools to CodeCompanion tools (future feature)
local config3 = require("vs-code-companion").create_config_with_tools("mapped")
```

### One-time Import with Custom Config

You can also import prompts with a custom transformation config without changing your main configuration:

```lua
-- Import once with full_stack_dev tools
local custom_config = require("vs-code-companion").create_config_with_tools("full_stack_dev")
require("vs-code-companion").import_prompts_with_config(custom_config)

-- Or create a completely custom config
local getters = require("vs-code-companion").getters()
local transforms = require("vs-code-companion").transforms()

local my_config = {
  description = {
    getter = getters.get_description,
    transform = transforms.transform_description,
    required = true,
  },
  content = {
    getter = getters.get_content,
    transform = function(content, role) 
      -- Custom content transformation
      return {
        role = role or "user",
        content = "CUSTOM PREFIX: " .. content,
      }
    end,
    required = true,
  },
  -- ... other properties
}

require("vs-code-companion").import_prompts_with_config(my_config)
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

### 3. Use Imported Prompts

Open a CodeCompanion chat buffer and use imported prompts as slash commands:
- Type `/` to see all available commands
- Use `/vsc_<filename>` where `<filename>` is your prompt file name (sanitized)
- Example: `test-prompt.md` becomes `/vsc_test_prompt`

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
        },
      },
    },
    -- your other codecompanion config
  }
}
```

This enables `/vs_import` to import VS Code prompts from within a CodeCompanion buffer.

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
  }
}
```

## Future Features

### Planned Enhancements

- **Rules-based Configuration**: Configure different transformation rules based on file paths or names
  ```lua
  rules = {
    {
      pattern = "*.chatmode.md",
      transform = custom_chatmode_config
    },
    {
      pattern = ".github/prompts/**",
      transform = github_prompts_config
    }
  }
  ```
  
- **Required Field Validation**: Mark transformation properties as required and fail gracefully
  ```lua
  transform = {
    description = {
      getter = getters.get_description,
      transform = transforms.transform_description,
      required = true  -- Fail if this can't be extracted
    }
  }
  ```

- **VS Code to CodeCompanion Tool Mapping**: Smart mapping of VS Code tools to equivalent CodeCompanion tools
  ```lua
  -- Future: automatic mapping like this
  vs_code_tools = ["python", "typescript"] 
  -- → codecompanion_tools = "@{python_dev}@{typescript_dev}"
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
