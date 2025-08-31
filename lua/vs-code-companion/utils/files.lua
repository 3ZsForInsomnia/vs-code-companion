local v = vim

local M = {}

local frontmatter = require("vs-code-companion.utils.frontmatter")
local git_root_cache = nil
local git_root_cache_time = 0

-- Safe file reading utility with proper resource management
local function read_file_safely(filepath)
	if not filepath or filepath == "" then
		return nil, "Invalid filepath provided"
	end

	local file, open_err = io.open(filepath, "r")
	if not file then
		return nil, "Could not open file: " .. (open_err or "unknown error")
	end

	local content, read_err = file:read("*all")
	file:close() -- Always close the file handle

	if not content then
		return nil, "Could not read file content: " .. (read_err or "unknown error")
	end

	return content
end

local function log_file_processing(filepath, status, reason)
	local filename = v.fn.fnamemodify(filepath, ":t")

	if status == "included" then
		-- Success - log to :messages for detailed tracking
		vim.cmd(string.format("echomsg 'vs-code-companion: Successfully processed %s'", filename))
	else
		-- Error - always show what was missing/wrong
		vim.cmd(string.format("echomsg 'vs-code-companion: Failed to process %s - %s'", filename, reason or "unknown error"))
	end
end

-- Validate that a markdown file is a proper prompt file
function M.is_valid_prompt_file(parsed, filepath)
	local reasons = {}

	-- Must have frontmatter
	if not parsed.frontmatter or type(parsed.frontmatter) ~= "table" then
		table.insert(reasons, "no YAML frontmatter found")
		if filepath then
			log_file_processing(filepath, "skipped", table.concat(reasons, ", "))
		end
		return false
	end

	local fm = parsed.frontmatter

	-- Must have a description
	if not fm.description then
		table.insert(reasons, "missing 'description' field")
	elseif type(fm.description) ~= "string" then
		table.insert(reasons, "'description' field is not a string")
	elseif fm.description:match("^%s*$") then
		table.insert(reasons, "'description' field is empty")
	end

	-- Must have actual content (not just whitespace)
	if not parsed.content then
		table.insert(reasons, "missing content after frontmatter")
	elseif type(parsed.content) ~= "string" then
		table.insert(reasons, "content is not a string")
	elseif parsed.content:match("^%s*$") then
		table.insert(reasons, "content is empty")
	end

	-- Validate optional fields if present
	if fm.model and type(fm.model) ~= "string" then
		table.insert(reasons, "'model' field is not a string")
	end

	if fm.tools then
		if type(fm.tools) ~= "table" then
			table.insert(reasons, "'tools' field is not an array")
		else
			for i, tool in ipairs(fm.tools) do
				if type(tool) ~= "string" then
					table.insert(reasons, string.format("'tools[%d]' is not a string", i))
					break
				end
			end
		end
	end

	if #reasons > 0 then
		if filepath then
			log_file_processing(filepath, "skipped", table.concat(reasons, ", "))
		end
		return false
	end
	if filepath then
		log_file_processing(filepath, "included", nil)
	end
	return true
end

local function get_git_root()
	local current_time = v.loop.hrtime()
	-- Cache for 5 seconds to avoid repeated git calls
	if git_root_cache and (current_time - git_root_cache_time) < 5000000000 then
		return git_root_cache
	end

	local result = v.fn.systemlist("git rev-parse --show-toplevel")

	if v.v.shell_error ~= 0 then
		git_root_cache = nil
		git_root_cache_time = current_time
		error("vs-code-companion: Not in a git repository. Please run from within a git project.")
	end

	git_root_cache = result[1] and v.fn.fnamemodify(result[1], ":p:h") or nil
	git_root_cache_time = current_time
	return git_root_cache
end

local function resolve_directories(directories)
	if not directories or type(directories) ~= "table" or #directories == 0 then
		error("vs-code-companion: No directories provided for resolution")
	end

	local git_root = get_git_root()

	local resolved = {}
	for _, dir in ipairs(directories) do
		local full_path = v.fn.resolve(git_root .. "/" .. dir)

		table.insert(resolved, full_path)
	end

	return resolved
end

-- Public utility for safe file reading with proper resource management
function M.read_file_safely(filepath)
	return read_file_safely(filepath)
end

function M.find_markdown_files(directories)
	if not directories or type(directories) ~= "table" or #directories == 0 then
		return {}
	end

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
	if not filepath or filepath == "" then
		error("vs-code-companion: Invalid filepath provided")
	end

	local content, err = read_file_safely(filepath)
	if not content then
		error("vs-code-companion: " .. err)
	end

	local parsed = frontmatter.parse(content)

	-- Get filename for validation
	local filename = v.fn.fnamemodify(filepath, ":t")
	if not filename or filename == "" then
		error("vs-code-companion: Could not extract filename from path: " .. filepath)
	end

	-- Validate that this is a proper prompt file
	if not M.is_valid_prompt_file(parsed, filepath) then
		return nil
	end

	return {
		filepath = filepath,
		filename = filename,
		frontmatter = parsed.frontmatter,
		content = parsed.content,
		raw_content = content,
	}
end

function M.get_markdown_files_info(directories)
	local files = M.find_markdown_files(directories)
	local files_info = {}
	local total_found = #files
	local included_count = 0
	local error_count = 0

	for _, filepath in ipairs(files) do
		local ok, info = pcall(M.get_file_info, filepath)
		if ok and info then
			table.insert(files_info, info)
			included_count = included_count + 1
		elseif not ok then
			error_count = error_count + 1
			-- Always log file processing errors since they're actual errors
			local filename = v.fn.fnamemodify(filepath, ":t")
			vim.cmd(
				string.format("echomsg 'vs-code-companion: Failed to process %s: %s'", filename, info or "unknown error")
			)
		end
	end

	-- Always log processing summary to :messages for detailed tracking
	if total_found > 0 then
		vim.cmd(
			string.format(
				"echomsg 'vs-code-companion: File processing completed - %d found, %d processed successfully, %d failed'",
				total_found,
				included_count,
				error_count
			)
		)
	end

	return files_info
end

return M
