local v = vim

local M = {}

local models_util = require("vs-code-companion.utils.models")

function M.resolve_model_name(model_name)
	if not model_name then
		v.notify("vs-code-companion: No model specified", v.log.levels.WARN)
		return ""
	end

	local technical_name = models_util.get_technical_name(model_name)
	if not technical_name then
		v.notify("vs-code-companion: Could not resolve model name: " .. model_name, v.log.levels.ERROR)
		return ""
	end

	return technical_name
end

function M.apply_model_to_chat(model_name, chat_instance)
	local chat_utils = require("vs-code-companion.codecompanion.chat_utils")
	local chat = chat_instance or chat_utils.get_current_chat()

	if not chat then
		v.notify("vs-code-companion: No chat instance available", v.log.levels.ERROR)
		return false
	end

	local technical_name = M.resolve_model_name(model_name)
	if not technical_name or technical_name == "" then
		v.notify("vs-code-companion: Invalid model name: " .. model_name, v.log.levels.ERROR)
		return false
	end

	local success, err = pcall(function()
		chat:change_adapter(technical_name)
	end)

	if success then
		v.notify("vs-code-companion: Model set to " .. technical_name, v.log.levels.INFO)
		return true
	else
		v.notify(
			"vs-code-companion: Failed to set model to " .. technical_name .. ". Reason: " .. (err or "unknown error"),
			v.log.levels.ERROR
		)
		return false
	end
end

return M
