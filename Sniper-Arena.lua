-- Sniper Arena v2.1
-- ESP/AIM lifecycle fix:
--  * Rebinds character references on every respawn.
--  * Invalidates stale character models immediately.
--  * Revalidates players/characters periodically and on PlayerAdded/CharacterAdded.
--  * Never targets a dead/removed character.
--  * Cleans ESP objects when a character is removed.
--  * Avoids accumulating CharacterAdded connections on repeated setup.
--
-- NOTE: Core ESP/AIM logic is retained; UI/config code is kept compatible.

--// MULTI-RUN CLEANUP
if _G.ShutV6Cleanup then
    pcall(_G.ShutV6Cleanup)
end

local Cleanups = {}
_G.ShutV6Cleanup = function()
    for _, item in ipairs(Cleanups) do
        pcall(function()
            if typeof(item) == "RBXScriptConnection" then
                item:Disconnect()
            elseif typeof(item) == "Instance" then
                item:Destroy()
            end
        end)
    end
    pcall(function()
        game:GetService("RunService"):UnbindFromRenderStep("ShutAimEngine")
    end)
end

--// SERVICES
local function safeService(name)
    local s = game:GetService(name)
    return (cloneref and cloneref(s)) or s
end

local Players = safeService("Players")
local RunService = safeService("RunService")
local UIS = safeService("UserInputService")
local TweenService = safeService("TweenService")
local SoundService = safeService("SoundService")
local HttpService = safeService("HttpService")
local VIM = safeService("VirtualInputManager")

local LocalPlayer = (cloneref and cloneref(Players.LocalPlayer)) or Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// BRAND
local SHUT_NAME = "Sniper Arena"
local SHUT_VERSION = "v2.2"
local TELEGRAM_URL = "https://t.me/+qTcgFmViTe9jMzU6"
local CONFIG_FILE = "SniperArena_Config.json"

--// THEMES
local Themes = {
    Purple  = {Accent = Color3.fromRGB(180,95,255), Accent2 = Color3.fromRGB(105,145,255), Accent3 = Color3.fromRGB(255,80,195)},
    Cyan    = {Accent = Color3.fromRGB(0,235,255), Accent2 = Color3.fromRGB(60,140,255), Accent3 = Color3.fromRGB(0,255,190)},
    Emerald = {Accent = Color3.fromRGB(65,245,135), Accent2 = Color3.fromRGB(35,190,210), Accent3 = Color3.fromRGB(170,255,95)},
    Crimson = {Accent = Color3.fromRGB(255,65,90), Accent2 = Color3.fromRGB(255,125,55), Accent3 = Color3.fromRGB(255,45,145)},
    Gold    = {Accent = Color3.fromRGB(255,190,50), Accent2 = Color3.fromRGB(255,115,45), Accent3 = Color3.fromRGB(255,235,95)}
}

local C = {
    Background = Color3.fromRGB(10,10,16),
    Panel = Color3.fromRGB(14,14,23),
    Panel2 = Color3.fromRGB(20,19,31),
    CardOff = Color3.fromRGB(20,19,28),
    CardOn = Color3.fromRGB(28,24,42),
    Card = Color3.fromRGB(24,22,35),
    Card2 = Color3.fromRGB(32,29,46),
    Hover = Color3.fromRGB(42,38,62),
    StrokeOff = Color3.fromRGB(55,50,75),
    Stroke = Color3.fromRGB(72,64,96),
    White = Color3.fromRGB(255,255,255),
    Text = Color3.fromRGB(235,232,246),
    Sub = Color3.fromRGB(160,155,180),
    Muted = Color3.fromRGB(110,105,130),
    Accent = Themes.Purple.Accent,
    Accent2 = Themes.Purple.Accent2,
    Accent3 = Themes.Purple.Accent3,
    Green = Color3.fromRGB(79,225,134),
    Yellow = Color3.fromRGB(245,195,88),
    Red = Color3.fromRGB(240,84,105)
}

--// CONFIG
local Config = {
    ESP = {
        Enabled = true, Box = true, Name = true, Health = true, Distance = true,
        Tracer = true, TeamCheck = false, MaxDistance = 1500, Fill = false,
        FillTransparency = 0.85, OutlineTransparency = 0, ShowOnlyVisible = false
    },
    Aim = {
        Enabled = false, FOV = 150, MaxDistance = 1000, Smoothness = 0.18,
        TargetPart = "Head", TeamCheck = false, PrioritizeDistance = false,
        WallCheck = true, TurnSpeed = 4200, LockGraceTime = 0.08, AutoFire = false
    },
    Visuals = {FOVCircle = true, Crosshair = true, FOVThickness = 1},
    UI = {
        MenuKey = "RightShift", Animations = true, Sounds = true,
        Notifications = true, TelegramPopup = true, CurrentTheme = "Purple"
    }
}

local function saveConfigFile()
    return pcall(function()
        if writefile then writefile(CONFIG_FILE, HttpService:JSONEncode(Config)) end
    end)
end

local function loadConfigFile()
    return pcall(function()
        if isfile and readfile and isfile(CONFIG_FILE) then
            local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE))
            for cat, settings in pairs(decoded) do
                if Config[cat] and type(settings) == "table" then
                    for k, v in pairs(settings) do Config[cat][k] = v end
                end
            end
        end
    end)
end
loadConfigFile()
Config.Aim.AutoFire = Config.Aim.AutoFire == true
if tonumber(Config.Aim.TurnSpeed) == nil then Config.Aim.TurnSpeed = 4200 end
Config.Aim.TurnSpeed = math.clamp(Config.Aim.TurnSpeed,900,4200)
if tonumber(Config.Aim.LockGraceTime) == nil or Config.Aim.LockGraceTime > 0.12 then Config.Aim.LockGraceTime = 0.08 end

--// HELPERS
local function tw(obj, time, props, style, direction)
    if not obj or not Config.UI.Animations then return end
    local ok, t = pcall(function()
        local x = TweenService:Create(obj, TweenInfo.new(
            time or .18,
            style or Enum.EasingStyle.Quart,
            direction or Enum.EasingDirection.Out
        ), props)
        x:Play()
        return x
    end)
    return ok and t or nil
end

local function corner(parent, radius)
    local x = Instance.new("UICorner")
    x.CornerRadius = UDim.new(0, radius or 10)
    x.Parent = parent
    return x
end

local function stroke(parent, color, transparency, thickness)
    local x = Instance.new("UIStroke")
    x.Color = color or C.Stroke
    x.Transparency = transparency or 0
    x.Thickness = thickness or 1
    x.Parent = parent
    return x
end

local function gradient(parent, a, b, rotation)
    local x = Instance.new("UIGradient")
    x.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, a),
        ColorSequenceKeypoint.new(.5, C.Accent3),
        ColorSequenceKeypoint.new(1, b)
    })
    x.Rotation = rotation or 0
    x.Parent = parent
    return x
end

local function text(parent, value, size, pos, fontSize, color, z)
    local x = Instance.new("TextLabel")
    x.BackgroundTransparency = 1
    x.Text = value or ""
    x.Size = size or UDim2.fromScale(1,1)
    x.Position = pos or UDim2.fromScale(0,0)
    x.Font = Enum.Font.GothamBold
    x.TextSize = fontSize or 11
    x.TextColor3 = color or C.Text
    x.TextXAlignment = Enum.TextXAlignment.Left
    x.TextYAlignment = Enum.TextYAlignment.Center
    x.ZIndex = z or 25
    x.Parent = parent
    return x
end

local function button(parent, size, pos, z)
    local x = Instance.new("TextButton")
    x.AutoButtonColor = false
    x.Text = ""
    x.BorderSizePixel = 0
    x.BackgroundTransparency = 1
    x.Size = size
    x.Position = pos
    x.ZIndex = z or 20
    x.Parent = parent
    return x
end

local function getSafeContainer()
    local target
    pcall(function()
        if gethui then target = gethui()
        elseif game:GetService("CoreGui") then target = game:GetService("CoreGui") end
    end)
    return target or LocalPlayer:WaitForChild("PlayerGui")
end

local SafeContainer = getSafeContainer()
local function genId()
    return "SniperArena_" .. string.sub(HttpService:GenerateGUID(false),1,8)
end

local function getMSKTimeString()
    return os.date("!%H:%M:%S", os.time() + 3*3600)
end

--// SOUNDS
local SoundClick = Instance.new("Sound")
SoundClick.SoundId = "rbxassetid://6895079853"
SoundClick.Volume = .55
SoundClick.Parent = SoundService
table.insert(Cleanups, SoundClick)

local SoundTab = Instance.new("Sound")
SoundTab.SoundId = "rbxassetid://6895079853"
SoundTab.Volume = .45
SoundTab.PlaybackSpeed = 1.15
SoundTab.Parent = SoundService
table.insert(Cleanups, SoundTab)

local function playSound(s)
    if Config.UI.Sounds then pcall(function() s:Play() end) end
end

--// GUI ROOTS
local OverlayGui = Instance.new("ScreenGui")
OverlayGui.Name = genId()
OverlayGui.ResetOnSpawn = false
OverlayGui.IgnoreGuiInset = true
OverlayGui.DisplayOrder = 998
OverlayGui.Parent = SafeContainer
table.insert(Cleanups, OverlayGui)

local MenuGui = Instance.new("ScreenGui")
MenuGui.Name = genId()
MenuGui.ResetOnSpawn = false
MenuGui.IgnoreGuiInset = true
MenuGui.DisplayOrder = 999
MenuGui.Parent = SafeContainer
table.insert(Cleanups, MenuGui)

