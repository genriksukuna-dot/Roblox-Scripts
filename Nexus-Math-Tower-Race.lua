--// ============================================================
--// NEXUS MATH TOWER RACE V3
--// Compact 3D UI / Mobile + PC / Smart Solver
--//
--// UI changes in V3:
--//  • Fully clipped content so controls never escape the menu.
--//  • Responsive UIScale for phones, tablets and PC.
--//  • Real ViewportFrame 3D animated background.
--//  • Compact square navigation and controls.
--//  • New circular NEXUS launcher.
--//  • No giant empty panels / no oversized launcher.
--//
--// Solver core remains clean-room and self-contained.
--// ============================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

--// ============================================================
--// CONFIG
--// ============================================================

local Config = {
    AutoSolve = false,
    Randomizer = true,
    AntiAFK = true,
    ScanInterval = 0.05,
    MinDelay = 0.06,
    MaxDelay = 0.18,
    Debug = false,
}

--// ============================================================
--// GUI PARENT
--// ============================================================

local function getUIParent()
    local ok, hui = pcall(function()
        if typeof(gethui) == "function" then
            return gethui()
        end
        return nil
    end)

    if ok and hui then
        return hui
    end

    return game:GetService("CoreGui")
end

local UIParent = getUIParent()

pcall(function()
    local old = UIParent:FindFirstChild("NEXUS_MATH_TOWER_RACE")
    if old then
        old:Destroy()
    end
end)

--// ============================================================
--// SAFE HELPERS
--// ============================================================

local function safe(fn, ...)
    local ok, a, b, c = pcall(fn, ...)
    if ok then
        return a, b, c
    end
end

local function clamp(value, minValue, maxValue)
    return math.max(minValue, math.min(maxValue, value))
end

local function trim(value)
    return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function normalizeMathText(text)
    text = tostring(text or "")
    text = text
        :gsub("×", "*")
        :gsub("✕", "*")
        :gsub("x", "*")
        :gsub("X", "*")
        :gsub("÷", "/")
        :gsub("∕", "/")
        :gsub("−", "-")
        :gsub("–", "-")
        :gsub("—", "-")
        :gsub("＋", "+")
    return text
end

--// ============================================================
--// MATH PARSER
--// ============================================================

local function tokenize(expression)
    expression = normalizeMathText(expression)

    local tokens = {}
    local i = 1
    local length = #expression

    while i <= length do
        local char = expression:sub(i, i)

        if char:match("%s") then
            i += 1

        elseif char:match("[%d%.]") then
            local start = i
            local dotCount = 0

            while i <= length do
                local current = expression:sub(i, i)

                if current == "." then
                    dotCount += 1
                    if dotCount > 1 then
                        break
                    end
                elseif not current:match("%d") then
                    break
                end

                i += 1
            end

            local number = tonumber(expression:sub(start, i - 1))
            if number == nil then
                return nil
            end

            tokens[#tokens + 1] = {
                kind = "number",
                value = number,
            }

        elseif char == "+" or char == "-" or char == "*" or char == "/"
            or char == "%" or char == "^" or char == "(" or char == ")" then

            tokens[#tokens + 1] = {
                kind = "operator",
                value = char,
            }

            i += 1
        else
            return nil
        end
    end

    return tokens
end

local function evaluateExpression(expression)
    local tokens = tokenize(expression)
    if not tokens or #tokens == 0 then
        return nil
    end

    local index = 1

    local parseExpression
    local parseTerm
    local parsePower
    local parseUnary
    local parsePrimary

    local function current()
        return tokens[index]
    end

    local function consume(value)
        local token = current()
        if token and token.value == value then
            index += 1
            return true
        end
        return false
    end

    parsePrimary = function()
        local token = current()
        if not token then
            return nil
        end

        if token.kind == "number" then
            index += 1
            return token.value
        end

        if consume("(") then
            local result = parseExpression()
            if not consume(")") then
                return nil
            end
            return result
        end

        return nil
    end

    parseUnary = function()
        if consume("+") then
            return parseUnary()
        end

        if consume("-") then
            local result = parseUnary()
            if result == nil then
                return nil
            end
            return -result
        end

        return parsePrimary()
    end

    parsePower = function()
        local left = parseUnary()
        if left == nil then
            return nil
        end

        if consume("^") then
            local right = parsePower()
            if right == nil then
                return nil
            end
            left = left ^ right
        end

        return left
    end

    parseTerm = function()
        local left = parsePower()
        if left == nil then
            return nil
        end

        while true do
            local token = current()
            if not token then
                break
            end

            if token.value == "*" then
                index += 1
                local right = parsePower()
                if right == nil then
                    return nil
                end
                left *= right

            elseif token.value == "/" then
                index += 1
                local right = parsePower()
                if right == nil or right == 0 then
                    return nil
                end
                left /= right

            elseif token.value == "%" then
                index += 1
                local right = parsePower()
                if right == nil or right == 0 then
                    return nil
                end
                left %= right
            else
                break
            end
        end

        return left
    end

    parseExpression = function()
        local left = parseTerm()
        if left == nil then
            return nil
        end

        while true do
            local token = current()
            if not token then
                break
            end

            if token.value == "+" then
                index += 1
                local right = parseTerm()
                if right == nil then
                    return nil
                end
                left += right

            elseif token.value == "-" then
                index += 1
                local right = parseTerm()
                if right == nil then
                    return nil
                end
                left -= right
            else
                break
            end
        end

        return left
    end

    local result = parseExpression()

    if result == nil or index <= #tokens then
        return nil
    end

    if result ~= result or result == math.huge or result == -math.huge then
        return nil
    end

    return math.round(result * 1000000) / 1000000
end

--// ============================================================
--// QUESTION EXTRACTION
--// ============================================================

local function parseQuestion(text)
    text = normalizeMathText(text)
    local candidates = {}

    for candidate in text:gmatch("[%d%.%+%-%*/%^%%%(%)]%s*[%d%.%+%-%*/%^%%%(%)]*") do
        local compact = candidate:gsub("%s+", "")
        if compact:find("%d") and compact:find("[%+%-%*/%^%%]") then
            local answer = evaluateExpression(compact)
            if answer ~= nil then
                candidates[#candidates + 1] = {
                    expression = compact,
                    answer = answer,
                    score = #compact,
                }
            end
        end
    end

    local stripped = text:gsub("[^%d%.%+%-%*/%^%%%(%)]", "")
    if stripped:find("%d") and stripped:find("[%+%-%*/%^%%]") then
        local answer = evaluateExpression(stripped)
        if answer ~= nil then
            candidates[#candidates + 1] = {
                expression = stripped,
                answer = answer,
                score = #stripped + 1000,
            }
        end
    end

    table.sort(candidates, function(a, b)
        return a.score > b.score
    end)

    return candidates[1]
end

local function sameNumber(a, b)
    return a ~= nil and b ~= nil and math.abs(a - b) < 0.00001
end

--// ============================================================
--// GUI OBJECT HELPERS
--// ============================================================

local function isActuallyVisible(object)
    if not object:IsA("GuiObject") or not object.Visible then
        return false
    end

    local current = object.Parent
    while current do
        if current:IsA("GuiObject") and not current.Visible then
            return false
        end
        current = current.Parent
    end

    return true
