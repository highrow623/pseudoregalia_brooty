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
function breaker()
    return has("breaker")
end

function greaves()
    return has("greaves")
end

function slide()
    return has("slide")
end

function solar()
    return has("solar")
end

function sunsetter()
    return has("sunsetter")
end

function strikebreak()
    return has("strikebreak")
end

function cling()
    return has("cling")
end

function ascendant()
    return has("ascendant")
end

function cutter()
    return has("cutter")
end

function heliacal()
    return has("heliacal")
end

-- Quick Functions
function has_small_keys()
    return has("smallkey",6)
end

function can_bounce()
    return breaker() and ascendant()
end

function more_kicks()
    return greaves() and heliacal()
end

function can_slidejump()
    return slide() and solar()
end

function navigate_darkrooms()
    return (breaker() or ascendant())
end

function can_strikebreak()
    return breaker() and strikebreak()
end

function can_soulcutter()
    return breaker() and strikebreak() and cutter()
end

function can_sunsetter()
    return breaker() and sunsetter()
end

-- Region functions
function dungeon_strong_eyes()
    return slide() and breaker()
end

function underbelly_main()
    return breaker() or (sunsetter() and (tower_remains() or underbelly_hole()))
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

function theatre_main()
    return (cling() and (greaves() or can_slidejump()) and keep_main()) or (cling() and castle_sansa()) or
               (cling() and sunsetter() and theatre_pillar()) or (more_kicks() and can_slidejump() and castle_sansa()) or
               (more_kicks() and sunsetter() and theatre_pillar()) or (cling() and breaker() and (greaves() or can_slidejump()))
end

function castle_sansa()
    return (has_small_keys() and dungeon_strong_eyes()) or (empty_bailey())
end

function library_main()
    return breaker() and castle_sansa()
end

function keep_main()
    return (cling() and ((cling() and castle_sansa()) or (cling() and sunsetter() and theatre_pillar()) or
               (more_kicks() and can_slidejump() and castle_sansa()) or
               (more_kicks() and sunsetter() and theatre_pillar()) or (cling() and breaker() and (greaves() or can_slidejump())))) or
               castle_sansa()
end

function empty_bailey()
    return (dungeon_strong_eyes() and has_small_keys()) or ((breaker() or sunsetter()) and underbelly_main())
end

function theatre_pillar()
    return (castle_sansa() and (heliacal() or greaves() or cling() or sunsetter())) or (empty_bailey())
end

function keep_sunsetter()
    return (has_small_keys() or cling() or greaves()) and keep_main()
end

function library_locked()
    return library_main() --and has_small_keys() --removed for yellow checks
end

function underbelly_hole()
    return (sunsetter() or heliacal() or greaves()) and keep_main()
end

function tower_remains()
    return (cling() or heliacal() or greaves() or (slide() and sunsetter())) and empty_bailey()
end

function the_great_door()
    return cling() and greaves() and tower_remains()
end




