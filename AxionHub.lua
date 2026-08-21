--[[
    BLOX FRUITS FULL FEATURE HUB
    Reconstructed from constant pool dump
    Modular, toggle-driven, Fluent UI based
    For educational / private server use only
]]

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

World1 = (game.PlaceId == 2753915549)
World2 = (game.PlaceId == 4442272183)
World3 = (game.PlaceId == 7449423635)
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- Global state
getgenv().BFHub = getgenv().BFHub or {}
local Hub = getgenv().BFHub
Hub.Flags = Hub.Flags or {}
Hub.Connections = Hub.Connections or {}
Hub.Running = Hub.Running or {}

local function SetFlag(name, value)
    Hub.Flags[name] = value
end

local function GetFlag(name)
    return Hub.Flags[name]
end

local function Connect(name, signal, callback)
    if Hub.Connections[name] then
        Hub.Connections[name]:Disconnect()
    end
    Hub.Connections[name] = signal:Connect(callback)
end

local function Disconnect(name)
    if Hub.Connections[name] then
        Hub.Connections[name]:Disconnect()
        Hub.Connections[name] = nil
    end
end

-- Safe remote helpers
local function FireComm(...)
    local ok, err = pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local comm = remotes:FindFirstChild("CommF_") or remotes:FindFirstChild("CommE")
            if comm then
                if comm:IsA("RemoteFunction") then
                    return comm:InvokeServer(...)
                elseif comm:IsA("RemoteEvent") then
                    return comm:FireServer(...)
                end
            end
        end
    end)
    return ok
end

local function FireNet(path, ...)
    pcall(function()
        local net = ReplicatedStorage:FindFirstChild("Net") or ReplicatedStorage:FindFirstChild("Network")
        if not net then return end
        local remote = net
        for _, part in ipairs(string.split(path, "/")) do
            remote = remote:FindFirstChild(part)
            if not remote then return end
        end
        if remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(...)
        end
    end)
end

-- Character refresh + Stun clear + SimulationRadius (optimized single path)
local function BindCharacter(char)
    Character = char
    HumanoidRootPart = char:WaitForChild("HumanoidRootPart", 10)
    Humanoid = char:WaitForChild("Humanoid", 10)
    pcall(function()
        local stun = char:FindFirstChild("Stun")
        if stun then
            stun.Changed:Connect(function()
                pcall(function() stun.Value = 0 end)
            end)
            stun.Value = 0
        end
    end)
end
if Character then BindCharacter(Character) end
LocalPlayer.CharacterAdded:Connect(BindCharacter)

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if sethiddenproperty then
                sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            end
            if setscriptable then
                pcall(setscriptable, LocalPlayer, "SimulationRadius", true)
            end
            if Character and Character:FindFirstChild("Stun") then
                Character.Stun.Value = 0
            end
        end)
    end
end)

