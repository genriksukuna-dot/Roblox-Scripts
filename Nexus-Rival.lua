print("[NEXUS] Starting execution...")

--// MULTI-RUN CLEANUP
if _G.NexusShooterCleanup then
    pcall(_G.NexusShooterCleanup)
end

local Cleanups = {}

_G.NexusShooterCleanup = function()
    for _, item in ipairs(Cleanups) do
        pcall(function()
            if typeof(item) == "RBXScriptConnection" then
                item:Disconnect()
            elseif typeof(item) == "Instance" then
                item:Destroy()
            elseif type(item) == "function" then
                item()
            end
        end)
    end

    pcall(function()
        local rs = game:GetService("RunService")
        rs:UnbindFromRenderStep("NexusAimEngine")
        rs:UnbindFromRenderStep("NexusESPEngine")
    end)

    table.clear(Cleanups)
end

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StatsService = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    local startT = os.clock()
    repeat
        task.wait(0.1)
        LocalPlayer = Players.LocalPlayer
    until LocalPlayer or (os.clock() - startT > 3)
end

if not LocalPlayer then
    warn("[NEXUS] LocalPlayer not found!")
    return
end

local Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")

--// CONFIG
local Config = {
    Aimbot = {
        Enabled = false,
        AutoFire = false,
        HitboxExpander = false,
        HitboxSize = 10,
        NoRecoil = true,
        Smoothness = 1.00,
        AimResponse = 78,
        FOV = 150,
        DrawFOV = true,
        VisibilityCheck = true,
        TeamCheck = true,
        TargetPart = "Head"
    },

    Weapon = {
        FireRate = 12,
        FireRange = 1000,
        UseRemoteFire = false,
        AutoDetectFireMode = true,
        DefaultAutomatic = false,
        RapidFire = false,
        RapidFireRate = 45,
        InfiniteAmmo = false,
        AmmoRefreshInterval = 0.08,
        TeleportBurstDuration = 0.65,
        TeleportAutoFireRate = 16,
        SafeRapidMaxRate = 60
    },

    ESP = {
        Enabled = false,
        Boxes = true,
        Skeleton = true,
        Snaplines = true,
        Names = true,
        Distance = true,
        HealthBar = true,
        TeamCheck = true,
        BoxColor = Color3.fromRGB(255, 45, 75),
        TracerColor = Color3.fromRGB(0, 235, 255),
        SkeletonColor = Color3.fromRGB(0, 255, 140)
    },

    Teleport = {
        Enabled = false,
        OffsetY = 15,
        SwitchDelay = 0.15,
        UseServerRemote = true
    },

    Settings = {
        Watermark = true,
        RainbowFOV = false
    },

    ActiveTab = "AIMBOT"
}

local TG_LINK = "https://t.me/+qTcgFmViTe9jMzU6"
local ConfigFileName = "NexusRivalConfig.json"

--// TARGET STATE IS DECLARED BEFORE UI CALLBACKS
local StickyTargetPlayer = nil
local StickyTargetPart = nil
local smoothedAimPos = nil
local LastFireTime = 0
local MAX_LEAD_TIME = 0.035
local TeleportAttackToken = 0
local startTeleportWeaponAttack

--// AUTO TELEPORT STATE
local TeleportTargetPlayer = nil
local TeleportTargetDeathConnection = nil
local LastTeleportTime = 0
local startAutoTeleport
local stopAutoTeleport

--// OPTIONAL REMOTE FIRE ADAPTER
local FireWeaponRemote = nil
pcall(function()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local remote = remotes:FindFirstChild("FireWeapon")
        if remote and remote:IsA("RemoteEvent") then
            FireWeaponRemote = remote
        end
    end
end)

--// SERVER TELEPORT ADAPTER
-- For a server-authoritative game, create/use a RemoteEvent named:
-- ReplicatedStorage.Remotes.NexusTeleport
-- The companion ServerScript file included with this package creates it.
local NexusTeleportRemote = nil
pcall(function()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    if remotes then
        local remote = remotes:FindFirstChild("NexusTeleport")
        if remote and remote:IsA("RemoteEvent") then
            NexusTeleportRemote = remote
        end
    end
end)

--// SAVE & LOAD
local function serializeColor(c)
    return {c.R, c.G, c.B}
end

local function saveConfig()
    local data = {
        Aimbot = Config.Aimbot,
        Weapon = Config.Weapon,
        ESP = {
            Enabled = Config.ESP.Enabled,
            Boxes = Config.ESP.Boxes,
            Skeleton = Config.ESP.Skeleton,
            Snaplines = Config.ESP.Snaplines,
            Names = Config.ESP.Names,
            Distance = Config.ESP.Distance,
            HealthBar = Config.ESP.HealthBar,
            TeamCheck = Config.ESP.TeamCheck,
            BoxColor = serializeColor(Config.ESP.BoxColor),
            TracerColor = serializeColor(Config.ESP.TracerColor),
            SkeletonColor = serializeColor(Config.ESP.SkeletonColor)
        },
        Teleport = Config.Teleport,
        Settings = Config.Settings
    }

    local success, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)

    if success and writefile then
        pcall(function()
            writefile(ConfigFileName, encoded)
        end)
    end
end

local function loadConfig()
    if not (readfile and isfile) then
        return
    end

    if not isfile(ConfigFileName) then
        return
    end

    local success, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(ConfigFileName))
    end)

    if not success or type(decoded) ~= "table" then
        return
    end

    if decoded.Aimbot then
        for k, v in pairs(decoded.Aimbot) do
            if Config.Aimbot[k] ~= nil then
                Config.Aimbot[k] = v
            end
        end
    end

    if decoded.Weapon then
        for k, v in pairs(decoded.Weapon) do
            if Config.Weapon[k] ~= nil then
                Config.Weapon[k] = v
            end
        end
    end

    if decoded.ESP then
        for k, v in pairs(decoded.ESP) do
            if k == "BoxColor" and type(v) == "table" then
                Config.ESP.BoxColor = Color3.new(v[1], v[2], v[3])
            elseif k == "TracerColor" and type(v) == "table" then
                Config.ESP.TracerColor = Color3.new(v[1], v[2], v[3])
            elseif k == "SkeletonColor" and type(v) == "table" then
                Config.ESP.SkeletonColor = Color3.new(v[1], v[2], v[3])
            elseif Config.ESP[k] ~= nil then
                Config.ESP[k] = v
            end
        end
    end

    if decoded.Teleport then
        for k, v in pairs(decoded.Teleport) do
            if Config.Teleport[k] ~= nil then
                Config.Teleport[k] = v
            end
        end
    end

    if decoded.Settings then
        for k, v in pairs(decoded.Settings) do
            if Config.Settings[k] ~= nil then
                Config.Settings[k] = v
            end
        end
    end
end

pcall(loadConfig)

--// THEMES
local Themes = {
    CyberNeon = {
        Name = "Cyber Neon",
        Bg = Color3.fromRGB(11, 13, 20),
        HeaderBg = Color3.fromRGB(16, 19, 30),
        CardBg = Color3.fromRGB(19, 23, 36),
        Border = Color3.fromRGB(38, 48, 75),
        Accent = Color3.fromRGB(0, 230, 255),
        AccentSec = Color3.fromRGB(0, 255, 160),
        Text = Color3.fromRGB(255, 255, 255),
        Muted = Color3.fromRGB(145, 155, 185),
        TabActive = Color3.fromRGB(0, 185, 225)
    },
    CrimsonBlood = {
        Name = "Crimson Blood",
        Bg = Color3.fromRGB(14, 10, 12),
        HeaderBg = Color3.fromRGB(22, 14, 17),
        CardBg = Color3.fromRGB(28, 17, 21),
        Border = Color3.fromRGB(70, 32, 40),
        Accent = Color3.fromRGB(255, 45, 75),
        AccentSec = Color3.fromRGB(255, 140, 0),
        Text = Color3.fromRGB(255, 255, 255),
        Muted = Color3.fromRGB(180, 140, 150),
        TabActive = Color3.fromRGB(210, 35, 65)
    },
    PurpleVoid = {
        Name = "Purple Void",
        Bg = Color3.fromRGB(12, 10, 20),
        HeaderBg = Color3.fromRGB(18, 14, 30),
        CardBg = Color3.fromRGB(24, 18, 38),
        Border = Color3.fromRGB(60, 40, 95),
        Accent = Color3.fromRGB(175, 70, 255),
        AccentSec = Color3.fromRGB(240, 60, 220),
        Text = Color3.fromRGB(255, 255, 255),
        Muted = Color3.fromRGB(165, 145, 195),
        TabActive = Color3.fromRGB(150, 50, 230)
    }
}

local CurrentTheme = Themes.CyberNeon

local PaletteSwatches = {
    Color3.fromRGB(255, 45, 75),
    Color3.fromRGB(0, 235, 255),
    Color3.fromRGB(0, 255, 140),
    Color3.fromRGB(255, 220, 40),
    Color3.fromRGB(185, 75, 255),
    Color3.fromRGB(255, 255, 255)
}

--// HELPERS
local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function addStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or CurrentTheme.Border
    s.Thickness = thickness or 1.2
    s.Parent = parent
    return s
end

local function tween(inst, duration, props, style, dir)
    if not inst then
        return
    end

    local tw = TweenService:Create(
        inst,
        TweenInfo.new(
            duration or 0.25,
            style or Enum.EasingStyle.Quart,
            dir or Enum.EasingDirection.Out
        ),
        props
    )
    tw:Play()
    return tw
end

local function copyClipboard(text)
    local fn = setclipboard or toclipboard or (Clipboard and Clipboard.set)
    if fn then
        pcall(fn, text)
        return true
    end
    return false
end

--// SMART TEAM CHECK
local function isTeammate(player)
    if not player or player == LocalPlayer then
        return true
    end

    if LocalPlayer.Team ~= nil and player.Team ~= nil then
        return LocalPlayer.Team == player.Team
    end

    if not LocalPlayer.Neutral
        and not player.Neutral
        and LocalPlayer.TeamColor ~= nil
        and player.TeamColor ~= nil then
        return LocalPlayer.TeamColor == player.TeamColor
    end

    local function getTeamValue(p)
        local character = p.Character
        local names = {
            "Team", "TeamName", "TeamID", "TeamId",
            "TeamColor", "Faction", "FactionName", "Side"
        }

        for _, name in ipairs(names) do
            local value = p:GetAttribute(name)
            if value ~= nil and tostring(value) ~= "" then
                return tostring(value)
            end
            if character then
                value = character:GetAttribute(name)
                if value ~= nil and tostring(value) ~= "" then
                    return tostring(value)
                end
            end
        end

        for _, container in ipairs({p, character}) do
            if container then
                for _, name in ipairs(names) do
                    local obj = container:FindFirstChild(name)
                    if obj and obj:IsA("ValueBase") then
                        local value = obj.Value
                        if value ~= nil and tostring(value) ~= "" then
                            return tostring(value)
                        end
                    end
                end
            end
        end

        return nil
    end

    local myTeam = getTeamValue(LocalPlayer)
    local theirTeam = getTeamValue(player)

    if myTeam ~= nil and theirTeam ~= nil then
        return myTeam == theirTeam
    end

    return false
end

--// GUI CONTAINER
local ContainerGui
pcall(function()
    if type(gethui) == "function" then
        ContainerGui = gethui()
    end
end)
if not ContainerGui then
    pcall(function()
        ContainerGui = game:GetService("CoreGui")
    end)
end
if not ContainerGui then
    pcall(function()
        ContainerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
    end)
end
if not ContainerGui then
    warn("[NEXUS] GUI container not found.")
    return
end

local RootScreen = Instance.new("ScreenGui")
RootScreen.Name = "NexusSupremeShooter"
RootScreen.ResetOnSpawn = false
RootScreen.IgnoreGuiInset = true
RootScreen.DisplayOrder = 99999
RootScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
RootScreen.Parent = ContainerGui
table.insert(Cleanups, RootScreen)

local ESPDrawContainer = Instance.new("Frame")
ESPDrawContainer.Name = "ESPCanvas"
ESPDrawContainer.Size = UDim2.fromScale(1, 1)
ESPDrawContainer.BackgroundTransparency = 1
ESPDrawContainer.BorderSizePixel = 0
ESPDrawContainer.ZIndex = 5
ESPDrawContainer.Parent = RootScreen

--// FOV UI
local FOVCircleFrame = Instance.new("Frame")
FOVCircleFrame.Name = "FOVCircle"
FOVCircleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircleFrame.BackgroundTransparency = 1
FOVCircleFrame.Size = UDim2.fromOffset(Config.Aimbot.FOV * 2, Config.Aimbot.FOV * 2)
FOVCircleFrame.Visible = false
FOVCircleFrame.ZIndex = 8
FOVCircleFrame.Parent = RootScreen
addCorner(FOVCircleFrame, 999)
local FOVStroke = addStroke(FOVCircleFrame, CurrentTheme.Accent, 1.4)

