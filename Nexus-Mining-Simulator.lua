--[[
============================================================
 NEXUS MINING HUB • MOBILE
 Build: 1.9
------------------------------------------------------------
 Auto Farm route fix:
 • Portal/world transition uses MoveTo only.
 • No repeated local CFrame teleports under the map.
 • Farm-zone teleport is attempted only once per selected area.
 • No physical bridge/ForceField plate is created.
 • Extra world spawns such as Lava are detected automatically.
 • Auto Rebirth is independent from backpack threshold.
 • After sell/rebirth the selected world/farm route is restored once.
 • Disabling Auto Farm returns to the valid world center once.
------------------------------------------------------------
 Designed for a Roblox experience you control.
============================================================
]]

--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StatsService = game:GetService("Stats")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// CONFIG
local CONFIG = {
    Name = "NEXUS MINING HUB",
    Version = "1.9",

    Colors = {
        Background = Color3.fromRGB(3, 8, 18),
        Panel = Color3.fromRGB(5, 12, 25),
        Panel2 = Color3.fromRGB(7, 17, 33),
        Panel3 = Color3.fromRGB(9, 22, 42),
        Border = Color3.fromRGB(27, 84, 135),
        Accent = Color3.fromRGB(34, 151, 255),
        Accent2 = Color3.fromRGB(70, 211, 255),
        White = Color3.fromRGB(242, 248, 255),
        Muted = Color3.fromRGB(132, 154, 179),
        Good = Color3.fromRGB(66, 224, 145),
        Warn = Color3.fromRGB(255, 194, 82),
        Bad = Color3.fromRGB(255, 92, 110),
    },

    Mining = {
        NormalInterval = 0.14,
        FastInterval = 0.075,
        SellInterval = 0.25,
        RebirthInterval = 0.5,
        ShopInterval = 6.0,
        RebirthCostCoins = 10000000,
    },

    Movement = {
        SprintSpeed = 24,
    },
}

--// STATE
local State = {
    MenuOpen = true,
    ActiveTab = "Mining",

    AutoMine = false,
    AutoFarm = false,
    FastMine = false,
    AutoSell = false,
    AutoRebirth = false,
    RebirthOnly = false,
    AutoBackpack = false,
    AutoTools = false,
    Sprint = false,

    SelectedArea = "MagicForest",
    SellThreshold = 30000,

    LastTarget = nil,
    LastMine = 0,
    LastSell = 0,
    LastRebirth = 0,
    LastShop = 0,
    LastFarmCheck = 0,

    FarmBusy = false,
    CycleBusy = false,
    FarmZonePosition = nil,
    FarmRouteBusy = false,
    FarmRouteTried = false,
    FarmRouteComplete = false,
    FarmRouteArea = nil,
    FarmCenterArea = nil,

    InventoryLabel = nil,
    InventoryLabelScanAt = 0,

    ShopEntries = {},
    RebirthBaseBlocks = nil,

    FPS = 0,
    Ping = "--",
    Status = "INITIALIZING",

    Remote = nil,
    RemoteDiscoveryDone = false,
}

--// GUI FORWARD DECLARATIONS
local StatusLabel
local Toast
local MiningToggle
local FastMiningToggle
local SellToggle
local BackpackToggle
local ToolsToggle
local SprintToggle
local RebirthToggle
local RebirthOnlyToggle
local AreaNameLabel
local StatsText
local AttributesText
local InventoryText
local RebirthStatsLabel

--// HELPERS
local function safeFind(parent, name)
    if not parent then
        return nil
    end
    return parent:FindFirstChild(name)
end

local function round(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = object
    return c
end

local function stroke(object, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or CONFIG.Colors.Border
    s.Transparency = transparency or 0
    s.Thickness = thickness or 1
    s.Parent = object
    return s
end

local function gradient(object, a, b, rotation)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, a),
        ColorSequenceKeypoint.new(0.5, b),
        ColorSequenceKeypoint.new(1, a),
    })
    g.Rotation = rotation or 0
    g.Parent = object
    return g
end

local function makeLabel(parent, text, size, position, textSize, color, font)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = size
    label.Position = position
    label.Text = text or ""
    label.TextColor3 = color or CONFIG.Colors.White
    label.Font = font or Enum.Font.Gotham
    label.TextSize = textSize or 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

local function makeButton(parent, text, size, position)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.Size = size
    b.Position = position
    b.BackgroundColor3 = CONFIG.Colors.Panel2
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = CONFIG.Colors.White
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.Parent = parent
    round(b, 10)
    stroke(b, CONFIG.Colors.Border, 0.35, 1)
    return b
end

local function setButtonState(button, enabled, normalText)
    button.Text = enabled and "ON" or (normalText or "OFF")
    button.BackgroundColor3 = enabled and Color3.fromRGB(20, 92, 76) or CONFIG.Colors.Panel2
    button.TextColor3 = enabled and CONFIG.Colors.White or CONFIG.Colors.Muted
end

local function formatNumber(value)
    value = tonumber(value)
    if not value then
        return "N/A"
    end

    local abs = math.abs(value)
    if abs >= 1e12 then
        return string.format("%.2fT", value / 1e12)
    elseif abs >= 1e9 then
        return string.format("%.2fB", value / 1e9)
    elseif abs >= 1e6 then
        return string.format("%.2fM", value / 1e6)
    elseif abs >= 1e3 then
        return string.format("%.2fK", value / 1e3)
    end

    if math.floor(value) == value then
        return tostring(math.floor(value))
    end

    return string.format("%.2f", value)
end

local function getRoot(player)
    local character = player and player.Character
    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
        or character.PrimaryPart
        or character:FindFirstChild("UpperTorso")
        or character:FindFirstChild("Torso")
end

local function getHumanoid(player)
    local character = player and player.Character
    if not character then
        return nil
    end
    return character:FindFirstChildOfClass("Humanoid")
end

local function getEquippedTool()
    local character = LocalPlayer.Character
    if not character then
        return nil
    end
    return character:FindFirstChildOfClass("Tool")
end

local function findNumberValue(container, names)
    if not container then
        return nil
    end

    for _, name in ipairs(names) do
        local object = container:FindFirstChild(name, true)
        if object and (object:IsA("IntValue") or object:IsA("NumberValue")) then
            return object
        end
    end

    return nil
end

local function getBlocksValueObject()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    return findNumberValue(leaderstats, {"Blocks Mined", "BlocksMined", "Blocks"})
        or findNumberValue(LocalPlayer, {"Blocks Mined", "BlocksMined", "Blocks"})
end

local function getBlocksMined()
    local obj = getBlocksValueObject()
    return obj and tonumber(obj.Value) or 0
end

local function getCoinsValueObject()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    return findNumberValue(leaderstats, {"Coins", "Cash", "Money"})
        or findNumberValue(LocalPlayer, {"Coins", "Cash", "Money"})
end

local function getCoins()
    local obj = getCoinsValueObject()
    if not obj then
        local stats = LocalPlayer:FindFirstChild("Stats")
        obj = findNumberValue(stats, {"Coins", "Cash", "Money"})
    end
    return obj and tonumber(obj.Value) or 0
end

local function getRebirths()
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local obj = findNumberValue(leaderstats, {"Rebirths", "Rebirth"})
    return obj and tonumber(obj.Value) or 0
end

local function setStatus(text, good)
    State.Status = text

    if StatusLabel then
        StatusLabel.Text = text
        StatusLabel.TextColor3 = good == false and CONFIG.Colors.Bad or CONFIG.Colors.Good
    end
end

local function notify(text)
    if not Toast then
        return
    end

    Toast.Text = text
    Toast.Visible = true
    Toast.BackgroundTransparency = 0.12

    task.delay(2, function()
        if Toast and Toast.Parent then
            local tween = TweenService:Create(
                Toast,
                TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundTransparency = 1}
            )
            tween:Play()
            tween.Completed:Wait()
            if Toast then
                Toast.Visible = false
            end
        end
    end)
end

--//========================================================
--// GAME-SPECIFIC CORE (PORTED FROM WORKING BUILD)
--//========================================================

local GEN = (type(getgenv) == "function" and getgenv()) or _G

GEN.SellTreshold = (type(GEN.SellTreshold) == "number" and GEN.SellTreshold > 0 and GEN.SellTreshold ~= 30000) and GEN.SellTreshold or nil
GEN.Depth = (type(GEN.Depth) == "number" and GEN.Depth >= 0) and GEN.Depth or 205

State.SellThreshold = GEN.SellTreshold or 30000
State.Depth = GEN.Depth

local SellArea = CFrame.new(42, 14, -1239)
local Remote = nil
local rebirthConnection = nil
local rebirthRunId = 0
local rebirthPhaseText = "off"
local rebirthDigging = false
local areaRunId = 0
local areaTransit = false
local lastAreaName = nil
local lastMineSpot = nil
local sellTrip = false
local sellLoopGen = 0
local buyPause = false
local buyPauseAt = 0
local shopCache = {tools = nil, packs = nil, at = 0}
local refusedBuy = {}
local toolBuyerRunning = false
local packBuyerRunning = false

local Areas = {
    { name = "Cyber",       moveTo = "CyberSpawn",  spawn = Vector3.new(21, 15, 30139),  walkEnd = Vector3.new(19, 13, 30051),  mine = Vector3.new(22, 12, 30037),  bridgeSize = Vector3.new(10, 1, 100), bridgePos = Vector3.new(21, 9.5, 30095) },
    { name = "Spawn",       moveTo = nil,           spawn = Vector3.new(-86, 14, -12),    walkEnd = Vector3.new(-36, 14, -3),    mine = Vector3.new(-17, 12, -3) },
    { name = "Space",       moveTo = "SpaceSpawn",  spawn = Vector3.new(-81, 15, 1569),   walkEnd = Vector3.new(-27, 12, 1568),  mine = Vector3.new(-15, 12, 1568) },
    { name = "Candy",       moveTo = "CandySpawn",  spawn = Vector3.new(-27, 15, 3011),   walkEnd = Vector3.new(2, 13, 3009),    mine = Vector3.new(11, 12, 3010) },
    { name = "Toy",         moveTo = "ToySpawn",    spawn = Vector3.new(10, 15, 5719),    walkEnd = Vector3.new(11, 13, 5699),   mine = Vector3.new(11, 12, 5687) },
    { name = "Food",        moveTo = "FoodSpawn",   spawn = Vector3.new(61, 14, 8675),    walkEnd = Vector3.new(59, 13, 8719),   mine = Vector3.new(56, 12, 8732) },
    { name = "Dino",        moveTo = "DinoSpawn",   spawn = Vector3.new(12, 15, 10581),   walkEnd = Vector3.new(12, 13, 10552),  mine = Vector3.new(14, 12, 10539) },
    { name = "Sea",         moveTo = "SeaSpawn",    spawn = Vector3.new(14, 12, 10539),   walkEnd = Vector3.new(17, 13, 11969),  mine = Vector3.new(18, 12, 11949) },
    { name = "Beach",       moveTo = "BeachSpawn",  spawn = Vector3.new(19, 14, 14437),   walkEnd = Vector3.new(15, 13, 14374),  mine = Vector3.new(15, 12, 14357) },
    { name = "Cavern",      moveTo = "CavernSpawn", spawn = Vector3.new(19, 15, 18461),   walkEnd = Vector3.new(20, 13, 18400),  mine = Vector3.new(21, 12, 18382) },
    { name = "MagicForest", moveTo = nil,           spawn = Vector3.new(15, 15, 22461),   walkEnd = Vector3.new(16, 13, 22420),  mine = Vector3.new(17, 12, 22409) },
    { name = "Lava",        moveTo = "LavaSpawn",  spawn = nil, walkEnd = nil, mine = nil, dynamic = true },
}

local function getTeleportSpawnCFrame(pointName)
    if type(pointName) ~= "string" or pointName == "" then return nil end

    local folder = workspace:FindFirstChild("TeleportPoints")
    if folder then
        local exact = folder:FindFirstChild(pointName, true)
        if exact then
            if exact:IsA("BasePart") then return exact.CFrame end
            if exact:IsA("Attachment") then return exact.WorldCFrame end
            if exact:IsA("CFrameValue") then return exact.Value end
        end
    end

    for _, object in ipairs(workspace:GetDescendants()) do
        if object.Name == pointName then
            if object:IsA("BasePart") then return object.CFrame end
            if object:IsA("Attachment") then return object.WorldCFrame end
            if object:IsA("CFrameValue") then return object.Value end
        end
    end
    return nil
end

local function refreshDynamicAreas()
    local known = {}
    for _, area in ipairs(Areas) do
        known[tostring(area.name):lower()] = true
    end

    local folder = workspace:FindFirstChild("TeleportPoints")
    if not folder then return end

    for _, object in ipairs(folder:GetDescendants()) do
        local objectName = tostring(object.Name)
        if objectName:sub(-5) == "Spawn" then
            local base = objectName:sub(1, -6)
            local lower = base:lower()
            if base ~= "Surface" and base ~= "Sell" and base ~= "Spawn" and base ~= "" and not known[lower] then
                table.insert(Areas, {
                    name = base,
                    moveTo = objectName,
                    spawn = nil,
                    walkEnd = nil,
                    mine = nil,
                    dynamic = true,
                })
                known[lower] = true
            end
        end
    end
