---[[
function has(item, amount)
    local count = Tracker:ProviderCountForCode(item)
    amount = tonumber(amount)
    if not amount then
        return count > 0
    else
        return count >= amount
    end
end

-- Abilities
function breaker(n)
    return has("breaker")
end

function greaves(n)
    return has("greaves")
end

function slide(n)
    return has("slide")
end

function solar(n)
    return has("solar")
end

function sunsetter(n)
    return has("sunsetter")
end

function strikebreak(n)
    return has("strikebreak")
end

function cling(n)
    return has("cling")
end

function ascendant(n)
    return has("ascendant")
end

function cutter(n)
    return has("cutter")
end

function heliacal(n)
    return has("heliacal")
end

-- Quick Functions
function has_small_keys(n)
    -- print("has_small_keys")
    return has("smallkey",6)
end

function can_bounce(n)
    -- print("can_bounce")
    return breaker() and ascendant()
end

function more_kicks(n)
    -- print("more_kicks")
    return greaves() and heliacal()
end

function can_slidejump(n)
    -- print("can_slidejump")
    return slide() and solar()
end

function navigate_darkrooms(n)
    -- print("navigate_darkrooms")
    return (breaker() or ascendant())
end

function can_strikebreak(n)
    -- print("can_strikebreak")
    return breaker() and strikebreak()
end

function can_soulcutter(n)
    -- print("can_soulcutter")
    return breaker() and strikebreak() and cutter()
end

function can_sunsetter(n)
    -- print("can_sunsetter")
    return breaker() and sunsetter()
end

-- Region functions
function dungeon_strong_eyes(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("dungeon_strong_eyes")
    return slide(n) and breaker(n)
end

function underbelly_main(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("underbelly_main")
    return breaker(n) or (sunsetter(n) and (tower_remains(n) or underbelly_hole(n)))
end

--function theatre_main() -- OLD OLD OLD
    --return (cling() and (greaves() or can_slidejump())) or
               --(castle_sansa() and (cling() or (can_slidejump() and more_kicks()))) or
               --(keep_main() and ((cling() and greaves()) or (cling() and can_slidejump()))) or
               --(theatre_pillar() and ((sunsetter() and cling()) or (sunsetter() and more_kicks()))) 
--end

--function theatre_main() -- THIS FUNCTION WILL BE MORE ACCURATE LATER ON, FOR NOW USING THE ONE BELOW JUST TO MATCH AP LOGIC
    --return (breaker() and cling()) or (breaker() and greaves()) or (breaker() and heliacal() and can_slidejump()) or
               --(cling() and (greaves() or can_slidejump()) and keep_main()) or
               --(cling() and castle_sansa()) or (cling() and theatre_pillar() and sunsetter()) or
               --(castle_sansa() and more_kicks() and can_slidejump()) or
               --(more_kicks() and theatre_pillar() and sunsetter()) or (cling() and (greaves() or can_slidejump()))
--end

function theatre_main(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("theatre_main")
    return (cling(n) and (greaves(n) or can_slidejump(n)) and keep_main(n)) or (cling(n) and castle_sansa(n)) or
               (cling(n) and sunsetter(n) and theatre_pillar(n)) or (more_kicks(n) and can_slidejump(n) and castle_sansa(n)) or
               (more_kicks(n) and sunsetter(n) and theatre_pillar(n)) or (cling(n) and breaker(n) and (greaves(n) or can_slidejump(n)))
end

function castle_sansa(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("castle_sansa")
    return (has_small_keys(n) and dungeon_strong_eyes(n)) or (empty_bailey(n))
end

function library_main(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("library_main")
    return breaker(n) and castle_sansa(n)
end

function keep_main(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("keep_main")
    return (cling(n) and ((cling(n) and castle_sansa(n)) or (cling(n) and sunsetter(n) and theatre_pillar(n)) or
               (more_kicks(n) and can_slidejump(n) and castle_sansa(n)) or
               (more_kicks(n) and sunsetter(n) and theatre_pillar(n)) or (cling(n) and breaker(n) and (greaves(n) or can_slidejump(n))))) or
               castle_sansa(n)
end

function empty_bailey(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("empty_bailey")
    return (dungeon_strong_eyes(n) and has_small_keys(n)) or ((breaker(n) or sunsetter(n)) and underbelly_main(n))
end

function theatre_pillar(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("theatre_pillar")
    return (castle_sansa(n) and (heliacal(n) or greaves(n) or cling(n) or sunsetter(n))) or (empty_bailey(n))
end

function keep_sunsetter(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("keep_sunsetter")
    return (has_small_keys(n) or cling(n) or greaves(n)) and keep_main(n)
end

function library_locked(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("library_locked")
    return library_main(n) --and has_small_keys() --removed for yellow checks
end

function underbelly_hole(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("underbelly_hole")
    return (sunsetter(n) or heliacal(n) or greaves(n)) and keep_main(n)
end

function tower_remains(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("tower_remains")
    return (cling(n) or heliacal(n) or greaves(n) or (slide(n) and sunsetter(n))) and empty_bailey(n)
end

function the_great_door(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("the_great_door")
    return cling(n) and greaves(n) and tower_remains(n)
end