--// OVERLAY
local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(.5,.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Size = UDim2.fromOffset(Config.Aim.FOV*2, Config.Aim.FOV*2)
FOVCircle.Position = UDim2.fromScale(.5,.5)
FOVCircle.Visible = Config.Visuals.FOVCircle
FOVCircle.ZIndex = 5
FOVCircle.Parent = OverlayGui
corner(FOVCircle,999)
local FOVStroke = stroke(FOVCircle,C.Accent,.15,Config.Visuals.FOVThickness)

local Crosshair = Instance.new("Frame")
Crosshair.AnchorPoint = Vector2.new(.5,.5)
Crosshair.Position = UDim2.fromScale(.5,.5)
Crosshair.Size = UDim2.fromOffset(24,24)
Crosshair.BackgroundTransparency = 1
Crosshair.Visible = Config.Visuals.Crosshair
Crosshair.ZIndex = 5
Crosshair.Parent = OverlayGui

for _, spec in ipairs({
    {UDim2.fromOffset(7,2),UDim2.fromOffset(1,11)},
    {UDim2.fromOffset(7,2),UDim2.fromOffset(16,11)},
    {UDim2.fromOffset(2,7),UDim2.fromOffset(11,1)},
    {UDim2.fromOffset(2,7),UDim2.fromOffset(11,16)}
}) do
    local b = Instance.new("Frame")
    b.BorderSizePixel = 0
    b.BackgroundColor3 = C.Accent2
    b.Size = spec[1]
    b.Position = spec[2]
    b.Parent = Crosshair
    corner(b,2)
end

--// MAIN MENU
local Shadow = Instance.new("Frame")
Shadow.AnchorPoint = Vector2.new(.5,.5)
Shadow.Position = UDim2.fromScale(.5,.5)
Shadow.Size = UDim2.fromOffset(530,370)
Shadow.BackgroundColor3 = Color3.new(0,0,0)
Shadow.BackgroundTransparency = .5
Shadow.BorderSizePixel = 0
Shadow.ZIndex = 4
Shadow.Parent = MenuGui
corner(Shadow,16)

local Main = Instance.new("Frame")
Main.AnchorPoint = Vector2.new(.5,.5)
Main.Position = UDim2.fromScale(.5,.5)
Main.Size = UDim2.fromOffset(530,370)
Main.BackgroundColor3 = C.Background
Main.BorderSizePixel = 0
Main.ZIndex = 5
Main.ClipsDescendants = true
Main.Parent = MenuGui
corner(Main,16)
stroke(Main,C.Stroke,.12,1.2)

local MainScale = Instance.new("UIScale")
MainScale.Parent = Main

local function updateScale()
    Camera = workspace.CurrentCamera or Camera
    local v = Camera and Camera.ViewportSize or Vector2.new(1280,720)
    MainScale.Scale = v.X < 720 and math.clamp(v.X/620,.60,.85) or v.X < 960 and .88 or 1
end
if Camera then
    table.insert(Cleanups,Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale))
end
updateScale()

local TopGlow = Instance.new("Frame")
TopGlow.Size = UDim2.new(1,-24,0,3)
TopGlow.Position = UDim2.fromOffset(12,0)
TopGlow.BorderSizePixel = 0
TopGlow.BackgroundColor3 = C.Accent
TopGlow.ZIndex = 7
TopGlow.Parent = Main
corner(TopGlow,5)
local TopGlowGrad = gradient(TopGlow,C.Accent,C.Accent2)

--// SIDEBAR
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.fromOffset(150,370)
Sidebar.BackgroundColor3 = C.Panel
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 6
Sidebar.Parent = Main
corner(Sidebar,16)

local Brand = Instance.new("Frame")
Brand.Size = UDim2.new(1,-20,0,48)
Brand.Position = UDim2.fromOffset(10,10)
Brand.BackgroundTransparency = 1
Brand.ZIndex = 7
Brand.Parent = Sidebar

local BrandIcon = Instance.new("Frame")
BrandIcon.Size = UDim2.fromOffset(34,34)
BrandIcon.Position = UDim2.fromOffset(2,4)
BrandIcon.BackgroundColor3 = C.Accent
BrandIcon.BorderSizePixel = 0
BrandIcon.ZIndex = 8
BrandIcon.Parent = Brand
corner(BrandIcon,10)
local BrandGrad = gradient(BrandIcon,C.Accent,C.Accent2,45)

local BrandMark = text(BrandIcon,"S",UDim2.fromScale(1,1),UDim2.fromScale(0,0),17,C.White,9)
BrandMark.Font = Enum.Font.GothamBlack
BrandMark.TextXAlignment = Enum.TextXAlignment.Center

local BrandTitle = text(Brand,SHUT_NAME,UDim2.fromOffset(85,20),UDim2.fromOffset(42,5),13,C.White,8)
BrandTitle.Font = Enum.Font.GothamBlack
local brandSub = text(Brand,"CONTROL PANEL",UDim2.fromOffset(95,14),UDim2.fromOffset(43,23),7,C.Sub,8)
brandSub.Font = Enum.Font.GothamMedium

local Pages = Instance.new("Frame")
Pages.Size = UDim2.new(1,-16,0,250)
Pages.Position = UDim2.fromOffset(8,64)
Pages.BackgroundTransparency = 1
Pages.ZIndex = 7
Pages.Parent = Sidebar

local PageLayout = Instance.new("UIListLayout")
PageLayout.Padding = UDim.new(0,5)
PageLayout.Parent = Pages

local PageButtons, PageFrames = {}, {}

local function makePageButton(id,titleVal,subVal,iconCode)
    local b = button(Pages,UDim2.new(1,0,0,42),UDim2.new(),8)
    b.BackgroundColor3 = C.Card
    b.BackgroundTransparency = 1
    corner(b,10)

    local activeBar = Instance.new("Frame")
    activeBar.Size = UDim2.fromOffset(3,24)
    activeBar.Position = UDim2.new(0,0,.5,-12)
    activeBar.BackgroundColor3 = C.Accent
    activeBar.BorderSizePixel = 0
    activeBar.Visible = false
    activeBar.ZIndex = 10
    activeBar.Parent = b
    corner(activeBar,4)

    local iconBox = Instance.new("Frame")
    iconBox.Size = UDim2.fromOffset(28,28)
    iconBox.Position = UDim2.fromOffset(6,7)
    iconBox.BackgroundColor3 = C.Panel2
    iconBox.BorderSizePixel = 0
    iconBox.ZIndex = 9
    iconBox.Parent = b
    corner(iconBox,8)

    local iconLabel = text(iconBox,utf8.char(iconCode),UDim2.fromScale(1,1),UDim2.fromScale(0,0),12,C.Sub,10)
    iconLabel.TextXAlignment = Enum.TextXAlignment.Center

    local t = text(b,titleVal,UDim2.fromOffset(95,16),UDim2.fromOffset(40,5),10,C.Text,10)
    local s = text(b,subVal,UDim2.fromOffset(95,14),UDim2.fromOffset(40,21),7,C.Sub,10)
    s.Font = Enum.Font.GothamMedium

    PageButtons[id] = {Button=b,Active=activeBar,IconBox=iconBox,Icon=iconLabel,Title=t,Sub=s}

    table.insert(Cleanups,b.MouseEnter:Connect(function()
        tw(b,.12,{BackgroundTransparency=.18,BackgroundColor3=C.Hover})
    end))
    table.insert(Cleanups,b.MouseLeave:Connect(function()
        local cur=PageButtons[id]
        tw(b,.12,{BackgroundTransparency=(cur and cur.Active.Visible) and .03 or 1,BackgroundColor3=C.Card})
    end))
end

makePageButton("ESP","ESP","Player visuals",0x25C8)
makePageButton("AIM","AIM","Targeting engine",0x25CE)
makePageButton("VISUALS","VISUALS","Screen effects",0x25C9)
makePageButton("STATUS","STATUS","Engine details",0x25CF)
makePageButton("SETTINGS","SETTINGS","Config & Style",0x2699)

--// CONTENT
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1,-150,1,0)
Content.Position = UDim2.fromOffset(150,0)
Content.BackgroundTransparency = 1
Content.ZIndex = 6
Content.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,54)
Header.BackgroundTransparency = 1
Header.ZIndex = 7
Header.Parent = Content

local PageTitle = text(Header,"ESP",UDim2.fromOffset(240,22),UDim2.fromOffset(16,9),17,C.White,15)
PageTitle.Font = Enum.Font.GothamBlack
local PageDesc = text(Header,"Configure player visual tags",UDim2.fromOffset(300,15),UDim2.fromOffset(17,30),8,C.Sub,15)
PageDesc.Font = Enum.Font.GothamMedium

local Close = button(Header,UDim2.fromOffset(24,24),UDim2.new(1,-28,0,14),16)
Close.BackgroundColor3 = Color3.fromRGB(60,48,76)
corner(Close,7)
local CloseText = text(Close,"×",UDim2.fromScale(1,1),UDim2.fromScale(0,0),15,C.White,17)
CloseText.TextXAlignment = Enum.TextXAlignment.Center

local ContentPages = Instance.new("Frame")
ContentPages.Size = UDim2.new(1,-26,1,-62)
ContentPages.Position = UDim2.fromOffset(13,54)
ContentPages.BackgroundTransparency = 1
ContentPages.ZIndex = 7
ContentPages.Parent = Content

local function createScrollPage(id)
    local page=Instance.new("ScrollingFrame")
    page.Name=id
    page.Size=UDim2.fromScale(1,1)
    page.BackgroundTransparency=1
    page.BorderSizePixel=0
    page.ScrollBarThickness=3
    page.ScrollBarImageColor3=C.Accent
    page.AutomaticCanvasSize=Enum.AutomaticSize.Y
    page.CanvasSize=UDim2.new()
    page.Visible=false
    page.ZIndex=8
    page.Parent=ContentPages

    local layout=Instance.new("UIListLayout")
    layout.Padding=UDim.new(0,7)
    layout.Parent=page

    local pad=Instance.new("UIPadding")
    pad.PaddingRight=UDim.new(0,5)
    pad.PaddingBottom=UDim.new(0,14)
    pad.Parent=page

    PageFrames[id]=page
    return page
end

local ESPPage=createScrollPage("ESP")
local AimPage=createScrollPage("AIM")
local VisualPage=createScrollPage("VISUALS")
local StatusPage=createScrollPage("STATUS")
local SettingsPage=createScrollPage("SETTINGS")

--// NOTIFICATIONS
local NotificationLayer=Instance.new("Frame")
NotificationLayer.Size=UDim2.fromOffset(250,180)
NotificationLayer.Position=UDim2.new(1,-12,1,-12)
NotificationLayer.AnchorPoint=Vector2.new(1,1)
NotificationLayer.BackgroundTransparency=1
NotificationLayer.ZIndex=100
NotificationLayer.Parent=MenuGui

