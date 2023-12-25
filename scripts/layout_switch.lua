-- LAYOUT SWITCHING
-- change layout depending on options


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
