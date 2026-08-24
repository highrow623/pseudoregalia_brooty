local player_start_to_stage = {}
local origin_region_names = {}
local default_origin_region = ""

for i = 1,#rules.pseudoregalia_data.spawn_points do
    local spawn_data = rules.pseudoregalia_data.spawn_points[i]
    if spawn_data.default then
        default_origin_region = spawn_data.region
    end
    local player_start = rules.player_starts[spawn_data.player_start]
    local stage = i-1
    player_start_to_stage[player_start] = stage
    origin_region_names[stage] = spawn_data.region
end

regions = {
    player_start_to_stage = player_start_to_stage,
    origin_region_names = origin_region_names,
    default_origin_region = default_origin_region,
}

return regions
