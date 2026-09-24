ScriptHost:LoadScript("scripts/vendor/tinyyaml/tinyyaml.lua")

local tag_level_to_int = {
    advanced = 1,
    hard = 2,
    expert = 3,
    lunatic = 4,
}

local option_to_value = {
    ultra_cap = {
        full_gold = 1,
    },
    spawn_point = {
        dungeon_mirror = 2,
    },
}


local PseudoregaliaRule = {}
local And = {}
local Or = {}
local Has = {}
local True = {}

local AndR = { type = "AndR" }
local OrR = { type = "OrR" }
local HasR = { type = "HasR" }
local TrueR = { type = "TrueR" }
local FalseR = { type = "FalseR" }


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
    return FalseR:new()
end

function PseudoregaliaRule:to_string()
    if self.tags == nil and self.options == nil then
        return self.rule:to_string()
    end
    local s = "PseudoregaliaRule("
    s = s .. self.rule:to_string()
    if self.tags ~= nil then
        s = s .. ", tags={"
        local first = true
        for tag, value in pairs(self.tags) do
            if first then first = false else s = s .. ", " end
            s = s .. tag .. ": " .. value
        end
        s = s .. "}"
    end
    if self.options ~= nil then
        s = s .. ", options={"
        local first = true
        for option, value in pairs(self.options) do
            if first then first = false else s = s .. ", " end
            s = s .. option .. ": " .. tostring(value)
        end
        s = s .. "}"
    end
    s = s .. ")"
    return s
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
            if definition.options[option].value ~= option_to_value[option][value] then
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
    local queue = {}
    for i = 1,#self.clauses do
        queue[i] = self.clauses[i]:resolve(definition)
    end

    local clauses = {}
    while #queue > 0 do
        local resolved = queue[#queue]
        queue[#queue] = nil

        if resolved.type == TrueR.type then
            return resolved
        elseif resolved.type == OrR.type then
            for i = 1,#resolved.clauses do
                queue[#queue+1] = resolved.clauses[i]
            end
        elseif resolved.type ~= FalseR.type then
            clauses[#clauses+1] = resolved
        end
    end

    if #clauses == 0 then
        return FalseR:new()
    elseif #clauses == 1 then
        return clauses[1]
    end

    return OrR:new(clauses)
end

function Or:to_string()
    local s = "Or("
    local first = true
    for i = 1,#self.clauses do
        if first then first = false else s = s .. ", " end
        s = s .. self.clauses[i]:to_string()
    end
    s = s .. ")"
    return s
end


And.__index = And

function And:new(clauses)
    return setmetatable({
        clauses = clauses,
    }, self)
end

function And:resolve(definition)
    local queue = {}
    for i = 1,#self.clauses do
        queue[i] = self.clauses[i]:resolve(definition)
    end

    local clauses = {}
    local items = {}
    while #queue > 0 do
        local resolved = queue[#queue]
        queue[#queue] = nil

        if resolved.type == FalseR.type then
            return resolved
        elseif resolved.type == AndR.type then
            for i = 1,#resolved.clauses do
                queue[#queue+1] = resolved.clauses[i]
            end
        elseif resolved.type == HasR.type then
            for item, count in pairs(resolved.items) do
                if count > (items[item] or 0) then
                    items[item] = count
                end
            end
        elseif resolved.type ~= TrueR.type then
            clauses[#clauses+1] = resolved
        end
    end
    if next(items) ~= nil then
        clauses[#clauses+1] = HasR:new(items)
    end

    if #clauses == 0 then
        return TrueR:new()
    elseif #clauses == 1 then
        return clauses[1]
    end

    return AndR:new(clauses)
end

function And:to_string()
    local s = "And("
    local first = true
    for i = 1,#self.clauses do
        if first then first = false else s = s .. ", " end
        s = s .. self.clauses[i]:to_string()
    end
    s = s .. ")"
    return s
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
    return HasR:new(self.items)
end

function Has:to_string()
    local s = "Has("
    local first = true
    for item, count in pairs(self.items) do
        if first then first = false else s = s .. ", " end
        s = s .. item .. ": " .. tostring(count)
    end
    s = s .. ")"
    return s
end


-- True is very simple but I'm doing it this way just to match the other rule objects
True.__index = True

function True:new()
    return setmetatable({}, self)
end

function True:resolve(_)
    return TrueR:new()
end

function True:to_string()
    return "True"
end


AndR.__index = AndR

function AndR:new(clauses)
    return setmetatable({
        clauses = clauses,
    }, self)
end

function AndR:__call(state)
    for i = 1,#self.clauses do
        if not self.clauses[i](state) then
            return false
        end
    end
    return true
end

function AndR:to_string()
    local s = "And("
    local first = true
    for i = 1,#self.clauses do
        if first then first = false else s = s .. ", " end
        s = s .. self.clauses[i]:to_string()
    end
    s = s .. ")"
    return s
end


OrR.__index = OrR

function OrR:new(clauses)
    return setmetatable({
        clauses = clauses,
    }, self)
end

function OrR:__call(state)
    for i = 1,#self.clauses do
        if self.clauses[i](state) then
            return true
        end
    end
    return false
end

function OrR:to_string()
    local s = "Or("
    local first = true
    for i = 1,#self.clauses do
        if first then first = false else s = s .. ", " end
        s = s .. self.clauses[i]:to_string()
    end
    s = s .. ")"
    return s
end


HasR.__index = HasR

function HasR:new(items)
    return setmetatable({
        items = items,
    }, self)
end

function HasR:__call(state)
    for item, count in pairs(self.items) do
        if state:count(item) < count then
            return false
        end
    end
    return true
end

function HasR:to_string()
    local s = "Has("
    local first = true
    for item, count in pairs(self.items) do
        if first then first = false else s = s .. ", " end
        s = s .. item .. ": " .. tostring(count)
    end
    s = s .. ")"
    return s
end


TrueR.__index = TrueR

function TrueR:new()
    return setmetatable({}, self)
end

function TrueR:__call()
    return true
end

function TrueR:to_string()
    return "True"
end


FalseR.__index = FalseR

function FalseR:new()
    return setmetatable({}, self)
end

function FalseR:__call()
    return false
end

function FalseR:to_string()
    return "False"
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
    TrueR = TrueR,
    FalseR = FalseR,
}

return rules
