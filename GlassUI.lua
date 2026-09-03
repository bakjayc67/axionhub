--[[
  GlassUI – Premium Glassmorphism UI Library
  Designed to replicate Banana Hub’s modern style.
  All features: Windows, Tabs, Sections, Toggles, Sliders, Dropdowns, Buttons, Paragraphs, Notifications.
  Mobile‑optimised, animated, fully customisable.
]]
local GlassUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================ THEME ============================
local Theme = {
    Background = Color3.fromRGB(20, 20, 30),
    Glass = Color3.fromRGB(255, 255, 255),
    GlassTransparency = 0.85,
    Border = Color3.fromRGB(255, 255, 255),
    BorderTransparency = 0.8,
    Accent = Color3.fromRGB(120, 80, 255), -- purple/blue gradient base
    AccentGradient = Color3.fromRGB(80, 180, 255),
    Text = Color3.fromRGB(220, 220, 220),
    TextDim = Color3.fromRGB(150, 150, 170),
    ToggleOn = Color3.fromRGB(120, 80, 255),
    ToggleOff = Color3.fromRGB(80, 80, 100),
    SliderTrack = Color3.fromRGB(60, 60, 80),
    SliderFill = Color3.fromRGB(120, 80, 255),
    DropdownBg = Color3.fromRGB(30, 30, 45),
    Shadow = Color3.fromRGB(0, 0, 0),
}

-- ============================ UTILITIES ============================
local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function CreateShadow(parent, size, color)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://13160412869" -- soft shadow
    shadow.ImageColor3 = color or Theme.Shadow
    shadow.ImageTransparency = 0.7
    shadow.BackgroundTransparency = 1
    shadow.Size = size or UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.Parent = parent
    return shadow
end

local function CreateGlassFrame(parent, size, position, transparency)
    transparency = transparency or Theme.GlassTransparency
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = Theme.Glass
    frame.BackgroundTransparency = transparency
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Theme.Border
    frame.BorderTransparency = Theme.BorderTransparency
    frame.ClipsDescendants = true
    frame.Parent = parent
    -- Corner radius
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    -- Shadow
    CreateShadow(frame, UDim2.new(1, 10, 1, 10), Theme.Shadow)
    return frame
end

local function CreateText(parent, text, size, color, position, font)
    font = font or Enum.Font.GothamSemibold
    local label = Instance.new("TextLabel")
    label.Text = text
    label.TextSize = size or 14
    label.TextColor3 = color or Theme.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Position = position or UDim2.new(0, 0, 0, 0)
    label.Font = font
    label.Parent = parent
    return label
end

local function CreateScrollingFrame(parent, size, position)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = size
    scroll.Position = position
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Theme.Accent
    scroll.ScrollBarImageTransparency = 0.6
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = parent
    -- Custom scrollbar styling (using image)
    local bar = Instance.new("ImageLabel")
    bar.Name = "ScrollBar"
    bar.Image = "rbxassetid://13160412869"
    bar.ImageColor3 = Theme.Accent
    bar.ImageTransparency = 0.5
    bar.BackgroundTransparency = 1
    bar.Size = UDim2.new(0, 4, 1, 0)
    bar.Position = UDim2.new(1, -6, 0, 0)
    bar.Parent = scroll
    return scroll
end

-- ============================ NOTIFICATION SYSTEM ============================
local NotificationHolder = nil
local function CreateNotificationHolder()
    if NotificationHolder then return end
    NotificationHolder = Instance.new("Frame")
    NotificationHolder.Size = UDim2.new(0, 300, 0, 0)
    NotificationHolder.Position = UDim2.new(1, -320, 0, 20)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.Parent = game:GetService("CoreGui")
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.VerticalAlignment = Enum.VerticalAlignment.Top
    layout.Parent = NotificationHolder
end

function GlassUI:Notify(message, duration, type)
    duration = duration or 3
    type = type or "info"
    CreateNotificationHolder()
    local frame = CreateGlassFrame(NotificationHolder, UDim2.new(1, 0, 0, 50), UDim2.new(0, 0, 0, 0), 0.9)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    frame.BorderTransparency = 0.6
    local icon = Instance.new("TextLabel")
    icon.Text = type == "success" and "✓" or type == "error" and "✗" or "●"
    icon.TextColor3 = type == "success" and Color3.fromRGB(0, 255, 100) or type == "error" and Color3.fromRGB(255, 50, 50) or Theme.Accent
    icon.TextSize = 18
    icon.Font = Enum.Font.GothamBold
    icon.Size = UDim2.new(0, 30, 1, 0)
    icon.BackgroundTransparency = 1
    icon.TextXAlignment = Enum.TextXAlignment.Center
    icon.Parent = frame
    local msg = CreateText(frame, message, 14, Theme.Text, UDim2.new(0, 35, 0, 0))
    msg.TextWrapped = true
    msg.TextSize = 13
    msg.Size = UDim2.new(1, -40, 1, 0)
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.LayoutOrder = #NotificationHolder:GetChildren()
    frame.BackgroundTransparency = 0.15
    -- Animate in
    frame.Position = UDim2.new(1, 20, 0, 0)
    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(duration)
    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Position = UDim2.new(1, 20, 0, 0)}):Play()
    task.wait(0.3)
    frame:Destroy()
