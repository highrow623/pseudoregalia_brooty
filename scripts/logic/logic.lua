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
    return has("breaker") or has("breaker1")
end

function greaves(n)
    return has("greaves")
end

function slide(n)
    return has("slide") or has("slide1")
end

function solar(n)
    return has("solar") or has("slide2")
end

function sunsetter(n)
    return has("sunsetter")
end

function strikebreak(n)
    return has("strikebreak") or has("breaker2")
end

function cling(n)
    return has("cling")
end

function ascendant(n)
    return has("ascendant")
end

function cutter(n)
    return has("cutter") or has("breaker3")
end

function heliacal(n)
    return Tracker:ProviderCountForCode("heliacal")
end

function progkick(n)
    return Tracker:ProviderCountForCode("airkick")
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
    return has("smallkey",7)
end

function can_bounce(n)
    -- print("can_bounce")
    return breaker(n) and ascendant(n)
end

--function more_kicks(n)
    -- print("more_kicks")
    --return greaves(n) and heliacal(n)
--

function can_slidejump(n)
    -- print("can_slidejump")
    return (slide(n) and solar(n)) or has("slide2")
end

function navigate_darkrooms(n)
    -- print("navigate_darkrooms")
    return (breaker(n) or ascendant(n))
end

function can_strikebreak(n)
    -- print("can_strikebreak")
    return (breaker(n) and strikebreak(n)) or has("breaker2")
end

function can_soulcutter(n)
    -- print("can_soulcutter")
    return (breaker(n) and strikebreak(n) and cutter(n)) or has("breaker3")
end

function can_sunsetter(n)
    -- print("can_sunsetter")
    return breaker(n) and sunsetter(n)
end

function can_attack(n)
    -- print("can_sunsetter")
    return breaker(n) or sunsetter(n)
end

