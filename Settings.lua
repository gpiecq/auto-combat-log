local _, ns = ...

local SETTINGS_WIDTH = 420
local SETTINGS_HEIGHT = 550
local TAB_HEIGHT = 24

----------------------------------------------
-- Show / Toggle Settings
----------------------------------------------
function ns:OpenSettings()
    if not self.settingsFrame then
        self:CreateSettingsFrame()
    end

    if self.settingsFrame:IsShown() then
        self.settingsFrame:Hide()
    else
        self.settingsFrame:Show()
    end
end

----------------------------------------------
-- Tab switching
----------------------------------------------
local function SwitchTab(frame, tabName)
    if tabName == "settings" then
        frame.settingsScroll:Show()
        frame.historyScroll:Hide()
        ns:SetTabActive(frame.settingsTab)
        ns:SetTabInactive(frame.historyTab)
    else
        frame.settingsScroll:Hide()
        frame.historyScroll:Show()
        ns:SetTabInactive(frame.settingsTab)
        ns:SetTabActive(frame.historyTab)
        ns:RefreshHistoryDisplay()
    end
end

----------------------------------------------
-- Create Settings Frame
----------------------------------------------
function ns:CreateSettingsFrame()
    local frame = CreateFrame("Frame", "ACLSettingsFrame", UIParent)
    frame:SetSize(SETTINGS_WIDTH, SETTINGS_HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    tinsert(UISpecialFrames, "ACLSettingsFrame")
    self:CreateBackdrop(frame, 0.92)

    -- Title bar
    local titleBar, titleText = self:CreateTitleBar(frame, "AutoCombatLogClassic")

    -- Close button
    self:CreateCloseButton(frame)

    -- Status indicator in title bar
    local statusDot = self:CreateStatusDot(titleBar, 8)
    statusDot:SetPoint("RIGHT", -32, 0)
    frame.statusDot = statusDot

    local statusText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusText:SetPoint("RIGHT", statusDot, "LEFT", -6, 0)
    frame.statusText = statusText

    -- ============================================
    -- TAB BUTTONS
    -- ============================================
    local tabWidth = 90
    local settingsTab = self:CreateTab(frame, tabWidth, TAB_HEIGHT, "Settings")
    settingsTab:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -30)
    frame.settingsTab = settingsTab

    local historyTab = self:CreateTab(frame, tabWidth, TAB_HEIGHT, "History")
    historyTab:SetPoint("LEFT", settingsTab, "RIGHT", 4, 0)
    frame.historyTab = historyTab

    self:SetTabActive(settingsTab)
    self:SetTabInactive(historyTab)

    settingsTab:SetScript("OnClick", function() SwitchTab(frame, "settings") end)
    historyTab:SetScript("OnClick", function() SwitchTab(frame, "history") end)

    local contentTop = -(28 + TAB_HEIGHT + 4) -- title bar + tabs + spacing
    local contentHeight = SETTINGS_HEIGHT - math.abs(contentTop) - 8

    -- ============================================
    -- SETTINGS SCROLL FRAME
    -- ============================================
    local settingsScroll, settingsChild = self:CreateScrollFrame(frame, SETTINGS_WIDTH - 12, contentHeight)
    settingsScroll:SetPoint("TOP", 0, contentTop)
    frame.settingsScroll = settingsScroll

    local yOffset = -10

    -- SECTION: Status
    yOffset = self:CreateSectionHeader(settingsChild, "Logging Status", yOffset)

    local statusLine = settingsChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusLine:SetPoint("TOPLEFT", 16, yOffset)
    statusLine:SetTextColor(unpack(self.COLORS.TEXT))
    frame.statusLine = statusLine
    yOffset = yOffset - 20

    local durationLine = settingsChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    durationLine:SetPoint("TOPLEFT", 16, yOffset)
    durationLine:SetTextColor(unpack(self.COLORS.TEXT_DIM))
    frame.durationLine = durationLine
    yOffset = yOffset - 20

    local toggleBtn = self:CreateStyledButton(settingsChild, 160, 24, "Toggle Combat Log")
    toggleBtn.text:SetTextColor(unpack(self.COLORS.ACCENT))
    toggleBtn:SetPoint("TOPLEFT", 16, yOffset)
    toggleBtn:SetScript("OnClick", function()
        ns:ToggleLogging()
        ns:UpdateSettingsStatus()
    end)
    yOffset = yOffset - 40

    -- SECTION: TBC Raids
    yOffset = self:CreateSectionHeader(settingsChild, "TBC Raids", yOffset)

    local selectAllRaids = self:CreateStyledButton(settingsChild, 100, 20, "Select All")
    selectAllRaids:SetPoint("TOPLEFT", 16, yOffset)
    local deselectAllRaids = self:CreateStyledButton(settingsChild, 100, 20, "Deselect All")
    deselectAllRaids:SetPoint("LEFT", selectAllRaids, "RIGHT", 8, 0)
    yOffset = yOffset - 28

    local raidCheckboxes = {}
    local sortedRaids = self:GetSortedInstances(self.RAIDS)
    for _, entry in ipairs(sortedRaids) do
        local cb
        cb, yOffset = self:CreateCheckbox(settingsChild, entry.name, yOffset, function(checked)
            ns.db.instances[entry.id] = checked
        end, ns.db.instances[entry.id])
        table.insert(raidCheckboxes, { cb = cb, id = entry.id })
    end

    selectAllRaids:SetScript("OnClick", function()
        for _, item in ipairs(raidCheckboxes) do
            item.cb:SetChecked(true)
            ns.db.instances[item.id] = true
        end
    end)
    deselectAllRaids:SetScript("OnClick", function()
        for _, item in ipairs(raidCheckboxes) do
            item.cb:SetChecked(false)
            ns.db.instances[item.id] = false
        end
    end)

    yOffset = yOffset - 10

    -- SECTION: TBC Heroic Dungeons
    yOffset = self:CreateSectionHeader(settingsChild, "TBC Heroic Dungeons", yOffset)

    local selectAllDungeons = self:CreateStyledButton(settingsChild, 100, 20, "Select All")
    selectAllDungeons:SetPoint("TOPLEFT", 16, yOffset)
    local deselectAllDungeons = self:CreateStyledButton(settingsChild, 100, 20, "Deselect All")
    deselectAllDungeons:SetPoint("LEFT", selectAllDungeons, "RIGHT", 8, 0)
    yOffset = yOffset - 28

    local dungeonCheckboxes = {}
    local sortedDungeons = self:GetSortedInstances(self.DUNGEONS)
    for _, entry in ipairs(sortedDungeons) do
        local cb
        cb, yOffset = self:CreateCheckbox(settingsChild, entry.name, yOffset, function(checked)
            ns.db.instances[entry.id] = checked
        end, ns.db.instances[entry.id])
        table.insert(dungeonCheckboxes, { cb = cb, id = entry.id })
    end

    selectAllDungeons:SetScript("OnClick", function()
        for _, item in ipairs(dungeonCheckboxes) do
            item.cb:SetChecked(true)
            ns.db.instances[item.id] = true
        end
    end)
    deselectAllDungeons:SetScript("OnClick", function()
        for _, item in ipairs(dungeonCheckboxes) do
            item.cb:SetChecked(false)
            ns.db.instances[item.id] = false
        end
    end)

    yOffset = yOffset - 10

    -- SECTION: Minimap
    yOffset = self:CreateSectionHeader(settingsChild, "Minimap", yOffset)

    local _, yNew = self:CreateCheckbox(settingsChild, "Hide minimap button", yOffset, function(checked)
        ns.db.minimap.hide = checked
        local LDBIcon = LibStub("LibDBIcon-1.0", true)
        if LDBIcon then
            if checked then
                LDBIcon:Hide("AutoCombatLogClassic")
            else
                LDBIcon:Show("AutoCombatLogClassic")
            end
        end
    end, ns.db.minimap.hide)
    yOffset = yNew

    -- Footer
    yOffset = yOffset - 20
    local footer = settingsChild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    footer:SetPoint("TOPLEFT", 12, yOffset)
    footer:SetText(ns.ADDON_COLOR .. "AutoCombatLogClassic|r v" .. ns.VERSION .. " — /acl for help")
    footer:SetTextColor(unpack(self.COLORS.TEXT_DIM))
    yOffset = yOffset - 20

    settingsChild:SetHeight(math.abs(yOffset) + 20)

    -- ============================================
    -- HISTORY SCROLL FRAME
    -- ============================================
    local historyScroll, historyChild = self:CreateScrollFrame(frame, SETTINGS_WIDTH - 12, contentHeight)
    historyScroll:SetPoint("TOP", 0, contentTop)
    historyScroll:Hide()
    frame.historyScroll = historyScroll
    frame.historyChild = historyChild

    self.settingsFrame = frame

    -- Register with Blizzard Interface Options
    self:RegisterInterfaceOptions()

    -- Update status on show
    frame:SetScript("OnShow", function()
        ns:UpdateSettingsStatus()
        -- Refresh history if the history tab is visible
        if frame.historyScroll:IsShown() then
            ns:RefreshHistoryDisplay()
        end
    end)
