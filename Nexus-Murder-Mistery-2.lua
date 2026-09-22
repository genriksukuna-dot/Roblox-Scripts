--[[
    NEXUS // MURDER MYSTERY 2
    Rebuilt from the observable functionality of the supplied moonveil.lua.
    Designed as a Roblox Studio LocalScript for your own experience.

    Implemented:
      - NEXUS MM2 UI
      - Aim Assist + FOV
      - Player ESP + role detection
      - Tracers / names / role labels
      - Murderer / Sheriff teleport
      - Coin / pickup auto-farm
      - WalkSpeed / JumpPower
      - Noclip / Infinite Jump
      - Combat tool activation helper
      - Clean menu presentation without a full-screen image layer
      - Drag / close / reopen HUD
      - Config-style controls

    The original moonveil file is heavily obfuscated, so this is a clean
    Studio implementation of the functions and API behavior that could be
    identified from it, not a literal byte-for-byte copy of the obfuscation.
]]

--==============================================================
-- SERVICES
--==============================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==============================================================
-- CONFIG
--==============================================================

local Config = {
    ToggleKey = Enum.KeyCode.RightShift,

    Aim = {
        Enabled = false,
        FOV = 180,
        Smoothness = 0.17,
        TeamCheck = false,
        TargetPart = "Head",
        VisibleCheck = false,
        AutoTeleportGun = false,
    },

    ESP = {
        Enabled = true,
        Boxes = true,
        Names = true,
        Roles = true,
        Tracers = false,
        Distance = true,
    },

    Farm = {
        Enabled = false,
        Speed = 45,
        PickupNames = {
            "Coin",
            "Coins",
            "CoinDrop",
            "Cash",
            "CashDrop",
            "Token",
            "Pickup",
            "Collectible",
        },
    },

    Movement = {
        WalkSpeed = 16,
        JumpPower = 50,
        Noclip = false,
        InfiniteJump = false,
        SafeSpeed = true,
        SafeSpeedCap = 24,
    },

    Combat = {
        Enabled = false,
        Range = 12,
        Cooldown = 0.25,
        AutoEquip = true,
        ToolKeywords = {
            "Knife",
            "Gun",
            "Weapon",
            "Revolver",
            "Blade",
            "Sword",
        },
    },

    UI = {
        Accent = Color3.fromRGB(173, 91, 255),
        Accent2 = Color3.fromRGB(76, 122, 255),
        Background = Color3.fromRGB(7, 7, 12),
        Panel = Color3.fromRGB(14, 12, 22),
        Panel2 = Color3.fromRGB(18, 18, 29),
        Text = Color3.fromRGB(246, 246, 255),
        Muted = Color3.fromRGB(145, 147, 168),
    },
}

local C = Config.UI

local ApplyMovement
local UpdateESP
local FOVCircle
local ControlRegistry = {}
local RuntimeConfigCache = nil
local CONFIG_FILE_NAME = "NEXUS_MM2_Config.json"

local function GetExternalFunction(name)
    local ok, value = pcall(function()
        if type(_G) == "table" and type(_G[name]) == "function" then
            return _G[name]
        end

        if type(getgenv) == "function" then
            local env = getgenv()
            if type(env) == "table" and type(env[name]) == "function" then
                return env[name]
            end
        end

        return nil
    end)

    return ok and value or nil
end

local function ConfigSnapshot()
    return {
        Aim = {
            Enabled = Config.Aim.Enabled,
            FOV = Config.Aim.FOV,
            Smoothness = Config.Aim.Smoothness,
            TeamCheck = Config.Aim.TeamCheck,
            VisibleCheck = Config.Aim.VisibleCheck,
            AutoTeleportGun = Config.Aim.AutoTeleportGun,
        },
        ESP = {
            Enabled = Config.ESP.Enabled,
            Boxes = Config.ESP.Boxes,
            Names = Config.ESP.Names,
            Roles = Config.ESP.Roles,
            Tracers = Config.ESP.Tracers,
            Distance = Config.ESP.Distance,
        },
        Farm = {
            Enabled = Config.Farm.Enabled,
            Speed = Config.Farm.Speed,
        },
        Movement = {
            WalkSpeed = Config.Movement.WalkSpeed,
            JumpPower = Config.Movement.JumpPower,
            Noclip = Config.Movement.Noclip,
            InfiniteJump = Config.Movement.InfiniteJump,
            SafeSpeed = Config.Movement.SafeSpeed,
            SafeSpeedCap = Config.Movement.SafeSpeedCap,
        },
        Combat = {
            AutoEquip = Config.Combat.AutoEquip,
            Range = Config.Combat.Range,
        },
    }
end

local SaveConfigToStorage = function()
    RuntimeConfigCache = ConfigSnapshot()

    local writer = GetExternalFunction("writefile")
    if not writer then
        return true, "session only (writefile unavailable)"
    end

    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(RuntimeConfigCache)
    end)
    if not ok then
        return false, "encode failed"
    end

    local wrote = pcall(function()
        writer(CONFIG_FILE_NAME, encoded)
    end)

    return wrote, wrote and ("saved: " .. CONFIG_FILE_NAME) or "write failed"
end

local LoadConfigFromStorage = function()
    local data = RuntimeConfigCache
    local reader = GetExternalFunction("readfile")

    if reader then
        local ok, raw = pcall(function()
            return reader(CONFIG_FILE_NAME)
        end)
        if ok and type(raw) == "string" and #raw > 0 then
            local decodedOk, decoded = pcall(function()
                return HttpService:JSONDecode(raw)
            end)
            if decodedOk and type(decoded) == "table" then
                data = decoded
                RuntimeConfigCache = decoded
            end
        end
    end

    if type(data) ~= "table" then
        return false, "no saved config"
    end

    if type(data.Aim) == "table" then
        for key in pairs(Config.Aim) do
            if data.Aim[key] ~= nil then Config.Aim[key] = data.Aim[key] end
        end
    end
    if type(data.ESP) == "table" then
        for key in pairs(Config.ESP) do
            if data.ESP[key] ~= nil then Config.ESP[key] = data.ESP[key] end
        end
    end
    if type(data.Farm) == "table" then
        for key in pairs(Config.Farm) do
            if data.Farm[key] ~= nil then Config.Farm[key] = data.Farm[key] end
        end
    end
    if type(data.Movement) == "table" then
        for key in pairs(Config.Movement) do
            if data.Movement[key] ~= nil then Config.Movement[key] = data.Movement[key] end
        end
    end
    if type(data.Combat) == "table" then
        for key in pairs(Config.Combat) do
            if data.Combat[key] ~= nil then Config.Combat[key] = data.Combat[key] end
        end
    end

    local bools = {
        ["Aim Assist"] = Config.Aim.Enabled,
        ["Auto Teleport Gun"] = Config.Aim.AutoTeleportGun,
        ["Team Check"] = Config.Aim.TeamCheck,
        ["Visible Check"] = Config.Aim.VisibleCheck,
        ["ESP"] = Config.ESP.Enabled,
        ["Boxes / Highlights"] = Config.ESP.Boxes,
        ["Names"] = Config.ESP.Names,
        ["Roles"] = Config.ESP.Roles,
        ["Distance"] = Config.ESP.Distance,
        ["Tracers"] = Config.ESP.Tracers,
        ["Auto Farm"] = Config.Farm.Enabled,
        ["Auto Equip"] = Config.Combat.AutoEquip,
        ["Noclip"] = Config.Movement.Noclip,
        ["Infinite Jump"] = Config.Movement.InfiniteJump,
        ["Safe Speed"] = Config.Movement.SafeSpeed,
    }

    for key, value in pairs(bools) do
        local setter = ControlRegistry[key]
        if setter then setter(value) end
    end

    local sliders = {
        FOV = Config.Aim.FOV,
        Smoothness = Config.Aim.Smoothness,
        ["Farm Speed"] = Config.Farm.Speed,
        WalkSpeed = Config.Movement.WalkSpeed,
        JumpPower = Config.Movement.JumpPower,
        ["Safe Speed Cap"] = Config.Movement.SafeSpeedCap,
        ["Attack Range"] = Config.Combat.Range,
    }

    for key, value in pairs(sliders) do
        local setter = ControlRegistry[key]
        if setter then setter(value) end
    end

    FOVCircle.Size = UDim2.fromOffset(Config.Aim.FOV * 2, Config.Aim.FOV * 2)
    FOVCircle.Visible = Config.Aim.Enabled
    ApplyMovement()
    UpdateESP()

    return true, "config loaded"
end

--==============================================================
-- HELPERS
--==============================================================

local function New(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    if parent then
        obj.Parent = parent
    end
    return obj
end

local function Corner(parent, radius)
    return New("UICorner", {
        CornerRadius = UDim.new(0, radius or 8),
    }, parent)
end

local function Stroke(parent, color, transparency, thickness)
    return New("UIStroke", {
        Color = color or C.Accent,
        Transparency = transparency or 0,
        Thickness = thickness or 1,
    }, parent)
end

local function Tween(obj, time, props, style, direction)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(
            time or 0.18,
            style or Enum.EasingStyle.Quad,
            direction or Enum.EasingDirection.Out
        ),
        props
    )
    t:Play()
    return t
end

