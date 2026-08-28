-- // ============================================================
-- // AXIOM BLOX FRUITS | Full Rebuild from OpenSource
-- // Cleaner, optimized, fully structured
-- // ============================================================

Settings = Settings or {}

-- // Services
local Players          = game:GetService("Players")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local TeleportService  = game:GetService("TeleportService")
local CollectionService= game:GetService("CollectionService")
local HttpService      = game:GetService("HttpService")
local VirtualUser      = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

-- // Player refs
local Plr         = Players.LocalPlayer
local PlaceId     = game.PlaceId
local JobId       = game.JobId

-- // World detection
local World1, World2, World3 = false, false, false
if PlaceId == 2753915549  or PlaceId == 85211729168715  then World1 = true
elseif PlaceId == 4442272183 or PlaceId == 79091703265657  then World2 = true
elseif PlaceId == 7449423635 or PlaceId == 100117331123089 then World3 = true
end

-- // Global state
_G.AutoFarm         = false
_G.AutoNear         = false
_G.ESPPlayer        = true
_G.ChestESP         = true
_G.DevilFruitESP    = true
_G.FlowerESP        = true
_G.RealFruitESP     = true
_G.IslandESP        = true
_G.MobESP           = true
_G.SeaESP           = true
_G.NpcESP           = false
_G.MirageESP        = false
_G.SelectWeapon     = "Melee"
_G.SelectMaterial   = ""
_G.UseSkill         = false
_G.AutoRaidPirate   = false
_G.AutoFactory      = false
_G.FarmDaiBan       = false
_G.FarmBone         = false
_G.FarmCake         = false
_G.Hallow           = false
_G.Rdbone           = false
_G.Pray             = false
_G.Trylux           = false
_G.AutoRejoin30m    = false
_G.SafeMode         = false
_G.AutoPlayerHunter = false
_G.Fast_Delay       = 0
_G.Farm8Binhs       = false
_G.AutoValentineGacha = false

local StartBring    = false
local MonFarm       = ""
local PosMon        = CFrame.new()
local FarmPos       = CFrame.new()
local NeedAttacking = false
local BypassTP      = true
local NoClip        = false
local v391          = false
local CurrentTween  = nil
local TravelingSubmerged = false
local SUBMERGED_Y   = -1400
local SUB_NPC       = CFrame.new(-16246.041, 38.48, 1376.539)

-- // Quest vars
local Mon, NameMon, NameQuest, LevelQuest       = "","","",1
local CFrameQuest, CFrameMon                    = CFrame.new(), CFrame.new()
local MonNew, NameMonNew, NameQuestNew, LevelQuestNew = "","","",1
local CFrameQuestNew, CFrameMonNew              = CFrame.new(), CFrame.new()
local SelectMonster = ""
local MMon, MPos, SP = "","",""

-- // Anti AFK
Plr.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- // Hook death/respawn to do nothing (prevent death screen)
pcall(function()
    hookfunction(require(ReplicatedStorage.Effect.Container.Death), function() end)
    hookfunction(require(ReplicatedStorage.Effect.Container.Respawn), function() end)
end)

-- ============================================================
-- // UTILITY FUNCTIONS
-- ============================================================

local function isnil(v) return v == nil end
local function rnd(v) return math.floor(tonumber(v) + 0.5) end
local function HRP() return Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart") end
local function IsAlive()
    local c = Plr.Character
    return c and c:FindFirstChildOfClass("Humanoid") and c.Humanoid.Health > 0
end
local function IsInSubmerged()
    local h = HRP(); return h and h.Position.Y < SUBMERGED_Y
end

function AutoHaki()
    local c = Plr.Character
    if c and not c:FindFirstChild("HasBuso") then
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso") end)
    end
end

function EquipWeapon(name)
    if not name then return end
    pcall(function()
        local tool = Plr.Backpack:FindFirstChild(name)
        if tool then Plr.Character.Humanoid:EquipTool(tool) end
    end)
end

function UnEquipWeapon(name)
    if not name then return end
    pcall(function()
        local tool = Plr.Character:FindFirstChild(name)
        if tool then
            _G.NotAutoEquip = true
            task.wait(0.5)
            tool.Parent = Plr.Backpack
            task.wait(0.1)
            _G.NotAutoEquip = false
        end
    end)
end

function FindWeapon(wType)
    for _, t in ipairs(Plr.Backpack:GetChildren()) do
        if t:IsA("Tool") then
            if wType == "Melee" and (t.ToolTip == "Melee" or t.Name == "Combat") then return t.Name end
            if wType == "Sword" and t.ToolTip == "Sword" then return t.Name end
            if wType == "Gun"   and t.ToolTip == "Gun"   then return t.Name end
            if wType == "Fruit" and t.ToolTip == "Blox Fruit" then return t.Name end
        end
    end
    return nil
end

function AttackAllSkills()
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        local function Skill(k)
            VIM:SendKeyEvent(true, Enum.KeyCode[k], false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, Enum.KeyCode[k], false, game)
        end
        local function Click()
            VIM:SendMouseButtonEvent(0,0,0,true,game,1)
            task.wait(0.05)
            VIM:SendMouseButtonEvent(0,0,0,false,game,1)
        end
        for _, wType in ipairs({"Melee","Sword","Fruit","Gun"}) do
            local w = FindWeapon(wType)
            if w then
                EquipWeapon(w)
                Skill("Z"); Skill("X")
                if wType == "Melee" or wType == "Fruit" then Skill("C") end
                if wType == "Fruit" then Skill("F") end
                Click()
            end
        end
    end)
end

function StopTween(state)
    pcall(function()
        local c = Plr.Character; if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart"); if not h then return end
        if not state then
            _G.StopTween = true
            h.AssemblyLinearVelocity  = Vector3.zero
            h.AssemblyAngularVelocity = Vector3.zero
            for _, obj in pairs(h:GetChildren()) do
                if obj:IsA("BodyVelocity") or obj:IsA("BodyGyro")
                or obj:IsA("BodyPosition") or obj:IsA("AlignPosition")
                or obj:IsA("AlignOrientation") then obj:Destroy() end
            end
            if h:FindFirstChild("BodyClip") then h.BodyClip:Destroy() end
            if c:FindFirstChild("Block")    then c.Block:Destroy()    end
        end
    end)
end

function enableNoclip()
    pcall(function()
        local h = HRP()
        if h and not h:FindFirstChild("BodyClip") then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "BodyClip"; bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.Velocity = Vector3.zero; bv.Parent = h
        end
    end)
end
function disableNoclip()
    pcall(function()
        local h = HRP()
        if h and h:FindFirstChild("BodyClip") then h.BodyClip:Destroy() end
    end)