end

refreshDynamicAreas()

local areaOrder = {}
for _, a in ipairs(Areas) do
    table.insert(areaOrder, {a.name, a.moveTo})
end

local function EnsureRemote()
    if Remote and Remote.Parent then
        State.Remote = Remote
        return Remote
    end

    Remote = nil
    State.Remote = nil
    State.RemoteDiscoveryDone = false

    pcall(function()
        local Network = ReplicatedStorage:WaitForChild("Network", 5)
        if Network then
            if Network:IsA("RemoteFunction") then
                local a, b = Network:InvokeServer()
                if typeof(a) == "Instance" and a:IsA("RemoteEvent") then
                    Remote = a
                elseif typeof(b) == "Instance" and b:IsA("RemoteEvent") then
                    Remote = b
                elseif typeof(a) == "Instance" then
                    Remote = a
                end
            elseif Network:IsA("RemoteEvent") then
                Remote = Network
            end
        end
    end)

    if not Remote then
        pcall(function()
            local screen = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
            local clientScript = screen and screen:FindFirstChild("ClientScript")
            if clientScript and type(getsenv) == "function" and type(getupvalue) == "function" then
                local env = getsenv(clientScript)
                local updatePasses = env and env.updatePasses
                if type(updatePasses) == "function" then
                    local values = getupvalue(updatePasses, 8)
                    local candidate = values and values["RemoteEvent"]
                    if typeof(candidate) == "Instance" and candidate:IsA("RemoteEvent") then
                        Remote = candidate
                    end
                end
            end
        end)
    end

    if Remote and Remote:IsA("RemoteEvent") then
        State.Remote = Remote
        State.RemoteDiscoveryDone = true
        setStatus("REMOTE READY", true)
    else
        setStatus("REMOTE NOT FOUND", false)
    end

    return Remote
end

local function fireCommand(command, args)
    local remote = EnsureRemote()
    if not remote then
        return false
    end

    return pcall(function()
        remote:FireServer(command, args)
    end)
end

EnsureRemote()

pcall(function()
    local VU = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        VU:CaptureController()
        VU:ClickButton2(Vector2.new())
    end)
end)

local function Split(s, delimiter)
    local result = {}
    s = tostring(s or "")
    for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

local function findDepthLabel()
    local sg = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
    if not sg then
        return nil
    end

    local candidates = {}

    pcall(function()
        local t1 = sg:FindFirstChild("TopInfoFrame")
        if t1 and t1:FindFirstChild("Depth") then
            table.insert(candidates, t1.Depth)
        end

        local t2 = sg:FindFirstChild("TopInfo")
        if t2 and t2:FindFirstChild("Depth") then
            table.insert(candidates, t2.Depth)
        end

        local deep = sg:FindFirstChild("Depth", true)
        if deep then
            table.insert(candidates, deep)
        end
    end)

    for _, lbl in ipairs(candidates) do
        if lbl and lbl.Text then
            local parts = Split(lbl.Text, " ")
            if tonumber(parts[1]) then
                return lbl
            end
        end
    end

    return candidates[1]
end

local function GetCurrentDepth()
    local ok, value = pcall(function()
        local label = findDepthLabel()
        if not label or not label.Text then
            return nil
        end

        local parts = Split(tostring(label.Text), " ")
        return tonumber(parts[1])
    end)

    return ok and value or nil
end

local Leaderstats = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:WaitForChild("leaderstats", 10)
local Rebirths = Leaderstats and (Leaderstats:FindFirstChild("Rebirths") or Leaderstats:WaitForChild("Rebirths", 10))
local CoinsAmount = Leaderstats and (Leaderstats:FindFirstChild("Coins") or Leaderstats:WaitForChild("Coins", 10))

local function GetCoinsAmount()
    if not CoinsAmount or CoinsAmount.Parent == nil then
        Leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        CoinsAmount = Leaderstats and Leaderstats:FindFirstChild("Coins") or nil
    end

    if not CoinsAmount then
        return 0
    end

    local raw = tostring(CoinsAmount.Value):gsub(",", "")
    return tonumber(raw) or 0
end

local function GetInventoryLabel()
    if State.InventoryLabel and State.InventoryLabel.Parent and State.InventoryLabel.Text then
        return State.InventoryLabel
    end

    local label
    pcall(function()
        local sg = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
        local stats = sg and sg:FindFirstChild("StatsFrame2")
        local inventory = stats and stats:FindFirstChild("Inventory")
        local amount = inventory and inventory:FindFirstChild("Amount")
        if amount and amount:IsA("TextLabel") then
            label = amount
        end
    end)

    if not label then
        pcall(function()
            local sg = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
            local inv = sg and sg:FindFirstChild("Inventory", true)
            local amount = inv and inv:FindFirstChild("Amount", true)
            if amount and amount:IsA("TextLabel") then
                label = amount
            end
        end)
    end

    State.InventoryLabel = label
    return label
end

local function GetInventoryAmount()
    local lbl = GetInventoryLabel()
    if not lbl or not lbl.Text then
        return 0, 0
    end

    local amount = tostring(lbl.Text)
        :gsub("%s+", "")
        :gsub(",", "")

    local slash = amount:split("/")
    return tonumber(slash[1]) or 0, tonumber(slash[2]) or 0
end

local function FindAreaByName(name)
    if type(name) ~= "string" then
        return nil
    end

    for _, area in ipairs(Areas) do
        if area.name == name then
            return area
        end
    end

    return nil
end

local function resolveAreaRuntime(area)
    if not area then return nil end

    if area.spawn and area.walkEnd and area.mine then
        return area
    end

    local spawnCF = getTeleportSpawnCFrame(area.moveTo)
    if spawnCF then
        area.spawn = spawnCF.Position
        area.walkEnd = area.walkEnd or spawnCF.Position
        area.mine = area.mine or spawnCF.Position
    end

    return area
end

local function findNearbyMinePoint(radius)
    local root = getRoot(LocalPlayer)
    local blocksFolder = workspace:FindFirstChild("Blocks")
    if not root or not blocksFolder then return nil end

    local ok, parts = pcall(function()
        local r = radius or 80
        local region = Region3.new(root.Position - Vector3.new(r, r, r), root.Position + Vector3.new(r, r, r))
        return workspace:FindPartsInRegion3WithWhiteList(region, {blocksFolder}, 100)
    end)

    if not ok or type(parts) ~= "table" then return nil end

    local best, bestDistance = nil, math.huge
    for _, part in ipairs(parts) do
        if part:IsA("BasePart") then
            local d = (root.Position - part.Position).Magnitude
            if d < bestDistance then
                bestDistance = d
                best = part.Position + Vector3.new(0, math.max(part.Size.Y * 0.5 + 2, 3), 0)
            end
        end
    end
    return best
end

local function DetectArea()
    local root = getRoot(LocalPlayer)
    if not root then return nil end

    refreshDynamicAreas()
    local best, bestDistance = nil, math.huge

    for _, area in ipairs(Areas) do
        resolveAreaRuntime(area)
        if area.mine then
            local dx = root.Position.X - area.mine.X
            local dz = root.Position.Z - area.mine.Z
            local d = dx * dx + dz * dz
            if d < bestDistance then
                bestDistance = d
                best = area
            end
        end
    end
    return best
end

local function TrackArea(force)
    if areaTransit then
        return
    end

    local now = os.clock()
    if not force and now - (State.LastFarmCheck or 0) < 2 then
        return
    end

    State.LastFarmCheck = now

    local area = DetectArea()
    if area then
        lastAreaName = area.name
    end
end