Connect("AntiAFK", LocalPlayer.Idled, function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- Noclip + freeze while any farm flag active (from reference)
local FarmActiveFlags = {
    "AutoFarmLevel", "AutoFarmNearest", "AutoFarmChest", "AutoKillBoss",
    "AutoCollectFruit", "AutoFishing", "AutoBones", "AutoFarmEctoplasm",
    "AutoMasterySword", "AutoMasteryFruit", "AutoMasteryGun",
    "AutoCakePrince", "AutoDarkbeard", "AutoSoulReaper", "AutoDonSwan",
    "AutoAllBoss", "MobAura", "AutoCompleteRaid", "AutoSaber",
    "AutoTerrorShark", "AutoSeaBeast", "AutoLeviathan", "EliteHunter",
    "AutoFarmMaterial", "AutoRengoku", "AutoPole", "AutoShark", "AutoPiranha",
    "AutoCDK", "AutoTushita", "AutoYama", "AutoFactoryRaid", "AutoPirateRaid",
    "AutoFarmRaid", "AutoBartilo", "AutoCitizen", "AutoEliteQuest",
    "AutoFarmObservation", "AutoStartRaid"
}

local function AnyFarmActive()
    for _, name in ipairs(FarmActiveFlags) do
        if GetFlag(name) then return true end
    end
    return false
end

task.spawn(function()
    while true do
        task.wait(GetFlag("FastFarm") and 0.08 or 0.12)
        pcall(function()
            if not Character or not HumanoidRootPart or not Humanoid then return end
            if AnyFarmActive() then
                -- anti sit
                if Humanoid.Sit then Humanoid.Sit = false end
                -- body velocity lock
                if not HumanoidRootPart:FindFirstChild("BodyVelocity1") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "BodyVelocity1"
                    bv.MaxForce = Vector3.new(10000, 10000, 10000)
                    bv.Velocity = Vector3.new(0, 0, 0)
                    bv.Parent = HumanoidRootPart
                end
                -- noclip parts
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            else
                local bv = HumanoidRootPart:FindFirstChild("BodyVelocity1")
                if bv then bv:Destroy() end
            end
        end)
    end
end)

-------------------------------------------------
-- UI (Fluent) — multi-mirror + SaveManager + safe fallback
-------------------------------------------------
local Fluent, SaveManager, InterfaceManager

local FLUENT_URLS = {
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua",
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/main.lua",
    "https://cdn.jsdelivr.net/gh/dawid-scripts/Fluent@master/main.lua",
}

local function HttpGet(url)
    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and body and #body > 100 then return body end
    ok, body = pcall(function()
        return game:HttpGet(url, true)
    end)
    if ok and body and #body > 100 then return body end
    if syn and syn.request then
        ok, body = pcall(function()
            local r = syn.request({Url = url, Method = "GET"})
            return r.Body
        end)
        if ok and body and #body > 100 then return body end
    end
    if http_request then
        ok, body = pcall(function()
            local r = http_request({Url = url, Method = "GET"})
            return r.Body
        end)
        if ok and body and #body > 100 then return body end
    end
    if request then
        ok, body = pcall(function()
            local r = request({Url = url, Method = "GET"})
            return r.Body
        end)
        if ok and body and #body > 100 then return body end
    end
    return nil
end

local function LoadFluentLib()
    for _, url in ipairs(FLUENT_URLS) do
        local body = HttpGet(url)
        if body then
            local ok, res = pcall(function()
                return loadstring(body)()
            end)
            if ok and type(res) == "table" and res.CreateWindow then
                print("[BFHub] Fluent loaded from", url:match("https://([^/]+)") or url)
                return res
            end
        end
    end
    return nil
end

Fluent = LoadFluentLib()
if not Fluent then
    warn("[BFHub] Fluent load failed — limited UI")
    Fluent = {
        CreateWindow = function()
            return {
                AddTab = function()
                    return {
                        AddToggle = function() return {} end,
                        AddButton = function() return {} end,
                        AddDropdown = function() return {} end,
                        AddSlider = function() return {} end,
                        AddParagraph = function() return { SetDesc = function() end } end,
                        AddSection = function() return {} end,
                        AddInput = function() return {} end,
                    }
                end,
                SelectTab = function() end,
            }
        end,
        Notify = function(opts)
            pcall(function()
                game.StarterGui:SetCore("SendNotification", {
                    Title = opts.Title or "BF Hub",
                    Text = opts.Content or "",
                    Duration = opts.Duration or 4,
                })
            end)
        end,
        Options = {},
    }
end

pcall(function()
    local body = HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua")
    if body then SaveManager = loadstring(body)() end
end)
pcall(function()
    local body = HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua")
    if body then InterfaceManager = loadstring(body)() end
end)

local Window = Fluent:CreateWindow({
    Title = "BF Full Hub" .. (Fluent.Version and ("  " .. tostring(Fluent.Version)) or ""),
    SubTitle = "Axion · No Key",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 480),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl,
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Farm = Window:AddTab({ Title = "Auto Farm", Icon = "swords" }),
    Mastery = Window:AddTab({ Title = "Mastery", Icon = "target" }),
    Bosses = Window:AddTab({ Title = "Bosses", Icon = "skull" }),
    Raids = Window:AddTab({ Title = "Raids", Icon = "castle" }),
    Quests = Window:AddTab({ Title = "Quests", Icon = "scroll" }),
    Sea = Window:AddTab({ Title = "Sea Events", Icon = "waves" }),
    Fruits = Window:AddTab({ Title = "Fruits", Icon = "apple" }),
    Swords = Window:AddTab({ Title = "Swords", Icon = "sword" }),
    Race = Window:AddTab({ Title = "Race / Haki", Icon = "user" }),
    TP = Window:AddTab({ Title = "Teleport", Icon = "map-pin" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    Fish = Window:AddTab({ Title = "Fishing", Icon = "fish" }),
    Shop = Window:AddTab({ Title = "Shop / Craft", Icon = "shopping-cart" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
}

local function Notify(title, content, duration)
    pcall(function()
        Fluent:Notify({
            Title = title or "BF Hub",
            Content = content or "",
            Duration = duration or 4,
        })
    end)
end


-- Harden tab methods (never throw into Fluent internals)
local function HardenTab(tab)
    if not tab or type(tab) ~= "table" then return tab end
    for _, method in ipairs({"AddToggle", "AddButton", "AddSlider", "AddDropdown", "AddParagraph", "AddSection", "AddInput", "AddKeybind"}) do
        local original = tab[method]
        if type(original) == "function" then
            tab[method] = function(...)
                local ok, res = pcall(original, ...)
                if ok then return res end
                warn("[BFHub] UI", method, "failed:", tostring(res))
                return { SetDesc = function() end, SetValue = function() end }
            end
        end
    end
    return tab
end
for name, tab in pairs(Tabs) do
    Tabs[name] = HardenTab(tab)
end

local function SetParagraph(para, text)
    if not para then return end
    pcall(function()
        if para.SetDesc then para:SetDesc(text) end
    end)
end

-------------------------------------------------
-- Utility: Tween / Bring / Attack
-------------------------------------------------
-- Fast tween: high speed + short-range snap + optional bypass TP (from reference)
local ActiveTween = nil
local function TweenTo(cframe, speed)
    if not HumanoidRootPart or not cframe then return end
    speed = speed or (GetFlag("TweenSpeed") or 320)
    -- Fast Farm mode pushes speed higher
    if GetFlag("FastFarm") then
        speed = math.max(speed, 450)
    end
    local dist = (HumanoidRootPart.Position - cframe.Position).Magnitude
    -- snap if already close
    if dist <= 12 then
        pcall(function() HumanoidRootPart.CFrame = cframe end)
        return
    end
    -- bypass / instant for very long distance (optional)
    if GetFlag("BypassTP") and dist > 2500 then
        pcall(function()
            if ActiveTween then ActiveTween:Cancel() end
            HumanoidRootPart.CFrame = cframe
            if Humanoid then Humanoid:ChangeState(11) end
        end)
        task.wait(0.08)
        return
    end
    -- cancel previous tween so we don't stack
    if ActiveTween then
        pcall(function() ActiveTween:Cancel() end)
        ActiveTween = nil
    end
    local duration = math.clamp(dist / speed, 0.05, 8)
    local ok, tw = pcall(function()
        return TweenService:Create(
            HumanoidRootPart,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {CFrame = cframe}
        )
    end)
    if ok and tw then
        ActiveTween = tw
        tw:Play()
        -- don't block forever: wait max duration+epsilon
        local t0 = os.clock()
        while ActiveTween == tw and tw.PlaybackState == Enum.PlaybackState.Playing do
            if os.clock() - t0 > duration + 0.15 then break end
            -- if already close enough, cancel and snap
            if HumanoidRootPart and (HumanoidRootPart.Position - cframe.Position).Magnitude <= 10 then
                pcall(function() tw:Cancel() end)
                pcall(function() HumanoidRootPart.CFrame = cframe end)
                break
            end
            task.wait()
        end
        if ActiveTween == tw then ActiveTween = nil end
    else
        pcall(function() HumanoidRootPart.CFrame = cframe end)
    end
end


-- Banana-style farm position: stand above mob looking down (stable)
local function BananaFarmCF(mobHRP, dist)
    dist = dist or (GetFlag("DistanceAutoFarm") or 8)
    if not mobHRP then return nil end
    return mobHRP.CFrame * CFrame.Angles(math.rad(-90), 0, 0) * CFrame.new(0, 0, dist)
end

local function GetNearestEnemy(maxDist)
    maxDist = maxDist or 1000
    if not HumanoidRootPart then return nil end
    local closest, closestDist = nil, maxDist
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    local myPos = HumanoidRootPart.Position
    local children = enemies:GetChildren()
    for i = 1, #children do
        local mob = children[i]
        local hrp = mob:FindFirstChild("HumanoidRootPart")
        local hum = mob:FindFirstChild("Humanoid")
        if hrp and hum and hum.Health > 0 then
            local d = (myPos - hrp.Position).Magnitude
            if d < closestDist then
                closest = mob
                closestDist = d
                if d < 12 then return closest end -- early exit
            end
        end
    end
    return closest
end

-- PosMon magnet point (reference-style)
local PosMon = nil
local StartMagnet = false

local function SetMagnetPoint(cf)
    PosMon = cf
    StartMagnet = true
end

local function StopMagnet()
    StartMagnet = false
    PosMon = nil
end

local function BringEnemy(mob)
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end
    pcall(function()
        local hrp = mob.HumanoidRootPart
        local target = PosMon or (HumanoidRootPart.CFrame * CFrame.new(0, 0, -5))
        hrp.CFrame = target
        hrp.CanCollide = false
        hrp.Size = Vector3.new(60, 60, 60)
        hrp.Transparency = 1
        if mob:FindFirstChild("Humanoid") then
            mob.Humanoid.WalkSpeed = 0
            mob.Humanoid.JumpPower = 0
            if mob.Humanoid:FindFirstChild("Animator") then
                pcall(function() mob.Humanoid.Animator:Destroy() end)
            end
            pcall(function()
                mob.Humanoid:ChangeState(11)
                mob.Humanoid:ChangeState(14)
            end)
        end
        if mob:FindFirstChild("Head") then
            mob.Head.CanCollide = false
        end
    end)
end

-- Continuous magnet loop (faster tick for farm speed)
task.spawn(function()
    while true do
        -- yield more when farm parallel bring is active (avoid double iterate Enemies)
        if GetFlag("AutoFarmLevel") then
            task.wait(0.2)
        else
            task.wait(GetFlag("FastFarm") and 0.06 or 0.1)
        end
        if StartMagnet and PosMon and GetFlag("BringEnemy") and not (GetFlag("AutoFarmLevel")) then
            pcall(function()
                local enemies = workspace:FindFirstChild("Enemies")
                if not enemies or not HumanoidRootPart then return end
                for _, mob in ipairs(enemies:GetChildren()) do
                    local hrp = mob:FindFirstChild("HumanoidRootPart")
                    local hum = mob:FindFirstChild("Humanoid")
                    if hrp and hum and hum.Health > 0 and not mob.Name:find("Boss") then
                        local dist = (hrp.Position - HumanoidRootPart.Position).Magnitude
                        if dist <= 500 then
                            hrp.CFrame = PosMon
                            hrp.CanCollide = false
                            hrp.Size = Vector3.new(60, 60, 60)
                            hrp.Transparency = 1
                            hum.WalkSpeed = 0
                            hum.JumpPower = 0
                            if hum:FindFirstChild("Animator") then
                                pcall(function() hum.Animator:Destroy() end)
                            end
                            pcall(function()
                                hum:ChangeState(11)
                                hum:ChangeState(14)
                            end)
                        end
                    end
                end
            end)
        end
    end
end)


local function EquipWeapon(name)
    pcall(function()
        local tool = LocalPlayer.Backpack:FindFirstChild(name)
        if tool then
            Humanoid:EquipTool(tool)
        end
    end)
end

local function EquipWeaponSword()
    pcall(function()
        for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if t:IsA("Tool") and t.ToolTip == "Sword" then
                Humanoid:EquipTool(t)
                break
            end
        end
    end)
end

local function EquipTool(name)
    local tool = LocalPlayer.Backpack:FindFirstChild(name) or Character:FindFirstChild(name)
    if tool then
        Humanoid:EquipTool(tool)
        return true
    end
    return false
end

local function AttackNearest()
    local mob = GetNearestEnemy(50)
    if not mob then return end
    pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("RegisterHit")
        if remote then
            remote:FireServer(mob.HumanoidRootPart, {})
        end
        -- M1 simulation
        VirtualUser:ClickButton1(Vector2.new())
    end)
end

-------------------------------------------------

-------------------------------------------------
-- QUEST SYSTEM — exact CheckQuest from Axion's full reference (no key system)
World1 = (game.PlaceId == 2753915549)
World2 = (game.PlaceId == 4442272183)
World3 = (game.PlaceId == 7449423635)

Name, QuestName, LevelQuest, NameMon = nil, nil, 1, nil
CFrameMon, VectorMon, CFrameQuest, VectorQuest, LevelFarm = nil, nil, nil, nil, nil

local CurrentQuest = {
    Mon = nil,
    NameMon = nil,
    NameQuest = nil,
    LevelQuest = 1,
    CFrameQuest = nil,
    CFrameMon = nil,
}

function CheckQuest()
    local v288 = game.Players.LocalPlayer.Data.Level.Value
    if World1 then
        if v288 == 1 or v288 <= 9 then
            LevelFarm = 1
            Name = "Bandit [Lv. 5]"
            QuestName = "BanditQuest1"
            LevelQuest = 1
            NameMon = "Bandit"
            CFrameMon = CFrame.new(1145, 17, 1634)
            VectorMon = Vector3.new(1145, 17, 1634)
            CFrameQuest = CFrame.new(1060, 17, 1547)
            VectorQuest = Vector3.new(1060, 17, 1547)
        elseif v288 == 10 or v288 <= 14 then
            LevelFarm = 2
            Name = "Monkey [Lv. 14]"
            QuestName = "JungleQuest"
            LevelQuest = 1
            NameMon = "Monkey"
            CFrameMon = CFrame.new(- 1496, 39, 35)
            VectorMon = Vector3.new(- 1496, 39, 35)
            CFrameQuest = CFrame.new(- 1602, 37, 152)
            VectorQuest = Vector3.new(- 1602, 37, 152)
        elseif v288 == 15 or v288 <= 29 then
            LevelFarm = 3
            Name = "Gorilla [Lv. 20]"
            QuestName = "JungleQuest"
            LevelQuest = 2
            NameMon = "Gorilla"
            CFrameMon = CFrame.new(- 1237, 6, - 486)
            VectorMon = Vector3.new(- 1237, 7, - 486)
            CFrameQuest = CFrame.new(- 1602, 37, 152)
            VectorQuest = Vector3.new(- 1602, 37, 152)
        elseif v288 == 30 or v288 <= 39 then
            LevelFarm = 4
            Name = "Pirate [Lv. 35]"
            QuestName = "BuggyQuest1"
            LevelQuest = 1
            NameMon = "Pirate"
            CFrameMon = CFrame.new(- 1115, 14, 3938)
            VectorMon = Vector3.new(- 1115, 14, 3938)
            CFrameQuest = CFrame.new(- 1140, 5, 3828)
            VectorQuest = Vector3.new(- 1140, 5, 3828)
        elseif v288 == 40 or v288 <= 59 then
            LevelFarm = 5
            Name = "Brute [Lv. 45]"
            QuestName = "BuggyQuest1"
            LevelQuest = 2
            NameMon = "Brute"
            CFrameMon = CFrame.new(- 1145, 15, 4350)
            VectorMon = Vector3.new(- 1146, 15, 4350)
            CFrameQuest = CFrame.new(- 1140, 5, 3828)
            VectorQuest = Vector3.new(- 1140, 5, 3828)
        elseif v288 == 60 or v288 <= 74 then
            LevelFarm = 6
            Name = "Desert Bandit [Lv. 60]"
            QuestName = "DesertQuest"
            LevelQuest = 1
            NameMon = "Desert Bandit"
            CFrameMon = CFrame.new(932, 7, 4484)
            VectorMon = Vector3.new(932, 7, 4484)
            CFrameQuest = CFrame.new(897, 7, 4388)
            VectorQuest = Vector3.new(897, 7, 4388)
        elseif v288 == 75 or v288 <= 89 then
            LevelFarm = 7
            Name = "Desert Officer [Lv. 70]"
            QuestName = "DesertQuest"
            LevelQuest = 2
            NameMon = "Desert Officer"
            CFrameMon = CFrame.new(1572, 10, 4373)
            VectorMon = Vector3.new(1572, 10, 4373)
            CFrameQuest = CFrame.new(897, 7, 4388)
            VectorQuest = Vector3.new(897, 7, 4388)
        elseif v288 == 90 or v288 <= 99 then
            LevelFarm = 8
            Name = "Snow Bandit [Lv. 90]"
            QuestName = "SnowQuest"
            LevelQuest = 1
            NameMon = "Snow Bandits"
            CFrameMon = CFrame.new(1289, 150, - 1442)
            VectorMon = Vector3.new(1289, 106, - 1442)
            CFrameQuest = CFrame.new(1386, 87, - 1297)
            VectorQuest = Vector3.new(1386, 87, - 1297)
        elseif v288 == 100 or v288 <= 119 then
            LevelFarm = 9
            Name = "Snowman [Lv. 100]"
            QuestName = "SnowQuest"
            LevelQuest = 2
            NameMon = "Snowman"
            CFrameMon = CFrame.new(1289, 150, - 1442)
            VectorMon = Vector3.new(1289, 106, - 1442)
            CFrameQuest = CFrame.new(1386, 87, - 1297)
            VectorQuest = Vector3.new(1386, 87, - 1297)
        elseif v288 == 120 or v288 <= 149 then
            LevelFarm = 10
            Name = "Chief Petty Officer [Lv. 120]"
            QuestName = "MarineQuest2"
            LevelQuest = 1
            NameMon = "Chief Petty Officer"
            CFrameMon = CFrame.new(- 4855, 23, 4308)
            VectorMon = Vector3.new(- 4855, 23, 4308)
            CFrameQuest = CFrame.new(- 5036, 29, 4325)
            VectorQuest = Vector3.new(- 5036, 29, 4325)
        elseif v288 == 150 or v288 <= 174 then
            LevelFarm = 11
            Name = "Sky Bandit [Lv. 150]"
            QuestName = "SkyQuest"
            LevelQuest = 1
            NameMon = "Sky Bandit"
            CFrameMon = CFrame.new(- 4981, 278, - 2830)
            VectorMon = Vector3.new(- 4981, 278, - 2830)
            CFrameQuest = CFrame.new(- 4842, 718, - 2623)
            VectorQuest = Vector3.new(- 4842, 718, - 2623)
        elseif v288 == 175 or v288 <= 189 then
            LevelFarm = 12
            Name = "Dark Master [Lv. 175]"
            QuestName = "SkyQuest"
            LevelQuest = 2
            NameMon = "Dark Master"
            CFrameMon = CFrame.new(- 5250, 389, - 2272)
            VectorMon = Vector3.new(- 5250, 389, - 2272)
            CFrameQuest = CFrame.new(- 4842, 718, - 2623)
            VectorQuest = Vector3.new(- 4842, 718, - 2623)
        elseif v288 == 190 or v288 <= 209 then
            LevelFarm = 13
            Name = "Prisoner [Lv. 190]"
            QuestName = "PrisonerQuest"
            LevelQuest = 1
            NameMon = "Prisoner"
            CFrameMon = CFrame.new(5411, 96, 690)
            VectorMon = Vector3.new(5411, 96, 690)
            CFrameQuest = CFrame.new(5308, 2, 474)
            VectorQuest = Vector3.new(5308, 2, 474)
        elseif v288 == 210 or v288 <= 249 then
            LevelFarm = 14
            Name = "Dangerous Prisoner [Lv. 210]"
            QuestName = "PrisonerQuest"
            LevelQuest = 2
            NameMon = "Dangerous Prisoner"
            CFrameMon = CFrame.new(5411, 96, 690)
            VectorMon = Vector3.new(5411, 96, 690)
            CFrameQuest = CFrame.new(5308, 2, 474)
            VectorQuest = Vector3.new(5308, 2, 474)
        elseif v288 == 250 or v288 <= 299 then
            LevelFarm = 15
            Name = "Toga Warrior [Lv. 250]"
            QuestName = "ColosseumQuest"
            LevelQuest = 1
            NameMon = "Toga Warrior"
            CFrameMon = CFrame.new(- 1824, 50, - 2743)
            VectorMon = Vector3.new(- 1824, 50, - 2743)
            CFrameQuest = CFrame.new(- 1576, 8, - 2985)
            VectorQuest = Vector3.new(- 1576, 8, - 2985)
        elseif v288 == 300 or v288 <= 329 then
            LevelFarm = 16
            Name = "Military Soldier [Lv. 300]"
            QuestName = "MagmaQuest"
            LevelQuest = 1
            NameMon = "Military Soldier"
            CFrameMon = CFrame.new(- 5408, 11, 8447)
            VectorMon = Vector3.new(- 5408, 11, 8447)
            CFrameQuest = CFrame.new(- 5316, 12, 8517)
            VectorQuest = Vector3.new(- 5316, 12, 8517)
        elseif v288 == 325 or v288 <= 374 then
            LevelFarm = 17
            Name = "Military Spy [Lv. 325]"
            QuestName = "MagmaQuest"
            LevelQuest = 2
            NameMon = "Military Spy"
            CFrameMon = CFrame.new(- 5815, 84, 8820)
            VectorMon = Vector3.new(- 5815, 84, 8820)
            CFrameQuest = CFrame.new(- 5316, 12, 8517)
            VectorQuest = Vector3.new(- 5316, 12, 8517)
        elseif v288 == 375 or v288 <= 399 then
            LevelFarm = 18
            Name = "Fishman Warrior [Lv. 375]"
            QuestName = "FishmanQuest"
            LevelQuest = 1
            NameMon = "Fishman Warrior"
            CFrameMon = CFrame.new(60859, 19, 1501)
            VectorMon = Vector3.new(60859, 19, 1501)
            CFrameQuest = CFrame.new(61123, 19, 1569)
            VectorQuest = Vector3.new(61123, 19, 1569)
        elseif v288 == 400 or v288 <= 449 then
            LevelFarm = 19
            Name = "Fishman Commando [Lv. 400]"
            QuestName = "FishmanQuest"
            LevelQuest = 2
            NameMon = "Fishman Commando"
            CFrameMon = CFrame.new(61891, 19, 1470)
            VectorMon = Vector3.new(61891, 19, 1470)
            CFrameQuest = CFrame.new(61123, 19, 1569)
            VectorQuest = Vector3.new(61123, 19, 1569)
        elseif v288 == 450 or v288 <= 474 then
            LevelFarm = 20
            Name = "God\'s Guard [Lv. 450]"
            QuestName = "SkyExp1Quest"
            LevelQuest = 1
            NameMon = "God\'s Guards"
            CFrameMon = CFrame.new(- 4698, 845, - 1912)
            VectorMon = Vector3.new(- 4698, 845, - 1912)
            CFrameQuest = CFrame.new(- 4722, 845, - 1954)
            VectorQuest = Vector3.new(- 4722, 846, - 1954)
        elseif v288 == 475 or v288 <= 524 then
            LevelFarm = 21
            Name = "Shanda [Lv. 475]"
            QuestName = "SkyExp1Quest"
            LevelQuest = 2
            NameMon = "Shandas"
            CFrameMon = CFrame.new(- 7685, 5567, - 502)
            VectorMon = Vector3.new(- 7685, 5567, - 502)
            CFrameQuest = CFrame.new(- 7862, 5546, - 380)
            VectorQuest = Vector3.new(- 7862, 5546, - 380)
        elseif v288 == 525 or v288 <= 549 then
            LevelFarm = 22
            Name = "Royal Squad [Lv. 525]"
            QuestName = "SkyExp2Quest"
            LevelQuest = 1
            NameMon = "Royal Squad"
            CFrameMon = CFrame.new(- 7670, 5607, - 1460)
            VectorMon = Vector3.new(- 7670, 5607, - 1460)
            CFrameQuest = CFrame.new(- 7904, 5636, - 1412)
            VectorQuest = Vector3.new(- 7904, 5636, - 1412)
        elseif v288 == 550 or v288 <= 624 then
            LevelFarm = 23
            Name = "Royal Soldier [Lv. 550]"
            QuestName = "SkyExp2Quest"
            LevelQuest = 2
            NameMon = "Royal Soldier"
            CFrameMon = CFrame.new(- 7828, 5607, - 1744)
            VectorMon = Vector3.new(- 7828, 5607, - 1744)
            CFrameQuest = CFrame.new(- 7904, 5636, - 1412)
            VectorQuest = Vector3.new(- 7904, 5636, - 1412)
        elseif v288 == 625 or v288 <= 649 then
            LevelFarm = 24
            Name = "Galley Pirate [Lv. 625]"
            QuestName = "FountainQuest"
            LevelQuest = 1
            NameMon = "Galley Pirate"
            CFrameMon = CFrame.new(5589, 45, 3996)
            VectorMon = Vector3.new(5589, 45, 3996)
            CFrameQuest = CFrame.new(5256, 39, 4050)
            VectorQuest = Vector3.new(5256, 39, 4050)
        elseif v288 >= 650 then
            LevelFarm = 25
            Name = "Galley Captain [Lv. 650]"
            QuestName = "FountainQuest"
            LevelQuest = 2
            NameMon = "Galley Captain"
            CFrameMon = CFrame.new(5649, 39, 4936)
            VectorMon = Vector3.new(5649, 39, 4936)
            CFrameQuest = CFrame.new(5256, 39, 4050)
            VectorQuest = Vector3.new(5256, 39, 4050)
        end
    end
    if World2 then
        if v288 == 700 or v288 <= 724 then
            LevelFarm = 1
            Name = "Raider [Lv. 700]"
            QuestName = "Area1Quest"
            LevelQuest = 1
            NameMon = "Raider"
            CFrameQuest = CFrame.new(- 425, 73, 1837)
            VectorQuest = Vector3.new(- 425, 73, 1837)
            CFrameMon = CFrame.new(- 746, 39, 2390)
            VectorMon = Vector3.new(- 746, 39, 2389)
        elseif v288 == 725 or v288 <= 774 then
            LevelFarm = 2
            Name = "Mercenary [Lv. 725]"
            QuestName = "Area1Quest"
            LevelQuest = 2
            NameMon = "Mercenary"
            CFrameQuest = CFrame.new(- 425, 73, 1837)
            VectorQuest = Vector3.new(- 425, 73, 1837)
            CFrameMon = CFrame.new(- 874, 141, 1312)
            VectorMon = Vector3.new(- 874, 141, 1312)
        elseif v288 == 775 or v288 <= 799 then
            LevelFarm = 3
            Name = "Swan Pirate [Lv. 775]"
            QuestName = "Area2Quest"
            LevelQuest = 1
            NameMon = "Swan Pirate"
            CFrameQuest = CFrame.new(634, 73, 918)
            VectorQuest = Vector3.new(634, 73, 918)
            CFrameMon = CFrame.new(878, 122, 1235)
            VectorMon = Vector3.new(878, 122, 1235)
        elseif v288 == 800 or v288 <= 874 then
            LevelFarm = 4
            Name = "Factory Staff [Lv. 800]"
            QuestName = "Area2Quest"
            LevelQuest = 2
            NameMon = "Factory Staff"
            CFrameQuest = CFrame.new(634, 73, 918)
            VectorQuest = Vector3.new(634, 73, 918)
            CFrameMon = CFrame.new(295, 73, - 56)
            VectorMon = Vector3.new(295, 73, - 56)
        elseif v288 == 875 or v288 <= 899 then
            LevelFarm = 5
            Name = "Marine Lieutenant [Lv. 875]"
            QuestName = "MarineQuest3"
            LevelQuest = 1
            NameMon = "Marine Lieutenant"
            CFrameMon = CFrame.new(- 2806, 73, - 3038)
            VectorMon = Vector3.new(- 2806, 73, - 3038)
            CFrameQuest = CFrame.new(- 2443, 73, - 3219)
            VectorQuest = Vector3.new(- 2443, 73, - 3219)
        elseif v288 == 900 or v288 <= 949 then
            LevelFarm = 6
            Name = "Marine Captain [Lv. 900]"
            QuestName = "MarineQuest3"
            LevelQuest = 2
            NameMon = "Marine Captain"
            CFrameMon = CFrame.new(- 1869, 73, - 3320)
            VectorMon = Vector3.new(- 1869, 73, - 3320)
            CFrameQuest = CFrame.new(- 2443, 73, - 3219)
            VectorQuest = Vector3.new(- 2443, 73, - 3219)
        elseif v288 == 950 or v288 <= 974 then
            LevelFarm = 7
            Name = "Zombie [Lv. 950]"
            QuestName = "ZombieQuest"
            LevelQuest = 1
            NameMon = "Zombie"
            CFrameMon = CFrame.new(- 5736, 126, - 728)
            VectorMon = Vector3.new(- 5736, 126, - 728)
            CFrameQuest = CFrame.new(- 5494, 49, - 795)
            VectorQuest = Vector3.new(- 5494, 49, - 794)
        elseif v288 == 975 or v288 <= 999 then
            LevelFarm = 8
            Name = "Vampire [Lv. 975]"
            QuestName = "ZombieQuest"
            LevelQuest = 2
            NameMon = "Vampire"
            CFrameMon = CFrame.new(- 6033, 7, - 1317)
            VectorMon = Vector3.new(- 6033, 7, - 1317)
            CFrameQuest = CFrame.new(- 5494, 49, - 795)
            VectorQuest = Vector3.new(- 5494, 49, - 795)
        elseif v288 == 1000 or v288 <= 1049 then
            LevelFarm = 9
            Name = "Snow Trooper [Lv. 1000]"
            QuestName = "SnowMountainQuest"
            LevelQuest = 1
            NameMon = "Snow Trooper"
            CFrameMon = CFrame.new(478, 402, - 5362)
            VectorMon = Vector3.new(478, 402, - 5362)
            CFrameQuest = CFrame.new(605, 402, - 5371)
            VectorQuest = Vector3.new(605, 402, - 5371)
        elseif v288 == 1050 or v288 <= 1099 then
            LevelFarm = 10
            Name = "Winter Warrior [Lv. 1050]"
            QuestName = "SnowMountainQuest"
            LevelQuest = 2
            NameMon = "Winter Warrior"
            CFrameMon = CFrame.new(1157, 430, - 5188)
            VectorMon = Vector3.new(1157, 430, - 5188)
            CFrameQuest = CFrame.new(605, 402, - 5371)
            VectorQuest = Vector3.new(605, 402, - 5371)
        elseif v288 == 1100 or v288 <= 1124 then
            LevelFarm = 11
            Name = "Lab Subordinate [Lv. 1100]"
            QuestName = "IceSideQuest"
            LevelQuest = 1
            NameMon = "Lab Subordinate"
            CFrameMon = CFrame.new(- 5782, 42, - 4484)
            VectorMon = Vector3.new(- 5782, 42, - 4484)
            CFrameQuest = CFrame.new(- 6060, 16, - 4905)
            VectorQuest = Vector3.new(- 6060, 16, - 4905)
        elseif v288 == 1125 or v288 <= 1174 then
            LevelFarm = 12
            Name = "Horned Warrior [Lv. 1125]"
            QuestName = "IceSideQuest"
            LevelQuest = 2
            NameMon = "Horned Warrior"
            CFrameMon = CFrame.new(- 6406, 24, - 5805)
            VectorMon = Vector3.new(- 6406, 24, - 5805)
            CFrameQuest = CFrame.new(- 6060, 16, - 4905)
            VectorQuest = Vector3.new(- 6060, 16, - 4905)
        elseif v288 == 1175 or v288 <= 1199 then
            LevelFarm = 13
            Name = "Magma Ninja [Lv. 1175]"
            QuestName = "FireSideQuest"
            LevelQuest = 1
            NameMon = "Magma Ninja"
            CFrameMon = CFrame.new(- 5428, 78, - 5959)
            VectorMon = Vector3.new(- 5428, 78, - 5959)
            CFrameQuest = CFrame.new(- 5430, 16, - 5295)
            VectorQuest = Vector3.new(- 5430, 16, - 5296)
        elseif v288 == 1200 or v288 <= 1249 then
            LevelFarm = 14
            Name = "Lava Pirate [Lv. 1200]"
            QuestName = "FireSideQuest"
            LevelQuest = 2
            NameMon = "Lava Pirate"
            CFrameMon = CFrame.new(- 5270, 42, - 4800)
            VectorMon = Vector3.new(- 5270, 42, - 4800)
            CFrameQuest = CFrame.new(- 5430, 16, - 5295)
            VectorQuest = Vector3.new(- 5430, 16, - 5296)
        elseif v288 == 1250 or v288 <= 1274 then
            LevelFarm = 15
            Name = "Ship Deckhand [Lv. 1250]"
            QuestName = "ShipQuest1"
            LevelQuest = 1
            NameMon = "Ship Deckhand"
            CFrameMon = CFrame.new(1198, 126, 33031)
            VectorMon = Vector3.new(1198, 126, 33031)
            CFrameQuest = CFrame.new(1038, 125, 32913)
            VectorQuest = Vector3.new(1038, 125, 32913)
        elseif v288 == 1275 or v288 <= 1299 then
            LevelFarm = 16
            Name = "Ship Engineer [Lv. 1275]"
            QuestName = "ShipQuest1"
            LevelQuest = 2
            NameMon = "Ship Engineer"
            CFrameMon = CFrame.new(918, 44, 32787)
            VectorMon = Vector3.new(918, 44, 32787)
            CFrameQuest = CFrame.new(1038, 125, 32913)
            VectorQuest = Vector3.new(1038, 125, 32913)
        elseif v288 == 1300 or v288 <= 1324 then
            LevelFarm = 17
            Name = "Ship Steward [Lv. 1300]"
            QuestName = "ShipQuest2"
            LevelQuest = 1
            NameMon = "Ship Steward"
            CFrameMon = CFrame.new(915, 130, 33419)
            VectorMon = Vector3.new(915, 130, 33419)
            CFrameQuest = CFrame.new(969, 125, 33245)
            VectorQuest = Vector3.new(969, 125, 33245)
        elseif v288 == 1325 or v288 <= 1349 then
            LevelFarm = 18
            Name = "Ship Officer [Lv. 1325]"
            QuestName = "ShipQuest2"
            LevelQuest = 2
            NameMon = "Ship Officer"
            CFrameMon = CFrame.new(916, 181, 33335)
            VectorMon = Vector3.new(916, 181, 33335)
            CFrameQuest = CFrame.new(969, 125, 33245)
            VectorQuest = Vector3.new(969, 125, 33245)
        elseif v288 == 1350 or v288 <= 1374 then
            LevelFarm = 19
            Name = "Arctic Warrior [Lv. 1350]"
            QuestName = "FrostQuest"
            LevelQuest = 1
            NameMon = "Arctic Warrior"
            CFrameMon = CFrame.new(6038, 29, - 6231)
            VectorMon = Vector3.new(6038, 29, - 6231)
            VectorQuest = Vector3.new(5669, 28, - 6482)
            CFrameQuest = CFrame.new(5669, 28, - 6482)
        elseif v288 == 1375 or v288 <= 1424 then
            LevelFarm = 20
            Name = "Snow Lurker [Lv. 1375]"
            QuestName = "FrostQuest"
            LevelQuest = 2
            NameMon = "Snow Lurker"
            CFrameMon = CFrame.new(5560, 42, - 6826)
            VectorMon = Vector3.new(5560, 42, - 6826)
            VectorQuest = Vector3.new(5669, 28, - 6482)
            CFrameQuest = CFrame.new(5669, 28, - 6482)
        elseif v288 == 1425 or v288 <= 1449 then
            LevelFarm = 21
            Name = "Sea Soldier [Lv. 1425]"
            QuestName = "ForgottenQuest"
            LevelQuest = 1
            NameMon = "Sea Soldier"
            CFrameMon = CFrame.new(- 3022, 16, - 9722)
            VectorMon = Vector3.new(- 3022, 16, - 9722)
            CFrameQuest = CFrame.new(- 3054, 237, - 10148)
            VectorQuest = Vector3.new(- 3054, 237, - 10148)
        elseif v288 >= 1450 then
            LevelFarm = 22
            Name = "Water Fighter [Lv. 1450]"
            QuestName = "ForgottenQuest"
            LevelQuest = 2
            NameMon = "Water Fighter"
            CFrameMon = CFrame.new(- 3385, 239, - 10542)
            VectorMon = Vector3.new(- 3385, 239, - 10542)
            CFrameQuest = CFrame.new(- 3054, 237, - 10148)
            VectorQuest = Vector3.new(- 3054, 237, - 10148)
        end
    end
    if World3 then
        if v288 == 1500 or v288 <= 1524 then
            LevelFarm = 1
            Name = "Pirate Millionaire [Lv. 1500]"
            QuestName = "PiratePortQuest"
            LevelQuest = 1
            NameMon = "Pirate"
            CFrameMon = CFrame.new(- 373, 75, 5550)
            VectorMon = Vector3.new(- 373, 75, 5550)
            CFrameQuest = CFrame.new(- 288, 44, 5576)
            VectorQuest = Vector3.new(- 288, 44, 5576)
        elseif v288 == 1525 or v288 <= 1574 then
            LevelFarm = 2
            Name = "Pistol Billionaire [Lv. 1525]"
            QuestName = "PiratePortQuest"
            LevelQuest = 2
            NameMon = "Pistol"
            CFrameMon = CFrame.new(- 469, 74, 5904)
            VectorMon = Vector3.new(- 469, 74, 5904)
            CFrameQuest = CFrame.new(- 288, 44, 5576)
            VectorQuest = Vector3.new(- 288, 44, 5576)
        elseif v288 == 1575 or v288 <= 1599 then
            LevelFarm = 3
            Name = "Dragon Crew Warrior [Lv. 1575]"
            QuestName = "AmazonQuest"
            LevelQuest = 1
            NameMon = "Warrior"
            CFrameMon = CFrame.new(6339, 52, - 1213)
            VectorMon = Vector3.new(6338, 52, - 1213)
            CFrameQuest = CFrame.new(5835, 52, - 1105)
            VectorQuest = Vector3.new(5835, 52, - 1105)
        elseif v288 == 1600 or v288 <= 1624 then
            LevelFarm = 4
            Name = "Dragon Crew Archer [Lv. 1600]"
            QuestName = "AmazonQuest"
            LevelQuest = 2
            NameMon = "Archer"
            CFrameMon = CFrame.new(6594, 383, 139)
            VectorMon = Vector3.new(6594, 383, 139)
            CFrameQuest = CFrame.new(5835, 52, - 1105)
            VectorQuest = Vector3.new(5835, 52, - 1105)
        elseif v288 == 1625 or v288 <= 1649 then
            LevelFarm = 5
            Name = "Female Islander [Lv. 1625]"
            QuestName = "AmazonQuest2"
            LevelQuest = 1
            NameMon = "Female"
            CFrameMon = CFrame.new(5308, 819, 1047)
            VectorMon = Vector3.new(5308, 819, 1047)
            CFrameQuest = CFrame.new(5443, 602, 751)
            VectorQuest = Vector3.new(5443, 602, 751)
        elseif v288 == 1650 or v288 <= 1699 then
            LevelFarm = 6
            Name = "Giant Islander [Lv. 1650]"
            QuestName = "AmazonQuest2"
            LevelQuest = 2
            NameMon = "Giant Islanders"
            CFrameMon = CFrame.new(4951, 602, - 68)
            VectorMon = Vector3.new(4951, 602, - 68)
            CFrameQuest = CFrame.new(5443, 602, 751)
            VectorQuest = Vector3.new(5443, 602, 751)
        elseif v288 == 1700 or v288 <= 1724 then
            LevelFarm = 7
            Name = "Marine Commodore [Lv. 1700]"
            QuestName = "MarineTreeIsland"
            LevelQuest = 1
            NameMon = "Marine Commodore"
            CFrameMon = CFrame.new(2447, 73, - 7470)
            VectorMon = Vector3.new(2447, 73, - 7470)
            CFrameQuest = CFrame.new(2180, 29, - 6737)
            VectorQuest = Vector3.new(2180, 29, - 6737)
        elseif v288 == 1725 or v288 <= 1774 then
            LevelFarm = 8
            Name = "Marine Rear Admiral [Lv. 1725]"
            QuestName = "MarineTreeIsland"
            LevelQuest = 2
            NameMon = "Marine Rear Admiral"
            CFrameMon = CFrame.new(3671, 161, - 6932)
            VectorMon = Vector3.new(3671, 161, - 6932)
            CFrameQuest = CFrame.new(2180, 29, - 6737)
            VectorQuest = Vector3.new(2180, 29, - 6737)
        elseif v288 == 1775 or v288 <= 1800 then
            LevelFarm = 9
            Name = "Fishman Raider [Lv. 1775]"
            QuestName = "DeepForestIsland3"
            LevelQuest = 1
            NameMon = "Fishman Raider"
            CFrameMon = CFrame.new(- 10560, 332, - 8466)
            VectorMon = Vector3.new(- 10560, 332, - 8466)
            CFrameQuest = CFrame.new(- 10584, 332, - 8758)
            VectorQuest = Vector3.new(- 10584, 332, - 8758)
        elseif v288 == 1800 or v288 <= 1824 then
            LevelFarm = 10
            Name = "Fishman Captain [Lv. 1800]"
            QuestName = "DeepForestIsland3"
            LevelQuest = 2
            NameMon = "Fishman Captain"
            CFrameMon = CFrame.new(- 10993, 332, - 8940)
            VectorMon = Vector3.new(- 10993, 332, - 8940)
            CFrameQuest = CFrame.new(- 10584, 332, - 8758)
            VectorQuest = Vector3.new(- 10584, 332, - 8758)
        elseif v288 == 1825 or v288 <= 1849 then
            LevelFarm = 11
            Name = "Forest Pirate [Lv. 1825]"
            QuestName = "DeepForestIsland"
            LevelQuest = 1
            NameMon = "Forest Pirate"
            CFrameMon = CFrame.new(- 13479, 333, - 7905)
            VectorMon = Vector3.new(- 13479, 333, - 7905)
            CFrameQuest = CFrame.new(- 13232, 333, - 7627)
            VectorQuest = Vector3.new(- 13232, 333, - 7627)
        elseif v288 == 1850 or v288 <= 1899 then
            LevelFarm = 12
            Name = "Mythological Pirate [Lv. 1850]"
            QuestName = "DeepForestIsland"
            LevelQuest = 2
            NameMon = "Mythological Pirate"
            CFrameMon = CFrame.new(- 13545, 470, - 6917)
            VectorMon = Vector3.new(- 13545, 470, - 6917)
            CFrameQuest = CFrame.new(- 13232, 333, - 7627)
            VectorQuest = Vector3.new(- 13232, 333, - 7627)
        elseif v288 == 1900 or v288 <= 1924 then
            LevelFarm = 13
            Name = "Jungle Pirate [Lv. 1900]"
            QuestName = "DeepForestIsland2"
            LevelQuest = 1
            NameMon = "Jungle Pirate"
            CFrameMon = CFrame.new(- 12107, 332, - 10549)
            VectorMon = Vector3.new(- 12106, 332, - 10549)
            CFrameQuest = CFrame.new(- 12684, 391, - 9902)
            VectorQuest = Vector3.new(- 12684, 391, - 9902)
        elseif v288 == 1925 or v288 <= 1974 then
            LevelFarm = 14
            Name = "Musketeer Pirate [Lv. 1925]"
            QuestName = "DeepForestIsland2"
            LevelQuest = 2
            NameMon = "Musketeer Pirate"
            CFrameMon = CFrame.new(- 13286, 392, - 9769)
            VectorMon = Vector3.new(- 13286, 392, - 9768)
            CFrameQuest = CFrame.new(- 12684, 391, - 9902)
            VectorQuest = Vector3.new(- 12684, 391, - 9902)
        elseif v288 == 1975 or v288 <= 1999 then
            LevelFarm = 15
            Name = "Reborn Skeleton [Lv. 1975]"
            QuestName = "HauntedQuest1"
            LevelQuest = 1
            NameMon = "Reborn Skeleton"
            CFrameMon = CFrame.new(- 8760, 142, 6039)
            VectorMon = Vector3.new(- 8760, 142, 6039)
            CFrameQuest = CFrame.new(- 9482, 142, 5567)
            VectorQuest = Vector3.new(- 9482, 142, 5567)
        elseif v288 == 2000 or v288 <= 2024 then
            LevelFarm = 16
            Name = "Living Zombie [Lv. 2000]"
            QuestName = "HauntedQuest1"
            LevelQuest = 2
            NameMon = "Living Zombie"
            CFrameMon = CFrame.new(- 10144, 140, 5932)
            VectorMon = Vector3.new(- 10144, 140, 5932)
            CFrameQuest = CFrame.new(- 9482, 142, 5567)
            VectorQuest = Vector3.new(- 9482, 142, 5567)
        elseif v288 == 2025 or v288 <= 2049 then
            LevelFarm = 17
            Name = "Demonic Soul [Lv. 2025]"
            QuestName = "HauntedQuest2"
            LevelQuest = 1
            NameMon = "Demonic Soul"
            CFrameMon = CFrame.new(- 9507, 172, 6158)
            VectorMon = Vector3.new(- 9506, 172, 6158)
            CFrameQuest = CFrame.new(- 9513, 172, 6079)
            VectorQuest = Vector3.new(- 9513, 172, 6079)
        elseif v288 == 2050 or v288 <= 2074 then
            LevelFarm = 18
            Name = "Posessed Mummy [Lv. 2050]"
            QuestName = "HauntedQuest2"
            LevelQuest = 2
            NameMon = "Posessed Mummy"
            CFrameMon = CFrame.new(- 9577, 6, 6223)
            VectorMon = Vector3.new(- 9577, 6, 6223)
            CFrameQuest = CFrame.new(- 9513, 172, 6079)
            VectorQuest = Vector3.new(- 9513, 172, 6079)
        elseif v288 == 2075 or v288 <= 2099 then
            LevelFarm = 19
            Name = "Peanut Scout [Lv. 2075]"
            QuestName = "NutsIslandQuest"
            LevelQuest = 1
            NameMon = "Peanut Scout"
            CFrameMon = CFrame.new(- 2124, 123, - 10435)
            VectorMon = Vector3.new(- 2124, 123, - 10435)
            CFrameQuest = CFrame.new(- 2104, 38, - 10192)
            VectorQuest = Vector3.new(- 2104, 38, - 10192)
        elseif v288 == 2100 or v288 <= 2124 then
            LevelFarm = 20
            Name = "Peanut President [Lv. 2100]"
            QuestName = "NutsIslandQuest"
            LevelQuest = 2
            NameMon = "Peanut President"
            CFrameMon = CFrame.new(- 2124, 123, - 10435)
            VectorMon = Vector3.new(- 2124, 123, - 10435)
            CFrameQuest = CFrame.new(- 2104, 38, - 10192)
            VectorQuest = Vector3.new(- 2104, 38, - 10192)
        elseif v288 == 2125 or v288 <= 2149 then
            LevelFarm = 21
            Name = "Ice Cream Chef [Lv. 2125]"
            QuestName = "IceCreamIslandQuest"
            LevelQuest = 1
            NameMon = "Ice Cream Chef"
            CFrameMon = CFrame.new(- 641, 127, - 11062)
            VectorMon = Vector3.new(- 641, 127, - 11062)
            CFrameQuest = CFrame.new(- 822, 66, - 10965)
            VectorQuest = Vector3.new(- 822, 66, - 10965)
        elseif v288 == 2150 or v288 <= 2199 then
            LevelFarm = 22
            Name = "Ice Cream Commander [Lv. 2150]"
            QuestName = "IceCreamIslandQuest"
            LevelQuest = 2
            NameMon = "Ice Cream Commander"
            CFrameMon = CFrame.new(- 641, 127, - 11062)
            VectorMon = Vector3.new(- 641, 127, - 11062)
            CFrameQuest = CFrame.new(- 822, 66, - 10965)
            VectorQuest = Vector3.new(- 822, 66, - 10965)
        elseif v288 == 2200 or v288 <= 2224 then
            LevelFarm = 23
            Name = "Cookie Crafter [Lv. 2200]"
            QuestName = "CakeQuest1"
            LevelQuest = 1
            NameMon = "Cookie Crafter"
            CFrameMon = CFrame.new(- 2365, 38, - 12099)
            VectorMon = Vector3.new(- 2365, 38, - 12099)
            CFrameQuest = CFrame.new(- 2020, 38, - 12025)
            VectorQuest = Vector3.new(- 2020, 38, - 12025)
        elseif v288 == 2225 or v288 <= 2249 then
            LevelFarm = 24
            Name = "Cake Guard [Lv. 2225]"
            QuestName = "CakeQuest1"
            LevelQuest = 2
            NameMon = "Cake Guard"
            CFrameMon = CFrame.new(- 1651, 38, - 12308)
            VectorMon = Vector3.new(- 1651, 38, - 12308)
            CFrameQuest = CFrame.new(- 2020, 38, - 12025)
            VectorQuest = Vector3.new(- 2020, 38, - 12025)
        elseif v288 == 2250 or v288 <= 2274 then
            LevelFarm = 25
            Name = "Baking Staff [Lv. 2250]"
            QuestName = "CakeQuest2"
            LevelQuest = 1
            NameMon = "Baking Staff"
            CFrameMon = CFrame.new(- 1870, 38, - 12938)
            VectorMon = Vector3.new(- 1870, 38, - 12938)
            CFrameQuest = CFrame.new(- 1926, 38, - 12850)
            VectorQuest = Vector3.new(- 1926, 38, - 12850)
        elseif v288 == 2275 or v288 <= 2299 then
            LevelFarm = 26
            Name = "Head Baker [Lv. 2275]"
            QuestName = "CakeQuest2"
            LevelQuest = 2
            NameMon = "Head Baker"
            CFrameMon = CFrame.new(- 1926, 88, - 12850)
            VectorMon = CFrame.new(- 1870, 38, - 12938)
            CFrameQuest = CFrame.new(- 1926, 38, - 12850)
            VectorQuest = Vector3.new(- 1926, 38, - 12850)
        elseif v288 == 2300 or v288 <= 2324 then
            LevelFarm = 27
            Name = "Cocoa Warrior [Lv. 2300]"
            QuestName = "ChocQuest1"
            LevelQuest = 1
            NameMon = "Cocoa Warrior"
            CFrameMon = CFrame.new(231, 23, - 12194)
            VectorMon = CFrame.new(231, 23, - 12194)
            CFrameQuest = CFrame.new(231, 23, - 12194)
            VectorQuest = Vector3.new(231, 23, - 12194)
        elseif v288 == 2325 or v288 <= 2349 then
            LevelFarm = 28
            Name = "Chocolate Bar Battler [Lv. 2325]"
            QuestName = "ChocQuest1"
            LevelQuest = 2
            NameMon = "Chocolate Bar Battler"
            CFrameMon = CFrame.new(231, 23, - 12194)
            VectorMon = CFrame.new(231, 23, - 12194)
            CFrameQuest = CFrame.new(231, 23, - 12194)
            VectorQuest = Vector3.new(231, 23, - 12194)
        elseif v288 == 2350 or v288 <= 2374 then
            LevelFarm = 29
            Name = "Sweet Thief [Lv. 2350]"
            QuestName = "ChocQuest2"
            LevelQuest = 1
            NameMon = "Sweet Thief"
            CFrameMon = CFrame.new(71, 77, - 12632)
            VectorMon = CFrame.new(71, 77, - 12632)
            CFrameQuest = CFrame.new(151, 23, - 12774)
            VectorQuest = Vector3.new(151, 23, - 12774)
        elseif v288 == 2375 or v288 <= 2399 then
            LevelFarm = 30
            Name = "Candy Rebel [Lv. 2375]"
            QuestName = "ChocQuest2"
            LevelQuest = 2
            NameMon = "Candy Rebel"
            CFrameMon = CFrame.new(134, 77, - 12882)
            VectorMon = CFrame.new(134, 77, - 12882)
            CFrameQuest = CFrame.new(151, 23, - 12774)
            VectorQuest = Vector3.new(151, 23, - 12774)
        elseif v288 == 2400 or v288 <= 2424 then
            LevelFarm = 31
            Name = "Candy Pirate [Lv. 2400]"
            QuestName = "CandyQuest1"
            LevelQuest = 1
            NameMon = "Candy Pirate"
            CFrameMon = CFrame.new(- 1423.4515380859375, 116.5498275756836, - 14603.890625)
            VectorMon = CFrame.new(- 1423.4515380859375, 116.5498275756836, - 14603.890625)
            CFrameQuest = CFrame.new(- 1147.584716796875, 16.232574462890625, - 14445.6279296875)
            VectorQuest = Vector3.new(- 1147.584716796875, 16.232574462890625, - 14445.6279296875)
        elseif v288 >= 2425 then
            LevelFarm = 32
            Name = "Snow Demon [Lv. 2425]"
            QuestName = "CandyQuest1"
            LevelQuest = 2
            NameMon = "Snow Demon"
            CFrameMon = CFrame.new(- 941.1054077148438, 56.978214263916016, - 14539.7060546875)
            VectorMon = CFrame.new(- 941.1054077148438, 56.978214263916016, - 14539.7060546875)
            CFrameQuest = CFrame.new(- 1147.584716796875, 16.232574462890625, - 14445.6279296875)
            VectorQuest = Vector3.new(- 1147.584716796875, 16.232574462890625, - 14445.6279296875)
        end
    end
end


-- after CheckQuest runs, sync globals -> CurrentQuest for hub loops
local _CheckQuest_orig = CheckQuest
function CheckQuest()
    _CheckQuest_orig()
    CurrentQuest.Mon = Name
    CurrentQuest.NameMon = NameMon
    CurrentQuest.NameQuest = QuestName
    CurrentQuest.LevelQuest = LevelQuest or 1
    CurrentQuest.CFrameQuest = CFrameQuest
    CurrentQuest.CFrameMon = CFrameMon
end


local function GetQuestMonsters(nameFilter, maxDist)
    maxDist = maxDist or 2000
    local list = {}
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return list end
    for _, mob in ipairs(enemies:GetChildren()) do
        local hum = mob:FindFirstChild("Humanoid")
        local hrp = mob:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 then
            local match = true
            if nameFilter and nameFilter ~= "" then
                match = mob.Name:find(nameFilter) ~= nil or (mob:GetAttribute("OriginalName") == nameFilter)
            end
            if match then
                local d = (HumanoidRootPart.Position - hrp.Position).Magnitude
                if d <= maxDist then
                    table.insert(list, mob)
                end
            end
        end
    end
    table.sort(list, function(a, b)
        return (a.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
             < (b.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
    end)
    return list
end

local function BringMobsToPlayer(mobs)
    if not HumanoidRootPart then return end
    for _, mob in ipairs(mobs) do
        pcall(function()
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                hrp.CanCollide = false
                hrp.Size = Vector3.new(2, 2, 2)
                if mob:FindFirstChild("Humanoid") then
                    mob.Humanoid.WalkSpeed = 0
                    mob.Humanoid.JumpPower = 0
                end
            end
        end)
    end
end


-- === EXACT AttackNoCD from Axion reference (Zaque) — ported + wired ===
local vu130 = LocalPlayer
local vu131 = nil
local vu132 = nil
pcall(function()
    local cf = require(LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
    vu131 = debug.getupvalues(cf)
    vu132 = vu131 and vu131[2] or nil
end)

-- maxincrement hook for hit validation (from reference)
pcall(function()
    local function maxincrement()
        if vu132 and vu132.activeController and vu132.activeController.anims and vu132.activeController.anims.basic then
            return #vu132.activeController.anims.basic
        end
        return 4
    end
    local old
    old = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if method and method:lower() == "fireserver" and args[1] == "hit" then
            args[3] = maxincrement()
            return old(self, unpack(args))
        end
        return old(self, ...)
    end)
end)

function GetCurrentBlade()
    local ok, blade = pcall(function()
        if not vu132 then
            local cf = require(LocalPlayer.PlayerScripts.CombatFramework)
            vu131 = debug.getupvalues(cf)
            vu132 = vu131 and vu131[2]
        end
        if not vu132 or not vu132.activeController then return nil end
        local v138 = vu132.activeController.blades[1]
        if v138 then
            while v138.Parent and v138.Parent ~= Character do
                v138 = v138.Parent
            end
            return v138
        end
        return nil
    end)
    return ok and blade or nil
end

-- EXACT AttackNoCD from reference (p139 == 1 = full validator path, p139 == 0 = click path)
function AttackNoCD(p139)
    p139 = p139 or 1
    pcall(function()
        if not Character or not HumanoidRootPart then return end
        if not vu132 then
            local cf = require(LocalPlayer.PlayerScripts.CombatFramework)
            vu131 = debug.getupvalues(cf)
            vu132 = vu131 and vu131[2]
        end
        if not vu132 or not vu132.activeController then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(1300, 760), workspace.CurrentCamera.CFrame)
            return
        end

        if p139 == 1 then
            local vu140 = vu132.activeController
            local v141 = require(game.ReplicatedStorage.CombatFramework.RigLib).getBladeHits(Character, {
                HumanoidRootPart
            }, 60)
            local vu146 = {}
            local v145 = {}
            for _, v148 in pairs(v141 or {}) do
                if v148 and v148.Parent and v148.Parent:FindFirstChild("HumanoidRootPart") and not v145[v148.Parent] then
                    table.insert(vu146, v148.Parent.HumanoidRootPart)
                    v145[v148.Parent] = true
                end
            end
            if #vu146 > 0 then
                local vu149 = debug.getupvalue(vu140.attack, 5)
                local vu150 = debug.getupvalue(vu140.attack, 6)
                local vu151 = debug.getupvalue(vu140.attack, 4)
                local v152 = debug.getupvalue(vu140.attack, 7)
                if vu149 and vu150 and vu151 and v152 then
                    local vu153 = (vu149 * 798405 + vu151 * 727595) % vu150
                    local vu154 = vu151 * 798405
                    vu153 = (vu153 * vu150 + vu154) % 1099511627776
                    vu149 = math.floor(vu153 / vu150)
                    vu151 = vu153 - vu149 * vu150
                    local vu155 = v152 + 1
                    debug.setupvalue(vu140.attack, 5, vu149)
                    debug.setupvalue(vu140.attack, 6, vu150)
                    debug.setupvalue(vu140.attack, 4, vu151)
                    debug.setupvalue(vu140.attack, 7, vu155)
                    pcall(function()
                        if Character:FindFirstChildOfClass("Tool") and vu140.blades and vu140.blades[1] then
                            if vu140.animator and vu140.animator.anims and vu140.animator.anims.basic and vu140.animator.anims.basic[1] then
                                vu140.animator.anims.basic[1]:Play(0.01, 0.01, 0.01)
                            end
                            local blade = GetCurrentBlade()
                            if blade then
                                ReplicatedStorage.RigControllerEvent:FireServer("weaponChange", tostring(blade))
                            end
                            pcall(function()
                                game.ReplicatedStorage.Remotes.Validator:FireServer(math.floor(vu153 / 1099511627776 * 16777215), vu155)
                            end)
                            ReplicatedStorage.RigControllerEvent:FireServer("hit", vu146, 2, "")
                        end
                    end)
                else
                    -- fallback if upvalues missing
                    pcall(function()
                        if vu140.animator and vu140.animator.anims and vu140.animator.anims.basic and vu140.animator.anims.basic[1] then
                            vu140.animator.anims.basic[1]:Play(0.01, 0.01, 0.01)
                        end
                        ReplicatedStorage.RigControllerEvent:FireServer("hit", vu146, 2, "")
                    end)
                end
            end
        elseif p139 == 0 then
            local vu156 = vu132.activeController
            local v157 = require(game.ReplicatedStorage.CombatFramework.RigLib).getBladeHits(Character, {
                HumanoidRootPart
            }, 60)
            local v162 = {}
            local v161 = {}
            for _, v164 in pairs(v157 or {}) do
                if v164 and v164.Parent and v164.Parent:FindFirstChild("HumanoidRootPart") and not v161[v164.Parent] then
                    table.insert(v162, v164.Parent.HumanoidRootPart)
                    v161[v164.Parent] = true
                end
            end
            if #v162 > 0 then
                if Character:FindFirstChild("Black Leg") and Character:FindFirstChild("Black Leg"):FindFirstChild("Level") and Character["Black Leg"].Level.Value >= 150 then
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, "V", false, game)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, "V", false, game)
                end
                pcall(function()
                    if Character:FindFirstChildOfClass("Tool") and vu156.blades and vu156.blades[1] then
                        for idx, vu168 in pairs(vu131 or {}) do
                            pcall(function()
                                if idx == 2 and vu168 and vu168.activeController then
                                    local v169 = vu132.activeController
                                    pcall(function()
                                        require(game.ReplicatedStorage.Util.CameraShaker):Stop()
                                    end)
                                    vu168.activeController.attacking = false
                                    vu168.activeController.blocking = false
                                    vu168.activeController.focusStart = 1655503339.0980349
                                    vu168.activeController.increment = 4
                                    vu168.activeController.hitboxMagnitude = 55
                                    vu168.activeController.timeToNextBlock = tick()
                                    vu168.activeController.timeToNextAttack = tick()
                                    VirtualUser:CaptureController()
                                    VirtualUser:ClickButton1(Vector2.new(1300, 760), workspace.CurrentCamera.CFrame)
                                    if v169 and v169.animator and v169.animator.anims and v169.animator.anims.basic and v169.animator.anims.basic[1] then
                                        v169.animator.anims.basic[1]:Play(0.01, 0.01, 0.01)
                                    end
                                end
                            end)
                        end
                    end
                end)
            end
        end
    end)
end

-- wrapAttackAnimationAsync override (exact from reference)
pcall(function()
    local vu170 = require(LocalPlayer.PlayerScripts.CombatFramework.Particle)
    local vu171 = require(ReplicatedStorage.CombatFramework.RigLib)
    if not shared.orl then
        shared.orl = vu171.wrapAttackAnimationAsync
    end
    if not shared.cpc then
        shared.cpc = vu170.play
    end
    game:GetService("RunService").Stepped:Connect(function()
        pcall(function()
            function vu171.wrapAttackAnimationAsync(p172, p173, p174, p175, p176)
                local v177 = vu171.getBladeHits(p173, p174, p175)
                if v177 then
                    function vu170.play()
                    end
                    p172:Play(0.01, 0.01, 0.01)
                    p176(v177)
                    vu170.play = shared.cpc
                    task.wait(p172.length * 0.5)
                    p172:Stop()
                end
            end
        end)
    end)
end)

local AttackNoCD_Ref = AttackNoCD

local function AttackTarget(mob)
    pcall(function()
        -- use full validator path (1) like reference Fast Attack
        AttackNoCD(1)
        if mob and mob:FindFirstChild("HumanoidRootPart") then
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes then
                local hit = remotes:FindFirstChild("RegisterHit") or remotes:FindFirstChild("RE/RegisterHit")
                if hit and hit:IsA("RemoteEvent") then
                    hit:FireServer(mob.HumanoidRootPart, {})
                end
                local atk = remotes:FindFirstChild("RegisterAttack") or remotes:FindFirstChild("RE/RegisterAttack")
                if atk and atk:IsA("RemoteEvent") then
                    atk:FireServer(0.5)
                end
            end
        end
    end)
end


-- Skill spam (Z/X/C/V) while farming for faster clear
function SpamSkills()
    if not (GetFlag("SkillSpam") or GetFlag("FastFarm")) then return end
    pcall(function()
        local vim = game:GetService("VirtualInputManager")
        for _, key in ipairs({"Z", "X", "C", "V"}) do
            if GetFlag("Skill" .. key) ~= false then
                vim:SendKeyEvent(true, key, false, game)
                task.wait(0.015)
                vim:SendKeyEvent(false, key, false, game)
            end
        end
    end)
end

-- Com helper from reference (no key)

local function HasActiveQuest()
    local ok, vis = pcall(function()
        local q = LocalPlayer.PlayerGui:FindFirstChild("Main")
        q = q and q:FindFirstChild("Quest")
        return q and q.Visible
    end)
    return ok and vis or false
end

local function StartQuestRemote(questName, levelQuest)
    if not questName then return end
    levelQuest = levelQuest or 1
    pcall(function()
        local r = ReplicatedStorage:FindFirstChild("Remotes")
        r = r and r:FindFirstChild("CommF_")
        if r then
            r:InvokeServer("StartQuest", questName, levelQuest)
            pcall(function() r:InvokeServer("SetSpawnPoint") end)
        end
    end)
    pcall(function()
        FireComm("StartQuest", questName, levelQuest)
    end)
end

local function Com(suffix, ...)
    pcall(function()
        local r = ReplicatedStorage.Remotes:FindFirstChild("Comm" .. suffix)
        if not r then return end
        if r:IsA("RemoteEvent") then r:FireServer(...)
        elseif r:IsA("RemoteFunction") then r:InvokeServer(...) end
    end)
end

local function DoQuestFarmStep()
    CheckQuest()
    if not QuestName or not CFrameQuest then
        return
    end
    -- equip
    pcall(function()
        if not Character:FindFirstChildOfClass("Tool") then
            for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if t:IsA("Tool") and (t.ToolTip == "Sword" or t.ToolTip == "Melee" or t.ToolTip == "Blox Fruit") then
                    Humanoid:EquipTool(t)
                    break
                end
            end
            if not Character:FindFirstChildOfClass("Tool") then
                local any = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if any then Humanoid:EquipTool(any) end
            end
        end
    end)
    -- auto buso
    pcall(function()
        if (GetFlag("AutoBuso") or GetFlag("AutoHaki")) and not Character:FindFirstChild("HasBuso") then
            Com("F_", "Buso")
        end
    end)

    local questGui = LocalPlayer.PlayerGui:FindFirstChild("Main")
        and LocalPlayer.PlayerGui.Main:FindFirstChild("Quest")
    local questVisible = questGui and questGui.Visible

    -- accept quest (reference style + requestEntrance)
    if not questVisible then
        StartMagnet = false
        local distToQuest = (HumanoidRootPart.Position - CFrameQuest.Position).Magnitude
        if World1 and Name and (Name == "Fishman Commando [Lv. 400]" or Name == "Fishman Warrior [Lv. 375]") and distToQuest > 50000 then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(3864.8515625, 6.6796875, -1926.7841796875))
            end)
            task.wait(0.2)
        elseif World2 and Name and string.find(Name, "Ship") and distToQuest > 30000 then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
            end)
            task.wait(0.2)
        elseif World2 and distToQuest > 30000 then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(-6508.5581054688, 89.034996032715, -132.83953857422))
            end)
            task.wait(0.2)
        end
        if distToQuest > 12 then
            TweenTo(CFrameQuest, GetFlag("FastFarm") and 480 or 380)
        else
            HumanoidRootPart.CFrame = CFrameQuest
            task.wait(0.12)
            Com("F_", "StartQuest", QuestName, LevelQuest)
            Com("F_", "SetSpawnPoint")
            task.wait(0.2)
        end
        return
    end

    -- find exact Name mob
    local target = nil
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies and Name then
        for _, mob in ipairs(enemies:GetChildren()) do
            if mob.Name == Name then
                local hrp, hum = mob:FindFirstChild("HumanoidRootPart"), mob:FindFirstChild("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    target = mob
                    break
                end
            end
        end
    end
    if not target then
        StartMagnet = false
        if CFrameMon then TweenTo(CFrameMon, GetFlag("FastFarm") and 480 or 380) end
        task.wait(0.12)
        return
    end

    local hrp = target.HumanoidRootPart
    local farmDist = GetFlag("DistanceAutoFarm") or (GetFlag("FastFarm") and 8 or 10)
    local above = BananaFarmCF(hrp, farmDist) or (hrp.CFrame * CFrame.new(0, farmDist, 0))
    local dist = (HumanoidRootPart.Position - hrp.Position).Magnitude
    if dist > 35 then
        TweenTo(above, GetFlag("FastFarm") and 500 or 420)
    else
        pcall(function() HumanoidRootPart.CFrame = above end)
    end
    if GetFlag("BringEnemy") then
        StartMagnet = true
        PosMon = above
        SetMagnetPoint(above)
        pcall(function()
            hrp.Size = Vector3.new(60, 60, 60)
            hrp.Transparency = 1
            hrp.CanCollide = false
            target.Humanoid.JumpPower = 0
            target.Humanoid.WalkSpeed = 0
            if target.Humanoid:FindFirstChild("Animator") then
                pcall(function() target.Humanoid.Animator:Destroy() end)
            end
            target.Humanoid:ChangeState(11)
            target.Humanoid:ChangeState(14)
        end)
        -- pull nearby same-name pack hard
        pcall(function()
            local enemies = workspace:FindFirstChild("Enemies")
            if not enemies then return end
            for _, m in ipairs(enemies:GetChildren()) do
                if m ~= target and m.Name == Name then
                    local mh = m:FindFirstChild("HumanoidRootPart")
                    local hu = m:FindFirstChild("Humanoid")
                    if mh and hu and hu.Health > 0 and (mh.Position - HumanoidRootPart.Position).Magnitude <= 350 then
                        mh.CFrame = above
                        mh.Size = Vector3.new(60, 60, 60)
                        mh.Transparency = 1
                        mh.CanCollide = false
                        hu.WalkSpeed = 0
                        hu.JumpPower = 0
                    end
                end
            end
        end)
    else
        StartMagnet = false
        StopMagnet()
    end
    -- double hit per step for speed
    AttackTarget(target)
    AttackNoCD(1)
    if GetFlag("FastFarm") or GetFlag("DoubleAttack") then
        AttackNoCD(1)
    end
    pcall(SpamSkills)
end



-------------------------------------------------
-- FEATURE RUNNERS (wired from reference patterns)
-------------------------------------------------

local function FindMobByName(name, maxDist)
    maxDist = maxDist or 4000
    if not HumanoidRootPart or not name then return nil end
    local best, bestD = nil, maxDist
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    local myPos = HumanoidRootPart.Position
    local children = enemies:GetChildren()
    for i = 1, #children do
        local mob = children[i]
        if mob.Name == name or mob.Name:find(name, 1, true) then
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            local hum = mob:FindFirstChild("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local d = (myPos - hrp.Position).Magnitude
                if d < bestD then
                    best, bestD = mob, d
                    if d < 15 then return best end
                end
            end
        end
    end
    return best
end

local function FarmNamedMob(name, bring)
    local mob = FindMobByName(name)
    if not mob then return false end
    local hrp = mob:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local above = BananaFarmCF(hrp, GetFlag("DistanceAutoFarm") or 8) or (hrp.CFrame * CFrame.new(0, 10, 0))
    local dist = (HumanoidRootPart.Position - hrp.Position).Magnitude
    if dist > 35 then
        TweenTo(above, GetFlag("FastFarm") and 500 or 420)
    else
        pcall(function() HumanoidRootPart.CFrame = above end)
    end
    if bring and GetFlag("BringEnemy") then
        StartMagnet = true
        PosMon = above
        SetMagnetPoint(above)
        BringEnemy(mob)
    end
    AttackTarget(mob)
    AttackNoCD(1)
    if GetFlag("FastFarm") then AttackNoCD(1) end
    pcall(SpamSkills)
    return true
end

local function CollectItemsByName(substr)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find(substr:lower()) then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChild("Handle") or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
            if part and part:IsA("BasePart") then
                local d = (HumanoidRootPart.Position - part.Position).Magnitude
                if d < 4000 then
                    TweenTo(part.CFrame, 450)
                    task.wait(0.25)
                    return true
                end
            end
        end
    end
    return false
end

local function RunBossSelectLoop()
    local name = GetFlag("SelectedBoss")
    if not name or name == "" then return end
    local mob = FindMobByName(name, 8000)
    if mob then
        TweenTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0), 350)
        if GetFlag("BringEnemy") then
            SetMagnetPoint(HumanoidRootPart.CFrame * CFrame.new(0, 0, -5))
            BringEnemy(mob)
        end
        AttackTarget(mob)
    end