end

-- ============================ WINDOW ============================
function GlassUI:CreateWindow(title, subtitle, size)
    size = size or UDim2.fromOffset(500, 350)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GlassUI"
    screenGui.Parent = game:GetService("CoreGui")

    -- Main glass window
    local window = CreateGlassFrame(screenGui, size, UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2), 0.85)
    window.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    window.BackgroundTransparency = 0.12
    window.BorderTransparency = 0.5
    MakeDraggable(window)

    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundTransparency = 1
    header.Parent = window

    local titleLabel = CreateText(header, title, 18, Theme.Text, UDim2.new(0, 15, 0, 0), Enum.Font.GothamBold)
    titleLabel.TextSize = 18
    local subLabel = CreateText(header, subtitle or "", 12, Theme.TextDim, UDim2.new(0, 15, 0, 22))
    subLabel.TextSize = 11

    -- Gradient accent line
    local accentLine = Instance.new("Frame")
    accentLine.Size = UDim2.new(0.3, 0, 0, 2)
    accentLine.Position = UDim2.new(0, 15, 1, -2)
    accentLine.BackgroundColor3 = Theme.Accent
    accentLine.BackgroundTransparency = 0.3
    accentLine.Parent = header
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(1, Theme.AccentGradient)}
    grad.Parent = accentLine

    -- Minimize button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -40, 0, 8)
    minimizeBtn.Text = "─"
    minimizeBtn.TextColor3 = Theme.Text
    minimizeBtn.TextSize = 18
    minimizeBtn.BackgroundTransparency = 1
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = header
    minimizeBtn.MouseButton1Click:Connect(function()
        window.Visible = not window.Visible
    end)

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -10, 0, 8)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    closeBtn.TextSize = 16
    closeBtn.BackgroundTransparency = 1
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    -- Tab container
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 36)
    tabContainer.Position = UDim2.new(0, 0, 0, 45)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = window

    local tabScroll = CreateScrollingFrame(tabContainer, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
    tabScroll.BackgroundTransparency = 1
    tabScroll.ScrollBarThickness = 2
    tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 8)
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Parent = tabScroll

    local tabs = {}
    local activeTab = nil

    -- Content container
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, -20, 1, -100)
    contentContainer.Position = UDim2.new(0, 10, 0, 85)
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = window

    -- Window methods
    local windowObj = {
        _screenGui = screenGui,
        _window = window,
        _tabContainer = tabContainer,
        _contentContainer = contentContainer,
        _tabs = tabs,
        _activeTab = nil,
        Notify = GlassUI.Notify,
    }

    function windowObj:CreateTab(name)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0, 80, 1, -8)
        tabBtn.Text = name
        tabBtn.TextColor3 = Theme.TextDim
        tabBtn.TextSize = 14
        tabBtn.BackgroundTransparency = 1
        tabBtn.Font = Enum.Font.GothamSemibold
        tabBtn.Parent = tabScroll

        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = Theme.Accent
        tabContent.ScrollBarImageTransparency = 0.6
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContent.Visible = false
        tabContent.Parent = contentContainer

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = tabContent

        local tabObj = {
            _button = tabBtn,
            _content = tabContent,
            _layout = layout,
            _elements = {},
        }

        function tabObj:CreateSection(title)
            local section = Instance.new("Frame")
            section.Size = UDim2.new(1, 0, 0, 30)
            section.BackgroundTransparency = 1
            section.Parent = tabContent
            local titleLabel = CreateText(section, title, 14, Theme.TextDim, UDim2.new(0, 5, 0, 0), Enum.Font.GothamBold)
            titleLabel.TextSize = 13
            titleLabel.TextColor3 = Theme.Text
            titleLabel.Size = UDim2.new(1, -10, 1, 0)
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            -- Add accent line
            local line = Instance.new("Frame")
            line.Size = UDim2.new(1, -10, 0, 1)
            line.Position = UDim2.new(0, 5, 1, -2)
            line.BackgroundColor3 = Theme.Accent
            line.BackgroundTransparency = 0.5
            line.Parent = section
            return section
        end

        function tabObj:CreateToggle(name, default, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 36)
            frame.BackgroundTransparency = 1
            frame.Parent = tabContent

            local label = CreateText(frame, name, 14, Theme.Text, UDim2.new(0, 0, 0, 0))
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Size = UDim2.new(1, -50, 1, 0)

            local toggleBg = Instance.new("Frame")
            toggleBg.Size = UDim2.new(0, 40, 0, 22)
            toggleBg.Position = UDim2.new(1, -45, 0.5, -11)
            toggleBg.BackgroundColor3 = Theme.ToggleOff
            toggleBg.BackgroundTransparency = 0.2
            toggleBg.BorderSizePixel = 0
            toggleBg.Parent = frame
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(1, 0)
            corner.Parent = toggleBg

            local toggleCircle = Instance.new("Frame")
            toggleCircle.Size = UDim2.new(0, 18, 0, 18)
            toggleCircle.Position = UDim2.new(0, 2, 0.5, -9)
            toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            toggleCircle.BackgroundTransparency = 0.2
            toggleCircle.BorderSizePixel = 0
            toggleCircle.Parent = toggleBg
            local circleCorner = Instance.new("UICorner")
            circleCorner.CornerRadius = UDim.new(1, 0)
            circleCorner.Parent = toggleCircle

            local state = default or false
            local function updateToggle()
                local targetPos = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                local targetColor = state and Theme.ToggleOn or Theme.ToggleOff
                TweenService:Create(toggleBg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = targetColor}):Play()
                TweenService:Create(toggleCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Position = targetPos}):Play()
            end
            updateToggle()

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Parent = toggleBg
            btn.MouseButton1Click:Connect(function()
                state = not state
                updateToggle()
                if callback then callback(state) end
            end)

            return {
                Set = function(s) state = s; updateToggle(); if callback then callback(state) end end,
                Get = function() return state end,
            }
        end

        function tabObj:CreateSlider(name, min, max, default, callback)
            min = min or 0
            max = max or 100
            default = default or 50
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 50)
            frame.BackgroundTransparency = 1
            frame.Parent = tabContent

            local label = CreateText(frame, name, 14, Theme.Text, UDim2.new(0, 0, 0, 0))
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Size = UDim2.new(1, -60, 0.5, 0)

            local valueLabel = CreateText(frame, tostring(default), 13, Theme.TextDim, UDim2.new(1, -10, 0, 0))
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Size = UDim2.new(0, 50, 0.5, 0)

            local track = Instance.new("Frame")
            track.Size = UDim2.new(1, -10, 0, 4)
            track.Position = UDim2.new(0, 5, 1, -10)
            track.BackgroundColor3 = Theme.SliderTrack
            track.BackgroundTransparency = 0.3
            track.BorderSizePixel = 0
            track.Parent = frame
            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = track

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = Theme.SliderFill
            fill.BorderSizePixel = 0
            fill.Parent = track
            local fillCorner = Instance.new("UICorner")
            fillCorner.CornerRadius = UDim.new(1, 0)
            fillCorner.Parent = fill
            -- gradient on fill
            local grad = Instance.new("UIGradient")
            grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Theme.Accent), ColorSequenceKeypoint.new(1, Theme.AccentGradient)}
            grad.Parent = fill

            local knob = Instance.new("Frame")
            knob.Size = UDim2.new(0, 14, 0, 14)
            knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -7)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BackgroundTransparency = 0.2
            knob.BorderSizePixel = 0
            knob.Parent = track
            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(1, 0)
            knobCorner.Parent = knob

            local dragging = false
            local function updateSlider(input)
                local relative = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                local val = math.clamp(relative, 0, 1) * (max - min) + min
                val = math.round(val)
                fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
                knob.Position = UDim2.new((val - min) / (max - min), -7, 0.5, -7)
                valueLabel.Text = tostring(val)
                if callback then callback(val) end
            end

            knob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            return {
                Set = function(val)
                    val = math.clamp(val, min, max)
                    fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
                    knob.Position = UDim2.new((val - min) / (max - min), -7, 0.5, -7)
                    valueLabel.Text = tostring(val)
                    if callback then callback(val) end
                end,
                Get = function()
                    local rel = fill.Size.X.Scale
                    return math.round(rel * (max - min) + min)
                end,
            }
        end

        function tabObj:CreateDropdown(name, options, default, callback)
            options = options or {}
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 36)
            frame.BackgroundTransparency = 1
            frame.Parent = tabContent

            local label = CreateText(frame, name, 14, Theme.Text, UDim2.new(0, 0, 0, 0))
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Size = UDim2.new(1, -100, 1, 0)

            local dropdownBtn = Instance.new("TextButton")
            dropdownBtn.Size = UDim2.new(0, 90, 0, 28)
            dropdownBtn.Position = UDim2.new(1, -95, 0.5, -14)
            dropdownBtn.Text = default or "Select"
            dropdownBtn.TextColor3 = Theme.Text
            dropdownBtn.TextSize = 13
            dropdownBtn.BackgroundColor3 = Theme.DropdownBg
            dropdownBtn.BackgroundTransparency = 0.3
            dropdownBtn.BorderSizePixel = 0
            dropdownBtn.Font = Enum.Font.GothamSemibold
            dropdownBtn.Parent = frame
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = dropdownBtn

            local dropdownList = Instance.new("Frame")
            dropdownList.Size = UDim2.new(0, 90, 0, 0)
            dropdownList.Position = UDim2.new(1, -95, 1, 0)
            dropdownList.BackgroundColor3 = Theme.DropdownBg
            dropdownList.BackgroundTransparency = 0.3
            dropdownList.BorderSizePixel = 0
            dropdownList.ClipsDescendants = true
            dropdownList.Visible = false
            dropdownList.Parent = frame
            local listCorner = Instance.new("UICorner")
            listCorner.CornerRadius = UDim.new(0, 4)
            listCorner.Parent = dropdownList

            local listLayout = Instance.new("UIListLayout")
            listLayout.Padding = UDim.new(0, 2)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.Parent = dropdownList

            local function updateList(visible)
                dropdownList.Visible = visible
                local height = #options * 28 + 6
                TweenService:Create(dropdownList, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 90, 0, visible and height or 0)}):Play()
            end

            local selected = default
            for _, opt in ipairs(options) do
                local item = Instance.new("TextButton")
                item.Size = UDim2.new(1, 0, 0, 26)
                item.Text = opt
                item.TextColor3 = Theme.Text
                item.TextSize = 13
                item.BackgroundTransparency = 1
                item.Font = Enum.Font.GothamSemibold
                item.Parent = dropdownList
                item.MouseButton1Click:Connect(function()
                    selected = opt
                    dropdownBtn.Text = opt
                    if callback then callback(opt) end
                    updateList(false)
                end)
            end

            dropdownBtn.MouseButton1Click:Connect(function()
                updateList(not dropdownList.Visible)
            end)

            -- Close dropdown when clicking outside
            UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    if not frame:IsAncestorOf(input.Position) then
                        updateList(false)
                    end
                end
            end)

            return {
                Set = function(opt)
                    if table.find(options, opt) then
                        selected = opt
                        dropdownBtn.Text = opt
                        if callback then callback(opt) end
                    end
                end,
                Get = function() return selected end,
            }
        end

        function tabObj:CreateButton(name, callback)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 36)
            frame.BackgroundTransparency = 1
            frame.Parent = tabContent

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -20, 1, -6)
            btn.Position = UDim2.new(0, 10, 0, 3)
            btn.Text = name
            btn.TextColor3 = Theme.Text
            btn.TextSize = 14
            btn.BackgroundColor3 = Theme.Glass
            btn.BackgroundTransparency = 0.8
            btn.BorderSizePixel = 0
            btn.Font = Enum.Font.GothamSemibold
            btn.Parent = frame
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = btn
            -- gradient accent on hover? we can skip for simplicity
            btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
            return btn
        end

        function tabObj:CreateParagraph(title, content)
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 40)
            frame.BackgroundTransparency = 1
            frame.Parent = tabContent

            local titleLabel = CreateText(frame, title, 14, Theme.Text, UDim2.new(0, 0, 0, 0), Enum.Font.GothamBold)
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Size = UDim2.new(1, 0, 0.5, 0)

            local contentLabel = CreateText(frame, content, 12, Theme.TextDim, UDim2.new(0, 0, 0.5, 0))
            contentLabel.TextXAlignment = Enum.TextXAlignment.Left
            contentLabel.Size = UDim2.new(1, 0, 0.5, 0)
            contentLabel.TextWrapped = true
            contentLabel.TextSize = 12
            return {
                Set = function(newContent)
                    contentLabel.Text = newContent
                end
            }
        end

        -- Tab activation
        tabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(tabs) do
                t._content.Visible = false
                t._button.TextColor3 = Theme.TextDim
            end
            tabContent.Visible = true
            tabBtn.TextColor3 = Theme.Accent
            windowObj._activeTab = tabObj
        end)

        table.insert(tabs, tabObj)
        if not activeTab then
            activeTab = tabObj
            tabContent.Visible = true
            tabBtn.TextColor3 = Theme.Accent
        end
        return tabObj
    end

    function windowObj:Destroy()
        screenGui:Destroy()
    end

    return windowObj
end

-- ============================ EXPOSE ============================
return GlassUI
