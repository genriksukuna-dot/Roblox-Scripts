--============================================================
-- NEXUS MURDER DUEL • VEXAL FUNCTION PORT
-- Custom GUI only. Feature logic is based on the supplied Vexal script.
--============================================================

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Stats = game:GetService("Stats")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

if _G.NexusVexalCustomCleanup then
    pcall(_G.NexusVexalCustomCleanup)
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

_G.NexusVexalCustomCleanup = function()
    for _, c in ipairs(Connections) do
        pcall(function() c:Disconnect() end)
    end
    for _, inst in ipairs(Tracked) do
        pcall(function() inst:Destroy() end)
    end
    table.clear(Connections)
    table.clear(Tracked)
end

local C = {
    BG = Color3.fromRGB(9, 8, 15),
    PANEL = Color3.fromRGB(17, 14, 27),
    PANEL2 = Color3.fromRGB(23, 19, 36),
    PANEL3 = Color3.fromRGB(45, 32, 72),
    CYAN = Color3.fromRGB(83, 231, 255),
    VIOLET = Color3.fromRGB(161, 92, 255),
    MAGENTA = Color3.fromRGB(255, 82, 197),
    ACCENT = Color3.fromRGB(185, 105, 255),
    ACCENT2 = Color3.fromRGB(101, 208, 255),
    GOOD = Color3.fromRGB(102, 232, 157),
    BAD = Color3.fromRGB(255, 104, 135),
    WARN = Color3.fromRGB(255, 208, 100),
    TEXT = Color3.fromRGB(246, 243, 252),
    MUTED = Color3.fromRGB(150, 143, 171),
    OUTLINE = Color3.fromRGB(79, 67, 107),
}
local FONT = Enum.Font.Gotham
local BOLD = Enum.Font.GothamBold

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function addStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local Gui = track(Instance.new("ScreenGui"))
Gui.Name = "NexusVexalCustom"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder = 999
Gui.Parent = PlayerGui

local Main = track(Instance.new("Frame"))
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.52)
Main.Size = UDim2.fromOffset(610, 460)
Main.BackgroundColor3 = C.BG
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = Gui
addCorner(Main, 18)
addStroke(Main, C.OUTLINE, 1, 0.15)

local Scale = Instance.new("UIScale")
Scale.Parent = Main

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(11,8,22)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18,22,47)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(28,9,29)),
})
gradient.Rotation = 20
gradient.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,58)
Header.BackgroundTransparency = 1
Header.Active = true
Header.Parent = Main

local HeaderLine = Instance.new("Frame")
HeaderLine.Position = UDim2.fromOffset(18,49)
HeaderLine.Size = UDim2.new(1,-36,0,2)
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header
addCorner(HeaderLine,99)
local hg = Instance.new("UIGradient")
hg.Color = ColorSequence.new(C.CYAN,C.MAGENTA)
hg.Parent = HeaderLine

local Brand = Instance.new("TextLabel")
Brand.BackgroundTransparency = 1
Brand.Position = UDim2.fromOffset(18,7)
Brand.Size = UDim2.new(0.7,0,0,24)
Brand.Font = BOLD
Brand.Text = "✦ NEXUS VEXAL"
Brand.TextSize = 15
Brand.TextColor3 = C.CYAN
Brand.TextXAlignment = Enum.TextXAlignment.Left
Brand.Parent = Header

local Sub = Instance.new("TextLabel")
Sub.BackgroundTransparency = 1
Sub.Position = UDim2.fromOffset(19,30)
Sub.Size = UDim2.new(0.7,0,0,16)
Sub.Font = FONT
Sub.Text = "FULL VEXAL FEATURE PACK • CUSTOM UI"
Sub.TextSize = 8
Sub.TextColor3 = C.MUTED
Sub.TextXAlignment = Enum.TextXAlignment.Left
Sub.Parent = Header

local Tag = Instance.new("TextLabel")
Tag.AnchorPoint = Vector2.new(1,0)
Tag.Position = UDim2.new(1,-50,0,12)
Tag.Size = UDim2.fromOffset(56,22)
Tag.BackgroundColor3 = C.PANEL3
Tag.BorderSizePixel = 0
Tag.Font = BOLD
Tag.Text = "V3"
Tag.TextSize = 8
Tag.TextColor3 = C.ACCENT2
Tag.Parent = Header
addCorner(Tag,9)
addStroke(Tag,C.ACCENT,1,0.55)