end

local function RunAllBossesLoop()
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return end
    for _, mob in ipairs(enemies:GetChildren()) do
        if mob.Name:find("Boss") or table.find({"Cake Prince","Dough King","Darkbeard","Soul Reaper","rip_indra","Ice Admiral","Magma Admiral","Smoke Admiral","Thunder God","Tide Keeper","Cursed Captain","Don Swan","Diamond","Longma","Stone","Greybeard","Yeti","Saber Expert"}, mob.Name) then
            local hum = mob:FindFirstChild("Humanoid")
            local hrp = mob:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                TweenTo(hrp.CFrame * CFrame.new(0, 15, 0), 350)
                if GetFlag("BringEnemy") then BringEnemy(mob) end
                AttackTarget(mob)
                return
            end
        end
    end
end

local function RunMasteryLoop(mode)
    -- mode: sword / fruit / gun — farm nearest + attack, stop if mastery lock hit (best-effort)
    local lock = GetFlag("MasteryLock") or 600
    local mob = GetNearestEnemy(2000)
    if not mob then return end
    if mode == "sword" then
        -- equip sword
        for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if t:IsA("Tool") and t.ToolTip == "Sword" then Humanoid:EquipTool(t) break end
        end
    elseif mode == "gun" then
        for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if t:IsA("Tool") and t.ToolTip == "Gun" then Humanoid:EquipTool(t) break end
        end
    elseif mode == "fruit" then
        for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if t:IsA("Tool") and t.ToolTip == "Blox Fruit" then Humanoid:EquipTool(t) break end
        end
    end
    TweenTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0), 400)
    if GetFlag("BringEnemy") then
        SetMagnetPoint(HumanoidRootPart.CFrame * CFrame.new(0, 0, -5))
        BringEnemy(mob)
    end
    AttackTarget(mob)
