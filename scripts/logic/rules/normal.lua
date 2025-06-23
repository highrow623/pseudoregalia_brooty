-- TODO: require base

PseudoregaliaNormalRules = PseudoregaliaRulesHelpers:new(nil)

function PseudoregaliaNormalRules.new(cls, definition)
    local self = PseudoregaliaRulesHelpers.new(cls, definition)

    local region_clauses = {
        ["Bailey Lower -> Bailey Upper"] = function(state)
            return self:has_slide(state) and self:can_attack(state)
            or self:get_kicks(state, 2)
            or self:get_kicks(state, 1) and self:knows_obscure(state)
        end,
        ["Bailey Upper -> Tower Remains"] = function(state)
            return self:kick_or_plunge(state, 4)
            and (
                self:can_slidejump(state)
                or self:has_plunge(state) and self:knows_obscure(state))
        end,
        ["Bailey Upper -> Underbelly => Bailey"] = function(state)
            return self:has_plunge(state)
        end,
        ["Tower Remains -> The Great Door"] = function(state)
            return self:can_attack(state) and self:has_gem(state) and self:kick_or_plunge(state, 1)
        end,
        ["Theatre Main -> Theatre Pillar"] = function (state)
            return self:get_kicks(state, 2)
            or self:get_kicks(state, 1) and self:has_plunge(state) and self:knows_obscure(state)
            or self:has_gem(state)
        end,
        ["Theatre Pillar => Bailey -> Theatre Pillar"] = function (state)
            return self:has_plunge(state) and self:knows_obscure(state)
            or self:get_kicks(state, 1) and self:can_bounce(state)
        end,
        ["Castle => Theatre Pillar -> Theatre Pillar"] = function (state)
            return self:has_plunge(state)
        end,
        ["Theatre Pillar -> Theatre Main"] = function (state)
            return self:has_gem(state)
            or self:has_plunge(state) and self:get_kicks(state, 3)
        end,
        ["Theatre Outside Scythe Corridor -> Theatre Main"] = function (state)
            return self:has_gem(state) and self:kick_or_plunge(state, 3)
            or self:has_gem(state) and self:can_slidejump(state)
        end,
        ["Theatre Outside Scythe Corridor -> Dungeon Escape Upper"] = function (state)
            return self:navigate_darkrooms(state)
            and (
                self:can_bounce(state)
                or self:get_kicks(state, 1)
                or self:has_gem(state)
                or self:can_slidejump(state)
                or self:knows_obscure(state) and self:has_plunge(state))
        end,
        ["Theatre Outside Scythe Corridor -> Keep Main"] = function (state)
            return self:has_gem(state)
            or self:get_kicks(state, 1)
            or self:can_bounce(state)
            or self:can_slidejump(state)
            or self:knows_obscure(state) and self:has_plunge(state)
        end,
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
            return self:knows_obscure(state) and self:can_attack(state) and self:navigate_darkrooms(state)
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
            return self:can_bounce(state)
            or self:get_kicks(state, 1) and self:has_plunge(state)
            or self:get_kicks(state, 3)
        end,
        ["Dungeon Escape Upper -> Theatre Outside Scythe Corridor"] = function(state)
            return self:can_bounce(state)
            or self:get_kicks(state, 1)
            or self:has_gem(state)
            or self:knows_obscure(state) and self:has_plunge(state)
        end,
        ["Castle Main -> Library Main"] = function(state)
            return self:can_attack(state)
        end,
        ["Castle Main -> Castle => Theatre Pillar"] = function(state)
            return self:has_gem(state) and self:kick_or_plunge(state, 1)
            or self:kick_or_plunge(state, 2)
        end,
        ["Castle Main -> Castle Spiral Climb"] = function(state)
            return self:get_kicks(state, 2)
            or self:has_gem(state) and self:has_plunge(state)
        end,
        ["Castle Spiral Climb -> Castle High Climb"] = function(state)
            return self:has_gem(state)
            or self:get_kicks(state, 3) and self:has_plunge(state)
            or self:can_attack(state) and self:get_kicks(state, 1)
        end,
        ["Castle Spiral Climb -> Castle By Scythe Corridor"] = function(state)
            return self:has_gem(state)
        end,
        ["Castle By Scythe Corridor -> Castle Spiral Climb"] = function(state)
            return self:has_gem(state)
            or self:get_kicks(state, 4) and self:has_plunge(state)
        end,
        ["Castle By Scythe Corridor -> Castle High Climb"] = function(state)
            return self:has_gem(state)
            or self:get_kicks(state, 4)
            or self:get_kicks(state, 2) and self:has_plunge(state)
            or self:get_kicks(state, 1) and self:has_plunge(state) and self:can_slidejump(state)
        end,
        ["Castle By Scythe Corridor -> Castle => Theatre (Front)"] = function(state)
            return self:has_gem(state) and self:kick_or_plunge(state, 2)
        end,
        ["Castle => Theatre (Front) -> Castle By Scythe Corridor"] = function(state)
            return self:has_gem(state)
            or self:can_slidejump(state) and self:get_kicks(state, 1)
            or self:get_kicks(state, 4)
        end,
        ["Castle => Theatre (Front) -> Castle Moon Room"] = function(state)
            return self:has_gem(state)
            or self:can_slidejump(state) and self:kick_or_plunge(state, 2)
        end,
        ["Castle => Theatre (Front) -> Theatre Main"] = function (state)
            return self:has_plunge(state) and self:get_kicks(state, 1)
            or self:get_kicks(state, 2)
        end,
        ["Library Main -> Library Locked"] = function(state)
            return self:has_small_keys(state)
        end,
        ["Library Main -> Library Greaves"] = function(state)
            return self:has_slide(state)
        end,
        ["Library Main -> Library Top"] = function(state)
            return self:kick_or_plunge(state, 4)
            or self:knows_obscure(state) and self:get_kicks(state, 1) and self:has_plunge(state)
        end,
        ["Library Greaves -> Library Top"] = function(state)
            return self:has_gem(state)
            or self:get_kicks(state, 2)
        end,
        ["Library Top -> Library Greaves"] = function(state)
            return self:has_gem(state) and self:kick_or_plunge(state, 1)
            or self:get_kicks(state, 3) and self:has_plunge(state)
            or self:get_kicks(state, 3) and self:can_bounce(state)
        end,
        ["Keep Main -> Keep Locked Room"] = function(state)
            return self:has_small_keys(state)
            or self:get_kicks(state, 3)
            or self:has_plunge(state) and self:get_kicks(state, 1)
            or self:has_gem(state) and self:has_plunge(state)
            or self:has_gem(state) and self:get_kicks(state, 1)
        end,
        ["Keep Main -> Keep Sunsetter"] = function(state)
            return self:has_gem(state)
        end,
        ["Keep Main -> Keep Throne Room"] = function(state)
            return self:has_breaker(state) and self:has_gem(state)
            and (
                self:has_plunge(state) and self:get_kicks(state, 1)
                or self:has_plunge(state) and self:can_bounce(state)
                or self:get_kicks(state, 1) and self:can_bounce(state))
            or self:can_bounce(state) and self:kick_or_plunge(state, 4)
        end,
        ["Keep Main -> Keep => Underbelly"] = function(state)
            return self:kick_or_plunge(state, 1)
            or self:has_gem(state)
        end,
        ["Keep Main -> Theatre Outside Scythe Corridor"] = function(state)
            return self:has_gem(state)
            or self:get_kicks(state, 1)
            or self:can_bounce(state)
            or self:can_slidejump(state)
            or self:knows_obscure(state) and self:has_plunge(state)
        end,
        ["Underbelly => Dungeon -> Dungeon Escape Lower"] = function(state)
            return self:navigate_darkrooms(state)
        end,
        ["Underbelly => Dungeon -> Underbelly Ascendant Light"] = function(state)
            return self:can_bounce(state)
            or self:has_gem(state)
            or self:get_kicks(state, 2)
            or self:get_kicks(state, 1) and self:can_slidejump(state)
            or self:knows_obscure(state) and self:can_attack(state)
        end,
        ["Underbelly Light Pillar -> Underbelly => Dungeon"] = function(state)
            return self:can_bounce(state)
            or self:kick_or_plunge(state, 4)
        end,
        ["Underbelly Light Pillar -> Underbelly Ascendant Light"] = function(state)
            return self:has_breaker(state)
            and (
                self:has_plunge(state)
                or self:knows_obscure(state) and self:get_kicks(state, 3))
        end,
        ["Underbelly Ascendant Light -> Underbelly => Dungeon"] = function(state)
            return self:can_bounce(state)
            or self:has_gem(state)
            or self:get_kicks(state, 2)
            or self:get_kicks(state, 1) and self:can_slidejump(state)
        end,
        ["Underbelly Main Lower -> Underbelly Hole"] = function(state)
            return self:has_plunge(state)
            and (
                self:get_kicks(state, 1)
                or self:can_slidejump(state)
                or self:can_attack(state))
        end,
        ["Underbelly Main Lower -> Underbelly By Heliacal"] = function(state)
            return self:has_slide(state) and self:has_plunge(state)
        end,
        ["Underbelly Main Lower -> Underbelly Main Upper"] = function(state)
            return self:knows_obscure(state) and self:has_plunge(state) and self:get_kicks(state, 2)
        end,
        ["Underbelly Main Upper -> Underbelly Light Pillar"] = function(state)
            return self:has_breaker(state) and self:has_plunge(state)
            or self:knows_obscure(state) and self:has_breaker(state)
            and (
                self:get_kicks(state, 2)
                or self:has_gem(state) and self:get_kicks(state, 1))
        end,
        ["Underbelly Main Upper -> Underbelly By Heliacal"] = function(state)
            return self:has_breaker(state)
            and (
                state:has("Ascendant Light") and self:get_kicks(state, 1)
                or self:can_slidejump(state) and self:get_kicks(state, 3)
                or self:has_gem(state) and self:get_kicks(state, 2))
        end,
        ["Underbelly By Heliacal -> Underbelly Main Upper"] = function(state)
            return self:has_breaker(state) and self:has_plunge(state)
            or self:knows_obscure(state) and self:has_plunge(state)
            and (
                self:get_kicks(state, 1)
                or self:has_gem(state))
        end,
        ["Underbelly => Bailey -> Bailey Upper"] = function (state)
            return self:knows_obscure(state)
            or self:has_plunge(state) and self:get_kicks(state, 1)
        end,
        ["Underbelly => Bailey -> Underbelly Main Lower"] = function(state)
            return self:has_plunge(state)
            or self:get_kicks(state, 2)
            or self:knows_obscure(state)
        end,
        ["Underbelly => Keep -> Underbelly Hole"] = function(state)
            return self:has_plunge(state)
        end,
        ["Underbelly Hole -> Underbelly Main Lower"] = function(state)
            return self:has_plunge(state)
            and (
                self:can_attack(state)
                or self:can_slidejump(state) and self:has_gem(state)
                or self:can_slidejump(state) and self:get_kicks(state, 1))
        end,
        ["Underbelly Hole -> Underbelly => Keep"] = function(state)
            return self:has_plunge(state) and self:has_slide(state)
        end,
    }

    local location_clauses = {
        ["Empty Bailey - Solar Wind"] = function (state)
            return self:has_slide(state)
        end,
        ["Empty Bailey - Cheese Bell"] = function (state)
            return self:get_kicks(state, 3)
            or self:has_gem(state) and self:kick_or_plunge(state, 2)
        end,
        ["Empty Bailey - Inside Building"] = function (state)
            return self:has_slide(state)
        end,
        ["Empty Bailey - Center Steeple"] = function (state)
            return self:has_plunge(state)
        end,
        ["Empty Bailey - Guarded Hand"] = function (state)
            return self.definition:get_region("Bailey Upper"):can_reach(state)
            and (
                self:knows_obscure(state)
                or self:has_gem(state)
                or self:get_kicks(state, 3))
            or self:has_breaker(state)
            and (
                self:has_plunge(state)
                or self:get_kicks(state, 2))
        end,
        ["Twilight Theatre - Soul Cutter"] = function (state)
            return self:can_strikebreak(state)
            and (
                self:can_bounce(state)
                or self:kick_or_plunge(state, 1)
                or self:has_gem(state))
        end,
        ["Twilight Theatre - Corner Beam"] = function (state)
            return self:has_gem(state)
            and (
                self:has_plunge(state)
                or self:get_kicks(state, 2))
            or self:has_plunge(state) and self:get_kicks(state, 3) and self:knows_obscure(state)
            or self:get_kicks(state, 4)
        end,
        ["Twilight Theatre - Locked Door"] = function (state)
            return self:has_small_keys(state)
            and (
                self:can_bounce(state)
                or self:get_kicks(state, 1))
        end,
        ["Twilight Theatre - Back Of Auditorium"] = function (state)
            return self:has_plunge(state) and self:knows_obscure(state)
            or self:get_kicks(state, 1)
            or self:has_gem(state)
        end,
        ["Twilight Theatre - Center Stage"] = function (state)
            return self:can_soulcutter(state) and self:has_gem(state)
            and self:has_plunge(state) and self:can_slidejump(state)
        end,
        ["Tower Remains - Cling Gem"] = function (state)
            return self:kick_or_plunge(state, 2)
        end,
        ["Dilapidated Dungeon - Dark Orbs"] = function(state)
            return self:has_gem(state) and self:can_bounce(state)
            or self:has_gem(state) and self:kick_or_plunge(state, 3)
            or self:get_kicks(state, 2) and self:can_bounce(state)
            or self:can_slidejump(state) and self:get_kicks(state, 1) and self:can_bounce(state)
        end,
        ["Dilapidated Dungeon - Past Poles"] = function(state)
            return self:has_gem(state) and self:kick_or_plunge(state, 1)
            or self:get_kicks(state, 3)
        end,
        ["Dilapidated Dungeon - Rafters"] = function(state)
            return self:kick_or_plunge(state, 3)
            or self:knows_obscure(state) and self:can_bounce(state) and self:has_gem(state)
        end,
        ["Dilapidated Dungeon - Strong Eyes"] = function(state)
            return self:has_breaker(state)
            or self:knows_obscure(state)
            and (
                self:has_gem(state) and self:get_kicks(state, 1) and self:has_plunge(state)
                or self:has_gem(state) and self:get_kicks(state, 3))
        end,
        ["Castle Sansa - Alcove Near Dungeon"] = function(state)
            return self:has_gem(state)
            or self:get_kicks(state, 1)
            or self:can_slidejump(state)
            or self:knows_obscure(state) and self:has_plunge(state)
        end,
        ["Castle Sansa - Balcony"] = function(state)
            return self:has_gem(state)
            or self:kick_or_plunge(state, 3)
               or self:can_slidejump(state) and self:kick_or_plunge(state, 2)
        end,
        ["Castle Sansa - Corner Corridor"] = function(state)
            return self:has_gem(state)
            or self:get_kicks(state, 4)
        end,
        ["Castle Sansa - Floater In Courtyard"] = function(state)
            return self:can_bounce(state) and self:has_plunge(state)
            or self:can_bounce(state) and self:get_kicks(state, 2)
            or self:has_gem(state) and self:get_kicks(state, 2)
            or self:has_gem(state) and self:has_plunge(state)
            or self:get_kicks(state, 4)
            or self:knows_obscure(state) and self:can_bounce(state) and self:get_kicks(state, 1)
            or self:knows_obscure(state) and self:has_gem(state) and self:get_kicks(state, 1)
        end,
        ["Castle Sansa - Locked Door"] = function(state)
            return self:has_small_keys(state)
        end,
        ["Castle Sansa - Platform In Main Halls"] = function(state)
            return self:has_plunge(state)
            or self:has_gem(state)
            or self:get_kicks(state, 2)
        end,
        ["Castle Sansa - Tall Room Near Wheel Crawlers"] = function(state)
            return self:has_gem(state) and self:kick_or_plunge(state, 1)
            or self:get_kicks(state, 2)
        end,
        ["Castle Sansa - Wheel Crawlers"] = function(state)
            return self:can_bounce(state)
            or self:has_gem(state)
            or self:get_kicks(state, 2)
            or self:get_kicks(state, 1) and self:can_slidejump(state)
            or self:knows_obscure(state) and self:has_plunge(state)
        end,
        ["Castle Sansa - High Climb From Courtyard"] = function(state)
            return self:get_kicks(state, 2)
            or self:has_gem(state) and self:has_plunge(state)
            or self:can_attack(state) and self:get_kicks(state, 1)
        end,
        ["Castle Sansa - Alcove Near Scythe Corridor"] = function(state)
            return self:has_gem(state) and self:get_kicks(state, 1) and self:has_plunge(state)
            or self:kick_or_plunge(state, 4)
        end,
        ["Castle Sansa - Near Theatre Front"] = function(state)
            return self:get_kicks(state, 4)
            or self:get_kicks(state, 2) and self:has_plunge(state)
        end,
        ["Listless Library - Sun Greaves"] = function(state)
            return self:can_attack(state)
        end,
        ["Listless Library - Sun Greaves 1"] = function(state)
            return self:can_attack(state)
        end,
        ["Listless Library - Sun Greaves 2"] = function(state)
            return self:can_attack(state)
        end,
        ["Listless Library - Sun Greaves 3"] = function(state)
            return self:can_attack(state)
        end,
        ["Listless Library - Upper Back"] = function(state)
            return self:can_attack(state)
            and (
                self:has_gem(state) and self:kick_or_plunge(state, 1)
                or self:kick_or_plunge(state, 2))
        end,
        ["Listless Library - Locked Door Across"] = function(state)
            return self:has_gem(state)
            or self:get_kicks(state, 1)
            or self:can_slidejump(state)
        end,
        ["Listless Library - Locked Door Left"] = function(state)
            return self:has_gem(state)
            or self:can_slidejump(state) and self:get_kicks(state, 1)
            or self:kick_or_plunge(state, 3)
        end,
        ["Sansa Keep - Near Theatre"] = function(state)
            return self:kick_or_plunge(state, 1)
            or self:has_gem(state)
        end,
        ["Sansa Keep - Levers Room"] = function(state)
            return self:can_attack(state)
        end,
        ["Sansa Keep - Sunsetter"] = function(state)
            return self:can_attack(state)
        end,
        ["Sansa Keep - Strikebreak"] = function(state)
            return self:has_breaker(state)
            and (
                self:has_slide(state)
                or self:can_strikebreak(state))
            and (
                self:has_gem(state)
                or self:has_plunge(state) and self:get_kicks(state, 1)
                or self:get_kicks(state, 3))
        end,
        ["The Underbelly - Rafters Near Keep"] = function(state)
            return self:has_plunge(state)
            or self:get_kicks(state, 2)
            or self:can_bounce(state)
        end,
        ["The Underbelly - Locked Door"] = function(state)
            return self:has_small_keys(state)
        end,
        ["The Underbelly - Main Room"] = function(state)
            return self:has_plunge(state)
            or self:can_slidejump(state) and self:get_kicks(state, 1)
            or self:knows_obscure(state)
            and (
                self:has_gem(state)
                or self:get_kicks(state, 2))
        end,
        ["The Underbelly - Alcove Near Light"] = function(state)
            return self:can_attack(state)
            or self:has_gem(state)
            or self:get_kicks(state, 4)
            or self:get_kicks(state, 3) and self:can_slidejump(state)
        end,
        ["The Underbelly - Building Near Little Guy"] = function(state)
            return self:has_plunge(state)
            or self:get_kicks(state, 3)
        end,
        ["The Underbelly - Strikebreak Wall"] = function(state)
            return self:can_strikebreak(state) and self:can_bounce(state) and self:kick_or_plunge(state, 1)
        end,
        ["The Underbelly - Surrounded By Holes"] = function(state)
            return self:can_soulcutter(state) and self:has_plunge(state)
            and (
                self:can_bounce(state)
                or self:get_kicks(state, 2)
                or self:knows_obscure(state) and self:get_kicks(state, 1))
        end,

        ["Dilapidated Dungeon - Time Trial"] = function (state)
            return self:has_breaker(state) and self:has_plunge(state) and self:get_kicks(state, 3)
            and self:has_gem(state) and self:can_slidejump(state) and self:can_bounce(state)
        end,
        ["Castle Sansa - Time Trial"] = function (state)
            return self:has_small_keys(state)
        end,
        ["Sansa Keep - Time Trial"] = function (state)
            return self:has_breaker(state) and self:has_plunge(state) and self:get_kicks(state, 3)
            and self:has_gem(state) and self:can_slidejump(state) and self:can_bounce(state)
        end,
        ["Listless Library - Time Trial"] = function (state)
            return self:has_breaker(state) and self:has_plunge(state) and self:has_gem(state)
        end,
        ["Twilight Theatre - Time Trial"] = function (state)
            return self:has_breaker(state) and self:has_plunge(state) and self:get_kicks(state, 3)
            and self:has_gem(state) and self:can_slidejump(state) and self:can_bounce(state)
        end,
        ["Empty Bailey - Time Trial"] = function (state)
            return self:has_breaker(state) and self:has_plunge(state) and self:get_kicks(state, 3)
            and self:has_gem(state) and self:can_slidejump(state) and self:can_bounce(state)
        end,
        ["The Underbelly - Time Trial"] = function (state)
            return self:has_breaker(state) and self:has_plunge(state) and self:get_kicks(state, 3)
            and self:has_gem(state) and self:can_slidejump(state) and self:can_bounce(state)
        end,
        ["Tower Remains - Time Trial"] = function (state)
            return self:has_breaker(state) and self:has_plunge(state) and self:get_kicks(state, 3)
            and self:has_gem(state) and self:can_slidejump(state) and self:can_bounce(state)
        end,
    }

    apply_clauses(self, region_clauses, location_clauses)

    return self
end

return PseudoregaliaNormalRules -- prepare for require()
