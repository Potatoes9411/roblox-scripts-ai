-- ================================================================
-- MULTI-GAME SCRIPT HUB v2.0 - ENHANCED EDITION
-- For Roblox Studio Testing Only
-- Place in StarterPlayerScripts as a LocalScript
-- ================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- ================================================================
-- THEME SYSTEM
-- ================================================================

local Themes = {
    Dark = {
        Background = Color3.fromRGB(18, 18, 28),
        Secondary = Color3.fromRGB(25, 25, 38),
        Tertiary = Color3.fromRGB(35, 35, 52),
        Accent = Color3.fromRGB(100, 130, 255),
        AccentDark = Color3.fromRGB(70, 90, 200),
        Text = Color3.fromRGB(230, 230, 255),
        TextDim = Color3.fromRGB(140, 140, 180),
        TextMuted = Color3.fromRGB(90, 90, 130),
        Toggle_On = Color3.fromRGB(80, 200, 120),
        Toggle_Off = Color3.fromRGB(70, 70, 100),
        Slider = Color3.fromRGB(100, 160, 255),
        Button = Color3.fromRGB(80, 110, 220),
        Danger = Color3.fromRGB(200, 60, 60),
        Warning = Color3.fromRGB(200, 160, 0),
        Success = Color3.fromRGB(60, 180, 100),
        Border = Color3.fromRGB(60, 60, 100),
    },
    Purple = {
        Background = Color3.fromRGB(20, 10, 30),
        Secondary = Color3.fromRGB(28, 15, 42),
        Tertiary = Color3.fromRGB(40, 20, 60),
        Accent = Color3.fromRGB(160, 80, 255),
        AccentDark = Color3.fromRGB(120, 50, 200),
        Text = Color3.fromRGB(240, 220, 255),
        TextDim = Color3.fromRGB(160, 130, 200),
        TextMuted = Color3.fromRGB(100, 80, 140),
        Toggle_On = Color3.fromRGB(160, 80, 255),
        Toggle_Off = Color3.fromRGB(80, 50, 120),
        Slider = Color3.fromRGB(160, 80, 255),
        Button = Color3.fromRGB(130, 60, 220),
        Danger = Color3.fromRGB(200, 60, 80),
        Warning = Color3.fromRGB(200, 140, 0),
        Success = Color3.fromRGB(80, 200, 120),
        Border = Color3.fromRGB(100, 50, 160),
    },
    Midnight = {
        Background = Color3.fromRGB(8, 10, 20),
        Secondary = Color3.fromRGB(12, 15, 28),
        Tertiary = Color3.fromRGB(18, 22, 40),
        Accent = Color3.fromRGB(0, 180, 255),
        AccentDark = Color3.fromRGB(0, 130, 200),
        Text = Color3.fromRGB(200, 230, 255),
        TextDim = Color3.fromRGB(120, 160, 200),
        TextMuted = Color3.fromRGB(70, 100, 140),
        Toggle_On = Color3.fromRGB(0, 200, 255),
        Toggle_Off = Color3.fromRGB(30, 50, 80),
        Slider = Color3.fromRGB(0, 200, 255),
        Button = Color3.fromRGB(0, 140, 220),
        Danger = Color3.fromRGB(220, 50, 80),
        Warning = Color3.fromRGB(220, 160, 0),
        Success = Color3.fromRGB(0, 220, 140),
        Border = Color3.fromRGB(0, 80, 140),
    },
    Rose = {
        Background = Color3.fromRGB(22, 12, 18),
        Secondary = Color3.fromRGB(32, 16, 24),
        Tertiary = Color3.fromRGB(45, 22, 34),
        Accent = Color3.fromRGB(255, 80, 140),
        AccentDark = Color3.fromRGB(200, 50, 100),
        Text = Color3.fromRGB(255, 220, 235),
        TextDim = Color3.fromRGB(200, 150, 175),
        TextMuted = Color3.fromRGB(140, 90, 115),
        Toggle_On = Color3.fromRGB(255, 80, 140),
        Toggle_Off = Color3.fromRGB(100, 40, 65),
        Slider = Color3.fromRGB(255, 100, 160),
        Button = Color3.fromRGB(200, 60, 110),
        Danger = Color3.fromRGB(220, 40, 60),
        Warning = Color3.fromRGB(220, 160, 0),
        Success = Color3.fromRGB(80, 200, 120),
        Border = Color3.fromRGB(140, 40, 80),
    },
}

local CurrentTheme = Themes.Dark
local ActiveThemeName = "Dark"

-- ================================================================
-- STATE & CONFIG
-- ================================================================

local HubConfig = {
    keybind = Enum.KeyCode.RightShift,
    notifications = true,
    notifDuration = 4,
    watermark = true,
    fps_counter = true,
}

local gameStates = {}
local openWindows = {}
local connections = {}
local espObjects = {}
local fovCircle = nil
local watermarkLabel = nil
local fpsLabel = nil

-- ================================================================
-- NOTIFICATION SYSTEM
-- ================================================================

local NotifHolder
local notifCount = 0

local function CreateNotification(title, message, nType, duration)
    if not HubConfig.notifications then return end
    duration = duration or HubConfig.notifDuration
    nType = nType or "info"

    local colors = {
        info = Color3.fromRGB(80, 130, 255),
        success = Color3.fromRGB(60, 200, 100),
        warning = Color3.fromRGB(220, 170, 0),
        error = Color3.fromRGB(220, 60, 60),
    }
    local icons = {info = "ℹ", success = "✓", warning = "⚠", error = "✕"}

    notifCount = notifCount + 1
    local nColor = colors[nType] or colors.info
    local nIcon = icons[nType] or icons.info

    local NFrame = Instance.new("Frame")
    NFrame.Size = UDim2.new(0, 280, 0, 0)
    NFrame.Position = UDim2.new(1, -295, 0, 0)
    NFrame.BackgroundColor3 = CurrentTheme.Secondary
    NFrame.BorderSizePixel = 0
    NFrame.ClipsDescendants = true
    NFrame.Parent = NotifHolder
    local nCorner = Instance.new("UICorner", NFrame)
    nCorner.CornerRadius = UDim.new(0, 10)
    local nStroke = Instance.new("UIStroke", NFrame)
    nStroke.Color = nColor
    nStroke.Thickness = 1.5

    local Accent = Instance.new("Frame")
    Accent.Size = UDim2.new(0, 4, 1, 0)
    Accent.BackgroundColor3 = nColor
    Accent.BorderSizePixel = 0
    Accent.Parent = NFrame
    local aCorner = Instance.new("UICorner", Accent)
    aCorner.CornerRadius = UDim.new(0, 4)

    local IconLbl = Instance.new("TextLabel")
    IconLbl.Size = UDim2.new(0, 28, 0, 28)
    IconLbl.Position = UDim2.new(0, 12, 0, 10)
    IconLbl.BackgroundColor3 = nColor
    IconLbl.Text = nIcon
    IconLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    IconLbl.Font = Enum.Font.GothamBold
    IconLbl.TextSize = 14
    IconLbl.BorderSizePixel = 0
    IconLbl.Parent = NFrame
    local ilCorner = Instance.new("UICorner", IconLbl)
    ilCorner.CornerRadius = UDim.new(1, 0)

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -60, 0, 18)
    TitleLbl.Position = UDim2.new(0, 50, 0, 8)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = title
    TitleLbl.TextColor3 = CurrentTheme.Text
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 13
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = NFrame

    local MsgLbl = Instance.new("TextLabel")
    MsgLbl.Size = UDim2.new(1, -60, 0, 30)
    MsgLbl.Position = UDim2.new(0, 50, 0, 26)
    MsgLbl.BackgroundTransparency = 1
    MsgLbl.Text = message
    MsgLbl.TextColor3 = CurrentTheme.TextDim
    MsgLbl.Font = Enum.Font.Gotham
    MsgLbl.TextSize = 11
    MsgLbl.TextXAlignment = Enum.TextXAlignment.Left
    MsgLbl.TextWrapped = true
    MsgLbl.Parent = NFrame

    local ProgressBG = Instance.new("Frame")
    ProgressBG.Size = UDim2.new(1, -8, 0, 3)
    ProgressBG.Position = UDim2.new(0, 4, 1, -5)
    ProgressBG.BackgroundColor3 = CurrentTheme.Tertiary
    ProgressBG.BorderSizePixel = 0
    ProgressBG.Parent = NFrame
    local pbCorner = Instance.new("UICorner", ProgressBG)
    pbCorner.CornerRadius = UDim.new(1, 0)

    local ProgressFill = Instance.new("Frame")
    ProgressFill.Size = UDim2.new(1, 0, 1, 0)
    ProgressFill.BackgroundColor3 = nColor
    ProgressFill.BorderSizePixel = 0
    ProgressFill.Parent = ProgressBG
    local pfCorner = Instance.new("UICorner", ProgressFill)
    pfCorner.CornerRadius = UDim.new(1, 0)

    TweenService:Create(NFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 280, 0, 68)}):Play()
    TweenService:Create(ProgressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()

    task.delay(duration, function()
        TweenService:Create(NFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 280, 0, 0),
            Position = UDim2.new(1, -295 + 300, 0, 0)
        }):Play()
        task.wait(0.3)
        NFrame:Destroy()
    end)
end

-- ================================================================
-- UTILITY FUNCTIONS
-- ================================================================

local function Tween(obj, props, duration, style, dir)
    style = style or Enum.EasingStyle.Quart
    dir = dir or Enum.EasingDirection.Out
    local t = TweenService:Create(obj, TweenInfo.new(duration or 0.3, style, dir), props)
    t:Play()
    return t
end

local function MakeDraggable(frame, dragHandle)
    local dragging, dragStart, startPos = false, nil, nil
    dragHandle = dragHandle or frame
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    dragHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMove then
            local delta = input.Position - dragStart
            local newX = math.clamp(startPos.X.Offset + delta.X, -frame.AbsoluteSize.X + 50, Camera.ViewportSize.X - 50)
            local newY = math.clamp(startPos.Y.Offset + delta.Y, 0, Camera.ViewportSize.Y - 30)
            frame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        end
    end)
end

local function GetNearestPlayer(maxDist, targetPart)
    local nearest, nearestDist = nil, maxDist or math.huge
    targetPart = targetPart or "HumanoidRootPart"
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local part = plr.Character:FindFirstChild(targetPart) or plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChild("Humanoid")
            if part and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                    if dist < nearestDist then
                        nearest = plr
                        nearestDist = dist
                    end
                end
            end
        end
    end
    return nearest
end

local function WorldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToScreenPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

-- ================================================================
-- UI COMPONENT LIBRARY
-- ================================================================

local function CreateToggle(parent, text, default, callback, description)
    local togVal = default or false
    local T = CurrentTheme

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, description and 46 or 34)
    frame.BackgroundColor3 = T.Tertiary
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 7)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -65, 0, 18)
    label.Position = UDim2.new(0, 10, 0, description and 6 or 8)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = T.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.Parent = frame

    if description then
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -65, 0, 14)
        desc.Position = UDim2.new(0, 10, 0, 26)
        desc.BackgroundTransparency = 1
        desc.Text = description
        desc.TextColor3 = T.TextMuted
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 10
        desc.Parent = frame
    end

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 44, 0, 22)
    toggleBtn.Position = UDim2.new(1, -54, 0.5, -11)
    toggleBtn.BackgroundColor3 = togVal and T.Toggle_On or T.Toggle_Off
    toggleBtn.Text = ""
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = frame
    local tbCorner = Instance.new("UICorner", toggleBtn)
    tbCorner.CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = togVal and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = toggleBtn
    local kCorner = Instance.new("UICorner", knob)
    kCorner.CornerRadius = UDim.new(1, 0)
    local kShadow = Instance.new("UIStroke", knob)
    kShadow.Color = Color3.fromRGB(0, 0, 0)
    kShadow.Thickness = 0.5
    kShadow.Transparency = 0.7

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = frame

    clickBtn.MouseButton1Click:Connect(function()
        togVal = not togVal
        Tween(toggleBtn, {BackgroundColor3 = togVal and T.Toggle_On or T.Toggle_Off}, 0.2)
        Tween(knob, {Position = togVal and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}, 0.2)
        if callback then callback(togVal) end
    end)

    local function SetValue(val)
        togVal = val
        Tween(toggleBtn, {BackgroundColor3 = togVal and T.Toggle_On or T.Toggle_Off}, 0.2)
        Tween(knob, {Position = togVal and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}, 0.2)
        if callback then callback(togVal) end
    end

    return frame, function() return togVal end, SetValue
end

