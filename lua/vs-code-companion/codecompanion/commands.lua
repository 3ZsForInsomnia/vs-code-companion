local v = vim

local M = {}

local transformer = require("vs-code-companion.transform.transformer")

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

local create_slash_cmd_prompt = function(file_info, force_overwrite, transform_config)
	force_overwrite = force_overwrite or false
	
	-- Use the transformation system to convert markdown to CodeCompanion format
	local prompt_config, err = transformer.transform_to_codecompanion(file_info, transform_config)
	if not prompt_config then
		return false, err or "Failed to transform prompt"
	end
	
	-- Extract command name from the generated config
	local command_name = prompt_config.opts and prompt_config.opts.short_name
	if not command_name then
		command_name = generate_command_name(file_info.filename)
	end

	local codecompanion_config = ensure_codecompanion_ready()

	if not codecompanion_config.prompt_library then
		codecompanion_config.prompt_library = {}
	end

	-- Skip if already exists (avoid duplicates), unless forcing overwrite
	if codecompanion_config.prompt_library[command_name] and not force_overwrite then
		return false, "Command already exists (use force overwrite to replace)"
	end

	-- Use the transformed prompt config directly
	codecompanion_config.prompt_library[command_name] = prompt_config

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

	local config = require("vs-code-companion.config").get()
	local directories = config.directories
	local transform_config = config.transform -- Will be nil if not configured, which uses defaults
	local files = require("vs-code-companion.utils.files")
	local markdown_prompts = files.get_markdown_files_info(directories)

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
		local success, message = create_slash_cmd_prompt(file_info, false, transform_config)
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

	local config = require("vs-code-companion.config").get()
	local directories = config.directories
	local transform_config = config.transform -- Will be nil if not configured, which uses defaults
	local files = require("vs-code-companion.utils.files")
	local markdown_prompts = files.get_markdown_files_info(directories)

	if #markdown_prompts == 0 then
		v.notify("vs-code-companion: Imported 0/0 prompts successfully", v.log.levels.INFO)
		vim.cmd("echomsg 'vs-code-companion: No prompt files found in configured directories'")
		return false
	end

	local success_count = 0
	local total_count = #markdown_prompts
	local results = {}

	for _, file_info in ipairs(markdown_prompts) do
		local success, message = create_slash_cmd_prompt(file_info, true, transform_config) -- force overwrite for manual import
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
