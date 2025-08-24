local M = {}

M.handle_selection = function()
	-- Always re-import VS Code prompts before selection (fast!)
	require("vs-code-companion.codecompanion.commands").import_all_prompts()

	local display = require("vs-code-companion.ui.display")
	local pickers = require("vs-code-companion.ui.pickers")
	local handlers = require("vs-code-companion.ui.handlers")
	local config = require("vs-code-companion.config")

	local directories = config.get().directories

	-- Now get only codecompanion prompts (since we just imported everything)
	local prompts = require("vs-code-companion.utils.prompts")
	local prompts_info = prompts.get_codecompanion_prompts_info()

	if #prompts_info == 0 then
		display.show_no_prompts_error()
		return
	end

	if
		not pickers.try_telescope_picker(directories, function(file_info)
			handlers.handle_file_selection(file_info, nil)
		end)
	then
		pickers.use_vim_ui_select(prompts_info, function(file_info)
			handlers.handle_file_selection(file_info, nil)
		end)
	end
end

return M
