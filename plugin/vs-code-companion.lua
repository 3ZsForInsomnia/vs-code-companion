-- vs-code-companion plugin entry point
if vim.g.loaded_vs_code_companion then
  return
end
vim.g.loaded_vs_code_companion = 1

-- Initialize the plugin
require('vs-code-companion').setup()