# Integrations and Extensions

This document covers integrating vs-code-companion.nvim with other tools and building custom extensions.

## CodeCompanion Integration

### Slash Commands

Add VS Code prompt functionality directly to CodeCompanion chat buffers:

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

**Available Commands:**
- `/vs_import` - Import VS Code prompts from within a CodeCompanion buffer
- `/vs_select` - Select and apply prompts from within a CodeCompanion buffer

### Extension System

This plugin also registers as a CodeCompanion extension, providing the `library_prompts` function:

```lua
-- Automatically available in CodeCompanion's extension system
-- Provides fuzzy search over all available prompts
```

## Custom Picker Integration

### Building Custom Pickers

Use the public API to integrate with other picker frameworks like [snacks.nvim](https://github.com/folke/snacks.nvim):

```lua
local function snacks_prompt_picker()
  local prompts = require("vs-code-companion").get_all_prompts()
  local snacks = require("snacks")
  
  local items = {}
  for _, prompt in ipairs(prompts) do
    table.insert(items, {
      text = require("vs-code-companion").create_prompt_display_text(prompt),
      data = prompt,
    })
  end
  
  snacks.picker({
    items = items,
    preview = function(item)
      if item.data.source == "markdown" then
        return { file = item.data.filepath }
      else
        return { 
          text = require("vs-code-companion").codecompanion_to_markdown(
            item.data.prompt_data, 
            item.data.name
          )
        }
      end
    end,
    on_select = function(item)
      require("vs-code-companion.ui.handlers").handle_file_selection(item.data)
    end,
  })
end

-- Create a command for your custom picker
vim.api.nvim_create_user_command("MyPromptPicker", snacks_prompt_picker, {})
```

### Telescope Extension

The plugin includes a Telescope extension that's automatically loaded:

```lua
-- Use the Telescope extension directly
require("telescope").extensions.vs_code_companion.prompts()

-- Or with custom handler
require("telescope").extensions.vs_code_companion.prompts(directories, custom_handler)
```

## Public API Reference

### Core Functions

```lua
local vs_companion = require("vs-code-companion")

-- Get all available prompts (markdown + codecompanion)
local prompts = vs_companion.get_all_prompts(directories)
-- Returns: array of prompt info objects

-- Create display text for UI
local display = vs_companion.create_prompt_display_text(prompt_info)
-- Returns: formatted string like "Code Review - Review code for bugs and improvements"

-- Convert codecompanion prompt to markdown
local markdown = vs_companion.codecompanion_to_markdown(prompt_data, name)
-- Returns: markdown string with YAML frontmatter

-- Validate prompt file format
local is_valid = vs_companion.is_valid_prompt_file(parsed_content)
-- Returns: boolean

-- Get prompt content (handles function content)
local content = vs_companion.get_prompt_content(prompt)
-- Returns: string content

-- Safe file reading with proper resource management
local content, err = vs_companion.read_file_safely(filepath)
-- Returns: content string or nil, error_message

-- Apply syntax highlighting to markdown buffer
vs_companion.apply_markdown_highlighting(bufnr, lines, highlights)
-- Returns: nothing (applies highlighting in-place)
```

### Prompt Info Object Structure

```lua
{
  source = "markdown" | "codecompanion",     -- Where the prompt came from
  filename = "code-review.md",               -- Original filename
  filepath = "/path/to/file.md",             -- Full path (nil for codecompanion)
  name = "vsc_code_review",                  -- Command name (for codecompanion)
  frontmatter = {                            -- Parsed YAML frontmatter
    description = "Review code for bugs",
    model = "Claude Sonnet 3.5",
    tools = {"codebase", "search"}
  },
  content = "Your prompt content...",        -- Main prompt text
  raw_content = "---\n...",                  -- Full file content with frontmatter
  prompt_data = {...}                        -- Original codecompanion data (if applicable)
}
```

### Selection Handlers

```lua
-- Handle prompt selection (opens CodeCompanion chat with prompt)
require("vs-code-companion.ui.handlers").handle_file_selection(prompt_info, chat_instance)

-- Handle codecompanion-specific prompts  
require("vs-code-companion.ui.handlers").handle_codecompanion_prompt(prompt_info, chat_instance)
```

## Tool Integration Examples

### Creating a Custom Command

```lua
-- Create a custom command that filters to specific directories
local function engineering_prompts()
  local prompts = require("vs-code-companion").get_all_prompts({
    'engineering/prompts',
    'team/engineering'
  })
  
  -- Use your preferred picker...
  vim.ui.select(prompts, {
    prompt = "Engineering Prompts",
    format_item = function(prompt)
      return require("vs-code-companion").create_prompt_display_text(prompt)
    end
  }, function(selected)
    if selected then
      require("vs-code-companion.ui.handlers").handle_file_selection(selected)
    end
  end)
end

vim.api.nvim_create_user_command("EngineeringPrompts", engineering_prompts, {})
```

### Integration with Other Plugins

```lua
-- Integration with which-key.nvim
local wk = require("which-key")
wk.register({
  ["<leader>p"] = {
    name = "Prompts",
    i = { "<cmd>VsccImport<cr>", "Import VS Code Prompts" },
    s = { "<cmd>VsccSelect<cr>", "Select Prompt" },
    e = { "<cmd>EngineeringPrompts<cr>", "Engineering Prompts" },
  }
})

-- Integration with legendary.nvim
require("legendary").setup({
  commands = {
    { ":VsccImport", description = "Import VS Code prompts" },
    { ":VsccSelect", description = "Select and apply prompt" },
  }
})
```

## Architecture Notes

### Module Structure

```
lua/vs-code-companion/
├── init.lua                    # Public API and setup
├── config.lua                  # Configuration management  
├── commands.lua                # User command handlers
├── codecompanion/              # CodeCompanion integration
│   ├── commands.lua            # Import/management functions
│   ├── models.lua              # Model name resolution
│   ├── chat.lua                # Chat integration
│   └── chat_utils.lua          # Chat utilities
├── ui/                         # User interface
│   ├── pickers.lua             # Picker selection logic
│   ├── handlers.lua            # Selection handlers  
│   └── display.lua             # Display formatting
└── utils/                      # Core utilities
    ├── files.lua               # File system operations
    ├── prompts.lua             # Prompt data management
    ├── frontmatter.lua         # YAML parsing
    ├── models.lua              # Model mappings
    ├── highlighting.lua        # Syntax highlighting
    └── markdown_converter.lua  # Format conversion
```

### Extension Points

The plugin provides several extension points:

1. **Custom pickers** via public API functions
2. **Model mappings** via `utils/models.lua` 
3. **Syntax highlighting** via configuration
4. **Selection handlers** for custom workflow integration

### Error Handling

- All public API functions use `pcall` for safety
- File processing errors are always logged to `:messages`
- Import operations provide comprehensive feedback
- Resource management ensures proper cleanup

All file processing errors and detailed information are logged to `:messages` for diagnosis.