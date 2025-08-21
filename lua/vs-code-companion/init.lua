local M = {}

function M.setup(user_config)
	require("vs-code-companion.config").setup(user_config or {})
end

M.import_slash_command = {
	description = "Import from VS Code",
	callback = function()
		require("vs-code-companion.codecompanion.commands").import_all_prompts()
	end,
}

M.select_slash_command = {
	description = "Select from VS Code",
	callback = function()
		require("vs-code-companion.commands").handle_selection()
	end,
}

return M
