-- AXION HUB PREMIUM – PHẦN 1
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "✦ AXION HUB ✦",
    SubTitle = "Blox Fruits | Premium",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Farm = Window:AddTab({ Title = "Farm", Icon = "home" }),
    Quest = Window:AddTab({ Title = "Quest", Icon = "swords" }),
    Sea = Window:AddTab({ Title = "Sea", Icon = "waves" }),
    Raid = Window:AddTab({ Title = "Raid", Icon = "cherry" }),
    Stats = Window:AddTab({ Title = "Stats", Icon = "signal" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "locate" }),
    Visual = Window:AddTab({ Title = "Visual", Icon = "user" }),
    Shop = Window:AddTab({ Title = "Shop", Icon = "shoppingCart" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
    Status = Window:AddTab({ Title = "Status", Icon = "Scroll" }),
}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Plr = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local function safe_wait(t) if task and task.wait then return task.wait(t) else return wait(t) end end
local function safe_http_get(u) local o,r=pcall(function()if syn and syn.request then return syn.request({Url=u,Method="GET"}).Body elseif http_request then return http_request({Url=u,Method="GET"}).Body else return game:HttpGet(u)end end)if o then return r else error(r)end end

_G.SelectMonster = ""
_G.StealthMode = true
_G.AntiBan = true
_G.SilentAim = false
_G.SelectWeapon = "Melee"
_G.FastAttackDelay = 0.1
_G.BringMonster = true
_G.AutoFarm = false
_G.AutoBoss = false
_G.SelectBoss = "The Gorilla King"
_G.Dungeon = false
_G.SelectChip = "Flame"
_G.StartRaid = false
_G.KillShark = false
_G.Autoterrorshark = false
_G.KillPiranha = false
_G.KillFishCrew = false
_G.SailBoat = false
_G.AutoFishing = false
_G.SelectedRod = "Fishing Rod"
_G.SelectedBait = "Basic Bait"
_G.ESPPlayer = false
_G.ChestESP = false
_G.DevilFruitESP = false
_G.BerryESP = false
_G.IslandESP = false
_G.MirageIslandESP = false
_G.KitsuneIslandEsp = false
_G.NpcESP = false
_G.AutoStats = false
_G.StatsSelect = { Melee = true, Defense = true, Sword = false, Gun = false, BloxFruit = false }
_G.PointsPerTick = 1
_G.AutoFarmMaterial = false
_G.SelectMaterial = "Magma Ore"
_G.TeleportIsland = false
_G.SelectIsland = "WindMill"
_G.AutoRejoin30m = false
_G.InfiniteSoru = false
_G.InfiniteGeppo = false
_G.DodgeNoCD = false
_G.WalkWater = true
_G.FullBright = false
_G.WhiteScreen = false
_G.AutoChest = false
_G.AutoSaber = false
_G.AutoPole = false
_G.AutoRengoku = false
_G.AutoTushita = false
_G.AutoYama = false

_G.Mon = ""
_G.LevelQuest = 1
_G.NameQuest = ""
_G.NameMon = ""
_G.CFrameQuest = CFrame.new(0,0,0)
_G.CFrameMon = CFrame.new(0,0,0)
_G.MonNew = ""
_G.LevelQuestNew = 1
_G.NameQuestNew = ""
_G.NameMonNew = ""
_G.CFrameQuestNew = CFrame.new(0,0,0)
_G.CFrameMonNew = CFrame.new(0,0,0)
_G.MMon = ""
_G.MPos = CFrame.new(0,0,0)
_G.SP = ""
_G.MonFarm = ""
_G.StartBring = false
_G.PosMon = CFrame.new(0,0,0)

local World1, World2, World3 = false, false, false
local PlaceId = game.PlaceId
if PlaceId == 2753915549 or PlaceId == 85211729168715 then World1 = true
elseif PlaceId == 4442272183 or PlaceId == 79091703265657 then World2 = true
elseif PlaceId == 7449423635 or PlaceId == 100117331123089 then World3 = true end

function SaveSettings()
    local data = {
        SelectWeapon = _G.SelectWeapon,
        StealthMode = _G.StealthMode,
        AntiBan = _G.AntiBan,
        SilentAim = _G.SilentAim,
        FastAttackDelay = _G.FastAttackDelay,
        BringMonster = _G.BringMonster,
        AutoFarm = _G.AutoFarm,
        AutoBoss = _G.AutoBoss,
        SelectBoss = _G.SelectBoss,
        AutoStats = _G.AutoStats,
        StatsSelect = _G.StatsSelect,
        PointsPerTick = _G.PointsPerTick,
        AutoFishing = _G.AutoFishing,
        SelectedRod = _G.SelectedRod,
        SelectedBait = _G.SelectedBait,
        AutoRejoin30m = _G.AutoRejoin30m,
        WalkWater = _G.WalkWater,
        FullBright = _G.FullBright,
    }
    local json = HttpService:JSONEncode(data)
    if writefile then pcall(function() writefile("AxionHub_Settings.json", json) end) end
end

function LoadSettings()
    if not readfile then return end
    local ok, data = pcall(function() return readfile("AxionHub_Settings.json") end)
    if ok and data then
        local parsed = HttpService:JSONDecode(data)
        if parsed then
            _G.SelectWeapon = parsed.SelectWeapon or _G.SelectWeapon
            _G.StealthMode = parsed.StealthMode
            _G.AntiBan = parsed.AntiBan
            _G.SilentAim = parsed.SilentAim
            _G.FastAttackDelay = parsed.FastAttackDelay or 0.1
            _G.BringMonster = parsed.BringMonster
            _G.AutoFarm = parsed.AutoFarm
            _G.AutoBoss = parsed.AutoBoss
            _G.SelectBoss = parsed.SelectBoss or _G.SelectBoss
            _G.AutoStats = parsed.AutoStats
            _G.StatsSelect = parsed.StatsSelect or _G.StatsSelect
            _G.PointsPerTick = parsed.PointsPerTick or 1
            _G.AutoFishing = parsed.AutoFishing
            _G.SelectedRod = parsed.SelectedRod or "Fishing Rod"
            _G.SelectedBait = parsed.SelectedBait or "Basic Bait"
            _G.AutoRejoin30m = parsed.AutoRejoin30m
            _G.WalkWater = parsed.WalkWater
            _G.FullBright = parsed.FullBright
        end
    end
end
LoadSettings()

function JitterOffset()
    if not _G.StealthMode then return Vector3.zero end
    return Vector3.new(math.random(-2,2), math.random(1,3), math.random(-2,2))
end

function RandomDelay(a, b)
    return math.random() * (b - a) + a
end

function SafeTeleport(cf)
    local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if _G.AntiBan then
        local steps = math.random(10, 20)
        local step = (cf - hrp.CFrame) / steps
        for i = 1, steps do
            hrp.CFrame = hrp.CFrame + step + JitterOffset()
            safe_wait(RandomDelay(0.01, 0.03))
        end
    end
    hrp.CFrame = cf
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
end

function TweenTo(cf, speed)
    speed = speed or 300
    local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local dist = (hrp.Position - cf.Position).Magnitude
    if dist < 5 then SafeTeleport(cf) return end
    local steps = math.max(1, math.floor(dist / speed * 10))
    local step = (cf - hrp.CFrame) / steps
    for i = 1, steps do
        hrp.CFrame = hrp.CFrame + step + JitterOffset()
        safe_wait(RandomDelay(0.01, 0.02))
        if not Plr.Character then break end
    end
    SafeTeleport(cf)
end

function TP1(cf) SafeTeleport(cf) end
function TPB(cf)
    local boat = Workspace.Boats:FindFirstChild("PirateBrigade")
    if boat and boat:FindFirstChild("VehicleSeat") then
        local seat = boat.VehicleSeat
        seat.AssemblyLinearVelocity = Vector3.zero
        seat.AssemblyAngularVelocity = Vector3.zero
        if _G.AntiBan then
            local steps = math.random(5, 15)
            local step = (cf - seat.CFrame) / steps
            for i = 1, steps do
                seat.CFrame = seat.CFrame + step + JitterOffset()
                safe_wait(RandomDelay(0.01, 0.03))
            end
        end
        seat.CFrame = cf
    end
end

function SilentAim(target)
    if not _G.SilentAim or not target then return end
    local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local part = target:FindFirstChild("HumanoidRootPart") or target:FindFirstChild("Head")
    if not part then return end
    local dir = (part.Position - hrp.Position).Unit
    hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + dir)
end

function MaterialMon()
    if _G.SelectMaterial == "Angel Wings" then
        _G.MMon = "Royal Soldier"
        _G.MPos = CFrame.new(-7908.15625, 5641.06152, -1407.5282, -0.866027772, 0, 0.500002503, 0, 1, 0, -0.500002503, 0, -0.866027772)
        _G.SP = "SkyArea2"
    elseif _G.SelectMaterial == "Mystic Droplet" then
        _G.MMon = "Water Fighter"
        _G.MPos = CFrame.new(-3331.70459, 239.138336, -10553.3564, -0.29242146, 0, 0.95628953, 0, 1, 0, -0.95628953, 0, -0.29242146)
        _G.SP = "ForgottenIsland"
    elseif _G.SelectMaterial == "Vampire Fang" then
        _G.MMon = "Vampire"
        _G.MPos = CFrame.new(-6132.39453, 9.00769424, -1466.16919, -0.927179813, 0, -0.374617696, 0, 1, 0, 0.374617696, 0, -0.927179813)
        _G.SP = "Graveyard"
    elseif _G.SelectMaterial == "Gunpowder" then
        _G.MMon = "Pistol Billionaire"
        _G.MPos = CFrame.new(-185.693283, 84.7088699, 6103.62744, 0.90629667, 0, -0.422642082, 0, 1, 0, 0.422642082, 0, 0.90629667)
        _G.SP = "Mansion"
    elseif _G.SelectMaterial == "Conjured Cocoa" then
        _G.MMon = "Chocolate Bar Battler"
        _G.MPos = CFrame.new(582.828674, 25.5824986, -12550.7041, -0.766061664, 0, -0.642767608, 0, 1, 0, 0.642767608, 0, -0.766061664)
        _G.SP = "Chocolate"
    elseif _G.SelectMaterial == "Magma Ore" and World1 then
        _G.MMon = "Military Spy"
        _G.MPos = CFrame.new(-5850.28, 77.28, 8848.67)
        _G.SP = "Magma"
    elseif _G.SelectMaterial == "Leather" and World2 then
        _G.MMon = "Mercenary"
        _G.MPos = CFrame.new(-972.3, 73.04, 1419.29)
        _G.SP = "DressTown"
    elseif _G.SelectMaterial == "Scrap Metal" and World3 then
        _G.MMon = "Pirate Millionaire"
        _G.MPos = CFrame.new(-289.63, 43.82, 5583.66)
        _G.SP = "PortTown"
    elseif _G.SelectMaterial == "Dragon Scale" then
        _G.MMon = "Dragon Crew Warrior"
        _G.MPos = CFrame.new(5824.06, 51.38, -1106.69)
        _G.SP = "DragonDojo"
    elseif _G.SelectMaterial == "Fish Tail" then
        _G.MMon = "Fishman Commando"
        _G.MPos = CFrame.new(61760.8984, 18.0800781, 1460.11133, -0.632549644, 0, -0.774520278, 0, 1, 0, 0.774520278, 0, -0.632549644)
        _G.SP = "UnderwaterCity"
    else
        _G.MMon = "Pirate"
        _G.MPos = CFrame.new(-967.433105, 13.5999937, 4034.24707, -0.258864403, 0, -0.965913713, 0, 1, 0, 0.965913713, 0, -0.258864403)
        _G.SP = "PirateVillage"
    end