end

local function getText(object)
    if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
        return trim(object.Text)
    end
    return ""
end

local function getGuiRoot()
    return LocalPlayer:FindFirstChildOfClass("PlayerGui")
end

local function getButtonValue(buttonObject)
    local text = normalizeMathText(getText(buttonObject))
    if text == "" or #text > 40 then
        return nil
    end

    local direct = tonumber(text)
    if direct ~= nil then
        return direct
    end

    text = text:gsub("^=%s*", "")
    if text:find("[%+%-%*/%^%%]") then
        return evaluateExpression(text)
    end

    return nil
end

local function collectCandidateButtons(root)
    local result = {}
    if not root then
        return result
    end

    for _, object in ipairs(root:GetDescendants()) do
        if object:IsA("TextButton") and isActuallyVisible(object) then
            local value = getButtonValue(object)
            if value ~= nil then
                result[#result + 1] = {
                    button = object,
                    value = value,
                    position = object.AbsolutePosition,
                }
            end
        end
    end

    return result
end

local function findQuestionLabels(root)
    local result = {}
    if not root then
        return result
    end

    for _, object in ipairs(root:GetDescendants()) do
        if (object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox"))
            and isActuallyVisible(object) then

            local text = getText(object)
            if #text >= 3 and #text <= 160 then
                local parsed = parseQuestion(text)
                if parsed then
                    result[#result + 1] = {
                        object = object,
                        expression = parsed.expression,
                        answer = parsed.answer,
                        size = #parsed.expression,
                    }
                end
            end
        end
    end

    table.sort(result, function(a, b)
        return a.size > b.size
    end)

    return result
end

local function distance2D(a, b)
    return (a - b).Magnitude
end

local function collectNearbyButtons(questionObject)
    local allButtons = collectCandidateButtons(getGuiRoot())
    if #allButtons == 0 then
        return {}
    end

    local questionPosition = questionObject.AbsolutePosition
    local questionSize = questionObject.AbsoluteSize
    local questionCenter = questionPosition + questionSize / 2
    local nearby = {}

    for _, entry in ipairs(allButtons) do
        local buttonObject = entry.button
        local center = buttonObject.AbsolutePosition + buttonObject.AbsoluteSize / 2
        local distance = distance2D(questionCenter, center)

        if distance <= 650 then
            entry.distance = distance
            nearby[#nearby + 1] = entry
        end
    end

    table.sort(nearby, function(a, b)
        return a.distance < b.distance
    end)

    if #nearby >= 2 then
        return nearby
    end

    return allButtons
end

--// ============================================================
--// BUTTON ACTIVATION
--// ============================================================

local function activateButton(buttonObject)
    if not buttonObject or not buttonObject.Parent then
        return false
    end

    local clicked = false

    safe(function()
        buttonObject:Activate()
        clicked = true
    end)

    if typeof(firesignal) == "function" then
        safe(function()
            firesignal(buttonObject.Activated)
            clicked = true
        end)

        safe(function()
            firesignal(buttonObject.MouseButton1Click)
            clicked = true
        end)
    end

    if not clicked then
        local center = buttonObject.AbsolutePosition + buttonObject.AbsoluteSize / 2

        safe(function()
            VirtualInputManager:SendMouseButtonEvent(
                center.X,
                center.Y,
                0,
                true,
                game,
                0
            )

            VirtualInputManager:SendMouseButtonEvent(
                center.X,
                center.Y,
                0,
                false,
                game,
                0
            )

            clicked = true
        end)
    end

    return clicked
end

--// ============================================================
--// SOLVER STATE
--// ============================================================

local State = {
    Solved = 0,
    Scans = 0,
    LastSignature = "",
    LastClick = 0,
    LastStatus = "NEXUS READY",
}

local function randomDelay()
    local minDelay = clamp(tonumber(Config.MinDelay) or 0.06, 0, 5)
    local maxDelay = clamp(tonumber(Config.MaxDelay) or 0.18, minDelay, 5)

    if not Config.Randomizer then
        return minDelay
    end

    return minDelay + math.random() * (maxDelay - minDelay)
end

local function solveOnce()
    local gui = getGuiRoot()
    if not gui then
        return false, "PlayerGui not found"
    end

    State.Scans += 1

    local questions = findQuestionLabels(gui)
    if #questions == 0 then
        return false, "Waiting for question..."
    end

    for _, question in ipairs(questions) do
        local buttons = collectNearbyButtons(question.object)

        if #buttons >= 2 then
            local target

            if Config.Randomizer and #buttons > 2 then
                local shuffled = table.clone(buttons)
                for i = #shuffled, 2, -1 do
                    local j = math.random(1, i)
                    shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
                end
                buttons = shuffled
            end

            for _, entry in ipairs(buttons) do
                if sameNumber(entry.value, question.answer) then
                    target = entry.button
                    break
                end
            end

            if target then
                local signature = question.expression .. "=" .. tostring(question.answer)
                local now = os.clock()

                if signature == State.LastSignature and now - State.LastClick < 0.45 then
                    return false, "Cooldown"
                end

                task.wait(randomDelay())

                if not Config.AutoSolve then
                    return false, "Auto Solve is OFF"
                end

                if not target.Parent or not isActuallyVisible(target) then
                    return false, "Answer changed"
                end

                local activated = activateButton(target)

                if activated then
                    State.LastSignature = signature
                    State.LastClick = os.clock()
                    State.Solved += 1
                    return true, question.expression .. " = " .. tostring(question.answer)
                end
            end
        end
    end

    return false, "Answer option not found"
end

--// ============================================================
--// ANTI AFK
--// ============================================================

local AntiAFKConnection

local function setAntiAFK(enabled)
    Config.AntiAFK = enabled

    if AntiAFKConnection then
        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil
    end

    if not enabled then
        return
    end

    AntiAFKConnection = LocalPlayer.Idled:Connect(function()
        safe(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)
    end)
end

setAntiAFK(Config.AntiAFK)

--// ============================================================
--// UI ROOT
--// ============================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NEXUS_MATH_TOWER_RACE"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999
ScreenGui.Parent = UIParent

--// ============================================================
--// UI HELPERS
--// ============================================================

local function tween(object, duration, properties, style, direction)
    local info = TweenInfo.new(
        duration or 0.18,
        style or Enum.EasingStyle.Quint,
        direction or Enum.EasingDirection.Out
    )

    local tw = TweenService:Create(object, info, properties)
    tw:Play()
    return tw
end

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 10)
    corner.Parent = parent
    return corner
end

local function addStroke(parent, color, transparency, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Transparency = transparency or 0
    stroke.Thickness = thickness or 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
    return stroke
end

local function addGradient(parent, colorA, colorB, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colorA),
        ColorSequenceKeypoint.new(1, colorB),
    })
    gradient.Rotation = rotation or 0
    gradient.Parent = parent
    return gradient
end

