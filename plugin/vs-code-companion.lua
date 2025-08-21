if vim.g.loaded_vs_code_companion then
	return
end
vim.g.loaded_vs_code_companion = 1

local function lazy_setup()
	if not vim.g.vs_code_companion_setup then
		require("vs-code-companion").setup()
		vim.g.vs_code_companion_setup = true
	end
end

vim.api.nvim_create_user_command("VsccSelect", function()
	lazy_setup()
	require("vs-code-companion.commands").handle_selection()
end, { desc = "Select and use a prompt from configured directories" })

vim.api.nvim_create_user_command("VsccImport", function()
	lazy_setup()
	require("vs-code-companion.codecompanion.commands").import_all_prompts()
end, { desc = "Import all prompts as slash commands" })
