-- ap-style logic

-- set global DEBUG to true to get more output
-- DEBUG = true

-- TODO: use require; this will need a PopTracker update to make "nested" require() work better
ScriptHost:LoadScript("scripts/logic/rules.lua")
ScriptHost:LoadScript("scripts/logic/regions.lua") -- origin_region_names
ScriptHost:LoadScript("scripts/logic/helper.lua") -- load helper for AP-style logic
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

local isProgBreaker = false  -- caching here to avoid going through Tracker
local isProgSlide = false
local isSplitKicks = false
local isSplitCling = false

-- version helper
local v = {}
PopVersion:gsub("([^%.]+)", function(c) v[#v+1] = tonumber(c) end)
local hasAnyWatch = v[1] > 0 or v[2] > 25 or v[2] == 25 and v[3] > 4  -- available since 0.25.5

-- patch up State.has and State.count to match the codes
local _count = State.count

State.has = function(state, name)
    return state:count(name) > 0  -- use count to only implement the crazy mappings once
end

-- TODO (granular-logic)? this is probably really bad
local item_mapping = {
    breaker = {
        prog_code = function() return isProgBreaker and "breaker1" or "breaker" end,
    },
    strikebreak = {
        prog_code = function() return isProgBreaker and "breaker2" or "strikebreak" end,
    },
    cutter = {
        prog_code = function() return isProgBreaker and "breaker3" or "cutter" end,
    },
    slide = {
        prog_code = function() return isProgSlide and "slide1" or "slide" end,
    },
    slide_jump = {
        prog_code = function() return isProgSlide and "slide2" or "solar" end,
    },
    kick = {
        is_split = function() return isSplitKicks end,
        split = {
            {code = "splitkick"},
        },
        no_split = {
            {code = "greaves", count = 3},
            {code = "heliacal"},
        },
    },
    plunge = {
        code = "sunsetter",
    },
    kick_or_plunge = {
        is_split = function() return isSplitKicks end,
        split = {
            {code = "splitkick"},
            {code = "sunsetter"},
        },
        no_split = {
            {code = "greaves", count = 3},
            {code = "heliacal"},
            {code = "sunsetter"},
        },
    },
    cling = {
        is_split = function() return isSplitCling end,
        split = {
            {code = "clingshard"},
        },
        no_split = {
            {code = "cling", count = 6},
        },
    },
    light = {
        code = "ascendant",
    },
    small_key = {
        code = "smallkey",
    },
    major_key = {
        code = "majorkey",
    },
}

State.count = function(state, name)
    local mapping = item_mapping[name]
    if not mapping then
        if DEBUG then
            print("Unknown item " .. name)
        end
        return _count(state, name)
    end

    if mapping.prog_code then
        return _count(state, mapping.prog_code())
    end

    if mapping.is_split then
        local code_list = mapping.is_split() and mapping.split or mapping.no_split
        local count = 0
        for i = 1,#code_list do
            local code_data = code_list[i]
            count = count + _count(state, code_data.code) * (code_data.count or 1)
        end
        return count
    end

    return _count(state, mapping.code)
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
    glitchDef:set_options(pseudoregalia_options, {logic_level = difficulties.LUNATIC, obscure_logic = 1})
end

function _create_regions(definition)
    definition.regions:clear()  -- allow running _create_regions multiple times

    if definition.options.spawn_point then
        definition.origin_region_name = regions.origin_region_names[definition.options.spawn_point.value]
    end

    for i = 1,#rules.pseudoregalia_data.regions do
        local region_data = rules.pseudoregalia_data.regions[i]
        definition.regions:append(Region:new(region_data.name, definition))
    end

    for i = 1,#rules.pseudoregalia_data.locations do
        local location_data = rules.pseudoregalia_data.locations[i]
        local region = definition:get_region(location_data.region)
        local rule
        if rules.location_rules[location_data.name] then
            rule = rules.location_rules[location_data.name]:resolve(definition)
        end
        local location = Location:new(location_data.name, region, rule)
        region.locations:append(location)
    end

    for i = 1,#rules.pseudoregalia_data.regions do
        local region_data = rules.pseudoregalia_data.regions[i]
        if not region_data.exits then goto continue end

        local region = definition:get_region(region_data.name)
        for j = 1,#region_data.exits do
            local exit_data = region_data.exits[j]
            local exit_region = definition:get_region(exit_data.region)
            local entrance_name = rules.create_entrance_name(region.name, exit_region.name, exit_data.entrance_name)
            local rule
            if rules.entrance_rules[entrance_name] then
                rule = rules.entrance_rules[entrance_name]:resolve(definition)
            end
            region:connect(exit_region, entrance_name, rule)
        end
        ::continue::
    end
end

function create_regions()
    _create_regions(def)
    _create_regions(glitchDef)
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

function logicChanged()  -- run by watch for code "ultra_cap", "logic", "obscure"
    print("logic changed")
    isSplitKicks = Tracker:ProviderCountForCode("op_splitkick_on") > 0  -- cache for State.count
    isSplitCling = Tracker:ProviderCountForCode("op_splitcling_on") > 0  -- cache for State.count
    set_options()  -- update world option emulation
    create_regions()  -- recreate rules with new code(s) in Tracker
    state.stale = true
    glitchState.stale = true
end

function progLogicChanged()  -- run by watch for code "op_progbreaker", "op_progslide"
    -- cache prog breaker/slide into variable for faster access
    isProgBreaker = Tracker:ProviderCountForCode("op_progbreaker") > 0
    isProgSlide = Tracker:ProviderCountForCode("op_progslide") > 0
end

-- initialize logic
logicChanged()

-- add watches
ScriptHost:AddWatchForCode("ultraCapChanged", "ultra_cap", logicChanged)
ScriptHost:AddWatchForCode("difficultyChanged", "logic", logicChanged)
ScriptHost:AddWatchForCode("spawnChanged", "spawn", logicChanged)
ScriptHost:AddWatchForCode("obscureChanged", "obscure", logicChanged)
ScriptHost:AddWatchForCode("splitSunGreavesChanged", "op_splitkick_on", logicChanged)
ScriptHost:AddWatchForCode("splitClingGemChanged", "op_splitcling_on", logicChanged)
ScriptHost:AddWatchForCode("progBreakerLogicChanged", "op_progbreaker", progLogicChanged)
ScriptHost:AddWatchForCode("progSlideLogicChanged", "op_progslide", progLogicChanged)
if hasAnyWatch then
    ScriptHost:AddWatchForCode("stateChanged", "*", stateChanged)
end