local function makeLabel(parent, text, position, size, font, color, textSize)
    local object = Instance.new("TextLabel")
    object.BackgroundTransparency = 1
    object.Position = position
    object.Size = size
    object.Font = font or Enum.Font.Gotham
    object.Text = text
    object.TextColor3 = color or Color3.fromRGB(230, 233, 240)
    object.TextSize = textSize or 10
    object.TextXAlignment = Enum.TextXAlignment.Left
    object.TextYAlignment = Enum.TextYAlignment.Center
    object.ZIndex = 20
    object.Parent = parent
    return object
end

local function makeButton(parent, text, position, size, accent)
    local shadow = Instance.new("Frame")
    shadow.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset + 3)
    shadow.Size = size
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.42
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 18
    shadow.Parent = parent
    addCorner(shadow, 9)

    local object = Instance.new("TextButton")
    object.Position = position
    object.Size = size
    object.BackgroundColor3 = Color3.fromRGB(19, 24, 36)
    object.Text = text
    object.TextColor3 = Color3.fromRGB(222, 228, 240)
    object.Font = Enum.Font.GothamBold
    object.TextSize = 9
    object.AutoButtonColor = false
    object.BorderSizePixel = 0
    object.ZIndex = 20
    object.Parent = parent
    addCorner(object, 9)

    local stroke = addStroke(object, accent or Color3.fromRGB(255, 70, 110), 0.9, 1)

    object.MouseEnter:Connect(function()
        tween(object, 0.13, {
            BackgroundColor3 = Color3.fromRGB(28, 31, 46),
            TextColor3 = Color3.fromRGB(255, 245, 249),
        })
        tween(stroke, 0.13, {Transparency = 0.55})
    end)

    object.MouseLeave:Connect(function()
        tween(object, 0.13, {
            BackgroundColor3 = Color3.fromRGB(19, 24, 36),
            TextColor3 = Color3.fromRGB(222, 228, 240),
        })
        tween(stroke, 0.13, {Transparency = 0.9})
    end)

    object.MouseButton1Down:Connect(function()
        tween(object, 0.07, {
            Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset + 2),
        })
    end)

    object.MouseButton1Up:Connect(function()
        tween(object, 0.09, {Position = position})
    end)

    return object, stroke
end

--// ============================================================
--// MAIN WINDOW
--// ============================================================

local MainShadow = Instance.new("Frame")
MainShadow.Name = "MainShadow"
MainShadow.Size = UDim2.fromOffset(444, 324)
MainShadow.Position = UDim2.new(0.5, -222, 0.5, -154)
MainShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainShadow.BackgroundTransparency = 0.2
MainShadow.BorderSizePixel = 0
MainShadow.ZIndex = 1
MainShadow.Parent = ScreenGui
addCorner(MainShadow, 20)

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(430, 310)
Main.Position = UDim2.new(0.5, -215, 0.5, -155)
Main.BackgroundColor3 = Color3.fromRGB(7, 10, 17)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.ZIndex = 5
Main.Parent = ScreenGui
addCorner(Main, 19)
local MainStroke = addStroke(Main, Color3.fromRGB(255, 55, 102), 0.42, 1)

local MainScale = Instance.new("UIScale")
MainScale.Scale = 1
MainScale.Parent = Main

--// Responsive scale: fixed internal layout, scaled to the available viewport.
local function updateResponsiveScale()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local viewport = camera.ViewportSize
    local sx = (viewport.X - 18) / 430
    local sy = (viewport.Y - 18) / 310
    local scale = clamp(math.min(sx, sy), 0.68, 1.08)
    MainScale.Scale = scale
end

if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale)
end
updateResponsiveScale()

--// ============================================================
--// 3D VIEWPORT BACKGROUND
--// ============================================================

local Viewport = Instance.new("ViewportFrame")
Viewport.Name = "NEXUS_3D_BACKGROUND"
Viewport.Size = UDim2.fromScale(1, 1)
Viewport.Position = UDim2.fromScale(0, 0)
Viewport.BackgroundColor3 = Color3.fromRGB(5, 7, 12)
Viewport.BackgroundTransparency = 0
Viewport.BorderSizePixel = 0
Viewport.Ambient = Color3.fromRGB(120, 30, 70)
Viewport.LightColor = Color3.fromRGB(255, 90, 145)
Viewport.LightDirection = Vector3.new(-1, -1, -1)
Viewport.ImageTransparency = 0.15
Viewport.ZIndex = 6
Viewport.Parent = Main
addCorner(Viewport, 19)

local WorldModel = Instance.new("WorldModel")
WorldModel.Parent = Viewport

local Camera = Instance.new("Camera")
Camera.FieldOfView = 52
Camera.CFrame = CFrame.new(Vector3.new(0, 0, 15), Vector3.new(0, 0, 0))
Camera.Parent = Viewport
Viewport.CurrentCamera = Camera

local ThreeDObjects = {}

