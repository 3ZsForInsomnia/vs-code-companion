-- Health check for vs-code-companion
local M = {}

function M.check()
  vim.health.start('vs-code-companion')
  
  -- Check if plugin is loaded
  local ok, vs_code_companion = pcall(require, 'vs-code-companion')
  if ok then
    vim.health.ok('vs-code-companion loaded successfully')
  else
    vim.health.error('vs-code-companion failed to load: ' .. vs_code_companion)
    return
  end
  
  -- Check git repository
  local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    vim.health.error('Not in a git repository - plugin requires git root for relative directory resolution')
  else
    vim.health.ok('Git repository detected: ' .. git_root)
  end
  
  -- Check configuration
  local config = vs_code_companion.get_config()
  
  if #config.directories == 0 then
    vim.health.warn('No directories configured')
  else
    vim.health.ok('Configuration found')
  end
  
  -- Check directories
  local total_dirs = 0
  local valid_dirs = 0
  
  -- Only check directories if we're in a git repo
  if vim.v.shell_error == 0 then
    local git_root_path = git_root
    
    for _, dir in ipairs(config.directories) do
    total_dirs = total_dirs + 1
    local full_path = vim.fn.resolve(git_root_path .. '/' .. dir)
    if vim.fn.isdirectory(full_path) == 1 then
      valid_dirs = valid_dirs + 1
    else
        vim.health.warn('Directory does not exist: ' .. dir .. ' (resolved to: ' .. full_path .. ')')
    end
  end
  end
  
  if total_dirs > 0 then
    vim.health.ok(string.format('%d/%d configured directories exist', valid_dirs, total_dirs))
  end
  
  -- Check telescope
  local has_telescope = pcall(require, 'telescope')
  if has_telescope then
    vim.health.ok('telescope.nvim is available')
  else
    vim.health.warn('telescope.nvim is not available - telescope extension will not work')
  end
  
  -- Check CodeCompanion
  local has_codecompanion = pcall(require, 'codecompanion')
  if has_codecompanion then
    vim.health.ok('codecompanion.nvim is available')
    
    -- Check chat strategy specifically
    local has_chat_strategy = pcall(require, 'codecompanion.strategies.chat')
    if has_chat_strategy then
      vim.health.ok('CodeCompanion chat strategy is available')
    else
      vim.health.warn('CodeCompanion chat strategy not found - model setting may not work')
    end
  else
    vim.health.error('codecompanion.nvim is not available - this plugin requires CodeCompanion')
  end
end

return M