local function Text(parent, value, size, color, font)
    return New("TextLabel", {
        BackgroundTransparency = 1,
        Text = value,
        TextColor3 = color or C.Text,
        TextSize = size or 12,
        Font = font or Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, parent)
end

local function SafeCall(fn, ...)
    if type(fn) ~= "function" then
        return
    end
    pcall(fn, ...)
end

local function GetCharacter(player)
    if not player then
        return nil
    end
    return player.Character
end

local function GetRoot(player)
    local char = GetCharacter(player)
    if not char then
        return nil
    end

    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Torso")
end

local function GetHumanoid(player)
    local char = GetCharacter(player)
    return char and char:FindFirstChildOfClass("Humanoid") or nil
end

local function Alive(player)
    local humanoid = GetHumanoid(player)
    return humanoid and humanoid.Health > 0 and GetRoot(player) ~= nil
end

local function IsEnemy(player)
    if not player or player == LocalPlayer then
        return false
    end

    if not Config.Aim.TeamCheck then
        return true
    end

    if LocalPlayer.Team == nil or player.Team == nil then
        return true
    end

    return player.Team ~= LocalPlayer.Team
end

local function HasKeyword(name, keywords)
    name = tostring(name):lower()

    for _, keyword in ipairs(keywords) do
        if name:find(tostring(keyword):lower(), 1, true) then
            return true
        end
    end

    return false
end

local function GetLocalRoot()
    return GetRoot(LocalPlayer)
end

local function GetLocalHumanoid()
    return GetHumanoid(LocalPlayer)
end

--==============================================================
-- ROLE DETECTION
--==============================================================

local function ReadRoleValue(container)
    if not container then
        return nil
    end

    for _, child in ipairs(container:GetDescendants()) do
        if child:IsA("StringValue") then
            local n = child.Name:lower()
            local v = tostring(child.Value):lower()

            if n == "role" or n == "rolename" or n == "playerrole" then
                return tostring(child.Value)
            end

            if v == "murderer" or v == "sheriff" or v == "innocent" then
                return tostring(child.Value)
            end
        end
    end

    return nil
end

local function NormalizeRole(value)
    local low = tostring(value or ""):lower()

    if low:find("murder", 1, true) then
        return "Murderer"
    elseif low:find("sheriff", 1, true) then
        return "Sheriff"
    elseif low:find("innocent", 1, true) then
        return "Innocent"
    elseif low:find("hero", 1, true) then
        return "Sheriff"
    end

    return nil
end

local function ReadToolRole(container)
    if not container then
        return nil
    end

    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("Tool") then
            local n = child.Name:lower()

            if n:find("knife", 1, true)
                or n:find("blade", 1, true)
                or n:find("murder", 1, true)
                or n:find("saber", 1, true) then
                return "Murderer"
            end

            if n:find("gun", 1, true)
                or n:find("revolver", 1, true)
                or n:find("sheriff", 1, true)
                or n:find("pistol", 1, true)
                or n:find("classi", 1, true) then
                return "Sheriff"
            end
        end
    end

    return nil
end

local ServerRoleCache = {}
local ServerRoleRefreshBusy = false
local RoleCache = {}
local LastKnownRole = {}

local function RefreshServerRoleData()
    if ServerRoleRefreshBusy then
        return
    end

    local remote = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
    if not remote or not remote:IsA("RemoteFunction") then
        return
    end

    ServerRoleRefreshBusy = true

    task.spawn(function()
        local ok, data = pcall(function()
            return remote:InvokeServer()
        end)

        if ok and type(data) == "table" then
            local fresh = {}

            for playerKey, playerData in pairs(data) do
                if type(playerData) == "table" then
                    local role = NormalizeRole(playerData.Role or playerData.role or playerData.RoleName or playerData.roleName)
                    if role then
                        local keys = {}
                        if typeof(playerKey) == "Instance" and playerKey:IsA("Player") then
                            table.insert(keys, playerKey.Name)
                            table.insert(keys, tostring(playerKey.UserId))
                        else
                            table.insert(keys, tostring(playerKey))
                        end

                        local explicitName = playerData.Name or playerData.name or playerData.Username or playerData.username
                        local explicitUserId = playerData.UserId or playerData.userId or playerData.UserID or playerData.userid
                        if explicitName then table.insert(keys, tostring(explicitName)) end
                        if explicitUserId then table.insert(keys, tostring(explicitUserId)) end

                        for _, key in ipairs(keys) do
                            fresh[tostring(key)] = role
                        end
                    end
                end
            end

            ServerRoleCache = fresh

            for _, player in ipairs(Players:GetPlayers()) do
                RoleCache[player] = nil
            end

            if Config.ESP.Enabled then
                task.defer(UpdateESP)
            end
        end

        ServerRoleRefreshBusy = false
    end)
end

local function GetRole(player)
    if not player then
        return "Unknown"
    end

    local char = player.Character
    local backpack = player:FindFirstChildOfClass("Backpack")

    -- Current round server-role data is the strongest live round signal.
    -- Weapons are used as an immediate fallback because Sheriff/Murderer can
    -- receive their tools a moment before the profile data updates.
    local serverRole = ServerRoleCache[player.Name]
        or ServerRoleCache[tostring(player.UserId)]
        or ServerRoleCache[player.DisplayName]
    local toolRole = ReadToolRole(char) or ReadToolRole(backpack)

    if player == LocalPlayer and serverRole then
        return serverRole
    end

    if toolRole then
        return toolRole
    end

    if serverRole then
        return serverRole
    end

    -- Prefer explicit role attributes next.
    for key, value in pairs(player:GetAttributes()) do
        if tostring(key):lower():find("role", 1, true) then
            local normalized = NormalizeRole(value)
            if normalized then
                return normalized
            end
        end
    end

    -- Then read role values from the character/player containers.
    local role = ReadRoleValue(char)
    if role then
        local normalized = NormalizeRole(role)
        if normalized then
            return normalized
        end
    end

    role = ReadRoleValue(player)
    if role then
        local normalized = NormalizeRole(role)
        if normalized then
            return normalized
        end
    end

    role = ReadRoleValue(player:FindFirstChild("leaderstats"))
    if role then
        local normalized = NormalizeRole(role)
        if normalized then
            return normalized
        end
    end

    return "Unknown"
end

local function GetRoleCached(player)
    if not player then
        return "Unknown"
    end

    local cached = RoleCache[player]
    if cached then
        return cached
    end

    local role = GetRole(player)
    RoleCache[player] = role
    return role
end

local function RefreshRoleCache()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            -- Keep local role fresh because picking up the Sheriff gun can
            -- change the effective aim role immediately.
            RoleCache[player] = GetRole(player)
        else
            RoleCache[player] = GetRole(player)
        end
    end
end

local function FindMurdererForFarm()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and Alive(player) then
            local role = GetRole(player):lower()

            if role:find("murder", 1, true) then
                return player
            end
        end
    end

    return nil
end

local function FindSheriff()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and Alive(player) then
            local role = GetRole(player):lower()

            if role:find("sheriff", 1, true) then
                return player
            end
        end
    end

    return nil
end

--==============================================================
-- TELEPORT
--==============================================================

local function TeleportToPlayer(player)
    local localRoot = GetLocalRoot()
    local targetRoot = GetRoot(player)

    if not localRoot or not targetRoot then
        return false
    end

    localRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
    return true
end

local function TeleportToMurderer()
    return TeleportToPlayer(FindMurdererForFarm())
end

local function TeleportToSheriff()
    return TeleportToPlayer(FindSheriff())
end

local function TeleportToRandomPlayer()
    local candidates = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and Alive(player) then
            table.insert(candidates, player)
        end
    end

    if #candidates == 0 then
        return false
    end

    return TeleportToPlayer(candidates[math.random(1, #candidates)])
end

--==============================================================
-- AIM
--==============================================================

local Camera = Workspace.CurrentCamera

FOVCircle = New("Frame", {
    Name = "AimFOV",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = UDim2.fromOffset(Config.Aim.FOV * 2, Config.Aim.FOV * 2),
    BackgroundTransparency = 1,
    Visible = false,
}, nil)

Corner(FOVCircle, 999)
Stroke(FOVCircle, C.Accent, 0.25, 1.5)

local function RefreshCamera()
    Camera = Workspace.CurrentCamera
end

local function HasRevolver(player)
    if not player then
        return false
    end

    local char = player.Character
    if char then
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("revolver", 1, true)
                or tool.Name:lower():find("gun", 1, true)
                or tool.Name:lower():find("sheriff", 1, true)) then
                return true
            end
        end
    end

    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():find("revolver", 1, true)
                or tool.Name:lower():find("gun", 1, true)
                or tool.Name:lower():find("sheriff", 1, true)) then
                return true
            end
        end
    end

    return false
end

local function AimRole()
    local role = GetRoleCached(LocalPlayer):lower()

    if role:find("murder", 1, true) then
        return "Murderer"
    end

    if role:find("sheriff", 1, true) or HasRevolver(LocalPlayer) then
        return "Sheriff"
    end

    return "Innocent"
end

local LockedAimTarget = nil
local AimScanClock = 0
local AimBoundName = "NEXUS_AimHardLock"

local function CanAimAt(player)
    if not player or player == LocalPlayer or not Alive(player) then
        return false
    end

    local localRole = AimRole()

    -- Innocent without the Sheriff gun: aim is completely disabled.
    if localRole == "Innocent" then
        return false
    end

    local targetRole = GetRoleCached(player):lower()

    if localRole == "Sheriff" then
        return targetRole:find("murder", 1, true) ~= nil
    end

    -- Murderer can aim at every living player.
    return true
end

local function GetAimPart(player)
    local character = player and player.Character
    if not character then
        return nil
    end

    return character:FindFirstChild(Config.Aim.TargetPart)
        or character:FindFirstChild("Head")
        or character:FindFirstChild("HumanoidRootPart")
end

local function HasLineOfSight(part, targetCharacter)
    -- Aim must NEVER track through solid geometry. This is intentionally
    -- unconditional for the aim system so role (including Murderer) or UI
    -- toggles cannot accidentally disable the wall check.
    RefreshCamera()

    if not Camera or not part or not targetCharacter then
        return false
    end

    local origin = Camera.CFrame.Position
    local direction = part.Position - origin

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {
        LocalPlayer.Character,
        Camera,
    }

    local result = Workspace:Raycast(origin, direction, params)

    if not result then
        return true
    end

    return result.Instance:IsDescendantOf(targetCharacter)
end

local function GetAimTarget(forceScan)
    RefreshCamera()

    if not Camera then
        return nil
    end

    -- Once acquired, stay on this player until they die, disappear, or stop
    -- matching the current role rules. We deliberately do not re-run the FOV
    -- check on an already locked target, so the lock cannot "fall off" as the
    -- camera moves.
    if not forceScan and CanAimAt(LockedAimTarget) then
        local lockedPart = GetAimPart(LockedAimTarget)
        if lockedPart and HasLineOfSight(lockedPart, LockedAimTarget.Character) then
            return LockedAimTarget
        end
    end

    if CanAimAt(LockedAimTarget) then
        local lockedPart = GetAimPart(LockedAimTarget)
        if lockedPart and HasLineOfSight(lockedPart, LockedAimTarget.Character) then
            return LockedAimTarget
        end
    end

    LockedAimTarget = nil

    if AimRole() == "Innocent" then
        return nil
    end

    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

    local bestPlayer = nil
    local bestDistance = Config.Aim.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if CanAimAt(player) then
            local part = GetAimPart(player)

            if part then
                local screenPos, visible = Camera:WorldToViewportPoint(part.Position)

                if visible and screenPos.Z > 0 then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude

                    if distance < bestDistance and HasLineOfSight(part, player.Character) then
                        bestDistance = distance
                        bestPlayer = player
                    end
                end
            end
        end
    end

    LockedAimTarget = bestPlayer
    return LockedAimTarget
end

local function UpdateAim(_dt)
    if not Config.Aim.Enabled then
        LockedAimTarget = nil
        return
    end

    local localRole = AimRole()
    if localRole == "Innocent" then
        LockedAimTarget = nil
        return
    end

    AimScanClock += 0.016

    -- Only reacquire when the lock is genuinely invalid. A valid target is
    -- never replaced merely because another player moves closer to the FOV.
    local target = GetAimTarget(AimScanClock >= 0.10)
    if AimScanClock >= 0.10 then
        AimScanClock = 0
    end

    local part = GetAimPart(target)
    if not Camera or not part then
        return
    end

    -- Never aim through solid geometry. Keep the target locked so it can be
    -- reacquired immediately when it becomes visible again, but do not move
    -- the camera while the line of sight is blocked.
    if not HasLineOfSight(part, target.Character) then
        return
    end

    -- Hard camera lock: exact CFrame every rendered frame. This keeps the
    -- camera attached to the visible target without the old Lerp gap.
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, part.Position)
end

pcall(function()
    RunService:UnbindFromRenderStep(AimBoundName)
end)

RunService:BindToRenderStep(AimBoundName, Enum.RenderPriority.Camera.Value + 1, function()
    UpdateAim(0.016)
end)

--==============================================================
-- ESP
--==============================================================

local EspCache = {}

local function ClearESP(player)
    local data = EspCache[player]

    if not data then
        return
    end

    for _, object in pairs(data) do
        if typeof(object) == "Instance" and object.Parent then
            object:Destroy()
        end
    end

    EspCache[player] = nil
end

local function RoleColor(role)
    role = tostring(role):lower()

    if role:find("murder", 1, true) then
        return Color3.fromRGB(255, 65, 95)
    elseif role:find("sheriff", 1, true) then
        return Color3.fromRGB(75, 155, 255)
    elseif role:find("innocent", 1, true) then
        return Color3.fromRGB(90, 255, 155)
    end

    return C.Accent
end

local function CreateESP(player)
    if player == LocalPlayer then
        return
    end

    ClearESP(player)

    local char = player.Character
    if not char then
        return
    end

    local root = GetRoot(player)
    if not root then
        return
    end

    local color = RoleColor(GetRole(player))

    local highlight
    if Config.ESP.Boxes then
        highlight = New("Highlight", {
            Name = "NEXUS_ESP",
            Adornee = char,
            DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
            FillColor = color,
            OutlineColor = Color3.new(1, 1, 1),
            FillTransparency = 0.82,
            OutlineTransparency = 0.15,
        }, char)
    end

    local billboard = New("BillboardGui", {
        Name = "NEXUS_INFO",
        Adornee = root,
        Size = UDim2.fromOffset(180, 55),
        StudsOffset = Vector3.new(0, 3.1, 0),
        AlwaysOnTop = true,
        Enabled = true,
    }, PlayerGui)

    local label = New("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = color,
        TextStrokeTransparency = 0.4,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, billboard)

    local line = New("Frame", {
        Name = "NEXUS_TRACER",
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Visible = Config.ESP.Tracers,
    }, billboard)

    EspCache[player] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = label,
        Tracer = line,
    }