local function notify(titleVal,bodyVal)
    if not Config.UI.Notifications then return end
    local card=Instance.new("Frame")
    card.Size=UDim2.fromOffset(235,54)
    card.Position=UDim2.new(1,18,1,-64)
    card.BackgroundColor3=C.Panel
    card.ZIndex=100
    card.Parent=NotificationLayer
    corner(card,10)
    stroke(card,C.Stroke,.15,1)

    local bar=Instance.new("Frame",card)
    bar.Size=UDim2.fromOffset(3,34)
    bar.Position=UDim2.fromOffset(8,10)
    bar.BackgroundColor3=C.Accent
    bar.BorderSizePixel=0
    bar.ZIndex=101
    corner(bar,3)

    text(card,titleVal,UDim2.new(1,-25,0,16),UDim2.fromOffset(18,6),10,C.White,101)
    local body=text(card,bodyVal,UDim2.new(1,-25,0,22),UDim2.fromOffset(18,23),8,C.Sub,101)
    body.TextWrapped=true

    tw(card,.28,{Position=UDim2.new(1,-245,1,-64)},Enum.EasingStyle.Back)
    task.delay(2.6,function()
        if card.Parent then
            tw(card,.22,{Position=UDim2.new(1,18,1,-64)})
            task.delay(.25,function() if card.Parent then card:Destroy() end end)
        end
    end)
end

--// WIDGETS
local DynamicUIElements={Tracks={}}

local function section(parent,titleVal,descVal)
    local h=Instance.new("Frame")
    h.Size=UDim2.new(1,0,0,30)
    h.BackgroundTransparency=1
    h.ZIndex=12
    h.Parent=parent
    local t=text(h,titleVal,UDim2.new(1,0,0,16),UDim2.fromOffset(0,0),10,C.White,25)
    t.Font=Enum.Font.GothamBlack
    local d=text(h,descVal,UDim2.new(1,0,0,14),UDim2.fromOffset(0,15),8,C.Sub,25)
    d.Font=Enum.Font.GothamMedium
end

local function toggle(parent,titleVal,descVal,tbl,key)
    local card=Instance.new("Frame")
    card.Size=UDim2.new(1,0,0,50)
    card.BackgroundColor3=tbl[key] and C.CardOn or C.CardOff
    card.ZIndex=10
    card.Parent=parent
    corner(card,9)
    local cardStroke=stroke(card,tbl[key] and C.Accent or C.StrokeOff,.35,1)

    local b=button(card,UDim2.fromScale(1,1),UDim2.fromScale(0,0),15)
    text(card,titleVal,UDim2.new(1,-80,0,18),UDim2.fromOffset(12,6),11,C.White,25)
    local d=text(card,descVal,UDim2.new(1,-80,0,15),UDim2.fromOffset(12,25),8,C.Sub,25)
    d.Font=Enum.Font.GothamMedium

    local track=Instance.new("Frame",card)
    track.Size=UDim2.fromOffset(36,20)
    track.Position=UDim2.new(1,-48,.5,-10)
    track.BackgroundColor3=tbl[key] and C.Accent or C.Muted
    track.BorderSizePixel=0
    track.ZIndex=26
    corner(track,99)

    local knob=Instance.new("Frame",track)
    knob.Size=UDim2.fromOffset(14,14)
    knob.Position=UDim2.fromOffset(tbl[key] and 19 or 3,3)
    knob.BackgroundColor3=C.White
    knob.BorderSizePixel=0
    knob.ZIndex=27
    corner(knob,99)

    local function refresh(anim)
        local on=tbl[key]
        local tx=on and 19 or 3
        local col=on and C.Accent or C.Muted
        local cardCol=on and C.CardOn or C.CardOff
        local strokeCol=on and C.Accent or C.StrokeOff
        if anim then
            tw(track,.18,{BackgroundColor3=col})
            tw(knob,.22,{Position=UDim2.fromOffset(tx,3)},Enum.EasingStyle.Back)
            tw(card,.20,{BackgroundColor3=cardCol})
            tw(cardStroke,.20,{Color=strokeCol})
        else
            track.BackgroundColor3=col
            knob.Position=UDim2.fromOffset(tx,3)
            card.BackgroundColor3=cardCol
            cardStroke.Color=strokeCol
        end
    end

    table.insert(DynamicUIElements.Tracks,function() refresh(false) end)
    table.insert(Cleanups,b.Activated:Connect(function()
        tbl[key]=not tbl[key]
        refresh(true)
        playSound(SoundClick)
        saveConfigFile()
    end))
    return card
end

local function slider(parent,titleVal,descVal,tbl,key,minV,maxV,dec)
    local card=Instance.new("Frame")
    card.Size=UDim2.new(1,0,0,64)
    card.BackgroundColor3=C.Card
    card.ZIndex=10
    card.Parent=parent
    corner(card,9)
    stroke(card,C.Stroke,.45,1)

    text(card,titleVal,UDim2.new(.7,0,0,16),UDim2.fromOffset(12,6),11,C.White,25)
    local d=text(card,descVal,UDim2.new(.7,0,0,14),UDim2.fromOffset(12,24),8,C.Sub,25)
    d.Font=Enum.Font.GothamMedium

    local valLabel=text(card,tostring(tbl[key]),UDim2.fromOffset(60,18),UDim2.new(1,-70,0,6),10,C.Accent2,25)
    valLabel.TextXAlignment=Enum.TextXAlignment.Right

    local bar=Instance.new("Frame",card)
    bar.Size=UDim2.new(1,-24,0,5)
    bar.Position=UDim2.fromOffset(12,46)
    bar.BackgroundColor3=C.Panel2
    bar.BorderSizePixel=0
    bar.ZIndex=26
    corner(bar,99)

    local fill=Instance.new("Frame",bar)
    fill.Size=UDim2.fromScale(0,1)
    fill.BackgroundColor3=C.Accent
    fill.BorderSizePixel=0
    fill.ZIndex=27
    corner(fill,99)

    local knob=Instance.new("Frame",bar)
    knob.Size=UDim2.fromOffset(11,11)
    knob.AnchorPoint=Vector2.new(.5,.5)
    knob.BackgroundColor3=C.White
    knob.BorderSizePixel=0
    knob.ZIndex=28
    corner(knob,99)

    local dragging=false
    local function updateX(x)
        local ratio=math.clamp((x-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)
        local raw=minV+(maxV-minV)*ratio
        local mult=10^(dec or 0)
        local v=math.floor(raw*mult+.5)/mult
        tbl[key]=v
        fill.Size=UDim2.fromScale(ratio,1)
        knob.Position=UDim2.new(ratio,0,.5,0)
        valLabel.Text=tostring(v)
    end

    table.insert(Cleanups,bar.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true
            updateX(input.Position.X)
        end
    end))
    table.insert(Cleanups,UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            updateX(input.Position.X)
        end
    end))
    table.insert(Cleanups,UIS.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=false
            saveConfigFile()
        end
    end))

    table.insert(DynamicUIElements.Tracks,function()
        local ratio=math.clamp((tbl[key]-minV)/(maxV-minV),0,1)
        fill.BackgroundColor3=C.Accent
        valLabel.TextColor3=C.Accent2
        fill.Size=UDim2.fromScale(ratio,1)
        knob.Position=UDim2.new(ratio,0,.5,0)
        valLabel.Text=tostring(tbl[key])
    end)

    local ratio=math.clamp((tbl[key]-minV)/(maxV-minV),0,1)
    fill.Size=UDim2.fromScale(ratio,1)
    knob.Position=UDim2.new(ratio,0,.5,0)
    return card
end

--// PAGES
section(ESPPage,"PLAYER ESP","Reliable player overlays and tracking")
toggle(ESPPage,"ESP Master","Master switch for player overlays",Config.ESP,"Enabled")
toggle(ESPPage,"2D Boxes","Bounding boxes around players",Config.ESP,"Box")
toggle(ESPPage,"Player Names","Display username and display name",Config.ESP,"Name")
toggle(ESPPage,"Health Bars","Show live HP indicator",Config.ESP,"Health")
toggle(ESPPage,"Distance Tag","Show distance and HP",Config.ESP,"Distance")
toggle(ESPPage,"Snaplines","Draw line to player",Config.ESP,"Tracer")
toggle(ESPPage,"Team Check","Ignore teammates",Config.ESP,"TeamCheck")
toggle(ESPPage,"Visible Only","Hide ESP behind walls",Config.ESP,"ShowOnlyVisible")
slider(ESPPage,"Max Distance","ESP render range",Config.ESP,"MaxDistance",100,3000,0)

section(AimPage,"360° AIM ASSIST","Stable lock with strict wall check")
toggle(AimPage,"Aim Assist","Enable target lock",Config.Aim,"Enabled")
toggle(AimPage,"Target Closest","Prefer nearest valid target",Config.Aim,"PrioritizeDistance")
toggle(AimPage,"Team Check","Ignore teammates",Config.Aim,"TeamCheck")
toggle(AimPage,"Wall Check","Never aim through walls",Config.Aim,"WallCheck")
toggle(AimPage,"Auto Fire","Fire without stealing movement or menu input",Config.Aim,"AutoFire")
slider(AimPage,"FOV Radius","Visual acquisition radius",Config.Aim,"FOV",40,500,0)
slider(AimPage,"Smoothness","Kept for config compatibility",Config.Aim,"Smoothness",0.05,0.6,2)
slider(AimPage,"Max Range","Maximum target distance",Config.Aim,"MaxDistance",50,2500,0)

section(VisualPage,"SCREEN VISUALS","Crosshair and FOV")
toggle(VisualPage,"FOV Ring","Draw visual FOV circle",Config.Visuals,"FOVCircle")
toggle(VisualPage,"Crosshair","Draw center reticle",Config.Visuals,"Crosshair")

section(StatusPage,"PLAYER PROFILE","Account statistics and identity")
local profCard=Instance.new("Frame")
profCard.Size=UDim2.new(1,0,0,92)
profCard.BackgroundColor3=C.Card
profCard.Parent=StatusPage
corner(profCard,10)
stroke(profCard,C.Stroke,.45,1)

