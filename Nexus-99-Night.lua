--[[
    NEXUS 99 NIGHT
    Standalone custom hub for 99 Nights in the Forest.

    - No key system
    - No external HttpGet/loadstring
    - No external UI libraries
    - No dependency on GitHub or other loaders

    This implementation recreates common 99 Nights utility features
    in a standalone Nexus UI. Game-specific remote APIs can change,
    so features that depend on the game's current networking may need
    small adjustments after game updates.
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

local Nexus = {
    Connections = {},
    Drawings = {},
    Highlights = {},
    Threads = {},
    CombatBusy = {},
    CombatClock = 0,
    TreeHitCount = 0,
    FrozenEnemies = {},
    DeathRecords = {},
    EnemyHooked = {},
    KillAllBusy = false,
    TreeClock = 0,
    UIVisible = true,
    Original = {
        WalkSpeed = 16,
        JumpPower = 50,
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
    },
    State = {
        ESPPlayers = false,
        ESPEnemies = false,
        ESPItems = false,
        ESPChests = false,
        ESPChildren = false,
        KillAura = false,
        TreeAura = false,
        AutoChop = false,
        AutoEat = false,
        AutoHeal = false,
        AutoFuel = false,
        CampfireZoneFeed = false,
        BringItems = false,
        BringTrees = false,
        BringChopped = false,
        AutoPlant = false,
        AutoCook = false,
        Speed = false,
        Fly = false,
        Noclip = false,
        InfiniteJump = false,
        Fullbright = false,
        NoFog = false,
        InstantInteract = false,
        AntiAFK = false,
        FreezeEnemies = false,
        GodMode = false,
    },
    Settings = {
        KillAuraRadius = 35,
        TreeRadius = 1000,
        BringRadius = 500,
        WalkSpeed = 32,
        FlySpeed = 55,
        SelectedItem = "Log",
        AutoEatThreshold = 40,
        AutoHealThreshold = 55,
    },
    Cache = {
        StatValues = {},
        StatScanAt = 0,
        Campfire = nil,
        CampfireScanAt = 0,
        WorldCandidates = {},
        WorldScanAt = 0,
        CombatContainer = nil,
        CombatContainerScanAt = 0,
    },
    Tick = {
        Combat = 0,
        Tree = 0,
        Survival = 0,
        Bring = 0,
        Freeze = 0,
    },
    Running = true
}

local function safeCall(fn, ...)
    local ok, a, b, c = pcall(fn, ...)
    if ok then
        return a, b, c
    end
    return nil, nil, nil
end

local function connect(signal, fn)
    local c = signal:Connect(function(...)
        safeCall(fn, ...)
    end)
    table.insert(Nexus.Connections, c)
    return c
end

local function destroyConnection(c)
    if c then
        pcall(function() c:Disconnect() end)
    end
end

local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local c = getCharacter()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local c = getCharacter()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getTool()
    local c = getCharacter()
    if c then
        for _, v in ipairs(c:GetChildren()) do
            if v:IsA("Tool") then
                return v
            end
        end
    end
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, v in ipairs(backpack:GetChildren()) do
            if v:IsA("Tool") then
                return v
            end
        end
    end
end

local function equipTool(predicate)
    local character = getCharacter()
    local humanoid = getHumanoid()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not character or not humanoid or not backpack then
        return nil
    end

    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and predicate(tool) then
            return tool
        end
    end

    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and predicate(tool) then
            pcall(function()
                humanoid:EquipTool(tool)
            end)
            return tool
        end
    end
end

local function activateTool(predicate)
    local tool = equipTool(predicate or function() return true end)
    if tool then
        pcall(function()
            tool:Activate()
        end)
        return tool
    end
end

local function lowerName(obj)
    return string.lower(obj.Name or "")
end

local function matchesAny(name, list)
    name = string.lower(name or "")
    for _, s in ipairs(list) do
        if string.find(name, string.lower(s), 1, true) then
            return true
        end
    end
    return false
end

local function getPivot(obj)
    if obj:IsA("BasePart") then
        return obj.CFrame
    elseif obj:IsA("Model") then
        return obj:GetPivot()
    end
end

local function setPivot(obj, cf)
    if obj:IsA("BasePart") then
        obj.CFrame = cf
        return true
    elseif obj:IsA("Model") then
        pcall(function()
            obj:PivotTo(cf)
        end)
        return true
    end
    return false
end

local function isAliveModel(model)
    if not model or not model:IsA("Model") then
        return false
    end
    local hum = model:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function closestDescendant(predicate, maxDistance)
    local root = getRoot()
    if not root then
        return nil, math.huge
    end

    local best, bestDist = nil, maxDistance or math.huge
    local function inspect(container)
        for _, obj in ipairs(container:GetChildren()) do
            local ok = safeCall(predicate, obj)
            if ok then
                local cf = getPivot(obj)
                if cf then
                    local d = (cf.Position - root.Position).Magnitude
                    if d < bestDist then
                        best, bestDist = obj, d
                    end
                end
            end
        end
    end

    inspect(Workspace)
    for _, name in ipairs({"Map", "Characters", "Items", "DroppedItems", "Resources", "Interactions", "Deployables"}) do
        local folder = Workspace:FindFirstChild(name)
        if folder then
            inspect(folder)
        end
    end

    return best, bestDist
end

local function teleportToObject(obj, offset)
    local root = getRoot()
    local cf = obj and getPivot(obj)
    if not root or not cf then
        return false
    end
    root.CFrame = cf * CFrame.new(offset or 0, 3, offset and 0 or 0)
    return true
end

local function findByNameTerms(terms, maxDistance)
    return closestDescendant(function(obj)
        return matchesAny(obj.Name, terms)
            and (obj:IsA("BasePart") or obj:IsA("Model"))
    end, maxDistance)
end

--////////////////////////////////////////////////////////////////
--  ESP
--////////////////////////////////////////////////////////////////

local function removeHighlight(obj)
    local h = Nexus.Highlights[obj]
    if h then
        pcall(function() h:Destroy() end)
        Nexus.Highlights[obj] = nil
    end
end

local function addHighlight(obj, fill, outline)
    if not obj or not obj.Parent then
        return
    end
    if Nexus.Highlights[obj] then
        return
    end

    local h = Instance.new("Highlight")
    h.Name = "Nexus99_ESP"
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.FillTransparency = 0.68
    h.OutlineTransparency = 0.05
    h.FillColor = fill
    h.OutlineColor = outline or fill
    h.Adornee = obj:IsA("Model") and obj or (obj:IsA("BasePart") and obj)
    h.Parent = obj:IsA("Model") and obj or Workspace
    Nexus.Highlights[obj] = h
end

local function clearESP()
    for obj, h in pairs(Nexus.Highlights) do
        pcall(function() h:Destroy() end)
        Nexus.Highlights[obj] = nil
    end
end

local EnemyNames = {
    "wolf", "alpha wolf", "bear", "polar bear", "cultist",
    "crossbow cultist", "moose", "deer", "mammoth", "scav",
    "scavenger", "raider", "alien", "monster", "thing", "husk",
    "goblin", "bunny"
}

local ItemNames = {
    "log", "coal", "scrap", "food", "meat", "morsel", "berry",
    "bandage", "medkit", "flower", "ammo", "bullet", "fuel",
    "fuel tank", "pellet", "wood", "sapling", "stone", "bolt",
    "armor", "gun", "weapon", "key", "gem", "diamond"
}

local ChestNames = {"chest", "crate", "box", "frog chest", "gold chest"}
local ChildNames = {"child", "lost child", "missing child"}

local function refreshESP()
    clearESP()

    local wanted = {
        player = Nexus.State.ESPPlayers,
        enemy = Nexus.State.ESPEnemies,
        item = Nexus.State.ESPItems,
        chest = Nexus.State.ESPChests,
        child = Nexus.State.ESPChildren,
    }
    if not (wanted.player or wanted.enemy or wanted.item or wanted.chest or wanted.child) then return end

    if wanted.player then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                addHighlight(plr.Character, Color3.fromRGB(70, 155, 255), Color3.fromRGB(160, 210, 255))
            end
        end
    end

    local seen = {}
    local function inspect(container)
        for _, obj in ipairs(container:GetChildren()) do
            if not seen[obj] then
                seen[obj] = true
                local n = lowerName(obj)
                if wanted.enemy and isAliveModel(obj) and (matchesAny(n, EnemyNames) or obj:GetAttribute("Enemy") == true) then
                    addHighlight(obj, Color3.fromRGB(255, 75, 75), Color3.fromRGB(255, 180, 180))
                elseif wanted.item and (obj:IsA("Model") or obj:IsA("BasePart")) and matchesAny(n, ItemNames) then
                    addHighlight(obj, Color3.fromRGB(85, 255, 125), Color3.fromRGB(185, 255, 200))
                elseif wanted.chest and (obj:IsA("Model") or obj:IsA("BasePart")) and matchesAny(n, ChestNames) then
                    addHighlight(obj, Color3.fromRGB(255, 205, 70), Color3.fromRGB(255, 238, 150))
                elseif wanted.child and (obj:IsA("Model") or obj:IsA("BasePart")) and matchesAny(n, ChildNames) then
                    addHighlight(obj, Color3.fromRGB(215, 115, 255), Color3.fromRGB(240, 185, 255))
                end
            end
        end
    end

    inspect(Workspace)
    local combat = Workspace:FindFirstChild("Characters")
    if combat then inspect(combat) end
    for _, name in ipairs({"Map", "Items", "DroppedItems", "Resources", "Interactions", "Deployables", "Loot", "Chests"}) do
        local folder = Workspace:FindFirstChild(name)
        if folder then inspect(folder) end
    end
end

--////////////////////////////////////////////////////////////////
--  GAMEPLAY HELPERS
--////////////////////////////////////////////////////////////////

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function getRemoteFolder()
    local folder = ReplicatedStorage:FindFirstChild("RemoteEvents")
    if folder then return folder end
    return ReplicatedStorage:FindFirstChild("RemoteEvent")
end

local function getRemote(name)
    local folder = getRemoteFolder()
    if not folder then return nil end
    return folder:FindFirstChild(name)
end

local function getDamageRemote()
    return getRemote("ToolDamageObject")
end

local function getDragRemotes()
    return getRemote("RequestStartDraggingItem"), getRemote("StopDraggingItem")
end

local ToolDamageIDs = {
    ["Old Axe"] = "3_7367831688",
    ["Good Axe"] = "112_7367831688",
    ["Strong Axe"] = "116_7367831688",
    ["Chainsaw"] = "647_8992824875",
    ["Spear"] = "196_8999010016",
}

local CombatWeaponNames = {
    "Old Axe", "Good Axe", "Strong Axe", "Chainsaw", "Spear",
    "Corrupted Axe", "Morningstar", "Infernal Sword", "Scythe",
    "Bouncing Blade", "Kunai", "Crossbow", "Tactial Shotgun", "Raygun"
}

local CombatEnemyNames = {
    "Alien", "Alpha Wolf", "Wolf", "Crossbow Cultist", "Cultist",
    "Bunny", "Rabbit", "Bear", "Polar Bear", "Mammoth", "Moose",
    "Scavenger", "Scav", "Husky", "Deer", "Thing", "The Deer",
    "Goblin", "Raider", "Monster", "Husk", "Chicken", "Pig", "Rat",
    "Fox", "Animal"
}

local FriendlyNPCNames = {
    "trader", "caravan", "survivor", "builder", "merchant", "crafting bench",
    "lost child", "lost child2", "lost child3", "lost child4", "dino kid", "kraken kid", "squid kid", "koala kid"
}

local EnemyDropNames = {
    "morsel", "steak", "raw meat", "cooked morsel", "cooked steak", "ribs",
    "hide", "fur", "pelt", "leather", "claw", "tooth", "fang", "bone",
    "horn", "antler", "feather", "shell", "gland", "organ", "drop", "loot",
    "scrap", "ammo", "bullet", "bolt", "alpha wolf corpse", "wolf corpse",
    "bear corpse", "cultist", "crossbow cultist", "corpse"
}

local TreeObjectNames = {
    "small tree", "treebig1", "treebig2", "treebig3", "treebig",
    "corrupted small tree", "corrupted treebig1", "corrupted treebig2", "corrupted treebig3",
    "snowy small tree", "snow tree", "fairy small tree", "fairytreebig1", "fairytreebig2",
    "fairytreebig3", "dead tree", "tree"
}

local ExactTeleportPaths = {
    Campfire = function()
        local map = Workspace:FindFirstChild("Map")
        local campground = map and map:FindFirstChild("Campground")
        return campground and (campground:FindFirstChild("InnerTouchZone") or campground:FindFirstChild("MainFire"))
    end,
    CraftingBench = function()
        local map = Workspace:FindFirstChild("Map")
        local campground = map and map:FindFirstChild("Campground")
        return campground and campground:FindFirstChild("CraftingBench")
    end,
    Biofuel = function()
        local structures = Workspace:FindFirstChild("Structures")
        return structures and structures:FindFirstChild("Biofuel Processor")
    end,
    CrockPot = function()
        local structures = Workspace:FindFirstChild("Structures")
        return structures and structures:FindFirstChild("Crock Pot")
    end,
}

local function getInventory()
    return LocalPlayer:FindFirstChild("Inventory")
end

local function getCombatWeapon()
    local character = getCharacter()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local inventory = getInventory()
    local best, bestScore = nil, -math.huge

    local function consider(item)
        if not item or not item.Parent then return end
        if not matchesAny(item.Name, CombatWeaponNames) then return end
        local score = tonumber(item:GetAttribute("WeaponDamage")) or tonumber(item:GetAttribute("WeaponResourceDamage")) or 0
        local priority = ({
            ["Chainsaw"] = 140, ["Strong Axe"] = 130, ["Good Axe"] = 120, ["Old Axe"] = 100,
            ["Infernal Sword"] = 120, ["Scythe"] = 115, ["Morningstar"] = 110, ["Spear"] = 90
        })[item.Name] or 50
        score = score + priority
        if character and item.Parent == character then score = score + 1000 end
        if score > bestScore then
            best, bestScore = item, score
        end
    end

    if character then
        for _, obj in ipairs(character:GetChildren()) do consider(obj) end
    end
    if inventory then
        for _, obj in ipairs(inventory:GetChildren()) do consider(obj) end
    end
    if backpack then
        for _, obj in ipairs(backpack:GetChildren()) do consider(obj) end
    end
    return best
end

local function getCombatContainer()
    local now = os.clock()
    if Nexus.Cache.CombatContainer and Nexus.Cache.CombatContainer.Parent
        and now - Nexus.Cache.CombatContainerScanAt < 1.5 then
        return Nexus.Cache.CombatContainer
    end
    Nexus.Cache.CombatContainer = Workspace:FindFirstChild("Characters") or Workspace
    Nexus.Cache.CombatContainerScanAt = now
    return Nexus.Cache.CombatContainer
end

local function getObjectRoot(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj:FindFirstChild("HumanoidRootPart")
            or obj.PrimaryPart
            or obj:FindFirstChild("Trunk")
            or obj:FindFirstChild("Head")
            or obj:FindFirstChildWhichIsA("BasePart")
    end
end

local function isEnemyModel(obj)
    if not obj or not obj:IsA("Model") or obj == getCharacter() then return false end
    local hum = obj:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if Players:GetPlayerFromCharacter(obj) then return false end
    if matchesAny(lowerName(obj), FriendlyNPCNames) then return false end
    if obj:GetAttribute("Enemy") == true or obj:GetAttribute("IsEnemy") == true then return true end
    -- Characters in this game are predominantly hostile animals/NPCs; exclude only obvious friendlies.
    local parentName = obj.Parent and lowerName(obj.Parent) or ""
    if parentName == "characters" or parentName == "enemies" or parentName == "animals" then
        return true
    end
    return matchesAny(lowerName(obj), CombatEnemyNames)
end

local function isTreeModel(obj)
    if not obj or not (obj:IsA("Model") or obj:IsA("BasePart")) then return false end
    return matchesAny(obj.Name, TreeObjectNames) or obj:GetAttribute("Tree") == true
end

local function getWeaponResourceDamage(tool)
    if not tool then return nil end
    local value = tool:GetAttribute("WeaponResourceDamage")
    if type(value) == "number" then return value end
    local fallback = {
        ["Old Axe"] = 10,
        ["Good Axe"] = 17,
        ["Strong Axe"] = 25,
        ["Chainsaw"] = 40,
        ["Spear"] = 20,
        ["Morningstar"] = 30,
        ["Infernal Sword"] = 35,
        ["Scythe"] = 28,
    }
    return fallback[tool.Name] or 10
end

local function equipServerTool(tool)
    local remote = getRemote("EquipItemHandle")
    if remote and tool then
        pcall(function() remote:FireServer("FireAllClients", tool) end)
    end
end

local function unequipServerTool(tool)
    local remote = getRemote("UnequipItemHandle")
    if remote and tool then
        pcall(function() remote:FireServer(tool) end)
    end
end

local function makeSessionID()
    Nexus.SessionCounter = (Nexus.SessionCounter or 0) + 1
    return tostring(Nexus.SessionCounter) .. "_" .. tostring(math.abs(LocalPlayer.UserId))
end

local function getWeaponDamage(tool, isTree)
    if not tool then return 10 end
    local attr = tool:GetAttribute(isTree and "WeaponResourceDamage" or "WeaponDamage")
    if type(attr) == "number" and attr > 0 then
        return attr
    end
    if isTree then
        return getWeaponResourceDamage(tool) or 10
    end
    local fallback = {
        ["Old Axe"] = 10, ["Good Axe"] = 17, ["Strong Axe"] = 25,
        ["Chainsaw"] = 40, ["Spear"] = 20, ["Morningstar"] = 30,
        ["Infernal Sword"] = 35, ["Scythe"] = 28,
    }
    return fallback[tool.Name] or 10
end

local function invokeDamage(target, weapon, isTree)
    if not target or not target.Parent or not weapon then return false end
    local remote = getDamageRemote()
    local root = getRoot()
    if not remote or not root then return false end
    if Nexus.CombatBusy[target] and os.clock() - Nexus.CombatBusy[target] < 0.08 then
        return false
    end

    Nexus.CombatBusy[target] = os.clock()
    equipServerTool(weapon)

    local hum = getHumanoid()
    if hum and weapon:IsA("Tool") and weapon.Parent ~= getCharacter() then
        pcall(function() hum:EquipTool(weapon) end)
        task.wait(0.03)
    end

    local damage = getWeaponDamage(weapon, isTree)
    local session = "1_" .. tostring(LocalPlayer.UserId)
    local requestCF = root.CFrame

    -- The current public 99 Nights implementations consistently use the
    -- player session id as the 3rd argument for ToolDamageObject.  Keep
    -- damage-based fallbacks for game revisions that expect numeric damage.
    local attempts
    if isTree then
        attempts = {
            {target, weapon, session, requestCF},
            {target, weapon, damage, requestCF},
            {target, weapon, "6", requestCF},
        }
    else
        attempts = {
            {target, weapon, session, requestCF},
            {target, weapon, damage, requestCF},
            {target, weapon, "6", requestCF},
        }
    end

    local success = false
    for _, args in ipairs(attempts) do
        local ok, result = pcall(function()
            if remote:IsA("RemoteFunction") then
                return remote:InvokeServer(unpack(args))
            else
                remote:FireServer(unpack(args))
                return true
            end
        end)
        if ok then
            if remote:IsA("RemoteEvent") then
                success = true
                break
            end
            if result == true or result == nil then
                success = true
                break
            end
            if type(result) ~= "table" or result.Success ~= false then
                success = true
                break
            end
        end
    end

    task.delay(isTree and 0.10 or 0.12, function()
        Nexus.CombatBusy[target] = nil
    end)
    return success
end

local function findNearestEnemy(radius)
    local root = getRoot()
    if not root then return nil, math.huge end
    local container = getCombatContainer()
    local best, bestDist = nil, radius or math.huge
    for _, obj in ipairs(container:GetChildren()) do
        if isEnemyModel(obj) then
            local part = getObjectRoot(obj)
            if part then
                local d = (part.Position - root.Position).Magnitude
                if d <= bestDist then best, bestDist = obj, d end
            end
        end
    end
    return best, bestDist
end

local function tryAttackTarget(target)
    local weapon = getCombatWeapon()
    return weapon and invokeDamage(target, weapon) or false
end

local function getStatValue(names)
    local now = os.clock()
    if now - Nexus.Cache.StatScanAt < 0.9 then
        for _, name in ipairs(names) do
            if Nexus.Cache.StatValues[string.lower(name)] ~= nil then
                return Nexus.Cache.StatValues[string.lower(name)]
            end
        end
    end

    local found
    local function scan(container)
        for _, obj in ipairs(container:GetChildren()) do
            if obj:IsA("NumberValue") or obj:IsA("IntValue") then
                local n = string.lower(obj.Name)
                for _, wanted in ipairs(names) do
                    if string.find(n, string.lower(wanted), 1, true) then
                        Nexus.Cache.StatValues[n] = obj.Value
                        found = obj.Value
                        return true
                    end
                end
            elseif obj:IsA("Folder") then
                for _, wanted in ipairs(names) do
                    local attr = obj:GetAttribute(wanted)
                    if type(attr) == "number" then
                        Nexus.Cache.StatValues[string.lower(wanted)] = attr
                        found = attr
                        return true
                    end
                end
            end
        end
    end
    scan(LocalPlayer)
    if not found and getCharacter() then scan(getCharacter()) end
    Nexus.Cache.StatScanAt = now
    return found
end

local function findToolByNames(list)
    local function pred(t)
        return matchesAny(t.Name, list)
    end
    return equipTool(pred)
end

local function findCampfire()
    local exact = ExactTeleportPaths.Campfire and safeCall(ExactTeleportPaths.Campfire)
    if exact then return exact end
    local map = Workspace:FindFirstChild("Map")
    local campground = map and map:FindFirstChild("Campground")
    local mainFire = campground and campground:FindFirstChild("MainFire")
    if mainFire then return mainFire end
    return findByNameTerms({"campfire", "camp fire", "mainfire", "warm place"}, 2500)
end

local BringContainers = {
    "Items", "DroppedItems", "Resources", "Interactions", "Deployables",
    "Loot", "Chests"
}

local function getItemsFolder()
    return Workspace:FindFirstChild("Items")
end

local function getItemPart(obj)
    if not obj then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Model") then
        return obj.PrimaryPart
            or obj:FindFirstChildWhichIsA("BasePart")
            or obj:FindFirstChild("Handle")
    end
end

local function isChestItem(obj)
    if not obj then return false end
    local n = lowerName(obj)
    return string.find(n, "item chest", 1, true) ~= nil
        or string.find(n, "chest", 1, true) ~= nil
end

local function isOpenedChest(obj)
    return obj and (obj:GetAttribute("8721081708ed") == true
        or obj:GetAttribute("8721081708Opened") == true)
end

local function moveItemWithServerDrag(item, targetCF)
    if not item or not item.Parent then return false end
    local part = getItemPart(item)
    if not part then return false end

    local startDrag, stopDrag = getDragRemotes()
    if not startDrag or not stopDrag then
        setPivot(item, targetCF)
        return true
    end

    local ok = pcall(function()
        startDrag:FireServer(item)
        task.wait(0.04)
        setPivot(item, targetCF)
        task.wait(0.04)
        stopDrag:FireServer(item)
    end)
    return ok
end

local function openChestPrompt(chest)
    if not chest or not chest.Parent then return false end
    if isOpenedChest(chest) then return true end
    if type(fireproximityprompt) ~= "function" then return false end

    local promptParent = chest:FindFirstChild("Main")
    if promptParent then
        local attachment = promptParent:FindFirstChild("ProximityAttachment")
        if attachment then
            for _, obj in ipairs(attachment:GetChildren()) do
                if obj:IsA("ProximityPrompt") then
                    pcall(function() fireproximityprompt(obj) end)
                    return true
                end
            end
        end
        for _, obj in ipairs(promptParent:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                pcall(function() fireproximityprompt(obj) end)
                return true
            end
        end
    end
    for _, obj in ipairs(chest:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            pcall(function() fireproximityprompt(obj) end)
            return true
        end
    end
    return false
end

local function getBringCandidates(category)
    if category == "trees" then
        local result = {}
        local map = Workspace:FindFirstChild("Map")
        if map then
            for _, folderName in ipairs({"Foliage", "Landmarks"}) do
                local folder = map:FindFirstChild(folderName)
                if folder then
                    for _, obj in ipairs(folder:GetChildren()) do
                        result[#result + 1] = obj
                    end
                end
            end
        end
        return result
    end

    local items = getItemsFolder()
    if items then return items:GetChildren() end
    local result = {}
    for _, name in ipairs(BringContainers) do
        local folder = Workspace:FindFirstChild(name)
        if folder then
            for _, obj in ipairs(folder:GetChildren()) do
                result[#result + 1] = obj
            end
        end
    end
    return result
end

local function matchesBringCategory(obj, list, category)
    if category == "chests" then
        return isChestItem(obj) and not isOpenedChest(obj)
    end
    local n = lowerName(obj)
    for _, term in ipairs(list or {}) do
        if string.find(n, string.lower(term), 1, true) then
            return true
        end
    end
    return false
end

local function bringMatches(list, radius, maxCount, category, openAfter)
    local root = getRoot()
    if not root then return 0 end
    local targetCF = root.CFrame * CFrame.new(0, 2.2, -2.5)
    local r = radius or Nexus.Settings.BringRadius
    local count = 0

    for _, obj in ipairs(getBringCandidates(category)) do
        if count >= (maxCount or 20) then break end
        if obj.Parent and (obj:IsA("Model") or obj:IsA("BasePart"))
            and matchesBringCategory(obj, list, category) then
            local part = getItemPart(obj)
            if part and (part.Position - root.Position).Magnitude <= r then
                if moveItemWithServerDrag(obj, targetCF * CFrame.new((count % 3) * 2.6, 0, math.floor(count / 3) * 2.6)) then
                    count += 1
                    if openAfter and category == "chests" then
                        task.delay(0.12, function()
                            openChestPrompt(obj)
                        end)
                    end
                end
            end
        end
    end
    return count
end

local function bringByCategory(category, openAfter)
    local map = {
        items = ItemNames,
        trees = {"tree", "log tree", "dead tree", "big tree", "small tree", "treebig", "snow tree"},
        chopped = {"log", "wood", "chopped", "wood pile", "log pile", "woodpile", "droppedwood", "cutwood"},
        food = {"morsel", "steak", "cooked morsel", "cooked steak", "cake", "berry", "carrot", "apple", "ribs", "mre"},
        fuel = {"log", "coal", "fuel canister", "fuel", "oil barrel", "gas", "biofuel"},
        weapons = {"revolver", "rifle", "scythe", "morningstar", "explosive rifle", "kunai", "strong axe", "good axe", "spear", "bouncing blade", "chainsaw", "crossbow", "raygun"},
        scrap = {"broken microwave", "broken fan", "bolt", "old radio", "sheet metal", "tyre", "washing machine", "old car engine", "metal chair", "ufo component", "ufo scrap", "scrap"},
        gems = {"cultist gem", "gem of the forest", "gem of the forest fragment"},
        saplings = {"sapling"},
        heals = {"bandage", "medkit"},
        armor = {"leather body", "iron body", "thorn body", "alien armour", "obsidiron body", "vampire cloak", "riot shield", "poison armour", "corrupted thorn body"},
        explosives = {"impact grenade", "dynamite"},
        light = {"old flashlight", "strong flashlight"},
    }
    return bringMatches(map[category] or {Nexus.Settings.SelectedItem}, Nexus.Settings.BringRadius, 25, category, openAfter)
end

local function godModeOnce()
    if Nexus._GodGuard then
        destroyConnection(Nexus._GodGuard)
        Nexus._GodGuard = nil
        Nexus.State.GodMode = false
        return false
    end
    local hum = getHumanoid()
    if not hum then return false end
    Nexus.State.GodMode = true
    Nexus._GodGuard = connect(hum.HealthChanged, function(hp)
        if not Nexus.State.GodMode then return end
        if hp > 0 and hp < hum.MaxHealth then
            pcall(function() hum.Health = hum.MaxHealth end)
        end
    end)
    pcall(function() hum.Health = hum.MaxHealth end)
    return true
end

local function setInstantInteract(enabled)
    if Nexus._InstantInteract then
        destroyConnection(Nexus._InstantInteract)
        Nexus._InstantInteract = nil
    end
    if not enabled then return end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            obj.HoldDuration = 0
        end
    end
    Nexus._InstantInteract = connect(Workspace.DescendantAdded, function(obj)
        if obj:IsA("ProximityPrompt") then
            pcall(function() obj.HoldDuration = 0 end)
        end
    end)
end

local function openAllItemChests()
    local remote = getRemote("RequestOpenItemChest")
    local folder = Workspace:FindFirstChild("Items")
    if not remote or not folder then return 0 end
    local count = 0
    for _, item in ipairs(folder:GetChildren()) do
        if isChestItem(item) and not isOpenedChest(item) then
            pcall(function() remote:FireServer(item) end)
            count += 1
            if count >= 40 then break end
            task.wait(0.04)
        end
    end
    return count
end

local function getTeleportTargetFromInstance(obj)
    if not obj or not obj.Parent then return nil end
    local cf = getPivot(obj)
    if cf then return cf end
    local part = getObjectRoot(obj)
    return part and part.CFrame or nil
end

local function safeTeleportCF(cf)
    local root = getRoot()
    if not root or not cf then return false end
    local hum = getHumanoid()
    if hum then pcall(function() hum.Sit = false end) end

    Nexus.LastTeleportCF = root.CFrame
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)

    local ok = pcall(function()
        root.CFrame = cf
    end)
    if not ok then return false end

    task.defer(function()
        task.wait()
        if root and root.Parent then
            pcall(function()
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end)
    return true
end

local function teleportToGround(targetCF)
    if not targetCF then return false end
    local root = getRoot()
    local character = getCharacter()
    if not root or not character then return false end

    local targetPos = typeof(targetCF) == "CFrame" and targetCF.Position or targetCF
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}
    local hit = Workspace:Raycast(targetPos + Vector3.new(0, 80, 0), Vector3.new(0, -220, 0), params)
    local grounded = hit and (hit.Position + Vector3.new(0, 3, 0)) or targetPos
    local _, yaw = root.CFrame:ToEulerAnglesYXZ()
    return safeTeleportCF(CFrame.new(grounded) * CFrame.Angles(0, yaw, 0))
end

local function collectTeleportRoots()
    local roots = {}
    local seen = {}
    local map = Workspace:FindFirstChild("Map")
    local candidates = {
        map,
        map and map:FindFirstChild("Landmarks"),
        map and map:FindFirstChild("Foliage"),
        map and map:FindFirstChild("Campground"),
        Workspace:FindFirstChild("Characters"),
        Workspace:FindFirstChild("Items"),
        Workspace:FindFirstChild("Structures"),
    }
    for _, obj in ipairs(candidates) do
        if obj and not seen[obj] then
            seen[obj] = true
            roots[#roots + 1] = obj
        end
    end
    return roots
end

local function findTeleportTarget(terms)
    local root = getRoot()
    if not root then return nil end
    local lowered = {}
    for _, term in ipairs(terms) do lowered[#lowered+1] = string.lower(term) end

    local best, bestScore, bestDist
    local seen = {}
    local function scoreName(name)
        local n = string.lower(name or "")
        local score = 0
        for _, term in ipairs(lowered) do
            if n == term then score = math.max(score, 5)
            elseif string.find(n, term, 1, true) then score = math.max(score, 2) end
        end
        return score
    end

    for _, searchRoot in ipairs(collectTeleportRoots()) do
        for _, obj in ipairs(searchRoot:GetDescendants()) do
            if not seen[obj] then
                seen[obj] = true
                if obj:IsA("Model") or obj:IsA("BasePart") then
                    local score = scoreName(obj.Name)
                    if score > 0 then
                        local cf = getPivot(obj)
                        if cf then
                            local d = (cf.Position - root.Position).Magnitude
                            if not bestScore or score > bestScore or (score == bestScore and d < bestDist) then
                                best, bestScore, bestDist = obj, score, d
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local function teleportNamed(terms)
    local direct = string.lower(table.concat(terms, " "))
    if direct:find("camp", 1, true) or direct:find("fire", 1, true) then
        local fire = ExactTeleportPaths.Campfire and safeCall(ExactTeleportPaths.Campfire)
        local cf = getTeleportTargetFromInstance(fire)
        if cf then return teleportToGround(cf * CFrame.new(0, 6, 0)) end
    end

    local obj = findTeleportTarget(terms)
    local cf = getTeleportTargetFromInstance(obj)
    if cf then return teleportToGround(cf) end
    return false
end

local function teleportToCursor()
    local mouse = LocalPlayer:GetMouse()
    if mouse and mouse.Hit then
        return teleportToGround(mouse.Hit.Position)
    end
    return false
end

local function teleportToPlayer(name)
    local needle = string.lower(name or "")
    if needle == "" then return false end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and (string.find(string.lower(plr.Name), needle, 1, true)
            or string.find(string.lower(plr.DisplayName), needle, 1, true)) then
            local targetRoot = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then return teleportToGround(targetRoot.CFrame) end
        end
    end
    return false
end

local function hookEnemyDeath(model)
    if not model or not model:IsA("Model") or Nexus.EnemyHooked[model] then return end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    Nexus.EnemyHooked[model] = true
    local con
    con = hum.Died:Connect(function()
        local pivot = getPivot(model)
        if pivot then
            Nexus.DeathRecords[#Nexus.DeathRecords + 1] = {
                Position = pivot.Position,
                Time = os.clock(),
            }
        end
    end)
    table.insert(Nexus.Connections, con)
end

local function scanEnemyHooks()
    local container = Workspace:FindFirstChild("Characters")
    if not container then return end
    for _, obj in ipairs(container:GetChildren()) do
        if obj:IsA("Model") and isEnemyModel(obj) then
            hookEnemyDeath(obj)
        end
    end
end

local function cleanupDeathRecords()
    local now = os.clock()
    for i = #Nexus.DeathRecords, 1, -1 do
        if now - Nexus.DeathRecords[i].Time > 30 then
            table.remove(Nexus.DeathRecords, i)
        end
    end
end

local function getDropCandidates()
    local out = {}
    local seen = {}
    for _, name in ipairs({"Items", "DroppedItems", "Loot", "Resources", "Interactions", "Deployables"}) do
        local folder = Workspace:FindFirstChild(name)
        if folder then
            for _, obj in ipairs(folder:GetChildren()) do
                if not seen[obj] then
                    seen[obj] = true
                    out[#out + 1] = obj
                end
            end
        end
    end
    return out
end

local function isEnemyDrop(obj)
    if not obj or not (obj:IsA("Model") or obj:IsA("BasePart")) then return false end
    if obj:GetAttribute("Scrappable") == true then return true end
    return matchesAny(obj.Name, EnemyDropNames)
end

local function getCorpsePositions() 
    local positions = {}
    for _, obj in ipairs(getDropCandidates()) do
        if obj.Parent and (obj:IsA("Model") or obj:IsA("BasePart")) and matchesAny(obj.Name, {"alpha wolf corpse", "wolf corpse", "bear corpse", "corpse"}) then
            local cf = getPivot(obj)
            if cf then positions[#positions + 1] = {Position = cf.Position, Time = os.clock()} end
        end
    end
    for _, death in ipairs(Nexus.DeathRecords) do
        positions[#positions + 1] = death
    end
    return positions
end

local collectLootNearPositions

local function bringEnemyDrops()
    cleanupDeathRecords()
    local root = getRoot()
    if not root then return 0 end
    local positions = {}
    for _, death in ipairs(Nexus.DeathRecords) do positions[#positions+1] = death.Position end
    for _, obj in ipairs(getDropCandidates()) do
        if obj.Parent and matchesAny(obj.Name, {"corpse","pelt","alpha wolf corpse","wolf corpse","bear corpse"}) then
            local cf = getPivot(obj)
            if cf then positions[#positions+1] = cf.Position end
        end
    end
    return collectLootNearPositions(positions, 130)
end

local function getAllEnemyModels()
    local result, seen = {}, {}
    local containers = {}
    for _, name in ipairs({"Characters", "Enemies"}) do
        local f = Workspace:FindFirstChild(name)
        if f then containers[#containers+1] = f end
    end
    local map = Workspace:FindFirstChild("Map")
    if map then
        for _, name in ipairs({"Characters", "Animals", "Enemies"}) do
            local f = map:FindFirstChild(name)
            if f then containers[#containers+1] = f end
        end
    end

    for _, container in ipairs(containers) do
        for _, obj in ipairs(container:GetChildren()) do
            if not seen[obj] and isEnemyModel(obj) then
                seen[obj] = true
                result[#result+1] = obj
            end
        end
    end

    local root = getRoot()
    if root then
        table.sort(result, function(a,b)
            local ar, br = getObjectRoot(a), getObjectRoot(b)
            if not ar or not br then return ar ~= nil end
            return (ar.Position-root.Position).Magnitude < (br.Position-root.Position).Magnitude
        end)
    end
    return result
end

collectLootNearPositions = function(positions, maxRadius)
    local root = getRoot()
    if not root or not positions or #positions == 0 then return 0 end
    local moved = 0
    local containers = {}
    for _, name in ipairs({"Items","DroppedItems","Loot","Resources","Interactions"}) do
        local f = Workspace:FindFirstChild(name)
        if f then containers[#containers+1] = f end
    end
    local seen = {}
    local target = root.CFrame * CFrame.new(0, 2.5, -2)
    for _, folder in ipairs(containers) do
        for _, obj in ipairs(folder:GetChildren()) do
            if moved >= 80 then return moved end
            if obj.Parent and not seen[obj] then
                seen[obj] = true
                local part = getItemPart(obj)
                if part then
                    for _, pos in ipairs(positions) do
                        if (part.Position-pos).Magnitude <= (maxRadius or 90) then
                            if moveItemWithServerDrag(obj, target * CFrame.new((moved%6)*2,0,math.floor(moved/6)*2)) then
                                moved += 1
                            end
                            break
                        end
                    end
                end
            end
        end
    end
    return moved
end

local function killAllEnemies()
    if Nexus.KillAllBusy then return false end
    Nexus.KillAllBusy = true
    task.spawn(function()
        local root = getRoot()
        if not root then Nexus.KillAllBusy = false return end

        local enemies = getAllEnemyModels()
        local positions = {}
        for _, enemy in ipairs(enemies) do
            local part = getObjectRoot(enemy)
            if part then
                positions[#positions + 1] = part.Position
            end
        end

        local weapon = getCombatWeapon()
        if not weapon then
            Nexus.KillAllBusy = false
            return
        end
        equipServerTool(weapon)

        local maxHits = math.clamp(math.ceil((tonumber(weapon:GetAttribute("WeaponDamage")) or 10) > 0 and 12 or 16), 8, 16)
        local cooldown = math.max(0.16, tonumber(weapon:GetAttribute("ToolCooldown")) or 0.24)

        for _, enemy in ipairs(enemies) do
            if not Nexus.Running then break end
            if enemy.Parent and isEnemyModel(enemy) then
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                for _ = 1, maxHits do
                    if not (enemy.Parent and hum and hum.Health > 0 and isEnemyModel(enemy)) then break end
                    invokeDamage(enemy, weapon, false)
                    task.wait(cooldown)
                end
                local corpsePart = getObjectRoot(enemy)
                if corpsePart then positions[#positions + 1] = corpsePart.Position end
            end
        end

        -- Drops can replicate after the Humanoid dies. Do multiple cheap passes.
        for _, delayTime in ipairs({0.35, 0.8, 1.4}) do
            task.wait(delayTime)
            collectLootNearPositions(positions, 140)
        end
        Nexus.KillAllBusy = false
    end)
    return true
end

--////////////////////////////////////////////////////////////////
--  THREADS
--////////////////////////////////////////////////////////////////

local function startThread(key, fn)
    if Nexus.Threads[key] then
        return
    end

    Nexus.Threads[key] = true
    task.spawn(function()
        while Nexus.Threads[key] do
            local ok = pcall(fn)
            if not ok then
                task.wait(1)
            else
                task.wait(0.12)
            end
        end
    end)
end

local function stopThread(key)
    Nexus.Threads[key] = nil
end

local function stopAllThreads()
    for key in pairs(Nexus.Threads) do
        Nexus.Threads[key] = nil
    end
end

-- Prefer an actual melee weapon for enemies, and an actual axe for trees.
local function getAxeWeapon()
    local character = getCharacter()
    local inventory = getInventory()
    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    local names = {"Strong Axe", "Good Axe", "Old Axe", "Chainsaw", "Ice Axe", "Corrupted Axe"}
    local best, bestScore = nil, -math.huge

    local function consider(obj)
        if not obj or not obj.Parent then return end
        if not matchesAny(obj.Name, names) then return end
        local score = tonumber(obj:GetAttribute("WeaponResourceDamage")) or 0
        score = score + (({
            ["Strong Axe"] = 50, ["Good Axe"] = 40, ["Old Axe"] = 30,
            ["Chainsaw"] = 60, ["Ice Axe"] = 55, ["Corrupted Axe"] = 55
        })[obj.Name] or 10)
        if character and obj.Parent == character then score += 1000 end
        if score > bestScore then best, bestScore = obj, score end
    end

    if character then for _, obj in ipairs(character:GetChildren()) do consider(obj) end end
    if inventory then for _, obj in ipairs(inventory:GetChildren()) do consider(obj) end end
    if backpack then for _, obj in ipairs(backpack:GetChildren()) do consider(obj) end end
    return best
end

local function getNearbyEnemyModels(radius)
    local root = getRoot()
    if not root then return {} end
    local result, seen = {}, {}
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Include
    local folders = {}
    for _, name in ipairs({"Characters", "Enemies"}) do
        local folder = Workspace:FindFirstChild(name)
        if folder then folders[#folders + 1] = folder end
    end
    params.FilterDescendantsInstances = folders

    local ok, parts = pcall(function()
        return Workspace:GetPartBoundsInRadius(root.Position, radius, params)
    end)
    if ok and parts then
        for _, part in ipairs(parts) do
            local model = part:FindFirstAncestorOfClass("Model")
            if model and not seen[model] and isEnemyModel(model) then
                seen[model] = true
                result[#result + 1] = model
            end
        end
    end

    -- Fallback for executors/versions where Include filtering or the spatial
    -- query does not return nested NPC models.
    if #result == 0 then
        for _, model in ipairs(getAllEnemyModels()) do
            local part = getObjectRoot(model)
            if part and (part.Position - root.Position).Magnitude <= radius then
                result[#result + 1] = model
            end
        end
    end
    table.sort(result, function(a, b)
        local ar, br = getObjectRoot(a), getObjectRoot(b)
        if not ar or not br then return ar ~= nil end
        return (ar.Position - root.Position).Magnitude < (br.Position - root.Position).Magnitude
    end)
    return result
end

-- Kill Aura
local function updateKillAura()
    if not Nexus.State.KillAura then return end
    local now = os.clock()
    local weapon = getCombatWeapon()
    local root = getRoot()
    if not weapon or not root then return end

    local cooldown = tonumber(weapon:GetAttribute("ToolCooldown")) or 0.28
    if now - (Nexus._LastKillAura or 0) < math.max(0.18, cooldown) then return end
    Nexus._LastKillAura = now

    local targets = getNearbyEnemyModels(Nexus.Settings.KillAuraRadius)
    local target = targets[1]
    if target then
        invokeDamage(target, weapon, false)
    end
end

-- Tree Aura
local function getTreeContainers()
    local map = Workspace:FindFirstChild("Map")
    if not map then return {} end
    local out, seen = {}, {}
    for _, name in ipairs({"Foliage", "Landmarks", "Resources"}) do
        local folder = map:FindFirstChild(name)
        if folder and not seen[folder] then
            seen[folder] = true
            out[#out + 1] = folder
        end
    end
    return out
end

local function getTreeRoot(tree)
    if tree:IsA("BasePart") then return tree end
    return tree:FindFirstChild("Trunk")
        or tree.PrimaryPart
        or tree:FindFirstChild("Wood")
        or tree:FindFirstChild("Log")
        or tree:FindFirstChildWhichIsA("BasePart")
end

local function damageNearbyTrees()
    local now = os.clock()
    local axe = getAxeWeapon()
    local root = getRoot()
    if not axe or not root then return end

    local cooldown = tonumber(axe:GetAttribute("ToolCooldown")) or 0.32
    if now - (Nexus._LastTreeSwing or 0) < math.max(0.20, cooldown) then return end
    Nexus._LastTreeSwing = now

    local radius = math.clamp(Nexus.Settings.TreeRadius, 15, 1000)
    local candidates, seen = {}, {}
    for _, container in ipairs(getTreeContainers()) do
        for _, tree in ipairs(container:GetChildren()) do
            if not seen[tree] and tree:IsA("Model") and tree.Parent and isTreeModel(tree) then
                local part = getTreeRoot(tree)
                if part and (part.Position - root.Position).Magnitude <= radius then
                    seen[tree] = true
                    candidates[#candidates + 1] = {
                        tree = tree,
                        part = part,
                        dist = (part.Position - root.Position).Magnitude,
                    }
                end
            end
        end
    end

    -- A second, cheaper recursive pass only runs when the normal foliage list
    -- produced nothing. This avoids a full descendant scan on every swing.
    if #candidates == 0 then
        for _, container in ipairs(getTreeContainers()) do
            for _, tree in ipairs(container:GetDescendants()) do
                if tree:IsA("Model") and not seen[tree] and tree.Parent and isTreeModel(tree) then
                    local part = getTreeRoot(tree)
                    if part and (part.Position - root.Position).Magnitude <= radius then
                        seen[tree] = true
                        candidates[#candidates + 1] = {
                            tree = tree,
                            part = part,
                            dist = (part.Position - root.Position).Magnitude,
                        }
                    end
                end
            end
        end
    end

    table.sort(candidates, function(a, b) return a.dist < b.dist end)
    equipServerTool(axe)
    pcall(function()
        if axe:IsA("Tool") and axe.Parent ~= getCharacter() then
            getHumanoid():EquipTool(axe)
        end
    end)

    -- Keep the hit count small enough to avoid ping spikes while still making
    -- the aura noticeably faster than the previous one-target implementation.
    local limit = (Nexus.State.TreeAura or Nexus.State.AutoChop) and 4 or 1
    for i = 1, math.min(limit, #candidates) do
        invokeDamage(candidates[i].tree, axe, true)
    end
end

local function updateTreeAura()
    if not Nexus.State.TreeAura then return end
    damageNearbyTrees()
end

-- Auto chop uses the same server-compatible tree damage path as Tree Aura.
local function updateAutoChop()
    if not Nexus.State.AutoChop then return end
    damageNearbyTrees()
end

-- Auto eat
local function findHungerValue()
    for name, value in pairs(LocalPlayer:GetAttributes()) do
        if type(value) == "number" then
            local n = string.lower(tostring(name))
            if n:find("hunger", 1, true) or n:find("food", 1, true) or n == "satiation" then
                return value
            end
        end
    end
    return nil
end

local function consumeGameItem(item, bringFirst)
    if not item or not item.Parent then return false end
    local consume = getRemote("RequestConsumeItem")
    if not consume then return false end
    if bringFirst and item:IsDescendantOf(Workspace) then
        local root = getRoot()
        if root then
            moveItemWithServerDrag(item, root.CFrame * CFrame.new(0, 2, -2))
            task.wait(0.08)
        end
    end
    local ok = pcall(function()
        if consume:IsA("RemoteFunction") then
            consume:InvokeServer(item)
        else
            consume:FireServer(item)
        end
    end)
    return ok
end

local function updateAutoEat()
    if not Nexus.State.AutoEat then return end
    local now = os.clock()
    if now - (Nexus._LastEat or 0) < 2.75 then return end

    local hunger = findHungerValue()
    if hunger and hunger > Nexus.Settings.AutoEatThreshold then return end

    local items = Workspace:FindFirstChild("Items")
    local inventory = getInventory()
    local best, bestRestore = nil, -math.huge

    local function consider(folder, isWorld)
        if not folder then return end
        for _, item in ipairs(folder:GetChildren()) do
            local restore = item:GetAttribute("RestoreHunger")
            if type(restore) == "number" and restore > 0 and restore > bestRestore then
                best, bestRestore = item, restore
                Nexus._EatWorldItem = isWorld
            end
        end
    end

    consider(inventory, false)
    consider(items, true)

    if best then
        if consumeGameItem(best, Nexus._EatWorldItem) then
            Nexus._LastEat = now
        end
        return
    end

    local tool = activateTool(function(t)
        return matchesAny(t.Name, {"food","meat","morsel","berry","carrot","corn","cake","pie","stew","apple"})
    end)
    if tool then Nexus._LastEat = now end
end

-- Auto heal
local function updateAutoHeal()
    if not Nexus.State.AutoHeal then return end
    local now = os.clock()
    if now - (Nexus._LastHeal or 0) < 1.75 then return end
    local hum = getHumanoid()
    if not hum or hum.MaxHealth <= 0 then return end
    local percent = hum.Health / hum.MaxHealth * 100
    if percent > Nexus.Settings.AutoHealThreshold then return end

    local inventory = getInventory()
    local items = Workspace:FindFirstChild("Items")
    local best, bestHeal, world = nil, -math.huge, false

    local function consider(folder, isWorld)
        if not folder then return end
        for _, item in ipairs(folder:GetChildren()) do
            local heal = item:GetAttribute("RestoreHealth")
            local named = matchesAny(item.Name, {"bandage", "medkit"})
            if (type(heal) == "number" and heal > 0) or named then
                local score = (type(heal) == "number" and heal or 1)
                if score > bestHeal then
                    best, bestHeal, world = item, score, isWorld
                end
            end
        end
    end
    consider(inventory, false)
    consider(items, true)

    if best and consumeGameItem(best, world) then
        Nexus._LastHeal = now
        return
    end

    local tool = activateTool(function(t)
        return matchesAny(t.Name, {"bandage","medkit","med","heal","first aid"})
    end)
    if tool then Nexus._LastHeal = now end
end

-- Auto fuel / campfire.
-- 1) Anything already inside the campfire's touch-zone is burned immediately.
-- 2) Fuel anywhere in the map is moved to the fire through the drag remotes,
--    then burned. This removes the old local-radius limitation.
local function getCampfireTargets()
    local map = Workspace:FindFirstChild("Map")
    local campground = map and map:FindFirstChild("Campground")
    if not campground then return nil, nil end
    local fire = campground:FindFirstChild("MainFire")
    if not fire then return nil, nil end
    local zone = fire:FindFirstChild("InnerTouchZone", true) or campground:FindFirstChild("InnerTouchZone", true)
    return fire, zone
end

local function isFuelItem(item)
    if not item or not item.Parent then return false end
    local names = {
        ["log"] = true, ["coal"] = true, ["fuel canister"] = true,
        ["oil barrel"] = true, ["biofuel"] = true, ["chair"] = true,
    }
    return names[lowerName(item)] == true or item:GetAttribute("BurnFuel") == true
end

local function isInsideCampfireZone(item, zone, fire)
    local part = getItemPart(item)
    if not part then return false end
    local centerCF = zone and getPivot(zone) or (fire and getPivot(fire))
    if not centerCF then return false end
    local pos = centerCF:PointToObjectSpace(part.Position)
    local halfX = zone and math.max(5, zone.Size.X * 0.5) or 12
    local halfZ = zone and math.max(5, zone.Size.Z * 0.5) or 12
    local halfY = zone and math.max(7, zone.Size.Y * 0.5 + 8) or 12
    return math.abs(pos.X) <= halfX and math.abs(pos.Z) <= halfZ and math.abs(pos.Y) <= halfY
end

local function burnFuelItem(fire, zone, item)
    local burn = getRemote("RequestBurnItem")
    if not fire or not item or not item.Parent then return false end
    if not isFuelItem(item) then return false end

    if burn and isInsideCampfireZone(item, zone, fire) then
        local ok = pcall(function() burn:FireServer(fire, item) end)
        if ok then return true end
    end

    local startDrag, stopDrag = getDragRemotes()
    local targetCF = zone and getPivot(zone) or getPivot(fire)
    if startDrag and stopDrag and targetCF then
        local ok = pcall(function()
            startDrag:FireServer(item)
            task.wait(0.035)
            setPivot(item, targetCF * CFrame.new(0, 2, 0))
            task.wait(0.05)
            stopDrag:FireServer(item)
            task.wait(0.03)
        end)
        if not ok then return false end
    else
        if targetCF then setPivot(item, targetCF * CFrame.new(0, 2, 0)) end
    end

    if burn then
        return pcall(function() burn:FireServer(fire, item) end)
    end
    return true
end

local function updateCampfireZoneFeed()
    if not Nexus.State.CampfireZoneFeed then return end
    local fire, zone = getCampfireTargets()
    if not fire or not zone then return end
    local burn = getRemote("RequestBurnItem")
    if not burn then return end

    local now = os.clock()
    Nexus._ZoneFuelCooldown = Nexus._ZoneFuelCooldown or {}
    local count = 0
    local items = Workspace:FindFirstChild("Items")
    if not items then return end

    for _, item in ipairs(items:GetChildren()) do
        if count >= 10 then break end
        if item.Parent and isFuelItem(item) and isInsideCampfireZone(item, zone, fire) then
            local nextAt = Nexus._ZoneFuelCooldown[item] or 0
            if now >= nextAt then
                Nexus._ZoneFuelCooldown[item] = now + 0.75
                pcall(function() burn:FireServer(fire, item) end)
                count += 1
            end
        end
    end
end

local function updateAutoFuel()
    if not Nexus.State.AutoFuel then return end
    local fire, zone = getCampfireTargets()
    if not fire then return end

    local now = os.clock()
    Nexus._FuelCooldown = Nexus._FuelCooldown or {}
    local processed = 0

    for _, folderName in ipairs({"Items", "DroppedItems", "Resources", "Loot"}) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, item in ipairs(folder:GetChildren()) do
                if processed >= 24 then return end
                if item.Parent and isFuelItem(item) then
                    local nextAt = Nexus._FuelCooldown[item] or 0
                    if now >= nextAt then
                        Nexus._FuelCooldown[item] = now + 1.5
                        burnFuelItem(fire, zone, item)
                        processed += 1
                    end
                end
            end
        end
    end
end

-- Bring loops
local function updateBringItems()
    if Nexus.State.BringItems then bringByCategory("items") end
    if Nexus.State.BringTrees then bringByCategory("trees") end
    if Nexus.State.BringChopped then bringByCategory("chopped") end
end

-- Auto plant saplings
local function updateAutoPlant()
    if not Nexus.State.AutoPlant then return end
    local remote = getRemote("RequestPlantItem")
    local items = Workspace:FindFirstChild("Items")
    if not remote or not items then return end
    for _, item in ipairs(items:GetChildren()) do
        if lowerName(item) == "sapling" then
            local root = getRoot()
            local pos = root and (root.Position + Vector3.new(0,0,5))
            if pos then
                pcall(function() remote:InvokeServer(item, pos) end)
            end
            break
        end
    end
end

-- Auto cook using the game's current campfire remote when available.
local function updateAutoCook()
    if not Nexus.State.AutoCook then return end
    local remote = getRemote("RequestCookItem")
    local map = Workspace:FindFirstChild("Map")
    local campground = map and map:FindFirstChild("Campground")
    local fire = campground and campground:FindFirstChild("MainFire")
    local items = Workspace:FindFirstChild("Items")
    if not remote or not fire or not items then return end

    for _, item in ipairs(items:GetChildren()) do
        local cookable = item:GetAttribute("Cookable")
        local restoreHealth = item:GetAttribute("RestoreHealth")
        if cookable == true or (type(restoreHealth) == "number" and restoreHealth < 0) or matchesAny(item.Name, {"morsel","steak","raw meat"}) then
            pcall(function()
                remote:FireServer(fire, item)
            end)
            break
        end
    end
end

local function restoreFrozenEnemies()
    for model, state in pairs(Nexus.FrozenEnemies) do
        if model and model.Parent then
            local hum = model:FindFirstChildOfClass("Humanoid")
            local rootPart = getObjectRoot(model)
            if hum then
                pcall(function() hum.WalkSpeed = state.WalkSpeed end)
                pcall(function() hum.JumpPower = state.JumpPower end)
                pcall(function() hum.AutoRotate = state.AutoRotate end)
                pcall(function() hum.PlatformStand = state.PlatformStand or false end)
            end
            if rootPart then
                pcall(function() rootPart.Anchored = state.Anchored end)
            end
        end
        Nexus.FrozenEnemies[model] = nil
    end
end

-- Freeze enemies: scan the live Characters folder directly instead of relying
-- on the death-hook cache. This makes newly spawned animals freeze immediately.
local function updateFreeze()
    if not Nexus.State.FreezeEnemies then
        restoreFrozenEnemies()
        return
    end

    local active = {}
    local enemies = getAllEnemyModels()
    for _, obj in ipairs(enemies) do
        if obj.Parent and isEnemyModel(obj) then
            active[obj] = true
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local rootPart = getObjectRoot(obj)
            if hum and not Nexus.FrozenEnemies[obj] then
                Nexus.FrozenEnemies[obj] = {
                    WalkSpeed = hum.WalkSpeed,
                    JumpPower = hum.JumpPower,
                    AutoRotate = hum.AutoRotate,
                    PlatformStand = hum.PlatformStand,
                    Anchored = rootPart and rootPart.Anchored or false,
                }
            end
            local state = Nexus.FrozenEnemies[obj]
            if hum then
                pcall(function()
                    hum.WalkSpeed = 0
                    hum.JumpPower = 0
                    hum.AutoRotate = false
                    hum.PlatformStand = true
                    hum:ChangeState(Enum.HumanoidStateType.Physics)
                end)
            end
            if rootPart then
                pcall(function()
                    rootPart.AssemblyLinearVelocity = Vector3.zero
                    rootPart.AssemblyAngularVelocity = Vector3.zero
                    rootPart.Anchored = true
                end)
            end
        end
    end

    for model, state in pairs(Nexus.FrozenEnemies) do
        if not active[model] then
            local hum = model and model:FindFirstChildOfClass("Humanoid")
            local rootPart = model and getObjectRoot(model)
            if hum and state then
                pcall(function()
                    hum.WalkSpeed = state.WalkSpeed
                    hum.JumpPower = state.JumpPower
                    hum.AutoRotate = state.AutoRotate
                    hum.PlatformStand = state.PlatformStand
                end)
            end
            if rootPart and state then rootPart.Anchored = state.Anchored end
            Nexus.FrozenEnemies[model] = nil
        end
    end
end

task.spawn(function()
    while Nexus.Running do
        local now = os.clock()
        updateKillAura()
        updateTreeAura()

        if now - Nexus.Tick.Survival >= 0.75 then
            Nexus.Tick.Survival = now
            updateAutoChop()
            updateAutoEat()
            updateAutoHeal()
            updateAutoFuel()
            updateAutoPlant()
            updateAutoCook()
        end

        if now - (Nexus._LastZoneFuelTick or 0) >= 0.25 then
            Nexus._LastZoneFuelTick = now
            updateCampfireZoneFeed()
        end

        if now - Nexus.Tick.Bring >= 1.15 then
            Nexus.Tick.Bring = now
            updateBringItems()
        end

        if now - Nexus.Tick.Freeze >= 0.9 then
            Nexus.Tick.Freeze = now
            updateFreeze()
        end

        if now - (Nexus._LastEnemyScan or 0) >= 1.2 then
            Nexus._LastEnemyScan = now
            cleanupDeathRecords()
            scanEnemyHooks()
        end

        task.wait(0.05)
    end
end)

--////////////////////////////////////////////////////////////////
--  MOVEMENT
--////////////////////////////////////////////////////////////////

local movementFrame = 0
local environmentFrame = 0
local flyControlModule
local flyDownButton
local FlyUpButton
Nexus.NoclipOriginal = Nexus.NoclipOriginal or {}

local function restoreNoclip()
    for part, state in pairs(Nexus.NoclipOriginal) do
        if part and part.Parent then
            pcall(function() part.CanCollide = state end)
        end
    end
    table.clear(Nexus.NoclipOriginal)
end

local function getMobileMoveVector(hum)
    if not flyControlModule then
        pcall(function()
            local module = LocalPlayer:WaitForChild("PlayerScripts", 2)
            local pm = module and module:FindFirstChild("PlayerModule")
            local control = pm and pm:FindFirstChild("ControlModule")
            if control then
                flyControlModule = require(control)
            end
        end)
    end
    if flyControlModule then
        local ok, vec = pcall(function() return flyControlModule:GetMoveVector() end)
        if ok and typeof(vec) == "Vector3" then return vec end
    end
    return hum and hum.MoveDirection or Vector3.zero
end

local function updateNoclip()
    local character = getCharacter()
    if not character then return end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            if Nexus.NoclipOriginal[part] == nil then Nexus.NoclipOriginal[part] = part.CanCollide end
            part.CanCollide = false
        end
    end
end

local function finishFly()
    local character = getCharacter()
    local hum = getHumanoid()
    local root = getRoot()
    if root then
        local bv = root:FindFirstChild("Nexus99_Fly")
        local bg = root:FindFirstChild("Nexus99_FlyGyro")
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
    if hum then hum.PlatformStand = false end
    if flyDownButton then flyDownButton.Visible = false end
    if FlyUpButton then FlyUpButton.Visible = false end
end

connect(RunService.RenderStepped, function(dt)
    local hum = getHumanoid()
    local root = getRoot()
    movementFrame += dt
    environmentFrame += dt

    if Nexus.State.Speed and hum then
        hum.WalkSpeed = Nexus.Settings.WalkSpeed
    elseif hum then
        if hum.WalkSpeed > 0 and hum.WalkSpeed ~= Nexus.Original.WalkSpeed then
            hum.WalkSpeed = Nexus.Original.WalkSpeed
        end
    end

    if root and Nexus.State.Fly then
        local camera = Workspace.CurrentCamera
        local move = Vector3.zero
        if UserInputService.TouchEnabled then
            local input = getMobileMoveVector(hum)
            move = camera.CFrame.RightVector * input.X - camera.CFrame.LookVector * input.Z
            if Nexus.FlyUp then move += Vector3.yAxis end
            if Nexus.FlyDown then move -= Vector3.yAxis end
        else
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) or UserInputService:IsKeyDown(Enum.KeyCode.E) then move += Vector3.yAxis end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then move -= Vector3.yAxis end
        end

        local bv = root:FindFirstChild("Nexus99_Fly")
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "Nexus99_Fly"
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.P = 2e4
            bv.Parent = root
        end
        local bg = root:FindFirstChild("Nexus99_FlyGyro")
        if not bg then
            bg = Instance.new("BodyGyro")
            bg.Name = "Nexus99_FlyGyro"
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.P = 3e4
            bg.Parent = root
        end
        bg.CFrame = camera.CFrame
        hum.PlatformStand = true
        bv.Velocity = move.Magnitude > 0 and move.Unit * Nexus.Settings.FlySpeed or Vector3.zero
        if UserInputService.TouchEnabled then
            if flyDownButton then flyDownButton.Visible = true end
            FlyUpButton.Visible = true
        end
    else
        finishFly()
    end

    if movementFrame >= 0.10 then
        movementFrame = 0
        if Nexus.State.Noclip then
            updateNoclip()
        else
            restoreNoclip()
        end
    end

    if environmentFrame >= 0.20 then
        environmentFrame = 0
        if Nexus.State.Fullbright then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        end
        if Nexus.State.NoFog then
            Lighting.FogStart = 0
            Lighting.FogEnd = 1e9
        end
    end
end)

connect(UserInputService.JumpRequest, function()
    if Nexus.State.InfiniteJump then
        local hum = getHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Anti AFK
local function setAntiAFK(enabled)
    if enabled then
        if Nexus._AntiAFK then return end
        Nexus._AntiAFK = connect(LocalPlayer.Idled, function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    else
        if Nexus._AntiAFK then
            destroyConnection(Nexus._AntiAFK)
            Nexus._AntiAFK = nil
        end
    end
end

-- Restore environment when character changes / features stop
connect(Workspace.DescendantAdded, function(obj)
    if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and isEnemyModel(obj) then
        task.defer(function() hookEnemyDeath(obj) end)
    end
end)

connect(LocalPlayer.CharacterAdded, function(char)
    task.wait(1)
    if Nexus._GodGuard then
        destroyConnection(Nexus._GodGuard)
        Nexus._GodGuard = nil
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and Nexus.State.GodMode then
        Nexus._GodGuard = connect(hum.HealthChanged, function(hp)
            if Nexus.State.GodMode and hp > 0 and hp < hum.MaxHealth then
                pcall(function() hum.Health = hum.MaxHealth end)
            end
        end)
        pcall(function() hum.Health = hum.MaxHealth end)
    end
    if hum and not Nexus.State.Speed then
        hum.WalkSpeed = Nexus.Original.WalkSpeed
    end
end)

--////////////////////////////////////////////////////////////////
--  NEXUS UI
--////////////////////////////////////////////////////////////////

local GuiParent = LocalPlayer:WaitForChild("PlayerGui")

local old = GuiParent:FindFirstChild("Nexus99Night")
if old then
    old:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
Nexus.ScreenGui = ScreenGui
ScreenGui.Name = "Nexus99Night"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = GuiParent

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 520, 0, 350)
Main.Position = UDim2.new(0.5, -260, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(16, 17, 22)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.ZIndex = 1
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(56, 58, 70)
MainStroke.Transparency = 0.15
MainStroke.Thickness = 1
MainStroke.Parent = Main
local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 19, 25)),
    ColorSequenceKeypoint.new(0.48, Color3.fromRGB(14, 15, 20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 22, 30))
})
MainGradient.Rotation = 25
MainGradient.Parent = Main

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 54)
Top.BackgroundColor3 = Color3.fromRGB(21, 22, 29)
Top.BorderSizePixel = 0
Top.Parent = Main

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 14)
TopCorner.Parent = Top
Top.ZIndex = 2
Top.ClipsDescendants = true
Top.BackgroundTransparency = 0.03
Top.ClipsDescendants = true

local TopGradient = Instance.new("UIGradient")
TopGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 30, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(19, 21, 29))
})
TopGradient.Rotation = 90
TopGradient.Parent = Top

local Accent = Instance.new("Frame")
Accent.Position = UDim2.new(0, 3, 0, 9)
Accent.Size = UDim2.new(0, 2, 1, -18)
Accent.BackgroundColor3 = Color3.fromRGB(90, 150, 255)
Accent.BorderSizePixel = 0
Accent.Parent = Top

local AccentCorner = Instance.new("UICorner")
AccentCorner.CornerRadius = UDim.new(0, 4)
AccentCorner.Parent = Accent

local AccentGradient = Instance.new("UIGradient")
AccentGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(94, 164, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 90, 255))
})
AccentGradient.Rotation = 90
AccentGradient.Parent = Accent

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 58, 0, 7)
Title.Size = UDim2.new(0, 300, 0, 23)
Title.Font = Enum.Font.GothamBold
Title.Text = "NEXUS 99 NIGHT"
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(245, 247, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.new(0, 60, 0, 30)
Subtitle.Size = UDim2.new(0, 320, 0, 16)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "99 Nights in the Forest • Standalone"
Subtitle.TextSize = 10
Subtitle.TextColor3 = Color3.fromRGB(142, 146, 160)
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Top

local Status = Instance.new("TextLabel")
Status.BackgroundTransparency = 1
Status.AnchorPoint = Vector2.new(1, 0.5)
Status.Position = UDim2.new(1, -48, 0.5, 0)
Status.Size = UDim2.new(0, 104, 0, 24)
Status.Font = Enum.Font.GothamMedium
Status.Text = "● ONLINE"
Status.TextSize = 11
Status.TextColor3 = Color3.fromRGB(90, 235, 135)
Status.TextXAlignment = Enum.TextXAlignment.Right
Status.TextTruncate = Enum.TextTruncate.AtEnd
Status.Parent = Top

-- NEXUS logo
local Logo = Instance.new("Frame")
Logo.Name = "NexusLogo"
Logo.Position = UDim2.new(0, 12, 0, 10)
Logo.Size = UDim2.new(0, 36, 0, 36)
Logo.BackgroundColor3 = Color3.fromRGB(37, 43, 60)
Logo.BorderSizePixel = 0
Logo.Parent = Top

local LogoCorner = Instance.new("UICorner")
LogoCorner.CornerRadius = UDim.new(0, 12)
LogoCorner.Parent = Logo

local LogoStroke = Instance.new("UIStroke")
LogoStroke.Color = Color3.fromRGB(93, 155, 255)
LogoStroke.Thickness = 1.5
LogoStroke.Transparency = 0.15
LogoStroke.Parent = Logo

local LogoGradient = Instance.new("UIGradient")
LogoGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(43, 51, 78)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(40, 69, 122)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(29, 34, 53))
})
LogoGradient.Rotation = 35
LogoGradient.Parent = Logo

local LogoN = Instance.new("TextLabel")
LogoN.BackgroundTransparency = 1
LogoN.Size = UDim2.new(1, 0, 1, 0)
LogoN.Font = Enum.Font.GothamBlack
LogoN.Text = "N"
LogoN.TextSize = 22
LogoN.TextColor3 = Color3.fromRGB(232, 239, 255)
LogoN.Parent = Logo

local LogoMark = Instance.new("Frame")
LogoMark.AnchorPoint = Vector2.new(0.5, 0.5)
LogoMark.Position = UDim2.new(0.5, 0, 0.5, 0)
LogoMark.Size = UDim2.new(0, 24, 0, 2)
LogoMark.Rotation = -35
LogoMark.BackgroundColor3 = Color3.fromRGB(106, 171, 255)
LogoMark.BorderSizePixel = 0
LogoMark.ZIndex = 3
LogoMark.Parent = Logo

local HideButton = Instance.new("TextButton")
HideButton.Name = "HideButton"
HideButton.AnchorPoint = Vector2.new(1, 0.5)
HideButton.Position = UDim2.new(1, -12, 0.5, 0)
HideButton.Size = UDim2.new(0, 30, 0, 30)
HideButton.AutoButtonColor = false
HideButton.BackgroundColor3 = Color3.fromRGB(34, 35, 44)
HideButton.BorderSizePixel = 0
HideButton.Text = "×"
HideButton.Font = Enum.Font.GothamBold
HideButton.TextSize = 16
HideButton.TextColor3 = Color3.fromRGB(195, 199, 212)
HideButton.Parent = Top

local HideCorner = Instance.new("UICorner")
HideCorner.CornerRadius = UDim.new(0, 8)
HideCorner.Parent = HideButton

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "NexusOpenButton"
OpenButton.AnchorPoint = Vector2.new(1, 1)
OpenButton.Position = UDim2.new(1, -16, 1, -16)
OpenButton.Size = UDim2.new(0, 46, 0, 46)
OpenButton.Visible = false
OpenButton.AutoButtonColor = false
OpenButton.BackgroundColor3 = Color3.fromRGB(37, 47, 75)
OpenButton.BorderSizePixel = 0
OpenButton.Text = "N99"
OpenButton.Font = Enum.Font.GothamBlack
OpenButton.TextSize = 18
OpenButton.TextColor3 = Color3.fromRGB(235, 241, 255)
OpenButton.ZIndex = 50
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

local OpenGradient = Instance.new("UIGradient")
OpenGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(58, 91, 160)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(84, 72, 166)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(38, 45, 74))
})
OpenGradient.Rotation = 135
OpenGradient.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(89, 150, 255)
OpenStroke.Thickness = 2
OpenStroke.Parent = OpenButton

local OpenSub = Instance.new("TextLabel")
OpenSub.BackgroundTransparency = 1
OpenSub.AnchorPoint = Vector2.new(0.5, 1)
OpenSub.Position = UDim2.new(0.5, 0, 1, -2)
OpenSub.Size = UDim2.new(1, 0, 0, 13)
OpenSub.Font = Enum.Font.GothamBold
OpenSub.Text = ""
OpenSub.TextSize = 8
OpenSub.TextColor3 = Color3.fromRGB(113, 170, 255)
OpenSub.Visible = false

local FlyDownButton = Instance.new("TextButton")
FlyDownButton.Name = "FlyDownButton"
FlyDownButton.AnchorPoint = Vector2.new(1, 1)
FlyDownButton.Position = UDim2.new(1, -170, 1, -78)
FlyDownButton.Size = UDim2.new(0, 44, 0, 44)
FlyDownButton.AutoButtonColor = false
FlyDownButton.BackgroundColor3 = Color3.fromRGB(25, 29, 40)
FlyDownButton.BorderSizePixel = 0
FlyDownButton.Text = "↓"
FlyDownButton.Font = Enum.Font.GothamBlack
FlyDownButton.TextSize = 22
FlyDownButton.TextColor3 = Color3.fromRGB(220, 232, 255)
FlyDownButton.Visible = false
FlyDownButton.ZIndex = 50
FlyDownButton.Parent = ScreenGui
flyDownButton = FlyDownButton
local FlyDownCorner = Instance.new("UICorner")
FlyDownCorner.CornerRadius = UDim.new(1, 0)
FlyDownCorner.Parent = FlyDownButton
local FlyDownStroke = Instance.new("UIStroke")
FlyDownStroke.Color = Color3.fromRGB(86, 146, 255)
FlyDownStroke.Transparency = 0.2
FlyDownStroke.Parent = FlyDownButton
FlyUpButton = Instance.new("TextButton")
FlyUpButton.Name = "FlyUpButton"
FlyUpButton.AnchorPoint = Vector2.new(1, 1)
FlyUpButton.Position = UDim2.new(1, -170, 1, -130)
FlyUpButton.Size = UDim2.new(0, 44, 0, 44)
FlyUpButton.AutoButtonColor = false
FlyUpButton.BackgroundColor3 = Color3.fromRGB(25, 29, 40)
FlyUpButton.BorderSizePixel = 0
FlyUpButton.Text = "↑"
FlyUpButton.Font = Enum.Font.GothamBlack
FlyUpButton.TextSize = 22
FlyUpButton.TextColor3 = Color3.fromRGB(220, 232, 255)
FlyUpButton.Visible = false
FlyUpButton.ZIndex = 50
FlyUpButton.Parent = ScreenGui
local FlyUpCorner = Instance.new("UICorner")
FlyUpCorner.CornerRadius = UDim.new(1, 0)
FlyUpCorner.Parent = FlyUpButton
local FlyUpStroke = Instance.new("UIStroke")
FlyUpStroke.Color = Color3.fromRGB(86, 146, 255)
FlyUpStroke.Transparency = 0.2
FlyUpStroke.Parent = FlyUpButton
connect(FlyUpButton.MouseButton1Down, function() Nexus.FlyUp = true end)
connect(FlyUpButton.MouseButton1Up, function() Nexus.FlyUp = false end)
connect(FlyUpButton.InputEnded, function() Nexus.FlyUp = false end)
connect(FlyDownButton.MouseButton1Down, function()
    Nexus.FlyDown = true
end)
connect(FlyDownButton.MouseButton1Up, function()
    Nexus.FlyDown = false
end)
connect(FlyDownButton.InputEnded, function()
    Nexus.FlyDown = false
end)

local function setUIVisible(visible)
    Nexus.UIVisible = visible
    Main.Visible = visible
    OpenButton.Visible = not visible
    if not Nexus.State.Fly then
        FlyDownButton.Visible = false
        FlyUpButton.Visible = false
    end
end

local function refreshCombatStatus()
    local remote = getDamageRemote()
    local weapon = getCombatWeapon()
    if remote and weapon then
        Status.Text = "● READY"
        Status.TextColor3 = Color3.fromRGB(90, 235, 135)
    elseif remote then
        Status.Text = "● AXE"
        Status.TextColor3 = Color3.fromRGB(255, 205, 90)
    else
        Status.Text = "● ONLINE"
        Status.TextColor3 = Color3.fromRGB(90, 235, 135)
    end
end

connect(HideButton.MouseButton1Click, function()
    setUIVisible(false)
end)
connect(OpenButton.MouseEnter, function()
    OpenButton.Size = UDim2.new(0, 50, 0, 50)
end)
connect(OpenButton.MouseLeave, function()
    OpenButton.Size = UDim2.new(0, 46, 0, 46)
end)
connect(OpenButton.MouseButton1Click, function()
    setUIVisible(true)
end)

connect(HideButton.MouseEnter, function()
    HideButton.BackgroundColor3 = Color3.fromRGB(75, 45, 60)
    HideButton.TextColor3 = Color3.fromRGB(255, 230, 240)
end)
connect(HideButton.MouseLeave, function()
    HideButton.BackgroundColor3 = Color3.fromRGB(34, 35, 44)
    HideButton.TextColor3 = Color3.fromRGB(195, 199, 212)
end)
connect(UserInputService.InputBegan, function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        setUIVisible(not Nexus.UIVisible)
    end
end)

-- Drag
do
    local dragging = false
    local dragStart
    local startPos

    connect(Top.InputBegan, function(input)
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

    connect(UserInputService.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local TabBar = Instance.new("Frame")
TabBar.Position = UDim2.new(0, 0, 0, 54)
TabBar.Size = UDim2.new(0, 96, 1, -54)
TabBar.BackgroundColor3 = Color3.fromRGB(19, 20, 26)
TabBar.BorderSizePixel = 0
TabBar.Parent = Main

local TabPadding = Instance.new("UIPadding")
TabPadding.PaddingTop = UDim.new(0, 10)
TabPadding.PaddingLeft = UDim.new(0, 7)
TabPadding.PaddingRight = UDim.new(0, 7)
TabPadding.Parent = TabBar

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 5)
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabBar

local Content = Instance.new("Frame")
Content.Position = UDim2.new(0, 96, 0, 54)
Content.Size = UDim2.new(1, -96, 1, -54)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.ZIndex = 2
Content.Parent = Main

local Pages = {}
local TabButtons = {}

local function makeTab(name)
    local button = Instance.new("TextButton")
    button.AutoButtonColor = false
    button.Size = UDim2.new(1, 0, 0, 31)
    button.BackgroundColor3 = Color3.fromRGB(27, 28, 36)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamMedium
    button.Text = name
    button.TextSize = 11
    button.TextColor3 = Color3.fromRGB(176, 180, 194)
    button.Parent = TabBar

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 9)
    bc.Parent = button

    local tabAccent = Instance.new("Frame")
    tabAccent.Name = "ActiveAccent"
    tabAccent.Position = UDim2.new(0, 0, 0, 6)
    tabAccent.Size = UDim2.new(0, 3, 1, -12)
    tabAccent.BackgroundColor3 = Color3.fromRGB(91, 151, 255)
    tabAccent.BorderSizePixel = 0
    tabAccent.Visible = false
    tabAccent.Parent = button
    local tac = Instance.new("UICorner")
    tac.CornerRadius = UDim.new(1, 0)
    tac.Parent = tabAccent

    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.new(1, -14, 1, -14)
    page.Position = UDim2.new(0, 7, 0, 7)
    page.CanvasSize = UDim2.new()
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Active = true
    page.ScrollingEnabled = true
    page.ClipsDescendants = true
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(83, 87, 103)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Visible = false
    page.Parent = Content

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 6)
    padding.PaddingRight = UDim.new(0, 6)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = page

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    Pages[name] = page
    TabButtons[name] = button

    connect(button.MouseButton1Click, function()
        for n, p in pairs(Pages) do
            p.Visible = n == name
            local b = TabButtons[n]
            b.BackgroundColor3 = n == name and Color3.fromRGB(44, 49, 64) or Color3.fromRGB(25, 26, 34)
            b.TextColor3 = n == name and Color3.fromRGB(241, 244, 255) or Color3.fromRGB(167, 171, 187)
            local accent = b:FindFirstChild("ActiveAccent")
            if accent then accent.Visible = n == name end
        end
    end)

    return page
end

local function makeSection(page, title, desc)
    local holder = Instance.new("Frame")
    holder.BackgroundColor3 = Color3.fromRGB(22, 23, 30)
    holder.BorderSizePixel = 0
    holder.AutomaticSize = Enum.AutomaticSize.Y
    holder.Size = UDim2.new(1, 0, 0, 0)
    holder.ClipsDescendants = true
    holder.Parent = page

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 11)
    corner.Parent = holder

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(48, 50, 61)
    stroke.Transparency = 0.35
    stroke.Parent = holder

    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 12, 0, 9)
    titleLabel.Size = UDim2.new(1, -28, 0, 21)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextSize = 12
    titleLabel.TextColor3 = Color3.fromRGB(236, 238, 246)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = holder

    local descLabel = Instance.new("TextLabel")
    descLabel.BackgroundTransparency = 1
    descLabel.Position = UDim2.new(0, 12, 0, 29)
    descLabel.Size = UDim2.new(1, -28, 0, 18)
    descLabel.Font = Enum.Font.Gotham
    descLabel.Text = desc or ""
    descLabel.TextSize = 9
    descLabel.TextColor3 = Color3.fromRGB(130, 134, 149)
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = holder

    local body = Instance.new("Frame")
    body.BackgroundTransparency = 1
    body.Position = UDim2.new(0, 10, 0, 52)
    body.Size = UDim2.new(1, -24, 0, 0)
    body.AutomaticSize = Enum.AutomaticSize.Y
    body.Parent = holder

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 6)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = body

    return body
end

local function makeToggle(parent, title, desc, key, callback)
    local button = Instance.new("TextButton")
    button.AutoButtonColor = false
    button.Size = UDim2.new(1, 0, 0, 51)
    button.BackgroundColor3 = Color3.fromRGB(29, 30, 38)
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = button

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 12, 0, 7)
    label.Size = UDim2.new(1, -78, 0, 19)
    label.Font = Enum.Font.GothamMedium
    label.Text = title
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(225, 228, 237)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = button

    local d = Instance.new("TextLabel")
    d.BackgroundTransparency = 1
    d.Position = UDim2.new(0, 12, 0, 27)
    d.Size = UDim2.new(1, -78, 0, 18)
    d.Font = Enum.Font.Gotham
    d.Text = desc or ""
    d.TextSize = 10
    d.TextColor3 = Color3.fromRGB(123, 127, 142)
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.Parent = button

    local switch = Instance.new("Frame")
    switch.AnchorPoint = Vector2.new(1, 0.5)
    switch.Position = UDim2.new(1, -12, 0.5, 0)
    switch.Size = UDim2.new(0, 42, 0, 22)
    switch.BackgroundColor3 = Color3.fromRGB(46, 48, 57)
    switch.BorderSizePixel = 0
    switch.Parent = button

    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(1, 0)
    sc.Parent = switch

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(208, 211, 220)
    knob.BorderSizePixel = 0
    knob.Parent = switch

    local kc = Instance.new("UICorner")
    kc.CornerRadius = UDim.new(1, 0)
    kc.Parent = knob

    local function setVisual(on)
        switch.BackgroundColor3 = on and Color3.fromRGB(72, 142, 255) or Color3.fromRGB(46, 48, 57)
        knob.Position = on and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    end

    local function setState(on)
        Nexus.State[key] = on
        setVisual(on)
        if callback then
            safeCall(callback, on)
        end
    end

    setVisual(Nexus.State[key] == true)

    connect(button.MouseButton1Click, function()
        setState(not Nexus.State[key])
    end)

    return {
        SetValue = setState,
        GetValue = function() return Nexus.State[key] end,
    }