local Min = Instance.new("TextButton")
Min.AnchorPoint = Vector2.new(1,0)
Min.Position = UDim2.new(1,-16,0,10)
Min.Size = UDim2.fromOffset(28,28)
Min.BackgroundColor3 = C.PANEL2
Min.BorderSizePixel = 0
Min.Text = "–"
Min.TextSize = 15
Min.Font = BOLD
Min.TextColor3 = C.TEXT
Min.AutoButtonColor = false
Min.Parent = Header
addCorner(Min,8)
addStroke(Min,C.CYAN,1,0.55)

local OpenButton = track(Instance.new("TextButton"))
OpenButton.AnchorPoint = Vector2.new(1,0)
OpenButton.Position = UDim2.fromOffset(62,80)
OpenButton.Size = UDim2.fromOffset(46,46)
OpenButton.BackgroundColor3 = C.PANEL2
OpenButton.BorderSizePixel = 0
OpenButton.Text = "N"
OpenButton.TextSize = 14
OpenButton.Font = BOLD
OpenButton.TextColor3 = C.TEXT
OpenButton.AutoButtonColor = false
OpenButton.Visible = false
OpenButton.ZIndex = 500
OpenButton.Parent = Gui
addCorner(OpenButton,12)
addStroke(OpenButton,C.ACCENT,1.2,0.1)

-- Drag the menu with mouse or touch.
local dragging = false
local dragStart = nil
local startPos = nil
connect(Header.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
connect(UserInputService.InputChanged, function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - dragStart
    Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end)

local Body = Instance.new("Frame")
Body.Position = UDim2.fromOffset(12,64)
Body.Size = UDim2.new(1,-24,1,-74)
Body.BackgroundTransparency = 1
Body.Parent = Main

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0,125,1,0)
Sidebar.BackgroundColor3 = C.PANEL
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Body
addCorner(Sidebar,13)
addStroke(Sidebar,C.OUTLINE,1,0.7)

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(134,0)
Content.Size = UDim2.new(1,-134,1,0)
Content.BackgroundColor3 = C.PANEL
Content.BorderSizePixel = 0
Content.ClipsDescendants = true
Content.Parent = Body
addCorner(Content,13)
addStroke(Content,C.OUTLINE,1,0.7)

local Pages = {}
local TabRefs = {}
local CurrentTab = "Main"

local TabData = {
    {Name="Main",Icon="⌂"},
    {Name="ESP",Icon="◉"},
    {Name="Kill All",Icon="☠"},
    {Name="Ability",Icon="ϟ"},
    {Name="Teleport",Icon="⌖"},
    {Name="FOV",Icon="⊙"},
    {Name="Status",Icon="◈"},
}

local function makeTab(i,data)
    local b=Instance.new("TextButton")
    b.AutoButtonColor=false
    b.BackgroundColor3=C.PANEL2
    b.BackgroundTransparency=0.9
    b.BorderSizePixel=0
    b.Position=UDim2.fromOffset(7,6+(i-1)*39)
    b.Size=UDim2.new(1,-14,0,35)
    b.Text=""
    b.Parent=Sidebar
    addCorner(b,10)
    local a=Instance.new("Frame")
    a.Position=UDim2.fromOffset(0,6)
    a.Size=UDim2.fromOffset(3,23)
    a.BackgroundColor3=C.CYAN
    a.BorderSizePixel=0
    a.Visible=false
    a.Parent=b
    addCorner(a,4)
    local ic=Instance.new("TextLabel")
    ic.BackgroundTransparency=1
    ic.Position=UDim2.fromOffset(10,0)
    ic.Size=UDim2.fromOffset(22,35)
    ic.Font=BOLD
    ic.Text=data.Icon
    ic.TextSize=13
    ic.TextColor3=C.MUTED
    ic.Parent=b
    local tx=Instance.new("TextLabel")
    tx.BackgroundTransparency=1
    tx.Position=UDim2.fromOffset(36,0)
    tx.Size=UDim2.new(1,-42,1,0)
    tx.Font=BOLD
    tx.Text=data.Name
    tx.TextSize=9
    tx.TextColor3=C.MUTED
    tx.TextXAlignment=Enum.TextXAlignment.Left
    tx.Parent=b
    TabRefs[data.Name]={Button=b,Icon=ic,Text=tx,Accent=a}
