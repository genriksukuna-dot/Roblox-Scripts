--// ============================================================
--// NEXUS ANALYZER v3.0
--// PROFESSIONAL PASSIVE ROBLOX ANALYZER
--//
--// FEATURES
--// • Knit RE / RF / RP mapping
--// • RemoteEvent / RemoteFunction / UnreliableRemoteEvent
--// • ModuleScript / Tool / Prompt / ClickDetector / Bindable scan
--// • ReplicatedFirst / ReplicatedStorage / Workspace / PlayerGui /
--//   Backpack / Character
--// • Framework detection
--// • Snapshot diff: Added / Removed endpoints
--// • Live replicated-object watcher
--// • Executor compatibility diagnostics
--// • JSON export
--// • Copy All
--// • Search + filters
--// • 450x330 mobile-first UI
--// • Dragging
--// • UI/CoreGui/gethui fallbacks
--// • Clipboard/filesystem fallbacks
--//
--// IMPORTANT
--// This analyzer does NOT:
--// • Fire RemoteEvents
--// • Invoke RemoteFunctions
--// • Hook remotes
--// • Modify game state
--// • Bypass anti-cheat
--//
--// ============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--==============================================================
-- CONFIG
--==============================================================

local CONFIG = {
    Width = 450,
    Height = 330,

    ScanReplicatedStorage = true,
    ScanReplicatedFirst = true,
    ScanWorkspace = true,
    ScanPlayerGui = true,
    ScanBackpack = true,
    ScanCharacter = true,

    WatchLive = true,

    MaxRemoteRows = 250,
    MaxObjectRows = 250,
}

--==============================================================
-- STATE
--==============================================================

local State = {
    Results = {},
    Objects = {},
    Services = {},
    Frameworks = {},

    Seen = {},

    PreviousSnapshot = {},
    CurrentSnapshot = {},

    Added = {},
    Removed = {},

    CurrentTab = "Overview",
    CurrentFilter = "ALL",
    Search = "",

    Scanning = false,
    LiveConnections = {},

    GameName = "Unknown",
}

--==============================================================
-- SAFE API HELPERS
--==============================================================

local function safeCall(fn, ...)
    local ok, result = pcall(fn, ...)
    if ok then
        return result
    end
    return nil
end

local function hasFunction(name)
    local fn = rawget(_G, name)
    return type(fn) == "function"
end

local function getGlobalFunction(name)
    local fn = rawget(_G, name)

    if type(fn) == "function" then
        return fn
    end

    return nil
end

local function getPath(instance)
    return safeCall(function()
        return instance:GetFullName()
    end) or tostring(instance.Name)
end

local function getAttributes(instance)
    local output = {}

    local attrs = safeCall(function()
        return instance:GetAttributes()
    end)

    if not attrs then
        return output
    end

    for name, value in pairs(attrs) do
        table.insert(output, {
            Name = tostring(name),
            Value = tostring(value),
        })
    end

    table.sort(output, function(a, b)
        return a.Name < b.Name
    end)

    return output
end

local function isA(instance, className)
    return safeCall(function()
        return instance:IsA(className)
    end) == true
end

--==============================================================
-- UI PARENT FALLBACK
--==============================================================

local function getGuiParent()
    local gethui = getGlobalFunction("gethui")

    if gethui then
        local result = safeCall(gethui)

        if result then
            return result
        end
    end

    local coreGui = safeCall(function()
        return game:GetService("CoreGui")
    end)

    if coreGui then
        local ok = pcall(function()
            local test = Instance.new("Folder")
            test.Name = "__NexusTest"
            test.Parent = coreGui
            test:Destroy()
        end)

        if ok then
            return coreGui
        end
    end

    return LocalPlayer:WaitForChild("PlayerGui")
end

--==============================================================
-- GAME INFO
--==============================================================

State.GameName = safeCall(function()
    local info = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    return info and info.Name or "Unknown"
end) or "Unknown"

--==============================================================
-- KNIT DETECTION
--==============================================================

local function parseKnitPath(path)
    local serviceName
    local endpointType
    local endpointName

    local types = {
        "RE",
        "RF",
        "RP",
    }

    for _, candidate in ipairs(types) do
        local pattern =
            "%.Services%.([^%.]+)%."
            .. candidate
            .. "%.(.+)$"

        local service, endpoint = string.match(path, pattern)

        if service and endpoint then
            serviceName = service
            endpointType = candidate
            endpointName = endpoint

            break
        end
    end

    return serviceName, endpointType, endpointName
end

local function detectEndpointType(instance)
    local path = getPath(instance)

    local serviceName, knitType = parseKnitPath(path)

    if knitType then
        return knitType, serviceName
    end

    if isA(instance, "RemoteFunction") then
        return "RF", nil
    end

    if isA(instance, "UnreliableRemoteEvent") then
        return "RE", nil
    end

    if isA(instance, "RemoteEvent") then
        return "RE", nil
    end

    return "OTHER", nil
end

--==============================================================
-- SERVICE MAP
--==============================================================

local function getService(serviceName)
    if not serviceName then
        return nil
    end

    if not State.Services[serviceName] then
        State.Services[serviceName] = {
            Name = serviceName,
            RE = {},
            RF = {},
            RP = {},
            Total = 0,
        }
    end

    return State.Services[serviceName]
end

--==============================================================
-- FRAMEWORK DETECTION
--==============================================================

local function addFramework(name)
    State.Frameworks[name] = true
end

local function detectFrameworkFromPath(path)
    local lower = string.lower(path)

    if string.find(lower, "knit", 1, true) then
        addFramework("Knit")
    end

    if string.find(lower, "flamework", 1, true) then
        addFramework("Flamework")
    end

    if string.find(lower, "nevermore", 1, true) then
        addFramework("Nevermore")
    end

    if string.find(lower, "comm", 1, true) then
        addFramework("Comm / Networking")
    end

    if string.find(lower, "promise", 1, true) then
        addFramework("Promise")
    end

    if string.find(lower, "signal", 1, true) then
        addFramework("Signal")
    end
end

--==============================================================
-- REMOTE ADD
--==============================================================

local function addRemote(instance)
    if State.Seen[instance] then
        return
    end

    if not (
        isA(instance, "RemoteEvent")
        or isA(instance, "RemoteFunction")
        or isA(instance, "UnreliableRemoteEvent")
    ) then
        return
    end

    State.Seen[instance] = true

    local path = getPath(instance)
    local endpointType, serviceName = detectEndpointType(instance)

    local service = getService(serviceName)

    local item = {
        Name = instance.Name,
        Class = instance.ClassName,
        Type = endpointType,

        Service = serviceName or "Unknown",

        Parent = instance.Parent
            and getPath(instance.Parent)
            or "nil",

        Path = path,

        Attributes = getAttributes(instance),
    }

    table.insert(State.Results, item)

    if service and service[endpointType] then
        service.Total += 1
        table.insert(service[endpointType], item)
    end

    detectFrameworkFromPath(path)
end

--==============================================================
-- INTERESTING OBJECT SCANNER
--==============================================================

