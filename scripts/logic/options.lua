-- this is roughly eqiovalent to AP player options
-- TODO: use require for constants and helper


local difficulties = constants.difficulties
local Choice = helper.Choice
local Toggle = helper.Toggle


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


FullGoldSlide = {
    code = "full_gold_slide"
}
setmetatable(FullGoldSlide, Toggle)


options = {
    pseudoregalia_options = {
        logic_level = LogicLevel,
        obscure_logic = ObscureLogic,
        split_sun_greaves = SplitSunGreaves,
        full_gold_slide = FullGoldSlide,
    }
}

return options
