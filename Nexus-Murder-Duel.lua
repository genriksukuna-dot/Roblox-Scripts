--============================================================
-- NEXUS MURDER DUEL
-- Compact Anime UI • Mobile + PC
-- LocalScript • Fixed Build 10
--
-- Main fix:
--   ESP keeps Skeleton/labels; the old ESP Line/tracer is removed.
--
-- Other fixes:
--   • Skeleton is projected directly into a full-screen mobile-safe overlay.
--   • Teleport Follow keeps the player behind the selected opponent and uses native Tool activation.
--   • Fire is gated by target visibility + aim alignment to reduce misses.
--   • Manual UI scale is respected.
--   • Mobile/PC menu drag is supported.
--============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local Stats = game:GetService("Stats")
local MarketplaceService = game:GetService("MarketplaceService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--============================================================
-- CLEANUP
--============================================================

if _G.NexusMurderDuelCleanup then
    pcall(_G.NexusMurderDuelCleanup)
end

local Connections = {}
local Tracked = {}

local function track(inst)
    Tracked[#Tracked + 1] = inst
    return inst
end

local function connect(signal, callback)
    local c = signal:Connect(callback)
    Connections[#Connections + 1] = c
    return c
end

_G.NexusMurderDuelCleanup = function()
    pcall(function()
        RunService:UnbindFromRenderStep("NexusMurderDuelAim")
        RunService:UnbindFromRenderStep("NexusMurderDuelESP")
    end)

    for _, c in ipairs(Connections) do
        pcall(function()
            c:Disconnect()
        end)
    end

    for _, inst in ipairs(Tracked) do
        pcall(function()
            inst:Destroy()
        end)
    end

    table.clear(Connections)
    table.clear(Tracked)
end

--============================================================
-- THEME
--============================================================

local C = {
    BG = Color3.fromRGB(9, 8, 15),
    PANEL = Color3.fromRGB(17, 14, 27),
    PANEL2 = Color3.fromRGB(23, 19, 36),
    PANEL3 = Color3.fromRGB(43, 31, 67),
    CYAN = Color3.fromRGB(83, 231, 255),
    VIOLET = Color3.fromRGB(161, 92, 255),
    MAGENTA = Color3.fromRGB(255, 82, 197),
    ACCENT = Color3.fromRGB(185, 105, 255),
    ACCENT2 = Color3.fromRGB(101, 208, 255),
    PINK = Color3.fromRGB(255, 121, 206),
    TEXT = Color3.fromRGB(246, 243, 252),
    MUTED = Color3.fromRGB(150, 143, 171),
    GOOD = Color3.fromRGB(102, 232, 157),
    BAD = Color3.fromRGB(255, 104, 135),
    WARN = Color3.fromRGB(255, 208, 100),
    OUTLINE = Color3.fromRGB(79, 67, 107),
}

local FONT = Enum.Font.Gotham
local BOLD = Enum.Font.GothamBold

--============================================================
-- STATE
--============================================================

local State = {
    ESP = {
        Enabled = true,
        Health = true,
        Name = true,
        Skeleton = true,
        Weapon = true,
        Hitbox = true,
        IgnoreTeam = false,
        MaxDistance = 250,
    },

    Aim = {
        Enabled = false,
        Aimbot = false,
        IgnoreTeam = true,
        FOV = 180,
        FOVColor = C.CYAN,
        TeleportShot = false,
        DuelOnly = true,
        CheckVisible = true,
        Sticky = true,
        Stabilizer = true,
        Smoothness = 68,
        Target = nil,
        SmoothedTargetPosition = nil,
    },
}

local CurrentTab = "ESP"
local MenuOpen = true

local updateScale
local clampMenuToViewport

--============================================================
-- HELPERS
--============================================================

local function clone(tbl)
    local out = {}
    for k, v in pairs(tbl) do
        out[k] = type(v) == "table" and clone(v) or v
    end
    return out
end

local function getViewport()
    local camera = Workspace.CurrentCamera
    return camera and camera.ViewportSize or Vector2.new(1280, 720)
end

local function getPing()
    local value = 0
    pcall(function()
        local network = Stats:FindFirstChild("Network")
        local serverStats = network and network:FindFirstChild("ServerStatsItem")
        local item = serverStats and serverStats:FindFirstChild("Data Ping")
        if item then
            value = math.floor(tonumber(item:GetValue()) or 0)
        end
    end)
    return value
end

local function getDevice()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        return "Mobile"
    elseif UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then
        return "Gamepad"
    elseif UserInputService.KeyboardEnabled then
        return "PC"
    end
    return "Unknown"
end

local function getPlatform()
    -- Delta/executor compatibility: some clients expose GuiService but do not
    -- expose GetPlatform(). Do not call a possibly-missing API.
    if UserInputService.TouchEnabled then
        if UserInputService.KeyboardEnabled then
            return "Touch + Keyboard"
        end
        return "Touch"
    end

    if UserInputService.GamepadEnabled then
        return "Gamepad"
    end

    if UserInputService.KeyboardEnabled then
        return "Keyboard / Mouse"
    end

    return "Unknown"
end

local function getWeapon(player)
    local char = player and player.Character
    if not char then
        return "None"
    end
    local tool = char:FindFirstChildOfClass("Tool")
    return tool and tool.Name or "None"
end

local function isAlive(player)
    local char = player and player.Character
    if not char then
        return false
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    return hum ~= nil and hum.Health > 0 and root ~= nil
end

local function getRoot(player)
    local char = player and player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHead(player)
    local char = player and player.Character
    return char and (char:FindFirstChild("Head") or char:FindFirstChild("UpperTorso"))
end

local function findPart(character, ...)
    if not character then
        return nil
    end

    for i = 1, select("#", ...) do
        local name = select(i, ...)
        local part = character:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            return part
        end
    end

    return nil
end


local function getTeamKey(player)
    if not player then
        return nil
    end

    local team = player.Team
    if team then
        return "team:" .. tostring(team.Name)
    end

    for _, name in ipairs({
        "Team", "TeamId", "TeamID", "Side", "Faction", "TeamColor"
    }) do
        local value = player:GetAttribute(name)
        if value ~= nil and tostring(value) ~= "" then
            return name .. ":" .. tostring(value)
        end
    end

    local char = player.Character
    if char then
        for _, name in ipairs({
            "Team", "TeamId", "TeamID", "Side", "Faction", "TeamColor"
        }) do
            local value = char:GetAttribute(name)
            if value ~= nil and tostring(value) ~= "" then
                return name .. ":" .. tostring(value)
            end
        end
    end

    return nil
end

local function sameTeam(player)
    if not player or not LocalPlayer then
        return false
    end

    local a = getTeamKey(LocalPlayer)
    local b = getTeamKey(player)
    return a ~= nil and b ~= nil and a == b
end

local ACTIVE_FOLDERS = {
    "DuelPlayers", "Duelists", "MatchPlayers", "RoundPlayers",
    "Participants", "Contestants", "Playing", "InGame", "Alive",
    "ActivePlayers",
}

local ACTIVE_ATTRS = {
    "InDuel", "Duel", "InMatch", "MatchActive", "InRound",
    "RoundActive", "DuelActive", "Match", "Round", "Playing",
}

local SESSION_ATTRS = {
    "DuelId", "MatchId", "RoundId", "ArenaId", "RoomId", "SessionId",
}

local DUEL_ATTR_WORDS = {"duel", "match", "round", "arena", "opponent", "enemy"}
local DUEL_VALUE_NAMES = {
    "Duel", "InDuel", "DuelActive", "Match", "InMatch", "Round",
    "InRound", "RoundActive", "Opponent", "OpponentUserId", "Enemy",
    "EnemyUserId",
}

local DuelCache = {}
local DuelContainersCache = {}

local function invalidateDuelCache(player)
    if player then
        DuelCache[player] = nil
    end
end

local DuelContainersCacheAt = 0

local function getDuelBoolOrValue(player, name)
    if not player then
        return nil
    end

    local value = player:GetAttribute(name)
    if value ~= nil then
        return value
    end

    local char = player.Character
    if char then
        value = char:GetAttribute(name)
        if value ~= nil then
            return value
        end
    end

    for _, root in ipairs({player, char}) do
        if root then
            local child = root:FindFirstChild(name)
            if child then
                if child:IsA("BoolValue") or child:IsA("StringValue")
                    or child:IsA("IntValue") or child:IsA("NumberValue") then
                    return child.Value
                end
            end
        end
    end

    return nil
end

local function readDuelMarker(player)
    if not player then
        return nil
    end

    local sawMarker = false
    local positive = false

    for _, name in ipairs(DUEL_VALUE_NAMES) do
        local value = getDuelBoolOrValue(player, name)
        if value ~= nil then
            sawMarker = true
            if type(value) == "boolean" then
                if value then
                    positive = true
                end
            elseif tostring(value) ~= "" and tostring(value) ~= "0" then
                positive = true
            end
        end
    end

    for _, root in ipairs({player, player.Character}) do
        if root then
            local attrs = root:GetAttributes()
            for name, value in pairs(attrs) do
                local n = string.lower(tostring(name))
                for _, word in ipairs(DUEL_ATTR_WORDS) do
                    if n:find(word, 1, true) then
                        sawMarker = true
                        if type(value) == "boolean" then
                            if value then
                                positive = true
                            end
                        elseif tostring(value) ~= "" and tostring(value) ~= "0" then
                            positive = true
                        end
                        break
                    end
                end
            end
        end
    end

    if positive then
        return true
    end

    if sawMarker then
        return false
    end

    return nil
end

local function getSessionId(player)
    if not player then
        return nil
    end

    for _, name in ipairs(SESSION_ATTRS) do
        local value = player:GetAttribute(name)
        if value ~= nil and tostring(value) ~= "" then
            return tostring(value)
        end

        local char = player.Character
        if char then
            value = char:GetAttribute(name)
            if value ~= nil and tostring(value) ~= "" then
                return tostring(value)
            end
        end
    end

    return nil
end

local function getExplicitOpponentUserId(player)
    for _, name in ipairs({"OpponentUserId", "EnemyUserId", "OpponentId", "EnemyId"}) do
        local value = getDuelBoolOrValue(player, name)
        local id = tonumber(value)
        if id and id > 0 then
            return math.floor(id)
        end
    end
    return nil
end

local function isHubLike(player)
    if not player then
        return true
    end

    local function inspect(inst)
        if not inst then
            return false
        end

        local names = {
            "Hub", "Lobby", "Spectate", "Spectator", "Waiting",
            "Intermission", "Queue", "MainLobby", "SafeZone",
        }

        local n = string.lower(inst.Name)
        for _, wanted in ipairs(names) do
            local w = string.lower(wanted)
            if n == w or n:find(w, 1, true) then
                return true
            end
        end

        return false
    end

    for _, attr in ipairs({"InLobby", "InHub", "Lobby", "Spectating", "Waiting"}) do
        if player:GetAttribute(attr) == true then
            return true
        end
    end

    -- Some games expose a positive/negative match marker instead of
    -- moving the character into a Lobby instance. Respect explicit false
    -- values so TP cannot stay active in a menu/waiting state.
    for _, attr in ipairs({"InDuel", "DuelActive", "InMatch", "MatchActive", "InRound", "RoundActive", "Playing"}) do
        local value = player:GetAttribute(attr)
        if value == false then
            return true
        end
    end

    local char = player.Character
    local node = char
    local depth = 0

    while node and node ~= Workspace and depth < 20 do
        if inspect(node) then
            return true
        end
        node = node.Parent
        depth += 1
    end

    -- Client-side lobby HUD/menu fallback. Only strong lobby names are
    -- used; ordinary combat HUDs are intentionally ignored.
    if player == LocalPlayer and PlayerGui then
        local ok, descendants = pcall(function()
            return PlayerGui:GetDescendants()
        end)
        if ok and descendants then
            for _, inst in ipairs(descendants) do
                if (inst:IsA("ScreenGui") or inst:IsA("Frame") or inst:IsA("TextLabel") or inst:IsA("TextButton"))
                    and inst.Visible ~= false then
                    local n = string.lower(inst.Name)
                    if n:find("lobby", 1, true)
                        or n:find("mainmenu", 1, true)
                        or n:find("intermission", 1, true)
                        or n:find("spectat", 1, true)
                        or n:find("queue", 1, true)
                        or n:find("waitingroom", 1, true) then
                        return true
                    end
                end
            end
        end
    end

    return false
end

local function refreshDuelContainersCache()
    local now = os.clock()
    if now - DuelContainersCacheAt < 2 then
        return
    end

    DuelContainersCacheAt = now
    table.clear(DuelContainersCache)

    local wantedExact = {}
    for _, name in ipairs(ACTIVE_FOLDERS) do
        wantedExact[string.lower(name)] = true
    end

    local ok, descendants = pcall(function()
        return Workspace:GetDescendants()
    end)
    if not ok or not descendants then
        return
    end

    for _, inst in ipairs(descendants) do
        local n = string.lower(inst.Name)
        if wantedExact[n]
            or n:find("duel", 1, true)
            or n:find("match", 1, true)
            or n:find("round", 1, true)
            or n:find("arena", 1, true) then
            DuelContainersCache[#DuelContainersCache + 1] = inst
        end
    end
end

local function getDuelContainer(player)
    local char = player and player.Character
    if not char then
        return nil
    end

    local node = char
    local depth = 0
    while node and node ~= Workspace and depth < 16 do
        local n = string.lower(node.Name)
        if n:find("duel", 1, true)
            or n:find("match", 1, true)
            or n:find("round", 1, true)
            or n:find("arena", 1, true) then
            return node
        end
        node = node.Parent
        depth += 1
    end

    refreshDuelContainersCache()
    for _, container in ipairs(DuelContainersCache) do
        local ok, inside = pcall(function()
            return char:IsDescendantOf(container)
        end)
        if ok and inside then
            return container
        end
    end

    return nil
end

local function computeDuelState(player)
    if not player or not isAlive(player) or isHubLike(player) then
        return false
    end

    if getExplicitOpponentUserId(player) then
        return true
    end

    local marker = readDuelMarker(player)
    if marker == true then
        return true
    elseif marker == false then
        return false
    end

    if getSessionId(player) then
        return true
    end

    return getDuelContainer(player) ~= nil
end

local function activeDuelState(player)
    local now = os.clock()
    local cached = DuelCache[player]
    if cached and now - cached.time < 0.25 then
        return cached.value
    end

    local value = computeDuelState(player)
    DuelCache[player] = {time = now, value = value}
    return value
end

local function sameDuelContext(playerA, playerB)
    if not playerA or not playerB or playerA == playerB then
        return false
    end

    if sameTeam(playerB) then
        return false
    end

    if not activeDuelState(playerA) or not activeDuelState(playerB) then
        return false
    end

    local explicit = getExplicitOpponentUserId(playerA)
    if explicit then
        return playerB.UserId == explicit
    end

    local bExplicit = getExplicitOpponentUserId(playerB)
    if bExplicit then
        return playerA.UserId == bExplicit
    end

    local aId = getSessionId(playerA)
    local bId = getSessionId(playerB)

    if aId or bId then
        return aId ~= nil and bId ~= nil and aId == bId
    end

    local a = getDuelContainer(playerA)
    local b = getDuelContainer(playerB)

    if a and b then
        return a == b
    end

    -- For games that only expose a boolean duel marker, accept a true 1v1 roster.
    local roster = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if activeDuelState(p) and not isHubLike(p) then
            roster[#roster + 1] = p
            if #roster > 2 then
                break
            end
        end
    end

    if #roster == 2 then
        return (roster[1] == playerA and roster[2] == playerB)
            or (roster[1] == playerB and roster[2] == playerA)
    end

    return false
end

local function getMatchId(player)
    if not player then return nil end
    local value = player:GetAttribute("Match")
    if value == false or value == "" then
        return nil
    end
    return value
end

local function isExplicitlyInMatch(player)
    return getMatchId(player) ~= nil
end

local function sameMatch(playerA, playerB)
    local a = getMatchId(playerA)
    local b = getMatchId(playerB)
    return a ~= nil and b ~= nil and a == b
end

local function getMatchEnemies()
    local list = {}
    local myMatch = getMatchId(LocalPlayer)
    if myMatch == nil then
        return list
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer
            and getMatchId(player) == myMatch
            and isAlive(player)
            and not sameTeam(player) then
            list[#list + 1] = player
        end
    end

    return list
end

local function shouldIgnore(player)
    if player == LocalPlayer or not isAlive(player) then
        return true
    end
    if State.ESP.IgnoreTeam and sameTeam(player) then
        return true
    end
    -- If the game exposes Match, use it as the authoritative combat roster.
    -- Outside a match we keep normal ESP available only when Match is absent.
    local myMatch = getMatchId(LocalPlayer)
    if myMatch ~= nil and not sameMatch(LocalPlayer, player) then
        return true
    end
    return false
end

local isValidTeleportTarget

local function shouldIgnoreAim(player)
    if player == LocalPlayer or not isAlive(player) then
        return true
    end

    if isHubLike(player) then
        return true
    end

    local myMatch = getMatchId(LocalPlayer)
    if myMatch ~= nil and not sameMatch(LocalPlayer, player) then
        return true
    end

    if State.Aim.IgnoreTeam and sameTeam(player) then
        return true
    end

    if State.Aim.TeleportShot and State.Aim.DuelOnly then
        if not isValidTeleportTarget(player) then
            return true
        end
    end

    return false
end

local function getCombatCandidates()
    local matchList = getMatchEnemies()
    if #matchList > 0 then
        return matchList
    end

    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer
            and isAlive(player)
            and not isHubLike(player)
            and not sameTeam(player) then
            list[#list + 1] = player
        end
    end
    return list
end

local CombatContextCache = {
    time = 0,
    value = false,
    opponent = nil,
}

local function hasCombatContext()
    local now = os.clock()

    if now - CombatContextCache.time < 0.12 then
        return CombatContextCache.value
    end

    CombatContextCache.time = now
    CombatContextCache.opponent = nil

    if isHubLike(LocalPlayer) then
        CombatContextCache.value = false
        return false
    end

    local character = LocalPlayer.Character
    local humanoid = character
        and character:FindFirstChildOfClass("Humanoid")

    if not humanoid or humanoid.Health <= 0 then
        CombatContextCache.value = false
        return false
    end

    -- Strongest path for this game: the Match attribute is the server-side
    -- roster marker used by the original game script.
    local myMatch = getMatchId(LocalPlayer)
    if myMatch ~= nil then
        local candidates = getMatchEnemies()
        if #candidates >= 1 then
            CombatContextCache.opponent = candidates[1]
            CombatContextCache.value = true
            return true
        end
        CombatContextCache.value = false
        return false
    end

    -- Strong path: explicit/current duel context.
    if activeDuelState(LocalPlayer) then
        for _, player in ipairs(getCombatCandidates()) do
            if sameDuelContext(LocalPlayer, player) then
                CombatContextCache.opponent = player
                CombatContextCache.value = true
                return true
            end
        end
    end

    -- Fallback for places which expose no usable duel marker.
    -- Only use this path when the local player has no explicit negative
    -- duel/match marker, otherwise lobby/waiting states are rejected.
    local marker = readDuelMarker(LocalPlayer)
    if marker == nil then
        local candidates = getCombatCandidates()

        if #candidates == 1 then
            local opponent = candidates[1]
            local opponentCharacter = opponent.Character
            local localTool = character and character:FindFirstChildOfClass("Tool")
            local opponentTool =
                opponentCharacter and opponentCharacter:FindFirstChildOfClass("Tool")

            if localTool and opponentTool then
                CombatContextCache.opponent = opponent
                CombatContextCache.value = true
                return true
            end
        end
    end

    CombatContextCache.value = false
    return false
end

isValidTeleportTarget = function(player)
    if not player
        or player == LocalPlayer
        or not isAlive(player)
        or sameTeam(player)
        or isHubLike(player)
        or not hasCombatContext() then
        return false
    end

    local myMatch = getMatchId(LocalPlayer)
    if myMatch ~= nil then
        return sameMatch(LocalPlayer, player)
    end

    if CombatContextCache.opponent == player then
        return true
    end

    if sameDuelContext(LocalPlayer, player) then
        CombatContextCache.opponent = player
        return true
    end

    return false
end


--============================================================
-- GUI ROOT
--============================================================

local Gui = track(Instance.new("ScreenGui"))
Gui.Name = "NexusMurderDuel"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder = 999
Gui.Parent = PlayerGui

local function addCorner(parent, radius)
    local x = Instance.new("UICorner")
    x.CornerRadius = UDim.new(0, radius)
    x.Parent = parent
    return x
end

local function addStroke(parent, color, thickness, transparency)
    local x = Instance.new("UIStroke")
    x.Color = color
    x.Thickness = thickness or 1
    x.Transparency = transparency or 0
    x.Parent = parent
    return x
end

--============================================================
-- FOV CIRCLE
--============================================================

local FOV = track(Instance.new("Frame"))
FOV.Name = "FOV"
FOV.AnchorPoint = Vector2.new(0.5, 0.5)
FOV.BackgroundTransparency = 1
FOV.BorderSizePixel = 0
FOV.Position = UDim2.fromScale(0.5, 0.5)
FOV.Size = UDim2.fromOffset(State.Aim.FOV * 2, State.Aim.FOV * 2)
FOV.Visible = false
FOV.ZIndex = 5
FOV.Parent = Gui

addCorner(FOV, 999)

local FOVStroke = addStroke(FOV, State.Aim.FOVColor, 1.6, 0.08)

local FOVDot = Instance.new("Frame")
FOVDot.AnchorPoint = Vector2.new(0.5, 0.5)
FOVDot.Position = UDim2.fromScale(0.5, 0.5)
FOVDot.Size = UDim2.fromOffset(4, 4)
FOVDot.BackgroundColor3 = State.Aim.FOVColor
FOVDot.BorderSizePixel = 0
FOVDot.ZIndex = 6
FOVDot.Parent = FOV
addCorner(FOVDot, 999)

--============================================================
-- MAIN MENU
--============================================================

local OpenButton = track(Instance.new("TextButton"))
OpenButton.Name = "OpenMenu"
OpenButton.AnchorPoint = Vector2.new(1, 0)
OpenButton.Position = UDim2.fromOffset(0, 80)
OpenButton.Size = UDim2.fromOffset(44, 44)
OpenButton.BackgroundColor3 = C.PANEL2
OpenButton.BorderSizePixel = 0
OpenButton.AutoButtonColor = false
OpenButton.Text = "N"
OpenButton.TextSize = 14
OpenButton.Font = BOLD
OpenButton.TextColor3 = C.TEXT
OpenButton.ZIndex = 500
OpenButton.Visible = false
OpenButton.Parent = Gui
addCorner(OpenButton, 12)
addStroke(OpenButton, C.ACCENT, 1.2, 0.15)

local Main = track(Instance.new("Frame"))
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.52)
Main.Size = UDim2.fromOffset(580, 400)
Main.BackgroundColor3 = C.BG
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = Gui
addCorner(Main, 18)
addStroke(Main, C.OUTLINE, 1, 0.18)

local Scale = track(Instance.new("UIScale"))
Scale.Parent = Main

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(11, 8, 22)),
    ColorSequenceKeypoint.new(0.52, Color3.fromRGB(18, 22, 47)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 9, 29)),
})
MainGradient.Rotation = 20
MainGradient.Parent = Main

-- The old top glow bars touched the rounded corners and could render
-- outside the visual bounds on some mobile clients. Keep the border only.
local TopAccent = Instance.new("Frame")
TopAccent.Position = UDim2.fromOffset(8, 2)
TopAccent.Size = UDim2.new(1, -16, 0, 2)
TopAccent.BackgroundColor3 = C.ACCENT
TopAccent.BorderSizePixel = 0
TopAccent.Parent = Main
addCorner(TopAccent, 99)

--============================================================
-- HEADER
--============================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 58)
Header.BackgroundTransparency = 1
Header.Active = true
Header.Parent = Main

local HeaderGlowStrip = Instance.new("Frame")
HeaderGlowStrip.BackgroundTransparency = 0.15
HeaderGlowStrip.BorderSizePixel = 0
HeaderGlowStrip.Position = UDim2.fromOffset(18, 49)
HeaderGlowStrip.Size = UDim2.new(1, -36, 0, 2)
HeaderGlowStrip.Parent = Header
addCorner(HeaderGlowStrip, 99)

local HeaderGlowGradient = Instance.new("UIGradient")
HeaderGlowGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.CYAN),
    ColorSequenceKeypoint.new(0.5, C.VIOLET),
    ColorSequenceKeypoint.new(1, C.MAGENTA),
})
HeaderGlowGradient.Parent = HeaderGlowStrip

