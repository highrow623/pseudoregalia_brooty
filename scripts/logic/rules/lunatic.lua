-- TODO: require base

local FULL_GOLD = constants.versions.FULL_GOLD

local free = function(state) return true end

PseudoregaliaLunaticRules = PseudoregaliaExpertRules:new(nil)

function PseudoregaliaLunaticRules.new(cls, definition)
    local self = PseudoregaliaExpertRules.new(cls, definition)

    if self.definition == nil then
        return self
    end

    local region_clauses = {
        ["Tower Remains -> The Great Door"] = function (state)
            return self:can_gold_ultra(state) and self:get_kicks(state, 1)
            or self:has_slide(state) and self:get_kicks(state, 1) and self:has_plunge(state)
        end,
        ["Bailey Lower -> Bailey Upper"] = function (state)
            return self:can_bounce(state)
        end,
        ["Theatre Pillar -> Theatre Main"] = function (state)
            return self:get_kicks(state, 2)
        end,
        ["Dungeon Escape Lower -> Dungeon Escape Upper"] = function(state)
            return self:can_gold_ultra(state) and self:has_plunge(state)
        end,
        ["Castle Main -> Castle => Theatre Pillar"] = function (state)
            return self:has_plunge(state)
        end,
        ["Castle Spiral Climb -> Castle By Scythe Corridor"] = function(state)
            return self:get_kicks(state, 3)
        end,
        ["Castle By Scythe Corridor -> Castle => Theatre (Front)"] = function(state)
            return self:can_gold_ultra(state) and self:kick_or_plunge(state, 2)
        end,
        ["Castle => Theatre (Front) -> Castle By Scythe Corridor"] = function(state)
            return self:can_slidejump(state)
        end,
        ["Library Main -> Library Top"] = function(state)
            return self:get_kicks(state, 1)
        end,
        ["Library Top -> Library Back"] = function(state)
            return self:can_bounce(state) and self:get_kicks(state, 1) and self:has_plunge(state)
        end,
        ["Keep Main -> Keep Throne Room"] = function(state)
            return self:has_breaker(state) and self:has_slide(state) and self:kick_or_plunge(state, 3)
            or self:get_clings(state, 2)
            or (
                self:can_gold_ultra(state)
                and self:can_bounce(state)
                and self:get_kicks(state, 1)
                and self:has_plunge(state)
                and self:can_soulcutter(state))
        end,
        ["Underbelly Main Lower -> Underbelly Main Upper"] = function(state)
            return self:get_kicks(state, 1)
        end,
    }

    local location_clauses = {
        ["Dilapidated Dungeon - Past Poles"] = function(state)
            return self:get_kicks(state, 1) and self:has_plunge(state)
            or self:has_breaker(state) and self:has_plunge(state) and self:has_slide(state)
        end,
        ["Dilapidated Dungeon - Rafters"] = function(state)
            return self:can_gold_ultra(state)
        end,
        ["Castle Sansa - Floater In Courtyard"] = function(state)
            return self:has_slide(state) and self:get_kicks(state, 1)
        end,
        ["Castle Sansa - Platform In Main Halls"] = function(state)
            return self:can_bounce(state)
        end,
        ["Castle Sansa - Corner Corridor"] = function(state)
            return self:can_gold_slide_ultra(state) and self:get_kicks(state, 1)
            or self:has_slide(state) and self:get_kicks(state, 1) and self:has_plunge(state)
        end,
        ["Castle Sansa - Near Theatre Front"] = function(state)
            return self:has_slide(state)
            or self:get_clings(state, 2)
        end,
        ["Sansa Keep - Levers Room"] = free,
        ["Listless Library - Upper Back"] = function(state)
            return self:has_plunge(state)
        end,
    }

    local game_version = self.definition.options.game_version.value
    if game_version == FULL_GOLD then
        location_clauses["Dilapidated Dungeon - Strong Eyes"] = function (state)
            return self:has_slide(state) and self:kick_or_plunge(state, 1)
        end
    end

    apply_clauses(self, region_clauses, location_clauses)

    return self
end

return PseudoregaliaLunaticRules -- prepare for require()
