local v = vim

local M = {}

local models = require("vs-code-companion.codecompanion.models")
local chat = require("vs-code-companion.codecompanion.chat")

local function generate_command_name(filename)
	local name = filename:gsub("%.md$", ""):gsub("[^%w]", "_")
	if not name:match("^[%a_]") then
		name = "_" .. name
	end
	return "vsc_" .. name
end

local create_slash_cmd_prompt = function(file_info, force_overwrite)
	force_overwrite = force_overwrite or false
	
	if not file_info.content or file_info.content == "" then
		v.notify("vs-code-companion: No content to create command from", v.log.levels.WARN)
		return false
	end

	local command_name = generate_command_name(file_info.filename)

	local codecompanion_config = require("codecompanion.config")
	if not codecompanion_config then
		return false
	end

	if not codecompanion_config.prompt_library then
		codecompanion_config.prompt_library = {}
	end

	-- Skip if already exists (avoid duplicates), unless forcing overwrite
	if codecompanion_config.prompt_library[command_name] and not force_overwrite then
		return false
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

	return true
end

function M.import_all_prompts()
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
		return false
	end

	local success_count = 0
	local total_count = #markdown_prompts

	for _, file_info in ipairs(markdown_prompts) do
		if create_slash_cmd_prompt(file_info) then
			success_count = success_count + 1
		end
	end

	return success_count > 0
end

-- Manual import with user feedback (for VsccImport command)
function M.import_all_prompts_with_feedback()
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
		v.notify("vs-code-companion: No prompt files found in configured directories", v.log.levels.WARN)
		return false
	end

	local success_count = 0
	local total_count = #markdown_prompts

	for _, file_info in ipairs(markdown_prompts) do
		if create_slash_cmd_prompt(file_info, true) then -- force overwrite for manual import
			success_count = success_count + 1
		end
	end

	if success_count > 0 then
		v.notify(
			string.format(
				"vs-code-companion: Successfully imported %d/%d prompts as slash commands",
				success_count,
				total_count
			),
			v.log.levels.INFO
		)
		return true
	else
		v.notify("vs-code-companion: Failed to import any prompts", v.log.levels.ERROR)
		return false
	end
end

return M
