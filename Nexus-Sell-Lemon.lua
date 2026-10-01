--[[
    NEXUS • SELL LEMON
    Cosmic Purple visual theme; no neon effects.
    v10 — optimized orchard harvest cache; UI construction fixed; thumbnail loading no longer blocks menu.
    Standalone UI — NO MacLib dependency.

    Ported functionality from the supplied Sell Lemon / NEXUS • SELL LEMON script:
      FARM
        • Auto Buy Upgrades
        • Auto Click Income
        • Auto Upgrade Stands
        • Auto Collect Fruit
        • Auto Cash Vine
        • Auto Phone Offer
      PROGRESSION
        • Auto Rebirth
        • Auto Ascend
        • Auto Evolve
        • Auto Power Upgrade
      BONUS
        • Auto Double Offline Cash
        • Auto Use Time Cash
        • Auto Use Earner Boost
        • Auto Minigame Race
        • Auto Minigame Trade
      SETTINGS
        • Fruit Sweep Delay
        • Phone Offer Response
        • Anti-AFK
        • Boost FPS
      STATS
        • Live counters + Cash

    Designed for PC + Mobile.
]]

--==============================================================
-- SERVICES
--==============================================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==============================================================
-- CONFIG / STATE
--==============================================================

local CONFIG = {
    -- 1.4x smaller than the previous 760x500 window.
    WindowWidth = 544,
    WindowHeight = 357,
    MinWindowWidth = 300,
    MinWindowHeight = 320,
    DragKey = Enum.KeyCode.RightControl,
    FruitSweepDelay = 5,
    PhoneOfferResponse = "Accept",
    RebirthInterval = 3600, -- 1 minute .. 4 hours; default 1 hour
    StandUpgradeAmount = 5, -- 5 / 25 / 100 / "Max"
}

local ENABLED = {
    AutoBuyUpgrades = false,
    AutoCollectFruit = false,
    AutoHarvestGarden = false,
    AutoClick = false,
    AutoPhoneOffer = false,
    AutoUpgradeStands = false,
    AutoRebirth = false,
    AutoAscend = false,
    AutoEvolve = false,
    AutoPowerUpgrade = false,
    AutoOfflineCash = false,
    AutoTimeCash = false,
    AutoEarnerBoost = false,
    AutoMinigameRace = false,
    AutoMinigameTrade = false,
    AutoCashVine = false,
    AntiAFK = false,
    BoostFPS = false,
}

local STATS = {
    upgradesBought = 0,
    fruitCollected = 0,
    gardenHarvests = 0,
    clicks = 0,
    phoneOffers = 0,
    standsUpgraded = 0,
    rebirths = 0,
    ascends = 0,
    evolves = 0,
    powerUpgrades = 0,
    racesWon = 0,
    tradesWon = 0,
    vineCollected = 0,
}

local POWER_NAMES = {
    "UpgradeStack",
    "BuyNext",
    "Manage",
    "WalkSpeed",
    "ClickFruitValue",
}

local INCOME_STREAMS = {
    "LemonDash",
    "LemonDepot",
    "LemonLabs",
    "LemonTrading",
    "LemonRepublic",
    "LemonRobotics",
    "LemonStand",
    "LemonX",
}

local STAND_NAMES = {
    "LemonDash",
    "Lemon Depot",
    "Lemon Labs",
    "Lemon Stand",
    "Lemon Trading",
    "Lemon Republic",
    "Lemon Robotics",
    "LemonX",
}

local PHONE_OFFER_RESPONSES = { "Accept", "Raise", "Reject" }

--==============================================================
-- COLORS — , NO NEON
--==============================================================

local C = {
    Background = Color3.fromRGB(12, 10, 17),
    Surface = Color3.fromRGB(19, 16, 27),
    Surface2 = Color3.fromRGB(24, 20, 34),
    Surface3 = Color3.fromRGB(29, 24, 40),
    Border = Color3.fromRGB(58, 46, 78),
    BorderSoft = Color3.fromRGB(43, 35, 58),
    Purple = Color3.fromRGB(150, 105, 220),
    Purple2 = Color3.fromRGB(111, 75, 174),
    PurpleSoft = Color3.fromRGB(93, 72, 125),
    PurpleDark = Color3.fromRGB(43, 32, 58),
    White = Color3.fromRGB(238, 235, 244),
    Text = Color3.fromRGB(224, 219, 232),
    SubText = Color3.fromRGB(145, 137, 157),
    Muted = Color3.fromRGB(107, 100, 118),
    Green = Color3.fromRGB(103, 178, 124),
    Red = Color3.fromRGB(183, 95, 111),
    Gold = Color3.fromRGB(214, 177, 100),
}

--==============================================================
-- CLEANUP
--==============================================================

pcall(function()
    local old = PlayerGui:FindFirstChild("NEXUS_Sell_Lemon")
    if old then
        old:Destroy()
    end
end)

--==============================================================
-- HELPERS
--==============================================================

local Connections = {}
local function connect(signal, callback)
    local c = signal:Connect(callback)
    table.insert(Connections, c)
    return c
end

local function disconnectAll()
    for _, c in ipairs(Connections) do
        pcall(function() c:Disconnect() end)
    end
    table.clear(Connections)
end

