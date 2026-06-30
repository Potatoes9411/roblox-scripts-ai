-- ================================================================
-- MULTI GAME SCRIPT HUB v3.0
-- Full Rewrite - Loadstring Compatible
-- ================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

-- SAFE INIT
repeat task.wait() until game:IsLoaded()
repeat task.wait() until Players.LocalPlayer
repeat task.wait() until Players.LocalPlayer:FindFirstChild("PlayerGui")

local LP = Players.LocalPlayer
local PGui = LP.PlayerGui
local Mouse = LP:GetMouse()
local Cam = workspace.CurrentCamera

task.wait(0.5)

-- ================================================================
-- DESTROY OLD GUI
-- ================================================================
for _, g in ipairs(PGui:GetChildren()) do
    if g.Name == "HubV3" then g:Destroy() end
end

-- ================================================================
-- COLORS
-- ================================================================
local C = {
    BG       = Color3.fromRGB(18,18,28),
    BG2      = Color3.fromRGB(25,25,38),
    BG3      = Color3.fromRGB(35,35,52),
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
}

-- ================================================================
-- STATE
-- ================================================================
local States = {}
local OpenWins = {}
local HubKeybind = Enum.KeyCode.RightShift

-- ================================================================
-- MAIN SCREENGUI
-- ================================================================
local SGui = Instance.new("ScreenGui")
SGui.Name = "HubV3"
SGui.ResetOnSpawn = false
SGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SGui.IgnoreGuiInset = true
SGui.Parent = PGui

-- ================================================================
-- UTILITY
-- ================================================================
local function Tw(obj, props, t, s, d)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.25, s or Enum.EasingStyle.Quart, d or Enum.EasingDirection.Out),
        props):Play()
end

local function Rnd(n, dec)
    dec = dec or 0
    local m = 10^dec
    return math.floor(n*m+0.5)/m
end

local function GetChar()
    return LP.Character
end

local function GetRoot()
    local c = GetChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function GetHum()
    local c = GetChar()
    return c and c:FindFirstChild("Humanoid")
end

local function SetWS(v)
    local h = GetHum()
    if h then h.WalkSpeed = v end
end

local function SetJP(v)
    local h = GetHum()
    if h then h.JumpPower = v end
end

local function SetGod(v)
    local h = GetHum()
    if h then
        h.MaxHealth = v and math.huge or 100
        h.Health = h.MaxHealth
    end
end

local function MakeDrag(frame, handle)
    local drag, ds, dp = false, nil, nil
    handle = handle or frame
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            ds = i.Position
            dp = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType == Enum.UserInputType.MouseMove then
            local d = i.Position - ds
            frame.Position = UDim2.new(dp.X.Scale, dp.X.Offset+d.X, dp.Y.Scale, dp.Y.Offset+d.Y)
        end
    end)
end

-- ================================================================
-- BASE UI BUILDERS
-- ================================================================
local function MkFrame(parent, size, pos, color, clip)
    local f = Instance.new("Frame")
    f.Size = size or UDim2.new(1,0,1,0)
    f.Position = pos or UDim2.new(0,0,0,0)
    f.BackgroundColor3 = color or C.BG
    f.BorderSizePixel = 0
    f.ClipsDescendants = clip or false
    f.Parent = parent
    return f
end

local function MkCorner(parent, r)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local function MkStroke(parent, color, thick)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or C.Border
    s.Thickness = thick or 1.5
    return s
end

local function MkLabel(parent, text, size, color, font, xalign)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Text = text or ""
    l.TextSize = size or 13
    l.TextColor3 = color or C.Text
    l.Font = font or Enum.Font.GothamMedium
    l.TextXAlignment = xalign or Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function MkBtn(parent, text, size, pos, color, textcolor, fontsize)
    local b = Instance.new("TextButton")
    b.Size = size or UDim2.new(1,0,1,0)
    b.Position = pos or UDim2.new(0,0,0,0)
    b.BackgroundColor3 = color or C.BG3
    b.Text = text or ""
    b.TextColor3 = textcolor or C.Text
    b.Font = Enum.Font.GothamMedium
    b.TextSize = fontsize or 13
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = parent
    return b
end

local function MkScroll(parent, size, pos)
    local s = Instance.new("ScrollingFrame")
    s.Size = size or UDim2.new(1,0,1,0)
    s.Position = pos or UDim2.new(0,0,0,0)
    s.BackgroundTransparency = 1
    s.BorderSizePixel = 0
    s.ScrollBarThickness = 4
    s.ScrollBarImageColor3 = C.Accent
    s.CanvasSize = UDim2.new(0,0,0,0)
    s.AutomaticCanvasSize = Enum.AutomaticSize.Y
    s.Parent = parent
    return s
end

local function MkList(parent, pad, dir)
    local l = Instance.new("UIListLayout", parent)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding = UDim.new(0, pad or 5)
    l.FillDirection = dir or Enum.FillDirection.Vertical
    return l
end

local function MkPad(parent, t, b, l, r)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    return p
end

-- ================================================================
-- COMPONENT LIBRARY
-- ================================================================

-- SECTION
local function Section(parent, title)
    local f = MkFrame(parent, UDim2.new(1,-10,0,22), nil, Color3.fromRGB(0,0,0), false)
    f.BackgroundTransparency = 1

    local l1 = MkFrame(f, UDim2.new(0.25,0,0,1), UDim2.new(0,0,0.5,0), C.Border)
    local lbl = MkLabel(f, "  "..title.."  ", 10, C.Accent, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    lbl.Size = UDim2.new(0.5,0,1,0)
    lbl.Position = UDim2.new(0.25,0,0,0)
    local l2 = MkFrame(f, UDim2.new(0.25,0,0,1), UDim2.new(0.75,0,0.5,0), C.Border)
    return f
end

-- TOGGLE
local function Toggle(parent, text, default, cb, desc)
    local val = default or false
    local h = desc and 48 or 34

    local frame = MkFrame(parent, UDim2.new(1,-10,0,h), nil, C.BG3)
    MkCorner(frame, 7)

    local lbl = MkLabel(frame, text, 13, C.Text, Enum.Font.GothamMedium)
    lbl.Size = UDim2.new(1,-65,0,18)
    lbl.Position = UDim2.new(0,10,0, desc and 6 or 8)

    if desc then
        local d = MkLabel(frame, desc, 10, C.TextMute, Enum.Font.Gotham)
        d.Size = UDim2.new(1,-65,0,14)
        d.Position = UDim2.new(0,10,0,26)
    end

    local togBg = MkFrame(frame, UDim2.new(0,44,0,22), UDim2.new(1,-54,0.5,-11), val and C.TOn or C.TOff)
    MkCorner(togBg, 12)

    local knob = MkFrame(togBg, UDim2.new(0,16,0,16), val and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8), C.White)
    MkCorner(knob, 10)

    local hit = MkBtn(frame, "", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0))
    hit.BackgroundTransparency = 1

    hit.MouseButton1Click:Connect(function()
        val = not val
        Tw(togBg, {BackgroundColor3 = val and C.TOn or C.TOff}, 0.2)
        Tw(knob, {Position = val and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)}, 0.2)
        if cb then cb(val) end
    end)

    return frame, function() return val end
end

-- SLIDER
local function Slider(parent, text, min, max, default, cb, suf)
    local val = default or min
    suf = suf or ""

    local frame = MkFrame(parent, UDim2.new(1,-10,0,54), nil, C.BG3)
    MkCorner(frame, 7)

    local lbl = MkLabel(frame, text, 13, C.Text, Enum.Font.GothamMedium)
    lbl.Size = UDim2.new(1,-85,0,20)
    lbl.Position = UDim2.new(0,10,0,6)

    local vLbl = MkLabel(frame, tostring(val)..suf, 12, C.Slider, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
    vLbl.Size = UDim2.new(0,70,0,20)
    vLbl.Position = UDim2.new(1,-78,0,6)

    local track = MkFrame(frame, UDim2.new(1,-20,0,6), UDim2.new(0,10,0,38), C.BG2)
    MkCorner(track, 4)

    local fill = MkFrame(track, UDim2.new((val-min)/(max-min),0,1,0), nil, C.Slider)
    MkCorner(fill, 4)

    local knob = MkFrame(track, UDim2.new(0,14,0,14), UDim2.new((val-min)/(max-min),-7,0.5,-7), C.White)
    knob.ZIndex = 3
    MkCorner(knob, 8)

    local sliding = false
    local cd = MkBtn(track, "", UDim2.new(1,0,1,10), UDim2.new(0,0,0,-5))
    cd.BackgroundTransparency = 1
    cd.ZIndex = 4

    local function Upd(rel)
        rel = math.clamp(rel,0,1)
        val = Rnd(min+(max-min)*rel)
        vLbl.Text = tostring(val)..suf
        fill.Size = UDim2.new(rel,0,1,0)
        knob.Position = UDim2.new(rel,-7,0.5,-7)
        if cb then cb(val) end
    end

    cd.MouseButton1Down:Connect(function()
        sliding = true
        Upd((Mouse.X - track.AbsolutePosition.X)/track.AbsoluteSize.X)
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and i.UserInputType == Enum.UserInputType.MouseMove then
            Upd((Mouse.X - track.AbsolutePosition.X)/track.AbsoluteSize.X)
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
            math.min(color.R+0.1,1), math.min(color.G+0.1,1), math.min(color.B+0.1,1))}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        Tw(btn, {BackgroundColor3 = color}, 0.15)
    end)
    btn.MouseButton1Click:Connect(function()
        if cb then cb() end
    end)
    return btn
