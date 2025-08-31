local v = vim

local M = {}

local models = require("vs-code-companion.codecompanion.models")
local chat = require("vs-code-companion.codecompanion.chat")

-- Helper function to ensure CodeCompanion is available and ready
local function ensure_codecompanion_ready()
	local ok, codecompanion_config = pcall(require, "codecompanion.config")
	if not ok then
		error("vs-code-companion: CodeCompanion is not installed or loaded. Please ensure codecompanion.nvim is properly installed and configured.")
	end
	
	if not codecompanion_config then
		error("vs-code-companion: CodeCompanion configuration is not available. Please ensure CodeCompanion is properly set up.")
	end
	
	return codecompanion_config
end

local function generate_command_name(filename)
	if not filename or type(filename) ~= "string" or filename:match("^%s*$") then
		error("vs-code-companion: Cannot generate command name from empty/invalid filename")
	end
	
	-- Remove .md extension and sanitize
	local name = filename:gsub("%.md$", ""):gsub("[^%w]", "_"):lower()
	
	-- Remove any leading/trailing underscores and collapse multiple underscores
	name = name:gsub("^_+", ""):gsub("_+$", ""):gsub("_+", "_")
	
	-- After sanitization, ensure we still have something meaningful
	if name == "" then
		error("vs-code-companion: Filename '" .. filename .. "' produces no valid command name after sanitization")
	end
	
	-- Ensure it starts with a letter or underscore (for Lua identifier rules)
	if not name:match("^[%a_]") then
		name = "_" .. name
	end
	
	return "vsc_" .. name
end

local create_slash_cmd_prompt = function(file_info, force_overwrite)
	force_overwrite = force_overwrite or false
	
	if not file_info.content or file_info.content == "" then
		return false, "No content to create command from"
	end

	local command_name = generate_command_name(file_info.filename)

	local codecompanion_config = ensure_codecompanion_ready()

	if not codecompanion_config.prompt_library then
		codecompanion_config.prompt_library = {}
	end

	-- Skip if already exists (avoid duplicates), unless forcing overwrite
	if codecompanion_config.prompt_library[command_name] and not force_overwrite then
		return false, "Command already exists (use force overwrite to replace)"
	end

	local content = chat.append_tool_instruction_if_needed(file_info.content)

	local prompt_entry = {
		strategy = "chat",
		description = file_info.frontmatter.description or ("Prompt from " .. file_info.filename),
		opts = {
			is_slash_cmd = true,
			short_name = command_name,
			auto_submit = false,
		},
		prompts = {
			{
				role = "user",
				content = content,
			},
		},
	}

	if file_info.frontmatter.model then
		local technical_name = models.resolve_model_name(file_info.frontmatter.model)
		if technical_name and technical_name ~= "" then
			prompt_entry.opts.model = technical_name
		end
	end

	codecompanion_config.prompt_library[command_name] = prompt_entry

	return true, "Successfully imported as /" .. command_name
end

function M.import_all_prompts()
	-- Ensure CodeCompanion is ready before attempting any imports
	local ok, err = pcall(ensure_codecompanion_ready)
	if not ok then
		v.notify("vs-code-companion: Import failed - " .. (err or "CodeCompanion not available"), v.log.levels.ERROR)
		vim.cmd("echomsg 'vs-code-companion: " .. (err or "CodeCompanion not available") .. "'")
		return false
	end

	local directories = require("vs-code-companion.config").get().directories
	local prompts = require("vs-code-companion.utils.prompts")
	local prompts_info = prompts.get_all_prompts_info(directories)

	-- Filter to only markdown files for import (don't import codecompanion prompts as they're already there)
	local markdown_prompts = {}
	for _, prompt in ipairs(prompts_info) do
		if prompt.source == "markdown" then
			table.insert(markdown_prompts, prompt)
		end
	end

	if #markdown_prompts == 0 then
		-- Always notify about import results
		v.notify("vs-code-companion: Imported 0/0 prompts successfully", v.log.levels.INFO)
		vim.cmd("echomsg 'vs-code-companion: No prompt files found in configured directories'")
		return false
	end

	local success_count = 0
	local total_count = #markdown_prompts
	local results = {}

	for _, file_info in ipairs(markdown_prompts) do
		local success, message = create_slash_cmd_prompt(file_info)
		if success then
			success_count = success_count + 1
			table.insert(results, {
				filename = file_info.filename,
				success = true,
				message = message
			})
		else
			table.insert(results, {
				filename = file_info.filename,
				success = false,
				message = message
			})
		end
	end
	-- Always notify about import results
	v.notify(string.format("vs-code-companion: Imported %d/%d prompts successfully", success_count, total_count), v.log.levels.INFO)
	
	-- Always log detailed results to :messages
	for _, result in ipairs(results) do
		if result.success then
			vim.cmd(string.format("echomsg 'vs-code-companion: %s - %s'", result.filename, result.message))
		else
			vim.cmd(string.format("echomsg 'vs-code-companion: Failed to import %s - %s'", result.filename, result.message))
		end
	end

	return success_count > 0
end
function M.import_all_prompts_with_feedback()
	-- Ensure CodeCompanion is ready before attempting any imports
	local ok, err = pcall(ensure_codecompanion_ready)
	if not ok then
		v.notify("vs-code-companion: Import failed - " .. (err or "CodeCompanion not available"), v.log.levels.ERROR)
		vim.cmd("echomsg 'vs-code-companion: " .. (err or "CodeCompanion not available") .. "'")
		return false
	end

	local directories = require("vs-code-companion.config").get().directories
	local prompts = require("vs-code-companion.utils.prompts")
	local prompts_info = prompts.get_all_prompts_info(directories)

	-- Filter to only markdown files for import
	local markdown_prompts = {}
	for _, prompt in ipairs(prompts_info) do
		if prompt.source == "markdown" then
			table.insert(markdown_prompts, prompt)
		end
	end

	if #markdown_prompts == 0 then
		v.notify("vs-code-companion: Imported 0/0 prompts successfully", v.log.levels.INFO)
		vim.cmd("echomsg 'vs-code-companion: No prompt files found in configured directories'")
		return false
	end

	local success_count = 0
	local total_count = #markdown_prompts
	local results = {}

	for _, file_info in ipairs(markdown_prompts) do
		local success, message = create_slash_cmd_prompt(file_info, true) -- force overwrite for manual import
		if success then
			success_count = success_count + 1
			table.insert(results, {
				filename = file_info.filename,
				success = true,
				message = message
			})
		else
			table.insert(results, {
				filename = file_info.filename,
				success = false,
				message = message
			})
		end
	end

	-- Always notify about import results
	v.notify(string.format("vs-code-companion: Imported %d/%d prompts successfully", success_count, total_count), v.log.levels.INFO)
	
	-- Always log detailed results to :messages
	for _, result in ipairs(results) do
		if result.success then
			vim.cmd(string.format("echomsg 'vs-code-companion: %s - %s'", result.filename, result.message))
		else
			vim.cmd(string.format("echomsg 'vs-code-companion: Failed to import %s - %s'", result.filename, result.message))
		end
	end
end

return M
