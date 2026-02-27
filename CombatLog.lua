local _, ns = ...

local isCurrentlyLogging = false
local currentSessionInstanceID = nil

-- Max history entries to keep
local MAX_HISTORY = 50

function ns:RegisterCombatLogEvents()
    ns:RegisterEvent("PLAYER_ENTERING_WORLD", function(isInitialLogin, isReloadingUi)
        C_Timer.After(1, function()
            if ns.db.isLogging then
                ns:ResumeLogging()
            else
                ns:CheckInstance()
            end
        end)
    end)

    ns:RegisterEvent("ZONE_CHANGED_NEW_AREA", function()
        C_Timer.After(1, function()
            ns:CheckInstance()
        end)
    end)
end

-- ============================================================
-- Confirmation Popups
-- ============================================================

StaticPopupDialogs["AUTOCOMBATLOG_START_CONFIRM"] = {
    text = "",
    button1 = "Enable",
    button2 = "No",
    OnAccept = function()
        local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()
        ns:StartLogging(instanceID)
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["AUTOCOMBATLOG_STOP_CONFIRM"] = {
    text = ns.ADDON_COLOR .. "AutoCombatLog|r\n\nYou left the instance.\nDisable combat logging?",
    button1 = "Disable",
    button2 = "Keep logging",
    OnAccept = function()
        ns:StopLogging()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function ns:CheckInstance()
    local _, instanceType, difficultyID, _, _, _, _, instanceID = GetInstanceInfo()

    if self:IsEligibleInstance(instanceID, difficultyID) then
        if not isCurrentlyLogging and self.db.instances[instanceID] then
            -- Check if WoW combat log is already running (e.g. manually started)
            if LoggingCombat() then
                -- Sync addon state with WoW without popup
                isCurrentlyLogging = true
                currentSessionInstanceID = instanceID
                self.db.isLogging = true
                self.db.lastInstanceID = instanceID
                self:StartSessionTimer()
                self:UpdateMinimapIcon()
                self:AddHistoryEntry(instanceID, "resumed")

                local instanceName = self:GetInstanceName(instanceID)
                RaidNotice_AddMessage(RaidWarningFrame,
                    ns.ADDON_COLOR .. "AutoCombatLog:|r Combat logging detected for " .. instanceName,
                    ChatTypeInfo["RAID_WARNING"])
            else
                local instanceName = self:GetInstanceName(instanceID)
                StaticPopupDialogs["AUTOCOMBATLOG_START_CONFIRM"].text =
                    ns.ADDON_COLOR .. "AutoCombatLog|r\n\nYou entered " .. instanceName .. ".\nEnable combat logging?"
                StaticPopup_Show("AUTOCOMBATLOG_START_CONFIRM")
            end
        end
    else
        -- Left an eligible instance while logging
        if isCurrentlyLogging then
            StaticPopup_Show("AUTOCOMBATLOG_STOP_CONFIRM")
        end
    end
end

function ns:StartLogging(instanceID)
    if isCurrentlyLogging then return end

    LoggingCombat(true)
    isCurrentlyLogging = true
    currentSessionInstanceID = instanceID
    self.db.isLogging = true
    self.db.lastInstanceID = instanceID

    self:StartSessionTimer()
    self:UpdateMinimapIcon()

    -- Add history entry
    self:AddHistoryEntry(instanceID, "started")

    local instanceName = self:GetInstanceName(instanceID)
    RaidNotice_AddMessage(RaidWarningFrame,
        ns.ADDON_COLOR .. "AutoCombatLog:|r Combat logging started for " .. instanceName,
        ChatTypeInfo["RAID_WARNING"])
end

function ns:StopLogging()
    if not isCurrentlyLogging then return end

    LoggingCombat(false)

    local durationSeconds = self:GetRawSessionDuration()
    local duration = self:StopSessionTimer()

    -- Update history entry to "completed"
    self:CompleteHistoryEntry(currentSessionInstanceID, durationSeconds)

    isCurrentlyLogging = false
    currentSessionInstanceID = nil
    self.db.isLogging = false
    self.db.lastInstanceID = nil

    self:UpdateMinimapIcon()

    RaidNotice_AddMessage(RaidWarningFrame,
        ns.ADDON_COLOR .. "AutoCombatLog:|r Combat logging stopped. Duration: " .. duration,
        ChatTypeInfo["RAID_WARNING"])

    self:ShowUploadReminder(duration)
end

function ns:ResumeLogging(retryCount)
    retryCount = retryCount or 0
    local _, instanceType, difficultyID, _, _, _, _, instanceID = GetInstanceInfo()

    if self.db.isLogging and self:IsEligibleInstance(instanceID, difficultyID) then
        LoggingCombat(true)
        isCurrentlyLogging = true
        currentSessionInstanceID = instanceID
        self:StartSessionTimer()
        self:UpdateMinimapIcon()

        -- Add history entry for resume
        self:AddHistoryEntry(instanceID, "resumed")

        local instanceName = self:GetInstanceName(instanceID)
        RaidNotice_AddMessage(RaidWarningFrame,
            ns.ADDON_COLOR .. "AutoCombatLog:|r Combat logging RESUMED for " .. instanceName,
            ChatTypeInfo["RAID_WARNING"])
    elseif retryCount < 2 then
        -- GetInstanceInfo() may not be ready yet after disconnect, retry
        C_Timer.After(3, function()
            ns:ResumeLogging(retryCount + 1)
        end)
    else
        self.db.isLogging = false
        self.db.lastInstanceID = nil
    end
end

function ns:IsLogging()
    return isCurrentlyLogging
end

function ns:ToggleLogging()
    if isCurrentlyLogging then
        self:StopLogging()
    else
        local _, _, difficultyID, _, _, _, _, instanceID = GetInstanceInfo()
        if self:IsEligibleInstance(instanceID, difficultyID) then
            self:StartLogging(instanceID)
        else
            RaidNotice_AddMessage(RaidWarningFrame,
                ns.ADDON_COLOR .. "AutoCombatLog:|r You are not in an eligible instance.",
                ChatTypeInfo["RAID_WARNING"])
        end
    end
end

-- ============================================================
-- History Management
-- ============================================================

function ns:AddHistoryEntry(instanceID, status)
    if not self.db.history then
        self.db.history = {}
    end

    local entry = {
        instanceID = instanceID,
        instanceName = self:GetInstanceName(instanceID),
        startTime = time(),
        date = date("%Y-%m-%d %H:%M"),
        duration = nil,
        status = status, -- "started", "resumed", "completed"
    }

    table.insert(self.db.history, 1, entry) -- Insert at beginning (most recent first)

    -- Trim history to max size
    while #self.db.history > MAX_HISTORY do
        table.remove(self.db.history)
    end
end

function ns:CompleteHistoryEntry(instanceID, durationSeconds)
    if not self.db.history or #self.db.history == 0 then return end

    -- Find the most recent active entry for this instance
    for _, entry in ipairs(self.db.history) do
        if entry.instanceID == instanceID and entry.status ~= "completed" then
            entry.status = "completed"
            entry.duration = durationSeconds
            break
        end
    end
end

function ns:GetHistory()
    return self.db.history or {}
end

function ns:ClearHistory()
    self.db.history = {}
end

-- ============================================================
-- Upload Reminder
-- ============================================================

function ns:ShowUploadReminder(duration)
    StaticPopupDialogs["AUTOCOMBATLOG_UPLOAD_REMINDER"] = {
        text = "Combat logging session ended.\n\nSession duration: " .. duration .. "\n\nRemember to upload your logs to Warcraft Logs!\nLog file is in your WoW Logs folder.",
        button1 = "OK",
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("AUTOCOMBATLOG_UPLOAD_REMINDER")
end

-- ============================================================
-- Slash Commands
-- ============================================================

SLASH_AUTOCOMBATLOG1 = "/acl"
SLASH_AUTOCOMBATLOG2 = "/autocombatlog"
SlashCmdList["AUTOCOMBATLOG"] = function(msg)
    msg = strlower(strtrim(msg))
    if msg == "toggle" then
        ns:ToggleLogging()
    elseif msg == "start" then
        if not ns:IsLogging() then
            local _, _, difficultyID, _, _, _, _, instanceID = GetInstanceInfo()
            if ns:IsEligibleInstance(instanceID, difficultyID) then
                ns:StartLogging(instanceID)
            else
                RaidNotice_AddMessage(RaidWarningFrame,
                    ns.ADDON_COLOR .. "AutoCombatLog:|r You are not in an eligible instance.",
                    ChatTypeInfo["RAID_WARNING"])
            end
        end
    elseif msg == "stop" then
        ns:StopLogging()
    elseif msg == "settings" or msg == "options" or msg == "config" then
        ns:OpenSettings()
    elseif msg == "status" then
        if ns:IsLogging() then
            local duration = ns:GetFormattedSessionDuration()
            print(ns.ADDON_COLOR .. "AutoCombatLog:|r Logging is |cff00ff00ACTIVE|r (" .. duration .. ")")
        else
            print(ns.ADDON_COLOR .. "AutoCombatLog:|r Logging is |cffff4c4cINACTIVE|r")
        end
    elseif msg == "history" then
        ns:PrintHistory()
    elseif msg == "debug" then
        local name, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID = GetInstanceInfo()
        print(ns.ADDON_COLOR .. "AutoCombatLog|r - Debug Info:")
        print("  Instance Name: " .. tostring(name))
        print("  Instance Type: " .. tostring(instanceType))
        print("  Difficulty ID: " .. tostring(difficultyID))
        print("  Difficulty Name: " .. tostring(difficultyName))
        print("  Max Players: " .. tostring(maxPlayers))
        print("  Instance ID: " .. tostring(instanceID))
        print("  Eligible: " .. tostring(ns:IsEligibleInstance(instanceID, difficultyID)))
    else
        print(ns.ADDON_COLOR .. "AutoCombatLog|r commands:")
        print("  /acl toggle - Start/stop combat logging")
        print("  /acl start - Start combat logging")
        print("  /acl stop - Stop combat logging")
        print("  /acl status - Show current logging status")
        print("  /acl history - Show session history")
        print("  /acl settings - Open settings panel")
    end
end

function ns:PrintHistory()
    local history = self:GetHistory()
    if #history == 0 then
        print(ns.ADDON_COLOR .. "AutoCombatLog:|r No session history.")
        return
    end

    print(ns.ADDON_COLOR .. "AutoCombatLog|r - Session History:")
    for i, entry in ipairs(history) do
        if i > 10 then break end -- Show last 10 in chat
        local statusColor = entry.status == "completed" and "|cff00ff00" or "|cffffcc00"
        local durationStr = entry.duration and self:FormatDuration(entry.duration) or "In progress"
        print(string.format("  %s %s%s|r - %s (%s)",
            entry.date,
            statusColor, entry.status,
            entry.instanceName,
            durationStr))
    end
end