local function make3DPart(size, material, transparency)
    local part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Size = size
    part.Material = material or Enum.Material.Neon
    part.Color = Color3.fromRGB(255, 42, 104)
    part.Transparency = transparency or 0.35
    part.Parent = WorldModel
    ThreeDObjects[#ThreeDObjects + 1] = part
    return part
end

local RingA = {}
local RingB = {}

for i = 1, 28 do
    local angle = (math.pi * 2 / 28) * i
    local x = math.cos(angle) * 5.7
    local y = math.sin(angle) * 5.7
    local piece = make3DPart(Vector3.new(1.25, 0.07, 0.07), Enum.Material.Neon, 0.55)
    piece.CFrame = CFrame.new(x, y, 1.2) * CFrame.Angles(0, 0, angle)
    RingA[#RingA + 1] = piece
end

for i = 1, 20 do
    local angle = (math.pi * 2 / 20) * i
    local x = math.cos(angle) * 3.6
    local y = math.sin(angle) * 3.6
    local piece = make3DPart(Vector3.new(0.85, 0.055, 0.055), Enum.Material.Neon, 0.72)
    piece.Color = Color3.fromRGB(111, 60, 255)
    piece.CFrame = CFrame.new(x, y, -0.5) * CFrame.Angles(0, 0, -angle)
    RingB[#RingB + 1] = piece
end

local Core = make3DPart(Vector3.new(2.4, 2.4, 2.4), Enum.Material.Neon, 0.78)
Core.Shape = Enum.PartType.Ball
Core.Color = Color3.fromRGB(255, 40, 104)
Core.CFrame = CFrame.new(0, 0, 0)

for i = 1, 7 do
    local block = make3DPart(Vector3.new(0.35, 0.35, 0.35), Enum.Material.Neon, 0.5)
    block.Color = i % 2 == 0 and Color3.fromRGB(126, 71, 255) or Color3.fromRGB(255, 67, 120)
    block.CFrame = CFrame.new(
        math.cos(i * 2.1) * 4.4,
        math.sin(i * 1.7) * 3.1,
        -1.8 + (i % 3) * 0.7
    )
    block.Shape = Enum.PartType.Ball
end

local viewportOverlay = Instance.new("Frame")
viewportOverlay.Size = UDim2.fromScale(1, 1)
viewportOverlay.BackgroundColor3 = Color3.fromRGB(5, 7, 13)
viewportOverlay.BackgroundTransparency = 0.17
viewportOverlay.BorderSizePixel = 0
viewportOverlay.ZIndex = 7
viewportOverlay.Parent = Main
addCorner(viewportOverlay, 19)

--// Soft inner tint layers.
local TopTint = Instance.new("Frame")
TopTint.Size = UDim2.new(1, 0, 0, 94)
TopTint.BackgroundColor3 = Color3.fromRGB(9, 11, 19)
TopTint.BackgroundTransparency = 0.18
TopTint.BorderSizePixel = 0
TopTint.ZIndex = 8
TopTint.Parent = Main
addCorner(TopTint, 18)

local BottomTint = Instance.new("Frame")
BottomTint.Size = UDim2.new(1, 0, 0, 70)
BottomTint.Position = UDim2.new(0, 0, 1, -70)
BottomTint.BackgroundColor3 = Color3.fromRGB(6, 9, 15)
BottomTint.BackgroundTransparency = 0.2
BottomTint.BorderSizePixel = 0
BottomTint.ZIndex = 8
BottomTint.Parent = Main
addCorner(BottomTint, 18)

--// 3D animation stays very light: only CFrame updates, no UI tweens per frame.
local angleA = 0
local angleB = 0
local last3D = 0
local threeDConnection = RunService.RenderStepped:Connect(function(dt)
    if not Main.Parent then
        return
    end

    -- Throttle to keep mobile overhead low.
    if os.clock() - last3D < 1 / 30 then
        return
    end
    last3D = os.clock()

    angleA += dt * 0.35
    angleB -= dt * 0.22

    for i, part in ipairs(RingA) do
        local base = (math.pi * 2 / #RingA) * i + angleA
        part.CFrame = CFrame.new(
            math.cos(base) * 5.7,
            math.sin(base) * 5.7,
            1.2 + math.sin(angleA + i * 0.16) * 0.35
        ) * CFrame.Angles(0, 0, base)
    end

    for i, part in ipairs(RingB) do
        local base = (math.pi * 2 / #RingB) * i + angleB
        part.CFrame = CFrame.new(
            math.cos(base) * 3.6,
            math.sin(base) * 3.6,
            -0.5 + math.cos(angleB + i * 0.25) * 0.3
        ) * CFrame.Angles(0, 0, -base)
    end

    Core.CFrame = CFrame.new(0, 0, math.sin(angleA * 0.8) * 0.4)
        * CFrame.Angles(angleA * 0.4, angleB * 0.6, angleA * 0.2)
end)

--// ============================================================
--// HEADER
--// ============================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 64)
Header.BackgroundColor3 = Color3.fromRGB(8, 11, 19)
Header.BackgroundTransparency = 0.08
Header.BorderSizePixel = 0
Header.ZIndex = 12
Header.Parent = Main
addCorner(Header, 18)

local HeaderAccent = Instance.new("Frame")
HeaderAccent.Size = UDim2.fromOffset(4, 40)
HeaderAccent.Position = UDim2.fromOffset(12, 12)
HeaderAccent.BackgroundColor3 = Color3.fromRGB(255, 53, 108)
HeaderAccent.BorderSizePixel = 0
HeaderAccent.ZIndex = 15
HeaderAccent.Parent = Header
addCorner(HeaderAccent, 3)

local HeaderAccentGlow = Instance.new("Frame")
HeaderAccentGlow.Size = UDim2.fromOffset(15, 48)
HeaderAccentGlow.Position = UDim2.fromOffset(7, 8)
HeaderAccentGlow.BackgroundColor3 = Color3.fromRGB(255, 35, 95)
HeaderAccentGlow.BackgroundTransparency = 0.92
HeaderAccentGlow.BorderSizePixel = 0
HeaderAccentGlow.ZIndex = 13
HeaderAccentGlow.Parent = Header
addCorner(HeaderAccentGlow, 8)

local Title = makeLabel(
    Header,
    "NEXUS",
    UDim2.fromOffset(27, 7),
    UDim2.new(1, -155, 0, 27),
    Enum.Font.GothamBlack,
    Color3.fromRGB(248, 250, 255),
    22
)

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.58, Color3.fromRGB(255, 235, 241)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 77, 119)),
})
TitleGradient.Parent = Title

local Subtitle = makeLabel(
    Header,
    "MATH TOWER RACE  /  SMART SOLVER",
    UDim2.fromOffset(28, 34),
    UDim2.new(1, -170, 0, 15),
    Enum.Font.GothamMedium,
    Color3.fromRGB(112, 121, 141),
    7
)

local VersionChip = Instance.new("Frame")
VersionChip.Size = UDim2.fromOffset(62, 24)
VersionChip.Position = UDim2.new(1, -119, 0, 9)
VersionChip.BackgroundColor3 = Color3.fromRGB(30, 18, 34)
VersionChip.BorderSizePixel = 0
VersionChip.ZIndex = 15
VersionChip.Parent = Header
addCorner(VersionChip, 8)
addStroke(VersionChip, Color3.fromRGB(255, 66, 111), 0.6, 1)

local VersionText = makeLabel(
    VersionChip,
    "MTR / V3",
    UDim2.fromScale(0, 0),
    UDim2.fromScale(1, 1),
    Enum.Font.GothamBold,
    Color3.fromRGB(255, 111, 139),
    8
)
VersionText.TextXAlignment = Enum.TextXAlignment.Center

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.fromOffset(32, 32)
CloseButton.Position = UDim2.new(1, -43, 0, 14)
CloseButton.BackgroundColor3 = Color3.fromRGB(27, 31, 44)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(230, 234, 243)
CloseButton.Font = Enum.Font.GothamBlack
CloseButton.TextSize = 19
CloseButton.AutoButtonColor = false
CloseButton.BorderSizePixel = 0
CloseButton.ZIndex = 16
CloseButton.Parent = Header
addCorner(CloseButton, 10)
local CloseStroke = addStroke(CloseButton, Color3.fromRGB(255, 255, 255), 0.84, 1)

CloseButton.MouseEnter:Connect(function()
    tween(CloseButton, 0.13, {
        BackgroundColor3 = Color3.fromRGB(115, 28, 54),
        Rotation = 6,
    })
    tween(CloseStroke, 0.13, {Transparency = 0.45})
end)

CloseButton.MouseLeave:Connect(function()
    tween(CloseButton, 0.13, {
        BackgroundColor3 = Color3.fromRGB(27, 31, 44),
        Rotation = 0,
    })
    tween(CloseStroke, 0.13, {Transparency = 0.84})
end)

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, -30, 0, 1)
HeaderLine.Position = UDim2.new(0, 15, 1, -2)
HeaderLine.BackgroundColor3 = Color3.fromRGB(255, 57, 105)
HeaderLine.BackgroundTransparency = 0.55
HeaderLine.BorderSizePixel = 0
HeaderLine.ZIndex = 17
HeaderLine.Parent = Header

--// ============================================================
--// CONTENT / SIDEBAR
--// ============================================================

