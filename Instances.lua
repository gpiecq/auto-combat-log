local _, ns = ...

-- TBC Raids (always eligible regardless of difficultyID)
ns.RAIDS = {
    [532] = { name = "Karazhan",              maxPlayers = 10 },
    [565] = { name = "Gruul's Lair",          maxPlayers = 25 },
    [544] = { name = "Magtheridon's Lair",    maxPlayers = 25 },
    [548] = { name = "Serpentshrine Cavern",  maxPlayers = 25 },
    [550] = { name = "Tempest Keep: The Eye", maxPlayers = 25 },
    [534] = { name = "Hyjal Summit",          maxPlayers = 25 },
    [564] = { name = "Black Temple",          maxPlayers = 25 },
    [568] = { name = "Zul'Aman",              maxPlayers = 10 },
    [580] = { name = "Sunwell Plateau",       maxPlayers = 25 },
}

-- TBC Heroic Dungeons (eligible only when difficultyID == 2)
ns.DUNGEONS = {
    [543] = { name = "Hellfire Ramparts" },
    [542] = { name = "The Blood Furnace" },
    [540] = { name = "The Shattered Halls" },
    [547] = { name = "The Slave Pens" },
    [546] = { name = "The Underbog" },
    [545] = { name = "The Steamvault" },
    [557] = { name = "Mana-Tombs" },
    [558] = { name = "Auchenai Crypts" },
    [556] = { name = "Sethekk Halls" },
    [555] = { name = "Shadow Labyrinth" },
    [560] = { name = "Old Hillsbrad Foothills" },
    [269] = { name = "The Black Morass" },
    [554] = { name = "The Mechanar" },
    [553] = { name = "The Botanica" },
    [552] = { name = "The Arcatraz" },
    [585] = { name = "Magisters' Terrace" },
}

function ns:IsEligibleInstance(instanceID, difficultyID)
    if self.RAIDS[instanceID] then
        return true
    end
    if self.DUNGEONS[instanceID] and difficultyID == 2 then
        return true
    end
    return false
end

function ns:GetInstanceName(instanceID)
    local data = self.RAIDS[instanceID] or self.DUNGEONS[instanceID]
    return data and data.name or "Unknown"
end

function ns:GetSortedInstances(tbl)
    local sorted = {}
    for id, data in pairs(tbl) do
        table.insert(sorted, { id = id, name = data.name })
    end
    table.sort(sorted, function(a, b) return a.name < b.name end)
    return sorted
end
