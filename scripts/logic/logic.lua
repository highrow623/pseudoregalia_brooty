-- ap-style logic
-- TODO: use require
ScriptHost:LoadScript("scripts/logic/helper.lua") -- load helper for AP-style logic
ScriptHost:LoadScript("scripts/logic/locations.lua") -- load location_table
ScriptHost:LoadScript("scripts/logic/regions.lua") -- load region_table
ScriptHost:LoadScript("scripts/logic/rules/base.lua") -- load PseudoregaliaRulesHelpers
ScriptHost:LoadScript("scripts/logic/rules/normal.lua") -- load PseudoregaliaNormalRules
ScriptHost:LoadScript("scripts/logic/rules/hard.lua") -- load PseudoregaliaHardRules
ScriptHost:LoadScript("scripts/logic/rules/expert.lua") -- load PseudoregaliaExpertRules
ScriptHost:LoadScript("scripts/logic/rules/lunatic.lua") -- load PseudoregaliaLunaticRules
-- TODO: normal, hard, expert, lunatic rules
-- TODO: init to set up locations, regions and rules


local def = Definition:new()
local state = State:new(def) -- TODO: add caching and update in watch for code


-- item name to code mapping
local codes = {
    ["Dream Breaker"] = "breaker",
    ["Sun Greaves"] = "greaves",
    ["Slide"] = "slide",
    ["Solar Wind"] = "solar",
    ["Sunsetter"] = "sunsetter",
    ["Strikebreak"] = "strikebreak",
    ["Cling Gem"] = "cling",
    ["Ascendant Light"] = "ascendant",
    ["Soul Cutter"] = "cutter",
    ["Heliacal Power"] = "heliacal",
    ["Small Key"] = "smallkey",
    ["Major Key - Empty Bailey"] = "majorkey",
    ["Major Key - The Underbelly"] = "majorkey",
    ["Major Key - Tower Remains"] = "majorkey",
    ["Major Key - Sansa Keep"] = "majorkey",
    ["Major Key - Twilight Theatre"] = "majorkey",
}

-- patch up State.has to match the codes
local _has = getmetatable(state).has
getmetatable(state).has = function(state, name)
    local code = codes[name]
    if code then
        return _has(state, code)
    else
        -- TODO: warn?
        return _has(state, name)
    end
end
-- patch up State.count to match the codes
local _count = getmetatable(state).count
getmetatable(state).count = function(state, name)
    local code = codes[name]
    if code then
        return _count(state, code)
    else
        return _count(state, name)
    end
end

function can_reach(location_name, out_of_logic)
    if out_of_logic then
        --return true -- TODO: return logic for lunatic
    end
    state.stale = true
    return def:get_location(location_name):can_reach(state)
end

function can_glitch(location_name)
    return can_reach(location_name, true)
end

function dump(o, level)
    level = level or 0
    if level > 10 then
        return "F"
    end
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v, level + 1) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end
 
--print(dump(def))
--print(dump(def.regions))
--print(dump(getmetatable(def.regions)))

function create_regions()
    for region_name, _ in pairs(region_table) do
        def.regions:append(Region:new(region_name, def))
    end

    for loc_name, loc_data in pairs(location_table) do
        -- if not loc_data.can_create() ...
        region = def:get_region(loc_data.region)
        new_loc = Location:new(loc_name, loc_data.code, region)
        region.locations:append(new_loc)
    end

    for region_name, exit_list in pairs(region_table) do
        region = def:get_region(region_name)
        region:add_exits(exit_list)
    end

    -- locked items
    -- TODO: events if it uses events
end

function set_rules()
    -- TODO: difficulty
    -- TODO: setup difficulty toggles/addwatch for codes normal, hard, expert, lunatic
    PseudoregaliaNormalRules:new(def):set_pseudoregalia_rules()
    PseudoregaliaHardRules:new(def):set_pseudoregalia_rules()
    PseudoregaliaExpertRules:new(def):set_pseudoregalia_rules()
    PseudoregaliaLunaticRules:new(def):set_pseudoregalia_rules()
end

create_regions()
set_rules()


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