local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, -20, 1, -74)
Body.Position = UDim2.fromOffset(10, 69)
Body.BackgroundTransparency = 1
Body.ClipsDescendants = true
Body.ZIndex = 18
Body.Parent = Main

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.fromOffset(92, 227)
Sidebar.Position = UDim2.fromOffset(0, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(9, 13, 22)
Sidebar.BackgroundTransparency = 0.1
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 20
Sidebar.Parent = Body
addCorner(Sidebar, 12)
addStroke(Sidebar, Color3.fromRGB(255, 255, 255), 0.93, 1)

local SidebarTitle = makeLabel(
    Sidebar,
    "SYSTEM",
    UDim2.fromOffset(10, 8),
    UDim2.new(1, -20, 0, 13),
    Enum.Font.GothamBold,
    Color3.fromRGB(78, 88, 108),
    7
)

local function navButton(text, y, symbol)
    local object = Instance.new("TextButton")
    object.Size = UDim2.new(1, -12, 0, 34)
    object.Position = UDim2.fromOffset(6, y)
    object.BackgroundColor3 = Color3.fromRGB(17, 22, 34)
    object.Text = ""
    object.AutoButtonColor = false
    object.BorderSizePixel = 0
    object.ZIndex = 22
    object.Parent = Sidebar
    addCorner(object, 8)
    local stroke = addStroke(object, Color3.fromRGB(255, 62, 108), 0.95, 1)

    local icon = makeLabel(
        object,
        symbol,
        UDim2.fromOffset(8, 0),
        UDim2.fromOffset(18, 34),
        Enum.Font.GothamBlack,
        Color3.fromRGB(255, 83, 124),
        10
    )
    icon.TextXAlignment = Enum.TextXAlignment.Center

    local title = makeLabel(
        object,
        text,
        UDim2.fromOffset(28, 0),
        UDim2.new(1, -33, 1, 0),
        Enum.Font.GothamBold,
        Color3.fromRGB(201, 208, 222),
        8
    )

    object.MouseEnter:Connect(function()
        tween(object, 0.12, {BackgroundColor3 = Color3.fromRGB(27, 29, 44)})
        tween(stroke, 0.12, {Transparency = 0.6})
        tween(icon, 0.12, {TextColor3 = Color3.fromRGB(255, 127, 153)})
    end)

    object.MouseLeave:Connect(function()
        tween(object, 0.12, {BackgroundColor3 = Color3.fromRGB(17, 22, 34)})
        tween(stroke, 0.12, {Transparency = 0.95})
        tween(icon, 0.12, {TextColor3 = Color3.fromRGB(255, 83, 124)})
    end)

    return object, stroke, icon, title
end

local MainTab = navButton("MAIN", 28, ">")
local SettingsTab = navButton("SETTINGS", 67, "⚙")
local InfoTab = navButton("INFO", 106, "i")

local SideBottom = makeLabel(
    Sidebar,
    "NEXUS\nMTR",
    UDim2.fromOffset(10, 184),
    UDim2.new(1, -20, 0, 36),
    Enum.Font.GothamBlack,
    Color3.fromRGB(54, 62, 80),
    8
)
SideBottom.TextYAlignment = Enum.TextYAlignment.Top

local Content = Instance.new("Frame")
Content.Position = UDim2.fromOffset(101, 0)
Content.Size = UDim2.new(1, -101, 1, 0)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = true
Content.ZIndex = 20
Content.Parent = Body

local MainPage = Instance.new("Frame")
MainPage.Size = UDim2.fromScale(1, 1)
MainPage.BackgroundTransparency = 1
MainPage.ZIndex = 21
MainPage.Parent = Content

local SettingsPage = Instance.new("Frame")
SettingsPage.Size = UDim2.fromScale(1, 1)
SettingsPage.BackgroundTransparency = 1
SettingsPage.Visible = false
SettingsPage.ZIndex = 21
SettingsPage.Parent = Content

local InfoPage = Instance.new("Frame")
InfoPage.Size = UDim2.fromScale(1, 1)
InfoPage.BackgroundTransparency = 1
InfoPage.Visible = false
InfoPage.ZIndex = 21
InfoPage.Parent = Content

--// ============================================================
--// STATUS
--// ============================================================

local StatusDot
local StatusLabel
local CounterLabel
local RandomizerButton
local AntiAFKButton
local DebugButton
local SolveSwitch
local SolveKnob
local SolveIcon

local function updateUI()
    RandomizerButton.Text = "RANDOMIZER   " .. (Config.Randomizer and "ON" or "OFF")
    AntiAFKButton.Text = "ANTI AFK   " .. (Config.AntiAFK and "ON" or "OFF")
    DebugButton.Text = "DEBUG   " .. (Config.Debug and "ON" or "OFF")

    CounterLabel.Text = string.format("SOLVED %d    /    SCANS %d", State.Solved, State.Scans)

    if Config.AutoSolve then
        SolveSwitch.BackgroundColor3 = Color3.fromRGB(86, 24, 51)
        SolveKnob.Position = UDim2.fromOffset(31, 4)
        SolveKnob.BackgroundColor3 = Color3.fromRGB(255, 80, 121)
        SolveIcon.BackgroundColor3 = Color3.fromRGB(83, 25, 48)
    else
        SolveSwitch.BackgroundColor3 = Color3.fromRGB(24, 29, 42)
        SolveKnob.Position = UDim2.fromOffset(4, 4)
        SolveKnob.BackgroundColor3 = Color3.fromRGB(160, 168, 184)
        SolveIcon.BackgroundColor3 = Color3.fromRGB(42, 29, 42)
    end
end

local function setStatus(text)
    State.LastStatus = text

    if StatusLabel then
        StatusLabel.Text = text
    end

    updateUI()

    if StatusDot then
        tween(StatusDot, 0.08, {
            Size = UDim2.fromOffset(9, 9),
        })
        task.delay(0.1, function()
            if StatusDot and StatusDot.Parent then
                tween(StatusDot, 0.16, {
                    Size = UDim2.fromOffset(6, 6),
                })
            end
        end)
    end
end

--// ============================================================
--// MAIN PAGE
--// ============================================================

makeLabel(
    MainPage,
    "AUTOMATION",
    UDim2.fromOffset(4, 0),
    UDim2.new(1, -8, 0, 14),
    Enum.Font.GothamBold,
    Color3.fromRGB(91, 101, 121),
    7
)

local SolveCard = Instance.new("Frame")
SolveCard.Position = UDim2.fromOffset(4, 20)
SolveCard.Size = UDim2.new(1, -8, 0, 53)
SolveCard.BackgroundColor3 = Color3.fromRGB(10, 14, 23)
SolveCard.BackgroundTransparency = 0.05
SolveCard.BorderSizePixel = 0
SolveCard.ZIndex = 24
SolveCard.Parent = MainPage
addCorner(SolveCard, 11)
addStroke(SolveCard, Color3.fromRGB(255, 59, 107), 0.78, 1)

SolveIcon = Instance.new("Frame")
SolveIcon.Size = UDim2.fromOffset(34, 34)
SolveIcon.Position = UDim2.fromOffset(9, 9)
SolveIcon.BackgroundColor3 = Color3.fromRGB(42, 29, 42)
SolveIcon.BorderSizePixel = 0
SolveIcon.ZIndex = 25
SolveIcon.Parent = SolveCard
addCorner(SolveIcon, 10)
addStroke(SolveIcon, Color3.fromRGB(255, 67, 113), 0.7, 1)

local SolveIconText = makeLabel(
    SolveIcon,
    ">_",
    UDim2.fromScale(0, 0),
    UDim2.fromScale(1, 1),
    Enum.Font.GothamBlack,
    Color3.fromRGB(255, 99, 132),
    12
)
SolveIconText.TextXAlignment = Enum.TextXAlignment.Center

makeLabel(
    SolveCard,
    "AUTO SOLVE",
    UDim2.fromOffset(52, 7),
    UDim2.new(1, -132, 0, 17),
    Enum.Font.GothamBold,
    Color3.fromRGB(239, 242, 249),
    9
)

makeLabel(
    SolveCard,
    "QUESTION  →  ANSWER",
    UDim2.fromOffset(52, 25),
    UDim2.new(1, -138, 0, 13),
    Enum.Font.Gotham,
    Color3.fromRGB(99, 109, 129),
    6
)

SolveSwitch = Instance.new("Frame")
SolveSwitch.Size = UDim2.fromOffset(53, 27)
SolveSwitch.Position = UDim2.new(1, -62, 0, 13)
SolveSwitch.BackgroundColor3 = Color3.fromRGB(24, 29, 42)
SolveSwitch.BorderSizePixel = 0
SolveSwitch.ZIndex = 26
SolveSwitch.Parent = SolveCard
addCorner(SolveSwitch, 14)
local SolveSwitchStroke = addStroke(SolveSwitch, Color3.fromRGB(255, 76, 117), 0.72, 1)

SolveKnob = Instance.new("Frame")
SolveKnob.Size = UDim2.fromOffset(19, 19)
SolveKnob.Position = UDim2.fromOffset(4, 4)
SolveKnob.BackgroundColor3 = Color3.fromRGB(160, 168, 184)
SolveKnob.BorderSizePixel = 0
SolveKnob.ZIndex = 27
SolveKnob.Parent = SolveSwitch
addCorner(SolveKnob, 10)

local SolveClickZone = Instance.new("TextButton")
SolveClickZone.Size = UDim2.fromScale(1, 1)
SolveClickZone.BackgroundTransparency = 1
SolveClickZone.Text = ""
SolveClickZone.ZIndex = 30
SolveClickZone.Parent = SolveCard

RandomizerButton = makeButton(
    MainPage,
    "RANDOMIZER   ON",
    UDim2.fromOffset(4, 79),
    UDim2.new(1, -8, 0, 34)
)

AntiAFKButton = makeButton(
    MainPage,
    "ANTI AFK   ON",
    UDim2.fromOffset(4, 117),
    UDim2.new(1, -8, 0, 34)
)

local ScanButton = makeButton(
    MainPage,
    "SCAN / TEST",
    UDim2.fromOffset(4, 155),
    UDim2.new(1, -8, 0, 34),
    Color3.fromRGB(113, 76, 255)
)

local StatusFrame = Instance.new("Frame")
StatusFrame.Position = UDim2.fromOffset(4, 193)
StatusFrame.Size = UDim2.new(1, -8, 0, 63)
StatusFrame.BackgroundColor3 = Color3.fromRGB(8, 12, 20)
StatusFrame.BackgroundTransparency = 0.04
StatusFrame.BorderSizePixel = 0
StatusFrame.ZIndex = 24
StatusFrame.Parent = MainPage
addCorner(StatusFrame, 11)
addStroke(StatusFrame, Color3.fromRGB(255, 255, 255), 0.92, 1)

StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.fromOffset(6, 6)
StatusDot.Position = UDim2.fromOffset(11, 11)
StatusDot.BackgroundColor3 = Color3.fromRGB(70, 255, 158)
StatusDot.BorderSizePixel = 0
StatusDot.ZIndex = 27
StatusDot.Parent = StatusFrame
addCorner(StatusDot, 4)

StatusLabel = makeLabel(
    StatusFrame,
    "NEXUS READY",
    UDim2.fromOffset(24, 5),
    UDim2.new(1, -32, 0, 17),
    Enum.Font.GothamBold,
    Color3.fromRGB(228, 233, 243),
    8
)

CounterLabel = makeLabel(
    StatusFrame,
    "SOLVED 0    /    SCANS 0",
    UDim2.fromOffset(11, 28),
    UDim2.new(1, -22, 0, 13),
    Enum.Font.GothamMedium,
    Color3.fromRGB(103, 113, 133),
    7
)

makeLabel(
    StatusFrame,
    "solver engine  /  PlayerGui monitor",
    UDim2.fromOffset(11, 44),
    UDim2.new(1, -22, 0, 11),
    Enum.Font.Gotham,
    Color3.fromRGB(66, 75, 93),
    6
)

--// ============================================================
--// SETTINGS PAGE
--// ============================================================

makeLabel(
    SettingsPage,
    "TIMING CONTROL",
    UDim2.fromOffset(4, 0),
    UDim2.new(1, -8, 0, 15),
    Enum.Font.GothamBold,
    Color3.fromRGB(91, 101, 121),
    7
)

makeLabel(
    SettingsPage,
    "MIN DELAY",
    UDim2.fromOffset(4, 23),
    UDim2.new(1, -8, 0, 13),
    Enum.Font.GothamBold,
    Color3.fromRGB(186, 193, 207),
    7
)

local MinDelayBox = Instance.new("TextBox")
MinDelayBox.Position = UDim2.fromOffset(4, 39)
MinDelayBox.Size = UDim2.new(1, -8, 0, 30)
MinDelayBox.BackgroundColor3 = Color3.fromRGB(12, 17, 28)
MinDelayBox.Text = tostring(Config.MinDelay)
MinDelayBox.TextColor3 = Color3.fromRGB(238, 242, 249)
MinDelayBox.Font = Enum.Font.GothamMedium
MinDelayBox.TextSize = 9
MinDelayBox.ClearTextOnFocus = false
MinDelayBox.BorderSizePixel = 0
MinDelayBox.ZIndex = 24
MinDelayBox.Parent = SettingsPage
addCorner(MinDelayBox, 8)
addStroke(MinDelayBox, Color3.fromRGB(255, 255, 255), 0.92, 1)

makeLabel(
    SettingsPage,
    "MAX DELAY",
    UDim2.fromOffset(4, 76),
    UDim2.new(1, -8, 0, 13),
    Enum.Font.GothamBold,
    Color3.fromRGB(186, 193, 207),
    7
)

local MaxDelayBox = Instance.new("TextBox")
MaxDelayBox.Position = UDim2.fromOffset(4, 92)
MaxDelayBox.Size = UDim2.new(1, -8, 0, 30)
MaxDelayBox.BackgroundColor3 = Color3.fromRGB(12, 17, 28)
MaxDelayBox.Text = tostring(Config.MaxDelay)
MaxDelayBox.TextColor3 = Color3.fromRGB(238, 242, 249)
MaxDelayBox.Font = Enum.Font.GothamMedium
MaxDelayBox.TextSize = 9
MaxDelayBox.ClearTextOnFocus = false
MaxDelayBox.BorderSizePixel = 0
MaxDelayBox.ZIndex = 24
MaxDelayBox.Parent = SettingsPage
addCorner(MaxDelayBox, 8)
addStroke(MaxDelayBox, Color3.fromRGB(255, 255, 255), 0.92, 1)

local ApplyButton = makeButton(
    SettingsPage,
    "APPLY TIMING",
    UDim2.fromOffset(4, 130),
    UDim2.new(1, -8, 0, 33),
    Color3.fromRGB(255, 72, 112)
)

DebugButton = makeButton(
    SettingsPage,
    "DEBUG   OFF",
    UDim2.fromOffset(4, 167),
    UDim2.new(1, -8, 0, 33)
)

local TimingHint = makeLabel(
    SettingsPage,
    "Randomizer varies the click timing inside the selected range.\nKeep the range low for faster rounds.",
    UDim2.fromOffset(4, 208),
    UDim2.new(1, -8, 0, 35),
    Enum.Font.Gotham,
    Color3.fromRGB(82, 92, 112),
    6
)
TimingHint.TextWrapped = true
TimingHint.TextYAlignment = Enum.TextYAlignment.Top

--// ============================================================
--// INFO PAGE
--// ============================================================

makeLabel(
    InfoPage,
    "NEXUS MTR",
    UDim2.fromOffset(4, 0),
    UDim2.new(1, -8, 0, 23),
    Enum.Font.GothamBlack,
    Color3.fromRGB(244, 247, 253),
    14
)

makeLabel(
    InfoPage,
    "MATH TOWER RACE  /  V3",
    UDim2.fromOffset(4, 22),
    UDim2.new(1, -8, 0, 15),
    Enum.Font.GothamBold,
    Color3.fromRGB(255, 78, 117),
    7
)

local InfoCard = Instance.new("Frame")
InfoCard.Position = UDim2.fromOffset(4, 47)
InfoCard.Size = UDim2.new(1, -8, 0, 211)
InfoCard.BackgroundColor3 = Color3.fromRGB(8, 12, 20)
InfoCard.BackgroundTransparency = 0.04
InfoCard.BorderSizePixel = 0
InfoCard.ZIndex = 24
InfoCard.Parent = InfoPage
addCorner(InfoCard, 12)
addStroke(InfoCard, Color3.fromRGB(255, 255, 255), 0.92, 1)

local InfoText = makeLabel(
    InfoCard,
    "CORE FEATURES\n\n"
    .. "> Auto Solve\n"
    .. "> Expression parser\n"
    .. "> Numeric answer matching\n"
    .. "> Randomized timing\n"
    .. "> Anti-AFK\n"
    .. "> Manual scan test\n"
    .. "> Responsive mobile / PC UI\n"
    .. "> Animated 3D NEXUS background",
    UDim2.fromOffset(13, 11),
    UDim2.new(1, -26, 1, -22),
    Enum.Font.Gotham,
    Color3.fromRGB(155, 164, 182),
    8
)
InfoText.TextYAlignment = Enum.TextYAlignment.Top
InfoText.TextWrapped = true

--// ============================================================
--// PAGE SWITCHING
--// ============================================================

local function setNavState(selected)
    local tabs = {MainTab, SettingsTab, InfoTab}
    for _, tab in ipairs(tabs) do
        local active = tab == selected
        tween(tab, 0.15, {
            BackgroundColor3 = active
                and Color3.fromRGB(67, 23, 45)
                or Color3.fromRGB(17, 22, 34),
        })
    end
end

local function switchPage(page, tab)
    MainPage.Visible = page == MainPage
    SettingsPage.Visible = page == SettingsPage
    InfoPage.Visible = page == InfoPage
    setNavState(tab)
end

MainTab.MouseButton1Click:Connect(function()
    switchPage(MainPage, MainTab)
end)

SettingsTab.MouseButton1Click:Connect(function()
    switchPage(SettingsPage, SettingsTab)
end)

InfoTab.MouseButton1Click:Connect(function()
    switchPage(InfoPage, InfoTab)
end)

--// ============================================================
--// UI INTERACTIONS
--// ============================================================

SolveClickZone.MouseButton1Click:Connect(function()
    Config.AutoSolve = not Config.AutoSolve
    setStatus(Config.AutoSolve and "AUTO SOLVER ENABLED" or "AUTO SOLVER DISABLED")
end)

RandomizerButton.MouseButton1Click:Connect(function()
    Config.Randomizer = not Config.Randomizer
    setStatus(Config.Randomizer and "RANDOMIZER ENABLED" or "RANDOMIZER DISABLED")
end)

AntiAFKButton.MouseButton1Click:Connect(function()
    setAntiAFK(not Config.AntiAFK)
    setStatus(Config.AntiAFK and "ANTI AFK ENABLED" or "ANTI AFK DISABLED")
end)

DebugButton.MouseButton1Click:Connect(function()
    Config.Debug = not Config.Debug
    setStatus(Config.Debug and "DEBUG ENABLED" or "DEBUG DISABLED")
end)

ApplyButton.MouseButton1Click:Connect(function()
    local minValue = tonumber(MinDelayBox.Text)
    local maxValue = tonumber(MaxDelayBox.Text)

    if minValue then
        Config.MinDelay = clamp(minValue, 0, 5)
    end

    if maxValue then
        Config.MaxDelay = clamp(maxValue, Config.MinDelay, 5)
    end

    MinDelayBox.Text = tostring(Config.MinDelay)
    MaxDelayBox.Text = tostring(Config.MaxDelay)

    setStatus(string.format("TIMING  %.2f  —  %.2f SEC", Config.MinDelay, Config.MaxDelay))
end)

ScanButton.MouseButton1Click:Connect(function()
    local previous = Config.AutoSolve
    Config.AutoSolve = true

    local success, message = solveOnce()

    Config.AutoSolve = previous

    if success then
        setStatus("SOLVED  •  " .. message)
    else
        setStatus(message or "SCAN FAILED")
    end
end)

--// ============================================================
--// CIRCULAR NEXUS LAUNCHER
--// ============================================================

local Launcher = Instance.new("Frame")
Launcher.Name = "NEXUS_3D_LAUNCHER"
Launcher.Size = UDim2.fromOffset(76, 76)
Launcher.Position = UDim2.new(0, 18, 0.5, -38)
Launcher.BackgroundTransparency = 1
Launcher.Visible = false
Launcher.ZIndex = 100
Launcher.Parent = ScreenGui

local LauncherScale = Instance.new("UIScale")
LauncherScale.Scale = 1
LauncherScale.Parent = Launcher

local LauncherShadow = Instance.new("Frame")
LauncherShadow.Size = UDim2.fromOffset(58, 58)
LauncherShadow.Position = UDim2.fromOffset(9, 13)
LauncherShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LauncherShadow.BackgroundTransparency = 0.32
LauncherShadow.BorderSizePixel = 0
LauncherShadow.ZIndex = 100
LauncherShadow.Parent = Launcher
addCorner(LauncherShadow, 30)

local LauncherOuter = Instance.new("Frame")
LauncherOuter.Size = UDim2.fromOffset(64, 64)
LauncherOuter.Position = UDim2.fromOffset(6, 6)
LauncherOuter.BackgroundColor3 = Color3.fromRGB(44, 14, 35)
LauncherOuter.BorderSizePixel = 0
LauncherOuter.ZIndex = 101
LauncherOuter.Parent = Launcher
addCorner(LauncherOuter, 32)
local LauncherOuterStroke = addStroke(LauncherOuter, Color3.fromRGB(255, 63, 111), 0.2, 1)

local LauncherRing = Instance.new("Frame")
LauncherRing.Size = UDim2.fromOffset(54, 54)
LauncherRing.Position = UDim2.fromOffset(11, 11)
LauncherRing.BackgroundColor3 = Color3.fromRGB(12, 15, 25)
LauncherRing.BorderSizePixel = 0
LauncherRing.ZIndex = 102
LauncherRing.Parent = Launcher
addCorner(LauncherRing, 28)
addStroke(LauncherRing, Color3.fromRGB(118, 74, 255), 0.3, 1)

local LauncherButton = Instance.new("TextButton")
LauncherButton.Size = UDim2.fromOffset(48, 48)
LauncherButton.Position = UDim2.fromOffset(14, 14)
LauncherButton.BackgroundColor3 = Color3.fromRGB(18, 21, 32)
LauncherButton.Text = "N"
LauncherButton.TextColor3 = Color3.fromRGB(250, 250, 255)
LauncherButton.Font = Enum.Font.GothamBlack
LauncherButton.TextSize = 21
LauncherButton.AutoButtonColor = false
LauncherButton.BorderSizePixel = 0
LauncherButton.ZIndex = 104
LauncherButton.Parent = Launcher
addCorner(LauncherButton, 25)
local LauncherButtonStroke = addStroke(LauncherButton, Color3.fromRGB(255, 76, 118), 0.12, 1)

local LauncherDot = Instance.new("Frame")
LauncherDot.Size = UDim2.fromOffset(6, 6)
LauncherDot.Position = UDim2.fromOffset(50, 18)
LauncherDot.BackgroundColor3 = Color3.fromRGB(73, 255, 160)
LauncherDot.BorderSizePixel = 0
LauncherDot.ZIndex = 105
LauncherDot.Parent = Launcher
addCorner(LauncherDot, 3)

local launcherRotation = 0
local launcherPulseConnection = RunService.RenderStepped:Connect(function(dt)
    if not Launcher.Parent or not Launcher.Visible then
        return
    end

    launcherRotation += dt * 22
    LauncherRing.Rotation = launcherRotation
    LauncherDot.BackgroundTransparency = 0.15 + (math.sin(os.clock() * 2.3) + 1) * 0.22
end)

LauncherButton.MouseEnter:Connect(function()
    tween(LauncherScale, 0.15, {Scale = 1.08})
    tween(LauncherButton, 0.15, {
        BackgroundColor3 = Color3.fromRGB(29, 24, 43),
        Rotation = -5,
    })
    tween(LauncherButtonStroke, 0.15, {Transparency = 0})
end)

LauncherButton.MouseLeave:Connect(function()
    tween(LauncherScale, 0.18, {Scale = 1})
    tween(LauncherButton, 0.18, {
        BackgroundColor3 = Color3.fromRGB(18, 21, 32),
        Rotation = 0,
    })
    tween(LauncherButtonStroke, 0.18, {Transparency = 0.12})
end)

--// ============================================================
--// OPEN / CLOSE
--// ============================================================

local menuOpen = true

local function showLauncher()
    Launcher.Visible = true
    Launcher.Position = UDim2.new(0, 7, 0.5, -38)
    LauncherScale.Scale = 0.72

    tween(Launcher, 0.32, {
        Position = UDim2.new(0, 18, 0.5, -38),
    }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    tween(LauncherScale, 0.32, {
        Scale = 1,
    }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function hideLauncher()
    tween(Launcher, 0.2, {
        Position = UDim2.new(0, 5, 0.5, -38),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

    tween(LauncherScale, 0.2, {
        Scale = 0.76,
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

    task.delay(0.21, function()
        if Launcher then
            Launcher.Visible = false
        end
    end)
end

local function openMenu()
    menuOpen = true
    Main.Visible = true
    Main.Position = UDim2.new(0.5, -215, 0.5, -145)
    MainScale.Scale = 0.94
    MainShadow.BackgroundTransparency = 1

    tween(Main, 0.28, {
        Position = UDim2.new(0.5, -215, 0.5, -155),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    tween(MainScale, 0.28, {
        Scale = 1,
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    tween(MainShadow, 0.28, {
        BackgroundTransparency = 0.2,
    }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
end

local function closeMenu()
    menuOpen = false

    tween(Main, 0.2, {
        Position = UDim2.new(0.5, -215, 0.5, -143),
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

    tween(MainScale, 0.2, {
        Scale = 0.94,
    }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)

    tween(MainShadow, 0.2, {
        BackgroundTransparency = 1,
    }, Enum.EasingStyle.Sine, Enum.EasingDirection.In)

    task.delay(0.21, function()
        if not menuOpen then
            Main.Visible = false
            Main.Position = UDim2.new(0.5, -215, 0.5, -155)
            MainScale.Scale = 1
            showLauncher()
        end
    end)
end

CloseButton.MouseButton1Click:Connect(closeMenu)
LauncherButton.MouseButton1Click:Connect(function()
    hideLauncher()
    openMenu()
end)

--// ============================================================
--// DRAG SYSTEM
--// ============================================================

local dragging = false
local dragInput
local dragStart
local startPosition

local function updateDrag(input)
    if not dragging then
        return
    end

    local delta = input.Position - dragStart

    Main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )

    MainShadow.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset - 7 + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + 7 + delta.Y
    )
end

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = Main.Position
        dragInput = input
    end
end)

Header.InputEnded:Connect(function(input)
    if input == dragInput
        or input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = false
        dragInput = nil
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then

        updateDrag(input)
    end
end)

--// ============================================================
--// STARTUP
--// ============================================================

switchPage(MainPage, MainTab)
updateUI()
setStatus("NEXUS READY  •  MTR")

--// ============================================================
--// SOLVER LOOP
--// ============================================================

local running = true

task.spawn(function()
    while running do
        if Config.AutoSolve then
            local success, message = solveOnce()

            if success then
                setStatus("SOLVED  •  " .. message)
            elseif Config.Debug and message ~= "Cooldown" and message ~= "Auto Solve is OFF" then
                setStatus(message)
            end
        end

        task.wait(clamp(tonumber(Config.ScanInterval) or 0.05, 0.02, 2))
    end
end)

--// ============================================================
--// RESPAWN SAFETY
--// ============================================================

LocalPlayer.CharacterAdded:Connect(function()
    State.LastSignature = ""
    State.LastClick = 0

    task.wait(0.5)

    if Config.AntiAFK then
        setAntiAFK(true)
    end
end)

--// Keep 3D connections from surviving if the GUI is destroyed externally.
ScreenGui.Destroying:Connect(function()
    running = false

    if AntiAFKConnection then
        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil
    end

    if threeDConnection then
        threeDConnection:Disconnect()
    end

    if launcherPulseConnection then
        launcherPulseConnection:Disconnect()
    end
end)

print("[NEXUS] Math Tower Race V3 loaded")
print("[NEXUS] AutoSolve:", Config.AutoSolve)
print("[NEXUS] Randomizer:", Config.Randomizer)
print("[NEXUS] AntiAFK:", Config.AntiAFK)
