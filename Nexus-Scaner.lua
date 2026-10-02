--// ============================================================
--// NEXUS ANALYZER v2
--// Universal replicated-object / remote analyzer
--// UI: 450x330
--//
--// Features:
--// • RemoteEvent / RemoteFunction / UnreliableRemoteEvent
--// • Knit RE / RF / RP detection
--// • Service grouping
--// • Search
--// • ALL / RF / RE / RP filters
--// • Copy All report
--// • Rescan
--// • Place / Job / Player information
--// • Remote attributes
--// • Related endpoints per Knit service
--// • Workspace / ReplicatedStorage / PlayerGui /
--//   Backpack / Character scanning
--// • Mobile drag
--// • No Remote firing / invoking
--// ============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

local LocalPlayer = Players.LocalPlayer

--==============================================================
-- CONFIG
--==============================================================

local CONFIG = {
    Width = 450,
    Height = 330,

    ScanWorkspace = true,
    ScanReplicatedStorage = true,
    ScanPlayerGui = true,
    ScanBackpack = true,
    ScanCharacter = true,

    MaxRows = 250,
}

--==============================================================
-- STATE
--==============================================================

local State = {
    Results = {},
    Services = {},
    Seen = {},
    CurrentFilter = "ALL",
    Search = "",
    Scanning = false,
}

--==============================================================
-- HELPERS
--==============================================================

local function safeCall(fn, ...)
    local ok, result = pcall(fn, ...)
    if ok then
        return result
    end

    return nil
end

local function getPath(instance)
    return safeCall(function()
        return instance:GetFullName()
    end) or instance.Name
end

local function getRootName(instance)
    local path = getPath(instance)
    return string.match(path, "^[^%.]+") or "Unknown"
end

local function getServiceInfo(path)
    local serviceName = string.match(
        path,
        "%.Services%.([^%.]+)%.(RE|RF|RP)%."
    )

    local endpointType = string.match(
        path,
        "%.Services%.[^%.]+%.(RE|RF|RP)%."
    )

    return serviceName, endpointType
end

local function getEndpointType(instance)
    if instance:IsA("RemoteFunction") then
        return "RF"
    end

    if instance:IsA("RemoteEvent") then
        local serviceName, knitType = getServiceInfo(getPath(instance))

        if knitType == "RP" then
            return "RP"
        end

        return "RE"
    end

    if instance:IsA("UnreliableRemoteEvent") then
        return "RE"
    end

    return "OTHER"
end

local function getClass(instance)
    return instance.ClassName
end

local function getAttributes(instance)
    local result = {}

    local attrs = safeCall(function()
        return instance:GetAttributes()
    end)

    if not attrs then
        return result
    end

    for key, value in pairs(attrs) do
        table.insert(result, {
            Name = tostring(key),
            Value = tostring(value),
        })
    end

    table.sort(result, function(a, b)
        return a.Name < b.Name
    end)

    return result
end

local function addService(
    serviceName,
    endpointType,
    remote
)
    if not serviceName then
        return
    end

    State.Services[serviceName] = State.Services[serviceName] or {
        Name = serviceName,
        RE = {},
        RF = {},
        RP = {},
        Total = 0,
    }

    local service = State.Services[serviceName]

    service.Total += 1

    if service[endpointType] then
        table.insert(service[endpointType], remote)
    end
end

local function addResult(instance)
    if State.Seen[instance] then
        return
    end

    State.Seen[instance] = true

    if not (
        instance:IsA("RemoteEvent")
        or instance:IsA("RemoteFunction")
        or instance:IsA("UnreliableRemoteEvent")
    ) then
        return
    end

    local path = getPath(instance)
    local typeName = getEndpointType(instance)
    local serviceName, knitType = getServiceInfo(path)

    -- RemoteProperty detection by path.
    if knitType == "RP" then
        typeName = "RP"
    end

    local item = {
        Name = instance.Name,
        Class = getClass(instance),
        Type = typeName,
        Path = path,
        Parent = instance.Parent and getPath(instance.Parent) or "nil",
        Root = getRootName(instance),
        Service = serviceName or "Unknown",
        Attributes = getAttributes(instance),
    }

    table.insert(State.Results, item)

    addService(
        serviceName,
        typeName,
        item
    )
