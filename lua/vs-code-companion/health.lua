local v = vim
local h = v.health

local M = {}

function M.check()
	h.start("vs-code-companion")

	local ok, vs_code_companion = pcall(require, "vs-code-companion")
	if ok then
		h.ok("vs-code-companion loaded successfully")
	else
		h.error("vs-code-companion failed to load: " .. vs_code_companion)
		return
	end

	local git_root = v.fn.systemlist("git rev-parse --show-toplevel")[1]
	if v.v.shell_error ~= 0 then
		h.error("Not in a git repository - plugin requires git root for relative directory resolution")
	else
		h.ok("Git repository detected: " .. git_root)
	end

	local config = require("vs-code-companion.config").get()

	if #config.directories == 0 then
		h.error("No directories configured")
	else
		h.ok("Configuration found")
	end

	local total_dirs = 0
	local valid_dirs = 0

	if v.v.shell_error == 0 then
		local git_root_path = git_root

		for _, dir in ipairs(config.directories) do
			total_dirs = total_dirs + 1
			local full_path = v.fn.resolve(git_root_path .. "/" .. dir)
			if v.fn.isdirectory(full_path) == 1 then
				valid_dirs = valid_dirs + 1
			else
				h.warn("Directory does not exist: " .. dir .. " (resolved to: " .. full_path .. ")")
			end
		end
	end

	if total_dirs > 0 then
		h.ok(string.format("%d/%d configured directories exist", valid_dirs, total_dirs))
	end

	local has_telescope = pcall(require, "telescope")
	if has_telescope then
		h.ok("telescope.nvim is available")
	else
		h.warn("telescope.nvim is not available - telescope extension will not work")
	end

	local has_codecompanion = pcall(require, "codecompanion")
	if has_codecompanion then
		h.ok("codecompanion.nvim is available")

		local has_chat_strategy = pcall(require, "codecompanion.strategies.chat")
		if has_chat_strategy then
			h.ok("CodeCompanion chat strategy is available")
		else
			h.error("CodeCompanion chat strategy not found - model setting may not work")
		end
	else
		h.error("codecompanion.nvim is not available - this plugin requires CodeCompanion")
	end
end

return M