function Kickorplunge(count, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    local total = 0
    if has("greaves") then
      total = total + 3
    end
    if has("sunsetter") then
      total = total + 1
    end
    total = total + heliacal() --see note
    total = total + progkick() --see note
    count = tonumber(count)
    return (total >= count)
  end

function Getkicks(count, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    local kicks = 0
    if has("greaves") then
        kicks = kicks + 3
    end
    kicks = kicks + heliacal()
    kicks = kicks + progkick()
    count = tonumber(count)
    return (kicks >= count)
end

-- Region functions
-- Dungeon
function dungeon_mirror(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    --print("dungeon_mirror")
    return breaker(n)
end

function dungeon_strong_eyes(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return (slide(n) and breaker(n)) or (has("smallkey",1) and (empty_bailey(n) or Castle_spiral_climb(n)) and dungeon_mirror(n))
    end
    --print("dungeon_strong_eyes")
    return (slide(n) and dungeon_mirror(n)) or (has_small_keys(n) and (empty_bailey(n) or Castle_spiral_climb(n)) and dungeon_mirror(n))
end

-- Underbelly
function underbelly_main(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    --print("underbelly_main")
    return breaker(n) or (sunsetter(n) and (tower_remains(n) or underbelly_hole(n)))
end

function underbelly_hole(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    --print("underbelly_hole")
    return Kickorplunge(1) and ((cling(n) and theatre_main(n)) or ((has_small_keys(n) and dungeon_strong_eyes(n)) or Castle_spiral_climb(n)))
    --return Kickorplunge(1) and keep_main(n)
end

-- Theatre
function theatre_main(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    --print("theatre_main")
    return (cling(n) and (Getkicks(3) or can_slidejump(n)) and dungeon_mirror(n)) or
        (cling(n) and (Getkicks(3) or can_slidejump(n)) and ((has_small_keys(n) and dungeon_strong_eyes(n)) or ((sunsetter(n) or breaker(n)) and (breaker(n) or (sunsetter(n) and tower_remains(n)))) or Castle_spiral_climb(n))) or -- castle_sansa() = reduced keep_main() rule, and then reduced castle_sansa more to help more recurssions
        ((sunsetter(n) and cling(n)) or (sunsetter(n) and Getkicks(4)) and theatre_pillar(n)) or
        Theatre_front(n)
end

function theatre_pillar(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    --print("theatre_pillar")
    return (empty_bailey(n)) or (Normal(n) and (Kickorplunge(2) or (cling(n) and Kickorplunge(1))) and castle_sansa(n)) or
        (Hard(n) and (cling(n) or (Kickorplunge(1))) and castle_sansa(n)) or
        ((Expert(n) or Lunatic(n)) and (cling(n) or slide(n) or Kickorplunge(1)) and castle_sansa(n))
end

-- Library
function library_main(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return can_attack(n) and castle_sansa(n)
    end
    --print("library_main")
    return (Normal(n) and (breaker(n) or (Knows_obscure(n) and can_attack(n))) and castle_sansa(n)) or
        (Expert(n) and can_attack(n) and castle_sansa(n))
end

function library_locked(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return (has("smallkey",1) and library_main(n))
    end
    --print("library_locked")
    return (Normal(n) and has_small_keys(n) and library_main(n))
end

function library_greaves(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return (cling(n) or Getkicks(2) or (can_bounce(n) and Getkicks(1) and sunsetter(n))) and library_top(n)
    end
    --print("library_greaves")
    return (Normal(n) and slide(n) and library_main(n)) or
        (Normal(n) and ((cling(n) and Kickorplunge(1)) or (Getkicks(3) and sunsetter(n)) or Getkicks(3) and can_bounce(n)) and library_top(n)) or
        (Hard(n) and (cling(n) or Getkicks(3) or (Getkicks(2) and sunsetter(n) and can_bounce(n))) and library_top(n)) or
        (Expert(n) and (cling(n) or Getkicks(2)) and library_top(n)) or
        (Lunatic(n) and (cling(n) or Getkicks(2) or (can_bounce(n) and Getkicks(1) and sunsetter(n))) and library_top(n))
end

function library_top(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return ((cling(n) or (Kickorplunge(2) or slide(n))) and library_main(n)) or
        (cling(n) or (Getkicks(1) or slide(n))) and slide(n) and library_main(n)
    end
    --print("library_top")
    return (Normal(n) and (Kickorplunge(4) or (Knows_obscure(n) and Getkicks(1) and sunsetter(n))) and library_main(n)) or
        (Normal(n) and (cling(n) or (Getkicks(2))) and slide(n) and library_main(n)) or -- reduced library_greaves for recurssions
        (Hard(n) and (cling(n) or Kickorplunge(4) or (Knows_obscure(n) and Kickorplunge(2))) and library_main(n)) or
        (Hard(n) and (cling(n) or (Getkicks(1))) and slide(n) and library_main(n)) or -- reduced library_greaves for recurssions
        (Expert(n) and (cling(n) or (Kickorplunge(2) or slide(n))) and library_main(n)) or
        (Expert(n) and (cling(n) or (Getkicks(1) or slide(n))) and slide(n) and library_main(n)) -- reduced library_greaves for recurssions
end

-- Keep
function keep_main(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    --print("keep_main")
    return (cling(n) and theatre_main(n)) or castle_sansa(n)
end

function keep_sunsetter(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    --print("keep_sunsetter")
    return (cling(n) or has_small_keys(n) or greaves(n)) and keep_main(n)
end

-- Bailey
function empty_bailey(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    --print("empty_bailey")
    return (sunsetter(n) or breaker(n)) and (breaker(n) or (sunsetter(n) and underbelly_hole(n))) -- reduced underbelly_main to `breaker(n) or (sunsetter(n) and (tower_remains(n) or underbelly_hole(n)))` and then removed the 'tower_remains' to help eliminate recurssions
    --return (sunsetter(n) or breaker(n)) and underbelly_main(n)
end

-- Tower
function tower_remains(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    --print("tower_remains")
    return (cling(n) or Getkicks(1) or (slide(n) and sunsetter(n))) and empty_bailey(n)
end

function the_great_door(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    --print("the_great_door")
    return cling(n) and Getkicks(3) and tower_remains(n)
end

-- Castle
function castle_sansa(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return (has("smallkey",1) and dungeon_strong_eyes(n)) or empty_bailey(n) or Castle_spiral_climb(n)
    end
    --print("castle_sansa")
    return (has_small_keys(n) and dungeon_strong_eyes(n)) or empty_bailey(n) or Castle_spiral_climb(n)
end

function Castle_spiral_climb(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    --print("Castle_spiral_climb")
    return (Normal(n) and (Getkicks(2) or (cling(n) and sunsetter(n))) and ((has_small_keys(n) and dungeon_strong_eyes(n)) or empty_bailey(n))) or -- reduced castle_sansa
        (Normal(n) and (cling(n) or (Getkicks(4) and sunsetter(n))) and Scythe_corridor(n)) or 
        (Hard(n) and (cling(n) or Kickorplunge(2) or (can_slidejump(n) and sunsetter(n))) and ((has_small_keys(n) and dungeon_strong_eyes(n)) or empty_bailey(n))) or -- reduced castle_sansa
        (Hard(n) and (cling(n) or Getkicks(3)) and Scythe_corridor(n)) or
        (Expert(n) and (cling(n) or slide(n) or Kickorplunge(2)) and ((has_small_keys(n) and dungeon_strong_eyes(n)) or empty_bailey(n))) -- reduced castle_sansa
end

function Castle_high_climb(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    --print("Castle_high_climb")
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
    --print("Scythe_corridor")
    return (Normal(n) and cling(n) and Castle_spiral_climb(n)) or
        (Normal(n) and (cling(n) or (can_slidejump(n) and Getkicks(1)) or Getkicks(4)) and Theatre_front(n)) or
        (Expert(n) and (cling(n) or Kickorplunge(4)) and Castle_spiral_climb(n)) or
        (Expert(n) and (cling(n) or slide(n) or Kickorplunge(2)) and Theatre_front(n)) or
        (Lunatic(n) and (cling(n) or Getkicks(3)) and Castle_spiral_climb(n)) or
        (Lunatic(n) and (cling(n) or slide(n) or Getkicks(3)) and Theatre_front(n))
end

--function Theatre_front(n)
    --if n == nil then; n = 0; end
    --if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    --n = n + 1
    --return (Normal(n) and cling(n) and Kickorplunge(2) and Scythe_corridor(n)) or
        --(Hard(n) and cling(n) and Scythe_corridor(n)) or
        --(Expert(n) and (cling(n) or (slide(n) and Getkicks(2))) and Scythe_corridor(n)) or
        --(Lunatic(n) and (cling(n) or (slide(n) and Kickorplunge(2))) and Scythe_corridor(n))
--end

function Theatre_front(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    --print("Theatre_front")
    return (Normal(n) and cling(n) and Kickorplunge(2) and ((Normal(n) and cling(n) and Castle_spiral_climb(n)) or -- "reduced" Scythe_corridor to help with recurssions. see old code above
            (Expert(n) and (cling(n) or Kickorplunge(4)) and Castle_spiral_climb(n)) or
            (Lunatic(n) and (cling(n) or Getkicks(3)) and Castle_spiral_climb(n)))) or
        (Hard(n) and cling(n) and ((Normal(n) and cling(n) and Castle_spiral_climb(n)) or -- "reduced" Scythe_corridor to help with recurssions. see old code above
            (Expert(n) and (cling(n) or Kickorplunge(4)) and Castle_spiral_climb(n)) or
            (Lunatic(n) and (cling(n) or Getkicks(3)) and Castle_spiral_climb(n)))) or
        (Expert(n) and (cling(n) or (slide(n) and Getkicks(2))) and ((Normal(n) and cling(n) and Castle_spiral_climb(n)) or -- "reduced" Scythe_corridor to help with recurssions. see old code above
            (Expert(n) and (cling(n) or Kickorplunge(4)) and Castle_spiral_climb(n)) or
            (Lunatic(n) and (cling(n) or Getkicks(3)) and Castle_spiral_climb(n)))) or
        (Lunatic(n) and (cling(n) or (slide(n) and Kickorplunge(2))) and ((Normal(n) and cling(n) and Castle_spiral_climb(n)) or -- "reduced" Scythe_corridor to help with recurssions. see old code above
            (Expert(n) and (cling(n) or Kickorplunge(4)) and Castle_spiral_climb(n)) or
            (Lunatic(n) and (cling(n) or Getkicks(3)) and Castle_spiral_climb(n))))
end

function Castle_moon_room(n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    --print("Castle_moon_room")
    return (Normal(n) and (cling(n) or (can_slidejump(n) and Kickorplunge(2))) and Theatre_front(n)) or
        (Hard(n) and (cling(n) or (can_slidejump(n) and Kickorplunge(2)) or Getkicks(4)) and Theatre_front(n)) or
        (Expert(n) and (cling(n) or slide(n) or Getkicks(4)) and Theatre_front(n))
end

-- LOCATION LOGIC
-- DUNGEON // NO FUNCTIONS FOR 'DREAM BREAKER', 'SLIDE', AND 'ALCOVE NEAR MIRROR'
function dungeon_dark_orbs(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return (cling(n) or (Getkicks(1) and can_bounce(n)) or (Getkicks(3) and sunsetter(n)) or (slide(n) and Getkicks(1)) or (slide(n) and can_bounce(n)))
    end
    return (Normal(n) and ((cling(n) and can_bounce(n)) or (cling(n) and Kickorplunge(3)) or (Getkicks(2) and can_bounce(n)) or (can_slidejump(n) and Getkicks(1) and can_bounce(n)))) or
        (Hard(n) and (cling(n) or (Getkicks(1) and can_bounce(n)) or (can_slidejump(n) and sunsetter(n) and can_bounce(n)) or (Getkicks(3) and sunsetter(n)))) or
        (Expert(n) and (cling(n) or (Getkicks(1) and can_bounce(n)) or (Getkicks(3) and sunsetter(n)) or (slide(n) and Getkicks(1)) or (slide(n) and can_bounce(n))))
end

function dungeon_rafters(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return (cling(n) or Kickorplunge(2) or (can_bounce(n) and Kickorplunge(1)) or slide(n))
    end
    return (Normal(n) and (Kickorplunge(3) or (Knows_obscure(n) and can_bounce(n) and cling(n)))) or
        (Hard(n) and (cling(n) or Getkicks(3) or (Getkicks(1) and sunsetter(n)) or (Getkicks(1) and can_bounce(n)))) or
        (Expert(n) and (cling(n) or Kickorplunge(2) or (can_bounce(n) and Getkicks(1)) or (slide(n) and Kickorplunge(1)))) or
        (Lunatic(n) and (cling(n) or Kickorplunge(2) or (can_bounce(n) and Kickorplunge(1)) or slide(n)))
end

function strong_eyes_in_dungeon(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return (breaker(n) or cling(n) or (slide(n) and Kickorplunge(1)))
    end
    return (Normal(n) and (breaker(n) or (Knows_obscure(n) and ((cling(n) and Getkicks(1) and sunsetter(n)) or (cling(n) and Getkicks(3)))))) or
        (Hard(n) and (breaker(n) or (Knows_obscure(n) and cling(n) and Kickorplunge(2)))) or
        (Expert(n) and (breaker(n) or cling(n) or (slide(n) and Getkicks(1)))) or
        (Lunatic(n) and (breaker(n) or cling(n) or (slide(n) and Kickorplunge(1))))
end

function dungeon_past_poles(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return (cling(n) or Getkicks(2) or (slide(n) and Getkicks(1) and sunsetter(n)))
    end
    return (Normal(n) and (Getkicks(3) or (cling(n) and Kickorplunge(1)))) or
        (Hard(n) and (cling(n) or Getkicks(2))) or
        (Lunatic(n) and (cling(n) or Getkicks(2) or (slide(n) and Getkicks(1) and sunsetter(n))))
end

-- CASTLE
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

-- LISTLESS LIBRARY
function library_sun_greaves(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return can_attack(n)
    end
    return (Normal(n) and (breaker(n) or (Knows_obscure(n) and sunsetter(n)))) or
        (Expert(n) and can_attack(n))
end

function library_upper_back(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return (breaker(n) or (Knows_obscure(n) and sunsetter(n))) and (cling(n) or Kickorplunge(2) or slide(n))
    end
    return (Normal(n) and (breaker(n) or (Knows_obscure(n) and sunsetter(n))) and ((cling(n) and Kickorplunge(1)) or Kickorplunge(2))) or
        (Hard(n) and (breaker(n) or (Knows_obscure(n) and sunsetter(n))) and (cling(n) or Kickorplunge(2))) or
        (Expert(n) and (breaker(n) or (Knows_obscure(n) and sunsetter(n))) and (cling(n) or Kickorplunge(2) or slide(n)))
end

function library_locked_across(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return (cling(n) or Kickorplunge(1) or slide(n))
    end
    return (Normal(n) and (cling(n) or Getkicks(1) or can_slidejump(n))) or
        (Hard(n) and (cling(n) or Kickorplunge(1) or can_slidejump(n))) or
        (Expert(n) and (cling(n) or Kickorplunge(1) or slide(n)))
end

function library_locked_left(outOflogic, n)
    if n == nil then; n = 0; end
    if n > 10 then; return false; end -- detect 10th step when trying to resolve and abort
    n = n + 1
    if outOflogic then
        return (cling(n) or Kickorplunge(2) or (slide(n) and Kickorplunge(1)))
    end
    return (Normal(n) and (cling(n) or Kickorplunge(3) or (can_slidejump(n) and Getkicks(1)))) or
        (Expert(n) and (cling(n) or Kickorplunge(2) or (slide(n) and Kickorplunge(1))))
end

-- LAYOUT SWITCHING
function apLayoutChange1()
    local progBreaker = Tracker:FindObjectForCode("progbreakerLayout")
    if (string.find(Tracker.ActiveVariantUID, "standard")) then
        if progBreaker.Active then
            Tracker:AddLayouts("layouts/items_only_progbreaker.json")
            --Tracker:AddLayouts("layouts/broadcast_horizontal_AP.json") -- ADD LATER
        else
            Tracker:AddLayouts("layouts/items_standard.json")
        end
    end
end

function apLayoutChange2()
    local progSlide = Tracker:FindObjectForCode("progslideLayout")
    if (string.find(Tracker.ActiveVariantUID, "standard")) then
        if progSlide.Active then
            Tracker:AddLayouts("layouts/items_only_progslide.json")
            --Tracker:AddLayouts("layouts/broadcast_horizontal_AP.json") -- ADD LATER
        else
            Tracker:AddLayouts("layouts/items_standard.json")
        end
    end
end

function apLayoutChange3()
    local splitKick = Tracker:FindObjectForCode("splitkickLayout")
    if (string.find(Tracker.ActiveVariantUID, "standard")) then
        if splitKick.Active then
            Tracker:AddLayouts("layouts/items_only_splitkick.json")
            --Tracker:AddLayouts("layouts/broadcast_horizontal_AP.json") -- ADD LATER
        else
            Tracker:AddLayouts("layouts/items_standard.json")
        end
    end
end

function apLayoutChange4()
    local progBprogS = Tracker:FindObjectForCode("progbreakerprogslideLayout")
    if (string.find(Tracker.ActiveVariantUID, "standard")) then
        if progBprogS.Active then
            Tracker:AddLayouts("layouts/items_progbreaker_and_progslide.json")
            --Tracker:AddLayouts("layouts/broadcast_horizontal_AP.json") -- ADD LATER
        else
            Tracker:AddLayouts("layouts/items_standard.json")
        end
    end
end

function apLayoutChange5()
    local progBsplitK = Tracker:FindObjectForCode("progbreakersplitkickLayout")
    if (string.find(Tracker.ActiveVariantUID, "standard")) then
        if progBsplitK.Active then
            Tracker:AddLayouts("layouts/items_progbreaker_and_splitkick.json")
            --Tracker:AddLayouts("layouts/broadcast_horizontal_AP.json") -- ADD LATER
        else
            Tracker:AddLayouts("layouts/items_standard.json")
        end
    end
end

function apLayoutChange6()
    local progSsplitK = Tracker:FindObjectForCode("progslidesplitkickLayout")
    if (string.find(Tracker.ActiveVariantUID, "standard")) then
        if progSsplitK.Active then
            Tracker:AddLayouts("layouts/items_progslide_and_splitkick.json")
            --Tracker:AddLayouts("layouts/broadcast_horizontal_AP.json") -- ADD LATER
        else
            Tracker:AddLayouts("layouts/items_standard.json")
        end
    end
end

function apLayoutChange7()
    local progBSsplitK = Tracker:FindObjectForCode("progsandsplitLayout")
    if (string.find(Tracker.ActiveVariantUID, "standard")) then
        if progBSsplitK.Active then
            Tracker:AddLayouts("layouts/items_progs_and_split.json")
            --Tracker:AddLayouts("layouts/broadcast_horizontal_AP.json") -- ADD LATER
        else
            Tracker:AddLayouts("layouts/items_standard.json")
        end
    end
end
  
ScriptHost:AddWatchForCode("useApLayout1", "progbreakerLayout", apLayoutChange1)
ScriptHost:AddWatchForCode("useApLayout2", "progslideLayout", apLayoutChange2)
ScriptHost:AddWatchForCode("useApLayout3", "splitkickLayout", apLayoutChange3)
ScriptHost:AddWatchForCode("useApLayout4", "progbreakerprogslideLayout", apLayoutChange4)
ScriptHost:AddWatchForCode("useApLayout5", "progbreakersplitkickLayout", apLayoutChange5)
ScriptHost:AddWatchForCode("useApLayout6", "progslidesplitkickLayout", apLayoutChange6)
ScriptHost:AddWatchForCode("useApLayout7", "progsandsplitLayout", apLayoutChange7)
