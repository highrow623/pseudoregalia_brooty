-- ap-style logic

-- set global DEBUG to true to get more output
-- DEBUG = true

-- TODO: use require; this will need a PopTracker update to make "nested" require() work better
ScriptHost:LoadScript("scripts/logic/helper.lua") -- load helper for AP-style logic
ScriptHost:LoadScript("scripts/logic/constants.lua")
ScriptHost:LoadScript("scripts/logic/options.lua")
ScriptHost:LoadScript("scripts/logic/locations.lua") -- load location_table
ScriptHost:LoadScript("scripts/logic/regions.lua") -- load region_table
ScriptHost:LoadScript("scripts/logic/rules/base.lua") -- load PseudoregaliaRulesHelpers
ScriptHost:LoadScript("scripts/logic/rules/normal.lua") -- load PseudoregaliaNormalRules
ScriptHost:LoadScript("scripts/logic/rules/hard.lua") -- load PseudoregaliaHardRules
ScriptHost:LoadScript("scripts/logic/rules/expert.lua") -- load PseudoregaliaExpertRules
ScriptHost:LoadScript("scripts/logic/rules/lunatic.lua") -- load PseudoregaliaLunaticRules

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

-- version helper
local v = {}
PopVersion:gsub("([^%.]+)", function(c) v[#v+1] = tonumber(c) end)
local hasAnyWatch = v[1] > 0 or v[2] > 25 or v[2] == 25 and v[3] > 4  -- available since 0.25.5

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
local _has = State.has
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
local _count = State.count
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
    glitchDef:set_options(pseudoregalia_options, {logic_level = difficulties.LUNATIC})
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
