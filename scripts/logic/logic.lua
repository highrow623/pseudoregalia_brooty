-- ap-style logic
-- TODO: use require; this will need a PopTracker update to make "nested" require() work better
ScriptHost:LoadScript("scripts/logic/helper.lua") -- load helper for AP-style logic
ScriptHost:LoadScript("scripts/logic/locations.lua") -- load location_table
ScriptHost:LoadScript("scripts/logic/regions.lua") -- load region_table
ScriptHost:LoadScript("scripts/logic/rules/base.lua") -- load PseudoregaliaRulesHelpers
ScriptHost:LoadScript("scripts/logic/rules/normal.lua") -- load PseudoregaliaNormalRules
ScriptHost:LoadScript("scripts/logic/rules/hard.lua") -- load PseudoregaliaHardRules
ScriptHost:LoadScript("scripts/logic/rules/expert.lua") -- load PseudoregaliaExpertRules
ScriptHost:LoadScript("scripts/logic/rules/lunatic.lua") -- load PseudoregaliaLunaticRules
ScriptHost:LoadScript("scripts/logic/constants.lua")
ScriptHost:LoadScript("scripts/logic/options.lua")

-- shorthand names from imports
local Definition = helper.Definition
local State = helper.State
local Region = helper.Region
local Location = helper.Location
local difficulties = constants.difficulties
local pseudoregalia_options = options.pseudoregalia_options

-- state and world definition variables
local def = Definition:new()  -- "world" definition for logic
local state = State:new(def)  -- TODO: add caching and update in watch for code
local glitchDef = Definition:new()  -- "world" definition for out-of-logic
local glitchState = State:new(glitchDef)  -- TODO: add caching and update in watch for code

DEBUG = true

-- version helper
local v = {}
PopVersion:gsub("([^%.]+)", function(c) v[#v+1] = tonumber(c) end)
local hasAnyWatch = v[1] > 0 or v[2] > 25 or v[2] == 25 and v[3] > 4

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
State.has = function(state, name)
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
State.count = function(state, name)
    local code = codes[name]
    if code then
        return _count(state, code)
    else
        return _count(state, name)
    end
end


-- logic resolvers (called from json locations)


function can_reach(location_name)
    if not hasAnyWatch then
        state.stale = true
    end
    return def:get_location(location_name):can_reach(state)
end

function can_glitch(location_name)
    if not hasAnyWatch then
        glitchState.stale = true
    end
    return glitchDef:get_location(location_name):can_reach(glitchState)
end


-- logic init (called to init/update def and state for logic and out-of-logic)


function set_options()
    def:set_options(pseudoregalia_options)
    glitchDef:set_options(pseudoregalia_options)
end

function _create_regions(def)
    def.regions:clear()  -- allow running _create_regions multiple times

    for region_name, _ in pairs(region_table) do
        def.regions:append(Region:new(region_name, def))
    end

    for loc_name, loc_data in pairs(location_table) do
        -- if not loc_data.can_create() ...
        local region = def:get_region(loc_data.region)
        local new_loc = Location:new(loc_name, loc_data.code, region)
        region.locations:append(new_loc)
    end

    for region_name, exit_list in pairs(region_table) do
        local region = def:get_region(region_name)
        region:add_exits(exit_list)
    end

    -- locked items
    -- TODO: events if it uses events
end

function create_regions()
    _create_regions(def)
    _create_regions(glitchDef)
end

function set_rules()
    -- set_pseudoregalia_rules does not rewrite everything, so we have to recreate locations
    _create_regions(def)
    -- set rules depending on logic (and other options)
    local difficulty = def.options.logic_level.value  -- .value because lua can't override __eq for number
    if difficulty == difficulties.NORMAL then
        print("Setting difficulty to normal")
        PseudoregaliaNormalRules:new(def):set_pseudoregalia_rules()
    elseif difficulty == difficulties.HARD then
        print("Setting difficulty to hard")
        PseudoregaliaHardRules:new(def):set_pseudoregalia_rules()
    elseif difficulty == difficulties.EXPERT then
        print("Setting difficulty to expert")
        PseudoregaliaExpertRules:new(def):set_pseudoregalia_rules()
    elseif difficulty == difficulties.LUNATIC then
        print("Setting difficulty to lunatic")
        PseudoregaliaLunaticRules:new(def):set_pseudoregalia_rules()
    else
        error("Unknown difficulty " .. tostring(difficulty.value))
    end
    PseudoregaliaLunaticRules:new(glitchDef):set_pseudoregalia_rules()
end

function stateChanged(code)  -- run by watch for code "*" (any)
    if DEBUG then
        if code ~= "obscure" and code:find("^logic") == nil then
            print(code .. " changed")
        end
    end
    state.stale = true
    glitchState.stale = true
end

function logicChanged()  -- run by watch for code "logic", "obscure"
    print("logic changed")
    set_options()  -- update world option emulation
    set_rules()  -- recreate rules with new code(s) in Tracker
    state.stale = true
    glitchState.stale = true
end

-- initialize logic
create_regions()  -- TODO: this depends on progressive options, so we need another watch for code
logicChanged()

-- add watches
ScriptHost:AddWatchForCode("difficultyChanged", "logic", logicChanged)
ScriptHost:AddWatchForCode("obscureChanged", "obscure", logicChanged)
if hasAnyWatch then
    ScriptHost:AddWatchForCode("stateChanged", "*", stateChanged)
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