local function CreateSlider(parent, text, min, max, default, callback, suffix)
    local val = default or min
    suffix = suffix or ""
    local T = CurrentTheme

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 54)
    frame.BackgroundColor3 = T.Tertiary
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 7)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = T.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.Parent = frame

    local valBox = Instance.new("TextBox")
    valBox.Size = UDim2.new(0, 65, 0, 22)
    valBox.Position = UDim2.new(1, -73, 0, 4)
    valBox.BackgroundColor3 = T.Secondary
    valBox.Text = tostring(val) .. suffix
    valBox.TextColor3 = T.Slider
    valBox.PlaceholderColor3 = T.TextMuted
    valBox.Font = Enum.Font.GothamBold
    valBox.TextSize = 12
    valBox.BorderSizePixel = 0
    valBox.ClearTextOnFocus = true
    valBox.Parent = frame
    local vbCorner = Instance.new("UICorner", valBox)
    vbCorner.CornerRadius = UDim.new(0, 5)

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 38)
    track.BackgroundColor3 = T.Secondary
    track.BorderSizePixel = 0
    track.Parent = frame
    local tCorner = Instance.new("UICorner", track)
    tCorner.CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = T.Slider
    fill.BorderSizePixel = 0
    fill.Parent = track
    local fCorner = Instance.new("UICorner", fill)
    fCorner.CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new((val - min) / (max - min), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 3
    knob.Parent = track
    local kCorner = Instance.new("UICorner", knob)
    kCorner.CornerRadius = UDim.new(1, 0)

    local sliding = false
    local clickDetect = Instance.new("TextButton")
    clickDetect.Size = UDim2.new(1, 0, 1, 10)
    clickDetect.Position = UDim2.new(0, 0, 0, -5)
    clickDetect.BackgroundTransparency = 1
    clickDetect.Text = ""
    clickDetect.ZIndex = 4
    clickDetect.Parent = track

    local function UpdateSlider(relative)
        relative = math.clamp(relative, 0, 1)
        val = math.floor(min + (max - min) * relative + 0.5)
        valBox.Text = tostring(val) .. suffix
        fill.Size = UDim2.new(relative, 0, 1, 0)
        knob.Position = UDim2.new(relative, -7, 0.5, -7)
        if callback then callback(val) end
    end

    clickDetect.MouseButton1Down:Connect(function()
        sliding = true
        local rel = (Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
        UpdateSlider(rel)
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and i.UserInputType == Enum.UserInputType.MouseMove then
            local rel = (Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            UpdateSlider(rel)
        end
    end)

    valBox.FocusLost:Connect(function()
        local n = tonumber(valBox.Text:gsub(suffix, ""))
        if n then
            n = math.clamp(n, min, max)
            UpdateSlider((n - min) / (max - min))
        else
            valBox.Text = tostring(val) .. suffix
        end
    end)

    return frame
end

local function CreateButton(parent, text, callback, color, icon)
    local T = CurrentTheme
    color = color or T.Button
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 34)
    btn.BackgroundColor3 = color
    btn.Text = (icon and icon .. "  " or "") .. text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.Parent = parent
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 7)
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = 0.85
    stroke.Thickness = 1

    btn.MouseEnter:Connect(function()
        Tween(btn, {BackgroundColor3 = Color3.new(
            math.min(color.R + 0.1, 1),
            math.min(color.G + 0.1, 1),
            math.min(color.B + 0.1, 1)
        )}, 0.15)
        Tween(stroke, {Transparency = 0.6}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, {BackgroundColor3 = color}, 0.15)
        Tween(stroke, {Transparency = 0.85}, 0.15)
    end)
    btn.MouseButton1Down:Connect(function()
        Tween(btn, {BackgroundColor3 = Color3.new(
            math.max(color.R - 0.1, 0),
            math.max(color.G - 0.1, 0),
            math.max(color.B - 0.1, 0)
        )}, 0.1)
    end)
    btn.MouseButton1Up:Connect(function()
        Tween(btn, {BackgroundColor3 = color}, 0.1)
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return btn
end

local function CreateSection(parent, title)
    local T = CurrentTheme
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -10, 0, 22)
    section.BackgroundTransparency = 1
    section.Parent = parent

    local line1 = Instance.new("Frame")
    line1.Size = UDim2.new(0.25, 0, 0, 1)
    line1.Position = UDim2.new(0, 0, 0.5, 0)
    line1.BackgroundColor3 = T.Border
    line1.BorderSizePixel = 0
    line1.Parent = section

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0.25, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "  " .. title .. "  "
    label.TextColor3 = T.Accent
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.Parent = section

    local line2 = Instance.new("Frame")
    line2.Size = UDim2.new(0.25, 0, 0, 1)
    line2.Position = UDim2.new(0.75, 0, 0.5, 0)
    line2.BackgroundColor3 = T.Border
    line2.BorderSizePixel = 0
    line2.Parent = section
    return section
end

local function CreateDropdown(parent, text, options, default, callback)
    local selected = default or options[1]
    local open = false
    local T = CurrentTheme

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 34)
    container.BackgroundColor3 = T.Tertiary
    container.BorderSizePixel = 0
    container.ClipsDescendants = false
    container.ZIndex = 10
    container.Parent = parent
    local corner = Instance.new("UICorner", container)
    corner.CornerRadius = UDim.new(0, 7)

    local labelTxt = Instance.new("TextLabel")
    labelTxt.Size = UDim2.new(0.45, 0, 1, 0)
    labelTxt.Position = UDim2.new(0, 10, 0, 0)
    labelTxt.BackgroundTransparency = 1
    labelTxt.Text = text
    labelTxt.TextColor3 = T.Text
    labelTxt.TextXAlignment = Enum.TextXAlignment.Left
    labelTxt.Font = Enum.Font.GothamMedium
    labelTxt.TextSize = 13
    labelTxt.ZIndex = 10
    labelTxt.Parent = container

    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Size = UDim2.new(0.45, -30, 1, 0)
    selectedLabel.Position = UDim2.new(0.45, 5, 0, 0)
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Text = selected
    selectedLabel.TextColor3 = T.Accent
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
    selectedLabel.Font = Enum.Font.GothamMedium
    selectedLabel.TextSize = 12
    selectedLabel.ZIndex = 10
    selectedLabel.Parent = container

    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 22, 1, 0)
    arrow.Position = UDim2.new(1, -26, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = T.TextDim
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 10
    arrow.ZIndex = 10
    arrow.Parent = container

    local dropFrame = Instance.new("Frame")
    dropFrame.Size = UDim2.new(1, 0, 0, math.min(#options, 6) * 28 + 8)
    dropFrame.Position = UDim2.new(0, 0, 1, 4)
    dropFrame.BackgroundColor3 = T.Secondary
    dropFrame.BorderSizePixel = 0
    dropFrame.ZIndex = 20
    dropFrame.Visible = false
    dropFrame.Parent = container
    local dCorner = Instance.new("UICorner", dropFrame)
    dCorner.CornerRadius = UDim.new(0, 7)
    local dStroke = Instance.new("UIStroke", dropFrame)
    dStroke.Color = T.Border
    dStroke.Thickness = 1

    local dScroll = Instance.new("ScrollingFrame")
    dScroll.Size = UDim2.new(1, -4, 1, -4)
    dScroll.Position = UDim2.new(0, 2, 0, 2)
    dScroll.BackgroundTransparency = 1
    dScroll.BorderSizePixel = 0
    dScroll.ScrollBarThickness = 3
    dScroll.ScrollBarImageColor3 = T.Accent
    dScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    dScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    dScroll.ZIndex = 21
    dScroll.Parent = dropFrame

    local dList = Instance.new("UIListLayout", dScroll)
    dList.SortOrder = Enum.SortOrder.LayoutOrder
    dList.Padding = UDim.new(0, 2)
    local dPad = Instance.new("UIPadding", dScroll)
    dPad.PaddingTop = UDim.new(0, 2)
    dPad.PaddingLeft = UDim.new(0, 2)
    dPad.PaddingRight = UDim.new(0, 2)

    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 26)
        optBtn.BackgroundColor3 = selected == opt and T.Accent or T.Tertiary
        optBtn.Text = opt
        optBtn.TextColor3 = selected == opt and Color3.fromRGB(255,255,255) or T.TextDim
        optBtn.Font = Enum.Font.GothamMedium
        optBtn.TextSize = 12
        optBtn.BorderSizePixel = 0
        optBtn.ZIndex = 22
        optBtn.Parent = dScroll
        local oCorner = Instance.new("UICorner", optBtn)
        oCorner.CornerRadius = UDim.new(0, 5)

        optBtn.MouseEnter:Connect(function()
            if selected ~= opt then
                Tween(optBtn, {BackgroundColor3 = T.Tertiary}, 0.1)
                optBtn.TextColor3 = T.Text
            end
        end)
        optBtn.MouseLeave:Connect(function()
            if selected ~= opt then
                Tween(optBtn, {BackgroundColor3 = Color3.fromRGB(40, 40, 55)}, 0.1)
                optBtn.TextColor3 = T.TextDim
            end
        end)
        optBtn.MouseButton1Click:Connect(function()
            -- Reset all
            for _, child in ipairs(dScroll:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
                    child.TextColor3 = T.TextDim
                end
            end
            selected = opt
            selectedLabel.Text = opt
            optBtn.BackgroundColor3 = T.Accent
            optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            open = false
            dropFrame.Visible = false
            Tween(arrow, {Rotation = 0}, 0.2)
            if callback then callback(opt) end
        end)
    end

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 11
    clickBtn.Parent = container
    clickBtn.MouseButton1Click:Connect(function()
        open = not open
        dropFrame.Visible = open
        Tween(arrow, {Rotation = open and 180 or 0}, 0.2)
    end)
    return container
end

local function CreateColorPicker(parent, text, default, callback)
    local T = CurrentTheme
    local color = default or Color3.fromRGB(255, 100, 100)
    local open = false

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 34)
    container.BackgroundColor3 = T.Tertiary
    container.BorderSizePixel = 0
    container.ClipsDescendants = false
    container.ZIndex = 5
    container.Parent = parent
    local corner = Instance.new("UICorner", container)
    corner.CornerRadius = UDim.new(0, 7)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = T.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.ZIndex = 5
    label.Parent = container

    local colorPreview = Instance.new("TextButton")
    colorPreview.Size = UDim2.new(0, 50, 0, 22)
    colorPreview.Position = UDim2.new(1, -58, 0.5, -11)
    colorPreview.BackgroundColor3 = color
    colorPreview.Text = ""
    colorPreview.BorderSizePixel = 0
    colorPreview.ZIndex = 6
    colorPreview.Parent = container
    local cpCorner = Instance.new("UICorner", colorPreview)
    cpCorner.CornerRadius = UDim.new(0, 5)
    local cpStroke = Instance.new("UIStroke", colorPreview)
    cpStroke.Color = T.Border
    cpStroke.Thickness = 1

    -- Simple RGB sliders in a dropdown panel
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Size = UDim2.new(1, 0, 0, 110)
    pickerFrame.Position = UDim2.new(0, 0, 1, 4)
    pickerFrame.BackgroundColor3 = T.Secondary
    pickerFrame.BorderSizePixel = 0
    pickerFrame.ZIndex = 10
    pickerFrame.Visible = false
    pickerFrame.Parent = container
    local pfCorner = Instance.new("UICorner", pickerFrame)
    pfCorner.CornerRadius = UDim.new(0, 7)
    local pfStroke = Instance.new("UIStroke", pickerFrame)
    pfStroke.Color = T.Border
    pfStroke.Thickness = 1

    local r, g, b = math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)

    local function UpdateColor()
        color = Color3.fromRGB(r, g, b)
        colorPreview.BackgroundColor3 = color
        if callback then callback(color) end
    end

    local function MakeRGBSlider(parent_, label_, val_, minV, maxV, clr, onChange)
        local sf = Instance.new("Frame")
        sf.Size = UDim2.new(1, -10, 0, 28)
        sf.BackgroundTransparency = 1
        sf.Parent = parent_

        local sl = Instance.new("TextLabel")
        sl.Size = UDim2.new(0, 14, 1, 0)
        sl.BackgroundTransparency = 1
        sl.Text = label_
        sl.TextColor3 = clr
        sl.Font = Enum.Font.GothamBold
        sl.TextSize = 11
        sl.Parent = sf

        local track2 = Instance.new("Frame")
        track2.Size = UDim2.new(1, -55, 0, 5)
        track2.Position = UDim2.new(0, 18, 0.5, -2)
        track2.BackgroundColor3 = T.Tertiary
        track2.BorderSizePixel = 0
        track2.Parent = sf
        local t2c = Instance.new("UICorner", track2)
        t2c.CornerRadius = UDim.new(1, 0)

        local fill2 = Instance.new("Frame")
        fill2.Size = UDim2.new(val_ / maxV, 0, 1, 0)
        fill2.BackgroundColor3 = clr
        fill2.BorderSizePixel = 0
        fill2.Parent = track2
        local f2c = Instance.new("UICorner", fill2)
        f2c.CornerRadius = UDim.new(1, 0)

        local knob2 = Instance.new("Frame")
        knob2.Size = UDim2.new(0, 10, 0, 10)
        knob2.Position = UDim2.new(val_ / maxV, -5, 0.5, -5)
        knob2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob2.BorderSizePixel = 0
        knob2.ZIndex = 3
        knob2.Parent = track2
        local k2c = Instance.new("UICorner", knob2)
        k2c.CornerRadius = UDim.new(1, 0)

        local valLbl = Instance.new("TextLabel")
        valLbl.Size = UDim2.new(0, 32, 1, 0)
        valLbl.Position = UDim2.new(1, -33, 0, 0)
        valLbl.BackgroundTransparency = 1
        valLbl.Text = tostring(val_)
        valLbl.TextColor3 = T.TextDim
        valLbl.Font = Enum.Font.GothamBold
        valLbl.TextSize = 10
        valLbl.Parent = sf

        local sliding2 = false
        local cd = Instance.new("TextButton")
        cd.Size = UDim2.new(1, 0, 1, 6)
        cd.Position = UDim2.new(0,0,0,-3)
        cd.BackgroundTransparency = 1
        cd.Text = ""
        cd.ZIndex = 5
        cd.Parent = track2

        cd.MouseButton1Down:Connect(function() sliding2 = true end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding2 = false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if sliding2 and i.UserInputType == Enum.UserInputType.MouseMove then
                local rel = math.clamp((Mouse.X - track2.AbsolutePosition.X) / track2.AbsoluteSize.X, 0, 1)
                val_ = math.floor(rel * maxV)
                fill2.Size = UDim2.new(rel, 0, 1, 0)
                knob2.Position = UDim2.new(rel, -5, 0.5, -5)
                valLbl.Text = tostring(val_)
                onChange(val_)
                UpdateColor()
            end
        end)
        return sf
    end

    local pfList = Instance.new("UIListLayout", pickerFrame)
    pfList.SortOrder = Enum.SortOrder.LayoutOrder
    pfList.Padding = UDim.new(0, 2)
    local pfPad = Instance.new("UIPadding", pickerFrame)
    pfPad.PaddingAll = UDim.new(0, 5)

    MakeRGBSlider(pickerFrame, "R", r, 0, 255, Color3.fromRGB(255,80,80), function(v) r = v end)
    MakeRGBSlider(pickerFrame, "G", g, 0, 255, Color3.fromRGB(80,255,80), function(v) g = v end)
    MakeRGBSlider(pickerFrame, "B", b, 0, 255, Color3.fromRGB(80,160,255), function(v) b = v end)

    colorPreview.MouseButton1Click:Connect(function()
        open = not open
        pickerFrame.Visible = open
    end)

    return container
end

local function CreateKeybind(parent, text, default, callback)
    local T = CurrentTheme
    local key = default
    local listening = false

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 34)
    frame.BackgroundColor3 = T.Tertiary
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 7)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = T.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.Parent = frame

    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 80, 0, 22)
    keyBtn.Position = UDim2.new(1, -88, 0.5, -11)
    keyBtn.BackgroundColor3 = T.Secondary
    keyBtn.Text = key and key.Name or "None"
    keyBtn.TextColor3 = T.Accent
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextSize = 11
    keyBtn.BorderSizePixel = 0
    keyBtn.Parent = frame
    local kbCorner = Instance.new("UICorner", keyBtn)
    kbCorner.CornerRadius = UDim.new(0, 5)
    local kbStroke = Instance.new("UIStroke", keyBtn)
    kbStroke.Color = T.Border
    kbStroke.Thickness = 1

    keyBtn.MouseButton1Click:Connect(function()
        listening = true
        keyBtn.Text = "..."
        keyBtn.TextColor3 = T.Warning
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if listening and not gpe then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                key = input.KeyCode
                keyBtn.Text = key.Name
                keyBtn.TextColor3 = T.Accent
                listening = false
                if callback then callback(key) end
            end
        end
    end)

    return frame, function() return key end
end

local function CreateTextInput(parent, text, placeholder, callback)
    local T = CurrentTheme

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 54)
    frame.BackgroundColor3 = T.Tertiary
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 7)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 18)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = T.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.Parent = frame

    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -20, 0, 24)
    inputBox.Position = UDim2.new(0, 10, 0, 25)
    inputBox.BackgroundColor3 = T.Secondary
    inputBox.PlaceholderText = placeholder or "Enter text..."
    inputBox.PlaceholderColor3 = T.TextMuted
    inputBox.Text = ""
    inputBox.TextColor3 = T.Text
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 12
    inputBox.BorderSizePixel = 0
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.Parent = frame
    local ibCorner = Instance.new("UICorner", inputBox)
    ibCorner.CornerRadius = UDim.new(0, 5)
    local ibPad = Instance.new("UIPadding", inputBox)
    ibPad.PaddingLeft = UDim.new(0, 8)

    inputBox.FocusLost:Connect(function(enterPressed)
        if callback then callback(inputBox.Text, enterPressed) end
    end)
    return frame
end

local function CreateLabel(parent, text, subtext)
    local T = CurrentTheme
    local h = subtext and 42 or 28

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, h)
    frame.BackgroundColor3 = T.Tertiary
    frame.BorderSizePixel = 0
    frame.Parent = parent
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 7)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 18)
    lbl.Position = UDim2.new(0, 10, 0, subtext and 5 or 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = T.TextDim
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.Parent = frame

    if subtext then
        local sub = Instance.new("TextLabel")
        sub.Size = UDim2.new(1, -10, 0, 14)
        sub.Position = UDim2.new(0, 10, 0, 24)
        sub.BackgroundTransparency = 1
        sub.Text = subtext
        sub.TextColor3 = T.TextMuted
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.Font = Enum.Font.Gotham
        sub.TextSize = 10
        sub.Parent = frame
    end
    return frame
end

local function CreateSeparator(parent)
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, -10, 0, 1)
    sep.BackgroundColor3 = CurrentTheme.Border
    sep.BorderSizePixel = 0
    sep.Parent = parent
    return sep
end

-- ================================================================
-- ESP SYSTEM
-- ================================================================

local ESPConfig = {
    Enabled = false,
    Boxes = false,
    Names = false,
    Health = false,
    Tracers = false,
    Distance = false,
    Skeletons = false,
    Highlights = false,
    BoxColor = Color3.fromRGB(255, 100, 100),
    NameColor = Color3.fromRGB(255, 255, 255),
    TracerColor = Color3.fromRGB(255, 255, 0),
    HealthColorGood = Color3.fromRGB(0, 255, 0),
    HealthColorBad = Color3.fromRGB(255, 0, 0),
    MaxDist = 1000,
    TeamCheck = false,
}

