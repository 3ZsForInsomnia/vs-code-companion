local models = require("vs-code-companion.codecompanion.models")
local chat_module = require("vs-code-companion.codecompanion.chat")

local M = {}

function M.handle_file_selection(file_info, chat_instance)
	if file_info.frontmatter.model then
		models.apply_model_to_chat(file_info.frontmatter.model, chat_instance)
	end

	if file_info.content and file_info.content ~= "" then
		local content = chat_module.append_tool_instruction_if_needed(file_info.content)
		chat_module.add_user_message(content)
	end
end

return M
