local _, ns = ...

local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

local ICON_DEFAULT = "Interface\\Icons\\INV_Misc_Note_06"

local dataObject = LDB:NewDataObject("AutoCombatLogClassic", {
    type = "launcher",
    text = "AutoCombatLogClassic",
    icon = ICON_DEFAULT,
    OnClick = function(self, button)
        if button == "LeftButton" then
            ns:ToggleLogging()
        elseif button == "RightButton" then
            ns:OpenSettings()
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine(ns.ADDON_COLOR .. "AutoCombatLogClassic|r")
        tooltip:AddLine(" ")
        if ns:IsLogging() then
            if ns.IsPendingStop and ns:IsPendingStop() then
                tooltip:AddLine("Status: |cffffcc00Active (stop prompt pending)|r")
            else
                tooltip:AddLine("Status: |cff00ff00Active|r")
            end
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
    LDBIcon:Register("AutoCombatLogClassic", dataObject, ns.db.minimap)
    ns:UpdateMinimapIcon()
end

function ns:UpdateMinimapIcon()
    local button = LDBIcon:GetMinimapButton("AutoCombatLogClassic")
    if not button then return end
    local icon = button.icon
    if not icon then return end

    if ns:IsLogging() then
        if ns.IsPendingStop and ns:IsPendingStop() then
            icon:SetVertexColor(1, 0.8, 0) -- amber: stop prompt pending
        else
            icon:SetVertexColor(0, 1, 0) -- bright green tint
        end
    else
        icon:SetVertexColor(1, 1, 1) -- normal color
    end
end
