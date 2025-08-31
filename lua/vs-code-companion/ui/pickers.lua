local v = vim

local M = {}

local display = require("vs-code-companion.ui.display")

function M.use_vim_ui_select(prompts_info, selection_handler)
	local items = display.create_display_items(prompts_info)

	v.ui.select(items, {
		prompt = "Select from Prompt Library",
		format_item = function(item)
			return item
		end,
	}, function(choice, idx)
		if choice and idx then
			local selected_prompt = prompts_info[idx]
			selection_handler(selected_prompt)
		end
	end)
end

function M.try_telescope_picker(directories, selection_handler)
	local config = require("vs-code-companion.config").get()
	
	-- Respect user preference
	if config.picker == "vim_ui" then
		return false
	end
	
	if config.picker == "telescope" then
		local has_telescope = pcall(require, "telescope")
		if not has_telescope then
			v.notify("vs-code-companion: telescope.nvim not found but picker=telescope in config", v.log.levels.ERROR)
			return false
		end
	elseif config.picker == "auto" then
		local has_telescope = pcall(require, "telescope")
		if not has_telescope then
			return false
		end
	end

	local telescope = require("telescope")
	local ok, extension = pcall(function()
		return telescope.extensions.vs_code_companion
	end)

	if ok and extension and extension.prompts then
		extension.prompts(directories, selection_handler)
		return true
	end

	return false
end

return M