local function tween(obj, duration, props, style, direction)
    local info = TweenInfo.new(
        duration or 0.18,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function corner(parent, radius)
    local x = Instance.new("UICorner")
    x.CornerRadius = UDim.new(0, radius or 8)
    x.Parent = parent
    return x
end

local function stroke(parent, color, transparency, thickness)
    local x = Instance.new("UIStroke")
    x.Color = color or C.Border
    x.Transparency = transparency == nil and 0 or transparency
    x.Thickness = thickness or 1
    x.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    x.Parent = parent
    return x
end

local function padding(parent, left, top, right, bottom)
    local p = Instance.new("UIPadding")
    p.PaddingLeft = UDim.new(0, left or 0)
    p.PaddingTop = UDim.new(0, top or 0)
    p.PaddingRight = UDim.new(0, right or 0)
    p.PaddingBottom = UDim.new(0, bottom or 0)
    p.Parent = parent
    return p
end

local function makeLabel(parent, text, size, color, bold)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel = 0
    l.Text = tostring(text or "")
    l.TextColor3 = color or C.Text
    l.TextSize = size or 14
    l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.Parent = parent
    return l
end

local function makeButton(parent, text, height)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.BackgroundColor3 = C.Surface2
    b.BorderSizePixel = 0
    b.Size = UDim2.new(1, 0, 0, height or 34)
    b.Text = text or ""
    b.TextColor3 = C.Text
    b.TextSize = 12
    b.Font = Enum.Font.GothamMedium
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.TextTruncate = Enum.TextTruncate.AtEnd
    b.Parent = parent
    corner(b, 7)
    stroke(b, C.BorderSoft, 0.2)
    connect(b.MouseEnter, function()
        tween(b, 0.12, { BackgroundColor3 = C.Surface3 })
    end)
    connect(b.MouseLeave, function()
        tween(b, 0.12, { BackgroundColor3 = C.Surface2 })
    end)
    return b
end

local function makeSectionTitle(parent, text)
    local label = makeLabel(parent, text, 11, C.Muted, true)
    label.Size = UDim2.new(1, 0, 0, 22)
    return label
end

--==============================================================
-- GAME FUNCTIONS — PORTED FROM ORIGINAL
--==============================================================

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart", 10)

connect(LocalPlayer.CharacterAdded, function(c)
    character = c
    root = c:WaitForChild("HumanoidRootPart", 10)
end)

local myTycoon = nil

local function getMyTycoon()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name:match("^Tycoon%d+$") then
            local owner = obj:FindFirstChild("Owner", true)
            if owner and owner:IsA("ObjectValue") and owner.Value == LocalPlayer then
                return obj
            end
        end
    end
    return nil
end

local function tycoon()
    if not myTycoon or not myTycoon.Parent then
        myTycoon = getMyTycoon()
    end
    return myTycoon
end

task.spawn(function()
    for _ = 1, 30 do
        myTycoon = getMyTycoon()
        if myTycoon then break end
        task.wait(0.5)
    end
end)

local function rem(name)
    local t = tycoon()
    if not t then return nil end
    local remotes = t:FindFirstChild("Remotes")
    if not remotes then return nil end
    return remotes:FindFirstChild(name)
end

local function getCash()
    local function readValue(obj)
        if not obj then return nil end
        if obj:IsA("NumberValue") or obj:IsA("IntValue") then
            return tonumber(obj.Value)
        end
        if obj:IsA("StringValue") then
            return tonumber(obj.Value)
        end
        return nil
    end

    local function readAttribute(container, names)
        if not container then return nil end
        for _, name in ipairs(names) do
            local value = container:GetAttribute(name)
            if type(value) == "number" then
                return value
            elseif type(value) == "string" then
                local n = tonumber(value)
                if n then return n end
            end
        end
        return nil
    end

    local names = {
        "Cash", "Money", "Coins", "Coin", "LemonCash", "LemonMoney",
        "Currency", "Balance", "CashAmount", "MoneyAmount",
    }

    local candidates = {}
    local function addCandidate(value)
        if value ~= nil then
            table.insert(candidates, tonumber(value) or 0)
        end
    end

    addCandidate(readAttribute(LocalPlayer, names))

    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    local t = tycoon()
    addCandidate(readAttribute(t, names))

    local containers = { leaderstats, LocalPlayer, t }
    for _, container in ipairs(containers) do
        if container then
            for _, name in ipairs(names) do
                addCandidate(readValue(container:FindFirstChild(name, true)))
            end
        end
    end

    -- Fallback for games whose leaderstat has a non-standard currency name.
    -- Only scan leaderstats here to keep the live stat update lightweight.
    local fallback = 0
    if leaderstats then
        for _, obj in ipairs(leaderstats:GetDescendants()) do
            local value = readValue(obj)
            if value and value > fallback then
                fallback = value
            end
        end
    end

    local best = nil
    for _, value in ipairs(candidates) do
        if best == nil or value > best then
            best = value
        end
    end

    return math.floor(best ~= nil and best or fallback)
end

local buyLock = {}

local function autoBuyUpgradesStep()
    local t = tycoon()
    if not t then return end

    local purchases = t:FindFirstChild("Purchases")
    if not purchases then return end

    for _, obj in ipairs(purchases:GetDescendants()) do
        if not ENABLED.AutoBuyUpgrades then break end
        if not (obj:IsA("RemoteFunction") and obj.Name == "Purchase") then
            continue
        end

        local btn = obj.Parent
        if not btn then continue end
        if buyLock[obj] then continue end
        if btn:GetAttribute("Purchased") == true then continue end
        if btn:GetAttribute("Enabled") == false then continue end
        if btn:GetAttribute("Shown") == false then continue end

        buyLock[obj] = true
        task.spawn(function()
            local ok = pcall(function()
                obj:InvokeServer(false)
            end)
            if ok then
                STATS.upgradesBought += 1
            end
            task.wait(0.8)
            buyLock[obj] = nil
        end)
    end
end

local cachedStandRFs = {}

local function buildStandRFCache()
    table.clear(cachedStandRFs)
    local t = tycoon()
    if not t then return end

    local purchases = t:FindFirstChild("Purchases")
    if not purchases then return end

    for _, standName in ipairs(STAND_NAMES) do
        local standFolder = purchases:FindFirstChild(standName)
        if not standFolder then continue end

        local standModel = standFolder:FindFirstChild(standName)
        if not standModel then continue end

        for _, obj in ipairs(standModel:GetDescendants()) do
            if obj:IsA("RemoteFunction") and obj.Name == "Upgrade" then
                cachedStandRFs[standName] = obj
                break
            end
        end
    end
end

local lastStandTick = 0
local standUpgradeBusy = {}

local function doStandUpgrade(upgradeRF)
    if not upgradeRF or not upgradeRF.Parent then return end
    if standUpgradeBusy[upgradeRF] then return end

    standUpgradeBusy[upgradeRF] = true
    task.spawn(function()
        local mode = CONFIG.StandUpgradeAmount

        if mode == "Max" then
            -- The game remote is known to accept a numeric batch size (the
            -- original script used 5). For Max, use the largest supported
            -- batch repeatedly, stopping on an explicit failure/false result
            -- and capping the loop so one stand can never lock the UI loop.
            for _ = 1, 25 do
                if not upgradeRF.Parent then break end

                local ok, result = pcall(function()
                    return upgradeRF:InvokeServer(100)
                end)

                if not ok or result == false then
                    break
                end

                STATS.standsUpgraded += 1
                task.wait(0.06)
            end
        else
            local amount = tonumber(mode) or 5
            local ok = pcall(function()
                upgradeRF:InvokeServer(amount)
            end)
            if ok then
                STATS.standsUpgraded += 1
            end
        end

        standUpgradeBusy[upgradeRF] = nil
    end)
end

local function autoUpgradeStandsStep()
    if os.clock() - lastStandTick < 0.65 then return end
    lastStandTick = os.clock()

    if not next(cachedStandRFs) then
        buildStandRFCache()
        if not next(cachedStandRFs) then return end
    end

    for _, upgradeRF in pairs(cachedStandRFs) do
        doStandUpgrade(upgradeRF)
    end
end

local function getCharacterRoot()
    local c = LocalPlayer.Character
    if not c then return nil end

    local r = c:FindFirstChild("HumanoidRootPart")
    if r and r:IsA("BasePart") then
        root = r
        return r
    end

    return root
end

local function moveRootTo(position)
    local r = getCharacterRoot()
    if not r or not position then return false end

    local target = CFrame.new(position)
    local ok = pcall(function()
        r.CFrame = target
    end)

    -- Pivot the whole character as well. This helps when the character root is
    -- network-owned differently by the game.
    local c = LocalPlayer.Character
    if c then
        pcall(function()
            c:PivotTo(target)
        end)
    end

    return ok
end

local function fireClickDetectorSafe(cd)
    if not cd or not cd.Parent then return false end
    local fn = fireclickdetector
    if type(fn) ~= "function" then return false end

    -- Different executors expose the optional distance/argument differently.
    for _, args in ipairs({ {cd, 1}, {cd, 20}, {cd} }) do
        local ok = pcall(fn, table.unpack(args))
        if ok then return true end
    end

    return false
end

local function activatePromptSafe(prompt)
    if not prompt or not prompt.Parent then return false end
    local fn = fireproximityprompt
    if type(fn) ~= "function" then return false end

    for _, args in ipairs({ {prompt, 1}, {prompt, 0}, {prompt} }) do
        local ok = pcall(fn, table.unpack(args))
        if ok then return true end
    end

    return false
end

local function touchPartSafe(part)
    if not part or not part.Parent then return false end
    local fn = firetouchinterest
    local r = getCharacterRoot()
    if type(fn) ~= "function" or not r then return false end

    local ok = pcall(fn, r, part, 0)
    if not ok then return false end
    task.wait(0.05)
    pcall(fn, r, part, 1)
    return true
end

local function findDescendantOfClass(parent, className)
    if not parent then return nil end
    for _, obj in ipairs(parent:GetDescendants()) do
        if obj:IsA(className) then
            return obj
        end
    end
    return nil
end

local function findFirstBasePart(parent)
    if not parent then return nil end
    if parent:IsA("BasePart") then return parent end
    for _, obj in ipairs(parent:GetDescendants()) do
        if obj:IsA("BasePart") then
            return obj
        end
    end
    return nil
end

local function autoCollectFruitStep()
    local r = getCharacterRoot()
    if not r then return end

    local targets = {}
    local seen = {}

    -- Prefer the exact hierarchy from the supplied working script, then fall
    -- back to a broader LemonTree/Fruit detector search for map variations.
    for _, tree in ipairs(Workspace:GetDescendants()) do
        if tree.Name ~= "LemonTree" then continue end

        for _, fruit in ipairs(tree:GetDescendants()) do
            if fruit.Name ~= "Fruit" then continue end

            local clickPart = fruit:FindFirstChild("ClickPart", true)
            local detector = clickPart and clickPart:FindFirstChildOfClass("ClickDetector")

            if not detector then
                detector = findDescendantOfClass(fruit, "ClickDetector")
            end

            if detector and not seen[detector] then
                local targetPart = clickPart
                if not targetPart or not targetPart:IsA("BasePart") then
                    targetPart = detector.Parent
                    while targetPart and targetPart ~= fruit and not targetPart:IsA("BasePart") do
                        targetPart = targetPart.Parent
                    end
                end
                if not targetPart or not targetPart:IsA("BasePart") then
                    targetPart = findFirstBasePart(fruit)
                end

                if targetPart then
                    seen[detector] = true
                    table.insert(targets, {
                        detector = detector,
                        part = targetPart,
                    })
                end
            end
        end
    end

    if #targets == 0 then return end

    local saved = r.CFrame
    for _, entry in ipairs(targets) do
        if not ENABLED.AutoCollectFruit then break end
        if not entry.detector or not entry.detector.Parent then continue end
        if not entry.part or not entry.part.Parent then continue end

        moveRootTo(entry.part.Position + Vector3.new(0, 3, 0))
        task.wait(0.12)

        -- Try the normal click-detector path more than once, because some
        -- versions of the game recreate the detector after collection.
        local fired = false
        for _ = 1, 2 do
            if not entry.detector.Parent then break end
            if fireClickDetectorSafe(entry.detector) then
                fired = true
                break
            end
            task.wait(0.06)
        end

        if fired then
            STATS.fruitCollected += 1
        end
        task.wait(0.14)
    end

    pcall(function()
        if r and r.Parent then
            r.CFrame = saved
        end
    end)
end

--==============================================================
-- AUTO GARDEN HARVEST (OPTIMIZED / EVENT-DRIVEN)
--==============================================================
-- The old implementation scanned all of Workspace every 0.5s. That was
-- expensive on a large orchard (40+ trees) and could tank FPS/ping.
-- Instead we build a small cache once and keep it updated when prompts or
-- click detectors are added/removed or when their text/state changes.

local gardenHarvestDebounce = setmetatable({}, {__mode = "k"})
local gardenCandidates = {}
local gardenCandidateConnections = setmetatable({}, {__mode = "k"})
local gardenDirty = true
local gardenLastPass = 0
local GARDEN_PASS_INTERVAL = 0.20

local function gardenText(value)
    if type(value) ~= "string" then return "" end
    return value:lower():gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
end

local function isGardenActionText(value)
    local t = gardenText(value)
    return t == "урожай"
        or t == "собрать"
        or t == "harvest"
        or t == "gather"
        or t == "collect harvest"
end

local function isGardenContext(obj)
    local current = obj
    for _ = 1, 10 do
        if not current then break end
        local n = gardenText(current.Name)
        if n:find("garden", 1, true)
            or n:find("orchard", 1, true)
            or n:find("crop", 1, true)
            or n:find("plant", 1, true)
            or n:find("сад", 1, true)
            or n:find("урож", 1, true) then
            return true
        end
        current = current.Parent
    end
    return false
end

local function isCashContext(obj)
    local current = obj
    for _ = 1, 10 do
        if not current then break end
        local n = gardenText(current.Name)
        if n:find("cash", 1, true)
            or n:find("money", 1, true)
            or n:find("coin", 1, true)
            or n:find("drop", 1, true)
            or n:find("деньг", 1, true)
            or n:find("монет", 1, true)
            or n:find("меш", 1, true) then
            return true
        end
        current = current.Parent
    end
    return false
end

local function isGardenCandidate(obj)
    if not obj or not obj.Parent then return false end
    if isCashContext(obj) then return false end

    if obj:IsA("ProximityPrompt") then
        local action = isGardenActionText(obj.ActionText)
        local object = isGardenActionText(obj.ObjectText)
        local name = isGardenActionText(obj.Name)

        -- Prefer the exact UI action from the screenshot. Generic "Collect"
        -- is intentionally NOT accepted anymore because it can belong to cash.
        if action or name or object then
            if action or name or object then
                return true
            end
            return isGardenContext(obj)
        end

        return false
    end

    if obj:IsA("ClickDetector") then
        local name = isGardenActionText(obj.Name)
        local parentName = obj.Parent and isGardenActionText(obj.Parent.Name)
        local grandName = obj.Parent and obj.Parent.Parent and isGardenActionText(obj.Parent.Parent.Name)
        if name or parentName or grandName then
            return true
        end
    end

    return false
end

local function removeGardenCandidate(obj)
    gardenCandidates[obj] = nil
    local bucket = gardenCandidateConnections[obj]
    if bucket then
        for _, c in ipairs(bucket) do
            pcall(function() c:Disconnect() end)
        end
        gardenCandidateConnections[obj] = nil
    end
end

local function refreshGardenCandidate(obj)
    if not obj then return end
    removeGardenCandidate(obj)

    if not (obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector")) then
        return
    end

    if not isGardenCandidate(obj) then
        return
    end

    gardenCandidates[obj] = true
    local bucket = {}

    if obj:IsA("ProximityPrompt") then
        table.insert(bucket, connect(obj:GetPropertyChangedSignal("ActionText"), function()
            gardenDirty = true
            refreshGardenCandidate(obj)
        end))
        table.insert(bucket, connect(obj:GetPropertyChangedSignal("ObjectText"), function()
            gardenDirty = true
            refreshGardenCandidate(obj)
        end))
        table.insert(bucket, connect(obj:GetPropertyChangedSignal("Enabled"), function()
            gardenDirty = true
        end))
    end

    gardenCandidateConnections[obj] = bucket
end

local function interactGardenObject(obj)
    if not obj or not obj.Parent then return false end

    if gardenHarvestDebounce[obj] and os.clock() - gardenHarvestDebounce[obj] < 1.25 then
        return false
    end

    if not isGardenCandidate(obj) then
        gardenCandidates[obj] = nil
        return false
    end

    gardenHarvestDebounce[obj] = os.clock()

    if obj:IsA("ProximityPrompt") then
        if obj.Enabled == false then return false end
        local fire = fireproximityprompt
        if type(fire) ~= "function" then return false end

        local ok = pcall(function()
            -- No character movement: fire the prompt directly.
            fire(obj, 1, true)
        end)
        if ok then
            STATS.gardenHarvests += 1
            return true
        end
        return false
    end

    if obj:IsA("ClickDetector") then
        local fire = fireclickdetector
        if type(fire) ~= "function" then return false end

        local ok = pcall(function()
            fire(obj, 1)
        end)
        if ok then
            STATS.gardenHarvests += 1
            return true
        end
        return false
    end

    return false
end

local function autoHarvestGardenStep(forcePass)
    if not ENABLED.AutoHarvestGarden then return end

    local now = os.clock()
    if not forcePass and now - gardenLastPass < GARDEN_PASS_INTERVAL then
        return
    end
    gardenLastPass = now

    -- The cache is tiny compared to Workspace, so this remains cheap even
    -- with dozens of orchard trees.
    for obj in pairs(gardenCandidates) do
        if not obj or not obj.Parent then
            removeGardenCandidate(obj)
            continue
        end

        if isGardenCandidate(obj) then
            interactGardenObject(obj)
        else
            removeGardenCandidate(obj)
        end
    end

    gardenDirty = false
end

-- Build the cache ONCE. This is intentionally not placed in a fast loop.
for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then
        refreshGardenCandidate(obj)
    end
end

connect(Workspace.DescendantAdded, function(obj)
    if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then
        refreshGardenCandidate(obj)
        gardenDirty = true
    end
end)

connect(Workspace.DescendantRemoving, function(obj)
    if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then
        removeGardenCandidate(obj)
        gardenDirty = true
    end
end)

local cachedWakeRF = nil
local function buildWakeRFCache()
    cachedWakeRF = nil
    local r = rem("WakeIncomeStream")
    if r and r:IsA("RemoteFunction") then
        cachedWakeRF = r
    end
end

local lastClickTick = 0
local function autoClickStep()
    if os.clock() - lastClickTick < 0.5 then return end
    lastClickTick = os.clock()

    if not cachedWakeRF then
        buildWakeRFCache()
        if not cachedWakeRF then return end
    end

    for _, streamName in ipairs(INCOME_STREAMS) do
        local s = streamName
        task.spawn(function()
            local ok = pcall(function()
                cachedWakeRF:InvokeServer(s)
            end)
            if ok then
                STATS.clicks += 1
            end
        end)
    end
end

local phoneEvent = nil
local phoneConn = nil
local activeOffer = false
local offerHandled = false

local function respondToOffer()
    if not phoneEvent then return end
    offerHandled = true
    local ok = pcall(function()
        phoneEvent:FireServer(CONFIG.PhoneOfferResponse)
    end)
    if ok then
        STATS.phoneOffers += 1
    end
end

local function setupPhoneOffer()
    local t = tycoon()
    if not t then return end

    local remotes = t:FindFirstChild("Remotes")
    if not remotes then return end

    local ev = remotes:FindFirstChild("PhoneOffer")
    if not ev or not ev:IsA("RemoteEvent") then return end

    phoneEvent = ev
    if phoneConn then
        pcall(function() phoneConn:Disconnect() end)
    end

    phoneConn = ev.OnClientEvent:Connect(function(val)
        if type(val) == "number" then
            activeOffer = true
            offerHandled = false
            if ENABLED.AutoPhoneOffer then
                respondToOffer()
            end
        else
            activeOffer = false
            offerHandled = false
        end
    end)
    table.insert(Connections, phoneConn)
end

local rebirthCooldown = false
local lastRebirthTime = 0

local function autoRebirthStep()
    if rebirthCooldown then return end

    -- Do not fire immediately on toggle; wait for the selected interval.
    if lastRebirthTime == 0 then
        lastRebirthTime = os.clock()
        return
    end

    if os.clock() - lastRebirthTime < CONFIG.RebirthInterval then
        return
    end

    local r = rem("Rebirth")
    if not r then return end

    rebirthCooldown = true
    task.spawn(function()
        local ok = pcall(function()
            r:InvokeServer()
        end)

        if ok then
            lastRebirthTime = os.clock()
            STATS.rebirths += 1

            task.wait(5)
            myTycoon = nil
            table.clear(buyLock)

            for _ = 1, 20 do
                myTycoon = getMyTycoon()
                if myTycoon then break end
                task.wait(0.5)
            end

            buildStandRFCache()
            buildWakeRFCache()
            setupPhoneOffer()
        end

        rebirthCooldown = false
    end)
end

local lastAscend = 0
local function autoAscendStep()
    if os.clock() - lastAscend < 8 then return end
    lastAscend = os.clock()

    local r = rem("Ascend")
    if not r then return end
    local ok = pcall(function()
        r:InvokeServer()
    end)
    if ok then
        STATS.ascends += 1
    end
end

local lastEvolve = 0
local function autoEvolveStep()
    if os.clock() - lastEvolve < 8 then return end
    lastEvolve = os.clock()

    local r = rem("Evolve")
    if not r then return end
    local ok = pcall(function()
        r:InvokeServer()
    end)
    if ok then
        STATS.evolves += 1
    end
end

local lastPowerUpgrade = 0
local function autoPowerUpgradeStep()
    if os.clock() - lastPowerUpgrade < 0.5 then return end
    lastPowerUpgrade = os.clock()

    local r = rem("UpgradePowerLevel")
    if not r then return end

    for _, powerName in ipairs(POWER_NAMES) do
        task.spawn(function()
            local ok = pcall(function()
                r:InvokeServer(powerName)
            end)
            if ok then
                STATS.powerUpgrades += 1
            end
        end)
    end
end

local lastOfflineCash = 0
local function autoOfflineCashStep()
    if os.clock() - lastOfflineCash < 20 then return end
    lastOfflineCash = os.clock()

    local r = rem("DoubleOfflineCash")
    if r then
        pcall(function() r:InvokeServer() end)
    end
end

local lastTimeCash = 0
local function autoTimeCashStep()
    if os.clock() - lastTimeCash < 10 then return end
    lastTimeCash = os.clock()

    local r = rem("UseTimeCash")
    if r then
        pcall(function() r:InvokeServer() end)
    end
end

local lastEarnerBoost = 0
local function autoEarnerBoostStep()
    if os.clock() - lastEarnerBoost < 10 then return end
    lastEarnerBoost = os.clock()

    local r = rem("UseEarnerBoost")
    if r then
        pcall(function() r:InvokeServer() end)
    end
end

local raceCD = false
local lastRaceCheck = 0
local function autoMinigameRaceStep()
    if raceCD or os.clock() - lastRaceCheck < 5 then return end
    lastRaceCheck = os.clock()

    local core = ReplicatedStorage:FindFirstChild("Core")
    if not core then return end
    local request = core:FindFirstChild("RemoteRequest")
    if not request then return end

    local startRF = request:FindFirstChild("MinigameRaceService.Start")
    local endRF = request:FindFirstChild("MinigameRaceService.End")
    if not startRF or not endRF then return end

    raceCD = true
    task.spawn(function()
        local ok, res = pcall(function()
            return startRF:InvokeServer()
        end)
        if ok and res then
            task.wait(0.25)
            local ended = pcall(function()
                endRF:InvokeServer(1)
            end)
            if ended then
                STATS.racesWon += 1
            end
        end
        task.wait(3)
        raceCD = false
    end)
end

local tradeCD = false
local lastTradeCheck = 0
local function autoMinigameTradeStep()
    if tradeCD or os.clock() - lastTradeCheck < 5 then return end
    lastTradeCheck = os.clock()

    local core = ReplicatedStorage:FindFirstChild("Core")
    if not core then return end
    local request = core:FindFirstChild("RemoteRequest")
    if not request then return end

    local startRF = request:FindFirstChild("MinigameTradeService.Start")
    local endRF = request:FindFirstChild("MinigameTradeService.End")
    if not startRF or not endRF then return end

    tradeCD = true
    task.spawn(function()
        local ok, res = pcall(function()
            return startRF:InvokeServer()
        end)
        if ok and res then
            task.wait(0.25)
            local ended = pcall(function()
                endRF:InvokeServer(1)
            end)
            if ended then
                STATS.tradesWon += 1
            end
        end
        task.wait(3)
        tradeCD = false
    end)
end

local lastCashVine = 0
local function autoCashVineStep()
    if os.clock() - lastCashVine < 30 then return end
    lastCashVine = os.clock()

    local map = Workspace:FindFirstChild("Map")
    if not map or not root then return end
    local sewer = map:FindFirstChild("Sewer")
    if not sewer then return end
    local cvFolder = sewer:FindFirstChild("CashVine")
    if not cvFolder then return end
    local cvModel = cvFolder:FindFirstChild("CashVine")
    if not cvModel then return end

    local useRF = cvModel:FindFirstChild("Use")
    if not useRF or not useRF:IsA("RemoteFunction") then return end

    local targetPart = cvModel:FindFirstChildOfClass("BasePart") or cvFolder:FindFirstChildOfClass("BasePart")
    local saved = root.CFrame

    if targetPart then
        pcall(function()
            root.CFrame = CFrame.new(targetPart.Position + Vector3.new(0, 3, 0))
        end)
        task.wait(0.2)
    end

    local ok = pcall(function()
        useRF:InvokeServer()
    end)
    if ok then
        STATS.vineCollected += 1
    end

    task.wait(0.2)
    pcall(function()
        if root then root.CFrame = saved end
    end)
end

--==============================================================
-- ANTI AFK
--==============================================================

connect(LocalPlayer.Idled, function()
    if not ENABLED.AntiAFK then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

task.spawn(function()
    while true do
        task.wait(900)
        if ENABLED.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end
end)

--==============================================================
-- FPS BOOST
--==============================================================

local removedObjects = {}
local fpsBoostActive = false
local savedLighting = {
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
    Brightness = Lighting.Brightness,
}

local function enableFPSBoost()
    if fpsBoostActive then return end
    fpsBoostActive = true
    table.clear(removedObjects)

    local removeClasses = {
        "Texture",
        "Decal",
        "ParticleEmitter",
        "Trail",
        "Smoke",
        "Fire",
        "Sparkles",
        "SpecialMesh",
        "SelectionBox",
        "SurfaceAppearance",
    }

    for _, obj in ipairs(Workspace:GetDescendants()) do
        for _, cls in ipairs(removeClasses) do
            if obj:IsA(cls) then
                table.insert(removedObjects, { obj = obj, parent = obj.Parent })
                obj.Parent = nil
                break
            end
        end
    end

    for _, obj in ipairs(Lighting:GetChildren()) do
        if obj:IsA("Sky")
            or obj:IsA("Atmosphere")
            or obj:IsA("BloomEffect")
            or obj:IsA("BlurEffect")
            or obj:IsA("ColorCorrectionEffect")
            or obj:IsA("SunRaysEffect")
            or obj:IsA("DepthOfFieldEffect") then

            table.insert(removedObjects, { obj = obj, parent = obj.Parent })
            obj.Parent = nil
        end
    end

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    Lighting.Brightness = 2
end

local function disableFPSBoost()
    if not fpsBoostActive then return end
    fpsBoostActive = false

    for _, entry in ipairs(removedObjects) do
        pcall(function()
            if entry.obj and entry.parent then
                entry.obj.Parent = entry.parent
            end
        end)
    end
    table.clear(removedObjects)

    Lighting.GlobalShadows = savedLighting.GlobalShadows
    Lighting.FogEnd = savedLighting.FogEnd
    Lighting.Brightness = savedLighting.Brightness
end

--==============================================================
-- CHARACTER REFRESH
--==============================================================

connect(LocalPlayer.CharacterAdded, function()
    task.wait(2)
    buildStandRFCache()
    buildWakeRFCache()
    setupPhoneOffer()
    table.clear(buyLock)
    if ENABLED.BoostFPS then
        -- Keep boost state on after respawn; no destructive re-apply is needed.
    end
end)

--==============================================================
-- UI ROOT
--==============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NEXUS_Sell_Lemon"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = PlayerGui

--==============================================================
-- MAIN WINDOW
--==============================================================

local Window = Instance.new("Frame")
Window.Name = "Window"
Window.AnchorPoint = Vector2.new(0.5, 0.5)
Window.Position = UDim2.fromScale(0.5, 0.5)
Window.Size = UDim2.fromOffset(CONFIG.WindowWidth, CONFIG.WindowHeight)
Window.BackgroundColor3 = C.Background
Window.BorderSizePixel = 0
Window.ClipsDescendants = true
Window.Parent = ScreenGui
corner(Window, 12)
stroke(Window, C.Border, 0.05, 1)

local WindowScale = Instance.new("UIScale")
WindowScale.Parent = Window

local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Size = UDim2.new(1, 0, 0, 64)
Topbar.BackgroundColor3 = C.Surface
Topbar.BorderSizePixel = 0
Topbar.Parent = Window

local TopbarLine = Instance.new("Frame")
TopbarLine.AnchorPoint = Vector2.new(0, 1)
TopbarLine.Position = UDim2.new(0, 0, 1, 0)
TopbarLine.Size = UDim2.new(1, 0, 0, 1)
TopbarLine.BackgroundColor3 = C.BorderSoft
TopbarLine.BorderSizePixel = 0
TopbarLine.Parent = Topbar

-- One-row branding: NEXUS + SELL LEMON
local Brand = Instance.new("Frame")
Brand.BackgroundTransparency = 1
Brand.Position = UDim2.fromOffset(18, 8)
Brand.Size = UDim2.new(0.72, 0, 1, -16)
Brand.Parent = Topbar

local BrandList = Instance.new("UIListLayout")
BrandList.FillDirection = Enum.FillDirection.Horizontal
BrandList.VerticalAlignment = Enum.VerticalAlignment.Center
BrandList.Padding = UDim.new(0, 9)
BrandList.Parent = Brand

local NexusLogo = makeLabel(Brand, "NEXUS", 19, C.White, true)
NexusLogo.Size = UDim2.fromOffset(68, 30)

local BrandDivider = Instance.new("Frame")
BrandDivider.Size = UDim2.fromOffset(1, 24)
BrandDivider.BackgroundColor3 = C.Border
BrandDivider.BorderSizePixel = 0
BrandDivider.Parent = Brand

local SellLemon = makeLabel(Brand, "SELL LEMON", 12, C.SubText, true)
SellLemon.Size = UDim2.new(0, 92, 0, 26)

local Controls = Instance.new("Frame")
Controls.AnchorPoint = Vector2.new(1, 0.5)
Controls.Position = UDim2.new(1, -12, 0.5, 0)
Controls.Size = UDim2.fromOffset(30, 28)
Controls.BackgroundTransparency = 1
Controls.Parent = Topbar

local function controlButton(text, bg)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.Size = UDim2.fromOffset(28, 28)
    b.Text = text
    b.TextColor3 = C.White
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.BackgroundColor3 = bg
    b.BorderSizePixel = 0
    b.Parent = Controls
    corner(b, 7)
    return b
end

local CloseButton = controlButton("×", C.Red)

--==============================================================
-- BODY / SIDEBAR
--==============================================================

local Body = Instance.new("Frame")
Body.Position = UDim2.fromOffset(0, 64)
Body.Size = UDim2.new(1, 0, 1, -64)
Body.BackgroundTransparency = 1
Body.Parent = Window

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Position = UDim2.fromOffset(0, 0)
Sidebar.Size = UDim2.new(0, 156, 1, 0)
Sidebar.BackgroundColor3 = C.Surface
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Body

local SideLine = Instance.new("Frame")
SideLine.AnchorPoint = Vector2.new(1, 0)
SideLine.Position = UDim2.new(1, 0, 0, 0)
SideLine.Size = UDim2.new(0, 1, 1, 0)
SideLine.BackgroundColor3 = C.BorderSoft
SideLine.BorderSizePixel = 0
SideLine.Parent = Sidebar

local Profile = Instance.new("Frame")
Profile.Position = UDim2.fromOffset(12, 13)
Profile.Size = UDim2.new(1, -24, 0, 62)
Profile.BackgroundColor3 = C.Surface2
Profile.BorderSizePixel = 0
Profile.Parent = Sidebar
corner(Profile, 8)
stroke(Profile, C.BorderSoft, 0.25, 1)

local Avatar = Instance.new("ImageLabel")
Avatar.Position = UDim2.fromOffset(10, 10)
Avatar.Size = UDim2.fromOffset(42, 42)
Avatar.BackgroundColor3 = C.PurpleDark
Avatar.BorderSizePixel = 0
Avatar.Parent = Profile
corner(Avatar, 9)

-- Never block UI construction on thumbnail/network loading.
task.spawn(function()
    pcall(function()
        local image, ready = Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.AvatarBust,
            Enum.ThumbnailSize.Size48x48
        )
        if ready and image and Avatar.Parent then
            Avatar.Image = image
        end
    end)
end)

local ProfileName = makeLabel(Profile, LocalPlayer.DisplayName, 12, C.Text, true)
ProfileName.Position = UDim2.fromOffset(61, 9)
ProfileName.Size = UDim2.new(1, -71, 0, 20)

local ProfileUser = makeLabel(Profile, "@" .. LocalPlayer.Name, 10, C.SubText, false)
ProfileUser.Position = UDim2.fromOffset(61, 29)
ProfileUser.Size = UDim2.new(1, -71, 0, 17)

local Nav = Instance.new("ScrollingFrame")
Nav.Position = UDim2.fromOffset(10, 88)
Nav.Size = UDim2.new(1, -20, 1, -138)
Nav.BackgroundTransparency = 1
Nav.BorderSizePixel = 0
Nav.ScrollBarThickness = 2
Nav.ScrollBarImageColor3 = C.PurpleSoft
Nav.AutomaticCanvasSize = Enum.AutomaticSize.Y
Nav.CanvasSize = UDim2.new()
Nav.Parent = Sidebar

local NavLayout = Instance.new("UIListLayout")
NavLayout.Padding = UDim.new(0, 6)
NavLayout.Parent = Nav

local SideFooter = makeLabel(Sidebar, "RCTRL  •  TOGGLE MENU", 9, C.Muted, true)
SideFooter.AnchorPoint = Vector2.new(0, 1)
SideFooter.Position = UDim2.new(0, 14, 1, -14)
SideFooter.Size = UDim2.new(1, -28, 0, 20)

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Position = UDim2.fromOffset(156, 0)
Content.Size = UDim2.new(1, -156, 1, 0)
Content.BackgroundColor3 = C.Background
Content.BorderSizePixel = 0
Content.Parent = Body

local ContentHeader = Instance.new("Frame")
ContentHeader.Position = UDim2.fromOffset(16, 12)
ContentHeader.Size = UDim2.new(1, -32, 0, 44)
ContentHeader.BackgroundTransparency = 1
ContentHeader.Parent = Content

local CurrentTabLabel = makeLabel(ContentHeader, "Farm", 17, C.White, true)
CurrentTabLabel.Position = UDim2.fromOffset(2, 0)
CurrentTabLabel.Size = UDim2.new(0.7, 0, 0, 25)

local CurrentSubLabel = makeLabel(ContentHeader, "Farm controls", 10, C.Muted, false)
CurrentSubLabel.Position = UDim2.fromOffset(2, 23)
CurrentSubLabel.Size = UDim2.new(0.8, 0, 0, 18)

local StatusDot = Instance.new("Frame")
StatusDot.AnchorPoint = Vector2.new(1, 0.5)
StatusDot.Position = UDim2.new(1, -4, 0.5, 0)
StatusDot.Size = UDim2.fromOffset(7, 7)
StatusDot.BackgroundColor3 = C.Green
StatusDot.BorderSizePixel = 0
StatusDot.Parent = ContentHeader
corner(StatusDot, 99)

local Pages = Instance.new("Frame")
Pages.Position = UDim2.fromOffset(16, 62)
Pages.Size = UDim2.new(1, -32, 1, -76)
Pages.BackgroundTransparency = 1
Pages.Parent = Content

local PagesByName = {}
local TabButtons = {}
local currentPage = nil

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.PurpleSoft
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new()
    page.Visible = false
    page.Parent = Pages

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.Parent = page

    PagesByName[name] = page
    return page
end

local function createTwoColumnHolder(parent)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 0)
    holder.AutomaticSize = Enum.AutomaticSize.Y
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local left = Instance.new("Frame")
    left.Size = UDim2.new(0.5, -5, 0, 0)
    left.AutomaticSize = Enum.AutomaticSize.Y
    left.BackgroundTransparency = 1
    left.Parent = holder

    local right = Instance.new("Frame")
    right.AnchorPoint = Vector2.new(1, 0)
    right.Position = UDim2.new(1, 0, 0, 0)
    right.Size = UDim2.new(0.5, -5, 0, 0)
    right.AutomaticSize = Enum.AutomaticSize.Y
    right.BackgroundTransparency = 1
    right.Parent = holder

    local leftLayout = Instance.new("UIListLayout")
    leftLayout.Padding = UDim.new(0, 8)
    leftLayout.Parent = left

    local rightLayout = Instance.new("UIListLayout")
    rightLayout.Padding = UDim.new(0, 8)
    rightLayout.Parent = right

    return left, right
end

local function createCard(parent, title, subtitle)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = C.Surface
    card.BorderSizePixel = 0
    card.Parent = parent
    corner(card, 9)
    stroke(card, C.BorderSoft, 0.15, 1)
    padding(card, 11, 9, 11, 9)

    local cardLayout = Instance.new("UIListLayout")
    cardLayout.FillDirection = Enum.FillDirection.Vertical
    cardLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cardLayout.Padding = UDim.new(0, 6)
    cardLayout.Parent = card

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, subtitle and 33 or 20)
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    header.LayoutOrder = 0
    header.Parent = card

    local titleLabel = makeLabel(header, title, 11, C.SubText, true)
    titleLabel.Position = UDim2.fromOffset(0, 0)
    titleLabel.Size = UDim2.new(1, 0, 0, 18)

    if subtitle then
        local sub = makeLabel(header, subtitle, 8, C.Muted, false)
        sub.Position = UDim2.fromOffset(0, 18)
        sub.Size = UDim2.new(1, 0, 0, 13)
    end

    local body = Instance.new("Frame")
    body.Size = UDim2.new(1, 0, 0, 0)
    body.AutomaticSize = Enum.AutomaticSize.Y
    body.BackgroundTransparency = 1
    body.BorderSizePixel = 0
    body.LayoutOrder = 1
    body.Parent = card

    local bodyLayout = Instance.new("UIListLayout")
    bodyLayout.FillDirection = Enum.FillDirection.Vertical
    bodyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
    bodyLayout.Padding = UDim.new(0, 7)
    bodyLayout.Parent = body

    return body
