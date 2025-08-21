local v = vim

local M = {}

local chat_utils = require("vs-code-companion.codecompanion.chat_utils")

-- Eventually this might actually map VSC tools to Code Companion tools
-- However for now, there is not a clear mapping of tools, so just using full_stack_dev
function M.append_tool_instruction_if_needed(content)
	return content .. "\nPlease use the @{full_stack_dev} tool"
end

function M.add_user_message(content)
	if not content or content == "" then
		v.notify("vs-code-companion: No content to send", v.log.levels.WARN)
		return false
	end

	local chat = chat_utils.get_current_chat()
	if chat and chat.add_buf_message then
		chat:add_buf_message({
			content = content .. "\n",
		})
		return true
	end

	if chat_utils.ensure_chat_open() then
		v.defer_fn(function()
			local new_chat = chat_utils.get_current_chat()
			if new_chat and new_chat.add_buf_message then
				new_chat:add_buf_message({
					content = content,
				})
			else
				v.notify("vs-code-companion: Could not get chat instance", v.log.levels.ERROR)
			end
		end, 100)
	end

	return true
end

return M