end

-- DROPDOWN
local function Dropdown(parent, text, opts, default, cb)
    local sel = default or opts[1]
    local isOpen = false

    local cont = MkFrame(parent, UDim2.new(1,-10,0,34), nil, C.BG3)
    cont.ClipsDescendants = false
    cont.ZIndex = 10
    MkCorner(cont, 7)

    local lbl = MkLabel(cont, text, 13, C.Text, Enum.Font.GothamMedium)
    lbl.Size = UDim2.new(0.5,0,1,0)
    lbl.Position = UDim2.new(0,10,0,0)
    lbl.ZIndex = 10

    local selLbl = MkLabel(cont, sel, 12, C.Accent, Enum.Font.GothamMedium, Enum.TextXAlignment.Right)
    selLbl.Size = UDim2.new(0.42,-22,1,0)
    selLbl.Position = UDim2.new(0.5,0,0,0)
    selLbl.ZIndex = 10

    local arr = MkLabel(cont, "▼", 10, C.TextDim, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    arr.Size = UDim2.new(0,22,1,0)
    arr.Position = UDim2.new(1,-24,0,0)
    arr.ZIndex = 10

    local maxVisible = math.min(#opts, 5)
    local dropH = maxVisible * 28 + 6

    local drop = MkFrame(cont, UDim2.new(1,0,0,dropH), UDim2.new(0,0,1,4), C.BG2)
    drop.ZIndex = 20
    drop.Visible = false
    drop.ClipsDescendants = true
    MkCorner(drop, 7)
    MkStroke(drop, C.Border, 1)

    local dScroll = MkScroll(drop, UDim2.new(1,-4,1,-4), UDim2.new(0,2,0,2))
    dScroll.ZIndex = 21
    MkList(dScroll, 2)
    MkPad(dScroll, 2, 2, 2, 2)

    local optBtns = {}
    for _, opt in ipairs(opts) do
        local ob = MkBtn(dScroll, opt, UDim2.new(1,0,0,26), nil, opt==sel and C.Accent or C.BG3, opt==sel and C.White or C.TextDim, 12)
        ob.Font = Enum.Font.GothamMedium
        ob.ZIndex = 22
        MkCorner(ob, 5)
        optBtns[opt] = ob

        ob.MouseButton1Click:Connect(function()
            for k, b in pairs(optBtns) do
                b.BackgroundColor3 = C.BG3
                b.TextColor3 = C.TextDim
            end
            sel = opt
            selLbl.Text = opt
            ob.BackgroundColor3 = C.Accent
            ob.TextColor3 = C.White
            isOpen = false
            drop.Visible = false
            Tw(arr, {Rotation=0}, 0.2)
            if cb then cb(opt) end
        end)
    end

    local hit = MkBtn(cont, "", UDim2.new(1,0,1,0), UDim2.new(0,0,0,0))
    hit.BackgroundTransparency = 1
    hit.ZIndex = 11
    hit.MouseButton1Click:Connect(function()
        isOpen = not isOpen
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
    dur = dur or 4
    local clrs = {info=C.Accent, success=C.Good, warning=C.Warn, error=C.Danger}
    local icos = {info="ℹ", success="✓", warning="⚠", error="✕"}
    local nc = clrs[ntype] or C.Accent
    local ni = icos[ntype] or "ℹ"

    local nf = MkFrame(NHolder, UDim2.new(0,280,0,0), nil, C.BG2)
    nf.ClipsDescendants = true
    nf.ZIndex = 200
    MkCorner(nf, 10)
    MkStroke(nf, nc, 1.5)

    local ab = MkFrame(nf, UDim2.new(0,4,1,0), nil, nc)
    MkCorner(ab, 3)

    local ico = MkFrame(nf, UDim2.new(0,26,0,26), UDim2.new(0,12,0,9), nc)
    MkCorner(ico, 13)
    local icoL = MkLabel(ico, ni, 13, C.White, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    icoL.Size = UDim2.new(1,0,1,0)

    local tl = MkLabel(nf, title, 13, C.Text, Enum.Font.GothamBold)
    tl.Size = UDim2.new(1,-55,0,17)
    tl.Position = UDim2.new(0,48,0,7)
    tl.ZIndex = 201

    local ml = MkLabel(nf, msg, 11, C.TextDim, Enum.Font.Gotham)
    ml.Size = UDim2.new(1,-55,0,28)
    ml.Position = UDim2.new(0,48,0,25)
    ml.TextWrapped = true
    ml.ZIndex = 201

    local pbg = MkFrame(nf, UDim2.new(1,-8,0,3), UDim2.new(0,4,1,-5), C.BG3)
    MkCorner(pbg, 3)
    local pf = MkFrame(pbg, UDim2.new(1,0,1,0), nil, nc)
    MkCorner(pf, 3)

    Tw(nf, {Size=UDim2.new(0,280,0,66)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    Tw(pf, {Size=UDim2.new(0,0,1,0)}, dur, Enum.EasingStyle.Linear)

    task.delay(dur, function()
        Tw(nf, {Size=UDim2.new(0,280,0,0)}, 0.3)
        task.wait(0.35)
        if nf and nf.Parent then nf:Destroy() end
    end)
end

-- ================================================================
-- WATERMARK
-- ================================================================
local wmF = MkFrame(SGui, UDim2.new(0,210,0,28), UDim2.new(0,8,0,8), C.BG2)
wmF.ZIndex = 50
MkCorner(wmF, 6)
MkStroke(wmF, C.Accent, 1)
local wmL = MkLabel(wmF, "🎮 Hub v3.0", 12, C.Text, Enum.Font.GothamBold)
wmL.Size = UDim2.new(1,-10,1,0)
wmL.Position = UDim2.new(0,8,0,0)
wmL.ZIndex = 51

local fpsF = MkFrame(SGui, UDim2.new(0,120,0,24), UDim2.new(0,8,0,40), C.BG2)
fpsF.ZIndex = 50
MkCorner(fpsF, 6)
MkStroke(fpsF, C.Border, 1)
local fpsL = MkLabel(fpsF, "FPS: --", 11, C.TextDim, Enum.Font.GothamBold)
fpsL.Size = UDim2.new(1,-10,1,0)
fpsL.Position = UDim2.new(0,8,0,0)
fpsL.ZIndex = 51

local lastT = tick()
local fCount = 0
RunService.Heartbeat:Connect(function()
    fCount += 1
    local now = tick()
    if now - lastT >= 0.5 then
        local fps = math.floor(fCount/(now-lastT))
        fCount = 0
        lastT = now
        fpsL.TextColor3 = fps>=55 and C.Good or fps>=30 and C.Warn or C.Danger
        fpsL.Text = "FPS: "..fps
        wmL.Text = string.format("🎮 Hub v3.0  |  %s", os.date("%H:%M:%S"))
    end
end)

-- ================================================================
-- TOGGLE BUTTON
-- ================================================================
local togBtn = MkBtn(SGui, "☰", UDim2.new(0,44,0,44), UDim2.new(0,10,0.5,-22), C.BG2, C.Accent, 22)
togBtn.Font = Enum.Font.GothamBold
togBtn.ZIndex = 100
MkCorner(togBtn, 10)
MkStroke(togBtn, C.Accent, 1.5)

-- ================================================================
-- MAIN HUB FRAME
-- ================================================================
local Hub = MkFrame(SGui, UDim2.new(0,340,0,560), UDim2.new(0,64,0.5,-280), C.BG, true)
Hub.ZIndex = 10
MkCorner(Hub, 12)
MkStroke(Hub, C.Border, 1.5)

-- Top gradient bar
local topBar = MkFrame(Hub, UDim2.new(1,0,0,3), nil, C.Accent)

-- Title bar
local titleBar = MkFrame(Hub, UDim2.new(1,0,0,56), UDim2.new(0,0,0,3), C.BG2)

local iconBg = MkFrame(titleBar, UDim2.new(0,38,0,38), UDim2.new(0,10,0.5,-19), C.Accent)
MkCorner(iconBg, 9)
local iconL = MkLabel(iconBg, "🎮", 20, C.White, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
iconL.Size = UDim2.new(1,0,1,0)

local titleL = MkLabel(titleBar, "Script Hub", 20, C.Text, Enum.Font.GothamBold)
titleL.Size = UDim2.new(1,-120,0,24)
titleL.Position = UDim2.new(0,58,0,9)

local subL = MkLabel(titleBar, "v3.0 — Studio Edition", 11, C.TextMute, Enum.Font.Gotham)
subL.Size = UDim2.new(1,-120,0,15)
subL.Position = UDim2.new(0,58,0,34)

-- Hub close/min buttons
local function HBtn(xo, clr, sym)
    local b = MkBtn(titleBar, sym, UDim2.new(0,26,0,26), UDim2.new(1,xo,0.5,-13), clr, C.White, 12)
    b.Font = Enum.Font.GothamBold
    MkCorner(b, 13)
    return b
end
local hubClose = HBtn(-36, C.Danger, "✕")
local hubMin   = HBtn(-66, C.Warn,   "─")

local isMinimized = false
hubMin.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    Tw(Hub, {Size = isMinimized and UDim2.new(0,340,0,59) or UDim2.new(0,340,0,560)}, 0.3)
end)
hubClose.MouseButton1Click:Connect(function()
    Tw(Hub, {Size=UDim2.new(0,340,0,0)}, 0.3)
    task.wait(0.32)
    Hub.Visible = false
    Hub.Size = UDim2.new(0,340,0,560)
end)

MakeDrag(Hub, titleBar)

-- Search bar
local searchOuter = MkFrame(Hub, UDim2.new(1,-20,0,36), UDim2.new(0,10,0,66), C.BG3)
MkCorner(searchOuter, 9)
MkStroke(searchOuter, C.Border, 1)

local searchIco = MkLabel(searchOuter, "🔍", 14, C.TextMute, Enum.Font.Gotham, Enum.TextXAlignment.Center)
searchIco.Size = UDim2.new(0,32,1,0)

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1,-42,1,0)
searchBox.Position = UDim2.new(0,34,0,0)
searchBox.BackgroundTransparency = 1
searchBox.Text = ""
searchBox.PlaceholderText = "Search games..."
searchBox.PlaceholderColor3 = C.TextMute
searchBox.TextColor3 = C.Text
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 13
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Parent = searchOuter

-- Stats bar
local statsBar = MkFrame(Hub, UDim2.new(1,-20,0,24), UDim2.new(0,10,0,108), C.BG3)
MkCorner(statsBar, 6)
local countL = MkLabel(statsBar, "", 11, C.TextDim, Enum.Font.GothamMedium)
countL.Size = UDim2.new(0.55,0,1,0)
countL.Position = UDim2.new(0,8,0,0)
local plrL = MkLabel(statsBar, "👤 "..LP.Name, 11, C.Accent, Enum.Font.GothamMedium, Enum.TextXAlignment.Right)
plrL.Size = UDim2.new(0.45,-8,1,0)
plrL.Position = UDim2.new(0.55,0,0,0)

-- Game list scroll
local gameScroll = MkScroll(Hub, UDim2.new(1,-20,1,-145), UDim2.new(0,10,0,138))
gameScroll.ScrollBarImageColor3 = C.Accent
MkList(gameScroll, 6)
MkPad(gameScroll, 0, 8, 0, 0)

-- Toggle hub
togBtn.MouseButton1Click:Connect(function()
    if Hub.Visible and Hub.Size.Y.Offset > 10 then
        Tw(Hub, {Size=UDim2.new(0,340,0,0)}, 0.3)
        task.delay(0.32, function() Hub.Visible = false; Hub.Size=UDim2.new(0,340,0,560) end)
    else
        Hub.Visible = true
        Hub.Size = UDim2.new(0,340,0,0)
        Tw(Hub, {Size=UDim2.new(0,340,0,560)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end
end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == HubKeybind then
        togBtn.MouseButton1Click:Fire()
    end
end)

-- ================================================================
-- GAMES LIST
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
}

-- ================================================================
-- WINDOW SYSTEM
-- ================================================================
local function MakeWindow(gName, gColor, gIcon)
    if OpenWins[gName] and OpenWins[gName].Parent then
        OpenWins[gName].Visible = true
        OpenWins[gName].Size = UDim2.new(0,0,0,0)
        Tw(OpenWins[gName], {Size=UDim2.new(0,410,0,530)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        return
    end

    States[gName] = States[gName] or {}
    local S = States[gName]

    local win = MkFrame(SGui, UDim2.new(0,410,0,530),
        UDim2.new(0.5,-205+math.random(-50,50), 0.5,-265+math.random(-30,30)), C.BG, true)
    win.ZIndex = 50
    MkCorner(win, 12)
    MkStroke(win, gColor, 1.5)
    OpenWins[gName] = win

    -- Top color bar
    local wTopBar = MkFrame(win, UDim2.new(1,0,0,3), nil, gColor)
    wTopBar.ZIndex = 51

    -- Title bar
    local wTB = MkFrame(win, UDim2.new(1,0,0,54), UDim2.new(0,0,0,3), C.BG2)
    wTB.ZIndex = 51

    local wIB = MkFrame(wTB, UDim2.new(0,38,0,38), UDim2.new(0,10,0.5,-19), gColor)
    wIB.ZIndex = 52
    MkCorner(wIB, 9)
    local wIL = MkLabel(wIB, gIcon, 20, C.White, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    wIL.Size = UDim2.new(1,0,1,0)
    wIL.ZIndex = 53

    local wTL = MkLabel(wTB, gName, 17, C.Text, Enum.Font.GothamBold)
    wTL.Size = UDim2.new(1,-130,0,22)
    wTL.Position = UDim2.new(0,58,0,7)
    wTL.ZIndex = 52

    local wSL = MkLabel(wTB, "Script Controls", 11, C.TextMute, Enum.Font.Gotham)
    wSL.Size = UDim2.new(1,-130,0,14)
    wSL.Position = UDim2.new(0,58,0,31)
    wSL.ZIndex = 52

    local function WBtn(xo, clr, sym)
        local b = MkBtn(wTB, sym, UDim2.new(0,26,0,26), UDim2.new(1,xo,0.5,-13), clr, C.White, 12)
        b.Font = Enum.Font.GothamBold
        b.ZIndex = 55
        MkCorner(b, 13)
        return b
    end

    local wClose = WBtn(-36, C.Danger, "✕")
    local wMin   = WBtn(-66, C.Warn,   "─")

    local wMinned = false
    wMin.MouseButton1Click:Connect(function()
        wMinned = not wMinned
        Tw(win, {Size = wMinned and UDim2.new(0,410,0,57) or UDim2.new(0,410,0,530)}, 0.3)
    end)
    wClose.MouseButton1Click:Connect(function()
        Tw(win, {Size=UDim2.new(0,0,0,0)}, 0.25)
        task.delay(0.28, function()
            if win and win.Parent then win:Destroy() end
            OpenWins[gName] = nil
            States[gName] = nil
        end)
    end)

    MakeDrag(win, wTB)

    -- Tab scroll bar
    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Size = UDim2.new(1,-20,0,34)
    tabScroll.Position = UDim2.new(0,10,0,61)
    tabScroll.BackgroundColor3 = C.BG2
    tabScroll.BorderSizePixel = 0
    tabScroll.ScrollBarThickness = 0
    tabScroll.CanvasSize = UDim2.new(0,0,0,0)
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
    tabScroll.ZIndex = 52
    tabScroll.Parent = win
    MkCorner(tabScroll, 8)
    MkList(tabScroll, 4, Enum.FillDirection.Horizontal)
    MkPad(tabScroll, 5, 5, 4, 4)

    -- Content scroll
    local contentScroll = MkScroll(win, UDim2.new(1,-20,1,-103), UDim2.new(0,10,0,100))
    contentScroll.ZIndex = 51
    contentScroll.ScrollBarImageColor3 = gColor
    contentScroll.ScrollBarThickness = 3

    local tabNames  = {}
    local tabFrames = {}
    local tabBtns   = {}

    local function AddTab(name)
        local btn = MkBtn(tabScroll, name, UDim2.new(0,85,1,0), nil, C.BG3, C.TextDim, 11)
        btn.Font = Enum.Font.GothamMedium
        btn.ZIndex = 53
        MkCorner(btn, 6)

        local tc = MkFrame(contentScroll, UDim2.new(1,0,0,0), nil, Color3.fromRGB(0,0,0))
        tc.BackgroundTransparency = 1
        tc.Visible = false
        tc.AutomaticSize = Enum.AutomaticSize.Y
        tc.ZIndex = 51
        MkList(tc, 5)

        table.insert(tabNames, name)
        tabFrames[name] = tc
        tabBtns[name] = btn

        btn.MouseButton1Click:Connect(function()
            for _, n in ipairs(tabNames) do
                tabFrames[n].Visible = false
                Tw(tabBtns[n], {BackgroundColor3=C.BG3, TextColor3=C.TextDim}, 0.15)
            end
            tc.Visible = true
            Tw(btn, {BackgroundColor3=gColor, TextColor3=C.White}, 0.15)
            contentScroll.CanvasPosition = Vector2.new(0,0)
        end)

        return tc
    end

    local function ActivateTab(name)
        if tabFrames[name] then
            for _, n in ipairs(tabNames) do
                tabFrames[n].Visible = false
                Tw(tabBtns[n], {BackgroundColor3=C.BG3, TextColor3=C.TextDim}, 0.15)
            end
            tabFrames[name].Visible = true
            Tw(tabBtns[name], {BackgroundColor3=gColor, TextColor3=C.White}, 0.15)
        end
    end

    -- ============================================================
    -- SHARED TAB BUILDERS
    -- ============================================================
    local function MoveTab()
        local tab = AddTab("Movement")
        Section(tab, "SPEED")
        Slider(tab, "Walk Speed", 16, 150, 16, function(v) SetWS(v) end, " wsp")
        Slider(tab, "Jump Power", 50, 400, 50, function(v) SetJP(v) end, " jp")
        Toggle(tab, "Infinite Jump", false, function(v) S.infJump=v end, "Jump repeatedly mid-air")
        Toggle(tab, "Bunny Hop", false, function(v) S.bunnyHop=v end)
        Section(tab, "FLY")
        Toggle(tab, "Fly Mode", false, function(v)
            S.fly = v
            Notify("Movement", v and "Fly ON — WASD + Space / Ctrl" or "Fly OFF", v and "info" or "warning")
        end, "WASD = move, Space = up, Ctrl = down")
        Slider(tab, "Fly Speed", 5, 300, 60, function(v) S.flySpeed=v end, " sp")
        Section(tab, "UTILITY")
        Toggle(tab, "No Clip", false, function(v) S.noClip=v end, "Phase through walls")
        Toggle(tab, "God Mode", false, function(v) SetGod(v) end, "Cannot die")
        Toggle(tab, "Anti AFK", true, function(v) S.antiAFK=v end)
        Button(tab, "📍 Teleport to Spawn", function()
            local c = GetChar()
            local sp = workspace:FindFirstChildOfClass("SpawnLocation")
            if c and sp then c:SetPrimaryPartCFrame(sp.CFrame + Vector3.new(0,5,0)) end
            Notify("Teleport", "Teleported to spawn!", "success")
        end, C.Btn)
        Button(tab, "📍 Teleport to Mouse", function()
            local c = GetChar()
            if c then c:SetPrimaryPartCFrame(Mouse.Hit + Vector3.new(0,5,0)) end
        end, C.Btn)
        Button(tab, "📍 Teleport to Nearest Player", function()
            local c = GetChar()
            local root = GetRoot()
            if not (c and root) then return end
            local best, bd = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local pr = p.Character:FindFirstChild("HumanoidRootPart")
                    if pr then
                        local d = (pr.Position - root.Position).Magnitude
                        if d < bd then bd=d; best=pr end
                    end
                end
            end
            if best then c:SetPrimaryPartCFrame(best.CFrame + Vector3.new(3,0,0)) end
            Notify("Teleport", best and "Teleported to nearest player" or "No players found", best and "success" or "warning")
        end, C.Btn)
        return tab
    end

    local function ESPTab()
        local tab = AddTab("ESP")
        Section(tab, "PLAYER ESP")
        Toggle(tab, "Enable ESP", false, function(v) S.espOn=v end, "Shows all player info")
        Toggle(tab, "Names", false, function(v) S.espNames=v end)
        Toggle(tab, "Health Bars", false, function(v) S.espHP=v end)
        Toggle(tab, "Distance", false, function(v) S.espDist=v end)
        Toggle(tab, "Highlights", false, function(v)
            S.espHL = v
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local ex = p.Character:FindFirstChild("HubESPBox")
                    if v and not ex then
                        local sb = Instance.new("SelectionBox")
                        sb.Name = "HubESPBox"
                        sb.Adornee = p.Character
                        sb.Color3 = gColor
                        sb.LineThickness = 0.05
                        sb.SurfaceTransparency = 0.85
                        sb.SurfaceColor3 = gColor
                        sb.Parent = SGui
                    elseif not v and ex then
                        ex:Destroy()
                    end
                end
            end
        end)
        Section(tab, "RENDERING")
        Toggle(tab, "Fullbright", false, function(v)
            Lighting.Brightness = v and 10 or 2
            Lighting.ClockTime = v and 14 or 6
        end)
        Toggle(tab, "No Fog", false, function(v)
            Lighting.FogEnd = v and 999999 or 1000
        end)
        Slider(tab, "ESP Max Distance", 50, 2000, 1000, function(v) S.espMaxDist=v end, " st")
        return tab
    end

    -- ============================================================
    -- GAME SPECIFIC MENUS
    -- ============================================================

    if gName == "Arsenal" then
        local tAim  = AddTab("Aimbot")
        local tGun  = AddTab("Weapons")
        local tVis  = ESPTab()
        local tMove = MoveTab()
        local tMisc = AddTab("Misc")
        ActivateTab("Aimbot")

        Section(tAim, "AIMBOT")
        Toggle(tAim, "Aimbot Enabled", false, function(v)
            S.aimbot = v
            Notify("Arsenal", v and "Aimbot ON" or "Aimbot OFF", v and "success" or "warning")
        end, "Locks aim to nearest player")
        Toggle(tAim, "Silent Aim", false, function(v) S.silentAim=v end, "Invisible aim correction")
        Toggle(tAim, "Hold to Aim", true, function(v) S.holdAim=v end)
        Slider(tAim, "FOV Radius", 10, 600, 150, function(v) S.fov=v end, " px")
        Slider(tAim, "Smoothness", 1, 30, 8, function(v) S.smooth=v end)
        Slider(tAim, "Prediction", 0, 20, 5, function(v) S.predict=v end)
        Dropdown(tAim, "Target Part", {"Head","HumanoidRootPart","Torso"}, "Head", function(v) S.tPart=v end)
        Dropdown(tAim, "Priority", {"Nearest","Lowest HP","Random"}, "Nearest", function(v) S.priority=v end)
        Section(tAim, "TRIGGERBOT")
        Toggle(tAim, "Triggerbot", false, function(v) S.trigger=v end, "Auto shoots when on target")
        Slider(tAim, "Trigger Delay", 0, 400, 80, function(v) S.trigDelay=v end, " ms")

        Section(tGun, "FIRE MODS")
        Toggle(tGun, "No Recoil", false, function(v) S.noRecoil=v end)
        Toggle(tGun, "No Spread", false, function(v) S.noSpread=v end)
        Toggle(tGun, "Rapid Fire", false, function(v) S.rapidFire=v end)
        Toggle(tGun, "Infinite Ammo", false, function(v) S.infAmmo=v end)
        Toggle(tGun, "Auto Reload", false, function(v) S.autoReload=v end)
        Slider(tGun, "Damage Multiplier", 1, 20, 1, function(v) S.dmgMult=v end, "x")
        Section(tGun, "EXTRAS")
        Toggle(tGun, "One Shot Kill", false, function(v) S.oneShot=v end)
        Slider(tGun, "Bullet Speed", 100, 9999, 1200, function(v) S.bulletSpd=v end)

        Section(tMisc, "MISC")
        Toggle(tMisc, "God Mode", false, function(v) SetGod(v) end)
        Toggle(tMisc, "Fullbright", false, function(v) Lighting.Brightness=v and 10 or 2 end)
        Toggle(tMisc, "FOV Circle", false, function(v) S.fovCircle=v end)
        Button(tMisc, "💀 Kill All (Test)", function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChild("Humanoid")
                    if h then h.Health=0 end
                end
            end
            Notify("Arsenal", "Eliminated all (test)", "success")
        end, C.Danger)
        Button(tMisc, "📋 Print Player List", function()
            local names = {}
            for _, p in ipairs(Players:GetPlayers()) do table.insert(names, p.Name) end
            warn("Players: "..table.concat(names, ", "))
            Notify("Arsenal", "Player list in output", "info")
        end, C.Btn)

    elseif gName == "Jailbreak" then
        local tPl   = AddTab("Player")
        local tCar  = AddTab("Vehicle")
        local tCrime= AddTab("Crime")
        local tMove = MoveTab()
        local tVis  = ESPTab()
        ActivateTab("Player")

        Section(tPl, "PLAYER")
        Toggle(tPl, "God Mode", false, function(v) SetGod(v) end)
        Toggle(tPl, "Anti Arrest", false, function(v) S.antiArrest=v end, "Prevents being arrested")
        Toggle(tPl, "Anti AFK", true, function(v) S.antiAFK=v end)
        Toggle(tPl, "No Clip", false, function(v) S.noClip=v end)

        Section(tCar, "VEHICLE")
        Toggle(tCar, "No Car Flip", false, function(v) S.noFlip=v end)
        Toggle(tCar, "God Car", false, function(v) S.carGod=v end)
        Slider(tCar, "Speed Multiplier", 1, 15, 1, function(v) S.carSpd=v end, "x")
        Button(tCar, "🚗 Eject from Vehicle", function()
            local h = GetHum()
            if h then h.Sit=false end
        end, C.Warn)
        Button(tCar, "🔧 Repair Vehicle (Test)", function()
            Notify("Jailbreak", "Vehicle repaired!", "success")
        end, C.Good)

        Section(tCrime, "AUTO ROB")
        Toggle(tCrime, "Auto Rob Bank", false, function(v) S.robBank=v
            Notify("Jailbreak", v and "Robbing bank..." or "Stopped", "info")
        end)
        Toggle(tCrime, "Auto Rob Jewelry", false, function(v) S.robJewel=v end)
        Toggle(tCrime, "Auto Rob Museum", false, function(v) S.robMuseum=v end)
        Toggle(tCrime, "Auto Rob Power Plant", false, function(v) S.robPower=v end)
        Toggle(tCrime, "Auto Collect Cash", false, function(v) S.autoCash=v end)
        Section(tCrime, "TELEPORT")
        Dropdown(tCrime, "Location", {"Bank","Jewelry","Museum","Train","Power Plant","Police Station","Gas Station"}, "Bank", function(v) S.tpLoc=v end)
        Button(tCrime, "📍 Go to Location", function()
            Notify("Jailbreak", "Teleporting to "..(S.tpLoc or "Bank"), "info")
        end, gColor)

    elseif gName == "Murder Mystery 2" then
        local tRole = AddTab("Role")
        local tFarm = AddTab("Farm")
        local tMove = MoveTab()
        local tVis  = ESPTab()
        ActivateTab("Role")

        Section(tRole, "DETECTION")
        Toggle(tRole, "Show Murderer", false, function(v) S.showMurd=v end, "Highlights the murderer")
        Toggle(tRole, "Show Sheriff", false, function(v) S.showSheriff=v end)
        Toggle(tRole, "Role Announcer", false, function(v) S.announceRoles=v end)
        Section(tRole, "MURDERER")
        Toggle(tRole, "Knife Aimbot", false, function(v) S.knifeAim=v end)
        Slider(tRole, "Knife Reach", 5, 100, 15, function(v) S.knifeReach=v end, " st")
        Toggle(tRole, "Instant Kill", false, function(v) S.instKill=v end)
        Section(tRole, "SHERIFF")
        Toggle(tRole, "Auto Aim Sheriff", false, function(v) S.sheriffAim=v end)
        Button(tRole, "🔫 Grab Gun", function()
            Notify("MM2", "Grabbing sheriff gun...", "info")
        end, gColor)

        Section(tFarm, "COIN FARM")
        Toggle(tFarm, "Auto Collect Coins", false, function(v) S.autoCoins=v
            Notify("MM2", v and "Collecting coins" or "Stopped", "success")
        end)
        Toggle(tFarm, "Coin Magnet", false, function(v) S.coinMag=v end, "Pulls coins toward you")
        Slider(tFarm, "Magnet Radius", 10, 200, 60, function(v) S.magRadius=v end, " st")
        Button(tFarm, "💰 Collect All Now", function()
            Notify("MM2", "Collecting all coins!", "success")
        end, C.Good)

    elseif gName == "Blade Ball" then
        local tBall  = AddTab("Ball")
        local tSkill = AddTab("Skills")
        local tMove  = MoveTab()
        ActivateTab("Ball")

        Section(tBall, "AUTO DEFLECT")
        Toggle(tBall, "Auto Deflect", false, function(v) S.autoDef=v
            Notify("Blade Ball", v and "Auto Deflect ON" or "OFF", v and "success" or "warning")
        end, "Automatically deflects the ball")
        Slider(tBall, "Deflect Window", 10, 500, 80, function(v) S.defWin=v end, " ms")
        Toggle(tBall, "Perfect Parry", false, function(v) S.perfectParry=v end, "Always times perfectly")
        Toggle(tBall, "Parry Without Click", false, function(v) S.autoParry=v end)
        Section(tBall, "TARGETING")
        Toggle(tBall, "Smart Redirect", false, function(v) S.redirect=v end, "Sends ball to weakest player")
        Dropdown(tBall, "Redirect Target", {"Weakest HP","Nearest","Farthest","Random"}, "Weakest HP", function(v) S.redirTarget=v end)
        Toggle(tBall, "Ball ESP", false, function(v) S.ballESP=v end)

        Section(tSkill, "SKILLS")
        Toggle(tSkill, "Auto Use Skill", false, function(v) S.autoSkill=v end)
        Dropdown(tSkill, "Priority Skill", {"Dash","Shield","Slow Time","Speed Boost","Teleport"}, "Dash", function(v) S.skill=v end)
        Toggle(tSkill, "Skill Spam", false, function(v) S.skillSpam=v end)
        Slider(tSkill, "CD Reduction", 1, 10, 1, function(v) S.cdReduce=v end, "x")
        Slider(tSkill, "Activate Below HP%", 1, 100, 50, function(v) S.skillHP=v end, "%")

    elseif gName == "Tower of Hell" then
        local tCheat = AddTab("Cheat")
        local tMove  = MoveTab()
        local tVis   = ESPTab()
        ActivateTab("Cheat")

        Section(tCheat, "COMPLETION")
        Button(tCheat, "🏆 TP to Top of Tower", function()
            local root = GetRoot()
            if not root then return end
            local highest = 0
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Position.Y > highest then
                    highest = v.Position.Y
                end
            end
            root.CFrame = CFrame.new(root.Position.X, highest+10, root.Position.Z)
            Notify("ToH", "Teleported to top!", "success")
        end, gColor)
        Toggle(tCheat, "God Mode", false, function(v) SetGod(v) end, "Cannot die or reset")
        Toggle(tCheat, "No Kill Bricks", false, function(v) S.noKillBricks=v end)
        Toggle(tCheat, "No Clip", false, function(v) S.noClip=v end)
        Section(tCheat, "GRAVITY")
        Slider(tCheat, "Gravity", 1, 400, 196, function(v) workspace.Gravity=v end, " g")
        Toggle(tCheat, "Moon Gravity", false, function(v) workspace.Gravity=v and 20 or 196.2 end)
        Toggle(tCheat, "Zero Gravity", false, function(v) workspace.Gravity=v and 1 or 196.2 end)
        Section(tCheat, "TIMER")
        Toggle(tCheat, "Freeze Timer", false, function(v) S.freezeTimer=v end)

    elseif gName == "Da Hood" then
        local tAim    = AddTab("Aimbot")
        local tGun    = AddTab("Weapons")
        local tMove   = MoveTab()
        local tVis    = ESPTab()
        local tStreet = AddTab("Street")
        ActivateTab("Aimbot")

        Section(tAim, "AIMBOT")
        Toggle(tAim, "Aimbot", false, function(v) S.aimbot=v
            Notify("Da Hood", v and "Aimbot ON" or "OFF", v and "success" or "warning")
        end)
        Toggle(tAim, "Silent Aim", false, function(v) S.silentAim=v end)
        Slider(tAim, "FOV", 10, 600, 200, function(v) S.fov=v end, " px")
        Slider(tAim, "Smoothness", 1, 30, 8, function(v) S.smooth=v end)
        Dropdown(tAim, "Aim Part", {"Head","HumanoidRootPart","Torso"}, "Head", function(v) S.aimPart=v end)
        Section(tAim, "TRIGGERBOT")
        Toggle(tAim, "Triggerbot", false, function(v) S.trigger=v end)
        Slider(tAim, "Trigger Delay", 0, 400, 80, function(v) S.trigDelay=v end, " ms")

        Section(tGun, "WEAPONS")
        Toggle(tGun, "No Recoil", false, function(v) S.noRecoil=v end)
        Toggle(tGun, "No Spread", false, function(v) S.noSpread=v end)
        Toggle(tGun, "Rapid Fire", false, function(v) S.rapidFire=v end)
        Toggle(tGun, "Infinite Ammo", false, function(v) S.infAmmo=v end)
        Slider(tGun, "Damage Multiplier", 1, 20, 1, function(v) S.dmgMult=v end, "x")
        Section(tGun, "MELEE")
        Toggle(tGun, "Extended Punch", false, function(v) S.extPunch=v end)
        Slider(tGun, "Punch Reach", 5, 60, 12, function(v) S.punchReach=v end, " st")
        Toggle(tGun, "Auto Block", false, function(v) S.autoBlock=v end)
        Toggle(tGun, "Auto Parry", false, function(v) S.autoParry=v end)

        Section(tStreet, "MONEY")
        Toggle(tStreet, "Auto Farm Cash", false, function(v) S.autoFarm=v
            Notify("Da Hood", v and "Farming cash" or "Stopped", "success")
        end)
        Slider(tStreet, "Farm Radius", 10, 200, 50, function(v) S.farmRadius=v end, " st")
        Toggle(tStreet, "God Mode", false, function(v) SetGod(v) end)
        Toggle(tStreet, "Ragdoll Immunity", false, function(v) S.ragImmune=v end)
        Toggle(tStreet, "Anti Knockback", false, function(v) S.antiKB=v end)

    elseif gName == "Bee Swarm Simulator" then
        local tFarm = AddTab("Farming")
        local tBee  = AddTab("Bees")
        local tMove = MoveTab()
        ActivateTab("Farming")

        Section(tFarm, "AUTO FARM")
        Toggle(tFarm, "Auto Collect Pollen", false, function(v) S.autoPollen=v
            Notify("BSS", v and "Farming pollen" or "Stopped", "success")
        end, "Automatically collects pollen")
        Toggle(tFarm, "Auto Convert Honey", false, function(v) S.autoHoney=v end)
        Toggle(tFarm, "Auto Fill Bags", false, function(v) S.autoFill=v end)
        Slider(tFarm, "Collection Speed", 1, 20, 5, function(v) S.collectSpd=v end, "x")
        Toggle(tFarm, "Auto Quest", false, function(v) S.autoQuest=v end)
        Section(tFarm, "FIELD SELECT")
        Dropdown(tFarm, "Target Field", {"Sunflower","Dandelion","Mushroom","Blue Flower","Clover","Spider","Strawberry","Bamboo","Pumpkin","Rose"}, "Sunflower", function(v) S.field=v end)
        Button(tFarm, "📍 Go to Field", function()
            Notify("BSS", "Going to "..(S.field or "Sunflower").." Field", "info")
        end, gColor)

        Section(tBee, "BEE MANAGEMENT")
        Toggle(tBee, "Auto Level Bees", false, function(v) S.autoLevel=v end)
        Toggle(tBee, "Collect Gift Boxes", false, function(v) S.autoGifts=v end)
        Toggle(tBee, "Auto Daily Reward", false, function(v) S.autoDaily=v end)
        Toggle(tBee, "Auto Use Abilities", false, function(v) S.autoAbil=v end)
        Dropdown(tBee, "Priority Ability", {"Rage","Inspire","Motivate","Concentrate"}, "Rage", function(v) S.beeAbil=v end)

    elseif gName == "Flee the Facility" then
        local tSurv  = AddTab("Survivor")
        local tBeast = AddTab("Beast")
        local tMove  = MoveTab()
        local tVis   = ESPTab()
        ActivateTab("Survivor")

        Section(tSurv, "SURVIVOR")
        Toggle(tSurv, "Auto Hack Computer", false, function(v) S.autoHack=v
            Notify("FTF", v and "Auto hacking" or "Stopped", "success")
        end, "Auto hacks nearby computers")
        Toggle(tSurv, "Instant Hack", false, function(v) S.instHack=v end)
        Toggle(tSurv, "Auto Free Teammates", false, function(v) S.autoFree=v end)
        Toggle(tSurv, "Show Beast Position", false, function(v) S.showBeast=v end)
        Button(tSurv, "💻 TP to Nearest Computer", function()
            local c = GetChar()
            local root = GetRoot()
            if not (c and root) then return end
            local best, bd = nil, math.huge
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj.Name:lower():find("computer") and obj:IsA("BasePart") then
                    local d = (obj.Position - root.Position).Magnitude
                    if d < bd then bd=d; best=obj end
                end
            end
            if best then c:SetPrimaryPartCFrame(best.CFrame+Vector3.new(0,5,0)) end
            Notify("FTF", best and "Teleported to computer!" or "No computer found", best and "success" or "warning")
        end, gColor)
        Button(tSurv, "🚪 TP to Exit", function()
            local c = GetChar()
            local exit = workspace:FindFirstChild("Exit") or workspace:FindFirstChild("Door")
            if c and exit then c:SetPrimaryPartCFrame(exit.CFrame+Vector3.new(0,5,0)) end
            Notify("FTF", exit and "Teleported to exit!" or "Exit not found", exit and "success" or "warning")
        end, C.Good)

        Section(tBeast, "BEAST")
        Slider(tBeast, "Beast Speed", 16, 120, 60, function(v) SetWS(v) end, " wsp")
        Toggle(tBeast, "Auto Catch Survivors", false, function(v) S.autoCatch=v end)
        Toggle(tBeast, "Show All Survivors", false, function(v) S.showSurvivors=v end)
        Toggle(tBeast, "Extended Smash Reach", false, function(v) S.extSmash=v end)
        Slider(tBeast, "Smash Reach", 5, 50, 10, function(v) S.smashReach=v end, " st")

    elseif gName == "Natural Disasters" then
        local tSurv = AddTab("Survival")
        local tDis  = AddTab("Disasters")
        local tMove = MoveTab()
        ActivateTab("Survival")

        Section(tSurv, "PROTECTION")
        Toggle(tSurv, "God Mode", false, function(v) SetGod(v) end, "Immune to all disasters")
        Toggle(tSurv, "Anti Damage", false, function(v) S.antiDmg=v end)
        Toggle(tSurv, "No Ragdoll", false, function(v) S.noRagdoll=v end)
        Toggle(tSurv, "Auto TP to Safety", false, function(v) S.autoSafe=v end)
        Button(tSurv, "⬆ TP to Highest Point", function()
            local root = GetRoot()
            if not root then return end
            local highest = 0
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Position.Y > highest then highest = v.Position.Y end
            end
            root.CFrame = CFrame.new(root.Position.X, highest+10, root.Position.Z)
            Notify("NDS", "Teleported to highest point!", "success")
        end, gColor)

        Section(tDis, "DISASTER IMMUNITY")
        Toggle(tDis, "No Acid Rain", false, function(v) S.noAcid=v end)
        Toggle(tDis, "No Meteors", false, function(v) S.noMeteors=v end)
        Toggle(tDis, "No Flood", false, function(v) S.noFlood=v end)
        Toggle(tDis, "No Fire", false, function(v) S.noFire=v end)
        Toggle(tDis, "No Tornado", false, function(v) S.noTornado=v end)
        Toggle(tDis, "No Earthquake", false, function(v) S.noQuake=v end)
        Toggle(tDis, "Show Disaster Name", true, function(v) S.showDisaster=v end)

    elseif gName == "Slime RNG" then
        local tFarm = AddTab("Auto Farm")
        local tRNG  = AddTab("RNG")
        local tMove = MoveTab()
        ActivateTab("Auto Farm")

        Section(tFarm, "ROLLING")
        Toggle(tFarm, "Auto Roll", false, function(v) S.autoRoll=v
            Notify("Slime RNG", v and "Auto rolling!" or "Stopped", "success")
        end, "Automatically rolls for slimes")
        Slider(tFarm, "Roll Speed", 1, 30, 5, function(v) S.rollSpd=v end, "/s")
        Toggle(tFarm, "Stop on Target Rarity", true, function(v) S.stopOnTarget=v end)
        Section(tFarm, "COLLECT")
        Toggle(tFarm, "Auto Collect Slimes", false, function(v) S.autoCollect=v end)
        Toggle(tFarm, "Auto Sell", false, function(v) S.autoSell=v end)
        Toggle(tFarm, "Magnet Collect", false, function(v) S.magnet=v end, "Pulls slimes to you")
        Button(tFarm, "📊 Print Roll Stats", function()
            warn("[Slime RNG] Total Rolls: "..(S.rollCount or 0))
            Notify("Slime RNG", "Stats printed to output", "info")
        end, C.Btn)

        Section(tRNG, "LUCK")
        Dropdown(tRNG, "Target Rarity", {"Common","Uncommon","Rare","Epic","Legendary","Mythic","Divine","Celestial","Secret"}, "Legendary", function(v) S.targetRarity=v
            Notify("Slime RNG", "Target: "..v, "info")
        end)
        Slider(tRNG, "Luck Boost", 0, 1000, 0, function(v) S.luckBoost=v end, "%")
        Toggle(tRNG, "Auto Use Potions", false, function(v) S.autoPotions=v end)
        Dropdown(tRNG, "Potion Priority", {"Luck","Time","Size","Speed"}, "Luck", function(v) S.potionPrio=v end)

    elseif gName == "Grow a Garden" then
        local tFarm  = AddTab("Farming")
        local tCrops = AddTab("Crops")
        local tMove  = MoveTab()
        ActivateTab("Farming")

        Section(tFarm, "AUTO FARMING")
        Toggle(tFarm, "Auto Water Plants", false, function(v) S.autoWater=v
            Notify("Garden", v and "Watering plants" or "Stopped", "success")
        end, "Keeps all plants watered")
        Toggle(tFarm, "Auto Harvest Crops", false, function(v) S.autoHarvest=v end)
        Toggle(tFarm, "Auto Replant Seeds", false, function(v) S.autoReplant=v end)
        Toggle(tFarm, "Auto Sell Crops", false, function(v) S.autoSell=v end)
        Section(tFarm, "GROWTH MODS")
        Toggle(tFarm, "Instant Grow", false, function(v) S.instGrow=v end, "Crops grow immediately")
        Slider(tFarm, "Grow Speed Mult", 1, 50, 1, function(v) S.growSpd=v end, "x")
        Toggle(tFarm, "Never Wilt", false, function(v) S.neverWilt=v end)

        Section(tCrops, "CROP MANAGER")
        Dropdown(tCrops, "Crop Type", {"Tomato","Carrot","Sunflower","Corn","Pumpkin","Roses","Strawberry","Watermelon","Potato","Wheat"}, "Tomato", function(v) S.cropType=v end)
        Button(tCrops, "🌱 Plant Selected Crop", function()
            Notify("Garden", "Planting: "..(S.cropType or "Tomato"), "success")
        end, gColor)
        Button(tCrops, "🌾 Harvest All Now", function()
            Notify("Garden", "Harvesting all crops!", "success")
        end, C.Good)
        Toggle(tCrops, "Alert When Ready", true, function(v) S.alertReady=v end)

    elseif gName == "Bloxstrike" then
        local tAim  = AddTab("Aimbot")
        local tGun  = AddTab("Weapons")
        local tMove = MoveTab()
        local tVis  = ESPTab()
        ActivateTab("Aimbot")

        Section(tAim, "AIMBOT")
        Toggle(tAim, "Aimbot", false, function(v) S.aimbot=v
            Notify("Bloxstrike", v and "Aimbot ON" or "OFF", v and "success" or "warning")
        end)
        Toggle(tAim, "Silent Aim", false, function(v) S.silentAim=v end)
        Slider(tAim, "FOV", 10, 600, 180, function(v) S.fov=v end, " px")
        Slider(tAim, "Smoothness", 1, 30, 6, function(v) S.smooth=v end)
        Slider(tAim, "Prediction", 0, 20, 5, function(v) S.predict=v end)
        Dropdown(tAim, "Target Part", {"Head","HumanoidRootPart","Torso"}, "Head", function(v) S.tPart=v end)
        Section(tAim, "TRIGGERBOT")
        Toggle(tAim, "Triggerbot", false, function(v) S.trigger=v end)
        Slider(tAim, "Trigger Delay", 0, 300, 50, function(v) S.trigDelay=v end, " ms")

        Section(tGun, "WEAPONS")
        Toggle(tGun, "No Recoil", false, function(v) S.noRecoil=v end)
        Toggle(tGun, "No Spread", false, function(v) S.noSpread=v end)
        Toggle(tGun, "Rapid Fire", false, function(v) S.rapidFire=v end)
        Toggle(tGun, "Infinite Ammo", false, function(v) S.infAmmo=v end)
        Toggle(tGun, "Flashbang Immunity", false, function(v) S.noFlash=v end)
        Slider(tGun, "Bullet Speed", 500, 10000, 2000, function(v) S.bulletSpd=v end)

    elseif gName == "Break Your Bones" then
        local tPhys = AddTab("Physics")
        local tGrav = AddTab("Gravity")
        local tMove = MoveTab()
        ActivateTab("Physics")

        Section(tPhys, "LAUNCH")
        Slider(tPhys, "Launch Force", 100, 10000, 1000, function(v) S.force=v end, " f")
        Dropdown(tPhys, "Direction", {"Up","Forward","Random","Spin","All Directions"}, "Up", function(v) S.launchDir=v end)
        Button(tPhys, "💥 LAUNCH NOW!", function()
            local root = GetRoot()
            if not root then return end
            local f = S.force or 1000
            local d = S.launchDir or "Up"
            local vel
            if d=="Up" then vel=Vector3.new(0,f,0)
            elseif d=="Forward" then vel=Cam.CFrame.LookVector*f
            elseif d=="Random" then vel=Vector3.new(math.random(-f,f),f,math.random(-f,f))
            elseif d=="Spin" then vel=Vector3.new(f,f/2,f)
            else vel=Vector3.new(math.random(-f,f),math.random(0,f),math.random(-f,f)) end
            root.Velocity = vel
            Notify("BYB", "Launched! Force: "..f, "success")
        end, gColor)
        Toggle(tPhys, "Auto Launch Loop", false, function(v) S.autoLaunch=v end)
        Slider(tPhys, "Auto Launch Interval", 1, 30, 5, function(v) S.launchInt=v end, "s")
        Button(tPhys, "📉 Drop from Sky (500 studs)", function()
            local root = GetRoot()
            if not root then return end
            root.CFrame = CFrame.new(root.Position+Vector3.new(0,500,0))
            Notify("BYB", "Dropping from 500 studs!", "info")
        end, C.Btn)
        Button(tPhys, "🌍 Drop from Space (2000 studs)", function()
            local root = GetRoot()
            if not root then return end
            root.CFrame = CFrame.new(root.Position+Vector3.new(0,2000,0))
            Notify("BYB", "Dropping from 2000 studs!", "success")
        end, C.Btn)

        Section(tGrav, "GRAVITY CONTROL")
        Slider(tGrav, "Gravity", 0, 600, 196, function(v) workspace.Gravity=v end, " g")
        Toggle(tGrav, "Zero Gravity", false, function(v) workspace.Gravity=v and 0.1 or 196.2 end)
        Toggle(tGrav, "Moon Gravity", false, function(v) workspace.Gravity=v and 20 or 196.2 end)
        Toggle(tGrav, "Hyper Gravity", false, function(v) workspace.Gravity=v and 600 or 196.2 end)
        Button(tGrav, "🔄 Reset Gravity", function()
            workspace.Gravity = 196.2
            Notify("BYB", "Gravity reset to normal", "success")
        end, C.Btn)

    elseif gName == "Rivals" then
        local tCombat = AddTab("Combat")
        local tMove   = MoveTab()
        local tVis    = ESPTab()
        ActivateTab("Combat")

        Section(tCombat, "COMBAT")
        Toggle(tCombat, "Aimbot", false, function(v) S.aimbot=v
            Notify("Rivals", v and "Aimbot ON" or "OFF", v and "success" or "warning")
        end)
        Toggle(tCombat, "Auto Parry", false, function(v) S.autoParry=v end, "Times parry automatically")
        Toggle(tCombat, "Auto Block", false, function(v) S.autoBlock=v end)
        Toggle(tCombat, "Perfect Timing", false, function(v) S.perfectTiming=v end)
        Slider(tCombat, "FOV", 50, 400, 150, function(v) S.fov=v end, " px")
        Slider(tCombat, "Parry Window", 50, 500, 150, function(v) S.parryWin=v end, " ms")
        Section(tCombat, "MOVEMENT")
        Toggle(tCombat, "Bunny Hop", false, function(v) S.bunnyHop=v end)
        Toggle(tCombat, "Strafe Assist", false, function(v) S.strafe=v end)
        Toggle(tCombat, "God Mode", false, function(v) SetGod(v) end)

    elseif gName == "Hypershot" then
        local tAim   = AddTab("Aim")
        local tTrain = AddTab("Training")
        local tMove  = MoveTab()
        ActivateTab("Aim")

        Section(tAim, "AIM ASSIST")
        Toggle(tAim, "Aim Assist", false, function(v) S.aimAssist=v
            Notify("Hypershot", v and "Aim assist ON" or "OFF", "info")
        end)
        Slider(tAim, "Assist Strength", 1, 100, 50, function(v) S.assistStr=v end, "%")
        Slider(tAim, "FOV", 10, 300, 100, function(v) S.fov=v end, " px")
        Dropdown(tAim, "Target Part", {"Head","Torso","HumanoidRootPart"}, "Head", function(v) S.tPart=v end)
        Toggle(tAim, "Auto Click", false, function(v) S.autoClick=v end)

        Section(tTrain, "TRAINING")
        Toggle(tTrain, "Auto Aim Targets", false, function(v) S.autoAim=v end)
        Slider(tTrain, "Reaction Time", 10, 500, 200, function(v) S.reaction=v end, " ms")
        Toggle(tTrain, "Slow Motion", false, function(v) workspace.Gravity=v and 20 or 196.2 end)
        Button(tTrain, "🔄 Reset Score", function()
            Notify("Hypershot", "Score reset (test)", "info")
        end, C.Danger)

    elseif gName == "Combat Arena" then
        local tCombat = AddTab("Combat")
        local tMove   = MoveTab()
        local tVis    = ESPTab()
        ActivateTab("Combat")

        Section(tCombat, "COMBAT")
        Toggle(tCombat, "Aimbot", false, function(v) S.aimbot=v
            Notify("Combat Arena", v and "Aimbot ON" or "OFF", "info")
        end)
        Toggle(tCombat, "Auto Combo", false, function(v) S.autoCombo=v end)
        Toggle(tCombat, "Auto Block", false, function(v) S.autoBlock=v end)
        Toggle(tCombat, "Auto Dodge", false, function(v) S.autoDodge=v end)
        Slider(tCombat, "Combo Speed", 1, 20, 5, function(v) S.comboSpd=v end)
        Slider(tCombat, "Hit Reach", 5, 50, 10, function(v) S.reach=v end, " st")
        Toggle(tCombat, "God Mode", false, function(v) SetGod(v) end)
        Toggle(tCombat, "One Shot", false, function(v) S.oneShot=v end)

    elseif gName == "Steal a Brainrot" then
        local tSteal = AddTab("Steal")
        local tDef   = AddTab("Defense")
        local tMove  = MoveTab()
        ActivateTab("Steal")

        Section(tSteal, "STEALING")
        Toggle(tSteal, "Auto Steal", false, function(v) S.autoSteal=v
            Notify("Steal a Brainrot", v and "Auto stealing" or "Stopped", "success")
        end, "Automatically steals brainrots")
        Toggle(tSteal, "Instant Steal", false, function(v) S.instSteal=v end)
        Toggle(tSteal, "ESP Brainrots", false, function(v) S.brainESP=v end)
        Slider(tSteal, "Steal Range", 5, 100, 20, function(v) S.stealRange=v end, " st")
        Button(tSteal, "🧠 Collect All Nearby", function()
            Notify("Steal a Brainrot", "Collecting nearby!", "success")
        end, gColor)

        Section(tDef, "DEFENSE")
        Toggle(tDef, "Anti Steal", false, function(v) S.antiSteal=v end, "Protect your brainrots")
        Toggle(tDef, "Notify on Theft", true, function(v) S.notifyTheft=v end)
        Toggle(tDef, "God Mode", false, function(v) SetGod(v) end)

    elseif gName == "One Tap" then
        local tAim  = AddTab("Aimbot")
        local tGun  = AddTab("Weapons")
        local tMove = MoveTab()
        local tVis  = ESPTab()
        ActivateTab("Aimbot")

        Section(tAim, "AIMBOT")
        Toggle(tAim, "Aimbot", false, function(v) S.aimbot=v
            Notify("One Tap", v and "Aimbot ON" or "OFF", "info")
        end)
        Toggle(tAim, "Silent Aim", false, function(v) S.silentAim=v end)
        Slider(tAim, "FOV", 10, 400, 120, function(v) S.fov=v end, " px")
        Slider(tAim, "Smoothness", 1, 20, 5, function(v) S.smooth=v end)
        Dropdown(tAim, "Target Part", {"Head","HumanoidRootPart","Torso"}, "Head", function(v) S.tPart=v end)
        Section(tGun, "WEAPONS")
        Toggle(tGun, "No Recoil", false, function(v) S.noRecoil=v end)
        Toggle(tGun, "Rapid Fire", false, function(v) S.rapidFire=v end)
        Toggle(tGun, "Infinite Ammo", false, function(v) S.infAmmo=v end)
        Toggle(tGun, "One Shot Kill", false, function(v) S.oneShot=v end)

    elseif gName == "Pet Simulator X" then
        local tFarm = AddTab("Farming")
        local tPets = AddTab("Pets")
        local tMove = MoveTab()
        ActivateTab("Farming")

        Section(tFarm, "AUTO FARM")
        Toggle(tFarm, "Auto Break Eggs", false, function(v) S.autoBreak=v
            Notify("PSX", v and "Breaking eggs" or "Stopped", "success")
        end)
        Toggle(tFarm, "Auto Collect Coins", false, function(v) S.autoCoins=v end)
        Toggle(tFarm, "Auto Sell Pets", false, function(v) S.autoSell=v end)
        Toggle(tFarm, "Auto Open Chests", false, function(v) S.autoChests=v end)
        Dropdown(tFarm, "Target Area", {"Spawn","Forest","Desert","Space","Underworld","Candy Land"}, "Spawn", function(v) S.area=v end)
        Button(tFarm, "📍 Go to Area", function()
            Notify("PSX", "Going to "..(S.area or "Spawn"), "info")
        end, gColor)

        Section(tPets, "PETS")
        Toggle(tPets, "Huge Pet Notifier", true, function(v) S.hugeNotify=v end)
        Toggle(tPets, "Auto Equip Best Pets", false, function(v) S.autoEquip=v end)
        Toggle(tPets, "Auto Fuse Pets", false, function(v) S.autoFuse=v end)
        Toggle(tPets, "Pet ESP", false, function(v) S.petESP=v end)

    elseif gName == "Adopt Me!" then
        local tRP   = AddTab("Roleplay")
        local tPets = AddTab("Pets")
        local tMove = MoveTab()
        ActivateTab("Roleplay")

        Section(tRP, "PLAYER")
        Toggle(tRP, "Speed Boost", false, function(v) SetWS(v and 80 or 16) end)
        Toggle(tRP, "No Clip", false, function(v) S.noClip=v end)
        Toggle(tRP, "Fly Mode", false, function(v) S.fly=v end)
        Section(tRP, "TASKS")
        Toggle(tRP, "Auto Feed Pets", false, function(v) S.autoFeed=v end)
        Toggle(tRP, "Auto Age Up", false, function(v) S.autoAge=v end)
        Toggle(tRP, "Auto Daily Login", false, function(v) S.autoLogin=v end)
        Button(tRP, "🏠 Teleport to Home", function()
            local home = workspace:FindFirstChild("Homes") or workspace:FindFirstChild("Home")
            local c = GetChar()
            if c and home then c:SetPrimaryPartCFrame(home.CFrame+Vector3.new(0,5,0)) end
            Notify("Adopt Me", home and "Teleported home!" or "Home not found", home and "success" or "warning")
        end, gColor)

        Section(tPets, "PETS")
        Toggle(tPets, "Pet ESP", false, function(v) S.petESP=v end)
        Toggle(tPets, "Legendary Notifier", true, function(v) S.legNotify=v end)
        Toggle(tPets, "Auto Trade Accept", false, function(v) S.autoTrade=v end)

    else
        -- GENERIC
        local tGen  = AddTab("General")
        local tMove = MoveTab()
        local tVis  = ESPTab()
        ActivateTab("General")

        Section(tGen, "GENERAL")
        Toggle(tGen, "God Mode", false, function(v) SetGod(v) end)
        Toggle(tGen, "Anti AFK", true, function(v) S.antiAFK=v end)
        Section(tGen, "COMBAT")
        Toggle(tGen, "Aimbot", false, function(v) S.aimbot=v end)
        Toggle(tGen, "No Recoil", false, function(v) S.noRecoil=v end)
        Toggle(tGen, "Infinite Ammo", false, function(v) S.infAmmo=v end)
        Toggle(tGen, "Rapid Fire", false, function(v) S.rapidFire=v end)
        Section(tGen, "FARMING")
        Toggle(tGen, "Auto Farm", false, function(v) S.autoFarm=v
            Notify(gName, v and "Auto farm ON" or "OFF", "success")
        end)
        Toggle(tGen, "Auto Collect", false, function(v) S.autoCollect=v end)
        Button(tGen, "💀 Eliminate All (Test)", function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local h = p.Character:FindFirstChild("Humanoid")
                    if h then h.Health=0 end
                end
            end
            Notify(gName, "Eliminated all (test)", "success")
        end, C.Danger)
    end

    -- Open animation
    win.Size = UDim2.new(0,0,0,0)
    Tw(win, {Size=UDim2.new(0,410,0,530)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
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
        local match = filter=="" or g.name:lower():find(filter,1,true) or g.desc:lower():find(filter,1,true)
        if not match then continue end
        count += 1

        local btn = MkBtn(gameScroll, "", UDim2.new(1,0,0,54), nil, C.BG2, C.White, 13)
        MkCorner(btn, 9)
        local bStroke = MkStroke(btn, C.Border, 1)

        local ibg = MkFrame(btn, UDim2.new(0,40,0,40), UDim2.new(0,8,0.5,-20), g.color)
        MkCorner(ibg, 9)
        local iL = MkLabel(ibg, g.icon, 20, C.White, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        iL.Size = UDim2.new(1,0,1,0)

        local nL = MkLabel(btn, g.name, 14, C.Text, Enum.Font.GothamBold)
        nL.Size = UDim2.new(1,-100,0,20)
        nL.Position = UDim2.new(0,58,0,9)

        local dL = MkLabel(btn, g.desc, 11, C.TextMute, Enum.Font.Gotham)
        dL.Size = UDim2.new(1,-100,0,16)
        dL.Position = UDim2.new(0,58,0,30)

        local arr = MkLabel(btn, "›", 26, C.TextMute, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        arr.Size = UDim2.new(0,26,1,0)
        arr.Position = UDim2.new(1,-32,0,0)

        local gc, gi, gn = g.color, g.icon, g.name

        btn.MouseEnter:Connect(function()
            Tw(btn, {BackgroundColor3=C.BG3}, 0.15)
            Tw(bStroke, {Color=gc}, 0.15)
            Tw(arr, {TextColor3=gc}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Tw(btn, {BackgroundColor3=C.BG2}, 0.15)
            Tw(bStroke, {Color=C.Border}, 0.15)
            Tw(arr, {TextColor3=C.TextMute}, 0.15)
        end)
        btn.MouseButton1Click:Connect(function()
            MakeWindow(gn, gc, gi)
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
-- FLY + NOCLIP + INF JUMP RUNTIME
-- ================================================================
RunService.Heartbeat:Connect(function()
    local char = GetChar()
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChild("Humanoid")
    if not (root and hum) then return end

    for _, S in pairs(States) do
        -- Noclip
        if S.noClip then
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end

        -- Fly
        if S.fly then
            if not S._flyOn then
                S._flyOn = true
                hum.PlatformStand = true
                local bg = Instance.new("BodyGyro", root)
                bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
                bg.D = 150; bg.P = 10000
                local bv = Instance.new("BodyVelocity", root)
                bv.MaxForce = Vector3.new(1e9,1e9,1e9)
                bv.Velocity = Vector3.new(0,0,0)
                S._bg = bg; S._bv = bv
            end
            if S._bv and S._bg then
                local sp = S.flySpeed or 60
                local dir = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
                local mag = dir.Magnitude
                S._bv.Velocity = mag > 0 and (dir/mag)*sp or Vector3.new(0,0,0)
                S._bg.CFrame = Cam.CFrame
            end
        elseif S._flyOn then
            S._flyOn = false
            hum.PlatformStand = false
            if S._bg then S._bg:Destroy(); S._bg=nil end
            if S._bv then S._bv:Destroy(); S._bv=nil end
        end
    end
end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.Space then
        for _, S in pairs(States) do
            if S.infJump then
                local h = GetHum()
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end
    end
    if inp.KeyCode == HubKeybind then
        togBtn.MouseButton1Click:Fire()
    end
end)

-- ================================================================
-- STARTUP ANIMATION
-- ================================================================
Hub.Visible = true
Hub.Size = UDim2.new(0,340,0,0)
task.wait(0.2)
Tw(Hub, {Size=UDim2.new(0,340,0,560)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
task.delay(1.2, function()
    Notify("Script Hub v3.0", #GAMES.." games loaded and ready!", "success", 5)
    task.wait(0.4)
    Notify("Controls", "RightShift = toggle hub • Drag title bars to move windows", "info", 5)
end)

print("✅ Hub v3.0 loaded | "..#GAMES.." games | loadstring compatible")
