--// ============================================================
--// NEXUS GAME SCANNER v7.0
--// AI-oriented client-visible Roblox game analyzer
--//
--// What changed from v6:
--//   • Does NOT traverse CoreGui / Roblox system internals
--//   • Scans only game-relevant client-visible containers
--//   • Focused structure tree instead of a 100k+ object dump
--//   • Remote map with inferred system / action / confidence
--//   • Knit framework detection
--//   • Separates FACT / INFERENCE / UNKNOWN
--//   • AI HANDOFF report optimized for pasting into ChatGPT
--//   • FULL REPORT still available for detailed inspection
--//
--// Safety:
--//   Passive scanner only.
--//   Does NOT invoke remotes, hook __namecall, dump server-only
--//   source, bypass replication, or modify game state.
--//
--// Compatibility:
--//   Standard Roblox APIs where possible.
--//   Clipboard uses setclipboard/toclipboard when available.
--// ============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")
local Teams = game:GetService("Teams")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--// ============================================================
--// CONFIG
--// ============================================================

local CONFIG = {
    WindowWidth = 400,
    WindowHeight = 300,

    MaxString = 500,
    MaxRemoteEntries = 1000,
    MaxModuleEntries = 900,
    MaxScriptEntries = 700,
    MaxPromptEntries = 500,
    MaxValueEntries = 800,
    MaxAttributeEntries = 900,
    MaxTagEntries = 500,
    MaxImportantEntries = 1600,
    MaxTreeLines = 2600,
    MaxTreeDepth = 14,
    MaxEvidencePerSystem = 8,
    YieldEvery = 100,

    -- Only these roots are considered relevant by default.
    -- CoreGui and Roblox system trees are intentionally excluded.
    RootNames = {
        "ReplicatedStorage",
        "ReplicatedFirst",
        "Workspace",
        "Lighting",
        "StarterGui",
        "StarterPlayer",
        "Teams",
        "SoundService",
        "PlayerGui",
        "PlayerScripts"
    }
}

--// ============================================================
--// UTIL
--// ============================================================

local function safe(fn, fallback)
    local ok, result = pcall(fn)
    if ok then
        return result
    end
    return fallback
end

local function safeString(value)
    local s = tostring(value)
    s = s:gsub("\r", "")
    s = s:gsub("\n", "\\n")
    if #s > CONFIG.MaxString then
        s = s:sub(1, CONFIG.MaxString) .. "...[TRUNCATED]"
    end
    return s
end

local function getClass(obj)
    return safe(function()
        return obj.ClassName
    end, "Unknown")
end

local function getPath(obj)
    return safe(function()
        return obj:GetFullName()
    end, tostring(obj.Name))
end

local function getChildren(obj)
    return safe(function()
        return obj:GetChildren()
    end, {})
end

local function getDescendants(obj)
    return safe(function()
        return obj:GetDescendants()
    end, {})
end

local function formatNumber(n)
    local s = tostring(math.floor(tonumber(n) or 0))
    local out = s
    while true do
        local changed
        out, changed = out:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        if not changed or changed == 0 then
            break
        end
    end
    return out
end

