--// NEXUS TOWER OF HELL • MOBILE v7
--// ONE COMPLETE LocalScript
--// No CanvasGroup
--// No stretch animation
--// No click sounds
--// Mobile + PC
--// Fly + Infinite Jump + Big Jump + Teleport
--// Status + Settings + Profile

--==================================================
-- SERVICES
--==================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

--==================================================
-- REMOVE OLD INSTANCE
--==================================================

pcall(function()
    local old = PlayerGui:FindFirstChild("NexusTowerOfHell")

    if old then
        old:Destroy()
    end
end)

--==================================================
-- CONFIG
--==================================================

local Defaults = {
    Fly = false,
    FlySpeed = 70,

    InfiniteJump = false,

    BigJump = false,
    JumpPower = 90,
}

local Config = table.clone(Defaults)

local SavedConfig = nil

local CONFIG_FILE = "NexusTowerOfHell_Config.json"

-- Forward declarations.
local StartFly
local StopFly

local EnableBigJump
local DisableBigJump

-- IMPORTANT:
-- This variable is declared before the toggle is created.
local FlyWanted = false

--==================================================
-- BASIC HELPERS
--==================================================

local function New(className, properties, parent)
    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    object.Parent = parent

    return object
end

local function Corner(object, radius)
    New("UICorner", {
        CornerRadius = UDim.new(0, radius or 12)
    }, object)
end

local function Stroke(object, color, thickness, transparency)
    New("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0
    }, object)
end

local function Gradient(object, color1, color2, rotation)
    New("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color1),
            ColorSequenceKeypoint.new(1, color2)
        }),
        Rotation = rotation or 0
    }, object)
end

