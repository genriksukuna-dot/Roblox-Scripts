--[[
    SHUT v7.8 [Supreme Hitscan + Zero-Shake Aimbot + Hex UTF8 UI + Rivals Team Check]
]]

--// MULTI-RUN CLEANUP
if _G.ShutBloxStrikeCleanup then
    pcall(_G.ShutBloxStrikeCleanup)
end

local Cleanups = {}
_G.ShutBloxStrikeCleanup = function()
    for _, item in ipairs(Cleanups) do
        pcall(function()
            if typeof(item) == "RBXScriptConnection" then
                item:Disconnect()
            elseif typeof(item) == "Instance" then
                item:Destroy()
            end
        end)
    end
    pcall(function() game:GetService("RunService"):UnbindFromRenderStep("ShutAimEngine") end)
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

--// CONSTANTS & LINKS
local SCRIPT_TITLE = "SHUT"
local SCRIPT_VER = "v7.8"
local TG_LINK = "https://t.me/+qTcgFmViTe9jMzU6"

--// HEX DECODER (PREVENTS MOJIBAKE / ENCODING CORRUPTION ON MOBILE EXECUTORS)
local function H(hex)
    return (hex:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end

--// LOCALIZATION DICTIONARY
local Dict = {
    EN = {
        ScriptTitle = "SHUT",
        Subtitle = "TACTICAL ENGINE",
        StatusReady = "STATUS: HOOKED & READY",
        EngineStatus = "⚡ SHUT HITSCAN ACTIVE",
        TabAim = "AIM ASSIST",
        TabESP = "VISUAL ESP",
        TabVis = "RETICLES",
        TabStat = "MATCH INFO",
        TabSet = "SETTINGS",
        HeaderAimDesc = "Headshot targeting, sticky lock & infinite range",
        HeaderESPDesc = "Player visual overlays & skeleton ESP",
        HeaderVisDesc = "Tactical FOV ring & crosshairs",
        HeaderStatDesc = "Match diagnostics & live statistics",
        HeaderSetDesc = "System configurations & preferences",
        TgTitle = "JOIN OUR TELEGRAM",
        TgDesc = "Get fresh configs, script updates & bypass alerts!",
        TgBtn = "COPY TG LINK",
        TgCopied = "COPIED TO CLIPBOARD!",
        AimEnabled = "Headshot Aimbot",
        AimEnabledDesc = "Instant lock strictly on Head",
        AimMagnet = "Bullet Magnet (Hitbox)",
        AimMagnetDesc = "Expands enemy head hitbox for max range hits",
        AimMagnetSize = "Magnet Head Radius",
        AimMagnetSizeDesc = "Size of target head collision (Studs)",
        AimVis = "Visible Check",
        AimVisDesc = "Ignore enemies behind bulletproof walls",
        AimTeam = "Team Check",
        AimTeamDesc = "Filter out friendly teammates",
        AimFOV = "Aim FOV",
        AimFOVDesc = "Targeting angle radius",
        AimSmooth = "Aim Smoothness",
        AimSmoothDesc = "0 = Instant Snap, Higher = Smoother",
        AimDist = "Max Distance",
        AimDistDesc = "Engagement range in studs",
        ESPEnabled = "Master ESP",
        ESPEnabledDesc = "Player visual overlays",
        ESPBox = "2D Boxes",
        ESPBoxDesc = "Bounding boxes around alive targets",
        ESPName = "Player Names",
        ESPNameDesc = "Display tag and username",
        ESPHealth = "Health Bars",
        ESPHealthDesc = "Show live player health status",
        ESPDist = "Distance Tag",
        ESPDistDesc = "Show distance in meters",
        ESPTracer = "Snaplines",
        ESPTracerDesc = "Draw tracer lines to enemies",
        ESPSkeleton = "Skeleton ESP",
        ESPSkeletonDesc = "Draw bone skeleton lines on targets",
        ESPTeam = "Team Check",
        ESPTeamDesc = "Hide ESP on teammates",
        ESPRange = "ESP Range",
        ESPRangeDesc = "Maximum render distance",
        VisFOV = "FOV Ring",
        VisFOVDesc = "Draw aimbot field of view circle",
        VisCross = "Custom Crosshair",
        VisCrossDesc = "Draw centered tactical reticle",
        LangTitle = "Language / Язык / Idioma",
        LangDesc = "Switch interface language",
        ThemeTitle = "Color Themes",
        ThemeDesc = "Customize UI color palette",
        StyleTitle = "Menu Styles",
        StyleDesc = "Switch UI layout and visual effects",
        MenuSounds = "Menu Sounds",
        MenuSoundsDesc = "Play tactile sound clicks",
        MenuAnim = "UI Animations",
        MenuAnimDesc = "Enable smooth transitions",
        PillText = "⚡ SHUT MENU",
    },
    RU = {
        ScriptTitle = "SHUT",
        Subtitle = H("D0A2D090D09AD0A2D098D0A7D095D0A1D09AD098D09920D094D092D098D096D09ED09A"),
        StatusReady = H("D0A1D0A2D090D0A2D0A3D0A13A20D09FD09ED094D09AD09BD0AED0A7D095D09DD09E20D09820D093D09ED0A2D09ED092D09E"),
        EngineStatus = H("E29AA120D0A5D098D0A2D0A1D09AD090D09D205348555420D090D09AD0A2D098D092D095D09D"),
        TabAim = H("D090D098D09C20D090D0A1D0A1D098D0A1D0A2"),
        TabESP = H("D092D098D097D0A3D090D09B20455350"),
        TabVis = H("D09FD0A0D098D0A6D095D09BD0AB"),
        TabStat = H("D09CD090D0A2D0A720D098D09DD0A4D09E"),
        TabSet = H("D09DD090D0A1D0A2D0A0D09ED099D09AD098"),
        HeaderAimDesc = H("D0A5D0B5D0B4D188D0BED1822DD0B0D0B8D0BC2C20D0BBD0B8D0BFD0BAD0B8D0B920D0B7D0B0D185D0B2D0B0D18220D0B820D0B1D0B5D181D0BADD0BED0BDD0B5D187D0BDD0B0D18F20D0B4D0B0D0BBD18CD0BDD0BED181D182D18C"),
        HeaderESPDesc = H("D092D0B8D0B7D183D0B0D0BBD18CD0BDD18BD0B520D0B1D0BED0BADD181D18B2C20D0B8D0BCD0B5D0BDD0B020D0B820D181D0BADD0B5D0BBD0B5D18220455350"),
        HeaderVisDesc = H("D09ED182D0BED0B1D180D0B0D0B6D0B5D0BDD0B8D0B520D0BADD180D183D0B3D0B020464F5620D0B820D0BFD0B5D180D0B5D0BADD180D0B5D181D182D0B8D18F"),
        HeaderStatDesc = H("D098D0BDD184D0BED180D0BCD0B0D186D0B8D18F20D0BE20D181D0B5D180D0B2D0B5D180D0B520D0B820D0B4D0B8D0B0D0B3D0BDD0BED181D182D0B8D0BADD0B020D182D0B0D180D0B3D0B5D182D0BED0B2"),
        HeaderSetDesc = H("D09AD0BED0BDD184D0B8D0B3D183D180D0B0D186D0B8D18F2C20D18FD0B7D18BD0BA20D0B820D182D0B5D0BCD18B20D0BED184D0BED180D0BCD0BBD0B5D0BDD0B8D18F"),
        TgTitle = H("D09DD090D0A820D0A2D095D09BD095D093D0A0D090D09C"),
        TgDesc = H("D0A1D0B2D0B5D0B6D0B8D0B520D0BADD0BED0BDD184D0B8D0B3D0B820D0B820D0B2D0B0D0B6D0BDD18BD0B520D0BDD0BED0B2D0BED181D182D0B820D0BED0B1D185D0BED0B4D0B021"),
        TgBtn = H("D0A1D09AD09ED09FD098D0A0D09ED092D090D0A2D0AC20D0A1D0A1D0ABD09BD09AD0A3"),
        TgCopied = H("D0A1D0A1D0ABD09BD09AD09020D0A1D09AD09ED09FD098D0A0D09ED092D090D09DD09021"),
        AimEnabled = H("D0A5D0B5D0B4D188D0BED18220D090D0B8D0BCD0B1D0BED182"),
        AimEnabledDesc = H("D09CD0B3D0BDD0BED0B2D0B5D0BDD0BDD0B0D18F20D184D0B8D0BAD181D0B0D186D0B8D18F20D181D182D180D0BED0B3D0BE20D0BDD0B020D0B3D0BED0BBD0BED0B2D183"),
        AimMagnet = H("D09CD0B0D0B3D0BDD0B8D18220D0BFD183D0BBD18C2028D0A5D0B8D182D0B1D0BED0BADD18129"),
        AimMagnetDesc = H("D0A0D0B0D181D188D0B8D180D18FD0B5D18220D185D0B8D182D0B1D0BED0BADD18120D0B4D0BBD18F20D183D180D0BED0BDD0B020D0BDD0B020D0BBD18ED0B1D0BED0B920D0B4D0B8D181D182D0B0D0BDD186D0B8D0B8"),
        AimMagnetSize = H("D0A0D0B0D0B4D0B8D183D18120D0B3D0BED0BBD0BED0B2D18B2028D181D182D0B0D0B4D18B29"),
        AimMagnetSizeDesc = H("D0A0D0B0D0B7D0BCD0B5D18020D185D0B8D182D0B1D0BED0BADD181D0B020D0B3D0BED0BBD0BED0B2D18B20D0B4D0BBD18F20D0BFD183D0BBD18C"),
        AimVis = H("D09FD180D0BED0B2D0B5D180D0BAD0B020D0B2D0B8D0B4D0B8D0BCD0BED181D182D0B8"),
        AimVisDesc = H("D098D0B3D0BDD0BED180D0B8D180D0BED0B2D0B0D182D18C20D0B2D180D0B0D0B3D0BED0B220D0B7D0B020D0B3D0BBD183D185D0B8D0BCD0B820D181D182D0B5D0BDD0B0D0BCD0B8"),
        AimTeam = H("D0A4D0B8D0BBD18CD182D18020D0BADD0BED0BCD0B0D0BDD0B4D18B"),
        AimTeamDesc = H("D09DD0B520D0BDD0B0D0B2D0BED0B4D0B8D182D18CD181D18F20D0BDD0B020D0B8D0B3D180D0BED0BADD0BED0B220D181D0B2D0BED0B5D0B920D0BADD0BED0BCD0B0D0BDD0B4D18B"),
        AimFOV = H("D0A0D0B0D0B4D0B8D183D18120D0B7D0B0D185D0B2D0B0D182D0B02028464F5629"),
        AimFOVDesc = H("D097D0BED0BDD0B020D183D0B3D0BBD0B020D0BED0B1D0B7D0BED180D0B020D0B4D0BBD18F20D0B7D0B0D185D0B2D0B0D182D0B020D186D0B5D0BBD0B8"),
        AimSmooth = H("D09FD0BBD0B0D0B2D0BDD0BED181D182D18C20D0B4D0BED0B2D0BED0B4D0BAD0B8"),
        AimSmoothDesc = H("30203D20D09CD0B3D0BDD0BED0B2D0B5D0BDD0BDD18BD0B920D181D0BDD0B0D0BF2C20D0B2D18BD188D0B5203D20D0BFD0BBD0B0D0B2D0BDD0B5D0B5"),
        AimDist = H("D094D0B8D181D182D0B0D0BDD186D0B8D18F20D0B0D0B8D0BCD0B0"),
        AimDistDesc = H("D09FD180D0B5D0B4D0B5D0BBD18CD0BDD0B0D18F20D0B4D0B0D0BBD18CD0BDD0BED181D182D18C20D0B7D0B0D185D0B2D0B0D182D0B020D0B220D181D182D0B0D0B4D0B0D185"),
        ESPEnabled = H("D09CD0B0D181D182D0B5D18020455350"),
        ESPEnabledDesc = H("D093D0BBD0B0D0B2D0BDD18BD0B920D0BFD0B5D180D0B5D0BADD0BBD18ED187D0B0D182D0B5D0BBD18C20D0B2D0B8D0B7D183D0B0D0BBD0BED0B2"),
        ESPBox = H("324420D091D0BED0BADD181D18B"),
        ESPBoxDesc = H("D09FD180D18FD0BCD0BED183D0B3D0BED0BBD18CD0BDD0B8D0BAD0B820D0B2D0BED0BADD180D183D0B320D0B6D0B8D0B2D18BD18520D0BFD180D0BED182D0B8D0B2D0BDD0B8D0BAD0BED0B2"),
        ESPName = H("D098D0BCD0B5D0BDD0B020D0B8D0B3D180D0BED0BADD0BED0B2"),
        ESPNameDesc = H("D09ED182D0BED0B1D180D0B0D0B6D0B5D0BDD0B8D0B520D0BDD0B8D0BAD0B020D0B820D0B4D0B8D181D0BFD0BBD0B5D0B92DD0BDD0B5D0B9D0BCD0B0"),
        ESPHealth = H("D09FD0BED0BBD0BED181D0BAD0B820D0B7D0B4D0BED180D0BED0B2D18CD18F"),
        ESPHealthDesc = H("D0A8D0BADD0B0D0BBD0B020D182D0B5D0BADD183D189D0B5D0B3D0BE20D0B7D0B4D0BED180D0BED0B2D18CD18F20D0BFD180D0BED182D0B8D0B2D0BDD0B8D0BAD0B0"),
        ESPDist = H("D094D0B8D181D182D0B0D0BDD186D0B8D18F"),
        ESPDistDesc = H("D09ED182D0BED0B1D180D0B0D0B6D0B5D0BDD0B8D0B520D180D0B0D181D181D182D0BED18FD0BDD0B8D18F20D0B220D0BCD0B5D182D180D0B0D185"),
        ESPTracer = H("D0A2D180D0B5D0B9D181D0B5D180D18B2028D0BBD0B8D0BDD0B8D0B829"),
        ESPTracerDesc = H("D09BD0B8D0BDD0B8D0B820D0BED18220D186D0B5D0BDD182D180D0B020D18DD0BAD180D0B0D0BDD0B020D0BA20D0BFD180D0BED182D0B8D0B2D0BDD0B8D0BAD0B0D0BC"),
        ESPSkeleton = H("D0A1D0BADD0B5D0BBD0B5D18220455350"),
        ESPSkeletonDesc = H("D09ED182D0BED0B1D180D0B0D0B6D0B5D0BDD0B8D0B520D0BADD0BED181D182D0B5D0B920D0B820D181D0BADD0B5D0BBD0B5D182D0B020D0BDD0B020D0B2D180D0B0D0B3D0B0D185"),
        ESPTeam = H("D0A4D0B8D0BBD18CD182D18020D0BADD0BED0BCD0B0D0BDD0B4D18B"),
        ESPTeamDesc = H("D0A1D0BADD180D18BD0B2D0B0D182D18C20D0B2D0B8D0B7D183D0B0D0BBD18B20D0BDD0B020D181D0BED18ED0B7D0BDD0B8D0BAD0B0D185"),
        ESPRange = H("D094D0B8D181D182D0B0D0BDD186D0B8D18F20455350"),
        ESPRangeDesc = H("D09FD180D0B5D0B4D0B5D0BBD18CD0BDD0B0D18F20D0B4D0B0D0BBD18CD0BDD0BED181D182D18C20D0BFD180D0BED180D0B8D181D0BED0B2D0BAD0B8"),
        VisFOV = H("D09AD180D183D0B320D0B0D0B8D0BCD0B02028464F5629"),
        VisFOVDesc = H("D092D0B8D0B7D183D0B0D0BBD18CD0BDD18BD0B920D0BADD180D183D0B320D0B7D0BED0BDD18B20D0B7D0B0D185D0B2D0B0D182D0B0"),
        VisCross = H("D09AD0B0D181D182D0BED0BCD0BDD18BD0B920D0BFD180D0B8D186D0B5D0BB"),
        VisCrossDesc = H("D0A2D0B0D0BAD182D0B8D187D0B5D181D0BADD0BED0B520D0BFD0B5D180D0B5D0BADD180D0B5D181D182D0B8D0B520D0BFD0BE20D186D0B5D0BDD182D180D183"),
        LangTitle = H("D0AFD0B7D18BD0BA20D0B8D0BDD182D0B5D180D184D0B5D0B9D181D0B0"),
        LangDesc = H("D09FD0B5D180D0B5D0BADD0BBD18ED187D0B5D0BDD0B8D0B520D18FD0B7D18BD0BAD0B020D0BCD0B5D0BDD18E"),
        ThemeTitle = H("D0A6D0B2D0B5D182D0BED0B2D0B0D18F20D182D0B5D0BCD0B0"),
        ThemeDesc = H("D092D18BD0B1D0BED18020D0BED182D182D0B5D0BDD0BADD0BED0B220D0BED184D0BED180D0BCD0BBD0B5D0BDD0B8D18F"),
        StyleTitle = H("D0A1D182D0B8D0BBD0B820D0BCD0B5D0BDD18E"),
        StyleDesc = H("D093D0BBD0BED0B1D0B0D0BBD18CD0BDD18BD0B520D0B2D0B8D0B7D183D0B0D0BBD18CD0BDD18BD0B520D18DD184D184D0B5D0BADD182D18B"),
        MenuSounds = H("D097D0B2D183D0BAD0B820D0BADD0BBD0B8D0BADD0BED0B2"),
        MenuSoundsDesc = H("D097D0B2D183D0BADD0BED0B2D18BD0B520D18DD184D184D0B5D0BADD182D18B20D0BCD0B5D0BDD18E"),
        MenuAnim = H("D090D0BDD0B8D0BCD0B0D186D0B8D0B8205549"),
        MenuAnimDesc = H("D09FD0BBD0B0D0B2D0BDD18BD0B520D0BFD0B5D180D0B5D185D0BED0B4D18B20D0B820D0B4D0B8D0BDD0B0D0BCD0B8D0BAD0B0"),
        PillText = H("E29AA120D09CD095D09DD0AE2053485554"),
    },
    ES = {
        ScriptTitle = "SHUT",
        Subtitle = "MOTOR TACTICO",
        StatusReady = "ESTADO: CONECTADO Y LISTO",
        EngineStatus = "HITSCAN SHUT ACTIVO",
        TabAim = "ASISTENCIA",
        TabESP = "ESP VISUAL",
        TabVis = "RETICULAS",
        TabStat = "ESTADO",
        TabSet = "AJUSTES",
        HeaderAimDesc = "Bloqueo a la cabeza, iman de balas y rango infinito",
        HeaderESPDesc = "Overlays de jugadores y esqueleto ESP",
        HeaderVisDesc = "Anillo de FOV tactico y reticula centrada",
        HeaderStatDesc = "Detalles de partida y diagnostico",
        HeaderSetDesc = "Configuraciones del sistema e idioma",
        TgTitle = "UNETE A TELEGRAM",
        TgDesc = "Nuevas configuraciones, actualizaciones y avisos!",
        TgBtn = "COPIAR ENLACE TG",
        TgCopied = "COPIADO AL PORTAPAPELES!",
        AimEnabled = "Aimbot de Cabeza",
        AimEnabledDesc = "Bloqueo instantaneo al centro de la cabeza",
        AimMagnet = "Iman de Balas (Hitbox)",
        AimMagnetDesc = "Expande la cabeza enemiga para rango maximo",
        AimMagnetSize = "Radio de Cabeza (Studs)",
        AimMagnetSizeDesc = "Tamano del hitbox de impacto de cabeza",
        AimVis = "Chequeo Visible",
        AimVisDesc = "Ignorar enemigos detras de muros",
        AimTeam = "Filtro de Equipo",
        AimTeamDesc = "Ignorar companeros de equipo",
        AimFOV = "Radio de FOV",
        AimFOVDesc = "Angulo de alcance del objetivo",
        AimSmooth = "Suavizado de Mira",
        AimSmoothDesc = "0 = Instantaneo, Mayor = Mas suave",
        AimDist = "Distancia Maxima",
        AimDistDesc = "Rango de activacion en studs",
        ESPEnabled = "ESP Maestro",
        ESPEnabledDesc = "Interruptor maestro de visuales",
        ESPBox = "Cajas 2D",
        ESPBoxDesc = "Bordes alrededor de enemigos vivos",
        ESPName = "Nombres",
        ESPNameDesc = "Mostrar nombre del jugador",
        ESPHealth = "Barras de Salud",
        ESPHealthDesc = "Barra de vida en tiempo real",
        ESPDist = "Etiqueta de Distancia",
        ESPDistDesc = "Mostrar distancia en metros",
        ESPTracer = "Lineas de Rastreo",
        ESPTracerDesc = "Trazar lineas hacia enemigos",
        ESPSkeleton = "Esqueleto ESP",
        ESPSkeletonDesc = "Dibujar lineas de esqueleto en objetivos",
        ESPTeam = "Chequeo de Equipo",
        ESPTeamDesc = "Ocultar ESP en companeros",
        ESPRange = "Rango de ESP",
        ESPRangeDesc = "Distancia maxima de dibujo",
        VisFOV = "Circulo de FOV",
        VisFOVDesc = "Dibujar radio del aimbot",
        VisCross = "Reticula Tactica",
        VisCrossDesc = "Reticula centrada en pantalla",
        LangTitle = "Idioma",
        LangDesc = "Seleccionar idioma de la interfaz",
        ThemeTitle = "Color del Tema",
        ThemeDesc = "Personalizar paleta de colores",
        StyleTitle = "Estilo de Menu",
        StyleDesc = "Efectos visuales globales de la interfaz",
        MenuSounds = "Sonidos de Menu",
        MenuSoundsDesc = "Reproducir clics tactiles",
        MenuAnim = "Animaciones UI",
        MenuAnimDesc = "Habilitar transiciones suaves",
        PillText = "MENU SHUT",
    }
}

--// CONFIG
local Config = {
    Aim = {
        Enabled = true,
        HitboxExpander = true,
        HitboxSize = 4.2,
        FOV = 140,
        Smoothness = 0.04,
        TargetPart = "Head",
        VisibleCheck = true,
        TeamCheck = true,
        MaxDistance = 2500,
    },
    ESP = {
        Enabled = true,
        Box = true,
        Name = true,
        Health = true,
        Distance = true,
        Tracer = false,
        Skeleton = true,
        TeamCheck = true,
        MaxDistance = 2500,
    },
    Visuals = {
        FOVCircle = true,
        Crosshair = true,
    },
    UI = {
        CurrentTheme = "Cyan",
        Language = "RU", -- По умолчанию Русский
        Style = "Classic",
        Sounds = true,
        Animations = true,
    }
}

local function tr(key)
    local cur = Dict[Config.UI.Language] or Dict.EN
    return cur[key] or Dict.EN[key] or key
end

--// THEMES
local Themes = {
    Cyan     = { Accent = Color3.fromRGB(0, 235, 255), Accent2 = Color3.fromRGB(130, 0, 255) },
    Crimson  = { Accent = Color3.fromRGB(255, 50, 85),  Accent2 = Color3.fromRGB(255, 130, 0) },
    Emerald  = { Accent = Color3.fromRGB(50, 255, 130), Accent2 = Color3.fromRGB(0, 200, 255) },
    Purple   = { Accent = Color3.fromRGB(180, 75, 255), Accent2 = Color3.fromRGB(60, 110, 255) },
    Gold     = { Accent = Color3.fromRGB(255, 205, 45), Accent2 = Color3.fromRGB(255, 80, 0) }
}

local C = {
    Bg        = Color3.fromRGB(10, 11, 18),
    Sidebar   = Color3.fromRGB(14, 15, 24),
    CardOff   = Color3.fromRGB(18, 19, 30),
    CardOn    = Color3.fromRGB(27, 26, 44),
    StrokeOff = Color3.fromRGB(40, 42, 65),
    Stroke    = Color3.fromRGB(65, 75, 120),

    White     = Color3.fromRGB(255, 255, 255),
    Text      = Color3.fromRGB(235, 238, 250),
    Sub       = Color3.fromRGB(145, 150, 180),
    Muted     = Color3.fromRGB(90, 95, 120),

    Accent    = Themes.Cyan.Accent,
    Accent2   = Themes.Cyan.Accent2,

    Green     = Color3.fromRGB(65, 245, 130),
    Red       = Color3.fromRGB(255, 65, 85),
}

--// SOUNDS
local SoundClick = Instance.new("Sound")
SoundClick.SoundId = "rbxassetid://6895079853"
SoundClick.Volume = 0.6
SoundClick.Parent = SoundService

local SoundTab = Instance.new("Sound")
SoundTab.SoundId = "rbxassetid://6895079853"
SoundTab.Volume = 0.45
SoundTab.Pitch = 1.25
SoundTab.Parent = SoundService

local function playSound(s)
    if Config.UI.Sounds then pcall(function() s:Play() end) end
end

--// UI HELPERS
local function tw(obj, time, props, style, direction)
    if not obj or not Config.UI.Animations then
        for k, v in pairs(props) do pcall(function() obj[k] = v end) end
        return nil 
    end
    local t = TweenService:Create(
        obj,
        TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = parent
    return c
end

local function stroke(parent, color, transparency, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or C.Stroke
    s.Transparency = transparency or 0
    s.Thickness = thickness or 1
    s.Parent = parent
    return s
end

local function gradient(parent, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2)
    })
    g.Rotation = rot or 0
    g.Parent = parent
    return g
end

local function text(parent, str, size, pos, fontSize, color, zidx)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = str or ""
    l.Size = size or UDim2.fromScale(1, 1)
    l.Position = pos or UDim2.fromScale(0, 0)
    l.Font = Enum.Font.GothamBold -- Улучшенная поддержка кириллицы
    l.TextSize = fontSize or 11
    l.TextColor3 = color or C.Text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = zidx or 25
    l.Parent = parent
    return l
end

local function button(parent, size, pos, zidx)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.Text = ""
    b.BorderSizePixel = 0
    b.BackgroundTransparency = 1
    b.Size = size
    b.Position = pos
    b.ZIndex = zidx or 20
    b.Parent = parent
    return b
end

local function copyToClipboard(str)
    local clipFunc = setclipboard or toclipboard or (syn and syn.write_clipboard) or (Clipboard and Clipboard.set)
    if clipFunc then pcall(clipFunc, str) return true end
    return false
end

local function getSafeContainer()
    local target = nil
    pcall(function()
        if gethui then target = gethui()
        elseif game:GetService("CoreGui") then target = game:GetService("CoreGui") end
    end)
    return target or LocalPlayer:WaitForChild("PlayerGui")
end

local SafeContainer = getSafeContainer()
local function genId() return "SHUT_" .. string.sub(HttpService:GenerateGUID(false), 1, 8) end

--// SCREEN GUIS
local OverlayGui = Instance.new("ScreenGui")
OverlayGui.Name = genId()
OverlayGui.ResetOnSpawn = false
OverlayGui.IgnoreGuiInset = true
OverlayGui.DisplayOrder = 9998
OverlayGui.Parent = SafeContainer
table.insert(Cleanups, OverlayGui)

local MenuGui = Instance.new("ScreenGui")
MenuGui.Name = genId()
MenuGui.ResetOnSpawn = false
MenuGui.IgnoreGuiInset = true
MenuGui.DisplayOrder = 9999
MenuGui.Parent = SafeContainer
table.insert(Cleanups, MenuGui)

--// ROBUST TEAM CHECK (FIXED FOR RIVALS AND CUSTOM TEAM SYSTEMS)
local function isTeammate(p)
    if not p or p == LocalPlayer then return true end

    -- 1. Standard Roblox Teams
    if LocalPlayer.Team and p.Team and LocalPlayer.Team == p.Team then 
        return true 
    end

    -- 2. Rivals / Custom Attribute based Teams
    local attrs = {"Team", "TeamId", "team"}
    for _, attr in ipairs(attrs) do
        local myAttr = LocalPlayer:GetAttribute(attr) or (LocalPlayer.Character and LocalPlayer.Character:GetAttribute(attr))
        local pAttr = p:GetAttribute(attr) or (p.Character and p.Character:GetAttribute(attr))
        if myAttr ~= nil and pAttr ~= nil and myAttr == pAttr then
            return true
        end
    end

    -- 3. ValueBases in Player
    for _, valName in ipairs({"Team", "TeamValue", "TeamName"}) do
        local myVal = LocalPlayer:FindFirstChild(valName)
        local pVal = p:FindFirstChild(valName)
        if myVal and pVal and myVal:IsA("ValueBase") and pVal:IsA("ValueBase") then
            if myVal.Value == pVal.Value and tostring(myVal.Value) ~= "" then 
                return true 
            end
        end
    end
    
    return false
end

--// FAST DEAD-PLAYER PURGE
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
    if char:GetAttribute("Dead") == true or char:GetAttribute("IsDead") == true or char:GetAttribute("Killed") == true then return false end
    local head = char:FindFirstChild("Head") or char:FindFirstChild("FakeHead") or char:FindFirstChild("HeadHB")
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not head or not root then return false end
    if head.Transparency >= 0.95 and root.Transparency >= 0.95 then return false end
    return true
end

local function getCharParts(char)
    if not char or not char:IsDescendantOf(workspace) then return nil, nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local head = char:FindFirstChild("Head") or char:FindFirstChild("FakeHead") or char:FindFirstChild("HeadHB")
    local hbFolder = char:FindFirstChild("Hitbox") or char:FindFirstChild("Hitboxes") or char:FindFirstChild("HitBoxes")
    if hbFolder then head = hbFolder:FindFirstChild("Head") or hbFolder:FindFirstChild("HeadHB") or head end
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        or (hbFolder and (hbFolder:FindFirstChild("HumanoidRootPart") or hbFolder:FindFirstChild("Torso")))
        or char.PrimaryPart
    if not head and root then head = root end
    if not root and head then root = head end
    return hum, root, head
end

--// HITBOX EXPANDER
local OriginalSizes = {}
table.insert(Cleanups, RunService.Heartbeat:Connect(function()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local alive = isAlivePlayer(p)
            local sameTeam = isTeammate(p)
            local _, _, head = getCharParts(p.Character)
            
            -- Остановка расширения для тиммейтов
            if alive and (not Config.Aim.TeamCheck or not sameTeam) and head and head:IsA("BasePart") then
                if Config.Aim.HitboxExpander then
                    if not OriginalSizes[head] then OriginalSizes[head] = head.Size end
                    local sz = Config.Aim.HitboxSize
                    head.Size = Vector3.new(sz, sz, sz)
                    head.CanCollide = false
                    head.CanQuery = true
                    head.CanTouch = true
                else
                    if OriginalSizes[head] then
                        head.Size = OriginalSizes[head]
                        OriginalSizes[head] = nil
                    end
                end
            else
                if head and OriginalSizes[head] then
                    head.Size = OriginalSizes[head]
                    OriginalSizes[head] = nil
                end
            end
        end
    end
end))

--// VISIBLE CHECK
local function isPartVisible(targetPart, targetChar)
    if not Camera or not targetPart or not targetChar then return false end
    local camPos = Camera.CFrame.Position
    local targetPos = targetPart.Position
    local fullDir = targetPos - camPos
    local dist = fullDir.Magnitude
    if dist < 1.5 then return true end

    local rayOrigin = camPos + (fullDir.Unit * 1.2)
    local rayDir = targetPos - rayOrigin
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude

    local ignoreList = {Camera}
    if LocalPlayer.Character then table.insert(ignoreList, LocalPlayer.Character) end
    for _, item in ipairs(Camera:GetChildren()) do table.insert(ignoreList, item) end
    for _, folderName in ipairs({"Viewmodel", "Arms", "Ignore", "Debris", "Bullets", "RaycastIgnore", "Effects", "Particles", "DropWeapons", "DroppedGuns", "Smoke", "Grenades"}) do
        local f = workspace:FindFirstChild(folderName) or Camera:FindFirstChild(folderName)
        if f then table.insert(ignoreList, f) end
    end
    params.FilterDescendantsInstances = ignoreList
    params.IgnoreWater = true

    local currOrigin = rayOrigin
    local currDir = rayDir

    for _ = 1, 6 do
        local hit = workspace:Raycast(currOrigin, currDir, params)
        if not hit then return true end
        local inst = hit.Instance
        if not inst then return true end
        if inst:IsDescendantOf(targetChar) then return true end
        
        local name = inst.Name:lower()
        local isClip = name:find("clip") or name:find("barrier") or name:find("invis") or name:find("trigger") or name:find("border") or name:find("boundary")
        local isTransparent = inst.Transparency >= 0.35
        local isNonCollidable = (not inst.CanCollide)

        if isClip or isTransparent or isNonCollidable or inst:IsA("Accessory") or inst.Name == "Handle" then
            table.insert(ignoreList, inst)
            params.FilterDescendantsInstances = ignoreList
            if (hit.Position - currOrigin).Magnitude >= currDir.Magnitude - 0.25 then return true end
            currOrigin = hit.Position + (currDir.Unit * 0.1)
            currDir = targetPos - currOrigin
        else
            return false
        end
    end
    return false
end

--// FOV CIRCLE & CROSSHAIR
local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Size = UDim2.fromOffset(Config.Aim.FOV * 2, Config.Aim.FOV * 2)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.Visible = Config.Visuals.FOVCircle
FOVCircle.ZIndex = 5
FOVCircle.Parent = OverlayGui
corner(FOVCircle, 999)
local FOVStroke = stroke(FOVCircle, C.Accent, 0.2, 1.2)

local Crosshair = Instance.new("Frame")
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.Position = UDim2.fromScale(0.5, 0.5)
Crosshair.Size = UDim2.fromOffset(22, 22)
Crosshair.BackgroundTransparency = 1
Crosshair.Visible = Config.Visuals.Crosshair
Crosshair.ZIndex = 5
Crosshair.Parent = OverlayGui

for _, spec in ipairs({
    {size = UDim2.fromOffset(6, 2), pos = UDim2.fromOffset(1, 10)},
    {size = UDim2.fromOffset(6, 2), pos = UDim2.fromOffset(15, 10)},
    {size = UDim2.fromOffset(2, 6), pos = UDim2.fromOffset(10, 1)},
    {size = UDim2.fromOffset(2, 6), pos = UDim2.fromOffset(10, 15)},
}) do
    local b = Instance.new("Frame")
    b.BorderSizePixel = 0
    b.BackgroundColor3 = C.Accent
    b.Size = spec.size
    b.Position = spec.pos
    b.Parent = Crosshair
    corner(b, 2)
end

--// MAIN MENU FRAME
local Shadow = Instance.new("Frame")
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.Position = UDim2.fromScale(0.5, 0.5)
Shadow.Size = UDim2.fromOffset(530, 360)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.35
Shadow.BorderSizePixel = 0
Shadow.ZIndex = 4
Shadow.Parent = MenuGui
corner(Shadow, 16)

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.Size = UDim2.fromOffset(530, 360)
Main.BackgroundColor3 = C.Bg
Main.BorderSizePixel = 0
Main.ZIndex = 5
Main.ClipsDescendants = true
Main.Parent = MenuGui
corner(Main, 16)
local MainBorder = stroke(Main, C.Accent, 0.2, 1.4)

local DecoBack = Instance.new("Frame", Main)
DecoBack.Size = UDim2.fromScale(1, 1)
DecoBack.BackgroundTransparency = 1
DecoBack.ZIndex = 5

for i = 1, 4 do
    local bolt = Instance.new("Frame", DecoBack)
    bolt.BackgroundColor3 = C.Accent
    bolt.BorderSizePixel = 0
    bolt.BackgroundTransparency = 0.88
    bolt.ZIndex = 5
    bolt.Size = UDim2.fromOffset(140 + (i * 20), 2)
    bolt.Position = UDim2.new(0.18 * i, 0, 0.18 * i, 0)
    bolt.Rotation = -32 + (i * 16)
    corner(bolt, 4)
    gradient(bolt, C.Accent, C.Accent2, 90)
end

local MainScale = Instance.new("UIScale")
MainScale.Scale = 1
MainScale.Parent = Main

local function updateScale()
    Camera = workspace.CurrentCamera or Camera
    local v = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
    if v.X < 720 then MainScale.Scale = math.clamp(v.X / 600, 0.60, 0.85)
    else MainScale.Scale = 1 end
end
table.insert(Cleanups, Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale))
updateScale()

