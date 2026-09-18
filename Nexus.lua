print("[NEXUS] Starting Tactical Hub...")
​pcall(function()
game:GetService("StarterGui"):SetCore("SendNotification", {
Title = "NEXUS HUB",
Text = "Starting launcher...",
Duration = 2
})
end)
​if _G.NexusHubMasterCleanup then
pcall(_G.NexusHubMasterCleanup)
end
​local Cleanups = {}
_G.NexusHubMasterCleanup = function()
for _, item in ipairs(Cleanups) do
pcall(function()
if typeof(item) == "RBXScriptConnection" then
item:Disconnect()
elseif typeof(item) == "Instance" then
item:Destroy()
end
end)
end
table.clear(Cleanups)
end
​local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
​local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")
​local GITHUB_SCRIPTS = {
BlockStrike = "https://raw.githubusercontent.com/genriksukuna-dot/Roblox-Scripts/refs/heads/main/Block-Strike.lua",
SniperArena = "https://raw.githubusercontent.com/genriksukuna-dot/Roblox-Scripts/refs/heads/main/Sniper-Arena.lua"
}
​local RAW_ASSET_IDS = {
BlockStrike = "92306455384915",
SniperArena = "124037211421900"
}
​local Colors = {
Bg           = Color3.fromRGB(12, 13, 20),
HeaderBg     = Color3.fromRGB(18, 19, 30),
CardBg       = Color3.fromRGB(20, 22, 35),
CardBorder   = Color3.fromRGB(45, 50, 75),
White        = Color3.fromRGB(255, 255, 255),
TextMuted    = Color3.fromRGB(150, 155, 185),
GreenOnline  = Color3.fromRGB(50, 245, 140),
GoldBadge    = Color3.fromRGB(255, 200, 60),
BS_Primary   = Color3.fromRGB(0, 235, 255),
BS_Secondary = Color3.fromRGB(0, 255, 170),
SA_Primary   = Color3.fromRGB(245, 60, 255),
SA_Secondary = Color3.fromRGB(130, 80, 255)
}
​local function getSafeGui()
local pgui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 4)
if pgui then return pgui end
if typeof(gethui) == "function" then
local ok, h = pcall(gethui)
if ok and h then return h end
end
return LocalPlayer:FindFirstChild("PlayerGui")
end
​local GuiParent = getSafeGui()
if not GuiParent then return end
​local function tween(inst, time, props, style, dir)
if not inst then return end
local tw = TweenService:Create(
inst,
TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
props
)
tw:Play()
return tw
end
​local function addCorner(parent, radius)
local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, radius or 10)
c.Parent = parent
return c
end
​local function addStroke(parent, color, thickness)
local s = Instance.new("UIStroke")
s.Color = color or Colors.CardBorder
s.Thickness = thickness or 1.2
s.Parent = parent
return s
end
​local function addGradient(parent, c1, c2, rot)
local g = Instance.new("UIGradient")
g.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, c1),
ColorSequenceKeypoint.new(1, c2)
})
g.Rotation = rot or 0
g.Parent = parent
return g
end
​local function applyDecalImage(imageLabel, rawId)
local clean = tostring(rawId):gsub("%D", "")
imageLabel.Image = "rbxthumb://type=Asset&id=" .. clean .. "&w=420&h=420"
task.spawn(function()
pcall(function()
local objs = game:GetObjects("rbxassetid://" .. clean)
if objs and objs[1] and objs[1]:IsA("Decal") then
local tex = objs[1].Texture
if tex and tex ~= "" then
imageLabel.Image = tex
end
objs[1]:Destroy()
end
end)
end)
end
​local RootGui = Instance.new("ScreenGui")
RootGui.Name = "Nexus_Tactical_Hub"
RootGui.ResetOnSpawn = false
RootGui.IgnoreGuiInset = true
RootGui.DisplayOrder = 99999
RootGui.Parent = GuiParent
table.insert(Cleanups, RootGui)
​local DarkBackdrop = Instance.new("Frame", RootGui)
DarkBackdrop.Size = UDim2.fromScale(1, 1)
DarkBackdrop.BackgroundColor3 = Color3.fromRGB(4, 5, 8)
DarkBackdrop.BackgroundTransparency = 0.45
DarkBackdrop.BorderSizePixel = 0
DarkBackdrop.ZIndex = 1
​local vp = Camera and Camera.ViewportSize or Vector2.new(800, 450)
local winW = math.clamp(math.floor(vp.X * 0.90), 500, 610)
local winH = math.clamp(math.floor(vp.Y * 0.90), 330, 385)
​local MainPanel = Instance.new("Frame", RootGui)
MainPanel.Name = "MainPanel"
MainPanel.AnchorPoint = Vector2.new(0.5, 0.5)
MainPanel.Position = UDim2.fromScale(0.5, 0.5)
MainPanel.Size = UDim2.fromOffset(winW, winH)
MainPanel.BackgroundColor3 = Colors.Bg
MainPanel.BorderSizePixel = 0
MainPanel.ClipsDescendants = true
MainPanel.ZIndex = 2
addCorner(MainPanel, 14)
local PanelBorder = addStroke(MainPanel, Colors.CardBorder, 1.4)
​local TopNeon = Instance.new("Frame", MainPanel)
TopNeon.Size = UDim2.new(1, 0, 0, 3)
TopNeon.BorderSizePixel = 0
TopNeon.BackgroundColor3 = Colors.BS_Primary
TopNeon.ZIndex = 10
addGradient(TopNeon, Colors.BS_Primary, Colors.SA_Primary, 0)
​local MiniPill = Instance.new("Frame", RootGui)
MiniPill.Name = "MiniPill"
MiniPill.Size = UDim2.fromOffset(125, 32)
MiniPill.Position = UDim2.new(0.5, -62, 0, 16)
MiniPill.BackgroundColor3 = Colors.HeaderBg
MiniPill.BorderSizePixel = 0
MiniPill.Visible = false
MiniPill.ZIndex = 100
addCorner(MiniPill, 16)
addStroke(MiniPill, Colors.BS_Primary, 1.2)
​local PillDot = Instance.new("Frame", MiniPill)
PillDot.Size = UDim2.fromOffset(7, 7)
PillDot.Position = UDim2.fromOffset(10, 12)
PillDot.BackgroundColor3 = Colors.BS_Primary
PillDot.BorderSizePixel = 0
PillDot.ZIndex = 101
addCorner(PillDot, 99)
​local PillLabel = Instance.new("TextLabel", MiniPill)
PillLabel.Size = UDim2.new(1, -26, 1, 0)
PillLabel.Position = UDim2.fromOffset(24, 0)
PillLabel.BackgroundTransparency = 1
PillLabel.Font = Enum.Font.GothamBlack
PillLabel.Text = "NEXUS HUB"
PillLabel.TextSize = 9
PillLabel.TextColor3 = Colors.White
PillLabel.TextXAlignment = Enum.TextXAlignment.Left
PillLabel.ZIndex = 101
​local PillBtn = Instance.new("TextButton", MiniPill)
PillBtn.Size = UDim2.fromScale(1, 1)
PillBtn.BackgroundTransparency = 1
PillBtn.Text = ""
PillBtn.ZIndex = 105
​local function toggleHub(show)
if show then
MainPanel.Visible = true
DarkBackdrop.Visible = true
MiniPill.Visible = false
MainPanel.Position = UDim2.fromScale(0.5, 0.53)
tween(MainPanel, 0.22, {Position = UDim2.fromScale(0.5, 0.5)}, Enum.EasingStyle.Back)
else
tween(MainPanel, 0.18, {Position = UDim2.fromScale(0.5, 0.54)})
task.delay(0.16, function()
MainPanel.Visible = false
DarkBackdrop.Visible = false
MiniPill.Visible = true
end)
end
end
​PillBtn.Activated:Connect(function() toggleHub(true) end)
​local Header = Instance.new("Frame", MainPanel)
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Colors.HeaderBg
Header.BorderSizePixel = 0
Header.ZIndex = 10
​local LogoBadge = Instance.new("Frame", Header)
LogoBadge.Size = UDim2.fromOffset(26, 26)
LogoBadge.Position = UDim2.fromOffset(12, 8)
LogoBadge.BackgroundColor3 = Colors.CardBg
LogoBadge.BorderSizePixel = 0
LogoBadge.ZIndex = 11
addCorner(LogoBadge, 7)
addGradient(LogoBadge, Colors.BS_Primary, Colors.SA_Primary, 45)
​local LogoTxt = Instance.new("TextLabel", LogoBadge)
LogoTxt.Size = UDim2.fromScale(1, 1)
LogoTxt.BackgroundTransparency = 1
LogoTxt.Font = Enum.Font.GothamBlack
LogoTxt.Text = "N"
LogoTxt.TextSize = 13
LogoTxt.TextColor3 = Colors.White
LogoTxt.ZIndex = 12
​local HeaderTitle = Instance.new("TextLabel", Header)
HeaderTitle.Size = UDim2.fromOffset(220, 15)
HeaderTitle.Position = UDim2.fromOffset(46, 6)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Font = Enum.Font.GothamBlack
HeaderTitle.Text = "NEXUS TACTICAL HUB"
HeaderTitle.TextSize = 11
HeaderTitle.TextColor3 = Colors.White
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.ZIndex = 11
​local HeaderSub = Instance.new("TextLabel", Header)
HeaderSub.Size = UDim2.fromOffset(220, 13)
HeaderSub.Position = UDim2.fromOffset(47, 21)
HeaderSub.BackgroundTransparency = 1
HeaderSub.Font = Enum.Font.GothamBold
HeaderSub.Text = "DIRECT CLOUD INJECTOR"
HeaderSub.TextSize = 7.5
HeaderSub.TextColor3 = Colors.BS_Primary
HeaderSub.TextXAlignment = Enum.TextXAlignment.Left
HeaderSub.ZIndex = 11
​local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.fromOffset(24, 24)
CloseBtn.Position = UDim2.new(1, -32, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(28, 30, 46)
CloseBtn.BorderSizePixel = 0
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextSize = 11
CloseBtn.TextColor3 = Colors.TextMuted
CloseBtn.ZIndex = 12
addCorner(CloseBtn, 6)
​CloseBtn.Activated:Connect(function() toggleHub(false) end)
​local CardsHolder = Instance.new("Frame", MainPanel)
CardsHolder.Size = UDim2.new(1, -20, 1, -114)
CardsHolder.Position = UDim2.fromOffset(10, 46)
CardsHolder.BackgroundTransparency = 1
CardsHolder.ZIndex = 5
​local CardsLayout = Instance.new("UIListLayout", CardsHolder)
CardsLayout.FillDirection = Enum.FillDirection.Horizontal
CardsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
CardsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
CardsLayout.Padding = UDim.new(0, 12)
​local isInjecting = false
local function executeFromGitHub(url, title, accentColor)
if isInjecting then return end
isInjecting = true
​PanelBorder.Color = accentColor
pcall(function()
game:GetService("StarterGui"):SetCore("SendNotification", {
Title = title,
Text = "Downloading script from GitHub...",
Duration = 3
})
end)
​tween(MainPanel, 0.2, {Size = UDim2.fromOffset(winW * 0.9, winH * 0.9), BackgroundTransparency = 0.5})
tween(DarkBackdrop, 0.2, {BackgroundTransparency = 1})
​task.delay(0.22, function()
if _G.NexusHubMasterCleanup then
_G.NexusHubMasterCleanup()
end
​task.spawn(function()
local success, rawScript = pcall(function()
return game:HttpGet(url)
end)
​if success and rawScript then
local fn, err = loadstring(rawScript)
if fn then
fn()
else
warn("[NEXUS ERROR] " .. tostring(err))
end
else
warn("[NEXUS HTTP GET FAILED]")
end
end)
end)
end
​local function buildCard(cfg)
local cardW = math.floor((winW - 36) / 2)
local cardH = winH - 118
​local card = Instance.new("Frame", CardsHolder)
card.Size = UDim2.fromOffset(cardW, cardH)
card.BackgroundColor3 = Colors.CardBg
card.BorderSizePixel = 0
card.ClipsDescendants = true
card.ZIndex = 6
addCorner(card, 10)
addStroke(card, Colors.CardBorder, 1.2)
​local Banner = Instance.new("Frame", card)
Banner.Size = UDim2.new(1, 0, 0, math.floor(cardH * 0.50))
Banner.BackgroundColor3 = Color3.fromRGB(15, 17, 26)
Banner.BorderSizePixel = 0
Banner.ClipsDescendants = true
Banner.ZIndex = 7
addCorner(Banner, 10)
​local ThumbImg = Instance.new("ImageLabel", Banner)
ThumbImg.Size = UDim2.fromScale(1, 1)
ThumbImg.BackgroundTransparency = 1
ThumbImg.ScaleType = Enum.ScaleType.Crop
ThumbImg.ZIndex = 7
applyDecalImage(ThumbImg, cfg.RawAssetId)
​local BottomShadow = Instance.new("Frame", Banner)
BottomShadow.Size = UDim2.new(1, 0, 0.45, 0)
BottomShadow.Position = UDim2.new(0, 0, 0.55, 0)
BottomShadow.BackgroundColor3 = Color3.fromRGB(8, 9, 14)
BottomShadow.BorderSizePixel = 0
BottomShadow.ZIndex = 8
​local shadowGrad = Instance.new("UIGradient", BottomShadow)
shadowGrad.Rotation = 90
shadowGrad.Transparency = NumberSequence.new({
NumberSequenceKeypoint.new(0, 1),
NumberSequenceKeypoint.new(0.5, 0.4),
NumberSequenceKeypoint.new(1, 0)
})
​local TitleLbl = Instance.new("TextLabel", Banner)
TitleLbl.Size = UDim2.new(1, -16, 0, 16)
TitleLbl.Position = UDim2.new(0, 8, 1, -20)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Font = Enum.Font.GothamBlack
TitleLbl.Text = cfg.Title
TitleLbl.TextSize = 12
TitleLbl.TextColor3 = Colors.White
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex = 10
​local Body = Instance.new("Frame", card)
Body.Size = UDim2.new(1, -14, 1, -(Banner.Size.Y.Offset + 8))
Body.Position = UDim2.fromOffset(7, Banner.Size.Y.Offset + 4)
Body.BackgroundTransparency = 1
Body.ZIndex = 8
​local DescLbl = Instance.new("TextLabel", Body)
DescLbl.Size = UDim2.new(1, 0, 0, 22)
DescLbl.BackgroundTransparency = 1
DescLbl.Font = Enum.Font.GothamMedium
DescLbl.Text = cfg.Description
DescLbl.TextSize = 7.5
DescLbl.TextColor3 = Colors.TextMuted
DescLbl.TextWrapped = true
DescLbl.TextXAlignment = Enum.TextXAlignment.Left
DescLbl.ZIndex = 9
​local LaunchBtn = Instance.new("TextButton", Body)
LaunchBtn.Size = UDim2.new(1, 0, 0, 28)
LaunchBtn.Position = UDim2.new(0, 0, 1, -30)
LaunchBtn.BackgroundColor3 = cfg.PrimaryColor
LaunchBtn.BorderSizePixel = 0
LaunchBtn.AutoButtonColor = false
LaunchBtn.Text = ""
LaunchBtn.ZIndex = 12
addCorner(LaunchBtn, 7)
addGradient(LaunchBtn, cfg.PrimaryColor, cfg.SecondaryColor, 0)
​local LaunchTxt = Instance.new("TextLabel", LaunchBtn)
LaunchTxt.Size = UDim2.fromScale(1, 1)
LaunchTxt.BackgroundTransparency = 1
LaunchTxt.Font = Enum.Font.GothamBlack
LaunchTxt.Text = "RUN " .. cfg.Title
LaunchTxt.TextSize = 9
LaunchTxt.TextColor3 = Colors.White
LaunchTxt.ZIndex = 13
​LaunchBtn.Activated:Connect(function()
LaunchTxt.Text = "INJECTING..."
executeFromGitHub(cfg.ScriptUrl, cfg.Title, cfg.PrimaryColor)
end)
​task.spawn(function()
pcall(function()
ContentProvider:PreloadAsync({ThumbImg})
end)
end)
end
​buildCard({
Title = "BLOCK STRIKE",
RawAssetId = RAW_ASSET_IDS.BlockStrike,
PrimaryColor = Colors.BS_Primary,
SecondaryColor = Colors.BS_Secondary,
Description = "Hitbox Expander, Hitscan Aimbot and Fast Reload.",
ScriptUrl = GITHUB_SCRIPTS.BlockStrike
})
​buildCard({
Title = "SNIPER ARENA",
RawAssetId = RAW_ASSET_IDS.SniperArena,
PrimaryColor = Colors.SA_Primary,
SecondaryColor = Colors.SA_Secondary,
Description = "Smooth Camera Lock, Visual ESP and Config Manager.",
ScriptUrl = GITHUB_SCRIPTS.SniperArena
})
​local BottomBar = Instance.new("Frame", MainPanel)
BottomBar.Name = "BottomProfileBar"
BottomBar.Size = UDim2.new(1, -20, 0, 52)
BottomBar.Position = UDim2.new(0, 10, 1, -58)
BottomBar.BackgroundColor3 = Colors.HeaderBg
BottomBar.BorderSizePixel = 0
BottomBar.ZIndex = 10
addCorner(BottomBar, 10)
addStroke(BottomBar, Colors.CardBorder, 1.1)
​local AvatarHolder = Instance.new("Frame", BottomBar)
AvatarHolder.Size = UDim2.fromOffset(38, 38)
AvatarHolder.Position = UDim2.fromOffset(8, 7)
AvatarHolder.BackgroundColor3 = Colors.CardBg
AvatarHolder.BorderSizePixel = 0
AvatarHolder.ZIndex = 11
addCorner(AvatarHolder, 8)
addStroke(AvatarHolder, Colors.BS_Primary, 1.1)
​local AvatarImg = Instance.new("ImageLabel", AvatarHolder)
AvatarImg.Size = UDim2.fromScale(1, 1)
AvatarImg.BackgroundTransparency = 1
AvatarImg.ScaleType = Enum.ScaleType.Fit
AvatarImg.ZIndex = 12
addCorner(AvatarImg, 8)
AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
​local OnlineDot = Instance.new("Frame", AvatarHolder)
OnlineDot.Size = UDim2.fromOffset(8, 8)
OnlineDot.Position = UDim2.new(1, -3, 1, -3)
OnlineDot.AnchorPoint = Vector2.new(0.5, 0.5)
OnlineDot.BackgroundColor3 = Colors.GreenOnline
OnlineDot.BorderSizePixel = 0
OnlineDot.ZIndex = 14
addCorner(OnlineDot, 99)
addStroke(OnlineDot, Colors.HeaderBg, 1.5)
​local StatsHolder = Instance.new("Frame", BottomBar)
StatsHolder.Size = UDim2.new(1, -190, 1, -8)
StatsHolder.Position = UDim2.fromOffset(54, 4)
StatsHolder.BackgroundTransparency = 1
StatsHolder.ZIndex = 11
​local NameRow = Instance.new("Frame", StatsHolder)
NameRow.Size = UDim2.new(1, 0, 0, 16)
NameRow.BackgroundTransparency = 1
NameRow.ZIndex = 12
​local DisplayLbl = Instance.new("TextLabel", NameRow)
DisplayLbl.Size = UDim2.new(0, 130, 1, 0)
DisplayLbl.BackgroundTransparency = 1
DisplayLbl.Font = Enum.Font.GothamBlack
DisplayLbl.Text = LocalPlayer.DisplayName
DisplayLbl.TextSize = 10.5
DisplayLbl.TextColor3 = Colors.White
DisplayLbl.TextXAlignment = Enum.TextXAlignment.Left
DisplayLbl.TextTruncate = Enum.TextTruncate.AtEnd
DisplayLbl.ZIndex = 13
​local isPrem = (LocalPlayer.MembershipType == Enum.MembershipType.Premium)
local PremBadge = Instance.new("TextLabel", NameRow)
PremBadge.Size = UDim2.fromOffset(58, 14)
PremBadge.Position = UDim2.fromOffset(132, 1)
PremBadge.BackgroundColor3 = isPrem and Colors.GoldBadge or Color3.fromRGB(35, 40, 60)
PremBadge.BackgroundTransparency = 0.2
PremBadge.Font = Enum.Font.GothamBold
PremBadge.Text = isPrem and "PREMIUM" or "USER"
PremBadge.TextSize = 7.5
PremBadge.TextColor3 = isPrem and Color3.fromRGB(15, 15, 15) or Colors.White
PremBadge.ZIndex = 13
addCorner(PremBadge, 4)
​local SubInfoLbl = Instance.new("TextLabel", StatsHolder)
SubInfoLbl.Size = UDim2.new(1, 0, 0, 13)
SubInfoLbl.Position = UDim2.fromOffset(0, 16)
SubInfoLbl.BackgroundTransparency = 1
SubInfoLbl.Font = Enum.Font.GothamBold
SubInfoLbl.Text = "@" .. LocalPlayer.Name .. " | ID: " .. tostring(LocalPlayer.UserId)
SubInfoLbl.TextSize = 8
SubInfoLbl.TextColor3 = Colors.TextMuted
SubInfoLbl.TextXAlignment = Enum.TextXAlignment.Left
SubInfoLbl.TextTruncate = Enum.TextTruncate.AtEnd
SubInfoLbl.ZIndex = 12
​local AgeLbl = Instance.new("TextLabel", StatsHolder)
AgeLbl.Size = UDim2.new(1, 0, 0, 12)
AgeLbl.Position = UDim2.fromOffset(0, 29)
AgeLbl.BackgroundTransparency = 1
AgeLbl.Font = Enum.Font.GothamMedium
AgeLbl.Text = "Account Age: " .. tostring(LocalPlayer.AccountAge) .. " days | Status: Active"
AgeLbl.TextSize = 7.5
AgeLbl.TextColor3 = Colors.BS_Primary
AgeLbl.TextXAlignment = Enum.TextXAlignment.Left
AgeLbl.TextTruncate = Enum.TextTruncate.AtEnd
AgeLbl.ZIndex = 12
​local LiveMetrics = Instance.new("Frame", BottomBar)
LiveMetrics.Size = UDim2.fromOffset(125, 40)
LiveMetrics.Position = UDim2.new(1, -132, 0.5, -20)
LiveMetrics.BackgroundTransparency = 1
LiveMetrics.ZIndex = 11
​local LiveLayout = Instance.new("UIListLayout", LiveMetrics)
LiveLayout.FillDirection = Enum.FillDirection.Vertical
LiveLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
LiveLayout.VerticalAlignment = Enum.VerticalAlignment.Center
LiveLayout.Padding = UDim.new(0, 3)
​local FpsBadge = Instance.new("TextLabel", LiveMetrics)
FpsBadge.Size = UDim2.fromOffset(80, 16)
FpsBadge.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
FpsBadge.Font = Enum.Font.GothamBlack
FpsBadge.Text = "FPS: 60"
FpsBadge.TextSize = 8
FpsBadge.TextColor3 = Colors.GreenOnline
FpsBadge.ZIndex = 12
addCorner(FpsBadge, 5)
addStroke(FpsBadge, Color3.fromRGB(40, 50, 70), 1)
​local PingBadge = Instance.new("TextLabel", LiveMetrics)
PingBadge.Size = UDim2.fromOffset(80, 16)
PingBadge.BackgroundColor3 = Color3.fromRGB(24, 28, 42)
PingBadge.Font = Enum.Font.GothamBlack
PingBadge.Text = "PING: 35ms"
PingBadge.TextSize = 8
PingBadge.TextColor3 = Colors.BS_Primary
PingBadge.ZIndex = 12
addCorner(PingBadge, 5)
addStroke(PingBadge, Color3.fromRGB(40, 50, 70), 1)
​local frameCount = 0
local lastSample = os.clock()
​table.insert(Cleanups, RunService.RenderStepped:Connect(function()
frameCount = frameCount + 1
local now = os.clock()
local delta = now - lastSample
if delta >= 0.5 then
local currentFPS = math.floor((frameCount / delta) + 0.5)
FpsBadge.Text = "FPS: " .. tostring(currentFPS)
​local pingVal = 30
pcall(function()
local item = StatsService.Network.ServerStatsItem["Data Ping"]
if item then
pingVal = math.floor(item:GetValue())
end
end)
PingBadge.Text = "PING: " .. tostring(pingVal) .. "ms"
​frameCount = 0
lastSample = now
end
end))
​print("[NEXUS HUB] Ready!")
