local v = vim

local M = {}

function M.create_display_items(prompts_info)
	local prompts_util = require("vs-code-companion.utils.prompts")
	local items = {}
	for _, info in ipairs(prompts_info) do
		table.insert(items, prompts_util.create_display_text(info))
	end
	return items
end

function M.show_no_files_error(directories)
	if #directories == 0 then
		v.notify(
			"No directories configured! You must have configured directories before you can use this plugin",
			v.log.levels.WARN
		)
	else
		v.notify(
			"No prompt files found in configured directories: " .. table.concat(directories, ", "),
			v.log.levels.WARN
		)
	end
end

function M.show_no_prompts_error()
	v.notify(
		"No prompts available in CodeCompanion prompt library",
		v.log.levels.WARN
	)
end

return M