end
function disableCollisions()
    pcall(function()
        for _, p in pairs(Plr.Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end

-- // Noclip loop
spawn(function()
    while task.wait(0.2) do
        pcall(function()
            if _G.AutoFarm or _G.AutoNear or _G.FarmDaiBan or _G.FarmBone or _G.FarmCake then
                enableNoclip(); disableCollisions()
            else
                disableNoclip()
            end
        end)
    end
end)

-- // requestEntrance helper (for teleporters in game)
local function CheckNearestTeleporter(cf)
    local pos = cf.Position
    local tps = {}
    if PlaceId == 2753915549 then
        tps = {
            Sky3 = Vector3.new(-7894,5547,-380),
            UnderWater = Vector3.new(61163,11,1819),
            ["Pirate Village"] = Vector3.new(-1242,4.8,3901),
        }
    elseif PlaceId == 4442272183 then
        tps = {
            ["Swan Mansion"] = Vector3.new(-390,332,673),
            ["Cursed Ship"]  = Vector3.new(923,126,32852),
            ["Zombie Island"]= Vector3.new(-6509,83,-133),
        }
    elseif PlaceId == 7449423635 then
        tps = {
            ["Floating Turtle"] = Vector3.new(-12462,375,-7552),
            ["Hydra Island"]    = Vector3.new(5657,1013,-335),
            ["Temple of Time"]  = Vector3.new(28286,14897,103),
        }
    end
    local best, bestDist = nil, math.huge
    for _, v in pairs(tps) do
        local d = (v - pos).Magnitude
        if d < bestDist then bestDist = d; best = v end
    end
    if best and bestDist <= (pos - (HRP() and HRP().Position or pos)).Magnitude then
        return best
    end
end

local function requestEntrance(v)
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", v)
        local h = HRP(); if h then h.CFrame = h.CFrame + Vector3.new(0,50,0) end
        task.wait(0.5)
    end)
end

function stopTeleport()
    v391 = false
    pcall(function()
        if Plr.Character:FindFirstChild("PartTele") then
            Plr.Character.PartTele:Destroy()
        end
    end)
end

function topos(cf)
    pcall(function()
        if not IsAlive() then return end
        local h = HRP(); if not h then return end
        local dist = (cf.Position - h.Position).Magnitude
        local tp = CheckNearestTeleporter(cf)
        if tp then requestEntrance(tp) end
        if Plr.Character:FindFirstChild("PartTele") then
            Plr.Character.PartTele:Destroy()
        end
        local part = Instance.new("Part", Plr.Character)
        part.Size = Vector3.new(10,1,10)
        part.Name = "PartTele"
        part.Anchored = true
        part.Transparency = 1
        part.CanCollide = true
        part.CFrame = h.CFrame
        part:GetPropertyChangedSignal("CFrame"):Connect(function()
            if not v391 then return end
            task.wait()
            if Plr.Character and HRP() then HRP().CFrame = part.CFrame end
        end)
        v391 = true
        local tw = TweenService:Create(part,
            TweenInfo.new(dist/360, Enum.EasingStyle.Linear), {CFrame = cf})
        tw:Play()
        tw.Completed:Connect(function(s)
            if s == Enum.PlaybackState.Completed then
                if Plr.Character:FindFirstChild("PartTele") then
                    Plr.Character.PartTele:Destroy()
                end
                v391 = false
            end
        end)
    end)
end

function TP1(cf) topos(cf) end

-- Tween movement (faster)
function TweenTo(cf)
    if not _G.AutoFarm then return end
    local h = HRP(); if not h then return end
    if CurrentTween then pcall(function() CurrentTween:Cancel() end) end
    local dist  = (h.Position - cf.Position).Magnitude
    local speed = 300
    CurrentTween = TweenService:Create(h,
        TweenInfo.new(dist/speed, Enum.EasingStyle.Linear), {CFrame = cf})
    CurrentTween:Play()
    while _G.AutoFarm and CurrentTween
    and CurrentTween.PlaybackState == Enum.PlaybackState.Playing do
        task.wait()
    end
    if CurrentTween then pcall(function() CurrentTween:Cancel() end) end
    CurrentTween = nil
end

-- Bring mob to player
function Bring(name, cf)
    pcall(function()
        for _, mob in pairs(workspace.Enemies:GetChildren()) do
            if mob.Name == name and mob:FindFirstChild("HumanoidRootPart") then
                mob.HumanoidRootPart.CFrame = cf
            end
        end
    end)
end

-- BTP (Bypass TP)
function BTP(cf)
    pcall(function()
        local h = HRP(); if not h then return end
        for _ = 1, 10 do
            h.CFrame = cf
            task.wait(0.05)
        end
    end)
end

-- Respawn fix
spawn(function()
    while task.wait() do
        pcall(function()
            local c = Plr.Character
            local h = c and c:FindFirstChild("HumanoidRootPart")
            if c and h and c:FindFirstChild("Block")
            and (c.Humanoid.Health <= 0 or not h) then
                c.Block:Destroy()
            end
        end)
    end
end)

-- Auto re-stop teleport if stuck
spawn(function()
    while task.wait() do
        pcall(function()
            if not v391 then stopTeleport() end
        end)
    end
end)

-- ============================================================
-- // WEAPON AUTO-SELECT LOOP
-- ============================================================
task.spawn(function()
    while task.wait() do
        pcall(function()
            if _G.SelectWeapon == "Sword" then
                for _, t in pairs(Plr.Backpack:GetChildren()) do
                    if t:IsA("Tool") and t.ToolTip == "Sword" then _G.SelectWeapon = t.Name end
                end
            elseif _G.SelectWeapon == "Gun" then
                for _, t in pairs(Plr.Backpack:GetChildren()) do
                    if t:IsA("Tool") and t.ToolTip == "Gun" then _G.SelectWeapon = t.Name end
                end
            elseif _G.SelectWeapon == "Fruit" or _G.SelectWeapon == "Blox Fruit" then
                for _, t in pairs(Plr.Backpack:GetChildren()) do
                    if t:IsA("Tool") and t.ToolTip == "Blox Fruit" then _G.SelectWeapon = t.Name end
                end
            else
                for _, t in pairs(Plr.Backpack:GetChildren()) do
                    if t:IsA("Tool") and t.ToolTip == "Melee" then _G.SelectWeapon = t.Name end
                end
            end
        end)
    end
end)

-- ============================================================
-- // MATERIAL MONSTER (Material Farm)
-- ============================================================
function MaterialMon()
    local m = _G.SelectMaterial
    if m == "Angel Wings"      then MMon="Royal Soldier";  MPos=CFrame.new(-7759,5606,-1862); SP="SkyArea2"
    elseif m == "Mystic Droplet"   then MMon="Water Fighter";  MPos=CFrame.new(-3331,239,-10553);  SP="ForgottenIsland"
    elseif m == "Vampire Fang"     then MMon="Vampire";         MPos=CFrame.new(-6132,9,-1466);     SP="Graveyard"
    elseif m == "Gunpowder"        then MMon="Pistol Billionaire"; MPos=CFrame.new(-185,84,6103);  SP="Mansion"
    elseif m == "Conjured Cocoa"   then MMon="Chocolate Bar Battler"; MPos=CFrame.new(582,25,-12550); SP="Chocolate"
    elseif m == "Mini Tusk"        then MMon="Mythological Pirate"; MPos=CFrame.new(-13456,469,-7039); SP="BigMansion"
    elseif m == "Radiactive Material" then
        if World1 then MMon="Fishman Warrior"; MPos=CFrame.new(60943,17,1744); SP="Underwater City"
        elseif World3 then MMon="Fishman Captain"; MPos=CFrame.new(-10828,331,-9049); SP="PineappleTown" end
    elseif m == "Leather + Scrap Metal" then
        if World1 then MMon="Military Soldier"; MPos=CFrame.new(-5565,9,8327); SP="Magma"
        elseif World2 then MMon="Lava Pirate"; MPos=CFrame.new(-5158,14,-4654); SP="CircleIslandFire" end
    elseif m == "Magma Ore" then
        if World1 then MMon="Pirate"; MPos=CFrame.new(-967,13,4034); SP="Pirate"
        elseif World3 then MMon="Pirate Millionaire"; MPos=CFrame.new(-118,55,5649); SP="Default"
        elseif World2 then MMon="Mercenary"; MPos=CFrame.new(-986,72,1088); SP="DressTown" end
    elseif m == "Fish Tail" then MMon="Factory Staff"; MPos=CFrame.new(-105,72,-670); SP="Bar"
    end
end

-- ============================================================
-- // CHECK QUEST (World 1-2-3, Level 1–2599)
-- ============================================================
function CheckQuest()
    local lvl = Plr.Data.Level.Value
    -- World 1
    if World1 then
        if lvl <= 9   or SelectMonster=="Bandit"           then Mon="Bandit";          NameQuest="BanditQuest1";  LevelQuest=1; NameMon="Bandit";           CFrameQuest=CFrame.new(1059,15,1550);   CFrameMon=CFrame.new(1045,27,1560)
        elseif lvl<=14 or SelectMonster=="Monkey"          then Mon="Monkey";          NameQuest="JungleQuest";   LevelQuest=1; NameMon="Monkey";            CFrameQuest=CFrame.new(-1598,35,153);   CFrameMon=CFrame.new(-1448,67,11)
        elseif lvl<=29 or SelectMonster=="Gorilla"         then Mon="Gorilla";         NameQuest="JungleQuest";   LevelQuest=2; NameMon="Gorilla";           CFrameQuest=CFrame.new(-1598,35,153);   CFrameMon=CFrame.new(-1129,40,-525)
        elseif lvl<=39 or SelectMonster=="Pirate"          then Mon="Pirate";          NameQuest="BuggyQuest1";   LevelQuest=1; NameMon="Pirate";            CFrameQuest=CFrame.new(-1141,4,3831);   CFrameMon=CFrame.new(-1103,13,3896)
        elseif lvl<=59 or SelectMonster=="Brute"           then Mon="Brute";           NameQuest="BuggyQuest1";   LevelQuest=2; NameMon="Brute";             CFrameQuest=CFrame.new(-1141,4,3831);   CFrameMon=CFrame.new(-1140,8,4322)
        elseif lvl<=74 or SelectMonster=="Desert Bandit"   then Mon="Desert Bandit";   NameQuest="DesertQuest";   LevelQuest=1; NameMon="Desert Bandit";     CFrameQuest=CFrame.new(894,5,4392);     CFrameMon=CFrame.new(924,6,4481)
        elseif lvl<=89 or SelectMonster=="Desert Officer"  then Mon="Desert Officer";  NameQuest="DesertQuest";   LevelQuest=2; NameMon="Desert Officer";    CFrameQuest=CFrame.new(894,5,4392);     CFrameMon=CFrame.new(1608,8,4371)
        elseif lvl<=99 or SelectMonster=="Snow Bandit"     then Mon="Snow Bandit";     NameQuest="SnowQuest";     LevelQuest=1; NameMon="Snow Bandit";       CFrameQuest=CFrame.new(1389,88,-1298);  CFrameMon=CFrame.new(1354,87,-1393)
        elseif lvl<=119 or SelectMonster=="Snowman"        then Mon="Snowman";         NameQuest="SnowQuest";     LevelQuest=2; NameMon="Snowman";           CFrameQuest=CFrame.new(1389,88,-1298);  CFrameMon=CFrame.new(1201,144,-1550)
        elseif lvl<=149 or SelectMonster=="Chief Petty Officer" then Mon="Chief Petty Officer"; NameQuest="MarineQuest2"; LevelQuest=1; NameMon="Chief Petty Officer"; CFrameQuest=CFrame.new(-5039,27,4324); CFrameMon=CFrame.new(-4881,22,4273)
        elseif lvl<=174 or SelectMonster=="Sky Bandit"     then Mon="Sky Bandit";      NameQuest="SkyQuest";      LevelQuest=1; NameMon="Sky Bandit";        CFrameQuest=CFrame.new(-4839,716,-2619); CFrameMon=CFrame.new(-4953,295,-2899)
        elseif lvl<=189 or SelectMonster=="Dark Master"    then Mon="Dark Master";     NameQuest="SkyQuest";      LevelQuest=2; NameMon="Dark Master";       CFrameQuest=CFrame.new(-4839,716,-2619); CFrameMon=CFrame.new(-5259,391,-2229)
        elseif lvl<=209 or SelectMonster=="Prisoner"       then Mon="Prisoner";        NameQuest="PrisonerQuest"; LevelQuest=1; NameMon="Prisoner";          CFrameQuest=CFrame.new(5308,1,475);     CFrameMon=CFrame.new(5098,0,474)
        elseif lvl<=249 or SelectMonster=="Dangerous Prisoner" then Mon="Dangerous Prisoner"; NameQuest="PrisonerQuest"; LevelQuest=2; NameMon="Dangerous Prisoner"; CFrameQuest=CFrame.new(5308,1,475); CFrameMon=CFrame.new(5654,15,866)
        elseif lvl<=274 or SelectMonster=="Toga Warrior"   then Mon="Toga Warrior";    NameQuest="ColosseumQuest";LevelQuest=1; NameMon="Toga Warrior";      CFrameQuest=CFrame.new(1580,6,-2986);   CFrameMon=CFrame.new(-1820,51,-2740)
        elseif lvl<=299 or SelectMonster=="Gladiator"      then Mon="Gladiator";       NameQuest="ColosseumQuest";LevelQuest=2; NameMon="Gladiator";         CFrameQuest=CFrame.new(1580,6,-2986);   CFrameMon=CFrame.new(1292,56,-3339)
        elseif lvl<=324 or SelectMonster=="Military Soldier" then Mon="Military Soldier"; NameQuest="MagmaQuest"; LevelQuest=1; NameMon="Military Soldier";  CFrameQuest=CFrame.new(-5313,10,8515);  CFrameMon=CFrame.new(-5411,11,8454)
        elseif lvl<=374 or SelectMonster=="Military Spy"   then Mon="Military Spy";    NameQuest="MagmaQuest";    LevelQuest=2; NameMon="Military Spy";      CFrameQuest=CFrame.new(-5313,10,8515);  CFrameMon=CFrame.new(-5882,86,8828)
        elseif lvl<=399 or SelectMonster=="Fishman Warrior" then Mon="Fishman Warrior"; NameQuest="FishmanQuest"; LevelQuest=1; NameMon="Fishman Warrior";   CFrameQuest=CFrame.new(61122,18,1569);  CFrameMon=CFrame.new(60878,18,1543)
        elseif lvl<=449 or SelectMonster=="Fishman Commando" then Mon="Fishman Commando"; NameQuest="FishmanQuest"; LevelQuest=2; NameMon="Fishman Commando"; CFrameQuest=CFrame.new(61163,11,1819); CFrameMon=CFrame.new(61163,11,1819)
        elseif lvl<=474 or SelectMonster=="God's Guard"    then Mon="God's Guard";     NameQuest="SkyExp1Quest";  LevelQuest=1; NameMon="God's Guard";       CFrameQuest=CFrame.new(-4721,843,-1949); CFrameMon=CFrame.new(-4710,845,-1927)
        elseif lvl<=524 or SelectMonster=="Shanda"         then Mon="Shanda";          NameQuest="SkyExp1Quest";  LevelQuest=2; NameMon="Shanda";            CFrameQuest=CFrame.new(-7859,5544,-381); CFrameMon=CFrame.new(-7678,5566,-497)
        elseif lvl<=549 or SelectMonster=="Royal Squad"    then Mon="Royal Squad";     NameQuest="SkyExp2Quest";  LevelQuest=1; NameMon="Royal Squad";       CFrameQuest=CFrame.new(-7906,5634,-1411); CFrameMon=CFrame.new(-7624,5658,-1467)
        elseif lvl<=574 or SelectMonster=="Royal Soldier"  then Mon="Royal Soldier";   NameQuest="SkyExp2Quest";  LevelQuest=2; NameMon="Royal Soldier";     CFrameQuest=CFrame.new(-7906,5634,-1411); CFrameMon=CFrame.new(-7836,5645,-1790)
        elseif lvl<=599 or SelectMonster=="Fishman Commando" then Mon="Fishman Commando"; NameQuest="FishmanQuest"; LevelQuest=2; NameMon="Fishman Commando"; CFrameQuest=CFrame.new(61122,18,1569); CFrameMon=CFrame.new(61921,18,1493)
        else Mon="Fishman Warrior"; NameQuest="FishmanQuest"; LevelQuest=1; NameMon="Fishman Warrior"; CFrameQuest=CFrame.new(61122,18,1569); CFrameMon=CFrame.new(60878,18,1543)
        end

    -- World 2
    elseif World2 then
        if lvl<=699 or SelectMonster=="Raider"             then Mon="Raider";          NameQuest="Area1Quest";    LevelQuest=1; NameMon="Raider";            CFrameQuest=CFrame.new(-429,71,1836);   CFrameMon=CFrame.new(-728,52,2345)
        elseif lvl<=724 or SelectMonster=="Mercenary"      then Mon="Mercenary";       NameQuest="Area1Quest";    LevelQuest=2; NameMon="Mercenary";         CFrameQuest=CFrame.new(-429,71,1836);   CFrameMon=CFrame.new(-1004,80,1424)
        elseif lvl<=774 or SelectMonster=="Swan Pirate"    then Mon="Swan Pirate";     NameQuest="Area2Quest";    LevelQuest=1; NameMon="Swan Pirate";       CFrameQuest=CFrame.new(638,71,918);     CFrameMon=CFrame.new(1068,137,1322)
        elseif lvl<=799 or SelectMonster=="Zombie"         then Mon="Zombie";          NameQuest="ZombieQuest";   LevelQuest=1; NameMon="Zombie";            CFrameQuest=CFrame.new(-5497,47,-795);  CFrameMon=CFrame.new(-5657,78,928)
        elseif lvl<=874 or SelectMonster=="Factory Staff"  then Mon="Factory Staff";   NameQuest="Area2Quest";    LevelQuest=2; NameMon="Factory Staff";     CFrameQuest=CFrame.new(632,73,918);     CFrameMon=CFrame.new(73,86,-27)
        elseif lvl<=899 or SelectMonster=="Marine Lieutenant" then Mon="Marine Lieutenant"; NameQuest="MarineQuest3"; LevelQuest=1; NameMon="Marine Lieutenant"; CFrameQuest=CFrame.new(-2440,71,-3216); CFrameMon=CFrame.new(-2821,75,-3070)
        elseif lvl<=949 or SelectMonster=="Marine Captain" then Mon="Marine Captain";  NameQuest="MarineQuest3";  LevelQuest=2; NameMon="Marine Captain";    CFrameQuest=CFrame.new(-2440,71,-3216); CFrameMon=CFrame.new(-1861,80,-3254)
        elseif lvl<=999 or SelectMonster=="Vampire"        then Mon="Vampire";         NameQuest="ZombieQuest";   LevelQuest=2; NameMon="Vampire";           CFrameQuest=CFrame.new(-5497,47,-795);  CFrameMon=CFrame.new(-5497,32,-1340)
        elseif lvl<=1049 or SelectMonster=="Snow Trooper"  then Mon="Snow Trooper";    NameQuest="SnowMountainQuest"; LevelQuest=1; NameMon="Snow Trooper";  CFrameQuest=CFrame.new(609,400,-5372);  CFrameMon=CFrame.new(549,427,5563)
        elseif lvl<=1099 or SelectMonster=="Winter Warrior" then Mon="Winter Warrior"; NameQuest="SnowMountainQuest"; LevelQuest=2; NameMon="Winter Warrior"; CFrameQuest=CFrame.new(609,400,-5372); CFrameMon=CFrame.new(1142,475,-5199)
        elseif lvl<=1124 or SelectMonster=="Lab Subordinate" then Mon="Lab Subordinate"; NameQuest="IceSideQuest"; LevelQuest=1; NameMon="Lab Subordinate";  CFrameQuest=CFrame.new(-6064,15,-4902); CFrameMon=CFrame.new(-5707,15,-4513)
        elseif lvl<=1174 or SelectMonster=="Horned Warrior" then Mon="Horned Warrior"; NameQuest="IceSideQuest";  LevelQuest=2; NameMon="Horned Warrior";    CFrameQuest=CFrame.new(-6064,15,-4902); CFrameMon=CFrame.new(-6341,15,-5723)
        elseif lvl<=1249 or SelectMonster=="Magma Ninja"   then Mon="Magma Ninja";     NameQuest="FireSideQuest"; LevelQuest=1; NameMon="Magma Ninja";       CFrameQuest=CFrame.new(-5428,15,-5299); CFrameMon=CFrame.new(-5449,76,-5808)
        elseif lvl<=1274 or SelectMonster=="Lava Pirate"   then Mon="Lava Pirate";     NameQuest="FireSideQuest"; LevelQuest=2; NameMon="Lava Pirate";       CFrameQuest=CFrame.new(-5428,15,-5299); CFrameMon=CFrame.new(-5213,49,-4701)
        elseif lvl<=1299 or SelectMonster=="Ship Deckhand" then Mon="Ship Deckhand";   NameQuest="ShipQuest1";    LevelQuest=1; NameMon="Ship Deckhand";     CFrameQuest=CFrame.new(1037,125,32911); CFrameMon=CFrame.new(1212,150,33059)
        elseif lvl<=1324 or SelectMonster=="Ship Steward"  then Mon="Ship Steward";    NameQuest="ShipQuest2";    LevelQuest=1; NameMon="Ship Steward";      CFrameQuest=CFrame.new(968,125,33244);  CFrameMon=CFrame.new(919,129,33436)
        elseif lvl<=1374 or SelectMonster=="Snow Lurker"   then Mon="Snow Lurker";     NameQuest="FrostQuest";    LevelQuest=2; NameMon="Snow Lurker";       CFrameQuest=CFrame.new(5667,26,-6486);  CFrameMon=CFrame.new(5407,69,-6880)
        elseif lvl<=1424 or SelectMonster=="Arctic Warrior" then Mon="Arctic Warrior"; NameQuest="FrostQuest";    LevelQuest=1; NameMon="Arctic Warrior";    CFrameQuest=CFrame.new(5667,26,-6486);  CFrameMon=CFrame.new(5966,24,-6179)
        elseif lvl<=1449 or SelectMonster=="Sea Soldier"   then Mon="Sea Soldier";     NameQuest="ForgottenQuest";LevelQuest=1; NameMon="Sea Soldier";       CFrameQuest=CFrame.new(-3054,235,-10142); CFrameMon=CFrame.new(3028,64,-9775)
        elseif lvl<=1499 or SelectMonster=="Water Fighter" then Mon="Water Fighter";   NameQuest="ForgottenQuest";LevelQuest=2; NameMon="Water Fighter";     CFrameQuest=CFrame.new(-3054,235,-10142); CFrameMon=CFrame.new(3352,285,-10534)
        end

    -- World 3
    elseif World3 then
        if lvl<=1524 or SelectMonster=="Pirate Millionaire" then Mon="Pirate Millionaire"; NameQuest="PiratePortQuest"; LevelQuest=1; NameMon="Pirate Millionaire"; CFrameQuest=CFrame.new(-450,107,5950); CFrameMon=CFrame.new(-245,47,5584)
        elseif lvl<=1574 or SelectMonster=="Pistol Billionaire" then Mon="Pistol Billionaire"; NameQuest="PiratePortQuest"; LevelQuest=2; NameMon="Pistol Billionaire"; CFrameQuest=CFrame.new(-450,107,5950); CFrameMon=CFrame.new(-54,83,5947)
        elseif lvl<=1599 or SelectMonster=="Dragon Crew Warrior" then Mon="Dragon Crew Warrior"; NameQuest="DragonCrewQuest"; LevelQuest=1; NameMon="Dragon Crew Warrior"; CFrameQuest=CFrame.new(6750,127,-711); CFrameMon=CFrame.new(6709,52,-1139)
        elseif lvl<=1624 or SelectMonster=="Dragon Crew Archer"  then Mon="Dragon Crew Archer"; NameQuest="DragonCrewQuest"; LevelQuest=2; NameMon="Dragon Crew Archer"; CFrameQuest=CFrame.new(6750,127,-711);  CFrameMon=CFrame.new(6668,481,329)
        elseif lvl<=1649 or SelectMonster=="Hydra Enforcer" then Mon="Hydra Enforcer"; NameQuest="VenomCrewQuest"; LevelQuest=1; NameMon="Hydra Enforcer"; CFrameQuest=CFrame.new(5206,1004,748); CFrameMon=CFrame.new(4547,1003,334)
        elseif lvl<=1699 or SelectMonster=="Venomous Assailant" then Mon="Venomous Assailant"; NameQuest="VenomCrewQuest"; LevelQuest=2; NameMon="Venomous Assailant"; CFrameQuest=CFrame.new(5206,1004,748); CFrameMon=CFrame.new(4674,1134,996)
        elseif lvl<=1724 or SelectMonster=="Marine Commodore"    then Mon="Marine Commodore"; NameQuest="MarineTreeIsland"; LevelQuest=1; NameMon="Marine Commodore"; CFrameQuest=CFrame.new(2481,228,74); CFrameMon=CFrame.new(2577,75,-7739)
        elseif lvl<=1774 or SelectMonster=="Marine Rear Admiral" then Mon="Marine Rear Admiral"; NameQuest="MarineTreeIsland"; LevelQuest=2; NameMon="Marine Rear Admiral"; CFrameQuest=CFrame.new(2481,228,74); CFrameMon=CFrame.new(3761,123,-6823)
        elseif lvl<=1799 or SelectMonster=="Fishman Raider" then Mon="Fishman Raider"; NameQuest="DeepForestIsland3"; LevelQuest=1; NameMon="Fishman Raider"; CFrameQuest=CFrame.new(-10581,330,-8861); CFrameMon=CFrame.new(-10407,331,-8368)
        elseif lvl<=1824 or SelectMonster=="Fishman Captain" then Mon="Fishman Captain"; NameQuest="DeepForestIsland3"; LevelQuest=2; NameMon="Fishman Captain"; CFrameQuest=CFrame.new(-10581,330,-8861); CFrameMon=CFrame.new(-10994,352,-9002)
        elseif lvl<=1849 or SelectMonster=="Forest Pirate"   then Mon="Forest Pirate"; NameQuest="DeepForestIsland"; LevelQuest=1; NameMon="Forest Pirate"; CFrameQuest=CFrame.new(-13234,331,-7625); CFrameMon=CFrame.new(-13274,332,-7769)
        elseif lvl<=1899 or SelectMonster=="Mythological Pirate" then Mon="Mythological Pirate"; NameQuest="DeepForestIsland"; LevelQuest=2; NameMon="Mythological Pirate"; CFrameQuest=CFrame.new(-13234,331,-7625); CFrameMon=CFrame.new(13680,501,-6991)
        elseif lvl<=1924 or SelectMonster=="Jungle Pirate"   then Mon="Jungle Pirate"; NameQuest="DeepForestIsland2"; LevelQuest=1; NameMon="Jungle Pirate"; CFrameQuest=CFrame.new(-12680,389,-9902); CFrameMon=CFrame.new(-12256,331,-10485)
        elseif lvl<=1974 or SelectMonster=="Musketeer Pirate" then Mon="Musketeer Pirate"; NameQuest="DeepForestIsland2"; LevelQuest=2; NameMon="Musketeer Pirate"; CFrameQuest=CFrame.new(-12680,389,-9902); CFrameMon=CFrame.new(-13457,391,-9859)
        elseif lvl<=1999 or SelectMonster=="Reborn Skeleton" then Mon="Reborn Skeleton"; NameQuest="HauntedQuest1"; LevelQuest=1; NameMon="Reborn Skeleton"; CFrameQuest=CFrame.new(-9479,141,5566); CFrameMon=CFrame.new(-8763,165,6159)
        elseif lvl<=2049 or SelectMonster=="Demonic Soul"    then Mon="Demonic Soul";   NameQuest="HauntedQuest2"; LevelQuest=1; NameMon="Demonic Soul";    CFrameQuest=CFrame.new(-9516,172,6078); CFrameMon=CFrame.new(-9505,172,6158)
        elseif lvl<=2074 or SelectMonster=="Posessed Mummy"  then Mon="Posessed Mummy"; NameQuest="HauntedQuest2"; LevelQuest=2; NameMon="Posessed Mummy"; CFrameQuest=CFrame.new(-9516,172,6078); CFrameMon=CFrame.new(-9582,172,6205)
        elseif lvl<=2124 or SelectMonster=="Peanut President" then Mon="Peanut President"; NameQuest="NutsIslandQuest"; LevelQuest=2; NameMon="Peanut President"; CFrameQuest=CFrame.new(-2104,38,-10194); CFrameMon=CFrame.new(-2143,47,-10029)
        elseif lvl<=2149 or SelectMonster=="Ice Cream Chef"  then Mon="Ice Cream Chef"; NameQuest="IceCreamIslandQuest"; LevelQuest=1; NameMon="Ice Cream Chef"; CFrameQuest=CFrame.new(-820,65,-10965); CFrameMon=CFrame.new(-872,65,-10919)
        elseif lvl<=2199 or SelectMonster=="Ice Cream Commander" then Mon="Ice Cream Commander"; NameQuest="IceCreamIslandQuest"; LevelQuest=2; NameMon="Ice Cream Commander"; CFrameQuest=CFrame.new(-820,65,-10965); CFrameMon=CFrame.new(-558,112,-11299)
        elseif lvl<=2224 or SelectMonster=="Cookie Crafter"  then Mon="Cookie Crafter"; NameQuest="CakeQuest1"; LevelQuest=1; NameMon="Cookie Crafter"; CFrameQuest=CFrame.new(2021,37,-12028); CFrameMon=CFrame.new(2374,37,-12125)
        elseif lvl<=2274 or SelectMonster=="Baking Staff"    then Mon="Baking Staff";   NameQuest="CakeQuest2"; LevelQuest=1; NameMon="Baking Staff";   CFrameQuest=CFrame.new(-1927,37,-12842); CFrameMon=CFrame.new(-1887,77,-12998)
        elseif lvl<=2299 or SelectMonster=="Head Baker"      then Mon="Head Baker";     NameQuest="CakeQuest2"; LevelQuest=2; NameMon="Head Baker";     CFrameQuest=CFrame.new(-1927,37,-12842); CFrameMon=CFrame.new(-2216,82,-12869)
        elseif lvl<=2349 or SelectMonster=="Chocolate Bar Battler" then Mon="Chocolate Bar Battler"; NameQuest="ChocQuest1"; LevelQuest=2; NameMon="Chocolate Bar Battler"; CFrameQuest=CFrame.new(233,29,-12201); CFrameMon=CFrame.new(582,77,-12463)
        elseif lvl<=2374 or SelectMonster=="Sweet Thief"     then Mon="Sweet Thief";    NameQuest="ChocQuest2"; LevelQuest=1; NameMon="Sweet Thief";    CFrameQuest=CFrame.new(150,30,-12774); CFrameMon=CFrame.new(165,76,-12600)
        elseif lvl<=2399 or SelectMonster=="Candy Rebel"     then Mon="Candy Rebel";    NameQuest="ChocQuest2"; LevelQuest=2; NameMon="Candy Rebel";    CFrameQuest=CFrame.new(150,30,-12774); CFrameMon=CFrame.new(134,77,-12876)
        elseif lvl<=2449 or SelectMonster=="Snow Demon"      then Mon="Snow Demon";     NameQuest="CandyQuest1"; LevelQuest=2; NameMon="Snow Demon";    CFrameQuest=CFrame.new(-1150,20,-14446); CFrameMon=CFrame.new(-880,71,-14538)
        elseif lvl<=2474 or SelectMonster=="Isle Outlaw"     then Mon="Isle Outlaw";    NameQuest="TikiQuest1"; LevelQuest=1; NameMon="Isle Outlaw";    CFrameQuest=CFrame.new(-16547,61,-173); CFrameMon=CFrame.new(-16442,116,-264)
        elseif lvl<=2524 or SelectMonster=="Isle Champion"   then Mon="Isle Champion";  NameQuest="TikiQuest2"; LevelQuest=2; NameMon="Isle Champion";  CFrameQuest=CFrame.new(-16539,55,1051); CFrameMon=CFrame.new(-16641,235,1031)
        elseif lvl<=2549 or SelectMonster=="Skull Slayer"    then Mon="Skull Slayer";   NameQuest="TikiQuest3"; LevelQuest=2; NameMon="Skull Slayer";   CFrameQuest=CFrame.new(-16665,104,1579); CFrameMon=CFrame.new(-16855,122,1478)
        else Mon="Serpent Hunter"; NameQuest="TikiQuest3"; LevelQuest=1; NameMon="Serpent Hunter"; CFrameQuest=CFrame.new(-16665,104,1579); CFrameMon=CFrame.new(-16521,106,1488)
        end
    end
end

-- ============================================================
-- // CHECK QUEST NEW (Submerged Island, Level 2600+)
-- ============================================================
function CheckQuestNew()
    local lvl = Plr.Data.Level.Value
    if lvl>=2600 and lvl<=2624 then
        MonNew="Reef Bandit";    LevelQuestNew=1; NameQuestNew="SubmergedQuest1"; NameMonNew="Reef Bandit"
        CFrameQuestNew=CFrame.new(10882,-2086,10034); CFrameMonNew=CFrame.new(10736,-2087,9338)
    elseif lvl>=2650 and lvl<=2674 then
        MonNew="Sea Chanter";   LevelQuestNew=1; NameQuestNew="SubmergedQuest2"; NameMonNew="Sea Chanter"
        CFrameQuestNew=CFrame.new(10882,-2086,10034); CFrameMonNew=CFrame.new(10621,-2087,10102)
    elseif lvl>=2675 and lvl<=2699 then
        MonNew="Ocean Prophet"; LevelQuestNew=2; NameQuestNew="SubmergedQuest2"; NameMonNew="Ocean Prophet"
        CFrameQuestNew=CFrame.new(10882,-2086,10034); CFrameMonNew=CFrame.new(11056,-2001,10117)
    elseif lvl>=2700 and lvl<=2724 then
        MonNew="High Disciple"; LevelQuestNew=1; NameQuestNew="SubmergedQuest3"; NameMonNew="High Disciple"
        CFrameQuestNew=CFrame.new(9636,-1992,9609); CFrameMonNew=CFrame.new(9828,-1940,9693)
    else
        MonNew="Grand Devotee"; LevelQuestNew=2; NameQuestNew="SubmergedQuest3"; NameMonNew="Grand Devotee"
        CFrameQuestNew=CFrame.new(9636,-1992,9609); CFrameMonNew=CFrame.new(9557,-1928,9859)
    end
end

-- ============================================================
-- // GO SUBMERGED
-- ============================================================
function GoSubmerged()
    if not _G.AutoFarm then return end
    if TravelingSubmerged or IsInSubmerged() then return end
    if Plr.Data.Level.Value < 2600 then return end
    TravelingSubmerged = true
    TweenTo(SUB_NPC + Vector3.new(0,60,0))
    if not _G.AutoFarm then TravelingSubmerged=false; return end
    TweenTo(SUB_NPC)
    if not _G.AutoFarm then TravelingSubmerged=false; return end
    pcall(function()
        ReplicatedStorage.Modules.Net["RF/SubmarineWorkerSpeak"]:InvokeServer("TravelToSubmergedIsland")
    end)
    while _G.AutoFarm and not IsInSubmerged() do task.wait(0.5) end
    TravelingSubmerged = false
end

-- ============================================================
-- // MAIN FARM LOOP
-- ============================================================
spawn(function()
    while task.wait() do
        if _G.AutoFarm then
            pcall(function()
                local questGui = Plr.PlayerGui.Main.Quest
                local lvl = Plr.Data.Level.Value

                -- Submerged island (2600+)
                if lvl >= 2600 and World3 then
                    if not IsInSubmerged() then GoSubmerged() end
                    if IsInSubmerged() then
                        CheckQuestNew()
                        if not questGui.Visible then
                            StartBring = false
                            if (HRP().Position - CFrameQuestNew.Position).Magnitude > 20 then
                                TweenTo(CFrameQuestNew)
                            else
                                ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", NameQuestNew, LevelQuestNew)
                            end
                        else
                            local txt = questGui.Container.QuestTitle.Title.Text
                            if not string.find(txt, NameMonNew) then
                                StartBring = false
                                ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest")
                            else
                                for _, mob in pairs(workspace.Enemies:GetChildren()) do
                                    if mob.Name == MonNew
                                    and mob:FindFirstChild("HumanoidRootPart")
                                    and mob:FindFirstChild("Humanoid")
                                    and mob.Humanoid.Health > 0 then
                                        repeat
                                            task.wait()
                                            EquipWeapon(_G.SelectWeapon)
                                            AutoHaki()
                                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
                                            mob.HumanoidRootPart.CanCollide = false
                                            mob.Humanoid.WalkSpeed = 0
                                            mob.HumanoidRootPart.Size = Vector3.new(70,70,70)
                                            StartBring = true
                                            MonFarm = mob.Name
                                            VirtualUser:CaptureController()
                                            VirtualUser:Button1Down(Vector2.new(1280,672))
                                        until not _G.AutoFarm or mob.Humanoid.Health <= 0
                                        or not mob.Parent or not questGui.Visible
                                    end
                                end
                                if not workspace.Enemies:FindFirstChild(MonNew) then
                                    TweenTo(CFrameMonNew); StartBring = false
                                end
                            end
                        end
                        return
                    end
                end

                -- Legacy farm (1–2599)
                local txt = questGui.Container.QuestTitle.Title.Text
                CheckQuest()

                if not string.find(txt, NameMon) then
                    StartBring = false
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest")
                end

                if questGui.Visible then
                    if string.find(txt, "kissed") then
                        -- kissed warrior edge case
                        for _, v in pairs(workspace.Enemies:GetChildren()) do
                            if string.find(v.Name,"kissed Warrior")
                            and v:FindFirstChild("HumanoidRootPart")
                            and v.Humanoid.Health > 0 then
                                if string.find(txt, NameMon) then
                                    repeat
                                        task.wait()
                                        EquipWeapon(_G.SelectWeapon); AutoHaki()
                                        topos(v.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
                                        v.HumanoidRootPart.CanCollide=false; v.Humanoid.WalkSpeed=0
                                        v.HumanoidRootPart.Size=Vector3.new(70,70,70)
                                        StartBring=true; MonFarm=v.Name
                                        VirtualUser:CaptureController()
                                        VirtualUser:Button1Down(Vector2.new(1280,672))
                                    until not _G.AutoFarm or v.Humanoid.Health<=0
                                    or not v.Parent or not questGui.Visible
                                end
                            end
                        end
                    else
                        if workspace.Enemies:FindFirstChild(Mon) then
                            for _, mob in pairs(workspace.Enemies:GetChildren()) do
                                if mob:FindFirstChild("HumanoidRootPart")
                                and mob:FindFirstChild("Humanoid")
                                and mob.Humanoid.Health > 0
                                and mob.Name == Mon then
                                    if not string.find(txt, NameMon) then
                                        StartBring = false
                                        ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest")
                                    else
                                        repeat
                                            task.wait()
                                            EquipWeapon(_G.SelectWeapon); AutoHaki()
                                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
                                            mob.HumanoidRootPart.CanCollide=false
                                            mob.Humanoid.WalkSpeed=0
                                            mob.HumanoidRootPart.Size=Vector3.new(70,70,70)
                                            StartBring=true; MonFarm=mob.Name; PosMon=mob.HumanoidRootPart.CFrame
                                            VirtualUser:CaptureController()
                                            VirtualUser:Button1Down(Vector2.new(1280,672))
                                        until not _G.AutoFarm or mob.Humanoid.Health<=0
                                        or not mob.Parent or not questGui.Visible
                                    end
                                end
                            end
                        else
                            TP1(CFrameMon); StartBring=false
                        end
                    end
                else
                    StartBring=false
                    TP1(CFrameQuest)
                    if (HRP().Position - CFrameQuest.Position).Magnitude <= 20 then
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", NameQuest, LevelQuest)
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- // AUTO FARM NEAREST
-- ============================================================
spawn(function()
    while task.wait() do
        if _G.AutoNear then
            pcall(function()
                for _, mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob:FindFirstChild("Humanoid")
                    and mob:FindFirstChild("HumanoidRootPart")
                    and mob.Humanoid.Health > 0
                    and (HRP().Position - mob.HumanoidRootPart.Position).Magnitude <= 5000 then
                        repeat
                            task.wait(_G.Fast_Delay)
                            StartBring=true; AutoHaki(); EquipWeapon(_G.SelectWeapon)
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
                            mob.HumanoidRootPart.Size=Vector3.new(60,60,60)
                            mob.HumanoidRootPart.Transparency=1
                            mob.Humanoid.JumpPower=0; mob.Humanoid.WalkSpeed=0
                            mob.HumanoidRootPart.CanCollide=false
                            FarmPos=mob.HumanoidRootPart.CFrame; MonFarm=mob.Name
                        until not _G.AutoNear or not mob.Parent or mob.Humanoid.Health<=0
                        StartBring=false
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- // AUTO FARM BONES
-- ============================================================
spawn(function()
    while task.wait() do
        if _G.FarmBone and World3 then
            pcall(function()
                local boneCF = CFrame.new(-9508,142,5737)
                TP1(boneCF)
                local hasMobs = false
                for _, mob in pairs(workspace.Enemies:GetChildren()) do
                    if (mob.Name=="Reborn Skeleton" or mob.Name=="Living Zombie"
                    or mob.Name=="Demonic Soul" or mob.Name=="Posessed Mummy")
                    and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        hasMobs = true
                        repeat
                            task.wait(); AutoHaki(); EquipWeapon(_G.SelectWeapon)
                            mob.HumanoidRootPart.CanCollide=false; mob.Humanoid.WalkSpeed=0
                            StartBring=true; MonFarm=mob.Name
                            topos(mob.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
                        until not _G.FarmBone or not mob.Parent or mob.Humanoid.Health<=0
                    end
                end
                if not hasMobs then
                    topos(CFrame.new(-9506,172,6117))
                end
            end)
        end
    end
end)

-- ============================================================
-- // AUTO TRADE BONES
-- ============================================================
spawn(function()
    while task.wait(0.1) do
        if _G.Rdbone then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Bones","Buy",1,1)
            end)
        end
    end
end)

-- ============================================================
-- // AUTO PRAY / TRY LUCK
-- ============================================================
spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local graveCF = CFrame.new(-8652,143,6170)
            if _G.Pray then
                TP1(graveCF); task.wait()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("gravestoneEvent",1)
            end
            if _G.Trylux then
                TP1(graveCF); task.wait()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("gravestoneEvent",2)
            end
        end)
    end
end)

-- ============================================================
-- // KILL SOUL REAPER
-- ============================================================
spawn(function()
    while task.wait() do
        if _G.Hallow then
            pcall(function()
                if not workspace.Enemies:FindFirstChild("Soul Reaper") then
                    if Plr.Backpack:FindFirstChild("Hallow Essence")
                    or Plr.Character:FindFirstChild("Hallow Essence") then
                        TP1(CFrame.new(-8932,146,6062))
                        EquipWeapon("Hallow Essence")
                    end
                else
                    for _, mob in pairs(workspace.Enemies:GetChildren()) do
                        if string.find(mob.Name,"Soul Reaper") then
                            repeat
                                task.wait(); EquipWeapon(_G.SelectWeapon); AutoHaki()
                                mob.HumanoidRootPart.Size=Vector3.new(50,50,50)
                                topos(mob.HumanoidRootPart.CFrame*CFrame.new(0,30,0))
                                VirtualUser:CaptureController()
                                VirtualUser:Button1Down(Vector2.new(1280,670))
                            until mob.Humanoid.Health<=0 or not _G.Hallow
                        end
                    end
                end
            end)
        end
    end
end)

-- ============================================================
-- // AUTO PIRATES SEA (World 3)
-- ============================================================
if World3 then
    spawn(function()
        while task.wait() do
            if _G.AutoRaidPirate then
                pcall(function()
                    local farmCF = CFrame.new(-5496,313,-2841)
                    for _, mob in pairs(workspace.Enemies:GetChildren()) do
                        if mob:FindFirstChild("HumanoidRootPart")
                        and mob:FindFirstChild("Humanoid")
                        and mob.Humanoid.Health > 0
                        and (mob.HumanoidRootPart.Position - HRP().Position).Magnitude < 2000 then
                            repeat
                                task.wait(); AutoHaki(); EquipWeapon(_G.SelectWeapon)
                                mob.HumanoidRootPart.CanCollide=false
                                mob.HumanoidRootPart.Size=Vector3.new(60,60,60)
                                topos(mob.HumanoidRootPart.CFrame*CFrame.new(0,30,0))
                            until mob.Humanoid.Health<=0 or not mob.Parent or not _G.AutoRaidPirate
                        end
                    end
                    if (HRP().Position - farmCF.Position).Magnitude > 500 then TP1(farmCF) end
                end)
            end
        end
    end)
end

-- ============================================================
-- // AUTO FACTORY (World 2)
-- ============================================================
if World2 then
    spawn(function()
        while task.wait() do
            if _G.AutoFactory then
                pcall(function()
                    if workspace.Enemies:FindFirstChild("Core") then
                        for _, mob in pairs(workspace.Enemies:GetChildren()) do
                            if mob.Name=="Core" and mob.Humanoid.Health>0 then
                                repeat
                                    task.wait(); AutoHaki(); EquipWeapon(_G.SelectWeapon)
                                    topos(CFrame.new(448,199,441))
                                    VirtualUser:CaptureController()
                                    VirtualUser:Button1Down(Vector2.new(1280,672))
                                until mob.Humanoid.Health<=0 or not _G.AutoFactory
                            end
                        end
                    else
                        topos(CFrame.new(448,199,-441))
                    end
                end)
            end
        end
    end)
end

-- ============================================================
-- // SERVER HOP
-- ============================================================
function GetNewServer()
    local Servers = {}
    local ok, data = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        ))
    end)
    if ok and data and data.data then
        for _, s in pairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= JobId then
                table.insert(Servers, s.id)
            end
        end
    end
    if #Servers > 0 then return Servers[math.random(1,#Servers)] end
end

function Hop()
    local ok, _ = pcall(function()
        local cursor = ""
        local visited = {}
        while true do
            local url = "https://games.roblox.com/v1/games/"..PlaceId..
                        "/servers/Public?sortOrder=Asc&limit=100"
            if cursor ~= "" then url = url.."&cursor="..cursor end
            local res = HttpService:JSONDecode(game:HttpGet(url))
            if res.nextPageCursor and res.nextPageCursor ~= "null"
            and res.nextPageCursor ~= nil then
                cursor = res.nextPageCursor
            else cursor = "" end
            for _, s in pairs(res.data) do
                if tostring(s.maxPlayers) > tostring(s.playing) then
                    if not visited[tostring(s.id)] then
                        visited[tostring(s.id)] = true
                        TeleportService:TeleportToPlaceInstance(PlaceId, s.id, Plr)
                        return
                    end
                end
            end
            task.wait(0.1)
            if cursor == "" then break end
        end
    end)
end

-- Auto rejoin every 30 min
local RejoinRunning = false
spawn(function()
    while task.wait(1) do
        if _G.AutoRejoin30m and not RejoinRunning then
            RejoinRunning = true
            task.spawn(function()
                while _G.AutoRejoin30m do
                    task.wait(1800)
                    if not _G.AutoRejoin30m then break end
                    local ns = GetNewServer()
                    if ns then TeleportService:TeleportToPlaceInstance(PlaceId, ns, Plr)
                    else TeleportService:Teleport(PlaceId, Plr) end
                end
                RejoinRunning = false
            end)
        end
    end
end)

-- Admin check → hop
local Admins = {
    red_game43=true, rip_indra=true, Axiore=true, Polkster=true,
    wenlocktoad=true, Daigrock=true, toilamvidamme=true,
    oofficialnoobie=true, Uzoth=true, Azarth=true, arlthmetic=true,
    Death_King=true, Lunoven=true, TheGreateAced=true,
    rip_fud=true, drip_mama=true, layandikit12=true, Hingoi=true,
}
task.spawn(function()
    while task.wait(1) do
        for _, p in pairs(Players:GetPlayers()) do
            if Admins[p.Name] then Hop(); break end
        end
    end
end)

-- ============================================================
-- // SAFE MODE (fly up)
-- ============================================================
spawn(function()
    while task.wait() do
        if _G.SafeMode and HRP() then
            pcall(function()
                HRP().CFrame = HRP().CFrame * CFrame.new(0,200,0)
            end)
        end
    end
end)

-- ============================================================
-- // ESP SYSTEM
-- ============================================================
local Number = math.random(1,1000000)

-- Player ESP
local ESPConnections = {}
function UpdatePlayerChams()
    for _, player in pairs(Players:GetPlayers()) do
        if player == Plr then continue end
        pcall(function()
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if not hrp or not hum then return end

            if not _G.ESPPlayer then
                if hrp:FindFirstChild("PlayerESP") then hrp.PlayerESP:Destroy() end
                if ESPConnections[player] then
                    ESPConnections[player]:Disconnect(); ESPConnections[player]=nil
                end
                return
            end

            if hrp:FindFirstChild("PlayerESP") then return end

            local gui = Instance.new("BillboardGui")
            gui.Name = "PlayerESP"; gui.Adornee = hrp
            gui.Size = UDim2.new(0,200,0,50)
            gui.StudsOffset = Vector3.new(0,2.5,0)
            gui.AlwaysOnTop = true; gui.Parent = hrp

            local nameLabel = Instance.new("TextLabel")
            nameLabel.BackgroundTransparency = 1
            nameLabel.Size = UDim2.new(1,0,0.5,0)
            nameLabel.TextScaled = true
            nameLabel.Font = Enum.Font.SourceSansBold
            nameLabel.Parent = gui

            local hpLabel = Instance.new("TextLabel")
            hpLabel.BackgroundTransparency = 1
            hpLabel.Size = UDim2.new(1,0,0.5,0)
            hpLabel.Position = UDim2.new(0,0,0.5,0)
            hpLabel.TextScaled = true
            hpLabel.Font = Enum.Font.SourceSansBold
            hpLabel.Parent = gui

            ESPConnections[player] = RunService.RenderStepped:Connect(function()
                if not _G.ESPPlayer or not char or not hrp or not hum or hum.Health<=0 then
                    gui.Enabled = false; return
                end
                gui.Enabled = true
                local dist = rnd((Plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                nameLabel.Text = player.Name.." ["..dist.."m]"
                hpLabel.Text   = "["..rnd(hum.Health).."/"..rnd(hum.MaxHealth).."]"
                nameLabel.TextColor3 = player.Team == Plr.Team and Color3.new(0,1,0) or Color3.new(1,0,0)
                hpLabel.TextColor3   = Color3.new(0,1,0)
            end)
        end)
    end
end

-- Chest ESP
function UpdateChestESP()
    for _, chest in pairs(CollectionService:GetTagged("_ChestTagged")) do
        pcall(function()
            if not _G.ChestESP then
                if chest:FindFirstChild("ChestEsp") then chest.ChestEsp:Destroy() end
                return
            end
            if chest:GetAttribute("IsDisabled") then
                if chest:FindFirstChild("ChestEsp") then chest.ChestEsp:Destroy() end
                return
            end
            if chest:FindFirstChild("ChestEsp") then
                local dist = rnd((Plr.Character.Head.Position - chest:GetPivot().Position).Magnitude)
                chest.ChestEsp.TextLabel.Text = "Chest\n"..dist.."M"
                return
            end
            local gui = Instance.new("BillboardGui", chest)
            gui.Name = "ChestEsp"; gui.Adornee = chest
            gui.ExtentsOffset = Vector3.new(0,1,0)
            gui.Size = UDim2.new(1,200,1,30)
            gui.AlwaysOnTop = true
            local lbl = Instance.new("TextLabel", gui)
            lbl.Font = Enum.Font.Code; lbl.FontSize = Enum.FontSize.Size14
            lbl.TextWrapped = true; lbl.Size = UDim2.new(1,0,1,0)
            lbl.TextYAlignment = Enum.TextYAlignment.Top
            lbl.BackgroundTransparency = 1; lbl.TextStrokeTransparency = 0.5
            lbl.TextColor3 = Color3.fromRGB(255,215,0)
        end)
    end
end

-- Devil Fruit ESP
function UpdateDevilChams()
    local char = Plr.Character
    if not char or not char:FindFirstChild("Head") then return end
    for _, v in pairs(workspace:GetChildren()) do
        pcall(function()
            if v:IsA("Tool") and string.find(v.Name,"Fruit") and v:FindFirstChild("Handle") then
                local handle = v.Handle
                local espName = "NameEsp"..Number
                local dist = rnd((char.Head.Position - handle.Position).Magnitude)
                if not _G.DevilFruitESP then
                    if handle:FindFirstChild(espName) then handle[espName]:Destroy() end
                    return
                end
                if handle:FindFirstChild(espName) then
                    handle[espName].TextLabel.Text = "Fruit | "..v.Name.." | <"..dist..">"
                    return
                end
                local bill = Instance.new("BillboardGui")
                bill.Name = espName; bill.Size = UDim2.new(0,220,0,40)
                bill.ExtentsOffset = Vector3.new(0,1.5,0)
                bill.AlwaysOnTop = true; bill.Adornee = handle; bill.Parent = handle
                local text = Instance.new("TextLabel")
                text.Size = UDim2.new(1,0,1,0); text.BackgroundTransparency=1
                text.TextScaled=true; text.Font=Enum.Font.GothamBold
                text.TextColor3=Color3.fromRGB(255,80,0)
                text.TextStrokeTransparency=0; text.Parent=bill
            end
        end)
    end
end

-- Flower ESP
function UpdateFlowerChams()
    for _, v in pairs(workspace:GetChildren()) do
        pcall(function()
            if v.Name=="Flower1" or v.Name=="Flower2" then
                local espName = "NameEsp"..Number
                local dist = rnd((Plr.Character.Head.Position - v.Position).Magnitude)
                if not _G.FlowerESP then
                    if v:FindFirstChild(espName) then v[espName]:Destroy() end
                    return
                end
                if v:FindFirstChild(espName) then
                    v[espName].TextLabel.Text = (v.Name=="Flower1" and "Blue Flower" or "Red Flower").." \n"..dist.." Distance"
                    return
                end
                local gui = Instance.new("BillboardGui",v)
                gui.Name=espName; gui.ExtentsOffset=Vector3.new(0,1,0)
                gui.Size=UDim2.new(1,200,1,30); gui.AlwaysOnTop=true
                local lbl = Instance.new("TextLabel",gui)
                lbl.Font=Enum.Font.GothamSemibold; lbl.FontSize=Enum.FontSize.Size14
                lbl.TextWrapped=true; lbl.Size=UDim2.new(1,0,1,0)
                lbl.TextYAlignment=Enum.TextYAlignment.Top
                lbl.BackgroundTransparency=1; lbl.TextStrokeTransparency=0.5
                lbl.TextColor3 = v.Name=="Flower1" and Color3.fromRGB(0,0,255) or Color3.fromRGB(255,0,0)
            end
        end)
    end
end

-- Real Fruit ESP (Apple, Pineapple, Banana spawner)
function UpdateRealFruitChams()
    local spawners = {"AppleSpawner","PineappleSpawner","BananaSpawner"}
    for _, sName in ipairs(spawners) do
        pcall(function()
            local spawner = workspace:FindFirstChild(sName)
            if not spawner then return end
            for _, v in pairs(spawner:GetChildren()) do
                if v:IsA("Tool") then
                    local espName = "NameEsp"..Number
                    local dist = rnd((Plr.Character.Head.Position - v.Handle.Position).Magnitude)
                    if not _G.RealFruitESP then
                        if v.Handle:FindFirstChild(espName) then v.Handle[espName]:Destroy() end
                        return
                    end
                    if v.Handle:FindFirstChild(espName) then
                        v.Handle[espName].TextLabel.Text = v.Name.." \n"..dist.." Distance"
                        return
                    end
                    local gui = Instance.new("BillboardGui",v.Handle)
                    gui.Name=espName; gui.ExtentsOffset=Vector3.new(0,1,0)
                    gui.Size=UDim2.new(1,200,1,30); gui.AlwaysOnTop=true
                    local lbl=Instance.new("TextLabel",gui)
                    lbl.Font=Enum.Font.GothamSemibold; lbl.FontSize=Enum.FontSize.Size14
                    lbl.TextWrapped=true; lbl.Size=UDim2.new(1,0,1,0)
                    lbl.TextYAlignment=Enum.TextYAlignment.Top
                    lbl.BackgroundTransparency=1; lbl.TextStrokeTransparency=0.5
                    lbl.TextColor3=Color3.fromRGB(255,255,0)
                end
            end
        end)
    end
end

-- Island ESP
function UpdateIslandESP()
    pcall(function()
        for _, v in pairs(workspace._WorldOrigin.Locations:GetChildren()) do
            pcall(function()
                if v.Name == "Sea" then return end
                if not _G.IslandESP then
                    if v:FindFirstChild("NameEsp") then v.NameEsp:Destroy() end
                    return
                end
                local dist = rnd((Plr.Character.Head.Position - v.Position).Magnitude)
                if v:FindFirstChild("NameEsp") then
                    v.NameEsp.TextLabel.Text = v.Name.." \n"..dist.." Distance"
                    return
                end
                local gui = Instance.new("BillboardGui",v)
                gui.Name="NameEsp"; gui.ExtentsOffset=Vector3.new(0,1,0)
                gui.Size=UDim2.new(1,200,1,30); gui.AlwaysOnTop=true
                local lbl=Instance.new("TextLabel",gui)
                lbl.Font=Enum.Font.GothamSemibold; lbl.FontSize=Enum.FontSize.Size14
                lbl.TextWrapped=true; lbl.Size=UDim2.new(1,0,1,0)
                lbl.TextYAlignment=Enum.TextYAlignment.Top
                lbl.BackgroundTransparency=1; lbl.TextStrokeTransparency=0.5
                lbl.TextColor3=Color3.fromRGB(8,247,255)
            end)
        end
    end)
end

-- Mob ESP
spawn(function()
    while task.wait() do
        pcall(function()
            if _G.MobESP then
                for _, mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob:FindFirstChild("HumanoidRootPart") then
                        if not mob:FindFirstChild("MobEap") then
                            local gui = Instance.new("BillboardGui")
                            gui.Active=true; gui.Name="MobEap"
                            gui.AlwaysOnTop=true; gui.LightInfluence=1
                            gui.Size=UDim2.new(0,200,0,50)
                            gui.StudsOffset=Vector3.new(0,2.5,0)
                            gui.Parent=mob
                            local lbl=Instance.new("TextLabel",gui)
                            lbl.BackgroundTransparency=1
                            lbl.Size=UDim2.new(1,0,1,0)
                            lbl.Font=Enum.Font.GothamBold
                            lbl.TextColor3=Color3.fromRGB(7,236,240)
                            lbl.TextSize=35
                        end
                        local dist = rnd((Plr.Character.HumanoidRootPart.Position - mob.HumanoidRootPart.Position).Magnitude)
                        mob.MobEap.TextLabel.Text = mob.Name.." - "..dist.." Distance"
                    end
                end
            else
                for _, mob in pairs(workspace.Enemies:GetChildren()) do
                    if mob:FindFirstChild("MobEap") then mob.MobEap:Destroy() end
                end
            end
        end)
    end
end)

-- Sea Beast ESP
spawn(function()
    while task.wait() do
        pcall(function()
            if _G.SeaESP then
                for _, mob in pairs(workspace.SeaBeasts:GetChildren()) do
                    if mob:FindFirstChild("HumanoidRootPart") then
                        if not mob:FindFirstChild("Seaesps") then
                            local gui=Instance.new("BillboardGui")
                            gui.Active=true; gui.Name="Seaesps"
                            gui.AlwaysOnTop=true; gui.LightInfluence=1
                            gui.Size=UDim2.new(0,200,0,50)
                            gui.StudsOffset=Vector3.new(0,2.5,0)
                            gui.Parent=mob
                            local lbl=Instance.new("TextLabel",gui)
                            lbl.BackgroundTransparency=1
                            lbl.Size=UDim2.new(1,0,1,0)
                            lbl.Font=Enum.Font.GothamBold
                            lbl.TextColor3=Color3.fromRGB(7,236,240)
                            lbl.TextSize=35
                        end
                        local dist = rnd((Plr.Character.HumanoidRootPart.Position - mob.HumanoidRootPart.Position).Magnitude)
                        mob.Seaesps.TextLabel.Text = mob.Name.." - "..dist.." Distance"
                    end
                end
            else
                for _, mob in pairs(workspace.SeaBeasts:GetChildren()) do
                    if mob:FindFirstChild("Seaesps") then mob.Seaesps:Destroy() end
                end
            end
        end)
    end
end)

-- ESP render loop
RunService.RenderStepped:Connect(function()
    pcall(UpdatePlayerChams)
    pcall(UpdateChestESP)
    pcall(UpdateDevilChams)
    pcall(UpdateFlowerChams)
    pcall(UpdateRealFruitChams)
    pcall(UpdateIslandESP)
end)

Players.PlayerAdded:Connect(function() task.wait(1); UpdatePlayerChams() end)
Players.PlayerRemoving:Connect(function(p)
    if ESPConnections[p] then ESPConnections[p]:Disconnect(); ESPConnections[p]=nil end
end)

-- ============================================================
-- // JOIN TEAM
-- ============================================================
local function JoinTeam()
    local target = Settings.JoinTeam == "Pirates" and "Pirates" or "Marines"
    if not Plr.Team or (Plr.Team.Name ~= "Marines" and Plr.Team.Name ~= "Pirates") then
        pcall(function()
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("SetTeam", target)
        end)
    end
end
JoinTeam()

-- ============================================================
-- // GUI (redzlib)
-- ============================================================
local ok, redzlib = pcall(function()
    return loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/PlockScripts/Libraryui/refs/heads/main/redz-V5-remake/main.luau"
    ))()
end)

if ok and redzlib then
    local win = redzlib:MakeWindow({
        Title    = "AXIOM | Blox Fruits",
        SubTitle = "Full Rebuild — boss man edition",
        SaveFolder = "Axiom_BF.lua"
    })

    local farmTab  = win:MakeTab({"Farm",       "home"})
    local espTab   = win:MakeTab({"ESP/Visual", "user"})
    local miscTab  = win:MakeTab({"Misc",       "settings"})

    -- // Farm tab
    farmTab:AddToggle({Name="Auto Farm Level",      Default=false, Callback=function(v) _G.AutoFarm=v; StopTween(_G.AutoFarm) end})
    farmTab:AddToggle({Name="Auto Farm Nearest",    Default=false, Callback=function(v) _G.AutoNear=v; StopTween(_G.AutoNear) end})
    if World3 then
        farmTab:AddToggle({Name="Auto Pirates Sea", Default=false, Callback=function(v) _G.AutoRaidPirate=v; StopTween(v) end})
        farmTab:AddToggle({Name="Auto Farm Bones",  Default=false, Callback=function(v) _G.FarmBone=v; StopTween(v) end})
        farmTab:AddToggle({Name="Farm Katakuri",    Default=false, Callback=function(v) _G.FarmCake=v; StopTween(v) end})
        farmTab:AddToggle({Name="Kill Soul Reaper", Default=false, Callback=function(v) _G.Hallow=v; StopTween(v) end})
        farmTab:AddToggle({Name="Auto Pray",        Default=false, Callback=function(v) _G.Pray=v end})
        farmTab:AddToggle({Name="Auto Try Luck",    Default=false, Callback=function(v) _G.Trylux=v end})
        farmTab:AddToggle({Name="Auto Trade Bones", Default=false, Callback=function(v) _G.Rdbone=v end})
        farmTab:AddToggle({Name="Farm Tyrant",      Default=false, Callback=function(v) _G.FarmDaiBan=v; StopTween(v) end})
        farmTab:AddToggle({Name="Safe Mode",        Default=false, Callback=function(v) _G.SafeMode=v end})
    end
    if World2 then
        farmTab:AddToggle({Name="Auto Factory",     Default=false, Callback=function(v) _G.AutoFactory=v; StopTween(v) end})
    end
    farmTab:AddDropdown({
        Name="Weapon Type",
        Options={"Melee","Sword","Gun","Blox Fruit"},
        Default="Melee",
        Callback=function(v) _G.SelectWeapon=v end
    })

    -- // ESP tab
    espTab:AddToggle({Name="Player ESP",      Default=true,  Callback=function(v) _G.ESPPlayer=v end})
    espTab:AddToggle({Name="Chest ESP",       Default=true,  Callback=function(v) _G.ChestESP=v end})
    espTab:AddToggle({Name="Devil Fruit ESP", Default=true,  Callback=function(v) _G.DevilFruitESP=v end})
    espTab:AddToggle({Name="Flower ESP",      Default=true,  Callback=function(v) _G.FlowerESP=v end})
    espTab:AddToggle({Name="Real Fruit ESP",  Default=true,  Callback=function(v) _G.RealFruitESP=v end})
    espTab:AddToggle({Name="Island ESP",      Default=true,  Callback=function(v) _G.IslandESP=v end})
    espTab:AddToggle({Name="Mob ESP",         Default=true,  Callback=function(v) _G.MobESP=v end})
    espTab:AddToggle({Name="Sea Beast ESP",   Default=true,  Callback=function(v) _G.SeaESP=v end})

    -- // Misc tab
    miscTab:AddButton({Title="Server Hop",     Callback=function() Hop() end})
    miscTab:AddButton({Title="Rejoin Server",  Callback=function()
        TeleportService:Teleport(PlaceId, Plr)
    end})
    miscTab:AddToggle({Name="Auto Rejoin 30m", Default=false, Callback=function(v) _G.AutoRejoin30m=v end})
    miscTab:AddToggle({Name="Auto Haki",       Default=false, Callback=function(v)
        if v then
            spawn(function()
                while v do task.wait(0.5); pcall(AutoHaki) end
            end)
        end
    end})
end

print("[AXIOM] Blox Fruits loaded — fuck yeah boss man")
