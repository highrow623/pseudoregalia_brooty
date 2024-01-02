-- TODO: require base

PseudoregaliaNormalRules = PseudoregaliaRulesHelpers:new(nil)

function PseudoregaliaNormalRules.new(cls, definition)
    local self = PseudoregaliaRulesHelpers.new(cls, definition)

    for k, v in pairs({
        ["Dungeon Mirror -> Dungeon Slide"] = function(state)
            return self:can_attack(state)
        end,
        ["Dungeon Slide -> Dungeon Mirror"] = function(state)
            return self:can_attack(state)
        end,
        ["Dungeon Slide -> Dungeon Strong Eyes"] = function(state)
            return self:has_slide(state)
        end,
        ["Dungeon Slide -> Dungeon Escape Lower"] = function(state)
            return self:can_attack(state) and self:navigate_darkrooms(state)
        end,
        ["Dungeon Strong Eyes -> Dungeon Slide"] = function(state)
            return self:has_slide(state)
        end,
        ["Dungeon Strong Eyes -> Dungeon => Castle"] = function(state)
            return self:has_small_keys(state)
        end,
        ["Dungeon => Castle -> Dungeon Strong Eyes"] = function(state)
            return self:has_small_keys(state)
        end,
        ["Dungeon Escape Lower -> Dungeon Slide"] = function(state)
            return self:can_attack(state)
        end,
        ["Dungeon Escape Lower -> Dungeon Escape Upper"] = function(state)
            return (self:can_bounce(state)
                or self:get_kicks(state, 1) and self:has_plunge(state)
                or self:get_kicks(state, 3))
        end,
        ["Dungeon Escape Upper -> Theatre Outside Scythe Corridor"] = function(state)
            return (self:can_bounce(state)
                or self:kick_or_plunge(state, 1)
                or self:has_gem(state))
        end,
        ["Castle Main -> Library Main"] = function(state)
            return self:has_breaker(state) or self:knows_obscure(state) and self:can_attack(state)
        end,
        ["Castle Main -> Theatre Pillar"] = function(state)
            return self:has_gem(state) and self:kick_or_plunge(state, 1) or self:kick_or_plunge(state, 2)
        end,
        ["Castle Main -> Castle Spiral Climb"] = function(state)
            return self:get_kicks(state, 2) or self:has_gem(state) and self:has_plunge(state)
        end,
        ["Castle Spiral Climb -> Castle High Climb"] = function(state)
            return (self:has_gem(state)
                or self:get_kicks(state, 3) and self:has_plunge(state)
                or self:has_breaker(state) and self:get_kicks(state, 1)
                or self:knows_obscure(state) and self:has_plunge(state) and self:get_kicks(state, 1))
        end,
        ["Castle Spiral Climb -> Castle By Scythe Corridor"] = function(state)
            return self:has_gem(state)
        end,
        ["Castle By Scythe Corridor -> Castle Spiral Climb"] = function(state)
            return self:has_gem(state) or self:get_kicks(state, 4) and self:has_plunge(state)
        end,
        ["Castle By Scythe Corridor -> Castle High Climb"] = function(state)
            return (self:has_gem(state)
                or self:get_kicks(state, 4)
                or self:get_kicks(state, 2) and self:has_plunge(state)
                or self:get_kicks(state, 1) and self:has_plunge(state) and self:can_slidejump(state))
        end,
        ["Castle By Scythe Corridor -> Castle => Theatre (Front)"] = function(state)
            return self:has_gem(state) and self:kick_or_plunge(state, 2)
        end,
        ["Castle => Theatre (Front) -> Castle By Scythe Corridor"] = function(state)
            return (self:has_gem(state)
                or self:can_slidejump(state) and self:get_kicks(state, 1)
                or self:get_kicks(state, 4))
        end,
        ["Castle => Theatre (Front) -> Castle Moon Room"] = function(state)
            return self:has_gem(state) or self:can_slidejump(state) and self:kick_or_plunge(state, 1)
        end,
        ["Library Main -> Library Locked"] = function(state)
            return self:has_small_keys(state)
        end,
        ["Library Main -> Library Greaves"] = function(state)
            return self:has_slide(state)
        end,
        ["Library Main -> Library Top"] = function(state)
            return (self:kick_or_plunge(state, 4)
                or self:knows_obscure(state) and self:get_kicks(state, 1) and self:has_plunge(state))
        end,
        ["Library Greaves -> Library Top"] = function(state)
            return self:has_gem(state) or self:get_kicks(state, 2)
        end,
        ["Library Top -> Library Greaves"] = function(state)
            return (self:has_gem(state) and self:kick_or_plunge(state, 1)
                or self:get_kicks(state, 3) and self:has_plunge(state)
                or self:get_kicks(state, 3) and self:can_bounce(state))
        end,
        ["Keep Main -> Keep Locked Room"] = function(state)
            return (self:has_small_keys(state)
                or self:get_kicks(state, 3)
                or self:has_plunge(state) and self:get_kicks(state, 1)
                or self:has_gem(state) and self:has_plunge(state)
                or self:has_gem(state) and self:get_kicks(state, 1))
        end,
        ["Keep Main -> Keep Sunsetter"] = function(state)
            return self:has_gem(state)
        end,
        ["Keep Main -> Keep => Underbelly"] = function(state)
            return self:kick_or_plunge(state, 1) or self:has_gem(state)
        end,
        ["Keep Main -> Theatre Outside Scythe Corridor"] = function(state)
            return (self:has_gem(state)
                or self:get_kicks(state, 1)
                or self:can_bounce(state)
                or self:can_slidejump(state))
        end,
        ["Keep Main -> Keep Path To Throne"] = function(state)
            return self:has_breaker(state)
        end,
        ["Underbelly => Dungeon -> Underbelly Ascendant Light"] = function(state)
            return (self:can_bounce(state)
                or self:has_gem(state)
                or self:get_kicks(state, 2)
                or self:get_kicks(state, 1) and self:can_slidejump(state)
                or self:knows_obscure(state) and self:has_breaker(state))
        end,
        ["Underbelly Light Pillar -> Underbelly => Dungeon"] = function(state)
            return self:can_bounce(state) or self:kick_or_plunge(state, 4)
        end,
        ["Underbelly Light Pillar -> Underbelly Ascendant Light"] = function(state)
            return self:has_breaker(state) and (
                self:has_plunge(state) or self:get_kicks(state, 4)
            ) or self:knows_obscure(state) and self:has_gem(state) and self:get_kicks(state, 1)
        end,
        ["Underbelly Ascendant Light -> Underbelly => Dungeon"] = function(state)
            return (self:can_bounce(state)
                or self:has_gem(state)
                or self:get_kicks(state, 2)
                or self:get_kicks(state, 1) and self:can_slidejump(state))
        end,
        ["Underbelly Main Lower -> Underbelly Hole"] = function(state)
            return self:has_plunge(state) and (
                self:get_kicks(state, 1) or self:can_slidejump(state) or self:can_attack(state)
            )
        end,
        ["Underbelly Main Lower -> Underbelly By Heliacal"] = function(state)
            return self:has_slide(state) and self:has_plunge(state)
        end,
        ["Underbelly Main Lower -> Underbelly Main Upper"] = function(state)
            return self:has_plunge(state) and (
                self:get_kicks(state, 2)
                or self:get_kicks(state, 1) and self:has_gem(state)
            )
        end,
        ["Underbelly Main Upper -> Underbelly Light Pillar"] = function(state)
            return (self:has_breaker(state) and self:has_plunge(state)
                or self:has_breaker(state) and self:get_kicks(state, 2)
                or self:has_gem(state) and (
                    self:get_kicks(state, 2) and self:has_plunge(state)
                    or self:get_kicks(state, 4)
                ))
        end,
        ["Underbelly Main Upper -> Underbelly By Heliacal"] = function(state)
            return self:has_breaker(state) and (
                state:has("Ascendant Light")
                or self:can_slidejump(state) and self:get_kicks(state, 3)
                or self:has_gem(state) and self:get_kicks(state, 2))
        end,
        ["Underbelly By Heliacal -> Underbelly Main Upper"] = function(state)
            return self:has_breaker(state) or self:knows_obscure(state) and (
                self:get_kicks(state, 1)
                or self:has_gem(state) and self:can_slidejump(state))
        end,
        ["Underbelly Little Guy -> Underbelly Main Lower"] = function(state)
            return self:has_gem(state) or self:kick_or_plunge(state, 1)
        end,
        ["Underbelly => Keep -> Underbelly Hole"] = function(state)
            return self:has_plunge(state)
        end,
        ["Underbelly Hole -> Underbelly Main Lower"] = function(state)
            return (self:get_kicks(state, 2)
                or self:has_gem(state) and self:can_slidejump(state)
                or self:can_attack(state))
        end,
        ["Underbelly Hole -> Underbelly => Keep"] = function(state)
            return self:has_slide(state)
        end,
    }) do
        self.region_rules[k] = v
    end

    for k, v in pairs({
        ["Dilapidated Dungeon - Dark Orbs"] = function(state)
            return (self:has_gem(state) and self:can_bounce(state)
                or self:has_gem(state) and self:kick_or_plunge(state, 3)
                or self:get_kicks(state, 2) and self:can_bounce(state)
                or self:can_slidejump(state) and self:get_kicks(state, 1) and self:can_bounce(state))
        end,
        ["Dilapidated Dungeon - Past Poles"] = function(state)
            return (self:has_gem(state) and self:kick_or_plunge(state, 1)
                or self:get_kicks(state, 3))
        end,
        ["Dilapidated Dungeon - Rafters"] = function(state)
            return (self:kick_or_plunge(state, 3)
                or self:knows_obscure(state) and self:can_bounce(state) and self:has_gem(state))
        end,
        ["Dilapidated Dungeon - Strong Eyes"] = function(state)
            return (self:has_breaker(state)
                or self:knows_obscure(state) and (
                    self:has_gem(state) and self:get_kicks(state, 1) and self:has_plunge(state)
                    or self:has_gem(state) and self:get_kicks(state, 3)))
        end,
        ["Castle Sansa - Alcove Near Dungeon"] = function(state)
            return (self:has_gem(state) and self:kick_or_plunge(state, 1)
                or self:kick_or_plunge(state, 2))
        end,
        ["Castle Sansa - Balcony"] = function(state)
            return (self:has_gem(state)
                or self:kick_or_plunge(state, 3)
                or self:can_slidejump(state) and self:kick_or_plunge(state, 2))
        end,
        ["Castle Sansa - Corner Corridor"] = function(state)
            return (self:has_gem(state)
                or self:get_kicks(state, 4))
        end,
        ["Castle Sansa - Floater In Courtyard"] = function(state)
            return (self:can_bounce(state) and self:has_plunge(state)
                or self:can_bounce(state) and self:get_kicks(state, 2)
                or self:has_gem(state) and self:get_kicks(state, 2)
                or self:has_gem(state) and self:has_plunge(state)
                or self:get_kicks(state, 4)
                or self:knows_obscure(state) and self:can_bounce(state) and self:get_kicks(state, 1)
                or self:knows_obscure(state) and self:has_gem(state) and self:get_kicks(state, 1))
        end,
        ["Castle Sansa - Locked Door"] = function(state)
            return self:has_small_keys(state)
        end,
        ["Castle Sansa - Platform In Main Halls"] = function(state)
            return (self:has_plunge(state)
                or self:has_gem(state)
                or self:get_kicks(state, 2))
        end,
        ["Castle Sansa - Tall Room Near Wheel Crawlers"] = function(state)
            return (self:has_gem(state) and self:kick_or_plunge(state, 1)
                or self:get_kicks(state, 2))
        end,
        ["Castle Sansa - Wheel Crawlers"] = function(state)
            return (self:can_bounce(state)
                or self:has_gem(state)
                or self:get_kicks(state, 2)
                or self:get_kicks(state, 1) and self:can_slidejump(state)
                or self:knows_obscure(state) and self:has_plunge(state))
        end,
        ["Castle Sansa - High Climb From Courtyard"] = function(state)
            return (self:get_kicks(state, 2)
                or self:has_gem(state) and self:has_plunge(state)
                or self:has_breaker(state) and self:get_kicks(state, 1)
                or self:knows_obscure(state) and self:has_plunge(state) and self:get_kicks(state, 1))
        end,
        ["Castle Sansa - Alcove Near Scythe Corridor"] = function(state)
            return (self:has_gem(state) and self:get_kicks(state, 1) and self:has_plunge(state)
                or self:kick_or_plunge(state, 4))
        end,
        ["Castle Sansa - Near Theatre Front"] = function(state)
            return (self:get_kicks(state, 4)
                or self:get_kicks(state, 2) and self:has_plunge(state))
        end,
        ["Listless Library - Sun Greaves"] = function(state)
            return (self:has_breaker(state)
                or self:knows_obscure(state) and self:has_plunge(state))
        end,
        ["Listless Library - Sun Greaves 1"] = function(state)
            return (self:has_breaker(state)
                or self:knows_obscure(state) and self:has_plunge(state))
        end,
        ["Listless Library - Sun Greaves 2"] = function(state)
            return (self:has_breaker(state)
                or self:knows_obscure(state) and self:has_plunge(state))
        end,
        ["Listless Library - Sun Greaves 3"] = function(state)
            return (self:has_breaker(state)
                or self:knows_obscure(state) and self:has_plunge(state))
        end,
        ["Listless Library - Upper Back"] = function(state)
            return ((self:has_breaker(state) or self:knows_obscure(state) and self:has_plunge(state))
                and (
                    self:has_gem(state) and self:kick_or_plunge(state, 1)
                    or self:kick_or_plunge(state, 2)))
        end,
        ["Listless Library - Locked Door Across"] = function(state)
            return (self:has_gem(state)
                or self:get_kicks(state, 1)
                or self:can_slidejump(state))
        end,
        ["Listless Library - Locked Door Left"] = function(state)
            return (self:has_gem(state)
                or self:can_slidejump(state) and self:get_kicks(state, 1)
                or self:kick_or_plunge(state, 3))
        end,
        ["Sansa Keep - Near Theatre"] = function(state)
            return (self:kick_or_plunge(state, 1)
                or self:has_gem(state))
        end,
        ["Sansa Keep - Levers Room"] = function(state)
            return self:can_attack(state)
        end,
        ["Sansa Keep - Sunsetter"] = function(state)
            return self:can_attack(state)
        end,
        ["Sansa Keep - Strikebreak"] = function(state)
            return ((self:can_attack(state) and (self:has_slide(state) or self:can_strikebreak(state)))
                and (
                    self:has_gem(state)
                    or self:has_plunge(state) and self:get_kicks(state, 1)
                    or self:get_kicks(state, 3)))
        end,
        ["Sansa Keep - Lonely Throne"] = function(state)
            return ((self:has_gem(state) and (
                self:has_plunge(state) and self:get_kicks(state, 1)
                or self:has_plunge(state) and state:has("Ascendant Light")
                or self:get_kicks(state, 1) and state:has("Ascendant Light"))
                ) or (state:has("Ascendant Light") and self:kick_or_plunge(state, 4)))
        end,
        ["The Underbelly - Rafters Near Keep"] = function(state)
            return (self:has_plunge(state)
                or self:get_kicks(state, 2)
                or self:can_bounce(state))
        end,
        ["The Underbelly - Locked Door"] = function(state)
            return self:has_small_keys(state)
        end,
        ["The Underbelly - Main Room"] = function(state)
            return (self:has_plunge(state)
                or self:has_gem(state)
                or self:get_kicks(state, 2)
                or self:can_slidejump(state) and self:get_kicks(state, 1))
        end,
        ["The Underbelly - Alcove Near Light"] = function(state)
            return (self:can_attack(state)
                or self:has_gem(state)
                or self:get_kicks(state, 4)
                or self:get_kicks(state, 3) and self:can_slidejump(state))
        end,
        ["The Underbelly - Building Near Little Guy"] = function(state)
            return self:has_plunge(state) or self:get_kicks(state, 3)
        end,
        ["The Underbelly - Strikebreak Wall"] = function(state)
            return self:can_strikebreak(state) and (
                self:can_bounce(state)
                or self:get_kicks(state, 4)
                or self:get_kicks(state, 2) and self:has_plunge(state))
        end,
        ["The Underbelly - Surrounded By Holes"] = function(state)
            return self:can_soulcutter(state) and (
                self:can_bounce(state) or self:get_kicks(state, 2)
            ) or self:can_slidejump(state) and self:has_gem(state) and self:get_kicks(state, 1)
        end,
    }) do
        self.location_rules[k] = v
    end

    return self
end

return PseudoregaliaNormalRules -- prepare for require()
