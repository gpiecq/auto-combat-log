local _, ns = ...

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

-- Use Spell_Holy_BorrowedTime (green glow) when active, INV_Misc_Note_06 (gray) when inactive
local ICON_ACTIVE = "Interface\\Icons\\Spell_Holy_BorrowedTime"
local ICON_INACTIVE = "Interface\\Icons\\INV_Misc_Note_06"

local dataObject = LDB:NewDataObject("AutoCombatLog", {
    type = "launcher",
    text = "AutoCombatLog",
    icon = ICON_INACTIVE,
    OnClick = function(self, button)
        if button == "LeftButton" then
            ns:ToggleLogging()
        elseif button == "RightButton" then
            ns:OpenSettings()
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine(ns.ADDON_COLOR .. "AutoCombatLog|r")
        tooltip:AddLine(" ")
        if ns:IsLogging() then
            tooltip:AddLine("Status: |cff00ff00Active|r")
            local duration = ns:GetFormattedSessionDuration()
            tooltip:AddLine("Session: " .. duration)

            -- Show current instance
            local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()
            local instanceName = ns:GetInstanceName(instanceID)
            if instanceName ~= "Unknown" then
                tooltip:AddLine("Instance: " .. ns.ADDON_COLOR .. instanceName .. "|r")
            end
        else
            tooltip:AddLine("Status: |cffff4c4cInactive|r")
        end
        tooltip:AddLine(" ")
        tooltip:AddDoubleLine("|cffffffffLeft-click|r", "Toggle combat logging")
        tooltip:AddDoubleLine("|cffffffffRight-click|r", "Open settings")
    end,
})

function ns:InitMinimapButton()
    LDBIcon:Register("AutoCombatLog", dataObject, ns.db.minimap)
    ns:UpdateMinimapIcon()
end

function ns:UpdateMinimapIcon()
    if ns:IsLogging() then
        dataObject.icon = ICON_ACTIVE
    else
        dataObject.icon = ICON_INACTIVE
    end
end