local AccentLine = Instance.new("Frame", Main)
AccentLine.Size = UDim2.new(1, -20, 0, 2)
AccentLine.Position = UDim2.fromOffset(10, 0)
AccentLine.BackgroundColor3 = C.Accent
AccentLine.BorderSizePixel = 0
AccentLine.ZIndex = 8
corner(AccentLine, 4)
local AccentGrad = gradient(AccentLine, C.Accent, C.Accent2, 0)

--// SIDEBAR
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.fromOffset(150, 360)
Sidebar.BackgroundColor3 = C.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 6
corner(Sidebar, 16)

local LogoCard = Instance.new("Frame", Sidebar)
LogoCard.Size = UDim2.new(1, -16, 0, 52)
LogoCard.Position = UDim2.fromOffset(8, 8)
LogoCard.BackgroundTransparency = 1
LogoCard.ZIndex = 7

local LogoBadge = Instance.new("Frame", LogoCard)
LogoBadge.Size = UDim2.fromOffset(36, 36)
LogoBadge.Position = UDim2.fromOffset(2, 8)
LogoBadge.BackgroundColor3 = C.Accent
LogoBadge.BorderSizePixel = 0
LogoBadge.ZIndex = 8
corner(LogoBadge, 10)
local LogoGrad = gradient(LogoBadge, C.Accent, C.Accent2, 45)

