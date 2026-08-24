ScriptHost:LoadScript("scripts/vendor/tinyyaml/tinyyaml.lua")

local tag_level_to_int = {
    advanced = 1,
    hard = 2,
    expert = 3,
    lunatic = 4,
}

local option_to_value = {
    game_version = {
        map_patch = 1,
        full_gold = 2,
    },
    spawn_point = {
        dungeon_mirror = 2,
    },
}


local TrueR = function() return true end
local FalseR = function() return false end


local PseudoregaliaRule = {}
local And = {}
local Or = {}
local Has = {}
local CanReachRegion = {}
local True = {}


-- TODO: for now rules don't really do optimizations in resolve and can't because resolve return values are functions
-- instaed of tables
PseudoregaliaRule.__index = PseudoregaliaRule

function PseudoregaliaRule:new(rule_data, ref_rules)
    local and_clauses = {}
    if rule_data["and"] ~= nil then
        for i = 1,#rule_data["and"] do
            local child_data = rule_data["and"][i]
            and_clauses[#and_clauses+1] = PseudoregaliaRule:new(child_data, ref_rules)
        end
    end
    if rule_data["or"] ~= nil then
        local or_clauses = {}
        for i = 1,#rule_data["or"] do
            local child_data = rule_data["or"][i]
            or_clauses[#or_clauses+1] = PseudoregaliaRule:new(child_data, ref_rules)
        end
        and_clauses[#and_clauses+1] = Or:new(or_clauses)
    end
    if rule_data.has ~= nil then
        and_clauses[#and_clauses+1] = Has:new(rule_data.has)
    end
    if rule_data.can_reach_region ~= nil then
        and_clauses[#and_clauses+1] = CanReachRegion:new(rule_data.can_reach_region)
    end
    if rule_data.ref ~= nil then
        if type(rule_data.ref) == "table" then
            for i = 1,#rule_data.ref do
                local ref = rule_data.ref[i]
                and_clauses[#and_clauses+1] = ref_rules[ref]
            end
        else
            and_clauses[#and_clauses+1] = ref_rules[rule_data.ref]
        end
    end

    local rule
    if #and_clauses == 0 then
        rule = True:new()
    elseif #and_clauses == 1 then
        rule = and_clauses[1]
    else
        rule = And:new(and_clauses)
    end

    local tags
    if rule_data.tags ~= nil then
        tags = {}
        for tag, level in pairs(rule_data.tags) do
            tags[tag] = tag_level_to_int[level]
        end
    end

    return setmetatable({
        rule = rule,
        tags = tags,
        options = rule_data.options,
    }, self)
end

function PseudoregaliaRule:resolve(definition)
    if self:passes_filter(definition) then
        return self.rule:resolve(definition)
    end
    return FalseR
end

function PseudoregaliaRule:passes_filter(definition)
    if self.tags ~= nil then
        for tag, level in pairs(self.tags) do
            if definition.tags[tag] < level then
                return false
            end
        end
    end
    if self.options ~= nil then
        for option, value in pairs(self.options) do
            if definition.options[option] ~= option_to_value[option][value] then
                return false
            end
        end
    end
    return true
end


Or.__index = Or

function Or:new(clauses)
    return setmetatable({
        clauses = clauses,
    }, self)
end

function Or:resolve(definition)
    local clauses = {}
    for i = 1,#self.clauses do
        local clause = self.clauses[i]
        local resolved = clause:resolve(definition)
        if resolved == TrueR then
            return resolved
        end
        if resolved ~= FalseR then
            clauses[#clauses+1] = resolved
        end
    end

    if #clauses == 0 then
        return FalseR
    elseif #clauses == 1 then
        return clauses[1]
    end

    return function(state)
        for i = 1,#clauses do
            local clause = clauses[i]
            if clause(state) then
                return true
            end
        end
        return false
    end
end


And.__index = And

function And:new(clauses)
    return setmetatable({
        clauses = clauses,
    }, self)
end

function And:resolve(definition)
    local clauses = {}
    for i = 1,#self.clauses do
        local clause = self.clauses[i]
        local resolved = clause:resolve(definition)
        if resolved == FalseR then
            return resolved
        end
        if resolved ~= TrueR then
            clauses[#clauses+1] = resolved
        end
    end

    if #clauses == 0 then
        return TrueR
    elseif #clauses == 1 then
        return clauses[1]
    end

    return function(state)
        for i = 1,#clauses do
            local clause = clauses[i]
            if not clause(state) then
                return false
            end
        end
        return true
    end
end


Has.__index = Has

function Has:new(has_data)
    local items = {}
    if type(has_data) == "string" then
        items[has_data] = 1
    elseif has_data[1] ~= nil then
        for i = 1,#has_data do
            local item = has_data[i]
            items[item] = 1
        end
    else
        items = has_data
    end

    return setmetatable({
        items = items,
    }, self)
end

function Has:resolve()
    return function(state)
        for item, count in pairs(self.items) do
            if state:count(item) < count then
                return false
            end
        end
        return true
    end
end


CanReachRegion.__index = CanReachRegion

function CanReachRegion:new(region)
    return setmetatable({
        region = region
    }, self)
end

function CanReachRegion:resolve(definition)
    local region = definition:get_region(self.region)
    return function(state)
        return region:can_reach(state)
    end
end


-- True is very simple but I'm doing it this way just to match the other rule objects
True.__index = True

function True:new()
    return setmetatable({}, self)
end

function True:resolve(_)
    return TrueR
end


local f = assert(io.open("scripts/logic/logic.yaml", "r"))
local raw_data = f:read("*all")
local pseudoregalia_data = tinyyaml.parse(raw_data)

local ref_rules = {}
for i = 1,#pseudoregalia_data.ref_rules do
    local ref_rule_data = pseudoregalia_data.ref_rules[i]
    ref_rules[ref_rule_data.name] = PseudoregaliaRule:new(ref_rule_data.rule, ref_rules)
end

function create_entrance_name(from, to, entrance_name)
    if entrance_name ~= nil then return entrance_name end
    return from .. " -> " .. to
end

local entrance_rules = {}
for i = 1,#pseudoregalia_data.regions do
    local region_data = pseudoregalia_data.regions[i]
    if region_data.exits == nil then goto continue_outer end

    for j = 1,#region_data.exits do
        local exit_data = region_data.exits[j]
        if exit_data.rule == nil then goto continue_inner end

        local entrance_name = create_entrance_name(region_data.name, exit_data.region, exit_data.entrance_name)
        entrance_rules[entrance_name] = PseudoregaliaRule:new(exit_data.rule, ref_rules)
        ::continue_inner::
    end
    ::continue_outer::
end

local location_rules = {}
for i = 1,#pseudoregalia_data.locations do
    local location_data = pseudoregalia_data.locations[i]
    if location_data.rule == nil then goto continue end

    location_rules[location_data.name] = PseudoregaliaRule:new(location_data.rule, ref_rules)
    ::continue::
end

local player_starts = {}
for i = 1,#pseudoregalia_data.enums.player_start do
    player_starts[pseudoregalia_data.enums.player_start[i]] = i-1
end

rules = {
    pseudoregalia_data = pseudoregalia_data,
    entrance_rules = entrance_rules,
    location_rules = location_rules,
    create_entrance_name = create_entrance_name,
    player_starts = player_starts,
    FalseR = FalseR,
}

return rules
