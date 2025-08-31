local v = vim

local M = {}

local models_util = require("vs-code-companion.utils.models")

function M.resolve_model_name(model_name)
	if not model_name or type(model_name) ~= "string" or model_name:match("^%s*$") then
		v.notify("vs-code-companion: No model name provided for resolution", v.log.levels.WARN)
		return ""
	end

	local technical_name = models_util.get_technical_name(model_name)
	if not technical_name or technical_name == "" then
		v.notify("vs-code-companion: Unknown model '" .. model_name .. "' - check docs/models.md for supported models", v.log.levels.WARN)
		return ""
	end

	return technical_name
end

function M.apply_model_to_chat(model_name, chat_instance)
	local chat_utils = require("vs-code-companion.codecompanion.chat_utils")
	local chat = chat_instance or chat_utils.get_current_chat()

	if not chat then
		v.notify("vs-code-companion: No CodeCompanion chat is open. Please open a chat first.", v.log.levels.ERROR)
		return false
	end

	local technical_name = M.resolve_model_name(model_name)
	if not technical_name or technical_name == "" then
		v.notify("vs-code-companion: Cannot set model - '" .. model_name .. "' is not recognized", v.log.levels.ERROR)
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
			"vs-code-companion: Failed to change to model '" .. technical_name .. "': " .. (err or "CodeCompanion adapter error"),
			v.log.levels.ERROR
		)
		return false
	end
end

return M
