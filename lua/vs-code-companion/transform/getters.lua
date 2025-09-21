local M = {}

-- Extract description from markdown frontmatter
function M.get_description(file_info)
	if not file_info or not file_info.frontmatter then
		return nil
	end
	
	local description = file_info.frontmatter.description
	if type(description) == "string" and description:match("%S") then
		return description
	end
	
	return nil
end

-- Extract content after frontmatter as user prompt
function M.get_content(file_info)
	if not file_info or not file_info.content then
		return nil
	end
	
	local content = file_info.content
	if type(content) == "string" and content:match("%S") then
		return content
	end
	
	return nil
end

-- Extract model from frontmatter
function M.get_model(file_info)
	if not file_info or not file_info.frontmatter then
		return nil
	end
	
	local model = file_info.frontmatter.model
	if type(model) == "string" and model:match("%S") then
		return model
	end
	
	return nil
end

-- Extract tools from frontmatter
function M.get_tools(file_info)
	if not file_info or not file_info.frontmatter then
		return nil
	end
	
	local tools = file_info.frontmatter.tools
	if type(tools) == "table" and #tools > 0 then
		return tools
	end
	
	return nil
end

-- Always return "chat" strategy
function M.get_strategy(file_info)
	return "chat"
end

-- Generate command name from filename
function M.get_command_name(file_info)
	if not file_info or not file_info.filename then
		return nil
	end
	
	local filename = file_info.filename
	if not filename or type(filename) ~= "string" or filename:match("^%s*$") then
		return nil
	end
	
	-- Remove .md extension and sanitize
	local name = filename:gsub("%.md$", ""):gsub("[^%w]", "_"):lower()
	
	-- Remove any leading/trailing underscores and collapse multiple underscores
	name = name:gsub("^_+", ""):gsub("_+$", ""):gsub("_+", "_")
	
	-- After sanitization, ensure we still have something meaningful
	if name == "" then
		return nil
	end
	
	-- Ensure it starts with a letter or underscore (for Lua identifier rules)
	if not name:match("^[%a_]") then
		name = "_" .. name
	end
	
	return "vsc_" .. name
end

-- Always return false for auto_submit (user should manually submit)
function M.get_auto_submit(file_info)
	return false
end

-- Always return true for is_slash_cmd
function M.get_is_slash_cmd(file_info)
	return true
end

-- Extract role - for VS Code prompts, content is always user role
function M.get_role(file_info)
	return "user"
end

-- No system prompt by default for VS Code prompts
function M.get_system_prompt(file_info)
	return nil
end

-- No context by default
function M.get_context(file_info)
	return nil
end

-- No memory by default
function M.get_memory(file_info)
	return nil
end

-- No placement override
function M.get_placement(file_info)
	return nil
end

-- No mapping by default
function M.get_mapping(file_info)
	return nil
end

-- No modes restriction by default
function M.get_modes(file_info)
	return nil
end

-- No intro message by default
function M.get_intro_message(file_info)
	return nil
end

-- Don't ignore system prompt by default
function M.get_ignore_system_prompt(file_info)
	return nil
end

return M