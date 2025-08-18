local M = {}

local frontmatter = require("vs-code-companion.utils.frontmatter")

local function get_git_root()
  local result = vim.fn.systemlist('git rev-parse --show-toplevel')
	if vim.v.shell_error ~= 0 then
		return nil
	end
  return result[1] and vim.fn.fnamemodify(result[1], ':p:h') or nil
end

-- Convert relative directories to absolute paths from git root
local function resolve_directories(directories)
	local git_root = get_git_root()
	if not git_root then
		vim.notify(
			"vs-code-companion: Not in a git repository. Please run from within a git project.",
			vim.log.levels.ERROR
		)
		return {}
	end

	local resolved = {}
	for _, dir in ipairs(directories) do
		local full_path = vim.fn.resolve(git_root .. "/" .. dir)
		table.insert(resolved, full_path)
	end

	return resolved
end

function M.find_markdown_files(directories)
	local files = {}
	local resolved_dirs = resolve_directories(directories)

	for _, dir in ipairs(resolved_dirs) do
		if vim.fn.isdirectory(dir) == 1 then
			local found_files = vim.fn.globpath(dir, "**/*.md", false, true)
			for _, file in ipairs(found_files) do
				table.insert(files, file)
			end
		else
			vim.notify("vs-code-companion: Directory does not exist: " .. dir, vim.log.levels.WARN)
		end
	end

	return files
end

-- Get file info with parsed frontmatter and content
function M.get_file_info(filepath)
	local file = io.open(filepath, "r")
	if not file then
		return nil
	end

	local content = file:read("*all")
	file:close()

	local parsed = frontmatter.parse(content)

	return {
		filepath = filepath,
		filename = vim.fn.fnamemodify(filepath, ":t"),
		frontmatter = parsed.frontmatter,
		content = parsed.content,
		raw_content = content,
	}
end

-- Get all markdown files with their info from directories
function M.get_markdown_files_info(directories)
	local files = M.find_markdown_files(directories)
	local files_info = {}

	for _, filepath in ipairs(files) do
		local info = M.get_file_info(filepath)
		if info then
			table.insert(files_info, info)
		end
	end

	return files_info
end

return M
