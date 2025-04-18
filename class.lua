local _class_list = {}
local _class_meta = {}

local function extends(self, _str)
    if _class_list[_str] == nil then error("Unkown class: " .. _str) end

    for key, value in pairs(_class_list[_str].members) do
        self.members[key] = value
    end

    return self
end

local function copy (t) -- shallow-copy a table
    if type(t) ~= "table" then return t end
    local meta = getmetatable(t)
    local target = {}
    for k, v in pairs(t) do target[k] = v end
    setmetatable(target, meta)
    return target
end

local function define(self, _tbl) 
    for key, value in pairs(_tbl) do
        self.members[key] = value
    end

    _class_list[self.name] = self

    self._new = function(...)
        local inst = {}
        inst._name = self.name

        for k, v in pairs(self.members) do
            inst[k] = copy(v)
        end

        setmetatable(inst, {
            __type = function() return self.name end,
            __newindex = function(t, key, value) error("Unknown member: '" .. key .. "'") end
        })

        if inst[self.name] then
            inst[self.name](inst, ...)
        end

        return inst
    end

    local f = function(...) return new( self.name, ... ) end
    return f
end

function _class_meta:__call(_v)
    if type(_v) == "string" then
        return self:extends(_v)
    else
        return self:define(_v)
    end
end

function _G.class(_str)
    return setmetatable({
        members = {},
        name    = _str,
        define  = define,
        extends = extends
    }, _class_meta)
end

function _G.new(_name, ...)
    local vargs = {...}

    if type(_name) ~= "string" then error("Expected string, got " .. type(_name)) end

    if #vargs == 0 then
        return _class_list[_name]._new
    else
        return _class_list[_name]._new(...)
    end
end