local function CleanupESP()
    for _, obj in pairs(espObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    espObjects = {}
end

local function GetESPContainer()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("ESPGui")
    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Name = "ESPGui"
        gui.ResetOnSpawn = false
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = LocalPlayer.PlayerGui
    end
    return gui
end

local function UpdateESP()
    local gui = GetESPContainer()
    -- Clear old
    for child in pairs(espObjects) do
        if typeof(child) == "Instance" and child.Parent then
            child:Destroy()
        end
    end
    espObjects = {}

    if not ESPConfig.Enabled then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local char = plr.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            local head = char:FindFirstChild("Head")
            if not (root and hum and head) then continue end

            if ESPConfig.Highlights then
                local existing = char:FindFirstChild("ESPHighlight")
                if not existing then
                    local hl = Instance.new("SelectionBox")
                    hl.Name = "ESPHighlight"
                    hl.Adornee = char
                    hl.Color3 = ESPConfig.BoxColor
                    hl.LineThickness = 0.04
                    hl.SurfaceTransparency = 0.8
                    hl.SurfaceColor3 = ESPConfig.BoxColor
                    hl.Parent = gui
                    table.insert(espObjects, hl)
                end
            end

            -- Billboard ESP
            local billboard = Instance.new("BillboardGui")
            billboard.Adornee = head
            billboard.Size = UDim2.new(0, 200, 0, 80)
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.AlwaysOnTop = true
            billboard.ResetOnSpawn = false
            billboard.Parent = gui
            table.insert(espObjects, billboard)

            local yOffset = 0

            if ESPConfig.Names then
                local nameLbl = Instance.new("TextLabel")
                nameLbl.Size = UDim2.new(1, 0, 0, 20)
                nameLbl.Position = UDim2.new(0, 0, 0, yOffset)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Text = plr.Name
                nameLbl.TextColor3 = ESPConfig.NameColor
                nameLbl.Font = Enum.Font.GothamBold
                nameLbl.TextSize = 14
                nameLbl.TextStrokeTransparency = 0.5
                nameLbl.Parent = billboard
                yOffset = yOffset + 20
            end

            if ESPConfig.Health then
                local healthPct = hum.Health / hum.MaxHealth
                local healthLbl = Instance.new("TextLabel")
                healthLbl.Size = UDim2.new(1, 0, 0, 16)
                healthLbl.Position = UDim2.new(0, 0, 0, yOffset)
                healthLbl.BackgroundTransparency = 1
                healthLbl.Text = string.format("HP: %d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))
                healthLbl.TextColor3 = Color3.new(1 - healthPct, healthPct, 0)
                healthLbl.Font = Enum.Font.GothamBold
                healthLbl.TextSize = 12
                healthLbl.TextStrokeTransparency = 0.5
                healthLbl.Parent = billboard
                yOffset = yOffset + 16
            end

            if ESPConfig.Distance then
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myRoot then
                    local dist = (root.Position - myRoot.Position).Magnitude
                    local distLbl = Instance.new("TextLabel")
                    distLbl.Size = UDim2.new(1, 0, 0, 14)
                    distLbl.Position = UDim2.new(0, 0, 0, yOffset)
                    distLbl.BackgroundTransparency = 1
                    distLbl.Text = string.format("[%.0f studs]", dist)
                    distLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
                    distLbl.Font = Enum.Font.Gotham
                    distLbl.TextSize = 11
                    distLbl.TextStrokeTransparency = 0.5
                    distLbl.Parent = billboard
                end
            end
        end
    end
end

-- ================================================================
-- FOV CIRCLE
-- ================================================================

local function UpdateFOVCircle(enabled, radius, color)
    if fovCircle then fovCircle:Destroy() fovCircle = nil end
    if not enabled then return end
    local gui = LocalPlayer.PlayerGui:FindFirstChild("FOVGui") or Instance.new("ScreenGui")
    gui.Name = "FOVGui"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer.PlayerGui

    fovCircle = Instance.new("Frame")
    fovCircle.Size = UDim2.new(0, radius * 2, 0, radius * 2)
    fovCircle.Position = UDim2.new(0.5, -radius, 0.5, -radius)
    fovCircle.BackgroundTransparency = 1
    fovCircle.BorderSizePixel = 0
    fovCircle.Parent = gui

    local circle = Instance.new("UICorner", fovCircle)
    circle.CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", fovCircle)
    stroke.Color = color or Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.3
end

-- ================================================================
-- WATERMARK & FPS COUNTER
-- ================================================================

local function SetupOverlays(screenGui)
    -- Watermark
    local wmFrame = Instance.new("Frame")
    wmFrame.Size = UDim2.new(0, 200, 0, 28)
    wmFrame.Position = UDim2.new(0, 8, 0, 8)
    wmFrame.BackgroundColor3 = CurrentTheme.Secondary
    wmFrame.BorderSizePixel = 0
    wmFrame.Parent = screenGui
    local wmCorner = Instance.new("UICorner", wmFrame)
    wmCorner.CornerRadius = UDim.new(0, 6)
    local wmStroke = Instance.new("UIStroke", wmFrame)
    wmStroke.Color = CurrentTheme.Accent
    wmStroke.Thickness = 1

    watermarkLabel = Instance.new("TextLabel")
    watermarkLabel.Size = UDim2.new(1, -10, 1, 0)
    watermarkLabel.Position = UDim2.new(0, 5, 0, 0)
    watermarkLabel.BackgroundTransparency = 1
    watermarkLabel.TextColor3 = CurrentTheme.Text
    watermarkLabel.Font = Enum.Font.GothamBold
    watermarkLabel.TextSize = 12
    watermarkLabel.TextXAlignment = Enum.TextXAlignment.Left
    watermarkLabel.Parent = wmFrame

    -- FPS
    local fpsFrame = Instance.new("Frame")
    fpsFrame.Size = UDim2.new(0, 100, 0, 24)
    fpsFrame.Position = UDim2.new(0, 8, 0, 40)
    fpsFrame.BackgroundColor3 = CurrentTheme.Secondary
    fpsFrame.BorderSizePixel = 0
    fpsFrame.Parent = screenGui
    local fpsCorner = Instance.new("UICorner", fpsFrame)
    fpsCorner.CornerRadius = UDim.new(0, 6)
    local fpsStroke = Instance.new("UIStroke", fpsFrame)
    fpsStroke.Color = CurrentTheme.Border
    fpsStroke.Thickness = 1

    fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(1, -10, 1, 0)
    fpsLabel.Position = UDim2.new(0, 5, 0, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.TextColor3 = CurrentTheme.TextDim
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextSize = 11
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.Parent = fpsFrame

    -- Update loop
    local lastTime = tick()
    local frameCount = 0
    RunService.Heartbeat:Connect(function()
        frameCount = frameCount + 1
        local now = tick()
        if now - lastTime >= 0.5 then
            local fps = math.floor(frameCount / (now - lastTime))
            frameCount = 0
            lastTime = now
            local fpsColor = fps >= 55 and Color3.fromRGB(80, 220, 100) or fps >= 30 and Color3.fromRGB(220, 180, 0) or Color3.fromRGB(220, 60, 60)
            if fpsLabel then
                fpsLabel.Text = string.format("FPS: %d", fps)
                fpsLabel.TextColor3 = fpsColor
            end
            if watermarkLabel then
                watermarkLabel.Text = string.format("🎮 Hub v2.0 | %s", os.date("%H:%M:%S"))
            end
        end
    end)
end

-- ================================================================
-- MAIN HUB UI CONSTRUCTION
-- ================================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MultiGameHubV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer.PlayerGui

SetupOverlays(ScreenGui)

-- Notification holder
NotifHolder = Instance.new("Frame")
NotifHolder.Size = UDim2.new(0, 290, 1, -20)
NotifHolder.Position = UDim2.new(1, -300, 0, 10)
NotifHolder.BackgroundTransparency = 1
NotifHolder.BorderSizePixel = 0
NotifHolder.Parent = ScreenGui
local nhList = Instance.new("UIListLayout", NotifHolder)
nhList.SortOrder = Enum.SortOrder.LayoutOrder
nhList.VerticalAlignment = Enum.VerticalAlignment.Bottom
nhList.Padding = UDim.new(0, 5)

-- TOGGLE BUTTON
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 44, 0, 44)
toggleBtn.Position = UDim2.new(0, 10, 0.5, -22)
toggleBtn.BackgroundColor3 = CurrentTheme.Secondary
toggleBtn.Text = "☰"
toggleBtn.TextColor3 = CurrentTheme.Accent
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 22
toggleBtn.BorderSizePixel = 0
toggleBtn.ZIndex = 100
toggleBtn.Parent = ScreenGui
local tbCorner = Instance.new("UICorner", toggleBtn)
tbCorner.CornerRadius = UDim.new(0, 10)
local tbStroke = Instance.new("UIStroke", toggleBtn)
tbStroke.Color = CurrentTheme.Accent
tbStroke.Thickness = 1.5

-- MAIN WINDOW
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 340, 0, 560)
MainFrame.Position = UDim2.new(0, 64, 0.5, -280)
MainFrame.BackgroundColor3 = CurrentTheme.Background
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
local mfCorner = Instance.new("UICorner", MainFrame)
mfCorner.CornerRadius = UDim.new(0, 12)
local mfStroke = Instance.new("UIStroke", MainFrame)
mfStroke.Color = CurrentTheme.Border
mfStroke.Thickness = 1.5

-- GRADIENT TOP BAR
local TopGrad = Instance.new("UIGradient")
TopGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, CurrentTheme.Accent),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 40, 160)),
})
TopGrad.Rotation = 90

local GradBar = Instance.new("Frame")
GradBar.Size = UDim2.new(1, 0, 0, 3)
GradBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GradBar.BorderSizePixel = 0
GradBar.Parent = MainFrame
TopGrad.Parent = GradBar

-- TITLE BAR
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 58)
TitleBar.Position = UDim2.new(0, 0, 0, 3)
TitleBar.BackgroundColor3 = CurrentTheme.Secondary
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleIcon = Instance.new("Frame")
TitleIcon.Size = UDim2.new(0, 38, 0, 38)
TitleIcon.Position = UDim2.new(0, 10, 0.5, -19)
TitleIcon.BackgroundColor3 = CurrentTheme.Accent
TitleIcon.BorderSizePixel = 0
TitleIcon.Parent = TitleBar
local tiCorner = Instance.new("UICorner", TitleIcon)
tiCorner.CornerRadius = UDim.new(0, 9)
local tiLabel = Instance.new("TextLabel")
tiLabel.Size = UDim2.new(1, 0, 1, 0)
tiLabel.BackgroundTransparency = 1
tiLabel.Text = "🎮"
tiLabel.TextSize = 20
tiLabel.Font = Enum.Font.GothamBold
tiLabel.Parent = TitleIcon

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -120, 0, 24)
TitleLabel.Position = UDim2.new(0, 58, 0, 9)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "Script Hub"
TitleLabel.TextColor3 = CurrentTheme.Text
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 20
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(1, -120, 0, 16)
SubLabel.Position = UDim2.new(0, 58, 0, 34)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "v2.0 — Studio Edition"
SubLabel.TextColor3 = CurrentTheme.TextMuted
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextSize = 11
SubLabel.TextXAlignment = Enum.TextXAlignment.Left
SubLabel.Parent = TitleBar

-- Window controls
local function MakeWinBtn(pos, color, symbol)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 26, 0, 26)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = symbol
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = TitleBar
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(1, 0)
    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundTransparency = 0.3}, 0.1) end)
    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundTransparency = 0}, 0.1) end)
    return btn
end

local CloseMain = MakeWinBtn(UDim2.new(1, -34, 0.5, -13), Color3.fromRGB(200, 60, 60), "✕")
local MinMain = MakeWinBtn(UDim2.new(1, -64, 0.5, -13), Color3.fromRGB(200, 160, 0), "─")

local minimized = false
MinMain.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        Tween(MainFrame, {Size = UDim2.new(0, 340, 0, 61)}, 0.3)
    else
        Tween(MainFrame, {Size = UDim2.new(0, 340, 0, 560)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
end)

CloseMain.MouseButton1Click:Connect(function()
    Tween(MainFrame, {Size = UDim2.new(0, 340, 0, 0), BackgroundTransparency = 1}, 0.3)
    task.wait(0.3)
    MainFrame.Visible = false
    MainFrame.BackgroundTransparency = 0
    MainFrame.Size = UDim2.new(0, 340, 0, 560)
end)

MakeDraggable(MainFrame, TitleBar)

-- SEARCH BAR
local SearchOuter = Instance.new("Frame")
SearchOuter.Size = UDim2.new(1, -20, 0, 38)
SearchOuter.Position = UDim2.new(0, 10, 0, 68)
SearchOuter.BackgroundColor3 = CurrentTheme.Tertiary
SearchOuter.BorderSizePixel = 0
SearchOuter.Parent = MainFrame
local soCorner = Instance.new("UICorner", SearchOuter)
soCorner.CornerRadius = UDim.new(0, 9)
local soStroke = Instance.new("UIStroke", SearchOuter)
soStroke.Color = CurrentTheme.Border
soStroke.Thickness = 1

local SearchIcon = Instance.new("TextLabel")
SearchIcon.Size = UDim2.new(0, 34, 1, 0)
SearchIcon.BackgroundTransparency = 1
SearchIcon.Text = "🔍"
SearchIcon.TextSize = 15
SearchIcon.Font = Enum.Font.Gotham
SearchIcon.TextColor3 = CurrentTheme.TextMuted
SearchIcon.Parent = SearchOuter

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -44, 1, 0)
SearchBox.Position = UDim2.new(0, 34, 0, 0)
SearchBox.BackgroundTransparency = 1
SearchBox.Text = ""
SearchBox.PlaceholderText = "Search games..."
SearchBox.PlaceholderColor3 = CurrentTheme.TextMuted
SearchBox.TextColor3 = CurrentTheme.Text
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 13
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.ClearTextOnFocus = false
SearchBox.Parent = SearchOuter

SearchBox.Focused:Connect(function()
    Tween(soStroke, {Color = CurrentTheme.Accent}, 0.2)
end)
SearchBox.FocusLost:Connect(function()
    Tween(soStroke, {Color = CurrentTheme.Border}, 0.2)
end)

-- STATS BAR
local StatsBar = Instance.new("Frame")
StatsBar.Size = UDim2.new(1, -20, 0, 26)
StatsBar.Position = UDim2.new(0, 10, 0, 112)
StatsBar.BackgroundColor3 = CurrentTheme.Tertiary
StatsBar.BorderSizePixel = 0
StatsBar.Parent = MainFrame
local sbCorner = Instance.new("UICorner", StatsBar)
sbCorner.CornerRadius = UDim.new(0, 7)

local CountLabel = Instance.new("TextLabel")
CountLabel.Size = UDim2.new(0.5, 0, 1, 0)
CountLabel.Position = UDim2.new(0, 8, 0, 0)
CountLabel.BackgroundTransparency = 1
CountLabel.TextColor3 = CurrentTheme.TextDim
CountLabel.Font = Enum.Font.GothamMedium
CountLabel.TextSize = 11
CountLabel.TextXAlignment = Enum.TextXAlignment.Left
CountLabel.Parent = StatsBar

local PlayerLabel = Instance.new("TextLabel")
PlayerLabel.Size = UDim2.new(0.5, -8, 1, 0)
PlayerLabel.Position = UDim2.new(0.5, 0, 0, 0)
PlayerLabel.BackgroundTransparency = 1
PlayerLabel.Text = "👤 " .. LocalPlayer.Name
PlayerLabel.TextColor3 = CurrentTheme.Accent
PlayerLabel.Font = Enum.Font.GothamMedium
PlayerLabel.TextSize = 11
PlayerLabel.TextXAlignment = Enum.TextXAlignment.Right
PlayerLabel.Parent = StatsBar

-- SCROLL FRAME
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -150)
ScrollFrame.Position = UDim2.new(0, 10, 0, 145)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.ScrollBarImageColor3 = CurrentTheme.Accent
ScrollFrame.ScrollBarImageTransparency = 0.5
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 6)
ListLayout.Parent = ScrollFrame

local ListPad = Instance.new("UIPadding")
ListPad.PaddingBottom = UDim.new(0, 10)
ListPad.Parent = ScrollFrame

-- ================================================================
-- GAMES DATA
-- ================================================================

local GAMES = {
    {name = "Arsenal", icon = "⚔️", color = Color3.fromRGB(220, 60, 60), desc = "FPS Shooter", tags = {"fps","shooter","gun"}},
    {name = "Rivals", icon = "🥊", color = Color3.fromRGB(200, 80, 40), desc = "PvP Fighter", tags = {"pvp","combat","fight"}},
    {name = "Hypershot", icon = "🎯", color = Color3.fromRGB(60, 160, 220), desc = "Aim Trainer", tags = {"aim","training","fps"}},
    {name = "Jailbreak", icon = "🚔", color = Color3.fromRGB(40, 100, 200), desc = "Open World RPG", tags = {"open world","crime","cars"}},
    {name = "Combat Arena", icon = "🗡️", color = Color3.fromRGB(160, 50, 200), desc = "Combat Game", tags = {"combat","pvp","arena"}},
    {name = "Steal a Brainrot", icon = "🧠", color = Color3.fromRGB(100, 200, 80), desc = "Steal Items Game", tags = {"steal","collect"}},
    {name = "Murder Mystery 2", icon = "🔪", color = Color3.fromRGB(180, 40, 40), desc = "Mystery Thriller", tags = {"mystery","murder","horror"}},
    {name = "Blade Ball", icon = "⚡", color = Color3.fromRGB(255, 180, 0), desc = "Deflect & Survive", tags = {"ball","deflect","pvp"}},
    {name = "Tower of Hell", icon = "🏗️", color = Color3.fromRGB(255, 100, 0), desc = "Obby Challenge", tags = {"obby","parkour","tower"}},
    {name = "Da Hood", icon = "🌆", color = Color3.fromRGB(80, 80, 120), desc = "Street Life Game", tags = {"street","gun","crime"}},
    {name = "Natural Disasters", icon = "🌪️", color = Color3.fromRGB(60, 140, 80), desc = "Survival Game", tags = {"survival","disaster","random"}},
    {name = "One Tap", icon = "💥", color = Color3.fromRGB(220, 40, 80), desc = "Quick FPS Game", tags = {"fps","fast","shooter"}},
    {name = "Bee Swarm Simulator", icon = "🐝", color = Color3.fromRGB(255, 200, 0), desc = "Honey Simulator", tags = {"sim","bees","farming"}},
    {name = "Flee the Facility", icon = "🏃", color = Color3.fromRGB(40, 160, 180), desc = "Horror Escape", tags = {"horror","escape","beast"}},
    {name = "Grow a Garden", icon = "🌻", color = Color3.fromRGB(80, 180, 60), desc = "Farming Sim", tags = {"farming","garden","sim"}},
    {name = "Bloxstrike", icon = "🔫", color = Color3.fromRGB(60, 80, 200), desc = "CS-Style FPS", tags = {"fps","cs","shooter"}},
    {name = "Break Your Bones", icon = "💀", color = Color3.fromRGB(160, 160, 180), desc = "Physics Ragdoll", tags = {"ragdoll","physics","funny"}},
    {name = "Slime RNG", icon = "🟢", color = Color3.fromRGB(60, 200, 120), desc = "RNG Luck Game", tags = {"rng","luck","collect"}},
    {name = "Pet Simulator X", icon = "🐾", color = Color3.fromRGB(255, 140, 0), desc = "Pet Collecting", tags = {"pets","sim","collect"}},
    {name = "Adopt Me!", icon = "🏠", color = Color3.fromRGB(255, 180, 200), desc = "Pet Adoption", tags = {"pets","rp","trading"}},
    {name = "Brookhaven", icon = "🏙️", color = Color3.fromRGB(100, 200, 255), desc = "Roleplay Game", tags = {"rp","roleplay","city"}},
    {name = "Islands", icon = "🏝️", color = Color3.fromRGB(80, 200, 160), desc = "Island Survival", tags = {"island","survival","build"}},
}

-- ================================================================
-- WINDOW FACTORY
-- ================================================================

