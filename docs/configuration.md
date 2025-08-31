# Configuration Guide

This document covers advanced configuration options for vs-code-companion.nvim.

## Basic Configuration

```lua
{
  '3ZsForInsomnia/vs-code-companion.nvim',
  opts = {
    directories = {'.github/prompts', '.github/chatmodes'},
    picker = "auto",
    highlights = {
      -- Custom syntax highlighting options
    },
  }
}
```

## Configuration Options

### Directories

Control where the plugin searches for VS Code prompt files:

```lua
{
  directories = {
    '.github/prompts',      -- Default VS Code location
    '.github/chatmodes',    -- Alternative VS Code location  
    'docs/ai-prompts',      -- Custom documentation location
    'team/shared-prompts',  -- Team-specific prompts
    'personal/prompts'      -- User-specific prompts
  }
}
```

**Notes:**
- Paths are relative to git repository root
- Searches recursively in each directory for `*.md` files
- Must be a non-empty array of strings
- Git repository is required for relative path resolution

### Picker Configuration

Control which UI picker is used for prompt selection:

```lua
{
  picker = "auto"  -- Default: use Telescope if available, fall back to vim.ui.select
}
```

**Options:**
- `"auto"` - Use Telescope if available, fall back to vim.ui.select (recommended)
- `"telescope"` - Force Telescope (error if not available)
- `"vim_ui"` - Force vim.ui.select (basic picker, no previews)

**Telescope Benefits:**
- Fuzzy search with live filtering
- File content previews with syntax highlighting
- Better keyboard navigation
- More responsive interface

### Custom Syntax Highlighting

Customize the appearance of prompt previews in Telescope and other markdown displays:

```lua
{
  highlights = {
    -- YAML frontmatter colors
    yaml_key = { fg = "#79dac8", bold = true },        -- Property names
    yaml_value = { fg = "#e39777" },                   -- Default property values
    yaml_description = { fg = "#ff9e64" },             -- Description field values
    yaml_model = { fg = "#9d7cd8" },                   -- Model field values  
    yaml_tools = { fg = "#73daca" },                   -- Tools field values
    
    -- Multi-message prompt colors (for converted CodeCompanion prompts)
    system_header = { fg = "#f7768e", bold = true },   -- "## Message 1 (system)"
    user_header = { fg = "#9ece6a", bold = true },     -- "## Message 2 (user)"
    system_content = { fg = "#bb9af7" },               -- System message content
    user_content = { fg = "#7dcfff" },                 -- User message content
  }
}
```

**Highlight Groups:**
- `yaml_key` - YAML property names (`description`, `model`, etc.)
- `yaml_description` - Values for the `description` field
- `yaml_model` - Values for the `model` field
- `yaml_tools` - Values for the `tools` field  
- `yaml_value` - Fallback for other YAML values
- `system_header` - Headers for system messages in multi-message prompts
- `user_header` - Headers for user messages in multi-message prompts
- `system_content` - Content of system messages
- `user_content` - Content of user messages

**Color Format:**
Colors can be specified as:
- Hex codes: `{ fg = "#ff0000" }`
- Named colors: `{ fg = "red" }`
- With attributes: `{ fg = "#ff0000", bold = true, italic = true }`

## Complete Example

```lua
{
  '3ZsForInsomnia/vs-code-companion.nvim',
  opts = {
    -- Search multiple directories for prompts
    directories = {
      '.github/prompts',
      '.github/chatmodes',
      'docs/ai-prompts',
      'team/shared-prompts'
    },
    
    -- Force Telescope for better UX
    picker = "telescope",
    
    -- Custom theme colors
    highlights = {
      yaml_key = { fg = "#7aa2f7", bold = true },
      yaml_description = { fg = "#e0af68" },
      yaml_model = { fg = "#bb9af7" },
      yaml_tools = { fg = "#9ece6a" },
      system_header = { fg = "#f7768e", bold = true },
      user_header = { fg = "#9ece6a", bold = true },
    },
  }
}
```

## Validation

The plugin validates all configuration options and will throw descriptive errors for:

- Invalid directory types or empty directory lists
- Unrecognized picker options
- Invalid highlight table structure

Configuration errors are shown immediately when the plugin loads, making it easy to spot and fix issues.