local Avatar=Instance.new("ImageLabel")
Avatar.Size=UDim2.fromOffset(62,62)
Avatar.Position=UDim2.fromOffset(12,15)
Avatar.BackgroundColor3=C.Panel2
Avatar.BorderSizePixel=0
Avatar.Parent=profCard
corner(Avatar,10)
pcall(function()
    Avatar.Image=Players:GetUserThumbnailAsync(LocalPlayer.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)
end)

text(profCard,LocalPlayer.DisplayName,UDim2.new(1,-90,0,18),UDim2.fromOffset(84,12),12,C.White,25)
text(profCard,"@"..LocalPlayer.Name,UDim2.new(1,-90,0,14),UDim2.fromOffset(84,31),8,C.Sub,25)
text(profCard,"UserId: "..tostring(LocalPlayer.UserId),UDim2.new(1,-90,0,14),UDim2.fromOffset(84,47),8,C.Muted,25)
text(profCard,"Account Age: "..tostring(LocalPlayer.AccountAge).." days",UDim2.new(1,-90,0,14),UDim2.fromOffset(84,63),8,C.Accent2,25)

section(StatusPage,"ENGINE STATS","Runtime metrics")
local engCard=Instance.new("Frame")
engCard.Size=UDim2.new(1,0,0,88)
engCard.BackgroundColor3=C.Card
engCard.Parent=StatusPage
corner(engCard,10)
stroke(engCard,C.Stroke,.45,1)
text(engCard,"SYSTEM ONLINE • STABLE LOCK",UDim2.new(1,-20,0,16),UDim2.fromOffset(12,7),9,C.Green,25)
local engInfo=text(engCard,"",UDim2.new(1,-20,0,56),UDim2.fromOffset(12,25),8,C.Sub,25)
engInfo.TextWrapped=true

--// SETTINGS
section(SettingsPage,"CONFIGURATION MANAGER","Save or reload settings")
local cfgCard=Instance.new("Frame")
cfgCard.Size=UDim2.new(1,0,0,48)
cfgCard.BackgroundColor3=C.Card
cfgCard.Parent=SettingsPage
corner(cfgCard,10)
stroke(cfgCard,C.Stroke,.45,1)

local cfgLayout=Instance.new("UIListLayout")
cfgLayout.FillDirection=Enum.FillDirection.Horizontal
cfgLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
cfgLayout.VerticalAlignment=Enum.VerticalAlignment.Center
cfgLayout.Padding=UDim.new(0,10)
cfgLayout.Parent=cfgCard

local saveBtn=button(cfgCard,UDim2.fromOffset(105,32),UDim2.new(),25)
saveBtn.BackgroundColor3=C.Accent
corner(saveBtn,7)
local saveTxt=text(saveBtn,"SAVE CONFIG",UDim2.fromScale(1,1),UDim2.fromScale(0,0),9,C.White,26)
saveTxt.TextXAlignment=Enum.TextXAlignment.Center

local loadBtn=button(cfgCard,UDim2.fromOffset(105,32),UDim2.new(),25)
loadBtn.BackgroundColor3=C.Panel2
corner(loadBtn,7)
stroke(loadBtn,C.Stroke,.2,1)
local loadTxt=text(loadBtn,"LOAD CONFIG",UDim2.fromScale(1,1),UDim2.fromScale(0,0),9,C.White,26)
loadTxt.TextXAlignment=Enum.TextXAlignment.Center

table.insert(Cleanups,saveBtn.Activated:Connect(function()
    saveConfigFile()
    playSound(SoundClick)
    notify("Configuration Saved","Settings stored in "..CONFIG_FILE)
end))

table.insert(Cleanups,loadBtn.Activated:Connect(function()
    loadConfigFile()
    for _,fn in ipairs(DynamicUIElements.Tracks) do pcall(fn) end
    playSound(SoundClick)
    notify("Configuration Loaded","Settings restored from "..CONFIG_FILE)
end))

section(SettingsPage,"THEME CUSTOMIZER","Select accent palette")
local themeCard=Instance.new("Frame")
themeCard.Size=UDim2.new(1,0,0,52)
themeCard.BackgroundColor3=C.Card
themeCard.Parent=SettingsPage
corner(themeCard,10)
stroke(themeCard,C.Stroke,.45,1)

local themeLayout=Instance.new("UIListLayout")
themeLayout.FillDirection=Enum.FillDirection.Horizontal
themeLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
themeLayout.VerticalAlignment=Enum.VerticalAlignment.Center
themeLayout.Padding=UDim.new(0,8)
themeLayout.Parent=themeCard

local function applyTheme(name)
    local t=Themes[name]
    if not t then return end
    Config.UI.CurrentTheme=name
    C.Accent=t.Accent
    C.Accent2=t.Accent2
    C.Accent3=t.Accent3

    TopGlow.BackgroundColor3=C.Accent
    TopGlowGrad.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,C.Accent),
        ColorSequenceKeypoint.new(.5,C.Accent3),
        ColorSequenceKeypoint.new(1,C.Accent2)
    })
    BrandIcon.BackgroundColor3=C.Accent
    BrandGrad.Color=TopGlowGrad.Color
    FOVStroke.Color=C.Accent
    saveBtn.BackgroundColor3=C.Accent
    for _,fn in ipairs(DynamicUIElements.Tracks) do pcall(fn) end
    for _,data in pairs(PageButtons) do data.Active.BackgroundColor3=C.Accent end
end

for _,name in ipairs({"Purple","Cyan","Emerald","Crimson","Gold"}) do
    local b=button(themeCard,UDim2.fromOffset(60,32),UDim2.new(),25)
    b.BackgroundColor3=Themes[name].Accent
    corner(b,7)
    local bt=text(b,name,UDim2.fromScale(1,1),UDim2.fromScale(0,0),8,C.White,26)
    bt.TextXAlignment=Enum.TextXAlignment.Center
    table.insert(Cleanups,b.Activated:Connect(function()
        applyTheme(name)
        playSound(SoundClick)
        notify("Theme Applied","Switched UI palette to "..name)
    end))
end

section(SettingsPage,"INTERFACE","Menu behavior")
toggle(SettingsPage,"Animations","Enable menu animations",Config.UI,"Animations")
toggle(SettingsPage,"Sounds","Enable feedback sounds",Config.UI,"Sounds")
toggle(SettingsPage,"Notifications","Enable notifications",Config.UI,"Notifications")
toggle(SettingsPage,"Telegram Popup","Show Telegram reminder",Config.UI,"TelegramPopup")

local infoCard=Instance.new("Frame")
infoCard.Size=UDim2.new(1,0,0,52)
infoCard.BackgroundColor3=C.Card
infoCard.Parent=SettingsPage
corner(infoCard,10)
stroke(infoCard,C.Stroke,.45,1)
text(infoCard,"Menu Shortcut: RightShift or M",UDim2.new(1,-20,0,16),UDim2.fromOffset(12,7),9,C.White,25)
text(infoCard,"Mobile: use the top status bar button",UDim2.new(1,-20,0,16),UDim2.fromOffset(12,25),8,C.Sub,25)

--// PAGE SWITCHER
local function setPage(id)
    playSound(SoundTab)
    for pid,p in pairs(PageFrames) do
        if pid==id then
            p.Visible=true
            p.CanvasPosition=Vector2.zero
            p.Position=UDim2.fromOffset(0,10)
            tw(p,.20,{Position=UDim2.fromOffset(0,0)})
        else p.Visible=false end
    end
    PageTitle.Text=id
    PageDesc.Text =
        id=="ESP" and "Configure player visual tags" or
        id=="AIM" and "Stable 360° target lock and wall check" or
        id=="VISUALS" and "On-screen overlays and reticles" or
        id=="STATUS" and "Diagnostics and player metrics" or
        "Configuration manager and styles"
    for pid,data in pairs(PageButtons) do
        local active=pid==id
        data.Active.Visible=active
        tw(data.Button,.14,{BackgroundTransparency=active and .03 or 1,BackgroundColor3=C.Card})
        data.Title.TextColor3=active and C.White or C.Text
    end
end

for id,data in pairs(PageButtons) do
    table.insert(Cleanups,data.Button.Activated:Connect(function() setPage(id) end))
end
setPage("ESP")
applyTheme(Config.UI.CurrentTheme or "Purple")

--// TOP BAR
local OpenBar=Instance.new("Frame")
OpenBar.AnchorPoint=Vector2.new(.5,0)
OpenBar.Size=UDim2.fromOffset(450,36)
OpenBar.Position=UDim2.new(.5,0,0,-50)
OpenBar.BackgroundColor3=C.Panel
OpenBar.ZIndex=60
OpenBar.Parent=MenuGui
corner(OpenBar,10)
stroke(OpenBar,C.Stroke,.15,1)

local barAccent=Instance.new("Frame",OpenBar)
barAccent.Size=UDim2.fromOffset(3,20)
barAccent.Position=UDim2.fromOffset(8,8)
barAccent.BackgroundColor3=C.Accent
barAccent.BorderSizePixel=0
barAccent.ZIndex=61
corner(barAccent,4)

local BarBrand=text(OpenBar,"SHUT",UDim2.fromOffset(38,20),UDim2.fromOffset(16,8),10,C.White,65)
BarBrand.Font=Enum.Font.GothamBlack
local BarUser=text(OpenBar,"@"..LocalPlayer.Name,UDim2.fromOffset(95,20),UDim2.fromOffset(58,8),8,C.Sub,65)
BarUser.TextTruncate=Enum.TextTruncate.AtEnd
local BarFPS=text(OpenBar,"FPS: 60",UDim2.fromOffset(55,20),UDim2.fromOffset(158,8),8,C.Green,65)
local BarMSK=text(OpenBar,"MSK: 00:00:00",UDim2.fromOffset(95,20),UDim2.fromOffset(218,8),8,C.Accent2,65)

local OpenTab=button(OpenBar,UDim2.fromOffset(115,26),UDim2.fromOffset(325,5),65)
OpenTab.BackgroundColor3=C.Accent
corner(OpenTab,7)
gradient(OpenTab,C.Accent,C.Accent2)
local OpenTabText=text(OpenTab,"UNLOCK MENU ›",UDim2.fromScale(1,1),UDim2.fromScale(0,0),8,C.White,66)
OpenTabText.TextXAlignment=Enum.TextXAlignment.Center