local function getAreaByName(name)
    refreshDynamicAreas()
    local area = FindAreaByName(name)
    if area then return resolveAreaRuntime(area) end
    return DetectArea() or resolveAreaRuntime(Areas[#Areas])
end

local function getMaxAvailableArea()
    -- Magic Forest is the known maximum farming world from the supplied working build.
    -- Additional worlds such as Lava are still available in the Areas menu.
    local preferred = FindAreaByName("MagicForest")
    if preferred then return preferred.name end
    refreshDynamicAreas()
    return Areas[#Areas].name
end

local function resetFarmRoute()
    State.FarmZonePosition = nil
    State.FarmRouteTried = false
    State.FarmRouteComplete = false
    State.FarmRouteArea = nil
    State.FarmCenterArea = nil
    State.LastTarget = nil
    lastMineSpot = nil
end

local function waitForTeleportMovement(root, timeout)
    local startedAt = os.clock()
    local from = root.Position

    while os.clock() - startedAt < (timeout or 4) do
        if not root or not root.Parent then
            return false
        end

        if (root.Position - from).Magnitude > 5 then
            return true
        end

        task.wait(0.1)
    end

    return false
end

local function safeSetCFrame(root, position)
    if not root then
        return false
    end

    local target = CFrame.new(position)

    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.CFrame = target
    end)

    task.wait(0.25)

    return root.Parent ~= nil and (root.Position - position).Magnitude <= 20
end

local function StartAreaRun(area)
    area = area or getAreaByName(State.SelectedArea)
    area = resolveAreaRuntime(area)
    if not area then
        return false
    end

    areaRunId += 1
    local run = areaRunId

    areaTransit = true
    State.FarmBusy = true
    State.FarmRouteTried = true
    State.FarmRouteComplete = false
    State.FarmRouteArea = area.name
    State.SelectedArea = area.name

    if AreaNameLabel then
        AreaNameLabel.Text = area.name
    end

    task.spawn(function()
        local function alive()
            return run == areaRunId
        end

        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local hum = character and character:FindFirstChildOfClass("Humanoid")

        while alive() and not root do
            task.wait(0.25)
            character = LocalPlayer.Character
            root = character and character:FindFirstChild("HumanoidRootPart")
        end

        if not alive() or not root then
            areaTransit = false
            State.FarmBusy = false
            return
        end

        if hum then
            hum.WalkSpeed = 0
            hum.JumpPower = 0
        end

        -- Portal/world transition exactly like the working build.
        if area.moveTo and EnsureRemote() then
            root.Anchored = true
            fireCommand("MoveTo", {{area.moveTo}})
            waitForTeleportMovement(root, 4)

            -- SurfaceSpawn resets the avatar to the surface before the fixed
            -- world coordinate is applied. This is part of the game's route.
            fireCommand("MoveTo", {{"SurfaceSpawn"}})
            waitForTeleportMovement(root, 4)

            resolveAreaRuntime(area)
            if area.spawn then safeSetCFrame(root, area.spawn) end
            task.wait(0.75)
        else
            root.Anchored = true
            resolveAreaRuntime(area)
            if area.spawn then safeSetCFrame(root, area.spawn) end
            task.wait(0.5)
        end

        if not alive() then
            pcall(function() root.Anchored = false end)
            areaTransit = false
            State.FarmBusy = false
            return
        end

        character = LocalPlayer.Character
        root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then
            areaTransit = false
            State.FarmBusy = false
            return
        end

        if area.spawn then
            safeSetCFrame(root, area.spawn)
        end

        -- No physical bridge/ForceField plate is created. The old helper
        -- could block the vertical mining path. Remove leftovers from
        -- previous builds instead.
        pcall(function()
            local old = workspace:FindFirstChild("NEXUS_AreaBridge")
            if old then old:Destroy() end
            local legacy = workspace:FindFirstChild("MS_AreaBridge")
            if legacy then legacy:Destroy() end
        end)

        pcall(function() root.Anchored = false end)

        if hum and hum.Parent then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end

        -- Walk along the route instead of repeatedly teleporting.
        local guard = os.clock()
        while alive() and os.clock() - guard < 120 do
            character = LocalPlayer.Character
            root = character and character:FindFirstChild("HumanoidRootPart")
            if not root then
                task.wait(0.25)
            else
                local flat = Vector3.new(
                    area.walkEnd.X - root.Position.X,
                    0,
                    area.walkEnd.Z - root.Position.Z
                )

                if flat.Magnitude <= 1.5 then
                    break
                end

                local step = flat.Unit * 0.5
                pcall(function()
                    root.CFrame = CFrame.new(
                        root.Position.X + step.X,
                        area.walkEnd.Y,
                        root.Position.Z + step.Z
                    )
                end)

                task.wait(0.01)
            end
        end

        if not alive() then
            areaTransit = false
            State.FarmBusy = false
            return
        end

        character = LocalPlayer.Character
        root = character and character:FindFirstChild("HumanoidRootPart")
        if not root then
            areaTransit = false
            State.FarmBusy = false
            return
        end

        -- Dynamic worlds such as Lava may not have hard-coded mine coordinates.
        if not area.mine then
            area.mine = findNearbyMinePoint(90) or root.Position
            area.walkEnd = area.walkEnd or area.mine
            area.spawn = area.spawn or root.Position
        end

        -- Only one controlled teleport to the real mining point.
        root.Anchored = true
        safeSetCFrame(root, area.mine)
        task.wait(0.5)
        root.Anchored = false

        local verified = (root.Position - area.mine).Magnitude <= 20

        if verified then
            lastAreaName = area.name
            lastMineSpot = area.mine
            State.FarmZonePosition = area.mine
            State.FarmRouteArea = area.name
            State.FarmRouteComplete = true
            State.FarmCenterArea = area.name
            State.LastFarmCheck = os.clock()
            TrackArea(true)
            notify("NEXUS • " .. area.name .. " FARM READY")
        else
            State.FarmRouteComplete = false
            notify("NEXUS • FARM ROUTE FAILED")
        end

        areaTransit = false
        State.FarmBusy = false
    end)

    return true
end

local function ensureFarmArea(force, silent)
    if State.FarmBusy then
        return false
    end

    if not force and State.FarmRouteComplete and State.FarmRouteArea == State.SelectedArea then
        return true
    end

    local area = getAreaByName(State.SelectedArea)
    if not area then
        return false
    end

    if not silent then
        notify("NEXUS • ROUTING TO " .. area.name)
    end

    return StartAreaRun(area)
end

local function returnToAreaCenter()
    local area = getAreaByName(State.SelectedArea)
    if not area then
        return false
    end

    areaRunId += 1
    areaTransit = true
    State.FarmBusy = true
    State.FarmRouteComplete = false
    State.FarmRouteTried = false
    State.FarmRouteArea = nil

    task.spawn(function()
        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")

        if not root then
            areaTransit = false
            State.FarmBusy = false
            return
        end

        pcall(function() root.Anchored = true end)
        safeSetCFrame(root, area.spawn)
        task.wait(0.35)
        pcall(function() root.Anchored = false end)

        local hum = character and character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end

        State.FarmCenterArea = area.name
        State.FarmZonePosition = area.spawn
        lastAreaName = area.name
        lastMineSpot = nil

        areaTransit = false
        State.FarmBusy = false

        if menuOpen then
            notify("NEXUS • " .. area.name .. " CENTER")
        end
    end)

    return true
end

local function getMiningParts(radius, maxParts, downOnly)
    local root = getRoot(LocalPlayer)
    local blocksFolder = workspace:FindFirstChild("Blocks")
    if not root or not blocksFolder then
        return {}
    end

    local ok, parts = pcall(function()
        local center = root.Position
        local minp, maxp

        if downOnly then
            minp = center + Vector3.new(-1, -10, -1)
            maxp = center + Vector3.new(1, 0, 1)
        else
            minp = center - Vector3.new(radius, radius, radius)
            maxp = center + Vector3.new(radius, radius, radius)
        end

        local region = Region3.new(minp, maxp)
        return workspace:FindPartsInRegion3WithWhiteList(region, {blocksFolder}, maxParts or 50)
    end)

    return ok and parts or {}
end

local autoMineRunning = false
local fastMineRunning = false
local autoSellRunning = false

local function StartAutoMineLoop()
    if autoMineRunning then
        return
    end
    autoMineRunning = true

    task.spawn(function()
        while State.AutoMine and State.AutoFarm do
            if areaTransit or State.FarmBusy or buyPause then
                task.wait(0.25)
            else
                local remote = EnsureRemote()
                local root = getRoot(LocalPlayer)

                if remote and root then
                    local currentDepth = nil
                    if State.LimitDepth then
                        currentDepth = GetCurrentDepth()
                    end

                    if not State.LimitDepth or currentDepth == nil or currentDepth < State.Depth then
                        local parts = getMiningParts(1, 10, true)

                        for _, block in ipairs(parts) do
                            if not State.AutoMine or not State.AutoFarm or areaTransit then
                                break
                            end

                            pcall(function()
                                remote:FireServer("MineBlock", {{block.Parent}})
                            end)

                            task.wait()
                        end

                        if #parts > 0 then
                            lastMineSpot = root.Position
                            TrackArea(false)
                        end
                    else
                        task.wait(0.5)
                    end
                else
                    task.wait(1)
                end
            end

            task.wait()
        end

        autoMineRunning = false
    end)
end

local function StartFastMineLoop()
    if fastMineRunning then
        return
    end
    fastMineRunning = true

    task.spawn(function()
        while State.FastMine do
            if areaTransit or State.FarmBusy or buyPause then
                task.wait(0.25)
            else
                local remote = EnsureRemote()
                local root = getRoot(LocalPlayer)

                if remote and root then
                    local parts = getMiningParts(5, 50, false)

                    for _, block in ipairs(parts) do
                        if not State.FastMine or areaTransit then
                            break
                        end

                        pcall(function()
                            remote:FireServer("MineBlock", {{block.Parent}})
                        end)

                        task.wait()
                    end

                    if #parts > 0 then
                        lastMineSpot = root.Position
                        TrackArea(false)
                    end
                else
                    task.wait(1)
                end
            end

            task.wait()
        end

        fastMineRunning = false
    end)
end

local function updateSellThreshold()
    -- Match the known-working script: an explicit executor threshold wins;
    -- otherwise sell at the current backpack capacity (FULL mode).
    if type(GEN.SellTreshold) == "number" and GEN.SellTreshold > 0 then
        State.SellThreshold = GEN.SellTreshold
        return State.SellThreshold
    end

    local _, maxInv = GetInventoryAmount()
    if maxInv and maxInv > 0 then
        State.SellThreshold = maxInv
    end

    return State.SellThreshold > 0 and State.SellThreshold or 30000
end

local function StartAutoSellLoop()
    if autoSellRunning then
        return
    end

    autoSellRunning = true
    sellLoopGen += 1
    local generation = sellLoopGen

    task.spawn(function()
        print("[NEXUS] AutoSell ON")

        while State.AutoSell and generation == sellLoopGen do
            local ok, err = pcall(function()
                if buyPause then
                    if os.clock() - buyPauseAt > 8 then
                        buyPause = false
                    else
                        task.wait(0.20)
                        return
                    end
                end

                local remote = EnsureRemote()
                if not remote then
                    task.wait(0.75)
                    return
                end

                local root = getRoot(LocalPlayer)
                if not root then
                    task.wait(0.50)
                    return
                end

                if not State.InventoryLabel or not State.InventoryLabel.Parent then
                    GetInventoryLabel()
                end

                local current, maximum = GetInventoryAmount()
                local threshold = updateSellThreshold()

                if maximum <= 0 or current < threshold then
                    task.wait(0.18)
                    return
                end

                if sellTrip then
                    task.wait(0.10)
                    return
                end

                sellTrip = true

                -- Lock every other movement/farm worker while the player is
                -- physically at the sell point. This prevents Auto Farm from
                -- immediately pulling the character back to the mine.
                local oldAreaTransit = areaTransit
                local oldFarmBusy = State.FarmBusy
                areaTransit = true
                State.FarmBusy = true

                local savedCFrame = root.CFrame
                local savedPosition = root.Position
                local sold = false

                -- STEP 1: move to the real sell point.
                pcall(function()
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                    root.CFrame = SellArea
                end)

                -- STEP 2: remain at SellArea for a full 2 seconds.
                -- Re-apply the CFrame every 0.05s so the server/game cannot
                -- immediately pull the character back to the mining spot.
                local holdUntil = os.clock() + 2.0
                while os.clock() < holdUntil
                    and State.AutoSell
                    and generation == sellLoopGen do

                    local sellRoot = getRoot(LocalPlayer)
                    if sellRoot then
                        root = sellRoot
                        pcall(function()
                            root.AssemblyLinearVelocity = Vector3.zero
                            root.AssemblyAngularVelocity = Vector3.zero
                            root.CFrame = SellArea
                        end)
                    end

                    task.wait(0.05)
                end

                -- STEP 3: fire SellItems only AFTER the 2-second stay.
                -- Keep the character at the sell point until the inventory
                -- actually changes, rather than returning immediately.
                local sellDeadline = os.clock() + 3.0

                while State.AutoSell
                    and generation == sellLoopGen
                    and os.clock() < sellDeadline do

                    local sellRoot = getRoot(LocalPlayer)
                    if sellRoot then
                        root = sellRoot
                        pcall(function()
                            root.AssemblyLinearVelocity = Vector3.zero
                            root.AssemblyAngularVelocity = Vector3.zero
                            root.CFrame = SellArea
                        end)
                    end

                    local beforeInv = select(1, GetInventoryAmount())

                    pcall(function()
                        remote:FireServer("SellItems", {{}})
                    end)
                    sold = true

                    task.wait(0.18)

                    local afterInv = select(1, GetInventoryAmount())
                    if afterInv < beforeInv or afterInv < threshold then
                        break
                    end
                end

                -- STEP 4: give replication a moment, but NEVER return to the
                -- farm until the sale stage has finished.
                task.wait(0.25)

                local freshRoot = getRoot(LocalPlayer)
                if freshRoot and savedCFrame then
                    for _ = 1, 5 do
                        pcall(function()
                            freshRoot.AssemblyLinearVelocity = Vector3.zero
                            freshRoot.AssemblyAngularVelocity = Vector3.zero
                            freshRoot.CFrame = savedCFrame
                        end)

                        task.wait(0.20)

                        freshRoot = getRoot(LocalPlayer) or freshRoot
                        if freshRoot and (freshRoot.Position - savedPosition).Magnitude <= 15 then
                            break
                        end
                    end
                end

                lastMineSpot = savedPosition
                State.LastSell = os.clock()

                local after = select(1, GetInventoryAmount())
                if sold and after < threshold then
                    notify("NEXUS • SOLD " .. formatNumber(current))
                elseif sold then
                    warn("[NEXUS] SellItems sent, inventory still " .. tostring(after) .. "/" .. tostring(maximum))
                end

                -- Restore movement/farm state only AFTER the full sell trip.
                State.FarmBusy = oldFarmBusy
                areaTransit = oldAreaTransit
                sellTrip = false
            end)

            if not ok then
                sellTrip = false
                areaTransit = false
                State.FarmBusy = false
                warn("[NEXUS] AutoSell error: " .. tostring(err))
                task.wait(0.75)
            else
                task.wait(0.08)
            end
        end

        sellTrip = false
        autoSellRunning = false
        print("[NEXUS] AutoSell OFF")
    end)
end

local function rebirthCost()
    local rebirthValue = Rebirths and tonumber(Rebirths.Value) or 0
    local custom = tonumber(LocalPlayer:GetAttribute("RebirthCost"))
    if custom and custom > 0 then
        return custom
    end
    return 10000000 * (rebirthValue + 1)
end

local function bindAutoRebirth()
    if rebirthConnection then
        rebirthConnection:Disconnect()
        rebirthConnection = nil
    end

    rebirthConnection = RunService.RenderStepped:Connect(function()
        if not State.AutoRebirth then
            return
        end

        if not Remote then
            EnsureRemote()
        end

        if Rebirths and Remote then
            local cost = rebirthCost()
            if GetCoinsAmount() >= cost then
                pcall(function()
                    Remote:FireServer("Rebirth", {{}})
                end)
                State.LastRebirth = os.clock()
            end
        end
    end)
end

local function StartAutoRebirth()
    rebirthRunId += 1
    local run = rebirthRunId

    if rebirthConnection then
        rebirthConnection:Disconnect()
        rebirthConnection = nil
    end

    if not State.AutoRebirth then
        rebirthPhaseText = "off"
        rebirthDigging = false
        return
    end

    bindAutoRebirth()

    task.spawn(function()
        rebirthPhaseText = "waiting to mine..."
        while State.AutoRebirth and run == rebirthRunId do
            if getRoot(LocalPlayer) and LocalPlayer:FindFirstChild("leaderstats") then
                break
            end
            task.wait(0.5)
        end

        if not State.AutoRebirth or run ~= rebirthRunId then
            return
        end

        EnsureRemote()
        rebirthPhaseText = "digging to " .. tostring(State.Depth) .. "..."
        rebirthDigging = true

        local nilStreak = 0

        while State.AutoRebirth and run == rebirthRunId do
            if buyPause or areaTransit or State.FarmBusy or sellTrip then
                task.wait(0.25)
            else
                local remote = EnsureRemote()
                local root = getRoot(LocalPlayer)

                if not remote then
                    task.wait(1)
                elseif not root then
                    task.wait(0.5)
                else
                    local depthNow = GetCurrentDepth()

                    if depthNow ~= nil and depthNow >= State.Depth then
                        break
                    end

                    if depthNow == nil then
                        nilStreak += 1
                        if nilStreak > 60 then
                            break
                        end
                    end

                    local parts = getMiningParts(1, 10, true)

                    for _, block in ipairs(parts) do
                        if not State.AutoRebirth or run ~= rebirthRunId or areaTransit then
                            break
                        end

                        pcall(function()
                            remote:FireServer("MineBlock", {{block.Parent}})
                        end)

                        task.wait()
                    end
                end

                task.wait()
            end
        end

        rebirthDigging = false

        if not State.AutoRebirth or run ~= rebirthRunId then
            rebirthPhaseText = "off"
            return
        end

        rebirthPhaseText = "mining + selling..."

        while State.AutoRebirth and run == rebirthRunId do
            if buyPause or areaTransit or sellTrip then
                task.wait(0.25)
            else
                local remote = EnsureRemote()
                local root = getRoot(LocalPlayer)

                if not remote then
                    task.wait(1)
                elseif root then
                    local parts = getMiningParts(5, 50, false)

                    for _, block in ipairs(parts) do
                        if not State.AutoRebirth or run ~= rebirthRunId or areaTransit then
                            break
                        end

                        pcall(function()
                            remote:FireServer("MineBlock", {{block.Parent}})
                        end)

                        task.wait()
                    end

                    if #parts > 0 then
                        lastMineSpot = root.Position
                        TrackArea(false)
                    end

                    -- The working build sells directly from the farm position
                    -- using the known SellArea, then returns to the saved point.
                    local threshold = updateSellThreshold()
                    local current = select(1, GetInventoryAmount())

                    if current >= threshold and not sellTrip then
                        sellTrip = true
                        local savedPosition = root.Position
                        local sold = false

                        while State.AutoRebirth
                            and run == rebirthRunId
                            and GetInventoryAmount() >= threshold
                            and not areaTransit do

                            sold = true
                            pcall(function()
                                remote:FireServer("SellItems", {{}})
                                root.CFrame = SellArea
                            end)

                            task.wait()
                            root = getRoot(LocalPlayer) or root
                        end

                        if sold then
                            root = getRoot(LocalPlayer) or root
                            for _ = 1, 4 do
                                safeSetCFrame(root, savedPosition)
                                task.wait(0.25)
                                root = getRoot(LocalPlayer) or root
                                if (root.Position - savedPosition).Magnitude <= 15 then
                                    break
                                end
                            end
                            lastMineSpot = savedPosition
                        end

                        sellTrip = false
                    end
                else
                    task.wait(0.5)
                end

                task.wait()
            end
        end

        rebirthPhaseText = "off"
    end)
end

local function StopAutoRebirth()
    rebirthRunId += 1
    rebirthPhaseText = "off"
    rebirthDigging = false

    if rebirthConnection then
        rebirthConnection:Disconnect()
        rebirthConnection = nil
    end
end

local rebirthOnlyRunning = false
local function StartRebirthOnly()
    if rebirthOnlyRunning then
        return
    end

    rebirthOnlyRunning = true

    task.spawn(function()
        while State.RebirthOnly and State.MenuOpen ~= nil do
            local remote = EnsureRemote()

            if remote and Rebirths then
                local cost = rebirthCost()

                if GetCoinsAmount() >= cost then
                    pcall(function()
                        remote:FireServer("Rebirth", {{}})
                    end)
                    State.LastRebirth = os.clock()
                else
                    task.wait(0.1)
                end
            else
                task.wait(1)
            end

            task.wait()
        end

        rebirthOnlyRunning = false
    end)
end

local function StopRebirthOnly()
    -- State toggle is enough to stop the loop.
end

--========================================================
-- SHOP LOGIC (PORTED FROM WORKING BUILD)
--========================================================

local gearToolText = "?"
local gearPackText = "?"
local lastBoughtToolText = "none yet"
local lastBoughtPackText = "none yet"
local lastToolTryText = ""

local function requireShopModules()
    local ok, result = pcall(function()
        local assets = Lighting:FindFirstChild("Assets")
        local mods = assets and assets:FindFirstChild("Modules")
        if not mods then
            return nil
        end

        local shopModule = mods:FindFirstChild("ShopModule")
        local backpackModule = mods:FindFirstChild("BackpackModule")
        local playerState

        pcall(function()
            local sg = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
            local cs = sg and sg:FindFirstChild("ClientScript")
            local client = cs and cs:FindFirstChild("Client")
            local ps = client and client:FindFirstChild("PlayerState")
            if ps then
                playerState = require(ps)
            end
        end)

        return {
            shop = shopModule and require(shopModule) or nil,
            player = playerState,
            backpack = backpackModule and require(backpackModule) or nil,
        }
    end)

    return ok and result or nil
end

local function playerDataTable()
    local ok, data = pcall(function()
        local sg = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
        local cs = sg and sg:FindFirstChild("ClientScript")
        local client = cs and cs:FindFirstChild("Client")
        local psm = client and client:FindFirstChild("PlayerState")

        if psm then
            local module = require(psm)
            if type(module) == "table" and type(module.coins) == "number" then
                return module
            end
        end

        return nil
    end)

    if ok and data then
        return data
    end

    local ok2, found = pcall(function()
        local sg = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
        local cs = sg and sg:FindFirstChild("ClientScript")

        if not cs or type(getsenv) ~= "function" then
            return nil
        end

        local env = getsenv(cs)
        if type(env) ~= "table" then
            return nil
        end

        for _, value in pairs(env) do
            if type(value) == "table"
                and type(value.coins) == "number"
                and type(value.equipped) == "table" then
                return value
            end
        end

        return nil
    end)

    return ok2 and found or nil
end

local function entryName(entry, index)
    if type(entry) == "string" then
        return entry
    end

    if type(entry) == "table" then
        if type(entry[1]) == "string" then
            return entry[1]
        end

        for _, key in ipairs({"name", "Name", "id", "Id"}) do
            if type(entry[key]) == "string" then
                return entry[key]
            end
        end
    end

    return "item" .. tostring(index)
end

local function shopPrice(entry, category)
    if type(entry) ~= "table" or entry[2] == "Group" then
        return nil
    end

    local base = tonumber(entry[2])
    if not base then
        return nil
    end

    local ok, value = pcall(function()
        local pd = playerDataTable()
        local rb = pd and tonumber(pd.rebirths) or (Rebirths and tonumber(Rebirths.Value) or 0)
        local price

        if entry.fixedPrice or rb == 0 or category == "Rebirth Shop" then
            price = math.ceil(base)
        else
            price = math.ceil(base * ((rb + 1) / 2))
        end

        local multiplier = tonumber(LocalPlayer:GetAttribute("GuildShopPriceMultiplier")) or 1
        return math.max(0, math.ceil(price * multiplier))
    end)

    return ok and value or math.ceil(base)
end

local function isOwned(entry, pd)
    local name = entryName(entry)

    local ok, owned = pcall(function()
        if not pd then
            return false
        end

        for _, list in ipairs({pd.ownedItems, pd.permanentItems}) do
            if type(list) == "table" then
                for _, n in ipairs(list) do
                    if n == name then
                        return true
                    end
                end
            end
        end

        if type(entry) == "table"
            and type(entry[3]) == "table"
            and pd.ownedPasses then
            return pd.ownedPasses[entry[3][2]] == true
        end

        return false
    end)

    return ok and owned or false
end

local function discoverShop()
    if (shopCache.tools or shopCache.packs)
        and os.clock() - shopCache.at < 60 then
        return shopCache
    end

    pcall(function()
        local modules = requireShopModules()
        local shop = modules and modules.shop

        if type(shop) ~= "table" then
            shopCache.at = os.clock()
            return
        end

        local function looksLikeShopRow(entry)
            if type(entry) ~= "table" then
                return type(entry) == "string"
            end

            if type(entry[1]) ~= "string" or entry[1] == "" then
                return false
            end

            return tonumber(entry[2]) ~= nil
                or entry[2] == "Group"
                or type(entry[3]) == "table"
        end

        local function validList(list)
            if type(list) ~= "table" or #list <= 5 then
                return false
            end

            local good, checked = 0, 0
            for i = 1, math.min(#list, 20) do
                checked += 1
                if looksLikeShopRow(list[i]) then
                    good += 1
                end
            end

            return checked > 0 and (good / checked) >= 0.7
        end

        local tools = shop.Tools
        local packs = shop.Backpack

        shopCache.tools = validList(tools) and tools or nil
        shopCache.packs = validList(packs) and packs or nil
        shopCache.at = os.clock()
    end)

    return shopCache
end

local function equippedToolName()
    local character = LocalPlayer.Character
    if character then
        for _, object in ipairs(character:GetChildren()) do
            if object:IsA("Tool") then
                return object.Name
            end
        end
    end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, object in ipairs(backpack:GetChildren()) do
            if object:IsA("Tool") then
                return object.Name
            end
        end
    end

    return "?"
end

local function toolSignature()
    local names = {}

    pcall(function()
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then
            for _, tool in ipairs(bp:GetChildren()) do
                if tool:IsA("Tool") then
                    table.insert(names, tool.Name)
                end
            end
        end

        local ch = LocalPlayer.Character
        if ch then
            for _, tool in ipairs(ch:GetChildren()) do
                if tool:IsA("Tool") then
                    table.insert(names, tool.Name)
                end
            end
        end
    end)

    table.sort(names)
    return table.concat(names, "|") .. "#" .. tostring(#names)
end

local function packSignature()
    local _, maximum = GetInventoryAmount()
    return "max" .. tostring(maximum)
end

local function bestToolIndex(shop)
    if type(shop) ~= "table" then
        return 0
    end

    local pd = playerDataTable()
    local current = pd and pd.equipped and pd.equipped[3]

    if type(current) ~= "string" or current == "" then
        current = equippedToolName()
    end

    for index, entry in ipairs(shop) do
        if entryName(entry, index) == current then
            return index
        end
    end

    return 0
end

local function bestPackIndex(shop)
    if type(shop) ~= "table" then
        return 0
    end

    local pd = playerDataTable()
    local current = pd and pd.equipped and pd.equipped[1]

    if type(current) ~= "string" or current == "" then
        return 0
    end

    for index, entry in ipairs(shop) do
        if entryName(entry, index) == current then
            return index
        end
    end

    return 0
end

local function bestBuy(shop, ownedIndex, startIndex, coins, category)
    if type(shop) ~= "table" or #shop == 0 then
        return nil, "NOSHOP"
    end

    local pd = playerDataTable()
    local best, cheapestMissing = nil, nil

    for index = math.max(ownedIndex + 1, startIndex or 1), #shop do
        if not refusedBuy[category .. "#" .. index]
            and not isOwned(shop[index], pd) then

            local price = shopPrice(shop[index], category)

            if price ~= nil then
                if not cheapestMissing then
                    cheapestMissing = price
                end

                if price <= coins then
                    best = index
                end
            end
        end
    end

    if best then
        return best, "OK"
    end

    if cheapestMissing and cheapestMissing > coins then
        return nil, "POOR"
    end

    return nil, "MAX"
end

local function StartAutoBackpackLoop()
    if packBuyerRunning then
        return
    end

    packBuyerRunning = true

    task.spawn(function()
        local failCount = 0
        local memory = 3

        while State.AutoBackpack do
            if areaTransit or State.FarmBusy then
                task.wait(0.5)
            else
                local remote = EnsureRemote()
                local shop = discoverShop().packs

                if not remote then
                    task.wait(1)
                elseif shop then
                    local bought = 0
                    local chained = 0

                    while State.AutoBackpack and chained < 10 do
                        local coins = GetCoinsAmount()
                        local owned = bestPackIndex(shop)
                        local index, why = bestBuy(shop, owned, 3, coins, "Backpack")

                        if not index then
                            lastBoughtPackText = why == "MAX" and "MAX (best owned)" or "saving (next too pricey)"
                            break
                        end

                        buyPause = true
                        buyPauseAt = os.clock()
                        pcall(function()
                            remote:FireServer("BuyItem", {{"Backpack", index}})
                        end)

                        task.wait(0.9)
                        buyPause = false

                        local _, maxInv = GetInventoryAmount()
                        bought += 1
                        chained += 1
                        memory = index + 1
                        lastBoughtPackText = "Pack #" .. tostring(index)
                        gearPackText = "max " .. tostring(maxInv)
                    end

                    failCount = bought == 0 and failCount + 1 or 0
                    task.wait(bought > 0 and 0.1 or math.min(2 + failCount * 2, 12))
                else
                    -- Fallback from the working build: try raw IDs.
                    local bought = 0
                    local index = memory

                    for _ = 1, 10 do
                        if not State.AutoBackpack then
                            break
                        end

                        if index > 50 then
                            index = 3
                        end

                        buyPause = true
                        buyPauseAt = os.clock()
                        pcall(function()
                            remote:FireServer("BuyItem", {{"Backpack", index}})
                        end)
                        task.wait(0.3)
                        buyPause = false

                        bought += 1
                        lastBoughtPackText = "Pack #" .. tostring(index)
                        memory = index + 1
                        index += 1
                    end

                    task.wait(bought > 0 and 0.1 or 2)
                end
            end
        end

        packBuyerRunning = false
    end)
end

local function StartAutoToolsLoop()
    if toolBuyerRunning then
        return
    end

    toolBuyerRunning = true

    task.spawn(function()
        local failCount = 0
        local memory = 1

        while State.AutoTools do
            if areaTransit or State.FarmBusy then
                task.wait(0.5)
            else
                local remote = EnsureRemote()
                local shop = discoverShop().tools

                if not remote then
                    task.wait(1)
                elseif shop then
                    local bought = 0
                    local chained = 0

                    while State.AutoTools and chained < 10 do
                        local coins = GetCoinsAmount()
                        local owned = bestToolIndex(shop)
                        local index, why = bestBuy(shop, owned, 1, coins, "Tools")

                        if not index then
                            lastBoughtToolText = why == "MAX" and "MAX (best owned)" or "saving (next too pricey)"
                            break
                        end

                        buyPause = true
                        buyPauseAt = os.clock()

                        pcall(function()
                            remote:FireServer("BuyItem", {{"Tools", index}})
                        end)

                        task.wait(0.35)

                        pcall(function()
                            remote:FireServer("EquipItem", {{"Tools", entryName(shop[index], index)}})
                        end)

                        task.wait(0.9)
                        buyPause = false

                        bought += 1
                        chained += 1
                        memory = index + 1
                        lastBoughtToolText = "Tool #" .. tostring(index)
                        gearToolText = equippedToolName()
                        lastToolTryText = ""
                    end

                    failCount = bought == 0 and failCount + 1 or 0
                    task.wait(bought > 0 and 0.1 or math.min(2 + failCount * 2, 12))
                else
                    local bought = 0
                    local index = memory

                    for _ = 1, 10 do
                        if not State.AutoTools then
                            break
                        end

                        if index > 50 then
                            index = 1
                        end

                        buyPause = true
                        buyPauseAt = os.clock()
                        pcall(function()
                            remote:FireServer("BuyItem", {{"Tools", index}})
                        end)
                        task.wait(0.3)
                        buyPause = false

                        bought += 1
                        lastBoughtToolText = "Tool #" .. tostring(index)
                        gearToolText = equippedToolName()
                        memory = index + 1
                        index += 1
                    end

                    task.wait(bought > 0 and 0.1 or 2)
                end
            end
        end

        toolBuyerRunning = false
    end)
end

local function updateCoreStatus()
    local current, maximum = GetInventoryAmount()
    local depth = GetCurrentDepth()

    if InventoryStatusLabel then
        InventoryStatusLabel.Text = string.format(
            "Inventory: %s / %s",
            tostring(current),
            tostring(maximum)
        )
    end

    if State.AutoRebirth then
        setStatus("AUTO REBIRTH • " .. rebirthPhaseText, true)
    elseif State.AutoFarm then
        setStatus(State.FarmRouteComplete and "AUTO FARM • RUNNING" or "AUTO FARM • ROUTING", true)
    elseif State.AutoSell then
        setStatus("AUTO SELL • READY", true)
    elseif depth then
        setStatus("DEPTH " .. tostring(depth), true)
    end
end

-- Compatibility functions used by the existing NEXUS GUI.
local function doMine()
    if State.AutoFarm and not State.FarmRouteComplete and not State.FarmBusy then
        ensureFarmArea(false, true)
    end
end

local function performSell()
    local remote = EnsureRemote()
    local root = getRoot(LocalPlayer)
    if not remote or not root then
        return false
    end

    local savedCFrame = root.CFrame
    local savedPosition = root.Position
    local current = select(1, GetInventoryAmount())
    local threshold = updateSellThreshold()

    if current < threshold then
        return false
    end

    sellTrip = true
    local oldAreaTransit = areaTransit
    local oldFarmBusy = State.FarmBusy
    areaTransit = true
    State.FarmBusy = true

    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.CFrame = SellArea
    end)

    local holdUntil = os.clock() + 2.0
    while os.clock() < holdUntil do
        root = getRoot(LocalPlayer) or root
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            root.CFrame = SellArea
        end)
        task.wait(0.05)
    end

    local deadline = os.clock() + 3.0
    while os.clock() < deadline do
        root = getRoot(LocalPlayer) or root
        pcall(function()
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            root.CFrame = SellArea
            remote:FireServer("SellItems", {{}})
        end)

        task.wait(0.18)

        local after = select(1, GetInventoryAmount())
        if after < current or after < threshold then
            break
        end
    end

    task.wait(0.25)

    root = getRoot(LocalPlayer) or root
    for _ = 1, 5 do
        safeSetCFrame(root, savedCFrame)
        task.wait(0.20)
        root = getRoot(LocalPlayer) or root
        if root and (root.Position - savedPosition).Magnitude <= 15 then
            break
        end
    end

    State.LastSell = os.clock()
    State.FarmBusy = oldFarmBusy
    areaTransit = oldAreaTransit
    sellTrip = false
    return true
end

local function doRebirth()
    local remote = EnsureRemote()
    if not remote then
        return false
    end

    if GetCoinsAmount() < rebirthCost() then
        return false
    end

    local before = Rebirths and Rebirths.Value or 0

    pcall(function()
        remote:FireServer("Rebirth", {{}})
    end)

    local deadline = os.clock() + 2
    while os.clock() < deadline do
        if Rebirths and Rebirths.Value > before then
            break
        end
        task.wait(0.05)
    end

    if Rebirths and Rebirths.Value > before then
        State.LastRebirth = os.clock()
        notify("NEXUS • REBIRTH #" .. tostring(Rebirths.Value))
        return true
    end

    return false
end

local function runAutomationCycle()
    if State.RebirthOnly then
        return
    end

    if State.AutoRebirth and not rebirthConnection then
        StartAutoRebirth()
    end

    if State.AutoSell and not sellTrip then
        -- Dedicated loop handles actual selling.
    end
end

local function StartAutomationFromToggle()
    if State.AutoFarm and not State.AutoMine then
        State.AutoMine = true
        StartAutoMineLoop()
    end

    if State.FastMine then
        StartFastMineLoop()
    end

    if State.AutoSell then
        StartAutoSellLoop()
    end

    if State.AutoRebirth then
        StartAutoRebirth()
    end

    if State.RebirthOnly then
        StartRebirthOnly()
    end

    if State.AutoBackpack then
        StartAutoBackpackLoop()
    end

    if State.AutoTools then
        StartAutoToolsLoop()
    end
end

-- Executor-compatible configuration watchers.
task.spawn(function()
    while ScreenGui and ScreenGui.Parent do
        if type(GEN.SellTreshold) == "number" and GEN.SellTreshold > 0 then
            State.SellThreshold = GEN.SellTreshold
        end

        if type(GEN.Depth) == "number" and GEN.Depth >= 0 then
            State.Depth = GEN.Depth
        end

        updateCoreStatus()
        task.wait(0.5)
    end
end)


--// Compatibility layer for the original NEXUS UI

local function getRebirthCost()
    return rebirthCost()
end

local function initializeRebirthBaseline()
    State.RebirthBaseBlocks = getBlocksMined()
end

local function getTeleportPoint(pointName, areaName)
    local area = FindAreaByName(areaName)

    if not area and type(pointName) == "string" then
        for _, candidate in ipairs(Areas) do
            if candidate.moveTo == pointName or candidate.name .. "Spawn" == pointName then
                area = candidate
                break
            end
        end
    end

    return area
end

local function getTeleportCF(pointName, areaName)
    local area = getTeleportPoint(pointName, areaName)
    if area then
        return area, CFrame.new(area.spawn)
    end
    return nil, nil
end

local function scanShop()
    local cache = discoverShop()
    table.clear(State.ShopEntries)

    local function addList(list, category)
        if type(list) ~= "table" then
            return
        end

        for index, entry in ipairs(list) do
            local price = shopPrice(entry, category)
            if price then
                table.insert(State.ShopEntries, {
                    Name = entryName(entry, index),
                    Index = index,
                    Price = price,
                    Category = category,
                    Raw = entry,
                })
            end
        end
    end

    addList(cache.tools, "Tools")
    addList(cache.packs, "Backpack")

    table.sort(State.ShopEntries, function(a, b)
        if a.Category == b.Category then
            return a.Price < b.Price
        end
        return a.Category < b.Category
    end)

    return State.ShopEntries
end

local function buyAndEquipBest(category)
    local cache = discoverShop()
    local shop = category == "Tools" and cache.tools or cache.packs

    if type(shop) ~= "table" then
        return false
    end

    local owned = category == "Tools" and bestToolIndex(shop) or bestPackIndex(shop)
    local index = bestBuy(shop, owned, category == "Tools" and 1 or 3, GetCoinsAmount(), category)

    if not index then
        return false
    end

    local remote = EnsureRemote()
    if not remote then
        return false
    end

    buyPause = true
    buyPauseAt = os.clock()

    local ok = pcall(function()
        remote:FireServer("BuyItem", {{category, index}})
    end)

    task.wait(0.35)

    if category == "Tools" then
        pcall(function()
            remote:FireServer("EquipItem", {{"Tools", entryName(shop[index], index)}})
        end)
    end

    task.wait(0.35)
    buyPause = false

    return ok
end

-- Worker manager: the UI only changes booleans; this starts/stops the
-- proven game-specific workers automatically and prevents duplicate loops.
task.spawn(function()
    local wasAutoRebirth = false

    while ScreenGui and ScreenGui.Parent do
        if State.AutoMine and State.AutoFarm and not autoMineRunning then
            StartAutoMineLoop()
        end

        if State.FastMine and not fastMineRunning then
            StartFastMineLoop()
        end

        if State.AutoSell and not autoSellRunning then
            StartAutoSellLoop()
        end

        if State.AutoBackpack and not packBuyerRunning then
            StartAutoBackpackLoop()
        end

        if State.AutoTools and not toolBuyerRunning then
            StartAutoToolsLoop()
        end

        if State.AutoRebirth and not wasAutoRebirth then
            StartAutoRebirth()
        elseif not State.AutoRebirth and wasAutoRebirth then
            StopAutoRebirth()
        end

        wasAutoRebirth = State.AutoRebirth

        if State.RebirthOnly then
            StartRebirthOnly()
        end

        task.wait(0.15)
    end
end)

--// GUI ROOT
local existing = PlayerGui:FindFirstChild("NexusMiningHub")
if existing then
    existing:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexusMiningHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Remove any bridge left behind by an older NEXUS build.
pcall(function()
    for _, name in ipairs({"NEXUS_AreaBridge", "MS_AreaBridge"}) do
        local old = workspace:FindFirstChild(name)
        if old then old:Destroy() end
    end
end)

local RootScale = Instance.new("UIScale")
RootScale.Scale = 1
RootScale.Parent = ScreenGui

local function updateScale()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local viewport = camera.ViewportSize
    local shortest = math.min(viewport.X, viewport.Y)
    local scale = 1

    if shortest < 650 then
        scale = math.clamp(shortest / 650, 0.82, 1)
    elseif shortest > 1100 then
        scale = 1.08
    end

    RootScale.Scale = scale
end

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    task.defer(updateScale)
end)

task.defer(updateScale)

--// BACKDROP
local Backdrop = Instance.new("TextButton")
Backdrop.Name = "Backdrop"
Backdrop.Size = UDim2.fromScale(1, 1)
Backdrop.BackgroundColor3 = Color3.fromRGB(0, 3, 9)
Backdrop.BackgroundTransparency = 0.40
Backdrop.BorderSizePixel = 0
Backdrop.Text = ""
Backdrop.AutoButtonColor = false
Backdrop.Visible = true
Backdrop.ZIndex = 1
Backdrop.Parent = ScreenGui

--// MAIN
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.Size = UDim2.new(0.94, 0, 0.82, 0)
Main.BackgroundColor3 = CONFIG.Colors.Background
Main.BorderSizePixel = 0
Main.ZIndex = 2
Main.Parent = ScreenGui
round(Main, 18)
stroke(Main, CONFIG.Colors.Border, 0.10, 1.2)

local MainSize = Instance.new("UISizeConstraint")
MainSize.MinSize = Vector2.new(320, 430)
MainSize.MaxSize = Vector2.new(560, 700)
MainSize.Parent = Main

--// HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, -18, 0, 66)
Header.Position = UDim2.fromOffset(9, 9)
Header.BackgroundColor3 = CONFIG.Colors.Panel
Header.BorderSizePixel = 0
Header.ZIndex = 3
Header.Parent = Main
round(Header, 14)
stroke(Header, CONFIG.Colors.Border, 0.30, 1)

local HeaderGlow = Instance.new("Frame")
HeaderGlow.Size = UDim2.new(1, -26, 0, 3)
HeaderGlow.Position = UDim2.fromOffset(13, 0)
HeaderGlow.BackgroundColor3 = CONFIG.Colors.Accent
HeaderGlow.BorderSizePixel = 0
HeaderGlow.ZIndex = 4
HeaderGlow.Parent = Header
round(HeaderGlow, 3)
gradient(HeaderGlow, CONFIG.Colors.Accent, CONFIG.Colors.Accent2, 0)

local Logo = Instance.new("Frame")
Logo.Size = UDim2.fromOffset(46, 46)
Logo.Position = UDim2.fromOffset(10, 10)
Logo.BackgroundColor3 = CONFIG.Colors.Accent
Logo.BorderSizePixel = 0
Logo.ZIndex = 5
Logo.Parent = Header
round(Logo, 13)
stroke(Logo, CONFIG.Colors.Accent2, 0.05, 1)
gradient(Logo, CONFIG.Colors.Accent2, CONFIG.Colors.Accent, 135)

local LogoText = makeLabel(
    Logo,
    "N",
    UDim2.fromScale(1, 1),
    UDim2.fromScale(0, 0),
    25,
    CONFIG.Colors.White,
    Enum.Font.GothamBlack
)
LogoText.TextXAlignment = Enum.TextXAlignment.Center

local Title = makeLabel(
    Header,
    "NEXUS",
    UDim2.new(1, -180, 0, 24),
    UDim2.fromOffset(68, 8),
    17,
    CONFIG.Colors.White,
    Enum.Font.GothamBlack
)

local Subtitle = makeLabel(
    Header,
    "MINING HUB • MOBILE",
    UDim2.new(1, -180, 0, 18),
    UDim2.fromOffset(69, 31),
    8,
    CONFIG.Colors.Muted,
    Enum.Font.GothamBold
)

local Version = makeLabel(
    Header,
    "v" .. CONFIG.Version,
    UDim2.fromOffset(55, 18),
    UDim2.new(1, -113, 0, 9),
    8,
    CONFIG.Colors.Accent2,
    Enum.Font.GothamBlack
)
Version.TextXAlignment = Enum.TextXAlignment.Right

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.fromOffset(8, 8)
StatusDot.Position = UDim2.new(1, -19, 0, 14)
StatusDot.BackgroundColor3 = CONFIG.Colors.Good
StatusDot.BorderSizePixel = 0
StatusDot.ZIndex = 6
StatusDot.Parent = Header
round(StatusDot, 8)

StatusLabel = makeLabel(
    Header,
    "INITIALIZING",
    UDim2.fromOffset(95, 18),
    UDim2.new(1, -105, 0, 25),
    7,
    CONFIG.Colors.Good,
    Enum.Font.GothamBold
)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Right

local CloseButton = makeButton(
    Header,
    "×",
    UDim2.fromOffset(34, 34),
    UDim2.new(1, -43, 0, 25)
)
CloseButton.TextSize = 23
CloseButton.ZIndex = 7

--// CONTENT
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -18, 1, -132)
Content.Position = UDim2.fromOffset(9, 80)
Content.BackgroundTransparency = 1
Content.ZIndex = 3
Content.Parent = Main

