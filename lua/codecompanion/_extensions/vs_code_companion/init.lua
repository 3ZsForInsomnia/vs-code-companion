local setup = function(opts)
	require("vs-code-companion.config").setup(opts or {})
	require("vs-code-companion.commands")
end

local exports = {
	library_prompts = {
		description = "Search and apply prompts from configured directories",
		callback = function(chat)
			local directories = require("vs-code-companion.config").get().directories
			local display = require("vs-code-companion.ui.display")
			local pickers = require("vs-code-companion.ui.pickers")
			local handlers = require("vs-code-companion.ui.handlers")
			local files = require("vs-code-companion.utils.files")

			local files_info = files.get_markdown_files_info(directories)

			if #files_info == 0 then
				display.show_no_files_error(directories)
				return
			end

			local selection_handler = function(file_info)
				handlers.handle_file_selection(file_info, chat)
			end

			if not pickers.try_telescope_picker(directories, selection_handler) then
				pickers.use_vim_ui_select(files_info, selection_handler)
			end
		end,
		opts = {},
	},
}

return {
	setup = setup,
	exports = exports,
}