--// WATERMARK
local WatermarkFrame = Instance.new("Frame")
WatermarkFrame.Name = "WatermarkHUD"
WatermarkFrame.Size = UDim2.fromOffset(180, 24)
WatermarkFrame.Position = UDim2.new(1, -190, 0, 16)
WatermarkFrame.BackgroundColor3 = CurrentTheme.HeaderBg
WatermarkFrame.BorderSizePixel = 0
WatermarkFrame.Visible = Config.Settings.Watermark
WatermarkFrame.ZIndex = 90
WatermarkFrame.Parent = RootScreen
addCorner(WatermarkFrame, 6)
addStroke(WatermarkFrame, CurrentTheme.Border, 1)

local WatermarkTxt = Instance.new("TextLabel")
WatermarkTxt.Size = UDim2.fromScale(1, 1)
WatermarkTxt.BackgroundTransparency = 1
WatermarkTxt.Font = Enum.Font.GothamBlack
WatermarkTxt.Text = "NEXUS | 60 FPS | 35ms"
WatermarkTxt.TextSize = 8.5
WatermarkTxt.TextColor3 = CurrentTheme.Accent
WatermarkTxt.ZIndex = 91
WatermarkTxt.Parent = WatermarkFrame

--// TELEGRAM POPUP
local TgCard = Instance.new("Frame")
TgCard.Name = "TelegramPrompt"
TgCard.Size = UDim2.fromOffset(260, 100)
TgCard.Position = UDim2.new(1, 300, 0, 50)
TgCard.BackgroundColor3 = CurrentTheme.HeaderBg
TgCard.BorderSizePixel = 0
TgCard.ZIndex = 200
TgCard.Parent = RootScreen
addCorner(TgCard, 12)
addStroke(TgCard, CurrentTheme.Accent, 1.5)

local TgTitle = Instance.new("TextLabel")
TgTitle.Size = UDim2.new(1, -40, 0, 18)
TgTitle.Position = UDim2.fromOffset(12, 10)
TgTitle.BackgroundTransparency = 1
TgTitle.Font = Enum.Font.GothamBlack
TgTitle.Text = "JOIN TELEGRAM"
TgTitle.TextSize = 10.5
TgTitle.TextColor3 = CurrentTheme.Text
TgTitle.TextXAlignment = Enum.TextXAlignment.Left
TgTitle.ZIndex = 202
TgTitle.Parent = TgCard

local TgClose = Instance.new("TextButton")
TgClose.Size = UDim2.fromOffset(20, 20)
TgClose.Position = UDim2.new(1, -26, 0, 10)
TgClose.BackgroundTransparency = 1
TgClose.Font = Enum.Font.GothamBold
TgClose.Text = "X"
TgClose.TextSize = 11
TgClose.TextColor3 = CurrentTheme.Muted
TgClose.ZIndex = 203
TgClose.Parent = TgCard

local TgDesc = Instance.new("TextLabel")
TgDesc.Size = UDim2.new(1, -24, 0, 26)
TgDesc.Position = UDim2.fromOffset(12, 30)
TgDesc.BackgroundTransparency = 1
TgDesc.Font = Enum.Font.GothamMedium
TgDesc.Text = "Get exclusive configs & script updates!"
TgDesc.TextSize = 8.5
TgDesc.TextColor3 = CurrentTheme.Muted
TgDesc.TextXAlignment = Enum.TextXAlignment.Left
TgDesc.TextWrapped = true
TgDesc.ZIndex = 202
TgDesc.Parent = TgCard

local TgCopyBtn = Instance.new("TextButton")
TgCopyBtn.Size = UDim2.new(1, -24, 0, 28)
TgCopyBtn.Position = UDim2.fromOffset(12, 62)
TgCopyBtn.BackgroundColor3 = CurrentTheme.Accent
TgCopyBtn.BorderSizePixel = 0
TgCopyBtn.Font = Enum.Font.GothamBlack
TgCopyBtn.Text = "COPY TG LINK"
TgCopyBtn.TextSize = 9
TgCopyBtn.TextColor3 = Color3.fromRGB(15, 15, 20)
TgCopyBtn.ZIndex = 202
TgCopyBtn.Parent = TgCard
addCorner(TgCopyBtn, 7)

tween(TgCard, 0.55, {
    Position = UDim2.new(1, -280, 0, 50)
}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

TgCopyBtn.Activated:Connect(function()
    copyClipboard(TG_LINK)
    TgCopyBtn.Text = "COPIED TO CLIPBOARD!"
    TgCopyBtn.BackgroundColor3 = CurrentTheme.AccentSec
    task.delay(2.2, function()
        if TgCopyBtn.Parent then
            TgCopyBtn.Text = "COPY TG LINK"
            TgCopyBtn.BackgroundColor3 = CurrentTheme.Accent
        end
    end)
end)

TgClose.Activated:Connect(function()
    tween(TgCard, 0.3, {
        Position = UDim2.new(1, 300, 0, 50)
    }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    task.delay(0.32, function()
        if TgCard.Parent then
            TgCard:Destroy()
        end
    end)
end)

--// MINI PILL
local MiniPill = Instance.new("Frame")
MiniPill.Name = "MiniPill"
MiniPill.Size = UDim2.fromOffset(130, 36)
MiniPill.Position = UDim2.new(0.5, -65, 0, 16)
MiniPill.BackgroundColor3 = CurrentTheme.HeaderBg
MiniPill.BorderSizePixel = 0
MiniPill.Visible = false
MiniPill.Active = true
MiniPill.ZIndex = 100
MiniPill.Parent = RootScreen
addCorner(MiniPill, 18)
local PillStroke = addStroke(MiniPill, CurrentTheme.Accent, 1.3)

local PillDot = Instance.new("Frame")
PillDot.Size = UDim2.fromOffset(8, 8)
PillDot.Position = UDim2.fromOffset(10, 14)
PillDot.BackgroundColor3 = CurrentTheme.AccentSec
PillDot.BorderSizePixel = 0
PillDot.ZIndex = 101
PillDot.Parent = MiniPill
addCorner(PillDot, 99)

local PillLabel = Instance.new("TextLabel")
PillLabel.Size = UDim2.new(1, -28, 1, 0)
PillLabel.Position = UDim2.fromOffset(26, 0)
PillLabel.BackgroundTransparency = 1
PillLabel.Font = Enum.Font.GothamBlack
PillLabel.Text = "OPEN MENU"
PillLabel.TextSize = 8.5
PillLabel.TextColor3 = CurrentTheme.Text
PillLabel.TextXAlignment = Enum.TextXAlignment.Left
PillLabel.ZIndex = 101
PillLabel.Parent = MiniPill

local PillBtn = Instance.new("TextButton")
PillBtn.Size = UDim2.fromScale(1, 1)
PillBtn.BackgroundTransparency = 1
PillBtn.Text = ""
PillBtn.ZIndex = 105
PillBtn.Parent = MiniPill

--// MAIN MENU
local vp = Camera and Camera.ViewportSize or Vector2.new(800, 450)
local winW = math.clamp(math.floor(vp.X * 0.88), 470, 560)
local winH = math.clamp(math.floor(vp.Y * 0.86), 330, 410)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.fromScale(0.5, 0.5)
MainFrame.Size = UDim2.fromOffset(winW, winH)
MainFrame.Visible = true
MainFrame.BackgroundColor3 = CurrentTheme.Bg
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = RootScreen
addCorner(MainFrame, 14)
local MainStroke = addStroke(MainFrame, CurrentTheme.Accent, 1.4)

local TopNeon = Instance.new("Frame")
TopNeon.Size = UDim2.new(1, 0, 0, 3)
TopNeon.BackgroundColor3 = CurrentTheme.Accent
TopNeon.BorderSizePixel = 0
TopNeon.Parent = MainFrame

--// MENU TOGGLE
local toggleMenu
local MenuAccess = Instance.new("TextButton")
MenuAccess.Name = "MenuAccess"
MenuAccess.Size = UDim2.fromOffset(42, 42)
MenuAccess.Position = UDim2.fromOffset(16, 84)
MenuAccess.BackgroundColor3 = CurrentTheme.HeaderBg
MenuAccess.BorderSizePixel = 0
MenuAccess.Text = "N"
MenuAccess.TextSize = 14
MenuAccess.Font = Enum.Font.GothamBlack
MenuAccess.TextColor3 = CurrentTheme.Accent
MenuAccess.ZIndex = 120
MenuAccess.Visible = false
MenuAccess.Parent = RootScreen
addCorner(MenuAccess, 12)
addStroke(MenuAccess, CurrentTheme.Accent, 1.2)

local isDragging = false
local dragStart = nil
local startPos = nil

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = false
    end
end)

table.insert(Cleanups, UserInputService.InputChanged:Connect(function(input)
    if isDragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end))

toggleMenu = function(show)
    if show then
        MiniPill.Visible = false
        MenuAccess.Visible = false
        MainFrame.Visible = true
        MainFrame.Size = UDim2.fromOffset(120, 90)
        MainFrame.Position = UDim2.fromScale(0.5, 0.52)
        tween(MainFrame, 0.30, {
            Size = UDim2.fromOffset(winW, winH),
            Position = UDim2.fromScale(0.5, 0.5)
        }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        tween(MainFrame, 0.20, {
            Size = UDim2.fromOffset(120, 90),
            Position = UDim2.fromScale(0.5, 0.53)
        }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.delay(0.19, function()
            if MainFrame.Parent then
                MainFrame.Visible = false
            end
            MiniPill.Visible = true
            MenuAccess.Visible = true
        end)
    end
end

MenuAccess.Activated:Connect(function()
    toggleMenu(true)
end)

--// HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = CurrentTheme.HeaderBg
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local LogoBadge = Instance.new("Frame")
LogoBadge.Size = UDim2.fromOffset(26, 26)
LogoBadge.Position = UDim2.fromOffset(10, 8)
LogoBadge.BackgroundColor3 = CurrentTheme.CardBg
LogoBadge.BorderSizePixel = 0
LogoBadge.Parent = Header
addCorner(LogoBadge, 7)
addStroke(LogoBadge, CurrentTheme.Accent, 1)

local LogoTxt = Instance.new("TextLabel")
LogoTxt.Size = UDim2.fromScale(1, 1)
LogoTxt.BackgroundTransparency = 1
LogoTxt.Font = Enum.Font.GothamBlack
LogoTxt.Text = "N"
LogoTxt.TextSize = 13
LogoTxt.TextColor3 = CurrentTheme.Accent
LogoTxt.Parent = LogoBadge

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -90, 1, 0)
TitleLabel.Position = UDim2.fromOffset(44, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.Text = "NEXUS RIVAL | TACTICAL SHOOTER"
TitleLabel.TextSize = 11
TitleLabel.TextColor3 = CurrentTheme.Text
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(26, 26)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -13)
CloseBtn.BackgroundColor3 = CurrentTheme.CardBg
CloseBtn.BorderSizePixel = 0
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextSize = 11
CloseBtn.TextColor3 = CurrentTheme.Muted
CloseBtn.Parent = Header
addCorner(CloseBtn, 7)
addStroke(CloseBtn, CurrentTheme.Border, 1)
CloseBtn.Activated:Connect(function()
    toggleMenu(false)
end)

--// TABS
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 32)
TabBar.Position = UDim2.fromOffset(10, 48)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabListLayout.Padding = UDim.new(0, 8)
TabListLayout.Parent = TabBar

local TabButtons = {}
local TabPages = {}

local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -20, 1, -90)
PagesContainer.Position = UDim2.fromOffset(10, 84)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

local function createTabPage(tabId)
    local page = Instance.new("ScrollingFrame")
    page.Name = tabId .. "Page"
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.CanvasSize = UDim2.fromOffset(0, 1300)
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = CurrentTheme.Accent
    page.Visible = Config.ActiveTab == tabId
    page.Parent = PagesContainer

    local padding = Instance.new("UIPadding")
    padding.PaddingRight = UDim.new(0, 3)
    padding.Parent = page

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    TabPages[tabId] = page
    return page
end

local function switchTab(tabId)
    Config.ActiveTab = tabId
    for id, page in pairs(TabPages) do
        page.Visible = id == tabId
    end
    for id, btn in pairs(TabButtons) do
        if id == tabId then
            tween(btn, 0.18, {BackgroundColor3 = CurrentTheme.TabActive})
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            tween(btn, 0.18, {BackgroundColor3 = CurrentTheme.CardBg})
            btn.TextColor3 = CurrentTheme.Muted
        end
    end
end

local tabNames = {
    AIMBOT = "AIMBOT",
    RAGE = "RAGE",
    VISUALS = "VISUALS",
    STATUS = "STATUS",
    SETTINGS = "SETTINGS"
}

for internalName, displayName in pairs(tabNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.19, -4, 1, 0)
    btn.BackgroundColor3 = Config.ActiveTab == internalName
        and CurrentTheme.TabActive or CurrentTheme.CardBg
    btn.Font = Enum.Font.GothamBold
    btn.Text = displayName
    btn.TextSize = 9.5
    btn.TextColor3 = Config.ActiveTab == internalName
        and Color3.fromRGB(255, 255, 255) or CurrentTheme.Muted
    btn.Parent = TabBar
    addCorner(btn, 8)
    addStroke(btn, CurrentTheme.Border, 1)
    btn.Activated:Connect(function()
        switchTab(internalName)
    end)
    TabButtons[internalName] = btn
    createTabPage(internalName)
