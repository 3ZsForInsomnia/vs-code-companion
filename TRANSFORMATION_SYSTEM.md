# VS Code Companion Transformation System

## Overview

This document explains the new transformation system that converts VS Code markdown prompts into CodeCompanion prompt configurations.

## Architecture

The transformation system consists of several modular components:

### 1. Getters (`lua/vs-code-companion/transform/getters.lua`)
Functions that extract values from markdown file info:
- `get_description()` - Extracts description from frontmatter
- `get_content()` - Extracts content after frontmatter  
- `get_model()` - Extracts model from frontmatter
- `get_tools()` - Extracts tools array from frontmatter
- `get_strategy()` - Always returns "chat" for VS Code prompts
- `get_command_name()` - Generates command name from filename
- Plus getters for all other CodeCompanion properties

### 2. Transforms (`lua/vs-code-companion/transform/transforms.lua`)
Functions that convert raw values to CodeCompanion format:
- `transform_description()` - Pass through description as-is
- `transform_content()` - Convert to prompts array format with role
- `transform_model()` - Resolve display names to technical names
- `transform_tools_*()` - Multiple strategies for handling tools
- Plus transforms for all other properties

### 3. Defaults (`lua/vs-code-companion/transform/defaults.lua`)
Pre-configured getter/transform pairs for all properties:
- `defaults.description` - Required field configuration
- `defaults.content` - Required field configuration  
- `defaults.tools` - Configurable with multiple variants
- Complete coverage of all CodeCompanion prompt properties

### 4. Transformer (`lua/vs-code-companion/transform/transformer.lua`)
Core transformation engine:
- `transform_to_codecompanion()` - Main transformation function
- `merge_transform_config()` - Merge custom config with defaults
- `create_config_with_tools()` - Helper for tool variants

## Usage Examples

### Basic Usage (Uses Defaults)
```lua
require("vs-code-companion").setup({
  directories = {".github/prompts"}
  -- No transform config = uses defaults
})
```

### Custom Configuration
```lua
local getters = require("vs-code-companion").getters()
local transforms = require("vs-code-companion").transforms()

require("vs-code-companion").setup({
  transform = {
    description = {
      getter = getters.get_description,
      transform = transforms.transform_description,
      required = true,
    },
    tools = {
      getter = getters.get_tools,
      transform = transforms.transform_tools_full_stack_dev,
    },
    mapping = false, -- Disable property
  }
})
```

### Tool Variants
```lua
-- No tools (default)
local config = require("vs-code-companion").create_config_with_tools("none")

-- Use full_stack_dev for all tools
local config = require("vs-code-companion").create_config_with_tools("full_stack_dev")

-- Future: smart mapping
local config = require("vs-code-companion").create_config_with_tools("mapped")
```

### One-time Custom Import
```lua
local custom_config = require("vs-code-companion").create_config_with_tools("full_stack_dev")
require("vs-code-companion").import_prompts_with_config(custom_config)
```

## Extension Points

### Custom Getters
```lua
local custom_getter = function(file_info)
  -- Extract custom value from file_info
  return "custom_value"
end
```

### Custom Transforms
```lua
local custom_transform = function(raw_value)
  -- Convert raw value to CodeCompanion format
  return processed_value
end
```

### Complete Custom Property
```lua
transform = {
  my_property = {
    getter = custom_getter,
    transform = custom_transform,
    required = false, -- optional
  }
}
```

## Backward Compatibility

The new system is fully backward compatible:
- Default behavior unchanged if no transform config provided
- Existing import commands work exactly the same
- All existing functionality preserved

## Future Enhancements

1. **Rules-based Configuration** - Different configs for different file patterns
2. **Required Field Validation** - Mark properties as required with graceful failure
3. **Smart Tool Mapping** - Automatic mapping of VS Code tools to CodeCompanion tools

## Implementation Notes

- Uses pcall for safe error handling
- Validates required fields before transformation
- Preserves existing chat.append_tool_instruction_if_needed logic
- Maintains CodeCompanion prompt structure requirements
- Supports all documented CodeCompanion prompt properties
