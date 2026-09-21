--//======================================================
--// NEXUS TACTICAL HUB - CREDITS + TELEGRAM COPY NOTIFICATION
--//
--// Fixes:
--//  • Load Script button is actually created
--//  • Run + Load Script execute the selected game script
--//  • Close button works reliably (Activated)
--//  • Two green Online dots + Online text, moved left
--//  • User avatar has a gray outline
--//  • Roblox account ID is shown under the username
--//  • FPS / Ping use live client values
--//  • Supplied screenshot/asset IDs are restored
--//  • Search + ALL / SHUTER / OBI filtering retained
--//  • Details page still covers the whole hub
--//  • Tower of Hell card + functionality catalog added
--//======================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local ContentProvider = game:GetService("ContentProvider")

local LocalPlayer = Players.LocalPlayer

--=======================================================
-- CONFIG
--=======================================================

local CONFIG = {
    GuiName = "Nexus_Tactical_Hub",

    Cards = {
        {
            Id = "BlockStrike",
            Title = "BLOCK STRIKE",
            Category = "SHUTER",
            Description = "Combat-focused game profile with configurable visual and gameplay modules.",
            AssetId = "71380059433011",
            ScriptUrl = "https://raw.githubusercontent.com/genriksukuna-dot/Roblox-Scripts/refs/heads/main/Block-Strike.lua",
            Accent = Color3.fromRGB(0, 235, 255),
            Accent2 = Color3.fromRGB(0, 255, 170),
            Features = {
                { Category = "INTERFACE", Items = {
                    "Tactical Engine Interface",
                    "Tabbed Sections",
                    "English / Russian / Spanish UI",
                    "Menu Sounds",
                    "UI Animations",
                } },
                { Category = "VISUAL SETTINGS", Items = {
                    "FOV Ring Display",
                    "Custom Crosshair Display",
                    "Theme Selection",
                    "Menu Style Selection",
                } },
                { Category = "CONFIGURATION", Items = {
                    "Language Selection",
                    "Theme Configuration",
                    "Style Configuration",
                    "Menu Preferences",
                } },
                { Category = "MATCH INFO", Items = {
                    "Match Diagnostics",
                    "Live Statistics",
                    "Server / Session Information",
                } },
                { Category = "GENERAL", Items = {
                    "Nexus Interface",
                    "Quick Launch Panel",
                } },
            },
        },

        {
            Id = "SniperArena",
            Title = "SNIPER ARENA",
            Category = "SHUTER",
            Description = "Precision-oriented profile with camera, visual and configuration modules.",
            AssetId = "79267451018215",
            ScriptUrl = "https://raw.githubusercontent.com/genriksukuna-dot/Roblox-Scripts/refs/heads/main/Sniper-Arena.lua",
            Accent = Color3.fromRGB(245, 60, 255),
            Accent2 = Color3.fromRGB(130, 80, 255),
            Features = {
                { Category = "AIM", Items = {
                    "Aim Assist",
                    "Target Closest",
                    "Team Check",
                    "FOV Radius",
                    "Smoothness",
                    "Max Range",
                } },
                { Category = "VISUAL", Items = {
                    "2D Boxes",
                    "Player Names",
                    "Health Bars",
                    "Distance Tag",
                    "Snaplines",
                    "Visible Only",
                    "Max Distance",
                } },
                { Category = "CONFIG", Items = {
                    "Config Manager",
                } },
            },
        },

        {
            Id = "Rival",
            Title = "RIVAL",
            Category = "SHUTER",
            Description = "Complete Rival profile with AIM, ESP, configuration and theme sections.",
            AssetId = "97029225300638",
            ScriptUrl = "https://raw.githubusercontent.com/genriksukuna-dot/Roblox-Scripts/refs/heads/main/Nexus-Rival.lua",
            Accent = Color3.fromRGB(255, 95, 60),
            Accent2 = Color3.fromRGB(255, 180, 50),
            Features = {
                { Category = "AIMBOT", Items = {
                    "Aimbot",
                    "Hitbox Expander",
                    "FOV",
                    "Visibility Check",
                    "Team Check",
                    "Target Part",
                    "Smoothness",
                    "No Recoil",
                } },
                { Category = "ESP", Items = {
                    "Boxes",
                    "Skeleton",
                    "Snaplines",
                    "Names",
                    "Distance",
                    "Health Bar",
                    "Team Check",
                } },
                { Category = "SETTINGS", Items = {
                    "Watermark",
                    "Rainbow FOV",
                } },
                { Category = "CONFIG", Items = {
                    "Save Config",
                    "Load Config",
                } },
                { Category = "THEMES", Items = {
                    "Cyber Neon",
                    "Crimson Blood",
                    "Purple Void",
                } },
            },
        },


        {
            Id = "MurderDuel",
            Title = "MURDER DUEL",
            Category = "SHUTER",
            Description = "Full Murder Duel profile with combat automation, kill-all tools, ability controls, duel-pad automation, FOV shooting, ESP and movement utilities.",
            AssetId = "138729049229616",
            PlaceId = "138729049229616",
            ScriptUrl = "https://raw.githubusercontent.com/genriksukuna-dot/Roblox-Scripts/refs/heads/main/Nexus-Murder-Duel.lua",
            Accent = Color3.fromRGB(185, 105, 255),
            Accent2 = Color3.fromRGB(83, 231, 255),
            Features = {
                { Category = "COMBAT", Items = {
                    "Auto UnAnchor Character",
                    "Remove Gun Cooldown",
                    "Autoshoot",
                    "Autoshoot Distance",
                    "Autoshoot Cooldown",
                    "Auto Throw Knife",
                    "Throw Distance",
                    "Throw Cooldown",
                    "Triggerbot",
                    "Triggerbot Cooldown",
                } },
                { Category = "KILL ALL", Items = {
                    "Kill All Players Once - Gun",
                    "Auto Kill Players - Gun",
                    "Equip Gun",
                    "Kill All Players Once - Knife",
                    "Auto Kill Players - Knife",
                    "Equip Knife",
                } },
                { Category = "ABILITY", Items = {
                    "Auto Shroud Players",
                    "Low Executor Mode",
                    "Shrouds / Enemy",
                    "Remove Sprint Cooldown",
                    "Remove Dash Cooldown",
                    "Remove Shroud Cooldown",
                    "Remove Soul Reap Combat Delay",
                    "Sprint Cooldown",
                    "Dash Cooldown",
                    "Shroud Cooldown",
                    "Soul Reap Combat Delay",
                    "Sprint Time",
                    "Sprint Boost",
                    "Soul Reap Time",
                    "Soul Reap Speed Boost",
                    "Propeller Jump Boost",
                    "Shroud Time",
                    "Shroud Projectile Speed",
                    "Shroud Projectile Range",
                } },
                { Category = "TELEPORT", Items = {
                    "Auto Walk To Duel Pads",
                    "Prefer Occupied Locations With Free Slot",
                    "Find Occupied + Free Slot",
                    "Find Best Available Pad",
                    "Stop Auto Walk",
                    "Refresh Duel Pad Buttons",
                    "Walk To 1v1 Duel Pad",
                    "Walk To 2v2 Duel Pad",
                    "Walk To 3v3 Duel Pad",
                    "Walk To 4v4 Duel Pad",
                    "Noclip While Auto Walking",
                } },
                { Category = "FOV", Items = {
                    "Enable FOV Circle",
                    "Autoshoot FOV",
                    "FOV Manual Shoot",
                    "FOV Circle Size",
                    "FOV Shoot Cooldown",
                } },
                { Category = "ESP", Items = {
                    "ESP Charms",
                    "ESP Skeleton",
                    "ESP Tracers",
                    "Hitbox Expander",
                    "Hitbox Size",
                    "Team Color",
                    "Enemy Color",
                    "Cycle ESP Colors",
                } },
                { Category = "MOVEMENT / MISC", Items = {
                    "Auto Spin",
                    "Noclip",
                    "Enable Speed Changer",
                    "Walk Speed",
                    "Live Match Status",
                    "Live Enemy Count",
                } },
                { Category = "STATUS", Items = {
                    "Match State",
                    "Match Enemy Count",
                    "Gun Ready State",
                    "Platform Detection",
                    "Ping",
                    "Player Display Name",
                    "Place ID",
                    "Script Runtime State",
                } },
            },
        },
        {
            Id = "Nights99",
            Title = "99 NIGHTS IN THE FOREST",
            Category = "SURVIVAL",
            Description = "Complete 99 Nights in the Forest survival profile with combat, automation, ESP, movement, teleport and utility modules.",
            AssetId = "130857995818038",
            ScriptUrl = "https://raw.githubusercontent.com/genriksukuna-dot/Roblox-Scripts/refs/heads/main/Nexus-99-Night.lua",
            Accent = Color3.fromRGB(92, 205, 112),
            Accent2 = Color3.fromRGB(54, 180, 92),
            Features = {
                { Category = "HOME", Items = {
                    "Refresh ESP",
                    "Bring All Items",
                    "Bring Weapons",
                    "Bring Food",
                    "Bring Scrap",
                    "Bring Gems",
                    "Bring Heals",
                    "Bring Enemy Drops",
                    "Open All Item Chests",
                    "God Mode",
                    "Teleport To Camp",
                } },
                { Category = "COMBAT", Items = {
                    "Combat Engine",
                    "Kill Aura",
                    "Tree Aura",
                    "Freeze Enemies",
                    "Kill All Enemies",
                    "Bring Enemy Drops",
                    "Chop All Trees",
                    "Kill Aura Radius",
                    "Tree Radius",
                } },
                { Category = "AUTOMATION", Items = {
                    "Auto Chop",
                    "Auto Eat",
                    "Auto Heal",
                    "Auto Fuel",
                    "Campfire Zone Feed",
                    "Bring Items",
                    "Bring Trees",
                    "Bring Chopped",
                    "Auto Plant",
                    "Auto Cook",
                    "Bring Food",
                    "Bring Fuel",
                    "Bring Weapons",
                    "Bring Scrap",
                    "Bring Gems",
                    "Bring Heals",
                    "Bring Armor",
                    "Bring Explosives",
                    "Open All Item Chests",
                } },
                { Category = "VISUALS", Items = {
                    "Players ESP",
                    "Enemy ESP",
                    "Item ESP",
                    "Chest ESP",
                    "Child ESP",
                    "Fullbright",
                    "No Fog",
                    "Instant Interact",
                    "Refresh ESP",
                    "Clear ESP",
                } },
                { Category = "MOVEMENT", Items = {
                    "Speed",
                    "Walk Speed",
                    "Fly",
                    "Fly Speed",
                    "No Clip",
                    "Infinite Jump",
                    "Anti AFK",
                } },
                { Category = "TELEPORT", Items = {
                    "Teleport To Camp",
                    "Teleport To Named Location",
                    "Teleport To Player",
                    "Player Name / Display Name Search",
                    "Teleport To Cursor",
                    "Teleport Helpers",
                } },
                { Category = "SETTINGS", Items = {
                    "Rebuild UI",
                    "Restore Lighting",
                    "Restore Movement",
                    "Clear ESP",
                    "Unload Nexus",
                    "Saved Original Movement / Lighting State",
                } },
            },
        },

        {
            Id = "TowerOfHell",
            Title = "TOWER OF HELL",
            Category = "OBI",
            Description = "Tower of Hell profile with movement, jump, teleport, server, configuration and profile modules.",
            AssetId = "127599163236219",
            ScriptUrl = "https://raw.githubusercontent.com/genriksukuna-dot/Roblox-Scripts/refs/heads/main/Nexus-Tower-of-Hell.lua",
            Accent = Color3.fromRGB(255, 43, 139),
            Accent2 = Color3.fromRGB(132, 79, 255),
            Features = {
                { Category = "MOVEMENT", Items = {
                    "FLY",
                    "Fly Speed",
                    "Camera-relative 3D movement",
                } },
                { Category = "JUMP", Items = {
                    "INFINITE JUMP",
                    "BIG JUMP",
                    "Jump Power",
                } },
                { Category = "PLAYER TELEPORT", Items = {
                    "Player List",
                    "Select Player",
                    "Teleport To Selected Player",
                    "Live Player List Refresh",
                } },
                { Category = "SERVER", Items = {
                    "Job ID",
                    "Rejoin Current Server",
                    "Server Link",
                    "Copy Server Link",
                } },
                { Category = "CONFIGURATION", Items = {
                    "Save Configuration",
                    "Load Configuration",
                    "Reset Configuration",
                } },
                { Category = "STATUS", Items = {
                    "Live FPS",
                    "Online / Uptime",
                    "Fly Speed Status",
                    "Server / Session Information",
                } },
                { Category = "PROFILE", Items = {
                    "Username",
                    "Display Name",
                    "User ID",
                    "Account Age",
                    "Membership",
                    "Team",
                    "Character Status",
                } },
            },
        },
    },
}

