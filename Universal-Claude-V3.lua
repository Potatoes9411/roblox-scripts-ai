-- ================================================================
-- MULTI GAME SCRIPT HUB v3.2
-- Loadstring Compatible | Full Functionality Verified
-- ================================================================

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")

-- Safe init
repeat task.wait() until game:IsLoaded()
repeat task.wait() until Players.LocalPlayer
repeat task.wait() until Players.LocalPlayer:FindFirstChild("PlayerGui")

local LP   = Players.LocalPlayer
local PGui = LP.PlayerGui
local Mouse = LP:GetMouse()
local Cam   = workspace.CurrentCamera

task.wait(0.5)

-- Destroy old instance
for _, g in ipairs(PGui:GetChildren()) do
    if g.Name == "HubV32" then g:Destroy() end
end

-- ================================================================
-- COLORS
-- ================================================================
local C = {
    BG       = Color3.fromRGB(18,18,28),
    BG2      = Color3.fromRGB(25,25,38),
    BG3      = Color3.fromRGB(35,35,52),
    BG4      = Color3.fromRGB(28,28,44),
    Accent   = Color3.fromRGB(100,130,255),
    Text     = Color3.fromRGB(230,230,255),
    TextDim  = Color3.fromRGB(140,140,180),
    TextMute = Color3.fromRGB(90,90,130),
    TOn      = Color3.fromRGB(80,200,120),
    TOff     = Color3.fromRGB(70,70,100),
    Slider   = Color3.fromRGB(100,160,255),
    Btn      = Color3.fromRGB(80,110,220),
    Danger   = Color3.fromRGB(200,60,60),
    Warn     = Color3.fromRGB(200,160,0),
    Good     = Color3.fromRGB(60,180,100),
    Border   = Color3.fromRGB(60,60,100),
    White    = Color3.fromRGB(255,255,255),
    Purple   = Color3.fromRGB(140,80,255),
}

-- ================================================================
-- GLOBAL STATE
-- ================================================================
local States   = {}   -- per-game feature toggles
local OpenWins = {}   -- open window frames
local HubKeybind    = Enum.KeyCode.RightShift
local HubMinKeybind = Enum.KeyCode.RightControl

-- ================================================================
-- SCREENGUI
-- ================================================================
local SGui = Instance.new("ScreenGui")
SGui.Name             = "HubV32"
SGui.ResetOnSpawn     = false
SGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
SGui.IgnoreGuiInset   = true
SGui.Parent           = PGui

-- ================================================================
-- CHARACTER HELPERS
-- These functions always fetch fresh references so they work after
-- respawn without needing to reconnect anything.
-- ================================================================
local function GetChar()  return LP.Character end
local function GetRoot()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function GetHum()
    local c = GetChar()
    return c and c:FindFirstChildWhichIsA("Humanoid")
end

local function SetWS(v)
    local h = GetHum()
    if h then h.WalkSpeed = v end
end

local function SetJP(v)
    local h = GetHum()
    if h then h.JumpPower = v end
end

local function SetGod(enabled)
    local h = GetHum()
    if not h then return end
    if enabled then
        h.MaxHealth = math.huge
        h.Health    = math.huge
    else
        h.MaxHealth = 100
        h.Health    = 100
    end
end

-- ================================================================
-- TWEEN HELPER
-- ================================================================
local function Tw(obj, props, t, s, d)
    TweenService:Create(
        obj,
        TweenInfo.new(t or 0.25, s or Enum.EasingStyle.Quart, d or Enum.EasingDirection.Out),
        props
    ):Play()
end

-- ================================================================
-- DRAGGABLE — clamped to viewport
-- ================================================================
local function MakeDraggable(frame, handle)
    local dragging  = false
    local dragStart = nil
    local startPos  = nil
    handle = handle or frame

    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = i.Position
            startPos  = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMove then
            local delta = i.Position - dragStart
            local vp    = Cam.ViewportSize
            local newX  = math.clamp(startPos.X.Offset + delta.X, 0, vp.X - frame.AbsoluteSize.X)
            local newY  = math.clamp(startPos.Y.Offset + delta.Y, 0, vp.Y - frame.AbsoluteSize.Y)
            frame.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
        end
    end)
end

-- ================================================================
-- BASE UI BUILDERS
-- ================================================================
local function MkCorner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local function MkStroke(p, color, thick)
    local s = Instance.new("UIStroke", p)
    s.Color     = color or C.Border
    s.Thickness = thick or 1.5
    return s
end

local function MkFrame(parent, size, pos, color, clip)
    local f = Instance.new("Frame")
    f.Size              = size  or UDim2.new(1,0,1,0)
    f.Position          = pos   or UDim2.new(0,0,0,0)
    f.BackgroundColor3  = color or C.BG
    f.BorderSizePixel   = 0
    f.ClipsDescendants  = clip  or false
    if parent then f.Parent = parent end
    return f
end

local function MkLabel(parent, text, size, color, font, xalign)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text          = text   or ""
    l.TextSize      = size   or 13
    l.TextColor3    = color  or C.Text
    l.Font          = font   or Enum.Font.GothamMedium
    l.TextXAlignment= xalign or Enum.TextXAlignment.Left
    if parent then l.Parent = parent end
    return l
end

local function MkBtn(parent, text, size, pos, color, tc, fs)
    local b = Instance.new("TextButton")
    b.Size              = size  or UDim2.new(1,0,1,0)
    b.Position          = pos   or UDim2.new(0,0,0,0)
    b.BackgroundColor3  = color or C.BG3
    b.Text              = text  or ""
    b.TextColor3        = tc    or C.Text
    b.Font              = Enum.Font.GothamMedium
    b.TextSize          = fs    or 13
    b.BorderSizePixel   = 0
    b.AutoButtonColor   = false
    if parent then b.Parent = parent end
    return b
end

local function MkScroll(parent, size, pos)
    local s = Instance.new("ScrollingFrame")
    s.Size                  = size or UDim2.new(1,0,1,0)
    s.Position              = pos  or UDim2.new(0,0,0,0)
    s.BackgroundTransparency= 1
    s.BorderSizePixel       = 0
    s.ScrollBarThickness    = 4
    s.ScrollBarImageColor3  = C.Accent
    s.CanvasSize            = UDim2.new(0,0,0,0)
    s.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    if parent then s.Parent = parent end
    return s
end

local function MkList(parent, pad, dir)
    local l = Instance.new("UIListLayout", parent)
    l.SortOrder     = Enum.SortOrder.LayoutOrder
    l.Padding       = UDim.new(0, pad or 5)
    l.FillDirection = dir or Enum.FillDirection.Vertical
    return l
end

local function MkPad(parent, t, b, l, r)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    return p
end

-- ================================================================
-- REUSABLE UI COMPONENTS
-- ================================================================

-- SECTION DIVIDER
local function Section(parent, title)
    local f = MkFrame(parent, UDim2.new(1,-10,0,22), nil, C.BG)
    f.BackgroundTransparency = 1
    local l1 = MkFrame(f, UDim2.new(0.25,0,0,1), UDim2.new(0,0,0.5,0), C.Border)
    local lbl = MkLabel(f, "  "..title.."  ", 10, C.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    lbl.Size     = UDim2.new(0.5,0,1,0)
    lbl.Position = UDim2.new(0.25,0,0,0)
    local l2 = MkFrame(f, UDim2.new(0.25,0,0,1), UDim2.new(0.75,0,0.5,0), C.Border)
    return f
end

-- TOGGLE
local function Toggle(parent, text, default, cb, desc)
    local val = default == true  -- explicit bool check
    local h   = desc and 48 or 34

    local frame = MkFrame(parent, UDim2.new(1,-10,0,h), nil, C.BG3)
    MkCorner(frame, 7)

    local lbl = MkLabel(frame, text, 13, C.Text, Enum.Font.GothamMedium)
    lbl.Size     = UDim2.new(1,-65,0,18)
    lbl.Position = UDim2.new(0,10,0, desc and 6 or 8)

    if desc then
        local d = MkLabel(frame, desc, 10, C.TextMute, Enum.Font.Gotham)
        d.Size     = UDim2.new(1,-65,0,14)
        d.Position = UDim2.new(0,10,0,26)
    end

    local togBg = MkFrame(frame,
        UDim2.new(0,44,0,22),
        UDim2.new(1,-54,0.5,-11),
        val and C.TOn or C.TOff)
    MkCorner(togBg, 12)

    local knob = MkFrame(togBg,
        UDim2.new(0,16,0,16),
        val and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
        C.White)
    MkCorner(knob, 10)

    -- Invisible full-size button to capture clicks anywhere on the row
    local hit = MkBtn(frame, "", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0))
    hit.BackgroundTransparency = 1

    hit.MouseButton1Click:Connect(function()
        val = not val
        Tw(togBg, {BackgroundColor3 = val and C.TOn or C.TOff}, 0.2)
        Tw(knob,  {Position = val and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)}, 0.2)
        if cb then cb(val) end
    end)

    return frame, function() return val end
end