end

local function createToggle(parent, title, desc, key)
    local row = Instance.new("TextButton")
    row.AutoButtonColor = false
    row.Text = ""
    row.Size = UDim2.new(1, 0, 0, desc and 54 or 42)
    row.BackgroundColor3 = C.Surface2
    row.BorderSizePixel = 0
    row.Parent = parent
    corner(row, 7)
    local st = stroke(row, C.BorderSoft, 0.25, 1)

    local name = makeLabel(row, title, 11, C.Text, true)
    name.Position = UDim2.fromOffset(11, desc and 8 or 0)
    name.Size = UDim2.new(1, -55, 0, 19)

    if desc then
        local d = makeLabel(row, desc, 8, C.Muted, false)
        d.Position = UDim2.fromOffset(11, 28)
        d.Size = UDim2.new(1, -55, 0, 15)
    end

    local track = Instance.new("Frame")
    track.AnchorPoint = Vector2.new(1, 0.5)
    track.Position = UDim2.new(1, -10, 0.5, 0)
    track.Size = UDim2.fromOffset(34, 18)
    track.BackgroundColor3 = C.PurpleDark
    track.BorderSizePixel = 0
    track.Parent = row
    corner(track, 99)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Position = UDim2.new(0, 3, 0.5, 0)
    knob.Size = UDim2.fromOffset(12, 12)
    knob.BackgroundColor3 = C.Muted
    knob.BorderSizePixel = 0
    knob.Parent = track
    corner(knob, 99)

    local function render(state, instant)
        ENABLED[key] = state
        local targetTrack = state and C.Purple2 or C.PurpleDark
        local targetKnob = state and C.White or C.Muted
        local x = state and 19 or 3
        if instant then
            track.BackgroundColor3 = targetTrack
            knob.BackgroundColor3 = targetKnob
            knob.Position = UDim2.new(0, x, 0.5, 0)
        else
            tween(track, 0.14, { BackgroundColor3 = targetTrack })
            tween(knob, 0.14, { BackgroundColor3 = targetKnob, Position = UDim2.new(0, x, 0.5, 0) })
        end
    end

    render(false, true)

    connect(row.MouseEnter, function()
        tween(row, 0.1, { BackgroundColor3 = C.Surface3 })
    end)
    connect(row.MouseLeave, function()
        tween(row, 0.1, { BackgroundColor3 = C.Surface2 })
    end)
    connect(row.MouseButton1Click, function()
        render(not ENABLED[key])
    end)

    return {
        Row = row,
        Set = function(state)
            render(state)
        end,
        Get = function()
            return ENABLED[key]
        end,
        Stroke = st,
    }