local LightningL = Instance.new("TextLabel")
LightningL.BackgroundTransparency = 1
LightningL.Position = UDim2.fromOffset(3, 7)
LightningL.Size = UDim2.fromOffset(20, 20)
LightningL.Font = BOLD
LightningL.Text = "ϟ"
LightningL.TextSize = 17
LightningL.TextColor3 = C.CYAN
LightningL.Parent = Header

local LightningR = Instance.new("TextLabel")
LightningR.BackgroundTransparency = 1
LightningR.AnchorPoint = Vector2.new(1, 0)
LightningR.Position = UDim2.new(1, -34, 0, 7)
LightningR.Size = UDim2.fromOffset(20, 20)
LightningR.Font = BOLD
LightningR.Text = "ϟ"
LightningR.TextSize = 17
LightningR.TextColor3 = C.MAGENTA
LightningR.Parent = Header

local DragOverlay = Instance.new("Frame")
DragOverlay.Name = "DragOverlay"
DragOverlay.Position = UDim2.fromOffset(0, 0)
DragOverlay.Size = UDim2.new(1, -48, 1, 0)
DragOverlay.BackgroundTransparency = 1
DragOverlay.BorderSizePixel = 0
DragOverlay.Active = true
DragOverlay.Selectable = false
DragOverlay.ZIndex = 28
DragOverlay.Parent = Header

local DragHandle = Instance.new("Frame")
DragHandle.Name = "DragHandle"
DragHandle.AnchorPoint = Vector2.new(0.5, 0)
DragHandle.Position = UDim2.new(0.5, 0, 0, 2)
DragHandle.Size = UDim2.fromOffset(54, 3)
DragHandle.BackgroundColor3 = C.ACCENT2
DragHandle.BorderSizePixel = 0
DragHandle.ZIndex = 30
DragHandle.Parent = Header
addCorner(DragHandle, 99)

-- Neon lightning decoration: lightweight Frames, clipped by Main.
local Lightning = Instance.new("Frame")
Lightning.Name = "LightningDecor"
Lightning.BackgroundTransparency = 1
Lightning.Position = UDim2.new(0.72, 0, 0, 7)
Lightning.Size = UDim2.fromOffset(58, 42)
Lightning.ZIndex = 3
Lightning.Parent = Header

local function addBolt(parent, points, color, thickness)
    local last = nil
    for _, pnt in ipairs(points) do
        local p2 = Vector2.new(pnt[1], pnt[2])
        if last then
            local dx = p2.X - last.X
            local dy = p2.Y - last.Y
            local len = math.sqrt(dx * dx + dy * dy)
            local seg = Instance.new("Frame")
            seg.BackgroundColor3 = color
            seg.BorderSizePixel = 0
            seg.AnchorPoint = Vector2.new(0, 0.5)
            seg.Position = UDim2.fromOffset(last.X, last.Y)
            seg.Size = UDim2.fromOffset(len, thickness or 1.6)
            seg.Rotation = math.deg(math.atan2(dy, dx))
            seg.ZIndex = 4
            seg.Parent = parent
            addCorner(seg, 8)
        end
        last = p2
    end
end

addBolt(Lightning, {{3, 8}, {15, 8}, {10, 18}, {23, 18}, {14, 31}, {30, 31}}, C.CYAN, 1.8)
addBolt(Lightning, {{30, 5}, {41, 5}, {36, 14}, {50, 14}, {42, 27}, {55, 27}}, C.VIOLET, 1.5)

local LightningDot = Instance.new("Frame")
LightningDot.Size = UDim2.fromOffset(4, 4)
LightningDot.Position = UDim2.fromOffset(26, 35)
LightningDot.BackgroundColor3 = C.MAGENTA
LightningDot.BorderSizePixel = 0
LightningDot.ZIndex = 4
LightningDot.Parent = Lightning
addCorner(LightningDot, 99)

local Brand = Instance.new("TextLabel")
Brand.BackgroundTransparency = 1
Brand.Position = UDim2.fromOffset(18, 8)
Brand.Size = UDim2.new(0.66, 0, 0, 23)
Brand.Font = BOLD
Brand.Text = "✦  NEXUS MURDER DUEL"
Brand.TextSize = 14
Brand.TextColor3 = C.CYAN
Brand.TextXAlignment = Enum.TextXAlignment.Left
Brand.TextTruncate = Enum.TextTruncate.AtEnd
Brand.Parent = Header

local Version = Instance.new("TextLabel")
Version.BackgroundTransparency = 1
Version.Position = UDim2.fromOffset(19, 32)
Version.Size = UDim2.new(0.66, 0, 0, 16)
Version.Font = FONT
Version.Text = "anime interface  •  compact"
Version.TextSize = 9
Version.TextColor3 = C.MUTED
Version.TextXAlignment = Enum.TextXAlignment.Left
Version.Parent = Header

local DecoDot1 = Instance.new("Frame")
DecoDot1.Size = UDim2.fromOffset(6, 6)
DecoDot1.Position = UDim2.new(0.68, 0, 0, 18)
DecoDot1.BackgroundColor3 = C.PINK
DecoDot1.BorderSizePixel = 0
DecoDot1.Parent = Header
addCorner(DecoDot1, 99)

local DecoDot2 = Instance.new("Frame")
DecoDot2.Size = UDim2.fromOffset(4, 4)
DecoDot2.Position = UDim2.new(0.70, 0, 0, 31)
DecoDot2.BackgroundColor3 = C.CYAN
DecoDot2.BorderSizePixel = 0
DecoDot2.Parent = Header
addCorner(DecoDot2, 99)

local OnlinePill = Instance.new("Frame")
OnlinePill.AnchorPoint = Vector2.new(1, 0)
OnlinePill.Position = UDim2.new(1, -48, 0, 11)
OnlinePill.Size = UDim2.fromOffset(82, 24)
OnlinePill.BackgroundColor3 = Color3.fromRGB(23, 50, 45)
OnlinePill.BackgroundTransparency = 0.15
OnlinePill.BorderSizePixel = 0
OnlinePill.ZIndex = 27
OnlinePill.Parent = Header
addCorner(OnlinePill, 12)
addStroke(OnlinePill, C.GOOD, 1, 0.65)

local Online = Instance.new("TextLabel")
Online.BackgroundTransparency = 1
Online.AnchorPoint = Vector2.new(1, 0)
Online.Position = UDim2.new(1, -53, 0, 14)
Online.Size = UDim2.fromOffset(72, 18)
Online.ZIndex = 28
Online.Font = BOLD
Online.Text = "● ONLINE"
Online.TextSize = 9
Online.TextColor3 = C.GOOD
Online.TextXAlignment = Enum.TextXAlignment.Right
Online.Parent = Header

local Min = Instance.new("TextButton")
Min.AutoButtonColor = false
Min.AnchorPoint = Vector2.new(1, 0)
Min.Position = UDim2.new(1, -16, 0, 10)
Min.Size = UDim2.fromOffset(28, 28)
Min.BackgroundColor3 = C.PANEL2
Min.BorderSizePixel = 0
Min.Text = "–"
Min.TextSize = 15
Min.Font = BOLD
Min.TextColor3 = C.TEXT
Min.Parent = Header
addCorner(Min, 8)
addStroke(Min, C.CYAN, 1, 0.55)

--============================================================
-- BODY
--============================================================

local Body = Instance.new("Frame")
Body.Position = UDim2.fromOffset(12, 64)
Body.Size = UDim2.new(1, -24, 1, -74)
Body.BackgroundTransparency = 1
Body.Parent = Main

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 138, 1, 0)
Sidebar.BackgroundColor3 = C.PANEL
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Body
addCorner(Sidebar, 13)
addStroke(Sidebar, C.OUTLINE, 1, 0.7)

local SidebarGradient = Instance.new("UIGradient")
SidebarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(27, 18, 48)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 27, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(34, 16, 42)),
})
SidebarGradient.Rotation = 110
SidebarGradient.Parent = Sidebar

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(147, 0)
Content.Size = UDim2.new(1, -147, 1, 0)
Content.BackgroundColor3 = C.PANEL
Content.BorderSizePixel = 0
Content.ClipsDescendants = true
Content.Parent = Body
addCorner(Content, 13)
addStroke(Content, C.OUTLINE, 1, 0.7)

local ContentGradient = Instance.new("UIGradient")
ContentGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 15, 31)),
    ColorSequenceKeypoint.new(0.55, Color3.fromRGB(30, 20, 47)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 24, 42)),
})
ContentGradient.Rotation = 25
ContentGradient.Parent = Content

--============================================================
-- TABS
--============================================================

local Pages = {}
local TabRefs = {}

local TabData = {
    {Name = "Main", Icon = "⌂"},
    {Name = "ESP", Icon = "◉"},
    {Name = "Aim", Icon = "◎"},
    {Name = "Kill All", Icon = "☠"},
    {Name = "Ability", Icon = "ϟ"},
    {Name = "Teleport", Icon = "⌖"},
    {Name = "FOV", Icon = "⊙"},
    {Name = "Status", Icon = "◈"},
}

