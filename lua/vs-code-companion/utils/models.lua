local M = {}

M.model_mappings = {
	-- Claude models
	["Claude Sonnet 4"] = "claude-4-sonnet",
	["Claude Sonnet 3.5"] = "claude-3-5-sonnet-20241022",
	["Claude Sonnet"] = "claude-3-5-sonnet-20241022",
	["Claude Haiku 3.5"] = "claude-3-5-haiku-20241022",
	["Claude Haiku"] = "claude-3-5-haiku-20241022",
	["Claude Opus 3"] = "claude-3-opus-20240229",
	["Claude Opus"] = "claude-3-opus-20240229",

	-- OpenAI models
	["GPT-4"] = "gpt-4",
	["GPT-4 Turbo"] = "gpt-4-turbo-preview",
	["GPT-4o"] = "gpt-4o",
	["GPT-4o Mini"] = "gpt-4o-mini",
	["GPT-3.5 Turbo"] = "gpt-3.5-turbo",

	-- Google models
	["Gemini 2.5 Pro"] = "gemini-2.5-pro",
	["Gemini 2.5 Flash"] = "gemini-2.5-flash",
	["Gemini Pro"] = "gemini-2.5-pro",
	["Gemini Flash"] = "gemini-2.5-flash",

	-- Other models
	["Llama 70B"] = "llama-70b",
	["Llama 8B"] = "llama-8b",
}

-- Transform a display model name to technical name
function M.get_technical_name(display_name)
	if not display_name then
		return nil
	end

	-- Try exact match first
	local technical = M.model_mappings[display_name]
	if technical then
		return technical
	end

	-- Try case-insensitive match
	for display, tech in pairs(M.model_mappings) do
		if display:lower() == display_name:lower() then
			return tech
		end
	end

	-- If no mapping found, try to convert the name automatically
	-- This is a fallback for cases not in our mapping table
	return display_name:lower():gsub("%s+", "-"):gsub("%.", "")
end

-- Get all available display names
function M.get_display_names()
	local names = {}
	for display_name, _ in pairs(M.model_mappings) do
		table.insert(names, display_name)
	end
	table.sort(names)
	return names
end

-- Validate if a technical model name is supported
function M.is_supported_model(technical_name)
	for _, tech_name in pairs(M.model_mappings) do
		if tech_name == technical_name then
			return true
		end
	end
	return false
end

return M
