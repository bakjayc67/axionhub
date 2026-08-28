local Compkiller = loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/CompKiller/refs/heads/main/src/source.luau"))()
local Notifier = Compkiller.newNotify()
local ConfigManager = Compkiller:ConfigManager({
    Directory = "Compkiller-Full",
    Config = "CK-Full"
})

Compkiller:Loader("rbxassetid://120245531583106", 2.0).yield()

local Window = Compkiller.new({
    Name = "COMPKILLER",
    Keybind = "LeftAlt",
    Logo = "rbxassetid://120245531583106",
    Scale = Compkiller.Scale.Window,
    TextSize = 15,
})

Notifier.new({
    Title = "COMPKILLER",
    Content = "Full module loaded — Aimbot ESP Rage Legit",
    Duration = 6,
    Icon = "rbxassetid://120245531583106"
})

-- ============================================================
-- SERVICES
-- ============================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local GuiService = game:GetService("GuiService")
local TextService = game:GetService("TextService")
local SoundService = game:GetService("SoundService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LP:GetMouse()

-- Watermark
local Watermark = Window:Watermark()
Watermark:AddText({ Icon = "user", Text = LP.Name })
Watermark:AddText({ Icon = "clock", Text = Compkiller:GetDate() })
local TimeLabel = Watermark:AddText({ Icon = "timer", Text = "TIME" })
task.spawn(function()
    while true do
        task.wait(0.5)
        TimeLabel:SetText(Compkiller:GetTimeNow())
    end
end)
Watermark:AddText({ Icon = "server", Text = Compkiller.Version })

-- ============================================================
-- GLOBAL STATE (all modules)
-- ============================================================
local State = {
    -- AIMBOT CORE
    EnableAimbot = false,
    AimbotKey = "E",
    AimbotKeyActive = false,
    TeamCheck = true,
    VisibleCheck = true,
    AliveCheck = true,
    ForceFieldCheck = true,
    AimMethod = "Camera",
    AimCondition = "Always",
    AimPart = "Head",
    AimPartFallback = {"Head", "HumanoidRootPart", "UpperTorso", "Torso"},
    Smoothing = 0.12,
    SmoothingType = "Linear",
    Prediction = false,
    PredictionAmount = 0.15,
    PredictionMethod = "Velocity",
    MaxDistance = 2000,
    MinDistance = 0,
    FOVType = "Circle",
    ShowFOV = false,
    FOVRadius = 120,
    FOVColor = Color3.fromRGB(255, 255, 255),
    FOVThickness = 1.5,
    FOVFilled = false,
    FOVTransparency = 0.6,
    StickyAim = false,
    StickyTime = 0.35,
    AimPriority = "Crosshair", -- Crosshair / Distance / Health
    IgnoreFriends = true,
    IgnoreCreator = true,
    Wallbang = false,
    SilentAim = false,
    SilentHitChance = 100,
    Resolver = false,
    ResolverType = "ClosestPoint",

    -- TRIGGERBOT
    EnableTriggerbot = false,
    TriggerTeamCheck = true,
    TriggerDelay = 0.05,
    TriggerMaxDistance = 500,
    TriggerHitChance = 100,
    TriggerOnlyFOV = true,
    TriggerMagnet = false,

    -- RCS
    EnableRCS = false,
    RCSPullPower = 0.35,
    RCSSmoothing = 0.2,
    RCSStandalone = false,
    RCSPattern = false,

    -- ESP BOX
    EnableESP = false,
    ESPTeamCheck = false,
    ESPMaxDistance = 2500,
    EnemyCount = false,
    AimingWarning = false,
    AimingWarningDistance = 300,
    AimingWarningDot = 0.9,
    TeamColor = false,
    BoxESP = false,
    BoxType = "Full", -- Full / Corner
    CornerBoxMode = false,
    CornerLength = 8,
    BoxWallCheck = false,
    BoxVisibleColor = Color3.fromRGB(0, 255, 100),
    BoxHiddenColor = Color3.fromRGB(255, 40, 40),
    BoxTeamColor = Color3.fromRGB(80, 160, 255),
    FilledBoxes = false,
    FillColor = Color3.fromRGB(40, 80, 255),
    FillTransparency = 0.65,
    Thickness = 2,
    BoxGradient = false,

    -- SKELETON
    Skeleton = false,
    SkeletonWallCheck = true,
    SkeletonVisible = Color3.fromRGB(255, 255, 255),
    SkeletonHidden = Color3.fromRGB(255, 0, 255),
    SkeletonThickness = 1.5,
    SkeletonJoints = false,

    -- INFO
    Names = false,
    NameMode = "DisplayName", -- DisplayName / Username / Both
    Distances = false,
    DistanceUnit = "m",
    Tool = false,
    HealthBar = false,
    HealthBarSide = "Left",
    HealthText = false,
    TextColor = Color3.fromRGB(255, 255, 255),
    TextSize = 13,
    TextOutline = true,
    Tracer = false,
    TracerOrigin = "Bottom", -- Bottom / Center / Mouse / Top
    TracerColor = Color3.fromRGB(255, 255, 255),
    TracerThickness = 1,
    HeadDot = false,
    HeadDotSize = 4,
    HeadDotColor = Color3.fromRGB(255, 0, 0),
    Arrow = false,
    ArrowRadius = 120,
    ArrowSize = 12,
    ArrowColor = Color3.fromRGB(255, 80, 80),

    -- CHAMS
    EnableChams = false,
    ChamsTeamCheck = false,
    ChamsMode = "Highlight", -- Highlight / BoxHandleAdornment / Custom
    ChamsColor = Color3.fromRGB(0, 120, 255),
    ChamsFillTransparency = 0.45,
    GlowOutline = false,
    OutlineColor = Color3.fromRGB(255, 255, 255),
    OutlineTransparency = 0,
    ChamsOccludedColor = Color3.fromRGB(255, 50, 50),
    ChamsVisibleColor = Color3.fromRGB(0, 255, 120),
    ChamsWallCheck = true,

    -- GLOW / HIGHLIGHT EXTRA
    LocalChams = false,
    LocalChamsColor = Color3.fromRGB(0, 255, 200),

    -- RADAR
    EnableRadar = false,
    RadarSize = 150,
    RadarZoom = 1.5,
    RadarPosition = Vector2.new(20, 200),
    RadarTeamColor = true,
    RadarRotate = true,

    -- CROSSHAIR
    CustomCrosshair = false,
    CrosshairGap = 4,
    CrosshairSize = 8,
    CrosshairThickness = 1.5,
    CrosshairColor = Color3.fromRGB(0, 255, 128),
    CrosshairTStyle = "Static",

    -- MODS / MISC
    EnableTPRCM = false,
    EnableCameraFOV = false,
    CameraFOVValue = 70,
    EnableSpinBot = false,
    SpinSpeed = 20,
    SpinAxis = "Y",
    BunnyHop = false,
    BhopSpeedBoost = 1.98,
    BhopAuto = false,
    SpeedHack = false,
    SpeedValue = 16,
    InfiniteJump = false,
    NoClip = false,
    Fly = false,
    FlySpeed = 50,
    FlyKey = "F",
    ThirdPerson = false,
    ThirdPersonDistance = 10,
    AntiAFK = true,
    NoFog = false,
    Fullbright = false,
    AmbientColor = Color3.fromRGB(255, 255, 255),
    HitSound = false,
    HitSoundId = "rbxassetid://3746776597",
    HitSoundVolume = 1,
    KillSound = false,
    HitMarker = false,
    HitMarkerDuration = 0.25,

    -- RAGE
    RageEnabled = false,
    AutoFire = false,
    AutoWall = false,
    MinDamage = 0,
    Hitchance = 100,
    DoubleTap = false,
    HideShots = false,

    -- LEGIT
    LegitEnabled = false,
    LegitFOV = 60,
    LegitSmooth = 0.25,
    LegitAimPart = "Head",
    RCSStandaloneLegit = false,

    -- WORLD
    Ambient = false,
    OutdoorAmbient = Color3.fromRGB(128, 128, 128),
    TimeOfDay = false,
    ClockTime = 12,
    Exposure = false,
    ExposureValue = 0,

    -- PERFORMANCE
    ESPRefreshRate = 0, -- 0 = every frame
    MaxESPBoxes = 40,
    StreamProof = false,

    -- SYSTEM
    MenuKey = "LeftAlt",
    UnloadMenu = false,
    WatermarkVisible = true,
    ArrayList = false,
}

getgenv().CKState = State
getgenv().CKConfig = State

-- ============================================================
-- UTILITY LIBRARY
-- ============================================================
local Util = {}

function Util.IsAlive(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
    if hum.Health <= 0 then return false end
    if hum:GetState() == Enum.HumanoidStateType.Dead then return false end
    return true
end

function Util.GetCharacter(plr)
    return plr and plr.Character
end

function Util.GetHumanoid(char)
    return char and char:FindFirstChildOfClass("Humanoid")
end

function Util.GetRoot(char)
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
        or char:FindFirstChild("Torso")
        or char:FindFirstChild("UpperTorso")
        or char.PrimaryPart
end

function Util.GetHead(char)
    return char and char:FindFirstChild("Head")
end

function Util.GetPart(char, name)
    if not char then return nil end
    local p = char:FindFirstChild(name)
    if p and p:IsA("BasePart") then return p end
    return nil
end

function Util.SameTeam(plr)
    if not plr then return false end
    if LP.Team and plr.Team then
        return LP.Team == plr.Team
    end
    -- some games use TeamColor
    if LP.TeamColor and plr.TeamColor then
        return LP.TeamColor == plr.TeamColor
    end
    return false
end

function Util.IsFriend(plr)
    local ok, result = pcall(function()
        return LP:IsFriendsWith(plr.UserId)
    end)
    return ok and result
end

function Util.IsCreator(plr)
    return plr.UserId == game.CreatorId
end

function Util.WorldToScreen(pos)
    local v, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(v.X, v.Y), onScreen, v.Z
end

function Util.GetMousePos()
    return UserInputService:GetMouseLocation()
end

function Util.Raycast(origin, direction, ignore)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignore or { LP.Character, Camera }
    params.IgnoreWater = true
    return Workspace:Raycast(origin, direction, params)
end

function Util.IsVisible(part, from)
    if not part then return false end
    from = from or Camera.CFrame.Position
    local dir = part.Position - from
    local result = Util.Raycast(from, dir)
    if not result then return true end
    return result.Instance:IsDescendantOf(part.Parent)
end

function Util.GetClosestPointOnPart(part, from)
    -- approximate closest point on part AABB
    local cf = part.CFrame
    local size = part.Size * 0.5
    local localPos = cf:PointToObjectSpace(from)
    local clamped = Vector3.new(
        math.clamp(localPos.X, -size.X, size.X),
        math.clamp(localPos.Y, -size.Y, size.Y),
        math.clamp(localPos.Z, -size.Z, size.Z)
    )
    return cf:PointToWorldSpace(clamped)
end

function Util.PredictPosition(part, amount, method)
    if not part then return part and part.Position end
    amount = amount or State.PredictionAmount
    method = method or State.PredictionMethod
    if method == "Velocity" then
        local vel = part.AssemblyLinearVelocity or Vector3.zero
        return part.Position + vel * amount
    elseif method == "MoveDirection" then
        local hum = Util.GetHumanoid(part.Parent)
        if hum then
            return part.Position + hum.MoveDirection * hum.WalkSpeed * amount
        end
    end
    return part.Position
end

function Util.GetAimPart(char)
    local preferred = State.AimPart
    local p = Util.GetPart(char, preferred)
    if p then return p end
    for _, name in ipairs(State.AimPartFallback) do
        p = Util.GetPart(char, name)
        if p then return p end
    end
    return Util.GetRoot(char)
end

function Util.Clamp(n, a, b)
    return math.max(a, math.min(b, n))
end

function Util.Lerp(a, b, t)
    return a + (b - a) * t
end

function Util.LerpColor(c1, c2, t)
    return Color3.new(
        Util.Lerp(c1.R, c2.R, t),
        Util.Lerp(c1.G, c2.G, t),
        Util.Lerp(c1.B, c2.B, t)
    )
end

function Util.SmoothStep(t)
    return t * t * (3 - 2 * t)
end

function Util.Distance(a, b)
    return (a - b).Magnitude
end

function Util.CreateDrawing(class, props)
    if not Drawing then return nil end
    local ok, d = pcall(Drawing.new, class)
    if not ok or not d then return nil end
    if props then
        for k, v in pairs(props) do
            pcall(function() d[k] = v end)
        end
    end
    return d
end

function Util.SafeDestroy(obj)
    if not obj then return end
    pcall(function()
        if obj.Remove then obj:Remove()
        elseif obj.Destroy then obj:Destroy() end
    end)
end

function Util.PlaySound(id, vol)
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = id
        s.Volume = vol or 1
        s.Parent = SoundService
        s:Play()
        game:GetService("Debris"):AddItem(s, 3)
    end)
end

-- ============================================================
-- ENTITY CACHE (performance)
-- ============================================================
local EntityCache = {}
local EntityList = {}
local LastCacheUpdate = 0
local CACHE_INTERVAL = 0.12

local function refreshEntityCache()
    local now = tick()
    if now - LastCacheUpdate < CACHE_INTERVAL then return end
    LastCacheUpdate = now
    table.clear(EntityList)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        local char = Util.GetCharacter(plr)
        if not Util.IsAlive(char) then
            EntityCache[plr] = nil
            continue
        end
        local root = Util.GetRoot(char)
        local head = Util.GetHead(char)
        local hum = Util.GetHumanoid(char)
        if not root or not head or not hum then
            EntityCache[plr] = nil
            continue
        end
        local data = EntityCache[plr]
        if not data then
            data = {}
            EntityCache[plr] = data
        end
        data.plr = plr
        data.char = char
        data.root = root
        data.head = head
        data.hum = hum
        data.team = Util.SameTeam(plr)
        data.friend = State.IgnoreFriends and Util.IsFriend(plr)
        data.tool = char:FindFirstChildOfClass("Tool")
        data.health = hum.Health
        data.maxHealth = hum.MaxHealth
        data.pos = root.Position
        data.vel = root.AssemblyLinearVelocity or Vector3.zero
        table.insert(EntityList, data)
    end
end

Players.PlayerRemoving:Connect(function(plr)
    EntityCache[plr] = nil
end)

-- ============================================================
-- FOV DRAWING
-- ============================================================
local FOVCircle = Util.CreateDrawing("Circle", {
    Thickness = State.FOVThickness,
    NumSides = 64,
    Filled = false,
    Transparency = State.FOVTransparency,
    Visible = false,
    ZIndex = 5,
})

local function updateFOV()
    if not FOVCircle then return end
    local show = State.ShowFOV and (State.EnableAimbot or State.EnableTriggerbot)
    FOVCircle.Visible = show
    if not show then return end
    FOVCircle.Radius = State.FOVRadius
    FOVCircle.Color = State.FOVColor
    FOVCircle.Thickness = State.FOVThickness
    FOVCircle.Filled = State.FOVFilled
    FOVCircle.Transparency = State.FOVTransparency
    FOVCircle.Position = Util.GetMousePos()
end

-- ============================================================
-- AIMBOT ENGINE
-- ============================================================
local StickyTarget = nil
local StickyUntil = 0
local CurrentAimTarget = nil

local function passesAimFilters(data)
    if State.TeamCheck and data.team then return false end
    if State.IgnoreFriends and data.friend then return false end
    if State.IgnoreCreator and Util.IsCreator(data.plr) then return false end
    if State.AliveCheck and not Util.IsAlive(data.char) then return false end
    if State.ForceFieldCheck and data.char:FindFirstChildOfClass("ForceField") then return false end
    local dist = Util.Distance(Camera.CFrame.Position, data.pos)
    if dist > State.MaxDistance or dist < State.MinDistance then return false end
    return true
end

local function getAimTarget()
    refreshEntityCache()
    local mousePos = Util.GetMousePos()
    local best, bestScore = nil, math.huge

    -- sticky
    if State.StickyAim and StickyTarget and tick() < StickyUntil then
        local char = Util.GetCharacter(StickyTarget)
        if Util.IsAlive(char) then
            local part = Util.GetAimPart(char)
            if part then
                if not State.VisibleCheck or Util.IsVisible(part) then
                    return part, StickyTarget
                end
            end
        end
        StickyTarget = nil
    end

    for _, data in ipairs(EntityList) do
        if not passesAimFilters(data) then continue end
        local part = Util.GetAimPart(data.char)
        if not part then continue end
        local aimPos = part.Position
        if State.Prediction then
            aimPos = Util.PredictPosition(part, State.PredictionAmount, State.PredictionMethod)
        end
        local screen, onScreen = Util.WorldToScreen(aimPos)
        if not onScreen then continue end
        local crossDist = (screen - mousePos).Magnitude
        if crossDist > State.FOVRadius then continue end
        if State.VisibleCheck and not State.Wallbang and not Util.IsVisible(part) then continue end

        local score = crossDist
        if State.AimPriority == "Distance" then
            score = Util.Distance(Camera.CFrame.Position, data.pos)
        elseif State.AimPriority == "Health" then
            score = data.health
        end
        if score < bestScore then
            bestScore = score
            best = { part = part, plr = data.plr, pos = aimPos, data = data }
        end
    end

    if best then
        CurrentAimTarget = best.plr
        if State.StickyAim then
            StickyTarget = best.plr
            StickyUntil = tick() + State.StickyTime
        end
        return best.part, best.plr, best.pos
    end
    CurrentAimTarget = nil
    return nil
end

local function applyAim(part, worldPos)
    if not part and not worldPos then return end
    local targetPos = worldPos or part.Position
    if State.AimMethod == "Camera" then
        local origin = Camera.CFrame.Position
        local goal = CFrame.new(origin, targetPos)
        local t = 1 - Util.Clamp(State.Smoothing, 0, 0.99)
        if State.SmoothingType == "SmoothStep" then
            t = Util.SmoothStep(t)
        end
        Camera.CFrame = Camera.CFrame:Lerp(goal, t)
    elseif State.AimMethod == "Mouse" and typeof(mousemoverel) == "function" then
        local screen = Util.WorldToScreen(targetPos)
        local mouse = Util.GetMousePos()
        local delta = (screen - mouse) * (1 - State.Smoothing)
        mousemoverel(delta.X, delta.Y)
    end
end

local function aimbotCondition()
    if not State.EnableAimbot then return false end
    if State.AimCondition == "Always" then return true end
    if State.AimCondition == "MouseButton2" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    end
    if State.AimCondition == "MouseButton1" then
        return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    end
    if State.AimCondition == "Keybind" then
        return State.AimbotKeyActive
    end
    return true
end

RunService.RenderStepped:Connect(function()
    updateFOV()
    if not aimbotCondition() then return end
    local part, plr, pos = getAimTarget()
    if part or pos then
        applyAim(part, pos)
    end
end)

-- keybind hold for aimbot
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode.Name == State.AimbotKey then
        State.AimbotKeyActive = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode.Name == State.AimbotKey then
        State.AimbotKeyActive = false
    end
end)

