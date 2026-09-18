-- STREAMING_CHUNK: Initializing master environment and cleanup
local successInit, errInit = pcall(function()
    if _G.NexusShooterCleanup then
        pcall(_G.NexusShooterCleanup)
    end

    local Cleanups = {}
    _G.NexusShooterCleanup = function()
        for _, item in ipairs(Cleanups) do
            pcall(function()
                if typeof(item) == "RBXScriptConnection" then
                    item:Disconnect()
                elseif typeof(item) == "Instance" then
                    item:Destroy()
                elseif type(item) == "function" then
                    item()
                end
            end)
        end
        pcall(function() game:GetService("RunService"):UnbindFromRenderStep("NexusAimEngine") end)
        pcall(function() game:GetService("RunService"):UnbindFromRenderStep("NexusESPEngine") end)
        table.clear(Cleanups)
    end

    -- STREAMING_CHUNK: Importing cloned and protected core Roblox services
    local function safeService(serviceName)
        local s = game:GetService(serviceName)
        return (cloneref and cloneref(s)) or s
    end

    local Players = safeService("Players")
    local RunService = safeService("RunService")
    local TweenService = safeService("TweenService")
    local UserInputService = safeService("UserInputService")
    local StatsService = safeService("Stats")
    local TeleportService = safeService("TeleportService")
    local HttpService = safeService("HttpService")

    local LocalPlayer = (cloneref and cloneref(Players.LocalPlayer)) or Players.LocalPlayer
    if not LocalPlayer then
        local startT = os.clock()
        repeat
            task.wait(0.1)
            LocalPlayer = Players.LocalPlayer
        until LocalPlayer or (os.clock() - startT > 3)
    end
    if not LocalPlayer then return end

    local Camera = workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera")

    -- STREAMING_CHUNK: Configuring default tactical settings
    local Config = {
        Aimbot = {
            Enabled = false,
            HitboxExpander = false,
            HitboxSize = 10,
            NoRecoil = true,
            Smoothness = 0.20,
            FOV = 150,
            DrawFOV = true,
            VisibilityCheck = true,
            TeamCheck = true,
            TargetPart = "Head"
        },
        ESP = {
            Enabled = false,
            Boxes = true,
            Skeleton = true,
            Snaplines = true,
            Names = true,
            Distance = true,
            HealthBar = true,
            TeamCheck = true,
            BoxColor = Color3.fromRGB(255, 45, 75),
            TracerColor = Color3.fromRGB(0, 235, 255),
            SkeletonColor = Color3.fromRGB(0, 255, 140)
        },
        Settings = {
            Watermark = true,
            RainbowFOV = false
        },
        ActiveTab = "AIMBOT"
    }

    local CurrentLang = "ru"
    local TG_LINK = "https://t.me/+qTcgFmViTe9jMzU6"

    -- STREAMING_CHUNK: Implementing config save and load system
    local ConfigFileName = "NexusSupremeConfig.json"

    local function saveConfig()
        local data = {
            Aimbot = Config.Aimbot,
            ESP = {
                Enabled = Config.ESP.Enabled,
                Boxes = Config.ESP.Boxes,
                Skeleton = Config.ESP.Skeleton,
                Snaplines = Config.ESP.Snaplines,
                Names = Config.ESP.Names,
                Distance = Config.ESP.Distance,
                HealthBar = Config.ESP.HealthBar,
                TeamCheck = Config.ESP.TeamCheck,
                BoxColor = {Config.ESP.BoxColor.R, Config.ESP.BoxColor.G, Config.ESP.BoxColor.B},
                TracerColor = {Config.ESP.TracerColor.R, Config.ESP.TracerColor.G, Config.ESP.TracerColor.B},
                SkeletonColor = {Config.ESP.SkeletonColor.R, Config.ESP.SkeletonColor.G, Config.ESP.SkeletonColor.B},
            },
            Settings = Config.Settings,
            Language = CurrentLang
        }
        local success, encoded = pcall(function()
            return HttpService:JSONEncode(data)
        end)
        if success and writefile then
            pcall(function()
                writefile(ConfigFileName, encoded)
            end)
        end
    end

    local function loadConfig()
        if readfile and isfile and isfile(ConfigFileName) then
            local success, decoded = pcall(function()
                return HttpService:JSONDecode(readfile(ConfigFileName))
            end)
            if success and decoded then
                if decoded.Aimbot then
                    for k, v in pairs(decoded.Aimbot) do
                        if Config.Aimbot[k] ~= nil then Config.Aimbot[k] = v end
                    end
                end
                if decoded.ESP then
                    for k, v in pairs(decoded.ESP) do
                        if k == "BoxColor" and type(v) == "table" then
                            Config.ESP.BoxColor = Color3.new(v[1], v[2], v[3])
                        elseif k == "TracerColor" and type(v) == "table" then
                            Config.ESP.TracerColor = Color3.new(v[1], v[2], v[3])
                        elseif k == "SkeletonColor" and type(v) == "table" then
                            Config.ESP.SkeletonColor = Color3.new(v[1], v[2], v[3])
                        elseif Config.ESP[k] ~= nil then
                            Config.ESP[k] = v
                        end
                    end
                end
                if decoded.Settings then
                    for k, v in pairs(decoded.Settings) do
                        if Config.Settings[k] ~= nil then Config.Settings[k] = v end
                    end
                end
                if decoded.Language then
                    CurrentLang = decoded.Language
                end
            end
        end
    end

    pcall(loadConfig)

    -- STREAMING_CHUNK: Setting up themes and color swatches
    local Themes = {
        CyberNeon = {
            Name = "Cyber Neon",
            Bg = Color3.fromRGB(11, 13, 20),
            HeaderBg = Color3.fromRGB(16, 19, 30),
            CardBg = Color3.fromRGB(19, 23, 36),
            Border = Color3.fromRGB(38, 48, 75),
            Accent = Color3.fromRGB(0, 230, 255),
            AccentSec = Color3.fromRGB(0, 255, 160),
            Text = Color3.fromRGB(255, 255, 255),
            Muted = Color3.fromRGB(145, 155, 185),
            TabActive = Color3.fromRGB(0, 185, 225),
            EnemyColor = Color3.fromRGB(255, 55, 80)
        },
        CrimsonBlood = {
            Name = "Crimson Blood",
            Bg = Color3.fromRGB(14, 10, 12),
            HeaderBg = Color3.fromRGB(22, 14, 17),
            CardBg = Color3.fromRGB(28, 17, 21),
            Border = Color3.fromRGB(70, 32, 40),
            Accent = Color3.fromRGB(255, 45, 75),
            AccentSec = Color3.fromRGB(255, 140, 0),
            Text = Color3.fromRGB(255, 255, 255),
            Muted = Color3.fromRGB(180, 140, 150),
            TabActive = Color3.fromRGB(210, 35, 65),
            EnemyColor = Color3.fromRGB(255, 40, 70)
        },
        PurpleVoid = {
            Name = "Purple Void",
            Bg = Color3.fromRGB(12, 10, 20),
            HeaderBg = Color3.fromRGB(18, 14, 30),
            CardBg = Color3.fromRGB(24, 18, 38),
            Border = Color3.fromRGB(60, 40, 95),
            Accent = Color3.fromRGB(175, 70, 255),
            AccentSec = Color3.fromRGB(240, 60, 220),
            Text = Color3.fromRGB(255, 255, 255),
            Muted = Color3.fromRGB(165, 145, 195),
            TabActive = Color3.fromRGB(150, 50, 230),
            EnemyColor = Color3.fromRGB(255, 70, 190)
        }
    }

    local CurrentTheme = Themes.CyberNeon
    local PaletteSwatches = {
        Color3.fromRGB(255, 45, 75),
        Color3.fromRGB(0, 235, 255),
        Color3.fromRGB(0, 255, 140),
        Color3.fromRGB(255, 220, 40),
        Color3.fromRGB(185, 75, 255),
        Color3.fromRGB(255, 255, 255)
    }

    -- STREAMING_CHUNK: Multi-language translations dictionary
    local Locales = {
        en = {
            hub_title = "NEXUS SUPREME | TACTICAL SHOOTER",
            mini_open = "OPEN MENU",
            tab_aim = "AIMBOT",
            tab_esp = "VISUALS",
            tab_status = "STATUS",
            tab_settings = "SETTINGS",
            aim_enable = "STICKY AIMBOT LOCK",
            aim_hitbox = "HEAD HITBOX EXPANDER",
            aim_hitbox_size = "HITBOX EXPANSION SIZE",
            aim_recoil = "NO RECOIL / STABILIZER",
            aim_smooth = "AIM SMOOTHNESS",
            aim_fov = "AIM FOV RADIUS",
            aim_vis = "WALL VISIBILITY CHECK",
            aim_team = "IGNORE TEAMMATES (AIMBOT)",
            aim_part = "TARGET BODY PART",
            aim_fov_circle = "DRAW FOV CIRCLE",
            part_head = "HEAD",
            part_torso = "TORSO",
            part_legs = "LEGS",
            esp_enable = "MASTER 2D VISUALS (ESP)",
            esp_boxes = "2D BOUNDING BOXES",
            esp_skeleton = "SKELETON ESP (BONES)",
            esp_lines = "SNAPLINES (TRACERS)",
            esp_names = "PLAYER NAMES",
            esp_dist = "DISTANCE DISPLAY",
            esp_health = "DYNAMIC HEALTH BAR",
            esp_team = "IGNORE TEAMMATES (ESP)",
            col_box = "BOX COLOR PALETTE",
            col_tracer = "TRACER COLOR PALETTE",
            col_skel = "SKELETON COLOR PALETTE",
            sec_user = "PLAYER PROFILE",
            sec_device = "DEVICE & HARDWARE TELEMETRY",
            sec_metrics = "PERFORMANCE METRICS",
            sec_target = "LOCKED TARGET TELEMETRY",
            metric_fps = "FRAME RATE",
            metric_ping = "NETWORK PING",
            metric_mem = "TOTAL MEMORY",
            dev_platform = "PLATFORM / OS",
            dev_res = "SCREEN RESOLUTION",
            dev_input = "PRIMARY INPUT",
            target_none = "NO ACTIVE LOCK",
            btn_copy_job = "COPY SERVER ID",
            btn_rejoin = "REJOIN SERVER",
            theme_title = "SELECT UI THEME",
            lang_title = "SELECT LANGUAGE",
            opt_watermark = "SCREEN HUD WATERMARK",
            opt_rainbow = "RGB RAINBOW FOV CIRCLE",
            btn_reset = "RESET DEFAULTS",
            btn_unload = "UNLOAD / SELF-DESTRUCT",
            btn_save_config = "SAVE CONFIG",
            btn_load_config = "LOAD CONFIG",
            tg_title = "JOIN TELEGRAM",
            tg_desc = "Get exclusive configs & script updates!",
            tg_btn = "COPY TG LINK",
            tg_copied = "COPIED TO CLIPBOARD!",
        },
        ru = {
            hub_title = "NEXUS SUPREME | РЁРЈРўР•Р  РҐРђР‘",
            mini_open = "РћРўРљР Р«РўР¬ РњР•РќР®",
            tab_aim = "РђРРњР‘РћРў",
            tab_esp = "Р’РР—РЈРђР›Р«",
            tab_status = "РЎРўРђРўРЈРЎ",
            tab_settings = "РќРђРЎРўР РћР™РљР",
            aim_enable = "Р›РРџРљРР™ РђРРњР‘РћРў",
            aim_hitbox = "Р РђРЎРЁРР Р•РќРР• РҐРРўР‘РћРљРЎРђ Р“РћР›РћР’Р«",
            aim_hitbox_size = "Р РђР—РњР•Р  РҐРРўР‘РћРљРЎРђ (РЎРўРђР”Р«)",
            aim_recoil = "РђРќРўР-РћРўР”РђР§Рђ (РЎРўРђР‘РР›РР—РђРўРћР )",
            aim_smooth = "РџР›РђР’РќРћРЎРўР¬ РќРђР’Р•Р”Р•РќРРЇ",
            aim_fov = "Р РђР”РРЈРЎ Р—РђРҐР’РђРўРђ (FOV)",
            aim_vis = "РџР РћР’Р•Р РљРђ РќРђ РЎРўР•РќР«",
            aim_team = "РР“РќРћР РР РћР’РђРўР¬ РЎРћР®Р—РќРРљРћР’ (РђРРњ)",
            aim_part = "Р—РћРќРђ РЎРўР Р•Р›Р¬Р‘Р«",
            aim_fov_circle = "Р РРЎРћР’РђРўР¬ РљР РЈР“ FOV",
            part_head = "Р“РћР›РћР’Рђ",
            part_torso = "РўР•Р›Рћ",
            part_legs = "РќРћР“Р",
            esp_enable = "Р“Р›РђР’РќР«Р™ ESP (Р’РҐ)",
            esp_boxes = "2D Р‘РћРљРЎР«",
            esp_skeleton = "РЎРљР•Р›Р•РўР« (РљРћРЎРўР)",
            esp_lines = "Р›РРќРР (TRACERS)",
            esp_names = "РќРРљРќР•Р™РњР« РР“Р РћРљРћР’",
            esp_dist = "Р”РРЎРўРђРќР¦РРЇ Р’ РњР•РўР РђРҐ",
            esp_health = "РџРћР›РћРЎРљРђ Р—Р”РћР РћР’Р¬РЇ",
            esp_team = "РР“РќРћР РР РћР’РђРўР¬ РЎРћР®Р—РќРРљРћР’ (ESP)",
            col_box = "Р¦Р’Р•Рў 2D Р‘РћРљРЎРћР’",
            col_tracer = "Р¦Р’Р•Рў Р›РРќРР™ (TRACERS)",
            col_skel = "Р¦Р’Р•Рў РЎРљР•Р›Р•РўРћР’",
            sec_user = "РџР РћР¤РР›Р¬ РР“Р РћРљРђ",
            sec_device = "РЈРЎРўР РћР™РЎРўР’Рћ Р РЎРРЎРўР•РњРђ",
            sec_metrics = "РџР РћРР—Р’РћР”РРўР•Р›Р¬РќРћРЎРўР¬",
            sec_target = "РўР•Р›Р•РњР•РўР РРЇ Р¦Р•Р›Р",
            metric_fps = "Р§РђРЎРўРћРўРђ FPS",
            metric_ping = "РџРРќР“ (PING)",
            metric_mem = "РџРђРњРЇРўР¬ RAM",
            dev_platform = "РџР›РђРўР¤РћР РњРђ",
            dev_res = "Р РђР—Р Р•РЁР•РќРР•",
            dev_input = "РўРРџ Р’Р’РћР”Рђ",
            target_none = "РќР•Рў Р—РђРҐР’РђРўРђ",
            btn_copy_job = "РЎРљРћРџРР РћР’РђРўР¬ JOB ID",
            btn_rejoin = "РџР•Р Р•Р—РђР™РўР РќРђ РЎР•Р Р’Р•Р ",
            theme_title = "Р¦Р’Р•РўРћР’РђРЇ РўР•РњРђ",
            lang_title = "РЇР—Р«Рљ РРќРўР•Р Р¤Р•Р™РЎРђ",
            opt_watermark = "HUD Р’РР”Р–Р•Рў РќРђ Р­РљР РђРќР•",
            opt_rainbow = "RGB Р РђР”РЈР–РќР«Р™ РљР РЈР“ FOV",
            btn_reset = "РЎР‘Р РћРЎ РќРђРЎРўР РћР•Рљ",
            btn_unload = "Р’Р«Р“Р РЈР—РРўР¬ РҐРђР‘",
            btn_save_config = "РЎРћРҐР РђРќРРўР¬ РљРћРќР¤РР“",
            btn_load_config = "Р—РђР“Р РЈР—РРўР¬ РљРћРќР¤РР“",
            tg_title = "РќРђРЁ РўР•Р›Р•Р“Р РђРњ",
            tg_desc = "РЎРІРµР¶РёРµ РєРѕРЅС„РёРіРё Рё РѕР±РЅРѕРІР»РµРЅРёСЏ СЃРєСЂРёРїС‚Р°!",
            tg_btn = "РЎРљРћРџРР РћР’РђРўР¬ РЎРЎР«Р›РљРЈ",
            tg_copied = "РЎРЎР«Р›РљРђ РЎРљРћРџРР РћР’РђРќРђ!",
        },
        es = {
            hub_title = "NEXUS SUPREME | DISPARADOR TГЃCTICO",
            mini_open = "ABRIR MENГљ",
            tab_aim = "AIMBOT",
            tab_esp = "VISUALES",
            tab_status = "ESTADO",
            tab_settings = "AJUSTES",
            aim_enable = "AIMBOT FIJO",
            aim_hitbox = "EXPANDIR HITBOX DE CABEZA",
            aim_hitbox_size = "TAMAГ‘O DEL HITBOX (STUDS)",
            aim_recoil = "SIN RETROCESO (ESTABLE)",
            aim_smooth = "SUAVIDAD DE APUNTADO",
            aim_fov = "RADIO DE FOV",
            aim_vis = "COMPROBAR VISIBILIDAD",
            aim_team = "IGNORAR COMPAГ‘EROS (AIM)",
            aim_part = "ZONA DE DISPARO",
            aim_fov_circle = "CГЌRCULO FOV VISIBLE",
            part_head = "CABEZA",
            part_torso = "TORSO",
            part_legs = "PIERNAS",
            esp_enable = "VISUALES 2D (ESP)",
            esp_boxes = "CAJAS 2D (BOXES)",
            esp_skeleton = "ESQUELETO (HUESOS)",
            esp_lines = "LГЌNEAS TRACERS",
            esp_names = "NOMBRES DE JUGADOR",
            esp_dist = "DISTANCIA EN METROS",
            esp_health = "BARRA DE SALUD DINГЃMICA",
            esp_team = "IGNORAR COMPAГ‘EROS (ESP)",
            col_box = "COLOR DE CAJAS",
            col_tracer = "COLOR DE LГЌNEAS",
            col_skel = "COLOR DE ESQUELETO",
            sec_user = "PERFIL DE USUARIO",
            sec_device = "DISPOSITIVO Y SISTEMA",
            sec_metrics = "RENDIMIENTO DEL CLIENTE",
            sec_target = "TELEMETRГЌA DEL OBJETIVO",
            metric_fps = "CUADROS FPS",
            metric_ping = "LATENCIA PING",
            metric_mem = "MEMORIA RAM",
            dev_platform = "PLATAFORMA",
            dev_res = "RESOLUCIГ“N",
            dev_input = "TIPO DE ENTRADA",
            target_none = "SIN OBJETIVO FIJADO",
            btn_copy_job = "COPIAR ID SERVIDOR",
            btn_rejoin = "RECONECTAR SERVIDOR",
            theme_title = "TEMA DE COLOR",
            lang_title = "IDIOMA DEL MENГљ",
            opt_watermark = "MARCA DE AGUA EN PANTALLA",
            opt_rainbow = "CГЌRCULO FOV ARCOГЌRIS",
            btn_reset = "RESTAURAR AJUSTES",
            btn_unload = "DESCARGAR SCRIPT",
            btn_save_config = "GUARDAR CONFIG",
            btn_load_config = "CARGAR CONFIG",
            tg_title = "ГљNETE A TELEGRAM",
            tg_desc = "ВЎConfigs exclusivas y actualizaciones!",
            tg_btn = "COPIAR ENLACE TG",
            tg_copied = "ВЎCOPIADO AL PORTAPAPELES!",
        }
    }

    local function L(key)
        local cur = Locales[CurrentLang] or Locales.en
        return (cur and cur[key]) or (Locales.en and Locales.en[key]) or key
    end

    -- Dynamic localization updaters registry
    local LangUpdaters = {}

    -- STREAMING_CHUNK: Robust team check and player validation
    local function isTeammate(p)
        if not p or p == LocalPlayer then return true end

        -- 1. Standard Roblox Team Instance
        if LocalPlayer.Team and p.Team then
            if not LocalPlayer.Neutral and not p.Neutral then
                if LocalPlayer.Team == p.Team then return true end
            end
        end

        -- 2. Standard Roblox TeamColor
        if LocalPlayer.TeamColor and p.TeamColor then
            if not LocalPlayer.Neutral and not p.Neutral then
                if LocalPlayer.TeamColor == p.TeamColor and LocalPlayer.TeamColor.Name ~= "White" and LocalPlayer.TeamColor.Name ~= "Medium stone grey" then
                    return true
                end
            end
        end

        -- 3. Custom attributes on Player or Character
        local myTeamAttr = LocalPlayer:GetAttribute("Team") or (LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Team"))
        local pTeamAttr = p:GetAttribute("Team") or (p.Character and p.Character:GetAttribute("Team"))
        if myTeamAttr ~= nil and pTeamAttr ~= nil then
            local t1 = tostring(myTeamAttr):lower()
            local t2 = tostring(pTeamAttr):lower()
            if t1 == t2 and t1 ~= "" and t1 ~= "0" and t1 ~= "ffa" and t1 ~= "none" then
                return true
            end
        end

        -- 4. Custom ValueObjects in Player or Character
        local myTeamVal = LocalPlayer:FindFirstChild("Team") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Team"))
        local pTeamVal = p:FindFirstChild("Team") or (p.Character and p.Character:FindFirstChild("Team"))
        if myTeamVal and pTeamVal and myTeamVal:IsA("ValueBase") and pTeamVal:IsA("ValueBase") then
            if myTeamVal.Value == pTeamVal.Value and tostring(myTeamVal.Value) ~= "" and tostring(myTeamVal.Value) ~= "0" then
                return true
            end
        end

        -- 5. Leaderstats team or role detection
        local myLs = LocalPlayer:FindFirstChild("leaderstats")
        local pLs = p:FindFirstChild("leaderstats")
        if myLs and pLs then
            local myRole = myLs:FindFirstChild("Team") or myLs:FindFirstChild("Role")
            local pRole = pLs:FindFirstChild("Team") or pLs:FindFirstChild("Role")
            if myRole and pRole and myRole.Value == pRole.Value and tostring(myRole.Value) ~= "" then
                return true
            end
        end

        return false
    end

    local function isAlivePlayer(p)
        if not p or p == LocalPlayer then return false end
        local char = p.Character
        if not char or not char:IsDescendantOf(workspace) then return false end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            if hum.Health <= 0 then return false end
            local st = hum:GetState()
            if st == Enum.HumanoidStateType.Dead or st == Enum.HumanoidStateType.Physics then return false end
        end
        if char:GetAttribute("Dead") == true or char:GetAttribute("IsDead") == true or char:GetAttribute("Killed") == true then
            return false
        end
        local head = char:FindFirstChild("Head") or char:FindFirstChild("FakeHead") or char:FindFirstChild("HeadHB")
        local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        if not head or not root then return false end
        if head.Transparency >= 0.95 and root.Transparency >= 0.95 then return false end
        return true
    end

    -- STREAMING_CHUNK: Detecting platform and hardware telemetry
    local function detectHardwareProfile()
        local platformName = "Desktop PC"
        pcall(function()
            local p = UserInputService:GetPlatform()
            if p == Enum.Platform.Android then
                platformName = "Android Mobile"
            elseif p == Enum.Platform.IOS then
                platformName = "Apple iOS"
            elseif p == Enum.Platform.Windows then
                platformName = "Windows PC"
            elseif p == Enum.Platform.OSX then
                platformName = "macOS"
            elseif p == Enum.Platform.UWP then
                platformName = "Windows UWP"
            elseif p == Enum.Platform.XBoxOne or p == Enum.Platform.PS4 then
                platformName = "Console"
            else
                if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
                    platformName = "Touch Mobile"
                elseif UserInputService.KeyboardEnabled then
                    platformName = "Desktop PC"
                end
            end
        end)

        local inputType = "Mouse + Keyboard"
        if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then
            inputType = "Touchscreen (Mobile)"
        elseif UserInputService.GamepadEnabled then
            inputType = "Gamepad Controller"
        end

        local vpSize = Camera and Camera.ViewportSize or Vector2.new(800, 600)
        local resStr = string.format("%d x %d", math.floor(vpSize.X), math.floor(vpSize.Y))
        return { Platform = platformName, Input = inputType, Resolution = resStr }
    end

    local DeviceInfo = detectHardwareProfile()

    -- STREAMING_CHUNK: Acquiring safe ScreenGui container
    local function getSafeContainer()
        local ok, h = pcall(function()
            if typeof(gethui) == "function" then return gethui() end
            return game:GetService("CoreGui")
        end)
        if ok and h then return h end
        return LocalPlayer:WaitForChild("PlayerGui", 4) or LocalPlayer:FindFirstChildOfClass("PlayerGui")
    end

    local ContainerGui = getSafeContainer()
    if not ContainerGui then return end

    local function addCorner(parent, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 10)
        c.Parent = parent
        return c
    end

    local function addStroke(parent, color, thickness)
        local s = Instance.new("UIStroke")
        s.Color = color or CurrentTheme.Border
        s.Thickness = thickness or 1.2
        s.Parent = parent
        return s
    end

    local function tween(inst, duration, props, style, dir)
        if not inst then return end
        local tw = TweenService:Create(
            inst,
            TweenInfo.new(duration or 0.25, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
            props
        )
        tw:Play()
        return tw
    end

    local function copyClipboard(text)
        local fn = setclipboard or toclipboard or (syn and syn.write_clipboard) or (Clipboard and Clipboard.set)
        if fn then
            pcall(fn, text)
            return true
        end
        return false
    end

    -- STREAMING_CHUNK: Creating root ScreenGui and canvases
    local RootScreen = Instance.new("ScreenGui")
    RootScreen.Name = "NexusSupremeShooter"
    RootScreen.ResetOnSpawn = false
    RootScreen.IgnoreGuiInset = true
    RootScreen.DisplayOrder = 99999
    RootScreen.Parent = ContainerGui
    table.insert(Cleanups, RootScreen)

    local ESPDrawContainer = Instance.new("Frame", RootScreen)
    ESPDrawContainer.Name = "ESPCanvas"
    ESPDrawContainer.Size = UDim2.fromScale(1, 1)
    ESPDrawContainer.BackgroundTransparency = 1
    ESPDrawContainer.BorderSizePixel = 0
    ESPDrawContainer.ZIndex = 5

    local FOVCircleFrame = Instance.new("Frame", RootScreen)
    FOVCircleFrame.Name = "FOVCircle"
    FOVCircleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    FOVCircleFrame.Position = UDim2.fromScale(0.5, 0.5)
    FOVCircleFrame.Size = UDim2.fromOffset(Config.Aimbot.FOV * 2, Config.Aimbot.FOV * 2)
    FOVCircleFrame.BackgroundTransparency = 1
    FOVCircleFrame.Visible = false
    FOVCircleFrame.ZIndex = 8
    addCorner(FOVCircleFrame, 999)
    local FOVStroke = addStroke(FOVCircleFrame, CurrentTheme.Accent, 1.4)

    local WatermarkFrame = Instance.new("Frame", RootScreen)
    WatermarkFrame.Name = "WatermarkHUD"
    WatermarkFrame.Size = UDim2.fromOffset(180, 24)
    WatermarkFrame.Position = UDim2.new(1, -190, 0, 16)
    WatermarkFrame.BackgroundColor3 = CurrentTheme.HeaderBg
    WatermarkFrame.BorderSizePixel = 0
    WatermarkFrame.Visible = Config.Settings.Watermark
    WatermarkFrame.ZIndex = 90
    addCorner(WatermarkFrame, 6)
    addStroke(WatermarkFrame, CurrentTheme.Border, 1)

    local WatermarkTxt = Instance.new("TextLabel", WatermarkFrame)
    WatermarkTxt.Size = UDim2.fromScale(1, 1)
    WatermarkTxt.BackgroundTransparency = 1
    WatermarkTxt.Font = Enum.Font.GothamBlack
    WatermarkTxt.Text = "NEXUS | 60 FPS | 35ms"
    WatermarkTxt.TextSize = 8.5
    WatermarkTxt.TextColor3 = CurrentTheme.Accent
    WatermarkTxt.ZIndex = 91

    -- STREAMING_CHUNK: Constructing Telegram notification prompt
    local TgCard = Instance.new("Frame", RootScreen)
    TgCard.Name = "TelegramPrompt"
    TgCard.Size = UDim2.fromOffset(260, 100)
    TgCard.Position = UDim2.new(1, 300, 0, 50)
    TgCard.BackgroundColor3 = CurrentTheme.HeaderBg
    TgCard.BorderSizePixel = 0
    TgCard.ZIndex = 200
    addCorner(TgCard, 12)
    addStroke(TgCard, CurrentTheme.Accent, 1.5)

    local TgGlow = Instance.new("Frame", TgCard)
    TgGlow.Size = UDim2.new(1, -12, 0, 2)
    TgGlow.Position = UDim2.fromOffset(6, 0)
    TgGlow.BackgroundColor3 = CurrentTheme.AccentSec
    TgGlow.BorderSizePixel = 0
    TgGlow.ZIndex = 201
    addCorner(TgGlow, 2)

    local TgTitle = Instance.new("TextLabel", TgCard)
    TgTitle.Size = UDim2.new(1, -40, 0, 18)
    TgTitle.Position = UDim2.fromOffset(12, 10)
    TgTitle.BackgroundTransparency = 1
    TgTitle.Font = Enum.Font.GothamBlack
    TgTitle.Text = L("tg_title")
    TgTitle.TextSize = 10.5
    TgTitle.TextColor3 = CurrentTheme.Text
    TgTitle.TextXAlignment = Enum.TextXAlignment.Left
    TgTitle.ZIndex = 202

    local TgClose = Instance.new("TextButton", TgCard)
    TgClose.Size = UDim2.fromOffset(20, 20)
    TgClose.Position = UDim2.new(1, -26, 0, 10)
    TgClose.BackgroundTransparency = 1
    TgClose.Font = Enum.Font.GothamBold
    TgClose.Text = "вњ•"
    TgClose.TextSize = 11
    TgClose.TextColor3 = CurrentTheme.Muted
    TgClose.ZIndex = 203

    local TgDesc = Instance.new("TextLabel", TgCard)
    TgDesc.Size = UDim2.new(1, -24, 0, 26)
    TgDesc.Position = UDim2.fromOffset(12, 30)
    TgDesc.BackgroundTransparency = 1
    TgDesc.Font = Enum.Font.GothamMedium
    TgDesc.Text = L("tg_desc")
    TgDesc.TextSize = 8.5
    TgDesc.TextColor3 = CurrentTheme.Muted
    TgDesc.TextXAlignment = Enum.TextXAlignment.Left
    TgDesc.TextWrapped = true
    TgDesc.ZIndex = 202

    local TgCopyBtn = Instance.new("TextButton", TgCard)
    TgCopyBtn.Size = UDim2.new(1, -24, 0, 28)
    TgCopyBtn.Position = UDim2.fromOffset(12, 62)
    TgCopyBtn.BackgroundColor3 = CurrentTheme.Accent
    TgCopyBtn.BorderSizePixel = 0
    TgCopyBtn.Font = Enum.Font.GothamBlack
    TgCopyBtn.Text = L("tg_btn")
    TgCopyBtn.TextSize = 9
    TgCopyBtn.TextColor3 = Color3.fromRGB(15, 15, 20)
    TgCopyBtn.ZIndex = 202
    addCorner(TgCopyBtn, 7)

    table.insert(LangUpdaters, function()
        TgTitle.Text = L("tg_title")
        TgDesc.Text = L("tg_desc")
        TgCopyBtn.Text = L("tg_btn")
    end)

    tween(TgCard, 0.55, {Position = UDim2.new(1, -280, 0, 50)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    TgCopyBtn.Activated:Connect(function()
        copyClipboard(TG_LINK)
        TgCopyBtn.Text = L("tg_copied")
        TgCopyBtn.BackgroundColor3 = CurrentTheme.AccentSec
        task.delay(2.2, function()
            if TgCopyBtn.Parent then
                TgCopyBtn.Text = L("tg_btn")
                TgCopyBtn.BackgroundColor3 = CurrentTheme.Accent
            end
        end)
    end)

    TgClose.Activated:Connect(function()
        tween(TgCard, 0.3, {Position = UDim2.new(1, 300, 0, 50)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.delay(0.32, function()
            if TgCard.Parent then TgCard:Destroy() end
        end)
    end)

    -- STREAMING_CHUNK: Building floating mobile open pill
    local MiniPill = Instance.new("Frame", RootScreen)
    MiniPill.Name = "MiniPill"
    MiniPill.Size = UDim2.fromOffset(130, 36)
    MiniPill.Position = UDim2.new(0.5, -65, 0, 16)
    MiniPill.BackgroundColor3 = CurrentTheme.HeaderBg
    MiniPill.BorderSizePixel = 0
    MiniPill.Visible = false
    MiniPill.Active = true
    MiniPill.ZIndex = 100
    addCorner(MiniPill, 18)

    local PillStroke = addStroke(MiniPill, CurrentTheme.Accent, 1.3)
    local PillDot = Instance.new("Frame", MiniPill)
    PillDot.Size = UDim2.fromOffset(8, 8)
    PillDot.Position = UDim2.fromOffset(10, 14)
    PillDot.BackgroundColor3 = CurrentTheme.AccentSec
    PillDot.BorderSizePixel = 0
    PillDot.ZIndex = 101
    addCorner(PillDot, 99)

    local PillLabel = Instance.new("TextLabel", MiniPill)
    PillLabel.Size = UDim2.new(1, -28, 1, 0)
    PillLabel.Position = UDim2.fromOffset(26, 0)
    PillLabel.BackgroundTransparency = 1
    PillLabel.Font = Enum.Font.GothamBlack
    PillLabel.Text = L("mini_open")
    PillLabel.TextSize = 8.5
    PillLabel.TextColor3 = CurrentTheme.Text
    PillLabel.TextXAlignment = Enum.TextXAlignment.Left
    PillLabel.ZIndex = 101

    table.insert(LangUpdaters, function()
        PillLabel.Text = L("mini_open")
    end)

    local PillBtn = Instance.new("TextButton", MiniPill)
    PillBtn.Size = UDim2.fromScale(1, 1)
    PillBtn.BackgroundTransparency = 1
    PillBtn.Text = ""
    PillBtn.ZIndex = 105

    -- STREAMING_CHUNK: Designing main responsive window
    local vp = Camera and Camera.ViewportSize or Vector2.new(800, 450)
    local winW = math.clamp(math.floor(vp.X * 0.88), 470, 560)
    local winH = math.clamp(math.floor(vp.Y * 0.86), 310, 365)

    local MainFrame = Instance.new("Frame", RootScreen)
    MainFrame.Name = "MainFrame"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.Size = UDim2.fromOffset(winW, winH)
    MainFrame.BackgroundColor3 = CurrentTheme.Bg
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.ZIndex = 10
    addCorner(MainFrame, 14)

    local MainStroke = addStroke(MainFrame, CurrentTheme.Accent, 1.4)
    local TopNeon = Instance.new("Frame", MainFrame)
    TopNeon.Size = UDim2.new(1, 0, 0, 3)
    TopNeon.BackgroundColor3 = CurrentTheme.Accent
    TopNeon.BorderSizePixel = 0
    TopNeon.ZIndex = 11

    local isDragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    local function toggleMenu(show)
        if show then
            MiniPill.Visible = false
            MainFrame.Visible = true
            MainFrame.Size = UDim2.fromOffset(120, 90)
            MainFrame.Position = UDim2.fromScale(0.5, 0.52)
            tween(MainFrame, 0.30, {Size = UDim2.fromOffset(winW, winH), Position = UDim2.fromScale(0.5, 0.5)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            tween(MainFrame, 0.20, {Size = UDim2.fromOffset(120, 90), Position = UDim2.fromScale(0.5, 0.53)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            task.delay(0.19, function()
                MainFrame.Visible = false
                MiniPill.Visible = true
            end)
        end
    end

    local isPillDragging = false
    local pillDragStart = Vector2.zero
    local pillStartPos = UDim2.new()
    local hasPillMoved = false

    PillBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isPillDragging = true
            hasPillMoved = false
            pillDragStart = Vector2.new(input.Position.X, input.Position.Y)
            pillStartPos = MiniPill.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isPillDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - pillDragStart
            if delta.Magnitude > 7 then hasPillMoved = true end
            local newX = pillStartPos.X.Offset + delta.X
            local newY = pillStartPos.Y.Offset + delta.Y
            local curVp = Camera and Camera.ViewportSize or Vector2.new(800, 600)
            MiniPill.Position = UDim2.new(
                pillStartPos.X.Scale, math.clamp(newX, -(curVp.X * 0.5) + 70, (curVp.X * 0.5) - 70),
                pillStartPos.Y.Scale, math.clamp(newY, 10, curVp.Y - 50)
            )
        end
    end)
    local function finishPillDrag(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if isPillDragging then
                isPillDragging = false
                if not hasPillMoved then toggleMenu(true) end
            end
        end
    end
    PillBtn.InputEnded:Connect(finishPillDrag)
    UserInputService.InputEnded:Connect(finishPillDrag)

    -- STREAMING_CHUNK: Assembling header components and brand logo
    local Header = Instance.new("Frame", MainFrame)
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundColor3 = CurrentTheme.HeaderBg
    Header.BorderSizePixel = 0
    Header.ZIndex = 12

    local LogoBadge = Instance.new("Frame", Header)
    LogoBadge.Size = UDim2.fromOffset(26, 26)
    LogoBadge.Position = UDim2.fromOffset(10, 8)
    LogoBadge.BackgroundColor3 = CurrentTheme.CardBg
    LogoBadge.BorderSizePixel = 0
    LogoBadge.ZIndex = 13
    addCorner(LogoBadge, 7)
    addStroke(LogoBadge, CurrentTheme.Accent, 1)

    local LogoTxt = Instance.new("TextLabel", LogoBadge)
    LogoTxt.Size = UDim2.fromScale(1, 1)
    LogoTxt.BackgroundTransparency = 1
    LogoTxt.Font = Enum.Font.GothamBlack
    LogoTxt.Text = "N"
    LogoTxt.TextSize = 13
    LogoTxt.TextColor3 = CurrentTheme.Accent
    LogoTxt.ZIndex = 14

    local TitleLabel = Instance.new("TextLabel", Header)
    TitleLabel.Size = UDim2.new(1, -90, 1, 0)
    TitleLabel.Position = UDim2.fromOffset(44, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBlack
    TitleLabel.Text = L("hub_title")
    TitleLabel.TextSize = 11
    TitleLabel.TextColor3 = CurrentTheme.Text
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 13

    table.insert(LangUpdaters, function()
        TitleLabel.Text = L("hub_title")
    end)

    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.fromOffset(26, 26)
    CloseBtn.Position = UDim2.new(1, -34, 0.5, -13)
    CloseBtn.BackgroundColor3 = CurrentTheme.CardBg
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "вЂ”"
    CloseBtn.TextSize = 14
    CloseBtn.TextColor3 = CurrentTheme.Muted
    CloseBtn.ZIndex = 14
    addCorner(CloseBtn, 7)
    addStroke(CloseBtn, CurrentTheme.Border, 1)
    CloseBtn.Activated:Connect(function() toggleMenu(false) end)

    -- STREAMING_CHUNK: Setting up navigation tabs and page containers
    local TabBar = Instance.new("Frame", MainFrame)
    TabBar.Size = UDim2.new(1, -20, 0, 32)
    TabBar.Position = UDim2.fromOffset(10, 48)
    TabBar.BackgroundTransparency = 1
    TabBar.ZIndex = 15

    local TabListLayout = Instance.new("UIListLayout", TabBar)
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.Padding = UDim.new(0, 8)

    local TabButtons = {}
    local TabPages = {}

    local PagesContainer = Instance.new("Frame", MainFrame)
    PagesContainer.Size = UDim2.new(1, -20, 1, -90)
    PagesContainer.Position = UDim2.fromOffset(10, 84)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.ZIndex = 15

    local function createTabPage(tabId)
        local page = Instance.new("ScrollingFrame", PagesContainer)
        page.Name = tabId .. "Page"
        page.Size = UDim2.fromScale(1, 1)
        page.BackgroundTransparency = 1
        page.CanvasSize = UDim2.fromOffset(0, 940)
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = CurrentTheme.Accent
        page.Visible = (Config.ActiveTab == tabId)
        page.ZIndex = 16

        local layout = Instance.new("UIListLayout", page)
        layout.Padding = UDim.new(0, 8)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        TabPages[tabId] = page
        return page
    end

    local function switchTab(tabId)
        Config.ActiveTab = tabId
        for id, page in pairs(TabPages) do
            page.Visible = (id == tabId)
        end
        for id, btn in pairs(TabButtons) do
            if id == tabId then
                tween(btn, 0.18, {BackgroundColor3 = CurrentTheme.TabActive})
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                tween(btn, 0.18, {BackgroundColor3 = CurrentTheme.CardBg})
                btn.TextColor3 = CurrentTheme.Muted
            end
        end
    end

    local tabListKeys = {"tab_aim", "tab_esp", "tab_status", "tab_settings"}
    local tabInternal = {"AIMBOT", "VISUALS", "STATUS", "SETTINGS"}

    for idx, internalName in ipairs(tabInternal) do
        local key = tabListKeys[idx]
        local btn = Instance.new("TextButton", TabBar)
        btn.Size = UDim2.new(0.24, -4, 1, 0)
        btn.BackgroundColor3 = (Config.ActiveTab == internalName) and CurrentTheme.TabActive or CurrentTheme.CardBg
        btn.Font = Enum.Font.GothamBold
        btn.Text = L(key)
        btn.TextSize = 9.5
        btn.TextColor3 = (Config.ActiveTab == internalName) and Color3.fromRGB(255, 255, 255) or CurrentTheme.Muted
        btn.ZIndex = 16
        addCorner(btn, 8)
        addStroke(btn, CurrentTheme.Border, 1)
        btn.Activated:Connect(function() switchTab(internalName) end)
        TabButtons[internalName] = btn
        createTabPage(internalName)

        table.insert(LangUpdaters, function()
            btn.Text = L(key)
        end)
    end

    -- STREAMING_CHUNK: Creating interactive UI controls with auto-updating localization
    local function createToggle(parent, titleKey, defaultState, callback)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, -6, 0, 38)
        frame.BackgroundColor3 = CurrentTheme.CardBg
        frame.BorderSizePixel = 0
        frame.ZIndex = 17
        addCorner(frame, 9)
        local stroke = addStroke(frame, CurrentTheme.Border, 1)

        local title = Instance.new("TextLabel", frame)
        title.Size = UDim2.new(1, -80, 1, 0)
        title.Position = UDim2.fromOffset(12, 0)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.Text = L(titleKey)
        title.TextSize = 9.5
        title.TextColor3 = CurrentTheme.Text
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 18

        table.insert(LangUpdaters, function()
            title.Text = L(titleKey)
        end)

        local pill = Instance.new("Frame", frame)
        pill.Size = UDim2.fromOffset(46, 22)
        pill.Position = UDim2.new(1, -56, 0.5, -11)
        pill.BackgroundColor3 = defaultState and CurrentTheme.AccentSec or CurrentTheme.HeaderBg
        pill.BorderSizePixel = 0
        pill.ZIndex = 18
        addCorner(pill, 11)

        local switchCircle = Instance.new("Frame", pill)
        switchCircle.Size = UDim2.fromOffset(16, 16)
        switchCircle.Position = defaultState and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        switchCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        switchCircle.BorderSizePixel = 0
        switchCircle.ZIndex = 19
        addCorner(switchCircle, 99)

        local state = defaultState
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.fromScale(1, 1)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 20

        btn.Activated:Connect(function()
            state = not state
            if state then
                tween(pill, 0.18, {BackgroundColor3 = CurrentTheme.AccentSec})
                tween(switchCircle, 0.18, {Position = UDim2.new(1, -19, 0.5, -8)})
            else
                tween(pill, 0.18, {BackgroundColor3 = CurrentTheme.HeaderBg})
                tween(switchCircle, 0.18, {Position = UDim2.new(0, 3, 0.5, -8)})
            end
            pcall(callback, state)
        end)

        return {
            Frame = frame,
            Title = title,
            Stroke = stroke,
            SetState = function(s)
                state = s
                if state then
                    pill.BackgroundColor3 = CurrentTheme.AccentSec
                    switchCircle.Position = UDim2.new(1, -19, 0.5, -8)
                else
                    pill.BackgroundColor3 = CurrentTheme.HeaderBg
                    switchCircle.Position = UDim2.new(0, 3, 0.5, -8)
                end
            end
        }
    end

    local function createSlider(parent, titleKey, minVal, maxVal, defaultVal, callback)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, -6, 0, 50)
        frame.BackgroundColor3 = CurrentTheme.CardBg
        frame.BorderSizePixel = 0
        frame.ZIndex = 17
        addCorner(frame, 9)
        local stroke = addStroke(frame, CurrentTheme.Border, 1)

        local title = Instance.new("TextLabel", frame)
        title.Size = UDim2.new(1, -70, 0, 20)
        title.Position = UDim2.fromOffset(12, 6)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.Text = L(titleKey)
        title.TextSize = 9.5
        title.TextColor3 = CurrentTheme.Text
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 18

        table.insert(LangUpdaters, function()
            title.Text = L(titleKey)
        end)

        local valLabel = Instance.new("TextLabel", frame)
        valLabel.Size = UDim2.new(0, 50, 0, 20)
        valLabel.Position = UDim2.new(1, -60, 0, 6)
        valLabel.BackgroundTransparency = 1
        valLabel.Font = Enum.Font.GothamBlack
        valLabel.Text = tostring(defaultVal)
        valLabel.TextSize = 9.5
        valLabel.TextColor3 = CurrentTheme.Accent
        valLabel.TextXAlignment = Enum.TextXAlignment.Right
        valLabel.ZIndex = 18

        local bar = Instance.new("Frame", frame)
        bar.Size = UDim2.new(1, -24, 0, 6)
        bar.Position = UDim2.new(0, 12, 0, 34)
        bar.BackgroundColor3 = CurrentTheme.HeaderBg
        bar.BorderSizePixel = 0
        bar.ZIndex = 18
        addCorner(bar, 3)

        local fill = Instance.new("Frame", bar)
        local startRatio = (defaultVal - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(math.clamp(startRatio, 0, 1), 0, 1, 0)
        fill.BackgroundColor3 = CurrentTheme.Accent
        fill.BorderSizePixel = 0
        fill.ZIndex = 19
        addCorner(fill, 3)

        local hit = Instance.new("TextButton", bar)
        hit.Size = UDim2.new(1, 20, 1, 20)
        hit.Position = UDim2.fromOffset(-10, -10)
        hit.BackgroundTransparency = 1
        hit.Text = ""
        hit.ZIndex = 20

        local draggingSlider = false
        local function update(input)
            local ratio = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local value = math.floor(minVal + (maxVal - minVal) * ratio)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            valLabel.Text = tostring(value)
            pcall(callback, value)
        end

        hit.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = true
                update(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                draggingSlider = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end)

        return { Frame = frame, Title = title, Stroke = stroke, ValLabel = valLabel }
    end

    local function createColorPicker(parent, titleKey, initialColor, callback)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, -6, 0, 52)
        frame.BackgroundColor3 = CurrentTheme.CardBg
        frame.BorderSizePixel = 0
        frame.ZIndex = 17
        addCorner(frame, 9)
        local stroke = addStroke(frame, CurrentTheme.Border, 1)

        local title = Instance.new("TextLabel", frame)
        title.Size = UDim2.new(0.48, 0, 1, 0)
        title.Position = UDim2.fromOffset(12, 0)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.Text = L(titleKey)
        title.TextSize = 8.5
        title.TextColor3 = CurrentTheme.Text
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.ZIndex = 18

        table.insert(LangUpdaters, function()
            title.Text = L(titleKey)
        end)

        local swatchesHolder = Instance.new("Frame", frame)
        swatchesHolder.Size = UDim2.new(0.50, -10, 0, 24)
        swatchesHolder.Position = UDim2.new(0.50, 4, 0.5, -12)
        swatchesHolder.BackgroundTransparency = 1
        swatchesHolder.ZIndex = 18

        local listLayout = Instance.new("UIListLayout", swatchesHolder)
        listLayout.FillDirection = Enum.FillDirection.Horizontal
        listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
        listLayout.Padding = UDim.new(0, 6)

        local swatchButtons = {}
        for _, col in ipairs(PaletteSwatches) do
            local dot = Instance.new("TextButton", swatchesHolder)
            dot.Size = UDim2.fromOffset(20, 20)
            dot.BackgroundColor3 = col
            dot.Text = ""
            dot.BorderSizePixel = 0
            dot.ZIndex = 19
            addCorner(dot, 99)
            local dStroke = addStroke(dot, (col == initialColor) and Color3.fromRGB(255, 255, 255) or CurrentTheme.Border, (col == initialColor) and 1.6 or 0.8)

            dot.Activated:Connect(function()
                for _, info in ipairs(swatchButtons) do
                    info.Stroke.Color = CurrentTheme.Border
                    info.Stroke.Thickness = 0.8
                end
                dStroke.Color = Color3.fromRGB(255, 255, 255)
                dStroke.Thickness = 1.6
                pcall(callback, col)
            end)
            table.insert(swatchButtons, { Button = dot, Stroke = dStroke, Color = col })
        end

        return { Frame = frame, Title = title, Stroke = stroke }
    end

    -- STREAMING_CHUNK: Head hitbox expander with team filter
    local OriginalHeadData = {}
    local function restoreAllHitboxes()
        for player, data in pairs(OriginalHeadData) do
            pcall(function()
                if player.Character and player.Character:FindFirstChild("Head") then
                    local head = player.Character.Head
                    head.Size = data.Size or Vector3.new(2, 1, 1)
                    head.Transparency = data.Transparency or 0
                    head.Material = data.Material or Enum.Material.SmoothPlastic
                    head.CanCollide = false
                end
            end)
        end
        table.clear(OriginalHeadData)
    end
    table.insert(Cleanups, function() restoreAllHitboxes() end)
    Players.PlayerRemoving:Connect(function(player) OriginalHeadData[player] = nil end)

    table.insert(Cleanups, RunService.RenderStepped:Connect(function()
        if not Config.Aimbot.HitboxExpander then return end
        local targetSize = Vector3.new(Config.Aimbot.HitboxSize, Config.Aimbot.HitboxSize, Config.Aimbot.HitboxSize)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local sameTeam = isTeammate(player)
                local alive = isAlivePlayer(player)
                local head = player.Character:FindFirstChild("Head")
                if alive and head and head:IsA("BasePart") and not (Config.Aimbot.TeamCheck and sameTeam) then
                    pcall(function()
                        if not OriginalHeadData[player] then
                            OriginalHeadData[player] = { Size = head.Size, Transparency = head.Transparency, Material = head.Material }
                        end
                        head.Size = targetSize
                        head.Transparency = 0.55
                        head.Material = Enum.Material.Neon
                        head.Color = CurrentTheme.Accent
                        head.CanCollide = false
                        head.Massless = true
                    end)
                elseif head and OriginalHeadData[player] and (not alive or (Config.Aimbot.TeamCheck and sameTeam)) then
                    pcall(function()
                        local data = OriginalHeadData[player]
                        head.Size = data.Size or Vector3.new(2, 1, 1)
                        head.Transparency = data.Transparency or 0
                        head.Material = data.Material or Enum.Material.SmoothPlastic
                        head.CanCollide = false
                        OriginalHeadData[player] = nil
                    end)
                end
            end
        end
    end))

    -- STREAMING_CHUNK: Populating Aimbot tab options
    local aimPage = TabPages["AIMBOT"]
    createToggle(aimPage, "aim_hitbox", Config.Aimbot.HitboxExpander, function(state)
        Config.Aimbot.HitboxExpander = state
        if not state then restoreAllHitboxes() end
    end)
    createSlider(aimPage, "aim_hitbox_size", 2, 25, Config.Aimbot.HitboxSize, function(val)
        Config.Aimbot.HitboxSize = val
    end)
    createToggle(aimPage, "aim_enable", Config.Aimbot.Enabled, function(state)
        Config.Aimbot.Enabled = state
    end)
    createToggle(aimPage, "aim_recoil", Config.Aimbot.NoRecoil, function(state)
        Config.Aimbot.NoRecoil = state
    end)
    createSlider(aimPage, "aim_smooth", 1, 100, math.floor(Config.Aimbot.Smoothness * 100), function(val)
        Config.Aimbot.Smoothness = val / 100
    end)
    createSlider(aimPage, "aim_fov", 30, 450, Config.Aimbot.FOV, function(val)
        Config.Aimbot.FOV = val
        FOVCircleFrame.Size = UDim2.fromOffset(val * 2, val * 2)
    end)
    createToggle(aimPage, "aim_fov_circle", Config.Aimbot.DrawFOV, function(state)
        Config.Aimbot.DrawFOV = state
        FOVCircleFrame.Visible = state
    end)
    createToggle(aimPage, "aim_vis", Config.Aimbot.VisibilityCheck, function(state)
        Config.Aimbot.VisibilityCheck = state
    end)
    createToggle(aimPage, "aim_team", Config.Aimbot.TeamCheck, function(state)
        Config.Aimbot.TeamCheck = state
        if not state then restoreAllHitboxes() end
    end)

    local boneFrame = Instance.new("Frame", aimPage)
    boneFrame.Size = UDim2.new(1, -6, 0, 38)
    boneFrame.BackgroundColor3 = CurrentTheme.CardBg
    boneFrame.BorderSizePixel = 0
    boneFrame.ZIndex = 17
    addCorner(boneFrame, 9)
    addStroke(boneFrame, CurrentTheme.Border, 1)

    local boneTitle = Instance.new("TextLabel", boneFrame)
    boneTitle.Size = UDim2.new(1, -120, 1, 0)
    boneTitle.Position = UDim2.fromOffset(12, 0)
    boneTitle.BackgroundTransparency = 1
    boneTitle.Font = Enum.Font.GothamBold
    boneTitle.Text = L("aim_part")
    boneTitle.TextSize = 9.5
    boneTitle.TextColor3 = CurrentTheme.Text
    boneTitle.TextXAlignment = Enum.TextXAlignment.Left
    boneTitle.ZIndex = 18

    local boneBtn = Instance.new("TextButton", boneFrame)
    boneBtn.Size = UDim2.fromOffset(105, 24)
    boneBtn.Position = UDim2.new(1, -112, 0.5, -12)
    boneBtn.BackgroundColor3 = CurrentTheme.HeaderBg
    boneBtn.Font = Enum.Font.GothamBlack
    boneBtn.Text = L("part_head")
    boneBtn.TextSize = 9
    boneBtn.TextColor3 = CurrentTheme.Accent
    boneBtn.ZIndex = 19
    addCorner(boneBtn, 6)
    addStroke(boneBtn, CurrentTheme.Border, 1)

    local bodyPartsCycle = {"Head", "Torso", "Legs"}
    local currentPartIndex = 1
    local function updateBoneBtnText()
        local pName = bodyPartsCycle[currentPartIndex]
        Config.Aimbot.TargetPart = pName
        if pName == "Head" then
            boneBtn.Text = L("part_head")
        elseif pName == "Torso" then
            boneBtn.Text = L("part_torso")
        else
            boneBtn.Text = L("part_legs")
        end
    end
    boneBtn.Activated:Connect(function()
        currentPartIndex = (currentPartIndex % #bodyPartsCycle) + 1
        updateBoneBtnText()
    end)

    table.insert(LangUpdaters, function()
        boneTitle.Text = L("aim_part")
        updateBoneBtnText()
    end)

    -- STREAMING_CHUNK: Populating Visuals (ESP) tab options
    local espPage = TabPages["VISUALS"]
    createToggle(espPage, "esp_enable", Config.ESP.Enabled, function(state)
        Config.ESP.Enabled = state
    end)
    createToggle(espPage, "esp_boxes", Config.ESP.Boxes, function(state)
        Config.ESP.Boxes = state
    end)
    createToggle(espPage, "esp_skeleton", Config.ESP.Skeleton, function(state)
        Config.ESP.Skeleton = state
    end)
    createToggle(espPage, "esp_lines", Config.ESP.Snaplines, function(state)
        Config.ESP.Snaplines = state
    end)
    createToggle(espPage, "esp_names", Config.ESP.Names, function(state)
        Config.ESP.Names = state
    end)
    createToggle(espPage, "esp_dist", Config.ESP.Distance, function(state)
        Config.ESP.Distance = state
    end)
    createToggle(espPage, "esp_health", Config.ESP.HealthBar, function(state)
        Config.ESP.HealthBar = state
    end)
    createToggle(espPage, "esp_team", Config.ESP.TeamCheck, function(state)
        Config.ESP.TeamCheck = state
    end)

    createColorPicker(espPage, "col_box", Config.ESP.BoxColor, function(c) Config.ESP.BoxColor = c end)
    createColorPicker(espPage, "col_skel", Config.ESP.SkeletonColor, function(c) Config.ESP.SkeletonColor = c end)
    createColorPicker(espPage, "col_tracer", Config.ESP.TracerColor, function(c) Config.ESP.TracerColor = c end)

    -- STREAMING_CHUNK: Raycast visibility check algorithm
    local staticRaycastParams = RaycastParams.new()
    staticRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
    staticRaycastParams.IgnoreWater = true

    local function resolveTargetPart(char, partMode)
        if not char then return nil end
        if partMode == "Head" then
            return char:FindFirstChild("Head") or char:FindFirstChild("FakeHead") or char:FindFirstChild("HeadHB") or char:FindFirstChild("HumanoidRootPart")
        elseif partMode == "Torso" then
            return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
        elseif partMode == "Legs" then
            return char:FindFirstChild("LowerTorso") or char:FindFirstChild("RightLowerLeg") or char:FindFirstChild("LeftLowerLeg") or char:FindFirstChild("Right Leg") or char:FindFirstChild("Left Leg") or char:FindFirstChild("HumanoidRootPart")
        end
        return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    end

    local function isTargetVisiblePenetrating(origin, targetPart, targetChar)
        if not Config.Aimbot.VisibilityCheck then return true end
        local direction = targetPart.Position - origin
        local ignore = {LocalPlayer.Character, Camera}
        staticRaycastParams.FilterDescendantsInstances = ignore
        local curOrigin = origin
        local curDir = direction

        for _ = 1, 6 do
            local hit = workspace:Raycast(curOrigin, curDir, staticRaycastParams)
            if not hit then return true end
            if hit.Instance:IsDescendantOf(targetChar) then return true end
            local inst = hit.Instance
            local nameLower = inst.Name:lower()
            if inst.CanCollide == false or inst.Transparency >= 0.40 or inst:IsA("Accessory") or inst.Parent:IsA("Accessory") or nameLower:find("barrier") or nameLower:find("zone") or nameLower:find("clip") or nameLower:find("trigger") or nameLower:find("bullet") or nameLower:find("smoke") then
                table.insert(ignore, inst)
                staticRaycastParams.FilterDescendantsInstances = ignore
                curOrigin = hit.Position + (curDir.Unit * 0.15)
                curDir = targetPart.Position - curOrigin
            else
                return false
            end
        end
        return false
    end

    local StickyTargetPlayer = nil
    local StickyTargetPart = nil
    local LastTimeTargetVisible = 0
    local TARGET_GRACE_TIME = 0.35

    local function validateStickyTarget()
        if not StickyTargetPlayer or not StickyTargetPlayer.Parent then return false end
        if not isAlivePlayer(StickyTargetPlayer) then return false end
        
        -- Exact team check for sticky targeting
        if Config.Aimbot.TeamCheck and isTeammate(StickyTargetPlayer) then
            return false
        end

        local char = StickyTargetPlayer.Character
        StickyTargetPart = resolveTargetPart(char, Config.Aimbot.TargetPart)
        if not StickyTargetPart then return false end

        local screenPos, onScreen = Camera:WorldToViewportPoint(StickyTargetPart.Position)
        if not onScreen or screenPos.Z <= 0 then return false end

        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if screenDist > (Config.Aimbot.FOV * 1.6) then return false end

        local now = os.clock()
        if isTargetVisiblePenetrating(Camera.CFrame.Position, StickyTargetPart, char) then
            LastTimeTargetVisible = now
            return true
        else
            if (now - LastTimeTargetVisible) < TARGET_GRACE_TIME then return true end
            return false
        end
    end

    local function acquireBestTarget()
        local bestPlayer = nil
        local bestPart = nil
        local shortestDist = Config.Aimbot.FOV
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

        for _, enemy in ipairs(Players:GetPlayers()) do
            if isAlivePlayer(enemy) then
                -- Strict team check
                if not (Config.Aimbot.TeamCheck and isTeammate(enemy)) then
                    local char = enemy.Character
                    local targetPart = resolveTargetPart(char, Config.Aimbot.TargetPart)
                    if targetPart then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen and screenPos.Z > 0 then
                            local screenDist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                            if screenDist <= shortestDist then
                                if isTargetVisiblePenetrating(Camera.CFrame.Position, targetPart, char) then
                                    shortestDist = screenDist
                                    bestPlayer = enemy
                                    bestPart = targetPart
                                end
                            end
                        end
                    end
                end
            end
        end
        return bestPlayer, bestPart
    end

    -- STREAMING_CHUNK: High precision camera aimbot and jitter stabilizer
    local smoothedAimPos = nil

    RunService:BindToRenderStep("NexusAimEngine", Enum.RenderPriority.Camera.Value + 1, function(dt)
        if Config.Aimbot.DrawFOV and FOVCircleFrame then
            FOVCircleFrame.Visible = true
            FOVCircleFrame.Position = UDim2.fromOffset(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            if Config.Settings.RainbowFOV then
                local hue = (os.clock() * 0.4) % 1
                FOVStroke.Color = Color3.fromHSV(hue, 0.85, 1)
            else
                FOVStroke.Color = CurrentTheme.Accent
            end
        elseif FOVCircleFrame then
            FOVCircleFrame.Visible = false
        end

        if not Config.Aimbot.Enabled then
            StickyTargetPlayer = nil
            StickyTargetPart = nil
            smoothedAimPos = nil
            return
        end

        if not validateStickyTarget() then
            StickyTargetPlayer, StickyTargetPart = acquireBestTarget()
            if StickyTargetPlayer then
                LastTimeTargetVisible = os.clock()
                smoothedAimPos = nil
            end
        end

        if StickyTargetPart and StickyTargetPlayer and StickyTargetPlayer.Character then
            local camPos = Camera.CFrame.Position
            local targetPos = StickyTargetPart.Position
            local targetDist = (targetPos - camPos).Magnitude

            if targetDist > 55 then
                local tRoot = StickyTargetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if tRoot then
                    local vel = tRoot.AssemblyLinearVelocity or Vector3.zero
                    if vel.Magnitude > 1.5 and vel.Magnitude < 90 then
                        local lead = vel * 0.032
                        if lead.Magnitude > 1.8 then lead = lead.Unit * 1.8 end
                        targetPos = targetPos + lead
                    end
                end
            end

            local isVisibleNow = isTargetVisiblePenetrating(camPos, StickyTargetPart, StickyTargetPlayer.Character)
            if Config.Aimbot.VisibilityCheck and not isVisibleNow then
                smoothedAimPos = nil
                return
            end

            -- Smooth out movement jitter
            if not smoothedAimPos or (targetPos - smoothedAimPos).Magnitude > 20 then
                smoothedAimPos = targetPos
            else
                smoothedAimPos = smoothedAimPos:Lerp(targetPos, math.clamp(dt * 30, 0.2, 1))
            end

            local toTarget = smoothedAimPos - camPos
            if toTarget.Magnitude > 0.1 then
                local dir = toTarget.Unit
                local yaw = math.atan2(-dir.X, -dir.Z)
                local pitch = math.asin(math.clamp(dir.Y, -0.999, 0.999))
                local targetRot = CFrame.fromEulerAnglesYXZ(pitch, yaw, 0)

                local curCFrame = Camera.CFrame
                local curRot = curCFrame - curCFrame.Position

                local smoothInput = math.clamp(Config.Aimbot.Smoothness, 0.01, 1.0)
                local lerpRate = (1.10 - smoothInput) * 22
                local factor = math.clamp(1 - math.exp(-lerpRate * dt), 0.15, 0.95)

                if Config.Aimbot.NoRecoil then
                    factor = math.clamp(factor * 1.35, 0.30, 1.0)
                end

                local newRot = curRot:Lerp(targetRot, factor)
                Camera.CFrame = CFrame.new(curCFrame.Position) * newRot
            end
        else
            smoothedAimPos = nil
        end
    end)

    -- STREAMING_CHUNK: High performance 2D ESP engine
    local ESPWidgets = {}

    local function getPlayerBones(char)
        if not char then return nil end
        local isR15 = (char:FindFirstChild("UpperTorso") ~= nil)
        if isR15 then
            local uTorso = char:FindFirstChild("UpperTorso")
            local lTorso = char:FindFirstChild("LowerTorso")
            return {
                {char:FindFirstChild("Head"), uTorso},
                {uTorso, lTorso},
                {uTorso, char:FindFirstChild("LeftUpperArm")},
                {char:FindFirstChild("LeftUpperArm"), char:FindFirstChild("LeftLowerArm")},
                {char:FindFirstChild("LeftLowerArm"), char:FindFirstChild("LeftHand")},
                {uTorso, char:FindFirstChild("RightUpperArm")},
                {char:FindFirstChild("RightUpperArm"), char:FindFirstChild("RightLowerArm")},
                {char:FindFirstChild("RightLowerArm"), char:FindFirstChild("RightHand")},
                {lTorso, char:FindFirstChild("LeftUpperLeg")},
                {char:FindFirstChild("LeftUpperLeg"), char:FindFirstChild("LeftLowerLeg")},
                {lTorso, char:FindFirstChild("RightUpperLeg")},
                {char:FindFirstChild("RightUpperLeg"), char:FindFirstChild("RightLowerLeg")}
            }
        else
            local torso = char:FindFirstChild("Torso")
            if not torso then return nil end
            return {
                {char:FindFirstChild("Head"), torso},
                {torso, char:FindFirstChild("Left Arm")},
                {torso, char:FindFirstChild("Right Arm")},
                {torso, char:FindFirstChild("Left Leg")},
                {torso, char:FindFirstChild("Right Leg")}
            }
        end
    end

    local function createPlayerESPWidget(player)
        if player == LocalPlayer then return end
        local widget = {
            Player = player,
            Box = Instance.new("Frame", ESPDrawContainer),
            BoxStroke = nil,
            Tracer = Instance.new("Frame", ESPDrawContainer),
            NameLabel = Instance.new("TextLabel", ESPDrawContainer),
            DistLabel = Instance.new("TextLabel", ESPDrawContainer),
            HealthBg = Instance.new("Frame", ESPDrawContainer),
            HealthFill = nil,
            SkeletonLines = {}
        }

        widget.Box.BackgroundTransparency = 1
        widget.Box.BorderSizePixel = 0
        widget.Box.Visible = false
        widget.Box.ZIndex = 6
        widget.BoxStroke = addStroke(widget.Box, Config.ESP.BoxColor, 1.4)

        widget.Tracer.AnchorPoint = Vector2.new(0.5, 0.5)
        widget.Tracer.BorderSizePixel = 0
        widget.Tracer.BackgroundColor3 = Config.ESP.TracerColor
        widget.Tracer.Visible = false
        widget.Tracer.ZIndex = 5

        widget.NameLabel.BackgroundTransparency = 1
        widget.NameLabel.Font = Enum.Font.GothamBlack
        widget.NameLabel.Text = player.DisplayName
        widget.NameLabel.TextSize = 10
        widget.NameLabel.TextColor3 = CurrentTheme.Text
        widget.NameLabel.TextStrokeTransparency = 0.3
        widget.NameLabel.Visible = false
        widget.NameLabel.ZIndex = 7

        widget.DistLabel.BackgroundTransparency = 1
        widget.DistLabel.Font = Enum.Font.GothamBold
        widget.DistLabel.Text = "[0m]"
        widget.DistLabel.TextSize = 9
        widget.DistLabel.TextColor3 = CurrentTheme.Accent
        widget.DistLabel.TextStrokeTransparency = 0.3
        widget.DistLabel.Visible = false
        widget.DistLabel.ZIndex = 7

        widget.HealthBg.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        widget.HealthBg.BorderSizePixel = 0
        widget.HealthBg.Visible = false
        widget.HealthBg.ZIndex = 6
        addCorner(widget.HealthBg, 2)

        widget.HealthFill = Instance.new("Frame", widget.HealthBg)
        widget.HealthFill.Size = UDim2.fromScale(1, 1)
        widget.HealthFill.BackgroundColor3 = CurrentTheme.AccentSec
        widget.HealthFill.BorderSizePixel = 0
        widget.HealthFill.ZIndex = 7
        addCorner(widget.HealthFill, 2)

        for i = 1, 14 do
            local ln = Instance.new("Frame", ESPDrawContainer)
            ln.AnchorPoint = Vector2.new(0.5, 0.5)
            ln.BorderSizePixel = 0
            ln.BackgroundColor3 = Config.ESP.SkeletonColor
            ln.Visible = false
            ln.ZIndex = 5
            table.insert(widget.SkeletonLines, ln)
        end

        ESPWidgets[player] = widget
    end

    local function removePlayerESPWidget(player)
        local w = ESPWidgets[player]
        if w then
            pcall(function() w.Box:Destroy() end)
            pcall(function() w.Tracer:Destroy() end)
            pcall(function() w.NameLabel:Destroy() end)
            pcall(function() w.DistLabel:Destroy() end)
            pcall(function() w.HealthBg:Destroy() end)
            for _, ln in ipairs(w.SkeletonLines) do
                pcall(function() ln:Destroy() end)
            end
            ESPWidgets[player] = nil
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do createPlayerESPWidget(p) end
    Players.PlayerAdded:Connect(createPlayerESPWidget)
    Players.PlayerRemoving:Connect(removePlayerESPWidget)

    RunService:BindToRenderStep("NexusESPEngine", Enum.RenderPriority.Camera.Value + 2, function()
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local screenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

        for player, w in pairs(ESPWidgets) do
            local alive = isAlivePlayer(player)
            local sameTeam = isTeammate(player)
            local char = player.Character

            -- Precise team filter for ESP
            local canShowESP = Config.ESP.Enabled and alive and char and not (Config.ESP.TeamCheck and sameTeam)

            if canShowESP then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
                local head = char:FindFirstChild("Head") or char:FindFirstChild("FakeHead") or char:FindFirstChild("HeadHB")

                if root and head then
                    local rootScreen, onScreenRoot = Camera:WorldToViewportPoint(root.Position)
                    local headScreen, onScreenHead = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0))
                    local legScreen = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.8, 0))

                    if (onScreenRoot or onScreenHead) and rootScreen.Z > 0 and headScreen.Z > 0 then
                        local boxHeight = math.abs(headScreen.Y - legScreen.Y)
                        local boxWidth = math.clamp(boxHeight * 0.65, 12, 400)
                        local boxPos = Vector2.new(rootScreen.X - (boxWidth / 2), math.min(headScreen.Y, legScreen.Y))

                        if Config.ESP.Boxes then
                            w.Box.Visible = true
                            w.Box.Size = UDim2.fromOffset(boxWidth, boxHeight)
                            w.Box.Position = UDim2.fromOffset(boxPos.X, boxPos.Y)
                            w.BoxStroke.Color = (player == StickyTargetPlayer) and Color3.fromRGB(255, 220, 0) or Config.ESP.BoxColor
                        else
                            w.Box.Visible = false
                        end

                        if Config.ESP.Skeleton then
                            local bones = getPlayerBones(char)
                            local boneIdx = 1
                            if bones then
                                for _, pair in ipairs(bones) do
                                    local p1, p2 = pair[1], pair[2]
                                    if p1 and p2 then
                                        local s1, on1 = Camera:WorldToViewportPoint(p1.Position)
                                        local s2, on2 = Camera:WorldToViewportPoint(p2.Position)
                                        if (on1 or on2) and s1.Z > 0 and s2.Z > 0 then
                                            local v1 = Vector2.new(s1.X, s1.Y)
                                            local v2 = Vector2.new(s2.X, s2.Y)
                                            local deltaB = v2 - v1
                                            local boneDist = deltaB.Magnitude
                                            local angleB = math.deg(math.atan2(deltaB.Y, deltaB.X))
                                            local midB = (v1 + v2) / 2
                                            local ln = w.SkeletonLines[boneIdx]
                                            if ln then
                                                ln.Visible = true
                                                ln.Size = UDim2.fromOffset(boneDist, 1.4)
                                                ln.Position = UDim2.fromOffset(midB.X, midB.Y)
                                                ln.Rotation = angleB
                                                ln.BackgroundColor3 = (player == StickyTargetPlayer) and Color3.fromRGB(255, 220, 0) or Config.ESP.SkeletonColor
                                                boneIdx = boneIdx + 1
                                            end
                                        end
                                    end
                                end
                            end
                            for i = boneIdx, #w.SkeletonLines do
                                w.SkeletonLines[i].Visible = false
                            end
                        else
                            for _, ln in ipairs(w.SkeletonLines) do ln.Visible = false end
                        end

                        if Config.ESP.Snaplines then
                            local targetPoint = Vector2.new(rootScreen.X, legScreen.Y)
                            local delta = targetPoint - screenBottom
                            local dist = delta.Magnitude
                            local angle = math.deg(math.atan2(delta.Y, delta.X))
                            local midPoint = (screenBottom + targetPoint) / 2
                            w.Tracer.Visible = true
                            w.Tracer.Size = UDim2.fromOffset(dist, 1.4)
                            w.Tracer.Position = UDim2.fromOffset(midPoint.X, midPoint.Y)
                            w.Tracer.Rotation = angle
                            w.Tracer.BackgroundColor3 = (player == StickyTargetPlayer) and Color3.fromRGB(255, 220, 0) or Config.ESP.TracerColor
                        else
                            w.Tracer.Visible = false
                        end

                        if Config.ESP.Names then
                            w.NameLabel.Visible = true
                            w.NameLabel.Position = UDim2.fromOffset(boxPos.X, boxPos.Y - 14)
                            w.NameLabel.Size = UDim2.fromOffset(boxWidth, 14)
                        else
                            w.NameLabel.Visible = false
                        end

                        if Config.ESP.Distance and myRoot then
                            local studs = math.floor((myRoot.Position - root.Position).Magnitude)
                            w.DistLabel.Visible = true
                            w.DistLabel.Text = string.format("[%dm]", studs)
                            w.DistLabel.Position = UDim2.fromOffset(boxPos.X, boxPos.Y + boxHeight + 1)
                            w.DistLabel.Size = UDim2.fromOffset(boxWidth, 12)
                        else
                            w.DistLabel.Visible = false
                        end

                        if Config.ESP.HealthBar and hum then
                            w.HealthBg.Visible = true
                            w.HealthBg.Size = UDim2.fromOffset(3.5, boxHeight)
                            w.HealthBg.Position = UDim2.fromOffset(boxPos.X - 6, boxPos.Y)
                            local hpRatio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                            w.HealthFill.Size = UDim2.fromScale(1, hpRatio)
                            w.HealthFill.Position = UDim2.fromScale(0, 1 - hpRatio)
                            if hpRatio > 0.5 then
                                w.HealthFill.BackgroundColor3 = CurrentTheme.AccentSec
                            elseif hpRatio > 0.25 then
                                w.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
                            else
                                w.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 45, 60)
                            end
                        else
                            w.HealthBg.Visible = false
                        end
                    else
                        w.Box.Visible = false
                        w.Tracer.Visible = false
                        w.NameLabel.Visible = false
                        w.DistLabel.Visible = false
                        w.HealthBg.Visible = false
                        for _, ln in ipairs(w.SkeletonLines) do ln.Visible = false end
                    end
                else
                    w.Box.Visible = false
                    w.Tracer.Visible = false
                    w.NameLabel.Visible = false
                    w.DistLabel.Visible = false
                    w.HealthBg.Visible = false
                    for _, ln in ipairs(w.SkeletonLines) do ln.Visible = false end
                end
            else
                w.Box.Visible = false
                w.Tracer.Visible = false
                w.NameLabel.Visible = false
                w.DistLabel.Visible = false
                w.HealthBg.Visible = false
                for _, ln in ipairs(w.SkeletonLines) do ln.Visible = false end
            end
        end
    end)

    -- STREAMING_CHUNK: Populating Status and telemetry dashboard tab
    local statusPage = TabPages["STATUS"]
    local profileCard = Instance.new("Frame", statusPage)
    profileCard.Size = UDim2.new(1, -6, 0, 70)
    profileCard.BackgroundColor3 = CurrentTheme.CardBg
    profileCard.BorderSizePixel = 0
    profileCard.ZIndex = 17
    addCorner(profileCard, 10)
    addStroke(profileCard, CurrentTheme.Accent, 1.2)

    local avatarImg = Instance.new("ImageLabel", profileCard)
    avatarImg.Size = UDim2.fromOffset(48, 48)
    avatarImg.Position = UDim2.fromOffset(10, 11)
    avatarImg.BackgroundColor3 = CurrentTheme.HeaderBg
    avatarImg.BorderSizePixel = 0
    avatarImg.ScaleType = Enum.ScaleType.Fit
    avatarImg.ZIndex = 18
    avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
    addCorner(avatarImg, 8)
    addStroke(avatarImg, CurrentTheme.Border, 1)

    local uName = Instance.new("TextLabel", profileCard)
    uName.Size = UDim2.new(1, -80, 0, 18)
    uName.Position = UDim2.fromOffset(68, 10)
    uName.BackgroundTransparency = 1
    uName.Font = Enum.Font.GothamBlack
    uName.Text = LocalPlayer.DisplayName
    uName.TextSize = 12
    uName.TextColor3 = CurrentTheme.Text
    uName.TextXAlignment = Enum.TextXAlignment.Left
    uName.ZIndex = 18

    local uHandle = Instance.new("TextLabel", profileCard)
    uHandle.Size = UDim2.new(1, -80, 0, 14)
    uHandle.Position = UDim2.fromOffset(68, 28)
    uHandle.BackgroundTransparency = 1
    uHandle.Font = Enum.Font.GothamMedium
    uHandle.Text = "@" .. LocalPlayer.Name .. " вЂў " .. tostring(LocalPlayer.AccountAge) .. " d"
    uHandle.TextSize = 8.5
    uHandle.TextColor3 = CurrentTheme.Muted
    uHandle.TextXAlignment = Enum.TextXAlignment.Left
    uHandle.ZIndex = 18

    local isPrem = (LocalPlayer.MembershipType == Enum.MembershipType.Premium)
    local uTag = Instance.new("TextLabel", profileCard)
    uTag.Size = UDim2.fromOffset(80, 15)
    uTag.Position = UDim2.fromOffset(68, 46)
    uTag.BackgroundColor3 = isPrem and Color3.fromRGB(245, 180, 40) or CurrentTheme.HeaderBg
    uTag.Font = Enum.Font.GothamBold
    uTag.Text = isPrem and "в… PREMIUM" or "VERIFIED CLIENT"
    uTag.TextSize = 7.5
    uTag.TextColor3 = isPrem and Color3.fromRGB(15, 15, 15) or CurrentTheme.Accent
    uTag.ZIndex = 18
    addCorner(uTag, 4)

    local deviceCard = Instance.new("Frame", statusPage)
    deviceCard.Size = UDim2.new(1, -6, 0, 64)
    deviceCard.BackgroundColor3 = CurrentTheme.CardBg
    deviceCard.BorderSizePixel = 0
    deviceCard.ZIndex = 17
    addCorner(deviceCard, 10)
    addStroke(deviceCard, CurrentTheme.Border, 1)

    local deviceLayout = Instance.new("UIGridLayout", deviceCard)
    deviceLayout.CellSize = UDim2.new(0.32, -4, 0, 48)
    deviceLayout.CellPadding = UDim2.new(0.02, 0, 0, 6)
    deviceLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    deviceLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local function makeTelemetryCard(parent, titleKey, initialVal, color)
        local card = Instance.new("Frame", parent)
        card.BackgroundColor3 = CurrentTheme.HeaderBg
        card.BorderSizePixel = 0
        card.ZIndex = 18
        addCorner(card, 7)
        addStroke(card, CurrentTheme.Border, 1)

        local lbl = Instance.new("TextLabel", card)
        lbl.Size = UDim2.new(1, -6, 0, 15)
        lbl.Position = UDim2.fromOffset(3, 4)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.Text = L(titleKey)
        lbl.TextSize = 7.2
        lbl.TextColor3 = CurrentTheme.Muted
        lbl.ZIndex = 19

        local num = Instance.new("TextLabel", card)
        num.Size = UDim2.new(1, -6, 0, 22)
        num.Position = UDim2.fromOffset(3, 19)
        num.BackgroundTransparency = 1
        num.Font = Enum.Font.GothamBlack
        num.Text = initialVal
        num.TextSize = 9.5
        num.TextColor3 = color
        num.ZIndex = 19

        table.insert(LangUpdaters, function()
            lbl.Text = L(titleKey)
        end)

        return { Box = card, Title = lbl, Value = num }
    end

    local platformCard = makeTelemetryCard(deviceCard, "dev_platform", DeviceInfo.Platform, CurrentTheme.Accent)
    local resCard = makeTelemetryCard(deviceCard, "dev_res", DeviceInfo.Resolution, CurrentTheme.AccentSec)
    local inputCard = makeTelemetryCard(deviceCard, "dev_input", DeviceInfo.Input, Color3.fromRGB(245, 190, 60))

    local metricsFrame = Instance.new("Frame", statusPage)
    metricsFrame.Size = UDim2.new(1, -6, 0, 64)
    metricsFrame.BackgroundColor3 = CurrentTheme.CardBg
    metricsFrame.BorderSizePixel = 0
    metricsFrame.ZIndex = 17
    addCorner(metricsFrame, 10)
    addStroke(metricsFrame, CurrentTheme.Border, 1)

    local metricsLayout = Instance.new("UIGridLayout", metricsFrame)
    metricsLayout.CellSize = UDim2.new(0.32, -4, 0, 48)
    metricsLayout.CellPadding = UDim2.new(0.02, 0, 0, 6)
    metricsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    metricsLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local fpsCard = makeTelemetryCard(metricsFrame, "metric_fps", "60", CurrentTheme.AccentSec)
    local pingCard = makeTelemetryCard(metricsFrame, "metric_ping", "30ms", CurrentTheme.Accent)
    local memCard = makeTelemetryCard(metricsFrame, "metric_mem", "120MB", Color3.fromRGB(240, 180, 50))

    local targetTelemetryFrame = Instance.new("Frame", statusPage)
    targetTelemetryFrame.Size = UDim2.new(1, -6, 0, 68)
    targetTelemetryFrame.BackgroundColor3 = CurrentTheme.CardBg
    targetTelemetryFrame.BorderSizePixel = 0
    targetTelemetryFrame.ZIndex = 17
    addCorner(targetTelemetryFrame, 10)
    addStroke(targetTelemetryFrame, CurrentTheme.Border, 1)

    local targetHeader = Instance.new("TextLabel", targetTelemetryFrame)
    targetHeader.Size = UDim2.new(1, -20, 0, 18)
    targetHeader.Position = UDim2.fromOffset(12, 5)
    targetHeader.BackgroundTransparency = 1
    targetHeader.Font = Enum.Font.GothamBlack
    targetHeader.Text = L("sec_target")
    targetHeader.TextSize = 9.5
    targetHeader.TextColor3 = CurrentTheme.Text
    targetHeader.TextXAlignment = Enum.TextXAlignment.Left
    targetHeader.ZIndex = 18

    table.insert(LangUpdaters, function()
        targetHeader.Text = L("sec_target")
    end)

    local targetStatusText = Instance.new("TextLabel", targetTelemetryFrame)
    targetStatusText.Size = UDim2.new(1, -24, 0, 16)
    targetStatusText.Position = UDim2.fromOffset(12, 24)
    targetStatusText.BackgroundTransparency = 1
    targetStatusText.Font = Enum.Font.GothamBold
    targetStatusText.Text = L("target_none")
    targetStatusText.TextSize = 9
    targetStatusText.TextColor3 = CurrentTheme.Muted
    targetStatusText.TextXAlignment = Enum.TextXAlignment.Left
    targetStatusText.ZIndex = 18

    local targetHealthBarBg = Instance.new("Frame", targetTelemetryFrame)
    targetHealthBarBg.Size = UDim2.new(1, -24, 0, 6)
    targetHealthBarBg.Position = UDim2.fromOffset(12, 46)
    targetHealthBarBg.BackgroundColor3 = CurrentTheme.HeaderBg
    targetHealthBarBg.BorderSizePixel = 0
    targetHealthBarBg.ZIndex = 18
    addCorner(targetHealthBarBg, 3)

    local targetHealthBarFill = Instance.new("Frame", targetHealthBarBg)
    targetHealthBarFill.Size = UDim2.fromScale(0, 1)
    targetHealthBarFill.BackgroundColor3 = CurrentTheme.AccentSec
    targetHealthBarFill.BorderSizePixel = 0
    targetHealthBarFill.ZIndex = 19
    addCorner(targetHealthBarFill, 3)

    local actionButtonsRow = Instance.new("Frame", statusPage)
    actionButtonsRow.Size = UDim2.new(1, -6, 0, 36)
    actionButtonsRow.BackgroundTransparency = 1
    actionButtonsRow.ZIndex = 17

    local copyJobBtn = Instance.new("TextButton", actionButtonsRow)
    copyJobBtn.Size = UDim2.new(0.48, -4, 1, 0)
    copyJobBtn.BackgroundColor3 = CurrentTheme.CardBg
    copyJobBtn.Font = Enum.Font.GothamBold
    copyJobBtn.Text = L("btn_copy_job")
    copyJobBtn.TextSize = 8.5
    copyJobBtn.TextColor3 = CurrentTheme.Accent
    copyJobBtn.ZIndex = 18
    addCorner(copyJobBtn, 8)
    addStroke(copyJobBtn, CurrentTheme.Border, 1)
    copyJobBtn.Activated:Connect(function()
        copyClipboard(tostring(game.JobId))
        copyJobBtn.Text = "COPIED!"
        task.delay(1.5, function() copyJobBtn.Text = L("btn_copy_job") end)
    end)

    local rejoinBtn = Instance.new("TextButton", actionButtonsRow)
    rejoinBtn.Size = UDim2.new(0.48, -4, 1, 0)
    rejoinBtn.Position = UDim2.new(0.52, 4, 0, 0)
    rejoinBtn.BackgroundColor3 = CurrentTheme.CardBg
    rejoinBtn.Font = Enum.Font.GothamBold
    rejoinBtn.Text = L("btn_rejoin")
    rejoinBtn.TextSize = 8.5
    rejoinBtn.TextColor3 = CurrentTheme.AccentSec
    rejoinBtn.ZIndex = 18
    addCorner(rejoinBtn, 8)
    addStroke(rejoinBtn, CurrentTheme.Border, 1)
    rejoinBtn.Activated:Connect(function()
        if #Players:GetPlayers() <= 1 then
            LocalPlayer:Kick("\n[NEXUS] Rejoining empty server...")
            task.wait(0.2)
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)

    table.insert(LangUpdaters, function()
        copyJobBtn.Text = L("btn_copy_job")
        rejoinBtn.Text = L("btn_rejoin")
    end)

    -- STREAMING_CHUNK: Populating Settings tab with animated themes and languages
    local settingsPage = TabPages["SETTINGS"]
    createToggle(settingsPage, "opt_watermark", Config.Settings.Watermark, function(state)
        Config.Settings.Watermark = state
        WatermarkFrame.Visible = state
    end)
    createToggle(settingsPage, "opt_rainbow", Config.Settings.RainbowFOV, function(state)
        Config.Settings.RainbowFOV = state
    end)

    local themeGroup = Instance.new("Frame", settingsPage)
    themeGroup.Size = UDim2.new(1, -6, 0, 68)
    themeGroup.BackgroundColor3 = CurrentTheme.CardBg
    themeGroup.BorderSizePixel = 0
    themeGroup.ZIndex = 17
    addCorner(themeGroup, 10)
    addStroke(themeGroup, CurrentTheme.Border, 1)

    local themeTitle = Instance.new("TextLabel", themeGroup)
    themeTitle.Size = UDim2.new(1, -20, 0, 20)
    themeTitle.Position = UDim2.fromOffset(10, 6)
    themeTitle.BackgroundTransparency = 1
    themeTitle.Font = Enum.Font.GothamBlack
    themeTitle.Text = L("theme_title")
    themeTitle.TextSize = 9.5
    themeTitle.TextColor3 = CurrentTheme.Text
    themeTitle.TextXAlignment = Enum.TextXAlignment.Left
    themeTitle.ZIndex = 18

    table.insert(LangUpdaters, function()
        themeTitle.Text = L("theme_title")
    end)

    local themeRow = Instance.new("Frame", themeGroup)
    themeRow.Size = UDim2.new(1, -20, 0, 30)
    themeRow.Position = UDim2.fromOffset(10, 28)
    themeRow.BackgroundTransparency = 1
    themeRow.ZIndex = 18

    local themeListLayout = Instance.new("UIListLayout", themeRow)
    themeListLayout.FillDirection = Enum.FillDirection.Horizontal
    themeListLayout.Padding = UDim.new(0, 8)

    local function refreshAllLanguage()
        for _, updater in ipairs(LangUpdaters) do
            pcall(updater)
        end
    end

    local function triggerInterfaceReloadAnimation(callback)
        tween(MainFrame, 0.20, {Size = UDim2.fromOffset(80, 50), Position = UDim2.fromScale(0.5, 0.53)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.delay(0.22, function()
            pcall(callback)
            refreshAllLanguage()
            MainFrame.Position = UDim2.fromScale(0.5, 0.48)
            tween(MainFrame, 0.30, {Size = UDim2.fromOffset(winW, winH), Position = UDim2.fromScale(0.5, 0.5)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end)
    end

    local function applyTheme(themeObj)
        CurrentTheme = themeObj
        MainFrame.BackgroundColor3 = CurrentTheme.Bg
        MainStroke.Color = CurrentTheme.Accent
        TopNeon.BackgroundColor3 = CurrentTheme.Accent
        Header.BackgroundColor3 = CurrentTheme.HeaderBg
        MiniPill.BackgroundColor3 = CurrentTheme.HeaderBg
        PillStroke.Color = CurrentTheme.Accent
        PillDot.BackgroundColor3 = CurrentTheme.AccentSec
        LogoTxt.TextColor3 = CurrentTheme.Accent
        CloseBtn.BackgroundColor3 = CurrentTheme.CardBg
        WatermarkTxt.TextColor3 = CurrentTheme.Accent
        WatermarkFrame.BackgroundColor3 = CurrentTheme.HeaderBg
        switchTab(Config.ActiveTab)
    end

    local themeKeys = {"CyberNeon", "CrimsonBlood", "PurpleVoid"}
    for _, tKey in ipairs(themeKeys) do
        local th = Themes[tKey]
        local tBtn = Instance.new("TextButton", themeRow)
        tBtn.Size = UDim2.new(0.32, -4, 1, 0)
        tBtn.BackgroundColor3 = th.CardBg
        tBtn.Font = Enum.Font.GothamBold
        tBtn.Text = th.Name
        tBtn.TextSize = 8.5
        tBtn.TextColor3 = th.Accent
        tBtn.ZIndex = 19
        addCorner(tBtn, 7)
        addStroke(tBtn, th.Accent, 1)
        tBtn.Activated:Connect(function()
            triggerInterfaceReloadAnimation(function() applyTheme(th) end)
        end)
    end

    local langGroup = Instance.new("Frame", settingsPage)
    langGroup.Size = UDim2.new(1, -6, 0, 68)
    langGroup.BackgroundColor3 = CurrentTheme.CardBg
    langGroup.BorderSizePixel = 0
    langGroup.ZIndex = 17
    addCorner(langGroup, 10)
    addStroke(langGroup, CurrentTheme.Border, 1)

    local langTitle = Instance.new("TextLabel", langGroup)
    langTitle.Size = UDim2.new(1, -20, 0, 20)
    langTitle.Position = UDim2.fromOffset(10, 6)
    langTitle.BackgroundTransparency = 1
    langTitle.Font = Enum.Font.GothamBlack
    langTitle.Text = L("lang_title")
    langTitle.TextSize = 9.5
    langTitle.TextColor3 = CurrentTheme.Text
    langTitle.TextXAlignment = Enum.TextXAlignment.Left
    langTitle.ZIndex = 18

    table.insert(LangUpdaters, function()
        langTitle.Text = L("lang_title")
    end)

    local langRow = Instance.new("Frame", langGroup)
    langRow.Size = UDim2.new(1, -20, 0, 30)
    langRow.Position = UDim2.fromOffset(10, 28)
    langRow.BackgroundTransparency = 1
    langRow.ZIndex = 18

    local langListLayout = Instance.new("UIListLayout", langRow)
    langListLayout.FillDirection = Enum.FillDirection.Horizontal
    langListLayout.Padding = UDim.new(0, 8)

    local languages = {
        { Code = "ru", Name = "Р СѓСЃСЃРєРёР№" },
        { Code = "en", Name = "English" },
        { Code = "es", Name = "EspaГ±ol" }
    }

    for _, lang in ipairs(languages) do
        local lBtn = Instance.new("TextButton", langRow)
        lBtn.Size = UDim2.new(0.32, -4, 1, 0)
        lBtn.BackgroundColor3 = CurrentTheme.HeaderBg
        lBtn.Font = Enum.Font.GothamBold
        lBtn.Text = lang.Name
        lBtn.TextSize = 9.5
        lBtn.TextColor3 = CurrentTheme.Text
        lBtn.ZIndex = 19
        addCorner(lBtn, 7)
        addStroke(lBtn, CurrentTheme.Border, 1)
        lBtn.Activated:Connect(function()
            if CurrentLang == lang.Code then return end
            CurrentLang = lang.Code
            triggerInterfaceReloadAnimation(function()
                refreshAllLanguage()
            end)
        end)
    end

    -- STREAMING_CHUNK: Setting up config actions and script destruction
    local configActionsRow = Instance.new("Frame", settingsPage)
    configActionsRow.Size = UDim2.new(1, -6, 0, 36)
    configActionsRow.BackgroundTransparency = 1
    configActionsRow.ZIndex = 17

    local saveConfigBtn = Instance.new("TextButton", configActionsRow)
    saveConfigBtn.Size = UDim2.new(0.48, -4, 1, 0)
    saveConfigBtn.BackgroundColor3 = CurrentTheme.CardBg
    saveConfigBtn.Font = Enum.Font.GothamBold
    saveConfigBtn.Text = L("btn_save_config")
    saveConfigBtn.TextSize = 8.5
    saveConfigBtn.TextColor3 = CurrentTheme.AccentSec
    saveConfigBtn.ZIndex = 18
    addCorner(saveConfigBtn, 8)
    addStroke(saveConfigBtn, CurrentTheme.Border, 1)
    saveConfigBtn.Activated:Connect(function()
        saveConfig()
        saveConfigBtn.Text = "SAVED!"
        task.delay(1.2, function() saveConfigBtn.Text = L("btn_save_config") end)
    end)

    local loadConfigBtn = Instance.new("TextButton", configActionsRow)
    loadConfigBtn.Size = UDim2.new(0.48, -4, 1, 0)
    loadConfigBtn.Position = UDim2.new(0.52, 4, 0, 0)
    loadConfigBtn.BackgroundColor3 = CurrentTheme.CardBg
    loadConfigBtn.Font = Enum.Font.GothamBold
    loadConfigBtn.Text = L("btn_load_config")
    loadConfigBtn.TextSize = 8.5
    loadConfigBtn.TextColor3 = CurrentTheme.Accent
    loadConfigBtn.ZIndex = 18
    addCorner(loadConfigBtn, 8)
    addStroke(loadConfigBtn, CurrentTheme.Border, 1)
    loadConfigBtn.Activated:Connect(function()
        loadConfig()
        loadConfigBtn.Text = "LOADED!"
        task.delay(1.2, function() loadConfigBtn.Text = L("btn_load_config") end)
    end)

    table.insert(LangUpdaters, function()
        saveConfigBtn.Text = L("btn_save_config")
        loadConfigBtn.Text = L("btn_load_config")
    end)

    local hubActionsRow = Instance.new("Frame", settingsPage)
    hubActionsRow.Size = UDim2.new(1, -6, 0, 36)
    hubActionsRow.BackgroundTransparency = 1
    hubActionsRow.ZIndex = 17

    local resetConfigBtn = Instance.new("TextButton", hubActionsRow)
    resetConfigBtn.Size = UDim2.new(0.48, -4, 1, 0)
    resetConfigBtn.BackgroundColor3 = CurrentTheme.CardBg
    resetConfigBtn.Font = Enum.Font.GothamBold
    resetConfigBtn.Text = L("btn_reset")
    resetConfigBtn.TextSize = 8.5
    resetConfigBtn.TextColor3 = CurrentTheme.Text
    resetConfigBtn.ZIndex = 18
    addCorner(resetConfigBtn, 8)
    addStroke(resetConfigBtn, CurrentTheme.Border, 1)
    resetConfigBtn.Activated:Connect(function()
        Config.Aimbot.Enabled = false
        Config.Aimbot.HitboxExpander = false
        Config.Aimbot.HitboxSize = 10
        restoreAllHitboxes()
        Config.Aimbot.NoRecoil = true
        Config.Aimbot.Smoothness = 0.20
        Config.Aimbot.FOV = 150
        Config.Aimbot.TargetPart = "Head"
        Config.ESP.Enabled = false
        Config.ESP.Boxes = true
        Config.ESP.Skeleton = true
        Config.ESP.Snaplines = true
        Config.ESP.BoxColor = Color3.fromRGB(255, 45, 75)
        Config.ESP.SkeletonColor = Color3.fromRGB(0, 255, 140)
        Config.ESP.TracerColor = Color3.fromRGB(0, 235, 255)
        Config.Settings.RainbowFOV = false
        FOVCircleFrame.Size = UDim2.fromOffset(300, 300)
        resetConfigBtn.Text = "DONE!"
        task.delay(1.2, function() resetConfigBtn.Text = L("btn_reset") end)
    end)

    local unloadBtn = Instance.new("TextButton", hubActionsRow)
    unloadBtn.Size = UDim2.new(0.48, -4, 1, 0)
    unloadBtn.Position = UDim2.new(0.52, 4, 0, 0)
    unloadBtn.BackgroundColor3 = Color3.fromRGB(45, 18, 24)
    unloadBtn.Font = Enum.Font.GothamBold
    unloadBtn.Text = L("btn_unload")
    unloadBtn.TextSize = 8.5
    unloadBtn.TextColor3 = Color3.fromRGB(255, 75, 95)
    unloadBtn.ZIndex = 18
    addCorner(unloadBtn, 8)
    addStroke(unloadBtn, Color3.fromRGB(80, 25, 35), 1)
    unloadBtn.Activated:Connect(function()
        if _G.NexusShooterCleanup then _G.NexusShooterCleanup() end
    end)

    table.insert(LangUpdaters, function()
        resetConfigBtn.Text = L("btn_reset")
        unloadBtn.Text = L("btn_unload")
    end)

    -- STREAMING_CHUNK: Binding live performance and lock telemetry
    local frameCount = 0
    local lastSample = os.clock()
    table.insert(Cleanups, RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        local now = os.clock()
        local delta = now - lastSample
        if delta >= 0.5 then
            local currentFPS = math.floor((frameCount / delta) + 0.5)
            fpsCard.Value.Text = tostring(currentFPS)
            local pingVal = 35
            pcall(function()
                local item = StatsService.Network.ServerStatsItem["Data Ping"]
                if item then pingVal = math.floor(item:GetValue()) end
            end)
            pingCard.Value.Text = tostring(pingVal) .. "ms"
            local memMb = 150
            pcall(function() memMb = math.floor(StatsService:GetTotalMemoryUsageMb()) end)
            memCard.Value.Text = tostring(memMb) .. "MB"

            local curVp = Camera and Camera.ViewportSize or Vector2.new(800, 600)
            resCard.Value.Text = string.format("%dx%d", math.floor(curVp.X), math.floor(curVp.Y))

            if Config.Settings.Watermark then
                WatermarkTxt.Text = string.format("NEXUS | %d FPS | %dms", currentFPS, pingVal)
            end

            -- Live telemetry for locked target
            if StickyTargetPlayer and isAlivePlayer(StickyTargetPlayer) and not (Config.Aimbot.TeamCheck and isTeammate(StickyTargetPlayer)) then
                local char = StickyTargetPlayer.Character
                local tHum = char and char:FindFirstChildOfClass("Humanoid")
                local tRoot = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
                local myRoot = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character:FindFirstChild("Torso"))
                if tHum and tHum.Health > 0 and tRoot then
                    local dist = myRoot and math.floor((myRoot.Position - tRoot.Position).Magnitude) or 0
                    targetStatusText.Text = string.format("LOCK: %s вЂў [%dm] вЂў HP: %d/%d", StickyTargetPlayer.DisplayName, dist, math.floor(tHum.Health), math.floor(tHum.MaxHealth))
                    targetStatusText.TextColor3 = CurrentTheme.AccentSec
                    local hpRatio = math.clamp(tHum.Health / math.max(tHum.MaxHealth, 1), 0, 1)
                    targetHealthBarFill.Size = UDim2.fromScale(hpRatio, 1)
                    if hpRatio > 0.5 then
                        targetHealthBarFill.BackgroundColor3 = CurrentTheme.AccentSec
                    elseif hpRatio > 0.25 then
                        targetHealthBarFill.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
                    else
                        targetHealthBarFill.BackgroundColor3 = Color3.fromRGB(255, 45, 60)
                    end
                else
                    targetStatusText.Text = L("target_none")
                    targetStatusText.TextColor3 = CurrentTheme.Muted
                    targetHealthBarFill.Size = UDim2.fromScale(0, 1)
                end
            else
                targetStatusText.Text = L("target_none")
                targetStatusText.TextColor3 = CurrentTheme.Muted
                targetHealthBarFill.Size = UDim2.fromScale(0, 1)
            end

            frameCount = 0
            lastSample = now
        end
    end))

    refreshAllLanguage()
    print("[NEXUS] Tactical Shooter Hub Loaded Successfully with Clean UTF-8 Text & Corrected Team Filters!")
end)

if not successInit then
    warn("[NEXUS INITIALIZATION ERROR]: " .. tostring(errInit))
end
