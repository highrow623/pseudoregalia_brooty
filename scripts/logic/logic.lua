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
    return Tracker:ProviderCountForCode("heliacal")
end

-- Difficulty Settings

function Knows_obscure(n)
    return has("obscure")
end

function Normal(n)
    return has("normal")
end

function Hard(n)
    return has("hard")
end

function Expert(n)
    return has("expert")
end

function Lunatic(n)
    return has("lunatic")
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

function can_attack(n)
    -- print("can_sunsetter")
    return breaker() or sunsetter()
end

function Kickorplunge(count)
    local total = 0
    if has("greaves") then
      total = total + 3
    end
    if has("sunsetter") then
      total = total + 1
    end
    total = total + heliacal() --see note
    count = tonumber(count)
    return (total >= count)
  end

function Getkicks(count)
    local kicks = 0
    if has("greaves") then
        kicks = kicks + 3
    end
    kicks = kicks + heliacal()
    count = tonumber(count)
    return (kicks >= count)
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

function theatre_main(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("theatre_main")
    return (cling(n) and (greaves(n) or can_slidejump(n))) or
        (cling(n) and (greaves(n) or can_slidejump(n)) and keep_main(n)) or 
        ((sunsetter(n) and cling(n)) or (sunsetter(n) and Getkicks(4)) and theatre_pillar(n)) or
        Theatre_front(n)
end

function castle_sansa(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("castle_sansa")
    return (has_small_keys(n) and dungeon_strong_eyes(n)) or empty_bailey(n) or Castle_spiral_climb(n)
end

function library_main(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("library_main")
    return (Normal(n) and (breaker(n) or (Knows_obscure(n) and can_attack(n))) and castle_sansa(n)) or
        (Expert(n) and can_attack(n) and castle_sansa(n))
end

function keep_main(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("keep_main")
    return (cling(n) and theatre_main(n)) or castle_sansa(n)
end

function empty_bailey(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("empty_bailey")
    return (sunsetter(n) or breaker(n)) and underbelly_main(n)
end

function theatre_pillar(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("theatre_pillar")
    return (empty_bailey(n)) or (Normal(n) and (Kickorplunge(2) or (cling(n) and Kickorplunge(1))) and castle_sansa(n)) or
        (Hard(n) and (cling(n) or (Kickorplunge(1))) and castle_sansa(n)) or
        ((Expert(n) or Lunatic(n)) and (cling(n) or slide(n) or Kickorplunge(1)) and castle_sansa(n))
end

function keep_sunsetter(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("keep_sunsetter")
    return (cling(n) or has_small_keys(n) or greaves(n)) and keep_main(n)
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
    return Kickorplunge(1) and keep_main(n)
end

function tower_remains(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("tower_remains")
    return (cling(n) or Getkicks(1) or (slide(n) and sunsetter(n))) and empty_bailey(n)
end

function the_great_door(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    -- print("the_great_door")
    return cling(n) and Getkicks(3) and tower_remains(n)
end

function Castle_spiral_climb(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    return (Normal(n) and (Getkicks(2) or (cling(n) and sunsetter(n))) and castle_sansa(n)) or
        (Normal(n) and (cling(n) or (Getkicks(4) and sunsetter(n))) and Scythe_corridor(n)) or 
        (Hard(n) and (cling(n) or Kickorplunge(2) or (can_slidejump(n) and sunsetter(n))) and castle_sansa(n)) or
        ((Hard(n) or Expert(n) or Lunatic(n)) and (cling(n) or (Getkicks(3))) and Scythe_corridor(n)) or
        ((Expert(n) or Lunatic(n)) and (cling(n) or slide(n) or Kickorplunge(2)) and castle_sansa(n))
end

function Castle_high_climb(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    return (Normal(n) and ((Getkicks(3) and sunsetter(n)) or (breaker(n) and Getkicks(1)) or (Knows_obscure(n) and sunsetter(n) and Getkicks(1))) and Castle_spiral_climb(n)) or
        (Normal(n) and (cling(n) or Getkicks(4) or (Getkicks(2) and sunsetter(n)) or (Getkicks(1) and sunsetter(n) and can_slidejump(n))) and Scythe_corridor(n)) or
        (Hard(n) and (cling(n) or Kickorplunge(3) or (breaker(n) and Getkicks(1)) or (Knows_obscure(n) and sunsetter(n) and Getkicks(1)) or (Knows_obscure(n) and can_attack(n) and can_slidejump(n))) and Castle_spiral_climb(n)) or
        (Hard(n) and (cling(n) or Getkicks(4) or (Getkicks(3) and breaker(n)) or (Getkicks(1) and sunsetter(n))) and Scythe_corridor(n)) or
        (Expert(n) and Castle_spiral_climb(n)) or
        (Expert(n) and (cling(n) or (slide(n) or Kickorplunge(2))) and Scythe_corridor(n))
end

function Scythe_corridor(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    return (Normal(n) and cling(n) and Castle_spiral_climb(n)) or
        (Normal(n) and (cling(n) or (can_slidejump(n) and Getkicks(1)) or Getkicks(4)) and Theatre_front(n)) or
        (Expert(n) and (cling(n) or Kickorplunge(4)) and Castle_spiral_climb(n)) or
        (Expert(n) and (cling(n) or slide(n) or Kickorplunge(2)) and Theatre_front(n)) or
        (Lunatic(n) and (cling(n) or Getkicks(3)) and Castle_spiral_climb(n)) or
        (Lunatic(n) and (cling(n) or slide(n) or Getkicks(3)) and Theatre_front(n))
end

function Theatre_front(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    return (Normal(n) and cling(n) and Kickorplunge(2) and Scythe_corridor(n)) or
        (Hard(n) and cling(n) and Scythe_corridor(n)) or
        (Expert(n) and (cling(n) or (slide(n) and Getkicks(2))) and Scythe_corridor(n)) or
        (Lunatic(n) and (cling(n) or (slide(n) and Kickorplunge(2))) and Scythe_corridor(n))
end

function Castle_moon_room(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    return (Normal(n) and (cling(n) or (can_slidejump(n) and Kickorplunge(2))) and Theatre_front(n)) or
        (Hard(n) and (cling(n) or (can_slidejump(n) and Kickorplunge(2)) or Getkicks(4)) and Theatre_front(n)) or
        (Expert(n) and (cling(n) or slide(n) or Getkicks(4)) and Theatre_front(n))
end

-- LOCATION LOGIC

function Floater_in_courtyard(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
    --print(outOflogic)
    --print(((can_bounce(n) and (Kickorplunge(1) or slide(n))) or (slide(n) and Getkicks(1)) or Getkicks(3) or cling(n)))
        return ((can_bounce(n) and (Kickorplunge(1) or slide(n))) or (slide(n) and Getkicks(1)) or Getkicks(3) or cling(n))
    end
    return (Normal(n) and ((can_bounce(n) and sunsetter(n)) or (can_bounce(n) and Getkicks(2)) or (cling(n) and Getkicks(2)) or (cling(n) and sunsetter(n)) or Getkicks(4))) or
        (Hard(n) and ((can_bounce(n) and sunsetter(n)) or (can_bounce(n) and Getkicks(1)) or Kickorplunge(4) or cling(n))) or
        (Expert(n) and ((can_bounce(n) and (Kickorplunge(1) or slide(n))) or (slide(n) and Getkicks(1)) or Getkicks(3) or cling(n)))
end

function Castle_locked_door(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return can_attack(n)
    end
    return (Normal(n) and (breaker(n) or (Knows_obscure(n) and can_attack(n)))) or
        (Expert(n) and can_attack(n))
end

function Castle_platform_main(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return (Kickorplunge(1) or cling(n) or slide(n) or can_bounce(n))
    end
    return (Normal(n) and (sunsetter(n) or cling(n) or Getkicks(2))) or
        (Hard(n) and (Kickorplunge(1) or cling(n))) or
        (Expert(n) and (Kickorplunge(1) or cling(n) or slide(n))) or
        (Lunatic(n) and (Kickorplunge(1) or cling(n) or slide(n) or can_bounce(n)))
end

function Castle_tall_room_wheel_crawlers(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return (cling(n) or Getkicks(1) or slide(n))
    end
    return (Normal(n) and (Getkicks(2) or (cling(n) and Kickorplunge(1)))) or
        (Hard(n) and (cling(n) or Getkicks(1) or (Knows_obscure(n) and can_slidejump(n) and sunsetter(n)))) or
        (Expert(n) and (cling(n) or Getkicks(1) or slide(n)))
end

function Castle_alcove_near_dungeon(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return (cling(n) or Kickorplunge(1) or slide(n))
    end
    return (Normal(n) and (Kickorplunge(2) or (cling(n) and Kickorplunge(1)))) or
        (Hard(n) and (cling(n) or Kickorplunge(1))) or
        (Expert(n) and (cling(n) or Kickorplunge(1) or slide(n)))
end

function Castle_balcony(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return (cling(n) or Getkicks(3) or (slide(n) or (sunsetter(n) and Getkicks(1))))
    end
    return (Normal(n) and (cling(n) or Kickorplunge(3) or (can_slidejump(n) and Kickorplunge(2)))) or
        (Hard(n) and (cling(n) or Kickorplunge(3) or (slide(n) and sunsetter(n)) or (slide(n) and Getkicks(1) and breaker(n)))) or
        (Expert(n) and (cling(n) or Getkicks(3) or (slide(n) or (sunsetter(n) and Getkicks(1)))))
end

function Castle_corner_corridor(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return (cling(n) or Getkicks(3) or (Getkicks(1) and slide(n)))
    end
    return (Normal(n) and (cling(n) or Getkicks(4))) or
        (Hard(n) and (cling(n) or Getkicks(3))) or
        (Expert(n) and (cling(n) or Getkicks(3) or (Getkicks(2) and slide(n)))) or
        (Lunatic(n) and (cling(n) or Getkicks(3) or (Getkicks(1) and slide(n))))
end

function Castle_wheel_crawler(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return (can_bounce(n) or cling(n) or Kickorplunge(1) or slide(1))
    end
    return (Normal(n) and (can_bounce(n) or cling(n) or (Getkicks(2) or (Getkicks(1) and can_slidejump(n))))) or
        (Hard(n) and (can_bounce(n) or cling(n) or Getkicks(1) or (can_slidejump(n) and sunsetter(n)) or (Knows_obscure(n) and sunsetter(n)))) or
        (Expert(n) and (can_bounce(n) or cling(n) or Kickorplunge(1) or slide(1)))
end

function Castle_alcove_scythe(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return (cling(n) or Kickorplunge(1))
    end
    return (Normal(n) and (Kickorplunge(4) or (cling(n) and Getkicks(1) and sunsetter(n)))) or
        (Hard(n) and (cling(n) or (Getkicks(2) and sunsetter(n)))) or
        (Expert(n) and (cling(n) or Kickorplunge(3) or (slide(n) and Kickorplunge(1)))) or
        (Lunatic(n) and (cling(n) or Kickorplunge(1)))
end

function Castle_theatre_front(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return (cling(n) or slide(n) or Getkicks(4) or (Getkicks(2) and sunsetter(n)))
    end
    return (Normal(n) and (Getkicks(4) or (Getkicks(2) and sunsetter(n)))) or
        (Hard(n) and (cling(n) or Getkicks(4) or (Getkicks(2) and sunsetter(n)))) or
        (Expert(n) and (cling(n) or slide(n) or Getkicks(4) or (Getkicks(2) and sunsetter(n))))
end

function Castle_courtyard_high_climb(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return (Getkicks(2) or cling(n) or slide(n) or (can_attack(n) and Getkicks(1)))
    end
    return (Normal(n) and (Getkicks(2) or (cling(n) and sunsetter(n)) or (breaker(n) and Getkicks(1)) or (Knows_obscure(n) and sunsetter(n) and Getkicks(1)))) or
        (Hard(n) and (Getkicks(2) or cling(n) or (sunsetter(n) and can_slidejump(n)) or (breaker(n) and Getkicks(1)) or (Knows_obscure(n) and sunsetter(n) and Getkicks(1)))) or
        (Expert(n) and (Getkicks(2) or cling(n) or slide(n) or (can_attack(n) and Getkicks(1))))
end