end

local function RunObservationFarm()
    -- dodge-style: stay near mobs without attacking much
    local mob = GetNearestEnemy(80)
    if mob then
        TweenTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, 8, 15), 300)
    end
end

local function RunBoneFarm()
    -- bone drops from haunted / skeleton style
    if not FarmNamedMob("Skeleton", true) and not FarmNamedMob("Zombie", true) and not FarmNamedMob("Reborn", true) then
        CollectItemsByName("bone")
    end
end

local function RunEctoplasmFarm()
    FarmNamedMob("Ship", true)
    CollectItemsByName("Ectoplasm")
end

local function RunChestFarm()
    if not HumanoidRootPart then return end
    local myPos = HumanoidRootPart.Position
    local best, bestD = nil, 3500
    for _, obj in ipairs(workspace:GetChildren()) do
        local n = obj.Name:lower()
        if n:find("chest") then
            local part = obj:IsA("BasePart") and obj or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
            if part then
                local d = (myPos - part.Position).Magnitude
                if d < bestD then best, bestD = part, d end
            end
        end
    end
    if best then
        if bestD > 15 then
            TweenTo(best.CFrame + Vector3.new(0, 3, 0), GetFlag("FastFarm") and 500 or 400)
        else
            pcall(function() HumanoidRootPart.CFrame = best.CFrame + Vector3.new(0, 3, 0) end)
        end
    end