local function makeTab(i, data)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.BackgroundColor3 = C.PANEL2
    b.BackgroundTransparency = 0.9
    b.BorderSizePixel = 0
    b.Position = UDim2.fromOffset(7, 6 + ((i - 1) * 36))
    b.Size = UDim2.new(1, -14, 0, 34)
    b.Text = ""
    b.Parent = Sidebar
    addCorner(b, 10)

    local accent = Instance.new("Frame")
    accent.Position = UDim2.fromOffset(0, 6)
    accent.Size = UDim2.fromOffset(3, 22)
    accent.BackgroundColor3 = C.ACCENT
    accent.BorderSizePixel = 0
    accent.Visible = false
    accent.Parent = b
    addCorner(accent, 4)

    local icon = Instance.new("TextLabel")
    icon.BackgroundTransparency = 1
    icon.Position = UDim2.fromOffset(11, 0)
    icon.Size = UDim2.fromOffset(24, 34)
    icon.Font = BOLD
    icon.Text = data.Icon
    icon.TextSize = 14
    icon.TextColor3 = C.MUTED
    icon.Parent = b

    local text = Instance.new("TextLabel")
    text.BackgroundTransparency = 1
    text.Position = UDim2.fromOffset(39, 0)
    text.Size = UDim2.new(1, -46, 1, 0)
    text.Font = BOLD
    text.Text = data.Name
    text.TextSize = 10
    text.TextColor3 = C.MUTED
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextTruncate = Enum.TextTruncate.AtEnd
    text.Parent = b

    TabRefs[data.Name] = {
        Button = b,
        Icon = icon,
        Text = text,
        Accent = accent,
    }
end

for i, data in ipairs(TabData) do
    makeTab(i, data)
end

local function makePage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "Page"
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Visible = false
    page.CanvasSize = UDim2.fromOffset(0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.ScrollBarImageColor3 = C.ACCENT2
    page.ScrollBarImageTransparency = 0.15
    page.BottomImage = ""
    page.ScrollBarThickness = 6
    page.ElasticBehavior = Enum.ElasticBehavior.Never
    page.Active = true
    page.Parent = Content

    local bottomPad = Instance.new("Frame")
    bottomPad.Name = "BottomPadding"
    bottomPad.BackgroundTransparency = 1
    bottomPad.BorderSizePixel = 0
    bottomPad.Position = UDim2.fromOffset(0, 600)
    bottomPad.Size = UDim2.fromOffset(1, 40)
    bottomPad.Parent = page

    Pages[name] = page
    return page
end

local ESPPage = makePage("ESP")
local AimPage = makePage("Aim")
local SettingsPage = makePage("Settings")
local StatusPage = makePage("Status")
local ExtraPages = {
    Main = SettingsPage,
    ["Kill All"] = makePage("Kill All"),
    Ability = makePage("Ability"),
    Teleport = makePage("Teleport"),
    FOV = makePage("FOV"),
}
Pages.Main = SettingsPage

local function switchTab(name)
    CurrentTab = name

    for tabName, ref in pairs(TabRefs) do
        local active = tabName == name
        ref.Button.BackgroundColor3 = active and C.PANEL3 or C.PANEL2
        ref.Button.BackgroundTransparency = active and 0.03 or 0.9
        ref.Icon.TextColor3 = active and C.CYAN or C.MUTED
        ref.Text.TextColor3 = active and C.TEXT or C.MUTED
        ref.Accent.Visible = active
        ref.Accent.BackgroundColor3 = active and C.CYAN or C.ACCENT

        local gradient = ref.Button:FindFirstChild("TabGradient")
        if active and not gradient then
            gradient = Instance.new("UIGradient")
            gradient.Name = "TabGradient"
            gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(91, 42, 139)),
                ColorSequenceKeypoint.new(0.52, Color3.fromRGB(38, 78, 131)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(119, 38, 101)),
            })
            gradient.Rotation = 12
            gradient.Parent = ref.Button
        elseif not active and gradient then
            gradient:Destroy()
        end
    end

    for pageName, page in pairs(Pages) do
        local active = pageName == name
        page.Visible = active

        if active then
            page.CanvasPosition = Vector2.new(0, math.max(0, page.CanvasPosition.Y))
        end
    end
end

for name, ref in pairs(TabRefs) do
    connect(ref.Button.Activated, function()
        switchTab(name)
    end)
end

--============================================================
-- PAGE HELPERS
--============================================================

local function makeTitle(parent, titleText, subText)
    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(14, 11)
    title.Size = UDim2.new(1, -28, 0, 20)
    title.Font = BOLD
    title.Text = titleText
    title.TextSize = 13
    title.TextColor3 = C.TEXT
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.Parent = parent

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.fromOffset(14, 31)
    sub.Size = UDim2.new(1, -28, 0, 15)
    sub.Font = FONT
    sub.Text = subText
    sub.TextSize = 9
    sub.TextColor3 = C.MUTED
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.TextTruncate = Enum.TextTruncate.AtEnd
    sub.Parent = parent
end

local function makeSection(parent, top, height, labelText)
    local s = Instance.new("Frame")
    s.Position = UDim2.fromOffset(12, top)
    s.Size = UDim2.new(1, -24, 0, height)
    s.BackgroundColor3 = C.PANEL2
    s.BorderSizePixel = 0
    s.Parent = parent
    addCorner(s, 12)
    addStroke(s, C.OUTLINE, 1, 0.72)

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(39, 27, 62)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(27, 25, 52)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(42, 20, 48)),
    })
    gradient.Rotation = 18
    gradient.Parent = s

    local stripe = Instance.new("Frame")
    stripe.Position = UDim2.fromOffset(10, 11)
    stripe.Size = UDim2.fromOffset(3, 12)
    stripe.BackgroundColor3 = C.ACCENT2
    stripe.BorderSizePixel = 0
    stripe.Parent = s
    addCorner(stripe, 3)

    local h = Instance.new("TextLabel")
    h.BackgroundTransparency = 1
    h.Position = UDim2.fromOffset(20, 8)
    h.Size = UDim2.new(1, -30, 0, 19)
    h.Font = BOLD
    h.Text = labelText
    h.TextSize = 9
    h.TextColor3 = C.ACCENT2
    h.TextXAlignment = Enum.TextXAlignment.Left
    h.TextTruncate = Enum.TextTruncate.AtEnd
    h.Parent = s

    return s
end

local function makeToggle(parent, top, labelText, initial, callback)
    local button = Instance.new("TextButton")
    button.AutoButtonColor = false
    button.BackgroundTransparency = 1
    button.Position = UDim2.fromOffset(12, top)
    button.Size = UDim2.new(1, -24, 0, 31)
    button.Text = ""
    button.Parent = parent

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(0, 0)
    label.Size = UDim2.new(1, -55, 1, 0)
    label.Font = FONT
    label.Text = labelText
    label.TextSize = 10
    label.TextColor3 = initial and C.TEXT or C.MUTED
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = button

    local trackFrame = Instance.new("Frame")
    trackFrame.AnchorPoint = Vector2.new(1, 0.5)
    trackFrame.Position = UDim2.new(1, 0, 0.5, 0)
    trackFrame.Size = UDim2.fromOffset(38, 19)
    trackFrame.BackgroundColor3 = initial and C.ACCENT or C.PANEL3
    trackFrame.BorderSizePixel = 0
    trackFrame.Parent = button
    addCorner(trackFrame, 99)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(15, 15)
    knob.Position = initial and UDim2.new(1, -17, 0, 2) or UDim2.fromOffset(2, 2)
    knob.BackgroundColor3 = C.TEXT
    knob.BorderSizePixel = 0
    knob.Parent = trackFrame
    addCorner(knob, 99)

    local value = initial == true

    local function render()
        trackFrame.BackgroundColor3 = value and C.CYAN or C.PANEL3
        knob.Position = value and UDim2.new(1, -17, 0, 2) or UDim2.fromOffset(2, 2)
        label.TextColor3 = value and C.TEXT or C.MUTED
    end

    connect(button.Activated, function()
        value = not value
        render()
        callback(value)
    end)

    return {
        Set = function(v)
            value = v == true
            render()
        end,

        Get = function()
            return value
        end,
    }
end

local function makeSlider(parent, top, labelText, min, max, initial, callback)
    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    holder.Position = UDim2.fromOffset(12, top)
    holder.Size = UDim2.new(1, -24, 0, 47)
    holder.Parent = parent

    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(0.65, 0, 0, 17)
    l.Font = FONT
    l.Text = labelText
    l.TextSize = 10
    l.TextColor3 = C.TEXT
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = holder

    local valueText = Instance.new("TextLabel")
    valueText.BackgroundTransparency = 1
    valueText.AnchorPoint = Vector2.new(1, 0)
    valueText.Position = UDim2.new(1, 0, 0, 0)
    valueText.Size = UDim2.fromOffset(60, 17)
    valueText.Font = BOLD
    valueText.TextSize = 9
    valueText.TextColor3 = C.ACCENT2
    valueText.TextXAlignment = Enum.TextXAlignment.Right
    valueText.Parent = holder

    local bar = Instance.new("Frame")
    bar.Position = UDim2.fromOffset(0, 28)
    bar.Size = UDim2.new(1, 0, 0, 5)
    bar.BackgroundColor3 = C.PANEL3
    bar.BorderSizePixel = 0
    bar.Parent = holder
    addCorner(bar, 99)

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = C.ACCENT
    fill.BorderSizePixel = 0
    fill.Size = UDim2.fromScale(0, 1)
    fill.Parent = bar
    addCorner(fill, 99)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Size = UDim2.fromOffset(11, 11)
    knob.BackgroundColor3 = C.TEXT
    knob.BorderSizePixel = 0
    knob.Parent = bar
    addCorner(knob, 99)

    local value = math.clamp(math.floor(initial + 0.5), min, max)
    local drag = false

    local function redraw()
        local alpha = (value - min) / (max - min)
        fill.Size = UDim2.fromScale(alpha, 1)
        knob.Position = UDim2.fromScale(alpha, 0.5)
        valueText.Text = tostring(value)
    end

    local function updateFromInput(input)
        local left = bar.AbsolutePosition.X
        local width = math.max(bar.AbsoluteSize.X, 1)
        local alpha = math.clamp((input.Position.X - left) / width, 0, 1)
        value = math.floor(min + ((max - min) * alpha) + 0.5)
        redraw()
        callback(value)
    end

    connect(holder.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            updateFromInput(input)
        end
    end)

    connect(UserInputService.InputChanged, function(input)
        if drag and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            updateFromInput(input)
        end
    end)

    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)

    redraw()

    return {
        Set = function(v)
            value = math.clamp(math.floor(v + 0.5), min, max)
            redraw()
        end,
    }
end

local function makeValue(parent, top, labelText, initialText)
    local row = Instance.new("Frame")
    row.BackgroundTransparency = 1
    row.Position = UDim2.fromOffset(12, top)
    row.Size = UDim2.new(1, -24, 0, 25)
    row.Parent = parent

    local left = Instance.new("TextLabel")
    left.BackgroundTransparency = 1
    left.Size = UDim2.new(0.52, 0, 1, 0)
    left.Font = FONT
    left.Text = labelText
    left.TextSize = 9
    left.TextColor3 = C.MUTED
    left.TextXAlignment = Enum.TextXAlignment.Left
    left.TextTruncate = Enum.TextTruncate.AtEnd
    left.Parent = row

    local right = Instance.new("TextLabel")
    right.BackgroundTransparency = 1
    right.AnchorPoint = Vector2.new(1, 0)
    right.Position = UDim2.new(1, 0, 0, 0)
    right.Size = UDim2.new(0.48, 0, 1, 0)
    right.Font = BOLD
    right.Text = tostring(initialText)
    right.TextSize = 8
    right.TextColor3 = C.TEXT
    right.TextXAlignment = Enum.TextXAlignment.Right
    right.TextTruncate = Enum.TextTruncate.AtEnd
    right.Parent = row

    return right
end

--============================================================
-- ESP PAGE
--============================================================

makeTitle(ESPPage, "ESP", "Wall-ready visuals • skeleton • labels • hitbox")

local espSection = makeSection(ESPPage, 54, 326, "VISUAL MODULES")
local espControls = {}

local y = 32

espControls.Enabled = makeToggle(espSection, y, "Enable ESP", State.ESP.Enabled, function(v)
    State.ESP.Enabled = v
end)
y += 32

espControls.Health = makeToggle(espSection, y, "Health", State.ESP.Health, function(v)
    State.ESP.Health = v
end)
y += 32

espControls.Name = makeToggle(espSection, y, "Name", State.ESP.Name, function(v)
    State.ESP.Name = v
end)
y += 32

espControls.Skeleton = makeToggle(espSection, y, "Skeleton", State.ESP.Skeleton, function(v)
    State.ESP.Skeleton = v
end)
y += 32

espControls.Weapon = makeToggle(espSection, y, "Weapon", State.ESP.Weapon, function(v)
    State.ESP.Weapon = v
end)
y += 32

espControls.Hitbox = makeToggle(espSection, y, "Hitbox", State.ESP.Hitbox, function(v)
    State.ESP.Hitbox = v
end)
y += 32

espControls.IgnoreTeam = makeToggle(espSection, y, "Ignore Team", State.ESP.IgnoreTeam, function(v)
    State.ESP.IgnoreTeam = v
end)

local espDistanceSection = makeSection(ESPPage, 394, 88, "ESP RANGE  •  SLIDER")

local espDistanceSlider = makeSlider(espDistanceSection, 28, "Max Distance  (25–250)", 25, 250, State.ESP.MaxDistance, function(v)
    State.ESP.MaxDistance = math.clamp(v, 25, 250)
end)

--============================================================
-- AIM CHARACTER SYNC
--============================================================

local AimAutoRotateWas = nil

local function restoreCharacterAutoRotate()
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid and AimAutoRotateWas ~= nil then
        humanoid.AutoRotate = AimAutoRotateWas
    end

    AimAutoRotateWas = nil
end

local function syncCharacterToAim(targetPosition)
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not root or not targetPosition then
        return
    end

    if AimAutoRotateWas == nil then
        AimAutoRotateWas = humanoid.AutoRotate
    end

    humanoid.AutoRotate = false

    local flatTarget = Vector3.new(
        targetPosition.X,
        root.Position.Y,
        targetPosition.Z
    )

    local flatDirection = flatTarget - root.Position

    if flatDirection.Magnitude > 0.01 then
        root.CFrame = CFrame.lookAt(root.Position, flatTarget)
    end
end

--============================================================
-- AIM PAGE
--============================================================

makeTitle(AimPage, "AIM", "Native tool fire • stable follow • combat-only teleport")

local aimSection = makeSection(AimPage, 54, 360, "AIM CONTROLS")
local aimControls = {}

y = 32

aimControls.Enabled = makeToggle(aimSection, y, "Enable Aim", State.Aim.Enabled, function(v)
    State.Aim.Enabled = v
    FOV.Visible = v

    if not v then
        State.Aim.Target = nil
        State.Aim.SmoothedTargetPosition = nil
        restoreCharacterAutoRotate()
    end
end)
y += 32

aimControls.Aimbot = makeToggle(aimSection, y, "Aimbot", State.Aim.Aimbot, function(v)
    State.Aim.Aimbot = v
end)
y += 32

aimControls.IgnoreTeam = makeToggle(aimSection, y, "Ignore Team", State.Aim.IgnoreTeam, function(v)
    State.Aim.IgnoreTeam = v
    State.Aim.Target = nil
end)
y += 32

aimControls.CheckVisible = makeToggle(aimSection, y, "Check Visible", State.Aim.CheckVisible, function(v)
    State.Aim.CheckVisible = v
    State.Aim.Target = nil
    State.Aim.SmoothedTargetPosition = nil
end)
y += 32

aimControls.Sticky = makeToggle(aimSection, y, "Sticky Target", State.Aim.Sticky, function(v)
    State.Aim.Sticky = v

    if not v then
        State.Aim.Target = nil
    end
end)
y += 36

aimControls.Stabilizer = makeToggle(aimSection, y, "Aim Stabilizer", State.Aim.Stabilizer, function(v)
    State.Aim.Stabilizer = v
end)
y += 36

local fovSlider = makeSlider(aimSection, y, "FOV Size  (20–350)", 20, 350, State.Aim.FOV, function(v)
    State.Aim.FOV = v
    FOV.Size = UDim2.fromOffset(v * 2, v * 2)
end)
y += 49

local smoothSlider = makeSlider(aimSection, y, "Smoothness  (1–100)", 1, 100, State.Aim.Smoothness, function(v)
    State.Aim.Smoothness = v
end)

local AimModeText = Instance.new("TextLabel")
AimModeText.BackgroundTransparency = 1
AimModeText.Position = UDim2.fromOffset(14, 332)
AimModeText.Size = UDim2.new(1, -28, 0, 16)
AimModeText.Font = BOLD
AimModeText.Text = "MODE  360°  •  TP SHOT"
AimModeText.TextSize = 8
AimModeText.TextColor3 = C.ACCENT2
AimModeText.TextXAlignment = Enum.TextXAlignment.Left
AimModeText.Parent = aimSection

local colorSection = makeSection(AimPage, 420, 108, "FOV COLOR / TELEPORT SHOT")

local colorButton = Instance.new("TextButton")
colorButton.AutoButtonColor = false
colorButton.Position = UDim2.fromOffset(12, 29)
colorButton.Size = UDim2.fromOffset(115, 27)
colorButton.BackgroundColor3 = C.ACCENT
colorButton.BorderSizePixel = 0
colorButton.Text = "FOV COLOR"
colorButton.Font = BOLD
colorButton.TextSize = 8
colorButton.TextColor3 = C.TEXT
colorButton.Parent = colorSection
addCorner(colorButton, 8)

local colorDot = Instance.new("Frame")
colorDot.AnchorPoint = Vector2.new(1, 0.5)
colorDot.Position = UDim2.new(1, -8, 0.5, 0)
colorDot.Size = UDim2.fromOffset(8, 8)
colorDot.BackgroundColor3 = State.Aim.FOVColor
colorDot.BorderSizePixel = 0
colorDot.Parent = colorButton
addCorner(colorDot, 99)