local MenuVisible=true
local function setMenuVisible(visible)
    MenuVisible=visible
    playSound(SoundClick)
    if visible then
        Main.Visible=true
        Shadow.Visible=true
        MainScale.Scale=MainScale.Scale > 0 and MainScale.Scale or 1
        tw(MainScale,.20,{Scale=1},Enum.EasingStyle.Back)
        tw(Shadow,.20,{BackgroundTransparency=.50})
        tw(OpenBar,.18,{Position=UDim2.new(.5,0,0,-50)})
    else
        tw(MainScale,.16,{Scale=.85})
        tw(Shadow,.16,{BackgroundTransparency=1})
        tw(OpenBar,.22,{Position=UDim2.new(.5,0,0,10)},Enum.EasingStyle.Back)
        task.delay(.16,function()
            if not MenuVisible then Main.Visible=false Shadow.Visible=false end
        end)
    end
end

table.insert(Cleanups,OpenTab.Activated:Connect(function() setMenuVisible(true) end))
table.insert(Cleanups,Close.Activated:Connect(function() setMenuVisible(false) end))
table.insert(Cleanups,UIS.InputBegan:Connect(function(input,processed)
    if processed then return end
    if input.KeyCode==Enum.KeyCode.RightShift or input.KeyCode==Enum.KeyCode.M then
        setMenuVisible(not MenuVisible)
    end
end))

--// DRAG
local dragging=false
local dragStart,panelStart
table.insert(Cleanups,Header.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true
        dragStart=input.Position
        panelStart=Main.Position
    end
end))
table.insert(Cleanups,UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-dragStart
        Main.Position=UDim2.new(panelStart.X.Scale,panelStart.X.Offset+delta.X,panelStart.Y.Scale,panelStart.Y.Offset+delta.Y)
        Shadow.Position=UDim2.new(panelStart.X.Scale,panelStart.X.Offset+delta.X+6,panelStart.Y.Scale,panelStart.Y.Offset+delta.Y+8)
    end
end))
table.insert(Cleanups,UIS.InputEnded:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
end))

--// TELEGRAM POPUP
local function createTelegramPopup()
    if not Config.UI.TelegramPopup or SafeContainer:FindFirstChild("ShutTelegramNotification") then return end
    local popupGui=Instance.new("ScreenGui")
    popupGui.Name="ShutTelegramNotification"
    popupGui.ResetOnSpawn=false
    popupGui.IgnoreGuiInset=true
    popupGui.DisplayOrder=1001
    popupGui.Parent=SafeContainer
    table.insert(Cleanups,popupGui)

    local card=Instance.new("Frame",popupGui)
    card.Size=UDim2.fromOffset(245,160)
    card.Position=UDim2.new(1,270,0,16)
    card.BackgroundColor3=C.Panel
    card.ZIndex=80
    corner(card,14)
    stroke(card,C.Accent,.35,1.2)

    local top=Instance.new("Frame",card)
    top.Size=UDim2.new(1,-20,0,3)
    top.Position=UDim2.fromOffset(10,0)
    top.BackgroundColor3=C.Accent
    top.BorderSizePixel=0
    top.ZIndex=81
    corner(top,5)

    text(card,"Shut Community",UDim2.new(1,-24,0,20),UDim2.fromOffset(12,11),11,C.White,82)
    local desc=text(card,"Subscribe to our Telegram channel for script updates and releases.",UDim2.new(1,-24,0,48),UDim2.fromOffset(12,38),8,C.Sub,82)
    desc.TextWrapped=true
    desc.TextYAlignment=Enum.TextYAlignment.Top

    local go=button(card,UDim2.new(1,-24,0,28),UDim2.fromOffset(12,92),85)
    go.BackgroundColor3=C.Accent
    corner(go,8)
    local gt=text(go,"COPY INVITE LINK",UDim2.fromScale(1,1),UDim2.fromScale(0,0),9,C.White,86)
    gt.TextXAlignment=Enum.TextXAlignment.Center

    local cancel=button(card,UDim2.new(1,-24,0,24),UDim2.fromOffset(12,124),85)
    cancel.BackgroundColor3=C.Panel2
    corner(cancel,8)
    local ct=text(cancel,"Dismiss",UDim2.fromScale(1,1),UDim2.fromScale(0,0),8,C.Sub,86)
    ct.TextXAlignment=Enum.TextXAlignment.Center

    local function closePopup()
        tw(card,.22,{Position=UDim2.new(1,270,0,16)})
        task.delay(.25,function() if popupGui.Parent then popupGui:Destroy() end end)
    end

    table.insert(Cleanups,go.Activated:Connect(function()
        pcall(function() if setclipboard then setclipboard(TELEGRAM_URL) end end)
        notify("Telegram Link","Link copied to clipboard!")
        playSound(SoundClick)
        closePopup()
    end))
    table.insert(Cleanups,cancel.Activated:Connect(closePopup))
    tw(card,.35,{Position=UDim2.new(1,-260,0,16)},Enum.EasingStyle.Back)
end

task.spawn(function()
    task.wait(4)
    createTelegramPopup()
    while true do
        task.wait(300)
        if Config.UI.TelegramPopup then createTelegramPopup() end
    end
end)

--// CHARACTER HELPERS
local function getCharParts(char)
    if not char or not char:IsDescendantOf(workspace) then return nil,nil,nil end
    local hum=char:FindFirstChildOfClass("Humanoid")
    local root=char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Torso") or char.PrimaryPart
    if not root then
        for _,obj in ipairs(char:GetChildren()) do
            if obj:IsA("BasePart") and obj.Name~="Handle" then root=obj break end
        end
    end
    local head=char:FindFirstChild("Head") or root
    return hum,root,head
end

local function readCharacterHealth(char,hum)
    if not char or not hum or not hum.Parent then return 0,1 end

    -- Some games keep Humanoid.Health at 100 and store combat HP elsewhere.
    -- Read the common replicated numeric forms, preferring a value that is
    -- actually changing instead of a static max-health attribute.
    local humHp=math.max(0,tonumber(hum.Health) or 0)
    local humMax=math.max(1,tonumber(hum.MaxHealth) or 1)
    local hp=humHp
    local maxHp=humMax

    local hpNames={"CurrentHealth","Health","HP","HitPoints","Hitpoint","CurrentHP","HealthPoints","CurrentHitPoints"}
    local maxNames={"MaxHealth","MaxHP","HealthMax","MaxHitPoints","MaxHitpoint","MaxHealthPoints"}

    local function numericValue(obj)
        if not obj then return nil end
        local ok,v=pcall(function()
            if obj:IsA("NumberValue") or obj:IsA("IntValue") then return obj.Value end
            return nil
        end)
        return ok and tonumber(v) or nil
    end

    for _,name in ipairs(hpNames) do
        local attr=char:GetAttribute(name)
        if type(attr)=="number" and attr>=0 then
            hp=attr
            break
        end
        local child=char:FindFirstChild(name,true)
        local value=numericValue(child)
        if value~=nil and value>=0 then
            hp=value
            break
        end
    end

    for _,name in ipairs(maxNames) do
        local attr=char:GetAttribute(name)
        if type(attr)=="number" and attr>0 then
            maxHp=attr
            break
        end
        local child=char:FindFirstChild(name,true)
        local value=numericValue(child)
        if value and value>0 then
            maxHp=value
            break
        end
    end

    -- If a custom current-health value is absent, fall back to Humanoid.
    return math.clamp(tonumber(hp) or 0,0,maxHp),math.max(1,tonumber(maxHp) or 1)
end

local function hasPlayerDeadMarker(player)
    if not player then return false end
    for _,name in ipairs({"Dead","IsDead","Eliminated","Alive","Status","State"}) do
        local attr=player:GetAttribute(name)
        if name=="Alive" and attr==false then return true end
        if (name=="Dead" or name=="IsDead" or name=="Eliminated") and attr==true then return true end
        if type(attr)=="string" then
            local v=string.lower(attr)
            if v=="dead" or v=="eliminated" or v=="knocked" or v=="downed" then return true end
        end
    end
    return false
end

local function hasDeadMarker(char)
    if not char then return false end

    local names={"Dead","IsDead","Died","Eliminated","EliminatedState","Elimination","Knocked","Downed","Destroyed","Defeated"}
    for _,name in ipairs(names) do
        local attr=char:GetAttribute(name)
        if attr==true then return true end
        if type(attr)=="string" and string.lower(attr)=="dead" then return true end
        local value=char:FindFirstChild(name,true)
        if value then
            if value:IsA("BoolValue") and value.Value then return true end
            if (value:IsA("StringValue")) and string.lower(value.Value)=="dead" then return true end
            if (value:IsA("NumberValue") or value:IsA("IntValue")) and value.Value<=0 and name~="EliminatedState" then return true end
        end
    end

    local alive=char:GetAttribute("Alive")
    if alive==false then return true end

    return false
end

local function isAlive(char,hum)
    if not char or not char:IsDescendantOf(workspace) then return false end
    if not hum or not hum.Parent or hasDeadMarker(char) then return false end
    local hp=readCharacterHealth(char,hum)
    return hp > 0 and hum.Health > 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead
end

local function sameTeam(p,teamCheck)
    return teamCheck and LocalPlayer.Team and p.Team and LocalPlayer.Team==p.Team
end

local function isLocalPlayerObject(p)
    if not p then return false end
    if p==LocalPlayer then return true end
    local ok,id=pcall(function() return p.UserId end)
    local localOk,localId=pcall(function() return LocalPlayer.UserId end)
    return ok and localOk and id and localId and id==localId
end

local function isLocalCharacter(char)
    if not char then return false end
    local localChar=LocalPlayer and LocalPlayer.Character
    if not localChar then return false end
    if char==localChar then return true end
    local ok,result=pcall(function()
        return char:IsDescendantOf(localChar) or localChar:IsDescendantOf(char)
    end)
    return ok and result==true
end

local function isLocalPart(part)
    if not part then return false end
    return isLocalCharacter(part.Parent) or (LocalPlayer.Character and part:IsDescendantOf(LocalPlayer.Character))