end

local function RunFruitCollect()
    CollectItemsByName("Fruit")
end

local function TryBuyFightingStyle(remoteName)
    pcall(function()
        FireComm(remoteName)
    end)
end

local function RunHakiAuto()
    if GetFlag("AutoBuso") then
        pcall(function() FireComm("Buso") end)
    end
end

-- generic loop spawner

local function SpawnFlagLoop(flagName, fn, interval)
    interval = interval or 0.2
    task.spawn(function()
        while true do
            if GetFlag(flagName) then
                local ok, err = pcall(fn)
                local waitTime = interval
                if GetFlag("FastFarm") then
                    waitTime = math.max(0.04, interval * 0.6)
                end
                task.wait(waitTime)
            else
                task.wait(0.5) -- cooler when off
            end
        end
    end)
end

-- wire continuous runners for major features
SpawnFlagLoop("AutoKillBoss", RunBossSelectLoop, 0.12)
SpawnFlagLoop("AutoAllBoss", RunAllBossesLoop, 0.15)
SpawnFlagLoop("AutoMasterySword", function() RunMasteryLoop("sword") end, 0.1)
SpawnFlagLoop("AutoMasteryFruit", function() RunMasteryLoop("fruit") end, 0.1)
SpawnFlagLoop("AutoMasteryGun", function() RunMasteryLoop("gun") end, 0.1)
SpawnFlagLoop("AutoFarmObservation", RunObservationFarm, 0.15)
SpawnFlagLoop("AutoBones", RunBoneFarm, 0.1)
SpawnFlagLoop("AutoFarmEctoplasm", RunEctoplasmFarm, 0.1)
SpawnFlagLoop("AutoFarmChest", RunChestFarm, 0.5)
SpawnFlagLoop("AutoCollectFruit", RunFruitCollect, 0.6)
SpawnFlagLoop("AutoCakePrince", function() FarmNamedMob("Cake Prince", true) end, 0.12)
SpawnFlagLoop("AutoDarkbeard", function() FarmNamedMob("Darkbeard", true) end, 0.12)
SpawnFlagLoop("AutoSoulReaper", function() FarmNamedMob("Soul Reaper", true) end, 0.12)
SpawnFlagLoop("AutoDonSwan", function() FarmNamedMob("Don Swan", true) or FarmNamedMob("Swan", true) end, 0.12)
SpawnFlagLoop("AutoBuso", RunHakiAuto, 1.0)

-- material-ish farms
SpawnFlagLoop("AutoFarmMaterial", function()
    FarmNamedMob("Pirate", true)
    CollectItemsByName("Magnet")
end, 0.35)

-- sea events best-effort
SpawnFlagLoop("AutoTerrorShark", function() FarmNamedMob("Terror", true) or FarmNamedMob("Shark", true) end, 0.15)
SpawnFlagLoop("AutoSeaBeast", function() FarmNamedMob("Sea Beast", true) or FarmNamedMob("SeaBeast", true) end, 0.15)
SpawnFlagLoop("AutoLeviathan", function() FarmNamedMob("Leviathan", true) end, 0.15)
SpawnFlagLoop("AutoShark", function() FarmNamedMob("Shark", true) end, 0.15)
SpawnFlagLoop("AutoPiranha", function() FarmNamedMob("Piranha", true) end, 0.15)

-- elite hunter: kill elite + notify
SpawnFlagLoop("EliteHunter", function()
    local mob = FindMobByName("Elite", 6000)
    if mob then
        Notify("Elite", mob.Name)
        TweenTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0), 350)
        if GetFlag("BringEnemy") then BringEnemy(mob) end
        AttackTarget(mob)
    end
end, 0.4)

-- store fruit best-effort
SpawnFlagLoop("AutoStoreFruit", function()
    pcall(function()
        for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if t:IsA("Tool") and t.Name:find("Fruit") then
                FireComm("StoreFruit", t.Name)
            end
        end
        for _, t in ipairs(Character:GetChildren()) do
            if t:IsA("Tool") and t.Name:find("Fruit") then
                FireComm("StoreFruit", t.Name)
            end
        end
    end)
end, 2)

-- random fruit buy
SpawnFlagLoop("AutoRandomFruit", function()
    pcall(function() FireComm("Cousin", "Buy") end)
end, 5)

-- fighting style purchase loops (one-shot style when toggled)
SpawnFlagLoop("AutoSuperhuman", function() TryBuyFightingStyle("BuySuperhuman") end, 3)
SpawnFlagLoop("AutoGodhuman", function() TryBuyFightingStyle("BuyGodhuman") end, 3)
SpawnFlagLoop("AutoDeathStep", function() TryBuyFightingStyle("BuyDeathStep") end, 3)
SpawnFlagLoop("AutoSharkman", function() TryBuyFightingStyle("BuySharkmanKarate") end, 3)
SpawnFlagLoop("AutoElectricClaw", function() TryBuyFightingStyle("BuyElectricClaw") end, 3)
SpawnFlagLoop("AutoDragonClaw", function() TryBuyFightingStyle("BuyDragonTalon") end, 3)
SpawnFlagLoop("AutoSanguine", function() TryBuyFightingStyle("BuySanguineArt") end, 3)

-- saber / rengoku / pole best-effort named farms
SpawnFlagLoop("AutoSaber", function() FarmNamedMob("Saber Expert", true) end, 0.12)
SpawnFlagLoop("AutoRengoku", function() FarmNamedMob("Rengoku", true) or CollectItemsByName("Rengoku") end, 0.4)
SpawnFlagLoop("AutoPole", function() FarmNamedMob("Thunder God", true) or CollectItemsByName("Pole") end, 0.4)

-- raids: try start via remote
SpawnFlagLoop("AutoStartRaid", function()
    pcall(function() FireComm("RaidsNpc", "Ready") end)
    pcall(function() FireComm("StartRaid") end)
end, 3)

SpawnFlagLoop("AutoCompleteRaid", function()
    local mob = GetNearestEnemy(300)
    if mob then
        TweenTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0), 400)
        if GetFlag("BringEnemy") then BringEnemy(mob) end
        AttackTarget(mob)
    end
end, 0.2)

-- bartilo / citizen / elite quests: try start + farm related mobs
SpawnFlagLoop("AutoBartilo", function()
    pcall(function() FireComm("StartQuest", "BartiloQuest", 1) end)
    FarmNamedMob("Swan Pirate", true)
end, 0.5)

SpawnFlagLoop("AutoCitizen", function()
    pcall(function() FireComm("StartQuest", "CitizenQuest", 1) end)
end, 2)

SpawnFlagLoop("AutoEliteQuest", function()
    pcall(function() FireComm("EliteHunter") end)
    local mob = FindMobByName("Elite", 6000)
    if mob then
        TweenTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, 12, 0), 350)
        AttackTarget(mob)
    end
end, 0.5)

-- CDK / Yama / Tushita placeholders: farm related content
SpawnFlagLoop("AutoCDK", function()
    FarmNamedMob("Elite", true)
end, 0.4)
SpawnFlagLoop("AutoTushita", function()
    FarmNamedMob("Tushita", true) or FarmNamedMob("Longma", true)
end, 0.4)
SpawnFlagLoop("AutoYama", function()
    FarmNamedMob("Yama", true) or FarmNamedMob("Reaper", true)
end, 0.4)

-- mirage / kitsune / prehistoric search: scan workspace names
local function ScanIsland(keyword, flag)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find(keyword:lower()) and obj:IsA("BasePart") then
            Notify(flag, "Found " .. obj.Name)
            TweenTo(obj.CFrame, 400)
            return true
        end
    end
    return false
end

SpawnFlagLoop("AutoFindMirage", function() ScanIsland("Mirage", "Mirage") end, 3)
SpawnFlagLoop("AutoFindKitsune", function() ScanIsland("Kitsune", "Kitsune") end, 3)
SpawnFlagLoop("AutoFindPrehistoric", function() ScanIsland("Prehistoric", "Prehistoric") end, 3)

-- fishing best-effort
SpawnFlagLoop("AutoFishing", function()
    pcall(function()
        EquipTool(GetFlag("SelectRod") or "Fishing Rod")
        FireComm("StartCasting")
        local remote = ReplicatedStorage:FindFirstChild("FishingRemote") or ReplicatedStorage:FindFirstChild("FishingClient")
        if remote then
            if remote:IsA("RemoteEvent") then remote:FireServer() end
        end
    end)
end, 2)

-- walk water already exists
-- server hop already exists

-- Fast attack continuous when flag
SpawnFlagLoop("AttackNoCD", function()
    -- skip if parallel farm attack loop already owns combat
    if GetFlag("AutoFarmLevel") then return end
    local mob = GetNearestEnemy(50)
    if mob then AttackTarget(mob) end
    AttackNoCD(1)
end, 0.05)

-- Mob aura from reference concept
SpawnFlagLoop("MobAura", function()
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return end
    local range = GetFlag("MobAuraDistance") or 1000
    for _, mob in ipairs(enemies:GetChildren()) do
        local hrp = mob:FindFirstChild("HumanoidRootPart")
        local hum = mob:FindFirstChild("Humanoid")
        if hrp and hum and hum.Health > 0 then
            if (hrp.Position - HumanoidRootPart.Position).Magnitude <= range then
                AttackTarget(mob)
            end
        end
    end
end, 0.15)


SpawnFlagLoop("AutoDropFruit", function()
    pcall(function()
        for _, t in ipairs(Character:GetChildren()) do
            if t:IsA("Tool") and t.Name:find("Fruit") then
                t.Parent = workspace
            end
        end
    end)
end, 2)

SpawnFlagLoop("AutoTweenFruit", function()
    CollectItemsByName("Fruit")
end, 1.5)

SpawnFlagLoop("AutoGun", function()
    for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == "Gun" then Humanoid:EquipTool(t) break end
    end
    local mob = GetNearestEnemy(200)
    if mob then AttackTarget(mob) end
end, 0.25)

SpawnFlagLoop("AutoMelee", function()
    for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == "Melee" then Humanoid:EquipTool(t) break end
    end
    local mob = GetNearestEnemy(80)
    if mob then
        if GetFlag("BringEnemy") then BringEnemy(mob) end
        AttackTarget(mob)
    end
end, 0.2)

SpawnFlagLoop("AutoKen", function()
    pcall(function() FireComm("Ken") end)
    pcall(function() FireComm("KenTalk") end)
end, 2)

SpawnFlagLoop("AutoRaceV3", function()
    pcall(function() FireComm("ActivateAbility") end)
end, 2)

SpawnFlagLoop("AutoRaceV4", function()
    pcall(function() FireComm("ActivateAbility") end)
end, 2)

SpawnFlagLoop("AutoNextIsland", function()
    -- sequential island hop best-effort by level bands handled in CheckQuest farm
    CheckQuest()
    if CurrentQuest.CFrameMon then TweenTo(CurrentQuest.CFrameMon, 350) end
end, 5)

SpawnFlagLoop("AutoCraftVolcanic", function()
    pcall(function() FireComm("Craft", "Volcanic Magnet") end)
    pcall(function() FireComm("CraftItem", "Volcanic Magnet") end)
end, 4)

SpawnFlagLoop("AutoCollectMirageChest", function()
    CollectItemsByName("Chest")
end, 2)

SpawnFlagLoop("AutoFactoryRaid", function()
    FarmNamedMob("Factory", true)
end, 0.3)

SpawnFlagLoop("AutoPirateRaid", function()
    FarmNamedMob("Pirate", true)
end, 0.3)

SpawnFlagLoop("AutoFarmRaid", function()
    local mob = GetNearestEnemy(250)
    if mob then
        TweenTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, 10, 0), 400)
        if GetFlag("BringEnemy") then BringEnemy(mob) end
        AttackTarget(mob)
    end
end, 0.2)


-- === EXTRA / HARDENED RUNNERS (full coverage, safe pcall) ===
SpawnFlagLoop("AutoFarmLevel", function()
    DoQuestFarmStep()
end, 0.08)

SpawnFlagLoop("AutoFarmNearest", function()
    local mob = GetNearestEnemy(GetFlag("MobAuraDistance") or 500)
    if not mob then return end
    local hrp = mob:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if (HumanoidRootPart.Position - hrp.Position).Magnitude > 30 then
        TweenTo(hrp.CFrame * CFrame.new(0, 8, 3), 400)
    end
    if GetFlag("BringEnemy") then
        StartMagnet = true
        PosMon = hrp.CFrame
        SetMagnetPoint(hrp.CFrame)
        BringEnemy(mob)
    end
    AttackTarget(mob)
    AttackNoCD(1)
end, 0.06)

-- Legendary sword dealer (Sea 2)
SpawnFlagLoop("AutoBuyLegendarySword", function()
    pcall(function()
        FireComm("LegendarySwordDealer", "1")
        FireComm("LegendarySwordDealer", "2")
        FireComm("LegendarySwordDealer", "3")
    end)
end, 5)

-- Haki color / enchant
SpawnFlagLoop("AutoBuyEnchanmentHaki", function()
    pcall(function()
        FireComm("ColorsDealer", "2")
        FireComm("BuyHaki", "Buso")
    end)
end, 8)

-- Random bone
SpawnFlagLoop("AutoRandomBone", function()
    pcall(function() FireComm("Bones", "Buy", 1, 1) end)
end, 2)

-- Auto stats (Melee priority)
SpawnFlagLoop("AutoStats", function()
    pcall(function()
        local stats = LocalPlayer.Data.Stats
        local melee = stats.Melee.Level.Value
        local pts = GetFlag("StatPointSelect") or 3
        if melee < 2400 then
            FireComm("AddPoint", "Melee", pts)
        else
            FireComm("AddPoint", "Defense", pts)
        end
    end)
end, 1)

-- Inf energy
SpawnFlagLoop("InfEnergy", function()
    pcall(function()
        if Character and Character:FindFirstChild("Energy") then
            Character.Energy.Value = Character.Energy.MaxValue
        end
    end)
end, 0.3)

-- Walk on water
SpawnFlagLoop("WalkOnWater", function()
    pcall(function()
        local t = workspace.Terrain
        t.WaterWaveSize = 0
        t.WaterWaveSpeed = 0
        t.WaterReflectance = 0
        t.WaterTransparency = 1
    end)
end, 2)

-- Full bright
SpawnFlagLoop("FullBright", function()
    pcall(function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 9e9
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end)
end, 2)