local LogoMark = text(LogoBadge, "SH", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), 14, C.White, 9)
LogoMark.Font = Enum.Font.GothamBlack
LogoMark.TextXAlignment = Enum.TextXAlignment.Center

local TitleLabel = text(LogoCard, SCRIPT_TITLE, UDim2.fromOffset(92, 18), UDim2.fromOffset(42, 6), 13, C.White, 8)
TitleLabel.Font = Enum.Font.GothamBlack
local SubtitleLabel = text(LogoCard, tr("Subtitle"), UDim2.fromOffset(92, 14), UDim2.fromOffset(43, 24), 7, C.Accent, 8)

local TabHolder = Instance.new("Frame", Sidebar)
TabHolder.Size = UDim2.new(1, -16, 0, 280)
TabHolder.Position = UDim2.fromOffset(8, 66)
TabHolder.BackgroundTransparency = 1
TabHolder.ZIndex = 7

local TabLayout = Instance.new("UIListLayout", TabHolder)
TabLayout.Padding = UDim.new(0, 4)

local Tabs = {}
local TabFrames = {}
local CurrentTabId = "AIM"

local function createTabButton(id, titleKey, badgeText)
    local b = button(TabHolder, UDim2.new(1, 0, 0, 36), UDim2.new(), 8)
    b.BackgroundColor3 = C.CardOff
    b.BackgroundTransparency = 1
    corner(b, 9)

    local activeIndicator = Instance.new("Frame", b)
    activeIndicator.Size = UDim2.fromOffset(3, 18)
    activeIndicator.Position = UDim2.new(0, 0, 0.5, -9)
    activeIndicator.BackgroundColor3 = C.Accent
    activeIndicator.BorderSizePixel = 0
    activeIndicator.Visible = false
    activeIndicator.ZIndex = 10
    corner(activeIndicator, 3)

    local iconBox = Instance.new("Frame", b)
    iconBox.Size = UDim2.fromOffset(24, 24)
    iconBox.Position = UDim2.fromOffset(6, 6)
    iconBox.BackgroundColor3 = C.Bg
    iconBox.BorderSizePixel = 0
    iconBox.ZIndex = 9
    corner(iconBox, 7)

    local badge = text(iconBox, badgeText, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), 9, C.Sub, 10)
    badge.Font = Enum.Font.GothamBlack
    badge.TextXAlignment = Enum.TextXAlignment.Center

    local t = text(b, tr(titleKey), UDim2.fromOffset(92, 24), UDim2.fromOffset(36, 6), 9, C.Text, 10)
    Tabs[id] = { Button = b, Bar = activeIndicator, Badge = badge, Title = t, Key = titleKey }

    b.MouseEnter:Connect(function() tw(b, 0.1, {BackgroundTransparency = 0.25, BackgroundColor3 = C.CardOn}) end)
    b.MouseLeave:Connect(function()
        local cur = Tabs[id]
        tw(b, 0.1, {BackgroundTransparency = (cur and cur.Bar.Visible) and 0.05 or 1, BackgroundColor3 = C.CardOff})
    end)
    return b
