-- Helper for AP-style rule definition
-- this mostly maps to BaseClasses.py

local free = function(state) return true end


function table.shallow_copy(t)
    local t2 = {}
    for k,v in pairs(t) do
      t2[k] = v
    end
    return t2
  end


AppendableList = {
    append = function(t,v)
        t[#t+1]=v
    end
}
AppendableList.__index = AppendableList


State = {}
State.__index = State

function State:new(definition)
    local res = {}
    res.stale = true -- TODO: update this
    res.definition = definition
    res.reachable_regions = {}
    --res.blocked_connections = {}
    setmetatable(res, self)
    return res
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
    --print(dump(queue, 8))

    while #queue > 0 do
        connection = queue[#queue]
        queue[#queue] = nil
        new_region = connection.connected_region
        
        --print("checking " .. connection.name)
        if not reachable[new_region] and connection:can_reach(self) then
            reachable[new_region] = true
            for _, exit_ in ipairs(new_region.exits) do
                queue[#queue + 1] = exit_
            end
        end
    end
end


Location = {}
Location.__index = Location

function Location:new(name, code, parent_region)
    local res = {}
    res.name = name
    res.code = code
    res.parent_region = parent_region
    res.access_rule = free
    setmetatable(res, self)
    return res
end

function Location:set_rule(rule)
    self.access_rule = rule
end

function Location:can_reach(state)
    print(self.name .. ": " .. tostring(self.access_rule(state)) .. " and " .. tostring(self.parent_region:can_reach(state)))
    return self.access_rule(state) and self.parent_region:can_reach(state)
end


Region = {}
Region.__index = Region

function Region:new(name, definition)
    local res = {}
    res.name = name
    res.locations = {}
    res.exits = {}
    res.entrances = {}
    res.definition = definition
    setmetatable(res, self)
    setmetatable(res.locations, AppendableList)
    setmetatable(res.exits, AppendableList)
    setmetatable(res.entrances, AppendableList)
    return res
end

function Region:create_exit(name)
    exit_ = Entrance:new(name, self)
    self.exits:append(exit_)
    return exit_
end

function Region:connect(connecting_region, name, rule)
    if name == nil then
        name = self.name .. " -> " .. connecting_region.name
    end
    exit_ = self:create_exit(name)
    if rule then
        exit_.access_rule = rule
    end
    exit_:connect(connecting_region)
    return exit_
end

function Region:add_exits(exits)
    -- TODO: implement exits for Dict[str, Optional[str]] type
    -- TODO: implement rules: Dict[str, Callable[[CollectionState], bool]] = None) -> None:
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
        --print("  updating regions")
        state:update_reachable_regions()
        --print("  " .. dump(state.reachable_regions))
    end
    --print(tostring(state.reachable_regions[self]))
    return not not state.reachable_regions[self]
end


Entrance = {}
Entrance.__index = Entrance

function Entrance:new(name, parent_region)
    local res = {}
    res.name = name
    res.parent_region = parent_region
    res.access_rule = free
    setmetatable(res, self)
    return res
end

function Entrance:set_rule(rule)
    self.access_rule = rule
end

function Entrance:connect(destination, addresses, target)
    self.connected_region = destination
    self.target = target -- is this lttp crap?
    self.addresses = addresses -- is this lttp crap?
    destination.entrances:append(self)
end

function Entrance:can_reach(state)
    --print("  " .. tostring(self.parent_region:can_reach(state)) .. " and " .. tostring(self.access_rule(state)))
    return self.parent_region:can_reach(state) and self.access_rule(state)
end


Definition = {}
Definition.__index = Definition

function Definition:new()
    local res = {}
    res.regions = {}
    setmetatable(res, self)
    setmetatable(res.regions, AppendableList)
    return res
end

function Definition:get_region(name)
    --return self.regions[name]
    for _, region in ipairs(self.regions) do
        if region.name == name then
            return region
        end
    end
end

function Definition:get_entrance(name)
    --return self.entrances[name]
    for _, region in ipairs(self.regions) do
        --print(region.name .. ":" .. dump(region.entrances))
        for _, entrance in ipairs(region.entrances) do
            --print(entrance.name .. " == " .. name .. " ?")
            if entrance.name == name then
                return entrance
            end
        end
    end
end

function Definition:get_location(name)
    --return self.locations[name]
    for _, region in ipairs(self.regions) do
        for _, location in ipairs(region.locations) do
            if location.name == name then
                return location
            end
        end
    end
end