-- Banana-style parallel loops (Bring / Attack / Skill independent)
task.spawn(function()
    local acc = 0
    while true do
        local dt = RunService.Heartbeat:Wait()
        if not (GetFlag("AutoFarmLevel") or GetFlag("BringEnemy")) then
            task.wait(0.4)
        else
            acc = acc + dt
            if acc >= 0.06 then
                acc = 0
                pcall(function()
                    if not (StartMagnet and PosMon and HumanoidRootPart) then return end
                    local enemies = workspace:FindFirstChild("Enemies")
                    if not enemies then return end
                    local myPos = HumanoidRootPart.Position
                    local targetCF = PosMon
                    local kids = enemies:GetChildren()
                    for i = 1, #kids do
                        local mob = kids[i]
                        local hrp = mob:FindFirstChild("HumanoidRootPart")
                        local hum = mob:FindFirstChild("Humanoid")
                        if hrp and hum and hum.Health > 0 then
                            local n = mob.Name
                            if not n:find("Boss") and (hrp.Position - myPos).Magnitude <= 350 then
                                hrp.CFrame = targetCF
                                hrp.CanCollide = false
                                hrp.Size = Vector3.new(60, 60, 60)
                                hrp.Transparency = 1
                                hum.WalkSpeed = 0
                                hum.JumpPower = 0
                            end
                        end
                    end
                end)
            end
        end
    end
end)

task.spawn(function()
    local acc = 0
    local hb = RunService.Heartbeat
    while true do
        local dt = hb:Wait()
        local on = GetFlag("AttackNoCD") or GetFlag("AutoFarmLevel")
        if not on then
            task.wait(0.3)
        else
            acc = acc + dt
            local need = GetFlag("FastFarm") and 0.04 or 0.06
            if acc >= need then
                acc = 0
                pcall(function()
                    local mob = GetNearestEnemy(55)
                    if mob then AttackTarget(mob) end
                    AttackNoCD(1)
                end)
            end
        end
    end
end)

task.spawn(function()
    while true do
        if GetFlag("SkillSpam") or GetFlag("FastFarm") then
            pcall(SpamSkills)
            task.wait(0.35)
        else
            task.wait(0.5)
        end
    end
end)

-- Stack soft: chest + store when farm idle (no quest mob nearby)
task.spawn(function()
    while true do
        task.wait(2)
        if GetFlag("AutoFarmLevel") then
            pcall(function()
                -- soft chest if no nearby enemies
                local near = GetNearestEnemy(120)
                if not near then
                    if RunChestFarm then RunChestFarm() end
                end
            end)
            pcall(function()
                if GetFlag("AutoStoreFruit") or GetFlag("AutoFarmLevel") then
                    -- try store any fruit tool
                    for _, t in ipairs(LocalPlayer.Backpack:GetChildren()) do
                        if t:IsA("Tool") and (t:GetAttribute("Fruit") or t.Name:find("Fruit") or t.ToolTip == "Blox Fruit") then
                            FireComm("StoreFruit", t.Name)
                        end
                    end
                end
            end)
        end
    end
end)


print("[BFHub] Extra runners loaded")

SetFlag("FastFarm", true)
SetFlag("SkillSpam", true)
SetFlag("BringEnemy", true)
SetFlag("AttackNoCD", true)
SetFlag("DoubleAttack", true)
SetFlag("AutoBuso", true)
SetFlag("TweenSpeed", 350)
SetFlag("DistanceAutoFarm", 8)
print("[BFHub] Feature runners loaded")
print("[BFHub] Core combat ready — bật Auto Farm Level khi muốn farm")


-- AUTO FARM
-------------------------------------------------


Tabs.Main:AddSection("Status")
local StatusPara = Tabs.Main:AddParagraph({
    Title = "Farm Status",
    Content = "Level: - | Quest: - | Mob: - | "
})
task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            local lv = "?"
            pcall(function() lv = tostring(LocalPlayer.Data.Level.Value) end)
            local q = QuestName or CurrentQuest and CurrentQuest.NameQuest or "-"
            local m = Name or CurrentQuest and CurrentQuest.Mon or "-"
            SetParagraph(StatusPara, string.format("Level: %s | Quest: %s | Mob: %s", lv, tostring(q), tostring(m)))
        end)
    end
end)

local FarmSection = Tabs.Farm:AddSection("Auto Farm")

Tabs.Farm:AddToggle("AutoFarmLevel", {
    Title = "Auto Farm Level (Quest + Bring)",
    Default = false,
    Callback = function(v)
        SetFlag("AutoFarmLevel", v)
        if v then
            Notify("Farm", "Quest farm started — accept + bring mobs")
            task.spawn(function()
                while GetFlag("AutoFarmLevel") do
                    pcall(DoQuestFarmStep)
                    task.wait(GetFlag("FastFarm") and 0.06 or 0.1)
                end
            end)
        end
    end
})

Tabs.Farm:AddToggle("AutoFarmNearest", {
    Title = "Auto Farm Nearest",
    Default = false,
    Callback = function(v)
        SetFlag("AutoFarmNearest", v)
        if v then
            task.spawn(function()
                while GetFlag("AutoFarmNearest") do
                    local mob = GetNearestEnemy(GetFlag("MobAuraDistance") or 800)
                    if mob and mob:FindFirstChild("HumanoidRootPart") then
                        local hrp = mob.HumanoidRootPart
                        if (HumanoidRootPart.Position - hrp.Position).Magnitude > 25 then
                            TweenTo(hrp.CFrame * CFrame.new(0, 8, 3), GetFlag("FastFarm") and 500 or 420)
                        else
                            pcall(function() HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 8, 0) end)
                        end
                        if GetFlag("BringEnemy") then
                            StartMagnet = true
                            PosMon = hrp.CFrame
                            BringEnemy(mob)
                        end
                        AttackNearest()
                        AttackNoCD(1)
                    end
                    task.wait(GetFlag("FastFarm") and 0.04 or 0.06)
                end
            end)
        end
    end
})

Tabs.Farm:AddToggle("AutoFarmChest", {
    Title = "Auto Collect Chest",
    Default = false,
    Callback = function(v)
        SetFlag("AutoFarmChest", v)
        if v then
            task.spawn(function()
                while GetFlag("AutoFarmChest") do
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if (obj:IsA("Model") or obj:IsA("BasePart")) and obj.Name:lower():find("chest") then
                            local pos = obj:IsA("Model") and (obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetPivot().Position) or obj.Position
                            if (HumanoidRootPart.Position - pos).Magnitude < 3000 then
                                TweenTo(CFrame.new(pos + Vector3.new(0, 3, 0)), 400)
                                task.wait(0.3)
                            end
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end
})

Tabs.Farm:AddToggle("AutoBones", {
    Title = "Auto Bones",
    Default = false,
    Callback = function(v) SetFlag("AutoBones", v) end
})

Tabs.Farm:AddToggle("AutoFarmEctoplasm", {
    Title = "Auto Farm Ectoplasm",
    Default = false,
    Callback = function(v) SetFlag("AutoFarmEctoplasm", v) end
})

Tabs.Farm:AddToggle("AutoFarmObservation", {
    Title = "Auto Farm Observation",
    Default = false,
    Callback = function(v) SetFlag("AutoFarmObservation", v) end
})

Tabs.Farm:AddToggle("AutoFarmRaid", {
    Title = "Auto Farm Raid",
    Default = false,
    Callback = function(v) SetFlag("AutoFarmRaid", v) end
})

Tabs.Farm:AddToggle("SkillSpam", {
    Title = "Skill Spam (Z/X/C/V)",
    Default = true,
    Callback = function(v) SetFlag("SkillSpam", v) end
})
Tabs.Farm:AddToggle("FastFarm", {
    Title = "Fast Farm (speed boost)",
    Default = true,
    Callback = function(v) SetFlag("FastFarm", v) end
})
Tabs.Farm:AddToggle("BypassTP", {
    Title = "Bypass TP (long distance)",
    Default = false,
    Callback = function(v) SetFlag("BypassTP", v) end
})
Tabs.Farm:AddSlider("TweenSpeed", {
    Title = "Tween Speed",
    Default = 350,
    Min = 150,
    Max = 600,
    Rounding = 0,
    Callback = function(v) SetFlag("TweenSpeed", v) end
})
Tabs.Farm:AddSlider("DistanceAutoFarm", {
    Title = "Farm Height Distance",
    Default = 15,
    Min = 5,
    Max = 40,
    Rounding = 0,
    Callback = function(v) SetFlag("DistanceAutoFarm", v) end
})
Tabs.Farm:AddToggle("BringEnemy", {
    Title = "Bring Enemy",
    Default = true,
    Callback = function(v) SetFlag("BringEnemy", v) end
})

Tabs.Farm:AddToggle("MobAura", {
    Title = "Mob Aura",
    Default = false,
    Callback = function(v) SetFlag("MobAura", v) end
})

Tabs.Farm:AddSlider("MobAuraDistance", {
    Title = "Distance Mob Aura",
    Default = 1000,
    Min = 50,
    Max = 2000,
    Rounding = 0,
    Callback = function(v) SetFlag("MobAuraDistance", v) end
})

Tabs.Bosses:AddToggle("AutoAllBoss", {
    Title = "Auto All Boss",
    Default = false,
    Callback = function(v) SetFlag("AutoAllBoss", v) end
})

Tabs.Farm:AddToggle("DoubleAttack", {
    Title = "Double Attack (Fruit + Melee M1)",
    Default = false,
    Callback = function(v)
        SetFlag("DoubleAttack", v)
        if v then
            task.spawn(function()
                while GetFlag("DoubleAttack") do
                    -- alternate fruit M1 and melee
                    VirtualUser:ClickButton1(Vector2.new())
                    task.wait(0.12)
                end
            end)
        end
    end
})

Tabs.Farm:AddToggle("AutoFarmMaterial", {
    Title = "Auto Farm Material + Volcanic Magnet",
    Default = false,
    Callback = function(v)
        SetFlag("AutoFarmMaterial", v)
        if v then
            Notify("Material Farm", "Farming materials & crafting Volcanic Magnet")
        end
    end
})

-------------------------------------------------
-- MASTERY
-------------------------------------------------
Tabs.Mastery:AddToggle("AutoMasterySword", {
    Title = "Auto Mastery All Sword",
    Default = false,
    Callback = function(v) SetFlag("AutoMasterySword", v) end
})

Tabs.Mastery:AddToggle("AutoMasteryFruit", {
    Title = "Auto Mastery Fruits",
    Default = false,
    Callback = function(v) SetFlag("AutoMasteryFruit", v) end
})

Tabs.Mastery:AddToggle("AutoMasteryGun", {
    Title = "Auto Mastery Gun",
    Default = false,
    Callback = function(v) SetFlag("AutoMasteryGun", v) end
})

Tabs.Mastery:AddToggle("NPCAimbotMastery", {
    Title = "NPC Aimbot (Mastery)",
    Default = false,
    Callback = function(v) SetFlag("NPCAimbotMastery", v) end
})

Tabs.Mastery:AddSlider("MasteryLock", {
    Title = "Sword Mastery Level Lock",
    Default = 600,
    Min = 0,
    Max = 600,
    Rounding = 0,
    Callback = function(v) SetFlag("MasteryLock", v) end
})

-------------------------------------------------
-- BOSSES
-------------------------------------------------
local BossList = {
    "Cake Prince", "Dough King", "Darkbeard", "Soul Reaper", "Rip_Indra",
    "Ice Admiral", "Awakened Ice Admiral", "Magma Admiral", "Smoke Admiral",
    "Thunder God", "Tide Keeper", "Cursed Captain", "Don Swan", "Diamond",
    "Jeremy", "Fajita", "Captain Elephant", "Beautiful Pirate", "Longma",
    "Stone", "Island Empress", "Kilo Admiral", "Warden", "Chief Warden",
    "Swan", "Greybeard", "The Gorilla King", "Bobby", "Yeti", "Saber Expert",
    "Forest Pirate", "Cake Queen", "Head Baker", "Baking Staff", "Cookie Crafter",
    "Cake Guard", "Chocolate Bar Battler", "Sweet Thief", "Candy Rebel",
    "Peanut Scout", "Ice Cream Chef", "Ice Cream Commander", "Cocoa Warrior",
    "Living Zombie", "Reborn Skeleton", "Demonic Soul", "Posessed Mummy",
    "Ghost", "Mythological Pirate", "Fishman Lord", "Fishman Captain",
    "Arctic Warrior", "Snow Lurker", "Elite Hunter", "Hydra Leader",
    "Dragon Crew Warrior", "Dragon Crew Archer", "Venomous Assailant",
    "Marine Captain", "Marine Rear Admiral", "Vice Admiral", "Mob Leader",
    "Galley Captain", "Pirate Millionaire", "Pistol Billionaire", "The Saw",
    "The Sentinel", "Heaven's Guardian", "Hell's Messenger", "Order"
}

Tabs.Bosses:AddDropdown("SelectedBoss", {
    Title = "Select Boss",
    Values = BossList,
    Multi = false,
    Default = 1,
    Callback = function(v) SetFlag("SelectedBoss", v) end
})

Tabs.Bosses:AddToggle("AutoKillBoss", {
    Title = "Auto Kill Selected Boss",
    Default = false,
    Callback = function(v)
        SetFlag("AutoKillBoss", v)
        if v then
            task.spawn(function()
                while GetFlag("AutoKillBoss") do
                    local targetName = GetFlag("SelectedBoss")
                    local enemies = workspace:FindFirstChild("Enemies")
                    if enemies then
                        local boss = enemies:FindFirstChild(targetName)
                        if boss and boss:FindFirstChild("HumanoidRootPart") and boss.Humanoid.Health > 0 then
                            TweenTo(boss.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0), 350)
                            if GetFlag("BringEnemy") then BringEnemy(boss) end
                            AttackNearest()
                        end
                    end
                    task.wait(0.2)
                end
            end)
        end
    end
})

Tabs.Bosses:AddToggle("AutoCakePrince", {
    Title = "Auto Cake Prince",
    Default = false,
    Callback = function(v) SetFlag("AutoCakePrince", v) end
})

Tabs.Bosses:AddToggle("AutoDarkbeard", {
    Title = "Auto Darkbeard",
    Default = false,
    Callback = function(v) SetFlag("AutoDarkbeard", v) end
})

Tabs.Bosses:AddToggle("AutoSoulReaper", {
    Title = "Auto Soul Reaper [Fully]",
    Default = false,
    Callback = function(v) SetFlag("AutoSoulReaper", v) end
})

Tabs.Bosses:AddToggle("AutoDonSwan", {
    Title = "Auto Unlocked DonSwan",
    Default = false,
    Callback = function(v) SetFlag("AutoDonSwan", v) end
})

Tabs.Bosses:AddToggle("BossNotify", {
    Title = "Boss Spawn Notification",
    Default = true,
    Callback = function(v)
        SetFlag("BossNotify", v)
        if v then
            Connect("BossSpawn", workspace.ChildAdded, function(child)
                if table.find(BossList, child.Name) then
                    Notify("Boss Spawned!", child.Name .. " is in the server!", 6)
                end
            end)
        else
            Disconnect("BossSpawn")
        end
    end
})

Tabs.Bosses:AddToggle("EliteHunter", {
    Title = "Elite Hunter Status",
    Default = false,
    Callback = function(v) SetFlag("EliteHunter", v) end
})

-------------------------------------------------
-- RAIDS / DUNGEONS
-------------------------------------------------
Tabs.Raids:AddToggle("AutoStartRaid", {
    Title = "Auto Start Raid",
    Default = false,
    Callback = function(v) SetFlag("AutoStartRaid", v) end
})

Tabs.Raids:AddToggle("AutoCompleteRaid", {
    Title = "Auto Complete Raid [Safety]",
    Default = false,
    Callback = function(v) SetFlag("AutoCompleteRaid", v) end
})

Tabs.Raids:AddToggle("AutoFactoryRaid", {
    Title = "Auto Factory Raid",
    Default = false,
    Callback = function(v) SetFlag("AutoFactoryRaid", v) end
})

Tabs.Raids:AddToggle("AutoPirateRaid", {
    Title = "Auto Pirate Raid",
    Default = false,
    Callback = function(v) SetFlag("AutoPirateRaid", v) end
})

Tabs.Raids:AddToggle("AutoSelectChip", {
    Title = "Auto Select Dungeon Chip",
    Default = false,
    Callback = function(v) SetFlag("AutoSelectChip", v) end
})

Tabs.Raids:AddToggle("BuyChipBeli", {
    Title = "Buy Dungeon Chips [Beli]",
    Default = false,
    Callback = function(v) SetFlag("BuyChipBeli", v) end
})

Tabs.Raids:AddToggle("BuyChipFruit", {
    Title = "Buy Dungeon Chips [Devil Fruit]",
    Default = false,
    Callback = function(v) SetFlag("BuyChipFruit", v) end
})

Tabs.Raids:AddToggle("AutoUnlockDough", {
    Title = "Auto Unlock Dough Dungeon",
    Default = false,
    Callback = function(v) SetFlag("AutoUnlockDough", v) end
})

Tabs.Raids:AddToggle("AutoUnlockPhoenix", {
    Title = "Auto Unlock Phoenix Dungeon",
    Default = false,
    Callback = function(v) SetFlag("AutoUnlockPhoenix", v) end
})

Tabs.Raids:AddToggle("StartLawRaid", {
    Title = "Start Law Raids",
    Default = false,
    Callback = function(v) SetFlag("StartLawRaid", v) end
})

-------------------------------------------------
-- QUESTS / TRIALS / CDK
-------------------------------------------------
Tabs.Quests:AddToggle("AutoAcceptQuest", {
    Title = "Accept Quests (by level)",
    Default = false,
    Callback = function(v)
        SetFlag("AutoAcceptQuest", v)
        if v then
            task.spawn(function()
                while GetFlag("AutoAcceptQuest") do
                    CheckQuest()
                    if CurrentQuest.NameQuest and not HasActiveQuest() then
                        if CurrentQuest.CFrameQuest then
                            TweenTo(CurrentQuest.CFrameQuest, 350)
                        end
                        StartQuestRemote(CurrentQuest.NameQuest, CurrentQuest.LevelQuest)
                    end
                    task.wait(1.2)
                end
            end)
        end
    end
})

Tabs.Quests:AddToggle("AutoBartilo", {
    Title = "Auto Done Bartilo Quest",
    Default = false,
    Callback = function(v) SetFlag("AutoBartilo", v) end
})

Tabs.Quests:AddToggle("AutoCitizen", {
    Title = "Auto Done Citizen Quest",
    Default = false,
    Callback = function(v) SetFlag("AutoCitizen", v) end
})

Tabs.Quests:AddToggle("AutoEliteQuest", {
    Title = "Auto Elite Quest",
    Default = false,
    Callback = function(v) SetFlag("AutoEliteQuest", v) end
})

Tabs.Quests:AddToggle("AutoCDK", {
    Title = "Auto Get CDK [Last Quest]",
    Default = false,
    Callback = function(v) SetFlag("AutoCDK", v) end
})

Tabs.Quests:AddToggle("AutoTushita", {
    Title = "Auto Tushita CDK / Sword",
    Default = false,
    Callback = function(v) SetFlag("AutoTushita", v) end
})

Tabs.Quests:AddToggle("AutoYama", {
    Title = "Auto Yama CDK / Sword",
    Default = false,
    Callback = function(v) SetFlag("AutoYama", v) end
})

Tabs.Quests:AddToggle("AutoZou", {
    Title = "Auto Zou Quest",
    Default = false,
    Callback = function(v) SetFlag("AutoZou", v) end
})