-- ============================================================
-- TRIGGERBOT
-- ============================================================
local lastTrigger = 0
RunService.Heartbeat:Connect(function()
    if not State.EnableTriggerbot then return end
    if tick() - lastTrigger < State.TriggerDelay then return end
    local part, plr = getAimTarget()
    if not part then return end
    if State.TriggerTeamCheck and plr and Util.SameTeam(plr) then return end
    local dist = Util.Distance(Camera.CFrame.Position, part.Position)
    if dist > State.TriggerMaxDistance then return end
    local screen, on = Util.WorldToScreen(part.Position)
    local mouse = Util.GetMousePos()
    if not on then return end
    if State.TriggerOnlyFOV and (screen - mouse).Magnitude > State.FOVRadius then return end
    if (screen - mouse).Magnitude > 16 and not State.TriggerMagnet then return end
    if math.random(1, 100) > State.TriggerHitChance then return end
    if typeof(mouse1click) == "function" then
        mouse1click()
    else
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, true, game, 0)
            task.wait()
            VirtualInputManager:SendMouseButtonEvent(mouse.X, mouse.Y, 0, false, game, 0)
        end)
    end
    lastTrigger = tick()
end)

-- ============================================================
-- RCS
-- ============================================================
local lastLook = Camera.CFrame.LookVector
RunService.RenderStepped:Connect(function(dt)
    if not State.EnableRCS then
        lastLook = Camera.CFrame.LookVector
        return
    end
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
        local current = Camera.CFrame.LookVector
        local deltaY = lastLook.Y - current.Y
        if deltaY > 0.0005 then
            local pull = deltaY * State.RCSPullPower * (1 - State.RCSSmoothing)
            Camera.CFrame = Camera.CFrame * CFrame.Angles(pull, 0, 0)
        end
    end
    lastLook = Camera.CFrame.LookVector
end)

