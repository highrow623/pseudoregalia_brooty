local playerStarts = constants.playerStarts

player_start_to_stage = {
    [playerStarts.CastleWestSave] = 0,
    [playerStarts.CastleGazeboSave] = 1,
    [playerStarts.DungeonMirror] = 2,
    [playerStarts.LibraryMainSave] = 3,
    [playerStarts.UnderbellySouthSave] = 4,
    [playerStarts.UnderbellyCentralSave] = 5,
    [playerStarts.BaileySave] = 6,
    [playerStarts.KeepCentralSave] = 7,
    [playerStarts.KeepNorthSave] = 8,
    [playerStarts.TheatreSave] = 9,
}

stage_to_player_start = {}
for start, stage in pairs(player_start_to_stage) do
    stage_to_player_start[stage] = start
end

origin_region_names = {
    [0] = "Castle Main",
    [1] = "Castle Main",
    [2] = "Dungeon Mirror",
    [3] = "Library Main",
    [4] = "Underbelly => Bailey",
    [5] = "Underbelly Main Upper",
    [6] = "Bailey Lower",
    [7] = "Keep Main",
    [8] = "Keep Main",
    [9] = "Theatre Main",
}

region_table = {
    ["Dungeon Mirror"] = {
        "Dungeon Slide",
    },
    ["Dungeon Slide"] = {
        "Dungeon Mirror",
        "Dungeon Strong Eyes",
        "Dungeon Escape Lower",
    },
    ["Dungeon Strong Eyes"] = {
        "Dungeon Slide",
        "Dungeon => Castle",
    },
    ["Dungeon => Castle"] = {
        "Dungeon Mirror",
        "Dungeon Strong Eyes",
        "Castle Main",
    },
    ["Dungeon Escape Lower"] = {
        "Dungeon Slide",
        "Dungeon Escape Upper",
        "Underbelly => Dungeon",
    },
    ["Dungeon Escape Upper"] = {
        "Dungeon Escape Lower",
        "Theatre Outside Scythe Corridor",
    },

    ["Castle Main"] = {
        "Dungeon => Castle",
        "Keep Main",
        "Bailey Lower",
        "Library Main",
        "Castle => Theatre Pillar",
        "Castle Spiral Climb",
        "Keep (Northeast) => Castle",
    },
    ["Castle Spiral Climb"] = {
        "Castle Main",
        "Castle High Climb",
        "Castle By Scythe Corridor",
    },
    ["Castle High Climb"] = {
    },
    ["Castle By Scythe Corridor"] = {
        "Castle Spiral Climb",
        "Castle High Climb",
        "Castle => Theatre (Front)",
    },
    ["Castle => Theatre (Front)"] = {
        "Castle By Scythe Corridor",
        "Castle Moon Room",
        "Theatre Main",
    },
    ["Castle Moon Room"] = {
    },

    ["Library Main"] = {
        "Library Locked",
        "Library Greaves",
        "Library Top",
        "Castle Main",
    },
    ["Library Locked"] = {
    },
    ["Library Greaves"] = {
        "Library Back",
    },
    ["Library Top"] = {
        "Library Back",
    },
    ["Library Back"] = {
        "Library Greaves",
        "Library Top",
    },

    ["Keep Main"] = {
        "Keep Locked Room",
        "Keep Sunsetter",
        "Keep Throne Room",
        "Keep => Underbelly",
        "Theatre Outside Scythe Corridor",
        "Keep (Northeast) => Castle",
        "Castle Main",
    },
    ["Keep Locked Room"] = {
        "Keep Sunsetter",
    },
    ["Keep Sunsetter"] = {
    },
    ["Keep Throne Room"] = {
    },
    ["Keep => Underbelly"] = {
        "Keep Main",
        "Underbelly => Keep",
    },
    ["Keep (Northeast) => Castle"] = {
        "Keep Main",
        "Castle Main",
    },

    ["Bailey Lower"] = {
        "Bailey Upper",
        "Castle Main",
        "Theatre Pillar => Bailey",
    },
    ["Bailey Upper"] = {
        "Bailey Lower",
        "Underbelly => Bailey",
        "Tower Remains",
    },
    ["Tower Remains"] = {
        "The Great Door",
    },
    ["Underbelly => Dungeon"] = {
        "Dungeon Escape Lower",
        "Underbelly Light Pillar",
        "Underbelly Ascendant Light",
    },
    ["Underbelly Light Pillar"] = {
        "Underbelly Main Upper",
        "Underbelly => Dungeon",
        "Underbelly Ascendant Light",
    },
    ["Underbelly Ascendant Light"] = {
        "Underbelly => Dungeon",
    },
    ["Underbelly Main Lower"] = {
        "Underbelly => Bailey",
        "Underbelly Hole",
        "Underbelly By Heliacal",
        "Underbelly Main Upper",
    },
    ["Underbelly Main Upper"] = {
        "Underbelly Main Lower",
        "Underbelly Light Pillar",
        "Underbelly By Heliacal",
    },
    ["Underbelly By Heliacal"] = {
        "Underbelly Main Upper",
    },
    ["Underbelly => Bailey"] = {
        "Bailey Upper",
        "Bailey Lower",
        "Underbelly Main Lower",
    },
    ["Underbelly => Keep"] = {
        "Keep => Underbelly",
        "Underbelly Hole",
    },
    ["Underbelly Hole"] = {
        "Underbelly Main Lower",
        "Underbelly => Keep",
    },

    ["Theatre Main"] = {
        "Theatre Outside Scythe Corridor",
        "Theatre Pillar",
        "Castle => Theatre (Front)",
    },
    ["Theatre Pillar => Bailey"] = {
        "Theatre Pillar",
        "Bailey Lower",
    },
    ["Castle => Theatre Pillar"] = {
        "Theatre Pillar",
        "Castle Main",
    },
    ["Theatre Pillar"] = {
        "Theatre Main",
        "Theatre Pillar => Bailey",
        "Castle => Theatre Pillar",
    },
    ["Theatre Outside Scythe Corridor"] = {
        "Theatre Main",
        "Dungeon Escape Upper",
        "Keep Main",
    },

    ["The Great Door"] = {
    },
}
