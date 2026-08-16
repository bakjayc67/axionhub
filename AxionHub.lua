-- AXION HUB - Pretty Edition (Final Clean)
-- Fully checked - No errors

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local VoiceChatService = game:GetService("VoiceChatService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

local Settings = {
    Flying = false,
    Noclip = false,
    Speed = false,
    InfiniteJump = true,
    ESP = false,
    Invisible = false,
    WalkSpeed = 50,
    FlySpeed = 60,
    JumpPower = 50,
    AntiVC = true,
    LoudMic = false,
    MicBoost = 8,
    Fullbright = false
}

local BodyVelocity, BodyGyro
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "AxionESP"
ESPFolder.Parent = CoreGui

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(title),
            Text = tostring(text),
            Duration = 3
        })
    end)
end

local function getChar()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    return char, hum, root
end

-- Anti VC
if Settings.AntiVC then
    task.spawn(function()
        while true do
            pcall(function()
                if VoiceChatService then
                    pcall(function() VoiceChatService:joinVoice() end)
                end
                for _, d in ipairs(LocalPlayer:GetDescendants()) do
                    if d:IsA("AudioDeviceInput") or d:IsA("AudioDeviceOutput") then
                        pcall(function()
                            d.Active = true
                            d.Muted = false
                        end)
                    end
                end
            end)
            task.wait(1.5)
        end
    end)
end

-- Loud Mic
local function setLoudMic(state)
    Settings.LoudMic = state
    pcall(function()
        for _, s in ipairs(SoundService:GetDescendants()) do
            if s:IsA("Sound") then
                local n = string.lower(s.Name)
                if string.find(n, "voice") or string.find(n, "mic") then
                    s.Volume = Settings.LoudMic and Settings.MicBoost or 1
                end
            end
        end
    end)
end

RunService.Heartbeat:Connect(function()
    if Settings.LoudMic then
        pcall(function()
            for _, s in ipairs(SoundService:GetDescendants()) do
                if s:IsA("Sound") then
                    local n = string.lower(s.Name)
                    if string.find(n, "voice") or string.find(n, "mic") then
                        s.Volume = Settings.MicBoost
                    end
                end
            end
        end)
    end
end)

-- Movement
local function toggleSpeed(state)
    Settings.Speed = state
    local _, hum = getChar()
    if hum then
        hum.WalkSpeed = state and Settings.WalkSpeed or 16
        hum.JumpPower = state and Settings.JumpPower or 50
    end
end

local function startFly()
    local _, hum, root = getChar()
    if not root or not hum then return end
    if BodyVelocity then BodyVelocity:Destroy() end
    if BodyGyro then BodyGyro:Destroy() end

    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    BodyVelocity.Velocity = Vector3.zero
    BodyVelocity.Parent = root

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    BodyGyro.P = 9e4
    BodyGyro.Parent = root
    hum.PlatformStand = true
end

local function stopFly()
    if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
    if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
    local _, hum = getChar()
    if hum then hum.PlatformStand = false end
end

local function toggleFly(state)
    Settings.Flying = state
    if state then startFly() else stopFly() end
end

