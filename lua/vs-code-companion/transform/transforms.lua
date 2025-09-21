local M = {}

-- Transform description to CodeCompanion format
function M.transform_description(description)
	if not description then
		return nil
	end
	return description
end

-- Transform content to CodeCompanion prompts array format
function M.transform_content(content, role)
	if not content then
		return nil
	end
	
	role = role or "user"
	
	return {
		role = role,
		content = content,
	}
end

-- Transform model to CodeCompanion format
function M.transform_model(model)
	if not model then
		return nil
	end
	
	-- Use existing model resolution logic
	local models = require("vs-code-companion.codecompanion.models")
	local technical_name = models.resolve_model_name(model)
	
	if technical_name and technical_name ~= "" then
		return technical_name
	end
	
	return nil
end

-- Transform tools - default to nil (no tools)
function M.transform_tools_none(tools)
	return nil
end

-- Transform tools - use full_stack_dev
function M.transform_tools_full_stack_dev(tools)
	if not tools or type(tools) ~= "table" or #tools == 0 then
		return nil
	end
	
	-- Return the tool instruction to append to content
	return "\nPlease use the @{full_stack_dev} tool"
end

-- Transform tools - attempt basic mapping (placeholder for future implementation)
function M.transform_tools_mapped(tools)
	if not tools or type(tools) ~= "table" or #tools == 0 then
		return nil
	end
	
	-- TODO: Implement actual mapping from VS Code tools to CodeCompanion tools
	-- For now, fall back to full_stack_dev
	return "\nPlease use the @{full_stack_dev} tool"
end

-- Transform strategy to CodeCompanion format
function M.transform_strategy(strategy)
	if not strategy then
		return "chat"
	end
	return strategy
end

-- Transform command name to short_name
function M.transform_command_name(command_name)
	if not command_name then
		return nil
	end
	return command_name
end

-- Transform auto_submit to CodeCompanion format
function M.transform_auto_submit(auto_submit)
	if auto_submit == nil then
		return false
	end
	return auto_submit
end

-- Transform is_slash_cmd to CodeCompanion format  
function M.transform_is_slash_cmd(is_slash_cmd)
	if is_slash_cmd == nil then
		return true
	end
	return is_slash_cmd
end

-- Transform role to CodeCompanion format
function M.transform_role(role)
	if not role then
		return "user"
	end
	return role
end

-- Transform system prompt to CodeCompanion prompts array format
function M.transform_system_prompt(system_prompt)
	if not system_prompt then
		return nil
	end
	
	return {
		role = "system",
		content = system_prompt,
	}
end

-- Transform context to CodeCompanion format
function M.transform_context(context)
	-- For now, pass through as-is since CodeCompanion context format
	-- is already well-defined
	return context
end

-- Transform memory to CodeCompanion format
function M.transform_memory(memory)
	return memory
end

-- Transform placement to CodeCompanion format
function M.transform_placement(placement)
	return placement
end

-- Transform mapping to CodeCompanion format
function M.transform_mapping(mapping)
	return mapping
end

-- Transform modes to CodeCompanion format
function M.transform_modes(modes)
	return modes
end

-- Transform intro_message to CodeCompanion format
function M.transform_intro_message(intro_message)
	return intro_message
end

-- Transform ignore_system_prompt to CodeCompanion format
function M.transform_ignore_system_prompt(ignore_system_prompt)
	return ignore_system_prompt
end

return M