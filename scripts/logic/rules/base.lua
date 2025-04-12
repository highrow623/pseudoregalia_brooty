PseudoregaliaRulesHelpers = {} -- rules base. See normal, hard, expert and lunatic for finished rules.


local NORMAL = constants.difficulties.NORMAL

local free = function(state) return true end
local no = function(state) return false end


function PseudoregaliaRulesHelpers.new(cls, definition)
    local self = {}
    self. definition = definition -- this is equivalent to multiworld in AP
    self.region_rules = {}
    self.location_rules = {}

    region_clauses = {
        ["Empty Bailey -> Castle Main"] = free,
        ["Empty Bailey -> Theatre Pillar"] = free,
        ["Empty Bailey -> Tower Remains"] = function(state)
            return self:has_gem(state) or self:has_slide(state) and self:has_plunge(state) or self:get_kicks(state, 1)
        end,
        ["Tower Remains -> Underbelly Little Guy"] = function(state)
            return self:has_plunge(state)
        end,
        ["Tower Remains -> The Great Door"] = function(state)
            return self:has_gem(state) and self:get_kicks(state, 3)
        end,
        ["Theatre Main -> Keep Main"] = function(state)
            return self:has_gem(state)
        end,
        ["Theatre Pillar -> Theatre Main"] = function(state)
            return state:has_all({"Sunsetter", "Cling Gem"}) or self:has_plunge(state) and self:get_kicks(state, 4)
        end,
        ["Theatre Outside Scythe Corridor -> Theatre Main"] = function(state)
            return self:has_gem(state) and (self:get_kicks(state, 3) or self:can_slidejump(state))
        end,
    }

    location_clauses = {
        ["Empty Bailey - Solar Wind"] = function(state)
            return self:has_slide(state)
        end,
        ["Empty Bailey - Cheese Bell"] = function(state)
            return (self:can_slidejump(state) and self:get_kicks(state, 1) and self:has_plunge(state)
                or self:can_slidejump(state) and self:has_gem(state)
                or self:get_kicks(state, 3) and self:has_plunge(state))
        end,
        ["Empty Bailey - Inside Building"] = function(state)
            return self:has_slide(state)
        end,
        ["Empty Bailey - Center Steeple"] = function(state)
            return self:get_kicks(state, 3) or self:has_slide(state) and self:has_plunge(state)
        end,
        ["Empty Bailey - Guarded Hand"] = function(state)
            return self:has_plunge(state) or self:has_gem(state) or self:get_kicks(state, 3)
        end,
        ["Twilight Theatre - Soul Cutter"] = function(state)
            return self:can_strikebreak(state)
        end,
        ["Twilight Theatre - Corner Beam"] = function(state)
            return (self:has_gem(state) and self:get_kicks(state, 3)
                or self:has_gem(state) and self:can_slidejump(state)
                or self:get_kicks(state, 3) and self:can_slidejump(state))
        end,
        ["Twilight Theatre - Locked Door"] = function(state)
            return self:has_small_keys(state) and (
                self:has_gem(state) or self:get_kicks(state, 3))
        end,
        ["Twilight Theatre - Back Of Auditorium"] = function(state)
            return self:get_kicks(state, 3) or self:has_gem(state)
        end,
        ["Twilight Theatre - Murderous Goat"] = free,
        ["Twilight Theatre - Center Stage"] = function(state)
            return self:can_soulcutter(state) and self:has_gem(state) and (
                self:can_slidejump(state) or self:get_kicks(state, 1))
        end,
        ["Tower Remains - Cling Gem"] = function(state)
            return self:get_kicks(state, 3)
        end,
        ["Tower Remains - Atop The Tower"] = free,
    }
    self:apply_clauses(region_clauses, location_clauses)
    self.required_small_keys = 6
    cls.__index = cls
    setmetatable(self, cls)
    return self
end

function PseudoregaliaRulesHelpers:apply_clauses(region_clauses, location_clauses)
    for name, rule in pairs(region_clauses) do
        if self.region_rules[name] == nil then
            table.insert(self.region_rules, name, {})
        end
        table.insert(self.region_rules[name], rule)
    end
    for name, rule in pairs(location_clauses) do
        if self.location_rules[name] == nil then
            table.insert(self.location_rules, name, {})
        end
        table.insert(self.location_rules[name], rule)
    end
end