end
for i,d in ipairs(TabData) do makeTab(i,d) end

local function makePage(name)
    local p=Instance.new("ScrollingFrame")
    p.Name=name.."Page"
    p.Size=UDim2.fromScale(1,1)
    p.BackgroundTransparency=1
    p.BorderSizePixel=0
    p.Visible=false
    p.CanvasSize=UDim2.fromOffset(0,0)
    p.AutomaticCanvasSize=Enum.AutomaticSize.Y
    p.ScrollingDirection=Enum.ScrollingDirection.Y
    p.ScrollBarThickness=5
    p.ScrollBarImageColor3=C.ACCENT2
    p.ElasticBehavior=Enum.ElasticBehavior.Never
    p.Active=true
    p.Parent=Content
    local pad=Instance.new("Frame")
    pad.BackgroundTransparency=1
    pad.Size=UDim2.fromOffset(1,40)
    pad.Position=UDim2.fromOffset(0,1400)
    pad.Parent=p
    Pages[name]=p
    return p
end

local MainPage=makePage("Main")
local ESPPage=makePage("ESP")
local KillPage=makePage("Kill All")
local AbilityPage=makePage("Ability")
local TeleportPage=makePage("Teleport")
local FOVPage=makePage("FOV")
local StatusPage=makePage("Status")
local ExtraPages={Main=MainPage,["Kill All"]=KillPage,Ability=AbilityPage,Teleport=TeleportPage,FOV=FOVPage}

local function switchTab(name)
    CurrentTab=name
    for tab,ref in pairs(TabRefs) do
        local active=tab==name
        ref.Button.BackgroundColor3=active and C.PANEL3 or C.PANEL2
        ref.Button.BackgroundTransparency=active and 0.03 or 0.9
        ref.Icon.TextColor3=active and C.CYAN or C.MUTED
        ref.Text.TextColor3=active and C.TEXT or C.MUTED
        ref.Accent.Visible=active
    end
    for pageName,page in pairs(Pages) do page.Visible=(pageName==name) end
end
for name,ref in pairs(TabRefs) do connect(ref.Button.Activated,function() switchTab(name) end) end

connect(Min.Activated,function() Main.Visible=false; OpenButton.Visible=true end)
connect(OpenButton.Activated,function() Main.Visible=true; OpenButton.Visible=false end)

local NotifyHolder=track(Instance.new("Frame"))
NotifyHolder.AnchorPoint=Vector2.new(1,0)
NotifyHolder.Position=UDim2.new(1,-16,0,16)
NotifyHolder.Size=UDim2.fromOffset(290,300)
NotifyHolder.BackgroundTransparency=1
NotifyHolder.ZIndex=1000
NotifyHolder.Parent=Gui

local function notify(title,content,duration)
    local card=Instance.new("Frame")
    card.Size=UDim2.new(1,0,0,72)
    card.BackgroundColor3=C.PANEL2
    card.BorderSizePixel=0
    card.ZIndex=1001
    card.Parent=NotifyHolder
    addCorner(card,12)
    addStroke(card,C.ACCENT,1,0.2)
    local t=Instance.new("TextLabel")
    t.BackgroundTransparency=1
    t.Position=UDim2.fromOffset(12,9)
    t.Size=UDim2.new(1,-24,0,18)
    t.Font=BOLD
    t.Text=tostring(title)
    t.TextSize=10
    t.TextColor3=C.CYAN
    t.TextXAlignment=Enum.TextXAlignment.Left
    t.Parent=card
    local c=Instance.new("TextLabel")
    c.BackgroundTransparency=1
    c.Position=UDim2.fromOffset(12,29)
    c.Size=UDim2.new(1,-24,0,32)
    c.Font=FONT
    c.Text=tostring(content)
    c.TextSize=8
    c.TextWrapped=true
    c.TextColor3=C.MUTED
    c.TextXAlignment=Enum.TextXAlignment.Left
    c.Parent=card
    task.delay(duration or 2.5,function() if card.Parent then card:Destroy() end end)
end