--=======================================================
-- SAFE GUI PARENT
--=======================================================

local function getSafeGui()
    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        return playerGui
    end

    if typeof(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then
            return hui
        end
    end

    return game:GetService("CoreGui")
end

local GUI_PARENT = getSafeGui()

local oldGui = GUI_PARENT:FindFirstChild(CONFIG.GuiName)
if oldGui then
    oldGui:Destroy()
end

--=======================================================
-- COLORS
--=======================================================

local COLORS = {
    Background = Color3.fromRGB(3, 8, 18),
    Panel = Color3.fromRGB(5, 12, 25),
    Header = Color3.fromRGB(4, 11, 24),
    Card = Color3.fromRGB(7, 17, 34),
    CardHover = Color3.fromRGB(9, 28, 52),
    Border = Color3.fromRGB(0, 112, 205),
    BorderSoft = Color3.fromRGB(16, 54, 92),
    White = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(215, 232, 255),
    Muted = Color3.fromRGB(112, 151, 196),
    DarkText = Color3.fromRGB(57, 91, 130),
    Green = Color3.fromRGB(55, 240, 140),
    Red = Color3.fromRGB(255, 75, 95),
    Sidebar = Color3.fromRGB(3, 10, 21),
}

--=======================================================
-- HELPERS
--=======================================================

local function tween(instance, properties, duration, style, direction)
    return TweenService:Create(instance, TweenInfo.new(
        duration or 0.2,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    ), properties)
end

local function round(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = parent
    return corner
end

local function stroke(parent, color, thickness, transparency)
    local obj = Instance.new("UIStroke")
    obj.Color = color or COLORS.Border
    obj.Thickness = thickness or 1
    obj.Transparency = transparency or 0
    obj.Parent = parent
    return obj
end

local function createText(parent, text, size, color, font, align)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text or ""
    label.TextSize = size or 14
    label.TextColor3 = color or COLORS.White
    label.Font = font or Enum.Font.Gotham
    label.TextXAlignment = align or Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

local function countFeatures(cfg)
    local count = 0
    for _, categoryData in ipairs(cfg.Features) do
        count += #categoryData.Items
    end
    return count
end

local function setImage(imageLabel, assetId)
    if not imageLabel then
        return
    end

    local id = tostring(assetId)

    local uris = {
        "rbxassetid://" .. id,
        "rbxthumb://type=Asset&id=" .. id .. "&w=768&h=432",
        "rbxthumb://type=Asset&id=" .. id .. "&w=420&h=236",
    }

    task.spawn(function()
        for _, uri in ipairs(uris) do
            imageLabel.Image = uri
            imageLabel.ImageTransparency = 0

            local loaded = false
            pcall(function()
                ContentProvider:PreloadAsync({ imageLabel })
                loaded = imageLabel.IsLoaded == true
            end)

            if loaded then
                imageLabel:SetAttribute("NexusImageLoaded", true)
                return
            end

            local deadline = os.clock() + 1.8
            while os.clock() < deadline do
                if imageLabel.IsLoaded then
                    imageLabel:SetAttribute("NexusImageLoaded", true)
                    return
                end
                task.wait(0.05)
            end
        end

        imageLabel:SetAttribute("NexusImageFailed", true)
    end)
end

local function makeImage(parent, assetId, props)
    local holder = Instance.new("Frame")
    holder.BackgroundColor3 = Color3.fromRGB(25, 28, 42)
    holder.BorderSizePixel = 0
    holder.ClipsDescendants = true

    for key, value in pairs(props or {}) do
        holder[key] = value
    end

    holder.Parent = parent
    round(holder, 10)

    local image = Instance.new("ImageLabel")
    image.Size = UDim2.fromScale(1, 1)
    image.BackgroundTransparency = 1
    image.BorderSizePixel = 0
    image.ScaleType = Enum.ScaleType.Crop
    image.ImageTransparency = 0
    image.ZIndex = ((props and props.ZIndex) or 1) + 1
    image.Parent = holder

    setImage(image, assetId)
    return holder, image
end

--=======================================================
-- MAIN GUI
--=======================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = CONFIG.GuiName
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = GUI_PARENT

local Backdrop = Instance.new("Frame")
Backdrop.Size = UDim2.fromScale(1, 1)
Backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
Backdrop.BackgroundTransparency = 0.28
Backdrop.BorderSizePixel = 0
Backdrop.Parent = ScreenGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.Size = UDim2.new(0.92, 0, 0.88, 0)
Main.BackgroundColor3 = COLORS.Panel
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Active = true
Main.Parent = ScreenGui
round(Main, 12)

local MainScale = Instance.new("UIScale")
MainScale.Scale = 1
MainScale.Parent = Main
stroke(Main, COLORS.Border, 1)

local MainGlow = Instance.new("UIStroke")
MainGlow.Color = Color3.fromRGB(0, 128, 255)
MainGlow.Thickness = 2
MainGlow.Transparency = 0.72
MainGlow.Parent = Main

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 15, 31)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(3, 9, 21)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 13, 28)),
})
MainGradient.Rotation = 90
MainGradient.Parent = Main

--=======================================================
-- ELECTRIC BLUE LIGHTNING DECOR
--=======================================================

local function addNeonLightning(parent, xScale, yOffset, size, rotation, zIndex)
    local holder = Instance.new("Frame")
    holder.Name = "NeonLightning"
    holder.AnchorPoint = Vector2.new(0.5, 0)
    holder.Position = UDim2.new(xScale, 0, 0, yOffset)
    holder.Size = UDim2.fromOffset(size, math.floor(size * 1.20))
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.Active = false
    holder.ZIndex = zIndex or 6
    holder.Rotation = rotation or 0
    holder.Parent = parent

    local glow = createText(holder, "ϟ", math.floor(size * 1.05), Color3.fromRGB(0, 105, 255), Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    glow.Size = UDim2.fromScale(1, 1)
    glow.Position = UDim2.fromScale(0, 0)
    glow.TextStrokeColor3 = Color3.fromRGB(0, 60, 255)
    glow.TextStrokeTransparency = 0.45
    glow.TextTransparency = 0.18
    glow.ZIndex = (zIndex or 6)

    local core = createText(holder, "ϟ", math.floor(size * 0.88), Color3.fromRGB(35, 195, 255), Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    core.Size = UDim2.fromScale(1, 1)
    core.Position = UDim2.fromOffset(0, -1)
    core.TextStrokeColor3 = Color3.fromRGB(160, 235, 255)
    core.TextStrokeTransparency = 0.30
    core.ZIndex = (zIndex or 6) + 1

    return holder
end

--=======================================================
-- HEADER
--=======================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 74)
Header.BackgroundColor3 = COLORS.Header
Header.BorderSizePixel = 0
Header.ZIndex = 10
Header.Parent = Main

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(4, 15, 33)),
    ColorSequenceKeypoint.new(0.55, Color3.fromRGB(3, 9, 20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 19, 39)),
})
HeaderGradient.Rotation = 0
HeaderGradient.Parent = Header

local HeaderElectricLine = Instance.new("Frame")
HeaderElectricLine.Position = UDim2.new(0, 22, 1, -2)
HeaderElectricLine.Size = UDim2.new(1, -44, 0, 2)
HeaderElectricLine.BackgroundColor3 = Color3.fromRGB(20, 120, 255)
HeaderElectricLine.BackgroundTransparency = 0.42
HeaderElectricLine.BorderSizePixel = 0
HeaderElectricLine.ZIndex = 11
HeaderElectricLine.Parent = Header

local HeaderElectricGlow = Instance.new("UIGradient")
HeaderElectricGlow.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 70, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(45, 190, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 70, 180)),
})
HeaderElectricGlow.Parent = HeaderElectricLine

local Title = createText(Header, "NEXUS TACTICAL HUB", 23, COLORS.White, Enum.Font.GothamBlack)
Title.Position = UDim2.new(0, 22, 0, 10)
Title.Size = UDim2.new(0, 320, 0, 26)
Title.ZIndex = 11

local Subtitle = createText(Header, "GAME LIBRARY  •  TACTICAL INTERFACE", 10, COLORS.Muted, Enum.Font.GothamBold)
Subtitle.Position = UDim2.new(0, 23, 0, 38)
Subtitle.Size = UDim2.new(0, 360, 0, 18)
Subtitle.ZIndex = 11

local OnlineDot1 = Instance.new("Frame")
OnlineDot1.Size = UDim2.fromOffset(8, 8)
OnlineDot1.Position = UDim2.new(1, -176, 0, 31)
OnlineDot1.BackgroundColor3 = COLORS.Green
OnlineDot1.BorderSizePixel = 0
OnlineDot1.ZIndex = 11
OnlineDot1.Parent = Header
round(OnlineDot1, 8)

local OnlineDot2 = Instance.new("Frame")
OnlineDot2.Size = UDim2.fromOffset(8, 8)
OnlineDot2.Position = UDim2.new(1, -162, 0, 31)
OnlineDot2.BackgroundColor3 = COLORS.Green
OnlineDot2.BorderSizePixel = 0
OnlineDot2.ZIndex = 11
OnlineDot2.Parent = Header
round(OnlineDot2, 8)

local OnlineText = createText(Header, "ONLINE", 11, COLORS.Green, Enum.Font.GothamBold)
OnlineText.Position = UDim2.new(1, -148, 0, 22)
OnlineText.Size = UDim2.new(0, 55, 0, 25)
OnlineText.ZIndex = 11