local function addObject(instance)
    local class = instance.ClassName

    local category

    if class == "ModuleScript" then
        category = "Module"

    elseif class == "ProximityPrompt" then
        category = "Prompt"

    elseif class == "ClickDetector" then
        category = "Click"

    elseif class == "Tool" then
        category = "Tool"

    elseif class == "BindableEvent" then
        category = "BindableEvent"

    elseif class == "BindableFunction" then
        category = "BindableFunction"

    elseif class == "Folder" then
        return

    else
        return
    end

    local path = getPath(instance)

    table.insert(State.Objects, {
        Name = instance.Name,
        Class = class,
        Category = category,
        Path = path,
    })

    detectFrameworkFromPath(path)
end

--==============================================================
-- SCAN CONTAINER
--==============================================================

local function scanContainer(container)
    if not container then
        return
    end

    local descendants = safeCall(function()
        return container:GetDescendants()
    end)

    if not descendants then
        return
    end

    for _, instance in ipairs(descendants) do
        addRemote(instance)
        addObject(instance)
    end
end

--==============================================================
-- ROOTS
--==============================================================

local function getScanRoots()
    local roots = {}

    if CONFIG.ScanReplicatedStorage then
        table.insert(roots, ReplicatedStorage)
    end

    if CONFIG.ScanReplicatedFirst then
        table.insert(roots, ReplicatedFirst)
    end

    if CONFIG.ScanWorkspace then
        table.insert(roots, Workspace)
    end

    if LocalPlayer then
        if CONFIG.ScanPlayerGui then
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")

            if PlayerGui then
                table.insert(roots, PlayerGui)
            end
        end

        if CONFIG.ScanBackpack then
            local Backpack = LocalPlayer:FindFirstChild("Backpack")

            if Backpack then
                table.insert(roots, Backpack)
            end
        end

        if CONFIG.ScanCharacter and LocalPlayer.Character then
            table.insert(roots, LocalPlayer.Character)
        end
    end

    return roots
end

--==============================================================
-- SNAPSHOT
--==============================================================

local function makeSnapshot()
    local snapshot = {}

    for _, item in ipairs(State.Results) do
        local key = item.Type .. "::" .. item.Path

        snapshot[key] = {
            Type = item.Type,
            Name = item.Name,
            Service = item.Service,
            Path = item.Path,
        }
    end

    return snapshot
end

local function calculateDiff()
    State.Added = {}
    State.Removed = {}

    for key, item in pairs(State.CurrentSnapshot) do
        if not State.PreviousSnapshot[key] then
            table.insert(State.Added, item)
        end
    end

    for key, item in pairs(State.PreviousSnapshot) do
        if not State.CurrentSnapshot[key] then
            table.insert(State.Removed, item)
        end
    end

    table.sort(State.Added, function(a, b)
        return a.Path < b.Path
    end)

    table.sort(State.Removed, function(a, b)
        return a.Path < b.Path
    end)
end

--==============================================================
-- SCAN
--==============================================================

local function performScan()
    if State.Scanning then
        return
    end

    State.Scanning = true

    State.PreviousSnapshot = State.CurrentSnapshot

    State.Results = {}
    State.Objects = {}
    State.Services = {}
    State.Frameworks = {}
    State.Seen = {}

    for _, root in ipairs(getScanRoots()) do
        scanContainer(root)
    end

    table.sort(State.Results, function(a, b)
        if a.Service ~= b.Service then
            return a.Service:lower() < b.Service:lower()
        end

        if a.Type ~= b.Type then
            return a.Type < b.Type
        end

        return a.Path:lower() < b.Path:lower()
    end)

    table.sort(State.Objects, function(a, b)
        if a.Category ~= b.Category then
            return a.Category < b.Category
        end

        return a.Path:lower() < b.Path:lower()
    end)

    State.CurrentSnapshot = makeSnapshot()

    calculateDiff()

    State.Scanning = false
end

--==============================================================
-- LIVE WATCHER
--==============================================================

local function stopLiveWatcher()
    for _, connection in ipairs(State.LiveConnections) do
        safeCall(function()
            connection:Disconnect()
        end)
    end

    State.LiveConnections = {}
end

local function startLiveWatcher()
    if not CONFIG.WatchLive then
        return
    end

    stopLiveWatcher()

    for _, root in ipairs(getScanRoots()) do
        local connection = root.DescendantAdded:Connect(function(instance)
            task.defer(function()
                addRemote(instance)
                addObject(instance)
            end)
        end)

        table.insert(
            State.LiveConnections,
            connection
        )
    end
end

--==============================================================
-- API DIAGNOSTICS
--==============================================================

local function getCapabilities()
    local capabilityList = {
        {
            Name = "Clipboard",
            Available = hasFunction("setclipboard"),
        },

        {
            Name = "Filesystem",
            Available =
                hasFunction("writefile")
                and hasFunction("readfile"),
        },

        {
            Name = "Make Folder",
            Available = hasFunction("makefolder"),
        },

        {
            Name = "Delete File",
            Available = hasFunction("delfile"),
        },

        {
            Name = "Executor UI Parent",
            Available = hasFunction("gethui"),
        },

        {
            Name = "Global Environment",
            Available = hasFunction("getgenv"),
        },

        {
            Name = "Function Hook API",
            Available = hasFunction("hookfunction"),
        },

        {
            Name = "Metamethod Hook API",
            Available = hasFunction("hookmetamethod"),
        },

        {
            Name = "GC Inspection",
            Available = hasFunction("getgc"),
        },

        {
            Name = "Connection Inspection",
            Available = hasFunction("getconnections"),
        },

        {
            Name = "Namecall Method",
            Available = hasFunction("getnamecallmethod"),
        },
    }

    return capabilityList
end

--==============================================================
-- JSON REPORT
--==============================================================

local function buildData()
    local re = 0
    local rf = 0
    local rp = 0

    for _, item in ipairs(State.Results) do
        if item.Type == "RE" then
            re += 1

        elseif item.Type == "RF" then
            rf += 1

        elseif item.Type == "RP" then
            rp += 1
        end
    end

    local frameworks = {}

    for framework in pairs(State.Frameworks) do
        table.insert(frameworks, framework)
    end

    table.sort(frameworks)

    local services = {}

    for serviceName, service in pairs(State.Services) do
        services[serviceName] = {
            Total = service.Total,
            RE = service.RE,
            RF = service.RF,
            RP = service.RP,
        }
    end

    return {
        Analyzer = {
            Name = "Nexus Analyzer",
            Version = "3.0",
        },

        Game = {
            Name = State.GameName,
            PlaceId = game.PlaceId,
            GameId = game.GameId,
            JobId = game.JobId,
            Player = LocalPlayer and LocalPlayer.Name or "Unknown",
        },

        Summary = {
            Total = #State.Results,
            RemoteEvents = re,
            RemoteFunctions = rf,
            RemoteProperties = rp,
            InterestingObjects = #State.Objects,
            KnitServices = 0,
            Added = #State.Added,
            Removed = #State.Removed,
        },

        Frameworks = frameworks,

        Services = services,

        Remotes = State.Results,

        Objects = State.Objects,

        Diff = {
            Added = State.Added,
            Removed = State.Removed,
        },

        Capabilities = getCapabilities(),
    }
