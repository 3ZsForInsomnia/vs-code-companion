local M = {}

-- Main transformation function that converts markdown file info to CodeCompanion prompt
function M.transform_to_codecompanion(file_info, transform_config)
	if not file_info then
		return nil, "No file info provided"
	end
	
	-- Use default config if none provided
	local defaults = require("vs-code-companion.transform.defaults")
	transform_config = transform_config or defaults.defaults
	
	local prompt_config = {
		prompts = {}
	}
	local opts = {}
	local system_prompts = {}
	local user_prompts = {}
	local tool_instruction = nil
	
	-- Track which required fields we've successfully processed
	local required_fields = {}
	for key, config in pairs(transform_config) do
		if config.required then
			required_fields[key] = false
		end
	end
	
	-- Process each configured property
	for property, config in pairs(transform_config) do
		-- Skip if disabled
		if config == false then
			goto continue
		end
		
		-- Validate config structure
		if type(config) ~= "table" or not config.getter or not config.transform then
			if config.required then
				return nil, string.format("Invalid config for required property '%s'", property)
			end
			goto continue
		end
		
		-- Get the raw value
		local raw_value = config.getter(file_info)
		
		-- Check required fields
		if config.required then
			if raw_value == nil then
				return nil, string.format("Required property '%s' could not be extracted", property)
			end
			required_fields[property] = true
		end
		
		-- Skip if no value and not required
		if raw_value == nil then
			goto continue
		end
		
		-- Transform the value
		local transformed_value
		if property == "content" then
			-- Special case: content transformation needs role
			local role_config = transform_config.role
			local role = role_config and role_config.getter and role_config.getter(file_info) or "user"
			transformed_value = config.transform(raw_value, role)
		else
			transformed_value = config.transform(raw_value)
		end
		
		-- Apply the transformed value to the appropriate section
		if property == "description" then
			prompt_config.description = transformed_value
		elseif property == "strategy" then
			prompt_config.strategy = transformed_value
		elseif property == "content" then
			if transformed_value and transformed_value.role == "system" then
				table.insert(system_prompts, transformed_value)
			elseif transformed_value then
				table.insert(user_prompts, transformed_value)
			end
		elseif property == "system_prompt" then
			if transformed_value then
				table.insert(system_prompts, transformed_value)
			end
		elseif property == "context" then
			if transformed_value then
				prompt_config.context = transformed_value
			end
		elseif property == "memory" then
			if transformed_value then
				prompt_config.memory = transformed_value
			end
		elseif property == "model" then
			if transformed_value then
				if not opts.adapter then
					opts.adapter = {}
				end
				opts.adapter.model = transformed_value
			end
		elseif property == "tools" then
			if transformed_value then
				-- Store tool instruction for later appending to user prompts
				-- We'll append it after all prompts are processed
				tool_instruction = transformed_value
			end
		elseif property == "command_name" then
			if transformed_value then
				opts.short_name = transformed_value
			end
		else
			-- All other properties go into opts
			if transformed_value ~= nil then
				opts[property] = transformed_value
			end
		end
		
		::continue::
	end
	
	-- Verify all required fields were processed
	for field, processed in pairs(required_fields) do
		if not processed then
			return nil, string.format("Required field '%s' was not successfully processed", field)
		end
	end
	
	-- Build the prompts array in the correct order: system prompts first, then user prompts
	for _, system_prompt in ipairs(system_prompts) do
		table.insert(prompt_config.prompts, system_prompt)
	end
	for _, user_prompt in ipairs(user_prompts) do
		table.insert(prompt_config.prompts, user_prompt)
	end
	
	-- Append tool instruction to the last user prompt if we have one
	if tool_instruction and #prompt_config.prompts > 0 then
		for i = #prompt_config.prompts, 1, -1 do
			if prompt_config.prompts[i].role == "user" then
				prompt_config.prompts[i].content = prompt_config.prompts[i].content .. tool_instruction
				break
			end
		end
	end
	
	-- Only add opts if it has content
	if next(opts) then
		prompt_config.opts = opts
	end
	
	-- Validate final structure
	if not prompt_config.description then
		return nil, "No description generated"
	end
	
	if not prompt_config.prompts or #prompt_config.prompts == 0 then
		return nil, "No prompts generated"
	end
	
	return prompt_config, nil
end

-- Helper function to merge custom config with defaults
function M.merge_transform_config(custom_config)
	local defaults = require("vs-code-companion.transform.defaults")
	
	if not custom_config then
		return defaults.defaults
	end
	
	-- Deep merge custom config with defaults
	local merged = vim.tbl_deep_extend("force", defaults.defaults, custom_config)
	
	return merged
end

-- Helper function to create a config with specific tool variant
function M.create_config_with_tools(tool_variant)
	local defaults = require("vs-code-companion.transform.defaults")
	local config = vim.tbl_deep_extend("force", {}, defaults.defaults)
	
	if tool_variant and defaults.tool_variants[tool_variant] then
		config.tools = defaults.tool_variants[tool_variant]
	end
	
	return config
end

return M