local function Tween(object, duration, properties)
    local tween = TweenService:Create(
        object,
        TweenInfo.new(
            duration,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        properties
    )

    tween:Play()

    return tween
end

local function SafeCall(callback, ...)
    local ok, result = pcall(callback, ...)

    if ok then
        return result
    end

    return nil
end

local function Character()
    return LP.Character
end

local function Humanoid()
    local character = Character()

    if not character then
        return nil
    end

    return character:FindFirstChildOfClass("Humanoid")
end

local function Root()
    local character = Character()

    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
end

local function FormatTime(seconds)
    seconds = math.max(0, math.floor(seconds))

    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    return string.format(
        "%02d:%02d:%02d",
        hours,
        minutes,
        secs
    )
end

local function MembershipName()
    return tostring(
        LP.MembershipType
    ):gsub(
        "Enum.MembershipType.",
        ""
    )
end

--==================================================
-- CONFIG FUNCTIONS
--==================================================

local function SaveConfig()
    SavedConfig = {}

    for key, value in pairs(Config) do
        SavedConfig[key] = value
    end

    -- Optional persistence where writefile exists.
    pcall(function()
        if type(writefile) == "function" then
            writefile(
                CONFIG_FILE,
                HttpService:JSONEncode(SavedConfig)
            )
        end
    end)
end

local function LoadConfig()
    local loaded = nil

    pcall(function()
        if type(readfile) == "function"
            and type(isfile) == "function"
            and isfile(CONFIG_FILE) then

            loaded = HttpService:JSONDecode(
                readfile(CONFIG_FILE)
            )
        end
    end)

    if type(loaded) ~= "table" then
        loaded = SavedConfig
    end

    if type(loaded) ~= "table" then
        return false
    end

    for key, defaultValue in pairs(Defaults) do
        if loaded[key] ~= nil
            and typeof(loaded[key]) == typeof(defaultValue) then

            Config[key] = loaded[key]
        end
    end

    return true
end

local function ResetConfig()
    for key, value in pairs(Defaults) do
        Config[key] = value
    end
end

--==================================================
-- COLORS
--==================================================

local BG = Color3.fromRGB(
    7,
    5,
    12
)

local PANEL = Color3.fromRGB(
    23,
    15,
    40
)

local PANEL2 = Color3.fromRGB(
    34,
    22,
    55
)

local PANEL3 = Color3.fromRGB(
    48,
    29,
    74
)

local TEXT = Color3.fromRGB(
    247,
    244,
    255
)

local MUTED = Color3.fromRGB(
    174,
    161,
    194
)

local PINK = Color3.fromRGB(
    255,
    43,
    139
)

local PINK2 = Color3.fromRGB(
    255,
    92,
    173
)

local PURPLE = Color3.fromRGB(
    132,
    79,
    255
)

local BLUE = Color3.fromRGB(
    63,
    195,
    255
)

local GREEN = Color3.fromRGB(
    67,
    232,
    153
)

local RED = Color3.fromRGB(
    255,
    90,
    110
)

--==================================================
-- ROOT GUI
--==================================================

local Gui = New("ScreenGui", {
    Name = "NexusTowerOfHell",

    ResetOnSpawn = false,

    IgnoreGuiInset = true,

    ZIndexBehavior =
        Enum.ZIndexBehavior.Sibling,

    Enabled = true,
}, PlayerGui)

local GuiScale = New("UIScale", {
    Scale = 1
}, Gui)

local BASE_WIDTH = 720
local BASE_HEIGHT = 540

local Window = New("Frame", {
    Name = "Window",

    AnchorPoint =
        Vector2.new(.5, .5),

    Position =
        UDim2.fromScale(.5, .5),

    Size =
        UDim2.fromOffset(
            BASE_WIDTH,
            BASE_HEIGHT
        ),

    BackgroundColor3 = BG,

    BorderSizePixel = 0,

    Visible = false,

    ClipsDescendants = true,
}, Gui)

Corner(
    Window,
    26
)

Stroke(
    Window,
    Color3.fromRGB(
        119,
        71,
        180
    ),
    2,
    .12
)

--==================================================
-- BACKGROUND GLOW
--==================================================

local GlowA = New("Frame", {
    Position =
        UDim2.fromOffset(
            460,
            -170
        ),

    Size =
        UDim2.fromOffset(
            350,
            350
        ),

    BackgroundColor3 =
        PURPLE,

    BackgroundTransparency =
        .91,

    BorderSizePixel = 0,
}, Window)

Corner(
    GlowA,
    175
)

local GlowB = New("Frame", {
    Position =
        UDim2.fromOffset(
            -160,
            300
        ),

    Size =
        UDim2.fromOffset(
            310,
            310
        ),

    BackgroundColor3 =
        PINK,

    BackgroundTransparency =
        .94,

    BorderSizePixel = 0,
}, Window)

Corner(
    GlowB,
    155
)

--==================================================
-- HEADER
--==================================================

local Header = New("Frame", {
    Size =
        UDim2.new(
            1,
            0,
            0,
            112
        ),

    BackgroundColor3 =
        Color3.fromRGB(
            10,
            7,
            17
        ),

    BorderSizePixel = 0,
}, Window)

local Logo = New("Frame", {
    Position =
        UDim2.fromOffset(
            20,
            17
        ),

    Size =
        UDim2.fromOffset(
            72,
            72
        ),

    BackgroundColor3 =
        Color3.fromRGB(
            28,
            16,
            51
        ),

    BorderSizePixel = 0,
}, Header)

Corner(
    Logo,
    18
)

Stroke(
    Logo,
    PURPLE,
    1,
    .3
)

New("TextLabel", {
    Size =
        UDim2.fromScale(
            1,
            1
        ),

    BackgroundTransparency = 1,

    Text = "N",

    Font =
        Enum.Font.GothamBlack,

    TextSize = 38,

    TextColor3 = PINK,
}, Logo)

New("TextLabel", {
    Position =
        UDim2.fromOffset(
            108,
            18
        ),

    Size =
        UDim2.new(
            1,
            -265,
            0,
            38
        ),

    BackgroundTransparency = 1,

    Text = "NEXUS",

    Font =
        Enum.Font.GothamBlack,

    TextSize = 31,

    TextColor3 = TEXT,

    TextXAlignment =
        Enum.TextXAlignment.Left,
}, Header)

New("TextLabel", {
    Position =
        UDim2.fromOffset(
            109,
            57
        ),

    Size =
        UDim2.new(
            1,
            -265,
            0,
            20
        ),

    BackgroundTransparency = 1,

    Text =
        "TOWER OF HELL • MOBILE",

    Font =
        Enum.Font.GothamMedium,

    TextSize = 11,

    TextColor3 = MUTED,

    TextXAlignment =
        Enum.TextXAlignment.Left,
}, Header)

local OnlineDot = New("Frame", {
    Position =
        UDim2.new(
            1,
            -155,
            0,
            37
        ),

    Size =
        UDim2.fromOffset(
            12,
            12
        ),

    BackgroundColor3 =
        GREEN,

    BorderSizePixel = 0,
}, Header)

Corner(
    OnlineDot,
    9
)

New("TextLabel", {
    Position =
        UDim2.new(
            1,
            -137,
            0,
            29
        ),

    Size =
        UDim2.fromOffset(
            80,
            28
        ),

    BackgroundTransparency = 1,

    Text = "ONLINE",

    Font =
        Enum.Font.GothamBold,

    TextSize = 11,

    TextColor3 =
        GREEN,
}, Header)

local CloseButton = New("TextButton", {
    Position =
        UDim2.new(
            1,
            -67,
            0,
            22
        ),

    Size =
        UDim2.fromOffset(
            45,
            45
        ),

    BackgroundColor3 =
        Color3.fromRGB(
            67,
            26,
            67
        ),

    BorderSizePixel = 0,

    Text = "×",

    Font =
        Enum.Font.GothamBlack,

    TextSize = 29,

    TextColor3 = TEXT,

    AutoButtonColor = false,
}, Header)

Corner(
    CloseButton,
    15
)

local HeaderLine = New("Frame", {
    Position =
        UDim2.new(
            0,
            18,
            1,
            -5
        ),

    Size =
        UDim2.new(
            1,
            -36,
            0,
            3
        ),

    BackgroundColor3 = PINK,

    BorderSizePixel = 0,
}, Header)

Corner(
    HeaderLine,
    2
)

Gradient(
    HeaderLine,
    PINK,
    PURPLE
)

--==================================================
-- TABS
--==================================================

local Tabs = New("Frame", {
    Position =
        UDim2.fromOffset(
            15,
            123
        ),

    Size =
        UDim2.new(
            1,
            -30,
            0,
            56
        ),

    BackgroundColor3 =
        PANEL2,

    BorderSizePixel = 0,
}, Window)

Corner(
    Tabs,
    18
)

Stroke(
    Tabs,
    Color3.fromRGB(
        103,
        70,
        143
    ),
    1,
    .45
)

New("UIListLayout", {
    FillDirection =
        Enum.FillDirection.Horizontal,

    HorizontalAlignment =
        Enum.HorizontalAlignment.Center,

    VerticalAlignment =
        Enum.VerticalAlignment.Center,

    Padding =
        UDim.new(
            0,
            7
        ),
}, Tabs)

local Pages = New("Frame", {
    Position =
        UDim2.fromOffset(
            15,
            190
        ),

    Size =
        UDim2.new(
            1,
            -30,
            1,
            -205
        ),

    BackgroundTransparency = 1,
}, Window)

--==================================================
-- TAB SYSTEM
--==================================================

local TabButtons = {}
local PageObjects = {}

local function CreateTab(name, text)

    local Button = New("TextButton", {
        Size =
            UDim2.fromOffset(
                155,
                43
            ),

        BackgroundColor3 =
            PANEL,

        BorderSizePixel = 0,

        Text = text,

        Font =
            Enum.Font.GothamBold,

        TextSize = 12,

        TextColor3 =
            MUTED,

        AutoButtonColor = false,
    }, Tabs)

    Corner(
        Button,
        14
    )

    TabButtons[name] =
        Button

    return Button
end

CreateTab(
    "STATUS",
    "STATUS"
)

CreateTab(
    "FUNCTIONS",
    "FUNCTIONS"
)

CreateTab(
    "SETTINGS",
    "SETTINGS"
)

CreateTab(
    "PROFILE",
    "PROFILE"
)

local function CreatePage(name)

    local Page = New("ScrollingFrame", {
        Size =
            UDim2.fromScale(
                1,
                1
            ),

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        ScrollBarThickness = 4,

        ScrollBarImageColor3 =
            PURPLE,

        CanvasSize =
            UDim2.new(
                0,
                0,
                0,
                0
            ),

        AutomaticCanvasSize =
            Enum.AutomaticSize.Y,

        Visible = false,
    }, Pages)

    New("UIPadding", {
        PaddingTop =
            UDim.new(
                0,
                3
            ),

        PaddingBottom =
            UDim.new(
                0,
                15
            ),

        PaddingLeft =
            UDim.new(
                0,
                2
            ),

        PaddingRight =
            UDim.new(
                0,
                2
            ),
    }, Page)

    New("UIListLayout", {
        Padding =
            UDim.new(
                0,
                10
            ),

        SortOrder =
            Enum.SortOrder.LayoutOrder,
    }, Page)

    PageObjects[name] =
        Page

    return Page
end

local StatusPage =
    CreatePage("STATUS")

local FunctionsPage =
    CreatePage("FUNCTIONS")

local SettingsPage =
    CreatePage("SETTINGS")

local ProfilePage =
    CreatePage("PROFILE")

--==================================================
-- CARD HELPERS
--==================================================

local function Card(parent, height)

    local Frame = New("Frame", {
        Size =
            UDim2.new(
                1,
                0,
                0,
                height
            ),

        BackgroundColor3 =
            PANEL,

        BorderSizePixel = 0,
    }, parent)

    Corner(
        Frame,
        18
    )

    Stroke(
        Frame,
        Color3.fromRGB(
            102,
            73,
            141
        ),
        1,
        .48
    )

    return Frame
end

local function Title(
    parent,
    text,
    color
)

    return New("TextLabel", {
        Position =
            UDim2.fromOffset(
                17,
                12
            ),

        Size =
            UDim2.new(
                1,
                -34,
                0,
                24
            ),

        BackgroundTransparency =
            1,

        Text = text,

        Font =
            Enum.Font.GothamBlack,

        TextSize = 14,

        TextColor3 =
            color or TEXT,

        TextXAlignment =
            Enum.TextXAlignment.Left,
    }, parent)
end

local function Row(
    parent,
    text,
    y,
    color,
    size
)

    return New("TextLabel", {
        Position =
            UDim2.fromOffset(
                17,
                y
            ),

        Size =
            UDim2.new(
                1,
                -34,
                0,
                22
            ),

        BackgroundTransparency =
            1,

        Text = text,

        Font =
            Enum.Font.GothamMedium,

        TextSize =
            size or 11,

        TextColor3 =
            color or MUTED,

        TextXAlignment =
            Enum.TextXAlignment.Left,
    }, parent)
end

--==================================================
-- STATUS PAGE
--==================================================

local AccountCard =
    Card(
        StatusPage,
        220
    )

Title(
    AccountCard,
    "ACCOUNT STATUS",
    PINK2
)

Row(
    AccountCard,
    "Display Name: "
        ..LP.DisplayName,
    42,
    TEXT
)

Row(
    AccountCard,
    "Username: @"
        ..LP.Name,
    66
)

Row(
    AccountCard,
    "UserId: "
        ..tostring(
            LP.UserId
        ),
    90,
    BLUE
)

Row(
    AccountCard,
    "Account age: "
        ..tostring(
            LP.AccountAge
        )
        .." days",
    114,
    TEXT
)

Row(
    AccountCard,
    "Membership: "
        ..MembershipName(),
    138
)

Row(
    AccountCard,
    "Team: "
        ..(
            LP.Team
            and LP.Team.Name
            or "None"
        ),
    162
)

Row(
    AccountCard,
    "Character: "
        ..(
            LP.Character
            and "Loaded"
            or "Not loaded"
        ),
    186,
    GREEN
)

--==================================================
-- PLACE STATUS
--==================================================

local PlaceCard =
    Card(
        StatusPage,
        275
    )

Title(
    PlaceCard,
    "PLACE / SERVER STATUS",
    BLUE
)

local PlaceName = "Unknown"
local CreatorName = "Unknown"

pcall(function()

    local Info =
        MarketplaceService:GetProductInfo(
            game.PlaceId
        )

    if Info then

        PlaceName =
            tostring(
                Info.Name
                or "Unknown"
            )

        if Info.Creator then

            CreatorName =
                tostring(
                    Info.Creator.Name
                    or "Unknown"
                )

        end
    end
end)

Row(
    PlaceCard,
    "Place: "
        ..PlaceName,
    42,
    TEXT
)

Row(
    PlaceCard,
    "Creator: "
        ..CreatorName,
    66
)

Row(
    PlaceCard,
    "PlaceId: "
        ..tostring(
            game.PlaceId
        ),
    90,
    BLUE
)

Row(
    PlaceCard,
    "JobId: "
        ..(
            game.JobId ~= ""
            and game.JobId
            or "Unavailable / Studio"
        ),
    114
)

local PlayersLine =
    Row(
        PlaceCard,
        "Players: "
            ..#Players:GetPlayers()
            .." / "
            ..Players.MaxPlayers,
        138,
        TEXT
    )

local UptimeLine =
    Row(
        PlaceCard,
        "Server online: detecting...",
        162,
        GREEN
    )

Row(
    PlaceCard,
    "Gravity: "
        ..string.format(
            "%.1f",
            workspace.Gravity
        ),
    186
)

local FPSLine =
    Row(
        PlaceCard,
        "FPS: detecting...",
        210,
        GREEN
    )

--==================================================
-- TOGGLE SYSTEM
--==================================================

local function CreateToggle(
    parent,
    text,
    initial,
    callback,
    y
)

    local Button = New("TextButton", {
        Position =
            UDim2.fromOffset(
                16,
                y
            ),

        Size =
            UDim2.new(
                1,
                -32,
                0,
                43
            ),

        BackgroundColor3 =
            PANEL2,

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false,
    }, parent)

    Corner(
        Button,
        13
    )

    New("TextLabel", {
        Position =
            UDim2.fromOffset(
                13,
                0
            ),

        Size =
            UDim2.new(
                .7,
                0,
                1,
                0
            ),

        BackgroundTransparency =
            1,

        Text = text,

        Font =
            Enum.Font.GothamBold,

        TextSize = 12,

        TextColor3 = TEXT,

        TextXAlignment =
            Enum.TextXAlignment.Left,
    }, Button)

    local Pill = New("Frame", {
        Position =
            UDim2.new(
                1,
                -80,
                .5,
                -12
            ),

        Size =
            UDim2.fromOffset(
                64,
                24
            ),

        BackgroundColor3 =
            Color3.fromRGB(
                67,
                57,
                78
            ),

        BorderSizePixel = 0,
    }, Button)

    Corner(
        Pill,
        13
    )

    local Knob = New("Frame", {
        Position =
            UDim2.fromOffset(
                4,
                4
            ),

        Size =
            UDim2.fromOffset(
                16,
                16
            ),

        BackgroundColor3 =
            Color3.fromRGB(
                218,
                213,
                225
            ),

        BorderSizePixel = 0,
    }, Pill)

    Corner(
        Knob,
        10
    )

    local Value = initial

    local function Refresh()

        Pill.BackgroundColor3 =
            Value
            and Color3.fromRGB(
                84,
                46,
                112
            )
            or Color3.fromRGB(
                67,
                57,
                78
            )

        Knob.BackgroundColor3 =
            Value
            and PINK2
            or Color3.fromRGB(
                218,
                213,
                225
            )

        Tween(
            Knob,
            .15,
            {
                Position =
                    Value
                    and UDim2.new(
                        1,
                        -20,
                        0,
                        4
                    )
                    or UDim2.fromOffset(
                        4,
                        4
                    )
            }
        )
    end

    Button.Activated:Connect(function()

        Value =
            not Value

        Refresh()

        callback(Value)
    end)

    Refresh()

    return {

        Button = Button,

        Set = function(value)

            Value =
                value

            Refresh()

            callback(value)
        end
    }
end

--==================================================
-- BIG JUMP STATE
--==================================================

local OriginalJumpPower = nil
local OriginalUseJumpPower = nil
local OriginalHumanoid = nil

EnableBigJump = function()

    local Hum =
        Humanoid()

    if not Hum then
        return
    end

    -- Store the actual default state
    -- of the current humanoid.
    if OriginalHumanoid ~= Hum then

        OriginalHumanoid =
            Hum

        OriginalJumpPower =
            Hum.JumpPower

        OriginalUseJumpPower =
            Hum.UseJumpPower
    end

    Hum.UseJumpPower = true

    Hum.JumpPower =
        Config.JumpPower
end

DisableBigJump = function()

    local Hum =
        Humanoid()

    if not Hum then
        return
    end

    if OriginalHumanoid == Hum
        and OriginalJumpPower ~= nil then

        Hum.JumpPower =
            OriginalJumpPower

        if OriginalUseJumpPower ~= nil then

            Hum.UseJumpPower =
                OriginalUseJumpPower
        end

    else

        -- Safe Roblox fallback.
        Hum.JumpPower = 50
        Hum.UseJumpPower = true

    end
end

--==================================================
-- FUNCTIONS PAGE
--==================================================

local FlyCard =
    Card(
        FunctionsPage,
        178
    )

Title(
    FlyCard,
    "FLY CONTROL",
    PINK2
)

-- IMPORTANT:
-- StartFly/StopFly are forward-declared above,
-- so this callback can safely call them.

local FlyToggle =
    CreateToggle(
        FlyCard,
        "FLY",
        Config.Fly,

        function(value)

            Config.Fly =
                value

            FlyWanted =
                value

            if value then

                StartFly()

            else

                StopFly()

            end

        end,

        45
    )

local SpeedLabel =
    Row(
        FlyCard,
        "Speed: "
            ..Config.FlySpeed,
        93,
        MUTED
    )

local SpeedMinus =
    New("TextButton", {

        Position =
            UDim2.new(
                1,
                -108,
                0,
                90
            ),

        Size =
            UDim2.fromOffset(
                42,
                36
            ),

        BackgroundColor3 =
            PANEL3,

        BorderSizePixel = 0,

        Text = "−",

        Font =
            Enum.Font.GothamBlack,

        TextSize = 19,

        TextColor3 = TEXT,

        AutoButtonColor = false,

    }, FlyCard)

Corner(
    SpeedMinus,
    10
)

local SpeedPlus =
    New("TextButton", {

        Position =
            UDim2.new(
                1,
                -60,
                0,
                90
            ),

        Size =
            UDim2.fromOffset(
                42,
                36
            ),

        BackgroundColor3 =
            PANEL3,

        BorderSizePixel = 0,

        Text = "+",

        Font =
            Enum.Font.GothamBlack,

        TextSize = 19,

        TextColor3 = TEXT,

        AutoButtonColor = false,

    }, FlyCard)

Corner(
    SpeedPlus,
    10
)

local SpeedInfo =
    New("TextLabel", {

        Position =
            UDim2.fromOffset(
                16,
                126
            ),

        Size =
            UDim2.new(
                1,
                -32,
                0,
                22
            ),

        BackgroundTransparency = 1,

        Text =
            "Camera-relative 3D movement",

        Font =
            Enum.Font.GothamMedium,

        TextSize = 10,

        TextColor3 = MUTED,

        TextXAlignment =
            Enum.TextXAlignment.Left,

    }, FlyCard)

local function UpdateFlyUI()

    SpeedLabel.Text =
        "Speed: "
        ..Config.FlySpeed

    SpeedInfo.Text =
        "Camera-relative 3D movement • Speed "
        ..Config.FlySpeed
end

SpeedMinus.Activated:Connect(
    function()

        Config.FlySpeed =
            math.max(
                20,
                Config.FlySpeed - 10
            )

        UpdateFlyUI()

    end
)

SpeedPlus.Activated:Connect(
    function()

        Config.FlySpeed =
            math.min(
                180,
                Config.FlySpeed + 10
            )

        UpdateFlyUI()

    end
)

--==================================================
-- JUMP CARD
--==================================================

local JumpCard =
    Card(
        FunctionsPage,
        180
    )

Title(
    JumpCard,
    "JUMP",
    BLUE
)

local InfiniteToggle =
    CreateToggle(
        JumpCard,
        "INFINITE JUMP",
        Config.InfiniteJump,

        function(value)

            Config.InfiniteJump =
                value

        end,

        45
    )

local BigJumpToggle =
    CreateToggle(
        JumpCard,
        "BIG JUMP",
        Config.BigJump,

        function(value)

            Config.BigJump =
                value

            if value then

                EnableBigJump()

            else

                DisableBigJump()

            end

        end,

        91
    )

local JumpLabel =
    Row(
        JumpCard,
        "Jump Power: "
            ..Config.JumpPower,
        139,
        MUTED
    )

local JumpMinus =
    New("TextButton", {

        Position =
            UDim2.new(
                1,
                -108,
                0,
                136
            ),

        Size =
            UDim2.fromOffset(
                42,
                32
            ),

        BackgroundColor3 =
            PANEL3,

        BorderSizePixel = 0,

        Text = "−",

        Font =
            Enum.Font.GothamBlack,

        TextSize = 18,

        TextColor3 = TEXT,

        AutoButtonColor = false,

    }, JumpCard)

Corner(
    JumpMinus,
    10
)

local JumpPlus =
    New("TextButton", {

        Position =
            UDim2.new(
                1,
                -60,
                0,
                136
            ),

        Size =
            UDim2.fromOffset(
                42,
                32
            ),

        BackgroundColor3 =
            PANEL3,

        BorderSizePixel = 0,

        Text = "+",

        Font =
            Enum.Font.GothamBlack,

        TextSize = 18,

        TextColor3 = TEXT,

        AutoButtonColor = false,

    }, JumpCard)

Corner(
    JumpPlus,
    10
)

local function UpdateJumpUI()

    JumpLabel.Text =
        "Jump Power: "
        ..Config.JumpPower

end

JumpMinus.Activated:Connect(
    function()

        Config.JumpPower =
            math.max(
                50,
                Config.JumpPower - 10
            )

        UpdateJumpUI()

        if Config.BigJump then
            EnableBigJump()
        end

    end
)

JumpPlus.Activated:Connect(
    function()

        Config.JumpPower =
            math.min(
                250,
                Config.JumpPower + 10
            )

        UpdateJumpUI()

        if Config.BigJump then
            EnableBigJump()
        end

    end
)

--==================================================
-- PLAYER TELEPORT
--==================================================

local PlayerCard =
    Card(
        FunctionsPage,
        245
    )

Title(
    PlayerCard,
    "PLAYER TELEPORT",
    PINK2
)

Row(
    PlayerCard,
    "Tap a player, then teleport to them.",
    38,
    MUTED,
    10
)

local PlayerList =
    New("ScrollingFrame", {

        Position =
            UDim2.fromOffset(
                12,
                66
            ),

        Size =
            UDim2.new(
                1,
                -24,
                1,
                -122
            ),

        BackgroundTransparency = 1,

        BorderSizePixel = 0,

        ScrollBarThickness = 3,

        ScrollBarImageColor3 =
            PURPLE,

        CanvasSize =
            UDim2.new(
                0,
                0,
                0,
                0
            ),

        AutomaticCanvasSize =
            Enum.AutomaticSize.Y,

    }, PlayerCard)

New("UIListLayout", {

    Padding =
        UDim.new(
            0,
            6
        ),

    SortOrder =
        Enum.SortOrder.Name,

}, PlayerList)

local SelectedPlayer = nil

local function RebuildPlayers()

    for _, child in ipairs(
        PlayerList:GetChildren()
    ) do

        if child:IsA("TextButton") then
            child:Destroy()
        end

    end

    for _, player in ipairs(
        Players:GetPlayers()
    ) do

        if player ~= LP then

            local Button =
                New("TextButton", {

                    Size =
                        UDim2.new(
                            1,
                            0,
                            0,
                            38
                        ),

                    BackgroundColor3 =
                        PANEL2,

                    BorderSizePixel = 0,

                    Text =
                        player.DisplayName
                        .."  @"
                        ..player.Name,

                    Font =
                        Enum.Font.GothamSemibold,

                    TextSize = 11,

                    TextColor3 =
                        TEXT,

                    TextXAlignment =
                        Enum.TextXAlignment.Left,

                    AutoButtonColor = false,

                }, PlayerList)

            Corner(
                Button,
                11
            )

            New("UIPadding", {

                PaddingLeft =
                    UDim.new(
                        0,
                        12
                    )

            }, Button)

            Button.Activated:Connect(
                function()

                    SelectedPlayer =
                        player

                    for _, item in ipairs(
                        PlayerList:GetChildren()
                    ) do

                        if item:IsA(
                            "TextButton"
                        ) then

                            item.BackgroundColor3 =
                                item == Button
                                and Color3.fromRGB(
                                    93,
                                    48,
                                    119
                                )
                                or PANEL2

                        end

                    end

                end
            )
        end

    end
end

local TeleportButton =
    New("TextButton", {

        Position =
            UDim2.new(
                0,
                12,
                1,
                -48
            ),

        Size =
            UDim2.new(
                1,
                -24,
                0,
                38
            ),

        BackgroundColor3 =
            PINK,

        BorderSizePixel = 0,

        Text =
            "TELEPORT TO SELECTED",

        Font =
            Enum.Font.GothamBlack,

        TextSize = 11,

        TextColor3 = TEXT,

        AutoButtonColor = false,

    }, PlayerCard)

Corner(
    TeleportButton,
    12
)

TeleportButton.Activated:Connect(
    function()

        if not SelectedPlayer then
            return
        end

        local targetCharacter =
            SelectedPlayer.Character

        local targetRoot =
            targetCharacter
            and targetCharacter:FindFirstChild(
                "HumanoidRootPart"
            )

        local myCharacter =
            LP.Character

        if targetRoot
            and myCharacter then

            myCharacter:PivotTo(
                targetRoot.CFrame
                    * CFrame.new(
                        0,
                        4,
                        0
                    )
            )

        end

    end
)

Players.PlayerAdded:Connect(
    RebuildPlayers
)

Players.PlayerRemoving:Connect(
    function(player)

        if SelectedPlayer == player then
            SelectedPlayer = nil
        end

        RebuildPlayers()

    end
)

RebuildPlayers()

--==================================================
-- SERVER SETTINGS
--==================================================

local ServerCard =
    Card(
        SettingsPage,
        222
    )

Title(
    ServerCard,
    "SERVER",
    PINK2
)

Row(
    ServerCard,
    "JobId: "
        ..(
            game.JobId ~= ""
            and game.JobId
            or "Unavailable / Studio"
        ),
    42,
    MUTED,
    10
)

local RejoinButton =
    New("TextButton", {

        Position =
            UDim2.fromOffset(
                16,
                72
            ),

        Size =
            UDim2.new(
                1,
                -32,
                0,
                42
            ),

        BackgroundColor3 =
            PINK,

        BorderSizePixel = 0,

        Text =
            "REJOIN CURRENT SERVER",

        Font =
            Enum.Font.GothamBlack,

        TextSize = 12,

        TextColor3 = TEXT,

        AutoButtonColor = false,

    }, ServerCard)

Corner(
    RejoinButton,
    13
)

RejoinButton.Activated:Connect(
    function()

        if game.JobId == "" then
            return
        end

        pcall(function()

            TeleportService:
                TeleportToPlaceInstance(
                    game.PlaceId,
                    game.JobId,
                    LP
                )

        end)

    end
)

local ServerLink =
    "https://www.roblox.com/games/start?placeId="
    ..game.PlaceId
    .."&gameInstanceId="
    ..game.JobId

local LinkBox =
    New("TextBox", {

        Position =
            UDim2.fromOffset(
                16,
                121
            ),

        Size =
            UDim2.new(
                1,
                -32,
                0,
                37
            ),

        BackgroundColor3 =
            PANEL2,

        BorderSizePixel = 0,

        Text =
            ServerLink,

        PlaceholderText =
            "Server link",

        PlaceholderColor3 =
            MUTED,

        TextColor3 =
            TEXT,

        Font =
            Enum.Font.GothamMedium,

        TextSize = 9,

        ClearTextOnFocus = false,

    }, ServerCard)

Corner(
    LinkBox,
    10
)

local CopyButton =
    New("TextButton", {

        Position =
            UDim2.fromOffset(
                16,
                165
            ),

        Size =
            UDim2.new(
                1,
                -32,
                0,
                35
            ),

        BackgroundColor3 =
            PANEL3,

        BorderSizePixel = 0,

        Text =
            "SELECT / COPY SERVER LINK",

        Font =
            Enum.Font.GothamBold,

        TextSize = 10,

        TextColor3 = TEXT,

        AutoButtonColor = false,

    }, ServerCard)

Corner(
    CopyButton,
    10
)

CopyButton.Activated:Connect(
    function()

        LinkBox:CaptureFocus()

        LinkBox.SelectionStart = 1

        LinkBox.CursorPosition =
            #LinkBox.Text + 1

    end
)

--==================================================
-- CONFIGURATION CARD
--==================================================

local ConfigCard =
    Card(
        SettingsPage,
        180
    )

Title(
    ConfigCard,
    "CONFIGURATION",
    PINK2
)

Row(
    ConfigCard,
    "Save your current Nexus settings.",
    39,
    MUTED,
    10
)

local SaveButton =
    New("TextButton", {

        Position =
            UDim2.fromOffset(
                16,
                66
            ),

        Size =
            UDim2.new(
                .31,
                -8,
                0,
                40
            ),

        BackgroundColor3 =
            PINK,

        BorderSizePixel = 0,

        Text =
            "SAVE",

        Font =
            Enum.Font.GothamBlack,

        TextSize = 11,

        TextColor3 =
            TEXT,

        AutoButtonColor = false,

    }, ConfigCard)

Corner(
    SaveButton,
    11
)

local LoadButton =
    New("TextButton", {

        Position =
            UDim2.new(
                .345,
                0,
                0,
                66
            ),

        Size =
            UDim2.new(
                .31,
                -8,
                0,
                40
            ),

        BackgroundColor3 =
            PANEL3,

        BorderSizePixel = 0,

        Text =
            "LOAD",

        Font =
            Enum.Font.GothamBlack,

        TextSize = 11,

        TextColor3 =
            TEXT,

        AutoButtonColor = false,

    }, ConfigCard)

Corner(
    LoadButton,
    11
)

local ResetButton =
    New("TextButton", {

        Position =
            UDim2.new(
                .69,
                0,
                0,
                66
            ),

        Size =
            UDim2.new(
                .31,
                -8,
                0,
                40
            ),

        BackgroundColor3 =
            Color3.fromRGB(
                73,
                28,
                50
            ),

        BorderSizePixel = 0,

        Text =
            "RESET",

        Font =
            Enum.Font.GothamBlack,

        TextSize = 11,

        TextColor3 =
            TEXT,

        AutoButtonColor = false,

    }, ConfigCard)

Corner(
    ResetButton,
    11
)

local ConfigStatus =
    Row(
        ConfigCard,
        "No saved configuration.",
        119,
        MUTED,
        10
    )

SaveButton.Activated:Connect(
    function()

        SaveConfig()

        ConfigStatus.Text =
            "Configuration saved."

        ConfigStatus.TextColor3 =
            GREEN

    end
)

LoadButton.Activated:Connect(
    function()

        if not LoadConfig() then

            ConfigStatus.Text =
                "Nothing to load."

            ConfigStatus.TextColor3 =
                RED

            return
        end

        FlyToggle.Set(
            Config.Fly
        )

        InfiniteToggle.Set(
            Config.InfiniteJump
        )

        BigJumpToggle.Set(
            Config.BigJump
        )

        UpdateFlyUI()
        UpdateJumpUI()

        ConfigStatus.Text =
            "Configuration loaded."

        ConfigStatus.TextColor3 =
            BLUE

    end
)

ResetButton.Activated:Connect(
    function()

        -- Turn off active abilities first,
        -- so their state is properly restored.

        if Config.Fly then

            Config.Fly = false
            FlyWanted = false

            StopFly()

        end

        if Config.BigJump then

            Config.BigJump = false

            DisableBigJump()

        end

        ResetConfig()

        FlyToggle.Set(false)

        InfiniteToggle.Set(false)

        BigJumpToggle.Set(false)

        UpdateFlyUI()
        UpdateJumpUI()

        ConfigStatus.Text =
            "Defaults restored."

        ConfigStatus.TextColor3 =
            GREEN

    end
)

--==================================================
-- DEVICE CARD
--==================================================

local DeviceCard =
    Card(
        SettingsPage,
        285
    )

Title(
    DeviceCard,
    "DEVICE / CLIENT",
    BLUE
)

Row(
    DeviceCard,
    "Touch: "
        ..(
            UIS.TouchEnabled
            and "YES"
            or "NO"
        ),
    42,
    UIS.TouchEnabled
        and GREEN
        or MUTED
)

Row(
    DeviceCard,
    "Keyboard: "
        ..(
            UIS.KeyboardEnabled
            and "YES"
            or "NO"
        ),
    68
)

Row(
    DeviceCard,
    "Mouse: "
        ..(
            UIS.MouseEnabled
            and "YES"
            or "NO"
        ),
    94
)

Row(
    DeviceCard,
    "Gamepad: "
        ..(
            UIS.GamepadEnabled
            and "YES"
            or "NO"
        ),
    120
)

local CurrentCamera =
    workspace.CurrentCamera

Row(
    DeviceCard,
    "Viewport: "
        ..(
            CurrentCamera
            and CurrentCamera.ViewportSize.X
            or 0
        )
        .." × "
        ..(
            CurrentCamera
            and CurrentCamera.ViewportSize.Y
            or 0
        ),
    146,
    TEXT
)

Row(
    DeviceCard,
    "PlaceId: "
        ..game.PlaceId,
    172
)

Row(
    DeviceCard,
    "Roblox handles graphics quality automatically.",
    198,
    MUTED,
    10
)

Row(
    DeviceCard,
    "Phone model is not exposed by normal Roblox APIs.",
    224,
    MUTED,
    9
)

--==================================================
-- PROFILE
--==================================================

local ProfileCard =
    Card(
        ProfilePage,
        292
    )

Title(
    ProfileCard,
    "ROBLOX PROFILE",
    PINK2
)

local Avatar =
    New("ImageLabel", {

        Position =
            UDim2.fromOffset(
                18,
                47
            ),

        Size =
            UDim2.fromOffset(
                105,
                105
            ),

        BackgroundColor3 =
            PANEL2,

        BorderSizePixel = 0,

        Image = "",

    }, ProfileCard)

Corner(
    Avatar,
    18
)

New("TextLabel", {

    Position =
        UDim2.fromOffset(
            140,
            50
        ),

    Size =
        UDim2.new(
            1,
            -158,
            0,
            30
        ),

    BackgroundTransparency = 1,

    Text =
        LP.DisplayName,

    Font =
        Enum.Font.GothamBlack,

    TextSize = 19,

    TextColor3 =
        TEXT,

    TextXAlignment =
        Enum.TextXAlignment.Left,

}, ProfileCard)

New("TextLabel", {

    Position =
        UDim2.fromOffset(
            140,
            83
        ),

    Size =
        UDim2.new(
            1,
            -158,
            0,
            23
        ),

    BackgroundTransparency = 1,

    Text =
        "@"
        ..LP.Name,

    Font =
        Enum.Font.GothamMedium,

    TextSize = 12,

    TextColor3 =
        MUTED,

    TextXAlignment =
        Enum.TextXAlignment.Left,

}, ProfileCard)

New("TextLabel", {

    Position =
        UDim2.fromOffset(
            140,
            109
        ),

    Size =
        UDim2.new(
            1,
            -158,
            0,
            23
        ),

    BackgroundTransparency = 1,

    Text =
        "UserId: "
        ..LP.UserId,

    Font =
        Enum.Font.GothamMedium,

    TextSize = 11,

    TextColor3 =
        BLUE,

    TextXAlignment =
        Enum.TextXAlignment.Left,

}, ProfileCard)

Row(
    ProfileCard,
    "Account age: "
        ..LP.AccountAge
        .." days",
    176,
    TEXT
)

Row(
    ProfileCard,
    "Membership: "
        ..MembershipName(),
    202
)

Row(
    ProfileCard,
    "Team: "
        ..(
            LP.Team
            and LP.Team.Name
            or "None"
        ),
    228
)

Row(
    ProfileCard,
    "Character: "
        ..(
            LP.Character
            and "Loaded"
            or "Not loaded"
        ),
    254,
    GREEN
)

task.spawn(function()

    pcall(function()

        local image =
            Players:GetUserThumbnailAsync(
                LP.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size180x180
            )

        Avatar.Image =
            image
    end)

end)

--==================================================
-- FLY ENGINE
--==================================================

local FlyVelocity = nil
local FlyGyro = nil
local FlyConnection = nil

StopFly = function()

    if FlyConnection then

        FlyConnection:Disconnect()

        FlyConnection = nil

    end

    if FlyVelocity then

        FlyVelocity:Destroy()

        FlyVelocity = nil

    end

    if FlyGyro then

        FlyGyro:Destroy()

        FlyGyro = nil

    end

    local Hum =
        Humanoid()

    if Hum then

        Hum.PlatformStand =
            false

        Hum.AutoRotate =
            true

    end
end

StartFly = function()

    -- Prevent duplicate BodyMovers/connections.
    StopFly()

    local RootPart =
        Root()

    local Hum =
        Humanoid()

    if not RootPart
        or not Hum
        or Hum.Health <= 0 then

        return false
    end

    FlyVelocity =
        Instance.new(
            "BodyVelocity"
        )

    FlyVelocity.Name =
        "NexusFlyVelocity"

    FlyVelocity.MaxForce =
        Vector3.new(
            1e9,
            1e9,
            1e9
        )

    FlyVelocity.P =
        10000

    FlyVelocity.Velocity =
        Vector3.zero

    FlyVelocity.Parent =
        RootPart

    FlyGyro =
        Instance.new(
            "BodyGyro"
        )

    FlyGyro.Name =
        "NexusFlyGyro"

    FlyGyro.MaxTorque =
        Vector3.new(
            1e9,
            1e9,
            1e9
        )

    FlyGyro.P =
        30000

    FlyGyro.D =
        1000

    FlyGyro.CFrame =
        RootPart.CFrame

    FlyGyro.Parent =
        RootPart

    Hum.PlatformStand =
        true

    Hum.AutoRotate =
        false

    FlyConnection =
        RunService.RenderStepped:Connect(
            function()

                if not Config.Fly
                    or not FlyWanted then

                    StopFly()

                    return
                end

                local CurrentRoot =
                    Root()

                local CurrentHumanoid =
                    Humanoid()

                local Camera =
                    workspace.CurrentCamera

                if not CurrentRoot
                    or not CurrentHumanoid
                    or CurrentHumanoid.Health <= 0
                    or not Camera then

                    StopFly()

                    return
                end

                local Move =
                    CurrentHumanoid.MoveDirection

                local CameraCF =
                    Camera.CFrame

                -- Horizontal camera directions.
                local FlatLook =
                    Vector3.new(
                        CameraCF.LookVector.X,
                        0,
                        CameraCF.LookVector.Z
                    )

                local FlatRight =
                    Vector3.new(
                        CameraCF.RightVector.X,
                        0,
                        CameraCF.RightVector.Z
                    )

                local ForwardInput = 0
                local SideInput = 0

                if FlatLook.Magnitude > .02 then

                    ForwardInput =
                        Move:Dot(
                            FlatLook.Unit
                        )

                end

                if FlatRight.Magnitude > .02 then

                    SideInput =
                        Move:Dot(
                            FlatRight.Unit
                        )

                end

                local Direction =
                    Vector3.zero

                -- Full camera-relative 3D flight.
                --
                -- Camera looking UP
                -- + forward movement
                -- = fly upward.
                --
                -- Camera looking DOWN
                -- + forward movement
                -- = fly downward.

                if math.abs(
                    ForwardInput
                ) > .02 then

                    Direction +=
                        CameraCF.LookVector
                        * ForwardInput

                end

                if math.abs(
                    SideInput
                ) > .02
                    and FlatRight.Magnitude > .02 then

                    Direction +=
                        FlatRight.Unit
                        * SideInput

                end

                if Direction.Magnitude > 1 then

                    Direction =
                        Direction.Unit

                end

                if Move.Magnitude < .05 then

                    Direction =
                        Vector3.zero

                end

                FlyVelocity.Velocity =
                    Direction
                    * Config.FlySpeed

                if FlatLook.Magnitude > .02 then

                    FlyGyro.CFrame =
                        CFrame.lookAt(
                            CurrentRoot.Position,
                            CurrentRoot.Position
                                + FlatLook.Unit
                        )

                end

            end
        )

    return true
end

--==================================================
-- ABILITY LOOP
--==================================================

RunService.Heartbeat:Connect(
    function()

        -- Fly state repair.
        if Config.Fly
            and not FlyWanted then

            FlyWanted =
                true

            StartFly()

        elseif not Config.Fly
            and FlyWanted then

            FlyWanted =
                false

            StopFly()

        end

        -- Big Jump:
        -- Only modify JumpPower while it is enabled.
        local Hum =
            Humanoid()

        if Hum
            and Config.BigJump then

            if OriginalHumanoid ~= Hum then

                OriginalHumanoid =
                    Hum

                OriginalJumpPower =
                    Hum.JumpPower

                OriginalUseJumpPower =
                    Hum.UseJumpPower

            end

            Hum.UseJumpPower =
                true

            Hum.JumpPower =
                Config.JumpPower

        end

    end
)

--==================================================
-- CHARACTER / RESPAWN
--==================================================

local function SetupCharacter(character)

    local Hum =
        character:WaitForChild(
            "Humanoid",
            5
        )

    if not Hum then
        return
    end

    -- Save real values for this humanoid.
    OriginalHumanoid =
        Hum

    OriginalJumpPower =
        Hum.JumpPower

    OriginalUseJumpPower =
        Hum.UseJumpPower

    Hum.Died:Connect(
        function()

            StopFly()

        end
    )

    task.delay(
        .7,
        function()

            local NewHum =
                Humanoid()

            if not NewHum then
                return
            end

            OriginalHumanoid =
                NewHum

            OriginalJumpPower =
                NewHum.JumpPower

            OriginalUseJumpPower =
                NewHum.UseJumpPower

            -- Restore the correct current mode.
            if Config.BigJump then

                EnableBigJump()

            else

                DisableBigJump()

            end

            if Config.Fly then

                FlyWanted =
                    true

                StartFly()

            end

        end
    )
end

if LP.Character then
    SetupCharacter(
        LP.Character
    )
end

LP.CharacterAdded:Connect(
    SetupCharacter
)

--==================================================
-- INFINITE JUMP
--==================================================

UIS.JumpRequest:Connect(
    function()

        if not Config.InfiniteJump then
            return
        end

        local Hum =
            Humanoid()

        if Hum
            and Hum.Health > 0 then

            Hum:ChangeState(
                Enum.HumanoidStateType.Jumping
            )

        end

    end
)

--==================================================
-- FPS
--==================================================

local FPS = 60
local FrameCount = 0
local FPSTime = os.clock()

RunService.RenderStepped:Connect(
    function()

        FrameCount += 1

        local elapsed =
            os.clock()
            - FPSTime

        if elapsed >= 1 then

            FPS =
                math.floor(
                    FrameCount
                    / elapsed
                    + .5
                )

            FrameCount = 0

            FPSTime =
                os.clock()

        end

    end
)

--==================================================
-- LIVE STATUS
--==================================================

task.spawn(function()

    while Gui.Parent do

        task.wait(1)

        PlayersLine.Text =
            "Players: "
            ..#Players:GetPlayers()
            .." / "
            ..Players.MaxPlayers

        FPSLine.Text =
            "FPS: "
            ..FPS

        local ServerStart =
            workspace:GetAttribute(
                "NexusServerStartUnix"
            )

        if typeof(ServerStart)
            == "number" then

            UptimeLine.Text =
                "Server online: "
                ..FormatTime(
                    os.time()
                    - ServerStart
                )

        else

            UptimeLine.Text =
                "Online: "
                ..FormatTime(
                    workspace.DistributedGameTime
                )

        end

        SpeedInfo.Text =
            "Camera-relative 3D movement • Speed "
            ..Config.FlySpeed

    end

end)

--==================================================
-- TAB SWITCH
--==================================================

local function ShowTab(name)

    for pageName, page in pairs(
        PageObjects
    ) do

        page.Visible =
            pageName == name

    end

    for tabName, button in pairs(
        TabButtons
    ) do

        local Active =
            tabName == name

        button.BackgroundColor3 =
            Active
            and PINK
            or PANEL

        button.TextColor3 =
            Active
            and TEXT
            or MUTED

    end
end

for name, button in pairs(
    TabButtons
) do

    button.Activated:Connect(
        function()

            ShowTab(name)

        end
    )

end

ShowTab(
    "STATUS"
)

--==================================================
-- REOPEN BUTTON
--==================================================

local OpenButton =
    New("TextButton", {

        AnchorPoint =
            Vector2.new(
                .5,
                .5
            ),

        Position =
            UDim2.fromScale(
                .5,
                .85
            ),

        Size =
            UDim2.fromOffset(
                74,
                74
            ),

        BackgroundColor3 =
            Color3.fromRGB(
                14,
                10,
                25
            ),

        BorderSizePixel = 0,

        Text = "",

        AutoButtonColor = false,

        Visible = false,

        ZIndex = 100,

    }, Gui)

Corner(
    OpenButton,
    23
)

Stroke(
    OpenButton,
    Color3.fromRGB(
        118,
        76,
        255
    ),
    2,
    .08
)

local OpenInner =
    New("Frame", {

        AnchorPoint =
            Vector2.new(
                .5,
                .5
            ),

        Position =
            UDim2.fromScale(
                .5,
                .5
            ),

        Size =
            UDim2.fromOffset(
                58,
                58
            ),

        BackgroundColor3 =
            Color3.fromRGB(
                25,
                14,
                49
            ),

        BorderSizePixel = 0,

        ZIndex = 101,

    }, OpenButton)

Corner(
    OpenInner,
    18
)

Stroke(
    OpenInner,
    PINK,
    1,
    .12
)

Gradient(
    OpenInner,
    Color3.fromRGB(
        53,
        27,
        96
    ),
    Color3.fromRGB(
        24,
        13,
        48
    ),
    45
)

New("TextLabel", {

    AnchorPoint =
        Vector2.new(
            .5,
            .5
        ),

    Position =
        UDim2.fromScale(
            .5,
            .47
        ),

    Size =
        UDim2.fromOffset(
            44,
            42
        ),

    BackgroundTransparency = 1,

    Text = "N",

    Font =
        Enum.Font.GothamBlack,

    TextSize = 34,

    TextColor3 =
        Color3.fromRGB(
            255,
            255,
            255
        ),

    TextStrokeColor3 =
        PINK,

    TextStrokeTransparency =
        .25,

    ZIndex = 102,

}, OpenButton)

--==================================================
-- MENU OPEN / CLOSE
--==================================================

local MenuOpen = true

local function OpenMenu()

    if MenuOpen then
        return
    end

    MenuOpen =
        true

    OpenButton.Visible =
        false

    Window.Visible =
        true

    -- IMPORTANT:
    -- Only transparency is animated.
    -- Window Size does not change.
    -- UIScale does not change.
    -- ScrollingFrames do not stretch.

    Window.BackgroundTransparency =
        .55

    Tween(
        Window,
        .22,
        {
            BackgroundTransparency =
                0
        }
    )

end

local function CloseMenu()

    if not MenuOpen then
        return
    end

    MenuOpen =
        false

    Tween(
        Window,
        .18,
        {
            BackgroundTransparency =
                .55
        }
    )

    task.delay(
        .19,
        function()

            if MenuOpen then
                return
            end

            Window.Visible =
                false

            Window.BackgroundTransparency =
                0

            OpenButton.Visible =
                true

        end
    )

end

CloseButton.Activated:Connect(
    CloseMenu
)

OpenButton.Activated:Connect(
    OpenMenu
)

--==================================================
-- OPEN BUTTON DRAG
--==================================================

local DraggingOpenButton =
    false

local OpenDragStart =
    nil

local OpenButtonStart =
    nil

local OpenMoved =
    false

OpenButton.InputBegan:Connect(
    function(input)

        if input.UserInputType ==
            Enum.UserInputType.Touch
            or input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            DraggingOpenButton =
                true

            OpenMoved =
                false

            OpenDragStart =
                input.Position

            OpenButtonStart =
                OpenButton.Position

        end

    end
)

UIS.InputChanged:Connect(
    function(input)

        if not DraggingOpenButton then
            return
        end

        if input.UserInputType ~=
            Enum.UserInputType.Touch
            and input.UserInputType ~=
            Enum.UserInputType.MouseMovement then

            return
        end

        local Delta =
            input.Position
            - OpenDragStart

        if Delta.Magnitude > 8 then
            OpenMoved =
                true
        end

        if not OpenMoved then
            return
        end

        local CurrentCamera =
            workspace.CurrentCamera

        if not CurrentCamera then
            return
        end

        local View =
            CurrentCamera.ViewportSize

        local X =
            OpenButtonStart.X.Offset
            + Delta.X

        local Y =
            OpenButtonStart.Y.Offset
            + Delta.Y

        local Half =
            OpenButton.AbsoluteSize.X
            / 2

        X =
            math.clamp(
                X,
                Half + 8,
                View.X - Half - 8
            )

        Y =
            math.clamp(
                Y,
                Half + 8,
                View.Y - Half - 8
            )

        OpenButton.Position =
            UDim2.fromOffset(
                X,
                Y
            )

    end
)

UIS.InputEnded:Connect(
    function(input)

        if not DraggingOpenButton then
            return
        end

        if input.UserInputType ==
            Enum.UserInputType.Touch
            or input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            local WasClick =
                not OpenMoved

            DraggingOpenButton =
                false

            if WasClick then
                OpenMenu()
            end

        end

    end
)

--==================================================
-- WINDOW DRAG
--==================================================

local DraggingWindow =
    false

local WindowDragStart =
    nil

local WindowStart =
    nil

Header.InputBegan:Connect(
    function(input)

        if input.UserInputType ==
            Enum.UserInputType.Touch
            or input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            DraggingWindow =
                true

            WindowDragStart =
                input.Position

            WindowStart =
                Window.Position

        end

    end
)

UIS.InputChanged:Connect(
    function(input)

        if not DraggingWindow then
            return
        end

        if input.UserInputType ~=
            Enum.UserInputType.Touch
            and input.UserInputType ~=
            Enum.UserInputType.MouseMovement then

            return
        end

        local Delta =
            input.Position
            - WindowDragStart

        Window.Position =
            UDim2.new(
                WindowStart.X.Scale,
                WindowStart.X.Offset
                    + Delta.X,

                WindowStart.Y.Scale,
                WindowStart.Y.Offset
                    + Delta.Y
            )

    end
)

UIS.InputEnded:Connect(
    function(input)

        if input.UserInputType ==
            Enum.UserInputType.Touch
            or input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            DraggingWindow =
                false

        end

    end
)

--==================================================
-- RIGHT SHIFT
--==================================================

UIS.InputBegan:Connect(
    function(input, processed)

        if processed then
            return
        end

        if input.KeyCode ==
            Enum.KeyCode.RightShift then

            if MenuOpen then
                CloseMenu()
            else
                OpenMenu()
            end

        end

    end
)

--==================================================
-- RESPONSIVE SCALE
--==================================================

local function Resize()

    CurrentCamera =
        workspace.CurrentCamera

    if not CurrentCamera then
        return
    end

    local View =
        CurrentCamera.ViewportSize

    local ScaleX =
        (View.X - 20)
        / BASE_WIDTH

    local ScaleY =
        (View.Y - 20)
        / BASE_HEIGHT

    -- This is responsive scaling only.
    -- It is NEVER animated during open/close.

    GuiScale.Scale =
        math.clamp(
            math.min(
                ScaleX,
                ScaleY
            ),
            .55,
            1.15
        )

end

if workspace.CurrentCamera then

    workspace.CurrentCamera:
        GetPropertyChangedSignal(
            "ViewportSize"
        ):
        Connect(
            Resize
        )

end

workspace:GetPropertyChangedSignal(
    "CurrentCamera"
):Connect(
    function()

        CurrentCamera =
            workspace.CurrentCamera

        if CurrentCamera then

            CurrentCamera:
                GetPropertyChangedSignal(
                    "ViewportSize"
                ):
                Connect(
                    Resize
                )

            Resize()

        end

    end
)

--==================================================
-- INITIALIZE
--==================================================

UpdateFlyUI()
UpdateJumpUI()

Resize()

Window.Position =
    UDim2.fromScale(
        .5,
        .5
    )

Window.Rotation =
    0

Window.BackgroundTransparency =
    0

Window.Visible =
    true

OpenButton.Visible =
    false

-- Apply saved config if available.
pcall(function()

    if LoadConfig() then

        UpdateFlyUI()
        UpdateJumpUI()

    end

end)

-- Force correct initial state.
FlyWanted =
    Config.Fly

if Config.Fly then

    task.defer(function()
        StartFly()
    end)

end

if Config.BigJump then

    task.defer(function()
        EnableBigJump()
    end)

end

print(
    "[NEXUS] Tower of Hell v7 loaded successfully."
)