connect(colorButton.Activated, function()
    local palette = {
        C.ACCENT,
        C.ACCENT2,
        C.PINK,
        C.GOOD,
        C.WARN,
        C.TEXT,
    }

    local current = 1
    local best = math.huge

    for i, color in ipairs(palette) do
        local d = (color.R - State.Aim.FOVColor.R)^2
            + (color.G - State.Aim.FOVColor.G)^2
            + (color.B - State.Aim.FOVColor.B)^2

        if d < best then
            best = d
            current = i
        end
    end

    current = (current % #palette) + 1
    State.Aim.FOVColor = palette[current]
    FOVStroke.Color = State.Aim.FOVColor
    FOVDot.BackgroundColor3 = State.Aim.FOVColor
    colorDot.BackgroundColor3 = State.Aim.FOVColor
end)

aimControls.TeleportShot = makeToggle(colorSection, 61, "Teleport Follow + Shot", State.Aim.TeleportShot, function(v)
    State.Aim.TeleportShot = v
    State.Aim.Target = nil
    State.Aim.SmoothedTargetPosition = nil
    if not v then
        restoreCharacterAutoRotate()
    end
end)

local teleportHint = Instance.new("TextLabel")
teleportHint.BackgroundTransparency = 1
teleportHint.Position = UDim2.fromOffset(140, 29)
teleportHint.Size = UDim2.new(1, -152, 0, 30)
teleportHint.Font = FONT
teleportHint.Text = "FOLLOW + NATIVE SHOT  •  COMBAT ONLY  •  SAFE POSITION"
teleportHint.TextSize = 8
teleportHint.TextWrapped = true
teleportHint.TextColor3 = C.MUTED
teleportHint.TextXAlignment = Enum.TextXAlignment.Left
teleportHint.Parent = colorSection

--============================================================
-- SETTINGS PAGE
--============================================================

makeTitle(SettingsPage, "MAIN", "Game data • combat features • movement utilities")

local gameSection = makeSection(SettingsPage, 54, 126, "GAME STATUS")
local gameNameValue = makeValue(gameSection, 30, "Game", "Loading...")
local placeValue = makeValue(gameSection, 55, "Place ID", tostring(game.PlaceId))
local universeValue = makeValue(gameSection, 80, "Universe", tostring(game.GameId))
local enemyValue = makeValue(gameSection, 105, "Enemy", "No target")

local interfaceSection = makeSection(SettingsPage, 188, 82, "INTERFACE")

local ManualScale = 1

local uiScaleSlider = makeSlider(interfaceSection, 28, "Menu Size  (70–100%)", 70, 100, 100, function(v)
    ManualScale = math.clamp(v / 100, 0.70, 1)
    updateScale()
end)

local functionSection = makeSection(SettingsPage, 270, 170, "FUNCTION STATUS")
local fnESP = makeValue(functionSection, 27, "ESP", "DISABLED")
local fnAim = makeValue(functionSection, 52, "Aim", "DISABLED")
local fnAimbot = makeValue(functionSection, 77, "Aimbot", "DISABLED")
local fnTeleport = makeValue(functionSection, 102, "Teleport Shot", "DISABLED")
local fnStabilizer = makeValue(functionSection, 127, "Stabilizer", "ON")

--============================================================
-- STATUS PAGE
--============================================================

makeTitle(StatusPage, "STATUS", "Roblox client • player • device telemetry")

local playerSection = makeSection(StatusPage, 54, 192, "ROBLOX PLAYER")

local avatar = Instance.new("ImageLabel")
avatar.BackgroundColor3 = C.PANEL3
avatar.Position = UDim2.fromOffset(12, 34)
avatar.Size = UDim2.fromOffset(50, 50)
avatar.BorderSizePixel = 0
avatar.Parent = playerSection
addCorner(avatar, 10)

pcall(function()
    local image = Players:GetUserThumbnailAsync(
        LocalPlayer.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size100x100
    )
    avatar.Image = image
end)

local playerInfo = Instance.new("Frame")
playerInfo.BackgroundTransparency = 1
playerInfo.Position = UDim2.fromOffset(74, 30)
playerInfo.Size = UDim2.new(1, -86, 0, 150)
playerInfo.Parent = playerSection

local pName = makeValue(playerInfo, 0, "Username", "Hidden")
local pDisplay = makeValue(playerInfo, 25, "Display", "Hidden")
local pId = makeValue(playerInfo, 50, "Roblox ID", tostring(LocalPlayer.UserId))
local pAge = makeValue(playerInfo, 75, "Account Age", tostring(LocalPlayer.AccountAge) .. "d")
local pClient = makeValue(playerInfo, 100, "Client User", "LOCAL")
local ScriptStatus = makeValue(playerInfo, 125, "Script", "RUNNING")

local deviceSection = makeSection(StatusPage, 256, 167, "DEVICE")

local dDevice = makeValue(deviceSection, 31, "Device", getDevice())
local dPlatform = makeValue(deviceSection, 56, "Platform", getPlatform())
local dFPS = makeValue(deviceSection, 81, "FPS", "0")
local dPing = makeValue(deviceSection, 106, "Ping", "0 ms")
local dViewport = makeValue(deviceSection, 131, "Viewport", "0 x 0")
local dMatch = makeValue(deviceSection, 156, "Match", "LOBBY")

--============================================================
-- ESP OBJECTS
--============================================================

local ESPFolder = track(Instance.new("Folder"))
ESPFolder.Name = "NexusESP"
ESPFolder.Parent = Workspace

-- Character-attached ESP objects.
-- Skeleton is made from Beams whose attachments live directly on the
-- enemy body parts, so it follows animations/teleports without screen-space drift.
local ESPData = {}

local function makeBoneBeam()
    local beam = track(Instance.new("Beam"))
    beam.Name = "ESPSkeletonBone"
    beam.Color = ColorSequence.new(C.ACCENT)
    beam.Width0 = 0.075
    beam.Width1 = 0.075
    beam.FaceCamera = true
    beam.Brightness = 2
    beam.LightEmission = 1
    beam.Segments = 1
    beam.Transparency = NumberSequence.new(0)
    beam.Enabled = false
    beam.Parent = ESPFolder
    return beam
end

local function getBoneAttachment(part, name)
    if not part or not part:IsA("BasePart") then
        return nil
    end

    local attachment = part:FindFirstChild(name)
    if attachment and attachment:IsA("Attachment") then
        return attachment
    end

    attachment = Instance.new("Attachment")
    attachment.Name = name
    attachment.Position = Vector3.zero
    attachment.Parent = part
    return attachment
end

local function bindSkeleton(data, char)
    if not data or not char then
        return
    end

    if data.SkeletonCharacter == char and data.SkeletonBound then
        return
    end

    data.SkeletonCharacter = char
    data.SkeletonBound = false

    local head = findPart(char, "Head")
    local upper = findPart(char, "UpperTorso", "Torso")
    local lower = findPart(char, "LowerTorso", "Torso")
    local leftArm = findPart(char, "LeftUpperArm", "Left Arm")
    local rightArm = findPart(char, "RightUpperArm", "Right Arm")
    local leftLeg = findPart(char, "LeftUpperLeg", "Left Leg")
    local rightLeg = findPart(char, "RightUpperLeg", "Right Leg")

    local points = {
        {head, upper},
        {upper, leftArm},
        {upper, rightArm},
        {upper, lower},
        {lower, leftLeg},
        {lower, rightLeg},
    }

    local boundCount = 0

    for i, pair in ipairs(points) do
        local beam = data.Skeleton[i]
        local p1, p2 = pair[1], pair[2]

        if beam and p1 and p2 then
            local a0 = getBoneAttachment(p1, "NexusBoneA_" .. tostring(LocalPlayer.UserId))
            local a1 = getBoneAttachment(p2, "NexusBoneB_" .. tostring(LocalPlayer.UserId))
            beam.Attachment0 = a0
            beam.Attachment1 = a1
            pcall(function()
                beam.Parent = char
            end)
            beam.Enabled = a0 ~= nil and a1 ~= nil
            if a0 and a1 then
                boundCount += 1
            end
        elseif beam then
            beam.Enabled = false
            beam.Attachment0 = nil
            beam.Attachment1 = nil
        end
    end

    data.SkeletonBound = boundCount > 0
    if not data.SkeletonBound then
        data.SkeletonCharacter = nil
    end
end

local function createESP(player)
    if player == LocalPlayer or ESPData[player] then
        return
    end

    local skeleton = {}
    for _ = 1, 6 do
        skeleton[#skeleton + 1] = makeBoneBeam()
    end

    local billboard = track(Instance.new("BillboardGui"))
    billboard.Name = "ESP_Billboard_" .. player.UserId
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.Size = UDim2.fromOffset(165, 46)
    billboard.StudsOffset = Vector3.new(0, 3.0, 0)
    billboard.Enabled = false
    billboard.Parent = PlayerGui

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = BOLD
    label.TextSize = 10
    label.TextWrapped = true
    label.TextColor3 = C.TEXT
    label.TextStrokeTransparency = 0.25
    label.Parent = billboard

    local highlight = track(Instance.new("Highlight"))
    highlight.Name = "Hitbox_" .. player.UserId
    highlight.FillColor = C.ACCENT
    highlight.FillTransparency = 0.80
    highlight.OutlineColor = C.CYAN
    highlight.OutlineTransparency = 0.0
    highlight.Enabled = false
    highlight.Parent = Workspace
    pcall(function()
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end)

    ESPData[player] = {
        Skeleton = skeleton,
        SkeletonCharacter = nil,
        SkeletonBound = false,
        Billboard = billboard,
        Label = label,
        Highlight = highlight,
    }
end

local function removeESP(player)
    local data = ESPData[player]
    if not data then
        return
    end

    for _, obj in ipairs(data.Skeleton) do
        pcall(function()
            obj:Destroy()
        end)
    end

    pcall(function()
        data.Billboard:Destroy()
    end)

    pcall(function()
        data.Highlight:Destroy()
    end)

    ESPData[player] = nil
end

local function resetPlayerVisuals(player)
    local data = ESPData[player]
    if not data then
        return
    end

    data.SkeletonCharacter = nil
    data.SkeletonBound = false
    data.Billboard.Adornee = nil
    data.Billboard.Enabled = false
    data.Highlight.Adornee = nil
    data.Highlight.Enabled = false

    for _, beam in ipairs(data.Skeleton) do
        beam.Enabled = false
        beam.Attachment0 = nil
        beam.Attachment1 = nil
        pcall(function()
            beam.Parent = ESPFolder
        end)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
        connect(player.CharacterAdded, function()
            invalidateDuelCache(player)
            resetPlayerVisuals(player)
        end)
    end
end

connect(Players.PlayerAdded, function(player)
    invalidateDuelCache(player)
    createESP(player)
    connect(player.CharacterAdded, function()
        invalidateDuelCache(player)
        resetPlayerVisuals(player)
    end)
end)

connect(Players.PlayerRemoving, function(player)
    invalidateDuelCache(player)
    removeESP(player)
end)

--============================================================
-- AIM TARGETING
--============================================================

local function targetDistance(player)
    local root = getRoot(player)
    local localRoot = getRoot(LocalPlayer)

    if not root or not localRoot then
        return math.huge
    end

    return (root.Position - localRoot.Position).Magnitude
end

local isTargetVisible
local getVisibleAimPart

local function validStickyTarget(player)
    if not player or shouldIgnoreAim(player) then
        return false
    end

    return true
end

local function getAimParts(player)
    local char = player and player.Character

    if not char then
        return {}
    end

    local parts = {}

    for _, name in ipairs({
        "Head",
        "UpperTorso",
        "Torso",
        "HumanoidRootPart",
        "LowerTorso",
    }) do
        local part = char:FindFirstChild(name)

        if part and part:IsA("BasePart") then
            parts[#parts + 1] = part
        end
    end

    return parts
end

local function getAimPart(player)
    local parts = getAimParts(player)
    return parts[1]
end

isTargetVisible = function(player, part)
    if not State.Aim.CheckVisible then
        return true
    end

    local camera = Workspace.CurrentCamera
    local character = player and player.Character

    if not camera or not character then
        return false
    end

    local parts = {}

    if part and part:IsA("BasePart") then
        parts[#parts + 1] = part
    end

    for _, candidate in ipairs(getAimParts(player)) do
        local exists = false

        for _, existing in ipairs(parts) do
            if existing == candidate then
                exists = true
                break
            end
        end

        if not exists then
            parts[#parts + 1] = candidate
        end
    end

    local ignore = {}

    if LocalPlayer.Character then
        ignore[#ignore + 1] = LocalPlayer.Character
    end

    for _, candidate in ipairs(parts) do
        local ok, obscuring = pcall(function()
            return camera:GetPartsObscuringTarget(
                {candidate.Position},
                ignore
            )
        end)

        if ok and obscuring and #obscuring == 0 then
            return true
        end
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    params.FilterDescendantsInstances = ignore

    local origin = camera.CFrame.Position

    for _, candidate in ipairs(parts) do
        local direction = candidate.Position - origin

        if direction.Magnitude > 0.001 then
            local hit = Workspace:Raycast(
                origin,
                direction,
                params
            )

            if hit and hit.Instance and hit.Instance:IsDescendantOf(character) then
                return true
            end
        end
    end

    return false
end

getVisibleAimPart = function(player)
    local first = getAimPart(player)

    if not State.Aim.CheckVisible then
        return first
    end

    for _, part in ipairs(getAimParts(player)) do
        if isTargetVisible(player, part) then
            return part
        end
    end

    return nil
end

local function acquireTarget(forTeleportShot)
    local current = State.Aim.Target

    if State.Aim.Sticky and validStickyTarget(current) then
        local stickyPart =
            forTeleportShot
            and getAimPart(current)
            or getVisibleAimPart(current)

        if stickyPart
            and (
                forTeleportShot
                or (not State.Aim.CheckVisible)
                or isTargetVisible(current, stickyPart)
            ) then
            return current
        end
    end

    local camera = Workspace.CurrentCamera
    if not camera then
        return nil
    end

    local best = nil
    local bestScore = math.huge
    local center = getViewport() * 0.5

    for _, player in ipairs(Players:GetPlayers()) do
        if not shouldIgnoreAim(player) then
            local part =
                forTeleportShot
                and getAimPart(player)
                or getVisibleAimPart(player)

            if part then
                if forTeleportShot then
                    local score = targetDistance(player)
                    if score < bestScore then
                        bestScore = score
                        best = player
                    end
                else
                    local screen, onScreen =
                        camera:WorldToViewportPoint(part.Position)

                    if onScreen and screen.Z > 0 then
                        local dx = screen.X - center.X
                        local dy = screen.Y - center.Y
                        local screenDistance =
                            math.sqrt((dx * dx) + (dy * dy))

                        if screenDistance <= State.Aim.FOV
                            and screenDistance < bestScore then
                            bestScore = screenDistance
                            best = player
                        end
                    end
                end
            end
        end
    end

    return best
end

--============================================================
-- TELEPORT SHOT
--============================================================

local lastTeleportShotAt = 0
local lastTeleportMoveAt = 0
local lastToolRestoreAt = 0

local TELEPORT_SHOT_INTERVAL = 0.10
local TELEPORT_FOLLOW_INTERVAL = 0.055
local TELEPORT_DISTANCE = 3.15
local TELEPORT_SAFE_RADIUS = 6.5

local function getHeldTool(character)
    if not character then
        return nil
    end
    return character:FindFirstChildOfClass("Tool")
end

local function scoreWeaponTool(tool)
    if not tool or not tool:IsA("Tool") then
        return -math.huge
    end

    local name = string.lower(tool.Name or "")
    local score = 0

    for _, token in ipairs({
        "gun", "rifle", "pistol", "weapon", "shot",
        "fire", "blaster", "sniper", "revolver",
    }) do
        if name:find(token, 1, true) then
            score += 25
        end
    end

    if tool:FindFirstChild("Fire") or tool:FindFirstChild("Shoot") then
        score += 40
    end

    if tool:FindFirstChildOfClass("RemoteEvent") then
        score += 10
    end

    return score
end

local function getBestWeaponTool(character)
    if not character then
        return nil
    end

    local equipped = character:FindFirstChildOfClass("Tool")
    if equipped then
        return equipped
    end

    local best, bestScore = nil, -math.huge
    for _, obj in ipairs(character:GetChildren()) do
        if obj:IsA("Tool") then
            local score = scoreWeaponTool(obj)
            if score > bestScore then
                bestScore = score
                best = obj
            end
        end
    end

    return best
end

local function ensureHeldTool(character, humanoid, heldTool)
    if not character or not humanoid or not heldTool then
        return nil
    end

    if heldTool.Parent ~= character
        and os.clock() - lastToolRestoreAt >= 0.25 then

        lastToolRestoreAt = os.clock()

        pcall(function()
            humanoid:EquipTool(heldTool)
        end)
    end

    return (heldTool.Parent == character and heldTool)
        or getHeldTool(character)
end

local function activateToolNative(tool)
    if not tool or not tool:IsA("Tool") then
        return false
    end

    local oldEnabled
    local oldManual

    pcall(function()
        oldEnabled = tool.Enabled
        tool.Enabled = true
    end)

    pcall(function()
        oldManual = tool.ManualActivationOnly
        tool.ManualActivationOnly = false
    end)

    local called = false

    for _ = 1, 2 do
        local ok = pcall(function()
            tool:Activate()
        end)

        if ok then
            called = true
        end

        task.wait(0.018)
    end

    pcall(function()
        if oldEnabled ~= nil then
            tool.Enabled = oldEnabled
        end
    end)

    pcall(function()
        if oldManual ~= nil then
            tool.ManualActivationOnly = oldManual
        end
    end)

    return called
end

local function sendGameShot(targetPlayer, targetPart, heldTool)
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not character or not humanoid or humanoid.Health <= 0 or not root then
        return false
    end

    targetPart = targetPart
        or (targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head"))
        or (targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart"))
    if not targetPlayer or not targetPart then
        return false
    end

    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local shootRemote = remotes and remotes:FindFirstChild("ShootGun")
    if not shootRemote or not shootRemote:IsA("RemoteEvent") then
        return false
    end

    local origin = root.Position
    local targetPos = targetPart.Position

    local muzzle = heldTool and heldTool:FindFirstChild("Muzzle", true)
    if muzzle and muzzle:IsA("Attachment") then
        origin = muzzle.WorldPosition
    end

    local ok = pcall(function()
        shootRemote:FireServer(origin, targetPos, targetPart, targetPos)
    end)

    if ok then
        local fireSound = heldTool and heldTool:FindFirstChild("Fire")
        if fireSound and fireSound:IsA("Sound") then
            pcall(function() fireSound:Play() end)
        end
    end

    return ok
end

local function sendDirectShot(targetPlayer, targetPart, heldTool)
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not character or not humanoid or humanoid.Health <= 0 then
        return false
    end

    local tool = heldTool or getHeldTool(character)
    tool = tool or getBestWeaponTool(character)
    tool = ensureHeldTool(character, humanoid, tool)
    if not tool then
        return false
    end

    -- This game's actual firing contract is the ShootGun RemoteEvent.
    -- Native Tool:Activate remains the fallback for custom weapons.
    if sendGameShot(targetPlayer, targetPart, tool) then
        return true
    end

    return activateToolNative(tool)
end

local function getSafeFloor(position, character, targetCharacter, targetY)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {
        character,
        targetCharacter,
    }
    params.IgnoreWater = true

    local origin = Vector3.new(position.X, position.Y + 10, position.Z)
    local hit = Workspace:Raycast(
        origin,
        Vector3.new(0, -30, 0),
        params
    )

    if not hit then
        return nil
    end

    -- Never accept a floor that is wildly below/above the target; that was
    -- the main cause of rare teleports into the void or under the map.
    if targetY and math.abs(hit.Position.Y - targetY) > 8 then
        return nil
    end

    return hit.Position
end

local function isSpaceClear(position, character, targetCharacter)
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {
        character,
        targetCharacter,
    }

    local hits = Workspace:GetPartBoundsInBox(
        CFrame.new(position),
        Vector3.new(2.5, 4.6, 2.5),
        params
    )

    for _, part in ipairs(hits) do
        if part:IsA("BasePart") and part.CanCollide then
            return false
        end
    end

    return true
end

local function positionLooksSafe(position, targetRoot)
    if not position or not targetRoot then
        return false
    end

    local delta = position - targetRoot.Position
    if delta.Magnitude > TELEPORT_SAFE_RADIUS then
        return false
    end

    if math.abs(delta.Y) > 7 then
        return false
    end

    if position.Y < -500 or position.Y > 5000 then
        return false
    end

    return true
end

local function getSafeBehindPosition(targetRoot, targetCharacter, character, humanoid)
    if not targetRoot or not targetCharacter or not character or not humanoid then
        return nil
    end

    local look = targetRoot.CFrame.LookVector
    local right = targetRoot.CFrame.RightVector
    local targetY = targetRoot.Position.Y

    local candidates = {
        -look * TELEPORT_DISTANCE,
        -look * 2.45,
        (-look * 2.35) + (right * 1.65),
        (-look * 2.35) - (right * 1.65),
        -look * 3.65,
        right * 2.8,
        -right * 2.8,
    }

    for _, offset in ipairs(candidates) do
        local raw = targetRoot.Position + offset

        -- First try to keep the same combat-plane height. This is safer on
        -- maps with floating arenas where a generic ground ray can hit a
        -- completely unrelated surface far below.
        local sameHeight = Vector3.new(raw.X, targetY, raw.Z)
        if positionLooksSafe(sameHeight, targetRoot)
            and isSpaceClear(sameHeight, character, targetCharacter) then
            return sameHeight
        end

        local floor = getSafeFloor(raw, character, targetCharacter, targetY)
        if floor then
            local standHeight = math.max((humanoid.HipHeight or 2) + 0.9, 2.4)
            local candidate = Vector3.new(
                raw.X,
                floor.Y + standHeight,
                raw.Z
            )

            if positionLooksSafe(candidate, targetRoot)
                and isSpaceClear(candidate, character, targetCharacter) then
                return candidate
            end
        end
    end

    return nil
end

local function teleportAndShoot(targetPlayer, targetPart)
    local now = os.clock()

    if not State.Aim.TeleportShot then
        return false
    end

    if isHubLike(LocalPlayer) or not isExplicitlyInMatch(LocalPlayer) then
        State.Aim.Target = nil
        restoreCharacterAutoRotate()
        return false
    end

    if State.Aim.DuelOnly and not hasCombatContext() then
        State.Aim.Target = nil
        restoreCharacterAutoRotate()
        return false
    end

    if not isValidTeleportTarget(targetPlayer) then

        State.Aim.Target = nil
        return false
    end

    local character = LocalPlayer.Character
    local localRoot = getRoot(LocalPlayer)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local targetRoot = getRoot(targetPlayer)
    local targetCharacter = targetPlayer.Character

    if not character or not localRoot or not humanoid
        or not targetRoot or not targetCharacter then
        return false
    end

    targetPart = targetPart
        or getHead(targetPlayer)
        or targetRoot

    if not targetPart or not targetPart:IsA("BasePart") then
        return false
    end

    local heldTool =
        getHeldTool(character)
        or getBestWeaponTool(character)

    if now - lastTeleportMoveAt >= TELEPORT_FOLLOW_INTERVAL then
        local safePosition =
            getSafeBehindPosition(
                targetRoot,
                targetCharacter,
                character,
                humanoid
            )

        if not safePosition then
            return false
        end

        local facePosition = targetPart.Position
        local flatFace = Vector3.new(
            facePosition.X,
            safePosition.Y,
            facePosition.Z
        )

        local moved = false

        pcall(function()
            humanoid.AutoRotate = false
            character:PivotTo(
                CFrame.lookAt(safePosition, flatFace)
            )
            moved = true
        end)

        if not moved then
            return false
        end

        pcall(function()
            local current = localRoot.AssemblyLinearVelocity
            if current.Magnitude < 80 then
                localRoot.AssemblyLinearVelocity = Vector3.zero
            else
                localRoot.AssemblyLinearVelocity = Vector3.zero
            end
            localRoot.AssemblyAngularVelocity = Vector3.zero
        end)

        -- Never force a new weapon. Only recover the exact tool already held
        -- if Roblox moved it out of Character.
        task.defer(function()
            ensureHeldTool(character, humanoid, heldTool)
        end)

        local actualDistance =
            (localRoot.Position - targetRoot.Position).Magnitude

        if actualDistance > TELEPORT_SAFE_RADIUS
            or math.abs(localRoot.Position.Y - targetRoot.Position.Y) > 7.5 then
            return false
        end

        local camera = Workspace.CurrentCamera
        if camera then
            pcall(function()
                if camera.CameraSubject ~= humanoid then
                    camera.CameraSubject = humanoid
                end
            end)
        end

        lastTeleportMoveAt = now
    end

    if now - lastTeleportShotAt >= TELEPORT_SHOT_INTERVAL then
        local shotSent = sendDirectShot(targetPlayer, targetPart, heldTool)

        if shotSent then
            lastTeleportShotAt = now
            return true
        end
    end

    return false
end

--============================================================
-- MENU DRAG
--============================================================

local drag = false
local dragInput = nil
local dragStart = nil
local startPos = nil

Header.Active = true
DragHandle.Active = true

local function beginMenuDrag(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    drag = true
    dragInput = input
    dragStart = input.Position
    startPos = Main.Position
end

local function updateMenuDrag(input)
    if not drag or not dragStart then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - dragStart
    if delta.Magnitude < 1 then
        return
    end

    local viewport = getViewport()
    local absoluteSize = Main.AbsoluteSize

    local halfW = absoluteSize.X * 0.5
    local halfH = absoluteSize.Y * 0.5
    local startCenter = Main.AbsolutePosition + Vector2.new(halfW, halfH)
    local desired = startCenter + delta

    local minX = halfW + 4
    local maxX = math.max(minX, viewport.X - halfW - 4)
    local minY = halfH + 4
    local maxY = math.max(minY, viewport.Y - halfH - 4)

    desired = Vector2.new(
        math.clamp(desired.X, minX, maxX),
        math.clamp(desired.Y, minY, maxY)
    )

    Main.Position = UDim2.fromOffset(desired.X, desired.Y)
end

connect(DragOverlay.InputBegan, beginMenuDrag)
connect(UserInputService.InputChanged, updateMenuDrag)

connect(UserInputService.InputEnded, function(input)
    if input == dragInput
        or input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        drag = false
        dragInput = nil
        dragStart = nil
        startPos = nil
    end
end)

--============================================================
-- MINIMIZE
--============================================================

connect(Min.Activated, function()
    MenuOpen = false
    Main.Visible = false
    Min.Visible = false
    OpenButton.Visible = true
    FOV.Visible = State.Aim.Enabled

    local viewport = getViewport()
    local insetTop = 0

    pcall(function()
        insetTop = GuiService:GetGuiInset().Y
    end)

    OpenButton.Position = UDim2.fromOffset(
        viewport.X - 18,
        insetTop + 18
    )
end)

connect(OpenButton.Activated, function()
    MenuOpen = true
    Main.Visible = true
    Min.Visible = true
    OpenButton.Visible = false
    Main.Size = UDim2.fromOffset(580, 400)

    task.defer(function()
        updateScale()
        clampMenuToViewport()
    end)
end)

--============================================================
-- RESPONSIVE SCALE
--============================================================

local lastViewport = Vector2.zero

clampMenuToViewport = function()
    local viewport = getViewport()
    local insetTop = 0

    pcall(function()
        insetTop = GuiService:GetGuiInset().Y
    end)

    local size = Main.AbsoluteSize
    local halfW = size.X * 0.5
    local halfH = size.Y * 0.5

    local minX = halfW + 6
    local maxX = math.max(minX, viewport.X - halfW - 6)
    local minY = insetTop + halfH + 6
    local maxY = math.max(minY, viewport.Y - halfH - 6)

    local center = Main.AbsolutePosition + Vector2.new(
        halfW,
        halfH
    )

    local target = Vector2.new(
        math.clamp(center.X, minX, maxX),
        math.clamp(center.Y, minY, maxY)
    )

    Main.Position = UDim2.fromOffset(
        target.X,
        target.Y
    )
end

updateScale = function()
    local viewport = getViewport()
    local insetTop = 0

    pcall(function()
        insetTop = GuiService:GetGuiInset().Y
    end)

    if viewport.X < 900 then
        local mobileW = math.clamp(
            viewport.X - 18,
            320,
            580
        )

        local mobileH = math.clamp(
            viewport.Y - insetTop - 34,
            300,
            520
        )

        Main.Size = UDim2.fromOffset(
            mobileW,
            mobileH
        )
    else
        Main.Size = UDim2.fromOffset(
            580,
            400
        )
    end

    if viewport.X < 600 then
        Sidebar.Size = UDim2.new(0, 92, 1, 0)
        Content.Position = UDim2.fromOffset(100, 0)
        Content.Size = UDim2.new(1, -100, 1, 0)

        for _, ref in pairs(TabRefs) do
            ref.Icon.Position = UDim2.fromOffset(7, 0)
            ref.Icon.Size = UDim2.fromOffset(18, 34)
            ref.Icon.TextSize = 11

            ref.Text.Position = UDim2.fromOffset(27, 0)
            ref.Text.Size = UDim2.new(1, -31, 1, 0)
            ref.Text.TextSize = 8
            ref.Text.TextTruncate = Enum.TextTruncate.AtEnd
        end
    else
        Sidebar.Size = UDim2.new(0, 120, 1, 0)
        Content.Position = UDim2.fromOffset(128, 0)
        Content.Size = UDim2.new(1, -128, 1, 0)

        for _, ref in pairs(TabRefs) do
            ref.Icon.Position = UDim2.fromOffset(9, 0)
            ref.Icon.Size = UDim2.fromOffset(22, 34)
            ref.Icon.TextSize = 12

            ref.Text.Position = UDim2.fromOffset(34, 0)
            ref.Text.Size = UDim2.new(1, -39, 1, 0)
            ref.Text.TextSize = 9
            ref.Text.TextTruncate = Enum.TextTruncate.AtEnd
        end
    end

    local baseScale

    if viewport.X <= 420 or viewport.Y <= 430 then
        baseScale = 0.76
    elseif viewport.X <= 720 or viewport.Y <= 540 then
        baseScale = 0.86
    else
        baseScale = 0.94
    end

    Scale.Scale = math.clamp(
        baseScale * ManualScale,
        0.55,
        1
    )

    if not MenuOpen then
        OpenButton.Position = UDim2.fromOffset(
            viewport.X - 18,
            insetTop + 18
        )
    end

    task.defer(clampMenuToViewport)
end

updateScale()

task.defer(function()
    Main.Position = UDim2.fromScale(0.5, 0.50)
    clampMenuToViewport()
end)

connect(Workspace:GetPropertyChangedSignal("CurrentCamera"), function()
    updateScale()

    task.defer(function()
        local viewport = getViewport()

        FOV.Position = UDim2.fromOffset(
            viewport.X * 0.5,
            viewport.Y * 0.5
        )

        FOV.Size = UDim2.fromOffset(
            math.clamp(State.Aim.FOV, 20, 350) * 2,
            math.clamp(State.Aim.FOV, 20, 350) * 2
        )

        FOV.Visible = State.Aim.Enabled
    end)
end)

connect(LocalPlayer.CharacterAdded, function()
    invalidateDuelCache(LocalPlayer)
    restoreCharacterAutoRotate()
    State.Aim.Target = nil
    State.Aim.SmoothedTargetPosition = nil

    task.defer(function()
        updateScale()

        local viewport = getViewport()

        FOV.Position = UDim2.fromOffset(
            viewport.X * 0.5,
            viewport.Y * 0.5
        )

        FOV.Visible = State.Aim.Enabled
    end)
end)

connect(RunService.RenderStepped, function()
    local viewport = getViewport()

    if viewport.X ~= lastViewport.X
        or viewport.Y ~= lastViewport.Y then
        lastViewport = viewport
        updateScale()
    end
end)

--============================================================
-- CAMERA AIM
--============================================================

pcall(function()
    RunService:UnbindFromRenderStep("NexusMurderDuelAim")
end)

RunService:BindToRenderStep(
    "NexusMurderDuelAim",
    Enum.RenderPriority.Camera.Value + 1,
    function(dt)

        if not State.Aim.Enabled
            or (not State.Aim.Aimbot and not State.Aim.TeleportShot) then
            restoreCharacterAutoRotate()
            return
        end

        local target = State.Aim.Target

        if not target or not validStickyTarget(target) then
            State.Aim.Target = nil
            State.Aim.SmoothedTargetPosition = nil
            restoreCharacterAutoRotate()
            return
        end

        local part = State.Aim.TeleportShot and getAimPart(target) or getVisibleAimPart(target)
        local camera = Workspace.CurrentCamera

        if not part or not camera then
            State.Aim.Target = nil
            State.Aim.SmoothedTargetPosition = nil
            restoreCharacterAutoRotate()
            return
        end

        if State.Aim.CheckVisible
            and not State.Aim.TeleportShot
            and not isTargetVisible(target, part) then
            State.Aim.Target = nil
            State.Aim.SmoothedTargetPosition = nil
            restoreCharacterAutoRotate()
            return
        end

        -- Teleport Shot owns its complete action: teleport behind the target,
        -- center the target in the camera, then fire from the screen center.
        if State.Aim.TeleportShot then
            teleportAndShoot(target, part)
            State.Aim.SmoothedTargetPosition = nil
            return
        end

        local velocity = Vector3.zero
        pcall(function()
            velocity = part.AssemblyLinearVelocity
        end)
        local desiredPosition = part.Position + (velocity * 0.02)

        local rate =
            28
            + (math.clamp(
                State.Aim.Smoothness,
                1,
                100
            ) * 0.72)

        local targetAlpha =
            1 - math.exp(
                -rate * math.clamp(dt, 0, 0.08)
            )

        if not State.Aim.SmoothedTargetPosition then
            State.Aim.SmoothedTargetPosition = desiredPosition
        else
            State.Aim.SmoothedTargetPosition =
                State.Aim.SmoothedTargetPosition:Lerp(
                    desiredPosition,
                    targetAlpha
                )
        end

        local desired = CFrame.lookAt(
            camera.CFrame.Position,
            State.Aim.SmoothedTargetPosition
        )

        local lockStrength =
            math.clamp(
                State.Aim.Smoothness / 100,
                0.01,
                1
            )

        local rateCamera =
            22 + (lockStrength * 80)

        local cameraAlpha =
            math.clamp(
                1 - math.exp(
                    -rateCamera
                    * math.clamp(dt, 0, 0.1)
                ),
                State.Aim.Stabilizer and 0.045 or 0.08,
                State.Aim.Stabilizer and 0.56 or 0.82
            )

        local dot = math.clamp(
            camera.CFrame.LookVector:Dot(
                desired.LookVector
            ),
            -1,
            1
        )

        local angle = math.acos(dot)

        local deadZone = State.Aim.Stabilizer and math.rad(0.42) or math.rad(0.06)

        if angle > deadZone then
            camera.CFrame =
                camera.CFrame:Lerp(
                    desired,
                    cameraAlpha
                )
        end

        if not State.Aim.Stabilizer or angle > math.rad(0.75) then
            syncCharacterToAim(State.Aim.SmoothedTargetPosition)
        end
    end
)

--============================================================
-- LIVE UPDATE LOOPS
--============================================================

local Runtime = {
    fpsFrames = 0,
    fpsClock = os.clock(),
    fpsValue = 60,
    ESPInterval = 0.09,
    nextESPUpdate = 0,
    AimInterval = 0.045,
    nextAimUpdate = 0,
    UIInterval = 0.25,
    nextUIUpdate = 0,
    ESPVisualInterval = 0.05,
    lastESPVisualUpdate = -math.huge,
}

connect(RunService.RenderStepped, function()
    local now = os.clock()
    local viewport = getViewport()

    -- FPS
    Runtime.fpsFrames += 1

    if now - Runtime.fpsClock >= 0.5 then
        Runtime.fpsValue = math.floor(
            (Runtime.fpsFrames / (now - Runtime.fpsClock)) + 0.5
        )

        Runtime.fpsFrames = 0
        Runtime.fpsClock = now
    end

    -- FOV
    FOV.Position = UDim2.fromOffset(
        viewport.X * 0.5,
        viewport.Y * 0.5
    )

    FOV.Size = UDim2.fromOffset(
        math.clamp(State.Aim.FOV, 20, 350) * 2,
        math.clamp(State.Aim.FOV, 20, 350) * 2
    )

    FOVStroke.Color = State.Aim.FOVColor
    FOVDot.BackgroundColor3 = State.Aim.FOVColor
    FOV.Visible = State.Aim.Enabled

    --========================================================
    -- AIM TARGET ACQUISITION
    --========================================================

    local teleportAllowed =
        (not State.Aim.TeleportShot)
        or (not State.Aim.DuelOnly)
        or hasCombatContext()

    local aimPipelineActive =
        State.Aim.Enabled
        and (State.Aim.Aimbot or State.Aim.TeleportShot)
        and teleportAllowed

    if State.Aim.TeleportShot and not teleportAllowed then
        State.Aim.Target = nil
        State.Aim.SmoothedTargetPosition = nil
        restoreCharacterAutoRotate()
    end

    if aimPipelineActive and now >= Runtime.nextAimUpdate then
        Runtime.nextAimUpdate = now + Runtime.AimInterval

        local currentTarget = State.Aim.Target
        local currentPart =
            currentTarget
            and (State.Aim.TeleportShot and getAimPart(currentTarget) or getVisibleAimPart(currentTarget))

        local badCurrent =
            not validStickyTarget(currentTarget)

        if currentPart == nil then
            badCurrent = true
        end

        if State.Aim.CheckVisible
            and not State.Aim.TeleportShot
            and currentTarget
            and currentPart
            and not isTargetVisible(
                currentTarget,
                currentPart
            ) then
            badCurrent = true
        end

        if badCurrent then
            State.Aim.Target = acquireTarget(State.Aim.TeleportShot)
            State.Aim.SmoothedTargetPosition = nil
        end

        local target = State.Aim.Target
        local part =
            target
            and (State.Aim.TeleportShot and getAimPart(target) or getVisibleAimPart(target))

        if not part or not isAlive(target) then
            State.Aim.Target = nil
            State.Aim.SmoothedTargetPosition = nil
            target = nil
            part = nil
        end

    elseif not State.Aim.Enabled then
        State.Aim.Target = nil
        State.Aim.SmoothedTargetPosition = nil
    end

    --========================================================
    -- ESP
    --========================================================
    -- Heavy/text work remains throttled, while visual projection is executed
    -- in a dedicated camera-priority RenderStep below the normal camera pass.

    if now >= Runtime.nextESPUpdate then
        Runtime.nextESPUpdate = now + Runtime.ESPInterval

        for player, data in pairs(ESPData) do
            local char = player.Character
            local root = getRoot(player)
            local humanoid =
                char and char:FindFirstChildOfClass("Humanoid")

            local valid =
                State.ESP.Enabled
                and char ~= nil
                and root ~= nil
                and humanoid ~= nil
                and humanoid.Health > 0
                and not (State.ESP.IgnoreTeam and sameTeam(player))
                and targetDistance(player) <= math.max(25, State.ESP.MaxDistance)

            if valid then
                local parts = {}

                if State.ESP.Name then
                    parts[#parts + 1] = player.DisplayName
                end

                if State.ESP.Health then
                    parts[#parts + 1] =
                        "HP " .. math.floor(humanoid.Health)
                end

                if State.ESP.Weapon then
                    parts[#parts + 1] =
                        getWeapon(player)
                end

                data.Label.Text =
                    table.concat(parts, "  •  ")
            end
        end

        local target = State.Aim.Target
        enemyValue.Text =
            target and target.DisplayName or "No target"

        if target and validStickyTarget(target) then
            AimModeText.Text =
                "TARGET  "
                .. tostring(target.DisplayName)
                .. (State.Aim.TeleportShot and "  •  TP SHOT" or "  •  360° LOCK")
            AimModeText.TextColor3 = C.GOOD
        else
            AimModeText.Text =
                "MODE  360°  •  TP SHOT"
            AimModeText.TextColor3 = C.ACCENT2
        end

        fnESP.Text =
            State.ESP.Enabled and "ENABLED" or "DISABLED"
        fnESP.TextColor3 =
            State.ESP.Enabled and C.GOOD or C.MUTED

        fnAim.Text =
            State.Aim.Enabled and "ENABLED" or "DISABLED"
        fnAim.TextColor3 =
            State.Aim.Enabled and C.GOOD or C.MUTED

        fnAimbot.Text =
            State.Aim.Aimbot and "ENABLED" or "DISABLED"
        fnAimbot.TextColor3 =
            State.Aim.Aimbot and C.GOOD or C.MUTED

        fnTeleport.Text =
            State.Aim.TeleportShot and "ENABLED" or "DISABLED"
        fnTeleport.TextColor3 =
            State.Aim.TeleportShot and C.GOOD or C.MUTED

        fnStabilizer.Text = State.Aim.Stabilizer and "ON" or "OFF"
        fnStabilizer.TextColor3 = State.Aim.Stabilizer and C.GOOD or C.MUTED
    end

    --========================================================
    -- LIVE STATUS / UI TELEMETRY
    --========================================================

    if now >= Runtime.nextUIUpdate then
        Runtime.nextUIUpdate = now + Runtime.UIInterval

        dFPS.Text = tostring(Runtime.fpsValue)
        dPing.Text = tostring(getPing()) .. " ms"

        dViewport.Text = string.format(
            "%d x %d",
            math.floor(viewport.X),
            math.floor(viewport.Y)
        )

        dDevice.Text = getDevice()
        dPlatform.Text = getPlatform()

        pClient.Text = "LOCAL"
        pName.Text = "LOCAL PLAYER"
        pDisplay.Text = "LOCAL"
        pId.Text = tostring(LocalPlayer.UserId)
    end
end)

--============================================================
-- ESP VISUAL RENDER PASS
--============================================================

pcall(function()
    RunService:UnbindFromRenderStep("NexusMurderDuelESP")
end)

RunService:BindToRenderStep(
    "NexusMurderDuelESP",
    Enum.RenderPriority.Camera.Value + 2,
    function()
        local now = os.clock()
        local camera = Workspace.CurrentCamera
        if not camera then
            return
        end

        if not State.ESP.Enabled then
            for _, data in pairs(ESPData) do
                data.Billboard.Adornee = nil
                data.Billboard.Enabled = false
                data.Highlight.Adornee = nil
                data.Highlight.Enabled = false
                for _, beam in ipairs(data.Skeleton) do
                    beam.Enabled = false
                end
            end
            return
        end

        if now - Runtime.lastESPVisualUpdate < Runtime.ESPVisualInterval then
            return
        end
        Runtime.lastESPVisualUpdate = now

        for player, data in pairs(ESPData) do
            local char = player.Character
            local root = getRoot(player)
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")

            local valid =
                State.ESP.Enabled
                and char ~= nil
                and root ~= nil
                and humanoid ~= nil
                and humanoid.Health > 0
                and not (State.ESP.IgnoreTeam and sameTeam(player))
                and targetDistance(player) <= math.max(25, State.ESP.MaxDistance)

            if valid then
                data.Billboard.Adornee = root
                data.Billboard.Enabled =
                    State.ESP.Name
                    or State.ESP.Health
                    or State.ESP.Weapon

                data.Highlight.Adornee = char
                data.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                data.Highlight.Enabled = State.ESP.Hitbox

                if State.ESP.Skeleton then
                    bindSkeleton(data, char)
                else
                    for _, beam in ipairs(data.Skeleton) do
                        beam.Enabled = false
                    end
                end
            else
                data.Billboard.Adornee = nil
                data.Billboard.Enabled = false
                data.Highlight.Adornee = nil
                data.Highlight.Enabled = false
                for _, beam in ipairs(data.Skeleton) do
                    beam.Enabled = false
                end
            end
        end
    end
)

--============================================================
-- GAME NAME
--============================================================

task.spawn(function()
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(
            game.PlaceId
        )
    end)

    if ok and info and info.Name then
        gameNameValue.Text = tostring(info.Name)
    else
        gameNameValue.Text = "Nexus Murder Duel"
    end
end)

--============================================================
-- HOTKEY
--============================================================

connect(UserInputService.InputBegan, function(input, processed)
    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.RightShift then
        MenuOpen = not MenuOpen
        Gui.Enabled = true

        if MenuOpen then
            Main.Visible = true
            Min.Visible = true
            OpenButton.Visible = false

            task.defer(function()
                updateScale()
                clampMenuToViewport()
            end)
        else
            Main.Visible = false
            Min.Visible = false
            OpenButton.Visible = true
            FOV.Visible = State.Aim.Enabled
        end
    end
end)

--============================================================
-- NEXUS VEXAL FEATURE PACK
-- Full port of the supplied Vexal-style functions into the
-- existing NEXUS custom GUI. No WindUI / Drawing dependency.
--============================================================

NexusVexalPack = NexusVexalPack or {}

function NexusVexalPack.build()
    if type(getgenv) == "function" then
        local g = getgenv()
        if type(g.NexusVexalCleanup) == "function" then
            pcall(g.NexusVexalCleanup)
        end
    end

    local V = {
        running = true,
        match = false,
        matchEnemies = {},
        threads = {},
        connections = {},
        originalCooldowns = {},
        originalHitboxes = {},
        originalSpeed = 16,
        speedEnabled = false,
        currentSpeed = 16,
        autoUnanchor = false,
        removeCooldown = false,
        autoShoot = false,
        autoShootDistance = 300,
        autoShootCooldown = 2,
        autoThrow = false,
        throwDistance = 300,
        throwCooldown = 2,
        lastThrow = 0,
        triggerbot = false,
        triggerbotCooldown = 1,
        triggerbotFiring = false,
        hitboxExpander = false,
        hitboxSize = 13,
        hitboxColor = Color3.fromRGB(255, 0, 0),
        teamColor = Color3.fromRGB(0, 255, 0),
        enemyColor = Color3.fromRGB(255, 0, 0),
        charms = false,
        tracers = false,
        tracerConnection = nil,
        charmsFolder = nil,
        skeletonFolder = nil,
        tracerFolder = nil,
        autoKillGun = false,
        autoKillKnife = false,
        autoShroud = false,
        lowExecutorShroud = false,
        shroudRate = 1,
        abilityLocked = true,
        abilityConfig = nil,
        activateShroud = nil,
        autoWalk = false,
        currentPad = nil,
        fovEnabled = false,
        fovAuto = false,
        fovManual = false,
        fovRadius = 100,
        fovCooldown = 1,
        fovLastShot = 0,
        fovCircle = nil,
        manualGunControllerThread = nil,
        autoSpin = false,
        noclip = false,
        notifyValue = nil,
        padSection = nil,
        abilityStatus = nil,
    }

    NexusVexalPack.state = V

    local g = type(getgenv) == "function" and getgenv() or _G
    g.NexusVexalState = V

    local function c(signal, fn)
        local ok, conn = pcall(function() return signal:Connect(fn) end)
        if ok and conn then
            V.connections[#V.connections + 1] = conn
        end
        return conn
    end

    local function spawn(fn)
        local th = task.spawn(fn)
        V.threads[#V.threads + 1] = th
        return th
    end

    local function setNotify(text)
        if V.notifyValue then
            V.notifyValue.Text = text
        end
        print("[Nexus] " .. tostring(text))
    end

    local function makeButton(parent, top, text, callback)
        local b = Instance.new("TextButton")
        b.AutoButtonColor = false
        b.Position = UDim2.fromOffset(12, top)
        b.Size = UDim2.new(1, -24, 0, 29)
        b.BackgroundColor3 = C.PANEL3
        b.BorderSizePixel = 0
        b.Font = BOLD
        b.Text = text
        b.TextSize = 8
        b.TextColor3 = C.TEXT
        b.Parent = parent
        addCorner(b, 8)
        addStroke(b, C.OUTLINE, 1, 0.3)
        c(b.Activated, function()
            if callback then callback() end
        end)
        return b
    end

    local function cycleColor(current, palette)
        local idx = 1
        local best = math.huge
        for i, color in ipairs(palette) do
            local d = (current.R - color.R)^2 + (current.G - color.G)^2 + (current.B - color.B)^2
            if d < best then
                best = d
                idx = i
            end
        end
        return palette[(idx % #palette) + 1]
    end

    function V.getMatchId()
        local value = Player:GetAttribute("Match")
        if value == nil or value == false or value == "" then
            return nil
        end
        return value
    end

    function V.refreshMatches()
        local id = V.getMatchId()
        V.match = id ~= nil
        table.clear(V.matchEnemies)
        if not id then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p:GetAttribute("Match") == id then
                local char = p.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    V.matchEnemies[#V.matchEnemies + 1] = p
                end
            end
        end
    end

    function V.getGun()
        local char = Player.Character
        local backpack = Player:FindFirstChildOfClass("Backpack")
        for _, container in ipairs({backpack, char}) do
            if container then
                for _, tool in ipairs(container:GetChildren()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Fire") and tool:FindFirstChild("Reload") then
                        return tool
                    end
                end
            end
        end
        return nil
    end

    function V.equipGun()
        if not V.match then return false end
        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local gun = V.getGun()
        if hum and hum.Health > 0 and gun then
            pcall(function() hum:EquipTool(gun) end)
            return true
        end
        return false
    end

    function V.equipKnife()
        if not V.match then return false end
        local char = Player.Character
        local backpack = Player:FindFirstChildOfClass("Backpack")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return false end
        for _, tool in ipairs({backpack, char}) do
            if tool then
                for _, obj in ipairs(tool:GetChildren()) do
                    if obj:IsA("Tool") and obj:GetAttribute("EquipAnimation") == "Knife_Equip" then
                        pcall(function() hum:EquipTool(obj) end)
                        return true
                    end
                end
            end
        end
        return false
    end

    function V.getRayOrigin(char)
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        return (root.CFrame * CFrame.new(0, 0, root.Size.Z / 2)).Position
    end

    function V.bulletRenderer(origin, targetPos)
        local a = Instance.new("Part")
        local b = Instance.new("Part")
        local beam = Instance.new("Beam")
        a.Size = Vector3.new(0.1, 0.1, 0.1)
        b.Size = Vector3.new(0.1, 0.1, 0.1)
        a.Transparency = 1
        b.Transparency = 1
        a.Anchored = true
        b.Anchored = true
        a.CanCollide = false
        b.CanCollide = false
        a.CanQuery = false
        b.CanQuery = false
        a.CanTouch = false
        b.CanTouch = false
        a.CFrame = CFrame.lookAt(origin, targetPos) * CFrame.new(0, 0, -1)
        b.CFrame = CFrame.new(targetPos)
        a.Parent = Workspace
        b.Parent = Workspace
        local a0 = Instance.new("Attachment")
        local a1 = Instance.new("Attachment")
        a0.Parent = a
        a1.Parent = b
        beam.Attachment0 = a0
        beam.Attachment1 = a1
        beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        beam.LightEmission = 1
        beam.Width0 = 0.3
        beam.Width1 = 0.6
        beam.Parent = a
        Debris:AddItem(a, 0.15)
        Debris:AddItem(b, 0.15)
    end

    function V.shootGun(target)
        if not target or not target.Character then return false end
        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local remote = remotes and remotes:FindFirstChild("ShootGun")
        if not char or not hum or hum.Health <= 0 or not root or not remote or not remote:IsA("RemoteEvent") then return false end
        local hitPart = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
        local tool = V.getGun()
        if not hitPart or not tool then return false end
        local origin = V.getRayOrigin(char) or root.Position
        local muzzle = tool:FindFirstChild("Muzzle", true)
        local startPos = (muzzle and muzzle:IsA("Attachment")) and muzzle.WorldPosition or origin
        V.bulletRenderer(startPos, hitPart.Position)
        pcall(function()
            remote:FireServer(origin, hitPart.Position, hitPart, hitPart.Position)
        end)
        local sound = tool:FindFirstChild("Fire")
        if sound and sound:IsA("Sound") then
            pcall(function() sound:Play() end)
        end
        return true
    end

    function V.sameTeam(p)
        return p and Player.Team ~= nil and p.Team ~= nil and p.Team == Player.Team
    end

    function V.hasClearLos(fromPos, toPos, myChar, targetChar)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {myChar, targetChar}
        local hit = Workspace:Raycast(fromPos, toPos - fromPos, params)
        return not hit or hit.Instance:IsDescendantOf(targetChar)
    end

    function V.isCombatEnemy(p)
        if not p or p == Player or not V.match or V.sameTeam(p) then return false end
        local char = p.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        return hum ~= nil and hum.Health > 0 and root ~= nil and p:GetAttribute("Match") == V.getMatchId()
    end

    function V.closestTarget(maxDistance, fovOnly)
        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local camera = Workspace.CurrentCamera
        if not root or not camera then return nil end
        local best, bestDist = nil, maxDistance or math.huge
        for _, p in ipairs(V.matchEnemies) do
            if V.isCombatEnemy(p) then
                local pr = p.Character:FindFirstChild("HumanoidRootPart")
                if pr then
                    local dist = (pr.Position - root.Position).Magnitude
                    if dist < bestDist then
                        local okFov = true
                        if fovOnly then
                            local direction = (pr.Position - camera.CFrame.Position).Unit
                            okFov = camera.CFrame.LookVector:Dot(direction) >= 0.9
                        end
                        if okFov then
                            best = p
                            bestDist = dist
                        end
                    end
                end
            end
        end
        return best
    end

    function V.getMouseFovTarget()
        local camera = Workspace.CurrentCamera
        if not camera then return nil end
        local mouse = UserInputService:GetMouseLocation()
        local best, bestDist = nil, V.fovRadius
        for _, p in ipairs(V.matchEnemies) do
            if V.isCombatEnemy(p) then
                local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local screen, visible = camera:WorldToViewportPoint(root.Position)
                    if visible then
                        local dist = (Vector2.new(screen.X, screen.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude
                        if dist <= bestDist then
                            best = p
                            bestDist = dist
                        end
                    end
                end
            end
        end
        return best
    end

    function V.isInFov(targetPosition)
        local camera = Workspace.CurrentCamera
        if not camera then return false end
        local screen, visible = camera:WorldToViewportPoint(targetPosition)
        if not visible then return false end
        local mouse = UserInputService:GetMouseLocation()
        return (Vector2.new(screen.X, screen.Y) - Vector2.new(mouse.X, mouse.Y)).Magnitude <= V.fovRadius
    end

    function V.throwKnife(targetChar)
        local char = Player.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        local throwStart = remotes and remotes:FindFirstChild("ThrowStart")
        local throwHit = remotes and remotes:FindFirstChild("ThrowHit")
        local controller = modules and modules:FindFirstChild("KnifeProjectileController")
        if not tool or not targetRoot or not throwStart or not throwHit or not controller then return false end
        local origin = V.getRayOrigin(char)
        if not origin then return false end
        local direction = (targetRoot.Position - origin).Unit
        local ok, projectile = pcall(require, controller)
        if not ok or type(projectile) ~= "function" then return false end
        pcall(function() throwStart:FireServer(origin, direction) end)
        pcall(function()
            projectile({
                Speed = tool:GetAttribute("ThrowSpeed"),
                KnifeProjectile = tool:FindFirstChild("RightHandle") and tool.RightHandle:Clone() or tool.Handle:Clone(),
                Direction = direction,
                Origin = origin,
            }, function(result)
                if result then
                    pcall(function() throwHit:FireServer(result.Instance, result.Position) end)
                end
            end)
        end)
        V.lastThrow = tick()
        return true
    end

    function V.triggerValid(p)
        if not V.isCombatEnemy(p) then return false end
        local char = p.Character
        if not char or not char:IsDescendantOf(Workspace) then return false end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or hum.Health <= 0 or not root then return false end
        local collection = game:GetService("CollectionService")
        return not collection:HasTag(char, "Invulnerable") and not collection:HasTag(char, "SpeedTrail")
    end

    function V.cleanupHitboxes()
        for hrp, old in pairs(V.originalHitboxes) do
            if hrp and hrp.Parent then
                pcall(function()
                    hrp.Size = old.Size
                    hrp.CanCollide = old.CanCollide
                    local adorn = hrp:FindFirstChild("NexusVexalHitbox")
                    if adorn then adorn:Destroy() end
                end)
            end
        end
        table.clear(V.originalHitboxes)
    end

    function V.updateHitboxes()
        for _, p in ipairs(V.matchEnemies) do
            if V.isCombatEnemy(p) then
                local char = p.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if not V.originalHitboxes[hrp] then
                        V.originalHitboxes[hrp] = {Size = hrp.Size, CanCollide = hrp.CanCollide}
                    end
                    hrp.Size = Vector3.new(V.hitboxSize, V.hitboxSize, V.hitboxSize)
                    hrp.CanCollide = true
                    local box = hrp:FindFirstChild("NexusVexalHitbox")
                    if not box then
                        box = Instance.new("BoxHandleAdornment")
                        box.Name = "NexusVexalHitbox"
                        box.Adornee = hrp
                        box.AlwaysOnTop = true
                        box.ZIndex = 10
                        box.Transparency = 0.8
                        box.Parent = hrp
                    end
                    box.Size = hrp.Size
                    box.Color3 = V.hitboxColor
                end
            end
        end
    end

    function V.updateCharms()
        if not V.charmsFolder then return end
        local alive = {}
        for _, p in ipairs(V.matchEnemies) do
            if V.isCombatEnemy(p) and p.Character then
                alive[p.Name] = true
                local h = V.charmsFolder:FindFirstChild(p.Name)
                if not h then
                    h = Instance.new("Highlight")
                    h.Name = p.Name
                    h.FillTransparency = 0.6
                    h.OutlineTransparency = 0.3
                    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    h.Parent = V.charmsFolder
                end
                h.FillColor = V.enemyColor
                h.OutlineColor = V.enemyColor
                h.Adornee = p.Character
            end
        end
        for _, h in ipairs(V.charmsFolder:GetChildren()) do
            if not alive[h.Name] then h:Destroy() end
        end
    end

    function V.clearTracers()
        if not V.tracerFolder then return end
        for _, child in ipairs(V.tracerFolder:GetChildren()) do child:Destroy() end
    end

    function V.updateTracers()
        if not V.tracerFolder then return end
        if not V.tracers then
            V.clearTracers()
            return
        end
        local myChar = Player.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end
        local active = {}
        for _, p in ipairs(V.matchEnemies) do
            if V.isCombatEnemy(p) and p.Character then
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    active[p.Name] = true
                    local line = V.tracerFolder:FindFirstChild(p.Name)
                    if not line then
                        line = Instance.new("LineHandleAdornment")
                        line.Name = p.Name
                        line.Thickness = 1.5
                        line.ZIndex = 10
                        line.AlwaysOnTop = true
                        line.Parent = V.tracerFolder
                    end
                    line.Color3 = V.enemyColor
                    line.Adornee = Workspace.Terrain
                    line.CFrame = CFrame.lookAt(myRoot.Position, root.Position)
                    line.Length = (myRoot.Position - root.Position).Magnitude
                end
            end
        end
        for _, child in ipairs(V.tracerFolder:GetChildren()) do
            if not active[child.Name] then child:Destroy() end
        end
    end

    function V.stopManualGunController()
        if V.manualGunControllerThread then
            pcall(task.cancel, V.manualGunControllerThread)
            V.manualGunControllerThread = nil
        end
    end

    function V.startManualGunController()
        V.stopManualGunController()
        V.manualGunControllerThread = task.spawn(function()
            while V.running and V.fovManual do
                task.wait()
                local model = Workspace:FindFirstChild(Player.Name)
                local controller = model and model:FindFirstChild("GunController")
                if controller then
                    pcall(function() controller.Parent = nil end)
                end
            end
        end)
        V.threads[#V.threads + 1] = V.manualGunControllerThread
    end

    function V.tryKillAllGun()
        if not V.match then return end
        V.equipGun()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local remote = remotes and remotes:FindFirstChild("ShootGun")
        local char = Player.Character
        local origin = char and char:FindFirstChild("HumanoidRootPart")
        if not remote or not origin then return end
        for _, p in ipairs(V.matchEnemies) do
            if V.isCombatEnemy(p) then
                local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    pcall(function() remote:FireServer(origin.Position, root.Position, root, root.Position) end)
                    task.wait(0.1)
                end
            end
        end
    end

    function V.tryKillAllKnife()
        if not V.match then return end
        V.equipKnife()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local remote = remotes and remotes:FindFirstChild("ThrowHit")
        if not remote then return end
        for _, p in ipairs(V.matchEnemies) do
            if V.isCombatEnemy(p) then
                local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    pcall(function() remote:FireServer(root, root.Position) end)
                    task.wait(0.1)
                end
            end
        end
    end

    function V.blind(target)
        if not target or not target.Character then return end
        local char = Player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if not root or not targetRoot or not V.activateShroud then return end
        local origin = root.Position
        local direction = (targetRoot.Position - origin).Unit
        local modules = ReplicatedStorage:FindFirstChild("Modules")
        local controller = ReplicatedStorage:FindFirstChild("Ability") and ReplicatedStorage.Ability:FindFirstChild("ShroudProjectileController")
        local rayOriginModule = modules and modules:FindFirstChild("CharacterRayOrigin")
        if not V.lowExecutorShroud and controller and rayOriginModule then
            local ok1, rayOrigin = pcall(require, rayOriginModule)
            local ok2, projectile = pcall(require, controller)
            if ok1 and ok2 and type(rayOrigin) == "function" and type(projectile) == "function" then
                origin = rayOrigin(char)
                direction = (targetRoot.Position - origin).Unit
                pcall(function() V.activateShroud:FireServer(origin, direction) end)
                pcall(function() projectile(origin, direction) end)
                return
            end
            V.lowExecutorShroud = true
        end
        pcall(function() V.activateShroud:FireServer(origin, direction) end)
    end

    function V.getPadGroups()
        return {DuelRing_1v1 = 1, DuelRing_2v2 = 2, DuelRing_3v3 = 3, DuelRing_4v4 = 4}
    end

    function V.walkTo(model)
        local char = Player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not char or not hum or not root or not model or not model.PrimaryPart then return end
        hum.WalkSpeed = 35
        local dist = (root.Position - model.PrimaryPart.Position).Magnitude
        if dist <= 6 then
            V.noclip = false
        end
        hum:MoveTo(model.PrimaryPart.Position)
        if not V.walkJumpAt or os.clock() - V.walkJumpAt >= 2 then
            V.walkJumpAt = os.clock()
            hum.Jump = true
        end
        if V.autoWalk then
            V.noclip = true
        end
    end

    function V.findPad()
        local lobby = Workspace:FindFirstChild("Lobby")
        local groups = V.getPadGroups()
        if not lobby then return nil end
        for groupName, maxCount in pairs(groups) do
            local ringFolder = lobby:FindFirstChild("DuelRingsGroup") and lobby.DuelRingsGroup:FindFirstChild(groupName)
            if ringFolder then
                local total = 0
                local pads = {}
                for _, model in ipairs(ringFolder:GetChildren()) do
                    if model:IsA("Model") and model.Name == "DuelPad" then
                        local count = model:GetAttribute("CharacterCount") or 0
                        total += count
                        pads[#pads + 1] = {model = model, count = count}
                    end
                end
                if total == (maxCount * 2) - 1 then
                    for _, pad in ipairs(pads) do
                        if pad.count < maxCount then
                            return pad.model
                        end
                    end
                end
            end
        end
        return nil
    end

    function V.restoreSpeed()
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = V.originalSpeed end
    end

    local MainPage = ExtraPages.Main
    local KillPage = ExtraPages["Kill All"]
    local AbilityPage = ExtraPages.Ability
    local TeleportPage = ExtraPages.Teleport
    local FOVPage = ExtraPages.FOV

    local mainSection = makeSection(MainPage, 454, 520, "COMBAT FEATURES")
    V.notifyValue = makeValue(mainSection, 30, "Status", "READY")
    makeToggle(mainSection, 58, "Auto UnAnchor Character", false, function(v)
        V.autoUnanchor = v
        setNotify(v and "Auto unanchor enabled" or "Auto unanchor disabled")
    end)
    makeToggle(mainSection, 90, "Remove Gun Cooldown", false, function(v)
        V.removeCooldown = v
        if not v then
            for tool, old in pairs(V.originalCooldowns) do
                if tool and tool.Parent then pcall(function() tool:SetAttribute("Cooldown", old) end) end
            end
            table.clear(V.originalCooldowns)
        end
    end)
    makeToggle(mainSection, 122, "Autoshoot", false, function(v) V.autoShoot = v end)
    makeSlider(mainSection, 160, "Autoshoot Distance", 25, 1000, 300, function(v) V.autoShootDistance = v end)
    makeSlider(mainSection, 207, "Autoshoot Cooldown", 0, 10, 2, function(v) V.autoShootCooldown = v end)
    makeToggle(mainSection, 262, "Auto Throw Knife", false, function(v) V.autoThrow = v end)
    makeSlider(mainSection, 300, "Throw Distance", 25, 1000, 300, function(v) V.throwDistance = v end)
    makeSlider(mainSection, 347, "Throw Cooldown", 0.5, 10, 2, function(v) V.throwCooldown = v end)
    makeToggle(mainSection, 402, "Triggerbot", false, function(v) V.triggerbot = v end)
    makeSlider(mainSection, 440, "Triggerbot Cooldown", 0, 3, 1, function(v) V.triggerbotCooldown = v end)

    local miscSection = makeSection(MainPage, 986, 300, "MOVEMENT / MISC")
    makeToggle(miscSection, 30, "Auto Spin", false, function(v) V.autoSpin = v end)
    makeToggle(miscSection, 62, "Noclip", false, function(v) V.noclip = v end)
    makeToggle(miscSection, 94, "Enable Speed Changer", false, function(v)
        V.speedEnabled = v
        if not v then V.restoreSpeed() end
    end)
    makeSlider(miscSection, 132, "Walk Speed", 16, 200, 16, function(v) V.currentSpeed = v end)
    V.matchValue = makeValue(miscSection, 188, "Match", "NO")
    V.enemyCountValue = makeValue(miscSection, 213, "Enemy Count", "0")

    makeTitle(ExtraPages["Kill All"], "KILL ALL", "Gun / knife actions from the supplied feature set")
    local killGun = makeSection(KillPage, 54, 150, "GUN")
    makeButton(killGun, 32, "KILL ALL PLAYERS ONCE", function()
        if V.match then V.tryKillAllGun() else setNotify("Enter a match first") end
    end)
    makeToggle(killGun, 70, "Auto Kill Players", false, function(v) V.autoKillGun = v end)
    makeButton(killGun, 108, "EQUIP GUN", function() V.equipGun() end)

    local killKnife = makeSection(KillPage, 216, 150, "KNIFE")
    makeButton(killKnife, 32, "KILL ALL PLAYERS ONCE", function()
        if V.match then V.tryKillAllKnife() else setNotify("Enter a match first") end
    end)
    makeToggle(killKnife, 70, "Auto Kill Players", false, function(v) V.autoKillKnife = v end)
    makeButton(killKnife, 108, "EQUIP KNIFE", function() V.equipKnife() end)

    makeTitle(AbilityPage, "ABILITY", "Shroud + editable AbilityConfig values")
    local abilityStatus = makeSection(AbilityPage, 54, 180, "ABILITY STATUS")
    V.abilityStatus = makeValue(abilityStatus, 30, "Config", "Checking...")
    makeToggle(abilityStatus, 58, "Auto Shroud Players", false, function(v) V.autoShroud = v end)
    makeToggle(abilityStatus, 90, "Low Executor Mode", false, function(v) V.lowExecutorShroud = v end)
    makeSlider(abilityStatus, 122, "Shrouds / Enemy", 1, 1000, 1, function(v) V.shroudRate = math.max(0.1, v) end)

    local abilityValues = makeSection(AbilityPage, 246, 780, "ABILITY CONFIG")
    local cfgOk, cfg = pcall(function() return require(ReplicatedStorage.Ability.AbilityConfig) end)
    V.abilityLocked = not cfgOk
    V.abilityConfig = cfgOk and cfg or nil
    local abilityConfig = V.abilityConfig
    V.activateShroud = (ReplicatedStorage:FindFirstChild("Ability") and ReplicatedStorage.Ability:FindFirstChild("ActivateShroud")) or nil
    V.abilityStatus.Text = V.abilityLocked and "Unavailable" or "Loaded"

    local function cfgNumber(name, fallback)
        local n = abilityConfig and tonumber(abilityConfig[name])
        return n or fallback
    end
    local function setCfg(name, value)
        if V.abilityLocked or not abilityConfig then return end
        pcall(function() abilityConfig[name] = value end)
    end

    V.abilityOriginals = {
        SprintCooldown = cfgNumber("SprintCooldown", 15),
        DashCooldown = cfgNumber("DashCooldown", 6),
        ShroudCooldown = cfgNumber("ShroudCooldown", 7),
        SoulReapCombatDelay = cfgNumber("SoulReapCombatDelay", 0.35),
    }

    makeToggle(abilityValues, 24, "Remove Sprint Cooldown", false, function(v)
        setCfg("SprintCooldown", v and 0 or V.abilityOriginals.SprintCooldown)
    end)
    makeToggle(abilityValues, 56, "Remove Dash Cooldown", false, function(v)
        setCfg("DashCooldown", v and 0 or V.abilityOriginals.DashCooldown)
    end)
    makeToggle(abilityValues, 88, "Remove Shroud Cooldown", false, function(v)
        setCfg("ShroudCooldown", v and 0 or V.abilityOriginals.ShroudCooldown)
    end)
    makeToggle(abilityValues, 120, "Remove Soul Reap Combat Delay", false, function(v)
        setCfg("SoulReapCombatDelay", v and 0 or V.abilityOriginals.SoulReapCombatDelay)
    end)

    makeSlider(abilityValues, 166, "Sprint Cooldown", 0, 15, cfgNumber("SprintCooldown", 15), function(v) setCfg("SprintCooldown", v) end)
    makeSlider(abilityValues, 214, "Dash Cooldown", 0, 15, cfgNumber("DashCooldown", 6), function(v) setCfg("DashCooldown", v) end)
    makeSlider(abilityValues, 262, "Shroud Cooldown", 0, 15, cfgNumber("ShroudCooldown", 7), function(v) setCfg("ShroudCooldown", v) end)
    makeSlider(abilityValues, 310, "Soul Reap Combat Delay", 0, 3, cfgNumber("SoulReapCombatDelay", 0.35), function(v) setCfg("SoulReapCombatDelay", v) end)
    makeSlider(abilityValues, 358, "Sprint Time", 0.5, 10, cfgNumber("SprintTime", 3), function(v) setCfg("SprintTime", v) end)
    makeSlider(abilityValues, 406, "Sprint Boost", 0, 5, cfgNumber("SprintBoost", 1), function(v) setCfg("SprintBoost", v) end)
    makeSlider(abilityValues, 454, "Soul Reap Time", 0.5, 10, cfgNumber("SoulReapTime", 3), function(v) setCfg("SoulReapTime", v) end)
    makeSlider(abilityValues, 502, "Soul Reap Speed Boost", 0.1, 10, cfgNumber("SoulReapSpeedBoost", 1), function(v) setCfg("SoulReapSpeedBoost", v) end)
    makeSlider(abilityValues, 550, "Propeller Jump Boost", 0.1, 5, cfgNumber("PropellerJumpBoost", 1), function(v) setCfg("PropellerJumpBoost", v) end)
    makeSlider(abilityValues, 598, "Shroud Time", 0.5, 10, cfgNumber("ShroudTime", 3), function(v) setCfg("ShroudTime", v) end)
    makeSlider(abilityValues, 646, "Shroud Projectile Speed", 2.5, 100, cfgNumber("ShroudProjectileSpeed", 20), function(v) setCfg("ShroudProjectileSpeed", v) end)
    makeSlider(abilityValues, 694, "Shroud Projectile Range", 5, 1000, cfgNumber("ShroudProjectileRange", 100), function(v) setCfg("ShroudProjectileRange", v) end)

    makeTitle(TeleportPage, "TELEPORT", "Lobby duel pad helper")
    local teleSection = makeSection(TeleportPage, 54, 170, "AUTO WALK")
    makeToggle(teleSection, 30, "Enable Auto Walk to Duel Pads", false, function(v) V.autoWalk = v end)
    makeButton(teleSection, 68, "FIND AVAILABLE DUEL PAD", function()
        V.currentPad = V.findPad()
        if V.currentPad then
            V.walkTo(V.currentPad)
            setNotify("Walking to " .. tostring(V.currentPad.Name))
        else
            setNotify("No available duel pad found")
        end
    end)
    makeButton(teleSection, 106, "STOP AUTO WALK", function()
        V.autoWalk = false
        V.currentPad = nil
        V.noclip = false
    end)
    makeValue(teleSection, 144, "Current Pad", "None")

    V.padSection = makeSection(TeleportPage, 236, 560, "DUEL PAD BUTTONS")
    makeButton(V.padSection, 30, "REFRESH PAD BUTTONS", function()
        V.rebuildPadButtons()
    end)

    function V.rebuildPadButtons()
        if not V.padSection then return end
        for _, child in ipairs(V.padSection:GetChildren()) do
            if child:GetAttribute("NexusPadButton") then child:Destroy() end
        end
        local lobby = Workspace:FindFirstChild("Lobby")
        local groups = V.getPadGroups()
        if not lobby then return end
        local top = 66
        for groupName, _ in pairs(groups) do
            local folder = lobby:FindFirstChild("DuelRingsGroup") and lobby.DuelRingsGroup:FindFirstChild(groupName)
            if folder then
                local index = 1
                for _, model in ipairs(folder:GetChildren()) do
                    if model:IsA("Model") and model.Name == "DuelPad" then
                        local title = "Walk to " .. groupName .. " " .. tostring(index)
                        local btn = makeButton(V.padSection, top, title, function()
                            V.currentPad = model
                            V.autoWalk = false
                            V.walkTo(model)
                        end)
                        btn:SetAttribute("NexusPadButton", true)
                        top += 34
                        index += 1
                    end
                end
            end
        end
    end
    V.rebuildPadButtons()

    makeTitle(FOVPage, "FOV SHOOTING", "Mouse FOV circle • autoshoot • manual shoot")
    local fovSection = makeSection(FOVPage, 54, 300, "FOV")
    makeToggle(fovSection, 30, "Enable FOV Circle", false, function(v) V.fovEnabled = v end)
    V.fovAutoControl = makeToggle(fovSection, 62, "Autoshoot FOV", false, function(v)
        V.fovAuto = v
        if v then V.fovManual = false; V.stopManualGunController() end
    end)
    V.fovManualControl = makeToggle(fovSection, 94, "FOV Manual Shoot", false, function(v)
        V.fovManual = v
        if v then V.fovAuto = false; V.startManualGunController() else V.stopManualGunController() end
    end)
    makeSlider(fovSection, 132, "FOV Circle Size", 35, 300, 100, function(v) V.fovRadius = v end)
    makeSlider(fovSection, 179, "FOV Shoot Cooldown", 0, 5, 1, function(v) V.fovCooldown = v end)
    makeValue(fovSection, 235, "Mode", "OFF")

    local extraEsp = makeSection(ESPPage, 492, 230, "EXTRA ESP")
    V.charmsFolder = CoreGui:FindFirstChild("NexusCharmsESP") or Instance.new("Folder")
    V.charmsFolder.Name = "NexusCharmsESP"
    V.charmsFolder.Parent = CoreGui
    V.tracerFolder = CoreGui:FindFirstChild("NexusTracers") or Instance.new("Folder")
    V.tracerFolder.Name = "NexusTracers"
    V.tracerFolder.Parent = CoreGui
    makeToggle(extraEsp, 30, "ESP Charms", false, function(v) V.charms = v if not v then for _, child in ipairs(V.charmsFolder:GetChildren()) do child:Destroy() end end end)
    makeToggle(extraEsp, 62, "ESP Tracers", false, function(v) V.tracers = v if not v then V.clearTracers() end end)
    makeToggle(extraEsp, 94, "Hitbox Expander", false, function(v) V.hitboxExpander = v if not v then V.cleanupHitboxes() end end)
    makeSlider(extraEsp, 132, "Hitbox Size", 5, 100, 13, function(v) V.hitboxSize = v end)
    makeButton(extraEsp, 184, "CYCLE ESP COLORS", function()
        local palette = {C.CYAN, C.VIOLET, C.MAGENTA, C.GOOD, C.WARN, C.TEXT, C.BAD}
        V.enemyColor = cycleColor(V.enemyColor, palette)
        V.teamColor = cycleColor(V.teamColor, {C.GOOD, C.CYAN, C.TEXT, C.WARN})
        V.hitboxColor = cycleColor(V.hitboxColor, {C.BAD, C.MAGENTA, C.VIOLET, C.CYAN, C.WARN})
        setNotify("ESP colors changed")
    end)

    -- FOV circle: regular Roblox UI instead of Drawing.new.
    V.fovCircle = Instance.new("Frame")
    V.fovCircle.Name = "NexusMouseFOV"
    V.fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    V.fovCircle.BackgroundTransparency = 1
    V.fovCircle.BorderSizePixel = 0
    V.fovCircle.Size = UDim2.fromOffset(V.fovRadius * 2, V.fovRadius * 2)
    V.fovCircle.Visible = false
    V.fovCircle.ZIndex = 20
    V.fovCircle.Parent = Gui
    addCorner(V.fovCircle, 999)
    addStroke(V.fovCircle, C.TEXT, 2, 0)

    -- Threads / connections.
    spawn(function()
        while V.running do
            V.refreshMatches()
            task.wait(0.1)
        end
    end)

    spawn(function()
        while V.running do
            if V.autoUnanchor then
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root and root.Anchored then root.Anchored = false end
            end
            task.wait(0.08)
        end
    end)

    spawn(function()
        while V.running do
            if V.removeCooldown then
                for _, container in ipairs({Player:FindFirstChild("Backpack"), Player.Character}) do
                    if container then
                        for _, tool in ipairs(container:GetChildren()) do
                            if tool:IsA("Tool") and tool:FindFirstChild("Fire") then
                                if V.originalCooldowns[tool] == nil then
                                    V.originalCooldowns[tool] = tool:GetAttribute("Cooldown")
                                end
                                if tool:GetAttribute("Cooldown") ~= 0 then
                                    pcall(function() tool:SetAttribute("Cooldown", 0) end)
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)

    local lastAutoShot = 0
    spawn(function()
        while V.running do
            if V.autoShoot and V.match and tick() - lastAutoShot >= V.autoShootCooldown then
                local target = V.closestTarget(V.autoShootDistance, true)
                if target then
                    local myChar = Player.Character
                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    local targetRoot = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot and targetRoot and V.hasClearLos(myRoot.Position, targetRoot.Position, myChar, target.Character) then
                        if V.shootGun(target) then lastAutoShot = tick() end
                    end
                end
            end
            task.wait(0.03)
        end
    end)

    spawn(function()
        while V.running do
            if V.autoThrow and V.match and tick() - V.lastThrow >= V.throwCooldown then
                local char = Player.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local target = nil
                local best = V.throwDistance
                if root then
                    for _, p in ipairs(V.matchEnemies) do
                        if V.isCombatEnemy(p) then
                            local pr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                            if pr then
                                local dist = (pr.Position - root.Position).Magnitude
                                if dist < best and V.hasClearLos(root.Position, pr.Position, char, p.Character) then
                                    best = dist
                                    target = p
                                end
                            end
                        end
                    end
                end
                if target then V.equipKnife(); V.throwKnife(target.Character) end
            end
            task.wait(0.1)
        end
    end)

    c(RunService.Heartbeat, function()
        if not V.triggerbot or not V.match or V.triggerbotFiring then return end
        local camera = Workspace.CurrentCamera
        local char = Player.Character
        if not camera or not char then return end
        local mouse = UserInputService:GetMouseLocation()
        local ray = camera:ViewportPointToRay(mouse.X, mouse.Y)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {char}
        local hit = Workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
        local model = hit and hit.Instance and hit.Instance:FindFirstAncestorOfClass("Model")
        local target = model and Players:GetPlayerFromCharacter(model)
        if target and V.triggerValid(target) then
            V.triggerbotFiring = true
            V.shootGun(target)
            task.delay(V.triggerbotCooldown, function() V.triggerbotFiring = false end)
        end
    end)

    spawn(function()
        while V.running do
            if V.hitboxExpander then V.updateHitboxes() else V.cleanupHitboxes() end
            task.wait(0.1)
        end
    end)

    spawn(function()
        while V.running do
            if V.charms then V.updateCharms() end
            if V.tracers then V.updateTracers() end
            task.wait(0.05)
        end
    end)

    spawn(function()
        while V.running do
            if V.autoKillGun and V.match then V.tryKillAllGun() end
            task.wait(0.1)
        end
    end)

    spawn(function()
        while V.running do
            if V.autoKillKnife and V.match then V.tryKillAllKnife() end
            task.wait(0.1)
        end
    end)

    spawn(function()
        while V.running do
            if V.autoShroud and V.match then
                for _, p in ipairs(V.matchEnemies) do
                    if V.isCombatEnemy(p) then V.blind(p) end
                end
                task.wait(1 / math.max(V.shroudRate, 0.1))
            else
                task.wait(0.5)
            end
        end
    end)

    spawn(function()
        while V.running do
            if V.autoWalk and not V.match then
                if not V.currentPad then V.currentPad = V.findPad() end
                if V.currentPad then V.walkTo(V.currentPad) end
                if V.currentPad and V.currentPad.Parent == nil then V.currentPad = nil end
            else
                V.currentPad = nil
            end
            task.wait(0.2)
        end
    end)

    local lastJump = 0
    c(RunService.Stepped, function()
        if not V.noclip then return end
        local char = Player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)

    spawn(function()
        while V.running do
            if V.speedEnabled then
                local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    if hum.WalkSpeed ~= V.currentSpeed then hum.WalkSpeed = V.currentSpeed end
                end
            end
            task.wait(0.1)
        end
    end)

    c(Player.CharacterAdded, function(character)
        task.wait(0.2)
        local hum = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 3)
        if hum then
            if V.speedEnabled then hum.WalkSpeed = V.currentSpeed else V.originalSpeed = hum.WalkSpeed end
        end
    end)

    spawn(function()
        while V.running do
            if V.autoSpin and not V.match then
                local dailies = ReplicatedStorage:FindFirstChild("Dailies")
                local module = dailies and dailies:FindFirstChild("SpinnerService")
                if module then
                    local ok, svc = pcall(require, module)
                    if ok and svc and svc.Spin then pcall(function() svc.Spin() end) end
                end
            end
            task.wait(0.1)
        end
    end)

    c(UserInputService.InputBegan, function(input, processed)
        if processed then return end
        if not V.fovManual or input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if tick() - V.fovLastShot < V.fovCooldown then return end
        local target = V.getMouseFovTarget()
        if target then
            local root = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            if root and myRoot and V.hasClearLos(myRoot.Position, root.Position, Player.Character, target.Character) then
                if V.shootGun(target) then V.fovLastShot = tick() end
            end
        end
    end)

    c(RunService.Heartbeat, function()
        local circle = V.fovCircle
        if not circle then return end
        circle.Visible = V.fovEnabled or V.fovAuto or V.fovManual
        circle.Size = UDim2.fromOffset(V.fovRadius * 2, V.fovRadius * 2)
        if circle.Visible then
            local mouse = UserInputService:GetMouseLocation()
            circle.Position = UDim2.fromOffset(mouse.X, mouse.Y)
        end
        if V.fovAuto then
            local target = V.getMouseFovTarget()
            local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            if target and myRoot and targetRoot and tick() - V.fovLastShot >= V.fovCooldown then
                if V.hasClearLos(myRoot.Position, targetRoot.Position, Player.Character, target.Character) then
                    if V.shootGun(target) then V.fovLastShot = tick() end
                end
            end
        end
    end)

    spawn(function()
        while V.running do
            if V.matchValue then V.matchValue.Text = V.match and "YES" or "NO" end
            if V.enemyCountValue then V.enemyCountValue.Text = tostring(#V.matchEnemies) end
            task.wait(0.25)
        end
    end)

    -- Cleanup for reruns / character teardown.
    g.NexusVexalCleanup = function()
        V.running = false
        pcall(V.stopManualGunController)
        for _, th in ipairs(V.threads) do pcall(task.cancel, th) end
        for _, conn in ipairs(V.connections) do pcall(function() conn:Disconnect() end) end
        V:clearTracers()
        V:cleanupHitboxes()
        if V.charmsFolder then
            for _, child in ipairs(V.charmsFolder:GetChildren()) do child:Destroy() end
        end
        if V.fovCircle then V.fovCircle:Destroy() end
        for tool, old in pairs(V.originalCooldowns) do
            if tool and tool.Parent then pcall(function() tool:SetAttribute("Cooldown", old) end) end
        end
        V.restoreSpeed()
    end

    setNotify("Full Vexal feature pack loaded")
end

xpcall(NexusVexalPack.build, function(err) warn("[Nexus Vexal] " .. tostring(err)); return err end)

--============================================================
-- START
--============================================================

switchTab("Main")
print("[Nexus Murder Duel] Custom GUI + full Vexal feature pack loaded.")