local function sortedKeys(tbl)
    local out = {}
    for key in pairs(tbl) do
        out[#out + 1] = key
    end

    table.sort(out, function(a, b)
        return tostring(a):lower() < tostring(b):lower()
    end)

    return out
end

local function lower(text)
    return string.lower(tostring(text or ""))
end

local function containsAny(text, tokens)
    text = lower(text)

    for _, token in ipairs(tokens) do
        if string.find(text, token, 1, true) then
            return true
        end
    end

    return false
end

local function countTokens(text, tokens)
    text = lower(text)
    local score = 0

    for _, token in ipairs(tokens) do
        if string.find(text, token, 1, true) then
            score += 1
        end
    end

    return score
end

local function copyText(text)
    if type(setclipboard) == "function" then
        local ok = pcall(setclipboard, text)
        if ok then
            return true, "Copied with setclipboard."
        end
    end

    if type(toclipboard) == "function" then
        local ok = pcall(toclipboard, text)
        if ok then
            return true, "Copied with toclipboard."
        end
    end

    return false, "Clipboard API is unavailable."
end

local function sortedByPath(list)
    table.sort(list, function(a, b)
        return lower(a.path or a.name) < lower(b.path or b.name)
    end)
end

local function addUnique(list, seen, key, item, maxCount)
    if seen[key] then
        return false
    end

    if #list >= maxCount then
        return false
    end

    seen[key] = true
    list[#list + 1] = item
    return true
end

--// ============================================================
--// INFERENCE TABLES
--// ============================================================

local SYSTEM_RULES = {
    Economy = {
        "money", "cash", "coins", "coin", "gold", "currency", "credits",
        "balance", "wallet", "earn", "income", "sell", "buy", "price",
        "cost", "reward", "value", "salary", "payout"
    },

    Inventory = {
        "inventory", "backpack", "hotbar", "item", "items", "storage",
        "slot", "loadout", "equipment", "equip", "weapon"
    },

    Shop = {
        "shop", "store", "merchant", "purchase", "buy", "sell", "catalog",
        "product", "crate", "case", "bundle", "vendor"
    },

    Progression = {
        "level", "xp", "experience", "rank", "rebirth", "prestige",
        "upgrade", "skill", "talent", "mastery", "ascend"
    },

    Quests = {
        "quest", "mission", "objective", "task", "challenge", "daily",
        "weekly", "achievement"
    },

    Combat = {
        "combat", "damage", "attack", "hit", "weapon", "sword", "gun",
        "shoot", "bullet", "aim", "enemy", "health", "stun", "kill"
    },

    Rounds = {
        "round", "match", "arena", "lobby", "intermission", "spectate",
        "winner", "timer", "countdown", "vote", "mapvote"
    },

    Automation = {
        "autofarm", "farm", "collector", "collect", "loop", "cycle",
        "drop", "pickup", "harvest", "mining", "mine", "lemon"
    },

    Vehicles = {
        "vehicle", "car", "truck", "boat", "plane", "bike", "drive",
        "engine", "fuel", "speed"
    },

    Tycoon = {
        "tycoon", "dropper", "conveyor", "collector", "base", "rebirth",
        "button", "plot"
    },

    Pets = {
        "pet", "pets", "egg", "hatch", "hatching", "rarity", "equip"
    },

    Trading = {
        "trade", "trading", "offer", "accept", "exchange", "market"
    },

    Social = {
        "party", "friend", "team", "clan", "guild", "group", "chat"
    },

    Tutorial = {
        "tutorial", "onboarding", "guide", "intro", "howto"
    },

    Settings = {
        "settings", "setting", "config", "configuration", "options"
    },

    Data = {
        "data", "profile", "profiles", "save", "load", "datastore",
        "leaderstats", "stats", "profiledata"
    },

    Rewards = {
        "reward", "gift", "daily", "claim", "free", "bonus", "code"
    },

    Leaderboard = {
        "leaderboard", "leaderstats", "top", "rank", "wins"
    }
}

local ACTION_RULES = {
    Claim = {"claim", "collect", "pickup", "redeem", "receive"},
    Buy = {"buy", "purchase", "shop", "checkout"},
    Sell = {"sell", "cashout"},
    Equip = {"equip", "unequip", "loadout"},
    Use = {"use", "activate", "consume"},
    Upgrade = {"upgrade", "improve", "levelup"},
    Rebirth = {"rebirth", "prestige", "ascend"},
    Start = {"start", "begin", "launch", "play"},
    Stop = {"stop", "cancel", "end"},
    Join = {"join", "enter", "queue"},
    Leave = {"leave", "exit"},
    Vote = {"vote", "select", "choose"},
    Attack = {"attack", "hit", "damage", "shoot"},
    Trade = {"trade", "offer", "accept", "exchange"},
    Open = {"open", "unlock"},
    Close = {"close"},
    Spawn = {"spawn", "summon"},
    Update = {"update", "set", "change", "toggle"},
    Request = {"request", "get", "fetch", "load"},
    Teleport = {"teleport", "tp"},
    Hatch = {"hatch", "egg"},
    Craft = {"craft", "forge", "combine"}
}

local IGNORE_NAME_TOKENS = {
    "animate", "health", "humanoid", "motion", "emote",
    "touchinterest", "camera", "chat", "bubblechat",
    "controlmodule", "playerlist", "topbar", "core", "roblox"
}

local IMPORTANT_CLASSES = {
    RemoteEvent = true,
    RemoteFunction = true,
    BindableEvent = true,
    BindableFunction = true,
    ModuleScript = true,
    LocalScript = true,
    Script = true,
    Tool = true,
    ProximityPrompt = true,
    ClickDetector = true,
    StringValue = true,
    IntValue = true,
    NumberValue = true,
    BoolValue = true,
    ObjectValue = true,
    Vector3Value = true,
    CFrameValue = true,
    Color3Value = true,
    BrickColorValue = true,
    Folder = true,
    Model = true
}

local VALUE_CLASSES = {
    StringValue = true,
    IntValue = true,
    NumberValue = true,
    BoolValue = true,
    ObjectValue = true,
    Vector3Value = true,
    CFrameValue = true,
    Color3Value = true,
    BrickColorValue = true
}

--// ============================================================
--// STATE
--// ============================================================

local State = {
    running = false,
    cancelled = false,
    startedAt = 0,
    finishedAt = 0,
    lastFullReport = "",
    lastAIReport = "",

    objectCount = 0,
    relevantCount = 0,
    rootsScanned = 0,

    byClass = {},
    byRoot = {},

    remotes = {},
    remoteSeen = {},

    bindables = {},
    bindableSeen = {},

    modules = {},
    moduleSeen = {},

    scripts = {},
    scriptSeen = {},

    tools = {},
    toolSeen = {},

    prompts = {},
    promptSeen = {},

    clickDetectors = {},
    clickSeen = {},

    values = {},
    valueSeen = {},

    attributes = {},
    attributeSeen = {},

    tags = {},
    tagSeen = {},

    important = {},
    importantSeen = {},

    systems = {},
    systemEvidence = {},

    knit = {
        detected = false,
        frameworkPaths = {},
        serviceLike = {},
        controllerLike = {}
    },

    tree = {},
    treeLines = 0,

    warnings = {}
}

local GameProfile = {}

--// ============================================================
--// GUI
--// ============================================================

local function destroyOldGui()
    pcall(function()
        local old = CoreGui:FindFirstChild("NEXUS_GameScanner_v7")
        if old then
            old:Destroy()
        end
    end)

    pcall(function()
        local playerGui = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if playerGui then
            local old = playerGui:FindFirstChild("NEXUS_GameScanner_v7")
            if old then
                old:Destroy()
            end
        end
    end)
end

destroyOldGui()

local Gui = Instance.new("ScreenGui")
Gui.Name = "NEXUS_GameScanner_v7"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset = true

local attached = pcall(function()
    Gui.Parent = CoreGui
end)

if not attached or not Gui.Parent then
    Gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(CONFIG.WindowWidth, CONFIG.WindowHeight)
Main.Position = UDim2.new(0.5, -CONFIG.WindowWidth / 2, 0.5, -CONFIG.WindowHeight / 2)
Main.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(72, 78, 100)
MainStroke.Transparency = 0.25
MainStroke.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundColor3 = Color3.fromRGB(17, 18, 25)
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 14)
HeaderCorner.Parent = Header

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(14, 5)
Title.Size = UDim2.new(1, -62, 0, 24)
Title.Font = Enum.Font.GothamBold
Title.Text = "NEXUS GAME SCANNER"
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.TextColor3 = Color3.fromRGB(243, 245, 255)
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.fromOffset(15, 29)
Subtitle.Size = UDim2.new(1, -65, 0, 16)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "v7.0  •  AI Game Map"
Subtitle.TextSize = 9
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.TextColor3 = Color3.fromRGB(146, 151, 172)
Subtitle.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(32, 32)
CloseButton.Position = UDim2.new(1, -40, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(34, 35, 45)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "×"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 19
CloseButton.TextColor3 = Color3.fromRGB(235, 235, 245)
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseButton

local Status = Instance.new("TextLabel")
Status.BackgroundTransparency = 1
Status.Position = UDim2.fromOffset(14, 60)
Status.Size = UDim2.new(1, -28, 0, 20)
Status.Font = Enum.Font.GothamMedium
Status.Text = "Ready"
Status.TextSize = 11
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.TextColor3 = Color3.fromRGB(205, 210, 225)
Status.Parent = Main

local ProgressBack = Instance.new("Frame")
ProgressBack.Position = UDim2.fromOffset(14, 85)
ProgressBack.Size = UDim2.new(1, -28, 0, 6)
ProgressBack.BackgroundColor3 = Color3.fromRGB(31, 32, 42)
ProgressBack.BorderSizePixel = 0
ProgressBack.Parent = Main

local PBcorner = Instance.new("UICorner")
PBcorner.CornerRadius = UDim.new(0, 5)
PBcorner.Parent = ProgressBack

local Progress = Instance.new("Frame")
Progress.Size = UDim2.new(0, 0, 1, 0)
Progress.BackgroundColor3 = Color3.fromRGB(95, 125, 255)
Progress.BorderSizePixel = 0
Progress.Parent = ProgressBack

local PCorner = Instance.new("UICorner")
PCorner.CornerRadius = UDim.new(0, 5)
PCorner.Parent = Progress

local StatsLabel = Instance.new("TextLabel")
StatsLabel.BackgroundTransparency = 1
StatsLabel.Position = UDim2.fromOffset(14, 96)
StatsLabel.Size = UDim2.new(1, -28, 0, 18)
StatsLabel.Font = Enum.Font.Gotham
StatsLabel.Text = "Relevant: 0 • Remotes: 0 • Modules: 0 • Scripts: 0"
StatsLabel.TextSize = 9
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextColor3 = Color3.fromRGB(135, 140, 160)
StatsLabel.Parent = Main

local ButtonBar = Instance.new("Frame")
ButtonBar.BackgroundTransparency = 1
ButtonBar.Position = UDim2.fromOffset(14, 119)
ButtonBar.Size = UDim2.new(1, -28, 0, 38)
ButtonBar.Parent = Main

local function makeButton(text, x, width)
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(width, 38)
    button.Position = UDim2.fromOffset(x, 0)
    button.BackgroundColor3 = Color3.fromRGB(28, 30, 41)
    button.BorderSizePixel = 0
    button.Text = text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 9
    button.TextColor3 = Color3.fromRGB(230, 233, 245)
    button.AutoButtonColor = true
    button.Parent = ButtonBar

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button

    return button
end

local ScanButton = makeButton("SCAN", 0, 66)
local AICopyButton = makeButton("AI COPY", 71, 80)
local FullCopyButton = makeButton("FULL COPY", 156, 82)
local ClearButton = makeButton("CLEAR", 243, 65)
local MinButton = makeButton("MIN", 313, 55)

local Output = Instance.new("ScrollingFrame")
Output.Position = UDim2.fromOffset(14, 166)
Output.Size = UDim2.new(1, -28, 1, -180)
Output.BackgroundColor3 = Color3.fromRGB(6, 7, 11)
Output.BorderSizePixel = 0
Output.ScrollBarThickness = 5
Output.ScrollBarImageColor3 = Color3.fromRGB(82, 87, 110)
Output.CanvasSize = UDim2.new(0, 0, 0, 0)
Output.Parent = Main

local OutputCorner = Instance.new("UICorner")
OutputCorner.CornerRadius = UDim.new(0, 10)
OutputCorner.Parent = Output

local OutText = Instance.new("TextLabel")
OutText.BackgroundTransparency = 1
OutText.Position = UDim2.fromOffset(9, 9)
OutText.Size = UDim2.new(1, -18, 0, 0)
OutText.AutomaticSize = Enum.AutomaticSize.Y
OutText.Font = Enum.Font.Code
OutText.Text = ""
OutText.TextSize = 9
OutText.TextXAlignment = Enum.TextXAlignment.Left
OutText.TextYAlignment = Enum.TextYAlignment.Top
OutText.TextColor3 = Color3.fromRGB(185, 190, 208)
OutText.RichText = false
OutText.Parent = Output

local OpenButton = nil

--// Drag
do
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local dragInput = nil

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPos = Main.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function setStatus(text)
    Status.Text = text
end

local function setProgress(value)
    value = math.clamp(value or 0, 0, 1)
    Progress.Size = UDim2.new(value, 0, 1, 0)
end

local function setOutput(text)
    OutText.Text = text

    task.defer(function()
        local h = OutText.AbsoluteSize.Y
        Output.CanvasSize = UDim2.new(0, 0, 0, h + 24)
        Output.CanvasPosition = Vector2.new(0, 0)
    end)
end

local function getRemoteCounts()
    local events = 0
    local functions = 0

    for _, remote in ipairs(State.remotes) do
        if remote.class == "RemoteEvent" then
            events += 1
        elseif remote.class == "RemoteFunction" then
            functions += 1
        end
    end

    return events, functions
end

local function updateStats()
    local events, functions = getRemoteCounts()

    StatsLabel.Text = string.format(
        "Relevant: %s • Remotes: %s • Modules: %s • Scripts: %s",
        formatNumber(State.relevantCount),
        formatNumber(events + functions),
        formatNumber(#State.modules),
        formatNumber(#State.scripts)
    )
end

--// ============================================================
--// GAME PROFILE
--// ============================================================

local function makeGameProfile()
    local camera = safe(function()
        return Workspace.CurrentCamera
    end, nil)

    return {
        name = safe(function() return game.Name end, "Unknown"),
        placeId = safe(function() return game.PlaceId end, 0),
        gameId = safe(function() return game.GameId end, 0),
        jobId = safe(function() return game.JobId end, ""),
        creatorId = safe(function() return game.CreatorId end, 0),
        creatorType = safe(function() return tostring(game.CreatorType) end, "Unknown"),
        loaded = safe(function() return game:IsLoaded() end, false),
        gravity = safe(function() return Workspace.Gravity end, 0),
        streamingEnabled = safe(function() return Workspace.StreamingEnabled end, false),
        maxPlayers = safe(function() return Players.MaxPlayers end, 0),
        playerCount = #Players:GetPlayers(),
        cameraType = camera and safe(function()
            return tostring(camera.CameraType)
        end, "Unknown") or "None",
        generated = os.date("%Y-%m-%d %H:%M:%S")
    }
end

--// ============================================================
--// SYSTEM / ACTION INFERENCE
--// ============================================================

local function inferSystem(text)
    local bestName = "Unknown"
    local bestScore = 0

    for systemName, tokens in pairs(SYSTEM_RULES) do
        local score = countTokens(text, tokens)

        if score > bestScore then
            bestScore = score
            bestName = systemName
        end
    end

    if bestScore == 0 then
        return "Unknown", 0, "UNKNOWN"
    end

    local confidence = "MEDIUM"

    if bestScore >= 3 then
        confidence = "HIGH"
    elseif bestScore == 1 then
        confidence = "LOW"
    end

    return bestName, bestScore, confidence
end

local function inferAction(text)
    local bestName = "Unknown"
    local bestScore = 0

    for actionName, tokens in pairs(ACTION_RULES) do
        local score = countTokens(text, tokens)

        if score > bestScore then
            bestScore = score
            bestName = actionName
        end
    end

    if bestScore == 0 then
        return "Unknown", 0, "UNKNOWN"
    end

    local confidence = "MEDIUM"

    if bestScore >= 2 then
        confidence = "HIGH"
    elseif bestScore == 1 then
        confidence = "LOW"
    end

    return bestName, bestScore, confidence
end

local function classifyRemote(obj)
    local name = obj.Name
    local path = getPath(obj)
    local combined = lower(name .. " " .. path)

    local system, systemScore, systemConfidence = inferSystem(combined)
    local action, actionScore, actionConfidence = inferAction(combined)

    local confidence = "LOW"

    if systemConfidence == "HIGH" and actionConfidence == "HIGH" then
        confidence = "HIGH"
    elseif systemConfidence ~= "UNKNOWN" or actionConfidence ~= "UNKNOWN" then
        confidence = "MEDIUM"
    end

    local purpose = "Unknown client-visible remote"

    if system ~= "Unknown" and action ~= "Unknown" then
        purpose = system .. " / " .. action
    elseif system ~= "Unknown" then
        purpose = system
    elseif action ~= "Unknown" then
        purpose = action
    end

    return {
        class = getClass(obj),
        name = name,
        path = path,
        system = system,
        systemScore = systemScore,
        action = action,
        actionScore = actionScore,
        confidence = confidence,
        purpose = purpose
    }
end

local function addSystemEvidence(systemName, evidence)
    if systemName == "Unknown" then
        return
    end

    State.systems[systemName] = (State.systems[systemName] or 0) + 1
    State.systemEvidence[systemName] = State.systemEvidence[systemName] or {}

    if #State.systemEvidence[systemName] < CONFIG.MaxEvidencePerSystem then
        State.systemEvidence[systemName][#State.systemEvidence[systemName] + 1] = evidence
    end
end

--// ============================================================
--// KNIT DETECTION
--// ============================================================

local function detectKnit(obj)
    local path = lower(getPath(obj))
    local name = lower(obj.Name)

    if string.find(path, "knit", 1, true)
        or string.find(path, "sleitnick_knit", 1, true)
        or string.find(name, "knit", 1, true) then

        State.knit.detected = true

        local fullPath = getPath(obj)

        if #State.knit.frameworkPaths < 80 then
            local duplicate = false

            for _, existing in ipairs(State.knit.frameworkPaths) do
                if existing == fullPath then
                    duplicate = true
                    break
                end
            end

            if not duplicate then
                State.knit.frameworkPaths[#State.knit.frameworkPaths + 1] = fullPath
            end
        end
    end

    if string.find(path, ".services.", 1, true)
        or string.find(path, "/services/", 1, true) then

        local serviceName = obj.Name

        if not State.knit.serviceLike[serviceName] then
            State.knit.serviceLike[serviceName] = getPath(obj)
        end
    end

    if string.find(path, ".controllers.", 1, true)
        or string.find(path, "/controllers/", 1, true) then

        local controllerName = obj.Name

        if not State.knit.controllerLike[controllerName] then
            State.knit.controllerLike[controllerName] = getPath(obj)
        end
    end
end

--// ============================================================
--// ATTRIBUTES / TAGS / VALUES
--// ============================================================

local function captureAttributes(obj, path)
    local attrs = safe(function()
        return obj:GetAttributes()
    end, {})

    local keys = sortedKeys(attrs)

    for _, key in ipairs(keys) do
        if #State.attributes >= CONFIG.MaxAttributeEntries then
            return
        end

        local value = attrs[key]
        local uniqueKey = path .. "::" .. tostring(key)

        if not State.attributeSeen[uniqueKey] then
            State.attributeSeen[uniqueKey] = true

            State.attributes[#State.attributes + 1] = {
                path = path,
                name = tostring(key),
                type = typeof(value),
                value = safeString(value)
            }
        end
    end
end

local function captureTags(obj, path)
    local tags = safe(function()
        return CollectionService:GetTags(obj)
    end, {})

    for _, tag in ipairs(tags) do
        if #State.tags >= CONFIG.MaxTagEntries then
            return
        end

        local uniqueKey = path .. "::" .. tostring(tag)

        if not State.tagSeen[uniqueKey] then
            State.tagSeen[uniqueKey] = true
            State.tags[#State.tags + 1] = {
                path = path,
                tag = tostring(tag)
            }
        end
    end
end

local function captureValue(obj, path)
    local class = getClass(obj)

    if not VALUE_CLASSES[class] then
        return
    end

    if #State.values >= CONFIG.MaxValueEntries then
        return
    end

    local value = safe(function()
        return obj.Value
    end, nil)

    local display = safeString(value)

    if class == "ObjectValue" and value then
        display = getPath(value)
    end

    local uniqueKey = path

    if not State.valueSeen[uniqueKey] then
        State.valueSeen[uniqueKey] = true
        State.values[#State.values + 1] = {
            class = class,
            name = obj.Name,
            path = path,
            value = display
        }
    end
end

--// ============================================================
--// IMPORTANT OBJECT FILTER
--// ============================================================

local function isIgnoredObject(obj)
    local name = lower(obj.Name)
    local class = getClass(obj)

    if name == "roblox" then
        return true
    end

    if class == "ModuleScript" or class == "LocalScript" or class == "Script" then
        -- Keep custom scripts, but ignore obvious default player plumbing.
        if containsAny(name, IGNORE_NAME_TOKENS) then
            local path = lower(getPath(obj))

            if string.find(path, "playergui", 1, true)
                or string.find(path, "playerplayerscripts", 1, true)
                or string.find(path, "character", 1, true) then
                return true
            end
        end
    end

    return false
end

local function shouldKeepAsImportant(obj)
    local class = getClass(obj)
    local name = obj.Name
    local path = getPath(obj)

    if IMPORTANT_CLASSES[class] then
        if class == "Folder" or class == "Model" then
            return containsAny(name .. " " .. path, {
                "shop", "store", "map", "zone", "area", "spawn",
                "teleport", "portal", "quest", "npc", "merchant",
                "pet", "egg", "plot", "tycoon", "round", "arena",
                "lobby", "lemon", "sell", "buy", "upgrade", "base",
                "obstacle", "obby", "checkpoint", "rebirth"
            })
        end

        return true
    end

    return containsAny(name .. " " .. path, {
        "shop", "store", "sell", "buy", "quest", "reward", "teleport",
        "portal", "npc", "merchant", "pet", "egg", "plot", "tycoon",
        "round", "arena", "lobby", "lemon", "upgrade", "rebirth",
        "collect", "claim", "checkpoint", "spawn"
    })
end

--// ============================================================
--// OBJECT CAPTURE
--// ============================================================

local function captureObject(obj, rootName)
    State.objectCount += 1

    local class = getClass(obj)
    local path = getPath(obj)
    local name = obj.Name

    State.byClass[class] = (State.byClass[class] or 0) + 1
    State.byRoot[rootName] = (State.byRoot[rootName] or 0) + 1

    local searchable = lower(name .. " " .. path)
    local system = inferSystem(searchable)

    if system ~= "Unknown" then
        addSystemEvidence(system, class .. " " .. path)
    end

    detectKnit(obj)
    captureAttributes(obj, path)
    captureTags(obj, path)
    captureValue(obj, path)

    if class == "RemoteEvent" or class == "RemoteFunction" then
        local remote = classifyRemote(obj)

        addUnique(
            State.remotes,
            State.remoteSeen,
            path,
            remote,
            CONFIG.MaxRemoteEntries
        )

        State.relevantCount += 1
    elseif class == "BindableEvent" or class == "BindableFunction" then
        addUnique(
            State.bindables,
            State.bindableSeen,
            path,
            {
                class = class,
                name = name,
                path = path
            },
            500
        )

        State.relevantCount += 1
    elseif class == "ModuleScript" then
        if not isIgnoredObject(obj) then
            addUnique(
                State.modules,
                State.moduleSeen,
                path,
                {
                    name = name,
                    path = path
                },
                CONFIG.MaxModuleEntries
            )

            State.relevantCount += 1
        end
    elseif class == "LocalScript" or class == "Script" then
        if not isIgnoredObject(obj) then
            addUnique(
                State.scripts,
                State.scriptSeen,
                path,
                {
                    class = class,
                    name = name,
                    path = path
                },
                CONFIG.MaxScriptEntries
            )

            State.relevantCount += 1
        end
    elseif class == "Tool" then
        addUnique(
            State.tools,
            State.toolSeen,
            path,
            {
                name = name,
                path = path
            },
            400
        )

        State.relevantCount += 1
    elseif class == "ProximityPrompt" then
        addUnique(
            State.prompts,
            State.promptSeen,
            path,
            {
                name = name,
                path = path,
                action = safe(function() return obj.ActionText end, ""),
                objectText = safe(function() return obj.ObjectText end, ""),
                maxDistance = safe(function() return obj.MaxActivationDistance end, 0)
            },
            CONFIG.MaxPromptEntries
        )

        State.relevantCount += 1
    elseif class == "ClickDetector" then
        addUnique(
            State.clickDetectors,
            State.clickSeen,
            path,
            {
                name = name,
                path = path,
                maxDistance = safe(function() return obj.MaxActivationDistance end, 0)
            },
            300
        )

        State.relevantCount += 1
    elseif class == "Folder" or class == "Model" then
        if shouldKeepAsImportant(obj) then
            addUnique(
                State.important,
                State.importantSeen,
                path,
                {
                    class = class,
                    name = name,
                    path = path
                },
                CONFIG.MaxImportantEntries
            )
        end
    end
end

--// ============================================================
--// FOCUSED TREE
--// ============================================================

local function treeNodeRelevant(obj, depth)
    if depth > CONFIG.MaxTreeDepth then
        return false
    end

    local class = getClass(obj)

    if IMPORTANT_CLASSES[class] then
        return true
    end

    if containsAny(obj.Name, {
        "shop", "store", "sell", "buy", "quest", "reward", "teleport",
        "portal", "npc", "merchant", "pet", "egg", "plot", "tycoon",
        "round", "arena", "lobby", "lemon", "upgrade", "rebirth",
        "collect", "claim", "checkpoint", "spawn", "map", "zone", "area"
    }) then
        return true
    end

    return false
end

local function buildFocusedTree(root)
    local function walk(obj, depth, prefix)
        if State.treeLines >= CONFIG.MaxTreeLines then
            return
        end

        if depth > CONFIG.MaxTreeDepth then
            return
        end

        local children = getChildren(obj)

        table.sort(children, function(a, b)
            local ac = getClass(a)
            local bc = getClass(b)

            if ac == bc then
                return lower(a.Name) < lower(b.Name)
            end

            return lower(ac) < lower(bc)
        end)

        for _, child in ipairs(children) do
            if State.cancelled then
                return
            end

            local keep = treeNodeRelevant(child, depth)

            if keep then
                local class = getClass(child)

                State.tree[#State.tree + 1] = prefix
                    .. "├─ "
                    .. child.Name
                    .. " ["
                    .. class
                    .. "]"

                State.treeLines += 1

                walk(child, depth + 1, prefix .. "  ")
            end
        end
    end

    walk(root, 0, "")
end

--// ============================================================
--// ROOTS
--// ============================================================

local function getRoots()
    local roots = {}

    local function addRoot(instance, name)
        if instance then
            roots[#roots + 1] = {
                instance = instance,
                name = name
            }
        end
    end

    addRoot(ReplicatedStorage, "ReplicatedStorage")
    addRoot(ReplicatedFirst, "ReplicatedFirst")
    addRoot(Workspace, "Workspace")
    addRoot(Lighting, "Lighting")
    addRoot(StarterGui, "StarterGui")
    addRoot(StarterPlayer, "StarterPlayer")
    addRoot(Teams, "Teams")
    addRoot(SoundService, "SoundService")

    if LocalPlayer then
        addRoot(LocalPlayer:FindFirstChild("PlayerGui"), "PlayerGui")
        addRoot(LocalPlayer:FindFirstChild("PlayerScripts"), "PlayerScripts")
    end

    return roots
end

--// ============================================================
--// SCAN
--// ============================================================

local function resetState()
    State.running = false
    State.cancelled = false
    State.startedAt = 0
    State.finishedAt = 0
    State.lastFullReport = ""
    State.lastAIReport = ""

    State.objectCount = 0
    State.relevantCount = 0
    State.rootsScanned = 0

    State.byClass = {}
    State.byRoot = {}

    State.remotes = {}
    State.remoteSeen = {}

    State.bindables = {}
    State.bindableSeen = {}

    State.modules = {}
    State.moduleSeen = {}

    State.scripts = {}
    State.scriptSeen = {}

    State.tools = {}
    State.toolSeen = {}

    State.prompts = {}
    State.promptSeen = {}

    State.clickDetectors = {}
    State.clickSeen = {}

    State.values = {}
    State.valueSeen = {}

    State.attributes = {}
    State.attributeSeen = {}

    State.tags = {}
    State.tagSeen = {}

    State.important = {}
    State.importantSeen = {}

    State.systems = {}
    State.systemEvidence = {}

    State.knit = {
        detected = false,
        frameworkPaths = {},
        serviceLike = {},
        controllerLike = {}
    }

    State.tree = {}
    State.treeLines = 0
    State.warnings = {}
end

local function addWarning(text)
    if #State.warnings < 40 then
        State.warnings[#State.warnings + 1] = text
    end
end

local function scanRoot(root)
    local instance = root.instance
    local rootName = root.name

    if not instance then
        return
    end

    State.rootsScanned += 1
    State.byRoot[rootName] = 0

    local descendants = getDescendants(instance)

    for index, obj in ipairs(descendants) do
        if State.cancelled then
            return
        end

        captureObject(obj, rootName)

        if index % CONFIG.YieldEvery == 0 then
            task.wait()

            setStatus(
                "Scanning "
                    .. rootName
                    .. " • "
                    .. formatNumber(index)
                    .. " objects"
            )

            local rootProgress = math.clamp(
                index / math.max(#descendants, 1),
                0,
                1
            )

            setProgress(
                math.clamp(
                    ((State.rootsScanned - 1) + rootProgress) / 10,
                    0.05,
                    0.82
                )
            )
        end
    end

    -- Root itself is also relevant for profile/tree purposes.
    captureObject(instance, rootName)
end

--// ============================================================
--// REPORT HELPERS
--// ============================================================

local function addHeader(lines, title)
    lines[#lines + 1] = "============================================================"
    lines[#lines + 1] = title
    lines[#lines + 1] = "============================================================"
end

local function addKV(lines, key, value)
    lines[#lines + 1] = string.format(
        "%-26s : %s",
        key,
        safeString(value)
    )
end

local function addList(lines, list, formatter, limit)
    local maxItems = math.min(#list, limit or #list)

    sortedByPath(list)

    for index = 1, maxItems do
        lines[#lines + 1] = formatter(list[index])
    end

    if #list > maxItems then
        lines[#lines + 1] = "... truncated: " .. (#list - maxItems) .. " more ..."
    end

    lines[#lines + 1] = ""
end

local function sortedSystems()
    local systems = {}

    for name, score in pairs(State.systems) do
        systems[#systems + 1] = {
            name = name,
            score = score
        }
    end

    table.sort(systems, function(a, b)
        if a.score == b.score then
            return a.name < b.name
        end

        return a.score > b.score
    end)

    return systems
end

local function appendRemoteMap(lines, compact)
    addHeader(lines, compact and "REMOTE MAP" or "REMOTE EVENTS / FUNCTIONS")

    if #State.remotes == 0 then
        lines[#lines + 1] = "(no client-visible RemoteEvent/RemoteFunction found)"
        lines[#lines + 1] = ""
        return
    end

    sortedByPath(State.remotes)

    local limit = compact and 220 or CONFIG.MaxRemoteEntries

    for index, remote in ipairs(State.remotes) do
        if index > limit then
            lines[#lines + 1] = "... REMOTE MAP TRUNCATED ..."
            break
        end

        lines[#lines + 1] = string.format(
            "[%s] %s | system=%s | action=%s | confidence=%s",
            remote.class,
            remote.name,
            remote.system,
            remote.action,
            remote.confidence
        )

        lines[#lines + 1] = "  Purpose: " .. remote.purpose
        lines[#lines + 1] = "  Path: " .. remote.path

        if not compact then
            lines[#lines + 1] = string.format(
                "  Scores: system=%s action=%s",
                remote.systemScore,
                remote.actionScore
            )
            lines[#lines + 1] = "  Args: UNKNOWN (passive scan did not observe calls)"
        end

        lines[#lines + 1] = ""
    end
end

local function appendKnit(lines)
    addHeader(lines, "KNIT MAP")

    if not State.knit.detected then
        lines[#lines + 1] = "Knit indicators not detected."
        lines[#lines + 1] = ""
        return
    end

    lines[#lines + 1] = "Framework: Knit indicators DETECTED"
    lines[#lines + 1] = ""

    if #State.knit.frameworkPaths > 0 then
        lines[#lines + 1] = "Framework paths:"
        for _, path in ipairs(State.knit.frameworkPaths) do
            lines[#lines + 1] = "  - " .. path
        end
        lines[#lines + 1] = ""
    end

    local services = sortedKeys(State.knit.serviceLike)

    lines[#lines + 1] = "Service-like nodes:"

    if #services == 0 then
        lines[#lines + 1] = "  (none detected)"
    else
        for _, name in ipairs(services) do
            lines[#lines + 1] = "  - " .. name .. " => " .. State.knit.serviceLike[name]
        end
    end

    lines[#lines + 1] = ""

    local controllers = sortedKeys(State.knit.controllerLike)

    lines[#lines + 1] = "Controller-like nodes:"

    if #controllers == 0 then
        lines[#lines + 1] = "  (none detected)"
    else
        for _, name in ipairs(controllers) do
            lines[#lines + 1] = "  - " .. name .. " => " .. State.knit.controllerLike[name]
        end
    end

    lines[#lines + 1] = ""
end

local function appendSystems(lines, compact)
    addHeader(lines, compact and "DETECTED GAME SYSTEMS" or "GAME SYSTEM ANALYSIS")

    local systems = sortedSystems()

    if #systems == 0 then
        lines[#lines + 1] = "No strong name/path indicators detected."
        lines[#lines + 1] = "This is not proof that the system does not exist."
        lines[#lines + 1] = ""
        return
    end

    for _, system in ipairs(systems) do
        local evidence = State.systemEvidence[system.name] or {}

        lines[#lines + 1] = string.format(
            "[%02d] %-16s evidence=%s",
            math.min(system.score, 99),
            system.name,
            system.score
        )

        for index = 1, math.min(#evidence, compact and 2 or 6) do
            lines[#lines + 1] = "  - " .. evidence[index]
        end
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "Confidence rule: name/path heuristics only."
    lines[#lines + 1] = "These are inferences, not proof of server behavior."
    lines[#lines + 1] = ""
end

local function appendImportantObjects(lines, compact)
    addHeader(lines, compact and "IMPORTANT STRUCTURE" or "IMPORTANT OBJECTS")

    local list = {}

    for _, item in ipairs(State.important) do
        list[#list + 1] = item
    end

    if #list == 0 then
        lines[#lines + 1] = "(none)"
        lines[#lines + 1] = ""
        return
    end

    sortedByPath(list)

    local limit = compact and 250 or CONFIG.MaxImportantEntries

    for index = 1, math.min(#list, limit) do
        local item = list[index]

        lines[#lines + 1] = string.format(
            "[%s] %s\n  %s",
            item.class,
            item.name,
            item.path
        )
    end

    if #list > limit then
        lines[#lines + 1] = "... truncated ..."
    end

    lines[#lines + 1] = ""
end

local function appendModules(lines, compact)
    addHeader(lines, compact and "CLIENT-VISIBLE MODULES" or "MODULES")

    if #State.modules == 0 then
        lines[#lines + 1] = "(none)"
        lines[#lines + 1] = ""
        return
    end

    local limit = compact and 180 or CONFIG.MaxModuleEntries

    sortedByPath(State.modules)

    for index = 1, math.min(#State.modules, limit) do
        lines[#lines + 1] = "[ModuleScript] " .. State.modules[index].name
            .. "\n  " .. State.modules[index].path
    end

    if #State.modules > limit then
        lines[#lines + 1] = "... truncated ..."
    end

    lines[#lines + 1] = ""
end

local function appendScripts(lines, compact)
    addHeader(lines, compact and "CLIENT-SIDE SCRIPTS" or "SCRIPTS")

    if #State.scripts == 0 then
        lines[#lines + 1] = "(none)"
        lines[#lines + 1] = ""
        return
    end

    local limit = compact and 150 or CONFIG.MaxScriptEntries

    sortedByPath(State.scripts)

    for index = 1, math.min(#State.scripts, limit) do
        local script = State.scripts[index]

        lines[#lines + 1] = string.format(
            "[%s] %s\n  %s",
            script.class,
            script.name,
            script.path
        )
    end

    if #State.scripts > limit then
        lines[#lines + 1] = "... truncated ..."
    end

    lines[#lines + 1] = ""
end

local function appendInteractables(lines, compact)
    addHeader(lines, compact and "INTERACTABLES" or "PROXIMITY PROMPTS / CLICK DETECTORS")

    sortedByPath(State.prompts)

    local promptLimit = compact and 120 or CONFIG.MaxPromptEntries

    for index = 1, math.min(#State.prompts, promptLimit) do
        local prompt = State.prompts[index]

        lines[#lines + 1] = string.format(
            "[Prompt] %s | action=%s | object=%s\n  %s",
            prompt.name,
            safeString(prompt.action),
            safeString(prompt.objectText),
            prompt.path
        )
    end

    if #State.prompts > promptLimit then
        lines[#lines + 1] = "... prompts truncated ..."
    end

    sortedByPath(State.clickDetectors)

    local clickLimit = compact and 80 or #State.clickDetectors

    for index = 1, math.min(#State.clickDetectors, clickLimit) do
        local detector = State.clickDetectors[index]

        lines[#lines + 1] = string.format(
            "[ClickDetector] %s | distance=%s\n  %s",
            detector.name,
            safeString(detector.maxDistance),
            detector.path
        )
    end

    if #State.clickDetectors > clickLimit then
        lines[#lines + 1] = "... click detectors truncated ..."
    end

    lines[#lines + 1] = ""
end

local function appendValuesAndMetadata(lines, compact)
    addHeader(lines, compact and "VISIBLE STATE / METADATA" or "VALUES / ATTRIBUTES / TAGS")

    sortedByPath(State.values)

    local valueLimit = compact and 120 or CONFIG.MaxValueEntries

    lines[#lines + 1] = "Values:"

    for index = 1, math.min(#State.values, valueLimit) do
        local item = State.values[index]

        lines[#lines + 1] = string.format(
            "  [%s] %s = %s\n    %s",
            item.class,
            item.name,
            item.value,
            item.path
        )
    end

    if #State.values > valueLimit then
        lines[#lines + 1] = "  ... values truncated ..."
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "Attributes:"

    sortedByPath(State.attributes)

    local attributeLimit = compact and 120 or CONFIG.MaxAttributeEntries

    for index = 1, math.min(#State.attributes, attributeLimit) do
        local item = State.attributes[index]

        lines[#lines + 1] = string.format(
            "  %s.%s [%s] = %s",
            item.path,
            item.name,
            item.type,
            item.value
        )
    end

    if #State.attributes > attributeLimit then
        lines[#lines + 1] = "  ... attributes truncated ..."
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "CollectionService tags:"

    sortedByPath(State.tags)

    local tagLimit = compact and 100 or CONFIG.MaxTagEntries

    for index = 1, math.min(#State.tags, tagLimit) do
        local item = State.tags[index]
        lines[#lines + 1] = "  " .. item.path .. " => " .. item.tag
    end

    if #State.tags > tagLimit then
        lines[#lines + 1] = "  ... tags truncated ..."
    end

    lines[#lines + 1] = ""
end

local function appendFocusedTree(lines, compact)
    addHeader(lines, compact and "FOCUSED TREE" or "GAME STRUCTURE TREE")

    if #State.tree == 0 then
        lines[#lines + 1] = "(no focused nodes)"
        lines[#lines + 1] = ""
        return
    end

    local limit = compact and 900 or CONFIG.MaxTreeLines

    for index = 1, math.min(#State.tree, limit) do
        lines[#lines + 1] = State.tree[index]
    end

    if #State.tree > limit then
        lines[#lines + 1] = "... tree truncated ..."
    end

    lines[#lines + 1] = ""
end

local function appendWarnings(lines)
    addHeader(lines, "LIMITS / WARNINGS")

    if #State.warnings == 0 then
        lines[#lines + 1] = "(none)"
    else
        for _, warning in ipairs(State.warnings) do
            lines[#lines + 1] = "- " .. warning
        end
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "FACT: This scanner reads objects/state available to the client."
    lines[#lines + 1] = "UNKNOWN: Remote argument signatures were not observed."
    lines[#lines + 1] = "UNKNOWN: Server-only Script.Source and hidden server logic were not read."
    lines[#lines + 1] = "INFERENCE: System/action labels are heuristic based on names and paths."
    lines[#lines + 1] = ""
end

local function appendAIHandoff(lines)
    addHeader(lines, "AI HANDOFF")

    lines[#lines + 1] = "GOAL: Use this map as context for writing a client-side Roblox development script."
    lines[#lines + 1] = ""

    lines[#lines + 1] = "FACTS:"
    lines[#lines + 1] = "- Game Name: " .. safeString(GameProfile.name)
    lines[#lines + 1] = "- PlaceId: " .. safeString(GameProfile.placeId)
    lines[#lines + 1] = "- GameId: " .. safeString(GameProfile.gameId)
    lines[#lines + 1] = "- Visible object count in selected roots: " .. formatNumber(State.objectCount)
    lines[#lines + 1] = "- Relevant objects captured: " .. formatNumber(State.relevantCount)

    local events, functions = getRemoteCounts()

    lines[#lines + 1] = "- RemoteEvents: " .. formatNumber(events)
    lines[#lines + 1] = "- RemoteFunctions: " .. formatNumber(functions)
    lines[#lines + 1] = "- ModuleScripts: " .. formatNumber(#State.modules)
    lines[#lines + 1] = "- Scripts/LocalScripts: " .. formatNumber(#State.scripts)
    lines[#lines + 1] = "- ProximityPrompts: " .. formatNumber(#State.prompts)
    lines[#lines + 1] = "- Values: " .. formatNumber(#State.values)
    lines[#lines + 1] = "- Attributes: " .. formatNumber(#State.attributes)
    lines[#lines + 1] = ""

    lines[#lines + 1] = "INFERENCES:"
    local systems = sortedSystems()

    if #systems == 0 then
        lines[#lines + 1] = "- No strong system name/path indicators."
    else
        for index = 1, math.min(#systems, 10) do
            lines[#lines + 1] = string.format(
                "- %s (evidence=%s)",
                systems[index].name,
                systems[index].score
            )
        end
    end

    if State.knit.detected then
        lines[#lines + 1] = "- Knit framework indicators detected."
    end

    lines[#lines + 1] = ""

    lines[#lines + 1] = "UNKNOWN / NOT PROVIDED:"
    lines[#lines + 1] = "- Exact FireServer/InvokeServer argument lists."
    lines[#lines + 1] = "- Exact return values of RemoteFunctions."
    lines[#lines + 1] = "- Server-only script source and server-only logic."
    lines[#lines + 1] = "- DataStore/server database contents."
    lines[#lines + 1] = "- Any behavior that has no replicated client-visible footprint."
    lines[#lines + 1] = ""

    lines[#lines + 1] = "DEVELOPMENT NOTE:"
    lines[#lines + 1] = "- Prefer using clearly identified client-visible remotes/modules."
    lines[#lines + 1] = "- Treat every inferred purpose/action as a hypothesis until verified."
    lines[#lines + 1] = "- Do not invent remote arguments from names alone."
    lines[#lines + 1] = ""
end

--// ============================================================
--// FULL REPORT
--// ============================================================

local function buildFullReport()
    local lines = {}

    addHeader(lines, "NEXUS GAME SCANNER v7.0")
    lines[#lines + 1] = "Generated: " .. GameProfile.generated
    lines[#lines + 1] = ""

    addHeader(lines, "GAME PROFILE")
    addKV(lines, "Name", GameProfile.name)
    addKV(lines, "PlaceId", GameProfile.placeId)
    addKV(lines, "GameId", GameProfile.gameId)
    addKV(lines, "JobId", GameProfile.jobId)
    addKV(lines, "CreatorId", GameProfile.creatorId)
    addKV(lines, "CreatorType", GameProfile.creatorType)
    addKV(lines, "GameLoaded", GameProfile.loaded)
    addKV(lines, "Gravity", GameProfile.gravity)
    addKV(lines, "StreamingEnabled", GameProfile.streamingEnabled)
    addKV(lines, "MaxPlayers", GameProfile.maxPlayers)
    addKV(lines, "PlayersNow", GameProfile.playerCount)
    addKV(lines, "CameraType", GameProfile.cameraType)
    lines[#lines + 1] = ""

    addHeader(lines, "SCAN SCOPE")
    lines[#lines + 1] = "Included: ReplicatedStorage, ReplicatedFirst, Workspace,"
        .. " Lighting, StarterGui, StarterPlayer, Teams, SoundService,"
        .. " LocalPlayer.PlayerGui and LocalPlayer.PlayerScripts."
    lines[#lines + 1] = "Excluded: CoreGui / Roblox system UI internals."
    lines[#lines + 1] = ""

    addHeader(lines, "SCAN SUMMARY")
    local remoteEvents, remoteFunctions = getRemoteCounts()
    addKV(lines, "ObjectsVisited", State.objectCount)
    addKV(lines, "RelevantCaptured", State.relevantCount)
    addKV(lines, "RemoteEvents", remoteEvents)
    addKV(lines, "RemoteFunctions", remoteFunctions)
    addKV(lines, "Bindables", #State.bindables)
    addKV(lines, "ModuleScripts", #State.modules)
    addKV(lines, "Scripts", #State.scripts)
    addKV(lines, "Tools", #State.tools)
    addKV(lines, "Prompts", #State.prompts)
    addKV(lines, "ClickDetectors", #State.clickDetectors)
    addKV(lines, "Values", #State.values)
    addKV(lines, "Attributes", #State.attributes)
    addKV(lines, "Tags", #State.tags)
    lines[#lines + 1] = ""

    addHeader(lines, "CLASS SUMMARY")
    for _, class in ipairs(sortedKeys(State.byClass)) do
        addKV(lines, class, State.byClass[class])
    end
    lines[#lines + 1] = ""

    addHeader(lines, "ROOT SUMMARY")
    for _, root in ipairs(sortedKeys(State.byRoot)) do
        addKV(lines, root, State.byRoot[root])
    end
    lines[#lines + 1] = ""

    appendRemoteMap(lines, false)

    addHeader(lines, "BINDABLES")
    sortedByPath(State.bindables)
    for index = 1, math.min(#State.bindables, 500) do
        lines[#lines + 1] = string.format(
            "[%s] %s\n  %s",
            State.bindables[index].class,
            State.bindables[index].name,
            State.bindables[index].path
        )
    end
    lines[#lines + 1] = ""

    appendKnit(lines)
    appendSystems(lines, false)
    appendModules(lines, false)
    appendScripts(lines, false)
    appendImportantObjects(lines, false)
    appendInteractables(lines, false)
    appendValuesAndMetadata(lines, false)
    appendFocusedTree(lines, false)
    appendAIHandoff(lines)
    appendWarnings(lines)

    addHeader(lines, "END OF REPORT")
    lines[#lines + 1] = "NEXUS GAME SCANNER v7.0"
    lines[#lines + 1] = "Passive client-visible analysis only."

    local report = table.concat(lines, "\n")

    if #report > 1400000 then
        report = report:sub(1, 1400000)
            .. "\n\n[HARD TRUNCATED AT 1,400,000 CHARACTERS]"
    end

    return report
end

--// ============================================================
--// AI REPORT
--// ============================================================

local function buildAIReport()
    local lines = {}

    addHeader(lines, "NEXUS AI GAME REPORT v7.0")
    lines[#lines + 1] = "This compact report is intended to be pasted into ChatGPT"
    lines[#lines + 1] = "before asking for a client-side Roblox script."
    lines[#lines + 1] = ""

    addHeader(lines, "GAME")
    addKV(lines, "Name", GameProfile.name)
    addKV(lines, "PlaceId", GameProfile.placeId)
    addKV(lines, "GameId", GameProfile.gameId)
    addKV(lines, "PlayersNow", GameProfile.playerCount)
    addKV(lines, "StreamingEnabled", GameProfile.streamingEnabled)
    lines[#lines + 1] = ""

    appendAIHandoff(lines)

    appendRemoteMap(lines, true)
    appendKnit(lines)
    appendSystems(lines, true)
    appendModules(lines, true)
    appendScripts(lines, true)
    appendImportantObjects(lines, true)
    appendInteractables(lines, true)
    appendValuesAndMetadata(lines, true)
    appendFocusedTree(lines, true)

    addHeader(lines, "IMPORTANT REQUEST FORMAT")
    lines[#lines + 1] = "When generating code from this report:"
    lines[#lines + 1] = "- Separate verified facts from inferred behavior."
    lines[#lines + 1] = "- Do not invent unknown remote arguments."
    lines[#lines + 1] = "- Prefer existing client-visible modules/remotes."
    lines[#lines + 1] = "- State clearly when a server-side detail is missing."
    lines[#lines + 1] = ""

    local report = table.concat(lines, "\n")

    if #report > 500000 then
        report = report:sub(1, 500000)
            .. "\n\n[AI REPORT HARD TRUNCATED AT 500,000 CHARACTERS]"
    end

    return report
end

--// ============================================================
--// PREVIEW
--// ============================================================

local function buildPreview()
    local events, functions = getRemoteCounts()
    local systems = sortedSystems()

    local lines = {
        "NEXUS GAME SCANNER v7.0",
        "",
        "SCAN COMPLETE",
        "",
        "Game           : " .. safeString(GameProfile.name),
        "PlaceId        : " .. safeString(GameProfile.placeId),
        "Objects        : " .. formatNumber(State.objectCount),
        "Relevant       : " .. formatNumber(State.relevantCount),
        "RemoteEvents   : " .. formatNumber(events),
        "RemoteFunctions: " .. formatNumber(functions),
        "Modules        : " .. formatNumber(#State.modules),
        "Scripts        : " .. formatNumber(#State.scripts),
        "Prompts        : " .. formatNumber(#State.prompts),
        "Attributes     : " .. formatNumber(#State.attributes),
        "",
        "Knit           : " .. (State.knit.detected and "DETECTED" or "not detected"),
        "",
        "Top systems:"
    }

    for index = 1, math.min(#systems, 8) do
        lines[#lines + 1] = "• "
            .. systems[index].name
            .. " ("
            .. systems[index].score
            .. ")"
    end

    if #systems == 0 then
        lines[#lines + 1] = "• none strongly detected"
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "AI COPY = compact report"
    lines[#lines + 1] = "FULL COPY = detailed report"

    return table.concat(lines, "\n")
end

--// ============================================================
--// RUN SCAN
--// ============================================================

local function runScan()
    if State.running then
        return
    end

    resetState()
    State.running = true
    State.cancelled = false
    State.startedAt = os.clock()

    ScanButton.Text = "CANCEL"
    AICopyButton.Text = "AI COPY"
    FullCopyButton.Text = "FULL COPY"

    setProgress(0)
    setStatus("Preparing focused scan...")
    setOutput("Starting v7.0 focused game analysis...\n")

    GameProfile = makeGameProfile()

    local roots = getRoots()

    if #roots == 0 then
        State.running = false
        setStatus("No scan roots available.")
        setOutput("No client-visible game roots were available.")
        ScanButton.Text = "SCAN"
        return
    end

    for index, root in ipairs(roots) do
        if State.cancelled then
            break
        end

        setStatus(
            "Root "
                .. index
                .. "/"
                .. #roots
                .. ": "
                .. root.name
        )

        scanRoot(root)

        setProgress(
            math.clamp(
                0.05 + (index / #roots) * 0.72,
                0.05,
                0.77
            )
        )

        task.wait()
    end

    if State.cancelled then
        State.running = false
        setProgress(0)
        setStatus("Scan cancelled.")
        setOutput("Scan cancelled before report generation.")
        ScanButton.Text = "SCAN"
        return
    end

    setStatus("Building focused tree...")
    setProgress(0.82)

    for _, root in ipairs(roots) do
        if State.cancelled then
            break
        end

        buildFocusedTree(root.instance)
        task.wait()
    end

    if State.cancelled then
        State.running = false
        setProgress(0)
        setStatus("Scan cancelled.")
        setOutput("Scan cancelled while building tree.")
        ScanButton.Text = "SCAN"
        return
    end

    setStatus("Building AI report...")
    setProgress(0.91)

    State.lastAIReport = buildAIReport()

    setStatus("Building full report...")
    setProgress(0.96)

    State.lastFullReport = buildFullReport()

    State.finishedAt = os.clock()
    State.running = false

    setProgress(1)

    setStatus(
        "Complete • "
            .. string.format("%.2fs", State.finishedAt - State.startedAt)
            .. " • "
            .. formatNumber(State.relevantCount)
            .. " relevant"
    )

    updateStats()
    setOutput(buildPreview())
    ScanButton.Text = "RESCAN"
end

--// ============================================================
--// BUTTONS
--// ============================================================

ScanButton.Activated:Connect(function()
    if State.running then
        State.cancelled = true
        setStatus("Cancelling...")
        ScanButton.Text = "CANCEL"
        return
    end

    task.spawn(runScan)
end)

AICopyButton.Activated:Connect(function()
    if State.running then
        setStatus("Wait until scan finishes.")
        return
    end

    if State.lastAIReport == "" then
        setStatus("Run SCAN first.")
        return
    end

    local ok, message = copyText(State.lastAIReport)

    if ok then
        setStatus(
            "AI report copied • "
                .. formatNumber(#State.lastAIReport)
                .. " chars"
        )
    else
        setStatus(message)
        setOutput(State.lastAIReport)
    end
end)

FullCopyButton.Activated:Connect(function()
    if State.running then
        setStatus("Wait until scan finishes.")
        return
    end

    if State.lastFullReport == "" then
        setStatus("Run SCAN first.")
        return
    end

    local ok, message = copyText(State.lastFullReport)

    if ok then
        setStatus(
            "Full report copied • "
                .. formatNumber(#State.lastFullReport)
                .. " chars"
        )
    else
        setStatus(message)
        setOutput(State.lastFullReport)
    end
end)

ClearButton.Activated:Connect(function()
    if State.running then
        return
    end

    resetState()
    GameProfile = {}
    setProgress(0)
    setStatus("Ready")
    updateStats()

    setOutput(
        "NEXUS GAME SCANNER v7.0\n\n"
            .. "Focused passive scanner ready.\n"
            .. "CoreGui / Roblox system internals are excluded.\n\n"
            .. "SCAN → build game map\n"
            .. "AI COPY → compact ChatGPT handoff\n"
            .. "FULL COPY → detailed report"
    )
end)

MinButton.Activated:Connect(function()
    Main.Visible = false

    if OpenButton then
        OpenButton:Destroy()
        OpenButton = nil
    end

    OpenButton = Instance.new("TextButton")
    OpenButton.Name = "OpenScanner"
    OpenButton.Size = UDim2.fromOffset(150, 44)
    OpenButton.Position = UDim2.new(0, 18, 1, -62)
    OpenButton.BackgroundColor3 = Color3.fromRGB(20, 22, 31)
    OpenButton.BorderSizePixel = 0
    OpenButton.Text = "NEXUS SCANNER"
    OpenButton.Font = Enum.Font.GothamBold
    OpenButton.TextSize = 12
    OpenButton.TextColor3 = Color3.fromRGB(235, 238, 250)
    OpenButton.Parent = Gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = OpenButton

    OpenButton.Activated:Connect(function()
        if OpenButton then
            OpenButton:Destroy()
            OpenButton = nil
        end

        Main.Visible = true
    end)
end)

CloseButton.Activated:Connect(function()
    Gui:Destroy()
end)

--// ============================================================
--// INITIAL STATE
--// ============================================================

GameProfile = makeGameProfile()
updateStats()

setOutput(
    "NEXUS GAME SCANNER v7.0\n\n"
        .. "Focused passive scanner ready.\n"
        .. "It scans game-relevant client-visible roots and filters\n"
        .. "CoreGui / Roblox system noise.\n\n"
        .. "SCAN → build map\n"
        .. "AI COPY → compact report for ChatGPT\n"
        .. "FULL COPY → detailed report\n"
)

-- Set true only if you want automatic scanning.
local AUTO_SCAN = false

if AUTO_SCAN then
    task.defer(runScan)
end
