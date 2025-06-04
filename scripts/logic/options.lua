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
        obscure_logic = ObscureLogic,
        split_sun_greaves = SplitSunGreaves,
    }
}

return options
