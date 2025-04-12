-- TODO = require base

PseudoregaliaExpertRules = PseudoregaliaHardRules:new(nil)

function PseudoregaliaExpertRules.new(cls, definition)
    local self = PseudoregaliaHardRules.new(cls, definition)

    region_clauses = {
        ["Dungeon Escape Lower -> Dungeon Escape Upper"] = function(state)
            return self:has_slide(state) and self:get_kicks(state, 1)
        end,
        ["Dungeon Escape Upper -> Theatre Outside Scythe Corridor"] = function(state)
            return self:has_slide(state)
        end,
        ["Castle Main -> Theatre Pillar"] = function(state)
            return self:has_slide(state)
        end,
        ["Castle Main -> Castle Spiral Climb"] = function(state)
            return self:has_slide(state)
        end,
        ["Castle Spiral Climb -> Castle High Climb"] = function(state)
            return self:has_slide(state)
            or self:get_kicks(state, 2)
        end,
        ["Castle Spiral Climb -> Castle By Scythe Corridor"] = function(state)
            return self:kick_or_plunge(state, 4)
        end,
        ["Castle By Scythe Corridor -> Castle => Theatre (Front)"] = function(state)
            return self:has_slide(state) and self:get_kicks(state, 2)
        end,
        ["Castle By Scythe Corridor -> Castle High Climb"] = function(state)
            return self:has_slide(state)
            or self:kick_or_plunge(state, 2)
        end,
        ["Castle => Theatre (Front) -> Castle By Scythe Corridor"] = function(state)
            return self:has_slide(state)
            or self:get_kicks(state, 3)
        end,
        ["Castle => Theatre (Front) -> Castle Moon Room"] = function(state)
            return self:has_slide(state)
        end,
        ["Library Main -> Library Top"] = function(state)
            return self:has_plunge(state)
            or self:has_slide(state)
        end,
        ["Library Greaves -> Library Top"] = function(state)
            return self:has_slide(state)
        end,
        ["Library Top -> Library Greaves"] = function(state)
            return self:get_kicks(state, 2)
        end,
        ["Keep Main -> Keep => Underbelly"] = function(state)
            return self:has_slide(state)
        end,
        ["Keep Main -> Theatre Outside Scythe Corridor"] = function(state)
            return self:has_slide(state)
        end,
        ["Underbelly => Dungeon -> Underbelly Ascendant Light"] = function(state)
            return self:has_breaker(state)
            or self:get_kicks(state, 1) and self:has_slide(state)
        end,
        ["Underbelly Light Pillar -> Underbelly => Dungeon"] = function(state)
            return self:has_slide(state) and self:kick_or_plunge(state, 2)
        end,
        ["Underbelly Light Pillar -> Underbelly Ascendant Light"] = function(state)
            return self:has_breaker(state)
            and (
                self:get_kicks(state, 2)
                or self:get_kicks(state, 1) and self:has_gem(state)
                or self:has_slide(state))
            or self:has_plunge(state)
            and (
                self:has_gem(state)
                or self:get_kicks(state, 1)
                or self:has_slide(state))
        end,
        ["Underbelly Ascendant Light -> Underbelly => Dungeon"] = function(state)
            return self:has_slide(state) and self:get_kicks(state, 1)
        end,
        ["Underbelly Main Lower -> Underbelly Hole"] = function(state)
            return self:has_plunge(state) and self:has_slide(state)
        end,
        ["Underbelly Main Lower -> Underbelly By Heliacal"] = function(state)
            return self:has_slide(state)
        end,
        ["Underbelly Main Lower -> Underbelly Main Upper"] = function(state)
            return self:has_gem(state) and self:kick_or_plunge(state, 1)
            or self:get_kicks(state, 4)
            or self:has_slide(state)
            and (
                self:has_gem(state)
                or self:get_kicks(state, 3)
                or self:get_kicks(state, 1) and self:has_plunge(state)
                or self:get_kicks(state, 1) and self:has_breaker(state))
        end,
        ["Underbelly Main Upper -> Underbelly Light Pillar"] = function(state)
            return self:has_breaker(state) and self:has_slide(state)
            or self:has_slide(state) and self:get_kicks(state, 1)
            or self:has_plunge(state) and self:get_kicks(state, 2)
            or self:has_gem(state) and self:get_kicks(state, 2)
        end,
        ["Underbelly Main Upper -> Underbelly By Heliacal"] = function(state)
            return self:has_breaker(state) and self:has_slide(state) and self:get_kicks(state, 2)
        end,
        ["Underbelly By Heliacal -> Underbelly Main Upper"] = function(state)
            return self:has_plunge(state)
            or self:has_breaker(state)
            and (
                self:has_slide(state)
                or self:has_gem(state)
                or self:get_kicks(state, 1))
            or self:has_slide(state)
            and (
                self:has_gem(state)
                or self:get_kicks(state, 2))
        end,
        ["Underbelly Hole -> Underbelly Main Lower"] = function(state)
            return self:has_slide(state)
        end,
    }
    
    location_clauses = {
        ["Dilapidated Dungeon - Dark Orbs"] = function(state)
            return self:has_slide(state) and self:get_kicks(state, 1)
            or self:has_slide(state) and self:can_bounce(state)
        end,
        ["Dilapidated Dungeon - Rafters"] = function(state)
            return self:kick_or_plunge(state, 2)
            or self:can_bounce(state) and self:get_kicks(state, 1)
            or self:has_slide(state) and self:kick_or_plunge(state, 1)
        end,
        ["Dilapidated Dungeon - Strong Eyes"] = function(state)
            return self:has_gem(state)
            or self:has_slide(state) and self:get_kicks(state, 1)
        end,
        ["Castle Sansa - Floater In Courtyard"] = function(state)
            return self:can_bounce(state)
            and (
                self:kick_or_plunge(state, 1)
                or self:has_slide(state))
            or self:has_slide(state) and self:get_kicks(state, 1)
            or self:get_kicks(state, 3)
            or self:has_gem(state)
        end,
        ["Castle Sansa - Platform In Main Halls"] = function(state)
            return self:has_slide(state)
        end,
        ["Castle Sansa - Tall Room Near Wheel Crawlers"] = function(state)
            return self:has_slide(state)
        end,
        ["Castle Sansa - Alcove Near Dungeon"] = function(state)
            return self:kick_or_plunge(state, 1)
            or self:has_slide(state)
        end,
        ["Castle Sansa - Balcony"] = function(state)
            return self:get_kicks(state, 3)
            or self:has_plunge(state) and self:get_kicks(state, 1)
            or self:has_slide(state)
        end,
        ["Castle Sansa - Corner Corridor"] = function(state)
            return self:get_kicks(state, 2) and self:has_slide(state)
        end,
        ["Castle Sansa - Wheel Crawlers"] = function(state)
            return self:kick_or_plunge(state, 1)
            or self:has_slide(state)
        end,
        ["Castle Sansa - Alcove Near Scythe Corridor"] = function(state)
            return self:kick_or_plunge(state, 3)
            or self:has_slide(state) and self:kick_or_plunge(state, 1)
        end,
        ["Castle Sansa - Near Theatre Front"] = function(state)
            return self:has_slide(state)
        end,
        ["Castle Sansa - High Climb From Courtyard"] = function(state)
            return self:can_attack(state) and self:get_kicks(state, 1)
            or self:has_slide(state)
        end,
        ["Listless Library - Upper Back"] = function(state)
            return self:can_attack(state) and self:has_slide(state)
        end,
        ["Listless Library - Locked Door Across"] = function(state)
            return self:has_slide(state)
        end,
        ["Listless Library - Locked Door Left"] = function(state)
            return self:kick_or_plunge(state, 2)
            or self:has_slide(state) and self:kick_or_plunge(state, 1)
        end,
        ["Sansa Keep - Strikebreak"] = function(state)
            return self:has_breaker(state) and self:has_slide(state)
            or self:can_strikebreak(state) and self:has_plunge(state)
        end,
        ["Sansa Keep - Lonely Throne"] = function(state)
            return self:has_breaker(state)
            and (
                self:has_gem(state)
                or self:can_bounce(state) and self:kick_or_plunge(state, 3)
                or self:has_slide(state) and self:get_kicks(state, 3))
        end,
        ["Sansa Keep - Near Theatre"] = function(state)
            return self:has_slide(state)
        end,
        ["The Underbelly - Rafters Near Keep"] = function(state)
            return self:has_slide(state)
        end,
        ["The Underbelly - Main Room"] = function(state)
            return self:has_slide(state) or self:get_kicks(state, 1)
        end,
        ["The Underbelly - Alcove Near Light"] = function(state)
            return self:get_kicks(state, 1) and self:has_slide(state)
        end,
        ["The Underbelly - Building Near Little Guy"] = function(state)
            return self:get_kicks(state, 1)
            or self:has_slide(state)
        end,
        ["The Underbelly - Strikebreak Wall"] = function(state)
            return self:can_strikebreak(state)
            and (
                self:has_slide(state) and self:kick_or_plunge(state, 1)
                or self:has_slide(state) and self:has_gem(state))
        end,
        ["The Underbelly - Surrounded By Holes"] = function(state)
            return self:can_soulcutter(state) and self:has_slide(state)
            or self:has_slide(state) and self:get_kicks(state, 1)
        end,
    }

    self:apply_clauses(region_clauses, location_clauses)

    return self
end

return PseudoregaliaExpertRules -- prepare for require()
