local models = require("vs-code-companion.codecompanion.models")
local chat_module = require("vs-code-companion.codecompanion.chat")

local M = {}

function M.handle_file_selection(file_info, chat_instance)
	-- Handle codecompanion prompts differently from markdown files
	if file_info.source == "codecompanion" then
		return M.handle_codecompanion_prompt(file_info, chat_instance)
	end
	
	-- Original logic for markdown files
	if file_info.frontmatter.model then
		models.apply_model_to_chat(file_info.frontmatter.model, chat_instance)
	end

	if file_info.content and file_info.content ~= "" then
		local content = chat_module.append_tool_instruction_if_needed(file_info.content)
		chat_module.add_user_message(content)
	end
end

function M.handle_codecompanion_prompt(prompt_info, chat_instance)
	-- For codecompanion prompts, we need to handle them differently
	-- since they may have system prompts and specific formatting
	
	if prompt_info.frontmatter.model then
		models.apply_model_to_chat(prompt_info.frontmatter.model, chat_instance)
	end
	
	-- For codecompanion prompts, we'll just use the user content for now
	-- In the future, this could be enhanced to handle system prompts differently
	if prompt_info.content and prompt_info.content ~= "" then
		local content = chat_module.append_tool_instruction_if_needed(prompt_info.content)
		chat_module.add_user_message(content)
	end
end

return M