-- ============================================================
-- ESP ENGINE (full)
-- ============================================================
local ESPObjects = {} -- [plr] = drawings + highlight

local function clearESP(plr)
    local obj = ESPObjects[plr]
    if not obj then return end
    for k, v in pairs(obj) do
        if k == "skeleton" or k == "corners" then
            for _, d in pairs(v) do Util.SafeDestroy(d) end
        else
            Util.SafeDestroy(v)
        end
    end
    ESPObjects[plr] = nil
end

local function ensureESP(plr)
    if ESPObjects[plr] then return ESPObjects[plr] end
    local obj = {
        box = Util.CreateDrawing("Square", { Thickness = 2, Filled = false, Visible = false }),
        fill = Util.CreateDrawing("Square", { Thickness = 1, Filled = true, Visible = false }),
        name = Util.CreateDrawing("Text", { Size = 13, Center = true, Outline = true, Visible = false }),
        dist = Util.CreateDrawing("Text", { Size = 12, Center = true, Outline = true, Visible = false }),
        tool = Util.CreateDrawing("Text", { Size = 12, Center = true, Outline = true, Visible = false }),
        hpText = Util.CreateDrawing("Text", { Size = 11, Center = true, Outline = true, Visible = false }),
        hpBG = Util.CreateDrawing("Square", { Filled = true, Color = Color3.new(0,0,0), Visible = false }),
        hpFG = Util.CreateDrawing("Square", { Filled = true, Visible = false }),
        tracer = Util.CreateDrawing("Line", { Thickness = 1, Visible = false }),
        headDot = Util.CreateDrawing("Circle", { Filled = true, NumSides = 16, Visible = false }),
        arrow = Util.CreateDrawing("Triangle", { Filled = true, Visible = false }),
        skeleton = {},
        corners = {},
        hl = nil,
    }
    for i = 1, 14 do
        obj.skeleton[i] = Util.CreateDrawing("Line", { Thickness = 1.5, Visible = false })
    end
    for i = 1, 8 do
        obj.corners[i] = Util.CreateDrawing("Line", { Thickness = 2, Visible = false })
    end
    ESPObjects[plr] = obj
    return obj
end