end

createTabButton("AIM", "TabAim", "AIM")
createTabButton("ESP", "TabESP", "ESP")
createTabButton("VISUALS", "TabVis", "VIS")
createTabButton("STATUS", "TabStat", "INF")
createTabButton("SETTINGS", "TabSet", "CFG")

--// CONTENT AREA
local ContentArea = Instance.new("Frame", Main)
ContentArea.Size = UDim2.new(1, -150, 1, 0)
ContentArea.Position = UDim2.fromOffset(150, 0)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 6

local Header = Instance.new("Frame", ContentArea)
Header.Size = UDim2.new(1, 0, 0, 52)
Header.BackgroundTransparency = 1
Header.ZIndex = 7

local HeaderTitle = text(Header, tr("TabAim"), UDim2.fromOffset(220, 20), UDim2.fromOffset(16, 12), 15, C.White, 15)
HeaderTitle.Font = Enum.Font.GothamBlack
local HeaderDesc = text(Header, tr("HeaderAimDesc"), UDim2.new(280, 14), UDim2.fromOffset(17, 30), 8, C.Sub, 15)

local CloseBtn = button(Header, UDim2.fromOffset(22, 22), UDim2.new(1, -28, 0, 14), 16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(45, 48, 68)
corner(CloseBtn, 6)
local CloseTxt = text(CloseBtn, "✕", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), 11, C.White, 17)
CloseTxt.TextXAlignment = Enum.TextXAlignment.Center