end

----------------------------------------------
-- Refresh History Display
----------------------------------------------
local historyRows = {}
local historyClearBtn = nil

function ns:RefreshHistoryDisplay()
    if not self.settingsFrame or not self.settingsFrame.historyChild then return end

    local container = self.settingsFrame.historyChild

    -- Clear existing rows
    for _, row in ipairs(historyRows) do
        row:Hide()
    end
    if historyClearBtn then historyClearBtn:Hide() end

    local history = self:GetHistory()
    local yOff = -10

    -- Section header
    yOff = self:CreateSectionHeader(container, "Session History", yOff)

    if #history == 0 then
        local row = historyRows[1]
        if not row then
            row = CreateFrame("Frame", nil, container)
            historyRows[1] = row
        end
        row:SetSize(container:GetWidth(), 20)
        row:SetPoint("TOPLEFT", 16, yOff)
        row:Show()

        if not row.emptyText then
            row.emptyText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            row.emptyText:SetPoint("LEFT")
            row.emptyText:SetTextColor(unpack(self.COLORS.TEXT_DIM))
        end
        row.emptyText:SetText("No session history yet.")
        if row.dateText then row.dateText:SetText("") end
        if row.instanceText then row.instanceText:SetText("") end
        if row.durationText then row.durationText:SetText("") end
        if row.statusIcon then row.statusIcon:Hide() end

        yOff = yOff - 24
    else
        -- Column headers
        local headerRow = historyRows[1]
        if not headerRow then
            headerRow = CreateFrame("Frame", nil, container)
            historyRows[1] = headerRow
        end
        headerRow:SetSize(container:GetWidth(), 16)
        headerRow:SetPoint("TOPLEFT", 12, yOff)
        headerRow:Show()

        if not headerRow.dateText then
            headerRow.dateText = headerRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            headerRow.dateText:SetPoint("TOPLEFT", 4, 0)
        end
        headerRow.dateText:SetText(ns.ADDON_COLOR .. "Date|r")

        if not headerRow.instanceText then
            headerRow.instanceText = headerRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            headerRow.instanceText:SetPoint("TOPLEFT", 120, 0)
        end
        headerRow.instanceText:SetText(ns.ADDON_COLOR .. "Instance|r")

        if not headerRow.durationText then
            headerRow.durationText = headerRow:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            headerRow.durationText:SetPoint("TOPLEFT", 280, 0)
        end
        headerRow.durationText:SetText(ns.ADDON_COLOR .. "Duration|r")

        if headerRow.emptyText then headerRow.emptyText:SetText("") end
        if headerRow.statusIcon then headerRow.statusIcon:Hide() end

        yOff = yOff - 18

        -- Separator under header
        if not headerRow.sep then
            headerRow.sep = container:CreateTexture(nil, "ARTWORK")
            headerRow.sep:SetHeight(1)
            headerRow.sep:SetColorTexture(unpack(self.COLORS.SEPARATOR))
        end
        headerRow.sep:ClearAllPoints()
        headerRow.sep:SetPoint("TOPLEFT", 12, yOff)
        headerRow.sep:SetPoint("RIGHT", container, "RIGHT", -12, 0)
        headerRow.sep:Show()
        yOff = yOff - 4

        -- Data rows (all sessions, no limit)
        for i, entry in ipairs(history) do
            local rowIdx = i + 1
            local row = historyRows[rowIdx]
            if not row then
                row = CreateFrame("Frame", nil, container)
                historyRows[rowIdx] = row
            end
            row:SetSize(container:GetWidth() - 24, 18)
            row:SetPoint("TOPLEFT", 12, yOff)
            row:Show()

            -- Alternate row background
            if not row.bg then
                row.bg = row:CreateTexture(nil, "BACKGROUND")
                row.bg:SetAllPoints()
            end
            if i % 2 == 0 then
                row.bg:SetColorTexture(0.08, 0.08, 0.08, 0.5)
            else
                row.bg:SetColorTexture(0, 0, 0, 0)
            end

            -- Status dot
            if not row.statusIcon then
                row.statusIcon = row:CreateTexture(nil, "OVERLAY")
                row.statusIcon:SetSize(6, 6)
                row.statusIcon:SetPoint("TOPLEFT", 4, -6)
            end
            row.statusIcon:Show()
            if entry.status == "completed" then
                row.statusIcon:SetColorTexture(0, 1, 0, 1)
            elseif entry.status == "started" or entry.status == "resumed" then
                row.statusIcon:SetColorTexture(1, 0.8, 0, 1)
            else
                row.statusIcon:SetColorTexture(0.5, 0.5, 0.5, 1)
            end

            -- Date
            if not row.dateText then
                row.dateText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                row.dateText:SetPoint("TOPLEFT", 14, 0)
            end
            row.dateText:SetText(entry.date or "?")
            row.dateText:SetTextColor(unpack(self.COLORS.TEXT_DIM))

            -- Instance name
            if not row.instanceText then
                row.instanceText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                row.instanceText:SetPoint("TOPLEFT", 120, 0)
            end
            row.instanceText:SetText(entry.instanceName or "?")
            row.instanceText:SetTextColor(unpack(self.COLORS.TEXT))

            -- Duration
            if not row.durationText then
                row.durationText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                row.durationText:SetPoint("TOPLEFT", 280, 0)
            end
            if entry.duration then
                row.durationText:SetText(ns:FormatDuration(entry.duration))
                row.durationText:SetTextColor(unpack(self.COLORS.TEXT))
            else
                row.durationText:SetText("In progress")
                row.durationText:SetTextColor(1, 0.8, 0, 1)
            end

            if row.emptyText then row.emptyText:SetText("") end

            yOff = yOff - 18
        end
    end

    -- Clear history button
    yOff = yOff - 12
    if not historyClearBtn then
        historyClearBtn = self:CreateStyledButton(container, 120, 22, "Clear History")
        historyClearBtn:SetScript("OnClick", function()
            ns:ClearHistory()
            ns:RefreshHistoryDisplay()
        end)
    end
    historyClearBtn:ClearAllPoints()
    historyClearBtn:SetPoint("TOPLEFT", 12, yOff)
    historyClearBtn:Show()
    yOff = yOff - 34

    -- Update scrollChild height
    container:SetHeight(math.abs(yOff) + 10)
