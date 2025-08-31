local M = {}

-- Helper function to safely get content from a prompt (handles both string and function content)
function M.get_prompt_content(prompt)
	if not prompt then
		return ""
	end
	
	local content = prompt.content or ""
	
	-- Handle case where content is a function
	if type(content) == "function" then
		local ok, result = pcall(content)
		if ok and type(result) == "string" then
			content = result
		else
			content = ""
		end
	end
	
	-- Ensure content is a string
	if type(content) ~= "string" then
		content = tostring(content or "")
	end
	
	return content
end

-- Convert codecompanion prompt to markdown with YAML frontmatter
-- This is exposed as a public utility function
function M.codecompanion_to_markdown(prompt_data, prompt_name)
	if not prompt_data or type(prompt_data) ~= "table" then
		return ""
	end
	
	local lines = {}
	
	-- Add frontmatter
	table.insert(lines, "---")
	
	if prompt_data.description then
		table.insert(lines, "description: " .. prompt_data.description)
	end
	
	local model = M.extract_model_from_prompt(prompt_data)
	if model then
		table.insert(lines, "model: " .. model)
	end
	
	local tools = M.extract_tools_from_prompt(prompt_data)
	if #tools > 0 then
		table.insert(lines, "tools: [" .. table.concat(tools, ", ") .. "]")
	end
	
	table.insert(lines, "---")
	table.insert(lines, "")
	
	-- Add prompts content
	if prompt_data.prompts then
		for i, prompt in ipairs(prompt_data.prompts) do
			table.insert(lines, "## Message " .. i .. " (" .. (prompt.role or "unknown") .. ")")
			table.insert(lines, "")
			table.insert(lines, M.get_prompt_content(prompt))
			table.insert(lines, "")
		end
	end
	
	return table.concat(lines, "\n")
end

-- Extract model information from codecompanion prompt
function M.extract_model_from_prompt(prompt_data)
	if prompt_data.opts and prompt_data.opts.adapter then
		if type(prompt_data.opts.adapter) == "string" then
			return prompt_data.opts.adapter
		elseif type(prompt_data.opts.adapter) == "table" and prompt_data.opts.adapter.model then
			return prompt_data.opts.adapter.model
		end
	end
	if prompt_data.opts and prompt_data.opts.model then
		return prompt_data.opts.model
	end
	return nil
end

-- Extract tool references from prompt content
function M.extract_tools_from_prompt(prompt_data)
	local tools = {}
	if not prompt_data.prompts then
		return tools
	end
	
	for _, prompt in ipairs(prompt_data.prompts) do
		if prompt.content then
			local content_text = M.get_prompt_content(prompt)
			-- Look for tool references like @{tool-name}
			for tool in content_text:gmatch("@{([^}]+)}") do
				if not vim.tbl_contains(tools, tool) then
					table.insert(tools, tool)
				end
			end
		end
	end
	
	return tools
end

return M