end

UpdateESP = function()
    if not Config.ESP.Enabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                ClearESP(player)
            end
        end
        return
    end

    local localRoot = GetLocalRoot()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local data = EspCache[player]

            if not data or not data.Billboard.Parent then
                CreateESP(player)
                data = EspCache[player]
            end

            if data then
                local role = GetRole(player)
                local color = RoleColor(role)
                local distance = 0

                local root = GetRoot(player)
                if localRoot and root then
                    distance = math.floor((root.Position - localRoot.Position).Magnitude)
                end

                local name = player.DisplayName
                if Config.ESP.Names then
                    name = name .. "\n@" .. player.Name
                end

                if Config.ESP.Roles then
                    name = name .. "\n[" .. tostring(role) .. "]"
                end

                if Config.ESP.Distance then
                    name = name .. "  " .. tostring(distance) .. "m"
                end

                data.Label.Text = name
                data.Label.TextColor3 = color

                if data.Highlight then
                    data.Highlight.FillColor = color
                    data.Highlight.Enabled = Config.ESP.Boxes
                end

                if data.Tracer then
                    data.Tracer.Visible = Config.ESP.Tracers
                end
            end
        end
    end
end

--==============================================================
-- AUTO FARM
--==============================================================

local function IsPickup(instance)
    if not instance then
        return false
    end

    if not instance:IsA("BasePart")
        and not instance:IsA("MeshPart")
        and not instance:IsA("UnionOperation") then
        return false
    end

    local n = instance.Name:lower()

    for _, wanted in ipairs(Config.Farm.PickupNames) do
        if n == wanted:lower() or n:find(wanted:lower(), 1, true) then
            return true
        end
    end

    return false
end

local PickupCache = {}

local function AddPickup(instance)
    if IsPickup(instance) then
        PickupCache[instance] = true
    end
end

local function RemovePickup(instance)
    PickupCache[instance] = nil
end

for _, instance in ipairs(Workspace:GetDescendants()) do
    AddPickup(instance)
end

Workspace.DescendantAdded:Connect(AddPickup)
Workspace.DescendantRemoving:Connect(RemovePickup)

local function FindNearestPickup()
    local localRoot = GetLocalRoot()
    if not localRoot then
        return nil
    end

    local nearest = nil
    local bestDistance = math.huge

    for object in pairs(PickupCache) do
        if object
            and object.Parent
            and object:IsDescendantOf(Workspace)
            and object:IsA("BasePart") then

            local distance = (object.Position - localRoot.Position).Magnitude

            if distance < bestDistance then
                bestDistance = distance
                nearest = object
            end
        else
            PickupCache[object] = nil
        end
    end

    return nearest
end

local function CollectPickup(pickup)
    local localRoot = GetLocalRoot()
    if not localRoot or not pickup then
        return
    end

    localRoot.CFrame = pickup.CFrame + Vector3.new(0, 2.5, 0)

    -- This mirrors the touch-based pickup style observable in the
    -- supplied script. It only affects your own experience.
    if typeof(firetouchinterest) == "function" then
        local character = LocalPlayer.Character
        local torso = character and (
            character:FindFirstChild("HumanoidRootPart")
            or character:FindFirstChild("Torso")
        )

        if torso then
            pcall(function()
                firetouchinterest(torso, pickup, 0)
                task.wait()
                firetouchinterest(torso, pickup, 1)
            end)
        end
    end
end

local farmBusy = false

local function AutoFarmTick()
    if not Config.Farm.Enabled or farmBusy then
        return
    end

    farmBusy = true

    local pickup = FindNearestPickup()
    if pickup then
        -- Fixed fast teleport interval; Farm Speed no longer controls pickup travel.
        CollectPickup(pickup)
    end

    task.wait(0.035)
    farmBusy = false
end

--==============================================================
-- MOVEMENT
--==============================================================

local noclipConnection

ApplyMovement = function()
    local humanoid = GetLocalHumanoid()

    if humanoid then
        local requestedSpeed = tonumber(Config.Movement.WalkSpeed) or 16
        local effectiveSpeed = requestedSpeed
        if Config.Movement.SafeSpeed then
            effectiveSpeed = math.min(effectiveSpeed, tonumber(Config.Movement.SafeSpeedCap) or 24)
        end

        humanoid.WalkSpeed = math.max(0, effectiveSpeed)

        pcall(function()
            humanoid.JumpPower = Config.Movement.JumpPower
        end)

        pcall(function()
            humanoid.UseJumpPower = true
        end)
    end
end

local function StartNoclip()
    if noclipConnection then
        return
    end

    noclipConnection = RunService.Stepped:Connect(function()
        if not Config.Movement.Noclip then
            return
        end

        local char = LocalPlayer.Character
        if not char then
            return
        end

        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

StartNoclip()

-- Keep the configured WalkSpeed after tools are equipped/unequipped and when the
-- character is respawned. The guard only reapplies the existing configured
-- value; it does not attempt to bypass server-side validation.
local speedGuardConnections = {}
local speedGuardBusy = false

local function ClearSpeedGuardConnections()
    for _, connection in ipairs(speedGuardConnections) do
        pcall(function() connection:Disconnect() end)
    end
    table.clear(speedGuardConnections)
end

local function GuardedApplyMovement()
    if speedGuardBusy then
        return
    end
    speedGuardBusy = true
    pcall(ApplyMovement)
    speedGuardBusy = false
end

local function SetupSpeedGuard()
    ClearSpeedGuardConnections()

    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        table.insert(speedGuardConnections, humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if speedGuardBusy then return end
            task.defer(GuardedApplyMovement)
        end))
    end

    if character then
        table.insert(speedGuardConnections, character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.delay(0.05, GuardedApplyMovement)
                task.delay(0.18, GuardedApplyMovement)
            end
        end))

        table.insert(speedGuardConnections, character.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then
                task.delay(0.05, GuardedApplyMovement)
            end
        end))
    end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        table.insert(speedGuardConnections, backpack.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.delay(0.05, GuardedApplyMovement)
            end
        end))
    end
end

SetupSpeedGuard()

UserInputService.JumpRequest:Connect(function()
    if not Config.Movement.InfiniteJump then
        return
    end

    local humanoid = GetLocalHumanoid()
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

--==============================================================
-- COMBAT TOOL HELPER
--==============================================================

local function FindCombatTool()
    local char = LocalPlayer.Character
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") and HasKeyword(child.Name, Config.Combat.ToolKeywords) then
                return child
            end
        end
    end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") and HasKeyword(child.Name, Config.Combat.ToolKeywords) then
                return child
            end
        end
    end

    return nil
end

local function EquipCombatTool()
    local humanoid = GetLocalHumanoid()
    if not humanoid then
        return nil
    end

    local tool = FindCombatTool()
    if not tool then
        return nil
    end

    if tool.Parent ~= LocalPlayer.Character then
        pcall(function()
            humanoid:EquipTool(tool)
        end)

        task.wait()
    end

    return tool
end

local function HasDirectLineOfSight(part, targetCharacter)
    RefreshCamera()
    if not Camera or not part or not targetCharacter then
        return false
    end

    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { LocalPlayer.Character, Camera }

    local result = Workspace:Raycast(origin, direction, params)
    return (not result) or result.Instance:IsDescendantOf(targetCharacter)
end

local function IsMurdererVisibleInFOV(player)
    if not player or not Alive(player) then
        return false
    end

    local part = GetAimPart(player)
    if not part then
        return false
    end

    RefreshCamera()
    if not Camera then
        return false
    end

    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen or screenPos.Z <= 0 then
        return false
    end

    local viewport = Camera.ViewportSize
    local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
    local screenDistance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
    if screenDistance > Config.Aim.FOV then
        return false
    end

    return HasDirectLineOfSight(part, player.Character)
end

local function FindRevolverTool()
    local char = LocalPlayer.Character
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then
                local n = child.Name:lower()
                if n:find("revolver", 1, true)
                    or n:find("gun", 1, true)
                    or n:find("sheriff", 1, true)
                    or n:find("pistol", 1, true)
                    or n:find("classic", 1, true) then
                    return child
                end
            end
        end
    end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") then
                local n = child.Name:lower()
                if n:find("revolver", 1, true)
                    or n:find("gun", 1, true)
                    or n:find("sheriff", 1, true)
                    or n:find("pistol", 1, true)
                    or n:find("classic", 1, true) then
                    return child
                end
            end
        end
    end

    return nil
end

local function EquipRevolver()
    local humanoid = GetLocalHumanoid()
    if not humanoid then return nil end
    local tool = FindRevolverTool()
    if not tool then return nil end

    if tool.Parent ~= LocalPlayer.Character then
        pcall(function() humanoid:EquipTool(tool) end)
        task.wait()
    end
    return tool
end

--==============================================================
-- OPTIONAL REMOTE DISCOVERY FOR YOUR OWN GAME
--==============================================================

local function FindLikelyCombatRemote()
    local names = {
        "KnifeHit",
        "Attack",
        "Damage",
        "Hit",
        "Kill",
        "Melee",
        "Combat",
    }

    for _, object in ipairs(ReplicatedStorage:GetDescendants()) do
        if object:IsA("RemoteEvent") then
            for _, name in ipairs(names) do
                if object.Name:lower() == name:lower()
                    or object.Name:lower():find(name:lower(), 1, true) then
                    return object
                end
            end
        end
    end

    return nil
end

--==============================================================
-- UI
--==============================================================

local old = PlayerGui:FindFirstChild("NEXUS_MM2")
if old then
    old:Destroy()
end

local Gui = New("ScreenGui", {
    Name = "NEXUS_MM2",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 20,
}, PlayerGui)

-- Add FOV to GUI after Gui exists.
FOVCircle.Parent = Gui
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.Size = UDim2.fromOffset(Config.Aim.FOV * 2, Config.Aim.FOV * 2)
FOVCircle.ZIndex = 20

local Backdrop = New("Frame", {
    Name = "Backdrop",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 1,
}, Gui)

local Main = New("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.52),
    Size = UDim2.fromOffset(820, 505),
    BackgroundColor3 = C.Panel,
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 1,
}, Gui)