end

--// ESP
local ESPCache={}

local function safeDestroy(obj)
    if obj and typeof(obj)=="Instance" then pcall(function() obj:Destroy() end) end
end

local function hideESP(data)
    if not data then return end
    data.Character = nil
    if data.Highlight then
        pcall(function()
            data.Highlight.Enabled=false
            data.Highlight.Adornee=nil
        end)
    end
    for _,key in ipairs({"Box","Tag","Info","HPBack","Tracer"}) do
        if data[key] then
            data[key].Visible=false
        end
    end
end

local function purgeESP(p)
    local data=ESPCache[p]
    if not data then return end
    hideESP(data)
    for _,obj in pairs(data) do
        if typeof(obj)=="Instance" then safeDestroy(obj) end
    end
    ESPCache[p]=nil
end

local function setupESPForPlayer(p)
    if isLocalPlayerObject(p) then return end
    local old=ESPCache[p]
    if old then
        hideESP(old)
        return
    end

    local box=Instance.new("Frame")
    box.Name="ESPBox"
    box.BackgroundTransparency=1
    box.Visible=false
    box.ZIndex=12
    box.Parent=OverlayGui
    local boxStroke=stroke(box,C.Accent,0,1.2)

    local tag=text(OverlayGui,"",UDim2.fromOffset(280,16),UDim2.fromScale(0,0),10,C.White,15)
    tag.TextXAlignment=Enum.TextXAlignment.Center
    tag.Visible=false

    local info=text(OverlayGui,"",UDim2.fromOffset(280,16),UDim2.fromScale(0,0),8,C.Sub,15)
    info.TextXAlignment=Enum.TextXAlignment.Center
    info.Visible=false

    local hpBack=Instance.new("Frame")
    hpBack.BackgroundColor3=Color3.fromRGB(25,25,30)
    hpBack.BorderSizePixel=0
    hpBack.Visible=false
    hpBack.ZIndex=13
    hpBack.Parent=OverlayGui
    corner(hpBack,4)

    local hpFill=Instance.new("Frame")
    hpFill.AnchorPoint=Vector2.new(0,1)
    hpFill.Position=UDim2.fromOffset(0,0)
    hpFill.Size=UDim2.fromOffset(4,0)
    hpFill.BackgroundColor3=C.Green
    hpFill.BorderSizePixel=0
    hpFill.ZIndex=14
    hpFill.Parent=hpBack
    corner(hpFill,4)

    local tracer=Instance.new("Frame")
    tracer.AnchorPoint=Vector2.new(.5,.5)
    tracer.BackgroundColor3=C.Accent
    tracer.BorderSizePixel=0
    tracer.Visible=false
    tracer.ZIndex=14
    tracer.Parent=OverlayGui

    local highlight=Instance.new("Highlight")
    highlight.Name="ESPHighlight"
    highlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor=C.Accent
    highlight.OutlineColor=C.Accent2
    highlight.FillTransparency=Config.ESP.Fill and Config.ESP.FillTransparency or 1
    highlight.OutlineTransparency=Config.ESP.OutlineTransparency
    highlight.Enabled=false
    highlight.Parent=workspace

    ESPCache[p]={
        Box=box,BoxStroke=boxStroke,Tag=tag,Info=info,
        HPBack=hpBack,HPFill=hpFill,Tracer=tracer,
        Highlight=highlight,Character=nil,Connections={}
    }
end

for _,p in ipairs(Players:GetPlayers()) do setupESPForPlayer(p) end

-- Character lifecycle is centralized here. It removes stale model references
-- and replaces them as soon as the player gets a new character.
local function bindPlayerLifecycle(p)
    if isLocalPlayerObject(p) then return end
    local data=ESPCache[p]
    if not data then setupESPForPlayer(p) data=ESPCache[p] end
    if not data then return end

    if data.LifecycleBound then return end
    data.LifecycleBound=true
    data.Character=p.Character

    local c1=p.CharacterAdded:Connect(function(char)
        local d=ESPCache[p]
        if not d then return end

        -- Drop every reference to the dead/old model BEFORE using the new one.
        d.Character=nil
        hideESP(d)

        -- Wait until the new model has its core parts, then bind it.
        task.spawn(function()
            local deadline=os.clock()+5
            while os.clock()<deadline and char.Parent and not char:IsDescendantOf(workspace) do
                task.wait()
            end
            local hum,root,head=getCharParts(char)
            if d and ESPCache[p]==d and char.Parent and hum and root and head and hum.Health>0 then
                d.Character=char
            end
        end)
    end)

    local c2=p.CharacterRemoving:Connect(function(char)
        local d=ESPCache[p]
        if not d then return end
        if d.Character==char then
            d.Character=nil
            hideESP(d)
        end
    end)

    table.insert(data.Connections,c1)
    table.insert(data.Connections,c2)
    table.insert(Cleanups,c1)
    table.insert(Cleanups,c2)
end

for _,p in ipairs(Players:GetPlayers()) do bindPlayerLifecycle(p) end

table.insert(Cleanups,Players.PlayerAdded:Connect(function(p)
    setupESPForPlayer(p)
    bindPlayerLifecycle(p)
end))

table.insert(Cleanups,Players.PlayerRemoving:Connect(function(p)
    purgeESP(p)
end))

-- Full-server reconciliation. This is intentionally periodic as well as
-- event-driven, so late-created/replaced Player/Character objects are picked up.
local reconcileClock=0
local RECONCILE_INTERVAL=0.25

local function reconcilePlayers()
    local seen={}
    for _,p in ipairs(Players:GetPlayers()) do
        seen[p]=true
        if not isLocalPlayerObject(p) then
            if not ESPCache[p] then setupESPForPlayer(p) end
            bindPlayerLifecycle(p)

            local d=ESPCache[p]
            if d then
                local char=p.Character
                if char~=d.Character then
                    d.Character=nil
                    hideESP(d)
                end
                if char and char:IsDescendantOf(workspace) then
                    local hum,root,head=getCharParts(char)
                    if isAlive(char,hum) and root and head then
                        d.Character=char
                    else
                        d.Character=nil
                        hideESP(d)
                    end
                else
                    d.Character=nil
                    hideESP(d)
                end
            end
        end
    end
    for p in pairs(ESPCache) do
        if not seen[p] then purgeESP(p) end
    end
end

local function isTargetVisibleForESP(targetPos,char)
    if isLocalCharacter(char) or not Camera or not targetPos or not char then return false end
    local origin=Camera.CFrame.Position
    local direction=targetPos-origin
    if direction.Magnitude<=.01 then return true end
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={Camera,LocalPlayer.Character}
    params.IgnoreWater=true
    local hit=workspace:Raycast(origin,direction,params)
    return not hit or hit.Instance:IsDescendantOf(char)
end

local function getProjectedBounds(model)
    if not model or not model:IsDescendantOf(workspace) or not Camera then return nil end
    local ok,boxCF,boxSize=pcall(function() return model:GetBoundingBox() end)
    if not ok or not boxCF or not boxSize then return nil end
    local half=boxSize*0.5
    local corners={
        boxCF:PointToWorldSpace(Vector3.new(-half.X,-half.Y,-half.Z)),
        boxCF:PointToWorldSpace(Vector3.new(-half.X,-half.Y, half.Z)),
        boxCF:PointToWorldSpace(Vector3.new(-half.X, half.Y,-half.Z)),
        boxCF:PointToWorldSpace(Vector3.new(-half.X, half.Y, half.Z)),
        boxCF:PointToWorldSpace(Vector3.new( half.X,-half.Y,-half.Z)),
        boxCF:PointToWorldSpace(Vector3.new( half.X,-half.Y, half.Z)),
        boxCF:PointToWorldSpace(Vector3.new( half.X, half.Y,-half.Z)),
        boxCF:PointToWorldSpace(Vector3.new( half.X, half.Y, half.Z))
    }
    local minX,minY=math.huge,math.huge
    local maxX,maxY=-math.huge,-math.huge
    local anyFront=false
    for _,worldPos in ipairs(corners) do
        local screen=Camera:WorldToViewportPoint(worldPos)
        if screen.Z>0 then
            anyFront=true
            minX=math.min(minX,screen.X)
            maxX=math.max(maxX,screen.X)
            minY=math.min(minY,screen.Y)
            maxY=math.max(maxY,screen.Y)
        end
    end
    if not anyFront then return nil end
    local width=math.max(maxX-minX,10)
    local height=math.max(maxY-minY,18)
    return minX,minY,width,height,(minX+maxX)*0.5
end