end

--// WIDGETS
local function createToggle(parent, titleText, defaultState, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -6, 0, 38)
    frame.BackgroundColor3 = CurrentTheme.CardBg
    frame.BorderSizePixel = 0
    frame.Parent = parent
    addCorner(frame, 9)
    local stroke = addStroke(frame, CurrentTheme.Border, 1)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.fromOffset(12, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = titleText
    title.TextSize = 9.5
    title.TextColor3 = CurrentTheme.Text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local pill = Instance.new("Frame")
    pill.Size = UDim2.fromOffset(46, 22)
    pill.Position = UDim2.new(1, -56, 0.5, -11)
    pill.BackgroundColor3 = defaultState and CurrentTheme.AccentSec or CurrentTheme.HeaderBg
    pill.BorderSizePixel = 0
    pill.Parent = frame
    addCorner(pill, 11)

    local switchCircle = Instance.new("Frame")
    switchCircle.Size = UDim2.fromOffset(16, 16)
    switchCircle.Position = defaultState
        and UDim2.new(1, -19, 0.5, -8)
        or UDim2.new(0, 3, 0.5, -8)
    switchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    switchCircle.BorderSizePixel = 0
    switchCircle.Parent = pill
    addCorner(switchCircle, 99)

    local state = defaultState
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromScale(1, 1)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = frame

    btn.Activated:Connect(function()
        state = not state
        if state then
            tween(pill, 0.18, {BackgroundColor3 = CurrentTheme.AccentSec})
            tween(switchCircle, 0.18, {
                Position = UDim2.new(1, -19, 0.5, -8)
            })
        else
            tween(pill, 0.18, {BackgroundColor3 = CurrentTheme.HeaderBg})
            tween(switchCircle, 0.18, {
                Position = UDim2.new(0, 3, 0.5, -8)
            })
        end
        pcall(callback, state)
    end)

    return {Frame = frame, Title = title, Stroke = stroke}
end

local function createActionButton(parent, titleText, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -6, 0, 38)
    frame.BackgroundColor3 = CurrentTheme.CardBg
    frame.BorderSizePixel = 0
    frame.Parent = parent
    addCorner(frame, 9)
    local stroke = addStroke(frame, CurrentTheme.Border, 1)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 1, -8)
    btn.Position = UDim2.fromOffset(6, 4)
    btn.BackgroundColor3 = CurrentTheme.HeaderBg
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.Text = titleText
    btn.TextSize = 9.5
    btn.TextColor3 = CurrentTheme.Accent
    btn.AutoButtonColor = false
    btn.Parent = frame
    addCorner(btn, 7)

    btn.MouseEnter:Connect(function()
        tween(btn, 0.12, {BackgroundColor3 = CurrentTheme.CardBg})
    end)

    btn.MouseLeave:Connect(function()
        tween(btn, 0.12, {BackgroundColor3 = CurrentTheme.HeaderBg})
    end)

    btn.Activated:Connect(function()
        pcall(callback, btn)
    end)

    return {Frame = frame, Button = btn, Stroke = stroke}
end

local function createSlider(parent, titleText, minVal, maxVal, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -6, 0, 50)
    frame.BackgroundColor3 = CurrentTheme.CardBg
    frame.BorderSizePixel = 0
    frame.Parent = parent
    addCorner(frame, 9)
    local stroke = addStroke(frame, CurrentTheme.Border, 1)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -70, 0, 20)
    title.Position = UDim2.fromOffset(12, 6)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = titleText
    title.TextSize = 9.5
    title.TextColor3 = CurrentTheme.Text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.fromOffset(50, 20)
    valLabel.Position = UDim2.new(1, -60, 0, 6)
    valLabel.BackgroundTransparency = 1
    valLabel.Font = Enum.Font.GothamBlack
    valLabel.Text = tostring(defaultVal)
    valLabel.TextSize = 9.5
    valLabel.TextColor3 = CurrentTheme.Accent
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -24, 0, 6)
    bar.Position = UDim2.new(0, 12, 0, 34)
    bar.BackgroundColor3 = CurrentTheme.HeaderBg
    bar.BorderSizePixel = 0
    bar.Parent = frame
    addCorner(bar, 3)

    local fill = Instance.new("Frame")
    local startRatio = (defaultVal - minVal) / math.max(maxVal - minVal, 1)
    fill.Size = UDim2.new(math.clamp(startRatio, 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = CurrentTheme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = bar
    addCorner(fill, 3)

    local hit = Instance.new("TextButton")
    hit.Size = UDim2.new(1, 20, 1, 20)
    hit.Position = UDim2.fromOffset(-10, -10)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.Parent = bar

    local draggingSlider = false
    local function update(input)
        local ratio = math.clamp(
            (input.Position.X - bar.AbsolutePosition.X)
            / math.max(bar.AbsoluteSize.X, 1),
            0, 1
        )
        local value = math.floor(minVal + (maxVal - minVal) * ratio + 0.5)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        valLabel.Text = tostring(value)
        pcall(callback, value)
    end

    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = true
            update(input)
        end
    end)

    table.insert(Cleanups, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            draggingSlider = false
        end
    end))

    table.insert(Cleanups, UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            update(input)
        end
    end))

    return {
        Frame = frame,
        Title = title,
        Stroke = stroke,
        ValLabel = valLabel
    }
end

local function createColorPicker(parent, titleText, initialColor, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -6, 0, 52)
    frame.BackgroundColor3 = CurrentTheme.CardBg
    frame.BorderSizePixel = 0
    frame.Parent = parent
    addCorner(frame, 9)
    local stroke = addStroke(frame, CurrentTheme.Border, 1)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.48, 0, 1, 0)
    title.Position = UDim2.fromOffset(12, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = titleText
    title.TextSize = 8.5
    title.TextColor3 = CurrentTheme.Text
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0.50, -10, 0, 24)
    holder.Position = UDim2.new(0.50, 4, 0.5, -12)
    holder.BackgroundTransparency = 1
    holder.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    layout.Padding = UDim.new(0, 6)
    layout.Parent = holder

    local buttons = {}
    for _, col in ipairs(PaletteSwatches) do
        local dot = Instance.new("TextButton")
        dot.Size = UDim2.fromOffset(20, 20)
        dot.BackgroundColor3 = col
        dot.Text = ""
        dot.BorderSizePixel = 0
        dot.Parent = holder
        addCorner(dot, 99)

        local dStroke = addStroke(
            dot,
            col == initialColor and Color3.fromRGB(255,255,255) or CurrentTheme.Border,
            col == initialColor and 1.6 or 0.8
        )

        dot.Activated:Connect(function()
            for _, info in ipairs(buttons) do
                info.Stroke.Color = CurrentTheme.Border
                info.Stroke.Thickness = 0.8
            end
            dStroke.Color = Color3.fromRGB(255,255,255)
            dStroke.Thickness = 1.6
            pcall(callback, col)
        end)

        table.insert(buttons, {Button = dot, Stroke = dStroke, Color = col})
    end

    return {Frame = frame, Title = title, Stroke = stroke}
end

--// AIMBOT UI
local aimPage = TabPages.AIMBOT

createToggle(aimPage, "STICKY AIMBOT LOCK", Config.Aimbot.Enabled, function(state)
    Config.Aimbot.Enabled = state
    if not state then
        StickyTargetPlayer = nil
        StickyTargetPart = nil
        smoothedAimPos = nil
    end
end)

createToggle(aimPage, "AUTO FIRE", Config.Aimbot.AutoFire, function(state)
    Config.Aimbot.AutoFire = state
end)

createSlider(aimPage, "AIM RESPONSE", 1, 100, Config.Aimbot.AimResponse, function(value)
    Config.Aimbot.AimResponse = value
    Config.Aimbot.Smoothness = value / 100
end)

createToggle(aimPage, "HEAD HITBOX EXPANDER", Config.Aimbot.HitboxExpander, function(state)
    Config.Aimbot.HitboxExpander = state
end)

createSlider(aimPage, "HITBOX EXPANSION SIZE", 2, 25, Config.Aimbot.HitboxSize, function(value)
    Config.Aimbot.HitboxSize = value
end)

createToggle(aimPage, "NO RECOIL / STABILIZER", Config.Aimbot.NoRecoil, function(state)
    Config.Aimbot.NoRecoil = state
end)

createSlider(aimPage, "AIM FOV RADIUS", 30, 450, Config.Aimbot.FOV, function(value)
    Config.Aimbot.FOV = value
    FOVCircleFrame.Size = UDim2.fromOffset(value * 2, value * 2)
end)

createToggle(aimPage, "DRAW FOV CIRCLE", Config.Aimbot.DrawFOV, function(state)
    Config.Aimbot.DrawFOV = state
    FOVCircleFrame.Visible = state
end)

createToggle(aimPage, "WALL VISIBILITY CHECK", Config.Aimbot.VisibilityCheck, function(state)
    Config.Aimbot.VisibilityCheck = state
end)

createToggle(aimPage, "IGNORE TEAMMATES (AIMBOT)", Config.Aimbot.TeamCheck, function(state)
    Config.Aimbot.TeamCheck = state
end)

createToggle(aimPage, "USE REMOTE FIRE ADAPTER", Config.Weapon.UseRemoteFire, function(state)
    Config.Weapon.UseRemoteFire = state
end)

local boneFrame = Instance.new("Frame")
boneFrame.Size = UDim2.new(1, -6, 0, 38)
boneFrame.BackgroundColor3 = CurrentTheme.CardBg
boneFrame.BorderSizePixel = 0
boneFrame.Parent = aimPage
addCorner(boneFrame, 9)
addStroke(boneFrame, CurrentTheme.Border, 1)

local boneTitle = Instance.new("TextLabel")
boneTitle.Size = UDim2.new(1, -120, 1, 0)
boneTitle.Position = UDim2.fromOffset(12, 0)
boneTitle.BackgroundTransparency = 1
boneTitle.Font = Enum.Font.GothamBold
boneTitle.Text = "TARGET BODY PART"
boneTitle.TextSize = 9.5
boneTitle.TextColor3 = CurrentTheme.Text
boneTitle.TextXAlignment = Enum.TextXAlignment.Left
boneTitle.Parent = boneFrame

local boneBtn = Instance.new("TextButton")
boneBtn.Size = UDim2.fromOffset(105, 24)
boneBtn.Position = UDim2.new(1, -112, 0.5, -12)
boneBtn.BackgroundColor3 = CurrentTheme.HeaderBg
boneBtn.Font = Enum.Font.GothamBlack
boneBtn.Text = "HEAD"
boneBtn.TextSize = 9
boneBtn.TextColor3 = CurrentTheme.Accent
boneBtn.Parent = boneFrame
addCorner(boneBtn, 6)
addStroke(boneBtn, CurrentTheme.Border, 1)

local bodyPartsCycle = {"Head", "Torso", "Legs"}
local currentPartIndex = 1
local function updateBoneBtnText()
    local partName = bodyPartsCycle[currentPartIndex]
    Config.Aimbot.TargetPart = partName
    boneBtn.Text = string.upper(partName)