function PseudoregaliaRulesHelpers:has_breaker(state)
    return state:has_any({"Dream Breaker", "Progressive Dream Breaker"})
end

function PseudoregaliaRulesHelpers:has_slide(state)
    return state:has_any({"Slide", "Progressive Slide"})
end

function PseudoregaliaRulesHelpers:has_plunge(state)
    return state:has("Sunsetter")
end

function PseudoregaliaRulesHelpers:has_gem(state)
    return state:has("Cling Gem")
end

function PseudoregaliaRulesHelpers:can_bounce(state)
    return self:has_breaker(state) and state:has("Ascendant Light")
end

function PseudoregaliaRulesHelpers:can_attack(state)
    error("can_attack has to be overridden")
end

function PseudoregaliaRulesHelpers:get_kicks(state, count)
    local kicks = 0
    if state:has("Sun Greaves") then
        kicks = kicks + 3
    end
    kicks = kicks + state:count("Heliacal Power")
    kicks = kicks + state:count("Air Kick")
    return kicks >= count
end

function PseudoregaliaRulesHelpers:kick_or_plunge(state, count)
    local total = 0
    if state:has("Sun Greaves") then
        total = total + 3
    end
    if state:has("Sunsetter") then
        total = total + 1
    end
    total = total + state:count("Heliacal Power")
    total = total + state:count("Air Kick")
    return total >= count
end

function PseudoregaliaRulesHelpers:has_small_keys(state)
    if not self:can_attack(state) then
        return false
    end
    return state:count("Small Key") >= self.required_small_keys
end

function PseudoregaliaRulesHelpers:navigate_darkrooms(state)
    return self:has_breaker(state) or state:has("Ascendant Light")
end

function PseudoregaliaRulesHelpers:can_slidejump(state)
    return (state:has_all({"Slide", "Solar Wind"})
        or state:count("Progressive Slide") >= 2)
end

function PseudoregaliaRulesHelpers:can_strikebreak(state)
    return (state:has_all({"Dream Breaker", "Strikebreak"})
        or state:count("Progressive Dream Breaker") >= 2)
end

function PseudoregaliaRulesHelpers:can_soulcutter(state)
    return (state:has_all({"Dream Breaker", "Strikebreak", "Soul Cutter"})
        or state:count("Progressive Dream Breaker") >= 3)
end

function PseudoregaliaRulesHelpers:knows_obscure(state)
    error("knows_obscure has to be overridden")
end

function PseudoregaliaRulesHelpers:set_pseudoregalia_rules()
    local split_kicks = self.definition.options.split_sun_greaves.value
    local obscure_logic = self.definition.options.obscure_logic.value
    local logic_level = self.definition.options.logic_level.value

    if obscure_logic then
        self.knows_obscure = free
        self.can_attack = function(self, state) return self:has_breaker(state) or self:has_plunge(state) end
    else
        self.knows_obscure = no
        self.can_attack = function(self, state) return self:has_breaker(state) end
    end

    if logic_level == NORMAL then
        self.required_small_keys = 7
    end

    for name, rules in pairs(self.region_rules) do
        local entrance = self.definition:get_entrance(name)
        if entrance then
            for index, rule in ipairs(rules) do
                if index == 1 then
                    entrance:set_rule(rule)
                else
                    entrance:add_rule(rule, "or")
                end
            end
        else
            print("Missing entrance: " .. name)
        end
    end
    for name, rules in pairs(self.location_rules) do
        local library = name:find("^Listless Library") ~= nil
        if (not library or
                not (split_kicks and name:find("Greaves$") ~= nil)
                and not (not split_kicks and tonumber(name:sub(-1)) ~= nil)) then
            local location = self.definition:get_location(name)
            if location then
                for index, rule in ipairs(rules) do
                    if index == 1 then
                        location:set_rule(rule)
                    else
                        location:add_rule(rule, "or")
                    end
                end
            else
                print("Missing location: " .. name)
            end
        end
    end

    self.definition:get_location("D S T RT ED M M O   Y"):set_rule(function(state)
        return state:has_all({
            "Major Key - Empty Bailey",
            "Major Key - The Underbelly",
            "Major Key - Tower Remains",
            "Major Key - Sansa Keep",
            "Major Key - Twilight Theatre",
        })
    end)
end

return PseudoregaliaRulesHelpers -- prepare for require()