end

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
        addResult(instance)
    end
end

--==============================================================
-- GAME INFO
--==============================================================

local function getGameName()
    local info = safeCall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)

    if info and info.Name then
        return tostring(info.Name)
    end

    return "Unknown"
end

--==============================================================
-- SCANNER
--==============================================================

local function performScan()
    if State.Scanning then
        return
    end

    State.Scanning = true

    State.Results = {}
    State.Services = {}
    State.Seen = {}

    local roots = {}

    if CONFIG.ScanReplicatedStorage then
        table.insert(roots, ReplicatedStorage)
    end

    if CONFIG.ScanWorkspace then
        table.insert(roots, workspace)
    end

    if CONFIG.ScanPlayerGui and LocalPlayer then
        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")

        if PlayerGui then
            table.insert(roots, PlayerGui)
        end
    end

    if CONFIG.ScanBackpack and LocalPlayer then
        local Backpack = LocalPlayer:FindFirstChild("Backpack")

        if Backpack then
            table.insert(roots, Backpack)
        end
    end

    if CONFIG.ScanCharacter and LocalPlayer and LocalPlayer.Character then
        table.insert(
            roots,
            LocalPlayer.Character
        )
    end

    for _, root in ipairs(roots) do
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

    State.Scanning = false
end

--==============================================================
-- REPORT
--==============================================================

local function buildReport()
    local countRE = 0
    local countRF = 0
    local countRP = 0

    for _, item in ipairs(State.Results) do
        if item.Type == "RE" then
            countRE += 1
        elseif item.Type == "RF" then
            countRF += 1
        elseif item.Type == "RP" then
            countRP += 1
        end
    end

    local lines = {}

    table.insert(lines, "============================================================")
    table.insert(lines, "NEXUS ANALYZER")
    table.insert(lines, "============================================================")
    table.insert(lines, "")
    table.insert(lines, "GAME")
    table.insert(lines, "Name     : " .. getGameName())
    table.insert(lines, "PlaceId  : " .. tostring(game.PlaceId))
    table.insert(lines, "GameId   : " .. tostring(game.GameId))
    table.insert(lines, "JobId    : " .. tostring(game.JobId))
    table.insert(lines, "Player   : " .. tostring(LocalPlayer and LocalPlayer.Name or "Unknown"))
    table.insert(lines, "")
    table.insert(lines, "SUMMARY")
    table.insert(lines, "Total    : " .. tostring(#State.Results))
    table.insert(lines, "RemoteEvent      : " .. tostring(countRE))
    table.insert(lines, "RemoteFunction   : " .. tostring(countRF))
    table.insert(lines, "RemoteProperty   : " .. tostring(countRP))
    table.insert(lines, "")
    table.insert(lines, "============================================================")
    table.insert(lines, "KNIT SERVICE MAP")
    table.insert(lines, "============================================================")

    local serviceNames = {}

    for serviceName in pairs(State.Services) do
        table.insert(serviceNames, serviceName)
    end

    table.sort(serviceNames)

    if #serviceNames == 0 then
        table.insert(lines, "No Knit Services detected.")
    else
        for _, serviceName in ipairs(serviceNames) do
            local service = State.Services[serviceName]

            table.insert(lines, "")
            table.insert(
                lines,
                "[" .. serviceName .. "] Total: " .. tostring(service.Total)
            )

            if #service.RF > 0 then
                table.insert(lines, "  RF:")

                for _, remote in ipairs(service.RF) do
                    table.insert(
                        lines,
                        "    " .. remote.Name .. " -> " .. remote.Path
                    )
                end
            end

            if #service.RE > 0 then
                table.insert(lines, "  RE:")

                for _, remote in ipairs(service.RE) do
                    table.insert(
                        lines,
                        "    " .. remote.Name .. " -> " .. remote.Path
                    )
                end
            end

            if #service.RP > 0 then
                table.insert(lines, "  RP:")

                for _, remote in ipairs(service.RP) do
                    table.insert(
                        lines,
                        "    " .. remote.Name .. " -> " .. remote.Path
                    )
                end
            end
        end
    end

    table.insert(lines, "")
    table.insert(lines, "============================================================")
    table.insert(lines, "ALL REPLICATED REMOTE ENDPOINTS")
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
                    "  " .. attribute.Name .. " = " .. attribute.Value
                )
            end
        else
            table.insert(lines, "Attributes: none")
        end
    end

    table.insert(lines, "")
    table.insert(lines, "============================================================")
    table.insert(lines, "IMPORTANT")
    table.insert(lines, "============================================================")
    table.insert(
        lines,
        "This report describes objects replicated to the client."
    )
    table.insert(
        lines,
        "It does not reveal server-only objects or undocumented server code."
    )
    table.insert(
        lines,
        "Remote arguments/return types cannot be determined reliably from the instance tree alone."
    )
    table.insert(lines, "No RemoteEvent/RemoteFunction was fired or invoked.")
    table.insert(lines, "============================================================")

    return table.concat(lines, "\n")
end

--==============================================================
-- UI
--==============================================================

local gui = Instance.new("ScreenGui")
gui.Name = "NexusAnalyzer"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

pcall(function()
    gui.Parent = game:GetService("CoreGui")
end)

if not gui.Parent then
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(CONFIG.Width, CONFIG.Height)
main.Position = UDim2.new(0.5, -CONFIG.Width / 2, 0.5, -CONFIG.Height / 2)
main.BackgroundColor3 = Color3.fromRGB(9, 11, 17)
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(70, 80, 105)
mainStroke.Transparency = 0.25
mainStroke.Thickness = 1
mainStroke.Parent = main

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(13, 16, 26)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 9, 14)),
})
gradient.Rotation = 90
gradient.Parent = main