local Pages = {}

for _, tabName in ipairs({"Mining", "Rebirth", "Shop", "Areas", "Settings"}) do
    local page = Instance.new("ScrollingFrame")
    page.Name = tabName
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = CONFIG.Colors.Accent
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.fromOffset(0, 0)
    page.Visible = false
    page.ZIndex = 4
    page.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 12)
    pad.PaddingLeft = UDim.new(0, 2)
    pad.PaddingRight = UDim.new(0, 2)
    pad.Parent = page

    Pages[tabName] = page
end

--// TOGGLES
local function createToggle(page, title, description, initial, callback)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -4, 0, 58)
    card.BackgroundColor3 = CONFIG.Colors.Panel2
    card.BorderSizePixel = 0
    card.ZIndex = 5
    card.Parent = page
    round(card, 12)
    stroke(card, CONFIG.Colors.Border, 0.42, 1)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.fromOffset(4, 34)
    accent.Position = UDim2.fromOffset(0, 12)
    accent.BackgroundColor3 = CONFIG.Colors.Accent
    accent.BorderSizePixel = 0
    accent.Parent = card
    round(accent, 2)

    local titleLabel = makeLabel(
        card,
        title,
        UDim2.new(1, -92, 0, 20),
        UDim2.fromOffset(14, 7),
        10,
        CONFIG.Colors.White,
        Enum.Font.GothamBold
    )

    local descLabel = makeLabel(
        card,
        description,
        UDim2.new(1, -92, 0, 21),
        UDim2.fromOffset(14, 29),
        7,
        CONFIG.Colors.Muted,
        Enum.Font.Gotham
    )
    descLabel.TextWrapped = true

    local button = makeButton(
        card,
        "OFF",
        UDim2.fromOffset(58, 30),
        UDim2.new(1, -70, 0.5, -15)
    )
    button.ZIndex = 6

    local state = initial and true or false

    local function refresh()
        setButtonState(button, state)
        callback(state)
    end

    button.Activated:Connect(function()
        state = not state
        refresh()
    end)

    refresh()

    return {
        Set = function(value)
            state = value and true or false
            refresh()
        end,
        Get = function()
            return state
        end,
    }
