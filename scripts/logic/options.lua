-- this is roughly eqiovalent to AP player options
-- TODO: use require for constants and helper


local difficulties = constants.difficulties
local versions = constants.versions
local Choice = helper.Choice
local Toggle = helper.Toggle


GameVersion = {
    value_to_code = {
        [versions.MAP_PATCH] = "map_patch",
        [versions.FULL_GOLD] = "full_gold",
    },
    default = versions.MAP_PATCH,
}
setmetatable(GameVersion, Choice)


LogicLevel = {
    value_to_code = {
        [difficulties.NORMAL] = "normal",
        [difficulties.HARD] = "hard",
        [difficulties.EXPERT] = "expert",
        [difficulties.LUNATIC] = "lunatic",
    },
    default = difficulties.NORMAL,
}
setmetatable(LogicLevel, Choice)


SpawnPoint = {
    value_to_code = {
        [0] = "castle_west_save",
        [1] = "castle_gazebo_save",
        [2] = "dungeon_mirror",
        [3] = "library_main_save",
        [4] = "underbelly_south_save",
        [5] = "underbelly_central_save",
        [6] = "bailey_save",
        [7] = "keep_central_save",
        [8] = "keep_north_save",
        [9] = "theatre_save",
    },
    default = 0,
}
setmetatable(SpawnPoint, Choice)


ObscureLogic = {
    code = "obscure"
}
setmetatable(ObscureLogic, Toggle)


SplitSunGreaves = {
    code = "op_splitkick_on"
}
setmetatable(SplitSunGreaves, Toggle)


options = {
    pseudoregalia_options = {
        game_version = GameVersion,
        logic_level = LogicLevel,
        spawn_point = SpawnPoint,
        obscure_logic = ObscureLogic,
        split_sun_greaves = SplitSunGreaves,
    }
}

return options
