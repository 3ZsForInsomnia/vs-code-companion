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

	if user_config.transform then
		if type(user_config.transform) ~= "table" then
			error("vs-code-companion: config.transform must be a table")
		end
		-- TODO: Add more detailed validation for transform config structure
	end

end

local default_config = {
	directories = {
		".github/prompts",
		".github/chatmodes",
	},
	transform = nil, -- Uses defaults if nil, can be customized by users
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
