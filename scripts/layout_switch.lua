-- LAYOUT SWITCHING
-- change layout depending on options

local currentLayoutNum = 1  -- standard

function updateLayout()
    if pauseLayoutUpdate then  -- global set from AP autotracking to pause updating
        return  -- update deferred
    end
    -- read toggles
    local progBreaker = Tracker:ProviderCountForCode("op_progbreaker") > 0
    local progSlide = Tracker:ProviderCountForCode("op_progslide") > 0
    local splitKicks = Tracker:ProviderCountForCode("op_splitkick_on") > 0
    local splitClings = Tracker:ProviderCountForCode("op_splitcling_on") > 0
    -- encode 4 toggles into a 4 bit integer (16 states), +1 for Lua array starting at 1
    local layoutNum = 1 + (progBreaker and 1 or 0) + (progSlide and 2 or 0) + (splitKicks and 4 or 0) + (splitClings and 8 or 0)
    if layoutNum == currentLayoutNum then
        return  -- unchanged
    end
    -- select layout from number
    local layoutNames = {
        "layouts/items_standard.json",
        "layouts/items_progbreaker.json",
        "layouts/items_progslide.json",
        "layouts/items_progs.json",
        "layouts/items_splitkick.json",
        "layouts/items_progbreaker_splitkick.json",
        "layouts/items_progslide_splitkick.json",
        "layouts/items_progs_splitkick.json",
        "layouts/items_splitcling.json",
        "layouts/items_progbreaker_splitcling.json",
        "layouts/items_progslide_splitcling.json",
        "layouts/items_progs_splitcling.json",
        "layouts/items_splits.json",
        "layouts/items_progbreaker_splits.json",
        "layouts/items_progslide_splits.json",
        "layouts/items_progs_splits.json",
    }
    local layoutName = layoutNames[layoutNum]
    -- load layout
    Tracker:AddLayouts(layoutName)
    currentLayoutNum = layoutNum  -- remember what is currently loaded
end

ScriptHost:AddWatchForCode("op_progbreaker", "op_progbreaker", updateLayout)
ScriptHost:AddWatchForCode("op_progslide", "op_progslide", updateLayout)
ScriptHost:AddWatchForCode("op_splitkick", "op_splitkick", updateLayout)
ScriptHost:AddWatchForCode("op_splitcling", "op_splitcling", updateLayout)