end

--// MINING PAGE
makeLabel(
    Pages.Mining,
    "AUTOMATION",
    UDim2.new(1, -4, 0, 24),
    UDim2.fromOffset(2, 0),
    11,
    CONFIG.Colors.Muted,
    Enum.Font.GothamBlack
)

local areaInfo = Instance.new("Frame")
areaInfo.Size = UDim2.new(1, -4, 0, 66)
areaInfo.BackgroundColor3 = CONFIG.Colors.Panel
areaInfo.BorderSizePixel = 0
areaInfo.ZIndex = 5
areaInfo.Parent = Pages.Mining
round(areaInfo, 13)
stroke(areaInfo, CONFIG.Colors.Border, 0.30, 1)

makeLabel(
    areaInfo,
    "SELECTED AREA",
    UDim2.new(0.5, -10, 0, 18),
    UDim2.fromOffset(13, 10),
    8,
    CONFIG.Colors.Muted,
    Enum.Font.GothamBold
)

AreaNameLabel = makeLabel(
    areaInfo,
    State.SelectedArea,
    UDim2.new(0.5, -10, 0, 26),
    UDim2.fromOffset(13, 27),
    14,
    CONFIG.Colors.White,
    Enum.Font.GothamBlack
)

local MaxAreaButton = makeButton(
    areaInfo,
    "MAX AREA",
    UDim2.fromOffset(102, 32),
    UDim2.new(1, -115, 0.5, -16)
)
MaxAreaButton.Activated:Connect(function()
    local maxArea = getMaxAvailableArea()
    State.SelectedArea = maxArea
    resetFarmRoute()
    AreaNameLabel.Text = maxArea

    if State.AutoFarm or State.AutoMine then
        task.spawn(function()
            ensureFarmArea(true, false)
        end)
    end
end)