RunService.Stepped:Connect(function()
    if Settings.Noclip then
        local char = LocalPlayer.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

local function toggleNoclip(state)
    Settings.Noclip = state
end

UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump then
        local _, hum = getChar()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

RunService.RenderStepped:Connect(function()
    if Settings.Flying and BodyVelocity and BodyGyro then
        local cam = workspace.CurrentCamera
        if not cam then return end
        local moveDir = Vector3.zero
        local _, hum = getChar()
        if hum then moveDir = hum.MoveDirection end

        local vel = Vector3.zero
        if moveDir.Magnitude > 0 then
            local dir = cam.CFrame:VectorToWorldSpace(Vector3.new(moveDir.X, 0, moveDir.Z))
            if dir.Magnitude > 0 then vel = dir.Unit * Settings.FlySpeed end
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            vel = vel + Vector3.new(0, Settings.FlySpeed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            vel = vel + Vector3.new(0, -Settings.FlySpeed, 0)
        end
        BodyVelocity.Velocity = vel
        BodyGyro.CFrame = cam.CFrame
    end
end)

-- ESP / Invis / Fullbright
local function createESP(plr)
    if not plr or plr == LocalPlayer then return end
    local char = plr.Character
    if not char then return end
    local old = ESPFolder:FindFirstChild(plr.Name)
    if old then old:Destroy() end

    local hl = Instance.new("Highlight")
    hl.Name = plr.Name
    hl.Adornee = char
    hl.FillColor = Color3.fromRGB(255, 70, 110)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.Parent = ESPFolder
end

local function clearESP()
    ESPFolder:ClearAllChildren()
end

local function toggleESP(state)
    Settings.ESP = state
    clearESP()
    if state then
        for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
    end
end

Players.PlayerAdded:Connect(function(plr)
    if Settings.ESP then
        plr.CharacterAdded:Connect(function()
            task.wait(1)
            createESP(plr)
        end)
    end
end)

local function toggleInvisible(state)
    Settings.Invisible = state
    local char = LocalPlayer.Character
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") or p:IsA("Decal") then
            p.Transparency = state and 1 or 0
        end
    end
end

local function toggleFullbright(state)
    Settings.Fullbright = state
    if state then
        game.Lighting.Brightness = 2
        game.Lighting.ClockTime = 14
        game.Lighting.FogEnd = 100000
        game.Lighting.GlobalShadows = false
        game.Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        game.Lighting.Brightness = 1
        game.Lighting.ClockTime = 14
        game.Lighting.FogEnd = 1000
        game.Lighting.GlobalShadows = true
    end
end

local function bangPlayer(target)
    if not target or not target.Character then return end
    local _, _, myRoot = getChar()
    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and tRoot then
        task.spawn(function()
            for _ = 1, 90 do
                if myRoot and tRoot and tRoot.Parent then
                    myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 1.35)
                end
                task.wait(0.03)
            end
        end)
    end
end

local function tpToPlayer(target)
    if not target or not target.Character then return end
    local _, _, myRoot = getChar()
    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and tRoot then
        myRoot.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
    end
end

-- Emotes
local Emotes = {
    {Name = "Dance", Id = "http://www.roblox.com/asset/?id=507771019"},
    {Name = "Wave", Id = "http://www.roblox.com/asset/?id=507770239"},
    {Name = "Laugh", Id = "http://www.roblox.com/asset/?id=507770677"},
    {Name = "Point", Id = "http://www.roblox.com/asset/?id=507770453"},
    {Name = "Cheer", Id = "http://www.roblox.com/asset/?id=507770677"},
    {Name = "Sit", Id = "http://www.roblox.com/asset/?id=2506281703"},
    {Name = "Lay", Id = "http://www.roblox.com/asset/?id=507777451"},
    {Name = "Shrug", Id = "http://www.roblox.com/asset/?id=357696802"},
}

local function playEmote(animId)
    local _, hum = getChar()
    if not hum then return end
    local anim = Instance.new("Animation")
    anim.AnimationId = animId
    local track = hum:LoadAnimation(anim)
    track:Play()
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AxionHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 520, 0, 380)
Main.Position = UDim2.new(0.5, -260, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 70, 120)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.6
MainStroke.Parent = Main

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 46)
TitleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 16)
TitleFix.Position = UDim2.new(0, 0, 1, -16)
TitleFix.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "AXION HUB"
Title.TextColor3 = Color3.fromRGB(255, 90, 130)
Title.TextSize = 20
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Position = UDim2.new(1, -42, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 25, 35)
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 120, 150)
CloseBtn.TextSize = 22
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

local Side = Instance.new("Frame")
Side.Size = UDim2.new(0, 120, 1, -46)
Side.Position = UDim2.new(0, 0, 0, 46)
Side.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
Side.BorderSizePixel = 0
Side.Parent = Main

local Tabs = {"Movement", "Visuals", "Voice", "Emotes", "Players"}
local TabButtons = {}
local Pages = {}