end

local function createChoice(parent, title, options, getter, setter)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 48)
    row.BackgroundColor3 = C.Surface2
    row.BorderSizePixel = 0
    row.Parent = parent
    corner(row, 7)
    stroke(row, C.BorderSoft, 0.25, 1)

    local label = makeLabel(row, title, 10, C.Text, true)
    label.Position = UDim2.fromOffset(10, 5)
    label.Size = UDim2.new(1, 0, 0, 15)

    local buttons = {}
    local holder = Instance.new("Frame")
    holder.Position = UDim2.fromOffset(10, 23)
    holder.Size = UDim2.new(1, -20, 0, 20)
    holder.BackgroundTransparency = 1
    holder.Parent = row

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 5)
    layout.Parent = holder

    local function refresh()
        local current = getter()
        for value, button in pairs(buttons) do
            local selected = tostring(value) == tostring(current)
            button.BackgroundColor3 = selected and C.PurpleDark or C.Background
            button.TextColor3 = selected and C.White or C.SubText
        end
    end

    for _, value in ipairs(options) do
        local button = Instance.new("TextButton")
        button.AutoButtonColor = false
        button.Size = UDim2.new(0.25, -4, 1, 0)
        button.BackgroundColor3 = C.Background
        button.BorderSizePixel = 0
        button.Text = tostring(value)
        button.TextSize = 9
        button.Font = Enum.Font.GothamSemibold
        button.TextColor3 = C.SubText
        button.Parent = holder
        corner(button, 5)
        stroke(button, C.BorderSoft, 0.3, 1)
        buttons[value] = button

        connect(button.MouseButton1Click, function()
            setter(value)
            refresh()
        end)
    end

    refresh()
    return {Row = row, Refresh = refresh}
