local getters = require("vs-code-companion.transform.getters")
local transforms = require("vs-code-companion.transform.transforms")

local M = {}

-- Default configuration for all CodeCompanion prompt properties
M.defaults = {
	-- Required properties
	description = {
		getter = getters.get_description,
		transform = transforms.transform_description,
		required = true,
	},
	content = {
		getter = getters.get_content,
		transform = transforms.transform_content,
		required = true,
	},
	
	-- Core properties
	strategy = {
		getter = getters.get_strategy,
		transform = transforms.transform_strategy,
	},
	
	-- Opts properties
	command_name = {
		getter = getters.get_command_name,
		transform = transforms.transform_command_name,
	},
	auto_submit = {
		getter = getters.get_auto_submit,
		transform = transforms.transform_auto_submit,
	},
	is_slash_cmd = {
		getter = getters.get_is_slash_cmd,
		transform = transforms.transform_is_slash_cmd,
	},
	mapping = {
		getter = getters.get_mapping,
		transform = transforms.transform_mapping,
	},
	modes = {
		getter = getters.get_modes,
		transform = transforms.transform_modes,
	},
	intro_message = {
		getter = getters.get_intro_message,
		transform = transforms.transform_intro_message,
	},
	ignore_system_prompt = {
		getter = getters.get_ignore_system_prompt,
		transform = transforms.transform_ignore_system_prompt,
	},
	placement = {
		getter = getters.get_placement,
		transform = transforms.transform_placement,
	},
	
	-- Model and tools
	model = {
		getter = getters.get_model,
		transform = transforms.transform_model,
	},
	tools = {
		getter = getters.get_tools,
		transform = transforms.transform_tools_none,
	},
	
	-- Advanced properties
	role = {
		getter = getters.get_role,
		transform = transforms.transform_role,
	},
	system_prompt = {
		getter = getters.get_system_prompt,
		transform = transforms.transform_system_prompt,
	},
	context = {
		getter = getters.get_context,
		transform = transforms.transform_context,
	},
	memory = {
		getter = getters.get_memory,
		transform = transforms.transform_memory,
	},
}

-- Alternative tool configurations users can choose from
M.tool_variants = {
	none = {
		getter = getters.get_tools,
		transform = transforms.transform_tools_none,
	},
	full_stack_dev = {
		getter = getters.get_tools,
		transform = transforms.transform_tools_full_stack_dev,
	},
	mapped = {
		getter = getters.get_tools,
		transform = transforms.transform_tools_mapped,
	},
}

return M