local function CreateGameWindow(gameName, gameColor, gameIcon)
    if openWindows[gameName] then
        openWindows[gameName].Frame.Visible = true
        Tween(openWindows[gameName].Frame, {Size = UDim2.new(0, 400, 0, 530)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        return
    end

    -- ---- WINDOW FRAME ----
    local WIN = Instance.new("Frame")
    WIN.Size = UDim2.new(0, 400, 0, 530)
    WIN.Position = UDim2.new(0.5, -200 + math.random(-60, 60), 0.5, -265 + math.random(-40, 40))
    WIN.BackgroundColor3 = CurrentTheme.Background
    WIN.BorderSizePixel = 0
    WIN.ZIndex = 50
    WIN.ClipsDescendants = true
    WIN.Parent = ScreenGui
    local wCorner = Instance.new("UICorner", WIN)
    wCorner.CornerRadius = UDim.new(0, 12)
    local wStroke = Instance.new("UIStroke", WIN)
    wStroke.Color = gameColor
    wStroke.Thickness = 1.5

    -- Colored top bar
    local WGradBar = Instance.new("Frame")
    WGradBar.Size = UDim2.new(1, 0, 0, 3)
    WGradBar.BackgroundColor3 = gameColor
    WGradBar.BorderSizePixel = 0
    WGradBar.ZIndex = 51
    WGradBar.Parent = WIN

    -- TITLE BAR
    local WTB = Instance.new("Frame")
    WTB.Size = UDim2.new(1, 0, 0, 56)
    WTB.Position = UDim2.new(0, 0, 0, 3)
    WTB.BackgroundColor3 = CurrentTheme.Secondary
    WTB.BorderSizePixel = 0
    WTB.ZIndex = 51
    WTB.Parent = WIN

    local WIconBG = Instance.new("Frame")
    WIconBG.Size = UDim2.new(0, 38, 0, 38)
    WIconBG.Position = UDim2.new(0, 10, 0.5, -19)
    WIconBG.BackgroundColor3 = gameColor
    WIconBG.BorderSizePixel = 0
    WIconBG.ZIndex = 52
    WIconBG.Parent = WTB
    local wibCorner = Instance.new("UICorner", WIconBG)
    wibCorner.CornerRadius = UDim.new(0, 9)
    local WIconLbl = Instance.new("TextLabel")
    WIconLbl.Size = UDim2.new(1, 0, 1, 0)
    WIconLbl.BackgroundTransparency = 1
    WIconLbl.Text = gameIcon
    WIconLbl.TextSize = 20
    WIconLbl.Font = Enum.Font.GothamBold
    WIconLbl.ZIndex = 53
    WIconLbl.Parent = WIconBG

    local WTitle = Instance.new("TextLabel")
    WTitle.Size = UDim2.new(1, -130, 0, 22)
    WTitle.Position = UDim2.new(0, 58, 0, 8)
    WTitle.BackgroundTransparency = 1
    WTitle.Text = gameName
    WTitle.TextColor3 = CurrentTheme.Text
    WTitle.Font = Enum.Font.GothamBold
    WTitle.TextSize = 17
    WTitle.TextXAlignment = Enum.TextXAlignment.Left
    WTitle.ZIndex = 52
    WTitle.Parent = WTB

    local WSubLbl = Instance.new("TextLabel")
    WSubLbl.Size = UDim2.new(1, -130, 0, 15)
    WSubLbl.Position = UDim2.new(0, 58, 0, 32)
    WSubLbl.BackgroundTransparency = 1
    WSubLbl.Text = "Script Controls"
    WSubLbl.TextColor3 = CurrentTheme.TextMuted
    WSubLbl.Font = Enum.Font.Gotham
    WSubLbl.TextSize = 11
    WSubLbl.TextXAlignment = Enum.TextXAlignment.Left
    WSubLbl.ZIndex = 52
    WSubLbl.Parent = WTB

    -- Win buttons
    local function MakeWBtn(xOff, clr, sym, zidx)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 26, 0, 26)
        b.Position = UDim2.new(1, xOff, 0.5, -13)
        b.BackgroundColor3 = clr
        b.Text = sym
        b.TextColor3 = Color3.fromRGB(255,255,255)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 12
        b.BorderSizePixel = 0
        b.ZIndex = zidx or 55
        b.Parent = WTB
        local bc = Instance.new("UICorner", b)
        bc.CornerRadius = UDim.new(1,0)
        b.MouseEnter:Connect(function() Tween(b, {BackgroundTransparency = 0.3}, 0.1) end)
        b.MouseLeave:Connect(function() Tween(b, {BackgroundTransparency = 0}, 0.1) end)
        return b
    end

    local WClose = MakeWBtn(-36, Color3.fromRGB(200, 60, 60), "✕")
    local WMin = MakeWBtn(-66, Color3.fromRGB(200, 160, 0), "─")
    local WPin = MakeWBtn(-96, Color3.fromRGB(60, 160, 200), "📌")
    local pinned = false

    WPin.MouseButton1Click:Connect(function()
        pinned = not pinned
        WPin.Text = pinned and "📌" or "📌"
        WPin.BackgroundColor3 = pinned and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(60, 160, 200)
        WIN.ZIndex = pinned and 100 or 50
    end)

    local wMinimized = false
    WMin.MouseButton1Click:Connect(function()
        wMinimized = not wMinimized
        Tween(WIN, {Size = wMinimized and UDim2.new(0, 400, 0, 59) or UDim2.new(0, 400, 0, 530)}, 0.3, Enum.EasingStyle.Quart)
    end)

    WClose.MouseButton1Click:Connect(function()
        Tween(WIN, {Size = UDim2.new(0, 0, 0, 0)}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.wait(0.25)
        WIN:Destroy()
        openWindows[gameName] = nil
        gameStates[gameName] = nil
    end)

    MakeDraggable(WIN, WTB)

    -- TAB BAR (scrollable for many tabs)
    local TabBarScroll = Instance.new("ScrollingFrame")
    TabBarScroll.Size = UDim2.new(1, -20, 0, 36)
    TabBarScroll.Position = UDim2.new(0, 10, 0, 63)
    TabBarScroll.BackgroundColor3 = CurrentTheme.Secondary
    TabBarScroll.BorderSizePixel = 0
    TabBarScroll.ZIndex = 51
    TabBarScroll.ScrollBarThickness = 0
    TabBarScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabBarScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
    TabBarScroll.Parent = WIN
    local tbsCorner = Instance.new("UICorner", TabBarScroll)
    tbsCorner.CornerRadius = UDim.new(0, 8)

    local TabBarLayout = Instance.new("UIListLayout")
    TabBarLayout.FillDirection = Enum.FillDirection.Horizontal
    TabBarLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabBarLayout.Padding = UDim.new(0, 4)
    TabBarLayout.Parent = TabBarScroll
    local TabBarPad = Instance.new("UIPadding", TabBarScroll)
    TabBarPad.PaddingLeft = UDim.new(0, 4)
    TabBarPad.PaddingTop = UDim.new(0, 4)
    TabBarPad.PaddingBottom = UDim.new(0, 4)

    -- CONTENT SCROLL
    local ContentScroll = Instance.new("ScrollingFrame")
    ContentScroll.Size = UDim2.new(1, -20, 1, -112)
    ContentScroll.Position = UDim2.new(0, 10, 0, 103)
    ContentScroll.BackgroundTransparency = 1
    ContentScroll.BorderSizePixel = 0
    ContentScroll.ScrollBarThickness = 3
    ContentScroll.ScrollBarImageColor3 = gameColor
    ContentScroll.ScrollBarImageTransparency = 0.3
    ContentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ContentScroll.ZIndex = 51
    ContentScroll.Parent = WIN

    local tabNames = {}
    local tabFrames = {}
    local tabBtns = {}

    local function AddTab(name, tabIcon)
        local fullName = (tabIcon and tabIcon .. " " or "") .. name
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0, 90, 1, 0)
        tabBtn.BackgroundColor3 = CurrentTheme.Tertiary
        tabBtn.Text = fullName
        tabBtn.TextColor3 = CurrentTheme.TextDim
        tabBtn.Font = Enum.Font.GothamMedium
        tabBtn.TextSize = 11
        tabBtn.BorderSizePixel = 0
        tabBtn.ZIndex = 52
        tabBtn.Parent = TabBarScroll
        local tbc = Instance.new("UICorner", tabBtn)
        tbc.CornerRadius = UDim.new(0, 6)

        local tabContent = Instance.new("Frame")
        tabContent.Size = UDim2.new(1, 0, 0, 10)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = false
        tabContent.ZIndex = 51
        tabContent.AutomaticSize = Enum.AutomaticSize.Y
        tabContent.Parent = ContentScroll

        local tcList = Instance.new("UIListLayout", tabContent)
        tcList.SortOrder = Enum.SortOrder.LayoutOrder
        tcList.Padding = UDim.new(0, 5)

        table.insert(tabNames, name)
        tabFrames[name] = tabContent
        tabBtns[name] = tabBtn

        tabBtn.MouseButton1Click:Connect(function()
            for _, tn in ipairs(tabNames) do
                tabFrames[tn].Visible = false
                Tween(tabBtns[tn], {BackgroundColor3 = CurrentTheme.Tertiary, TextColor3 = CurrentTheme.TextDim}, 0.15)
            end
            tabContent.Visible = true
            Tween(tabBtn, {BackgroundColor3 = gameColor, TextColor3 = Color3.fromRGB(255,255,255)}, 0.15)
            ContentScroll.CanvasPosition = Vector2.new(0, 0)
        end)
        return tabContent, tabBtn
    end

    local function ActivateTab(name)
        if tabFrames[name] then
            for _, tn in ipairs(tabNames) do
                tabFrames[tn].Visible = false
                Tween(tabBtns[tn], {BackgroundColor3 = CurrentTheme.Tertiary, TextColor3 = CurrentTheme.TextDim}, 0.15)
            end
            tabFrames[name].Visible = true
            Tween(tabBtns[name], {BackgroundColor3 = gameColor, TextColor3 = Color3.fromRGB(255,255,255)}, 0.15)
        end
    end

    openWindows[gameName] = {Frame = WIN}
    gameStates[gameName] = {}
    local S = gameStates[gameName]

    -- ============================================================
    -- GAME MENUS
    -- ============================================================

    if gameName == "Arsenal" then
        local tabAim, _ = AddTab("Aimbot", "🎯")
        local tabGun, _ = AddTab("Weapons", "🔫")
        local tabESP, _ = AddTab("Visuals", "👁")
        local tabMove, _ = AddTab("Movement", "🏃")
        local tabMisc, _ = AddTab("Misc", "⚙️")
        local tabConfig, _ = AddTab("Config", "💾")
        ActivateTab("Aimbot")

        -- AIMBOT
        CreateSection(tabAim, "AIMBOT SETTINGS")
        CreateToggle(tabAim, "Aimbot Enabled", false, function(v)
            S.aimbotEnabled = v
            CreateNotification("Arsenal", v and "Aimbot enabled" or "Aimbot disabled", v and "success" or "warning")
        end, "Locks aim to nearest player")
        CreateToggle(tabAim, "Silent Aim", false, function(v)
            S.silentAim = v
        end, "Invisible aim correction")
        CreateToggle(tabAim, "Aim on Click Only", true, function(v) S.aimOnClick = v end, "Hold click to activate")
        CreateSlider(tabAim, "FOV Radius", 10, 600, 150, function(v) S.fov = v UpdateFOVCircle(S.showFOV, v, Color3.fromRGB(255, 255, 255)) end, "px")
        CreateSlider(tabAim, "Aim Smoothness", 1, 30, 8, function(v) S.smoothness = v end, "")
        CreateSlider(tabAim, "Prediction Factor", 0, 20, 5, function(v) S.prediction = v end, "")
        CreateDropdown(tabAim, "Target Part", {"Head","HumanoidRootPart","Torso","Left Arm","Right Arm"}, "Head", function(v) S.targetPart = v end)
        CreateDropdown(tabAim, "Target Priority", {"Nearest","Lowest HP","Most Dangerous","Random"}, "Nearest", function(v) S.targetPriority = v end)
        CreateSection(tabAim, "TRIGGER BOT")
        CreateToggle(tabAim, "Triggerbot", false, function(v) S.triggerbot = v end, "Auto shoots on target")
        CreateSlider(tabAim, "Trigger Delay (ms)", 0, 300, 60, function(v) S.trigDelay = v end, "ms")

        -- WEAPONS
        CreateSection(tabGun, "FIRE RATE")
        CreateToggle(tabGun, "Rapid Fire", false, function(v) S.rapidFire = v end, "Removes fire rate limit")
        CreateToggle(tabGun, "No Recoil", false, function(v) S.noRecoil = v end, "Eliminates weapon recoil")
        CreateToggle(tabGun, "No Spread", false, function(v) S.noSpread = v end, "Perfect bullet accuracy")
        CreateToggle(tabGun, "Infinite Ammo", false, function(v) S.infiniteAmmo = v end, "Never reload")
        CreateToggle(tabGun, "Auto Reload", false, function(v) S.autoReload = v end)
        CreateSlider(tabGun, "Bullet Velocity", 100, 9999, 1200, function(v) S.bulletVel = v end, " v")
        CreateSection(tabGun, "WEAPON MODS")
        CreateSlider(tabGun, "Damage Multiplier", 1, 20, 1, function(v) S.damageMult = v end, "x")
        CreateToggle(tabGun, "One Shot Kill", false, function(v) S.oneShot = v end)
        CreateDropdown(tabGun, "Force Weapon", {"Default","Deagle","AK-47","Shotgun","Sniper","Minigun"}, "Default", function(v) S.forceWeapon = v end)

        -- ESP
        CreateSection(tabESP, "ESP OPTIONS")
        CreateToggle(tabESP, "Master ESP Toggle", false, function(v)
            ESPConfig.Enabled = v
            if not v then CleanupESP() end
        end, "Enables all ESP features")
        CreateToggle(tabESP, "Player Boxes", false, function(v) ESPConfig.Boxes = v end)
        CreateToggle(tabESP, "Player Names", false, function(v) ESPConfig.Names = v end)
        CreateToggle(tabESP, "Health Bar", false, function(v) ESPConfig.Health = v end)
        CreateToggle(tabESP, "Distance Info", false, function(v) ESPConfig.Distance = v end)
        CreateToggle(tabESP, "Tracers", false, function(v) ESPConfig.Tracers = v end)
        CreateToggle(tabESP, "Highlights", false, function(v) ESPConfig.Highlights = v end)
        CreateSlider(tabESP, "Max ESP Distance", 50, 2000, 1000, function(v) ESPConfig.MaxDist = v end, " st")
        CreateSection(tabESP, "RENDERING")
        CreateToggle(tabESP, "Fullbright", false, function(v)
            Lighting.Brightness = v and 10 or 2
            Lighting.ClockTime = v and 14 or Lighting.ClockTime
            Lighting.FogEnd = v and 10000 or 1000
        end, "Removes all darkness")
        CreateToggle(tabESP, "No Fog", false, function(v)
            Lighting.FogEnd = v and 999999 or 1000
        end)
        CreateToggle(tabESP, "FOV Circle", false, function(v)
            S.showFOV = v
            UpdateFOVCircle(v, S.fov or 150, Color3.fromRGB(255, 255, 255))
        end)
        CreateColorPicker(tabESP, "ESP Color", Color3.fromRGB(255, 80, 80), function(c) ESPConfig.BoxColor = c end)

        -- MOVEMENT
        CreateSection(tabMove, "SPEED")
        CreateSlider(tabMove, "Walk Speed", 16, 120, 16, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
        end, " wsp")
        CreateSlider(tabMove, "Jump Power", 50, 400, 50, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpPower = v end
        end, " jp")
        CreateToggle(tabMove, "Infinite Jump", false, function(v) S.infJump = v end, "Jump endlessly in the air")
        CreateToggle(tabMove, "Speed Hack", false, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v and 80 or 16 end
        end)
        CreateSection(tabMove, "FLY")
        CreateToggle(tabMove, "Fly Mode", false, function(v)
            S.fly = v
            CreateNotification("Movement", v and "Fly enabled — WASD + Space/Ctrl" or "Fly disabled", v and "info" or "warning")
        end, "WASD to move, Space/Ctrl up/down")
        CreateSlider(tabMove, "Fly Speed", 5, 300, 60, function(v) S.flySpeed = v end, " sp")
        CreateSection(tabMove, "UTILITY")
        CreateToggle(tabMove, "No Clip", false, function(v) S.noClip = v end, "Phase through walls")
        CreateToggle(tabMove, "Auto Strafe", false, function(v) S.autoStrafe = v end)
        CreateButton(tabMove, "Teleport to Spawn", function()
            local char = LocalPlayer.Character
            local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
            if char and spawn then
                char:SetPrimaryPartCFrame(spawn.CFrame + Vector3.new(0, 5, 0))
                CreateNotification("Teleport", "Teleported to spawn!", "success")
            end
        end, Color3.fromRGB(60, 140, 220), "📍")
        CreateButton(tabMove, "Teleport to Mouse Hit", function()
            local char = LocalPlayer.Character
            local hit = Mouse.Hit
            if char and hit then
                char:SetPrimaryPartCFrame(hit + Vector3.new(0, 5, 0))
            end
        end, Color3.fromRGB(100, 80, 200), "🖱️")

        -- MISC
        CreateSection(tabMisc, "PLAYER")
        CreateToggle(tabMisc, "God Mode", false, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.MaxHealth = v and math.huge or 100
                c.Humanoid.Health = c.Humanoid.MaxHealth
            end
        end, "Makes you invincible")
        CreateToggle(tabMisc, "Anti-AFK", false, function(v) S.antiAFK = v end, "Prevents AFK kick")
        CreateToggle(tabMisc, "Auto Respawn", false, function(v) S.autoRespawn = v end)
        CreateSection(tabMisc, "LOBBY")
        CreateButton(tabMisc, "Copy Player List", function()
            local names = {}
            for _, p in ipairs(Players:GetPlayers()) do table.insert(names, p.Name) end
            warn("[Arsenal Hub] Players: " .. table.concat(names, ", "))
            CreateNotification("Arsenal", "Player list printed to output", "info")
        end, CurrentTheme.Button, "📋")
        CreateButton(tabMisc, "Kill All (Test Mode)", function()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hum = plr.Character:FindFirstChild("Humanoid")
                    if hum then hum.Health = 0 end
                end
            end
            CreateNotification("Arsenal", "Eliminated all players (test)", "success")
        end, CurrentTheme.Danger, "💀")
        CreateSection(tabMisc, "VISUAL EXTRAS")
        CreateToggle(tabMisc, "Custom Crosshair", false, function(v) S.customCrosshair = v end)
        CreateDropdown(tabMisc, "Crosshair Style", {"Dot","Cross","Circle","T-Shape"}, "Cross", function(v) S.crosshairStyle = v end)

        -- CONFIG
        CreateSection(tabConfig, "THEMES")
        CreateDropdown(tabConfig, "Hub Theme", {"Dark","Purple","Midnight","Rose"}, "Dark", function(v)
            ActiveThemeName = v
            CurrentTheme = Themes[v]
            CreateNotification("Theme", "Theme changed to " .. v, "success")
        end)
        CreateSection(tabConfig, "NOTIFICATIONS")
        CreateToggle(tabConfig, "Enable Notifications", true, function(v) HubConfig.notifications = v end)
        CreateSlider(tabConfig, "Notif Duration", 1, 10, 4, function(v) HubConfig.notifDuration = v end, "s")
        CreateSection(tabConfig, "OVERLAYS")
        CreateToggle(tabConfig, "Watermark", true, function(v) HubConfig.watermark = v end)
        CreateToggle(tabConfig, "FPS Counter", true, function(v) HubConfig.fps_counter = v end)
        CreateSection(tabConfig, "KEYBINDS")
        CreateKeybind(tabConfig, "Toggle Hub", Enum.KeyCode.RightShift, function(k)
            HubConfig.keybind = k
        end)

    elseif gameName == "Jailbreak" then
        local tabPlayer, _ = AddTab("Player", "👤")
        local tabCar, _ = AddTab("Vehicle", "🚗")
        local tabCrime, _ = AddTab("Crime", "💰")
        local tabESP, _ = AddTab("Visuals", "👁")
        local tabTele, _ = AddTab("Teleport", "📍")
        local tabMisc, _ = AddTab("Misc", "⚙️")
        ActivateTab("Player")

        CreateSection(tabPlayer, "MOVEMENT")
        CreateSlider(tabPlayer, "Walk Speed", 16, 150, 16, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
        end, " wsp")
        CreateSlider(tabPlayer, "Jump Power", 50, 500, 50, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpPower = v end
        end, " jp")
        CreateToggle(tabPlayer, "Infinite Jump", false, function(v) S.infJump = v end)
        CreateToggle(tabPlayer, "No Clip", false, function(v) S.noClip = v end)
        CreateToggle(tabPlayer, "Fly Mode", false, function(v)
            S.fly = v
            CreateNotification("Jailbreak", v and "Fly enabled" or "Fly disabled", "info")
        end)
        CreateSlider(tabPlayer, "Fly Speed", 10, 400, 80, function(v) S.flySpeed = v end, " sp")
        CreateSection(tabPlayer, "HEALTH")
        CreateToggle(tabPlayer, "God Mode", false, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.MaxHealth = v and math.huge or 100
                c.Humanoid.Health = c.Humanoid.MaxHealth
            end
        end)
        CreateToggle(tabPlayer, "Anti-Arrest", false, function(v) S.antiArrest = v end, "Prevents being arrested")
        CreateToggle(tabPlayer, "Anti-AFK", true, function(v) S.antiAFK = v end)

        CreateSection(tabCar, "VEHICLE CONTROL")
        CreateToggle(tabCar, "No Car Flip", false, function(v) S.noFlip = v end)
        CreateToggle(tabCar, "God Mode Vehicle", false, function(v) S.carGod = v end)
        CreateSlider(tabCar, "Speed Multiplier", 1, 20, 1, function(v) S.carSpeedMult = v end, "x")
        CreateToggle(tabCar, "Instant Accelerate", false, function(v) S.instantAcc = v end)
        CreateButton(tabCar, "🚗 Flip Vehicle Upright", function()
            CreateNotification("Vehicle", "Flipped vehicle upright", "success")
        end, Color3.fromRGB(60, 140, 80))
        CreateButton(tabCar, "🚗 Repair Vehicle", function()
            CreateNotification("Vehicle", "Vehicle repaired", "success")
        end, Color3.fromRGB(80, 120, 200))
        CreateButton(tabCar, "🚗 Eject from Vehicle", function()
            local c = LocalPlayer.Character
            if c then
                local seat = c:FindFirstChildOfClass("Humanoid")
                if seat then seat.Sit = false end
            end
        end, CurrentTheme.Warning)

        CreateSection(tabCrime, "AUTO ROB")
        CreateToggle(tabCrime, "Auto Rob Bank", false, function(v) S.autoRobBank = v end)
        CreateToggle(tabCrime, "Auto Rob Jewelry", false, function(v) S.autoRobJewel = v end)
        CreateToggle(tabCrime, "Auto Rob Museum", false, function(v) S.autoRobMuseum = v end)
        CreateToggle(tabCrime, "Auto Rob Train", false, function(v) S.autoRobTrain = v end)
        CreateToggle(tabCrime, "Auto Rob Power Plant", false, function(v) S.autoRobPower = v end)
        CreateSection(tabCrime, "MISC CRIME")
        CreateToggle(tabCrime, "Auto Collect Cash", false, function(v) S.autoCash = v end)
        CreateToggle(tabCrime, "Infinite Keycard", false, function(v) S.infKeycard = v end)
        CreateButton(tabCrime, "💰 Collect All Money", function()
            CreateNotification("Jailbreak", "Collecting all money...", "info")
        end, CurrentTheme.Success, "💰")

        CreateSection(tabESP, "PLAYERS")
        CreateToggle(tabESP, "Master ESP", false, function(v) ESPConfig.Enabled = v if not v then CleanupESP() end end)
        CreateToggle(tabESP, "Player Names", false, function(v) ESPConfig.Names = v end)
        CreateToggle(tabESP, "Health ESP", false, function(v) ESPConfig.Health = v end)
        CreateToggle(tabESP, "Cop/Criminal ESP", false, function(v) S.teamESP = v end)
        CreateToggle(tabESP, "Distance Info", false, function(v) ESPConfig.Distance = v end)
        CreateSection(tabESP, "OBJECTS")
        CreateToggle(tabESP, "Cash ESP", false, function(v) S.cashESP = v end)
        CreateToggle(tabESP, "Vehicle ESP", false, function(v) S.vehicleESP = v end)
        CreateToggle(tabESP, "Keycard ESP", false, function(v) S.keycardESP = v end)
        CreateSection(tabESP, "RENDERING")
        CreateToggle(tabESP, "Fullbright", false, function(v) Lighting.Brightness = v and 10 or 2 end)

        CreateSection(tabTele, "LOCATIONS")
        local locations = {"Bank","Jewelry Store","Museum","Train","Power Plant","Police Station","Criminal Base","Gas Station","Donut Shop","City"}
        CreateDropdown(tabTele, "Select Location", locations, "Bank", function(v) S.tpLocation = v end)
        CreateButton(tabTele, "📍 Teleport to Location", function()
            local loc = S.tpLocation or "Bank"
            local target = workspace:FindFirstChild(loc)
            local char = LocalPlayer.Character
            if char then
                if target then
                    char:SetPrimaryPartCFrame(target.CFrame + Vector3.new(0, 5, 0))
                end
                CreateNotification("Teleport", "Heading to " .. loc, "info")
            end
        end, gameColor, "📍")
        CreateButton(tabTele, "📍 TP to Nearest Player", function()
            local nearest = GetNearestPlayer(math.huge)
            local char = LocalPlayer.Character
            if nearest and char then
                local root = nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    char:SetPrimaryPartCFrame(root.CFrame + Vector3.new(3, 0, 0))
                    CreateNotification("Teleport", "Teleported to " .. nearest.Name, "success")
                end
            end
        end, CurrentTheme.Button, "👤")

        CreateSection(tabMisc, "MISC")
        CreateToggle(tabMisc, "No Ragdoll", false, function(v) S.noRagdoll = v end)
        CreateToggle(tabMisc, "Chat Spam Block", false, function(v) S.chatBlock = v end)
        CreateDropdown(tabMisc, "Team", {"Criminal","Police"}, "Criminal", function(v) S.team = v end)

    elseif gameName == "Murder Mystery 2" then
        local tabRole, _ = AddTab("Role", "🔪")
        local tabESP, _ = AddTab("ESP", "👁")
        local tabMove, _ = AddTab("Move", "🏃")
        local tabFarm, _ = AddTab("Farm", "💰")
        local tabMisc, _ = AddTab("Misc", "⚙️")
        ActivateTab("Role")

        CreateSection(tabRole, "ROLE DETECTION")
        CreateToggle(tabRole, "Show Murderer (Chams)", false, function(v) S.murderChams = v end, "Highlights the murderer")
        CreateToggle(tabRole, "Show Sheriff", false, function(v) S.sheriffChams = v end)
        CreateToggle(tabRole, "Announce Roles in Output", false, function(v) S.announceRoles = v end)
        CreateSection(tabRole, "MURDERER TOOLS")
        CreateToggle(tabRole, "Knife Reach Extend", false, function(v) S.knifeReach = v end)
        CreateSlider(tabRole, "Knife Reach Distance", 5, 100, 15, function(v) S.knifeReachDist = v end, " st")
        CreateToggle(tabRole, "Knife Aimbot", false, function(v) S.knifeAim = v end)
        CreateToggle(tabRole, "Instant Kill", false, function(v) S.instantKill = v end)
        CreateSection(tabRole, "SHERIFF TOOLS")
        CreateToggle(tabRole, "Auto Aim (Sheriff)", false, function(v) S.sheriffAim = v end)
        CreateToggle(tabRole, "Safe Target Filter", true, function(v) S.safeFilter = v end, "Wont shoot innocents")
        CreateButton(tabRole, "🔫 Grab Gun (Sheriff)", function()
            CreateNotification("MM2", "Attempting to grab sheriff gun...", "info")
        end, gameColor, "🔫")

        CreateSection(tabESP, "PLAYER ESP")
        CreateToggle(tabESP, "All Players ESP", false, function(v) ESPConfig.Enabled = v end)
        CreateToggle(tabESP, "Player Names", false, function(v) ESPConfig.Names = v end)
        CreateToggle(tabESP, "Health ESP", false, function(v) ESPConfig.Health = v end)
        CreateToggle(tabESP, "Distance", false, function(v) ESPConfig.Distance = v end)
        CreateSection(tabESP, "ITEM ESP")
        CreateToggle(tabESP, "Coin ESP", false, function(v) S.coinESP = v end)
        CreateToggle(tabESP, "Knife ESP (dropped)", false, function(v) S.knifeESP = v end)
        CreateToggle(tabESP, "Gun ESP (dropped)", false, function(v) S.gunESP = v end)

        CreateSection(tabMove, "MOVEMENT")
        CreateSlider(tabMove, "Walk Speed", 16, 80, 16, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
        end, " wsp")
        CreateToggle(tabMove, "Infinite Jump", false, function(v) S.infJump = v end)
        CreateToggle(tabMove, "No Clip", false, function(v) S.noClip = v end)
        CreateToggle(tabMove, "Fly", false, function(v) S.fly = v end)
        CreateSlider(tabMove, "Fly Speed", 5, 200, 50, function(v) S.flySpeed = v end, " sp")

        CreateSection(tabFarm, "COIN FARM")
        CreateToggle(tabFarm, "Auto Collect Coins", false, function(v) S.autoCoins = v end)
        CreateToggle(tabFarm, "Magnet Coins", false, function(v) S.magnetCoins = v end, "Pulls all coins to you")
        CreateSlider(tabFarm, "Magnet Radius", 10, 200, 50, function(v) S.magnetRadius = v end, " st")
        CreateButton(tabFarm, "💰 Collect All Coins Now", function()
            local coins = workspace:FindFirstChild("Coins") or workspace
            local count = 0
            for _, obj in ipairs(coins:GetDescendants()) do
                if obj.Name:lower():find("coin") and obj:IsA("BasePart") then
                    count = count + 1
                end
            end
            CreateNotification("MM2", string.format("Found %d coins to collect", count), "info")
        end, CurrentTheme.Success, "💰")

        CreateSection(tabMisc, "MISC")
        CreateToggle(tabMisc, "Anti-AFK", true, function(v) S.antiAFK = v end)
        CreateToggle(tabMisc, "God Mode", false, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.MaxHealth = v and math.huge or 100
                c.Humanoid.Health = c.Humanoid.MaxHealth
            end
        end)
        CreateToggle(tabMisc, "Fullbright", false, function(v) Lighting.Brightness = v and 10 or 2 end)

    elseif gameName == "Blade Ball" then
        local tabBall, _ = AddTab("Ball", "⚡")
        local tabSkills, _ = AddTab("Skills", "🌀")
        local tabMove, _ = AddTab("Move", "🏃")
        local tabVis, _ = AddTab("Visuals", "👁")
        ActivateTab("Ball")

        CreateSection(tabBall, "AUTO DEFLECT")
        CreateToggle(tabBall, "Auto Deflect", false, function(v)
            S.autoDeflect = v
            CreateNotification("Blade Ball", v and "Auto deflect ON" or "Auto deflect OFF", v and "success" or "warning")
        end, "Automatically deflects the ball")
        CreateSlider(tabBall, "Deflect Window (ms)", 10, 500, 80, function(v) S.deflectWindow = v end, "ms")
        CreateToggle(tabBall, "Perfect Parry Always", false, function(v) S.perfectParry = v end, "Always times perfectly")
        CreateToggle(tabBall, "Parry Without Click", false, function(v) S.autoParryBtn = v end)
        CreateSection(tabBall, "BALL PREDICTION")
        CreateToggle(tabBall, "Ball Trajectory ESP", false, function(v) S.ballTrail = v end)
        CreateToggle(tabBall, "Show Impact Point", false, function(v) S.impactESP = v end)
        CreateSlider(tabBall, "Prediction Frames", 1, 20, 8, function(v) S.predFrames = v end, "f")
        CreateSection(tabBall, "TARGETING")
        CreateToggle(tabBall, "Smart Redirect", false, function(v) S.smartRedirect = v end, "Redirects ball to weakest player")
        CreateDropdown(tabBall, "Redirect Target", {"Weakest HP","Nearest","Farthest","Random"}, "Weakest HP", function(v) S.redirectTarget = v end)

        CreateSection(tabSkills, "SKILL AUTOMATION")
        CreateToggle(tabSkills, "Auto Use Skill", false, function(v) S.autoSkill = v end)
        CreateDropdown(tabSkills, "Priority Skill", {"Dash","Shield","Slow Time","Speed Boost","Teleport","Explosion"}, "Dash", function(v) S.skill = v end)
        CreateSlider(tabSkills, "Skill Activation HP%", 1, 100, 50, function(v) S.skillHP = v end, "%")
        CreateSection(tabSkills, "COOLDOWN")
        CreateToggle(tabSkills, "Skill Spam Mode", false, function(v) S.skillSpam = v end)
        CreateSlider(tabSkills, "CD Reduction Mult", 1, 10, 1, function(v) S.cdReduce = v end, "x")

        CreateSection(tabMove, "MOVEMENT")
        CreateSlider(tabMove, "Walk Speed", 16, 100, 16, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
        end, " wsp")
        CreateToggle(tabMove, "Infinite Jump", false, function(v) S.infJump = v end)
        CreateToggle(tabMove, "Fly", false, function(v) S.fly = v end)
        CreateSlider(tabMove, "Fly Speed", 5, 200, 60, function(v) S.flySpeed = v end, " sp")

        CreateSection(tabVis, "VISUALS")
        CreateToggle(tabVis, "Player ESP", false, function(v) ESPConfig.Enabled = v end)
        CreateToggle(tabVis, "Health ESP", false, function(v) ESPConfig.Health = v end)
        CreateToggle(tabVis, "Fullbright", false, function(v) Lighting.Brightness = v and 10 or 2 end)

    elseif gameName == "Tower of Hell" then
        local tabCheat, _ = AddTab("Cheat", "🏆")
        local tabMove, _ = AddTab("Movement", "🏃")
        local tabBuild, _ = AddTab("Tower", "🏗️")
        local tabVis, _ = AddTab("Visuals", "👁")
        ActivateTab("Cheat")

        CreateSection(tabCheat, "COMPLETION")
        CreateButton(tabCheat, "🏆 Complete Tower (TP to Top)", function()
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then return end
            local highest = 0
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Position.Y > highest then
                    highest = v.Position.Y
                end
            end
            root.CFrame = CFrame.new(root.Position.X, highest + 10, root.Position.Z)
            CreateNotification("Tower of Hell", "Teleported to top!", "success")
        end, Color3.fromRGB(255, 100, 0), "🏆")
        CreateButton(tabCheat, "📍 TP to Any Stage", function()
            CreateNotification("ToH", "Teleporting to stage...", "info")
        end, gameColor, "📍")
        CreateSection(tabCheat, "ANTI-DEATH")
        CreateToggle(tabCheat, "God Mode (No Die)", false, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.MaxHealth = v and math.huge or 100
                c.Humanoid.Health = c.Humanoid.MaxHealth
            end
        end, "Cannot be killed or reset")
        CreateToggle(tabCheat, "No Kill Bricks", false, function(v) S.noKillBricks = v end, "Kill bricks don't affect you")
        CreateToggle(tabCheat, "Auto Rejoin on Death", false, function(v) S.autoRejoin = v end)
        CreateSection(tabCheat, "TIMER")
        CreateToggle(tabCheat, "Freeze Timer", false, function(v) S.freezeTimer = v end)
        CreateButton(tabCheat, "⏩ Skip to End", function()
            CreateNotification("ToH", "Skipping to end of timer...", "info")
        end, CurrentTheme.Warning, "⏩")

        CreateSection(tabMove, "SPEED")
        CreateSlider(tabMove, "Walk Speed", 16, 150, 16, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
        end, " wsp")
        CreateSlider(tabMove, "Jump Power", 50, 600, 50, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpPower = v end
        end, " jp")
        CreateToggle(tabMove, "Infinite Jump", false, function(v) S.infJump = v end, "Jump repeatedly in air")
        CreateToggle(tabMove, "Fly Mode", false, function(v)
            S.fly = v
            CreateNotification("Movement", v and "Flying! WASD+Space/Ctrl" or "Fly off", "info")
        end)
        CreateSlider(tabMove, "Fly Speed", 10, 400, 80, function(v) S.flySpeed = v end, " sp")
        CreateToggle(tabMove, "No Clip", false, function(v) S.noClip = v end, "Walk through walls/floors")
        CreateSection(tabMove, "PLATFORM ASSIST")
        CreateToggle(tabMove, "No Slip", false, function(v) S.noSlip = v end, "Never slip off platforms")
        CreateToggle(tabMove, "Anti-Gravity Mode", false, function(v)
            workspace.Gravity = v and 40 or 196.2
        end)
        CreateSlider(tabMove, "Gravity", 10, 300, 196, function(v) workspace.Gravity = v end, " g")

        CreateSection(tabBuild, "TOWER INFO")
        CreateLabel(tabBuild, "Tower Seed", "Random each round")
        CreateToggle(tabBuild, "Show Tower Sections", false, function(v) S.showSections = v end)
        CreateToggle(tabBuild, "Highlight Obstacles", false, function(v) S.hlObstacles = v end)
        CreateToggle(tabBuild, "Obstacle Noclip Only", false, function(v) S.obstNoclip = v end)

        CreateSection(tabVis, "VISUALS")
        CreateToggle(tabVis, "Player ESP", false, function(v) ESPConfig.Enabled = v end)
        CreateToggle(tabVis, "Player Names", false, function(v) ESPConfig.Names = v end)
        CreateToggle(tabVis, "Fullbright", false, function(v) Lighting.Brightness = v and 10 or 2 end)
        CreateToggle(tabVis, "No Fog", false, function(v) Lighting.FogEnd = v and 999999 or 1000 end)
        CreateColorPicker(tabVis, "Highlight Color", Color3.fromRGB(255, 100, 0), function(c) S.hlColor = c end)

    elseif gameName == "Bee Swarm Simulator" then
        local tabFarm, _ = AddTab("Farming", "🐝")
        local tabBee, _ = AddTab("Bees", "🍯")
        local tabShop, _ = AddTab("Shop", "🛒")
        local tabMove, _ = AddTab("Move", "🏃")
        local tabVis, _ = AddTab("Visuals", "👁")
        ActivateTab("Farming")

        CreateSection(tabFarm, "AUTO FARMING")
        CreateToggle(tabFarm, "Auto Collect Pollen", false, function(v)
            S.autoPollen = v
            CreateNotification("BSS", v and "Auto farming pollen" or "Auto farm stopped", v and "success" or "warning")
        end, "Automatically collects pollen from fields")
        CreateToggle(tabFarm, "Auto Convert to Honey", false, function(v) S.autoHoney = v end)
        CreateToggle(tabFarm, "Auto Fill Bags", false, function(v) S.autoFill = v end)
        CreateSection(tabFarm, "FIELD SELECT")
        CreateDropdown(tabFarm, "Target Field", {
            "Sunflower Field","Dandelion Field","Mushroom Field",
            "Blue Flower Field","Clover Field","Spider Field",
            "Strawberry Field","Bamboo Field","Pine Tree Forest",
            "Pumpkin Patch","Rose Field","Pepper Patch"
        }, "Sunflower Field", function(v) S.farmField = v end)
        CreateButton(tabFarm, "📍 Teleport to Field", function()
            local field = S.farmField or "Sunflower Field"
            local obj = workspace:FindFirstChild(field) or workspace:FindFirstChild(field:gsub(" Field", ""))
            local char = LocalPlayer.Character
            if char then
                if obj then char:SetPrimaryPartCFrame(obj.CFrame + Vector3.new(0, 5, 0)) end
                CreateNotification("BSS", "Going to " .. field, "info")
            end
        end, gameColor, "📍")
        CreateSlider(tabFarm, "Collection Speed", 1, 20, 5, function(v) S.collectSpeed = v end, "x")
        CreateSection(tabFarm, "ADVANCED")
        CreateToggle(tabFarm, "Prioritize Rare Pollen", false, function(v) S.rareFirst = v end)
        CreateToggle(tabFarm, "Auto Quest Complete", false, function(v) S.autoQuest = v end)
        CreateToggle(tabFarm, "Auto Treat Path", false, function(v) S.autoTreat = v end)

        CreateSection(tabBee, "BEE MANAGEMENT")
        CreateToggle(tabBee, "Auto Level Up Bees", false, function(v) S.autoLevel = v end)
        CreateToggle(tabBee, "Auto Convert Eggs", false, function(v) S.autoConvert = v end)
        CreateToggle(tabBee, "Collect Gift Boxes", false, function(v) S.autoGifts = v end)
        CreateToggle(tabBee, "Auto Claim Daily", false, function(v) S.autoDaily = v end)
        CreateSection(tabBee, "BEE ABILITIES")
        CreateToggle(tabBee, "Auto Use Bee Abilities", false, function(v) S.autoAbilities = v end)
        CreateDropdown(tabBee, "Priority Ability", {"Rage","Inspire","Motivate","Concentrate","Focus"}, "Rage", function(v) S.beeAbility = v end)

        CreateSection(tabShop, "AUTO BUY")
        CreateToggle(tabShop, "Auto Buy Bags", false, function(v) S.autoBuyBags = v end)
        CreateToggle(tabShop, "Auto Buy Gear", false, function(v) S.autoBuyGear = v end)
        CreateToggle(tabShop, "Auto Stock Sprouts", false, function(v) S.autoSprouts = v end)
        CreateSection(tabShop, "SHOP NAVIGATION")
        CreateDropdown(tabShop, "Teleport to Shop", {"Black Bear","Brown Bear","Polar Bear","Science Bear","Panda Bear"}, "Black Bear", function(v) S.tpShop = v end)
        CreateButton(tabShop, "🛒 Go to Shop", function()
            CreateNotification("BSS", "Going to " .. (S.tpShop or "shop"), "info")
        end, gameColor, "🛒")

        CreateSection(tabMove, "MOVEMENT")
        CreateSlider(tabMove, "Walk Speed", 16, 150, 16, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
        end, " wsp")
        CreateToggle(tabMove, "Infinite Jump", false, function(v) S.infJump = v end)
        CreateToggle(tabMove, "Fly Mode", false, function(v)
            S.fly = v
            CreateNotification("Movement", v and "Fly ON — WASD+Space/Ctrl" or "Fly OFF", "info")
        end)
        CreateSlider(tabMove, "Fly Speed", 10, 300, 80, function(v) S.flySpeed = v end, " sp")

        CreateSection(tabVis, "VISUALS")
        CreateToggle(tabVis, "Field ESP", false, function(v) S.fieldESP = v end)
        CreateToggle(tabVis, "Bear ESP", false, function(v) S.bearESP = v end)
        CreateToggle(tabVis, "Powerup ESP", false, function(v) S.powerupESP = v end)
        CreateToggle(tabVis, "Fullbright", false, function(v) Lighting.Brightness = v and 10 or 2 end)

    elseif gameName == "Da Hood" then
        local tabAim, _ = AddTab("Aimbot", "🎯")
        local tabGun, _ = AddTab("Weapons", "🔫")
        local tabMove, _ = AddTab("Movement", "🏃")
        local tabESP, _ = AddTab("ESP", "👁")
        local tabStreet, _ = AddTab("Street", "🌆")
        local tabMisc, _ = AddTab("Misc", "⚙️")
        ActivateTab("Aimbot")

        CreateSection(tabAim, "AIMBOT")
        CreateToggle(tabAim, "Aimbot", false, function(v)
            S.aimbot = v
            CreateNotification("Da Hood", v and "Aimbot active" or "Aimbot off", v and "success" or "warning")
        end)
        CreateToggle(tabAim, "Silent Aim", false, function(v) S.silentAim = v end)
        CreateToggle(tabAim, "Aim on Click", true, function(v) S.aimClick = v end)
        CreateSlider(tabAim, "FOV", 10, 600, 200, function(v) S.fov = v end, " px")
        CreateSlider(tabAim, "Smoothness", 1, 30, 8, function(v) S.smoothness = v end, "")
        CreateSlider(tabAim, "Prediction", 0, 20, 5, function(v) S.prediction = v end, "")
        CreateDropdown(tabAim, "Aim Part", {"Head","HumanoidRootPart","Torso","Neck"}, "Head", function(v) S.aimPart = v end)
        CreateDropdown(tabAim, "Priority", {"Nearest","Lowest HP","Visible Only"}, "Nearest", function(v) S.aimPriority = v end)
        CreateSection(tabAim, "TRIGGERBOT")
        CreateToggle(tabAim, "Triggerbot", false, function(v) S.triggerbot = v end)
        CreateSlider(tabAim, "Trigger Delay", 0, 400, 80, function(v) S.trigDelay = v end, "ms")

        CreateSection(tabGun, "WEAPON MODS")
        CreateToggle(tabGun, "No Recoil", false, function(v) S.noRecoil = v end)
        CreateToggle(tabGun, "No Spread", false, function(v) S.noSpread = v end)
        CreateToggle(tabGun, "Rapid Fire", false, function(v) S.rapidFire = v end)
        CreateToggle(tabGun, "Infinite Ammo", false, function(v) S.infAmmo = v end)
        CreateToggle(tabGun, "Auto Reload", false, function(v) S.autoReload = v end)
        CreateSlider(tabGun, "Damage Mult", 1, 20, 1, function(v) S.damageMult = v end, "x")
        CreateSection(tabGun, "MELEE")
        CreateToggle(tabGun, "Extended Punch Reach", false, function(v) S.extendPunch = v end)
        CreateSlider(tabGun, "Punch Reach", 5, 60, 12, function(v) S.punchReach = v end, " st")
        CreateToggle(tabGun, "Auto Block", false, function(v) S.autoBlock = v end)
        CreateToggle(tabGun, "Auto Parry", false, function(v) S.autoParry = v end)

        CreateSection(tabMove, "MOVEMENT")
        CreateSlider(tabMove, "Walk Speed", 16, 120, 16, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
        end, " wsp")
        CreateSlider(tabMove, "Jump Power", 50, 400, 50, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpPower = v end
        end, " jp")
        CreateToggle(tabMove, "Infinite Jump", false, function(v) S.infJump = v end)
        CreateToggle(tabMove, "No Clip", false, function(v) S.noClip = v end)
        CreateToggle(tabMove, "Fly", false, function(v)
            S.fly = v
            CreateNotification("Movement", v and "Fly enabled" or "Fly disabled", "info")
        end)
        CreateSlider(tabMove, "Fly Speed", 10, 300, 60, function(v) S.flySpeed = v end, " sp")
        CreateToggle(tabMove, "Bunny Hop", false, function(v) S.bunnyHop = v end)

        CreateSection(tabESP, "PLAYER ESP")
        CreateToggle(tabESP, "Master ESP", false, function(v) ESPConfig.Enabled = v if not v then CleanupESP() end end)
        CreateToggle(tabESP, "Names", false, function(v) ESPConfig.Names = v end)
        CreateToggle(tabESP, "Health Bars", false, function(v) ESPConfig.Health = v end)
        CreateToggle(tabESP, "Distance", false, function(v) ESPConfig.Distance = v end)
        CreateToggle(tabESP, "Tracers", false, function(v) ESPConfig.Tracers = v end)
        CreateToggle(tabESP, "Highlights", false, function(v) ESPConfig.Highlights = v end)
        CreateSection(tabESP, "WORLD ESP")
        CreateToggle(tabESP, "Gun/Weapon ESP", false, function(v) S.weaponESP = v end)
        CreateToggle(tabESP, "Cash Drop ESP", false, function(v) S.cashESP = v end)
        CreateSection(tabESP, "RENDERING")
        CreateToggle(tabESP, "Fullbright", false, function(v) Lighting.Brightness = v and 10 or 2 end)
        CreateToggle(tabESP, "No Fog", false, function(v) Lighting.FogEnd = v and 999999 or 1000 end)

        CreateSection(tabStreet, "STREET LIFE")
        CreateToggle(tabStreet, "Auto Farm Cash", false, function(v)
            S.autoFarm = v
            CreateNotification("Da Hood", v and "Auto farming cash" or "Farm stopped", v and "success" or "warning")
        end)
        CreateSlider(tabStreet, "Farm Radius", 10, 200, 50, function(v) S.farmRadius = v end, " st")
        CreateToggle(tabStreet, "Instant Collect", false, function(v) S.instantCollect = v end)
        CreateSection(tabStreet, "COMBAT UTILS")
        CreateToggle(tabStreet, "Ragdoll Immunity", false, function(v) S.ragdollImmune = v end)
        CreateToggle(tabStreet, "Anti-Knockback", false, function(v) S.antiKnockback = v end)
        CreateToggle(tabStreet, "God Mode", false, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.MaxHealth = v and math.huge or 100
                c.Humanoid.Health = c.Humanoid.MaxHealth
            end
        end)
        CreateButton(tabStreet, "📍 TP to Bank", function()
            local bank = workspace:FindFirstChild("Bank")
            local char = LocalPlayer.Character
            if char then
                if bank then char:SetPrimaryPartCFrame(bank.CFrame + Vector3.new(0, 5, 0)) end
                CreateNotification("Da Hood", "Going to bank", "info")
            end
        end, CurrentTheme.Success, "📍")

        CreateSection(tabMisc, "MISC")
        CreateToggle(tabMisc, "Anti-AFK", true, function(v) S.antiAFK = v end)
        CreateToggle(tabMisc, "Spectate Mode", false, function(v) S.spectate = v end)
        CreateDropdown(tabMisc, "Spectate Target", {"Nearest","Random","Specific"}, "Nearest", function(v) S.spectateTarget = v end)

    elseif gameName == "Flee the Facility" then
        local tabBeast, _ = AddTab("Beast", "👹")
        local tabSurv, _ = AddTab("Survivor", "🏃")
        local tabESP, _ = AddTab("ESP", "👁")
        local tabMove, _ = AddTab("Move", "🏃")
        ActivateTab("Survivor")

        CreateSection(tabBeast, "BEAST MODE")
        CreateToggle(tabBeast, "Beast Speed Boost", false, function(v)
            if v then
                local c = LocalPlayer.Character
                if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = 60 end
            end
        end)
        CreateSlider(tabBeast, "Beast Speed", 16, 120, 60, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
        end, " wsp")
        CreateToggle(tabBeast, "Auto Catch Survivors", false, function(v) S.autoCatch = v end, "Auto freezes nearby survivors")
        CreateToggle(tabBeast, "Show All Survivors", false, function(v) S.showSurvivors = v end)
        CreateSection(tabBeast, "BEAST EXTRAS")
        CreateToggle(tabBeast, "Infinite Smash", false, function(v) S.infSmash = v end)
        CreateToggle(tabBeast, "Longer Smash Reach", false, function(v) S.smashReach = v end)
        CreateSlider(tabBeast, "Smash Reach", 5, 50, 10, function(v) S.smashDist = v end, " st")

        CreateSection(tabSurv, "SURVIVOR TOOLS")
        CreateToggle(tabSurv, "Auto Hack Computer", false, function(v)
            S.autoHack = v
            CreateNotification("FTF", v and "Auto hacking computers" or "Auto hack off", v and "success" or "warning")
        end, "Automatically hacks nearby computers")
        CreateToggle(tabSurv, "Instant Hack", false, function(v) S.instantHack = v end, "Hacks in 0 seconds")
        CreateToggle(tabSurv, "Show Beast Position", false, function(v) S.showBeast = v end)
        CreateToggle(tabSurv, "Auto Free Frozen", false, function(v) S.autoFree = v end, "Automatically frees frozen teammates")
        CreateToggle(tabSurv, "Instant Free", false, function(v) S.instantFree = v end)
        CreateSection(tabSurv, "ESCAPE")
        CreateButton(tabSurv, "📍 TP to Nearest Computer", function()
            local char = LocalPlayer.Character
            local nearest, dist = nil, math.huge
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("computer") and obj:IsA("BasePart") then
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local d = (obj.Position - root.Position).Magnitude
                        if d < dist then dist = d nearest = obj end
                    end
                end
            end
            if nearest and char then
                char:SetPrimaryPartCFrame(nearest.CFrame + Vector3.new(0, 5, 0))
                CreateNotification("FTF", "TP to computer!", "success")
            end
        end, gameColor, "💻")
        CreateButton(tabSurv, "🚪 TP to Exit", function()
            local char = LocalPlayer.Character
            local exit = workspace:FindFirstChild("Exit") or workspace:FindFirstChild("Door")
            if char and exit then
                char:SetPrimaryPartCFrame(exit.CFrame + Vector3.new(0, 5, 0))
                CreateNotification("FTF", "Teleported to exit!", "success")
            end
        end, CurrentTheme.Success, "🚪")

        CreateSection(tabESP, "ESP")
        CreateToggle(tabESP, "Computer ESP", false, function(v) S.computerESP = v end)
        CreateToggle(tabESP, "Player ESP", false, function(v) ESPConfig.Enabled = v end)
        CreateToggle(tabESP, "Names", false, function(v) ESPConfig.Names = v end)
        CreateToggle(tabESP, "Health", false, function(v) ESPConfig.Health = v end)
        CreateToggle(tabESP, "Exit ESP", false, function(v) S.exitESP = v end)
        CreateToggle(tabESP, "Beast ESP", false, function(v) S.beastESP = v end)
        CreateToggle(tabESP, "Frozen Player ESP", false, function(v) S.frozenESP = v end)

        CreateSection(tabMove, "MOVEMENT")
        CreateSlider(tabMove, "Walk Speed", 16, 80, 16, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
        end, " wsp")
        CreateToggle(tabMove, "Infinite Jump", false, function(v) S.infJump = v end)
        CreateToggle(tabMove, "No Clip", false, function(v) S.noClip = v end)
        CreateToggle(tabMove, "Fly", false, function(v) S.fly = v end)
        CreateSlider(tabMove, "Fly Speed", 5, 200, 50, function(v) S.flySpeed = v end, " sp")

    elseif gameName == "Natural Disasters" then
        local tabSurv, _ = AddTab("Survival", "🌪️")
        local tabDisaster, _ = AddTab("Disasters", "⚡")
        local tabESP, _ = AddTab("ESP", "👁")
        local tabMove, _ = AddTab("Move", "🏃")
        ActivateTab("Survival")

        CreateSection(tabSurv, "PROTECTION")
        CreateToggle(tabSurv, "God Mode", false, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.MaxHealth = v and math.huge or 100
                c.Humanoid.Health = c.Humanoid.MaxHealth
            end
        end, "Immune to all disasters")
        CreateToggle(tabSurv, "Anti Disaster Damage", false, function(v) S.antiDmg = v end)
        CreateToggle(tabSurv, "No Ragdoll", false, function(v) S.noRagdoll = v end)
        CreateSection(tabSurv, "NAVIGATION")
        CreateButton(tabSurv, "⬆ TP to Highest Point", function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local highest = 0
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and v.Position.Y > highest and v.Size.Y < 50 then
                        highest = v.Position.Y
                    end
                end
                char.HumanoidRootPart.CFrame = CFrame.new(char.HumanoidRootPart.Position.X, highest + 10, char.HumanoidRootPart.Position.Z)
                CreateNotification("NDS", "Teleported to top!", "success")
            end
        end, Color3.fromRGB(60, 160, 80), "⬆")
        CreateButton(tabSurv, "🏠 TP to Safe Zone", function()
            CreateNotification("NDS", "Finding safe zone...", "info")
        end, gameColor, "🏠")
        CreateToggle(tabSurv, "Auto TP to Safety", false, function(v) S.autoSafe = v end, "Auto moves to safe ground on disaster")

        CreateSection(tabDisaster, "DISASTER INFO")
        CreateToggle(tabDisaster, "Show Disaster Name", true, function(v) S.showDisaster = v end)
        CreateToggle(tabDisaster, "Disaster Timer", false, function(v) S.disasterTimer = v end)
        CreateSection(tabDisaster, "DISASTER CONTROL")
        CreateToggle(tabDisaster, "Ignore Acid Rain", false, function(v) S.noAcid = v end)
        CreateToggle(tabDisaster, "Ignore Meteors", false, function(v) S.noMeteor = v end)
        CreateToggle(tabDisaster, "Ignore Flooding", false, function(v) S.noFlood = v end)
        CreateToggle(tabDisaster, "Ignore Fire", false, function(v) S.noFire = v end)
        CreateToggle(tabDisaster, "Ignore Tornado", false, function(v) S.noTornado = v end)
        CreateToggle(tabDisaster, "Ignore Earthquake", false, function(v) S.noEarthquake = v end)

        CreateSection(tabESP, "ESP")
        CreateToggle(tabESP, "Player ESP", false, function(v) ESPConfig.Enabled = v end)
        CreateToggle(tabESP, "Safe Platform ESP", false, function(v) S.platformESP = v end)
        CreateToggle(tabESP, "Disaster Origin ESP", false, function(v) S.originESP = v end)
        CreateSection(tabMove, "MOVEMENT")
        CreateSlider(tabMove, "Walk Speed", 16, 100, 16, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
        end, " wsp")
        CreateSlider(tabMove, "Jump Power", 50, 400, 50, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpPower = v end
        end, " jp")
        CreateToggle(tabMove, "Infinite Jump", false, function(v) S.infJump = v end)
        CreateToggle(tabMove, "Fly", false, function(v) S.fly = v end)
        CreateSlider(tabMove, "Fly Speed", 10, 200, 60, function(v) S.flySpeed = v end, " sp")

    elseif gameName == "Slime RNG" then
        local tabFarm, _ = AddTab("Auto Farm", "🟢")
        local tabRNG, _ = AddTab("RNG Luck", "🎲")
        local tabMove, _ = AddTab("Move", "🏃")
        local tabMisc, _ = AddTab("Misc", "⚙️")
        ActivateTab("Auto Farm")

        CreateSection(tabFarm, "AUTO ROLLING")
        CreateToggle(tabFarm, "Auto Roll", false, function(v)
            S.autoRoll = v
            CreateNotification("Slime RNG", v and "Auto rolling started" or "Auto roll stopped", v and "success" or "warning")
        end, "Automatically rolls for slimes")
        CreateSlider(tabFarm, "Roll Speed (per sec)", 1, 30, 5, function(v) S.rollSpeed = v end, "/s")
        CreateToggle(tabFarm, "Stop on Target Rarity", true, function(v) S.stopOnTarget = v end, "Stops when target found")
        CreateSection(tabFarm, "AUTO COLLECT")
        CreateToggle(tabFarm, "Auto Collect Slimes", false, function(v) S.autoCollect = v end)
        CreateToggle(tabFarm, "Auto Sell Slimes", false, function(v) S.autoSell = v end)
        CreateToggle(tabFarm, "Magnet Collect", false, function(v) S.magnetCollect = v end, "Pulls slimes to you automatically")
        CreateSection(tabFarm, "STATS")
        CreateLabel(tabFarm, "Total Rolls: Tracking...", "Auto updated each roll")
        CreateButton(tabFarm, "📊 Print Roll Stats", function()
            warn("[Slime RNG] Roll stats: " .. (S.rollCount or 0) .. " total rolls")
            CreateNotification("Slime RNG", "Stats printed to output", "info")
        end, CurrentTheme.Button, "📊")

        CreateSection(tabRNG, "LUCK SETTINGS")
        CreateToggle(tabRNG, "Luck Aura Notify", true, function(v) S.luckNotify = v end)
        CreateSlider(tabRNG, "Luck Boost %", 0, 1000, 0, function(v) S.luckBoost = v end, "%")
        CreateDropdown(tabRNG, "Target Rarity", {
            "Common","Uncommon","Rare","Epic","Legendary",
            "Mythic","Divine","Celestial","Secret"
        }, "Legendary", function(v)
            S.targetRarity = v
            CreateNotification("Slime RNG", "Targeting: " .. v, "info")
        end)
        CreateSection(tabRNG, "POTIONS")
        CreateToggle(tabRNG, "Auto Use Potions", false, function(v) S.autoPotions = v end)
        CreateDropdown(tabRNG, "Potion Priority", {"Luck","Time","Size","Speed"}, "Luck", function(v) S.potionPrio = v end)
        CreateButton(tabRNG, "🧪 Use All Potions", function()
            CreateNotification("Slime RNG", "Using all available potions!", "success")
        end, CurrentTheme.Success, "🧪")

        CreateSection(tabMove, "MOVEMENT")
        CreateSlider(tabMove, "Walk Speed", 16, 100, 16, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
        end, " wsp")
        CreateToggle(tabMove, "Infinite Jump", false, function(v) S.infJump = v end)
        CreateToggle(tabMove, "Fly", false, function(v) S.fly = v end)
        CreateSlider(tabMove, "Fly Speed", 5, 200, 50, function(v) S.flySpeed = v end, " sp")

        CreateSection(tabMisc, "MISC")
        CreateToggle(tabMisc, "Anti-AFK", true, function(v) S.antiAFK = v end)
        CreateToggle(tabMisc, "Auto Daily Claim", false, function(v) S.autoDaily = v end)
        CreateToggle(tabMisc, "Fullbright", false, function(v) Lighting.Brightness = v and 10 or 2 end)

    elseif gameName == "Grow a Garden" then
        local tabFarm, _ = AddTab("Farming", "🌻")
        local tabCrops, _ = AddTab("Crops", "🌱")
        local tabShop, _ = AddTab("Shop", "🛒")
        local tabMove, _ = AddTab("Move", "🏃")
        ActivateTab("Farming")

        CreateSection(tabFarm, "AUTO FARMING")
        CreateToggle(tabFarm, "Auto Water Plants", false, function(v)
            S.autoWater = v
            CreateNotification("Garden", v and "Auto watering plants" or "Stopped watering", v and "success" or "warning")
        end, "Keeps plants watered automatically")
        CreateToggle(tabFarm, "Auto Harvest Crops", false, function(v) S.autoHarvest = v end, "Harvests when crops are ready")
        CreateToggle(tabFarm, "Auto Replant Seeds", false, function(v) S.autoReplant = v end, "Plants seeds after harvesting")
        CreateToggle(tabFarm, "Auto Sell All Crops", false, function(v) S.autoSell = v end)
        CreateSlider(tabFarm, "Farm Loop Delay", 1, 30, 5, function(v) S.farmDelay = v end, "s")
        CreateSection(tabFarm, "GROWTH MODS")
        CreateToggle(tabFarm, "Instant Grow", false, function(v) S.instantGrow = v end, "Crops grow immediately")
        CreateSlider(tabFarm, "Grow Speed Mult", 1, 50, 1, function(v) S.growMult = v end, "x")
        CreateToggle(tabFarm, "Never Wilt", false, function(v) S.neverWilt = v end, "Plants never die without water")

        CreateSection(tabCrops, "CROP MANAGER")
        CreateDropdown(tabCrops, "Auto Plant Type", {
            "Tomato","Carrot","Sunflower","Corn","Pumpkin",
            "Roses","Strawberry","Blueberry","Watermelon","Potato","Wheat"
        }, "Tomato", function(v) S.plantType = v end)
        CreateToggle(tabCrops, "Plant Only Profitable", false, function(v) S.profitOnly = v end)
        CreateButton(tabCrops, "🌱 Plant Selected Crop", function()
            CreateNotification("Garden", "Planting: " .. (S.plantType or "Tomato"), "success")
        end, gameColor, "🌱")
        CreateButton(tabCrops, "🌾 Harvest All Now", function()
            CreateNotification("Garden", "Harvesting all crops!", "success")
        end, CurrentTheme.Success, "🌾")
        CreateSection(tabCrops, "CROP STATUS")
        CreateToggle(tabCrops, "Show Crop Readiness", true, function(v) S.showReady = v end)
        CreateToggle(tabCrops, "Alert When Ready", true, function(v) S.alertReady = v end)

        CreateSection(tabShop, "SHOP")
        CreateToggle(tabShop, "Auto Buy Seeds", false, function(v) S.autoBuySeeds = v end)
        CreateToggle(tabShop, "Auto Buy Tools", false, function(v) S.autoBuyTools = v end)
        CreateDropdown(tabShop, "Buy Priority", {"Cheapest","Most Profitable","Rarest"}, "Most Profitable", function(v) S.buyPriority = v end)
        CreateButton(tabShop, "🛒 Go to Market", function()
            local market = workspace:FindFirstChild("Market") or workspace:FindFirstChild("Shop")
            local char = LocalPlayer.Character
            if char and market then
                char:SetPrimaryPartCFrame(market.CFrame + Vector3.new(0, 5, 0))
            end
            CreateNotification("Garden", "Going to market!", "info")
        end, gameColor, "🛒")

        CreateSection(tabMove, "MOVEMENT")
        CreateSlider(tabMove, "Walk Speed", 16, 80, 16, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
        end, " wsp")
        CreateToggle(tabMove, "Infinite Jump", false, function(v) S.infJump = v end)
        CreateToggle(tabMove, "Fly", false, function(v) S.fly = v end)
        CreateSlider(tabMove, "Fly Speed", 5, 150, 40, function(v) S.flySpeed = v end, " sp")

    elseif gameName == "Bloxstrike" then
        local tabAim, _ = AddTab("Aimbot", "🎯")
        local tabGun, _ = AddTab("Weapons", "🔫")
        local tabVis, _ = AddTab("Visuals", "👁")
        local tabMove, _ = AddTab("Move", "🏃")
        local tabMisc, _ = AddTab("Misc", "⚙️")
        ActivateTab("Aimbot")

        CreateSection(tabAim, "AIMBOT")
        CreateToggle(tabAim, "Aimbot", false, function(v)
            S.aimbot = v
            CreateNotification("Bloxstrike", v and "Aimbot enabled" or "Aimbot disabled", v and "success" or "warning")
        end)
        CreateToggle(tabAim, "Silent Aim", false, function(v) S.silentAim = v end)
        CreateToggle(tabAim, "Hold to Aim", true, function(v) S.holdAim = v end)
        CreateSlider(tabAim, "FOV", 10, 600, 180, function(v) S.fov = v UpdateFOVCircle(S.showFOV, v, Color3.fromRGB(255,255,255)) end, "px")
        CreateSlider(tabAim, "Smoothness", 1, 30, 6, function(v) S.smoothness = v end, "")
        CreateSlider(tabAim, "Prediction", 0, 20, 5, function(v) S.prediction = v end, "")
        CreateDropdown(tabAim, "Target Part", {"Head","HumanoidRootPart","Torso","Neck"}, "Head", function(v) S.targetPart = v end)
        CreateDropdown(tabAim, "Priority", {"Nearest","Lowest HP","Most Dangerous"}, "Nearest", function(v) S.priority = v end)
        CreateSection(tabAim, "TRIGGERBOT")
        CreateToggle(tabAim, "Triggerbot", false, function(v) S.triggerbot = v end)
        CreateSlider(tabAim, "Trigger Delay", 0, 300, 50, function(v) S.trigDelay = v end, "ms")
        CreateToggle(tabAim, "FOV Circle", false, function(v) S.showFOV = v UpdateFOVCircle(v, S.fov or 180, Color3.fromRGB(255,255,255)) end)

        CreateSection(tabGun, "WEAPON MODS")
        CreateToggle(tabGun, "No Recoil", false, function(v) S.noRecoil = v end)
        CreateToggle(tabGun, "No Spread", false, function(v) S.noSpread = v end)
        CreateToggle(tabGun, "Rapid Fire", false, function(v) S.rapidFire = v end)
        CreateToggle(tabGun, "Infinite Ammo", false, function(v) S.infAmmo = v end)
        CreateToggle(tabGun, "Auto Reload", false, function(v) S.autoReload = v end)
        CreateSlider(tabGun, "Bullet Speed", 500, 10000, 2000, function(v) S.bulletSpeed = v end, " v")
        CreateSection(tabGun, "ABILITIES")
        CreateToggle(tabGun, "Flashbang Immunity", false, function(v) S.noFlash = v end)
        CreateToggle(tabGun, "No Smoke", false, function(v) S.noSmoke = v end)

        CreateSection(tabVis, "ESP")
        CreateToggle(tabVis, "Master ESP", false, function(v) ESPConfig.Enabled = v if not v then CleanupESP() end end)
        CreateToggle(tabVis, "Names", false, function(v) ESPConfig.Names = v end)
        CreateToggle(tabVis, "Health", false, function(v) ESPConfig.Health = v end)
        CreateToggle(tabVis, "Distance", false, function(v) ESPConfig.Distance = v end)
        CreateToggle(tabVis, "Tracers", false, function(v) ESPConfig.Tracers = v end)
        CreateToggle(tabVis, "Highlights", false, function(v) ESPConfig.Highlights = v end)
        CreateSection(tabVis, "RENDERING")
        CreateToggle(tabVis, "Fullbright", false, function(v) Lighting.Brightness = v and 10 or 2 end)
        CreateToggle(tabVis, "No Fog", false, function(v) Lighting.FogEnd = v and 999999 or 1000 end)
        CreateToggle(tabVis, "No Scope Glint", false, function(v) S.noGlint = v end)

        CreateSection(tabMove, "MOVEMENT")
        CreateSlider(tabMove, "Walk Speed", 16, 80, 16, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
        end, " wsp")
        CreateToggle(tabMove, "Infinite Jump", false, function(v) S.infJump = v end)
        CreateToggle(tabMove, "Bunny Hop", false, function(v) S.bunnyHop = v end)
        CreateToggle(tabMove, "No Clip", false, function(v) S.noClip = v end)

        CreateSection(tabMisc, "MISC")
        CreateToggle(tabMisc, "Anti-AFK", true, function(v) S.antiAFK = v end)
        CreateToggle(tabMisc, "God Mode", false, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.MaxHealth = v and math.huge or 100
                c.Humanoid.Health = c.Humanoid.MaxHealth
            end
        end)
        CreateToggle(tabMisc, "Wallbang", false, function(v) S.wallbang = v end, "Bullets penetrate walls")

    elseif gameName == "Break Your Bones" then
        local tabPhys, _ = AddTab("Physics", "💥")
        local tabScore, _ = AddTab("Score", "🏆")
        local tabGrav, _ = AddTab("Gravity", "🌍")
        local tabMisc, _ = AddTab("Misc", "⚙️")
        ActivateTab("Physics")

        CreateSection(tabPhys, "LAUNCH SETTINGS")
        CreateSlider(tabPhys, "Launch Force", 100, 10000, 1000, function(v) S.launchForce = v end, " f")
        CreateDropdown(tabPhys, "Launch Direction", {"Up","Forward","Diagonal","Random","Spin","All Directions"}, "Up", function(v) S.launchDir = v end)
        CreateButton(tabPhys, "💥 Launch Character!", function()
            local char = LocalPlayer.Character
            if not char then return end
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local force = S.launchForce or 1000
                local dir = S.launchDir or "Up"
                local vel
                if dir == "Up" then vel = Vector3.new(0, force, 0)
                elseif dir == "Forward" then vel = Camera.CFrame.LookVector * force
                elseif dir == "Random" then vel = Vector3.new(math.random(-force,force), force, math.random(-force,force))
                elseif dir == "Spin" then vel = Vector3.new(force, force/2, force)
                else vel = Vector3.new(math.random(-force,force), math.random(0,force), math.random(-force,force))
                end
                root.Velocity = vel
                CreateNotification("BYB", "Launched! Force: " .. force, "success")
            end
        end, gameColor, "💥")
        CreateToggle(tabPhys, "Auto Launch (Loop)", false, function(v) S.autoLaunch = v end)
        CreateSlider(tabPhys, "Auto Launch Interval", 1, 30, 5, function(v) S.launchInterval = v end, "s")
        CreateSection(tabPhys, "BODY PARTS")
        CreateToggle(tabPhys, "Limp Mode", false, function(v) S.limp = v end, "All joints go loose")
        CreateToggle(tabPhys, "Ragdoll Always", false, function(v) S.alwaysRagdoll = v end)
        CreateSlider(tabPhys, "Ragdoll Duration", 1, 30, 5, function(v) S.ragdollDur = v end, "s")

        CreateSection(tabScore, "SCORE FARMING")
        CreateToggle(tabScore, "Auto Max Damage", false, function(v) S.autoMaxDmg = v end)
        CreateButton(tabScore, "📉 Giant Drop", function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(char.HumanoidRootPart.Position + Vector3.new(0, 500, 0))
                CreateNotification("BYB", "Dropping from 500 studs!", "info")
            end
        end, Color3.fromRGB(200, 80, 40), "📉")
        CreateButton(tabScore, "🌍 Drop from Space", function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(char.HumanoidRootPart.Position + Vector3.new(0, 2000, 0))
                CreateNotification("BYB", "Dropping from 2000 studs!", "success")
            end
        end, Color3.fromRGB(40, 60, 220), "🌍")

        CreateSection(tabGrav, "GRAVITY")
        CreateSlider(tabGrav, "Gravity", 0, 600, 196, function(v) workspace.Gravity = v end, " g")
        CreateToggle(tabGrav, "Zero Gravity", false, function(v) workspace.Gravity = v and 0.1 or 196.2 end, "Float in the air")
        CreateToggle(tabGrav, "Moon Gravity", false, function(v) workspace.Gravity = v and 20 or 196.2 end, "Low gravity like the moon")
        CreateToggle(tabGrav, "Hyper Gravity", false, function(v) workspace.Gravity = v and 600 or 196.2 end, "Extreme gravity")
        CreateButton(tabGrav, "🔄 Reset Gravity", function()
            workspace.Gravity = 196.2
            CreateNotification("BYB", "Gravity reset to normal", "success")
        end, CurrentTheme.Button, "🔄")

        CreateSection(tabMisc, "MISC")
        CreateToggle(tabMisc, "No Clip", false, function(v) S.noClip = v end)
        CreateToggle(tabMisc, "Infinite Jump", false, function(v) S.infJump = v end)
        CreateToggle(tabMisc, "Fly", false, function(v) S.fly = v end)
        CreateSlider(tabMisc, "Walk Speed", 16, 80, 16, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
        end, " wsp")

    else
        -- GENERIC MENU for all other games
        local tabGeneral, _ = AddTab("General", "⚙️")
        local tabMove, _ = AddTab("Movement", "🏃")
        local tabESP, _ = AddTab("ESP", "👁")
        local tabMisc, _ = AddTab("Misc", "🔧")
        ActivateTab("General")

        CreateSection(tabGeneral, "PLAYER")
        CreateToggle(tabGeneral, "God Mode", false, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.MaxHealth = v and math.huge or 100
                c.Humanoid.Health = c.Humanoid.MaxHealth
            end
        end, "Full invincibility")
        CreateToggle(tabGeneral, "Anti-AFK", true, function(v) S.antiAFK = v end)
        CreateToggle(tabGeneral, "No Clip", false, function(v) S.noClip = v end)
        CreateSection(tabGeneral, "COMBAT")
        CreateToggle(tabGeneral, "Aimbot (Generic)", false, function(v) S.aimbot = v end)
        CreateToggle(tabGeneral, "No Recoil", false, function(v) S.noRecoil = v end)
        CreateToggle(tabGeneral, "Infinite Ammo", false, function(v) S.infAmmo = v end)
        CreateSection(tabGeneral, "MISC")
        CreateToggle(tabGeneral, "Auto Farm", false, function(v)
            S.autoFarm = v
            CreateNotification(gameName, v and "Auto farm started" or "Auto farm stopped", v and "success" or "warning")
        end)
        CreateToggle(tabGeneral, "Auto Collect", false, function(v) S.autoCollect = v end)

        CreateSection(tabMove, "MOVEMENT")
        CreateSlider(tabMove, "Walk Speed", 16, 120, 16, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
        end, " wsp")
        CreateSlider(tabMove, "Jump Power", 50, 400, 50, function(v)
            local c = LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpPower = v end
        end, " jp")
        CreateToggle(tabMove, "Infinite Jump", false, function(v) S.infJump = v end)
        CreateToggle(tabMove, "Fly Mode", false, function(v)
            S.fly = v
            CreateNotification(gameName, v and "Fly enabled" or "Fly disabled", "info")
        end)
        CreateSlider(tabMove, "Fly Speed", 5, 300, 60, function(v) S.flySpeed = v end, " sp")
        CreateSection(tabMove, "TELEPORT")
        CreateButton(tabMove, "📍 TP to Spawn", function()
            local char = LocalPlayer.Character
            local sp = workspace:FindFirstChildOfClass("SpawnLocation")
            if char and sp then char:SetPrimaryPartCFrame(sp.CFrame + Vector3.new(0,5,0)) end
        end, CurrentTheme.Button, "📍")
        CreateButton(tabMove, "📍 TP to Mouse", function()
            local char = LocalPlayer.Character
            if char then char:SetPrimaryPartCFrame(Mouse.Hit + Vector3.new(0,5,0)) end
        end, CurrentTheme.Button, "🖱️")

        CreateSection(tabESP, "ESP")
        CreateToggle(tabESP, "Master ESP", false, function(v) ESPConfig.Enabled = v if not v then CleanupESP() end end)
        CreateToggle(tabESP, "Names", false, function(v) ESPConfig.Names = v end)
        CreateToggle(tabESP, "Health", false, function(v) ESPConfig.Health = v end)
        CreateToggle(tabESP, "Distance", false, function(v) ESPConfig.Distance = v end)
        CreateToggle(tabESP, "Highlights", false, function(v) ESPConfig.Highlights = v end)
        CreateSection(tabESP, "RENDERING")
        CreateToggle(tabESP, "Fullbright", false, function(v) Lighting.Brightness = v and 10 or 2 end)
        CreateToggle(tabESP, "No Fog", false, function(v) Lighting.FogEnd = v and 999999 or 1000 end)

        CreateSection(tabMisc, "EXTRAS")
        CreateToggle(tabMisc, "Fullbright", false, function(v) Lighting.Brightness = v and 10 or 2 end)
        CreateToggle(tabMisc, "Gravity Control", false, function(v) workspace.Gravity = v and 50 or 196.2 end)
        CreateSlider(tabMisc, "Custom Gravity", 1, 500, 196, function(v) workspace.Gravity = v end, " g")
        CreateButton(tabMisc, "💀 Kill All Enemies (Test)", function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local h = p.Character:FindFirstChild("Humanoid")
                    if h then h.Health = 0 end
                end
            end
            CreateNotification(gameName, "Eliminated all (test mode)", "success")
        end, CurrentTheme.Danger, "💀")
    end

    -- Open animation
    WIN.Size = UDim2.new(0, 0, 0, 0)
    WIN.BackgroundTransparency = 0.5
    Tween(WIN, {Size = UDim2.new(0, 400, 0, 530), BackgroundTransparency = 0}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    CreateNotification(gameName, "Game menu opened!", "info", 2)
end

-- ================================================================
-- FLY / NOCLIP / INFINITE JUMP SYSTEM
-- ================================================================

local flyObjects = {}

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not (root and hum) then return end

    for gName, S in pairs(gameStates) do
        -- NoClip
        if S.noClip then
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end

        -- Fly
        if S.fly then
            if not S._flyActive then
                S._flyActive = true
                hum.PlatformStand = true
                local bg = Instance.new("BodyGyro")
                bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                bg.D = 150
                bg.P = 10000
                bg.Parent = root
                local bv = Instance.new("BodyVelocity")
                bv.Velocity = Vector3.new(0,0,0)
                bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                bv.Parent = root
                S._bg = bg
                S._bv = bv
            end
            if S._bv and S._bg then
                local cam = workspace.CurrentCamera
                local speed = S.flySpeed or 60
                local dir = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.Q) then dir -= Vector3.new(0,1,0) end
                local vx, vy, vz = dir.X, dir.Y, dir.Z
                local mag = math.sqrt(vx*vx + vy*vy + vz*vz)
                S._bv.Velocity = mag > 0 and Vector3.new(vx/mag, vy/mag, vz/mag) * speed or Vector3.new(0, 0, 0)
                S._bg.CFrame = cam.CFrame
            end
        elseif S._flyActive then
            S._flyActive = false
            if hum then hum.PlatformStand = false end
            if S._bg then S._bg:Destroy() S._bg = nil end
            if S._bv then S._bv:Destroy() S._bv = nil end
        end
    end

    -- ESP Update (throttled)
    if ESPConfig.Enabled then
        UpdateESP()
    end
end)

