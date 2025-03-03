-- Tracker:AddLayouts("layouts/tracker_worldmap.json")
Tracker:AddLayouts("layouts/settings_popup.json")
-- Tracker:AddLayouts("layouts/broadcast_horizontal.json")

if (string.find(Tracker.ActiveVariantUID,"standard")) then
    Tracker:AddMaps("maps/maps.json")
    Tracker:AddLocations("locations/locations.json")
    Tracker:AddLayouts("layouts/broadcast.json")
    Tracker:AddLayouts("layouts/tracker.json")
    Tracker:AddLayouts("layouts/maps.json")
end
