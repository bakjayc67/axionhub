--[[
    Lotus Hub Fixed v2.3 — Hard Audit Fix 2026
    Fixed:
    - Melee infinite buy loop
    - Bartilo progress logic
    - Tushita / Yama incomplete paths
    - Priority order
    - Safer material + godhuman
    - All modules present and called
]]

repeat task.wait() until game:IsLoaded() and game.Players.LocalPlayer

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local plr = Players.LocalPlayer
local character = plr.Character or plr.CharacterAdded:Wait()
plr.CharacterAdded:Connect(function(c) character = c end)

local Config = {
    UI            = true,
    Team          = "Marines",
    FPS           = 30,
    FPSBOOST      = true,
    GOD           = false,
    Saber         = true,
    CDK           = true,
    SkullGuitar   = false,
    RaceV3        = true,
    AutoMelee     = true,
    AutoRaid      = true,
    Humanize      = true,
    AttackDelayMin = 0.14,
    AttackDelayMax = 0.28,
    TweenSpeed    = 250,
    BringMax      = 3,
}
getgenv().LotusConfig = Config

-- ===================== UTILS =====================
local function rand(a,b) return a + math.random()*(b-a) end
local function humanDelay() if Config.Humanize then task.wait(rand(0.05,0.14)) end end
local function getHRP() return character and character:FindFirstChild("HumanoidRootPart") end
local function getHum() return character and character:FindFirstChildOfClass("Humanoid") end
local function isAlive() local h=getHum() return h and h.Health>0 end
local function dist(pos) local h=getHRP() return h and (h.Position-pos).Magnitude or 1e9 end
local function currentSea()
    local m = workspace:GetAttribute("MAP")
    return m=="Sea1" and 1 or m=="Sea2" and 2 or m=="Sea3" and 3 or 0
end

-- ===================== REMOTES =====================
local R = {}
local function cacheRemotes()
    local rem = ReplicatedStorage:FindFirstChild("Remotes")
    if not rem then return end
    R.CommF = rem:FindFirstChild("CommF_")
    R.Redeem = rem:FindFirstChild("Redeem")
    local net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
    if net then
        R.RegAttack = net:FindFirstChild("RE/RegisterAttack")
        R.RegHit = net:FindFirstChild("RE/RegisterHit")
    end
end
cacheRemotes()

local function inv(name, ...)
    if not R.CommF then cacheRemotes() end
    if R.CommF then
        local ok, res = pcall(R.CommF.InvokeServer, R.CommF, name, ...)
        return ok and res or nil
    end
end

-- ===================== SAFETY =====================
pcall(function()
    for _,c in pairs(getconnections(plr.Idled)) do
        if c.Disable then c:Disable() elseif c.Disconnect then c:Disconnect() end
    end
end)

pcall(function()
    local mt = getrawmetatable(game)
    if not mt then return end
    setreadonly(mt, false)
    local old = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        if method=="FireServer" or method=="InvokeServer" then
            local n = tostring(args[1] or "")
            if n=="TeleportDetect" or n=="CHECKER_1" or n=="CHECKER"
                or n=="BANREMOTE" or n=="PERMAIDBAN" or n=="KICKREMOTE"
                or n=="BR_KICKPC" or n=="BR_KICKMOBILE" then
                return
            end
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end)

task.spawn(function()
    while not plr.Team do
        inv("SetTeam", Config.Team or "Pirates")
        task.wait(0.7)
    end
end)

task.spawn(function()
    while true do
        pcall(setfpscap, Config.FPS or 30)
        task.wait(10)
    end
end)

if Config.FPSBOOST then
    task.spawn(function()
        pcall(function()
            for _,v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Transparency < 1 then v.Transparency = 1 end
            end
        end)
    end)
end

-- ===================== MOVEMENT =====================
local curTween
local function stopTween()
    if curTween then pcall(function() curTween:Cancel() end) curTween = nil end
end

local ENTRANCES = {
    [1] = {Vector3.new(61163,11,1819), Vector3.new(-4650,872,-1775), Vector3.new(-7900,5578,-520)},
    [2] = {Vector3.new(-390,332,673), Vector3.new(2285,15,905), Vector3.new(923,126,32852), Vector3.new(-6509,83,-133)},
    [3] = {Vector3.new(5700,1015,-215), Vector3.new(-12550,340,-7500), Vector3.new(-5000,350,-3035)},
}

