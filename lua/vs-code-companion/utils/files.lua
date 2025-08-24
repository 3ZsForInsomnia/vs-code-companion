local v = vim

local M = {}

local frontmatter = require("vs-code-companion.utils.frontmatter")

local function get_git_root()
	local result = v.fn.systemlist("git rev-parse --show-toplevel")

	if v.v.shell_error ~= 0 then
		return nil
	end

	return result[1] and v.fn.fnamemodify(result[1], ":p:h") or nil
end

local function resolve_directories(directories)
	local git_root = get_git_root()
	if not git_root then
		v.notify(
			"vs-code-companion: Not in a git repository. Please run from within a git project.",
			v.log.levels.ERROR
		)

		return {}
	end

	local resolved = {}
	for _, dir in ipairs(directories) do
		local full_path = v.fn.resolve(git_root .. "/" .. dir)

		table.insert(resolved, full_path)
	end

	return resolved
end

function M.find_markdown_files(directories)
	local files = {}
	local resolved_dirs = resolve_directories(directories)

	for _, dir in ipairs(resolved_dirs) do
		if v.fn.isdirectory(dir) == 1 then
			local found_files = v.fn.globpath(dir, "**/*.md", false, true)
			for _, file in ipairs(found_files) do
				table.insert(files, file)
			end
		end
	end

	return files
end

function M.get_file_info(filepath)
	local file = io.open(filepath, "r")
	if not file then
		return nil
	end

	local content = file:read("*all")
	file:close()

	local parsed = frontmatter.parse(content)

	-- Validate that this is a proper prompt file
	if not M.is_valid_prompt_file(parsed) then
		return nil
	end

	return {
		filepath = filepath,
		filename = v.fn.fnamemodify(filepath, ":t"),
		frontmatter = parsed.frontmatter,
		content = parsed.content,
		raw_content = content,
	}
end

-- Validate that a markdown file is a proper prompt file
function M.is_valid_prompt_file(parsed)
	-- Must have frontmatter with at least a description
	if not parsed.frontmatter or type(parsed.frontmatter) ~= "table" then
		return false
	end
	
	-- Must have a description property
	if not parsed.frontmatter.description or 
	   type(parsed.frontmatter.description) ~= "string" or 
	   parsed.frontmatter.description:match("^%s*$") then
		return false
	end
	
	-- Must have actual content (not just whitespace)
	if not parsed.content or 
	   type(parsed.content) ~= "string" or 
	   parsed.content:match("^%s*$") then
		return false
	end
	
	return true
end

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