end
boneBtn.Activated:Connect(function()
    currentPartIndex = (currentPartIndex % #bodyPartsCycle) + 1
    updateBoneBtnText()
end)

--// RAGE UI
local ragePage = TabPages.RAGE

createToggle(ragePage, "AUTO TELEPORT TO ENEMY", Config.Teleport.Enabled, function(state)
    Config.Teleport.Enabled = state
    if state then
        startAutoTeleport()
    else
        stopAutoTeleport()
    end
end)

createSlider(ragePage, "TELEPORT HEIGHT", 6, 25, Config.Teleport.OffsetY, function(value)
    Config.Teleport.OffsetY = value
end)

createSlider(ragePage, "TARGET SWITCH DELAY", 0.05, 0.50, Config.Teleport.SwitchDelay, function(value)
    Config.Teleport.SwitchDelay = value
end)

createSlider(ragePage, "AUTO FIRE RATE", 1, 30, Config.Weapon.FireRate, function(value)
    Config.Weapon.FireRate = value
end)

createToggle(ragePage, "RAPID FIRE — ANY WEAPON", Config.Weapon.RapidFire, function(state)
    Config.Weapon.RapidFire = state
end)

createSlider(ragePage, "RAPID FIRE RATE", 10, 60, Config.Weapon.RapidFireRate, function(value)
    Config.Weapon.RapidFireRate = value
end)

createToggle(ragePage, "INFINITE AMMO", Config.Weapon.InfiniteAmmo, function(state)
    Config.Weapon.InfiniteAmmo = state
end)

createSlider(ragePage, "AMMO REFRESH", 0.03, 0.20, Config.Weapon.AmmoRefreshInterval, function(value)
    Config.Weapon.AmmoRefreshInterval = value
end)

--// VISUALS UI
local espPage = TabPages.VISUALS
createToggle(espPage, "MASTER 2D VISUALS (ESP)", Config.ESP.Enabled, function(state)
    Config.ESP.Enabled = state
end)
createToggle(espPage, "2D BOUNDING BOXES", Config.ESP.Boxes, function(state)
    Config.ESP.Boxes = state
end)
createToggle(espPage, "SKELETON ESP (BONES)", Config.ESP.Skeleton, function(state)
    Config.ESP.Skeleton = state
end)
createToggle(espPage, "SNAPLINES (TRACERS)", Config.ESP.Snaplines, function(state)
    Config.ESP.Snaplines = state
end)
createToggle(espPage, "PLAYER NAMES", Config.ESP.Names, function(state)
    Config.ESP.Names = state
end)
createToggle(espPage, "DISTANCE DISPLAY", Config.ESP.Distance, function(state)
    Config.ESP.Distance = state
end)
createToggle(espPage, "DYNAMIC HEALTH BAR", Config.ESP.HealthBar, function(state)
    Config.ESP.HealthBar = state
end)
createToggle(espPage, "IGNORE TEAMMATES (ESP)", Config.ESP.TeamCheck, function(state)
    Config.ESP.TeamCheck = state
end)
createColorPicker(espPage, "BOX COLOR PALETTE", Config.ESP.BoxColor, function(c)
    Config.ESP.BoxColor = c
end)
createColorPicker(espPage, "SKELETON COLOR PALETTE", Config.ESP.SkeletonColor, function(c)
    Config.ESP.SkeletonColor = c
end)
createColorPicker(espPage, "TRACER COLOR PALETTE", Config.ESP.TracerColor, function(c)
    Config.ESP.TracerColor = c
end)

--// TARGET ENGINE
local function resolveTargetPart(char, partMode)
    if not char then
        return nil
    end
    if partMode == "Head" then
        return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    elseif partMode == "Torso" then
        return char:FindFirstChild("UpperTorso")
            or char:FindFirstChild("Torso")
            or char:FindFirstChild("HumanoidRootPart")
    elseif partMode == "Legs" then
        return char:FindFirstChild("LeftUpperLeg")
            or char:FindFirstChild("RightUpperLeg")
            or char:FindFirstChild("LowerTorso")
            or char:FindFirstChild("HumanoidRootPart")
    end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
end

local function isAimVisible(cam, part, character)
    if not Config.Aimbot.VisibilityCheck then
        return true
    end
    if not cam or not part or not character then
        return false
    end

    local origin = cam.CFrame.Position
    local direction = part.Position - origin
    if direction.Magnitude <= 0.05 then
        return true
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true

    local ignore = {LocalPlayer.Character, cam}
    params.FilterDescendantsInstances = ignore

    local currentOrigin = origin
    local remaining = direction

    for _ = 1, 6 do
        local hit = workspace:Raycast(currentOrigin, remaining, params)
        if not hit then
            return true
        end
        if hit.Instance:IsDescendantOf(character) then
            return true
        end

        local inst = hit.Instance
        local parent = inst.Parent
        local nameLower = string.lower(inst.Name)
        local passThrough =
            inst.CanCollide == false
            or inst.Transparency >= 0.5
            or inst:IsA("Accessory")
            or (parent and parent:IsA("Accessory"))
            or nameLower:find("trigger")
            or nameLower:find("zone")
            or nameLower:find("clip")
            or nameLower:find("barrier")

        if not passThrough then
            return false
        end

        table.insert(ignore, inst)
        params.FilterDescendantsInstances = ignore
        local unit = remaining.Unit
        currentOrigin = hit.Position + unit * 0.05
        remaining = part.Position - currentOrigin
    end

    return false
end

local function getCurrentCamera()
    local cam = workspace.CurrentCamera
    if cam then
        Camera = cam
    end
    return Camera
end

local function clearTargetLock()
    StickyTargetPlayer = nil
    StickyTargetPart = nil
    smoothedAimPos = nil
end

local function getAimPart(player)
    if not player or not player.Character then
        return nil
    end
    return resolveTargetPart(player.Character, Config.Aimbot.TargetPart)
end

local function isValidAimPlayer(player)
    if not player or player == LocalPlayer then
        return false
    end
    local char = player.Character
    if not char then
        return false
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then
        return false
    end
    if Config.Aimbot.TeamCheck and isTeammate(player) then
        return false
    end
    return getAimPart(player) ~= nil
end

--// FOV CENTER FIX
-- The UI circle and target acquisition now use the exact same viewport center.
local function getViewportCenter(cam)
    local viewport = cam and cam.ViewportSize or Vector2.new(800, 600)
    return Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
end

local function updateFOVPosition(cam)
    if not FOVCircleFrame or not cam then
        return
    end

    local viewport = cam.ViewportSize
    local center = getViewportCenter(cam)

    FOVCircleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    FOVCircleFrame.Position = UDim2.fromOffset(center.X, center.Y)
    FOVCircleFrame.Size = UDim2.fromOffset(
        Config.Aimbot.FOV * 2,
        Config.Aimbot.FOV * 2
    )

    -- Keep size valid after viewport/device changes.
    if viewport.X <= 0 or viewport.Y <= 0 then
        FOVCircleFrame.Visible = false
    else
        FOVCircleFrame.Visible = Config.Aimbot.DrawFOV
    end
end

local function getScreenDistance(cam, worldPosition)
    if not cam then
        return math.huge, false
    end

    local center = getViewportCenter(cam)
    local screenPos, onScreen = cam:WorldToViewportPoint(worldPosition)

    if not onScreen or screenPos.Z <= 0 then
        return math.huge, false
    end

    local delta = Vector2.new(screenPos.X, screenPos.Y) - center
    return delta.Magnitude, true
end

local function getPredictedPosition(player, part, cam)
    if not part then
        return nil
    end

    local position = part.Position
    local character = player and player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not root or not cam then
        return position
    end

    local velocity = root.AssemblyLinearVelocity
    if velocity.Magnitude < 2 then
        return position
    end

    local distance = (position - cam.CFrame.Position).Magnitude
    local leadTime = math.clamp(distance / 4500, 0.008, MAX_LEAD_TIME)
    return position + velocity * leadTime
end

local function acquireBestTarget(cam)
    local bestPlayer = nil
    local bestPart = nil
    local bestScore = math.huge

    for _, enemy in ipairs(Players:GetPlayers()) do
        if isValidAimPlayer(enemy) then
            local part = getAimPart(enemy)
            if part then
                local screenDist, onScreen = getScreenDistance(cam, part.Position)
                if onScreen and screenDist <= Config.Aimbot.FOV then
                    if isAimVisible(cam, part, enemy.Character) then
                        local worldDist = (part.Position - cam.CFrame.Position).Magnitude
                        if worldDist <= Config.Weapon.FireRange then
                            local score = screenDist + worldDist * 0.001
                            if score < bestScore then
                                bestScore = score
                                bestPlayer = enemy
                                bestPart = part
                            end
                        end
                    end
                end
            end
        end
    end

    return bestPlayer, bestPart
end

local function updateLockedTarget()
    if not StickyTargetPlayer then
        return false
    end
    if not isValidAimPlayer(StickyTargetPlayer) then
        clearTargetLock()
        return false
    end
    StickyTargetPart = getAimPart(StickyTargetPlayer)
    if not StickyTargetPart then
        clearTargetLock()
        return false
    end
    return true
end

--// AUTO TELEPORT
local TeleportTargetPlayer = nil
local TeleportTargetCharacter = nil
local TeleportTargetDeathConnection = nil
local TeleportTargetCharacterAddedConnection = nil
local LastTeleportTime = 0
local LastTargetSwitchTime = 0
local TeleportBusy = false
local CameraStabilizeUntil = 0
local CameraStabilizeTarget = nil
local CameraStabilizeConnection = nil
local startAutoTeleport
local stopAutoTeleport

local function disconnectTeleportConnections()
    if TeleportTargetDeathConnection then
        pcall(function()
            TeleportTargetDeathConnection:Disconnect()
        end)
        TeleportTargetDeathConnection = nil
    end

    if TeleportTargetCharacterAddedConnection then
        pcall(function()
            TeleportTargetCharacterAddedConnection:Disconnect()
        end)
        TeleportTargetCharacterAddedConnection = nil
    end
end

local function getTeleportCharacter(player)
    return player and player.Character or nil
end

local function getTeleportHumanoid(player)
    local character = getTeleportCharacter(player)
    return character and character:FindFirstChildOfClass("Humanoid") or nil
end

local function getTeleportRoot(player)
    local character = getTeleportCharacter(player)
    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
        or character.PrimaryPart
end

local function isValidTeleportTarget(player)
    if not player or player == LocalPlayer then
        return false
    end

    if Config.Aimbot.TeamCheck and isTeammate(player) then
        return false
    end

    local character = getTeleportCharacter(player)
    local humanoid = getTeleportHumanoid(player)
    local root = getTeleportRoot(player)

    if not character or not humanoid or humanoid.Health <= 0 or not root then
        return false
    end

    return true
end

local function getMyRoot()
    local character = LocalPlayer.Character
    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
        or character.PrimaryPart
end

local function acquireTeleportTarget(excludePlayer)
    local myRoot = getMyRoot()
    local myPosition = myRoot and myRoot.Position

    local bestPlayer = nil
    local bestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= excludePlayer and isValidTeleportTarget(player) then
            local root = getTeleportRoot(player)
            if root then
                local distance

                if myPosition then
                    distance = (root.Position - myPosition).Magnitude
                else
                    local cam = getCurrentCamera()
                    distance = cam
                        and (root.Position - cam.CFrame.Position).Magnitude
                        or math.huge
                end

                if distance < bestDistance then
                    bestDistance = distance
                    bestPlayer = player
                end
            end
        end
    end

    return bestPlayer
end

local function stabilizeCameraOnTarget(player, duration)
    CameraStabilizeUntil = os.clock() + (duration or 0.28)
    CameraStabilizeTarget = player
end

local function stopCameraStabilization()
    CameraStabilizeUntil = 0
    CameraStabilizeTarget = nil
end

-- Runs after normal camera scripts, preventing the short shake caused by a
-- sudden PivotTo while immediately looking at the selected enemy.
CameraStabilizeConnection = RunService:BindToRenderStep("NexusTeleportCameraStabilizer", Enum.RenderPriority.Last.Value + 20, function()
    if CameraStabilizeUntil <= os.clock() then
        return
    end

    local cam = getCurrentCamera()
    local target = CameraStabilizeTarget
    local part = target and getAimPart(target)
    if not cam or not part then
        return
    end

    local camPos = cam.CFrame.Position
    cam.CFrame = CFrame.lookAt(camPos, part.Position)
end)

table.insert(Cleanups, function()
    stopCameraStabilization()
    pcall(function()
        RunService:UnbindFromRenderStep("NexusTeleportCameraStabilizer")
    end)
end)

local function isTeleportSpaceFree(position, ignoreCharacters)
    local size = Vector3.new(3.8, 6.0, 3.8)
    local overlap = OverlapParams.new()
    overlap.FilterType = Enum.RaycastFilterType.Exclude
    overlap.FilterDescendantsInstances = ignoreCharacters or {}

    local ok, parts = pcall(function()
        return workspace:GetPartBoundsInBox(CFrame.new(position), size, overlap)
    end)
    if not ok or not parts then
        return false
    end

    for _, part in ipairs(parts) do
        if part and part:IsA("BasePart") then
            if part.CanCollide and part.Transparency < 0.95 then
                return false
            end
        end
    end
    return true
end

local function hasTeleportLineOfSight(fromPosition, targetPart, ignoreCharacters)
    if not targetPart then
        return false
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.IgnoreWater = true
    local ignore = {}
    for _, item in ipairs(ignoreCharacters or {}) do
        table.insert(ignore, item)
    end
    params.FilterDescendantsInstances = ignore

    local origin = fromPosition + Vector3.new(0, 0.5, 0)
    local remaining = targetPart.Position - origin
    for _ = 1, 5 do
        if remaining.Magnitude <= 0.15 then
            return true
        end
        local hit = workspace:Raycast(origin, remaining, params)
        if not hit then
            return true
        end
        if hit.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        end
        local inst = hit.Instance
        local parent = inst.Parent
        local passThrough =
            inst.CanCollide == false
            or inst.Transparency >= 0.5
            or inst:IsA("Accessory")
            or (parent and parent:IsA("Accessory"))
        if not passThrough then
            return false
        end
        table.insert(ignore, inst)
        params.FilterDescendantsInstances = ignore
        origin = hit.Position + remaining.Unit * 0.05
        remaining = targetPart.Position - origin
    end
    return false
end

local function getSafeTeleportPosition(targetPlayer)
    local targetCharacter = getTeleportCharacter(targetPlayer)
    local targetRoot = getTeleportRoot(targetPlayer)
    if not targetCharacter or not targetRoot then
        return nil
    end

    local targetPart = getAimPart(targetPlayer) or targetRoot
    local myCharacter = LocalPlayer.Character
    local ignore = {targetCharacter}
    if myCharacter then
        table.insert(ignore, myCharacter)
    end

    local base = targetRoot.Position
    local offsets = {
        Vector3.new(0, Config.Teleport.OffsetY, 0),
        Vector3.new(0, Config.Teleport.OffsetY + 5, 0),
        Vector3.new(0, Config.Teleport.OffsetY + 10, 0),
        Vector3.new(0, 25, 0),
        Vector3.new(0, 30, 0),
        Vector3.new(8, 8, 0), Vector3.new(-8, 8, 0),
        Vector3.new(0, 8, 8), Vector3.new(0, 8, -8),
        Vector3.new(8, 6, 8), Vector3.new(-8, 6, 8),
        Vector3.new(8, 6, -8), Vector3.new(-8, 6, -8),
        Vector3.new(12, 10, 0), Vector3.new(-12, 10, 0),
        Vector3.new(0, 10, 12), Vector3.new(0, 10, -12),
        Vector3.new(10, 5, 0), Vector3.new(-10, 5, 0),
        Vector3.new(0, 5, 10), Vector3.new(0, 5, -10),
    }

    local preferred = base + offsets[1]
    if isTeleportSpaceFree(preferred, ignore) and hasTeleportLineOfSight(preferred, targetPart, ignore) then
        return preferred
    end

    local bestVisible, bestVisibleScore
    local bestFree, bestFreeScore
    for i, offset in ipairs(offsets) do
        local pos = base + offset
        if isTeleportSpaceFree(pos, ignore) then
            local verticalPenalty = math.abs(offset.Y - Config.Teleport.OffsetY)
            local distancePenalty = math.abs(offset.X) + math.abs(offset.Z)
            local score = verticalPenalty * 2 + distancePenalty + i * 0.05

            if not bestFreeScore or score < bestFreeScore then
                bestFree = pos
                bestFreeScore = score
            end

            if hasTeleportLineOfSight(pos, targetPart, ignore) then
                if not bestVisibleScore or score < bestVisibleScore then
                    bestVisible = pos
                    bestVisibleScore = score
                end
            end
        end
    end

    return bestVisible or bestFree or preferred
end

local function performTeleport(player)
    if not Config.Teleport.Enabled then
        return false
    end

    if not isValidTeleportTarget(player) then
        return false
    end

    local myCharacter = LocalPlayer.Character
    local myRoot = getMyRoot()
    local targetRoot = getTeleportRoot(player)

    if not myCharacter or not myRoot or not targetRoot then
        return false
    end

    local now = os.clock()
    if now - LastTeleportTime < 0.12 then
        return false
    end

    LastTeleportTime = now

    local targetPosition = getSafeTeleportPosition(player) or (targetRoot.Position + Vector3.new(0, Config.Teleport.OffsetY, 0))
    local targetCFrame = CFrame.lookAt(targetPosition, getAimPart(player) and getAimPart(player).Position or targetRoot.Position)

    -- Prefer the server teleport adapter in an own/test game.
    -- It only moves the character; the weapon attack below is what handles damage.
    if Config.Teleport.UseServerRemote and NexusTeleportRemote then
        stabilizeCameraOnTarget(player, 0.35)

        local ok = pcall(function()
            NexusTeleportRemote:FireServer(player)
        end)
        if ok then
            StickyTargetPlayer = player
            StickyTargetPart = getAimPart(player)
            smoothedAimPos = StickyTargetPart and StickyTargetPart.Position or nil
            startTeleportWeaponAttack(player)
            return true
        end
    end

    -- Fallback for local/test environments without the server adapter.
    local ok = pcall(function()
        myCharacter:PivotTo(targetCFrame)
    end)

    if not ok then
        ok = pcall(function()
            myRoot.CFrame = targetCFrame
        end)
    end

    if ok then
        StickyTargetPlayer = player
        StickyTargetPart = getAimPart(player)
        smoothedAimPos = StickyTargetPart and StickyTargetPart.Position or nil
        stabilizeCameraOnTarget(player, 0.35)
        startTeleportWeaponAttack(player)
    end

    return ok
end

local function clearTeleportTarget()
    disconnectTeleportConnections()
    TeleportTargetPlayer = nil
    TeleportTargetCharacter = nil
end

local function selectAndTeleportNext(excludePlayer)
    if not Config.Teleport.Enabled then
        return false
    end

    local now = os.clock()
    if now - LastTargetSwitchTime < math.max(Config.Teleport.SwitchDelay, 0) then
        return false
    end

    local nextTarget = acquireTeleportTarget(excludePlayer)
    if not nextTarget then
        clearTeleportTarget()
        return false
    end

    LastTargetSwitchTime = now
    clearTeleportTarget()

    TeleportTargetPlayer = nextTarget
    TeleportTargetCharacter = nextTarget.Character

    local humanoid = getTeleportHumanoid(nextTarget)
    if humanoid then
        TeleportTargetDeathConnection = humanoid.Died:Connect(function()
            task.delay(math.max(Config.Teleport.SwitchDelay, 0), function()
                if Config.Teleport.Enabled and TeleportTargetPlayer == nextTarget then
                    clearTeleportTarget()
                    selectAndTeleportNext(nextTarget)
                end
            end)
        end)
    end

    -- Some games replace Character without immediately destroying the Player.
    TeleportTargetCharacterAddedConnection = nextTarget.CharacterAdded:Connect(function(newCharacter)
        if not Config.Teleport.Enabled or TeleportTargetPlayer ~= nextTarget then
            return
        end

        task.defer(function()
            if TeleportTargetPlayer ~= nextTarget then
                return
            end

            TeleportTargetCharacter = newCharacter
            disconnectTeleportConnections()

            -- Rebind to the new character's Humanoid.
            local newHumanoid = newCharacter:FindFirstChildOfClass("Humanoid")
                or newCharacter:WaitForChild("Humanoid", 2)

            if newHumanoid then
                TeleportTargetDeathConnection = newHumanoid.Died:Connect(function()
                    task.delay(math.max(Config.Teleport.SwitchDelay, 0), function()
                        if Config.Teleport.Enabled and TeleportTargetPlayer == nextTarget then
                            clearTeleportTarget()
                            selectAndTeleportNext(nextTarget)
                        end
                    end)
                end)
            end
        end)
    end)

    task.defer(function()
        if Config.Teleport.Enabled and TeleportTargetPlayer == nextTarget then
            local didTeleport = performTeleport(nextTarget)
            if didTeleport then
                StickyTargetPlayer = nextTarget
                StickyTargetPart = getAimPart(nextTarget)
                smoothedAimPos = StickyTargetPart and StickyTargetPart.Position or nil
            end
        end
    end)

    return true
end

local function ensureTeleportTarget()
    if not Config.Teleport.Enabled or TeleportBusy then
        return
    end

    TeleportBusy = true

    local current = TeleportTargetPlayer

    if current and isValidTeleportTarget(current) then
        -- Keep following the selected target's current position.
        performTeleport(current)
        TeleportBusy = false
        return
    end

    clearTeleportTarget()
    selectAndTeleportNext(current)

    TeleportBusy = false
end

stopAutoTeleport = function()
    TeleportAttackToken += 1
    disconnectTeleportConnections()
    TeleportTargetPlayer = nil
    TeleportTargetCharacter = nil
    LastTeleportTime = 0
    LastTargetSwitchTime = 0
    TeleportBusy = false
    stopCameraStabilization()
end

startAutoTeleport = function()
    stopAutoTeleport()

    if not Config.Teleport.Enabled then
        return
    end

    task.defer(function()
        if Config.Teleport.Enabled then
            ensureTeleportTarget()
        end
    end)
end

table.insert(Cleanups, stopAutoTeleport)

table.insert(Cleanups, RunService.Heartbeat:Connect(function()
    if not Config.Teleport.Enabled then
        return
    end

    ensureTeleportTarget()
end))

--// AUTO FIRE / TELEPORT ATTACK
local function getEquippedTool()
    local character = LocalPlayer.Character
    if not character then
        return nil
    end
    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            return child
        end
    end
    return nil
end

local function readBoolSetting(tool, names)
    for _, name in ipairs(names) do
        local attr = tool:GetAttribute(name)
        if typeof(attr) == "boolean" then
            return attr
        end

        local obj = tool:FindFirstChild(name, true)
        if obj and obj:IsA("BoolValue") then
            return obj.Value
        end
    end
    return nil
end

local function readStringSetting(tool, names)
    for _, name in ipairs(names) do
        local attr = tool:GetAttribute(name)
        if typeof(attr) == "string" then
            return attr
        end

        local obj = tool:FindFirstChild(name, true)
        if obj and obj:IsA("StringValue") then
            return obj.Value
        end
    end
    return nil
end

local function getWeaponFireMode(tool)
    if not tool then
        return "semi"
    end

    local explicitAutomatic = readBoolSetting(tool, {"Automatic", "IsAutomatic", "FullAuto"})
    if explicitAutomatic ~= nil then
        return explicitAutomatic and "auto" or "semi"
    end

    if Config.Weapon.AutoDetectFireMode then
        local mode = readStringSetting(tool, {"FireMode", "Mode", "ShootingMode"})
        if mode then
            mode = string.lower(mode)
            if mode:find("auto", 1, true) or mode:find("full", 1, true) then
                return "auto"
            end
            if mode:find("semi", 1, true) or mode:find("single", 1, true) or mode:find("bolt", 1, true) then
                return "semi"
            end
        end
    end

    return Config.Weapon.DefaultAutomatic and "auto" or "semi"
end

local function activateEquippedWeapon(targetPosition)
    local tool = getEquippedTool()
    if not tool then
        return false
    end

    if Config.Weapon.UseRemoteFire and FireWeaponRemote then
        local success = pcall(function()
            FireWeaponRemote:FireServer(targetPosition)
        end)
        if success then
            return true
        end
    end

    return pcall(function()
        tool:Activate()
    end)
end

local AMMO_NAME_HINTS = {
    ammo = true,
    currentammo = true,
    ammoinmag = true,
    magazineammo = true,
    clipammo = true,
    clip = true,
    bullets = true,
    rounds = true,
    shells = true,
    reserveammo = true,
    spareammo = true,
    totalammo = true
}

local function isAmmoName(name)
    name = string.lower(name or "")
    return AMMO_NAME_HINTS[name] == true
end

local function refreshAmmoObject(obj)
    if not obj then
        return
    end

    local valueType = obj:IsA("IntValue") and "IntValue" or (obj:IsA("NumberValue") and "NumberValue" or nil)
    if valueType and isAmmoName(obj.Name) then
        pcall(function()
            obj.Value = 999
        end)
    end
end

local function refreshAmmoAttributes(tool)
    if not tool then
        return
    end

    for name, value in pairs(tool:GetAttributes()) do
        if isAmmoName(name) and (typeof(value) == "number") then
            pcall(function()
                tool:SetAttribute(name, 999)
            end)
        end
    end
end

local function refreshInfiniteAmmo()
    if not Config.Weapon.InfiniteAmmo then
        return
    end

    local tool = getEquippedTool()
    if not tool then
        return
    end

    refreshAmmoAttributes(tool)
    for _, obj in ipairs(tool:GetDescendants()) do
        refreshAmmoObject(obj)
    end
end

local function getRapidFireInterval()
    local rate = math.max(1, Config.Weapon.RapidFire and Config.Weapon.RapidFireRate or Config.Weapon.FireRate)
    return 1 / rate
end

local InfiniteAmmoAccumulator = 0
local InfiniteAmmoConnection = RunService.Heartbeat:Connect(function(dt)
    if not Config.Weapon.InfiniteAmmo then
        InfiniteAmmoAccumulator = 0
        return
    end

    InfiniteAmmoAccumulator += dt
    local interval = math.max(0.03, tonumber(Config.Weapon.AmmoRefreshInterval) or 0.08)
    if InfiniteAmmoAccumulator >= interval then
        InfiniteAmmoAccumulator = 0
        refreshInfiniteAmmo()
    end
end)
table.insert(Cleanups, InfiniteAmmoConnection)

local function fireEquippedWeapon(targetPosition)
    local tool = getEquippedTool()
    if not tool then
        return false
    end

    local now = os.clock()
    local fireInterval = getRapidFireInterval()
    if now - LastFireTime < fireInterval then
        return false
    end
    LastFireTime = now

    return activateEquippedWeapon(targetPosition)
end

startTeleportWeaponAttack = function(targetPlayer)
    TeleportAttackToken += 1
    local myToken = TeleportAttackToken

    if not targetPlayer or not isValidAimPlayer(targetPlayer) then
        return
    end

    StickyTargetPlayer = targetPlayer
    StickyTargetPart = getAimPart(targetPlayer)
    smoothedAimPos = StickyTargetPart and StickyTargetPart.Position or nil

    -- First shot is immediate: the camera stabilizer + aim engine already point
    -- at the target, so there is no deliberate waiting for normal smoothing.
    task.defer(function()
        if myToken ~= TeleportAttackToken then
            return
        end

        local part = getAimPart(targetPlayer)
        if not part or not isValidAimPlayer(targetPlayer) then
            return
        end

        local pos = part.Position
        smoothedAimPos = pos
        local cam = getCurrentCamera()
        if cam then
            cam.CFrame = CFrame.lookAt(cam.CFrame.Position, pos)
        end

        activateEquippedWeapon(pos)

        local tool = getEquippedTool()
        local mode = getWeaponFireMode(tool)
        if mode ~= "auto" then
            return
        end

        -- Safe local rapid-fire path:
        -- only calls the equipped Tool's normal Activate() method.
        -- It does not bypass server-side ammo, damage, or fire-rate checks.
        local rapidEnabled = Config.Weapon.RapidFire
        local shouldBurst = rapidEnabled or mode == "auto"
        if not shouldBurst then
            return
        end

        local finishAt = os.clock() + math.max(Config.Weapon.TeleportBurstDuration, 0.1)
        local requestedRate = rapidEnabled and Config.Weapon.RapidFireRate or Config.Weapon.TeleportAutoFireRate
        local rate = math.clamp(tonumber(requestedRate) or 12, 1, Config.Weapon.SafeRapidMaxRate)
        local interval = 1 / rate

        while myToken == TeleportAttackToken and os.clock() < finishAt do
            if not Config.Teleport.Enabled or not isValidAimPlayer(targetPlayer) then
                break
            end

            local currentPart = getAimPart(targetPlayer)
            if not currentPart then
                break
            end

            local currentPos = currentPart.Position
            -- Small smoothing keeps the aim stable without producing large camera jumps.
            smoothedAimPos = smoothedAimPos and smoothedAimPos:Lerp(currentPos, 0.65) or currentPos
            activateEquippedWeapon(smoothedAimPos)
            task.wait(interval)
        end
    end)
end

--// AIM + AUTO FIRE ENGINE
RunService:BindToRenderStep(
    "NexusAimEngine",
    Enum.RenderPriority.Last.Value + 1,
    function(dt)
        local cam = getCurrentCamera()
        if not cam then
            return
        end

        -- FOV POSITION IS UPDATED FROM THE SAME VIEWPORT CENTER USED BY AIM.
        if FOVCircleFrame then
            updateFOVPosition(cam)
            if Config.Settings.RainbowFOV then
                local hue = (os.clock() * 0.4) % 1
                FOVStroke.Color = Color3.fromHSV(hue, 0.85, 1)
            else
                FOVStroke.Color = CurrentTheme.Accent
            end
        end

        if not Config.Aimbot.Enabled then
            clearTargetLock()
            return
        end

        if not updateLockedTarget() then
            StickyTargetPlayer, StickyTargetPart = acquireBestTarget(cam)
            if not StickyTargetPlayer or not StickyTargetPart then
                return
            end
            smoothedAimPos = StickyTargetPart.Position
        end

        local targetPlayer = StickyTargetPlayer
        local targetPart = StickyTargetPart
        if not targetPlayer or not targetPart then
            return
        end

        if Config.Aimbot.VisibilityCheck
            and not isAimVisible(cam, targetPart, targetPlayer.Character) then
            local replacementPlayer, replacementPart = acquireBestTarget(cam)
            if replacementPlayer and replacementPart then
                StickyTargetPlayer = replacementPlayer
                StickyTargetPart = replacementPart
                smoothedAimPos = replacementPart.Position
                targetPlayer = replacementPlayer
                targetPart = replacementPart
            else
                smoothedAimPos = nil
                return
            end
        end

        local targetPos = getPredictedPosition(targetPlayer, targetPart, cam)
        if not targetPos then
            return
        end

        if Config.Aimbot.TargetPart == "Torso" then
            targetPos += Vector3.new(0, 0.12, 0)
        elseif Config.Aimbot.TargetPart == "Legs" then
            targetPos += Vector3.new(0, 0.05, 0)
        end

        local camPos = cam.CFrame.Position
        local toTarget = targetPos - camPos
        if toTarget.Magnitude > 0.05 then
            local response = math.clamp(Config.Aimbot.AimResponse, 1, 100)
            local alpha = 1 - math.exp(-dt * (response * 18))

            if response >= 95 then
                cam.CFrame = CFrame.lookAt(camPos, targetPos)
            else
                if not smoothedAimPos then
                    smoothedAimPos = targetPos
                else
                    smoothedAimPos = smoothedAimPos:Lerp(targetPos, alpha)
                end

                local finalVec = smoothedAimPos - camPos
                if finalVec.Magnitude > 0.05 then
                    cam.CFrame = CFrame.lookAt(camPos, smoothedAimPos)
                end
            end
        end

        if Config.Aimbot.AutoFire then
            local distance = (targetPart.Position - cam.CFrame.Position).Magnitude
            if distance <= Config.Weapon.FireRange then
                fireEquippedWeapon(targetPos)
            end
        end
    end
)

--// ESP
local ESPWidgets = {}

local function getPlayerBones(char)
    if not char then
        return nil
    end

    local isR15 = char:FindFirstChild("UpperTorso") ~= nil
    if isR15 then
        local upperTorso = char:FindFirstChild("UpperTorso")
        local lowerTorso = char:FindFirstChild("LowerTorso")
        return {
            {char:FindFirstChild("Head"), upperTorso},
            {upperTorso, lowerTorso},
            {upperTorso, char:FindFirstChild("LeftUpperArm")},
            {char:FindFirstChild("LeftUpperArm"), char:FindFirstChild("LeftLowerArm")},
            {char:FindFirstChild("LeftLowerArm"), char:FindFirstChild("LeftHand")},
            {upperTorso, char:FindFirstChild("RightUpperArm")},
            {char:FindFirstChild("RightUpperArm"), char:FindFirstChild("RightLowerArm")},
            {char:FindFirstChild("RightLowerArm"), char:FindFirstChild("RightHand")},
            {lowerTorso, char:FindFirstChild("LeftUpperLeg")},
            {char:FindFirstChild("LeftUpperLeg"), char:FindFirstChild("LeftLowerLeg")},
            {lowerTorso, char:FindFirstChild("RightUpperLeg")},
            {char:FindFirstChild("RightUpperLeg"), char:FindFirstChild("RightLowerLeg")}
        }
    end

    local torso = char:FindFirstChild("Torso")
    if not torso then
        return nil
    end

    return {
        {char:FindFirstChild("Head"), torso},
        {torso, char:FindFirstChild("Left Arm")},
        {torso, char:FindFirstChild("Right Arm")},
        {torso, char:FindFirstChild("Left Leg")},
        {torso, char:FindFirstChild("Right Leg")}
    }
end

local function createPlayerESPWidget(player)
    if player == LocalPlayer then
        return
    end

    local widget = {
        Player = player,
        Box = Instance.new("Frame"),
        Tracer = Instance.new("Frame"),
        NameLabel = Instance.new("TextLabel"),
        DistLabel = Instance.new("TextLabel"),
        HealthBg = Instance.new("Frame"),
        HealthFill = nil,
        SkeletonLines = {}
    }

    widget.Box.BackgroundTransparency = 1
    widget.Box.BorderSizePixel = 0
    widget.Box.Visible = false
    widget.Box.Parent = ESPDrawContainer
    widget.BoxStroke = addStroke(widget.Box, Config.ESP.BoxColor, 1.4)

    widget.Tracer.AnchorPoint = Vector2.new(0.5, 0.5)
    widget.Tracer.BorderSizePixel = 0
    widget.Tracer.BackgroundColor3 = Config.ESP.TracerColor
    widget.Tracer.Visible = false
    widget.Tracer.Parent = ESPDrawContainer

    widget.NameLabel.BackgroundTransparency = 1
    widget.NameLabel.Font = Enum.Font.GothamBlack
    widget.NameLabel.Text = player.DisplayName
    widget.NameLabel.TextSize = 10
    widget.NameLabel.TextColor3 = CurrentTheme.Text
    widget.NameLabel.TextStrokeTransparency = 0.3
    widget.NameLabel.Visible = false
    widget.NameLabel.Parent = ESPDrawContainer

    widget.DistLabel.BackgroundTransparency = 1
    widget.DistLabel.Font = Enum.Font.GothamBold
    widget.DistLabel.Text = "[0m]"
    widget.DistLabel.TextSize = 9
    widget.DistLabel.TextColor3 = CurrentTheme.Accent
    widget.DistLabel.TextStrokeTransparency = 0.3
    widget.DistLabel.Visible = false
    widget.DistLabel.Parent = ESPDrawContainer

    widget.HealthBg.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    widget.HealthBg.BorderSizePixel = 0
    widget.HealthBg.Visible = false
    widget.HealthBg.Parent = ESPDrawContainer
    addCorner(widget.HealthBg, 2)

    widget.HealthFill = Instance.new("Frame")
    widget.HealthFill.Size = UDim2.fromScale(1, 1)
    widget.HealthFill.BackgroundColor3 = CurrentTheme.AccentSec
    widget.HealthFill.BorderSizePixel = 0
    widget.HealthFill.Parent = widget.HealthBg
    addCorner(widget.HealthFill, 2)

    for _ = 1, 14 do
        local line = Instance.new("Frame")
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.BorderSizePixel = 0
        line.BackgroundColor3 = Config.ESP.SkeletonColor
        line.Visible = false
        line.Parent = ESPDrawContainer
        table.insert(widget.SkeletonLines, line)
    end

    ESPWidgets[player] = widget
end

local function hideESPWidget(widget)
    widget.Box.Visible = false
    widget.Tracer.Visible = false
    widget.NameLabel.Visible = false
    widget.DistLabel.Visible = false
    widget.HealthBg.Visible = false
    for _, line in ipairs(widget.SkeletonLines) do
        line.Visible = false
    end
end

local function removePlayerESPWidget(player)
    local widget = ESPWidgets[player]
    if not widget then
        return
    end
    pcall(function()
        widget.Box:Destroy()
        widget.Tracer:Destroy()
        widget.NameLabel:Destroy()
        widget.DistLabel:Destroy()
        widget.HealthBg:Destroy()
        for _, line in ipairs(widget.SkeletonLines) do
            line:Destroy()
        end
    end)
    ESPWidgets[player] = nil
end

for _, player in ipairs(Players:GetPlayers()) do
    createPlayerESPWidget(player)
end

table.insert(Cleanups, Players.PlayerAdded:Connect(createPlayerESPWidget))
table.insert(Cleanups, Players.PlayerRemoving:Connect(removePlayerESPWidget))

RunService:BindToRenderStep(
    "NexusESPEngine",
    Enum.RenderPriority.Camera.Value + 2,
    function()
        local cam = Camera
        if not cam then
            return
        end

        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local screenBottom = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)

        for player, widget in pairs(ESPWidgets) do
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            local allied = isTeammate(player)

            if not Config.ESP.Enabled
                or not char
                or not hum
                or hum.Health <= 0
                or not root
                or not head
                or (Config.ESP.TeamCheck and allied) then
                hideESPWidget(widget)
                continue
            end

            local rootScreen, onScreenRoot = cam:WorldToViewportPoint(root.Position)
            local headScreen, onScreenHead = cam:WorldToViewportPoint(
                head.Position + Vector3.new(0, 0.6, 0)
            )
            local legScreen = cam:WorldToViewportPoint(
                root.Position - Vector3.new(0, 2.8, 0)
            )

            if not ((onScreenRoot or onScreenHead) and rootScreen.Z > 0 and headScreen.Z > 0) then
                hideESPWidget(widget)
                continue
            end

            local boxHeight = math.abs(headScreen.Y - legScreen.Y)
            local boxWidth = math.clamp(boxHeight * 0.65, 12, 400)
            local boxPos = Vector2.new(
                rootScreen.X - boxWidth / 2,
                math.min(headScreen.Y, legScreen.Y)
            )

            if Config.ESP.Boxes then
                widget.Box.Visible = true
                widget.Box.Size = UDim2.fromOffset(boxWidth, boxHeight)
                widget.Box.Position = UDim2.fromOffset(boxPos.X, boxPos.Y)
                widget.BoxStroke.Color = player == StickyTargetPlayer
                    and Color3.fromRGB(255, 220, 0)
                    or Config.ESP.BoxColor
            else
                widget.Box.Visible = false
            end

            if Config.ESP.Skeleton then
                local bones = getPlayerBones(char)
                local boneIndex = 1
                if bones then
                    for _, pair in ipairs(bones) do
                        local p1, p2 = pair[1], pair[2]
                        if p1 and p2 then
                            local s1, on1 = cam:WorldToViewportPoint(p1.Position)
                            local s2, on2 = cam:WorldToViewportPoint(p2.Position)
                            if (on1 or on2) and s1.Z > 0 and s2.Z > 0 then
                                local v1 = Vector2.new(s1.X, s1.Y)
                                local v2 = Vector2.new(s2.X, s2.Y)
                                local delta = v2 - v1
                                local distance = delta.Magnitude
                                local angle = math.deg(math.atan2(delta.Y, delta.X))
                                local midpoint = (v1 + v2) / 2
                                local line = widget.SkeletonLines[boneIndex]
                                if line then
                                    line.Visible = true
                                    line.Size = UDim2.fromOffset(distance, 1.4)
                                    line.Position = UDim2.fromOffset(midpoint.X, midpoint.Y)
                                    line.Rotation = angle
                                    line.BackgroundColor3 = player == StickyTargetPlayer
                                        and Color3.fromRGB(255, 220, 0)
                                        or Config.ESP.SkeletonColor
                                    boneIndex += 1
                                end
                            end
                        end
                    end
                end
                for i = boneIndex, #widget.SkeletonLines do
                    widget.SkeletonLines[i].Visible = false
                end
            else
                for _, line in ipairs(widget.SkeletonLines) do
                    line.Visible = false
                end
            end

            if Config.ESP.Snaplines then
                local targetPoint = Vector2.new(rootScreen.X, legScreen.Y)
                local delta = targetPoint - screenBottom
                local distance = delta.Magnitude
                local angle = math.deg(math.atan2(delta.Y, delta.X))
                local midpoint = (screenBottom + targetPoint) / 2
                widget.Tracer.Visible = true
                widget.Tracer.Size = UDim2.fromOffset(distance, 1.4)
                widget.Tracer.Position = UDim2.fromOffset(midpoint.X, midpoint.Y)
                widget.Tracer.Rotation = angle
                widget.Tracer.BackgroundColor3 = player == StickyTargetPlayer
                    and Color3.fromRGB(255, 220, 0)
                    or Config.ESP.TracerColor
            else
                widget.Tracer.Visible = false
            end

            if Config.ESP.Names then
                widget.NameLabel.Visible = true
                widget.NameLabel.Position = UDim2.fromOffset(boxPos.X, boxPos.Y - 14)
                widget.NameLabel.Size = UDim2.fromOffset(boxWidth, 14)
            else
                widget.NameLabel.Visible = false
            end

            if Config.ESP.Distance and myRoot then
                local studs = math.floor((myRoot.Position - root.Position).Magnitude)
                widget.DistLabel.Visible = true
                widget.DistLabel.Text = string.format("[%dm]", studs)
                widget.DistLabel.Position = UDim2.fromOffset(boxPos.X, boxPos.Y + boxHeight + 1)
                widget.DistLabel.Size = UDim2.fromOffset(boxWidth, 12)
            else
                widget.DistLabel.Visible = false
            end

            if Config.ESP.HealthBar then
                widget.HealthBg.Visible = true
                widget.HealthBg.Size = UDim2.fromOffset(3.5, boxHeight)
                widget.HealthBg.Position = UDim2.fromOffset(boxPos.X - 6, boxPos.Y)
                local ratio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                widget.HealthFill.Size = UDim2.fromScale(1, ratio)
                widget.HealthFill.Position = UDim2.fromScale(0, 1 - ratio)
                if ratio > 0.5 then
                    widget.HealthFill.BackgroundColor3 = CurrentTheme.AccentSec
                elseif ratio > 0.25 then
                    widget.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
                else
                    widget.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 45, 60)
                end
            else
                widget.HealthBg.Visible = false
            end
        end
    end
)

