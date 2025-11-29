local config = _G.offset_config or {
  ignore_duplicates = true
}

local sources = config.sources or {
    "https://imtheo.lol/Offsets/Offsets.json",
    "https://offsets.ntgetwritewatch.workers.dev/offsets.json",
}

local function to_dec(v)
    if typeof(v) == "string" and v:sub(1,2):lower() == "0x" then
        return tonumber(v, 16)
    end
    return tonumber(v)
end

local function flatten_offsets(t, result, visited)
    if typeof(t) ~= "table" then return end
    
    visited = visited or {}
    if visited[t] then return end
    visited[t] = true
    
    for k, v in pairs(t) do
        if string.find(k, "%s") then continue end
        if typeof(v) == "table" then
            flatten_offsets(v, result, visited)
        else
            local dec_value = to_dec(v)
            if dec_value and (not config.ignore_duplicates or result[k] == nil) then
                result[k] = dec_value
            end
        end
    end
end

local offsets = {}

for _, url in sources do
    local success, data = pcall(function()
        return crypt.json.decode(game:HttpGet(url))
    end)
    
    if success and data then
        flatten_offsets(data, offsets)
    end
end

return offsets