--==============================================================
-- TOPBAR
--==============================================================

local topbar = Instance.new("Frame")
topbar.Size = UDim2.new(1, 0, 0, 45)
topbar.BackgroundColor3 = Color3.fromRGB(13, 16, 24)
topbar.BorderSizePixel = 0
topbar.Parent = main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 14)
topCorner.Parent = topbar

local title = Instance.new("TextLabel")
title.Size = UDim2.fromOffset(220, 22)
title.Position = UDim2.fromOffset(16, 6)
title.BackgroundTransparency = 1
title.Text = "NEXUS ANALYZER"
title.TextColor3 = Color3.fromRGB(238, 242, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topbar

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.fromOffset(300, 16)
subtitle.Position = UDim2.fromOffset(17, 25)
subtitle.BackgroundTransparency = 1
subtitle.Text = "REMOTE / KNIT NETWORK MAP"
subtitle.TextColor3 = Color3.fromRGB(105, 115, 140)
subtitle.TextSize = 9
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = topbar

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(30, 30)
close.Position = UDim2.new(1, -37, 0, 7)
close.BackgroundColor3 = Color3.fromRGB(28, 31, 42)
close.Text = "×"
close.TextColor3 = Color3.fromRGB(225, 228, 240)
close.TextSize = 20
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
-- DRAGGING
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
-- STATS
--==============================================================

local stats = Instance.new("Frame")
stats.Size = UDim2.new(1, -20, 0, 40)
stats.Position = UDim2.fromOffset(10, 51)
stats.BackgroundTransparency = 1
stats.Parent = main

local function createStat(label, x)
    local box = Instance.new("Frame")
    box.Size = UDim2.fromOffset(96, 36)
    box.Position = UDim2.fromOffset(x, 0)
    box.BackgroundColor3 = Color3.fromRGB(17, 20, 30)
    box.BorderSizePixel = 0
    box.Parent = stats

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = box

    local value = Instance.new("TextLabel")
    value.Name = "Value"
    value.Size = UDim2.new(1, -12, 0, 19)
    value.Position = UDim2.fromOffset(6, 2)
    value.BackgroundTransparency = 1
    value.Text = "0"
    value.TextColor3 = Color3.fromRGB(235, 240, 255)
    value.TextSize = 15
    value.Font = Enum.Font.GothamBold
    value.Parent = box

    local caption = Instance.new("TextLabel")
    caption.Size = UDim2.new(1, -12, 0, 12)
    caption.Position = UDim2.fromOffset(6, 21)
    caption.BackgroundTransparency = 1
    caption.Text = label
    caption.TextColor3 = Color3.fromRGB(105, 115, 140)
    caption.TextSize = 8
    caption.Font = Enum.Font.GothamMedium
    caption.Parent = box

    return value
end

local totalValue = createStat("TOTAL", 0)
local rfValue = createStat("FUNCTIONS", 102)
local reValue = createStat("EVENTS", 204)
local rpValue = createStat("PROPERTIES", 306)

--==============================================================
-- CONTROLS
--==============================================================

local search = Instance.new("TextBox")
search.Size = UDim2.fromOffset(205, 31)
search.Position = UDim2.fromOffset(10, 96)
search.BackgroundColor3 = Color3.fromRGB(17, 20, 30)
search.BorderSizePixel = 0
search.PlaceholderText = "Search remote / service..."
search.PlaceholderColor3 = Color3.fromRGB(88, 97, 119)
search.Text = ""
search.TextColor3 = Color3.fromRGB(235, 238, 247)
search.TextSize = 11
search.Font = Enum.Font.GothamMedium
search.ClearTextOnFocus = false
search.Parent = main

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 9)
searchCorner.Parent = search

