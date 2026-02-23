local ADDON_NAME, ns = ...

ns.ADDON_NAME = ADDON_NAME
ns.VERSION = "1.1.0"

-- Shared state
ns.db = nil

-- Central event frame
ns.frame = CreateFrame("Frame")
local eventHandlers = {}

ns.frame:SetScript("OnEvent", function(self, event, ...)
    if eventHandlers[event] then
        eventHandlers[event](...)
    end
end)

function ns:RegisterEvent(event, handler)
    eventHandlers[event] = handler
    ns.frame:RegisterEvent(event)
end

function ns:UnregisterEvent(event)
    eventHandlers[event] = nil
    ns.frame:UnregisterEvent(event)
end

-- SavedVariables defaults
local function InitializeDB()
    if not AutoCombatLogDB then
        AutoCombatLogDB = {}
    end

    local defaults = {
        isLogging = false,
        lastInstanceID = nil,
        sessionStartTime = nil,
        minimap = { hide = false },
        instances = {},
        history = {},
    }

    for k, v in pairs(defaults) do
        if AutoCombatLogDB[k] == nil then
            if type(v) == "table" then
                AutoCombatLogDB[k] = {}
                for k2, v2 in pairs(v) do
                    AutoCombatLogDB[k][k2] = v2
                end
            else
                AutoCombatLogDB[k] = v
            end
        end
    end

    -- Populate missing instances with defaults
    for id in pairs(ns.RAIDS) do
        if AutoCombatLogDB.instances[id] == nil then
            AutoCombatLogDB.instances[id] = true
        end
    end
    for id in pairs(ns.DUNGEONS) do
        if AutoCombatLogDB.instances[id] == nil then
            AutoCombatLogDB.instances[id] = false
        end
    end

    ns.db = AutoCombatLogDB
end

-- Initialization
ns:RegisterEvent("ADDON_LOADED", function(addonName)
    if addonName ~= ADDON_NAME then return end
    ns:UnregisterEvent("ADDON_LOADED")

    InitializeDB()
    ns:InitMinimapButton()
    ns:InitSettings()
    ns:RegisterCombatLogEvents()

    print(ns.ADDON_COLOR .. "AutoCombatLog|r v" .. ns.VERSION .. " loaded. Type /acl for help.")
end)
