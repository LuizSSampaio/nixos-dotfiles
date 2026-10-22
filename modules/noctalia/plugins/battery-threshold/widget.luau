local sysfsPath = noctalia.getConfig("sysfsPath") or "/sys/devices/pci0000:00/0000:00:14.3/PNP0C09:00/VPC2004:00/conservation_mode"
local conservationUnit = noctalia.getConfig("conservationUnit") or "battery-threshold-mode@conservation.service"
local normalUnit = noctalia.getConfig("normalUnit") or "battery-threshold-mode@normal.service"
local pollIntervalMs = noctalia.getConfig("pollIntervalMs") or 10000

local conservationEnabled = false
local busy = false
local lastError = ""

local function updateUI()
  if lastError ~= "" then
    barWidget.setTooltip("Battery threshold error: " .. lastError)
    barWidget.setGlyph("battery")
    barWidget.setGlyphColor("error")
  elseif conservationEnabled then
    barWidget.setGlyph("battery-eco")
    barWidget.setGlyphColor("primary")
    barWidget.setTooltip("Battery conservation mode enabled")
  else
    barWidget.setGlyph("battery")
    barWidget.setGlyphColor("on_surface")
    barWidget.setTooltip("Battery conservation mode disabled")
  end
end

local function refreshState()
  if not sysfsPath or sysfsPath == "" then
    barWidget.setVisible(false)
    return
  end

  barWidget.setVisible(true)

  noctalia.readFileAsync(sysfsPath, function(content, err)
    if err ~= nil then
      lastError = tostring(err)
    elseif content ~= nil then
      lastError = ""
      local trimmed = content:gsub("^%s+", ""):gsub("%s+$", "")
      conservationEnabled = (trimmed == "1")
    end
    updateUI()
  end)
end

function onClick()
  if busy or not sysfsPath or sysfsPath == "" then
    return
  end

  busy = true
  lastError = ""
  local targetUnit = conservationEnabled and normalUnit or conservationUnit

  noctalia.runAsync({"systemctl", "start", targetUnit}, function(result)
    busy = false
    if result and result.exitCode and result.exitCode ~= 0 then
      lastError = (result.stderr or "failed to switch battery mode"):gsub("^%s+", ""):gsub("%s+$", "")
      updateUI()
    else
      refreshState()
    end
  end)
end

function update()
  refreshState()
end

noctalia.setUpdateInterval(pollIntervalMs)
refreshState()