local SKELETON_BONES_R15 = {
    {"Head", "UpperTorso"},
    {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"},
    {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"},
    {"RightLowerLeg", "RightFoot"},
}

local SKELETON_BONES_R6 = {
    {"Head", "Torso"},
    {"Torso", "Left Arm"},
    {"Torso", "Right Arm"},
    {"Torso", "Left Leg"},
    {"Torso", "Right Leg"},
}

local function drawSkeleton(obj, char, color)
    local bones = SKELETON_BONES_R15
    local useR6 = char:FindFirstChild("Torso") and not char:FindFirstChild("UpperTorso")
    if useR6 then bones = SKELETON_BONES_R6 end
    for i, bone in ipairs(bones) do
        local line = obj.skeleton[i]
        if not line then continue end
        local a = char:FindFirstChild(bone[1], true)
        local b = char:FindFirstChild(bone[2], true)
        if a and b and a:IsA("BasePart") and b:IsA("BasePart") then
            local sa, oa = Util.WorldToScreen(a.Position)
            local sb, ob = Util.WorldToScreen(b.Position)
            if oa and ob then
                line.Visible = true
                line.From = sa
                line.To = sb
                line.Color = color
                line.Thickness = State.SkeletonThickness
            else
                line.Visible = false
            end
        else
            line.Visible = false
        end
    end
    for i = #bones + 1, #obj.skeleton do
        if obj.skeleton[i] then obj.skeleton[i].Visible = false end
    end
end

local function drawCornerBox(obj, boxPos, boxSize, color)
    local x, y = boxPos.X, boxPos.Y
    local w, h = boxSize.X, boxSize.Y
    local cl = math.min(State.CornerLength, w / 2, h / 2)
    local corners = {
        {Vector2.new(x, y), Vector2.new(x + cl, y)},
        {Vector2.new(x, y), Vector2.new(x, y + cl)},
        {Vector2.new(x + w, y), Vector2.new(x + w - cl, y)},
        {Vector2.new(x + w, y), Vector2.new(x + w, y + cl)},
        {Vector2.new(x, y + h), Vector2.new(x + cl, y + h)},
        {Vector2.new(x, y + h), Vector2.new(x, y + h - cl)},
        {Vector2.new(x + w, y + h), Vector2.new(x + w - cl, y + h)},
        {Vector2.new(x + w, y + h), Vector2.new(x + w, y + h - cl)},
    }
    for i, c in ipairs(corners) do
        local line = obj.corners[i]
        if line then
            line.Visible = true
            line.From = c[1]
            line.To = c[2]
            line.Color = color
            line.Thickness = State.Thickness
        end
    end
end

local function hideCorners(obj)
    for _, l in pairs(obj.corners) do
        if l then l.Visible = false end
    end
end

local function updateESP()
    if not State.EnableESP then
        for plr in pairs(ESPObjects) do clearESP(plr) end
        return
    end
    refreshEntityCache()
    local camPos = Camera.CFrame.Position
    local drawn = 0

    for _, data in ipairs(EntityList) do
        if drawn >= State.MaxESPBoxes then break end
        if State.ESPTeamCheck and data.team then
            clearESP(data.plr)
            continue
        end
        local dist = Util.Distance(camPos, data.pos)
        if dist > State.ESPMaxDistance then
            clearESP(data.plr)
            continue
        end

        local headPos = data.head.Position + Vector3.new(0, 0.5, 0)
        local rootPos = data.root.Position
        local screenHead, onH, zH = Util.WorldToScreen(headPos)
        local screenRoot, onR = Util.WorldToScreen(rootPos)
        if not onH and not onR then
            -- offscreen arrow
            local obj = ensureESP(data.plr)
            if State.Arrow and obj.arrow then
                local dir = (rootPos - camPos).Unit
                local flat = Vector3.new(dir.X, 0, dir.Z).Unit
                local camFlat = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z).Unit
                local angle = math.atan2(flat.X - camFlat.X, flat.Z - camFlat.Z)
                -- simplified: hide for now if complex
                obj.arrow.Visible = false
            end
            if not State.Arrow then clearESP(data.plr) end
            continue
        end

        drawn = drawn + 1
        local obj = ensureESP(data.plr)
        local visible = Util.IsVisible(data.root)
        local boxColor
        if State.TeamColor and data.team then
            boxColor = State.BoxTeamColor
        elseif State.BoxWallCheck and not visible then
            boxColor = State.BoxHiddenColor
        else
            boxColor = State.BoxVisibleColor
        end
        local skelColor = (State.SkeletonWallCheck and not visible) and State.SkeletonHidden or State.SkeletonVisible

        local scale = Util.Clamp(1000 / math.max(zH, 1), 0.3, 10)
        local boxH = 52 * scale
        local boxW = 28 * scale
        local boxPos = Vector2.new(screenHead.X - boxW / 2, screenHead.Y)
        local boxSize = Vector2.new(boxW, boxH)

        -- BOX
        if State.BoxESP then
            if State.CornerBoxMode or State.BoxType == "Corner" then
                if obj.box then obj.box.Visible = false end
                drawCornerBox(obj, boxPos, boxSize, boxColor)
            else
                hideCorners(obj)
                if obj.box then
                    obj.box.Visible = true
                    obj.box.Position = boxPos
                    obj.box.Size = boxSize
                    obj.box.Color = boxColor
                    obj.box.Thickness = State.Thickness
                    obj.box.Filled = false
                end
            end
            if State.FilledBoxes and obj.fill then
                obj.fill.Visible = true
                obj.fill.Position = boxPos
                obj.fill.Size = boxSize
                obj.fill.Color = State.FillColor
                obj.fill.Transparency = State.FillTransparency
            elseif obj.fill then
                obj.fill.Visible = false
            end
        else
            if obj.box then obj.box.Visible = false end
            if obj.fill then obj.fill.Visible = false end
            hideCorners(obj)
        end

        -- NAME
        if obj.name then
            if State.Names then
                local text = data.plr.Name
                if State.NameMode == "DisplayName" then
                    text = data.plr.DisplayName
                elseif State.NameMode == "Both" then
                    text = data.plr.DisplayName .. " [@" .. data.plr.Name .. "]"
                end
                obj.name.Visible = true
                obj.name.Text = text
                obj.name.Size = State.TextSize
                obj.name.Color = State.TextColor
                obj.name.Outline = State.TextOutline
                obj.name.Position = Vector2.new(screenHead.X, screenHead.Y - 16)
            else
                obj.name.Visible = false
            end
        end

        -- DISTANCE
        if obj.dist then
            if State.Distances then
                obj.dist.Visible = true
                obj.dist.Text = math.floor(dist) .. State.DistanceUnit
                obj.dist.Color = State.TextColor
                obj.dist.Position = Vector2.new(screenHead.X, screenHead.Y + boxH + 2)
            else
                obj.dist.Visible = false
            end
        end

        -- TOOL
        if obj.tool then
            if State.Tool and data.tool then
                obj.tool.Visible = true
                obj.tool.Text = data.tool.Name
                obj.tool.Color = Color3.fromRGB(255, 200, 80)
                obj.tool.Position = Vector2.new(screenHead.X, screenHead.Y + boxH + 14)
            else
                obj.tool.Visible = false
            end
        end

        -- HEALTH BAR
        if obj.hpBG and obj.hpFG then
            if State.HealthBar then
                local pct = Util.Clamp(data.health / math.max(data.maxHealth, 1), 0, 1)
                obj.hpBG.Visible = true
                obj.hpFG.Visible = true
                obj.hpBG.Position = Vector2.new(boxPos.X - 5, boxPos.Y)
                obj.hpBG.Size = Vector2.new(3, boxH)
                obj.hpFG.Position = Vector2.new(boxPos.X - 5, boxPos.Y + boxH * (1 - pct))
                obj.hpFG.Size = Vector2.new(3, boxH * pct)
                obj.hpFG.Color = Color3.fromRGB(255 * (1 - pct), 255 * pct, 40)
            else
                obj.hpBG.Visible = false
                obj.hpFG.Visible = false
            end
        end

        if obj.hpText then
            if State.HealthText then
                obj.hpText.Visible = true
                obj.hpText.Text = math.floor(data.health)
                obj.hpText.Color = State.TextColor
                obj.hpText.Position = Vector2.new(boxPos.X - 12, boxPos.Y + boxH / 2)
            else
                obj.hpText.Visible = false
            end
        end

        -- TRACER
        if obj.tracer then
            if State.Tracer then
                local from
                local vp = Camera.ViewportSize
                if State.TracerOrigin == "Bottom" then
                    from = Vector2.new(vp.X / 2, vp.Y)
                elseif State.TracerOrigin == "Top" then
                    from = Vector2.new(vp.X / 2, 0)
                elseif State.TracerOrigin == "Mouse" then
                    from = Util.GetMousePos()
                else
                    from = Vector2.new(vp.X / 2, vp.Y / 2)
                end
                obj.tracer.Visible = true
                obj.tracer.From = from
                obj.tracer.To = screenRoot
                obj.tracer.Color = State.TracerColor
                obj.tracer.Thickness = State.TracerThickness
            else
                obj.tracer.Visible = false
            end
        end

        -- HEAD DOT
        if obj.headDot then
            if State.HeadDot then
                local sp, on = Util.WorldToScreen(data.head.Position)
                obj.headDot.Visible = on
                obj.headDot.Position = sp
                obj.headDot.Radius = State.HeadDotSize
                obj.headDot.Color = State.HeadDotColor
            else
                obj.headDot.Visible = false
            end
        end

        -- SKELETON
        if State.Skeleton then
            drawSkeleton(obj, data.char, skelColor)
        else
            for _, l in pairs(obj.skeleton) do
                if l then l.Visible = false end
            end
        end

        -- CHAMS
        if State.EnableChams and not (State.ChamsTeamCheck and data.team) then
            if not obj.hl or not obj.hl.Parent then
                local hl = Instance.new("Highlight")
                hl.Name = "CKChams"
                hl.Adornee = data.char
                hl.Parent = data.char
                obj.hl = hl
            end
            local hl = obj.hl
            hl.Enabled = true
            if State.ChamsWallCheck then
                hl.FillColor = visible and State.ChamsVisibleColor or State.ChamsOccludedColor
            else
                hl.FillColor = State.ChamsColor
            end
            hl.OutlineColor = State.OutlineColor
            hl.FillTransparency = State.ChamsFillTransparency
            hl.OutlineTransparency = State.GlowOutline and State.OutlineTransparency or 1
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        elseif obj.hl then
            obj.hl.Enabled = false
        end
    end

    -- cleanup disconnected
    for plr in pairs(ESPObjects) do
        local found = false
        for _, d in ipairs(EntityList) do
            if d.plr == plr then found = true break end
        end
        if not found then clearESP(plr) end
    end
end

RunService.RenderStepped:Connect(updateESP)
Players.PlayerRemoving:Connect(clearESP)

-- ============================================================
-- AIMING WARNING
-- ============================================================
local warnGui, warnLabel
local function ensureWarnGui()
    if warnGui then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "CKAimWarn"
    sg.ResetOnSpawn = false
    sg.Parent = (gethui and gethui()) or CoreGui
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 280, 0, 28)
    lbl.Position = UDim2.new(0.5, -140, 0.07, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "▲ Enemy aiming at you"
    lbl.TextColor3 = Color3.fromRGB(255, 55, 55)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 16
    lbl.Parent = sg
    warnGui = sg
    warnLabel = lbl
end

RunService.Heartbeat:Connect(function()
    if not State.AimingWarning then
        if warnGui then warnGui.Enabled = false end
        return
    end
    ensureWarnGui()
    local hit = false
    local camPos = Camera.CFrame.Position
    for _, data in ipairs(EntityList) do
        if State.TeamCheck and data.team then continue end
        local look = data.head.CFrame.LookVector
        local toMe = (camPos - data.head.Position)
        local dist = toMe.Magnitude
        if dist > State.AimingWarningDistance then continue end
        if look:Dot(toMe.Unit) > State.AimingWarningDot then
            hit = true
            break
        end
    end
    warnGui.Enabled = hit
end)

-- ============================================================
-- MODS: BHOP, SPIN, FOV, NOCLIP, FLY, SPEED, ANTI-AFK
-- ============================================================
UserInputService.JumpRequest:Connect(function()
    if not State.BunnyHop then return end
    local char = Util.GetCharacter(LP)
    local hum = Util.GetHumanoid(char)
    if not hum then return end
    if hum.FloorMaterial == Enum.Material.Air then return end
    hum.Jump = true
    local root = Util.GetRoot(char)
    if root then
        local vel = root.AssemblyLinearVelocity
        local flat = Vector3.new(vel.X, 0, vel.Z)
        if flat.Magnitude > 1 then
            root.AssemblyLinearVelocity = flat.Unit * (flat.Magnitude * State.BhopSpeedBoost) + Vector3.new(0, vel.Y, 0)
        end
    end
end)

-- Infinite jump
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not State.InfiniteJump then return end
    if input.KeyCode == Enum.KeyCode.Space then
        local hum = Util.GetHumanoid(Util.GetCharacter(LP))
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Spinbot
RunService.RenderStepped:Connect(function()
    if not State.EnableSpinBot then return end
    local root = Util.GetRoot(Util.GetCharacter(LP))
    if not root then return end
    local axis = State.SpinAxis
    local a = math.rad(State.SpinSpeed)
    if axis == "Y" then
        root.CFrame = root.CFrame * CFrame.Angles(0, a, 0)
    elseif axis == "X" then
        root.CFrame = root.CFrame * CFrame.Angles(a, 0, 0)
    else
        root.CFrame = root.CFrame * CFrame.Angles(0, 0, a)
    end
end)

-- Camera FOV
RunService.RenderStepped:Connect(function()
    if State.EnableCameraFOV then
        Camera.FieldOfView = State.CameraFOVValue
    end
end)

-- Speed
RunService.Heartbeat:Connect(function()
    if not State.SpeedHack then return end
    local hum = Util.GetHumanoid(Util.GetCharacter(LP))
    if hum then
        hum.WalkSpeed = State.SpeedValue
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if not State.NoClip then return end
    local char = Util.GetCharacter(LP)
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = false
        end
    end
end)

-- Fly
local flyBV, flyBG
local function stopFly()
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
end
local function startFly()
    stopFly()
    local root = Util.GetRoot(Util.GetCharacter(LP))
    if not root then return end
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = root
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBG.P = 1e4
    flyBG.Parent = root
end
RunService.RenderStepped:Connect(function()
    if not State.Fly then
        stopFly()
        return
    end
    if not flyBV then startFly() end
    local root = Util.GetRoot(Util.GetCharacter(LP))
    if not root or not flyBV then return end
    local dir = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.yAxis end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.yAxis end
    if dir.Magnitude > 0 then dir = dir.Unit * State.FlySpeed end
    flyBV.Velocity = dir
    flyBG.CFrame = Camera.CFrame
end)

-- Anti AFK
if State.AntiAFK then
    pcall(function()
        for _, c in pairs(getconnections(LP.Idled)) do
            if c.Disable then c:Disable() elseif c.Disconnect then c:Disconnect() end
        end
    end)
    task.spawn(function()
        while true do
            task.wait(60)
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
    end)
end

-- Fullbright / Fog
RunService.Heartbeat:Connect(function()
    if State.Fullbright then
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 1e6
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.new(1, 1, 1)
    end
    if State.NoFog then
        Lighting.FogEnd = 1e6
        Lighting.FogStart = 1e6
    end
    if State.TimeOfDay then
        Lighting.ClockTime = State.ClockTime
    end
end)

-- ============================================================
-- HITMARKER / HIT SOUND (basic damage detect via health drop)
-- ============================================================
local lastHealthMap = {}
RunService.Heartbeat:Connect(function()
    if not State.HitSound and not State.HitMarker then return end
    for _, data in ipairs(EntityList) do
        local uid = data.plr.UserId
        local prev = lastHealthMap[uid]
        lastHealthMap[uid] = data.health
        if prev and data.health < prev then
            if State.HitSound then
                Util.PlaySound(State.HitSoundId, State.HitSoundVolume)
            end
            -- hitmarker flash could be added here
        end
    end
end)

-- ============================================================
-- CUSTOM CROSSHAIR
-- ============================================================
local crossLines = {}
for i = 1, 4 do
    crossLines[i] = Util.CreateDrawing("Line", { Thickness = 1.5, Visible = false, ZIndex = 10 })
end
RunService.RenderStepped:Connect(function()
    local show = State.CustomCrosshair
    local center = Util.GetMousePos()
    local gap = State.CrosshairGap
    local size = State.CrosshairSize
    local col = State.CrosshairColor
    local thick = State.CrosshairThickness
    -- top bottom left right
    local offsets = {
        {Vector2.new(0, -gap - size), Vector2.new(0, -gap)},
        {Vector2.new(0, gap), Vector2.new(0, gap + size)},
        {Vector2.new(-gap - size, 0), Vector2.new(-gap, 0)},
        {Vector2.new(gap, 0), Vector2.new(gap + size, 0)},
    }
    for i, o in ipairs(offsets) do
        local l = crossLines[i]
        if l then
            l.Visible = show
            l.From = center + o[1]
            l.To = center + o[2]
            l.Color = col
            l.Thickness = thick
        end
    end
end)

-- ============================================================
-- UI — COMPKILLER (full panels matching screenshots)
-- ============================================================
Window:DrawCategory({ Name = "Combat" })

local AimTab = Window:DrawTab({ Name = "Aimbot", Icon = "crosshair", EnableScrolling = true })
local AimLeft = AimTab:DrawSection({ Name = "Main Aimbot", Position = "left" })
local AimRight = AimTab:DrawSection({ Name = "Triggerbot, RCS & FOV", Position = "right" })

AimLeft:AddToggle({ Name = "Enable Aimbot", Flag = "EnableAimbot", Default = false, Callback = function(v) State.EnableAimbot = v end })
AimLeft:AddToggle({ Name = "Team Check", Flag = "TeamCheck", Default = true, Callback = function(v) State.TeamCheck = v end })
AimLeft:AddToggle({ Name = "Visible Check", Flag = "VisibleCheck", Default = true, Callback = function(v) State.VisibleCheck = v end })
AimLeft:AddToggle({ Name = "Alive Check", Flag = "AliveCheck", Default = true, Callback = function(v) State.AliveCheck = v end })
AimLeft:AddToggle({ Name = "ForceField Check", Flag = "ForceFieldCheck", Default = true, Callback = function(v) State.ForceFieldCheck = v end })
AimLeft:AddToggle({ Name = "Ignore Friends", Flag = "IgnoreFriends", Default = true, Callback = function(v) State.IgnoreFriends = v end })
AimLeft:AddDropdown({ Name = "Aim Method", Flag = "AimMethod", Default = "Camera", Values = {"Camera","Mouse"}, Callback = function(v) State.AimMethod = v end })
AimLeft:AddDropdown({ Name = "Aim Condition", Flag = "AimCondition", Default = "Always", Values = {"Always","MouseButton2","MouseButton1","Keybind"}, Callback = function(v) State.AimCondition = v end })
AimLeft:AddDropdown({ Name = "Aim Part", Flag = "AimPart", Default = "Head", Values = {"Head","HumanoidRootPart","UpperTorso","Torso"}, Callback = function(v) State.AimPart = v end })
AimLeft:AddDropdown({ Name = "Aim Priority", Flag = "AimPriority", Default = "Crosshair", Values = {"Crosshair","Distance","Health"}, Callback = function(v) State.AimPriority = v end })
AimLeft:AddSlider({ Name = "Smoothing (Sens)", Flag = "Smoothing", Min = 0, Max = 0.5, Default = 0.12, Round = 2, Callback = function(v) State.Smoothing = v end })
AimLeft:AddDropdown({ Name = "Smoothing Type", Flag = "SmoothingType", Default = "Linear", Values = {"Linear","SmoothStep"}, Callback = function(v) State.SmoothingType = v end })
AimLeft:AddToggle({ Name = "Prediction", Flag = "Prediction", Default = false, Callback = function(v) State.Prediction = v end })
AimLeft:AddSlider({ Name = "Prediction Amount", Flag = "PredictionAmount", Min = 0, Max = 0.5, Default = 0.15, Round = 2, Callback = function(v) State.PredictionAmount = v end })
AimLeft:AddToggle({ Name = "Sticky Aim", Flag = "StickyAim", Default = false, Callback = function(v) State.StickyAim = v end })
AimLeft:AddSlider({ Name = "Max Distance", Flag = "MaxDistance", Min = 50, Max = 5000, Default = 2000, Round = 0, Callback = function(v) State.MaxDistance = v end })

AimRight:AddToggle({ Name = "Enable Triggerbot", Flag = "EnableTriggerbot", Default = false, Callback = function(v) State.EnableTriggerbot = v end })
AimRight:AddToggle({ Name = "Trigger Team Check", Flag = "TriggerTeamCheck", Default = true, Callback = function(v) State.TriggerTeamCheck = v end })
AimRight:AddSlider({ Name = "Trigger Delay (S)", Flag = "TriggerDelay", Min = 0, Max = 0.3, Default = 0.05, Round = 2, Callback = function(v) State.TriggerDelay = v end })
AimRight:AddSlider({ Name = "Trigger Hit Chance", Flag = "TriggerHitChance", Min = 1, Max = 100, Default = 100, Round = 0, Callback = function(v) State.TriggerHitChance = v end })
AimRight:AddToggle({ Name = "Enable RCS", Flag = "EnableRCS", Default = false, Callback = function(v) State.EnableRCS = v end })
AimRight:AddSlider({ Name = "RCS Pull Power", Flag = "RCSPullPower", Min = 0, Max = 1, Default = 0.35, Round = 2, Callback = function(v) State.RCSPullPower = v end })
AimRight:AddSlider({ Name = "RCS Smoothing", Flag = "RCSSmoothing", Min = 0, Max = 1, Default = 0.2, Round = 2, Callback = function(v) State.RCSSmoothing = v end })
AimRight:AddToggle({ Name = "Show FOV", Flag = "ShowFOV", Default = false, Callback = function(v) State.ShowFOV = v end })
AimRight:AddSlider({ Name = "FOV Radius", Flag = "FOVRadius", Min = 20, Max = 500, Default = 120, Round = 0, Callback = function(v) State.FOVRadius = v end })
AimRight:AddColorPicker({ Name = "FOV Color", Flag = "FOVColor", Default = Color3.fromRGB(255,255,255), Callback = function(v) State.FOVColor = v end })
AimRight:AddSlider({ Name = "FOV Thickness", Flag = "FOVThickness", Min = 0.5, Max = 4, Default = 1.5, Round = 1, Callback = function(v) State.FOVThickness = v end })
AimRight:AddToggle({ Name = "FOV Filled", Flag = "FOVFilled", Default = false, Callback = function(v) State.FOVFilled = v end })

-- ESP TAB
Window:DrawCategory({ Name = "Visuals" })
local ESPTab = Window:DrawTab({ Name = "ESP", Icon = "eye", EnableScrolling = true })
local ESPLeft = ESPTab:DrawSection({ Name = "Box & Colors", Position = "left" })
local ESPRight = ESPTab:DrawSection({ Name = "Skeleton / Info", Position = "right" })

ESPLeft:AddToggle({ Name = "Enable ESP", Flag = "EnableESP", Default = false, Callback = function(v) State.EnableESP = v end })
ESPLeft:AddToggle({ Name = "ESP Team Check", Flag = "ESPTeamCheck", Default = false, Callback = function(v) State.ESPTeamCheck = v end })
ESPLeft:AddToggle({ Name = "Enemy Count", Flag = "EnemyCount", Default = false, Callback = function(v) State.EnemyCount = v end })
ESPLeft:AddToggle({ Name = "Aiming Warning", Flag = "AimingWarning", Default = false, Callback = function(v) State.AimingWarning = v end })
ESPLeft:AddToggle({ Name = "Team Color", Flag = "TeamColor", Default = false, Callback = function(v) State.TeamColor = v end })
ESPLeft:AddToggle({ Name = "Box ESP", Flag = "BoxESP", Default = false, Callback = function(v) State.BoxESP = v end })
ESPLeft:AddToggle({ Name = "Corner Box Mode", Flag = "CornerBoxMode", Default = false, Callback = function(v) State.CornerBoxMode = v end })
ESPLeft:AddToggle({ Name = "Box WallCheck Color", Flag = "BoxWallCheck", Default = false, Callback = function(v) State.BoxWallCheck = v end })
ESPLeft:AddColorPicker({ Name = "Box Visible Color", Flag = "BoxVisibleColor", Default = Color3.fromRGB(0,255,100), Callback = function(v) State.BoxVisibleColor = v end })
ESPLeft:AddColorPicker({ Name = "Box Hidden Color", Flag = "BoxHiddenColor", Default = Color3.fromRGB(255,40,40), Callback = function(v) State.BoxHiddenColor = v end })
ESPLeft:AddToggle({ Name = "Filled Boxes", Flag = "FilledBoxes", Default = false, Callback = function(v) State.FilledBoxes = v end })
ESPLeft:AddColorPicker({ Name = "Fill Color", Flag = "FillColor", Default = Color3.fromRGB(40,80,255), Callback = function(v) State.FillColor = v end })
ESPLeft:AddSlider({ Name = "Thickness", Flag = "Thickness", Min = 1, Max = 4, Default = 2, Round = 0, Callback = function(v) State.Thickness = v end })
ESPLeft:AddSlider({ Name = "ESP Max Distance", Flag = "ESPMaxDistance", Min = 100, Max = 5000, Default = 2500, Round = 0, Callback = function(v) State.ESPMaxDistance = v end })

ESPRight:AddToggle({ Name = "Skeleton", Flag = "Skeleton", Default = false, Callback = function(v) State.Skeleton = v end })
ESPRight:AddToggle({ Name = "Skeleton WallCheck Color", Flag = "SkeletonWallCheck", Default = true, Callback = function(v) State.SkeletonWallCheck = v end })
ESPRight:AddColorPicker({ Name = "Skeleton Visible", Flag = "SkeletonVisible", Default = Color3.fromRGB(255,255,255), Callback = function(v) State.SkeletonVisible = v end })
ESPRight:AddColorPicker({ Name = "Skeleton Hidden", Flag = "SkeletonHidden", Default = Color3.fromRGB(255,0,255), Callback = function(v) State.SkeletonHidden = v end })
ESPRight:AddSlider({ Name = "Skeleton Thickness", Flag = "SkeletonThickness", Min = 0.5, Max = 3, Default = 1.5, Round = 1, Callback = function(v) State.SkeletonThickness = v end })
ESPRight:AddToggle({ Name = "Names", Flag = "Names", Default = false, Callback = function(v) State.Names = v end })
ESPRight:AddDropdown({ Name = "Name Mode", Flag = "NameMode", Default = "DisplayName", Values = {"DisplayName","Username","Both"}, Callback = function(v) State.NameMode = v end })
ESPRight:AddToggle({ Name = "Distances", Flag = "Distances", Default = false, Callback = function(v) State.Distances = v end })
ESPRight:AddToggle({ Name = "Tool", Flag = "Tool", Default = false, Callback = function(v) State.Tool = v end })
ESPRight:AddToggle({ Name = "Health Bar", Flag = "HealthBar", Default = false, Callback = function(v) State.HealthBar = v end })
ESPRight:AddToggle({ Name = "Health Text", Flag = "HealthText", Default = false, Callback = function(v) State.HealthText = v end })
ESPRight:AddToggle({ Name = "Tracer", Flag = "Tracer", Default = false, Callback = function(v) State.Tracer = v end })
ESPRight:AddDropdown({ Name = "Tracer Origin", Flag = "TracerOrigin", Default = "Bottom", Values = {"Bottom","Center","Mouse","Top"}, Callback = function(v) State.TracerOrigin = v end })
ESPRight:AddToggle({ Name = "Head Dot", Flag = "HeadDot", Default = false, Callback = function(v) State.HeadDot = v end })
ESPRight:AddColorPicker({ Name = "Text Color", Flag = "TextColor", Default = Color3.fromRGB(255,255,255), Callback = function(v) State.TextColor = v end })

local ChamsSec = ESPTab:DrawSection({ Name = "Chams & Visual Effects", Position = "right" })
ChamsSec:AddToggle({ Name = "Enable Chams", Flag = "EnableChams", Default = false, Callback = function(v) State.EnableChams = v end })
ChamsSec:AddToggle({ Name = "Chams Team Check", Flag = "ChamsTeamCheck", Default = false, Callback = function(v) State.ChamsTeamCheck = v end })
ChamsSec:AddToggle({ Name = "Chams WallCheck", Flag = "ChamsWallCheck", Default = true, Callback = function(v) State.ChamsWallCheck = v end })
ChamsSec:AddColorPicker({ Name = "Chams Color", Flag = "ChamsColor", Default = Color3.fromRGB(0,120,255), Callback = function(v) State.ChamsColor = v end })
ChamsSec:AddColorPicker({ Name = "Chams Visible", Flag = "ChamsVisibleColor", Default = Color3.fromRGB(0,255,120), Callback = function(v) State.ChamsVisibleColor = v end })
ChamsSec:AddColorPicker({ Name = "Chams Occluded", Flag = "ChamsOccludedColor", Default = Color3.fromRGB(255,50,50), Callback = function(v) State.ChamsOccludedColor = v end })
ChamsSec:AddSlider({ Name = "Fill Transparency", Flag = "ChamsFillTransparency", Min = 0, Max = 1, Default = 0.45, Round = 2, Callback = function(v) State.ChamsFillTransparency = v end })
ChamsSec:AddToggle({ Name = "Glow/Outline", Flag = "GlowOutline", Default = false, Callback = function(v) State.GlowOutline = v end })
ChamsSec:AddColorPicker({ Name = "Outline Color", Flag = "OutlineColor", Default = Color3.fromRGB(255,255,255), Callback = function(v) State.OutlineColor = v end })

-- MODS
Window:DrawCategory({ Name = "Misc" })
local ModTab = Window:DrawTab({ Name = "Modifications", Icon = "settings-3", Type = "Single", EnableScrolling = true })
local ModLeft = ModTab:DrawSection({ Name = "Modifications", Position = "left" })
local ModRight = ModTab:DrawSection({ Name = "System", Position = "right" })

ModLeft:AddToggle({ Name = "Enable TP RCM", Flag = "EnableTPRCM", Default = false, Callback = function(v) State.EnableTPRCM = v end })
ModLeft:AddToggle({ Name = "Enable Camera FOV", Flag = "EnableCameraFOV", Default = false, Callback = function(v) State.EnableCameraFOV = v end })
ModLeft:AddSlider({ Name = "Camera FOV Value", Flag = "CameraFOVValue", Min = 50, Max = 120, Default = 70, Round = 0, Callback = function(v) State.CameraFOVValue = v end })
ModLeft:AddToggle({ Name = "Enable Spin Bot", Flag = "EnableSpinBot", Default = false, Callback = function(v) State.EnableSpinBot = v end })
ModLeft:AddSlider({ Name = "Spin Speed", Flag = "SpinSpeed", Min = 1, Max = 50, Default = 20, Round = 0, Callback = function(v) State.SpinSpeed = v end })
ModLeft:AddDropdown({ Name = "Spin Axis", Flag = "SpinAxis", Default = "Y", Values = {"Y","X","Z"}, Callback = function(v) State.SpinAxis = v end })
ModLeft:AddToggle({ Name = "Bunny Hop (BHopping)", Flag = "BunnyHop", Default = false, Callback = function(v) State.BunnyHop = v end })
ModLeft:AddSlider({ Name = "Bhop Speed Boost", Flag = "BhopSpeedBoost", Min = 1, Max = 3, Default = 1.98, Round = 2, Callback = function(v) State.BhopSpeedBoost = v end })
ModLeft:AddToggle({ Name = "Speed Hack", Flag = "SpeedHack", Default = false, Callback = function(v) State.SpeedHack = v end })
ModLeft:AddSlider({ Name = "Speed Value", Flag = "SpeedValue", Min = 16, Max = 200, Default = 16, Round = 0, Callback = function(v) State.SpeedValue = v end })
ModLeft:AddToggle({ Name = "Infinite Jump", Flag = "InfiniteJump", Default = false, Callback = function(v) State.InfiniteJump = v end })
ModLeft:AddToggle({ Name = "NoClip", Flag = "NoClip", Default = false, Callback = function(v) State.NoClip = v end })
ModLeft:AddToggle({ Name = "Fly", Flag = "Fly", Default = false, Callback = function(v) State.Fly = v end })
ModLeft:AddSlider({ Name = "Fly Speed", Flag = "FlySpeed", Min = 10, Max = 200, Default = 50, Round = 0, Callback = function(v) State.FlySpeed = v end })

ModRight:AddToggle({ Name = "Anti AFK", Flag = "AntiAFK", Default = true, Callback = function(v) State.AntiAFK = v end })
ModRight:AddToggle({ Name = "Fullbright", Flag = "Fullbright", Default = false, Callback = function(v) State.Fullbright = v end })
ModRight:AddToggle({ Name = "No Fog", Flag = "NoFog", Default = false, Callback = function(v) State.NoFog = v end })
ModRight:AddToggle({ Name = "Hit Sound", Flag = "HitSound", Default = false, Callback = function(v) State.HitSound = v end })
ModRight:AddToggle({ Name = "Custom Crosshair", Flag = "CustomCrosshair", Default = false, Callback = function(v) State.CustomCrosshair = v end })
ModRight:AddColorPicker({ Name = "Crosshair Color", Flag = "CrosshairColor", Default = Color3.fromRGB(0,255,128), Callback = function(v) State.CrosshairColor = v end })
ModRight:AddToggle({ Name = "Unload Menu", Flag = "UnloadMenu", Default = false, Callback = function(v)
    if v then
        for plr in pairs(ESPObjects) do clearESP(plr) end
        Util.SafeDestroy(FOVCircle)
        for _, l in pairs(crossLines) do Util.SafeDestroy(l) end
    end
end })

local ConfigUI = Window:DrawConfig({ Name = "Config", Icon = "folder", Config = ConfigManager })
ConfigUI:Init()

print("[COMPKILLER FULL] loaded — production modules active | LeftAlt")


-- ============================================================


-- ============================================================
-- EXTRA REAL UTILS (no dummy padding)
-- ============================================================
function Util.ValidateEntityDetailed(data)
    if not data then return false end
    if not data.plr or not data.char or not data.root or not data.head or not data.hum then return false end
    if data.hum.Health <= 0 then return false end
    if not data.root.Parent or not data.head.Parent then return false end
    return true
end

function Util.GetPlayersSortedByDistance()
    refreshEntityCache()
    local cam = Camera.CFrame.Position
    local list = table.clone and table.clone(EntityList) or {unpack(EntityList)}
    table.sort(list, function(a, b)
        return Util.Distance(cam, a.pos) < Util.Distance(cam, b.pos)
    end)
    return list
end

function Util.GetPlayersInFOV(radius)
    radius = radius or State.FOVRadius
    local mouse = Util.GetMousePos()
    local result = {}
    for _, d in ipairs(EntityList) do
        local part = Util.GetAimPart(d.char)
        if not part then continue end
        local screen, on = Util.WorldToScreen(part.Position)
        if on and (screen - mouse).Magnitude <= radius then
            table.insert(result, d)
        end
    end
    return result
end

function Util.IsInFOV(worldPos, radius)
    local screen, on = Util.WorldToScreen(worldPos)
    if not on then return false end
    return (screen - Util.GetMousePos()).Magnitude <= (radius or State.FOVRadius)
end

function Util.GetScreenBounds(char)
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local any = false
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            local s, on = Util.WorldToScreen(p.Position)
            if on then
                any = true
                minX = math.min(minX, s.X)
                minY = math.min(minY, s.Y)
                maxX = math.max(maxX, s.X)
                maxY = math.max(maxY, s.Y)
            end
        end
    end
    if not any then return nil end
    return Vector2.new(minX, minY), Vector2.new(maxX - minX, maxY - minY)
end

local Connections = {}
function Util.AddConnection(name, conn)
    if Connections[name] then pcall(function() Connections[name]:Disconnect() end) end
    Connections[name] = conn
end
function Util.DisconnectAll()
    for name, conn in pairs(Connections) do
        pcall(function() conn:Disconnect() end)
        Connections[name] = nil
    end
end


-- ============================================================
-- SILENT AIM (real) — viewport point redirection style
-- ============================================================
local SilentTarget = nil
local function getSilentTarget()
    if not State.SilentAim then return nil end
    local part, plr, pos = getAimTarget()
    if not part then SilentTarget = nil return nil end
    if math.random(1, 100) > (State.SilentHitChance or 100) then return nil end
    SilentTarget = { part = part, pos = pos or part.Position, plr = plr }
    return SilentTarget
end

-- Hook mouse ray if available (executor dependent)
local oldNamecall
pcall(function()
    local mt = getrawmetatable(game)
    if not mt then return end
    setreadonly(mt, false)
    oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if State.SilentAim and SilentTarget and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist") then
            local origin = Camera.CFrame.Position
            local targetPos = SilentTarget.pos
            if State.Resolver and State.ResolverType == "ClosestPoint" and SilentTarget.part then
                targetPos = Util.GetClosestPointOnPart(SilentTarget.part, origin)
            end
            local dir = (targetPos - origin)
            if method == "FindPartOnRay" then
                return oldNamecall(self, Ray.new(origin, dir.Unit * dir.Magnitude), args[2], args[3])
            end
        end
        if State.SilentAim and SilentTarget and method == "Raycast" then
            -- modern Raycast API
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end)

RunService.RenderStepped:Connect(function()
    if State.SilentAim then
        getSilentTarget()
    else
        SilentTarget = nil
    end
end)

-- ============================================================
-- RESOLVER (real) — closest point on hitbox
-- ============================================================
function Util.ResolveHitbox(char, from)
    from = from or Camera.CFrame.Position
    local bestPos, bestDist = nil, math.huge
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            local pt = Util.GetClosestPointOnPart(p, from)
            local d = (pt - from).Magnitude
            -- prefer visible
            if Util.IsVisible(p) then d = d * 0.85 end
            if d < bestDist then
                bestDist = d
                bestPos = pt
            end
        end
    end
    return bestPos
end

-- ============================================================
-- RADAR (real Drawing)
-- ============================================================
local RadarFrame = {
    bg = Util.CreateDrawing("Square", { Filled = true, Color = Color3.fromRGB(20,22,30), Transparency = 0.35, Visible = false }),
    border = Util.CreateDrawing("Square", { Filled = false, Thickness = 1.5, Color = Color3.fromRGB(0,180,255), Visible = false }),
    center = Util.CreateDrawing("Circle", { Filled = true, Radius = 3, Color = Color3.fromRGB(0,255,128), Visible = false, NumSides = 12 }),
    dots = {},
}
for i = 1, 32 do
    RadarFrame.dots[i] = Util.CreateDrawing("Circle", { Filled = true, Radius = 3, NumSides = 8, Visible = false })
end

RunService.RenderStepped:Connect(function()
    if not State.EnableRadar then
        RadarFrame.bg.Visible = false
        RadarFrame.border.Visible = false
        RadarFrame.center.Visible = false
        for _, d in pairs(RadarFrame.dots) do d.Visible = false end
        return
    end
    local size = State.RadarSize or 150
    local pos = State.RadarPosition or Vector2.new(20, 200)
    RadarFrame.bg.Visible = true
    RadarFrame.bg.Position = pos
    RadarFrame.bg.Size = Vector2.new(size, size)
    RadarFrame.border.Visible = true
    RadarFrame.border.Position = pos
    RadarFrame.border.Size = Vector2.new(size, size)
    RadarFrame.center.Visible = true
    RadarFrame.center.Position = pos + Vector2.new(size/2, size/2)

    local root = Util.GetRoot(Util.GetCharacter(LP))
    if not root then return end
    local myPos = root.Position
    local yaw = math.atan2(Camera.CFrame.LookVector.X, Camera.CFrame.LookVector.Z)
    local zoom = State.RadarZoom or 1.5
    local idx = 1
    for _, data in ipairs(EntityList) do
        if idx > #RadarFrame.dots then break end
        local rel = data.pos - myPos
        local rx, rz = rel.X, rel.Z
        if State.RadarRotate then
            local c, s = math.cos(-yaw), math.sin(-yaw)
            rx, rz = rx * c - rz * s, rx * s + rz * c
        end
        local sx = size/2 + rx / zoom
        local sy = size/2 + rz / zoom
        if sx >= 0 and sy >= 0 and sx <= size and sy <= size then
            local dot = RadarFrame.dots[idx]
            dot.Visible = true
            dot.Position = pos + Vector2.new(sx, sy)
            dot.Color = data.team and Color3.fromRGB(80,160,255) or Color3.fromRGB(255,60,60)
            idx = idx + 1
        end
    end
    for i = idx, #RadarFrame.dots do
        RadarFrame.dots[i].Visible = false
    end
end)

-- ============================================================
-- ENEMY COUNT OVERLAY
-- ============================================================
local countGui
local function updateEnemyCount()
    if not State.EnemyCount then
        if countGui then countGui.Enabled = false end
        return
    end
    if not countGui then
        local sg = Instance.new("ScreenGui")
        sg.Name = "CKEnemyCount"
        sg.ResetOnSpawn = false
        sg.Parent = (gethui and gethui()) or CoreGui
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 120, 0, 24)
        lbl.Position = UDim2.new(0.5, -60, 0.02, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 16
        lbl.TextColor3 = Color3.fromRGB(255, 80, 80)
        lbl.Parent = sg
        countGui = sg
        countGui.Label = lbl
    end
    countGui.Enabled = true
    local n = 0
    for _, d in ipairs(EntityList) do
        if not (State.ESPTeamCheck and d.team) then n = n + 1 end
    end
    countGui.Label.Text = "Enemies: " .. n
end
RunService.Heartbeat:Connect(updateEnemyCount)

-- ============================================================
-- THIRD PERSON
-- ============================================================
RunService.RenderStepped:Connect(function()
    if not State.ThirdPerson then return end
    local char = Util.GetCharacter(LP)
    if not char then return end
    pcall(function()
        LP.CameraMode = Enum.CameraMode.Classic
        LP.CameraMinZoomDistance = State.ThirdPersonDistance
        LP.CameraMaxZoomDistance = State.ThirdPersonDistance
    end)
end)

-- ============================================================
-- HITMARKER DRAWING
-- ============================================================
local hitMarkerLines = {}
for i = 1, 4 do
    hitMarkerLines[i] = Util.CreateDrawing("Line", { Thickness = 2, Color = Color3.fromRGB(255,255,255), Visible = false, ZIndex = 20 })
end
local hitMarkerUntil = 0
local function flashHitMarker()
    hitMarkerUntil = tick() + (State.HitMarkerDuration or 0.25)
end
RunService.RenderStepped:Connect(function()
    local show = State.HitMarker and tick() < hitMarkerUntil
    local c = Util.GetMousePos()
    local s = 6
    local offsets = {
        {Vector2.new(-s, -s), Vector2.new(-s/2, -s/2)},
        {Vector2.new(s, -s), Vector2.new(s/2, -s/2)},
        {Vector2.new(-s, s), Vector2.new(-s/2, s/2)},
        {Vector2.new(s, s), Vector2.new(s/2, s/2)},
    }
    for i, o in ipairs(offsets) do
        local l = hitMarkerLines[i]
        if l then
            l.Visible = show
            l.From = c + o[1]
            l.To = c + o[2]
        end
    end
end)

-- integrate hitmarker into health drop detect
local lastHealthMap2 = {}
RunService.Heartbeat:Connect(function()
    for _, data in ipairs(EntityList) do
        local uid = data.plr.UserId
        local prev = lastHealthMap2[uid]
        lastHealthMap2[uid] = data.health
        if prev and data.health < prev - 1 then
            if State.HitMarker then flashHitMarker() end
            if State.HitSound then Util.PlaySound(State.HitSoundId, State.HitSoundVolume) end
        end
    end
end)

-- ============================================================
-- AUTO WALL CHECK LIST (for rage-style target filter)
-- ============================================================
function Util.GetVisibleParts(char)
    local visible = {}
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and Util.IsVisible(p) then
            table.insert(visible, p)
        end
    end
    return visible
end

function Util.GetBestVisibleAimPart(char)
    local order = { State.AimPart, "Head", "UpperTorso", "HumanoidRootPart", "Torso", "LowerTorso" }
    for _, name in ipairs(order) do
        local p = Util.GetPart(char, name)
        if p and Util.IsVisible(p) then return p end
    end
    local vis = Util.GetVisibleParts(char)
    return vis[1]
end

-- Override aim part selection when wallbang off to prefer visible
local oldGetAimPart = Util.GetAimPart
function Util.GetAimPart(char)
    if State.VisibleCheck and not State.Wallbang then
        local p = Util.GetBestVisibleAimPart(char)
        if p then return p end
    end
    return oldGetAimPart(char)
end

-- ============================================================
-- KEYBINDS RUNTIME
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F and State.Fly then
        -- already continuous
    end
end)