end

--==============================================================
-- TEXT REPORT
--==============================================================

local function buildReport()
    local data = buildData()

    local lines = {}

    table.insert(lines, "============================================================")
    table.insert(lines, "NEXUS ANALYZER v3.0")
    table.insert(lines, "============================================================")

    table.insert(lines, "")
    table.insert(lines, "GAME")
    table.insert(lines, "Name     : " .. tostring(data.Game.Name))
    table.insert(lines, "PlaceId  : " .. tostring(data.Game.PlaceId))
    table.insert(lines, "GameId   : " .. tostring(data.Game.GameId))
    table.insert(lines, "JobId    : " .. tostring(data.Game.JobId))
    table.insert(lines, "Player   : " .. tostring(data.Game.Player))

    table.insert(lines, "")
    table.insert(lines, "SUMMARY")
    table.insert(lines, "Total Remote Endpoints : " .. tostring(data.Summary.Total))
    table.insert(lines, "RemoteEvent            : " .. tostring(data.Summary.RemoteEvents))
    table.insert(lines, "RemoteFunction         : " .. tostring(data.Summary.RemoteFunctions))
    table.insert(lines, "RemoteProperty         : " .. tostring(data.Summary.RemoteProperties))
    table.insert(lines, "Interesting Objects    : " .. tostring(data.Summary.InterestingObjects))
    table.insert(lines, "Knit / Service Count   : " .. tostring(#(function()
        local temp = {}
        for serviceName in pairs(State.Services) do
            temp[serviceName] = true
        end

        local count = 0

        for _ in pairs(temp) do
            count += 1
        end

        return temp
    end)()))
    table.insert(lines, "Added Since Snapshot   : " .. tostring(data.Summary.Added))
    table.insert(lines, "Removed Since Snapshot : " .. tostring(data.Summary.Removed))

    table.insert(lines, "")
    table.insert(lines, "FRAMEWORKS")

    if #data.Frameworks == 0 then
        table.insert(lines, "None detected")
    else
        for _, framework in ipairs(data.Frameworks) do
            table.insert(lines, "- " .. framework)
        end
    end

    table.insert(lines, "")
    table.insert(lines, "============================================================")
    table.insert(lines, "SERVICE MAP")
    table.insert(lines, "============================================================")

    local serviceNames = {}

    for serviceName in pairs(State.Services) do
        table.insert(serviceNames, serviceName)
    end

    table.sort(serviceNames)

    for _, serviceName in ipairs(serviceNames) do
        local service = State.Services[serviceName]

        table.insert(lines, "")
        table.insert(
            lines,
            "[" .. serviceName .. "] Total: " .. tostring(service.Total)
        )

        if #service.RF > 0 then
            table.insert(lines, "  RF:")

            for _, item in ipairs(service.RF) do
                table.insert(
                    lines,
                    "    " .. item.Name .. " -> " .. item.Path
                )
            end
        end

        if #service.RE > 0 then
            table.insert(lines, "  RE:")

            for _, item in ipairs(service.RE) do
                table.insert(
                    lines,
                    "    " .. item.Name .. " -> " .. item.Path
                )
            end
        end

        if #service.RP > 0 then
            table.insert(lines, "  RP:")

            for _, item in ipairs(service.RP) do
                table.insert(
                    lines,
                    "    " .. item.Name .. " -> " .. item.Path
                )
            end
        end
    end

    table.insert(lines, "")
    table.insert(lines, "============================================================")
    table.insert(lines, "ENDPOINTS")
    table.insert(lines, "============================================================")

    for index, item in ipairs(State.Results) do
        table.insert(lines, "")
        table.insert(
            lines,
            string.format(
                "[%03d] [%s] %s",
                index,
                item.Type,
                item.Name
            )
        )

        table.insert(lines, "Class   : " .. item.Class)
        table.insert(lines, "Service : " .. item.Service)
        table.insert(lines, "Parent  : " .. item.Parent)
        table.insert(lines, "Path    : " .. item.Path)

        if #item.Attributes > 0 then
            table.insert(lines, "Attributes:")

            for _, attribute in ipairs(item.Attributes) do
                table.insert(
                    lines,
                    "  "
                    .. attribute.Name
                    .. " = "
                    .. attribute.Value
                )
            end
        end
    end

    table.insert(lines, "")
    table.insert(lines, "============================================================")
    table.insert(lines, "INTERESTING OBJECTS")
    table.insert(lines, "============================================================")

    for index, item in ipairs(State.Objects) do
        if index > CONFIG.MaxObjectRows then
            break
        end

        table.insert(
            lines,
            string.format(
                "[%03d] [%s] %s",
                index,
                item.Category,
                item.Name
            )
        )

        table.insert(lines, "Class : " .. item.Class)
        table.insert(lines, "Path  : " .. item.Path)
    end

    table.insert(lines, "")
    table.insert(lines, "============================================================")
    table.insert(lines, "SNAPSHOT DIFF")
    table.insert(lines, "============================================================")

    table.insert(lines, "ADDED")

    if #State.Added == 0 then
        table.insert(lines, "  none")
    else
        for _, item in ipairs(State.Added) do
            table.insert(
                lines,
                "  [" .. item.Type .. "] " .. item.Path
            )
        end
    end

    table.insert(lines, "")
    table.insert(lines, "REMOVED")

    if #State.Removed == 0 then
        table.insert(lines, "  none")
    else
        for _, item in ipairs(State.Removed) do
            table.insert(
                lines,
                "  [" .. item.Type .. "] " .. item.Path
            )
        end
    end

    table.insert(lines, "")
    table.insert(lines, "============================================================")
    table.insert(lines, "CAPABILITIES")
    table.insert(lines, "============================================================")

    for _, capability in ipairs(data.Capabilities) do
        table.insert(
            lines,
            string.format(
                "%-24s : %s",
                capability.Name,
                capability.Available and "YES" or "NO"
            )
        )
    end

    table.insert(lines, "")
    table.insert(lines, "============================================================")
    table.insert(lines, "SAFETY / SCOPE")
    table.insert(lines, "============================================================")
    table.insert(lines, "Only client-visible objects are analyzed.")
    table.insert(lines, "Server-only objects are not exposed.")
    table.insert(lines, "RemoteEvents are not fired.")
    table.insert(lines, "RemoteFunctions are not invoked.")
    table.insert(lines, "No hooks are installed.")
    table.insert(lines, "No anti-cheat bypass is performed.")
    table.insert(lines, "============================================================")

    return table.concat(lines, "\n")
end

--==============================================================
-- GUI
--==============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "NexusAnalyzerV3"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = getGuiParent()

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(
    CONFIG.Width,
    CONFIG.Height
)
main.Position = UDim2.new(
    0.5,
    -CONFIG.Width / 2,
    0.5,
    -CONFIG.Height / 2
)
main.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(64, 76, 105)
mainStroke.Transparency = 0.2
mainStroke.Thickness = 1
mainStroke.Parent = main

