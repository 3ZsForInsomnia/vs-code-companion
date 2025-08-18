local vs_code_companion = require("vs-code-companion")

-- Main command - automatically uses telescope if available
vim.api.nvim_create_user_command("VsPrompts", function()
	vs_code_companion.select_prompt()
end, {
	desc = "Select from configured prompts",
})