local copyAll = Instance.new("TextButton")
copyAll.Size = UDim2.fromOffset(105, 31)
copyAll.Position = UDim2.fromOffset(220, 96)
copyAll.BackgroundColor3 = Color3.fromRGB(23, 31, 55)
copyAll.BorderSizePixel = 0
copyAll.Text = "COPY ALL"
copyAll.TextColor3 = Color3.fromRGB(160, 190, 255)
copyAll.TextSize = 10
copyAll.Font = Enum.Font.GothamBold
copyAll.AutoButtonColor = false
copyAll.Parent = main

local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 9)
copyCorner.Parent = copyAll

local rescan = Instance.new("TextButton")
rescan.Size = UDim2.fromOffset(105, 31)
rescan.Position = UDim2.fromOffset(333, 96)
rescan.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
rescan.BorderSizePixel = 0
rescan.Text = "RESCAN"
rescan.TextColor3 = Color3.fromRGB(210, 216, 230)
rescan.TextSize = 10
rescan.Font = Enum.Font.GothamBold
rescan.AutoButtonColor = false
rescan.Parent = main

local rescanCorner = Instance.new("UICorner")
rescanCorner.CornerRadius = UDim.new(0, 9)
rescanCorner.Parent = rescan

--==============================================================
-- FILTERS
--==============================================================

local filters = Instance.new("Frame")
filters.Size = UDim2.new(1, -20, 0, 27)
filters.Position = UDim2.fromOffset(10, 134)
filters.BackgroundTransparency = 1
filters.Parent = main

local filterButtons = {}

local filterData = {
    {"ALL", 0},
    {"RF", 77},
    {"RE", 154},
    {"RP", 231},
}

for _, data in ipairs(filterData) do
    local name = data[1]
    local x = data[2]

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(70, 25)
    button.Position = UDim2.fromOffset(x, 0)
    button.BackgroundColor3 = Color3.fromRGB(17, 20, 29)
    button.BorderSizePixel = 0
    button.Text = name
    button.TextColor3 = Color3.fromRGB(142, 151, 174)
    button.TextSize = 9
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Parent = filters

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 7)
    corner.Parent = button

    filterButtons[name] = button

    button.Activated:Connect(function()
        State.CurrentFilter = name

        for filterName, filterButton in pairs(filterButtons) do
            if filterName == name then
                filterButton.BackgroundColor3 = Color3.fromRGB(28, 42, 72)
                filterButton.TextColor3 = Color3.fromRGB(170, 200, 255)
            else
                filterButton.BackgroundColor3 = Color3.fromRGB(17, 20, 29)
                filterButton.TextColor3 = Color3.fromRGB(142, 151, 174)
            end
        end
    end)
