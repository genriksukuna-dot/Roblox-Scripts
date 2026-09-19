--[[
    SNIPER ARENA v2
    Stable 360° Aim + Wall Check + Reliable ESP + Config Manager
]]

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

local LocalPlayer = (cloneref and cloneref(Players.LocalPlayer)) or Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// BRAND
local SHUT_NAME = "Sniper Arena"
local SHUT_VERSION = "v2.0"
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
        Enabled = true,
        Box = true,
        Name = true,
        Health = true,
        Distance = true,
        Tracer = true,
        TeamCheck = false,
        MaxDistance = 1500,
        Fill = false,
        FillTransparency = 0.85,
        OutlineTransparency = 0,
        ShowOnlyVisible = false
    },
    Aim = {
        Enabled = true,
        FOV = 150,
        MaxDistance = 1000,
        Smoothness = 0.18,
        TargetPart = "Head",
        TeamCheck = false,
        PrioritizeDistance = true,
        WallCheck = true
    },
    Visuals = {
        FOVCircle = true,
        Crosshair = true,
        FOVThickness = 1
    },
    UI = {
        MenuKey = "RightShift",
        Animations = true,
        Sounds = true,
        Notifications = true,
        TelegramPopup = true,
        CurrentTheme = "Purple"
    }
}

local function saveConfigFile()
    return pcall(function()
        if writefile then
            writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
        end
    end)
end

local function loadConfigFile()
    return pcall(function()
        if isfile and readfile and isfile(CONFIG_FILE) then
            local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE))
            for cat, settings in pairs(decoded) do
                if Config[cat] and type(settings) == "table" then
                    for k, v in pairs(settings) do
                        Config[cat][k] = v
                    end
                end
            end
        end
    end)
end

loadConfigFile()