end

local function createActionButton(parent, title, callback)
    local b = makeButton(parent, title, 36)
    b.TextXAlignment = Enum.TextXAlignment.Center
    connect(b.MouseButton1Click, function()
        callback()
    end)
    return b
end

local function createValueRow(parent, title, valueGetter)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = C.Surface2
    row.BorderSizePixel = 0
    row.Parent = parent
    corner(row, 7)
    stroke(row, C.BorderSoft, 0.25, 1)

    local name = makeLabel(row, title, 10, C.SubText, true)
    name.Position = UDim2.fromOffset(10, 0)
    name.Size = UDim2.new(0.62, 0, 1, 0)

    local value = makeLabel(row, valueGetter(), 10, C.White, true)
    value.AnchorPoint = Vector2.new(1, 0)
    value.Position = UDim2.new(1, -10, 0, 0)
    value.Size = UDim2.new(0.38, -10, 1, 0)
    value.TextXAlignment = Enum.TextXAlignment.Right

    return {
        ValueLabel = value,
        Update = function()
            value.Text = tostring(valueGetter())
        end,
    }
end

local function formatDuration(seconds)
    seconds = math.max(0, math.floor(seconds + 0.5))

    if seconds < 60 then
        return tostring(seconds) .. "s"
    end

    local minutes = math.floor(seconds / 60)
    if minutes < 60 then
        return tostring(minutes) .. "m"
    end

    local hours = math.floor(minutes / 60)
    local mins = minutes % 60

    if mins == 0 then
        return tostring(hours) .. "h"
    end

    return string.format("%dh %02dm", hours, mins)