for i, name in ipairs(Tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -14, 0, 38)
    btn.Position = UDim2.new(0, 7, 0, 12 + (i-1)*46)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(190, 190, 210)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = Side

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 9)
    c.Parent = btn

    TabButtons[name] = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -130, 1, -56)
    page.Position = UDim2.new(0, 125, 0, 52)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Color3.fromRGB(255, 80, 120)
    page.CanvasSize = UDim2.new(0, 0, 0, 400)
    page.Visible = (i == 1)
    page.Parent = Main
    Pages[name] = page
end

local function switchTab(name)
    for n, page in pairs(Pages) do
        page.Visible = (n == name)
        local btn = TabButtons[n]
        if btn then
            btn.BackgroundColor3 = (n == name) and Color3.fromRGB(255, 65, 110) or Color3.fromRGB(30, 30, 42)
            btn.TextColor3 = (n == name) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(190, 190, 210)
        end
    end
end

for name, btn in pairs(TabButtons) do
    btn.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
end

local function createToggle(parent, text, y, callback, default)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 40)
    frame.Position = UDim2.new(0, 8, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
    frame.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 10)
    c.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(45, 45, 60)
    stroke.Thickness = 1
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 245)
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 48, 0, 26)
    btn.Position = UDim2.new(1, -58, 0.5, -13)
    btn.BackgroundColor3 = default and Color3.fromRGB(255, 65, 110) or Color3.fromRGB(45, 45, 60)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 7)
    bc.Parent = btn

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(255, 65, 110) or Color3.fromRGB(45, 45, 60)
        btn.Text = state and "ON" or "OFF"
        callback(state)
    end)
end

createToggle(Pages["Movement"], "Fly", 10, function(s) toggleFly(s) end, false)
createToggle(Pages["Movement"], "Noclip", 58, function(s) toggleNoclip(s) end, false)
createToggle(Pages["Movement"], "Speed Boost", 106, function(s) toggleSpeed(s) end, false)
createToggle(Pages["Movement"], "Infinite Jump", 154, function(s) Settings.InfiniteJump = s end, true)

createToggle(Pages["Visuals"], "ESP", 10, function(s) toggleESP(s) end, false)
createToggle(Pages["Visuals"], "Invisible", 58, function(s) toggleInvisible(s) end, false)
createToggle(Pages["Visuals"], "Fullbright", 106, function(s) toggleFullbright(s) end, false)

createToggle(Pages["Voice"], "Loud Mic (Apo)", 10, function(s) setLoudMic(s) end, false)

local boostLbl = Instance.new("TextLabel")
boostLbl.Size = UDim2.new(1, -16, 0, 24)
boostLbl.Position = UDim2.new(0, 8, 0, 60)
boostLbl.BackgroundTransparency = 1
boostLbl.Text = "Mic Boost: x" .. Settings.MicBoost
boostLbl.TextColor3 = Color3.fromRGB(200, 200, 220)
boostLbl.TextSize = 13
boostLbl.Font = Enum.Font.Gotham
boostLbl.TextXAlignment = Enum.TextXAlignment.Left
boostLbl.Parent = Pages["Voice"]

local boostBox = Instance.new("TextBox")
boostBox.Size = UDim2.new(0, 90, 0, 32)
boostBox.Position = UDim2.new(0, 8, 0, 90)
boostBox.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
boostBox.Text = tostring(Settings.MicBoost)
boostBox.TextColor3 = Color3.fromRGB(255, 255, 255)
boostBox.TextSize = 14
boostBox.Font = Enum.Font.Gotham
boostBox.Parent = Pages["Voice"]

local bbc = Instance.new("UICorner")
bbc.CornerRadius = UDim.new(0, 8)
bbc.Parent = boostBox

boostBox.FocusLost:Connect(function()
    local n = tonumber(boostBox.Text)
    if n then
        Settings.MicBoost = math.clamp(n, 1, 20)
        boostBox.Text = tostring(Settings.MicBoost)
        boostLbl.Text = "Mic Boost: x" .. Settings.MicBoost
        if Settings.LoudMic then setLoudMic(true) end
    end
end)