local ExpandButton = Instance.new("TextButton")
ExpandButton.Size = UDim2.fromOffset(38, 38)
ExpandButton.Position = UDim2.new(1, -95, 0, 17)
ExpandButton.BackgroundColor3 = Color3.fromRGB(27, 29, 40)
ExpandButton.Text = "⛶"
ExpandButton.TextColor3 = COLORS.White
ExpandButton.TextSize = 20
ExpandButton.Font = Enum.Font.GothamBold
ExpandButton.AutoButtonColor = false
ExpandButton.ZIndex = 12
ExpandButton.Parent = Header
round(ExpandButton, 10)

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(38, 38)
CloseButton.Position = UDim2.new(1, -50, 0, 17)
CloseButton.BackgroundColor3 = Color3.fromRGB(27, 29, 40)
CloseButton.Text = "×"
CloseButton.TextColor3 = COLORS.White
CloseButton.TextSize = 25
CloseButton.Font = Enum.Font.Gotham
CloseButton.AutoButtonColor = false
CloseButton.ZIndex = 12
CloseButton.Parent = Header
round(CloseButton, 10)

--=======================================================
-- BODY / SIDEBAR
--=======================================================

local Body = Instance.new("Frame")
Body.Position = UDim2.new(0, 0, 0, 74)
Body.Size = UDim2.new(1, 0, 1, -134)
Body.BackgroundTransparency = 1
Body.ZIndex = 2
Body.Parent = Main

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 210, 1, 0)
Sidebar.BackgroundColor3 = COLORS.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 3
Sidebar.Parent = Body

local SidebarGradient = Instance.new("UIGradient")
SidebarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(3, 13, 27)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(2, 7, 16)),
})
SidebarGradient.Rotation = 90
SidebarGradient.Parent = Sidebar

local SideTitle = createText(Sidebar, "LIBRARY", 11, COLORS.Muted, Enum.Font.GothamBold)
SideTitle.Position = UDim2.new(0, 18, 0, 18)
SideTitle.Size = UDim2.new(1, -36, 0, 20)

local SideLine = Instance.new("Frame")
SideLine.Position = UDim2.new(0, 18, 0, 43)
SideLine.Size = UDim2.new(1, -36, 0, 1)
SideLine.BackgroundColor3 = COLORS.BorderSoft
SideLine.BorderSizePixel = 0
SideLine.Parent = Sidebar

local categoryState = "ALL"
local SidebarButtons = {}

--=======================================================
-- SIDEBAR CATEGORY SCROLL / SLIDER
--=======================================================
-- Keeps the existing category buttons exactly the same visually,
-- while adding a dedicated vertical scroll area in the library section.
local SidebarCategoryScroll = Instance.new("ScrollingFrame")
SidebarCategoryScroll.Name = "SidebarCategoryScroll"
SidebarCategoryScroll.Position = UDim2.new(0, 12, 0, 52)
SidebarCategoryScroll.Size = UDim2.new(1, -24, 1, -126)
SidebarCategoryScroll.BackgroundTransparency = 1
SidebarCategoryScroll.BorderSizePixel = 0
SidebarCategoryScroll.ScrollBarThickness = 0
SidebarCategoryScroll.ScrollingDirection = Enum.ScrollingDirection.Y
SidebarCategoryScroll.CanvasSize = UDim2.fromOffset(0, 0)
SidebarCategoryScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
SidebarCategoryScroll.Active = true
SidebarCategoryScroll.ZIndex = 4
SidebarCategoryScroll.Parent = Sidebar

local SidebarScrollTrack = Instance.new("Frame")
SidebarScrollTrack.Name = "SidebarScrollTrack"
SidebarScrollTrack.Position = UDim2.new(1, -7, 0, 55)
SidebarScrollTrack.Size = UDim2.new(0, 4, 1, -132)
SidebarScrollTrack.BackgroundColor3 = Color3.fromRGB(10, 25, 43)
SidebarScrollTrack.BackgroundTransparency = 0.2
SidebarScrollTrack.BorderSizePixel = 0
SidebarScrollTrack.ZIndex = 7
SidebarScrollTrack.Parent = Sidebar
round(SidebarScrollTrack, 4)

local SidebarScrollThumb = Instance.new("TextButton")
SidebarScrollThumb.Name = "SidebarScrollThumb"
SidebarScrollThumb.Position = UDim2.new(0, 0, 0, 0)
SidebarScrollThumb.Size = UDim2.new(1, 0, 0, 72)
SidebarScrollThumb.BackgroundColor3 = Color3.fromRGB(25, 170, 255)
SidebarScrollThumb.BackgroundTransparency = 0.12
SidebarScrollThumb.BorderSizePixel = 0
SidebarScrollThumb.Text = ""
SidebarScrollThumb.AutoButtonColor = false
SidebarScrollThumb.Active = true
SidebarScrollThumb.ZIndex = 8
SidebarScrollThumb.Parent = SidebarScrollTrack
round(SidebarScrollThumb, 4)

local function updateSidebarSlider()
    local windowHeight = math.max(SidebarCategoryScroll.AbsoluteWindowSize.Y, 1)
    local canvasHeight = math.max(SidebarCategoryScroll.AbsoluteCanvasSize.Y, windowHeight)

    local trackHeight = math.max(SidebarScrollTrack.AbsoluteSize.Y, 1)
    local maxScroll = math.max(canvasHeight - windowHeight, 0)

    local thumbHeight
    if maxScroll <= 0 then
        thumbHeight = trackHeight
    else
        thumbHeight = math.clamp(
            math.floor(trackHeight * (windowHeight / canvasHeight)),
            42,
            trackHeight
        )
    end

    SidebarScrollThumb.Size = UDim2.new(1, 0, 0, thumbHeight)

    local travel = math.max(trackHeight - thumbHeight, 0)
    local alpha = maxScroll > 0
        and math.clamp(SidebarCategoryScroll.CanvasPosition.Y / maxScroll, 0, 1)
        or 0

    SidebarScrollThumb.Position = UDim2.new(0, 0, 0, math.floor(travel * alpha + 0.5))
end

local sidebarSliderDragging = false
local sidebarSliderDragStartY = 0
local sidebarSliderStartY = 0

SidebarScrollThumb.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        sidebarSliderDragging = true
        sidebarSliderDragStartY = input.Position.Y
        sidebarSliderStartY = SidebarScrollThumb.Position.Y.Offset

        tween(SidebarScrollThumb, {
            BackgroundColor3 = Color3.fromRGB(55, 195, 255)
        }, 0.1):Play()
    end
end)

SidebarScrollThumb.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        sidebarSliderDragging = false

        tween(SidebarScrollThumb, {
            BackgroundColor3 = Color3.fromRGB(25, 170, 255)
        }, 0.1):Play()
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not sidebarSliderDragging then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local trackHeight = math.max(SidebarScrollTrack.AbsoluteSize.Y, 1)
    local thumbHeight = SidebarScrollThumb.AbsoluteSize.Y
    local travel = math.max(trackHeight - thumbHeight, 0)

    local canvasHeight = math.max(SidebarCategoryScroll.AbsoluteCanvasSize.Y, SidebarCategoryScroll.AbsoluteWindowSize.Y)
    local windowHeight = math.max(SidebarCategoryScroll.AbsoluteWindowSize.Y, 1)
    local maxScroll = math.max(canvasHeight - windowHeight, 0)

    if maxScroll <= 0 or travel <= 0 then
        return
    end

    local deltaY = input.Position.Y - sidebarSliderDragStartY
    local newThumbY = math.clamp(sidebarSliderStartY + deltaY, 0, travel)
    local alpha = newThumbY / travel

    SidebarCategoryScroll.CanvasPosition = Vector2.new(
        0,
        alpha * maxScroll
    )

    updateSidebarSlider()
end)

SidebarCategoryScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(updateSidebarSlider)
SidebarCategoryScroll:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateSidebarSlider)
SidebarCategoryScroll:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updateSidebarSlider)
SidebarScrollTrack:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSidebarSlider)

local function createSidebarButton(name, text, y)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Position = UDim2.new(0, 0, 0, y)
    Button.Size = UDim2.new(1, 0, 0, 42)
    Button.BackgroundColor3 = Color3.fromRGB(5, 18, 35)
    Button.Text = ""
    Button.AutoButtonColor = false
    Button.ZIndex = 4
    Button.Parent = SidebarCategoryScroll
    round(Button, 10)

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.fromOffset(3, 18)
    indicator.Position = UDim2.new(0, 0, 0.5, -9)
    indicator.BackgroundColor3 = Color3.fromRGB(25, 170, 255)
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.ZIndex = 5
    indicator.Parent = Button
    round(indicator, 3)

    local label = createText(Button, text, 13, COLORS.Muted, Enum.Font.GothamBold)
    label.Position = UDim2.new(0, 17, 0, 0)
    label.Size = UDim2.new(1, -25, 1, 0)
    label.ZIndex = 5

    SidebarButtons[name] = { Button = Button, Indicator = indicator, Label = label }
    return Button
end

local AllButton = createSidebarButton("All", "ALL", 8)
local ShuterButton = createSidebarButton("Shuter", "SHUTER", 56)
local ObiButton = createSidebarButton("Obi", "OBI", 104)
local SurvivalButton = createSidebarButton("Survival", "SURVIVAL", 152)

task.defer(function()
    task.wait()
    updateSidebarSlider()
end)

local SidebarScrollPadding = Instance.new("UIPadding")
SidebarScrollPadding.PaddingBottom = UDim.new(0, 12)
SidebarScrollPadding.Parent = SidebarCategoryScroll

local SearchBox = Instance.new("Frame")
SearchBox.Position = UDim2.new(0, 12, 1, -62)
SearchBox.Size = UDim2.new(1, -24, 0, 44)
SearchBox.BackgroundColor3 = Color3.fromRGB(4, 16, 31)
SearchBox.BorderSizePixel = 0
SearchBox.ZIndex = 4
SearchBox.Parent = Sidebar
round(SearchBox, 10)
stroke(SearchBox, COLORS.BorderSoft, 1)

local SearchIcon = createText(SearchBox, "⌕", 21, COLORS.Muted, Enum.Font.Gotham, Enum.TextXAlignment.Center)
SearchIcon.Size = UDim2.fromOffset(34, 44)
SearchIcon.Position = UDim2.fromOffset(3, 0)

local Search = Instance.new("TextBox")
Search.Position = UDim2.new(0, 35, 0, 0)
Search.Size = UDim2.new(1, -43, 1, 0)
Search.BackgroundTransparency = 1
Search.Text = ""
Search.PlaceholderText = "Search..."
Search.PlaceholderColor3 = COLORS.DarkText
Search.TextColor3 = COLORS.White
Search.TextSize = 13
Search.Font = Enum.Font.Gotham
Search.ClearTextOnFocus = false
Search.ZIndex = 5
Search.Parent = SearchBox

