if not game:IsLoaded() then
    game.Loaded:Wait()
end
do
    local str

    do
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer

        if not LocalPlayer then
            pcall(function()
                Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
            end)
            LocalPlayer = Players.LocalPlayer
        end

        str = tostring(LocalPlayer and LocalPlayer.UserId or 0)
    end

    local v4 = getgenv and getgenv() or _G
    local NEXUSHUB = v4.NEXUSHUB

    if type(NEXUSHUB) ~= "table" then
        NEXUSHUB = {
			slots = {}
		}
        v4.NEXUSHUB = NEXUSHUB
    end

    if type(NEXUSHUB.slots) ~= "table" then
        NEXUSHUB.slots = {}
    end

    local unload

    do
        local v6 = NEXUSHUB.slots[str]

        if type(v6) ~= "table" then
            v6 = {}
            NEXUSHUB.slots[str] = v6
        end

        v6.gen = (tonumber(v6.gen) or 0) + 1

        local v7 = false

        for k, v in pairs(NEXUSHUB.slots) do
            if str ~= tostring(k) and type(v) == "table" and v.alive == true then
                v7 = true

                break
            end
        end

        if not v7 then
            v4.NEXUSCfgGen = (tonumber(v4.NEXUSCfgGen) or 0) + 1
        end

        unload = v6.unload
        v6.unload = nil
        v6.alive = false
    end

    if type(unload) == "function" then
        pcall(unload)
    elseif type(v4.NEXUSUnload) == "function" then
        local NEXUSUnloadUid = v4.NEXUSUnloadUid
        local v12 = NEXUSUnloadUid == nil or str == tostring(NEXUSUnloadUid)

        if NEXUSUnloadUid == nil then
            for k, v in pairs(NEXUSHUB.slots) do
                if str ~= tostring(k) and type(v) == "table" and type(v.unload) == "function" then
                    v12 = false

                    break
                end
            end
        end

        if v12 then
            local NEXUSUnload = v4.NEXUSUnload

            if str == tostring(NEXUSUnloadUid or str) then
                v4.NEXUSUnload = nil
                v4.NEXUSUnloadUid = nil
            end

            pcall(NEXUSUnload)
        end
    end
end
do
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    if not LocalPlayer then
        pcall(function()
            Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        end)
        LocalPlayer = Players.LocalPlayer
    end

    local v18 = os.clock() + 60

    while LocalPlayer and v18 > os.clock() do
        local v20, v21

        do
            local Character = LocalPlayer.Character

            v20 = Character and Character:FindFirstChildOfClass("Humanoid")
            v21 = Character and Character:FindFirstChild("HumanoidRootPart")
        end

        if v20 and v21 and v20.Health > 0 then
            task.wait(0.45)

            local Character = LocalPlayer.Character
            local v23 = Character and Character:FindFirstChildOfClass("Humanoid")
            local v24 = Character and Character:FindFirstChild("HumanoidRootPart")

            if not v23 or not v24 or not (v23.Health > 0) then
                continue
            end

            break
        end

        task.wait(0.1)
    end
end
local t1 = {
	Title = "NEXUS",
	Version = "0.1-GUARDIAN-FIX-V5-ROUTE",
	Product = "STEAL AN EGG",
	OpenBind = Enum.KeyCode.RightShift,
	FlightBind = Enum.KeyCode.F,
	Tagline = "GAME LIBRARY • STEAL • HATCH • FARM",
	Status = "LIVE",
	Game = "Steal an Egg",
	Discord = "",
	Website = "",
	Changelog = "",
	Author = "NEXUS DEVELOPMENT",
	Credits = "NEXUS Steal an Egg",
	Support = "NEXUS • Steal an Egg"
}
local function v26(p1)
    local v328 = tostring(p1 or "Game"):gsub("[<>:\"/\\|?*]", "_"):gsub("%s+", "_"):gsub("_+", "_"):match("^%s*(.-)%s*$")

    if not v328 or v328 == "" or v328 == "_" then
        v328 = "Game"
    end

    return v328
end
t1.LogoFile = "NEXUS" .. "/logo.png"
t1.LogoFileLight = "NEXUS" .. "/logo-light.png"
local n1 = 620
local n2 = 430
local n3 = 152
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService, Stats, ProximityPromptService, ReplicatedStorage, LocalPlayer, v40, v41, u42, u43, u44, str, v48, v49, v50, v51, t2
local t3, t4, t5, t6, t7, t9, t10, t11, t12, u66, u67, u68, u69, u70, u71, t14
local v73, u75, u76, v79, self, v82, v83, v84, v85, v87, v98, v103, v108, v113, v151, v194
local v199, v217, v228, v229, v245, v250, v259, v261, v262, v263, u265, u266, v268, v270, v272, v274
local v277, v278, v279, v280, v281, v282, u284, v287, v288, v289, v290, v291, v292, v293
do
    local t8, t13, v81, v86

    do
        local t26, v94

        do
            local TweenService = game:GetService("TweenService")

            HttpService = game:GetService("HttpService")
            Stats = game:GetService("Stats")
            ProximityPromptService = game:GetService("ProximityPromptService")
            ReplicatedStorage = game:GetService("ReplicatedStorage")

            local GuiService = game:GetService("GuiService")

            LocalPlayer = Players.LocalPlayer

            if not LocalPlayer then
                pcall(function()
                    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
                end)
                LocalPlayer = Players.LocalPlayer
            end

            function v40()
                if UserInputService.VREnabled then
                    return false
                end
                local u338 = false
                pcall(function()
                    u338 = GuiService:IsTenFootInterface()
                end)
                if u338 then
                    return false
                end
                if UserInputService.TouchEnabled then
                    return true
                end
                if UserInputService.MouseEnabled == false then
                    return true
                end
                local u339 = false
                local u340 = false
                pcall(function()
                    u339 = UserInputService.GyroscopeEnabled == true
                end)
                pcall(function()
                    u340 = UserInputService.AccelerometerEnabled == true
                end)
                if u339 or u340 then
                    return true
                end
                local PreferredInput
                local LastInputType
                pcall(function()
                    PreferredInput = UserInputService.PreferredInput
                end)
                pcall(function()
                    LastInputType = UserInputService:GetLastInputType()
                end)
                if PreferredInput == Enum.PreferredInput.Touch or LastInputType == Enum.UserInputType.Touch then
                    return true
                end
                local v343 = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
                if v343 and (v343:FindFirstChild("TouchGui", true) or v343:FindFirstChild("TouchControlFrame", true) or v343:FindFirstChild("JumpButton", true) or v343:FindFirstChild("DynamicThumbstickFrame", true)) then
                    return true
                end

                return false
            end
            function v41()
                local CurrentCamera = workspace.CurrentCamera
                local v345 = if not CurrentCamera then Vector2.new(1280, 720) else CurrentCamera.ViewportSize
                local v346 = math.floor(math.clamp(v345.X * 0.7, 440, 560))
                local v347 = math.floor(math.clamp(v345.Y * 0.74, 340, 410))

                if v345.X > 80 then
                    v346 = math.min(v346, v345.X - 36)
                end

                if v345.Y > 80 then
                    v347 = math.min(v347, v345.Y - 36)
                end

                return math.max(400, v346), math.max(320, v347)
            end

            u42 = v40()
            u43 = false
            u44 = nil

            if u42 then
                local v45, v46 = v41()

                n1 = v45
                n2 = v46
                n3 = 128
            end

            str = tostring(LocalPlayer and LocalPlayer.UserId or 0)
            v48 = "PH_UI_" .. str
            v49 = "NEXUSWorldGui_" .. str

            function v50()
                return getgenv and getgenv() or _G
            end
            function v51()
                local v350 = getgenv and getgenv() or _G
                local NEXUSHUB = v350.NEXUSHUB

                if type(NEXUSHUB) ~= "table" then
                    NEXUSHUB = {
						slots = {}
					}
                    v350.NEXUSHUB = NEXUSHUB
                end

                if type(NEXUSHUB.slots) ~= "table" then
                    NEXUSHUB.slots = {}
                end

                local v352 = NEXUSHUB.slots[str]

                if type(v352) ~= "table" then
                    v352 = {}
                    NEXUSHUB.slots[str] = v352
                end

                return v352
            end

            t1.ConfigFile = (("NEXUS" .. "/" .. v26(t1.Game)) .. "/cache") .. "/" .. v26(LocalPlayer and LocalPlayer.Name or "Player") .. "-config.json"
            t2 = {
				Dark = {
					bg = Color3.fromRGB(3, 8, 18),
					rail = Color3.fromRGB(5, 12, 25),
					card = Color3.fromRGB(8, 18, 35),
					lift = Color3.fromRGB(12, 27, 49),
					fill = Color3.fromRGB(16, 36, 63),
					line = Color3.fromRGB(30, 74, 116),
					text = Color3.fromRGB(240, 247, 255),
					dim = Color3.fromRGB(145, 171, 200),
					mute = Color3.fromRGB(92, 116, 145),
					accent = Color3.fromRGB(74, 178, 255),
					accentDeep = Color3.fromRGB(22, 86, 145),
					accentHover = Color3.fromRGB(110, 201, 255),
					ink = Color3.fromRGB(3, 10, 19),
					ok = Color3.fromRGB(92, 204, 150),
					NEXUS = Color3.fromRGB(240, 247, 255)
				},
				Light = {
					bg = Color3.fromRGB(228, 237, 248),
					rail = Color3.fromRGB(221, 232, 245),
					card = Color3.fromRGB(248, 251, 255),
					lift = Color3.fromRGB(235, 243, 252),
					fill = Color3.fromRGB(215, 229, 243),
					line = Color3.fromRGB(178, 201, 225),
					text = Color3.fromRGB(17, 31, 49),
					dim = Color3.fromRGB(74, 101, 132),
					mute = Color3.fromRGB(101, 127, 156),
					accent = Color3.fromRGB(24, 126, 221),
					accentDeep = Color3.fromRGB(15, 88, 160),
					accentHover = Color3.fromRGB(43, 148, 239),
					ink = Color3.fromRGB(248, 251, 255),
					ok = Color3.fromRGB(42, 151, 104),
					NEXUS = Color3.fromRGB(17, 31, 49)
				}
			}
            t3 = {}

            for k, v in pairs(t2.Dark) do
                t3[k] = v
            end

            t4 = {
				title = Enum.Font.BuilderSansBold,
				mid = Enum.Font.BuilderSansMedium,
				body = Enum.Font.BuilderSans,
				mono = Enum.Font.RobotoMono
			}
            t5 = {
				"Forest",
				"Desert",
				"Lake",
				"Jungle",
				"Snow",
				"Volcano",
				"Prehistoric",
				"Cosmic",
				"Abyss Ocean",
				"Cherry Blossom"
			}
            t6 = {
				"Common",
				"Uncommon",
				"Rare",
				"Epic",
				"Legendary",
				"Mythic",
				"Cosmic",
				"Secret",
				"Eternal",
				"Divine",
				"Titan"
			}
            t7 = {
				"Golden",
				"Rainbow",
				"Galaxy",
				"Crystal",
				"Bloom"
			}
            t8 = {
				About = "info",
				["Auto Steal"] = "egg",
				Plot = "grid",
				Serverhop = "rocket",
				Misc = "layers",
				Webhook = "out",
				Settings = "cog"
			}
            t9 = {}
            t10 = {}
            t11 = {}
            t12 = {}
            t13 = {}
            u66 = nil
            u67 = nil
            u68 = nil
            u69 = nil
            u70 = nil
            u71 = nil
            t14 = {}

            function v73(p2)
                if p2 then
                    t14[#t14 + 1] = p2
                end

                return p2
            end

            local t15 = {}

            u75 = nil
            u76 = nil

            local function v77(p3)
                if type(p3) ~= "string" or p3 == "" then
                    return
                end

                local t16 = {}

                if crypt then
                    t16[#t16 + 1] = crypt.base64decode
                    t16[#t16 + 1] = crypt.base64_decode
                end

                if syn and syn.crypt and syn.crypt.base64 and syn.crypt.base64.decode then
                    t16[#t16 + 1] = syn.crypt.base64.decode
                end

                if base64 and base64.decode then
                    t16[#t16 + 1] = base64.decode
                end

                if base64_decode then
                    t16[#t16 + 1] = base64_decode
                end

                for i = 1, #t16 do
                    local ok, result = pcall(t16[i], p3)

                    if ok and type(result) == "string" and #result > 64 then
                        return result
                    end
                end
            end
            local function v78(p4)
                if p4 then
                    if u76 then
                        return u76
                    end
                elseif u75 then
                    return u75
                end

                local v367 = v77(not p4 and "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")

                if not v367 then
                    return
                end

                local v368 = p4 and t1.LogoFileLight or t1.LogoFile

                if type(makefolder) == "function" then
                    pcall(makefolder, "NEXUS")
                end

                if writefile then
                    pcall(writefile, v368, v367)
                end

                if getcustomasset then
                    local ok, result = pcall(getcustomasset, v368)

                    if ok and type(result) == "string" and result ~= "" then
                        if p4 then
                            u76 = result

                            return result
                        end

                        u75 = result

                        return result
                    end
                end
            end

            function v79()
                local v371 = v78(t9.Theme == "Light")

                if not v371 then
                    return
                end

                for _, v in ipairs(t15) do
                    local Mark = v:FindFirstChild("Mark")

                    if Mark and Mark:IsA("ImageLabel") then
                        Mark.Image = v371
                        Mark.ImageColor3 = Color3.new(1, 1, 1)
                    end
                end
            end

            self = setmetatable({}, {
				__mode = "k"
			})

            function v81(p5, p6, p7, p8)
                local v379 = self[p5]

                if v379 then
                    pcall(function()
                        v379:Cancel()
                    end)
                end

                local tween = TweenService:Create(p5, TweenInfo.new(p6, p8 or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), p7)

                self[p5] = tween
                tween:Play()
                tween.Completed:Connect(function()
                    if self[p5] == tween then
                        self[p5] = nil
                    end
                end)
            end
            function v82(p9, p10, p11)
                local v384 = Instance.new(p9)

                if p10 then
                    for k, v in pairs(p10) do
                        v384[k] = v
                    end
                end

                if p11 then
                    v384.Parent = p11
                end

                return v384
            end
            function v83(p12, p13, p14)
                local v396
                local v397
                if type(p13) == "string" then
                    v396 = p13
                    v397 = t3[p13] or t3.line
                else
                    v397 = p13 or t3.line
                end
                local t17 = {
					Color = v397,
					Thickness = p14 or 1,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				}
                local UIStroke = Instance.new("UIStroke")
                if t17 then
                    for k, v in pairs(t17) do
                        UIStroke[k] = v
                    end
                end
                if p12 then
                    UIStroke.Parent = p12
                end
                if v396 then
                    UIStroke:SetAttribute("th_stroke", v396)
                end

                return UIStroke
            end
            function v84(p15, p16, p17, p18, p19)
                if p17 == nil then
                    p17 = p16
                    p18 = p16
                    p19 = p16
                end

                local t18 = {
					PaddingLeft = UDim.new(0, p16),
					PaddingTop = UDim.new(0, p17),
					PaddingRight = UDim.new(0, p18 or p16),
					PaddingBottom = UDim.new(0, p19 or p17)
				}
                local UIPadding = Instance.new("UIPadding")

                if t18 then
                    for k, v in pairs(t18) do
                        UIPadding[k] = v
                    end
                end

                if p15 then
                    UIPadding.Parent = p15
                end

                return UIPadding
            end
            function v85(p20, p21, p22)
                if type(p21) == "string" then
                    if p20 and p21 then
                        p20:SetAttribute("th_bg", p21)

                        local v418 = t3[p21]

                        if v418 and p20:IsA("GuiObject") then
                            p20.BackgroundColor3 = v418
                        end
                    end

                    p20:SetAttribute("th_hover", p22)
                end

                p20.MouseEnter:Connect(function()
                    if p20:GetAttribute("locked") then
                        return
                    end

                    p20:SetAttribute("th_over", true)

                    local v1246 = p20:GetAttribute("th_hover") or p22
                    local v1247 = type(v1246) == "string" and t3[v1246] or v1246

                    if v1247 then
                        v81(p20, 0.12, {
							BackgroundColor3 = v1247
						})
                    end
                end)
                p20.MouseLeave:Connect(function()
                    if p20:GetAttribute("locked") then
                        return
                    end

                    p20:SetAttribute("th_over", false)

                    local v1248 = p20:GetAttribute("th_bg") or p21
                    local v1249 = type(v1248) == "string" and t3[v1248] or v1248

                    if v1249 then
                        v81(p20, 0.12, {
							BackgroundColor3 = v1249
						})
                    end
                end)
            end
            function v86(p23, p24, p25, p26)
                local t19 = {
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(16, 16),
					ZIndex = p26
				}
                local Frame = Instance.new("Frame")

                if t19 then
                    for k, v in pairs(t19) do
                        Frame[k] = v
                    end
                end

                if p23 then
                    Frame.Parent = p23
                end

                local v427 = Frame

                local function v428(p27, p28, p29, p30, p31)
                    local t20 = {
						BackgroundColor3 = p25,
						BorderSizePixel = 0,
						Position = UDim2.fromOffset(p27, p28),
						Size = UDim2.fromOffset(p29, p30),
						ZIndex = p26 + 1
					}
                    local v1256 = v427
                    local Frame2 = Instance.new("Frame")

                    if t20 then
                        for k, v in pairs(t20) do
                            Frame2[k] = v
                        end
                    end

                    if v1256 then
                        Frame2.Parent = v1256
                    end

                    if p31 then
                        local t21 = {
							CornerRadius = UDim.new(0, p31 or 8)
						}
                        local UICorner = Instance.new("UICorner")

                        if t21 then
                            for k, v in pairs(t21) do
                                UICorner[k] = v
                            end
                        end

                        if Frame2 then
                            UICorner.Parent = Frame2
                        end
                    end

                    return Frame2
                end
                local function v429(p32, p33, p34, p35, p36)
                    local t22 = {
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(p32, p33),
						Size = UDim2.fromOffset(p34, p35),
						ZIndex = p26 + 1
					}
                    local v1270 = v427
                    local Frame3 = Instance.new("Frame")

                    if t22 then
                        for k, v in pairs(t22) do
                            Frame3[k] = v
                        end
                    end

                    if v1270 then
                        Frame3.Parent = v1270
                    end

                    local t23 = {
						CornerRadius = UDim.new(0, p36 or 8)
					}
                    local UICorner = Instance.new("UICorner")

                    if t23 then
                        for k, v in pairs(t23) do
                            UICorner[k] = v
                        end
                    end

                    if Frame3 then
                        UICorner.Parent = Frame3
                    end

                    v83(Frame3, p25, 1.2)

                    return Frame3
                end

                if p24 == "egg" then
                    v428(4, 2, 8, 12, 5)

                    return v427
                end

                if p24 == "aim" then
                    v429(2, 2, 12, 12, 6)
                    v428(7, 7, 2, 2, 1)
                    v428(7, 0, 2, 3, 0)
                    v428(7, 13, 2, 3, 0)
                    v428(0, 7, 3, 2, 0)
                    v428(13, 7, 3, 2, 0)

                    return v427
                end

                if p24 == "spark" then
                    v428(7, 1, 2, 14, 1)
                    v428(1, 7, 14, 2, 1)
                    v428(4, 4, 2, 2, 1)
                    v428(10, 10, 2, 2, 1)

                    return v427
                end

                if p24 == "grid" then
                    v428(1, 1, 6, 6, 2)
                    v428(9, 1, 6, 6, 2)
                    v428(1, 9, 6, 6, 2)
                    v428(9, 9, 6, 6, 2)

                    return v427
                end

                if p24 == "layers" then
                    v428(2, 3, 12, 2, 1)
                    v428(2, 7, 12, 2, 1)
                    v428(2, 11, 12, 2, 1)

                    return v427
                end

                if p24 == "out" then
                    v429(1, 3, 10, 10, 3)
                    v428(8, 2, 6, 2, 1)
                    v428(12, 2, 2, 6, 1)

                    return v427
                end

                if p24 == "cog" then
                    v429(3, 3, 10, 10, 5)
                    v428(7, 1, 2, 3, 1)
                    v428(7, 12, 2, 3, 1)
                    v428(1, 7, 3, 2, 1)
                    v428(12, 7, 3, 2, 1)

                    return v427
                end

                if p24 == "rocket" then
                    v428(6, 1, 4, 9, 2)
                    v428(7, 0, 2, 3, 1)
                    v428(4, 8, 3, 4, 1)
                    v428(9, 8, 3, 4, 1)
                    v428(7, 11, 2, 4, 1)

                    return v427
                end

                if p24 == "search" then
                    v429(1, 1, 10, 10, 5)
                    v428(9, 10, 5, 2, 1).Rotation = 40

                    return v427
                end

                if p24 == "info" then
                    v429(2, 2, 12, 12, 6)
                    v428(7, 4, 2, 2, 1)
                    v428(7, 7, 2, 5, 1)
                end

                return v427
            end
            function v87(p37, p38, p39)
                local v433 = p39 or 18
                local t24 = {
					Name = "NEXUS Hub",
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(v433, v433),
					ZIndex = p38
				}
                local Frame = Instance.new("Frame")

                if t24 then
                    for k, v in pairs(t24) do
                        Frame[k] = v
                    end
                end

                if p37 then
                    Frame.Parent = p37
                end

                local v438 = v78(false)
                local t25 = {
					Name = "Mark",
					BackgroundTransparency = 1,
					Size = UDim2.fromScale(1, 1),
					Image = v438 or "",
					ImageColor3 = Color3.new(1, 1, 1),
					ScaleType = Enum.ScaleType.Fit,
					ZIndex = p38 + 1
				}
                local ImageLabel = Instance.new("ImageLabel")

                if t25 then
                    for k, v in pairs(t25) do
                        ImageLabel[k] = v
                    end
                end

                if Frame then
                    ImageLabel.Parent = Frame
                end

                t15[#t15 + 1] = Frame

                return Frame
            end

            local function v88()
                if gethui then
                    local ok, result = pcall(gethui)

                    if ok and result then
                        return result
                    end
                end

                local CoreGui = game:GetService("CoreGui")

                if pcall(function()
                    return CoreGui:FindFirstChild("PH_UI")
                end) then
                    return CoreGui
                end

                return LocalPlayer:WaitForChild("PlayerGui")
            end

            local v89 = v88()
            local v90 = v89:FindFirstChild(v48)

            if v90 then
                v90:Destroy()
            end

            local PH_UI = v89:FindFirstChild("PH_UI")

            if PH_UI then
                local NEXUSUnloadUid = (getgenv and getgenv() or _G).NEXUSUnloadUid

                if NEXUSUnloadUid == nil or str == tostring(NEXUSUnloadUid) then
                    PH_UI:Destroy()
                end
            end

            t26 = {
				Name = v48,
				ResetOnSpawn = false,
				IgnoreGuiInset = true,
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
				DisplayOrder = 1200
			}
            v94 = v88()
        end

        local ScreenGui = Instance.new("ScreenGui")

        if t26 then
            for k, v in pairs(t26) do
                ScreenGui[k] = v
            end
        end

        if v94 then
            ScreenGui.Parent = v94
        end

        v98 = ScreenGui
        pcall(function()
            if syn and syn.protect_gui then
                syn.protect_gui(v98)
            end
        end)

        local t27 = {
			Name = "Overlay",
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.fromScale(1, 1),
			Visible = false,
			ZIndex = 80
		}
        local TextButton = Instance.new("TextButton")

        if t27 then
            for k, v in pairs(t27) do
                TextButton[k] = v
            end
        end

        if v98 then
            TextButton.Parent = v98
        end

        v103 = TextButton

        local t28 = {
			Scale = 1
		}
        local UIScale = Instance.new("UIScale")

        if t28 then
            for k, v in pairs(t28) do
                UIScale[k] = v
            end
        end

        v108 = UIScale

        local t29 = {
			Name = "Window",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(n1, n2),
			BackgroundColor3 = t3.bg,
			BorderSizePixel = 0,
			ClipsDescendants = false,
			ZIndex = 10
		}
        local Frame = Instance.new("Frame")

        if t29 then
            for k, v in pairs(t29) do
                Frame[k] = v
            end
        end

        if v98 then
            Frame.Parent = v98
        end

        v113 = Frame
    end

    do
        local t30 = {
			CornerRadius = UDim.new(0, 12)
		}
        local UICorner = Instance.new("UICorner")

        if t30 then
            for k, v in pairs(t30) do
                UICorner[k] = v
            end
        end

        if v113 then
            UICorner.Parent = v113
        end

        local s1 = "line"
        local t31 = {
			Color = t3.line or t3.line,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}
        local UIStroke = Instance.new("UIStroke")

        if t31 then
            for k, v in pairs(t31) do
                UIStroke[k] = v
            end
        end

        if v113 then
            UIStroke.Parent = v113
        end

        if s1 then
            UIStroke:SetAttribute("th_stroke", s1)
        end

        v108.Parent = v113

        if v113 then
            v113:SetAttribute("th_bg", "bg")

            local bg = t3.bg

            if bg and v113:IsA("GuiObject") then
                v113.BackgroundColor3 = bg
            end
        end

        local t32 = {
			Name = "Shadow",
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.7,
			Position = UDim2.fromOffset(8, 12),
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 9,
			BorderSizePixel = 0
		}
        local Frame = Instance.new("Frame")

        if t32 then
            for k, v in pairs(t32) do
                Frame[k] = v
            end
        end

        if v113 then
            Frame.Parent = v113
        end

        local Shadow = v113.Shadow
        local t33 = {
			CornerRadius = UDim.new(0, 14)
		}
        local UICorner2 = Instance.new("UICorner")

        if t33 then
            for k, v in pairs(t33) do
                UICorner2[k] = v
            end
        end

        if Shadow then
            UICorner2.Parent = Shadow
        end
    end

    do
        local t34 = {
			Name = "HeadBar",
			BackgroundColor3 = t3.rail,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 82),
			ZIndex = 11
		}
        local Frame = Instance.new("Frame")

        if t34 then
            for k, v in pairs(t34) do
                Frame[k] = v
            end
        end

        if v113 then
            Frame.Parent = v113
        end

        if Frame then
            Frame:SetAttribute("th_bg", "rail")

            local rail = t3.rail

            if rail and Frame:IsA("GuiObject") then
                Frame.BackgroundColor3 = rail
            end
        end

        local t35 = {
			CornerRadius = UDim.new(0, 12)
		}
        local UICorner = Instance.new("UICorner")

        if t35 then
            for k, v in pairs(t35) do
                UICorner[k] = v
            end
        end

        if Frame then
            UICorner.Parent = Frame
        end

        local t36 = {
			BackgroundColor3 = t3.rail,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 1, -16),
			Size = UDim2.new(1, 0, 0, 16),
			ZIndex = 11
		}
        local Frame4 = Instance.new("Frame")

        if t36 then
            for k, v in pairs(t36) do
                Frame4[k] = v
            end
        end

        if Frame then
            Frame4.Parent = Frame
        end

        if Frame4 then
            Frame4:SetAttribute("th_bg", "rail")

            local rail = t3.rail

            if rail and Frame4:IsA("GuiObject") then
                Frame4.BackgroundColor3 = rail
            end
        end

        local t37 = {
			Name = "Rail",
			BackgroundColor3 = t3.rail,
			BorderSizePixel = 0,
			Size = UDim2.new(0, n3, 1, 0),
			ZIndex = 11
		}
        local Frame5 = Instance.new("Frame")

        if t37 then
            for k, v in pairs(t37) do
                Frame5[k] = v
            end
        end

        if v113 then
            Frame5.Parent = v113
        end

        v151 = Frame5

        if v151 then
            v151:SetAttribute("th_bg", "rail")

            local rail = t3.rail

            if rail and v151:IsA("GuiObject") then
                v151.BackgroundColor3 = rail
            end
        end

        local t38 = {
			CornerRadius = UDim.new(0, 12)
		}
        local UICorner3 = Instance.new("UICorner")

        if t38 then
            for k, v in pairs(t38) do
                UICorner3[k] = v
            end
        end

        if v151 then
            UICorner3.Parent = v151
        end
    end

    local v171, v204, v210

    do
        local Frame, TextLabel

        do
            local t39 = {
				BackgroundColor3 = t3.rail,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -16, 0, 0),
				Size = UDim2.new(0, 16, 1, 0),
				ZIndex = 11
			}
            local Frame6 = Instance.new("Frame")

            if t39 then
                for k, v in pairs(t39) do
                    Frame6[k] = v
                end
            end

            if v151 then
                Frame6.Parent = v151
            end

            if Frame6 then
                Frame6:SetAttribute("th_bg", "rail")

                local rail = t3.rail

                if rail and Frame6:IsA("GuiObject") then
                    Frame6.BackgroundColor3 = rail
                end
            end

            local t40 = {
				BackgroundColor3 = t3.line,
				BorderSizePixel = 0,
				Position = UDim2.new(1, -1, 0, 2),
				Size = UDim2.new(0, 1, 1, -2),
				ZIndex = 12
			}
            local Frame7 = Instance.new("Frame")

            if t40 then
                for k, v in pairs(t40) do
                    Frame7[k] = v
                end
            end

            if v151 then
                Frame7.Parent = v151
            end

            if Frame7 then
                Frame7:SetAttribute("th_bg", "line")

                local line = t3.line

                if line and Frame7:IsA("GuiObject") then
                    Frame7.BackgroundColor3 = line
                end
            end

            v151.Active = true

            local t41 = {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, -18),
				Position = UDim2.fromOffset(0, 12),
				CanvasSize = UDim2.new(0, 0, 0, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollBarThickness = not u42 and 0 or 5,
				BorderSizePixel = 0,
				ZIndex = 12
			}
            local ScrollingFrame = Instance.new("ScrollingFrame")

            if t41 then
                for k, v in pairs(t41) do
                    ScrollingFrame[k] = v
                end
            end

            if v151 then
                ScrollingFrame.Parent = v151
            end

            v171 = ScrollingFrame
            v84(v171, 10, 2, 10, 12)

            local t42 = {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 3),
				SortOrder = Enum.SortOrder.LayoutOrder
			}
            local UIListLayout = Instance.new("UIListLayout")

            if t42 then
                for k, v in pairs(t42) do
                    UIListLayout[k] = v
                end
            end

            if v171 then
                UIListLayout.Parent = v171
            end

            local t43 = {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 40),
				LayoutOrder = 0,
				ZIndex = 12
			}

            Frame = Instance.new("Frame")

            if t43 then
                for k, v in pairs(t43) do
                    Frame[k] = v
                end
            end

            if v171 then
                Frame.Parent = v171
            end

            v87(Frame, 13, 28).Position = UDim2.fromOffset(0, 2)

            local t44 = {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(34, 3),
				Size = UDim2.new(1, -34, 0, 16),
				Font = t4.title,
				Text = t1.Title,
				TextColor3 = t3.text,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 13
			}

            TextLabel = Instance.new("TextLabel")

            if t44 then
                for k, v in pairs(t44) do
                    TextLabel[k] = v
                end
            end
        end

        if Frame then
            TextLabel.Parent = Frame
        end

        if TextLabel then
            TextLabel:SetAttribute("th_text", "text")

            local text = t3.text

            if text then
                TextLabel.TextColor3 = text
            end
        end

        local t45 = {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(34, 20),
			Size = UDim2.new(1, -34, 0, 12),
			Font = t4.mono,
			Text = t1.Product,
			TextColor3 = t3.mute,
			TextSize = 9,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 13
		}
        local TextLabel2 = Instance.new("TextLabel")

        if t45 then
            for k, v in pairs(t45) do
                TextLabel2[k] = v
            end
        end

        if Frame then
            TextLabel2.Parent = Frame
        end

        if TextLabel2 then
            TextLabel2:SetAttribute("th_text", "mute")

            local mute = t3.mute

            if mute then
                TextLabel2.TextColor3 = mute
            end
        end

        local t46 = {
			Name = "Main",
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(n3, 2),
			Size = UDim2.new(1, -n3, 1, -2),
			ZIndex = 11
		}
        local Frame8 = Instance.new("Frame")

        if t46 then
            for k, v in pairs(t46) do
                Frame8[k] = v
            end
        end

        if v113 then
            Frame8.Parent = v113
        end

        v194 = Frame8

        local t47 = {
			Name = "Header",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 46),
			ZIndex = 12,
			Active = true
		}
        local Frame9 = Instance.new("Frame")

        if t47 then
            for k, v in pairs(t47) do
                Frame9[k] = v
            end
        end

        if v194 then
            Frame9.Parent = v194
        end

        v199 = Frame9

        local t48 = {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 8),
			Size = UDim2.new(1, -180, 0, 18),
			Font = t4.title,
			Text = "Auto Steal",
			TextColor3 = t3.text,
			TextSize = 16,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 12
		}
        local TextLabel3 = Instance.new("TextLabel")

        if t48 then
            for k, v in pairs(t48) do
                TextLabel3[k] = v
            end
        end

        if v199 then
            TextLabel3.Parent = v199
        end

        v204 = TextLabel3

        if v204 then
            v204:SetAttribute("th_text", "text")

            local text = t3.text

            if text then
                v204.TextColor3 = text
            end
        end

        local t49 = {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 26),
			Size = UDim2.new(1, -180, 0, 14),
			Font = t4.body,
			Text = "idle",
			TextColor3 = t3.dim,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 12
		}
        local TextLabel4 = Instance.new("TextLabel")

        if t49 then
            for k, v in pairs(t49) do
                TextLabel4[k] = v
            end
        end

        if v199 then
            TextLabel4.Parent = v199
        end

        v210 = TextLabel4
    end

    if v210 then
        v210:SetAttribute("th_text", "dim")

        local dim = t3.dim

        if dim then
            v210.TextColor3 = dim
        end
    end

    local Frame, UIStroke

    do
        local function v212(p40, p41)
            local t50 = {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = t3.card,
				Position = UDim2.new(1, p41, 0.5, 2),
				Size = UDim2.fromOffset(p40, 22),
				Font = t4.mono,
				Text = "—",
				TextColor3 = t3.dim,
				TextSize = 10,
				ZIndex = 12
			}
            local v449 = v199
            local TextLabel = Instance.new("TextLabel")

            if t50 then
                for k, v in pairs(t50) do
                    TextLabel[k] = v
                end
            end

            if v449 then
                TextLabel.Parent = v449
            end

            local t51 = {
				CornerRadius = UDim.new(0, 7)
			}
            local UICorner = Instance.new("UICorner")

            if t51 then
                for k, v in pairs(t51) do
                    UICorner[k] = v
                end
            end

            if TextLabel then
                UICorner.Parent = TextLabel
            end

            local s2 = "line"
            local t52 = {
				Color = t3.line or t3.line,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}
            local UIStroke2 = Instance.new("UIStroke")

            if t52 then
                for k, v in pairs(t52) do
                    UIStroke2[k] = v
                end
            end

            if TextLabel then
                UIStroke2.Parent = TextLabel
            end

            if s2 then
                UIStroke2:SetAttribute("th_stroke", s2)
            end

            if TextLabel then
                TextLabel:SetAttribute("th_bg", "card")

                local card = t3.card

                if card and TextLabel:IsA("GuiObject") then
                    TextLabel.BackgroundColor3 = card
                end
            end

            if TextLabel then
                TextLabel:SetAttribute("th_text", "dim")

                local dim = t3.dim

                if not dim then
                    return TextLabel
                end

                TextLabel.TextColor3 = dim
            end

            return TextLabel
        end

        local t53 = {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = t3.card,
			Position = UDim2.new(1, -12, 0.5, 2),
			Size = UDim2.fromOffset(not u42 and 22 or 32, not u42 and 22 or 32),
			Font = t4.mid,
			Text = "–",
			TextColor3 = t3.dim,
			TextSize = 14,
			AutoButtonColor = false,
			ZIndex = 12
		}
        local TextButton = Instance.new("TextButton")

        if t53 then
            for k, v in pairs(t53) do
                TextButton[k] = v
            end
        end

        if v199 then
            TextButton.Parent = v199
        end

        v217 = TextButton

        local t54 = {
			CornerRadius = UDim.new(0, 7)
		}
        local UICorner = Instance.new("UICorner")

        if t54 then
            for k, v in pairs(t54) do
                UICorner[k] = v
            end
        end

        if v217 then
            UICorner.Parent = v217
        end

        local s3 = "line"
        local t55 = {
			Color = t3.line or t3.line,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}
        local UIStroke3 = Instance.new("UIStroke")

        if t55 then
            for k, v in pairs(t55) do
                UIStroke3[k] = v
            end
        end

        if v217 then
            UIStroke3.Parent = v217
        end

        if s3 then
            UIStroke3:SetAttribute("th_stroke", s3)
        end

        v85(v217, "card", "lift")

        if v217 then
            v217:SetAttribute("th_text", "dim")

            local dim = t3.dim

            if dim then
                v217.TextColor3 = dim
            end
        end

        v228 = v212(52, -54)
        v229 = v212(56, -110)

        local t56 = {
			BackgroundColor3 = t3.card,
			Position = UDim2.fromOffset(14, 46),
			Size = UDim2.new(1, -28, 0, not u42 and 28 or 36),
			ZIndex = 12
		}

        Frame = Instance.new("Frame")

        if t56 then
            for k, v in pairs(t56) do
                Frame[k] = v
            end
        end

        if v194 then
            Frame.Parent = v194
        end

        local t57 = {
			CornerRadius = UDim.new(0, 9)
		}
        local UICorner4 = Instance.new("UICorner")

        if t57 then
            for k, v in pairs(t57) do
                UICorner4[k] = v
            end
        end

        if Frame then
            UICorner4.Parent = Frame
        end

        if Frame then
            Frame:SetAttribute("th_bg", "card")

            local card = t3.card

            if card and Frame:IsA("GuiObject") then
                Frame.BackgroundColor3 = card
            end
        end

        local s4 = "line"
        local t58 = {
			Color = t3.line or t3.line,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}

        UIStroke = Instance.new("UIStroke")

        if t58 then
            for k, v in pairs(t58) do
                UIStroke[k] = v
            end
        end

        if Frame then
            UIStroke.Parent = Frame
        end

        if s4 then
            UIStroke:SetAttribute("th_stroke", s4)
        end
    end

    local v244 = UIStroke

    v245 = v86(Frame, "search", t3.mute, 13)
    v245.Position = UDim2.fromOffset(8, 6)

    local t59 = {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.fromOffset(30, 0),
		Font = t4.body,
		PlaceholderText = "Filter this page",
		PlaceholderColor3 = t3.mute,
		Text = "",
		TextColor3 = t3.text,
		TextSize = not u42 and 12 or 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		ZIndex = 13
	}
    local TextBox = Instance.new("TextBox")

    if t59 then
        for k, v in pairs(t59) do
            TextBox[k] = v
        end
    end

    if Frame then
        TextBox.Parent = Frame
    end

    v250 = TextBox

    if v250 then
        v250:SetAttribute("th_text", "text")

        local text = t3.text

        if text then
            v250.TextColor3 = text
        end
    end

    if v250 then
        v250:SetAttribute("th_placeholder", "mute")

        local mute = t3.mute

        if mute and v250:IsA("TextBox") then
            v250.PlaceholderColor3 = mute
        end
    end

    v250.Focused:Connect(function()
        v81(v244, 0.12, {
			Color = t3.accent
		})
    end)
    v250.FocusLost:Connect(function()
        v81(v244, 0.12, {
			Color = t3.line
		})
    end)

    local v253 = not u42 and 80 or 88
    local t60 = {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, v253),
		Size = UDim2.new(1, 0, 1, -v253),
		ClipsDescendants = true,
		ZIndex = 12
	}
    local Frame10 = Instance.new("Frame")

    if t60 then
        for k, v in pairs(t60) do
            Frame10[k] = v
        end
    end

    if v194 then
        Frame10.Parent = v194
    end

    local v258 = Frame10

    function v259(p42, p43)
        local t61 = {
			Name = p42,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = not u42 and 4 or 8,
			ScrollBarImageColor3 = t3.line,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 13
		}
        local v467 = v258
        local ScrollingFrame = Instance.new("ScrollingFrame")

        if t61 then
            for k, v in pairs(t61) do
                ScrollingFrame[k] = v
            end
        end

        if v467 then
            ScrollingFrame.Parent = v467
        end

        if ScrollingFrame then
            ScrollingFrame:SetAttribute("th_scroll", "line")

            local line = t3.line

            if line and ScrollingFrame:IsA("ScrollingFrame") then
                ScrollingFrame.ScrollBarImageColor3 = line
            end
        end

        v84(ScrollingFrame, 12, 4, 12, 14)

        local t62 = {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder
		}
        local UIListLayout = Instance.new("UIListLayout")

        if t62 then
            for k, v in pairs(t62) do
                UIListLayout[k] = v
            end
        end

        if ScrollingFrame then
            UIListLayout.Parent = ScrollingFrame
        end

        local t63 = {
			name = p42,
			subtitle = p43,
			scroll = ScrollingFrame,
			items = {},
			n = 0,
			card = nil,
			lastRule = nil
		}

        t12[p42] = t63
        t13[#t13 + 1] = p42

        return t63
    end

    local t64 = {}

    function v261(p44, p45, p46)
        local t65 = {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			Font = t4.mono,
			Text = p44,
			TextColor3 = t3.mute,
			TextSize = 9,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = p46,
			ZIndex = 12
		}
        local v481 = v171
        local TextLabel = Instance.new("TextLabel")

        if t65 then
            for k, v in pairs(t65) do
                TextLabel[k] = v
            end
        end

        if v481 then
            TextLabel.Parent = v481
        end

        if TextLabel then
            TextLabel:SetAttribute("th_text", "mute")

            local mute = t3.mute

            if mute then
                TextLabel.TextColor3 = mute
            end
        end

        for i, v in ipairs(p45) do
            local t66 = {
				BackgroundColor3 = t3.rail,
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, not u42 and 26 or 34),
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = p46 + i,
				ZIndex = 12
			}
            local v489 = v171
            local TextButton = Instance.new("TextButton")

            if t66 then
                for k, v2 in pairs(t66) do
                    TextButton[k] = v2
                end
            end

            if v489 then
                TextButton.Parent = v489
            end

            local v493 = TextButton
            local t67 = {
				CornerRadius = UDim.new(0, 6)
			}
            local UICorner = Instance.new("UICorner")

            if t67 then
                for k, v3 in pairs(t67) do
                    UICorner[k] = v3
                end
            end

            if v493 then
                UICorner.Parent = v493
            end

            local v498 = v86(v493, t8[v] or "layers", t3.mute, 13)

            v498.Name = "Ico"
            v498.Position = UDim2.fromOffset(6, 5)

            local t68 = {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(26, 0),
				Size = UDim2.new(1, -30, 1, 0),
				Font = t4.body,
				Text = v,
				TextColor3 = t3.dim,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 13
			}
            local TextLabel5 = Instance.new("TextLabel")

            if t68 then
                for k, v5 in pairs(t68) do
                    TextLabel5[k] = v5
                end
            end

            if v493 then
                TextLabel5.Parent = v493
            end

            if TextLabel5 then
                TextLabel5:SetAttribute("th_text", "dim")

                local dim = t3.dim

                if dim then
                    TextLabel5.TextColor3 = dim
                end
            end

            t64[v] = {
				btn = v493,
				lab = TextLabel5,
				ico = v498
			}
            v493.MouseEnter:Connect(function()
                if t64[v].on then
                    return
                end

                v81(v493, 0.12, {
					BackgroundTransparency = 0,
					BackgroundColor3 = t3.lift
				})
            end)
            v493.MouseLeave:Connect(function()
                if t64[v].on then
                    return
                end

                v81(v493, 0.12, {
					BackgroundTransparency = 1
				})
            end)
            v493.MouseButton1Click:Connect(function()
                u68(v)
            end)
        end
    end
    function v262(p47, p48)
        for _, descendant in ipairs(p47:GetDescendants()) do
            if descendant:IsA("ImageLabel") then
                descendant.ImageColor3 = p48
            elseif descendant:IsA("Frame") and descendant.BackgroundTransparency < 1 then
                descendant.BackgroundColor3 = p48
            elseif descendant:IsA("UIStroke") then
                descendant.Color = p48
            end
        end
    end
    function u68(p49)
        local v509 = t12[p49]

        if not v509 then
            return
        end

        u66 = v509

        for k, v in pairs(t64) do
            local v512 = k == p49

            v.on = v512
            v.lab.TextColor3 = v512 and t3.text or t3.dim
            v.lab.Font = v512 and t4.mid or t4.body
            v.btn.BackgroundColor3 = v512 and t3.card or t3.rail
            v.btn.BackgroundTransparency = not v512 and 1 or 0
            v262(v.ico, v512 and t3.accent or t3.mute)
        end

        for _, v in pairs(t12) do
            v.scroll.Visible = v == v509

            if v == v509 then
                v.scroll.CanvasPosition = Vector2.zero
            end
        end

        v204.Text = p49
        v210.Text = v509.subtitle or ""
        u69(v509, v250.Text)
    end
    function u69(p50, p51)
        local v517 = string.lower(p51 or "")
        local inst
        local v519 = false
        for _, v in ipairs(p50.items) do
            if v.kind == "section" then
                if inst then
                    inst.Visible = v517 == "" or v519
                end

                inst = v.inst
                v519 = false
            else
                local v522 = (v517 == "" or string.find(v.q, v517, 1, true) ~= nil) and (not v.visibleIf or v.visibleIf() or false)

                v.inst.Visible = v522

                if v522 then
                    v519 = true
                end
            end
        end
        if inst then
            inst.Visible = v517 == "" or v519
        end
    end

    v250:GetPropertyChangedSignal("Text"):Connect(function()
        if u66 then
            u69(u66, v250.Text)
        end
    end)

    function v263(p52, p53)
        p52.lastRule = nil

        local t69 = {
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundColor3 = t3.card,
			BorderSizePixel = 0
		}

        p52.n = p52.n + 1
        t69.LayoutOrder = p52.n
        t69.ZIndex = 13

        local scroll = p52.scroll
        local Frame11 = Instance.new("Frame")

        if t69 then
            for k, v in pairs(t69) do
                Frame11[k] = v
            end
        end

        if scroll then
            Frame11.Parent = scroll
        end

        local t70 = {
			CornerRadius = UDim.new(0, 8)
		}
        local UICorner = Instance.new("UICorner")

        if t70 then
            for k, v in pairs(t70) do
                UICorner[k] = v
            end
        end

        if Frame11 then
            UICorner.Parent = Frame11
        end

        local s5 = "line"
        local t71 = {
			Color = t3.line or t3.line,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}
        local UIStroke4 = Instance.new("UIStroke")

        if t71 then
            for k, v in pairs(t71) do
                UIStroke4[k] = v
            end
        end

        if Frame11 then
            UIStroke4.Parent = Frame11
        end

        if s5 then
            UIStroke4:SetAttribute("th_stroke", s5)
        end

        if Frame11 then
            Frame11:SetAttribute("th_bg", "card")

            local card = t3.card

            if card and Frame11:IsA("GuiObject") then
                Frame11.BackgroundColor3 = card
            end
        end

        local t72 = {
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0, 0),
			SortOrder = Enum.SortOrder.LayoutOrder
		}
        local UIListLayout = Instance.new("UIListLayout")

        if t72 then
            for k, v in pairs(t72) do
                UIListLayout[k] = v
            end
        end

        if Frame11 then
            UIListLayout.Parent = Frame11
        end

        local t73 = {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 26),
			LayoutOrder = 0,
			ZIndex = 14
		}
        local Frame12 = Instance.new("Frame")

        if t73 then
            for k, v in pairs(t73) do
                Frame12[k] = v
            end
        end

        if Frame11 then
            Frame12.Parent = Frame11
        end

        local t74 = {
			BackgroundColor3 = t3.accent,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(12, 12),
			Size = UDim2.fromOffset(10, 2),
			ZIndex = 15
		}
        local Frame13 = Instance.new("Frame")

        if t74 then
            for k, v in pairs(t74) do
                Frame13[k] = v
            end
        end

        if Frame12 then
            Frame13.Parent = Frame12
        end

        if Frame13 then
            Frame13:SetAttribute("th_bg", "accent")

            local accent = t3.accent

            if accent and Frame13:IsA("GuiObject") then
                Frame13.BackgroundColor3 = accent
            end
        end

        local t75 = {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(28, 0),
			Size = UDim2.new(1, -36, 1, 0),
			Font = t4.mono,
			Text = p53,
			TextColor3 = t3.dim,
			TextSize = 10,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 15
		}
        local TextLabel = Instance.new("TextLabel")

        if t75 then
            for k, v in pairs(t75) do
                TextLabel[k] = v
            end
        end

        if Frame12 then
            TextLabel.Parent = Frame12
        end

        local TextLabel6 = Frame12:FindFirstChildWhichIsA("TextLabel")

        if TextLabel6 then
            TextLabel6:SetAttribute("th_text", "dim")

            local dim = t3.dim

            if dim then
                TextLabel6.TextColor3 = dim
            end
        end

        p52.card = Frame11
        p52.items[#p52.items + 1] = {
			kind = "section",
			inst = Frame11,
			q = string.lower(p53)
		}

        return Frame11
    end

    local function v264(p54, p55, p56, p57)
        local v564 = p57 or (not u42 and 132 or 140)
        local v565 = p54.card or p54.scroll
        local v566 = not p56 and 36 or 46
        if u42 then
            v566 = not p56 and 44 or 54
        end
        local t76 = {
			BackgroundColor3 = t3.card,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, v566)
		}
        p54.n = p54.n + 1
        t76.LayoutOrder = p54.n
        t76.ZIndex = 14
        local Frame14 = Instance.new("Frame")
        if t76 then
            for k, v in pairs(t76) do
                Frame14[k] = v
            end
        end
        if v565 then
            Frame14.Parent = v565
        end
        local v571 = Frame14
        local t77 = {
			BackgroundColor3 = t3.line,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 14, 0, 0),
			Size = UDim2.new(1, -28, 0, 1),
			Visible = p54.lastRule ~= nil,
			ZIndex = 15
		}
        local Frame15 = Instance.new("Frame")
        if t77 then
            for k, v in pairs(t77) do
                Frame15[k] = v
            end
        end
        if v571 then
            Frame15.Parent = v571
        end
        p54.lastRule = Frame15
        if Frame15 then
            Frame15:SetAttribute("th_bg", "line")

            local line = t3.line

            if line and Frame15:IsA("GuiObject") then
                Frame15.BackgroundColor3 = line
            end
        end
        if v571 then
            v571:SetAttribute("th_bg", "card")

            local card = t3.card

            if card and v571:IsA("GuiObject") then
                v571.BackgroundColor3 = card
            end
        end
        v571:SetAttribute("th_hover", "lift")
        v571:SetAttribute("th_row", true)
        v571.MouseEnter:Connect(function()
            v571:SetAttribute("th_over", true)
            v81(v571, 0.1, {
				BackgroundTransparency = 0,
				BackgroundColor3 = t3.lift
			})
        end)
        v571.MouseLeave:Connect(function()
            v571:SetAttribute("th_over", false)
            v81(v571, 0.1, {
				BackgroundTransparency = 1,
				BackgroundColor3 = t3.card
			})
        end)
        local t78 = {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(12, not p56 and 10 or 6),
			Size = UDim2.new(1, -(v564 + 20), 0, 14),
			Font = t4.mid,
			Text = p55,
			TextColor3 = t3.text,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 15
		}
        local TextLabel = Instance.new("TextLabel")
        if t78 then
            for k, v in pairs(t78) do
                TextLabel[k] = v
            end
        end
        if v571 then
            TextLabel.Parent = v571
        end
        if TextLabel then
            TextLabel:SetAttribute("th_text", "text")

            local text = t3.text

            if text then
                TextLabel.TextColor3 = text
            end
        end
        local TextLabel7
        if p56 then
            local t79 = {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(12, 22),
				Size = UDim2.new(1, -(v564 + 20), 0, 20),
				Font = t4.body,
				Text = p56,
				TextColor3 = t3.dim,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextWrapped = true,
				ZIndex = 15
			}

            TextLabel7 = Instance.new("TextLabel")

            if t79 then
                for k, v in pairs(t79) do
                    TextLabel7[k] = v
                end
            end

            if v571 then
                TextLabel7.Parent = v571
            end

            if TextLabel7 then
                TextLabel7:SetAttribute("th_text", "dim")

                local dim = t3.dim

                if dim then
                    TextLabel7.TextColor3 = dim
                end
            end
        end
        local t80 = {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(v564, not u42 and 26 or 32),
			ZIndex = 16
		}
        local Frame16 = Instance.new("Frame")
        if t80 then
            for k, v in pairs(t80) do
                Frame16[k] = v
            end
        end
        if v571 then
            Frame16.Parent = v571
        end
        p54.items[#p54.items + 1] = {
			kind = "row",
			inst = v571,
			q = string.lower(p55 .. " " .. (p56 or ""))
		}

        return v571, Frame16, TextLabel7
    end

    u265 = false
    u266 = false

    local t81 = {
		ImportPaste = true,
		Flight = true,
		HopNearNight = true,
		CfgSaveName = true,
		PhoneUI = true
	}

    v268 = v51().gen or 1

    local function v269(...)
        warn("[NEXUS/cfg]", ...)
    end

    function v270()
        for k, v in pairs(t10) do
            if v and v.kind == "input" and v.box then
                pcall(function()
                    local boxText = v.box.Text

                    if type(boxText) ~= "string" then
                        return
                    end

                    if boxText ~= "" or t9[k] == nil or t9[k] == "" then
                        t9[k] = boxText
                    end
                end)
            end
        end

        local t82 = {}

        for k, v in pairs(t9) do
            if not t81[k] and (k ~= "HookUrl" or t9.ExportUrl) then
                local v597 = type(v)

                if v597 == "boolean" or v597 == "number" or v597 == "string" then
                    t82[k] = v
                elseif v597 == "table" then
                    t82[k] = v
                else
                    local ok, result = pcall(function()
                        return v.Name
                    end)

                    if ok and type(result) == "string" then
                        t82[k] = result
                    end
                end
            end
        end

        return t82
    end

    local function v271(p58, p59)
        if type(p58) ~= "string" or p58 == "" then
            return false
        end

        if type(makefolder) == "function" then
            pcall(makefolder, "NEXUS")
        end

        local v602 = "NEXUS" .. "/" .. v26(t1.Game)

        if type(makefolder) == "function" then
            pcall(makefolder, v602)
        end

        local v603 = ("NEXUS" .. "/" .. v26(t1.Game)) .. "/cache"

        if type(makefolder) == "function" then
            pcall(makefolder, v603)
        end

        local v604 = ("NEXUS" .. "/" .. v26(t1.Game)) .. "/configs"

        if type(makefolder) == "function" then
            pcall(makefolder, v604)
        end

        local v605 = p58:match("^(.*)/[^/]+$")

        if v605 and type(makefolder) == "function" then
            pcall(makefolder, v605)
        end

        local ok, result = pcall(writefile, p58, p59)

        if not ok then
            v269("write fail", p58, (tostring(result)))

            return false
        end

        return true
    end

    function v272(p60)
        if u265 and not p60 then
            return
        end

        if not writefile then
            v269("writefile missing")

            return
        end

        local ok, result = pcall(function()
            return HttpService:JSONEncode((v270()))
        end)

        if not ok or type(result) ~= "string" then
            v269("encode fail", (tostring(result)))

            return
        end

        if not v271((("NEXUS" .. "/" .. v26(t1.Game)) .. "/cache") .. "/" .. v26(LocalPlayer and LocalPlayer.Name or "Player") .. "-config.json", result) then
            v271((("NEXUS" .. "/" .. v26(t1.Game)) .. "/cache") .. "/" .. str .. "-config.json", result)
        end
    end

    local function v273(p61, p62)
        local v614 = t10[p61]

        if v614 and (v614.kind == "keybind" and type(p62) == "string") then
            local ok, result = pcall(function()
                return Enum.KeyCode[p62]
            end)

            if ok and result then
                return result
            end
        end

        if p61 == "Theme" and (p62 == "Dusk" or p62 == "dusk") then
            return "Dark"
        end

        return p62
    end

    function v274(p63, p64)
        if type(p63) ~= "table" then
            return
        end

        u265 = true

        local ok, result = pcall(function()
            if p63.NeverTraps == true then
                p63.AntiTrap = true
            end

            p63.NeverTraps = nil
            p63.RarityZones = nil
            p63.HopMinPlayers = nil
            p63.HopMaxPlayers = nil
            p63.AntiDie = nil

            if p63.StealMode == "Rarity snipe" then
                p63.StealMode = "Egg type filter"
            end

            for k, v in pairs(p63) do
                if k ~= "ImportPaste" then
                    local v1281 = v273(k, v)
                    local v1282 = t10[k]

                    if v1282 and v1282.set then
                        pcall(v1282.set, v1281)

                        if p64 and v1282.on and v1282.kind ~= "slider" and k ~= "Flight" and k ~= "CfgPreset" then
                            pcall(v1282.on, t9[k])
                        end
                    else
                        t9[k] = v1281
                    end
                end
            end
        end)

        u265 = false

        if not ok then
            v269("apply fail", (tostring(result)))
        end
    end

    local function v275(p65)
        if type(p65) ~= "string" or p65 == "" or not readfile then
            return
        end

        local ok, result = pcall(readfile, p65)

        if ok and type(result) == "string" and result ~= "" then
            local ok2, result2 = pcall(function()
                return HttpService:JSONDecode(result)
            end)

            if ok2 and type(result2) == "table" then
                return result2, p65
            end
        end
    end
    local function v276()
        local t83 = { "default" }
        local t84 = {
			default = true
		}

        if type(listfiles) == "function" then
            local ok, result = pcall(listfiles, ("NEXUS" .. "/" .. v26(t1.Game)) .. "/configs")

            if ok and type(result) == "table" then
                for i = 1, #result do
                    local v631 = tostring(result[i] or ""):gsub("\\", "/"):match("([^/]+)%.json$")

                    if v631 and not t84[v631] then
                        t84[v631] = true
                        t83[#t83 + 1] = v631
                    end
                end
            end
        elseif type(isfile) == "function" then
            local v632 = tostring(t9.CfgPreset or ""):gsub("^%s+", ""):gsub("%s+$", "")
            local v633 = if v632 ~= "" then v26(v632) else "default"

            if v633 ~= "default" and not t84[v633] then
                t83[#t83 + 1] = v633
            end
        end

        table.sort(t83, function(p66, p67)
            if p66 == "default" then
                return true
            end

            if p67 == "default" then
                return false
            end

            return p66 < p67
        end)

        return t83
    end

    function v277()
        local CfgPreset = t10.CfgPreset

        if not CfgPreset or not CfgPreset.options then
            return
        end

        local v635 = v276()

        for i = #CfgPreset.options, 1, -1 do
            CfgPreset.options[i] = nil
        end

        for i = 1, #v635 do
            CfgPreset.options[i] = v635[i]
        end

        local v638 = tostring(t9.CfgPreset or ""):gsub("^%s+", ""):gsub("%s+$", "")
        local v639 = if v638 ~= "" then v26(v638) else "default"
        local v640 = false

        for i = 1, #v635 do
            if v639 == v635[i] then
                v640 = true

                break
            end
        end

        if not v640 then
            v639 = "default"
            t9.CfgPreset = v639
        end

        if CfgPreset.set then
            pcall(CfgPreset.set, v639)

            return
        end

        if CfgPreset.refresh then
            pcall(CfgPreset.refresh)
        end
    end
    function v278(p68)
        local v643 = tostring(p68 or ""):gsub("^%s+", ""):gsub("%s+$", "")
        local v644 = if v643 ~= "" then v26(v643) else "default"
        local ok, result = pcall(function()
            return HttpService:JSONEncode((v270()))
        end)

        if not ok or type(result) ~= "string" then
            v269("named encode fail", (tostring(result)))

            return false
        end

        local v647 = v271
        local v648 = ("NEXUS" .. "/" .. v26(t1.Game)) .. "/configs"
        local v649 = tostring(v644 or ""):gsub("^%s+", ""):gsub("%s+$", "")

        if not v647(v648 .. "/" .. ((if v649 ~= "" then v26(v649) else "default")) .. ".json", result) then
            return false
        end

        t9.CfgPreset = v644
        v277()
        v269("saved named", v644)

        return true
    end
    function v279(p69, p70)
        local v652 = tostring(p69 or ""):gsub("^%s+", ""):gsub("%s+$", "")
        local v653 = if v652 ~= "" then v26(v652) else "default"
        local v654 = v275
        local v655 = ("NEXUS" .. "/" .. v26(t1.Game)) .. "/configs"
        local v656 = tostring(v653 or ""):gsub("^%s+", ""):gsub("%s+$", "")
        local v657, v658 = v654(v655 .. "/" .. ((if v656 ~= "" then v26(v656) else "default")) .. ".json")

        if not v657 then
            v269("no named config", v653)

            return false
        end

        v274(v657, p70)
        t9.Flight = false

        if t10.Flight and t10.Flight.set then
            pcall(t10.Flight.set, false)
        end

        t9.CfgPreset = v653
        u71(t9.Theme or "Dark")

        local num = tonumber(t9.UIScale)

        if num then
            v108.Scale = num / 100
        end

        v272(true)
        v269("loaded named", v658)

        return true
    end
    function v280(p71)
        if not readfile then
            v269("readfile missing")

            return false
        end

        local v661, v662 = v275((("NEXUS" .. "/" .. v26(t1.Game)) .. "/cache") .. "/" .. v26(LocalPlayer and LocalPlayer.Name or "Player") .. "-config.json")

        if not v661 then
            v661, v662 = v275((("NEXUS" .. "/" .. v26(t1.Game)) .. "/cache") .. "/" .. str .. "-config.json")
        end

        if not v661 then
            local v663 = v275
            local v664 = ("NEXUS" .. "/" .. v26(t1.Game)) .. "/configs"
            local v665 = tostring("default" or ""):gsub("^%s+", ""):gsub("%s+$", "")

            v661, v662 = v663(v664 .. "/" .. ((if v665 ~= "" then v26(v665) else "default")) .. ".json")
        end

        if not v661 then
            local t85 = {
				("NEXUS" .. "/" .. v26(t1.Game)) .. "/config.json",
				"NEXUS" .. "/config.json",
				"NEXUS" .. "/" .. t1.Game .. "/config.json",
				("NEXUS" .. "/" .. v26(t1.Game)) .. "/NEXUS.json",
				"NEXUS" .. "/NEXUS.json",
				"NEXUS.json"
			}

            for i = 1, #t85 do
                v661, v662 = v275(t85[i])

                if v661 then
                    break
                end
            end
        end

        if not v661 then
            v277()

            return false
        end

        v274(v661, p71)
        t9.Flight = false

        if t10.Flight and t10.Flight.set then
            pcall(t10.Flight.set, false)
        end

        u71(t9.Theme or "Dark")

        local num = tonumber(t9.UIScale)

        if num then
            v108.Scale = num / 100
        end

        if t9.StartMin then
            u70(false)
        end

        for k, v in pairs(t10) do
            if v and v.set and t9[k] ~= nil then
                if v.kind == "toggle" then
                    pcall(v.set, t9[k] == true)
                elseif v.kind == "choice" or v.kind == "dropdown" or v.kind == "input" or v.kind == "slider" then
                    pcall(v.set, t9[k])
                end
            end
        end

        if u66 then
            u69(u66, v250.Text)
        end

        v277()

        if v662 ~= (("NEXUS" .. "/" .. v26(t1.Game)) .. "/cache") .. "/" .. v26(LocalPlayer and LocalPlayer.Name or "Player") .. "-config.json" then
            v272(true)
        end

        v269("loaded", v662)

        return true
    end
    function v281(p72, p73, p74, p75, p76, p77)
        t9[p73] = not not p76

        local v681 = (not p77 or not p77.options) and 132 or 214

        if u42 then
            v681 = (not p77 or not p77.options) and 148 or 220
        end

        local _, v683, v684 = v264(p72, p74, p75, v681)

        if p77 and p77.options then
            t9[p77.flag] = t9[p77.flag] or p77.options[1]

            local t86 = {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = t3.fill,
				Position = UDim2.new(1, -40, 0.5, 0),
				Size = UDim2.fromOffset(72, 22),
				Font = t4.mid,
				Text = tostring(t9[p77.flag]) .. " ▾",
				TextColor3 = t3.text,
				TextSize = 10,
				TextTruncate = Enum.TextTruncate.AtEnd,
				AutoButtonColor = false,
				ZIndex = 17
			}
            local TextButton = Instance.new("TextButton")

            if t86 then
                for k, v in pairs(t86) do
                    TextButton[k] = v
                end
            end

            if v683 then
                TextButton.Parent = v683
            end

            local v689 = TextButton
            local t87 = {
				CornerRadius = UDim.new(0, 6)
			}
            local UICorner = Instance.new("UICorner")

            if t87 then
                for k, v in pairs(t87) do
                    UICorner[k] = v
                end
            end

            if v689 then
                UICorner.Parent = v689
            end

            local s6 = "line"
            local t88 = {
				Color = t3.line or t3.line,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}
            local UIStroke5 = Instance.new("UIStroke")

            if t88 then
                for k, v in pairs(t88) do
                    UIStroke5[k] = v
                end
            end

            if v689 then
                UIStroke5.Parent = v689
            end

            if s6 then
                UIStroke5:SetAttribute("th_stroke", s6)
            end

            if v689 then
                v689:SetAttribute("th_bg", "fill")

                local fill = t3.fill

                if fill and v689:IsA("GuiObject") then
                    v689.BackgroundColor3 = fill
                end
            end

            if v689 then
                v689:SetAttribute("th_text", "text")

                local text = t3.text

                if text then
                    v689.TextColor3 = text
                end
            end

            v689.MouseButton1Click:Connect(function()
                if u67 then
                    u67(v689, p77.flag, p77.options)
                end
            end)
            t10[p77.flag] = {
				kind = "choice",
				chip = v689,
				set = function(p78)
                t9[p77.flag] = p78
                v689.Text = tostring(p78) .. " ▾"

                if u265 then
                    return
                end

                if u266 then
                    return
                end

                u266 = true

                local v1286 = v268

                task.delay(0.35, function()
                    u266 = false

                    if v1286 ~= (v51().gen or 0) then
                        return
                    end

                    v272()
                end)
            end
			}
        end

        local t89 = {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = t9[p73] and t3.accent or t3.fill,
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.fromOffset(not u42 and 34 or 42, not u42 and 18 or 24),
			Text = "",
			AutoButtonColor = false,
			ZIndex = 17
		}
        local TextButton = Instance.new("TextButton")

        if t89 then
            for k, v in pairs(t89) do
                TextButton[k] = v
            end
        end

        if v683 then
            TextButton.Parent = v683
        end

        local v705 = TextButton
        local v706 = not u42 and 9 or 12
        local t90 = {
			CornerRadius = UDim.new(0, v706 or 8)
		}
        local UICorner = Instance.new("UICorner")

        if t90 then
            for k, v in pairs(t90) do
                UICorner[k] = v
            end
        end

        if v705 then
            UICorner.Parent = v705
        end

        local v711 = v83(v705, t9[p73] and t3.accent or t3.line, 1)
        local v712 = u42 and UDim2.new(1, -20, 0.5, -8) or UDim2.new(1, -16, 0.5, -6)
        local uDim2 = UDim2.fromOffset(2, 2)
        local v714 = not u42 and 14 or 16
        local t91 = {
			BackgroundColor3 = t9[p73] and t3.ink or t3.text,
			Position = t9[p73] and v712 or uDim2,
			Size = UDim2.fromOffset(v714, v714),
			ZIndex = 18
		}
        local Frame17 = Instance.new("Frame")

        if t91 then
            for k, v in pairs(t91) do
                Frame17[k] = v
            end
        end

        if v705 then
            Frame17.Parent = v705
        end

        local v719 = Frame17
        local v720 = not u42 and 7 or 8
        local t92 = {
			CornerRadius = UDim.new(0, v720 or 8)
		}
        local UICorner5 = Instance.new("UICorner")

        if t92 then
            for k, v in pairs(t92) do
                UICorner5[k] = v
            end
        end

        if v719 then
            UICorner5.Parent = v719
        end

        local function v725(p79)
            v81(v705, 0.16, {
				BackgroundColor3 = p79 and t3.accent or t3.fill
			}, Enum.EasingStyle.Quart)
            v81(v719, 0.16, {
				Position = p79 and v712 or uDim2,
				BackgroundColor3 = p79 and t3.ink or t3.text
			}, Enum.EasingStyle.Quart)
            v81(v711, 0.16, {
				Color = p79 and t3.accent or t3.line
			})
        end

        v705.MouseButton1Click:Connect(function()
            local v1288 = not t9[p73]

            t9[p73] = v1288
            v725(v1288)

            if not u265 and not u266 then
                u266 = true

                local v1289 = v268

                task.delay(0.35, function()
                    u266 = false

                    if v1289 ~= (v51().gen or 0) then
                        return
                    end

                    v272()
                end)
            end

            local v1290 = t10[p73]

            task.defer(function()
                if v1290 and v1290.on then
                    pcall(v1290.on, v1288)
                end
            end)
        end)
        t10[p73] = {
			kind = "toggle",
			status = v684,
			set = function(p80)
            t9[p73] = not not p80
            v725(t9[p73])
        end
		}
    end
    function v282(p81, p82, p83, p84, p85, p86, p87, p88)
        t9[p82] = p87

        local v734, v735, v736 = v264(p81, p83, p84)

        v734.Size = UDim2.new(1, 0, 0, 72)
        v735.Size = UDim2.fromOffset(148, 48)

        local t93 = {
			BackgroundColor3 = t3.fill,
			Size = UDim2.new(1, 0, 0, 20),
			Font = t4.mono,
			Text = tostring(p87) .. (p88 or ""),
			TextColor3 = t3.accent,
			TextSize = 12,
			ZIndex = 17
		}
        local TextLabel = Instance.new("TextLabel")

        if t93 then
            for k, v in pairs(t93) do
                TextLabel[k] = v
            end
        end

        if v735 then
            TextLabel.Parent = v735
        end

        local v741 = TextLabel
        local t94 = {
			CornerRadius = UDim.new(0, 5)
		}
        local UICorner = Instance.new("UICorner")

        if t94 then
            for k, v in pairs(t94) do
                UICorner[k] = v
            end
        end

        if v741 then
            UICorner.Parent = v741
        end

        if v741 then
            v741:SetAttribute("th_bg", "fill")

            local fill = t3.fill

            if fill and v741:IsA("GuiObject") then
                v741.BackgroundColor3 = fill
            end
        end

        if v741 then
            v741:SetAttribute("th_text", "accent")

            local accent = t3.accent

            if accent then
                v741.TextColor3 = accent
            end
        end

        local t95 = {
			BackgroundColor3 = t3.fill,
			Position = UDim2.fromOffset(0, 32),
			Size = UDim2.new(1, 0, 0, 10),
			ZIndex = 17,
			Active = true
		}
        local Frame18 = Instance.new("Frame")

        if t95 then
            for k, v in pairs(t95) do
                Frame18[k] = v
            end
        end

        if v735 then
            Frame18.Parent = v735
        end

        local v752 = Frame18
        local t96 = {
			CornerRadius = UDim.new(0, 5)
		}
        local UICorner6 = Instance.new("UICorner")

        if t96 then
            for k, v in pairs(t96) do
                UICorner6[k] = v
            end
        end

        if v752 then
            UICorner6.Parent = v752
        end

        local t97 = {
			BackgroundColor3 = t3.accent,
			Size = UDim2.new((p87 - p85) / math.max(p86 - p85, 1), 0, 1, 0),
			ZIndex = 18
		}
        local Frame19 = Instance.new("Frame")

        if t97 then
            for k, v in pairs(t97) do
                Frame19[k] = v
            end
        end

        if v752 then
            Frame19.Parent = v752
        end

        local v761 = Frame19
        local t98 = {
			CornerRadius = UDim.new(0, 5)
		}
        local UICorner7 = Instance.new("UICorner")

        if t98 then
            for k, v in pairs(t98) do
                UICorner7[k] = v
            end
        end

        if v761 then
            UICorner7.Parent = v761
        end

        local t99 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = t3.text,
			Position = UDim2.new((p87 - p85) / math.max(p86 - p85, 1), 0, 0.5, 0),
			Size = UDim2.fromOffset(18, 18),
			ZIndex = 19
		}
        local Frame20 = Instance.new("Frame")

        if t99 then
            for k, v in pairs(t99) do
                Frame20[k] = v
            end
        end

        if v752 then
            Frame20.Parent = v752
        end

        local v770 = Frame20
        local t100 = {
			CornerRadius = UDim.new(0, 9)
		}
        local UICorner8 = Instance.new("UICorner")

        if t100 then
            for k, v in pairs(t100) do
                UICorner8[k] = v
            end
        end

        if v770 then
            UICorner8.Parent = v770
        end

        local s7 = "accentDeep"
        local t101 = {
			Color = t3.accentDeep or t3.line,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}
        local UIStroke6 = Instance.new("UIStroke")

        if t101 then
            for k, v in pairs(t101) do
                UIStroke6[k] = v
            end
        end

        if v770 then
            UIStroke6.Parent = v770
        end

        if s7 then
            UIStroke6:SetAttribute("th_stroke", s7)
        end

        local t102 = {
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Active = true,
			Position = UDim2.fromOffset(0, 20),
			Size = UDim2.new(1, 0, 0, 32),
			ZIndex = 21
		}
        local TextButton = Instance.new("TextButton")

        if t102 then
            for k, v in pairs(t102) do
                TextButton[k] = v
            end
        end

        if v735 then
            TextButton.Parent = v735
        end

        local function v784(p89)
            local num = tonumber(p89)

            if not num then
                return
            end

            local v1294 = math.clamp(math.floor(num + 0.5), p85, p86)

            t9[p82] = v1294

            local v1295 = (v1294 - p85) / math.max(p86 - p85, 1)

            v761.Size = UDim2.new(v1295, 0, 1, 0)
            v770.Position = UDim2.new(v1295, 0, 0.5, 0)
            v741.Text = tostring(v1294) .. (p88 or "")

            if u265 then
                return
            end

            local v1296 = t10[p82]

            if v1296 and v1296.on then
                pcall(v1296.on, v1294)
            end

            if u265 then
                return
            end

            if u266 then
                return
            end

            u266 = true

            local v1297 = v268

            task.delay(0.35, function()
                u266 = false

                if v1297 ~= (v51().gen or 0) then
                    return
                end

                v272()
            end)
        end

        local u785 = false

        TextButton.InputBegan:Connect(function(input)
            local UserInputType = input.UserInputType

            if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.Touch then
                u785 = true

                if p81 and p81.scroll then
                    p81.scroll.ScrollingEnabled = false
                end

                if v171 then
                    v171.ScrollingEnabled = false
                end

                local PositionX = input.Position.X
                local v1304 = math.clamp((PositionX - v752.AbsolutePosition.X) / math.max(v752.AbsoluteSize.X, 1), 0, 1)

                v784(p85 + v1304 * (p86 - p85))
            end
        end)

        local connection = UserInputService.InputChanged:Connect(function(input)
            if u785 then
                local UserInputType = input.UserInputType

                if UserInputType == Enum.UserInputType.MouseMovement or UserInputType == Enum.UserInputType.Touch then
                    local PositionX = input.Position.X
                    local v1308 = math.clamp((PositionX - v752.AbsolutePosition.X) / math.max(v752.AbsoluteSize.X, 1), 0, 1)

                    v784(p85 + v1308 * (p86 - p85))
                end
            end
        end)

        if connection then
            t14[#t14 + 1] = connection
        end

        local connection2 = UserInputService.InputEnded:Connect(function(input)
            if u785 then
                local UserInputType = input.UserInputType

                if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.Touch then
                    u785 = false

                    if p81 and p81.scroll then
                        p81.scroll.ScrollingEnabled = true
                    end

                    if v171 then
                        v171.ScrollingEnabled = true
                    end
                end
            end
        end)

        if connection2 then
            t14[#t14 + 1] = connection2
        end

        t10[p82] = {
			kind = "slider",
			status = v736,
			set = v784
		}
    end

    local v283 = v82("Frame", {
		Name = "Drops",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		ZIndex = 90
	}, v98)

    function u284()
        v283:ClearAllChildren()
        v283.Visible = false
    end

    v103.MouseButton1Click:Connect(function()
        u284()
        v103.Visible = false
    end)

    function u67(p90, p91, p92)
        u284()
        v103.Visible = true
        v103.ZIndex = 85
        v283.Visible = true

        local AbsolutePosition = p90.AbsolutePosition
        local AbsoluteSize = p90.AbsoluteSize
        local t103 = {
			BackgroundColor3 = t3.card,
			Position = UDim2.fromOffset(AbsolutePosition.X, AbsolutePosition.Y + AbsoluteSize.Y + 6),
			Size = UDim2.fromOffset(math.max(AbsoluteSize.X, 120), #p92 * 28 + 10),
			ZIndex = 95
		}
        local v794 = v283
        local Frame21 = Instance.new("Frame")

        if t103 then
            for k, v in pairs(t103) do
                Frame21[k] = v
            end
        end

        if v794 then
            Frame21.Parent = v794
        end

        local t104 = {
			CornerRadius = UDim.new(0, 10)
		}
        local UICorner = Instance.new("UICorner")

        if t104 then
            for k, v in pairs(t104) do
                UICorner[k] = v
            end
        end

        if Frame21 then
            UICorner.Parent = Frame21
        end

        local s8 = "line"
        local t105 = {
			Color = t3.line or t3.line,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}
        local UIStroke7 = Instance.new("UIStroke")

        if t105 then
            for k, v in pairs(t105) do
                UIStroke7[k] = v
            end
        end

        if Frame21 then
            UIStroke7.Parent = Frame21
        end

        if s8 then
            UIStroke7:SetAttribute("th_stroke", s8)
        end

        if Frame21 then
            Frame21:SetAttribute("th_bg", "card")

            local card = t3.card

            if card and Frame21:IsA("GuiObject") then
                Frame21.BackgroundColor3 = card
            end
        end

        local t106 = {
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder
		}
        local UIListLayout = Instance.new("UIListLayout")

        if t106 then
            for k, v in pairs(t106) do
                UIListLayout[k] = v
            end
        end

        if Frame21 then
            UIListLayout.Parent = Frame21
        end

        v84(Frame21, 5, 5, 5, 5)

        for i, v in ipairs(p92) do
            local v814 = v == t9[p91]
            local t107 = {
				BackgroundColor3 = v814 and t3.lift or t3.card,
				Size = UDim2.new(1, 0, 0, 24),
				Font = t4.body,
				Text = "  " .. v,
				TextColor3 = v814 and t3.accent or t3.text,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutoButtonColor = false,
				LayoutOrder = i,
				ZIndex = 97
			}
            local TextButton = Instance.new("TextButton")

            if t107 then
                for k, v8 in pairs(t107) do
                    TextButton[k] = v8
                end
            end

            if Frame21 then
                TextButton.Parent = Frame21
            end

            local t108 = {
				CornerRadius = UDim.new(0, 6)
			}
            local UICorner9 = Instance.new("UICorner")

            if t108 then
                for k, v9 in pairs(t108) do
                    UICorner9[k] = v9
                end
            end

            if TextButton then
                UICorner9.Parent = TextButton
            end

            TextButton.MouseButton1Click:Connect(function()
                t9[p91] = v

                local v1311 = t10[p91]

                if v1311 and v1311.set then
                    v1311.set(v)
                end

                if v1311 and v1311.on then
                    pcall(v1311.on, v)
                end

                u284()
                v103.Visible = false

                if u265 then
                    return
                end

                if u266 then
                    return
                end

                u266 = true

                local v1312 = v268

                task.delay(0.35, function()
                    u266 = false

                    if v1312 ~= (v51().gen or 0) then
                        return
                    end

                    v272()
                end)
            end)
        end
    end

    local function v285(p93, p94)
        if type(p93) ~= "table" then
            return "none"
        end

        local n4 = 0
        local v826 = #p94
        local t109 = {}

        for _, v in ipairs(p93) do
            t109[v] = true
        end

        for _, v in ipairs(p94) do
            if t109[v] then
                n4 += 1
            end
        end

        if n4 == 0 then
            return "none"
        end

        if n4 == v826 then
            return "all · " .. v826
        end

        return n4 .. " / " .. v826
    end
    local function v286(p95, p96)
        local t110 = {
			BackgroundColor3 = t3.fill,
			Size = UDim2.new(1, 0, 0, 24),
			Font = t4.mid,
			Text = p96,
			TextColor3 = t3.text,
			TextSize = 11,
			TextTruncate = Enum.TextTruncate.AtEnd,
			AutoButtonColor = false,
			ZIndex = 17
		}
        local TextButton = Instance.new("TextButton")

        if t110 then
            for k, v in pairs(t110) do
                TextButton[k] = v
            end
        end

        if p95 then
            TextButton.Parent = p95
        end

        local t111 = {
			CornerRadius = UDim.new(0, 7)
		}
        local UICorner = Instance.new("UICorner")

        if t111 then
            for k, v in pairs(t111) do
                UICorner[k] = v
            end
        end

        if TextButton then
            UICorner.Parent = TextButton
        end

        local s9 = "line"
        local t112 = {
			Color = t3.line or t3.line,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}
        local UIStroke8 = Instance.new("UIStroke")

        if t112 then
            for k, v in pairs(t112) do
                UIStroke8[k] = v
            end
        end

        if TextButton then
            UIStroke8.Parent = TextButton
        end

        if s9 then
            UIStroke8:SetAttribute("th_stroke", s9)
        end

        v85(TextButton, "fill", "lift")

        if TextButton then
            TextButton:SetAttribute("th_text", "text")

            local text = t3.text

            if not text then
                return TextButton
            end

            TextButton.TextColor3 = text
        end

        return TextButton
    end

    function v287(p97, p98, p99, p100, p101, p102, p103)
        if p103 then
            t9[p98] = p102 or { unpack(p101) }
        else
            t9[p98] = p102 or p101[1]
        end

        local _, v856, v857 = v264(p97, p99, p100)
        local v858 = v286(v856, p103 and v285(t9[p98], p101) or tostring(t9[p98]))
        local t113 = {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -6, 0.5, 0),
			Size = UDim2.fromOffset(12, 12),
			Font = t4.mid,
			Text = "▾",
			TextColor3 = t3.mute,
			TextSize = 11,
			ZIndex = 18
		}
        local TextLabel = Instance.new("TextLabel")

        if t113 then
            for k, v in pairs(t113) do
                TextLabel[k] = v
            end
        end

        if v858 then
            TextLabel.Parent = v858
        end

        v858.Text = (p103 and v285(t9[p98], p101) or tostring(t9[p98])) .. "   "
        v858.MouseButton1Click:Connect(function()
            u284()
            v103.Visible = true
            v103.ZIndex = 85
            v283.Visible = true

            local AbsolutePosition = v858.AbsolutePosition
            local AbsoluteSize = v858.AbsoluteSize
            local v1315 = math.min(7, #p101) * 28 + 10
            local t114 = {
				BackgroundColor3 = t3.card,
				Position = UDim2.fromOffset(AbsolutePosition.X, AbsolutePosition.Y + AbsoluteSize.Y + 6),
				Size = UDim2.fromOffset(math.max(AbsoluteSize.X, 180), v1315),
				ZIndex = 95
			}
            local v1317 = v283
            local Frame22 = Instance.new("Frame")

            if t114 then
                for k, v in pairs(t114) do
                    Frame22[k] = v
                end
            end

            if v1317 then
                Frame22.Parent = v1317
            end

            local t115 = {
				CornerRadius = UDim.new(0, 10)
			}
            local UICorner = Instance.new("UICorner")

            if t115 then
                for k, v in pairs(t115) do
                    UICorner[k] = v
                end
            end

            if Frame22 then
                UICorner.Parent = Frame22
            end

            local s10 = "accentDeep"
            local t116 = {
				Color = t3.accentDeep or t3.line,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}
            local UIStroke9 = Instance.new("UIStroke")

            if t116 then
                for k, v in pairs(t116) do
                    UIStroke9[k] = v
                end
            end

            if Frame22 then
                UIStroke9.Parent = Frame22
            end

            if s10 then
                UIStroke9:SetAttribute("th_stroke", s10)
            end

            local t117 = {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				CanvasSize = UDim2.new(0, 0, 0, #p101 * 28),
				ScrollBarThickness = 3,
				BorderSizePixel = 0,
				ZIndex = 96
			}
            local ScrollingFrame = Instance.new("ScrollingFrame")

            if t117 then
                for k, v in pairs(t117) do
                    ScrollingFrame[k] = v
                end
            end

            if Frame22 then
                ScrollingFrame.Parent = Frame22
            end

            v84(ScrollingFrame, 5, 5, 5, 5)

            local t118 = {
				Padding = UDim.new(0, 2),
				SortOrder = Enum.SortOrder.LayoutOrder
			}
            local UIListLayout = Instance.new("UIListLayout")

            if t118 then
                for k, v in pairs(t118) do
                    UIListLayout[k] = v
                end
            end

            if ScrollingFrame then
                UIListLayout.Parent = ScrollingFrame
            end

            local t119 = {}

            if p103 and type(t9[p98]) == "table" then
                for _, v in ipairs(t9[p98]) do
                    t119[v] = true
                end
            end

            for i, v in ipairs(p101) do
                local v1343 = p103 and t119[v] or v == t9[p98]
                local t120 = {
					BackgroundColor3 = v1343 and t3.lift or t3.card,
					Size = UDim2.new(1, 0, 0, 26),
					Font = t4.body,
					Text = "   " .. v,
					TextColor3 = v1343 and t3.accent or t3.text,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
					AutoButtonColor = false,
					LayoutOrder = i,
					ZIndex = 97
				}
                local TextButton = Instance.new("TextButton")

                if t120 then
                    for k, v10 in pairs(t120) do
                        TextButton[k] = v10
                    end
                end

                if ScrollingFrame then
                    TextButton.Parent = ScrollingFrame
                end

                local v1348 = TextButton
                local t121 = {
					CornerRadius = UDim.new(0, 6)
				}
                local UICorner10 = Instance.new("UICorner")

                if t121 then
                    for k, v11 in pairs(t121) do
                        UICorner10[k] = v11
                    end
                end

                if v1348 then
                    UICorner10.Parent = v1348
                end

                v85(v1348, v1343 and t3.lift or t3.card, t3.fill)
                v1348.MouseButton1Click:Connect(function()
                    if p103 then
                        local t122 = {}

                        t119[v] = not t119[v]

                        for _, v13 in ipairs(p101) do
                            if t119[v13] then
                                t122[#t122 + 1] = v13
                            end
                        end

                        t9[p98] = t122

                        local v2687 = t119[v]

                        v1348.BackgroundColor3 = v2687 and t3.lift or t3.card
                        v1348.TextColor3 = v2687 and t3.accent or t3.text
                        v1348:SetAttribute("locked", false)
                        v858.Text = (p103 and v285(t9[p98], p101) or tostring(t9[p98])) .. "   "

                        local v2688 = t10[p98]

                        if v2688 and v2688.on then
                            pcall(v2688.on, t122)
                        end

                        if u265 then
                            return
                        end

                        if u266 then
                            return
                        end

                        u266 = true

                        local v2689 = v268

                        task.delay(0.35, function()
                            u266 = false

                            if v2689 ~= (v51().gen or 0) then
                                return
                            end

                            v272()
                        end)

                        return
                    end

                    t9[p98] = v

                    local v2690 = t10[p98]

                    if v2690 and v2690.on then
                        pcall(v2690.on, v)
                    end

                    u284()
                    v103.Visible = false
                    v858.Text = (p103 and v285(t9[p98], p101) or tostring(t9[p98])) .. "   "

                    if u265 then
                        return
                    end

                    if u266 then
                        return
                    end

                    u266 = true

                    local v2691 = v268

                    task.delay(0.35, function()
                        u266 = false

                        if v2691 ~= (v51().gen or 0) then
                            return
                        end

                        v272()
                    end)
                end)
            end
        end)
        t10[p98] = {
			kind = "dropdown",
			status = v857,
			options = p101,
			refresh = function()
            v858.Text = (p103 and v285(t9[p98], p101) or tostring(t9[p98])) .. "   "
        end,
			set = function(p104)
            t9[p98] = p104
            v858.Text = (p103 and v285(t9[p98], p101) or tostring(t9[p98])) .. "   "
        end
		}
    end
    function v288(p105, p106, p107, p108, p109, p110, p111)
        t9[p106] = p110 or ""

        local _, v871, v872 = v264(p105, p107, p108)
        local t123 = {
			BackgroundColor3 = t3.fill,
			Size = UDim2.new(1, 0, 0, 24),
			Font = t4.mono,
			Text = t9[p106],
			PlaceholderText = p109 or "",
			PlaceholderColor3 = t3.mute,
			TextColor3 = t3.text,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClearTextOnFocus = false,
			ZIndex = 17
		}
        local TextBox2 = Instance.new("TextBox")

        if t123 then
            for k, v in pairs(t123) do
                TextBox2[k] = v
            end
        end

        if v871 then
            TextBox2.Parent = v871
        end

        local v877 = TextBox2
        local t124 = {
			CornerRadius = UDim.new(0, 7)
		}
        local UICorner = Instance.new("UICorner")

        if t124 then
            for k, v in pairs(t124) do
                UICorner[k] = v
            end
        end

        if v877 then
            UICorner.Parent = v877
        end

        if v877 then
            v877:SetAttribute("th_bg", "fill")

            local fill = t3.fill

            if fill and v877:IsA("GuiObject") then
                v877.BackgroundColor3 = fill
            end
        end

        if v877 then
            v877:SetAttribute("th_text", "text")

            local text = t3.text

            if text then
                v877.TextColor3 = text
            end
        end

        if v877 then
            v877:SetAttribute("th_placeholder", "mute")

            local mute = t3.mute

            if mute and v877:IsA("TextBox") then
                v877.PlaceholderColor3 = mute
            end
        end

        local s11 = "line"
        local t125 = {
			Color = t3.line or t3.line,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		}
        local UIStroke10 = Instance.new("UIStroke")

        if t125 then
            for k, v in pairs(t125) do
                UIStroke10[k] = v
            end
        end

        if v877 then
            UIStroke10.Parent = v877
        end

        if s11 then
            UIStroke10:SetAttribute("th_stroke", s11)
        end

        local v890 = UIStroke10

        v84(v877, 8, 0, 8, 0)
        v877.Focused:Connect(function()
            v81(v890, 0.12, {
				Color = t3.accent
			})
        end)
        v877.FocusLost:Connect(function()
            v81(v890, 0.12, {
				Color = t3.line
			})
            t9[p106] = v877.Text

            local v1354 = t10[p106]

            if v1354 and v1354.on then
                pcall(v1354.on, v877.Text)
            end

            if u265 then
                return
            end

            if u266 then
                return
            end

            u266 = true

            local v1355 = v268

            task.delay(0.35, function()
                u266 = false

                if v1355 ~= (v51().gen or 0) then
                    return
                end

                v272()
            end)
        end)
        v877:GetPropertyChangedSignal("Text"):Connect(function()
            t9[p106] = v877.Text

            if u265 then
                return
            end

            if u266 then
                return
            end

            u266 = true

            local v1356 = v268

            task.delay(0.35, function()
                u266 = false

                if v1356 ~= (v51().gen or 0) then
                    return
                end

                v272()
            end)
        end)
        t10[p106] = {
			kind = "input",
			status = v872,
			box = v877,
			set = function(p112)
            t9[p106] = p112
            v877.Text = tostring(p112)
        end
		}

        local v891 = p105.items[#p105.items]

        if p111 and p111.visibleIf and v891 then
            v891.visibleIf = p111.visibleIf
        end
    end
    function v289(p113, p114, p115, p116, p117, p118, p119)
        local _, v900, v901 = v264(p113, p115, p116)
        local t126 = {
			Size = UDim2.new(1, 0, 0, 24),
			Font = t4.mid,
			Text = p117,
			TextSize = 11,
			AutoButtonColor = false,
			ZIndex = 17
		}
        local TextButton = Instance.new("TextButton")

        if t126 then
            for k, v in pairs(t126) do
                TextButton[k] = v
            end
        end

        if v900 then
            TextButton.Parent = v900
        end

        local t127 = {
			CornerRadius = UDim.new(0, 7)
		}
        local UICorner = Instance.new("UICorner")

        if t127 then
            for k, v in pairs(t127) do
                UICorner[k] = v
            end
        end

        if TextButton then
            UICorner.Parent = TextButton
        end

        if not p119 then
            local s12 = "line"
            local t128 = {
				Color = t3.line or t3.line,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}
            local UIStroke11 = Instance.new("UIStroke")

            if t128 then
                for k, v in pairs(t128) do
                    UIStroke11[k] = v
                end
            end

            if TextButton then
                UIStroke11.Parent = TextButton
            end

            if s12 then
                UIStroke11:SetAttribute("th_stroke", s12)
            end
        end

        v85(TextButton, not p119 and "fill" or "accent", not p119 and "lift" or "accentHover")

        local v915 = not p119 and "text" or "ink"

        if TextButton and v915 then
            TextButton:SetAttribute("th_text", v915)

            local v916 = t3[v915]

            if v916 then
                TextButton.TextColor3 = v916
            end
        end

        t10[p114] = {
			kind = "button",
			status = v901,
			btn = TextButton
		}
        TextButton.MouseButton1Click:Connect(function()
            if p118 then
                pcall(p118)
            end

            local v1358 = t10[p114]

            if v1358 and v1358.on then
                pcall(v1358.on)
            end
        end)
    end
    function v290(p120, p121, p122, p123, p124)
        t9[p121] = p124

        local _, v923, v924 = v264(p120, p122, p123)
        local u925 = false
        local v926 = v286(v923, p124.Name)

        v926.Font = t4.mono
        v926.MouseButton1Click:Connect(function()
            u925 = true
            v926.Text = "press"
            v926.TextColor3 = t3.accent
        end)

        local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not u925 then
                return
            end

            if input.UserInputType ~= Enum.UserInputType.Keyboard then
                return
            end

            if gameProcessed then
                return
            end

            u925 = false
            t9[p121] = input.KeyCode
            v926.Text = input.KeyCode.Name
            v926.TextColor3 = t3.text

            local v1361 = t10[p121]

            if v1361 and v1361.on then
                pcall(v1361.on, input.KeyCode)
            end

            if u265 then
                return
            end

            if u266 then
                return
            end

            u266 = true

            local v1362 = v268

            task.delay(0.35, function()
                u266 = false

                if v1362 ~= (v51().gen or 0) then
                    return
                end

                v272()
            end)
        end)

        if connection then
            t14[#t14 + 1] = connection
        end

        t10[p121] = {
			kind = "keybind",
			status = v924,
			set = function(p125)
            if type(p125) == "string" then
                local ok, result = pcall(function()
                    return Enum.KeyCode[p125]
                end)

                if ok then
                    p125 = result
                end
            end

            t9[p121] = p125

            local ok, result = pcall(function()
                return p125.Name
            end)

            v926.Text = ok and result or tostring(p125)
        end
		}
    end
    function v291(p126)
        return type(p126) == "string" and p126:match("%S") ~= nil
    end
    function v292()
        local Discord = t1.Discord

        if type(Discord) ~= "string" or Discord:match("%S") == nil then
            return
        end

        if Discord:find("discord%.", 1) or Discord:find("http", 1, true) then
            return Discord
        end

        return "discord.gg/" .. Discord
    end
    function v293(p127, p128, p129)
        local v997 = p127.card or p127.scroll
        local t129 = {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = t3.card,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0)
		}

        p127.n = p127.n + 1
        t129.LayoutOrder = p127.n
        t129.ZIndex = 14

        local Frame23 = Instance.new("Frame")

        if t129 then
            for k, v in pairs(t129) do
                Frame23[k] = v
            end
        end

        if v997 then
            Frame23.Parent = v997
        end

        local v1002 = Frame23
        local t130 = {
			BackgroundColor3 = t3.line,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 14, 0, 0),
			Size = UDim2.new(1, -28, 0, 1),
			Visible = p127.lastRule ~= nil,
			ZIndex = 15
		}
        local Frame24 = Instance.new("Frame")

        if t130 then
            for k, v in pairs(t130) do
                Frame24[k] = v
            end
        end

        if v1002 then
            Frame24.Parent = v1002
        end

        p127.lastRule = Frame24

        if Frame24 then
            Frame24:SetAttribute("th_bg", "line")

            local line = t3.line

            if line and Frame24:IsA("GuiObject") then
                Frame24.BackgroundColor3 = line
            end
        end

        if v1002 then
            v1002:SetAttribute("th_bg", "card")

            local card = t3.card

            if card and v1002:IsA("GuiObject") then
                v1002.BackgroundColor3 = card
            end
        end

        v1002:SetAttribute("th_hover", "lift")
        v1002:SetAttribute("th_row", true)
        v1002.MouseEnter:Connect(function()
            v1002:SetAttribute("th_over", true)
            v81(v1002, 0.1, {
				BackgroundTransparency = 0,
				BackgroundColor3 = t3.lift
			})
        end)
        v1002.MouseLeave:Connect(function()
            v1002:SetAttribute("th_over", false)
            v81(v1002, 0.1, {
				BackgroundTransparency = 1,
				BackgroundColor3 = t3.card
			})
        end)

        local t131 = {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 8),
			Size = UDim2.new(1, -28, 0, 14),
			Font = t4.mid,
			Text = p128,
			TextColor3 = t3.text,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 15
		}
        local TextLabel = Instance.new("TextLabel")

        if t131 then
            for k, v in pairs(t131) do
                TextLabel[k] = v
            end
        end

        if v1002 then
            TextLabel.Parent = v1002
        end

        if TextLabel then
            TextLabel:SetAttribute("th_text", "text")

            local text = t3.text

            if text then
                TextLabel.TextColor3 = text
            end
        end

        local t132 = {
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(14, 24),
			Size = UDim2.new(1, -28, 0, 0),
			Font = t4.body,
			Text = p129,
			TextColor3 = t3.dim,
			TextSize = 11,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 15
		}
        local TextLabel8 = Instance.new("TextLabel")

        if t132 then
            for k, v in pairs(t132) do
                TextLabel8[k] = v
            end
        end

        if v1002 then
            TextLabel8.Parent = v1002
        end

        if TextLabel8 then
            TextLabel8:SetAttribute("th_text", "dim")

            local dim = t3.dim

            if dim then
                TextLabel8.TextColor3 = dim
            end
        end

        local t133 = {
			PaddingBottom = UDim.new(0, 10)
		}
        local UIPadding = Instance.new("UIPadding")

        if t133 then
            for k, v in pairs(t133) do
                UIPadding[k] = v
            end
        end

        if v1002 then
            UIPadding.Parent = v1002
        end

        p127.items[#p127.items + 1] = {
			kind = "row",
			inst = v1002,
			q = string.lower(p128 .. " " .. p129)
		}
    end
end
local v294 = v259("About", "NEXUS Steal an Egg")
local v295 = v259("Auto Steal", "targeting, filters, travel")
local v296 = v259("Plot", "eggs, pets, upgrades, selling")
local v297 = v259("Serverhop", "fill a reason, then turn Auto hop on")
local v298 = v259("Misc", "esp, defence, flight")
local v299 = v259("Webhook", "outbound messages")
local v300 = v259("Settings", "window and config")
v261("About", { "About" }, 0)
v261("Autofarm", { "Auto Steal" }, 10)
v261("Other stuff", {
	"Plot",
	"Serverhop",
	"Misc"
}, 30)
v261("Config", {
	"Webhook",
	"Settings"
}, 50);
(function(p130)
    local t134 = {
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundColor3 = t3.card,
		BorderSizePixel = 0
	}

    p130.n = p130.n + 1
    t134.LayoutOrder = p130.n
    t134.ZIndex = 13

    local scroll = p130.scroll
    local Frame = Instance.new("Frame")

    if t134 then
        for k, v in pairs(t134) do
            Frame[k] = v
        end
    end

    if scroll then
        Frame.Parent = scroll
    end

    local t135 = {
		CornerRadius = UDim.new(0, 8)
	}
    local UICorner = Instance.new("UICorner")

    if t135 then
        for k, v in pairs(t135) do
            UICorner[k] = v
        end
    end

    if Frame then
        UICorner.Parent = Frame
    end

    local s13 = "line"
    local t136 = {
		Color = t3.line or t3.line,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	}
    local UIStroke = Instance.new("UIStroke")

    if t136 then
        for k, v in pairs(t136) do
            UIStroke[k] = v
        end
    end

    if Frame then
        UIStroke.Parent = Frame
    end

    if s13 then
        UIStroke:SetAttribute("th_stroke", s13)
    end

    if Frame then
        Frame:SetAttribute("th_bg", "card")

        local card = t3.card

        if card and Frame:IsA("GuiObject") then
            Frame.BackgroundColor3 = card
        end
    end

    v84(Frame, 14, 14, 14, 14)

    local t137 = {
		FillDirection = Enum.FillDirection.Vertical,
		Padding = UDim.new(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder
	}
    local UIListLayout = Instance.new("UIListLayout")

    if t137 then
        for k, v in pairs(t137) do
            UIListLayout[k] = v
        end
    end

    if Frame then
        UIListLayout.Parent = Frame
    end

    local t138 = {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 48),
		LayoutOrder = 1,
		ZIndex = 14
	}
    local Frame25 = Instance.new("Frame")

    if t138 then
        for k, v in pairs(t138) do
            Frame25[k] = v
        end
    end

    if Frame then
        Frame25.Parent = Frame
    end

    v87(Frame25, 15, 44).Position = UDim2.fromOffset(0, 2)

    local t139 = {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(54, 2),
		Size = UDim2.new(1, -54, 0, 20),
		Font = t4.title,
		Text = t1.Title .. " " .. t1.Product,
		TextColor3 = t3.text,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 15
	}
    local TextLabel = Instance.new("TextLabel")

    if t139 then
        for k, v in pairs(t139) do
            TextLabel[k] = v
        end
    end

    if Frame25 then
        TextLabel.Parent = Frame25
    end

    if TextLabel then
        TextLabel:SetAttribute("th_text", "text")

        local text = t3.text

        if text then
            TextLabel.TextColor3 = text
        end
    end

    local t140 = {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(54, 26),
		Size = UDim2.new(1, -54, 0, 20),
		ZIndex = 15
	}
    local Frame26 = Instance.new("Frame")

    if t140 then
        for k, v in pairs(t140) do
            Frame26[k] = v
        end
    end

    if Frame25 then
        Frame26.Parent = Frame25
    end

    local v979 = Frame26
    local t141 = {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center
	}
    local UIListLayout2 = Instance.new("UIListLayout")

    if t141 then
        for k, v in pairs(t141) do
            UIListLayout2[k] = v
        end
    end

    if v979 then
        UIListLayout2.Parent = v979
    end

    local function v984(p131, p132, p133)
        local t142 = {
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = t3.fill,
			Size = UDim2.fromOffset(0, 18),
			Font = t4.mono,
			Text = "  " .. p131 .. "  ",
			TextColor3 = t3[p133] or t3.dim,
			TextSize = 10,
			LayoutOrder = p132,
			ZIndex = 16
		}
        local v1373 = v979
        local TextLabel9 = Instance.new("TextLabel")

        if t142 then
            for k, v in pairs(t142) do
                TextLabel9[k] = v
            end
        end

        if v1373 then
            TextLabel9.Parent = v1373
        end

        local t143 = {
			CornerRadius = UDim.new(0, 5)
		}
        local UICorner11 = Instance.new("UICorner")

        if t143 then
            for k, v in pairs(t143) do
                UICorner11[k] = v
            end
        end

        if TextLabel9 then
            UICorner11.Parent = TextLabel9
        end

        if TextLabel9 then
            TextLabel9:SetAttribute("th_bg", "fill")

            local fill = t3.fill

            if fill and TextLabel9:IsA("GuiObject") then
                TextLabel9.BackgroundColor3 = fill
            end
        end

        local v1382 = p133 or "dim"

        if TextLabel9 then
            if not v1382 then
                return TextLabel9
            end

            TextLabel9:SetAttribute("th_text", v1382)

            local v1383 = t3[v1382]

            if not v1383 then
                return TextLabel9
            end

            TextLabel9.TextColor3 = v1383
        end

        return TextLabel9
    end

    v984("v" .. tostring(t1.Version), 1, "accent")

    local Status = t1.Status

    if type(Status) == "string" and Status:match("%S") ~= nil then
        v984(t1.Status, 2, "dim")
    end

    local Game = t1.Game

    if type(Game) == "string" and Game:match("%S") ~= nil then
        v984(t1.Game, 3, "dim")
    end

    local Tagline = t1.Tagline
    local v988 = type(Tagline) == "string" and Tagline:match("%S") ~= nil and t1.Tagline or "Autofarm, hatch eggs and other stuff"
    local t144 = {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		Font = t4.body,
		Text = v988,
		TextColor3 = t3.dim,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 2,
		ZIndex = 15
	}
    local TextLabel10 = Instance.new("TextLabel")

    if t144 then
        for k, v in pairs(t144) do
            TextLabel10[k] = v
        end
    end

    if Frame then
        TextLabel10.Parent = Frame
    end

    if TextLabel10 then
        TextLabel10:SetAttribute("th_text", "dim")

        local dim = t3.dim

        if dim then
            TextLabel10.TextColor3 = dim
        end
    end

    p130.items[#p130.items + 1] = {
		kind = "section",
		inst = Frame,
		q = string.lower(TextLabel.Text .. " " .. v988)
	}
    p130.card = nil
    p130.lastRule = nil

    return Frame
end)(v294)
v263(v294, "Features")
v293(v294, "Auto Steal", "Snatch eggs and bring them to safe zone")
v293(v294, "Plot", "Place, hatch eggs, auto sell")
v293(v294, "Serverhop", "Idle, time, or night spawn — Auto hop only leaves if one of those boxes has a number")
v293(v294, "Misc", "ESP, stats, index claim, anti trap / ragdoll, bat aura, flight, bypass speed, optimizer")
v293(v294, "Webhook", "Discord embeds with the pet/egg icon on steal, hatch, and sell")
local v301 = v292()
local v302 = v291(t1.Website)
local v303 = v291(t1.Changelog)
if v301 or v302 or v303 then
    v263(v294, "Links")

    if v301 then
        v289(v294, "CopyDiscord", "Discord", v301, "Copy", function()
            if setclipboard then
                pcall(setclipboard, v301)
            end
        end, true)
    end

    if v302 then
        v289(v294, "CopySite", "Website", t1.Website, "Copy", function()
            if setclipboard then
                pcall(setclipboard, t1.Website)
            end
        end, false)
    end

    if v303 then
        v293(v294, "What's new", t1.Changelog)
    end
end
v263(v294, "Credits")
v293(v294, "Made by", v291(t1.Author) and t1.Author or t1.Title)
if v291(t1.Credits) then
    v293(v294, "With", t1.Credits)
end
if v291(t1.Support) then
    local v304 = v292()

    if not v304 or not string.find(t1.Support, v304, 1, true) then
        v293(v294, "Support", t1.Support)
    end
end
v263(v294, "Disclaimer")
v293(v294, "Not official", "Not affiliated with " .. (t1.Game or "this game") .. ". I'm not responsible for any bans, use at your own risk !")
v263(v295, "Auto steal")
v281(v295, "AutoSteal", "Auto steal", "idle · took 0 · lost 0 · re-grabbed 0", false, {
	flag = "StealTravel",
	options = {
		"Speed",
		"Flight"
	}
})
v282(v295, "StealSpeed", "Travel speed", "Studs/s to the egg — capped at 200 for stable pickup", 50, 200, 200, " studs/s")
v263(v295, "Targeting")
v287(v295, "StealMode", "What to take", "Filters being used from below", {
	"Best value",
	"Egg type filter",
	"Gen ($/s) snipe"
}, "Best value", false)
v288(v295, "GenSnipeFloor", "Egg ($/s) snipe", "What the pet inside of the egg will pay", "any · e.g. 100m", "", {
	visibleIf = function()
    return t9.StealMode == "Gen ($/s) snipe"
end
})
v263(v295, "Where to look")
v287(v295, "Areas", "Areas", "which zones to steal from", t5, { unpack(t5) }, true)
v263(v295, "What qualifies")
v281(v295, "UseRarity", "Egg type filter", "off = any egg type counts", false)
v287(v295, "Rarities", "Egg types", "an egg counts if it is one of these", t6, { unpack(t6) }, true)
v281(v295, "UseMutation", "Use mutation filter", "off = mutated or not, both fine", false)
v287(v295, "Mutations", "Mutations", "an egg counts if it carries one of these", t7, { unpack(t7) }, true)
v288(v295, "MinWeight", "Minimum weight (Kg)", "the same Kg the game shows — blank for any", "any", "")
v263(v295, "Event")
v281(v295, "AutoEvent", "Auto Hungry Monster", "after filters: grab infested, equip, feed", false)
v288(v295, "EventKeepGen", "Don't feed if egg makes ($/s)", "keeps high-pay eggs · blank = feed any", "feed any · e.g. 5m", "")
v263(v296, "Eggs & pets")
v281(v296, "AutoPlaceEggs", "Auto place eggs", "idle · placed 0 · hatched 0", false)
v287(v296, "NeverPlaceRarity", "Never place rarer", "Keeps better eggs in inventory", {
	"Place all",
	unpack(t6)
}, "Place all", false)
v288(v296, "PlaceMinGen", "Only place eggs worth ($/s)", "pen fills with the best first — blank for any", "any · e.g. 1.5m", "")
v281(v296, "AutoHatch", "Auto hatch", "hatches every egg the moment its timer is up", false)
v281(v296, "EquipBest", "Auto place best pets", "uses the game's own equip-best", false)
v263(v296, "Upgrades")
v281(v296, "UpgTrails", "Auto upgrade trails", "idle · bought 0 · sold 0", false)
v281(v296, "UpgTreadmill", "Auto upgrade treadmill", "buys the next treadmill when you can afford it", false)
v281(v296, "UpgPen", "Auto upgrade pen", "more room for pets", false)
v288(v296, "KeepMoney", "Keep this much money", "never spend below this — blank to spend freely", "spend it all · e.g. 500m", "")
v263(v296, "Selling")
v289(v296, "SellPreview", "Preview what will sell", "opens a window under the stats panel — Hover icon to display stats", "Preview", nil, false)
v288(v296, "SellUnderGen", "Sell anything earning under ($/s)", "blank = nothing sells", "nothing sells · e.g. 250k", "")
v281(v296, "AutoSellPets", "Auto sell pets", "equips then sells at the stall · worst first · only below the floor", false)
v281(v296, "AutoSellEggs", "Auto sell eggs", "equips then sells at the stall · spare eggs only — plot eggs stay", false)
v263(v296, "Treadmill training")
v281(v296, "AutoTreadmill", "Auto treadmill", "not training · 0/s · earned 0 this session", false)
v281(v296, "TrainWhenIdle", "Train when nothing to steal", "only when Auto Steal is off. Auto Steal never wears the belt", true)
v282(v296, "ReadyEarly", "Get ready early", "Step earlier to steal", 0, 15, 4, "s before reset")
v263(v297, "Auto hop")
v281(v297, "AutoHop", "Auto hop", "off · 0 hops this session", false)
v263(v297, "Leave when")
v288(v297, "HopIdle", "No steal for (seconds)", "Auto Steal on, nothing banked. Night does not count. Min 5. Blank = off.", "off · 90", "")
v288(v297, "HopAfter", "Been here (minutes)", "leave after this long no matter what. Min 1. Blank = off.", "off · 20", "")
v263(v297, "Leave now")
v289(v297, "HopNow", "Hop now", "one hop. Auto hop can stay off.", "Hop", function()
end, true)
v263(v297, "Which servers")
v282(v297, "HopPages", "Pages to fetch", "3 is enough. more pages is slower.", 1, 10, 3, " pages")
v281(v297, "HopSkipFull", "Skip full servers", "a full server just dumps you back here", true)
v287(v297, "HopPlayers", "Players", "Lowest = emptier, Highest = fuller", {
	"Lowest",
	"Highest"
}, "Lowest", false);
(function(p134, p135)
    local v930 = p134.card or p134.scroll
    local t145 = {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0)
	}

    p134.n = p134.n + 1
    t145.LayoutOrder = p134.n
    t145.ZIndex = 14

    local Frame = Instance.new("Frame")

    if t145 then
        for k, v in pairs(t145) do
            Frame[k] = v
        end
    end

    if v930 then
        Frame.Parent = v930
    end

    local t146 = {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(14, 6),
		Size = UDim2.new(1, -28, 0, 0),
		Font = t4.body,
		Text = p135,
		TextColor3 = t3.mute,
		TextSize = 12,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 15
	}
    local TextLabel = Instance.new("TextLabel")

    if t146 then
        for k, v in pairs(t146) do
            TextLabel[k] = v
        end
    end

    if Frame then
        TextLabel.Parent = Frame
    end

    local t147 = {
		PaddingBottom = UDim.new(0, 10),
		PaddingTop = UDim.new(0, 6)
	}
    local UIPadding = Instance.new("UIPadding")

    if t147 then
        for k, v in pairs(t147) do
            UIPadding[k] = v
        end
    end

    if Frame then
        UIPadding.Parent = Frame
    end

    if TextLabel then
        TextLabel:SetAttribute("th_text", "mute")

        local mute = t3.mute

        if mute then
            TextLabel.TextColor3 = mute
        end
    end

    p134.items[#p134.items + 1] = {
		kind = "row",
		inst = Frame,
		q = string.lower(p135)
	}
end)(v297, "skips this job and recent servers — shared across accounts in this workspace")
v263(v298, "Eggs on the map")
v281(v298, "EggESP", "Egg ESP", nil, false)
v287(v298, "ESPFilter", "Show ESP on", nil, {
	"All eggs",
	"Eggs matching my filters",
	"Stolen target only"
}, "All eggs", false)
v281(v298, "ESPBeam", "Beam to current target", "line to the egg auto steal picked", false)
v263(v298, "Eggs on your plot")
v281(v298, "PlotESP", "Plot egg ESP", "payout and hatch timer — green when ready", false)
v263(v298, "Stats")
v281(v298, "StatsPanel", "Show stats panel", "draggable: money, income, pen, best pet, best egg, speed, session", false)
v281(v298, "ClaimIndex", "Auto claim index", "redeems every completed index entry in one sweep", false)
v263(v298, "Defence")
v281(v298, "AntiTrap", "Anti trap", "Disables traps", false)
v281(v298, "AntiMob", "Anti ragdoll", "guards and other players' bats cannot flop or knock you; your bat still swings", false)
v281(v298, "GuardianBypass", "Guardian bypass", "staged egg return + guard/ragdoll interception", true)
v281(v298, "StagedReturn", "Staged egg return", "teleport → drop → re-grab → teleport to ~20 studs → drop → re-grab → walk home", true)
v282(v298, "FirstReturnHop", "First return hop", "first teleport leaves the egg this many studs from SafeZone", 25, 100, 60, " studs")
v282(v298, "FinalReturnRadius", "Final SafeZone distance", "second teleport leaves the egg this many studs from SafeZone", 18, 30, 20, " studs")
v282(v298, "FinalReturnSpeed", "Final return speed", "ordinary walking speed after the second re-grab", 16, 40, 20, " studs/s")
v282(v298, "RouteGrabCooldown", "Pickup cooldown", "minimum delay between egg pickup attempts during the staged route", 0.5, 2.0, 1.1, " s")
v263(v298, "Bat")
v281(v298, "BatAura", "Bat aura", "swings at any player in range — Auto Steal also equips the bat and chases whoever took your egg", false)
v263(v298, "Walking")
v281(v298, "BypassSpeed", "Bypass speed", "off = normal walk. on = Bypass cap. Auto steal uses Travel speed only while going to an egg, not while looking", false)
v282(v298, "BypassCap", "Bypass speed cap", "studs per second while walking with bypass on", 150, 1300, 880, " studs/s")
v263(v298, "Flight")
v281(v298, "Flight", "Flight", "WASD to fly, Space up, Left Ctrl down — holds altitude when you let go", false)
v282(v298, "FlightSpeed", "Flight speed", "studs per second while flying", 150, 1300, 880, " studs/s")
v290(v298, "FlightBind", "Flight keybind", "toggles flight without opening the window", t1.FlightBind)
v263(v298, "Performance")
v281(v298, "Optimizer", "Game optimizer", "lowest gfx: shadows, particles, lights, post-fx, terrain water — off restores", false)
v282(v298, "FPSCap", "FPS cap", "0 - no fps cap", 0, 240, 0, "")
v263(v299, "Connection")
v281(v299, "HookEnabled", "Send outbound", "", false)
v288(v299, "HookUrl", "Endpoint URL", "paste a URL — never committed", "https://", "")
v289(v299, "HookTest", "Test send", "posts a sample embed to the URL above", "Send", function()
end, true)
v263(v299, "What to send")
v281(v299, "HookStolen", "Egg stolen", "icon, $/s, rarity, mutations, where it came from", true)
v281(v299, "HookHatched", "Egg hatched", "icon, $/s, rarity, weight", true)
v281(v299, "HookSold", "Sold pets or eggs", "icon and what it was earning", false)
v281(v299, "HookRewards", "Rewards claimed", "index redeem count", false)
v263(v299, "How much noise")
v288(v299, "HookMinGen", "Only eggs earning over ($/s)", "stolen and hatched — blank for everything", "everything · e.g. 50m", "")
v287(v299, "HookRarityFloor", "Rarity floor", "stolen and hatched below this rarity are skipped", {
	"Any",
	unpack(t6)
}, "Any", false)
v281(v299, "SessionDigest", "Session recap", "every 10 minutes — stolen, lost, hatched, sold, cash. not a steal ping", false)
v263(v299, "The message")
v287(v299, "HookPing", "Ping", "", {
	"No ping",
	"Here",
	"User id"
}, "No ping", false)
v288(v299, "HookUserId", "User id", "optional", "0", "")
v281(v299, "HookUsername", "Show my Roblox name and headshot", "", false)
v281(v299, "ExportUrl", "Let exported configs carry the URL", "off by default", false)
v263(v300, "Appearance")
v281(v300, "PhoneUI", "Phone layout", "compact hub for phones / emulators — leave off on PC", u42)
v282(v300, "UIScale", "UI scale", "zooms the hub — does not crush the layout", 75, 125, 100, "%")
v287(v300, "Theme", "Theme", "dark or light — mark swaps with the theme", {
	"Dark",
	"Light"
}, "Dark", false)
v263(v300, "Keybinds")
v290(v300, "OpenBind", "Open / close", "press this any time to show or hide", t1.OpenBind)
v290(v300, "FlightBind2", "Toggle flight", "same bind as the movement page", t1.FlightBind)
v281(v300, "StartMin", "Start minimised", nil, false)
v263(v300, "Config")
v287(v300, "CfgPreset", "Load config", "new accounts use default", { "default" }, "default", false)
v288(v300, "CfgSaveName", "Save as", "blank = default", "name · or leave blank", "")
v289(v300, "SaveCfgAs", "Save config", "writes NEXUS/.../configs/<name>.json", "Save", function()
    v278(t9.CfgSaveName)
end, true)
v289(v300, "ExportCfg", "Export settings", "copies config to clipboard", "Copy", function()
    v272()

    local ok, result = pcall(function()
        return HttpService:JSONEncode((v270()))
    end)

    if not ok then
        return
    end

    if setclipboard then
        pcall(setclipboard, result)
    end
end, true)
v288(v300, "ImportPaste", "Import settings", "load config from clipboard", "paste, then press Import", "")
v289(v300, "ImportCfg", "Import", nil, "Import", function()
    local ImportPaste = t9.ImportPaste

    if type(ImportPaste) ~= "string" or ImportPaste == "" then
        return
    end

    local ok, result = pcall(function()
        return HttpService:JSONDecode(ImportPaste)
    end)

    if not ok or type(result) ~= "table" then
        return
    end

    v274(result, true)
    u71(t9.Theme or "Dark")
    v272(true)
end, false)
v263(v300, "Window")
local u305
v289(v300, "ResetWin", "Reset position & size", "window and orb back to the middle at default size", "Reset", function()
    v113.Position = UDim2.fromScale(0.5, 0.5)
    v113.Size = UDim2.fromOffset(n1, n2)
    v108.Scale = 1

    if t10.UIScale and t10.UIScale.set then
        t10.UIScale.set(100)
    end

    if u42 then
        Orb.Position = UDim2.new(0, 36, 1, -88)
    else
        Orb.Position = UDim2.new(0, 40, 0.5, 0)
    end

    u305()
end, false)
function t10.UIScale.on(p136)
    v108.Scale = p136 / 100
end
function t10.PhoneUI.on(p137)
    u43 = true
    u42 = not not p137

    if u44 then
        u44()
    end
end
function t10.Theme.on(p138)
    u71(p138)
end
function t10.FlightBind2.on(p139)
    t9.FlightBind = p139
end
function t10.CfgPreset.on(p140)
    v279(p140, true)
    v277()
end
local v306 = v82("TextButton", {
	Name = "Orb",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = u42 and UDim2.new(0, 36, 1, -88) or UDim2.new(0, 40, 0.5, 0),
	Size = UDim2.fromOffset(not u42 and 34 or 48, not u42 and 34 or 48),
	BackgroundColor3 = t3.rail,
	Text = "",
	AutoButtonColor = false,
	Visible = false,
	ZIndex = 20
}, v98);
(function(p141, p142)
    local t148 = {
		CornerRadius = UDim.new(0, p142 or 8)
	}
    local UICorner = Instance.new("UICorner")

    if t148 then
        for k, v in pairs(t148) do
            UICorner[k] = v
        end
    end

    if p141 then
        UICorner.Parent = p141
    end

    return UICorner
end)(v306, not u42 and 14 or 18)
v83(v306, "accent", 1.4);
(function(p143, p144, p145)
    if not p143 or not p145 then
        return p143
    end

    p143:SetAttribute("th_" .. p144, p145)

    local v414 = t3[p145]

    if not v414 then
        return p143
    end

    if p144 == "bg" and p143:IsA("GuiObject") then
        p143.BackgroundColor3 = v414

        return p143
    end

    if p144 == "text" then
        p143.TextColor3 = v414

        return p143
    end

    if p144 == "placeholder" and p143:IsA("TextBox") then
        p143.PlaceholderColor3 = v414

        return p143
    end

    if p144 == "stroke" and p143:IsA("UIStroke") then
        p143.Color = v414

        return p143
    end

    if p144 == "scroll" and p143:IsA("ScrollingFrame") then
        p143.ScrollBarImageColor3 = v414
    end

    return p143
end)(v306, "bg", "rail")
local v307 = v87(v306, 21, 20)
v307.AnchorPoint = Vector2.new(0.5, 0.5)
v307.Position = UDim2.fromScale(0.5, 0.5)
local u308 = true
function u70(p146)
    u308 = not not p146
    v113.Visible = u308
    v306.Visible = not u308

    if not u308 then
        u284()
        v103.Visible = false
    end
end
v217.MouseButton1Click:Connect(function()
    u70(false)
end)
v306.MouseButton1Click:Connect(function()
    u70(true)
end)
local u309
local s14
local inputPosition
local Position
local AbsoluteSize
v199.InputBegan:Connect(function(input)
    local UserInputType = input.UserInputType

    if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.Touch then
        u309 = true
        s14 = "win"
        inputPosition = input.Position
        Position = v113.Position
    end
end)
v151.InputBegan:Connect(function(input)
    local UserInputType = input.UserInputType

    if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.Touch then
        u309 = true
        s14 = "win"
        inputPosition = input.Position
        Position = v113.Position
    end
end)
v306.InputBegan:Connect(function(input)
    local UserInputType = input.UserInputType

    if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.Touch then
        u309 = true
        s14 = "orb"
        inputPosition = input.Position
        Position = v306.Position
    end
end)
local v314 = v82("Frame", {
	AnchorPoint = Vector2.new(1, 1),
	BackgroundTransparency = 1,
	Position = UDim2.new(1, 0, 1, 0),
	Size = UDim2.fromOffset(not u42 and 18 or 32, not u42 and 18 or 32),
	ZIndex = 30,
	Active = true
}, v113)
for i = 0, 1 do
    v82("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -4 - i * 4, 1, -4),
		Size = UDim2.fromOffset(8 - i * 2, 1),
		BackgroundColor3 = t3.mute,
		BorderSizePixel = 0,
		ZIndex = 31
	}, v314)
end
v314.InputBegan:Connect(function(input)
    local UserInputType = input.UserInputType

    if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.Touch then
        u309 = true
        s14 = "resize"
        inputPosition = input.Position
        AbsoluteSize = v113.AbsoluteSize
        Position = v113.Position
    end
end)
v73(UserInputService.InputChanged:Connect(function(input)
    if not u309 then
        return
    end

    local UserInputType = input.UserInputType

    if UserInputType ~= Enum.UserInputType.MouseMovement and UserInputType ~= Enum.UserInputType.Touch then
        return
    end

    local v1044 = input.Position - inputPosition

    if s14 == "win" then
        v113.Position = UDim2.new(Position.X.Scale, Position.X.Offset + v1044.X, Position.Y.Scale, Position.Y.Offset + v1044.Y)

        return
    end

    if s14 == "orb" then
        v306.Position = UDim2.new(Position.X.Scale, Position.X.Offset + v1044.X, Position.Y.Scale, Position.Y.Offset + v1044.Y)

        return
    end

    if s14 == "resize" then
        local CurrentCamera = workspace.CurrentCamera
        local v1046 = if not CurrentCamera then Vector2.new(1280, 720) else CurrentCamera.ViewportSize
        local Scale = v108.Scale

        if Scale <= 0 then
            Scale = 1
        end

        local v1048 = not u42 and 520 or 400
        local v1049 = not u42 and 360 or 320
        local v1050 = math.max(v1048, v1046.X - 24)
        local v1051 = math.max(v1049, v1046.Y - 24)
        local v1052 = math.clamp(AbsoluteSize.X / Scale + v1044.X / Scale, v1048, v1050)
        local v1053 = math.clamp(AbsoluteSize.Y / Scale + v1044.Y / Scale, v1049, v1051)

        v113.Size = UDim2.fromOffset(v1052, v1053)
        n1 = v1052
        n2 = v1053
    end
end))
v73(UserInputService.InputEnded:Connect(function(input)
    local UserInputType = input.UserInputType

    if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.Touch then
        u309 = false
    end
end))
function u305()
    local CurrentCamera = workspace.CurrentCamera
    local v1057 = if not CurrentCamera then Vector2.new(1280, 720) else CurrentCamera.ViewportSize

    if v1057.X < 80 or v1057.Y < 80 then
        return
    end

    local XOffset = v113.Size.X.Offset
    local YOffset = v113.Size.Y.Offset

    if XOffset <= 0 then
        XOffset = n1
    end

    if YOffset <= 0 then
        YOffset = n2
    end

    local v1060 = not u42 and 520 or 400
    local v1061 = not u42 and 360 or 320
    local v1062 = math.clamp(XOffset, v1060, math.max(v1060, v1057.X - 24))
    local v1063 = math.clamp(YOffset, v1061, math.max(v1061, v1057.Y - 24))

    if v1062 ~= v113.Size.X.Offset or v1063 ~= v113.Size.Y.Offset then
        v113.Size = UDim2.fromOffset(v1062, v1063)
    end
end
v108.Scale = (tonumber(t9.UIScale) or 100) / 100
if u42 then
    local v316, v317 = v41()

    n1 = v316
    n2 = v317
    v113.Size = UDim2.fromOffset(v316, v317)
end
u305()
function u44()
    local v1064 = not not u42

    n3 = not v1064 and 152 or 128
    v151.Size = UDim2.new(0, n3, 1, 0)
    v194.Position = UDim2.fromOffset(n3, 2)
    v194.Size = UDim2.new(1, -n3, 1, -2)
    v217.Size = UDim2.fromOffset(not v1064 and 22 or 32, not v1064 and 22 or 32)
    v306.Size = UDim2.fromOffset(not v1064 and 34 or 48, not v1064 and 34 or 48)
    v314.Size = UDim2.fromOffset(not v1064 and 18 or 32, not v1064 and 18 or 32)

    if v1064 then
        v306.Position = UDim2.new(0, 36, 1, -88)

        local v1065, v1066 = v41()

        n1 = v1065
        n2 = v1066
        v113.Size = UDim2.fromOffset(v1065, v1066)
    else
        n1 = 620
        n2 = 430
        v113.Size = UDim2.fromOffset(n1, n2)
    end

    if u305 then
        u305()
    end
end
local function v318()
    if u43 then
        return
    end

    if v40() and not u42 then
        u42 = true
        u44()

        if t10.PhoneUI and t10.PhoneUI.set then
            pcall(t10.PhoneUI.set, true)
        end
    end
end
task.defer(v318)
for _, v in ipairs({
	0.2,
	0.6,
	1.2,
	2.5
}) do
    task.delay(v, v318)
end
task.spawn(function()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")

    if not PlayerGui then
        pcall(function()
            PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 8)
        end)
    end

    if not PlayerGui then
        return
    end

    local connection = PlayerGui.ChildAdded:Connect(function(child)
        if child.Name == "TouchGui" or child.Name == "TouchControlFrame" then
            if u43 then
                return
            end

            if v40() and not u42 then
                u42 = true
                u44()

                if t10.PhoneUI and t10.PhoneUI.set then
                    pcall(t10.PhoneUI.set, true)
                end
            end
        end
    end)

    if connection then
        t14[#t14 + 1] = connection
    end

    if not u43 and v40() and not u42 then
        u42 = true
        u44()

        if t10.PhoneUI and t10.PhoneUI.set then
            pcall(t10.PhoneUI.set, true)
        end
    end
end)
pcall(function()
    local connection = UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(v318)

    if connection then
        t14[#t14 + 1] = connection
    end

    local connection3 = UserInputService:GetPropertyChangedSignal("GyroscopeEnabled"):Connect(v318)

    if connection3 then
        t14[#t14 + 1] = connection3
    end

    local connection4 = UserInputService:GetPropertyChangedSignal("AccelerometerEnabled"):Connect(v318)

    if connection4 then
        t14[#t14 + 1] = connection4
    end
end)
pcall(function()
    local CurrentCamera = workspace.CurrentCamera

    if CurrentCamera then
        local connection = CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            if not u43 and v40() and not u42 then
                u42 = true
                u44()

                if t10.PhoneUI and t10.PhoneUI.set then
                    pcall(t10.PhoneUI.set, true)
                end
            end

            u305()
        end)

        if connection then
            t14[#t14 + 1] = connection
        end
    end

    local connection = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        local CurrentCamera2 = workspace.CurrentCamera

        if CurrentCamera2 then
            local connection = CurrentCamera2:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                if not u43 and v40() and not u42 then
                    u42 = true
                    u44()

                    if t10.PhoneUI and t10.PhoneUI.set then
                        pcall(t10.PhoneUI.set, true)
                    end
                end

                u305()
            end)

            if connection then
                t14[#t14 + 1] = connection
            end

            u305()
        end
    end)

    if connection then
        t14[#t14 + 1] = connection
    end
end)
v73(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.Keyboard then
        return
    end

    if (t9.OpenBind or t1.OpenBind) == input.KeyCode then
        u70(not u308)
    end
end))
local n5 = 0
local elapsed = os.clock()
v73(RunService.RenderStepped:Connect(function()
    n5 += 1

    local elapsed2 = os.clock()

    if elapsed2 - elapsed < 0.4 then
        return
    end

    local v1078 = math.floor(n5 / (elapsed2 - elapsed) + 0.5)

    n5 = 0
    elapsed = elapsed2

    local n6 = 0

    pcall(function()
        local v1387 = Stats.Network.ServerStatsItem["Data Ping"]

        n6 = math.floor(v1387:GetValue())
    end)
    v229.Text = v1078 .. " fps"
    v228.Text = n6 .. " ms"
    v228.TextColor3 = n6 < 90 and t3.ok or t3.dim
end))
local function u323()
    if u284 then
        pcall(u284)
    end

    for i = 1, #t14 do
        local v1081 = t14[i]

        t14[i] = nil

        if v1081 then
            pcall(function()
                v1081:Disconnect()
            end)
        end
    end

    if v98 then
        pcall(function()
            v98:Destroy()
        end)
    end
end
if t9.StartMin then
    u70(false)
end
function u71(p147)
    if p147 == "Dusk" or p147 == "dusk" then
        p147 = "Dark"
    end

    local v1083 = t2[p147] or t2.Dark
    local s15

    if v1083 == t2.Light then
        s15 = "Light"
    else
        s15 = "Dark"
        v1083 = t2.Dark
    end

    t9.Theme = s15

    for k, v in pairs(v1083) do
        t3[k] = v
    end

    local function v1087(p148)
        local th_bg = p148:GetAttribute("th_bg")

        if th_bg and (t3[th_bg] and p148:IsA("GuiObject")) then
            local v1390 = self[p148]

            if v1390 then
                pcall(function()
                    v1390:Cancel()
                end)
                self[p148] = nil
            end

            local th_hover = p148:GetAttribute("th_hover")
            local v1392 = p148:GetAttribute("th_over") == true

            p148.BackgroundColor3 = v1392 and (not not th_hover and t3[th_hover]) or t3[th_bg]

            if p148:GetAttribute("th_row") then
                p148.BackgroundTransparency = not v1392 and 1 or 0
            end
        end

        local th_text = p148:GetAttribute("th_text")

        if th_text and t3[th_text] then
            pcall(function()
                p148.TextColor3 = t3[th_text]
            end)
        end

        if p148:IsA("TextBox") then
            local th_placeholder = p148:GetAttribute("th_placeholder")

            if th_placeholder and t3[th_placeholder] then
                p148.PlaceholderColor3 = t3[th_placeholder]
            end
        end

        if p148:IsA("UIStroke") then
            local th_stroke = p148:GetAttribute("th_stroke")

            if th_stroke and t3[th_stroke] then
                p148.Color = t3[th_stroke]
            end
        end

        if p148:IsA("ImageLabel") then
            local th_img = p148:GetAttribute("th_img")

            if th_img and t3[th_img] then
                p148.ImageColor3 = t3[th_img]
            end
        end

        if p148:IsA("ScrollingFrame") then
            local th_scroll = p148:GetAttribute("th_scroll")

            if th_scroll and t3[th_scroll] then
                p148.ScrollBarImageColor3 = t3[th_scroll]
            end
        end
    end

    v1087(v113)
    v1087(v306)

    for _, descendant in ipairs(v98:GetDescendants()) do
        v1087(descendant)
    end

    v79()
    v262(v245, t3.mute)

    for _, v in pairs(t12) do
        local scroll = v.scroll

        if scroll then
            local CanvasPosition = scroll.CanvasPosition

            scroll.CanvasPosition = CanvasPosition + Vector2.new(0, 1)
            scroll.CanvasPosition = CanvasPosition
        end
    end

    if u66 then
        u68(u66.name)
    end

    for k, v in pairs(t10) do
        if v.kind == "toggle" and v.set then
            v.set(t9[k] == true)
        end
    end
end
u68("Auto Steal")
local v324 = v50()
local v325 = v51()
v325.alive = true
local t149 = {
	Flags = t9,
	Widgets = t10,
	SetPage = u68,
	SetVisible = u70,
	SetTheme = u71,
	Destroy = u323,
	SetStatus = function(p149, p150)
    local v1098 = t10[p149]

    if v1098 and v1098.status then
        v1098.status.Text = p150
    end
end,
	On = function(p151, p152)
    local v1101 = t10[p151]

    if v1101 then
        v1101.on = p152
    end
end
}
v325.UI = t149
v324.NEXUSUI = type(v324.NEXUSUI) == "table" and v324.NEXUSUI or {}
v324.NEXUSUI[str] = t149
if type(v324.UI) ~= "table" or not (function()
    local NEXUSHUB = (getgenv and getgenv() or _G).NEXUSHUB
    local v354 = type(NEXUSHUB) == "table" and NEXUSHUB.slots

    if type(v354) ~= "table" then
        return false
    end

    for k, v in pairs(v354) do
        if tostring(k) ~= str and type(v) == "table" and v.alive == true then
            return true
        end
    end

    return false
end)() then
    v324.UI = t149
end;
(function()
    local function v1102(p153, ...)
        warn("[NEXUS/" .. tostring(p153) .. "]", ...)
    end
    local u1103
    local Directory
    local Directory2
    local ok, result = pcall(function()
        return require(ReplicatedStorage.Client.EggState)
    end)
    if ok then
        u1103 = result
    else
        v1102("modules", "EggState require failed", (tostring(result)))
    end
    local ok3, result3 = pcall(function()
        return require(ReplicatedStorage.Data.Assets)
    end)
    if ok3 and type(result3) == "table" then
        Directory = result3.Directory
    else
        v1102("modules", "Assets require failed", (tostring(result3)))
    end
    local ok4, result4 = pcall(function()
        return require(ReplicatedStorage.Data.Areas)
    end)
    if ok4 and type(result4) == "table" then
        Directory2 = result4.Directory

        if type(Directory2) == "table" then
            v1102("modules", "areas dir", "ok")
        end
    else
        v1102("modules", "Areas require failed", (tostring(result4)))
    end
    local function v1112()
        local Character = LocalPlayer.Character

        if not Character then
            return
        end

        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

        if not Humanoid or not HumanoidRootPart or Humanoid.Health <= 0 then
            return
        end

        return Humanoid, HumanoidRootPart, Character
    end
    local function v1113()
        local CurrentCamera = workspace.CurrentCamera

        if not CurrentCamera then
            return Vector3.new(0, 0, -1)
        end

        local vector3 = Vector3.new(CurrentCamera.CFrame.LookVector.X, 0, CurrentCamera.CFrame.LookVector.Z)

        if vector3.Magnitude < 0.001 then
            return Vector3.new(0, 0, -1)
        end

        return vector3.Unit
    end
    local t150 = {
		"VerticalTrajectory",
		"CorrectionContext",
		"PivotTo",
		"Relocate",
		"Authoritative WalkSpeed",
		"BeginImpulse",
		"LastValidatedGroundedSample"
	}
    local t151 = {
		"LastGoodSample",
		"LastObservedSample",
		"LastValidatedSample",
		"LastValidatedGroundedSample",
		"LastConfirmedGroundSample",
		"LastSample",
		"LastGameplayTrustedSample"
	}
    local u1116 = false
    local u1117 = true
    local u1118
    local u1119
    local u1120
    local t152 = {}
    local t153 = {}
    local t154 = {}
    local t155 = {}
    local n7 = 0.016666666666667
    local n8 = 0
    local u1127
    local u1128 = false
    local n9 = 16
    local u1130
    local u1131
    local u1132
    local t216
    local u1134
    local u1135
    local function v1136(p154)
        if p154 then
            t152[p154] = true
        end

        return p154
    end
    local function v1137()
        for k in pairs(t152) do
            t152[k] = nil
            pcall(function()
                k:Disconnect()
            end)
        end
    end
    local function v1138(p155, p156)
        local v1415 = p156 or 16

        if not debug or not debug.getconstants then
            return {}
        end

        local ok5, result5 = pcall(debug.getconstants, p155)

        if not ok5 or type(result5) ~= "table" then
            return {}
        end

        local t156 = {}
        local n10 = 0

        for _, v in pairs(result5) do
            n10 += 1

            if n10 <= v1415 then
                t156[#t156 + 1] = tostring(v)
            end
        end

        return t156
    end
    local function v1139(p157)
        local v1423 = table.concat(v1138(p157, 50), "|")

        for _, v in ipairs(t150) do
            if v1423:find(v, 1, true) then
                return true, v
            end
        end

        if v1423:find("WalkSpeed", 1, true) and v1423:find("AssemblyLinearVelocity", 1, true) and v1423:find("Magnitude", 1, true) then
            return true, "ALVvsWalkSpeed"
        end

        return false
    end
    local function v1140(p158, p159, p160, p161, p162)
        if type(p158) ~= "table" or not p159 then
            return
        end

        local v1441 = v1113()

        if u1128 and t9.StealTravel == "Flight" and not t9.Flight and t216 and typeof(t216.flyLook) == "Vector3" then
            v1441 = t216.flyLook
        end

        local cFrame = CFrame.new(p161, p161 + v1441)

        pcall(function()
            p158.Position = p161
            p158.CFrame = cFrame
            p158.LinearVelocity = p162
            p158.AngularVelocity = Vector3.zero
            p158.IsSupported = true
            p158.Timestamp = os.clock()

            if p160 then
                p158.WalkSpeed = p160.WalkSpeed
                p158.JumpPower = p160.JumpPower
                p158.JumpHeight = p160.JumpHeight
                p158.UseJumpPower = p160.UseJumpPower
                p158.HumanoidState = Enum.HumanoidStateType.Running
            end

            p158.Gravity = workspace.Gravity
        end)
    end
    local function v1141(p163, p164, p165, p166, p167)
        local v1453

        if type(p163) ~= "table" then
            v1453 = false
        else
            local ok6, result6 = pcall(rawget, p163, "LastGoodSample")
            local ok7, result7 = pcall(rawget, p163, "SafeGroundCheckpoints")

            v1453 = ok6 and (type(result6) == "table" and (ok7 and type(result7) == "table"))
        end

        if not v1453 then
            return
        end

        local v1459

        if type(p163) == "table" and type(p163.ExpectedHipHeight) == "number" then
            local v1458 = type(p163.ExpectedRootHalfHeight) == "number" and p163.ExpectedRootHalfHeight or 1

            v1459 = p163.ExpectedHipHeight + v1458 * 0.5
        else
            v1459 = 2.51
        end

        local v1460 = v1459

        pcall(function()
            local elapsed3 = os.clock()

            p163.MaxHorizontalSpeed = 10000000
            p163.MaxVerticalSpeed = 10000000
            p163.IsSupportedNow = true
            p163.LastSupportedAt = elapsed3
            p163.LastCorrectionAt = 0
            p163.HighestYSinceGround = p166.Y
            p163.MovementMode = "Grounded"
            p163.TelemetryRepeatCount = 0
            p163.ValidationLocked = false
            p163.MonitorRunning = false
            p163.MonitorPending = false
            p163.ThreatLevel = "Trusted"
            p163.WasMeaningfullyFalling = false
            p163.InitializingUntil = elapsed3 + 3600
            p163.SupportStartedAt = elapsed3
            p163.ValidationStartedAt = elapsed3

            local GroundContactWitness = p163.GroundContactWitness

            if type(GroundContactWitness) == "table" then
                GroundContactWitness.GroundDistance = v1460
                GroundContactWitness.GroundPosition = Vector3.new(p166.X, p166.Y - v1460, p166.Z)

                if p164.Parent then
                    GroundContactWitness.Character = p164.Parent
                end

                if type(GroundContactWitness.ContactSample) == "table" then
                    v1140(GroundContactWitness.ContactSample, p164, p165, p166, p167)
                end
            end

            local Evidence = p163.Evidence

            if type(Evidence) == "table" then
                Evidence.Speed = 0
                Evidence.Flight = 0
                Evidence.Teleport = 0
            end

            local LastVerticalTrajectoryDecision = p163.LastVerticalTrajectoryDecision

            if type(LastVerticalTrajectoryDecision) == "table" then
                LastVerticalTrajectoryDecision.Active = false
                LastVerticalTrajectoryDecision.CorrectionStarted = false
                LastVerticalTrajectoryDecision.ConsecutiveInvalidWindows = 0
                LastVerticalTrajectoryDecision.EvidenceEventCount = 0
                LastVerticalTrajectoryDecision.MeaningfulDescent = false
                LastVerticalTrajectoryDecision.LandingCandidate = false
                LastVerticalTrajectoryDecision.CurrentY = p166.Y
                LastVerticalTrajectoryDecision.PeakY = p166.Y
                LastVerticalTrajectoryDecision.StartY = p166.Y
                LastVerticalTrajectoryDecision.AirborneDuration = 0
                LastVerticalTrajectoryDecision.LandingDuration = 0
                LastVerticalTrajectoryDecision.LatestLegalSampleAge = 0
                LastVerticalTrajectoryDecision.AllowedRise = 10000000
                LastVerticalTrajectoryDecision.AllowedAirborneDuration = 10000000
                LastVerticalTrajectoryDecision.Evidence = 0
                LastVerticalTrajectoryDecision.PrimaryEvidenceSource = "None"
            end

            local LastVerticalSegmentDecision = p163.LastVerticalSegmentDecision

            if type(LastVerticalSegmentDecision) == "table" then
                LastVerticalSegmentDecision.Active = false
                LastVerticalSegmentDecision.CorrectionStarted = false
                LastVerticalSegmentDecision.Displacement = 0
                LastVerticalSegmentDecision.Excess = 0
                LastVerticalSegmentDecision.AllowedDistance = 10000000
                LastVerticalSegmentDecision.Decision = "Reachable"
                LastVerticalSegmentDecision.CurrentY = p166.Y
                LastVerticalSegmentDecision.PreviousY = p166.Y
                LastVerticalSegmentDecision.MovementContext = "OrdinaryStationaryY"
            end
        end)

        for _, v in ipairs(t151) do
            v1140(p163[v], p164, p165, p166, p167)
        end

        local SampleHistory = p163.SampleHistory

        if type(SampleHistory) == "table" then
            for _, v in pairs(SampleHistory) do
                if type(v) == "table" then
                    v1140(v, p164, p165, p166, p167)
                end
            end
        end

        local SafeGroundCheckpoints = p163.SafeGroundCheckpoints

        if type(SafeGroundCheckpoints) == "table" then
            for _, v in pairs(SafeGroundCheckpoints) do
                if type(v) == "table" then
                    v1140(v, p164, p165, p166, p167)
                end
            end
        end
    end
    local function v1142()
        t153 = {}

        if not getconnections then
            v1102("engine", "no getconnections — wraps skipped")

            return 0
        end

        local t157 = {}

        for _, v in ipairs(getconnections(RunService.PostSimulation)) do
            if not t152[v] and v1139(v.Function) then
                pcall(function()
                    v:Enable()
                end)

                for i = 1, 24 do
                    local Function = v.Function
                    local ok8, result8, v1476 = pcall(debug.getupvalue, Function, i)
                    local v1477 = if ok8 then if v1476 == nil then result8 else v1476 else nil

                    if v1477 == nil then
                        break
                    end

                    if type(v1477) == "table" and not t157[v1477] then
                        t157[v1477] = true
                        t153[#t153 + 1] = v1477
                    end
                end
            end
        end

        return #t153
    end
    local function v1143()
        local t158 = {}
        local t159 = {}

        for i = 1, #t153 do
            local v1481 = t153[i]
            local v1482

            if type(v1481) ~= "table" then
                v1482 = false
            else
                local ok9, result9 = pcall(rawget, v1481, "LastGoodSample")
                local ok10, result10 = pcall(rawget, v1481, "SafeGroundCheckpoints")

                v1482 = ok9 and (type(result9) == "table" and (ok10 and type(result10) == "table"))
            end

            if v1482 and not t158[v1481] then
                t158[v1481] = true
                t159[#t159 + 1] = v1481
            end
        end

        for i = 1, #t154 do
            local v1488 = t154[i]
            local v1489

            if type(v1488) ~= "table" then
                v1489 = false
            else
                local ok11, result11 = pcall(rawget, v1488, "LastGoodSample")
                local ok12, result12 = pcall(rawget, v1488, "SafeGroundCheckpoints")

                v1489 = ok11 and (type(result11) == "table" and (ok12 and type(result12) == "table"))
            end

            if v1489 and not t158[v1488] then
                t158[v1488] = true
                t159[#t159 + 1] = v1488
            end
        end

        if #t159 > 0 then
            t154 = t159
        end

        return #t154
    end
    local function v1144()
        u1120 = nil

        local v1494 = u1119 ~= nil

        if u1119 then
            pcall(function()
                u1119:Destroy()
            end)
            u1119 = nil
        end

        if v1494 then
            for _, child in ipairs(workspace:GetChildren()) do
                if child.Name == "NEXUSSupport" or child.Name == "Hub45Support" then
                    pcall(function()
                        child:Destroy()
                    end)
                end
            end
        end
    end
    local u1145 = false
    local function v1146(p168, p169, p170)
        v1144()

        if not p168 or not p169 then
            local Character = LocalPlayer.Character
            local v1503, v1504

            if not Character then
                v1503 = nil
                v1504 = nil
            else
                v1503 = Character:FindFirstChildOfClass("Humanoid")
                v1504 = Character:FindFirstChild("HumanoidRootPart")

                if not v1503 or not v1504 or v1503.Health <= 0 then
                    v1503 = nil
                    v1504 = nil
                end
            end

            p168 = p168 or v1503
            p169 = p169 or v1504
        end

        if not p168 then
            return
        end

        pcall(function()
            p168.PlatformStand = false
            p168.Sit = false
            p168.AutoRotate = true
            p168.AutoJumpEnabled = true
            p168.Jump = false

            if type(p168.WalkSpeed) == "number" and p168.WalkSpeed > 0 and p168.WalkSpeed <= 36 then
                n9 = p168.WalkSpeed
            end

            p168.WalkSpeed = n9

            if p170 then
                p168:ChangeState(Enum.HumanoidStateType.Freefall)
            end
        end)

        if p169 then
            pcall(function()
                p169.Anchored = false

                if p170 then
                    local AssemblyLinearVelocity = p169.AssemblyLinearVelocity

                    p169.AssemblyLinearVelocity = Vector3.new(0, math.min(AssemblyLinearVelocity.Y, -22), 0)
                end

                p169.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end
    local function v1147(p171)
        if typeof(p171) ~= "Vector3" then
            return nil
        end

        local raycastParams = RaycastParams.new()

        raycastParams.FilterType = Enum.RaycastFilterType.Exclude

        local t160 = { LocalPlayer.Character }

        if u1119 then
            t160[#t160 + 1] = u1119
        end

        if workspace.CurrentCamera then
            t160[#t160 + 1] = workspace.CurrentCamera
        end

        raycastParams.FilterDescendantsInstances = t160

        local vector3 = Vector3.new(p171.X, math.max(p171.Y + 48, 80), p171.Z)
        local raycastResult = workspace:Raycast(vector3, Vector3.new(0, -360, 0), raycastParams)

        if raycastResult and raycastResult.Instance and raycastResult.Instance.CanCollide then
            return raycastResult.Position.Y
        end

        if raycastResult then
            return raycastResult.Position.Y
        end

        return p171.Y
    end
    local function v1148(p172, p173)
        if not p172 then
            return
        end

        if not u1119 or not u1119.Parent then
            v1144()

            local Part = Instance.new("Part")

            Part.Name = "NEXUSSupport"
            Part.Size = Vector3.new(8, 1.2, 8)
            Part.Anchored = true
            Part.CanCollide = true
            Part.CanQuery = true
            Part.CanTouch = false
            Part.CastShadow = false
            Part.Transparency = 1
            Part.Material = Enum.Material.Concrete
            Part.Parent = workspace
            u1119 = Part
        end

        local max = math.max
        local v1516 = t154[1]
        local v1518

        if type(v1516) == "table" and type(v1516.ExpectedHipHeight) == "number" then
            local v1517 = type(v1516.ExpectedRootHalfHeight) == "number" and v1516.ExpectedRootHalfHeight or 1

            v1518 = v1516.ExpectedHipHeight + v1517 * 0.5
        else
            v1518 = 2.51
        end

        local v1519 = max(3.8, v1518)

        if u1128 and typeof(u1127) == "Vector3" and type(u1130) == "function" and u1130() then
            u1120 = p172.Position.Y - v1519 - 0.6
            u1119.CFrame = CFrame.new(p172.Position.X, u1120, p172.Position.Z)

            return
        end

        local v1520 = p172.Position.Y - v1519 - 0.6
        local v1521 = tonumber(p173) or 0

        if u1120 == nil then
            u1120 = v1520
        elseif v1521 > 8 then
            u1120 = math.max(u1120, v1520)
        elseif v1521 < -8 then
            u1120 = v1520
        else
            local v1522 = u1120 + 0.6

            if p172.Position.Y - v1522 > v1519 + 8 then
                u1120 = v1520
            end
        end

        u1119.CFrame = CFrame.new(p172.Position.X, u1120, p172.Position.Z)
    end
    local function v1149(p174, p175, p176)
        local WalkSpeed = p175.WalkSpeed
        local v1527 = math.max(10, WalkSpeed or 16)
        local v1528 = if not (p176.Magnitude > v1527 + 1) then p176 else p176.Magnitude > 0.0001 and p176.Unit * v1527 or Vector3.zero

        pcall(function()
            p174.AssemblyLinearVelocity = v1528
        end)

        for i = 1, #t154 do
            v1141(t154[i], p174, p175, p174.Position, v1528)
        end
    end
    local function v1150(p177)
        if p177 then
            if not hookfunction or not getconnections then
                v1102("engine", "cannot wrap PostSim validators")

                return 0
            end

            local n11 = 0

            for _, v in ipairs(getconnections(RunService.PostSimulation)) do
                if not t152[v] then
                    local v1534, v1535 = v1139(v.Function)
                    local Function = v.Function

                    if v1534 and not t155[Function] then
                        local t161 = {
							old = Function
						}

                        local function v1538(...)
                            local Character = LocalPlayer.Character
                            local v2705, v2706
                            if not Character then
                                v2705 = nil
                                v2706 = nil
                            else
                                v2705 = Character:FindFirstChildOfClass("Humanoid")
                                v2706 = Character:FindFirstChild("HumanoidRootPart")

                                if not v2705 or not v2706 or v2705.Health <= 0 then
                                    v2705 = nil
                                    v2706 = nil
                                end
                            end
                            local v2707 = v2706
                            local AssemblyLinearVelocity
                            local CFrame2
                            if v2707 and v2705 then
                                AssemblyLinearVelocity = v2707.AssemblyLinearVelocity
                                CFrame2 = v2707.CFrame

                                if u1130() then
                                    v1148(v2707, 0)
                                end

                                v1149(v2707, v2705, AssemblyLinearVelocity)
                            end
                            local u2710
                            local ok13, result13 = pcall(function(...)
                                u2710 = table.pack(t161.old(...))
                            end, ...)
                            if v2707 and CFrame2 then
                                local Magnitude = (v2707.Position - CFrame2.Position).Magnitude

                                if Magnitude > 1.5 then
                                    pcall(function()
                                        v2707.CFrame = CFrame2
                                        v2707.AssemblyLinearVelocity = AssemblyLinearVelocity
                                    end)

                                    local elapsed4 = os.clock()

                                    if elapsed4 - n8 > 1 then
                                        n8 = elapsed4
                                        v1102("engine", "undid relocate", math.floor(Magnitude * 10 + 0.5) / 10)
                                    end
                                end
                            end
                            if v2707 and v2705 then
                                v1149(v2707, v2705, AssemblyLinearVelocity or v2707.AssemblyLinearVelocity)
                            end
                            if v2707 and AssemblyLinearVelocity then
                                pcall(function()
                                    v2707.AssemblyLinearVelocity = AssemblyLinearVelocity
                                end)
                            end
                            if not ok13 then
                                error(result13)
                            end

                            return table.unpack(u2710, 1, u2710.n)
                        end

                        if type(newcclosure) == "function" then
                            v1538 = newcclosure(v1538)
                        end

                        local ok14, result14 = pcall(hookfunction, Function, v1538)

                        if ok14 then
                            t161.old = result14 or Function
                            t155[Function] = t161.old
                            n11 += 1
                        else
                            v1102("engine", "wrap fail", v1535, (tostring(result14)))
                        end
                    end
                end
            end

            return n11
        end

        local _restorefunction = restorefunction

        for k, v in pairs(t155) do
            if _restorefunction then
                pcall(_restorefunction, k)
            elseif hookfunction and v then
                pcall(hookfunction, k, v)
            end
        end

        t155 = {}
        v1102("engine", "validator wraps restored")

        return 0
    end
    local function v1151()
        if t216 and t216.carrying and (t216.state == "Return" or t216.state == "Bank") and t9.GuardianBypass ~= false then
            local stage = tonumber(t216.returnRouteStage) or 0

            -- Stages 0/1 are teleport+drop stages. Stage 2 is the final
            -- carry after the second re-grab, so use an ordinary 20-ish walk.
            if stage >= 2 then
                return math.clamp(tonumber(t9.FinalReturnSpeed) or 20, 16, 40)
            end

            return 16
        end

        if t9.Flight then
            return math.clamp(tonumber(t9.FlightSpeed) or 880, 150, 1300)
        end

        if u1128 and typeof(u1127) == "Vector3" then
            -- Travel to the egg is intentionally capped at 200.
            return math.clamp(tonumber(t9.StealSpeed) or 200, 50, 200)
        end

        if t9.BypassSpeed == true then
            return math.clamp(tonumber(t9.BypassCap) or 880, 150, 1300)
        end

        return n9
    end
    function u1130()
        if t216 and t216.carrying and (t216.state == "Return" or t216.state == "Bank") and t9.GuardianBypass ~= false then
            return true
        end

        if t9.Flight then
            return true
        end

        if u1135 and u1135.driving and u1135.driving() then
            return true
        end

        return u1128 == true and (t9.StealTravel == "Flight" and typeof(u1127) == "Vector3")
    end
    local function v1152()
        local v1544 = v1113()
        local vector3 = Vector3.new(-v1544.Z, 0, v1544.X)
        local zero = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            zero += v1544
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            zero -= v1544
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            zero += vector3
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            zero -= vector3
        end

        if zero.Magnitude < 0.001 then
            return Vector3.zero
        end

        return zero.Unit
    end
    local function v1153()
        local v1547 = v1151()
        local v1548 = v1152()
        local n12 = 0

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            n12 = 40
        elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            n12 = -40
        end

        if v1548.Magnitude > 0.05 then
            return Vector3.new(v1548.X * v1547, n12, v1548.Z * v1547)
        end

        return Vector3.new(0, n12, 0)
    end
    local function v1154(p178, p179)
        if t9.Flight and (not u1128 or not u1127) then
            return v1153()
        end

        local v1552 = v1151()

        if u1128 and u1127 then
            local v1553 = u1127 - p179.Position
            local vector3 = Vector3.new(v1553.X, 0, v1553.Z)
            local Magnitude = vector3.Magnitude
            local n13 = 0

            if u1130() then
                n13 = 0

                if u1128 then
                    local v1557 = v1147(Vector3.new(p179.Position.X, p179.Position.Y + 4, p179.Position.Z))

                    if type(v1557) == "number" and v1557 <= p179.Position.Y + 1 and p179.Position.Y > v1557 + 14 then
                        n13 = math.clamp(v1557 + 3 - p179.Position.Y, -28, 0)
                    end
                elseif p179.Position.Y > u1127.Y + 0.6 then
                    n13 = math.clamp(u1127.Y - p179.Position.Y, -36, 0)
                end
            end

            if Magnitude < 1.4 then
                if u1130() then
                    return Vector3.new(0, n13, 0)
                end

                return Vector3.zero
            end

            local finalClose = false
            if t216 and t216.carrying and (t216.state == "Return" or t216.state == "Bank") then
                local c = LocalPlayer.Character
                local root = c and c:FindFirstChild("HumanoidRootPart")
                local spawn = workspace:FindFirstChild("Spawn")
                local safe = spawn and spawn:FindFirstChild("SafeZone")
                local radius = math.clamp(tonumber(t9.FinalReturnRadius) or 8, 5, 14)
                if root and safe then
                    finalClose = Vector3.new(root.Position.X - safe.Position.X, 0, root.Position.Z - safe.Position.Z).Magnitude <= radius + 1.25
                end
            end

            local v1558 = finalClose and v1552 or (Magnitude < 8 and math.clamp(v1552 * (Magnitude / 8), 18, v1552) or v1552)

            return Vector3.new(vector3.Unit.X * v1558, n13, vector3.Unit.Z * v1558)
        end

        if u1128 and u1130() then
            return Vector3.zero
        end

        if t9.BypassSpeed == true then
            local MoveDirection = p178.MoveDirection

            if MoveDirection.Magnitude > 0.05 then
                return Vector3.new(MoveDirection.X * v1552, 0, MoveDirection.Z * v1552)
            end
        end

        return Vector3.zero
    end
    local n14 = 0
    local n15 = 7.2
    local u1157 = false
    local function v1158(p180)
        if not t9.AntiTrap then
            u1157 = false

            return false
        end

        local Character = LocalPlayer.Character
        local v1562, v1563

        if not Character then
            v1562 = nil
            v1563 = nil
            Character = nil
        else
            v1562 = Character:FindFirstChildOfClass("Humanoid")
            v1563 = Character:FindFirstChild("HumanoidRootPart")

            if not v1562 or not v1563 or v1562.Health <= 0 then
                v1562 = nil
                v1563 = nil
                Character = nil
            end
        end

        local v1564 = v1562
        local v1565 = v1563
        local v1566 = Character

        if not v1564 then
            return false
        end

        if type(v1564.JumpHeight) == "number" and v1564.JumpHeight > 0.5 then
            n15 = v1564.JumpHeight
        end

        local v1567 = u1130()
        local v1568 = v1566:GetAttribute("IsTrapped") == true

        if not v1568 and (not v1565.Anchored and v1564.JumpHeight ~= 0) then
            u1157 = false

            return false
        end

        pcall(function()
            if v1568 then
                v1566:SetAttribute("IsTrapped", nil)
            end

            v1565.Anchored = false

            if not v1567 then
                v1564.PlatformStand = false
            end

            v1564.Sit = false

            if u1128 and t9.StealTravel == "Flight" and not t9.Flight then
                v1564.AutoRotate = false
            else
                v1564.AutoRotate = true
            end

            if v1564.JumpHeight < 0.5 then
                v1564.JumpHeight = n15
            end

            local State = v1564:GetState()

            if State == Enum.HumanoidStateType.Physics or State == Enum.HumanoidStateType.PlatformStanding or State == Enum.HumanoidStateType.Seated then
                v1564:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
        pcall(function()
            local TrapBillboard = v1566:FindFirstChild("TrapBillboard", true)

            if TrapBillboard then
                TrapBillboard:Destroy()
            end
        end)

        if not u1157 then
            u1157 = true
            n14 += 1
            v1102("steal", "untrap", p180 or "freeze", n14)
        end

        return true
    end
    local t162 = {
		saved = {},
		char = nil,
		at = 0
	}
    local function v1160()
        local v1569 = t9.AntiTrap == true or t9.AntiMob == true

        if not v1569 and not next(t162.saved) then
            return
        end

        local Character = LocalPlayer.Character

        if Character ~= t162.char then
            t162.saved = {}
            t162.char = Character
            t162.at = 0

            if not v1569 then
                return
            end
        end

        if not Character then
            return
        end

        if v1569 then
            local elapsed5 = os.clock()

            if elapsed5 - (t162.at or 0) < 0.25 then
                return
            end

            t162.at = elapsed5
        end

        for _, descendant in ipairs(Character:GetDescendants()) do
            if descendant:IsA("BasePart") then
                if v1569 then
                    if t162.saved[descendant] == nil then
                        t162.saved[descendant] = descendant.CanTouch
                    end

                    if descendant.CanTouch ~= false then
                        descendant.CanTouch = false
                    end
                else
                    local v1574 = t162.saved[descendant]

                    if v1574 ~= nil then
                        descendant.CanTouch = v1574
                        t162.saved[descendant] = nil
                    end
                end
            end
        end

        if not v1569 then
            t162.saved = {}
        end
    end
    local t163 = {
		saved = {},
		on = false
	}
    local function v1162()
        if t163.on or next(t163.saved) then
            for k, v in pairs(t163.saved) do
                if k.Parent then
                    pcall(function()
                        k.CanCollide = v.c == nil or (v.c or true)
                        k.CanTouch = v.t
                    end)
                end

                t163.saved[k] = nil
            end

            t163.on = false
        end

        local Character = LocalPlayer.Character

        if not Character then
            return
        end

        for _, descendant in ipairs(Character:GetDescendants()) do
            if descendant:IsA("BasePart") and descendant.Name ~= "HumanoidRootPart" and not descendant:FindFirstAncestorWhichIsA("Accessory") and descendant.CanCollide == false then
                descendant.CanCollide = true
            end
        end
    end
    local function v1163(p181, p182, p183)
        if not p181 or (not p182 or not (p182.Magnitude > 0.05)) then
            return false
        end

        local v1583 = p183 or 12
        local raycastParams = RaycastParams.new()

        raycastParams.FilterType = Enum.RaycastFilterType.Exclude

        local t164 = { LocalPlayer.Character }

        if workspace.CurrentCamera then
            t164[#t164 + 1] = workspace.CurrentCamera
        end

        raycastParams.FilterDescendantsInstances = t164

        local v1586 = p181.Position + Vector3.new(0, 2.2, 0)
        local raycastResult = workspace:Raycast(v1586, p182.Unit * v1583, raycastParams)

        if not raycastResult or not raycastResult.Instance or not raycastResult.Instance.CanCollide then
            return false
        end

        local Instance2 = raycastResult.Instance
        local FullName = Instance2:GetFullName()
        local v1590 = string.lower(Instance2.Name)
        local v1591 = Instance2.Parent and string.lower(Instance2.Parent.Name) or ""
        local Instance2Size = Instance2.Size
        local Normal = raycastResult.Normal
        local v1594 = FullName:find("LobbyBoundaries", 1, true) or (FullName:find("MapBound", 1, true) or (v1590:find("boundar", 1, true) or (v1590:find("mapedge", 1, true) or Instance2Size.Y >= 24 and (math.min(Instance2Size.X, Instance2Size.Z) <= 14 and math.max(Instance2Size.X, Instance2Size.Z) >= 40))))

        if v1590:find("treadmill", 1, true) or (v1590:find("belt", 1, true) or (FullName:find("Treadmill", 1, true) or v1591:find("treadmill", 1, true))) then
            return true, Vector3.new(Normal.X, 0, Normal.Z), "belt"
        end

        if not v1594 then
            return false
        end

        return true, Vector3.new(Normal.X, 0, Normal.Z)
    end
    local t165 = {
		saved = {},
		at = 0,
		ragOff = false,
		patched = {},
		muted = {},
		groups = false,
		strikeWrapped = false,
		components = {},
		runtimes = {},
		hitArmed = false
	}
    local function v1165()
        for k, v in pairs(t165.saved) do
            if k.Parent then
                pcall(function()
                    k.CanCollide = v.collide
                    k.CanTouch = v.touch

                    if v.group then
                        k.CollisionGroup = v.group
                    end
                end)
            end

            t165.saved[k] = nil
        end
    end
    local function v1166(p184)
        for _, descendant in ipairs(p184:GetDescendants()) do
            local ok15, result15 = pcall(function()
                return descendant:IsA("BasePart")
            end)

            if ok15 and result15 then
                if t165.saved[descendant] == nil then
                    t165.saved[descendant] = {
						collide = descendant.CanCollide,
						touch = descendant.CanTouch,
						group = descendant.CollisionGroup
					}
                end

                pcall(function()
                    descendant.CanTouch = false
                    descendant.CanCollide = false
                end)
                pcall(function()
                    descendant.CollisionGroup = "GuardsNoCollide"
                end)
            end
        end
    end
    local function v1167(p185)
        local PhysicsService = game:GetService("PhysicsService")

        pcall(function()
            PhysicsService:RegisterCollisionGroup("Guards")
            PhysicsService:RegisterCollisionGroup("Players")
            PhysicsService:RegisterCollisionGroup("GuardsNoCollide")
        end)
        pcall(function()
            PhysicsService:CollisionGroupSetCollidable("Guards", "Players", not p185)
            PhysicsService:CollisionGroupSetCollidable("Players", "Guards", not p185)
            PhysicsService:CollisionGroupSetCollidable("GuardsNoCollide", "Players", false)
            PhysicsService:CollisionGroupSetCollidable("Players", "GuardsNoCollide", false)
            PhysicsService:CollisionGroupSetCollidable("GuardsNoCollide", "Default", false)
            PhysicsService:CollisionGroupSetCollidable("GuardsNoCollide", "Guards", false)
        end)
        t165.groups = p185 == true
    end
    local function v1168(p186)
        local Shared = ReplicatedStorage:FindFirstChild("Shared")

        for i = 1, #p186 do
            if not Shared then
                return
            end

            Shared = Shared:FindFirstChild(p186[i])
        end

        if Shared and Shared:IsA("ModuleScript") then
            local ok16, result16 = pcall(require, Shared)

            if ok16 then
                return result16
            end
        end
    end
    local function v1169(p187, p188, p189)
        if type(p187) ~= "table" or type(p187[p188]) ~= "function" then
            return false
        end
        local v1617 = tostring(p187) .. "." .. tostring(p188)
        if t165.patched[v1617] then
            return true
        end
        local v1618 = p189(p187[p188])
        local g1619
        local ok17
        local result17
        repeat
            if g1619 or type(newcclosure) == "function" then
                if not g1619 then
                    ok17, result17 = pcall(newcclosure, v1618)
                end

                if g1619 or ok17 and type(result17) == "function" then
                    g1619 = false
                    p187[p188] = result17
                    t165.patched[v1617] = true

                    return true
                end
            end

            result17 = v1618
            g1619 = true
        until not g1619
    end
    local function v1170(p190)
        if typeof(p190) == "Instance" then
            return p190
        end

        if type(p190) ~= "table" then
            return nil
        end

        for _, v in ipairs({
			"Remote",
			"remote",
			"Instance",
			"_remote",
			"_instance",
			"Event"
		}) do
            local v1625 = p190[v]

            if typeof(v1625) == "Instance" then
                return v1625
            end
        end
    end
    local function v1171(p191)
        local v1627 = v1170(p191) or typeof(p191) == "Instance" and p191

        if not v1627 or t165.muted[v1627] then
            return
        end

        local OnClientEvent = v1627.OnClientEvent

        if not OnClientEvent or not getconnections then
            return
        end

        local ok18, result18 = pcall(getconnections, OnClientEvent)

        if not ok18 or type(result18) ~= "table" then
            return
        end

        local t166 = {}

        for _, v in ipairs(result18) do
            pcall(function()
                if v.Disable then
                    v:Disable()
                end
            end)
            t166[#t166 + 1] = v
        end

        t165.muted[v1627] = t166
    end
    local function v1172(p192)
        if not p192 then
            for k, v in pairs(t165.components) do
                pcall(function()
                    if v.handler then
                        k._attackHandler = v.handler
                    end

                    k._enabled = v.enabled ~= false
                end)
                t165.components[k] = nil
            end

            for k in pairs(t165.runtimes) do
                pcall(function()
                    k:SetEnabled(true)
                end)
                t165.runtimes[k] = nil
            end

            return
        end

        t165.noopAttack = t165.noopAttack or function()
        end

        for k in pairs(t165.components) do
            k._attackHandler = t165.noopAttack
            k._enabled = false
        end
    end
    local function v1173()
        for k, v in pairs(t165.muted) do
            for _, v14 in ipairs(v) do
                pcall(function()
                    if v14.Enable then
                        v14:Enable()
                    end
                end)
            end

            t165.muted[k] = nil
        end
    end
    local function v1174()
        t165.noopAttack = t165.noopAttack or function()
        end

        for k in pairs(t165.components) do
            k._attackHandler = t165.noopAttack
            k._enabled = false
        end

        local v1644 = v1168({
			"Modules",
			"GuardAreas",
			"GuardDistance"
		})
        local v1645 = v1169(v1644, "XZ", function(p193)
            return function(p194, p195)
                if t9.AntiMob or (t9.GuardianBypass ~= false and t216 and t216.carrying == true and (t216.state == "Return" or t216.state == "Bank")) then
                    return 1000000000
                end

                return p193(p194, p195)
            end
        end)
        local v1646 = v1168({
			"Modules",
			"GuardAreas",
			"GuardComponent"
		})
        local v1647 = v1169(v1646, "_attemptAttack", function(p196)
            return function(...)
                if t9.AntiMob or (t9.GuardianBypass ~= false and t216 and t216.carrying == true and (t216.state == "Return" or t216.state == "Bank")) then
                    return
                end

                return p196(...)
            end
        end)

        v1169(v1646, "Step", function(p197)
            return function(p198, ...)
                if t9.AntiMob or (t9.GuardianBypass ~= false and t216 and t216.carrying == true and (t216.state == "Return" or t216.state == "Bank")) then
                    return nil
                end

                return p197(p198, ...)
            end
        end)

        local v1648 = v1168({
			"Modules",
			"Ragdoll"
		})

        v1169(v1648, "IsRagdolled", function(p199)
            return function(p200, ...)
                if t9.AntiMob and p200 == LocalPlayer.Character then
                    return false
                end

                return p199(p200, ...)
            end
        end)

        for _, v in ipairs({
			"TimedRagdoll",
			"TimedRagdollAsync",
			"ApplyClientRagdoll",
			"Ragdoll"
		}) do
            v1169(v1648, v, function(p201)
                return function(p202, ...)
                    if t9.AntiMob or (t9.GuardianBypass ~= false and t216 and t216.carrying == true and (t216.state == "Return" or t216.state == "Bank")) then
                        local Character = LocalPlayer.Character

                        if p202 == nil or p202 == Character then
                            return
                        end
                    end

                    return p201(p202, ...)
                end
            end)
        end

        local v1651 = v1168({
			"Modules",
			"RagdollJoints"
		})

        v1169(v1651, "Bind", function(p203)
            return function(...)
                if t9.AntiMob or (t9.GuardianBypass ~= false and t216 and t216.carrying == true and (t216.state == "Return" or t216.state == "Bank")) then
                    return
                end

                return p203(...)
            end
        end)
        pcall(function()
            local v2723 = v1168({ "Remotes" })
            local v2724 = v2723 and v2723.GuardPatrol

            if type(v2724) ~= "table" then
                return
            end

            for k, v in pairs(v2724) do
                local str2 = tostring(k)
                local v2728 = v1170(v) or typeof(v) == "Instance" and v

                if str2:find("Strike", 1, true) or str2:find("Handoff", 1, true) then
                    local v2729 = "gpfs." .. str2

                    if not t165.patched[v2729] then
                        if v2728 and typeof(v2728) == "Instance" then
                            v2724[k] = setmetatable({
								FireServer = function(_, ...)
                                if t9.AntiMob or (t9.GuardianBypass ~= false and t216 and t216.carrying == true and (t216.state == "Return" or t216.state == "Bank")) then
                                    return
                                end

                                return v2728:FireServer(...)
                            end
							}, {
								__index = v2728
							})
                            t165.patched[v2729] = true
                        elseif type(v) == "table" and type(v.FireServer) == "function" then
                            v1169(v, "FireServer", function(p205)
                                return function(...)
                                    if t9.AntiMob or (t9.GuardianBypass ~= false and t216 and t216.carrying == true and (t216.state == "Return" or t216.state == "Bank")) then
                                        return
                                    end

                                    return p205(...)
                                end
                            end)
                        end
                    end
                end

                if str2:find("Strike", 1, true) or str2:find("Handoff", 1, true) or str2:find("SpeedToll", 1, true) or str2:find("SpeedHit", 1, true) or str2:find("Ragdoll", 1, true) or str2:find("Limp", 1, true) or str2:find("Slap", 1, true) or str2:find("Jolt", 1, true) then
                    v1171(v2728 or v)
                end
            end
        end)
        pcall(function()
            local v2730 = v1168({ "Remotes" })

            if type(v2730) ~= "table" then
                return
            end

            local Limpness = v2730.Limpness

            v1171(Limpness and Limpness.WriteLimpness)

            local SharedFx = v2730.SharedFx

            v1171(SharedFx and SharedFx.JoltOnce)
        end)
        pcall(function()
            local t167 = {}
            local Network = ReplicatedStorage:FindFirstChild("Network")

            if Network then
                t167[#t167 + 1] = Network
            end

            local Packages = ReplicatedStorage:FindFirstChild("Packages")
            local v2736 = Packages and Packages:FindFirstChild("Networking")

            if v2736 then
                t167[#t167 + 1] = v2736
            end

            for _, v in ipairs(t167) do
                for _, descendant in ipairs(v:GetDescendants()) do
                    if descendant:IsA("RemoteEvent") then
                        local descendantName = descendant.Name

                        if descendantName:find("Strike", 1, true) or descendantName:find("SpeedToll", 1, true) or descendantName:find("SpeedHit", 1, true) or descendantName:find("Handoff", 1, true) or descendantName:find("Ragdoll", 1, true) or descendantName:find("Limp", 1, true) or descendantName:find("Slap", 1, true) or descendantName:find("Jolt", 1, true) then
                            v1171(descendant)
                        end
                    end
                end
            end
        end)
        pcall(function()
            if not u1103 or t165.patched["EggState.DropFieldEgg"] then
                return
            end

            v1169(u1103, "DropFieldEgg", function(p206)
                return function(p207, ...)
                    if t9.AntiMob and (p207 == "GuardHit" or p207 == "PlayerSlap") then
                        return
                    end

                    if t9.AutoSteal and t216 and t216.running and not t216.routeDropBusy then
                        return
                    end

                    return p206(p207, ...)
                end
            end)
        end)
        pcall(function()
            local v2742 = v1168({ "Remotes" })
            local v2743 = v2742 and v2742.EggWorld
            local v2744 = v2743 and v2743.AskFieldEggDrop
            local v2745 = v1170(v2744) or typeof(v2744) == "Instance" and v2744

            if v2745 and (typeof(v2745) == "Instance" and not t165.patched.AskFieldEggDrop) then
                v2743.AskFieldEggDrop = setmetatable({
					InvokeServer = function(_, p209, ...)
                    local v4604 = type(p209) == "table" and p209.Reason

                    if t9.AntiMob and (v4604 == "GuardHit" or v4604 == "PlayerSlap") then
                        return
                    end

                    if t9.AutoSteal and t216 and t216.running and not t216.routeDropBusy then
                        return
                    end

                    return v2745:InvokeServer(p209, ...)
                end
				}, {
					__index = v2745
				})
                t165.patched.AskFieldEggDrop = true

                return
            end

            if type(v2744) == "table" then
                v1169(v2744, "InvokeServer", function(p210)
                    return function(p211, p212, ...)
                        local v4885 = type(p212) == "table" and p212.Reason

                        if t9.AntiMob and (v4885 == "GuardHit" or v4885 == "PlayerSlap") then
                            return
                        end

                        if t9.AutoSteal and t216 and t216.running and not t216.routeDropBusy then
                            return
                        end

                        return p210(p211, p212, ...)
                    end
                end)
            end
        end)

        if not t165.attrConn then
            local v1652 = t165
            local connection = LocalPlayer:GetAttributeChangedSignal("RagdollEndTime"):Connect(function()
                if t9.AntiMob then
                    u1131()
                end
            end)

            if connection then
                t152[connection] = true
            end

            v1652.attrConn = connection
        end

        local v1654 = (not v1645 and "no-xz" or "xz") .. " " .. (not v1647 and "no-atk" or "atk")

        if v1654 ~= t165.logged then
            t165.logged = v1654
            v1102("engine", "anti ragdoll patch", v1654)
        end
    end
    function u1131()
        local Character = LocalPlayer.Character
        local v1656, v1657

        if not Character then
            v1656 = nil
            v1657 = nil
        else
            v1656 = Character:FindFirstChildOfClass("Humanoid")
            v1657 = Character:FindFirstChild("HumanoidRootPart")

            if not v1656 or not v1657 or v1656.Health <= 0 then
                v1656 = nil
                v1657 = nil
            end
        end

        local v1658 = v1656
        local v1659 = v1657

        if not v1658 then
            return
        end

        local State = v1658:GetState()
        local RagdollEndTime = LocalPlayer:GetAttribute("RagdollEndTime")
        local Parent = v1658.Parent

        if type(RagdollEndTime) ~= "number" and Parent then
            RagdollEndTime = Parent:GetAttribute("RagdollEndTime")
        end

        local v1663 = type(RagdollEndTime) == "number" and RagdollEndTime > workspace:GetServerTimeNow() - 0.05

        if not v1663 and (State ~= Enum.HumanoidStateType.Ragdoll and (State ~= Enum.HumanoidStateType.FallingDown and State ~= Enum.HumanoidStateType.Physics)) then
            return
        end

        t165.ragOff = true

        local v1664 = u1130 and u1130()

        pcall(function()
            v1658:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            v1658:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            v1658:SetStateEnabled(Enum.HumanoidStateType.Physics, false)

            if v1664 then
                v1658.PlatformStand = true

                return
            end

            v1658:ChangeState(Enum.HumanoidStateType.GettingUp)
            v1658.PlatformStand = false
            v1658.Sit = false
        end)

        if Parent then
            if not t165.joints then
                t165.joints = v1168({
					"Modules",
					"RagdollJoints"
				})
            end

            local joints = t165.joints

            if joints and type(joints.Release) == "function" then
                pcall(joints.Release, Parent)
            end

            pcall(function()
                Parent:SetAttribute("RagdollEndTime", 0)
            end)
        end

        if v1663 then
            pcall(function()
                LocalPlayer:SetAttribute("RagdollEndTime", 0)
            end)
        end

        if v1659 and not v1664 then
            pcall(function()
                local MoveDirection = v1658.MoveDirection
                local v2747 = v1658.WalkSpeed or 0

                v1659.AssemblyLinearVelocity = Vector3.new(MoveDirection.X * v2747, v1659.AssemblyLinearVelocity.Y, MoveDirection.Z * v2747)
                v1659.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end
    local function v1175()
        if t9.AntiMob ~= true then
            if not t165.hitArmed and not t165.ragOff and not t165.groups and not next(t165.saved) then
                return
            end

            v1173()
            v1172(false)

            if t165.groups then
                v1167(false)
            end

            if next(t165.saved) then
                v1165()
            end

            if t165.ragOff then
                local v1666 = select(1, v1112())

                if v1666 then
                    pcall(function()
                        v1666:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
                        v1666:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
                        v1666:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
                        v1666:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                    end)
                end

                t165.ragOff = false
            end

            t165.hitArmed = false

            return
        end

        if not t165.hitArmed then
            v1174()
            t165.hitArmed = true
        end

        if not t165.groups then
            v1167(true)
        end

        local v1667 = select(1, v1112())

        if v1667 then
            if v1667.Health < v1667.MaxHealth then
                pcall(function()
                    if v1667.Health <= 0 then
                        v1667:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                    end

                    v1667.Health = v1667.MaxHealth
                end)
            end

            u1131()

            if v1667 ~= t165.hum then
                t165.hum = v1667

                if t165.stConn then
                    pcall(function()
                        t165.stConn:Disconnect()
                    end)
                end

                if t165.hpConn then
                    pcall(function()
                        t165.hpConn:Disconnect()
                    end)
                end

                local v1668 = t165
                local connection = v1667.StateChanged:Connect(function(_, newState)
                    if t9.AntiMob ~= true then
                        return
                    end

                    if newState == Enum.HumanoidStateType.Ragdoll or newState == Enum.HumanoidStateType.FallingDown or newState == Enum.HumanoidStateType.Physics or newState == Enum.HumanoidStateType.Dead then
                        u1131()
                    end
                end)

                if connection then
                    t152[connection] = true
                end

                v1668.stConn = connection

                local v1670 = t165
                local connection5 = v1667.HealthChanged:Connect(function(p214)
                    if t9.AntiMob == true and p214 < v1667.MaxHealth then
                        pcall(function()
                            if p214 <= 0 then
                                v1667:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
                            end

                            v1667.Health = v1667.MaxHealth
                        end)
                    end
                end)

                if connection5 then
                    t152[connection5] = true
                end

                v1670.hpConn = connection5
            end
        end

        local elapsed6 = os.clock()

        if elapsed6 - (t165.muteAt or 0) < 0.35 then
            return
        end

        t165.muteAt = elapsed6
        pcall(function()
            local __OBJECTS = workspace:FindFirstChild("__OBJECTS")
            local v2752 = __OBJECTS and __OBJECTS:FindFirstChild("Areas")
            local v2753 = v2752 and v2752:FindFirstChild("GuardAreas") or workspace:FindFirstChild("GuardAreas")

            if not v2753 then
                return
            end

            for _, child in ipairs(v2753:GetChildren()) do
                local Guard = child:FindFirstChild("Guard")

                if Guard and Guard:IsA("Model") then
                    v1166(Guard)
                end

                for _, child2 in ipairs(child:GetChildren()) do
                    if child2:IsA("Model") and child2 ~= Guard and (string.lower(child2.Name):find("guard", 1, true) or child2:FindFirstChildOfClass("Humanoid")) then
                        v1166(child2)
                    end
                end
            end
        end)
    end
    local connection = LocalPlayer.CharacterRemoving:Connect(function()
        u1145 = false
        u1127 = nil
        v1144()
    end)
    if connection then
        t152[connection] = true
    end
    local connection7 = LocalPlayer.CharacterAdded:Connect(function(character)
        t162.saved = {}
        t162.char = nil
        u1145 = false
        u1127 = nil

        if t216 then
            t216.target = nil
            t216.lastPos = nil
            t216.stillFor = 0
            t216.pendingCarry = nil
        end

        task.spawn(function()
            if not u1117 then
                return
            end

            local Humanoid = character:WaitForChild("Humanoid", 15)

            if not u1117 then
                return
            end

            local v2760 = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart", 15)

            if not Humanoid or not v2760 then
                return
            end

            task.wait(0.55)

            if not u1117 or character.Parent == nil or Humanoid.Health <= 0 then
                return
            end

            v1144()
            v1160()
            v1175()

            local connection6 = Humanoid.Died:Connect(function()
                u1145 = false
                u1127 = nil
                v1144()
            end)

            if connection6 then
                t152[connection6] = true
            end

            if t216 and t216.running then
                t216.state = "Scan"
                t216.since = os.clock()
                u1128 = false
                u1127 = nil
            end

            if type(Humanoid.WalkSpeed) == "number" and Humanoid.WalkSpeed > 0 and Humanoid.WalkSpeed <= 36 then
                n9 = Humanoid.WalkSpeed
            end

            if u1130() and v2760 then
                v1148(v2760, 0)
            end
        end)
    end)
    if connection7 then
        t152[connection7] = true
    end
    local Character = LocalPlayer.Character
    local v1179 = Character and Character:FindFirstChildOfClass("Humanoid")
    if v1179 then
        local connection8 = v1179.Died:Connect(function()
            u1145 = false
            u1127 = nil
            v1144()
        end)

        if connection8 then
            t152[connection8] = true
        end
    end
    local function v1181(p215, p216, p217)
        v1148(p216, p217 and p217.Y)

        local v1678 = u1128 and (t9.StealTravel == "Flight" and not t9.Flight)

        pcall(function()
            p215.Jump = false
            p215.AutoJumpEnabled = false
            p215:Move(Vector3.zero, false)
            p215.PlatformStand = true

            if v1678 then
                p215.AutoRotate = false
            end
        end)

        if v1678 and p216 then
            pcall(function()
                p216.AssemblyAngularVelocity = Vector3.zero

                local v2762 = t216 and t216.flyLook

                if typeof(v2762) ~= "Vector3" or v2762.Magnitude < 0.05 then
                    local vector3 = Vector3.new(p216.CFrame.LookVector.X, 0, p216.CFrame.LookVector.Z)

                    v2762 = if not (vector3.Magnitude < 0.05) then vector3.Unit else Vector3.new(0, 0, -1)

                    if t216 then
                        t216.flyLook = v2762
                    end
                end

                local p216Position = p216.Position
                local p216PositionY = p216Position.Y
                local v2766 = p216Position

                if p217 and n7 then
                    v2766 = p216Position + Vector3.new(p217.X, 0, p217.Z) * math.clamp(n7, 0, 0.05)
                end

                if u1128 then
                    p217 = Vector3.new(p217.X, math.min(p217.Y, 0), p217.Z)
                else
                    local v2767 = v1147(v2766)
                    local v2768 = type(v2767) == "number" and v2767 + 3.15 or nil

                    if typeof(u1127) == "Vector3" then
                        local Y = u1127.Y

                        if v2768 then
                            Y = math.max(Y, v2768)
                        end

                        if Y < p216PositionY then
                            p216PositionY = Y
                            p217 = Vector3.new(p217.X, math.min(p217.Y, 0), p217.Z)
                        end
                    end

                    if v2768 and p216PositionY < v2768 then
                        p216PositionY = v2768
                        p217 = Vector3.new(p217.X, math.max(p217.Y, 0), p217.Z)
                    end
                end

                p216.CFrame = CFrame.new(Vector3.new(p216Position.X, p216PositionY, p216Position.Z), Vector3.new(p216Position.X, p216PositionY, p216Position.Z) + v2762)
            end)
        elseif p216 then
            if t216 then
                t216.flyLook = nil
            end

            local v1679 = v1147(p216.Position)

            if type(v1679) == "number" and p216.Position.Y < v1679 + 3.15 then
                local v1680 = v1679 + 3.15 - p216.Position.Y

                pcall(function()
                    p216.CFrame = p216.CFrame + Vector3.new(0, v1680, 0)
                end)

                if p217 then
                    p217 = Vector3.new(p217.X, math.max(p217.Y, 0), p217.Z)
                end
            end
        end

        if p216 and p217 then
            p216.AssemblyLinearVelocity = p217
        end
    end
    local function v1182(p218)
        if not u1117 then
            return
        end
        n7 = p218 or n7
        local v1682 = u1130()
        local Character2 = LocalPlayer.Character
        local v1684, v1685
        if not Character2 then
            v1684 = nil
            v1685 = nil
        else
            v1684 = Character2:FindFirstChildOfClass("Humanoid")
            v1685 = Character2:FindFirstChild("HumanoidRootPart")

            if not v1684 or not v1685 or v1684.Health <= 0 then
                v1684 = nil
                v1685 = nil
            end
        end
        local v1686 = v1684
        if u1145 and not v1682 then
            local v1687 = u1135 and (u1135.leaving and u1135.leaving())

            v1146(v1686, v1685, not v1687)
            u1145 = false
            pcall(v1158, "engine")
            pcall(v1160)
            pcall(v1175)

            return
        end
        u1145 = v1682
        if v1682 then
            if v1685 then
                pcall(function()
                    if v1686 then
                        v1686.WalkSpeed = math.clamp(v1151(), 16, 1300)
                    end
                end)

                local v1688 = v1154(v1686, v1685)
                local v1689 = v1685.Position + v1688 * math.clamp(n7, 0, 0.05)

                v1148(v1685, v1688.Y)

                local v1690 = v1686 and v1686.WalkSpeed or v1151()
                local v1691 = math.max(10, v1690 or 16)
                local v1692 = if not (v1688.Magnitude > v1691 + 1) then v1688 else v1688.Magnitude > 0.0001 and v1688.Unit * v1691 or Vector3.zero

                for i = 1, #t154 do
                    v1141(t154[i], v1685, v1686, v1689, v1692)
                end

                v1181(v1686, v1685, v1688)
            else
                v1144()
            end

            pcall(v1158, "engine")
            pcall(v1160)
            pcall(v1175)
            v1162(false)

            return
        end
        v1144()
        v1158("engine")
        v1160()
        v1175()
        if v1686 and type(v1686.WalkSpeed) == "number" and v1686.WalkSpeed > 0 and v1686.WalkSpeed <= 36 then
            n9 = v1686.WalkSpeed
        end
        local v1694 = u1128 and typeof(u1127) == "Vector3"
        if not v1694 and t9.BypassSpeed ~= true and t9.Flight ~= true then
            pcall(function()
                if v1686 then
                    v1686.WalkSpeed = n9
                end
            end)

            return
        end
        if not v1685 then
            return
        end
        local v1695 = v1154(v1686, v1685)
        local vector3 = Vector3.new(v1695.X, 0, v1695.Z)
        local v1697 = v1694 and not u1130()
        local u1698
        local v1699
        local v1700
        if v1697 and vector3.Magnitude > 1 then
            local v1701

            v1701, v1699, v1700 = v1163(v1685, vector3, 16)
            u1698 = v1701
        end
        if u1698 and v1700 == "belt" then
            if t216 and t216.beltSunk then
                u1698 = false
            else
                local v1702 = typeof(v1699) == "Vector3" and Vector3.new(v1699.X, 0, v1699.Z) or Vector3.zero
                local vector3_2 = Vector3.new(u1127.X - v1685.Position.X, 0, u1127.Z - v1685.Position.Z)

                if v1702.Magnitude > 0.05 then
                    local Unit = v1702.Unit

                    if vector3_2.Magnitude > 2 and vector3_2:Dot(Unit) < 0 then
                        vector3_2 -= Unit * vector3_2:Dot(Unit)
                    end

                    if vector3_2.Magnitude < 4 then
                        vector3_2 = Unit * 20
                    end

                    vector3 = vector3_2.Unit * math.max(40, v1151() * 0.5)
                    v1695 = Vector3.new(vector3.X, v1695.Y, vector3.Z)
                    pcall(function()
                        v1686.Jump = true
                    end)
                end

                u1698 = false
            end
        end
        if u1698 and typeof(v1699) == "Vector3" and v1699.Magnitude > 0.05 then
            local vector3_3 = Vector3.new(v1699.X, 0, v1699.Z)

            if vector3_3.Magnitude > 0.05 then
                local Unit = vector3_3.Unit
                local v1707 = vector3:Dot(Unit)

                if v1707 < 0 then
                    vector3 -= Unit * v1707
                end

                if vector3.Magnitude < 8 then
                    local vector3_4 = Vector3.new(u1127.X - v1685.Position.X, 0, u1127.Z - v1685.Position.Z)
                    local vector3_5 = Vector3.new(-Unit.Z, 0, Unit.X)

                    if vector3_5.Magnitude > 0.05 then
                        if vector3_5:Dot(vector3_4) < 0 then
                            vector3_5 = -vector3_5
                        end

                        vector3 = vector3_5.Unit * math.max(40, v1151() * 0.35)
                    end
                end

                v1695 = Vector3.new(vector3.X, v1695.Y, vector3.Z)
            end
        end
        pcall(function()
            v1686.PlatformStand = false
            v1686.Sit = false
            v1686.AutoRotate = true
            v1686.AutoJumpEnabled = true

            local v2770 = u1135 and (u1135.leaving and u1135.leaving())

            if v1697 then
                local v2771 = v1151()

                if u1698 then
                    v1686.WalkSpeed = math.clamp(v2771, 16, 90)
                else
                    v1686.WalkSpeed = math.clamp(v2771, 16, 1300)
                end
            elseif t9.BypassSpeed == true then
                v1686.WalkSpeed = math.clamp(tonumber(t9.BypassCap) or 880, 16, 1300)
            else
                v1686.WalkSpeed = n9
            end

            if v2770 or v1697 and t216 and (t216.stillFor or 0) > 0.4 then
                v1686.Jump = true
            elseif not v1697 then
                v1686.Jump = false
            end

            local State = v1686:GetState()

            if State == Enum.HumanoidStateType.PlatformStanding or State == Enum.HumanoidStateType.Physics or State == Enum.HumanoidStateType.Seated then
                v1686:ChangeState(Enum.HumanoidStateType.Running)
            end

            if vector3.Magnitude > 1 then
                v1686:Move(vector3.Unit, false)

                return
            end

            v1686:Move(Vector3.zero, false)
        end)
        v1162()
        v1685.AssemblyLinearVelocity = Vector3.new(v1695.X, v1685.AssemblyLinearVelocity.Y, v1695.Z)
        local AssemblyLinearVelocity = v1685.AssemblyLinearVelocity
        local WalkSpeed = v1686.WalkSpeed
        local v1712 = math.max(10, WalkSpeed or 16)
        local v1713 = if not (AssemblyLinearVelocity.Magnitude > v1712 + 1) then AssemblyLinearVelocity else AssemblyLinearVelocity.Magnitude > 0.0001 and AssemblyLinearVelocity.Unit * v1712 or Vector3.zero
        for i = 1, #t154 do
            v1141(t154[i], v1685, v1686, v1685.Position, v1713)
        end
    end
    local function v1183(p219)
        local v1716 = not not p219

        if v1716 == u1116 then
            if not u1116 then
                return
            end

            if (t9.Flight or t9.BypassSpeed) and true or (t9.AutoSteal or ((t9.AutoPlaceEggs or t9.AutoTreadmill) and true or (t9.AutoHatch or u1128 and t9.StealTravel == "Flight"))) then
                v1142()
                v1143()
                v1150(true)

                return
            end

            if next(t155) then
                v1150(false)
            end

            return
        end

        if v1716 then
            v1142()
            v1143()
            v1102("engine", "movementStates=", #t154)

            if (t9.Flight or t9.BypassSpeed) and true or (t9.AutoSteal or ((t9.AutoPlaceEggs or t9.AutoTreadmill) and true or (t9.AutoHatch or u1128 and t9.StealTravel == "Flight"))) then
                v1150(true)
            end

            if u1118 then
                u1118:Disconnect()
            end

            local connection9 = RunService.Stepped:Connect(function(_, dt)
                if not u1117 then
                    return
                end

                if u1132 and t216 and t216.running and t9.AutoSteal then
                    local ok19, result19 = pcall(u1132, dt)

                    if not ok19 then
                        local elapsed7 = os.clock()

                        if elapsed7 - (t216.lastErrAt or 0) > 2 then
                            t216.lastErrAt = elapsed7
                            v1102("steal", "tick ERR", (tostring(result19)))
                        end
                    end
                end

                pcall(v1182, dt)

                if u1135 and u1135.tick then
                    pcall(u1135.tick)
                end

                if u1134 and u1134.tick then
                    pcall(u1134.tick)
                end
            end)

            if connection9 then
                t152[connection9] = true
            end

            u1118 = connection9
            u1116 = true

            if u1130() then
                local Character3 = LocalPlayer.Character
                local v1719

                if not Character3 then
                    v1719 = nil
                else
                    local Humanoid = Character3:FindFirstChildOfClass("Humanoid")
                    local HumanoidRootPart = Character3:FindFirstChild("HumanoidRootPart")

                    v1719 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
                end

                if v1719 then
                    v1148(v1719, 0)
                end
            end

            v1102("engine", "ON speed=", v1151(), "fly=", u1130(), "wrap=", (t9.Flight or t9.BypassSpeed) and true or (not not t9.AutoSteal or ((t9.AutoPlaceEggs or t9.AutoTreadmill) and true or (not not t9.AutoHatch or u1128 and t9.StealTravel == "Flight"))))

            return
        end

        local v1722 = u1145 or u1119 ~= nil

        u1116 = false
        u1128 = false
        u1127 = nil
        u1145 = false
        v1150(false)

        if u1118 then
            u1118:Disconnect()
            u1118 = nil
        end

        local Character4 = LocalPlayer.Character
        local v1724, v1725

        if not Character4 then
            v1724 = nil
            v1725 = nil
        else
            v1724 = Character4:FindFirstChildOfClass("Humanoid")
            v1725 = Character4:FindFirstChild("HumanoidRootPart")

            if not v1724 or not v1725 or v1724.Health <= 0 then
                v1724 = nil
                v1725 = nil
            end
        end

        v1146(v1724, v1725, v1722)
        v1162(false)
        v1102("engine", "OFF")
    end
    local function v1184()
        if t9.AutoSteal or (t9.AntiTrap or t9.AntiMob) then
            return true
        end

        if u1135 and u1135.wanted and u1135.wanted() then
            return true
        end

        if u1135 and u1135.driving and u1135.driving() then
            return true
        end

        if u1135 and u1135.leaving and u1135.leaving() then
            return true
        end

        return t9.BypassSpeed or t9.Flight
    end
    local v1185 = fireproximityprompt or fireproximityprompttrigger
    local u1186
    local u1187
    local function v1188(p221)
        if typeof(p221) ~= "Instance" then
            return
        end

        local ok20, result20 = pcall(function()
            return p221:IsA("ProximityPrompt")
        end)

        if not ok20 or not result20 then
            return
        end

        pcall(function()
            p221.HoldDuration = 0
            p221.RequiresLineOfSight = false
            p221.ClickablePrompt = true
        end)

        if p221.Name == "CarryAreaEgg" then
            u1186 = p221
        end
    end
    local function v1189(p222)
        if not p222 then
            return false
        end

        if p222.Name == "CarryAreaEgg" then
            return true
        end

        local s16 = ""

        pcall(function()
            s16 = string.lower(tostring(p222.Name) .. " " .. tostring(p222.ActionText) .. " " .. tostring(p222.ObjectText))
        end)

        return s16:find("steal", 1, true) ~= nil or s16:find("carry", 1, true) ~= nil
    end
    local function v1190(p223)
        if not p223 then
            return
        end

        v1188(p223)

        if v1185 then
            pcall(v1185, p223, 0)

            return
        end

        pcall(function()
            p223:InputHoldBegin()
            p223:InputHoldEnd()
        end)
    end
    local function v1191()
        if u1187 and (u1187.Parent and v1189(u1187)) then
            return u1187
        end

        if u1186 and u1186.Parent then
            return u1186
        end

        local SmartPromptPart = workspace:FindFirstChild("SmartPromptPart")
        local v1733 = SmartPromptPart and SmartPromptPart:FindFirstChild("CarryAreaEgg")

        if v1733 and v1733:IsA("ProximityPrompt") then
            u1186 = v1733

            return v1733
        end
    end
    local function v1192(p224, _)
        if type(p224) ~= "table" then
            return nil
        end

        local Rarity = p224.Rarity

        if type(Rarity) == "table" then
            local DefaultRarityValue = Rarity.DefaultRarityValue

            if type(DefaultRarityValue) == "string" and DefaultRarityValue ~= "" then
                local v1747 = string.gsub(DefaultRarityValue, ",", "")
                local v1748 = string.gsub(v1747, "1 in ", "1/")
                local v1749 = string.gsub(v1748, " ", "")

                if string.sub(v1749, 1, 2) == "1/" then
                    local num = tonumber(string.sub(v1749, 3))

                    if num and num >= 1000000000000 then
                        return string.format("1/%.2ft", num / 1000000000000)
                    end

                    if num and num >= 1000000000 then
                        return string.format("1/%.2fb", num / 1000000000)
                    end

                    if num and num >= 1000000 then
                        return string.format("1/%.2fm", num / 1000000)
                    end

                    if num and num >= 1000 then
                        return string.format("1/%.0fk", num / 1000)
                    end

                    return v1749
                end
            end
        end

        return nil
    end
    local function v1193(p226, p227)
        if type(p227) ~= "table" and type(p226) == "table" then
            local v1754 = p226.AssetCategory or p226.Category

            p227 = if not not Directory and v1754 then Directory[v1754] else nil
        end
        if type(p226) == "table" then
            local num = tonumber(p226.MoneyPerSecond)

            if num and num > 0 then
                return num
            end

            local ItemData = p226.ItemData

            if type(ItemData) == "table" then
                local num2 = tonumber(ItemData.MoneyPerSecond)

                if num2 and num2 > 0 then
                    return num2
                end

                if type(ItemData.Category) == "string" and tonumber(ItemData.Scale) then
                    local ok21, result21 = pcall(function()
                        return require(ReplicatedStorage.Shared.Util.AssetEarnings).MutationOnlyRatePerSecond(ItemData)
                    end)

                    if ok21 and tonumber(result21) then
                        return (tonumber(result21))
                    end
                end
            end
        end
        local v1760 = if type(p227) == "table" then tonumber(p227.EarningRate) or 0 else 0
        local v1761 = type(p226) == "table" and (p226.AssetCategory or p226.Category) or nil
        local t168 = {}
        if type(p226) == "table" then
            if type(p226.Mutations) == "table" then
                t168 = p226.Mutations
            elseif type(p226.ItemData) == "table" and type(p226.ItemData.Mutations) == "table" then
                t168 = p226.ItemData.Mutations
            end
        end
        local num
        if type(p226) == "table" then
            num = tonumber(p226.Scale)

            if (not num or not (num > 0)) and type(p226.ItemData) == "table" then
                num = tonumber(p226.ItemData.Scale)
            end
        end
        if not num or not (num > 0) then
            local v1764 = type(p226) == "table" and (tonumber(p226.Weight) or (tonumber(p226.Kg) or tonumber(p226.ModelWeight)))
            local v1765 = type(p227) == "table" and tonumber(p227.ModelWeight)

            num = (not v1764 or (not (v1764 > 0) or (not v1765 or not (v1765 > 0)))) and 1 or (v1764 / v1765) ^ 0.33333333333333
        end
        if type(v1761) == "string" then
            local ok22, result22 = pcall(function()
                return require(ReplicatedStorage.Shared.Util.AssetEarnings).MutationOnlyRatePerSecond({
					Category = v1761,
					Mutations = t168,
					Scale = num
				})
            end)

            if ok22 and tonumber(result22) then
                return (tonumber(result22))
            end
        end
        local v1768 = num <= 5 and num ^ 1.85 or (num / 5) ^ 1.2 * 19.637875755794
        local n16 = 1
        pcall(function()
            n16 = require(ReplicatedStorage.Shared.Modules.Mutations).EarningsFor(t168)
        end)
        n16 = tonumber(n16) or 1
        local v1770 = v1760 * v1768 * n16
        if v1770 < 1 and v1760 > 0 then
            v1770 = 1
        end

        return math.floor(v1770 + 0.5)
    end
    local function v1194(p228)
        if type(p228) ~= "string" then
            return 0
        end

        local v1772 = string.lower(p228:gsub(",", ""):gsub("%s+", ""))

        if v1772 == "" or v1772 == "any" or v1772:find("blank") then
            return 0
        end

        local v1773, v1774 = v1772:match("([%d%.]+)([kmb]?)")
        local num = tonumber(v1773)

        if not num then
            return 0
        end

        if v1774 == "k" then
            return num * 1000
        end

        if v1774 == "m" then
            return num * 1000000
        end

        if v1774 == "b" then
            num *= 1000000000
        end

        return num
    end
    local u1195 = (function()
        local elapsed8 = os.clock()
        local elapsed9 = os.clock()
        local t169 = {}
        local t170 = {
			"IndexImage",
			"IndexIcon",
			"Icon",
			"Image",
			"ImageId",
			"IconImage",
			"Thumbnail",
			"AssetImage",
			"PetImage",
			"EggImage",
			"RenderImage",
			"Picture"
		}
        local t171 = {
			common = 9807270,
			uncommon = 3066993,
			rare = 3447003,
			epic = 10181046,
			legendary = 15844367,
			mythic = 15158332,
			cosmic = 5793266,
			secret = 2303786,
			eternal = 16766720,
			divine = 16738740,
			titan = 16777215
		}

        local function v1781(p229)
            local v2785 = tonumber(p229) or 0
            local v2786 = math.abs(v2785)

            if v2786 >= 1000000000000 then
                return string.format("%.2fT", v2785 / 1000000000000)
            end

            if v2786 >= 1000000000 then
                return string.format("%.2fB", v2785 / 1000000000)
            end

            if v2786 >= 1000000 then
                return string.format("%.2fm", v2785 / 1000000)
            end

            if v2786 >= 1000 then
                return string.format("%.1fk", v2785 / 1000)
            end

            return string.format("%.0f", v2785)
        end
        local function v1782(p230)
            local HookRarityFloor = t9.HookRarityFloor

            if not HookRarityFloor or HookRarityFloor == "Any" then
                return true
            end

            local n17 = 0
            local n18 = 0
            local v2795 = string.lower((tostring(p230 or "")))
            local v2796 = string.lower((tostring(HookRarityFloor)))

            for i, v in ipairs(t6) do
                local v2799 = string.lower(v)

                if v2799 == v2796 then
                    n17 = i
                end

                if v2799 == v2795 then
                    n18 = i
                end
            end

            return n17 <= n18
        end
        local function v1783()
            local v2802 = math.max(0, math.floor(os.clock() - elapsed9))
            local v2803 = math.floor(v2802 / 3600)
            local v2804 = math.floor(v2802 % 3600 / 60)
            local v2805 = v2802 % 60

            if v2803 > 0 then
                return string.format("%d:%02d:%02d", v2803, v2804, v2805)
            end

            return string.format("%d:%02d", v2804, v2805)
        end
        local function v1784(p231)
            if p231 == nil then
                return
            end

            local v2807 = typeof(p231)

            if v2807 == "number" then
                if p231 > 100 then
                    return "rbxassetid://" .. tostring(math.floor(p231))
                end

                return
            end

            if v2807 == "string" then
                if p231 == "" or p231 == "0" or p231 == "rbxassetid://0" then
                    return
                end

                if string.find(p231, "http", 1, true) or string.find(p231, "rbxasset", 1, true) or string.find(p231, "rbxthumb", 1, true) then
                    return p231
                end

                local num = tonumber(p231)

                if num and num > 100 then
                    return "rbxassetid://" .. tostring(math.floor(num))
                end
            end

            if v2807 == "Instance" then
                if p231:IsA("ImageLabel") or p231:IsA("ImageButton") then
                    return v1784(p231.Image)
                end

                if p231:IsA("Decal") or p231:IsA("Texture") then
                    return v1784(p231.Texture)
                end

                local v2809 = p231:FindFirstChildWhichIsA("ImageLabel", true) or (p231:FindFirstChildWhichIsA("ImageButton", true) or p231:FindFirstChildWhichIsA("Decal", true))

                if v2809 then
                    return v1784(v2809)
                end

                return
            end

            if v2807 == "table" then
                return v1784(p231.Image) or (v1784(p231.ImageId) or (v1784(p231.Icon) or v1784(p231.Id)))
            end
        end
        local function v1785(p232)
            if type(p232) ~= "table" then
                return
            end

            for i = 1, #t170 do
                local v2812 = v1784(p232[t170[i]])

                if v2812 then
                    return v2812
                end
            end

            if type(p232.Egg) == "table" then
                for i = 1, #t170 do
                    local v2814 = v1784(p232.Egg[t170[i]])

                    if v2814 then
                        return v2814
                    end
                end
            end
        end
        local function v1786(p233, p234, p235)
            if u1134 and u1134.scanIcons then
                pcall(u1134.scanIcons, true)
            end

            if u1134 and u1134.liveIcon then
                local ok23, result23 = pcall(u1134.liveIcon, p233, p234, p235)

                if ok23 and type(result23) == "string" and result23 ~= "" then
                    return result23
                end
            end

            if u1134 and u1134.icon then
                local ok24, result24 = pcall(u1134.icon, p233, p234)

                if ok24 and type(result24) == "string" and result24 ~= "" then
                    return result24
                end
            end

            return v1785(p233)
        end
        local function v1787(p236)
            if type(p236) ~= "string" or p236 == "" then
                return
            end

            local v2823 = p236:gsub("^http://", "https://")

            if not string.find(v2823, "^https://") then
                return
            end

            if string.find(v2823, "rbxcdn.com", 1, true) then
                return v2823
            end
        end
        local function v1788(p237)
            local v2828 = v1787(p237)
            local g2829
            repeat
                if g2829 or v2828 then
                    if g2829 or (type(v2828) ~= "string" or string.find(v2828, "PrivateImage", 1, true) == nil) then

                        if not v2828 then
                            return
                        end
                        if v2828:find("/Image/", 1, true) or v2828:find("/AvatarHeadshot/", 1, true) or v2828:find("/Avatar/", 1, true) or v2828:find("/Outfit/", 1, true) then
                            return v2828
                        end

                        return
                    end
                end

                v2828 = nil
                g2829 = true
            until not g2829
        end
        local function v1789(p238)
            if type(p238) ~= "string" or p238 == "" then
                return
            end

            local v2831 = v1787(p238)

            if v2831 then
                return {
					cdn = v2831
				}
            end

            local v2832, v2833 = p238:match("rbxthumb://type=([%w]+)&id=(%d+)")

            if not v2833 then
                v2832, v2833 = p238:match("rbxthumb://[^%s]*type=([%w]+)[^%s]*id=(%d+)")
            end

            if v2833 then
                local v2834 = string.lower((tostring(v2832 or "asset")))

                if v2834 == "avatarheadshot" or v2834 == "avatarbust" or v2834 == "avatar" then
                    return {
						kind = "user",
						id = v2833
					}
                end

                if v2834 == "bundlethumbnail" or v2834 == "bundle" then
                    return {
						kind = "bundle",
						id = v2833
					}
                end

                return {
					kind = "asset",
					id = v2833
				}
            end

            local v2835 = p238:match("rbxassetid://(%d+)") or (p238:match("[?&]assetId=(%d+)") or (p238:match("[?&]assetid=(%d+)") or (p238:match("/asset/%?id=(%d+)") or p238:match("[?&]id=(%d+)"))))

            if v2835 then
                return {
					kind = "asset",
					id = v2835
				}
            end
        end
        local function v1790(p239)
            local v2837 = syn and syn.request or (http_request or (request or (http and http.request or fluxus and fluxus.request)))

            if not v2837 then
                return
            end

            for i = 1, 3 do
                local ok25, result25 = pcall(v2837, {
					Url = p239,
					Method = "GET",
					Headers = {
						Accept = "application/json"
					}
				})

                if (ok25 and (type(result25) == "table" and tonumber(result25.StatusCode or (result25.status_code or result25.Status)))) ~= 429 then
                    if not ok25 or type(result25) ~= "table" then
                        return
                    end
                    local v2841 = result25.Body or result25.body
                    if type(v2841) == "table" then
                        return v2841
                    end
                    if type(v2841) ~= "string" or v2841 == "" then
                        return
                    end
                    local data
                    pcall(function()
                        data = HttpService:JSONDecode(v2841)
                    end)

                    return data, v2841
                end

                task.wait(i * 0.45)
            end
        end
        local function v1791(p240)
            if type(p240) ~= "string" then
                return
            end
            local g2869
            local g2871
            local g2873
            local g2875
            local n20
            local n19
            for match, v2864 in p240:gsub("\\/", "/"):gmatch("\"targetId\":(%d+).-?\"imageUrl\":\"(https://[^\"]+)\"") do
                local str3 = tostring(match or "")
                local v2866 = v1787(v2864)

                if str3 == "" or not v2866 then
                    continue
                end

                local v2867 = t169[str3]

                if v2867 then
                    if v1788(v2866) then
                        n19 = 3
                        g2869 = true
                    end

                    if not g2869 then
                        local v2870 = v1787(v2866)

                        repeat
                            if not g2871 and v2870 then
                                if type(v2870) == "string" and string.find(v2870, "PrivateImage", 1, true) ~= nil then
                                    g2871 = true
                                end
                            else
                                g2871 = false
                                v2870 = nil
                            end
                        until not g2871

                        n19 = if not v2870 then not (type(v2866) == "string" and string.find(v2866, "PrivateImage", 1, true) ~= nil) and 0 or 1 else 2
                    end

                    g2869 = false

                    if v1788(v2867) then
                        n20 = 3
                        g2873 = true
                    end

                    if not g2873 then
                        local v2874 = v1787(v2867)

                        repeat
                            if not g2875 and v2874 then
                                if type(v2874) == "string" and string.find(v2874, "PrivateImage", 1, true) ~= nil then
                                    g2875 = true
                                end
                            else
                                g2875 = false
                                v2874 = nil
                            end
                        until not g2875

                        n20 = if not v2874 then not (type(v2867) == "string" and string.find(v2867, "PrivateImage", 1, true) ~= nil) and 0 or 1 else 2
                    end

                    g2873 = false

                    if not (n20 < n19) then
                        continue
                    end
                end

                t169[str3] = v2866
            end
        end
        local function v1792(p241, p242)
            local v2878 = p241 and p241.data
            if type(v2878) ~= "table" then
                return
            end
            local g2889
            local g2891
            local g2893
            local g2895
            local n22
            local n21
            for i = 1, #v2878 do
                local v2880 = v2878[i]
                local str4 = tostring(v2880.targetId or (v2880.targetid or ""))

                if str4 == "" then
                    continue
                end

                local v2882 = string.lower((tostring(v2880.state or (v2880.State or ""))))
                local v2883

                if type(v2880) ~= "table" then
                    v2883 = nil
                else
                    local v2884 = string.lower((tostring(v2880.state or (v2880.State or ""))))

                    v2883 = if v2884 == "" or v2884 == "completed" then v1787(v2880.imageUrl or (v2880.imageurl or v2880.ImageUrl)) else nil
                end

                if v2883 then
                    local str5 = tostring(str4 or "")
                    local v2886 = v1787(v2883)

                    if str5 == "" or not v2886 then
                        continue
                    end

                    local v2887 = t169[str5]

                    if v2887 then
                        if v1788(v2886) then
                            n21 = 3
                            g2889 = true
                        end

                        if not g2889 then
                            local v2890 = v1787(v2886)

                            repeat
                                if not g2891 and v2890 then
                                    if type(v2890) == "string" and string.find(v2890, "PrivateImage", 1, true) ~= nil then
                                        g2891 = true
                                    end
                                else
                                    g2891 = false
                                    v2890 = nil
                                end
                            until not g2891

                            n21 = if not v2890 then not (type(v2886) == "string" and string.find(v2886, "PrivateImage", 1, true) ~= nil) and 0 or 1 else 2
                        end

                        g2889 = false

                        if v1788(v2887) then
                            n22 = 3
                            g2893 = true
                        end

                        if not g2893 then
                            local v2894 = v1787(v2887)

                            repeat
                                if not g2895 and v2894 then
                                    if type(v2894) == "string" and string.find(v2894, "PrivateImage", 1, true) ~= nil then
                                        g2895 = true
                                    end
                                else
                                    g2895 = false
                                    v2894 = nil
                                end
                            until not g2895

                            n22 = if not v2894 then not (type(v2887) == "string" and string.find(v2887, "PrivateImage", 1, true) ~= nil) and 0 or 1 else 2
                        end

                        g2893 = false

                        if not (n22 < n21) then
                            continue
                        end
                    end

                    t169[str5] = v2886

                    continue
                end

                if p242 and v2882 == "pending" then
                    p242[#p242 + 1] = str4
                end
            end
        end
        local function v1793(p243)
            if type(p243) ~= "table" or #p243 == 0 then
                return
            end

            local function v2897(p244, p245, p246)
                if type(p244) ~= "table" or #p244 == 0 then
                    return {}
                end

                local t172 = {}
                local v4616, v4617 = v1790("https://thumbnails.roblox.com/v1/" .. p245 .. table.concat(p244, ",") .. "&size=" .. p246 .. "&format=Png&isCircular=false")

                v1791(v4617)
                v1792(v4616, t172)

                if #p244 == 1 and type(v4617) == "string" then
                    local v4618 = v4617:gsub("\\/", "/"):match("\"imageUrl\":\"(https://[^\"]+)\"")

                    if not v4618 then
                        return t172
                    end

                    local str6 = tostring(p244[1] or "")
                    local v4620 = v1787(v4618)

                    if str6 ~= "" then
                        if not v4620 then
                            return t172
                        end
                        local v4621 = t169[str6]
                        local g4622
                        local g4624
                        local g4626
                        local v4625
                        local g4628
                        local g4630
                        local v4629
                        local n24
                        local n23
                        repeat
                            if g4622 or not v4621 then
                                g4622 = false
                                t169[str6] = v4620

                                return t172
                            end

                            if v1788(v4620) then
                                n23 = 3
                                g4624 = true
                            end

                            if not g4624 then
                                v4625 = v1787(v4620)
                            end

                            repeat
                                if g4624 or (g4626 or v4625) then
                                    if g4624 or (g4626 or (type(v4625) ~= "string" or string.find(v4625, "PrivateImage", 1, true) == nil)) then
                                        if not g4624 then
                                            g4626 = false
                                            n23 = if not v4625 then not (type(v4620) == "string" and string.find(v4620, "PrivateImage", 1, true) ~= nil) and 0 or 1 else 2
                                        end

                                        g4624 = false

                                        if v1788(v4621) then
                                            n24 = 3
                                            g4628 = true
                                        end

                                        if not g4628 then
                                            v4629 = v1787(v4621)
                                        end

                                        repeat
                                            if g4628 or (g4630 or v4629) then
                                                if g4628 or (g4630 or (type(v4629) ~= "string" or string.find(v4629, "PrivateImage", 1, true) == nil)) then
                                                    if not g4628 then
                                                        g4630 = false
                                                        n24 = if not v4629 then not (type(v4621) == "string" and string.find(v4621, "PrivateImage", 1, true) ~= nil) and 0 or 1 else 2
                                                    end

                                                    g4628 = false

                                                    if n24 < n23 then
                                                        g4622 = true
                                                    end

                                                    if not g4622 then
                                                        return t172
                                                    end
                                                end
                                            end

                                            if g4622 then
                                                break
                                            end

                                            v4629 = nil
                                            g4630 = true
                                        until not g4630
                                    end
                                end

                                if g4622 then
                                    break
                                end

                                v4625 = nil
                                g4626 = true
                            until not g4626
                        until not g4622
                    end
                end

                return t172
            end

            local v2898 = v2897(p243, "assets?assetIds=", "150x150")
            local t173 = {}

            for i = 1, #p243 do
                if not v1788(t169[tostring(p243[i])]) then
                    t173[#t173 + 1] = tostring(p243[i])
                end
            end

            if #t173 > 0 then
                v2897(t173, "assets?assetIds=", "420x420")
            end

            if type(v2898) == "table" and #v2898 > 0 then
                task.wait(0.4)
                v2897(v2898, "assets?assetIds=", "150x150")
            end

            local v2901 = (function()
                local t174 = {}
                local t175 = {}

                for i = 1, #p243 do
                    local str7 = tostring(p243[i])

                    if str7 ~= "" and not t175[str7] and type(t169[str7]) ~= "string" then
                        t175[str7] = true
                        t174[#t174 + 1] = str7
                    end
                end

                return t174
            end)()

            if #v2901 > 0 then
                v2897(v2901, "bundles/thumbnails?bundleIds=", "150x150")
            end
        end
        local function v1794(p247, p248, p249)
            local t176 = {}
            local t177 = {}
            local v2907 = v1786(p247, p248)

            if type(v2907) == "string" and (v2907 ~= "" and not t177[v2907]) then
                t177[v2907] = true
                t176[#t176 + 1] = v2907
            end

            if type(p249) == "string" and p249 ~= "" and not t177[p249] then
                t177[p249] = true
                t176[#t176 + 1] = p249
            end

            if type(p247) == "table" then
                local v2908 = v1784(p247.Icon)

                if type(v2908) == "string" and v2908 ~= "" and not t177[v2908] then
                    t177[v2908] = true
                    t176[#t176 + 1] = v2908
                end

                for i = 1, #t170 do
                    local v2910 = v1784(p247[t170[i]])

                    if type(v2910) == "string" and v2910 ~= "" and not t177[v2910] then
                        t177[v2910] = true
                        t176[#t176 + 1] = v2910
                    end
                end
            end

            return t176
        end
        local function v1795(p250, p251, p252)
            local v2914 = v1794(p251, p252, p250)
            local t178 = {}
            local t179 = {}
            local u2917
            local u2918
            local function v2919(p253)
                local v4633 = v1787(p253)
                if not v4633 then
                    return
                end
                local g4644
                local g4646
                local g4648
                local v4647
                local g4651
                local g4653
                local v4652
                local n28
                local n27
                if type(v4633) == "string" and string.find(v4633, "PrivateImage", 1, true) ~= nil then
                    local g4634
                    local g4636
                    local g4638
                    local v4637
                    local g4641
                    local g4643
                    local v4642
                    local n26
                    local n25
                    repeat
                        if g4634 or not u2918 then
                            g4634 = false
                            u2918 = v4633

                            return
                        end

                        if v1788(v4633) then
                            n25 = 3
                            g4636 = true
                        end

                        if not g4636 then
                            v4637 = v1787(v4633)
                        end

                        repeat
                            if g4636 or (g4638 or v4637) then
                                if g4636 or (g4638 or (type(v4637) ~= "string" or string.find(v4637, "PrivateImage", 1, true) == nil)) then
                                    if not g4636 then
                                        n25 = if not v4637 then not (type(v4633) == "string" and string.find(v4633, "PrivateImage", 1, true) ~= nil) and 0 or 1 else 2
                                    end

                                    g4636 = false

                                    local v4639 = u2918

                                    if v1788(v4639) then
                                        n26 = 3
                                        g4641 = true
                                    end

                                    if not g4641 then
                                        v4642 = v1787(v4639)
                                    end

                                    repeat
                                        if g4641 or (g4643 or v4642) then
                                            if g4641 or (g4643 or (type(v4642) ~= "string" or string.find(v4642, "PrivateImage", 1, true) == nil)) then
                                                if not g4641 then
                                                    n26 = if not v4642 then not (type(v4639) == "string" and string.find(v4639, "PrivateImage", 1, true) ~= nil) and 0 or 1 else 2
                                                end

                                                g4641 = false

                                                if n26 < n25 then
                                                    g4634 = true
                                                end

                                                if not g4634 then
                                                    return
                                                end
                                            end
                                        end

                                        if g4634 then
                                            break
                                        end

                                        v4642 = nil
                                        g4643 = true
                                    until not g4643
                                end
                            end

                            if g4634 then
                                break
                            end

                            v4637 = nil
                            g4638 = true
                        until not g4638
                    until not g4634
                end
                repeat
                    if g4644 or not u2917 then
                        g4644 = false
                        u2917 = v4633

                        return
                    end

                    if v1788(v4633) then
                        n27 = 3
                        g4646 = true
                    end

                    if not g4646 then
                        v4647 = v1787(v4633)
                    end

                    repeat
                        if g4646 or (g4648 or v4647) then
                            if g4646 or (g4648 or (type(v4647) ~= "string" or string.find(v4647, "PrivateImage", 1, true) == nil)) then
                                if not g4646 then
                                    g4648 = false
                                    n27 = if not v4647 then not (type(v4633) == "string" and string.find(v4633, "PrivateImage", 1, true) ~= nil) and 0 or 1 else 2
                                end

                                g4646 = false

                                local v4649 = u2917

                                if v1788(v4649) then
                                    n28 = 3
                                    g4651 = true
                                end

                                if not g4651 then
                                    v4652 = v1787(v4649)
                                end

                                repeat
                                    if g4651 or (g4653 or v4652) then
                                        if g4651 or (g4653 or (type(v4652) ~= "string" or string.find(v4652, "PrivateImage", 1, true) == nil)) then
                                            if not g4651 then
                                                g4653 = false
                                                n28 = if not v4652 then not (type(v4649) == "string" and string.find(v4649, "PrivateImage", 1, true) ~= nil) and 0 or 1 else 2
                                            end

                                            g4651 = false

                                            if not (n28 < n27) then
                                                return
                                            end

                                            g4644 = true
                                        end
                                    end

                                    if g4644 then
                                        break
                                    end

                                    v4652 = nil
                                    g4653 = true
                                until not g4653
                            end
                        end

                        if g4644 then
                            break
                        end

                        v4647 = nil
                        g4648 = true
                    until not g4648
                until not g4644
            end
            local g2927
            for i = 1, #v2914 do
                local v2921 = v1789(v2914[i])

                if v2921 then
                    if v2921.cdn then
                        v2919(v2921.cdn)
                    end

                    if v2921.id and not t179[v2921.id] then
                        t179[v2921.id] = true
                        t178[#t178 + 1] = v2921.id
                        v2919(t169[v2921.id])
                    end
                end
            end
            v1793(t178)
            for i = 1, #t178 do
                v2919(t169[t178[i]])
            end
            local v2923 = v1788(u2917) or u2917
            if not v1788(v2923) then
                for i = 1, #t178 do
                    local v2925 = v1788(t169[t178[i]])

                    if not v2925 then
                        local v2926 = t169[t178[i]]

                        v2925 = v1787(v2926)

                        repeat
                            if not g2927 and v2925 then
                                if type(v2925) == "string" and string.find(v2925, "PrivateImage", 1, true) ~= nil then
                                    g2927 = true
                                end
                            else
                                g2927 = false
                                v2925 = nil
                            end
                        until not g2927
                    end

                    if v2925 then
                        v2923 = v2925

                        if v1788(v2925) then
                            break
                        end
                    end
                end
            end

            return v2923, t178, u2917, u2918
        end

        local t180 = {}

        local function v1797(p254)
            local str8 = tostring(p254 or "")

            if str8 == "" or str8 == "0" then
                return
            end

            if type(t180[str8]) == "string" then
                return t180[str8]
            end

            local v2930 = v1790("https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. str8 .. "&size=150x150&format=Png&isCircular=false")
            local v2931 = v2930 and (v2930.data and v2930.data[1])
            local v2932

            if type(v2931) ~= "table" then
                v2932 = nil
            else
                local v2933 = string.lower((tostring(v2931.state or (v2931.State or ""))))

                v2932 = if v2933 == "" or v2933 == "completed" then v1787(v2931.imageUrl or (v2931.imageurl or v2931.ImageUrl)) else nil
            end

            if v2932 then
                t180[str8] = v2932
            end

            return v2932
        end
        local function v1798(p255, p256)
            local v2936
            if type(p255) == "table" then
                v2936 = tonumber(p255.Weight) or (tonumber(p255.ModelWeight) or (tonumber(p255.Kg) or tonumber(p255.BaseWeight)))
            end
            if (not v2936 or v2936 <= 0) and type(p256) == "table" then
                v2936 = tonumber(p256.Weight) or (tonumber(p256.BaseWeight) or tonumber(p256.ModelWeight))
            end
            if not v2936 or v2936 <= 0 then
                return
            end
            if v2936 >= 100 then
                return string.format("%.0f kg", v2936)
            end

            return string.format("%.1f kg", v2936)
        end
        local function v1799(p257)
            if type(p257) ~= "table" or (type(p257.Mutations) ~= "table" or #p257.Mutations == 0) then
                return
            end

            return table.concat(p257.Mutations, " · ")
        end
        local function v1800()
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            local v2939 = PlayerGui and PlayerGui:FindFirstChild("HUD")
            local v2940 = v2939 and v2939:FindFirstChild("GameHUD")
            local v2941 = v2940 and v2940:FindFirstChild("BottomLeft")
            local v2942 = v2941 and v2941:FindFirstChild("Money")
            local v2943 = v2942 and v2942:FindFirstChild("Value")

            if v2943 and ((v2943:IsA("TextLabel") or v2943:IsA("TextButton")) and v2943.Text ~= "") then
                return v2943.Text
            end

            local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
            local v2945 = leaderstats and (leaderstats:FindFirstChild("Money") or (leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Coins")))

            if v2945 and v2945:IsA("ValueBase") then
                return "$" .. v1781(v2945.Value)
            end

            return "—"
        end
        local function v1801()
            local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
            local v2947 = leaderstats and (leaderstats:FindFirstChild("Money/s") or leaderstats:FindFirstChild("Income"))

            if v2947 and v2947:IsA("ValueBase") then
                return v1781(v2947.Value) .. "/s"
            end

            return "—"
        end
        local function v1802(p258, p259, p260)
            if p259 == nil or p259 == "" then
                return
            end

            return {
				name = tostring(p258),
				value = tostring(p259),
				inline = p260 ~= false
			}
        end
        local function v1803(...)
            local t181 = {}

            for i = 1, select("#", ...) do
                local v2953 = select(i, ...)

                if v2953 then
                    t181[#t181 + 1] = v2953
                end
            end

            if #t181 == 0 then
                return
            end

            return t181
        end
        local function v1804()
            if t9.HookUsername == true then
                local t182 = {
					name = tostring(LocalPlayer.DisplayName or LocalPlayer.Name),
					url = "https://www.roblox.com/users/" .. tostring(LocalPlayer.UserId) .. "/profile"
				}
                local v2955 = v1797(LocalPlayer.UserId)

                if v2955 then
                    t182.icon_url = v2955
                end

                return t182
            end

            return {
				name = "NEXUS Hub"
			}
        end
        local function v1805(p261)
            if type(p261) ~= "table" then
                return true
            end

            if p261.Success == false or p261.success == false then
                return false
            end

            local num = tonumber(p261.StatusCode or (p261.status_code or p261.Status))

            if num and num >= 400 then
                return false, num
            end

            return true, num
        end
        local function v1806(p262)
            if type(p262) ~= "string" or #p262 < 12 then
                return
            end

            local v2959, v2960, v2961, v2962 = string.byte(p262, 1, 4)

            if v2959 == 137 and v2960 == 80 and v2961 == 78 and v2962 == 71 then
                return "image/png", "png"
            end

            if v2959 == 255 and v2960 == 216 then
                return "image/jpeg", "jpg"
            end

            if v2959 == 71 and v2960 == 73 and v2961 == 70 then
                return "image/gif", "gif"
            end

            if v2959 == 82 and v2960 == 73 and v2961 == 70 and v2962 == 70 and string.sub(p262, 9, 12) == "WEBP" then
                return "image/webp", "webp"
            end
        end
        local function v1807(p263, p264)
            if type(p263) ~= "string" or #p263 < 32 then
                return false
            end

            if p264 == "png" then
                return string.find(p263, "IEND", 1, true) ~= nil
            end

            if p264 == "jpg" then
                local v2965 = #p263

                return string.byte(p263, v2965 - 1) == 255 and string.byte(p263, v2965) == 217
            end

            if p264 == "gif" then
                return #p263 > 64
            end

            return false
        end
        local function v1808(p265, p266)
            local v2968 = p265 and (p265.Headers or p265.headers)

            if type(v2968) ~= "table" then
                return
            end

            local v2969 = string.lower(p266)

            for k, v in pairs(v2968) do
                if v2969 == string.lower((tostring(k))) then
                    return v
                end
            end
        end
        local function v1809(p267)
            if type(p267) ~= "string" then
                return
            end

            local u2973 = p267:gsub("^http://", "https://")

            if not string.find(u2973, "^https://") then
                return
            end

            local function v2974(p268)
                local v4655, v4656 = v1806(p268)

                if v4655 and (v4656 ~= "webp" and v1807(p268, v4656)) then
                    return p268, v4655, v4656
                end
            end

            if string.find(u2973, "rbxcdn.com", 1, true) and type(game.HttpGet) == "function" then
                local ok26, result26 = pcall(game.HttpGet, game, u2973)

                if ok26 then
                    local v2977, v2978 = v1806(result26)

                    if if not v2977 or (v2978 == "webp" or not v1807(result26, v2978)) then nil else result26 then
                        return v2974(result26)
                    end
                end
            end

            local v2979 = syn and syn.request or (http_request or (request or (http and http.request or fluxus and fluxus.request)))

            if v2979 then
                for _ = 1, 5 do
                    local ok27, result27 = pcall(v2979, {
						Url = u2973,
						Method = "GET",
						Headers = {
							Accept = "image/png,image/jpeg,image/*;q=0.8,*/*;q=0.1"
						}
					})

                    if not ok27 or type(result27) ~= "table" then
                        break
                    end

                    local v2983 = result27.Body or result27.body
                    local v2984, v2985 = v1806(v2983)

                    if if not v2984 or (v2985 == "webp" or not v1807(v2983, v2985)) then nil else v2983 then
                        return v2974(v2983)
                    end

                    local v2986 = v1808(result27, "Location")

                    if type(v2986) ~= "string" or v2986 == "" then
                        break
                    end

                    if string.find(v2986, "^https?://") then
                        u2973 = v2986:gsub("^http://", "https://")
                    else
                        if string.sub(v2986, 1, 1) ~= "/" then
                            break
                        end

                        local v2987 = u2973:match("^(https://[^/]+)")

                        if not v2987 then
                            break
                        end

                        u2973 = v2987 .. v2986
                    end
                end
            end

            local ok28, result28 = pcall(function()
                if type(game.HttpGet) == "function" then
                    return game:HttpGet(u2973)
                end
            end)

            if ok28 then
                return v2974(result28)
            end
        end
        local function v1810(p269, p270, p271)
            local v2993 = syn and syn.request or (http_request or (request or (http and http.request or fluxus and fluxus.request)))
            local ok29, result29 = pcall(function()
                return HttpService:JSONEncode(p270)
            end)

            if not ok29 or type(result29) ~= "string" then
                return false, "encode"
            end

            if p271 and p271.bytes then
                local v2996 = "NEXUS" .. tostring(math.floor(os.clock() * 1000000)) .. tostring(math.random(100000, 999999))
                local v2997 = "--" .. v2996 .. "\r\n" .. "Content-Disposition: form-data; name=\"payload_json\"" .. "\r\n" .. "\r\n" .. result29 .. "\r\n" .. "--" .. v2996 .. "\r\n" .. "Content-Disposition: form-data; name=\"files[0]\"; filename=\"" .. (p271.name or "icon.png") .. "\"" .. "\r\n" .. "Content-Type: " .. (p271.mime or "image/png") .. "\r\n" .. "Content-Transfer-Encoding: binary" .. "\r\n" .. "\r\n" .. p271.bytes .. "\r\n" .. "--" .. v2996 .. "--\r\n"

                if not string.find(p269, "wait=", 1, true) then
                    p269 ..= (not string.find(p269, "?", 1, true) and "?" or "&") .. "wait=true"
                end

                local ok30, result30 = pcall(v2993, {
					Url = p269,
					Method = "POST",
					Headers = {
						["Content-Type"] = "multipart/form-data; boundary=" .. v2996,
						["Content-Length"] = tostring(#v2997)
					},
					Body = v2997
				})

                if ok30 and select(1, v1805(result30)) then
                    local v3000 = result30 and (result30.Body or result30.body)
                    local v3001

                    if type(v3000) ~= "string" or v3000 == "" then
                        v3001 = false
                    else
                        local num = tonumber(v3000:match("\"code\"%s*:%s*(%d+)"))

                        v3001 = num ~= nil and num >= 10000
                    end

                    if not v3001 then
                        return true, result30
                    end
                end

                return false, "multipart"
            end

            local ok31, result31 = pcall(v2993, {
				Url = p269,
				Method = "POST",
				Headers = {
					["Content-Type"] = "application/json"
				},
				Body = result29
			})

            if not ok31 then
                return false, (tostring(result31))
            end

            local v3005, v3006

            if type(result31) ~= "table" then
                v3005 = true
                v3006 = nil
            elseif result31.Success == false or result31.success == false then
                v3005 = false
                v3006 = nil
            else
                v3006 = tonumber(result31.StatusCode or (result31.status_code or result31.Status))

                if v3006 and v3006 >= 400 then
                    v3005 = false
                else
                    v3005 = true
                end
            end

            if not v3005 then
                return false, "http " .. tostring(v3006)
            end

            return true, result31
        end
        local function v1811(p272)
            if t9.HookEnabled ~= true then
                return false, "off"
            end
            local HookUrl = t9.HookUrl
            if type(HookUrl) ~= "string" or not string.find(HookUrl, "^https://") then
                return false, "no url"
            end
            if (not syn or not syn.request) and (not http_request and (not request and ((not http or not http.request) and (not fluxus or not fluxus.request)))) then
                return false, "no http"
            end
            local v3009, v3010, v3011, v3012 = v1795(p272.thumbnail, p272.cfg, p272.cat)
            local str9 = tostring(p272.title or "NEXUS")
            local v3014
            local g3028
            local str10
            local s17
            if #str9 > 256 then
                v3014 = str9
                str9 = string.sub(str9, 1, 253) .. "..."
            end
            local t183 = {
				author = v1804(),
				title = str9,
				color = tonumber(p272.color) or 11393254,
				timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
			}
            local t184 = {}
            local Discord = t1.Discord
            local v3018 = tostring(((if type(Discord) == "string" and Discord:match("%S") ~= nil then (if not Discord:find("discord%.", 1) and not Discord:find("http", 1, true) then "discord.gg/" .. Discord else Discord) else nil)) or (t1.Discord or "")):gsub("^https://", "")
            t184.text = v3018 == "" and "NEXUS Hub" or "NEXUS Hub · " .. v3018
            t183.footer = t184
            local v3019 = p272.description and tostring(p272.description) or ""
            if v3014 then
                v3019 = v3019 ~= "" and v3014 .. "\n" .. v3019 or v3014
            end
            if v3019 ~= "" then
                t183.description = v3019
            end
            if p272.fields then
                t183.fields = p272.fields
            end
            if p272.url then
                t183.url = p272.url
            end
            local t186
            local t185 = {}
            local function v3022(p273)
                if type(p273) ~= "string" or p273 == "" or t185[p273] then
                    return
                end

                t185[p273] = true

                local v4661, v4662, v4663 = v1809(p273)

                if v4661 and v4663 then
                    t186 = {
						bytes = v4661,
						mime = v4662,
						name = "icon." .. v4663
					}

                    return true
                end
            end
            local function v3023(p274)
                local v4665 = v1787(p274)

                if not v4665 then
                    return
                end

                local v4666 = v4665:match("(180DAY%-[%w%-]+)") or v4665:match("rbxcdn%.com/([%w%-]+)/")

                if not v4666 then
                    return
                end

                return {
					"https://tr.rbxcdn.com/" .. v4666 .. "/150/150/Image/Png/noFilter",
					"https://tr.rbxcdn.com/" .. v4666 .. "/420/420/Image/Png/noFilter"
				}
            end
            local function v3024(p275)
                if v3022(p275) then
                    return true
                end

                local v4668 = v3023(p275)

                if type(v4668) ~= "table" then
                    return
                end

                for i = 1, #v4668 do
                    if v3022(v4668[i]) then
                        return true
                    end
                end
            end
            local t187 = {
				username = "NEXUS Hub",
				embeds = { t183 }
			}
            local HookPing = t9.HookPing
            if HookPing == "Here" then
                s17 = "@here"
                g3028 = true
            end
            repeat
                if g3028 or (g3028 or HookPing == "User id") then
                    if not g3028 then
                        if not g3028 then
                            str10 = tostring(t9.HookUserId or "")
                        end
                    end

                    if g3028 or (g3028 or str10 ~= "" and str10 ~= "0") then
                        if not g3028 then
                            if not g3028 then
                                s17 = "<@" .. str10 .. ">"
                            end
                        end

                        g3028 = false

                        if s17 then
                            t187.content = s17
                        end

                        local v3030 = v1788(v3011) or v1788(v3009)

                        if not v3030 and type(v3010) == "table" then
                            for i = 1, #v3010 do
                                local v3032 = t169[v3010[i]]

                                v3030 = v1788(v3032)

                                if v3030 then
                                    break
                                end
                            end
                        end

                        if not v3030 then
                            v3030 = v1788(v3012)
                        end

                        if v3030 then
                            t183.thumbnail = {
								url = v3030
							}

                            return v1810(HookUrl, t187)
                        end

                        if not t186 then
                            v3024(v3012)
                            v3024(v3009)
                            v3024(v3011)

                            if not t186 and type(v3010) == "table" then
                                for i = 1, math.min(#v3010, 8) do
                                    v3024(t169[v3010[i]])

                                    if t186 then
                                        break
                                    end

                                    local str11 = tostring(v3010[i])

                                    v3022("https://assetdelivery.roblox.com/v1/asset/?id=" .. str11)
                                    v3022("https://www.roblox.com/asset-thumbnail/image?assetId=" .. str11 .. "&width=150&height=150&format=png")

                                    if t186 then
                                        break
                                    end
                                end
                            end
                        end

                        if t186 then
                            t183.thumbnail = {
								url = "attachment://" .. t186.name
							}
                            t187.attachments = {{
								id = 0,
								filename = t186.name
							}}

                            if select(1, v1810(HookUrl, t187, t186)) then
                                return true
                            end

                            t187.attachments = nil
                        end

                        t183.thumbnail = nil

                        return v1810(HookUrl, t187)
                    end
                end

                s17 = nil
                g3028 = true
            until not g3028
        end
        local function v1812(p276)
            if type(p276) ~= "table" then
                return nil, nil, nil
            end

            local rec = p276.rec
            local cfg = p276.cfg
            local v3039 = p276.cat or rec and (rec.AssetCategory or rec.Category)

            if type(cfg) ~= "table" and v3039 then
                cfg = if not not Directory and v3039 then Directory[v3039] else nil
            end

            if type(cfg) ~= "table" and type(Directory) == "table" then
                local v3040 = string.lower((tostring(p276.name or (v3039 or ""))))

                if v3040 ~= "" and v3040 ~= "egg" and v3040 ~= "?" then
                    for k, v in pairs(Directory) do
                        if type(v) == "table" and (v3040 == string.lower((tostring(k))) or v3040 == string.lower((tostring(v.DisplayName or "")))) then
                            return rec, v, (tostring(k))
                        end
                    end
                end
            end

            return rec, cfg, v3039
        end
        local function v1813()
            if t9.HookEnabled ~= true or t9.SessionDigest ~= true then
                return
            end

            local elapsed10 = os.clock()

            if elapsed10 - elapsed8 < 600 then
                return
            end

            elapsed8 = elapsed10

            local v3109 = u1135 and (not not u1135.stats and u1135.stats()) or {}
            local v3110 = (tonumber(v3109.soldPets) or 0) + (tonumber(v3109.soldEggs) or 0)
            local v3111 = tostring(v3109.soldPets or 0) .. " pets · " .. tostring(v3109.soldEggs or 0) .. " eggs"
            local t188 = {
				kind = "Session recap",
				title = v1783() .. " running",
				description = "Totals since this execute — not just the last 10 minutes.",
				color = 9807270
			}
            local v3113 = v1803
            local str12 = tostring(t216 and t216.banked or 0)
            local v3115 = if str12 ~= nil and str12 ~= "" then {
				name = tostring("Stolen"),
				value = tostring(str12),
				inline = true
			} else nil
            local str13 = tostring(t216 and t216.lost or 0)
            local v3117 = if str13 ~= nil and str13 ~= "" then {
				name = tostring("Lost"),
				value = tostring(str13),
				inline = true
			} else nil
            local str14 = tostring(t216 and t216.regrabs or 0)
            local v3119 = if str14 ~= nil and str14 ~= "" then {
				name = tostring("Re-grabs"),
				value = tostring(str14),
				inline = true
			} else nil
            local str15 = tostring(v3109.hatched or 0)
            local v3121 = if str15 ~= nil and str15 ~= "" then {
				name = tostring("Hatched"),
				value = tostring(str15),
				inline = true
			} else nil
            local v3122 = v3110 > 0 and v3111 or "0"
            local v3123 = if v3122 ~= nil and v3122 ~= "" then {
				name = tostring("Sold"),
				value = tostring(v3122),
				inline = true
			} else nil
            local str16 = tostring(v3109.claimIndex or 0)
            local v3125 = if str16 ~= nil and str16 ~= "" then {
				name = tostring("Index claims"),
				value = tostring(str16),
				inline = true
			} else nil
            local v3126 = v1800()

            t188.fields = v3113(v3115, v3117, v3119, v3121, v3123, v3125, if v3126 ~= nil and v3126 ~= "" then {
				name = tostring("Money"),
				value = tostring(v3126),
				inline = true
			} else nil, v1802("Income", (v1801())))

            if type(t188) ~= "table" then
                return
            end

            task.spawn(function()
                local v4681, v4682 = v1811(t188)

                if not v4681 then
                    v1102("hook", "send fail", tostring(v4682), (tostring(t188.title)))
                end
            end)
        end

        task.spawn(function()
            while u1117 do
                task.wait(30)
                pcall(v1813)
            end
        end)

        return {
			send = function(p277)
            if type(p277) ~= "table" then
                return false, "bad embed"
            end

            task.spawn(function()
                local v4671, v4672 = v1811(p277)

                if not v4671 then
                    v1102("hook", "send fail", tostring(v4672), (tostring(p277.title)))
                end
            end)

            return true
        end,
			test = function()
            t9.HookEnabled = true

            if t10.HookEnabled and t10.HookEnabled.set then
                pcall(t10.HookEnabled.set, true)
            end

            local v3102 = v1811
            local t189 = {
					kind = "Webhook test",
					title = "Connected",
					description = "Stolen and hatched eggs will post as embeds with the pet icon, $/s, and rarity.",
					color = 11393254
				}
            local v3104 = v1803
            local str17 = tostring(LocalPlayer.DisplayName or LocalPlayer.Name)
            local v3106 = if str17 ~= nil and str17 ~= "" then {
					name = tostring("Player"),
					value = tostring(str17),
					inline = true
				} else nil
            local str18 = tostring(t1.Game or "Roblox")

            t189.fields = v3104(v3106, if str18 ~= nil and str18 ~= "" then {
					name = tostring("Game"),
					value = tostring(str18),
					inline = true
				} else nil, v1802("Session", v1783()))

            return v3102(t189)
        end,
			stolen = function(p278)
            if t9.HookStolen ~= true then
                return
            end

            local v3044 = p278 or t216 and (t216.hookSnap or t216.target)
            local v3045, v3046, v3047 = v1812(v3044)
            local v3048 = v3044 and v3044.name

            if type(v3048) ~= "string" or v3048 == "" or v3048 == "egg" or v3048 == "?" then
                v3048 = v3046 and (v3046.DisplayName or v3046._id) or (v3047 and tostring(v3047) or nil)
            end

            local v3049 = v1193(v3045, v3046)

            if (not v3049 or v3049 == 0) and v3044 and tonumber(v3044.earn) then
                v3049 = v3044.earn
            end

            if (not v3049 or v3049 == 0) and type(v3046) == "table" then
                v3049 = if type(v3046) == "table" then tonumber(v3046.EarningRate) or 0 else 0
            end

            local v3050 = if type(v3046) == "table" and type(v3046.Rarity) == "table" then tostring(v3046.Rarity.DisplayName or (v3046.Rarity.Name or (v3046.Rarity._id or "?"))) else "?"

            if (not v3050 or v3050 == "?") and v3044 and type(v3044.rar) == "string" then
                v3050 = v3044.rar
            end

            if (not v3048 or v3048 == "egg") and type(v3046) ~= "table" then
                v1102("hook", "stolen skipped, no egg")

                return
            end

            local v3051 = v3048 or (v3046 and v3046.DisplayName or "egg")
            local v3052 = v1194(t9.HookMinGen)

            if v3052 > 0 and v3052 > (tonumber(v3049) or 0) or not v1782(v3050) then
                return
            end

            local t190 = {
					kind = "Egg stolen",
					title = tostring(v3051),
					color = t171[string.lower((tostring(v3050 or "")))] or 5814783,
					thumbnail = v3044 and v3044.icon or v1786(v3046, v3047, v3051),
					cfg = v3046,
					cat = v3047
				}
            local v3054 = v1803
            local v3055 = "**" .. v1781(v3049) .. "/s**"
            local v3056 = if v3055 ~= nil and v3055 ~= "" then {
					name = tostring("Earns"),
					value = tostring(v3055),
					inline = true
				} else nil
            local v3057 = if v3050 ~= nil and v3050 ~= "" then {
					name = tostring("Rarity"),
					value = tostring(v3050),
					inline = true
				} else nil
            local v3058, v3059 = v1192(v3046, v3045)
            local v3060 = if v3058 ~= nil and v3058 ~= "" then {
					name = tostring("Chance"),
					value = tostring(v3058),
					inline = v3059 ~= false
				} else nil
            local v3061, v3062 = v1798(v3045, v3046)
            local v3063 = if v3061 ~= nil and v3061 ~= "" then {
					name = tostring("Weight"),
					value = tostring(v3061),
					inline = v3062 ~= false
				} else nil
            local v3064, v3065

            if type(v3045) ~= "table" or type(v3045.Mutations) ~= "table" or #v3045.Mutations == 0 then
                v3064 = nil
                v3065 = nil
            else
                v3064, v3065 = table.concat(v3045.Mutations, " · ")
            end

            local v3066 = if v3064 ~= nil and v3064 ~= "" then {
					name = tostring("Mutations"),
					value = tostring(v3064),
					inline = v3065 ~= false
				} else nil
            local v3067 = v3044 and (v3044.area ~= "" and v3044.area) or nil

            t190.fields = v3054(v3056, v3057, v3060, v3063, v3066, if v3067 ~= nil and v3067 ~= "" then {
					name = tostring("Area"),
					value = tostring(v3067),
					inline = true
				} else nil, v1802("This session", tostring(t216 and t216.banked or 0) .. " stolen · " .. tostring(t216 and t216.lost or 0) .. " lost"))

            if type(t190) ~= "table" then
                return
            end

            task.spawn(function()
                local v4673, v4674 = v1811(t190)

                if not v4673 then
                    v1102("hook", "send fail", tostring(v4674), (tostring(t190.title)))
                end
            end)
        end,
			hatched = function(p279, p280, p281)
            if t9.HookHatched ~= true then
                return
            end

            local v3071 = type(p279) == "table" and p279 or {
					name = p279,
					earn = p280,
					rar = p281
				}
            local v3072 = v3071.name or "pet"
            local v3073 = v1193(v3071.rec, v3071.cfg)

            if v3073 == 0 and tonumber(v3071.earn) then
                v3073 = v3071.earn
            end

            local rar = v3071.rar

            if not rar then
                local cfg = v3071.cfg

                rar = ((if type(cfg) == "table" and type(cfg.Rarity) == "table" then tostring(cfg.Rarity.DisplayName or (cfg.Rarity.Name or (cfg.Rarity._id or "?"))) else "?")) or "?"
            end

            local v3076 = v1194(t9.HookMinGen)

            if v3076 > 0 and v3076 > (tonumber(v3073) or 0) or not v1782(rar) then
                return
            end

            local t191 = {
					kind = "Egg hatched",
					title = tostring(v3072),
					color = t171[string.lower((tostring(rar or "")))] or 3908956,
					thumbnail = v1786(v3071.cfg, v3071.cat, v3072),
					cfg = v3071.cfg,
					cat = v3071.cat
				}
            local v3078 = v1803
            local v3079 = "**" .. v1781(v3073) .. "/s**"
            local v3080 = if v3079 ~= nil and v3079 ~= "" then {
					name = tostring("Earns"),
					value = tostring(v3079),
					inline = true
				} else nil
            local v3081 = if rar ~= nil and rar ~= "" then {
					name = tostring("Rarity"),
					value = tostring(rar),
					inline = true
				} else nil
            local v3082, v3083 = v1192(v3071.cfg, v3071.rec)
            local v3084 = if v3082 ~= nil and v3082 ~= "" then {
					name = tostring("Chance"),
					value = tostring(v3082),
					inline = v3083 ~= false
				} else nil
            local v3085, v3086 = v1798(v3071.rec, v3071.cfg)

            t191.fields = v3078(v3080, v3081, v3084, if v3085 ~= nil and v3085 ~= "" then {
					name = tostring("Weight"),
					value = tostring(v3085),
					inline = v3086 ~= false
				} else nil, v1802("Mutations", v1799(v3071.rec)))

            if type(t191) ~= "table" then
                return
            end

            task.spawn(function()
                local v4675, v4676 = v1811(t191)

                if not v4675 then
                    v1102("hook", "send fail", tostring(v4676), (tostring(t191.title)))
                end
            end)
        end,
			sold = function(p282, p283, p284)
            if t9.HookSold ~= true then
                return
            end

            local v3090 = type(p282) == "table" and p282 or {
					kind = p282,
					name = p283,
					earn = p284
				}
            local v3091, v3092, v3093 = v1812(v3090)

            v3090.cfg = v3092 or v3090.cfg
            v3090.cat = v3093 or v3090.cat
            v3090.rec = v3091 or v3090.rec

            local v3094 = v3090.kind ~= "egg" and "pet" or "egg"
            local v3095 = v3092 and (if type(v3092) == "table" and type(v3092.Rarity) == "table" then tostring(v3092.Rarity.DisplayName or (v3092.Rarity.Name or (v3092.Rarity._id or "?"))) else "?") or nil
            local name = v3090.name

            if type(name) ~= "string" or name == "" or name == "egg" or name == "pet" then
                name = v3092 and v3092.DisplayName or (v3093 or v3094)
            end

            local t192 = {
					kind = v3094 ~= "egg" and "Sold a pet" or "Sold an egg",
					title = tostring(name),
					color = t171[string.lower((tostring(v3095 or "")))] or 15105570,
					thumbnail = v1786(v3092, v3093, name),
					cfg = v3092,
					cat = v3093
				}
            local v3098 = v1803
            local v3099 = "**" .. v1781(v1193(v3090.rec, v3092)) .. "/s**"

            t192.fields = v3098(if v3099 ~= nil and v3099 ~= "" then {
					name = tostring("Earns"),
					value = tostring(v3099),
					inline = true
				} else nil, if v3095 ~= nil and v3095 ~= "" then {
					name = tostring("Rarity"),
					value = tostring(v3095),
					inline = true
				} else nil, v1802("Chance", v1192(v3092, v3090.rec)))

            if type(t192) ~= "table" then
                return
            end

            task.spawn(function()
                local v4677, v4678 = v1811(t192)

                if not v4677 then
                    v1102("hook", "send fail", tostring(v4678), (tostring(t192.title)))
                end
            end)
        end,
			rewards = function(p285)
            if t9.HookRewards ~= true then
                return
            end

            local t193 = {
					kind = "Rewards claimed",
					title = "Index rewards",
					description = "Claimed **" .. tostring(p285) .. "** " .. (tonumber(p285) ~= 1 and "entries" or "entry"),
					color = 3447003
				}

            if type(t193) ~= "table" then
                return
            end

            task.spawn(function()
                local v4679, v4680 = v1811(t193)

                if not v4679 then
                    v1102("hook", "send fail", tostring(v4680), (tostring(t193.title)))
                end
            end)
        end
		}
    end)()
    local function v1196(p286)
        local t194 = {}

        if type(p286) ~= "table" then
            return t194
        end

        for _, v in ipairs(p286) do
            t194[string.lower((tostring(v)))] = true
        end

        return t194
    end
    local t195 = {}
    local n29 = 0
    local t202
    local n30 = 0
    local u1201
    local u1202 = false
    local function v1203()
        local v1820 = workspace:GetServerTimeNow() or 0
        local AreaEggCycleDisabledAt = workspace:GetAttribute("AreaEggCycleDisabledAt")

        if type(AreaEggCycleDisabledAt) == "number" then
            v1820 = math.min(v1820, AreaEggCycleDisabledAt)
        end

        local AreaEggCycleAnchorAt = workspace:GetAttribute("AreaEggCycleAnchorAt")
        local AreaEggCycleAnchorIndex = workspace:GetAttribute("AreaEggCycleAnchorIndex")

        if type(AreaEggCycleAnchorAt) ~= "number" then
            AreaEggCycleAnchorAt = 0
        end

        if type(AreaEggCycleAnchorIndex) ~= "number" then
            AreaEggCycleAnchorIndex = 0
        end

        return math.max(0, AreaEggCycleAnchorIndex + math.floor((v1820 - AreaEggCycleAnchorAt) / 300))
    end
    local function v1204(p287)
        local elapsed11 = os.clock()
        local v1826 = v1203()

        if v1826 ~= u1201 then
            u1201 = v1826
            p287 = true
            u1202 = true
            n30 = 0
            t195 = {}

            if t216 then
                t216.eggResetAt = os.clock()
                t216.eggResetN = 0
                t216.eggResetGrew = 0
            end
        end

        if not p287 and type(t195) == "table" and elapsed11 - n29 < 0.4 then
            return t195
        end

        if not u1103 then
            return t195
        end

        local v1827 = u1103.ReadFieldEggs or u1103.SyncFieldEggs

        if type(v1827) ~= "function" then
            return t195
        end

        local ok32, result32, _, _ = pcall(v1827)

        if not ok32 then
            v1102("eggs", "ERR", "ReadFieldEggs", (tostring(result32)))
            result32 = nil
        end

        if type(result32) ~= "table" or type(result32.Records) ~= "table" then
            n29 = elapsed11 - 0.28

            return t195
        end

        local t196 = {}
        local t197 = {}

        for _, v in pairs(result32.Records) do
            if type(v) == "table" and v.Uid and not t197[v.Uid] then
                t197[v.Uid] = true
                t196[#t196 + 1] = v
            end
        end

        if #t196 == 0 and #t195 > 0 and elapsed11 - n30 < 2.5 then
            n29 = elapsed11

            return t195
        end

        t195 = t196
        n29 = elapsed11

        if #t196 > 0 then
            n30 = elapsed11
        end

        if t216 and (t216.eggResetAt or 0) > 0 and (t216.eggResetN or 0) < #t196 then
            t216.eggResetN = #t196
            t216.eggResetGrew = elapsed11
        end

        return t196
    end
    pcall(function()
        local v1836 = u1103 and u1103.FieldRefreshed

        if type(v1836) == "table" and type(v1836.Connect) == "function" then
            local connection10 = v1836:Connect(function()
                local v3127 = type(t195) == "table" and #t195 or 0

                n29 = 0
                n30 = 0
                u1202 = true

                if t216 and v3127 > 6 then
                    t216.eggResetAt = os.clock()
                    t216.eggResetN = 0
                    t216.eggResetGrew = 0
                end
            end)

            if connection10 then
                t152[connection10] = true
            end
        end
    end)
    local function v1205(p288, p289)
        local t198 = {}

        for _, v in ipairs(p288) do
            t198[string.lower((tostring(v)))] = true
        end

        local t199 = {}

        for _, v in ipairs(p289) do
            local str19 = tostring(v or "")

            if str19 ~= "" and str19 ~= "nil" and not t198[string.lower(str19)] then
                p288[#p288 + 1] = str19
                t198[string.lower(str19)] = true
                t199[#t199 + 1] = str19
            end
        end

        return t199
    end
    local function v1206(p290, p291)
        if type(p291) ~= "table" or #p291 == 0 then
            return
        end

        local v1849 = t9[p290]

        if type(v1849) ~= "table" then
            return
        end

        local t200 = {}
        local t201 = {}

        for i = 1, #v1849 do
            local str20 = tostring(v1849[i])

            t201[#t201 + 1] = v1849[i]
            t200[str20] = true
        end

        local v1854 = false

        for i = 1, #p291 do
            local str21 = tostring(p291[i])

            if str21 ~= "" and str21 ~= "nil" and not t200[str21] then
                t201[#t201 + 1] = str21
                t200[str21] = true
                v1854 = true
            end
        end

        if not v1854 then
            return
        end

        t9[p290] = t201

        local v1857 = t10[p290]

        if v1857 and v1857.set then
            v1857.set(t201)
        end
    end
    local function v1207(p292, p293, p294)
        local v1861 = t10[p292]
        local v1862 = v1861 and v1861.options

        if type(v1862) ~= "table" then
            return
        end

        local v1863 = t9[p292]

        for i = #v1862, 1, -1 do
            v1862[i] = nil
        end

        for _, v in ipairs(p293) do
            v1862[#v1862 + 1] = v
        end

        for _, v in ipairs(p294) do
            v1862[#v1862 + 1] = v
        end

        if v1861.refresh then
            v1861.refresh()
        end

        if v1863 ~= nil and v1861.set then
            v1861.set(v1863)
        end
    end
    local function v1208()
        if not t202 then
            t202 = {
				a = {},
				r = {},
				m = {},
				adopted = false
			}

            for _, v in ipairs(t5) do
                t202.a[v] = true
            end

            for _, v in ipairs(t6) do
                t202.r[v] = true
            end

            for _, v in ipairs(t7) do
                t202.m[v] = true
            end
        end

        local t203 = {}
        local t204 = {}
        local t205 = {}

        local function v1878(p295, p296)
            local str22 = tostring(p295 or "")

            if str22 == "" or (str22 == "?" or str22 == "nil" or t205[str22]) then
                return
            end

            t205[str22] = true
            t204[#t204 + 1] = {
				name = str22,
				n = tonumber(p296) or 999
			}
        end

        if type(Directory2) == "table" then
            local t206 = {}

            for k, v in pairs(Directory2) do
                local str23 = tostring(k)
                local n31 = 999

                if type(v) == "table" then
                    str23 = tostring(v.DisplayName or (v._id or k))

                    if type(v.Rarity) == "table" then
                        n31 = tonumber(v.Rarity.RarityNumber) or 999
                        v1878(v.Rarity.DisplayName or (v.Rarity.Name or v.Rarity._id), n31)
                    end
                end

                t206[#t206 + 1] = {
					name = str23,
					n = n31
				}
            end

            table.sort(t206, function(p297, p298)
                if p297.n ~= p298.n then
                    return p297.n < p298.n
                end

                return p297.name < p298.name
            end)

            for _, v in ipairs(t206) do
                t203[#t203 + 1] = v.name
            end
        end

        pcall(function()
            for _, v in ipairs(t195) do
                if type(v) == "table" then
                    if v.AreaId then
                        t203[#t203 + 1] = tostring(v.AreaId)
                    end

                    local AssetCategory = v.AssetCategory
                    local v3136 = if not not Directory and AssetCategory then Directory[AssetCategory] else nil

                    if type(v3136) == "table" and type(v3136.Rarity) == "table" then
                        v1878(v3136.Rarity.DisplayName or (v3136.Rarity.Name or v3136.Rarity._id), v3136.Rarity.RarityNumber)
                    end
                end
            end
        end)

        if type(Directory) == "table" then
            for _, v in pairs(Directory) do
                if type(v) == "table" and type(v.Rarity) == "table" then
                    v1878(v.Rarity.DisplayName or (v.Rarity.Name or v.Rarity._id), v.Rarity.RarityNumber)
                end
            end
        end

        table.sort(t204, function(p299, p300)
            if p299.n ~= p300.n then
                return p299.n < p300.n
            end

            return p299.name < p300.name
        end)

        local t207 = {}

        for _, v in ipairs(t204) do
            t207[#t207 + 1] = v.name
        end

        local t208 = {}

        if type(Directory) == "table" then
            for _, v in pairs(Directory) do
                if type(v) == "table" then
                    if type(v.Mutations) == "table" then
                        for _, v15 in pairs(v.Mutations) do
                            if type(v15) == "string" then
                                t208[#t208 + 1] = v15
                            end
                        end
                    end

                    if type(v.Mutation) == "string" then
                        t208[#t208 + 1] = v.Mutation
                    end
                end
            end
        end

        pcall(function()
            for _, v in ipairs(t195) do
                if type(v) == "table" and type(v.Mutations) == "table" then
                    for _, v16 in ipairs(v.Mutations) do
                        t208[#t208 + 1] = tostring(v16)
                    end
                end
            end
        end)

        local v1896 = v1205(t5, t203)
        local v1897 = v1205(t6, t207)
        local v1898 = v1205(t7, t208)
        local t209 = {
			common = 1,
			uncommon = 2,
			rare = 3,
			epic = 4,
			legendary = 5,
			mythic = 6,
			cosmic = 7,
			secret = 8,
			eternal = 9,
			divine = 10,
			titan = 11
		}
        local t210 = {}

        for i = 1, #t204 do
            local v1902 = t204[i]

            if v1902 and v1902.name then
                t210[string.lower(v1902.name)] = tonumber(v1902.n) or 999
            end
        end

        table.sort(t6, function(p301, p302)
            local v3145 = string.lower((tostring(p301)))
            local v3146 = string.lower((tostring(p302)))
            local v3147 = t209[v3145] or 100 + (t210[v3145] or 999)
            local v3148 = t209[v3146] or 100 + (t210[v3146] or 999)

            if v3147 ~= v3148 then
                return v3147 < v3148
            end

            return tostring(p301) < tostring(p302)
        end)

        if #v1896 > 0 then
            v1102("modules", "new zones", table.concat(v1896, ", "), "·", #t5, "total")
        end

        if #v1897 > 0 then
            v1102("modules", "new rarities", table.concat(v1897, ", "))
        end

        if #v1898 > 0 then
            v1102("modules", "new mutations", table.concat(v1898, ", "))
        end

        pcall(function()
            local t211 = {}
            local t212 = {}
            local t213 = {}

            if not t202.adopted then
                t202.adopted = true

                for _, v in ipairs(t5) do
                    if not t202.a[v] then
                        t211[#t211 + 1] = v
                    end
                end

                for _, v in ipairs(t6) do
                    if not t202.r[v] then
                        t212[#t212 + 1] = v
                    end
                end

                for _, v in ipairs(t7) do
                    if not t202.m[v] then
                        t213[#t213 + 1] = v
                    end
                end
            else
                t211 = v1896
                t212 = v1897
                t213 = v1898
            end

            pcall(v1206, "Areas", t211)
            pcall(v1206, "Rarities", t212)
            pcall(v1206, "Mutations", t213)
            pcall(v1207, "HookRarityFloor", { "Any" }, t6)
            pcall(v1207, "NeverPlaceRarity", { "place everything" }, t6)

            for _, v in ipairs({
				"Areas",
				"Rarities",
				"Mutations"
			}) do
                local v3160 = t10[v]

                if v3160 and v3160.refresh then
                    pcall(v3160.refresh)
                end
            end
        end)
    end
    local function v1209(p303)
        local BottomCFrame = p303.BottomCFrame
        local v1905

        if BottomCFrame == nil then
            v1905 = nil
        else
            local n32 = 4
            local ok33, result33 = pcall(function()
                if typeof(BottomCFrame) == "Vector3" then
                    return n32 and BottomCFrame + Vector3.new(0, n32, 0) or BottomCFrame
                end

                if n32 then
                    return BottomCFrame.Position + Vector3.new(0, n32, 0)
                end

                return BottomCFrame.Position
            end)

            v1905 = if not ok33 then nil else result33
        end

        if not v1905 then
            local BoundsCFrame = p303.BoundsCFrame

            if BoundsCFrame == nil then
                v1905 = nil
            else
                local n33 = 0
                local ok34, result34 = pcall(function()
                    if typeof(BoundsCFrame) == "Vector3" then
                        return n33 and BoundsCFrame + Vector3.new(0, n33, 0) or BoundsCFrame
                    end

                    if n33 then
                        return BoundsCFrame.Position + Vector3.new(0, n33, 0)
                    end

                    return BoundsCFrame.Position
                end)

                v1905 = if not ok34 then nil else result34
            end

            if not v1905 then
                local p303CFrame = p303.CFrame

                if p303CFrame == nil then
                    v1905 = nil
                else
                    local n34 = 0
                    local ok35, result35 = pcall(function()
                        if typeof(p303CFrame) == "Vector3" then
                            return n34 and p303CFrame + Vector3.new(0, n34, 0) or p303CFrame
                        end

                        if n34 then
                            return p303CFrame.Position + Vector3.new(0, n34, 0)
                        end

                        return p303CFrame.Position
                    end)

                    v1905 = if not ok35 then nil else result35
                end

                if not v1905 then
                    local WorldCFrame = p303.WorldCFrame

                    if WorldCFrame == nil then
                        v1905 = nil
                    else
                        local n35 = 0
                        local ok36, result36 = pcall(function()
                            if typeof(WorldCFrame) == "Vector3" then
                                return n35 and WorldCFrame + Vector3.new(0, n35, 0) or WorldCFrame
                            end

                            if n35 then
                                return WorldCFrame.Position + Vector3.new(0, n35, 0)
                            end

                            return WorldCFrame.Position
                        end)

                        v1905 = if not ok36 then nil else result36
                    end

                    if not v1905 then
                        local PivotCFrame = p303.PivotCFrame

                        if PivotCFrame == nil then
                            v1905 = nil
                        else
                            local n36 = 0
                            local ok37, result37 = pcall(function()
                                if typeof(PivotCFrame) == "Vector3" then
                                    return n36 and PivotCFrame + Vector3.new(0, n36, 0) or PivotCFrame
                                end

                                if n36 then
                                    return PivotCFrame.Position + Vector3.new(0, n36, 0)
                                end

                                return PivotCFrame.Position
                            end)

                            v1905 = if not ok37 then nil else result37
                        end

                        if not v1905 then
                            local p303Position = p303.Position

                            if p303Position == nil then
                                return nil
                            end

                            local n37 = 4
                            local ok38, result38 = pcall(function()
                                if typeof(p303Position) == "Vector3" then
                                    return n37 and p303Position + Vector3.new(0, n37, 0) or p303Position
                                end

                                if n37 then
                                    return p303Position.Position + Vector3.new(0, n37, 0)
                                end

                                return p303Position.Position
                            end)

                            if ok38 then
                                return result38
                            end

                            v1905 = nil
                        end
                    end
                end
            end
        end

        return v1905
    end
    local n38 = 0
    local u1211
    local function v1212(p304)
        if typeof(p304) ~= "Vector3" then
            return false
        end

        local elapsed12 = os.clock()

        if not u1211 or elapsed12 - n38 > 2 then
            local t214 = {}
            local Plots = workspace:FindFirstChild("Plots")

            if Plots then
                for _, child in ipairs(Plots:GetChildren()) do
                    local v1935 = child:FindFirstChild("CenterPoint", true) or child:FindFirstChild("SpawnPoint", true)

                    if v1935 and v1935:IsA("BasePart") then
                        t214[#t214 + 1] = {
							pos = v1935.Position,
							r = 48
						}
                    else
                        local ok39, result39 = pcall(function()
                            return child:GetPivot()
                        end)

                        if ok39 and typeof(result39) == "CFrame" then
                            t214[#t214 + 1] = {
								pos = result39.Position,
								r = 48
							}
                        end
                    end
                end
            end

            u1211 = t214
            n38 = elapsed12
        end

        for i = 1, #u1211 do
            local v1939 = u1211[i]

            if Vector3.new(p304.X - v1939.pos.X, 0, p304.Z - v1939.pos.Z).Magnitude <= v1939.r then
                return true
            end
        end

        return false
    end
    local function v1213(p305, p306)
        if type(p305) ~= "table" then
            return false
        end

        if p305.Placement ~= nil then
            return true
        end

        if p305.OwnerUserId and p305.State ~= "Dropped" then
            return true
        end

        local v1942 = string.lower((tostring(p305.Uid or "")))

        if v1942:find("plot", 1, true) or v1942:find(":pen", 1, true) or v1942:find("hatch", 1, true) then
            return true
        end

        if p305.State == "Slot" or p305.State == "Dropped" then
            return false
        end

        if typeof(p306) ~= "Vector3" then
            p306 = v1209(p305)
        end

        return (v1212(p306))
    end
    local function v1214(p307)
        if type(p307) ~= "table" then
            return false
        end

        if p307.HasParasite == true then
            return true
        end

        local BaseMutation = p307.BaseMutation
        local v1945 = string.lower((tostring(BaseMutation or "")))

        if v1945 == "monstrous" or (v1945 == "parasite" or v1945:find("infest", 1, true) ~= nil) then
            return true
        end

        local Mutations = p307.Mutations

        if type(Mutations) ~= "table" and type(p307.ItemData) == "table" then
            Mutations = p307.ItemData.Mutations
        end

        if type(Mutations) == "table" then
            for _, v in ipairs(Mutations) do
                local v1949 = string.lower((tostring(v or "")))

                if v1949 == "monstrous" or (v1949 == "parasite" or v1949:find("infest", 1, true) ~= nil) then
                    return true
                end
            end
        end

        return false
    end
    local function v1215(p308, p309, p310)
        local str24 = tostring(p308.AreaId or "")
        local v1954 = v1196(t9.Areas)

        if next(v1954) and not if next(v1954) then v1954[string.lower((tostring(str24 or "")))] == true else false then
            return false
        end

        if p310 then
            return true
        end

        if t9.UseRarity then
            local v1955 = v1196(t9.Rarities)

            if next(v1955) then
                local v1956 = if type(p309) == "table" and type(p309.Rarity) == "table" then tostring(p309.Rarity.DisplayName or (p309.Rarity.Name or (p309.Rarity._id or "?"))) else "?"

                if not if next(v1955) then v1955[string.lower((tostring(v1956 or "")))] == true else false then
                    return false
                end
            end
        end

        if t9.UseMutation then
            local v1957 = v1196(t9.Mutations)

            if next(v1957) then
                local v1958 = false

                if type(p308.Mutations) == "table" then
                    for _, v in ipairs(p308.Mutations) do
                        if if next(v1957) then v1957[string.lower((tostring(v or "")))] == true else false then
                            v1958 = true

                            break
                        end
                    end
                end

                if not v1958 then
                    return false
                end
            end
        end

        local num = tonumber(t9.MinWeight)

        if num and num > 0 and p309 and tonumber(p309.ModelWeight) and num > p309.ModelWeight then
            return false
        end

        return true
    end
    local function v1216()
        local v1965 = v1204()
        local v1966 = t9.StealMode or "Best value"

        local function v1967(p311)
            if type(p311) ~= "table" or not p311.Uid then
                return
            end

            local num = tonumber(p311 and p311.CarrierUserId)

            if num and (num ~= 0 and num ~= LocalPlayer.UserId) then
                return
            end

            local State = p311.State

            if State ~= "Slot" and State ~= "Dropped" then
                return
            end

            local AssetCategory = p311.AssetCategory
            local v3173 = if not not Directory and AssetCategory then Directory[AssetCategory] else nil
            local v3174 = v1209(p311)

            if not v3174 or v1213(p311, v3174) then
                return
            end

            return {
				rec = p311,
				cfg = v3173,
				pos = v3174,
				earn = v1193(p311, v3173),
				rar = if type(v3173) == "table" and type(v3173.Rarity) == "table" then tonumber(v3173.Rarity.RarityNumber) or 0 else 0,
				infested = v1214(p311),
				name = v3173 and (v3173.DisplayName or p311.AssetCategory) or tostring(p311.AssetCategory),
				area = tostring(p311.AreaId or "")
			}
        end

        local v1968 = t216.lockUid or t216.heldUid

        if type(v1968) == "string" then
            local v1969
            for _, v in ipairs(v1965) do
                if type(v) == "table" and v1968 == v.Uid then
                    v1969 = v1967(v)

                    break
                end
            end
            if v1969 then
                local rec = v1969.rec
                local v1973 = v1215(rec, v1969.cfg)

                if v1973 then
                    local cfg = v1969.cfg

                    if (t9.StealMode or "Best value") == "Gen ($/s) snipe" then
                        local v1975 = v1194(t9.GenSnipeFloor)

                        v1973 = not (v1975 > 0) or not (v1975 > v1193(rec, cfg))
                    else
                        v1973 = true
                    end
                end

                local v1976 = rec and rec.State == "Dropped"

                if v1973 or v1976 then
                    v1969.matched = true

                    if typeof(v1969.pos) == "Vector3" then
                        t216.lockPos = v1969.pos
                        t216.lockAt = os.clock()
                    end

                    return v1969
                end

                t216.lockUid = nil
                t216.lockPos = nil
            else
                if typeof(t216.lockPos) == "Vector3" and os.clock() - (t216.lockAt or 0) < 5 then
                    return {
						rec = {
							Uid = v1968,
							State = "Dropped"
						},
						pos = t216.lockPos,
						name = t216.target and t216.target.name or "egg",
						area = t216.target and t216.target.area or "",
						matched = true,
						event = t216.eventFromField == true
					}
                end

                t216.lockUid = nil

                if v1968 == t216.heldUid then
                    t216.heldUid = nil
                end

                if t216.target and t216.target.rec and v1968 == t216.target.rec.Uid then
                    t216.target = nil
                end
            end
        end

        local t215 = {}

        for _, v in ipairs(v1965) do
            if type(v) == "table" then
                local v1980 = v1967(v)

                if v1980 then
                    local v1981 = v1215(v, v1980.cfg)

                    if v1981 then
                        local cfg = v1980.cfg

                        if (t9.StealMode or "Best value") == "Gen ($/s) snipe" then
                            local v1983 = v1194(t9.GenSnipeFloor)

                            v1981 = not (v1983 > 0) or not (v1983 > v1193(v, cfg))
                        else
                            v1981 = true
                        end
                    end

                    local v1984 = false

                    if t9.AutoEvent == true then
                        v1984 = false

                        if v1980.infested == true then
                            local _ = v1980.cfg
                            local str25 = tostring(v.AreaId or "")
                            local v1987 = v1196(t9.Areas)

                            v1984 = not next(v1987) or (((if next(v1987) then v1987[string.lower((tostring(str25 or "")))] == true else false)) and true or false)
                        end
                    end

                    if v1984 then
                        local v1988 = v1194(t9.EventKeepGen)

                        if v1988 > 0 and v1988 <= (v1980.earn or 0) then
                            v1984 = false
                        end
                    end

                    if v1984 then
                        v1980.matched = false
                        v1980.event = true
                        t215[#t215 + 1] = v1980
                    elseif v1981 then
                        v1980.matched = true
                        v1980.event = false
                        t215[#t215 + 1] = v1980
                    end
                end
            end
        end

        table.sort(t215, function(p312, p313)
            if p312.matched ~= p313.matched then
                return p312.matched == true
            end

            if v1966 == "Egg type filter" or v1966 == "Rarity snipe" then
                if p312.rar ~= p313.rar then
                    return p312.rar > p313.rar
                end

                if p312.earn ~= p313.earn then
                    return p312.earn > p313.earn
                end
            else
                if p312.earn ~= p313.earn then
                    return p312.earn > p313.earn
                end

                if p312.rar ~= p313.rar then
                    return p312.rar > p313.rar
                end
            end

            return p312.name < p313.name
        end)

        return t215[1]
    end
    local function v1217()
        local u1989
        pcall(function()
            u1989 = require(ReplicatedStorage.Client.PlotState).ResolvePlot()
        end)
        if type(u1989) == "table" and u1989.PlotFolder then
            local PlotFolder = u1989.PlotFolder
            local CenterPoint = u1989.CenterPoint
            local RespawnPointCFrame = u1989.RespawnPointCFrame

            if typeof(RespawnPointCFrame) == "CFrame" then
                return RespawnPointCFrame.Position + Vector3.new(0, 4, 0), RespawnPointCFrame, PlotFolder, CenterPoint
            end

            local SpawnPoint = PlotFolder:FindFirstChild("SpawnPoint", true)

            if SpawnPoint and SpawnPoint:IsA("BasePart") then
                return SpawnPoint.Position + Vector3.new(0, 4, 0), SpawnPoint.CFrame, PlotFolder, CenterPoint
            end

            return PlotFolder:GetPivot().Position, PlotFolder:GetPivot(), PlotFolder, CenterPoint
        end
        local Plots = workspace:FindFirstChild("Plots")
        if not Plots then
            return
        end
        for _, child in ipairs(Plots:GetChildren()) do
            local v1997 = false

            for _, descendant in ipairs(child:GetDescendants()) do
                if descendant:IsA("TextLabel") and string.find(descendant.Text, LocalPlayer.Name, 1, true) then
                    v1997 = true

                    break
                end
            end

            if v1997 then
                local SpawnPoint = child:FindFirstChild("SpawnPoint", true)
                local CenterPoint = child:FindFirstChild("CenterPoint", true)

                if SpawnPoint and SpawnPoint:IsA("BasePart") then
                    return SpawnPoint.Position + Vector3.new(0, 4, 0), SpawnPoint.CFrame, child, CenterPoint
                end

                return child:GetPivot().Position, child:GetPivot(), child, CenterPoint
            end
        end
        if u1103 and type(u1103.ReadOwnedEggs) == "function" then
            local ok40, result40 = pcall(u1103.ReadOwnedEggs)

            if ok40 and type(result40) == "table" then
                for k, v in pairs(result40) do
                    if type(v) ~= "table" or tonumber(v.OwnerUserId) ~= LocalPlayer.UserId then
                        continue
                    end

                    local v2006 = Plots:FindFirstChild((tostring(k)))

                    if v2006 then
                        local SpawnPoint = v2006:FindFirstChild("SpawnPoint", true)
                        local CenterPoint = v2006:FindFirstChild("CenterPoint", true)

                        if SpawnPoint and SpawnPoint:IsA("BasePart") then
                            return SpawnPoint.Position + Vector3.new(0, 4, 0), SpawnPoint.CFrame, v2006, CenterPoint
                        end

                        return v2006:GetPivot().Position, v2006:GetPivot(), v2006, CenterPoint
                    end
                end
            end
        end
    end
    local function v1218(p314)
        if typeof(p314) ~= "Vector3" then
            return false
        end
        local _, _, v2012, v2013 = v1217()
        local Position2
        if v2013 and typeof(v2013) == "Instance" and v2013:IsA("BasePart") then
            Position2 = v2013.Position
        elseif v2012 then
            local v2015 = v2012:FindFirstChild("CenterPoint", true) or v2012:FindFirstChild("SpawnPoint", true)

            if v2015 and v2015:IsA("BasePart") then
                Position2 = v2015.Position
            else
                pcall(function()
                    Position2 = v2012:GetPivot().Position
                end)
            end
        end
        if typeof(Position2) ~= "Vector3" then
            return false
        end

        return Vector3.new(p314.X - Position2.X, 0, p314.Z - Position2.Z).Magnitude <= 56
    end
    local function u1219()
        local SpawnLocation = workspace:FindFirstChildOfClass("SpawnLocation")

        if SpawnLocation and SpawnLocation:IsA("BasePart") then
            return SpawnLocation.Position + Vector3.new(0, 4, 0), SpawnLocation.CFrame, SpawnLocation
        end

        local SpawnTarget = workspace:FindFirstChild("SpawnTarget", true)

        if SpawnTarget and SpawnTarget:IsA("BasePart") then
            return SpawnTarget.Position + Vector3.new(0, 4, 0), SpawnTarget.CFrame, SpawnTarget
        end

        return v1217()
    end
    local function v1220(p315)
        if typeof(p315) ~= "Vector3" then
            p315 = Vector3.zero
        end
        local u2020
        local u2021
        local function v2022(p316)
            if not p316 or not p316:IsA("BasePart") then
                return
            end

            local v3178 = string.lower(p316.Name)
            local v3179 = p316.Parent and string.lower(p316.Parent.Name) or ""
            local v3180 = v3178:find("treadmill", 1, true) or (v3178:find("belt", 1, true) or (v3179:find("treadmill", 1, true) or v3179:find("belt", 1, true)))

            if not v3180 and v3178 ~= "bottom" then
                return
            end

            if v3178 == "bottom" and not v3180 then
                return
            end

            local Magnitude = (p316.Position - p315).Magnitude

            if not u2021 or Magnitude < u2021 then
                u2020 = p316
                u2021 = Magnitude
            end
        end
        pcall(function()
            local _, _, v3184 = v1217()

            if v3184 then
                v2022(v3184:FindFirstChild("TreadmillBottom", true))

                for _, descendant in ipairs(v3184:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        v2022(descendant)
                    end
                end
            end
        end)
        local v2023 = select(1, v1217())
        local __ClientTreadmillRenders = workspace:FindFirstChild("__ClientTreadmillRenders")
        if __ClientTreadmillRenders then
            for _, descendant in ipairs(__ClientTreadmillRenders:GetDescendants()) do
                if descendant:IsA("BasePart") and typeof(v2023) == "Vector3" and (descendant.Position - v2023).Magnitude < 90 then
                    v2022(descendant)
                end
            end
        end

        return u2020
    end
    local function v1221(p317)
        local u2028
        local u2029
        local u2030
        local u2031
        local n39 = 0
        local n40 = 0
        local function v2034(p318)
            if not p318 or not p318:IsA("BasePart") then
                return
            end

            local v3188 = string.lower(p318.Name)
            local v3189 = p318.Parent and string.lower(p318.Parent.Name) or ""

            if not v3188:find("treadmill", 1, true) and not v3188:find("belt", 1, true) and not v3189:find("treadmill", 1, true) and not v3189:find("belt", 1, true) and v3188 ~= "treadmillbottom" then
                return
            end

            local p318CFrame = p318.CFrame
            local p318Size = p318.Size
            local v3192 = p318Size.X * 0.5
            local v3193 = p318Size.Z * 0.5
            local v3194 = math.abs(p318CFrame.RightVector.X) * v3192 + math.abs(p318CFrame.LookVector.X) * v3193 + math.abs(p318CFrame.UpVector.X) * (p318Size.Y * 0.5)
            local v3195 = math.abs(p318CFrame.RightVector.Z) * v3192 + math.abs(p318CFrame.LookVector.Z) * v3193 + math.abs(p318CFrame.UpVector.Z) * (p318Size.Y * 0.5)
            local PositionX = p318CFrame.Position.X
            local PositionZ = p318CFrame.Position.Z

            u2028 = u2028 and math.min(u2028, PositionX - v3194) or PositionX - v3194
            u2029 = u2029 and math.max(u2029, PositionX + v3194) or PositionX + v3194
            u2030 = u2030 and math.min(u2030, PositionZ - v3195) or PositionZ - v3195
            u2031 = u2031 and math.max(u2031, PositionZ + v3195) or PositionZ + v3195
            n39 += p318CFrame.Position.Y
            n40 += 1
        end
        pcall(function()
            local _, _, v3200 = v1217()

            if v3200 then
                v2034(v3200:FindFirstChild("TreadmillBottom", true))

                for _, descendant in ipairs(v3200:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        v2034(descendant)
                    end
                end
            end
        end)
        local v2035 = select(1, v1217())
        local __ClientTreadmillRenders = workspace:FindFirstChild("__ClientTreadmillRenders")
        if __ClientTreadmillRenders then
            for _, descendant in ipairs(__ClientTreadmillRenders:GetDescendants()) do
                if descendant:IsA("BasePart") and (typeof(v2035) ~= "Vector3" or (descendant.Position - v2035).Magnitude < 90) then
                    v2034(descendant)
                end
            end
        end
        local v2039 = v1220(p317)
        if v2039 then
            v2034(v2039)
        end
        if n40 == 0 or not u2028 then
            return
        end

        return {
			cx = (u2028 + u2029) * 0.5,
			cz = (u2030 + u2031) * 0.5,
			hx = (u2029 - u2028) * 0.5,
			hz = (u2031 - u2030) * 0.5,
			y = n39 / n40
		}
    end
    local function v1222(p319, p320, p321)
        if not p319 or typeof(p320) ~= "Vector3" then
            return false
        end

        local v2043 = p321 or 0

        return math.abs(p320.X - p319.cx) <= p319.hx + v2043 and math.abs(p320.Z - p319.cz) <= p319.hz + v2043
    end
    local function v1223(p322, p323, p324, p325)
        if not p322 or (typeof(p323) ~= "Vector3" or typeof(p324) ~= "Vector3") then
            return false
        end

        local v2048 = p325 or 0
        local p323X = p323.X
        local p323Z = p323.Z
        local p324X = p324.X
        local p324Z = p324.Z
        local v2053 = p322.cx - p322.hx - v2048
        local v2054 = p322.cx + p322.hx + v2048
        local v2055 = p322.cz - p322.hz - v2048
        local v2056 = p322.cz + p322.hz + v2048

        if p323X < v2053 and p324X < v2053 or v2054 < p323X and v2054 < p324X or p323Z < v2055 and p324Z < v2055 or v2056 < p323Z and v2056 < p324Z then
            return false
        end

        if v1222(p322, p323, v2048) or v1222(p322, p324, v2048) then
            return true
        end

        local v2057 = p324X - p323X
        local v2058 = p324Z - p323Z

        for i = 1, 8 do
            local v2060 = i / 9
            local vector3 = Vector3.new(p323X + v2057 * v2060, 0, p323Z + v2058 * v2060)

            if v1222(p322, vector3, v2048) then
                return true
            end
        end

        return false
    end
    local function v1224(p326, p327)
        if typeof(p326) ~= "Vector3" then
            return p327
        end

        local v2066 = select(1, u1219())
        local v2067 = select(1, v1217())
        local v2068 = v1221(p326)
        local v2069 = v2068 and v1222(v2068, p326, 12)
        local v2070 = v2068 and (typeof(p327) == "Vector3" and v1223(v2068, p326, p327, 8))

        if v2066 and Vector3.new(v2066.X - p326.X, 0, v2066.Z - p326.Z).Magnitude <= 62 then
            return p327
        end

        if not v1218(p326) and not v2069 and not v2070 then
            return p327
        end

        if typeof(v2066) ~= "Vector3" then
            return p327
        end

        local v2071 = v2068 and Vector3.new(v2068.cx, p326.Y, v2068.cz) or (typeof(v2067) == "Vector3" and v2067 or p326)
        local vector3 = Vector3.new(v2066.X - v2071.X, 0, v2066.Z - v2071.Z)

        if vector3.Magnitude < 2 then
            vector3 = Vector3.new(v2066.X - p326.X, 0, v2066.Z - p326.Z)
        end

        if vector3.Magnitude < 0.1 then
            return p327
        end

        local Unit = vector3.Unit

        if Vector3.new(p326.X - v2071.X, 0, p326.Z - v2071.Z):Dot(Unit) > 18 and not v2069 then
            return p327
        end

        local p326Y = p326.Y
        local vector3_6 = Vector3.new(v2071.X + Unit.X * 32, p326Y, v2071.Z + Unit.Z * 32)

        if Vector3.new(p326.X - vector3_6.X, 0, p326.Z - vector3_6.Z).Magnitude < 12 then
            return p327
        end

        return vector3_6
    end
    local function v1225(p328, p329, p330)
        if typeof(p328) ~= "Vector3" then
            return p328
        end

        if typeof(p329) ~= "Vector3" then
            return p328
        end

        local v2079 = select(1, u1219())

        if v2079 and Vector3.new(v2079.X - p329.X, 0, v2079.Z - p329.Z).Magnitude <= 62 then
            p330 = true
        end

        if p330 then
            return p328
        end

        local v2080 = v1221(p329)
        local v2081 = v1218(p329) or (v2080 and v1222(v2080, p329, 12) or v2080 and v1223(v2080, p329, p328, 8))

        if u1130() then
            return p328
        end

        if v2081 then
            return (v1224(p329, p328))
        end

        return p328
    end
    local function v1226(p331)
        local v2083 = select(1, u1219())

        if typeof(v2083) ~= "Vector3" then
            return v2083, v2083
        end

        if typeof(p331) ~= "Vector3" then
            return v2083, v2083
        end

        if u1130() then
            return Vector3.new(v2083.X, p331.Y, v2083.Z), v2083
        end

        return v1224(p331, v2083), v2083
    end
    t216 = {
		state = "Idle",
		since = 0,
		target = nil,
		hookSnap = nil,
		carrying = false,
		carryUid = nil,
		heldUid = nil,
		countedUid = nil,
		banked = 0,
		lost = 0,
		regrabs = 0,
		lastGrab = 0,
		lastBankTry = 0,
		lastBankAt = 0,
		lastErrAt = 0,
		lockUid = nil,
		lockPos = nil,
		lockAt = 0,
		haltUntil = 0,
		running = false,
		conn = nil,
		pendingCarry = nil,
		lastPos = nil,
		stillFor = 0,
		bat = nil,
		fed = 0,
		chests = 0,
		eventUid = nil,
		eventFromField = false,
		lastFeed = 0,
		lastChestTake = 0,
		feedLockUntil = 0,
		feedWasWait = false,
		eventSkip = {},
		returnRouteStage = 0,
		returnRouteLastHop = 0,
		routeDropAt = 0,
		routeDropBusy = false,
		nextGrabAt = 0
	}
    function t216.wallUp()
        local resetWall = t216.resetWall

        if resetWall == nil then
            local ok41, result41 = pcall(require, ReplicatedStorage.Client.AreaEggResetWall)

            t216.resetWall = not not ok41 and (type(result41) == "table" and (result41 or false))
            resetWall = t216.resetWall
        end

        local elapsed13 = os.clock()
        local v2088 = false

        if type(resetWall) == "table" and type(resetWall.IsSealed) == "function" then
            local ok42, result42 = pcall(resetWall.IsSealed)

            v2088 = ok42 and result42 == true
        end

        if v2088 then
            t216.wallSealedAt = elapsed13

            return true
        end

        local n41 = 0.5

        if type(resetWall) == "table" then
            local num = tonumber(resetWall.CollapseSeconds)

            if num and num > 0 then
                n41 = math.clamp(num, 0.15, 2)
            end
        end

        local v2093 = t216.wallSealedAt or 0

        if v2093 > 0 and elapsed13 - v2093 < n41 + 0.12 then
            return true
        end

        if v2093 > 0 then
            t216.wallSealedAt = 0
        end

        local __OBJECTS = workspace:FindFirstChild("__OBJECTS")
        local v2095 = __OBJECTS and __OBJECTS:FindFirstChild("Areas")
        local v2096 = v2095 and v2095:FindFirstChild("WallStartVisual")

        if v2096 and v2096:IsA("BasePart") and v2096.Transparency < 0.85 then
            local SizeY = v2096.Size.Y
            local wallRestY = t216.wallRestY

            if wallRestY == nil or wallRestY > SizeY + 0.05 then
                t216.wallRestY = SizeY
                wallRestY = SizeY
            end

            if SizeY > wallRestY + 3 then
                return true
            end
        end

        return false
    end
    t216.bat = (function()
        local n42 = 0
        local n43 = 0
        local n44 = 0
        local n45 = 17
        local s18 = "IsBat"
        local u2104
        local u2105
        pcall(function()
            local v3203 = v1168({
				"Modules",
				"BatController",
				"Config"
			})

            if type(v3203) == "table" then
                n45 = (tonumber(v3203.Range) or 15) + (tonumber(v3203.HitTolerance) or 2)

                if type(v3203.GetHitboxScalar) == "function" then
                    local ok43, result43 = pcall(v3203.GetHitboxScalar)

                    if ok43 and type(result43) == "number" and result43 > 0 then
                        n45 *= result43
                    end
                end
            end
        end)
        pcall(function()
            local Sakura = require(ReplicatedStorage.Data.Sakura)

            if type(Sakura) == "table" and type(Sakura.BatToolAttribute) == "string" then
                s18 = Sakura.BatToolAttribute
            end
        end)
        local function v2106(p332)
            local v3209 = p332 and p332.Character

            if not v3209 then
                return
            end

            local HumanoidRootPart = v3209:FindFirstChild("HumanoidRootPart")
            local Humanoid = v3209:FindFirstChildOfClass("Humanoid")

            if HumanoidRootPart and Humanoid and Humanoid.Health > 0 then
                return HumanoidRootPart, Humanoid, v3209
            end
        end
        local function v2107(p333)
            if not p333 then
                return
            end

            for _, child in ipairs(p333:GetChildren()) do
                if child:IsA("Tool") and child:GetAttribute(s18) == true then
                    return child
                end
            end
        end
        local function v2108()
            return v2107(LocalPlayer.Character)
        end
        local function v2109()
            local v3215 = v2107(LocalPlayer.Character)

            if v3215 then
                return v3215
            end

            if not t9.BatAura or not t9.AutoSteal or t216.carrying then
                return
            end

            local elapsed14 = os.clock()

            if elapsed14 - n44 < 0.35 then
                return
            end

            n44 = elapsed14

            local v3217 = v2107(LocalPlayer:FindFirstChild("Backpack"))

            if not v3217 then
                return
            end

            local v3218 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

            if not v3218 then
                return
            end

            pcall(function()
                v3218:EquipTool(v3217)
            end)

            return v2108()
        end
        local function v2110()
            n42 += 1

            return string.format("%d:%d:%d", LocalPlayer.UserId, n42, math.floor(workspace:GetServerTimeNow() * 1000))
        end
        local function v2111(p334)
            if not t9.BatAura or (not p334 or p334 == LocalPlayer) then
                return false
            end

            local elapsed15 = os.clock()

            if elapsed15 - n43 < 0.7 then
                return false
            end

            local v3221 = select(1, v2106(LocalPlayer))
            local v3222 = select(1, v2106(p334))

            if not v3221 or not v3222 then
                return false
            end

            if (v3221.Position - v3222.Position).Magnitude > n45 then
                return false
            end

            if not v2109() and not v2107(LocalPlayer.Character) then
                return false
            end

            local v3223

            if u2104 and u2104.Parent then
                v3223 = u2104
            else
                local v3224 = v1168({ "Remotes" })

                u2104 = v3224 and v1170(v3224.BatSwing and v3224.BatSwing.Trigger)
                v3223 = u2104
            end

            local v3225 = v3223

            if not v3225 then
                return false
            end

            n43 = elapsed15
            pcall(function()
                v3225:FireServer(p334, v2110())
            end)

            return true
        end
        local function v2112(p335)
            local t217 = {}
            local u3228 = t216.running and (t216.target and tonumber(t216.target.carrier))
            pcall(function()
                for _, v in ipairs((v1204())) do
                    if type(v) == "table" and v.State == "Carried" then
                        local num = tonumber(v.CarrierUserId)

                        if num then
                            t217[num] = true

                            if t216.heldUid and v.Uid == t216.heldUid then
                                u3228 = u3228 or num
                            end
                        end
                    end
                end
            end)
            local v3229
            local v3230
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local v3233 = select(1, v2106(player))

                    if v3233 then
                        local Magnitude = (v3233.Position - p335).Magnitude

                        if Magnitude <= n45 then
                            if u3228 and player.UserId == u3228 then
                                Magnitude -= 80
                            elseif t217[player.UserId] then
                                Magnitude -= 40
                            end

                            if not v3230 or Magnitude < v3230 then
                                v3229 = player
                                v3230 = Magnitude
                            end
                        end
                    end
                end
            end

            return v3229
        end
        local function v2113()
            if not u1117 or not t9.BatAura then
                return
            end

            if t9.AutoSteal then
                v2109()
            end

            local v3235 = select(1, v2106(LocalPlayer))

            if not v3235 then
                return
            end

            v2111((v2112(v3235.Position)))
        end
        local function v2114(p336)
            if not not p336 then
                if not u2105 then
                    local connection11 = RunService.Heartbeat:Connect(function()
                        pcall(v2113)
                    end)

                    if connection11 then
                        t152[connection11] = true
                    end

                    u2105 = connection11

                    return
                end
            elseif u2105 then
                u2105:Disconnect()
                u2105 = nil
            end
        end

        return {
			range = function()
            return n45
        end,
			swingAt = v2111,
			posOf = function(p337)
            local v3239 = type(p337) == "number" and Players:GetPlayerByUserId(p337)
            local v3240 = v3239 and select(1, v2106(v3239))

            return v3240 and v3240.Position, v3239
        end,
			setLive = v2114,
			stop = function()
            v2114(false)
        end
		}
    end)()
    u1134 = (function()
        local t218 = {
			folder = nil,
			beamObj = nil,
			pool = {},
			uidPart = {},
			plotAt = 0,
			plotList = {},
			optSaved = nil,
			lastTick = 0,
			iconBy = {},
			iconScanAt = 0,
			sessionAt = os.clock()
		}
        local u2116
        local function u2117(p338)
            local v3242 = tonumber(p338) or 0
            local v3243 = math.abs(v3242)

            if v3243 >= 1000000000000 then
                return string.format("%.2fT", v3242 / 1000000000000)
            end

            if v3243 >= 1000000000 then
                return string.format("%.2fB", v3242 / 1000000000)
            end

            if v3243 >= 1000000 then
                return string.format("%.2fm", v3242 / 1000000)
            end

            if v3243 >= 1000 then
                return string.format("%.1fk", v3242 / 1000)
            end

            if v3243 >= 10 then
                return string.format("%.0f", v3242)
            end

            return string.format("%.1f", v3242)
        end
        pcall(function()
            local FormatAbbreviated = require(ReplicatedStorage.UserGenerated.Strings.FormatAbbreviated)

            if type(FormatAbbreviated) == "function" then
                function u2117(p339)
                    local v4687 = tonumber(p339) or 0
                    local ok44, result44 = pcall(FormatAbbreviated, v4687)

                    if ok44 and type(result44) == "string" and result44 ~= "" then
                        return result44
                    end

                    if math.abs(v4687) >= 1000000 then
                        return string.format("%.2fm", v4687 / 1000000)
                    end

                    return string.format("%.0f", v4687)
                end
            end
        end)
        local function v2118(p340)
            local v3246 = tonumber(p340) or 0

            if v3246 >= 11 then
                return Color3.fromRGB(255, 236, 150)
            end

            if v3246 >= 10 then
                return Color3.fromRGB(255, 90, 210)
            end

            if v3246 >= 9 then
                return Color3.fromRGB(120, 210, 255)
            end

            if v3246 >= 8 then
                return Color3.fromRGB(255, 80, 110)
            end

            if v3246 >= 7 then
                return Color3.fromRGB(255, 186, 70)
            end

            if v3246 >= 6 then
                return Color3.fromRGB(186, 120, 255)
            end

            if v3246 >= 5 then
                return Color3.fromRGB(255, 220, 90)
            end

            if v3246 >= 4 then
                return Color3.fromRGB(160, 120, 255)
            end

            if v3246 >= 3 then
                return Color3.fromRGB(90, 170, 255)
            end

            if v3246 >= 2 then
                return Color3.fromRGB(120, 200, 120)
            end

            return Color3.fromRGB(210, 210, 210)
        end
        local function v2119()
            local NEXUSEsp = workspace:FindFirstChild("NEXUSEsp")

            if NEXUSEsp and NEXUSEsp:IsA("Folder") then
                t218.folder = NEXUSEsp

                return NEXUSEsp
            end

            if t218.folder and t218.folder.Parent == workspace then
                return t218.folder
            end

            if t218.folder then
                pcall(function()
                    t218.folder:Destroy()
                end)
            end

            local Folder = Instance.new("Folder")

            Folder.Name = "NEXUSEsp"
            Folder.Parent = workspace
            t218.folder = Folder

            return Folder
        end
        local function v2120()
            local Parent = v98.Parent
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")

            if PlayerGui then
                local v3251 = PlayerGui:FindFirstChild(v49) or PlayerGui:FindFirstChild("NEXUSWorldGui")

                if v3251 and v3251 ~= t218.world then
                    pcall(function()
                        v3251:Destroy()
                    end)
                end
            end

            if not Parent then
                Parent = PlayerGui or v98
            end

            local world = t218.world

            if not world or not world.Parent or not world:IsA("ScreenGui") then
                world = Parent:FindFirstChild(v49)
            end

            if world and world:IsA("ScreenGui") then
                if Parent ~= world.Parent and Parent then
                    world.Parent = Parent
                end

                world.Enabled = true
                world.ResetOnSpawn = false
                t218.world = world

                return world
            end

            local ScreenGui = Instance.new("ScreenGui")

            ScreenGui.Name = v49
            ScreenGui.ResetOnSpawn = false
            ScreenGui.IgnoreGuiInset = true
            ScreenGui.DisplayOrder = 80
            ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            ScreenGui.Parent = Parent
            t218.world = ScreenGui

            return ScreenGui
        end
        local function v2121(p341)
            if p341 == nil then
                return
            end

            local v3255 = typeof(p341)

            if v3255 == "number" then
                if p341 > 100 then
                    return "rbxassetid://" .. tostring(math.floor(p341))
                end

                return
            end

            if v3255 == "string" then
                if p341 == "" or p341 == "0" or p341 == "rbxassetid://0" then
                    return
                end

                if string.find(p341, "http", 1, true) or string.find(p341, "rbxasset", 1, true) or string.find(p341, "rbxthumb", 1, true) then
                    return p341
                end

                local num = tonumber(p341)

                if num and num > 100 then
                    return "rbxassetid://" .. tostring(math.floor(num))
                end

                return
            end

            if v3255 == "Instance" then
                if p341:IsA("ImageLabel") or p341:IsA("ImageButton") then
                    return v2121(p341.Image)
                end

                if p341:IsA("Decal") or p341:IsA("Texture") then
                    return v2121(p341.Texture)
                end

                local v3257 = p341:FindFirstChildWhichIsA("ImageLabel", true) or (p341:FindFirstChildWhichIsA("ImageButton", true) or p341:FindFirstChildWhichIsA("Decal", true))

                if v3257 then
                    return v2121(v3257)
                end

                return
            end

            if v3255 == "table" then
                return v2121(p341.Image) or (v2121(p341.ImageId) or (v2121(p341.Icon) or v2121(p341.Id)))
            end
        end
        local t219 = {
			"IndexImage",
			"IndexIcon",
			"Icon",
			"Image",
			"ImageId",
			"IconImage",
			"Thumbnail",
			"AssetImage",
			"PetImage",
			"EggImage",
			"RenderImage",
			"Picture"
		}
        local function v2123(p342, p343)
            if type(p343) ~= "table" then
                return
            end
            local v3264
            for i = 1, #t219 do
                v3264 = v2121(p343[t219[i]])

                if v3264 then
                    break
                end
            end
            if not v3264 and type(p343.Egg) == "table" then
                for i = 1, #t219 do
                    v3264 = v2121(p343.Egg[t219[i]])

                    if v3264 then
                        break
                    end
                end
            end
            if not v3264 then
                return
            end
            if type(p342) == "string" and p342 ~= "" and v3264 then
                local v3267 = string.lower(p342)

                t218.iconBy[v3267] = v3264

                local v3268 = v3267:gsub("[%s_%-]+", "")

                if v3268 ~= v3267 then
                    t218.iconBy[v3268] = v3264
                end
            end
            local DisplayName = p343.DisplayName
            if type(DisplayName) == "string" and DisplayName ~= "" and v3264 then
                local v3270 = string.lower(DisplayName)

                t218.iconBy[v3270] = v3264

                local v3271 = v3270:gsub("[%s_%-]+", "")

                if v3271 ~= v3270 then
                    t218.iconBy[v3271] = v3264
                end
            end
            local _id = p343._id
            if type(_id) == "string" and _id ~= "" and v3264 then
                local v3273 = string.lower(_id)

                t218.iconBy[v3273] = v3264

                local v3274 = v3273:gsub("[%s_%-]+", "")

                if v3274 ~= v3273 then
                    t218.iconBy[v3274] = v3264
                end
            end
            if type(p343.Egg) == "table" then
                local DisplayName2 = p343.Egg.DisplayName

                if type(DisplayName2) == "string" and DisplayName2 ~= "" then
                    if not v3264 then
                        return
                    end

                    local v3276 = string.lower(DisplayName2)

                    t218.iconBy[v3276] = v3264

                    local v3277 = v3276:gsub("[%s_%-]+", "")

                    if v3277 ~= v3276 then
                        t218.iconBy[v3277] = v3264
                    end
                end
            end
        end
        local function v2124()
            local t220 = {}

            if type(Directory) ~= "table" then
                return t220
            end

            for k, v in pairs(Directory) do
                local str26 = tostring(k)

                t220[string.lower(str26)] = str26

                if type(v) == "table" then
                    if v.DisplayName then
                        t220[string.lower((tostring(v.DisplayName)))] = str26
                    end

                    if v._id then
                        t220[string.lower((tostring(v._id)))] = str26
                    end

                    if type(v.Egg) == "table" and v.Egg.DisplayName then
                        t220[string.lower((tostring(v.Egg.DisplayName)))] = str26
                    end
                end
            end

            return t220
        end
        local function v2125(p344, p345)
            if not p344 then
                return
            end

            local ok45, result45 = pcall(function()
                return p344:GetDescendants()
            end)

            if not ok45 or type(result45) ~= "table" then
                return
            end

            local n46 = 0

            for i = 1, #result45 do
                n46 += 1

                if p345 < n46 then
                    return
                end

                local v3288 = result45[i]
                local u3289 = false

                pcall(function()
                    u3289 = v3288:IsA("ImageLabel") or v3288:IsA("ImageButton")
                end)

                if u3289 then
                    local v3290 = v2121(v3288)

                    if v3290 then
                        local Name = v3288.Name

                        if type(Name) == "string" and Name ~= "" and v3290 then
                            local v3292 = string.lower(Name)

                            t218.iconBy[v3292] = v3290

                            local v3293 = v3292:gsub("[%s_%-]+", "")

                            if v3293 ~= v3292 then
                                t218.iconBy[v3293] = v3290
                            end
                        end

                        if v3288.Parent then
                            local ParentName = v3288.Parent.Name

                            if type(ParentName) == "string" and ParentName ~= "" and v3290 then
                                local v3295 = string.lower(ParentName)

                                t218.iconBy[v3295] = v3290

                                local v3296 = v3295:gsub("[%s_%-]+", "")

                                if v3296 ~= v3295 then
                                    t218.iconBy[v3296] = v3290
                                end
                            end
                        end

                        pcall(function()
                            local AssetCategory = v3288:GetAttribute("AssetCategory")
                            local v4691 = v3290

                            if type(AssetCategory) == "string" and (AssetCategory ~= "" and v4691) then
                                local v4692 = string.lower(AssetCategory)

                                t218.iconBy[v4692] = v4691

                                local v4693 = v4692:gsub("[%s_%-]+", "")

                                if v4693 ~= v4692 then
                                    t218.iconBy[v4693] = v4691
                                end
                            end

                            local Id = v3288:GetAttribute("Id")
                            local v4695 = v3290

                            if type(Id) == "string" and Id ~= "" and v4695 then
                                local v4696 = string.lower(Id)

                                t218.iconBy[v4696] = v4695

                                local v4697 = v4696:gsub("[%s_%-]+", "")

                                if v4697 ~= v4696 then
                                    t218.iconBy[v4697] = v4695
                                end
                            end

                            if v3288.Parent then
                                local AssetCategory2 = v3288.Parent:GetAttribute("AssetCategory")
                                local v4699 = v3290

                                if type(AssetCategory2) == "string" and AssetCategory2 ~= "" then
                                    if not v4699 then
                                        return
                                    end

                                    local v4700 = string.lower(AssetCategory2)

                                    t218.iconBy[v4700] = v4699

                                    local v4701 = v4700:gsub("[%s_%-]+", "")

                                    if v4701 ~= v4700 then
                                        t218.iconBy[v4701] = v4699
                                    end
                                end
                            end
                        end)
                    end
                end
            end
        end
        local function v2126(p346, p347, p348)
            if not p346 or not p347 then
                return
            end

            local ok46, result46 = pcall(function()
                return p346:GetDescendants()
            end)

            if not ok46 or type(result46) ~= "table" then
                return
            end

            local n47 = 0

            for i = 1, #result46 do
                n47 += 1

                if p348 < n47 then
                    return
                end

                local v3304 = result46[i]
                local u3305 = false

                pcall(function()
                    u3305 = v3304:IsA("TextLabel") or v3304:IsA("TextButton")
                end)

                if u3305 then
                    local Text = v3304.Text

                    if type(Text) == "string" and Text ~= "" then
                        local v3307 = p347[string.lower(Text)]

                        if v3307 then
                            local Parent = v3304.Parent

                            if Parent then
                                local descendants = Parent:GetDescendants()

                                for j = 1, #descendants do
                                    local v3311 = descendants[j]
                                    local u3312 = false

                                    pcall(function()
                                        u3312 = v3311:IsA("ImageLabel") or v3311:IsA("ImageButton")
                                    end)

                                    if u3312 then
                                        local v3313 = v2121(v3311)

                                        if v3313 then
                                            if type(v3307) == "string" and v3307 ~= "" and v3313 then
                                                local v3314 = string.lower(v3307)

                                                t218.iconBy[v3314] = v3313

                                                local v3315 = v3314:gsub("[%s_%-]+", "")

                                                if v3315 ~= v3314 then
                                                    t218.iconBy[v3315] = v3313
                                                end
                                            end

                                            if type(Text) == "string" and Text ~= "" and v3313 then
                                                local v3316 = string.lower(Text)

                                                t218.iconBy[v3316] = v3313

                                                local v3317 = v3316:gsub("[%s_%-]+", "")

                                                if v3317 ~= v3316 then
                                                    t218.iconBy[v3317] = v3313
                                                end
                                            end

                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        local function v2127(p349)
            local v3319 = string.lower((tostring(p349 or "")))

            return string.find(v3319, "index", 1, true) or (string.find(v3319, "bestiary", 1, true) or (string.find(v3319, "collection", 1, true) or string.find(v3319, "pedia", 1, true)))
        end
        local function v2128(p350)
            local elapsed16 = os.clock()

            if not p350 and elapsed16 - (t218.iconScanAt or 0) < 8 then
                return
            end

            t218.iconScanAt = elapsed16

            if type(Directory) == "table" then
                for k, v in pairs(Directory) do
                    v2123(k, v)
                end
            end

            local v3324 = v2124()
            local Assets = ReplicatedStorage:FindFirstChild("Assets")

            pcall(v2125, Assets and Assets:FindFirstChild("UI"), 6000)
            pcall(v2125, ReplicatedStorage:FindFirstChild("Directory"), 8000)
            pcall(v2125, ReplicatedStorage:FindFirstChild("Data"), 4000)

            local function v3326(p351)
                if not p351 then
                    return
                end

                for _, child in ipairs(p351:GetChildren()) do
                    if child ~= v98 and v2127(child.Name) then
                        pcall(v2125, child, 8000)
                        pcall(v2126, child, v3324, 8000)
                    end
                end
            end

            v3326(LocalPlayer:FindFirstChild("PlayerGui"))
            pcall(v3326, game:GetService("StarterGui"))
        end
        local function v2129(p352, p353)
            local t221 = {}
            local t222 = {}

            local function v3331(p354)
                if type(p354) ~= "string" or p354 == "" then
                    return
                end

                local v4706 = string.lower(p354)

                if v4706 ~= "" and not t222[v4706] then
                    t222[v4706] = true
                    t221[#t221 + 1] = v4706
                end

                local v4707 = v4706:gsub("[%s_%-]+", "")

                if v4707 ~= "" and not t222[v4707] then
                    t222[v4707] = true
                    t221[#t221 + 1] = v4707
                end

                local v4708 = v4706:gsub("[%s%-]+", "_")

                if v4708 ~= "" and not t222[v4708] then
                    t222[v4708] = true
                    t221[#t221 + 1] = v4708
                end
            end

            v3331(p353)

            if type(p352) == "table" then
                v3331(p352.DisplayName)
                v3331(p352._id)

                if type(p352.Egg) == "table" then
                    v3331(p352.Egg.DisplayName)
                end
            end

            return t221
        end
        local function v2130(p355, p356)
            local v3353 = t9.Theme == "Light"
            local v3354 = p356 and p356.target

            if v3353 then
                p355.card.BackgroundColor3 = Color3.fromRGB(252, 250, 246)
                p355.card.BackgroundTransparency = 0.28
                p355.title.TextColor3 = Color3.fromRGB(28, 24, 20)
                p355.sub.TextColor3 = Color3.fromRGB(92, 84, 74)
                p355.stroke.Color = v3354 and t3.accent or Color3.fromRGB(188, 178, 164)
                p355.stroke.Transparency = not v3354 and 0.32 or 0.12

                if p355.icon then
                    p355.icon.BackgroundColor3 = Color3.fromRGB(232, 226, 216)
                    p355.icon.BackgroundTransparency = not p355.icon.Visible and 1 or 0.42
                end
            else
                p355.card.BackgroundColor3 = Color3.fromRGB(16, 15, 14)
                p355.card.BackgroundTransparency = 0.34
                p355.title.TextColor3 = Color3.fromRGB(246, 242, 234)
                p355.sub.TextColor3 = Color3.fromRGB(168, 158, 144)
                p355.stroke.Color = v3354 and t3.accent or Color3.fromRGB(58, 53, 46)
                p355.stroke.Transparency = not v3354 and 0.38 or 0.08

                if p355.icon then
                    p355.icon.BackgroundColor3 = Color3.fromRGB(28, 26, 24)
                    p355.icon.BackgroundTransparency = not p355.icon.Visible and 1 or 0.5
                end
            end

            p355.stroke.Thickness = not v3354 and 1 or 1.5
        end
        local function v2131()
            local BillboardGui = Instance.new("BillboardGui")

            BillboardGui.AlwaysOnTop = true
            BillboardGui.LightInfluence = 0
            BillboardGui.MaxDistance = 1000000
            BillboardGui.Size = UDim2.fromOffset(152, 34)
            BillboardGui.StudsOffset = Vector3.new(0, 2.2, 0)
            BillboardGui.ResetOnSpawn = false
            BillboardGui.Active = false
            BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            BillboardGui.Parent = v2120()

            local t223 = {
				BackgroundColor3 = Color3.fromRGB(16, 15, 14),
				BackgroundTransparency = 0.34,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(1, 1),
				ClipsDescendants = true,
				ZIndex = 1,
				Active = false
			}
            local Frame = Instance.new("Frame")

            if t223 then
                for k, v in pairs(t223) do
                    Frame[k] = v
                end
            end

            if BillboardGui then
                Frame.Parent = BillboardGui
            end

            local t224 = {
				CornerRadius = UDim.new(0, 8)
			}
            local UICorner = Instance.new("UICorner")

            if t224 then
                for k, v in pairs(t224) do
                    UICorner[k] = v
                end
            end

            if Frame then
                UICorner.Parent = Frame
            end

            local t225 = {
				Color = Color3.fromRGB(70, 64, 56),
				Transparency = 0.38,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}
            local UIStroke = Instance.new("UIStroke")

            if t225 then
                for k, v in pairs(t225) do
                    UIStroke[k] = v
                end
            end

            if Frame then
                UIStroke.Parent = Frame
            end

            local t226 = {
				BackgroundColor3 = Color3.fromRGB(210, 210, 210),
				BorderSizePixel = 0,
				Size = UDim2.new(0, 2, 1, -8),
				Position = UDim2.fromOffset(3, 4),
				ZIndex = 2,
				Active = false
			}
            local Frame27 = Instance.new("Frame")

            if t226 then
                for k, v in pairs(t226) do
                    Frame27[k] = v
                end
            end

            if Frame then
                Frame27.Parent = Frame
            end

            local t227 = {
				CornerRadius = UDim.new(0, 2)
			}
            local UICorner12 = Instance.new("UICorner")

            if t227 then
                for k, v in pairs(t227) do
                    UICorner12[k] = v
                end
            end

            if Frame27 then
                UICorner12.Parent = Frame27
            end

            local t228 = {
				BackgroundColor3 = Color3.fromRGB(28, 26, 24),
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(8, 6),
				Size = UDim2.fromOffset(22, 22),
				Image = "",
				ScaleType = Enum.ScaleType.Fit,
				Visible = false,
				ZIndex = 2,
				Active = false
			}
            local ImageLabel = Instance.new("ImageLabel")

            if t228 then
                for k, v in pairs(t228) do
                    ImageLabel[k] = v
                end
            end

            if Frame then
                ImageLabel.Parent = Frame
            end

            local t229 = {
				CornerRadius = UDim.new(0, 5)
			}
            local UICorner13 = Instance.new("UICorner")

            if t229 then
                for k, v in pairs(t229) do
                    UICorner13[k] = v
                end
            end

            if ImageLabel then
                UICorner13.Parent = ImageLabel
            end

            local t230 = {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(8, 2),
				Size = UDim2.new(1, -12, 0, 14),
				Font = t4.mid,
				Text = "",
				TextColor3 = Color3.fromRGB(246, 242, 234),
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 2,
				Active = false
			}
            local TextLabel = Instance.new("TextLabel")

            if t230 then
                for k, v in pairs(t230) do
                    TextLabel[k] = v
                end
            end

            if Frame then
                TextLabel.Parent = Frame
            end

            local t231 = {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(8, 16),
				Size = UDim2.new(1, -12, 0, 14),
				Font = t4.mono,
				Text = "",
				TextColor3 = Color3.fromRGB(168, 158, 144),
				TextSize = 9,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Top,
				TextWrapped = false,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 2,
				Active = false
			}
            local TextLabel11 = Instance.new("TextLabel")

            if t231 then
                for k, v in pairs(t231) do
                    TextLabel11[k] = v
                end
            end

            if Frame then
                TextLabel11.Parent = Frame
            end

            return {
				bb = BillboardGui,
				card = Frame,
				stroke = UIStroke,
				accent = Frame27,
				icon = ImageLabel,
				title = TextLabel,
				sub = TextLabel11
			}
        end
        local function v2132(p357, p358, p359)
            if not p358 then
                return
            end

            local u3395 = t218.pool[p357]

            if u3395 and (not u3395.bb or not u3395.bb.Parent) then
                if u3395.dummy then
                    pcall(function()
                        u3395.dummy:Destroy()
                    end)
                end

                u3395 = nil
                t218.pool[p357] = nil
            end

            if not u3395 then
                u3395 = v2131()
                t218.pool[p357] = u3395
            end

            u3395.alive = true
            u3395.pos = p358

            local v3396 = v2119()

            if not u3395.dummy or not u3395.dummy.Parent then
                if u3395.dummy then
                    pcall(function()
                        u3395.dummy:Destroy()
                    end)
                end

                local Part = Instance.new("Part")

                Part.Name = "NEXUSEspAdorn"
                Part.Anchored = true
                Part.CanCollide = false
                Part.CanQuery = false
                Part.CanTouch = false
                Part.CastShadow = false
                Part.Transparency = 1
                Part.Size = Vector3.new(0.15, 0.15, 0.15)
                Part.Parent = v3396
                u3395.dummy = Part
            end

            pcall(function()
                u3395.dummy.CFrame = CFrame.new(p358)
            end)
            u3395.bb.Adornee = u3395.dummy
            u3395.bb.Parent = v2120()
            u3395.bb.Enabled = true

            local v3398 = p359.color or Color3.fromRGB(210, 210, 210)

            u3395.title.Text = tostring(p359.name or "")
            u3395.sub.Text = tostring(p359.sub or "")
            u3395.accent.BackgroundColor3 = v3398

            local v3399 = not p359.tall and 34 or 46
            local icon = p359.icon
            local v3401 = not icon and 152 or 180

            if u3395.icon then
                if icon then
                    u3395.icon.Image = icon
                    u3395.icon.Visible = true

                    local v3402 = tostring(p359.name or ""):gsub("^▸%s*", ""):gsub("^>%s*", "")

                    if type(v3402) == "string" and v3402 ~= "" and icon then
                        local v3403 = string.lower(v3402)

                        t218.iconBy[v3403] = icon

                        local v3404 = v3403:gsub("[%s_%-]+", "")

                        if v3404 ~= v3403 then
                            t218.iconBy[v3404] = icon
                        end
                    end

                    u3395.title.Position = UDim2.fromOffset(34, 2)
                    u3395.title.Size = UDim2.new(1, -40, 0, 14)
                    u3395.sub.Position = UDim2.fromOffset(34, 16)
                    u3395.sub.Size = UDim2.new(1, -40, 0, not p359.tall and 14 or 26)
                    u3395.sub.TextWrapped = p359.tall == true
                else
                    u3395.icon.Image = ""
                    u3395.icon.Visible = false
                    u3395.title.Position = UDim2.fromOffset(8, 2)
                    u3395.title.Size = UDim2.new(1, -12, 0, 14)
                    u3395.sub.Position = UDim2.fromOffset(8, 16)
                    u3395.sub.Size = UDim2.new(1, -12, 0, not p359.tall and 14 or 26)
                    u3395.sub.TextWrapped = p359.tall == true
                end
            end

            v2130(u3395, p359)
            u3395.bb.Size = UDim2.fromOffset(v3401, v3399)
        end
        local function v2133()
            for k, v in pairs(t218.pool) do
                if not v.alive then
                    if v.bb then
                        v.bb:Destroy()
                    end

                    if v.dummy then
                        pcall(function()
                            v.dummy:Destroy()
                        end)
                    end

                    t218.pool[k] = nil
                else
                    v.alive = false
                end
            end
        end
        local function v2134(p360, p361)
            if type(p360) == "table" then
                local num = tonumber(p360.Weight)
                local v3410 = if not num or not (num > 0) then nil else num

                if not v3410 then
                    local num3 = tonumber(p360.ModelWeight)

                    v3410 = if not num3 or not (num3 > 0) then nil else num3

                    if not v3410 then
                        local num4 = tonumber(p360.Kg)

                        v3410 = if not num4 or not (num4 > 0) then nil else num4

                        if not v3410 then
                            local num5 = tonumber(p360.BaseWeight)

                            v3410 = if not num5 or not (num5 > 0) then nil else num5
                        end
                    end
                end

                if v3410 then
                    return v3410
                end
            end

            if type(p361) == "table" then
                local num = tonumber(p361.ModelWeight)
                local v3415 = if not num or not (num > 0) then nil else num

                if not v3415 then
                    local num6 = tonumber(p361.Weight)

                    v3415 = if not num6 or not (num6 > 0) then nil else num6

                    if not v3415 then
                        local num7 = tonumber(p361.BaseWeight)

                        v3415 = if not num7 or not (num7 > 0) then nil else num7
                    end
                end

                if v3415 then
                    return v3415
                end

                if type(p361.Egg) == "table" then
                    local num8 = tonumber(p361.Egg.ModelWeight)
                    local v3419 = if not num8 or not (num8 > 0) then nil else num8

                    if not v3419 then
                        local num9 = tonumber(p361.Egg.Weight)

                        if num9 and num9 > 0 then
                            return num9
                        end

                        v3419 = nil
                    end

                    return v3419
                end
            end
        end
        local function v2135(p362, p363, p364)
            local v3426 = p363 and (p363.DisplayName or type(p363.Egg) == "table" and p363.Egg.DisplayName) or tostring(p362.AssetCategory or "?")
            local g3440
            local v3439
            if p364 then
                v3426 = "▸ " .. tostring(v3426)
            end
            local v3427 = u2117(v1193(p362, p363)) .. "/s"
            local v3428 = if type(p363) == "table" and type(p363.Rarity) == "table" then tostring(p363.Rarity.DisplayName or (p363.Rarity.Name or (p363.Rarity._id or "?"))) else "?"
            local num = tonumber((v2134(p362, p363)))
            local v3430 = if num then if not (num >= 100) then string.format("%.1fkg", num) else string.format("%.0fkg", num) else nil
            local t232 = {
				v3427,
				v3428
			}
            local v3432 = v1192(p363, p362)
            if v3432 then
                t232[#t232 + 1] = v3432
            end
            if v3430 then
                t232[#t232 + 1] = v3430
            end
            local s19 = ""
            if type(p362.Mutations) == "table" and #p362.Mutations > 0 then
                s19 = table.concat(p362.Mutations, " · ")
            end
            local v3434 = table.concat(t232, " · ")
            if s19 ~= "" then
                v3434 ..= "\n" .. s19
            end
            local t233 = {
				name = v3426,
				sub = v3434,
				color = v2118(if type(p363) == "table" and type(p363.Rarity) == "table" then tonumber(p363.Rarity.RarityNumber) or 0 else 0),
				target = p364,
				tall = s19 ~= ""
			}
            local v3436 = p362 and p362.AssetCategory
            v2123(v3436, p363)
            local v3437 = v2129(p363, v3436)
            for i = 1, #v3437 do
                v3439 = t218.iconBy[v3437[i]]

                if v3439 then
                    g3440 = true
                end

                if g3440 then
                    break
                end
            end
            if not g3440 then
                v3439 = nil
            end
            t233.icon = v3439

            return t233
        end
        local function v2136()
            if not u1103 then
                return nil
            end

            if type(u1103.ReadOwnerEggs) == "function" then
                local ok47, result47, _, _ = pcall(function()
                    return u1103.ReadOwnerEggs(LocalPlayer.UserId)
                end)

                if not ok47 then
                    v1102("esp", "ERR", "ReadOwnerEggs", (tostring(result47)))
                    result47 = nil
                end

                if type(result47) == "table" then
                    return result47
                end
            end

            if type(u1103.ReadOwnedEggs) == "function" then
                local ReadOwnedEggs = u1103.ReadOwnedEggs
                local ok48, result48, _, _ = pcall(ReadOwnedEggs)

                if not ok48 then
                    v1102("esp", "ERR", "ReadOwnedEggs", (tostring(result48)))
                    result48 = nil
                end

                if type(result48) == "table" then
                    for _, v in pairs(result48) do
                        if type(v) == "table" and tonumber(v.OwnerUserId) == LocalPlayer.UserId then
                            return v.Records
                        end
                    end
                end
            end
        end
        local function v2137(p365, p366)
            if type(p365) ~= "table" then
                return nil, false
            end

            local v3459 = p366 or p365.Uid

            if v3459 and u1103 and type(u1103.IsReadyToHatch) == "function" then
                local ok49, result49 = pcall(u1103.IsReadyToHatch, v3459)

                if ok49 and result49 then
                    return 0, true
                end
            end

            local eggRec

            if t218.eggRec ~= nil then
                eggRec = t218.eggRec
            else
                local EggRecords
                pcall(function()
                    EggRecords = require(ReplicatedStorage.Shared.Util.EggRecords)
                end)
                t218.eggRec = type(EggRecords) == "table" and (EggRecords or false)
                eggRec = t218.eggRec
            end

            local v3464 = eggRec

            if type(v3464) == "table" and type(p365.Placement) == "table" then
                local ServerTimeNow = workspace:GetServerTimeNow()
                local u3466 = tonumber(p365.GrowthSpeedMultiplier) or 1
                if u3466 <= 0 then
                    u3466 = 1
                end
                local u3467
                pcall(function()
                    u3467 = v3464.CurrentNightCredit(p365, ServerTimeNow, u3466)
                end)
                local u3468 = false
                pcall(function()
                    u3468 = v3464.IsGrown(p365, ServerTimeNow, u3466, u3467, LocalPlayer) == true
                end)
                if u3468 then
                    return 0, true
                end
                local u3469
                pcall(function()
                    u3469 = v3464.WallSecondsRemaining(p365, ServerTimeNow, u3466, u3467)
                end)
                if type(u3469) == "number" then
                    return u3469, u3469 <= 0
                end
            end

            if p365.IsReady == true or p365.Ready == true then
                return 0, true
            end

            local v3470 = p365.HatchEndsAt or (p365.ReadyAt or p365.GrowEndsAt)

            if type(v3470) == "number" then
                local v3471 = v3470 - workspace.DistributedGameTime

                return v3471, v3471 <= 0
            end

            local v3472 = tonumber(p365.TimeLeft) or tonumber(p365.HatchTimeLeft)

            if v3472 then
                return v3472, v3472 <= 0
            end

            local Placement = p365.Placement

            if type(Placement) == "table" then
                if Placement.IsReady == true then
                    return 0, true
                end

                local v3474 = Placement.HatchEndsAt or Placement.ReadyAt

                if type(v3474) == "number" then
                    local v3475 = v3474 - workspace.DistributedGameTime

                    return v3475, v3475 <= 0
                end
            end

            return nil, false
        end
        local function v2138(p367)
            local v3477 = math.max(0, math.floor(tonumber(p367) or 0))
            local v3478 = math.floor(v3477 / 3600)
            local v3479 = math.floor(v3477 % 3600 / 60)
            local v3480 = v3477 % 60

            if v3478 > 0 then
                return string.format("%d:%02d:%02d", v3478, v3479, v3480)
            end

            return string.format("%d:%02d", v3479, v3480)
        end
        local function v2139()
            local elapsed17 = os.clock()

            if elapsed17 - (t218.plotAt or 0) < 0.5 then
                return t218.plotList
            end

            t218.plotAt = elapsed17

            local t234 = {}
            local v3483 = v2136()
            local _, _, v3486, v3487 = v1217()
            local cFrame = CFrame.new()

            if v3487 and typeof(v3487) == "Instance" and v3487:IsA("BasePart") then
                cFrame = v3487.CFrame
            elseif v3486 then
                local CenterPoint = v3486:FindFirstChild("CenterPoint", true)

                if CenterPoint and CenterPoint:IsA("BasePart") then
                    cFrame = CenterPoint.CFrame
                else
                    pcall(function()
                        cFrame = v3486:GetPivot()
                    end)
                end
            end

            if type(v3483) == "table" then
                for k, v in pairs(v3483) do
                    if type(v) == "table" and v.AssetCategory then
                        local v3492 = v.Uid or k
                        local AssetCategory = v.AssetCategory
                        local v3494 = if not not Directory and AssetCategory then Directory[AssetCategory] else nil
                        local v3495
                        local Placement = v.Placement
                        if type(Placement) == "table" and Placement.LocalCFrame then
                            local ok50, result50 = pcall(function()
                                return cFrame * Placement.LocalCFrame
                            end)

                            if ok50 and result50 then
                                v3495 = result50.Position + Vector3.new(0, 3, 0)
                            end
                        end
                        if v3495 then
                            local v3499, v3500 = v2137(v, v3492)

                            t234[#t234 + 1] = {
								key = "p:" .. tostring(v.Uid or k),
								pos = v3495,
								cfg = v3494,
								rec = v,
								left = v3499,
								ready = v3500
							}
                        end
                    end
                end
            end

            if #t234 == 0 and v3486 then
                for _, descendant in ipairs(v3486:GetDescendants()) do
                    local u3503 = false

                    pcall(function()
                        if descendant:IsA("ProximityPrompt") then
                            u3503 = string.lower(tostring(descendant.Name) .. " " .. tostring(descendant.ActionText) .. " " .. tostring(descendant.ObjectText)):find("hatch", 1, true) ~= nil
                        end
                    end)

                    if u3503 then
                        local descendantParent = descendant.Parent
                        local u3505
                        pcall(function()
                            if descendantParent:IsA("BasePart") then
                                u3505 = descendantParent.Position + Vector3.new(0, 3, 0)

                                return
                            end

                            if descendantParent:IsA("Model") then
                                u3505 = descendantParent:GetPivot().Position + Vector3.new(0, 3, 0)
                            end
                        end)
                        if u3505 then
                            local u3506 = false

                            pcall(function()
                                u3506 = string.lower(tostring(descendant.ObjectText) .. " " .. tostring(descendant.ActionText)):find("ready", 1, true) ~= nil
                            end)
                            t234[#t234 + 1] = {
								key = "p:" .. tostring(descendant),
								pos = u3505,
								ready = u3506,
								left = nil
							}
                        end
                    end
                end
            end

            t218.plotList = t234

            return t234
        end
        local function v2140(p368, p369)
            if not p368 or not p369 then
                if t218.beamObj then
                    t218.beamObj.Enabled = false
                end

                return
            end

            local v3509 = v2119()

            if not v3509 then
                if t218.beamObj then
                    t218.beamObj.Enabled = false
                end

                return
            end

            if not t218.att0 or p368 ~= t218.att0.Parent then
                if t218.att0 then
                    pcall(function()
                        t218.att0:Destroy()
                    end)
                end

                local Attachment = Instance.new("Attachment")

                Attachment.Name = "NEXUSBeamA"
                Attachment.Parent = p368
                t218.att0 = Attachment
            end

            if not t218.tip or not t218.tip.Parent then
                local Part = Instance.new("Part")

                Part.Name = "NEXUSBeamTip"
                Part.Anchored = true
                Part.CanCollide = false
                Part.CanQuery = false
                Part.CanTouch = false
                Part.Transparency = 1
                Part.Size = Vector3.new(0.2, 0.2, 0.2)
                Part.Parent = v3509
                t218.tip = Part
            end

            pcall(function()
                t218.tip.CFrame = CFrame.new(p369)
            end)

            if not t218.att1 or t218.att1.Parent ~= t218.tip then
                if t218.att1 then
                    pcall(function()
                        t218.att1:Destroy()
                    end)
                end

                local Attachment = Instance.new("Attachment")

                Attachment.Name = "NEXUSBeamB"
                Attachment.Parent = t218.tip
                t218.att1 = Attachment
            end

            if not t218.beamObj or not t218.beamObj.Parent then
                local Beam = Instance.new("Beam")

                Beam.Name = "NEXUSBeam"
                Beam.FaceCamera = true
                Beam.Width0 = 0.16
                Beam.Width1 = 0.05
                Beam.LightEmission = 0.7
                Beam.Transparency = NumberSequence.new(0.15)
                Beam.Parent = v3509
                t218.beamObj = Beam
            end

            t218.beamObj.Attachment0 = t218.att0
            t218.beamObj.Attachment1 = t218.att1
            t218.beamObj.Color = ColorSequence.new(t3.accent)
            t218.beamObj.Enabled = true
        end
        local function v2141()
            if not t9.EggESP and (not t9.PlotESP and not t9.ESPBeam) then
                for _, v in pairs(t218.pool) do
                    if v.bb then
                        v.bb.Enabled = false
                    end
                end

                if t218.beamObj then
                    t218.beamObj.Enabled = false
                end

                if t9.StatsPanel then
                    pcall(v1204)
                end

                return
            end

            local elapsed18 = os.clock()

            if elapsed18 - (t218.lastTick or 0) < 0.08 then
                return
            end

            t218.lastTick = elapsed18

            if t9.EggESP then
                local v3517 = v1204()
                local v3518 = t9.AutoSteal and (t216.running and (t216.target and (t216.target.rec and t216.target.rec.Uid)))

                for _, v in ipairs(v3517) do
                    pcall(function()
                        if type(v) ~= "table" or not v.Uid then
                            return
                        end

                        local State = v.State

                        if State ~= "Slot" and State ~= "Dropped" then
                            return
                        end

                        local AssetCategory = v.AssetCategory
                        local v4715 = if not not Directory and AssetCategory then Directory[AssetCategory] else nil
                        local v4716 = v
                        local v4717 = t9.ESPFilter or "All eggs"
                        local v4719

                        if v4717 == "Stolen target only" then
                            local target = t216.target

                            v4719 = target and (target.rec and target.rec.Uid == v4716.Uid)
                        else
                            v4719 = v4717 ~= "Eggs matching my filters" or v1215(v4716, v4715)
                        end

                        if not v4719 then
                            return
                        end

                        local v4720 = v1209(v)

                        if not v4720 then
                            local v4721 = t218.pool["f:" .. v.Uid]

                            v4720 = v4721 and v4721.pos
                        end

                        if v4720 then
                            local v4722 = v.Uid == v3518

                            v2132("f:" .. v.Uid, v4720, (v2135(v, v4715, v4722)))
                        end
                    end)
                end
            end

            if t9.PlotESP then
                pcall(function()
                    local g4739
                    local v4738
                    for _, v in ipairs((v2139())) do
                        local cfg = v.cfg
                        local v4726 = u2117(v1193(v.rec, cfg)) .. "/s"
                        local v4727 = cfg and (cfg.DisplayName or not not v.rec and v.rec.AssetCategory) or "plot egg"
                        local v4728 = if not v.ready then v.left and v2138(v.left) or "hatching" else "ready"
                        local v4729 = v.rec and v.rec.AssetCategory
                        local v4730 = v1192(cfg, v.rec)
                        local v4731 = v4726 .. "  ·  " .. v4728

                        if v4730 then
                            v4731 = v4726 .. "  ·  " .. v4730 .. "  ·  " .. v4728
                        end

                        local v4732 = v2132
                        local key = v.key
                        local pos = v.pos
                        local t235 = {
							name = tostring(v4727),
							sub = v4731,
							color = v.ready and t3.ok or t3.dim,
							target = v.ready == true
						}

                        v2123(v4729, cfg)

                        local v4736 = v2129(cfg, v4729)

                        for i = 1, #v4736 do
                            v4738 = t218.iconBy[v4736[i]]

                            if v4738 then
                                g4739 = true
                            end

                            if g4739 then
                                break
                            end
                        end

                        if not g4739 then
                            v4738 = nil
                        end

                        g4739 = false
                        t235.icon = v4738
                        v4732(key, pos, t235)
                    end
                end)
            end

            if t9.ESPBeam and t9.AutoSteal and t216.running then
                local Character5 = LocalPlayer.Character
                local v3522

                if not Character5 then
                    v3522 = nil
                else
                    local Humanoid = Character5:FindFirstChildOfClass("Humanoid")
                    local HumanoidRootPart = Character5:FindFirstChild("HumanoidRootPart")

                    v3522 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
                end

                local target = t216.target

                if v3522 and target and target.pos and (target.cfg or target.earn) then
                    v2140(v3522, target.pos)
                elseif t218.beamObj then
                    t218.beamObj.Enabled = false
                end
            elseif t218.beamObj then
                t218.beamObj.Enabled = false
            end

            v2133()
        end
        local t236 = {
			ParticleEmitter = true,
			Trail = true,
			Beam = true,
			Fire = true,
			Smoke = true,
			Sparkles = true,
			Highlight = true,
			PointLight = true,
			SpotLight = true,
			SurfaceLight = true,
			Clouds = true
		}
        local function v2143(p370)
            if p370 then
                local v3530

                if not p370 then
                    v3530 = true
                elseif v98 and p370:IsDescendantOf(v98) then
                    v3530 = true
                elseif t218.world and p370:IsDescendantOf(t218.world) then
                    v3530 = true
                else
                    local p370Name = p370.Name

                    v3530 = p370Name == "NEXUSSupport" or (p370Name == "Hub45Support" or (p370Name == "NEXUSWorldGui" or (p370Name == v49 or p370Name == v48)))
                end

                if not v3530 then
                    if p370:IsA("ScreenGui") or p370:FindFirstAncestorOfClass("ScreenGui") then
                        return
                    end

                    if not t236[p370.ClassName] then
                        return
                    end

                    if not t218.optInst then
                        t218.optInst = {}
                    end

                    if t218.optInst[p370] == nil then
                        local t237 = {}

                        pcall(function()
                            if p370:IsA("Light") then
                                t237.Enabled = p370.Enabled
                                t237.Brightness = p370.Brightness

                                return
                            end

                            if p370:IsA("ParticleEmitter") or p370:IsA("Trail") or p370:IsA("Beam") then
                                t237.Enabled = p370.Enabled

                                if p370:IsA("ParticleEmitter") then
                                    t237.Rate = p370.Rate

                                    return
                                end
                            else
                                t237.Enabled = p370.Enabled
                            end
                        end)
                        t218.optInst[p370] = t237
                    end

                    pcall(function()
                        p370.Enabled = false

                        if p370:IsA("Light") then
                            p370.Brightness = 0

                            return
                        end

                        if p370:IsA("ParticleEmitter") then
                            p370.Rate = 0
                        end
                    end)

                    return
                end
            end
        end
        local function v2144()
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            local v3549 = PlayerGui and PlayerGui:FindFirstChild("HUD")
            local v3550 = v3549 and v3549:FindFirstChild("GameHUD")
            local v3551 = v3550 and v3550:FindFirstChild("BottomLeft")
            local v3552 = v3551 and v3551:FindFirstChild("Money")
            local v3553 = v3552 and v3552:FindFirstChild("Value")

            if v3553 and ((v3553:IsA("TextLabel") or v3553:IsA("TextButton")) and v3553.Text ~= "") then
                return v3553.Text
            end

            local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
            local v3555 = leaderstats and (leaderstats:FindFirstChild("Money") or (leaderstats:FindFirstChild("Cash") or leaderstats:FindFirstChild("Coins")))

            if v3555 and v3555:IsA("ValueBase") then
                return "$" .. u2117(v3555.Value)
            end

            return "—"
        end
        local function v2145()
            local elapsed19 = os.clock()

            if t218.penSnap and elapsed19 - (t218.penAt or 0) < 2.5 then
                return t218.penSnap
            end

            if t218.penBusy then
                return t218.penSnap
            end

            t218.penAt = elapsed19
            t218.penBusy = true
            task.spawn(function()
                local u4748
                pcall(function()
                    local v4887 = v1168({ "Remotes" })
                    local v4888 = v4887 and (v4887.PenRoster and v1170(v4887.PenRoster.AskLiveSnapshot))

                    if not v4888 then
                        return
                    end

                    local v4889 = v4888:InvokeServer()

                    if type(v4889) ~= "table" then
                        return
                    end

                    for _, v in pairs(v4889) do
                        if type(v) == "table" and tonumber(v.OwnerUserId) == LocalPlayer.UserId then
                            u4748 = v

                            return
                        end
                    end
                end)
                if u4748 then
                    t218.penSnap = u4748
                end
                t218.penBusy = false
            end)

            return t218.penSnap
        end
        local t238 = {
			"Money",
			"Income",
			"Pen",
			"Best pet",
			"Best egg",
			"Speed",
			"Session"
		}
        local function v2147()
            if t218.statsFrame and t218.statsFrame.Parent then
                local statsRows = t218.statsRows

                if type(statsRows) == "table" and statsRows.Money and statsRows.Money.Parent and statsRows.Session and statsRows.Session.Parent and t218.statsFrame.Size.X.Offset >= 240 then
                    return t218.statsFrame
                end

                pcall(function()
                    t218.statsFrame:Destroy()
                end)
                t218.statsFrame = nil
                t218.statsRows = nil
            end
            local StatsPanel = v98:FindFirstChild("StatsPanel")
            if StatsPanel then
                pcall(function()
                    StatsPanel:Destroy()
                end)
            end
            local t239 = {
				Name = "StatsPanel",
				BackgroundColor3 = t3.card,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(16, 72),
				Size = UDim2.fromOffset(248, 222),
				ZIndex = 40,
				Active = true,
				Visible = false,
				ClipsDescendants = false
			}
            local v3560 = v98
            local Frame = Instance.new("Frame")
            if t239 then
                for k, v in pairs(t239) do
                    Frame[k] = v
                end
            end
            if v3560 then
                Frame.Parent = v3560
            end
            local v3564 = Frame
            local t240 = {
				CornerRadius = UDim.new(0, 10)
			}
            local UICorner = Instance.new("UICorner")
            if t240 then
                for k, v in pairs(t240) do
                    UICorner[k] = v
                end
            end
            if v3564 then
                UICorner.Parent = v3564
            end
            local s20 = "line"
            local t241 = {
				Color = t3.line or t3.line,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}
            local UIStroke = Instance.new("UIStroke")
            if t241 then
                for k, v in pairs(t241) do
                    UIStroke[k] = v
                end
            end
            if v3564 then
                UIStroke.Parent = v3564
            end
            if s20 then
                UIStroke:SetAttribute("th_stroke", s20)
            end
            if v3564 then
                v3564:SetAttribute("th_bg", "card")

                local card = t3.card

                if card and v3564:IsA("GuiObject") then
                    v3564.BackgroundColor3 = card
                end
            end
            local t242 = {
				BackgroundColor3 = t3.rail,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 26),
				Font = t4.mid,
				Text = "  Stats",
				TextColor3 = t3.text,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 9,
				Active = true
			}
            local TextLabel = Instance.new("TextLabel")
            if t242 then
                for k, v in pairs(t242) do
                    TextLabel[k] = v
                end
            end
            if v3564 then
                TextLabel.Parent = v3564
            end
            local t243 = {
				CornerRadius = UDim.new(0, 10)
			}
            local UICorner14 = Instance.new("UICorner")
            if t243 then
                for k, v in pairs(t243) do
                    UICorner14[k] = v
                end
            end
            if TextLabel then
                UICorner14.Parent = TextLabel
            end
            if TextLabel then
                TextLabel:SetAttribute("th_bg", "rail")

                local rail = t3.rail

                if rail and TextLabel:IsA("GuiObject") then
                    TextLabel.BackgroundColor3 = rail
                end
            end
            if TextLabel then
                TextLabel:SetAttribute("th_text", "text")

                local text = t3.text

                if text then
                    TextLabel.TextColor3 = text
                end
            end
            local t244 = {
				BackgroundColor3 = t3.rail,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 16),
				Size = UDim2.new(1, 0, 0, 10),
				ZIndex = 9
			}
            local Frame28 = Instance.new("Frame")
            if t244 then
                for k, v in pairs(t244) do
                    Frame28[k] = v
                end
            end
            if TextLabel then
                Frame28.Parent = TextLabel
            end
            local Frame29 = TextLabel:FindFirstChildOfClass("Frame")
            if Frame29 then
                Frame29:SetAttribute("th_bg", "rail")

                local rail = t3.rail

                if rail and Frame29:IsA("GuiObject") then
                    Frame29.BackgroundColor3 = rail
                end
            end
            local t245 = {}
            local n48 = 28
            for _, v in ipairs(t238) do
                local v3595 = v == "Best pet" or v == "Best egg"
                local v3596 = not v3595 and 18 or 34
                local t246 = {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(10, n48),
					Size = UDim2.fromOffset(72, v3596),
					Font = t4.body,
					Text = v,
					TextColor3 = t3.dim,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					ZIndex = 9
				}
                local TextLabel12 = Instance.new("TextLabel")

                if t246 then
                    for k, v17 in pairs(t246) do
                        TextLabel12[k] = v17
                    end
                end

                if v3564 then
                    TextLabel12.Parent = v3564
                end

                if TextLabel12 then
                    TextLabel12:SetAttribute("th_text", "dim")

                    local dim = t3.dim

                    if dim then
                        TextLabel12.TextColor3 = dim
                    end
                end

                local t247 = {
					BackgroundTransparency = 1,
					Position = UDim2.fromOffset(82, n48),
					Size = UDim2.fromOffset(156, v3596),
					Font = t4.mono,
					Text = "—",
					TextColor3 = t3.text,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextWrapped = v3595,
					TextTruncate = v3595 and Enum.TextTruncate.None or Enum.TextTruncate.AtEnd,
					ZIndex = 9
				}
                local TextLabel13 = Instance.new("TextLabel")

                if t247 then
                    for k, v19 in pairs(t247) do
                        TextLabel13[k] = v19
                    end
                end

                if v3564 then
                    TextLabel13.Parent = v3564
                end

                if TextLabel13 then
                    TextLabel13:SetAttribute("th_text", "text")

                    local text = t3.text

                    if text then
                        TextLabel13.TextColor3 = text
                    end
                end

                t245[v] = TextLabel13
                n48 += not v3595 and 21 or 38
            end
            v3564.Size = UDim2.fromOffset(248, n48 + 8)
            local u3607
            local inputPosition2
            local Position3
            TextLabel.InputBegan:Connect(function(input)
                local UserInputType = input.UserInputType

                if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.Touch then
                    u3607 = true
                    inputPosition2 = input.Position
                    Position3 = v3564.Position
                end
            end)
            if not t218.statsDrag then
                local v3610 = t218
                local connection12 = UserInputService.InputChanged:Connect(function(input)
                    if not u3607 then
                        return
                    end

                    local UserInputType = input.UserInputType

                    if UserInputType ~= Enum.UserInputType.MouseMovement and UserInputType ~= Enum.UserInputType.Touch then
                        return
                    end

                    if not t218.statsFrame or not t218.statsFrame.Parent then
                        u3607 = false

                        return
                    end

                    local v4753 = input.Position - inputPosition2

                    t218.statsFrame.Position = UDim2.new(Position3.X.Scale, Position3.X.Offset + v4753.X, Position3.Y.Scale, Position3.Y.Offset + v4753.Y)

                    if t218.sellFrame and t218.sellFrame.Visible and not t218.sellMoved then
                        u2116(t218.sellFrame)
                    end
                end)

                if connection12 then
                    t152[connection12] = true
                end

                v3610.statsDrag = connection12

                local v3612 = t218
                local connection13 = UserInputService.InputEnded:Connect(function(input)
                    local UserInputType = input.UserInputType

                    if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.Touch then
                        u3607 = false
                    end
                end)

                if connection13 then
                    t152[connection13] = true
                end

                v3612.statsEnd = connection13
            end
            t218.statsFrame = v3564
            t218.statsRows = t245

            return v3564
        end
        local function v2148(p371)
            if not p371 then
                if t218.statsFrame then
                    t218.statsFrame.Visible = false
                end

                return
            end

            local v3615 = v2147()

            if v3615 then
                v3615.Visible = true
            end
        end
        local function v2149()
            if not t9.StatsPanel then
                if t218.statsFrame and t218.statsFrame.Visible then
                    t218.statsFrame.Visible = false
                end

                return
            end
            local elapsed20 = os.clock()
            if u1202 then
                u1202 = false
                t218.statsAt = 0
                t218.ownerAt = 0
                pcall(v1204, true)
            elseif elapsed20 - (t218.statsAt or 0) < 0.35 then
                return
            end
            t218.statsAt = elapsed20
            local v3617 = v2147()
            if not v3617 then
                return
            end
            v3617.Visible = true
            if t218.sellFrame and t218.sellFrame.Visible and not t218.sellMoved then
                u2116(t218.sellFrame)
            end
            local statsRows = t218.statsRows
            if type(statsRows) ~= "table" then
                return
            end
            local v3619 = math.max(0, math.floor(elapsed20 - (t218.sessionAt or elapsed20)))
            local v3620 = math.floor(v3619 / 3600)
            local v3621 = math.floor(v3619 % 3600 / 60)
            local v3622 = v3619 % 60
            local v3623 = v3620 > 0 and string.format("%d:%02d:%02d", v3620, v3621, v3622) or string.format("%d:%02d", v3621, v3622)
            local n49 = 0
            pcall(function()
                n49 = tonumber(t216.banked) or 0
            end)
            local v3625 = v3623 .. " · " .. tostring(n49) .. " stolen"
            local Session = statsRows.Session
            if Session and Session.Parent then
                Session.Text = tostring(v3625)
            end
            pcall(function()
                local v4759 = v2144()
                local Money = statsRows.Money

                if Money and Money.Parent then
                    Money.Text = tostring(v4759)
                end
            end)
            pcall(function()
                local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
                local v4762 = leaderstats and leaderstats:FindFirstChild("Money/s")
                local v4763 = leaderstats and leaderstats:FindFirstChild("Speed")
                local v4764 = v4762 and u2117(v4762.Value) .. "/s" or "—"
                local Income = statsRows.Income

                if Income and Income.Parent then
                    Income.Text = tostring(v4764)
                end

                local v4766 = v4763 and u2117(v4763.Value) or "—"
                local statsRowsSpeed = statsRows.Speed

                if statsRowsSpeed and statsRowsSpeed.Parent then
                    statsRowsSpeed.Text = tostring(v4766)
                end
            end)
            if not t218.ownerBusy and elapsed20 - (t218.ownerAt or 0) > 1.5 then
                t218.ownerAt = elapsed20
                t218.ownerBusy = true
                task.spawn(function()
                    local n50 = 0
                    local n51 = 0

                    pcall(function()
                        local v4892 = v2136()

                        if type(v4892) == "table" then
                            for _, v in pairs(v4892) do
                                if type(v) == "table" then
                                    n51 += 1

                                    if v.Placement then
                                        n50 += 1
                                    end
                                end
                            end
                        end
                    end)

                    local v4770 = t218
                    local v4771 = t218

                    v4770.ownedN = n51
                    v4771.placedN = n50
                    t218.ownerBusy = false
                end)
            end
            local n52 = 0
            local u3628
            local n53 = 0
            pcall(function()
                local v4772 = v2145()

                if v4772 and type(v4772.Records) == "table" then
                    for _, v in pairs(v4772.Records) do
                        if type(v) == "table" then
                            n52 += 1

                            local v4775 = v1193
                            local v4776

                            if type(v) ~= "table" then
                                v4776 = nil
                            elseif v.AssetCategory then
                                v4776 = v.AssetCategory
                            else
                                local ItemData = v.ItemData

                                v4776 = if type(ItemData) ~= "table" then nil else ItemData.Category or (ItemData.AssetCategory or (ItemData.Name or ItemData.DisplayName))
                            end

                            local v4778 = v4775(v, if not not Directory and v4776 then Directory[v4776] else nil)

                            if v4778 > n53 then
                                n53 = v4778

                                local v4779

                                if type(v) ~= "table" then
                                    v4779 = nil
                                elseif v.AssetCategory then
                                    v4779 = v.AssetCategory
                                else
                                    local ItemData = v.ItemData

                                    v4779 = if type(ItemData) ~= "table" then nil else ItemData.Category or (ItemData.AssetCategory or (ItemData.Name or ItemData.DisplayName))
                                end

                                local s21

                                if not v4779 then
                                    s21 = "?"
                                else
                                    local v4782 = if not not Directory and v4779 then Directory[v4779] else nil

                                    s21 = v4782 and (v4782.DisplayName or type(v4782.Egg) == "table" and v4782.Egg.DisplayName) or tostring(v4779)
                                end

                                u3628 = s21
                            end
                        end
                    end
                end
            end)
            local v3630 = tonumber(t218.placedN) or 0
            if n52 > 0 then
                local v3631 = tostring(n52) .. " pets · " .. tostring(v3630) .. " eggs"
                local Pen = statsRows.Pen

                if Pen and Pen.Parent then
                    Pen.Text = tostring(v3631)
                end
            else
                local v3633 = tostring(v3630) .. " placed"
                local Pen = statsRows.Pen

                if Pen and Pen.Parent then
                    Pen.Text = tostring(v3633)
                end
            end
            if u3628 then
                local v3635 = tostring(u3628) .. "\n" .. u2117(n53) .. "/s"
                local v3636 = statsRows["Best pet"]

                if v3636 and v3636.Parent then
                    v3636.Text = tostring(v3635)
                end
            else
                local v3637 = statsRows["Best pet"]

                if v3637 and v3637.Parent then
                    v3637.Text = tostring("—")
                end
            end
            local u3638
            local n54 = 0
            pcall(function()
                local v4783 = v1204()

                if type(v4783) ~= "table" then
                    v4783 = t195
                end

                for _, v in ipairs(v4783) do
                    if type(v) == "table" and ((v.State == "Slot" or v.State == "Dropped") and not v1213(v)) then
                        local AssetCategory = v.AssetCategory
                        local v4787 = if not not Directory and AssetCategory then Directory[AssetCategory] else nil
                        local v4788 = v1193(v, v4787)

                        if v4788 > n54 then
                            n54 = v4788
                            u3638 = v4787 and (v4787.DisplayName or type(v4787.Egg) == "table" and v4787.Egg.DisplayName) or v.AssetCategory
                        end
                    end
                end
            end)
            if u3638 then
                local v3640 = tostring(u3638) .. "\n" .. u2117(n54) .. "/s"
                local v3641 = statsRows["Best egg"]

                if v3641 and v3641.Parent then
                    v3641.Text = tostring(v3640)
                end
            else
                local v3642 = statsRows["Best egg"]

                if v3642 and v3642.Parent then
                    v3642.Text = tostring("—")
                end
            end
        end
        local function v2150(p372)
            local cfg = p372.cfg
            local v3648
            if type(cfg) == "table" then
                v3648 = cfg.DisplayName or (type(cfg.Egg) ~= "table" or cfg.Egg.DisplayName)
            end
            if not v3648 or v3648 == "" then
                v3648 = p372.cat or "?"
            end
            local str27 = tostring(v3648)
            local cfg2 = p372.cfg
            local v3651 = if type(cfg2) == "table" and type(cfg2.Rarity) == "table" then tostring(cfg2.Rarity.DisplayName or (cfg2.Rarity.Name or (cfg2.Rarity._id or "?"))) else "?"
            local num = tonumber((v2134(p372.rec, p372.cfg)))
            local v3653 = if num then if not (num >= 100) then string.format("%.1fkg", num) else string.format("%.0fkg", num) else nil
            local s22 = ""
            local rec = p372.rec
            if type(rec) == "table" and type(rec.Mutations) == "table" and #rec.Mutations > 0 then
                s22 = table.concat(rec.Mutations, " · ")
            end
            local v3656 = u2117(p372.earn) .. "/s · " .. v3651
            if v3653 then
                v3656 ..= " · " .. v3653
            end
            local v3657 = v3656 .. " · " .. tostring(p372.kind)
            local v3658 = "×" .. tostring(p372.n or 1)
            if (p372.price or 0) > 0 then
                v3658 ..= " · $" .. u2117(p372.price)
            end
            if s22 ~= "" then
                v3658 ..= " · " .. s22
            end

            return str27, v3657, v3658
        end
        local function v2151()
            if t218.sellDrag then
                pcall(function()
                    t218.sellDrag:Disconnect()
                end)
                t218.sellDrag = nil
            end

            if t218.sellEnd then
                pcall(function()
                    t218.sellEnd:Disconnect()
                end)
                t218.sellEnd = nil
            end

            if t218.sellFrame then
                pcall(function()
                    t218.sellFrame:Destroy()
                end)
                t218.sellFrame = nil
            end

            t218.sellTips = nil
            t218.sellMoved = nil
            t218.sellPos = nil

            local SellPreviewPanel = v98:FindFirstChild("SellPreviewPanel")

            if SellPreviewPanel then
                pcall(function()
                    SellPreviewPanel:Destroy()
                end)
            end

            local statsFrame = t218.statsFrame

            if statsFrame then
                local v3661 = statsFrame:FindFirstChild("SellPreviewPanel") or statsFrame:FindFirstChild("SellPreview")

                if v3661 then
                    pcall(function()
                        v3661:Destroy()
                    end)
                end
            end
        end
        function u2116(p373)
            local v3663 = p373 or t218.sellFrame

            if not v3663 or not v3663.Parent then
                return
            end

            if v3663.Parent ~= v98 then
                v3663.Parent = v98
            end

            v3663.AnchorPoint = Vector2.new(0, 0)
            v3663.Size = UDim2.fromOffset(248, 348)
            v3663.ZIndex = 90
            v3663.Visible = true

            if t218.sellMoved and t218.sellPos then
                v3663.Position = t218.sellPos

                return
            end

            local statsFrame = t218.statsFrame

            if statsFrame and statsFrame.Parent and statsFrame.Visible then
                local AbsolutePosition = v98.AbsolutePosition
                local AbsolutePosition2 = statsFrame.AbsolutePosition
                local AbsoluteSize2 = statsFrame.AbsoluteSize

                v3663.Position = UDim2.fromOffset(AbsolutePosition2.X - AbsolutePosition.X, AbsolutePosition2.Y - AbsolutePosition.Y + AbsoluteSize2.Y + 8)

                return
            end

            v3663.Position = UDim2.fromOffset(16, 258)
        end
        local function v2152()
            if t218.sellFrame and (t218.sellFrame.Parent and t218.sellTips and t218.sellTips.pets and t218.sellTips.eggs) then
                if not ((t218.sellFrame.AbsoluteSize.Y or 0) < 320) then
                    u2116(t218.sellFrame)

                    return t218.sellFrame
                end

                v2151()
            end
            v2151()
            local t248 = {
				Name = "SellPreviewPanel",
				BackgroundColor3 = t3.card,
				BorderSizePixel = 0,
				BackgroundTransparency = 0,
				ClipsDescendants = true,
				Size = UDim2.fromOffset(248, 348),
				ZIndex = 90,
				Active = true,
				Visible = true
			}
            local v3669 = v98
            local Frame = Instance.new("Frame")
            if t248 then
                for k, v in pairs(t248) do
                    Frame[k] = v
                end
            end
            if v3669 then
                Frame.Parent = v3669
            end
            local v3673 = Frame
            local t249 = {
				CornerRadius = UDim.new(0, 10)
			}
            local UICorner = Instance.new("UICorner")
            if t249 then
                for k, v in pairs(t249) do
                    UICorner[k] = v
                end
            end
            if v3673 then
                UICorner.Parent = v3673
            end
            local s23 = "line"
            local t250 = {
				Color = t3.line or t3.line,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}
            local UIStroke = Instance.new("UIStroke")
            if t250 then
                for k, v in pairs(t250) do
                    UIStroke[k] = v
                end
            end
            if v3673 then
                UIStroke.Parent = v3673
            end
            if s23 then
                UIStroke:SetAttribute("th_stroke", s23)
            end
            if v3673 then
                v3673:SetAttribute("th_bg", "card")

                local card = t3.card

                if card and v3673:IsA("GuiObject") then
                    v3673.BackgroundColor3 = card
                end
            end
            u2116(v3673)
            local t251 = {
				BackgroundColor3 = t3.rail,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 26),
				Font = t4.mid,
				Text = "  Sell preview",
				TextColor3 = t3.text,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				AutoButtonColor = false,
				ZIndex = 60,
				Active = true
			}
            local TextButton = Instance.new("TextButton")
            if t251 then
                for k, v in pairs(t251) do
                    TextButton[k] = v
                end
            end
            if v3673 then
                TextButton.Parent = v3673
            end
            local t252 = {
				CornerRadius = UDim.new(0, 10)
			}
            local UICorner15 = Instance.new("UICorner")
            if t252 then
                for k, v in pairs(t252) do
                    UICorner15[k] = v
                end
            end
            if TextButton then
                UICorner15.Parent = TextButton
            end
            if TextButton then
                TextButton:SetAttribute("th_bg", "rail")

                local rail = t3.rail

                if rail and TextButton:IsA("GuiObject") then
                    TextButton.BackgroundColor3 = rail
                end
            end
            if TextButton then
                TextButton:SetAttribute("th_text", "text")

                local text = t3.text

                if text then
                    TextButton.TextColor3 = text
                end
            end
            local t253 = {
				BackgroundColor3 = t3.rail,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 0, 16),
				Size = UDim2.new(1, 0, 0, 10),
				ZIndex = 60,
				Active = false
			}
            local Frame30 = Instance.new("Frame")
            if t253 then
                for k, v in pairs(t253) do
                    Frame30[k] = v
                end
            end
            if TextButton then
                Frame30.Parent = TextButton
            end
            local Frame31 = TextButton:FindFirstChildOfClass("Frame")
            if Frame31 then
                Frame31:SetAttribute("th_bg", "rail")

                local rail = t3.rail

                if rail and Frame31:IsA("GuiObject") then
                    Frame31.BackgroundColor3 = rail
                end
            end
            local t254 = {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = t3.fill,
				Position = UDim2.new(1, -6, 0.5, 0),
				Size = UDim2.fromOffset(20, 20),
				Font = t4.mid,
				Text = "×",
				TextColor3 = t3.text,
				TextSize = 14,
				AutoButtonColor = false,
				ZIndex = 61,
				Active = true
			}
            local TextButton2 = Instance.new("TextButton")
            if t254 then
                for k, v in pairs(t254) do
                    TextButton2[k] = v
                end
            end
            if TextButton then
                TextButton2.Parent = TextButton
            end
            local v3704 = TextButton2
            local t255 = {
				CornerRadius = UDim.new(0, 6)
			}
            local UICorner16 = Instance.new("UICorner")
            if t255 then
                for k, v in pairs(t255) do
                    UICorner16[k] = v
                end
            end
            if v3704 then
                UICorner16.Parent = v3704
            end
            local s24 = "line"
            local t256 = {
				Color = t3.line or t3.line,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			}
            local UIStroke12 = Instance.new("UIStroke")
            if t256 then
                for k, v in pairs(t256) do
                    UIStroke12[k] = v
                end
            end
            if v3704 then
                UIStroke12.Parent = v3704
            end
            if s24 then
                UIStroke12:SetAttribute("th_stroke", s24)
            end
            if v3704 then
                v3704:SetAttribute("th_bg", "fill")

                local fill = t3.fill

                if fill and v3704:IsA("GuiObject") then
                    v3704.BackgroundColor3 = fill
                end
            end
            if v3704 then
                v3704:SetAttribute("th_text", "text")

                local text = t3.text

                if text then
                    v3704.TextColor3 = text
                end
            end
            v85(v3704, "fill", "lift")
            v3704.MouseButton1Click:Connect(function()
                if t218.sellFrame then
                    t218.sellFrame.Visible = false
                end
            end)
            local t257 = {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(10, 28),
				Size = UDim2.new(1, -20, 0, 16),
				Font = t4.body,
				Text = "",
				TextColor3 = t3.dim,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				ZIndex = 41
			}
            local TextLabel = Instance.new("TextLabel")
            if t257 then
                for k, v in pairs(t257) do
                    TextLabel[k] = v
                end
            end
            if v3673 then
                TextLabel.Parent = v3673
            end
            if TextLabel then
                TextLabel:SetAttribute("th_text", "dim")

                local dim = t3.dim

                if dim then
                    TextLabel.TextColor3 = dim
                end
            end
            local t258 = {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(8, 46),
				Size = UDim2.new(1, -16, 1, -102),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.new(0, 0, 0, 0),
				ScrollBarThickness = 4,
				ScrollBarImageColor3 = t3.line,
				ClipsDescendants = true,
				ZIndex = 41
			}
            local ScrollingFrame = Instance.new("ScrollingFrame")
            if t258 then
                for k, v in pairs(t258) do
                    ScrollingFrame[k] = v
                end
            end
            if v3673 then
                ScrollingFrame.Parent = v3673
            end
            local v3725 = ScrollingFrame
            local t259 = {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder
			}
            local UIListLayout = Instance.new("UIListLayout")
            if t259 then
                for k, v in pairs(t259) do
                    UIListLayout[k] = v
                end
            end
            if v3725 then
                UIListLayout.Parent = v3725
            end
            local function v3730(p374, p375)
                local t260 = {
					BackgroundTransparency = 1,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(1, 0, 0, 0),
					LayoutOrder = p374,
					ZIndex = 42
				}
                local v4792 = v3725
                local Frame32 = Instance.new("Frame")

                if t260 then
                    for k, v in pairs(t260) do
                        Frame32[k] = v
                    end
                end

                if v4792 then
                    Frame32.Parent = v4792
                end

                local t261 = {
					FillDirection = Enum.FillDirection.Vertical,
					Padding = UDim.new(0, 6),
					SortOrder = Enum.SortOrder.LayoutOrder
				}
                local UIListLayout3 = Instance.new("UIListLayout")

                if t261 then
                    for k, v in pairs(t261) do
                        UIListLayout3[k] = v
                    end
                end

                if Frame32 then
                    UIListLayout3.Parent = Frame32
                end

                local t262 = {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 14),
					Font = t4.mono,
					Text = p375,
					TextColor3 = t3.dim,
					TextSize = 10,
					TextXAlignment = Enum.TextXAlignment.Left,
					LayoutOrder = 1,
					ZIndex = 42
				}
                local TextLabel14 = Instance.new("TextLabel")

                if t262 then
                    for k, v in pairs(t262) do
                        TextLabel14[k] = v
                    end
                end

                if Frame32 then
                    TextLabel14.Parent = Frame32
                end

                if TextLabel14 then
                    TextLabel14:SetAttribute("th_text", "dim")

                    local dim = t3.dim

                    if dim then
                        TextLabel14.TextColor3 = dim
                    end
                end

                local t263 = {
					BackgroundTransparency = 1,
					AutomaticSize = Enum.AutomaticSize.Y,
					Size = UDim2.new(1, 0, 0, 0),
					LayoutOrder = 2,
					ZIndex = 42
				}
                local Frame33 = Instance.new("Frame")

                if t263 then
                    for k, v in pairs(t263) do
                        Frame33[k] = v
                    end
                end

                if Frame32 then
                    Frame33.Parent = Frame32
                end

                local v4809 = Frame33
                local t264 = {
					CellPadding = UDim2.fromOffset(4, 4),
					CellSize = UDim2.fromOffset(40, 40),
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					SortOrder = Enum.SortOrder.LayoutOrder
				}
                local UIGridLayout = Instance.new("UIGridLayout")

                if t264 then
                    for k, v in pairs(t264) do
                        UIGridLayout[k] = v
                    end
                end

                if v4809 then
                    UIGridLayout.Parent = v4809
                end

                local UIGridLayout2 = v4809:FindFirstChildOfClass("UIGridLayout")

                local function v4815()
                    if not v4809 or not UIGridLayout2 then
                        return
                    end

                    local v4895 = math.max(0, math.ceil(UIGridLayout2.AbsoluteContentSize.Y))

                    v4809.AutomaticSize = Enum.AutomaticSize.None
                    v4809.Size = UDim2.new(1, 0, 0, v4895)
                end

                if UIGridLayout2 then
                    UIGridLayout2:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(v4815)
                end

                return {
					lab = TextLabel14,
					grid = v4809,
					title = p375,
					fit = v4815
				}
            end
            local v3731 = v3730(1, "Pets")
            local v3732 = v3730(2, "Eggs")
            local t265 = {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundColor3 = t3.card,
				BorderSizePixel = 0,
				Position = UDim2.new(0, 0, 1, 0),
				Size = UDim2.new(1, 0, 0, 56),
				ClipsDescendants = true,
				ZIndex = 50
			}
            local Frame34 = Instance.new("Frame")
            if t265 then
                for k, v in pairs(t265) do
                    Frame34[k] = v
                end
            end
            if v3673 then
                Frame34.Parent = v3673
            end
            if Frame34 then
                Frame34:SetAttribute("th_bg", "card")

                local card = t3.card

                if card and Frame34:IsA("GuiObject") then
                    Frame34.BackgroundColor3 = card
                end
            end
            local t266 = {
				BackgroundColor3 = t3.line,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, 1),
				ZIndex = 51
			}
            local Frame35 = Instance.new("Frame")
            if t266 then
                for k, v in pairs(t266) do
                    Frame35[k] = v
                end
            end
            if Frame34 then
                Frame35.Parent = Frame34
            end
            if Frame35 then
                Frame35:SetAttribute("th_bg", "line")

                local line = t3.line

                if line and Frame35:IsA("GuiObject") then
                    Frame35.BackgroundColor3 = line
                end
            end
            local t267 = {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, 1),
				Size = UDim2.new(1, 0, 1, -1),
				ZIndex = 51
			}
            local Frame36 = Instance.new("Frame")
            if t267 then
                for k, v in pairs(t267) do
                    Frame36[k] = v
                end
            end
            if Frame34 then
                Frame36.Parent = Frame34
            end
            local t268 = {
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 6),
				PaddingBottom = UDim.new(0, 6)
			}
            local UIPadding = Instance.new("UIPadding")
            if t268 then
                for k, v in pairs(t268) do
                    UIPadding[k] = v
                end
            end
            if Frame36 then
                UIPadding.Parent = Frame36
            end
            local t269 = {
				FillDirection = Enum.FillDirection.Vertical,
				Padding = UDim.new(0, 2),
				SortOrder = Enum.SortOrder.LayoutOrder
			}
            local UIListLayout4 = Instance.new("UIListLayout")
            if t269 then
                for k, v in pairs(t269) do
                    UIListLayout4[k] = v
                end
            end
            if Frame36 then
                UIListLayout4.Parent = Frame36
            end
            local t270 = {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 14),
				Font = t4.mid,
				Text = "Hover icon to display stats",
				TextColor3 = t3.text,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				LayoutOrder = 1,
				ZIndex = 52
			}
            local TextLabel15 = Instance.new("TextLabel")
            if t270 then
                for k, v in pairs(t270) do
                    TextLabel15[k] = v
                end
            end
            if Frame36 then
                TextLabel15.Parent = Frame36
            end
            if TextLabel15 then
                TextLabel15:SetAttribute("th_text", "text")

                local text = t3.text

                if text then
                    TextLabel15.TextColor3 = text
                end
            end
            local t271 = {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 13),
				Font = t4.mono,
				Text = "",
				TextColor3 = t3.dim,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				LayoutOrder = 2,
				ZIndex = 52
			}
            local TextLabel16 = Instance.new("TextLabel")
            if t271 then
                for k, v in pairs(t271) do
                    TextLabel16[k] = v
                end
            end
            if Frame36 then
                TextLabel16.Parent = Frame36
            end
            if TextLabel16 then
                TextLabel16:SetAttribute("th_text", "dim")

                local dim = t3.dim

                if dim then
                    TextLabel16.TextColor3 = dim
                end
            end
            local t272 = {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 13),
				Font = t4.body,
				Text = "",
				TextColor3 = t3.mute,
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
				LayoutOrder = 3,
				ZIndex = 52
			}
            local TextLabel17 = Instance.new("TextLabel")
            if t272 then
                for k, v in pairs(t272) do
                    TextLabel17[k] = v
                end
            end
            if Frame36 then
                TextLabel17.Parent = Frame36
            end
            if TextLabel17 then
                TextLabel17:SetAttribute("th_text", "mute")

                local mute = t3.mute

                if mute then
                    TextLabel17.TextColor3 = mute
                end
            end
            t218.sellTips = {
				name = TextLabel15,
				a = TextLabel16,
				b = TextLabel17,
				sub = TextLabel,
				pets = v3731,
				eggs = v3732
			}
            local u3770
            local inputPosition3
            local Position4
            TextButton.InputBegan:Connect(function(input)
                local UserInputType = input.UserInputType

                if UserInputType ~= Enum.UserInputType.MouseButton1 and UserInputType ~= Enum.UserInputType.Touch then
                    return
                end

                local inputPosition4 = input.Position
                local AbsolutePosition = v3704.AbsolutePosition
                local AbsoluteSize3 = v3704.AbsoluteSize

                if inputPosition4.X >= AbsolutePosition.X and inputPosition4.X <= AbsolutePosition.X + AbsoluteSize3.X and inputPosition4.Y >= AbsolutePosition.Y and inputPosition4.Y <= AbsolutePosition.Y + AbsoluteSize3.Y then
                    return
                end

                u3770 = true
                inputPosition3 = input.Position
                Position4 = v3673.Position
                t218.sellMoved = true
                t218.sellPos = Position4
            end)
            if not t218.sellDrag then
                local v3773 = t218
                local connection14 = UserInputService.InputChanged:Connect(function(input)
                    if not u3770 then
                        return
                    end

                    local UserInputType = input.UserInputType

                    if UserInputType ~= Enum.UserInputType.MouseMovement and UserInputType ~= Enum.UserInputType.Touch then
                        return
                    end

                    if not t218.sellFrame or not t218.sellFrame.Parent or not Position4 or not inputPosition3 then
                        u3770 = false

                        return
                    end

                    local v4823 = input.Position - inputPosition3
                    local uDim2 = UDim2.new(Position4.X.Scale, Position4.X.Offset + v4823.X, Position4.Y.Scale, Position4.Y.Offset + v4823.Y)

                    t218.sellFrame.Position = uDim2
                    t218.sellPos = uDim2
                end)

                if connection14 then
                    t152[connection14] = true
                end

                v3773.sellDrag = connection14

                local v3775 = t218
                local connection15 = UserInputService.InputEnded:Connect(function(input)
                    local UserInputType = input.UserInputType

                    if UserInputType == Enum.UserInputType.MouseButton1 or UserInputType == Enum.UserInputType.Touch then
                        u3770 = false

                        if t218.sellFrame then
                            t218.sellPos = t218.sellFrame.Position
                        end
                    end
                end)

                if connection15 then
                    t152[connection15] = true
                end

                v3775.sellEnd = connection15
            end
            t218.sellFrame = v3673

            return v3673
        end
        local function v2153(p376, p377, p378)
            local g3804
            local v3803
            for _, child in ipairs(p376.grid:GetChildren()) do
                if child:IsA("GuiObject") then
                    child:Destroy()
                end
            end
            if #p377 == 0 then
                p376.lab.Text = p376.title .. " · none"

                return
            end
            local n55 = 0
            for i = 1, #p377 do
                n55 += p377[i].n or 1
            end
            p376.lab.Text = p376.title .. " · " .. tostring(n55)
            for i = 1, #p377 do
                local v3785 = p377[i]
                local v3786, v3787, v3788 = v2150(v3785)
                local t273 = {
					BackgroundColor3 = t3.fill,
					Text = "",
					AutoButtonColor = false,
					LayoutOrder = i,
					ZIndex = 43
				}
                local grid = p376.grid
                local TextButton = Instance.new("TextButton")

                if t273 then
                    for k, v in pairs(t273) do
                        TextButton[k] = v
                    end
                end

                if grid then
                    TextButton.Parent = grid
                end

                local t274 = {
					CornerRadius = UDim.new(0, 8)
				}
                local UICorner = Instance.new("UICorner")

                if t274 then
                    for k, v in pairs(t274) do
                        UICorner[k] = v
                    end
                end

                if TextButton then
                    UICorner.Parent = TextButton
                end

                if TextButton then
                    TextButton:SetAttribute("th_bg", "fill")

                    local fill = t3.fill

                    if fill and TextButton:IsA("GuiObject") then
                        TextButton.BackgroundColor3 = fill
                    end
                end

                v83(TextButton, v3785.kind ~= "egg" and "line" or "accent", 1)

                local cfg = v3785.cfg
                local cat = v3785.cat

                v2123(cat, cfg)

                local v3801 = v2129(cfg, cat)

                for j = 1, #v3801 do
                    v3803 = t218.iconBy[v3801[j]]

                    if v3803 then
                        g3804 = true
                    end

                    if g3804 then
                        break
                    end
                end

                if not g3804 then
                    v3803 = nil
                end

                g3804 = false

                if v3803 then
                    local t275 = {
						BackgroundTransparency = 1,
						Position = UDim2.fromOffset(4, 4),
						Size = UDim2.fromOffset(32, 32),
						Image = v3803,
						ScaleType = Enum.ScaleType.Fit,
						ZIndex = 44
					}
                    local ImageLabel = Instance.new("ImageLabel")

                    if t275 then
                        for k, v in pairs(t275) do
                            ImageLabel[k] = v
                        end
                    end

                    if TextButton then
                        ImageLabel.Parent = TextButton
                    end

                    ImageLabel.ImageColor3 = Color3.new(1, 1, 1)
                else
                    local v3809 = string.sub(v3786, 1, 1)

                    if v3809 == "" then
                        v3809 = "?"
                    end

                    local t276 = {
						BackgroundTransparency = 1,
						Size = UDim2.fromScale(1, 1),
						Font = t4.mid,
						Text = string.upper(v3809),
						TextColor3 = t3.dim,
						TextSize = 14,
						ZIndex = 44
					}
                    local TextLabel = Instance.new("TextLabel")

                    if t276 then
                        for k, v in pairs(t276) do
                            TextLabel[k] = v
                        end
                    end

                    if TextButton then
                        TextLabel.Parent = TextButton
                    end

                    if TextLabel then
                        TextLabel:SetAttribute("th_text", "dim")

                        local dim = t3.dim

                        if dim then
                            TextLabel.TextColor3 = dim
                        end
                    end
                end

                if (v3785.n or 1) > 1 then
                    local t277 = {
						AnchorPoint = Vector2.new(1, 1),
						BackgroundColor3 = t3.accent,
						Position = UDim2.new(1, 2, 1, 2),
						Size = UDim2.fromOffset(16, 12),
						Font = t4.mono,
						Text = if not (v3785.n > 9) then tostring(v3785.n) else "9+",
						TextColor3 = t3.ink,
						TextSize = 8,
						ZIndex = 45
					}
                    local TextLabel = Instance.new("TextLabel")

                    if t277 then
                        for k, v in pairs(t277) do
                            TextLabel[k] = v
                        end
                    end

                    if TextButton then
                        TextLabel.Parent = TextButton
                    end

                    local t278 = {
						CornerRadius = UDim.new(0, 4)
					}
                    local UICorner17 = Instance.new("UICorner")

                    if t278 then
                        for k, v in pairs(t278) do
                            UICorner17[k] = v
                        end
                    end

                    if TextLabel then
                        UICorner17.Parent = TextLabel
                    end

                    if TextLabel then
                        TextLabel:SetAttribute("th_bg", "accent")

                        local accent = t3.accent

                        if accent and TextLabel:IsA("GuiObject") then
                            TextLabel.BackgroundColor3 = accent
                        end
                    end

                    if TextLabel then
                        TextLabel:SetAttribute("th_text", "ink")

                        local ink = t3.ink

                        if ink then
                            TextLabel.TextColor3 = ink
                        end
                    end
                end

                TextButton.MouseEnter:Connect(function()
                    p378.name.Text = v3786
                    p378.a.Text = v3787
                    p378.b.Text = v3788
                end)
                TextButton.MouseLeave:Connect(function()
                    p378.name.Text = "Hover icon to display stats"
                    p378.a.Text = ""
                    p378.b.Text = ""
                end)
            end
            if p376.fit then
                pcall(p376.fit)
                task.defer(p376.fit)
            end
        end
        local connection16 = RunService.Stepped:Connect(function()
            if not u1117 or u1116 then
                return
            end

            pcall(v2141)
        end)
        if connection16 then
            t152[connection16] = true
        end
        t218.conn = connection16
        local connection17 = RunService.RenderStepped:Connect(function()
            if not u1117 then
                return
            end

            pcall(v2149)
        end)
        if connection17 then
            t152[connection17] = true
        end
        t218.dieConn = connection17
        task.defer(function()
            pcall(v2128)
        end)

        return {
			fps = function()
            local v3526 = tonumber(t9.FPSCap) or 0

            if not setfpscap then
                return
            end

            pcall(setfpscap, v3526 > 0 and v3526 or 0)
        end,
			opt = function(p379)
            local Lighting = game:GetService("Lighting")
            local Terrain = workspace:FindFirstChildOfClass("Terrain")

            if p379 then
                if not t218.optSaved then
                    t218.optSaved = {}
                    pcall(function()
                        t218.optSaved.quality = settings().Rendering.QualityLevel
                    end)
                    pcall(function()
                        t218.optSaved.savedQuality = UserSettings().GameSettings.SavedQualityLevel
                    end)
                    pcall(function()
                        t218.optSaved.meshDetail = settings().Rendering.MeshPartDetailLevel
                    end)
                    pcall(function()
                        local GameSettings = UserSettings().GameSettings

                        t218.optSaved.savedGfx = GameSettings.SavedQualityLevel
                    end)
                    pcall(function()
                        t218.optSaved.shadows = Lighting.GlobalShadows
                        t218.optSaved.brightness = Lighting.Brightness
                        t218.optSaved.envDiff = Lighting.EnvironmentDiffuseScale
                        t218.optSaved.envSpec = Lighting.EnvironmentSpecularScale
                        t218.optSaved.fogEnd = Lighting.FogEnd
                        t218.optSaved.fogStart = Lighting.FogStart
                        t218.optSaved.clock = Lighting.ClockTime
                        t218.optSaved.ambient = Lighting.Ambient
                        t218.optSaved.outdoor = Lighting.OutdoorAmbient
                        t218.optSaved.exposure = Lighting.ExposureCompensation
                    end)

                    if Terrain then
                        pcall(function()
                            t218.optSaved.waterWave = Terrain.WaterWaveSize
                            t218.optSaved.waterSpeed = Terrain.WaterWaveSpeed
                            t218.optSaved.waterReflect = Terrain.WaterReflectance
                            t218.optSaved.decoration = Terrain.Decoration
                        end)
                    end
                end

                pcall(function()
                    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                end)
                pcall(function()
                    UserSettings().GameSettings.SavedQualityLevel = Enum.SavedQualityLevel.QualityLevel1
                end)
                pcall(function()
                    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
                end)
                pcall(function()
                    Lighting.GlobalShadows = false
                    Lighting.Brightness = 1
                    Lighting.EnvironmentDiffuseScale = 0
                    Lighting.EnvironmentSpecularScale = 0
                    Lighting.FogEnd = 250
                    Lighting.FogStart = 0
                    Lighting.ExposureCompensation = -0.4
                end)

                if Terrain then
                    pcall(function()
                        Terrain.WaterWaveSize = 0
                        Terrain.WaterWaveSpeed = 0
                        Terrain.WaterReflectance = 0
                        Terrain.Decoration = false
                    end)
                end

                if not t218.optFx then
                    t218.optFx = {}
                end

                for _, child in ipairs(Lighting:GetChildren()) do
                    if child:IsA("PostEffect") or child:IsA("Atmosphere") or child:IsA("Sky") or child:IsA("Clouds") then
                        if t218.optFx[child] == nil then
                            if child:IsA("PostEffect") or child:IsA("Clouds") then
                                t218.optFx[child] = {
										Enabled = child.Enabled
									}
                            elseif child:IsA("Atmosphere") then
                                t218.optFx[child] = {
										Density = child.Density,
										Offset = child.Offset,
										Glare = child.Glare,
										Haze = child.Haze
									}
                            elseif child:IsA("Sky") then
                                t218.optFx[child] = {
										Parent = child.Parent
									}
                            end
                        end

                        pcall(function()
                            if child:IsA("PostEffect") or child:IsA("Clouds") then
                                child.Enabled = false

                                return
                            end

                            if child:IsA("Atmosphere") then
                                child.Density = 0
                                child.Glare = 0
                                child.Haze = 0
                            end
                        end)
                    end
                end

                pcall(function()
                    for _, descendant in ipairs(workspace:GetDescendants()) do
                        v2143(descendant)
                    end
                end)

                if t218.optAdd then
                    pcall(function()
                        t218.optAdd:Disconnect()
                    end)
                    t218.optAdd = nil
                end

                t218.optAdd = workspace.DescendantAdded:Connect(function(descendant)
                    if t9.Optimizer then
                        v2143(descendant)
                    end
                end)

                return
            end

            if t218.optSaved then
                if t218.optAdd then
                    pcall(function()
                        t218.optAdd:Disconnect()
                    end)
                    t218.optAdd = nil
                end

                pcall(function()
                    if t218.optSaved.quality then
                        settings().Rendering.QualityLevel = t218.optSaved.quality
                    end

                    if t218.optSaved.savedQuality then
                        UserSettings().GameSettings.SavedQualityLevel = t218.optSaved.savedQuality
                    end

                    if t218.optSaved.meshDetail then
                        settings().Rendering.MeshPartDetailLevel = t218.optSaved.meshDetail
                    end

                    Lighting.GlobalShadows = t218.optSaved.shadows

                    if t218.optSaved.brightness then
                        Lighting.Brightness = t218.optSaved.brightness
                    end

                    if t218.optSaved.envDiff then
                        Lighting.EnvironmentDiffuseScale = t218.optSaved.envDiff
                    end

                    if t218.optSaved.envSpec then
                        Lighting.EnvironmentSpecularScale = t218.optSaved.envSpec
                    end

                    if t218.optSaved.fogEnd then
                        Lighting.FogEnd = t218.optSaved.fogEnd
                    end

                    if t218.optSaved.fogStart then
                        Lighting.FogStart = t218.optSaved.fogStart
                    end

                    if t218.optSaved.exposure then
                        Lighting.ExposureCompensation = t218.optSaved.exposure
                    end

                    if Terrain then
                        if t218.optSaved.waterWave ~= nil then
                            Terrain.WaterWaveSize = t218.optSaved.waterWave
                        end

                        if t218.optSaved.waterSpeed ~= nil then
                            Terrain.WaterWaveSpeed = t218.optSaved.waterSpeed
                        end

                        if t218.optSaved.waterReflect ~= nil then
                            Terrain.WaterReflectance = t218.optSaved.waterReflect
                        end

                        if t218.optSaved.decoration ~= nil then
                            Terrain.Decoration = t218.optSaved.decoration
                        end
                    end

                    if t218.optFx then
                        for k, v in pairs(t218.optFx) do
                            if k.Parent and type(v) == "table" then
                                pcall(function()
                                    if v.Enabled ~= nil then
                                        k.Enabled = v.Enabled
                                    end

                                    if v.Density then
                                        k.Density = v.Density
                                    end

                                    if v.Glare then
                                        k.Glare = v.Glare
                                    end

                                    if v.Haze then
                                        k.Haze = v.Haze
                                    end
                                end)
                            end
                        end

                        t218.optFx = nil
                    end

                    if t218.optInst then
                        for k, v in pairs(t218.optInst) do
                            if k.Parent and type(v) == "table" then
                                pcall(function()
                                    if v.Enabled ~= nil then
                                        k.Enabled = v.Enabled
                                    end

                                    if v.Brightness ~= nil then
                                        k.Brightness = v.Brightness
                                    end

                                    if v.Rate ~= nil then
                                        k.Rate = v.Rate
                                    end
                                end)
                            end
                        end

                        t218.optInst = nil
                    end
                end)
                t218.optSaved = nil
            end
        end,
			clear = function()
            if t218.optAdd then
                pcall(function()
                    t218.optAdd:Disconnect()
                end)
                t218.optAdd = nil
            end

            if t218.conn then
                t218.conn:Disconnect()
                t218.conn = nil
            end

            if t218.dieConn then
                t218.dieConn:Disconnect()
                t218.dieConn = nil
            end

            if t218.statsDrag then
                pcall(function()
                    t218.statsDrag:Disconnect()
                end)
                t218.statsDrag = nil
            end

            if t218.statsEnd then
                pcall(function()
                    t218.statsEnd:Disconnect()
                end)
                t218.statsEnd = nil
            end

            if t218.statsFrame then
                pcall(function()
                    t218.statsFrame:Destroy()
                end)
                t218.statsFrame = nil
                t218.statsRows = nil
            end

            v2151()

            for _, v in pairs(t218.pool) do
                if v.bb then
                    v.bb:Destroy()
                end

                if v.dummy then
                    pcall(function()
                        v.dummy:Destroy()
                    end)
                end
            end

            for k in pairs(t218.pool) do
                t218.pool[k] = nil
            end

            for _, v in ipairs({
					"att0",
					"att1",
					"beamObj",
					"tip",
					"folder",
					"world"
				}) do
                local v3839 = t218[v]

                if v3839 then
                    pcall(function()
                        v3839:Destroy()
                    end)
                    t218[v] = nil
                end
            end
        end,
			tick = v2141,
			stats = v2148,
			sellPreview = function(p380, p381, p382)
            local v3828 = type(p380) == "table" and p380 or {}
            local v3829 = type(p381) == "table" and p381 or {}

            t9.StatsPanel = true
            pcall(v2148, true)
            pcall(v2147)

            if t218.statsFrame then
                t218.statsFrame.Visible = true
                pcall(function()
                    t218.statsFrame.ClipsDescendants = false
                end)
            end

            local ok51, result51 = pcall(v2152)
            local v3832 = ok51 and result51 or t218.sellFrame

            if not ok51 then
                v1102("esp", "preview build ERR", (tostring(result51)))
            end

            if not v3832 or not v3832.Parent then
                v1102("esp", "preview missing panel")

                return false
            end

            u2116(v3832)
            v3832.Visible = true

            local sellTips = t218.sellTips

            if sellTips then
                if sellTips.sub then
                    sellTips.sub.Text = tostring(p382 or "")
                end

                if sellTips.name then
                    sellTips.name.Text = "Hover icon to display stats"
                end

                if sellTips.a then
                    sellTips.a.Text = ""
                end

                if sellTips.b then
                    sellTips.b.Text = ""
                end

                if sellTips.pets then
                    pcall(v2153, sellTips.pets, v3828, sellTips)
                end

                if sellTips.eggs then
                    pcall(v2153, sellTips.eggs, v3829, sellTips)
                end
            end

            return true
        end,
			closeSellPreview = function()
            if t218.sellFrame then
                t218.sellFrame.Visible = false
            end
        end,
			icon = function(p383, p384)
            v2123(p384, p383)

            local v3334 = v2129(p383, p384)

            for i = 1, #v3334 do
                local v3336 = t218.iconBy[v3334[i]]

                if v3336 then
                    return v3336
                end
            end
        end,
			liveIcon = function(p385, p386, p387)
            local v3340 = v2129(p385, p386)

            if type(p387) == "string" and p387 ~= "" then
                if type(p387) == "string" and p387 ~= "" then
                    local v3341 = string.lower(p387)

                    v3340[#v3340 + 1] = v3341
                    v3340[#v3340 + 1] = v3341:gsub("[%s_%-]+", "")
                end
            end

            local t279 = {}

            for i = 1, #v3340 do
                t279[v3340[i]] = true
            end

            for _, v in pairs(t218.pool) do
                local v3346 = v.icon and v.icon.Image

                if type(v3346) ~= "string" or v3346 == "" then
                    continue
                end

                local v3347 = string.lower((tostring(v.title and v.title.Text or ""))):gsub("^▸%s*", ""):gsub("^>%s*", "")
                local v3348 = v3347:gsub("[%s_%-]+", "")

                if v3347 ~= "" and t279[v3347] or v3348 ~= "" and t279[v3348] then
                    return v3346
                end
            end

            for i = 1, #v3340 do
                local v3350 = t218.iconBy[v3340[i]]

                if v3350 then
                    return v3350
                end
            end
        end,
			scanIcons = v2128,
			bumpPlot = function()
            t218.plotAt = 0
        end
		}
    end)()
    local function v1227(p388)
        local v2157 = select(1, u1219())

        if not p388 then
            return false, v2157
        end

        if v2157 and Vector3.new(v2157.X - p388.Position.X, 0, v2157.Z - p388.Position.Z).Magnitude <= 28 then
            return true, v2157
        end

        return false, v2157
    end
    local function v1228()
        local ServerTimeNow = workspace:GetServerTimeNow()
        local AreaEggCycleDisabledAt = workspace:GetAttribute("AreaEggCycleDisabledAt")

        if type(AreaEggCycleDisabledAt) == "number" then
            ServerTimeNow = math.min(ServerTimeNow, AreaEggCycleDisabledAt)
        end

        local AreaEggCycleAnchorAt = workspace:GetAttribute("AreaEggCycleAnchorAt")
        local AreaEggCycleAnchorIndex = workspace:GetAttribute("AreaEggCycleAnchorIndex")

        if type(AreaEggCycleAnchorAt) ~= "number" then
            AreaEggCycleAnchorAt = 0
        end

        if type(AreaEggCycleAnchorIndex) ~= "number" then
            AreaEggCycleAnchorIndex = 0
        end

        local v2165 = AreaEggCycleAnchorAt + (math.max(0, AreaEggCycleAnchorIndex + math.floor((ServerTimeNow - AreaEggCycleAnchorAt) / 300)) + 1) * 300

        return math.max(0, v2165 - ServerTimeNow)
    end
    local function v1229()
        local ok52, result52 = pcall(v1228)

        if ok52 and type(result52) == "number" then
            return math.max(0, math.floor(result52 + 0.5))
        end

        return 0
    end
    local u1230 = (function()
        local TeleportService = game:GetService("TeleportService")
        local PlaceId = game.PlaceId
        local elapsed21 = os.clock()
        local n56 = 0
        local s25 = "off"
        local t280 = {}
        local u2178 = false
        local u2179 = false
        local n57 = 0
        local n58 = 0
        local n59 = 0
        local n60 = 10
        local n61 = 0
        local n62 = 0
        local elapsed22 = os.clock()
        local u2187 = tonumber(t216 and t216.banked) or 0
        local s26 = "idle"
        local u2190 = false
        local u2191 = false
        local v2192 = getgenv and getgenv() or _G
        v2192.NEXUSHopUsed = type(v2192.NEXUSHopUsed) == "table" and v2192.NEXUSHopUsed or {}
        v2192.NEXUSHopRing = type(v2192.NEXUSHopRing) == "table" and v2192.NEXUSHopRing or {}
        v2192.NEXUSHopCache = type(v2192.NEXUSHopCache) == "table" and v2192.NEXUSHopCache or {}
        if type(v2192.NEXUSHopUntil) == "number" then
            local ok53, result53 = pcall(function()
                local v3842 = v1228()
                local AreaEggCycleNightSeconds = workspace:GetAttribute("AreaEggCycleNightSeconds")

                if type(AreaEggCycleNightSeconds) ~= "number" then
                    AreaEggCycleNightSeconds = 10
                end

                return v3842 - math.clamp(AreaEggCycleNightSeconds, 1, 300)
            end)
            local v2195 = (not ok53 or type(result53) ~= "number") and 0 or math.max(0, result53)

            if math.abs(v2195 - v2192.NEXUSHopUntil) < 10 then
            end
        end
        local function v2196(p389)
            if type(p389) ~= "string" then
                return 0
            end

            local v3845 = string.lower(p389:gsub(",", ""):gsub("%s+", ""))

            if v3845 == "" or v3845 == "off" or v3845:find("blank", 1, true) then
                return 0
            end

            return tonumber(v3845:match("([%d%.]+)")) or 0
        end
        local function v2197(p390)
            if type(p390) ~= "string" or p390 == "" then
                return
            end

            local NEXUSHopRing = v2192.NEXUSHopRing

            for i = #NEXUSHopRing, 1, -1 do
                if p390 == NEXUSHopRing[i] then
                    table.remove(NEXUSHopRing, i)
                end
            end

            NEXUSHopRing[#NEXUSHopRing + 1] = p390

            while #NEXUSHopRing > 48 do
                table.remove(NEXUSHopRing, 1)
            end
        end
        local function v2198(p391)
            local str28 = tostring(p391 or "")
            if str28 == "" or str28 == tostring(game.JobId) then
                return true
            end
            local NEXUSHopRing = v2192.NEXUSHopRing
            local g3859
            local v3858
            for i = 1, #NEXUSHopRing do
                if str28 == NEXUSHopRing[i] then
                    v3858 = true
                    g3859 = true
                end

                if g3859 then
                    break
                end
            end
            if not g3859 then
                v3858 = false
            end
            g3859 = false
            if v3858 then
                return true
            end
            local v3860 = v2192.NEXUSHopUsed[str28]
            if type(v3860) ~= "number" then
                return false
            end
            if os.time() - v3860 > 2100 then
                v2192.NEXUSHopUsed[str28] = nil

                return false
            end

            return true
        end
        local function v2199()
            if type(readfile) ~= "function" then
                return
            end
            local ok54, result54 = pcall(readfile, (("NEXUS" .. "/" .. v26(t1.Game)) .. "/cache") .. "/hop-used.json")
            if not ok54 or type(result54) ~= "string" or result54 == "" then
                return
            end
            local data
            if not pcall(function()
                data = HttpService:JSONDecode(result54)
            end) or type(data) ~= "table" then
                return
            end
            if tonumber(data.place) and tonumber(data.place) ~= PlaceId then
                return
            end
            local timestamp = os.time()
            if type(data.jobs) == "table" then
                for k, v in pairs(data.jobs) do
                    local v3867 = type(v) == "number" and v or type(v) == "table" and tonumber(v.t)
                    local str29 = tostring(k)

                    if v3867 and timestamp - v3867 <= 2100 and v3867 > (tonumber(v2192.NEXUSHopUsed[str29]) or 0) then
                        v2192.NEXUSHopUsed[str29] = v3867
                    end
                end
            end
            if type(data.ring) == "table" then
                local t281 = {}
                local t282 = {}

                for i = 1, #data.ring do
                    local v3872 = data.ring[i]

                    if type(v3872) == "table" then
                        v3872 = v3872.id
                    end

                    if type(v3872) == "string" and v3872 ~= "" and not t281[v3872] then
                        t281[v3872] = true
                        t282[#t282 + 1] = v3872
                    end
                end

                for i = 1, #v2192.NEXUSHopRing do
                    local v3874 = v2192.NEXUSHopRing[i]

                    if type(v3874) == "table" then
                        v3874 = v3874.id
                    end

                    if type(v3874) == "string" and v3874 ~= "" and not t281[v3874] then
                        t281[v3874] = true
                        t282[#t282 + 1] = v3874
                    end
                end

                v2192.NEXUSHopRing = t282

                while #v2192.NEXUSHopRing > 48 do
                    table.remove(v2192.NEXUSHopRing, 1)
                end
            end
        end
        local function v2200()
            if type(writefile) ~= "function" then
                return
            end

            if type(makefolder) == "function" then
                pcall(makefolder, "NEXUS")
            end

            local v3875 = "NEXUS" .. "/" .. v26(t1.Game)

            if type(makefolder) == "function" then
                pcall(makefolder, v3875)
            end

            local v3876 = ("NEXUS" .. "/" .. v26(t1.Game)) .. "/cache"

            if type(makefolder) == "function" then
                pcall(makefolder, v3876)
            end

            local v3877 = ("NEXUS" .. "/" .. v26(t1.Game)) .. "/configs"

            if type(makefolder) == "function" then
                pcall(makefolder, v3877)
            end

            local t283 = {}
            local timestamp = os.time()

            for k, v in pairs(v2192.NEXUSHopUsed) do
                if type(v) == "number" and timestamp - v <= 2100 then
                    t283[tostring(k)] = {
						t = v,
						by = str
					}
                end
            end

            local t284 = {
				v = 1,
				place = PlaceId,
				jobs = t283,
				ring = v2192.NEXUSHopRing
			}
            local ok55, result55 = pcall(function()
                return HttpService:JSONEncode(t284)
            end)

            if ok55 and type(result55) == "string" then
                pcall(writefile, (("NEXUS" .. "/" .. v26(t1.Game)) .. "/cache") .. "/hop-used.json", result55)
            end
        end
        v2199()
        local str30 = tostring(tostring(game.JobId) or "")
        if str30 ~= "" then
            v2192.NEXUSHopUsed[str30] = os.time()
            v2197(str30)
        end
        v2200()
        local function v2202(p392, p393)
            local v3889 = tonumber(p393) or 2.2
            local v3890 = syn and syn.request or (http_request or (request or (http and http.request or fluxus and fluxus.request)))
            local u3891
            local u3892
            local u3893
            if v3890 then
                task.spawn(function()
                    local ok56, result56 = pcall(v3890, {
						Url = p392,
						Method = "GET",
						Headers = {
							Accept = "application/json"
						}
					})

                    u3891 = true

                    if ok56 then
                        u3892 = result56

                        return
                    end

                    u3893 = result56
                end)
            else
                if type(game.HttpGet) ~= "function" then
                    return nil, "no http"
                end

                task.spawn(function()
                    local ok57, result57 = pcall(game.HttpGet, game, p392)

                    u3891 = true

                    if ok57 then
                        u3892 = {
							StatusCode = 200,
							Body = result57
						}

                        return
                    end

                    u3893 = result57
                end)
            end
            local elapsed23 = os.clock()
            while not u3891 and v3889 > os.clock() - elapsed23 do
                task.wait(0.05)
            end
            if not u3891 then
                return nil, "slow"
            end
            if u3893 then
                return nil, (tostring(u3893))
            end
            local v3895 = u3892 and tonumber(u3892.StatusCode or (u3892.status_code or u3892.Status))
            local v3896 = u3892 and (u3892.Body or u3892.body)
            if v3895 == 429 then
                local v3897 = n60
                local v3898 = u3892 and (u3892.Headers or u3892.headers)

                if type(v3898) == "table" then
                    local num = tonumber(v3898["Retry-After"] or (v3898["retry-after"] or v3898["Retry-after"]))

                    if num and num > 0 then
                        v3897 = math.max(v3897, num)
                    end
                end

                n59 = os.clock() + v3897
                n60 = math.min(60, math.max(12, n60 * 2))

                return nil, "rate limited"
            end
            if v3895 and v3895 >= 400 then
                return nil, "http " .. tostring(v3895)
            end
            if type(v3896) ~= "string" or v3896 == "" then
                return nil, "empty"
            end
            n60 = 10

            return v3896
        end
        local function v2203()
            local v3900 = math.clamp(math.floor(tonumber(t9.HopPages) or 3), 1, 10)
            local v3901 = t9.HopSkipFull ~= false
            local v3902 = t9.HopPlayers == "Highest"

            return tostring(PlaceId) .. ":" .. (not v3902 and "A" or "D") .. ":" .. (not v3901 and "0" or "1") .. ":" .. tostring(v3900)
        end
        local function v2204(p394)
            t280 = {}

            if type(p394) ~= "table" then
                return t280
            end

            v2199()

            local str31 = tostring(game.JobId)

            for i = 1, #p394 do
                local v3906 = p394[i]
                local v3907 = v3906 and tostring(v3906.id)

                if v3907 and v3907 ~= "" and v3907 ~= str31 and not v2198(v3907) then
                    t280[#t280 + 1] = {
						id = v3906.id,
						playing = tonumber(v3906.playing) or 0,
						maxPlayers = tonumber(v3906.maxPlayers) or 0
					}
                end
            end

            return t280
        end
        local function v2205(p395)
            local NEXUSHopCache = v2192.NEXUSHopCache

            if type(NEXUSHopCache) ~= "table" or (NEXUSHopCache.key ~= v2203() or type(NEXUSHopCache.list) ~= "table" or #NEXUSHopCache.list == 0) then
                NEXUSHopCache = nil

                if type(readfile) == "function" then
                    local ok58, result58 = pcall(readfile, (("NEXUS" .. "/" .. v26(t1.Game)) .. "/cache") .. "/hop-list.json")

                    if ok58 and type(result58) == "string" and result58 ~= "" then
                        local data
                        pcall(function()
                            data = HttpService:JSONDecode(result58)
                        end)
                        if type(data) == "table" and data.key == v2203() and type(data.list) == "table" and #data.list > 0 then
                            NEXUSHopCache = data
                            v2192.NEXUSHopCache = data
                        end
                    end
                end
            end

            if type(NEXUSHopCache) ~= "table" or type(NEXUSHopCache.list) ~= "table" or #NEXUSHopCache.list == 0 then
                return
            end

            local v3913 = os.time() - (tonumber(NEXUSHopCache.at) or 0)

            if v3913 > 90 and not p395 then
                return
            end

            v2204(NEXUSHopCache.list)

            if #t280 > 0 then
                return t280, v3913
            end
        end
        local function v2206(p396)
            if type(p396) ~= "table" or #p396 == 0 then
                return
            end

            local t285 = {
				key = v2203(),
				at = os.time(),
				list = p396
			}

            v2192.NEXUSHopCache = t285

            if type(writefile) == "function" then
                if type(makefolder) == "function" then
                    pcall(makefolder, "NEXUS")
                end

                local v3916 = "NEXUS" .. "/" .. v26(t1.Game)

                if type(makefolder) == "function" then
                    pcall(makefolder, v3916)
                end

                local v3917 = ("NEXUS" .. "/" .. v26(t1.Game)) .. "/cache"

                if type(makefolder) == "function" then
                    pcall(makefolder, v3917)
                end

                local v3918 = ("NEXUS" .. "/" .. v26(t1.Game)) .. "/configs"

                if type(makefolder) == "function" then
                    pcall(makefolder, v3918)
                end

                local ok59, result59 = pcall(function()
                    return HttpService:JSONEncode(t285)
                end)

                if ok59 and type(result59) == "string" then
                    pcall(writefile, (("NEXUS" .. "/" .. v26(t1.Game)) .. "/cache") .. "/hop-list.json", result59)
                end
            end
        end
        local function v2207()
            if v2205(false) then
                return t280, "cached"
            end

            if os.clock() < n59 then
                if v2205(true) then
                    return t280, "cached"
                end

                return t280, "rate limited"
            end

            n58 = os.clock()

            local v3921 = math.clamp(math.floor(tonumber(t9.HopPages) or 3), 1, 10)
            local v3922 = t9.HopSkipFull ~= false
            local v3923 = t9.HopPlayers == "Highest"
            local t286 = {}
            local s27 = ""

            for i = 1, v3921 do
                if i > 1 then
                    task.wait(0.12)
                end
                local v3927 = "https://games.roblox.com/v1/games/" .. tostring(PlaceId) .. "/servers/Public?sortOrder=" .. (not v3923 and "Asc" or "Desc") .. "&excludeFullGames=" .. (not v3922 and "false" or "true") .. "&limit=100"
                if s27 ~= "" then
                    local u3928 = s27

                    pcall(function()
                        u3928 = HttpService:UrlEncode(s27)
                    end)
                    v3927 ..= "&cursor=" .. u3928
                end
                local v3929, v3930 = v2202(v3927, 2.2)
                if not v3929 then
                    if #t286 > 0 then
                        break
                    end

                    if v2205(true) then
                        return t280, "cached"
                    end

                    return nil, v3930 or "fetch"
                end
                local data
                local v3932 = pcall(function()
                    data = HttpService:JSONDecode(v3929)
                end) and (data and data.data)
                if type(v3932) ~= "table" then
                    if #t286 > 0 then
                        break
                    end

                    if v2205(true) then
                        return t280, "cached"
                    end

                    return nil, "bad json"
                end
                for j = 1, #v3932 do
                    local v3934 = v3932[j]

                    if type(v3934) == "table" and type(v3934.id) == "string" then
                        t286[#t286 + 1] = {
							id = v3934.id,
							playing = tonumber(v3934.playing) or 0,
							maxPlayers = tonumber(v3934.maxPlayers) or 0
						}
                    end
                end
                s27 = type(data.nextPageCursor) == "string" and data.nextPageCursor or ""
                if s27 == "" then
                    break
                end
            end

            table.sort(t286, function(p397, p398)
                if v3923 then
                    return p397.playing > p398.playing
                end

                return p397.playing < p398.playing
            end)
            v2206(t286)
            v2204(t286)

            return t280
        end
        local function v2208()
            local NEXUSHopRing = v2192.NEXUSHopRing
            local t287 = {}
            local t288 = {}

            for i = math.max(1, #NEXUSHopRing - 7), #NEXUSHopRing do
                local v3939 = NEXUSHopRing[i]

                if type(v3939) == "string" and not t288[v3939] then
                    t288[v3939] = true
                    t287[#t287 + 1] = v3939
                end
            end

            local str32 = tostring(game.JobId)

            if not t288[str32] then
                t287[#t287 + 1] = str32
            end

            v2192.NEXUSHopRing = t287

            local timestamp = os.time()

            for k, v in pairs(v2192.NEXUSHopUsed) do
                if k ~= str32 and type(v) == "number" and timestamp - v > 480 then
                    v2192.NEXUSHopUsed[k] = nil
                end
            end

            v2200()
        end
        local function v2209()
            v2199()

            local v3944 = t9.HopSkipFull ~= false
            local str33 = tostring(game.JobId)
            local t289 = {}
            local t290 = {}

            while #t280 > 0 do
                local v3948 = table.remove(t280, 1)
                local v3949 = v3948 and tostring(v3948.id)

                if v3949 and v3949 ~= "" and v3949 ~= str33 and not v2198(v3949) then
                    local v3950 = tonumber(v3948.maxPlayers) or 0

                    if not v3944 or v3950 <= 0 or v3950 > (tonumber(v3948.playing) or 0) then
                        if #t289 < 12 then
                            t289[#t289 + 1] = v3948
                        else
                            t290[#t290 + 1] = v3948
                        end
                    end
                end
            end

            t280 = t290

            local v3952, str34

            repeat
                if not (#t289 > 0) then
                    return
                end

                local v3951 = math.random(1, #t289)

                v3952 = table.remove(t289, v3951)
                str34 = tostring(v3952.id)
                v2199()
            until str34 ~= str33 and not v2198(str34)

            local str35 = tostring(str34 or "")

            if str35 ~= "" then
                v2192.NEXUSHopUsed[str35] = os.time()
                v2197(str35)
            end

            v2200()

            for i = #t289, 1, -1 do
                table.insert(t280, 1, t289[i])
            end

            return v3952
        end
        local function v2210()
            if t9.AutoEvent == true then
                local v3956 = t216 and t216.state

                if v3956 == "FeedGo" or v3956 == "Feed" or v3956 == "ChestGo" or v3956 == "ChestOpen" then
                    return true
                end

                if t216 and t216.findChestTool and t216.findChestTool() then
                    return true
                end

                if t216 and t216.target and t216.target.event then
                    return true
                end

                if t216 and t216.pickSatchelEvent then
                    local ok60, result60 = pcall(t216.pickSatchelEvent)

                    if ok60 and type(result60) == "table" then
                        return result60
                    end
                end
            end

            if type(v1216) ~= "function" then
                return
            end

            local ok61, result61 = pcall(v1216)

            if ok61 and type(result61) == "table" and result61.matched == true and (result61.cfg or result61.earn) then
                return result61
            end
        end
        local function v2211(p399)
            if u2179 or u2178 then
                return false
            end

            if os.clock() - n57 < 2.4 then
                return false
            end

            u2179 = true
            n57 = os.clock()
            pcall(v272, true)
            s25 = p399 or "hopping"

            local v3974 = not t9.AutoHop and "off" or (s25 ~= "" and s25 or "on")
            local AutoHop = t10.AutoHop

            if AutoHop and AutoHop.status then
                pcall(function()
                    AutoHop.status.Text = v3974 .. " · " .. tostring(n56) .. (n56 ~= 1 and " hops this session" or " hop this session")
                end)
            end

            if #t280 == 0 then
                local _, v3977 = v2207()

                if #t280 == 0 then
                    v2208()
                    v2205(true)

                    if #t280 == 0 then
                        u2179 = false
                        s25 = tostring(v3977 or "no servers")

                        local v3978 = not t9.AutoHop and "off" or (s25 ~= "" and s25 or "on")
                        local AutoHop2 = t10.AutoHop

                        if AutoHop2 and AutoHop2.status then
                            pcall(function()
                                AutoHop2.status.Text = v3978 .. " · " .. tostring(n56) .. (n56 ~= 1 and " hops this session" or " hop this session")
                            end)
                        end

                        local HopNow = t10.HopNow

                        if HopNow and HopNow.status then
                            HopNow.status.Text = s25
                        end

                        return false
                    end
                end
            end

            n56 += 1

            local str36 = tostring(game.JobId)
            local v3982 = false

            while u1117 and u2179 do
                local u3983 = v2209()

                if not u3983 then
                    v2208()
                    v2205(true)
                    u3983 = v2209()
                end

                if not u3983 then
                    break
                end

                local v3984 = v2192
                local ok62, result62 = pcall(function()
                    local v4836 = v1228()
                    local AreaEggCycleNightSeconds = workspace:GetAttribute("AreaEggCycleNightSeconds")

                    if type(AreaEggCycleNightSeconds) ~= "number" then
                        AreaEggCycleNightSeconds = 10
                    end

                    return v4836 - math.clamp(AreaEggCycleNightSeconds, 1, 300)
                end)

                v3984.NEXUSHopUntil = (not ok62 or type(result62) ~= "number") and 0 or math.max(0, result62)
                u2178 = true
                s25 = (p399 or "hop") .. " · " .. tostring(#t280) .. " left"

                local v3987 = not t9.AutoHop and "off" or (s25 ~= "" and s25 or "on")
                local AutoHop3 = t10.AutoHop

                if AutoHop3 and AutoHop3.status then
                    pcall(function()
                        AutoHop3.status.Text = v3987 .. " · " .. tostring(n56) .. (n56 ~= 1 and " hops this session" or " hop this session")
                    end)
                end

                local ok63, result63 = pcall(function()
                    TeleportService:TeleportToPlaceInstance(PlaceId, tostring(u3983.id), LocalPlayer)
                end)

                if not ok63 then
                    u2178 = false
                    n61 += 1
                    v1102("hop", "fail", (tostring(result63)))
                else
                    local elapsed24 = os.clock()

                    while u1117 and u2178 and os.clock() - elapsed24 < 2.2 do
                        if str36 ~= tostring(game.JobId) then
                            v3982 = true

                            break
                        end

                        task.wait(0.1)
                    end

                    if str36 ~= tostring(game.JobId) then
                        v3982 = true

                        break
                    end

                    pcall(function()
                        TeleportService:TeleportCancel()
                    end)
                    u2178 = false
                    n61 += 1
                end
            end

            u2179 = false
            u2178 = false

            if v3982 then
                return true
            end

            s25 = "no servers"

            local v3992 = not t9.AutoHop and "off" or (s25 ~= "" and s25 or "on")
            local AutoHop4 = t10.AutoHop

            if AutoHop4 and AutoHop4.status then
                pcall(function()
                    AutoHop4.status.Text = v3992 .. " · " .. tostring(n56) .. (n56 ~= 1 and " hops this session" or " hop this session")
                end)
            end

            return false
        end
        local connection18 = TeleportService.TeleportInitFailed:Connect(function(p400)
            if p400 ~= LocalPlayer then
                return
            end

            u2178 = false
            n61 += 1
        end)
        if connection18 then
            t152[connection18] = true
        end
        local function v2213()
            if not u1117 then
                return
            end

            local elapsed25 = os.clock()
            local v3996 = elapsed25 - elapsed22

            elapsed22 = elapsed25

            if t216 and t216.banked ~= u2187 then
                u2187 = t216.banked
                n62 = 0
            end

            local v3997 = v1228()
            local AreaEggCycleNightSeconds = workspace:GetAttribute("AreaEggCycleNightSeconds")

            if type(AreaEggCycleNightSeconds) ~= "number" then
                AreaEggCycleNightSeconds = 10
            end

            local v3999 = v3997 <= math.clamp(AreaEggCycleNightSeconds, 1, 300)
            local v4000 = false

            if not v3999 then
                v4000 = not not v2210()
            end

            if t9.AutoSteal and t216 and t216.running and not v3999 then
                if v4000 then
                    n62 = 0
                else
                    n62 += v3996
                end
            end

            if not t9.AutoHop then
                if s26 ~= "idle" or u2190 or u2191 then
                    s26 = "idle"
                    u2190 = false
                    u2191 = false
                end

                s25 = "off"

                local v4001 = not t9.AutoHop and "off" or (s25 ~= "" and s25 or "on")
                local AutoHop = t10.AutoHop

                if AutoHop and AutoHop.status then
                    pcall(function()
                        AutoHop.status.Text = v4001 .. " · " .. tostring(n56) .. (n56 ~= 1 and " hops this session" or " hop this session")
                    end)
                end

                return
            end

            if u2178 or u2179 then
                local v4003 = not t9.AutoHop and "off" or (s25 ~= "" and s25 or "on")
                local AutoHop = t10.AutoHop

                if AutoHop and AutoHop.status then
                    pcall(function()
                        AutoHop.status.Text = v4003 .. " · " .. tostring(n56) .. (n56 ~= 1 and " hops this session" or " hop this session")
                    end)
                end

                return
            end

            if elapsed25 < elapsed21 + 1.6 then
                s25 = "settling"

                local v4005 = not t9.AutoHop and "off" or (s25 ~= "" and s25 or "on")
                local AutoHop = t10.AutoHop

                if AutoHop and AutoHop.status then
                    pcall(function()
                        AutoHop.status.Text = v4005 .. " · " .. tostring(n56) .. (n56 ~= 1 and " hops this session" or " hop this session")
                    end)
                end

                return
            end

            if t216 and t216.carrying == true then
                s25 = "carrying"

                local v4007 = not t9.AutoHop and "off" or (s25 ~= "" and s25 or "on")
                local AutoHop = t10.AutoHop

                if AutoHop and AutoHop.status then
                    pcall(function()
                        AutoHop.status.Text = v4007 .. " · " .. tostring(n56) .. (n56 ~= 1 and " hops this session" or " hop this session")
                    end)
                end

                return
            end

            s26 = "idle"
            u2190 = false
            u2191 = false

            local v4009 = v2196(t9.HopIdle)

            if v4009 > 0 then
                if v4009 < 5 then
                    v4009 = 5
                end

                if t9.AutoSteal and t216 and t216.running then
                    if v2210() then
                        s25 = "eggs · grabbing"

                        local v4010 = not t9.AutoHop and "off" or (s25 ~= "" and s25 or "on")
                        local AutoHop = t10.AutoHop

                        if AutoHop and AutoHop.status then
                            pcall(function()
                                AutoHop.status.Text = v4010 .. " · " .. tostring(n56) .. (n56 ~= 1 and " hops this session" or " hop this session")
                            end)
                        end

                        return
                    end

                    s25 = "idle " .. tostring(math.floor(n62)) .. "/" .. tostring(math.floor(v4009)) .. "s"

                    if v4009 <= n62 then
                        local v4012 = not t9.AutoHop and "off" or (s25 ~= "" and s25 or "on")
                        local AutoHop = t10.AutoHop

                        if AutoHop and AutoHop.status then
                            pcall(function()
                                AutoHop.status.Text = v4012 .. " · " .. tostring(n56) .. (n56 ~= 1 and " hops this session" or " hop this session")
                            end)
                        end

                        v2211("idle")

                        return
                    end
                end
            end

            local v4014 = v2196(t9.HopAfter)

            if v4014 > 0 then
                if v4014 < 1 then
                    v4014 = 1
                end

                if v4014 <= (elapsed25 - elapsed21) / 60 then
                    s25 = "time"

                    local v4015 = not t9.AutoHop and "off" or (s25 ~= "" and s25 or "on")
                    local AutoHop = t10.AutoHop

                    if AutoHop and AutoHop.status then
                        pcall(function()
                            AutoHop.status.Text = v4015 .. " · " .. tostring(n56) .. (n56 ~= 1 and " hops this session" or " hop this session")
                        end)
                    end

                    v2211("time")

                    return
                end
            end

            if v2210() then
                s25 = "eggs · grabbing"
            elseif v4009 > 0 and t9.AutoSteal and t216 and t216.running then
                s25 = "idle " .. tostring(math.floor(n62)) .. "/" .. tostring(math.floor(v4009)) .. "s"
            elseif u2191 then
                s25 = "eggs · staying"
            elseif v4009 > 0 and t9.AutoHop then
                s25 = "idle needs Auto Steal"
            else
                s25 = "on"
            end

            local v4017 = not t9.AutoHop and "off" or (s25 ~= "" and s25 or "on")
            local AutoHop = t10.AutoHop

            if AutoHop and AutoHop.status then
                pcall(function()
                    AutoHop.status.Text = v4017 .. " · " .. tostring(n56) .. (n56 ~= 1 and " hops this session" or " hop this session")
                end)
            end
        end
        task.spawn(function()
            while u1117 do
                task.wait(0.4)
                pcall(v2213)
            end
        end)
        local v2214 = not t9.AutoHop and "off" or (s25 ~= "" and s25 or "on")
        local AutoHop = t10.AutoHop
        if AutoHop and AutoHop.status then
            pcall(function()
                AutoHop.status.Text = v2214 .. " · " .. tostring(n56) .. (n56 ~= 1 and " hops this session" or " hop this session")
            end)
        end

        return {
			now = function()
            local HopNow = t10.HopNow

            if HopNow and HopNow.status then
                HopNow.status.Text = "going…"
            end

            local v4020 = v2211("now")

            if HopNow and HopNow.status then
                HopNow.status.Text = if not v4020 then s25 else "going…"
            end

            return v4020
        end,
			stop = function()
            u2179 = false
            u2178 = false
            pcall(function()
                TeleportService:TeleportCancel()
            end)
        end,
			hops = function()
            return n56
        end
		}
    end)()
    u1135 = (function()
        local t291 = {
			placed = 0,
			hatched = 0,
			bought = 0,
			sold = 0,
			soldPets = 0,
			soldEggs = 0,
			trainEarned = 0,
			trainRate = 0,
			claimCash = 0,
			claimIndex = 0,
			training = false,
			conn = nil,
			busy = false,
			lastPlace = 0,
			lastHatch = 0,
			lastEquip = 0,
			lastSell = 0,
			lastWear = 0,
			lastUpg = 0,
			lastClaim = 0,
			lastPaint = 0,
			lastTrain = 0,
			lastPower = nil,
			lastPowerAt = 0,
			job = "idle",
			info = nil,
			infoAt = 0,
			lastPlaceWhy = nil,
			previewQueued = false
		}
        local function v2217(p401)
            local v4022 = tonumber(p401) or 0
            local v4023 = math.abs(v4022)

            if v4023 >= 1000000000000 then
                return string.format("%.2fT", v4022 / 1000000000000)
            end

            if v4023 >= 1000000000 then
                return string.format("%.2fB", v4022 / 1000000000)
            end

            if v4023 >= 1000000 then
                return string.format("%.2fm", v4022 / 1000000)
            end

            if v4023 >= 1000 then
                return string.format("%.1fk", v4022 / 1000)
            end

            return string.format("%.0f", v4022)
        end
        local function v2218(p402, p403)
            local v4029 = v1168({ "Remotes" })
            local v4030 = v4029 and (v4029[p402] and v4029[p402][p403])

            return v1170(v4030) or typeof(v4030) == "Instance" and v4030
        end
        local function v2219(p404, p405, ...)
            local v4033 = v2218(p404, p405)

            if not v4033 then
                return false, "no remote"
            end

            return v4033:InvokeServer(...)
        end
        local function v2220(p406, p407, ...)
            local v4036 = select("#", ...)
            local v4037, v4038, v4039 = ...
            local v4040 = v1168({ "Remotes" })
            local v4041 = v4040 and (v4040[p406] and v4040[p406][p407])

            if v4041 == nil then
                return false
            end

            local function v4042(p408)
                if v4036 <= 0 then
                    p408:FireServer()

                    return
                end

                if v4036 == 1 then
                    p408:FireServer(v4037)

                    return
                end

                if v4036 == 2 then
                    p408:FireServer(v4037, v4038)

                    return
                end

                p408:FireServer(v4037, v4038, v4039)
            end

            if pcall(v4042, v4041) then
                return true
            end

            local v4043 = v1170(v4041) or typeof(v4041) == "Instance" and v4041

            return v4043 ~= nil and pcall(v4042, v4043)
        end
        local function v2221()
            local Save = ReplicatedStorage.Shared.Save
            local v4049

            if t291.saveMod == false then
                v4049 = nil
            elseif t291.saveMod ~= nil then
                v4049 = t291.saveMod
            else
                local ok64, result64 = pcall(require, Save)

                t291.saveMod = not not ok64 and (type(result64) == "table" and (result64 or false))
                v4049 = if t291.saveMod ~= false then t291.saveMod else nil
            end

            if type(v4049) == "table" and type(v4049.Get) == "function" then
                local ok65, result65 = pcall(v4049.Get, LocalPlayer, false)

                if ok65 and type(result65) == "table" then
                    return result65
                end

                local ok66, result66 = pcall(v4049.Get)

                if ok66 and type(result66) == "table" then
                    return result66
                end
            end
        end
        local function v2222(p409)
            local v4061 = string.lower((tostring(p409 or "")))

            if v4061 == "" or v4061 == "?" then
                return 0
            end

            for i, v in ipairs(t6) do
                if v4061 == string.lower(v) then
                    return i
                end
            end

            return 0
        end
        local function v2223()
            local elapsed26 = os.clock()
            if t291.info and elapsed26 - (t291.infoAt or 0) < 0.45 then
                return t291.info
            end
            local PlotState = ReplicatedStorage.Client.PlotState
            local v4072
            if t291.plotMod == false then
                v4072 = nil
            elseif t291.plotMod ~= nil then
                v4072 = t291.plotMod
            else
                local ok67, result67 = pcall(require, PlotState)

                t291.plotMod = not not ok67 and (type(result67) == "table" and (result67 or false))
                v4072 = if t291.plotMod ~= false then t291.plotMod else nil
            end
            local v4075 = v4072
            local u4076
            if v4075 and type(v4075.ResolvePlot) == "function" then
                pcall(function()
                    u4076 = v4075.ResolvePlot()
                end)
            end
            t291.info = type(u4076) == "table" and u4076 or nil
            t291.infoAt = elapsed26

            return t291.info
        end
        local function v2224(p410, p411, p412)
            if not p410 or (not p410:IsA("BasePart") or typeof(p411) ~= "Vector3") then
                return false
            end

            local v4080 = p410.CFrame:PointToObjectSpace(p411)
            local v4081 = p410.Size.X * 0.5 - (p412 or 0)
            local v4082 = p410.Size.Z * 0.5 - (p412 or 0)

            return math.abs(v4080.X) <= math.max(v4081, 0.5) and math.abs(v4080.Z) <= math.max(v4082, 0.5)
        end
        local function v2225()
            local elapsed27 = os.clock()
            if t291.beltPart and (t291.beltPart.Parent and elapsed27 - (t291.beltAt or 0) < 0.85) then
                return t291.beltPart
            end
            local TreadmillBottom
            local v4085 = v2223()
            local v4086 = v4085 and v4085.PlotFolder
            if v4086 then
                TreadmillBottom = v4086:FindFirstChild("TreadmillBottom", true)

                if not (TreadmillBottom and TreadmillBottom:IsA("BasePart"))then
                    TreadmillBottom = nil
                    local v4087
                    for _, descendant in ipairs(v4086:GetDescendants()) do
                        if descendant:IsA("BasePart") then
                            local v4090 = string.lower(descendant.Name)

                            if v4090:find("treadmill", 1, true) or v4090 == "bottom" or v4090:find("belt", 1, true) then
                                local v4091 = descendant.Size.X * descendant.Size.Y * descendant.Size.Z

                                if not v4087 or v4087 < v4091 then
                                    TreadmillBottom = descendant
                                    v4087 = v4091
                                end
                            end
                        end
                    end
                end
            end
            if not TreadmillBottom then
                local __ClientTreadmillRenders = workspace:FindFirstChild("__ClientTreadmillRenders")

                if __ClientTreadmillRenders then
                    local v4093 = __ClientTreadmillRenders:FindFirstChild("TreadmillBottom", true) or __ClientTreadmillRenders:FindFirstChild("Bottom", true)

                    if v4093 and v4093:IsA("BasePart") then
                        TreadmillBottom = v4093
                    end
                end
            end
            t291.beltPart = TreadmillBottom
            t291.beltAt = elapsed27

            return TreadmillBottom
        end
        local function v2226()
            local v4094 = v2223()
            local v4095 = v4094 and v4094.PetArea
            local v4096 = v2225()

            if v4095 and v4095:IsA("BasePart") then
                local Position5 = v4095.Position

                if v4096 then
                    local vector3 = Vector3.new(Position5.X - v4096.Position.X, 0, Position5.Z - v4096.Position.Z)

                    if vector3.Magnitude > 1 then
                        Position5 += vector3.Unit * math.min(12, vector3.Magnitude * 0.15)
                    end
                end

                return Vector3.new(Position5.X, v4095.Position.Y + 4.5, Position5.Z), v4095
            end

            return select(1, v1217()), nil
        end
        local function v2227(p413, p414, p415)
            if typeof(p413) ~= "Vector3" or typeof(p414) ~= "Vector3" then
                return p413
            end

            if p415 then
                return p413
            end

            if Vector3.new(p413.X - p414.X, 0, p413.Z - p414.Z).Magnitude > 14 then
                return Vector3.new(p413.X, p413.Y + 18, p413.Z)
            end

            return p413
        end
        local function v2228(p416)
            local v4104 = v2225()

            if not v4104 or not p416 then
                return false
            end

            local p416Position = p416.Position

            if v2224(v4104, p416Position, -2) then
                return true
            end

            return Vector3.new(p416Position.X - v4104.Position.X, 0, p416Position.Z - v4104.Position.Z).Magnitude < 6
        end
        local function v2229()
            local v4112 = v2223()
            local v4113 = v4112 and v4112.PetArea
            local v4114 = v4112 and v4112.CenterPoint
            local v4115 = v2225()
            if not v4113 or (not v4113:IsA("BasePart") or not v4114) then
                local _, v4117 = v1217()

                if v4117 and v4114 then
                    return v4114.CFrame:ToObjectSpace(v4117)
                end

                return v4117
            end
            local v4118
            for _ = 1, 8 do
                local v4120 = (math.random() - 0.5) * math.min(v4113.Size.X - 8, 28)
                local v4121 = (math.random() - 0.5) * math.min(v4113.Size.Z - 8, 22)

                v4118 = v4113.CFrame * CFrame.new(v4120, 0.5, v4121)

                if not v4115 or not (Vector3.new(v4118.X - v4115.Position.X, 0, v4118.Z - v4115.Position.Z).Magnitude < 14) then
                    return v4114.CFrame:ToObjectSpace(v4118)
                end
            end

            return v4114.CFrame:ToObjectSpace(v4118)
        end
        local function v2230()
            local g4124
            local ok68
            local v4123
            if not u1103 then
                v4123 = nil
                g4124 = true
            end
            repeat
                if g4124 or (g4124 or type(u1103.ReadOwnerEggs) == "function") then
                    if not g4124 then
                        if not g4124 then
                            ok68, v4123 = pcall(u1103.ReadOwnerEggs, LocalPlayer.UserId)
                        end
                    end

                    if g4124 or (g4124 or ok68 and type(v4123) == "table") then

                        if type(v4123) ~= "table" then
                            return {}
                        end
                        local v4126 = v1194(t9.PlaceMinGen)
                        local t292 = {}
                        local n63 = 0
                        for k, v in pairs(v4123) do
                            if type(v) == "table" then
                                if v.Placement ~= nil then
                                    n63 += 1
                                else
                                    local AssetCategory = v.AssetCategory
                                    local v4132 = if not not Directory and AssetCategory then Directory[AssetCategory] else nil
                                    local v4133 = v1193(v, v4132)

                                    if v4126 <= 0 or v4126 <= v4133 then
                                        local NeverPlaceRarity = t9.NeverPlaceRarity
                                        local v4135

                                        if type(NeverPlaceRarity) ~= "string" or NeverPlaceRarity == "place everything" then
                                            v4135 = false
                                        else
                                            local v4136 = v2222(if type(v4132) == "table" and type(v4132.Rarity) == "table" then tostring(v4132.Rarity.DisplayName or (v4132.Rarity.Name or (v4132.Rarity._id or "?"))) else "?")
                                            local v4137 = v2222(NeverPlaceRarity)

                                            v4135 = v4136 > 0 and (v4137 > 0 and v4137 <= v4136)
                                        end

                                        if not v4135 then
                                            t292[#t292 + 1] = {
												uid = v.Uid or k,
												earn = v4133
											}
                                        end
                                    end
                                end
                            end
                        end
                        table.sort(t292, function(p417, p418)
                            return p417.earn > p418.earn
                        end)

                        return t292, n63
                    end
                end

                v4123 = nil
                g4124 = true
            until not g4124
        end
        local function v2231()
            local v4138 = v2221()
            local Bases = ReplicatedStorage.Data.Bases
            local v4140

            if t291.basesMod == false then
                v4140 = nil
            elseif t291.basesMod ~= nil then
                v4140 = t291.basesMod
            else
                local ok69, result68 = pcall(require, Bases)

                t291.basesMod = not not ok69 and (type(result68) == "table" and (result68 or false))
                v4140 = if t291.basesMod ~= false then t291.basesMod else nil
            end

            local v4143 = tonumber(v4138 and v4138.BaseUpgradeLevel) or 0
            local v4144 = v4140 and (v4140.BASES and (v4140.BASES[v4143] or v4140.BASES[v4143 + 1]))

            return tonumber(v4144 and v4144.MaxAssets) or 99
        end
        local function v2232()
            if t9.AutoHatch ~= true or (not u1103 or type(u1103.IsReadyToHatch) ~= "function") then
                return false
            end
            local g4146
            local ok70
            local v4145
            if not u1103 then
                v4145 = nil
                g4146 = true
            end
            repeat
                if g4146 or (g4146 or type(u1103.ReadOwnerEggs) == "function") then
                    if not g4146 then
                        if not g4146 then
                            ok70, v4145 = pcall(u1103.ReadOwnerEggs, LocalPlayer.UserId)
                        end
                    end

                    if g4146 or (g4146 or ok70 and type(v4145) == "table") then
                        g4146 = false

                        if type(v4145) ~= "table" then
                            return false
                        end

                        for k, v in pairs(v4145) do
                            if type(v) ~= "table" or v.Placement == nil then
                                continue
                            end

                            local ok71, result69 = pcall(u1103.IsReadyToHatch, v.Uid or k)

                            if ok71 and result69 == true then
                                return true
                            end
                        end

                        return false
                    end
                end

                v4145 = nil
                g4146 = true
            until not g4146
        end
        local function v2233(p419, p420)
            local Character6 = LocalPlayer.Character
            local v4157

            if not Character6 then
                v4157 = nil
            else
                local Humanoid = Character6:FindFirstChildOfClass("Humanoid")
                local HumanoidRootPart = Character6:FindFirstChild("HumanoidRootPart")

                v4157 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
            end

            if not v4157 or typeof(p419) ~= "Vector3" then
                return false
            end

            u1127 = v2227(p419, v4157.Position, p420)
            u1128 = true

            return Vector3.new(p419.X - v4157.Position.X, 0, p419.Z - v4157.Position.Z).Magnitude < 10 and math.abs(p419.Y - v4157.Position.Y) < 10
        end
        local function v2234(p421)
            local Character7 = LocalPlayer.Character
            local v4162, v4163

            if not Character7 then
                v4162 = nil
                v4163 = nil
            else
                v4162 = Character7:FindFirstChildOfClass("Humanoid")
                v4163 = Character7:FindFirstChild("HumanoidRootPart")

                if not v4162 or not v4163 or v4162.Health <= 0 then
                    v4162 = nil
                    v4163 = nil
                end
            end

            local v4164 = v4162
            local v4165 = v4163

            if not v4164 or not v4165 then
                return
            end

            if not p421 then
                u1128 = false
                u1127 = nil
            end

            v1146(v4164, v4165, false)

            local v4166 = p421 and (typeof(u1127) == "Vector3" and u1127) or v2226()
            local v4167 = v2225()
            local zero = Vector3.zero

            if v4166 then
                zero = Vector3.new(v4166.X - v4165.Position.X, 0, v4166.Z - v4165.Position.Z)
            end

            if zero.Magnitude < 0.5 and v4167 then
                zero = Vector3.new(v4165.Position.X - v4167.Position.X, 0, v4165.Position.Z - v4167.Position.Z)
            end

            local u4169 = if not (zero.Magnitude > 0.5) then Vector3.zero else zero.Unit

            pcall(function()
                v4164.PlatformStand = false
                v4164.Sit = false
                v4164.AutoRotate = true

                if type(v4164.JumpHeight) == "number" and v4164.JumpHeight < 0.5 then
                    v4164.JumpHeight = n15
                end

                if type(v4164.JumpPower) == "number" then
                    v4164.JumpPower = math.max(v4164.JumpPower, 50)
                end

                v4164:ChangeState(Enum.HumanoidStateType.Jumping)
                v4164.Jump = true

                if u4169.Magnitude > 0.5 then
                    v4164:Move(u4169, false)
                end
            end)
            pcall(function()
                v4165.Anchored = false
                v4165.AssemblyLinearVelocity = Vector3.new(u4169.X * 46, 78, u4169.Z * 46)
            end)
        end
        local function v2235()
            t291.training = false

            local Character8 = LocalPlayer.Character
            local v4179

            if not Character8 then
                v4179 = nil
            else
                local Humanoid = Character8:FindFirstChildOfClass("Humanoid")
                local HumanoidRootPart = Character8:FindFirstChild("HumanoidRootPart")

                v4179 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
            end

            local v4182

            if not t216 or not t216.running then
                v4182 = false
            else
                local state = t216.state

                v4182 = state == "GoEgg" or (state == "Grab" or (state == "Return" or (state == "Bank" or (state == "Chase" or (state == "Safe" or (state == "FeedGo" or (state == "Feed" or (state == "ChestGo" or state == "ChestOpen"))))))))
            end

            if v4179 and v2228(v4179) then
                t291.job = "leave"
                v2234(v4182)

                return
            end

            if t291.job == "belt" or t291.job == "leave" then
                t291.job = "idle"

                if not v4182 and (not t216 or not t216.running) then
                    u1128 = false
                    u1127 = nil
                end
            end
        end
        local function v2236()
            if t9.AutoPlaceEggs ~= true or (not u1103 or type(u1103.PlantEgg) ~= "function") then
                return
            end

            local v4184

            if not t216 or not t216.running then
                v4184 = false
            else
                local state = t216.state

                v4184 = state == "GoEgg" or (state == "Grab" or (state == "Return" or (state == "Bank" or (state == "Chase" or (state == "Safe" or (state == "FeedGo" or (state == "Feed" or (state == "ChestGo" or state == "ChestOpen"))))))))
            end

            if v4184 then
                return
            end

            local Character9 = LocalPlayer.Character
            local v4187

            if not Character9 then
                v4187 = nil
            else
                local Humanoid = Character9:FindFirstChildOfClass("Humanoid")
                local HumanoidRootPart = Character9:FindFirstChild("HumanoidRootPart")

                v4187 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
            end

            local v4190 = v2223()
            local v4191 = v4190 and v4190.PetArea
            local v4192

            if not v4191 or not v4187 then
                v4192 = false
            else
                local v4193 = v2225()

                v4192 = not (not not v4193 and not not v4187 and (if v2228(v4187) then math.abs(v4187.Position.Y - v4193.Position.Y) < 10 else false)) and v2224(v4191, v4187.Position, 2)
            end

            if not v4192 or u1119 then
                return
            end

            local elapsed28 = os.clock()

            if elapsed28 - t291.lastPlace < 1.15 then
                return
            end

            local v4195, v4196 = v2230()

            if #v4195 == 0 then
                return
            end

            if v4196 >= v2231() then
                t291.lastPlaceWhy = "pen full"

                return
            end

            local v4197 = v2229()

            if not v4197 then
                t291.lastPlaceWhy = "no pad"

                return
            end

            t291.lastPlace = elapsed28

            local uid = v4195[1].uid

            if type(u1103.WearEggTool) == "function" then
                pcall(u1103.WearEggTool, uid)
            end

            local ok72, result70, v4201 = pcall(function()
                return u1103.PlantEgg(uid, v4197)
            end)

            if type(u1103.DoffEggTool) == "function" then
                pcall(u1103.DoffEggTool, uid)
            end

            if ok72 and result70 == true then
                local v4202 = t291

                v4202.placed = v4202.placed + 1
                t291.lastPlaceWhy = nil
                v1102("plot", "placed", uid)

                if u1134 and u1134.bumpPlot then
                    u1134.bumpPlot()
                end

                return
            end

            t291.lastPlaceWhy = tostring(v4201 or result70 or (not ok72 and "err" or "rejected"))
            v1102("plot", "place fail", uid, t291.lastPlaceWhy)
        end
        local function v2237()
            if t9.AutoHatch ~= true or not u1103 then
                return
            end
            local Character10 = LocalPlayer.Character
            local g4213
            local ok73
            local v4212
            local v4204
            if not Character10 then
                v4204 = nil
            else
                local Humanoid = Character10:FindFirstChildOfClass("Humanoid")
                local HumanoidRootPart = Character10:FindFirstChild("HumanoidRootPart")

                v4204 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
            end
            local v4207 = v2223()
            local v4208 = v4207 and v4207.PetArea
            local v4209
            if not v4208 or not v4204 then
                v4209 = false
            else
                local v4210 = v2225()

                v4209 = not (not not v4210 and not not v4204 and (if v2228(v4204) then math.abs(v4204.Position.Y - v4210.Position.Y) < 10 else false)) and v2224(v4208, v4204.Position, 2)
            end
            if not v4209 or u1119 then
                return
            end
            local elapsed29 = os.clock()
            if elapsed29 - t291.lastHatch < 0.9 then
                return
            end
            if not u1103 then
                v4212 = nil
                g4213 = true
            end
            repeat
                if g4213 or (g4213 or type(u1103.ReadOwnerEggs) == "function") then
                    if not g4213 then
                        if not g4213 then
                            ok73, v4212 = pcall(u1103.ReadOwnerEggs, LocalPlayer.UserId)
                        end
                    end

                    if g4213 or (g4213 or ok73 and type(v4212) == "table") then
                        g4213 = false

                        if type(v4212) ~= "table" then
                            return
                        end

                        for k, v in pairs(v4212) do
                            if type(v) ~= "table" or v.Placement == nil then
                                continue
                            end

                            local v4217 = v.Uid or k
                            local v4218 = false

                            if type(u1103.IsReadyToHatch) == "function" then
                                local ok74, result71 = pcall(u1103.IsReadyToHatch, v4217)

                                v4218 = ok74 and result71 == true
                            end

                            if v4218 then
                                t291.lastHatch = elapsed29

                                if pcall(function()
                                    if type(u1103.BeginHatch) == "function" then
                                        u1103.BeginHatch(v4217)
                                    end

                                    if type(u1103.FinishHatch) == "function" then
                                        u1103.FinishHatch(v4217)
                                    end
                                end) then
                                    local v4221 = t291

                                    v4221.hatched = v4221.hatched + 1
                                    v1102("plot", "hatched", v4217)

                                    if u1195 and u1195.hatched then
                                        local v4222 = v.AssetCategory or v.Category
                                        local v4223 = if not not Directory and v4222 then Directory[v4222] else nil
                                        local v4224 = v1193(v, v4223)

                                        pcall(u1195.hatched, {
											name = v4223 and v4223.DisplayName or v.AssetCategory,
											earn = v4224,
											rar = if type(v4223) == "table" and type(v4223.Rarity) == "table" then tostring(v4223.Rarity.DisplayName or (v4223.Rarity.Name or (v4223.Rarity._id or "?"))) else "?",
											cfg = v4223,
											cat = v.AssetCategory or v.Category,
											rec = v
										})
                                    end

                                    if u1134 and u1134.bumpPlot then
                                        u1134.bumpPlot()
                                    end
                                end

                                return
                            end
                        end

                        return
                    end
                end

                v4212 = nil
                g4213 = true
            until not g4213
        end
        local function v2238()
            if t9.UpgTrails ~= true then
                return
            end
            local Trails = ReplicatedStorage.Data.Trails
            local v4227
            if t291.trailsMod == false then
                v4227 = nil
            elseif t291.trailsMod ~= nil then
                v4227 = t291.trailsMod
            else
                local ok75, result72 = pcall(require, Trails)

                t291.trailsMod = not not ok75 and (type(result72) == "table" and (result72 or false))
                v4227 = if t291.trailsMod ~= false then t291.trailsMod else nil
            end
            local v4230 = v4227 and (v4227.Directory or v4227)
            local v4231 = v2221()
            if type(v4230) ~= "table" or type(v4231) ~= "table" then
                return
            end
            local v4232 = type(v4231.TrailInventory) == "table" and v4231.TrailInventory or {}
            local t293 = {}
            for _, v in pairs(v4230) do
                if type(v) == "table" and type(v._id) == "string" then
                    t293[#t293 + 1] = v
                end
            end
            table.sort(t293, function(p422, p423)
                return (tonumber(p422.Price) or 0) < (tonumber(p423.Price) or 0)
            end)
            for i = 1, #t293 do
                local v4237 = t293[i]

                if v4232[v4237._id] ~= true then
                    local v4238 = tonumber(v4237.Price) or 0

                    if v4238 > 0 then
                        local v4239 = tonumber(v4238) or 0
                        local v4240 = v2221()

                        if (tonumber(v4240 and v4240.Money) or 0) - v4239 >= v1194(t9.KeepMoney) then
                            local ok76, result73 = pcall(v2219, "Trailwear", "AskPurchase", v4237._id)

                            if ok76 and result73 == true then
                                local v4243 = t291

                                v4243.bought = v4243.bought + 1
                                v1102("plot", "trail bought", v4237._id)
                                pcall(v2219, "Trailwear", "AskChoose", v4237._id)
                            end
                        end
                    end

                    return
                end
            end
            local v4244
            for i = 1, #t293 do
                local v4246 = t293[i]

                if v4232[v4246._id] == true then
                    v4244 = v4246
                end
            end
            if v4244 and v4231.EquippedTrail ~= v4244._id then
                pcall(v2219, "Trailwear", "AskChoose", v4244._id)
            end
        end
        local function v2239()
            if t9.UpgTreadmill ~= true then
                return
            end
            local Treadmills = ReplicatedStorage.Data.Treadmills
            local v4248
            if t291.tmsMod == false then
                v4248 = nil
            elseif t291.tmsMod ~= nil then
                v4248 = t291.tmsMod
            else
                local ok77, result74 = pcall(require, Treadmills)

                t291.tmsMod = not not ok77 and (type(result74) == "table" and (result74 or false))
                v4248 = if t291.tmsMod ~= false then t291.tmsMod else nil
            end
            local v4251 = v4248
            local v4252 = v2221()
            if type(v4251) ~= "table" or type(v4252) ~= "table" then
                return
            end
            local v4253 = (tonumber(v4252.TreadmillUpgradeLevel) or 0) + 1
            local u4254
            if type(v4251.GetByUpgradeLevel) == "function" then
                pcall(function()
                    u4254 = v4251.GetByUpgradeLevel(v4253)
                end)
            end
            if type(u4254) ~= "table" then
                return
            end
            local v4255 = tonumber(u4254.Price) or 0
            if v4255 > 0 then
                local v4256 = tonumber(v4255) or 0
                local v4257 = v2221()

                if not ((tonumber(v4257 and v4257.Money) or 0) - v4256 >= v1194(t9.KeepMoney)) then
                    return
                end
            end
            local ok78, result75 = pcall(v2219, "Treadmill", "AskTierRaise", u4254._id)
            if ok78 and result75 == true then
                v1102("plot", "treadmill", u4254._id)
            end
        end
        local function v2240()
            if t9.UpgPen ~= true then
                return
            end

            local v4260 = v2221()

            if type(v4260) ~= "table" then
                return
            end

            local Bases = ReplicatedStorage.Data.Bases
            local v4262

            if t291.basesMod == false then
                v4262 = nil
            elseif t291.basesMod ~= nil then
                v4262 = t291.basesMod
            else
                local ok79, result76 = pcall(require, Bases)

                t291.basesMod = not not ok79 and (type(result76) == "table" and (result76 or false))
                v4262 = if t291.basesMod ~= false then t291.basesMod else nil
            end

            local v4265 = (tonumber(v4260.BaseUpgradeLevel) or 0) + 1
            local v4266 = v4262 and (v4262.BASES and v4262.BASES[v4265])
            local v4267 = type(v4266) == "table" and tonumber(v4266.Cost) or 0

            if type(v4266) ~= "table" then
                return
            end

            if v4267 > 0 then
                local v4268 = tonumber(v4267) or 0
                local v4269 = v2221()

                if not ((tonumber(v4269 and v4269.Money) or 0) - v4268 >= v1194(t9.KeepMoney)) then
                    return
                end
            end

            v2220("Homestead", "AskBaseTierRaise")
            v1102("plot", "pen tier", v4265)
        end
        local function v2241(p424)
            local t294 = {}
            local v4273 = p424 and p424.EquippedAssets

            if type(v4273) == "table" then
                for _, v in pairs(v4273) do
                    t294[tostring(v)] = true
                end
            end

            return t294
        end
        local function v2242()
            local v4305 = v1194(t9.SellUnderGen)
            local t295 = {}
            local t296 = {}
            if v4305 <= 0 then
                local v4308 = t291
                local v4309 = t291
                local v4310 = t291

                v4308.sellPets = t295
                v4309.sellEggs = t296
                v4310.sellFloor = v4305

                return t295, t296, v4305
            end
            local v4311 = v2221()
            local v4312 = v2241(v4311)
            local v4313 = v4311 and v4311.Inventory
            local g4322
            local ok80
            local v4321
            if type(v4313) == "table" then
                for k, v in pairs(v4313) do
                    if type(v) == "table" then
                        local str37 = tostring(k)
                        local v4317 = v.IsFavorite == true

                        if not v4312[str37] and not v4317 and v.InFuse ~= true then
                            local v4318 = v.Category or v.AssetCategory
                            local v4319 = if not not Directory and v4318 then Directory[v4318] else nil
                            local v4320 = v1193(v, v4319)

                            if v4320 < v4305 then
                                t295[#t295 + 1] = {
									uid = str37,
									cat = v4318,
									cfg = v4319,
									earn = v4320,
									rec = v,
									price = 0
								}
                            end
                        end
                    end
                end
            end
            if not u1103 then
                v4321 = nil
                g4322 = true
            end
            repeat
                if g4322 or (g4322 or type(u1103.ReadOwnerEggs) == "function") then
                    if not g4322 then
                        if not g4322 then
                            ok80, v4321 = pcall(u1103.ReadOwnerEggs, LocalPlayer.UserId)
                        end
                    end

                    if g4322 or (g4322 or ok80 and type(v4321) == "table") then
                        g4322 = false

                        if type(v4321) ~= "table" then
                            v4321 = v4311 and v4311.EggInventory
                        end

                        if type(v4321) == "table" then
                            for k, v in pairs(v4321) do
                                if type(v) == "table" and v.Placement == nil then
                                    local v4326 = v.AssetCategory or v.Category
                                    local v4327 = if not not Directory and v4326 then Directory[v4326] else nil
                                    local v4328 = v1193(v, v4327)

                                    if v4328 < v4305 then
                                        t296[#t296 + 1] = {
											uid = tostring(v.Uid or k),
											cat = v4326,
											cfg = v4327,
											earn = v4328,
											rec = v,
											price = 0
										}
                                    end
                                end
                            end
                        end

                        local v4329 = t291
                        local v4330 = t291
                        local v4331 = t291

                        v4329.sellPets = t295
                        v4330.sellEggs = t296
                        v4331.sellFloor = v4305

                        return t295, t296, v4305
                    end
                end

                v4321 = nil
                g4322 = true
            until not g4322
        end
        local function v2243()
            local Stands = workspace:FindFirstChild("Stands")
            local v4333 = Stands and Stands:FindFirstChild("Prompts")
            local v4334 = v4333 and (v4333:FindFirstChild("SellHeldAsset") or v4333:FindFirstChild("SellAll"))

            if not v4334 or not v4334:IsA("BasePart") then
                return
            end

            local ProximityPrompt = v4334:FindFirstChildWhichIsA("ProximityPrompt")

            if ProximityPrompt then
                pcall(function()
                    ProximityPrompt.HoldDuration = 0
                    ProximityPrompt.RequiresLineOfSight = false
                    ProximityPrompt.MaxActivationDistance = 14
                    ProximityPrompt.ClickablePrompt = true
                end)
            end

            local vector3 = Vector3.new(v4334.CFrame.LookVector.X, 0, v4334.CFrame.LookVector.Z)

            if vector3.Magnitude < 0.15 then
                vector3 = Vector3.new(v4334.CFrame.RightVector.X, 0, v4334.CFrame.RightVector.Z)
            end

            local v4337 = vector3.Magnitude > 0.15 and vector3.Unit or Vector3.new(1, 0, 0)
            local v4338 = v4334.Position + v4337 * 7
            local v4339 = v4334.Position - v4337 * 7
            local Character11 = LocalPlayer.Character
            local v4341

            if not Character11 then
                v4341 = nil
            else
                local Humanoid = Character11:FindFirstChildOfClass("Humanoid")
                local HumanoidRootPart = Character11:FindFirstChild("HumanoidRootPart")

                v4341 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
            end

            local u4344 = v4338

            if v4341 and Vector3.new(v4341.Position.X - v4338.X, 0, v4341.Position.Z - v4338.Z).Magnitude > Vector3.new(v4341.Position.X - v4339.X, 0, v4341.Position.Z - v4339.Z).Magnitude + 1.5 then
                u4344 = v4339
            end

            local u4345 = v4334.Position.Y + 3.2

            pcall(function()
                local vector3_7 = Vector3.new(u4344.X, v4334.Position.Y + 16, u4344.Z)
                local raycastParams = RaycastParams.new()

                raycastParams.FilterType = Enum.RaycastFilterType.Exclude

                local t297 = {
					LocalPlayer.Character,
					v4334
				}

                if u1119 then
                    t297[#t297 + 1] = u1119
                end

                raycastParams.FilterDescendantsInstances = t297

                local raycastResult = workspace:Raycast(vector3_7, Vector3.new(0, -80, 0), raycastParams)

                if raycastResult then
                    u4345 = raycastResult.Position.Y + 3
                end
            end)

            if v4341 and Vector3.new(v4341.Position.X - u4344.X, 0, v4341.Position.Z - u4344.Z).Magnitude < 6 then
                u4345 = math.min(u4345, v4341.Position.Y)
            end

            return Vector3.new(u4344.X, u4345, u4344.Z), v4334, ProximityPrompt
        end
        local function v2244(p425)
            local v4359

            if not p425 then
                v4359 = nil
            else
                local v4360 = p425:GetAttribute("UID") or p425:GetAttribute("Uid")

                v4359 = if type(v4360) ~= "string" or v4360 == "" then nil else v4360
            end

            local v4361 = p425 and p425:GetAttribute("ItemType")

            if v4361 == "AssetEgg" and v4359 then
                v2219("EggWorld", "AskDoffTool", v4359)

                return
            end

            if v4361 == "Asset" and v4359 then
                v2219("PenRoster", "AskDoff", v4359)

                return
            end

            local v4362 = select(1, v1112())

            if v4362 then
                pcall(function()
                    v4362:UnequipTools()
                end)
            end
        end
        local function v2245(p426)
            local v4364 = p426 and (p426.uid and tostring(p426.uid))

            if not v4364 then
                return false
            end

            local Character12 = LocalPlayer.Character
            local v4366 = Character12 and Character12:FindFirstChildWhichIsA("Tool")
            local v4367

            if not v4366 then
                v4367 = nil
            elseif v4366:GetAttribute("ItemType") == "Gear" then
                v4367 = nil
            elseif not v4366 then
                v4367 = nil
            else
                local v4368 = v4366:GetAttribute("UID") or v4366:GetAttribute("Uid")

                v4367 = if type(v4368) ~= "string" or v4368 == "" then nil else v4368
            end

            if v4367 == v4364 then
                return true
            end

            local elapsed30 = os.clock()

            if elapsed30 - (t291.lastWear or 0) < 0.4 then
                return false
            end

            local v4370 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool")

            if v4370 then
                local v4371

                if not v4370 then
                    v4371 = nil
                else
                    local v4372 = v4370:GetAttribute("UID") or v4370:GetAttribute("Uid")

                    v4371 = if type(v4372) ~= "string" or v4372 == "" then nil else v4372
                end

                if v4371 ~= v4364 then
                    t291.lastWear = elapsed30
                    v2244(v4370)

                    return false
                end
            end

            local str38 = tostring(v4364)

            local function v4374(p427)
                if not p427 then
                    return
                end

                for _, child in ipairs(p427:GetChildren()) do
                    if not child:IsA("Tool") then
                        continue
                    end

                    local v4855

                    if not child then
                        v4855 = nil
                    else
                        local v4856 = child:GetAttribute("UID") or child:GetAttribute("Uid")

                        v4855 = if type(v4856) ~= "string" or v4856 == "" then nil else v4856
                    end

                    if v4855 == str38 then
                        return child
                    end
                end
            end

            local v4375 = v4374(LocalPlayer.Character) or v4374(LocalPlayer:FindFirstChild("Backpack"))
            local v4376 = select(1, v1112())

            if v4375 and v4376 then
                t291.lastWear = elapsed30

                if v4375.Parent ~= LocalPlayer.Character then
                    pcall(function()
                        v4376:EquipTool(v4375)
                    end)
                end

                local v4377 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                local v4378

                if not v4377 then
                    v4378 = nil
                else
                    local v4379 = v4377:GetAttribute("UID") or v4377:GetAttribute("Uid")

                    v4378 = if type(v4379) ~= "string" or v4379 == "" then nil else v4379
                end

                return v4378 == v4364
            end

            t291.lastWear = elapsed30

            if p426.kind == "egg" then
                v2219("EggWorld", "AskWearTool", v4364)
            else
                v2219("PenRoster", "AskWear", v4364)
            end

            return false
        end
        local function v2246(p428)
            v2220("PetSatchel", "SellPet", { p428 })

            local _, v4382, v4383 = v2243()

            if v4383 then
                v1190(v4383)

                return
            end

            if v4382 then
                local ProximityPrompt = v4382:FindFirstChildWhichIsA("ProximityPrompt")

                if ProximityPrompt then
                    v1190(ProximityPrompt)
                end
            end
        end
        local function v2247()
            local v4385, v4386 = v2242()

            if t9.AutoSellPets == true and #v4385 > 0 then
                table.sort(v4385, function(p429, p430)
                    return p429.earn < p430.earn
                end)
                v4385[1].kind = "pet"

                return v4385[1]
            end

            if t9.AutoSellEggs == true and #v4386 > 0 then
                table.sort(v4386, function(p431, p432)
                    return p431.earn < p432.earn
                end)
                v4386[1].kind = "egg"

                return v4386[1]
            end
        end
        local function v2248()
            if not t9.AutoSellPets and not t9.AutoSellEggs then
                return
            end

            if t291.expectSold then
                local Character13 = LocalPlayer.Character
                local v4388 = Character13 and Character13:FindFirstChildWhichIsA("Tool")
                local v4389

                if not v4388 then
                    v4389 = nil
                elseif v4388:GetAttribute("ItemType") == "Gear" then
                    v4389 = nil
                elseif not v4388 then
                    v4389 = nil
                else
                    local v4390 = v4388:GetAttribute("UID") or v4388:GetAttribute("Uid")

                    v4389 = if type(v4390) ~= "string" or v4390 == "" then nil else v4390
                end

                if v4389 ~= t291.expectSold.uid then
                    if t291.expectSold.kind == "egg" then
                        local v4391 = t291

                        v4391.soldEggs = v4391.soldEggs + 1
                    else
                        local v4392 = t291

                        v4392.soldPets = v4392.soldPets + 1
                    end

                    if u1195 and u1195.sold then
                        pcall(u1195.sold, t291.expectSold)
                    end

                    t291.expectSold = nil
                end
            end

            local Character14 = LocalPlayer.Character
            local v4394

            if not Character14 then
                v4394 = nil
            else
                local Humanoid = Character14:FindFirstChildOfClass("Humanoid")
                local HumanoidRootPart = Character14:FindFirstChild("HumanoidRootPart")

                v4394 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
            end

            if v2243() then
                local v4397 = v2243()

                if not v4394 or (typeof(v4397) ~= "Vector3" or not (Vector3.new(v4394.Position.X - v4397.X, 0, v4394.Position.Z - v4397.Z).Magnitude < 5.5)) then
                    return
                end
            end

            local v4398 = v2247()

            if not v4398 then
                return
            end

            if not v2245(v4398) then
                t291.sellWhy = "equipping"

                return
            end

            local elapsed31 = os.clock()

            if elapsed31 - t291.lastSell < 0.55 then
                return
            end

            t291.lastSell = elapsed31
            t291.sellWhy = "selling"
            v2246(v4398.uid)
            t291.expectSold = {
				uid = v4398.uid,
				kind = v4398.kind,
				name = v4398.cfg and v4398.cfg.DisplayName or v4398.cat,
				earn = v4398.earn,
				cfg = v4398.cfg,
				cat = v4398.cat
			}
            v1102("plot", "sell held", v4398.kind, v4398.uid)
        end
        local function v2249()
            if t9.ClaimIndex ~= true then
                return
            end

            if t291.claimBusy or t291.job == "sell" then
                return
            end

            local elapsed32 = os.clock()

            if elapsed32 - (t291.lastClaim or 0) < 8 then
                return
            end

            t291.lastClaim = elapsed32
            t291.claimBusy = true

            local v4401 = v2218("Codex", "AskRedeemAll")

            if not v4401 then
                t291.claimWhy = "no remote"
                t291.claimBusy = false

                return
            end

            local ok81, result77, v4404, v4405 = pcall(function()
                return v4401:InvokeServer()
            end)

            if not ok81 then
                t291.claimWhy = tostring(result77)
            elseif result77 == true then
                local n64 = 0

                if type(v4405) == "table" then
                    for _ in ipairs(v4405) do
                        n64 += 1
                    end

                    if n64 == 0 then
                        for _ in pairs(v4405) do
                            n64 += 1
                        end
                    end
                end

                if n64 > 0 then
                    local v4409 = t291

                    v4409.claimIndex = v4409.claimIndex + n64
                    t291.claimWhy = "claimed " .. n64

                    if u1195 and u1195.rewards then
                        pcall(u1195.rewards, n64)
                    end
                else
                    t291.claimWhy = "nothing to claim"
                end
            else
                t291.claimWhy = tostring(v4404 or "nothing to claim")
            end

            t291.claimBusy = false
        end
        local function v2250()
            if t9.AutoTreadmill ~= true then
                v2235()

                return
            end
            if t216 and t216.running and t216.allowTrain and not t216.allowTrain() then
                return
            end
            local g4410
            local g4411
            local v4412
            local v4413
            local v4414
            local g4433
            local v4432
            repeat
                if g4410 or ((tonumber(t9.ReadyEarly) or 4) >= v1228() or t9.AutoSteal == true and (t216 and (t216.running and (not t216.allowTrain or t216.allowTrain() ~= true)))) then
                    g4410 = false

                    if t291.training or t291.job == "belt" then
                        v2235()
                    end

                    return
                end

                repeat
                    if g4411 or t9.AutoPlaceEggs == true then
                        if not g4411 then
                            v4412, v4413 = v2230()
                        end

                        if g4411 or #v4412 > 0 and v4413 < v2231() then
                            if not g4411 then
                                v4414 = true
                            end

                            g4411 = false

                            if v4414 then
                                g4410 = true
                            end

                            if not g4410 then
                                local elapsed33 = os.clock()
                                local v4416 = v2221()
                                local v4417 = tonumber(v4416 and v4416.SpeedPower) or 0

                                if t291.lastPower and elapsed33 > t291.lastPowerAt then
                                    local v4418 = elapsed33 - t291.lastPowerAt

                                    if v4418 > 0.2 then
                                        local v4419 = math.max(0, v4417 - t291.lastPower)
                                        local v4420 = t291

                                        v4420.trainEarned = v4420.trainEarned + v4419
                                        t291.trainRate = v4419 / v4418
                                    end
                                end

                                t291.lastPower = v4417
                                t291.lastPowerAt = elapsed33

                                local v4421 = v2225()
                                local v4422 = if v4421 then v4421.Position + Vector3.new(0, v4421.Size.Y * 0.5 + 3.2, 0) else nil
                                local Character15 = LocalPlayer.Character
                                local v4424

                                if not Character15 then
                                    v4424 = nil
                                else
                                    local Humanoid = Character15:FindFirstChildOfClass("Humanoid")
                                    local HumanoidRootPart = Character15:FindFirstChild("HumanoidRootPart")

                                    v4424 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
                                end

                                if not v4422 or not v4424 then
                                    return
                                end

                                t291.job = "belt"

                                local v4427 = v2225()

                                if not v4427 or not v4424 or not if v2228(v4424) then math.abs(v4424.Position.Y - v4427.Position.Y) < 10 else false then
                                    t291.training = false
                                    v2233(v4422)

                                    return
                                end

                                u1128 = false
                                u1127 = nil

                                if u1119 or elapsed33 - t291.lastTrain < 1.2 then
                                    return
                                end

                                t291.lastTrain = elapsed33

                                local ok82, result78, v4430 = pcall(function()
                                    return v2219("Treadmill", "AskWearStill")
                                end)
                                local v4431 = t291

                                if ok82 then
                                    v4432 = true

                                    if result78 == true then
                                        g4433 = true
                                    end
                                end

                                if not g4433 then
                                    local v4434 = v2225()

                                    v4432 = not not v4434 and not not v4424 and if v2228(v4424) then math.abs(v4424.Position.Y - v4434.Position.Y) < 10 else false
                                end

                                g4433 = false
                                v4431.training = v4432

                                if not ok82 or result78 ~= true then
                                    v1102("plot", "wear fail", (tostring(v4430 or result78)))
                                end

                                return
                            end
                        end
                    end

                    if g4410 then
                        break
                    end

                    v4414 = v2232()
                    g4411 = true
                until not g4411
            until not g4410
        end
        local function v2251()
            local elapsed34 = os.clock()
            if elapsed34 - t291.lastPaint < 0.45 then
                return
            end
            t291.lastPaint = elapsed34
            local s28 = "idle"
            local g4447
            if t9.AutoPlaceEggs then
                s28 = if t291.job ~= "pad" then not t291.lastPlaceWhy and "running" or tostring(t291.lastPlaceWhy) else "flying to plot"
            end
            local v4437 = s28 .. " · placed " .. t291.placed .. " · hatched " .. t291.hatched
            local AutoPlaceEggs = t10.AutoPlaceEggs
            if AutoPlaceEggs and AutoPlaceEggs.status then
                pcall(function()
                    AutoPlaceEggs.status.Text = v4437
                end)
            end
            local v4439 = (not t9.UpgTrails and "idle" or "running") .. " · bought " .. t291.bought
            local UpgTrails = t10.UpgTrails
            if UpgTrails and UpgTrails.status then
                pcall(function()
                    UpgTrails.status.Text = v4439
                end)
            end
            local v4441, v4442, v4443 = v2242()
            local v4444 = #v4441
            local v4445 = #v4442
            local s29 = "off"
            if t9.AutoSellPets or t9.AutoSellEggs then
                if v4443 <= 0 then
                    s29 = "set a $/s floor"
                    g4447 = true
                end

                if not g4447 then
                    if t291.job ~= "sell" then
                        s29 = v4444 + v4445 ~= 0 and "selling" or "nothing under the floor"
                        g4447 = true
                    end

                    if not g4447 then
                        local Character16 = LocalPlayer.Character
                        local v4449

                        if not Character16 then
                            v4449 = nil
                        else
                            local Humanoid = Character16:FindFirstChildOfClass("Humanoid")
                            local HumanoidRootPart = Character16:FindFirstChild("HumanoidRootPart")

                            v4449 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
                        end

                        if v4449 then
                            local v4452 = v2243()

                            if v4449 and (typeof(v4452) == "Vector3" and Vector3.new(v4449.Position.X - v4452.X, 0, v4449.Position.Z - v4452.Z).Magnitude < 5.5) then
                                s29 = t291.sellWhy or "equipping"
                                g4447 = true
                            end
                        end

                        if not g4447 then
                            s29 = "flying to seller"
                            g4447 = true
                        end
                    end
                end
            end
            g4447 = false
            local v4453 = s29 .. " · sold " .. t291.soldPets .. " · " .. v4444 .. " waiting"
            local AutoSellPets = t10.AutoSellPets
            if AutoSellPets and AutoSellPets.status then
                pcall(function()
                    AutoSellPets.status.Text = v4453
                end)
            end
            local v4455 = s29 .. " · sold " .. t291.soldEggs .. " · " .. v4445 .. " waiting"
            local AutoSellEggs = t10.AutoSellEggs
            if AutoSellEggs and AutoSellEggs.status then
                pcall(function()
                    AutoSellEggs.status.Text = v4455
                end)
            end
            local v4457 = (not t9.ClaimIndex and "off" or (t291.claimWhy or "running")) .. " · claimed " .. t291.claimIndex
            local ClaimIndex = t10.ClaimIndex
            if ClaimIndex and ClaimIndex.status then
                pcall(function()
                    ClaimIndex.status.Text = v4457
                end)
            end
            if t291.job == "leave" then
                local v4459 = "leaving · " .. v2217(t291.trainRate) .. "/s · earned " .. v2217(t291.trainEarned) .. " this session"
                local AutoTreadmill = t10.AutoTreadmill

                if AutoTreadmill and AutoTreadmill.status then
                    pcall(function()
                        AutoTreadmill.status.Text = v4459
                    end)

                    return
                end
            elseif t291.job == "belt" and not t291.training then
                local v4461 = "flying to treadmill · " .. v2217(t291.trainRate) .. "/s · earned " .. v2217(t291.trainEarned) .. " this session"
                local AutoTreadmill = t10.AutoTreadmill

                if AutoTreadmill and AutoTreadmill.status then
                    pcall(function()
                        AutoTreadmill.status.Text = v4461
                    end)

                    return
                end
            elseif t291.training then
                local v4463 = "training · " .. v2217(t291.trainRate) .. "/s · earned " .. v2217(t291.trainEarned) .. " this session"
                local AutoTreadmill = t10.AutoTreadmill

                if AutoTreadmill and AutoTreadmill.status then
                    pcall(function()
                        AutoTreadmill.status.Text = v4463
                    end)

                    return
                end
            else
                local v4465 = "not training · " .. v2217(t291.trainRate) .. "/s · earned " .. v2217(t291.trainEarned) .. " this session"
                local AutoTreadmill = t10.AutoTreadmill

                if AutoTreadmill and AutoTreadmill.status then
                    pcall(function()
                        AutoTreadmill.status.Text = v4465
                    end)
                end
            end
        end
        local function v2252()
            local Character17 = LocalPlayer.Character
            local g4483
            local v4484
            local v4485
            local v4486
            local v4468
            if not Character17 then
                v4468 = nil
            else
                local Humanoid = Character17:FindFirstChildOfClass("Humanoid")
                local HumanoidRootPart = Character17:FindFirstChild("HumanoidRootPart")

                v4468 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
            end
            if t216 and type(t216.haltUntil) == "number" and os.clock() < t216.haltUntil and not t216.running then
                t291.job = "idle"
                t291.training = false
                u1128 = false
                u1127 = nil

                return
            end
            if t291.job == "leave" then
                t291.training = false

                if v4468 and v2228(v4468) then
                    local v4471 = v2234
                    local v4472

                    if not t216 or not t216.running then
                        v4472 = false
                    else
                        local state = t216.state

                        v4472 = state == "GoEgg" or (state == "Grab" or (state == "Return" or (state == "Bank" or (state == "Chase" or (state == "Safe" or (state == "FeedGo" or (state == "Feed" or (state == "ChestGo" or state == "ChestOpen"))))))))
                    end

                    v4471(v4472)

                    return
                end

                t291.job = "idle"

                local v4474

                if not t216 or not t216.running then
                    v4474 = false
                else
                    local state = t216.state

                    v4474 = state == "GoEgg" or (state == "Grab" or (state == "Return" or (state == "Bank" or (state == "Chase" or (state == "Safe" or (state == "FeedGo" or (state == "Feed" or (state == "ChestGo" or state == "ChestOpen"))))))))
                end

                if not v4474 and (not t216 or not t216.running) then
                    u1128 = false
                    u1127 = nil
                end

                v1183((v1184()))

                if not u1116 then
                    return
                end

                if (t9.Flight or t9.BypassSpeed) and true or (t9.AutoSteal or ((t9.AutoPlaceEggs or t9.AutoTreadmill) and true or (t9.AutoHatch or u1128 and t9.StealTravel == "Flight"))) then
                    v1142()
                    v1143()
                    v1150(true)

                    return
                end

                if next(t155) then
                    v1150(false)
                end

                return
            end
            local v4476
            if not t216 or not t216.running then
                v4476 = false
            else
                local state = t216.state

                v4476 = state == "GoEgg" or (state == "Grab" or (state == "Return" or (state == "Bank" or (state == "Chase" or (state == "Safe" or (state == "FeedGo" or (state == "Feed" or (state == "ChestGo" or state == "ChestOpen"))))))))
            end
            if v4476 then
                if t291.job == "sell" then
                    t291.job = "idle"
                end

                if v4468 and v2228(v4468) then
                    t291.job = "leave"
                    v2234(true)
                end

                return
            end
            if (t9.AutoSellPets or t9.AutoSellEggs) and v1194(t9.SellUnderGen) > 0 then
                local v4478, v4479 = v2242()

                if (t9.AutoSellPets and #v4478 or 0) + (t9.AutoSellEggs and #v4479 or 0) > 0 then
                    if v4468 and v2228(v4468) then
                        t291.job = "leave"
                        v2234()

                        return
                    end

                    local v4480 = v2243()

                    if v4468 then
                        local v4481 = v2243()

                        if not v4468 or (typeof(v4481) ~= "Vector3" or not (Vector3.new(v4468.Position.X - v4481.X, 0, v4468.Position.Z - v4481.Z).Magnitude < 5.5)) then
                            t291.job = "sell"

                            if v4480 then
                                v2233(v4480, true)
                            end

                            return
                        end
                    end

                    t291.job = "sell"

                    if u1128 or u1127 then
                        u1128 = false
                        u1127 = nil

                        if not t9.Flight then
                            local v4482 = select(1, v1112())

                            v1146(v4482, v4468, true)
                            u1145 = false
                        end
                    end

                    return
                end

                if t291.job == "sell" then
                    t291.job = "idle"
                    u1128 = false
                    u1127 = nil
                end
            elseif t291.job == "sell" then
                t291.job = "idle"
                u1128 = false
                u1127 = nil
            end
            repeat
                if g4483 or t9.AutoPlaceEggs == true then
                    if not g4483 then
                        v4484, v4485 = v2230()
                    end

                    if g4483 or #v4484 > 0 and v4485 < v2231() then
                        if not g4483 then
                            v4486 = true
                        end
                        if v4486 then
                            if v4468 and v2228(v4468) then
                                t291.job = "leave"
                                v2234()

                                return
                            end

                            t291.job = "pad"

                            local v4487 = v2226()

                            if v4487 then
                                if v4468 then
                                    local v4488 = v2223()
                                    local v4489 = v4488 and v4488.PetArea
                                    local v4490

                                    if not v4489 or not v4468 then
                                        v4490 = false
                                    else
                                        local v4491 = v2225()

                                        v4490 = not (not not v4491 and not not v4468 and (if v2228(v4468) then math.abs(v4468.Position.Y - v4491.Position.Y) < 10 else false)) and v2224(v4489, v4468.Position, 2)
                                    end

                                    if v4490 then
                                        u1128 = false
                                        u1127 = nil

                                        return
                                    end
                                end

                                v2233(v4487)
                            end

                            return
                        end
                        if t216 and t216.running then
                            t291.training = false

                            if t291.job == "belt" then
                                t291.job = "idle"
                            end
                        end
                        if t9.AutoTreadmill == true and (t9.AutoSteal ~= true or (not t216 or (not t216.running or t216.allowTrain and t216.allowTrain() == true))) then
                            v2250()

                            return
                        end
                        if t291.job == "pad" or t291.job == "belt" or t291.job == "sell" then
                            t291.job = "idle"
                        end
                        if not t216 or not t216.running then
                            u1128 = false
                            u1127 = nil
                        end

                        return
                    end
                end

                v4486 = v2232()
                g4483 = true
            until not g4483
        end
        local u2253
        local function v2254(p433, p434)
            local t298 = {}

            for i = 1, #p433 do
                local v4499 = p433[i]
                local str39 = tostring(v4499.cat or "?")
                local v4501 = p434 .. ":" .. str39
                local v4502 = t298[v4501]

                if not v4502 then
                    v4502 = {
						kind = p434,
						cat = str39,
						cfg = v4499.cfg,
						earn = v4499.earn,
						rec = v4499.rec,
						price = 0,
						n = 0
					}
                    t298[v4501] = v4502
                end

                v4502.n = v4502.n + 1
                v4502.price = v4502.price + (tonumber(v4499.price) or 0)

                if (v4499.earn or 0) < (v4502.earn or 0) then
                    v4502.earn = v4499.earn
                end
            end

            local t299 = {}

            for _, v in pairs(t298) do
                t299[#t299 + 1] = v
            end

            table.sort(t299, function(p435, p436)
                if p435.earn ~= p436.earn then
                    return p435.earn < p436.earn
                end

                return tostring(p435.cat) < tostring(p436.cat)
            end)

            return t299
        end
        local function u2255(p437, p438, p439, p440)
            local v4510 = type(p437) == "table" and p437 or {}
            local v4511 = type(p438) == "table" and p438 or {}
            local v4512 = tonumber(p439) or 0
            local t300 = {}
            local t301 = {}

            if type(p440) == "string" and p440 ~= "" then
            elseif v4512 <= 0 then
                p440 = "set a $/s floor or nothing sells"
            else
                t300 = v2254(v4510, "pet")
                t301 = v2254(v4511, "egg")
                p440 = if #v4510 + #v4511 ~= 0 then #v4510 .. " pets · " .. #v4511 .. " eggs under " .. v2217(v4512) .. "/s" else "nothing under " .. v2217(v4512) .. "/s — plot/pen pets stay"
            end

            local v4515 = p440
            local SellPreview = t10.SellPreview

            if SellPreview and SellPreview.status then
                pcall(function()
                    SellPreview.status.Text = v4515
                end)
            end

            if not u1134 or not u1134.sellPreview then
                local SellPreview2 = t10.SellPreview

                if SellPreview2 and SellPreview2.status then
                    local s30 = "preview missing"

                    pcall(function()
                        SellPreview2.status.Text = s30
                    end)
                end

                v1102("plot", "preview missing espApi.sellPreview")

                return
            end

            local ok83, result79 = pcall(u1134.sellPreview, t300, t301, p440)

            if not ok83 then
                local v4521 = "failed · " .. tostring(result79)
                local SellPreview3 = t10.SellPreview

                if SellPreview3 and SellPreview3.status then
                    pcall(function()
                        SellPreview3.status.Text = v4521
                    end)
                end

                v1102("plot", "preview ERR", (tostring(result79)))

                return
            end

            if result79 ~= true then
                local SellPreview4 = t10.SellPreview

                if SellPreview4 and SellPreview4.status then
                    local s31 = "failed to open"

                    pcall(function()
                        SellPreview4.status.Text = s31
                    end)
                end
            end
        end
        local function u2256()
            local t302 = {}
            local v4526, v4527, v4528

            if pcall(function()
                local v4863 = t302
                local v4864 = t302
                local v4865 = t302
                local v4866, v4867, v4868 = v2242()

                v4863[1] = v4866
                v4864[2] = v4867
                v4865[3] = v4868
            end) then
                v4526 = t302[1]
                v4527 = t302[2]
                v4528 = t302[3]
            else
                v4526 = t291.sellPets or {}
                v4527 = t291.sellEggs or {}
                v4528 = t291.sellFloor or v1194(t9.SellUnderGen)
            end

            u2255(v4526, v4527, v4528)
        end

        return {
			sync = function()
            if not (t9.AutoPlaceEggs or (t9.AutoHatch or (t9.EquipBest or (t9.UpgTrails or (t9.UpgTreadmill or (t9.UpgPen or (t9.AutoSellPets or (t9.AutoSellEggs or (t9.AutoTreadmill or t9.ClaimIndex))))))))) then
                v2235()
            end

            v1183((v1184()))

            if not u1116 then
                return
            end

            if (t9.Flight or t9.BypassSpeed) and true or (not not t9.AutoSteal or ((t9.AutoPlaceEggs or t9.AutoTreadmill) and true or (not not t9.AutoHatch or u1128 and t9.StealTravel == "Flight"))) then
                v1142()
                v1143()
                v1150(true)

                return
            end

            if next(t155) then
                v1150(false)
            end
        end,
			stop = function()
            t291.training = false
            t291.job = "idle"

            if not t216 or not t216.running then
                u1128 = false
                u1127 = nil
            end

            v1183((v1184()))

            if not u1116 then
                return
            end

            if (t9.Flight or t9.BypassSpeed) and true or (t9.AutoSteal or ((t9.AutoPlaceEggs or t9.AutoTreadmill) and true or (t9.AutoHatch or u1128 and t9.StealTravel == "Flight"))) then
                v1142()
                v1143()
                v1150(true)

                return
            end

            if next(t155) then
                v1150(false)
            end
        end,
			tick = function()
            if not u1117 then
                return
            end

            v2252()
            v2236()
            v2237()

            if t9.EquipBest == true then
                local elapsed35 = os.clock()

                if not (elapsed35 - t291.lastEquip < 4) then
                    t291.lastEquip = elapsed35
                    pcall(function()
                        v2219("Haul", "WearBest")
                    end)
                end
            end

            local elapsed36 = os.clock()

            if not (elapsed36 - t291.lastUpg < 4) and (t9.UpgTrails or t9.UpgTreadmill or t9.UpgPen) then
                t291.lastUpg = elapsed36
                v2238()
                v2239()
                v2240()
            end

            v2248()
            v2249()
            v2251()
        end,
			wanted = function()
            return t9.AutoPlaceEggs or (t9.AutoHatch or (t9.EquipBest or (t9.UpgTrails or (t9.UpgTreadmill or (t9.UpgPen or (t9.AutoSellPets or (t9.AutoSellEggs or (t9.AutoTreadmill or t9.ClaimIndex))))))))
        end,
			driving = function()
            return u1128 == true and (t291.job == "pad" or (t291.job == "belt" or t291.job == "sell"))
        end,
			leaving = function()
            return t291.job == "leave"
        end,
			leave = v2235,
			kickBelt = function()
            local Character18 = LocalPlayer.Character
            local v4171

            if not Character18 then
                v4171 = nil
            else
                local Humanoid = Character18:FindFirstChildOfClass("Humanoid")
                local HumanoidRootPart = Character18:FindFirstChild("HumanoidRootPart")

                v4171 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
            end

            if not v4171 or not v2228(v4171) then
                if t291.training or t291.job == "belt" then
                    t291.training = false
                    t291.job = "idle"
                end

                return
            end

            local elapsed37 = os.clock()

            if elapsed37 - (t291.lastKick or 0) < 0.55 then
                return
            end

            t291.lastKick = elapsed37
            t291.training = false
            t291.job = "leave"

            local v4175 = v2234
            local v4176

            if not t216 or not t216.running then
                v4176 = false
            else
                local state = t216.state

                v4176 = state == "GoEgg" or (state == "Grab" or (state == "Return" or (state == "Bank" or (state == "Chase" or (state == "Safe" or (state == "FeedGo" or (state == "Feed" or (state == "ChestGo" or state == "ChestOpen"))))))))
            end

            if not v4176 then
                v4176 = (t216 and t216.running) == true
            end

            v4175(v4176)
        end,
			holding = function()
            return t291.training == true or t291.job == "sell"
        end,
			preview = u2256,
			queuePreview = function()
            local v4530 = type(t291.sellPets) == "table" and t291.sellPets or {}
            local v4531 = type(t291.sellEggs) == "table" and t291.sellEggs or {}
            local num = tonumber(t291.sellFloor)

            if num == nil then
                local v4533 = v1194(t9.SellUnderGen)

                u2255(v4530, v4531, v4533, "opening…")
            else
                u2255(v4530, v4531, num)
            end

            t291.previewQueued = true

            if u2253 then
                return
            end

            local connection19 = RunService.Stepped:Connect(function()
                if not u1117 then
                    return
                end

                if not t291.previewQueued then
                    return
                end

                t291.previewQueued = false

                local v4874 = u2253

                u2253 = nil

                local ok84, result80 = pcall(u2256)

                if not ok84 then
                    local v4877 = "failed · " .. tostring(result80)
                    local SellPreview = t10.SellPreview

                    if SellPreview and SellPreview.status then
                        pcall(function()
                            SellPreview.status.Text = v4877
                        end)
                    end

                    v1102("plot", "preview ERR", (tostring(result80)))
                end

                if v4874 then
                    pcall(function()
                        v4874:Disconnect()
                    end)
                end
            end)

            if connection19 then
                t152[connection19] = true
            end

            u2253 = connection19
        end,
			stats = function()
            return {
					hatched = t291.hatched,
					soldPets = t291.soldPets,
					soldEggs = t291.soldEggs,
					placed = t291.placed,
					claimIndex = t291.claimIndex,
					claimCash = t291.claimCash
				}
        end
		}
    end)()
    local function v1231()
        local AutoSteal = t10.AutoSteal

        if not AutoSteal or not AutoSteal.status then
            return
        end

        local target = t216.target
        local state = t216.state
        local s32 = "idle"

        if state == "Night" then
            s32 = "night · " .. tostring(v1229()) .. "s left"
        elseif state == "Scan" then
            s32 = "looking"

            if type(t216.lookWhy) == "string" and t216.lookWhy ~= "" then
                s32 = "looking · " .. t216.lookWhy
            end
        elseif state == "Safe" then
            s32 = "going to safe zone"
        elseif state == "Return" then
            local routeStage = tonumber(t216.returnRouteStage) or 0
            if routeStage == 0 then
                s32 = "route · hop 1"
            elseif routeStage == 1 then
                s32 = "route · re-grab + hop 2"
            else
                s32 = "route · final run"
            end
        elseif state == "Bank" then
            s32 = "banking"
        elseif state == "Chase" then
            s32 = target and (not not target.name and "chasing · " .. tostring(target.name)) or "chasing"
        elseif state == "GoEgg" or state == "Grab" then
            local v2261 = state ~= "Grab" and "going to" or "grabbing"
            local v2262 = target and (not not target.area and tostring(target.area)) or ""
            local v2263 = target and (not not target.name and tostring(target.name)) or ""

            s32 = if v2262 == "" or v2263 == "" then if v2263 == "" and v2262 == "" then v2261 else v2261 .. " · " .. (v2263 ~= "" and v2263 or v2262) else v2261 .. " · " .. v2262 .. " · " .. v2263
        elseif state == "FeedGo" then
            s32 = t216.lookWhy ~= "need infested" and (t216.lookWhy ~= "equip infested" and t216.lookWhy ~= "pocket infested") and "going to monster" or t216.lookWhy
        elseif state == "Feed" then
            s32 = "feeding monster"
        elseif state == "ChestGo" then
            s32 = "picking up chest"
        elseif state == "ChestOpen" then
            s32 = "opening chest"
        elseif type(state) == "string" and state ~= "" and state ~= "Idle" then
            s32 = string.lower(state)
        end

        pcall(function()
            AutoSteal.status.Text = string.format("%s · took %d · lost %d · re-grabbed %d", s32, t216.banked, t216.lost, t216.regrabs)
        end)

        local AutoEvent = t10.AutoEvent

        if AutoEvent and AutoEvent.status then
            pcall(function()
                local s33 = "off"

                if t9.AutoEvent then
                    s33 = if t216.lookWhy ~= "need infested" and (t216.lookWhy ~= "pocket infested" and t216.lookWhy ~= "equip infested") then if state ~= "FeedGo" then if state ~= "Feed" then if state ~= "ChestGo" then if state ~= "ChestOpen" then (not t216.target or not t216.target.event) and "waiting for filters" or "grabbing infested" else "opening chest" else "picking up chest" else "feeding" else "going to monster" else "waiting for egg"
                end

                AutoEvent.status.Text = s33 .. " · fed " .. tostring(t216.fed or 0) .. " · chests " .. tostring(t216.chests or 0)
            end)
        end
    end
    function t216.keepHook(p441)
        if type(p441) ~= "table" then
            return
        end

        local rec = p441.rec
        local cfg = p441.cfg

        if type(cfg) ~= "table" and rec then
            local v2268 = rec.AssetCategory or rec.Category

            cfg = if not not Directory and v2268 then Directory[v2268] else nil
        end

        local v2269 = p441.cat or rec and (rec.AssetCategory or rec.Category)
        local name = p441.name

        if type(name) ~= "string" or name == "" or name == "egg" or name == "?" then
            name = cfg and cfg.DisplayName or v2269
        end

        local icon = p441.icon

        if type(icon) ~= "string" or icon == "" then
            if u1134 and u1134.liveIcon then
                local ok85, result81 = pcall(u1134.liveIcon, cfg, v2269, name)

                if ok85 and type(result81) == "string" and result81 ~= "" then
                    icon = result81
                end
            end

            if (type(icon) ~= "string" or icon == "") and u1134 and u1134.icon then
                local ok86, result82 = pcall(u1134.icon, cfg, v2269)

                if ok86 and type(result82) == "string" and result82 ~= "" then
                    icon = result82
                end
            end
        end

        local v2276 = t216
        local t303 = {
			rec = rec,
			cfg = cfg,
			cat = v2269,
			name = name,
			area = p441.area or "",
			earn = tonumber(p441.earn) or v1193(rec, cfg)
		}

        t303.rar = if type(cfg) == "table" and type(cfg.Rarity) == "table" then tostring(cfg.Rarity.DisplayName or (cfg.Rarity.Name or (cfg.Rarity._id or "?"))) else "?"
        t303.uid = rec and rec.Uid or p441.uid
        t303.icon = icon
        v2276.hookSnap = t303
    end
    local function v1232(p442)
        local v2279 = t216.heldUid or t216.carryUid

        if not v2279 or v2279 == t216.countedUid then
            return false
        end

        local v2280 = t216.hookSnap or t216.target

        t216.countedUid = v2279

        local v2281 = t216

        v2281.banked = v2281.banked + 1
        t216.lastBankAt = os.clock()
        t216.heldUid = nil
        t216.lockUid = nil
        t216.lockPos = nil
        t216.target = nil
        v1102("steal", "took +1", t216.banked, p442 or "", tostring(v2279):sub(1, 12))
        v1231()

        if u1195 and u1195.stolen then
            pcall(u1195.stolen, v2280)
        end

        t216.hookSnap = nil

        return true
    end
    local function v1233(p443, p444)
        if type(p443) == "table" then
            local sameLocked = t216.lockUid and p443.rec and p443.rec.Uid and t216.lockUid == p443.rec.Uid
            t216.target = p443

            if not sameLocked then
                t216.returnRouteStage = 0
                t216.returnRouteLastHop = 0
                t216.routeDropAt = 0
            end

            if t216.keepHook then
                t216.keepHook(p443)
            end

            if p443.rec and p443.rec.Uid then
                t216.lockUid = p443.rec.Uid
                t216.lockAt = os.clock()
            end

            if typeof(p443.pos) == "Vector3" then
                t216.lockPos = p443.pos
            end
        end

        u1128 = true

        local Character19 = LocalPlayer.Character
        local v2287

        if not Character19 then
            v2287 = nil
        else
            local Humanoid = Character19:FindFirstChildOfClass("Humanoid")
            local HumanoidRootPart = Character19:FindFirstChild("HumanoidRootPart")

            v2287 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
        end

        if v2287 and t216.target and typeof(t216.target.pos) == "Vector3" then
            if v1213(t216.target.rec, t216.target.pos) then
                t216.target = nil
                t216.lockUid = nil

                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "plot egg", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()

                return
            end

            if (v2287.Position - t216.target.pos).Magnitude <= 28 then
                local v2290 = p444 or "egg"

                if t216.state ~= "GoEgg" then
                    v1102("steal", t216.state, "->", "GoEgg", v2290 or "", t216.target and t216.target.name or "")
                    t216.state = "GoEgg"
                    t216.since = os.clock()
                else
                    t216.state = "GoEgg"
                end

                v1231()

                return
            end
        end

        if v2287 and v1227(v2287) then
            local v2291 = p444 or "egg"

            if t216.state ~= "GoEgg" then
                v1102("steal", t216.state, "->", "GoEgg", v2291 or "", t216.target and t216.target.name or "")
                t216.state = "GoEgg"
                t216.since = os.clock()
            else
                t216.state = "GoEgg"
            end

            v1231()

            return
        end

        if v2287 then
            local v2292 = v1221(v2287.Position)

            if v1218(v2287.Position) or v2292 and v1222(v2292, v2287.Position, 18) then
                if t216.state ~= "Safe" then
                    v1102("steal", t216.state, "->", "Safe", "pad first", t216.target and t216.target.name or "")
                    t216.state = "Safe"
                    t216.since = os.clock()
                else
                    t216.state = "Safe"
                end

                v1231()

                return
            end
        end

        local v2293 = p444 or "egg"

        if t216.state ~= "GoEgg" then
            v1102("steal", t216.state, "->", "GoEgg", v2293 or "", t216.target and t216.target.name or "")
            t216.state = "GoEgg"
            t216.since = os.clock()
        else
            t216.state = "GoEgg"
        end

        v1231()
    end
    local function v1234(p445)
        local pendingCarry = t216.pendingCarry

        if not pendingCarry then
            return
        end

        t216.pendingCarry = nil
        n29 = 0
        t216.stillFor = 0

        local carrying = t216.carrying

        t216.carrying = pendingCarry.carrying == true

        if type(pendingCarry.uid) == "string" then
            t216.carryUid = pendingCarry.uid
        elseif not t216.carrying then
            t216.carryUid = nil
        end

        if t216.carrying then
            t216.heldUid = pendingCarry.uid or t216.heldUid
            t216.lockUid = t216.heldUid or t216.lockUid

            if t216.target then
                t216.keepHook(t216.target)
            end

            if t216.state == "Grab" or t216.state == "GoEgg" or t216.state == "Chase" then
                if t216.target and t216.target.event then
                    t216.eventUid = t216.heldUid or t216.carryUid
                    t216.eventFromField = true

                    local eventUid = t216.eventUid

                    if eventUid then
                        t216.wearEventEgg(eventUid)
                    end

                    if eventUid and t216.findEventEggTool(eventUid) then
                        if t216.state ~= "FeedGo" then
                            v1102("steal", t216.state, "->", "FeedGo", "got infested", t216.target and t216.target.name or "")
                            t216.feedDropped = false
                            t216.feedPad = 5
                            t216.state = "FeedGo"
                            t216.since = os.clock()
                        else
                            t216.state = "FeedGo"
                        end

                        v1231()

                        return
                    end

                    t216.lookWhy = "pocket infested"
                    v1231()

                    return
                end

                if t216.state ~= "Return" then
                    v1102("steal", t216.state, "->", "Return", "got egg", t216.target and t216.target.name or "")
                    t216.state = "Return"
                    t216.since = os.clock()
                else
                    t216.state = "Return"
                end

                v1231()
            end

            return
        end

        if not carrying or not t9.AutoSteal then
            return
        end

        local v2298 = v1227(p445)

        if t216.state == "Bank" or t216.state == "Return" and v2298 then
            local endedUid = t216.heldUid or t216.carryUid
            local delivered = t216.confirmDelivery and t216.confirmDelivery(endedUid)

            if delivered == true then
                v1232("carry-ended-at-safe")
            elseif delivered == false then
                -- The game rejected the delivery (the egg returned to its nest).
                -- Keep the target locked and reattempt instead of counting a fake steal.
                t216.carrying = false
                t216.regrabs = (t216.regrabs or 0) + 1
                t216.lastErrAt = os.clock()
                t216.since = os.clock()

                if t216.state ~= "GoEgg" then
                    v1102("steal", t216.state, "->", "GoEgg", "delivery rejected", t216.target and t216.target.name or "")
                    t216.state = "GoEgg"
                end

                v1231()
                u1127 = nil
                u1128 = false
                return
            end

            if t216.state ~= "Scan" then
                v1102("steal", t216.state, "->", "Scan", "took", t216.target and t216.target.name or "")
                t216.state = "Scan"
                t216.since = os.clock()
            else
                t216.state = "Scan"
            end

            v1231()
            u1127 = nil

            return
        end

        if t216.state == "FeedGo" or t216.state == "Feed" then
            if t216.findEventEggTool and t216.findEventEggTool(t216.eventUid or t216.heldUid) then
                return
            end

            local v2299 = t216

            v2299.lost = v2299.lost + 1

            local v2300 = t216

            v2300.regrabs = v2300.regrabs + 1
            t216.lockUid = pendingCarry.uid or (t216.heldUid or t216.lockUid)
            t216.lockAt = os.clock()

            if p445 then
                t216.lockPos = p445.Position
            end

            if t216.state ~= "GoEgg" then
                v1102("steal", t216.state, "->", "GoEgg", "drop at monster", t216.target and t216.target.name or "")
                t216.state = "GoEgg"
                t216.since = os.clock()
            else
                t216.state = "GoEgg"
            end

            v1231()

            return
        end

        if t216.state == "Return" or t216.state == "GoEgg" or t216.state == "Grab" or t216.state == "Chase" then
            local v2301 = t216

            v2301.lost = v2301.lost + 1

            local v2302 = t216

            v2302.regrabs = v2302.regrabs + 1
            t216.lockUid = pendingCarry.uid or (t216.heldUid or t216.lockUid)
            t216.lockAt = os.clock()

            if p445 then
                t216.lockPos = p445.Position
            end

            v1102("steal", "dropped — re-grab", (tostring(t216.lockUid or "?")))

            if t216.state ~= "GoEgg" then
                v1102("steal", t216.state, "->", "GoEgg", "drop", t216.target and t216.target.name or "")
                t216.state = "GoEgg"
                t216.since = os.clock()
            else
                t216.state = "GoEgg"
            end

            v1231()
        end
    end
    local function v1235(p446)
        if not p446 or not p446.rec then
            return nil, "no-target"
        end
        local Uid = p446.rec.Uid
        if not Uid then
            return nil, "no-uid"
        end
        local v2305
        for _, v in ipairs((v1204())) do
            if type(v) == "table" and Uid == v.Uid then
                v2305 = v

                break
            end
        end
        if not v2305 then
            for _, v in ipairs((v1204(true))) do
                if type(v) == "table" and Uid == v.Uid then
                    v2305 = v

                    break
                end
            end
        end
        if not v2305 then
            return nil, "gone"
        end
        if v1213(v2305, (v1209(v2305))) then
            return nil, "plot"
        end
        p446.rec = v2305
        p446.carrier = tonumber(v2305.CarrierUserId)
        local State = v2305.State
        if State == "Slot" or State == "Dropped" then
            local v2311 = v1209(v2305)

            if v2311 then
                p446.pos = v2311
            end

            p446.carrier = nil

            if not p446.pos then
                return nil, "no-pos"
            end

            return p446
        end
        if State == "Carried" then
            p446.pos = v1209(v2305) or p446.pos

            return p446, "Carried"
        end

        return nil, (tostring(State or "bad-state"))
    end
    function t216.promptIsTarget(p447, p448, p449)
        if not p447 or (not p447.Parent or not v1189(p447)) then
            return false
        end
        if not p448 then
            return false
        end
        local v2315 = tonumber(p449) or 5
        local v2316 = p448.rec and (p448.rec.Uid and tostring(p448.rec.Uid))
        if v2316 and v2316 ~= "" then
            local u2317 = p447

            for _ = 1, 6 do
                if not u2317 then
                    break
                end
                local u2319
                pcall(function()
                    for _, v in ipairs({
						"Uid",
						"EggUid",
						"RecordUid",
						"AssetUid",
						"EggId"
					}) do
                        local v22 = u2317:GetAttribute(v)

                        if v22 ~= nil and tostring(v22) == v2316 then
                            u2319 = true

                            return
                        end
                    end

                    local str40 = tostring(u2317.Name or "")

                    if str40 ~= "" and str40 ~= "CarryAreaEgg" and str40 ~= "SmartPromptPart" and str40 == v2316 then
                        u2319 = true
                    end
                end)
                if u2319 then
                    return true
                end
                u2317 = u2317.Parent
            end
        end
        if typeof(p448.pos) ~= "Vector3" then
            return false
        end
        local p447Parent = p447.Parent
        local p447ParentPosition
        if p447Parent:IsA("BasePart") then
            p447ParentPosition = p447Parent.Position
        elseif p447Parent:IsA("Model") then
            local ok87, result83 = pcall(function()
                return p447Parent:GetPivot()
            end)

            p447ParentPosition = ok87 and (not not result83 and result83.Position) or nil
        elseif p447Parent.Parent and p447Parent.Parent:IsA("BasePart") then
            p447ParentPosition = p447Parent.Parent.Position
        end
        if typeof(p447ParentPosition) ~= "Vector3" then
            return false
        end

        return v2315 >= Vector3.new(p447ParentPosition.X - p448.pos.X, 0, p447ParentPosition.Z - p448.pos.Z).Magnitude
    end
    function t216.muteHazards(p450)
        t216.hazardSaved = t216.hazardSaved or {}

        local function v2325(p451)
            if not p451 or not p451:IsA("BasePart") then
                return
            end

            if t216.hazardSaved[p451] == nil then
                t216.hazardSaved[p451] = {
					c = p451.CanCollide,
					t = p451.CanTouch
				}
            end

            if p451.CanCollide ~= false then
                p451.CanCollide = false
            end

            if p451.CanTouch ~= false then
                p451.CanTouch = false
            end
        end

        if p450 then
            local elapsed38 = os.clock()

            if t216.hazardOn and elapsed38 - (t216.hazardAt or 0) < 2.4 then
                return
            end

            t216.hazardOn = true
            t216.hazardAt = elapsed38

            local __OBJECTS = workspace:FindFirstChild("__OBJECTS")
            local v2328 = __OBJECTS and __OBJECTS:FindFirstChild("Machines")
            local v2329 = v2328 and v2328:FindFirstChild("FuseMachine")

            if v2329 then
                v2325(v2329)

                for _, descendant in ipairs(v2329:GetDescendants()) do
                    v2325(descendant)
                end
            end

            if v2328 then
                for _, descendant in ipairs(v2328:GetDescendants()) do
                    if descendant:IsA("BasePart") and descendant.CanCollide == true then
                        v2325(descendant)
                    end
                end
            end

            return
        end

        t216.hazardOn = false
        t216.hazardAt = 0

        for k, _ in pairs(t216.hazardSaved) do
            if k.Parent then
                local v2336 = t216.hazardSaved[k]

                pcall(function()
                    if type(v2336) == "table" then
                        k.CanCollide = v2336.c == true
                        k.CanTouch = v2336.t == true

                        return
                    end

                    k.CanCollide = v2336 == true
                end)
            end
        end

        t216.hazardSaved = {}
    end
    function t216.allowTrain()
        if t9.AutoTreadmill ~= true then
            return false
        end

        if t9.AutoSteal == true and t216.running then
            return false
        end

        if t9.TrainWhenIdle ~= true then
            return false
        end

        return true
    end
    function t216.muteBelt(p452)
        t216.beltSaved = t216.beltSaved or {}

        local function v2338(p453)
            if not p453 or not p453:IsA("BasePart") then
                return false
            end

            local v4542 = string.lower(p453.Name)
            local v4543 = p453.Parent and string.lower(p453.Parent.Name) or ""
            local u4544 = v4542

            pcall(function()
                u4544 = string.lower(p453:GetFullName())
            end)

            if v4542 == "treadmillbottom" or v4542 == "bottom" and (v4543:find("treadmill", 1, true) or u4544:find("treadmill", 1, true)) then
                return true
            end

            if (v4542:find("wear", 1, true) or (v4542:find("sensor", 1, true) or (v4542:find("trigger", 1, true) or (v4542:find("hitbox", 1, true) or (v4542:find("activate", 1, true) or (v4542:find("detector", 1, true) or v4543:find("wear", 1, true))))))) and (u4544:find("treadmill", 1, true) or u4544:find("belt", 1, true) or v4543:find("treadmill", 1, true)) then
                return true
            end

            if p453.CanTouch == true and p453.Size.Y <= 6 and (v4542:find("treadmill", 1, true) or v4543:find("treadmill", 1, true) or u4544:find("clienttreadmill", 1, true)) then
                return true
            end

            return false
        end
        local function v2339(p454)
            local u4546 = t216.beltSaved[p454]

            if type(u4546) ~= "table" then
                u4546 = {
					cf = p454.CFrame,
					anchored = p454.Anchored,
					t = p454.CanTouch,
					c = p454.CanCollide
				}
                t216.beltSaved[p454] = u4546
            end

            pcall(function()
                p454.Anchored = true
                p454.CanTouch = false
                p454.CFrame = u4546.cf * CFrame.new(0, -80, 0)
            end)
        end

        if p452 then
            t216.beltSunk = true

            local elapsed39 = os.clock()

            if not t216.beltOn or elapsed39 - (t216.beltAt or 0) >= 2.4 then
                t216.beltOn = true
                t216.beltAt = elapsed39
                pcall(function()
                    local _, _, v4549 = v1217()

                    if v4549 then
                        for _, descendant in ipairs(v4549:GetDescendants()) do
                            if v2338(descendant) then
                                v2339(descendant)
                            end
                        end
                    end

                    local __ClientTreadmillRenders = workspace:FindFirstChild("__ClientTreadmillRenders")

                    if __ClientTreadmillRenders then
                        for _, descendant in ipairs(__ClientTreadmillRenders:GetDescendants()) do
                            if v2338(descendant) then
                                v2339(descendant)
                            end
                        end
                    end
                end)
            end

            for k in pairs(t216.beltSaved) do
                if k.Parent then
                    v2339(k)
                end
            end

            return
        end

        t216.beltSunk = false
        t216.beltOn = false
        t216.beltAt = 0

        for k, v in pairs(t216.beltSaved) do
            if k.Parent and type(v) == "table" then
                pcall(function()
                    k.CFrame = v.cf
                    k.Anchored = v.anchored == true
                    k.CanTouch = v.t == true
                    k.CanCollide = v.c == true
                end)
            end
        end

        t216.beltSaved = {}
    end
    function t216.floorY()
        local v2344 = select(1, u1219())

        if typeof(v2344) == "Vector3" then
            return v2344.Y
        end

        return 70
    end
    function t216.rescueVoid(p455, p456)
        if not t9.AutoSteal or not t216.running then
            return false
        end

        if not p455 then
            return false
        end

        local v2347 = t216.floorY()

        if p455.Position.Y >= v2347 - 8 then
            return false
        end

        local elapsed40 = os.clock()

        if elapsed40 - (t216.voidAt or 0) < 0.4 then
            return true
        end

        t216.voidAt = elapsed40

        local v2349 = select(1, u1219())

        pcall(function()
            p455.Anchored = false

            if typeof(v2349) == "Vector3" and v2349.Y >= 58 then
                p455.CFrame = CFrame.new(v2349.X, v2349.Y + 6, v2349.Z)
            else
                p455.CFrame = CFrame.new(0, 74, 0)
            end

            p455.AssemblyLinearVelocity = Vector3.zero
            p455.AssemblyAngularVelocity = Vector3.zero

            if p456 then
                p456.Sit = false
                p456.PlatformStand = u1130() == true
            end
        end)
        u1127 = nil
        v1102("steal", "void rescue")

        return true
    end
    function t216.resetStuck(p457, p458)
        local elapsed41 = os.clock()

        if elapsed41 - (t216.unstuckAt or 0) < 2.5 then
            return
        end

        t216.unstuckAt = elapsed41
        t216.stillFor = 0

        local v2353 = select(1, u1219())
        local v2354 = t216.floorY()
        local v2355 = type(v2354) == "number" and v2354 + 3 or p457.Position.Y
        local u2356 = p457.Position.X + 6
        local u2357 = v2355
        local PositionZ = p457.Position.Z
        local v2359 = t216.target and t216.target.pos

        if typeof(v2359) ~= "Vector3" then
            v2359 = t216.lockPos
        end

        if typeof(v2359) == "Vector3" then
            local vector3 = Vector3.new(v2359.X - p457.Position.X, 0, v2359.Z - p457.Position.Z)

            if vector3.Magnitude > 8 then
                local Unit = vector3.Unit

                u2356 = p457.Position.X + Unit.X * 16
                PositionZ = p457.Position.Z + Unit.Z * 16
            end
        end

        if t216.carrying or p457.Position.Y < (type(v2354) == "number" and v2354 - 4 or -1000000000) then
            if typeof(v2353) == "Vector3" then
                u2356 = v2353.X
                u2357 = v2353.Y + 3
                PositionZ = v2353.Z
            else
                u2357 = v2355
            end
        end

        pcall(function()
            p457.Anchored = false
            p457.CFrame = CFrame.new(u2356, u2357, PositionZ)
            p457.AssemblyLinearVelocity = Vector3.zero
            p457.AssemblyAngularVelocity = Vector3.zero

            if p458 then
                p458.Sit = false
                p458.PlatformStand = u1130() == true
            end
        end)
        v1102("steal", "unstuck reset", t216.state or "")
    end
    function t216.liveCarry()
        local v2362 = v1204()

        if type(v2362) ~= "table" then
            return false, nil
        end

        for i = 1, #v2362 do
            local v2364 = v2362[i]

            if type(v2364) == "table" and tonumber(v2364.CarrierUserId) == LocalPlayer.UserId then
                return true, v2364.Uid
            end
        end

        return false, nil
    end

    function t216.fieldHasUid(p460)
        if not p460 then
            return false
        end

        local records = v1204(true)

        if type(records) ~= "table" then
            return false
        end

        for i = 1, #records do
            local rec = records[i]
            if type(rec) == "table" then
                local uid = rec.Uid or rec.uid
                if uid and tostring(uid) == tostring(p460) then
                    return true, rec
                end
            end
        end

        return false
    end

    function t216.confirmDelivery(p461)
        if not p461 or not u1103 then
            return nil
        end

        -- Successful delivery should remove the UID from field eggs.
        -- Allow enough time for the server state to replicate before deciding.
        local deadline = os.clock() + 2.0
        repeat
            local live = t216.liveCarry and select(1, t216.liveCarry())
            local present = t216.fieldHasUid(p461)

            if present == false and not live then
                return true
            end

            task.wait(0.15)
        until os.clock() >= deadline

        return false
    end
    function t216.adoptCarry()
        local v2365, v2366 = t216.liveCarry()

        if v2365 then
            t216.carrying = true

            if v2366 then
                t216.carryUid = v2366
                t216.heldUid = v2366
                t216.lockUid = v2366
            end

            local state = t216.state

            if state == "Return" or state == "Bank" or state == "FeedGo" or state == "Feed" or state == "ChestGo" or state == "ChestOpen" then
                return
            end

            local target = t216.target

            if target and target.event then
                t216.eventUid = t216.heldUid or (t216.carryUid or t216.eventUid)
                t216.eventFromField = true

                local eventUid = t216.eventUid

                if eventUid and t216.findEventEggTool(eventUid) then
                    if t216.state ~= "FeedGo" then
                        v1102("steal", t216.state, "->", "FeedGo", "got infested", t216.target and t216.target.name or "")
                        t216.feedDropped = false
                        t216.feedPad = 5
                        t216.state = "FeedGo"
                        t216.since = os.clock()
                    else
                        t216.state = "FeedGo"
                    end

                    v1231()

                    return
                end

                if t216.state ~= "Return" then
                    v1102("steal", t216.state, "->", "Return", "got egg", t216.target and t216.target.name or "")
                    t216.state = "Return"
                    t216.since = os.clock()
                else
                    t216.state = "Return"
                end

                v1231()

                return
            end

            if t216.state ~= "Return" then
                v1102("steal", t216.state, "->", "Return", "got egg", t216.target and t216.target.name or "")
                t216.state = "Return"
                t216.since = os.clock()
            else
                t216.state = "Return"
            end

            v1231()

            return
        end

        t216.carrying = false

        local state = t216.state

        if state == "Return" or state == "Bank" then
            t216.lockAt = os.clock()

            if t216.lockUid and typeof(t216.lockPos) == "Vector3" then
                if t216.state ~= "GoEgg" then
                    v1102("steal", t216.state, "->", "GoEgg", "empty return", t216.target and t216.target.name or "")
                    t216.state = "GoEgg"
                    t216.since = os.clock()
                else
                    t216.state = "GoEgg"
                end

                v1231()

                return
            end

            if t216.state ~= "Scan" then
                v1102("steal", t216.state, "->", "Scan", "empty return", t216.target and t216.target.name or "")
                t216.state = "Scan"
                t216.since = os.clock()
            else
                t216.state = "Scan"
            end

            v1231()

            return
        end

        if state == "FeedGo" or state == "Feed" then
            local v2371 = t216.eventUid or t216.heldUid

            if t216.findEventEggTool and t216.findEventEggTool(v2371) then
                return
            end

            if t216.lookWhy == "need infested" or t216.lookWhy == "equip infested" or t216.lookWhy == "pocket infested" then
                return
            end

            if t216.lockUid and typeof(t216.lockPos) == "Vector3" then
                if t216.state ~= "GoEgg" then
                    v1102("steal", t216.state, "->", "GoEgg", "empty monster", t216.target and t216.target.name or "")
                    t216.state = "GoEgg"
                    t216.since = os.clock()
                else
                    t216.state = "GoEgg"
                end

                v1231()

                return
            end

            if t216.state ~= "Scan" then
                v1102("steal", t216.state, "->", "Scan", "empty monster", t216.target and t216.target.name or "")
                t216.state = "Scan"
                t216.since = os.clock()
            else
                t216.state = "Scan"
            end

            v1231()
        end
    end
    -- Performs a deliberate in-route drop using the game's own EggState/remote.
    -- The normal anti-drop hook blocks drops while Auto Steal is active; routeDropBusy
    -- is the narrow exception used only for this staged return sequence.
    function t216.routeDrop(reason)
        if not t216.carrying or t216.routeDropBusy then
            return false
        end

        local started = os.clock()
        local waitFor = math.clamp(tonumber(t9.RouteGrabCooldown) or 1.1, 0.5, 2.0)
        t216.routeDropBusy = true
        t216.routeDropAt = started

        local sent = false
        local why = reason or "Manual"

        pcall(function()
            if u1103 and type(u1103.DropFieldEgg) == "function" then
                u1103.DropFieldEgg(why)
                sent = true
            end
        end)

        if not sent then
            pcall(function()
                local rems = v1168({ "Remotes" })
                local eggWorld = rems and rems.EggWorld
                local dropRemote = eggWorld and eggWorld.AskFieldEggDrop
                local instance = v1170(dropRemote) or (typeof(dropRemote) == "Instance" and dropRemote or nil)

                if instance and type(instance.InvokeServer) == "function" then
                    instance:InvokeServer({ Reason = why })
                    sent = true
                elseif type(dropRemote) == "table" and type(dropRemote.InvokeServer) == "function" then
                    dropRemote:InvokeServer({ Reason = why })
                    sent = true
                end
            end)
        end

        -- Give the server a little time to replicate the dropped state.
        if sent then
            local deadline = os.clock() + math.max(0.75, math.min(1.5, waitFor + 0.25))
            repeat
                local live = t216.liveCarry and select(1, t216.liveCarry())
                if not live then
                    t216.carrying = false
                    t216.routeDropBusy = false
                    t216.nextGrabAt = os.clock() + waitFor
                    return true
                end
                task.wait(0.10)
            until os.clock() >= deadline
        end

        t216.routeDropBusy = false
        t216.nextGrabAt = os.clock() + waitFor
        return false
    end

    local function v1236(p459)
        if t216.carrying then
            return
        end

        local elapsed42 = os.clock()
        local grabCooldown = math.clamp(tonumber(t9.RouteGrabCooldown) or 1.1, 0.5, 2.0)

        if elapsed42 < (t216.nextGrabAt or 0) then
            return
        end

        if elapsed42 - t216.lastGrab < 0.03 then
            return
        end

        t216.lastGrab = elapsed42
        t216.nextGrabAt = elapsed42 + grabCooldown

        local v2374 = p459 and p459.rec
        local v2375 = v2374 and v2374.Uid

        if v2375 then
            t216.heldUid = v2375
            t216.lockUid = v2375
            t216.lockAt = os.clock()

            if p459 then
                t216.keepHook(p459)
            end

            if typeof(p459.pos) == "Vector3" then
                t216.lockPos = p459.pos
            end

            if u1103 and type(u1103.CarryFieldEgg) == "function" then
                local v2376 = v2374.FirstAreaSlotKey or (v2374.AreaId or v2374.SlotKey)

                pcall(u1103.CarryFieldEgg, v2375, v2376)
            end
        end

        local v2377 = v1191()
        local Character20 = LocalPlayer.Character
        local v2379

        if not Character20 then
            v2379 = nil
        else
            local Humanoid = Character20:FindFirstChildOfClass("Humanoid")
            local HumanoidRootPart = Character20:FindFirstChild("HumanoidRootPart")

            v2379 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
        end

        local v2382 = false

        if v2379 and typeof(p459.pos) == "Vector3" then
            v2382 = Vector3.new(v2379.Position.X - p459.pos.X, 0, v2379.Position.Z - p459.pos.Z).Magnitude <= 7
        end

        if v2382 and t216.promptIsTarget(v2377, p459, 5) then
            v1190(v2377)
        end
    end
    function t216.pickSatchelEvent()
        if not u1103 or type(u1103.ReadOwnerEggs) ~= "function" then
            return
        end
        local u2383
        pcall(function()
            u2383 = u1103.ReadOwnerEggs(LocalPlayer.UserId)
        end)
        if type(u2383) ~= "table" then
            return
        end
        local v2384 = v1194(t9.EventKeepGen)
        local t304
        local v2386
        for k, v in pairs(u2383) do
            if type(v) == "table" and v.HasParasite == true and v.Placement == nil then
                local v2389 = v.Uid or k

                if not t216.eventSkip or not t216.eventSkip[v2389] then
                    local AssetCategory = v.AssetCategory
                    local v2391 = if not not Directory and AssetCategory then Directory[AssetCategory] else nil
                    local v2392 = v1193(v, v2391)

                    if not (v2384 > 0) or not (v2384 <= v2392) then
                        if t216.findEventEggTool(v2389) then
                            if not t304 or v2392 < t304.earn then
                                t304 = {
									uid = v2389,
									earn = v2392,
									name = v2391 and (v2391.DisplayName or v.AssetCategory) or tostring(v.AssetCategory)
								}
                            end
                        else
                            v2386 = v2386 or v2389
                        end
                    end
                end
            end
        end
        if not t304 and v2386 then
            t216.wearEventEgg(v2386)
        end

        return t304
    end
    function t216.monsterStand()
        local MonsterParasiteMonsters = workspace:FindFirstChild("MonsterParasiteMonsters")
        if not MonsterParasiteMonsters then
            return
        end
        local v2394
        for _, child in ipairs(MonsterParasiteMonsters:GetChildren()) do
            if child:GetAttribute("OwnerUserId") == LocalPlayer.UserId then
                v2394 = child

                break
            end
        end
        local v2397 = v2394 or MonsterParasiteMonsters:FindFirstChildWhichIsA("Model")
        if not v2397 then
            return
        end
        local v2398 = v2397:FindFirstChild("RootPart") or v2397.PrimaryPart
        if not v2398 or not v2398:IsA("BasePart") then
            return
        end
        local vector3 = Vector3.new(v2398.CFrame.LookVector.X, 0, v2398.CFrame.LookVector.Z)
        local v2400 = if not (vector3.Magnitude < 0.05) then vector3.Unit else Vector3.new(0, 0, -1)
        local v2401 = tonumber(t216.feedPad) or 5
        if v2401 < 1.2 then
            v2401 = 1.2
        end
        local v2402 = v2398.Position + v2400 * v2401
        local v2403 = v2398.Position.Y + 2
        if type(u1130) ~= "function" or not u1130() then
            local v2404 = v1147(Vector3.new(v2402.X, v2398.Position.Y + 8, v2402.Z))

            v2403 = if type(v2404) ~= "number" or not (v2404 < v2398.Position.Y + 10) then v2398.Position.Y + 3 else v2404 + 3
        end
        local v2405 = v2398:FindFirstChild("FeedPrompt") or v2397:FindFirstChild("FeedPrompt", true)

        return Vector3.new(v2402.X, v2403, v2402.Z), v2397, v2405, v2398
    end
    function t216.eventToolUid()
        local Character21 = LocalPlayer.Character
        local v2407 = Character21 and Character21:FindFirstChildWhichIsA("Tool")

        if not v2407 or v2407:GetAttribute("ItemType") ~= "AssetEgg" then
            return
        end

        local v2408 = v2407:GetAttribute("UID") or v2407:GetAttribute("Uid")

        if type(v2408) == "string" and v2408 ~= "" then
            return v2408, v2407
        end
    end
    function t216.findEventEggTool(p460)
        local u2410 = type(p460) == "string" and (p460 ~= "" and p460) or nil
        local function v2411(p461)
            if not p461 then
                return
            end

            for _, child in ipairs(p461:GetChildren()) do
                if not child:IsA("Tool") or child:GetAttribute("ItemType") ~= "AssetEgg" then
                    continue
                end

                local v4558 = child:GetAttribute("UID") or child:GetAttribute("Uid")

                if type(v4558) == "string" and v4558 ~= "" then
                    if u2410 then
                        if v4558 ~= u2410 then
                            continue
                        end

                        return child, v4558
                    end

                    if child:GetAttribute("HasParasite") ~= true then
                        continue
                    end

                    return child, v4558
                end
            end
        end
        local v2412, v2413 = v2411(LocalPlayer.Character)
        if v2412 then
            return v2412, v2413
        end
        local v2414, v2415 = v2411(LocalPlayer:FindFirstChild("Backpack"))
        if v2414 then
            return v2414, v2415
        end
        if u2410 then
            return
        end
        local u2416
        pcall(function()
            u2416 = u1103 and u1103.ReadOwnerEggs(LocalPlayer.UserId)
        end)
        if type(u2416) ~= "table" then
            return
        end
        local function v2417(p462)
            if not p462 then
                return
            end

            for _, child in ipairs(p462:GetChildren()) do
                if not child:IsA("Tool") or child:GetAttribute("ItemType") ~= "AssetEgg" then
                    continue
                end

                local v4562 = child:GetAttribute("UID") or child:GetAttribute("Uid")
                local v4563 = type(v4562) == "string" and (u2416[v4562] or u2416[tostring(v4562)])

                if type(v4563) ~= "table" then
                    for k, v in pairs(u2416) do
                        if type(v) == "table" and (v4562 == v.Uid or k == v4562) then
                            v4563 = v

                            break
                        end
                    end
                end

                if type(v4563) == "table" and v4563.HasParasite == true and v4563.Placement == nil then
                    return child, v4562
                end
            end
        end

        return v2417(LocalPlayer.Character) or v2417(LocalPlayer:FindFirstChild("Backpack"))
    end
    function t216.wearEventEgg(p463)
        local str41 = tostring(p463 or "")

        if str41 == "" then
            return false
        end

        if t216.eventToolUid() == str41 then
            return true
        end

        local elapsed43 = os.clock()

        if elapsed43 - (t216.lastWear or 0) < 0.4 then
            return false
        end

        t216.lastWear = elapsed43

        local v2421 = select(1, v1112())

        local function v2422(p464)
            if not p464 then
                return
            end

            for _, child in ipairs(p464:GetChildren()) do
                if child:IsA("Tool") and (child:GetAttribute("UID") or child:GetAttribute("Uid")) == str41 then
                    return child
                end
            end
        end

        local u2423 = v2422(LocalPlayer.Character) or v2422(LocalPlayer:FindFirstChild("Backpack"))

        if u2423 and u2423:GetAttribute("ItemType") ~= "AssetEgg" then
            u2423 = nil
        end

        if u2423 and v2421 and u2423.Parent ~= LocalPlayer.Character then
            pcall(function()
                v2421:EquipTool(u2423)
            end)
        end

        if u1103 and type(u1103.WearEggTool) == "function" then
            pcall(u1103.WearEggTool, str41)
        end

        return t216.eventToolUid() == str41
    end
    function t216.mpInvoke(p465, ...)
        local v2425 = v1168({ "Remotes" })
        local v2426 = v2425 and (v2425.MonsterParasite and v2425.MonsterParasite[p465])

        if v2426 == nil then
            return false, "no remote"
        end

        local v2427 = v1170(v2426) or (typeof(v2426) == "Instance" and v2426 or v2426)
        local v2428 = (type(v2427) == "table" or typeof(v2427) == "Instance") and v2427.InvokeServer

        if type(v2428) ~= "function" then
            return false, "no invoke"
        end

        local ok88, result84

        if select("#", ...) <= 0 then
            ok88, result84 = pcall(v2428, v2427)
        else
            ok88, result84 = pcall(v2428, v2427, (...))
        end

        if not ok88 then
            return false, (tostring(result84))
        end

        if type(result84) == "table" then
            return result84.Success == true, tostring(result84.Message or ""), result84
        end

        return result84 == true, tostring(result84), result84
    end
    function t216.feedWaitMsg(p466, p467)
        local v2433 = string.lower((tostring(p466 or "")))

        if type(p467) == "table" then
            v2433 ..= " " .. string.lower((tostring(p467.Message or "")))
        end

        return v2433:find("wait", 1, true) ~= nil or v2433:find("cooldown", 1, true) ~= nil
    end
    function t216.askFeed(p468)
        if type(p468) ~= "string" or p468 == "" then
            return false, "no egg"
        end

        if p468 ~= t216.eventToolUid() then
            t216.wearEventEgg(p468)
        end

        if p468 ~= t216.eventToolUid() then
            return false, "no egg"
        end

        local v2435, v2436, v2437 = t216.mpInvoke("AskFeed")

        t216.lastFeedRes = v2437

        return v2435, v2436, v2437
    end
    function t216.isChestTool(p469)
        if not p469 or not p469:IsA("Tool") then
            return false
        end

        if p469:GetAttribute("ItemType") == "MonsterChest" then
            return true
        end

        return p469.Name == "Monster Chest"
    end
    function t216.findChestTool()
        local function v2439(p470)
            if not p470 then
                return
            end

            for _, child in ipairs(p470:GetChildren()) do
                if t216.isChestTool(child) then
                    return child
                end
            end
        end

        return v2439(LocalPlayer.Character) or v2439(LocalPlayer:FindFirstChild("Backpack"))
    end
    function t216.worldChest()
        for _, child in ipairs(workspace:GetChildren()) do
            if child.Name ~= "MonsterChest" or not child:IsA("Model") then
                continue
            end

            local v2442, v2443, v2444

            if not child or not child.Parent then
                v2442 = nil
                v2443 = nil
                v2444 = nil
            else
                local v2445 = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart", true)

                v2444 = child:FindFirstChild("ChestPrompt", true)

                if v2445 then
                    v2442 = v2445.Position
                    v2443 = child
                else
                    v2442 = nil
                    v2443 = nil
                    v2444 = nil
                end
            end

            if v2442 then
                return v2442, v2443, v2444
            end
        end

        local MonsterParasiteMonsters = workspace:FindFirstChild("MonsterParasiteMonsters")

        if MonsterParasiteMonsters then
            for _, child in ipairs(MonsterParasiteMonsters:GetChildren()) do
                if child.Name ~= "MonsterChest" then
                    continue
                end

                local v2449, v2450, v2451

                if not child or not child.Parent then
                    v2449 = nil
                    v2450 = nil
                    v2451 = nil
                else
                    local v2452 = child.PrimaryPart or child:FindFirstChildWhichIsA("BasePart", true)

                    v2451 = child:FindFirstChild("ChestPrompt", true)

                    if v2452 then
                        v2449 = v2452.Position
                        v2450 = child
                    else
                        v2449 = nil
                        v2450 = nil
                        v2451 = nil
                    end
                end

                if v2449 then
                    return v2449, v2450, v2451
                end
            end
        end
    end
    function t216.equipChest()
        local v2453 = t216.findChestTool()

        if not v2453 then
            return false
        end

        if v2453.Parent == LocalPlayer.Character then
            return true
        end

        local v2454 = select(1, v1112())

        if v2454 then
            pcall(function()
                v2454:EquipTool(v2453)
            end)
        end

        return t216.findChestTool() and t216.findChestTool().Parent == LocalPlayer.Character
    end
    function t216.noChestMsg(p471, p472)
        local v2457 = string.lower((tostring(p471 or "")))

        if type(p472) == "table" then
            v2457 ..= " " .. string.lower((tostring(p472.Message or "")))
        end

        return v2457:find("chest", 1, true) ~= nil and (v2457:find("no", 1, true) ~= nil or (v2457:find("don't", 1, true) ~= nil or (v2457:find("dont", 1, true) ~= nil or (v2457:find("any", 1, true) ~= nil or v2457:find("have", 1, true) ~= nil)))) or v2457:find("no chest", 1, true) ~= nil
    end
    function t216.openChest()
        local v2458 = t216.findChestTool()

        if not v2458 then
            return false, "no chest"
        end

        pcall(function()
            v2458:Activate()
        end)

        local guid = HttpService:GenerateGUID(false)
        local v2460, v2461, v2462 = t216.mpInvoke("AskChestClaim", guid)

        if v2460 and type(v2462) == "table" and type(v2462.OpeningId) == "string" then
            t216.mpInvoke("AskChestRevealComplete", v2462.OpeningId)

            return true, v2461
        end

        if v2460 then
            return true, v2461
        end

        return false, v2461
    end
    function t216.runEvent(p473, p474)
        if t216.state ~= "FeedGo" and (t216.state ~= "Feed" and t216.state ~= "ChestGo" and t216.state ~= "ChestOpen") then
            return false
        end

        u1128 = true

        local v2465, _, _, v2468 = t216.monsterStand()
        local v2469, _, _ = t216.worldChest()

        if t216.state == "ChestGo" or t216.state == "ChestOpen" then
            local v2472 = typeof(v2469) == "Vector3" and v2469 or v2465

            if typeof(v2472) == "Vector3" then
                u1127 = v1225(v2472, p473.Position, true)
            end

            if t216.state == "ChestGo" then
                if t216.findChestTool() then
                    t216.chestAsked = false
                    t216.chestClaimed = false

                    if t216.state ~= "ChestOpen" then
                        v1102("steal", t216.state, "->", "ChestOpen", "got chest", t216.target and t216.target.name or "")
                        t216.chestClaimed = false
                        t216.state = "ChestOpen"
                        t216.since = os.clock()
                    else
                        t216.state = "ChestOpen"
                    end

                    v1231()

                    return true
                end

                if typeof(v2469) ~= "Vector3" then
                    if p474 > 10 then
                        t216.chestSkip = true

                        if t216.state ~= "Scan" then
                            v1102("steal", t216.state, "->", "Scan", "no world chest", t216.target and t216.target.name or "")
                            t216.state = "Scan"
                            t216.since = os.clock()
                        else
                            t216.state = "Scan"
                        end

                        v1231()
                        u1127 = nil
                    end

                    return true
                end

                if not t216.chestAsked then
                    t216.chestAsked = true
                    t216.lastChestTake = os.clock()

                    local v2473, v2474, v2475 = t216.mpInvoke("AskChestTake")

                    if t216.findChestTool() then
                        t216.chestClaimed = false

                        if t216.state ~= "ChestOpen" then
                            v1102("steal", t216.state, "->", "ChestOpen", "got chest", t216.target and t216.target.name or "")
                            t216.chestClaimed = false
                            t216.state = "ChestOpen"
                            t216.since = os.clock()
                        else
                            t216.state = "ChestOpen"
                        end

                        v1231()

                        return true
                    end

                    if not v2473 or t216.noChestMsg(v2474, v2475) then
                        t216.chestSkip = true
                        v1102("steal", "no chest", (tostring(v2474)))

                        if t216.state ~= "Scan" then
                            v1102("steal", t216.state, "->", "Scan", "no chest", t216.target and t216.target.name or "")
                            t216.state = "Scan"
                            t216.since = os.clock()
                        else
                            t216.state = "Scan"
                        end

                        v1231()
                        u1127 = nil

                        return true
                    end
                end

                if p474 > 12 then
                    t216.chestSkip = true

                    if t216.state ~= "Scan" then
                        v1102("steal", t216.state, "->", "Scan", "chest pickup timeout", t216.target and t216.target.name or "")
                        t216.state = "Scan"
                        t216.since = os.clock()
                    else
                        t216.state = "Scan"
                    end

                    v1231()
                    u1127 = nil
                end

                return true
            end

            if not t216.findChestTool() then
                t216.chestSkip = true

                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "no chest", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()
                u1127 = nil

                return true
            end

            t216.equipChest()

            if not t216.chestClaimed then
                t216.chestClaimed = true

                local v2476, v2477 = t216.openChest()

                if v2476 then
                    t216.chests = (t216.chests or 0) + 1
                    t216.chestSkip = false
                    v1102("steal", "opened monster chest", v2477 or "")
                    t216.eventUid = nil

                    if t216.state ~= "Scan" then
                        v1102("steal", t216.state, "->", "Scan", "chest opened", t216.target and t216.target.name or "")
                        t216.state = "Scan"
                        t216.since = os.clock()
                    else
                        t216.state = "Scan"
                    end

                    v1231()
                    u1127 = nil

                    return true
                end

                t216.chestSkip = true
                v1102("steal", "chest open fail", (tostring(v2477)))

                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "chest open fail", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()
                u1127 = nil

                return true
            end

            if p474 > 8 then
                t216.chestSkip = true

                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "chest open timeout", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()
                u1127 = nil
            end

            return true
        end

        if typeof(v2465) ~= "Vector3" then
            t216.lookWhy = "no monster"

            if t216.state ~= "Scan" then
                v1102("steal", t216.state, "->", "Scan", "no monster", t216.target and t216.target.name or "")
                t216.state = "Scan"
                t216.since = os.clock()
            else
                t216.state = "Scan"
            end

            v1231()
            u1127 = nil

            return true
        end

        local v2478 = t216.eventUid or (t216.heldUid or t216.carryUid)
        local v2479, v2480 = t216.findEventEggTool(v2478)

        if v2480 then
            v2478 = v2480
            t216.eventUid = v2480
        end

        if t216.state == "FeedGo" then
            local v2481 = v2468 and (not not v2468:IsA("BasePart") and v2468.Position) or v2465
            local vector3 = Vector3.new(p473.Position.X - v2481.X, 0, p473.Position.Z - v2481.Z)

            if not v2479 then
                if v2478 then
                    t216.wearEventEgg(v2478)
                end

                t216.lookWhy = "need infested"
                u1127 = v1225(v2465, p473.Position, true)

                if p474 > 10 then
                    if t216.state ~= "Scan" then
                        v1102("steal", t216.state, "->", "Scan", "no infested tool", t216.target and t216.target.name or "")
                        t216.state = "Scan"
                        t216.since = os.clock()
                    else
                        t216.state = "Scan"
                    end

                    v1231()
                    u1127 = nil
                else
                    v1231()
                end

                return true
            end

            if v2478 ~= t216.eventToolUid() then
                t216.wearEventEgg(v2478)
            end

            u1127 = v1225(v2465, p473.Position, true)

            if vector3.Magnitude < 8 then
                if v2478 == t216.eventToolUid() then
                    if t216.state ~= "Feed" then
                        v1102("steal", t216.state, "->", "Feed", "at monster", t216.target and t216.target.name or "")
                        t216.state = "Feed"
                        t216.since = os.clock()
                    else
                        t216.state = "Feed"
                    end

                    v1231()
                else
                    t216.lookWhy = "equip infested"
                    t216.wearEventEgg(v2478)
                    v1231()
                end
            elseif p474 > 36 then
                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "monster timeout", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()
                u1127 = nil
            end

            return true
        end

        if not v2479 or v2478 ~= t216.eventToolUid() then
            if v2478 then
                t216.wearEventEgg(v2478)
            end

            t216.lookWhy = "equip infested"

            if p474 > 8 then
                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "no infested tool", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()
                u1127 = nil
            else
                v1231()
            end

            return true
        end

        u1127 = v1225(v2465, p473.Position, true)

        local v2483 = v2468 and (not not v2468:IsA("BasePart") and v2468.Position) or v2465

        if Vector3.new(p473.Position.X - v2483.X, 0, p473.Position.Z - v2483.Z).Magnitude > 7 then
            t216.lookWhy = "getting closer"
            v1231()

            return true
        end

        local elapsed44 = os.clock()

        if elapsed44 < (t216.feedLockUntil or 0) then
            t216.lookWhy = "feed wait"
            v1231()

            return true
        end

        if elapsed44 - (t216.lastFeed or 0) >= 1.6 then
            t216.lastFeed = elapsed44
            t216.feedLockUntil = elapsed44 + 1.6

            local v2485, v2486, v2487 = t216.askFeed(v2478)

            if v2485 then
                local v2488 = t216

                v2488.fed = v2488.fed + 1
                t216.feedWasWait = false
                t216.feedLockUntil = elapsed44 + 2.2

                if t216.eventFromField then
                    v1232("fed monster")
                end

                t216.eventUid = nil
                t216.eventFromField = false
                t216.target = nil
                t216.lockUid = nil

                local v2489 = type(v2487) == "table" and tonumber(v2487.Charge) or 0
                local v2490 = type(v2487) == "table" and tonumber(v2487.PendingChests) or 0

                v1102("steal", "fed monster", v2486 or "", "charge", v2489, "pending", v2490)

                if t216.findChestTool() then
                    if t216.state ~= "ChestOpen" then
                        v1102("steal", t216.state, "->", "ChestOpen", "got chest", t216.target and t216.target.name or "")
                        t216.chestClaimed = false
                        t216.state = "ChestOpen"
                        t216.since = os.clock()
                    else
                        t216.state = "ChestOpen"
                    end

                    v1231()
                elseif t216.worldChest() then
                    if t216.state ~= "ChestGo" then
                        v1102("steal", t216.state, "->", "ChestGo", "chest", t216.target and t216.target.name or "")
                        t216.chestAsked = false
                        t216.state = "ChestGo"
                        t216.since = os.clock()
                    else
                        t216.state = "ChestGo"
                    end

                    v1231()
                else
                    if t216.state ~= "Scan" then
                        v1102("steal", t216.state, "->", "Scan", "fed", t216.target and t216.target.name or "")
                        t216.state = "Scan"
                        t216.since = os.clock()
                    else
                        t216.state = "Scan"
                    end

                    v1231()
                    u1127 = nil
                end

                return true
            end

            t216.feedWasWait = t216.feedWaitMsg(v2486, v2487)

            if t216.feedWasWait then
                t216.feedLockUntil = elapsed44 + 2.8
                t216.lookWhy = "feed wait"
                v1102("steal", "feed cooldown", (tostring(v2486)))
            else
                t216.feedLockUntil = elapsed44 + 1.6
                v1102("steal", "feed fail", (tostring(v2486)))

                if type(v2486) == "string" and string.find(string.lower(v2486), "closer", 1, true) then
                    t216.feedPad = math.max(1.4, (tonumber(t216.feedPad) or 5) - 1.6)
                end
            end
        end

        if p474 > 28 then
            if v2478 and not t216.feedWasWait then
                t216.eventSkip[v2478] = true
            end

            local v2491 = not t216.feedWasWait and "feed timeout" or "feed wait"

            if t216.state ~= "Scan" then
                v1102("steal", t216.state, "->", "Scan", v2491 or "", t216.target and t216.target.name or "")
                t216.state = "Scan"
                t216.since = os.clock()
            else
                t216.state = "Scan"
            end

            v1231()
            u1127 = nil
        end

        return true
    end
    function u1132(p475)
        if not u1117 or not t9.AutoSteal then
            return
        end

        local v2493 = tonumber(p475) or (n7 or 0.016)

        v1158("tick")
        t216.muteHazards(true)

        if t216.muteBelt then
            t216.muteBelt(t216.allowTrain() ~= true)
        end

        local v2494 = v1228()
        local AreaEggCycleNightSeconds = workspace:GetAttribute("AreaEggCycleNightSeconds")

        if type(AreaEggCycleNightSeconds) ~= "number" then
            AreaEggCycleNightSeconds = 10
        end

        local v2496 = v2494 <= math.clamp(AreaEggCycleNightSeconds, 1, 300)

        if v2496 then
            local v2497 = t216.state == "Return" or (t216.state == "Bank" or (t216.state == "FeedGo" or (t216.state == "Feed" or (t216.state == "ChestGo" or t216.state == "ChestOpen"))))
            local v2498 = t216.state == "Safe"

            if not v2497 and not v2498 then
                u1127 = nil
                u1128 = false
                t216.target = nil

                if t216.state ~= "Night" then
                    if t216.state ~= "Night" then
                        v1102("steal", t216.state, "->", "Night", "paused until day", t216.target and t216.target.name or "")
                        t216.state = "Night"
                        t216.since = os.clock()
                    else
                        t216.state = "Night"
                    end

                    v1231()

                    return
                end

                local ok89, result85 = pcall(v1228)
                local v2501 = (not ok89 or type(result85) ~= "number") and 0 or math.max(0, math.floor(result85 + 0.5))

                if v2501 ~= t216.nightLeft then
                    t216.nightLeft = v2501
                    v1231()
                end

                return
            end
        elseif t216.state == "Night" then
            if t216.state ~= "Scan" then
                v1102("steal", t216.state, "->", "Scan", "day", t216.target and t216.target.name or "")
                t216.state = "Scan"
                t216.since = os.clock()
            else
                t216.state = "Scan"
            end

            v1231()
        end

        local Character22 = LocalPlayer.Character
        local v2503, v2504

        if not Character22 then
            v2503 = nil
            v2504 = nil
        else
            v2503 = Character22:FindFirstChildOfClass("Humanoid")
            v2504 = Character22:FindFirstChild("HumanoidRootPart")

            if not v2503 or not v2504 or v2503.Health <= 0 then
                v2503 = nil
                v2504 = nil
            end
        end

        local v2505 = v2503

        v1234(v2504)
        t216.adoptCarry()

        if not v2504 then
            u1127 = nil

            return
        end

        if t216.rescueVoid(v2504, v2505) then
            return
        end

        if t216.state == "Safe" then
            u1128 = true
            pcall(v1158, "safe")
            pcall(u1131)

            if t216.target and v2504 and (v1227(v2504) or not v1218(v2504.Position)) then
                local v2506 = v1221(v2504.Position)

                if v1227(v2504) or not v2506 or not v1222(v2506, v2504.Position, 18) then
                    if t216.state ~= "GoEgg" then
                        v1102("steal", t216.state, "->", "GoEgg", "skip pad", t216.target and t216.target.name or "")
                        t216.state = "GoEgg"
                        t216.since = os.clock()
                    else
                        t216.state = "GoEgg"
                    end

                    v1231()

                    return
                end
            end

            local v2507, v2508 = v1226(v2504.Position)

            if typeof(v2508) ~= "Vector3" then
                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "no safe zone", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()

                return
            end

            u1127 = v2507

            if Vector3.new(v2504.Position.X - v2508.X, 0, v2504.Position.Z - v2508.Z).Magnitude < 16 then
                if v2496 then
                    if t216.state ~= "Night" then
                        v1102("steal", t216.state, "->", "Night", "at safe zone", t216.target and t216.target.name or "")
                        t216.state = "Night"
                        t216.since = os.clock()
                    else
                        t216.state = "Night"
                    end

                    v1231()

                    return
                end

                if t216.target then
                    if t216.state ~= "GoEgg" then
                        v1102("steal", t216.state, "->", "GoEgg", "from pad", t216.target and t216.target.name or "")
                        t216.state = "GoEgg"
                        t216.since = os.clock()
                    else
                        t216.state = "GoEgg"
                    end

                    v1231()

                    return
                end

                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "at safe zone", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()

                return
            end

            if os.clock() - t216.since > 14 then
                if t216.target then
                    if t216.state ~= "GoEgg" then
                        v1102("steal", t216.state, "->", "GoEgg", "safe timeout", t216.target and t216.target.name or "")
                        t216.state = "GoEgg"
                        t216.since = os.clock()
                    else
                        t216.state = "GoEgg"
                    end

                    v1231()

                    return
                end

                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "safe timeout", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()
            end

            return
        end

        if u1127 then
            local Position6 = v2504.Position

            if t216.lastPos and (Position6 - t216.lastPos).Magnitude < 1.2 then
                local v2510 = t216

                v2510.stillFor = v2510.stillFor + v2493
            else
                t216.stillFor = 0
            end

            t216.lastPos = Position6

            if t216.stillFor > 0.85 then
                v1158("stuck")
                pcall(u1131)

                if not u1130() then
                    pcall(function()
                        v2505.Jump = true
                        v2505.AutoJumpEnabled = true
                    end)
                end
            end

            if t216.stillFor > 2.6 then
                local state = t216.state

                if state ~= "Feed" and state ~= "FeedGo" and state ~= "ChestGo" and state ~= "ChestOpen" then
                    t216.resetStuck(v2504, v2505)
                else
                    t216.stillFor = 0
                end

                if t216.state == "GoEgg" and not t216.carrying and not t216.lockUid then
                    v1102("steal", "stuck, rescan")
                    t216.target = nil

                    if t216.state ~= "Scan" then
                        v1102("steal", t216.state, "->", "Scan", "stuck", t216.target and t216.target.name or "")
                        t216.state = "Scan"
                        t216.since = os.clock()
                    else
                        t216.state = "Scan"
                    end

                    v1231()

                    return
                end
            end
        else
            t216.stillFor = 0
            t216.lastPos = v2504.Position
        end

        if u1127 and not u1116 then
            local vector3 = Vector3.new(u1127.X - v2504.Position.X, 0, u1127.Z - v2504.Position.Z)

            pcall(function()
                v2505.PlatformStand = false
                v2505.Sit = false
                v2505.AutoRotate = true

                if u1128 and typeof(u1127) == "Vector3" then
                    local v4575 = tonumber(t9.StealSpeed) or 200

                    if t216 and t216.carrying and (t216.state == "Return" or t216.state == "Bank") and t9.GuardianBypass ~= false then
                        local stage = tonumber(t216.returnRouteStage) or 0
                        if stage >= 2 then
                            v4575 = tonumber(t9.FinalReturnSpeed) or 20
                        else
                            v4575 = 16
                        end
                    else
                        v4575 = math.min(v4575, 200)
                    end

                    v2505.WalkSpeed = math.clamp(v4575, 16, 200)
                else
                    v2505.WalkSpeed = n9
                end

                if vector3.Magnitude > 1.2 then
                    v2505:Move(vector3.Unit, false)

                    return
                end

                v2505:Move(Vector3.zero, false)
            end)
        end

        local elapsed45 = os.clock()
        local v2514 = elapsed45 - t216.since

        if t216.runEvent(v2504, v2514) then
            return
        end

        if not t216.carrying then
            local v2515 = t216.eggResetAt or 0
            local v2516 = false

            if v2515 > 0 then
                local v2517 = elapsed45 - v2515

                v2516 = v2517 < 3.25 or (t216.eggResetGrew or 0) > 0 and (elapsed45 - t216.eggResetGrew < 0.55 and v2517 < 5)

                if not v2516 then
                    t216.eggResetAt = 0
                end
            end

            local v2518 = t216.wallUp()

            if (v2516 or v2518) and not t216.heldUid then
                local state = t216.state

                if state == "Idle" or state == "Scan" or state == "GoEgg" or state == "Grab" or state == "Chase" then
                    t216.target = nil
                    t216.lockUid = nil
                    t216.lockPos = nil
                    u1127 = nil
                    u1128 = false

                    local v2520 = not v2516 and "waiting barrier" or "eggs refreshing"

                    t216.lookWhy = v2520

                    if state ~= "Scan" then
                        if t216.state ~= "Scan" then
                            v1102("steal", t216.state, "->", "Scan", v2520 or "", t216.target and t216.target.name or "")
                            t216.state = "Scan"
                            t216.since = os.clock()
                        else
                            t216.state = "Scan"
                        end

                        v1231()

                        return
                    end

                    v1231()

                    return
                end
            end
        end

        if t216.state == "Idle" or t216.state == "Scan" then
            if t9.AutoEvent and not t216.chestSkip then
                if t216.findChestTool() then
                    u1128 = true

                    if t216.state ~= "ChestOpen" then
                        v1102("steal", t216.state, "->", "ChestOpen", "chest in bag", t216.target and t216.target.name or "")
                        t216.chestClaimed = false
                        t216.state = "ChestOpen"
                        t216.since = os.clock()
                    else
                        t216.state = "ChestOpen"
                    end

                    v1231()

                    return
                end

                if t216.worldChest() then
                    u1128 = true

                    if t216.state ~= "ChestGo" then
                        v1102("steal", t216.state, "->", "ChestGo", "world chest", t216.target and t216.target.name or "")
                        t216.chestAsked = false
                        t216.state = "ChestGo"
                        t216.since = os.clock()
                    else
                        t216.state = "ChestGo"
                    end

                    v1231()

                    return
                end
            end

            local v2521 = v1216()

            if v2521 and v2521.matched then
                u1128 = true
                v1233(v2521, v2521.area or "egg")

                return
            end

            local v2522 = os.clock() >= (t216.feedLockUntil or 0)

            if t9.AutoEvent then
                local v2523 = v2522 and t216.pickSatchelEvent()

                if v2523 then
                    t216.eventUid = v2523.uid
                    t216.eventFromField = false
                    u1128 = true

                    if t216.state ~= "FeedGo" then
                        v1102("steal", t216.state, "->", "FeedGo", "satchel infested", t216.target and t216.target.name or "")
                        t216.feedDropped = false
                        t216.feedPad = 5
                        t216.state = "FeedGo"
                        t216.since = os.clock()
                    else
                        t216.state = "FeedGo"
                    end

                    v1231()

                    return
                end

                if v2522 and v2521 and v2521.event then
                    u1128 = true
                    v1233(v2521, "event")

                    return
                end
            elseif v2521 and v2521.matched then
                u1128 = true
                v1233(v2521, v2521.area)

                return
            end

            t216.target = nil
            t216.lockUid = nil
            t216.lockPos = nil

            if not u1135 or not u1135.driving or not u1135.driving() then
                u1128 = false
                u1127 = nil
            end

            local v2524 = v1204()
            local v2525 = type(v2524) == "table" and #v2524 or 0
            local n65 = 0
            local n66 = 0

            if type(v2524) == "table" then
                for i = 1, v2525 do
                    local v2529 = v2524[i]

                    if type(v2529) == "table" then
                        local State = v2529.State
                        local num = tonumber(v2529.CarrierUserId)

                        if (State == "Slot" or State == "Dropped") and ((not num or num == 0 or num == LocalPlayer.UserId) and not v1213(v2529)) then
                            n65 += 1

                            local AssetCategory = v2529.AssetCategory
                            local v2533 = if not not Directory and AssetCategory then Directory[AssetCategory] else nil

                            if v1215(v2529, v2533) then
                                local v2535

                                if (t9.StealMode or "Best value") == "Gen ($/s) snipe" then
                                    local v2534 = v1194(t9.GenSnipeFloor)

                                    v2535 = not (v2534 > 0) or not (v2534 > v1193(v2529, v2533))
                                else
                                    v2535 = true
                                end

                                if v2535 then
                                    n66 += 1
                                end
                            end
                        end
                    end
                end
            end

            if not v2522 and t9.AutoEvent then
                t216.lookWhy = "feed wait"
            elseif v2525 == 0 then
                t216.lookWhy = "map empty"
            elseif n65 == 0 then
                t216.lookWhy = "nests empty"
            elseif n66 == 0 then
                t216.lookWhy = "no match"
            else
                t216.lookWhy = tostring(n66) .. " open"
            end

            if t216.state ~= "Scan" then
                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "no target", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()

                return
            end

            v1231()

            return
        end

        if t216.state == "GoEgg" then
            local target = t216.target

            if not target then
                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "lost target", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()

                return
            end

            pcall(v1158, "goegg")
            pcall(u1131)

            local v2537, v2538 = v1235(target)

            if v2538 == "plot" then
                t216.target = nil
                t216.lockUid = nil
                t216.lockPos = nil

                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "plot egg", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()

                return
            end

            if v2538 == "Carried" then
                if tonumber(target.carrier or target.rec and target.rec.CarrierUserId) == LocalPlayer.UserId then
                    t216.carrying = true
                    t216.carryUid = target.rec and target.rec.Uid or t216.carryUid
                    t216.heldUid = t216.carryUid or t216.heldUid
                    t216.adoptCarry()

                    return
                end

                if t9.BatAura then
                    if t216.state ~= "Chase" then
                        v1102("steal", t216.state, "->", "Chase", "player has it", t216.target and t216.target.name or "")
                        t216.state = "Chase"
                        t216.since = os.clock()
                    else
                        t216.state = "Chase"
                    end

                    v1231()

                    return
                end

                if v2514 > 3 then
                    t216.lockUid = nil
                    t216.lockPos = nil
                    t216.target = nil

                    if t216.state ~= "Scan" then
                        v1102("steal", t216.state, "->", "Scan", "taken", t216.target and t216.target.name or "")
                        t216.state = "Scan"
                        t216.since = os.clock()
                    else
                        t216.state = "Scan"
                    end

                    v1231()
                end

                return
            end

            if v2537 then
                if typeof(target.pos) == "Vector3" then
                    t216.lockPos = target.pos
                end

                local pos = target.pos
                local _ = v2504.Position
                local v2541 = if typeof(pos) == "Vector3" then if not u1130() then Vector3.new(pos.X, pos.Y - 2.5, pos.Z) else Vector3.new(pos.X, pos.Y + 1.5, pos.Z) else pos

                u1127 = v1225(v2541, v2504.Position, true)
                u1128 = true

                if typeof(u1127) == "Vector3" and typeof(v2541) == "Vector3" then
                    local Magnitude = Vector3.new(u1127.X - v2504.Position.X, 0, u1127.Z - v2504.Position.Z).Magnitude
                    local Magnitude2 = Vector3.new(v2541.X - v2504.Position.X, 0, v2541.Z - v2504.Position.Z).Magnitude

                    if Magnitude < 8 and Magnitude2 > 20 then
                        u1127 = v2541
                    end
                end

                local Magnitude = Vector3.new(v2504.Position.X - v2541.X, 0, v2504.Position.Z - v2541.Z).Magnitude
                local v2545 = v2504.Position.Y - v2541.Y

                if not u1130() and Magnitude <= 16 then
                    u1127 = v2541
                end

                local v2546 = not (target.rec and target.rec.State == "Dropped") and 10 or 16

                if u1130() then
                    if Magnitude <= v2546 and v2545 < 18 then
                        v1236(target)
                    end

                    if Magnitude <= 5 and v2545 < 10 then
                        if os.clock() < (t216.nextGrabAt or 0) then
                            t216.lookWhy = "pickup cooldown"
                            u1127 = v2541
                            u1128 = true
                            v1231()
                            return
                        end

                        local v2547 = "in range " .. math.floor(Magnitude)

                        if t216.state ~= "Grab" then
                            v1102("steal", t216.state, "->", "Grab", v2547 or "", t216.target and t216.target.name or "")
                            t216.state = "Grab"
                            t216.since = os.clock()
                        else
                            t216.state = "Grab"
                        end

                        v1231()

                        return
                    end
                else
                    local Magnitude3 = (v2504.Position - v2541).Magnitude

                    if Magnitude3 <= v2546 then
                        v1236(target)
                    end

                    if Magnitude3 <= 4 then
                        if os.clock() < (t216.nextGrabAt or 0) then
                            t216.lookWhy = "pickup cooldown"
                            u1127 = v2541
                            u1128 = true
                            v1231()
                            return
                        end

                        local v2549 = "in range " .. math.floor(Magnitude3)

                        if t216.state ~= "Grab" then
                            v1102("steal", t216.state, "->", "Grab", v2549 or "", t216.target and t216.target.name or "")
                            t216.state = "Grab"
                            t216.since = os.clock()
                        else
                            t216.state = "Grab"
                        end

                        v1231()

                        return
                    end
                end
            else
                n29 = 0
                u1127 = nil
                u1128 = false

                if v2514 > 2.5 then
                    v1102("steal", "egg gone", v2538 or "")
                    t216.lockUid = nil
                    t216.lockPos = nil
                    t216.target = nil

                    local v2550 = v2538 or "egg gone"

                    if t216.state ~= "Scan" then
                        v1102("steal", t216.state, "->", "Scan", v2550 or "", t216.target and t216.target.name or "")
                        t216.state = "Scan"
                        t216.since = os.clock()
                    else
                        t216.state = "Scan"
                    end

                    v1231()

                    return
                end
            end

            if v2514 > (not t216.lockUid and 18 or 45) then
                v1102("steal", "GoEgg timeout, rescan")
                n29 = 0

                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "timeout", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()
            end

            return
        end

        if t216.state == "Grab" then
            local target = t216.target

            if not target then
                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "no target", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()

                return
            end

            pcall(v1158, "grab")
            pcall(u1131)

            local v2552, v2553 = v1235(target)

            if v2553 == "Carried" then
                if tonumber(target.carrier or target.rec and target.rec.CarrierUserId) == LocalPlayer.UserId then
                    t216.carrying = true
                    t216.carryUid = target.rec and target.rec.Uid or t216.carryUid
                    t216.heldUid = t216.carryUid or t216.heldUid
                    t216.adoptCarry()

                    return
                end

                if t9.BatAura then
                    if t216.state ~= "Chase" then
                        v1102("steal", t216.state, "->", "Chase", "player has it", t216.target and t216.target.name or "")
                        t216.state = "Chase"
                        t216.since = os.clock()
                    else
                        t216.state = "Chase"
                    end

                    v1231()

                    return
                end

                if v2514 > 3 then
                    t216.lockUid = nil
                    t216.lockPos = nil
                    t216.target = nil

                    if t216.state ~= "Scan" then
                        v1102("steal", t216.state, "->", "Scan", "taken", t216.target and t216.target.name or "")
                        t216.state = "Scan"
                        t216.since = os.clock()
                    else
                        t216.state = "Scan"
                    end

                    v1231()
                end

                return
            end

            if v2552 then
                local v2554 = v1225
                local pos = target.pos
                local _ = v2504.Position

                u1127 = v2554(if typeof(pos) == "Vector3" then if not u1130() then Vector3.new(pos.X, pos.Y - 2.5, pos.Z) else Vector3.new(pos.X, pos.Y + 1.5, pos.Z) else pos, v2504.Position, true)

                if typeof(target.pos) == "Vector3" then
                    t216.lockPos = target.pos
                    t216.lockAt = os.clock()
                end
            else
                u1127 = nil
                u1128 = false

                if v2514 > 2.5 then
                    v1102("steal", "grab lost", v2553 or "")
                    t216.lockUid = nil
                    t216.lockPos = nil
                    t216.target = nil

                    local v2557 = v2553 or "grab lost"

                    if t216.state ~= "Scan" then
                        v1102("steal", t216.state, "->", "Scan", v2557 or "", t216.target and t216.target.name or "")
                        t216.state = "Scan"
                        t216.since = os.clock()
                    else
                        t216.state = "Scan"
                    end

                    v1231()

                    return
                end
            end

            u1128 = true
            v1236(target)

            if t216.carrying then
                t216.adoptCarry()

                return
            end

            if v2514 > (not t216.lockUid and (not target.rec or target.rec.State ~= "Dropped") and 8 or 30) then
                v1102("steal", "Grab timeout")
                n29 = 0

                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "grab timeout", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()
            end

            return
        end

        if t216.state == "Chase" then
            local target = t216.target
            if not target or not t9.BatAura then
                t216.target = nil

                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "no chase", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()

                return
            end
            local v2559, v2560 = v1235(target)
            if v2560 ~= "Carried" then
                if v2559 then
                    if t216.state ~= "GoEgg" then
                        v1102("steal", t216.state, "->", "GoEgg", "egg loose", t216.target and t216.target.name or "")
                        t216.state = "GoEgg"
                        t216.since = os.clock()
                    else
                        t216.state = "GoEgg"
                    end

                    v1231()

                    return
                end

                t216.target = nil

                local v2561 = v2560 or "chase lost"

                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", v2561 or "", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()

                return
            end
            local v2562
            local v2563
            if t216.bat then
                v2562, v2563 = t216.bat.posOf(target.carrier)
            end
            if v2562 then
                u1127 = v2562
                u1128 = true

                if v2563 then
                    t216.bat.swingAt(v2563)
                end
            elseif v2514 > 4 then
                t216.target = nil

                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "thief gone", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()

                return
            end
            if v2514 > 20 then
                t216.target = nil

                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "chase timeout", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()
            end

            return
        end

        if t216.state == "Return" then
            -- IMPORTANT: u1219() may resolve to SpawnLocation/SpawnTarget,
            -- which can be INSIDE the SafeZone. For staged returns we must
            -- use the actual Workspace.Spawn.SafeZone boundary, not its spawn
            -- point/center, otherwise the first hop can land directly in the
            -- safe area.
            local spawnFolder = workspace:FindFirstChild("Spawn")
            local safeZone = spawnFolder and spawnFolder:FindFirstChild("SafeZone")
            if not safeZone or not safeZone:IsA("BasePart") then
                v1102("steal", "no SafeZone part")
                u1127 = nil
                u1128 = false
                return
            end

            local here = v2504.Position
            local localHere = safeZone.CFrame:PointToObjectSpace(here)
            local halfX = safeZone.Size.X * 0.5
            local halfZ = safeZone.Size.Z * 0.5
            local dxOutside = math.max(math.abs(localHere.X) - halfX, 0)
            local dzOutside = math.max(math.abs(localHere.Z) - halfZ, 0)
            local outsideDistance = math.sqrt(dxOutside * dxOutside + dzOutside * dzOutside)

            local finalDistance = math.clamp(tonumber(t9.FinalReturnRadius) or 20, 18, 30)
            local firstDistance = math.clamp(tonumber(t9.FirstReturnHop) or 60, 25, 100)
            local stage = tonumber(t216.returnRouteStage) or 0

            local function pointOutsideSafeZone(gap)
                local flatLocal = Vector3.new(localHere.X, 0, localHere.Z)
                if flatLocal.Magnitude < 0.001 then
                    flatLocal = Vector3.new(1, 0, 0)
                end

                local dirLocal = flatLocal.Unit
                local tx = halfX / math.max(math.abs(dirLocal.X), 0.0001)
                local tz = halfZ / math.max(math.abs(dirLocal.Z), 0.0001)
                local boundaryT = math.min(tx, tz)
                local boundaryLocal = Vector3.new(dirLocal.X * boundaryT, 0, dirLocal.Z * boundaryT)
                local boundaryWorld = safeZone.CFrame:PointToWorldSpace(boundaryLocal)
                local dirWorld = safeZone.CFrame:VectorToWorldSpace(dirLocal)
                local flatWorldDir = Vector3.new(dirWorld.X, 0, dirWorld.Z)

                if flatWorldDir.Magnitude < 0.001 then
                    flatWorldDir = Vector3.new(1, 0, 0)
                else
                    flatWorldDir = flatWorldDir.Unit
                end

                return boundaryWorld + flatWorldDir * gap
            end

            local firstPos = pointOutsideSafeZone(firstDistance)
            local finalPos = pointOutsideSafeZone(finalDistance)

            -- If a previous route drop has left the egg on the ground, preserve the
            -- route stage and go back to the exact dropped UID instead of rescanning.
            if not t216.carrying then
                u1127 = nil
                u1128 = false

                if t216.lockUid and typeof(t216.lockPos) == "Vector3" then
                    if os.clock() < (t216.nextGrabAt or 0) then
                        t216.lookWhy = "pickup cooldown"
                        v1231()
                        return
                    end

                    if t216.state ~= "GoEgg" then
                        v1102("steal", t216.state, "->", "GoEgg", "route re-grab", t216.target and t216.target.name or "")
                        t216.state = "GoEgg"
                        t216.since = os.clock()
                    else
                        t216.state = "GoEgg"
                    end
                    v1231()
                    return
                end

                t216.returnRouteStage = 0
                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "empty return", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end
                v1231()
                return
            end

            -- Stage 0: first pickup -> teleport closer -> deliberate drop.
            if stage == 0 then
                -- FIRST HOP: land firstDistance studs OUTSIDE the SafeZone border.
                -- Never use the SafeZone center here.
                if outsideDistance > firstDistance + 2 then
                    u1127 = nil
                    u1128 = false

                    pcall(function()
                        v2504.CFrame = CFrame.new(firstPos.X, v2504.Position.Y, firstPos.Z)
                        v2504.AssemblyLinearVelocity = Vector3.zero
                        v2504.AssemblyAngularVelocity = Vector3.zero
                    end)

                    task.wait(0.12)
                    if t216.carrying then
                        local dropped = t216.routeDrop("Manual")
                        if dropped then
                            t216.returnRouteStage = 1
                            t216.returnRouteLastHop = os.clock()
                            t216.nextGrabAt = os.clock() + math.clamp(tonumber(t9.RouteGrabCooldown) or 1.1, 0.5, 2.0)
                            v1102("steal", "route", "hop1 -> outside edge +", firstDistance, "drop")
                        else
                            v1102("steal", "route", "hop1 drop failed")
                        end
                    end
                    v1231()
                    return
                end

                -- Already at/inside the first checkpoint: continue to stage 1.
                t216.returnRouteStage = 1
                stage = 1
            end

            -- Stage 1: re-grab -> teleport to ~20 studs -> deliberate drop.
            if stage == 1 and t216.carrying then
                -- SECOND HOP: land exactly finalDistance studs OUTSIDE the
                -- SafeZone border, then drop and require a real cooldown before
                -- the final re-grab.
                if outsideDistance > finalDistance + 1.5 then
                    u1127 = nil
                    u1128 = false

                    pcall(function()
                        v2504.CFrame = CFrame.new(finalPos.X, v2504.Position.Y, finalPos.Z)
                        v2504.AssemblyLinearVelocity = Vector3.zero
                        v2504.AssemblyAngularVelocity = Vector3.zero
                    end)

                    task.wait(0.12)
                    if t216.carrying then
                        local dropped = t216.routeDrop("Manual")
                        if dropped then
                            t216.returnRouteStage = 2
                            t216.returnRouteLastHop = os.clock()
                            t216.nextGrabAt = os.clock() + math.clamp(tonumber(t9.RouteGrabCooldown) or 1.1, 0.5, 2.0)
                            v1102("steal", "route", "hop2 -> outside edge +", finalDistance, "drop")
                        else
                            v1102("steal", "route", "hop2 drop failed")
                        end
                    end
                    v1231()
                    return
                end

                -- Already at the final checkpoint: drop, then re-grab after cooldown.
                local dropped = t216.routeDrop("Manual")
                if dropped then
                    t216.returnRouteStage = 2
                    t216.returnRouteLastHop = os.clock()
                    t216.nextGrabAt = os.clock() + math.clamp(tonumber(t9.RouteGrabCooldown) or 1.1, 0.5, 2.0)
                    v1102("steal", "route", "final checkpoint drop", "~", math.floor(outsideDistance), "outside SafeZone")
                end
                v1231()
                return
            end

            -- Stage 2: final re-grab -> ordinary walk at FinalReturnSpeed -> SafeZone.
            if stage >= 2 then
                t216.returnRouteStage = 2
                local target, safe = v1226(v2504.Position)
                if typeof(safe) ~= "Vector3" then
                    safe = safePos
                end

                if v1227(v2504) then
                    if t216.liveCarry and select(1, t216.liveCarry()) then
                        if t216.state ~= "Bank" then
                            v1102("steal", t216.state, "->", "Bank", "at safe zone", t216.target and t216.target.name or "")
                            t216.state = "Bank"
                            t216.since = os.clock()
                        else
                            t216.state = "Bank"
                        end
                        v1231()
                        return
                    end

                    t216.carrying = false
                    t216.returnRouteStage = 0
                    if t216.lockUid and typeof(t216.lockPos) == "Vector3" then
                        if t216.state ~= "GoEgg" then
                            v1102("steal", t216.state, "->", "GoEgg", "safe re-grab", t216.target and t216.target.name or "")
                            t216.state = "GoEgg"
                            t216.since = os.clock()
                        else
                            t216.state = "GoEgg"
                        end
                        v1231()
                        return
                    end

                    if t216.state ~= "Scan" then
                        v1102("steal", t216.state, "->", "Scan", "safe empty", t216.target and t216.target.name or "")
                        t216.state = "Scan"
                        t216.since = os.clock()
                    end
                    v1231()
                    return
                end

                u1127 = typeof(target) == "Vector3" and target or safePos
                u1128 = true
                v1231()
                return
            end

            -- Fallback for unexpected route state.
            t216.returnRouteStage = 0
            u1127 = nil
            u1128 = false
            if t216.state ~= "Scan" then
                t216.state = "Scan"
                t216.since = os.clock()
            end
            v1231()
            return
        end

        if t216.state == "Bank" then
            local _ = v2504.Position
            local v2566 = select(1, u1219())

            u1127 = if typeof(v2566) == "Vector3" then select(1, v1226(v2504.Position)) else v2566

            local elapsed46 = os.clock()

            if elapsed46 - t216.lastBankTry >= 0.45 then
                t216.lastBankTry = elapsed46
            end

            if not t216.carrying then
                v1232("empty-hands-at-safe")

                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "took", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()

                return
            end

            if not t216.liveCarry or not select(1, t216.liveCarry()) then
                t216.carrying = false

                if t216.lockUid and typeof(t216.lockPos) == "Vector3" then
                    if t216.state ~= "GoEgg" then
                        v1102("steal", t216.state, "->", "GoEgg", "empty bank", t216.target and t216.target.name or "")
                        t216.state = "GoEgg"
                        t216.since = os.clock()
                    else
                        t216.state = "GoEgg"
                    end

                    v1231()

                    return
                end

                if t216.state ~= "Scan" then
                    v1102("steal", t216.state, "->", "Scan", "empty bank", t216.target and t216.target.name or "")
                    t216.state = "Scan"
                    t216.since = os.clock()
                else
                    t216.state = "Scan"
                end

                v1231()

                return
            end

            if v2514 > 4 then
                v1102("steal", "Bank timeout, still carrying")

                if t216.state ~= "Return" then
                    v1102("steal", t216.state, "->", "Return", "bank timeout", t216.target and t216.target.name or "")
                    t216.state = "Return"
                    t216.since = os.clock()
                else
                    t216.state = "Return"
                end

                v1231()
            end

            return
        end
    end
    local function v1237()
        t216.running = false
        u1128 = false
        u1127 = nil
        t216.target = nil
        t216.eventUid = nil
        t216.pendingCarry = nil
        t216.returnRouteStage = 0
        t216.returnRouteLastHop = 0
        t216.routeDropAt = 0
        t216.routeDropBusy = false
        t216.nextGrabAt = 0
        t216.haltUntil = os.clock() + 2.2
        t216.muteHazards(false)

        if t216.muteBelt then
            t216.muteBelt(false)
        end

        if t216.state ~= "Idle" then
            v1102("steal", t216.state, "->", "Idle", "disabled", t216.target and t216.target.name or "")
            t216.state = "Idle"
            t216.since = os.clock()
        else
            t216.state = "Idle"
        end

        v1231()

        if u1135 and u1135.stop then
            pcall(u1135.stop)
        end

        local Character23 = LocalPlayer.Character
        local v2569, v2570

        if not Character23 then
            v2569 = nil
            v2570 = nil
        else
            v2569 = Character23:FindFirstChildOfClass("Humanoid")
            v2570 = Character23:FindFirstChild("HumanoidRootPart")

            if not v2569 or not v2570 or v2569.Health <= 0 then
                v2569 = nil
                v2570 = nil
            end
        end

        local v2571 = v2570
        local v2572 = v2569

        pcall(function()
            if v2571 then
                v2571.AssemblyLinearVelocity = Vector3.zero
                v2571.AssemblyAngularVelocity = Vector3.zero
            end

            if v2572 then
                v2572:Move(Vector3.zero, false)
                v2572.Sit = false

                if not t9.Flight then
                    v2572.PlatformStand = false
                end
            end
        end)

        if v2571 and v2571.Position.Y < 58 then
            local v2573 = select(1, u1219())

            pcall(function()
                if typeof(v2573) == "Vector3" and v2573.Y >= 58 then
                    v2571.CFrame = CFrame.new(v2573.X, v2573.Y + 6, v2573.Z)
                else
                    v2571.CFrame = CFrame.new(0, 74, 0)
                end

                v2571.AssemblyLinearVelocity = Vector3.zero
            end)
        end

        if not t9.Flight then
            v1144()
            v1146(v2572, v2571, true)
        end

        v1183((v1184()))

        if u1116 then
            if (t9.Flight or t9.BypassSpeed) and true or (t9.AutoSteal or ((t9.AutoPlaceEggs or t9.AutoTreadmill) and true or (t9.AutoHatch or u1128 and t9.StealTravel == "Flight"))) then
                v1142()
                v1143()
                v1150(true)
            elseif next(t155) then
                v1150(false)
            end
        end

        v1102("steal", "loop stopped")
    end
    if u1103 and u1103.CarryChanged and u1103.CarryChanged.Connect then
        v1136(u1103.CarryChanged:Connect(function(p476)
            if type(p476) ~= "table" then
                return
            end

            local Uid = p476.Uid

            t216.pendingCarry = {
				carrying = p476.IsCarrying == true,
				uid = type(Uid) == "string" and Uid or nil
			}
        end))
    end
    local function v1238(p477, p478)
        local v2578 = t10[p477]

        if not v2578 then
            v1102("wire", "missing widget", p477)

            return
        end

        v2578.on = p478
    end
    v1238("AutoSteal", function(p479)
        if p479 then
            if t216.running then
                return
            end

            t216.running = true
            t216.stillFor = 0
            t216.lastPos = nil
            t216.pendingCarry = nil
            t216.returnRouteStage = 0
            t216.returnRouteLastHop = 0
            t216.returnUid = nil

            if t216.state ~= "Scan" then
                v1102("steal", t216.state, "->", "Scan", "start", t216.target and t216.target.name or "")
                t216.state = "Scan"
                t216.since = os.clock()
            else
                t216.state = "Scan"
            end

            v1231()
            u1128 = false
            u1127 = nil
            v1183((v1184()))

            if u1116 then
                if (t9.Flight or t9.BypassSpeed) and true or (not not t9.AutoSteal or ((t9.AutoPlaceEggs or t9.AutoTreadmill) and true or (not not t9.AutoHatch or u1128 and t9.StealTravel == "Flight"))) then
                    v1142()
                    v1143()
                    v1150(true)
                elseif next(t155) then
                    v1150(false)
                end
            end

            v1102("steal", "loop started", t9.StealTravel)

            return
        end

        v1237()
    end)
    v1238("AutoEvent", function()
        v1231()
    end)
    v1238("AntiTrap", function(p480)
        v1102("engine", "anti trap", p480)
        v1183((v1184()))

        if u1116 then
            if (t9.Flight or t9.BypassSpeed) and true or (not not t9.AutoSteal or ((t9.AutoPlaceEggs or t9.AutoTreadmill) and true or (not not t9.AutoHatch or u1128 and t9.StealTravel == "Flight"))) then
                v1142()
                v1143()
                v1150(true)
            elseif next(t155) then
                v1150(false)
            end
        end

        v1160()
    end)
    v1238("AntiMob", function(p481)
        v1102("engine", "anti ragdoll", p481)
        v1183((v1184()))

        if u1116 then
            if (t9.Flight or t9.BypassSpeed) and true or (not not t9.AutoSteal or ((t9.AutoPlaceEggs or t9.AutoTreadmill) and true or (not not t9.AutoHatch or u1128 and t9.StealTravel == "Flight"))) then
                v1142()
                v1143()
                v1150(true)
            elseif next(t155) then
                v1150(false)
            end
        end

        v1175()
    end)
    v1238("BatAura", function(p482)
        v1102("esp", "bat aura", p482)

        if t216.bat and t216.bat.setLive then
            t216.bat.setLive(p482)
        end
    end)
    v1238("BypassSpeed", function()
        if t9.BypassSpeed ~= true then
            local v2583 = select(1, v1112())

            pcall(function()
                if v2583 then
                    v2583.WalkSpeed = n9
                end
            end)
        end

        v1183((v1184()))

        if not u1116 then
            return
        end

        if (t9.Flight or t9.BypassSpeed) and true or (not not t9.AutoSteal or ((t9.AutoPlaceEggs or t9.AutoTreadmill) and true or (not not t9.AutoHatch or u1128 and t9.StealTravel == "Flight"))) then
            v1142()
            v1143()
            v1150(true)

            return
        end

        if next(t155) then
            v1150(false)
        end
    end)
    v1238("StealTravel", function(p483)
        v1102("wire", "travel mode", (tostring(p483)))

        if t9.AutoSteal then
            v1183((v1184()))

            if not u1116 then
                return
            end

            if (t9.Flight or t9.BypassSpeed) and true or (not not t9.AutoSteal or ((t9.AutoPlaceEggs or t9.AutoTreadmill) and true or (not not t9.AutoHatch or u1128 and t9.StealTravel == "Flight"))) then
                v1142()
                v1143()
                v1150(true)

                return
            end

            if next(t155) then
                v1150(false)
            end
        end
    end)
    v1238("StealSpeed", function(p484)
        v1102("engine", "steal speed", p484)
    end)
    v1238("StealMode", function(p485)
        v1102("steal", "pick", (tostring(p485)))

        if u66 then
            u69(u66, v250.Text)
        end
    end)
    v1238("BypassCap", function(p486)
        v1102("engine", "cap", p486)
    end)
    v1238("Flight", function(p487)
        warn("flight is " .. tostring(p487))

        if p487 then
            v1144()

            local Character24 = LocalPlayer.Character
            local v2590

            if not Character24 then
                v2590 = nil
            else
                local Humanoid = Character24:FindFirstChildOfClass("Humanoid")
                local HumanoidRootPart = Character24:FindFirstChild("HumanoidRootPart")

                v2590 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
            end

            local v2593 = v2590

            if v2593 then
                pcall(function()
                    local AssemblyLinearVelocity = v2593.AssemblyLinearVelocity

                    v2593.AssemblyLinearVelocity = Vector3.new(AssemblyLinearVelocity.X, 0, AssemblyLinearVelocity.Z)
                    v2593.AssemblyAngularVelocity = Vector3.zero
                end)
            end
        else
            local Character25 = LocalPlayer.Character
            local v2595, v2596

            if not Character25 then
                v2595 = nil
                v2596 = nil
            else
                v2595 = Character25:FindFirstChildOfClass("Humanoid")
                v2596 = Character25:FindFirstChild("HumanoidRootPart")

                if not v2595 or not v2596 or v2595.Health <= 0 then
                    v2595 = nil
                    v2596 = nil
                end
            end

            u1145 = false
            v1146(v2595, v2596, true)
        end

        v1183((v1184()))

        if not u1116 then
            return
        end

        if (t9.Flight or t9.BypassSpeed) and true or (t9.AutoSteal or ((t9.AutoPlaceEggs or t9.AutoTreadmill) and true or (t9.AutoHatch or u1128 and t9.StealTravel == "Flight"))) then
            v1142()
            v1143()
            v1150(true)

            return
        end

        if next(t155) then
            v1150(false)
        end
    end)
    v1238("FlightSpeed", function(p488)
        if t9.Flight then
            v1102("engine", "flight speed", p488)
        end
    end)
    v1238("EggESP", function()
        v1102("esp", "field", t9.EggESP)
    end)
    v1238("ESPFilter", function(p489)
        v1102("esp", "filter", (tostring(p489)))
    end)
    v1238("ESPBeam", function()
        v1102("esp", "beam", t9.ESPBeam)
    end)
    v1238("PlotESP", function()
        v1102("esp", "plot", t9.PlotESP)

        if u1134.bumpPlot then
            u1134.bumpPlot()
        end
    end)
    v1238("StatsPanel", function(p490)
        if u1134.stats then
            u1134.stats(p490)
        end

        v1102("esp", "stats panel", p490)
    end)
    v1238("ClaimIndex", function()
        if u1135 then
            u1135.sync()
        end
    end)
    v1238("AutoPlaceEggs", function()
        if u1135 then
            u1135.sync()
        end
    end)
    v1238("AutoHatch", function()
        if u1135 then
            u1135.sync()
        end
    end)
    v1238("EquipBest", function()
        if u1135 then
            u1135.sync()
        end
    end)
    v1238("UpgTrails", function()
        if u1135 then
            u1135.sync()
        end
    end)
    v1238("UpgTreadmill", function()
        if u1135 then
            u1135.sync()
        end
    end)
    v1238("UpgPen", function()
        if u1135 then
            u1135.sync()
        end
    end)
    v1238("AutoSellPets", function()
        if u1135 then
            u1135.sync()
        end
    end)
    v1238("AutoSellEggs", function()
        if u1135 then
            u1135.sync()
        end
    end)
    v1238("AutoTreadmill", function(p491)
        if u1135 then
            if not p491 and u1135.leave then
                u1135.leave()
            end

            u1135.sync()
        end
    end)
    v1238("AutoHop", function()
    end)
    v1238("HopNow", function()
        if u1230 and u1230.now then
            u1230.now()
        end
    end)
    v1238("SellPreview", function()
        if t11.open then
            t11.open()
        end
    end)
    function t11.open()
        t9.StatsPanel = true

        if t10.StatsPanel and t10.StatsPanel.set then
            pcall(t10.StatsPanel.set, true)
        end

        if u1134 and u1134.stats then
            pcall(u1134.stats, true)
        end

        if u1135 and u1135.queuePreview then
            local ok90, result86 = pcall(u1135.queuePreview)

            if not ok90 then
                local SellPreview = t10.SellPreview

                if SellPreview and SellPreview.status then
                    SellPreview.status.Text = "failed · " .. tostring(result86)
                end

                v1102("plot", "preview ERR", (tostring(result86)))
            end

            return
        end

        local SellPreview = t10.SellPreview

        if SellPreview and SellPreview.status then
            SellPreview.status.Text = "preview missing"
        end
    end
    v1238("HookTest", function()
        local HookTest = t10.HookTest

        if not u1195 or not u1195.test then
            if HookTest and HookTest.status then
                HookTest.status.Text = "missing"
            end

            return
        end

        if HookTest and HookTest.status then
            HookTest.status.Text = "sending…"
        end

        task.spawn(function()
            local v4577, v4578 = u1195.test()

            if HookTest and HookTest.status then
                HookTest.status.Text = if not v4577 then "fail · " .. tostring(v4578) else "sent"
            end

            v1102("hook", not v4577 and "test fail" or "test ok", (tostring(v4578)))
        end)
    end)
    v1238("Optimizer", function(p492)
        u1134.opt(p492)
        v1102("esp", "optimizer", p492)
    end)
    v1238("FPSCap", function(p493)
        u1134.fps()
        v1102("esp", "fps cap", p493)
    end)
    v1136(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end

        if t9.FlightBind and input.KeyCode == t9.FlightBind then
            local v2610 = not t9.Flight

            if t10.Flight and t10.Flight.set then
                t10.Flight.set(v2610)
            else
                t9.Flight = v2610
            end

            if t10.Flight and t10.Flight.on then
                t10.Flight.on(v2610)
            else
                v1183((v1184()))

                if u1116 then
                    if (t9.Flight or t9.BypassSpeed) and true or (not not t9.AutoSteal or ((t9.AutoPlaceEggs or t9.AutoTreadmill) and true or (not not t9.AutoHatch or u1128 and t9.StealTravel == "Flight"))) then
                        v1142()
                        v1143()
                        v1150(true)
                    elseif next(t155) then
                        v1150(false)
                    end
                end
            end

            if u265 then
                return
            end

            if u266 then
                return
            end

            u266 = true

            local v2611 = v268

            task.delay(0.35, function()
                u266 = false

                if v2611 ~= (v51().gen or 0) then
                    return
                end

                v272()
            end)
        end
    end));
    (function()
        local ok91, result87, _, _ = pcall(function()
            v1191()

            for _, descendant in ipairs(workspace:GetDescendants()) do
                if descendant:IsA("ProximityPrompt") then
                    v1188(descendant)
                end
            end
        end)

        if not ok91 then
            v1102("prompts", "ERR", "scan", (tostring(result87)))
        end

        local connection20 = workspace.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("ProximityPrompt") then
                task.defer(v1188, descendant)
            end
        end)

        if connection20 then
            t152[connection20] = true
        end

        local connection21 = ProximityPromptService.PromptButtonHoldBegan:Connect(function(p494)
            v1188(p494)

            if v1189(p494) and (t216 and t216.running and t9.AutoSteal) then
                if (t216.state == "GoEgg" or t216.state == "Grab") and t216.promptIsTarget and t216.promptIsTarget(p494, t216.target, 5) then
                    v1190(p494)
                end

                return
            end

            if v1185 then
                pcall(v1185, p494, 0)

                return
            end

            pcall(function()
                p494:InputHoldBegin()
                p494:InputHoldEnd()
            end)
        end)

        if connection21 then
            t152[connection21] = true
        end

        pcall(function()
            local connection22 = ProximityPromptService.PromptShown:Connect(function(prompt)
                u1187 = prompt
                v1188(prompt)

                if t216 and (t216.running and t9.AutoSteal and v1189(prompt) and t216.state == "Grab" and t216.promptIsTarget and t216.promptIsTarget(prompt, t216.target, 5)) then
                    v1190(prompt)
                end
            end)

            if connection22 then
                t152[connection22] = true
            end
        end)
        pcall(function()
            local connection23 = ProximityPromptService.PromptHidden:Connect(function(prompt)
                if prompt == u1187 then
                    u1187 = nil
                end
            end)

            if connection23 then
                t152[connection23] = true
            end
        end)
        v1102("prompts", "instant HoldDuration=0")
    end)();
    (function()
        v1183((v1184()))

        if not u1116 then
            return
        end

        if (t9.Flight or t9.BypassSpeed) and true or (not not t9.AutoSteal or ((t9.AutoPlaceEggs or t9.AutoTreadmill) and true or (not not t9.AutoHatch or u1128 and t9.StealTravel == "Flight"))) then
            v1142()
            v1143()
            v1150(true)

            return
        end

        if next(t155) then
            v1150(false)
        end
    end)()
    pcall(v280, true)
    if not u43 then
        u42 = t9.PhoneUI == true
    end
    if u44 then
        u44()
    end
    if t216.bat and t216.bat.setLive then
        t216.bat.setLive(t9.BatAura == true)
    end
    if u1135 and u1135.sync then
        u1135.sync()
    end
    local ok92, result88 = pcall(v1208)
    if not ok92 then
        v1102("modules", "sync fail", (tostring(result88)))
    end
    task.spawn(function()
        while u1117 do
            task.wait(20)

            if u1117 then
                pcall(v1208)
            end
        end
    end)
    if not u1130() then
        v1144()

        local v1241 = select(1, v1112())

        if v1241 then
            pcall(function()
                v1241.PlatformStand = false
            end)
        end
    end
    u1134.fps()
    if t9.Optimizer then
        u1134.opt(true)
    end
    local v1242 = u323
    function u323()
        u1117 = false

        local v2612 = v1237
        local ok93, result89, _, _ = pcall(v2612)

        if not ok93 then
            v1102("shutdown", "ERR", "stopSteal", (tostring(result89)))
        end

        local ok94, result90, _, _ = pcall(function()
            if t216 and t216.muteHazards then
                t216.muteHazards(false)
            end

            if t216 and t216.muteBelt then
                t216.muteBelt(false)
            end
        end)

        if not ok94 then
            v1102("shutdown", "ERR", "hazards", (tostring(result90)))
        end

        local ok95, result91, _, _ = pcall(function()
            if t216.bat and t216.bat.stop then
                t216.bat.stop()
            end
        end)

        if not ok95 then
            v1102("shutdown", "ERR", "bat", (tostring(result91)))
        end

        local ok96, result92, _, _ = pcall(function()
            if u1230 and u1230.stop then
                u1230.stop()
            end
        end)

        if not ok96 then
            v1102("shutdown", "ERR", "hop", (tostring(result92)))
        end

        local ok97, result93, _, _ = pcall(function()
            if u1135 and u1135.stop then
                u1135.stop()
            end
        end)

        if not ok97 then
            v1102("shutdown", "ERR", "plot", (tostring(result93)))
        end

        local ok98, result94, _, _ = pcall(function()
            v1183(false)
            v1150(false)
        end)

        if not ok98 then
            v1102("shutdown", "ERR", "engineOff", (tostring(result94)))
        end

        local ok99, result95, _, _ = pcall(function()
            for _, v in ipairs({
				"attrConn",
				"stConn",
				"hpConn"
			}) do
                local v4581 = t165[v]

                t165[v] = nil

                if v4581 then
                    pcall(function()
                        v4581:Disconnect()
                    end)
                end
            end
        end)

        if not ok99 then
            v1102("shutdown", "ERR", "antiMob", (tostring(result95)))
        end

        local v2641 = v1137
        local ok100, result96, _, _ = pcall(v2641)

        if not ok100 then
            v1102("shutdown", "ERR", "conns", (tostring(result96)))
        end

        local clear = u1134.clear
        local ok101, result97, _, _ = pcall(clear)

        if not ok101 then
            v1102("shutdown", "ERR", "esp", (tostring(result97)))
        end

        local ok103, result99, _, _ = pcall(function()
            local v4582 = v98 and v98.Parent
            local v4583 = v49

            if v4582 and type(v4583) == "string" then
                local v4584 = v4582:FindFirstChild(v4583)

                if v4584 then
                    v4584:Destroy()
                end
            end

            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            local v4586 = v49

            if PlayerGui and type(v4586) == "string" then
                local v4587 = PlayerGui:FindFirstChild(v4586)

                if v4587 then
                    v4587:Destroy()
                end
            end

            if PlayerGui then
                local NEXUSWorldGui = PlayerGui:FindFirstChild("NEXUSWorldGui")

                if NEXUSWorldGui then
                    NEXUSWorldGui:Destroy()
                end
            end

            if gethui then
                local ok102, result98 = pcall(gethui)

                if ok102 then
                    local v4591 = v49

                    if result98 then
                        if type(v4591) ~= "string" then
                            return
                        end

                        local v4592 = result98:FindFirstChild(v4591)

                        if v4592 then
                            v4592:Destroy()
                        end
                    end
                end
            end
        end)

        if not ok103 then
            v1102("shutdown", "ERR", "worldGui", (tostring(result99)))
        end

        local v2655 = v1144
        local ok104, result100, _, _ = pcall(v2655)

        if not ok104 then
            v1102("shutdown", "ERR", "ghost", (tostring(result100)))
        end

        local ok105, result101, _, _ = pcall(function()
            u1134.opt(false)
        end)

        if not ok105 then
            v1102("shutdown", "ERR", "opt", (tostring(result101)))
        end

        local ok106, result102, _, _ = pcall(function()
            v272(true)
        end)

        if not ok106 then
            v1102("shutdown", "ERR", "saveConfig", (tostring(result102)))
        end

        local v2668 = getgenv and getgenv() or _G
        local v2669 = v51()

        v2669.unload = nil
        v2669.alive = false
        v2669.dump = nil

        if type(v2668.NEXUSUI) == "table" then
            v2668.NEXUSUI[str] = nil
        end

        if type(v2668.NEXUSDumpByUser) == "table" then
            v2668.NEXUSDumpByUser[str] = nil
        end

        if v2668.UI == t149 then
            v2668.UI = nil
        end

        if v2668.NEXUSUnloadUid == str then
            v2668.NEXUSUnloadUid = nil
            v2668.NEXUSUnload = nil
        end

        v1242()
    end
    t149.Destroy = u323
    local v1243 = v50()
    local v1244 = v51()
    v1244.unload = u323
    v1244.alive = true
    v1243.NEXUSUnloadUid = str
    function v1243.NEXUSUnload()
        local LocalPlayer2 = Players.LocalPlayer
        local str42 = tostring(LocalPlayer2 and LocalPlayer2.UserId or 0)
        local NEXUSHUB = v1243.NEXUSHUB
        local v2673 = type(NEXUSHUB) == "table" and (type(NEXUSHUB.slots) == "table" and NEXUSHUB.slots[str42])

        if type(v2673) == "table" and type(v2673.unload) == "function" then
            v2673.unload()
        end
    end
    function t149.NEXUSDump()
        local Character26 = LocalPlayer.Character
        local v2675

        if not Character26 then
            v2675 = nil
        else
            local Humanoid = Character26:FindFirstChildOfClass("Humanoid")
            local HumanoidRootPart = Character26:FindFirstChild("HumanoidRootPart")

            v2675 = if not not Humanoid and (not not HumanoidRootPart and not (Humanoid.Health <= 0)) then HumanoidRootPart else nil
        end

        local t305 = {
			state = t216.state,
			travel = t9.StealTravel,
			stealSpeed = t9.StealSpeed,
			bypass = t9.BypassSpeed,
			cap = t9.BypassCap,
			engine = u1116,
			carrying = t216.carrying,
			trapped = u1157,
			trapEscaped = n14,
			stillFor = t216.stillFor,
			target = t216.target and t216.target.area .. " " .. t216.target.name or nil,
			pos = v2675 and {
				math.floor(v2675.Position.X),
				math.floor(v2675.Position.Y),
				math.floor(v2675.Position.Z)
			},
			wraps = t155 and next(t155) ~= nil,
			areas = t9.Areas,
			eggTypes = t9.EggTypes,
			stealMode = t9.StealMode,
			eggEsp = t9.EggESP,
			plotEsp = t9.PlotESP
		}
        local v2679 = v1228()
        local AreaEggCycleNightSeconds = workspace:GetAttribute("AreaEggCycleNightSeconds")

        if type(AreaEggCycleNightSeconds) ~= "number" then
            AreaEggCycleNightSeconds = 10
        end

        t305.night = v2679 <= math.clamp(AreaEggCycleNightSeconds, 1, 300)

        return t305
    end
    local v1245 = v50()
    v51().dump = t149.NEXUSDump
    v1245.NEXUSDumpByUser = type(v1245.NEXUSDumpByUser) == "table" and v1245.NEXUSDumpByUser or {}
    v1245.NEXUSDumpByUser[str] = t149.NEXUSDump
    function v1245.NEXUSDump(...)
        local LocalPlayer3 = Players.LocalPlayer
        local str43 = tostring(LocalPlayer3 and LocalPlayer3.UserId or 0)
        local v2683 = v1245.NEXUSDumpByUser and v1245.NEXUSDumpByUser[str43]

        if type(v2683) == "function" then
            return v2683(...)
        end
    end
    print("[UI] NEXUS Hub ready · RightShift toggles · Dark / Light in Settings")
    v1102("boot", "game logic attached · NEXUSDump() in F9")
end)()



--// ============================================================
--// NEXUS GUARDIAN BYPASS V6
--// Staged carry return + 12-stud standoff + 50 studs/s final approach
--// ============================================================
--// This layer mirrors the movement pattern visible in the supplied
--// reference video: two short carry hops, then a normal-speed final leg.
--// It keeps the existing server-state checks and does not fabricate
--// delivery success.
--// ============================================================

task.spawn(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local LocalPlayer = Players.LocalPlayer

    local function getChar()
        return LocalPlayer.Character
    end

    local function getRoot()
        local c = getChar()
        return c and c:FindFirstChild("HumanoidRootPart")
    end

    local function getHum()
        local c = getChar()
        return c and c:FindFirstChildOfClass("Humanoid")
    end

    local function getSafeZone()
        local spawn = workspace:FindFirstChild("Spawn")
        return spawn and spawn:FindFirstChild("SafeZone")
    end

    local function insidePart(part, pos, extra)
        if not part or not pos then return false end
        extra = extra or 0
        local lp = part.CFrame:PointToObjectSpace(pos)
        local half = part.Size * 0.5
        return math.abs(lp.X) <= half.X + extra
           and math.abs(lp.Y) <= half.Y + extra
           and math.abs(lp.Z) <= half.Z + extra
    end

    local function liveCarry()
        local ok, records = pcall(function()
            return type(v1204) == "function" and v1204() or nil
        end)
        if not ok or type(records) ~= "table" then
            return false, nil
        end
        for _, rec in ipairs(records) do
            if type(rec) == "table" and tonumber(rec.CarrierUserId) == LocalPlayer.UserId then
                return true, rec.Uid
            end
        end
        return false, nil
    end

    local function carrying()
        local c = getChar()
        if c and c:GetAttribute("SAE_Carrying") == true then
            return true, nil
        end
        return liveCarry()
    end

    local function keepResponsive()
        local c = getChar()
        local hum = getHum()
        if not c or not hum or t9.GuardianBypass == false then return end
        local active = select(1, carrying())
        if not active then return end

        pcall(function()
            hum.PlatformStand = false
            hum.Sit = false
            hum.AutoRotate = true
        end)
    end

    local lastUid
    local lastPhase = "idle"

    RunService.Heartbeat:Connect(function()
        if not t216 or not t216.running then return end

        local active, uid = carrying()
        local root = getRoot()
        local hum = getHum()
        local safe = getSafeZone()

        if not active or not root or not hum or not safe then
            return
        end

        lastUid = uid or lastUid

        if t216.state ~= "Return" and t216.state ~= "Bank" then
            return
        end

        keepResponsive()

        local finalRadius = math.clamp(tonumber(t9.FinalReturnRadius) or 20, 18, 30)
        local finalSpeed = math.clamp(tonumber(t9.FinalReturnSpeed) or 20, 16, 20)
        local burstSpeed = math.clamp(tonumber(t9.BypassCap) or 880, 150, 1300)
        local flat = Vector3.new(root.Position.X - safe.Position.X, 0, root.Position.Z - safe.Position.Z)
        local dist = flat.Magnitude

        if insidePart(safe, root.Position, 3.5) then
            lastPhase = "safe"
            pcall(function()
                root.AssemblyLinearVelocity = Vector3.zero
                hum.WalkSpeed = finalSpeed
                hum:Move(Vector3.zero, false)
            end)
            return
        end

        if t9.StagedReturn == false then
            lastPhase = "direct"
            return
        end

        if dist <= finalRadius + 1.25 then
            -- Final corridor: stay out of the SafeZone until the normal
            -- server-accepted approach. No teleport and no injected burst.
            lastPhase = "final"
            local dir = Vector3.new(safe.Position.X - root.Position.X, 0, safe.Position.Z - root.Position.Z)
            if dir.Magnitude > 0.05 then
                pcall(function()
                    hum.WalkSpeed = finalSpeed
                    hum.PlatformStand = false
                    hum:Move(dir.Unit, false)
                    root.AssemblyLinearVelocity = Vector3.new(dir.Unit.X * finalSpeed, 0, dir.Unit.Z * finalSpeed)
                end)
            end
        elseif (t216.returnRouteStage or 0) >= 3 then
            -- We are at the standoff point (10-15 studs). Keep the final
            -- approach at 50 studs/s instead of snapping into SafeZone.
            lastPhase = "standoff"
            local dir = Vector3.new(safe.Position.X - root.Position.X, 0, safe.Position.Z - root.Position.Z)
            if dir.Magnitude > 0.05 then
                pcall(function()
                    hum.WalkSpeed = finalSpeed
                    hum.PlatformStand = false
                    hum:Move(dir.Unit, false)
                    root.AssemblyLinearVelocity = Vector3.new(dir.Unit.X * finalSpeed, 0, dir.Unit.Z * finalSpeed)
                end)
            end
        elseif (t216.returnRouteStage or 0) == 2 then
            -- The main Return state will make the final 10-15 stud hop.
            lastPhase = "final-hop"
        elseif (t216.returnRouteStage or 0) == 1 then
            lastPhase = "hop2"
        else
            lastPhase = "hop1"
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.35)
        if t216 and t216.running then
            t216.returnRouteStage = 0
            t216.returnRouteLastHop = 0
            pcall(function() t216.adoptCarry() end)
        end
    end)

    _G.NEXUS_GuardianV6 = {
        IsCarrying = function()
            return select(1, carrying())
        end,
        InSafeZone = function()
            local safe, root = getSafeZone(), getRoot()
            return safe and root and insidePart(safe, root.Position, 3.5) or false
        end,
        CarryUid = function()
            return select(2, liveCarry())
        end,
        RouteStage = function()
            return t216 and (t216.returnRouteStage or 0) or 0
        end,
        Phase = function()
            return lastPhase
        end,
        LastUid = function()
            return lastUid
        end,
    }
end)