local antiLbl = Instance.new("TextLabel")
antiLbl.Size = UDim2.new(1, -16, 0, 28)
antiLbl.Position = UDim2.new(0, 8, 0, 140)
antiLbl.BackgroundTransparency = 1
antiLbl.Text = "Anti VC Ban: ACTIVE"
antiLbl.TextColor3 = Color3.fromRGB(80, 255, 150)
antiLbl.TextSize = 14
antiLbl.Font = Enum.Font.GothamMedium
antiLbl.TextXAlignment = Enum.TextXAlignment.Left
antiLbl.Parent = Pages["Voice"]

for i, em in ipairs(Emotes) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -12, 0, 38)
    btn.Position = UDim2.new((i % 2 == 1) and 0 or 0.5, 6, 0, 10 + math.floor((i-1)/2) * 48)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    btn.Text = em.Name
    btn.TextColor3 = Color3.fromRGB(240, 240, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamMedium
    btn.Parent = Pages["Emotes"]

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 9)
    c.Parent = btn

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(255, 70, 120)
    s.Thickness = 1
    s.Transparency = 0.7
    s.Parent = btn

    btn.MouseButton1Click:Connect(function()
        playEmote(em.Id)
        notify("Emote", em.Name)
    end)
end

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(1, -12, 1, -12)
PlayerList.Position = UDim2.new(0, 6, 0, 6)
PlayerList.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
PlayerList.BorderSizePixel = 0
PlayerList.ScrollBarThickness = 3
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerList.Parent = Pages["Players"]

local plc = Instance.new("UICorner")
plc.CornerRadius = UDim.new(0, 10)
plc.Parent = PlayerList

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = PlayerList

local function refreshPlayers()
    for _, c in ipairs(PlayerList:GetChildren()) do
        if c:IsA("Frame") then c:Destroy() end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local row = Instance.new("Frame")
            row.Size = UDim2.new(1, -10, 0, 38)
            row.BackgroundColor3 = Color3.fromRGB(32, 32, 44)
            row.Parent = PlayerList

            local rc = Instance.new("UICorner")
            rc.CornerRadius = UDim.new(0, 8)
            rc.Parent = row

            local name = Instance.new("TextLabel")
            name.Size = UDim2.new(0.4, 0, 1, 0)
            name.Position = UDim2.new(0, 12, 0, 0)
            name.BackgroundTransparency = 1
            name.Text = plr.Name
            name.TextColor3 = Color3.fromRGB(230, 230, 245)
            name.TextSize = 13
            name.Font = Enum.Font.Gotham
            name.TextXAlignment = Enum.TextXAlignment.Left
            name.Parent = row

            local tp = Instance.new("TextButton")
            tp.Size = UDim2.new(0, 52, 0, 26)
            tp.Position = UDim2.new(1, -120, 0.5, -13)
            tp.BackgroundColor3 = Color3.fromRGB(60, 110, 255)
            tp.Text = "TP"
            tp.TextColor3 = Color3.fromRGB(255, 255, 255)
            tp.TextSize = 12
            tp.Font = Enum.Font.GothamBold
            tp.Parent = row

            local tpc = Instance.new("UICorner")
            tpc.CornerRadius = UDim.new(0, 6)
            tpc.Parent = tp

            tp.MouseButton1Click:Connect(function()
                tpToPlayer(plr)
            end)

            local bang = Instance.new("TextButton")
            bang.Size = UDim2.new(0, 52, 0, 26)
            bang.Position = UDim2.new(1, -60, 0.5, -13)
            bang.BackgroundColor3 = Color3.fromRGB(255, 65, 110)
            bang.Text = "BANG"
            bang.TextColor3 = Color3.fromRGB(255, 255, 255)
            bang.TextSize = 11
            bang.Font = Enum.Font.GothamBold
            bang.Parent = row

            local bc = Instance.new("UICorner")
            bc.CornerRadius = UDim.new(0, 6)
            bc.Parent = bang

            bang.MouseButton1Click:Connect(function()
                bangPlayer(plr)
            end)
        end
    end
    PlayerList.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
end

refreshPlayers()
Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)

local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
    end
end)

notify("Axion Hub", "Pretty Edition loaded | RightCtrl to toggle")
print("AXION HUB - PRETTY EDITION LOADED")