local PagesFrame = Instance.new("Frame", ContentArea)
PagesFrame.Size = UDim2.new(1, -24, 1, -62)
PagesFrame.Position = UDim2.fromOffset(12, 54)
PagesFrame.BackgroundTransparency = 1
PagesFrame.ZIndex = 7

local function createPage(id)
    local page = Instance.new("ScrollingFrame")
    page.Name = id
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = C.Accent
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new()
    page.Visible = false
    page.ZIndex = 8
    page.Parent = PagesFrame

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0, 6)
    local pad = Instance.new("UIPadding", page)
    pad.PaddingRight = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 12)

    TabFrames[id] = page
    return page
end

local AimPage = createPage("AIM")
local ESPPage = createPage("ESP")
local VisualPage = createPage("VISUALS")
local StatusPage = createPage("STATUS")
local SettingsPage = createPage("SETTINGS")

--// NOTIFICATIONS
local ToastContainer = Instance.new("Frame", MenuGui)
ToastContainer.Size = UDim2.fromOffset(230, 160)
ToastContainer.Position = UDim2.new(1, -12, 1, -12)
ToastContainer.AnchorPoint = Vector2.new(1, 1)
ToastContainer.BackgroundTransparency = 1
ToastContainer.ZIndex = 100

local function notify(titleStr, subStr)
    local card = Instance.new("Frame", ToastContainer)
    card.Size = UDim2.fromOffset(220, 50)
    card.Position = UDim2.new(1, 10, 1, -55)
    card.BackgroundColor3 = C.Sidebar
    card.ZIndex = 100
    corner(card, 8)
    stroke(card, C.Accent, 0.35, 1)

    local bar = Instance.new("Frame", card)
    bar.Size = UDim2.fromOffset(3, 32)
    bar.Position = UDim2.fromOffset(6, 9)
    bar.BackgroundColor3 = C.Accent
    bar.BorderSizePixel = 0
    bar.ZIndex = 101
    corner(bar, 2)

    text(card, titleStr, UDim2.new(1, -20, 0, 15), UDim2.fromOffset(15, 6), 9, C.White, 101)
    local s = text(card, subStr, UDim2.new(1, -20, 0, 18), UDim2.fromOffset(15, 24), 8, C.Sub, 101)
    s.TextWrapped = true

    tw(card, 0.25, {Position = UDim2.new(1, -225, 1, -55)}, Enum.EasingStyle.Back)
    task.delay(2.6, function()
        if card.Parent then
            tw(card, 0.2, {Position = UDim2.new(1, 10, 1, -55)})
            task.delay(0.25, function() if card.Parent then card:Destroy() end end)
        end
    end)
end

--// TELEGRAM POPUP (BEAUTIFUL ENTRANCE)
local TgCard = Instance.new("Frame", MenuGui)
TgCard.Name = "TelegramPrompt"
TgCard.Size = UDim2.fromOffset(255, 105)
TgCard.Position = UDim2.new(1, 280, 0, 20)
TgCard.BackgroundColor3 = C.Sidebar
TgCard.BorderSizePixel = 0
TgCard.ZIndex = 120
corner(TgCard, 12)
stroke(TgCard, C.Accent, 0.3, 1.4)

local tgGlow = Instance.new("Frame", TgCard)
tgGlow.Size = UDim2.new(1, -12, 0, 2)
tgGlow.Position = UDim2.fromOffset(6, 0)
tgGlow.BackgroundColor3 = C.Accent
tgGlow.BorderSizePixel = 0
tgGlow.ZIndex = 121
corner(tgGlow, 2)

local tgTitle = text(TgCard, tr("TgTitle"), UDim2.new(1, -40, 0, 16), UDim2.fromOffset(12, 10), 10, C.White, 122)
tgTitle.Font = Enum.Font.GothamBlack
local tgClose = button(TgCard, UDim2.fromOffset(18, 18), UDim2.new(1, -26, 0, 8), 125)
local tgCloseTxt = text(tgClose, "✕", UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), 10, C.Muted, 126)
tgCloseTxt.TextXAlignment = Enum.TextXAlignment.Center

local tgDesc = text(TgCard, tr("TgDesc"), UDim2.new(1, -24, 0, 28), UDim2.fromOffset(12, 28), 8, C.Sub, 122)
tgDesc.TextWrapped = true

local tgCopyBtn = button(TgCard, UDim2.new(1, -24, 0, 28), UDim2.fromOffset(12, 65), 123)
tgCopyBtn.BackgroundColor3 = C.Accent
corner(tgCopyBtn, 7)
local tgBtnTxt = text(tgCopyBtn, tr("TgBtn"), UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), 9, C.White, 124)
tgBtnTxt.Font = Enum.Font.GothamBlack
tgBtnTxt.TextXAlignment = Enum.TextXAlignment.Center

tw(TgCard, 0.45, {Position = UDim2.new(1, -270, 0, 20)}, Enum.EasingStyle.Back)
tgCopyBtn.Activated:Connect(function()
    copyToClipboard(TG_LINK)
    playSound(SoundClick)
    tgBtnTxt.Text = tr("TgCopied")
    tgCopyBtn.BackgroundColor3 = C.Green
    notify("SHUT Telegram", tr("TgCopied"))
    task.delay(2.5, function() if tgCopyBtn.Parent then tgBtnTxt.Text = tr("TgBtn") tgCopyBtn.BackgroundColor3 = C.Accent end end)
end)
tgClose.Activated:Connect(function()
    tw(TgCard, 0.25, {Position = UDim2.new(1, 280, 0, 20)})
    task.delay(0.3, function() if TgCard.Parent then TgCard:Destroy() end end)
end)

--// DYNAMIC WIDGETS AND FULL LANG TRANSLATION ENGINE
local DynamicUpdaters = {}
local LangUpdaters = {}

local function toggleWidget(parent, titleKey, descKey, tbl, key)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, 0, 0, 48)
    card.BackgroundColor3 = tbl[key] and C.CardOn or C.CardOff
    card.ZIndex = 10
    corner(card, 8)
    local cardStroke = stroke(card, tbl[key] and C.Accent or C.StrokeOff, 0.4, 1)

    local b = button(card, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), 15)
    local titleLbl = text(card, tr(titleKey), UDim2.new(1, -75, 0, 16), UDim2.fromOffset(10, 6), 10, C.White, 25)
    local descLbl = text(card, tr(descKey), UDim2.new(1, -75, 0, 14), UDim2.fromOffset(10, 24), 8, C.Sub, 25)

    local track = Instance.new("Frame", card)
    track.Size = UDim2.fromOffset(32, 18)
    track.Position = UDim2.new(1, -44, 0.5, -9)
    track.BackgroundColor3 = tbl[key] and C.Accent or C.Muted
    track.BorderSizePixel = 0
    track.ZIndex = 26
    corner(track, 99)

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.fromOffset(12, 12)
    knob.Position = UDim2.fromOffset(tbl[key] and 17 or 3, 3)
    knob.BackgroundColor3 = C.White
    knob.BorderSizePixel = 0
    knob.ZIndex = 27
    corner(knob, 99)

    local function refresh(anim)
        local on = tbl[key]
        local tx = on and 17 or 3
        local col = on and C.Accent or C.Muted
        local bgCol = on and C.CardOn or C.CardOff
        local strCol = on and C.Accent or C.StrokeOff

        if anim then
            tw(track, 0.16, {BackgroundColor3 = col})
            tw(knob, 0.2, {Position = UDim2.fromOffset(tx, 3)}, Enum.EasingStyle.Back)
            tw(card, 0.18, {BackgroundColor3 = bgCol})
            tw(cardStroke, 0.18, {Color = strCol})
        else
            track.BackgroundColor3 = col
            knob.Position = UDim2.fromOffset(tx, 3)
            card.BackgroundColor3 = bgCol
            cardStroke.Color = strCol
        end
    end

    table.insert(DynamicUpdaters, function() refresh(false) end)
    table.insert(LangUpdaters, function() titleLbl.Text = tr(titleKey) descLbl.Text = tr(descKey) end)

    b.Activated:Connect(function() tbl[key] = not tbl[key] refresh(true) playSound(SoundClick) end)
    refresh(false)
    return card
end

local function sliderWidget(parent, titleKey, descKey, tbl, key, minV, maxV, dec)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, 0, 0, 60)
    card.BackgroundColor3 = C.CardOff
    card.ZIndex = 10
    corner(card, 8)
    stroke(card, C.StrokeOff, 0.4, 1)

    local titleLbl = text(card, tr(titleKey), UDim2.new(0.7, 0, 0, 16), UDim2.fromOffset(10, 6), 10, C.White, 25)
    local descLbl = text(card, tr(descKey), UDim2.new(0.7, 0, 0, 14), UDim2.fromOffset(10, 22), 8, C.Sub, 25)

    local valLbl = text(card, tostring(tbl[key]), UDim2.fromOffset(50, 16), UDim2.new(1, -60, 0, 6), 10, C.Accent, 25)
    valLbl.TextXAlignment = Enum.TextXAlignment.Right

    local bar = Instance.new("Frame", card)
    bar.Size = UDim2.new(1, -20, 0, 4)
    bar.Position = UDim2.fromOffset(10, 44)
    bar.BackgroundColor3 = C.Bg
    bar.BorderSizePixel = 0
    bar.ZIndex = 26
    corner(bar, 99)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = C.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 27
    corner(fill, 99)

    local knob = Instance.new("Frame", bar)
    knob.Size = UDim2.fromOffset(10, 10)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.fromScale(0, 0.5)
    knob.BackgroundColor3 = C.White
    knob.BorderSizePixel = 0
    knob.ZIndex = 28
    corner(knob, 99)

    table.insert(DynamicUpdaters, function() fill.BackgroundColor3 = C.Accent valLbl.TextColor3 = C.Accent end)
    table.insert(LangUpdaters, function() titleLbl.Text = tr(titleKey) descLbl.Text = tr(descKey) end)

    local isDrag = false
    local function update(x)
        local ratio = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
        local raw = minV + (maxV - minV) * ratio
        local mult = 10 ^ (dec or 0)
        local v = math.floor(raw * mult + 0.5) / mult
        tbl[key] = v
        fill.Size = UDim2.fromScale(ratio, 1)
        knob.Position = UDim2.new(ratio, 0, 0.5, 0)
        valLbl.Text = tostring(v)
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDrag = true update(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if isDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDrag = false end
    end)

    local initRatio = math.clamp((tbl[key] - minV) / (maxV - minV), 0, 1)
    fill.Size = UDim2.fromScale(initRatio, 1)
    knob.Position = UDim2.new(initRatio, 0, 0.5, 0)
    return card