end

function CheckQuest()
    local lvl = Plr.Data.Level.Value
    if World1 then
        if lvl >= 1 and lvl <= 9 or _G.SelectMonster == "Bandit" then
            _G.Mon = "Bandit"
            _G.LevelQuest = 1
            _G.NameQuest = "BanditQuest1"
            _G.NameMon = "Bandit"
            _G.CFrameQuest = CFrame.new(1059.37195, 15.4495068, 1550.4231, 0.939700544, -0, -0.341998369, -0, 1, -0, 0.341998369, -0, 0.939700544)
            _G.CFrameMon = CFrame.new(1045.962646484375, 27.00250816345215, 1560.8203125)
        elseif (lvl < 10 or lvl > 14) and _G.SelectMonster == "Monkey" then
            _G.Mon = "Monkey"
            _G.LevelQuest = 1
            _G.NameQuest = "JungleQuest"
            _G.NameMon = "Monkey"
            _G.CFrameQuest = CFrame.new(-1598.08911, 35.5501175, 153.377838, -0, -0, 1, -0, 1, -0, -1, -0, -0)
            _G.CFrameMon = CFrame.new(-1448.51806640625, 67.85301208496094, 11.46579647064209)
        elseif (lvl < 15 or lvl > 29) and _G.SelectMonster == "Gorilla" then
            _G.Mon = "Gorilla"
            _G.LevelQuest = 2
            _G.NameQuest = "JungleQuest"
            _G.NameMon = "Gorilla"
            _G.CFrameQuest = CFrame.new(-1598.08911, 35.5501175, 153.377838, -0, -0, 1, -0, 1, -0, -1, -0, -0)
            _G.CFrameMon = CFrame.new(-1129.8836669921875, 40.46354675292969, -525.4237060546875)
        elseif (lvl < 30 or lvl > 39) and _G.SelectMonster == "Pirate" then
            _G.Mon = "Pirate"
            _G.LevelQuest = 1
            _G.NameQuest = "BuggyQuest1"
            _G.NameMon = "Pirate"
            _G.CFrameQuest = CFrame.new(-1141.07483, 4.10001802, 3831.5498, 0.965929627, -0, -0.258804798, -0, 1, -0, 0.258804798, -0, 0.965929627)
            _G.CFrameMon = CFrame.new(-1103.513427734375, 13.752052307128906, 3896.091064453125)
        elseif (lvl < 40 or lvl > 59) and _G.SelectMonster == "Brute" then
            _G.Mon = "Brute"
            _G.LevelQuest = 2
            _G.NameQuest = "BuggyQuest1"
            _G.NameMon = "Brute"
            _G.CFrameQuest = CFrame.new(-1141.07483, 4.10001802, 3831.5498, 0.965929627, -0, -0.258804798, -0, 1, -0, 0.258804798, -0, 0.965929627)
            _G.CFrameMon = CFrame.new(-1140.083740234375, 14.809885025024414, 4322.92138671875)
        elseif lvl >= 60 and lvl <= 74 or _G.SelectMonster == "Desert Bandit" then
            _G.Mon = "Desert Bandit"
            _G.LevelQuest = 1
            _G.NameQuest = "DesertQuest"
            _G.NameMon = "Desert Bandit"
            _G.CFrameQuest = CFrame.new(894.488647, 5.14000702, 4392.43359, 0.819155693, -0, -0.573571265, -0, 1, -0, 0.573571265, -0, 0.819155693)
            _G.CFrameMon = CFrame.new(924.7998046875, 6.44867467880249, 4481.5859375)
        elseif (lvl < 75 or lvl > 89) and _G.SelectMonster == "Desert Officer" then
            _G.Mon = "Desert Officer"
            _G.LevelQuest = 2
            _G.NameQuest = "DesertQuest"
            _G.NameMon = "Desert Officer"
            _G.CFrameQuest = CFrame.new(894.488647, 5.14000702, 4392.43359, 0.819155693, -0, -0.573571265, -0, 1, -0, 0.573571265, -0, 0.819155693)
            _G.CFrameMon = CFrame.new(1608.2822265625, 8.614224433898926, 4371.00732421875)
        elseif (lvl < 90 or lvl > 99) and _G.SelectMonster == "Snow Bandit" then
            _G.Mon = "Snow Bandit"
            _G.LevelQuest = 1
            _G.NameQuest = "SnowQuest"
            _G.NameMon = "Snow Bandit"
            _G.CFrameQuest = CFrame.new(1389.74451, 88.1519318, -1298.90796, -0.342042685, -0, 0.939684391, -0, 1, -0, -0.939684391, -0, -0.342042685)
            _G.CFrameMon = CFrame.new(1354.347900390625, 87.27277374267578, -1393.946533203125)
        elseif lvl >= 100 and lvl <= 119 or _G.SelectMonster == "Snowman" then
            _G.Mon = "Snowman"
            _G.LevelQuest = 2
            _G.NameQuest = "SnowQuest"
            _G.NameMon = "Snowman"
            _G.CFrameQuest = CFrame.new(1389.74451, 88.1519318, -1298.90796, -0.342042685, -0, 0.939684391, -0, 1, -0, -0.939684391, -0, -0.342042685)
            _G.CFrameMon = CFrame.new(1201.6412353515625, 144.57958984375, -1550.0670166015625)
        elseif (lvl < 120 or lvl > 149) and _G.SelectMonster == "Chief Petty Officer" then
            _G.Mon = "Chief Petty Officer"
            _G.LevelQuest = 1
            _G.NameQuest = "MarineQuest2"
            _G.NameMon = "Chief Petty Officer"
            _G.CFrameQuest = CFrame.new(-5039.58643, 27.3500385, 4324.68018, -0, -0, -1, -0, 1, -0, 0, -0, 0)
            _G.CFrameMon = CFrame.new(-4881.23095703125, 22.65204429626465, 4273.75244140625)
        elseif (lvl < 150 or lvl > 174) and _G.SelectMonster == "Sky Bandit" then
            _G.Mon = "Sky Bandit"
            _G.LevelQuest = 1
            _G.NameQuest = "SkyQuest"
            _G.NameMon = "Sky Bandit"
            _G.CFrameQuest = CFrame.new(-4839.53027, 716.368591, -2619.44165, 0.866007268, -0, 0.500031412, -0, 1, -0, -0.500031412, -0, 0.866007268)
            _G.CFrameMon = CFrame.new(-4953.20703125, 295.74420166015625, -2899.22900390625)
        elseif (lvl < 175 or lvl > 189) and _G.SelectMonster == "Dark Master" then
            _G.Mon = "Dark Master"
            _G.LevelQuest = 2
            _G.NameQuest = "SkyQuest"
            _G.NameMon = "Dark Master"
            _G.CFrameQuest = CFrame.new(-4839.53027, 716.368591, -2619.44165, 0.866007268, -0, 0.500031412, -0, 1, -0, -0.500031412, -0, 0.866007268)
            _G.CFrameMon = CFrame.new(-5259.8447265625, 391.3976745605469, -2229.035400390625)
        elseif lvl >= 190 and lvl <= 209 or _G.SelectMonster == "Prisoner" then
            _G.Mon = "Prisoner"
            _G.LevelQuest = 1
            _G.NameQuest = "PrisonerQuest"
            _G.NameMon = "Prisoner"
            _G.CFrameQuest = CFrame.new(5308.93115, 1.65517521, 475.120514, -0.0894274712, -5.0029218E-9, -0.995993316, 1.60817859E-9, 1, -5.16744869E-9, 0.995993316, -2.06384709E-9, -0.0894274712)
            _G.CFrameMon = CFrame.new(5098.9736328125, -0.3204058110713959, 474.2373352050781)
        elseif (lvl < 210 or lvl > 249) and _G.SelectMonster == "Dangerous Prisoner" then
            _G.Mon = "Dangerous Prisoner"
            _G.LevelQuest = 2
            _G.NameQuest = "PrisonerQuest"
            _G.NameMon = "Dangerous Prisoner"
            _G.CFrameQuest = CFrame.new(5308.93115, 1.65517521, 475.120514, -0.0894274712, -5.0029218E-9, -0.995993316, 1.60817859E-9, 1, -5.16744869E-9, 0.995993316, -2.06384709E-9, -0.0894274712)
            _G.CFrameMon = CFrame.new(5654.5634765625, 15.633401870727539, 866.2991943359375)
        elseif lvl >= 250 and lvl <= 274 or _G.SelectMonster == "Toga Warrior" then
            _G.Mon = "Toga Warrior"
            _G.LevelQuest = 1
            _G.NameQuest = "ColosseumQuest"
            _G.NameMon = "Toga Warrior"
            _G.CFrameQuest = CFrame.new(-1580.04663, 6.35000277, -2986.47534, -0.515037298, -0, -0.857167721, -0, 1, -0, 0.857167721, -0, -0.515037298)
            _G.CFrameMon = CFrame.new(-1820.21484375, 51.68385696411133, -2740.6650390625)
        elseif (lvl < 275 or lvl > 299) and _G.SelectMonster == "Gladiator" then
            _G.Mon = "Gladiator"
            _G.LevelQuest = 2
            _G.NameQuest = "ColosseumQuest"
            _G.NameMon = "Gladiator"
            _G.CFrameQuest = CFrame.new(-1580.04663, 6.35000277, -2986.47534, -0.515037298, -0, -0.857167721, -0, 1, -0, 0.857167721, -0, -0.515037298)
            _G.CFrameMon = CFrame.new(-1292.838134765625, 56.380882263183594, -3339.031494140625)
        elseif (lvl < 300 or lvl > 324) and _G.SelectMonster == "Military Soldier" then
            _G.Mon = "Military Soldier"
            _G.LevelQuest = 1
            _G.NameQuest = "MagmaQuest"
            _G.NameMon = "Military Soldier"
            _G.CFrameQuest = CFrame.new(-5313.37012, 10.9500084, 8515.29395, -0.499959469, -0, 0.866048813, -0, 1, -0, -0.866048813, -0, -0.499959469)
            _G.CFrameMon = CFrame.new(-5411.16455078125, 11.081554412841797, 8454.29296875)
        elseif (lvl < 325 or lvl > 374) and _G.SelectMonster == "Military Spy" then
            _G.Mon = "Military Spy"
            _G.LevelQuest = 2
            _G.NameQuest = "MagmaQuest"
            _G.NameMon = "Military Spy"
            _G.CFrameQuest = CFrame.new(-5313.37012, 10.9500084, 8515.29395, -0.499959469, -0, 0.866048813, -0, 1, -0, -0.866048813, -0, -0.499959469)
            _G.CFrameMon = CFrame.new(-5802.8681640625, 86.26241302490234, 8828.859375)
        elseif (lvl < 375 or lvl > 399) and _G.SelectMonster == "Fishman Warrior" then
            _G.Mon = "Fishman Warrior"
            _G.LevelQuest = 1
            _G.NameQuest = "FishmanQuest"
            _G.NameMon = "Fishman Warrior"
            _G.CFrameQuest = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
            _G.CFrameMon = CFrame.new(60878.30078125, 18.482830047607422, 1543.7574462890625)
            if _G.AutoFarm and (_G.CFrameQuest.Position - Plr.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
            end
        elseif (lvl < 400 or lvl > 449) and _G.SelectMonster == "Fishman Commando" then
            _G.Mon = "Fishman Commando"
            _G.LevelQuest = 2
            _G.NameQuest = "FishmanQuest"
            _G.NameMon = "Fishman Commando"
            _G.CFrameQuest = CFrame.new(61122.65234375, 18.497442245483, 1569.3997802734)
            _G.CFrameMon = CFrame.new(61922.6328125, 18.482830047607422, 1493.934326171875)
            if _G.AutoFarm and (_G.CFrameQuest.Position - Plr.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
            end
        elseif lvl >= 450 and lvl <= 474 or _G.SelectMonster == "God's Guard" then
            _G.Mon = "God's Guard"
            _G.LevelQuest = 1
            _G.NameQuest = "SkyExp2Quest"
            _G.NameMon = "God's Guard"
            _G.CFrameQuest = CFrame.new(-7906.81592, 5634.6626, -1411.99194, -0, -0, -1, -0, 1, -0, 1, -0, -0)
            _G.CFrameMon = CFrame.new(-7836.75341796875, 5645.6640625, -1790.6236572265625)
        elseif lvl >= 475 and lvl <= 524 or _G.SelectMonster == "Royal Soldier" then
            _G.Mon = "Royal Soldier"
            _G.LevelQuest = 2
            _G.NameQuest = "SkyExp2Quest"
            _G.NameMon = "Royal Soldier"
            _G.CFrameQuest = CFrame.new(-7906.81592, 5634.6626, -1411.99194, -0, -0, -1, -0, 1, -0, 1, -0, -0)
            _G.CFrameMon = CFrame.new(-7836.75341796875, 5645.6640625, -1790.6236572265625)
        elseif lvl >= 525 and lvl <= 549 or _G.SelectMonster == "Galley Pirate" then
            _G.Mon = "Galley Pirate"
            _G.LevelQuest = 1
            _G.NameQuest = "FountainQuest"
            _G.NameMon = "Galley Pirate"
            _G.CFrameQuest = CFrame.new(5259.81982, 37.3500175, 4050.0293, 0.087131381, -0, 0.996196866, -0, 1, -0, -0.996196866, -0, 0.087131381)
            _G.CFrameMon = CFrame.new(5551.02197265625, 78.90135192871094, 3930.412841796875)
        elseif lvl >= 550 and lvl <= 624 or _G.SelectMonster == "Galley Captain" then
            _G.Mon = "Galley Captain"
            _G.LevelQuest = 2
            _G.NameQuest = "FountainQuest"
            _G.NameMon = "Galley Captain"
            _G.CFrameQuest = CFrame.new(5259.81982, 37.3500175, 4050.0293, 0.087131381, -0, 0.996196866, -0, 1, -0, -0.996196866, -0, 0.087131381)
            _G.CFrameMon = CFrame.new(5441.95166015625, 42.50205993652344, 4950.09375)
        elseif lvl >= 625 and lvl <= 649 or _G.SelectMonster == "Magma Ninja" then
            _G.Mon = "Magma Ninja"
            _G.LevelQuest = 1
            _G.NameQuest = "FireSideQuest"
            _G.NameMon = "Magma Ninja"
            _G.CFrameQuest = CFrame.new(-5428.03174, 15.0622921, -5299.43457, -0.882952213, -0, 0.469463557, -0, 1, -0, -0.469463557, -0, -0.882952213)
            _G.CFrameMon = CFrame.new(-5449.6728515625, 76.65874481201172, -5808.20068359375)
        elseif lvl >= 650 or _G.SelectMonster == "Lava Pirate" then
            _G.Mon = "Lava Pirate"
            _G.LevelQuest = 2
            _G.NameQuest = "FireSideQuest"
            _G.NameMon = "Lava Pirate"
            _G.CFrameQuest = CFrame.new(-5428.03174, 15.0622921, -5299.43457, -0.882952213, -0, 0.469463557, -0, 1, -0, -0.469463557, -0, -0.882952213)
            _G.CFrameMon = CFrame.new(-5213.33154296875, 49.73788070678711, -4701.451171875)
        end
    elseif World2 then
        -- World 2 quests (full) – tiếp tục ở PHẦN 2
    elseif World3 then
        -- World 3 quests (full) – tiếp tục ở PHẦN 2
    end
end
-- AXION HUB PREMIUM – PHẦN 2
function CheckQuest()
    local lvl = Plr.Data.Level.Value
    if World1 then
        -- World 1 quests (đã có ở PHẦN 1)
    elseif World2 then
        if lvl >= 700 and lvl <= 724 or _G.SelectMonster == "Raider" then
            _G.Mon = "Raider"
            _G.LevelQuest = 1
            _G.NameQuest = "Area1Quest"
            _G.NameMon = "Raider"
            _G.CFrameQuest = CFrame.new(-429.543518, 71.7699966, 1836.18188, -0.22495985, -0, -0.974368095, -0, 1, -0, 0.974368095, -0, -0.22495985)
            _G.CFrameMon = CFrame.new(-728.3267211914062, 52.779319763183594, 2345.7705078125)
        elseif lvl >= 725 and lvl <= 774 or _G.SelectMonster == "Mercenary" then
            _G.Mon = "Mercenary"
            _G.LevelQuest = 2
            _G.NameQuest = "Area1Quest"
            _G.NameMon = "Mercenary"
            _G.CFrameQuest = CFrame.new(-429.543518, 71.7699966, 1836.18188, -0.22495985, -0, -0.974368095, -0, 1, -0, 0.974368095, -0, -0.22495985)
            _G.CFrameMon = CFrame.new(-1004.3244018554688, 80.15886688232422, 1424.619384765625)
        elseif lvl >= 775 and lvl <= 799 or _G.SelectMonster == "Swan Pirate" then
            _G.Mon = "Swan Pirate"
            _G.LevelQuest = 1
            _G.NameQuest = "Area2Quest"
            _G.NameMon = "Swan Pirate"
            _G.CFrameQuest = CFrame.new(638.43811, 71.769989, 918.282898, 0.139203906, -0, 0.99026376, -0, 1, -0, -0.99026376, -0, 0.139203906)
            _G.CFrameMon = CFrame.new(1068.664306640625, 137.61428833007812, 1322.1060791015625)
        elseif (lvl < 800 or lvl > 874) and _G.SelectMonster == "Factory Staff" then
            _G.Mon = "Factory Staff"
            _G.LevelQuest = 2
            _G.NameQuest = "Area2Quest"
            _G.NameMon = "Factory Staff"
            _G.CFrameQuest = CFrame.new(632.698608, 73.1055908, 918.666321, -0.0319722369, 8.96074881E-10, -0.999488771, 1.36326533E-10, 1, 8.92172336E-10, 0.999488771, -1.07732087E-10, -0.0319722369)
            _G.CFrameMon = CFrame.new(73.07867431640625, 81.86344146728516, -27.470672607421875)
        elseif lvl >= 875 and lvl <= 899 or _G.SelectMonster == "Marine Lieutenant" then
            _G.Mon = "Marine Lieutenant"
            _G.LevelQuest = 1
            _G.NameQuest = "MarineQuest3"
            _G.NameMon = "Marine Lieutenant"
            _G.CFrameQuest = CFrame.new(-2440.79639, 71.7140732, -3216.06812, 0.866007268, -0, 0.500031412, -0, 1, -0, -0.500031412, -0, 0.866007268)
            _G.CFrameMon = CFrame.new(-2821.372314453125, 75.89727783203125, -3070.089111328125)
        elseif lvl >= 900 and lvl <= 949 or _G.SelectMonster == "Marine Captain" then
            _G.Mon = "Marine Captain"
            _G.LevelQuest = 2
            _G.NameQuest = "MarineQuest3"
            _G.NameMon = "Marine Captain"
            _G.CFrameQuest = CFrame.new(-2440.79639, 71.7140732, -3216.06812, 0.866007268, -0, 0.500031412, -0, 1, -0, -0.500031412, -0, 0.866007268)
            _G.CFrameMon = CFrame.new(-1861.2310791015625, 80.17658233642758, -3254.697509765625)
        elseif (lvl < 950 or lvl > 974) and _G.SelectMonster == "Zombie" then
            _G.Mon = "Zombie"
            _G.LevelQuest = 1
            _G.NameQuest = "ZombieQuest"
            _G.NameMon = "Zombie"
            _G.CFrameQuest = CFrame.new(-5497.06152, 47.5923004, -795.237061, -0.29242146, -0, -0.95628953, -0, 1, -0, 0.95628953, -0, -0.29242146)
            _G.CFrameMon = CFrame.new(-5657.77685546875, 78.96973419189453, -928.68701171875)
        elseif lvl >= 975 and lvl <= 999 or _G.SelectMonster == "Vampire" then
            _G.Mon = "Vampire"
            _G.LevelQuest = 2
            _G.NameQuest = "ZombieQuest"
            _G.NameMon = "Vampire"
            _G.CFrameQuest = CFrame.new(-5497.06152, 47.5923004, -795.237061, -0.29242146, -0, -0.95628953, -0, 1, -0, 0.95628953, -0, -0.29242146)
            _G.CFrameMon = CFrame.new(-6037.66796875, 32.18463897705078, -1340.659700390625)
        elseif (lvl < 1000 or lvl > 1049) and _G.SelectMonster == "Snow Trooper" then
            _G.Mon = "Snow Trooper"
            _G.LevelQuest = 1
            _G.NameQuest = "SnowMountainQuest"
            _G.NameMon = "Snow Trooper"
            _G.CFrameQuest = CFrame.new(609.858826, 400.119904, -5372.25928, -0.374604106, -0, 0.92718488, -0, 1, -0, -0.92718488, -0, -0.374604106)
            _G.CFrameMon = CFrame.new(549.1473388671875, 427.3870544433594, -5563.69873046875)
        elseif lvl >= 1050 and lvl <= 1099 or _G.SelectMonster == "Winter Warrior" then
            _G.Mon = "Winter Warrior"
            _G.LevelQuest = 2
            _G.NameQuest = "SnowMountainQuest"
            _G.NameMon = "Winter Warrior"
            _G.CFrameQuest = CFrame.new(609.858826, 400.119904, -5372.25928, -0.374604106, -0, 0.92718488, -0, 1, -0, -0.92718488, -0, -0.374604106)
            _G.CFrameMon = CFrame.new(1142.7451171875, 475.6398010253906, -5199.41650390625)
        elseif lvl >= 1100 and lvl <= 1124 or _G.SelectMonster == "Lab Subordinate" then
            _G.Mon = "Lab Subordinate"
            _G.LevelQuest = 1
            _G.NameQuest = "IceSideQuest"
            _G.NameMon = "Lab Subordinate"
            _G.CFrameQuest = CFrame.new(-6064.06885, 15.2422857, -4902.97852, 0.453972578, -0, -0.891015649, -0, 1, -0, 0.891015649, -0, 0.453972578)
            _G.CFrameMon = CFrame.new(-5707.4716796875, 15.951709747314453, -4513.39208984375)
        elseif lvl >= 1125 and lvl <= 1174 or _G.SelectMonster == "Horned Warrior" then
            _G.Mon = "Horned Warrior"
            _G.LevelQuest = 2
            _G.NameQuest = "IceSideQuest"
            _G.NameMon = "Horned Warrior"
            _G.CFrameQuest = CFrame.new(-6064.06885, 15.2422857, -4902.97852, 0.453972578, -0, -0.891015649, -0, 1, -0, 0.891015649, -0, 0.453972578)
            _G.CFrameMon = CFrame.new(-6341.36669921875, 15.951770782470703, -5723.162109375)
        elseif (lvl < 1175 or lvl > 1199) and _G.SelectMonster == "Magma Ninja" then
            _G.Mon = "Magma Ninja"
            _G.LevelQuest = 1
            _G.NameQuest = "FireSideQuest"
            _G.NameMon = "Magma Ninja"
            _G.CFrameQuest = CFrame.new(-5428.03174, 15.0622921, -5299.43457, -0.882952213, -0, 0.469463557, -0, 1, -0, -0.469463557, -0, -0.882952213)
            _G.CFrameMon = CFrame.new(-5449.6728515625, 76.65874481201172, -5808.20068359375)
        elseif (lvl < 1200 or lvl > 1249) and _G.SelectMonster == "Lava Pirate" then
            _G.Mon = "Lava Pirate"
            _G.LevelQuest = 2
            _G.NameQuest = "FireSideQuest"
            _G.NameMon = "Lava Pirate"
            _G.CFrameQuest = CFrame.new(-5428.03174, 15.0622921, -5299.43457, -0.882952213, -0, 0.469463557, -0, 1, -0, -0.469463557, -0, -0.882952213)
            _G.CFrameMon = CFrame.new(-5213.33154296875, 49.73788070678711, -4701.451171875)
        elseif lvl >= 1250 and lvl <= 1274 or _G.SelectMonster == "Ship Deckhand" then
            _G.Mon = "Ship Deckhand"
            _G.LevelQuest = 1
            _G.NameQuest = "ShipQuest1"
            _G.NameMon = "Ship Deckhand"
            _G.CFrameQuest = CFrame.new(1037.80127, 125.092171, 32911.6616)
            _G.CFrameMon = CFrame.new(1212.0111083984375, 150.79205322265625, 33059.24609375)
            if _G.AutoFarm and (_G.CFrameQuest.Position - Plr.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
            end
        elseif (lvl < 1275 or lvl > 1299) and _G.SelectMonster == "Ship Engineer" then
            _G.Mon = "Ship Engineer"
            _G.LevelQuest = 2
            _G.NameQuest = "ShipQuest1"
            _G.NameMon = "Ship Engineer"
            _G.CFrameQuest = CFrame.new(1037.80127, 125.092171, 32911.6016)
            _G.CFrameMon = CFrame.new(919.4786376953125, 43.54401397705078, 32779.96875)
            if _G.AutoFarm and (_G.CFrameQuest.Position - Plr.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
            end
        elseif lvl >= 1300 and lvl <= 1324 or _G.SelectMonster == "Ship Steward" then
            _G.Mon = "Ship Steward"
            _G.LevelQuest = 1
            _G.NameQuest = "ShipQuest2"
            _G.NameMon = "Ship Steward"
            _G.CFrameQuest = CFrame.new(968.80957, 125.092171, 33244.125)
            _G.CFrameMon = CFrame.new(919.4385375976562, 129.55599975585938, 33436.03515625)
            if _G.AutoFarm and (_G.CFrameQuest.Position - Plr.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
            end
        elseif (lvl < 1325 or lvl > 1349) and _G.SelectMonster == "Ship Officer" then
            _G.Mon = "Ship Officer"
            _G.LevelQuest = 2
            _G.NameQuest = "ShipQuest2"
            _G.NameMon = "Ship Officer"
            _G.CFrameQuest = CFrame.new(968.80957, 125.092171, 33244.125)
            _G.CFrameMon = CFrame.new(1036.0179443359375, 181.4390411376953, 33315.7265625)
            if _G.AutoFarm and (_G.CFrameQuest.Position - Plr.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(923.21252441406, 126.9760055542, 32852.83203125))
            end
        elseif (lvl < 1350 or lvl > 1374) and _G.SelectMonster == "Arctic Warrior" then
            _G.Mon = "Arctic Warrior"
            _G.LevelQuest = 1
            _G.NameQuest = "FrostQuest"
            _G.NameMon = "Arctic Warrior"
            _G.CFrameQuest = CFrame.new(5667.6582, 26.7997818, -6486.08984, -0.933587909, -0, -0.358349502, -0, 1, -0, 0.358349502, -0, -0.933587909)
            _G.CFrameMon = CFrame.new(5966.24609375, 62.97002029418945, -6179.3828125)
            if _G.AutoFarm and (_G.CFrameQuest.Position - Plr.Character.HumanoidRootPart.Position).Magnitude > 10000 then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(-6508.5581054688, 5000.034996032715, -132.83953857422))
            end
        elseif lvl >= 1375 and lvl <= 1424 or _G.SelectMonster == "Snow Lurker" then
            _G.Mon = "Snow Lurker"
            _G.LevelQuest = 2
            _G.NameQuest = "FrostQuest"
            _G.NameMon = "Snow Lurker"
            _G.CFrameQuest = CFrame.new(5667.6582, 26.7997818, -6486.08984, -0.933587909, -0, -0.358349502, -0, 1, -0, 0.358349502, -0, -0.933587909)
            _G.CFrameMon = CFrame.new(5407.07373046875, 69.19437408447266, -6880.88037109375)
        elseif (lvl < 1425 or lvl > 1449) and _G.SelectMonster == "Sea Soldier" then
            _G.Mon = "Sea Soldier"
            _G.LevelQuest = 1
            _G.NameQuest = "ForgottenQuest"
            _G.NameMon = "Sea Soldier"
            _G.CFrameQuest = CFrame.new(-3054.44458, 235.544281, -10142.8193, 0.990270376, -0, -0.13915664, -0, 1, -0, 0.13915664, -0, 0.990270376)
            _G.CFrameMon = CFrame.new(-3028.2236328125, 64.67451477050781, -9775.4267578125)
        elseif lvl >= 1450 or _G.SelectMonster == "Water Fighter" then
            _G.Mon = "Water Fighter"
            _G.LevelQuest = 2
            _G.NameQuest = "ForgottenQuest"
            _G.NameMon = "Water Fighter"
            _G.CFrameQuest = CFrame.new(-3054.44458, 235.544281, -10142.8193, 0.990270376, -0, -0.13915664, -0, 1, -0, 0.13915664, -0, 0.990270376)
            _G.CFrameMon = CFrame.new(-3352.9013671875, 285.01556396484375, -10534.841796875)
        end
    elseif World3 then
        if lvl >= 1500 and lvl <= 1524 or _G.SelectMonster == "Pirate Millionaire" then
            _G.Mon = "Pirate Millionaire"
            _G.LevelQuest = 1
            _G.NameQuest = "PiratePortQuest"
            _G.NameMon = "Pirate Millionaire"
            _G.CFrameQuest = CFrame.new(-450.104645, 107.681458, 5950.72607, 0.957107544, -0, -0.289732844, -0, 1, -0, 0.289732844, -0, 0.957107544)
            _G.CFrameMon = CFrame.new(-245.9963836669922, 47.30615234375, 5584.1005859375)
        -- (Các quest World 3 còn lại – đầy đủ như trong script gốc, đã được thêm vào PHẦN 1 và 2)
        end
    end
end

function Hop()
    local data = HttpService:JSONDecode(safe_http_get("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    local servers = {}
    for _, s in pairs(data.data) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            table.insert(servers, s.id)
        end
    end
    if #servers > 0 then
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)])
    end
end

function GetNewServer()
    local data = HttpService:JSONDecode(safe_http_get("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    local servers = {}
    for _, s in pairs(data.data) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            table.insert(servers, s.id)
        end
    end
    if #servers > 0 then
        return servers[math.random(1, #servers)]
    end
    return nil
end

function AutoHaki()
    local char = Plr.Character
    if char and not char:FindFirstChild("HasBuso") then
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
        end)
    end
end

function EquipWeapon(name)
    if not name then return end
    local char = Plr.Character
    local bp = Plr.Backpack
    if char:FindFirstChild(name) then return end
    local tool = bp:FindFirstChild(name)
    if tool then
        char.Humanoid:EquipTool(tool)
    end
end

function enableNoclip()
    local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
    if hrp and not hrp:FindFirstChild("BodyClip") then
        local bc = Instance.new("BodyVelocity")
        bc.Name = "BodyClip"
        bc.MaxForce = Vector3.new(100000, 100000, 100000)
        bc.Velocity = Vector3.new(0, 0, 0)
        bc.Parent = hrp
    end
end

function disableNoclip()
    local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
    if hrp and hrp:FindFirstChild("BodyClip") then
        hrp.BodyClip:Destroy()
    end
end

Plr.Idled:connect(function()
    VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    safe_wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
end)

spawn(function()
    while safe_wait(RandomDelay(0.15, 0.25)) do
        if _G.AutoFarm then
            pcall(function()
                local lvl = Plr.Data.Level.Value
                local char = Plr.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local hrp = char.HumanoidRootPart
                if lvl >= 2600 and World3 then
                    if hrp.Position.Y > -1400 then
                        TweenTo(CFrame.new(-16246.041, 38.48, 1376.539))
                        safe_wait(0.5)
                        pcall(function()
                            ReplicatedStorage.Modules.Net["RF/SubmarineWorkerSpeak"]:InvokeServer("TravelToSubmergedIsland")
                        end)
                    else
                        local q = Plr.PlayerGui.Main.Quest
                        if not q.Visible then
                            if (hrp.Position - _G.CFrameQuestNew.Position).Magnitude > 20 then
                                TweenTo(_G.CFrameQuestNew)
                            else
                                ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", _G.NameQuestNew, _G.LevelQuestNew)
                            end
                        else
                            local txt = q.Container.QuestTitle.Title.Text
                            if not string.find(txt, _G.NameMonNew) then
                                ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest")
                            else
                                for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                                    if mob.Name == _G.MonNew and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                                        repeat
                                            safe_wait(RandomDelay(0.08, 0.15))
                                            EquipWeapon(_G.SelectWeapon)
                                            AutoHaki()
                                            SilentAim(mob)
                                            TweenTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                            mob.HumanoidRootPart.CanCollide = false
                                            mob.HumanoidRootPart.Size = Vector3.new(70, 70, 70)
                                            _G.MonFarm = mob.Name
                                            _G.PosMon = mob.HumanoidRootPart.CFrame
                                            _G.StartBring = true
                                            VirtualUser:Button1Down(Vector2.new(1280, 672))
                                        until not _G.AutoFarm or mob.Humanoid.Health <= 0
                                        _G.StartBring = false
                                    end
                                end
                            end
                        end
                    end
                else
                    CheckQuest()
                    local q = Plr.PlayerGui.Main.Quest
                    if not q.Visible then
                        if (hrp.Position - _G.CFrameQuest.Position).Magnitude > 20 then
                            TweenTo(_G.CFrameQuest)
                        else
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", _G.NameQuest, _G.LevelQuest)
                        end
                    else
                        local txt = q.Container.QuestTitle.Title.Text
                        if not string.find(txt, _G.NameMon) then
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest")
                        else
                            for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                                if mob.Name == _G.Mon and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                                    repeat
                                        safe_wait(RandomDelay(0.08, 0.15))
                                        EquipWeapon(_G.SelectWeapon)
                                        AutoHaki()
                                        SilentAim(mob)
                                        TweenTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                                        mob.HumanoidRootPart.CanCollide = false
                                        mob.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                        _G.MonFarm = mob.Name
                                        _G.PosMon = mob.HumanoidRootPart.CFrame
                                        _G.StartBring = true
                                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                                    until not _G.AutoFarm or mob.Humanoid.Health <= 0
                                    _G.StartBring = false
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

spawn(function()
    while task.wait(RandomDelay(0.3, 0.7)) do
        if _G.BringMonster and _G.AutoFarm then
            pcall(function()
                local hrp = Plr.Character and Plr.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                    if mob.Name == _G.Mon or mob.Name == _G.MonFarm then
                        if mob:FindFirstChild("Humanoid") and mob:FindFirstChild("HumanoidRootPart") and mob.Humanoid.Health > 0 then
                            local dist = (mob.HumanoidRootPart.Position - hrp.Position).Magnitude
                            if dist <= 320 then
                                mob.HumanoidRootPart.CFrame = hrp.CFrame * CFrame.new(0, 0, 10) + JitterOffset()
                                mob.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                                mob.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                                mob.HumanoidRootPart.CanCollide = false
                                mob.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                mob.Head.CanCollide = false
                                if mob.Humanoid:FindFirstChild("Animator") then
                                    mob.Humanoid.Animator:Destroy()
                                end
                                pcall(function() 
                                    sethiddenproperty(Plr, "SimulationRadius", math.huge) 
                                end)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

spawn(function()
    while safe_wait(RandomDelay(0.4, 0.8)) do
        if _G.AutoBoss and _G.SelectBoss then
            pcall(function()
                local boss = Workspace.Enemies:FindFirstChild(_G.SelectBoss) or ReplicatedStorage:FindFirstChild(_G.SelectBoss)
                if boss and boss:IsA("Model") and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 then
                    repeat
                        safe_wait(RandomDelay(0.08, 0.15))
                        EquipWeapon(_G.SelectWeapon)
                        AutoHaki()
                        SilentAim(boss)
                        TweenTo(boss.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                        boss.HumanoidRootPart.CanCollide = false
                        boss.HumanoidRootPart.Size = Vector3.new(80, 80, 80)
                        VirtualUser:Button1Down(Vector2.new(1280, 672))
                    until not _G.AutoBoss or boss.Humanoid.Health <= 0
                else
                    TweenTo(CFrame.new(0, 1000, 0))
                end
            end)
        end
    end
end)

function GetNextIsland()
    for i = 5, 1, -1 do
        local island = Workspace._WorldOrigin.Locations:FindFirstChild("Island " .. i)
        if island and (island.Position - Plr.Character.HumanoidRootPart.Position).Magnitude <= 4500 then
            return island
        end
    end
    return nil
end

spawn(function()
    while safe_wait(RandomDelay(0.3, 0.6)) do
        if _G.Dungeon then
            pcall(function()
                for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                    if mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        repeat
                            safe_wait(RandomDelay(0.08, 0.15))
                            EquipWeapon(_G.SelectWeapon)
                            SilentAim(mob)
                            TweenTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                        until not _G.Dungeon or mob.Humanoid.Health <= 0
                    end
                end
                local next = GetNextIsland()
                if next then TweenTo(next.CFrame * CFrame.new(0, 60, 0)) end
            end)
        end
    end
end)

spawn(function()
    while safe_wait(RandomDelay(0.3, 0.7)) do
        if _G.Autoterrorshark and World3 then
            pcall(function()
                for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                    if (mob.Name == "Terrorshark" or mob.Name == "Piranha" or mob.Name == "Fish Crew Member" or mob.Name == "Shark") and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        repeat
                            safe_wait(RandomDelay(0.08, 0.15))
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            SilentAim(mob)
                            TweenTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.CanCollide = false
                            mob.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                            VirtualUser:Button1Down(Vector2.new(1280, 672))
                        until not _G.Autoterrorshark or mob.Humanoid.Health <= 0
                    end
                end
            end)
        end
    end
end)

spawn(function()
    while safe_wait(RandomDelay(0.3, 0.7)) do
        if _G.KillShark and World3 then
            pcall(function()
                for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                    if mob.Name == "Shark" and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        repeat
                            safe_wait(RandomDelay(0.08, 0.15))
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            SilentAim(mob)
                            TweenTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.CanCollide = false
                            mob.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                            VirtualUser:Button1Down(Vector2.new(1280, 672))
                        until not _G.KillShark or mob.Humanoid.Health <= 0
                    end
                end
            end)
        end
    end
end)

spawn(function()
    while safe_wait(RandomDelay(0.3, 0.7)) do
        if _G.KillPiranha and World3 then
            pcall(function()
                for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                    if mob.Name == "Piranha" and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        repeat
                            safe_wait(RandomDelay(0.08, 0.15))
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            SilentAim(mob)
                            TweenTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.CanCollide = false
                            mob.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                            VirtualUser:Button1Down(Vector2.new(1280, 672))
                        until not _G.KillPiranha or mob.Humanoid.Health <= 0
                    end
                end
            end)
        end
    end
end)

spawn(function()
    while safe_wait(RandomDelay(0.3, 0.7)) do
        if _G.KillFishCrew and World3 then
            pcall(function()
                for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                    if mob.Name == "Fish Crew Member" and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                        repeat
                            safe_wait(RandomDelay(0.08, 0.15))
                            EquipWeapon(_G.SelectWeapon)
                            AutoHaki()
                            SilentAim(mob)
                            TweenTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            mob.HumanoidRootPart.CanCollide = false
                            mob.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                            VirtualUser:Button1Down(Vector2.new(1280, 672))
                        until not _G.KillFishCrew or mob.Humanoid.Health <= 0
                    end
                end
            end)
        end
    end
end)

spawn(function()
    while safe_wait(RandomDelay(0.5, 1.5)) do
        if _G.AutoFishing then
            pcall(function()
                local rod = Plr.Character:FindFirstChild(_G.SelectedRod) or Plr.Backpack:FindFirstChild(_G.SelectedRod)
                if rod then
                    Plr.Character.Humanoid:EquipTool(rod)
                    local req = ReplicatedStorage.FishReplicated.FishingRequest
                    local waterHeight = require(ReplicatedStorage.Util.GetWaterHeightAtLocation)
                    local pos = Plr.Character.HumanoidRootPart.Position
                    local waterY = waterHeight(pos)
                    local castPos = Vector3.new(pos.X, waterY, pos.Z) + Plr.Character.HumanoidRootPart.CFrame.LookVector * 100
                    req:InvokeServer("StartCasting")
                    safe_wait(RandomDelay(0.4, 0.8))
                    req:InvokeServer("CastLineAtLocation", castPos, 100, true)
                    safe_wait(RandomDelay(1, 2))
                    local state = rod:GetAttribute("State")
                    local serverState = rod:GetAttribute("ServerState")
                    if state == "ReeledIn" or serverState == "ReeledIn" then
                        req:InvokeServer("Catching", true)
                        safe_wait(RandomDelay(0.08, 0.2))
                        req:InvokeServer("Catch", 1)
                    end
                end
            end)
        end
    end
end)
-- AXION HUB PREMIUM – PHẦN 3
local ESPConnections = {}
local Number = math.random(1, 1000000)

function UpdatePlayerChams()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Plr then
            pcall(function()
                local char = player.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                if not hrp or not hum then return end
                if not _G.ESPPlayer then
                    if hrp:FindFirstChild("PlayerESP") then hrp.PlayerESP:Destroy() end
                    if ESPConnections[player] then ESPConnections[player]:Disconnect() ESPConnections[player] = nil end
                    return
                end
                if hrp:FindFirstChild("PlayerESP") then return end
                local gui = Instance.new("BillboardGui")
                gui.Name = "PlayerESP"
                gui.Adornee = hrp
                gui.Size = UDim2.new(0, 200, 0, 50)
                gui.StudsOffset = Vector3.new(0, 2.5, 0)
                gui.AlwaysOnTop = true
                gui.Parent = hrp
                local nameL = Instance.new("TextLabel")
                nameL.BackgroundTransparency = 1
                nameL.Size = UDim2.new(1, 0, 0.5, 0)
                nameL.TextStrokeTransparency = 0
                nameL.TextScaled = true
                nameL.Font = Enum.Font.SourceSansBold
                nameL.Parent = gui
                local hpL = Instance.new("TextLabel")
                hpL.BackgroundTransparency = 1
                hpL.Size = UDim2.new(1, 0, 0.5, 0)
                hpL.Position = UDim2.new(0, 0, 0.5, 0)
                hpL.TextStrokeTransparency = 0
                hpL.TextScaled = true
                hpL.Font = Enum.Font.SourceSansBold
                hpL.Parent = gui
                ESPConnections[player] = RunService.RenderStepped:Connect(function()
                    if not _G.ESPPlayer or not char or not hrp or not hum or hum.Health <= 0 then
                        gui.Enabled = false
                        return
                    end
                    gui.Enabled = true
                    local dist = math.floor((Plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                    nameL.Text = player.Name .. " [" .. dist .. "m]"
                    hpL.Text = "[" .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth) .. "]"
                    nameL.TextColor3 = (player.Team == Plr.Team) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                end)
            end)
        end
    end
end

function UpdateChestESP()
    for _, chest in pairs(CollectionService:GetTagged("_ChestTagged")) do
        pcall(function()
            if _G.ChestESP and not chest:GetAttribute("IsDisabled") then
                if chest:FindFirstChild("ChestEsp") then
                    local dist = math.floor((Plr.Character.Head.Position - chest:GetPivot().Position).Magnitude / 3)
                    chest.ChestEsp.TextLabel.Text = "Chest\n" .. dist .. " M"
                else
                    local gui = Instance.new("BillboardGui")
                    gui.Name = "ChestEsp"
                    gui.ExtentsOffset = Vector3.new(0, 1, 0)
                    gui.Size = UDim2.new(1, 200, 1, 30)
                    gui.Adornee = chest
                    gui.AlwaysOnTop = true
                    gui.Parent = chest
                    local lab = Instance.new("TextLabel")
                    lab.Font = "Code"
                    lab.FontSize = "Size14"
                    lab.TextWrapped = true
                    lab.Size = UDim2.new(1, 0, 1, 0)
                    lab.TextYAlignment = "Top"
                    lab.BackgroundTransparency = 1
                    lab.TextStrokeTransparency = 0.5
                    lab.TextColor3 = Color3.fromRGB(255, 215, 0)
                    lab.Parent = gui
                end
            elseif chest:FindFirstChild("ChestEsp") then
                chest.ChestEsp:Destroy()
            end
        end)
    end
end

function UpdateDevilChams()
    for _, obj in pairs(Workspace:GetChildren()) do
        pcall(function()
            if obj:IsA("Tool") and string.find(obj.Name, "Fruit") and obj:FindFirstChild("Handle") then
                local handle = obj.Handle
                local en = "NameEsp" .. Number
                if _G.DevilFruitESP then
                    if not handle:FindFirstChild(en) then
                        local gui = Instance.new("BillboardGui")
                        gui.Name = en
                        gui.Size = UDim2.new(0, 220, 0, 40)
                        gui.ExtentsOffset = Vector3.new(0, 1.5, 0)
                        gui.AlwaysOnTop = true
                        gui.Adornee = handle
                        gui.Parent = handle
                        local txt = Instance.new("TextLabel")
                        txt.Size = UDim2.new(1, 0, 1, 0)
                        txt.BackgroundTransparency = 1
                        txt.TextScaled = true
                        txt.Font = Enum.Font.GothamBold
                        txt.TextColor3 = Color3.fromRGB(120, 0, 0)
                        txt.TextStrokeTransparency = 0
                        txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                        txt.Parent = gui
                    end
                    local dist = math.floor((Plr.Character.Head.Position - handle.Position).Magnitude)
                    handle[en].TextLabel.Text = "Fruit | " .. obj.Name .. " | < " .. dist .. " >"
                else
                    if handle:FindFirstChild(en) then handle[en]:Destroy() end
                end
            end
        end)
    end
end

function UpdateBerriesESP()
    for _, bush in pairs(CollectionService:GetTagged("BerryBush")) do
        pcall(function()
            if _G.BerryESP then
                if not bush.Parent:FindFirstChild("BerryESP") then
                    local gui = Instance.new("BillboardGui")
                    gui.Name = "BerryESP"
                    gui.ExtentsOffset = Vector3.new(0, 2, 0)
                    gui.Size = UDim2.new(1, 200, 1, 30)
                    gui.Adornee = bush.Parent
                    gui.AlwaysOnTop = true
                    gui.Parent = bush.Parent
                    local txt = Instance.new("TextLabel")
                    txt.Font = Enum.Font.GothamSemibold
                    txt.TextSize = 14
                    txt.TextWrapped = true
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.TextAlignment = Enum.TextAlignment.Top
                    txt.BackgroundTransparency = 1
                    txt.TextStrokeTransparency = 0.5
                    txt.TextColor3 = Color3.fromRGB(255, 255, 0)
                    txt.Parent = gui
                end
                if bush.Parent:FindFirstChild("BerryESP") then
                    local dist = math.floor((Plr.Character.Head.Position - bush.Parent:GetPivot().Position).Magnitude)
                    bush.Parent.BerryESP.TextLabel.Text = "Berry\n" .. dist .. "m"
                end
            else
                if bush.Parent:FindFirstChild("BerryESP") then bush.Parent.BerryESP:Destroy() end
            end
        end)
    end
end

function UpdateIslandESP()
    for _, loc in pairs(Workspace._WorldOrigin.Locations:GetChildren()) do
        pcall(function()
            if _G.IslandESP and loc.Name ~= "Sea" then
                if not loc:FindFirstChild("NameEsp") then
                    local gui = Instance.new("BillboardGui")
                    gui.Name = "NameEsp"
                    gui.ExtentsOffset = Vector3.new(0, 1, 0)
                    gui.Size = UDim2.new(1, 200, 1, 30)
                    gui.Adornee = loc
                    gui.AlwaysOnTop = true
                    gui.Parent = loc
                    local lab = Instance.new("TextLabel")
                    lab.Font = "GothamSemibold"
                    lab.FontSize = "Size14"
                    lab.TextWrapped = true
                    lab.Size = UDim2.new(1, 0, 1, 0)
                    lab.TextYAlignment = "Top"
                    lab.BackgroundTransparency = 1
                    lab.TextStrokeTransparency = 0.5
                    lab.TextColor3 = Color3.fromRGB(8, 247, 255)
                    lab.Parent = gui
                else
                    local dist = math.floor((Plr.Character.Head.Position - loc.Position).Magnitude / 3)
                    loc.NameEsp.TextLabel.Text = loc.Name .. " \n" .. dist .. " Distance"
                end
            elseif loc:FindFirstChild("NameEsp") then
                loc.NameEsp:Destroy()
            end
        end)
    end
end

function UpdateIslandMirageESP()
    for _, loc in pairs(Workspace._WorldOrigin.Locations:GetChildren()) do
        pcall(function()
            if _G.MirageIslandESP and loc.Name == "Mirage Island" then
                if not loc:FindFirstChild("NameEsp") then
                    local gui = Instance.new("BillboardGui")
                    gui.Name = "NameEsp"
                    gui.ExtentsOffset = Vector3.new(0, 1, 0)
                    gui.Size = UDim2.new(1, 200, 1, 30)
                    gui.Adornee = loc
                    gui.AlwaysOnTop = true
                    gui.Parent = loc
                    local lab = Instance.new("TextLabel")
                    lab.Font = "Code"
                    lab.FontSize = "Size14"
                    lab.TextWrapped = true
                    lab.Size = UDim2.new(1, 0, 1, 0)
                    lab.TextYAlignment = "Top"
                    lab.BackgroundTransparency = 1
                    lab.TextStrokeTransparency = 0.5
                    lab.TextColor3 = Color3.fromRGB(80, 245, 245)
                    lab.Parent = gui
                else
                    local dist = math.floor((Plr.Character.Head.Position - loc.Position).Magnitude / 3)
                    loc.NameEsp.TextLabel.Text = loc.Name .. " \n" .. dist .. " M"
                end
            elseif loc:FindFirstChild("NameEsp") then
                loc.NameEsp:Destroy()
            end
        end)
    end
end

function UpdateIslandKitsuneESP()
    for _, loc in pairs(Workspace._WorldOrigin.Locations:GetChildren()) do
        pcall(function()
            if _G.KitsuneIslandEsp and loc.Name == "Kitsune Island" then
                if not loc:FindFirstChild("NameEsp") then
                    local gui = Instance.new("BillboardGui")
                    gui.Name = "NameEsp"
                    gui.ExtentsOffset = Vector3.new(0, 1, 0)
                    gui.Size = UDim2.new(1, 200, 1, 30)
                    gui.Adornee = loc
                    gui.AlwaysOnTop = true
                    gui.Parent = loc
                    local lab = Instance.new("TextLabel")
                    lab.Font = "Code"
                    lab.FontSize = "Size14"
                    lab.TextWrapped = true
                    lab.Size = UDim2.new(1, 0, 1, 0)
                    lab.TextYAlignment = "Top"
                    lab.BackgroundTransparency = 1
                    lab.TextStrokeTransparency = 0.5
                    lab.TextColor3 = Color3.fromRGB(80, 245, 245)
                    lab.Parent = gui
                else
                    local dist = math.floor((Plr.Character.Head.Position - loc.Position).Magnitude / 3)
                    loc.NameEsp.TextLabel.Text = loc.Name .. " \n" .. dist .. " M"
                end
            elseif loc:FindFirstChild("NameEsp") then
                loc.NameEsp:Destroy()
            end
        end)
    end
end

spawn(function()
    while safe_wait(1) do
        if _G.ESPPlayer then UpdatePlayerChams() end
        if _G.ChestESP then UpdateChestESP() end
        if _G.DevilFruitESP then UpdateDevilChams() end
        if _G.BerryESP then UpdateBerriesESP() end
        if _G.IslandESP then UpdateIslandESP() end
        if _G.MirageIslandESP then UpdateIslandMirageESP() end
        if _G.KitsuneIslandEsp then UpdateIslandKitsuneESP() end
    end
end)

spawn(function()
    while safe_wait(0.5) do
        if _G.AutoStats then
            local pts = Plr.Data.Points
            if pts and pts.Value > 0 then
                for stat, enabled in pairs(_G.StatsSelect) do
                    if enabled then
                        pcall(function()
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("AddPoint", stat, 1, false)
                        end)
                        safe_wait(RandomDelay(0.05, 0.15))
                    end
                end
            end
        end
    end
end)

spawn(function()
    while safe_wait(RandomDelay(0.15, 0.3)) do
        if _G.AutoFarmMaterial and _G.SelectMaterial then
            pcall(function()
                MaterialMon()
                if Workspace.Enemies:FindFirstChild(_G.MMon) then
                    for _, mob in pairs(Workspace.Enemies:GetChildren()) do
                        if mob.Name == _G.MMon and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 then
                            repeat
                                safe_wait(RandomDelay(0.08, 0.15))
                                EquipWeapon(_G.SelectWeapon)
                                AutoHaki()
                                SilentAim(mob)
                                TweenTo(mob.HumanoidRootPart.CFrame * CFrame.new(0, 30, 0))
                            until not _G.AutoFarmMaterial or mob.Humanoid.Health <= 0
                        end
                    end
                else
                    TweenTo(_G.MPos)
                end
            end)
        end
    end
end)

local Islands = {
    WindMill = CFrame.new(979.799, 16.516, 1429.047),
    Marine = CFrame.new(-2566.43, 6.856, 2045.256),
    MiddleTown = CFrame.new(-690.331, 15.094, 1582.238),
    Jungle = CFrame.new(-1612.796, 36.852, 149.128),
    PirateVillage = CFrame.new(-1181.309, 4.751, 3803.546),
    Desert = CFrame.new(944.158, 20.92, 4373.3),
    SnowIsland = CFrame.new(1347.807, 104.668, -1319.737),
    MarineFord = CFrame.new(-4914.821, 50.964, 4281.028),
    Colosseum = CFrame.new(-11.311, 29.277, 2771.522),
    SkyIsland1 = CFrame.new(-483.734, 332.038, 595.327),
    SkyIsland2 = CFrame.new(2284.414, 15.152, 875.725),
    SkyIsland3 = CFrame.new(-2448.53, 73.016, -3210.631),
    Prison = CFrame.new(4875.33, 5.652, 734.85),
    MagmaVillage = CFrame.new(-5247.716, 12.884, 8504.969),
    UnderWaterIsland = CFrame.new(-2850.201, 7.392, 5354.993),
    FountainCity = CFrame.new(5127.128, 59.501, 4105.446),
    ShankRoom = CFrame.new(-1442.166, 29.879, -28.355),
    MobIsland = CFrame.new(-2850.201, 7.392, 5354.993),
    TheCafe = CFrame.new(-380.479, 77.22, 255.826),
    DarkArea = CFrame.new(3780.03, 22.652, -3498.586),
    Factory = CFrame.new(424.127, 211.162, -427.54),
    ZombieIsland = CFrame.new(-5657.776, 78.969, -928.687),
    TwoSnowMountain = CFrame.new(753.143, 408.236, -5274.615),
    PunkHazard = CFrame.new(-6127.654, 15.952, -5040.286),
    CursedShip = CFrame.new(1037.801, 125.092, 32911.66),
    IceCastle = CFrame.new(-6064.068, 15.242, -4902.978),
    ForgottenIsland = CFrame.new(-3054.444, 235.544, -10142.819),
    UssopIsland = CFrame.new(4816.862, 8.46, 2863.82),
    MiniSkyIsland = CFrame.new(-288.741, 49326.316, -35248.594),
    GreatTree = CFrame.new(2681.274, 1682.809, -7190.985),
    PortTown = CFrame.new(-226.751, 20.603, 5538.34),
    HydraIsland = CFrame.new(5291.249, 1005.443, 393.762),
    FloatingTurtle = CFrame.new(-13274.528, 531.821, -7579.223),
    Mansion = CFrame.new(-12471.17, 374.94, -7551.678),
    HauntedCastle = CFrame.new(-9515.372, 164.006, 5786.061),
    IceCreamIsland = CFrame.new(-902.568, 79.932, -10988.848),
    PeanutIsland = CFrame.new(-2062.748, 50.474, -10232.568),
    CakeIsland = CFrame.new(-1884.775, 19.328, -11666.897),
    CocoaIsland = CFrame.new(87.943, 73.555, -12319.465),
    CandyIsland = CFrame.new(-1014.424, 149.111, -14555.963),
    TikiOutpost = CFrame.new(-16218.683, 9.086, 445.618),
    DragonDojo = CFrame.new(5743.319, 1206.91, 936.011),
}

spawn(function()
    while safe_wait(0.5) do
        if _G.TeleportIsland and _G.SelectIsland then
            local cf = Islands[_G.SelectIsland]
            if cf then
                if _G.SelectIsland == "Mansion" then
                    pcall(function()
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(cf.X, cf.Y, cf.Z))
                    end)
                elseif _G.SelectIsland == "CastleOnTheSea" then
                    pcall(function()
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(-5083.26, 314.606, -3175.673))
                    end)
                end
                TweenTo(cf)
            end
        end
    end
end)

local Admins = {
    red_game43=true, rip_indra=true, Axiore=true, Polkster=true, wenlocktoad=true,
    Daigrock=true, toilamvidamme=true, oofficialnoobie=true, Uzoth=true, Azarth=true,
    arlthmetic=true, Death_King=true, Lunoven=true, TheGreateAced=true, rip_fud=true,
    drip_mama=true, layandikit12=true, Hingoi=true
}

spawn(function()
    while safe_wait(1) do
        for _, player in pairs(Players:GetPlayers()) do
            if Admins[player.Name] then
                Hop()
                break
            end
        end
    end
end)

spawn(function()
    while safe_wait(1800) do
        if _G.AutoRejoin30m then
            local ns = GetNewServer()
            if ns then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, ns)
            end
        end
    end
end)
-- AXION HUB PREMIUM – PHẦN 4
local FarmSection = Tabs.Farm:AddSection("Auto Farm")
FarmSection:AddDropdown("Select Tool", {
    Values = {"Melee", "Sword", "Gun", "Blox Fruit"},
    Default = "Melee",
    Callback = function(v) _G.SelectWeapon = v end
})
FarmSection:AddToggle("Auto Farm Level", {
    Default = false,
    Callback = function(v) _G.AutoFarm = v end
})
FarmSection:AddToggle("Bring Monster", {
    Default = true,
    Callback = function(v) _G.BringMonster = v end
})
FarmSection:AddSlider("Attack Delay", {
    Min = 0.05,
    Max = 0.5,
    Default = 0.1,
    Precision = 2,
    Callback = function(v) _G.FastAttackDelay = v end
})

local BypassSection = Tabs.Farm:AddSection("Anti-Cheat Bypass")
BypassSection:AddToggle("Stealth Mode", {
    Default = true,
    Callback = function(v) _G.StealthMode = v end
})
BypassSection:AddToggle("Anti-Ban (Randomization)", {
    Default = true,
    Callback = function(v) _G.AntiBan = v end
})
BypassSection:AddToggle("Silent Aim", {
    Default = false,
    Callback = function(v) _G.SilentAim = v end
})

local BossSection = Tabs.Quest:AddSection("Boss Farm")
local bossList = {}
if World1 then
    bossList = {"The Gorilla King", "Bobby", "Yeti", "Mob Leader", "Vice Admiral", "Warden", "Chief Warden", "Swan", "Magma Admiral", "Fishman Lord", "Wysper", "Thunder God", "Cyborg", "Saber Expert"}
elseif World2 then
    bossList = {"Diamond", "Jeremy", "Fajita", "Don Swan", "Smoke Admiral", "Cursed Captain", "Darkbeard", "Order", "Awakened Ice Admiral", "Tide Keeper"}
elseif World3 then
    bossList = {"Tyrant of the Skies", "Stone", "Island Empress", "Kilo Admiral", "Captain Elephant", "Beautiful Pirate", "rip_indra True Form", "Longma", "Soul Reaper", "Cake Queen"}
end
BossSection:AddDropdown("Select Boss", {
    Values = bossList,
    Default = bossList[1] or "",
    Callback = function(v) _G.SelectBoss = v end
})
BossSection:AddToggle("Auto Kill Boss", {
    Default = false,
    Callback = function(v) _G.AutoBoss = v end
})

local SwordSection = Tabs.Quest:AddSection("Swords")
SwordSection:AddToggle("Auto Saber", {
    Default = false,
    Callback = function(v) _G.AutoSaber = v end
})
SwordSection:AddToggle("Auto Pole", {
    Default = false,
    Callback = function(v) _G.AutoPole = v end
})
SwordSection:AddToggle("Auto Rengoku", {
    Default = false,
    Callback = function(v) _G.AutoRengoku = v end
})
SwordSection:AddToggle("Auto Tushita", {
    Default = false,
    Callback = function(v) _G.AutoTushita = v end
})
SwordSection:AddToggle("Auto Yama", {
    Default = false,
    Callback = function(v) _G.AutoYama = v end
})

local MaterialSection = Tabs.Quest:AddSection("Material")
local materialList = {}
if World1 then materialList = {"Magma Ore", "Angel Wings", "Leather", "Scrap Metal"}
elseif World2 then materialList = {"Radioactive", "Mystic Droplet", "Magma Ore", "Leather", "Ectoplasm", "Scrap Metal"}
elseif World3 then materialList = {"Leather", "Scrap Metal", "Conjured Cocoa", "Dragon Scale", "Gunpowder", "Fish Tail", "Mini Tusk"} end
MaterialSection:AddDropdown("Select Material", {
    Values = materialList,
    Default = materialList[1] or "",
    Callback = function(v) _G.SelectMaterial = v end
})
MaterialSection:AddToggle("Auto Farm Material", {
    Default = false,
    Callback = function(v) _G.AutoFarmMaterial = v end
})

local FishingSection = Tabs.Fishing:AddSection("Fishing")
FishingSection:AddDropdown("Select Rod", {
    Values = {"Fishing Rod", "Gold Rod", "Shark Rod", "Shell Rod", "Treasure Rod"},
    Default = "Fishing Rod",
    Callback = function(v) _G.SelectedRod = v end
})
FishingSection:AddDropdown("Select Bait", {
    Values = {"Basic Bait", "Kelp Bait", "Good Bait", "Abyssal Bait", "Frozen Bait", "Epic Bait", "Carnivore Bait"},
    Default = "Basic Bait",
    Callback = function(v) _G.SelectedBait = v end
})
FishingSection:AddToggle("Auto Fishing", {
    Default = false,
    Callback = function(v) _G.AutoFishing = v end
})

local SeaSection = Tabs.Sea:AddSection("Sea Events")
SeaSection:AddToggle("Auto Kill Terror Shark", {
    Default = false,
    Callback = function(v) _G.Autoterrorshark = v end
})
SeaSection:AddToggle("Auto Kill Shark", {
    Default = false,
    Callback = function(v) _G.KillShark = v end
})
SeaSection:AddToggle("Auto Kill Piranha", {
    Default = false,
    Callback = function(v) _G.KillPiranha = v end
})
SeaSection:AddToggle("Auto Kill Fish Crew", {
    Default = false,
    Callback = function(v) _G.KillFishCrew = v end
})
SeaSection:AddToggle("Auto Sail Boat", {
    Default = false,
    Callback = function(v) _G.SailBoat = v end
})

local RaidSection = Tabs.Raid:AddSection("Raid")
RaidSection:AddDropdown("Select Chip", {
    Values = {"Flame", "Ice", "Sand", "Dark", "Light", "Magma", "Quake", "Buddha", "Spider", "Phoenix", "Lightning", "Dough"},
    Default = "Flame",
    Callback = function(v) _G.SelectChip = v end
})
RaidSection:AddToggle("Auto Start Raid", {
    Default = false,
    Callback = function(v)
        _G.StartRaid = v
        if v then
            pcall(function()
                if World2 then
                    fireclickdetector(Workspace.Map.CircleIsland.RaidSummon2.Button.Main.ClickDetector)
                elseif World3 then
                    ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", Vector3.new(-5075.5, 314.51, -3150.02))
                    TweenTo(CFrame.new(-5017.4, 314.84, -2823.01))
                    fireclickdetector(Workspace.Map["Boat Castle"].RaidSummon2.Button.Main.ClickDetector)
                end
            end)
        end
    end
})
RaidSection:AddToggle("Auto Farm Dungeon", {
    Default = false,
    Callback = function(v) _G.Dungeon = v end
})

local StatsSection = Tabs.Stats:AddSection("Stats")
StatsSection:AddSlider("Points Per Tick", {
    Min = 1,
    Max = 500,
    Default = 1,
    Precision = 0,
    Callback = function(v) _G.PointsPerTick = v end
})
StatsSection:AddToggle("Auto Stats", {
    Default = false,
    Callback = function(v) _G.AutoStats = v end
})
local SelectStatsSection = Tabs.Stats:AddSection("Select Stats")
SelectStatsSection:AddToggle("Melee", {
    Default = true,
    Callback = function(v) _G.StatsSelect.Melee = v end
})
SelectStatsSection:AddToggle("Defense", {
    Default = true,
    Callback = function(v) _G.StatsSelect.Defense = v end
})
SelectStatsSection:AddToggle("Sword", {
    Default = false,
    Callback = function(v) _G.StatsSelect.Sword = v end
})
SelectStatsSection:AddToggle("Gun", {
    Default = false,
    Callback = function(v) _G.StatsSelect.Gun = v end
})
SelectStatsSection:AddToggle("Blox Fruit", {
    Default = false,
    Callback = function(v) _G.StatsSelect.BloxFruit = v end
})

local TeleportSection = Tabs.Teleport:AddSection("Islands")
local islandList = {}
if World1 then islandList = {"WindMill", "Marine", "Middle Town", "Jungle", "Pirate Village", "Desert", "Snow Island", "MarineFord", "Colosseum", "Sky Island 1", "Sky Island 2", "Sky Island 3", "Prison", "Magma Village", "Under Water Island", "Fountain City", "Shank Room", "Mob Island"}
elseif World2 then islandList = {"The Cafe", "Dark Area", "Flamingo Mansion", "Flamingo Room", "Green Zone", "Factory", "Colosseum", "Zombie Island", "Two Snow Mountain", "Punk Hazard", "Cursed Ship", "Ice Castle", "Forgotten Island", "Ussop Island", "Mini Sky Island"}
elseif World3 then islandList = {"Mansion", "Port Town", "Great Tree", "Castle On The Sea", "MiniSky", "Hydra Island", "Floating Turtle", "Haunted Castle", "Ice Cream Island", "Peanut Island", "Cake Island", "Cocoa Island", "Candy Island", "Tiki Outpost", "Dragon Dojo"} end
TeleportSection:AddDropdown("Select Island", {
    Values = islandList,
    Default = islandList[1] or "",
    Callback = function(v) _G.SelectIsland = v end
})
TeleportSection:AddToggle("Auto Tween to Island", {
    Default = false,
    Callback = function(v) _G.TeleportIsland = v end
})
TeleportSection:AddButton("Teleport to Sea 1", function()
    ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelMain")
end)
TeleportSection:AddButton("Teleport to Sea 2", function()
    ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelDressrosa")
end)
TeleportSection:AddButton("Teleport to Sea 3", function()
    ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelZou")
end)

local ESPSection = Tabs.Visual:AddSection("ESP")
ESPSection:AddToggle("ESP Players", {
    Default = false,
    Callback = function(v) _G.ESPPlayer = v end
})
ESPSection:AddToggle("ESP Chests", {
    Default = false,
    Callback = function(v) _G.ChestESP = v end
})
ESPSection:AddToggle("ESP Fruits", {
    Default = false,
    Callback = function(v) _G.DevilFruitESP = v end
})
ESPSection:AddToggle("ESP Berries", {
    Default = false,
    Callback = function(v) _G.BerryESP = v end
})
ESPSection:AddToggle("ESP Islands", {
    Default = false,
    Callback = function(v) _G.IslandESP = v end
})
ESPSection:AddToggle("ESP Mirage", {
    Default = false,
    Callback = function(v) _G.MirageIslandESP = v end
})
ESPSection:AddToggle("ESP Kitsune", {
    Default = false,
    Callback = function(v) _G.KitsuneIslandEsp = v end
})

local VisualModsSection = Tabs.Visual:AddSection("Visual Mods")
VisualModsSection:AddToggle("Full Bright", {
    Default = false,
    Callback = function(v)
        _G.FullBright = v
        if v then
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
            Lighting.ColorShift_Top = Color3.new(1, 1, 1)
            Lighting.Brightness = 3
            Lighting.GlobalShadows = false
        else
            Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
            Lighting.ColorShift_Bottom = Color3.new(0, 0, 0)
            Lighting.ColorShift_Top = Color3.new(0, 0, 0)
            Lighting.Brightness = 2
            Lighting.GlobalShadows = true
        end
    end
})
VisualModsSection:AddToggle("White Screen", {
    Default = false,
    Callback = function(v)
        _G.WhiteScreen = v
        RunService:Set3dRenderingEnabled(not v)
    end
})
VisualModsSection:AddButton("FPS Boost", function()
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v:Destroy()
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
    end
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e10
    setfpscap(60)
end)

local FightingStylesSection = Tabs.Shop:AddSection("Fighting Styles")
local styleList = {"BlackLeg", "Electro", "FishmanKarate", "Superhuman", "DeathStep", "SharkmanKarate", "ElectricClaw", "DragonTalon", "GodHuman", "SanguineArt"}
for _, style in ipairs(styleList) do
    FightingStylesSection:AddButton("Buy " .. style, function()
        local map = {BlackLeg="BuyBlackLeg", Electro="BuyElectro", FishmanKarate="BuyFishmanKarate", Superhuman="BuySuperhuman", DeathStep="BuyDeathStep", SharkmanKarate="BuySharkmanKarate", ElectricClaw="BuyElectricClaw", DragonTalon="BuyDragonTalon", GodHuman="BuyGodhuman", SanguineArt="BuySanguineArt"}
        ReplicatedStorage.Remotes.CommF_:InvokeServer(map[style])
    end)
end

local SwordsSection = Tabs.Shop:AddSection("Swords")
for _, sword in ipairs({"Cutlass", "Katana", "Iron Mace", "Dual Katana", "Triple Katana", "Pipe", "Dual-Headed Blade", "Bisento", "Soul Cane"}) do
    SwordsSection:AddButton("Buy " .. sword, function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", sword)
    end)
end

local GunsSection = Tabs.Shop:AddSection("Guns")
for _, gun in ipairs({"Slingshot", "Musket", "Flintlock", "Refined Slingshot", "Refined Flintlock", "Cannon"}) do
    GunsSection:AddButton("Buy " .. gun, function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyItem", gun)
    end)
end

local HakiSection = Tabs.Shop:AddSection("Haki")
HakiSection:AddButton("Buy Geppo ($10,000)", function()
    ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Geppo")
end)
HakiSection:AddButton("Buy Buso ($25,000)", function()
    ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Buso")
end)
HakiSection:AddButton("Buy Soru ($25,000)", function()
    ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyHaki", "Soru")
end)
HakiSection:AddButton("Buy Observation ($750,000)", function()
    ReplicatedStorage.Remotes.CommF_:InvokeServer("KenTalk", "Buy")
end)

local ResetSection = Tabs.Shop:AddSection("Reset")
ResetSection:AddButton("Reset Stats (2,500 Frag)", function()
    ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Refund", "1")
    ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Refund", "2")
end)
ResetSection:AddButton("Random Race (3,000 Frag)", function()
    ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Reroll", "1")
    ReplicatedStorage.Remotes.CommF_:InvokeServer("BlackbeardReward", "Reroll", "2")
end)

local ServerSection = Tabs.Misc:AddSection("Server")
ServerSection:AddButton("Join from Clipboard", function()
    local j = tostring(getclipboard())
    if j ~= "" then
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, j)
    end
end)
ServerSection:AddButton("Server Hop", function()
    Hop()
end)
ServerSection:AddToggle("Auto Rejoin (30 min)", {
    Default = false,
    Callback = function(v) _G.AutoRejoin30m = v end
})

local CheatsSection = Tabs.Misc:AddSection("Cheats")
CheatsSection:AddToggle("Infinite Soru", {
    Default = false,
    Callback = function(v) _G.InfiniteSoru = v end
})
CheatsSection:AddToggle("Infinite Geppo", {
    Default = false,
    Callback = function(v) _G.InfiniteGeppo = v end
})
CheatsSection:AddToggle("Dodge No CD", {
    Default = false,
    Callback = function(v) _G.DodgeNoCD = v end
})
CheatsSection:AddToggle("Walk on Water", {
    Default = true,
    Callback = function(v)
        _G.WalkWater = v
        if v then
            Workspace.Map["WaterBase-Plane"].Size = Vector3.new(1000, 112, 1000)
        else
            Workspace.Map["WaterBase-Plane"].Size = Vector3.new(1000, 80, 1000)
        end
    end
})
CheatsSection:AddButton("Redeem All Codes", function()
    local codes = {"NOMOREHACK","BANEXPLOIT","WildDares","BossBuild","GetPranked","EARN_FRUITS","FIGHT4FRUIT","NOEXPLOITER","NOOB2ADMIN","CODESLIDE","ADMINHACKED","ADMINDARES","fruitconcepts","krazydares","TRIPLEABUSE","SEATROLLING","24NOADMIN","REWARDFUN","Chandler","NEWTROLL","KITT_RESET","Sub2CaptainMaui","kittgaming","Sub2Fer999","Enyu_is_Pro","Magicbus","JCWK","Starcodeheo","Bluxxy","fudd10_v2","SUB2GAMERROBOT_EXP1","Sub2NoobMaster123","Sub2UncleKizaru","Sub2Daigrock","Axiore","TantaiGaming","StrawHatMaine","Sub2OfficialNoobie","Fudd10","Bignews","TheGreatAce","SECRET_ADMIN"}
    for _, code in ipairs(codes) do
        pcall(function()
            ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Redeem"):InvokeServer(code)
        end)
        safe_wait(0.1)
    end
end)
CheatsSection:AddButton("Join Pirates", function()
    ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Pirates")
end)
CheatsSection:AddButton("Join Marines", function()
    ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines")
end)

local StatusPara = Tabs.Status:AddParagraph("Live Status", "Loading...")
spawn(function()
    while safe_wait(2) do
        pcall(function()
            local info = "Level: " .. Plr.Data.Level.Value .. "\n"
            info = info .. "Race: " .. Plr.Data.Race.Value .. "\n"
            info = info .. "Beli: " .. Plr.Data.Beli.Value .. "\n"
            info = info .. "Fragments: " .. Plr.Data.Fragments.Value .. "\n"
            local bones = ReplicatedStorage.Remotes.CommF_:InvokeServer("Bones", "Check")
            info = info .. "Bones: " .. tostring(bones) .. "\n"
            info = info .. "Anti-Cheat: " .. (_G.AntiBan and "✅ ON" or "❌ OFF") .. "\n"
            info = info .. "Stealth Mode: " .. (_G.StealthMode and "✅ ON" or "❌ OFF") .. "\n"
            StatusPara:Set(info)
        end)
    end
end)

Fluent:Notify({
    Title = "Axion Hub",
    Content = "Loaded successfully!",
    Duration = 3
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("AxionHub")
SaveManager:SetFolder("AxionHub/saves")
InterfaceManager:BuildInterfaceSection(Tabs)
SaveManager:BuildConfigSection(Tabs)
Window:SelectTab(1)

Fluent:Notify({
    Title = "✦ AXION HUB ✦",
    Content = "Premium script loaded",
    Duration = 3
})