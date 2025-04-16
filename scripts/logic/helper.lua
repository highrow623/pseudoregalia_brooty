-- Helper for Archipelago-style logic definition
-- this mostly maps to AP's BaseClasses.py and Options.py
-- see https://github.com/ArchipelagoMW/Archipelago for original copyright


-- python-style helpers


local free = function(state) return true end


function table.shallow_copy(t)
    local t2 = {}
    for k,v in pairs(t) do
      t2[k] = v
    end
    return t2
  end


local AppendableList = {
    new = function(cls,self)
        if self == nil then self = {} end
        return setmetatable(self, cls)
    end,
    append = function(t,v)
        t[#t+1]=v
    end,
    clear = function(t)
        for i = 1,#t do t[i] = nil end
    end,
}
AppendableList.__index = AppendableList


-- Base Classes


local State = {}
local Location = {}
local Region = {}
local Entrance = {}
local Definition = {}


State.__index = State

function State:new(definition)
    if not definition then
        error("definition required")
    end

    return setmetatable({
        stale = true,
        definition = definition,
        reachable_regions = {},
        --res.blocked_connections = {},
    }, self)
end

function State:has(item_name)
    return Tracker:ProviderCountForCode(item_name) > 0
end

function State:has_any(item_names)
    for _, item_name in ipairs(item_names) do
        if self:has(item_name) then
            return true
        end
    end
    return false
end

function State:has_all(item_names)
    for _, item_name in ipairs(item_names) do
        if not self:has(item_name) then
            return false
        end
    end
    return true
end

function State:count(item_name)
    return Tracker:ProviderCountForCode(item_name)
end

function State:update_reachable_regions()
    self.stale = false
    local reachable = {} -- TODO: cache
    local start = self.definition:get_region("Menu")
    local queue = table.shallow_copy(start.exits)
    reachable[start] = start
    self.reachable_regions = reachable

    while #queue > 0 do
        connection = queue[#queue]
        queue[#queue] = nil
        new_region = connection.connected_region

        if not reachable[new_region] and connection:can_reach(self) then
            reachable[new_region] = true
            for _, exit_ in ipairs(new_region.exits) do
                queue[#queue + 1] = exit_
            end
        end
    end
end


Location.__index = Location

function Location:new(name, code, parent_region)
    return setmetatable({
        name = name,
        code = code,
        parent_region = parent_region,
        access_rules = {},
    }, self)
end

function Location:set_rule(rule)
    table.insert(self.access_rules, rule)
end

function Location:add_rule(rule, _)
    table.insert(self.access_rules, rule)
end

function Location:can_reach(state)
    if not self.parent_region:can_reach(state) then
        return false
    end
    if #self.access_rules == 0 then
        return true
    end
    for _, rule in ipairs(self.access_rules) do
        if rule(state) then
            return true
        end
    end
    return false
end


Region.__index = Region

function Region:new(name, definition)
    return setmetatable({
        name = name,
        definition = definition,
        locations = AppendableList:new(),
        exits = AppendableList:new(),
        entrances = AppendableList:new(),
    }, self)
end

function Region:create_exit(name)
    local exit = Entrance:new(name, self)
    self.exits:append(exit)
    return exit
end

function Region:connect(connecting_region, name, rule)
    if name == nil then
        name = self.name .. " -> " .. connecting_region.name
    end
    local exit = self:create_exit(name)
    if rule then
        exit.access_rule = rule
    end
    exit:connect(connecting_region)
    return exit
end

function Region:add_exits(exits, rules)
    -- TODO: implement exits for Dict[str, Optional[str]] type
    -- TODO: implement rules: Dict[str, Callable[[CollectionState], bool]] = None) -> None:
    if rules then
        error("rules handling not implemented in Region:add_exits")
    end

    name = nil -- TODO
    for _, connecting_region_name in ipairs(exits) do
        local destination = self.definition:get_region(connecting_region_name)
        if not destination then
            error("No such region " .. connecting_region_name)
        end
        self:connect(destination, name)
    end
end

function Region:can_reach(state)
    if state.stale then
        state:update_reachable_regions()
    end
    return not not state.reachable_regions[self]
end


Entrance.__index = Entrance

function Entrance:new(name, parent_region)
    return setmetatable({
        name = name,
        parent_region = parent_region,
        access_rules = {},
    }, self)
end

function Entrance:set_rule(rule)
    table.insert(self.access_rules, rule)
end

function Entrance:add_rule(rule, _)
    table.insert(self.access_rules, rule)
end

function Entrance:connect(destination, addresses, target)
    self.connected_region = destination
    self.target = target -- is this lttp crap?
    self.addresses = addresses -- is this lttp crap?
    destination.entrances:append(self)
end

function Entrance:can_reach(state)
    if not self.parent_region:can_reach(state) then
        return false
    end
    if #self.access_rules == 0 then
        return true
    end
    for _, rule in ipairs(self.access_rules) do
        if rule(state) then
            return true
        end
    end
    return false
end


Definition.__index = Definition

function Definition:new()
    return setmetatable({
        regions = AppendableList:new(),
        options = {},
    }, self)
end

function Definition:get_region(name)
    --return self.regions[name] -- TODO: cache
    for _, region in ipairs(self.regions) do
        if region.name == name then
            return region
        end
    end
end

function Definition:get_entrance(name)
    --return self.entrances[name] -- TODO: cache
    for _, region in ipairs(self.regions) do
        for _, entrance in ipairs(region.entrances) do
            if entrance.name == name then
                return entrance
            end
        end
    end
end

function Definition:get_location(name)
    --return self.locations[name] -- TODO: cache
    for _, region in ipairs(self.regions) do
        for _, location in ipairs(region.locations) do
            if location.name == name then
                return location
            end
        end
    end
end

function Definition:set_options(options, values)
    -- missing value will try to resulve through code and fall back to default
    if values == nil then
        values = {}
    end
    for name, class in pairs(options) do
        self.options[name] = class:new(values[name])
    end
end


-- Options


local Choice = {
    value_to_code = {},  -- mapping to Tracker codes
    default = 0,
}
Choice.__index = Choice

function Choice.new(cls, initial_value)
    local self = {}
    cls.__index = cls
    cls.__eq = Choice.__eq
    setmetatable(self, cls)
    self.code_to_value = {}
    for value, code in pairs(self.value_to_code) do
        if value == nil or code == nil then
            error("Invalid option in code_to_value")
        end
        self.code_to_value[code] = value
        if initial_value == nil then
            -- if value is not provided, try to load from Tracker
            if Tracker:ProviderCountForCode(code) > 0 then
                initial_value = value
            end
        end
    end
    if initial_value == nil then
        self.value = self.default
    else
        self.value = initial_value
    end
    return self
end

function Choice:__eq(other)
    -- NOTE: this is NOT being called for type(other) == string or number. Use .value for that.
    if type(other) == type(self) then
        return self.value == other.value  -- compare value of two instances
    else
        return self.value == other  -- compare value of instance to const
    end
end

local Toggle = {
    default = false,
}
Toggle.__index = Toggle
setmetatable(Toggle, Choice)

function Toggle.new(cls, initial_value)
    if cls.code == nil then
        error("Toggle needs to define code")
    end
    cls.value_to_code = {[true] = cls.code}  -- so we can use Choice's code
    return Choice.new(cls, initial_value)
end


-- Module


-- create module table
helper = {
    AppendableList = AppendableList,
    State = State,
    Location = Location,
    Region = Region,
    Entrance = Entrance,
    Definition = Definition,
    Choice = Choice,
    Toggle = Toggle,
}

-- return the module table for require
return helper
