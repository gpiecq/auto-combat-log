local _, ns = ...

local sessionStartTime = nil

function ns:StartSessionTimer()
    sessionStartTime = time()
    ns.db.sessionStartTime = sessionStartTime
end

function ns:StopSessionTimer()
    local duration = "N/A"
    if sessionStartTime then
        local elapsed = time() - sessionStartTime
        duration = ns:FormatDuration(elapsed)
    end
    sessionStartTime = nil
    ns.db.sessionStartTime = nil
    return duration
end

function ns:GetSessionDuration()
    if not sessionStartTime then return nil end
    return time() - sessionStartTime
end

function ns:GetRawSessionDuration()
    if not sessionStartTime then return 0 end
    return time() - sessionStartTime
end

function ns:GetFormattedSessionDuration()
    local elapsed = self:GetSessionDuration()
    if not elapsed then return "Not logging" end
    return self:FormatDuration(elapsed)
end

function ns:FormatDuration(seconds)
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    if hours > 0 then
        return string.format("%dh %02dm %02ds", hours, mins, secs)
    else
        return string.format("%dm %02ds", mins, secs)
    end
end