end

--==============================================================
-- PAGES
--==============================================================

local Farm = createPage("Farm")
local Progression = createPage("Progression")
local Bonus = createPage("Bonus")
local Stats = createPage("Stats")
local Settings = createPage("Settings")

-- Farm

do
    local left, right = createTwoColumnHolder(Farm)

    local c1 = createCard(left, "INCOME")
    createToggle(c1, "Auto Buy Upgrades", "Purchases enabled and visible upgrade buttons.", "AutoBuyUpgrades")
    createToggle(c1, "Auto Click Income", "Wakes all configured lemon income streams.", "AutoClick")
    createToggle(c1, "Auto Upgrade Stands", "Upgrades money-making stands in the selected batch size.", "AutoUpgradeStands")
    createChoice(c1, "Stand Upgrade Batch", {5, 25, 100, "Max"}, function() return CONFIG.StandUpgradeAmount end, function(v) CONFIG.StandUpgradeAmount = v end)
    createToggle(c1, "Auto Collect Fruit", "Sweeps LemonTree fruit and clicks detectors.", "AutoCollectFruit")

    local c2 = createCard(right, "COLLECTORS")
    createToggle(c2, "Auto Harvest Garden", "Automatically activates your garden's Collect / Harvest controls without teleporting.", "AutoHarvestGarden")
    createToggle(c2, "Auto Cash Vine", "Uses the Sewer CashVine remote.", "AutoCashVine")
    createToggle(c2, "Auto Phone Offer", "Automatically responds to phone offers.", "AutoPhoneOffer")
end

-- Progression

do
    local left, right = createTwoColumnHolder(Progression)

    local c1 = createCard(left, "PROGRESSION")
    createToggle(c1, "Auto Rebirth", "Invokes Rebirth and refreshes the tycoon cache.", "AutoRebirth")
    createToggle(c1, "Auto Ascend", "Attempts Ascend periodically.", "AutoAscend")
    createToggle(c1, "Auto Evolve", "Attempts Evolve periodically.", "AutoEvolve")

    local c2 = createCard(right, "POWER")
    createToggle(c2, "Auto Power Upgrade", "Cycles through configured power upgrade names.", "AutoPowerUpgrade")

    local explain = createCard(Progression, "REBIRTH TIMER")
    local label = makeLabel(explain, "Auto Rebirth interval", 10, C.Muted, false)
    label.Size = UDim2.new(1, 0, 0, 18)
    label.LayoutOrder = 1

    local rebirthSliderRow = Instance.new("Frame")
    rebirthSliderRow.Size = UDim2.new(1, 0, 0, 54)
    rebirthSliderRow.BackgroundColor3 = C.Surface2
    rebirthSliderRow.BorderSizePixel = 0
    rebirthSliderRow.LayoutOrder = 2
    rebirthSliderRow.Parent = explain
    corner(rebirthSliderRow, 7)
    stroke(rebirthSliderRow, C.BorderSoft, 0.25, 1)

    local rebirthSliderName = makeLabel(rebirthSliderRow, "Rebirth Every", 11, C.Text, true)
    rebirthSliderName.Position = UDim2.fromOffset(11, 7)
    rebirthSliderName.Size = UDim2.new(0.55, 0, 0, 18)

    local rebirthSliderValue = makeLabel(rebirthSliderRow, formatDuration(CONFIG.RebirthInterval), 10, C.Purple, true)
    rebirthSliderValue.AnchorPoint = Vector2.new(1, 0)
    rebirthSliderValue.Position = UDim2.new(1, -11, 0, 7)
    rebirthSliderValue.Size = UDim2.fromOffset(70, 18)
    rebirthSliderValue.TextXAlignment = Enum.TextXAlignment.Right

    local rebirthTrack = Instance.new("Frame")
    rebirthTrack.Position = UDim2.fromOffset(11, 33)
    rebirthTrack.Size = UDim2.new(1, -22, 0, 6)
    rebirthTrack.BackgroundColor3 = C.PurpleDark
    rebirthTrack.BorderSizePixel = 0
    rebirthTrack.Parent = rebirthSliderRow
    corner(rebirthTrack, 99)

    local rebirthFill = Instance.new("Frame")
    rebirthFill.Size = UDim2.new((CONFIG.RebirthInterval - 60) / (14400 - 60), 0, 1, 0)
    rebirthFill.BackgroundColor3 = C.Purple2
    rebirthFill.BorderSizePixel = 0
    rebirthFill.Parent = rebirthTrack
    corner(rebirthFill, 99)

    local rebirthDrag = Instance.new("TextButton")
    rebirthDrag.BackgroundTransparency = 1
    rebirthDrag.Text = ""
    rebirthDrag.Size = UDim2.new(1, 12, 1, 16)
    rebirthDrag.Position = UDim2.fromOffset(-6, -5)
    rebirthDrag.Parent = rebirthTrack

    local draggingRebirthSlider = false

    local function updateRebirthSlider(x)
        local rel = math.clamp(
            (x - rebirthTrack.AbsolutePosition.X) / math.max(rebirthTrack.AbsoluteSize.X, 1),
            0, 1
        )

        -- 1 minute .. 4 hours. Snap to whole minutes for predictable timing.
        local value = math.floor((60 + rel * (14400 - 60)) / 60 + 0.5) * 60
        value = math.clamp(value, 60, 14400)

        CONFIG.RebirthInterval = value
        rebirthSliderValue.Text = formatDuration(value)
        rebirthFill.Size = UDim2.new((value - 60) / (14400 - 60), 0, 1, 0)

        -- If the slider is changed while Auto Rebirth is enabled,
        -- keep the next cycle measured from the latest setting point.
        if ENABLED.AutoRebirth then
            lastRebirthTime = os.clock()
        end
    end

    connect(rebirthDrag.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            draggingRebirthSlider = true
            updateRebirthSlider(input.Position.X)
        end
    end)

    connect(UserInputService.InputChanged, function(input)
        if draggingRebirthSlider
        and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            updateRebirthSlider(input.Position.X)
        end
    end)

    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            draggingRebirthSlider = false
        end
    end)

    local explain2 = createCard(Progression, "REMOTE TARGETS")
    local label2 = makeLabel(explain2, "Rebirth • Ascend • Evolve • UpgradePowerLevel", 10, C.Muted, false)
    label2.Size = UDim2.new(1, 0, 0, 22)
    label2.LayoutOrder = 1
end

-- Bonus

do
    local left, right = createTwoColumnHolder(Bonus)

    local c1 = createCard(left, "CASH BOOSTS")
    createToggle(c1, "Auto Double Offline Cash", "Uses DoubleOfflineCash periodically.", "AutoOfflineCash")
    createToggle(c1, "Auto Use Time Cash", "Uses UseTimeCash periodically.", "AutoTimeCash")
    createToggle(c1, "Auto Use Earner Boost", "Uses UseEarnerBoost periodically.", "AutoEarnerBoost")

    local c2 = createCard(right, "MINIGAMES")
    createToggle(c2, "Auto Minigame Race", "Starts and ends the race automatically.", "AutoMinigameRace")
    createToggle(c2, "Auto Minigame Trade", "Starts and ends the trade automatically.", "AutoMinigameTrade")