-- Render the whole menu about 1.6x smaller while preserving proportions.
local MainScale = New("UIScale", {
    Scale = 0.625,
}, Main)

Corner(Main, 18)
Stroke(Main, Color3.fromRGB(115, 88, 170), 0.38, 1)

-- Clean menu backing. The anime/full-screen image layer is intentionally removed.
local MenuBackdrop = New("Frame", {
    Name = "MenuBackdrop",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(8, 8, 14),
    BackgroundTransparency = 0.05,
    BorderSizePixel = 0,
    ZIndex = 0,
}, Main)
Corner(MenuBackdrop, 18)

local MenuShade = New("Frame", {
    Name = "MenuShade",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Color3.fromRGB(16, 12, 26),
    BackgroundTransparency = 0.18,
    BorderSizePixel = 0,
    ZIndex = 0,
}, Main)

local MainGradient = New("UIGradient", {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(27, 24, 42)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 7, 13)),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.10),
        NumberSequenceKeypoint.new(1, 0.02),
    }),
}, MenuBackdrop)

--==============================================================
-- FLOATING TOAST NOTIFICATIONS
--==============================================================

local ToastHolder = New("Frame", {
    Name = "ToastHolder",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -18, 0, 18),
    Size = UDim2.fromOffset(340, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 200,
}, Gui)