local gradient = Instance.new("UIGradient")
gradient.Rotation = 90
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(
        0,
        Color3.fromRGB(14, 18, 29)
    ),
    ColorSequenceKeypoint.new(
        1,
        Color3.fromRGB(7, 9, 14)
    ),
})
gradient.Parent = main

--==============================================================
-- TOPBAR
--==============================================================

local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, 0, 0, 42)
topbar.BackgroundColor3 = Color3.fromRGB(13, 16, 25)
topbar.BorderSizePixel = 0
topbar.Parent = main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 14)
topCorner.Parent = topbar

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(14, 5)
title.Size = UDim2.fromOffset(190, 20)
title.Text = "NEXUS ANALYZER"
title.TextColor3 = Color3.fromRGB(240, 243, 255)
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topbar

local sub = Instance.new("TextLabel")
sub.BackgroundTransparency = 1
sub.Position = UDim2.fromOffset(15, 24)
sub.Size = UDim2.fromOffset(250, 13)
sub.Text = "PASSIVE GAME STRUCTURE ANALYSIS"
sub.TextColor3 = Color3.fromRGB(92, 104, 130)
sub.TextSize = 8
sub.Font = Enum.Font.GothamMedium
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.Parent = topbar

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(28, 28)
close.Position = UDim2.new(1, -35, 0, 7)
close.BackgroundColor3 = Color3.fromRGB(29, 32, 43)
close.Text = "×"
close.TextColor3 = Color3.fromRGB(230, 234, 245)
close.TextSize = 19
close.Font = Enum.Font.GothamBold
close.AutoButtonColor = false
close.Parent = topbar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = close

close.Activated:Connect(function()
    gui.Enabled = false
end)

--==============================================================
-- DRAG
--==============================================================

local dragging = false
local dragStart
local startPosition
local dragInput

topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = main.Position
        dragInput = input

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

topbar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

--==============================================================
-- TAB BAR
--==============================================================

local tabs = Instance.new("Frame")
tabs.BackgroundTransparency = 1
tabs.Position = UDim2.fromOffset(10, 48)
tabs.Size = UDim2.new(1, -20, 0, 28)
tabs.Parent = main

local tabButtons = {}

local tabNames = {
    "Overview",
    "Remotes",
    "Objects",
    "Diff",
    "API",
}

local function createTab(name, x)
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(80, 25)
    button.Position = UDim2.fromOffset(x, 0)
    button.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = Color3.fromRGB(130, 141, 164)
    button.TextSize = 8
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Parent = tabs

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button

    tabButtons[name] = button

    return button
end

for index, name in ipairs(tabNames) do
    local button = createTab(
        name,
        (index - 1) * 85
    )

    button.Activated:Connect(function()
        State.CurrentTab = name

        for tabName, tabButton in pairs(tabButtons) do
            if tabName == name then
                tabButton.BackgroundColor3 = Color3.fromRGB(28, 42, 72)
                tabButton.TextColor3 = Color3.fromRGB(172, 202, 255)
            else
                tabButton.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
                tabButton.TextColor3 = Color3.fromRGB(130, 141, 164)
            end
        end
    end)
end

tabButtons.Overview.BackgroundColor3 = Color3.fromRGB(28, 42, 72)
tabButtons.Overview.TextColor3 = Color3.fromRGB(172, 202, 255)

--==============================================================
-- CONTENT HOLDER
--==============================================================

local content = Instance.new("Frame")
content.BackgroundTransparency = 1
content.Position = UDim2.fromOffset(10, 82)
content.Size = UDim2.new(1, -20, 0, 210)
content.Parent = main

--==============================================================
-- OVERVIEW
--==============================================================

local overview = Instance.new("Frame")
overview.BackgroundTransparency = 1
overview.Size = UDim2.fromScale(1, 1)
overview.Parent = content

local overviewTitle = Instance.new("TextLabel")
overviewTitle.BackgroundTransparency = 1
overviewTitle.Position = UDim2.fromOffset(4, 4)
overviewTitle.Size = UDim2.new(1, -8, 0, 18)
overviewTitle.Text = "GAME OVERVIEW"
overviewTitle.TextColor3 = Color3.fromRGB(214, 220, 235)
overviewTitle.TextSize = 11
overviewTitle.Font = Enum.Font.GothamBold
overviewTitle.TextXAlignment = Enum.TextXAlignment.Left
overviewTitle.Parent = overview

local gameLabel = Instance.new("TextLabel")
gameLabel.BackgroundTransparency = 1
gameLabel.Position = UDim2.fromOffset(4, 27)
gameLabel.Size = UDim2.new(1, -8, 0, 18)
gameLabel.Text = State.GameName
gameLabel.TextColor3 = Color3.fromRGB(235, 239, 250)
gameLabel.TextSize = 13
gameLabel.Font = Enum.Font.GothamBold
gameLabel.TextXAlignment = Enum.TextXAlignment.Left
gameLabel.Parent = overview

local placeLabel = Instance.new("TextLabel")
placeLabel.BackgroundTransparency = 1
placeLabel.Position = UDim2.fromOffset(4, 48)
placeLabel.Size = UDim2.new(1, -8, 0, 14)
placeLabel.Text =
    "PlaceId: "
    .. tostring(game.PlaceId)
    .. "   •   GameId: "
    .. tostring(game.GameId)
placeLabel.TextColor3 = Color3.fromRGB(95, 108, 134)
placeLabel.TextSize = 8
placeLabel.Font = Enum.Font.GothamMedium
placeLabel.TextXAlignment = Enum.TextXAlignment.Left
placeLabel.Parent = overview

local frameworkLabel = Instance.new("TextLabel")
frameworkLabel.BackgroundTransparency = 1
frameworkLabel.Position = UDim2.fromOffset(4, 67)
frameworkLabel.Size = UDim2.new(1, -8, 0, 25)
frameworkLabel.Text = "Frameworks: scanning..."
frameworkLabel.TextColor3 = Color3.fromRGB(153, 182, 231)
frameworkLabel.TextSize = 9
frameworkLabel.Font = Enum.Font.GothamBold
frameworkLabel.TextWrapped = true
frameworkLabel.TextXAlignment = Enum.TextXAlignment.Left
frameworkLabel.Parent = overview

--==============================================================
-- STAT BOXES
--==============================================================

local statValues = {}

local function makeStat(label, x, y)
    local box = Instance.new("Frame")
    box.Size = UDim2.fromOffset(98, 47)
    box.Position = UDim2.fromOffset(x, y)
    box.BackgroundColor3 = Color3.fromRGB(15, 18, 27)
    box.BorderSizePixel = 0
    box.Parent = overview

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = box

    local value = Instance.new("TextLabel")
    value.BackgroundTransparency = 1
    value.Position = UDim2.fromOffset(7, 4)
    value.Size = UDim2.new(1, -14, 0, 21)
    value.Text = "0"
    value.TextColor3 = Color3.fromRGB(235, 240, 255)
    value.TextSize = 15
    value.Font = Enum.Font.GothamBold
    value.Parent = box

    local caption = Instance.new("TextLabel")
    caption.BackgroundTransparency = 1
    caption.Position = UDim2.fromOffset(7, 27)
    caption.Size = UDim2.new(1, -14, 0, 13)
    caption.Text = label
    caption.TextColor3 = Color3.fromRGB(93, 105, 128)
    caption.TextSize = 8
    caption.Font = Enum.Font.GothamMedium
    caption.Parent = box

    statValues[label] = value