Tabs.Quests:AddToggle("AutoDragoV1", {
    Title = "Auto Drago (V1)",
    Default = false,
    Callback = function(v) SetFlag("AutoDragoV1", v) end
})

Tabs.Quests:AddToggle("AutoDragoV2", {
    Title = "Auto Drago (V2)",
    Default = false,
    Callback = function(v) SetFlag("AutoDragoV2", v) end
})

Tabs.Quests:AddToggle("AutoDragoV3", {
    Title = "Auto Drago (V3)",
    Default = false,
    Callback = function(v) SetFlag("AutoDragoV3", v) end
})

Tabs.Quests:AddToggle("AutoTrainDragoV4", {
    Title = "Auto Train Drago v4",
    Default = false,
    Callback = function(v) SetFlag("AutoTrainDragoV4", v) end
})

Tabs.Quests:AddToggle("AutoDragonTalon", {
    Title = "Auto DragonTalon",
    Default = false,
    Callback = function(v) SetFlag("AutoDragonTalon", v) end
})

Tabs.Quests:AddToggle("AutoDragonHunter", {
    Title = "Auto Dragon Hunter",
    Default = false,
    Callback = function(v) SetFlag("AutoDragonHunter", v) end
})

Tabs.Quests:AddToggle("AutoCollectDragonEggs", {
    Title = "Auto Collect Dragon Eggs",
    Default = false,
    Callback = function(v) SetFlag("AutoCollectDragonEggs", v) end
})

Tabs.Quests:AddToggle("AutoCompleteTrial", {
    Title = "Auto Complete Trial Race",
    Default = false,
    Callback = function(v) SetFlag("AutoCompleteTrial", v) end
})

Tabs.Quests:AddToggle("AutoRainbowHaki", {
    Title = "Auto Rainbow Colors / Haki",
    Default = false,
    Callback = function(v) SetFlag("AutoRainbowHaki", v) end
})

Tabs.Quests:AddToggle("AutoDojo", {
    Title = "Auto Dojo Trainer / Belt",
    Default = false,
    Callback = function(v) SetFlag("AutoDojo", v) end
})

Tabs.Quests:AddToggle("KillAfterTrial", {
    Title = "Auto Kill Player After Trial",
    Default = false,
    Callback = function(v) SetFlag("KillAfterTrial", v) end
})

-------------------------------------------------
-- SEA EVENTS
-------------------------------------------------
Tabs.Sea:AddToggle("AutoFindMirage", {
    Title = "Auto Find Mirage Island",
    Default = false,
    Callback = function(v)
        SetFlag("AutoFindMirage", v)
        if v then Notify("Mirage", "Searching for Mirage Island...") end
    end
})

Tabs.Sea:AddToggle("AutoFindKitsune", {
    Title = "Auto Find Kitsune Island",
    Default = false,
    Callback = function(v)
        SetFlag("AutoFindKitsune", v)
        if v then Notify("Kitsune", "Searching for Kitsune Island...") end
    end
})

Tabs.Sea:AddToggle("AutoFindPrehistoric", {
    Title = "Auto Find Prehistoric Island",
    Default = false,
    Callback = function(v)
        SetFlag("AutoFindPrehistoric", v)
        if v then Notify("Prehistoric", "Searching for Prehistoric Island...") end
    end
})

Tabs.Sea:AddToggle("AutoLeviathan", {
    Title = "Auto Attack Leviathan",
    Default = false,
    Callback = function(v) SetFlag("AutoLeviathan", v) end
})

Tabs.Sea:AddToggle("AutoSeaBeast", {
    Title = "Auto Attack Sea Beast",
    Default = false,
    Callback = function(v) SetFlag("AutoSeaBeast", v) end
})

Tabs.Sea:AddToggle("AutoTerrorShark", {
    Title = "Auto Terror Shark",
    Default = false,
    Callback = function(v) SetFlag("AutoTerrorShark", v) end
})

Tabs.Sea:AddToggle("AutoShark", {
    Title = "Auto Shark",
    Default = false,
    Callback = function(v) SetFlag("AutoShark", v) end
})

Tabs.Sea:AddToggle("AutoPiranha", {
    Title = "Auto Piranha",
    Default = false,
    Callback = function(v) SetFlag("AutoPiranha", v) end
})

Tabs.Sea:AddToggle("AutoPirateGrandBrigade", {
    Title = "Auto Attack Pirate Grand Brigade",
    Default = false,
    Callback = function(v) SetFlag("AutoPirateGrandBrigade", v) end
})

Tabs.Sea:AddToggle("AutoCollectMirageChest", {
    Title = "Auto Collect Mirage Chest",
    Default = false,
    Callback = function(v) SetFlag("AutoCollectMirageChest", v) end
})

Tabs.Sea:AddToggle("IslandNotify", {
    Title = "Notify Mirage / Kitsune / Prehistoric Spawn",
    Default = true,
    Callback = function(v) SetFlag("IslandNotify", v) end
})

Tabs.Sea:AddToggle("OpenLeviathanGate", {
    Title = "Open Leviathan Gate / Frozen Dimension",
    Default = false,
    Callback = function(v) SetFlag("OpenLeviathanGate", v) end
})

Tabs.Sea:AddToggle("CraftLeviathan", {
    Title = "Craft Leviathan Boat / Crown / Shield",
    Default = false,
    Callback = function(v) SetFlag("CraftLeviathan", v) end
})

-------------------------------------------------
-- FRUITS
-------------------------------------------------
Tabs.Fruits:AddToggle("AutoCollectFruit", {
    Title = "Auto Collect Fruit",
    Default = false,
    Callback = function(v)
        SetFlag("AutoCollectFruit", v)
        if v then
            task.spawn(function()
                while GetFlag("AutoCollectFruit") do
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if obj.Name:find("Fruit") and obj:IsA("Tool") or (obj:IsA("Model") and obj:FindFirstChild("Handle")) then
                            local handle = obj:FindFirstChild("Handle") or obj
                            if handle and handle:IsA("BasePart") then
                                TweenTo(handle.CFrame, 450)
                                task.wait(0.4)
                            end
                        end
                    end
                    task.wait(1.5)
                end
            end)
        end
    end
})

Tabs.Fruits:AddToggle("AutoStoreFruit", {
    Title = "Auto Store Fruit",
    Default = false,
    Callback = function(v) SetFlag("AutoStoreFruit", v) end
})

Tabs.Fruits:AddToggle("AutoDropFruit", {
    Title = "Auto Drop Fruit",
    Default = false,
    Callback = function(v) SetFlag("AutoDropFruit", v) end
})

Tabs.Fruits:AddToggle("AutoRandomFruit", {
    Title = "Auto Random Fruit",
    Default = false,
    Callback = function(v) SetFlag("AutoRandomFruit", v) end
})

Tabs.Fruits:AddToggle("AutoTweenFruit", {
    Title = "Auto Tween to Fruit",
    Default = false,
    Callback = function(v) SetFlag("AutoTweenFruit", v) end
})

Tabs.Fruits:AddToggle("AutoTweenDealer", {
    Title = "Auto Tween Advanced Fruit Dealer",
    Default = false,
    Callback = function(v) SetFlag("AutoTweenDealer", v) end
})

Tabs.Fruits:AddToggle("FruitESP", {
    Title = "Fruit ESP",
    Default = false,
    Callback = function(v) SetFlag("FruitESP", v) end
})

Tabs.Fruits:AddToggle("GodChalice", {
    Title = "Auto Farm God's Chalice / Stop when got",
    Default = false,
    Callback = function(v) SetFlag("GodChalice", v) end
})

Tabs.Fruits:AddToggle("IceWalk", {
    Title = "Ice Walk",
    Default = false,
    Callback = function(v) SetFlag("IceWalk", v) end
})

-------------------------------------------------
-- SWORDS / WEAPONS
-------------------------------------------------
local SwordList = {
    "Saber", "Yama", "Tushita", "Cursed Dual Katana", "True Triple Katana",
    "Rengoku", "Midnight Blade", "Dark Blade", "Bisento", "Pole",
    "Shark Anchor", "Soul Cane", "Hallow Scythe", "Dragon Trident",
    "Twin Hooks", "Canvander", "Buddy Sword", "Warden Sword", "Longsword",
    "Katana", "Cutlass", "Dual Katana", "Triple Katana", "Iron Mace",
    "Pipe", "Flintlock", "Refined Flintlock", "Musket", "Kabucha",
    "Serpent Bow", "Skull Guitar", "Valkyrie Helm"
}

Tabs.Swords:AddDropdown("SelectSword", {
    Title = "Select Weapon",
    Values = SwordList,
    Multi = false,
    Default = 1,
    Callback = function(v)
        SetFlag("SelectSword", v)
        EquipTool(v)
    end
})

Tabs.Swords:AddToggle("AutoEquipSword", {
    Title = "Auto Equip Selected Sword",
    Default = false,
    Callback = function(v)
        SetFlag("AutoEquipSword", v)
        if v then
            task.spawn(function()
                while GetFlag("AutoEquipSword") do
                    local name = GetFlag("SelectSword")
                    if name then EquipTool(name) end
                    task.wait(1)
                end
            end)
        end
    end
})

Tabs.Swords:AddToggle("AutoSaber", {
    Title = "Auto Saber Sword",
    Default = false,
    Callback = function(v) SetFlag("AutoSaber", v) end
})

Tabs.Swords:AddToggle("AutoRengoku", {
    Title = "Auto Rengoku Sword",
    Default = false,
    Callback = function(v) SetFlag("AutoRengoku", v) end
})

Tabs.Swords:AddToggle("AutoPole", {
    Title = "Auto Pole V1 / V2",
    Default = false,
    Callback = function(v) SetFlag("AutoPole", v) end
})

Tabs.Swords:AddToggle("AutoCDKSword", {
    Title = "Auto CDK / Tushita / Yama",
    Default = false,
    Callback = function(v) SetFlag("AutoCDKSword", v) end
})

Tabs.Swords:AddToggle("AutoSkullGuitar", {
    Title = "Auto Skull Guitar",
    Default = false,
    Callback = function(v) SetFlag("AutoSkullGuitar", v) end
})

Tabs.Swords:AddToggle("AutoLegendarySword", {
    Title = "Tween to Legendary Sword Dealer",
    Default = false,
    Callback = function(v) SetFlag("AutoLegendarySword", v) end
})

Tabs.Swords:AddToggle("AutoGun", {
    Title = "Auto Gun",
    Default = false,
    Callback = function(v) SetFlag("AutoGun", v) end
})

Tabs.Swords:AddToggle("AutoMelee", {
    Title = "Auto Melee",
    Default = false,
    Callback = function(v) SetFlag("AutoMelee", v) end
})

-------------------------------------------------
-- RACE / HAKI / STYLES
-------------------------------------------------
Tabs.Race:AddToggle("AutoBuso", {
    Title = "Auto Turn on Buso",
    Default = false,
    Callback = function(v)
        SetFlag("AutoBuso", v)
        if v then
            task.spawn(function()
                while GetFlag("AutoBuso") do
                    FireComm("Buso")
                    task.wait(1)
                end
            end)
        end
    end
})

Tabs.Race:AddToggle("AutoKen", {
    Title = "Auto Observation / Ken",
    Default = false,
    Callback = function(v) SetFlag("AutoKen", v) end
})

Tabs.Race:AddToggle("AutoRaceV3", {
    Title = "Auto Turn on Race V3",
    Default = false,
    Callback = function(v) SetFlag("AutoRaceV3", v) end
})

Tabs.Race:AddToggle("AutoRaceV4", {
    Title = "Auto Turn on Race V4",
    Default = false,
    Callback = function(v) SetFlag("AutoRaceV4", v) end
})

Tabs.Race:AddToggle("AutoTrainV4", {
    Title = "Auto Train V4",
    Default = false,
    Callback = function(v) SetFlag("AutoTrainV4", v) end
})

Tabs.Race:AddToggle("AutoSuperhuman", {
    Title = "Auto Superhuman",
    Default = false,
    Callback = function(v) SetFlag("AutoSuperhuman", v) end
})

Tabs.Race:AddToggle("AutoGodhuman", {
    Title = "Auto Godhuman",
    Default = false,
    Callback = function(v) SetFlag("AutoGodhuman", v) end
})

Tabs.Race:AddToggle("AutoSanguine", {
    Title = "Auto Sanguine Art",
    Default = false,
    Callback = function(v) SetFlag("AutoSanguine", v) end
})

Tabs.Race:AddToggle("AutoSharkman", {
    Title = "Auto Sharkman Karate",
    Default = false,
    Callback = function(v) SetFlag("AutoSharkman", v) end
})

Tabs.Race:AddToggle("AutoDeathStep", {
    Title = "Auto Death Step",
    Default = false,
    Callback = function(v) SetFlag("AutoDeathStep", v) end
})

Tabs.Race:AddToggle("AutoElectricClaw", {
    Title = "Auto Electric Claw",
    Default = false,
    Callback = function(v) SetFlag("AutoElectricClaw", v) end
})

Tabs.Race:AddToggle("AutoDragonClaw", {
    Title = "Auto Dragon Claw / Talon",
    Default = false,
    Callback = function(v) SetFlag("AutoDragonClaw", v) end
})

Tabs.Race:AddToggle("InfSoru", {
    Title = "Instance Soru [INF]",
    Default = false,
    Callback = function(v) SetFlag("InfSoru", v) end
})

Tabs.Race:AddToggle("InfObservation", {
    Title = "Instance Observation Range [INF]",
    Default = false,
    Callback = function(v) SetFlag("InfObservation", v) end
})

Tabs.Race:AddToggle("InfEnergy", {
    Title = "Instance Energy [INF]",
    Default = false,
    Callback = function(v) SetFlag("InfEnergy", v) end
})

Tabs.Race:AddToggle("AutoAwaken", {
    Title = "Auto Awakening",
    Default = false,
    Callback = function(v) SetFlag("AutoAwaken", v) end
})

Tabs.Race:AddToggle("AutoBuyBusoColor", {
    Title = "Auto Buy Buso Color",
    Default = false,
    Callback = function(v) SetFlag("AutoBuyBusoColor", v) end
})

-------------------------------------------------
-- TELEPORT (real CFrames checked & filled)
-------------------------------------------------
local IslandCFrames = {
    -- Sea 1
    ["Pirate Starter"] = CFrame.new(979.799, 16.516, 1429.047),
    ["Marine Starter"] = CFrame.new(-2566.43, 6.856, 2045.256),
    ["Middle Town"] = CFrame.new(-690.331, 15.094, 1582.238),
    ["Jungle"] = CFrame.new(-1612.796, 36.852, 149.128),
    ["Pirate Village"] = CFrame.new(-1181.309, 4.751, 3803.546),
    ["Desert"] = CFrame.new(944.158, 20.92, 4373.3),
    ["Frozen Village"] = CFrame.new(1347.807, 104.668, -1319.737),
    ["Marine Fortress"] = CFrame.new(-4914.821, 50.964, 4281.028),
    ["Magma Village"] = CFrame.new(-5247.716, 12.884, 8504.969),
    ["Fountain City"] = CFrame.new(5127.128, 59.501, 4105.446),
    ["Skylands"] = CFrame.new(-483.734, 332.038, 595.327),
    ["Prison"] = CFrame.new(4875.33, 5.652, 734.85),
    ["Colosseum"] = CFrame.new(-11.311, 29.277, 2771.522),
    ["Underwater City"] = CFrame.new(-2850.201, 7.392, 5354.993),
    ["Shank Room"] = CFrame.new(-1442.166, 29.879, -28.355),
    ["Mob Island"] = CFrame.new(-2850.201, 7.392, 5354.993),

    -- Sea 2
    ["Kingdom of Rose"] = CFrame.new(-380.479, 77.22, 255.826), -- Cafe area / Rose hub
    ["Cafe"] = CFrame.new(-380.479, 77.22, 255.826),
    ["Green Zone"] = CFrame.new(-2245.0, 73.0, -2800.0), -- approximate from common hubs
    ["Graveyard"] = CFrame.new(-9515.0, 142.0, 5786.0), -- near haunted-ish / adjust live
    ["Snow Mountain"] = CFrame.new(753.143, 408.236, -5274.615),
    ["Hot and Cold"] = CFrame.new(-6127.654, 15.952, -5040.286), -- Punk Hazard style
    ["Cursed Ship"] = CFrame.new(923.0, 125.0, 32865.0), -- common cursed ship
    ["Ice Castle"] = CFrame.new(5500.0, 40.0, -6200.0),
    ["Forgotten Island"] = CFrame.new(-3050.0, 240.0, -10250.0),
    ["Usoap Island"] = CFrame.new(4816.862, 8.46, 2863.82),
    ["Dark Arena"] = CFrame.new(3780.03, 22.652, -3498.586),
    ["Factory"] = CFrame.new(424.127, 211.162, -427.54),

    -- Sea 3
    ["Port Town"] = CFrame.new(-226.751, 20.603, 5538.34),
    ["Hydra Island"] = CFrame.new(5291.249, 1005.443, 393.762),
    ["Great Tree"] = CFrame.new(2681.274, 1682.809, -7190.985),
    ["Floating Turtle"] = CFrame.new(-13274.528, 531.821, -7579.223),
    ["Castle on the Sea"] = CFrame.new(-5083.26, 314.606, -3175.673),
    ["Mansion"] = CFrame.new(-378.0, 331.0, 645.0), -- near castle / mansion access
    ["Haunted Castle"] = CFrame.new(-9515.372, 164.006, 5786.061),
    ["Ice Cream Island"] = CFrame.new(-902.568, 79.932, -10988.848),
    ["Peanut Island"] = CFrame.new(-2062.748, 50.474, -10232.568),
    ["Cake Island"] = CFrame.new(-1884.775, 19.328, -11666.897),
    ["Cocoa Island"] = CFrame.new(87.943, 73.555, -12319.465),
    ["Candy Island"] = CFrame.new(-1014.424, 149.111, -14555.963),
    ["Tiki Outpost"] = CFrame.new(-16218.683, 9.086, 445.618),
    ["Dragon Dojo"] = CFrame.new(5743.319, 1206.91, 936.011),
    ["Mini Sky Island"] = CFrame.new(-288.741, 49326.316, -35248.594),

    -- Special
    ["Temple of Time"] = CFrame.new(28286.0, 14896.0, 102.0), -- common ToT
    ["Frozen Dimension"] = CFrame.new(-5000.0, 300.0, -12000.0), -- leviathan approach (live adjust)
}

local IslandNames = {}
for name in pairs(IslandCFrames) do
    table.insert(IslandNames, name)
end
table.sort(IslandNames)

local function RequestEntrance(pos)
    pcall(function()
        local rem = ReplicatedStorage:FindFirstChild("Remotes")
        if rem and rem:FindFirstChild("CommF_") then
            rem.CommF_:InvokeServer("requestEntrance", pos)
        end
    end)
end

