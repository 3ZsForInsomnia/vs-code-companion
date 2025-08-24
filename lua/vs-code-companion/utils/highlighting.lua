local M = {}

-- Apply syntax highlighting to a markdown buffer with YAML frontmatter
function M.apply_markdown_highlighting(bufnr, lines, config_highlights)
	local ns_id = vim.api.nvim_create_namespace("vs_code_companion_preview")
	
	-- Define highlight groups using configurable colors
	local highlights = {
		VsccYamlKey = config_highlights.yaml_key,
		VsccYamlDescription = config_highlights.yaml_description,
		VsccYamlModel = config_highlights.yaml_model,
		VsccYamlTools = config_highlights.yaml_tools,
		VsccYamlValue = config_highlights.yaml_value, -- fallback for other properties
		VsccSystemHeader = config_highlights.system_header,
		VsccUserHeader = config_highlights.user_header,
		VsccSystemContent = config_highlights.system_content,
		VsccUserContent = config_highlights.user_content,
	}
	
	-- Create highlight groups
	for name, opts in pairs(highlights) do
		vim.api.nvim_set_hl(0, name, opts)
	end
	
	local in_frontmatter = false
	local current_role = nil
	
	for i, line in ipairs(lines) do
		local line_idx = i - 1
		
		-- Handle frontmatter
		if line == "---" then
			in_frontmatter = not in_frontmatter
		elseif in_frontmatter and line:match("^%s*%w+%s*:") then
			-- Highlight yaml key-value pairs with specific colors per property
			local key_start, key_end = line:find("^%s*%w+")
			local key = line:match("^%s*(%w+)")
			
			if key_start then
				vim.api.nvim_buf_add_highlight(bufnr, ns_id, "VsccYamlKey", line_idx, key_start - 1, key_end)
			end
			
			local value_start = line:find(":%s*")
			if value_start then
				-- Use specific colors for different YAML properties
				local highlight_group = "VsccYamlValue" -- default
				if key == "description" then
					highlight_group = "VsccYamlDescription"
				elseif key == "model" then
					highlight_group = "VsccYamlModel"
				elseif key == "tools" then
					highlight_group = "VsccYamlTools"
				end
				
				vim.api.nvim_buf_add_highlight(bufnr, ns_id, highlight_group, line_idx, value_start + 1, -1)
			end
		-- Handle message headers
		elseif line:match("^## Message %d+ %(") then
			local role = line:match("%((%w+)%)")
			current_role = role
			
			if role == "system" then
				vim.api.nvim_buf_add_highlight(bufnr, ns_id, "VsccSystemHeader", line_idx, 0, -1)
			elseif role == "user" then
				vim.api.nvim_buf_add_highlight(bufnr, ns_id, "VsccUserHeader", line_idx, 0, -1)
			end
		-- Handle content based on current role
		elseif current_role and line ~= "" and not line:match("^#") then
			if current_role == "system" then
				vim.api.nvim_buf_add_highlight(bufnr, ns_id, "VsccSystemContent", line_idx, 0, -1)
			elseif current_role == "user" then
				vim.api.nvim_buf_add_highlight(bufnr, ns_id, "VsccUserContent", line_idx, 0, -1)
			end
		end
	end
end

return M