end

--==============================================================
-- LIST
--==============================================================

local list = Instance.new("ScrollingFrame")
list.Name = "RemoteList"
list.Size = UDim2.new(1, -20, 0, 133)
list.Position = UDim2.fromOffset(10, 168)
list.BackgroundColor3 = Color3.fromRGB(7, 9, 14)
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.ScrollBarImageColor3 = Color3.fromRGB(63, 73, 100)
list.CanvasSize = UDim2.fromOffset(0, 0)
list.Parent = main

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 10)
listCorner.Parent = list

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 5)
listPadding.PaddingBottom = UDim.new(0, 5)
listPadding.PaddingLeft = UDim.new(0, 5)
listPadding.PaddingRight = UDim.new(0, 5)
listPadding.Parent = list

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 4)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = list

--==============================================================
-- STATUS
--==============================================================

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 20)
status.Position = UDim2.fromOffset(10, 307)
status.BackgroundTransparency = 1
status.Text = "Ready"
status.TextColor3 = Color3.fromRGB(93, 105, 130)
status.TextSize = 9
status.Font = Enum.Font.GothamMedium
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

--==============================================================
-- TOAST
--==============================================================

local toast = Instance.new("TextLabel")
toast.Size = UDim2.fromOffset(190, 28)
toast.Position = UDim2.new(0.5, -95, 1, 8)
toast.BackgroundColor3 = Color3.fromRGB(19, 24, 37)
toast.BorderSizePixel = 0
toast.Text = ""
toast.TextColor3 = Color3.fromRGB(215, 225, 255)
toast.TextSize = 9
toast.Font = Enum.Font.GothamBold
toast.Visible = false
toast.Parent = main

local toastCorner = Instance.new("UICorner")
toastCorner.CornerRadius = UDim.new(0, 8)
toastCorner.Parent = toast

local function showToast(message)
    toast.Text = message
    toast.Visible = true
    toast.Position = UDim2.new(0.5, -95, 1, 8)

    TweenService:Create(
        toast,
        TweenInfo.new(0.18),
        {
            Position = UDim2.new(0.5, -95, 1, -36)
        }
    ):Play()

    task.delay(1.5, function()
        if toast.Visible then
            local tween = TweenService:Create(
                toast,
                TweenInfo.new(0.18),
                {
                    Position = UDim2.new(0.5, -95, 1, 8)
                }
            )

            tween:Play()

            tween.Completed:Wait()

            toast.Visible = false
        end
    end)
end

--==============================================================
-- RENDER LIST
--==============================================================

local function clearList()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

local function matches(item)
    local filter = State.CurrentFilter

    if filter ~= "ALL" and item.Type ~= filter then
        return false
    end

    local searchText = string.lower(State.Search)

    if searchText == "" then
        return true
    end

    return string.find(
        string.lower(item.Name),
        searchText,
        1,
        true
    ) ~= nil
    or string.find(
        string.lower(item.Path),
        searchText,
        1,
        true
    ) ~= nil
    or string.find(
        string.lower(item.Service),
        searchText,
        1,
        true
    ) ~= nil
end