--// RELIABLE ESP RENDER
table.insert(Cleanups,RunService.RenderStepped:Connect(function(dt)
    Camera=workspace.CurrentCamera or Camera
    if not Camera then return end

    reconcileClock+=dt
    if reconcileClock>=RECONCILE_INTERVAL then
        reconcileClock=0
        reconcilePlayers()
    end

    local vp=Camera.ViewportSize
    local tracerOrigin=Vector2.new(vp.X*.5,vp.Y-10)
    local camPos=Camera.CFrame.Position

    FOVCircle.Visible=Config.Visuals.FOVCircle
    FOVCircle.Size=UDim2.fromOffset(Config.Aim.FOV*2,Config.Aim.FOV*2)
    Crosshair.Visible=Config.Visuals.Crosshair

    for p,esp in pairs(ESPCache) do
        local char=esp.Character
        -- A corpse/old model must NEVER be rendered, even for one frame.
        -- The authoritative character is always p.Character.
        if char ~= p.Character then
            hideESP(esp)
            char=nil
        end
        local hum,root,head=getCharParts(char)
        local visible=false
        local highlight=esp.Highlight

        -- Never use p.Character directly here. Only the currently reconciled
        -- character can be rendered.
        if isLocalPlayerObject(p) or not char or char~=p.Character or isLocalCharacter(char) then
            hideESP(esp)
            continue
        end

        if not char:IsDescendantOf(workspace) or not isAlive(char,hum) then
            hideESP(esp)
            continue
        end

        if highlight then
            highlight.FillColor=C.Accent
            highlight.OutlineColor=C.Accent2
            highlight.FillTransparency=Config.ESP.Fill and Config.ESP.FillTransparency or 1
            highlight.OutlineTransparency=Config.ESP.OutlineTransparency
            highlight.Adornee=char
        end

        if Config.ESP.Enabled and root and head and not sameTeam(p,Config.ESP.TeamCheck) then
            local distance=(camPos-root.Position).Magnitude
            if distance<=Config.ESP.MaxDistance then
                local pass=true
                if Config.ESP.ShowOnlyVisible then pass=isTargetVisibleForESP(head.Position,char) end
                if pass then
                    local minX,minY,w,h,centerX=getProjectedBounds(char)
                    if highlight then highlight.Enabled=true end

                    if minX then
                        esp.Box.Size=UDim2.fromOffset(w,h)
                        esp.Box.Position=UDim2.fromOffset(minX,minY)
                        esp.Box.Visible=Config.ESP.Box

                        local tagW=math.max(w+100,180)
                        esp.Tag.Size=UDim2.fromOffset(tagW,16)
                        esp.Tag.Position=UDim2.fromOffset(centerX-tagW*.5,minY-18)
                        esp.Tag.Text=p.DisplayName.." (@"..p.Name..")"
                        esp.Tag.Visible=Config.ESP.Name

                        local hp,maxHp=readCharacterHealth(char,hum)
                        local hpRatio=math.clamp(hp/maxHp,0,1)

                        esp.Info.Position=UDim2.fromOffset(centerX-90,minY+h+2)
                        esp.Info.Text=string.format("%dm • %d HP",math.floor(distance),math.floor(hp))
                        esp.Info.Visible=Config.ESP.Distance

                        esp.HPBack.Size=UDim2.fromOffset(4,h)
                        esp.HPBack.Position=UDim2.fromOffset(minX-7,minY)
                        esp.HPBack.Visible=Config.ESP.Health
                        -- Anchor the fill to the bottom and use a real ratio of the
                        -- CURRENT Humanoid.Health. Scale is recalculated every frame,
                        -- so damage immediately shortens the bar.
                        esp.HPFill.AnchorPoint=Vector2.new(0,1)
                        esp.HPFill.Position=UDim2.new(0,0,1,0)
                        esp.HPFill.Size=UDim2.new(1,0,hpRatio,0)

                        if Config.ESP.Tracer then
                            local delta=Vector2.new(centerX,minY+h*.5)-tracerOrigin
                            esp.Tracer.Position=UDim2.fromOffset(tracerOrigin.X+delta.X*.5,tracerOrigin.Y+delta.Y*.5)
                            esp.Tracer.Size=UDim2.fromOffset(math.max(delta.Magnitude,1),1.5)
                            esp.Tracer.Rotation=math.deg(math.atan2(delta.Y,delta.X))
                            esp.Tracer.Visible=true
                        else
                            esp.Tracer.Visible=false
                        end
                    else
                        esp.Box.Visible=false
                        esp.Tag.Visible=false
                        esp.Info.Visible=false
                        esp.HPBack.Visible=false
                        esp.Tracer.Visible=false
                    end
                    visible=true
                end
            end
        end

        if not visible then
            esp.Box.Visible=false
            esp.Tag.Visible=false
            esp.Info.Visible=false
            esp.HPBack.Visible=false
            esp.Tracer.Visible=false
            if highlight then highlight.Enabled=false end
        end
    end
end))

--// AIM
local LockedPlayer=nil
local LockedCharacter=nil
local LockInvalidSince=nil
local AutoFireHeld=false
local LastAutoFire=0
local LastFireButtonScan=0
local CachedFireButton=nil
local NextAimValidation=0
local NextTargetSearch=0
local CachedAimBone=nil
local AimSmoothedPosition=nil
local AimSmoothTarget=nil

local function invalidateLock()
    LockedPlayer=nil
    LockedCharacter=nil
    LockInvalidSince=nil
    CachedAimBone=nil
    NextAimValidation=0
    NextTargetSearch=0
    AimSmoothedPosition=nil
    AimSmoothTarget=nil
end

local function getAimPart(char)
    if not char then return nil end
    local hum,root,head=getCharParts(char)
    if not hum or hum.Health<=0 then return nil end

    local candidates={}
    if head then table.insert(candidates,head) end
    local upper=char:FindFirstChild("UpperTorso")
    if upper and upper:IsA("BasePart") and upper~=head then table.insert(candidates,upper) end
    if root and root~=head and root~=upper then table.insert(candidates,root) end

    local best,bestScore=nil,math.huge
    local center=Camera and Camera.ViewportSize*0.5 or Vector2.new(0,0)
    for _,part in ipairs(candidates) do
        if part:IsA("BasePart") and part:IsDescendantOf(char) then
            local point=Camera:WorldToViewportPoint(part.Position)
            if point.Z>0 then
                local screenDelta=(Vector2.new(point.X,point.Y)-center).Magnitude
                local bias=(part==head) and 0 or 6
                local score=screenDelta+bias
                if score<bestScore then bestScore=score; best=part end
            end
        end
    end
    return best or head or root
end

local function isAimTargetVisible(targetPart,targetCharacter)
    if isLocalCharacter(targetCharacter) or isLocalPart(targetPart) then return false end
    if not Config.Aim.WallCheck then return true end
    if not Camera or not targetPart or not targetCharacter then return false end
    local origin=Camera.CFrame.Position
    local direction=targetPart.Position-origin
    if direction.Magnitude<=.01 then return true end
    local params=RaycastParams.new()
    params.FilterType=Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances={Camera,LocalPlayer.Character}
    params.IgnoreWater=true
    local hit=workspace:Raycast(origin,direction,params)
    return not hit or hit.Instance:IsDescendantOf(targetCharacter)
end

local function getAimScore(part,distance)
    if not Camera or not part then return math.huge end
    local point=Camera:WorldToViewportPoint(part.Position)
    if point.Z<=0 then return math.huge end
    local center=Camera.ViewportSize*0.5
    local screenDistance=(Vector2.new(point.X,point.Y)-center).Magnitude
    local fov=math.max(40,tonumber(Config.Aim.FOV) or 150)
    local angleBias=screenDistance/fov
    local distanceBias=math.clamp(distance/math.max(Config.Aim.MaxDistance,1),0,1)*0.08
    return angleBias+distanceBias
end

local function isValidAimTarget(p)
    if isLocalPlayerObject(p) then return false,nil,nil,nil end
    local char=p and p.Character
    if not char or not char:IsDescendantOf(workspace) or isLocalCharacter(char) then return false,nil,nil,nil end
    local hum,root,head=getCharParts(char)
    -- Reject dead/dead-state characters immediately; never use a stale corpse.
    local liveHp=readCharacterHealth(char,hum)
    if not hum or hum.Health <= 0 or liveHp <= 0
        or hum:GetState() == Enum.HumanoidStateType.Dead or hasDeadMarker(char) then
        return false,nil,nil,nil
    end
    if hasPlayerDeadMarker(p) or hasDeadMarker(char) or not isAlive(char,hum) or not root then return false,nil,nil,nil end
    if sameTeam(p,Config.Aim.TeamCheck) then return false,nil,nil,nil end
    local bone=getAimPart(char)
    if not bone or not bone:IsDescendantOf(char) then return false,nil,nil,nil end
    local distance=(Camera.CFrame.Position-bone.Position).Magnitude
    if distance>Config.Aim.MaxDistance then return false,nil,nil,nil end
    if not isAimTargetVisible(bone,char) then return false,nil,nil,nil end
    local score=getAimScore(bone,distance)
    if score==math.huge then return false,nil,nil,nil end
    return true,bone,distance,char,score
end

local function chooseBestTarget()
    if not Config.Aim.Enabled or not Camera then return nil,nil,nil end
    local bestPlayer,bestPart,bestChar=nil,nil,nil
    local bestMetric=math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if not isLocalPlayerObject(p) then
            local valid,bone,distance,char,score=isValidAimTarget(p)
            if valid and bone then
                local metric=score
                if Config.Aim.PrioritizeDistance then metric=distance+score*35 end
                if metric<bestMetric then
                    bestMetric=metric
                    bestPlayer=p
                    bestPart=bone
                    bestChar=char
                end
            end
        end
    end
    return bestPlayer,bestPart,bestChar
end

local function getStickyTarget()
    local now=os.clock()
    if LockedPlayer and LockedCharacter then
        if LockedPlayer.Character~=LockedCharacter or not LockedCharacter:IsDescendantOf(workspace) then
            invalidateLock()
        else
            -- Full target validation is intentionally throttled. Camera tracking
            -- still runs every frame, but raycasts/health scans do not.
            if now>=NextAimValidation then
                NextAimValidation=now+0.055
                local valid,bone,_,char=isValidAimTarget(LockedPlayer)
                if valid and bone and char==LockedCharacter then
                    CachedAimBone=bone
                    LockInvalidSince=nil
                else
                    CachedAimBone=nil
                    if not LockInvalidSince then LockInvalidSince=now end
                    local grace=tonumber(Config.Aim.LockGraceTime) or .08
                    if now-LockInvalidSince>=grace then
                        invalidateLock()
                    end
                end
            end
            if LockedPlayer and LockedCharacter and CachedAimBone and CachedAimBone:IsDescendantOf(LockedCharacter) then
                return CachedAimBone
            end
        end
    end

    if not LockedPlayer then
        if now<NextTargetSearch then return nil end
        NextTargetSearch=now+0.075
        local p,bone,char=chooseBestTarget()
        if p and bone and char then
            LockedPlayer=p
            LockedCharacter=char
            CachedAimBone=bone
            NextAimValidation=now+0.055
            LockInvalidSince=nil
            AimSmoothTarget=p
            AimSmoothedPosition=bone.Position
            return bone
        end
    end
    return nil
end

local function stopAutoFire()
    -- Auto Fire never owns the physical cursor/keyboard now. Keep this
    -- function purely as state cleanup so disabling it cannot interfere with
    -- player movement or the menu.
    AutoFireHeld=false
end

