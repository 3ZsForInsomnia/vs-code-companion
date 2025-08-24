local has_telescope = pcall(require, "telescope")
if not has_telescope then
	error("telescope.nvim is required for this extension")
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local prompts_util = require("vs-code-companion.utils.prompts")
local config = require("vs-code-companion.config")
local models = require("vs-code-companion.codecompanion.models")
local chat = require("vs-code-companion.codecompanion.chat")

local M = {}

-- Create enhanced previewer for both markdown and codecompanion prompts
function M.create_enhanced_previewer()
	local previewers = require("telescope.previewers")
	local highlighting = require("vs-code-companion.utils.highlighting")
	local markdown_converter = require("vs-code-companion.utils.markdown_converter")
	
	return previewers.new_buffer_previewer({
		title = "Prompt Preview",
		define_preview = function(self, entry, status)
			local prompt_info = entry.value
			local content, lines
			
			if prompt_info.source == "markdown" and prompt_info.filepath then
				-- Pipeline step 1: Read markdown file content
				local file = io.open(prompt_info.filepath, "r")
				if file then
					content = file:read("*all")
					file:close()
					lines = vim.split(content, "\n")
				else
					lines = {"Error: Could not read file"}
				end
			else
				-- Pipeline step 1: Convert codecompanion prompt to markdown
				content = prompt_info.raw_content or 
					markdown_converter.codecompanion_to_markdown(prompt_info.prompt_data, prompt_info.name)
				lines = vim.split(content, "\n")
			end
			
			-- Pipeline step 2: Set buffer content and filetype
			vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
			vim.api.nvim_buf_set_option(self.state.bufnr, "filetype", "markdown")
			
			-- Pipeline step 3: Apply custom highlighting
			local user_config = config.get()
			highlighting.apply_markdown_highlighting(self.state.bufnr, lines, user_config.highlights)
		end,
	})
end

local function handle_selection(file_info)
	local handlers = require("vs-code-companion.ui.handlers")
	handlers.handle_file_selection(file_info, nil)
end

function M.prompts(directories, custom_handler)
	directories = directories or config.get().directories
	custom_handler = custom_handler or handle_selection

	-- Import is handled by the calling function (commands.lua or codecompanion extension)
	-- So we just get codecompanion prompts here
	local prompts_info = prompts_util.get_codecompanion_prompts_info()

	if #prompts_info == 0 then
        		require("vs-code-companion.ui.display").show_no_prompts_error()

		return
	end

	pickers
		.new({}, {
			prompt_title = "Select from Prompt Library",
			finder = finders.new_table({
				results = prompts_info,
				entry_maker = function(prompt_info)
					local display = prompts_util.create_display_text(prompt_info)

					return {
						value = prompt_info,
						display = display,
						ordinal = (prompt_info.filename or prompt_info.name) .. " " .. (prompt_info.frontmatter.description or ""),
						path = prompt_info.filepath or "codecompanion:" .. (prompt_info.name or "unknown"),
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = M.create_enhanced_previewer(),
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