New("UIListLayout", {
    FillDirection = Enum.FillDirection.Vertical,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, ToastHolder)

local ToastSerial = 0

local function ShowToast(title, message, duration)
    ToastSerial += 1
    local order = ToastSerial
    local lifetime = math.clamp(tonumber(duration) or 2.4, 2, 3.2)

    local card = New("Frame", {
        LayoutOrder = order,
        Size = UDim2.fromOffset(320, 58),
        BackgroundColor3 = Color3.fromRGB(13, 13, 22),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(28, 0),
        ZIndex = 201,
    }, ToastHolder)
    Corner(card, 13)
    Stroke(card, Color3.fromRGB(91, 77, 128), 0.5, 1)

    local titleLabel = Text(card, tostring(title or "NEXUS"), 10, C.Text, Enum.Font.GothamBold)
    titleLabel.Position = UDim2.fromOffset(14, 8)
    titleLabel.Size = UDim2.new(1, -24, 0, 16)
    titleLabel.TextTransparency = 1
    titleLabel.ZIndex = 202

    local messageLabel = Text(card, tostring(message or ""), 8, C.Muted, Enum.Font.Gotham)
    messageLabel.Position = UDim2.fromOffset(14, 26)
    messageLabel.Size = UDim2.new(1, -24, 0, 24)
    messageLabel.TextWrapped = true
    messageLabel.TextYAlignment = Enum.TextYAlignment.Top
    messageLabel.TextTransparency = 1
    messageLabel.ZIndex = 202

    local scale = New("UIScale", { Scale = 0.94 }, card)
    Tween(card, 0.20, {
        Position = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 0.06,
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    Tween(scale, 0.20, { Scale = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    Tween(titleLabel, 0.18, { TextTransparency = 0 }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    Tween(messageLabel, 0.18, { TextTransparency = 0 }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    task.delay(lifetime, function()
        if not card or not card.Parent then return end
        Tween(scale, 0.18, { Scale = 0.96 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        Tween(card, 0.18, {
            Position = UDim2.fromOffset(28, 0),
            BackgroundTransparency = 1,
        }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        Tween(titleLabel, 0.15, { TextTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        Tween(messageLabel, 0.15, { TextTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.wait(0.20)
        if card and card.Parent then
            card:Destroy()
        end
    end)
end

--==============================================================
-- TOP BAR
--==============================================================

local TopBar = New("Frame", {
    Size = UDim2.new(1, 0, 0, 83),
    BackgroundTransparency = 1,
}, Main)

local Brand = New("Frame", {
    Position = UDim2.fromOffset(22, 10),
    Size = UDim2.fromOffset(320, 60),
    BackgroundTransparency = 1,
}, TopBar)

local Logo = Text(Brand, "NEXUS", 33, C.Text, Enum.Font.GothamBlack)
Logo.Size = UDim2.new(1, 0, 0, 38)

New("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(241, 230, 255)),
        ColorSequenceKeypoint.new(0.47, C.Accent),
        ColorSequenceKeypoint.new(1, C.Accent2),
    }),
}, Logo)

local GameTitle = Text(Brand, "MURDER MYSTERY 2", 10, C.Muted, Enum.Font.GothamBold)
GameTitle.Position = UDim2.fromOffset(2, 38)
GameTitle.Size = UDim2.new(1, 0, 0, 18)

local Status = New("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -56, 0.5, 0),
    Size = UDim2.fromOffset(153, 34),
    BackgroundColor3 = Color3.fromRGB(15, 18, 28),
    BorderSizePixel = 0,
    Visible = false,
}, TopBar)
Corner(Status, 10)
Stroke(Status, Color3.fromRGB(70, 80, 110), 0.48, 1)

local Dot = New("Frame", {
    Position = UDim2.fromOffset(13, 12),
    Size = UDim2.fromOffset(9, 9),
    BackgroundColor3 = Color3.fromRGB(91, 255, 157),
    BorderSizePixel = 0,
}, Status)
Corner(Dot, 20)

local StatusText = Text(Status, "SYSTEM ONLINE", 10, C.Text, Enum.Font.GothamBold)
StatusText.Position = UDim2.fromOffset(31, 0)
StatusText.Size = UDim2.new(1, -36, 1, 0)

local CloseButton = New("TextButton", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -17, 0.5, 0),
    Size = UDim2.fromOffset(31, 31),
    BackgroundColor3 = Color3.fromRGB(38, 22, 34),
    AutoButtonColor = false,
    Text = "×",
    TextColor3 = Color3.fromRGB(255, 170, 190),
    TextSize = 21,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
}, TopBar)
Corner(CloseButton, 9)

--==============================================================
-- CONTENT / SIDEBAR
--==============================================================

local Sidebar = New("Frame", {
    Position = UDim2.fromOffset(15, 92),
    Size = UDim2.new(0, 183, 1, -107),
    BackgroundColor3 = Color3.fromRGB(10, 10, 17),
    BorderSizePixel = 0,
}, Main)
Corner(Sidebar, 14)
Stroke(Sidebar, Color3.fromRGB(71, 67, 96), 0.62, 1)

local SidebarTitle = Text(Sidebar, "NEXUS CONTROL", 10, C.Muted, Enum.Font.GothamBold)
SidebarTitle.Position = UDim2.fromOffset(12, 12)
SidebarTitle.Size = UDim2.new(1, -24, 0, 18)

local TabList = New("Frame", {
    Position = UDim2.fromOffset(9, 36),
    Size = UDim2.new(1, -18, 1, -45),
    BackgroundTransparency = 1,
}, Sidebar)

New("UIListLayout", {
    Padding = UDim.new(0, 7),
}, TabList)

local Content = New("Frame", {
    Position = UDim2.fromOffset(210, 92),
    Size = UDim2.new(1, -225, 1, -107),
    BackgroundTransparency = 1,
}, Main)

local Pages = {}
local Tabs = {}

local function CreatePage(name)
    local page = New("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = C.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        Visible = false,
    }, Content)

    New("UIListLayout", {
        Padding = UDim.new(0, 9),
    }, page)

    Pages[name] = page
    return page
end

local function SelectTab(name)
    for pageName, page in pairs(Pages) do
        page.Visible = pageName == name
    end

    for pageName, button in pairs(Tabs) do
        local active = pageName == name

        Tween(button, 0.16, {
            BackgroundColor3 = active
                and Color3.fromRGB(36, 28, 56)
                or Color3.fromRGB(15, 15, 23),
        })

        local label = button:FindFirstChild("Label")
        if label then
            Tween(label, 0.16, {
                TextColor3 = active and C.Text or C.Muted,
            })
        end

        local icon = button:FindFirstChild("Icon")
        if icon then
            Tween(icon, 0.16, {
                TextColor3 = active and C.Accent or C.Muted,
            })
        end
    end
end

local function AddTab(name, icon, pageName)
    local button = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Color3.fromRGB(15, 15, 23),
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0,
    }, TabList)

    Corner(button, 10)

    local iconLabel = Text(button, icon, 16, C.Muted, Enum.Font.GothamBold)
    iconLabel.Name = "Icon"
    iconLabel.Position = UDim2.fromOffset(9, 0)
    iconLabel.Size = UDim2.fromOffset(27, 42)
    iconLabel.TextXAlignment = Enum.TextXAlignment.Center

    local label = Text(button, name, 11, C.Muted, Enum.Font.GothamSemibold)
    label.Name = "Label"
    label.Position = UDim2.fromOffset(43, 0)
    label.Size = UDim2.new(1, -50, 1, 0)

    button.MouseButton1Click:Connect(function()
        SelectTab(pageName)
    end)

    button.MouseEnter:Connect(function()
        if not Pages[pageName].Visible then
            Tween(button, 0.12, {
                BackgroundColor3 = Color3.fromRGB(23, 23, 33),
            })
        end
    end)

    button.MouseLeave:Connect(function()
        if not Pages[pageName].Visible then
            Tween(button, 0.12, {
                BackgroundColor3 = Color3.fromRGB(15, 15, 23),
            })
        end
    end)

    Tabs[pageName] = button
end

--==============================================================
-- UI COMPONENTS
--==============================================================

local function Section(parent, title, subtitle)
    local frame = New("Frame", {
        Size = UDim2.new(1, -4, 0, 64),
        BackgroundColor3 = C.Panel2,
        BorderSizePixel = 0,
    }, parent)

    Corner(frame, 12)
    Stroke(frame, Color3.fromRGB(72, 68, 98), 0.72, 1)

    local a = Text(frame, title, 12, C.Text, Enum.Font.GothamBold)
    a.Position = UDim2.fromOffset(14, 7)
    a.Size = UDim2.new(1, -28, 0, 22)

    local b = Text(frame, subtitle or "", 9, C.Muted, Enum.Font.Gotham)
    b.Position = UDim2.fromOffset(14, 30)
    b.Size = UDim2.new(1, -28, 0, 20)

    return frame
end

local function Toggle(parent, title, description, state, callback)
    local row = New("Frame", {
        Size = UDim2.new(1, -4, 0, 61),
        BackgroundColor3 = Color3.fromRGB(14, 14, 22),
        BorderSizePixel = 0,
    }, parent)

    Corner(row, 11)

    local titleLabel = Text(row, title, 11, C.Text, Enum.Font.GothamSemibold)
    titleLabel.Position = UDim2.fromOffset(13, 7)
    titleLabel.Size = UDim2.new(1, -86, 0, 20)

    local descLabel = Text(row, description or "", 8, C.Muted, Enum.Font.Gotham)
    descLabel.Position = UDim2.fromOffset(13, 29)
    descLabel.Size = UDim2.new(1, -96, 0, 20)

    local switch = New("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -13, 0.5, 0),
        Size = UDim2.fromOffset(43, 23),
        BackgroundColor3 = Color3.fromRGB(31, 31, 41),
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0,
    }, row)
    Corner(switch, 50)

    local knob = New("Frame", {
        Position = UDim2.fromOffset(3, 3),
        Size = UDim2.fromOffset(17, 17),
        BackgroundColor3 = C.Muted,
        BorderSizePixel = 0,
    }, switch)
    Corner(knob, 50)

    local enabled = state == true

    local function Draw()
        Tween(switch, 0.15, {
            BackgroundColor3 = enabled
                and Color3.fromRGB(54, 40, 78)
                or Color3.fromRGB(31, 31, 41),
        })

        Tween(knob, 0.15, {
            Position = enabled
                and UDim2.new(1, -20, 0, 3)
                or UDim2.fromOffset(3, 3),
            BackgroundColor3 = enabled and C.Accent or C.Muted,
        })
    end

    switch.MouseButton1Click:Connect(function()
        enabled = not enabled
        Draw()

        if callback then
            SafeCall(callback, enabled)
        end
    end)

    Draw()

    local setter = function(value)
        enabled = value == true
        Draw()
        if callback then
            SafeCall(callback, enabled)
        end
    end

    ControlRegistry[title] = setter
    return row, setter
end

local function Button(parent, title, description, callback)
    local row = New("TextButton", {
        Size = UDim2.new(1, -4, 0, 58),
        BackgroundColor3 = Color3.fromRGB(14, 14, 22),
        AutoButtonColor = false,
        Text = "",
        BorderSizePixel = 0,
    }, parent)

    Corner(row, 11)

    local titleLabel = Text(row, title, 11, C.Text, Enum.Font.GothamSemibold)
    titleLabel.Position = UDim2.fromOffset(13, 8)
    titleLabel.Size = UDim2.new(1, -80, 0, 20)

    local desc = Text(row, description or "", 8, C.Muted, Enum.Font.Gotham)
    desc.Position = UDim2.fromOffset(13, 30)
    desc.Size = UDim2.new(1, -30, 0, 18)

    local arrow = Text(row, "›", 22, C.Accent, Enum.Font.GothamBold)
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.Position = UDim2.new(1, -12, 0.5, 0)
    arrow.Size = UDim2.fromOffset(20, 28)
    arrow.TextXAlignment = Enum.TextXAlignment.Center

    row.MouseButton1Click:Connect(function()
        SafeCall(callback)
    end)

    row.MouseEnter:Connect(function()
        Tween(row, 0.12, {
            BackgroundColor3 = Color3.fromRGB(23, 23, 33),
        })
    end)

    row.MouseLeave:Connect(function()
        Tween(row, 0.12, {
            BackgroundColor3 = Color3.fromRGB(14, 14, 22),
        })
    end)

    return row
end

local function Slider(parent, title, min, max, default, callback)
    local row = New("Frame", {
        Size = UDim2.new(1, -4, 0, 70),
        BackgroundColor3 = Color3.fromRGB(14, 14, 22),
        BorderSizePixel = 0,
    }, parent)

    Corner(row, 11)

    local titleLabel = Text(row, title, 11, C.Text, Enum.Font.GothamSemibold)
    titleLabel.Position = UDim2.fromOffset(13, 6)
    titleLabel.Size = UDim2.new(1, -75, 0, 21)

    local valueLabel = Text(row, tostring(default), 10, C.Accent, Enum.Font.GothamBold)
    valueLabel.AnchorPoint = Vector2.new(1, 0)
    valueLabel.Position = UDim2.new(1, -13, 0, 6)
    valueLabel.Size = UDim2.fromOffset(55, 21)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local bar = New("Frame", {
        Position = UDim2.new(0, 13, 0, 39),
        Size = UDim2.new(1, -26, 0, 5),
        BackgroundColor3 = Color3.fromRGB(34, 34, 46),
        BorderSizePixel = 0,
    }, row)
    Corner(bar, 8)

    local fill = New("Frame", {
        Size = UDim2.new(
            math.clamp((default - min) / (max - min), 0, 1),
            0,
            1,
            0
        ),
        BackgroundColor3 = C.Accent,
        BorderSizePixel = 0,
    }, bar)
    Corner(fill, 8)

    local knob = New("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(
            math.clamp((default - min) / (max - min), 0, 1),
            0,
            0.5,
            0
        ),
        Size = UDim2.fromOffset(13, 13),
        BackgroundColor3 = C.Text,
        BorderSizePixel = 0,
    }, bar)
    Corner(knob, 20)

    local dragging = false
    local value = default

    local function SetValue(newValue)
        value = math.clamp(newValue, min, max)
        local alpha = (value - min) / (max - min)

        fill.Size = UDim2.new(alpha, 0, 1, 0)
        knob.Position = UDim2.new(alpha, 0, 0.5, 0)
        valueLabel.Text = tostring(math.floor(value * 10 + 0.5) / 10)

        SafeCall(callback, value)
    end

    local function FromInput(input)
        local x = input.Position.X
        local alpha = math.clamp(
            (x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
            0,
            1
        )

        SetValue(min + (max - min) * alpha)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            FromInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            FromInput(input)
        end
    end)

    local setter = function(newValue)
        SetValue(newValue)
    end

    ControlRegistry[title] = setter
    return row, setter
end

local function Info(parent, textValue)
    local row = New("Frame", {
        Size = UDim2.new(1, -4, 0, 50),
        BackgroundColor3 = Color3.fromRGB(14, 14, 22),
        BorderSizePixel = 0,
    }, parent)

    Corner(row, 10)

    local label = Text(row, textValue, 9, C.Muted, Enum.Font.Gotham)
    label.Position = UDim2.fromOffset(13, 0)
    label.Size = UDim2.new(1, -26, 1, 0)
    label.TextWrapped = true

    return row
end

--==============================================================
-- PAGES / TABS
--==============================================================

local HomePage = CreatePage("HOME")
local CombatPage = CreatePage("COMBAT")
local VisualsPage = CreatePage("VISUALS")
local FarmPage = CreatePage("FARM")
local MovementPage = CreatePage("MOVEMENT")
local StatusPage = CreatePage("STATUS")
local SettingsPage = CreatePage("SETTINGS")

AddTab("Home", "⌂", "HOME")
AddTab("Combat", "✦", "COMBAT")
AddTab("Visuals", "◈", "VISUALS")
AddTab("Farm", "◇", "FARM")
AddTab("Movement", "↯", "MOVEMENT")
AddTab("Status", "●", "STATUS")
AddTab("Settings", "⚙", "SETTINGS")

--==============================================================
-- HOME PAGE
--==============================================================

Section(
    HomePage,
    "NEXUS // CONTROL",
    "MM2 interface rebuilt around the observable Moonveil feature set."
)

local welcome = New("Frame", {
    Size = UDim2.new(1, -4, 0, 112),
    BackgroundColor3 = Color3.fromRGB(18, 16, 30),
    BorderSizePixel = 0,
}, HomePage)
Corner(welcome, 14)
Stroke(welcome, Color3.fromRGB(103, 76, 151), 0.48, 1)

local big = Text(welcome, "NEXUS", 27, C.Text, Enum.Font.GothamBlack)
big.Position = UDim2.fromOffset(16, 11)
big.Size = UDim2.new(1, -32, 0, 34)

local sub = Text(welcome, "MURDER MYSTERY 2", 9, C.Accent, Enum.Font.GothamBold)
sub.Position = UDim2.fromOffset(18, 44)
sub.Size = UDim2.new(1, -36, 0, 18)

local info = Text(
    welcome,
    "Aim • ESP • Farm • Teleport • Movement • Tool combat helper",
    9,
    C.Muted,
    Enum.Font.Gotham
)
info.Position = UDim2.fromOffset(18, 68)
info.Size = UDim2.new(1, -36, 0, 30)
info.TextWrapped = true

Button(
    HomePage,
    "Teleport to Murderer",
    "Uses role detection and moves the local character near the murderer.",
    TeleportToMurderer
)

Button(
    HomePage,
    "Teleport to Sheriff",
    "Uses role detection and moves the local character near the sheriff.",
    TeleportToSheriff
)

Button(
    HomePage,
    "Random Player",
    "Teleport to a random living player.",
    TeleportToRandomPlayer
)

Info(
    HomePage,
    "RightShift toggles the NEXUS window. When closed, use the draggable live-stat bar to reopen it."
)

--==============================================================
-- STATUS / ROBLOX PROFILE PAGE
--==============================================================

Section(
    StatusPage,
    "ROBLOX PROFILE",
    "Live account, role, character and current server information."
)

local ProfileCard = New("Frame", {
    Size = UDim2.new(1, -4, 0, 154),
    BackgroundColor3 = Color3.fromRGB(16, 15, 25),
    BorderSizePixel = 0,
}, StatusPage)
Corner(ProfileCard, 14)
Stroke(ProfileCard, Color3.fromRGB(80, 70, 110), 0.62, 1)

local ProfileAvatar = New("ImageLabel", {
    Position = UDim2.fromOffset(14, 14),
    Size = UDim2.fromOffset(122, 122),
    BackgroundColor3 = Color3.fromRGB(28, 26, 40),
    BackgroundTransparency = 0,
    BorderSizePixel = 0,
    Image = "",
    ScaleType = Enum.ScaleType.Crop,
}, ProfileCard)
Corner(ProfileAvatar, 14)
Stroke(ProfileAvatar, C.Accent, 0.45, 1)

local ProfileName = Text(ProfileCard, LocalPlayer.DisplayName, 18, C.Text, Enum.Font.GothamBold)
ProfileName.Position = UDim2.fromOffset(153, 13)
ProfileName.Size = UDim2.new(1, -170, 0, 27)

local ProfileUsername = Text(ProfileCard, "@" .. LocalPlayer.Name, 10, C.Muted, Enum.Font.Gotham)
ProfileUsername.Position = UDim2.fromOffset(154, 40)
ProfileUsername.Size = UDim2.new(1, -172, 0, 19)

local ProfileRole = Text(ProfileCard, "ROLE: ...", 10, C.Accent, Enum.Font.GothamBold)
ProfileRole.Position = UDim2.fromOffset(154, 62)
ProfileRole.Size = UDim2.new(1, -172, 0, 20)

local ProfileMeta = Text(ProfileCard, "Loading profile...", 9, C.Muted, Enum.Font.Gotham)
ProfileMeta.Position = UDim2.fromOffset(154, 83)
ProfileMeta.Size = UDim2.new(1, -172, 0, 48)
ProfileMeta.TextWrapped = true
ProfileMeta.TextYAlignment = Enum.TextYAlignment.Top

local ProfileURL = Text(ProfileCard, "", 8, C.Accent2, Enum.Font.Gotham)
ProfileURL.Position = UDim2.fromOffset(154, 132)
ProfileURL.Size = UDim2.new(1, -172, 0, 16)
ProfileURL.TextTruncate = Enum.TextTruncate.AtEnd

local StatsCard = New("Frame", {
    Size = UDim2.new(1, -4, 0, 218),
    BackgroundColor3 = Color3.fromRGB(14, 14, 22),
    BorderSizePixel = 0,
}, StatusPage)
Corner(StatsCard, 14)
Stroke(StatsCard, Color3.fromRGB(72, 68, 98), 0.72, 1)

local StatsText = Text(StatsCard, "", 9, C.Text, Enum.Font.Gotham)
StatsText.Position = UDim2.fromOffset(14, 12)
StatsText.Size = UDim2.new(1, -28, 1, -24)
StatsText.TextWrapped = true
StatsText.TextYAlignment = Enum.TextYAlignment.Top

local function UpdateProfilePage()
    local role = GetRole(LocalPlayer)
    local humanoid = GetLocalHumanoid()
    local root = GetLocalRoot()
    local teamName = LocalPlayer.Team and LocalPlayer.Team.Name or "None"
    local health = humanoid and math.floor(math.max(humanoid.Health, 0) + 0.5) or 0
    local maxHealth = humanoid and math.floor(math.max(humanoid.MaxHealth, 0) + 0.5) or 0
    local speed = humanoid and math.floor(humanoid.WalkSpeed + 0.5) or 0
    local jump = humanoid and math.floor((humanoid.UseJumpPower and humanoid.JumpPower or 0) + 0.5) or 0
    local pos = root and root.Position or Vector3.zero
    local membership = tostring(LocalPlayer.MembershipType):gsub("Enum.MembershipType%.?", "")
    local verified = LocalPlayer.HasVerifiedBadge and "Yes" or "No"
    local profileUrl = "https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile"

    ProfileName.Text = LocalPlayer.DisplayName
    ProfileUsername.Text = "@" .. LocalPlayer.Name .. "  •  UserId " .. tostring(LocalPlayer.UserId)
    ProfileRole.Text = "ROLE: " .. tostring(role) .. "   •   TEAM: " .. tostring(teamName)
    ProfileMeta.Text = table.concat({
        "Account age: " .. tostring(LocalPlayer.AccountAge) .. " days  •  Membership: " .. membership,
        "Verified badge: " .. verified .. "  •  Players in server: " .. tostring(#Players:GetPlayers()),
    }, "\n")
    ProfileURL.Text = profileUrl

    StatsText.Text = table.concat({
        "CHARACTER",
        "Health: " .. tostring(health) .. " / " .. tostring(maxHealth) .. "    WalkSpeed: " .. tostring(speed) .. "    JumpPower: " .. tostring(jump),
        "Position: " .. string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z),
        "",
        "EXPERIENCE",
        "PlaceId: " .. tostring(game.PlaceId),
        "JobId: " .. tostring(game.JobId ~= "" and game.JobId or "Unavailable"),
        "Server players: " .. tostring(#Players:GetPlayers()),
        "",
        "ROBLOX ACCOUNT",
        "Username: " .. LocalPlayer.Name,
        "DisplayName: " .. LocalPlayer.DisplayName,
        "UserId: " .. tostring(LocalPlayer.UserId),
        "AccountAge: " .. tostring(LocalPlayer.AccountAge) .. " days",
        "Membership: " .. membership,
        "VerifiedBadge: " .. verified,
    }, "\n")
end

task.spawn(function()
    local ok, content = pcall(function()
        return Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.AvatarBust,
            Enum.ThumbnailSize.Size420x420
        )
    end)
    if ok and content then
        ProfileAvatar.Image = content
    end
end)

ProfileCard.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        local clipboard = GetExternalFunction("setclipboard")
        local url = "https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile"
        if clipboard then
            pcall(function() clipboard(url) end)
            ShowToast("PROFILE", "Profile link copied", 2.2)
        end
    end
end)

UpdateProfilePage()

--==============================================================
-- COMBAT PAGE
--==============================================================

Section(
    CombatPage,
    "AIM",
    "Smooth local camera assistance using screen-space FOV."
)

Toggle(
    CombatPage,
    "Aim Assist",
    "Aim toward the nearest player inside the FOV.",
    false,
    function(value)
        Config.Aim.Enabled = value
        FOVCircle.Visible = value
        if not value then
            LockedAimTarget = nil
        end
    end
)

Toggle(
    CombatPage,
    "Auto Teleport Gun",
    "As an Innocent, teleport to the Sheriff revolver when the Sheriff dies.",
    Config.Aim.AutoTeleportGun,
    function(value)
        Config.Aim.AutoTeleportGun = value
    end
)

Slider(
    CombatPage,
    "FOV",
    30,
    500,
    Config.Aim.FOV,
    function(value)
        Config.Aim.FOV = value
        FOVCircle.Size = UDim2.fromOffset(value * 2, value * 2)
    end
)

Slider(
    CombatPage,
    "Smoothness",
    0.03,
    1,
    Config.Aim.Smoothness,
    function(value)
        Config.Aim.Smoothness = value
    end
)

Toggle(
    CombatPage,
    "Team Check",
    "Do not target players on the same Team.",
    Config.Aim.TeamCheck,
    function(value)
        Config.Aim.TeamCheck = value
    end
)

Toggle(
    CombatPage,
    "Visible Check",
    "Only target players visible through the current camera ray.",
    Config.Aim.VisibleCheck,
    function(value)
        Config.Aim.VisibleCheck = value
    end
)

Section(
    CombatPage,
    "COMBAT TOOL",
    "Find and activate a matching tool when a target is nearby."
)

Toggle(
    CombatPage,
    "Combat Helper",
    "Activates a local Knife/Gun/Weapon tool inside the configured range.",
    false,
    function(value)
        Config.Combat.Enabled = false
    end
)

Toggle(
    CombatPage,
    "Auto Equip",
    "Automatically equip a matching combat tool.",
    Config.Combat.AutoEquip,
    function(value)
        Config.Combat.AutoEquip = value
    end
)

Slider(
    CombatPage,
    "Attack Range",
    4,
    30,
    Config.Combat.Range,
    function(value)
        Config.Combat.Range = value
    end
)

--==============================================================
-- VISUALS PAGE
--==============================================================

Section(
    VisualsPage,
    "PLAYER ESP",
    "Highlight players and show role/name/distance information."
)

Toggle(
    VisualsPage,
    "ESP",
    "Enable the player ESP system.",
    Config.ESP.Enabled,
    function(value)
        Config.ESP.Enabled = value
        if value then
            UpdateESP()
        else
            UpdateESP()
        end
    end
)

Toggle(
    VisualsPage,
    "Boxes / Highlights",
    "Show character highlight colors.",
    Config.ESP.Boxes,
    function(value)
        Config.ESP.Boxes = value
        UpdateESP()
    end
)

Toggle(
    VisualsPage,
    "Names",
    "Display username and display name.",
    Config.ESP.Names,
    function(value)
        Config.ESP.Names = value
    end
)

Toggle(
    VisualsPage,
    "Roles",
    "Try to detect Murderer / Sheriff / Innocent roles.",
    Config.ESP.Roles,
    function(value)
        Config.ESP.Roles = value
    end
)

Toggle(
    VisualsPage,
    "Distance",
    "Show the approximate distance to each player.",
    Config.ESP.Distance,
    function(value)
        Config.ESP.Distance = value
    end
)

Toggle(
    VisualsPage,
    "Tracers",
    "Display a small tracer marker in each ESP label.",
    Config.ESP.Tracers,
    function(value)
        Config.ESP.Tracers = value
        UpdateESP()
    end
)

--==============================================================
-- FARM PAGE
--==============================================================

Section(
    FarmPage,
    "AUTO FARM",
    "Pickup scanner based on the touch/farm behavior visible in Moonveil."
)

Toggle(
    FarmPage,
    "Auto Farm",
    "Find the nearest Coin/Cash/Token/Pickup and move onto it.",
    Config.Farm.Enabled,
    function(value)
        Config.Farm.Enabled = value
    end
)

Slider(
    FarmPage,
    "Farm Speed",
    1,
    120,
    Config.Farm.Speed,
    function(value)
        Config.Farm.Speed = value
    end
)

Button(
    FarmPage,
    "Collect Nearest Pickup",
    "Instantly move to the nearest recognized pickup once.",
    function()
        local pickup = FindNearestPickup()
        if pickup then
            CollectPickup(pickup)
        end
    end
)

Button(
    FarmPage,
    "Find Murderer",
    "Return to the role target used by the farm helper.",
    function()
        local murderer = FindMurdererForFarm()
        if murderer then
            TeleportToPlayer(murderer)
        end
    end
)

Info(
    FarmPage,
    "Pickup names: Coin, Coins, CoinDrop, Cash, CashDrop, Token, Pickup, Collectible."
)

--==============================================================
-- MOVEMENT PAGE
--==============================================================

Section(
    MovementPage,
    "MOVEMENT",
    "Local movement controls."
)

Slider(
    MovementPage,
    "WalkSpeed",
    8,
    200,
    Config.Movement.WalkSpeed,
    function(value)
        Config.Movement.WalkSpeed = value
        ApplyMovement()
    end
)

Toggle(
    MovementPage,
    "Safe Speed",
    "Caps the effective WalkSpeed to reduce server-side speed kick risk. This does not bypass anti-cheat checks.",
    Config.Movement.SafeSpeed,
    function(value)
        Config.Movement.SafeSpeed = value
        ApplyMovement()
    end
)

Slider(
    MovementPage,
    "Safe Speed Cap",
    16,
    30,
    Config.Movement.SafeSpeedCap,
    function(value)
        Config.Movement.SafeSpeedCap = value
        ApplyMovement()
    end
)

Slider(
    MovementPage,
    "JumpPower",
    20,
    200,
    Config.Movement.JumpPower,
    function(value)
        Config.Movement.JumpPower = value
    end
)

Toggle(
    MovementPage,
    "Noclip",
    "Disable local character collision.",
    Config.Movement.Noclip,
    function(value)
        Config.Movement.Noclip = value
    end
)

Toggle(
    MovementPage,
    "Infinite Jump",
    "Allow repeated jumps while airborne.",
    Config.Movement.InfiniteJump,
    function(value)
        Config.Movement.InfiniteJump = value
    end
)

Button(
    MovementPage,
    "Reset Movement",
    "Return WalkSpeed and JumpPower to standard values.",
    function()
        Config.Movement.WalkSpeed = 16
        Config.Movement.JumpPower = 50
        ApplyMovement()
    end
)

--==============================================================
-- SETTINGS PAGE
--==============================================================

Section(
    SettingsPage,
    "INTERFACE",
    "NEXUS visual and window controls."
)

Button(
    SettingsPage,
    "Reset Position",
    "Move NEXUS back to the center.",
    function()
        Main.Position = UDim2.fromScale(0.5, 0.52)
    end
)

Section(
    SettingsPage,
    "CONFIGURATION",
    "Save and restore NEXUS combat, ESP, farm and movement settings."
)

Button(
    SettingsPage,
    "Save Config",
    "Save the current configuration. Uses executor file storage when available.",
    function()
        local ok, message = SaveConfigToStorage()
        ShowToast(ok and "CONFIG SAVED" or "CONFIG ERROR", message, 2.6)
    end
)

Button(
    SettingsPage,
    "Load Config",
    "Load the saved configuration and immediately apply it to the menu.",
    function()
        local ok, message = LoadConfigFromStorage()
        ShowToast(ok and "CONFIG LOADED" or "CONFIG ERROR", ok and "Saved settings applied" or message, 2.6)
    end
)

Button(
    SettingsPage,
    "Copy Config JSON",
    "Copy the current configuration text when clipboard access is available.",
    function()
        local clipboard = GetExternalFunction("setclipboard")
        local ok, encoded = pcall(function()
            return HttpService:JSONEncode(ConfigSnapshot())
        end)

        if clipboard and ok then
            pcall(function() clipboard(encoded) end)
            ShowToast("CONFIG", "Configuration copied", 2.2)
        else
            ShowToast("CONFIG", "Clipboard unavailable", 2.4)
        end
    end
)

Button(
    SettingsPage,
    "Reset Saved Config",
    "Remove the stored JSON config when file APIs are available.",
    function()
        RuntimeConfigCache = nil
        local deleter = GetExternalFunction("delfile")
        if deleter then
            pcall(function() deleter(CONFIG_FILE_NAME) end)
            ShowToast("CONFIG", "Saved configuration reset", 2.4)
        else
            ShowToast("CONFIG", "Session configuration reset", 2.4)
        end
    end
)

Info(
    SettingsPage,
    "The config file is optional. In executors with writefile/readfile it is stored as NEXUS_MM2_Config.json; otherwise Save/Load works for the current session."
)

Button(
    SettingsPage,
    "Rebuild ESP",
    "Clear and recreate every player ESP object.",
    function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                ClearESP(player)
                CreateESP(player)
            end
        end
    end
)

Button(
    SettingsPage,
    "Search Combat Remote",
    "Scan ReplicatedStorage for a likely combat RemoteEvent in your own project.",
    function()
        local remote = FindLikelyCombatRemote()
        if remote then
            ShowToast("COMBAT REMOTE", "Found: " .. remote:GetFullName(), 2.6)
        else
            ShowToast("COMBAT REMOTE", "No combat remote found", 2.6)
        end
    end
)

Info(
    SettingsPage,
    "The original Moonveil source is heavily obfuscated. This build keeps the identified mechanics readable and configurable for Studio."
)

--==============================================================
-- OPEN/CLOSE HUD
--==============================================================

local MenuOpen = true
local SetMenuVisible

local OpenHUD = New("Frame", {
    Name = "OpenHUD",
    AnchorPoint = Vector2.new(0, 0),
    Position = UDim2.fromOffset(14, 14),
    Size = UDim2.fromOffset(520, 54),
    BackgroundColor3 = Color3.fromRGB(10, 10, 17),
    BackgroundTransparency = 0.06,
    Active = true,
    Visible = false,
    BorderSizePixel = 0,
    ZIndex = 50,
}, Gui)
Corner(OpenHUD, 18)
Stroke(OpenHUD, C.Accent, 0.18, 1.2)

New("UIGradient", {
    Rotation = 0,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 18, 40)),
        ColorSequenceKeypoint.new(0.52, Color3.fromRGB(13, 15, 26)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 10, 16)),
    }),
}, OpenHUD)

