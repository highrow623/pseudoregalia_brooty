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
    -- encode 3 toggles into a 3 bit integer (8 states), +1 for Lua array starting at 1
    local layoutNum = 1 + (progBreaker and 1 or 0) + (progSlide and 2 or 0) + (splitKicks and 4 or 0)
    if layoutNum == currentLayoutNum then
        return  -- unchanged
    end
    -- select layout from number
    local layoutNames = {
        "layouts/items_standard.json",
        "layouts/items_only_progbreaker.json",
        "layouts/items_only_progslide.json",
        "layouts/items_progbreaker_and_progslide.json",
        "layouts/items_only_splitkick.json",
        "layouts/items_progbreaker_and_splitkick.json",
        "layouts/items_progslide_and_splitkick.json",
        "layouts/items_progs_and_split.json",
    }
    local layoutName = layoutNames[layoutNum]
    -- load layout
    Tracker:AddLayouts(layoutName)
    currentLayoutNum = layoutNum  -- remember what is currently loaded
end

ScriptHost:AddWatchForCode("op_progbreaker", "op_progbreaker", updateLayout)
ScriptHost:AddWatchForCode("op_progslide", "op_progslide", updateLayout)
ScriptHost:AddWatchForCode("op_splitkick", "op_splitkick", updateLayout)
