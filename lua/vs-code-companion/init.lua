local M = {}

function M.setup(user_config)
	require("vs-code-companion.config").setup(user_config or {})

	-- Auto-import VS Code prompts on setup
	require("vs-code-companion.codecompanion.commands").import_all_prompts()
end

-- Public utility for getting all prompts (markdown + codecompanion)
M.get_all_prompts = function(directories)
	local prompts = require("vs-code-companion.utils.prompts")
	local config = require("vs-code-companion.config")
	directories = directories or config.get().directories
	return prompts.get_all_prompts_info(directories)
end

-- Public utility for creating display text for prompts
M.create_prompt_display_text = function(prompt_info)
	local prompts = require("vs-code-companion.utils.prompts")
	return prompts.create_display_text(prompt_info)
end

-- Public utility for converting codecompanion prompts to markdown
M.codecompanion_to_markdown = function(prompt_data, prompt_name)
	local markdown_converter = require("vs-code-companion.utils.markdown_converter")
	return markdown_converter.codecompanion_to_markdown(prompt_data, prompt_name)
end

-- Public utility for applying markdown highlighting
M.apply_markdown_highlighting = function(bufnr, lines, highlights)
	local highlighting = require("vs-code-companion.utils.highlighting")
	highlighting.apply_markdown_highlighting(bufnr, lines, highlights)
end

-- Public utility for safely getting prompt content (handles function content)
M.get_prompt_content = function(prompt)
	local markdown_converter = require("vs-code-companion.utils.markdown_converter")
	return markdown_converter.get_prompt_content(prompt)
end

-- Public utility for validating if a markdown file is a proper prompt file
M.is_valid_prompt_file = function(parsed_content)
	local files = require("vs-code-companion.utils.files")
	return files.is_valid_prompt_file(parsed_content)
end

M.import_slash_command = {
	description = "Import from VS Code",
	callback = function()
		require("vs-code-companion.codecompanion.commands").import_all_prompts_with_feedback()
	end,
}

M.select_slash_command = {
	description = "Select from VS Code",
	callback = function()
		require("vs-code-companion.commands").handle_selection()
	end,
}

return M
