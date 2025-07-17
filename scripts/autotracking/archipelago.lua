ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")

CUR_INDEX = -1
SLOT_DATA = nil
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}
HOSTED = {gameover=1}

function buildKey(key)
    return string.format("Pseudoregalia - Team %d - Player %d - %s", Archipelago.TeamNumber, Archipelago.PlayerNumber, key)
end

local zoneValueToTab = {
    "Dilapidated Dungeon",
    "Castle Sansa",
    "Sansa Keep",
    "Listless Library",
    "Twilight Theatre",
    "Empty Bailey",
    "The Underbelly",
    "Tower Remains",
    "Tower Remains", -- use tower for chambers since there isn't a chambers tab
}

function onRetrieved(key, value)
    if key == buildKey("Game Complete") then
        if value == nil then return end
        Tracker:FindObjectForCode("gameover", ITEMS).Active = true
    elseif key == buildKey("Zone") then
        if Tracker:ProviderCountForCode("auto_swap_map") == 0 then return end
        if zoneValueToTab[value] == nil then return end
        Tracker:UiHint("ActivateTab", zoneValueToTab[value])
    end
end

function onSetReply(key, value, old)
    onRetrieved(key, value)
end

function onClear(slot_data)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onClear, slot_data:\n%s", dump_table(slot_data)))
    end
    SLOT_DATA = slot_data
    CUR_INDEX = -1
    -- reset locations
    for _, v in pairs(LOCATION_MAPPING) do
        if v[1] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing location %s", v[1]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[1]:sub(1, 1) == "@" then
                    obj.AvailableChestCount = obj.ChestCount
                else
                    obj.Active = false
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
    -- reset items
    for _, v in pairs(ITEM_MAPPING) do
        if v[1] and v[2] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing item %s of type %s", v[1], v[2]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[2] == "toggle" then
                    obj.Active = false
                elseif v[2] == "progressive" then
                    obj.CurrentStage = 0
                    obj.Active = false
                elseif v[2] == "consumable" then
                    obj.AcquiredCount = 0
                elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onClear: unknown item type %s for code %s", v[2], v[1]))
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
    -- reset hosted items
    for k, _ in pairs(HOSTED) do
        local obj = Tracker:FindObjectForCode(k)
        if obj then
            obj.Active = false
        end
    end

    if slot_data["game_version"] ~= nil then
        print("slot_data['game_version']: " .. slot_data['game_version'])
        if slot_data["game_version"] == 1 then
            Tracker:FindObjectForCode("game_version").CurrentStage = 0
        elseif slot_data["game_version"] == 2 then
            Tracker:FindObjectForCode("game_version").CurrentStage = 1
        end
    end

    if slot_data["logic_level"] ~= nil then
        print("slot_data['logic_level']: " .. slot_data['logic_level'])
        if slot_data["logic_level"] == 1 then
            Tracker:FindObjectForCode("logic").CurrentStage = 0
        elseif slot_data["logic_level"] == 2 then
            Tracker:FindObjectForCode("logic").CurrentStage = 1
        elseif slot_data["logic_level"] == 3 then
            Tracker:FindObjectForCode("logic").CurrentStage = 2
        elseif slot_data["logic_level"] == 4 then
            Tracker:FindObjectForCode("logic").CurrentStage = 3
        end
    end

    if slot_data.obscure_logic ~= nil then
        print("slot_data.obscure_logic: " .. tostring(slot_data.obscure_logic))
        local obj = Tracker:FindObjectForCode("obscure")
        if obj then
            obj.Active = slot_data.obscure_logic
        end
    end

    pauseLayoutUpdate = true  -- pause updating until all codes are set since update is expensive

    if slot_data.progressive_breaker ~= nil then
        print("slot_data.progressive_breaker: " .. tostring(slot_data.progressive_breaker))
        local obj = Tracker:FindObjectForCode("op_progbreaker")
        if obj then
            obj.Active = slot_data.progressive_breaker
        end
    end

    if slot_data.progressive_slide ~= nil then
        print("slot_data.progressive_slide: " .. tostring(slot_data.progressive_slide))
        local obj = Tracker:FindObjectForCode("op_progslide")
        if obj then
            obj.Active = slot_data.progressive_slide
        end
    end

    if slot_data.split_sun_greaves ~= nil then
        print("slot_data.split_sun_greaves: " .. tostring(slot_data.split_sun_greaves))
        -- op_splitkick is progressive because both stages are used for visibility_rules
        if slot_data.split_sun_greaves == false then
            Tracker:FindObjectForCode("op_splitkick_on").CurrentStage = 0
        elseif slot_data.split_sun_greaves == true then
            Tracker:FindObjectForCode("op_splitkick_on").CurrentStage = 1
        end
    end

    if slot_data.split_cling_gem ~= nil then
        print("slot_data.split_cling_gem: ".. tostring(slot_data.split_sun_greaves))
        -- op_splitcling is progressive because both stages are used for visibility_rules
        if slot_data.split_cling_gem == false then
            Tracker:FindObjectForCode("op_splitcling_on").CurrentStage = 0
        elseif slot_data.split_cling_gem == true then
            Tracker:FindObjectForCode("op_splitcling_on").CurrentStage = 1
        end
    end

    if slot_data.randomize_time_trials ~= nil then
        print("slot_data.randomize_time_trials: " .. tostring(slot_data.randomize_time_trials))
        -- time_trials is progressive because both stages are used for visibility_rules
        if slot_data.randomize_time_trials == false then
            Tracker:FindObjectForCode("time_trials").CurrentStage = 0
        elseif slot_data.randomize_time_trials == true then
            Tracker:FindObjectForCode("time_trials").CurrentStage = 1
        end
    end

    if slot_data.randomize_goats ~= nil then
        print("slot_data.randomize_goats: " .. tostring(slot_data.randomize_goats))
        local obj = Tracker:FindObjectForCode("goats")
        if obj then
            obj.Active = slot_data.randomize_goats
        end
    end

    if slot_data.randomize_chairs ~= nil then
        print("slot_data.randomize_chairs: " .. tostring(slot_data.randomize_chairs))
        local obj = Tracker:FindObjectForCode("chairs")
        if obj then
            obj.Active = slot_data.randomize_chairs
        end
    end

    if slot_data.randomize_books ~= nil then
        print("slot_data.randomize_books: " .. tostring(slot_data.randomize_books))
        local obj = Tracker:FindObjectForCode("books")
        if obj then
            obj.Active = slot_data.randomize_books
        end
    end

    if slot_data.randomize_notes ~= nil then
        print("slot_data.notes: " .. tostring(slot_data.randomize_notes))
        local obj = Tracker:FindObjectForCode("notes")
        if obj then
            obj.Active = slot_data.randomize_notes
        end
    end

    pauseLayoutUpdate = false
    updateLayout()  -- actually update

    LOCAL_ITEMS = {}
    GLOBAL_ITEMS = {}

    --Tracker:FindObjectForCode("apLayout").Active = true
    keys = {buildKey("Game Complete"), buildKey("Zone")}
    Archipelago:SetNotify(keys)
    Archipelago:Get(keys)
