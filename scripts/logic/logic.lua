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

-- Region functions
function dungeon_strong_eyes()
    return slide() and breaker()
end

function underbelly_main()
    return breaker() or (sunsetter() and (tower_remains() or underbelly_hole()))
end

--function theatre_main() -- OLD OLD OLD
    --return (greaves() and breaker()) or (cling() and breaker()) or
               --(can_slidejump() and (greaves() or heliacal()) and breaker()) or (can_bounce()) or
               --(castle_sansa() and (cling() or (can_slidejump() and more_kicks()))) or
               --(keep_main() and ((cling() and greaves()) or (cling() and can_slidejump()))) or
               --(theatre_pillar() and ((sunsetter() and cling()) or (sunsetter() and more_kicks()))) 
--end

function theatre_main()
    return (breaker() and cling()) or (breaker() and greaves()) or (breaker() and heliacal() and can_slidejump()) or
               (cling() and greaves() and keep_main()) or (cling() and keep_main() and can_slidejump()) or
               (cling() and castle_sansa()) or (cling() and theatre_pillar() and sunsetter()) or
               (castle_sansa() and more_kicks() and can_slidejump()) or
               (more_kicks() and theatre_pillar() and sunsetter()) or can_bounce()
end

function castle_sansa()
    return (has_small_keys() and dungeon_strong_eyes()) or (empty_bailey())
end

function library_main()
    return breaker() and castle_sansa()
end

function keep_main()
    return (cling() and theatre_main()) or castle_sansa()
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
    return library_main() and has_small_keys()
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

-- LOL, my attempts at trying to get rid of all the recurssions, fuck it lmao

--function dungeon_strong_eyes()
    --return (slide() and breaker())
--end

--function underbelly_main()
    --local tower_remains = tower_remains()
    --local underbelly_hole = underbelly_hole()
    
    --return (breaker()) or (tower_remains and sunsetter()) or (underbelly_hole() and sunsetter())
--end

--function underbelly_main()
    --local tower_remains = (dungeon_strong_eyes() and has_small_keys() and
                              --(cling() or (slide() and sunsetter())))
    --local underbelly_hole = ((dungeon_strong_eyes() and has_small_keys()) or
                                --(theatre_main() and cling())) and sunsetter()

    --return breaker() or (tower_remains and sunsetter()) or (underbelly_hole and sunsetter())
--end

--function theatre_main()
    --local hasGreaves = greaves()
    --local hasCling = cling()
    --local canSlideJump = can_slidejump()
    --local hasHeliacal = heliacal()
    --local hasBreaker = breaker()
    --local canBounce = can_bounce()
    --local castleSansa = castle_sansa()
    --local moreKicks = more_kicks()
    --local hasSunsetter = sunsetter()
    --local theatre_pillar = theatre_pillar()
    
    --return (hasGreaves and hasBreaker) or
           --(hasCling and hasBreaker) or
           --(canSlideJump and (hasGreaves or hasHeliacal) and hasBreaker) or
           --canBounce or
           --(castleSansa and (hasCling or (canSlideJump and moreKicks))) or
           --(castleSansa and (hasCling and hasGreaves) or (hasCling and canSlideJump)) or
           --(theatre_pillar and ((hasSunsetter and hasCling) or hasSunsetter and moreKicks))
--end

--function castle_sansa()
    --local empty_bailey = empty_bailey()

    --return (dungeon_strong_eyes() and has_small_keys()) or (empty_bailey)
--end

--function castle_sansa()
    --local empty_bailey = (dungeon_strong_eyes() and has_small_keys()) or
                             --(((breaker()) or
                                 --((cling() or (slide() and sunsetter())) and sunsetter()) or
                                 --((greaves() and breaker()) or (cling() and breaker()) or
                                     --(can_slidejump() and (greaves() or heliacal()) and breaker()) or
                                     --(can_bounce()) or
                                     --((cling() or sunsetter()) and
                                         --((sunsetter() and cling()) or sunsetter() and more_kicks())) and
                                     --cling() and sunsetter() and sunsetter())) and
                                 --(breaker() or sunsetter()))

    --return (dungeon_strong_eyes() and has_small_keys()) or (empty_bailey)
--end

--function library_main()
    --return (breaker())
--end

--function keep_main()
    --local castle_sansa = castle_sansa()
    --local theatre_main = theatre_main()

    --return (castle_sansa) or (theatre_main and cling())
--end

--function keep_main()
    --local castle_sansa =
        --((dungeon_strong_eyes() and has_small_keys()) or (dungeon_strong_eyes() and has_small_keys()) or
            --((breaker()) or
                --((dungeon_strong_eyes() and has_small_keys()) or
                    --((breaker()) and (breaker() or sunsetter())) and
                    --(cling() or (slide() and sunsetter())) and sunsetter()) or (sunsetter()) and
                --(breaker() or sunsetter())))
    --local theatre_main = (greaves() and breaker()) or (cling() and breaker()) or
                             --(can_slidejump() and (greaves() or heliacal()) and breaker()) or
                             --(can_bounce()) or
                             --(((dungeon_strong_eyes() and has_small_keys())) and
                                 --(cling() or (can_slidejump() and more_kicks()))) or
                             --(((dungeon_strong_eyes() and has_small_keys()) or
                                 --(breaker() and (breaker() or sunsetter()))) and
                                 --((cling() and greaves()) or (cling() and can_slidejump()))) or
                             --(((((dungeon_strong_eyes() and has_small_keys()) or (empty_bailey())) and (cling() or sunsetter())) or (empty_bailey())) and
                                 --((sunsetter() and cling()) or sunsetter() and more_kicks()))

    --return (castle_sansa) or (theatre_main and cling())
--end


--function empty_bailey()
    --local hasBreaker = breaker()
    --local hasSunsetter = sunsetter()
    --local underbelly_main = underbelly_main()
    
    --return (dungeon_strong_eyes() and has_small_keys()) or
           --(underbelly_main and (hasBreaker or hasSunsetter))
--end

--function theatre_pillar()
    --local hasCling = cling()
    --local hasSunsetter = sunsetter()
    --local castle_sansa = castle_sansa()
    --local empty_bailey = empty_bailey()
    
    --return (((dungeon_strong_eyes() and has_small_keys()) or (empty_bailey)) and (hasCling or hasSunsetter)) or (empty_bailey)
--end

--function keep_sunsetter()
    --local keep_main = keep_main()

    --return keep_main and (has_small_keys() or cling() or greaves())
--end

--function library_locked()
    --local library_main = library_main()

    --return (library_main and has_small_keys())
--end

--function underbelly_hole()
    --local keep_main = keep_main()

    --return (keep_main and sunsetter())
--end

--function tower_remains()
    --local hasCling = cling()
    --local hasSlide = slide()
    --local hasSunsetter = sunsetter()
    --local empty_bailey = empty_bailey()
    
    --return (empty_bailey and (hasCling or (hasSlide and hasSunsetter)))
--end

--function the_great_door()
    --return (tower_remains() and cling() and greaves())
--end





