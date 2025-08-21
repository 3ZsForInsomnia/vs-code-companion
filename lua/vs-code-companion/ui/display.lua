local v = vim

local M = {}

function M.create_display_items(files_info)
	local items = {}
	for _, info in ipairs(files_info) do
		local display = info.filename
		if info.frontmatter.description then
			display = display .. " - " .. info.frontmatter.description
		end
		table.insert(items, display)
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
			"No markdown files found in configured directories: " .. table.concat(directories, ", "),
			v.log.levels.WARN
		)
	end
end

return M