MiningToggle = createToggle(
    Pages.Mining,
    "Auto Farm",
    "Portal -> max world -> farm zone -> automatic mining.",
    false,
    function(value)
        State.AutoMine = value
        State.AutoFarm = value

        if value then
            local maxArea = getMaxAvailableArea()
            State.SelectedArea = maxArea
            resetFarmRoute()

            if AreaNameLabel then
                AreaNameLabel.Text = maxArea
            end

            task.spawn(function()
                ensureFarmArea(true, false)
                StartAutoMineLoop()
            end)
        else
            task.spawn(function()
                returnToAreaCenter()
            end)
        end
    end
)

FastMiningToggle = createToggle(
    Pages.Mining,
    "Fast Mine",
    "Uses the faster mining interval from the core.",
    false,
    function(value)
        State.FastMine = value
        if value then
            StartFastMineLoop()
        end
    end
)

SellToggle = createToggle(
    Pages.Mining,
    "Auto Sell",
    "Automatically sells when the backpack reaches the threshold.",
    false,
    function(value)
        State.AutoSell = value
        if value then
            StartAutoSellLoop()
        end
    end
)

local SellSettingsCard = Instance.new("Frame")
SellSettingsCard.Size = UDim2.new(1, -4, 0, 66)
SellSettingsCard.BackgroundColor3 = CONFIG.Colors.Panel2
SellSettingsCard.BorderSizePixel = 0
SellSettingsCard.ZIndex = 5
SellSettingsCard.Parent = Pages.Mining
round(SellSettingsCard, 12)
stroke(SellSettingsCard, CONFIG.Colors.Border, 0.42, 1)

makeLabel(
    SellSettingsCard,
    "SELL THRESHOLD",
    UDim2.new(0.46, 0, 0, 20),
    UDim2.fromOffset(14, 8),
    9,
    CONFIG.Colors.White,
    Enum.Font.GothamBold
)

makeLabel(
    SellSettingsCard,
    "Sell when backpack reaches this amount",
    UDim2.new(0.60, 0, 0, 18),
    UDim2.fromOffset(14, 30),
    7,
    CONFIG.Colors.Muted,
    Enum.Font.Gotham
)

local SellThresholdBox = Instance.new("TextBox")
SellThresholdBox.Size = UDim2.fromOffset(116, 34)
SellThresholdBox.Position = UDim2.new(1, -126, 0.5, -17)
SellThresholdBox.BackgroundColor3 = CONFIG.Colors.Panel3
SellThresholdBox.BorderSizePixel = 0
SellThresholdBox.ClearTextOnFocus = false
SellThresholdBox.PlaceholderText = "30000"
SellThresholdBox.Text = (type(GEN.SellTreshold) == "number" and GEN.SellTreshold > 0) and tostring(State.SellThreshold) or "FULL"
SellThresholdBox.TextColor3 = CONFIG.Colors.White
SellThresholdBox.PlaceholderColor3 = CONFIG.Colors.Muted
SellThresholdBox.Font = Enum.Font.GothamBold
SellThresholdBox.TextSize = 11
SellThresholdBox.TextXAlignment = Enum.TextXAlignment.Center
SellThresholdBox.ZIndex = 6
SellThresholdBox.Parent = SellSettingsCard
round(SellThresholdBox, 9)
stroke(SellThresholdBox, CONFIG.Colors.Border, 0.22, 1)

local InventoryStatusLabel = makeLabel(
    Pages.Mining,
    "Inventory: 0 / 0",
    UDim2.new(1, -4, 0, 20),
    UDim2.fromOffset(2, 0),
    8,
    CONFIG.Colors.Muted,
    Enum.Font.GothamBold
)

SellThresholdBox.FocusLost:Connect(function()
    local raw = tostring(SellThresholdBox.Text or "")
    local clean = raw:gsub(",", ""):gsub("%s+", "")
    local upper = clean:upper()

    if upper == "" or upper == "FULL" or upper == "MAX" or upper == "NIL" then
        GEN.SellTreshold = nil
        local _, maxInv = GetInventoryAmount()
        State.SellThreshold = (maxInv and maxInv > 0) and maxInv or 30000
        SellThresholdBox.Text = "FULL"
        notify("NEXUS • SELL AT FULL")
        return
    end

    local value = tonumber(clean:match("%d+"))

    if value and value > 0 then
        State.SellThreshold = math.floor(value)
        GEN.SellTreshold = State.SellThreshold
        SellThresholdBox.Text = tostring(State.SellThreshold)
        notify("NEXUS • SELL AT " .. formatNumber(State.SellThreshold))
    else
        SellThresholdBox.Text = (type(GEN.SellTreshold) == "number" and GEN.SellTreshold > 0) and tostring(State.SellThreshold) or "FULL"
    end
end)

BackpackToggle = createToggle(
    Pages.Mining,
    "Auto Backpack",
    "Buys the highest affordable backpack detected from the shop.",
    false,
    function(value)
        State.AutoBackpack = value
        if value then
            StartAutoBackpackLoop()
        end
    end
)

ToolsToggle = createToggle(
    Pages.Mining,
    "Auto Tools",
    "Buys/equips the highest affordable tool detected.",
    false,
    function(value)
        State.AutoTools = value
        if value then
            StartAutoToolsLoop()
        end
    end
)

SprintToggle = createToggle(
    Pages.Mining,
    "Sprint",
    "Keeps your Humanoid WalkSpeed at the selected sprint value.",
    false,
    function(value)
        State.Sprint = value
    end
)

--// REBIRTH PAGE
makeLabel(
    Pages.Rebirth,
    "REBIRTH SYSTEM",
    UDim2.new(1, -4, 0, 24),
    UDim2.fromOffset(2, 0),
    11,
    CONFIG.Colors.Muted,
    Enum.Font.GothamBlack
)

local rebirthInfo = Instance.new("Frame")
rebirthInfo.Size = UDim2.new(1, -4, 0, 132)
rebirthInfo.BackgroundColor3 = CONFIG.Colors.Panel
rebirthInfo.BorderSizePixel = 0
rebirthInfo.ZIndex = 5
rebirthInfo.Parent = Pages.Rebirth
round(rebirthInfo, 13)
stroke(rebirthInfo, CONFIG.Colors.Border, 0.30, 1)

RebirthStatsLabel = makeLabel(
    rebirthInfo,
    "Loading rebirth data...",
    UDim2.new(1, -26, 1, -18),
    UDim2.fromOffset(13, 9),
    9,
    CONFIG.Colors.White,
    Enum.Font.Gotham
)
RebirthStatsLabel.TextYAlignment = Enum.TextYAlignment.Top
RebirthStatsLabel.TextWrapped = false
RebirthStatsLabel.RichText = false

RebirthToggle = createToggle(
    Pages.Rebirth,
    "Auto Rebirth",
    "Rebirths immediately when the configured coin cost is reached.",
    false,
    function(value)
        State.AutoRebirth = value

        if value then
            State.AutoFarm = false
            State.AutoMine = false
            State.FastMine = false
            resetFarmRoute()
            StartAutoRebirth()

            local maxArea = getMaxAvailableArea()
            State.SelectedArea = maxArea
            resetFarmRoute()

            if AreaNameLabel then
                AreaNameLabel.Text = maxArea
            end

            if State.AutoFarm or State.AutoMine then
                task.spawn(function()
                    ensureFarmArea(true, true)
                end)
            end
        else
            StopAutoRebirth()
        end
    end
)

RebirthOnlyToggle = createToggle(
    Pages.Rebirth,
    "Rebirth Only",
    "Stops mining automation and runs only the rebirth cycle.",
    false,
    function(value)
        State.RebirthOnly = value

        if value then
            State.AutoMine = false
            State.AutoFarm = false
            State.FastMine = false
            State.AutoSell = false
            State.AutoRebirth = false
            StopAutoRebirth()
        end
    end
)