-- Infinite Jump
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Space then
        for _, S in pairs(gameStates) do
            if S.infJump then
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChild("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end
    end
    -- Hub keybind
    if input.KeyCode == HubConfig.keybind then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible then
            MainFrame.Size = UDim2.new(0, 340, 0, 0)
            Tween(MainFrame, {Size = UDim2.new(0, 340, 0, 560)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    end
end)

-- ================================================================
-- BUILD GAME LIST
-- ================================================================

local gameButtons = {}

local function BuildGameList(filter)
    filter = (filter or ""):lower()
    for _, btn in ipairs(gameButtons) do
        if btn and btn.Parent then btn:Destroy() end
    end
    gameButtons = {}

    local count = 0
    for _, game in ipairs(GAMES) do
        local match = filter == ""
        if not match then
            if game.name:lower():find(filter, 1, true) or game.desc:lower():find(filter, 1, true) then
                match = true
            end
            if not match then
                for _, tag in ipairs(game.tags or {}) do
                    if tag:find(filter, 1, true) then match = true break end
                end
            end
        end
        if match then
            count = count + 1
            local T = CurrentTheme
            local GameBtn = Instance.new("TextButton")
            GameBtn.Size = UDim2.new(1, 0, 0, 56)
            GameBtn.BackgroundColor3 = T.Secondary
            GameBtn.Text = ""
            GameBtn.BorderSizePixel = 0
            GameBtn.AutoButtonColor = false
            GameBtn.Parent = ScrollFrame
            local gbCorner = Instance.new("UICorner", GameBtn)
            gbCorner.CornerRadius = UDim.new(0, 9)
            local gbStroke = Instance.new("UIStroke", GameBtn)
            gbStroke.Color = T.Border
            gbStroke.Thickness = 1

            local IconBG = Instance.new("Frame")
            IconBG.Size = UDim2.new(0, 40, 0, 40)
            IconBG.Position = UDim2.new(0, 8, 0.5, -20)
            IconBG.BackgroundColor3 = game.color
            IconBG.BorderSizePixel = 0
            IconBG.Parent = GameBtn
            local ibCorner = Instance.new("UICorner", IconBG)
            ibCorner.CornerRadius = UDim.new(0, 9)
            local IconLbl = Instance.new("TextLabel")
            IconLbl.Size = UDim2.new(1, 0, 1, 0)
            IconLbl.BackgroundTransparency = 1
            IconLbl.Text = game.icon
            IconLbl.TextSize = 20
            IconLbl.Font = Enum.Font.GothamBold
            IconLbl.Parent = IconBG

            local NameLbl = Instance.new("TextLabel")
            NameLbl.Size = UDim2.new(1, -110, 0, 20)
            NameLbl.Position = UDim2.new(0, 58, 0, 10)
            NameLbl.BackgroundTransparency = 1
            NameLbl.Text = game.name
            NameLbl.TextColor3 = T.Text
            NameLbl.Font = Enum.Font.GothamBold
            NameLbl.TextSize = 14
            NameLbl.TextXAlignment = Enum.TextXAlignment.Left
            NameLbl.Parent = GameBtn

            local DescLbl = Instance.new("TextLabel")
            DescLbl.Size = UDim2.new(1, -110, 0, 16)
            DescLbl.Position = UDim2.new(0, 58, 0, 32)
            DescLbl.BackgroundTransparency = 1
            DescLbl.Text = game.desc
            DescLbl.TextColor3 = T.TextMuted
            DescLbl.Font = Enum.Font.Gotham
            DescLbl.TextSize = 11
            DescLbl.TextXAlignment = Enum.TextXAlignment.Left
            DescLbl.Parent = GameBtn

            local OpenIndicator = Instance.new("Frame")
            OpenIndicator.Size = UDim2.new(0, 6, 0, 6)
            OpenIndicator.Position = UDim2.new(0, 58, 0, 10)
            OpenIndicator.AnchorPoint = Vector2.new(0, 0.5)
            OpenIndicator.BackgroundColor3 = CurrentTheme.Success
            OpenIndicator.BorderSizePixel = 0
            OpenIndicator.Visible = openWindows[game.name] ~= nil
            OpenIndicator.Parent = GameBtn
            local oiCorner = Instance.new("UICorner", OpenIndicator)
            oiCorner.CornerRadius = UDim.new(1, 0)

            local Arrow = Instance.new("TextLabel")
            Arrow.Size = UDim2.new(0, 24, 1, 0)
            Arrow.Position = UDim2.new(1, -30, 0, 0)
            Arrow.BackgroundTransparency = 1
            Arrow.Text = "›"
            Arrow.TextColor3 = T.TextMuted
            Arrow.Font = Enum.Font.GothamBold
            Arrow.TextSize = 24
            Arrow.Parent = GameBtn

            local gameColor = game.color
            local gameIcon = game.icon
            local gameName = game.name

            GameBtn.MouseEnter:Connect(function()
                Tween(GameBtn, {BackgroundColor3 = T.Tertiary}, 0.15)
                Tween(gbStroke, {Color = gameColor}, 0.2)
                Tween(Arrow, {TextColor3 = gameColor}, 0.15)
                Tween(IconBG, {BackgroundColor3 = Color3.new(
                    math.min(gameColor.R + 0.15, 1),
                    math.min(gameColor.G + 0.15, 1),
                    math.min(gameColor.B + 0.15, 1)
                )}, 0.15)
            end)
            GameBtn.MouseLeave:Connect(function()
                Tween(GameBtn, {BackgroundColor3 = T.Secondary}, 0.15)
                Tween(gbStroke, {Color = T.Border}, 0.2)
                Tween(Arrow, {TextColor3 = T.TextMuted}, 0.15)
                Tween(IconBG, {BackgroundColor3 = gameColor}, 0.15)
            end)
            GameBtn.MouseButton1Click:Connect(function()
                CreateGameWindow(gameName, gameColor, gameIcon)
                OpenIndicator.Visible = true
            end)

            table.insert(gameButtons, GameBtn)
        end
    end
    CountLabel.Text = tostring(count) .. " / " .. #GAMES .. " games"
end

BuildGameList()

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    BuildGameList(SearchBox.Text)
end)

-- Toggle Hub
toggleBtn.MouseButton1Click:Connect(function()
    if MainFrame.Visible then
        Tween(MainFrame, {Size = UDim2.new(0, 340, 0, 0)}, 0.3)
        task.wait(0.3)
        MainFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 340, 0, 560)
    else
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 340, 0, 0)
        Tween(MainFrame, {Size = UDim2.new(0, 340, 0, 560)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
end)

-- Startup animation
MainFrame.Visible = true
MainFrame.Size = UDim2.new(0, 340, 0, 0)
task.wait(0.5)
Tween(MainFrame, {Size = UDim2.new(0, 340, 0, 560)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
task.wait(0.8)
CreateNotification("Script Hub v2.0", "Hub loaded! " .. #GAMES .. " games ready.", "success", 5)
CreateNotification("Tip", "Press RightShift to toggle hub • Drag any window to move it", "info", 6)

print("╔══════════════════════════════╗")
print("║   SCRIPT HUB v2.0 LOADED     ║")
print("║   " .. #GAMES .. " Games Available          ║")
print("║   RightShift = Toggle Hub    ║")
print("╚══════════════════════════════╝")
