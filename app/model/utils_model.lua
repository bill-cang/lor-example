
local utils_model = {}

-- deep-copy a table
function utils_model:table_clone (t)
    if type(t) ~= "table" then
        return t
    end

    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            target[k] = table_clone(v)
        else
            target[k] = v
        end
    end
    setmetatable(target, meta)
    return target
end

return utils_model

