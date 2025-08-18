local has_telescope = pcall(require, "telescope")
if not has_telescope then
	error("telescope.nvim is required for this extension")
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local previewers = require("telescope.previewers")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local files = require("vs-code-companion.utils.files")
local config = require("vs-code-companion.config")
local codecompanion = require("vs-code-companion.utils.codecompanion")

local M = {}

local function handle_selection(file_info)
	if file_info.frontmatter.model then
		codecompanion.apply_model(file_info.frontmatter.model)
	end

	if file_info.content and file_info.content ~= "" then
		codecompanion.add_user_message(file_info.content, file_info.frontmatter.tools)
	end
end

local function markdown_previewer()
	return previewers.new_buffer_previewer({
		title = "Markdown Preview",
		define_preview = function(self, entry, status)
			local file_info = entry.value
			if file_info and file_info.raw_content then
				vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, vim.split(file_info.raw_content, "\n"))
				vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "markdown")
			end
		end,
	})
end

function M.prompts(directories, prompt_title)
	directories = directories or config.get().directories
	prompt_title = prompt_title or "Prompts"

	local files_info = files.get_markdown_files_info(directories)

	if #files_info == 0 then
		if #directories == 0 then
			vim.notify("No directories configured for " .. prompt_title:lower(), vim.log.levels.WARN)
		else
			vim.notify("No markdown files found in: " .. table.concat(directories, ", "), vim.log.levels.WARN)
		end

		return
	end

	pickers
		.new({}, {
			prompt_title = prompt_title,
			finder = finders.new_table({
				results = files_info,
				entry_maker = function(file_info)
					local display = file_info.filename
					if file_info.frontmatter.description then
						display = file_info.filename .. " - " .. file_info.frontmatter.description
					end

					return {
						value = file_info,
						display = display,
						ordinal = file_info.filename .. " " .. (file_info.frontmatter.description or ""),
						path = file_info.filepath,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = markdown_previewer(),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						handle_selection(selection.value)
					end
				end)
				return true
			end,
		})
		:find()
end

return require("telescope").register_extension({
	setup = function() end,
	exports = {
		prompts = M.prompts,
	},
})
