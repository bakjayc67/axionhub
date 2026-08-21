--[[
  BF Full Hub — Axion
  v2.1.0 — methods ported from live Lotus-style source
  FastAttack / CommF_ / QuestController / smartTween / bringMob
  Fluent UI · No Key · Multi-executor
]]

if getgenv().BFHub then
    pcall(function()
        if getgenv().BFHub.Window and getgenv().BFHub.Window.Destroy then
            getgenv().BFHub.Window:Destroy()
        end
    end)
end

local Hub = {
    Flags = {},
    Version = "2.1.0-lotus-methods",
}
getgenv().BFHub = Hub

--------------------------------------------------------------------
-- Services
--------------------------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local VIM = Instance.new("VirtualInputManager")

local LP = Players.LocalPlayer
local Character = LP.Character or LP.CharacterAdded:Wait()
local Humanoid, HRP

local function notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "BF Hub",
            Text = text or "",
            Duration = dur or 3,
        })
    end)
end

local function BindCharacter(char)
    Character = char or LP.Character
    if not Character then return end
    Humanoid = Character:FindFirstChildOfClass("Humanoid")
    HRP = Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart
    pcall(function()
        local stun = Character:FindFirstChild("Stun")
        if stun and stun:IsA("ValueBase") then stun.Value = 0 end
    end)
end
BindCharacter(Character)
LP.CharacterAdded:Connect(function(c)
    task.wait(0.3)
    BindCharacter(c)
    Character = c
end)

task.spawn(function()
    while true do
        pcall(function()
            BindCharacter(LP.Character)
            if setsimulationradius then
                setsimulationradius(math.huge, math.huge)
            elseif LP.SimulationRadius ~= nil then
                LP.SimulationRadius = 1e6
            end
        end)
        task.wait(1)
    end
end)

--------------------------------------------------------------------
-- Sea detect (Lotus style — MAP attribute)
--------------------------------------------------------------------
local PLACE_ID = {}
PLACE_ID.sea1 = function()
    return workspace:GetAttribute("MAP") == "Sea1"
end
PLACE_ID.sea2 = function()
    return workspace:GetAttribute("MAP") == "Sea2"
end
PLACE_ID.sea3 = function()
    return workspace:GetAttribute("MAP") == "Sea3"
end

local function Level()
    local n = 1
    pcall(function() n = LP.Data.Level.Value end)
    return n or 1
end

--------------------------------------------------------------------
-- HttpGet race + cache
--------------------------------------------------------------------
local LibCache = getgenv().BFHub_LibCache or {}
getgenv().BFHub_LibCache = LibCache

local function rawHttpGet(url, timeoutSec)
    timeoutSec = timeoutSec or 2.0
    local result, done = nil, false
    local function finish(body)
        if done then return end
        if type(body) == "string" and #body > 200 then
            result, done = body, true
        end
    end
    task.spawn(function()
        pcall(function()
            if syn and syn.request then
                local r = syn.request({ Url = url, Method = "GET" })
                finish(r and r.Body)
            elseif http_request then
                local r = http_request({ Url = url, Method = "GET" })
                finish(r and r.Body)
            elseif request then
                local r = request({ Url = url, Method = "GET" })
                finish(r and r.Body)
            elseif fluxus and fluxus.request then
                local r = fluxus.request({ Url = url, Method = "GET" })
                finish(r and r.Body)
            else
                finish(game:HttpGet(url, true))
            end
        end)
    end)
    local t0 = os.clock()
    while not done and (os.clock() - t0) < timeoutSec do
        task.wait(0.05)
    end
    return result
end

local function raceHttpGet(urls, totalTimeout)
    totalTimeout = totalTimeout or 3.5
    if LibCache[urls[1]] then return LibCache[urls[1]] end
    local winner, done = nil, false
    for _, u in ipairs(urls) do
        task.spawn(function()
            local b = rawHttpGet(u, 2.0)
            if not done and b and #b > 200 then
                if b:find("Library", 1, true) or b:find("CreateWindow", 1, true) or #b > 4000 then
                    winner, done = b, true
                    LibCache[u] = b
                end
            end
        end)
    end
    local t0 = os.clock()
    while not done and (os.clock() - t0) < totalTimeout do
        task.wait(0.05)
    end
    return winner
end

--------------------------------------------------------------------
-- CommF_ (Lotus primary remote)
--------------------------------------------------------------------
local function CommF_(...)
    local ok, res = pcall(function()
        return ReplicatedStorage.Remotes.CommF_:InvokeServer(...)
    end)
    if ok then return res end
    return nil
end

local function CommE_(...)
    pcall(function()
        ReplicatedStorage.Remotes.CommE:FireServer(...)
    end)
end