--// STATUS PAGE
local statusPage = TabPages.STATUS

local function makeCard(parent, height)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, -6, 0, height)
    card.BackgroundColor3 = CurrentTheme.CardBg
    card.BorderSizePixel = 0
    card.Parent = parent
    addCorner(card, 10)
    addStroke(card, CurrentTheme.Border, 1)
    return card
end

local profileCard = makeCard(statusPage, 70)
local avatarImg = Instance.new("ImageLabel")
avatarImg.Size = UDim2.fromOffset(48, 48)
avatarImg.Position = UDim2.fromOffset(10, 11)
avatarImg.BackgroundColor3 = CurrentTheme.HeaderBg
avatarImg.BorderSizePixel = 0
avatarImg.ScaleType = Enum.ScaleType.Fit
avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
avatarImg.Parent = profileCard
addCorner(avatarImg, 8)
addStroke(avatarImg, CurrentTheme.Border, 1)

local uName = Instance.new("TextLabel")
uName.Size = UDim2.new(1, -80, 0, 18)
uName.Position = UDim2.fromOffset(68, 10)
uName.BackgroundTransparency = 1
uName.Font = Enum.Font.GothamBlack
uName.Text = LocalPlayer.DisplayName
uName.TextSize = 12
uName.TextColor3 = CurrentTheme.Text
uName.TextXAlignment = Enum.TextXAlignment.Left
uName.Parent = profileCard