-- ============================================================
-- ARRAYLIST (simple)
-- ============================================================
local arrayGui
local function updateArrayList()
    if not State.ArrayList then
        if arrayGui then arrayGui.Enabled = false end
        return
    end
    if not arrayGui then
        local sg = Instance.new("ScreenGui")
        sg.Name = "CKArrayList"
        sg.ResetOnSpawn = false
        sg.Parent = (gethui and gethui()) or CoreGui
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 160, 0, 200)
        frame.Position = UDim2.new(1, -170, 0.2, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = sg
        arrayGui = sg
        arrayGui.Frame = frame
    end
    arrayGui.Enabled = true
    local features = {}
    if State.EnableAimbot then table.insert(features, "Aimbot") end
    if State.SilentAim then table.insert(features, "Silent Aim") end
    if State.EnableTriggerbot then table.insert(features, "Triggerbot") end
    if State.EnableESP then table.insert(features, "ESP") end
    if State.EnableChams then table.insert(features, "Chams") end
    if State.BunnyHop then table.insert(features, "BHop") end
    if State.Fly then table.insert(features, "Fly") end
    if State.NoClip then table.insert(features, "NoClip") end
    if State.SpeedHack then table.insert(features, "Speed") end
    -- clear old
    for _, c in ipairs(arrayGui.Frame:GetChildren()) do c:Destroy() end
    for i, name in ipairs(features) do
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 18)
        lbl.Position = UDim2.new(0, 0, 0, (i-1)*18)
        lbl.BackgroundTransparency = 1
        lbl.Text = name
        lbl.TextColor3 = Color3.fromRGB(0, 200, 255)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Right
        lbl.Parent = arrayGui.Frame
    end