local function isMouseOverMenu()
    if not MenuVisible then return false end
    local guiService=safeService("GuiService")
    if not guiService then return false end
    local loc=UIS:GetMouseLocation()
    local ok,objects=pcall(function()
        return guiService:GetGuiObjectsAtPosition(loc.X,loc.Y)
    end)
    if not ok or type(objects)~="table" then return false end
    for _,obj in ipairs(objects) do
        if obj and (obj:IsDescendantOf(MenuGui) or obj:IsDescendantOf(OpenBar)) then
            return true
        end
    end
    return false
end

local function getEquippedTool()
    local char=LocalPlayer and LocalPlayer.Character
    if not char then return nil end
    for _,obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") then return obj end
    end
    return nil
end

local function scoreFireButton(obj, vp)
    if not obj or not obj:IsA("GuiButton") or not obj.Visible or not obj.Active then return -math.huge end
    if MenuGui and obj:IsDescendantOf(MenuGui) then return -math.huge end
    if OpenBar and obj:IsDescendantOf(OpenBar) then return -math.huge end

    local pos=obj.AbsolutePosition
    local size=obj.AbsoluteSize
    if size.X<35 or size.Y<35 then return -math.huge end
    local cx=pos.X+size.X*.5
    local cy=pos.Y+size.Y*.5
    local nx=cx/math.max(vp.X,1)
    local ny=cy/math.max(vp.Y,1)

    -- Mobile FPS fire buttons are normally large, round-ish controls on the
    -- right side around the vertical middle. Prefer that geometry when the
    -- game does not expose a useful button name/text.
    if nx<0.70 or ny<0.28 or ny>0.72 then return -math.huge end
    local aspect=math.min(size.X,size.Y)/math.max(size.X,size.Y)
    if aspect<0.55 then return -math.huge end

    local name=string.lower(obj.Name.." "..(obj:IsA("TextButton") and obj.Text or ""))
    local score=0
    local words={"fire","shoot","attack","primary","trigger","weapon","shot","gun"}
    for i,word in ipairs(words) do
        if string.find(name,word,1,true) then score+=160-i*8 end
    end

    -- Strong positional score for the typical mobile fire control.
    score += math.max(0,1-math.abs(nx-.865)/.20)*90
    score += math.max(0,1-math.abs(ny-.50)/.25)*70
    score += aspect*30
    local area=size.X*size.Y
    score += math.clamp(area/12000,0,25)
    return score
end

local function findFireButton(force)
    local now=os.clock()
    if not force and CachedFireButton and CachedFireButton.Parent and CachedFireButton.Visible and CachedFireButton.Active then
        return CachedFireButton
    end
    if not force and now-LastFireButtonScan<0.60 then return nil end
    LastFireButtonScan=now
    CachedFireButton=nil

    local playerGui=LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then return nil end
    local camera=workspace.CurrentCamera
    local vp=camera and camera.ViewportSize or Vector2.new(1920,1080)
    local best,bestScore=nil,-math.huge

    for _,obj in ipairs(playerGui:GetDescendants()) do
        if obj:IsA("GuiButton") then
            local score=scoreFireButton(obj,vp)
            if score>bestScore then
                bestScore=score
                best=obj
            end
        end
    end

    if best and bestScore>=45 then
        CachedFireButton=best
    end
    return CachedFireButton
end

local function fireThroughGuiButton()
    local button=findFireButton(false)
    if not button then button=findFireButton(true) end
    if not button then return false end

    local fired=false
    pcall(function()
        button:Activate()
        fired=true
    end)
    if fired then return true end

    if firesignal then
        pcall(function()
            firesignal(button.Activated)
            fired=true
        end)
    end
    return fired
end

local function touchFireButton()
    local button=findFireButton(false)
    if not button then return false end
    if not VIM then return false end

    local pos=button.AbsolutePosition
    local size=button.AbsoluteSize
    local x=pos.X+size.X*.5
    local y=pos.Y+size.Y*.5

    local ok=false
    pcall(function()
        -- Touch input does not move the mouse cursor and therefore does not
        -- steal camera/menu input on mobile.
        VIM:SendTouchEvent(1,Enum.UserInputState.Begin,x,y)
        VIM:SendTouchEvent(1,Enum.UserInputState.End,x,y)
        ok=true
    end)
    return ok
end

local function fireOnceWithoutStealingMovement()
    -- First try the game's actual Tool API.
    local char=LocalPlayer and LocalPlayer.Character
    local tool=char and getEquippedTool()
    if tool and tool.Parent==char and tool.Enabled~=false then
        local ok=pcall(function() tool:Activate() end)
        if ok then return true end
    end

    -- Then activate the game's own fire GUI. This works for mobile weapons
    -- that are not standard Tool weapons and does not move the cursor.
    if fireThroughGuiButton() then return true end

    -- Last mobile-only fallback: synthesize a touch on the cached fire button.
    return touchFireButton()
end

local function autoFire(targetPart)
    if not Config.Aim.AutoFire or not Config.Aim.Enabled or not targetPart then
        stopAutoFire()
        return
    end

    local char=LockedCharacter
    local player=LockedPlayer
    if not player or not char or player.Character~=char or not char:IsDescendantOf(workspace)
        or not targetPart:IsDescendantOf(char) then
        stopAutoFire()
        invalidateLock()
        return
    end

    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health<=0 or hum:GetState()==Enum.HumanoidStateType.Dead
        or hasPlayerDeadMarker(player) or hasDeadMarker(char) then
        stopAutoFire()
        invalidateLock()
        return
    end

    local point,onScreen=Camera:WorldToViewportPoint(targetPart.Position)
    local center=Camera.ViewportSize*0.5
    local distance2d=(Vector2.new(point.X,point.Y)-center).Magnitude
    if not onScreen or point.Z<=0 or distance2d>math.max(10,tonumber(Config.Aim.FOV) or 150)*0.18 then
        stopAutoFire()
        return
    end

    local now=os.clock()
    if now-LastAutoFire<0.11 then return end

    -- Use the same cached target instead of doing another full player scan and
    -- raycast for every shot. The lock is independently revalidated at 18 Hz.
    if CachedAimBone~=targetPart or LockedPlayer.Character~=char then
        stopAutoFire()
        return
    end

    LastAutoFire=now
    local fired=fireOnceWithoutStealingMovement()
    if not fired then
        -- Retry button discovery occasionally rather than scanning PlayerGui
        -- every frame (which was a major source of FPS drops).
        CachedFireButton=nil
        LastFireButtonScan=0
    end
end

local function rotateCameraToward(targetPosition,dt)
    if not Camera or not targetPosition or Camera.CameraType==Enum.CameraType.Scriptable then return end
    local targetPlayer=LockedPlayer
    if AimSmoothTarget~=targetPlayer then
        AimSmoothTarget=targetPlayer
        AimSmoothedPosition=targetPosition
    else
        local previous=AimSmoothedPosition or targetPosition
        local jump=(targetPosition-previous).Magnitude
        if jump>20 then AimSmoothedPosition=targetPosition
        else
            local smooth=math.clamp(tonumber(Config.Aim.Smoothness) or 0.18,0.02,0.8)
            local responseRate=28+(1-smooth)*34
            local response=1-math.exp(-math.max(dt,1/240)*responseRate)
            AimSmoothedPosition=previous:Lerp(targetPosition,response)
        end
    end

    local pos=Camera.CFrame.Position
    local offset=AimSmoothedPosition-pos
    if offset.Magnitude<0.05 then return end
    local desiredLook=offset.Unit
    local currentCF=Camera.CFrame
    local dot=math.clamp(currentCF.LookVector:Dot(desiredLook),-1,1)
    local angle=math.acos(dot)
    if angle<0.00015 then return end

    local up=currentCF.UpVector-desiredLook*currentCF.UpVector:Dot(desiredLook)
    if up.Magnitude<0.001 then up=currentCF.RightVector:Cross(desiredLook) end
    if up.Magnitude<0.001 then up=Vector3.new(0,1,0) end
    up=up.Unit

    local desiredCF=CFrame.lookAt(pos,pos+desiredLook,up)
    local speed=math.clamp(tonumber(Config.Aim.TurnSpeed) or 4200,900,4200)
    local maxStep=math.rad(speed)*math.max(dt,1/240)
    local alpha=maxStep>=angle and 1 or math.clamp(maxStep/angle,0,1)
    if alpha<0.002 then return end
    Camera.CFrame=currentCF:Lerp(desiredCF,alpha)
end

RunService:BindToRenderStep("ShutAimEngine",Enum.RenderPriority.Camera.Value+1,function(dt)
    Camera=workspace.CurrentCamera or Camera
    if not Camera then return end

    if not Config.Aim.Enabled then
        invalidateLock()
        stopAutoFire()
        return
    end

    local targetBone=getStickyTarget()
    if not targetBone or not LockedPlayer or not LockedCharacter then
        stopAutoFire()
        return
    end

    if isLocalPlayerObject(LockedPlayer)
        or LockedPlayer.Character~=LockedCharacter
        or isLocalCharacter(LockedCharacter)
        or isLocalPart(targetBone)
        or not targetBone:IsDescendantOf(LockedCharacter) then
        invalidateLock()
        stopAutoFire()
        return
    end

    rotateCameraToward(targetBone.Position,dt)
    autoFire(targetBone)
end)

--// RUNTIME
local frames,elapsed=0,0
table.insert(Cleanups,RunService.RenderStepped:Connect(function(dt)
    frames+=1
    elapsed+=dt
    if elapsed>=.5 then
        local fps=math.floor(frames/elapsed+.5)
        BarFPS.Text="FPS: "..tostring(fps)
        BarMSK.Text="MSK: "..getMSKTimeString()
        local vp=Camera and Camera.ViewportSize or Vector2.zero
        engInfo.Text=string.format(
            "Version: %s | FPS: %d\nPlayers: %d | PlaceId: %d\nViewport: %dx%d | UI Scale: %.2f\nAim: %s | Lock: %s",
            SHUT_VERSION,fps,#Players:GetPlayers(),game.PlaceId,
            math.floor(vp.X),math.floor(vp.Y),MainScale.Scale,
            Config.Aim.Enabled and "ON" or "OFF",
            LockedPlayer and LockedPlayer.Name or "NONE"
        )
        frames=0
        elapsed=0
    end
end))

Main.Position=UDim2.fromScale(.5,.5)
Shadow.Position=UDim2.fromScale(.5,.5)
setMenuVisible(true)