end

local function makeButton(parent, title, desc, callback)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.Size = UDim2.new(1, 0, 0, 42)
    b.BackgroundColor3 = Color3.fromRGB(29, 30, 38)
    b.BorderSizePixel = 0
    b.Text = ""
    b.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = b

    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Position = UDim2.new(0, 12, 0, 5)
    t.Size = UDim2.new(1, -24, 0, 18)
    t.Font = Enum.Font.GothamMedium
    t.Text = title
    t.TextSize = 12
    t.TextColor3 = Color3.fromRGB(225, 228, 237)
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = b

    local ds = Instance.new("TextLabel")
    ds.BackgroundTransparency = 1
    ds.Position = UDim2.new(0, 12, 0, 23)
    ds.Size = UDim2.new(1, -24, 0, 15)
    ds.Font = Enum.Font.Gotham
    ds.Text = desc or ""
    ds.TextSize = 10
    ds.TextColor3 = Color3.fromRGB(123, 127, 142)
    ds.TextXAlignment = Enum.TextXAlignment.Left
    ds.Parent = b

    connect(b.MouseEnter, function()
        b.BackgroundColor3 = Color3.fromRGB(39, 43, 55)
    end)
    connect(b.MouseLeave, function()
        b.BackgroundColor3 = Color3.fromRGB(29, 30, 38)
    end)
    connect(b.MouseButton1Down, function()
        b.BackgroundColor3 = Color3.fromRGB(47, 53, 68)
    end)
    connect(b.MouseButton1Up, function()
        b.BackgroundColor3 = Color3.fromRGB(39, 43, 55)
    end)
    connect(b.MouseButton1Click, callback)

    return b