end

makeStat("TOTAL", 4, 100)
makeStat("RF", 108, 100)
makeStat("RE", 212, 100)
makeStat("RP", 316, 100)

makeStat("OBJECTS", 4, 154)
makeStat("ADDED", 108, 154)
makeStat("REMOVED", 212, 154)
makeStat("SERVICES", 316, 154)

--==============================================================
-- REMOTE VIEW
--==============================================================

local remoteView = Instance.new("Frame")
remoteView.BackgroundTransparency = 1
remoteView.Size = UDim2.fromScale(1, 1)
remoteView.Visible = false
remoteView.Parent = content

local search = Instance.new("TextBox")
search.Size = UDim2.fromOffset(205, 29)
search.Position = UDim2.fromOffset(0, 0)
search.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
search.BorderSizePixel = 0
search.PlaceholderText = "Search remote / service..."
search.PlaceholderColor3 = Color3.fromRGB(82, 94, 117)
search.Text = ""
search.TextColor3 = Color3.fromRGB(230, 235, 248)
search.TextSize = 9
search.Font = Enum.Font.GothamMedium
search.ClearTextOnFocus = false
search.Parent = remoteView

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 8)
searchCorner.Parent = search

local copyButton = Instance.new("TextButton")
copyButton.Size = UDim2.fromOffset(105, 29)
copyButton.Position = UDim2.fromOffset(215, 0)
copyButton.BackgroundColor3 = Color3.fromRGB(24, 36, 61)
copyButton.BorderSizePixel = 0
copyButton.Text = "COPY ALL"
copyButton.TextColor3 = Color3.fromRGB(168, 198, 255)
copyButton.TextSize = 9
copyButton.Font = Enum.Font.GothamBold
copyButton.AutoButtonColor = false
copyButton.Parent = remoteView

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 8)
copyCorner.Parent = copyButton

local scanButton = Instance.new("TextButton")
scanButton.Size = UDim2.fromOffset(105, 29)
scanButton.Position = UDim2.fromOffset(325, 0)
scanButton.BackgroundColor3 = Color3.fromRGB(20, 23, 32)
scanButton.BorderSizePixel = 0
scanButton.Text = "RESCAN"
scanButton.TextColor3 = Color3.fromRGB(206, 214, 231)
scanButton.TextSize = 9
scanButton.Font = Enum.Font.GothamBold
scanButton.AutoButtonColor = false
scanButton.Parent = remoteView

local scanCorner = Instance.new("UICorner")
scanCorner.CornerRadius = UDim.new(0, 8)
scanCorner.Parent = scanButton

local remoteFilters = Instance.new("Frame")
remoteFilters.BackgroundTransparency = 1
remoteFilters.Position = UDim2.fromOffset(0, 35)
remoteFilters.Size = UDim2.new(1, 0, 0, 25)
remoteFilters.Parent = remoteView

local filterButtons = {}

for index, name in ipairs({
    "ALL",
    "RF",
    "RE",
    "RP",
}) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(70, 24)
    button.Position = UDim2.fromOffset((index - 1) * 75, 0)
    button.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = Color3.fromRGB(133, 144, 168)
    button.TextSize = 8
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Parent = remoteFilters

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button

    filterButtons[name] = button
end

filterButtons.ALL.BackgroundColor3 = Color3.fromRGB(28, 42, 72)
filterButtons.ALL.TextColor3 = Color3.fromRGB(170, 200, 255)

local remoteList = Instance.new("ScrollingFrame")
remoteList.Position = UDim2.fromOffset(0, 66)
remoteList.Size = UDim2.new(1, 0, 0, 140)
remoteList.BackgroundColor3 = Color3.fromRGB(7, 9, 14)
remoteList.BorderSizePixel = 0
remoteList.ScrollBarThickness = 3
remoteList.ScrollBarImageColor3 = Color3.fromRGB(62, 73, 101)
remoteList.CanvasSize = UDim2.fromOffset(0, 0)
remoteList.Parent = remoteView

local remoteListCorner = Instance.new("UICorner")
remoteListCorner.CornerRadius = UDim.new(0, 9)
remoteListCorner.Parent = remoteList

local remotePadding = Instance.new("UIPadding")
remotePadding.PaddingTop = UDim.new(0, 5)
remotePadding.PaddingLeft = UDim.new(0, 5)
remotePadding.PaddingRight = UDim.new(0, 5)
remotePadding.PaddingBottom = UDim.new(0, 5)
remotePadding.Parent = remoteList

local remoteLayout = Instance.new("UIListLayout")
remoteLayout.Padding = UDim.new(0, 3)
remoteLayout.SortOrder = Enum.SortOrder.LayoutOrder
remoteLayout.Parent = remoteList

--==============================================================
-- OBJECT VIEW
--==============================================================

local objectView = Instance.new("Frame")
objectView.BackgroundTransparency = 1
objectView.Size = UDim2.fromScale(1, 1)
objectView.Visible = false
objectView.Parent = content

local objectTitle = Instance.new("TextLabel")
objectTitle.BackgroundTransparency = 1
objectTitle.Position = UDim2.fromOffset(4, 2)
objectTitle.Size = UDim2.new(1, -8, 0, 20)
objectTitle.Text = "INTERESTING REPLICATED OBJECTS"
objectTitle.TextColor3 = Color3.fromRGB(218, 224, 239)
objectTitle.TextSize = 10
objectTitle.Font = Enum.Font.GothamBold
objectTitle.TextXAlignment = Enum.TextXAlignment.Left
objectTitle.Parent = objectView

local objectList = Instance.new("ScrollingFrame")
objectList.Position = UDim2.fromOffset(0, 27)
objectList.Size = UDim2.new(1, 0, 0, 180)
objectList.BackgroundColor3 = Color3.fromRGB(7, 9, 14)
objectList.BorderSizePixel = 0
objectList.ScrollBarThickness = 3
objectList.ScrollBarImageColor3 = Color3.fromRGB(62, 73, 101)
objectList.CanvasSize = UDim2.fromOffset(0, 0)
objectList.Parent = objectView

local objectCorner = Instance.new("UICorner")
objectCorner.CornerRadius = UDim.new(0, 9)
objectCorner.Parent = objectList

local objectPadding = Instance.new("UIPadding")
objectPadding.PaddingTop = UDim.new(0, 5)
objectPadding.PaddingLeft = UDim.new(0, 5)
objectPadding.PaddingRight = UDim.new(0, 5)
objectPadding.PaddingBottom = UDim.new(0, 5)
objectPadding.Parent = objectList

local objectLayout = Instance.new("UIListLayout")
objectLayout.Padding = UDim.new(0, 3)
objectLayout.Parent = objectList

--==============================================================
-- DIFF VIEW
--==============================================================

local diffView = Instance.new("Frame")
diffView.BackgroundTransparency = 1
diffView.Size = UDim2.fromScale(1, 1)
diffView.Visible = false
diffView.Parent = content