-- Scale the draggable live-stat opener to exactly half its former visual size.
-- Keeping the logical parent at the original dimensions preserves the existing
-- layout/drag math while UIScale reduces the rendered footprint.
New("UIScale", {
    Scale = 0.5,
}, OpenHUD)

local openLogo = Text(OpenHUD, "NEXUS", 14, C.Text, Enum.Font.GothamBlack)
openLogo.Position = UDim2.fromOffset(16, 6)
openLogo.Size = UDim2.fromOffset(72, 18)
openLogo.ZIndex = 52

local openSub = Text(OpenHUD, "MM2", 7, C.Accent2, Enum.Font.GothamBold)
openSub.Position = UDim2.fromOffset(17, 27)
openSub.Size = UDim2.fromOffset(36, 13)
openSub.ZIndex = 52

local function MakeStatPill(parent, x, width, title)
    local pill = New("Frame", {
        Position = UDim2.fromOffset(x, 8),
        Size = UDim2.fromOffset(width, 38),
        BackgroundColor3 = Color3.fromRGB(19, 20, 31),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ZIndex = 51,
    }, parent)
    Corner(pill, 11)
    Stroke(pill, Color3.fromRGB(58, 60, 82), 0.68, 1)

    local titleLabel = Text(pill, title, 6, C.Muted, Enum.Font.GothamBold)
    titleLabel.Position = UDim2.fromOffset(8, 4)
    titleLabel.Size = UDim2.new(1, -16, 0, 10)
    titleLabel.ZIndex = 52

    local valueLabel = Text(pill, "--", 10, C.Text, Enum.Font.GothamBold)
    valueLabel.Position = UDim2.fromOffset(8, 15)
    valueLabel.Size = UDim2.new(1, -16, 0, 17)
    valueLabel.ZIndex = 52
    return valueLabel
