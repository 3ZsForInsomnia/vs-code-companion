-- Configuration module
local M = {}

local default_config = {
	directories = {
		"prompts",
		".github/chatmode",
	},
}

local config = default_config

function M.setup(user_config)
	config = vim.tbl_deep_extend("force", default_config, user_config)
end

function M.get()
	return config
end

return M