end

-- AIM TAB
toggleWidget(AimPage, "AimEnabled", "AimEnabledDesc", Config.Aim, "Enabled")
toggleWidget(AimPage, "AimMagnet", "AimMagnetDesc", Config.Aim, "HitboxExpander")
sliderWidget(AimPage, "AimMagnetSize", "AimMagnetSizeDesc", Config.Aim, "HitboxSize", 1.5, 6.5, 1)
toggleWidget(AimPage, "AimVis", "AimVisDesc", Config.Aim, "VisibleCheck")
toggleWidget(AimPage, "AimTeam", "AimTeamDesc", Config.Aim, "TeamCheck")
sliderWidget(AimPage, "AimFOV", "AimFOVDesc", Config.Aim, "FOV", 40, 500, 0)
sliderWidget(AimPage, "AimSmooth", "AimSmoothDesc", Config.Aim, "Smoothness", 0.0, 0.65, 2)
sliderWidget(AimPage, "AimDist", "AimDistDesc", Config.Aim, "MaxDistance", 100, 3000, 0)

-- ESP TAB
toggleWidget(ESPPage, "ESPEnabled", "ESPEnabledDesc", Config.ESP, "Enabled")
toggleWidget(ESPPage, "ESPBox", "ESPBoxDesc", Config.ESP, "Box")
toggleWidget(ESPPage, "ESPName", "ESPNameDesc", Config.ESP, "Name")
toggleWidget(ESPPage, "ESPHealth", "ESPHealthDesc", Config.ESP, "Health")
toggleWidget(ESPPage, "ESPDist", "ESPDistDesc", Config.ESP, "Distance")
toggleWidget(ESPPage, "ESPTracer", "ESPTracerDesc", Config.ESP, "Tracer")
toggleWidget(ESPPage, "ESPSkeleton", "ESPSkeletonDesc", Config.ESP, "Skeleton")
toggleWidget(ESPPage, "ESPTeam", "ESPTeamDesc", Config.ESP, "TeamCheck")
sliderWidget(ESPPage, "ESPRange", "ESPRangeDesc", Config.ESP, "MaxDistance", 100, 3500, 0)

-- VISUALS TAB
toggleWidget(VisualPage, "VisFOV", "VisFOVDesc", Config.Visuals, "FOVCircle")
toggleWidget(VisualPage, "VisCross", "VisCrossDesc", Config.Visuals, "Crosshair")

-- STATUS TAB
local profCard = Instance.new("Frame", StatusPage)
profCard.Size = UDim2.new(1, 0, 0, 80)
profCard.BackgroundColor3 = C.CardOff
corner(profCard, 8)
stroke(profCard, C.StrokeOff, 0.4, 1)

local Avatar = Instance.new("ImageLabel", profCard)
Avatar.Size = UDim2.fromOffset(54, 54)
Avatar.Position = UDim2.fromOffset(10, 13)
Avatar.BackgroundColor3 = C.Bg
corner(Avatar, 8)
Avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"

local NameLbl = text(profCard, LocalPlayer.DisplayName, UDim2.new(1, -75, 0, 16), UDim2.fromOffset(72, 12), 11, C.White, 25)
local HandleLbl = text(profCard, "@" .. LocalPlayer.Name, UDim2.new(1, -75, 0, 14), UDim2.fromOffset(72, 30), 8, C.Sub, 25)
local profStatus = text(profCard, tr("EngineStatus"), UDim2.new(1, -75, 0, 14), UDim2.fromOffset(72, 46), 8, C.Accent, 25)

local matchCard = Instance.new("Frame", StatusPage)
matchCard.Size = UDim2.new(1, 0, 0, 75)
matchCard.BackgroundColor3 = C.CardOff
corner(matchCard, 8)
stroke(matchCard, C.StrokeOff, 0.4, 1)

local matchStatusTitle = text(matchCard, tr("StatusReady"), UDim2.new(1, -16, 0, 16), UDim2.fromOffset(10, 8), 9, C.Green, 25)
local matchInfo = text(matchCard, "", UDim2.new(1, -16, 0, 45), UDim2.fromOffset(10, 26), 8, C.Sub, 25)
matchInfo.TextWrapped = true

table.insert(LangUpdaters, function()
    profStatus.Text = tr("EngineStatus")
    matchStatusTitle.Text = tr("StatusReady")
end)

-- SETTINGS TAB
local langCard = Instance.new("Frame", SettingsPage)
langCard.Size = UDim2.new(1, 0, 0, 60)
langCard.BackgroundColor3 = C.CardOff
corner(langCard, 8)
stroke(langCard, C.StrokeOff, 0.4, 1)

local langTitleLbl = text(langCard, tr("LangTitle"), UDim2.new(0.6, 0, 0, 16), UDim2.fromOffset(10, 6), 10, C.White, 25)
local langDescLbl = text(langCard, tr("LangDesc"), UDim2.new(0.6, 0, 0, 14), UDim2.fromOffset(10, 22), 8, C.Sub, 25)

table.insert(LangUpdaters, function()
    langTitleLbl.Text = tr("LangTitle")
    langDescLbl.Text = tr("LangDesc")
end)

local langBtnsHolder = Instance.new("Frame", langCard)
langBtnsHolder.Size = UDim2.fromOffset(170, 30)
langBtnsHolder.Position = UDim2.new(1, -180, 0.5, -15)
langBtnsHolder.BackgroundTransparency = 1
langBtnsHolder.ZIndex = 25
local langLayout = Instance.new("UIListLayout", langBtnsHolder)
langLayout.FillDirection = Enum.FillDirection.Horizontal
langLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
langLayout.VerticalAlignment = Enum.VerticalAlignment.Center
langLayout.Padding = UDim.new(0, 5)

local function applyLanguageWithAnimation(langCode)
    if Config.UI.Language == langCode then return end
    playSound(SoundClick)
    tw(MainScale, 0.22, {Scale = 0.05}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    tw(Main, 0.22, {Rotation = -8}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    tw(Shadow, 0.22, {BackgroundTransparency = 1})

    task.delay(0.24, function()
        Config.UI.Language = langCode
        SubtitleLabel.Text = tr("Subtitle")
        HeaderTitle.Text = tr(Tabs[CurrentTabId].Key)
        HeaderDesc.Text = (CurrentTabId == "AIM" and tr("HeaderAimDesc")) or (CurrentTabId == "ESP" and tr("HeaderESPDesc")) or (CurrentTabId == "VISUALS" and tr("HeaderVisDesc")) or (CurrentTabId == "STATUS" and tr("HeaderStatDesc")) or tr("HeaderSetDesc")
        
        for _, tabData in pairs(Tabs) do tabData.Title.Text = tr(tabData.Key) end
        tgTitle.Text = tr("TgTitle") 
        tgDesc.Text = tr("TgDesc") 
        tgBtnTxt.Text = tr("TgBtn")
        
        for _, fn in ipairs(LangUpdaters) do pcall(fn) end

        Main.Rotation = 8
        MainScale.Scale = 0.05
        task.wait(0.05)
        tw(MainScale, 0.35, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tw(Main, 0.3, {Rotation = 0}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tw(Shadow, 0.3, {BackgroundTransparency = (Config.UI.Style == "Ghost" and 1) or (Config.UI.Style == "Glass" and 0.7) or 0.35})
        notify("SHUT", "Language set to " .. langCode)
    end)
end

for _, lInfo in ipairs({ {code = "EN", name = "EN"}, {code = "RU", name = "RU"}, {code = "ES", name = "ES"} }) do
    local lb = button(langBtnsHolder, UDim2.fromOffset(48, 26), UDim2.new(), 26)
    lb.BackgroundColor3 = C.Bg
    corner(lb, 6)
    stroke(lb, C.StrokeOff, 0.3, 1)
    local lt = text(lb, lInfo.name, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), 9, C.White, 27)
    lt.TextXAlignment = Enum.TextXAlignment.Center
    lb.Activated:Connect(function() applyLanguageWithAnimation(lInfo.code) end)
end

--// UI STYLES
local styleCard = Instance.new("Frame", SettingsPage)
styleCard.Size = UDim2.new(1, 0, 0, 60)
styleCard.BackgroundColor3 = C.CardOff
corner(styleCard, 8)
stroke(styleCard, C.StrokeOff, 0.4, 1)

local styleTitleLbl = text(styleCard, tr("StyleTitle"), UDim2.new(0.6, 0, 0, 16), UDim2.fromOffset(10, 6), 10, C.White, 25)
local styleDescLbl = text(styleCard, tr("StyleDesc"), UDim2.new(0.6, 0, 0, 14), UDim2.fromOffset(10, 22), 8, C.Sub, 25)

table.insert(LangUpdaters, function()
    styleTitleLbl.Text = tr("StyleTitle")
    styleDescLbl.Text = tr("StyleDesc")
end)

local styleBtnsHolder = Instance.new("Frame", styleCard)
styleBtnsHolder.Size = UDim2.fromOffset(170, 30)
styleBtnsHolder.Position = UDim2.new(1, -180, 0.5, -15)
styleBtnsHolder.BackgroundTransparency = 1
styleBtnsHolder.ZIndex = 25
local styleLayout = Instance.new("UIListLayout", styleBtnsHolder)
styleLayout.FillDirection = Enum.FillDirection.Horizontal
styleLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
styleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
styleLayout.Padding = UDim.new(0, 5)

local function applyMenuStyle(styleName)
    if Config.UI.Style == styleName then return end
    Config.UI.Style = styleName
    playSound(SoundClick)

    tw(MainScale, 0.2, {Scale = 0.75}, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
    tw(Main, 0.2, {Rotation = (styleName == "Glass" and 6) or (styleName == "Dark" and -6) or 3})

    task.delay(0.2, function()
        if styleName == "Classic" then
            tw(Main, 0.3, {BackgroundTransparency = 0, BackgroundColor3 = C.Bg})
            tw(Sidebar, 0.3, {BackgroundTransparency = 0, BackgroundColor3 = C.Sidebar})
            tw(Shadow, 0.3, {BackgroundTransparency = 0.35})
            tw(MainBorder, 0.3, {Transparency = 0.2})
        elseif styleName == "Glass" then
            tw(Main, 0.3, {BackgroundTransparency = 0.35, BackgroundColor3 = Color3.fromRGB(15, 15, 25)})
            tw(Sidebar, 0.3, {BackgroundTransparency = 0.45, BackgroundColor3 = Color3.fromRGB(10, 10, 20)})
            tw(Shadow, 0.3, {BackgroundTransparency = 0.75})
            tw(MainBorder, 0.3, {Transparency = 0.5})
        elseif styleName == "Dark" then
            tw(Main, 0.3, {BackgroundTransparency = 0.05, BackgroundColor3 = Color3.fromRGB(5, 5, 5)})
            tw(Sidebar, 0.3, {BackgroundTransparency = 0.1, BackgroundColor3 = Color3.fromRGB(8, 8, 8)})
            tw(Shadow, 0.3, {BackgroundTransparency = 0.95})
            tw(MainBorder, 0.3, {Transparency = 0.85})
        end
        tw(MainScale, 0.45, {Scale = 1}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tw(Main, 0.4, {Rotation = 0}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        notify("SHUT Style", "Applied style: " .. styleName)
    end)
end

for _, sInfo in ipairs({ {id = "Classic", name = "CLS"}, {id = "Glass", name = "GLS"}, {id = "Dark", name = "DRK"} }) do
    local sb = button(styleBtnsHolder, UDim2.fromOffset(48, 26), UDim2.new(), 26)
    sb.BackgroundColor3 = C.Bg
    corner(sb, 6)
    stroke(sb, C.StrokeOff, 0.3, 1)
    local st = text(sb, sInfo.name, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), 9, C.White, 27)
    st.TextXAlignment = Enum.TextXAlignment.Center
    sb.Activated:Connect(function() applyMenuStyle(sInfo.id) end)
end

local themeCard = Instance.new("Frame", SettingsPage)
themeCard.Size = UDim2.new(1, 0, 0, 46)
themeCard.BackgroundColor3 = C.CardOff
corner(themeCard, 8)
stroke(themeCard, C.StrokeOff, 0.4, 1)
local themeLayout = Instance.new("UIListLayout", themeCard)
themeLayout.FillDirection = Enum.FillDirection.Horizontal
themeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
themeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
themeLayout.Padding = UDim.new(0, 6)

local function applyTheme(name)
    local t = Themes[name]
    if not t then return end
    Config.UI.CurrentTheme = name
    C.Accent = t.Accent
    C.Accent2 = t.Accent2

    AccentLine.BackgroundColor3 = C.Accent
    AccentGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, C.Accent), ColorSequenceKeypoint.new(1, C.Accent2)})
    LogoBadge.BackgroundColor3 = C.Accent
    LogoGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, C.Accent), ColorSequenceKeypoint.new(1, C.Accent2)})
    FOVStroke.Color = C.Accent
    MainBorder.Color = C.Accent
    tgGlow.BackgroundColor3 = C.Accent

    for _, updater in ipairs(DynamicUpdaters) do pcall(updater) end
    for _, tabData in pairs(Tabs) do tabData.Bar.BackgroundColor3 = C.Accent end
    playSound(SoundClick)