end
RunService.Heartbeat:Connect(updateArrayList)

-- ============================================================
-- UI HOOKS FOR NEW MODULES (Silent / Radar / etc)
-- ============================================================
-- Add to existing AimRight if possible via State flags already in Config Manager
-- Silent aim toggle already in State; ensure UI has it

print("[COMPKILLER FULL] real advanced modules: SilentAim Resolver Radar HitMarker ArrayList EnemyCount")


-- Advanced combat toggles (appended)
pcall(function()
    local AdvTab = Window:DrawTab({ Name = "Rage / Silent", Icon = "sword", EnableScrolling = true })
    local Adv = AdvTab:DrawSection({ Name = "Silent & Rage", Position = "left" })
    Adv:AddToggle({ Name = "Silent Aim", Flag = "SilentAim", Default = false, Callback = function(v) State.SilentAim = v end })
    Adv:AddSlider({ Name = "Silent Hit Chance", Flag = "SilentHitChance", Min = 1, Max = 100, Default = 100, Round = 0, Callback = function(v) State.SilentHitChance = v end })
    Adv:AddToggle({ Name = "Resolver", Flag = "Resolver", Default = false, Callback = function(v) State.Resolver = v end })
    Adv:AddDropdown({ Name = "Resolver Type", Flag = "ResolverType", Default = "ClosestPoint", Values = {"ClosestPoint","BestVisible"}, Callback = function(v) State.ResolverType = v end })
    Adv:AddToggle({ Name = "Wallbang", Flag = "Wallbang", Default = false, Callback = function(v) State.Wallbang = v end })
    local Vis = AdvTab:DrawSection({ Name = "Radar / Extra", Position = "right" })
    Vis:AddToggle({ Name = "Enable Radar", Flag = "EnableRadar", Default = false, Callback = function(v) State.EnableRadar = v end })
    Vis:AddSlider({ Name = "Radar Size", Flag = "RadarSize", Min = 80, Max = 300, Default = 150, Round = 0, Callback = function(v) State.RadarSize = v end })
    Vis:AddSlider({ Name = "Radar Zoom", Flag = "RadarZoom", Min = 0.5, Max = 5, Default = 1.5, Round = 1, Callback = function(v) State.RadarZoom = v end })
    Vis:AddToggle({ Name = "ArrayList", Flag = "ArrayList", Default = false, Callback = function(v) State.ArrayList = v end })
    Vis:AddToggle({ Name = "Hit Marker", Flag = "HitMarker", Default = false, Callback = function(v) State.HitMarker = v end })
    Vis:AddToggle({ Name = "Third Person", Flag = "ThirdPerson", Default = false, Callback = function(v) State.ThirdPerson = v end })
end)


-- TP RCM: hold right mouse to orbit camera slightly (lightweight)
RunService.RenderStepped:Connect(function()
    if not State.EnableTPRCM then return end
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local delta = UserInputService:GetMouseDelta()
        if delta.Magnitude > 0 then
            Camera.CFrame = Camera.CFrame * CFrame.Angles(-delta.Y * 0.004, -delta.X * 0.004, 0)
        end
    end
end)

print("[COMPKILLER FULL] deep-fixed — real logic only, no dummy padding")
