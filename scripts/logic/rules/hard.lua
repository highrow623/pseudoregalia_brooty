-- TODO: require base

local free = function(state) return true end

PseudoregaliaHardRules = PseudoregaliaNormalRules:new(nil)

function PseudoregaliaHardRules.new(cls, definition)
    local self = PseudoregaliaNormalRules.new(cls, definition)

    if self.definition == nil then
        return self
    end

    local region_clauses = {
        ["Bailey Lower -> Bailey Upper"] = function (state)
            return self:has_plunge(state)
            or self:get_clings(state, 2)
        end,
        ["Bailey Upper -> Tower Remains"] = function (state)
            return self:kick_or_plunge(state, 3)
            or self:get_kicks(state, 2) and self:can_bounce(state)
        end,
        ["Tower Remains -> The Great Door"] = function (state)
            return self:can_attack(state) and self:get_clings(state, 2)
        end,
        ["Theatre Main -> Theatre Pillar"] = function (state)
            return self:get_kicks(state, 1)
        end,
        ["Theatre Pillar => Bailey -> Theatre Pillar"] = function(state)
            return self:get_kicks(state, 1)
            or self:can_slidejump(state)
        end,
        ["Castle => Theatre Pillar -> Theatre Pillar"] = function (state)
            return self:can_slidejump(state)
        end,
        ["Theatre Pillar -> Theatre Main"] = function (state)
            return self:can_slidejump(state) and self:kick_or_plunge(state, 3)
        end,
        ["Theatre Outside Scythe Corridor -> Theatre Main"] = function (state)
            return self:get_clings(state, 4)
        end,
        ["Dungeon Strong Eyes -> Dungeon => Castle"] = function (state)
            return self:knows_obscure(state)
            and (
                self:has_plunge(state)
                or self:has_breaker(state) and self:get_kicks(state, 1)
                or self:has_breaker(state) and self:can_slidejump(state))
        end,
        ["Dungeon => Castle -> Dungeon Strong Eyes"] = function (state)
            return self:knows_obscure(state) and self:has_breaker(state) and self:get_clings(state, 2)
        end,
        ["Dungeon Escape Lower -> Dungeon Escape Upper"] = function(state)
            return self:get_clings(state, 4)
            or self:kick_or_plunge(state, 2)
        end,
        ["Castle Main -> Castle => Theatre Pillar"] = function(state)
            return self:get_clings(state, 2)
            or self:get_kicks(state, 1)
        end,
        ["Castle Main -> Castle Spiral Climb"] = function(state)
            return self:get_clings(state, 2)
            or self:kick_or_plunge(state, 2)
            or self:can_slidejump(state) and self:has_plunge(state)
        end,
        ["Castle Spiral Climb -> Castle High Climb"] = function(state)
            return self:kick_or_plunge(state, 3)
            or self:knows_obscure(state) and self:can_attack(state) and self:can_slidejump(state)
        end,
        ["Castle By Scythe Corridor -> Castle Spiral Climb"] = function(state)
            return self:get_kicks(state, 3)
        end,
        ["Castle By Scythe Corridor -> Castle => Theatre (Front)"] = function(state)
            return self:get_clings(state, 6)
        end,
        ["Castle By Scythe Corridor -> Castle High Climb"] = function(state)
            return self:get_kicks(state, 3) and self:has_breaker(state)
            or self:get_kicks(state, 1) and self:has_plunge(state)
        end,
        ["Castle => Theatre (Front) -> Castle Moon Room"] = function(state)
            return self:get_kicks(state, 4)
        end,
        ["Castle => Theatre (Front) -> Theatre Main"] = function (state)
            return self:get_clings(state, 4)
        end,
        ["Library Main -> Library Top"] = function(state)
            return self:get_clings(state, 4)
            or self:knows_obscure(state) and self:kick_or_plunge(state, 2)
        end,
        ["Library Greaves -> Library Back"] = function (state)
            return self:can_attack(state) and self:get_kicks(state, 1)
        end,
        ["Library Back -> Library Top"] = function(state)
            return self:get_kicks(state, 1)
            or self:get_clings(state, 2)
        end,
        ["Library Top -> Library Back"] = function(state)
            return self:get_clings(state, 2)
            or self:get_kicks(state, 3)
            or self:get_kicks(state, 2) and self:has_plunge(state) and self:can_bounce(state)
        end,
        ["Keep Main -> Keep Locked Room"] = free,
        ["Keep Main -> Keep Sunsetter"] = free,
        ["Keep Main -> Keep Throne Room"] = function(state)
            return self:has_breaker(state) and self:get_clings(state, 6)
            and (
                self:has_plunge(state)
                or self:get_kicks(state, 2)
                or self:get_kicks(state, 1) and self:knows_obscure(state))
            or self:has_breaker(state) and self:has_plunge(state) and self:get_kicks(state, 4)
            or self:can_bounce(state) and self:get_kicks(state, 3)
        end,
        ["Keep Main -> Keep (Northeast) => Castle"] = function (state)
            return self:get_kicks(state, 1)
        end,
        ["Underbelly Light Pillar -> Underbelly Ascendant Light"] = function(state)
            return self:knows_obscure(state)
            and (
                self:can_attack(state) and self:get_kicks(state, 2)
                or self:has_plunge(state) and self:get_clings(state, 2))
        end,
        ["Underbelly Main Lower -> Underbelly Hole"] = function(state)
            return self:has_plunge(state) and self:get_clings(state, 4)
        end,
        ["Underbelly Main Lower -> Underbelly By Heliacal"] = function(state)
            return self:has_slide(state) and self:get_kicks(state, 2)
        end,
        ["Underbelly Main Lower -> Underbelly Main Upper"] = function(state)
            return self:knows_obscure(state)
            and (
                self:has_plunge(state) and self:get_kicks(state, 1)
                or self:has_plunge(state) and self:get_clings(state, 4)
                or self:get_kicks(state, 2) and self:get_clings(state, 2))
        end,
        ["Underbelly Main Upper -> Underbelly Light Pillar"] = function(state)
            return self:knows_obscure(state)
            and (
                self:has_breaker(state) and self:get_clings(state, 2)
                or self:can_slidejump(state) and self:get_kicks(state, 1) and self:has_plunge(state))
        end,
        ["Underbelly Main Upper -> Underbelly By Heliacal"] = function(state)
            return self:has_breaker(state)
            and (
                state:has("Ascendant Light")
                or self:get_clings(state, 2) and self:kick_or_plunge(state, 1)
                or self:kick_or_plunge(state, 4)
                or self:knows_obscure(state) and self:get_clings(state, 4))
        end,
        ["Underbelly => Bailey -> Bailey Upper"] = function (state)
            return self:get_kicks(state, 3)
            or self:can_slidejump(state) and self:get_kicks(state, 1)
        end,
        ["Underbelly => Bailey -> Underbelly Main Lower"] = function(state)
            return self:get_clings(state, 2)
        end,
        ["Underbelly Hole -> Underbelly Main Lower"] = function(state)
            return self:has_plunge(state)
            and (
                self:get_kicks(state, 1)
                or self:get_clings(state, 4))
        end,
    }

    local location_clauses = {
        ["Empty Bailey - Cheese Bell"] = function (state)
            return self:get_clings(state, 6)
        end,
        ["Twilight Theatre - Soul Cutter"] = function (state)
            return self:can_strikebreak(state) and self:can_slidejump(state)
        end,
        ["Twilight Theatre - Corner Beam"] = function (state)
            return self:get_clings(state, 2)
            and(
                self:kick_or_plunge(state, 1)
                or self:can_slidejump(state))
        end,
        ["Twilight Theatre - Locked Door"] = function (state)
            return self:has_small_keys(state) and self:get_clings(state, 4)
        end,
        ["Twilight Theatre - Back Of Auditorium"] = function (state)
            return self:can_slidejump(state)
        end,
        ["Twilight Theatre - Center Stage"] = function (state)
            return self:can_soulcutter(state) and self:get_clings(state, 6)
            and self:kick_or_plunge(state, 1) and self:can_slidejump(state)
        end,
        ["Tower Remains - Cling Gem"] = function (state)
            return self:get_clings(state, 2)
        end,
        ["Tower Remains - Cling Gem 1"] = function (state)
            return self:get_clings(state, 2)
        end,
        ["Tower Remains - Cling Gem 2"] = function (state)
            return self:get_clings(state, 2)
        end,
        ["Tower Remains - Cling Gem 3"] = function (state)
            return self:get_clings(state, 2)
        end,
        ["Dilapidated Dungeon - Dark Orbs"] = function(state)
            return self:get_clings(state, 6)
            or self:get_kicks(state, 1) and self:can_bounce(state)
            or self:can_slidejump(state) and self:has_plunge(state) and self:can_bounce(state)
            or self:get_kicks(state, 3) and self:has_plunge(state)
        end,
        ["Dilapidated Dungeon - Past Poles"] = function(state)
            return self:get_clings(state, 2)
            or self:get_kicks(state, 2)
        end,
        ["Dilapidated Dungeon - Rafters"] = function(state)
            return self:get_clings(state, 6)
            or self:get_kicks(state, 1) and self:has_plunge(state)
            or self:get_kicks(state, 1) and self:can_bounce(state)
        end,
        ["Castle Sansa - Floater In Courtyard"] = function(state)
            return self:kick_or_plunge(state, 4)
            or self:get_clings(state, 2) and self.has_plunge(state)
            or self:get_clings(state, 4)
        end,
        ["Castle Sansa - Platform In Main Halls"] = function(state)
            return self:kick_or_plunge(state, 1)
        end,
        ["Castle Sansa - Tall Room Near Wheel Crawlers"] = function(state)
            return self:get_clings(state, 2)
            or self:get_kicks(state, 1)
            or self:knows_obscure(state) and self:can_slidejump(state) and self:has_plunge(state)
        end,
        ["Castle Sansa - Balcony"] = function(state)
            return self:can_slidejump(state) and self:get_kicks(state, 1)
        end,
        ["Castle Sansa - Corner Corridor"] = function(state)
            return self:get_kicks(state, 3)
        end,
        ["Castle Sansa - Wheel Crawlers"] = function(state)
            return self:get_kicks(state, 1)
            or self:can_slidejump(state) and self:has_plunge(state)
        end,
        ["Castle Sansa - Alcove Near Scythe Corridor"] = function(state)
            return self:get_clings(state, 4)
            or self:get_kicks(state, 2) and self:has_plunge(state)
        end,
        ["Castle Sansa - Near Theatre Front"] = function(state)
            return self:get_clings(state, 6)
            or self:get_clings(state, 2) and self:get_kicks(state, 1)
        end,
        ["Castle Sansa - High Climb From Courtyard"] = function(state)
            return self:get_clings(state, 6)
            or self:has_plunge(state) and self:can_slidejump(state)
        end,
        ["Listless Library - Upper Back"] = function(state)
            return self:can_attack(state) and self:get_clings(state, 4)
        end,
        ["Listless Library - Locked Door Across"] = function(state)
            return self:kick_or_plunge(state, 1)
        end,
        ["Listless Library - Locked Door Left"] = function(state)
            return self:get_kicks(state, 2)
        end,
        ["Sansa Keep - Strikebreak"] = function(state)
            return self:has_breaker(state) and self:get_kicks(state, 1)
            and (
                self:has_slide(state)
                or self:can_strikebreak(state))
        end,
        ["The Underbelly - Rafters Near Keep"] = function(state)
            return self:kick_or_plunge(state, 1)
            or self:get_clings(state, 2)
        end,
        ["The Underbelly - Main Room"] = function(state)
            return self:can_slidejump(state)
        end,
        ["The Underbelly - Alcove Near Light"] = function(state)
            return self:get_kicks(state, 3)
            or self:get_kicks(state, 2) and self:can_slidejump(state)
        end,
        ["The Underbelly - Building Near Little Guy"] = function(state)
            return self:get_kicks(state, 2)
        end,
        ["The Underbelly - Strikebreak Wall"] = function(state)
            return self:can_strikebreak(state)
            and (
                self:can_bounce(state)
                or self:kick_or_plunge(state, 3))
        end,
        ["The Underbelly - Surrounded By Holes"] = function(state)
            return self:has_plunge(state) and self:get_clings(state, 6)
        end,
        ["Castle Sansa - Bubblephobic Goatling"] = function (state)
            return self:get_kicks(state, 1)
            or self:get_clings(state, 2)
        end,
        ["Twilight Theatre - Murderous Goatling"] = function (state)
            return self:get_kicks(state, 1)
        end,
        ["Twilight Theatre - Stage Right Stool"] = function (state)
            return self:knows_obscure(state) and self:can_soulcutter(state) and self:can_slidejump(state)
        end,
        ["The Underbelly - Note on a Ledge"] = function (state)
            return self:can_slidejump(state)
        end,
        ["The Underbelly - Note in the Big Room"] = function (state)
            return self:kick_or_plunge(state, 2)
            or self:get_clings(state, 6) and self:get_kicks(state, 1)
        end,
    }

    apply_clauses(self, region_clauses, location_clauses)

    return self
end

return PseudoregaliaHardRules -- prepare for require()
