local _, ns = ...

-- ============================================================
-- Color palette (matching ShareCraft / MyLootTraking style)
-- ============================================================
ns.COLORS = {
    BG          = { 0.06, 0.06, 0.06, 0.92 },
    BG_DARK     = { 0.04, 0.04, 0.04, 1 },
    TITLE_BAR   = { 0.08, 0.08, 0.08, 1 },
    BORDER      = { 0.2, 0.2, 0.2, 1 },
    BORDER_HIGHLIGHT = { 0.4, 0.4, 0.4, 1 },
    BTN         = { 0.15, 0.15, 0.15, 0.9 },
    BTN_HOVER   = { 0.25, 0.25, 0.25, 0.9 },
    ACCENT      = { 0.0, 0.8, 1.0, 1 },
    TEXT        = { 0.9, 0.9, 0.9, 1 },
    TEXT_DIM    = { 0.6, 0.6, 0.6, 1 },
    GREEN       = { 0.0, 1.0, 0.0, 1 },
    RED         = { 1.0, 0.3, 0.3, 1 },
    SEPARATOR   = { 0.25, 0.25, 0.25, 1 },
}

ns.ADDON_COLOR = "|cff00ccff"

local BACKDROP_INFO = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
}

-- ============================================================
-- Core frame helpers
-- ============================================================

function ns:CreateBackdrop(frame, alpha)
    alpha = alpha or 0.92
    if not frame.SetBackdrop and BackdropTemplateMixin then
        Mixin(frame, BackdropTemplateMixin)
    end
    frame:SetBackdrop(BACKDROP_INFO)
    frame:SetBackdropColor(0.06, 0.06, 0.06, alpha)
    frame:SetBackdropBorderColor(unpack(self.COLORS.BORDER))
end

function ns:CreateTitleBar(parent, text)
    local titleBar = CreateFrame("Frame", nil, parent)
    titleBar:SetPoint("TOPLEFT")
    titleBar:SetPoint("TOPRIGHT")
    titleBar:SetHeight(28)

    local bg = titleBar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(unpack(self.COLORS.TITLE_BAR))

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", 12, 0)
    title:SetText(self.ADDON_COLOR .. text .. "|r")

    return titleBar, title
end

function ns:CreateSeparator(parent, yOffset)
    local sep = parent:CreateTexture(nil, "ARTWORK")
    sep:SetHeight(1)
    sep:SetPoint("TOPLEFT", 12, yOffset)
    sep:SetPoint("RIGHT", parent, "RIGHT", -12, 0)
    sep:SetColorTexture(unpack(self.COLORS.SEPARATOR))
    return sep
end

function ns:CreateSectionHeader(parent, text, yOffset)
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOPLEFT", 12, yOffset)
    header:SetText(self.ADDON_COLOR .. text .. "|r")

    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", 12, yOffset - 14)
    line:SetPoint("RIGHT", parent, "RIGHT", -12, 0)
    line:SetHeight(1)
    line:SetColorTexture(unpack(self.COLORS.SEPARATOR))

    return yOffset - 24
end

-- ============================================================
-- Button helpers
-- ============================================================

function ns:CreateStyledButton(parent, width, height, text)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, height)
    btn:SetBackdrop(BACKDROP_INFO)
    btn:SetBackdropColor(unpack(self.COLORS.BTN))
    btn:SetBackdropBorderColor(unpack(self.COLORS.BORDER))

    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btn.text:SetPoint("CENTER")
    btn.text:SetText(text)
    btn.text:SetTextColor(unpack(self.COLORS.TEXT))

    btn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(unpack(ns.COLORS.ACCENT))
        self:SetBackdropColor(unpack(ns.COLORS.BTN_HOVER))
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(unpack(ns.COLORS.BORDER))
        self:SetBackdropColor(unpack(ns.COLORS.BTN))
    end)

    return btn
end

function ns:CreateCloseButton(parent)
    local btn = self:CreateStyledButton(parent, 20, 20, "x")
    btn.text:SetTextColor(unpack(self.COLORS.RED))
    btn:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -6, -4)

    btn:SetScript("OnClick", function() parent:Hide() end)
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropBorderColor(1, 0.3, 0.3, 1)
        self:SetBackdropColor(unpack(ns.COLORS.BTN_HOVER))
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropBorderColor(unpack(ns.COLORS.BORDER))
        self:SetBackdropColor(unpack(ns.COLORS.BTN))
    end)

    return btn
end

-- ============================================================
-- Tab helpers
-- ============================================================

function ns:CreateTab(parent, width, height, text)
    local tab = CreateFrame("Button", nil, parent, "BackdropTemplate")
    tab:SetSize(width, height)
    tab:SetBackdrop(BACKDROP_INFO)
    tab:SetBackdropColor(unpack(self.COLORS.BG))
    tab:SetBackdropBorderColor(unpack(self.COLORS.BORDER))

    tab.text = tab:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    tab.text:SetPoint("CENTER")
    tab.text:SetText(text)

    return tab
end

function ns:SetTabActive(tab)
    tab:SetBackdropBorderColor(unpack(self.COLORS.ACCENT))
    tab.text:SetTextColor(unpack(self.COLORS.ACCENT))
end

function ns:SetTabInactive(tab)
    tab:SetBackdropBorderColor(unpack(self.COLORS.BORDER))
    tab.text:SetTextColor(unpack(self.COLORS.TEXT_DIM))
end

-- ============================================================
-- Checkbox helper
-- ============================================================

function ns:CreateCheckbox(parent, label, yOffset, onChange, defaultValue)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 12, yOffset)
    cb:SetSize(24, 24)
    cb:SetChecked(defaultValue)

    local text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    text:SetText(label)
    text:SetTextColor(unpack(self.COLORS.TEXT))
    cb.label = text

    cb:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        if onChange then onChange(checked) end
    end)

    return cb, yOffset - 28
end

-- ============================================================
-- Scroll frame helper
-- ============================================================

function ns:CreateScrollFrame(parent, width, height)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(width, height)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(width - 20, 1)
    scrollFrame:SetScrollChild(scrollChild)

    -- Style scrollbar
    local scrollBar = scrollFrame.ScrollBar
    if scrollBar then
        scrollBar:ClearAllPoints()
        scrollBar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", -2, -18)
        scrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", -2, 18)

        local thumb = scrollBar:GetThumbTexture()
        if thumb then
            thumb:SetColorTexture(0.3, 0.3, 0.3, 0.8)
            thumb:SetSize(8, 24)
        end
    end

    return scrollFrame, scrollChild
end

-- ============================================================
-- Status indicator (colored dot)
-- ============================================================

function ns:CreateStatusDot(parent, size)
    local dot = parent:CreateTexture(nil, "OVERLAY")
    dot:SetSize(size or 10, size or 10)
    dot:SetColorTexture(unpack(self.COLORS.RED))
    return dot
end

function ns:UpdateStatusDot(dot, active)
    if active then
        dot:SetColorTexture(unpack(self.COLORS.GREEN))
    else
        dot:SetColorTexture(unpack(self.COLORS.RED))
    end
end