end

-- Stats

do
    local left, right = createTwoColumnHolder(Stats)

    local c1 = createCard(left, "ACTIVITY")
    local sUpg = createValueRow(c1, "UPGRADES BOUGHT", function() return STATS.upgradesBought end)
    local sClick = createValueRow(c1, "INCOME CLICKS", function() return STATS.clicks end)
    local sStands = createValueRow(c1, "STANDS UPGRADED", function() return STATS.standsUpgraded end)
    local sFruit = createValueRow(c1, "FRUIT COLLECTED", function() return STATS.fruitCollected end)
    local sGarden = createValueRow(c1, "GARDEN HARVESTS", function() return STATS.gardenHarvests end)
    local sPhone = createValueRow(c1, "PHONE OFFERS", function() return STATS.phoneOffers end)
    local sVine = createValueRow(c1, "VINE COLLECTED", function() return STATS.vineCollected end)

    local c2 = createCard(right, "PROGRESSION")
    local sCash = createValueRow(c2, "CASH", function() return math.floor(getCash()) end)
    local sRebirths = createValueRow(c2, "REBIRTHS", function() return STATS.rebirths end)
    local sAscends = createValueRow(c2, "ASCENDS", function() return STATS.ascends end)
    local sEvolves = createValueRow(c2, "EVOLVES", function() return STATS.evolves end)
    local sPower = createValueRow(c2, "POWER UPGRADES", function() return STATS.powerUpgrades end)
    local sRaces = createValueRow(c2, "RACES WON", function() return STATS.racesWon end)
    local sTrades = createValueRow(c2, "TRADES WON", function() return STATS.tradesWon end)

    task.spawn(function()
        while ScreenGui.Parent do
            task.wait(1)
            pcall(function()
                sUpg.Update()
                sClick.Update()
                sStands.Update()
                sFruit.Update()
                sGarden.Update()
                sPhone.Update()
                sVine.Update()
                sCash.Update()
                sRebirths.Update()
                sAscends.Update()
                sEvolves.Update()
                sPower.Update()
                sRaces.Update()
                sTrades.Update()
            end)
        end
    end)
end

-- Settings

do
    local general = createCard(Settings, "GENERAL")

    local sliderRow = Instance.new("Frame")
    sliderRow.Size = UDim2.new(1, 0, 0, 54)
    sliderRow.BackgroundColor3 = C.Surface2
    sliderRow.BorderSizePixel = 0
    sliderRow.Parent = general
    corner(sliderRow, 7)
    stroke(sliderRow, C.BorderSoft, 0.25, 1)

    local sliderName = makeLabel(sliderRow, "Fruit Sweep Delay", 11, C.Text, true)
    sliderName.Position = UDim2.fromOffset(11, 7)
    sliderName.Size = UDim2.new(0.55, 0, 0, 18)

    local sliderValue = makeLabel(sliderRow, tostring(CONFIG.FruitSweepDelay) .. "s", 10, C.Purple, true)
    sliderValue.AnchorPoint = Vector2.new(1, 0)
    sliderValue.Position = UDim2.new(1, -11, 0, 7)
    sliderValue.Size = UDim2.fromOffset(50, 18)
    sliderValue.TextXAlignment = Enum.TextXAlignment.Right

    local sliderTrack = Instance.new("Frame")
    sliderTrack.Position = UDim2.fromOffset(11, 33)
    sliderTrack.Size = UDim2.new(1, -22, 0, 6)
    sliderTrack.BackgroundColor3 = C.PurpleDark
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = sliderRow
    corner(sliderTrack, 99)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((CONFIG.FruitSweepDelay - 2) / 28, 0, 1, 0)
    sliderFill.BackgroundColor3 = C.Purple2
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack
    corner(sliderFill, 99)

    local sliderDrag = Instance.new("TextButton")
    sliderDrag.BackgroundTransparency = 1
    sliderDrag.Text = ""
    sliderDrag.Size = UDim2.new(1, 12, 1, 16)
    sliderDrag.Position = UDim2.fromOffset(-6, -5)
    sliderDrag.Parent = sliderTrack

    local draggingSlider = false
    local function updateSlider(x)
        local rel = math.clamp((x - sliderTrack.AbsolutePosition.X) / math.max(sliderTrack.AbsoluteSize.X, 1), 0, 1)
        local value = math.floor(2 + rel * 28 + 0.5)
        CONFIG.FruitSweepDelay = value
        sliderValue.Text = tostring(value) .. "s"
        sliderFill.Size = UDim2.new((value - 2) / 28, 0, 1, 0)
    end

    connect(sliderDrag.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            updateSlider(input.Position.X)
        end
    end)
    connect(UserInputService.InputChanged, function(input)
        if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position.X)
        end
    end)
    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end)

    local phoneCard = createCard(Settings, "PHONE OFFER RESPONSE")
    local phoneButtons = Instance.new("Frame")
    phoneButtons.Size = UDim2.new(1, 0, 0, 38)
    phoneButtons.BackgroundTransparency = 1
    phoneButtons.Parent = phoneCard

    local phoneLayout = Instance.new("UIListLayout")
    phoneLayout.FillDirection = Enum.FillDirection.Horizontal
    phoneLayout.Padding = UDim.new(0, 7)
    phoneLayout.Parent = phoneButtons

    local phoneOptions = {}
    for _, option in ipairs(PHONE_OFFER_RESPONSES) do
        local b = Instance.new("TextButton")
        b.AutoButtonColor = false
        b.Size = UDim2.new(1/3, -5, 1, 0)
        b.BackgroundColor3 = option == CONFIG.PhoneOfferResponse and C.PurpleDark or C.Surface2
        b.BorderSizePixel = 0
        b.Text = option
        b.TextColor3 = C.Text
        b.TextSize = 10
        b.Font = Enum.Font.GothamSemibold
        b.Parent = phoneButtons
        corner(b, 7)
        stroke(b, option == CONFIG.PhoneOfferResponse and C.PurpleSoft or C.BorderSoft, 0.2, 1)
        phoneOptions[option] = b

        connect(b.MouseButton1Click, function()
            CONFIG.PhoneOfferResponse = option
            for name, btn in pairs(phoneOptions) do
                local selected = name == option
                tween(btn, 0.12, {
                    BackgroundColor3 = selected and C.PurpleDark or C.Surface2
                })
            end
            if ENABLED.AutoPhoneOffer and activeOffer then
                offerHandled = false
                respondToOffer()
            end
        end)
    end

    local misc = createCard(Settings, "SYSTEM")
    createToggle(misc, "Anti-AFK", "Prevents Roblox idle disconnect behavior.", "AntiAFK")
    local fpsToggle = createToggle(misc, "Boost FPS", "Removes selected visual effects and reduces lighting load.", "BoostFPS")
    connect(fpsToggle.Row.MouseButton1Click, function()
        -- The toggle callback itself is driven by createToggle; mirror the state to graphics here.
        task.defer(function()
            if ENABLED.BoostFPS then
                enableFPSBoost()
            else
                disableFPSBoost()
            end
        end)
    end)
end

--==============================================================
-- NAVIGATION
--==============================================================

local NavItems = {
    { "Farm", "FARM" },
    { "Progression", "PROGRESSION" },
    { "Bonus", "BONUS" },
    { "Stats", "STATS" },
    { "Settings", "SETTINGS" },
}

local function selectPage(name)
    for pageName, page in pairs(PagesByName) do
        page.Visible = pageName == name
    end

    for buttonName, data in pairs(TabButtons) do
        local selected = buttonName == name
        tween(data.Button, 0.12, {
            BackgroundColor3 = selected and C.Surface2 or C.Surface,
        })
        data.Button.TextColor3 = selected and C.White or C.SubText
        tween(data.Stroke, 0.12, {
            Transparency = selected and 0.18 or 0.55,
        })
    end

    CurrentTabLabel.Text = name
    CurrentSubLabel.Text = name .. " controls"
    currentPage = name
end

for _, item in ipairs(NavItems) do
    local name = item[1]
    local hint = item[2]

    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.Text = name
    b.TextColor3 = C.SubText
    b.TextSize = 10
    b.Font = Enum.Font.GothamSemibold
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Size = UDim2.new(1, 0, 0, 37)
    b.BackgroundColor3 = C.Surface
    b.BorderSizePixel = 0
    b.Parent = Nav
    corner(b, 7)

    local hintLabel = makeLabel(b, hint, 7, C.Muted, true)
    hintLabel.AnchorPoint = Vector2.new(1, 0.5)
    hintLabel.Position = UDim2.new(1, -9, 0.5, 0)
    hintLabel.Size = UDim2.fromOffset(53, 16)
    hintLabel.TextXAlignment = Enum.TextXAlignment.Right

    padding(b, 10, 0, 6, 0)

    TabButtons[name] = {
        Button = b,
        Stroke = stroke(b, C.BorderSoft, 0.25, 1),
    }

    connect(b.MouseEnter, function()
        if currentPage ~= name then
            tween(b, 0.1, { BackgroundColor3 = C.Surface3 })
        end
    end)
    connect(b.MouseLeave, function()
        if currentPage ~= name then
            tween(b, 0.1, { BackgroundColor3 = C.Surface })
        end
    end)
    connect(b.MouseButton1Click, function()
        selectPage(name)
    end)
end