--------------------------------------------------------------------
-- Equip (Lotus)
--------------------------------------------------------------------
local function equipWeapon(weapon_type)
    weapon_type = weapon_type or "Melee"
    BindCharacter(LP.Character)
    if not Character or not Humanoid then return false end
    if not Character:FindFirstChild("HasBuso") then
        CommF_("Buso")
    end
    for _, v in ipairs(LP.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.ToolTip == weapon_type then
            pcall(function() Humanoid:EquipTool(v) end)
            return true
        end
    end
    for _, tip in ipairs({ "Melee", "Sword", "Blox Fruit", "Gun" }) do
        for _, v in ipairs(LP.Backpack:GetChildren()) do
            if v:IsA("Tool") and v.ToolTip == tip then
                pcall(function() Humanoid:EquipTool(v) end)
                return true
            end
        end
    end
    return false
end

--------------------------------------------------------------------
-- FastAttack (Lotus modern — RegisterAttack / RegisterHit + seed XOR)
--------------------------------------------------------------------
local netRemote, netId
pcall(function()
    for _, folder in ipairs({
        ReplicatedStorage:FindFirstChild("Util"),
        ReplicatedStorage:FindFirstChild("Common"),
        ReplicatedStorage:FindFirstChild("Remotes"),
        ReplicatedStorage:FindFirstChild("Assets"),
        ReplicatedStorage:FindFirstChild("FX"),
    }) do
        if folder then
            for _, n in ipairs(folder:GetChildren()) do
                if n:IsA("RemoteEvent") and n:GetAttribute("Id") then
                    netRemote, netId = n, n:GetAttribute("Id")
                end
            end
            folder.ChildAdded:Connect(function(n)
                if n:IsA("RemoteEvent") and n:GetAttribute("Id") then
                    netRemote, netId = n, n:GetAttribute("Id")
                end
            end)
        end
    end
end)

local function FastAttack()
    BindCharacter(LP.Character)
    if not Character then return end
    local parts = {}
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return end
    for _, v in ipairs(enemies:GetChildren()) do
        local hrp = v:FindFirstChild("HumanoidRootPart")
        local hum = v:FindFirstChildOfClass("Humanoid")
        if hrp and hum and hum.Health > 0 then
            local dist = LP:DistanceFromCharacter(hrp.Position)
            if dist <= 40 then
                for _, part in ipairs(v:GetChildren()) do
                    if part:IsA("BasePart") then
                        parts[#parts + 1] = { v, part }
                    end
                end
            end
        end
    end
    if #parts == 0 then return end

    local tool = Character:FindFirstChildOfClass("Tool")
    if not tool then
        equipWeapon()
        tool = Character:FindFirstChildOfClass("Tool")
    end
    if not tool then return end
    local tip = tool.ToolTip
    if tip ~= "Melee" and tip ~= "Sword" and tip ~= "Blox Fruit" and tip ~= "Gun" then
        return
    end

    -- Path A: Modules.Net RegisterAttack + RegisterHit (Lotus)
    pcall(function()
        local net = ReplicatedStorage:FindFirstChild("Modules")
            and ReplicatedStorage.Modules:FindFirstChild("Net")
        if not net then return end
        local ra = net:FindFirstChild("RE/RegisterAttack")
        local rh = net:FindFirstChild("RE/RegisterHit")
        if ra then ra:FireServer() end
        if rh then
            local head = parts[1][1]:FindFirstChild("Head") or parts[1][2]
            local token = tostring(LP.UserId):sub(2, 4) .. tostring(coroutine.running()):sub(11, 15)
            rh:FireServer(head, parts, {}, token)
        end
    end)

    -- Path B: XOR seed remote (Lotus)
    pcall(function()
        if not netRemote or not netId then return end
        local head = parts[1][1]:FindFirstChild("Head") or parts[1][2]
        local seed = 0
        pcall(function()
            seed = ReplicatedStorage.Modules.Net.seed:InvokeServer() * 2
        end)
        local xorName = string.gsub("RE/RegisterHit", ".", function(c)
            return string.char(bit32.bxor(string.byte(c), math.floor(workspace:GetServerTimeNow() / 10 % 10) + 1))
        end)
        netRemote:FireServer(
            xorName,
            bit32.bxor(netId + 909090, seed),
            head,
            parts
        )
    end)

    -- Path C: click fallback
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(0, 0))
        task.wait(0.02)
        VirtualUser:Button1Up(Vector2.new(0, 0))
    end)
    pcall(function()
        if tool then tool:Activate() end
    end)
end

local function AttackModern()
    FastAttack()
end

