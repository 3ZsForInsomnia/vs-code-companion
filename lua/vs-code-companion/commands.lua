local M = {}

M.handle_selection = function()
	local display = require("vs-code-companion.ui.display")
	local pickers = require("vs-code-companion.ui.pickers")
	local handlers = require("vs-code-companion.ui.handlers")
	local files = require("vs-code-companion.utils.files")
	local config = require("vs-code-companion.config")

	local directories = config.get().directories
	local files_info = files.get_markdown_files_info(directories)

	if #files_info == 0 then
		display.show_no_files_error(directories)
		return
	end

	if
		not pickers.try_telescope_picker(directories, function(file_info)
			handlers.handle_file_selection(file_info, nil)
		end)
	then
		pickers.use_vim_ui_select(files_info, function(file_info)
			handlers.handle_file_selection(file_info, nil)
		end)
	end
end

return M