end

for _, tName in ipairs({"Cyan", "Crimson", "Emerald", "Purple", "Gold"}) do
    local tb = button(themeCard, UDim2.fromOffset(56, 28), UDim2.new(), 25)
    tb.BackgroundColor3 = Themes[tName].Accent
    corner(tb, 6)
    local tt = text(tb, tName, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), 8, C.White, 26)
    tt.TextXAlignment = Enum.TextXAlignment.Center
    tb.Activated:Connect(function() applyTheme(tName) end)
end

toggleWidget(SettingsPage, "MenuSounds", "MenuSoundsDesc", Config.UI, "Sounds")
toggleWidget(SettingsPage, "MenuAnim", "MenuAnimDesc", Config.UI, "Animations")

--// TAB SWITCHER
local function setTab(id)
    CurrentTabId = id
    playSound(SoundTab)
    for tid, f in pairs(TabFrames) do
        if tid == id then
            f.Visible = true
            f.CanvasPosition = Vector2.zero
            f.Position = UDim2.fromOffset(0, 8)
            tw(f, 0.18, {Position = UDim2.fromOffset(0, 0)})
        else
            f.Visible = false
        end
    end

    HeaderTitle.Text = tr(Tabs[id].Key)
    HeaderDesc.Text = (id == "AIM" and tr("HeaderAimDesc")) or (id == "ESP" and tr("HeaderESPDesc")) or (id == "VISUALS" and tr("HeaderVisDesc")) or (id == "STATUS" and tr("HeaderStatDesc")) or tr("HeaderSetDesc")

    for tid, data in pairs(Tabs) do
        local active = (tid == id)
        data.Bar.Visible = active
        tw(data.Button, 0.12, {BackgroundTransparency = active and 0.05 or 1, BackgroundColor3 = C.CardOff})
        data.Title.TextColor3 = active and C.White or C.Text
    end
end

for id, data in pairs(Tabs) do data.Button.Activated:Connect(function() setTab(id) end) end
setTab("AIM")
applyTheme(Config.UI.CurrentTheme or "Cyan")

--// FLOATING ACTION PILL
local FloatToggle = Instance.new("Frame", MenuGui)
FloatToggle.Size = UDim2.fromOffset(125, 32)
FloatToggle.Position = UDim2.new(0.5, -62, 0, 50)
FloatToggle.BackgroundColor3 = C.Sidebar
FloatToggle.ZIndex = 80
corner(FloatToggle, 16)
stroke(FloatToggle, C.Accent, 0.25, 1.2)

local pillAccent = Instance.new("Frame", FloatToggle)
pillAccent.Size = UDim2.fromOffset(6, 6)
pillAccent.Position = UDim2.fromOffset(10, 13)
pillAccent.BackgroundColor3 = C.Accent
corner(pillAccent, 99)

local pillTxt = text(FloatToggle, tr("PillText"), UDim2.new(1, -26, 1, 0), UDim2.fromOffset(24, 0), 9, C.White, 82)
pillTxt.Font = Enum.Font.GothamBlack
local pillBtn = button(FloatToggle, UDim2.fromScale(1, 1), UDim2.fromScale(0, 0), 85)

table.insert(LangUpdaters, function() pillTxt.Text = tr("PillText") end)

local isPillDrag, pStart, touchStart
pillBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isPillDrag = true pStart = FloatToggle.Position touchStart = input.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if isPillDrag and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - touchStart
        FloatToggle.Position = UDim2.new(pStart.X.Scale, pStart.X.Offset + delta.X, pStart.Y.Scale, pStart.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then isPillDrag = false end
end)

--// MENU VISIBILITY
local MenuVisible = true
local function setMenuVisible(visible)
    MenuVisible = visible
    playSound(SoundClick)
    if visible then
        Main.Visible = true Shadow.Visible = true
        tw(MainScale, 0.25, {Scale = 1}, Enum.EasingStyle.Back)
        tw(Shadow, 0.25, {BackgroundTransparency = (Config.UI.Style == "Ghost" and 1) or (Config.UI.Style == "Glass" and 0.7) or 0.35})
        FloatToggle.Visible = false
    else
        tw(MainScale, 0.18, {Scale = 0.85})
        tw(Shadow, 0.18, {BackgroundTransparency = 1})
        task.delay(0.18, function()
            if not MenuVisible then
                Main.Visible = false Shadow.Visible = false FloatToggle.Visible = true
            end
        end)
    end
end

pillBtn.Activated:Connect(function() setMenuVisible(true) end)
CloseBtn.Activated:Connect(function() setMenuVisible(false) end)

table.insert(Cleanups, UIS.InputBegan:Connect(function(input, processed)
    if not processed and (input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.M) then setMenuVisible(not MenuVisible) end
end))

local isDragging, dragStart, panelStart
Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true dragStart = input.Position panelStart = Main.Position
    end
end)
UIS.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(panelStart.X.Scale, panelStart.X.Offset + delta.X, panelStart.Y.Scale, panelStart.Y.Offset + delta.Y)
        Shadow.Position = UDim2.new(panelStart.X.Scale, panelStart.X.Offset + delta.X + 6, panelStart.Y.Scale, panelStart.Y.Offset + delta.Y + 8)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = false end
end)

--// ESP REGISTRY
local ESPCache = {}
local function purgeESP(p)
    if ESPCache[p] then
        for _, obj in pairs(ESPCache[p]) do
            if typeof(obj) == "table" then
                for _, line in pairs(obj) do if typeof(line) == "Instance" then line:Destroy() end end
            elseif typeof(obj) == "Instance" then
                obj:Destroy()
            end
        end
        ESPCache[p] = nil
    end
end

local function setupESP(p)
    if p == LocalPlayer then return end
    purgeESP(p)

    local box = Instance.new("Frame", OverlayGui)
    box.BackgroundTransparency = 1 box.Visible = false box.ZIndex = 50
    local bStroke = stroke(box, C.Accent, 0, 1.2)

    local hpBarBg = Instance.new("Frame", box)
    hpBarBg.Size = UDim2.new(0, 2, 1, 0)
    hpBarBg.Position = UDim2.new(0, -5, 0, 0)
    hpBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    hpBarBg.BorderSizePixel = 0 hpBarBg.ZIndex = 51

    local hpBarFill = Instance.new("Frame", hpBarBg)
    hpBarFill.Size = UDim2.new(1, 0, 1, 0)
    hpBarFill.Position = UDim2.new(0, 0, 1, 0)
    hpBarFill.AnchorPoint = Vector2.new(0, 1)
    hpBarFill.BackgroundColor3 = C.Green
    hpBarFill.BorderSizePixel = 0 hpBarFill.ZIndex = 52

    local tag = text(OverlayGui, "", UDim2.fromOffset(200, 14), UDim2.fromScale(0, 0), 9, C.White, 55)
    tag.TextXAlignment = Enum.TextXAlignment.Center
    stroke(tag, Color3.new(0, 0, 0), 0.2, 1)

    local info = text(OverlayGui, "", UDim2.fromOffset(200, 14), UDim2.fromScale(0, 0), 8, C.Sub, 55)
    info.TextXAlignment = Enum.TextXAlignment.Center

    local tracer = Instance.new("Frame", OverlayGui)
    tracer.AnchorPoint = Vector2.new(0.5, 0.5)
    tracer.BackgroundColor3 = C.Accent
    tracer.BorderSizePixel = 0 tracer.Visible = false tracer.ZIndex = 49

    local skeletonLines = {}
    for i = 1, 5 do
        local line = Instance.new("Frame", OverlayGui)
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.BackgroundColor3 = C.Accent
        line.BorderSizePixel = 0
        line.Visible = false
        line.ZIndex = 48
        table.insert(skeletonLines, line)
    end

    table.insert(DynamicUpdaters, function()
        bStroke.Color = C.Accent
        tracer.BackgroundColor3 = C.Accent
        for _, l in ipairs(skeletonLines) do l.BackgroundColor3 = C.Accent end
    end)

    ESPCache[p] = { Box = box, HpFill = hpBarFill, Tag = tag, Info = info, Tracer = tracer, SkeletonLines = skeletonLines }