end

----------------------------------------------
-- Update status display in settings
----------------------------------------------
function ns:UpdateSettingsStatus()
    if not self.settingsFrame then return end

    local frame = self.settingsFrame
    if self:IsLogging() then
        frame.statusLine:SetText("Status: |cff00ff00Active|r")
        self:UpdateStatusDot(frame.statusDot, true)
        frame.statusText:SetText("|cff00ff00ON|r")
        local duration = self:GetFormattedSessionDuration()
        frame.durationLine:SetText("Session: " .. duration)
    else
        frame.statusLine:SetText("Status: |cffff4c4cInactive|r")
        self:UpdateStatusDot(frame.statusDot, false)
        frame.statusText:SetText("|cffff4c4cOFF|r")
        frame.durationLine:SetText("")
    end
end

----------------------------------------------
-- Register with Blizzard Interface Options
----------------------------------------------
function ns:RegisterInterfaceOptions()
    local panel = CreateFrame("Frame")
    panel.name = "AutoCombatLogClassic"

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(self.ADDON_COLOR .. "AutoCombatLogClassic|r")

    local desc = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    desc:SetText("v" .. self.VERSION .. " - Auto Combat Logging for TBC")
    desc:SetTextColor(0.7, 0.7, 0.7)

    local openBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    openBtn:SetSize(200, 30)
    openBtn:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -20)
    openBtn:SetText("Open Settings")
    openBtn:SetScript("OnClick", function()
        ns:OpenSettings()
    end)

    -- Support both old and new Settings API
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        Settings.RegisterAddOnCategory(category)
        self.settingsCategory = category
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end
end

----------------------------------------------
-- Init (called from Core.lua ADDON_LOADED)
----------------------------------------------
function ns:InitSettings()
    -- Settings frame is lazily created on first OpenSettings() call
end
