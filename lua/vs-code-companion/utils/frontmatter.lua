local M = {}

local function parse_yaml(yaml_str)
	local result = {}

	for line in yaml_str:gmatch("[^\r\n]+") do
		line = line:gsub("^%s+", ""):gsub("%s+$", "")

		if line ~= "" and not line:match("^#") then
			local key, value = line:match("^([^:]+):%s*(.*)$")

			if key and value then
				key = key:gsub("%s+$", "")

				if value:match("^%[.*%]$") then
					local array = {}
					for item in value:gmatch("'([^']*)'") do
						table.insert(array, item)
					end
					result[key] = array
				elseif value:match("^[\"'].*[\"']$") then
					result[key] = value:match('^["\'](.*)["\'"]$')
				elseif value:match("^%d+%.?%d*$") then
					result[key] = tonumber(value)
				elseif value:lower() == "true" or value:lower() == "false" then
					result[key] = value:lower() == "true"
				else
					result[key] = value
				end
			end
		end
	end

	return result
end

function M.parse(content)
	local frontmatter_pattern = "^%s*---%s*\n(.-)\n%s*---%s*\n(.*)$"
	local frontmatter_str, main_content = content:match(frontmatter_pattern)

	if frontmatter_str and main_content then
		return {
			frontmatter = parse_yaml(frontmatter_str),
			content = main_content:gsub("^%s*", ""),
		}
	else
		return {
			frontmatter = {},
			content = content,
		}
	end
end

return M
