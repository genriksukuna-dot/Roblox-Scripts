print("[STEAL EGG PRO] Loading Script...")

local success, err = pcall(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local StatsService = game:GetService("Stats")
    
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then
        local t = tick()
        repeat task.wait(0.1) LocalPlayer = Players.LocalPlayer until LocalPlayer or (tick() - t > 3)
    end
    
    if not LocalPlayer then return end

    local function getSafeGui()
        local ok, cg = pcall(function() return game:GetService("CoreGui") end)
        if ok and cg then return cg end
        local pgui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pgui then return pgui end
        return LocalPlayer:WaitForChild("PlayerGui", 3)
    end

    local GuiParent = getSafeGui()
    if not GuiParent then return end

    pcall(function()
        if GuiParent:FindFirstChild("StealAnEggProGUI") then
            GuiParent.StealAnEggProGUI:Destroy()
        end
    end)

    local Colors = {
        Bg = Color3.fromRGB(12, 14, 20),
        HeaderBg = Color3.fromRGB(17, 20, 30),
        CardBg = Color3.fromRGB(20, 24, 38),
        Border = Color3.fromRGB(45, 52, 80),
        Accent = Color3.fromRGB(0, 220, 255),
        AccentSec = Color3.fromRGB(0, 255, 150),
        White = Color3.fromRGB(255, 255, 255),
        Muted = Color3.fromRGB(140, 150, 180),
        TabActive = Color3.fromRGB(0, 180, 220)
    }

    local function addCorner(parent, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 10)
        c.Parent = parent
    end

    local function addStroke(parent, color, thickness)
        local s = Instance.new("UIStroke")
        s.Color = color or Colors.Border
        s.Thickness = thickness or 1.2
        s.Parent = parent
    end

    local function tween(inst, time, props, style, dir)
        if not inst then return end
        local tw = TweenService:Create(
            inst,
            TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Back, dir or Enum.EasingDirection.Out),
            props
        )
        tw:Play()
        return tw
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StealAnEggProGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 99999
    ScreenGui.Parent = GuiParent

    local MiniPill = Instance.new("Frame", ScreenGui)
    MiniPill.Name = "MiniPill"
    MiniPill.Size = UDim2.fromOffset(115, 32)
    MiniPill.Position = UDim2.new(0.5, -57, 0, 15)
    MiniPill.BackgroundColor3 = Colors.HeaderBg
    MiniPill.BorderSizePixel = 0
    MiniPill.Visible = false
    MiniPill.ZIndex = 100
    addCorner(MiniPill, 16)
    addStroke(MiniPill, Colors.Accent, 1.3)

    local PillDot = Instance.new("Frame", MiniPill)
    PillDot.Size = UDim2.fromOffset(7, 7)
    PillDot.Position = UDim2.fromOffset(10, 12)
    PillDot.BackgroundColor3 = Colors.AccentSec
    PillDot.BorderSizePixel = 0
    PillDot.ZIndex = 101
    addCorner(PillDot, 99)

    local PillLabel = Instance.new("TextLabel", MiniPill)
    PillLabel.Size = UDim2.new(1, -24, 1, 0)
    PillLabel.Position = UDim2.fromOffset(22, 0)
    PillLabel.BackgroundTransparency = 1
    PillLabel.Font = Enum.Font.GothamBlack
    PillLabel.Text = "OPEN HUB"
    PillLabel.TextSize = 9
    PillLabel.TextColor3 = Colors.White
    PillLabel.TextXAlignment = Enum.TextXAlignment.Left
    PillLabel.ZIndex = 101

    local PillBtn = Instance.new("TextButton", MiniPill)
    PillBtn.Size = UDim2.fromScale(1, 1)
    PillBtn.BackgroundTransparency = 1
    PillBtn.Text = ""
    PillBtn.ZIndex = 105

    local MainFrame = Instance.new("Frame", ScreenGui)
    MainFrame.Name = "MainFrame"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.Size = UDim2.fromOffset(450, 350)
    MainFrame.BackgroundColor3 = Colors.Bg
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.ClipsDescendants = true
    addCorner(MainFrame, 16)
    addStroke(MainFrame, Colors.Accent, 1.5)

    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 44)
    Header.BackgroundColor3 = Colors.HeaderBg
    Header.BorderSizePixel = 0

    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.fromOffset(14, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBlack
    Title.Text = "STEAL AN EGG | PRO HUB"
    Title.TextSize = 11.5
    Title.TextColor3 = Colors.White
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.fromOffset(28, 28)
    CloseBtn.Position = UDim2.new(1, -36, 0.5, -14)
    CloseBtn.BackgroundColor3 = Colors.CardBg
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "-"
    CloseBtn.TextSize = 14
    CloseBtn.TextColor3 = Colors.Muted
    addCorner(CloseBtn, 8)
    addStroke(CloseBtn, Colors.Border, 1)

    local function toggleMenu(show)
        if show then
            MiniPill.Visible = false
            MainFrame.Visible = true
            MainFrame.Size = UDim2.fromOffset(100, 80)
            MainFrame.Position = UDim2.fromScale(0.5, 0.52)
            tween(MainFrame, 0.3, {Size = UDim2.fromOffset(450, 350), Position = UDim2.fromScale(0.5, 0.5)}, Enum.EasingStyle.Back)
        else
            tween(MainFrame, 0.2, {Size = UDim2.fromOffset(100, 80), Position = UDim2.fromScale(0.5, 0.52)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            task.delay(0.18, function()
                MainFrame.Visible = false
                MiniPill.Visible = true
            end)
        end
    end

    CloseBtn.MouseButton1Click:Connect(function() toggleMenu(false) end)
    PillBtn.MouseButton1Click:Connect(function() toggleMenu(true) end)

    local TabBar = Instance.new("Frame", MainFrame)
    TabBar.Size = UDim2.new(1, -20, 0, 32)
    TabBar.Position = UDim2.fromOffset(10, 50)
    TabBar.BackgroundTransparency = 1

    local TabListLayout = Instance.new("UIListLayout", TabBar)
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.Padding = UDim.new(0, 8)

    local PagesContainer = Instance.new("Frame", MainFrame)
    PagesContainer.Size = UDim2.new(1, -20, 1, -156)
    PagesContainer.Position = UDim2.fromOffset(10, 92)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.ClipsDescendants = true

    local pages = {}
    local function createPage(name)
        local page = Instance.new("ScrollingFrame", PagesContainer)
        page.Name = name .. "Page"
        page.Size = UDim2.fromScale(1, 1)
        page.BackgroundTransparency = 1
        page.CanvasSize = UDim2.fromOffset(0, 700)
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = Colors.Accent
        page.Visible = false

        local layout = Instance.new("UIListLayout", page)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 10)

        pages[name] = page
        return page
    end

    local mainPage = createPage("Main")
    local espPage = createPage("ESP")
    local farmPage = createPage("Farm")
    mainPage.Visible = true

    local function switchTab(tabName)
        for name, page in pairs(pages) do
            page.Visible = (name == tabName)
        end
    end

    local function createTabButton(name, targetPage)
        local btn = Instance.new("TextButton", TabBar)
        btn.Size = UDim2.new(0.32, -4, 1, 0)
        btn.BackgroundColor3 = Colors.CardBg
        btn.Font = Enum.Font.GothamBold
        btn.Text = name
        btn.TextSize = 10.5
        btn.TextColor3 = Colors.Muted
        addCorner(btn, 8)
        addStroke(btn, Colors.Border, 1)

        btn.MouseButton1Click:Connect(function()
            for _, child in ipairs(TabBar:GetChildren()) do
                if child:IsA("TextButton") then
                    tween(child, 0.15, {BackgroundColor3 = Colors.CardBg}, Enum.EasingStyle.Quart)
                    child.TextColor3 = Colors.Muted
                end
            end
            tween(btn, 0.15, {BackgroundColor3 = Colors.TabActive}, Enum.EasingStyle.Quart)
            btn.TextColor3 = Colors.White
            switchTab(targetPage)
        end)
        return btn
    end

    local btnMain = createTabButton("MAIN", "Main")
    btnMain.BackgroundColor3 = Colors.TabActive
    btnMain.TextColor3 = Colors.White
    createTabButton("ESP", "ESP")
    createTabButton("FARM", "Farm")

    local function createToggle(parent, name, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, -6, 0, 42)
        btn.BackgroundColor3 = Colors.CardBg
        btn.Font = Enum.Font.GothamBold
        btn.Text = name .. ": OFF"
        btn.TextSize = 11
        btn.TextColor3 = Colors.White
        addCorner(btn, 10)
        addStroke(btn, Colors.Border, 1.2)

        local active = false
        btn.MouseButton1Click:Connect(function()
            active = not active
            if active then
                tween(btn, 0.15, {BackgroundColor3 = Colors.AccentSec})
                btn.TextColor3 = Color3.fromRGB(10, 15, 20)
                btn.Text = name .. ": ON"
            else
                tween(btn, 0.15, {BackgroundColor3 = Colors.CardBg})
                btn.TextColor3 = Colors.White
                btn.Text = name .. ": OFF"
            end
            pcall(callback, active)
        end)
        return btn
    end

    local function createSlider(parent, name, min, max, default, callback)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, -6, 0, 56)
        frame.BackgroundColor3 = Colors.CardBg
        addCorner(frame, 10)
        addStroke(frame, Colors.Border, 1.2)

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, -16, 0, 22)
        label.Position = UDim2.fromOffset(10, 6)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.Text = name .. ": " .. tostring(default)
        label.TextSize = 11
        label.TextColor3 = Colors.White
        label.TextXAlignment = Enum.TextXAlignment.Left

        local bar = Instance.new("Frame", frame)
        bar.Size = UDim2.new(1, -20, 0, 8)
        bar.Position = UDim2.new(0, 10, 0, 36)
        bar.BackgroundColor3 = Colors.Bg
        addCorner(bar, 4)

        local fill = Instance.new("Frame", bar)
        local startPos = (default - min) / (max - min)
        fill.Size = UDim2.new(startPos, 0, 1, 0)
        fill.BackgroundColor3 = Colors.Accent
        addCorner(fill, 4)

        local btn = Instance.new("TextButton", bar)
        btn.Size = UDim2.new(1, 24, 1, 16)
        btn.Position = UDim2.fromOffset(-12, -4)
        btn.BackgroundTransparency = 1
        btn.Text = ""

        local sliding = false
        local function update(input)
            local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pos)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            label.Text = name .. ": " .. tostring(val)
            pcall(callback, val)
        end

        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = true end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then sliding = false end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)
    end

    local Config = {
        SpeedEnabled = false,
        SpeedValue = 110,
        EspEnabled = false,
        EspDistance = 500,
        AllowedEggTypes = {},
        AutoSteal = false
    }

    createToggle(mainPage, "PHYSICS SPEED (ANTI-RUBBERBAND)", function(state)
        Config.SpeedEnabled = state
    end)

    createSlider(mainPage, "WALK SPEED MAX", 16, 110, 110, function(val)
        Config.SpeedValue = val
    end)

    local currentBodyVel = nil

    RunService.Heartbeat:Connect(function()
        if Config.SpeedEnabled then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                    local hum = char.Humanoid
                    local root = char.HumanoidRootPart
                    hum.WalkSpeed = 16 
                    
                    if hum.MoveDirection.Magnitude > 0 then
                        if not currentBodyVel or not currentBodyVel.Parent then
                            if currentBodyVel then currentBodyVel:Destroy() end
                            currentBodyVel = Instance.new("BodyVelocity")
                            currentBodyVel.MaxForce = Vector3.new(100000, 0, 100000)
                            currentBodyVel.Parent = root
                        end
                        currentBodyVel.Velocity = hum.MoveDirection * Config.SpeedValue
                    else
                        if currentBodyVel then
                            currentBodyVel:Destroy()
                            currentBodyVel = nil
                        end
                    end
                end
            end)
        else
            if currentBodyVel then
                currentBodyVel:Destroy()
                currentBodyVel = nil
            end
        end
    end)

    createToggle(espPage, "EGG ESP (WH)", function(state)
        Config.EspEnabled = state
    end)

    createSlider(espPage, "ESP DISTANCE (STUD)", 50, 2000, 500, function(val)
        Config.EspDistance = val
    end)

    local EggTypesListLabel = Instance.new("TextLabel", espPage)
    EggTypesListLabel.Size = UDim2.new(1, -6, 0, 24)
    EggTypesListLabel.BackgroundTransparency = 1
    EggTypesListLabel.Font = Enum.Font.GothamBold
    EggTypesListLabel.Text = "FOUND EGG TYPES (CLICK TO TOGGLE):"
    EggTypesListLabel.TextSize = 10
    EggTypesListLabel.TextColor3 = Colors.Accent
    EggTypesListLabel.TextXAlignment = Enum.TextXAlignment.Left

    local createdEggButtons = {}

    local function isRealEgg(obj)
        local name = obj.Name:lower()
        if name:find("fuse") or name:find("machine") or name:find("cube") or name:find("mesh") or name:find("ui") or name:find("cylinder") then return false end
        if name:find("eggspot") or name:find("eggpoint") or name:find("egg") then return true end
        return false
    end

    local function registerEggType(eggName)
        if createdEggButtons[eggName] then return end
        createdEggButtons[eggName] = true
        if Config.AllowedEggTypes[eggName] == nil then
            Config.AllowedEggTypes[eggName] = true
        end

        local btn = Instance.new("TextButton", espPage)
        btn.Size = UDim2.new(1, -6, 0, 34)
        btn.BackgroundColor3 = Colors.AccentSec
        btn.Font = Enum.Font.GothamBold
        btn.Text = "EGG: " .. eggName .. " [ON]"
        btn.TextSize = 10
        btn.TextColor3 = Color3.fromRGB(10, 15, 20)
        addCorner(btn, 8)
        addStroke(btn, Colors.Border, 1)

        local active = true
        btn.MouseButton1Click:Connect(function()
            active = not active
            Config.AllowedEggTypes[eggName] = active
            if active then
                tween(btn, 0.15, {BackgroundColor3 = Colors.AccentSec})
                btn.TextColor3 = Color3.fromRGB(10, 15, 20)
                btn.Text = "EGG: " .. eggName .. " [ON]"
            else
                tween(btn, 0.15, {BackgroundColor3 = Colors.CardBg})
                btn.TextColor3 = Colors.White
                btn.Text = "EGG: " .. eggName .. " [OFF]"
            end
        end)
    end

    task.spawn(function()
        while task.wait(2) do
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if isRealEgg(obj) and (obj:IsA("BasePart") or obj:IsA("Model")) then
                        registerEggType(obj.Name)
                    end
                end
            end)
        end
    end)

    task.spawn(function()
        while task.wait(0.5) do
            pcall(function()
                local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if isRealEgg(obj) and (obj:IsA("BasePart") or obj:IsA("Model")) then
                        local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                        
                        if targetPart then
                            local isAllowed = Config.AllowedEggTypes[obj.Name] ~= false
                            local dist = rootPart and (rootPart.Position - targetPart.Position).Magnitude or 0

                            if Config.EspEnabled and isAllowed and dist <= Config.EspDistance then
                                if not targetPart:FindFirstChild("EggHighlight") then
                                    local hl = Instance.new("Highlight")
                                    hl.Name = "EggHighlight"
                                    hl.FillColor = Color3.fromRGB(255, 215, 0)
                                    hl.OutlineColor = Colors.White
                                    hl.FillTransparency = 0.5
                                    hl.Parent = targetPart
                                end
                                if not targetPart:FindFirstChild("EggTextGui") then
                                    local bg = Instance.new("BillboardGui", targetPart)
                                    bg.Name = "EggTextGui"
                                    bg.Size = UDim2.new(0, 150, 0, 40)
                                    bg.StudsOffset = Vector3.new(0, 2.5, 0)
                                    bg.AlwaysOnTop = true
                                    local txt = Instance.new("TextLabel", bg)
                                    txt.Name = "Title"
                                    txt.Size = UDim2.new(1,0,1,0)
                                    txt.BackgroundTransparency = 1
                                    txt.TextColor3 = Color3.fromRGB(255, 215, 0)
                                    txt.Font = Enum.Font.GothamBold
                                    txt.TextSize = 12
                                    txt.TextStrokeTransparency = 0
                                end
                                local lbl = targetPart:FindFirstChild("EggTextGui") and targetPart.EggTextGui:FindFirstChild("Title")
                                if lbl then
                                    lbl.Text = string.format("%s\n[%dm]", obj.Name, math.floor(dist))
                                end
                            else
                                if targetPart:FindFirstChild("EggHighlight") then targetPart.EggHighlight:Destroy() end
                                if targetPart:FindFirstChild("EggTextGui") then targetPart.EggTextGui:Destroy() end
                            end
                        end
                    end
                end
            end)
        end
    end)

    createToggle(farmPage, "AUTO STEAL EGGS", function(state)
        Config.AutoSteal = state
    end)

    task.spawn(function()
        while task.wait(0.2) do
            if Config.AutoSteal then
                pcall(function()
                    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        for _, obj in ipairs(workspace:GetDescendants()) do
                            if isRealEgg(obj) then
                                local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                                if targetPart and (root.Position - targetPart.Position).Magnitude < 45 then
                                    for _, prompt in ipairs(obj:GetDescendants()) do
                                        if prompt:IsA("ProximityPrompt") then
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                    if typeof(firetouchinterest) == "function" then
                                        firetouchinterest(root, targetPart, 0)
                                        task.wait(0.01)
                                        firetouchinterest(root, targetPart, 1)
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end
    end)

    local BottomBar = Instance.new("Frame", MainFrame)
    BottomBar.Size = UDim2.new(1, -20, 0, 54)
    BottomBar.Position = UDim2.new(0, 10, 1, -60)
    BottomBar.BackgroundColor3 = Colors.HeaderBg
    addCorner(BottomBar, 12)
    addStroke(BottomBar, Colors.Border, 1.2)

    local AvatarHolder = Instance.new("Frame", BottomBar)
    AvatarHolder.Size = UDim2.fromOffset(40, 40)
    AvatarHolder.Position = UDim2.fromOffset(7, 7)
    AvatarHolder.BackgroundColor3 = Colors.CardBg
    addCorner(AvatarHolder, 10)
    addStroke(AvatarHolder, Colors.Accent, 1.2)

    local AvatarImg = Instance.new("ImageLabel", AvatarHolder)
    AvatarImg.Size = UDim2.fromScale(1, 1)
    AvatarImg.BackgroundTransparency = 1
    AvatarImg.ScaleType = Enum.ScaleType.Fit
    addCorner(AvatarImg, 10)
    pcall(function()
        AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
    end)

    local StatsHolder = Instance.new("Frame", BottomBar)
    StatsHolder.Size = UDim2.new(1, -175, 1, -6)
    StatsHolder.Position = UDim2.fromOffset(54, 4)
    StatsHolder.BackgroundTransparency = 1

    local NameLbl = Instance.new("TextLabel", StatsHolder)
    NameLbl.Size = UDim2.new(1, 0, 0, 18)
    NameLbl.BackgroundTransparency = 1
    NameLbl.Font = Enum.Font.GothamBlack
    NameLbl.Text = LocalPlayer.DisplayName or "Unknown"
    NameLbl.TextSize = 11
    NameLbl.TextColor3 = Colors.White
    NameLbl.TextXAlignment = Enum.TextXAlignment.Left

    local SubLbl = Instance.new("TextLabel", StatsHolder)
    SubLbl.Size = UDim2.new(1, 0, 0, 16)
    SubLbl.Position = UDim2.fromOffset(0, 18)
    SubLbl.BackgroundTransparency = 1
    SubLbl.Font = Enum.Font.GothamBold
    SubLbl.Text = "@" .. (LocalPlayer.Name or "Player") .. " | Age: " .. tostring(LocalPlayer.AccountAge or 0) .. "d"
    SubLbl.TextSize = 8
    SubLbl.TextColor3 = Colors.Muted
    SubLbl.TextXAlignment = Enum.TextXAlignment.Left

    local LiveMetrics = Instance.new("Frame", BottomBar)
    LiveMetrics.Size = UDim2.fromOffset(110, 40)
    LiveMetrics.Position = UDim2.new(1, -118, 0.5, -20)
    LiveMetrics.BackgroundTransparency = 1

    local FpsBadge = Instance.new("TextLabel", LiveMetrics)
    FpsBadge.Size = UDim2.new(1, 0, 0, 18)
    FpsBadge.BackgroundColor3 = Colors.CardBg
    FpsBadge.Font = Enum.Font.GothamBlack
    FpsBadge.Text = "FPS: 60"
    FpsBadge.TextSize = 8
    FpsBadge.TextColor3 = Colors.AccentSec
    addCorner(FpsBadge, 5)
    addStroke(FpsBadge, Colors.Border, 1)

    local PingBadge = Instance.new("TextLabel", LiveMetrics)
    PingBadge.Size = UDim2.new(1, 0, 0, 18)
    PingBadge.Position = UDim2.new(0, 0, 1, -18)
    PingBadge.BackgroundColor3 = Colors.CardBg
    PingBadge.Font = Enum.Font.GothamBlack
    PingBadge.Text = "PING: 35ms"
    PingBadge.TextSize = 8
    PingBadge.TextColor3 = Colors.Accent
    addCorner(PingBadge, 5)
    addStroke(PingBadge, Colors.Border, 1)

    local fc = 0
    local lastTick = os.clock()
    RunService.RenderStepped:Connect(function()
        fc = fc + 1
        local now = os.clock()
        local dt = now - lastTick
        if dt >= 0.5 then
            FpsBadge.Text = "FPS: " .. tostring(math.floor((fc / dt) + 0.5))
            local pingVal = 30
            pcall(function()
                local item = StatsService.Network.ServerStatsItem["Data Ping"]
                if item then pingVal = math.floor(item:GetValue()) end
            end)
            PingBadge.Text = "PING: " .. tostring(pingVal) .. "ms"
            fc = 0
            lastTick = now
        end
    end)

    print("[STEAL EGG PRO] Interface Loaded")
end)

if not success then
    warn("[STEAL EGG PRO ERROR]: " .. tostring(err))
end