local uHandle = Instance.new("TextLabel")
uHandle.Size = UDim2.new(1, -80, 0, 14)
uHandle.Position = UDim2.fromOffset(68, 28)
uHandle.BackgroundTransparency = 1
uHandle.Font = Enum.Font.GothamMedium
uHandle.Text = "@" .. LocalPlayer.Name
uHandle.TextSize = 8.5
uHandle.TextColor3 = CurrentTheme.Muted
uHandle.TextXAlignment = Enum.TextXAlignment.Left
uHandle.Parent = profileCard

local isPremium = LocalPlayer.MembershipType == Enum.MembershipType.Premium
local uTag = Instance.new("TextLabel")
uTag.Size = UDim2.fromOffset(100, 15)
uTag.Position = UDim2.fromOffset(68, 46)
uTag.BackgroundColor3 = isPremium and Color3.fromRGB(245,180,40) or CurrentTheme.HeaderBg
uTag.Font = Enum.Font.GothamBold
uTag.Text = isPremium and "PREMIUM" or "VERIFIED CLIENT"
uTag.TextSize = 7.5
uTag.TextColor3 = isPremium and Color3.fromRGB(15,15,15) or CurrentTheme.Accent
uTag.Parent = profileCard
addCorner(uTag, 4)

local deviceCard = makeCard(statusPage, 64)
local deviceLayout = Instance.new("UIGridLayout")
deviceLayout.CellSize = UDim2.new(0.32, -4, 0, 48)
deviceLayout.CellPadding = UDim2.new(0.02, 0, 0, 6)
deviceLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
deviceLayout.VerticalAlignment = Enum.VerticalAlignment.Center
deviceLayout.Parent = deviceCard