end

-- called when an item gets collected
function onItem(index, item_id, item_name, player_number)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onItem: %s, %s, %s, %s, %s", index, item_id, item_name, player_number, CUR_INDEX))
    end
    if not AUTOTRACKER_ENABLE_ITEM_TRACKING then
        return
    end
    if index <= CUR_INDEX then
        return
    end
    local is_local = player_number == Archipelago.PlayerNumber
    CUR_INDEX = index;
    local v = ITEM_MAPPING[item_id]
    if not v then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: could not find item mapping for id %s", item_id))
        end
        return
    end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: code: %s, type %s", v[1], v[2]))
    end
    if not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[2] == "toggle" then
            obj.Active = true
        elseif v[2] == "progressive" then
            if obj.Active then
                obj.CurrentStage = obj.CurrentStage + 1
            else
                obj.Active = true
            end
        elseif v[2] == "consumable" then
            obj.AcquiredCount = obj.AcquiredCount + obj.Increment
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: unknown item type %s for code %s", v[2], v[1]))
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: could not find object for code %s", v[1]))
    end
    -- track local items via snes interface
    if is_local then
        if LOCAL_ITEMS[v[1]] then
            LOCAL_ITEMS[v[1]] = LOCAL_ITEMS[v[1]] + 1
        else
            LOCAL_ITEMS[v[1]] = 1
        end
    else
        if GLOBAL_ITEMS[v[1]] then
            GLOBAL_ITEMS[v[1]] = GLOBAL_ITEMS[v[1]] + 1
        else
            GLOBAL_ITEMS[v[1]] = 1
        end
    end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("local items: %s", dump_table(LOCAL_ITEMS)))
        print(string.format("global items: %s", dump_table(GLOBAL_ITEMS)))
    end
    if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
        -- add snes interface functions here for local item tracking
    end
end

-- called when a location gets cleared
function onLocation(location_id, location_name)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onLocation: %s, %s", location_id, location_name))
    end
    if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
        return
    end
    local v = LOCATION_MAPPING[location_id]
    if not v and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find location mapping for id %s", location_id))
    end
    if not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[1]:sub(1, 1) == "@" then
            obj.AvailableChestCount = obj.AvailableChestCount - 1
        else
            obj.Active = true
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find object for code %s", v[1]))
    end
end

-- called when a locations is scouted
function onScout(location_id, location_name, item_id, item_name, item_player)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onScout: %s, %s, %s, %s, %s", location_id, location_name, item_id, item_name,
            item_player))
    end
    -- not implemented yet :(
end

-- called when a bounce message is received 
function onBounce(json)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onBounce: %s", dump_table(json)))
    end
    -- your code goes here
end

-- add AP callbacks
-- un-/comment as needed
Archipelago:AddClearHandler("clear handler", onClear)
if AUTOTRACKER_ENABLE_ITEM_TRACKING then
    Archipelago:AddItemHandler("item handler", onItem)
end
if AUTOTRACKER_ENABLE_LOCATION_TRACKING then
    Archipelago:AddLocationHandler("location handler", onLocation)
end
Archipelago:AddRetrievedHandler("retrieved handler", onRetrieved)
Archipelago:AddSetReplyHandler("set reply handler", onSetReply)
-- Archipelago:AddScoutHandler("scout handler", onScout)
-- Archipelago:AddBouncedHandler("bounce handler", onBounce)
