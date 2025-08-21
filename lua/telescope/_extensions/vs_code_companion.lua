local has_telescope = pcall(require, "telescope")
if not has_telescope then
	error("telescope.nvim is required for this extension")
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local files = require("vs-code-companion.utils.files")
local config = require("vs-code-companion.config")
local models = require("vs-code-companion.codecompanion.models")
local chat = require("vs-code-companion.codecompanion.chat")

local M = {}

local function handle_selection(file_info)
	local handlers = require("vs-code-companion.ui.handlers")
	handlers.handle_file_selection(file_info, nil)
end

function M.prompts(directories, custom_handler)
	directories = directories or config.get().directories
	custom_handler = custom_handler or handle_selection

	local files_info = files.get_markdown_files_info(directories)

	if #files_info == 0 then
        		require("vs-code-companion.ui.display").show_no_files_error(directories)

		return
	end

	pickers
		.new({}, {
			prompt_title = "Select from Prompt Library",
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
			previewer = conf.file_previewer({}),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						custom_handler(selection.value)
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