end

local OpenRoleValue = MakeStatPill(OpenHUD, 96, 92, "ROLE")
local OpenHPValue = MakeStatPill(OpenHUD, 194, 76, "HP")
local OpenSpeedValue = MakeStatPill(OpenHUD, 276, 86, "SPEED")
local OpenPlayersValue = MakeStatPill(OpenHUD, 368, 78, "PLAYERS")
local OpenAimValue = MakeStatPill(OpenHUD, 452, 58, "AIM")

local openDragActive = false
local openDragStart
local openStartPosition
local openMoved = false

local function UpdateOpenHUDStats()
    local humanoid = GetLocalHumanoid()
    local role = GetRole(LocalPlayer)
    local hp = humanoid and math.floor(math.max(humanoid.Health, 0) + 0.5) or 0
    local speed = humanoid and math.floor(humanoid.WalkSpeed + 0.5) or 0

    OpenRoleValue.Text = tostring(role):upper()
    OpenRoleValue.TextColor3 = role == "Murderer" and Color3.fromRGB(255, 96, 115)
        or role == "Sheriff" and Color3.fromRGB(92, 172, 255)
        or C.Text
    OpenHPValue.Text = tostring(hp)
    OpenSpeedValue.Text = tostring(speed)
    OpenPlayersValue.Text = tostring(#Players:GetPlayers())
    OpenAimValue.Text = Config.Aim.Enabled and "ON" or "OFF"
    OpenAimValue.TextColor3 = Config.Aim.Enabled and Color3.fromRGB(92, 235, 168) or C.Muted
end

OpenHUD.InputBegan:Connect(function(input)
    if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    openDragActive = true
    openMoved = false
    openDragStart = input.Position
    openStartPosition = OpenHUD.Position
end)

UserInputService.InputChanged:Connect(function(input)
    if not openDragActive then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - openDragStart
    if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then
        openMoved = true
    end

    local viewport = Gui.AbsoluteSize
    local barSize = OpenHUD.AbsoluteSize
    local nextX = math.clamp(
        openStartPosition.X.Offset + delta.X,
        8,
        math.max(8, viewport.X - barSize.X - 8)
    )
    local nextY = math.clamp(
        openStartPosition.Y.Offset + delta.Y,
        8,
        math.max(8, viewport.Y - barSize.Y - 8)
    )

    OpenHUD.Position = UDim2.fromOffset(nextX, nextY)
end)

UserInputService.InputEnded:Connect(function(input)
    if not openDragActive then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    openDragActive = false

    if not openMoved and not MenuOpen then
        SetMenuVisible(true)
    end
end)

OpenHUD.MouseEnter:Connect(function()
    Tween(OpenHUD, 0.12, {
        Size = UDim2.fromOffset(528, 58),
    })
end)

OpenHUD.MouseLeave:Connect(function()
    Tween(OpenHUD, 0.12, {
        Size = UDim2.fromOffset(520, 54),
    })
end)

SetMenuVisible = function(value)
    MenuOpen = value

    if value then
        Backdrop.Visible = false
        Main.Visible = true
        OpenHUD.Visible = false

        Main.Size = UDim2.fromOffset(810, 495)
        Tween(Main, 0.24, {
            Size = UDim2.fromOffset(820, 505),
        }, Enum.EasingStyle.Back)
    else
        Backdrop.Visible = false
        Main.Visible = false
        OpenHUD.Visible = true
    end
end

CloseButton.MouseButton1Click:Connect(function()
    SetMenuVisible(false)
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.KeyCode == Config.ToggleKey then
        SetMenuVisible(not MenuOpen)
    end
end)

Backdrop.Visible = false
SetMenuVisible(true)

--==============================================================
-- DRAG
--==============================================================

local dragging = false
local dragStart
local startPosition

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = Main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local delta = input.Position - dragStart

    Main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end)

--==============================================================
-- ROLE SIGNALS
--==============================================================

local RoleSignalConnections = {}

local function DisconnectRoleSignals(player)
    local connections = RoleSignalConnections[player]
    if not connections then
        return
    end

    for _, connection in ipairs(connections) do
        pcall(function() connection:Disconnect() end)
    end

    RoleSignalConnections[player] = nil
end

local function RefreshPlayerRoleNow(player)
    if not player then
        return
    end

    RoleCache[player] = GetRole(player)
    local normalized = NormalizeRole(RoleCache[player])
    if normalized then
        LastKnownRole[player] = normalized
    end

    if Config.ESP.Enabled and player ~= LocalPlayer then
        task.defer(UpdateESP)
    end

    if player == LocalPlayer and ProfileRole then
        task.defer(UpdateProfilePage)
    end