-- SLIDER
-- Uses Mouse.X relative to track AbsolutePosition which is reliable
-- in both Play Solo and via loadstring.
local function Slider(parent, text, min, max, default, cb, suf)
    local val = math.clamp(default or min, min, max)
    suf = suf or ""

    local frame = MkFrame(parent, UDim2.new(1,-10,0,54), nil, C.BG3)
    MkCorner(frame, 7)

    local lbl = MkLabel(frame, text, 13, C.Text, Enum.Font.GothamMedium)
    lbl.Size     = UDim2.new(1,-85,0,20)
    lbl.Position = UDim2.new(0,10,0,6)

    local vLbl = MkLabel(frame, tostring(val)..suf, 12, C.Slider, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
    vLbl.Size     = UDim2.new(0,70,0,20)
    vLbl.Position = UDim2.new(1,-78,0,6)

    local track = MkFrame(frame, UDim2.new(1,-20,0,6), UDim2.new(0,10,0,38), C.BG2)
    MkCorner(track, 4)

    local pct  = (val - min) / (max - min)
    local fill = MkFrame(track, UDim2.new(pct,0,1,0), nil, C.Slider)
    MkCorner(fill, 4)

    local knob = MkFrame(track, UDim2.new(0,14,0,14), UDim2.new(pct,-7,0.5,-7), C.White)
    knob.ZIndex = 3
    MkCorner(knob, 8)

    local sliding = false

    -- Clickable area slightly taller than the track so it's easier to grab
    local cd = MkBtn(track, "", UDim2.new(1,0,1,10), UDim2.new(0,0,0,-5))
    cd.BackgroundTransparency = 1
    cd.ZIndex = 4

    local function Update(mouseX)
        local rel = math.clamp((mouseX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        val = math.floor(min + (max - min) * rel + 0.5)
        vLbl.Text      = tostring(val)..suf
        fill.Size      = UDim2.new(rel, 0, 1, 0)
        knob.Position  = UDim2.new(rel, -7, 0.5, -7)
        if cb then cb(val) end
    end

    cd.MouseButton1Down:Connect(function()
        sliding = true
        Update(Mouse.X)
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and i.UserInputType == Enum.UserInputType.MouseMove then
            Update(Mouse.X)
        end
    end)

    return frame
end

-- BUTTON
local function Button(parent, text, cb, color)
    color = color or C.Btn
    local btn = MkBtn(parent, text, UDim2.new(1,-10,0,34), nil, color, C.White, 13)
    btn.Font = Enum.Font.GothamBold
    MkCorner(btn, 7)

    btn.MouseEnter:Connect(function()
        Tw(btn, {BackgroundColor3 = Color3.new(
            math.min(color.R + 0.1, 1),
            math.min(color.G + 0.1, 1),
            math.min(color.B + 0.1, 1))}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        Tw(btn, {BackgroundColor3 = color}, 0.15)
    end)
    btn.MouseButton1Down:Connect(function()
        Tw(btn, {BackgroundColor3 = Color3.new(
            math.max(color.R - 0.08, 0),
            math.max(color.G - 0.08, 0),
            math.max(color.B - 0.08, 0))}, 0.1)
    end)
    btn.MouseButton1Up:Connect(function()
        Tw(btn, {BackgroundColor3 = color}, 0.1)
    end)
    btn.MouseButton1Click:Connect(function()
        if cb then cb() end
    end)
    return btn
end

-- DROPDOWN
local function Dropdown(parent, text, opts, default, cb)
    local sel    = default or opts[1]
    local isOpen = false

    local cont = MkFrame(parent, UDim2.new(1,-10,0,34), nil, C.BG3)
    cont.ClipsDescendants = false
    cont.ZIndex = 10
    MkCorner(cont, 7)

    local lbl = MkLabel(cont, text, 13, C.Text, Enum.Font.GothamMedium)
    lbl.Size     = UDim2.new(0.48,0,1,0)
    lbl.Position = UDim2.new(0,10,0,0)
    lbl.ZIndex   = 10

    local selLbl = MkLabel(cont, sel, 12, C.Accent, Enum.Font.GothamMedium, Enum.TextXAlignment.Right)
    selLbl.Size     = UDim2.new(0.42,-22,1,0)
    selLbl.Position = UDim2.new(0.48,0,0,0)
    selLbl.ZIndex   = 10

    local arr = MkLabel(cont, "▼", 10, C.TextDim, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    arr.Size     = UDim2.new(0,22,1,0)
    arr.Position = UDim2.new(1,-24,0,0)
    arr.ZIndex   = 10

    local maxVis = math.min(#opts, 5)
    local dropH  = maxVis * 28 + 6

    local drop = MkFrame(cont, UDim2.new(1,0,0,dropH), UDim2.new(0,0,1,4), C.BG2)
    drop.ZIndex           = 20
    drop.Visible          = false
    drop.ClipsDescendants = true
    MkCorner(drop, 7)
    MkStroke(drop, C.Border, 1)

    local dScroll = MkScroll(drop, UDim2.new(1,-4,1,-4), UDim2.new(0,2,0,2))
    dScroll.ZIndex = 21
    MkList(dScroll, 2)
    MkPad(dScroll, 2, 2, 2, 2)

    local optBtns = {}
    for _, opt in ipairs(opts) do
        local isSelected = (opt == sel)
        local ob = MkBtn(dScroll, opt, UDim2.new(1,0,0,26), nil,
            isSelected and C.Accent or C.BG3,
            isSelected and C.White  or C.TextDim, 12)
        ob.Font   = Enum.Font.GothamMedium
        ob.ZIndex = 22
        MkCorner(ob, 5)
        optBtns[opt] = ob

        ob.MouseEnter:Connect(function()
            if sel ~= opt then Tw(ob, {BackgroundColor3 = C.BG4}, 0.1) end
        end)
        ob.MouseLeave:Connect(function()
            if sel ~= opt then Tw(ob, {BackgroundColor3 = C.BG3}, 0.1) end
        end)
        ob.MouseButton1Click:Connect(function()
            for _, b in pairs(optBtns) do
                b.BackgroundColor3 = C.BG3
                b.TextColor3       = C.TextDim
            end
            sel                    = opt
            selLbl.Text            = opt
            ob.BackgroundColor3    = C.Accent
            ob.TextColor3          = C.White
            isOpen                 = false
            drop.Visible           = false
            Tw(arr, {Rotation = 0}, 0.2)
            if cb then cb(opt) end
        end)
    end

    local hit = MkBtn(cont, "", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0))
    hit.BackgroundTransparency = 1
    hit.ZIndex = 11
    hit.MouseButton1Click:Connect(function()
        isOpen       = not isOpen
        drop.Visible = isOpen
        Tw(arr, {Rotation = isOpen and 180 or 0}, 0.2)
    end)

    return cont
end

-- ================================================================
-- NOTIFICATION SYSTEM
-- ================================================================
local NHolder = MkFrame(SGui, UDim2.new(0,290,1,-20), UDim2.new(1,-300,0,10))
NHolder.BackgroundTransparency = 1
NHolder.ZIndex = 200
local nhList = MkList(NHolder, 5)
nhList.VerticalAlignment = Enum.VerticalAlignment.Bottom

local function Notify(title, msg, ntype, dur)
    dur   = dur or 4
    local clrs = {info=C.Accent, success=C.Good, warning=C.Warn, error=C.Danger}
    local icos = {info="ℹ",      success="✓",    warning="⚠",   error="✕"}
    local nc = clrs[ntype] or C.Accent
    local ni = icos[ntype]  or "ℹ"

    local nf = MkFrame(NHolder, UDim2.new(0,280,0,0), nil, C.BG2)
    nf.ClipsDescendants = true
    nf.ZIndex = 200
    MkCorner(nf, 10)
    MkStroke(nf, nc, 1.5)

    local ab = MkFrame(nf, UDim2.new(0,4,1,0), nil, nc)
    MkCorner(ab, 3)

    local ico = MkFrame(nf, UDim2.new(0,26,0,26), UDim2.new(0,12,0,9), nc)
    MkCorner(ico, 13)
    local iL = MkLabel(ico, ni, 13, C.White, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    iL.Size   = UDim2.new(1,0,1,0)
    iL.ZIndex = 201

    local tl = MkLabel(nf, title, 13, C.Text, Enum.Font.GothamBold)
    tl.Size     = UDim2.new(1,-55,0,17)
    tl.Position = UDim2.new(0,48,0,7)
    tl.ZIndex   = 201

    local ml = MkLabel(nf, msg, 11, C.TextDim, Enum.Font.Gotham)
    ml.Size        = UDim2.new(1,-55,0,28)
    ml.Position    = UDim2.new(0,48,0,25)
    ml.TextWrapped = true
    ml.ZIndex      = 201

    local pbg = MkFrame(nf, UDim2.new(1,-8,0,3), UDim2.new(0,4,1,-5), C.BG3)
    MkCorner(pbg, 3)
    local pf = MkFrame(pbg, UDim2.new(1,0,1,0), nil, nc)
    MkCorner(pf, 3)

    Tw(nf, {Size = UDim2.new(0,280,0,66)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    Tw(pf, {Size = UDim2.new(0,0,1,0)},    dur,  Enum.EasingStyle.Linear)

    task.delay(dur, function()
        Tw(nf, {Size = UDim2.new(0,280,0,0)}, 0.3)
        task.wait(0.35)
        if nf and nf.Parent then nf:Destroy() end
    end)
end

-- ================================================================
-- WATERMARK + FPS COUNTER
-- ================================================================
local wmF = MkFrame(SGui, UDim2.new(0,220,0,28), UDim2.new(0,8,0,8), C.BG2)
wmF.ZIndex = 50
MkCorner(wmF, 6)
MkStroke(wmF, C.Accent, 1)
local wmL = MkLabel(wmF, "🎮 Hub v3.2", 12, C.Text, Enum.Font.GothamBold)
wmL.Size     = UDim2.new(1,-10,1,0)
wmL.Position = UDim2.new(0,8,0,0)
wmL.ZIndex   = 51

local fpsF = MkFrame(SGui, UDim2.new(0,120,0,24), UDim2.new(0,8,0,40), C.BG2)
fpsF.ZIndex = 50
MkCorner(fpsF, 6)
MkStroke(fpsF, C.Border, 1)
local fpsL = MkLabel(fpsF, "FPS: --", 11, C.TextDim, Enum.Font.GothamBold)
fpsL.Size     = UDim2.new(1,-10,1,0)
fpsL.Position = UDim2.new(0,8,0,0)
fpsL.ZIndex   = 51

do
    local lastT  = tick()
    local fCount = 0
    RunService.Heartbeat:Connect(function()
        fCount += 1
        local now = tick()
        if now - lastT >= 0.5 then
            local fps = math.floor(fCount / (now - lastT))
            fCount = 0
            lastT  = now
            fpsL.TextColor3 = fps >= 55 and C.Good or fps >= 30 and C.Warn or C.Danger
            fpsL.Text       = "FPS: "..fps
            wmL.Text        = string.format("🎮 Hub v3.2  |  %s", os.date("%H:%M:%S"))
        end
    end)
end

-- ================================================================
-- TOGGLE BUTTON (always visible sidebar)
-- ================================================================
local togBtn = MkBtn(SGui, "☰",
    UDim2.new(0,44,0,44),
    UDim2.new(0,10,0.5,-22),
    C.BG2, C.Accent, 22)
togBtn.Font   = Enum.Font.GothamBold
togBtn.ZIndex = 100
MkCorner(togBtn, 10)
MkStroke(togBtn, C.Accent, 1.5)

-- ================================================================
-- MAIN HUB FRAME
-- ================================================================
local Hub = MkFrame(SGui,
    UDim2.new(0,340,0,580),
    UDim2.new(0,64,0.5,-290),
    C.BG, true)
Hub.ZIndex = 10
MkCorner(Hub, 12)
MkStroke(Hub, C.Border, 1.5)

local fullHubSize = UDim2.new(0,340,0,580)
local miniHubSize = UDim2.new(0,340,0,59)
local isHubMin    = false

-- Gradient top strip
local topBar = MkFrame(Hub, UDim2.new(1,0,0,3), nil, C.Accent)
do
    local g = Instance.new("UIGradient", topBar)
    g.Color    = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.Accent),
        ColorSequenceKeypoint.new(1, C.Purple),
    })
    g.Rotation = 0
end

-- Title bar
local titleBar = MkFrame(Hub, UDim2.new(1,0,0,56), UDim2.new(0,0,0,3), C.BG2)

local iconBg = MkFrame(titleBar, UDim2.new(0,38,0,38), UDim2.new(0,10,0.5,-19), C.Accent)
MkCorner(iconBg, 9)
do
    local ig = Instance.new("UIGradient", iconBg)
    ig.Color    = ColorSequence.new({
        ColorSequenceKeypoint.new(0, C.Accent),
        ColorSequenceKeypoint.new(1, C.Purple),
    })
    ig.Rotation = 45
end
local iconL = MkLabel(iconBg, "🎮", 20, C.White, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
iconL.Size = UDim2.new(1,0,1,0)

local titleL = MkLabel(titleBar, "Script Hub", 20, C.Text, Enum.Font.GothamBold)
titleL.Size     = UDim2.new(1,-120,0,24)
titleL.Position = UDim2.new(0,58,0,9)

local subL = MkLabel(titleBar, "v3.2 — Studio Edition", 11, C.TextMute, Enum.Font.Gotham)
subL.Size     = UDim2.new(1,-120,0,15)
subL.Position = UDim2.new(0,58,0,34)

local function HBtn(xOff, color, sym)
    local b = MkBtn(titleBar, sym,
        UDim2.new(0,26,0,26),
        UDim2.new(1,xOff,0.5,-13),
        color, C.White, 12)
    b.Font   = Enum.Font.GothamBold
    MkCorner(b, 13)
    b.MouseEnter:Connect(function() Tw(b, {BackgroundTransparency=0.3}, 0.1) end)
    b.MouseLeave:Connect(function() Tw(b, {BackgroundTransparency=0},   0.1) end)
    return b
end

local hubClose = HBtn(-36, C.Danger, "✕")
local hubMin   = HBtn(-66, C.Warn,   "─")

local function DoToggleMin()
    isHubMin = not isHubMin
    Tw(Hub, {Size = isHubMin and miniHubSize or fullHubSize}, 0.35, Enum.EasingStyle.Quart)
    hubMin.Text = isHubMin and "▲" or "─"
end

hubMin.MouseButton1Click:Connect(DoToggleMin)

hubClose.MouseButton1Click:Connect(function()
    Tw(Hub, {Size = UDim2.new(0,340,0,0)}, 0.3)
    task.delay(0.35, function()
        Hub.Visible = false
        Hub.Size    = fullHubSize
        isHubMin    = false
        hubMin.Text = "─"
    end)
end)

-- Make main hub draggable via its title bar
MakeDraggable(Hub, titleBar)

-- Keybinds
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == HubKeybind then
        if Hub.Visible then
            Tw(Hub, {Size = UDim2.new(0,340,0,0)}, 0.3)
            task.delay(0.35, function()
                Hub.Visible = false
                Hub.Size    = isHubMin and miniHubSize or fullHubSize
            end)
        else
            Hub.Visible = true
            Hub.Size    = UDim2.new(0,340,0,0)
            Tw(Hub, {Size = isHubMin and miniHubSize or fullHubSize}, 0.4,
               Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
    elseif inp.KeyCode == HubMinKeybind then
        if Hub.Visible then DoToggleMin() end
    end
end)

togBtn.MouseButton1Click:Connect(function()
    if Hub.Visible then
        Tw(Hub, {Size = UDim2.new(0,340,0,0)}, 0.3)
        task.delay(0.35, function()
            Hub.Visible = false
            Hub.Size    = isHubMin and miniHubSize or fullHubSize
        end)
    else
        Hub.Visible = true
        Hub.Size    = UDim2.new(0,340,0,0)
        Tw(Hub, {Size = isHubMin and miniHubSize or fullHubSize}, 0.4,
           Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
end)

-- Search bar
local searchOuter = MkFrame(Hub, UDim2.new(1,-20,0,36), UDim2.new(0,10,0,66), C.BG3)
MkCorner(searchOuter, 9)
MkStroke(searchOuter, C.Border, 1)

local searchIco = MkLabel(searchOuter, "🔍", 14, C.TextMute, Enum.Font.Gotham, Enum.TextXAlignment.Center)
searchIco.Size = UDim2.new(0,32,1,0)

local searchBox = Instance.new("TextBox")
searchBox.Size              = UDim2.new(1,-42,1,0)
searchBox.Position          = UDim2.new(0,34,0,0)
searchBox.BackgroundTransparency = 1
searchBox.Text              = ""
searchBox.PlaceholderText   = "Search games..."
searchBox.PlaceholderColor3 = C.TextMute
searchBox.TextColor3        = C.Text
searchBox.Font              = Enum.Font.Gotham
searchBox.TextSize          = 13
searchBox.TextXAlignment    = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus  = false
searchBox.Parent            = searchOuter

-- Stats bar
local statsBar = MkFrame(Hub, UDim2.new(1,-20,0,24), UDim2.new(0,10,0,108), C.BG3)
MkCorner(statsBar, 6)
local countL = MkLabel(statsBar, "", 11, C.TextDim, Enum.Font.GothamMedium)
countL.Size     = UDim2.new(0.55,0,1,0)
countL.Position = UDim2.new(0,8,0,0)
local plrL = MkLabel(statsBar, "👤 "..LP.Name, 11, C.Accent, Enum.Font.GothamMedium, Enum.TextXAlignment.Right)
plrL.Size     = UDim2.new(0.45,-8,1,0)
plrL.Position = UDim2.new(0.55,0,0,0)

-- Hint bar
local hintBar = MkFrame(Hub, UDim2.new(1,-20,0,20), UDim2.new(0,10,0,137), C.BG3)
MkCorner(hintBar, 5)
local hintL = MkLabel(hintBar, "RShift: Toggle  •  RCtrl: Minimize  •  Drag title bar", 10, C.TextMute, Enum.Font.Gotham, Enum.TextXAlignment.Center)
hintL.Size = UDim2.new(1,0,1,0)

-- Game list scroll
local gameScroll = MkScroll(Hub, UDim2.new(1,-20,1,-163), UDim2.new(0,10,0,160))
gameScroll.ScrollBarImageColor3 = C.Accent
MkList(gameScroll, 6)
MkPad(gameScroll, 0, 8, 0, 0)

-- ================================================================
-- GAMES DATABASE
-- ================================================================
local GAMES = {
    {name="Arsenal",             icon="⚔️",  color=Color3.fromRGB(220,60,60),   desc="FPS Shooter"},
    {name="Rivals",              icon="🥊",  color=Color3.fromRGB(200,80,40),   desc="PvP Fighter"},
    {name="Hypershot",           icon="🎯",  color=Color3.fromRGB(60,160,220),  desc="Aim Trainer"},
    {name="Jailbreak",           icon="🚔",  color=Color3.fromRGB(40,100,200),  desc="Open World"},
    {name="Combat Arena",        icon="🗡️",  color=Color3.fromRGB(160,50,200),  desc="Combat Game"},
    {name="Steal a Brainrot",    icon="🧠",  color=Color3.fromRGB(100,200,80),  desc="Steal Game"},
    {name="Murder Mystery 2",    icon="🔪",  color=Color3.fromRGB(180,40,40),   desc="Mystery"},
    {name="Blade Ball",          icon="⚡",  color=Color3.fromRGB(255,180,0),   desc="Deflect Game"},
    {name="Tower of Hell",       icon="🏗️",  color=Color3.fromRGB(255,100,0),   desc="Obby"},
    {name="Da Hood",             icon="🌆",  color=Color3.fromRGB(80,80,120),   desc="Street Game"},
    {name="Natural Disasters",   icon="🌪️",  color=Color3.fromRGB(60,140,80),   desc="Survival"},
    {name="One Tap",             icon="💥",  color=Color3.fromRGB(220,40,80),   desc="FPS Game"},
    {name="Bee Swarm Simulator", icon="🐝",  color=Color3.fromRGB(255,200,0),   desc="Simulator"},
    {name="Flee the Facility",   icon="🏃",  color=Color3.fromRGB(40,160,180),  desc="Horror Escape"},
    {name="Grow a Garden",       icon="🌻",  color=Color3.fromRGB(80,180,60),   desc="Farming Sim"},
    {name="Bloxstrike",          icon="🔫",  color=Color3.fromRGB(60,80,200),   desc="FPS Shooter"},
    {name="Break Your Bones",    icon="💀",  color=Color3.fromRGB(160,160,180), desc="Physics Game"},
    {name="Slime RNG",           icon="🟢",  color=Color3.fromRGB(60,200,120),  desc="RNG Game"},
    {name="Pet Simulator X",     icon="🐾",  color=Color3.fromRGB(255,140,0),   desc="Pet Sim"},
    {name="Adopt Me!",           icon="🏠",  color=Color3.fromRGB(255,180,200), desc="Roleplay"},
    {name="Redliners",           icon="🔴",  color=Color3.fromRGB(220,30,30),   desc="FPS Shooter"},
}

-- ================================================================
-- WINDOW FACTORY
-- ================================================================
local function MakeWindow(gName, gColor, gIcon)
    -- If already open just show and animate it back in
    if OpenWins[gName] and OpenWins[gName].Parent then
        OpenWins[gName].Visible = true
        OpenWins[gName].Size    = UDim2.new(0,0,0,0)
        Tw(OpenWins[gName], {Size=UDim2.new(0,430,0,550)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        return
    end

    States[gName] = States[gName] or {}
    local S = States[gName]

    -- ---- WINDOW FRAME ----
    local win = MkFrame(SGui,
        UDim2.new(0,430,0,550),
        UDim2.new(0.5, -215 + math.random(-50,50), 0.5, -275 + math.random(-30,30)),
        C.BG, true)
    win.ZIndex = 50
    MkCorner(win, 12)
    MkStroke(win, gColor, 1.5)
    OpenWins[gName] = win

    -- Coloured top strip with subtle gradient
    local wTop = MkFrame(win, UDim2.new(1,0,0,3), nil, gColor)
    wTop.ZIndex = 51
    do
        local g = Instance.new("UIGradient", wTop)
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, gColor),
            ColorSequenceKeypoint.new(1, Color3.new(
                math.min(gColor.R + 0.15, 1),
                math.min(gColor.G + 0.05, 1),
                math.min(gColor.B + 0.25, 1)))
        })
    end

    -- Title bar
    local wTB = MkFrame(win, UDim2.new(1,0,0,54), UDim2.new(0,0,0,3), C.BG2)
    wTB.ZIndex = 51

    local wIB = MkFrame(wTB, UDim2.new(0,38,0,38), UDim2.new(0,10,0.5,-19), gColor)
    wIB.ZIndex = 52
    MkCorner(wIB, 9)
    local wIL = MkLabel(wIB, gIcon, 20, C.White, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    wIL.Size   = UDim2.new(1,0,1,0)
    wIL.ZIndex = 53

    local wTL = MkLabel(wTB, gName, 17, C.Text, Enum.Font.GothamBold)
    wTL.Size     = UDim2.new(1,-140,0,22)
    wTL.Position = UDim2.new(0,58,0,7)
    wTL.ZIndex   = 52

    local wSL = MkLabel(wTB, "Script Controls", 11, C.TextMute, Enum.Font.Gotham)
    wSL.Size     = UDim2.new(1,-140,0,14)
    wSL.Position = UDim2.new(0,58,0,31)
    wSL.ZIndex   = 52

    local function WBtn(xOff, color, sym)
        local b = MkBtn(wTB, sym,
            UDim2.new(0,26,0,26),
            UDim2.new(1,xOff,0.5,-13),
            color, C.White, 12)
        b.Font   = Enum.Font.GothamBold
        b.ZIndex = 55
        MkCorner(b, 13)
        b.MouseEnter:Connect(function() Tw(b, {BackgroundTransparency=0.3}, 0.1) end)
        b.MouseLeave:Connect(function() Tw(b, {BackgroundTransparency=0},   0.1) end)
        return b
    end

    local wClose = WBtn(-36, C.Danger, "✕")
    local wMinB  = WBtn(-66, C.Warn,   "─")
    local wMinned = false

    wMinB.MouseButton1Click:Connect(function()
        wMinned     = not wMinned
        wMinB.Text  = wMinned and "▲" or "─"
        Tw(win, {Size = wMinned and UDim2.new(0,430,0,57) or UDim2.new(0,430,0,550)}, 0.3)
    end)

    wClose.MouseButton1Click:Connect(function()
        Tw(win, {Size = UDim2.new(0,0,0,0)}, 0.25)
        task.delay(0.28, function()
            if win and win.Parent then win:Destroy() end
            OpenWins[gName] = nil
            States[gName]   = nil
        end)
    end)

    -- Every game window is also draggable
    MakeDraggable(win, wTB)

    -- Tab scroll bar
    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Size                = UDim2.new(1,-20,0,34)
    tabScroll.Position            = UDim2.new(0,10,0,61)
    tabScroll.BackgroundColor3    = C.BG2
    tabScroll.BorderSizePixel     = 0
    tabScroll.ScrollBarThickness  = 0
    tabScroll.CanvasSize          = UDim2.new(0,0,0,0)
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
    tabScroll.ZIndex              = 52
    tabScroll.Parent              = win
    MkCorner(tabScroll, 8)
    MkList(tabScroll, 4, Enum.FillDirection.Horizontal)
    MkPad(tabScroll, 5, 5, 4, 4)

    -- Content scroll
    local content = MkScroll(win, UDim2.new(1,-20,1,-103), UDim2.new(0,10,0,100))
    content.ZIndex                = 51
    content.ScrollBarImageColor3  = gColor
    content.ScrollBarThickness    = 3

    -- Tab state
    local tabNames  = {}
    local tabFrames = {}
    local tabBtns   = {}

    local function AddTab(name)
        local btn = MkBtn(tabScroll, name, UDim2.new(0,90,1,0), nil, C.BG3, C.TextDim, 11)
        btn.Font   = Enum.Font.GothamMedium
        btn.ZIndex = 53
        MkCorner(btn, 6)

        local tc = MkFrame(content, UDim2.new(1,0,0,0), nil, C.BG)
        tc.BackgroundTransparency = 1
        tc.Visible                = false
        tc.AutomaticSize          = Enum.AutomaticSize.Y
        tc.ZIndex                 = 51
        MkList(tc, 5)

        table.insert(tabNames, name)
        tabFrames[name] = tc
        tabBtns[name]   = btn

        btn.MouseButton1Click:Connect(function()
            for _, n in ipairs(tabNames) do
                tabFrames[n].Visible = false
                Tw(tabBtns[n], {BackgroundColor3=C.BG3, TextColor3=C.TextDim}, 0.15)
            end
            tc.Visible = true
            Tw(btn, {BackgroundColor3=gColor, TextColor3=C.White}, 0.15)
            content.CanvasPosition = Vector2.new(0,0)
        end)
        return tc
    end

    local function Activate(name)
        if not tabFrames[name] then return end
        for _, n in ipairs(tabNames) do
            tabFrames[n].Visible = false
            Tw(tabBtns[n], {BackgroundColor3=C.BG3, TextColor3=C.TextDim}, 0.15)
        end
        tabFrames[name].Visible = true
        Tw(tabBtns[name], {BackgroundColor3=gColor, TextColor3=C.White}, 0.15)
    end

    -- ================================================================
    -- SHARED TAB BUILDERS (reused across multiple games)
    -- ================================================================

    -- MOVEMENT TAB
    -- All values here directly mutate Humanoid properties which ARE
    -- accessible client-side in both Studio and live games.
    local function MoveTab()
        local tab = AddTab("Movement")
        Section(tab, "SPEED & JUMP")
        Slider(tab, "Walk Speed", 16, 200, 16, function(v) SetWS(v) end, " wsp")
        Slider(tab, "Jump Power",  50, 500, 50, function(v) SetJP(v) end, " jp")
        Toggle(tab, "Infinite Jump", false, function(v) S.infJump = v end,
               "Jump again before landing")
        Toggle(tab, "Bunny Hop", false, function(v) S.bunnyHop = v end,
               "Auto-jumps the moment you land")
        Section(tab, "FLY")
        Toggle(tab, "Fly Mode", false, function(v)
            S.fly = v
            Notify("Movement", v and "Fly ON  |  WASD + Space/Ctrl" or "Fly OFF",
                   v and "info" or "warning")
        end, "WASD move  •  Space up  •  Ctrl down")
        Slider(tab, "Fly Speed", 5, 500, 60, function(v) S.flySpeed = v end, " sp")
        Section(tab, "UTILITY")
        Toggle(tab, "No Clip", false, function(v) S.noClip = v end,
               "Phase through walls and floors")
        Toggle(tab, "God Mode", false, function(v) SetGod(v) end,
               "Cannot take damage or die")
        Toggle(tab, "Anti AFK", true, function(v) S.antiAFK = v end,
               "Prevents automatic kick for inactivity")
        Toggle(tab, "No Fall Damage", false, function(v) S.noFallDmg = v end)
        Section(tab, "TELEPORT")
        Button(tab, "📍 Teleport to Spawn", function()
            local c  = GetChar()
            local sp = workspace:FindFirstChildOfClass("SpawnLocation")
            if c and sp then
                c:SetPrimaryPartCFrame(sp.CFrame + Vector3.new(0,5,0))
                Notify("Teleport", "Teleported to spawn!", "success")
            else
                Notify("Teleport", "Spawn location not found", "warning")
            end
        end, C.Btn)
        Button(tab, "📍 Teleport to Mouse Position", function()
            local c = GetChar()
            if c then
                c:SetPrimaryPartCFrame(Mouse.Hit + Vector3.new(0,5,0))
                Notify("Teleport", "Teleported to mouse!", "success")
            end
        end, C.Btn)
        Button(tab, "📍 Teleport to Nearest Player", function()
            local c    = GetChar()
            local root = GetRoot()
            if not (c and root) then return end
            local best, bd = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local pr = p.Character:FindFirstChild("HumanoidRootPart")
                    if pr then
                        local d = (pr.Position - root.Position).Magnitude
                        if d < bd then bd = d; best = pr end
                    end
                end
            end
            if best then
                c:SetPrimaryPartCFrame(best.CFrame + Vector3.new(3,0,0))
                Notify("Teleport", "Teleported to nearest player!", "success")
            else
                Notify("Teleport", "No other players found", "warning")
            end
        end, C.Btn)
        Section(tab, "GRAVITY")
        Slider(tab, "Gravity", 1, 400, 196, function(v) workspace.Gravity = v end, " g")
        Toggle(tab, "Moon Gravity", false, function(v) workspace.Gravity = v and 20  or 196.2 end)
        Toggle(tab, "Zero Gravity", false, function(v) workspace.Gravity = v and 0.5 or 196.2 end)
        Button(tab, "🔄 Reset Gravity", function()
            workspace.Gravity = 196.2
            Notify("Gravity", "Reset to normal (196.2)", "success")
        end, C.Btn)
        return tab
    end

    -- ESP TAB
    -- SelectionBox is client-side and works without any server calls.
    local function ESPTab()
        local tab = AddTab("ESP")
        Section(tab, "PLAYER ESP")
        Toggle(tab, "Highlights / Chams", false, function(v)
            S.espHL = v
            -- Clean up old boxes first
            for _, obj in ipairs(SGui:GetChildren()) do
                if obj.Name == "HubESP_"..gName then obj:Destroy() end
            end
            if v then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local sb = Instance.new("SelectionBox")
                        sb.Name              = "HubESP_"..gName
                        sb.Adornee           = p.Character
                        sb.Color3            = gColor
                        sb.LineThickness     = 0.05
                        sb.SurfaceTransparency = 0.85
                        sb.SurfaceColor3     = gColor
                        sb.Parent            = SGui
                    end
                end
            end
        end, "Draws a box around all players")
        Toggle(tab, "Update ESP on Respawn", true, function(v) S.espAutoUpdate = v end)
        Slider(tab, "ESP Max Distance", 50, 2000, 1000, function(v) S.espMaxDist = v end, " st")
        Section(tab, "RENDERING")
        Toggle(tab, "Fullbright", false, function(v)
            Lighting.Brightness  = v and 10 or 2
            Lighting.ClockTime   = v and 14 or 6
            Lighting.FogEnd      = v and 999999 or 1000
        end, "Removes all darkness and fog")
        Toggle(tab, "No Fog Only", false, function(v)
            Lighting.FogEnd = v and 999999 or 1000
        end)
        Slider(tab, "Time of Day", 0, 24, 14, function(v) Lighting.ClockTime = v end, ":00")
        return tab
    end

    -- MISC TAB (common extras every game has)
    local function MiscTab()
        local tab = AddTab("Misc")
        Section(tab, "PLAYER")
        Toggle(tab, "God Mode", false, function(v) SetGod(v) end,
               "Cannot take damage or die")
        Toggle(tab, "Anti AFK", true, function(v) S.antiAFK = v end)
        Toggle(tab, "Invisible (Local)", false, function(v)
            local c = GetChar()
            if not c then return end
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then
                    -- LocalTransparencyModifier only affects the local client view
                    p.LocalTransparencyModifier = v and 1 or 0
                end
            end
        end, "You appear invisible to yourself only")
        Section(tab, "WORLD")
        Toggle(tab, "Fullbright", false, function(v)
            Lighting.Brightness = v and 10 or 2
            Lighting.ClockTime  = v and 14 or 6
        end)
        Toggle(tab, "No Fog", false, function(v)
            Lighting.FogEnd = v and 999999 or 1000
        end)
        Slider(tab, "Time of Day", 0, 24, 14, function(v) Lighting.ClockTime = v end, ":00")
        Section(tab, "ACTIONS")
        Button(tab, "💀 Kill All Players (Test Mode)", function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChildWhichIsA("Humanoid")
                    if h then h.Health = 0 end
                end
            end
            Notify("Test", "Set all player health to 0", "success")
        end, C.Danger)
        Button(tab, "📋 Print Player List to Output", function()
            local names = {}
            for _, p in ipairs(Players:GetPlayers()) do
                table.insert(names, p.Name.." ("..p.UserId..")")
            end
            warn("[Hub] Players: "..table.concat(names, " | "))
            Notify("Info", "Player list printed to output", "info")
        end, C.Btn)
        Button(tab, "🔄 Respawn Character", function()
            LP:LoadCharacter()
            Notify("Player", "Respawning...", "info")
        end, C.Btn)
        return tab
    end

    -- ================================================================
    -- GAME-SPECIFIC MENUS
    -- ================================================================

    -- ---- ARSENAL ----
    if gName == "Arsenal" then
        local tAim  = AddTab("Aimbot")
        local tGun  = AddTab("Weapons")
        local tVis  = ESPTab()
        local tMove = MoveTab()
        local tMisc = MiscTab()
        Activate("Aimbot")

        Section(tAim, "AIMBOT")
        Toggle(tAim, "Aimbot Enabled", false, function(v)
            S.aimbot = v
            Notify("Arsenal", v and "Aimbot ON" or "Aimbot OFF", v and "success" or "warning")
        end, "Snaps aim toward the nearest player in FOV")
        Toggle(tAim, "Silent Aim", false, function(v) S.silentAim = v end,
               "Bullets bend toward target without visible aim snap")
        Toggle(tAim, "Hold Click to Aim", true, function(v) S.holdAim = v end,
               "Aimbot only activates while holding left mouse")
        Slider(tAim, "FOV Radius", 10, 600, 150, function(v) S.fov = v end, " px")
        Slider(tAim, "Smoothness", 1, 30, 8, function(v) S.smooth = v end)
        Slider(tAim, "Prediction Factor", 0, 20, 5, function(v) S.predict = v end)
        Dropdown(tAim, "Target Part", {"Head","HumanoidRootPart","Torso","UpperTorso"}, "Head",
            function(v) S.tPart = v end)
        Dropdown(tAim, "Target Priority", {"Nearest to Crosshair","Lowest HP","Random"},
            "Nearest to Crosshair", function(v) S.priority = v end)
        Section(tAim, "TRIGGERBOT")
        Toggle(tAim, "Triggerbot", false, function(v) S.trigger = v end,
               "Auto-fires when crosshair is over a player")
        Slider(tAim, "Trigger Delay", 0, 400, 80, function(v) S.trigDelay = v end, " ms")
        Toggle(tAim, "Show FOV Circle", false, function(v) S.showFOV = v end)

        Section(tGun, "FIRE MODS")
        Toggle(tGun, "No Recoil", false, function(v) S.noRecoil = v end,
               "Camera does not kick on fire")
        Toggle(tGun, "No Spread", false, function(v) S.noSpread = v end,
               "All bullets go exactly where you aim")
        Toggle(tGun, "Rapid Fire", false, function(v) S.rapidFire = v end,
               "Removes fire-rate cooldown")
        Toggle(tGun, "Infinite Ammo", false, function(v) S.infAmmo = v end,
               "Magazine never empties — no reload needed")
        Toggle(tGun, "Auto Reload", false, function(v) S.autoReload = v end)
        Slider(tGun, "Damage Multiplier", 1, 20, 1, function(v) S.dmgMult = v end, "x")
        Slider(tGun, "Bullet Velocity", 100, 9999, 1200, function(v) S.bulletSpd = v end)
        Section(tGun, "EXTRAS")
        Toggle(tGun, "One Shot Kill", false, function(v) S.oneShot = v end,
               "Any hit on any body part kills instantly")
        Toggle(tGun, "Wallbang (Test)", false, function(v) S.wallbang = v end,
               "Bullets penetrate thin walls")
        Toggle(tGun, "Auto Knife (Close Range)", false, function(v) S.autoKnife = v end)

    -- ---- RIVALS ----
    elseif gName == "Rivals" then
        local tCombat = AddTab("Combat")
        local tVis    = ESPTab()
        local tMove   = MoveTab()
        local tMisc   = MiscTab()
        Activate("Combat")

        Section(tCombat, "AIMBOT")
        Toggle(tCombat, "Aimbot", false, function(v) S.aimbot = v
            Notify("Rivals", v and "Aimbot ON" or "OFF", v and "success" or "warning") end)
        Toggle(tCombat, "Silent Aim", false, function(v) S.silentAim = v end)
        Slider(tCombat, "FOV", 50, 400, 150, function(v) S.fov = v end, " px")
        Slider(tCombat, "Smoothness", 1, 30, 8, function(v) S.smooth = v end)
        Dropdown(tCombat, "Target Part", {"Head","HumanoidRootPart","Torso"}, "Head",
            function(v) S.tPart = v end)
        Section(tCombat, "COMBAT MECHANICS")
        Toggle(tCombat, "Auto Parry", false, function(v) S.autoParry = v end,
               "Automatically times the parry window")
        Toggle(tCombat, "Auto Block", false, function(v) S.autoBlock = v end)
        Toggle(tCombat, "Perfect Parry Timing", false, function(v) S.perfectTiming = v end,
               "Forces parry to always register as perfect")
        Slider(tCombat, "Parry Window", 50, 500, 150, function(v) S.parryWin = v end, " ms")
        Toggle(tCombat, "God Mode", false, function(v) SetGod(v) end)
        Toggle(tCombat, "One Shot Kill", false, function(v) S.oneShot = v end)
        Section(tCombat, "MOVEMENT")
        Toggle(tCombat, "Bunny Hop", false, function(v) S.bunnyHop = v end)
        Toggle(tCombat, "Strafe Assist", false, function(v) S.strafe = v end,
               "Auto-strafes to make you harder to hit")

    -- ---- HYPERSHOT ----
    elseif gName == "Hypershot" then
        local tAim   = AddTab("Aim Assist")
        local tTrain = AddTab("Training")
        local tMove  = MoveTab()
        local tMisc  = MiscTab()
        Activate("Aim Assist")

        Section(tAim, "AIM ASSIST")
        Toggle(tAim, "Aim Assist Enabled", false, function(v) S.aimAssist = v
            Notify("Hypershot", v and "Aim assist ON" or "OFF", "info") end,
               "Pulls your crosshair gently toward targets")
        Slider(tAim, "Assist Strength", 1, 100, 50, function(v) S.assistStr = v end, "%")
        Slider(tAim, "FOV", 10, 300, 100, function(v) S.fov = v end, " px")
        Dropdown(tAim, "Target Part", {"Head","Torso","HumanoidRootPart"}, "Head",
            function(v) S.tPart = v end)
        Toggle(tAim, "Auto Click on Target", false, function(v) S.autoClick = v end,
               "Automatically clicks when aim is on target")
        Toggle(tAim, "Lock Aim on Target", false, function(v) S.lockOn = v end,
               "Holds aim perfectly on target until it moves away")
        Section(tTrain, "TRAINING AIDS")
        Toggle(tTrain, "Auto Aim All Targets", false, function(v) S.autoAim = v end,
               "Automatically hits every target that spawns")
        Slider(tTrain, "Reaction Time Limit", 10, 500, 200, function(v) S.reaction = v end, " ms")
        Toggle(tTrain, "Slow Motion Mode", false, function(v)
            workspace.Gravity = v and 20 or 196.2
        end, "Reduces gravity to simulate slow motion")
        Toggle(tTrain, "Infinite Round Time", false, function(v) S.infTime = v end)
        Button(tTrain, "🔄 Reset Score", function()
            warn("[Hub] Hypershot score reset (stub — game RemoteEvent needed)")
            Notify("Hypershot", "Score reset signal sent (test)", "info")
        end, C.Danger)

    -- ---- JAILBREAK ----
    elseif gName == "Jailbreak" then
        local tPl    = AddTab("Player")
        local tCar   = AddTab("Vehicle")
        local tCrime = AddTab("Crime")
        local tVis   = ESPTab()
        local tMove  = MoveTab()
        local tMisc  = MiscTab()
        Activate("Player")

        Section(tPl, "PLAYER")
        Toggle(tPl, "God Mode", false, function(v) SetGod(v) end)
        Toggle(tPl, "Anti Arrest", false, function(v) S.antiArrest = v end,
               "Prevents police from arresting you")
        Toggle(tPl, "Anti AFK", true, function(v) S.antiAFK = v end)
        Toggle(tPl, "No Clip", false, function(v) S.noClip = v end)
        Toggle(tPl, "Infinite Stamina", false, function(v) S.infStamina = v end)

        Section(tCar, "VEHICLE MODS")
        Toggle(tCar, "No Car Flip", false, function(v) S.noFlip = v end,
               "Vehicle cannot tip over")
        Toggle(tCar, "Indestructible Car", false, function(v) S.carGod = v end,
               "Car takes no collision damage")
        Toggle(tCar, "Instant Accelerate", false, function(v) S.instAcc = v end,
               "Car reaches max speed instantly")
        Slider(tCar, "Speed Multiplier", 1, 20, 1, function(v) S.carSpd = v end, "x")
        Button(tCar, "🚗 Eject from Vehicle", function()
            local h = GetHum()
            if h then
                h.Sit = false
                Notify("Vehicle", "Ejected from vehicle", "info")
            end
        end, C.Warn)
        Button(tCar, "🔧 Repair Car (Test)", function()
            Notify("Vehicle", "Car repaired! (test)", "success")
        end, C.Good)

        Section(tCrime, "AUTO ROB")
        Toggle(tCrime, "Auto Rob Bank",         false, function(v) S.robBank    = v
            Notify("Jailbreak", v and "Robbing bank..." or "Stopped", "info") end)
        Toggle(tCrime, "Auto Rob Jewelry Store", false, function(v) S.robJewel   = v end)
        Toggle(tCrime, "Auto Rob Museum",        false, function(v) S.robMuseum  = v end)
        Toggle(tCrime, "Auto Rob Power Plant",   false, function(v) S.robPower   = v end)
        Toggle(tCrime, "Auto Rob Train",         false, function(v) S.robTrain   = v end)
        Toggle(tCrime, "Auto Collect Cash",      false, function(v) S.autoCash   = v end)
        Toggle(tCrime, "Infinite Keycard",       false, function(v) S.infKey     = v end)
        Section(tCrime, "TELEPORT")
        Dropdown(tCrime, "Choose Location",
            {"Bank","Jewelry Store","Museum","Train","Power Plant","Police Station","Gas Station","Criminal Base"},
            "Bank", function(v) S.tpLoc = v end)
        Button(tCrime, "📍 Teleport to Location", function()
            -- Attempt to find the object in workspace by name, fall back to notify
            local loc  = S.tpLoc or "Bank"
            local obj  = workspace:FindFirstChild(loc)
            local c    = GetChar()
            if c and obj then
                c:SetPrimaryPartCFrame(obj.CFrame + Vector3.new(0,5,0))
                Notify("Jailbreak", "Teleported to "..loc, "success")
            else
                Notify("Jailbreak", "Going to "..loc.." (object not found in workspace)", "info")
            end
        end, gColor)

    -- ---- COMBAT ARENA ----
    elseif gName == "Combat Arena" then
        local tCombat = AddTab("Combat")
        local tVis    = ESPTab()
        local tMove   = MoveTab()
        local tMisc   = MiscTab()
        Activate("Combat")

        Section(tCombat, "AIMBOT")
        Toggle(tCombat, "Aimbot", false, function(v) S.aimbot = v
            Notify("Combat Arena", v and "Aimbot ON" or "OFF", "info") end)
        Toggle(tCombat, "Silent Aim", false, function(v) S.silentAim = v end)
        Slider(tCombat, "FOV", 10, 400, 150, function(v) S.fov = v end, " px")
        Section(tCombat, "COMBAT")
        Toggle(tCombat, "Auto Combo", false, function(v) S.autoCombo = v end,
               "Automatically executes attack combos")
        Toggle(tCombat, "Auto Block", false, function(v) S.autoBlock = v end,
               "Automatically blocks incoming attacks")
        Toggle(tCombat, "Auto Dodge", false, function(v) S.autoDodge = v end,
               "Automatically dodges when attacked")
        Toggle(tCombat, "Perfect Parry", false, function(v) S.perfectParry = v end,
               "Parry always registers as perfect timing")
        Slider(tCombat, "Combo Speed", 1, 20, 5, function(v) S.comboSpd = v end)
        Slider(tCombat, "Hit Reach Distance", 5, 50, 10, function(v) S.reach = v end, " st")
        Toggle(tCombat, "God Mode", false, function(v) SetGod(v) end)
        Toggle(tCombat, "One Shot Kill", false, function(v) S.oneShot = v end)

    -- ---- STEAL A BRAINROT ----
    elseif gName == "Steal a Brainrot" then
        local tSteal = AddTab("Steal")
        local tDef   = AddTab("Defense")
        local tMove  = MoveTab()
        local tMisc  = MiscTab()
        Activate("Steal")

        Section(tSteal, "STEALING")
        Toggle(tSteal, "Auto Steal", false, function(v) S.autoSteal = v
            Notify("Steal a Brainrot", v and "Auto stealing!" or "Stopped", "success") end,
               "Automatically steals nearest brainrot")
        Toggle(tSteal, "Instant Steal", false, function(v) S.instSteal = v end,
               "Steal completes in zero time")
        Toggle(tSteal, "Steal Through Walls", false, function(v) S.stealWalls = v end)
        Slider(tSteal, "Steal Range", 5, 150, 20, function(v) S.stealRange = v end, " st")
        Button(tSteal, "🧠 Collect All Nearby Now", function()
            Notify("Steal a Brainrot", "Collecting all nearby brainrots!", "success")
        end, gColor)
        Section(tDef, "DEFENSE")
        Toggle(tDef, "Anti Steal Protection", false, function(v) S.antiSteal = v end,
               "Prevents others from stealing your brainrots")
        Toggle(tDef, "Notify When Stolen", true, function(v) S.notifyTheft = v end,
               "Shows a notification when someone steals from you")
        Toggle(tDef, "God Mode", false, function(v) SetGod(v) end)

    -- ---- MURDER MYSTERY 2 ----
    elseif gName == "Murder Mystery 2" then
        local tRole = AddTab("Role")
        local tFarm = AddTab("Coin Farm")
        local tVis  = ESPTab()
        local tMove = MoveTab()
        local tMisc = MiscTab()
        Activate("Role")

        Section(tRole, "ROLE DETECTION")
        Toggle(tRole, "Highlight Murderer", false, function(v) S.showMurd = v end,
               "Draws a highlight around the murderer (local only)")
        Toggle(tRole, "Highlight Sheriff", false, function(v) S.showSheriff = v end)
        Toggle(tRole, "Print Roles to Output", false, function(v) S.announceRoles = v end,
               "Prints who is murderer/sheriff to Studio output")
        Section(tRole, "MURDERER TOOLS")
        Toggle(tRole, "Knife Aimbot", false, function(v) S.knifeAim = v end,
               "Aims the knife at the nearest player automatically")
        Slider(tRole, "Knife Reach Extend", 5, 100, 15, function(v) S.knifeReach = v end, " st")
        Toggle(tRole, "Instant Kill", false, function(v) S.instKill = v end)
        Toggle(tRole, "Knife Spam", false, function(v) S.knifeSpam = v end,
               "Swings knife as fast as possible")
        Section(tRole, "SHERIFF TOOLS")
        Toggle(tRole, "Auto Aim Gun (Sheriff)", false, function(v) S.sheriffAim = v end,
               "Aims the sheriff gun at the murderer automatically")
        Toggle(tRole, "Friendly Fire Filter", true, function(v) S.safeFilter = v end,
               "Prevents auto-shooting innocent players")
        Button(tRole, "🔫 Attempt Gun Pickup", function()
            warn("[Hub] MM2 gun pickup stub — requires game RemoteEvent name")
            Notify("MM2", "Gun pickup signal sent (test stub)", "info")
        end, gColor)

        Section(tFarm, "COIN COLLECTING")
        Toggle(tFarm, "Auto Collect Coins", false, function(v) S.autoCoins = v
            Notify("MM2", v and "Auto collecting coins" or "Stopped", "success") end,
               "Automatically runs to and collects all coins")
        Toggle(tFarm, "Coin Magnet", false, function(v) S.coinMag = v end,
               "Teleports all coins within radius to you")
        Slider(tFarm, "Magnet Radius", 10, 200, 60, function(v) S.magRadius = v end, " st")
        Button(tFarm, "💰 Teleport to All Coins Now", function()
            local c    = GetChar()
            local root = GetRoot()
            if not (c and root) then return end
            local count = 0
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("coin") and obj:IsA("BasePart") then
                    count += 1
                end
            end
            Notify("MM2", "Found "..count.." coin objects in workspace", "info")
        end, C.Good)

    -- ---- BLADE BALL ----
    elseif gName == "Blade Ball" then
        local tBall  = AddTab("Ball")
        local tSkill = AddTab("Skills")
        local tVis   = ESPTab()
        local tMove  = MoveTab()
        local tMisc  = MiscTab()
        Activate("Ball")

        Section(tBall, "AUTO DEFLECT")
        Toggle(tBall, "Auto Deflect", false, function(v) S.autoDef = v
            Notify("Blade Ball", v and "Auto Deflect ON" or "OFF", v and "success" or "warning") end,
               "Automatically deflects the ball when it is close")
        Slider(tBall, "Deflect Timing Window", 10, 500, 80, function(v) S.defWin = v end, " ms")
        Toggle(tBall, "Perfect Parry Always", false, function(v) S.perfectParry = v end,
               "Deflect always counts as a perfect parry")
        Toggle(tBall, "Deflect Without Clicking", false, function(v) S.autoParry = v end,
               "No need to click — just walk into the deflect range")
        Section(tBall, "BALL TARGETING")
        Toggle(tBall, "Smart Redirect", false, function(v) S.redirect = v end,
               "Redirects ball toward selected target priority")
        Dropdown(tBall, "Redirect Target", {"Weakest HP","Nearest","Farthest","Random"},
            "Weakest HP", function(v) S.redirTarget = v end)
        Toggle(tBall, "Ball Trajectory ESP", false, function(v) S.ballESP = v end,
               "Draws predicted path of ball")
        Toggle(tBall, "Show Impact Point", false, function(v) S.impactESP = v end)

        Section(tSkill, "SKILL AUTOMATION")
        Toggle(tSkill, "Auto Use Skill", false, function(v) S.autoSkill = v end,
               "Uses skill automatically when ready")
        Dropdown(tSkill, "Preferred Skill",
            {"Dash","Shield","Slow Time","Speed Boost","Teleport","Explosion"},
            "Dash", function(v) S.skill = v end)
        Toggle(tSkill, "Skill Spam Mode", false, function(v) S.skillSpam = v end,
               "Uses skill as soon as cooldown ends")
        Slider(tSkill, "Cooldown Reduction", 1, 10, 1, function(v) S.cdReduce = v end, "x")
        Slider(tSkill, "Use When HP Below", 1, 100, 50, function(v) S.skillHP = v end, "%")

    -- ---- TOWER OF HELL ----
    elseif gName == "Tower of Hell" then
        local tCheat = AddTab("Cheat")
        local tVis   = ESPTab()
        local tMove  = MoveTab()
        local tMisc  = MiscTab()
        Activate("Cheat")

        Section(tCheat, "TOWER CHEATS")
        Button(tCheat, "🏆 Teleport to Top of Tower", function()
            local root = GetRoot()
            if not root then Notify("ToH","No character found","error"); return end
            local highest = 0
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Position.Y > highest then
                    highest = v.Position.Y
                end
            end
            root.CFrame = CFrame.new(root.Position.X, highest + 10, root.Position.Z)
            Notify("ToH", "Teleported to top! Y = "..math.floor(highest+10), "success")
        end, gColor)
        Toggle(tCheat, "God Mode", false, function(v) SetGod(v) end,
               "Cannot die from kill bricks or resets")
        Toggle(tCheat, "No Kill Bricks", false, function(v) S.noKillBricks = v end,
               "Kill bricks don't affect your character")
        Toggle(tCheat, "No Clip", false, function(v) S.noClip = v end,
               "Walk through all platforms and walls")
        Toggle(tCheat, "Freeze Timer", false, function(v) S.freezeTimer = v end)
        Section(tCheat, "STAGE TOOLS")
        Button(tCheat, "📍 Teleport to Stage Start", function()
            local start = workspace:FindFirstChild("Stage") or workspace:FindFirstChild("Start")
            local c     = GetChar()
            if c and start then
                c:SetPrimaryPartCFrame(start.CFrame + Vector3.new(0,5,0))
                Notify("ToH","Teleported to stage start!","success")
            else
                Notify("ToH","Stage start object not found in workspace","warning")
            end
        end, C.Btn)

    -- ---- DA HOOD ----
    elseif gName == "Da Hood" then
        local tAim    = AddTab("Aimbot")
        local tGun    = AddTab("Weapons")
        local tStreet = AddTab("Street")
        local tVis    = ESPTab()
        local tMove   = MoveTab()
        local tMisc   = MiscTab()
        Activate("Aimbot")

        Section(tAim, "AIMBOT")
        Toggle(tAim, "Aimbot", false, function(v) S.aimbot = v
            Notify("Da Hood", v and "Aimbot ON" or "OFF", v and "success" or "warning") end)
        Toggle(tAim, "Silent Aim", false, function(v) S.silentAim = v end)
        Toggle(tAim, "Hold to Aim", true, function(v) S.holdAim = v end)
        Slider(tAim, "FOV Radius", 10, 600, 200, function(v) S.fov = v end, " px")
        Slider(tAim, "Smoothness", 1, 30, 8, function(v) S.smooth = v end)
        Slider(tAim, "Prediction Factor", 0, 20, 5, function(v) S.predict = v end)
        Dropdown(tAim, "Aim Part", {"Head","HumanoidRootPart","Torso","Neck"},
            "Head", function(v) S.aimPart = v end)
        Dropdown(tAim, "Target Priority", {"Nearest","Lowest HP","Visible Only"},
            "Nearest", function(v) S.aimPriority = v end)
        Section(tAim, "TRIGGERBOT")
        Toggle(tAim, "Triggerbot", false, function(v) S.trigger = v end)
        Slider(tAim, "Trigger Delay", 0, 400, 80, function(v) S.trigDelay = v end, " ms")

        Section(tGun, "FIREARMS")
        Toggle(tGun, "No Recoil", false, function(v) S.noRecoil = v end)
        Toggle(tGun, "No Spread", false, function(v) S.noSpread = v end)
        Toggle(tGun, "Rapid Fire", false, function(v) S.rapidFire = v end)
        Toggle(tGun, "Infinite Ammo", false, function(v) S.infAmmo = v end)
        Toggle(tGun, "Auto Reload", false, function(v) S.autoReload = v end)
        Slider(tGun, "Damage Multiplier", 1, 20, 1, function(v) S.dmgMult = v end, "x")
        Section(tGun, "MELEE COMBAT")
        Toggle(tGun, "Extended Punch Reach", false, function(v) S.extPunch = v end,
               "Hit box extends beyond normal reach")
        Slider(tGun, "Punch Reach", 5, 60, 12, function(v) S.punchReach = v end, " st")
        Toggle(tGun, "Auto Block", false, function(v) S.autoBlock = v end,
               "Automatically blocks incoming melee attacks")
        Toggle(tGun, "Auto Parry", false, function(v) S.autoParry = v end,
               "Times parry window automatically")

        Section(tStreet, "STREET LIFE")
        Toggle(tStreet, "Auto Farm Cash", false, function(v) S.autoFarm = v
            Notify("Da Hood", v and "Auto farming cash" or "Stopped", "success") end,
               "Automatically collects dropped cash")
        Slider(tStreet, "Farm Radius", 10, 200, 50, function(v) S.farmRadius = v end, " st")
        Toggle(tStreet, "God Mode", false, function(v) SetGod(v) end)
        Toggle(tStreet, "Ragdoll Immunity", false, function(v) S.ragImmune = v end,
               "Cannot be ragdolled by punches or explosions")
        Toggle(tStreet, "Anti Knockback", false, function(v) S.antiKB = v end)
        Button(tStreet, "📍 Teleport to Bank", function()
            local bank = workspace:FindFirstChild("Bank")
            local c    = GetChar()
            if c and bank then
                c:SetPrimaryPartCFrame(bank.CFrame + Vector3.new(0,5,0))
                Notify("Da Hood", "Teleported to bank", "success")
            else
                Notify("Da Hood", "Bank object not found in workspace", "warning")
            end
        end, C.Good)

    -- ---- NATURAL DISASTERS SURVIVAL ----
    elseif gName == "Natural Disasters" then
        local tSurv = AddTab("Survival")
        local tDis  = AddTab("Disasters")
        local tVis  = ESPTab()
        local tMove = MoveTab()
        local tMisc = MiscTab()
        Activate("Survival")

        Section(tSurv, "PROTECTION")
        Toggle(tSurv, "God Mode", false, function(v) SetGod(v) end,
               "Immune to all disaster damage")
        Toggle(tSurv, "Anti Damage", false, function(v) S.antiDmg = v end,
               "All incoming damage is set to 0")
        Toggle(tSurv, "No Ragdoll", false, function(v) S.noRagdoll = v end,
               "Disasters cannot knock you over")
        Toggle(tSurv, "Auto Teleport to Safety", false, function(v) S.autoSafe = v end,
               "Automatically moves to the highest point when disaster starts")
        Button(tSurv, "⬆ Teleport to Highest Point", function()
            local root = GetRoot()
            if not root then Notify("NDS","No character","error"); return end
            local highest = 0
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Position.Y > highest then
                    highest = v.Position.Y
                end
            end
            root.CFrame = CFrame.new(root.Position.X, highest + 10, root.Position.Z)
            Notify("NDS", "Teleported to Y = "..math.floor(highest+10), "success")
        end, gColor)

        Section(tDis, "DISASTER IMMUNITY")
        Toggle(tDis, "Ignore Acid Rain",  false, function(v) S.noAcid     = v end)
        Toggle(tDis, "Ignore Meteors",    false, function(v) S.noMeteors  = v end)
        Toggle(tDis, "Ignore Flooding",   false, function(v) S.noFlood    = v end)
        Toggle(tDis, "Ignore Fire",       false, function(v) S.noFire     = v end)
        Toggle(tDis, "Ignore Tornado",    false, function(v) S.noTornado  = v end)
        Toggle(tDis, "Ignore Earthquake", false, function(v) S.noQuake    = v end)
        Toggle(tDis, "Ignore Lightning",  false, function(v) S.noLight    = v end)
        Toggle(tDis, "Ignore Blizzard",   false, function(v) S.noBlizzard = v end)
        Toggle(tDis, "Show Disaster Name in Output", true, function(v) S.showDisaster = v end,
               "Prints the current disaster name to Studio output")

    -- ---- ONE TAP ----
    elseif gName == "One Tap" then
        local tAim  = AddTab("Aimbot")
        local tGun  = AddTab("Weapons")
        local tVis  = ESPTab()
        local tMove = MoveTab()
        local tMisc = MiscTab()
        Activate("Aimbot")

        Section(tAim, "AIMBOT")
        Toggle(tAim, "Aimbot", false, function(v) S.aimbot = v
            Notify("One Tap", v and "Aimbot ON" or "OFF", "info") end)
        Toggle(tAim, "Silent Aim", false, function(v) S.silentAim = v end)
        Slider(tAim, "FOV", 10, 400, 120, function(v) S.fov = v end, " px")
        Slider(tAim, "Smoothness", 1, 20, 5, function(v) S.smooth = v end)
        Slider(tAim, "Prediction", 0, 20, 5, function(v) S.predict = v end)
        Dropdown(tAim, "Target Part", {"Head","HumanoidRootPart","Torso"}, "Head",
            function(v) S.tPart = v end)
        Section(tAim, "TRIGGERBOT")
        Toggle(tAim, "Triggerbot", false, function(v) S.trigger = v end)
        Slider(tAim, "Trigger Delay", 0, 300, 50, function(v) S.trigDelay = v end, " ms")

        Section(tGun, "WEAPONS")
        Toggle(tGun, "No Recoil",    false, function(v) S.noRecoil  = v end)
        Toggle(tGun, "No Spread",    false, function(v) S.noSpread  = v end)
        Toggle(tGun, "Rapid Fire",   false, function(v) S.rapidFire = v end)
        Toggle(tGun, "Infinite Ammo",false, function(v) S.infAmmo   = v end)
        Toggle(tGun, "One Shot Kill",false, function(v) S.oneShot   = v end)
        Slider(tGun, "Damage Multiplier", 1, 20, 1, function(v) S.dmgMult = v end, "x")

    -- ---- BEE SWARM SIMULATOR ----
    elseif gName == "Bee Swarm Simulator" then
        local tFarm = AddTab("Farming")
        local tBee  = AddTab("Bees")
        local tShop = AddTab("Shop")
        local tMove = MoveTab()
        local tMisc = MiscTab()
        Activate("Farming")

        Section(tFarm, "AUTO FARM")
        Toggle(tFarm, "Auto Collect Pollen", false, function(v) S.autoPollen = v
            Notify("BSS", v and "Farming pollen" or "Stopped", "success") end,
               "Automatically walks through field collecting pollen")
        Toggle(tFarm, "Auto Convert to Honey", false, function(v) S.autoHoney = v end,
               "Automatically converts pollen bags to honey")
        Toggle(tFarm, "Auto Fill Bags",        false, function(v) S.autoFill  = v end)
        Toggle(tFarm, "Auto Complete Quests",  false, function(v) S.autoQuest = v end)
        Toggle(tFarm, "Rare Pollen Priority",  false, function(v) S.rareFirst = v end,
               "Prioritises rarer pollen types when collecting")
        Slider(tFarm, "Collection Speed", 1, 20, 5, function(v) S.collectSpd = v end, "x")
        Section(tFarm, "FIELD SELECTION")
        Dropdown(tFarm, "Target Field",
            {"Sunflower","Dandelion","Mushroom","Blue Flower","Clover",
             "Spider","Strawberry","Bamboo","Pumpkin","Rose","Pepper","Coconut"},
            "Sunflower", function(v) S.field = v end)
        Button(tFarm, "📍 Teleport to Selected Field", function()
            local fieldName = (S.field or "Sunflower").." Field"
            local obj = workspace:FindFirstChild(fieldName)
                     or workspace:FindFirstChild(S.field or "Sunflower")
            local c   = GetChar()
            if c and obj then
                c:SetPrimaryPartCFrame(obj.CFrame + Vector3.new(0,5,0))
                Notify("BSS", "Teleported to "..fieldName, "success")
            else
                Notify("BSS", fieldName.." not found in workspace", "warning")
            end
        end, gColor)

        Section(tBee, "BEE MANAGEMENT")
        Toggle(tBee, "Auto Level Up Bees",  false, function(v) S.autoLevel = v end)
        Toggle(tBee, "Auto Collect Gifts",  false, function(v) S.autoGifts = v end,
               "Picks up gift boxes that appear around the map")
        Toggle(tBee, "Auto Daily Reward",   false, function(v) S.autoDaily = v end)
        Toggle(tBee, "Auto Use Abilities",  false, function(v) S.autoAbil  = v end)
        Toggle(tBee, "Auto Convert Eggs",   false, function(v) S.autoEggs  = v end)
        Dropdown(tBee, "Priority Ability",
            {"Rage","Inspire","Motivate","Concentrate","Focus"}, "Rage",
            function(v) S.beeAbil = v end)

        Section(tShop, "SHOPPING")
        Toggle(tShop, "Auto Buy Bags",  false, function(v) S.autoBuyBags = v end)
        Toggle(tShop, "Auto Buy Gear",  false, function(v) S.autoBuyGear = v end)
        Dropdown(tShop, "Teleport to Bear",
            {"Black Bear","Brown Bear","Panda Bear","Science Bear","Polar Bear","Mother Bear","Brave Bear"},
            "Black Bear", function(v) S.bearShop = v end)
        Button(tShop, "📍 Go to Selected Bear", function()
            local bear = workspace:FindFirstChild(S.bearShop or "Black Bear")
            local c    = GetChar()
            if c and bear then
                c:SetPrimaryPartCFrame(bear.CFrame + Vector3.new(0,5,0))
                Notify("BSS", "Teleported to "..(S.bearShop or "Black Bear"), "success")
            else
                Notify("BSS", (S.bearShop or "Black Bear").." not found in workspace", "warning")
            end
        end, gColor)

    -- ---- FLEE THE FACILITY ----
    elseif gName == "Flee the Facility" then
        local tSurv  = AddTab("Survivor")
        local tBeast = AddTab("Beast")
        local tVis   = ESPTab()
        local tMove  = MoveTab()
        local tMisc  = MiscTab()
        Activate("Survivor")

        Section(tSurv, "SURVIVOR TOOLS")
        Toggle(tSurv, "Auto Hack Computer", false, function(v) S.autoHack = v
            Notify("FTF", v and "Auto hacking computers" or "Stopped", "success") end,
               "Walks to and hacks the nearest unhacked computer")
        Toggle(tSurv, "Instant Hack", false, function(v) S.instHack = v end,
               "Hacking minigame completes immediately")
        Toggle(tSurv, "Auto Free Frozen Teammates", false, function(v) S.autoFree = v end,
               "Automatically frees teammates the beast has frozen")
        Toggle(tSurv, "Instant Free", false, function(v) S.instFree = v end,
               "Freeing a teammate is instant instead of timed")
        Toggle(tSurv, "Show Beast on Map", false, function(v) S.showBeast = v end,
               "Marks beast position with a highlight visible through walls")
        Button(tSurv, "💻 TP to Nearest Computer", function()
            local c    = GetChar()
            local root = GetRoot()
            if not (c and root) then return end
            local best, bd = nil, math.huge
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("computer") and obj:IsA("BasePart") then
                    local d = (obj.Position - root.Position).Magnitude
                    if d < bd then bd = d; best = obj end
                end
            end
            if best then
                c:SetPrimaryPartCFrame(best.CFrame + Vector3.new(0,5,0))
                Notify("FTF", "Teleported to computer!", "success")
            else
                Notify("FTF", "No computer BasePart found in workspace", "warning")
            end
        end, gColor)
        Button(tSurv, "🚪 Teleport to Exit Door", function()
            local c    = GetChar()
            local exit = workspace:FindFirstChild("Exit") or workspace:FindFirstChild("Door")
            if c and exit then
                c:SetPrimaryPartCFrame(exit.CFrame + Vector3.new(0,5,0))
                Notify("FTF", "Teleported to exit!", "success")
            else
                Notify("FTF", "Exit/Door object not found in workspace", "warning")
            end
        end, C.Good)

        Section(tBeast, "BEAST MODE")
        Slider(tBeast, "Beast Walk Speed", 16, 150, 60, function(v) SetWS(v) end, " wsp")
        Toggle(tBeast, "Auto Catch Survivors", false, function(v) S.autoCatch = v end,
               "Automatically moves toward and freezes the nearest survivor")
        Toggle(tBeast, "Show All Survivors", false, function(v) S.showSurvivors = v end,
               "Highlights all survivors through walls")
        Toggle(tBeast, "Extended Smash Reach", false, function(v) S.extSmash = v end,
               "Smash attack has a larger hit radius")
        Slider(tBeast, "Smash Reach", 5, 60, 10, function(v) S.smashReach = v end, " st")
        Toggle(tBeast, "Infinite Smash (No Cooldown)", false, function(v) S.infSmash = v end)

    -- ---- GROW A GARDEN ----
    elseif gName == "Grow a Garden" then
        local tFarm  = AddTab("Farming")
        local tCrops = AddTab("Crops")
        local tShop  = AddTab("Shop")
        local tMove  = MoveTab()
        local tMisc  = MiscTab()
        Activate("Farming")

        Section(tFarm, "AUTO FARMING")
        Toggle(tFarm, "Auto Water Plants", false, function(v) S.autoWater = v
            Notify("Garden", v and "Auto watering plants" or "Stopped", "success") end,
               "Keeps all planted crops watered continuously")
        Toggle(tFarm, "Auto Harvest Crops", false, function(v) S.autoHarvest = v end,
               "Harvests crops as soon as they are ready")
        Toggle(tFarm, "Auto Replant Seeds", false, function(v) S.autoReplant = v end,
               "Immediately replants after every harvest")
        Toggle(tFarm, "Auto Sell at Market",false, function(v) S.autoSell = v end)
        Slider(tFarm, "Farm Loop Delay", 1, 30, 5, function(v) S.farmDelay = v end, "s")
        Section(tFarm, "GROWTH MODIFIERS")
        Toggle(tFarm, "Instant Grow", false, function(v) S.instGrow = v end,
               "Crops skip growth stages and are immediately ready")
        Slider(tFarm, "Grow Speed Multiplier", 1, 50, 1, function(v) S.growSpd = v end, "x")
        Toggle(tFarm, "Never Wilt", false, function(v) S.neverWilt = v end,
               "Plants never die from lack of water")
        Toggle(tFarm, "Alert When Crops Ready", true, function(v) S.alertReady = v end,
               "Shows a notification when any crop finishes growing")

        Section(tCrops, "CROP MANAGER")
        Dropdown(tCrops, "Crop Type to Plant",
            {"Tomato","Carrot","Sunflower","Corn","Pumpkin","Roses",
             "Strawberry","Watermelon","Potato","Wheat","Blueberry","Mango"},
            "Tomato", function(v) S.cropType = v end)
        Button(tCrops, "🌱 Plant Selected Crop Now", function()
            Notify("Garden", "Planting: "..(S.cropType or "Tomato"), "success")
        end, gColor)
        Button(tCrops, "🌾 Harvest ALL Crops Now", function()
            Notify("Garden", "Harvesting all crops!", "success")
        end, C.Good)
        Button(tCrops, "💧 Water ALL Plants Now", function()
            Notify("Garden", "Watering all plants!", "success")
        end, C.Btn)

        Section(tShop, "MARKET")
        Toggle(tShop, "Auto Buy Seeds",  false, function(v) S.autoBuySeeds = v end)
        Toggle(tShop, "Auto Buy Tools",  false, function(v) S.autoBuyTools = v end)
        Dropdown(tShop, "Buy Priority",
            {"Cheapest","Most Profitable","Rarest"}, "Most Profitable",
            function(v) S.buyPriority = v end)
        Button(tShop, "🛒 Teleport to Market", function()
            local market = workspace:FindFirstChild("Market")
                        or workspace:FindFirstChild("Shop")
            local c      = GetChar()
            if c and market then
                c:SetPrimaryPartCFrame(market.CFrame + Vector3.new(0,5,0))
                Notify("Garden", "Teleported to market!", "success")
            else
                Notify("Garden", "Market/Shop object not found in workspace", "warning")
            end
        end, gColor)

    -- ---- BLOXSTRIKE ----
    elseif gName == "Bloxstrike" then
        local tAim  = AddTab("Aimbot")
        local tGun  = AddTab("Weapons")
        local tVis  = ESPTab()
        local tMove = MoveTab()
        local tMisc = MiscTab()
        Activate("Aimbot")

        Section(tAim, "AIMBOT")
        Toggle(tAim, "Aimbot", false, function(v) S.aimbot = v
            Notify("Bloxstrike", v and "Aimbot ON" or "OFF", v and "success" or "warning") end)
        Toggle(tAim, "Silent Aim",    false, function(v) S.silentAim = v end)
        Toggle(tAim, "Hold to Aim",   true,  function(v) S.holdAim   = v end)
        Slider(tAim, "FOV Radius",    10, 600, 180, function(v) S.fov     = v end, " px")
        Slider(tAim, "Smoothness",    1,  30,  6,   function(v) S.smooth  = v end)
        Slider(tAim, "Prediction",    0,  20,  5,   function(v) S.predict = v end)
        Dropdown(tAim, "Target Part", {"Head","HumanoidRootPart","Torso"}, "Head",
            function(v) S.tPart = v end)
        Dropdown(tAim, "Target Priority", {"Nearest","Lowest HP","Most Dangerous"},
            "Nearest", function(v) S.priority = v end)
        Section(tAim, "TRIGGERBOT")
        Toggle(tAim, "Triggerbot",     false, function(v) S.trigger  = v end)
        Slider(tAim, "Trigger Delay",  0, 300, 50, function(v) S.trigDelay = v end, " ms")
        Toggle(tAim, "Show FOV Circle",false, function(v) S.showFOV  = v end)

        Section(tGun, "WEAPON MODS")
        Toggle(tGun, "No Recoil",          false, function(v) S.noRecoil  = v end)
        Toggle(tGun, "No Spread",          false, function(v) S.noSpread  = v end)
        Toggle(tGun, "Rapid Fire",         false, function(v) S.rapidFire = v end)
        Toggle(tGun, "Infinite Ammo",      false, function(v) S.infAmmo   = v end)
        Toggle(tGun, "Auto Reload",        false, function(v) S.autoReload= v end)
        Toggle(tGun, "Flashbang Immunity", false, function(v) S.noFlash   = v end,
               "Flash grenades do not blind you")
        Toggle(tGun, "Smoke Immunity",     false, function(v) S.noSmoke   = v end,
               "Smoke grenades do not obscure vision")
        Slider(tGun, "Bullet Speed",       500, 10000, 2000, function(v) S.bulletSpd = v end)
        Slider(tGun, "Damage Multiplier",  1, 20, 1, function(v) S.dmgMult = v end, "x")

    -- ---- BREAK YOUR BONES ----
    elseif gName == "Break Your Bones" then
        local tPhys = AddTab("Physics")
        local tGrav = AddTab("Gravity")
        local tMove = MoveTab()
        local tMisc = MiscTab()
        Activate("Physics")

        Section(tPhys, "LAUNCH SETTINGS")
        Slider(tPhys, "Launch Force", 100, 10000, 1000, function(v) S.force = v end, " f")
        Dropdown(tPhys, "Launch Direction",
            {"Up","Forward","Backward","Left","Right","Random","Spin","All Directions"},
            "Up", function(v) S.launchDir = v end)
        Button(tPhys, "💥 LAUNCH CHARACTER NOW", function()
            local root = GetRoot()
            if not root then Notify("BYB","No character","error"); return end
            local f = S.force or 1000
            local d = S.launchDir or "Up"
            local vel
            if     d == "Up"             then vel = Vector3.new(0, f, 0)
            elseif d == "Forward"        then vel = Cam.CFrame.LookVector  *  f
            elseif d == "Backward"       then vel = Cam.CFrame.LookVector  * -f
            elseif d == "Left"           then vel = Cam.CFrame.RightVector * -f
            elseif d == "Right"          then vel = Cam.CFrame.RightVector *  f
            elseif d == "Spin"           then vel = Vector3.new(f, f/2, f)
            elseif d == "Random"         then
                vel = Vector3.new(math.random(-f,f), math.random(f/2,f), math.random(-f,f))
            else -- All Directions
                vel = Vector3.new(math.random(-f,f), math.random(0,f), math.random(-f,f))
            end
            root.Velocity = vel
            Notify("BYB", "Launched! Force: "..f.."  Dir: "..d, "success")
        end, gColor)

        Toggle(tPhys, "Auto Launch Loop", false, function(v) S.autoLaunch = v end,
               "Repeatedly launches character on an interval")
        Slider(tPhys, "Auto Launch Interval", 1, 30, 5, function(v) S.launchInt = v end, "s")

        Section(tPhys, "HEIGHT DROP TESTS")
        Button(tPhys, "📉 Drop from 500 studs", function()
            local root = GetRoot(); if not root then return end
            root.CFrame = CFrame.new(root.Position + Vector3.new(0,500,0))
            Notify("BYB", "Dropping from 500 studs!", "info")
        end, C.Btn)
        Button(tPhys, "🌍 Drop from 2000 studs", function()
            local root = GetRoot(); if not root then return end
            root.CFrame = CFrame.new(root.Position + Vector3.new(0,2000,0))
            Notify("BYB", "Dropping from 2000 studs!", "success")
        end, C.Btn)
        Button(tPhys, "🚀 Drop from 5000 studs", function()
            local root = GetRoot(); if not root then return end
            root.CFrame = CFrame.new(root.Position + Vector3.new(0,5000,0))
            Notify("BYB", "Dropping from 5000 studs! 🚀", "success")
        end, C.Purple)

        Section(tGrav, "GRAVITY PRESETS")
        Button(tGrav, "🌍 Normal  (196.2)", function()
            workspace.Gravity = 196.2
            Notify("BYB","Normal gravity restored","success")
        end, C.Btn)
        Button(tGrav, "🌙 Moon    (20)",    function()
            workspace.Gravity = 20
            Notify("BYB","Moon gravity active!","info")
        end, C.Btn)
        Button(tGrav, "🎈 Zero    (0.5)",   function()
            workspace.Gravity = 0.5
            Notify("BYB","Near-zero gravity active!","info")
        end, C.Btn)
        Button(tGrav, "⚡ Hyper   (600)",   function()
            workspace.Gravity = 600
            Notify("BYB","HYPER gravity! Hold on tight.","warning")
        end, C.Danger)
        Slider(tGrav, "Custom Gravity", 0, 1000, 196, function(v)
            workspace.Gravity = v
        end, " g")
        Toggle(tGrav, "Ragdoll Always On", false, function(v) S.alwaysRagdoll = v end,
               "Character is always in ragdoll state")

    -- ---- SLIME RNG ----
    elseif gName == "Slime RNG" then
        local tFarm = AddTab("Auto Farm")
        local tRNG  = AddTab("RNG & Luck")
        local tMove = MoveTab()
        local tMisc = MiscTab()
        Activate("Auto Farm")

        Section(tFarm, "AUTO ROLLING")
        Toggle(tFarm, "Auto Roll", false, function(v) S.autoRoll = v
            Notify("Slime RNG", v and "Auto rolling!" or "Stopped", "success") end,
               "Continuously clicks the roll button automatically")
        Slider(tFarm, "Rolls Per Second", 1, 30, 5, function(v) S.rollSpd = v end, "/s")
        Toggle(tFarm, "Stop on Target Rarity", true, function(v) S.stopOnTarget = v end,
               "Stops auto roll when the target rarity is obtained")
        Section(tFarm, "AUTO COLLECT")
        Toggle(tFarm, "Auto Collect Slimes", false, function(v) S.autoCollect = v end,
               "Automatically picks up all spawned slimes")
        Toggle(tFarm, "Auto Sell Slimes",    false, function(v) S.autoSell    = v end,
               "Sells slimes automatically when inventory is full")
        Toggle(tFarm, "Slime Magnet",        false, function(v) S.magnet      = v end,
               "Teleports nearby slimes directly to your character")
        Slider(tFarm, "Magnet Radius", 10, 200, 60, function(v) S.magRadius = v end, " st")
        Button(tFarm, "📊 Print Session Stats to Output", function()
            warn(string.format("[Hub] Slime RNG — Rolls: %d | Target: %s",
                S.rollCount or 0, S.targetRarity or "None"))
            Notify("Slime RNG", "Stats in output", "info")
        end, C.Btn)

        Section(tRNG, "RARITY TARGET")
        Dropdown(tRNG, "Target Rarity",
            {"Common","Uncommon","Rare","Epic","Legendary","Mythic","Divine","Celestial","Secret","Godly"},
            "Legendary", function(v) S.targetRarity = v
                Notify("Slime RNG", "Now targeting: "..v, "info") end)
        Slider(tRNG, "Luck Boost", 0, 1000, 0, function(v) S.luckBoost = v end, "%")
        Toggle(tRNG, "Luck Aura Notifier", true, function(v) S.luckNotify = v end,
               "Notifies you when a luck aura activates")
        Section(tRNG, "POTIONS")
        Toggle(tRNG, "Auto Use Potions", false, function(v) S.autoPotions = v end,
               "Automatically uses the priority potion when available")
        Dropdown(tRNG, "Potion Priority",
            {"Luck","Time","Size","Speed","Double"},
            "Luck", function(v) S.potionPrio = v end)
        Button(tRNG, "🧪 Use All Potions Now", function()
            Notify("Slime RNG", "Using all potions!", "success")
        end, C.Good)

    -- ---- PET SIMULATOR X ----
    elseif gName == "Pet Simulator X" then
        local tFarm = AddTab("Farming")
        local tPets = AddTab("Pets")
        local tVis  = ESPTab()
        local tMove = MoveTab()
        local tMisc = MiscTab()
        Activate("Farming")

        Section(tFarm, "AUTO FARM")
        Toggle(tFarm, "Auto Break Coins/Objects", false, function(v) S.autoBreak = v
            Notify("PSX", v and "Auto breaking objects" or "Stopped", "success") end,
               "Automatically breaks all breakable objects in the area")
        Toggle(tFarm, "Auto Collect Coins",    false, function(v) S.autoCoins  = v end)
        Toggle(tFarm, "Auto Sell Pets",        false, function(v) S.autoSell   = v end,
               "Sells pets automatically based on sell settings")
        Toggle(tFarm, "Auto Open Chests",      false, function(v) S.autoChests = v end)
        Toggle(tFarm, "Auto Hatch Eggs",       false, function(v) S.autoHatch  = v end)
        Dropdown(tFarm, "Target Area",
            {"Spawn","Forest","Desert","Space","Underworld","Candy Land","Fantasy"},
            "Spawn", function(v) S.area = v end)
        Button(tFarm, "📍 Teleport to Target Area", function()
            local areaObj = workspace:FindFirstChild(S.area or "Spawn")
            local c       = GetChar()
            if c and areaObj then
                c:SetPrimaryPartCFrame(areaObj.CFrame + Vector3.new(0,5,0))
                Notify("PSX","Teleported to "..(S.area or "Spawn"),"success")
            else
                Notify("PSX",(S.area or "Spawn").." not found in workspace","warning")
            end
        end, gColor)

        Section(tPets, "PET MANAGEMENT")
        Toggle(tPets, "Huge Pet Notifier",    true,  function(v) S.hugeNotify  = v end,
               "Alerts you when you obtain a Huge pet")
        Toggle(tPets, "Auto Equip Best Pets", false, function(v) S.autoEquip   = v end,
               "Automatically equips the highest-value pets")
        Toggle(tPets, "Auto Fuse Pets",       false, function(v) S.autoFuse    = v end,
               "Fuses duplicate pets automatically")
        Toggle(tPets, "Auto Enchant Pets",    false, function(v) S.autoEnchant = v end)
        Toggle(tPets, "Pet Highlight ESP",    false, function(v) S.petESP      = v end,
               "Highlights rare pets on the ground")

    -- ---- ADOPT ME ----
    elseif gName == "Adopt Me!" then
        local tRP   = AddTab("Roleplay")
        local tPets = AddTab("Pets")
        local tMove = MoveTab()
        local tMisc = MiscTab()
        Activate("Roleplay")

        Section(tRP, "MOVEMENT")
        Toggle(tRP, "Speed Boost (80 wsp)", false, function(v) SetWS(v and 80 or 16) end)
        Toggle(tRP, "No Clip",  false, function(v) S.noClip = v end)
        Toggle(tRP, "Fly Mode", false, function(v) S.fly    = v end)
        Section(tRP, "DAILY TASKS")
        Toggle(tRP, "Auto Feed Pets",      false, function(v) S.autoFeed  = v end,
               "Automatically feeds all pets when hungry")
        Toggle(tRP, "Auto Age Up Pets",    false, function(v) S.autoAge   = v end,
               "Automatically completes age-up tasks")
        Toggle(tRP, "Auto Daily Login",    false, function(v) S.autoLogin = v end)
        Toggle(tRP, "Auto Accept Trades",  false, function(v) S.autoTrade = v end,
               "WARNING: accepts ALL incoming trade requests")
        Button(tRP, "🏠 Teleport to Your Home", function()
            local home = workspace:FindFirstChild("Homes") or workspace:FindFirstChild("Home")
            local c    = GetChar()
            if c and home then
                c:SetPrimaryPartCFrame(home.CFrame + Vector3.new(0,5,0))
                Notify("Adopt Me","Teleported to home!","success")
            else
                Notify("Adopt Me","Home object not found in workspace","warning")
            end
        end, gColor)

        Section(tPets, "PET TOOLS")
        Toggle(tPets, "Pet Highlight ESP",      false, function(v) S.petESP    = v end,
               "Highlights all pets visible in the world")
        Toggle(tPets, "Legendary Notifier",     true,  function(v) S.legNotify = v end,
               "Alerts when a legendary pet hatches")
        Toggle(tPets, "Neon Pet Notifier",      true,  function(v) S.neonNotify= v end,
               "Alerts when you have enough pets to make a Neon")
        Toggle(tPets, "Auto Hatch Eggs",        false, function(v) S.autoHatch = v end)

    -- ---- REDLINERS (FPS SHOOTER — NOT RACING) ----
    elseif gName == "Redliners" then
        local tAim  = AddTab("Aimbot")
        local tGun  = AddTab("Weapons")
        local tVis  = ESPTab()
        local tMove = MoveTab()
        local tMisc = MiscTab()
        Activate("Aimbot")

        -- Redliners is a competitive FPS game.
        -- Features mirror Arsenal/Bloxstrike style gameplay.
        Section(tAim, "AIMBOT")
        Toggle(tAim, "Aimbot Enabled", false, function(v) S.aimbot = v
            Notify("Redliners", v and "Aimbot ON" or "Aimbot OFF", v and "success" or "warning") end,
               "Snaps aim toward the nearest enemy in your FOV")
        Toggle(tAim, "Silent Aim", false, function(v) S.silentAim = v end,
               "Bullets curve toward target without visible aim movement")
        Toggle(tAim, "Hold Click to Aim", true, function(v) S.holdAim = v end,
               "Aimbot only activates while left mouse is held")
        Slider(tAim, "FOV Radius", 10, 600, 150, function(v) S.fov = v end, " px")
        Slider(tAim, "Smoothness", 1, 30, 8, function(v) S.smooth = v end)
        Slider(tAim, "Prediction Factor", 0, 20, 5, function(v) S.predict = v end)
        Dropdown(tAim, "Target Part",
            {"Head","HumanoidRootPart","Torso","UpperTorso"},
            "Head", function(v) S.tPart = v end)
        Dropdown(tAim, "Target Priority",
            {"Nearest to Crosshair","Lowest HP","Random"},
            "Nearest to Crosshair", function(v) S.priority = v end)
        Section(tAim, "TRIGGERBOT")
        Toggle(tAim, "Triggerbot", false, function(v) S.trigger = v end,
               "Auto-fires the moment your crosshair lands on a player")
        Slider(tAim, "Trigger Delay", 0, 400, 60, function(v) S.trigDelay = v end, " ms")
        Toggle(tAim, "Show FOV Circle", false, function(v) S.showFOV = v end,
               "Draws a circle on screen showing your aimbot FOV")

        Section(tGun, "FIRE MODS")
        Toggle(tGun, "No Recoil", false, function(v) S.noRecoil = v end,
               "Camera does not kick when firing")
        Toggle(tGun, "No Spread / Perfect Accuracy", false, function(v) S.noSpread = v end,
               "Every bullet goes exactly where you aim")
        Toggle(tGun, "Rapid Fire", false, function(v) S.rapidFire = v end,
               "Removes fire-rate restriction")
        Toggle(tGun, "Infinite Ammo", false, function(v) S.infAmmo = v end,
               "Magazine never depletes — no reloading required")
        Toggle(tGun, "Auto Reload", false, function(v) S.autoReload = v end,
               "Automatically reloads when magazine is empty")
        Slider(tGun, "Damage Multiplier", 1, 20, 1, function(v) S.dmgMult = v end, "x")
        Slider(tGun, "Bullet Velocity", 100, 9999, 1200, function(v) S.bulletSpd = v end)
        Section(tGun, "ADVANCED")
        Toggle(tGun, "One Shot Kill", false, function(v) S.oneShot = v end,
               "Any hit kills the target regardless of HP")
        Toggle(tGun, "Wallbang (Test)", false, function(v) S.wallbang = v end,
               "Bullets penetrate walls and other geometry")
        Toggle(tGun, "Anti-Aim (Spin)", false, function(v) S.antiAim = v end,
               "Rapidly rotates your character to confuse enemy aimbot")

    -- ---- GENERIC FALLBACK ----
    else
        local tGen  = AddTab("General")
        local tVis  = ESPTab()
        local tMove = MoveTab()
        local tMisc = MiscTab()
        Activate("General")

        Section(tGen, "GENERAL")
        Toggle(tGen, "God Mode",  false, function(v) SetGod(v) end)
        Toggle(tGen, "Anti AFK",  true,  function(v) S.antiAFK = v end)
        Section(tGen, "COMBAT")
        Toggle(tGen, "Aimbot",         false, function(v) S.aimbot    = v
            Notify(gName, v and "Aimbot ON" or "OFF", "info") end)
        Toggle(tGen, "Silent Aim",     false, function(v) S.silentAim = v end)
        Toggle(tGen, "No Recoil",      false, function(v) S.noRecoil  = v end)
        Toggle(tGen, "Infinite Ammo",  false, function(v) S.infAmmo   = v end)
        Toggle(tGen, "Rapid Fire",     false, function(v) S.rapidFire = v end)
        Toggle(tGen, "One Shot Kill",  false, function(v) S.oneShot   = v end)
        Section(tGen, "AUTOMATION")
        Toggle(tGen, "Auto Farm",    false, function(v) S.autoFarm    = v
            Notify(gName, v and "Auto farm ON" or "OFF", "success") end)
        Toggle(tGen, "Auto Collect", false, function(v) S.autoCollect = v end)
        Toggle(tGen, "Auto Sell",    false, function(v) S.autoSell    = v end)
        Button(tGen, "💀 Set All Player HP to 0 (Test)", function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChildWhichIsA("Humanoid")
                    if h then h.Health = 0 end
                end
            end
            Notify(gName, "Set all player health to 0 (test)", "success")
        end, C.Danger)
    end

    -- Animate window open
    win.Size = UDim2.new(0,0,0,0)
    Tw(win, {Size=UDim2.new(0,430,0,550)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    Notify(gName, "Menu opened!", "info", 2)
end

-- ================================================================
-- GAME LIST BUILDER
-- ================================================================
local gameButtons = {}

local function BuildList(filter)
    filter = (filter or ""):lower()
    for _, b in ipairs(gameButtons) do
        if b and b.Parent then b:Destroy() end
    end
    gameButtons = {}
    local count = 0

    for _, g in ipairs(GAMES) do
        local match = filter == ""
            or g.name:lower():find(filter, 1, true)
            or g.desc:lower():find(filter, 1, true)
        if not match then continue end
        count += 1

        local btn = MkBtn(gameScroll, "", UDim2.new(1,0,0,56), nil, C.BG2, C.White, 13)
        MkCorner(btn, 9)
        local bStroke = MkStroke(btn, C.Border, 1)

        -- Game icon background
        local ibg = MkFrame(btn, UDim2.new(0,40,0,40), UDim2.new(0,8,0.5,-20), g.color)
        MkCorner(ibg, 9)
        local iL = MkLabel(ibg, g.icon, 20, C.White, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        iL.Size = UDim2.new(1,0,1,0)

        -- Game name
        local nL = MkLabel(btn, g.name, 14, C.Text, Enum.Font.GothamBold)
        nL.Size     = UDim2.new(1,-100,0,20)
        nL.Position = UDim2.new(0,58,0,9)

        -- Game description
        local dL = MkLabel(btn, g.desc, 11, C.TextMute, Enum.Font.Gotham)
        dL.Size     = UDim2.new(1,-100,0,16)
        dL.Position = UDim2.new(0,58,0,31)

        -- Green dot if window is already open
        local dot = MkFrame(btn, UDim2.new(0,7,0,7), UDim2.new(1,-42,0.5,-3), C.Good)
        MkCorner(dot, 5)
        dot.Visible = (OpenWins[g.name] ~= nil and OpenWins[g.name].Parent ~= nil)

        -- Arrow
        local arr = MkLabel(btn, "›", 26, C.TextMute, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        arr.Size     = UDim2.new(0,26,1,0)
        arr.Position = UDim2.new(1,-30,0,0)

        local gc, gi, gn = g.color, g.icon, g.name

        btn.MouseEnter:Connect(function()
            Tw(btn,    {BackgroundColor3 = C.BG3},   0.15)
            Tw(bStroke,{Color           = gc},        0.2)
            Tw(arr,    {TextColor3      = gc},        0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tw(btn,    {BackgroundColor3 = C.BG2},    0.15)
            Tw(bStroke,{Color           = C.Border},  0.2)
            Tw(arr,    {TextColor3      = C.TextMute},0.15)
        end)
        btn.MouseButton1Click:Connect(function()
            MakeWindow(gn, gc, gi)
            dot.Visible = true
        end)

        table.insert(gameButtons, btn)
    end
    countL.Text = count.." / "..#GAMES.." games"
end

BuildList()
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    BuildList(searchBox.Text)
end)

-- ================================================================
-- RUNTIME LOOP — Fly, Noclip, Infinite Jump
-- Everything here reads from the States table each frame.
-- Character helpers always fetch fresh references so respawn works.
-- ================================================================
local autoLaunchTimers = {}

RunService.Heartbeat:Connect(function()
    local char = GetChar()
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildWhichIsA("Humanoid")
    if not (root and hum) then return end

    for gName, S in pairs(States) do

        -- ---- NOCLIP ----
        -- Runs every frame so newly spawned parts are also covered.
        if S.noClip then
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end

        -- ---- FLY ----
        if S.fly then
            -- Create BodyMovers on first activation
            if not S._flyOn then
                S._flyOn = true
                hum.PlatformStand = true

                -- BodyGyro keeps character upright and facing camera
                local bg = Instance.new("BodyGyro", root)
                bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                bg.D         = 150
                bg.P         = 10000

                -- BodyVelocity provides directional movement
                local bv = Instance.new("BodyVelocity", root)
                bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                bv.Velocity = Vector3.new(0,0,0)

                S._bg = bg
                S._bv = bv
            end

            -- Update velocity every frame based on current key state
            if S._bv and S._bg then
                local sp  = S.flySpeed or 60
                local dir = Vector3.new(0,0,0)
                local cf  = Cam.CFrame

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    dir = dir + cf.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    dir = dir - cf.LookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    dir = dir - cf.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    dir = dir + cf.RightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    dir = dir + Vector3.new(0,1,0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                    dir = dir - Vector3.new(0,1,0)
                end

                local mag = dir.Magnitude
                S._bv.Velocity = mag > 0 and (dir / mag) * sp or Vector3.new(0,0,0)
                S._bg.CFrame   = cf
            end

        elseif S._flyOn then
            -- Fly was turned off — clean up movers
            S._flyOn = false
            hum.PlatformStand = false
            if S._bg and S._bg.Parent then S._bg:Destroy() end
            if S._bv and S._bv.Parent then S._bv:Destroy() end
            S._bg = nil
            S._bv = nil
        end

        -- ---- AUTO LAUNCH LOOP (Break Your Bones) ----
        if S.autoLaunch then
            local interval = S.launchInt or 5
            S._launchTimer = (S._launchTimer or 0) + (1/60)
            if S._launchTimer >= interval then
                S._launchTimer = 0
                local f = S.force or 1000
                root.Velocity = Vector3.new(
                    math.random(-f, f),
                    f,
                    math.random(-f, f)
                )
            end
        else
            S._launchTimer = 0
        end

    end
end)

-- ---- INFINITE JUMP ----
-- Connected once globally. Checks all open game States each jump.
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end

    if inp.KeyCode == Enum.KeyCode.Space then
        for _, S in pairs(States) do
            if S.infJump then
                local h = GetHum()
                -- Only trigger if already in the air (not on ground)
                -- Using ChangeState to Jumping lets us jump again mid-air.
                if h then
                    h:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end
    end
end)

-- ================================================================
-- STARTUP ANIMATION
-- ================================================================
Hub.Visible = true
Hub.Size    = UDim2.new(0,340,0,0)
task.wait(0.2)
Tw(Hub, {Size = fullHubSize}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

task.delay(1.2, function()
    Notify("Script Hub v3.2", #GAMES.." games ready to use!", "success", 5)
end)
task.delay(2.0, function()
    Notify("Controls",
        "RightShift = Toggle  •  RightCtrl = Minimize  •  Drag any title bar to move",
        "info", 6)
end)

print("=========================================")
print("   Script Hub v3.2 — Fully Loaded")
print("   Games:      "..#GAMES)
print("   RightShift: Toggle hub visibility")
print("   RightCtrl:  Minimize/restore hub")
print("   Drag:       Title bars are draggable")
print("=========================================")
