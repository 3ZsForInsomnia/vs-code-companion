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

local create_slash_cmd_prompt = function(file_info)
	if not file_info.content or file_info.content == "" then
		v.notify("vs-code-companion: No content to create command from", v.log.levels.WARN)
		return false
	end

	local command_name = generate_command_name(file_info.filename)
	local content = chat.append_tool_instruction_if_needed(file_info.content)

	local codecompanion_config = require("codecompanion.config")
	if not codecompanion_config then
		return false
	end

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

	if not codecompanion_config.prompt_library then
		codecompanion_config.prompt_library = {}
	end

	codecompanion_config.prompt_library[command_name] = prompt_entry

	v.notify("vs-code-companion: Created slash command /" .. command_name, v.log.levels.INFO)
	return true
end

function M.import_all_prompts()
	local directories = require("vs-code-companion.config").get().directories
	local files = require("vs-code-companion.utils.files")
	local files_info = files.get_markdown_files_info(directories)

	if #files_info == 0 then
		v.notify("vs-code-companion: No markdown files found in configured directories", v.log.levels.WARN)
		return false
	end

	local success_count = 0
	local total_count = #files_info

	for _, file_info in ipairs(files_info) do
		if create_slash_cmd_prompt(file_info) then
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
