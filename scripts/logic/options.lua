-- this is roughly eqiovalent to AP player options
-- TODO: use require for constants and helper


local difficulties = constants.difficulties
local Choice = helper.Choice


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


options = {
    pseudoregalia_options = {
        logic_level = LogicLevel
    }
}

return options