end

for _, p in ipairs(Players:GetPlayers()) do setupESP(p) end
table.insert(Cleanups, Players.PlayerAdded:Connect(setupESP))
table.insert(Cleanups, Players.PlayerRemoving:Connect(purgeESP))

local function updateSkeletonLine(frame, p1, p2)
    if not p1 or not p2 then frame.Visible = false return end
    local pos1, on1 = Camera:WorldToViewportPoint(p1)
    local pos2, on2 = Camera:WorldToViewportPoint(p2)
    if pos1.Z > 0 and pos2.Z > 0 then
        local v1 = Vector2.new(pos1.X, pos1.Y)
        local v2 = Vector2.new(pos2.X, pos2.Y)
        local delta = v2 - v1
        frame.Position = UDim2.fromOffset(v1.X + delta.X * 0.5, v1.Y + delta.Y * 0.5)
        frame.Size = UDim2.fromOffset(delta.Magnitude, 1.2)
        frame.Rotation = math.deg(math.atan2(delta.Y, delta.X))
        frame.Visible = true
    else
        frame.Visible = false
    end
end

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

--// ESP RENDER STEP
table.insert(Cleanups, RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera or Camera
    if not Camera then return end
    local vp = Camera.ViewportSize
    local tracerOrigin = Vector2.new(vp.X * 0.5, vp.Y - 10)
    local camPos = Camera.CFrame.Position

    if FOVCircle then
        FOVCircle.Visible = Config.Visuals.FOVCircle and Config.Aim.Enabled
        local fovSize = Config.Aim.FOV * 2
        FOVCircle.Size = UDim2.fromOffset(fovSize, fovSize)
    end
    if Crosshair then Crosshair.Visible = Config.Visuals.Crosshair end

    for p, esp in pairs(ESPCache) do
        local alive = isAlivePlayer(p)
        local sameTeam = isTeammate(p)
        local char = p.Character
        if Config.ESP.Enabled and alive and (not Config.ESP.TeamCheck or not sameTeam) and char then
            local hum, root, head = getCharParts(char)
            if root and head then
                local dist = (camPos - root.Position).Magnitude
                if dist <= Config.ESP.MaxDistance then
                    local top, on1 = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1.2, 0))
                    local btm, on2 = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.6, 0))

                    if top.Z > 0 and btm.Z > 0 then
                        local h = math.max(math.abs(top.Y - btm.Y), 14)
                        local w = math.max(h * 0.55, 10)
                        local minY = math.min(top.Y, btm.Y)

                        esp.Box.Size = UDim2.fromOffset(w, h)
                        esp.Box.Position = UDim2.fromOffset(top.X - w * 0.5, minY)
                        esp.Box.Visible = Config.ESP.Box

                        local curHp = hum and math.clamp(hum.Health, 0, hum.MaxHealth) or 100
                        local maxHp = hum and math.max(hum.MaxHealth, 1) or 100
                        local hpRatio = math.clamp(curHp / maxHp, 0, 1)
                        esp.HpFill.Size = UDim2.new(1, 0, hpRatio, 0)
                        esp.HpFill.BackgroundColor3 = C.Red:Lerp(C.Green, hpRatio)
                        esp.HpFill.Parent.Visible = Config.ESP.Health

                        esp.Tag.Position = UDim2.fromOffset(top.X - 100, minY - 15)
                        esp.Tag.Text = p.DisplayName
                        esp.Tag.Visible = Config.ESP.Name

                        esp.Info.Position = UDim2.fromOffset(top.X - 100, minY + h + 2)
                        esp.Info.Text = string.format("%dm • %dHP", math.floor(dist), math.floor(curHp))
                        esp.Info.Visible = Config.ESP.Distance

                        if Config.ESP.Tracer then
                            local delta = Vector2.new(btm.X, btm.Y) - tracerOrigin
                            esp.Tracer.Position = UDim2.fromOffset(tracerOrigin.X + delta.X * 0.5, tracerOrigin.Y + delta.Y * 0.5)
                            esp.Tracer.Size = UDim2.fromOffset(delta.Magnitude, 1.5)
                            esp.Tracer.Rotation = math.deg(math.atan2(delta.Y, delta.X))
                            esp.Tracer.Visible = true
                        else
                            esp.Tracer.Visible = false
                        end

                        if Config.ESP.Skeleton and esp.SkeletonLines then
                            local leftHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
                            local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
                            local leftFoot = char:FindFirstChild("LeftFoot") or char:FindFirstChild("Left Leg")
                            local rightFoot = char:FindFirstChild("RightFoot") or char:FindFirstChild("Right Leg")

                            updateSkeletonLine(esp.SkeletonLines[1], head.Position, root.Position)
                            updateSkeletonLine(esp.SkeletonLines[2], root.Position, leftHand and leftHand.Position)
                            updateSkeletonLine(esp.SkeletonLines[3], root.Position, rightHand and rightHand.Position)
                            updateSkeletonLine(esp.SkeletonLines[4], root.Position, leftFoot and leftFoot.Position)
                            updateSkeletonLine(esp.SkeletonLines[5], root.Position, rightFoot and rightFoot.Position)
                        else
                            for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
                        end
                    else
                        esp.Box.Visible, esp.Tag.Visible, esp.Info.Visible, esp.Tracer.Visible = false, false, false, false
                        for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
                    end
                else
                    esp.Box.Visible, esp.Tag.Visible, esp.Info.Visible, esp.Tracer.Visible = false, false, false, false
                    for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
                end
            else
                esp.Box.Visible, esp.Tag.Visible, esp.Info.Visible, esp.Tracer.Visible = false, false, false, false
                for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
            end
        else
            esp.Box.Visible, esp.Tag.Visible, esp.Info.Visible, esp.Tracer.Visible = false, false, false, false
            for _, l in ipairs(esp.SkeletonLines) do l.Visible = false end
        end
    end
end))

--// STICKY TARGET LOCK WITH SHAKE ELIMINATOR
local LockedPlayer = nil

local function getHitscanHeadTarget()
    if not Config.Aim.Enabled then 
        LockedPlayer = nil
        return nil 
    end
    Camera = workspace.CurrentCamera or Camera
    if not Camera then 
        LockedPlayer = nil
        return nil 
    end

    local center = Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5)
    local camPos = Camera.CFrame.Position

    if LockedPlayer and isAlivePlayer(LockedPlayer) then
        local sameTeam = isTeammate(LockedPlayer)
        if not Config.Aim.TeamCheck or not sameTeam then
            local char = LockedPlayer.Character
            local _, root, head = getCharParts(char)
            if root and head then
                local aimPos = root.Position + Vector3.new(0, 1.45, 0) -- Целимся в шею/голову от Рута, чтобы избежать тряски анимаций
                local pos, _ = Camera:WorldToViewportPoint(aimPos)
                if pos.Z > 0 then
                    local sDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    local wDist = (camPos - aimPos).Magnitude
                    if sDist <= (Config.Aim.FOV * 1.5) and wDist <= Config.Aim.MaxDistance then
                        local isVis = not Config.Aim.VisibleCheck or isPartVisible(head, char)
                        if isVis then
                            return aimPos
                        end
                    end
                end
            end
        end
    end

    LockedPlayer = nil
    local bestAimPos = nil
    local bestMetric = math.huge

    for _, p in ipairs(Players:GetPlayers()) do
        if isAlivePlayer(p) then
            local sameTeam = isTeammate(p)
            if not Config.Aim.TeamCheck or not sameTeam then
                local char = p.Character
                local _, root, head = getCharParts(char)

                if root and head then
                    local aimPos = root.Position + Vector3.new(0, 1.45, 0) -- Фикс тряски
                    local pos, _ = Camera:WorldToViewportPoint(aimPos)
                    if pos.Z > 0 then
                        local sDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        local wDist = (camPos - aimPos).Magnitude

                        if sDist <= Config.Aim.FOV and wDist <= Config.Aim.MaxDistance then
                            local isVis = not Config.Aim.VisibleCheck or isPartVisible(head, char)
                            if isVis and sDist < bestMetric then
                                bestMetric = sDist
                                bestAimPos = aimPos
                                LockedPlayer = p
                            end
                        end
                    end
                end
            end
        end
    end

    return bestAimPos
end

--// AIM ENGINE
table.insert(Cleanups, RunService.RenderStepped:Connect(function(dt)
    if not Config.Aim.Enabled then return end
    Camera = workspace.CurrentCamera or Camera
    if not Camera then return end

    local mouseDelta = UIS:GetMouseDelta()
    if mouseDelta.Magnitude > 2 then
        return 
    end

    local targetPos = getHitscanHeadTarget()
    if targetPos then
        local camCF = Camera.CFrame
        local targetCF = CFrame.lookAt(camCF.Position, targetPos)

        local s = math.clamp(Config.Aim.Smoothness, 0.0, 0.85)
        if s <= 0.02 then
            Camera.CFrame = targetCF
        else
            local speed = (1.0 - s) * 75 + 20
            local alpha = math.clamp(1 - math.exp(-speed * dt), 0.25, 1.0)
            Camera.CFrame = camCF:Lerp(targetCF, alpha)
        end
    else
        LockedPlayer = nil
    end
end))

--// RUNTIME DISPATCHER
local frames, elapsed = 0, 0
table.insert(Cleanups, RunService.RenderStepped:Connect(function(dt)
    frames = frames + 1
    elapsed = elapsed + dt
    if elapsed >= 0.5 then
        local curFps = math.floor((frames / elapsed) + 0.5)
        local vp = Camera and Camera.ViewportSize or Vector2.zero
        matchInfo.Text = string.format(
            "Engine: %s %s\nPlayers: %d | FPS: %d\nLock: %s | Range: INFINITE",
            SCRIPT_TITLE, SCRIPT_VER, #Players:GetPlayers(), curFps,
            LockedPlayer and LockedPlayer.Name or "NONE"
        )
        frames, elapsed = 0, 0
    end
end))

setMenuVisible(true)
```eof