--------------------------------------------------------------------
-- Bring mob (Lotus — network ownership + stack CFrame)
--------------------------------------------------------------------
local function bringMob(nameFilter, maxCount)
    BindCharacter(LP.Character)
    if not Character or not Character.PrimaryPart then return end
    maxCount = maxCount or 3
    local targets = {}
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return end
    for _, x in ipairs(enemies:GetChildren()) do
        local h = x:FindFirstChildOfClass("Humanoid")
        local pp = x.PrimaryPart or x:FindFirstChild("HumanoidRootPart")
        if pp and h and h.Health > 0 then
            if (not nameFilter or x.Name == nameFilter or x.Name:find(nameFilter, 1, true))
                and LP:DistanceFromCharacter(pp.Position) <= 180 then
                targets[#targets + 1] = x
                if #targets >= maxCount then break end
            end
        end
    end
    if #targets == 0 then return end
    local t = (targets[1].PrimaryPart or targets[1].HumanoidRootPart).CFrame
    for _, x in ipairs(targets) do
        pcall(function()
            local pp = x.PrimaryPart or x:FindFirstChild("HumanoidRootPart")
            if not pp then return end
            if isnetworkowner and isnetworkowner(pp) then
                pp.CFrame = t
            else
                -- soft pull
                pp.CFrame = t
            end
            pcall(function()
                sethiddenproperty(pp, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
            end)
        end)
    end
end

--------------------------------------------------------------------
-- Tween + smartTween (Lotus entrance waypoints)
--------------------------------------------------------------------
local currentTween

local function StopTween()
    if currentTween then
        pcall(function() currentTween:Cancel() end)
        currentTween = nil
    end
end

local function requestEntrance(pos)
    pcall(function()
        CommF_("requestEntrance", typeof(pos) == "Vector3" and pos or pos.Position)
    end)
end

local function smartTween(targetPos)
    if typeof(targetPos) == "CFrame" then
        targetPos = targetPos.Position
    end
    local waypoints
    if PLACE_ID.sea3() then
        waypoints = {
            Vector3.new(5700, 1015, -215),
            Vector3.new(-12550, 340, -7500),
            Vector3.new(-5000, 350, -3035),
        }
    elseif PLACE_ID.sea2() then
        waypoints = {
            Vector3.new(-390, 332, 673),
            Vector3.new(2285, 15, 905),
            Vector3.new(923, 126, 32852),
            Vector3.new(-6509, 83, -133),
        }
    elseif PLACE_ID.sea1() then
        if LP:GetAttribute("CurrentLocation") == "Underwater City"
            and LP:DistanceFromCharacter(targetPos) >= 3000 then
            requestEntrance(Vector3.new(3864, 6, -1926))
            return
        end
        waypoints = {
            Vector3.new(61163, 11, 1819),
            Vector3.new(-4650, 872, -1775),
            Vector3.new(-7900, 5578, -520),
        }
    else
        return
    end
    local bestI, bestD = 1, math.huge
    for i, wp in ipairs(waypoints) do
        local d = (targetPos - wp).Magnitude
        if d < bestD then bestD, bestI = d, i end
    end
    local dist = LP:DistanceFromCharacter(targetPos)
    if bestD < dist and dist >= 1500 then
        requestEntrance(waypoints[bestI])
        task.wait(0.4)
    end
end

local function tween(cf, speed, high)
    speed = speed or 280
    if speed > 280 and speed < 1e8 then speed = 280 end
    if Hub.Flags.FastFarm then speed = math.min(speed + 40, 320) end

    BindCharacter(LP.Character)
    while not Character or not Character.PrimaryPart or not Character:FindFirstChildOfClass("Humanoid") do
        task.wait()
        BindCharacter(LP.Character)
    end
    if Humanoid then Humanoid.Sit = false end

    if typeof(cf) == "Vector3" then cf = CFrame.new(cf) end
    local root = Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart
    if not root then return end

    smartTween(cf.Position)

    local pos = cf.Position + Vector3.new(0, high or 0, 0)
    local rot = root.CFrame - root.Position
    local target = CFrame.new(pos) * rot
    local distance = (root.Position - target.Position).Magnitude

    if distance <= 12 then
        StopTween()
        root.CFrame = target
        return nil
    end
    if Hub.Flags.BypassTP and distance > 2500 then
        StopTween()
        root.CFrame = target
        return nil
    end

    local time = distance / math.max(speed, 50)
    local info = TweenInfo.new(time, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    StopTween()
    currentTween = TweenService:Create(root, info, { CFrame = target })
    currentTween:Play()
    return currentTween
end

local function TweenTo(cf, speed)
    return tween(cf, speed or (Hub.Flags.TweenSpeed or 280), 0)
end

--------------------------------------------------------------------
-- Noclip + NoFall (Lotus)
--------------------------------------------------------------------
RunService.Stepped:Connect(function()
    if not Hub.Flags.BringEnemy and not Hub.Flags.AutoFarmLevel and not Hub.Flags.AutoFarmNearest
        and not Hub.Flags.AttackNoCD and not Hub.Flags.NoclipManual then
        return
    end
    pcall(function()
        if Character then
            for _, child in ipairs(Character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide then
                    child.CanCollide = false
                end
            end
        end
    end)
end)

task.spawn(function()
    while true do
        pcall(function()
            BindCharacter(LP.Character)
            if HRP and not HRP:FindFirstChild("NoFall") then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "NoFall"
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.zero
                bv.P = 1000
                bv.Parent = HRP
            end
        end)
        task.wait(0.5)
    end
end)

-- Dodge (Lotus)
task.spawn(function()
    while true do
        pcall(function()
            if Character and Character.PrimaryPart and Humanoid and Humanoid.Health > 0 then
                CommE_("Dodge", nil, 30, true, workspace:GetServerTimeNow())
            end
        end)
        task.wait(1.5)
    end
end)

--------------------------------------------------------------------
-- Quest system (Lotus — live game modules)
--------------------------------------------------------------------
local QuestController = {
    CurrentQuest = "",
    CurrentQuestName = "",
    CachedQuestData = nil,
}

pcall(function()
    QuestController.CachedQuestData = require(ReplicatedStorage.Quests)
end)

pcall(function()
    ReplicatedStorage.Remotes.QuestUpdate.OnClientEvent:Connect(function(a2)
        if a2 and typeof(a2) == "table" then
            local qname
            for i in pairs(a2.Progress or {}) do
                qname = i
                break
            end
            QuestController.CurrentQuest = qname or ""
            QuestController.CurrentQuestName = a2.InternalQuestName or ""
        else
            QuestController.CurrentQuest = ""
            QuestController.CurrentQuestName = ""
        end
    end)
end)

local function GetQuestData()
    return QuestController.CurrentQuest ~= ""
end

local CACHE_NPC_LIST
pcall(function()
    CACHE_NPC_LIST = require(ReplicatedStorage.GuideModule).Data.NPCList
end)

local function GetBestQuest()
    if not QuestController.CachedQuestData then return end
    local bestLevelReq = -1
    local bestRnq, bestTaskName, bestRidq
    local skip = { BartiloQuest = true, Trainees = true, MarineQuest = true, CitizenQuest = true }
    for rnq, v in pairs(QuestController.CachedQuestData) do
        if skip[tostring(rnq)] then continue end
        for ridq, ct in pairs(v) do
            if ct.LevelReq and ct.LevelReq >= 0 and Level() >= ct.LevelReq then
                for O, taskValue in pairs(ct.Task or {}) do
                    if taskValue > 1 and ct.LevelReq > bestLevelReq then
                        bestLevelReq = ct.LevelReq
                        bestRnq = rnq
                        bestTaskName = tostring(O)
                        bestRidq = ridq
                    end
                end
            end
        end
    end
    return bestLevelReq, bestRnq, bestTaskName, bestRidq
end

local function GetQuest()
    local Lv = Level()
    local msn, nq, idq
    if Lv >= 275 and Lv < 300 then
        nq, msn, idq = "ColosseumQuest", "Toga Warrior", 1
    elseif Lv >= 1450 and PLACE_ID.sea2() then
        nq, msn, idq = "ForgottenQuest", "Water Fighter", 2
    elseif Lv >= 700 and PLACE_ID.sea1() then
        nq, msn, idq = "FountainQuest", "Galley Captain", 2
    else
        local min
        min, nq, msn, idq = GetBestQuest()
    end
    return {
        NameMonster = msn,
        NameQuest = nq,
        ID = idq,
    }
end

local function getQuestPosition()
    if not CACHE_NPC_LIST then return nil end
    local quest = GetQuest()
    if not quest or not quest.NameQuest then return nil end
    for _, v in pairs(CACHE_NPC_LIST) do
        if typeof(v) == "table" then
            for _, x in pairs(v) do
                if x == quest.NameQuest then
                    if quest.NameQuest == "SkyExp1Quest" and Level() >= 450 then
                        return Vector3.new(-7859, 5544, -381)
                    end
                    return v.Position
                end
            end
        end
    end
    return nil
end

local lastTakeQuest = 0
local function takeQuest()
    if (tick() - lastTakeQuest) < 0.75 then return end
    local q = GetQuest()
    if not q or not q.NameQuest then return end
    if not GetQuestData() or QuestController.CurrentQuestName ~= q.NameQuest then
        local questPos = getQuestPosition()
        if questPos then
            local tw = tween(questPos, 350)
            if tw then tw.Completed:Wait() end
            task.wait(0.2)
            CommF_("StartQuest", q.NameQuest, q.ID)
        else
            -- fallback FireComm only
            CommF_("StartQuest", q.NameQuest, q.ID)
        end
    end
    lastTakeQuest = tick()
end

local function GetMonsterName()
    local names = {}
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, v in ipairs(enemies:GetChildren()) do
            if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid")
                and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart")
                and not v.Name:find("Brigade") and not v.Name:find("Boat") then
                if not table.find(names, v.Name) then
                    table.insert(names, v.Name)
                end
            end
        end
    end
    for _, v in ipairs(names) do
        local name = v:gsub(" %pLv%. ?%d+%p", "")
        if QuestController.CurrentQuest == name or QuestController.CurrentQuest:find(name, 1, true) then
            return name
        end
        if v == QuestController.CurrentQuest then return v end
    end
    -- fallback: strip and match NameMonster from GetQuest
    local q = GetQuest()
    if q and q.NameMonster then return q.NameMonster end
    return nil
end

--------------------------------------------------------------------
-- Fallback static quest table (if modules fail)
--------------------------------------------------------------------
local function CheckQuestFallback()
    local Lv = Level()
    local q = { NameMon = "Bandit", QuestName = "BanditQuest1", LevelQuest = 1,
        CFrameQuest = CFrame.new(1059, 15, 1550), CFrameMon = CFrame.new(1045, 27, 1560) }
    if PLACE_ID.sea1() or (not PLACE_ID.sea2() and not PLACE_ID.sea3()) then
        if Lv <= 9 then
            q = { NameMon = "Bandit", QuestName = "BanditQuest1", LevelQuest = 1,
                CFrameQuest = CFrame.new(1059, 15, 1550), CFrameMon = CFrame.new(1045, 27, 1560) }
        elseif Lv <= 14 then
            q = { NameMon = "Monkey", QuestName = "JungleQuest", LevelQuest = 1,
                CFrameQuest = CFrame.new(-1598, 36, 153), CFrameMon = CFrame.new(-1440, 30, 140) }
        elseif Lv <= 29 then
            q = { NameMon = "Gorilla", QuestName = "JungleQuest", LevelQuest = 2,
                CFrameQuest = CFrame.new(-1598, 36, 153), CFrameMon = CFrame.new(-1220, 20, -300) }
        elseif Lv <= 39 then
            q = { NameMon = "Pirate", QuestName = "BuggyQuest1", LevelQuest = 1,
                CFrameQuest = CFrame.new(-1140, 5, 3827), CFrameMon = CFrame.new(-1200, 5, 3900) }
        elseif Lv <= 59 then
            q = { NameMon = "Brute", QuestName = "BuggyQuest1", LevelQuest = 2,
                CFrameQuest = CFrame.new(-1140, 5, 3827), CFrameMon = CFrame.new(-1100, 80, 4100) }
        elseif Lv <= 700 then
            q = { NameMon = "Galley Captain", QuestName = "FountainQuest", LevelQuest = 2,
                CFrameQuest = CFrame.new(5259, 39, 4050), CFrameMon = CFrame.new(5600, 60, 4200) }
        end
    elseif PLACE_ID.sea2() then
        if Lv <= 874 then
            q = { NameMon = "Swan Pirate", QuestName = "Area2Quest", LevelQuest = 1,
                CFrameQuest = CFrame.new(916, 125, 332), CFrameMon = CFrame.new(1000, 130, 300) }
        else
            q = { NameMon = "Water Fighter", QuestName = "ForgottenQuest", LevelQuest = 2,
                CFrameQuest = CFrame.new(-3050, 240, -10250), CFrameMon = CFrame.new(-3385, 239, -10542) }
        end
    else
        q = { NameMon = "Pirate Millionaire", QuestName = "PiratePortQuest", LevelQuest = 1,
            CFrameQuest = CFrame.new(-288, 44, 5576), CFrameMon = CFrame.new(-300, 45, 5600) }
    end
    return q
end

--------------------------------------------------------------------
-- Mob helpers
--------------------------------------------------------------------
local function MobAlive(mob)
    if not mob or not mob.Parent then return false end
    local hum = mob:FindFirstChildOfClass("Humanoid")
    local hrp = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
    return hum and hrp and hum.Health > 0
end

local function FindMobByName(name)
    if not name then return nil end
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    local best, bestD = nil, 1e9
    for _, mob in ipairs(enemies:GetChildren()) do
        if MobAlive(mob) then
            local n = mob.Name
            if n == name or n:find(name, 1, true) or name:find(n:gsub(" %pLv%. ?%d+%p", ""), 1, true) then
                local hrp = mob.HumanoidRootPart or mob.PrimaryPart
                local d = LP:DistanceFromCharacter(hrp.Position)
                if d < bestD then best, bestD = mob, d end
            end
        end
    end
    -- also ReplicatedStorage (despawned bosses)
    for _, mob in ipairs(ReplicatedStorage:GetChildren()) do
        if mob:IsA("Model") and MobAlive(mob) then
            local n = mob.Name
            if n == name or n:find(name, 1, true) then
                return mob
            end
        end
    end
    return best
end

local function GetNearestEnemy(maxDist)
    maxDist = maxDist or 2000
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    local best, bestD = nil, maxDist
    for _, mob in ipairs(enemies:GetChildren()) do
        if MobAlive(mob) then
            local hrp = mob.HumanoidRootPart or mob.PrimaryPart
            local d = LP:DistanceFromCharacter(hrp.Position)
            if d < bestD then best, bestD = mob, d end
        end
    end
    return best
end

-- Lotus farm stance: above mob + offset
local function FarmOffset(hrp)
    local dist = Hub.Flags.FarmHeightDistance or 20
    return hrp.CFrame * CFrame.new(0, dist, 7)
end

--------------------------------------------------------------------
-- Core farm step (Lotus FarmLevelLogic style)
--------------------------------------------------------------------
local function DoQuestFarmStep()
    BindCharacter(LP.Character)
    if not Character or not HRP then return end

    -- Prefer live quest system
    local monName = GetMonsterName()
    if not monName then
        takeQuest()
        monName = GetMonsterName()
    end

    if not monName and not QuestController.CachedQuestData then
        -- static fallback
        local q = CheckQuestFallback()
        monName = q.NameMon
        if not GetQuestData() then
            tween(q.CFrameQuest, 350)
            task.wait(0.15)
            CommF_("StartQuest", q.QuestName, q.LevelQuest)
        end
    end

    if not monName then
        takeQuest()
        -- go to spawn folder
        pcall(function()
            local folder = ReplicatedStorage:FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder")
            local q = GetQuest()
            if folder and q and q.NameMonster and folder:FindFirstChild(q.NameMonster) then
                tween(folder[q.NameMonster]:GetPivot().Position + Vector3.new(0, 25, 0), 350)
            end
        end)
        return
    end

    local mob = FindMobByName(monName)
    if not mob then
        takeQuest()
        pcall(function()
            local folder = ReplicatedStorage:FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder")
            if folder and folder:FindFirstChild(monName) then
                tween(folder[monName]:GetPivot().Position + Vector3.new(0, 25, 0), 350)
            elseif workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("EnemySpawns") then
                for _, sp in ipairs(workspace._WorldOrigin.EnemySpawns:GetChildren()) do
                    if sp.Name == monName or sp.Name:find(monName, 1, true) then
                        tween(sp:GetPivot().Position + Vector3.new(0, 25, 0), 350)
                        break
                    end
                end
            end
        end)
        return
    end

    local mhrp = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
    if not mhrp then return end

    local target = FarmOffset(mhrp)
    local dist = LP:DistanceFromCharacter(mhrp.Position)
    local tw = tween(target, dist <= 160 and 1e9 or 350)
    if dist <= 50 then
        if Hub.Flags.BringEnemy then
            bringMob(mob.Name, 3)
        end
        equipWeapon()
        FastAttack()
        if Hub.Flags.DoubleAttack or Hub.Flags.FastFarm then
            FastAttack()
        end
        if Hub.Flags.SkillSpam then
            pcall(function()
                for _, key in ipairs({ Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C }) do
                    VIM:SendKeyEvent(true, key, false, game)
                    task.wait(0.02)
                    VIM:SendKeyEvent(false, key, false, game)
                end
            end)
        end
    end
end

local function FarmNearestStep()
    local mob = GetNearestEnemy(1500)
    if not mob then return end
    local mhrp = mob.HumanoidRootPart or mob.PrimaryPart
    local target = FarmOffset(mhrp)
    local dist = LP:DistanceFromCharacter(mhrp.Position)
    tween(target, dist <= 160 and 1e9 or 350)
    if dist <= 50 then
        if Hub.Flags.BringEnemy then bringMob(mob.Name, 3) end
        equipWeapon()
        FastAttack()
    end
end

local function FarmNamedMob(name)
    local mob = FindMobByName(name) or GetNearestEnemy(800)
    if not mob then return end
    local mhrp = mob.HumanoidRootPart or mob.PrimaryPart
    local target = FarmOffset(mhrp)
    local dist = LP:DistanceFromCharacter(mhrp.Position)
    tween(target, dist <= 160 and 1e9 or 350)
    if dist <= 50 then
        if Hub.Flags.BringEnemy then bringMob(mob.Name, 3) end
        equipWeapon()
        FastAttack()
    end
end

local function CollectItemsByName(subs)
    for _, obj in ipairs(workspace:GetChildren()) do
        pcall(function()
            local n = obj.Name:lower()
            for _, s in ipairs(subs) do
                if n:find(tostring(s):lower(), 1, true) then
                    local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    if part then
                        tween(part.CFrame, 350)
                        task.wait(0.15)
                    end
                end
            end
        end)
    end
end

--------------------------------------------------------------------
-- Flags + loops
--------------------------------------------------------------------
local function SetFlag(name, val)
    Hub.Flags[name] = val and true or false
end

local function SpawnFlagLoop(flagName, interval, fn)
    task.spawn(function()
        while true do
            local ok, err = pcall(function()
                if Hub.Flags[flagName] then
                    fn()
                    local w = interval or 0.1
                    if Hub.Flags.FastFarm then w = math.max(0.04, w * 0.55) end
                    task.wait(w)
                else
                    task.wait(0.4)
                end
            end)
            if not ok then
                warn("[BFHub] loop", flagName, err)
                task.wait(0.5)
            end
        end
    end)
end

-- continuous FastAttack when AttackNoCD
task.spawn(function()
    local acc = 0
    RunService.Heartbeat:Connect(function(dt)
        acc = acc + dt
        if acc < (Hub.Flags.FastFarm and 0.05 or 0.08) then return end
        acc = 0
        if Hub.Flags.AttackNoCD or Hub.Flags.AutoFarmLevel or Hub.Flags.AutoFarmNearest or Hub.Flags.MobAura then
            pcall(FastAttack)
        end
    end)
end)

SpawnFlagLoop("AutoFarmLevel", 0.08, DoQuestFarmStep)
SpawnFlagLoop("AutoFarmNearest", 0.06, FarmNearestStep)
SpawnFlagLoop("AcceptQuests", 0.6, function()
    takeQuest()
end)
SpawnFlagLoop("AutoFarmChest", 0.5, function()
    CollectItemsByName({ "chest", "Chest" })
end)
SpawnFlagLoop("AutoFarmBones", 0.5, function()
    for _, n in ipairs({ "Reborn Skeleton", "Living Zombie", "Demonic Soul", "Posessed Mummy" }) do
        if FindMobByName(n) then FarmNamedMob(n) return end
    end
    tween(CFrame.new(-9515, 164, 5786), 350)
end)
SpawnFlagLoop("MobAura", 0.08, function()
    local mob = GetNearestEnemy(Hub.Flags.MobAuraDistance or 80)
    if mob then
        equipWeapon()
        FastAttack()
        if Hub.Flags.BringEnemy then bringMob(mob.Name, 3) end
    end
end)
SpawnFlagLoop("AutoAllBoss", 0.15, function()
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return end
    for _, mob in ipairs(enemies:GetChildren()) do
        if MobAlive(mob) then
            local hum = mob:FindFirstChildOfClass("Humanoid")
            if hum and hum.MaxHealth >= 30000 then
                FarmNamedMob(mob.Name)
                return
            end
        end
    end
end)

for _, pair in ipairs({
    { "AutoCakePrince", "Cake Prince" },
    { "AutoDarkbeard", "Darkbeard" },
    { "AutoSoulReaper", "Soul Reaper" },
    { "AutoDonSwan", "Don Swan" },
    { "AutoEliteHunter", "Diablo" },
}) do
    SpawnFlagLoop(pair[1], 0.2, function() FarmNamedMob(pair[2]) end)
end

SpawnFlagLoop("MasterySword", 0.1, function() equipWeapon("Sword") FarmNearestStep() end)
SpawnFlagLoop("MasteryFruit", 0.1, function() equipWeapon("Blox Fruit") FarmNearestStep() end)
SpawnFlagLoop("MasteryGun", 0.1, function() equipWeapon("Gun") FarmNearestStep() end)

for _, sea in ipairs({ "Terror Shark", "Sea Beast", "Leviathan", "Shark", "Piranha" }) do
    local flag = "Auto" .. sea:gsub(" ", "")
    SpawnFlagLoop(flag, 0.25, function() FarmNamedMob(sea) end)
end

SpawnFlagLoop("AutoCollectFruit", 0.7, function() CollectItemsByName({ "Fruit" }) end)
SpawnFlagLoop("AutoStoreFruit", 1.2, function()
    for _, container in ipairs({ LP.Backpack, Character }) do
        if container then
            for _, t in ipairs(container:GetChildren()) do
                if t:IsA("Tool") and t.Name:find("Fruit") then
                    local ori = t:GetAttribute("OriginalName") or t.Name
                    CommF_("StoreFruit", ori, t)
                end
            end
        end
    end
end)

SpawnFlagLoop("AutoBuso", 1.0, function()
    if Character and not Character:FindFirstChild("HasBuso") then
        CommF_("Buso")
    end
    if not CollectionService:HasTag(Character, "Buso") then
        CommF_("BuyHaki", "Buso")
    end
end)

for _, style in ipairs({
    "Superhuman", "Godhuman", "DeathStep", "SharkmanKarate",
    "ElectricClaw", "DragonTalon", "SanguineArt",
}) do
    SpawnFlagLoop("Buy" .. style, 3.0, function()
        CommF_("Buy" .. style, true)
        CommF_("Buy" .. style)
    end)
end

SpawnFlagLoop("AutoStartRaid", 2.0, function()
    CommF_("RaidsNpc", "Select", "Dark")
end)
SpawnFlagLoop("AutoCompleteRaid", 0.15, FarmNearestStep)

SpawnFlagLoop("AntiAFK", 30, function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

SpawnFlagLoop("FullBright", 2.0, function()
    pcall(function()
        local L = game:GetService("Lighting")
        L.Brightness = 2
        L.ClockTime = 14
        L.FogEnd = 1e6
        L.GlobalShadows = false
    end)
end)

--------------------------------------------------------------------
-- Island TP
--------------------------------------------------------------------
local IslandCFrames = {
    ["Pirate Starter"] = CFrame.new(979.8, 16.5, 1429.0),
    ["Marine Starter"] = CFrame.new(-2566.4, 6.9, 2045.3),
    ["Jungle"] = CFrame.new(-1610, 37, 149),
    ["Pirate Village"] = CFrame.new(-1181, 5, 3803),
    ["Desert"] = CFrame.new(1095, 6, 4374),
    ["Frozen Village"] = CFrame.new(1140, 7, -1167),
    ["Skylands"] = CFrame.new(-4600, 850, -1900),
    ["Prison"] = CFrame.new(4850, 5, 735),
    ["Colosseum"] = CFrame.new(-1576, 7, -2983),
    ["Underwater City"] = CFrame.new(61122, 18, 1567),
    ["Fountain City"] = CFrame.new(5250, 38, 4050),
    ["Kingdom of Rose"] = CFrame.new(-200, 73, 1200),
    ["Cafe"] = CFrame.new(-380, 73, 300),
    ["Green Zone"] = CFrame.new(-2245, 73, -2800),
    ["Graveyard"] = CFrame.new(-5494, 48, -795),
    ["Snow Mountain"] = CFrame.new(605, 401, -5371),
    ["Hot and Cold"] = CFrame.new(-5900, 16, -5100),
    ["Cursed Ship"] = CFrame.new(923, 125, 32865),
    ["Ice Castle"] = CFrame.new(5500, 40, -6200),
    ["Forgotten Island"] = CFrame.new(-3050, 240, -10250),
    ["Port Town"] = CFrame.new(-226, 20, 5538),
    ["Hydra Island"] = CFrame.new(5291, 1005, 393),
    ["Great Tree"] = CFrame.new(2681, 1682, -7191),
    ["Floating Turtle"] = CFrame.new(-13274, 531, -7579),
    ["Castle on the Sea"] = CFrame.new(-5083, 314, -3175),
    ["Haunted Castle"] = CFrame.new(-9515, 164, 5786),
    ["Tiki Outpost"] = CFrame.new(-16218, 9, 445),
}

local function TeleportToIsland(name)
    local cf = IslandCFrames[name]
    if not cf then return end
    if name == "Castle on the Sea" then
        requestEntrance(Vector3.new(-5000, 350, -3035))
        task.wait(0.3)
    elseif name == "Hydra Island" then
        requestEntrance(Vector3.new(5700, 1015, -215))
        task.wait(0.3)
    elseif name == "Underwater City" then
        requestEntrance(Vector3.new(61163, 11, 1819))
        task.wait(0.3)
    end
    tween(cf, 350)
end

--------------------------------------------------------------------
-- ESP light
--------------------------------------------------------------------
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "BFHubESP"
pcall(function() ESPFolder.Parent = game:GetService("CoreGui") end)

local function makeBillboard(adornee, text, color)
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 120, 0, 28)
    bb.AlwaysOnTop = true
    bb.Adornee = adornee
    bb.Parent = ESPFolder
    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.Text = text
    tl.TextColor3 = color or Color3.new(1, 1, 1)
    tl.TextStrokeTransparency = 0.4
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 12
    tl.Parent = bb
end

SpawnFlagLoop("ESPPlayers", 2.0, function()
    ESPFolder:ClearAllChildren()
    if not Hub.Flags.ESPPlayers then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            makeBillboard(plr.Character.HumanoidRootPart, plr.Name, Color3.fromRGB(0, 200, 255))
        end
    end
end)

--------------------------------------------------------------------
-- Fluent UI
--------------------------------------------------------------------
local Fluent
local fluentUrls = {
    "https://cdn.jsdelivr.net/gh/dawid-scripts/Fluent@master/src/init.lua",
    "https://raw.githubusercontent.com/dawid-scripts/Fluent/master/src/init.lua",
}
do
    local src = raceHttpGet(fluentUrls, 3.5)
    if src then
        local ok, lib = pcall(function() return loadstring(src)() end)
        if ok then Fluent = lib end
    end
end

local Window, Tabs = nil, {}

if Fluent then
    pcall(function()
        Window = Fluent:CreateWindow({
            Title = "BF Full Hub  " .. Hub.Version,
            SubTitle = "Axion · Lotus methods · No Key",
            TabWidth = 150,
            Size = UDim2.fromOffset(560, 420),
            Acrylic = false,
            Theme = "Dark",
            MinimizeKey = Enum.KeyCode.LeftControl,
        })
        Hub.Window = Window
    end)
end

if not Window then
    notify("BF Hub", "Fluent failed — flags still work via getgenv().BFHub.Flags", 5)
    getgenv().BFHub_SetFlag = SetFlag
else
    local function addTab(name)
        local ok, tab = pcall(function() return Window:AddTab({ Title = name }) end)
        if ok then Tabs[name] = tab end
        return Tabs[name]
    end

    local Main = addTab("Main")
    local Farm = addTab("Auto Farm")
    local Mastery = addTab("Mastery")
    local Bosses = addTab("Bosses")
    local Raids = addTab("Raids")
    local Quests = addTab("Quests")
    local Sea = addTab("Sea Events")
    local Fruits = addTab("Fruits")
    local Race = addTab("Race / Haki")
    local TP = addTab("Teleport")
    local ESP = addTab("ESP")
    local Combat = addTab("Combat")
    local Misc = addTab("Misc")

    local function T(tab, title, flag, default)
        if not tab then return end
        pcall(function()
            tab:AddToggle(flag or title, {
                Title = title,
                Default = default or false,
                Callback = function(v) SetFlag(flag or title, v) end,
            })
            if default then SetFlag(flag or title, true) end
        end)
    end
    local function S(tab, title)
        if tab then pcall(function() tab:AddSection(title) end) end
    end
    local function B(tab, title, fn)
        if tab then pcall(function() tab:AddButton({ Title = title, Callback = function() pcall(fn) end }) end) end
    end
    local function Slider(tab, title, flag, min, max, default)
        if not tab then return end
        pcall(function()
            tab:AddSlider(flag, {
                Title = title, Min = min, Max = max, Default = default,
                Callback = function(v) Hub.Flags[flag] = v end,
            })
            Hub.Flags[flag] = default
        end)
    end

    S(Main, "Quick start")
    pcall(function()
        Main:AddParagraph({
            Title = "Methods",
            Content = "FastAttack Lotus · Quest live modules · smartTween · bringMob\nBật Auto Farm Level để chạy",
        })
    end)
    T(Main, "Auto Farm Level", "AutoFarmLevel", false)
    T(Main, "Bring Enemy", "BringEnemy", true)
    T(Main, "Attack No CD", "AttackNoCD", true)
    T(Main, "Fast Farm", "FastFarm", true)
    T(Main, "Skill Spam", "SkillSpam", true)

    S(Farm, "Level")
    T(Farm, "Auto Farm Level (Quest + Bring)", "AutoFarmLevel", false)
    T(Farm, "Auto Farm Nearest", "AutoFarmNearest", false)
    T(Farm, "Bring Enemy", "BringEnemy", true)
    T(Farm, "Fast Farm", "FastFarm", true)
    T(Farm, "Bypass TP", "BypassTP", false)
    T(Farm, "Double Attack", "DoubleAttack", true)
    Slider(Farm, "Tween Speed", "TweenSpeed", 150, 350, 280)
    Slider(Farm, "Farm Height", "FarmHeightDistance", 10, 40, 20)
    S(Farm, "Other")
    T(Farm, "Auto Chest", "AutoFarmChest")
    T(Farm, "Auto Bones", "AutoFarmBones")
    T(Farm, "Mob Aura", "MobAura")
    Slider(Farm, "Aura Distance", "MobAuraDistance", 20, 200, 80)

    T(Mastery, "Sword Mastery", "MasterySword")
    T(Mastery, "Fruit Mastery", "MasteryFruit")
    T(Mastery, "Gun Mastery", "MasteryGun")

    T(Bosses, "Auto All Boss", "AutoAllBoss")
    T(Bosses, "Cake Prince", "AutoCakePrince")
    T(Bosses, "Darkbeard", "AutoDarkbeard")
    T(Bosses, "Soul Reaper", "AutoSoulReaper")
    T(Bosses, "Don Swan", "AutoDonSwan")
    T(Bosses, "Elite (Diablo)", "AutoEliteHunter")

    T(Raids, "Auto Start Raid", "AutoStartRaid")
    T(Raids, "Auto Complete Raid", "AutoCompleteRaid")

    T(Quests, "Accept Quests", "AcceptQuests")
    T(Quests, "Auto Farm Level", "AutoFarmLevel")

    T(Sea, "Terror Shark", "AutoTerrorShark")
    T(Sea, "Sea Beast", "AutoSeaBeast")
    T(Sea, "Leviathan", "AutoLeviathan")
    T(Sea, "Shark", "AutoShark")
    T(Sea, "Piranha", "AutoPiranha")

    T(Fruits, "Collect Fruit", "AutoCollectFruit")
    T(Fruits, "Store Fruit", "AutoStoreFruit")

    T(Race, "Auto Buso", "AutoBuso", true)
    T(Race, "Buy Superhuman", "BuySuperhuman")
    T(Race, "Buy Godhuman", "BuyGodhuman")
    T(Race, "Buy Death Step", "BuyDeathStep")
    T(Race, "Buy Sharkman", "BuySharkmanKarate")
    T(Race, "Buy Electric Claw", "BuyElectricClaw")
    T(Race, "Buy Dragon Talon", "BuyDragonTalon")

    S(TP, "Islands")
    pcall(function()
        local names = {}
        for n in pairs(IslandCFrames) do table.insert(names, n) end
        table.sort(names)
        TP:AddDropdown("IslandTP", { Title = "Select Island", Values = names, Multi = false, Default = 1 })
        B(TP, "Teleport", function()
            local opt = Fluent.Options and Fluent.Options.IslandTP
            local val = opt and (opt.Value or opt.Selected) or names[1]
            if type(val) == "table" then val = val[1] end
            TeleportToIsland(tostring(val))
        end)
    end)

    T(ESP, "Player ESP", "ESPPlayers")

    T(Combat, "Attack No CD", "AttackNoCD", true)
    T(Combat, "Skill Spam", "SkillSpam", true)
    T(Combat, "Bring Enemy", "BringEnemy", true)
    T(Combat, "Noclip manual", "NoclipManual")

    T(Misc, "Anti AFK", "AntiAFK", true)
    T(Misc, "Full Bright", "FullBright")
    B(Misc, "Server Hop", function()
        pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
    end)
    B(Misc, "Rejoin", function()
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end)
    end)
    B(Misc, "Destroy Hub", function()
        pcall(function() if Window then Window:Destroy() end end)
        getgenv().BFHub = nil
    end)

    pcall(function() Window:SelectTab(1) end)
    notify("BF Hub", "v" .. Hub.Version .. " · Lotus methods loaded", 4)
end

print("[BFHub]", Hub.Version, "ready")
