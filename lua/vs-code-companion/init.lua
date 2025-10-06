local M = {}

local setup_done = false

function M.setup(user_config)
	if setup_done then
		return
	end

	-- Public API for importing prompts with custom transform config
	M.import_prompts_with_config = function(transform_config)
		local ok, err = pcall(function()
			local codecompanion_commands = require("vs-code-companion.codecompanion.commands")

			-- Temporarily override the config's transform setting
			local config = require("vs-code-companion.config")
			local original_config = config.get()
			local temp_config = vim.tbl_deep_extend("force", original_config, { transform = transform_config })

			-- Create a temporary override function
			local original_get = config.get
			config.get = function()
				return temp_config
			end

			-- Run the import
			local success = codecompanion_commands.import_all_prompts_with_feedback()

			-- Restore original config
			config.get = original_get

			return success
		end)

		if not ok then
			vim.notify(
				"vs-code-companion: Import with custom config failed - " .. (err or "unknown error"),
				vim.log.levels.ERROR
			)
			return false
		end

		return ok
	end

	require("vs-code-companion.config").setup(user_config or {})

	-- Auto-import VS Code prompts on setup
	vim.schedule(function()
		require("vs-code-companion.codecompanion.commands").import_all_prompts()
	end)

	setup_done = true
end

-- Public API for creating custom transformation configs
M.create_transform_config = function(custom_config)
	local transformer = require("vs-code-companion.transform.transformer")
	return transformer.merge_transform_config(custom_config)
end

-- Public API for using specific tool variants
M.create_config_with_tools = function(tool_variant)
	local transformer = require("vs-code-companion.transform.transformer")
	return transformer.create_config_with_tools(tool_variant)
end

-- Public API for accessing built-in getters
M.getters = function()
	return require("vs-code-companion.transform.getters")
end

-- Public API for accessing built-in transforms
M.transforms = function()
	return require("vs-code-companion.transform.transforms")
end

-- Public API for accessing defaults
M.defaults = function()
	return require("vs-code-companion.transform.defaults")
end

M.get_all_prompts = function(directories)
	-- Get markdown files for importing purposes
	local config = require("vs-code-companion.config")
	directories = directories or config.get().directories

	local files = require("vs-code-companion.utils.files")
	return files.get_markdown_files_info(directories)
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

return M