local function makeTitle(parent,titleText,subText)
    local t=Instance.new("TextLabel")
    t.BackgroundTransparency=1
    t.Position=UDim2.fromOffset(14,11)
    t.Size=UDim2.new(1,-28,0,20)
    t.Font=BOLD
    t.Text=titleText
    t.TextSize=13
    t.TextColor3=C.TEXT
    t.TextXAlignment=Enum.TextXAlignment.Left
    t.Parent=parent
    local s=Instance.new("TextLabel")
    s.BackgroundTransparency=1
    s.Position=UDim2.fromOffset(14,31)
    s.Size=UDim2.new(1,-28,0,15)
    s.Font=FONT
    s.Text=subText
    s.TextSize=8
    s.TextColor3=C.MUTED
    s.TextXAlignment=Enum.TextXAlignment.Left
    s.Parent=parent
end

local function makeSection(parent,top,height,labelText)
    local s=Instance.new("Frame")
    s.Position=UDim2.fromOffset(12,top)
    s.Size=UDim2.new(1,-24,0,height)
    s.BackgroundColor3=C.PANEL2
    s.BorderSizePixel=0
    s.Parent=parent
    addCorner(s,12)
    addStroke(s,C.OUTLINE,1,0.72)
    local stripe=Instance.new("Frame")
    stripe.Position=UDim2.fromOffset(10,11)
    stripe.Size=UDim2.fromOffset(3,12)
    stripe.BackgroundColor3=C.ACCENT2
    stripe.BorderSizePixel=0
    stripe.Parent=s
    addCorner(stripe,3)
    local h=Instance.new("TextLabel")
    h.BackgroundTransparency=1
    h.Position=UDim2.fromOffset(20,8)
    h.Size=UDim2.new(1,-30,0,19)
    h.Font=BOLD
    h.Text=labelText
    h.TextSize=9
    h.TextColor3=C.ACCENT2
    h.TextXAlignment=Enum.TextXAlignment.Left
    h.Parent=s
    return s
end

local function makeButton(parent,top,text,callback)
    local b=Instance.new("TextButton")
    b.AutoButtonColor=false
    b.Position=UDim2.fromOffset(12,top)
    b.Size=UDim2.new(1,-24,0,29)
    b.BackgroundColor3=C.PANEL3
    b.BorderSizePixel=0
    b.Font=BOLD
    b.Text=text
    b.TextSize=8
    b.TextColor3=C.TEXT
    b.Parent=parent
    addCorner(b,8)
    addStroke(b,C.OUTLINE,1,0.3)
    connect(b.Activated,function() if callback then callback() end end)
    return b
end

local function makeToggle(parent,top,labelText,initial,callback)
    local b=Instance.new("TextButton")
    b.AutoButtonColor=false
    b.BackgroundTransparency=1
    b.Position=UDim2.fromOffset(12,top)
    b.Size=UDim2.new(1,-24,0,31)
    b.Text=""
    b.Parent=parent
    local l=Instance.new("TextLabel")
    l.BackgroundTransparency=1
    l.Position=UDim2.fromOffset(0,0)
    l.Size=UDim2.new(1,-55,1,0)
    l.Font=FONT
    l.Text=labelText
    l.TextSize=9
    l.TextColor3=initial and C.TEXT or C.MUTED
    l.TextXAlignment=Enum.TextXAlignment.Left
    l.Parent=b
    local tr=Instance.new("Frame")
    tr.AnchorPoint=Vector2.new(1,0.5)
    tr.Position=UDim2.new(1,0,0.5,0)
    tr.Size=UDim2.fromOffset(38,19)
    tr.BackgroundColor3=initial and C.ACCENT or C.PANEL3
    tr.BorderSizePixel=0
    tr.Parent=b
    addCorner(tr,99)
    local k=Instance.new("Frame")
    k.Size=UDim2.fromOffset(15,15)
    k.BackgroundColor3=C.TEXT
    k.BorderSizePixel=0
    k.Parent=tr
    addCorner(k,99)
    local value=initial==true
    local function render()
        tr.BackgroundColor3=value and C.CYAN or C.PANEL3
        k.Position=value and UDim2.new(1,-17,0,2) or UDim2.fromOffset(2,2)
        l.TextColor3=value and C.TEXT or C.MUTED
    end
    connect(b.Activated,function() value=not value; render(); if callback then callback(value) end end)
    return {Set=function(v) value=v==true; render() end,Get=function() return value end}
end