--// HELPERS
local function tw(obj, time, props, style, direction)
    if not obj or not Config.UI.Animations then return end
    local ok, t = pcall(function()
        local x = TweenService:Create(
            obj,
            TweenInfo.new(time or .18, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
            props
        )
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
        if gethui then
            target = gethui()
        elseif game:GetService("CoreGui") then
            target = game:GetService("CoreGui")
        end
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
    MainScale.Scale = v.X < 720 and math.clamp(v.X/620,.60,.85)
        or v.X < 960 and .88 or 1
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
    saveConfigFile()
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
        else
            p.Visible=false
        end
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
local OpenTabGrad=gradient(OpenTab,C.Accent,C.Accent2)
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
            if not MenuVisible then
                Main.Visible=false
                Shadow.Visible=false
            end
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
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=false
    end
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
        pcall(function()
            if setclipboard then setclipboard(TELEGRAM_URL) end
        end)
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
    local root=char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("UpperTorso")
        or char:FindFirstChild("Torso")
        or char.PrimaryPart

    if not root then
        for _,obj in ipairs(char:GetChildren()) do
            if obj:IsA("BasePart") and obj.Name~="Handle" then
                root=obj
                break
            end
        end
    end

    local head=char:FindFirstChild("Head") or root
    return hum,root,head
end

local function isAlive(char,hum)
    return char and char:IsDescendantOf(workspace)
        and ((hum and hum.Health>0) or not hum)
end

local function sameTeam(p,teamCheck)
    return teamCheck
        and LocalPlayer.Team
        and p.Team
        and LocalPlayer.Team==p.Team
end

--// ESP
local ESPCache={}

local function purgeESP(p)
    local data=ESPCache[p]
    if not data then return end
    for _,obj in pairs(data) do
        if typeof(obj)=="Instance" then pcall(function() obj:Destroy() end) end
    end
    ESPCache[p]=nil
end

local function setupESPForPlayer(p)
    if p==LocalPlayer then return end
    purgeESP(p)

    local box=Instance.new("Frame",OverlayGui)
    box.BackgroundTransparency=1
    box.Visible=false
    box.ZIndex=12
    local boxStroke=stroke(box,C.Accent,0,1.2)

    local tag=text(OverlayGui,"",UDim2.fromOffset(260,16),UDim2.fromScale(0,0),10,C.White,15)
    tag.TextXAlignment=Enum.TextXAlignment.Center
    tag.Visible=false

    local info=text(OverlayGui,"",UDim2.fromOffset(260,16),UDim2.fromScale(0,0),8,C.Sub,15)
    info.TextXAlignment=Enum.TextXAlignment.Center
    info.Visible=false

    local hpBack=Instance.new("Frame",OverlayGui)
    hpBack.BackgroundColor3=Color3.fromRGB(25,25,30)
    hpBack.BorderSizePixel=0
    hpBack.Visible=false
    hpBack.ZIndex=13
    corner(hpBack,4)

    local hpFill=Instance.new("Frame",hpBack)
    hpFill.AnchorPoint=Vector2.new(0,1)
    hpFill.Position=UDim2.fromScale(0,1)
    hpFill.Size=UDim2.fromScale(1,1)
    hpFill.BackgroundColor3=C.Green
    hpFill.BorderSizePixel=0
    hpFill.ZIndex=14
    corner(hpFill,4)

    local tracer=Instance.new("Frame",OverlayGui)
    tracer.AnchorPoint=Vector2.new(.5,.5)
    tracer.BackgroundColor3=C.Accent
    tracer.BorderSizePixel=0
    tracer.Visible=false
    tracer.ZIndex=14

    ESPCache[p]={Box=box,BoxStroke=boxStroke,Tag=tag,Info=info,HPBack=hpBack,HPFill=hpFill,Tracer=tracer}
end

for _,p in ipairs(Players:GetPlayers()) do setupESPForPlayer(p) end
table.insert(Cleanups,Players.PlayerAdded:Connect(setupESPForPlayer))
table.insert(Cleanups,Players.PlayerRemoving:Connect(purgeESP))

-- Visible check is ONLY used when the user enables "Visible Only".
local function isTargetVisibleForESP(targetPos,char)
    if not Camera or not targetPos or not char then return false end

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

--// RELIABLE ESP RENDER
table.insert(Cleanups,RunService.RenderStepped:Connect(function()
    Camera=workspace.CurrentCamera or Camera
    if not Camera then return end

    local vp=Camera.ViewportSize
    local tracerOrigin=Vector2.new(vp.X*.5,vp.Y-10)
    local camPos=Camera.CFrame.Position

    FOVCircle.Visible=Config.Visuals.FOVCircle
    FOVCircle.Size=UDim2.fromOffset(Config.Aim.FOV*2,Config.Aim.FOV*2)
    Crosshair.Visible=Config.Visuals.Crosshair

    for p,esp in pairs(ESPCache) do
        local char=p.Character
        local hum,root,head=getCharParts(char)
        local visible=false

        if Config.ESP.Enabled and char and root and head and isAlive(char,hum) and not sameTeam(p,Config.ESP.TeamCheck) then
            local distance=(camPos-root.Position).Magnitude

            if distance<=Config.ESP.MaxDistance then
                local pass=true
                if Config.ESP.ShowOnlyVisible then
                    pass=isTargetVisibleForESP(head.Position,char)
                end

                if pass then
                    -- Use several body points to keep the box stable on different rigs.
                    local points={
                        head.Position+Vector3.new(0,1.4,0),
                        root.Position+Vector3.new(0,2.4,0),
                        root.Position-Vector3.new(0,3.0,0)
                    }

                    local minX,maxX,minY,maxY
                    local anyFront=false

                    for _,worldPos in ipairs(points) do
                        local screen=Camera:WorldToViewportPoint(worldPos)
                        if screen.Z>0 then
                            anyFront=true
                            minX=minX and math.min(minX,screen.X) or screen.X
                            maxX=maxX and math.max(maxX,screen.X) or screen.X
                            minY=minY and math.min(minY,screen.Y) or screen.Y
                            maxY=maxY and math.max(maxY,screen.Y) or screen.Y
                        end
                    end

                    if anyFront then
                        local h=math.max(maxY-minY,18)
                        local w=math.max(h*.52,14)
                        local centerX=(minX+maxX)*.5

                        -- Expand a little because some rigs have very narrow point spread.
                        minX=centerX-w*.5
                        maxX=centerX+w*.5

                        esp.Box.Size=UDim2.fromOffset(maxX-minX,h)
                        esp.Box.Position=UDim2.fromOffset(minX,minY)
                        esp.Box.Visible=Config.ESP.Box

                        esp.Tag.Size=UDim2.fromOffset(math.max(w+100,180),16)
                        esp.Tag.Position=UDim2.fromOffset(centerX-math.max(w+100,180)*.5,minY-18)
                        esp.Tag.Text=p.DisplayName.." (@"..p.Name..")"
                        esp.Tag.Visible=Config.ESP.Name

                        local hp=hum and math.max(0,hum.Health) or 100
                        local maxHp=hum and math.max(1,hum.MaxHealth) or 100
                        local hpRatio=math.clamp(hp/maxHp,0,1)

                        esp.Info.Position=UDim2.fromOffset(centerX-90,minY+h+2)
                        esp.Info.Text=string.format("%dm • %d HP",math.floor(distance),math.floor(hp))
                        esp.Info.Visible=Config.ESP.Distance

                        esp.HPBack.Size=UDim2.fromOffset(4,h)
                        esp.HPBack.Position=UDim2.fromOffset(minX-7,minY)
                        esp.HPBack.Visible=Config.ESP.Health
                        esp.HPFill.Size=UDim2.new(1,0,hpRatio,0)

                        if Config.ESP.Tracer then
                            local delta=Vector2.new(centerX,minY+h*.5)-tracerOrigin
                            esp.Tracer.Position=UDim2.fromOffset(tracerOrigin.X+delta.X*.5,tracerOrigin.Y+delta.Y*.5)
                            esp.Tracer.Size=UDim2.fromOffset(delta.Magnitude,1.5)
                            esp.Tracer.Rotation=math.deg(math.atan2(delta.Y,delta.X))
                            esp.Tracer.Visible=true
                        else
                            esp.Tracer.Visible=false
                        end

                        visible=true
                    end
                end
            end
        end

        if not visible then
            esp.Box.Visible=false
            esp.Tag.Visible=false
            esp.Info.Visible=false
            esp.HPBack.Visible=false
            esp.Tracer.Visible=false
        end
    end
end))

--// STABLE 360° AIM
local LockedPlayer=nil

local function getAimPart(char)
    if not char then return nil end
    local _,root,head=getCharParts(char)
    if Config.Aim.TargetPart=="Head" then
        return head or root
    end
    return root or head
end

-- IMPORTANT:
-- This raycast excludes only the local character and camera.
-- The target is NOT excluded, so a wall correctly blocks the lock.
local function isAimTargetVisible(targetPart,targetCharacter)
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

    if not hit then
        return true
    end

    return hit.Instance:IsDescendantOf(targetCharacter)
end

local function isValidAimTarget(p)
    if not p or p==LocalPlayer then return false,nil,nil end

    local char=p.Character
    if not char or not char:IsDescendantOf(workspace) then return false,nil,nil end

    local hum,root,head=getCharParts(char)
    if not root or not isAlive(char,hum) then return false,nil,nil end
    if sameTeam(p,Config.Aim.TeamCheck) then return false,nil,nil end

    local bone=getAimPart(char)
    if not bone then return false,nil,nil end

    local distance=(Camera.CFrame.Position-bone.Position).Magnitude
    if distance>Config.Aim.MaxDistance then return false,nil,nil end

    if not isAimTargetVisible(bone,char) then
        return false,nil,nil
    end

    return true,bone,distance
end

local function getBestTargetPart()
    if not Config.Aim.Enabled or not Camera then
        LockedPlayer=nil
        return nil
    end

    -- Keep the current target until it becomes invalid.
    -- This removes target switching jitter.
    if LockedPlayer then
        local valid,bone=isValidAimTarget(LockedPlayer)
        if valid and bone then
            return bone
        end
        LockedPlayer=nil
    end

    local bestPlayer=nil
    local bestPart=nil
    local bestMetric=math.huge

    for _,p in ipairs(Players:GetPlayers()) do
        local valid,bone,distance=isValidAimTarget(p)

        if valid and bone then
            local metric

            if Config.Aim.PrioritizeDistance then
                metric=distance
            else
                -- Full 360° angular metric. No on-screen requirement.
                local look=Camera.CFrame.LookVector
                local dir=(bone.Position-Camera.CFrame.Position).Unit
                metric=math.acos(math.clamp(look:Dot(dir),-1,1))
            end

            if metric<bestMetric then
                bestMetric=metric
                bestPlayer=p
                bestPart=bone
            end
        end
    end

    LockedPlayer=bestPlayer
    return bestPart
end

RunService:BindToRenderStep(
    "ShutAimEngine",
    Enum.RenderPriority.Camera.Value+1,
    function()
        if not Config.Aim.Enabled then
            LockedPlayer=nil
            return
        end

        Camera=workspace.CurrentCamera or Camera
        if not Camera then
            LockedPlayer=nil
            return
        end

        local targetBone=getBestTargetPart()
        if not targetBone or not LockedPlayer then
            return
        end

        local char=LockedPlayer.Character
        if not char or not isAimTargetVisible(targetBone,char) then
            LockedPlayer=nil
            return
        end

        -- HARD LOCK:
        -- no Lerp, no FOV/on-screen restriction, no gradual camera drift.
        -- Camera rotates directly to the valid target.
        local cameraPosition=Camera.CFrame.Position
        Camera.CFrame=CFrame.lookAt(cameraPosition,targetBone.Position)
    end
)

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
            SHUT_VERSION,
            fps,
            #Players:GetPlayers(),
            game.PlaceId,
            math.floor(vp.X),
            math.floor(vp.Y),
            MainScale.Scale,
            Config.Aim.Enabled and "ON" or "OFF",
            LockedPlayer and LockedPlayer.Name or "NONE"
        )

        frames=0
        elapsed=0
    end
end))

setMenuVisible(true)