end

local function BindRoleSignals(player)
    DisconnectRoleSignals(player)

    local connections = {}

    table.insert(connections, player.AttributeChanged:Connect(function()
        RefreshPlayerRoleNow(player)
    end))

    table.insert(connections, player.ChildAdded:Connect(function(child)
        if child.Name == "Backpack" then
            RefreshPlayerRoleNow(player)
            table.insert(connections, child.ChildAdded:Connect(function()
                RefreshPlayerRoleNow(player)
            end))
            table.insert(connections, child.ChildRemoved:Connect(function()
                RefreshPlayerRoleNow(player)
            end))
        end
    end))

    table.insert(connections, player.CharacterAdded:Connect(function(character)
        RefreshPlayerRoleNow(player)

        table.insert(connections, character.ChildAdded:Connect(function()
            RefreshPlayerRoleNow(player)
        end))

        table.insert(connections, character.ChildRemoved:Connect(function()
            RefreshPlayerRoleNow(player)
        end))

        task.defer(function()
            RefreshPlayerRoleNow(player)
        end)
    end))

    table.insert(connections, player.CharacterRemoving:Connect(function()
        RefreshPlayerRoleNow(player)
    end))

    table.insert(connections, player:GetPropertyChangedSignal("Team"):Connect(function()
        RefreshPlayerRoleNow(player)
    end))

    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        table.insert(connections, backpack.ChildAdded:Connect(function()
            RefreshPlayerRoleNow(player)
        end))
        table.insert(connections, backpack.ChildRemoved:Connect(function()
            RefreshPlayerRoleNow(player)
        end))
    end

    local character = player.Character
    if character then
        table.insert(connections, character.ChildAdded:Connect(function()
            RefreshPlayerRoleNow(player)
        end))
        table.insert(connections, character.ChildRemoved:Connect(function()
            RefreshPlayerRoleNow(player)
        end))
    end

    RoleSignalConnections[player] = connections
    RefreshPlayerRoleNow(player)
end

--==============================================================
-- PLAYER HOOKS
--==============================================================

local function HookPlayer(player)
    BindRoleSignals(player)

    if player == LocalPlayer then
        return
    end

    player.CharacterAdded:Connect(function()
        task.wait(0.75)

        if Config.ESP.Enabled then
            CreateESP(player)
        end
    end)

    if player.Character then
        task.defer(function()
            if Config.ESP.Enabled then
                CreateESP(player)
            end
        end)
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    HookPlayer(player)
end

Players.PlayerAdded:Connect(HookPlayer)

local SheriffDeathHooks = {}
local AutoGunTeleportBusy = false

Players.PlayerRemoving:Connect(function(player)
    ClearESP(player)
    RoleCache[player] = nil
    LastKnownRole[player] = nil
    DisconnectRoleSignals(player)
    local hook = SheriffDeathHooks[player]
    if hook and hook.Connection then
        hook.Connection:Disconnect()
    end
    SheriffDeathHooks[player] = nil
end)

--==============================================================
-- AUTO TELEPORT TO SHERIFF GUN DROP
--==============================================================

local GunDropCache = {}
local SheriffDeathObserved = false
local TryAutoTeleportToGun

local function IsGunDropObject(object)
    if not object then return false end
    local n = object.Name:lower()
    return n == "gundrop"
        or n == "droppedgun"
        or n == "revolverdrop"
        or n == "droppedrevolver"
        or n == "sheriffgun"
        or n == "revolver"
        or n:find("gundrop", 1, true) ~= nil
        or n:find("revolverdrop", 1, true) ~= nil
        or n:find("droppedgun", 1, true) ~= nil
end

local function GetObjectPart(object)
    if not object or not object.Parent then return nil end
    if object:IsA("BasePart") then return object end
    if object:IsA("Model") then
        return object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart", true)
    end
    return object:FindFirstChildWhichIsA("BasePart", true)
end

local function CacheGunDrop(object)
    if IsGunDropObject(object) then
        GunDropCache[object] = true
    end
end

for _, object in ipairs(Workspace:GetDescendants()) do
    CacheGunDrop(object)
end

Workspace.DescendantAdded:Connect(function(object)
    if IsGunDropObject(object) then
        GunDropCache[object] = true
        if Config.Aim.AutoTeleportGun and AimRole() == "Innocent" then
            task.delay(0.05, TryAutoTeleportToGun)
        end
    end
end)

Workspace.DescendantRemoving:Connect(function(object)
    GunDropCache[object] = nil
end)

local function FindGunDrop()
    for object in pairs(GunDropCache) do
        if object and object.Parent and object:IsDescendantOf(Workspace) then
            local part = GetObjectPart(object)
            if part then
                return part
            end
        else
            GunDropCache[object] = nil
        end
    end

    -- Small fallback scan for custom drop models that don't emit a matching name until late.
    for _, object in ipairs(Workspace:GetChildren()) do
        if IsGunDropObject(object) then
            local part = GetObjectPart(object)
            if part then
                GunDropCache[object] = true
                return part
            end
        end
    end

    return nil
end

local function PickupGunDrop(drop)
    local root = GetLocalRoot()
    if not root or not drop then return false end

    local function TryTouchPart(part)
        if not part or not part:IsA("BasePart") then return end
        if typeof(firetouchinterest) == "function" then
            pcall(function()
                firetouchinterest(root, part, 0)
                task.wait(0.02)
                firetouchinterest(root, part, 1)
            end)
        end
    end

    for _ = 1, 10 do
        if not drop or not drop.Parent then
            break
        end

        root.CFrame = drop.CFrame + Vector3.new(0, 1.25, 0)
        TryTouchPart(drop)

        -- Some MM2 drops are Models with a TouchInterest on a child part.
        local parent = drop.Parent
        if parent and parent:IsA("Model") then
            for _, child in ipairs(parent:GetDescendants()) do
                if child:IsA("BasePart") then
                    TryTouchPart(child)
                end
            end
        end

        task.wait(0.05)

        local tool = FindRevolverTool()
        if tool then
            EquipRevolver()
            task.wait(0.05)
            return FindRevolverTool() ~= nil
        end
    end

    local tool = FindRevolverTool()
    if tool then
        EquipRevolver()
        return true
    end

    return false
end

TryAutoTeleportToGun = function()
    if AutoGunTeleportBusy or not Config.Aim.AutoTeleportGun then
        return
    end

    if AimRole() ~= "Innocent" then
        return
    end

    AutoGunTeleportBusy = true

    task.spawn(function()
        -- Wait for the actual drop instead of depending on Sheriff ESP/role text.
        for _ = 1, 30 do
            if not Config.Aim.AutoTeleportGun or AimRole() ~= "Innocent" then
                break
            end

            local drop = FindGunDrop()
            local root = GetLocalRoot()

            if drop and root then
                local picked = PickupGunDrop(drop)
                if picked then
                    SheriffDeathObserved = false
                    break
                end
            end

            task.wait(0.08)
        end

        -- One last equip attempt in case the drop vanished just after touch.
        if Config.Aim.AutoTeleportGun and AimRole() == "Innocent" then
            local tool = FindRevolverTool()
            if tool then
                EquipRevolver()
            end
        end

        AutoGunTeleportBusy = false
    end)
end

local function HookSheriffDeath(player)
    if not player or player == LocalPlayer then
        return
    end

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    local old = SheriffDeathHooks[player]
    if old and old.Humanoid == humanoid then
        return
    end

    if old and old.Connection then
        old.Connection:Disconnect()
    end

    local connection = humanoid.Died:Connect(function()
        if not Config.Aim.AutoTeleportGun or AimRole() ~= "Innocent" then
            return
        end

        -- Do not rely on the ESP being correct at the exact death frame.
        -- LastKnownRole catches the Sheriff role before CharacterRemoving,
        -- while the drop watcher independently catches the actual gun.
        local knownRole = LastKnownRole[player]
        local wasSheriff = knownRole == "Sheriff"
            or GetRole(player):lower():find("sheriff", 1, true) ~= nil
            or HasRevolver(player)

        if wasSheriff then
            SheriffDeathObserved = true
            task.defer(TryAutoTeleportToGun)
        else
            -- A tiny fallback still watches for the gun if role data arrived late.
            task.delay(0.08, function()
                if Config.Aim.AutoTeleportGun and AimRole() == "Innocent" then
                    local drop = FindGunDrop()
                    if drop then
                        TryAutoTeleportToGun()
                    end
                end
            end)
        end
    end)

    SheriffDeathHooks[player] = {
        Humanoid = humanoid,
        Connection = connection,
    }
end

local function SetupSheriffDeathHooks()
    if not Config.Aim.AutoTeleportGun then
        return
    end

    -- Hook every living opponent. This makes the feature independent from
    -- whether ESP/role replication has updated on this exact frame.
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and Alive(player) then
            HookSheriffDeath(player)
        end
    end

    if SheriffDeathObserved and AimRole() == "Innocent" then
        TryAutoTeleportToGun()
    end
end
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.35)
    ApplyMovement()
    SetupSpeedGuard()

    RefreshCamera()

    if Config.ESP.Enabled then
        UpdateESP()
    end
end)

--==============================================================
-- MAIN LOOP
--==============================================================

local elapsed = 0
local farmClock = 0
local espClock = 0
local sheriffHookClock = 0
local roleClock = 0
local profileClock = 0
local serverRoleClock = 0

RunService.RenderStepped:Connect(function(dt)
    elapsed += dt
    farmClock += dt
    espClock += dt
    sheriffHookClock += dt
    roleClock += dt
    profileClock += dt
    serverRoleClock += dt

    RefreshCamera()

    -- The background is static on purpose: no per-frame image movement.
    if roleClock >= 0.20 then
        roleClock = 0
        RefreshRoleCache()
        UpdateOpenHUDStats()
    end

    if serverRoleClock >= 0.45 then
        serverRoleClock = 0
        RefreshServerRoleData()
    end

    if profileClock >= 0.25 then
        profileClock = 0
        UpdateProfilePage()
    end

    if FOVCircle.Visible then
        FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
    end

    -- ESP is refreshed a few times per second instead of dozens of times.
    if espClock >= 0.18 then
        espClock = 0
        UpdateESP()
    end

    -- Sheriff death hook maintenance is lightweight and infrequent.
    if sheriffHookClock >= 0.40 then
        sheriffHookClock = 0
        SetupSheriffDeathHooks()
    end

    if Config.Farm.Enabled and farmClock >= 0.08 then
        farmClock = 0
        task.spawn(AutoFarmTick)
    end

end)

--==============================================================
-- INITIAL STATE
--==============================================================

SelectTab("HOME")
ApplyMovement()
RefreshServerRoleData()
RefreshRoleCache()
UpdateESP()
UpdateProfilePage()
UpdateOpenHUDStats()
SetupSpeedGuard()
SetupSheriffDeathHooks()

-- Optional server-authoritative remote reference for your own game:
_G.NexusCombatRemote = FindLikelyCombatRemote()

-- End.