local function TeleportToIsland(name)
    local cf = IslandCFrames[name]
    if not cf then
        Notify("TP", "No CFrame for " .. tostring(name))
        return
    end
    -- Prefer portal request when available (Castle / Mansion style)
    if name == "Castle on the Sea" or name == "Mansion" then
        RequestEntrance(Vector3.new(cf.X, cf.Y, cf.Z))
        task.wait(0.4)
    end
    TweenTo(cf, 350)
    Notify("TP", "Arrived: " .. name)
end

Tabs.TP:AddDropdown("SelectIsland", {
    Title = "Choose Island",
    Values = IslandNames,
    Multi = false,
    Default = 1,
    Callback = function(v) SetFlag("SelectIsland", v) end
})

Tabs.TP:AddButton({
    Title = "Teleport to Selected Island",
    Callback = function()
        local name = GetFlag("SelectIsland")
        if name then
            TeleportToIsland(name)
        end
    end
})

Tabs.TP:AddToggle("AutoNextIsland", {
    Title = "Auto Next Island",
    Default = false,
    Callback = function(v) SetFlag("AutoNextIsland", v) end
})

Tabs.TP:AddToggle("BypassTP", {
    Title = "Turn on Bypass Teleport",
    Default = false,
    Callback = function(v) SetFlag("BypassTP", v) end
})

Tabs.TP:AddButton({
    Title = "Travel East Blue (World 1)",
    Callback = function()
        FireComm("TravelMain")
    end
})

Tabs.TP:AddButton({
    Title = "Travel Dressrosa (World 2)",
    Callback = function()
        FireComm("TravelDressrosa")
    end
})

Tabs.TP:AddButton({
    Title = "Travel Zou (World 3)",
    Callback = function()
        FireComm("TravelZou")
    end
})

Tabs.TP:AddToggle("AutoTweenNPC", {
    Title = "Auto Tween to NPCs",
    Default = false,
    Callback = function(v) SetFlag("AutoTweenNPC", v) end
})

Tabs.TP:AddToggle("UnlockPortals", {
    Title = "Unlock All Portals",
    Default = false,
    Callback = function(v) SetFlag("UnlockPortals", v) end
})

Tabs.TP:AddButton({
    Title = "Teleport to Temple of Time",
    Callback = function()
        TeleportToIsland("Temple of Time")
    end
})

Tabs.TP:AddButton({
    Title = "Teleport to Frozen Dimension",
    Callback = function()
        TeleportToIsland("Frozen Dimension")
    end
})

Tabs.TP:AddButton({
    Title = "Teleport to Castle on the Sea",
    Callback = function()
        TeleportToIsland("Castle on the Sea")
    end
})

Tabs.TP:AddButton({
    Title = "Teleport to Hydra Island",
    Callback = function()
        TeleportToIsland("Hydra Island")
    end
})

-------------------------------------------------
-- ESP
-------------------------------------------------
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "BFHubESP"
ESPFolder.Parent = CoreGui


-- === PORTED from reference: ESP systems ===
local function _DistM(pos)
    if not HumanoidRootPart then return 0 end
    return math.floor((HumanoidRootPart.Position - pos).Magnitude / 3 + 0.5)
end

local function ClearESPFolder()
    for _, c in ipairs(ESPFolder:GetChildren()) do
        c:Destroy()
    end
end

local function EnsureBillboard(adornee, name, text, color)
    if not adornee then return end
    local existing = adornee:FindFirstChild(name)
    if existing and existing:IsA("BillboardGui") then
        local lab = existing:FindFirstChild("ESP")
        if lab then lab.Text = text end
        return
    end
    local bill = Instance.new("BillboardGui")
    bill.Name = name
    bill.Adornee = adornee
    bill.Size = UDim2.new(0, 200, 0, 40)
    bill.StudsOffset = Vector3.new(0, 2, 0)
    bill.AlwaysOnTop = true
    bill.Parent = ESPFolder
    local label = Instance.new("TextLabel")
    label.Name = "ESP"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(0, 255, 250)
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextWrapped = true
    label.Parent = bill
end

local function UpdatePlayerESP()
    if not GetFlag("PlayerESP") then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local hum = plr.Character:FindFirstChild("Humanoid")
            local hp = hum and (math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)) or "?"
            local col = (plr.Team ~= LocalPlayer.Team) and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 255)
            EnsureBillboard(head, "NameEsp" .. plr.Name, plr.Name .. " [" .. _DistM(head.Position) .. "M] HP " .. hp, col)
        end
    end
end

local function UpdateIslandESP()
    if not GetFlag("IslandESP") then return end
    local wo = workspace:FindFirstChild("_WorldOrigin")
    local locs = wo and wo:FindFirstChild("Locations")
    if not locs then return end
    for _, loc in ipairs(locs:GetChildren()) do
        if loc.Name ~= "Sea" and loc:IsA("BasePart") then
            EnsureBillboard(loc, "NameEsp", loc.Name .. "\n" .. _DistM(loc.Position) .. " M", Color3.fromRGB(80, 245, 245))
        end
    end
end

local function UpdateChestESP()
    if not GetFlag("ChestESP") then return end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name:find("Chest") then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                EnsureBillboard(part, "NameEsp", obj.Name .. "\n" .. _DistM(part.Position) .. " M", Color3.fromRGB(0, 255, 250))
            end
        end
    end
end

local function UpdateFruitESP()
    if not (GetFlag("FruitESP") or GetFlag("FruitESP2")) then return end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name:find("Fruit") then
            local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
            if handle then
                EnsureBillboard(handle, "NameEsp", obj.Name .. "\n" .. _DistM(handle.Position) .. " M", Color3.fromRGB(255, 0, 0))
            end
        end
    end
end

local function UpdateFlowerESP()
    if not GetFlag("FlowerESP") then return end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj.Name == "Flower1" or obj.Name == "Flower2" then
            local col = obj.Name == "Flower1" and Color3.fromRGB(0, 0, 255) or Color3.fromRGB(255, 0, 0)
            local label = obj.Name == "Flower1" and "Blue Flower" or "Red Flower"
            EnsureBillboard(obj, "NameEsp", label .. "\n" .. _DistM(obj.Position) .. " M", col)
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            if GetFlag("PlayerESP") then UpdatePlayerESP() end
            if GetFlag("IslandESP") then UpdateIslandESP() end
            if GetFlag("ChestESP") then UpdateChestESP() end
            if GetFlag("FruitESP") or GetFlag("FruitESP2") then UpdateFruitESP() end
            if GetFlag("FlowerESP") then UpdateFlowerESP() end
        end)
    end
end)


local function ClearESP()
    ESPFolder:ClearAllChildren()
end

local function CreateESP(part, text, color)
    if not part then return end
    local bill = Instance.new("BillboardGui")
    bill.Name = "ESP_" .. text
    bill.Adornee = part
    bill.Size = UDim2.new(0, 120, 0, 40)
    bill.StudsOffset = Vector3.new(0, 3, 0)
    bill.AlwaysOnTop = true
    bill.Parent = ESPFolder
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Color3.fromRGB(255, 255, 0)
    label.TextStrokeTransparency = 0.3
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = bill
end

Tabs.ESP:AddToggle("PlayerESP", {
    Title = "Esp Players",
    Default = false,
    Callback = function(v)
        SetFlag("PlayerESP", v)
        if not v then ClearESP() end
    end
})

Tabs.ESP:AddToggle("ChestESP", {
    Title = "Esp Chests",
    Default = false,
    Callback = function(v) SetFlag("ChestESP", v) end
})

Tabs.ESP:AddToggle("FruitESP2", {
    Title = "Esp Fruits",
    Default = false,
    Callback = function(v) SetFlag("FruitESP2", v) end
})

Tabs.ESP:AddToggle("BerryESP", {
    Title = "Esp Berries",
    Default = false,
    Callback = function(v) SetFlag("BerryESP", v) end
})

Tabs.ESP:AddToggle("IslandESP", {
    Title = "Esp Island Location",
    Default = false,
    Callback = function(v) SetFlag("IslandESP", v) end
})

Tabs.ESP:AddToggle("BossESP", {
    Title = "Esp Bosses / Elite",
    Default = false,
    Callback = function(v) SetFlag("BossESP", v) end
})

Tabs.ESP:AddToggle("FlowerESP", {
    Title = "Esp Flower",
    Default = false,
    Callback = function(v) SetFlag("FlowerESP", v) end
})

Tabs.ESP:AddToggle("GearESP", {
    Title = "Esp Gears",
    Default = false,
    Callback = function(v) SetFlag("GearESP", v) end
})

Tabs.ESP:AddToggle("RemoveVFX", {
    Title = "Remove Death & Respawned VFX",
    Default = false,
    Callback = function(v) SetFlag("RemoveVFX", v) end
})

-------------------------------------------------
-- COMBAT / AIMBOT
-------------------------------------------------
Tabs.Combat:AddToggle("AimbotSkills", {
    Title = "Aimbot - Skills",
    Default = false,
    Callback = function(v) SetFlag("AimbotSkills", v) end
})

Tabs.Combat:AddToggle("AimbotCamera", {
    Title = "Aimbot Camera Closest Players",
    Default = false,
    Callback = function(v) SetFlag("AimbotCamera", v) end
})

Tabs.Combat:AddToggle("AutoAimbot", {
    Title = "Auto Aimbots",
    Default = false,
    Callback = function(v) SetFlag("AutoAimbot", v) end
})

Tabs.Combat:AddToggle("AttackNoCD", {
    Title = "Attack No CoolDown",
    Default = false,
    Callback = function(v) SetFlag("AttackNoCD", v) end
})

Tabs.Combat:AddToggle("IgnoreSameTeam", {
    Title = "Ignore Same Team (Aimbot)",
    Default = true,
    Callback = function(v) SetFlag("IgnoreSameTeam", v) end
})

Tabs.Combat:AddToggle("BringMobs", {
    Title = "Bring Enemy / Mobs",
    Default = false,
    Callback = function(v) SetFlag("BringMobs", v) end
})

Tabs.Combat:AddSlider("NPCHealthSwitch", {
    Title = "NPC Health % Switch to Weapon",
    Default = 30,
    Min = 1,
    Max = 100,
    Rounding = 0,
    Callback = function(v) SetFlag("NPCHealthSwitch", v) end
})

-------------------------------------------------
-- FISHING
-------------------------------------------------
local Baits = {"Basic Bait", "Good Bait", "Epic Bait", "Carnivore Bait", "Frozen Bait", "Kelp Bait", "Abyssal Bait"}
local Rods = {"Fishing Rod", "Gold Rod", "Shark Rod", "Shell Rod", "Treasure Rod"}

Tabs.Fish:AddDropdown("SelectBait", {
    Title = "Select Bait",
    Values = Baits,
    Multi = false,
    Default = 1,
    Callback = function(v) SetFlag("SelectBait", v) end
})

Tabs.Fish:AddDropdown("SelectRod", {
    Title = "Select Fishing Rod",
    Values = Rods,
    Multi = false,
    Default = 1,
    Callback = function(v) SetFlag("SelectRod", v) end
})

Tabs.Fish:AddToggle("AutoFishing", {
    Title = "Auto Fishing",
    Default = false,
    Callback = function(v)
        SetFlag("AutoFishing", v)
        if v then
            Notify("Fishing", "Auto Fishing started")
        end
    end
})

-------------------------------------------------
-- SHOP / CRAFT
-------------------------------------------------
Tabs.Shop:AddToggle("AutoStoreFruitShop", {
    Title = "Auto Store Fruit",
    Default = false,
    Callback = function(v) SetFlag("AutoStoreFruitShop", v) end
})

Tabs.Shop:AddToggle("AutoCraftVolcanic", {
    Title = "Auto Craft Volcanic Magnet",
    Default = false,
    Callback = function(v) SetFlag("AutoCraftVolcanic", v) end
})

Tabs.Shop:AddButton({
    Title = "Buy Superhuman",
    Callback = function() FireComm("BuySuperhuman") end
})

Tabs.Shop:AddButton({
    Title = "Buy Godhuman",
    Callback = function() FireComm("BuyGodhuman") end
})

Tabs.Shop:AddButton({
    Title = "Buy Sharkman Karate",
    Callback = function() FireComm("BuySharkmanKarate") end
})

Tabs.Shop:AddButton({
    Title = "Buy Death Step",
    Callback = function() FireComm("BuyDeathStep") end
})

Tabs.Shop:AddButton({
    Title = "Buy Electric Claw",
    Callback = function() FireComm("BuyElectricClaw") end
})

Tabs.Shop:AddButton({
    Title = "Buy Dragon Talon",
    Callback = function() FireComm("BuyDragonTalon") end
})

Tabs.Shop:AddButton({
    Title = "Buy Sanguine Art",
    Callback = function() FireComm("BuySanguineArt") end
})

Tabs.Shop:AddButton({
    Title = "Buy Buso",
    Callback = function() FireComm("BuyHaki", "Buso") end
})

Tabs.Shop:AddButton({
    Title = "Buy Geppo",
    Callback = function() FireComm("BuyHaki", "Geppo") end
})

Tabs.Shop:AddButton({
    Title = "Buy Soru",
    Callback = function() FireComm("BuyHaki", "Soru") end
})

Tabs.Shop:AddButton({
    Title = "Buy Ken",
    Callback = function() FireComm("BuyHaki", "Ken") end
})

Tabs.Shop:AddToggle("AutoBuyBusoColorShop", {
    Title = "Auto Buy Buso Color",
    Default = false,
    Callback = function(v) SetFlag("AutoBuyBusoColorShop", v) end
})

Tabs.Shop:AddButton({
    Title = "Craft Leviathan Boat",
    Callback = function() Notify("Craft", "Leviathan Boat") end
})

Tabs.Shop:AddButton({
    Title = "Craft Shark Anchor",
    Callback = function() Notify("Craft", "Shark Anchor") end
})

-------------------------------------------------
-- MISC / SETTINGS
-------------------------------------------------
Tabs.Misc:AddToggle("AntiAFKToggle", {
    Title = "Anti AFK",
    Default = true,
    Callback = function(v)
        SetFlag("AntiAFK", v)
    end
})

Tabs.Misc:AddToggle("WalkOnWater", {
    Title = "Walk on Water",
    Default = false,
    Callback = function(v)
        SetFlag("WalkOnWater", v)
        if v then
            local part = Instance.new("Part")
            part.Name = "WalkWater_Part"
            part.Size = Vector3.new(20, 1, 20)
            part.Transparency = 1
            part.Anchored = true
            part.CanCollide = true
            part.Parent = workspace
            Connect("WalkWater", RunService.Heartbeat, function()
                if HumanoidRootPart then
                    part.CFrame = CFrame.new(HumanoidRootPart.Position.X, 0.5, HumanoidRootPart.Position.Z)
                end
            end)
        else
            Disconnect("WalkWater")
            if workspace:FindFirstChild("WalkWater_Part") then
                workspace.WalkWater_Part:Destroy()
            end
        end
    end
})

Tabs.Misc:AddToggle("FullBright", {
    Title = "Turn on Full Bright",
    Default = false,
    Callback = function(v)
        SetFlag("FullBright", v)
        if v then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
    end
})

Tabs.Misc:AddToggle("LowCPU", {
    Title = "Turn on Low CPU",
    Default = false,
    Callback = function(v)
        SetFlag("LowCPU", v)
        if v then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end
    end
})

Tabs.Misc:AddToggle("NoClip", {
    Title = "Body Clip / NoClip",
    Default = false,
    Callback = function(v)
        SetFlag("NoClip", v)
        if v then
            Connect("NoClip", RunService.Stepped, function()
                if Character then
                    for _, part in ipairs(Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            Disconnect("NoClip")
        end
    end
})

Tabs.Misc:AddToggle("InfAbility", {
    Title = "Infinite Abilities",
    Default = false,
    Callback = function(v) SetFlag("InfAbility", v) end
})

Tabs.Misc:AddToggle("SafeMode", {
    Title = "Safe Mode (low health protection)",
    Default = false,
    Callback = function(v) SetFlag("SafeMode", v) end
})

Tabs.Misc:AddButton({
    Title = "Server Hop (Lowest Players)",
    Callback = function()
        Notify("Server Hop", "Looking for low player server...")
        pcall(function()
            local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            for _, s in ipairs(servers.data or {}) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                    break
                end
            end
        end)
    end
})

Tabs.Misc:AddButton({
    Title = "Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

Tabs.Misc:AddButton({
    Title = "Copy Job ID",
    Callback = function()
        setclipboard(tostring(game.JobId))
        Notify("Job ID", "Copied to clipboard")
    end
})

Tabs.Misc:AddToggle("DisableNotify", {
    Title = "Disable Notify",
    Default = false,
    Callback = function(v) SetFlag("DisableNotify", v) end
})

Tabs.Misc:AddToggle("DisableChat", {
    Title = "Disable Chat GUI",
    Default = false,
    Callback = function(v)
        pcall(function()
            StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not v)
        end)
    end
})

Tabs.Misc:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Callback = function(v)
        if Humanoid then Humanoid.WalkSpeed = v end
    end
})

Tabs.Misc:AddSlider("JumpPower", {
    Title = "Jump Power",
    Default = 50,
    Min = 50,
    Max = 200,
    Rounding = 0,
    Callback = function(v)
        if Humanoid then Humanoid.JumpPower = v end
    end
})

-------------------------------------------------
-- MAIN TAB INFO
-------------------------------------------------
Tabs.Main:AddParagraph({
    Title = "BF Full Feature Hub",
    Content = "Reconstructed from constant dump.\nAll major systems present as toggles.\nUse at your own risk on private/alt accounts.\nFluent UI loaded."
})

Tabs.Main:AddButton({
    Title = "Reload Character",
    Callback = function()
        LocalPlayer.Character:BreakJoints()
    end
})

Tabs.Main:AddButton({
    Title = "Destroy Hub",
    Callback = function()
        for name, conn in pairs(Hub.Connections) do
            pcall(function() conn:Disconnect() end)
        end
        ClearESP()
        if Window then pcall(function() Window:Destroy() end) end
        pcall(function() if Fluent.Destroy then Fluent:Destroy() end end)
        getgenv().BFHub = nil
    end
})

-- Fluent finish
pcall(function()
    if Window.SelectTab then
        Window:SelectTab(1)
    end
end)

pcall(function()
    if SaveManager and InterfaceManager and Fluent then
        SaveManager:SetLibrary(Fluent)
        InterfaceManager:SetLibrary(Fluent)
        pcall(function() SaveManager:IgnoreThemeSettings() end)
        InterfaceManager:SetFolder("BFFullHub")
        SaveManager:SetFolder("BFFullHub/configs")
        pcall(function() InterfaceManager:BuildInterfaceSection(Tabs.Misc) end)
        pcall(function() SaveManager:BuildConfigSection(Tabs.Misc) end)
        pcall(function() SaveManager:LoadAutoloadConfig() end)
    end
end)

Notify("BF Hub", "Loaded · Fluent ready · No Key", 4)
print("[BFHub] UI ready")