local function makeSlider(parent,top,labelText,min,max,initial,callback,step)
    step=step or 1
    local holder=Instance.new("Frame")
    holder.BackgroundTransparency=1
    holder.Position=UDim2.fromOffset(12,top)
    holder.Size=UDim2.new(1,-24,0,47)
    holder.Parent=parent
    local l=Instance.new("TextLabel")
    l.BackgroundTransparency=1
    l.Size=UDim2.new(0.7,0,0,17)
    l.Font=FONT
    l.Text=labelText
    l.TextSize=9
    l.TextColor3=C.TEXT
    l.TextXAlignment=Enum.TextXAlignment.Left
    l.Parent=holder
    local vt=Instance.new("TextLabel")
    vt.AnchorPoint=Vector2.new(1,0)
    vt.Position=UDim2.new(1,0,0,0)
    vt.Size=UDim2.fromOffset(70,17)
    vt.BackgroundTransparency=1
    vt.Font=BOLD
    vt.TextSize=8
    vt.TextColor3=C.ACCENT2
    vt.TextXAlignment=Enum.TextXAlignment.Right
    vt.Parent=holder
    local bar=Instance.new("Frame")
    bar.Position=UDim2.fromOffset(0,28)
    bar.Size=UDim2.new(1,0,0,5)
    bar.BackgroundColor3=C.PANEL3
    bar.BorderSizePixel=0
    bar.Parent=holder
    addCorner(bar,99)
    local fill=Instance.new("Frame")
    fill.BackgroundColor3=C.ACCENT
    fill.BorderSizePixel=0
    fill.Parent=bar
    addCorner(fill,99)
    local knob=Instance.new("Frame")
    knob.AnchorPoint=Vector2.new(0.5,0.5)
    knob.Size=UDim2.fromOffset(11,11)
    knob.BackgroundColor3=C.TEXT
    knob.BorderSizePixel=0
    knob.Parent=bar
    addCorner(knob,99)
    local value=math.clamp(initial,min,max)
    local draggingSlider=false
    local function quantize(n)
        local q=math.floor(((n-min)/step)+0.5)*step+min
        return math.clamp(q,min,max)
    end
    local function redraw()
        value=quantize(value)
        local a=(value-min)/math.max(max-min,0.0001)
        fill.Size=UDim2.fromScale(a,1)
        knob.Position=UDim2.fromScale(a,0.5)
        vt.Text=(math.abs(value-math.floor(value))<0.001) and tostring(math.floor(value)) or string.format("%.1f",value)
    end
    local function update(input)
        local left=bar.AbsolutePosition.X
        local width=math.max(bar.AbsoluteSize.X,1)
        local a=math.clamp((input.Position.X-left)/width,0,1)
        value=min+(max-min)*a
        redraw()
        if callback then callback(value) end
    end
    connect(holder.InputBegan,function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then draggingSlider=true; update(input) end end)
    connect(UserInputService.InputChanged,function(input) if draggingSlider and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then update(input) end end)
    connect(UserInputService.InputEnded,function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then draggingSlider=false end end)
    redraw()
    return {Set=function(v) value=v; redraw(); if callback then callback(value) end end}
end

local function makeValue(parent,top,labelText,initialText)
    local row=Instance.new("Frame")
    row.BackgroundTransparency=1
    row.Position=UDim2.fromOffset(12,top)
    row.Size=UDim2.new(1,-24,0,25)
    row.Parent=parent
    local l=Instance.new("TextLabel")
    l.BackgroundTransparency=1
    l.Size=UDim2.new(0.52,0,1,0)
    l.Font=FONT
    l.Text=labelText
    l.TextSize=9
    l.TextColor3=C.MUTED
    l.TextXAlignment=Enum.TextXAlignment.Left
    l.Parent=row
    local r=Instance.new("TextLabel")
    r.BackgroundTransparency=1
    r.AnchorPoint=Vector2.new(1,0)
    r.Position=UDim2.new(1,0,0,0)
    r.Size=UDim2.new(0.48,0,1,0)
    r.Font=BOLD
    r.Text=tostring(initialText)
    r.TextSize=8
    r.TextColor3=C.TEXT
    r.TextXAlignment=Enum.TextXAlignment.Right
    r.TextTruncate=Enum.TextTruncate.AtEnd
    r.Parent=row
    return r
end

