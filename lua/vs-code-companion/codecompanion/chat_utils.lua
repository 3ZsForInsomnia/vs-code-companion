local v = vim

local M = {}

function M.get_current_chat()
	if v.bo.filetype ~= "codecompanion" then
		return nil
	end

	local chat_strategy = require("codecompanion.strategies.chat")
	if not chat_strategy then
		return nil
	end

	local bufnr = v.api.nvim_get_current_buf()
	local chat = chat_strategy.buf_get_chat(bufnr)

	if not chat then
		chat = chat_strategy.last_chat()
	end

	return chat
end

function M.ensure_chat_open()
	if v.bo.filetype == "codecompanion" then
		return true
	end

	v.cmd("CodeCompanionChat Toggle")

	v.defer_fn(function()
		if v.bo.filetype ~= "codecompanion" then
			v.notify("vs-code-companion: Failed to open CodeCompanion chat", v.log.levels.ERROR)
		end
	end, 50)

	return true
end

return M