local diffTitle = Instance.new("TextLabel")
diffTitle.BackgroundTransparency = 1
diffTitle.Position = UDim2.fromOffset(4, 2)
diffTitle.Size = UDim2.new(1, -8, 0, 20)
diffTitle.Text = "SNAPSHOT DIFF"
diffTitle.TextColor3 = Color3.fromRGB(218, 224, 239)
diffTitle.TextSize = 10
diffTitle.Font = Enum.Font.GothamBold
diffTitle.TextXAlignment = Enum.TextXAlignment.Left
diffTitle.Parent = diffView

local diffInfo = Instance.new("TextLabel")
diffInfo.BackgroundTransparency = 1
diffInfo.Position = UDim2.fromOffset(4, 25)
diffInfo.Size = UDim2.new(1, -8, 0, 35)
diffInfo.Text = "No changes"
diffInfo.TextColor3 = Color3.fromRGB(125, 140, 164)
diffInfo.TextSize = 9
diffInfo.Font = Enum.Font.GothamMedium
diffInfo.TextWrapped = true
diffInfo.TextXAlignment = Enum.TextXAlignment.Left
diffInfo.Parent = diffView

local diffList = Instance.new("ScrollingFrame")
diffList.Position = UDim2.fromOffset(0, 66)
diffList.Size = UDim2.new(1, 0, 0, 140)
diffList.BackgroundColor3 = Color3.fromRGB(7, 9, 14)
diffList.BorderSizePixel = 0
diffList.ScrollBarThickness = 3
diffList.ScrollBarImageColor3 = Color3.fromRGB(62, 73, 101)
diffList.CanvasSize = UDim2.fromOffset(0, 0)
diffList.Parent = diffView

local diffCorner = Instance.new("UICorner")
diffCorner.CornerRadius = UDim.new(0, 9)
diffCorner.Parent = diffList

local diffPadding = Instance.new("UIPadding")
diffPadding.PaddingTop = UDim.new(0, 5)
diffPadding.PaddingLeft = UDim.new(0, 5)
diffPadding.PaddingRight = UDim.new(0, 5)
diffPadding.Parent = diffList

local diffLayout = Instance.new("UIListLayout")
diffLayout.Padding = UDim.new(0, 3)
diffLayout.Parent = diffList

--==============================================================
-- API VIEW
--==============================================================

local apiView = Instance.new("Frame")
apiView.BackgroundTransparency = 1
apiView.Size = UDim2.fromScale(1, 1)
apiView.Visible = false
apiView.Parent = content

local apiTitle = Instance.new("TextLabel")
apiTitle.BackgroundTransparency = 1
apiTitle.Position = UDim2.fromOffset(4, 2)
apiTitle.Size = UDim2.new(1, -8, 0, 20)
apiTitle.Text = "ENVIRONMENT CAPABILITIES"
apiTitle.TextColor3 = Color3.fromRGB(218, 224, 239)
apiTitle.TextSize = 10
apiTitle.Font = Enum.Font.GothamBold
apiTitle.TextXAlignment = Enum.TextXAlignment.Left
apiTitle.Parent = apiView

local apiList = Instance.new("ScrollingFrame")
apiList.Position = UDim2.fromOffset(0, 27)
apiList.Size = UDim2.new(1, 0, 0, 180)
apiList.BackgroundColor3 = Color3.fromRGB(7, 9, 14)
apiList.BorderSizePixel = 0
apiList.ScrollBarThickness = 3
apiList.ScrollBarImageColor3 = Color3.fromRGB(62, 73, 101)
apiList.CanvasSize = UDim2.fromOffset(0, 0)
apiList.Parent = apiView

local apiCorner = Instance.new("UICorner")
apiCorner.CornerRadius = UDim.new(0, 9)
apiCorner.Parent = apiList

local apiPadding = Instance.new("UIPadding")
apiPadding.PaddingTop = UDim.new(0, 5)
apiPadding.PaddingLeft = UDim.new(0, 5)
apiPadding.PaddingRight = UDim.new(0, 5)
apiPadding.Parent = apiList

local apiLayout = Instance.new("UIListLayout")
apiLayout.Padding = UDim.new(0, 3)
apiLayout.Parent = apiList

--==============================================================
-- RENDER HELPERS
--==============================================================

local toast = Instance.new("TextLabel")
toast.Size = UDim2.fromOffset(210, 28)
toast.Position = UDim2.new(0.5, -105, 1, 7)
toast.BackgroundColor3 = Color3.fromRGB(18, 24, 37)
toast.BorderSizePixel = 0
toast.TextColor3 = Color3.fromRGB(218, 227, 250)
toast.TextSize = 8
toast.Font = Enum.Font.GothamBold
toast.Visible = false
toast.Parent = main

local toastCorner = Instance.new("UICorner")
toastCorner.CornerRadius = UDim.new(0, 8)
toastCorner.Parent = toast

local function showToast(message)
    toast.Text = message
    toast.Visible = true

    toast.Position = UDim2.new(
        0.5,
        -105,
        1,
        7
    )

    local inTween = TweenService:Create(
        toast,
        TweenInfo.new(0.18),
        {
            Position = UDim2.new(
                0.5,
                -105,
                1,
                -37
            ),
        }
    )

    inTween:Play()

    task.delay(1.5, function()
        if not toast.Visible then
            return
        end

        local outTween = TweenService:Create(
            toast,
            TweenInfo.new(0.18),
            {
                Position = UDim2.new(
                    0.5,
                    -105,
                    1,
                    7
                ),
            }
        )

        outTween:Play()

        outTween.Completed:Wait()

        toast.Visible = false
    end)
end

local function clearContainer(container)
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

--==============================================================
-- RENDER REMOTES
--==============================================================

local function remoteMatches(item)
    if State.CurrentFilter ~= "ALL"
        and item.Type ~= State.CurrentFilter then

        return false
    end

    local query = string.lower(State.Search)

    if query == "" then
        return true
    end

    return
        string.find(string.lower(item.Name), query, 1, true)
        or string.find(string.lower(item.Service), query, 1, true)
        or string.find(string.lower(item.Path), query, 1, true)
end

