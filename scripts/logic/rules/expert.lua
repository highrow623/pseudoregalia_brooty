-- TODO = require base


local free = function(state) return true end
local no = function(state) return false end

PseudoregaliaExpertRules = PseudoregaliaRulesHelpers:new(nil)

function PseudoregaliaExpertRules.new(cls, definition)
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
        --# "Dungeon => Castle -> Dungeon Mirror" = function(state) True,
        ["Dungeon => Castle -> Dungeon Strong Eyes"] = function(state)
            return self:has_small_keys(state)
        end,
        --# "Dungeon => Castle -> Castle Main" = function(state) True,
        ["Dungeon Escape Lower -> Dungeon Slide"] = function(state)
            return self:can_attack(state)
        end,
        ["Dungeon Escape Lower -> Dungeon Escape Upper"] = function(state)
            return self:can_bounce(state)
            or self:has_gem(state)
            or self:kick_or_plunge(state, 2)
            or self:has_slide(state) and self:get_kicks(state, 1)
        end,
        --# "Dungeon Escape Lower -> Underbelly => Dungeon" = function(state) True,
        ["Dungeon Escape Upper -> Theatre Outside Scythe Corridor"] = function(state)
            return self:can_bounce(state)
            or self:kick_or_plunge(state, 1)
            or self:has_gem(state)
            or self:has_slide(state)
        end,
        --# "Dungeon Escape Upper -> Theatre Outside Scythe Corridor" = function(state) True,
        --# "Castle Main -> Dungeon => Castle" = function(state) True,
        --# "Castle Main -> Keep Main" = function(state) True,
        --# "Castle Main -> Empty Bailey" = function(state) True,
        ["Castle Main -> Library Main"] = function(state)
            return self:can_attack(state)
        end,
        ["Castle Main -> Theatre Pillar"] = function(state)
            return self:has_gem(state)
            or self:has_slide(state)
            or self:kick_or_plunge(state, 1)
        end,
        ["Castle Main -> Castle Spiral Climb"] = function(state)
            return self:has_gem(state)
            or self:has_slide(state)
            or self:kick_or_plunge(state, 2)
        end,
        --# "Castle Spiral Climb -> Castle Main" = function(state) True,
        --# "Castle Spiral Climb -> Castle High Climb" = function(state) True,
        --# Anything that gets you into spiral climb can get from there to high climb
        ["Castle Spiral Climb -> Castle By Scythe Corridor"] = function(state)
            return self:has_gem(state)
            or self:kick_or_plunge(state, 4)
        end,
        ["Castle By Scythe Corridor -> Castle Spiral Climb"] = function(state)
            return self:has_gem(state)
            or self:get_kicks(state, 3)
        end,
        ["Castle By Scythe Corridor -> Castle => Theatre (Front)"] = function(state)
            return self:has_gem(state)
            or self:has_slide(state) and self:get_kicks(state, 2)
        end,
        ["Castle By Scythe Corridor -> Castle High Climb"] = function(state)
            return self:has_gem(state)
            or self:has_slide(state)
            or self:kick_or_plunge(state, 2)
        end,
        ["Castle => Theatre (Front) -> Castle By Scythe Corridor"] = function(state)
            return self:has_gem(state)
            or self:has_slide(state)
            or self:get_kicks(state, 3)
        end,
        ["Castle => Theatre (Front) -> Castle Moon Room"] = function(state)
            return self:has_gem(state)
            or self:has_slide(state)
            or self:get_kicks(state, 4)
        end,
        --# "Castle => Theatre (Front) -> Theatre Main" = function(state) True,
        ["Library Main -> Library Locked"] = function(state)
            return self:has_small_keys(state)
        end,
        ["Library Main -> Library Greaves"] = function(state)
            return self:has_slide(state)
        end,
        ["Library Main -> Library Top"] = function(state)
            return self:has_gem(state)
            or self:kick_or_plunge(state, 2)
            or self:has_slide(state)
        end,
        ["Library Greaves -> Library Top"] = function(state)
            return self:has_gem(state)
            or self:get_kicks(state, 1)
            or self:has_slide(state)
        end,
        ["Library Top -> Library Greaves"] = function(state)
            return self:has_gem(state)
            or self:get_kicks(state, 2)
        end,
        --# "Keep Main -> Keep Locked Room" = function(state) True,
        --# "Keep Main -> Keep Sunsetter" = function(state) True,
        ["Keep Main -> Keep => Underbelly"] = function(state)
            return self:kick_or_plunge(state, 1)
            or self:has_gem(state)
            or self:has_slide(state)
        end,
        ["Keep Locked Room -> Keep Sunsetter"] = free,
        ["Keep => Underbelly -> Underbelly Hole"] = free,
        ["Keep Main -> Theatre Outside Scythe Corridor"] = function(state)
            return self:has_gem(state)
            or self:get_kicks(state, 1)
            or self:has_slide(state)
            or self:can_bounce(state)
        end,
        ["Keep Main -> Keep Path To Throne"] = function(state)
            return self:has_breaker(state)
        end,
        --# "Keep Locked Room -> Keep Sunsetter" = function(state) True,
        --# "Keep => Underbelly -> Keep Main" = function(state) True,
        --# "Keep => Underbelly -> Underbelly Hole" = function(state) True,
        --# "Underbelly => Dungeon -> Dungeon Escape Lower" = function(state) True,
        --# "Underbelly => Dungeon -> Underbelly Light Pillar" = function(state) True,
        ["Underbelly => Dungeon -> Underbelly Ascendant Light"] = function(state)
            return self:has_breaker(state)
            or self:has_gem(state)
            or self:kick_or_plunge(state, 2)
            or self:get_kicks(state, 1) and self:has_slide(state)
        end,
        --# "Underbelly Light Pillar -> Underbelly Main Upper" = function(state) True,
        ["Underbelly Light Pillar -> Underbelly => Dungeon"] = function(state)
            return self:can_bounce(state)
            or self:get_kicks(state, 4)
            or self:has_plunge(state) and self:get_kicks(state, 2)
            or self:has_slide(state) and self:kick_or_plunge(state, 2)
        end,
        ["Underbelly Light Pillar -> Underbelly Ascendant Light"] = function(state)
            return self:has_breaker(state)
            and (
                self:has_plunge(state)
                or self:get_kicks(state, 2)
                or self:get_kicks(state, 1) and self:has_gem(state)
                or self:has_slide(state))
            or self:has_plunge(state)
            and (
                self:has_gem(state)
                or self:get_kicks(state, 1)
                or self:has_slide(state))
            end,
        --# "Underbelly Ascendant Light -> Underbelly Light Pillar" = function(state) True,
        ["Underbelly Ascendant Light -> Underbelly => Dungeon"] = function(state)
            return self:can_bounce(state)
            or self:has_gem(state)
            or self:kick_or_plunge(state, 2)
            or self:has_slide(state) and self:get_kicks(state, 1)
        end,
        --# "Underbelly Main Lower -> Underbelly Little Guy" = function(state) True,
        ["Underbelly Main Lower -> Underbelly Hole"] = function(state)
            return self:has_plunge(state)
            and (
                self:get_kicks(state, 1)
                or self:has_gem(state)
                or self:has_slide(state)
                or self:can_attack(state))
            end,
        ["Underbelly Main Lower -> Underbelly By Heliacal"] = function(state)
            return self:has_slide(state)
            end,
        ["Underbelly Main Lower -> Underbelly Main Upper"] = function(state)
            return self:has_plunge(state) and self:get_kicks(state, 2)
            or self:has_gem(state) and self:kick_or_plunge(state, 1)
            or self:get_kicks(state, 4)
            or self:has_slide(state)
            and (
                self:has_gem(state)
                or self:get_kicks(state, 3)
                or self:get_kicks(state, 1) and self:has_plunge(state)
                or self:get_kicks(state, 1) and self:has_breaker(state))
            end,
        --# "Underbelly Main Upper -> Underbelly Main Lower" = function(state) True,
        ["Underbelly Main Upper -> Underbelly Light Pillar"] = function(state)
            return self:has_breaker(state)
            and (
                self:has_plunge(state)
                or self:get_kicks(state, 2)
                or self:has_slide(state))
            or self:has_slide(state) and self:get_kicks(state, 1)
            or self:has_plunge(state) and self:get_kicks(state, 2)
            or self:has_gem(state)
            and (
                self:has_plunge(state)
                or self:get_kicks(state, 2))
            end,
        ["Underbelly Main Upper -> Underbelly By Heliacal"] = function(state)
            return self:has_breaker(state)
            and (
                state:has("Ascendant Light")
                or self:has_gem(state)
                or self:has_plunge(state) and self:get_kicks(state, 3))
            end,
        ["Underbelly By Heliacal -> Underbelly Main Upper"] = function(state)
            return self:can_attack(state)
            or self:has_gem(state)
            or self:get_kicks(state, 2)
        end,
        --# "Underbelly Little Guy -> Empty Bailey" = function(state) True,
        --# "Underbelly Little Guy -> Underbelly Main Lower" = function(state) True,
        --# "Underbelly => Keep -> Keep => Underbelly" = function(state) True,
        ["Underbelly => Keep -> Underbelly Hole"] = function(state)
            return self:has_plunge(state)
        end,
        ["Underbelly Hole -> Underbelly Main Lower"] = function(state)
            return self:get_kicks(state, 1)
            or self:has_gem(state)
            or self:can_attack(state)
            or self:has_slide(state)
        end,
        ["Underbelly Hole -> Underbelly => Keep"] = function(state)
            return self:has_slide(state)
        end,
    }) do
        self.region_rules[k] = v
    end
    
    for k, v in pairs({
        --# "Dilapidated Dungeon - Dream Breaker" = function(state) True,
        --# "Dilapidated Dungeon - Slide" = function(state) True,
        --# "Dilapidated Dungeon - Alcove Near Mirror" = function(state) True,
        ["Dilapidated Dungeon - Dark Orbs"] = function(state)
            return self:has_gem(state)
            or self:get_kicks(state, 1) and self:can_bounce(state)
            or self:get_kicks(state, 3) and self:has_plunge(state)
            or self:has_slide(state) and self:get_kicks(state, 1)
            or self:has_slide(state) and self:can_bounce(state)
        end,
        ["Dilapidated Dungeon - Past Poles"] = function(state)
            return self:has_gem(state)
            or self:get_kicks(state, 2)
        end,
        ["Dilapidated Dungeon - Rafters"] = function(state)
            return self:has_gem(state)
            or self:kick_or_plunge(state, 2)
            or self:can_bounce(state) and self:get_kicks(state, 1)
            or self:has_slide(state) and self:kick_or_plunge(state, 1)
        end,
        ["Dilapidated Dungeon - Strong Eyes"] = function(state)
            return self:has_breaker(state)
            or self:has_gem(state)
            or self:has_slide(state) and self:get_kicks(state, 1)
        end,
        --# "Castle Sansa - Indignation" = function(state) True,
        ["Castle Sansa - Floater In Courtyard"] = function(state)
            return self:can_bounce(state)
            and (
                self:kick_or_plunge(state, 1)
                or self:has_slide(state))
            or self:has_slide(state) and self:get_kicks(state, 1)
            or self:get_kicks(state, 3)
            or self:has_gem(state)
        end,
        ["Castle Sansa - Locked Door"] = function(state)
            return self:has_small_keys(state)
        end,
        ["Castle Sansa - Platform In Main Halls"] = function(state)
            return self:kick_or_plunge(state, 1)
            or self:has_gem(state)
            or self:has_slide(state)
        end,
        ["Castle Sansa - Tall Room Near Wheel Crawlers"] = function(state)
            return self:has_gem(state)
            or self:get_kicks(state, 1)
            or self:has_slide(state)
        end,
        ["Castle Sansa - Alcove Near Dungeon"] = function(state)
            return self:has_gem(state)
            or self:kick_or_plunge(state, 1)
            or self:has_slide(state)
        end,
        ["Castle Sansa - Balcony"] = function(state)
            return self:has_gem(state)
            or self:get_kicks(state, 3)
            or self:has_plunge(state) and self:get_kicks(state, 1)
            or self:has_slide(state)
        end,
        ["Castle Sansa - Corner Corridor"] = function(state)
            return self:has_gem(state)
            or self:get_kicks(state, 3)
            or self:get_kicks(state, 2) and self:has_slide(state)
        end,
        ["Castle Sansa - Wheel Crawlers"] = function(state)
            return self:can_bounce(state)
            or self:has_gem(state)
            or self:kick_or_plunge(state, 1)
            or self:has_slide(state)
        end,
        ["Castle Sansa - Alcove Near Scythe Corridor"] = function(state)
            return self:has_gem(state)
            or self:kick_or_plunge(state, 3)
            or self:has_slide(state) and self:kick_or_plunge(state, 1)
        end,
        ["Castle Sansa - Near Theatre Front"] = function(state)
            return self:has_gem(state)
            or self:has_slide(state)
            or self:get_kicks(state, 4)
            or self:get_kicks(state, 2) and self:has_plunge(state)
        end,
        ["Castle Sansa - High Climb From Courtyard"] = function(state)
            return self:get_kicks(state, 2)
            or self:has_gem(state)
            or self:can_attack(state) and self:get_kicks(state, 1)
            or self:has_slide(state)
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
            return (self:has_breaker(state) or self:knows_obscure(state) and self:has_plunge(state))
            and (
                self:has_gem(state)
                or self:kick_or_plunge(state, 2)
                or self:has_slide(state))
            end,
        ["Listless Library - Locked Door Across"] = function(state)
            return self:has_gem(state)
            or self:kick_or_plunge(state, 1)
            or self:has_slide(state)
        end,
        ["Listless Library - Locked Door Left"] = function(state)
            return self:has_gem(state)
            or self:kick_or_plunge(state, 2)
            or self:has_slide(state) and self:kick_or_plunge(state, 1)
        end,
        ["Sansa Keep - Near Theatre"] = function(state)
            return self:kick_or_plunge(state, 1)
            or self:has_gem(state)
        end,
        --# "Sansa Keep - Alcove Near Locked Door" = function(state) True,
        ["Sansa Keep - Levers Room"] = function(state)
            return self:can_attack(state)
        end,
        ["Sansa Keep - Sunsetter"] = function(state)
            return self:can_attack(state)
        end,
        ["Sansa Keep - Strikebreak"] = function(state)
            return self:can_attack(state) and self:has_slide(state)
            or self:can_strikebreak(state) and self:has_gem(state)
            or self:can_strikebreak(state) and self:kick_or_plunge(state, 1)
        end,
        ["Sansa Keep - Lonely Throne"] = function(state)
            return self:has_gem(state)
            or self:has_plunge(state) and self:get_kicks(state, 4)
            or state:has("Ascendant Light") and self:kick_or_plunge(state, 3)
            or self:has_slide(state) and self:get_kicks(state, 3)
        end,
        --# "The Underbelly - Ascendant Light" = function(state) True,
        ["The Underbelly - Rafters Near Keep"] = function(state)
            return self:kick_or_plunge(state, 1)
            or self:has_gem(state)
            or self:has_slide(state)
            or self:can_bounce(state)
        end,
        ["The Underbelly - Locked Door"] = function(state)
            return self:has_small_keys(state)
        end,
        ["The Underbelly - Main Room"] = function(state)
            return self:has_plunge(state)
            or self:has_gem(state)
            or self:get_kicks(state, 2)
            or self:has_slide(state)
        end,
        ["The Underbelly - Alcove Near Light"] = function(state)
            return self:can_attack(state)
            or self:has_gem(state)
            or self:get_kicks(state, 3)
            or self:get_kicks(state, 1) and self:has_slide(state)
        end,
        ["The Underbelly - Building Near Little Guy"] = function(state)
            return self:has_plunge(state)
            or self:get_kicks(state, 1)
            or self:has_slide(state)
        end,
        ["The Underbelly - Strikebreak Wall"] = function(state)
            return self:can_bounce(state)
            or self:get_kicks(state, 3)
            or self:get_kicks(state, 1) and self:has_plunge(state)
            or self:has_slide(state) and self:kick_or_plunge(state, 1)
            or self:has_slide(state) and self:has_gem(state)
        end,
        ["The Underbelly - Surrounded By Holes"] = function(state)
            return self:can_soulcutter(state)
            and (
                self:can_bounce(state)
                or self:get_kicks(state, 1)
                or self:has_slide(state)
            )
            or self:has_gem(state)
            or self:has_slide(state) and self:get_kicks(state, 1)
        end,
    }) do
        self.location_rules[k] = v
    end

    return self
end

return PseudoregaliaExpertRules -- prepare for require()
