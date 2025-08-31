local M = {}

local function validate_config(user_config)
	if user_config.directories then
		if type(user_config.directories) ~= "table" then
			error("vs-code-companion: config.directories must be a table")
		end
		if #user_config.directories == 0 then
			error("vs-code-companion: config.directories cannot be empty")
		end
		for i, dir in ipairs(user_config.directories) do
			if type(dir) ~= "string" or dir == "" then
				error(string.format("vs-code-companion: config.directories[%d] must be a non-empty string", i))
			end
		end
	end

	if user_config.picker then
		local valid_pickers = { "auto", "telescope", "vim_ui" }
		if not vim.tbl_contains(valid_pickers, user_config.picker) then
			error("vs-code-companion: config.picker must be one of: " .. table.concat(valid_pickers, ", "))
		end
	end

	if user_config.highlights then
		if type(user_config.highlights) ~= "table" then
			error("vs-code-companion: config.highlights must be a table")
		end
	end

end

local default_config = {
	directories = {
		".github/prompts",
		".github/chatmodes",
	},
	picker = "auto", -- "auto", "telescope", "vim_ui"
	highlights = {
		yaml_key = { fg = "#79dac8", bold = true }, -- cyan for yaml keys
		yaml_value = { fg = "#e39777" }, -- orange for yaml values
		yaml_description = { fg = "#ff9e64" }, -- orange for description values
		yaml_model = { fg = "#9d7cd8" }, -- purple for model values
		yaml_tools = { fg = "#73daca" }, -- teal for tools values
		system_header = { fg = "#f7768e", bold = true }, -- red for system headers
		user_header = { fg = "#9ece6a", bold = true }, -- green for user headers
		system_content = { fg = "#bb9af7" }, -- purple for system content
		user_content = { fg = "#7dcfff" }, -- blue for user content
	},
}

local config = default_config

function M.setup(user_config)
	user_config = user_config or {}
	validate_config(user_config)
	config = vim.tbl_deep_extend("force", default_config, user_config)
end

function M.get()
	return config
end

return M
