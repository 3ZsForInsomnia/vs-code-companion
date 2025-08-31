local M = {}

local setup_done = false

function M.setup(user_config)
	if setup_done then
		return
	end
	
	require("vs-code-companion.config").setup(user_config or {})

	-- Auto-import VS Code prompts on setup
	vim.schedule(function()
		require("vs-code-companion.codecompanion.commands").import_all_prompts()
	end)
	
	setup_done = true
end

M.get_all_prompts = function(directories)
	local ok, result = pcall(function()
		-- Check if CodeCompanion is available for getting codecompanion prompts
		local has_codecompanion = pcall(require, "codecompanion.config")
		if not has_codecompanion then
			vim.notify("vs-code-companion: CodeCompanion not available - only showing markdown prompts", vim.log.levels.WARN)
		end
		
		local prompts = require("vs-code-companion.utils.prompts")
		local config = require("vs-code-companion.config")
		directories = directories or config.get().directories
		return prompts.get_all_prompts_info(directories)
	end)
	
	if not ok then
		vim.notify("vs-code-companion: Failed to get prompts: " .. result, vim.log.levels.ERROR)
		return {}
	end
	
	return result
end

-- Public utility for creating display text for prompts
M.create_prompt_display_text = function(prompt_info)
	if not prompt_info then
		return "Unknown prompt"
	end
	
	local ok, result = pcall(function()
		local prompts = require("vs-code-companion.utils.prompts")
		return prompts.create_display_text(prompt_info)
	end)
	
	if not ok then
		return "Error displaying prompt"
	end
	
	return result
end

-- Public utility for converting codecompanion prompts to markdown
M.codecompanion_to_markdown = function(prompt_data, prompt_name)
	if not prompt_data then
		return ""
	end
	
	local ok, result = pcall(function()
		local markdown_converter = require("vs-code-companion.utils.markdown_converter")
		return markdown_converter.codecompanion_to_markdown(prompt_data, prompt_name)
	end)
	
	if not ok then
		return ""
	end
	
	return result
end

-- Public utility for applying markdown highlighting
M.apply_markdown_highlighting = function(bufnr, lines, highlights)
	if not bufnr or not lines then
		return
	end
	
	pcall(function()
		local highlighting = require("vs-code-companion.utils.highlighting")
		highlighting.apply_markdown_highlighting(bufnr, lines, highlights)
	end)
end

-- Public utility for safely getting prompt content (handles function content)
M.get_prompt_content = function(prompt)
	if not prompt then
		return ""
	end
	
	local ok, result = pcall(function()
		local markdown_converter = require("vs-code-companion.utils.markdown_converter")
		return markdown_converter.get_prompt_content(prompt)
	end)
	
	if not ok then
		return ""
	end
	
	return result
end

M.is_valid_prompt_file = function(parsed_content)
	if not parsed_content then
		return false
	end
	
	local ok, result = pcall(function()
		local files = require("vs-code-companion.utils.files")
		return files.is_valid_prompt_file(parsed_content)
	end)
	
	if not ok then
		return false
	end
	
	return result
end

-- Public utility for safe file reading with proper resource management
M.read_file_safely = function(filepath)
	if not filepath then
		return nil, "Invalid filepath provided"
	end
	
	local ok, result, err = pcall(function()
		local files = require("vs-code-companion.utils.files")
		return files.read_file_safely(filepath)
	end)
	
	if not ok then
		return nil, "Error reading file: " .. (result or "unknown error")
	end
	
	return result, err
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