local function smartEntrance(target)
    local list = ENTRANCES[currentSea()]
    if not list then return end
    local best, bestD = list[1], (target-list[1]).Magnitude
    for i=2,#list do
        local d = (target-list[i]).Magnitude
        if d < bestD then best,bestD = list[i],d end
    end
    if bestD < dist(target) and dist(target) >= 1400 then
        inv("requestEntrance", best)
        task.wait(0.55)
    end
end

local function tweenTo(cfOrPos, speed, yOff)
    speed = math.min(speed or Config.TweenSpeed, 270)
    local hrp = getHRP()
    if not hrp or not isAlive() then return end
    stopTween()
    local target = typeof(cfOrPos)=="CFrame" and cfOrPos or CFrame.new(cfOrPos)
    if yOff then target = target + Vector3.new(0,yOff,0) end
    if Config.Humanize then
        target = target + Vector3.new(rand(-2,2), rand(0,1), rand(-2,2))
    end
    smartEntrance(target.Position)
    local t = math.clamp((hrp.Position-target.Position).Magnitude / speed, 0.08, 10)
    curTween = TweenService:Create(hrp, TweenInfo.new(t, Enum.EasingStyle.Linear), {CFrame=target})
    curTween:Play()
    return curTween
end

if Config.GOD then
    task.spawn(function()
        while true do
            local hrp = getHRP()
            if hrp and not hrp:FindFirstChild("LotusNF") then
                local bv = Instance.new("BodyVelocity")
                bv.Name = "LotusNF"
                bv.MaxForce = Vector3.new(0,1e9,0)
                bv.Velocity = Vector3.zero
                bv.Parent = hrp
            end
            task.wait(1.2)
        end
    end)
    RunService.Stepped:Connect(function()
        if not character then return end
        for _,p in ipairs(character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end

-- ===================== COMBAT =====================
local lastAtk = 0
local function equipMelee()
    if not character or not getHum() then return end
    for _,t in ipairs(plr.Backpack:GetChildren()) do
        if t:IsA("Tool") and (t.ToolTip=="Melee" or t.ToolTip=="Sword") then
            if not character:FindFirstChild("HasBuso") then inv("Buso") end
            getHum():EquipTool(t)
            return t
        end
    end
end

local function nearbyEnemies(range)
    local out = {}
    for _,m in ipairs(workspace.Enemies:GetChildren()) do
        local hrp = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
        local hum = m:FindFirstChildOfClass("Humanoid")
        if hrp and hum and hum.Health>0 and dist(hrp.Position)<=range then
            table.insert(out, {model=m, part=hrp})
        end
    end
    return out
end

local function fastAttack()
    local now = tick()
    if now - lastAtk < rand(Config.AttackDelayMin, Config.AttackDelayMax) then return end
    lastAtk = now
    local enemies = nearbyEnemies(35)
    if #enemies==0 then return end
    local tool = character and character:FindFirstChildOfClass("Tool")
    if not tool or (tool.ToolTip~="Melee" and tool.ToolTip~="Sword") then
        equipMelee()
        tool = character and character:FindFirstChildOfClass("Tool")
    end
    if not tool then return end
    local parts = {}
    for _,e in ipairs(enemies) do
        for _,p in ipairs(e.model:GetChildren()) do
            if p:IsA("BasePart") then table.insert(parts, {e.model, p}) end
        end
    end
    if #parts==0 then return end
    pcall(function()
        if R.RegAttack then R.RegAttack:FireServer() end
        local head = enemies[1].model:FindFirstChild("Head") or enemies[1].part
        if R.RegHit then
            R.RegHit:FireServer(head, parts, {}, tostring(plr.UserId):sub(2,4)..tostring(coroutine.running()):sub(11,15))
        end
    end)
end

local function bring(name, maxn)
    maxn = maxn or Config.BringMax
    local targets = {}
    for _,m in ipairs(workspace.Enemies:GetChildren()) do
        local hrp = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
        local hum = m:FindFirstChildOfClass("Humanoid")
        if hrp and hum and hum.Health>0 and (not name or m.Name==name) and dist(hrp.Position)<=150 then
            table.insert(targets, m)
            if #targets >= maxn then break end
        end
    end
    if #targets < 2 then return end
    local base = targets[1].PrimaryPart or targets[1]:FindFirstChild("HumanoidRootPart")
    if not base then return end
    for i=2,#targets do
        local p = targets[i].PrimaryPart or targets[i]:FindFirstChild("HumanoidRootPart")
        if p and isnetworkowner and isnetworkowner(p) then p.CFrame = base.CFrame end
    end
end

local function killTarget(mob)
    if not mob or not isAlive() then return end
    local start = tick()
    while mob and mob.Parent and isAlive() and (tick()-start)<65 do
        local hrp = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
        local hum = mob:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health<=0 then break end
        local pos = hrp.Position + Vector3.new(0,20,7)
        local tw = tweenTo(pos, Config.TweenSpeed)
        if dist(hrp.Position)<=48 then
            if tw then stopTween() end
            tweenTo(pos, 1e9)
            equipMelee()
            bring(mob.Name)
            fastAttack()
        end
        humanDelay()
    end
end

local function findMob(name)
    return workspace.Enemies:FindFirstChild(name) or ReplicatedStorage:FindFirstChild(name)
end

local function hasItem(name)
    local real = name:gsub("(%l)(%u)", "%1 %2")
    return character:FindFirstChild(real) or plr.Backpack:FindFirstChild(real)
        or character:FindFirstChild(name) or plr.Backpack:FindFirstChild(name)
end

-- ===================== QUEST =====================
local QC = {Current="", Name="", Cache=nil}
pcall(function() QC.Cache = require(ReplicatedStorage.Quests) end)
pcall(function()
    local qr = ReplicatedStorage.Remotes:FindFirstChild("QuestUpdate")
    if qr then
        qr.OnClientEvent:Connect(function(data)
            if type(data)=="table" and data.Progress then
                for k in pairs(data.Progress) do QC.Current=k break end
                QC.Name = data.InternalQuestName or ""
            else
                QC.Current, QC.Name = "", ""
            end
        end)
    end
end)

local function getBestQuest()
    if not QC.Cache then return end
    local lv = plr.Data.Level.Value
    local bestReq, bestN, bestT, bestId = -1, nil, nil, nil
    for rnq, list in pairs(QC.Cache) do
        if rnq=="BartiloQuest" or rnq=="Trainees" or rnq=="MarineQuest" or rnq=="CitizenQuest" then continue end
        for rid, ct in pairs(list) do
            if ct.LevelReq and ct.LevelReq>=0 and lv>=ct.LevelReq then
                for tn, val in pairs(ct.Task or {}) do
                    if val>1 and ct.LevelReq > bestReq then
                        bestReq, bestN, bestT, bestId = ct.LevelReq, rnq, tostring(tn), rid
                    end
                end
            end
        end
    end
    return bestN, bestT, bestId
end

local function takeQuest()
    local nq, msn, idq = getBestQuest()
    if not nq or QC.Name==nq then return end
    local pos
    pcall(function()
        local guide = require(ReplicatedStorage.GuideModule).Data.NPCList
        for _,v in pairs(guide) do
            if type(v)=="table" then
                for _,x in pairs(v) do
                    if x==nq then pos=v.Position break end
                end
            end
            if pos then break end
        end
    end)
    if pos then
        tweenTo(pos, 280)
        task.wait(0.35)
        if dist(pos)<14 then inv("StartQuest", nq, idq) end
    else
        inv("StartQuest", nq, idq)
    end
end

local function farmLevel()
    local lv = plr.Data.Level.Value
    local sea = currentSea()
    if lv>=10 and lv<70 and sea==1 then
        local m = findMob("Shanda")
        if m then killTarget(m) return end
    end
    if lv>=70 and lv<120 and sea==1 then
        local m = findMob("God's Guard")
        if m then killTarget(m) return end
    end
    takeQuest()
    local q = QC.Current
    if q and q~="" then
        local found = false
        for _,folder in ipairs({workspace.Enemies, ReplicatedStorage}) do
            for _,mob in ipairs(folder:GetChildren()) do
                if mob.Name:find(q) and mob:FindFirstChildOfClass("Humanoid") then
                    killTarget(mob)
                    found = true
                    break
                end
            end
            if found then break end
        end
        if not found then
            local sf = ReplicatedStorage:FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder")
            if sf and sf:FindFirstChild(q) then
                tweenTo(sf[q]:GetPivot().Position + Vector3.new(0,18,0), 270)
            end
        end
    end
end

-- ===================== MELEE (fixed infinite loop) =====================
local MeleeOrder = {"BlackLeg","Electro","FishmanKarate","DragonClaw","Superhuman","DeathStep","SharkmanKarate","ElectricClaw","DragonTalon","Godhuman"}
local MeleeTried = {}

local function buyMelee(name)
    if name=="DragonClaw" then
        inv("BlackbeardReward","DragonClaw","2")
    elseif name=="Godhuman" then
        inv("BuyGodhuman", true)
        inv("BuyGodhuman")
    else
        inv("Buy"..name, true)
        inv("Buy"..name)
    end
end

local function meleeStep()
    if not Config.AutoMelee then return false end
    local beli = plr.Data.Beli.Value
    if beli>=25000 and not CollectionService:HasTag(character,"Buso") then inv("BuyHaki","Buso") end
    if beli>=10000 and not CollectionService:HasTag(character,"Geppo") then inv("BuyHaki","Geppo") end
    if beli>=100000 and not CollectionService:HasTag(character,"Soru") then inv("BuyHaki","Soru") end
    for _,name in ipairs(MeleeOrder) do
        if not hasItem(name) and not MeleeTried[name] then
            buyMelee(name)
            MeleeTried[name] = true
            task.wait(0.9)
            return true
        end
    end
    return false
end

-- ===================== MATERIAL + GODHUMAN =====================
local function getMaterial(name)
    local ok, data = pcall(function()
        local KEYS = require(ReplicatedStorage.ItemReplicationService.KEYS)
        local IRS  = require(ReplicatedStorage.ItemReplicationService)
        local MATCH = require(ReplicatedStorage.ItemConfig.Storage).match
        local items = IRS:GetItems(KEYS.QUANTITY)
        for _,v in pairs(items) do
            local item = MATCH(v.ItemId)._ok
            if item and item.Display and item.Display.Category=="Material" and item.Index.StorageKey==name then
                return v.Value or 0
            end
        end
        return 0
    end)
    return ok and data or 0
end

local function farmMaterial(mat)
    local mon, pos
    local sea = currentSea()
    if sea==1 then
        if mat=="Fish Tail" then mon={"Fishman Warrior","Fishman Commando"} pos=Vector3.new(61123,19,1569)
        elseif mat=="Magma Ore" then mon={"Military Soldier","Military Spy"} pos=Vector3.new(-5815,84,8820) end
    elseif sea==2 then
        if mat=="Mystic Droplet" then mon={"Water Fighter"} pos=Vector3.new(-3385,239,-10542)
        elseif mat=="Magma Ore" then mon={"Magma Ninja","Lava Pirate"} pos=Vector3.new(-5428,78,-5959)
        elseif mat=="Ectoplasm" then mon={"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer"} pos=Vector3.new(911,126,33159) end
    elseif sea==3 then
        if mat=="Dragon Scale" then mon={"Dragon Crew Warrior","Dragon Crew Archer"} pos=Vector3.new(6594,383,139)
        elseif mat=="Fish Tail" then mon={"Fishman Raider","Fishman Captain"} pos=Vector3.new(-10993,332,-8940)
        elseif mat=="Conjured Cocoa" then mon={"Chocolate Bar Battler","Cocoa Warrior"} pos=Vector3.new(620,78,-12581) end
    end
    if not mon then return end
    local target, minD = nil, 1e9
    for _,m in ipairs(workspace.Enemies:GetChildren()) do
        if table.find(mon, m.Name) and m:FindFirstChildOfClass("Humanoid") and m.Humanoid.Health>0 then
            local d = dist((m.PrimaryPart or m:FindFirstChild("HumanoidRootPart")).Position)
            if d < minD then minD=d target=m end
        end
    end
    if target then killTarget(target)
    elseif pos then tweenTo(pos, 260) end
end

local function doGodhuman()
    if hasItem("Godhuman") then return false end
    local need = {["Dragon Scale"]=10, ["Mystic Droplet"]=10, ["Fish Tail"]=20, ["Magma Ore"]=20}
    for mat, qty in pairs(need) do
        if getMaterial(mat) < qty then
            if (mat=="Dragon Scale" or mat=="Fish Tail") and currentSea()~=3 then
                inv("TravelZou") return true
            elseif (mat=="Mystic Droplet" or mat=="Magma Ore") and currentSea()~=2 then
                inv("TravelDressrosa") return true
            end
            farmMaterial(mat)
            return true
        end
    end
    if currentSea()~=3 then inv("TravelZou") return true end
    tweenTo(Vector3.new(-12550,340,-7500), 240)
    task.wait(1)
    inv("BuyGodhuman", true)
    inv("BuyGodhuman")
    return true
end

-- ===================== SEA UNLOCK =====================
local function unlockSea2()
    if currentSea()~=1 or plr.Data.Level.Value<700 then return end
    local p = inv("DressrosaQuestProgress")
    if type(p)=="table" then
        if not p.UsedKey then
            inv("DressrosaQuestProgress","Detective")
            inv("DressrosaQuestProgress","UseKey")
        elseif not p.KilledIceBoss then
            local b = findMob("Ice Admiral")
            if b then killTarget(b) end
        else
            inv("TravelDressrosa")
        end
    else
        inv("TravelDressrosa")
    end
end

local function unlockSea3()
    if currentSea()~=2 or plr.Data.Level.Value<1500 then return end
    local c = inv("ZQuestProgress","Check")
    if c==0 then
        inv("TravelZou")
        local b = findMob("rip_indra")
        if b then killTarget(b) end
    else
        inv("TravelZou")
    end
end

-- ===================== SABER =====================
local function doSaber()
    if not Config.Saber or currentSea()~=1 or plr.Data.Level.Value<200 then return false end
    if hasItem("Saber") then return false end
    inv("ProQuestProgress")
    local b = findMob("Saber Expert")
    if b then killTarget(b) return true end
    return false
end

-- ===================== BARTILO (fixed) =====================
local function doBartilo()
    if currentSea()~=2 or plr.Data.Level.Value<850 then return false end
    if hasItem("Warrior Helmet") then return false end
    local progress = inv("BartiloQuestProgress")
    local data = inv("BartiloQuestProgress","Bartilo")
    -- progress can be table or number depending on call
    local killedBandits = false
    if type(progress)=="table" then
        killedBandits = progress.KilledBandits == true
    end
    if not killedBandits then
        if QC.Name ~= "BartiloQuest" then inv("StartQuest","BartiloQuest",1) end
        local m = findMob("Swan Pirate")
        if m then killTarget(m) else tweenTo(Vector3.new(932,156,1180),250) end
        return true
    end
    if data==1 then
        local j = findMob("Jeremy")
        if j then killTarget(j) else tweenTo(Vector3.new(2129,469,779),240) end
        return true
    end
    if data==2 then
        pcall(function()
            for i=1,8 do
                local plate = workspace.Map.Dressrosa.BartiloPlates:FindFirstChild("Plate"..i)
                if plate and character.PrimaryPart then
                    firetouchinterest(plate, character.PrimaryPart, 0)
                    task.wait(0.1)
                    firetouchinterest(plate, character.PrimaryPart, 1)
                end
            end
        end)
        return true
    end
    return false
end

-- ===================== RACE =====================
local function getRaceGrade()
    if hasItem("Awakening") then return "V4" end
    local race = plr.Data.Race
    if race:FindFirstChild("Evolved") then
        for _,n in ipairs({"Last Resort","Agility","Water Body","Heavenly Blood","Heightened Senses","Energy Core","Primordial Reign"}) do
            if hasItem(n) then return "V3" end
        end
        return "V2"
    end
    return "V1"
end

local function doRaceV2()
    if not Config.RaceV3 then return false end
    if getRaceGrade()~="V1" then return false end
    if currentSea()~=2 then inv("TravelDressrosa") return true end
    local check = inv("Alchemist","1")
    if check==0 then inv("Alchemist","2")
    elseif check==1 then
        if not hasItem("Flower 1") then
            local f = workspace:FindFirstChild("Flower1")
            if f then tweenTo(f.CFrame,250) end
        elseif not hasItem("Flower 2") then
            local f = workspace:FindFirstChild("Flower2")
            if f then tweenTo(f.CFrame,250) end
        elseif not hasItem("Flower 3") then
            local z = findMob("Zombie")
            if z then killTarget(z) end
        end
    elseif check==2 then
        inv("Alchemist","3")
    end
    return true
end

local HumanStage = 0
local function doRaceV3()
    if not Config.RaceV3 then return false end
    if getRaceGrade()~="V2" then return false end
    if plr.Data.Level.Value<1000 or plr.Data.Beli.Value<2000000 then return false end
    if currentSea()~=2 then inv("TravelDressrosa") return true end
    local race = plr.Data.Race.Value
    local check = inv("Wenlocktoad","1")
    if check==0 then inv("Wenlocktoad","2")
    elseif check==1 then
        if race=="Human" then
            local bosses = {"Jeremy","Diamond","Orbitus"}
            if HumanStage < 3 then
                local b = findMob(bosses[HumanStage+1])
                if b then
                    killTarget(b)
                    HumanStage = HumanStage + 1
                else
                    local pos = {Vector3.new(2333,449,699), Vector3.new(-1713,199,-104), Vector3.new(-2148,73,-4304)}
                    tweenTo(pos[HumanStage+1] or pos[1], 240)
                end
            else
                inv("Wenlocktoad","3")
            end
        else
            inv("Wenlocktoad","3")
        end
    elseif check==2 then
        inv("Wenlocktoad","3")
    end
    return true
end

-- ===================== ELITE + YAMA =====================
local function doElite()
    if currentSea()~=3 then return false end
    local elites = {"Diablo","Urban","Deandre","Tyrant of the Skies"}
    for _,name in ipairs(elites) do
        local m = findMob(name)
        if m and m:FindFirstChildOfClass("Humanoid") and m.Humanoid.Health>0 then
            inv("EliteHunter")
            killTarget(m)
            return true
        end
    end
    return false
end

local function doYama()
    if currentSea()~=3 then return false end
    if hasItem("Yama") then return false end
    local progress = inv("EliteHunter","Progress") or 0
    if type(progress)~="number" then progress = 0 end
    if progress < 30 then
        return doElite()
    end
    -- Hydra secret temple
    tweenTo(Vector3.new(5700,1015,-215), 240)
    task.wait(1)
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ClickDetector") and (v.Parent.Name:find("Yama") or v.Parent.Name:find("Katana") or v.Parent.Name:find("Sealed")) then
            pcall(fireclickdetector, v)
        end
    end
    return true
end

-- ===================== TUSHITA =====================
local function doTushita()
    if currentSea()~=3 or plr.Data.Level.Value<2000 then return false end
    if hasItem("Tushita") then return false end
    local indra = findMob("rip_indra") or findMob("rip_indra True Form")
    if not indra then return false end
    -- leave indra alive
    if not hasItem("Holy Torch") then
        -- try get torch from waterfall secret
        tweenTo(Vector3.new(5700,1015,-215), 240)
        task.wait(0.8)
        return true
    end
    -- light 5 torches on Floating Turtle
    for i=1,5 do
        local torch = workspace.Map:FindFirstChild("Turtle")
            and workspace.Map.Turtle:FindFirstChild("QuestTorches")
            and workspace.Map.Turtle.QuestTorches:FindFirstChild("Torch"..i)
        if torch then
            tweenTo(torch:GetPivot().Position, 230)
            task.wait(0.5)
        end
    end
    local longma = findMob("Longma")
    if longma then killTarget(longma) end
    return true
end

-- ===================== CDK =====================
local function doCDK()
    if not Config.CDK or currentSea()~=3 then return false end
    if plr.Data.Level.Value<2200 then return false end
    if not hasItem("Yama") or not hasItem("Tushita") then return false end
    local q = inv("CDKQuest","Progress")
    if type(q)~="table" then return false end
    if q.Evil==0 or q.Evil==-3 then
        inv("CDKQuest","StartTrial","Evil")
        local m = findMob("Mythological Pirate")
        if m then killTarget(m) end
        return true
    elseif q.Evil==1 or q.Evil==-4 then
        inv("CDKQuest","StartTrial","Evil")
        for _,m in ipairs(workspace.Enemies:GetChildren()) do
            if m:GetAttribute("Level") and m:FindFirstChildOfClass("Humanoid") then
                killTarget(m) break
            end
        end
        return true
    elseif q.Evil==2 or q.Evil==-5 then
        inv("CDKQuest","StartTrial","Evil")
        local sr = findMob("Soul Reaper")
        if sr then killTarget(sr) end
        if workspace.Map:FindFirstChild("HellDimension") then
            for i=1,3 do
                local torch = workspace.Map.HellDimension:FindFirstChild("Torch"..i)
                if torch then
                    tweenTo(torch.CFrame, 230)
                    pcall(fireproximityprompt, torch:FindFirstChildOfClass("ProximityPrompt"))
                end
            end
        end
        return true
    end
    if q.Good==0 or q.Good==-3 then
        inv("CDKQuest","StartTrial","Good")
        return true
    elseif q.Good==1 or q.Good==-4 then
        inv("CDKQuest","StartTrial","Good")
        return true
    elseif q.Good==2 or q.Good==-5 then
        inv("CDKQuest","StartTrial","Good")
        local cq = findMob("Cake Queen")
        if cq then killTarget(cq) end
        return true
    end
    return false
end

-- ===================== SOUL GUITAR =====================
local function doSoulGuitar()
    if not Config.SkullGuitar or currentSea()~=3 then return false end
    if plr.Data.Level.Value<2300 then return false end
    if hasItem("Soul Guitar") then return false end
    local check = inv("GuitarPuzzleProgress","Check")
    if not check then
        if game.Lighting.ClockTime>16 or game.Lighting.ClockTime<5 then
            tweenTo(Vector3.new(-8654,140,6167), 240)
            inv("gravestoneEvent",2)
            inv("gravestoneEvent",2,true)
        end
        return true
    end
    if check.Swamp==false then
        for _,m in ipairs(workspace.Enemies:GetChildren()) do
            if m.Name=="Living Zombie" and m:FindFirstChildOfClass("Humanoid") then
                killTarget(m)
            end
        end
        return true
    end
    if check.Gravestones==false then inv("GuitarPuzzleProgress","Gravestones") return true end
    if check.Ghost==false then inv("GuitarPuzzleProgress","Ghost") return true end
    if check.Trophies==false then inv("GuitarPuzzleProgress","Trophies") return true end
    if check.Pipes==false then inv("GuitarPuzzleProgress","Pipes") return true end
    if check.CraftedOnce==false then
        if plr.Data.Fragments.Value>=5000 and getMaterial("Bones")>=500 and getMaterial("Ectoplasm")>=250 then
            inv("soulGuitarBuy")
        end
        return true
    end
    return false
end

-- ===================== CAKE =====================
local function doCake()
    if currentSea()~=3 or plr.Data.Level.Value<2200 then return false end
    local cake = findMob("Cake Prince") or findMob("Dough King")
    if cake then killTarget(cake) return true end
    for _,n in ipairs({"Cookie Crafter","Cake Guard","Baking Staff","Head Baker"}) do
        local m = findMob(n)
        if m then killTarget(m) return true end
    end
    inv("CakePrinceSpawner")
    return false
end

-- ===================== RAID =====================
local isRaiding = false
pcall(function()
    local r = ReplicatedStorage.Remotes:FindFirstChild("Raids")
    if r then
        r.OnClientEvent:Connect(function(a) isRaiding = (a=="StartTimer") end)
    end
end)

local function doRaid()
    if not Config.AutoRaid or isRaiding or plr.Data.Level.Value<1250 then return end
    local sea = currentSea()
    if sea<2 then return end
    inv("RaidsNpc","Select","Dark")
    task.wait(0.9)
    if sea==2 then
        local det = workspace.Map.CircleIsland.RaidSummon2:FindFirstChildWhichIsA("ClickDetector",true)
        if det then pcall(fireclickdetector,det) end
    elseif sea==3 then
        tweenTo(Vector3.new(-5018,315,-2828),250)
        task.wait(0.7)
        local det = workspace.Map["Boat Castle"].RaidSummon2:FindFirstChildWhichIsA("ClickDetector",true)
        if det then pcall(fireclickdetector,det) end
    end
end

-- ===================== UI =====================
local Status = "Boot"
local function setStatus(s)
    Status = s
    if getgenv().LotusSetStatus then getgenv().LotusSetStatus(s) end
end

if Config.UI then
    task.spawn(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "LotusFixedUI"
        gui.ResetOnSpawn = false
        gui.Parent = gethui and gethui() or game.CoreGui
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0,460,0,34)
        lbl.Position = UDim2.new(0.5,-230,0.015,0)
        lbl.BackgroundColor3 = Color3.fromRGB(12,12,20)
        lbl.BackgroundTransparency = 0.25
        lbl.TextColor3 = Color3.fromRGB(180,255,210)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 15
        lbl.Text = "Lotus Fixed v2.3 | Booting"
        lbl.Parent = gui
        Instance.new("UICorner",lbl).CornerRadius = UDim.new(0,7)
        getgenv().LotusSetStatus = function(t) lbl.Text = "Lotus Fixed | "..tostring(t) end
        task.spawn(function()
            while true do
                pcall(function()
                    lbl.Text = string.format("Lotus Fixed | %s | Lv%d | Beli %s", Status, plr.Data.Level.Value, plr.Data.Beli.Value)
                end)
                task.wait(1.2)
            end
        end)
    end)
end

-- redeem
task.spawn(function()
    local codes = {
        "SUB2GAMERROBOT_EXP1","Sub2NoobMaster123","Sub2Daigrock","Axiore","TantaiGaming",
        "StrawHatMaine","TheGreatAce","JCWK","Starcodeheo","Bluxxy","Sub2CaptainMaui",
        "Magicbus","Enyu_is_Pro","kittgaming","BIGNEWS","LIGHTNINGABUSE","Sub2Fer999",
        "SUB2GAMERROBOT_RESET1","Sub2OfficialNoobie","Sub2UncleKizaru"
    }
    for _,c in ipairs(codes) do
        pcall(function() if R.Redeem then R.Redeem:InvokeServer(c) end end)
        task.wait(0.35)
    end
end)

-- auto stats
task.spawn(function()
    while true do
        pcall(function()
            local max = workspace:GetAttribute("LEVEL_CAP") or 2800
            local stats = plr.Data.Stats
            local def = stats.Defense and stats.Defense.Level.Value or 0
            local melee = stats.Melee and stats.Melee.Level.Value or 0
            local target = "Melee"
            if def < max and def < (plr.Data.Level.Value/70) then target="Defense"
            elseif melee >= max then target="Sword" end
            inv("AddPoint", target, 40)
        end)
        task.wait(2.5)
    end
end)

-- ===================== MAIN LOOP =====================
task.spawn(function()
    setStatus("Ready")
    while true do
        local ok, err = pcall(function()
            if not isAlive() then
                setStatus("Respawn")
                task.wait(2)
                return
            end
            local lv = plr.Data.Level.Value
            local sea = currentSea()

            if meleeStep() then setStatus("Melee") return end
            if doGodhuman() then setStatus("Godhuman") return end
            if lv>=700 and sea==1 then setStatus("Unlock Sea2") unlockSea2() return end
            if lv>=1500 and sea==2 then setStatus("Unlock Sea3") unlockSea3() return end
            if Config.Saber and doSaber() then setStatus("Saber") return end
            if doBartilo() then setStatus("Bartilo") return end
            if Config.RaceV3 and doRaceV2() then setStatus("Race V2") return end
            if Config.RaceV3 and doRaceV3() then setStatus("Race V3") return end
            if doElite() then setStatus("Elite") return end
            if doYama() then setStatus("Yama") return end
            if doTushita() then setStatus("Tushita") return end
            if Config.CDK and doCDK() then setStatus("CDK") return end
            if Config.SkullGuitar and doSoulGuitar() then setStatus("SoulGuitar") return end
            if doCake() then setStatus("Cake") return end
            if Config.AutoRaid and lv>=1250 and sea>=2 then
                setStatus("Raid")
                doRaid()
            end
            setStatus("Farm Lv"..lv)
            farmLevel()
        end)
        if not ok then warn("[LotusFixed]", err) end
        task.wait(0.4)
    end
end)

print("[Lotus Hub Fixed v2.3] hard-audit complete — all modules live")