selectPage("Farm")

--==============================================================
-- DRAGGING — CLAMPED TO SCREEN
--==============================================================

local windowWasMoved = false
local dragging = false
local dragStart = nil
local startPosition = nil

local function clampWindowPosition(target)
    local camera = Workspace.CurrentCamera
    if not camera then return target end

    local viewport = camera.ViewportSize
    local size = Window.AbsoluteSize
    local halfX = size.X * 0.5
    local halfY = size.Y * 0.5

    local x = math.clamp(target.X.Offset, halfX, viewport.X - halfX)
    local y = math.clamp(target.Y.Offset, halfY, viewport.Y - halfY)
    return UDim2.fromOffset(x, y)
end

local function updateDrag(input)
    if not dragging or not dragStart or not startPosition then return end
    local delta = input.Position - dragStart
    Window.Position = clampWindowPosition(UDim2.fromOffset(
        startPosition.X.Offset + delta.X,
        startPosition.Y.Offset + delta.Y
    ))
end

local function pointInside(guiObject, point)
    local p = guiObject.AbsolutePosition
    local s = guiObject.AbsoluteSize
    return point.X >= p.X and point.X <= p.X + s.X
        and point.Y >= p.Y and point.Y <= p.Y + s.Y
end

connect(Topbar.InputBegan, function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end
    if pointInside(CloseButton, input.Position) then
        return
    end
    dragging = true
    windowWasMoved = true
    dragStart = input.Position
    startPosition = Window.Position
end)

connect(UserInputService.InputChanged, function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        updateDrag(input)
    end
end)

connect(UserInputService.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

--==============================================================
-- VIEWPORT FIT
--==============================================================

local function fitToViewport(centerIfNotMoved)
    local camera = Workspace.CurrentCamera
    if not camera then return end

    local vp = camera.ViewportSize
    local targetW = math.min(CONFIG.WindowWidth, math.max(CONFIG.MinWindowWidth, vp.X - 18))
    local targetH = math.min(CONFIG.WindowHeight, math.max(CONFIG.MinWindowHeight, vp.Y - 18))

    Window.Size = UDim2.fromOffset(targetW, targetH)

    -- Keep text readable on narrow phones without re-scaling the whole desktop layout aggressively.
    WindowScale.Scale = targetW < 420 and math.clamp(targetW / 420, 0.9, 1) or 1

    if centerIfNotMoved and not windowWasMoved then
        Window.Position = UDim2.fromOffset(math.floor(vp.X * 0.5), math.floor(vp.Y * 0.5))
    else
        Window.Position = clampWindowPosition(Window.Position)
    end
end

if Workspace.CurrentCamera then
    fitToViewport(true)
    connect(Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function() fitToViewport(not windowWasMoved) end)
end

connect(Workspace:GetPropertyChangedSignal("CurrentCamera"), function()
    task.defer(function()
        fitToViewport(not windowWasMoved)
        local camera = Workspace.CurrentCamera
        if camera then
            connect(camera:GetPropertyChangedSignal("ViewportSize"), function() fitToViewport(not windowWasMoved) end)
        end
    end)
end)

local currentFPS = 60
do
    local frames = 0
    local elapsed = 0
    connect(RunService.RenderStepped, function(dt)
        frames += 1
        elapsed += dt
        if elapsed >= 0.5 then
            currentFPS = frames / elapsed
            frames = 0
            elapsed = 0
        end
    end)
end

--==============================================================
-- CLOSE / OPEN BUTTON / KEYBIND
--==============================================================

-- Small, fixed top-center status button. It is intentionally NOT draggable.
local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.AnchorPoint = Vector2.new(0.5, 0)
OpenButton.Position = UDim2.fromScale(0.5, 0.015)
OpenButton.Size = UDim2.fromOffset(196, 30)
OpenButton.BackgroundColor3 = C.Surface
OpenButton.BorderSizePixel = 0
OpenButton.Text = ""
OpenButton.Visible = false
OpenButton.Parent = ScreenGui
corner(OpenButton, 9)
stroke(OpenButton, C.BorderSoft, 0.12, 1)

local StatusName = makeLabel(OpenButton, LocalPlayer.DisplayName, 9, C.Text, true)
StatusName.Position = UDim2.fromOffset(10, 0)
StatusName.Size = UDim2.new(0.45, -10, 1, 0)
StatusName.TextTruncate = Enum.TextTruncate.AtEnd

local StatusDivider1 = Instance.new("Frame")
StatusDivider1.Position = UDim2.new(0.47, 0, 0.25, 0)
StatusDivider1.Size = UDim2.new(0, 1, 0.5, 0)
StatusDivider1.BackgroundColor3 = C.BorderSoft
StatusDivider1.BorderSizePixel = 0
StatusDivider1.Parent = OpenButton

local StatusPing = makeLabel(OpenButton, "PING 0", 8, C.SubText, true)
StatusPing.Position = UDim2.new(0.5, 6, 0, 0)
StatusPing.Size = UDim2.new(0.22, -6, 1, 0)
StatusPing.TextXAlignment = Enum.TextXAlignment.Center

local StatusDivider2 = Instance.new("Frame")
StatusDivider2.Position = UDim2.new(0.73, 0, 0.25, 0)
StatusDivider2.Size = UDim2.new(0, 1, 0.5, 0)
StatusDivider2.BackgroundColor3 = C.BorderSoft
StatusDivider2.BorderSizePixel = 0
StatusDivider2.Parent = OpenButton

local StatusFPS = makeLabel(OpenButton, "FPS 0", 8, C.Purple, true)
StatusFPS.Position = UDim2.new(0.76, 4, 0, 0)
StatusFPS.Size = UDim2.new(0.24, -8, 1, 0)
StatusFPS.TextXAlignment = Enum.TextXAlignment.Center

local function updateTopStatus()
    local ping = 0
    pcall(function()
        local stats = game:GetService("Stats")
        local item = stats.Network.ServerStatsItem["Data Ping"]
        if item then
            local raw = item:GetValueString()
            ping = tonumber(string.match(raw, "[%d%.]+")) or 0
        end
    end)
    StatusPing.Text = "PING " .. math.floor(ping)
    StatusFPS.Text = "FPS " .. math.floor(currentFPS + 0.5)
end

local windowVisible = true

local function setWindowVisible(state)
    windowVisible = state
    Window.Visible = state
    OpenButton.Visible = not state
    if state then
        fitToViewport(false)
    end
end

connect(OpenButton.MouseButton1Click, function()
    setWindowVisible(true)
end)

connect(OpenButton.MouseEnter, function()
    tween(OpenButton, 0.12, { BackgroundColor3 = C.Surface2 })
end)
connect(OpenButton.MouseLeave, function()
    tween(OpenButton, 0.12, { BackgroundColor3 = C.Surface })
end)

connect(CloseButton.MouseButton1Click, function()
    setWindowVisible(false)
end)

connect(UserInputService.InputBegan, function(input, processed)
    if processed then return end
    if input.KeyCode == CONFIG.DragKey then
        setWindowVisible(not windowVisible)
    end
end)

-- Top-center status updater.
updateTopStatus()

local statusClock = 0
connect(RunService.RenderStepped, function(dt)
    statusClock += dt
    if statusClock >= 0.5 then
        statusClock = 0
        updateTopStatus()
    end
end)

--==============================================================
-- MAIN AUTOMATION LOOP
--==============================================================

task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.08)

        if ENABLED.AutoBuyUpgrades then
            pcall(autoBuyUpgradesStep)
        end

        if ENABLED.AutoUpgradeStands then
            pcall(autoUpgradeStandsStep)
        end

        if ENABLED.AutoClick then
            pcall(autoClickStep)
        end

        if ENABLED.AutoRebirth then
            pcall(autoRebirthStep)
        end

        if ENABLED.AutoAscend then
            pcall(autoAscendStep)
        end

        if ENABLED.AutoEvolve then
            pcall(autoEvolveStep)
        end

        if ENABLED.AutoPowerUpgrade then
            pcall(autoPowerUpgradeStep)
        end

        if ENABLED.AutoOfflineCash then
            pcall(autoOfflineCashStep)
        end

        if ENABLED.AutoTimeCash then
            pcall(autoTimeCashStep)
        end

        if ENABLED.AutoEarnerBoost then
            pcall(autoEarnerBoostStep)
        end

        if ENABLED.AutoMinigameRace then
            pcall(autoMinigameRaceStep)
        end

        if ENABLED.AutoMinigameTrade then
            pcall(autoMinigameTradeStep)
        end

        if ENABLED.AutoCashVine then
            pcall(autoCashVineStep)
        end

        if ENABLED.AutoPhoneOffer and activeOffer and not offerHandled then
            pcall(respondToOffer)
        end
    end
end)

-- Garden harvest uses direct interactions and never changes character position.
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(0.20)
        if ENABLED.AutoHarvestGarden then
            pcall(autoHarvestGardenStep, gardenDirty)
        end
    end
end)

-- Fruit cycle is deliberately separate so the sweep delay slider is respected.
task.spawn(function()
    while ScreenGui.Parent do
        task.wait(math.max(2, CONFIG.FruitSweepDelay))
        if ENABLED.AutoCollectFruit then
            pcall(autoCollectFruitStep)
        end
    end
end)

--==============================================================
-- INITIAL CACHE
--==============================================================

task.spawn(function()
    task.wait(1)
    buildStandRFCache()
    buildWakeRFCache()
    setupPhoneOffer()
end)

--==============================================================
-- SIMPLE START MARK
--==============================================================

pcall(function()
    StatusDot.BackgroundColor3 = C.Green
end)

print("NEXUS • SELL LEMON loaded")
