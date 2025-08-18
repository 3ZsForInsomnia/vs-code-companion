-- CodeCompanion integration utilities
local M = {}

local models_util = require('vs-code-companion.utils.models')

function M.apply_model(model_name)
  if not model_name then
    vim.notify('vs-code-companion: No model specified', vim.log.levels.WARN)
    return false
  end
  
  -- Convert display name to technical name
  local technical_name = models_util.get_technical_name(model_name)
  if not technical_name then
    vim.notify('vs-code-companion: Could not resolve model name: ' .. model_name, vim.log.levels.ERROR)
    return false
  end
  
  -- Check if CodeCompanion is available
  local ok, codecompanion_chat = pcall(require, 'codecompanion.strategies.chat')
  if not ok then
    vim.notify('vs-code-companion: CodeCompanion not available or chat strategy not found', vim.log.levels.ERROR)
    return false
  end
  
  -- Apply the model
  local success, err = pcall(function()
    codecompanion_chat.apply_model(technical_name)
  end)
  
  if success then
    vim.notify('vs-code-companion: Model set to ' .. technical_name, vim.log.levels.INFO)
    return true
  else
    vim.notify('vs-code-companion: Failed to set model: ' .. (err or 'unknown error'), vim.log.levels.ERROR)
    return false
  end
-- Add a user message to CodeCompanion chat with optional tools
  if not content or content == '' then
    vim.notify('vs-code-companion: No content to send', vim.log.levels.WARN)
    return false
  end
  
  -- Check if we're in a CodeCompanion chat buffer
  if not M.is_codecompanion_buffer() then
    vim.notify('vs-code-companion: Not in a CodeCompanion chat buffer', vim.log.levels.WARN)
    return false
  end
  
  -- Check if CodeCompanion is available
  local ok, codecompanion = pcall(require, 'codecompanion')
  if not ok then
    vim.notify('vs-code-companion: CodeCompanion not available', vim.log.levels.ERROR)
    return false
  end
  
  -- Get the current buffer's CodeCompanion chat instance
  -- Try different ways to access the chat instance
  local chat_instance = vim.b.codecompanion_chat or vim.g.codecompanion_chat
  
  if not chat_instance then
    -- Fallback: try to get from CodeCompanion's internal state
    local chat_strategy_ok, chat_strategy = pcall(require, 'codecompanion.strategies.chat')
    if chat_strategy_ok and chat_strategy.current then
      chat_instance = chat_strategy.current
    end
  end
  
  if not chat_instance then
    vim.notify('vs-code-companion: Could not find active CodeCompanion chat instance. Make sure you are in a CodeCompanion chat buffer.', vim.log.levels.ERROR)
    return false
  end
  
  -- Prepare message data
  local message_data = {
    role = 'user',
    content = content,
  }
  
  -- Add tools if provided
  if tools and #tools > 0 then
    -- Note: The exact format for tools may need adjustment based on CodeCompanion's implementation
    -- Currently passing tools array directly - may need to be formatted as objects with specific structure
    message_data.tool_calls = tools
  end
  
  -- Add the message to the chat
  local success, err = pcall(function()
    chat_instance:add_message(message_data)
  end)
  
  if success then
    local tools_info = tools and #tools > 0 and (' with tools: ' .. table.concat(tools, ', ')) or ''
    vim.notify('vs-code-companion: Message added to chat' .. tools_info, vim.log.levels.INFO)
    return true
  else
    vim.notify('vs-code-companion: Failed to add message: ' .. (err or 'unknown error'), vim.log.levels.ERROR)
    return false
  end
end

-- Check if currently in a CodeCompanion chat buffer
function M.is_codecompanion_buffer()
  return vim.bo.filetype == 'codecompanion'
end

-- Get current CodeCompanion chat buffer info
function M.get_chat_info()
  if not M.is_codecompanion_buffer() then
    return nil
  end
  
  return {
    bufnr = vim.api.nvim_get_current_buf(),
    filetype = vim.bo.filetype,
    -- Add more chat info as needed
  }
end

return M