--=======================================================
-- TELEGRAM COPY NOTIFICATION
--=======================================================
local function showTelegramNotice(label)
    local Notice = Instance.new("Frame")
    Notice.Name = "TelegramCopyNotice"
    Notice.AnchorPoint = Vector2.new(1, 0)
    Notice.Position = UDim2.new(1, 340, 0, 18)
    Notice.Size = UDim2.fromOffset(326, 78)
    Notice.BackgroundColor3 = Color3.fromRGB(20, 23, 34)
    Notice.BackgroundTransparency = 1
    Notice.BorderSizePixel = 0
    Notice.ZIndex = 200
    Notice.Parent = Main
    round(Notice, 13)
    local NoticeStroke = stroke(Notice, Color3.fromRGB(180, 90, 255), 1.6, 1)

    local Accent = Instance.new("Frame")
    Accent.Size = UDim2.new(0, 4, 1, 0)
    Accent.BackgroundColor3 = Color3.fromRGB(180, 90, 255)
    Accent.BackgroundTransparency = 1
    Accent.BorderSizePixel = 0
    Accent.ZIndex = 201
    Accent.Parent = Notice
    round(Accent, 13)

    local Title = createText(Notice, "TELEGRAM COPIED ✓", 11, Color3.fromRGB(225, 190, 255), Enum.Font.GothamBold)
    Title.Position = UDim2.new(0, 17, 0, 10)
    Title.Size = UDim2.new(1, -30, 0, 18)
    Title.TextTransparency = 1
    Title.ZIndex = 202

    local BodyText = createText(Notice,
        "Telegram " .. label .. " copied.\nPaste it into your browser to open the profile.",
        10, COLORS.White, Enum.Font.GothamMedium)
    BodyText.Position = UDim2.new(0, 17, 0, 31)
    BodyText.Size = UDim2.new(1, -30, 0, 38)
    BodyText.TextWrapped = true
    BodyText.TextYAlignment = Enum.TextYAlignment.Top
    BodyText.TextTransparency = 1
    BodyText.ZIndex = 202

    tween(Notice, {Position = UDim2.new(1, -18, 0, 18), BackgroundTransparency = 0.04}, 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    tween(NoticeStroke, {Transparency = 0.08}, 0.35):Play()
    tween(Accent, {BackgroundTransparency = 0}, 0.25):Play()
    tween(Title, {TextTransparency = 0}, 0.28):Play()
    tween(BodyText, {TextTransparency = 0}, 0.32):Play()

    task.delay(4.5, function()
        if not Notice or not Notice.Parent then return end
        tween(Notice, {Position = UDim2.new(1, 340, 0, 18), BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In):Play()
        tween(NoticeStroke, {Transparency = 1}, 0.25):Play()
        tween(Accent, {BackgroundTransparency = 1}, 0.2):Play()
        tween(Title, {TextTransparency = 1}, 0.2):Play()
        tween(BodyText, {TextTransparency = 1}, 0.2):Play()
        task.wait(0.35)
        if Notice then Notice:Destroy() end
    end)
end

--=======================================================
-- CREDITS AREA
--=======================================================

local CreditsArea = Instance.new("Frame")
CreditsArea.Position = UDim2.new(0, 210, 0, 0)
CreditsArea.Size = UDim2.new(1, -210, 1, 0)
CreditsArea.BackgroundTransparency = 1
CreditsArea.Visible = false
CreditsArea.ZIndex = 20
CreditsArea.Parent = Body

local CreditsScroll = Instance.new("ScrollingFrame")
CreditsScroll.Position = UDim2.new(0, 17, 0, 17)
CreditsScroll.Size = UDim2.new(1, -34, 1, -34)
CreditsScroll.BackgroundTransparency = 1
CreditsScroll.BorderSizePixel = 0
CreditsScroll.ScrollBarThickness = 4
CreditsScroll.ScrollBarImageColor3 = COLORS.Border
CreditsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
CreditsScroll.ZIndex = 21
CreditsScroll.Parent = CreditsArea

local CreditsPadding = Instance.new("UIPadding")
CreditsPadding.PaddingBottom = UDim.new(0, 16)
CreditsPadding.Parent = CreditsScroll

local CreditsTitle = createText(CreditsScroll, "NEXUS CREDITS", 22, COLORS.White, Enum.Font.GothamBold)
CreditsTitle.Position = UDim2.new(0, 8, 0, 8)
CreditsTitle.Size = UDim2.new(1, -16, 0, 30)
CreditsTitle.ZIndex = 22

local CreditsSubtitle = createText(CreditsScroll, "PROJECT TEAM", 10, COLORS.Muted, Enum.Font.GothamBold)
CreditsSubtitle.Position = UDim2.new(0, 9, 0, 40)
CreditsSubtitle.Size = UDim2.new(1, -18, 0, 18)
CreditsSubtitle.ZIndex = 22

local function showChannelNotice()
    local Notice = Instance.new("Frame")
    Notice.Name = "NexusChannelCopyNotice"
    Notice.AnchorPoint = Vector2.new(1, 0)
    Notice.Position = UDim2.new(1, 340, 0, 18)
    Notice.Size = UDim2.fromOffset(342, 88)
    Notice.BackgroundColor3 = Color3.fromRGB(20, 23, 34)
    Notice.BackgroundTransparency = 1
    Notice.BorderSizePixel = 0
    Notice.ZIndex = 300
    Notice.Parent = Main
    round(Notice, 14)
    local NoticeStroke = stroke(Notice, Color3.fromRGB(35, 160, 255), 1.8, 1)

    local Accent = Instance.new("Frame")
    Accent.Size = UDim2.new(0, 4, 1, 0)
    Accent.BackgroundColor3 = Color3.fromRGB(35, 160, 255)
    Accent.BackgroundTransparency = 1
    Accent.BorderSizePixel = 0
    Accent.ZIndex = 301
    Accent.Parent = Notice
    round(Accent, 14)

    local Title = createText(Notice, "TELEGRAM COPIED ✓", 12, Color3.fromRGB(125, 195, 255), Enum.Font.GothamBold)
    Title.Position = UDim2.new(0, 18, 0, 9)
    Title.Size = UDim2.new(1, -30, 0, 20)
    Title.TextTransparency = 1
    Title.ZIndex = 302

    local BodyText = createText(Notice,
        "Telegram copied.\nPaste it into your browser, then press Search.",
        10, COLORS.White, Enum.Font.GothamMedium)
    BodyText.Position = UDim2.new(0, 18, 0, 33)
    BodyText.Size = UDim2.new(1, -30, 0, 42)
    BodyText.TextWrapped = true
    BodyText.TextYAlignment = Enum.TextYAlignment.Top
    BodyText.TextTransparency = 1
    BodyText.ZIndex = 302

    tween(Notice, {Position = UDim2.new(1, -18, 0, 18), BackgroundTransparency = 0.04}, 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out):Play()
    tween(NoticeStroke, {Transparency = 0.08}, 0.35):Play()
    tween(Accent, {BackgroundTransparency = 0}, 0.25):Play()
    tween(Title, {TextTransparency = 0}, 0.28):Play()
    tween(BodyText, {TextTransparency = 0}, 0.32):Play()

    task.delay(4.5, function()
        if not Notice or not Notice.Parent then return end
        tween(Notice, {Position = UDim2.new(1, 340, 0, 18), BackgroundTransparency = 1}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In):Play()
        tween(NoticeStroke, {Transparency = 1}, 0.25):Play()
        tween(Accent, {BackgroundTransparency = 1}, 0.2):Play()
        tween(Title, {TextTransparency = 1}, 0.2):Play()
        tween(BodyText, {TextTransparency = 1}, 0.2):Play()
        task.wait(0.35)
        if Notice then Notice:Destroy() end
    end)
end

local CreditsList = Instance.new("Frame")
CreditsList.Position = UDim2.new(0, 8, 0, 70)
CreditsList.Size = UDim2.new(1, -16, 0, 0)
CreditsList.AutomaticSize = Enum.AutomaticSize.Y
CreditsList.BackgroundTransparency = 1
CreditsList.ZIndex = 22
CreditsList.Parent = CreditsScroll

local CreditsLayout = Instance.new("UIListLayout")
CreditsLayout.Padding = UDim.new(0, 12)
CreditsLayout.SortOrder = Enum.SortOrder.LayoutOrder
CreditsLayout.Parent = CreditsList

local OWNER_ID = 4364128937
local CODER_ID = 11683846917

local function getRobloxName(userId)
    local ok, name = pcall(function()
        return Players:GetNameFromUserIdAsync(userId)
    end)
    if ok and name then
        return name
    end
    return "Roblox User " .. tostring(userId)
end

local function getRobloxAvatar(userId)
    local ok, image = pcall(function()
        return Players:GetUserThumbnailAsync(
            userId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size180x180
        )
    end)
    if ok then
        return image
    end
    return ""
end

local function createCreditCard(data, order)
    local Card = Instance.new("Frame")
    Card.LayoutOrder = order
    Card.Size = UDim2.new(1, 0, 0, 176)
    Card.BackgroundColor3 = COLORS.Card
    Card.BorderSizePixel = 0
    Card.ZIndex = 23
    Card.Parent = CreditsList
    round(Card, 13)
    local CardStroke = stroke(Card, data.Color, 1.5, 0.25)

    local AvatarFrame = Instance.new("Frame")
    AvatarFrame.Position = UDim2.new(0, 14, 0, 14)
    AvatarFrame.Size = UDim2.fromOffset(82, 82)
    AvatarFrame.BackgroundColor3 = Color3.fromRGB(24, 27, 39)
    AvatarFrame.BorderSizePixel = 0
    AvatarFrame.ZIndex = 24
    AvatarFrame.Parent = Card
    round(AvatarFrame, 18)
    stroke(AvatarFrame, data.Color, 2, 0.05)

    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Size = UDim2.fromScale(1, 1)
    AvatarImage.BackgroundTransparency = 1
    AvatarImage.BorderSizePixel = 0
    AvatarImage.ZIndex = 25
    AvatarImage.Parent = AvatarFrame
    round(AvatarImage, 18)
    AvatarImage.Image = getRobloxAvatar(data.UserId)

    local Name = createText(Card, getRobloxName(data.UserId), 15, COLORS.White, Enum.Font.GothamBold)
    Name.Position = UDim2.new(0, 112, 0, 14)
    Name.Size = UDim2.new(1, -130, 0, 22)
    Name.ZIndex = 25

    local Role = createText(Card, data.Role, 10, data.Color, Enum.Font.GothamBold)
    Role.Position = UDim2.new(0, 112, 0, 39)
    Role.Size = UDim2.new(0, 100, 0, 18)
    Role.ZIndex = 25
    Role.TextStrokeColor3 = data.Color
    Role.TextStrokeTransparency = 0.45

    local RoleGlow = Instance.new("UIStroke")
    RoleGlow.Color = data.Color
    RoleGlow.Thickness = 1.5
    RoleGlow.Transparency = 0.45
    RoleGlow.Parent = Role

    local Country = createText(Card, data.Country, 10, COLORS.Muted, Enum.Font.GothamMedium)
    Country.Position = UDim2.new(0, 112, 0, 61)
    Country.Size = UDim2.new(0, 180, 0, 18)
    Country.ZIndex = 25

    local Description = createText(Card, data.Description, 10, COLORS.Muted, Enum.Font.GothamMedium)
    Description.Position = UDim2.new(0, 14, 0, 105)
    Description.Size = UDim2.new(1, -170, 0, 48)
    Description.TextWrapped = true
    Description.TextYAlignment = Enum.TextYAlignment.Top
    Description.ZIndex = 25

    local TgButton = Instance.new("TextButton")
    TgButton.Size = UDim2.fromOffset(132, 34)
    TgButton.Position = UDim2.new(1, -146, 1, -48)
    TgButton.BackgroundColor3 = Color3.fromRGB(25, 29, 42)
    TgButton.BorderSizePixel = 0
    TgButton.Text = "Telegram @" .. tostring(data.Telegram):gsub("https://t%.me/", "")
    TgButton.TextColor3 = COLORS.White
    TgButton.TextSize = 10
    TgButton.Font = Enum.Font.GothamBold
    TgButton.AutoButtonColor = false
    TgButton.ZIndex = 26
    TgButton.Parent = Card
    round(TgButton, 9)
    local TgStroke = stroke(TgButton, data.Color, 1, 0.35)

    TgButton.MouseEnter:Connect(function()
        tween(TgButton, { BackgroundColor3 = data.Color }, 0.12):Play()
        tween(TgStroke, { Transparency = 0.05 }, 0.12):Play()
    end)
    TgButton.MouseLeave:Connect(function()
        tween(TgButton, { BackgroundColor3 = Color3.fromRGB(25, 29, 42) }, 0.12):Play()
        tween(TgStroke, { Transparency = 0.35 }, 0.12):Play()
    end)
    TgButton.Activated:Connect(function()
        local url = tostring(data.Telegram)
        if typeof(setclipboard) == "function" then
            pcall(function()
                setclipboard(url)
            end)
        end
        showTelegramNotice("@" .. tostring(data.Telegram):gsub("https://t%.me/", ""))
    end)
end

createCreditCard({
    UserId = OWNER_ID,
    Role = "OWNER",
    Country = "Country Russia 🇷🇺",
    Description = "Responsible for the project, Nexus interface, updates, and overall hub development.",
    Telegram = "https://t.me/ShutZaika",
    Color = Color3.fromRGB(255, 185, 60),
}, 1)

createCreditCard({
    UserId = CODER_ID,
    Role = "CODER",
    Country = "Country Ukraine 🇺🇦",
    Description = "Develops and maintains Nexus code, fixes bugs, and adds new UI features.",
    Telegram = "https://t.me/SharlotaK",
    Color = Color3.fromRGB(115, 145, 255),
}, 2)

--=======================================================
-- OFFICIAL CHANNEL
--=======================================================
local OfficialChannelLabel = createText(CreditsList, "OFFICIAL CHANNEL", 10, COLORS.Muted, Enum.Font.GothamBold)
OfficialChannelLabel.LayoutOrder = 3
OfficialChannelLabel.Size = UDim2.new(1, 0, 0, 18)
OfficialChannelLabel.ZIndex = 23

local ProjectTelegramCard = Instance.new("Frame")
ProjectTelegramCard.LayoutOrder = 4
ProjectTelegramCard.Size = UDim2.new(1, 0, 0, 142)
ProjectTelegramCard.BackgroundColor3 = COLORS.Card
ProjectTelegramCard.BorderSizePixel = 0
ProjectTelegramCard.ZIndex = 23
ProjectTelegramCard.Parent = CreditsList
round(ProjectTelegramCard, 13)
stroke(ProjectTelegramCard, Color3.fromRGB(45, 145, 255), 1.5, 0.18)

local ProjectAvatarFrame = Instance.new("Frame")
ProjectAvatarFrame.Position = UDim2.new(0, 14, 0, 14)
ProjectAvatarFrame.Size = UDim2.fromOffset(76, 76)
ProjectAvatarFrame.BackgroundColor3 = Color3.fromRGB(24, 27, 39)
ProjectAvatarFrame.BorderSizePixel = 0
ProjectAvatarFrame.ZIndex = 24
ProjectAvatarFrame.Parent = ProjectTelegramCard
round(ProjectAvatarFrame, 38)
stroke(ProjectAvatarFrame, Color3.fromRGB(45, 145, 255), 2, 0.08)

local ProjectAvatar = Instance.new("ImageLabel")
ProjectAvatar.Size = UDim2.fromScale(1, 1)
ProjectAvatar.BackgroundTransparency = 1
ProjectAvatar.BorderSizePixel = 0
ProjectAvatar.ZIndex = 25
ProjectAvatar.Parent = ProjectAvatarFrame
round(ProjectAvatar, 38)
ProjectAvatar.ScaleType = Enum.ScaleType.Crop
ProjectAvatar.Image = "rbxthumb://type=Asset&id=74524314170257&w=180&h=180"

local ProjectTitle = createText(ProjectTelegramCard, "NEXUS INJEKTOR", 15, COLORS.White, Enum.Font.GothamBold)
ProjectTitle.Position = UDim2.new(0, 106, 0, 14)
ProjectTitle.Size = UDim2.new(1, -122, 0, 22)
ProjectTitle.ZIndex = 25

local ProjectSubtitle = createText(ProjectTelegramCard, "Official Telegram of our project", 10, COLORS.Muted, Enum.Font.GothamMedium)
ProjectSubtitle.Position = UDim2.new(0, 106, 0, 39)
ProjectSubtitle.Size = UDim2.new(1, -122, 0, 20)
ProjectSubtitle.ZIndex = 25

local ProjectDescription = createText(ProjectTelegramCard, "News, updates, announcements and official Nexus project information.", 9, COLORS.Muted, Enum.Font.GothamMedium)
ProjectDescription.Position = UDim2.new(0, 14, 0, 96)
ProjectDescription.Size = UDim2.new(1, -174, 0, 30)
ProjectDescription.TextWrapped = true
ProjectDescription.TextYAlignment = Enum.TextYAlignment.Top
ProjectDescription.ZIndex = 25

local ProjectButton = Instance.new("TextButton")
ProjectButton.Size = UDim2.fromOffset(142, 34)
ProjectButton.Position = UDim2.new(1, -156, 1, -48)
ProjectButton.BackgroundColor3 = Color3.fromRGB(30, 105, 190)
ProjectButton.BorderSizePixel = 0
ProjectButton.Text = "Copy Telegram link"
ProjectButton.TextColor3 = COLORS.White
ProjectButton.TextSize = 10
ProjectButton.Font = Enum.Font.GothamBold
ProjectButton.AutoButtonColor = false
ProjectButton.ZIndex = 26
ProjectButton.Parent = ProjectTelegramCard
round(ProjectButton, 9)
local ProjectButtonStroke = stroke(ProjectButton, Color3.fromRGB(75, 165, 255), 1.2, 0.12)

ProjectButton.MouseEnter:Connect(function()
    tween(ProjectButton, {BackgroundColor3 = Color3.fromRGB(45, 135, 225)}, 0.12):Play()
    tween(ProjectButtonStroke, {Transparency = 0}, 0.12):Play()
end)
ProjectButton.MouseLeave:Connect(function()
    tween(ProjectButton, {BackgroundColor3 = Color3.fromRGB(30, 105, 190)}, 0.12):Play()
    tween(ProjectButtonStroke, {Transparency = 0.12}, 0.12):Play()
end)
ProjectButton.Activated:Connect(function()
    local url = "https://t.me/Nexus_injector"
    if typeof(setclipboard) == "function" then
        pcall(function() setclipboard(url) end)
    end
    showChannelNotice()
end)

--=======================================================
-- CARD AREA
--=======================================================

local CardsArea = Instance.new("Frame")
CardsArea.Position = UDim2.new(0, 210, 0, 0)
CardsArea.Size = UDim2.new(1, -210, 1, 0)
CardsArea.BackgroundTransparency = 1
CardsArea.ZIndex = 2
CardsArea.Parent = Body

local CardsScroll = Instance.new("ScrollingFrame")
CardsScroll.Position = UDim2.new(0, 17, 0, 17)
CardsScroll.Size = UDim2.new(1, -34, 1, -34)
CardsScroll.BackgroundTransparency = 1
CardsScroll.BorderSizePixel = 0
CardsScroll.ScrollBarThickness = 4
CardsScroll.ScrollBarImageColor3 = COLORS.Border
CardsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
CardsScroll.ZIndex = 4
CardsScroll.Parent = CardsArea

local CardsPadding = Instance.new("UIPadding")
CardsPadding.PaddingBottom = UDim.new(0, 12)
CardsPadding.Parent = CardsScroll

local Grid = Instance.new("UIGridLayout")
Grid.CellPadding = UDim2.fromOffset(12, 14)
Grid.CellSize = UDim2.new(0.31, 0, 0, 320)
Grid.FillDirection = Enum.FillDirection.Horizontal
Grid.FillDirectionMaxCells = 3
Grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
Grid.SortOrder = Enum.SortOrder.LayoutOrder
Grid.Parent = CardsScroll

--=======================================================
-- FOOTER
--=======================================================

local Footer = Instance.new("Frame")
Footer.Position = UDim2.new(0, 0, 1, -62)
Footer.Size = UDim2.new(1, 0, 0, 62)
Footer.BackgroundColor3 = Color3.fromRGB(3, 9, 19)
Footer.BorderSizePixel = 0
Footer.ZIndex = 7
Footer.Parent = Main

local Avatar = Instance.new("ImageLabel")
Avatar.Position = UDim2.new(0, 16, 0.5, -19)
Avatar.Size = UDim2.fromOffset(38, 38)
Avatar.BackgroundColor3 = Color3.fromRGB(28, 31, 42)
Avatar.BorderSizePixel = 0
Avatar.ZIndex = 8
Avatar.Parent = Footer
round(Avatar, 10)
stroke(Avatar, Color3.fromRGB(120, 125, 145), 1.5, 0)

pcall(function()
    local image = Players:GetUserThumbnailAsync(
        LocalPlayer.UserId,
        Enum.ThumbnailType.HeadShot,
        Enum.ThumbnailSize.Size100x100
    )
    Avatar.Image = image
end)

local UserName = createText(Footer, LocalPlayer.DisplayName or LocalPlayer.Name, 13, COLORS.White, Enum.Font.GothamBold)
UserName.Position = UDim2.new(0, 66, 0, 7)
UserName.Size = UDim2.new(0, 170, 0, 20)
UserName.ZIndex = 8

local OWNER_USER_ID = 4364128937
local CODER_USER_ID = 11683846917
local isNexusOwner = LocalPlayer.UserId == OWNER_USER_ID
local isNexusCoder = LocalPlayer.UserId == CODER_USER_ID
local NexusRole = isNexusOwner and "OWNER" or (isNexusCoder and "CODER" or "NEXUS USER")
local NexusRoleColor = isNexusOwner and Color3.fromRGB(255, 185, 60) or (isNexusCoder and Color3.fromRGB(115, 145, 255) or COLORS.Muted)

local UserTag = createText(
    Footer,
    NexusRole,
    9,
    NexusRoleColor,
    Enum.Font.GothamBold
)
UserTag.Position = UDim2.new(0, 66, 0, 27)
UserTag.Size = UDim2.new(0, 130, 0, 14)
UserTag.ZIndex = 8

if isNexusOwner or isNexusCoder then
    UserTag.TextStrokeColor3 = NexusRoleColor
    UserTag.TextStrokeTransparency = 0.3

    local RoleGlow = Instance.new("UIStroke")
    RoleGlow.Color = NexusRoleColor
    RoleGlow.Thickness = 2
    RoleGlow.Transparency = 0.45
    RoleGlow.Parent = UserTag
end

local UserIdLabel = createText(Footer, "ID: " .. tostring(LocalPlayer.UserId), 8, Color3.fromRGB(110, 114, 135), Enum.Font.GothamMedium)
UserIdLabel.Position = UDim2.new(0, 66, 0, 42)
UserIdLabel.Size = UDim2.new(0, 170, 0, 12)
UserIdLabel.ZIndex = 8

local FPSLabel = createText(Footer, "FPS: --", 11, COLORS.Muted, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
FPSLabel.AnchorPoint = Vector2.new(1, 0)
FPSLabel.Position = UDim2.new(1, -116, 0, 12)
FPSLabel.Size = UDim2.new(0, 80, 0, 18)
FPSLabel.ZIndex = 8

local PingLabel = createText(Footer, "PING: --", 11, COLORS.Muted, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
PingLabel.AnchorPoint = Vector2.new(1, 0)
PingLabel.Position = UDim2.new(1, -24, 0, 12)
PingLabel.Size = UDim2.new(0, 80, 0, 18)
PingLabel.ZIndex = 8

local FooterVersion = createText(Footer, "NEXUS // UI", 9, COLORS.DarkText, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
FooterVersion.AnchorPoint = Vector2.new(1, 0)
FooterVersion.Position = UDim2.new(1, -24, 0, 34)
FooterVersion.Size = UDim2.new(0, 120, 0, 15)
FooterVersion.ZIndex = 8

local FooterCredits = Instance.new("TextButton")
FooterCredits.Name = "FooterCredits"
FooterCredits.AnchorPoint = Vector2.new(0.5, 0.5)
FooterCredits.Position = UDim2.new(0.55, 0, 0.5, 0)
FooterCredits.Size = UDim2.fromOffset(126, 34)
FooterCredits.BackgroundColor3 = Color3.fromRGB(34, 30, 94)
FooterCredits.BorderSizePixel = 0
FooterCredits.Text = "CREDITS"
FooterCredits.TextColor3 = Color3.fromRGB(190, 205, 255)
FooterCredits.TextSize = 11
FooterCredits.Font = Enum.Font.GothamBold
FooterCredits.AutoButtonColor = false
FooterCredits.ZIndex = 9
FooterCredits.Parent = Footer
round(FooterCredits, 9)
local FooterCreditsStroke = stroke(FooterCredits, Color3.fromRGB(70, 105, 255), 1.4, 0.08)

--=======================================================
-- BLUE NEON LIGHTNING DECOR
--=======================================================
addNeonLightning(Header, 0.42, 10, 38, -12, 8)
addNeonLightning(Header, 0.60, 7, 34, 8, 8)
addNeonLightning(Header, 0.74, 11, 36, -10, 8)

addNeonLightning(Footer, 0.25, 7, 31, -12, 7)
addNeonLightning(Footer, 0.40, 8, 28, 10, 7)
addNeonLightning(Footer, 0.76, 8, 30, -12, 7)

FooterCredits.MouseEnter:Connect(function()
    tween(FooterCredits, { BackgroundColor3 = Color3.fromRGB(48, 52, 145) }, 0.12):Play()
    tween(FooterCreditsStroke, { Transparency = 0 }, 0.12):Play()
    tween(FooterCredits, { TextColor3 = COLORS.White }, 0.12):Play()
end)

FooterCredits.MouseLeave:Connect(function()
    tween(FooterCredits, { BackgroundColor3 = Color3.fromRGB(67, 31, 95) }, 0.12):Play()
    tween(FooterCreditsStroke, { Transparency = 0.08 }, 0.12):Play()
    tween(FooterCredits, { TextColor3 = Color3.fromRGB(225, 190, 255) }, 0.12):Play()
end)

--=======================================================
-- DETAILS PAGE
--=======================================================

local DetailsPage = Instance.new("Frame")
DetailsPage.Size = UDim2.fromScale(1, 1)
DetailsPage.BackgroundColor3 = COLORS.Panel
DetailsPage.BorderSizePixel = 0
DetailsPage.Visible = false
DetailsPage.ZIndex = 100
DetailsPage.Parent = Main

local DetailsHeader = Instance.new("Frame")
DetailsHeader.Size = UDim2.new(1, 0, 0, 68)
DetailsHeader.BackgroundColor3 = COLORS.Header
DetailsHeader.BorderSizePixel = 0
DetailsHeader.ZIndex = 101
DetailsHeader.Parent = DetailsPage

local BackButton = Instance.new("TextButton")
BackButton.Size = UDim2.fromOffset(88, 38)
BackButton.Position = UDim2.new(0, 15, 0, 15)
BackButton.BackgroundColor3 = Color3.fromRGB(25, 28, 39)
BackButton.Text = "←  BACK"
BackButton.TextColor3 = COLORS.White
BackButton.TextSize = 11
BackButton.Font = Enum.Font.GothamBold
BackButton.AutoButtonColor = false
BackButton.ZIndex = 102
BackButton.Parent = DetailsHeader
round(BackButton, 10)

local DetailsTitle = createText(DetailsHeader, "DETAILS", 18, COLORS.White, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
DetailsTitle.AnchorPoint = Vector2.new(0.5, 0)
DetailsTitle.Position = UDim2.new(0.5, 0, 0, 15)
DetailsTitle.Size = UDim2.new(0.45, 0, 0, 26)
DetailsTitle.ZIndex = 102

local DetailsClose = Instance.new("TextButton")
DetailsClose.Size = UDim2.fromOffset(38, 38)
DetailsClose.Position = UDim2.new(1, -53, 0, 15)
DetailsClose.BackgroundColor3 = Color3.fromRGB(27, 29, 40)
DetailsClose.Text = "×"
DetailsClose.TextColor3 = COLORS.White
DetailsClose.TextSize = 24
DetailsClose.Font = Enum.Font.Gotham
DetailsClose.AutoButtonColor = false
DetailsClose.ZIndex = 102
DetailsClose.Parent = DetailsHeader
round(DetailsClose, 10)

local DetailsScroll = Instance.new("ScrollingFrame")
DetailsScroll.Position = UDim2.new(0, 0, 0, 68)
DetailsScroll.Size = UDim2.new(1, 0, 1, -134)
DetailsScroll.BackgroundTransparency = 1
DetailsScroll.BorderSizePixel = 0
DetailsScroll.ScrollBarThickness = 4
DetailsScroll.ScrollBarImageColor3 = COLORS.Border
DetailsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
DetailsScroll.ZIndex = 101
DetailsScroll.Active = true
DetailsScroll.Parent = DetailsPage

local DetailsContainer = Instance.new("Frame")
DetailsContainer.Size = UDim2.new(1, -30, 0, 0)
DetailsContainer.Position = UDim2.new(0, 15, 0, 15)
DetailsContainer.AutomaticSize = Enum.AutomaticSize.Y
DetailsContainer.BackgroundTransparency = 1
DetailsContainer.ZIndex = 101
DetailsContainer.Parent = DetailsScroll

local DetailsList = Instance.new("UIListLayout")
DetailsList.Padding = UDim.new(0, 14)
DetailsList.HorizontalAlignment = Enum.HorizontalAlignment.Center
DetailsList.SortOrder = Enum.SortOrder.LayoutOrder
DetailsList.Parent = DetailsContainer

local DetailsFooter = Instance.new("Frame")
DetailsFooter.Position = UDim2.new(0, 0, 1, -66)
DetailsFooter.Size = UDim2.new(1, 0, 0, 66)
DetailsFooter.BackgroundColor3 = Color3.fromRGB(3, 9, 19)
DetailsFooter.BorderSizePixel = 0
DetailsFooter.ZIndex = 102
DetailsFooter.Parent = DetailsPage

local DetailsCloseBottom = Instance.new("TextButton")
DetailsCloseBottom.Size = UDim2.new(0, 115, 0, 40)
DetailsCloseBottom.Position = UDim2.new(0, 15, 0.5, -20)
DetailsCloseBottom.BackgroundColor3 = Color3.fromRGB(28, 31, 43)
DetailsCloseBottom.Text = "CLOSE"
DetailsCloseBottom.TextColor3 = COLORS.White
DetailsCloseBottom.TextSize = 11
DetailsCloseBottom.Font = Enum.Font.GothamBold
DetailsCloseBottom.AutoButtonColor = false
DetailsCloseBottom.ZIndex = 103
DetailsCloseBottom.Parent = DetailsFooter
round(DetailsCloseBottom, 10)

local RunButton = Instance.new("TextButton")
RunButton.Name = "RunButton"
RunButton.Size = UDim2.new(0, 170, 0, 40)
RunButton.Position = UDim2.new(1, -185, 0.5, -20)
RunButton.BackgroundColor3 = Color3.fromRGB(20, 142, 235)
RunButton.Text = "RUN"
RunButton.TextColor3 = COLORS.White
RunButton.TextSize = 11
RunButton.Font = Enum.Font.GothamBold
RunButton.AutoButtonColor = false
RunButton.ZIndex = 103
RunButton.Parent = DetailsFooter
round(RunButton, 10)

--=======================================================
-- NOTIFICATION
--=======================================================

local Notification = Instance.new("Frame")
Notification.AnchorPoint = Vector2.new(0.5, 1)
Notification.Position = UDim2.new(0.5, 0, 1, 30)
Notification.Size = UDim2.new(0, 340, 0, 58)
Notification.BackgroundColor3 = Color3.fromRGB(20, 23, 34)
Notification.BorderSizePixel = 0
Notification.Visible = false
Notification.ZIndex = 500
Notification.Parent = ScreenGui
round(Notification, 12)
stroke(Notification, COLORS.Border, 1)

local NotificationText = createText(Notification, "", 12, COLORS.White, Enum.Font.GothamMedium, Enum.TextXAlignment.Center)
NotificationText.Size = UDim2.new(1, -20, 1, -10)
NotificationText.Position = UDim2.new(0, 10, 0, 5)
NotificationText.ZIndex = 501

local notificationToken = 0
local function notify(message)
    notificationToken += 1
    local token = notificationToken
    NotificationText.Text = message
    Notification.Visible = true
    Notification.Position = UDim2.new(0.5, 0, 1, 30)

    tween(Notification, {
        Position = UDim2.new(0.5, 0, 1, -18),
    }, 0.22):Play()

    task.delay(2.2, function()
        if token ~= notificationToken then
            return
        end
        local out = tween(Notification, {
            Position = UDim2.new(0.5, 0, 1, 30),
        }, 0.22)
        out:Play()
        out.Completed:Wait()
        if token == notificationToken then
            Notification.Visible = false
        end
    end)
end

--=======================================================
-- LAUNCH / 3D CLOSE ANIMATION
--=======================================================

local launchInProgress = false

local function closeHubForLaunch()
    if launchInProgress or not ScreenGui.Parent then
        return false
    end

    launchInProgress = true

    Main.Active = false
    Body.Active = false
    DetailsPage.Active = false

    local DepthLayer = Instance.new("Frame")
    DepthLayer.Name = "LaunchDepth"
    DepthLayer.Size = UDim2.fromScale(1, 1)
    DepthLayer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    DepthLayer.BackgroundTransparency = 1
    DepthLayer.BorderSizePixel = 0
    DepthLayer.ZIndex = 10000
    DepthLayer.Parent = ScreenGui

    local depthStroke = Instance.new("UIStroke")
    depthStroke.Color = Color3.fromRGB(70, 220, 255)
    depthStroke.Thickness = 2
    depthStroke.Transparency = 0.75
    depthStroke.Parent = DepthLayer

    local pulse = tween(DepthLayer, {
        BackgroundTransparency = 0.72,
    }, 0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    pulse:Play()

    local spin = tween(Main, {
        Rotation = -7,
        Position = UDim2.fromScale(0.5, 0.47),
    }, 0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    spin:Play()
    spin.Completed:Wait()

    local closeTween = tween(Main, {
        Position = UDim2.fromScale(0.5, 0.50),
        Rotation = 9,
    }, 0.18, Enum.EasingStyle.Back, Enum.EasingDirection.In)

    local scaleTween = tween(MainScale, {
        Scale = 0.08,
    }, 0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

    local backdropTween = tween(Backdrop, {
        BackgroundTransparency = 1,
    }, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    closeTween:Play()
    scaleTween:Play()
    backdropTween:Play()

    closeTween.Completed:Wait()
    return true
end

local function destroyHubAfterLaunch()
    pcall(function()
        ScreenGui:Destroy()
    end)
end

--=======================================================
-- SCRIPT EXECUTION
--=======================================================

local CurrentDetails = nil
local scriptBusy = false

local function executeSelected(cfg)
    if not cfg then
        if ScreenGui.Parent then
            notify("SELECT A GAME FIRST")
        end
        return
    end

    if scriptBusy then
        if ScreenGui.Parent then
            notify("WAIT • SCRIPT IS LOADING")
        end
        return
    end

    if type(cfg.ScriptUrl) ~= "string" or cfg.ScriptUrl == "" then
        if ScreenGui.Parent then
            notify(cfg.Title .. " • SCRIPT URL MISSING")
        end
        warn("[Nexus] Missing script URL for " .. tostring(cfg.Id))
        return
    end

    if type(loadstring) ~= "function" then
        if ScreenGui.Parent then
            notify("LOADSTRING IS NOT AVAILABLE")
        end
        warn("[Nexus] loadstring is not available in this environment")
        return
    end

    scriptBusy = true

    if ScreenGui.Parent then
        notify(cfg.Title .. " • LOADING")
    end

    task.spawn(function()
        local okHttp, source = pcall(function()
            return game:HttpGet(cfg.ScriptUrl)
        end)

        if not okHttp or type(source) ~= "string" or source == "" then
            warn("[Nexus] " .. cfg.Id .. " HttpGet error:", source)
            if ScreenGui.Parent then
                notify(cfg.Title .. " • DOWNLOAD ERROR")
            end
            scriptBusy = false
            return
        end

        local okCompile, chunk = pcall(function()
            return loadstring(source)
        end)

        if not okCompile or type(chunk) ~= "function" then
            warn("[Nexus] " .. cfg.Id .. " compile error:", chunk)
            if ScreenGui.Parent then
                notify(cfg.Title .. " • COMPILE ERROR")
            end
            scriptBusy = false
            return
        end

        local okRun, runErr = pcall(chunk)

        if okRun then
            if ScreenGui.Parent then
                notify(cfg.Title .. " • STARTED")
            end
        else
            warn("[Nexus] " .. cfg.Id .. " runtime error:", runErr)
            if ScreenGui.Parent then
                notify(cfg.Title .. " • RUNTIME ERROR")
            end
        end

        scriptBusy = false
    end)
end

local function launchSelected(cfg)
    if not cfg or launchInProgress then
        if not cfg and ScreenGui.Parent then
            notify("SELECT A GAME FIRST")
        end
        return
    end

    local selected = cfg

    task.spawn(function()
        local ok = closeHubForLaunch()
        if not ok then
            return
        end

        task.wait(0.08)
        destroyHubAfterLaunch()
        executeSelected(selected)
    end)
end

--=======================================================
-- DETAILS BUILD
--=======================================================

local function clearDetails()
    for _, child in ipairs(DetailsContainer:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
end

local function createDetailsBanner(cfg)
    local Banner = makeImage(DetailsContainer, cfg.AssetId, {
        Name = "Banner",
        Size = UDim2.new(1, 0, 0, 185),
        LayoutOrder = 1,
        ZIndex = 102,
    })

    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.fromScale(1, 1)
    Overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    Overlay.BackgroundTransparency = 0.38
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 103
    Overlay.Parent = Banner
    round(Overlay, 10)

    local GameTitle = createText(Banner, cfg.Title, 27, COLORS.White, Enum.Font.GothamBlack)
    GameTitle.Position = UDim2.new(0, 20, 1, -58)
    GameTitle.Size = UDim2.new(1, -40, 0, 32)
    GameTitle.ZIndex = 104

    local GameDescription = createText(Banner, cfg.Description, 11, Color3.fromRGB(220, 223, 235), Enum.Font.GothamMedium)
    GameDescription.Position = UDim2.new(0, 20, 1, -28)
    GameDescription.Size = UDim2.new(1, -40, 0, 18)
    GameDescription.ZIndex = 104
end

local function createFeatureCategory(cfg, categoryData, order)
    local Group = Instance.new("Frame")
    Group.Name = "Category_" .. tostring(order)
    Group.Size = UDim2.new(1, 0, 0, 0)
    Group.AutomaticSize = Enum.AutomaticSize.Y
    Group.BackgroundColor3 = COLORS.Card
    Group.BorderSizePixel = 0
    Group.LayoutOrder = order
    Group.ZIndex = 102
    Group.Parent = DetailsContainer
    round(Group, 12)
    stroke(Group, Color3.fromRGB(12, 66, 112), 1)

    local CategoryTitle = createText(Group, string.upper(categoryData.Category), 12, cfg.Accent, Enum.Font.GothamBold)
    CategoryTitle.Position = UDim2.new(0, 15, 0, 12)
    CategoryTitle.Size = UDim2.new(1, -30, 0, 20)
    CategoryTitle.ZIndex = 103

    local Line = Instance.new("Frame")
    Line.Position = UDim2.new(0, 15, 0, 38)
    Line.Size = UDim2.new(1, -30, 0, 1)
    Line.BackgroundColor3 = COLORS.BorderSoft
    Line.BorderSizePixel = 0
    Line.ZIndex = 103
    Line.Parent = Group

    local ItemsHolder = Instance.new("Frame")
    ItemsHolder.Position = UDim2.new(0, 15, 0, 48)
    ItemsHolder.Size = UDim2.new(1, -30, 0, 0)
    ItemsHolder.AutomaticSize = Enum.AutomaticSize.Y
    ItemsHolder.BackgroundTransparency = 1
    ItemsHolder.ZIndex = 103
    ItemsHolder.Parent = Group

    local ItemList = Instance.new("UIListLayout")
    ItemList.Padding = UDim.new(0, 6)
    ItemList.SortOrder = Enum.SortOrder.LayoutOrder
    ItemList.Parent = ItemsHolder

    for i, featureName in ipairs(categoryData.Items) do
        local Item = Instance.new("Frame")
        Item.Size = UDim2.new(1, 0, 0, 31)
        Item.BackgroundColor3 = Color3.fromRGB(23, 25, 37)
        Item.BorderSizePixel = 0
        Item.ZIndex = 104
        Item.LayoutOrder = i
        Item.Parent = ItemsHolder
        round(Item, 8)

        local Check = createText(Item, "›", 17, cfg.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        Check.Position = UDim2.new(0, 8, 0, 0)
        Check.Size = UDim2.fromOffset(20, 31)
        Check.ZIndex = 105

        local Name = createText(Item, featureName, 9, COLORS.Text, Enum.Font.GothamMedium)
        Name.Position = UDim2.new(0, 31, 0, 0)
        Name.Size = UDim2.new(1, -40, 1, 0)
        Name.ZIndex = 105
        Name.TextWrapped = true
        Name.TextYAlignment = Enum.TextYAlignment.Center
        do
            local featureConstraint = Instance.new("UITextSizeConstraint")
            featureConstraint.MinTextSize = 7
            featureConstraint.MaxTextSize = 9
            featureConstraint.Parent = Name
        end
    end

    local bottomPadding = Instance.new("UIPadding")
    bottomPadding.PaddingBottom = UDim.new(0, 13)
    bottomPadding.Parent = ItemsHolder
end

local function showDetails(cfg)
    CurrentDetails = cfg
    clearDetails()
    DetailsScroll.CanvasPosition = Vector2.zero
    DetailsTitle.Text = cfg.Title

    createDetailsBanner(cfg)

    for i, categoryData in ipairs(cfg.Features) do
        createFeatureCategory(cfg, categoryData, i + 1)
    end

    local Info = Instance.new("Frame")
    Info.Size = UDim2.new(1, 0, 0, 58)
    Info.BackgroundColor3 = Color3.fromRGB(17, 19, 29)
    Info.BorderSizePixel = 0
    Info.ZIndex = 102
    Info.LayoutOrder = #cfg.Features + 3
    Info.Parent = DetailsContainer
    round(Info, 12)

    local InfoText = createText(Info, "FEATURE CATALOG", 10, cfg.Accent, Enum.Font.GothamBold)
    InfoText.Position = UDim2.new(0, 15, 0, 8)
    InfoText.Size = UDim2.new(1, -30, 0, 16)
    InfoText.ZIndex = 103

    local CountText = createText(Info, tostring(countFeatures(cfg)) .. " FUNCTIONS AVAILABLE", 11, COLORS.Muted, Enum.Font.GothamMedium)
    CountText.Position = UDim2.new(0, 15, 0, 28)
    CountText.Size = UDim2.new(1, -30, 0, 18)
    CountText.ZIndex = 103

    DetailsPage.Visible = true
    Body.Visible = false
    Footer.Visible = false
    DetailsPage.Position = UDim2.new(0, 24, 0, 0)
    tween(DetailsPage, { Position = UDim2.new(0, 0, 0, 0) }, 0.20, Enum.EasingStyle.Quint):Play()
end

local function hideDetails()
    if not DetailsPage.Visible then
        return
    end

    local tw = tween(DetailsPage, { Position = UDim2.new(0, 24, 0, 0) }, 0.16)
    tw:Play()
    tw.Completed:Wait()

    DetailsPage.Visible = false
    DetailsPage.Position = UDim2.new(0, 0, 0, 0)
    Body.Visible = true
    Footer.Visible = true
    CurrentDetails = nil
end

--=======================================================
-- CARD SYSTEM
--=======================================================

local CardObjects = {}

local function cardMatches(cfg)
    local searchText = string.lower(Search.Text or "")
    local categoryMatch = categoryState == "ALL"
        or string.upper(cfg.Category) == string.upper(categoryState)

    if not categoryMatch then
        return false
    end

    if searchText == "" then
        return true
    end

    if string.find(string.lower(cfg.Title), searchText, 1, true) then
        return true
    end

    if string.find(string.lower(cfg.Description), searchText, 1, true) then
        return true
    end

    for _, categoryData in ipairs(cfg.Features) do
        if string.find(string.lower(categoryData.Category), searchText, 1, true) then
            return true
        end
        for _, item in ipairs(categoryData.Items) do
            if string.find(string.lower(item), searchText, 1, true) then
                return true
            end
        end
    end

    return false
end

local function updateCardVisibility()
    local anyVisible = false
    for _, item in ipairs(CardObjects) do
        local visible = cardMatches(item.Config)
        item.Card.Visible = visible
        anyVisible = anyVisible or visible
    end

    local Empty = CardsScroll:FindFirstChild("EmptyState")
    if Empty then
        Empty.Visible = not anyVisible
    end
end

local function createCard(cfg, order)
    local Card = Instance.new("Frame")
    Card.Name = cfg.Id
    Card.BackgroundColor3 = COLORS.Card
    Card.BorderSizePixel = 0
    Card.LayoutOrder = order
    Card.ZIndex = 5
    Card.Parent = CardsScroll
    round(Card, 13)
    local CardStroke = stroke(Card, COLORS.Border, 1)

    local Banner = makeImage(Card, cfg.AssetId, {
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(1, -16, 0, 145),
        ZIndex = 6,
    })

    local Overlay = Instance.new("Frame")
    Overlay.Size = UDim2.fromScale(1, 1)
    Overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    Overlay.BackgroundTransparency = 0.55
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 7
    Overlay.Parent = Banner
    round(Overlay, 10)

    local AccentLine = Instance.new("Frame")
    AccentLine.Position = UDim2.new(0, 10, 0, 157)
    AccentLine.Size = UDim2.new(0, 36, 0, 3)
    AccentLine.BackgroundColor3 = cfg.Accent
    AccentLine.BorderSizePixel = 0
    AccentLine.ZIndex = 6
    AccentLine.Parent = Card
    round(AccentLine, 2)

    local GameTitle = createText(Card, cfg.Title, 13, COLORS.White, Enum.Font.GothamBold)
    GameTitle.Position = UDim2.new(0, 10, 0, 165)
    GameTitle.Size = UDim2.new(1, -20, 0, 29)
    GameTitle.TextWrapped = true
    GameTitle.TextYAlignment = Enum.TextYAlignment.Top
    GameTitle.ZIndex = 8
    do
        local titleConstraint = Instance.new("UITextSizeConstraint")
        titleConstraint.MinTextSize = 10
        titleConstraint.MaxTextSize = 13
        titleConstraint.Parent = GameTitle
    end

    local Desc = createText(Card, cfg.Description, 8, COLORS.Muted, Enum.Font.GothamMedium)
    Desc.Position = UDim2.new(0, 10, 0, 196)
    Desc.Size = UDim2.new(1, -20, 0, 31)
    Desc.TextWrapped = true
    Desc.TextYAlignment = Enum.TextYAlignment.Top
    Desc.ZIndex = 8
    do
        local descConstraint = Instance.new("UITextSizeConstraint")
        descConstraint.MinTextSize = 7
        descConstraint.MaxTextSize = 9
        descConstraint.Parent = Desc
    end

    local CountText = createText(Card, tostring(countFeatures(cfg)) .. " FUNCTIONS", 8, COLORS.DarkText, Enum.Font.GothamBold)
    CountText.Position = UDim2.new(0, 10, 0, 231)
    CountText.Size = UDim2.new(0.56, -10, 0, 15)
    CountText.ZIndex = 8
    do
        local countConstraint = Instance.new("UITextSizeConstraint")
        countConstraint.MinTextSize = 7
        countConstraint.MaxTextSize = 9
        countConstraint.Parent = CountText
    end

    local AllFunctionality = Instance.new("TextButton")
    AllFunctionality.Size = UDim2.new(1, -20, 0, 30)
    AllFunctionality.Position = UDim2.new(0, 10, 1, -78)
    AllFunctionality.BackgroundColor3 = Color3.fromRGB(26, 29, 42)
    AllFunctionality.Text = "ALL FUNCTIONALITY"
    AllFunctionality.TextColor3 = COLORS.Text
    AllFunctionality.TextSize = 8
    AllFunctionality.Font = Enum.Font.GothamBold
    AllFunctionality.AutoButtonColor = false
    AllFunctionality.ZIndex = 9
    AllFunctionality.Parent = Card
    round(AllFunctionality, 8)

    local AllStroke = stroke(AllFunctionality, cfg.Accent, 1, 0.6)

    local LoadScript = Instance.new("TextButton")
    LoadScript.Name = "LoadScript"
    LoadScript.Size = UDim2.new(1, -20, 0, 30)
    LoadScript.Position = UDim2.new(0, 10, 1, -42)
    LoadScript.BackgroundColor3 = Color3.fromRGB(0, 180, 135)
    LoadScript.Text = "LOAD SCRIPT"
    LoadScript.TextColor3 = COLORS.White
    LoadScript.TextSize = 8
    LoadScript.Font = Enum.Font.GothamBold
    LoadScript.AutoButtonColor = false
    LoadScript.ZIndex = 9
    LoadScript.Parent = Card
    round(LoadScript, 8)

    local LoadStroke = stroke(LoadScript, cfg.Accent2, 1, 0.45)

    Card.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            tween(Card, { BackgroundColor3 = COLORS.CardHover }, 0.15):Play()
            tween(CardStroke, { Color = cfg.Accent, Transparency = 0.35 }, 0.15):Play()
        end
    end)

    Card.MouseLeave:Connect(function()
        tween(Card, { BackgroundColor3 = COLORS.Card }, 0.15):Play()
        tween(CardStroke, { Color = COLORS.Border, Transparency = 0 }, 0.15):Play()
    end)

    AllFunctionality.MouseEnter:Connect(function()
        tween(AllFunctionality, { BackgroundColor3 = Color3.fromRGB(31, 35, 50) }, 0.12):Play()
        tween(AllStroke, { Transparency = 0.1 }, 0.12):Play()
    end)

    AllFunctionality.MouseLeave:Connect(function()
        tween(AllFunctionality, { BackgroundColor3 = Color3.fromRGB(26, 29, 42) }, 0.12):Play()
        tween(AllStroke, { Transparency = 0.6 }, 0.12):Play()
    end)

    AllFunctionality.Activated:Connect(function()
        showDetails(cfg)
    end)

    LoadScript.MouseEnter:Connect(function()
        tween(LoadScript, { BackgroundColor3 = cfg.Accent2 }, 0.12):Play()
        tween(LoadStroke, { Transparency = 0.05 }, 0.12):Play()
    end)

    LoadScript.MouseLeave:Connect(function()
        tween(LoadScript, { BackgroundColor3 = Color3.fromRGB(0, 180, 135) }, 0.12):Play()
        tween(LoadStroke, { Transparency = 0.45 }, 0.12):Play()
    end)

    LoadScript.Activated:Connect(function()
        launchSelected(cfg)
    end)

    table.insert(CardObjects, { Config = cfg, Card = Card })
end

for index, cfg in ipairs(CONFIG.Cards) do
    createCard(cfg, index)
end

local EmptyState = createText(CardsScroll, "NO GAMES FOUND", 14, COLORS.Muted, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
EmptyState.Name = "EmptyState"
EmptyState.Size = UDim2.new(1, -20, 0, 44)
EmptyState.LayoutOrder = 9999
EmptyState.Visible = false
EmptyState.ZIndex = 8

--=======================================================
-- SIDEBAR EVENTS
--=======================================================

local function selectCategory(category)
    categoryState = category

    for name, data in pairs(SidebarButtons) do
        local active = string.upper(name) == string.upper(category)
        data.Indicator.Visible = active
        tween(data.Button, {
            BackgroundColor3 = active and Color3.fromRGB(23, 27, 39) or Color3.fromRGB(17, 19, 28),
        }, 0.15):Play()
        tween(data.Label, {
            TextColor3 = active and COLORS.White or COLORS.Muted,
        }, 0.15):Play()
    end

    local creditsActive = string.upper(category) == "CREDITS"
    CardsArea.Visible = not creditsActive
    CreditsArea.Visible = creditsActive

    if not creditsActive then
        updateCardVisibility()
    end
end

selectCategory("ALL")
AllButton.Activated:Connect(function() selectCategory("ALL") end)
ShuterButton.Activated:Connect(function() selectCategory("SHUTER") end)
ObiButton.Activated:Connect(function() selectCategory("OBI") end)
SurvivalButton.Activated:Connect(function() selectCategory("SURVIVAL") end)
FooterCredits.Activated:Connect(function() selectCategory("CREDITS") end)
Search:GetPropertyChangedSignal("Text"):Connect(updateCardVisibility)

--=======================================================
-- BUTTON EVENTS
--=======================================================

BackButton.Activated:Connect(hideDetails)
DetailsClose.Activated:Connect(hideDetails)
DetailsCloseBottom.Activated:Connect(hideDetails)
RunButton.Activated:Connect(function()
    launchSelected(CurrentDetails)
end)
RunButton.MouseEnter:Connect(function()
    if CurrentDetails then
        tween(RunButton, { BackgroundColor3 = CurrentDetails.Accent }, 0.12):Play()
    end
end)
RunButton.MouseLeave:Connect(function()
    tween(RunButton, { BackgroundColor3 = Color3.fromRGB(37, 201, 238) }, 0.12):Play()
end)

ExpandButton.Activated:Connect(function()
    local expanded = Main.Size.X.Scale < 0.95
    tween(Main, {
        Size = expanded and UDim2.new(0.985, 0, 0.965, 0) or UDim2.new(0.90, 0, 0.86, 0),
    }, 0.20, Enum.EasingStyle.Quint):Play()
end)

CloseButton.Activated:Connect(function()
    local closeMain = tween(Main, {
        Size = UDim2.new(0.84, 0, 0.05, 0),
    }, 0.20, Enum.EasingStyle.Quint)

    local closeBackdrop = tween(Backdrop, {
        BackgroundTransparency = 1,
    }, 0.18)

    closeMain:Play()
    closeBackdrop:Play()
    closeMain.Completed:Wait()

    if ScreenGui then
        ScreenGui:Destroy()
    end
end)

--=======================================================
-- RESPONSIVE GRID
--=======================================================

local function updateGrid()
    local width = CardsScroll.AbsoluteSize.X

    local gap = 12
    local availableWidth = math.max(width - (gap * 2) - 8, 60)
    local cellWidth = math.floor(availableWidth / 3)

    Grid.FillDirectionMaxCells = 3
    Grid.CellSize = UDim2.fromOffset(cellWidth, 320)
    Grid.CellPadding = UDim2.fromOffset(gap, 14)
    Grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
end

CardsScroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateGrid)
task.defer(updateGrid)
task.delay(0.15, updateGrid)

--=======================================================
-- FPS / PING
--=======================================================

task.spawn(function()
    local frames = 0
    local elapsed = 0

    RunService.RenderStepped:Connect(function(dt)
        frames += 1
        elapsed += dt

        if elapsed >= 0.5 then
            local fps = math.floor((frames / elapsed) + 0.5)
            FPSLabel.Text = "FPS: " .. tostring(fps)
            frames = 0
            elapsed = 0
        end
    end)
end)

task.spawn(function()
    while ScreenGui.Parent do
        local pingText = "--"

        pcall(function()
            local perf = Stats:FindFirstChild("PerformanceStats")
            local ping = perf and perf:FindFirstChild("Ping")

            if ping and ping.GetValue then
                pingText = tostring(math.floor(ping:GetValue() + 0.5)) .. "ms"
            end
        end)

        if pingText == "--" then
            pcall(function()
                local network = Stats:FindFirstChild("Network")
                local serverStats = network and network:FindFirstChild("ServerStatsItem")
                local dataPing = serverStats and serverStats:FindFirstChild("Data Ping")

                if dataPing then
                    pingText = dataPing:GetValueString()
                end
            end)
        end

        PingLabel.Text = "PING: " .. tostring(pingText)
        task.wait(0.75)
    end
end)

--=======================================================
-- DRAGGING
--=======================================================

do
    local dragging = false
    local dragStart
    local startPosition

    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = Main.Position
        end
    end)

    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
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
end

--=======================================================
-- START
--=======================================================

Main.Size = UDim2.new(0.84, 0, 0.05, 0)
Main.Rotation = 0
Main.Position = UDim2.fromScale(0.5, 0.5)
MainScale.Scale = 1
Backdrop.BackgroundTransparency = 1

tween(Main, {
    Size = UDim2.new(0.90, 0, 0.86, 0),
}, 0.30, Enum.EasingStyle.Quint):Play()

tween(Backdrop, {
    BackgroundTransparency = 0.28,
}, 0.26):Play()

updateCardVisibility()

task.delay(0.3, function()
    if ScreenGui.Parent then
        notify("NEXUS TACTICAL HUB • READY")
    end
end)