local function renderRemotes()
    clearContainer(remoteList)

    local shown = 0

    for _, item in ipairs(State.Results) do
        if remoteMatches(item) then
            shown += 1

            if shown > CONFIG.MaxRemoteRows then
                break
            end

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -5, 0, 40)
            row.BackgroundColor3 = Color3.fromRGB(13, 16, 24)
            row.BorderSizePixel = 0
            row.Parent = remoteList

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 7)
            corner.Parent = row

            local typeLabel = Instance.new("TextLabel")
            typeLabel.Size = UDim2.fromOffset(34, 19)
            typeLabel.Position = UDim2.fromOffset(6, 10)
            typeLabel.BackgroundColor3 =
                item.Type == "RF"
                and Color3.fromRGB(49, 35, 64)
                or item.Type == "RP"
                and Color3.fromRGB(28, 54, 57)
                or Color3.fromRGB(24, 46, 67)

            typeLabel.Text = item.Type
            typeLabel.TextColor3 =
                item.Type == "RF"
                and Color3.fromRGB(210, 171, 255)
                or item.Type == "RP"
                and Color3.fromRGB(150, 225, 220)
                or Color3.fromRGB(153, 200, 255)

            typeLabel.TextSize = 7
            typeLabel.Font = Enum.Font.GothamBold
            typeLabel.Parent = row

            local typeCorner = Instance.new("UICorner")
            typeCorner.CornerRadius = UDim.new(0, 5)
            typeCorner.Parent = typeLabel

            local nameLabel = Instance.new("TextLabel")
            nameLabel.BackgroundTransparency = 1
            nameLabel.Position = UDim2.fromOffset(48, 3)
            nameLabel.Size = UDim2.new(1, -55, 0, 16)
            nameLabel.Text = item.Name
            nameLabel.TextColor3 = Color3.fromRGB(228, 232, 243)
            nameLabel.TextSize = 9
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            nameLabel.Parent = row

            local pathLabel = Instance.new("TextLabel")
            pathLabel.BackgroundTransparency = 1
            pathLabel.Position = UDim2.fromOffset(48, 20)
            pathLabel.Size = UDim2.new(1, -55, 0, 13)
            pathLabel.Text =
                item.Service
                .. " • "
                .. item.Path
            pathLabel.TextColor3 = Color3.fromRGB(88, 103, 128)
            pathLabel.TextSize = 6
            pathLabel.Font = Enum.Font.GothamMedium
            pathLabel.TextXAlignment = Enum.TextXAlignment.Left
            pathLabel.TextTruncate = Enum.TextTruncate.AtEnd
            pathLabel.Parent = row
        end
    end

    remoteList.CanvasSize = UDim2.fromOffset(
        0,
        remoteLayout.AbsoluteContentSize.Y + 10
    )
end

--==============================================================
-- RENDER OBJECTS
--==============================================================

local function renderObjects()
    clearContainer(objectList)

    for index, item in ipairs(State.Objects) do
        if index > CONFIG.MaxObjectRows then
            break
        end

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -5, 0, 36)
        row.BackgroundColor3 = Color3.fromRGB(13, 16, 24)
        row.BorderSizePixel = 0
        row.Parent = objectList

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 7)
        corner.Parent = row

        local category = Instance.new("TextLabel")
        category.Size = UDim2.fromOffset(75, 18)
        category.Position = UDim2.fromOffset(6, 9)
        category.BackgroundColor3 = Color3.fromRGB(22, 27, 39)
        category.Text = item.Category
        category.TextColor3 = Color3.fromRGB(146, 169, 205)
        category.TextSize = 7
        category.Font = Enum.Font.GothamBold
        category.Parent = row

        local categoryCorner = Instance.new("UICorner")
        categoryCorner.CornerRadius = UDim.new(0, 5)
        categoryCorner.Parent = category

        local name = Instance.new("TextLabel")
        name.BackgroundTransparency = 1
        name.Position = UDim2.fromOffset(88, 3)
        name.Size = UDim2.new(1, -94, 0, 15)
        name.Text = item.Name
        name.TextColor3 = Color3.fromRGB(225, 230, 242)
        name.TextSize = 8
        name.Font = Enum.Font.GothamBold
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.TextTruncate = Enum.TextTruncate.AtEnd
        name.Parent = row

        local path = Instance.new("TextLabel")
        path.BackgroundTransparency = 1
        path.Position = UDim2.fromOffset(88, 19)
        path.Size = UDim2.new(1, -94, 0, 11)
        path.Text = item.Path
        path.TextColor3 = Color3.fromRGB(88, 103, 128)
        path.TextSize = 6
        path.Font = Enum.Font.GothamMedium
        path.TextXAlignment = Enum.TextXAlignment.Left
        path.TextTruncate = Enum.TextTruncate.AtEnd
        path.Parent = row
    end

    objectList.CanvasSize = UDim2.fromOffset(
        0,
        objectLayout.AbsoluteContentSize.Y + 10
    )
end

--==============================================================
-- RENDER DIFF
--==============================================================

local function renderDiff()
    clearContainer(diffList)

    diffInfo.Text =
        "Added: "
        .. tostring(#State.Added)
        .. "    Removed: "
        .. tostring(#State.Removed)

    local count = 0

    for _, item in ipairs(State.Added) do
        count += 1

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -5, 0, 29)
        row.BackgroundColor3 = Color3.fromRGB(14, 27, 21)
        row.BorderSizePixel = 0
        row.Parent = diffList

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Position = UDim2.fromOffset(8, 0)
        label.Size = UDim2.new(1, -16, 1, 0)
        label.Text =
            "+  "
            .. item.Type
            .. "  "
            .. item.Path
        label.TextColor3 = Color3.fromRGB(128, 220, 165)
        label.TextSize = 7
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.Parent = row
    end

    for _, item in ipairs(State.Removed) do
        count += 1

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -5, 0, 29)
        row.BackgroundColor3 = Color3.fromRGB(31, 18, 20)
        row.BorderSizePixel = 0
        row.Parent = diffList

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Position = UDim2.fromOffset(8, 0)
        label.Size = UDim2.new(1, -16, 1, 0)
        label.Text =
            "-  "
            .. item.Type
            .. "  "
            .. item.Path
        label.TextColor3 = Color3.fromRGB(235, 137, 145)
        label.TextSize = 7
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.Parent = row
    end

    if count == 0 then
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -5, 0, 29)
        row.BackgroundColor3 = Color3.fromRGB(13, 16, 24)
        row.BorderSizePixel = 0
        row.Parent = diffList

        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Position = UDim2.fromOffset(8, 0)
        label.Size = UDim2.new(1, -16, 1, 0)
        label.Text = "No endpoint changes detected."
        label.TextColor3 = Color3.fromRGB(105, 117, 139)
        label.TextSize = 8
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = row
    end

    diffList.CanvasSize = UDim2.fromOffset(
        0,
        diffLayout.AbsoluteContentSize.Y + 10
    )
end

--==============================================================
-- RENDER API
--==============================================================

local function renderAPI()
    clearContainer(apiList)

    for _, capability in ipairs(getCapabilities()) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -5, 0, 29)
        row.BackgroundColor3 = Color3.fromRGB(13, 16, 24)
        row.BorderSizePixel = 0
        row.Parent = apiList

        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.fromOffset(48, 18)
        statusLabel.Position = UDim2.fromOffset(7, 5)
        statusLabel.BackgroundColor3 =
            capability.Available
            and Color3.fromRGB(18, 52, 35)
            or Color3.fromRGB(40, 29, 31)

        statusLabel.Text =
            capability.Available
            and "READY"
            or "N/A"

        statusLabel.TextColor3 =
            capability.Available
            and Color3.fromRGB(126, 221, 165)
            or Color3.fromRGB(218, 130, 139)

        statusLabel.TextSize = 6
        statusLabel.Font = Enum.Font.GothamBold
        statusLabel.Parent = row

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 5)
        corner.Parent = statusLabel

        local name = Instance.new("TextLabel")
        name.BackgroundTransparency = 1
        name.Position = UDim2.fromOffset(65, 0)
        name.Size = UDim2.new(1, -72, 1, 0)
        name.Text = capability.Name
        name.TextColor3 = Color3.fromRGB(220, 226, 240)
        name.TextSize = 8
        name.Font = Enum.Font.GothamMedium
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.Parent = row
    end

    apiList.CanvasSize = UDim2.fromOffset(
        0,
        apiLayout.AbsoluteContentSize.Y + 10
    )