local function makeColorPicker(parent,top,title,initial,palette,callback)
    local b=Instance.new("TextButton")
    b.AutoButtonColor=false
    b.Position=UDim2.fromOffset(12,top)
    b.Size=UDim2.new(1,-24,0,29)
    b.BackgroundColor3=C.PANEL3
    b.BorderSizePixel=0
    b.Text=""
    b.Parent=parent
    addCorner(b,8)
    local label=Instance.new("TextLabel")
    label.BackgroundTransparency=1
    label.Position=UDim2.fromOffset(10,0)
    label.Size=UDim2.new(1,-42,1,0)
    label.Font=BOLD
    label.Text=title
    label.TextSize=8
    label.TextColor3=C.TEXT
    label.TextXAlignment=Enum.TextXAlignment.Left
    label.Parent=b
    local dot=Instance.new("Frame")
    dot.AnchorPoint=Vector2.new(1,0.5)
    dot.Position=UDim2.new(1,-8,0.5,0)
    dot.Size=UDim2.fromOffset(12,12)
    dot.BackgroundColor3=initial
    dot.BorderSizePixel=0
    dot.Parent=b
    addCorner(dot,99)
    local current=1
    local best=math.huge
    for i,c in ipairs(palette) do
        local d=(initial.R-c.R)^2+(initial.G-c.G)^2+(initial.B-c.B)^2
        if d<best then best=d; current=i end
    end
    connect(b.Activated,function() current=(current%#palette)+1; dot.BackgroundColor3=palette[current]; if callback then callback(palette[current]) end end)
end

local function FeatureActivated(v)
    notify(v and "Activated Feature!!" or "Disabled Feature!!", "Vexal feature state changed.", 2.2)
end
local function NotSupportedFeature()
    notify("Executor not supported", "This feature could not be loaded in the current client.", 3)
end

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
        canShoot = true,
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
        skeletons = false,
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
        local myChar = Player.Character
        if not myChar then return false end
        local origin = V.getRayOrigin(myChar)
        if not origin then return false end
        local hitPart = target.Character:FindFirstChild("Head")
            or target.Character:FindFirstChild("HumanoidRootPart")
        local tool = V.getGun()
        if not tool or not hitPart then return false end

        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local shootRemote = remotes and remotes:FindFirstChild("ShootGun")
        if not shootRemote or not shootRemote:IsA("RemoteEvent") then return false end

        V.canShoot = false
        local targetPos = hitPart.Position
        local muzzle = tool:FindFirstChild("Muzzle", true)
        local startPos = (muzzle and muzzle:IsA("Attachment")) and muzzle.WorldPosition or origin

        V.bulletRenderer(startPos, targetPos)
        pcall(function()
            shootRemote:FireServer(origin, targetPos, hitPart, targetPos)
        end)

        local sound = tool:FindFirstChild("Fire")
        if sound and sound:IsA("Sound") then
            pcall(function() sound:Play() end)
        end

        task.delay(2.5, function()
            V.canShoot = true
        end)

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
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Player and p.Character then
                local char = p.Character
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local enemy = p.Team ~= Player.Team
                    if enemy then
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
                    else
                        local old = V.originalHitboxes[hrp]
                        if old then
                            hrp.Size = old.Size
                            hrp.CanCollide = old.CanCollide
                            V.originalHitboxes[hrp] = nil
                        end
                        local box = hrp:FindFirstChild("NexusVexalHitbox")
                        if box then box:Destroy() end
                    end
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

    function V.cleanupSkeletons()
        if not V.skeletonFolder then return end
        for _, child in ipairs(V.skeletonFolder:GetChildren()) do
            child:Destroy()
        end
    end

    function V.updateSkeletons()
        if not V.skeletonFolder then return end
        if not V.skeletons then
            V.cleanupSkeletons()
            return
        end

        local bones = {
            {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
            {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
            {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
            {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
            {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
        }

        local alive = {}
        for _, p in ipairs(V.matchEnemies) do
            if V.isCombatEnemy(p) and p.Character then
                local char = p.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and root then
                    alive[p.Name] = true
                    local holder = V.skeletonFolder:FindFirstChild(p.Name)
                    if not holder then
                        holder = Instance.new("Folder")
                        holder.Name = p.Name
                        holder.Parent = V.skeletonFolder
                    end

                    local color = (p.Team == Player.Team) and V.teamColor or V.enemyColor
                    for i, pair in ipairs(bones) do
                        local p1 = char:FindFirstChild(pair[1])
                        local p2 = char:FindFirstChild(pair[2])
                        if p1 and p2 and p1:IsA("BasePart") and p2:IsA("BasePart") then
                            local line = holder:FindFirstChild(tostring(i))
                            if not line then
                                line = Instance.new("LineHandleAdornment")
                                line.Name = tostring(i)
                                line.Thickness = 2
                                line.ZIndex = 10
                                line.AlwaysOnTop = true
                                line.Parent = holder
                            end
                            line.Color3 = color
                            line.Adornee = p1
                            line.CFrame = CFrame.new(Vector3.zero, p1.CFrame:PointToObjectSpace(p2.Position))
                            line.Length = (p1.Position - p2.Position).Magnitude
                        end
                    end
                end
            end
        end

        for _, child in ipairs(V.skeletonFolder:GetChildren()) do
            if not alive[child.Name] then
                child:Destroy()
            end
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
        local knifeRemote = remotes and remotes:FindFirstChild("ThrowHit")
        if not knifeRemote or not knifeRemote:IsA("RemoteEvent") then return end

        for _, target in ipairs(Players:GetPlayers()) do
            if target ~= Player and target.Character then
                local hum = target.Character:FindFirstChild("Humanoid")
                local root = target.Character:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and root then
                    pcall(function()
                        knifeRemote:FireServer(root, root.Position)
                    end)
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

    local mainSection = makeSection(MainPage, 54, 520, "COMBAT FEATURES")
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
    makeSlider(mainSection, 207, "Autoshoot Cooldown", 0, 10, 2, function(v) V.autoShootCooldown = v end, 0.5)
    makeToggle(mainSection, 262, "Auto Throw Knife", false, function(v) V.autoThrow = v end)
    makeSlider(mainSection, 300, "Throw Distance", 25, 1000, 300, function(v) V.throwDistance = v end)
    makeSlider(mainSection, 347, "Throw Cooldown", 0.5, 10, 2, function(v) V.throwCooldown = v end, 0.5)
    makeToggle(mainSection, 402, "Triggerbot", false, function(v) V.triggerbot = v end)
    makeSlider(mainSection, 440, "Triggerbot Cooldown", 0, 3, 1, function(v) V.triggerbotCooldown = v end, 0.1)

    local miscSection = makeSection(MainPage, 590, 300, "MOVEMENT / MISC")
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
    makeSlider(abilityStatus, 122, "Shrouds / Enemy", 1, 10000, 1, function(v) V.shroudRate = math.max(0.1, v) end, 0.1)

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
    makeSlider(abilityValues, 358, "Sprint Time", 0.5, 10, cfgNumber("SprintTime", 3), function(v) setCfg("SprintTime", v) end, 0.5)
    makeSlider(abilityValues, 406, "Sprint Boost", 0, 5, cfgNumber("SprintBoost", 1), function(v) setCfg("SprintBoost", v) end, 0.1)
    makeSlider(abilityValues, 454, "Soul Reap Time", 0.5, 10, cfgNumber("SoulReapTime", 3), function(v) setCfg("SoulReapTime", v) end, 0.5)
    makeSlider(abilityValues, 502, "Soul Reap Speed Boost", 0.1, 10, cfgNumber("SoulReapSpeedBoost", 1), function(v) setCfg("SoulReapSpeedBoost", v) end, 0.1)
    makeSlider(abilityValues, 550, "Propeller Jump Boost", 0.1, 5, cfgNumber("PropellerJumpBoost", 1), function(v) setCfg("PropellerJumpBoost", v) end, 0.1)
    makeSlider(abilityValues, 598, "Shroud Time", 0.5, 10, cfgNumber("ShroudTime", 3), function(v) setCfg("ShroudTime", v) end, 0.5)
    makeSlider(abilityValues, 646, "Shroud Projectile Speed", 2.5, 100, cfgNumber("ShroudProjectileSpeed", 20), function(v) setCfg("ShroudProjectileSpeed", v) end, 2.5)
    makeSlider(abilityValues, 694, "Shroud Projectile Range", 5, 1000, cfgNumber("ShroudProjectileRange", 100), function(v) setCfg("ShroudProjectileRange", v) end, 5)

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

    makeTitle(ESPPage, "ESP", "Charms • skeleton • tracers • hitbox")

    local extraEsp = makeSection(ESPPage, 54, 350, "ESP FEATURES")
    V.charmsFolder = CoreGui:FindFirstChild("NexusCharmsESP") or Instance.new("Folder")
    V.charmsFolder.Name = "NexusCharmsESP"
    V.charmsFolder.Parent = CoreGui
    V.tracerFolder = CoreGui:FindFirstChild("NexusTracers") or Instance.new("Folder")
    V.tracerFolder.Name = "NexusTracers"
    V.tracerFolder.Parent = CoreGui
    V.skeletonFolder = CoreGui:FindFirstChild("NexusSkeletons") or Instance.new("Folder")
    V.skeletonFolder.Name = "NexusSkeletons"
    V.skeletonFolder.Parent = CoreGui
    makeToggle(extraEsp, 30, "ESP Charms", false, function(v) V.charms = v if not v then for _, child in ipairs(V.charmsFolder:GetChildren()) do child:Destroy() end end end)
    makeColorPicker(extraEsp, 214, "Team Color", V.teamColor, {C.GOOD, C.CYAN, C.TEXT, C.WARN, C.VIOLET}, function(c) V.teamColor = c end)
    makeColorPicker(extraEsp, 246, "Enemy Color", V.enemyColor, {C.BAD, C.MAGENTA, C.VIOLET, C.CYAN, C.WARN}, function(c) V.enemyColor = c end)
    makeToggle(extraEsp, 94, "ESP Skeleton", false, function(v) V.skeletons = v if not v then V.cleanupSkeletons() end end)
    makeToggle(extraEsp, 126, "ESP Tracers", false, function(v) V.tracers = v if not v then V.clearTracers() end end)
    makeToggle(extraEsp, 158, "Hitbox Expander", false, function(v) V.hitboxExpander = v if not v then V.cleanupHitboxes() end end)
    makeSlider(extraEsp, 196, "Hitbox Size", 5, 100, 13, function(v) V.hitboxSize = v end)
    makeButton(extraEsp, 278, "CYCLE ESP COLORS", function()
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
            if V.autoShoot and V.match and V.canShoot and tick() - lastAutoShot >= V.autoShootCooldown then
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
            if V.charms then V.updateCharms() else if V.charmsFolder then for _, child in ipairs(V.charmsFolder:GetChildren()) do child:Destroy() end end end
            if V.skeletons then V.updateSkeletons() else V.cleanupSkeletons() end
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

    spawn(function()
        while V.running do
            statusMatch.Text = V.match and "YES" or "NO"
            statusEnemies.Text = tostring(#V.matchEnemies)
            statusCanShoot.Text = V.canShoot and "YES" or "COOLDOWN"
            statusFPS.Text = UserInputService.TouchEnabled and "Mobile" or (UserInputService.KeyboardEnabled and "PC" or "Unknown")
            local network = game:GetService("Stats"):FindFirstChild("Network")
            local server = network and network:FindFirstChild("ServerStatsItem")
            local pingItem = server and server:FindFirstChild("Data Ping")
            statusPing.Text = pingItem and (tostring(math.floor(tonumber(pingItem:GetValue()) or 0)) .. " ms") or "-"
            task.wait(0.25)
        end
    end)

    makeTitle(StatusPage, "STATUS", "Exact Vexal runtime state")
    local statusSection = makeSection(StatusPage, 54, 250, "RUNTIME")
    local statusMatch = makeValue(statusSection, 30, "Match", "NO")
    local statusEnemies = makeValue(statusSection, 55, "Match Enemies", "0")
    local statusCanShoot = makeValue(statusSection, 80, "Gun Ready", "YES")
    local statusFPS = makeValue(statusSection, 105, "Platform", "Detecting...")
    local statusPing = makeValue(statusSection, 130, "Ping", "-")
    local statusName = makeValue(statusSection, 155, "Player", Player.DisplayName)
    local statusPlace = makeValue(statusSection, 180, "Place ID", tostring(game.PlaceId))
    local statusScript = makeValue(statusSection, 205, "Script", "RUNNING")

    -- Cleanup for reruns / character teardown.
    g.NexusVexalCleanup = function()
        V.running = false
        pcall(V.stopManualGunController)
        for _, th in ipairs(V.threads) do pcall(task.cancel, th) end
        for _, conn in ipairs(V.connections) do pcall(function() conn:Disconnect() end) end
        V:clearTracers()
        V:cleanupHitboxes()
        V:cleanupSkeletons()
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