end

local function makeInput(parent, title, placeholder, default, callback)
    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(1, 0, 0, 60)
    wrap.BackgroundTransparency = 1
    wrap.Parent = parent

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(1, 0, 0, 18)
    label.Font = Enum.Font.GothamMedium
    label.Text = title
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(205, 208, 219)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = wrap

    local box = Instance.new("TextBox")
    box.ClearTextOnFocus = false
    box.Position = UDim2.new(0, 0, 0, 24)
    box.Size = UDim2.new(1, 0, 0, 32)
    box.BackgroundColor3 = Color3.fromRGB(28, 29, 37)
    box.BorderSizePixel = 0
    box.Font = Enum.Font.Gotham
    box.PlaceholderText = placeholder or ""
    box.PlaceholderColor3 = Color3.fromRGB(105, 108, 120)
    box.Text = default or ""
    box.TextSize = 11
    box.TextColor3 = Color3.fromRGB(230, 233, 241)
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.Parent = wrap

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 7)
    bc.Parent = box

    local bp = Instance.new("UIPadding")
    bp.PaddingLeft = UDim.new(0, 10)
    bp.PaddingRight = UDim.new(0, 10)
    bp.Parent = box

    connect(box.FocusLost, function()
        safeCall(callback, box.Text)
    end)

    return box