end

--==============================================================
-- OVERVIEW UPDATE
--==============================================================

local function updateOverview()
    local re = 0
    local rf = 0
    local rp = 0

    for _, item in ipairs(State.Results) do
        if item.Type == "RE" then
            re += 1
        elseif item.Type == "RF" then
            rf += 1
        elseif item.Type == "RP" then
            rp += 1
        end
    end

    statValues.TOTAL.Text = tostring(#State.Results)
    statValues.RF.Text = tostring(rf)
    statValues.RE.Text = tostring(re)
    statValues.RP.Text = tostring(rp)
    statValues.OBJECTS.Text = tostring(#State.Objects)
    statValues.ADDED.Text = tostring(#State.Added)
    statValues.REMOVED.Text = tostring(#State.Removed)

    local serviceCount = 0

    for _ in pairs(State.Services) do
        serviceCount += 1
    end

    statValues.SERVICES.Text = tostring(serviceCount)

    local frameworks = {}

    for framework in pairs(State.Frameworks) do
        table.insert(frameworks, framework)
    end

    table.sort(frameworks)

    if #frameworks == 0 then
        frameworkLabel.Text = "Frameworks: none detected"
    else
        frameworkLabel.Text =
            "Frameworks: "
            .. table.concat(frameworks, " • ")
    end
end

--==============================================================
-- TAB SWITCH
--==============================================================

local function showTab(name)
    overview.Visible = name == "Overview"
    remoteView.Visible = name == "Remotes"
    objectView.Visible = name == "Objects"
    diffView.Visible = name == "Diff"
    apiView.Visible = name == "API"
end

for tabName, button in pairs(tabButtons) do
    button.Activated:Connect(function()
        State.CurrentTab = tabName

        for name, other in pairs(tabButtons) do
            if name == tabName then
                other.BackgroundColor3 = Color3.fromRGB(28, 42, 72)
                other.TextColor3 = Color3.fromRGB(172, 202, 255)
            else
                other.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
                other.TextColor3 = Color3.fromRGB(130, 141, 164)
            end
        end

        showTab(tabName)
    end)
end

--==============================================================
-- SEARCH / FILTER
--==============================================================

search:GetPropertyChangedSignal("Text"):Connect(function()
    State.Search = search.Text
    renderRemotes()
end)

for name, button in pairs(filterButtons) do
    button.Activated:Connect(function()
        State.CurrentFilter = name

        for filterName, filterButton in pairs(filterButtons) do
            if filterName == name then
                filterButton.BackgroundColor3 = Color3.fromRGB(28, 42, 72)
                filterButton.TextColor3 = Color3.fromRGB(170, 200, 255)
            else
                filterButton.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
                filterButton.TextColor3 = Color3.fromRGB(133, 144, 168)
            end
        end

        renderRemotes()
    end)
end

--==============================================================
-- COPY ALL
--==============================================================

copyButton.Activated:Connect(function()
    local report = buildReport()

    local clipboard = getGlobalFunction("setclipboard")

    if clipboard then
        local ok = pcall(function()
            clipboard(report)
        end)

        if ok then
            showToast("Full report copied")
            return
        end
    end

    print(report)
    showToast("Clipboard unavailable • report printed")
end)

--==============================================================
-- SAVE REPORT
--==============================================================

local function saveReport()
    local writefileFn = getGlobalFunction("writefile")

    if not writefileFn then
        return false
    end

    local report = buildReport()

    local fileName =
        "NexusAnalyzer_"
        .. tostring(game.PlaceId)
        .. "_"
        .. tostring(os.time())
        .. ".txt"

    return pcall(function()
        writefileFn(fileName, report)
    end)
end

--==============================================================
-- RESCAN
--==============================================================

local function doScan()
    if State.Scanning then
        return
    end

    performScan()
    startLiveWatcher()

    updateOverview()
    renderRemotes()
    renderObjects()
    renderDiff()
    renderAPI()

    if State.CurrentTab == "Overview" then
        showTab("Overview")
    elseif State.CurrentTab == "Remotes" then
        showTab("Remotes")
    elseif State.CurrentTab == "Objects" then
        showTab("Objects")
    elseif State.CurrentTab == "Diff" then
        showTab("Diff")
    elseif State.CurrentTab == "API" then
        showTab("API")
    end
end

scanButton.Activated:Connect(function()
    if State.Scanning then
        return
    end

    showToast("Scanning...")

    task.spawn(function()
        doScan()

        local saved = saveReport()

        if saved then
            showToast("Scan complete • report saved")
        else
            showToast("Scan complete")
        end
    end)
end)

--==============================================================
-- STATUS BAR
--==============================================================

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Position = UDim2.fromOffset(10, 297)
status.Size = UDim2.new(1, -20, 0, 17)
status.Text = "Initializing Nexus Analyzer..."
status.TextColor3 = Color3.fromRGB(91, 105, 129)
status.TextSize = 8
status.Font = Enum.Font.GothamMedium
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

--==============================================================
-- INITIALIZATION
--==============================================================

task.spawn(function()
    doScan()

    status.Text =
        "Ready • "
        .. tostring(#State.Results)
        .. " endpoints • "
        .. tostring(#State.Objects)
        .. " objects"

    print("============================================================")
    print("[NEXUS] ANALYZER v3.0 READY")
    print("============================================================")
    print("[NEXUS] Game:", State.GameName)
    print("[NEXUS] PlaceId:", game.PlaceId)
    print("[NEXUS] Endpoints:", #State.Results)
    print("[NEXUS] Objects:", #State.Objects)
    print("[NEXUS] Knit Services:", (function()
        local count = 0
        for _ in pairs(State.Services) do
            count += 1
        end
        return count
    end)())
    print("[NEXUS] Added:", #State.Added)
    print("[NEXUS] Removed:", #State.Removed)
    print("============================================================")
end)

--==============================================================
-- GLOBAL API
--==============================================================

pcall(function()
    local getgenvFn = getGlobalFunction("getgenv")

    if getgenvFn then
        local env = getgenvFn()

        env.NexusAnalyzer = {
            State = State,

            Scan = function()
                doScan()
            end,

            GetResults = function()
                return State.Results
            end,

            GetObjects = function()
                return State.Objects
            end,

            GetServices = function()
                return State.Services
            end,

            GetFrameworks = function()
                return State.Frameworks
            end,

            GetDiff = function()
                return {
                    Added = State.Added,
                    Removed = State.Removed,
                }
            end,

            GetReport = function()
                return buildReport()
            end,

            GetData = function()
                return buildData()
            end,

            SaveReport = function()
                return saveReport()
            end,

            GUI = gui,
        }
    end
end)