local ManualRebirth = makeButton(
    Pages.Rebirth,
    "REBIRTH NOW",
    UDim2.new(1, -4, 0, 44),
    UDim2.fromOffset(2, 0)
)
ManualRebirth.BackgroundColor3 = CONFIG.Colors.Accent
ManualRebirth.Activated:Connect(function()
    doRebirth()
end)

local DepthSettingsCard = Instance.new("Frame")
DepthSettingsCard.Size = UDim2.new(1, -4, 0, 66)
DepthSettingsCard.BackgroundColor3 = CONFIG.Colors.Panel2
DepthSettingsCard.BorderSizePixel = 0
DepthSettingsCard.ZIndex = 5
DepthSettingsCard.Parent = Pages.Rebirth
round(DepthSettingsCard, 12)
stroke(DepthSettingsCard, CONFIG.Colors.Border, 0.42, 1)

makeLabel(
    DepthSettingsCard,
    "AUTO REBIRTH DEPTH",
    UDim2.new(0.55, 0, 0, 20),
    UDim2.fromOffset(14, 8),
    9,
    CONFIG.Colors.White,
    Enum.Font.GothamBold
)

makeLabel(
    DepthSettingsCard,
    "Dig target used by the working AutoRebirth route",
    UDim2.new(0.66, 0, 0, 18),
    UDim2.fromOffset(14, 30),
    7,
    CONFIG.Colors.Muted,
    Enum.Font.Gotham
)

local DepthBox = Instance.new("TextBox")
DepthBox.Size = UDim2.fromOffset(100, 34)
DepthBox.Position = UDim2.new(1, -110, 0.5, -17)
DepthBox.BackgroundColor3 = CONFIG.Colors.Panel3
DepthBox.BorderSizePixel = 0
DepthBox.ClearTextOnFocus = false
DepthBox.Text = tostring(State.Depth)
DepthBox.PlaceholderText = "205"
DepthBox.TextColor3 = CONFIG.Colors.White
DepthBox.PlaceholderColor3 = CONFIG.Colors.Muted
DepthBox.Font = Enum.Font.GothamBold
DepthBox.TextSize = 11
DepthBox.TextXAlignment = Enum.TextXAlignment.Center
DepthBox.ZIndex = 6
DepthBox.Parent = DepthSettingsCard
round(DepthBox, 9)
stroke(DepthBox, CONFIG.Colors.Border, 0.22, 1)

DepthBox.FocusLost:Connect(function()
    local raw = tostring(DepthBox.Text or "")
    local digits = raw:gsub(",", ""):match("%d+")
    local value = digits and tonumber(digits)
    if value then
        State.Depth = math.clamp(math.floor(value), 0, 5000)
        GEN.Depth = State.Depth
        DepthBox.Text = tostring(State.Depth)
        notify("NEXUS • DEPTH " .. tostring(State.Depth))
    else
        DepthBox.Text = tostring(State.Depth)
    end
end)

--// SHOP PAGE
makeLabel(
    Pages.Shop,
    "SHOP / EQUIPMENT",
    UDim2.new(1, -4, 0, 24),
    UDim2.fromOffset(2, 0),
    11,
    CONFIG.Colors.Muted,
    Enum.Font.GothamBlack
)

local ShopStatus = Instance.new("Frame")
ShopStatus.Size = UDim2.new(1, -4, 0, 76)
ShopStatus.BackgroundColor3 = CONFIG.Colors.Panel
ShopStatus.BorderSizePixel = 0
ShopStatus.ZIndex = 5
ShopStatus.Parent = Pages.Shop
round(ShopStatus, 13)
stroke(ShopStatus, CONFIG.Colors.Border, 0.30, 1)

local ShopCountLabel = makeLabel(
    ShopStatus,
    "Detected entries: 0",
    UDim2.new(1, -24, 0, 24),
    UDim2.fromOffset(12, 9),
    10,
    CONFIG.Colors.White,
    Enum.Font.GothamBold
)

local ScanShopButton = makeButton(
    ShopStatus,
    "RESCAN",
    UDim2.fromOffset(92, 32),
    UDim2.new(1, -104, 0.5, -16)
)

local ShopList = Instance.new("Frame")
ShopList.Size = UDim2.new(1, -4, 0, 1)
ShopList.AutomaticSize = Enum.AutomaticSize.Y
ShopList.BackgroundTransparency = 1
ShopList.ZIndex = 5
ShopList.Parent = Pages.Shop

local ShopLayout = Instance.new("UIListLayout")
ShopLayout.Padding = UDim.new(0, 7)
ShopLayout.SortOrder = Enum.SortOrder.LayoutOrder
ShopLayout.Parent = ShopList

local function clearChildrenExceptLayouts(parent)
    for _, child in ipairs(parent:GetChildren()) do
        if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
            child:Destroy()
        end
    end
end

local function renderShop()
    clearChildrenExceptLayouts(ShopList)
    ShopCountLabel.Text = "Detected entries: " .. tostring(#State.ShopEntries)

    local shown = 0

    for _, entry in ipairs(State.ShopEntries) do
        shown += 1

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 54)
        row.BackgroundColor3 = CONFIG.Colors.Panel2
        row.BorderSizePixel = 0
        row.Parent = ShopList
        round(row, 11)
        stroke(row, CONFIG.Colors.Border, 0.42, 1)

        makeLabel(
            row,
            entry.Name,
            UDim2.new(1, -135, 0, 20),
            UDim2.fromOffset(12, 5),
            9,
            CONFIG.Colors.White,
            Enum.Font.GothamBold
        )

        makeLabel(
            row,
            entry.Category .. " • " .. formatNumber(entry.Price),
            UDim2.new(1, -135, 0, 18),
            UDim2.fromOffset(12, 26),
            7,
            CONFIG.Colors.Muted,
            Enum.Font.Gotham
        )

        local buy = makeButton(
            row,
            "BUY",
            UDim2.fromOffset(52, 30),
            UDim2.new(1, -64, 0.5, -15)
        )

        buy.Activated:Connect(function()
            fireCommand("BuyItem", {{entry.Category, entry.Index}})
            if entry.Category == "Tools" then
                fireCommand("EquipItem", {{"Tools", entry.Name}})
            end
        end)

        if shown >= 20 then
            break
        end
    end
end

ScanShopButton.Activated:Connect(function()
    scanShop()
    renderShop()
    notify("NEXUS • SHOP RESCANNED")
end)

--// AREAS PAGE
refreshDynamicAreas()
makeLabel(
    Pages.Areas,
    "TELEPORT MENU",
    UDim2.new(1, -4, 0, 24),
    UDim2.fromOffset(2, 0),
    11,
    CONFIG.Colors.Muted,
    Enum.Font.GothamBlack
)

local TeleportInfo = makeLabel(
    Pages.Areas,
    "MoveTo -> SurfaceSpawn -> world spawn -> mine. Extra worlds such as Lava are detected automatically.",
    UDim2.new(1, -4, 0, 32),
    UDim2.fromOffset(2, 0),
    8,
    CONFIG.Colors.Muted,
    Enum.Font.Gotham
)
TeleportInfo.TextWrapped = true

local MaxWorldButton = makeButton(
    Pages.Areas,
    "TELEPORT TO MAX AREA",
    UDim2.new(1, -4, 0, 44),
    UDim2.fromOffset(2, 0)
)
MaxWorldButton.BackgroundColor3 = CONFIG.Colors.Accent
MaxWorldButton.Activated:Connect(function()
    local maxArea = getMaxAvailableArea()
    State.SelectedArea = maxArea
    resetFarmRoute()
    AreaNameLabel.Text = maxArea
    task.spawn(function()
        ensureFarmArea(true, false)
    end)
end)

for _, area in ipairs(Areas) do
    local a = area
    local pointName = a.moveTo or (a.name .. "Spawn")

    local b = makeButton(
        Pages.Areas,
        a.name .. "   •   " .. pointName,
        UDim2.new(1, -4, 0, 42),
        UDim2.fromOffset(2, 0)
    )

    b.TextXAlignment = Enum.TextXAlignment.Left
    b.TextSize = 10
    b.Text = "  " .. b.Text

    b.Activated:Connect(function()
        State.SelectedArea = a.name
        resetFarmRoute()
        AreaNameLabel.Text = a.name
        task.spawn(function()
            ensureFarmArea(true, false)
        end)
    end)
end

--// SETTINGS / STATS
makeLabel(
    Pages.Settings,
    "PLAYER / SYSTEM STATISTICS",
    UDim2.new(1, -4, 0, 24),
    UDim2.fromOffset(2, 0),
    11,
    CONFIG.Colors.Muted,
    Enum.Font.GothamBlack
)

local StatsCard = Instance.new("Frame")
StatsCard.Size = UDim2.new(1, -4, 0, 205)
StatsCard.BackgroundColor3 = CONFIG.Colors.Panel
StatsCard.BorderSizePixel = 0
StatsCard.ZIndex = 5
StatsCard.Parent = Pages.Settings
round(StatsCard, 13)
stroke(StatsCard, CONFIG.Colors.Border, 0.30, 1)

StatsText = makeLabel(
    StatsCard,
    "Loading player statistics...",
    UDim2.new(1, -24, 1, -18),
    UDim2.fromOffset(12, 9),
    8,
    CONFIG.Colors.White,
    Enum.Font.Gotham
)
StatsText.TextYAlignment = Enum.TextYAlignment.Top
StatsText.TextWrapped = false

local AttributesCard = Instance.new("Frame")
AttributesCard.Size = UDim2.new(1, -4, 0, 190)
AttributesCard.BackgroundColor3 = CONFIG.Colors.Panel
AttributesCard.BorderSizePixel = 0
AttributesCard.ZIndex = 5
AttributesCard.Parent = Pages.Settings
round(AttributesCard, 13)
stroke(AttributesCard, CONFIG.Colors.Border, 0.30, 1)

AttributesText = makeLabel(
    AttributesCard,
    "Loading attributes...",
    UDim2.new(1, -24, 1, -18),
    UDim2.fromOffset(12, 9),
    8,
    CONFIG.Colors.White,
    Enum.Font.Gotham
)
AttributesText.TextYAlignment = Enum.TextYAlignment.Top
AttributesText.TextWrapped = false

local InventoryCard = Instance.new("Frame")
InventoryCard.Size = UDim2.new(1, -4, 0, 165)
InventoryCard.BackgroundColor3 = CONFIG.Colors.Panel
InventoryCard.BorderSizePixel = 0
InventoryCard.ZIndex = 5
InventoryCard.Parent = Pages.Settings
round(InventoryCard, 13)
stroke(InventoryCard, CONFIG.Colors.Border, 0.30, 1)

InventoryText = makeLabel(
    InventoryCard,
    "Loading backpack...",
    UDim2.new(1, -24, 1, -18),
    UDim2.fromOffset(12, 9),
    8,
    CONFIG.Colors.White,
    Enum.Font.Gotham
)
InventoryText.TextYAlignment = Enum.TextYAlignment.Top
InventoryText.TextWrapped = false

local RefreshStats = makeButton(
    Pages.Settings,
    "REFRESH STATISTICS",
    UDim2.new(1, -4, 0, 44),
    UDim2.fromOffset(2, 0)
)
RefreshStats.BackgroundColor3 = CONFIG.Colors.Panel3

local ResetButtons = makeButton(
    Pages.Settings,
    "STOP ALL AUTOMATION",
    UDim2.new(1, -4, 0, 44),
    UDim2.fromOffset(2, 0)
)
ResetButtons.BackgroundColor3 = Color3.fromRGB(81, 28, 38)

--// BOTTOM NAV
local Nav = Instance.new("Frame")
Nav.Size = UDim2.new(1, -18, 0, 54)
Nav.Position = UDim2.new(0, 9, 1, -63)
Nav.BackgroundColor3 = CONFIG.Colors.Panel
Nav.BorderSizePixel = 0
Nav.ZIndex = 8
Nav.Parent = Main
round(Nav, 13)
stroke(Nav, CONFIG.Colors.Border, 0.22, 1)

local navNames = {"Mining", "Rebirth", "Shop", "Areas", "Settings"}
local NavButtons = {}

for index, tabName in ipairs(navNames) do
    local button = makeButton(
        Nav,
        tabName,
        UDim2.new(0.2, -3, 1, -10),
        UDim2.new((index - 1) * 0.2, 2, 0, 5)
    )
    button.TextSize = 8
    button.ZIndex = 9
    NavButtons[tabName] = button
end

local function setTab(tabName)
    State.ActiveTab = tabName

    for name, page in pairs(Pages) do
        local active = name == tabName
        page.Visible = active
        if active then
            page.CanvasPosition = Vector2.zero
        end
    end

    for name, button in pairs(NavButtons) do
        local active = name == tabName
        button.BackgroundColor3 = active and CONFIG.Colors.Accent or CONFIG.Colors.Panel2
        button.TextColor3 = active and CONFIG.Colors.White or CONFIG.Colors.Muted
    end
end

for tabName, button in pairs(NavButtons) do
    button.Activated:Connect(function()
        setTab(tabName)
    end)
end