local function makeTelemetryCard(parent, titleText, initialValue, textColor)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = CurrentTheme.HeaderBg
    card.BorderSizePixel = 0
    card.Parent = parent
    addCorner(card, 7)
    addStroke(card, CurrentTheme.Border, 1)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -6, 0, 15)
    title.Position = UDim2.fromOffset(3, 4)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = titleText
    title.TextSize = 7.2
    title.TextColor3 = CurrentTheme.Muted
    title.Parent = card

    local value = Instance.new("TextLabel")
    value.Size = UDim2.new(1, -6, 0, 22)
    value.Position = UDim2.fromOffset(3, 19)
    value.BackgroundTransparency = 1
    value.Font = Enum.Font.GothamBlack
    value.Text = initialValue
    value.TextSize = 9.5
    value.TextColor3 = textColor
    value.Parent = card

    return {Box = card, Title = title, Value = value}
end

local DeviceInfo = {Platform = "Unknown", Resolution = "Unknown", Input = "Unknown"}
pcall(function()
    local platform = UserInputService:GetPlatform()
    DeviceInfo.Platform = tostring(platform):gsub("Enum%.Platform%.", "")
end)
pcall(function()
    local size = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(800,600)
    DeviceInfo.Resolution = string.format("%dx%d", math.floor(size.X), math.floor(size.Y))
end)
pcall(function()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
        DeviceInfo.Input = "Touch"
    elseif UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then
        DeviceInfo.Input = "Keyboard + Mouse"
    elseif UserInputService.GamepadEnabled then
        DeviceInfo.Input = "Gamepad"
    end
end)

local platformCard = makeTelemetryCard(deviceCard, "PLATFORM / OS", DeviceInfo.Platform, CurrentTheme.Accent)
local resCard = makeTelemetryCard(deviceCard, "SCREEN RESOLUTION", DeviceInfo.Resolution, CurrentTheme.AccentSec)
local inputCard = makeTelemetryCard(deviceCard, "PRIMARY INPUT", DeviceInfo.Input, Color3.fromRGB(245,190,60))

local metricsFrame = makeCard(statusPage, 64)
local metricsLayout = Instance.new("UIGridLayout")
metricsLayout.CellSize = UDim2.new(0.32, -4, 0, 48)
metricsLayout.CellPadding = UDim2.new(0.02, 0, 0, 6)
metricsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
metricsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
metricsLayout.Parent = metricsFrame

local fpsCard = makeTelemetryCard(metricsFrame, "FRAME RATE", "60", CurrentTheme.AccentSec)
local pingCard = makeTelemetryCard(metricsFrame, "NETWORK PING", "35ms", CurrentTheme.Accent)
local memCard = makeTelemetryCard(metricsFrame, "TOTAL MEMORY", "150MB", Color3.fromRGB(240,180,50))

local targetTelemetryFrame = makeCard(statusPage, 68)
local targetHeader = Instance.new("TextLabel")
targetHeader.Size = UDim2.new(1, -20, 0, 18)
targetHeader.Position = UDim2.fromOffset(12, 5)
targetHeader.BackgroundTransparency = 1
targetHeader.Font = Enum.Font.GothamBlack
targetHeader.Text = "LOCKED TARGET TELEMETRY"
targetHeader.TextSize = 9.5
targetHeader.TextColor3 = CurrentTheme.Text
targetHeader.TextXAlignment = Enum.TextXAlignment.Left
targetHeader.Parent = targetTelemetryFrame

local targetStatusText = Instance.new("TextLabel")
targetStatusText.Size = UDim2.new(1, -24, 0, 16)
targetStatusText.Position = UDim2.fromOffset(12, 24)
targetStatusText.BackgroundTransparency = 1
targetStatusText.Font = Enum.Font.GothamBold
targetStatusText.Text = "NO ACTIVE LOCK"
targetStatusText.TextSize = 9
targetStatusText.TextColor3 = CurrentTheme.Muted
targetStatusText.Parent = targetTelemetryFrame

local targetHealthBarBg = Instance.new("Frame")
targetHealthBarBg.Size = UDim2.new(1, -24, 0, 6)
targetHealthBarBg.Position = UDim2.fromOffset(12, 46)
targetHealthBarBg.BackgroundColor3 = CurrentTheme.HeaderBg
targetHealthBarBg.BorderSizePixel = 0
targetHealthBarBg.Parent = targetTelemetryFrame
addCorner(targetHealthBarBg, 3)

local targetHealthBarFill = Instance.new("Frame")
targetHealthBarFill.Size = UDim2.fromScale(0, 1)
targetHealthBarFill.BackgroundColor3 = CurrentTheme.AccentSec
targetHealthBarFill.BorderSizePixel = 0
targetHealthBarFill.Parent = targetHealthBarBg
addCorner(targetHealthBarFill, 3)

local actionButtonsRow = Instance.new("Frame")
actionButtonsRow.Size = UDim2.new(1, -6, 0, 36)
actionButtonsRow.BackgroundTransparency = 1
actionButtonsRow.Parent = statusPage

local copyJobBtn = Instance.new("TextButton")
copyJobBtn.Size = UDim2.new(0.48, -4, 1, 0)
copyJobBtn.BackgroundColor3 = CurrentTheme.CardBg
copyJobBtn.Font = Enum.Font.GothamBold
copyJobBtn.Text = "COPY SERVER ID"
copyJobBtn.TextSize = 8.5
copyJobBtn.TextColor3 = CurrentTheme.Accent
copyJobBtn.Parent = actionButtonsRow
addCorner(copyJobBtn, 8)
addStroke(copyJobBtn, CurrentTheme.Border, 1)
copyJobBtn.Activated:Connect(function()
    copyClipboard(tostring(game.JobId))
    copyJobBtn.Text = "COPIED!"
    task.delay(1.5, function()
        if copyJobBtn.Parent then
            copyJobBtn.Text = "COPY SERVER ID"
        end
    end)
end)

local rejoinBtn = Instance.new("TextButton")
rejoinBtn.Size = UDim2.new(0.48, -4, 1, 0)
rejoinBtn.Position = UDim2.new(0.52, 4, 0, 0)
rejoinBtn.BackgroundColor3 = CurrentTheme.CardBg
rejoinBtn.Font = Enum.Font.GothamBold
rejoinBtn.Text = "REJOIN SERVER"
rejoinBtn.TextSize = 8.5
rejoinBtn.TextColor3 = CurrentTheme.AccentSec
rejoinBtn.Parent = actionButtonsRow
addCorner(rejoinBtn, 8)
addStroke(rejoinBtn, CurrentTheme.Border, 1)
rejoinBtn.Activated:Connect(function()
    if #Players:GetPlayers() <= 1 then
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    else
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
    end
end)

