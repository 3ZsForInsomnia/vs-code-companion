# Model Mappings

This document lists the AI model name mappings used by vs-code-companion.nvim.

## Overview

VS Code prompts often use "friendly" model names in their YAML frontmatter, while AI providers typically require specific technical model identifiers. This plugin automatically converts between the two formats.

## Supported Model Mappings

| Display Name (VS Code) | Technical Name (Provider) |
|------------------------|---------------------------|
| Claude Sonnet 4 | claude-4-sonnet |
| Claude Sonnet 3.5 | claude-3-5-sonnet-20241022 |
| Claude Sonnet | claude-3-5-sonnet-20241022 |
| Claude Haiku 3.5 | claude-3-5-haiku-20241022 |
| Claude Haiku | claude-3-5-haiku-20241022 |
| Claude Opus 3 | claude-3-opus-20240229 |
| Claude Opus | claude-3-opus-20240229 |

### OpenAI Models

| Display Name | Technical Name |
|--------------|----------------|
| GPT-4 | gpt-4 |
| GPT-4 Turbo | gpt-4-turbo-preview |
| GPT-4o | gpt-4o |
| GPT-4o Mini | gpt-4o-mini |
| GPT-3.5 Turbo | gpt-3.5-turbo |
| GPT-5 | gpt-5 |
| GPT-5 Mini | gpt-5-mini |
| GPT-5 Nano | gpt-5-nano |
| GPT-5 Chat | gpt-5-chat |
| GPT-5 Chat Latest | gpt-5-chat-latest |

### Google Models

| Display Name | Technical Name |
|--------------|----------------|
| Gemini 2.5 Pro | gemini-2.5-pro |
| Gemini 2.5 Flash | gemini-2.5-flash |
| Gemini Pro | gemini-2.5-pro |
| Gemini Flash | gemini-2.5-flash |

### Other Models

| Display Name | Technical Name |
|--------------|----------------|
| Llama 70B | llama-70b |
| Llama 8B | llama-8b |

## Usage in Prompts

Use the display names in your VS Code prompt files:

```markdown
---
description: "Code review with Claude"
model: "Claude Sonnet 3.5"
---

Please review this code...
```

The plugin will automatically convert "Claude Sonnet 3.5" to "claude-3-5-sonnet-20241022" when setting up the CodeCompanion chat.

## Case Insensitive Matching

Model name matching is case-insensitive, so these are all equivalent:
- `"Claude Sonnet 3.5"`
- `"claude sonnet 3.5"`
- `"CLAUDE SONNET 3.5"`

## Adding New Models

To add support for new models, edit `lua/vs-code-companion/utils/models.lua`:

```lua
local model_mappings = {
  -- Add your new mapping here
  ["Your Display Name"] = "technical-model-name",
  
  -- Existing mappings...
  ["Claude Sonnet 3.5"] = "claude-3-5-sonnet-20241022",
  -- ...
}
```

## Unknown Models

If a model name in a VS Code prompt is not recognized:
1. A warning is logged
2. The model name is passed through unchanged to CodeCompanion
3. CodeCompanion will handle the unknown model according to its own configuration

## Model Validation

The plugin validates model names when:
1. **Importing prompts** - Invalid model names are logged but don't prevent import
2. **Applying prompts** - Invalid models trigger warnings but don't block prompt usage
3. **File validation** - Model fields must be strings if present

## Provider-Specific Notes

### Anthropic (Claude)
- Date suffixes in technical names reflect specific model versions
- "Sonnet" and "Haiku" without version numbers default to latest 3.5 versions
- "Opus" defaults to the 3.0 version

### OpenAI (GPT)
- "GPT-4 Turbo" maps to the preview version
- Version numbers are preserved in technical names
- "GPT-4o" is the optimized GPT-4 variant

### Google (Gemini)
- Version 2.5 is the current generation
- "Pro" and "Flash" variants have different performance characteristics
- Short names ("Gemini Pro") map to current versions

### Meta (Llama)
- Parameter counts (70B, 8B) distinguish model sizes
- Technical names use lowercase and hyphens

## Future Considerations

- Dynamic model discovery from provider APIs
- User-configurable model mappings
- Validation against CodeCompanion's available adapters
- Support for model parameters and configuration options