--// OPEN BUTTON
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "NexusOpen"
OpenButton.Size = UDim2.fromOffset(58, 58)
OpenButton.AnchorPoint = Vector2.new(1, 1)
OpenButton.Position = UDim2.new(1, -18, 1, -18)
OpenButton.BackgroundColor3 = CONFIG.Colors.Accent
OpenButton.BorderSizePixel = 0
OpenButton.Text = "N"
OpenButton.TextColor3 = CONFIG.Colors.White
OpenButton.Font = Enum.Font.GothamBlack
OpenButton.TextSize = 26
OpenButton.AutoButtonColor = false
OpenButton.ZIndex = 20
OpenButton.Visible = false
OpenButton.Parent = ScreenGui
round(OpenButton, 16)
stroke(OpenButton, CONFIG.Colors.Accent2, 0.0, 1)
gradient(OpenButton, CONFIG.Colors.Accent2, CONFIG.Colors.Accent, 135)

--// TOAST
Toast = Instance.new("TextLabel")
Toast.Name = "Toast"
Toast.AnchorPoint = Vector2.new(0.5, 1)
Toast.Position = UDim2.new(0.5, 0, 1, -78)
Toast.Size = UDim2.new(0.82, 0, 0, 34)
Toast.BackgroundColor3 = CONFIG.Colors.Panel
Toast.BackgroundTransparency = 1
Toast.BorderSizePixel = 0
Toast.TextColor3 = CONFIG.Colors.White
Toast.Font = Enum.Font.GothamBold
Toast.TextSize = 9
Toast.Text = ""
Toast.Visible = false
Toast.ZIndex = 50
Toast.Parent = ScreenGui
round(Toast, 10)
stroke(Toast, CONFIG.Colors.Border, 0.25, 1)

--// OPEN / CLOSE
local menuOpen = true
local animating = false
local NORMAL_MAIN_SIZE = UDim2.new(0.94, 0, 0.82, 0)

local function setMenuVisible(visible)
    if animating or visible == menuOpen then
        return
    end

    animating = true
    menuOpen = visible

    if visible then
        OpenButton.Visible = false
        Backdrop.Visible = true
        Main.Visible = true

        local oldSize = NORMAL_MAIN_SIZE
        Main.Size = UDim2.new(oldSize.X.Scale, oldSize.X.Offset, 0, 120)

        local tween = TweenService:Create(
            Main,
            TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {Size = oldSize}
        )
        tween:Play()
        tween.Completed:Wait()

        Backdrop.BackgroundTransparency = 0.40
        animating = false
    else
        Backdrop.BackgroundTransparency = 1

        local closeTween = TweenService:Create(
            Main,
            TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            {Size = UDim2.new(NORMAL_MAIN_SIZE.X.Scale, NORMAL_MAIN_SIZE.X.Offset, 0, 120)}
        )
        closeTween:Play()
        closeTween.Completed:Wait()

        Main.Visible = false
        Backdrop.Visible = false
        OpenButton.Visible = true
        Main.Size = NORMAL_MAIN_SIZE
        animating = false
    end
end

CloseButton.Activated:Connect(function()
    setMenuVisible(false)
end)

OpenButton.Activated:Connect(function()
    setMenuVisible(true)
end)

Backdrop.Activated:Connect(function()
    if menuOpen then
        setMenuVisible(false)
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.RightShift then
        setMenuVisible(not menuOpen)
    end
end)

--// STATISTICS
local function getMembershipName()
    local ok, membership = pcall(function()
        return LocalPlayer.MembershipType.Name
    end)
    return ok and tostring(membership) or "Unknown"
end

local function buildLeaderstatsText()
    local lines = {"LEADERSTATS"}
    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")

    if leaderstats then
        local children = leaderstats:GetChildren()
        table.sort(children, function(a, b)
            return a.Name < b.Name
        end)

        for _, value in ipairs(children) do
            if value:IsA("ValueBase") then
                table.insert(lines, string.format("• %s: %s", value.Name, tostring(value.Value)))
            end
        end
    else
        table.insert(lines, "• leaderstats: not found")
    end

    return table.concat(lines, "\n")
end

local function buildStatsText()
    local root = getRoot(LocalPlayer)
    local hum = getHumanoid(LocalPlayer)
    local tool = getEquippedTool()

    local position = "N/A"
    if root then
        local p = root.Position
        position = string.format(
            "%d, %d, %d",
            math.floor(p.X + 0.5),
            math.floor(p.Y + 0.5),
            math.floor(p.Z + 0.5)
        )
    end

    local characterName = LocalPlayer.Character and LocalPlayer.Character:GetFullName() or "N/A"

    local lines = {
        "PLAYER",
        "• Display: " .. LocalPlayer.DisplayName,
        "• Username: @" .. LocalPlayer.Name,
        "• UserId: " .. tostring(LocalPlayer.UserId),
        "• Account age: " .. tostring(LocalPlayer.AccountAge) .. " days",
        "• Membership: " .. getMembershipName(),
        "• PlaceId: " .. tostring(game.PlaceId),
        "• JobId: " .. tostring(game.JobId),
        "",
        "CHARACTER",
        "• Character: " .. characterName,
        "• Health: " .. (hum and (string.format("%.0f / %.0f", hum.Health, hum.MaxHealth)) or "N/A"),
        "• WalkSpeed: " .. (hum and string.format("%.1f", hum.WalkSpeed) or "N/A"),
        "• JumpPower: " .. (hum and string.format("%.1f", hum.JumpPower) or "N/A"),
        "• Position: " .. position,
        "• Equipped: " .. (tool and tool.Name or "None"),
        "",
        "LIVE",
        "• FPS: " .. tostring(State.FPS),
        "• Ping: " .. tostring(State.Ping),
        "• Remote: " .. (State.Remote and State.Remote.Name or "Not resolved"),
        "• Selected area: " .. State.SelectedArea,
        "• Auto Farm: " .. tostring(State.AutoFarm),
        "• Farm route: " .. tostring(State.FarmRouteComplete),
        "• Status: " .. State.Status .. " | Phase: " .. tostring(rebirthPhaseText),
    }

    return table.concat(lines, "\n")
end

local function buildAttributesText()
    local lines = {"PLAYER ATTRIBUTES"}
    local attrs = LocalPlayer:GetAttributes()
    local keys = {}

    for key in pairs(attrs) do
        table.insert(keys, key)
    end

    table.sort(keys)

    if #keys == 0 then
        table.insert(lines, "• No attributes")
    else
        for _, key in ipairs(keys) do
            table.insert(lines, "• " .. key .. ": " .. tostring(attrs[key]))
        end
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = buildLeaderstatsText()

    return table.concat(lines, "\n")
end

local function buildInventoryText()
    local lines = {"BACKPACK"}
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local tools = {}

    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            table.insert(tools, item.Name)
        end
    end

    local equipped = getEquippedTool()
    if equipped then
        table.insert(tools, equipped.Name .. " [EQUIPPED]")
    end

    table.insert(lines, "• Items: " .. tostring(#tools))

    if #tools == 0 then
        table.insert(lines, "• Empty")
    else
        for _, itemName in ipairs(tools) do
            table.insert(lines, "• " .. itemName)
        end
    end

    return table.concat(lines, "\n")
end

local function refreshStatistics()
    if StatsText then
        StatsText.Text = buildStatsText()
    end

    if AttributesText then
        AttributesText.Text = buildAttributesText()
    end

    if InventoryText then
        InventoryText.Text = buildInventoryText()
    end

    if InventoryStatusLabel then
        local current, maximum = getInventoryAmount()
        InventoryStatusLabel.Text = "Inventory: " .. formatNumber(current) .. " / " .. formatNumber(maximum)
    end

    if RebirthStatsLabel then
        local gained = 0
        if State.RebirthBaseBlocks then
            gained = math.max(0, getBlocksMined() - State.RebirthBaseBlocks)
        end

        RebirthStatsLabel.Text =
            "COINS: " .. formatNumber(getCoins()) ..
            "\nBLOCKS MINED: " .. formatNumber(getBlocksMined()) ..
            "\nREBIRTHS: " .. formatNumber(getRebirths()) ..
            "\nSESSION BLOCKS: " .. formatNumber(gained) ..
            "\nTARGET: wallet-based" ..
            "\nCOST: " .. formatNumber(getRebirthCost())
    end
end

RefreshStats.Activated:Connect(function()
    refreshStatistics()
    notify("NEXUS • STATS UPDATED")
end)

ResetButtons.Activated:Connect(function()
    State.AutoMine = false
    State.AutoFarm = false
    State.FastMine = false
    State.AutoSell = false
    State.AutoRebirth = false
    State.RebirthOnly = false
    State.AutoBackpack = false
    State.AutoTools = false
    State.Sprint = false

    resetFarmRoute()

    MiningToggle.Set(false)
    FastMiningToggle.Set(false)
    SellToggle.Set(false)
    BackpackToggle.Set(false)
    ToolsToggle.Set(false)
    SprintToggle.Set(false)
    RebirthToggle.Set(false)
    RebirthOnlyToggle.Set(false)

    notify("NEXUS • ALL AUTOMATION STOPPED")
end)

--// FPS
 do
    local frameCount = 0
    local elapsed = 0

    RunService.RenderStepped:Connect(function(dt)
        frameCount += 1
        elapsed += dt

        if elapsed >= 0.5 then
            State.FPS = math.floor(frameCount / elapsed + 0.5)
            frameCount = 0
            elapsed = 0
        end
    end)
end

--// PING / STATUS
 task.spawn(function()
    while ScreenGui.Parent do
        local pingText = "--"

        pcall(function()
            local network = StatsService:FindFirstChild("Network")
            local serverStats = network and network:FindFirstChild("ServerStatsItem")
            local dataPing = serverStats and serverStats:FindFirstChild("Data Ping")

            if dataPing then
                pingText = dataPing:GetValueString()
            end
        end)

        State.Ping = tostring(pingText)

        if menuOpen and StatusLabel then
            StatusLabel.Text = State.Status
        end

        task.wait(0.75)
    end
end)

--// AUTO FARM / MINING LOOP
 task.spawn(function()
    while ScreenGui.Parent do
        if (State.AutoMine or State.AutoFarm or State.AutoRebirth)
            and not State.RebirthOnly then

            -- The route is only initialized once for an area.
            -- No periodic CFrame corrections are performed.
            if State.AutoFarm
                and not State.FarmBusy
                and not State.FarmRouteComplete
                and not State.FarmRouteTried then

                task.spawn(function()
                    ensureFarmArea(false, true)
                end)
            end

            local interval = State.FastMine and CONFIG.Mining.FastInterval or CONFIG.Mining.NormalInterval

            if os.clock() - State.LastMine >= interval then
                doMine()
            end
        end

        task.wait(0.035)
    end
end)

--// SELL / AUTO REBIRTH LOOP
 task.spawn(function()
    while ScreenGui.Parent do
        if not State.CycleBusy then
            runAutomationCycle()
        end
        task.wait(CONFIG.Mining.SellInterval)
    end
end)

--// REBIRTH ONLY
 task.spawn(function()
    while ScreenGui.Parent do
        if State.RebirthOnly and not State.CycleBusy then
            if os.clock() - State.LastRebirth >= CONFIG.Mining.RebirthInterval then
                State.LastRebirth = os.clock()
                doRebirth()
            end
        end

        task.wait(0.15)
    end
end)

--// SHOP LOOP
 task.spawn(function()
    while ScreenGui.Parent do
        if (State.AutoBackpack or State.AutoTools)
            and os.clock() - State.LastShop >= CONFIG.Mining.ShopInterval then

            State.LastShop = os.clock()

            if #State.ShopEntries == 0 then
                scanShop()
            end

            if State.AutoBackpack then
                buyAndEquipBest("Backpack")
            end

            if State.AutoTools then
                buyAndEquipBest("Tools")
            end
        end

        task.wait(0.5)
    end
end)

--// SPRINT
RunService.Heartbeat:Connect(function()
    local hum = getHumanoid(LocalPlayer)

    if State.Sprint and hum then
        if hum.WalkSpeed ~= CONFIG.Movement.SprintSpeed then
            hum.WalkSpeed = CONFIG.Movement.SprintSpeed
        end
    end
end)

--// STATS LOOP
 task.spawn(function()
    while ScreenGui.Parent do
        if AreaNameLabel then
            AreaNameLabel.Text = State.SelectedArea
        end

        refreshStatistics()
        task.wait(1)
    end
end)

--// CHARACTER RESPAWN RECOVERY
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)

    resetFarmRoute()
    initializeRebirthBaseline()

    if State.Sprint then
        local hum = getHumanoid(LocalPlayer)
        if hum then
            hum.WalkSpeed = CONFIG.Movement.SprintSpeed
        end
    end

    if State.AutoFarm or State.AutoMine then
        task.spawn(function()
            ensureFarmArea(true, true)
        end)
    end

    if State.AutoRebirth then
        task.spawn(function()
            StartAutoRebirth()
        end)
    end
end)

--// START
initializeRebirthBaseline()
State.SelectedArea = State.SelectedArea == "Forest" and "MagicForest" or State.SelectedArea
initializeRebirthBaseline()
scanShop()
refreshStatistics()
renderShop()
setTab("Mining")
Main.Visible = true
Backdrop.Visible = true
OpenButton.Visible = false
setStatus("READY", true)
