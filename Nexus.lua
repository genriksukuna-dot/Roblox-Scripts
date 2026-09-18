print("[NEXUS] Booting Launcher...")
pcall(function()
game:GetService("StarterGui"):SetCore("SendNotification", {
Title = "NEXUS HUB",
Text = "Launcher starting...",
Duration = 2
})
end)
if _G.NexusHubMasterCleanup then
pcall(_G.NexusHubMasterCleanup)
end
local Cleanups = {}
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
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")
local GITHUB_SCRIPTS = {
BlockStrike = "https://raw.githubusercontent.com/genriksukuna-dot/Roblox-Scripts/refs/heads/main/Block-Strike.lua",
SniperArena = "https://raw.githubusercontent.com/genriksukuna-dot/Roblox-Scripts/refs/heads/main/Sniper-Arena.lua"
}
local THUMBNAILS = {
BlockStrike = "rbxassetid://92306455384915",
SniperArena = "rbxassetid://124037211421900"
}
local Colors = {
Bg           = Color3.fromRGB(12, 13, 20),
HeaderBg     = Color3.fromRGB(18, 19, 30),
CardBg       = Color3.fromRGB(20, 22, 35),
CardBorder   = Color3.fromRGB(45, 50, 75),
White        = Color3.fromRGB(255, 255, 255),
TextMuted    = Color3.fromRGB(150, 155, 185),
BS_Primary   = Color3.fromRGB(0, 235, 255),
BS_Secondary = Color3.fromRGB(0, 255, 170),
SA_Primary   = Color3.fromRGB(245, 60, 255),
SA_Secondary = Color3.fromRGB(130, 80, 255)
}
local function getSafeGui()
local pgui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 4)
if pgui then return pgui end
if typeof(gethui) == "function" then
local ok, h = pcall(gethui)
if ok and h then return h end
end
return LocalPlayer:FindFirstChild("PlayerGui")
end
local GuiParent = getSafeGui()
if not GuiParent then return end
local function tween(inst, time, props, style, dir)
if not inst then return end
local tw = TweenService:Create(
inst,
TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
props
)
tw:Play()
return tw
end
local function addCorner(parent, radius)
local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(0, radius or 10)
c.Parent = parent
return c
end
local function addStroke(parent, color, thickness)
local s = Instance.new("UIStroke")
s.Color = color or Colors.CardBorder
s.Thickness = thickness or 1.2
s.Parent = parent
return s
end
local function addGradient(parent, c1, c2, rot)
local g = Instance.new("UIGradient")
g.Color = ColorSequence.new({
ColorSequenceKeypoint.new(0, c1),
ColorSequenceKeypoint.new(1, c2)
})
g.Rotation = rot or 0
g.Parent = parent
return g
end
local RootGui = Instance.new("ScreenGui")
RootGui.Name = "Nexus_Tactical_Hub"
RootGui.ResetOnSpawn = false
RootGui.IgnoreGuiInset = true
RootGui.DisplayOrder = 99999
RootGui.Parent = GuiParent
table.insert(Cleanups, RootGui)
local DarkBackdrop = Instance.new("Frame", RootGui)
DarkBackdrop.Size = UDim2.fromScale(1, 1)
DarkBackdrop.BackgroundColor3 = Color3.fromRGB(4, 5, 8)
DarkBackdrop.BackgroundTransparency = 0.4
DarkBackdrop.BorderSizePixel = 0
DarkBackdrop.ZIndex = 1
local vp = Camera and Camera.ViewportSize or Vector2.new(800, 450)
local winW = math.clamp(math.floor(vp.X * 0.88), 470, 580)
local winH = math.clamp(math.floor(vp.Y * 0.84), 280, 325)
local MainPanel = Instance.new("Frame", RootGui)
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
local TopNeon = Instance.new("Frame", MainPanel)
TopNeon.Size = UDim2.new(1, 0, 0, 3)
TopNeon.BorderSizePixel = 0
TopNeon.BackgroundColor3 = Colors.BS_Primary
TopNeon.ZIndex = 10
addGradient(TopNeon, Colors.BS_Primary, Colors.SA_Primary, 0)
-- Mini Toggle Pill (Mobile)
local MiniPill = Instance.new("Frame", RootGui)
MiniPill.Name = "MiniPill"
MiniPill.Size = UDim2.fromOffset(125, 32)
MiniPill.Position = UDim2.new(0.5, -62, 0, 16)
MiniPill.BackgroundColor3 = Colors.HeaderBg
MiniPill.BorderSizePixel = 0
MiniPill.Visible = false
MiniPill.ZIndex = 100
addCorner(MiniPill, 16)
addStroke(MiniPill, Colors.BS_Primary, 1.2)
local PillDot = Instance.new("Frame", MiniPill)
PillDot.Size = UDim2.fromOffset(7, 7)
PillDot.Position = UDim2.fromOffset(10, 12)
PillDot.BackgroundColor3 = Colors.BS_Primary
PillDot.BorderSizePixel = 0
PillDot.ZIndex = 101
addCorner(PillDot, 99)
local PillLabel = Instance.new("TextLabel", MiniPill)
PillLabel.Size = UDim2.new(1, -26, 1, 0)
PillLabel.Position = UDim2.fromOffset(24, 0)
PillLabel.BackgroundTransparency = 1
PillLabel.Font = Enum.Font.GothamBlack
PillLabel.Text = "NEXUS HUB"
PillLabel.TextSize = 9
PillLabel.TextColor3 = Colors.White
PillLabel.TextXAlignment = Enum.TextXAlignment.Left
PillLabel.ZIndex = 101
local PillBtn = Instance.new("TextButton", MiniPill)
PillBtn.Size = UDim2.fromScale(1, 1)
PillBtn.BackgroundTransparency = 1
PillBtn.Text = ""
PillBtn.ZIndex = 105
local function toggleHub(show)
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
PillBtn.Activated:Connect(function() toggleHub(true) end)
-- Header
local Header = Instance.new("Frame", MainPanel)
Header.Size = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3 = Colors.HeaderBg
Header.BorderSizePixel = 0
Header.ZIndex = 10
local LogoBadge = Instance.new("Frame", Header)
LogoBadge.Size = UDim2.fromOffset(28, 28)
LogoBadge.Position = UDim2.fromOffset(12, 8)
LogoBadge.BackgroundColor3 = Colors.CardBg
LogoBadge.BorderSizePixel = 0
LogoBadge.ZIndex = 11
addCorner(LogoBadge, 8)
addGradient(LogoBadge, Colors.BS_Primary, Colors.SA_Primary, 45)
local LogoTxt = Instance.new("TextLabel", LogoBadge)
LogoTxt.Size = UDim2.fromScale(1, 1)
LogoTxt.BackgroundTransparency = 1
LogoTxt.Font = Enum.Font.GothamBlack
LogoTxt.Text = "N"
LogoTxt.TextSize = 13
LogoTxt.TextColor3 = Colors.White
LogoTxt.ZIndex = 12
local HeaderTitle = Instance.new("TextLabel", Header)
HeaderTitle.Size = UDim2.fromOffset(220, 16)
HeaderTitle.Position = UDim2.fromOffset(48, 7)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Font = Enum.Font.GothamBlack
HeaderTitle.Text = "NEXUS TACTICAL HUB"
HeaderTitle.TextSize = 11
HeaderTitle.TextColor3 = Colors.White
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.ZIndex = 11
local HeaderSub = Instance.new("TextLabel", Header)
HeaderSub.Size = UDim2.fromOffset(220, 14)
HeaderSub.Position = UDim2.fromOffset(49, 23)
HeaderSub.BackgroundTransparency = 1
HeaderSub.Font = Enum.Font.GothamBold
HeaderSub.Text = "DIRECT CLOUD INJECTOR"
HeaderSub.TextSize = 7.5
HeaderSub.TextColor3 = Colors.BS_Primary
HeaderSub.TextXAlignment = Enum.TextXAlignment.Left
HeaderSub.ZIndex = 11
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.fromOffset(26, 26)
CloseBtn.Position = UDim2.new(1, -34, 0.5, -13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(28, 30, 46)
CloseBtn.BorderSizePixel = 0
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "X"
CloseBtn.TextSize = 11
CloseBtn.TextColor3 = Colors.TextMuted
CloseBtn.ZIndex = 12
addCorner(CloseBtn, 6)
CloseBtn.Activated:Connect(function() toggleHub(false) end)
-- Cards Area
local CardsHolder = Instance.new("Frame", MainPanel)
CardsHolder.Size = UDim2.new(1, -20, 1, -54)
CardsHolder.Position = UDim2.fromOffset(10, 48)
CardsHolder.BackgroundTransparency = 1
CardsHolder.ZIndex = 5
local CardsLayout = Instance.new("UIListLayout", CardsHolder)
CardsLayout.FillDirection = Enum.FillDirection.Horizontal
CardsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
CardsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
CardsLayout.Padding = UDim.new(0, 12)
local isInjecting = false
local function executeFromGitHub(url, title, accentColor)
if isInjecting then return end
isInjecting = true
PanelBorder.Color = accentColor
pcall(function()
game:GetService("StarterGui"):SetCore("SendNotification", {
Title = title,
Text = "Loading script from GitHub...",
Duration = 3
})
end)
tween(MainPanel, 0.2, {Size = UDim2.fromOffset(winW * 0.9, winH * 0.9), BackgroundTransparency = 0.5})
tween(DarkBackdrop, 0.2, {BackgroundTransparency = 1})
task.delay(0.22, function()
if _G.NexusHubMasterCleanup then
_G.NexusHubMasterCleanup()
end
task.spawn(function()
local success, rawScript = pcall(function()
return game:HttpGet(url)
end)
if success and rawScript then
-- Strip invisible unicode if present
rawScript = rawScript:gsub("\226\128\139", ""):gsub("[\194-\244][\128-\191]*", function(c)
if c == "\226\128\139" then return "" end
return c
end)
local fn, err = loadstring(rawScript)
if fn then
fn()
else
warn("[NEXUS ERROR] " .. tostring(err))
end
else
warn("[NEXUS HTTP ERROR]")
end
end)
end)
end
local function buildCard(cfg)
local cardW = math.floor((winW - 36) / 2)
local cardH = winH - 64
local card = Instance.new("Frame", CardsHolder)
card.Size = UDim2.fromOffset(cardW, cardH)
card.BackgroundColor3 = Colors.CardBg
card.BorderSizePixel = 0
card.ClipsDescendants = true
card.ZIndex = 6
addCorner(card, 12)
addStroke(card, Colors.CardBorder, 1.2)
local Banner = Instance.new("Frame", card)
Banner.Size = UDim2.new(1, 0, 0, math.floor(cardH * 0.48))
Banner.BackgroundColor3 = Color3.fromRGB(12, 13, 20)
Banner.BorderSizePixel = 0
Banner.ClipsDescendants = true
Banner.ZIndex = 7
addCorner(Banner, 12)
local ThumbImg = Instance.new("ImageLabel", Banner)
ThumbImg.Size = UDim2.fromScale(1, 1)
ThumbImg.BackgroundTransparency = 1
ThumbImg.ScaleType = Enum.ScaleType.Crop
ThumbImg.Image = cfg.Image
ThumbImg.ZIndex = 7
local ShadowOverlay = Instance.new("Frame", Banner)
ShadowOverlay.Size = UDim2.fromScale(1, 1)
ShadowOverlay.BackgroundColor3 = Colors.CardBg
ShadowOverlay.BackgroundTransparency = 0.2
ShadowOverlay.BorderSizePixel = 0
ShadowOverlay.ZIndex = 8
addGradient(ShadowOverlay, Color3.fromRGB(0, 0, 0), Colors.CardBg, 90)
local TitleLbl = Instance.new("TextLabel", Banner)
TitleLbl.Size = UDim2.new(1, -16, 0, 18)
TitleLbl.Position = UDim2.new(0, 10, 1, -22)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Font = Enum.Font.GothamBlack
TitleLbl.Text = cfg.Title
TitleLbl.TextSize = 13
TitleLbl.TextColor3 = Colors.White
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex = 10
local Body = Instance.new("Frame", card)
Body.Size = UDim2.new(1, -16, 1, -(Banner.Size.Y.Offset + 10))
Body.Position = UDim2.fromOffset(8, Banner.Size.Y.Offset + 6)
Body.BackgroundTransparency = 1
Body.ZIndex = 8
local DescLbl = Instance.new("TextLabel", Body)
DescLbl.Size = UDim2.new(1, 0, 0, 26)
DescLbl.BackgroundTransparency = 1
DescLbl.Font = Enum.Font.GothamMedium
DescLbl.Text = cfg.Description
DescLbl.TextSize = 8
DescLbl.TextColor3 = Colors.TextMuted
DescLbl.TextWrapped = true
DescLbl.TextXAlignment = Enum.TextXAlignment.Left
DescLbl.ZIndex = 9
local LaunchBtn = Instance.new("TextButton", Body)
LaunchBtn.Size = UDim2.new(1, 0, 0, 32)
LaunchBtn.Position = UDim2.new(0, 0, 1, -34)
LaunchBtn.BackgroundColor3 = cfg.PrimaryColor
LaunchBtn.BorderSizePixel = 0
LaunchBtn.AutoButtonColor = false
LaunchBtn.Text = ""
LaunchBtn.ZIndex = 12
addCorner(LaunchBtn, 7)
addGradient(LaunchBtn, cfg.PrimaryColor, cfg.SecondaryColor, 0)
local LaunchTxt = Instance.new("TextLabel", LaunchBtn)
LaunchTxt.Size = UDim2.fromScale(1, 1)
LaunchTxt.BackgroundTransparency = 1
LaunchTxt.Font = Enum.Font.GothamBlack
LaunchTxt.Text = "RUN " .. cfg.Title
LaunchTxt.TextSize = 9.5
LaunchTxt.TextColor3 = Colors.White
LaunchTxt.ZIndex = 13
LaunchBtn.Activated:Connect(function()
LaunchTxt.Text = "INJECTING..."
executeFromGitHub(cfg.ScriptUrl, cfg.Title, cfg.PrimaryColor)
end)
end
buildCard({
Title = "BLOCK STRIKE",
Image = THUMBNAILS.BlockStrike,
PrimaryColor = Colors.BS_Primary,
SecondaryColor = Colors.BS_Secondary,
Description = "Hitbox Expander, Hitscan Aimbot and Fast Reload.",
ScriptUrl = GITHUB_SCRIPTS.BlockStrike
})
buildCard({
Title = "SNIPER ARENA",
Image = THUMBNAILS.SniperArena,
PrimaryColor = Colors.SA_Primary,
SecondaryColor = Colors.SA_Secondary,
Description = "Smooth Camera Lock, Visual ESP and Config Manager.",
ScriptUrl = GITHUB_SCRIPTS.SniperArena
})
print("[NEXUS HUB] Ready!")