end

local function makeSlider(parent, title, min, max, default, callback)
    local wrap = Instance.new("Frame")
    wrap.Size = UDim2.new(1, 0, 0, 54)
    wrap.BackgroundTransparency = 1
    wrap.Parent = parent

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.7, 0, 0, 20)
    label.Font = Enum.Font.GothamMedium
    label.Text = title
    label.TextSize = 11
    label.TextColor3 = Color3.fromRGB(205, 208, 219)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = wrap

    local value = Instance.new("TextLabel")
    value.BackgroundTransparency = 1
    value.AnchorPoint = Vector2.new(1, 0)
    value.Position = UDim2.new(1, 0, 0, 0)
    value.Size = UDim2.new(0.25, 0, 0, 20)
    value.Font = Enum.Font.GothamMedium
    value.TextSize = 11
    value.TextColor3 = Color3.fromRGB(128, 177, 255)
    value.TextXAlignment = Enum.TextXAlignment.Right
    value.Parent = wrap

    local bar = Instance.new("TextButton")
    bar.AutoButtonColor = false
    bar.Text = ""
    bar.Position = UDim2.new(0, 0, 0, 28)
    bar.Size = UDim2.new(1, 0, 0, 9)
    bar.BackgroundColor3 = Color3.fromRGB(49, 51, 61)
    bar.BorderSizePixel = 0
    bar.Parent = wrap

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(1, 0)
    bc.Parent = bar

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(76, 145, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bar

    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(1, 0)
    fc.Parent = fill

    local current = default

    local function set(v)
        current = math.clamp(v, min, max)
        fill.Size = UDim2.new((current - min) / (max - min), 0, 1, 0)
        value.Text = tostring(math.floor(current))
        safeCall(callback, current)
    end

    set(default)

    local dragging = false
    connect(bar.MouseButton1Down, function()
        dragging = true
        local x = UserInputService:GetMouseLocation().X
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        set(min + (max - min) * rel)
    end)

    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    connect(UserInputService.InputChanged, function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local x = input.Position.X
            local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            set(min + (max - min) * rel)
        end
    end)

    return {SetValue = set}
end

-- Tabs
local HomePage = makeTab("Home")
local CombatPage = makeTab("Combat")
local FarmPage = makeTab("Farm")
local VisualsPage = makeTab("Visuals")
local MovementPage = makeTab("Movement")
local TeleportPage = makeTab("Teleport")
local SettingsPage = makeTab("Settings")

local homeSec = makeSection(HomePage, "NEXUS 99 NIGHT", "Standalone control hub")
makeButton(homeSec, "Refresh ESP", "Rebuild current ESP objects", function() task.spawn(refreshESP) end)
makeButton(homeSec, "Bring All Items", "Move common loot categories to you", function() bringByCategory("items") end)
makeButton(homeSec, "Bring Weapons", "Pull weapons to your position", function() bringByCategory("weapons") end)
makeButton(homeSec, "Bring Food", "Pull food to your position", function() bringByCategory("food") end)
makeButton(homeSec, "Bring Scrap", "Pull scrap and parts to your position", function() bringByCategory("scrap") end)
makeButton(homeSec, "Bring Gems", "Pull forest/cultist gems to you", function() bringByCategory("gems") end)
makeButton(homeSec, "Bring Heals", "Pull Bandage / MedKit to you", function() bringByCategory("heals") end)
makeButton(homeSec, "Bring Enemy Drops", "Pull loot near enemy corpses/deaths", function() task.spawn(bringEnemyDrops) end)
makeButton(homeSec, "Open All Item Chests", "Open chests in Items without teleporting them", function() task.spawn(openAllItemChests) end)
makeToggle(homeSec, "God Mode", "Local health guard without sending the damage remote", "GodMode", godModeOnce)
makeButton(homeSec, "Teleport To Camp", "Exact Campground fire location", function() teleportNamed({"campfire", "camp fire", "warm place", "camp"}) end)

local combatSec = makeSection(CombatPage, "Combat", "Current ToolDamageObject / weapon-resource path")
makeButton(combatSec, "Combat Engine", "Refresh weapon + damage remote status", refreshCombatStatus)
makeToggle(combatSec, "Kill Aura", "Attack the closest hostile animal/NPC in range", "KillAura")
makeToggle(combatSec, "Tree Aura", "Rapid axe hits on nearby trees", "TreeAura")
makeToggle(combatSec, "Freeze Enemies", "Freeze all currently detected hostile animals", "FreezeEnemies")
makeButton(combatSec, "Kill All Enemies", "Kill hostile animals/NPCs and then collect their nearby drops", function()
    task.spawn(function() killAllEnemies(); refreshCombatStatus() end)
end)
makeButton(combatSec, "Bring Enemy Drops", "Pull enemy corpses + nearby loot to you", function() task.spawn(bringEnemyDrops) end)
makeButton(combatSec, "Chop All Trees (once)", "Hit nearby map trees with your current axe", function()
    Nexus.State.TreeAura = true
    damageNearbyTrees()
    Nexus.State.TreeAura = false
end)
makeSlider(combatSec, "Kill Aura Radius", 10, 500, Nexus.Settings.KillAuraRadius, function(v)
    Nexus.Settings.KillAuraRadius = v
end)
makeSlider(combatSec, "Tree Radius", 15, 1000, Nexus.Settings.TreeRadius, function(v)
    Nexus.Settings.TreeRadius = v
end)

local farmSec = makeSection(FarmPage, "Automation", "Resource, survival and collection loops")
makeToggle(farmSec, "Auto Chop", "Chop trees across the map up to the selected radius", "AutoChop")
makeToggle(farmSec, "Auto Eat", "Use food when hunger is low", "AutoEat")
makeToggle(farmSec, "Auto Heal", "Use healing tools when health is low", "AutoHeal")
makeToggle(farmSec, "Auto Fuel", "Send map-wide logs/coal/fuel to the fire + auto-feed the fire zone", "AutoFuel")
makeToggle(farmSec, "Campfire Zone Feed", "Auto-burn Log / Coal / Fuel items dropped inside the fire circle", "CampfireZoneFeed")
makeToggle(farmSec, "Bring Items", "Continuously collect common loot", "BringItems")
makeToggle(farmSec, "Bring Trees", "Continuously pull tree objects", "BringTrees")
makeToggle(farmSec, "Bring Chopped", "Pull cut logs / wood piles", "BringChopped")
makeToggle(farmSec, "Auto Plant", "Attempt to use sapling/seed tools", "AutoPlant")
makeToggle(farmSec, "Auto Cook", "Cook raw meat at the campfire", "AutoCook")
makeButton(farmSec, "Bring Food", "Pull all supported food items", function() bringByCategory("food") end)
makeButton(farmSec, "Bring Fuel", "Pull logs/coal/fuel to you", function() bringByCategory("fuel") end)
makeButton(farmSec, "Bring Weapons", "Pull common weapons/axes to you", function() bringByCategory("weapons") end)
makeButton(farmSec, "Bring Scrap", "Pull supported scrap items", function() bringByCategory("scrap") end)
makeButton(farmSec, "Bring Gems", "Pull forest/cultist gems", function() bringByCategory("gems") end)
makeButton(farmSec, "Bring Heals", "Pull Bandages and MedKits", function() bringByCategory("heals") end)
makeButton(farmSec, "Bring Armor", "Pull supported armor items", function() bringByCategory("armor") end)
makeButton(farmSec, "Bring Explosives", "Pull supported explosives", function() bringByCategory("explosives") end)
makeButton(farmSec, "Open All Item Chests", "Open chests without moving them", function() task.spawn(openAllItemChests) end)

local itemInput = makeInput(
    farmSec,
    "Item Name",
    "Example: Log",
    Nexus.Settings.SelectedItem,
    function(v)
        Nexus.Settings.SelectedItem = v
    end
)

local visualsSec = makeSection(VisualsPage, "ESP", "Through-wall highlights for common entities")
makeToggle(visualsSec, "Players ESP", "Highlight other players", "ESPPlayers", refreshESP)
makeToggle(visualsSec, "Enemy ESP", "Highlight common enemies", "ESPEnemies", refreshESP)
makeToggle(visualsSec, "Item ESP", "Highlight common loot and resources", "ESPItems", refreshESP)
makeToggle(visualsSec, "Chest ESP", "Highlight chests and crates", "ESPChests", refreshESP)
makeToggle(visualsSec, "Child ESP", "Highlight lost/missing children", "ESPChildren", refreshESP)
makeToggle(visualsSec, "Fullbright", "Remove darkness from the map", "Fullbright")
makeToggle(visualsSec, "No Fog", "Remove scene fog", "NoFog")
makeToggle(visualsSec, "Instant Interact", "Set proximity prompt hold time to zero", "InstantInteract", function(v) setInstantInteract(v) end)

local moveSec = makeSection(MovementPage, "Movement", "Player movement utilities")
makeToggle(moveSec, "Speed", "Set a custom walk speed", "Speed")
makeSlider(moveSec, "Walk Speed", 16, 150, Nexus.Settings.WalkSpeed, function(v)
    Nexus.Settings.WalkSpeed = v
end)
makeToggle(moveSec, "Fly", "Client-side free movement", "Fly")
makeSlider(moveSec, "Fly Speed", 20, 150, Nexus.Settings.FlySpeed, function(v)
    Nexus.Settings.FlySpeed = v
end)
makeToggle(moveSec, "No Clip", "Disable character collisions", "Noclip")
makeToggle(moveSec, "Infinite Jump", "Jump repeatedly in the air", "InfiniteJump")
makeToggle(moveSec, "Anti AFK", "Prevent idle kick", "AntiAFK", setAntiAFK)

local tpSec = makeSection(TeleportPage, "Locations", "Stable map teleports with ground placement")
makeButton(tpSec, "Campfire / Camp", "Exact Map.Campground.InnerTouchZone", function()
    local fire = ExactTeleportPaths.Campfire and safeCall(ExactTeleportPaths.Campfire)
    local cf = getTeleportTargetFromInstance(fire)
    if cf then teleportToGround(cf * CFrame.new(0, 5, 0)) end
end)
makeButton(tpSec, "Teleport Back", "Return to your previous position", function()
    if Nexus.LastTeleportCF then safeTeleportCF(Nexus.LastTeleportCF) end
end)
makeButton(tpSec, "Teleport To Cursor", "Tap/click a place and teleport there", function()
    teleportToCursor()
end)
makeButton(tpSec, "Caravan / Trader", "Find the stable trader location", function()
    teleportNamed({"caravan", "trader", "merchant"})
end)
makeButton(tpSec, "Crafting Bench", "Exact Campground.CraftingBench", function()
    local obj = ExactTeleportPaths.CraftingBench and safeCall(ExactTeleportPaths.CraftingBench)
    local cf = getTeleportTargetFromInstance(obj)
    if cf then teleportToGround(cf) else teleportNamed({"craftingbench", "crafting bench"}) end
end)
makeButton(tpSec, "Biofuel Processor", "Teleport to the processor", function()
    local obj = ExactTeleportPaths.Biofuel and safeCall(ExactTeleportPaths.Biofuel)
    local cf = getTeleportTargetFromInstance(obj)
    if cf then teleportToGround(cf) else teleportNamed({"biofuel processor", "biofuel"}) end
end)
makeButton(tpSec, "Crock Pot", "Teleport to the crock pot", function()
    local obj = ExactTeleportPaths.CrockPot and safeCall(ExactTeleportPaths.CrockPot)
    local cf = getTeleportTargetFromInstance(obj)
    if cf then teleportToGround(cf) else teleportNamed({"crock pot", "crockpot"}) end
end)
makeButton(tpSec, "Anvil / Forge", "Find the nearest crafting forge", function()
    teleportNamed({"anvil", "forge", "blacksmith"})
end)
makeButton(tpSec, "Dino Kid", "Teleport to the first lost child", function()
    teleportNamed({"dino kid", "lost child"})
end)
makeButton(tpSec, "Kraken Kid", "Teleport to Kraken Kid", function()
    teleportNamed({"kraken kid", "lost child2"})
end)
makeButton(tpSec, "Squid Kid", "Teleport to Squid Kid", function()
    teleportNamed({"squid kid", "lost child3"})
end)
makeButton(tpSec, "Koala Kid", "Teleport to Koala Kid", function()
    teleportNamed({"koala kid", "lost child4"})
end)
makeButton(tpSec, "Tree", "Teleport to the nearest tree on the map", function()
    teleportNamed({"treebig1", "treebig2", "treebig3", "small tree", "snowy small tree", "dead tree"})
end)
makeButton(tpSec, "Weapon / Gun", "Find a dropped weapon or firearm", function()
    teleportNamed({"revolver", "rifle", "weapon", "sword", "spear", "shotgun", "chainsaw"})
end)
makeInput(tpSec, "Player", "Player name / display name", "", function(v)
    Nexus.TeleportPlayerName = v
end)
makeButton(tpSec, "Teleport To Player", "Teleport to the first matching player", function()
    teleportToPlayer(Nexus.TeleportPlayerName)
end)

local settingsSec = makeSection(SettingsPage, "Settings", "Nexus 99 Night controls")
makeButton(settingsSec, "Rebuild UI", "Destroy and recreate the hub", function()
    ScreenGui:Destroy()
end)
makeButton(settingsSec, "Clear ESP", "Remove all current highlights", clearESP)
makeButton(settingsSec, "Restore Lighting", "Restore the original lighting values", function()
    Lighting.FogStart = Nexus.Original.FogStart
    Lighting.FogEnd = Nexus.Original.FogEnd
    Lighting.Brightness = Nexus.Original.Brightness
    Lighting.ClockTime = Nexus.Original.ClockTime
    Lighting.Ambient = Nexus.Original.Ambient
    Lighting.OutdoorAmbient = Nexus.Original.OutdoorAmbient
end)
makeButton(settingsSec, "Restore Movement", "Reset WalkSpeed and remove fly body velocity", function()
    local hum = getHumanoid()
    local root = getRoot()
    if hum then
        hum.WalkSpeed = Nexus.Original.WalkSpeed
        hum.JumpPower = Nexus.Original.JumpPower
    end
    if root then
        local bv = root:FindFirstChild("Nexus99_Fly")
        local bg = root:FindFirstChild("Nexus99_FlyGyro")
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
    restoreNoclip()
end)
makeButton(settingsSec, "Unload Nexus", "Turn off loops, remove UI and clean connections", function()
    Nexus.Running = false
    stopAllThreads()
    clearESP()
    restoreFrozenEnemies()
    table.clear(Nexus.EnemyHooked)
    table.clear(Nexus.DeathRecords)

    if Nexus._AntiAFK then
        destroyConnection(Nexus._AntiAFK)
        Nexus._AntiAFK = nil
    end
    if Nexus._InstantInteract then
        destroyConnection(Nexus._InstantInteract)
        Nexus._InstantInteract = nil
    end

    local hum = getHumanoid()
    local root = getRoot()
    if hum then
        hum.WalkSpeed = Nexus.Original.WalkSpeed
        hum.JumpPower = Nexus.Original.JumpPower
    end
    if root then
        local bv = root:FindFirstChild("Nexus99_Fly")
        local bg = root:FindFirstChild("Nexus99_FlyGyro")
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
    restoreNoclip()

    for _, c in ipairs(Nexus.Connections) do
        destroyConnection(c)
    end
    Nexus.Connections = {}

    if ScreenGui then
        ScreenGui:Destroy()
    end
end)

-- Mobile-friendly scaling
local UIScale = Instance.new("UIScale")
UIScale.Scale = 1
UIScale.Parent = Main

local function updateUIScale()
    local camera = Workspace.CurrentCamera
    local vp = camera and camera.ViewportSize
    if not vp then return end
    if vp.X < 650 then
        UIScale.Scale = 0.70
    elseif vp.X < 820 then
        UIScale.Scale = 0.82
    elseif vp.X < 1050 then
        UIScale.Scale = 0.92
    else
        UIScale.Scale = 1
    end
end

connect(UserInputService.WindowFocused, updateUIScale)
connect(RunService.RenderStepped, function()
    -- Refresh only when the viewport actually changed.
    local camera = Workspace.CurrentCamera
    local size = camera and camera.ViewportSize
    local stamp = size and (size.X * 10000 + size.Y) or 0
    if Nexus._ViewportStamp ~= stamp then
        Nexus._ViewportStamp = stamp
        updateUIScale()
    end
end)


-- Initial tab
TabButtons["Home"].BackgroundColor3 = Color3.fromRGB(44, 49, 64)
TabButtons["Home"]:FindFirstChild("ActiveAccent").Visible = true
TabButtons["Home"].TextColor3 = Color3.fromRGB(241, 244, 255)
Pages["Home"].Visible = true

task.defer(function()
    scanEnemyHooks()
    local chars = Workspace:FindFirstChild("Characters")
    if chars then
        connect(chars.ChildAdded, function(obj)
            if obj:IsA("Model") then task.defer(function() if isEnemyModel(obj) then hookEnemyDeath(obj) end end) end
        end)
    end
end)

-- Initial ESP rebuild on player joins / respawns
connect(Players.PlayerAdded, function()
    task.delay(1, refreshESP)
end)
connect(Players.PlayerRemoving, function()
    task.delay(0.2, refreshESP)
end)

task.delay(1, function()
    refreshESP()
    refreshCombatStatus()
end)

connect(Players.PlayerAdded, function()
    task.delay(0.5, refreshCombatStatus)
end)
connect(Players.PlayerRemoving, function()
    task.delay(0.2, refreshCombatStatus)
end)

print("[NEXUS 99 NIGHT] Loaded standalone.")