--// SETTINGS PAGE
local settingsPage = TabPages.SETTINGS
createToggle(settingsPage, "SCREEN HUD WATERMARK", Config.Settings.Watermark, function(state)
    Config.Settings.Watermark = state
    WatermarkFrame.Visible = state
end)
createToggle(settingsPage, "RGB RAINBOW FOV CIRCLE", Config.Settings.RainbowFOV, function(state)
    Config.Settings.RainbowFOV = state
end)

local themeGroup = makeCard(settingsPage, 68)
local themeTitle = Instance.new("TextLabel")
themeTitle.Size = UDim2.new(1, -20, 0, 20)
themeTitle.Position = UDim2.fromOffset(10, 6)
themeTitle.BackgroundTransparency = 1
themeTitle.Font = Enum.Font.GothamBlack
themeTitle.Text = "SELECT UI THEME"
themeTitle.TextSize = 9.5
themeTitle.TextColor3 = CurrentTheme.Text
themeTitle.TextXAlignment = Enum.TextXAlignment.Left
themeTitle.Parent = themeGroup

local themeRow = Instance.new("Frame")
themeRow.Size = UDim2.new(1, -20, 0, 30)
themeRow.Position = UDim2.fromOffset(10, 28)
themeRow.BackgroundTransparency = 1
themeRow.Parent = themeGroup
local themeListLayout = Instance.new("UIListLayout")
themeListLayout.FillDirection = Enum.FillDirection.Horizontal
themeListLayout.Padding = UDim.new(0, 8)
themeListLayout.Parent = themeRow

local function applyTheme(themeObj)
    CurrentTheme = themeObj
    MainFrame.BackgroundColor3 = CurrentTheme.Bg
    MainStroke.Color = CurrentTheme.Accent
    TopNeon.BackgroundColor3 = CurrentTheme.Accent
    Header.BackgroundColor3 = CurrentTheme.HeaderBg
    MiniPill.BackgroundColor3 = CurrentTheme.HeaderBg
    PillStroke.Color = CurrentTheme.Accent
    PillDot.BackgroundColor3 = CurrentTheme.AccentSec
    LogoBadge.BackgroundColor3 = CurrentTheme.CardBg
    LogoTxt.TextColor3 = CurrentTheme.Accent
    CloseBtn.BackgroundColor3 = CurrentTheme.CardBg
    WatermarkTxt.TextColor3 = CurrentTheme.Accent
    WatermarkFrame.BackgroundColor3 = CurrentTheme.HeaderBg
    TgCard.BackgroundColor3 = CurrentTheme.HeaderBg
    TgCopyBtn.BackgroundColor3 = CurrentTheme.Accent
    MenuAccess.BackgroundColor3 = CurrentTheme.HeaderBg
    MenuAccess.TextColor3 = CurrentTheme.Accent
    FOVStroke.Color = CurrentTheme.Accent
    switchTab(Config.ActiveTab)
end

for _, themeKey in ipairs({"CyberNeon", "CrimsonBlood", "PurpleVoid"}) do
    local theme = Themes[themeKey]
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.32, -4, 1, 0)
    button.BackgroundColor3 = theme.CardBg
    button.Font = Enum.Font.GothamBold
    button.Text = theme.Name
    button.TextSize = 8.5
    button.TextColor3 = theme.Accent
    button.Parent = themeRow
    addCorner(button, 7)
    addStroke(button, theme.Accent, 1)
    button.Activated:Connect(function()
        applyTheme(theme)
    end)
end

local configRow = Instance.new("Frame")
configRow.Size = UDim2.new(1, -6, 0, 36)
configRow.BackgroundTransparency = 1
configRow.Parent = settingsPage

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(0.48, -4, 1, 0)
saveBtn.BackgroundColor3 = CurrentTheme.CardBg
saveBtn.Font = Enum.Font.GothamBold
saveBtn.Text = "SAVE CONFIG"
saveBtn.TextSize = 8.5
saveBtn.TextColor3 = CurrentTheme.AccentSec
saveBtn.Parent = configRow
addCorner(saveBtn, 8)
addStroke(saveBtn, CurrentTheme.Border, 1)
saveBtn.Activated:Connect(function()
    saveConfig()
    saveBtn.Text = "SAVED!"
    task.delay(1.2, function()
        if saveBtn.Parent then
            saveBtn.Text = "SAVE CONFIG"
        end
    end)
end)

local loadBtn = Instance.new("TextButton")
loadBtn.Size = UDim2.new(0.48, -4, 1, 0)
loadBtn.Position = UDim2.new(0.52, 4, 0, 0)
loadBtn.BackgroundColor3 = CurrentTheme.CardBg
loadBtn.Font = Enum.Font.GothamBold
loadBtn.Text = "LOAD CONFIG"
loadBtn.TextSize = 8.5
loadBtn.TextColor3 = CurrentTheme.Accent
loadBtn.Parent = configRow
addCorner(loadBtn, 8)
addStroke(loadBtn, CurrentTheme.Border, 1)
loadBtn.Activated:Connect(function()
    loadConfig()

    if Config.Teleport.Enabled then
        startAutoTeleport()
    else
        stopAutoTeleport()
    end

    loadBtn.Text = "LOADED!"
    task.delay(1.2, function()
        if loadBtn.Parent then
            loadBtn.Text = "LOAD CONFIG"
        end
    end)
end)

local resetRow = Instance.new("Frame")
resetRow.Size = UDim2.new(1, -6, 0, 36)
resetRow.BackgroundTransparency = 1
resetRow.Parent = settingsPage

local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0.48, -4, 1, 0)
resetBtn.BackgroundColor3 = CurrentTheme.CardBg
resetBtn.Font = Enum.Font.GothamBold
resetBtn.Text = "RESET DEFAULTS"
resetBtn.TextSize = 8.5
resetBtn.TextColor3 = CurrentTheme.Text
resetBtn.Parent = resetRow
addCorner(resetBtn, 8)
addStroke(resetBtn, CurrentTheme.Border, 1)
resetBtn.Activated:Connect(function()
    Config.Aimbot.Enabled = false
    Config.Aimbot.AutoFire = false
    Config.Aimbot.HitboxExpander = false
    Config.Aimbot.HitboxSize = 10
    Config.Aimbot.NoRecoil = true
    Config.Aimbot.Smoothness = 1
    Config.Aimbot.AimResponse = 78
    Config.Aimbot.FOV = 150
    Config.Aimbot.DrawFOV = true
    Config.Aimbot.TargetPart = "Head"

    Config.Weapon.FireRate = 12
    Config.Weapon.FireRange = 1000
    Config.Weapon.UseRemoteFire = false
    Config.Weapon.AutoDetectFireMode = true
    Config.Weapon.DefaultAutomatic = false
    Config.Weapon.RapidFire = false
    Config.Weapon.RapidFireRate = 45
    Config.Weapon.InfiniteAmmo = false
    Config.Weapon.AmmoRefreshInterval = 0.08
    Config.Weapon.TeleportBurstDuration = 0.65
    Config.Weapon.TeleportAutoFireRate = 16
    Config.Weapon.SafeRapidMaxRate = 60

    Config.ESP.Enabled = false
    Config.ESP.Boxes = true
    Config.ESP.Skeleton = true
    Config.ESP.Snaplines = true
    Config.ESP.Names = true
    Config.ESP.Distance = true
    Config.ESP.HealthBar = true
    Config.ESP.TeamCheck = true

    Config.Teleport.Enabled = false
    Config.Teleport.OffsetY = 15
    Config.Teleport.SwitchDelay = 0.15
    stopAutoTeleport()

    Config.Settings.RainbowFOV = false

    clearTargetLock()
    FOVCircleFrame.Size = UDim2.fromOffset(300, 300)
    updateFOVPosition(getCurrentCamera())

    resetBtn.Text = "DONE!"
    task.delay(1.2, function()
        if resetBtn.Parent then
            resetBtn.Text = "RESET DEFAULTS"
        end
    end)
end)

local unloadBtn = Instance.new("TextButton")
unloadBtn.Size = UDim2.new(0.48, -4, 1, 0)
unloadBtn.Position = UDim2.new(0.52, 4, 0, 0)
unloadBtn.BackgroundColor3 = Color3.fromRGB(45,18,24)
unloadBtn.Font = Enum.Font.GothamBold
unloadBtn.Text = "UNLOAD HUB"
unloadBtn.TextSize = 8.5
unloadBtn.TextColor3 = Color3.fromRGB(255,75,95)
unloadBtn.Parent = resetRow
addCorner(unloadBtn, 8)
addStroke(unloadBtn, Color3.fromRGB(80,25,35), 1)
unloadBtn.Activated:Connect(function()
    if _G.NexusShooterCleanup then
        _G.NexusShooterCleanup()
    end
end)

--// MINI PILL DRAGGING
local isPillDragging = false
local pillDragStart = Vector2.zero
local pillStartPos = UDim2.new()
local hasPillMoved = false

PillBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        isPillDragging = true
        hasPillMoved = false
        pillDragStart = Vector2.new(input.Position.X, input.Position.Y)
        pillStartPos = MiniPill.Position
    end
end)

table.insert(Cleanups, UserInputService.InputChanged:Connect(function(input)
    if isPillDragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = Vector2.new(input.Position.X, input.Position.Y) - pillDragStart
        if delta.Magnitude > 7 then
            hasPillMoved = true
        end

        local newX = pillStartPos.X.Offset + delta.X
        local newY = pillStartPos.Y.Offset + delta.Y
        local curVp = Camera and Camera.ViewportSize or Vector2.new(800, 600)

        MiniPill.Position = UDim2.new(
            pillStartPos.X.Scale,
            math.clamp(newX, -(curVp.X * 0.5) + 70, (curVp.X * 0.5) - 70),
            pillStartPos.Y.Scale,
            math.clamp(newY, 10, curVp.Y - 50)
        )
    end
end))

local function finishPillDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        if isPillDragging then
            isPillDragging = false
            if not hasPillMoved then
                toggleMenu(true)
            end
        end
    end
end

PillBtn.InputEnded:Connect(finishPillDrag)
table.insert(Cleanups, UserInputService.InputEnded:Connect(finishPillDrag))
PillBtn.Activated:Connect(function()
    toggleMenu(true)
end)

--// TELEGRAM POPUP RESTORE
task.defer(function()
    pcall(function()
        if TgCard and TgCard.Parent then
            TgCard.Visible = true
            TgCard.Position = UDim2.new(1, 300, 0, 50)
            tween(TgCard, 0.55, {
                Position = UDim2.new(1, -280, 0, 50)
            }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end)
end)

--// START TELEPORT FEATURE FROM LOADED CONFIG
pcall(function()
    if Config.Teleport.Enabled then
        startAutoTeleport()
    end
end)

--// FORCE MAIN MENU VISIBILITY
pcall(function()
    RootScreen.Enabled = true
    MainFrame.Visible = true
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.Size = UDim2.fromOffset(winW, winH)
    MiniPill.Visible = false
    MenuAccess.Visible = false
    updateFOVPosition(getCurrentCamera())
end)

--// RUNTIME TELEMETRY
local frameCount = 0
local lastSample = os.clock()

table.insert(Cleanups, RunService.RenderStepped:Connect(function()
    frameCount += 1
    local now = os.clock()
    local elapsed = now - lastSample
    if elapsed < 0.5 then
        return
    end

    local currentFPS = math.floor(frameCount / elapsed + 0.5)
    fpsCard.Value.Text = tostring(currentFPS)

    local pingValue = 35
    pcall(function()
        local item = StatsService.Network.ServerStatsItem["Data Ping"]
        if item then
            pingValue = math.floor(item:GetValue())
        end
    end)
    pingCard.Value.Text = tostring(pingValue) .. "ms"

    local memoryMb = 150
    pcall(function()
        memoryMb = math.floor(StatsService:GetTotalMemoryUsageMb())
    end)
    memCard.Value.Text = tostring(memoryMb) .. "MB"

    local viewport = Camera and Camera.ViewportSize or Vector2.new(800, 600)
    resCard.Value.Text = string.format("%dx%d", math.floor(viewport.X), math.floor(viewport.Y))

    if Config.Settings.Watermark then
        WatermarkTxt.Text = string.format("NEXUS | %d FPS | %dms", currentFPS, pingValue)
    end

    if StickyTargetPlayer and StickyTargetPlayer.Character then
        local hum = StickyTargetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            targetStatusText.Text = string.format("LOCKED: %s", StickyTargetPlayer.DisplayName)
            targetStatusText.TextColor3 = CurrentTheme.AccentSec
            local ratio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
            targetHealthBarFill.Size = UDim2.fromScale(ratio, 1)
        else
            targetStatusText.Text = "NO ACTIVE LOCK"
            targetStatusText.TextColor3 = CurrentTheme.Muted
            targetHealthBarFill.Size = UDim2.fromScale(0, 1)
        end
    else
        targetStatusText.Text = "NO ACTIVE LOCK"
        targetStatusText.TextColor3 = CurrentTheme.Muted
        targetHealthBarFill.Size = UDim2.fromScale(0, 1)
    end

    frameCount = 0
    lastSample = now
end))

print("[NEXUS SUPREME] Execution complete. FOV alignment fix loaded.")
