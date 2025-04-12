-- TODO: require base

local free = function(state) return true end

PseudoregaliaLunaticRules = PseudoregaliaExpertRules:new(nil)

function PseudoregaliaLunaticRules.new(cls, definition)
    local self = PseudoregaliaExpertRules.new(cls, definition)

    region_clauses = {
        ["Dungeon Escape Lower -> Dungeon Escape Upper"] = function(state)
            return self:has_slide(state) and self:kick_or_plunge(state, 1)
        end,
        ["Castle Spiral Climb -> Castle By Scythe Corridor"] = function(state)
            return self:get_kicks(state, 3)
        end,
        ["Castle By Scythe Corridor -> Castle => Theatre (Front)"] = function(state)
            return self:has_slide(state) and self:kick_or_plunge(state, 2)
        end,
        ["Library Main -> Library Top"] = function(state)
            return self:get_kicks(state, 1)
        end,
        ["Library Top -> Library Greaves"] = function(state)
            return self:can_bounce(state) and self:get_kicks(state, 1) and self:has_plunge(state)
        end,
        ["Underbelly Main Lower -> Underbelly Main Upper"] = function(state)
            return self:has_slide(state)
            and (
                self:has_gem(state)
                or self:get_kicks(state, 2)
                or self:get_kicks(state, 1) and self:has_plunge(state)
                or self:get_kicks(state, 1) and self:has_breaker(state))
        end,
    }

    location_clauses = {
        ["Dilapidated Dungeon - Past Poles"] = function(state)
            return self:has_slide(state) and self:get_kicks(state, 1) and self:has_plunge(state)
        end,
        ["Dilapidated Dungeon - Rafters"] = function(state)
            return self:can_bounce(state) and self:kick_or_plunge(state, 1)
            or self:has_slide(state)
        end,
        ["Dilapidated Dungeon - Strong Eyes"] = function(state)
            return self:has_slide(state) and self:kick_or_plunge(state, 1)
        end,
        ["Castle Sansa - Platform In Main Halls"] = function(state)
            return self:can_bounce(state)
        end,
        ["Castle Sansa - Corner Corridor"] = function(state)
            return self:get_kicks(state, 1) and self:has_slide(state)
        end,
        ["Castle Sansa - Alcove Near Scythe Corridor"] = function(state)
            return self:kick_or_plunge(state, 1)  --# This never really matters and that makes me sad
        end,
        ["Sansa Keep - Levers Room"] = free,
        ["Sansa Keep - Lonely Throne"] = function(state)
            return self:has_breaker(state) and self:has_slide(state) and self:kick_or_plunge(state, 3)
            or (
                self:has_slide(state)
                and self:can_bounce(state)
                and self:get_kicks(state, 1)
                and self:has_plunge(state)
                and self:can_soulcutter(state))
        end,
        ["Listless Library - Upper Back"] = function(state)
            return self:has_plunge(state)
        end,
    }

    self:apply_clauses(region_clauses, location_clauses)

    return self
end

return PseudoregaliaLunaticRules -- prepare for require()