local function renderList()
    clearList()

    local shown = 0

    for _, item in ipairs(State.Results) do
        if matches(item) then
            shown += 1

            if shown > CONFIG.MaxRows then
                break
            end

            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -5, 0, 41)
            row.BackgroundColor3 = Color3.fromRGB(13, 16, 24)
            row.BorderSizePixel = 0
            row.Parent = list

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = row

            local typeLabel = Instance.new("TextLabel")
            typeLabel.Size = UDim2.fromOffset(37, 20)
            typeLabel.Position = UDim2.fromOffset(7, 10)
            typeLabel.BackgroundColor3 =
                item.Type == "RF"
                and Color3.fromRGB(47, 35, 67)
                or item.Type == "RP"
                and Color3.fromRGB(32, 55, 62)
                or Color3.fromRGB(24, 49, 70)

            typeLabel.Text = item.Type
            typeLabel.TextColor3 =
                item.Type == "RF"
                and Color3.fromRGB(210, 170, 255)
                or item.Type == "RP"
                and Color3.fromRGB(150, 225, 225)
                or Color3.fromRGB(150, 200, 255)

            typeLabel.TextSize = 8
            typeLabel.Font = Enum.Font.GothamBold
            typeLabel.Parent = row

            local typeCorner = Instance.new("UICorner")
            typeCorner.CornerRadius = UDim.new(0, 5)
            typeCorner.Parent = typeLabel

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, -55, 0, 18)
            nameLabel.Position = UDim2.fromOffset(52, 3)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = item.Name
            nameLabel.TextColor3 = Color3.fromRGB(225, 230, 242)
            nameLabel.TextSize = 10
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            nameLabel.Parent = row

            local pathLabel = Instance.new("TextLabel")
            pathLabel.Size = UDim2.new(1, -55, 0, 14)
            pathLabel.Position = UDim2.fromOffset(52, 21)
            pathLabel.BackgroundTransparency = 1
            pathLabel.Text =
                item.Service ~= "Unknown"
                and item.Service .. "  •  " .. item.Path
                or item.Path

            pathLabel.TextColor3 = Color3.fromRGB(91, 103, 128)
            pathLabel.TextSize = 7
            pathLabel.Font = Enum.Font.GothamMedium
            pathLabel.TextXAlignment = Enum.TextXAlignment.Left
            pathLabel.TextTruncate = Enum.TextTruncate.AtEnd
            pathLabel.Parent = row

            row.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then

                    if type(setclipboard) == "function" then
                        setclipboard(item.Path)
                        showToast("Remote path copied")
                    end
                end
            end)
        end
    end

    list.CanvasSize = UDim2.fromOffset(
        0,
        layout.AbsoluteContentSize.Y + 10
    )

    status.Text =
        "Showing "
        .. tostring(shown)
        .. " / "
        .. tostring(#State.Results)
        .. " endpoints"
end

--==============================================================
-- STATS UPDATE
--==============================================================

local function updateStats()
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

    totalValue.Text = tostring(#State.Results)
    rfValue.Text = tostring(rf)
    reValue.Text = tostring(re)
    rpValue.Text = tostring(rp)
end

--==============================================================
-- BUTTONS
--==============================================================

copyAll.Activated:Connect(function()
    local report = buildReport()

    if type(setclipboard) == "function" then
        setclipboard(report)
        showToast("Full analyzer report copied")
        status.Text = "Full report copied to clipboard"
    else
        status.Text = "setclipboard is unavailable in this environment"
    end
end)

rescan.Activated:Connect(function()
    status.Text = "Scanning..."

    task.spawn(function()
        performScan()
        updateStats()
        renderList()

        status.Text =
            "Scan complete • "
            .. tostring(#State.Results)
            .. " endpoints found"

        showToast("Scan complete")
    end)
end)

search:GetPropertyChangedSignal("Text"):Connect(function()
    State.Search = search.Text
    renderList()
end)

for _, button in pairs(filterButtons) do
    button.BackgroundColor3 = Color3.fromRGB(17, 20, 29)
    button.TextColor3 = Color3.fromRGB(142, 151, 174)
end

filterButtons.ALL.BackgroundColor3 = Color3.fromRGB(28, 42, 72)
filterButtons.ALL.TextColor3 = Color3.fromRGB(170, 200, 255)

--==============================================================
-- INITIAL SCAN
--==============================================================

status.Text = "Scanning replicated objects..."

task.spawn(function()
    performScan()
    updateStats()
    renderList()

    status.Text =
        "Ready • "
        .. tostring(#State.Results)
        .. " endpoints found"
end)

--==============================================================
-- GLOBAL API
--==============================================================

pcall(function()
    getgenv().NexusAnalyzer = {
        State = State,

        Scan = function()
            performScan()
            updateStats()
            renderList()
        end,

        GetResults = function()
            return State.Results
        end,

        GetServices = function()
            return State.Services
        end,

        GetReport = function()
            return buildReport()
        end,

        GUI = gui,
    }
end)
