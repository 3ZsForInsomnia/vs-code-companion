local M = {}

local files = require("vs-code-companion.utils.files")
local codecompanion = require("vs-code-companion.utils.codecompanion")
function M.select_from_directories(directories, prompt)
	local files_info = files.get_markdown_files_info(directories)
	-- Try to use telescope if available and extension is loaded
	local has_telescope = pcall(require, "telescope")
	if has_telescope then
		local telescope = require("telescope")
		local ok, extension = pcall(function()
			return telescope.extensions.vs_code_companion
		end)
		if ok and extension and extension.prompts then
			extension.prompts(directories, prompt)
			return
		end
	end

	-- Fallback to vim.ui.select
	M.select_with_vim_ui(directories, prompt)
	function M.select_with_vim_ui(directories, prompt) end

	if #files_info == 0 then
		if #directories == 0 then
			vim.notify("No directories configured for " .. prompt:lower(), vim.log.levels.WARN)
		else
			vim.notify(
				"No markdown files found in configured directories: " .. table.concat(directories, ", "),
				vim.log.levels.WARN
			)
		end
		return
	end

	-- Create display items (just filenames for vim.ui.select)
	local items = {}
	for _, info in ipairs(files_info) do
		local display = info.filename
		if info.frontmatter.description then
			display = display .. " - " .. info.frontmatter.description
		end
		table.insert(items, display)
	end

	vim.ui.select(items, {
		prompt = prompt .. ":",
		format_item = function(item)
			return item
		end,
	}, function(choice, idx)
		if choice and idx then
			local selected_file = files_info[idx]
			M.handle_selection(selected_file)
		end
	end)
end

function M.handle_selection(file_info)
	if file_info.frontmatter.model then
		codecompanion.apply_model(file_info.frontmatter.model)
	end

	if file_info.content and file_info.content ~= "" then
		codecompanion.add_user_message(file_info.content, file_info.frontmatter.tools)
	end
end

return M
