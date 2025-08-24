local setup = function(opts)
	require("vs-code-companion.config").setup(opts or {})
	require("vs-code-companion.commands")
end

local exports = {
	library_prompts = {
		description = "Search and apply prompts from configured directories",
		callback = function(chat)
			-- Always re-import VS Code prompts before selection (fast!)
			require("vs-code-companion.codecompanion.commands").import_all_prompts()
			
			local directories = require("vs-code-companion.config").get().directories
			local display = require("vs-code-companion.ui.display")
			local pickers = require("vs-code-companion.ui.pickers")
			local handlers = require("vs-code-companion.ui.handlers")
			local prompts = require("vs-code-companion.utils.prompts")

			-- Now get only codecompanion prompts (since we just imported everything)
			local prompts_info = prompts.get_codecompanion_prompts_info()

			if #prompts_info == 0 then
				display.show_no_prompts_error()
				return
			end

			local selection_handler = function(file_info)
				handlers.handle_file_selection(file_info, chat)
			end

			if not pickers.try_telescope_picker(directories, selection_handler) then
				pickers.use_vim_ui_select(prompts_info, selection_handler)
			end
		end,
		opts = {},
	},
}

return {
	setup = setup,
	exports = exports,
}
