-- Main plugin module
local M = {}

local config = require('vs-code-companion.config')
local ui = require('vs-code-companion.ui')

function M.setup(user_config)
  config.setup(user_config or {})
  
  -- Load user commands
  require('vs-code-companion.commands')
end

-- Exposed API functions
function M.select_prompt()
  ui.select_from_directories(config.get().directories, "Select Prompt")
end

-- Get configuration for external access
function M.get_config()
  return config.get()
end

return M