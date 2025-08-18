local Extension = {}

local ui = require("vs-code-companion.ui")
local config = require("vs-code-companion.config")

function Extension.setup() end

Extension.exports = {
	prompts = function()
		return {
			description = "Search and apply prompts from configured directories",
			callback = function()
				ui.select_from_directories(config.get().directories, "Select Prompt")
			end,
			opts = {},
		}
	end,
}

return Extension
