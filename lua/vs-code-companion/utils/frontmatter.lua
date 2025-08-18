-- YAML frontmatter parser
local M = {}

-- Simple YAML parser for frontmatter
local function parse_yaml(yaml_str)
  local result = {}
  
  for line in yaml_str:gmatch('[^\r\n]+') do
    line = line:gsub('^%s+', ''):gsub('%s+$', '') -- trim whitespace
    
    if line ~= '' and not line:match('^#') then -- skip empty lines and comments
      local key, value = line:match('^([^:]+):%s*(.*)$')
      
      if key and value then
        key = key:gsub('%s+$', '') -- trim trailing whitespace from key
        
        -- Handle different value types
        if value:match('^%[.*%]$') then
          -- Array syntax like ['item1', 'item2']
          local array = {}
          for item in value:gmatch("'([^']*)'") do
            table.insert(array, item)
          end
          result[key] = array
        elseif value:match('^["\'].*["\']$') then
          -- Quoted string
          result[key] = value:match('^["\'](.*)["\'"]$')
        elseif value:match('^%d+%.?%d*$') then
          -- Number
          result[key] = tonumber(value)
        elseif value:lower() == 'true' or value:lower() == 'false' then
          -- Boolean
          result[key] = value:lower() == 'true'
        else
          -- Plain string
          result[key] = value
        end
      end
    end
  end
  
  return result
end

-- Parse markdown file with frontmatter
function M.parse(content)
  local frontmatter_pattern = '^%s*---%s*\n(.-)\n%s*---%s*\n(.*)$'
  local frontmatter_str, main_content = content:match(frontmatter_pattern)
  
  if frontmatter_str and main_content then
    return {
      frontmatter = parse_yaml(frontmatter_str),
      content = main_content:gsub('^%s*', ''), -- trim leading whitespace
    }
  else
    -- No frontmatter found
    return {
      frontmatter = {},
      content = content,
    }
  end
end

return M