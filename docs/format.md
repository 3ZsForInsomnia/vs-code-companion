# VS Code Prompt Format

This document details the VS Code prompt file format supported by vs-code-companion.nvim.

## Overview

VS Code prompts use markdown files with YAML frontmatter, following [VS Code's standard prompt format](https://code.visualstudio.com/docs/copilot/customization/prompt-files#_prompt-file-format).

## Basic Format

```markdown
---
description: "Brief description shown in picker"
model: "Claude Sonnet 3.5"
tools: ["optional", "array", "of", "tools"]
---

Your prompt content goes here...

This can be multiple paragraphs, code examples, etc.
```

## YAML Frontmatter

### Required Fields

#### `description` (string)
- **Purpose**: Short description shown in pickers and command descriptions
- **Required**: Yes
- **Example**: `"Review code for bugs and improvements"`
- **Notes**: Used to generate display names and help users identify prompts

### Optional Fields

#### `model` (string)
- **Purpose**: Specify which AI model to use for this prompt
- **Required**: No
- **Example**: `"Claude Sonnet 3.5"`, `"GPT-4o"`, `"Gemini Pro"`
- **Notes**: Uses friendly display names that are automatically converted to technical names

#### `tools` (array of strings)
- **Purpose**: Specify VS Code tools needed for this prompt
- **Required**: No
- **Example**: `["codebase", "search", "usages"]`
- **Notes**: Currently replaced with CodeCompanion's `@{full_stack_dev}` tool

### Example Frontmatter

```yaml
---
description: "Code review with security focus"
model: "Claude Sonnet 3.5"
tools: ["codebase", "search"]
---
```

## Content Section

### Basic Content
The content after the frontmatter is treated as the main prompt text:

```markdown
---
description: "Simple code review"
---

Please review this code for:
- Potential bugs
- Performance issues  
- Security vulnerabilities
- Code style improvements

Focus on practical, actionable feedback.
```

### Multi-line Content
Prompts can include multiple paragraphs, code blocks, and formatting:

```markdown
---
description: "Comprehensive API review"
model: "GPT-4o"
---

# API Review Checklist

Please review this API implementation for:

## Security
- Authentication and authorization
- Input validation and sanitization
- SQL injection prevention

## Performance  
- Database query optimization
- Caching strategies
- Rate limiting

## Code Quality
```javascript
// Example of good error handling
try {
  const result = await apiCall();
  return { success: true, data: result };
} catch (error) {
  logger.error('API call failed', error);
  return { success: false, error: error.message };
}
```

Provide specific, actionable recommendations.
```

## File Validation

The plugin validates prompt files and will skip files that don't meet these requirements:

### Must Have:
1. **Valid YAML frontmatter** - Properly formatted YAML between `---` markers
2. **Description field** - Non-empty string value for `description`
3. **Content** - Non-empty content after the frontmatter

### Optional Validation:
1. **Model field** - If present, must be a string
2. **Tools field** - If present, must be an array of strings

### Invalid Examples

**Missing frontmatter:**
```markdown
This is just a markdown file without frontmatter.
```

**Empty description:**
```markdown
---
description: ""
---
Some content here.
```

**Invalid YAML:**
```markdown
---
description: "Missing closing quote
model: Claude
---
Content here.
```

**No content:**
```markdown
---
description: "Valid frontmatter"
---


```

## Model Name Mapping

Display names in frontmatter are automatically converted to technical names:

### Supported Models

**Anthropic Claude:**
- `"Claude Sonnet 4"` → `claude-4-sonnet`
- `"Claude Sonnet 3.5"` → `claude-3-5-sonnet-20241022`
- `"Claude Haiku"` → `claude-3-5-haiku-20241022`
- `"Claude Opus"` → `claude-3-opus-20240229`

**OpenAI GPT:**
- `"GPT-5"` → `gpt-5`
- `"GPT-5 Mini"` → `gpt-5-mini`
- `"GPT-4o"` → `gpt-4o`
- `"GPT-4"` → `gpt-4`

**Google Gemini:**
- `"Gemini Pro"` → `gemini-2.5-pro`
- `"Gemini Flash"` → `gemini-2.5-flash`

See [Model Mappings](models.md) for the complete list.

## Tool Mapping

Currently, VS Code tools are not directly mapped to CodeCompanion tools. Instead:

- All imported prompts get `@{full_stack_dev}` appended
- This enables CodeCompanion's comprehensive toolset
- Future versions may include more sophisticated tool mapping

## File Organization

### Recommended Structure
```
.github/
├── prompts/
│   ├── code-review.md
│   ├── bug-analysis.md
│   ├── documentation.md
│   └── refactoring.md
└── chatmodes/
    ├── security-review.md
    └── performance-audit.md
```

### Naming Conventions
- Use descriptive filenames: `code-review.md` not `cr.md`
- Use hyphens for spaces: `bug-analysis.md` not `bug analysis.md`
- Files generate command names: `code-review.md` → `/vsc_code_review`

## VS Code Compatibility

This plugin follows VS Code's prompt format specification:

- **Frontmatter fields**: Standard VS Code fields are supported
- **Content format**: Plain markdown content is preserved
- **File structure**: Compatible with VS Code's prompt discovery
- **Tool references**: Syntax compatible (though mapped differently)

Files created for this plugin will work in VS Code, and VS Code prompt files will work with this plugin.

## Advanced Examples

### Complex Prompt with Context
```markdown
---
description: "Database performance optimization"
model: "Claude Sonnet 3.5"
tools: ["codebase", "search"]
---

# Database Performance Analysis

Analyze the provided database code for performance issues.

## Context
- High-traffic web application
- PostgreSQL database
- Current response times > 2 seconds

## Focus Areas

### Query Performance
- Identify N+1 queries
- Check for missing indexes
- Analyze query execution plans

### Schema Design
- Normalize/denormalize recommendations
- Foreign key relationships
- Data type optimization

### Caching Strategy
- Query result caching
- Application-level caching
- Database connection pooling

## Output Format
Provide recommendations in this format:

1. **Issue**: Brief description
2. **Impact**: Performance impact assessment
3. **Solution**: Specific code changes
4. **Priority**: High/Medium/Low

Focus on changes with the highest impact/effort ratio.
```

### Role-based Prompt
```markdown
---
description: "Senior engineer code review"
model: "GPT-4o"
---

You are a senior software engineer with 10+ years of experience reviewing code for production systems.

Review the provided code with the mindset of:
- **Reliability**: Will this work under load?
- **Maintainability**: Can the team support this long-term?
- **Security**: Are there potential vulnerabilities?
- **Performance**: Will this scale with user growth?

Provide feedback as if you're mentoring a junior developer - be thorough but constructive.
```