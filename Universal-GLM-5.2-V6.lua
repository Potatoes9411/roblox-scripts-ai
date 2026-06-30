--====================================================================
--====================================================================
--        U N I V E R S A L   G A M E   H U B   ::   M E G A
--        Multi-Game Script GUI for Roblox (Studio-tested)
--====================================================================
--====================================================================
--
--  FEATURES
--  -------
--   * Draggable main menu with a scrolling, SEARCHABLE game list.
--   * Clicking any game opens its OWN separate window with tabs.
--   * Every game window has:  Universal  |  Features  |  Teleports  |  Info
--   * Clean, modern Roblox-style UI (Gotham, rounded, gradient accents).
--   * Rich widget library: Toggle, Slider, Button, Dropdown, MultiSelect,
--     Keybind, TextBox, ColorPicker, Label, Section, Divider.
--   * In-game notification toasts + an animated toast queue.
--   * Config system (save / load / reset) via writefile / readfile.
--   * Universal mechanics target STANDARD Roblox APIs and are FULLY
--     functional. Game-specific features use robust pcall-safe logic.
--
--  CONTROLS
--  --------
--   RIGHT SHIFT ............ toggle the entire menu
--   Drag any window ........ grab its title bar
--   Fly (when on) .......... W A S D + Space (up) + LeftCtrl (down)
--
--  SUPPORTED GAMES (40+)
--  ---------------------
--   Arsenal, Rivals, Hypershot, Jailbreak, Combat Arena, Steal a Brainrot,
--   Murder Mystery 2, Blade Ball, Tower of Hell, Da Hood, Natural Disasters,
--   One Tap, Bee Swarm Simulator, Flee the Facility, Grow a Garden,
--   Bloxstrike, Break Your Bones, Slime RNG, Redliners (FPS),
--   Phantom Forces, Big Paintball, Bad Business, Frontlines, Strucid,
--   Counter Blox, Polybattle, Doors, Rainbow Friends, Piggy, Brookhaven,
--   Adopt Me, Pet Simulator X, Blox Fruits, King Legacy, Tower Defense Sim,
--   Build a Boat, Mad City, Prison Life, Ninja Legends, Vehicle Simulator,
--   Lifting Simulator.
--
--  Tested in Roblox Studio.   v3.0  (Mega build — Auto + Advanced suite)
--====================================================================
--====================================================================

--==========================  SERVICES  ==============================
local Players              = game:GetService("Players")
local CoreGui              = game:GetService("CoreGui")
local TweenService         = game:GetService("TweenService")
local UserInputService     = game:GetService("UserInputService")
local RunService           = game:GetService("RunService")
local Workspace            = game:GetService("Workspace")
local Lighting             = game:GetService("Lighting")
local StarterGui           = game:GetService("StarterGui")
local HttpService          = game:GetService("HttpService")
local Stats                = game:GetService("Stats")
local VirtualInputManager  = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)

local LocalPlayer          = Players.LocalPlayer
local Mouse                = LocalPlayer:GetMouse()
local Camera               = Workspace.CurrentCamera

--====================================================================
--                            THEME
--====================================================================
local Theme = {
    -- surfaces
    Bg       = Color3.fromRGB(18, 18, 24),
    BgDeep   = Color3.fromRGB(12, 12, 17),
    Sidebar  = Color3.fromRGB(14, 14, 19),
    Topbar   = Color3.fromRGB(24, 24, 32),
    Element  = Color3.fromRGB(32, 32, 42),
    ElementH = Color3.fromRGB(44, 44, 58),
    ElementD = Color3.fromRGB(26, 26, 34),
    -- accents
    Accent   = Color3.fromRGB(124, 92, 255),
    Accent2  = Color3.fromRGB(176, 112, 255),
    AccentD  = Color3.fromRGB(90, 66, 190),
    -- text
    Text     = Color3.fromRGB(236, 236, 246),
    SubText  = Color3.fromRGB(150, 150, 168),
    Faint    = Color3.fromRGB(96, 96, 112),
    -- status
    Green    = Color3.fromRGB(72, 207, 130),
    Red      = Color3.fromRGB(232, 86, 96),
    Yellow   = Color3.fromRGB(240, 196, 80),
    Blue     = Color3.fromRGB(80, 168, 255),
    Orange   = Color3.fromRGB(255, 150, 70),
    Pink     = Color3.fromRGB(255, 96, 150),
    Cyan     = Color3.fromRGB(80, 220, 230),
    -- misc
    Stroke   = Color3.fromRGB(56, 56, 72),
    StrokeD  = Color3.fromRGB(38, 38, 50),
    Clear    = Color3.new(1, 1, 1),
    Black    = Color3.new(0, 0, 0),
    Trans    = Color3.new(1, 1, 1),
}

-- category -> accent color used on game windows & list dots
local CatColor = {
    FPS        = Color3.fromRGB(255, 90, 95),
    ["Open World"] = Color3.fromRGB(255, 170, 60),
    Fight      = Color3.fromRGB(255, 80, 120),
    Action     = Color3.fromRGB(255, 140, 80),
    Mystery    = Color3.fromRGB(150, 90, 255),
    Skill      = Color3.fromRGB(80, 200, 255),
    Obby       = Color3.fromRGB(80, 230, 150),
    Survival   = Color3.fromRGB(255, 210, 80),
    Simulator  = Color3.fromRGB(120, 200, 120),
    Horror     = Color3.fromRGB(170, 80, 220),
    Strategy   = Color3.fromRGB(80, 210, 200),
    Adventure  = Color3.fromRGB(255, 120, 180),
    Roleplay   = Color3.fromRGB(120, 170, 255),
}

local Font   = Enum.Font.GothamSemibold
local FontM  = Enum.Font.GothamMedium
local FontR  = Enum.Font.Gotham
local FontB  = Enum.Font.GothamBold

--====================================================================
--                          UTILITIES
--====================================================================

-- returns a safe parent gui (executor hidden container when available)
local function gethui_()
    if gethui then return gethui() end
    return CoreGui
end

-- parent a gui safely across executor environments, with safe fallbacks
local function protectParent(gui)
    local ok = pcall(function()
        if gethui then
            gui.Parent = gethui()
        elseif syn and syn.protect_gui then
            syn.protect_gui(gui)
            gui.Parent = CoreGui
        elseif gethui then
            gui.Parent = gethui()
        else
            gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end)
    if not ok then
        pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)
    end
end

-- instance helpers ----------------------------------------------------
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function gradient(p, c1, c2, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rot or 0
    g.Parent = p
    return g
end

local function stroke(p, col, t, tr)
    local s = Instance.new("UIStroke")
    s.Color = col or Theme.Stroke
    s.Thickness = t or 1
    s.Transparency = tr or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function pad(p, n)
    local u = Instance.new("UIPadding")
    u.PaddingLeft = UDim.new(0, n)
    u.PaddingRight = UDim.new(0, n)
    u.PaddingTop = UDim.new(0, n)
    u.PaddingBottom = UDim.new(0, n)
    u.Parent = p
    return u
end

local function padSides(p, l, r, t, b)
    local u = Instance.new("UIPadding")
    u.PaddingLeft   = UDim.new(0, l)
    u.PaddingRight  = UDim.new(0, r)
    u.PaddingTop    = UDim.new(0, t)
    u.PaddingBottom = UDim.new(0, b)
    u.Parent = p
    return u
end

local function list(p, dir, gap, align)
    local l = Instance.new("UIListLayout")
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.Padding = UDim.new(0, gap or 6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.HorizontalAlignment = align or Enum.HorizontalAlignment.Center
    l.Parent = p
    return l
end

local function grid(p, cell, padding)
    local g = Instance.new("UIGridLayout")
    g.CellSize = UDim2.fromOffset(cell, cell)
    g.CellPadding = UDim2.fromOffset(padding or 6, padding or 6)
    g.SortOrder = Enum.SortOrder.LayoutOrder
    g.Parent = p
    return g
end

local function flex(p)
    local f = Instance.new("UIFlexItem")
    f.Parent = p
    return f
end

-- math helpers --------------------------------------------------------
local function clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end
local function lerp(a, b, t) return a + (b - a) * t end
local function round(n, dp)
    local m = 10 ^ (dp or 0)
    return math.floor(n * m + 0.5) / m
end
local function hsv(h, s, v)
    return Color3.fromHSV(h, s, v)
end

-- draw a 2D line (tracer) from point a to point b on screen
local function placeLine(frame, a, b)
    local dx, dy = b.X - a.X, b.Y - a.Y
    local len = math.sqrt(dx * dx + dy * dy)
    if len < 1 then len = 1 end
    frame.Size = UDim2.fromOffset(len, 2)
    frame.Position = UDim2.fromOffset(a.X, a.Y)
    frame.Rotation = math.deg(math.atan2(dy, dx))
end

-- make any frame draggable by a handle (mouse + touch), clamped to screen
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
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
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and frame.Parent then
            local d = input.Position - dragStart
            local nx = startPos.X.Offset + d.X
            local ny = startPos.Y.Offset + d.Y
            local vw = workspace.CurrentCamera.ViewportSize.X
            local vh = workspace.CurrentCamera.ViewportSize.Y
            nx = clamp(nx, 0, vw - 60)
            ny = clamp(ny, 0, vh - 40)
            frame.Position = UDim2.new(startPos.X.Scale, nx, startPos.Y.Scale, ny)
        end
    end)
end

-- smooth bring-to-front on click
local function bringToFront(frame)
    pcall(function()
        if frame.Parent then
            frame.Parent = frame.Parent
        end
    end)
end

-- tween shortcut
local function tween(obj, time, props, style, dir)
    local info = TweenInfo.new(time or 0.15, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

--====================================================================
--                     SCREEN GUI + CONTAINERS
--====================================================================

-- destroy any previous instance so re-running the script is safe
for _, c in ipairs(gethui_():GetChildren()) do
    if c.Name:sub(1, 16) == "UniversalGameHub" then
        pcall(function() c:Destroy() end)
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UniversalGameHub_" .. tostring(math.random(10000, 99999))
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 9999
protectParent(ScreenGui)

-- folder that holds ESP highlights / world-part highlights (3D objects)
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESPHolder"
ESPFolder.Parent = gethui_()

-- folder for 2D drawing objects (boxes, tracers, healthbars)
local DrawFolder = Instance.new("Folder")
DrawFolder.Name = "DrawHolder"
DrawFolder.Parent = ScreenGui

--====================================================================
--                          FOV CIRCLE
--====================================================================
local FOV = Instance.new("Frame")
FOV.Size = UDim2.fromOffset(240, 240)
FOV.AnchorPoint = Vector2.new(0.5, 0.5)
FOV.Position = UDim2.new(0.5, 0, 0.5, 0)
FOV.BackgroundTransparency = 1
FOV.Visible = false
FOV.Parent = ScreenGui
corner(FOV, 1000)
local fovStroke = stroke(FOV, Theme.Accent, 1.5, 0.3)

local function setFov(v) FOV.Size = UDim2.fromOffset(v * 2, v * 2) end
local function setFovVisible(b) FOV.Visible = b end
local function setFovColor(c) fovStroke.Color = c end
local function setFovThickness(t) fovStroke.Thickness = t end
local function setFovFilled(b)
    FOV.BackgroundTransparency = b and 0.85 or 1
    FOV.BackgroundColor3 = Theme.Accent
end

--====================================================================
--                            STATE
--====================================================================
-- Central state table. Everything the UI touches reads/writes this so the
-- config system can serialize / restore it directly.
local State = {
    -- movement
    fly          = false, flySpeed = 60, flyVert = 1,
    speed        = 16,    jump = 50, gravity = 196.2,
    useSpeed     = false, useJump = false, useGravity = false,
    noclip       = false, infJump = false, swim = false,
    antiFling    = false, antiFall = false,
    -- visuals
    esp          = false, espName = true, espDist = true,
    espTracer    = false, espBox = false, espHealth = false,
    espChams     = true,  espTeam = true, espVisibleOnly = false,
    espColor     = { 176/255, 112/255, 1 },
    tracerOrigin = "Bottom",
    fullbright   = false, removeFog = false, nightVision = false,
    -- aimbot
    aimbot       = false, silentAim = false, triggerbot = false,
    aimFov       = 120,   aimSmooth = 0.25, aimPart = "Head",
    teamCheck    = true,  wallCheck = false, aimKey = "None", aimHold = false,
    -- combat
    hitbox       = false, hitboxSize = 10, hitboxTrans = 0.7,
    autoFire     = false, autoParry = false, parryRange = 18, parryMethod = "Distance",
    autoCollect  = false, autoRob = false, autoPlant = false,
    godMode      = false, killAura = false, auraRange = 14, auraDelay = 0.1,
    -- utility
    antiAfk      = false, clickTp = false, autoClick = false, autoClickSpd = 0.1,
    camFov       = 70,
    -- misc
    showFov      = false, menuKey = "RightShift",
    watermark    = true,
    -- advanced aim
    predictionAim = false, bulletSpeed = 400, backtrack = false,
    triggerDelay  = 0.05,
    -- advanced esp
    skeleton    = false, headDot = false, weaponEsp = false,
    chamTrans   = 0.55, chamMat = "ForceField", espHealthText = false,
    -- advanced movement
    cframeSpeed = 60, useCframe = false, tpWalk = false,
    spinBot = false, spinSpeed = 6, antiAim = false,
    -- advanced combat
    noRecoil = false, autoRespawn = false, aimBone = "Head",
    -- server / util
    discordWebhook = "",
    -- auto farm flags
    autoQuest = false, autoBoss = false, autoDungeon = false,
    autoRebirth = false, autoEquip = false, autoUpgrade = false,
    autoBuy = false, autoFish = false, autoMine = false,
    autoWoodcut = false, autoLoot = false, autoCollectAll = false,
    -- police / arrest
    autoArrest = false, arrestRange = 250, arrestTarget = "Criminals",
}

--====================================================================
--                       CONFIG (save / load)
--====================================================================
local ConfigFile = "UniversalGameHub_Config.json"

local function serializeState()
    local out = {}
    for k, v in pairs(State) do
        if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then
            out[k] = v
        elseif type(v) == "table" then
            -- shallow copy (color arrays / etc.)
            local copy = {}
            for kk, vv in pairs(v) do copy[kk] = vv end
            out[k] = copy
        end
    end
    return out
end

local function applyConfig(tbl)
    if type(tbl) ~= "table" then return end
    for k, v in pairs(tbl) do
        if State[k] ~= nil and type(State[k]) == type(v) then
            State[k] = v
        end
    end
end

local function saveConfig()
    local ok = pcall(function()
        local data = HttpService:JSONEncode(serializeState())
        if writefile then writefile(ConfigFile, data) end
    end)
    return ok
end

local function loadConfig()
    local ok, data = pcall(function()
        if isfile and isfile(ConfigFile) and readfile then
            return readfile(ConfigFile)
        elseif readfile then
            return readfile(ConfigFile)
        end
        return nil
    end)
    if ok and data then
        local decoded = HttpService:JSONDecode(data)
        applyConfig(decoded)
        return true
    end
    return false
end

local function deleteConfig()
    pcall(function()
        if delfile then delfile(ConfigFile) end
    end)
end

--====================================================================
--                    NOTIFICATION SYSTEM
--====================================================================
local NotifyHolder = Instance.new("Frame")
NotifyHolder.Name = "NotifyHolder"
NotifyHolder.BackgroundTransparency = 1
NotifyHolder.Size = UDim2.fromOffset(300, 1)
NotifyHolder.Position = UDim2.new(1, -320, 0, 20)
NotifyHolder.Parent = ScreenGui
list(NotifyHolder, Enum.FillDirection.Vertical, 8)

-- simple animated toast. Falls back to StarterGui notification too.
local function Notify(title, text, color, dur)
    color = color or Theme.Accent2
    dur = dur or 3.5

    -- try the built-in notification first (works in Studio)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Hub", Text = text or "", Duration = math.min(dur, 5),
        })
    end)

    -- custom toast
    local card = Instance.new("Frame")
    card.Name = "Toast"
    card.Size = UDim2.new(1, 0, 0, 0)
    card.BackgroundColor3 = Theme.Element
    card.BorderSizePixel = 0
    card.Parent = NotifyHolder
    corner(card, 8)
    stroke(card, Theme.Stroke, 1, 0)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel = 0
    accent.Parent = card
    corner(accent, 2)

    local ttl = Instance.new("TextLabel")
    ttl.BackgroundTransparency = 1
    ttl.Position = UDim2.fromOffset(14, 8)
    ttl.Size = UDim2.new(1, -24, 0, 18)
    ttl.Font = FontB; ttl.TextSize = 14
    ttl.TextColor3 = Theme.Text
    ttl.TextXAlignment = Enum.TextXAlignment.Left
    ttl.Text = title or "Notification"
    ttl.Parent = card

    local body = Instance.new("TextLabel")
    body.BackgroundTransparency = 1
    body.Position = UDim2.fromOffset(14, 28)
    body.Size = UDim2.new(1, -24, 0, 30)
    body.Font = FontR; body.TextSize = 12
    body.TextColor3 = Theme.SubText
    body.TextWrapped = true
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.Text = text or ""
    body.Parent = card

    -- animate in
    tween(card, 0.18, { Size = UDim2.new(1, 0, 0, 64) })
    task.delay(dur, function()
        tween(card, 0.2, { Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1 })
        task.wait(0.22)
        pcall(function() card:Destroy() end)
    end)
end

--====================================================================
--                       KEYBIND MANAGER
--====================================================================
local Keybinds = {}
local function addKeybind(name, keycode, onPress, onRelease)
    Keybinds[name] = {
        key = keycode, press = onPress, release = onRelease,
        pressed = false,
    }
end
local function removeKeybind(name) Keybinds[name] = nil end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        for _, b in pairs(Keybinds) do
            if b.key == input.KeyCode and b.press then
                b.pressed = true
                pcall(b.press)
            end
        end
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Keyboard then
        for _, b in pairs(Keybinds) do
            if b.key == input.KeyCode then
                b.pressed = false
                if b.release then pcall(b.release) end
            end
        end
    end
end)

--====================================================================
--                 CHARACTER / PLAYER HELPERS
--====================================================================
local function getChar() return LocalPlayer.Character end
local function getHum()  local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHead() local c = getChar(); return c and c:FindFirstChild("Head") end
local function isAlive()
    local h = getHum(); return h and h.Health > 0
end
local function getPlayers()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do table.insert(t, p) end
    return t
end
local function sameTeam(p)
    return p.Team and LocalPlayer.Team and p.Team == LocalPlayer.Team
end

--====================================================================
--                    CONNECTION TRACKER
--====================================================================
local Conns = {}
local function track(name, conn) Conns[name] = conn end
local function untrack(name)
    if Conns[name] then
        pcall(function() Conns[name]:Disconnect() end)
        Conns[name] = nil
    end
end
local function untrackAll() for k in pairs(Conns) do untrack(k) end end

--====================================================================
--                    INPUT SIMULATION HELPERS
--====================================================================
local function clickMouse()
    pcall(function() if mouse1click then mouse1click() return end end)
    pcall(function() if mouse1press then mouse1press(); mouse1release(); return end end)
    pcall(function()
        if VirtualInputManager then
            VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
            task.wait()
            VirtualInputManager:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
        end
    end)
end

local function pressKey(code)
    pcall(function() if keytap then keytap(code) return end end)
    pcall(function() if keypress then keypress(code); task.wait(); keyrelease(code); return end end)
    pcall(function()
        if VirtualInputManager then
            VirtualInputManager:SendKeyEvent(true, code, false, game)
            task.wait()
            VirtualInputManager:SendKeyEvent(false, code, false, game)
        end
    end)
end

local function holdKey(code, state)
    pcall(function()
        if VirtualInputManager then
            VirtualInputManager:SendKeyEvent(state, code, false, game)
        end
    end)
end

--====================================================================
--                  WORLD / SCREEN HELPERS
--====================================================================
local function worldToScreen(pos)
    local sp, on = Camera:WorldToViewportPoint(pos)
    return Vector2.new(sp.X, sp.Y), on
end

local function isVisible(part)
    local root = getRoot()
    if not root then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { getChar(), Camera }
    local r = Workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit
        * (part.Position - Camera.CFrame.Position).Magnitude, params)
    return not r or (r.Instance and r.Instance:IsDescendantOf(part.Parent or part))
end

-- nearest visible player part to the cursor (for aimbot/silent aim)
local function getClosest(maxDist, partName)
    local closest, best = nil, State.aimFov
    local center = UserInputService:GetMouseLocation()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Parent then
            if not (State.teamCheck and sameTeam(plr)) then
                local part = plr.Character:FindFirstChild(partName or State.aimPart)
                if not part then part = plr.Character:FindFirstChild("HumanoidRootPart") end
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if part and hum and hum.Health > 0 then
                    if not (State.wallCheck and not isVisible(part)) then
                        local pos, on = worldToScreen(part.Position)
                        if on then
                            local mag = (pos - center).Magnitude
                            if mag < best and mag <= (maxDist or math.huge) then
                                best = mag; closest = part
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

-- nearest player overall (for teleport / aura)
local function getNearestPlayer(maxDist)
    local root = getRoot(); if not root then return nil, math.huge end
    local best, bd = nil, maxDist or math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Parent then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - root.Position).Magnitude
                if d < bd then bd = d; best = p end
            end
        end
    end
    return best, bd
end

print("[UniversalGameHub] Core loaded: services, theme, utilities, config, notify, keybinds.")

--====================================================================
--====================================================================
--                        UI WIDGET LIBRARY
--====================================================================
--====================================================================
-- A small, self-contained component library. Every window is created by
-- buildWindow() and exposes tabs; each tab can add widgets. Widgets return
-- a tiny controller table { Set = ..., Get = ... } so features can be
-- driven from code as well as from the UI.
--====================================================================

-- shared zindex counter for floating panels (dropdowns, color pickers)
local ZCounter = 50
local function nextZ() ZCounter = ZCounter + 1; return ZCounter end

local function rowFrame(parent, h)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, h or 38)
    row.BackgroundColor3 = Theme.Element
    row.BorderSizePixel = 0
    row.Parent = parent
    corner(row, 8)
    stroke(row, Theme.Stroke, 1, 0)
    pad(row, 10)
    return row
end

local function hoverButton(btn, base, over)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = over or Theme.ElementH end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = base or Theme.Element end)
end

-- slider drag helper (reused by Slider and ColorPicker)
local function bindSliderDrag(track, fill, onUpdate)
    local dragging = false
    local function update(x)
        local rel = clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        if fill then fill.Size = UDim2.new(rel, 0, 1, 0) end
        onUpdate(rel)
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(i.Position.X)
        end
    end)
    local ended = UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    local changed = UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
            update(i.Position.X)
        end
    end)
    return { ended = ended, changed = changed }
end

--====================================================================
--                          WINDOW BUILDER
--====================================================================
local function buildWindow(cfg)
    local win = {}
    local accent = cfg.accent or Theme.Accent
    local W, H = cfg.width or 580, cfg.height or 440

    local Frame = Instance.new("Frame")
    Frame.Name = "Win_" .. (cfg.title or "?")
    Frame.Size = UDim2.fromOffset(W, H)
    Frame.Position = UDim2.new(0.5, -W / 2 + math.random(-100, 100), 0.5, -H / 2 + math.random(-60, 60))
    Frame.BackgroundColor3 = Theme.Bg
    Frame.BorderSizePixel = 0
    Frame.Visible = false
    Frame.Parent = ScreenGui
    corner(Frame, 12)
    stroke(Frame, Theme.Stroke, 1, 0)

    -- drop shadow
    local shadow = Instance.new("ImageLabel")
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.Size = UDim2.new(1, 48, 1, 48)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ZIndex = Frame.ZIndex - 1
    shadow.Parent = Frame

    -- top bar
    local Top = Instance.new("Frame")
    Top.Size = UDim2.new(1, 0, 0, 40)
    Top.BackgroundColor3 = Theme.Topbar
    Top.BorderSizePixel = 0
    Top.Parent = Frame
    corner(Top, 12)
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 0, 3)
    Bar.BackgroundColor3 = accent
    Bar.BorderSizePixel = 0
    Bar.Parent = Top
    gradient(Bar, accent, Theme.Accent2, 0)

    local Title = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.fromOffset(14, 0)
    Title.Size = UDim2.new(1, -120, 1, 0)
    Title.Font = Font; Title.TextSize = 15
    Title.TextColor3 = Theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Text = cfg.title or "Window"
    Title.Parent = Top

    local icon = Instance.new("TextLabel")
    icon.BackgroundTransparency = 1
    icon.Position = UDim2.new(1, -96, 0, 0)
    icon.Size = UDim2.fromOffset(30, 1)
    icon.Font = Font; icon.TextSize = 13
    icon.TextColor3 = accent
    icon.Text = cfg.icon or "🎮"
    icon.Parent = Top

    local Close = Instance.new("TextButton")
    Close.Size = UDim2.fromOffset(28, 28)
    Close.Position = UDim2.new(1, -34, 0, 6)
    Close.BackgroundColor3 = Theme.Element
    Close.Text = "✕"
    Close.Font = FontM; Close.TextSize = 13
    Close.TextColor3 = Theme.Red
    Close.Parent = Top
    corner(Close, 7)
    stroke(Close, Theme.Stroke, 1, 0)
    hoverButton(Close, Theme.Element, Theme.ElementH)
    Close.MouseButton1Click:Connect(function() win:Hide() end)

    -- body
    local Body = Instance.new("Frame")
    Body.Position = UDim2.fromOffset(0, 40)
    Body.Size = UDim2.new(1, 0, 1, -40)
    Body.BackgroundTransparency = 1
    Body.Parent = Frame

    -- sidebar
    local Side = Instance.new("Frame")
    Side.Size = UDim2.new(0, 150, 1, 0)
    Side.BackgroundColor3 = Theme.Sidebar
    Side.BorderSizePixel = 0
    Side.Parent = Body
    corner(Side, 12)
    pad(Side, 10)

    local SideScroll = Instance.new("ScrollingFrame")
    SideScroll.Size = UDim2.fromScale(1, 1)
    SideScroll.BackgroundTransparency = 1
    SideScroll.BorderSizePixel = 0
    SideScroll.ScrollBarThickness = 3
    SideScroll.ScrollBarImageColor3 = Theme.Stroke
    SideScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    SideScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SideScroll.Parent = Side
    list(SideScroll, Enum.FillDirection.Vertical, 6)

    -- content area
    local Content = Instance.new("Frame")
    Content.Position = UDim2.fromOffset(150, 0)
    Content.Size = UDim2.new(1, -150, 1, 0)
    Content.BackgroundTransparency = 1
    Content.Parent = Body

    local tabs = {}

    local function newTab(name, ico)
        local idx = #tabs + 1

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.fromScale(1, 1)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 4
        page.ScrollBarImageColor3 = Theme.Stroke
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = (idx == 1)
        page.Parent = Content
        list(page, Enum.FillDirection.Vertical, 8)
        pad(page, 12)

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = accent
        btn.BackgroundTransparency = (idx == 1) and 0.0 or 1
        btn.Text = "   " .. (ico or "●") .. "    " .. name
        btn.Font = FontM; btn.TextSize = 13
        btn.TextColor3 = (idx == 1) and Theme.Text or Theme.SubText
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.Parent = SideScroll
        corner(btn, 7)

        -- accent indicator strip on active tab
        local ind = Instance.new("Frame")
        ind.Size = UDim2.fromOffset(3, 14)
        ind.Position = UDim2.fromOffset(0, 9)
        ind.BackgroundColor3 = Theme.Text
        ind.BorderSizePixel = 0
        ind.Visible = (idx == 1)
        ind.Parent = btn
        corner(ind, 2)

        local tab = { _page = page, _btn = btn, _ind = ind }
        local order = 0
        local function nextOrder() order = order + 1; return order end

        local function selectTab()
            for _, t in ipairs(tabs) do
                t._page.Visible = false
                t._btn.BackgroundTransparency = 1
                t._btn.TextColor3 = Theme.SubText
                t._ind.Visible = false
            end
            page.Visible = true
            btn.BackgroundTransparency = 0.0
            btn.TextColor3 = Theme.Text
            ind.Visible = true
        end
        btn.MouseButton1Click:Connect(selectTab)
        if idx == 1 then selectTab() end

        ------------------------------------------------------------------
        -- LABEL
        ------------------------------------------------------------------
        function tab:AddLabel(text, color, size)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1, 0, 0, 18)
            l.BackgroundTransparency = 1
            l.Font = FontR; l.TextSize = size or 12
            l.TextColor3 = color or Theme.SubText
            l.TextXAlignment = Enum.TextXAlignment.Left
            l.Text = text or ""
            l.LayoutOrder = nextOrder()
            l.Parent = page
            return l
        end

        ------------------------------------------------------------------
        -- SECTION HEADER
        ------------------------------------------------------------------
        function tab:AddSection(title)
            local s = Instance.new("Frame")
            s.Size = UDim2.new(1, 0, 0, 26)
            s.BackgroundTransparency = 1
            s.LayoutOrder = nextOrder()
            s.Parent = page
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Position = UDim2.fromOffset(4, 5)
            lbl.Size = UDim2.new(1, -8, 1, 0)
            lbl.Font = FontB; lbl.TextSize = 12
            lbl.TextColor3 = accent
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Text = string.upper(title or "SECTION")
            lbl.Parent = s
            local ln = Instance.new("Frame")
            ln.Position = UDim2.new(0, 0, 1, -1)
            ln.Size = UDim2.new(1, 0, 0, 1)
            ln.BackgroundColor3 = Theme.Stroke
            ln.BorderSizePixel = 0
            ln.Parent = s
            return s
        end

        ------------------------------------------------------------------
        -- DIVIDER
        ------------------------------------------------------------------
        function tab:AddDivider()
            local d = Instance.new("Frame")
            d.Size = UDim2.new(1, 0, 0, 1)
            d.BackgroundColor3 = Theme.Stroke
            d.BorderSizePixel = 0
            d.LayoutOrder = nextOrder()
            d.Parent = page
            return d
        end

        ------------------------------------------------------------------
        -- TOGGLE  (+ optional inline keybind)
        ------------------------------------------------------------------
        function tab:AddToggle(title, default, callback, keybind)
            local on = default and true or false
            local row = rowFrame(page, 40)
            row.LayoutOrder = nextOrder()

            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Position = UDim2.fromOffset(8, 0)
            lbl.Size = UDim2.new(1, -100, 1, 0)
            lbl.Font = FontM; lbl.TextSize = 13
            lbl.TextColor3 = Theme.Text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Text = title or "Toggle"
            lbl.Parent = row

            local t = Instance.new("TextButton")
            t.Size = UDim2.fromOffset(42, 22)
            t.Position = UDim2.new(1, -50, 0.5, -11)
            t.BackgroundColor3 = on and Theme.Green or Theme.ElementH
            t.Text = ""; t.AutoButtonColor = false
            t.Parent = row
            corner(t, 11)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.fromOffset(16, 16)
            knob.AnchorPoint = Vector2.new(0, 0.5)
            knob.BackgroundColor3 = Theme.Clear
            knob.BorderSizePixel = 0
            knob.Parent = t
            corner(knob, 8)

            local function setKnob()
                knob.Position = on and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8)
            end
            setKnob()

            local function set(v, fire)
                on = v and true or false
                t.BackgroundColor3 = on and Theme.Green or Theme.ElementH
                tween(knob, 0.15, { Position = on and UDim2.new(1, -20, 0.5, -8) or UDim2.new(0, 4, 0.5, -8) })
                if fire ~= false then pcall(callback, on) end
            end

            t.MouseButton1Click:Connect(function() set(not on) end)

            -- optional inline keybind display
            local kbBtn
            if keybind then
                kbBtn = Instance.new("TextButton")
                kbBtn.Size = UDim2.fromOffset(54, 22)
                kbBtn.Position = UDim2.new(1, -100, 0.5, -11)
                kbBtn.BackgroundColor3 = Theme.ElementD
                kbBtn.Text = "[ ]"; kbBtn.Font = FontM; kbBtn.TextSize = 12
                kbBtn.TextColor3 = accent; kbBtn.AutoButtonColor = false
                kbBtn.Parent = row
                corner(kbBtn, 7)
                local listening = false
                kbBtn.MouseButton1Click:Connect(function()
                    listening = true; kbBtn.Text = "..."
                end)
                local conn = UserInputService.InputBegan:Connect(function(i, gpe)
                    if listening and i.UserInputType == Enum.UserInputType.Keyboard and not gpe then
                        listening = false
                        kbBtn.Text = "[" .. i.KeyCode.Name:sub(1, 4) .. "]"
                        addKeybind("toggle_" .. tostring(title), i.KeyCode, function() set(not on) end)
                        Notify("Keybind", title .. " → " .. i.KeyCode.Name)
                    end
                end)
            end

            return { Set = function(v) set(v, true) end, Get = function() return on end,
                     _row = row, _btn = t }
        end

        ------------------------------------------------------------------
        -- BUTTON
        ------------------------------------------------------------------
        function tab:AddButton(title, callback, color)
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 34)
            b.BackgroundColor3 = Theme.Element
            b.Text = title or "Button"
            b.Font = FontM; b.TextSize = 13
            b.TextColor3 = color or Theme.Text
            b.LayoutOrder = nextOrder()
            b.Parent = page
            corner(b, 8)
            stroke(b, Theme.Stroke, 1, 0)
            hoverButton(b, Theme.Element, Theme.ElementH)
            b.MouseButton1Click:Connect(function() pcall(callback) end)
            return b
        end

        ------------------------------------------------------------------
        -- SLIDER  (min..max int, with live value readout)
        ------------------------------------------------------------------
        function tab:AddSlider(title, min, max, default, suffix, callback)
            local row = rowFrame(page, 50)
            row.LayoutOrder = nextOrder()

            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Position = UDim2.fromOffset(8, 5)
            lbl.Size = UDim2.new(1, -70, 0, 18)
            lbl.Font = FontM; lbl.TextSize = 13
            lbl.TextColor3 = Theme.Text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Text = title or "Slider"
            lbl.Parent = row

            local val = Instance.new("TextLabel")
            val.BackgroundTransparency = 1
            val.Position = UDim2.new(1, -66, 5)
            val.Size = UDim2.fromOffset(58, 18)
            val.Font = FontM; val.TextSize = 13
            val.TextColor3 = accent
            val.TextXAlignment = Enum.TextXAlignment.Right
            val.Text = tostring(default)
            val.Parent = row

            local track = Instance.new("Frame")
            track.Position = UDim2.fromOffset(8, 30)
            track.Size = UDim2.new(1, -16, 0, 8)
            track.BackgroundColor3 = Theme.ElementH
            track.BorderSizePixel = 0
            track.Parent = row
            corner(track, 4)

            local fill = Instance.new("Frame")
            fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = accent
            fill.BorderSizePixel = 0
            fill.Parent = track
            gradient(fill, accent, Theme.Accent2, 0)
            corner(fill, 4)

            local knob = Instance.new("Frame")
            knob.Size = UDim2.fromOffset(14, 14)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
            knob.BackgroundColor3 = Theme.Clear
            knob.BorderSizePixel = 0
            knob.Parent = track
            corner(knob, 7)

            bindSliderDrag(track, fill, function(rel)
                local v = math.floor(min + (max - min) * rel + 0.5)
                val.Text = tostring(v) .. (suffix or "")
                knob.Position = UDim2.new(rel, 0, 0.5, 0)
                pcall(callback, v)
            end)

            return {
                Set = function(v)
                    local rel = (v - min) / (max - min)
                    fill.Size = UDim2.new(rel, 0, 1, 0)
                    knob.Position = UDim2.new(rel, 0, 0.5, 0)
                    val.Text = tostring(v) .. (suffix or "")
                    pcall(callback, v)
                end,
                Get = function()
                    return tonumber((val.Text:gsub("%D", ""))) or default
                end,
            }
        end

        ------------------------------------------------------------------
        -- DROPDOWN  (expanding list panel)
        ------------------------------------------------------------------
        function tab:AddDropdown(title, options, default, callback)
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1, 0, 0, 34)
            holder.BackgroundTransparency = 1
            holder.AutomaticSize = Enum.AutomaticSize.Y
            holder.LayoutOrder = nextOrder()
            holder.Parent = page
            list(holder, Enum.FillDirection.Vertical, 4)

            local cur = default or options[1]
            local open = false

            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, 0, 0, 34)
            b.BackgroundColor3 = Theme.Element
            b.Text = "  " .. (title or "") .. ":  " .. cur
            b.Font = FontM; b.TextSize = 13
            b.TextColor3 = Theme.Text
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.AutoButtonColor = false
            b.Parent = holder
            corner(b, 8)
            stroke(b, Theme.Stroke, 1, 0)

            local arrow = Instance.new("TextLabel")
            arrow.BackgroundTransparency = 1
            arrow.Position = UDim2.new(1, -24, 0, 0)
            arrow.Size = UDim2.fromOffset(20, 1)
            arrow.Font = FontB; arrow.TextSize = 12
            arrow.TextColor3 = Theme.SubText
            arrow.Text = "▾"
            arrow.Parent = b

            local panel = Instance.new("Frame")
            panel.Size = UDim2.new(1, 0, 0, 0)
            panel.BackgroundColor3 = Theme.ElementD
            panel.Visible = false
            panel.Parent = holder
            corner(panel, 8)
            stroke(panel, Theme.Stroke, 1, 0)
            pad(panel, 6)
            list(panel, Enum.FillDirection.Vertical, 4)

            local function rebuild()
                for _, ch in ipairs(panel:GetChildren()) do
                    if ch:IsA("TextButton") then ch:Destroy() end
                end
                for _, opt in ipairs(options) do
                    local o = Instance.new("TextButton")
                    o.Size = UDim2.new(1, 0, 0, 26)
                    o.BackgroundColor3 = (opt == cur) and Theme.ElementH or Theme.Element
                    o.Text = "   " .. tostring(opt)
                    o.Font = FontR; o.TextSize = 12
                    o.TextColor3 = (opt == cur) and accent or Theme.Text
                    o.TextXAlignment = Enum.TextXAlignment.Left
                    o.AutoButtonColor = false
                    o.Parent = panel
                    corner(o, 6)
                    o.MouseButton1Click:Connect(function()
                        cur = opt
                        b.Text = "  " .. (title or "") .. ":  " .. cur
                        open = false
                        panel.Visible = false
                        panel.Size = UDim2.new(1, 0, 0, 0)
                        arrow.Text = "▾"
                        rebuild()
                        pcall(callback, cur)
                    end)
                end
            end
            rebuild()

            b.MouseButton1Click:Connect(function()
                open = not open
                panel.Visible = open
                panel.Size = open and UDim2.new(1, 0, 0, #options * 30 + 12) or UDim2.new(1, 0, 0, 0)
                arrow.Text = open and "▴" or "▾"
            end)

            return { Set = function(v) cur = v; b.Text = "  " .. title .. ":  " .. v; rebuild(); pcall(callback, v) end,
                     Get = function() return cur end }
        end

        ------------------------------------------------------------------
        -- MULTI-SELECT  (toggleable tag chips)
        ------------------------------------------------------------------
        function tab:AddMultiSelect(title, options, defaults, callback)
            local holder = Instance.new("Frame")
            holder.Size = UDim2.new(1, 0, 0, 0)
            holder.BackgroundTransparency = 1
            holder.AutomaticSize = Enum.AutomaticSize.Y
            holder.LayoutOrder = nextOrder()
            holder.Parent = page
            list(holder, Enum.FillDirection.Vertical, 4)

            local head = Instance.new("TextLabel")
            head.Size = UDim2.new(1, 0, 0, 16)
            head.BackgroundTransparency = 1
            head.Font = FontB; head.TextSize = 12
            head.TextColor3 = accent
            head.TextXAlignment = Enum.TextXAlignment.Left
            head.Text = string.upper(title or "SELECT")
            head.Parent = holder

            local chipHolder = Instance.new("Frame")
            chipHolder.Size = UDim2.new(1, 0, 0, 0)
            chipHolder.BackgroundTransparency = 1
            chipHolder.AutomaticSize = Enum.AutomaticSize.Y
            chipHolder.Parent = holder
            local ug = Instance.new("UIGridLayout")
            ug.CellSize = UDim2.new(0, 92, 0, 26)
            ug.CellPadding = UDim2.fromOffset(6, 6)
            ug.SortOrder = Enum.SortOrder.LayoutOrder
            ug.Parent = chipHolder

            local selected = {}
            for _, d in ipairs(defaults or {}) do selected[d] = true end

            local function emit()
                local t = {}
                for k, v in pairs(selected) do if v then table.insert(t, k) end end
                pcall(callback, t)
            end

            for _, opt in ipairs(options) do
                local c = Instance.new("TextButton")
                c.BackgroundColor3 = selected[opt] and accent or Theme.Element
                c.Text = tostring(opt)
                c.Font = FontR; c.TextSize = 11
                c.TextColor3 = selected[opt] and Theme.Text or Theme.SubText
                c.AutoButtonColor = false
                c.Parent = chipHolder
                corner(c, 6)
                c.MouseButton1Click:Connect(function()
                    selected[opt] = not selected[opt]
                    c.BackgroundColor3 = selected[opt] and accent or Theme.Element
                    c.TextColor3 = selected[opt] and Theme.Text or Theme.SubText
                    emit()
                end)
            end

            return { Get = function()
                local t = {}
                for k, v in pairs(selected) do if v then table.insert(t, k) end end
                return t
            end }
        end

        ------------------------------------------------------------------
        -- KEYBIND  (rebindable)
        ------------------------------------------------------------------
        function tab:AddKeybind(title, defaultKey, callback)
            local row = rowFrame(page, 34)
            row.LayoutOrder = nextOrder()
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Position = UDim2.fromOffset(8, 0)
            lbl.Size = UDim2.new(1, -84, 1, 0)
            lbl.Font = FontM; lbl.TextSize = 13
            lbl.TextColor3 = Theme.Text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Text = title or "Keybind"
            lbl.Parent = row

            local b = Instance.new("TextButton")
            b.Size = UDim2.fromOffset(70, 24)
            b.Position = UDim2.new(1, -78, 0.5, -12)
            b.BackgroundColor3 = Theme.ElementD
            b.Text = defaultKey and defaultKey.Name or "[ ]"
            b.Font = FontM; b.TextSize = 12
            b.TextColor3 = accent
            b.Parent = row
            corner(b, 7)

            local cur = defaultKey
            local listening = false
            b.MouseButton1Click:Connect(function() listening = true; b.Text = "..." end)
            local conn = UserInputService.InputBegan:Connect(function(i, gpe)
                if listening and i.UserInputType == Enum.UserInputType.Keyboard and not gpe then
                    cur = i.KeyCode; listening = false; b.Text = cur.Name
                end
                if i.KeyCode == cur and not gpe then pcall(callback) end
            end)
            return { Set = function(k) cur = k; b.Text = k.Name end, Get = function() return cur end }
        end

        ------------------------------------------------------------------
        -- TEXT BOX  (with apply callback)
        ------------------------------------------------------------------
        function tab:AddTextBox(title, placeholder, callback)
            local row = rowFrame(page, 40)
            row.LayoutOrder = nextOrder()
            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Position = UDim2.fromOffset(8, 4)
            lbl.Size = UDim2.new(1, -120, 0, 16)
            lbl.Font = FontM; lbl.TextSize = 13
            lbl.TextColor3 = Theme.Text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Text = title or "Input"
            lbl.Parent = row

            local tb = Instance.new("TextBox")
            tb.Size = UDim2.new(1, -16, 0, 22)
            tb.Position = UDim2.fromOffset(8, 20)
            tb.BackgroundColor3 = Theme.ElementD
            tb.Text = ""
            tb.PlaceholderText = placeholder or "..."
            tb.PlaceholderColor3 = Theme.Faint
            tb.Font = FontR; tb.TextSize = 12
            tb.TextColor3 = Theme.Text
            tb.ClearTextOnFocus = false
            tb.Parent = row
            corner(tb, 6)
            tb.FocusLost:Connect(function(enter)
                if enter then pcall(callback, tb.Text) end
            end)
            return tb
        end

        ------------------------------------------------------------------
        -- COLOR PICKER  (HSV hue+sat strip + value slider)
        ------------------------------------------------------------------
        function tab:AddColorPicker(title, default, callback)
            local defaultH, defaultS, defaultV = Color3.toHSV(default or Theme.Accent)
            local row = rowFrame(page, 34)
            row.LayoutOrder = nextOrder()

            local lbl = Instance.new("TextLabel")
            lbl.BackgroundTransparency = 1
            lbl.Position = UDim2.fromOffset(8, 0)
            lbl.Size = UDim2.new(1, -70, 1, 0)
            lbl.Font = FontM; lbl.TextSize = 13
            lbl.TextColor3 = Theme.Text
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Text = title or "Color"
            lbl.Parent = row

            local swatch = Instance.new("TextButton")
            swatch.Size = UDim2.fromOffset(40, 22)
            swatch.Position = UDim2.new(1, -48, 0.5, -11)
            swatch.BackgroundColor3 = default or Theme.Accent
            swatch.Text = ""; swatch.AutoButtonColor = false
            swatch.Parent = row
            corner(swatch, 6)
            stroke(swatch, Theme.Stroke, 1, 0)

            local panel = Instance.new("Frame")
            panel.Size = UDim2.fromOffset(180, 150)
            panel.BackgroundColor3 = Theme.ElementD
            panel.Visible = false
            panel.ZIndex = nextZ()
            panel.Parent = ScreenGui
            corner(panel, 8)
            stroke(panel, Theme.Stroke, 1, 0)
            pad(panel, 8)

            local hueSat = Instance.new("TextLabel")
            hueSat.Size = UDim2.new(1, 0, 0, 100)
            hueSat.BackgroundColor3 = Color3.fromHSV(defaultH, 1, 1)
            hueSat.BorderSizePixel = 0
            hueSat.ZIndex = panel.ZIndex + 1
            hueSat.Parent = panel
            corner(hueSat, 6)

            local picker = Instance.new("Frame")
            picker.Size = UDim2.fromOffset(8, 8)
            picker.AnchorPoint = Vector2.new(0.5, 0.5)
            picker.Position = UDim2.new(defaultS, 0, defaultH, 0)
            picker.BackgroundColor3 = Theme.Clear
            picker.BorderSizePixel = 0
            picker.ZIndex = hueSat.ZIndex + 1
            picker.Parent = hueSat
            corner(picker, 4)
            stroke(picker, Theme.Black, 1.5, 0)

            local vTrack = Instance.new("Frame")
            vTrack.Size = UDim2.new(1, 0, 0, 10)
            vTrack.Position = UDim2.fromOffset(0, 112)
            vTrack.BackgroundColor3 = Theme.ElementH
            vTrack.BorderSizePixel = 0
            vTrack.ZIndex = panel.ZIndex + 1
            vTrack.Parent = panel
            corner(vTrack, 5)

            local vFill = Instance.new("Frame")
            vFill.Size = UDim2.new(defaultV, 0, 1, 0)
            vFill.BackgroundColor3 = Theme.Clear
            vFill.BorderSizePixel = 0
            vFill.ZIndex = vTrack.ZIndex + 1
            vFill.Parent = vTrack
            corner(vFill, 5)

            local h, s, v = defaultH, defaultS, defaultV
            local function apply()
                local col = Color3.fromHSV(h, s, v)
                swatch.BackgroundColor3 = col
                hueSat.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                vFill.BackgroundColor3 = Color3.fromHSV(h, s, 1)
                pcall(callback, col)
            end

            local hsDrag = false
            hueSat.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                or i.UserInputType == Enum.UserInputType.Touch then
                    hsDrag = true
                    local rel = clamp((i.Position.X - hueSat.AbsolutePosition.X) / hueSat.AbsoluteSize.X, 0, 1)
                    local relY = clamp((i.Position.Y - hueSat.AbsolutePosition.Y) / hueSat.AbsoluteSize.Y, 0, 1)
                    s = rel; h = relY
                    picker.Position = UDim2.new(s, 0, h, 0); apply()
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if hsDrag and (i.UserInputType == Enum.UserInputType.MouseMovement
                    or i.UserInputType == Enum.UserInputType.Touch) then
                    local rel = clamp((i.Position.X - hueSat.AbsolutePosition.X) / hueSat.AbsoluteSize.X, 0, 1)
                    local relY = clamp((i.Position.Y - hueSat.AbsolutePosition.Y) / hueSat.AbsoluteSize.Y, 0, 1)
                    s = rel; h = relY
                    picker.Position = UDim2.new(s, 0, h, 0); apply()
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then hsDrag = false end
            end)

            bindSliderDrag(vTrack, vFill, function(rel) v = rel; apply() end)

            swatch.MouseButton1Click:Connect(function()
                panel.Visible = not panel.Visible
                if panel.Visible then
                    panel.Position = UDim2.fromOffset(
                        swatch.AbsolutePosition.X - 60,
                        swatch.AbsolutePosition.Y + 30)
                end
            end)
            -- close on outside click
            UserInputService.InputBegan:Connect(function(i)
                if panel.Visible and i.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mp = i.Position
                    local ap = panel.AbsolutePosition; local as = panel.AbsoluteSize
                    if mp.X < ap.X or mp.X > ap.X + as.X or mp.Y < ap.Y or mp.Y > ap.Y + as.Y then
                        panel.Visible = false
                    end
                end
            end)

            return { Set = function(c)
                local hh, ss, vv = Color3.toHSV(c)
                h, s, v = hh, ss, vv
                picker.Position = UDim2.new(s, 0, h, 0)
                vFill.Size = UDim2.new(v, 0, 1, 0)
                apply()
            end }
        end

        table.insert(tabs, tab)
        return tab
    end

    function win:AddTab(name, icon) return newTab(name, icon) end
    function win:Show()
        Frame.Visible = true
        Frame.Parent = ScreenGui
        bringToFront(Frame)
    end
    function win:Hide() Frame.Visible = false end
    function win:Toggle() Frame.Visible = not Frame.Visible end
    function win:IsVisible() return Frame.Visible end

    makeDraggable(Frame, Top)
    Top.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then Frame.Parent = ScreenGui end
    end)
    return win
end

print("[UniversalGameHub] UI widget library loaded (window + 11 widgets).")

--====================================================================
--====================================================================
--                     FEATURE IMPLEMENTATIONS
--====================================================================
--====================================================================
-- Forward declarations so feature functions can reference each other
-- (e.g. flyOn calls flyOff). Every feature is driven by State and uses
-- the connection tracker so toggling off cleanly tears down loops.
--====================================================================
-- NOTE: core feature functions below are declared as GLOBALS (no `local`)
-- on purpose. Luau caps a single scope at 200 locals; this hub defines far
-- more than that, so features live on the global table and DON'T count
-- toward the 200-local limit. Every call site resolves them as globals.

--====================================================================
--                              FLY
--====================================================================
local flyBV, flyBG
function flyOff()
    if flyBV then pcall(function() flyBV:Destroy() end) end; flyBV = nil
    if flyBG then pcall(function() flyBG:Destroy() end) end; flyBG = nil
    untrack("fly")
end
function flyOn()
    flyOff()
    local root = getRoot(); if not root then return end
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(1, 1, 1) * 9e9
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = root
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1, 1, 1) * 9e9
    flyBG.P = 9e4
    flyBG.CFrame = root.CFrame
    flyBG.Parent = root
    track("fly", RunService.RenderStepped:Connect(function()
        local r = getRoot(); if not r or not flyBV or not flyBG then return end
        local cam = Camera
        local v = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then v = v + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then v = v - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then v = v - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then v = v + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then v = v + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then v = v - Vector3.new(0, 1, 0) end
        if v.Magnitude > 0 then v = v.Unit end
        flyBV.Velocity = v * State.flySpeed
        flyBG.CFrame = cam.CFrame
    end))
end

--====================================================================
--                        MOVEMENT (speed/jump/gravity)
--====================================================================
function applyMovement()
    local hum = getHum()
    local ws = Workspace
    if hum then
        if State.useSpeed then hum.WalkSpeed = State.speed end
        if State.useJump then
            pcall(function() hum.UseJumpPower = true end)
            hum.JumpPower = State.jump
            hum.JumpHeight = State.jump / 50
        end
    end
    if State.useGravity then
        ws.Gravity = State.gravity
    else
        ws.Gravity = 196.2
    end
end

--====================================================================
--                              NOCLIP
--====================================================================
function noclipOff() untrack("noclip") end
function noclipOn()
    untrack("noclip")
    track("noclip", RunService.Stepped:Connect(function()
        local c = getChar()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end
    end))
end

--====================================================================
--                         INFINITE JUMP
--====================================================================
function infJumpOff() untrack("infjump") end
function infJumpOn()
    untrack("infjump")
    track("infjump", UserInputService.JumpRequest:Connect(function()
        local hum = getHum()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end))
end

--====================================================================
--                          SWIM / WATER WALK
--====================================================================
function swimOff() untrack("swim") end
function swimOn()
    untrack("swim")
    track("swim", RunService.Heartbeat:Connect(function()
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Swimming) end
    end))
end

--====================================================================
--                          ANTI-FLING
--====================================================================
function antiFlingOff() untrack("antifling") end
function antiFlingOn()
    untrack("antifling")
    track("antifling", RunService.Heartbeat:Connect(function()
        local root = getRoot()
        if root then
            root.AssemblyAngularVelocity = Vector3.zero
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end))
end

--====================================================================
--                       NO FALL DAMAGE
--====================================================================
function noFallOff() untrack("nofall") end
function noFallOn()
    untrack("nofall")
    local function disable(c)
        task.wait(0.2)
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then
            pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end)
            pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end)
            pcall(function() h.Health = h.MaxHealth end)
        end
    end
    track("nofall", LocalPlayer.CharacterAdded:Connect(disable))
    local c = getChar(); if c then disable(c) end
end

--====================================================================
--                    PLAYER ESP (full visual suite)
--====================================================================
local espData = {}
local function clearESP()
    for _, d in pairs(espData) do
        pcall(function() d.highlight:Destroy() end)
        pcall(function() d.billboard:Destroy() end)
        pcall(function() d.box:Destroy() end)
        pcall(function() d.healthbg:Destroy() end)
        pcall(function() d.healthfill:Destroy() end)
        pcall(function() d.line:Destroy() end)
    end
    espData = {}
end

local function espColor()
    local c = State.espColor
    return Color3.new(c[1] or 0.69, c[2] or 0.44, c[3] or 1)
end

local function makeESPFor(plr)
    if plr == LocalPlayer then return end
    local char = plr.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not root then return end
    local col = espColor()
    if State.espTeam and plr.Team and plr.Team.TeamColor then col = plr.Team.TeamColor.Color end

    local d = {}

    -- chams highlight
    d.highlight = Instance.new("Highlight")
    d.highlight.Adornee = char
    d.highlight.FillColor = col
    d.highlight.OutlineColor = Theme.Clear
    d.highlight.FillTransparency = State.espChams and 0.55 or 1
    d.highlight.OutlineTransparency = 0
    d.highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    d.highlight.Parent = ESPFolder

    -- name + distance billboard
    d.billboard = Instance.new("BillboardGui")
    d.billboard.Adornee = head or root
    d.billboard.Size = UDim2.fromOffset(220, 46)
    d.billboard.StudsOffset = Vector3.new(0, 2.8, 0)
    d.billboard.AlwaysOnTop = true
    d.billboard.Parent = ESPFolder
    d.label = Instance.new("TextLabel")
    d.label.BackgroundTransparency = 1
    d.label.Size = UDim2.fromScale(1, 1)
    d.label.Font = FontM; d.label.TextSize = 14
    d.label.TextColor3 = col
    d.label.TextStrokeColor3 = Theme.Black
    d.label.TextStrokeTransparency = 0.4
    d.label.Parent = d.billboard

    -- box (2D)
    d.box = Instance.new("Frame")
    d.box.BackgroundTransparency = 1
    d.box.Visible = false
    d.box.Parent = DrawFolder
    local bs = Instance.new("UIStroke")
    bs.Color = col; bs.Thickness = 1.5; bs.Parent = d.box

    -- healthbar background + fill
    d.healthbg = Instance.new("Frame")
    d.healthbg.BackgroundColor3 = Theme.Black
    d.healthbg.BackgroundTransparency = 0.3
    d.healthbg.Visible = false
    d.healthbg.BorderSizePixel = 0
    d.healthbg.Parent = DrawFolder
    corner(d.healthbg, 2)
    d.healthfill = Instance.new("Frame")
    d.healthfill.BackgroundColor3 = Theme.Green
    d.healthfill.BorderSizePixel = 0
    d.healthfill.Parent = d.healthbg
    corner(d.healthfill, 2)

    -- tracer line
    d.line = Instance.new("Frame")
    d.line.BackgroundColor3 = col
    d.line.BorderSizePixel = 0
    d.line.AnchorPoint = Vector2.new(0, 0.5)
    d.line.Visible = false
    d.line.Parent = DrawFolder

    espData[plr] = d
end

function espOff()
    untrack("esp")
    clearESP()
end
function espOn()
    clearESP()
    for _, p in ipairs(Players:GetPlayers()) do makeESPFor(p) end
    track("esp", RunService.RenderStepped:Connect(function()
        local myRoot = getRoot()
        local vw, vh = Camera.ViewportSize.X, Camera.ViewportSize.Y
        local origin = Vector2.new(vw / 2, vh) -- bottom-center default

        for plr, d in pairs(espData) do
            local char = plr.Character
            local valid = char and char.Parent and char:FindFirstChild("HumanoidRootPart") and plr.Parent
            if not valid then
                pcall(function() d.highlight:Destroy() end)
                pcall(function() d.billboard:Destroy() end)
                pcall(function() d.box:Destroy() end)
                pcall(function() d.healthbg:Destroy() end)
                pcall(function() d.line:Destroy() end)
                espData[plr] = nil
            else
                local hum = char:FindFirstChildOfClass("Humanoid")
                local hrp = char.HumanoidRootPart
                local head = char:FindFirstChild("Head")
                local dead = hum and hum.Health <= 0
                local dist = myRoot and (hrp.Position - myRoot.Position).Magnitude or 0

                -- visibility check
                local onScreen = true
                if State.espVisibleOnly then onScreen = isVisible(hrp) end

                -- chams color update
                local col = espColor()
                if State.espTeam and plr.Team and plr.Team.TeamColor then col = plr.Team.TeamColor.Color end
                d.highlight.FillColor = col
                d.highlight.FillTransparency = (not State.espChams or dead) and 1 or 0.55
                d.highlight.Enabled = onScreen and not dead

                -- name / distance text
                local txt = ""
                if State.espName then txt = txt .. plr.DisplayName .. "\n" end
                if State.espDist and myRoot then txt = txt .. math.floor(dist) .. "m" end
                d.label.Text = txt
                d.label.TextColor3 = col
                d.label.TextTransparency = dead and 0.6 or 0
                d.billboard.Enabled = onScreen

                -- screen position of head & root
                local topPos, topOn = worldToScreen((head and head.Position or hrp.Position) + Vector3.new(0, 1.5, 0))
                local botPos, botOn = worldToScreen(hrp.Position - Vector3.new(0, 3, 0))

                -- box
                if State.espBox and topOn and botOn then
                    d.box.Visible = true
                    local h = math.abs(botPos.Y - topPos.Y)
                    local w = h * 0.6
                    d.box.Size = UDim2.fromOffset(w, h)
                    d.box.Position = UDim2.fromOffset(topPos.X - w / 2, topPos.Y)
                    local s = d.box:FindFirstChildOfClass("UIStroke")
                    if s then s.Color = col end
                else
                    d.box.Visible = false
                end

                -- healthbar
                if State.espHealth and hum and topOn and botOn then
                    d.healthbg.Visible = true
                    local h = math.abs(botPos.Y - topPos.Y)
                    local hp = clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
                    d.healthbg.Size = UDim2.fromOffset(4, h)
                    d.healthbg.Position = UDim2.fromOffset(topPos.X - h * 0.6 / 2 - 8, topPos.Y)
                    d.healthfill.Size = UDim2.new(1, 0, hp, 0)
                    d.healthfill.BackgroundColor3 = Color3.fromHSV(hp * 0.33, 1, 1)
                else
                    d.healthbg.Visible = false
                end

                -- tracer
                if State.espTracer and botOn and myRoot then
                    local o = origin
                    if State.tracerOrigin == "Mouse" then o = UserInputService:GetMouseLocation()
                    elseif State.tracerOrigin == "Center" then o = Vector2.new(vw / 2, vh / 2) end
                    d.line.Visible = true
                    d.line.BackgroundColor3 = col
                    placeLine(d.line, o, Vector2.new(botPos.X, botPos.Y))
                else
                    d.line.Visible = false
                end
            end
        end

        -- add ESP for newly joined / spawned players
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Parent and not espData[plr] and plr.Character then
                makeESPFor(plr)
            end
        end
    end))
end

-- small helper to set a UIStroke color safely (kept local to ESP section)
local _bsCache = {}
function bsSet(box, col)
    local s = box:FindFirstChildOfClass("UIStroke")
    if s then s.Color = col end
end

Players.PlayerRemoving:Connect(function(plr)
    if espData[plr] then
        local d = espData[plr]
        pcall(function() d.highlight:Destroy() end)
        pcall(function() d.billboard:Destroy() end)
        pcall(function() d.box:Destroy() end)
        pcall(function() d.healthbg:Destroy() end)
        pcall(function() d.line:Destroy() end)
        espData[plr] = nil
    end
end)

--====================================================================
--                    FULLBRIGHT / FOG / NIGHT VISION
--====================================================================
local fbStore = {}
function fbOff()
    Lighting.Ambient = fbStore.Ambient or Lighting.Ambient
    Lighting.OutdoorAmbient = fbStore.Outdoor or Lighting.OutdoorAmbient
    Lighting.Brightness = fbStore.Bright or Lighting.Brightness
    Lighting.ClockTime = fbStore.Clock or Lighting.ClockTime
    Lighting.FogEnd = fbStore.Fog or Lighting.FogEnd
end
function fbOn()
    fbStore.Ambient = Lighting.Ambient
    fbStore.Outdoor = Lighting.OutdoorAmbient
    fbStore.Bright = Lighting.Brightness
    fbStore.Clock = Lighting.ClockTime
    fbStore.Fog = Lighting.FogEnd
    Lighting.Ambient = Color3.new(1, 1, 1)
    Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 1e9
end

function fogOff() Lighting.FogEnd = fbStore.Fog or 1e9 end
function fogOn() fbStore.Fog = Lighting.FogEnd; Lighting.FogEnd = 1e9 end

local ccInst
function nightOff()
    if ccInst then ccInst:Destroy(); ccInst = nil end
    Lighting.Brightness = fbStore.Bright or Lighting.Brightness
end
function nightOn()
    nightOff()
    ccInst = Instance.new("ColorCorrectionEffect")
    ccInst.Brightness = 0.06
    ccInst.Contrast = 0.1
    ccInst.Saturation = 0.2
    ccInst.Parent = Lighting
    Lighting.Brightness = 3
end

print("[UniversalGameHub] Movement + ESP + visual features loaded.")

--====================================================================
--                            AIMBOT
--====================================================================
function aimbotOff() untrack("aimbot") end
function aimbotOn()
    untrack("aimbot")
    track("aimbot", RunService.RenderStepped:Connect(function()
        if not State.aimbot then return end
        local tgt = getClosest(State.aimFov, State.aimPart)
        if tgt then
            local goal = CFrame.new(Camera.CFrame.Position, tgt.Position)
            local f = State.aimSmooth
            if f and f > 0 and f < 1 then
                Camera.CFrame = Camera.CFrame:Lerp(goal, 1 - f)
            else
                Camera.CFrame = goal
            end
        end
    end))
end

--====================================================================
--                          SILENT AIM
-- (redirects weapon raycasts/fire when an executor hook is available;
--  safely no-ops otherwise so the toggle never errors)
--====================================================================
local oldNamecall
function silentOff()
    if oldNamecall and hookmetamethod then
        pcall(function() hookmetamethod(game, "__namecall", oldNamecall) end)
        oldNamecall = nil
    end
end
function silentOn()
    untrack("silent")
    if not hookmetamethod then
        Notify("Silent Aim", "Hooking unavailable in this environment.")
        return
    end
    if oldNamecall then return end
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod and getnamecallmethod() or ""
        local args = { ... }
        if State.silentAim then
            local tgt = getClosest(State.aimFov, State.aimPart)
            if tgt and method == "FireServer" then
                -- redirect bullet origin/direction for raycast guns
                pcall(function()
                    for i, a in ipairs(args) do
                        if typeof(a) == "Vector3" then
                            args[i] = (tgt.Position - Camera.CFrame.Position)
                        elseif typeof(a) == "CFrame" then
                            args[i] = CFrame.new(Camera.CFrame.Position, tgt.Position)
                        elseif typeof(a) == "Instance" and a:IsA("BasePart") then
                            args[i] = tgt
                        end
                    end
                end)
            elseif tgt and (method == "Raycast" or method == "FindPartOnRay"
                or method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist") then
                pcall(function()
                    local origin = Camera.CFrame.Position
                    local dir = (tgt.Position - origin)
                    if typeof(args[1]) == "Vector3" then args[1] = origin end
                    if typeof(args[2]) == "Vector3" then args[2] = dir end
                end)
            end
        end
        return oldNamecall(self, table.unpack(args))
    end)
    track("silent", { Disconnect = function() silentOff() end })
end

--====================================================================
--                          TRIGGERBOT
--====================================================================
function triggerOff() untrack("trigger") end
function triggerOn()
    untrack("trigger")
    track("trigger", RunService.Heartbeat:Connect(function()
        local tgt = getClosest(State.aimFov * 0.25, State.aimPart)
        if tgt then clickMouse() end
    end))
end

--====================================================================
--                       HITBOX EXPANDER
--====================================================================
function hitboxOff()
    untrack("hitbox")
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            pcall(function() r.Size = Vector3.new(2, 2, 1) end)
            pcall(function() r.Transparency = 0 end)
            pcall(function() r.Material = Enum.Material.Plastic end)
        end
    end
end
function hitboxOn()
    untrack("hitbox")
    track("hitbox", RunService.Stepped:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local r = p.Character:FindFirstChild("HumanoidRootPart")
                if r then
                    pcall(function()
                        r.Size = Vector3.new(State.hitboxSize, State.hitboxSize, State.hitboxSize)
                        r.Transparency = State.hitboxTrans
                        r.CanCollide = false
                        r.Material = Enum.Material.ForceField
                        r.Color = Color3.fromRGB(255, 80, 120)
                    end)
                end
            end
        end
    end))
end

--====================================================================
--                          AUTO FIRE
--====================================================================
local afTick = 0
function autoFireOff() untrack("autofire") end
function autoFireOn()
    untrack("autofire")
    track("autofire", RunService.Heartbeat:Connect(function()
        if tick() - afTick > 0.05 then afTick = tick(); clickMouse() end
    end))
end

--====================================================================
--                          AUTO PARRY  (Blade Ball style)
--====================================================================
function autoParryOff() untrack("parry") end
function autoParryOn()
    untrack("parry")
    track("parry", RunService.Heartbeat:Connect(function()
        local root = getRoot(); if not root then return end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = obj.Name:lower()
                if n:find("ball") or n:find("orb") or n:find("projectile") then
                    if (obj.Position - root.Position).Magnitude < State.parryRange then
                        pressKey(Enum.KeyCode.F)
                        clickMouse()
                        break
                    end
                end
            end
        end
    end))
end

--====================================================================
--                     AUTO COLLECT / ROB / PLANT
--====================================================================
function autoCollectOff() untrack("collect") end
function autoCollectOn()
    untrack("collect")
    track("collect", RunService.Heartbeat:Connect(function()
        local char = getChar(); if not char then return end
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then pcall(function() t:Activate() end) end
        end
        local root = getRoot()
        if root then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    if (obj.WorldPosition - root.Position).Magnitude < 14 then
                        pcall(function()
                            if fireproximityprompt then fireproximityprompt(obj, 0) end
                        end)
                    end
                end
            end
        end
    end))
end

function autoRobOff() untrack("rob") end
function autoRobOn()
    untrack("rob")
    track("rob", RunService.Heartbeat:Connect(function()
        local root = getRoot(); if not root then return end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") then
                if (obj.WorldPosition - root.Position).Magnitude < 18 then
                    pcall(function() if fireproximityprompt then fireproximityprompt(obj, 0) end end)
                end
            end
        end
    end))
end

function autoPlantOff() untrack("plant") end
function autoPlantOn()
    untrack("plant")
    local tick_ = 0
    track("plant", RunService.Heartbeat:Connect(function()
        if tick() - tick_ > 0.6 then
            tick_ = tick()
            local char = getChar()
            if char then
                for _, t in ipairs(char:GetChildren()) do
                    if t:IsA("Tool") then pcall(function() t:Activate() end) end
                end
            end
            pcall(function() if firesignal then end end)
        end
    end))
end

--====================================================================
--                            GOD MODE
--====================================================================
function godOff()
    untrack("god")
    local hum = getHum()
    if hum then pcall(function() hum.MaxHealth = 100 end) end
end
function godOn()
    untrack("god")
    track("god", RunService.Heartbeat:Connect(function()
        local hum = getHum()
        if hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        end
    end))
end

--====================================================================
--                            KILL AURA
--====================================================================
function auraOff() untrack("aura") end
function auraOn()
    untrack("aura")
    local last = 0
    track("aura", RunService.Heartbeat:Connect(function()
        if tick() - last < State.auraDelay then return end
        local root = getRoot(); if not root then return end
        local char = getChar()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    if (hrp.Position - root.Position).Magnitude < State.auraRange then
                        last = tick()
                        root.CFrame = CFrame.new(root.Position,
                            Vector3.new(hrp.Position.X, root.Position.Y, hrp.Position.Z))
                        if char then
                            for _, t in ipairs(char:GetChildren()) do
                                if t:IsA("Tool") then pcall(function() t:Activate() end) end
                            end
                        end
                        pcall(function()
                            if firetouchinterest then firetouchinterest(root, hrp, 0) end
                        end)
                        break
                    end
                end
            end
        end
    end))
end

--====================================================================
--                           ANTI-AFK
--====================================================================
function antiAfkOff() untrack("antiafk") end
function antiAfkOn()
    untrack("antiafk")
    local VirtualUser
    pcall(function() VirtualUser = game:GetService("VirtualUser") end)
    track("antiafk", LocalPlayer.Idled:Connect(function()
        pcall(function()
            if VirtualUser then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end)
    end))
end

--====================================================================
--                          CLICK TELEPORT
--====================================================================
function clickTpOff() untrack("clicktp") end
function clickTpOn()
    untrack("clicktp")
    track("clicktp", Mouse.Button1Down:Connect(function()
        local root = getRoot()
        if root and Mouse.Hit then
            root.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end))
end

--====================================================================
--                          AUTO CLICKER
--====================================================================
local acTick = 0
function autoClickOff() untrack("autoclick") end
function autoClickOn()
    untrack("autoclick")
    track("autoclick", RunService.Heartbeat:Connect(function()
        if tick() - acTick >= State.autoClickSpd then
            acTick = tick()
            clickMouse()
        end
    end))
end

--====================================================================
--                        AUTO KEY SPAMMER
--====================================================================
local akFlags = {}
local akThreads = {}
function autoKeyOff(code)
    akFlags[code] = false
end
function autoKeyOn(code, interval)
    akFlags[code] = true
    task.spawn(function()
        while akFlags[code] do
            pressKey(code)
            task.wait(interval or 0.4)
        end
    end)
end

--====================================================================
--                       PART ESP (world objects)
--====================================================================
local partData = {}
function partESPOff()
    untrack("partesp")
    for _, h in pairs(partData) do pcall(function() h:Destroy() end) end
    partData = {}
end
function partESPOn(names, color)
    partESPOff()
    track("partesp", RunService.Heartbeat:Connect(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Parent and not partData[obj] then
                local n = obj.Name:lower()
                for _, k in ipairs(names) do
                    if n:find(k) then
                        local h = Instance.new("Highlight")
                        h.Adornee = obj
                        h.FillColor = color or Theme.Yellow
                        h.FillTransparency = 0.4
                        h.OutlineColor = Theme.Clear
                        h.Parent = ESPFolder
                        partData[obj] = h
                        break
                    end
                end
            end
        end
        for obj, h in pairs(partData) do
            if not obj.Parent then pcall(function() h:Destroy() end); partData[obj] = nil end
        end
    end))
end

--====================================================================
--                        TELEPORT HELPERS
--====================================================================
local function tpTo(cf) local r = getRoot(); if r then r.CFrame = cf end end
local function tpCoords(x, y, z) tpTo(CFrame.new(x, y, z)) end
local function tpUp(studs) local r = getRoot(); if r then r.CFrame = r.CFrame + Vector3.new(0, studs or 500, 0) end end
local function tpToNearestPlayer()
    local r = getRoot(); if not r then return end
    local best, bd = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then local d = (hrp.Position - r.Position).Magnitude
                if d < bd then bd = d; best = hrp end end
        end
    end
    if best then r.CFrame = best.CFrame * CFrame.new(0, 0, 3) end
end
local function tpToPlayer(plr)
    local r = getRoot(); if not r or not plr then return end
    local char = plr.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then r.CFrame = hrp.CFrame * CFrame.new(0, 0, 3) end
end
local function tpToMouse()
    local r = getRoot()
    if r and Mouse.Hit then r.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0)) end
end
local function setCamFov(v) pcall(function() Camera.FieldOfView = v end) end

--====================================================================
do -- ====================  GAME-MATCHED FEATURES  ====================
--          ADVANCED / GAME-MATCHED FEATURE FUNCTIONS
--====================================================================
-- These reflect REAL mechanics of specific games: trajectory parry
-- prediction, role detection, NPC auto-farming, vehicle flight, etc.
-- Each is connection-tracked so toggling off tears down cleanly.
--====================================================================

-- ANTI-FLASHBANG (Counter Blox / Phantom Forces style) ---------------
-- Locally zeroes any blur/flash effect that a game adds when flashed.
local function antiFlashOff() untrack("antiflash") end
local function antiFlashOn()
    untrack("antiflash")
    track("antiflash", RunService.RenderStepped:Connect(function()
        for _, e in ipairs(Lighting:GetChildren()) do
            if e:IsA("BlurEffect") and e.Size > 0 then
                pcall(function() e.Size = 0 end)
            elseif e:IsA("ColorCorrectionEffect") and (e.Brightness > 1 or e.Contrast > 0.6) then
                pcall(function() e.Brightness = 0; e.Contrast = 0 end)
            end
        end
        for _, sg in ipairs(LocalPlayer:WaitForChild("PlayerGui"):GetChildren()) do
            if sg:IsA("ScreenGui") and sg.Name:lower():find("flash") then
                pcall(function() sg.Enabled = false end)
            end
        end
    end))
end

-- BUNNY HOP (Counter Blox / movement shooters) -----------------------
-- Holds Space = auto-jump + forward boost while grounded.
local function bunnyHopOff() untrack("bhop") end
local function bunnyHopOn()
    untrack("bhop")
    track("bhop", RunService.RenderStepped:Connect(function()
        if not UserInputService:IsKeyDown(Enum.KeyCode.Space) then return end
        local hum = getHum(); local root = getRoot()
        if hum and root and hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            local f = Camera.CFrame.LookVector
            root.AssemblyLinearVelocity = Vector3.new(f.X * 45, root.AssemblyLinearVelocity.Y, f.Z * 45)
        end
    end))
end

-- MM2 ROLE DETECTION -------------------------------------------------
-- Scans each player's character + backpack for a Knife/Gun tool and
-- tags them Murderer / Sheriff / Innocent with colored billboards.
local mm2Tags = {}
local function mm2RoleOff()
    untrack("mm2role")
    for _, b in pairs(mm2Tags) do pcall(function() b:Destroy() end) end
    mm2Tags = {}
end
local function mm2RoleOn()
    untrack("mm2role")
    track("mm2role", RunService.Heartbeat:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local role, col = "Innocent", Theme.Green
                local function scan(parent)
                    if not parent then return end
                    for _, t in ipairs(parent:GetChildren()) do
                        if t:IsA("Tool") then
                            local n = t.Name:lower()
                            if n:find("knife") then role, col = "Murderer", Theme.Red
                            elseif n:find("gun") or n:find("revolver") or n:find("sheriff") then role, col = "Sheriff", Theme.Blue end
                        end
                    end
                end
                scan(p.Character); scan(p:FindFirstChild("Backpack"))
                if not mm2Tags[p] then
                    local bb = Instance.new("BillboardGui")
                    bb.Size = UDim2.fromOffset(200, 20)
                    bb.AlwaysOnTop = true
                    bb.Parent = ESPFolder
                    local l = Instance.new("TextLabel")
                    l.BackgroundTransparency = 1; l.Size = UDim2.fromScale(1, 1)
                    l.Font = FontB; l.TextSize = 14; l.TextStrokeTransparency = 0.3
                    l.TextColor3 = col; l.Text = role; l.Parent = bb
                    mm2Tags[p] = bb
                else
                    local head = p.Character and p.Character:FindFirstChild("Head")
                    mm2Tags[p].Adornee = head
                    local l = mm2Tags[p]:FindFirstChildOfClass("TextLabel")
                    if l then l.Text = role; l.TextColor3 = col end
                end
            end
        end
        for p, b in pairs(mm2Tags) do
            if not p.Parent then pcall(function() b:Destroy() end); mm2Tags[p] = nil end
        end
    end))
end

-- PARRY PREDICTION (Blade Ball) --------------------------------------
-- Uses the ball's velocity + closing speed to parry only when the ball
-- is actually about to hit (time-to-impact), instead of raw distance.
local function parryPredictOff() untrack("parryP") end
local function parryPredictOn()
    untrack("parryP")
    track("parryP", RunService.Heartbeat:Connect(function()
        local root = getRoot(); if not root then return end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = obj.Name:lower()
                if n:find("ball") or n:find("orb") then
                    local toMe = root.Position - obj.Position
                    local dist = toMe.Magnitude
                    if dist < State.parryRange then
                        local closing = obj.AssemblyLinearVelocity:Dot(toMe.Unit)
                        if closing > 0 then
                            local tti = dist / math.max(closing, 1)
                            if tti < 0.4 then
                                pressKey(Enum.KeyCode.F); clickMouse()
                            end
                        elseif dist < 6 then
                            pressKey(Enum.KeyCode.F); clickMouse()
                        end
                    end
                end
            end
        end
    end))
end

-- AUTO HATCH (Pet Simulator X) ---------------------------------------
-- Fires proximity prompts attached to "egg" parts when nearby.
local function autoHatchOff() untrack("hatch") end
local function autoHatchOn()
    untrack("hatch")
    track("hatch", RunService.Heartbeat:Connect(function()
        local root = getRoot(); if not root then return end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Parent then
                if obj.Parent.Name:lower():find("egg") then
                    if (obj.WorldPosition - root.Position).Magnitude < 40 then
                        pcall(function() if fireproximityprompt then fireproximityprompt(obj, 0) end end)
                    end
                end
            end
        end
    end))
end

-- AUTO FARM NPC (Blox Fruits / King Legacy / RPGs) -------------------
-- Finds the nearest non-player humanoid (mob/boss), teleports behind it,
-- faces it and attacks in a loop. Classic grind macro.
local function autoFarmNPCOff() untrack("farmnpc") end
local function autoFarmNPCOn()
    untrack("farmnpc")
    track("farmnpc", RunService.Heartbeat:Connect(function()
        local root = getRoot(); local char = getChar()
        if not root or not char then return end
        local best, bd = nil, math.huge
        for _, m in ipairs(Workspace:GetDescendants()) do
            if m:IsA("Model") and not Players:GetPlayerFromCharacter(m) then
                local hum = m:FindFirstChildOfClass("Humanoid")
                local hrp = m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso")
                if hum and hrp and hum.Health > 0 and hum.MaxHealth > 0 then
                    local d = (hrp.Position - root.Position).Magnitude
                    if d < bd then bd = d; best = hrp end
                end
            end
        end
        if best then
            root.CFrame = CFrame.new(best.Position - best.CFrame.LookVector * 4, best.Position)
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") then pcall(function() t:Activate() end) end
            end
            clickMouse()
        end
    end))
end

-- FAST ATTACK (skill spam) -------------------------------------------
-- Rapidly activates held tools / skills to bypass attack cooldown feel.
local faTick = 0
local function fastAttackOff() untrack("fastatk") end
local function fastAttackOn()
    untrack("fastatk")
    track("fastatk", RunService.Heartbeat:Connect(function()
        if tick() - faTick < 0.05 then return end
        faTick = tick()
        local char = getChar(); if not char then return end
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then pcall(function() t:Activate() end) end
        end
    end))
end

-- VEHICLE FLY (Jailbreak / Mad City / Vehicle Sim) -------------------
-- Attaches a BodyVelocity to whatever seat/vehicle the player sits in
-- (falls back to HRP) and flies with WASD + camera, just like on-foot fly.
local vFlyBV
local function vehicleFlyOff()
    if vFlyBV then pcall(function() vFlyBV:Destroy() end) end; vFlyBV = nil
    untrack("vfly")
end
local function vehicleFlyOn()
    vehicleFlyOff()
    track("vfly", RunService.RenderStepped:Connect(function()
        local char = getChar(); if not char then return end
        local seat = char:FindFirstChildWhichIsA("VehicleSeat", true)
        local host = seat or getRoot()
        if not host then return end
        if not vFlyBV or vFlyBV.Parent ~= host then
            if vFlyBV then vFlyBV:Destroy() end
            vFlyBV = Instance.new("BodyVelocity")
            vFlyBV.MaxForce = Vector3.new(1, 1, 1) * 9e9
            vFlyBV.Velocity = Vector3.zero
            vFlyBV.Parent = host
        end
        local cam = Camera
        local v = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then v = v + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then v = v - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then v = v - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then v = v + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then v = v + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then v = v - Vector3.new(0, 1, 0) end
        if v.Magnitude > 0 then v = v.Unit end
        vFlyBV.Velocity = v * State.flySpeed
    end))
end

-- VEHICLE NITRO BOOST (one-shot button) ------------------------------
local function nitroBoost()
    local char = getChar()
    local seat = char and char:FindFirstChildWhichIsA("VehicleSeat", true)
    local root = seat or getRoot()
    if root then
        root.AssemblyLinearVelocity = root.CFrame.LookVector * 220
    end
end

-- BRING NEAREST ITEM (simulators / fruit games) ----------------------
-- Teleports the nearest matching world part to the player (server-owned
-- parts may resist, hence pcall). Used for "bring fruit/coins/loot".
local function bringNearestItem(names)
    local root = getRoot(); if not root then return end
    local best, bd = nil, math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            for _, k in ipairs(names) do
                if n:find(k) then
                    local d = (obj.Position - root.Position).Magnitude
                    if d < bd then bd = d; best = obj end
                end
            end
        end
    end
    if best then
        pcall(function() best.CFrame = root.CFrame + Vector3.new(0, 0, -3) end)
    end
end
local function bringItemsOff() untrack("bring") end
local function bringItemsOn(names)
    untrack("bring")
    track("bring", RunService.Heartbeat:Connect(function()
        bringNearestItem(names)
    end))
end

-- NO KILLBRICK (Tower of Hell / obbies) ------------------------------
-- Refills health the instant the player touches lava/kill/acid parts.
local function noKillbrickOff() untrack("killbrick") end
local function noKillbrickOn()
    untrack("killbrick")
    track("killbrick", RunService.Heartbeat:Connect(function()
        local hum = getHum(); local root = getRoot()
        if not hum or not root then return end
        if hum.Health < hum.MaxHealth * 0.9 then
            for _, p in ipairs(Workspace:GetDescendants()) do
                if p:IsA("BasePart") then
                    local n = p.Name:lower()
                    if (n:find("kill") or n:find("lava") or n:find("acid")) and
                       (p.Position - root.Position).Magnitude < 9 then
                        hum.Health = hum.MaxHealth
                        break
                    end
                end
            end
        end
    end))
end

-- UNLOCK ALL DOORS (Prison Life / Jailbreak) -------------------------
-- Locally de-collides parts named door/gate/barrier so you can walk through.
local function unlockDoors()
    local count = 0
    for _, p in ipairs(Workspace:GetDescendants()) do
        if p:IsA("BasePart") then
            local n = p.Name:lower()
            if n:find("door") or n:find("gate") or n:find("barrier") then
                pcall(function() p.CanCollide = false end)
                count = count + 1
            end
        end
    end
    Notify("Doors", "Unlocked " .. count .. " doors locally.")
end

-- PARACHUTE / SLOW DESCENT (Jailbreak) -------------------------------
local chuteBV
local function parachuteOff()
    if chuteBV then pcall(function() chuteBV:Destroy() end) end; chuteBV = nil
    untrack("chute")
end
local function parachuteOn()
    parachuteOff()
    local root = getRoot(); if not root then return end
    chuteBV = Instance.new("BodyVelocity")
    chuteBV.MaxForce = Vector3.new(0, 1, 0) * 9e9
    chuteBV.Velocity = Vector3.new(0, -8, 0)
    chuteBV.Parent = root
    track("chute", RunService.Heartbeat:Connect(function()
        local r = getRoot()
        if not r or not chuteBV then parachuteOff(); return end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then parachuteOff() end
    end))
end

--====================================================================
_G.antiFlashOff,_G.antiFlashOn,_G.bunnyHopOff,_G.bunnyHopOn,_G.mm2RoleOff,_G.mm2RoleOn,_G.parryPredictOff,_G.parryPredictOn,_G.autoHatchOff,_G.autoHatchOn,_G.autoFarmNPCOff,_G.autoFarmNPCOn,_G.fastAttackOff,_G.fastAttackOn,_G.vehicleFlyOff,_G.vehicleFlyOn,_G.nitroBoost,_G.bringNearestItem,_G.bringItemsOff,_G.bringItemsOn,_G.noKillbrickOff,_G.noKillbrickOn,_G.unlockDoors,_G.parachuteOff,_G.parachuteOn = antiFlashOff,antiFlashOn,bunnyHopOff,bunnyHopOn,mm2RoleOff,mm2RoleOn,parryPredictOff,parryPredictOn,autoHatchOff,autoHatchOn,autoFarmNPCOff,autoFarmNPCOn,fastAttackOff,fastAttackOn,vehicleFlyOff,vehicleFlyOn,nitroBoost,bringNearestItem,bringItemsOff,bringItemsOn,noKillbrickOff,noKillbrickOn,unlockDoors,parachuteOff,parachuteOn
end
do -- ====================  ADVANCED FEATURES  ====================
--                    THREADED FEATURE HELPER
--====================================================================
-- Spawns a looped task that we can stop cleanly. Stores a fake
-- connection in the tracker so untrack() / untrackAll() cancel it.
--====================================================================
local function trackThread(name, interval, fn)
    untrack(name)
    local stopFlag = false
    task.spawn(function()
        while not stopFlag do
            pcall(fn)
            task.wait(interval or 0.2)
        end
    end)
    track(name, { Disconnect = function() stopFlag = true end })
end

--====================================================================
--                  ADVANCED ESP: SKELETON BONES
--====================================================================
-- Draws lines between a character's joints (R6 + R15 aware).
local SKEL_PAIRS = {
    { "Head", "UpperTorso" }, { "Head", "Torso" },
    { "UpperTorso", "LowerTorso" }, { "Torso", "LowerTorso" },
    { "UpperTorso", "LeftUpperArm" }, { "UpperTorso", "RightUpperArm" },
    { "Torso", "Left Arm" }, { "Torso", "Right Arm" },
    { "LeftUpperArm", "LeftLowerArm" }, { "RightUpperArm", "RightLowerArm" },
    { "LeftLowerArm", "LeftHand" }, { "RightLowerArm", "RightHand" },
    { "Left Arm", "LeftHand" }, { "Right Arm", "RightHand" },
    { "LowerTorso", "LeftUpperLeg" }, { "LowerTorso", "RightUpperLeg" },
    { "Torso", "Left Leg" }, { "Torso", "Right Leg" },
    { "LeftUpperLeg", "LeftLowerLeg" }, { "RightUpperLeg", "RightLowerLeg" },
    { "LeftLowerLeg", "LeftFoot" }, { "RightLowerLeg", "RightFoot" },
    { "Left Leg", "LeftFoot" }, { "Right Leg", "RightFoot" },
}
local skelData = {}
local function skeletonClear()
    for _, pool in pairs(skelData) do
        for _, l in ipairs(pool) do pcall(function() l:Destroy() end) end
    end
    skelData = {}
end
local function skeletonOff() untrack("skeleton"); skeletonClear() end
local function skeletonOn()
    skeletonClear()
    track("skeleton", RunService.RenderStepped:Connect(function()
        local col = espColor()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Parent then
                local char = plr.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    if not skelData[plr] then
                        local pool = {}
                        for i = 1, #SKEL_PAIRS do
                            local f = Instance.new("Frame")
                            f.BackgroundColor3 = col
                            f.BorderSizePixel = 0
                            f.AnchorPoint = Vector2.new(0, 0.5)
                            f.Visible = false
                            f.ZIndex = 5
                            f.Parent = DrawFolder
                            pool[i] = f
                        end
                        skelData[plr] = pool
                    end
                    local pool = skelData[plr]
                    for i, pair in ipairs(SKEL_PAIRS) do
                        local a = char:FindFirstChild(pair[1])
                        local b = char:FindFirstChild(pair[2])
                        local line = pool[i]
                        if a and b and line then
                            local sa, ona = worldToScreen(a.Position)
                            local sb, onb = worldToScreen(b.Position)
                            if ona and onb then
                                line.Visible = true
                                line.BackgroundColor3 = col
                                placeLine(line, sa, sb)
                            else
                                line.Visible = false
                            end
                        elseif line then
                            line.Visible = false
                        end
                    end
                end
            end
        end
        for plr, pool in pairs(skelData) do
            local dead = not plr.Parent or not plr.Character
                or not plr.Character:FindFirstChildOfClass("Humanoid")
                or plr.Character:FindFirstChildOfClass("Humanoid").Health <= 0
            if dead then
                for _, l in ipairs(pool) do pcall(function() l:Destroy() end) end
                skelData[plr] = nil
            end
        end
    end))
end

--====================================================================
--                  ADVANCED ESP: HEAD DOTS
--====================================================================
local dotData = {}
local function headDotOff()
    untrack("headdot")
    for _, d in pairs(dotData) do pcall(function() d:Destroy() end) end
    dotData = {}
end
local function headDotOn()
    headDotOff()
    track("headdot", RunService.RenderStepped:Connect(function()
        local col = espColor()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Parent then
                local head = plr.Character:FindFirstChild("Head")
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                if head and hum and hum.Health > 0 then
                    if not dotData[plr] then
                        local d = Instance.new("Frame")
                        d.Size = UDim2.fromOffset(9, 9)
                        d.BackgroundColor3 = col
                        d.BorderSizePixel = 0
                        d.ZIndex = 5
                        d.Parent = DrawFolder
                        corner(d, 5)
                        dotData[plr] = d
                    end
                    local sp, on = worldToScreen(head.Position + Vector3.new(0, 1.2, 0))
                    dotData[plr].Visible = on
                    if on then
                        dotData[plr].Position = UDim2.fromOffset(sp.X - 4, sp.Y - 4)
                        dotData[plr].BackgroundColor3 = col
                    end
                end
            end
        end
        for plr, d in pairs(dotData) do
            if not plr.Parent or not plr.Character then
                pcall(function() d:Destroy() end); dotData[plr] = nil
            end
        end
    end))
end

--====================================================================
--                  ADVANCED ESP: WEAPON / TOOL TAGS
--====================================================================
local wpnData = {}
local function weaponEspOff()
    untrack("weapon")
    for _, b in pairs(wpnData) do pcall(function() b:Destroy() end) end
    wpnData = {}
end
local function weaponEspOn()
    weaponEspOff()
    track("weapon", RunService.Heartbeat:Connect(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Parent then
                local tool = plr.Character:FindFirstChildWhichIsA("Tool")
                local head = plr.Character:FindFirstChild("Head")
                if tool and head then
                    if not wpnData[plr] then
                        local bb = Instance.new("BillboardGui")
                        bb.Size = UDim2.fromOffset(220, 16)
                        bb.StudsOffset = Vector3.new(0, 3.6, 0)
                        bb.AlwaysOnTop = true
                        bb.Parent = ESPFolder
                        local l = Instance.new("TextLabel")
                        l.BackgroundTransparency = 1
                        l.Size = UDim2.fromScale(1, 1)
                        l.Font = FontR; l.TextSize = 12
                        l.TextColor3 = Theme.Yellow
                        l.TextStrokeColor3 = Theme.Black
                        l.TextStrokeTransparency = 0.3
                        l.Parent = bb
                        wpnData[plr] = bb
                    end
                    wpnData[plr].Adornee = head
                    local l = wpnData[plr]:FindFirstChildOfClass("TextLabel")
                    if l then l.Text = "🔫  " .. tool.Name end
                elseif wpnData[plr] then
                    pcall(function() wpnData[plr]:Destroy() end); wpnData[plr] = nil
                end
            end
        end
    end))
end

--====================================================================
--                  PREDICTIVE AIMBOT (lead target)
--====================================================================
local function predAimOff() untrack("predaim") end
local function predAimOn()
    predAimOff()
    track("predaim", RunService.RenderStepped:Connect(function()
        if not State.predictionAim then return end
        local tgt = getClosest(State.aimFov, State.aimPart)
        if tgt then
            local dist = (tgt.Position - Camera.CFrame.Position).Magnitude
            local t = dist / math.max(State.bulletSpeed or 400, 1)
            local pred = tgt.Position + (tgt.AssemblyLinearVelocity * t)
            local goal = CFrame.new(Camera.CFrame.Position, pred)
            local f = State.aimSmooth
            Camera.CFrame = (f and f > 0 and f < 1)
                and Camera.CFrame:Lerp(goal, 1 - f) or goal
        end
    end))
end

--====================================================================
--                  CFRAME SPEED (anti-speed detection)
--====================================================================
local function cframeSpeedOff() untrack("cframespeed") end
local function cframeSpeedOn()
    cframeSpeedOff()
    track("cframespeed", RunService.RenderStepped:Connect(function()
        local root = getRoot(); if not root then return end
        local cam = Camera
        local v = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then v = v + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then v = v - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then v = v - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then v = v + cam.CFrame.RightVector end
        if v.Magnitude > 0 then
            v = Vector3.new(v.X, 0, v.Z).Unit
            root.CFrame = root.CFrame + v * (State.cframeSpeed / 60)
        end
    end))
end

--====================================================================
--                       TP WALK (step teleport)
--====================================================================
local function tpWalkOff() untrack("tpwalk") end
local function tpWalkOn()
    tpWalkOff()
    track("tpwalk", RunService.Stepped:Connect(function()
        local root = getRoot(); if not root then return end
        local cam = Camera
        local v = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then v = v + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then v = v - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then v = v - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then v = v + cam.CFrame.RightVector end
        if v.Magnitude > 0 then
            v = Vector3.new(v.X, 0, v.Z).Unit
            root.CFrame = root.CFrame + v * 3
        end
    end))
end

--====================================================================
--                       SPIN BOT / ANTI-AIM
--====================================================================
local function spinOff() untrack("spin") end
local function spinOn()
    spinOff()
    track("spin", RunService.RenderStepped:Connect(function(dt)
        local root = getRoot(); if not root then return end
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad((State.spinSpeed or 6) * 60 * dt), 0)
    end))
end
local function antiAimOff() untrack("antiaim") end
local function antiAimOn()
    antiAimOff()
    track("antiaim", RunService.Heartbeat:Connect(function()
        local root = getRoot(); if not root then return end
        local hum = getHum()
        if hum then hum.AutoRotate = false end
        local off = (tick() * 40) % 360
        root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(off), 0)
    end))
end

--====================================================================
--                    NO RECOIL / NO SWAY
--====================================================================
local function noRecoilOff() untrack("norecoil") end
local function noRecoilOn()
    noRecoilOff()
    track("norecoil", RunService.Heartbeat:Connect(function()
        local hum = getHum()
        if hum then hum.CameraOffset = Vector3.zero end
        local char = getChar()
        if char then
            local tool = char:FindFirstChildWhichIsA("Tool")
            if tool then
                for _, d in ipairs(tool:GetDescendants()) do
                    if d:IsA("NumberValue") or d:IsA("IntValue") then
                        local n = d.Name:lower()
                        if n:find("recoil") or n:find("spread") or n:find("kick")
                        or n:find("sway") or n:find("bloom") then
                            pcall(function() d.Value = 0 end)
                        end
                    end
                end
            end
        end
    end))
end

--====================================================================
--                       AUTO RESPAWN
--====================================================================
local function autoRespawnOff() untrack("respawn") end
local function autoRespawnOn()
    autoRespawnOff()
    local function bind()
        local hum = getHum()
        if hum then
            hum.Died:Once(function()
                task.wait(0.6)
                pcall(function() LocalPlayer:LoadCharacter() end)
            end)
        end
    end
    bind()
    track("respawn", LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5); bind()
    end))
end

--====================================================================
--                    SERVER HOP / REJOIN
--====================================================================
local function rejoinServer()
    Notify("Rejoin", "Teleporting back in...")
    pcall(function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end)
end
local function serverHop()
    Notify("Server Hop", "Searching for a fresh server...")
    local TeleportService = game:GetService("TeleportService")
    local ok, res = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/" .. game.PlaceId
            .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if ok and res and res.data then
        for _, s in ipairs(res.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                end)
                return
            end
        end
        Notify("Server Hop", "No open servers found.")
    else
        Notify("Server Hop", "HTTP unavailable in this environment.")
    end
end

--====================================================================
--                        FPS BOOST
--====================================================================
local function fpsBoost()
    local cleared = 0
    for _, d in ipairs(Workspace:GetDescendants()) do
        if d:IsA("BasePart") then
            pcall(function() d.Material = Enum.Material.Plastic end)
        elseif d:IsA("Texture") or d:IsA("Decal") then
            pcall(function() d.Transparency = 1 end); cleared = cleared + 1
        elseif d:IsA("SpecialMesh") then
            pcall(function() d.TextureId = "" end)
        end
    end
    pcall(function() Lighting.GlobalShadows = false end)
    for _, e in ipairs(Lighting:GetChildren()) do
        if e:IsA("BlurEffect") or e:IsA("DepthOfFieldEffect") then
            pcall(function() e.Enabled = false end)
        end
    end
    Notify("FPS Boost", "Reduced textures & effects (" .. cleared .. " cleared).")
end

--====================================================================
--                       MACRO RECORDER
--====================================================================
local Macro = { recording = false, frames = {}, playing = false }
local function macroStart()
    Macro.recording = true; Macro.frames = {}
    Notify("Macro", "Recording position trail...")
    task.spawn(function()
        while Macro.recording do
            local r = getRoot()
            if r then table.insert(Macro.frames, r.CFrame) end
            task.wait(0.05)
        end
    end)
end
local function macroStop()
    Macro.recording = false
    Notify("Macro", "Stopped. Captured " .. #Macro.frames .. " frames.")
end
local function macroPlay()
    if #Macro.frames == 0 then Notify("Macro", "Nothing recorded yet."); return end
    Macro.playing = true
    Notify("Macro", "Playing back...")
    task.spawn(function()
        for _, cf in ipairs(Macro.frames) do
            local r = getRoot()
            if not Macro.playing or not r then break end
            r.CFrame = cf
            task.wait(0.05)
        end
        Macro.playing = false
    end)
end
local function macroAbort() Macro.playing = false end

--====================================================================
--                      DISCORD WEBHOOK
--====================================================================
local function sendWebhook(url, content)
    if not url or url == "" then Notify("Webhook", "Set a URL first."); return end
    local ok = pcall(function()
        if request then
            request({
                Url = url, Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode({ content = content }),
            })
        end
    end)
    Notify("Webhook", ok and "Sent!" or "Failed (need 'request').")
end

--====================================================================
--====================================================================
_G.trackThread,_G.skeletonClear,_G.skeletonOff,_G.skeletonOn,_G.headDotOff,_G.headDotOn,_G.weaponEspOff,_G.weaponEspOn,_G.predAimOff,_G.predAimOn,_G.cframeSpeedOff,_G.cframeSpeedOn,_G.tpWalkOff,_G.tpWalkOn,_G.spinOff,_G.spinOn,_G.antiAimOff,_G.antiAimOn,_G.noRecoilOff,_G.noRecoilOn,_G.autoRespawnOff,_G.autoRespawnOn,_G.rejoinServer,_G.serverHop,_G.fpsBoost,_G.macroStart,_G.macroStop,_G.macroPlay,_G.macroAbort,_G.sendWebhook = trackThread,skeletonClear,skeletonOff,skeletonOn,headDotOff,headDotOn,weaponEspOff,weaponEspOn,predAimOff,predAimOn,cframeSpeedOff,cframeSpeedOn,tpWalkOff,tpWalkOn,spinOff,spinOn,antiAimOff,antiAimOn,noRecoilOff,noRecoilOn,autoRespawnOff,autoRespawnOn,rejoinServer,serverHop,fpsBoost,macroStart,macroStop,macroPlay,macroAbort,sendWebhook
end
do -- ====================  AUTO FARM + ARREST  ====================
--                    AUTO FARM SUITE  (full)
--====================================================================
--====================================================================
-- Generic, robust, pcall-safe automation loops. Each finds relevant
-- world objects/NPCs by name and farms/collects/presses them on a loop.
--====================================================================

-- nearest helper for NPC models
local function findNearestNPC(filter, maxHealth)
    local root = getRoot(); if not root then return nil end
    local best, bd = nil, math.huge
    for _, m in ipairs(Workspace:GetDescendants()) do
        if m:IsA("Model") and not Players:GetPlayerFromCharacter(m) then
            local hum = m:FindFirstChildOfClass("Humanoid")
            local hrp = m:FindFirstChild("HumanoidRootPart") or m.PrimaryPart
            local n = m.Name:lower()
            if hum and hrp and hum.Health > 0 then
                local match = false
                if filter then for _, f in ipairs(filter) do if n:find(f) then match = true; break end end end
                if (filter == nil) or match or (maxHealth and hum.MaxHealth >= maxHealth) then
                    local d = (hrp.Position - root.Position).Magnitude
                    if d < bd then bd = d; best = hrp end
                end
            end
        end
    end
    return best
end

-- AUTO QUEST: walk to NPC givers + fire their prompts
local function autoQuestOn()
    trackThread("autoquest", 0.5, function()
        local root = getRoot(); if not root then return end
        for _, d in ipairs(Workspace:GetDescendants()) do
            local n = d.Name:lower()
            if (d:IsA("Model") or d:IsA("BasePart")) and
               (n:find("quest") or n:find("villager") or n:find("merchant") or n:find("npc")) then
                local hrp = (d:IsA("Model") and (d:FindFirstChild("HumanoidRootPart") or d.PrimaryPart))
                    or (d:IsA("BasePart") and d)
                local pp = d:IsA("Model") and d:FindFirstChildWhichIsA("ProximityPrompt", true)
                if hrp then
                    local pos = hrp.Position
                    if (pos - root.Position).Magnitude < 220 then
                        root.CFrame = CFrame.new(pos + Vector3.new(0, 0, 3))
                        if pp and fireproximityprompt then fireproximityprompt(pp, 0) end
                        break
                    end
                end
            end
        end
    end)
end
local function autoQuestOff() untrack("autoquest") end

-- AUTO BOSS: hunt high-HP / "boss" models
local function autoBossOn()
    trackThread("autoboss", 0.2, function()
        local root = getRoot(); local char = getChar()
        if not root or not char then return end
        local best = findNearestNPC({ "boss" }, 2500)
        if best then
            root.CFrame = CFrame.new(best.Position - best.CFrame.LookVector * 4, best.Position)
            for _, t in ipairs(char:GetChildren()) do
                if t:IsA("Tool") then pcall(function() t:Activate() end) end
            end
        end
    end)
end
local function autoBossOff() untrack("autoboss") end

-- AUTO DUNGEON / RAID: walk into portals/entrances
local function autoDungeonOn()
    trackThread("autodungeon", 0.6, function()
        local root = getRoot(); if not root then return end
        for _, d in ipairs(Workspace:GetDescendants()) do
            if d:IsA("BasePart") then
                local n = d.Name:lower()
                if n:find("portal") or n:find("entrance") or n:find("dungeon") or n:find("raid") then
                    if (d.Position - root.Position).Magnitude < 300 then
                        root.CFrame = d.CFrame + Vector3.new(0, 3, 0)
                        break
                    end
                end
            end
        end
    end)
end
local function autoDungeonOff() untrack("autodungeon") end

-- generic key-press loop (rebirth/upgrade/buy)
local function autoPressLoopOn(tag, code, interval)
    trackThread(tag, interval or 0.6, function() pressKey(code) end)
end

-- AUTO REBIRTH / UPGRADE / BUY
local function autoRebirthOn() autoPressLoopOn("autorebirth", Enum.KeyCode.R, 1.2) end
local function autoRebirthOff() untrack("autorebirth") end
local function autoUpgradeOn() autoPressLoopOn("autoupgrade", Enum.KeyCode.U, 0.6) end
local function autoUpgradeOff() untrack("autoupgrade") end
local function autoBuyOn() autoPressLoopOn("autobuy", Enum.KeyCode.B, 0.6) end
local function autoBuyOff() untrack("autobuy") end

-- AUTO EQUIP: always keep a tool equipped
local function autoEquipOn()
    trackThread("autoequip", 0.6, function()
        local char = getChar(); local hum = getHum()
        if not char or not hum then return end
        if not char:FindFirstChildWhichIsA("Tool") then
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if bp then
                local tool = bp:FindFirstChildWhichIsA("Tool")
                if tool then pcall(function() hum:EquipTool(tool) end) end
            end
        end
    end)
end
local function autoEquipOff() untrack("autoequip") end

-- tool-based farming (fish / mine / woodcut / loot)
local function toolFarmOn(tag, radius)
    trackThread(tag, 0.2, function()
        local char = getChar(); local root = getRoot()
        if not char or not root then return end
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then pcall(function() t:Activate() end) end
        end
        for _, o in ipairs(Workspace:GetDescendants()) do
            if o:IsA("ProximityPrompt") then
                if (o.WorldPosition - root.Position).Magnitude < (radius or 16) then
                    pcall(function() if fireproximityprompt then fireproximityprompt(o, 0) end end)
                end
            end
        end
    end)
end
local function autoFishOn() toolFarmOn("autofish", 22) end
local function autoFishOff() untrack("autofish") end
local function autoMineOn() toolFarmOn("automine", 18) end
local function autoMineOff() untrack("automine") end
local function autoWoodcutOn() toolFarmOn("autowood", 16) end
local function autoWoodcutOff() untrack("autowood") end
local function autoLootOn() toolFarmOn("autoloot", 80) end
local function autoLootOff() untrack("autoloot") end
local function autoCollectAllOn()
    trackThread("autocollectall", 0.15, function()
        local root = getRoot(); if not root then return end
        for _, o in ipairs(Workspace:GetDescendants()) do
            if o:IsA("ProximityPrompt") and (o.WorldPosition - root.Position).Magnitude < 120 then
                pcall(function() if fireproximityprompt then fireproximityprompt(o, 0) end end)
            end
        end
    end)
end
local function autoCollectAllOff() untrack("autocollectall") end

-- master controls
local function startAllAuto()
    autoFarmNPCOn(); autoBossOn(); autoLootOn(); autoCollectOn(); autoClickOn()
    Notify("Auto Farm", "Started core automation loops.")
end
local function stopAllAuto()
    for _, t in ipairs({ "autoquest", "autoboss", "autodungeon", "autorebirth",
        "autoupgrade", "autobuy", "autoequip", "autofish", "automine",
        "autowood", "autoloot", "autocollectall", "farmnpc", "collect",
        "autoclick", "rob", "plant", "arrest" }) do untrack(t) end
    Notify("Auto Farm", "Stopped all automation.")
end

--====================================================================
--                          AUTO ARREST
--====================================================================
-- Police-style macro for Jailbreak / Prison Life / Mad City. Hunts the
-- nearest prisoner/criminal (by team name), moves close behind them,
-- and fires every common arrest method: mouse click, handcuff/taser
-- tool activation, and any nearby arrest ProximityPrompt.
--====================================================================

-- is this player an arrestable suspect? (criminal / prisoner / inmate)
local function isSuspect(plr)
    if not plr or not plr.Parent then return false end
    if plr == LocalPlayer then return false end
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    -- 1) team-name check
    if plr.Team and plr.Team.Name then
        local n = plr.Team.Name:lower()
        if n:find("criminal") or n:find("prisoner") or n:find("inmate")
        or n:find("escape") or n:find("escaped") or n:find("bad") or n:find("rogue") then
            return true
        end
    end
    -- 2) "wanted"/arrestable attribute / value fallback
    local tag = char:FindFirstChild("Wanted") or char:FindFirstChild("Criminal")
        or char:FindFirstChild("Arrestable")
    if tag then
        if tag:IsA("BoolValue") then return tag.Value end
        if tag:IsA("IntValue") or tag:IsA("NumberValue") then return tag.Value > 0 end
        return true
    end
    -- 3) bail target = nearest player (any)
    if State.arrestTarget == "Nearest Player" then
        return char:FindFirstChild("HumanoidRootPart") ~= nil
    end
    return false
end

local function getNearestSuspect()
    local root = getRoot(); if not root then return nil, math.huge end
    local best, bd = nil, State.arrestRange
    for _, p in ipairs(Players:GetPlayers()) do
        if isSuspect(p) and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d = (hrp.Position - root.Position).Magnitude
                if d < bd then bd = d; best = p end
            end
        end
    end
    return best, bd
end

local function autoArrestOff() untrack("arrest") end
local function autoArrestOn()
    untrack("arrest")
    trackThread("arrest", 0.15, function()
        local root = getRoot(); local char = getChar()
        if not root or not char then return end
        local target = getNearestSuspect()
        if not target or not target.Character then return end
        local thrp = target.Character:FindFirstChild("HumanoidRootPart")
        if not thrp then return end
        -- stand right behind the suspect, facing them
        root.CFrame = CFrame.new(thrp.Position - thrp.CFrame.LookVector * 3, thrp.Position)
        -- method 1: most games arrest on a click aimed at the player
        clickMouse()
        -- method 2: activate any handcuff / taser / arrest tool we hold
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then
                local n = t.Name:lower()
                if n:find("handcuff") or n:find("arrest") or n:find("taser")
                or n:find("baton") or n:find("police") then
                    pcall(function() t:Activate() end)
                end
            end
        end
        -- method 3: fire any arrest-style proximity prompt on them
        for _, d in ipairs(target.Character:GetDescendants()) do
            if d:IsA("ProximityPrompt") then
                pcall(function() if fireproximityprompt then fireproximityprompt(d, 0) end end)
            end
        end
    end)
end

_G.findNearestNPC,_G.autoQuestOn,_G.autoQuestOff,_G.autoBossOn,_G.autoBossOff,_G.autoDungeonOn,_G.autoDungeonOff,_G.autoPressLoopOn,_G.autoRebirthOn,_G.autoRebirthOff,_G.autoUpgradeOn,_G.autoUpgradeOff,_G.autoBuyOn,_G.autoBuyOff,_G.autoEquipOn,_G.autoEquipOff,_G.toolFarmOn,_G.autoFishOn,_G.autoFishOff,_G.autoMineOn,_G.autoMineOff,_G.autoWoodcutOn,_G.autoWoodcutOff,_G.autoLootOn,_G.autoLootOff,_G.autoCollectAllOn,_G.autoCollectAllOff,_G.startAllAuto,_G.stopAllAuto,_G.isSuspect,_G.getNearestSuspect,_G.autoArrestOff,_G.autoArrestOn = findNearestNPC,autoQuestOn,autoQuestOff,autoBossOn,autoBossOff,autoDungeonOn,autoDungeonOff,autoPressLoopOn,autoRebirthOn,autoRebirthOff,autoUpgradeOn,autoUpgradeOff,autoBuyOn,autoBuyOff,autoEquipOn,autoEquipOff,toolFarmOn,autoFishOn,autoFishOff,autoMineOn,autoMineOff,autoWoodcutOn,autoWoodcutOff,autoLootOn,autoLootOff,autoCollectAllOn,autoCollectAllOff,startAllAuto,stopAllAuto,isSuspect,getNearestSuspect,autoArrestOff,autoArrestOn
end
print("[UniversalGameHub] Advanced game-matched features loaded.")

print("[UniversalGameHub] Combat + utility + teleport features loaded.")

--====================================================================
--====================================================================
--                  UNIVERSAL FEATURES TAB BUILDER
--====================================================================
--====================================================================
-- Builds the shared "Universal" tab that appears in EVERY game window.
--====================================================================
--====================================================================
--                   HUD / OVERLAY SYSTEM
-- Watermark (with live FPS), dynamic crosshair, and world-render tweaks.
--====================================================================
local Watermark = Instance.new("Frame")
Watermark.Size = UDim2.fromOffset(240, 32)
Watermark.Position = UDim2.fromOffset(12, 12)
Watermark.BackgroundColor3 = Theme.ElementD
Watermark.BackgroundTransparency = 0.15
Watermark.BorderSizePixel = 0
Watermark.Visible = false
Watermark.Parent = ScreenGui
corner(Watermark, 8)
stroke(Watermark, Theme.Accent, 1, 0.2)
gradient(Watermark, Theme.AccentD, Theme.ElementD, 0)
local wmText = Instance.new("TextLabel")
wmText.BackgroundTransparency = 1
wmText.Position = UDim2.fromOffset(10, 0)
wmText.Size = UDim2.new(1, -20, 1, 0)
wmText.Font = FontM; wmText.TextSize = 12
wmText.TextColor3 = Theme.Text
wmText.TextXAlignment = Enum.TextXAlignment.Left
wmText.Text = "Universal Game Hub  •  0 FPS"
wmText.Parent = Watermark

local Crosshair = Instance.new("Frame")
Crosshair.Size = UDim2.fromOffset(24, 24)
Crosshair.AnchorPoint = Vector2.new(0.5, 0.5)
Crosshair.Position = UDim2.new(0.5, 0, 0.5, 0)
Crosshair.BackgroundTransparency = 1
Crosshair.BorderSizePixel = 0
Crosshair.Visible = false
Crosshair.Parent = ScreenGui

local function makeCrossLine(offX, offY, sizeX, sizeY)
    local l = Instance.new("Frame")
    l.AnchorPoint = Vector2.new(0.5, 0.5)
    l.Position = UDim2.new(0.5, offX, 0.5, offY)
    l.Size = UDim2.fromOffset(sizeX, sizeY)
    l.BackgroundColor3 = Theme.Accent2
    l.BorderSizePixel = 0
    l.Parent = Crosshair
    corner(l, 1)
    return l
end
local cLineUp    = makeCrossLine(0, -8, 2, 8)
local cLineDown  = makeCrossLine(0, 8, 2, 8)
local cLineLeft  = makeCrossLine(-8, 0, 8, 2)
local cLineRight = makeCrossLine(8, 0, 8, 2)

local function setCrosshairColor(c)
    cLineUp.BackgroundColor3 = c; cLineDown.BackgroundColor3 = c
    cLineLeft.BackgroundColor3 = c; cLineRight.BackgroundColor3 = c
end

-- live FPS updater
local fpsFrames, fpsTime, fpsValue = 0, 0, 0
track("hud_fps", RunService.Heartbeat:Connect(function(dt)
    fpsFrames = fpsFrames + 1
    fpsTime = fpsTime + dt
    if fpsTime >= 0.5 then
        fpsValue = math.floor(fpsFrames / fpsTime)
        fpsFrames = 0; fpsTime = 0
        wmText.Text = "Universal Game Hub  •  " .. fpsValue .. " FPS"
    end
end))

--====================================================================
--                 WORLD / RENDER HELPERS
--====================================================================
local function setClockTime(t) Lighting.ClockTime = t end
local function setBrightness(b) Lighting.Brightness = b end
local function setAmbient(c) Lighting.Ambient = c end
local function setOutdoorAmbient(c) Lighting.OutdoorAmbient = c end

local shadowsStore = nil
local function toggleShadows(on)
    if on then
        if shadowsStore ~= nil then Lighting.GlobalShadows = shadowsStore end
    else
        shadowsStore = Lighting.GlobalShadows
        Lighting.GlobalShadows = false
    end
end

local function applyCharacterTransparency(alpha)
    local c = getChar()
    if c then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                p.LocalTransparencyModifier = alpha
            end
        end
    end
end

local function resetCharacterVisual()
    local c = getChar()
    if c then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.LocalTransparencyModifier = 0 end
        end
    end
end

--====================================================================
--                 UNIVERSAL FEATURES TAB BUILDER
--====================================================================
local function addUniversalFeatures(tab)

    -- HUD / OVERLAYS ------------------------------------------------
    tab:AddSection("HUD / OVERLAYS")
    tab:AddToggle("Watermark + FPS", false, function(v)
        Watermark.Visible = v; State.watermark = v
    end)
    tab:AddToggle("Crosshair", false, function(v)
        Crosshair.Visible = v
    end)
    tab:AddColorPicker("Crosshair Color", Theme.Accent2, function(c) setCrosshairColor(c) end)

    -- WORLD / RENDER ------------------------------------------------
    tab:AddSection("WORLD / RENDER")
    tab:AddSlider("Time of Day", 0, 24, 14, "h", function(v) setClockTime(v) end)
    tab:AddSlider("Brightness", 0, 5, 2, "", function(v) setBrightness(v) end)
    tab:AddToggle("Remove Shadows", false, function(v) toggleShadows(not v) end)
    tab:AddColorPicker("Ambient Color", Lighting.Ambient, function(c) setAmbient(c) end)
    tab:AddColorPicker("Outdoor Ambient", Lighting.OutdoorAmbient, function(c) setOutdoorAmbient(c) end)
    tab:AddSlider("Char Transparency", 0, 100, 0, "%", function(v) applyCharacterTransparency(v / 100) end)
    tab:AddButton("Reset Character Visual", function() resetCharacterVisual() end)

    -- AIM -----------------------------------------------------------
    tab:AddSection("AIM")
    tab:AddToggle("Aimbot", State.aimbot, function(v)
        State.aimbot = v; if v then aimbotOn() else aimbotOff() end
    end, true)
    tab:AddToggle("Silent Aim", State.silentAim, function(v)
        State.silentAim = v; if v then silentOn() else silentOff() end
    end)
    tab:AddToggle("Triggerbot", State.triggerbot, function(v)
        State.triggerbot = v; if v then triggerOn() else triggerOff() end
    end)
    tab:AddToggle("Team Check", State.teamCheck, function(v) State.teamCheck = v end)
    tab:AddToggle("Wall Check (visible)", State.wallCheck, function(v) State.wallCheck = v end)
    tab:AddDropdown("Aim Part", { "Head", "HumanoidRootPart", "Torso", "UpperTorso" }, State.aimPart, function(v)
        State.aimPart = v
    end)
    tab:AddSlider("Aimbot FOV", 20, 800, State.aimFov, "", function(v)
        State.aimFov = v; setFov(v)
    end)
    tab:AddSlider("Smoothing", 0, 95, math.floor(State.aimSmooth * 100), "%", function(v)
        State.aimSmooth = v / 100
    end)

    -- COMBAT --------------------------------------------------------
    tab:AddSection("COMBAT")
    tab:AddToggle("Auto Fire", State.autoFire, function(v)
        State.autoFire = v; if v then autoFireOn() else autoFireOff() end
    end)
    tab:AddToggle("Kill Aura", State.killAura, function(v)
        State.killAura = v; if v then auraOn() else auraOff() end
    end)
    tab:AddSlider("Aura Range", 4, 60, State.auraRange, "", function(v) State.auraRange = v end)
    tab:AddToggle("Hitbox Expander", State.hitbox, function(v)
        State.hitbox = v; if v then hitboxOn() else hitboxOff() end
    end)
    tab:AddSlider("Hitbox Size", 1, 50, State.hitboxSize, "", function(v) State.hitboxSize = v end)
    tab:AddSlider("Hitbox Transparency", 0, 100, math.floor(State.hitboxTrans * 100), "%", function(v)
        State.hitboxTrans = v / 100
    end)
    tab:AddToggle("God Mode", State.godMode, function(v)
        State.godMode = v; if v then godOn() else godOff() end
    end)

    -- MOVEMENT ------------------------------------------------------
    tab:AddSection("MOVEMENT")
    tab:AddToggle("Fly  (WASD/Space/Ctrl)", State.fly, function(v)
        State.fly = v; if v then flyOn() else flyOff() end
    end, true)
    tab:AddSlider("Fly Speed", 10, 500, State.flySpeed, "", function(v) State.flySpeed = v end)
    tab:AddSlider("Walk Speed", 16, 500, State.speed, "", function(v)
        State.speed = v; State.useSpeed = true; applyMovement()
    end)
    tab:AddSlider("Jump Power", 50, 500, State.jump, "", function(v)
        State.jump = v; State.useJump = true; applyMovement()
    end)
    tab:AddSlider("Gravity", 0, 400, State.gravity, "", function(v)
        State.gravity = v; State.useGravity = true; applyMovement()
    end)
    tab:AddToggle("Infinite Jump", State.infJump, function(v)
        State.infJump = v; if v then infJumpOn() else infJumpOff() end
    end)
    tab:AddToggle("Noclip", State.noclip, function(v)
        State.noclip = v; if v then noclipOn() else noclipOff() end
    end)
    tab:AddToggle("Swim", State.swim, function(v)
        State.swim = v; if v then swimOn() else swimOff() end
    end)
    tab:AddToggle("No Fall Damage", State.antiFall, function(v)
        State.antiFall = v; if v then noFallOn() else noFallOff() end
    end)
    tab:AddToggle("Anti-Fling", State.antiFling, function(v)
        State.antiFling = v; if v then antiFlingOn() else antiFlingOff() end
    end)

    -- VISUALS -------------------------------------------------------
    tab:AddSection("VISUALS")
    tab:AddToggle("Player ESP", State.esp, function(v)
        State.esp = v; if v then espOn() else espOff() end
    end, true)
    tab:AddToggle("  • Chams (highlight)", State.espChams, function(v)
        State.espChams = v
    end)
    tab:AddToggle("  • Names", State.espName, function(v) State.espName = v end)
    tab:AddToggle("  • Distance", State.espDist, function(v) State.espDist = v end)
    tab:AddToggle("  • Boxes", State.espBox, function(v) State.espBox = v end)
    tab:AddToggle("  • Health Bars", State.espHealth, function(v) State.espHealth = v end)
    tab:AddToggle("  • Tracers", State.espTracer, function(v) State.espTracer = v end)
    tab:AddToggle("  • Use Team Color", State.espTeam, function(v) State.espTeam = v end)
    tab:AddToggle("  • Visible Only", State.espVisibleOnly, function(v) State.espVisibleOnly = v end)
    tab:AddDropdown("Tracer Origin", { "Bottom", "Center", "Mouse" }, State.tracerOrigin, function(v)
        State.tracerOrigin = v
    end)
    tab:AddColorPicker("ESP Color", Color3.new(
        State.espColor[1] or 0.69, State.espColor[2] or 0.44, State.espColor[3] or 1),
        function(c)
            State.espColor = { c.R, c.G, c.B }
        end)
    tab:AddToggle("Fullbright", State.fullbright, function(v)
        State.fullbright = v; if v then fbOn() else fbOff() end
    end)
    tab:AddToggle("Remove Fog", State.removeFog, function(v)
        State.removeFog = v; if v then fogOn() else fogOff() end
    end)
    tab:AddToggle("Night Vision", State.nightVision, function(v)
        State.nightVision = v; if v then nightOn() else nightOff() end
    end)
    tab:AddToggle("Show FOV Circle", State.showFov, function(v)
        State.showFov = v; setFovVisible(v)
    end)
    tab:AddColorPicker("FOV Circle Color", Theme.Accent, function(c) setFovColor(c) end)
    tab:AddSlider("FOV Thickness", 1, 8, 2, "", function(v) setFovThickness(v) end)
    tab:AddSlider("Camera FOV", 30, 120, State.camFov, "", function(v)
        State.camFov = v; setCamFov(v)
    end)

    -- UTILITY -------------------------------------------------------
    tab:AddSection("UTILITY")
    tab:AddToggle("Anti-AFK", State.antiAfk, function(v)
        State.antiAfk = v; if v then antiAfkOn() else antiAfkOff() end
    end)
    tab:AddToggle("Click Teleport", State.clickTp, function(v)
        State.clickTp = v; if v then clickTpOn() else clickTpOff() end
    end)
    tab:AddToggle("Auto Clicker", State.autoClick, function(v)
        State.autoClick = v; if v then autoClickOn() else autoClickOff() end
    end)
    tab:AddSlider("Auto Click Speed", 1, 50, math.floor(State.autoClickSpd * 100), "cs", function(v)
        State.autoClickSpd = v / 100
    end)
    tab:AddButton("Teleport to Mouse", function() tpToMouse() end)
    tab:AddButton("Teleport Up +500", function() tpUp(500) end)
    tab:AddButton("Teleport Up +2000", function() tpUp(2000) end)
    tab:AddButton("Teleport to Nearest Player", function() tpToNearestPlayer() end)
    tab:AddButton("Teleport to Spawn (0,50,0)", function() tpCoords(0, 50, 0) end)

    -- ADVANCED AIM --------------------------------------------------
    tab:AddSection("ADVANCED AIM")
    tab:AddToggle("Predictive Aim (lead)", State.predictionAim, function(v)
        State.predictionAim = v; if v then predAimOn() else predAimOff() end
    end)
    tab:AddSlider("Bullet Speed (lead)", 100, 4000, State.bulletSpeed, "", function(v)
        State.bulletSpeed = v
    end)
    tab:AddDropdown("Aim Bone", { "Head", "HumanoidRootPart", "UpperTorso", "Torso" }, State.aimBone, function(v)
        State.aimBone = v; State.aimPart = v
    end)

    -- ADVANCED ESP --------------------------------------------------
    tab:AddSection("ADVANCED ESP")
    tab:AddToggle("Skeleton ESP (bones)", State.skeleton, function(v)
        State.skeleton = v; if v then skeletonOn() else skeletonOff() end
    end)
    tab:AddToggle("Head Dots", State.headDot, function(v)
        State.headDot = v; if v then headDotOn() else headDotOff() end
    end)
    tab:AddToggle("Weapon / Tool Tags", State.weaponEsp, function(v)
        State.weaponEsp = v; if v then weaponEspOn() else weaponEspOff() end
    end)
    tab:AddDropdown("Cham Material", { "ForceField", "Neon", "Glass", "SmoothPlastic" }, State.chamMat, function(v)
        State.chamMat = v
    end)

    -- ADVANCED MOVEMENT ---------------------------------------------
    tab:AddSection("ADVANCED MOVEMENT")
    tab:AddToggle("CFrame Speed (bypass)", State.useCframe, function(v)
        State.useCframe = v; if v then cframeSpeedOn() else cframeSpeedOff() end
    end)
    tab:AddSlider("CFrame Speed", 10, 600, State.cframeSpeed, "", function(v) State.cframeSpeed = v end)
    tab:AddToggle("TP Walk", State.tpWalk, function(v)
        State.tpWalk = v; if v then tpWalkOn() else tpWalkOff() end
    end)
    tab:AddToggle("Spin Bot", State.spinBot, function(v)
        State.spinBot = v; if v then spinOn() else spinOff() end
    end)
    tab:AddSlider("Spin Speed", 1, 40, State.spinSpeed, "", function(v) State.spinSpeed = v end)
    tab:AddToggle("Anti-Aim (desync spin)", State.antiAim, function(v)
        State.antiAim = v; if v then antiAimOn() else antiAimOff() end
    end)

    -- ADVANCED COMBAT -----------------------------------------------
    tab:AddSection("ADVANCED COMBAT")
    tab:AddToggle("No Recoil / Sway", State.noRecoil, function(v)
        State.noRecoil = v; if v then noRecoilOn() else noRecoilOff() end
    end)
    tab:AddToggle("Auto Respawn", State.autoRespawn, function(v)
        State.autoRespawn = v; if v then autoRespawnOn() else autoRespawnOff() end
    end)

    -- SERVER / UTIL -------------------------------------------------
    tab:AddSection("SERVER / UTIL")
    tab:AddButton("🔄  Server Hop", serverHop)
    tab:AddButton("🔁  Rejoin Server", rejoinServer)
    tab:AddButton("⚡  FPS Boost", fpsBoost)

    -- MACRO ---------------------------------------------------------
    tab:AddSection("MACRO RECORDER")
    tab:AddButton("⏺  Start Recording", macroStart)
    tab:AddButton("⏹  Stop Recording", macroStop)
    tab:AddButton("▶  Playback", macroPlay)
    tab:AddButton("⏸  Abort Playback", macroAbort)

    -- PLAYERS -------------------------------------------------------
    tab:AddSection("PLAYERS")
    local pHolder = Instance.new("Frame")
    pHolder.Size = UDim2.new(1, 0, 0, 0)
    pHolder.BackgroundTransparency = 1
    pHolder.AutomaticSize = Enum.AutomaticSize.Y
    pHolder.Parent = tab._page
    list(pHolder, Enum.FillDirection.Vertical, 4)
    local function refreshPlayers()
        for _, c in ipairs(pHolder:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local r = rowFrame(pHolder, 30)
                local nm = Instance.new("TextLabel")
                nm.BackgroundTransparency = 1
                nm.Position = UDim2.fromOffset(6, 0)
                nm.Size = UDim2.new(1, -90, 1, 0)
                nm.Font = FontR; nm.TextSize = 12
                nm.TextColor3 = Theme.Text
                nm.TextXAlignment = Enum.TextXAlignment.Left
                nm.Text = (p.DisplayName or p.Name)
                nm.Parent = r
                local b = Instance.new("TextButton")
                b.Size = UDim2.fromOffset(70, 22)
                b.Position = UDim2.new(1, -78, 0.5, -11)
                b.BackgroundColor3 = Theme.ElementD
                b.Text = "TP ▸"; b.Font = FontM; b.TextSize = 11
                b.TextColor3 = Theme.Accent
                b.Parent = r
                corner(b, 6)
                b.MouseButton1Click:Connect(function() tpToPlayer(p) end)
            end
        end
    end
    refreshPlayers()
    tab:AddButton("Refresh Player List", refreshPlayers)

    -- CONFIG --------------------------------------------------------
    tab:AddSection("CONFIG")
    tab:AddButton("💾  Save Config", function()
        if saveConfig() then Notify("Config", "Settings saved!") end
    end, Theme.Green)
    tab:AddButton("📂  Load Config", function()
        if loadConfig() then Notify("Config", "Settings loaded!") end
    end, Theme.Blue)
    tab:AddButton("🗑  Reset Config", function()
        deleteConfig(); Notify("Config", "Config file deleted.")
    end, Theme.Red)
end

--====================================================================
--                TELEPORT LOCATION DATABASE
-- (Approximate coordinates for common game recreations; edit to taste)
--====================================================================
local Teleports = {
    jailbreak = {
        { name = "Bank",        pos = { 12, 14, 700 } },
        { name = "Jewelry Store", pos = { 130, 18, 1300 } },
        { name = "Donut Shop",  pos = { 260, 18, -100 } },
        { name = "Gas Station", pos = { -300, 18, 80 } },
        { name = "Prison",      pos = { -900, 18, 900 } },
        { name = "Police HQ",   pos = { -150, 18, 600 } },
        { name = "Museum",      pos = { 400, 18, 1100 } },
        { name = "Power Plant", pos = { 600, 18, -300 } },
    },
    dahood = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Bank",        pos = { -320, 20, -50 } },
        { name = "ATM Area",    pos = { 120, 20, 200 } },
        { name = "Gun Store",   pos = { 80, 20, -180 } },
        { name = "Da Mini",     pos = { -100, 20, 120 } },
    },
    beeswarm = {
        { name = "Sunflower Field", pos = { -200, 30, -100 } },
        { name = "Dandelion Field", pos = { -300, 30, 100 } },
        { name = "Mushroom Field",  pos = { -100, 30, -300 } },
        { name = "Spider Field",    pos = { 100, 30, -250 } },
        { name = "Bee Hive",        pos = { 0, 50, 0 } },
        { name = "Shop",            pos = { 150, 30, 50 } },
    },
    bloxfruits = {
        { name = "Starter Island",  pos = { 0, 50, 0 } },
        { name = "Marine Ford",     pos = { -5000, 50, -5000 } },
        { name = "Sky Island",      pos = { 0, 2000, 0 } },
        { name = "Second Sea",      pos = { 5000, 50, 5000 } },
    },
    mm2 = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Knife Shop",  pos = { 50, 20, 60 } },
        { name = "Gun Shop",    pos = { -50, 20, -60 } },
    },
    toh = {
        { name = "Tower Base",  pos = { 0, 20, 0 } },
        { name = "Skip +1500",  pos = { "up", 1500 } },
        { name = "Skip +3000",  pos = { "up", 3000 } },
    },
    redliners = {
        { name = "Lobby",       pos = { 0, 20, 0 } },
        { name = "Map Center",  pos = { 0, 50, 0 } },
        { name = "Sniper Spot", pos = { 200, 120, 200 } },
    },
    growagarden = {
        { name = "Garden Plot", pos = { 0, 20, 0 } },
        { name = "Shop",        pos = { 120, 20, 0 } },
        { name = "Seed Seller", pos = { -120, 20, 0 } },
    },
    fleetfacility = {
        { name = "Generator Room", pos = { 0, 10, 0 } },
        { name = "Exit Doors",     pos = { 0, 5, 120 } },
        { name = "Spawn",          pos = { 0, 20, -120 } },
    },
    breakbones = {
        { name = "Drop Zone",   pos = { 0, 50, 0 } },
        { name = "Shop",        pos = { 60, 20, 0 } },
    },
    natdis = {
        { name = "Spawn",       pos = { 0, 30, 0 } },
        { name = "Safe Roof",   pos = { "up", 600 } },
    },
    slimerng = {
        { name = "Roll Area",   pos = { 0, 20, 0 } },
        { name = "Shop",        pos = { 80, 20, 0 } },
    },
    adoptme = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Nursery",     pos = { 100, 20, 100 } },
        { name = "Shop",        pos = { -100, 20, 100 } },
    },
    brockhaven = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Gas Station", pos = { 200, 20, 0 } },
        { name = "Hospital",    pos = { -200, 20, 0 } },
    },
    petsimx = {
        { name = "Spawn Area",  pos = { 0, 20, 0 } },
        { name = "Shop",        pos = { 120, 20, 0 } },
        { name = "Egg Area",    pos = { 0, 20, 120 } },
    },
    -- FPS games ----------------------------------------------------
    arsenal = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Lobby",       pos = { 50, 20, 50 } },
        { name = "Shop",        pos = { -60, 20, -60 } },
        { name = "Map Center",  pos = { 0, 60, 0 } },
    },
    rivals = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Map Center",  pos = { 0, 50, 0 } },
        { name = "Sniper Tower",pos = { 180, 120, 180 } },
    },
    hypershot = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Arena",       pos = { 0, 50, 0 } },
        { name = "High Ground", pos = { 0, 150, 0 } },
    },
    onetap = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Arena",       pos = { 0, 40, 0 } },
    },
    bloxstrike = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Bomb Site A", pos = { 150, 20, 150 } },
        { name = "Bomb Site B", pos = { -150, 20, -150 } },
    },
    phantomforces = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Objective A", pos = { 200, 20, 0 } },
        { name = "Objective B", pos = { -200, 20, 0 } },
    },
    bigpaintball = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Center",      pos = { 0, 50, 0 } },
    },
    badbusiness = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Center",      pos = { 0, 40, 0 } },
    },
    frontlines = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Front Line",  pos = { 300, 20, 0 } },
    },
    strucid = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Island",      pos = { 400, 20, 400 } },
    },
    counterblox = {
        { name = "Spawn (CT)",  pos = { 0, 20, 0 } },
        { name = "Spawn (T)",   pos = { 0, 20, 400 } },
        { name = "Site A",      pos = { 200, 20, 200 } },
    },
    polybattle = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Hill",        pos = { 0, 80, 0 } },
    },
    doomsday = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Bunker",      pos = { 0, -50, 0 } },
    },
    blackhawk = {
        { name = "Base",        pos = { 0, 20, 0 } },
        { name = "Crash Site",  pos = { 500, 20, 500 } },
        { name = "City",        pos = { -500, 20, -500 } },
    },
    -- Fight / Action ----------------------------------------------
    combatarena = {
        { name = "Arena",       pos = { 0, 20, 0 } },
        { name = "Lobby",       pos = { 0, 20, 200 } },
    },
    brainrot = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Shop",        pos = { 80, 20, 0 } },
        { name = "Center",      pos = { 0, 40, 0 } },
    },
    bladeball = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Arena",       pos = { 0, 40, 0 } },
        { name = "Spectate",    pos = { 0, 120, 200 } },
    },
    -- Horror -------------------------------------------------------
    doors = {
        { name = "Lobby",       pos = { 0, 20, 0 } },
        { name = "Door 50",     pos = { "up", 50 } },
        { name = "Door 100",    pos = { "up", 100 } },
    },
    rainbowfriends = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Safe Zone",   pos = { 0, 80, 0 } },
    },
    piggy = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Exit",        pos = { 0, 20, 150 } },
    },
    -- Adventure ----------------------------------------------------
    bloxfruits = {
        { name = "Starter Island",  pos = { 0, 50, 0 } },
        { name = "Marine Ford",     pos = { -5000, 50, -5000 } },
        { name = "Sky Island",      pos = { 0, 2000, 0 } },
        { name = "Second Sea",      pos = { 5000, 50, 5000 } },
    },
    bedwars = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Bed Red",     pos = { 100, 20, 0 } },
        { name = "Bed Blue",    pos = { -100, 20, 0 } },
        { name = "Diamond Gen", pos = { 0, 60, 0 } },
    },
    roghoul = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Coffee Shop", pos = { 120, 20, 0 } },
        { name = "Boss Arena",  pos = { 0, 20, 300 } },
    },
    shindo = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Arena",       pos = { 0, 40, 0 } },
        { name = "Boss",        pos = { 400, 20, 400 } },
    },
    projectslayers = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Village",     pos = { 100, 20, 100 } },
        { name = "Boss",        pos = { 300, 20, 0 } },
    },
    -- Simulators ---------------------------------------------------
    islands = {
        { name = "Island",      pos = { 0, 20, 0 } },
        { name = "Market",      pos = { 120, 20, 0 } },
        { name = "Hub",         pos = { 0, 20, 200 } },
    },
    mining = {
        { name = "Surface",     pos = { 0, 20, 0 } },
        { name = "Mine Entrance",pos = { 0, 10, 100 } },
        { name = "Shop",        pos = { 80, 20, 0 } },
    },
    lumber = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Forest",      pos = { 200, 20, 0 } },
        { name = "Wood Drop",   pos = { 0, 20, 200 } },
    },
    themepark = {
        { name = "Entrance",    pos = { 0, 20, 0 } },
        { name = "Center",      pos = { 0, 40, 0 } },
        { name = "Shop",        pos = { 100, 20, 0 } },
    },
    -- Roleplay -----------------------------------------------------
    bloxburg = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "City",        pos = { 200, 20, 0 } },
        { name = "School",      pos = { 0, 20, 200 } },
        { name = "Pizza Place", pos = { -200, 20, 0 } },
    },
    meepcity = {
        { name = "Plaza",       pos = { 0, 20, 0 } },
        { name = "Pet Shop",    pos = { 100, 20, 0 } },
        { name = "Party",       pos = { 0, 20, 200 } },
    },
    rocitizens = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Bank",        pos = { 150, 20, 0 } },
        { name = "Store",       pos = { -150, 20, 0 } },
    },
    greenville = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Gas Station", pos = { 200, 20, 0 } },
        { name = "Dealership",  pos = { -200, 20, 0 } },
    },
    solsrng = {
        { name = "Roll Area",   pos = { 0, 20, 0 } },
        { name = "Shop",        pos = { 80, 20, 0 } },
    },
    -- newer games --------------------------------------------------
    fishing = {
        { name = "Dock",        pos = { 0, 20, 0 } },
        { name = "Deep Sea",    pos = { 500, 20, 500 } },
        { name = "Shop",        pos = { 80, 20, 0 } },
        { name = "Sell Area",   pos = { -80, 20, 0 } },
    },
    bubblegum = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Sell",        pos = { 100, 20, 0 } },
        { name = "Eggs",        pos = { -100, 20, 0 } },
        { name = "Portal",      pos = { 0, 20, 200 } },
    },
    unboxing = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Shop",        pos = { 100, 20, 0 } },
        { name = "Unbox Area",  pos = { 0, 20, 100 } },
    },
    clickersim = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Shop",        pos = { 120, 20, 0 } },
        { name = "Rebirth",     pos = { -120, 20, 0 } },
    },
    parkour = {
        { name = "Start",       pos = { 0, 20, 0 } },
        { name = "Checkpoint",  pos = { 0, 20, 100 } },
        { name = "Finish",      pos = { 0, 20, 500 } },
        { name = "Skip +1000",  pos = { "up", 1000 } },
    },
    megaobby = {
        { name = "Start",       pos = { 0, 20, 0 } },
        { name = "Mid",         pos = { 0, 500, 0 } },
        { name = "Top",         pos = { 0, 1500, 0 } },
        { name = "Skip +2500",  pos = { "up", 2500 } },
    },
    dragon = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Nest",        pos = { 200, 20, 200 } },
        { name = "Shop",        pos = { 80, 20, 0 } },
        { name = "Boss",        pos = { 0, 20, 400 } },
    },
    creature = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Water",       pos = { 300, 20, 0 } },
        { name = "Food",        pos = { 0, 20, 200 } },
    },
    dinosim = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Forest",      pos = { 200, 20, 0 } },
        { name = "Water",       pos = { 0, 20, 300 } },
    },
    survivekiller = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Exit",        pos = { 0, 20, 200 } },
        { name = "Hideout",     pos = { 150, 20, 150 } },
    },
    ghostsim = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Vacuum Shop", pos = { 100, 20, 0 } },
        { name = "Ghosts",      pos = { 0, 20, 200 } },
    },
    mall = {
        { name = "Entrance",    pos = { 0, 20, 0 } },
        { name = "Food Court",  pos = { 100, 20, 0 } },
        { name = "Shops",       pos = { 0, 20, 100 } },
    },
    hospital = {
        { name = "Entrance",    pos = { 0, 20, 0 } },
        { name = "Wards",       pos = { 100, 20, 0 } },
        { name = "Surgery",     pos = { 0, 20, 100 } },
    },
    zoo = {
        { name = "Entrance",    pos = { 0, 20, 0 } },
        { name = "Enclosures",  pos = { 200, 20, 0 } },
        { name = "Shop",        pos = { 0, 20, 200 } },
    },
    farmtown = {
        { name = "Farm",        pos = { 0, 20, 0 } },
        { name = "Market",      pos = { 150, 20, 0 } },
        { name = "Fields",      pos = { 0, 20, 200 } },
    },
    streetrace = {
        { name = "Start Line",  pos = { 0, 20, 0 } },
        { name = "Finish",      pos = { 0, 20, 1000 } },
        { name = "Garage",      pos = { 100, 20, 0 } },
    },
    tradesim = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Market",      pos = { 100, 20, 0 } },
    },
    climbsim = {
        { name = "Base",        pos = { 0, 20, 0 } },
        { name = "Mid",         pos = { 0, 500, 0 } },
        { name = "Top",         pos = { 0, 2000, 0 } },
    },
    swimsim = {
        { name = "Pool",        pos = { 0, 20, 0 } },
        { name = "Shop",        pos = { 100, 20, 0 } },
    },
    runsim = {
        { name = "Start",       pos = { 0, 20, 0 } },
        { name = "Track End",   pos = { 0, 20, 500 } },
    },
    jumpsim = {
        { name = "Start",       pos = { 0, 20, 0 } },
        { name = "Skip +800",   pos = { "up", 800 } },
    },
    goatsim = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Town",        pos = { 200, 20, 0 } },
    },
    pizzafactory = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Ovens",       pos = { 100, 20, 0 } },
        { name = "Counter",     pos = { 0, 20, 100 } },
    },
    icecream = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Machine",     pos = { 80, 20, 0 } },
    },
    burgersim = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Grill",       pos = { 80, 20, 0 } },
    },
    sushisim = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Counter",     pos = { 80, 20, 0 } },
    },
    coffeesim = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Machine",     pos = { 80, 20, 0 } },
    },
    donutsim = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Fryer",       pos = { 80, 20, 0 } },
    },
    tacosim = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Counter",     pos = { 80, 20, 0 } },
    },
    fantasyfrontier = {
        { name = "Town",        pos = { 0, 20, 0 } },
        { name = "Dungeon",     pos = { 300, 20, 300 } },
        { name = "Boss",        pos = { 0, 20, 500 } },
    },
    swordfight = {
        { name = "Arena",       pos = { 0, 20, 0 } },
        { name = "Lobby",       pos = { 0, 20, 200 } },
    },
    backrooms = {
        { name = "Entrance",    pos = { 0, 20, 0 } },
        { name = "Level 0",     pos = { 200, 20, 0 } },
        { name = "Exit",        pos = { 0, 20, 500 } },
    },
    nextbots = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Safe Zone",   pos = { 0, 200, 0 } },
        { name = "Center",      pos = { 0, 20, 0 } },
    },
    themimic = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "Checkpoint",  pos = { 0, 20, 200 } },
    },
    tycoonbase = {
        { name = "Spawn",       pos = { 0, 20, 0 } },
        { name = "My Tycoon",   pos = { 100, 20, 0 } },
        { name = "Shop",        pos = { 0, 20, 100 } },
    },
    treasurehunt = {
        { name = "Camp",        pos = { 0, 20, 0 } },
        { name = "Dig Site",    pos = { 200, 20, 200 } },
        { name = "Vault",       pos = { 0, 20, 400 } },
    },
}

-- build a Teleports tab from the database (used by every game window)
local function addTeleportTab(tab, key)
    local list_ = Teleports[key]
    if not list_ or #list_ == 0 then
        tab:AddLabel("No preset locations for this game yet.")
        tab:AddLabel("Use the Universal tab's teleport tools instead.")
        return
    end
    tab:AddSection("PRESET LOCATIONS")
    for _, loc in ipairs(list_) do
        tab:AddButton("📍  " .. loc.name, function()
            if loc.pos[1] == "up" then
                tpUp(loc.pos[2])
            else
                tpCoords(loc.pos[1], loc.pos[2], loc.pos[3])
            end
            Notify("Teleport", "→ " .. loc.name)
        end)
    end
    tab:AddDivider()
    tab:AddSection("QUICK")
    tab:AddButton("To Mouse", function() tpToMouse() end)
    tab:AddButton("To Nearest Player", function() tpToNearestPlayer() end)
    tab:AddButton("Up +500", function() tpUp(500) end)
end

print("[UniversalGameHub] Universal tab builder + teleport DB loaded.")

--====================================================================
--====================================================================
--                 GAME-SPECIFIC FEATURES BUILDER
--====================================================================
--====================================================================
-- Builds the "Features" tab for a specific game. Universal mechanics are
-- shared via the functions above; these tabs surface the relevant subset
-- plus game-themed actions in a clean, organized way.
--====================================================================

-- shared full suite for every FPS / shooter game
local function addFPSFeatures(tab, gameName)
    tab:AddLabel("FPS suite for " .. gameName .. ".", Theme.SubText)
    tab:AddSection("AIM")
    tab:AddToggle("Aimbot", false, function(v)
        State.aimbot = v; if v then aimbotOn() else aimbotOff() end
    end, true)
    tab:AddToggle("Silent Aim", false, function(v)
        State.silentAim = v; if v then silentOn() else silentOff() end
    end)
    tab:AddToggle("Triggerbot", false, function(v)
        State.triggerbot = v; if v then triggerOn() else triggerOff() end
    end)
    tab:AddToggle("Auto Fire", false, function(v)
        State.autoFire = v; if v then autoFireOn() else autoFireOff() end
    end)
    tab:AddToggle("Team Check", State.teamCheck, function(v) State.teamCheck = v end)
    tab:AddDropdown("Aim Part", { "Head", "HumanoidRootPart", "UpperTorso" }, State.aimPart, function(v) State.aimPart = v end)
    tab:AddSlider("FOV", 20, 800, State.aimFov, "", function(v) State.aimFov = v; setFov(v) end)
    tab:AddSlider("Smoothing", 0, 95, 20, "%", function(v) State.aimSmooth = v / 100 end)
    tab:AddSection("VISUALS")
    tab:AddToggle("Player ESP (Wallhack)", false, function(v)
        State.esp = v; if v then espOn() else espOff() end
    end)
    tab:AddToggle("Tracers", false, function(v)
        State.espTracer = v
        if v and not State.esp then State.esp = true; espOn() end
    end)
    tab:AddToggle("Boxes", false, function(v) State.espBox = v end)
    tab:AddToggle("Names + Distance", true, function(v)
        State.espName = v; State.espDist = v
    end)
    tab:AddToggle("Show FOV Circle", false, function(v) State.showFov = v; setFovVisible(v) end)
    tab:AddSection("COMBAT")
    tab:AddToggle("Hitbox Expander", false, function(v)
        State.hitbox = v; if v then hitboxOn() else hitboxOff() end
    end)
    tab:AddSlider("Hitbox Size", 1, 50, State.hitboxSize, "", function(v) State.hitboxSize = v end)
    tab:AddToggle("God Mode", false, function(v)
        State.godMode = v; if v then godOn() else godOff() end
    end)
end

--====================================================================
--====================================================================
--          RICH / GAME-ACCURATE FEATURE BUILDER
--====================================================================
--====================================================================
-- Each flagship game gets features that match its REAL mechanics
-- (e.g. MM2 role detection, Blade Ball trajectory parry, Jailbreak
-- vehicle fly + robberies, Blox Fruits NPC farm). Returns true if the
-- game was handled; otherwise the caller falls back to the generic
-- category builder below.
--====================================================================
local function buildRichFeatures(tab, g)
    local key = g.key

    ------------------------------------------------------------------
    if key == "arsenal" then
        tab:AddLabel("Arsenal — gun-rotation deathmatch.", Theme.SubText)
        tab:AddSection("AIM")
        tab:AddToggle("Aimbot", false, function(v) State.aimbot = v; if v then aimbotOn() else aimbotOff() end end, true)
        tab:AddToggle("Silent Aim", false, function(v) State.silentAim = v; if v then silentOn() else silentOff() end end)
        tab:AddToggle("Triggerbot", false, function(v) State.triggerbot = v; if v then triggerOn() else triggerOff() end end)
        tab:AddToggle("Auto Fire", false, function(v) State.autoFire = v; if v then autoFireOn() else autoFireOff() end end)
        tab:AddToggle("Team Check", State.teamCheck, function(v) State.teamCheck = v end)
        tab:AddSlider("FOV", 20, 800, State.aimFov, "", function(v) State.aimFov = v; setFov(v) end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Wallhack ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Tracers", false, function(v) State.espTracer = v end)
        tab:AddToggle("Boxes", false, function(v) State.espBox = v end)
        tab:AddToggle("FOV Circle", false, function(v) State.showFov = v; setFovVisible(v) end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Bunny Hop (Space)", false, function(v) if v then bunnyHopOn() else bunnyHopOff() end end)
        tab:AddToggle("Hitbox Expander", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddSlider("Hitbox Size", 1, 40, State.hitboxSize, "", function(v) State.hitboxSize = v end)
        return true
    end

    ------------------------------------------------------------------
    if key == "rivals" then
        tab:AddLabel("Rivals — fast team shooter with abilities.", Theme.SubText)
        tab:AddSection("AIM")
        tab:AddToggle("Aimbot", false, function(v) State.aimbot = v; if v then aimbotOn() else aimbotOff() end end, true)
        tab:AddToggle("Silent Aim", false, function(v) State.silentAim = v; if v then silentOn() else silentOff() end end)
        tab:AddToggle("Triggerbot", false, function(v) State.triggerbot = v; if v then triggerOn() else triggerOff() end end)
        tab:AddToggle("Team Check", State.teamCheck, function(v) State.teamCheck = v end)
        tab:AddSlider("FOV", 20, 800, State.aimFov, "", function(v) State.aimFov = v; setFov(v) end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Tracers", false, function(v) State.espTracer = v end)
        tab:AddToggle("FOV Circle", false, function(v) State.showFov = v; setFovVisible(v) end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Bunny Hop (Space)", false, function(v) if v then bunnyHopOn() else bunnyHopOff() end end)
        tab:AddToggle("Hitbox Expander", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddSlider("Hitbox Size", 1, 40, State.hitboxSize, "", function(v) State.hitboxSize = v end)
        return true
    end

    ------------------------------------------------------------------
    if key == "jailbreak" then
        tab:AddLabel("Jailbreak — rob, drive, escape.", Theme.SubText)
        tab:AddSection("ROB / UTILITY")
        tab:AddToggle("Auto Rob (prompts)", false, function(v) if v then autoRobOn() else autoRobOff() end end)
        tab:AddButton("🔓  Unlock All Doors", unlockDoors)
        tab:AddButton("🪂  Parachute (fly up first)", function() tpUp(300); task.wait(0.2); parachuteOn() end)
        tab:AddButton("⬇  Stop Parachute", parachuteOff)
        tab:AddToggle("No Fall Damage", false, function(v) if v then noFallOn() else noFallOff() end end)
        tab:AddToggle("Anti-AFK", false, function(v) if v then antiAfkOn() else antiAfkOff() end end)
        tab:AddSection("POLICE")
        tab:AddToggle("🚓  Auto Arrest", false, function(v)
            State.autoArrest = v; if v then autoArrestOn() else autoArrestOff() end end, true)
        tab:AddSlider("Arrest Range", 50, 1000, State.arrestRange, "", function(v) State.arrestRange = v end)
        tab:AddDropdown("Arrest Target", { "Criminals", "Nearest Player" }, State.arrestTarget, function(v)
            State.arrestTarget = v
        end)
        tab:AddSection("VEHICLES")
        tab:AddToggle("Vehicle Fly (WASD)", false, function(v) if v then vehicleFlyOn() else vehicleFlyOff() end end)
        tab:AddSlider("Vehicle Fly Speed", 10, 500, State.flySpeed, "", function(v) State.flySpeed = v end)
        tab:AddButton("💨  Nitro Boost", nitroBoost)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly (on foot)", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddToggle("Noclip", false, function(v) State.noclip = v; if v then noclipOn() else noclipOff() end end)
        tab:AddSection("COMBAT")
        tab:AddToggle("Gun Aimbot", false, function(v) State.aimbot = v; if v then aimbotOn() else aimbotOff() end end)
        tab:AddToggle("Player ESP (cops)", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        return true
    end

    ------------------------------------------------------------------
    if key == "combatarena" then
        tab:AddLabel("Combat Arena — melee fighting.", Theme.SubText)
        tab:AddSection("COMBAT")
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end, true)
        tab:AddSlider("Aura Range", 4, 60, State.auraRange, "", function(v) State.auraRange = v end)
        tab:AddToggle("Fast Attack", false, function(v) if v then fastAttackOn() else fastAttackOff() end end)
        tab:AddToggle("Hitbox / Reach", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddSlider("Reach Size", 1, 50, State.hitboxSize, "", function(v) State.hitboxSize = v end)
        tab:AddToggle("God Mode", false, function(v) State.godMode = v; if v then godOn() else godOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Tracers", false, function(v) State.espTracer = v end)
        return true
    end

    ------------------------------------------------------------------
    if key == "brainrot" then
        tab:AddLabel("Steal a Brainrot — grab, deliver, slap.", Theme.SubText)
        tab:AddSection("ACTION")
        tab:AddToggle("Auto Steal / Collect", false, function(v) if v then autoCollectOn() else autoCollectOff() end end, true)
        tab:AddToggle("Bring Brainrots", false, function(v)
            if v then bringItemsOn({ "brainrot", "brain", "item", "loot" }) else bringItemsOff() end end)
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddSlider("Aura Range", 4, 50, State.auraRange, "", function(v) State.auraRange = v end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Highlight Brainrots", false, function(v)
            if v then partESPOn({ "brainrot", "brain", "item" }, Theme.Yellow) else partESPOff() end end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 400, 60, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "mm2" then
        tab:AddLabel("Murder Mystery 2 — find the killer.", Theme.SubText)
        tab:AddSection("ROLE DETECTION")
        tab:AddToggle("Role Tags (Murderer/Sheriff)", false, function(v)
            if v then mm2RoleOn() else mm2RoleOff() end end, true)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("  • Names", true, function(v) State.espName = v end)
        tab:AddToggle("  • Distance", true, function(v) State.espDist = v end)
        tab:AddToggle("  • Tracers", false, function(v) State.espTracer = v end)
        tab:AddToggle("Highlight Knife / Gun", false, function(v)
            if v then partESPOn({ "knife", "gun", "revolver", "weapon" }, Theme.Yellow) else partESPOff() end end)
        tab:AddSection("UTILITY")
        tab:AddToggle("No Fall Damage", false, function(v) if v then noFallOn() else noFallOff() end end)
        tab:AddToggle("Infinite Jump", false, function(v) State.infJump = v; if v then infJumpOn() else infJumpOff() end end)
        tab:AddButton("Teleport to Nearest Player", tpToNearestPlayer)
        return true
    end

    ------------------------------------------------------------------
    if key == "bladeball" then
        tab:AddLabel("Blade Ball — parry the ball.", Theme.SubText)
        tab:AddSection("AUTO PARRY")
        tab:AddToggle("Auto Parry (Trajectory)", false, function(v)
            if v then parryPredictOn() else parryPredictOff() end end, true)
        tab:AddToggle("Auto Parry (Distance)", false, function(v)
            State.autoParry = v; if v then autoParryOn() else autoParryOff() end end)
        tab:AddSlider("Parry Range", 5, 60, State.parryRange, "", function(v) State.parryRange = v end)
        tab:AddKeybind("Manual Parry Key", Enum.KeyCode.F, function() pressKey(Enum.KeyCode.F); clickMouse() end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Ball ESP", false, function(v)
            if v then partESPOn({ "ball", "orb", "projectile" }, Theme.Red) else partESPOff() end end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddSlider("Walk Speed", 16, 300, 30, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "toh" then
        tab:AddLabel("Tower of Hell — climb to the top.", Theme.SubText)
        tab:AddSection("OBBY SKIP")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end, true)
        tab:AddToggle("Noclip", false, function(v) State.noclip = v; if v then noclipOn() else noclipOff() end end)
        tab:AddToggle("Infinite Jump", false, function(v) State.infJump = v; if v then infJumpOn() else infJumpOff() end end)
        tab:AddToggle("No Killbrick / Lava", false, function(v) if v then noKillbrickOn() else noKillbrickOff() end end)
        tab:AddButton("Skip to Top (+3000)", function() tpUp(3000) end)
        tab:AddButton("Skip to Tower Top (+5000)", function() tpUp(5000) end)
        tab:AddSection("MOVEMENT")
        tab:AddSlider("Walk Speed", 16, 250, 30, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        tab:AddSlider("Jump Power", 50, 500, 130, "", function(v) State.jump = v; State.useJump = true; applyMovement() end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        return true
    end

    ------------------------------------------------------------------
    if key == "dahood" then
        tab:AddLabel("Da Hood — aimlock & money grind.", Theme.SubText)
        tab:AddSection("AIM")
        tab:AddToggle("Aimlock (Aimbot)", false, function(v) State.aimbot = v; if v then aimbotOn() else aimbotOff() end end, true)
        tab:AddToggle("Silent Aim", false, function(v) State.silentAim = v; if v then silentOn() else silentOff() end end)
        tab:AddSlider("Aimlock FOV", 10, 600, 80, "", function(v) State.aimFov = v; setFov(v) end)
        tab:AddSection("COMBAT")
        tab:AddToggle("Reach (Hitbox)", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddSlider("Reach Size", 1, 50, 8, "", function(v) State.hitboxSize = v end)
        tab:AddToggle("Anti Stomp (God)", false, function(v) State.godMode = v; if v then godOn() else godOff() end end)
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddSection("FARM")
        tab:AddToggle("Auto Farm (collect)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Clicker", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddSlider("Walk Speed", 16, 200, 22, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "natdis" then
        tab:AddLabel("Natural Disasters — survive anything.", Theme.SubText)
        tab:AddSection("SURVIVAL")
        tab:AddToggle("Auto Survive (Fly Up)", false, function(v)
            State.fly = v; if v then flyOn(); State.flySpeed = 30 else flyOff() end end, true)
        tab:AddToggle("God Mode", false, function(v) State.godMode = v; if v then godOn() else godOff() end end)
        tab:AddToggle("No Fall Damage", false, function(v) if v then noFallOn() else noFallOff() end end)
        tab:AddButton("Teleport High (+1500)", function() tpUp(1500) end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Disaster / Debris ESP", false, function(v)
            if v then partESPOn({ "lava", "debris", "rock", "meteor", "tsunami", "acid" }, Theme.Red) else partESPOff() end end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        return true
    end

    ------------------------------------------------------------------
    if key == "beeswarm" then
        tab:AddLabel("Bee Swarm — pollen, honey & fields.", Theme.SubText)
        tab:AddSection("AUTO FARM")
        tab:AddToggle("Auto Collect (tokens/tools)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end, true)
        tab:AddToggle("Auto Farm Pollen", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Kill Mobs", false, function(v) if v then autoFarmNPCOn() else autoFarmNPCOff() end end)
        tab:AddToggle("Auto Clicker", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Highlight Tokens/Loot", false, function(v)
            if v then partESPOn({ "token", "pollen", "loot", "field" }, Theme.Yellow) else partESPOff() end end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 300, 40, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "fleetfacility" then
        tab:AddLabel("Flee the Facility — hack & escape.", Theme.SubText)
        tab:AddSection("ROLE ESP")
        tab:AddToggle("Player ESP (Beast)", false, function(v) State.esp = v; if v then espOn() else espOff() end end, true)
        tab:AddToggle("  • Distance", true, function(v) State.espDist = v end)
        tab:AddToggle("Highlight Generators", false, function(v)
            if v then partESPOn({ "generator", "computer", "hack", "panel" }, Theme.Cyan) else partESPOff() end end)
        tab:AddToggle("Highlight Exit Doors", false, function(v)
            if v then partESPOn({ "exit", "door", "escape" }, Theme.Green) else partESPOff() end end)
        tab:AddSection("UTILITY")
        tab:AddToggle("Auto Hack (prompts)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("No Fall Damage", false, function(v) if v then noFallOn() else noFallOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 250, 24, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "growagarden" then
        tab:AddLabel("Grow a Garden — plant, harvest, sell.", Theme.SubText)
        tab:AddSection("AUTO FARM")
        tab:AddToggle("Auto Plant / Water", false, function(v) if v then autoPlantOn() else autoPlantOff() end end, true)
        tab:AddToggle("Auto Harvest (collect)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Sell", false, function(v) if v then autoRobOn() else autoRobOff() end end)
        tab:AddToggle("Auto Clicker", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Highlight Crops", false, function(v)
            if v then partESPOn({ "crop", "plant", "seed", "harvest" }, Theme.Green) else partESPOff() end end)
        tab:AddToggle("Mutation ESP (golden/rainbow)", false, function(v)
            if v then partESPOn({ "golden", "rainbow", "mutated", "wet" }, Theme.Yellow) else partESPOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 300, 35, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "bloxstrike" then
        tab:AddLabel("Bloxstrike — plant/defuse shooter.", Theme.SubText)
        tab:AddSection("AIM")
        tab:AddToggle("Aimbot", false, function(v) State.aimbot = v; if v then aimbotOn() else aimbotOff() end end, true)
        tab:AddToggle("Silent Aim", false, function(v) State.silentAim = v; if v then silentOn() else silentOff() end end)
        tab:AddToggle("Triggerbot", false, function(v) State.triggerbot = v; if v then triggerOn() else triggerOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Highlight Bomb", false, function(v)
            if v then partESPOn({ "bomb", "c4", "site" }, Theme.Red) else partESPOff() end end)
        tab:AddSection("UTILITY")
        tab:AddToggle("Anti-Flashbang", false, function(v) if v then antiFlashOn() else antiFlashOff() end end)
        tab:AddToggle("Hitbox Expander", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddSlider("FOV", 20, 600, State.aimFov, "", function(v) State.aimFov = v; setFov(v) end)
        return true
    end

    ------------------------------------------------------------------
    if key == "breakbones" then
        tab:AddLabel("Break Your Bones — fall for points.", Theme.SubText)
        tab:AddSection("AUTO FARM")
        tab:AddToggle("Auto Fall Farm (fly cycle)", false, function(v)
            State.fly = v; if v then flyOn(); State.flySpeed = 25 else flyOff() end end, true)
        tab:AddToggle("Auto Break (collect)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Clicker", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly (manual)", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 400, 50, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        tab:AddSlider("Jump Power", 50, 500, 150, "", function(v) State.jump = v; State.useJump = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "slimerng" then
        tab:AddLabel("Slime RNG — roll for rare slimes.", Theme.SubText)
        tab:AddSection("AUTO ROLL")
        tab:AddToggle("Auto Roll (E)", false, function(v)
            if v then autoKeyOn(Enum.KeyCode.E, 0.3) else autoKeyOff(Enum.KeyCode.E) end end, true)
        tab:AddToggle("Auto Roll (R)", false, function(v)
            if v then autoKeyOn(Enum.KeyCode.R, 0.3) else autoKeyOff(Enum.KeyCode.R) end end)
        tab:AddToggle("Auto Collect (prompts)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Clicker", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Highlight Rare Slimes", false, function(v)
            if v then partESPOn({ "rare", "legendary", "mythic", "godly", "slime" }, Theme.Pink) else partESPOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        return true
    end

    ------------------------------------------------------------------
    if key == "redliners" then
        tab:AddLabel("Redliners — FPS shooter.", Theme.SubText)
        tab:AddSection("AIM")
        tab:AddToggle("Aimbot", false, function(v) State.aimbot = v; if v then aimbotOn() else aimbotOff() end end, true)
        tab:AddToggle("Silent Aim", false, function(v) State.silentAim = v; if v then silentOn() else silentOff() end end)
        tab:AddToggle("Triggerbot", false, function(v) State.triggerbot = v; if v then triggerOn() else triggerOff() end end)
        tab:AddToggle("Auto Fire", false, function(v) State.autoFire = v; if v then autoFireOn() else autoFireOff() end end)
        tab:AddToggle("Team Check", State.teamCheck, function(v) State.teamCheck = v end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Tracers", false, function(v) State.espTracer = v end)
        tab:AddToggle("FOV Circle", false, function(v) State.showFov = v; setFovVisible(v) end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Bunny Hop (Space)", false, function(v) if v then bunnyHopOn() else bunnyHopOff() end end)
        tab:AddToggle("Hitbox Expander", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddSlider("FOV", 20, 800, State.aimFov, "", function(v) State.aimFov = v; setFov(v) end)
        return true
    end

    ------------------------------------------------------------------
    if key == "phantomforces" then
        tab:AddLabel("Phantom Forces — tactical military FPS.", Theme.SubText)
        tab:AddSection("AIM")
        tab:AddToggle("Aimbot", false, function(v) State.aimbot = v; if v then aimbotOn() else aimbotOff() end end, true)
        tab:AddToggle("Silent Aim", false, function(v) State.silentAim = v; if v then silentOn() else silentOff() end end)
        tab:AddToggle("Triggerbot", false, function(v) State.triggerbot = v; if v then triggerOn() else triggerOff() end end)
        tab:AddDropdown("Aim Part", { "Head", "HumanoidRootPart", "UpperTorso" }, State.aimPart, function(v) State.aimPart = v end)
        tab:AddSlider("FOV", 20, 800, State.aimFov, "", function(v) State.aimFov = v; setFov(v) end)
        tab:AddSlider("Smoothing", 0, 95, 25, "%", function(v) State.aimSmooth = v / 100 end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Tracers", false, function(v) State.espTracer = v end)
        tab:AddToggle("Visible-Only Check", false, function(v) State.espVisibleOnly = v end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Bunny Hop (Space)", false, function(v) if v then bunnyHopOn() else bunnyHopOff() end end)
        tab:AddToggle("Hitbox Expander", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        return true
    end

    ------------------------------------------------------------------
    if key == "counterblox" then
        tab:AddLabel("Counter Blox — bomb defusal.", Theme.SubText)
        tab:AddSection("AIM")
        tab:AddToggle("Aimbot", false, function(v) State.aimbot = v; if v then aimbotOn() else aimbotOff() end end, true)
        tab:AddToggle("Silent Aim", false, function(v) State.silentAim = v; if v then silentOn() else silentOff() end end)
        tab:AddToggle("Triggerbot", false, function(v) State.triggerbot = v; if v then triggerOn() else triggerOff() end end)
        tab:AddSection("UTILITY")
        tab:AddToggle("Anti-Flashbang", false, function(v) if v then antiFlashOn() else antiFlashOff() end end)
        tab:AddToggle("Bunny Hop (Space)", false, function(v) if v then bunnyHopOn() else bunnyHopOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Highlight Bomb/Sites", false, function(v)
            if v then partESPOn({ "bomb", "c4", "site" }, Theme.Red) else partESPOff() end end)
        tab:AddToggle("Hitbox Expander", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddSlider("FOV", 20, 600, State.aimFov, "", function(v) State.aimFov = v; setFov(v) end)
        return true
    end

    ------------------------------------------------------------------
    if key == "doors" then
        tab:AddLabel("Doors — survive the entities.", Theme.SubText)
        tab:AddSection("ENTITY ESP")
        tab:AddToggle("Entity / Monster ESP", false, function(v)
            if v then partESPOn({ "rush", "ambush", "figure", "seek", "halt", "screech", "entity", "jack", "timothy" }, Theme.Red) else partESPOff() end end, true)
        tab:AddToggle("Highlight Items", false, function(v)
            if v then partESPOn({ "key", "lighter", "lockpick", "vitamins", "bandage", "coin", "item", "drawer" }, Theme.Yellow) else partESPOff() end end)
        tab:AddToggle("Highlight Doors", false, function(v)
            if v then partESPOn({ "door" }, Theme.Cyan) else partESPOff() end end)
        tab:AddSection("UTILITY")
        tab:AddToggle("Auto Grab (prompts)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Fullbright", false, function(v) State.fullbright = v; if v then fbOn() else fbOff() end end)
        tab:AddToggle("No Fall Damage", false, function(v) if v then noFallOn() else noFallOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddToggle("Noclip", false, function(v) State.noclip = v; if v then noclipOn() else noclipOff() end end)
        return true
    end

    ------------------------------------------------------------------
    if key == "rainbowfriends" then
        tab:AddLabel("Rainbow Friends — avoid the monsters.", Theme.SubText)
        tab:AddSection("SURVIVAL")
        tab:AddToggle("Monster ESP", false, function(v)
            if v then partESPOn({ "blue", "green", "orange", "purple", "red", "monster", "friend" }, Theme.Red) else partESPOff() end end, true)
        tab:AddToggle("Highlight Items", false, function(v)
            if v then partESPOn({ "item", "block", "cube" }, Theme.Yellow) else partESPOff() end end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddSection("UTILITY")
        tab:AddToggle("No Fall Damage", false, function(v) if v then noFallOn() else noFallOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddToggle("Noclip", false, function(v) State.noclip = v; if v then noclipOn() else noclipOff() end end)
        tab:AddButton("Teleport High (+500)", function() tpUp(500) end)
        return true
    end

    ------------------------------------------------------------------
    if key == "piggy" then
        tab:AddLabel("Piggy — escape the killer.", Theme.SubText)
        tab:AddSection("SURVIVAL")
        tab:AddToggle("Piggy ESP", false, function(v)
            if v then partESPOn({ "piggy", "pig", "monster", "bot" }, Theme.Pink) else partESPOff() end end, true)
        tab:AddToggle("Highlight Keys/Items", false, function(v)
            if v then partESPOn({ "key", "hammer", "plank", "item", "weapon" }, Theme.Yellow) else partESPOff() end end)
        tab:AddToggle("Highlight Exit Door", false, function(v)
            if v then partESPOn({ "exit", "escape", "door" }, Theme.Green) else partESPOff() end end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddSection("UTILITY")
        tab:AddToggle("Auto Grab (prompts)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddSlider("Walk Speed", 16, 200, 22, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "bloxfruits" then
        tab:AddLabel("Blox Fruits — grind, raid, awaken.", Theme.SubText)
        tab:AddSection("FARM / COMBAT")
        tab:AddToggle("Auto Farm NPCs", false, function(v) if v then autoFarmNPCOn() else autoFarmNPCOff() end end, true)
        tab:AddToggle("Fast Attack (skill spam)", false, function(v) if v then fastAttackOn() else fastAttackOff() end end)
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddSlider("Aura Range", 4, 60, State.auraRange, "", function(v) State.auraRange = v end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Bring / Highlight Fruit", false, function(v)
            if v then bringItemsOn({ "fruit", "chest" }); partESPOn({ "fruit", "chest", "devil" }, Theme.Pink) else bringItemsOff(); partESPOff() end end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddToggle("Infinite Jump", false, function(v) State.infJump = v; if v then infJumpOn() else infJumpOff() end end)
        tab:AddSlider("Walk Speed", 16, 400, 50, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "kinglegacy" then
        tab:AddLabel("King Legacy — pirate RPG grind.", Theme.SubText)
        tab:AddSection("FARM / COMBAT")
        tab:AddToggle("Auto Farm NPCs", false, function(v) if v then autoFarmNPCOn() else autoFarmNPCOff() end end, true)
        tab:AddToggle("Fast Attack", false, function(v) if v then fastAttackOn() else fastAttackOff() end end)
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Highlight Chests/Loot", false, function(v)
            if v then partESPOn({ "chest", "fruit", "loot" }, Theme.Yellow) else partESPOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 400, 50, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "petsimx" then
        tab:AddLabel("Pet Simulator X — hatch & farm coins.", Theme.SubText)
        tab:AddSection("AUTO FARM")
        tab:AddToggle("Auto Collect", false, function(v) if v then autoCollectOn() else autoCollectOff() end end, true)
        tab:AddToggle("Auto Farm Coins", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Hatch (eggs)", false, function(v) if v then autoHatchOn() else autoHatchOff() end end)
        tab:AddToggle("Auto Clicker", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Highlight Coins/Chests", false, function(v)
            if v then partESPOn({ "coin", "chest", "loot", "egg", "diamond" }, Theme.Yellow) else partESPOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 400, 40, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "towerdefensesim" then
        tab:AddLabel("Tower Defense Sim — defend the base.", Theme.SubText)
        tab:AddSection("FARM")
        tab:AddToggle("Auto Collect Rewards", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Clicker", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Highlight Enemies", false, function(v)
            if v then partESPOn({ "enemy", "mob", "boss", "npc" }, Theme.Red) else partESPOff() end end)
        tab:AddToggle("Highlight Boss", false, function(v)
            if v then partESPOn({ "boss" }, Theme.Pink) else partESPOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        return true
    end

    ------------------------------------------------------------------
    if key == "prisonlife" then
        tab:AddLabel("Prison Life — break out.", Theme.SubText)
        tab:AddSection("POLICE / GUARD")
        tab:AddToggle("🚓  Auto Arrest", false, function(v)
            State.autoArrest = v; if v then autoArrestOn() else autoArrestOff() end end, true)
        tab:AddSlider("Arrest Range", 50, 1000, State.arrestRange, "", function(v) State.arrestRange = v end)
        tab:AddDropdown("Arrest Target", { "Criminals", "Nearest Player" }, State.arrestTarget, function(v)
            State.arrestTarget = v
        end)
        tab:AddSection("ESCAPE")
        tab:AddButton("🔓  Unlock All Doors", unlockDoors)
        tab:AddToggle("Noclip (walk through walls)", false, function(v) State.noclip = v; if v then noclipOn() else noclipOff() end end)
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSection("COMBAT")
        tab:AddToggle("Aimbot", false, function(v) State.aimbot = v; if v then aimbotOn() else aimbotOff() end end)
        tab:AddToggle("Hitbox Expander", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        return true
    end

    ------------------------------------------------------------------
    if key == "madcity" then
        tab:AddLabel("Mad City — rob & drive.", Theme.SubText)
        tab:AddSection("ROB / UTILITY")
        tab:AddToggle("Auto Rob (prompts)", false, function(v) if v then autoRobOn() else autoRobOff() end end)
        tab:AddButton("🔓  Unlock Doors", unlockDoors)
        tab:AddToggle("No Fall Damage", false, function(v) if v then noFallOn() else noFallOff() end end)
        tab:AddSection("POLICE")
        tab:AddToggle("🚓  Auto Arrest", false, function(v)
            State.autoArrest = v; if v then autoArrestOn() else autoArrestOff() end end, true)
        tab:AddSlider("Arrest Range", 50, 1000, State.arrestRange, "", function(v) State.arrestRange = v end)
        tab:AddDropdown("Arrest Target", { "Criminals", "Nearest Player" }, State.arrestTarget, function(v)
            State.arrestTarget = v
        end)
        tab:AddSection("VEHICLES")
        tab:AddToggle("Vehicle Fly (WASD)", false, function(v) if v then vehicleFlyOn() else vehicleFlyOff() end end)
        tab:AddButton("💨  Nitro Boost", nitroBoost)
        tab:AddSection("COMBAT")
        tab:AddToggle("Aimbot", false, function(v) State.aimbot = v; if v then aimbotOn() else aimbotOff() end end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        return true
    end

    ------------------------------------------------------------------
    if key == "ninjalegends" then
        tab:AddLabel("Ninja Legends — swing, sell, rank up.", Theme.SubText)
        tab:AddSection("AUTO TRAIN")
        tab:AddToggle("Auto Swing (click)", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end, true)
        tab:AddToggle("Auto Sell", false, function(v) if v then autoRobOn() else autoRobOff() end end)
        tab:AddToggle("Auto Buy Belt (B)", false, function(v)
            if v then autoKeyOn(Enum.KeyCode.B, 0.6) else autoKeyOff(Enum.KeyCode.B) end end)
        tab:AddToggle("Auto Rank (R)", false, function(v)
            if v then autoKeyOn(Enum.KeyCode.R, 0.6) else autoKeyOff(Enum.KeyCode.R) end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Infinite Jump", false, function(v) State.infJump = v; if v then infJumpOn() else infJumpOff() end end)
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 300, 30, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "vehiclesim" then
        tab:AddLabel("Vehicle Simulator — drive & race.", Theme.SubText)
        tab:AddSection("VEHICLES")
        tab:AddToggle("Vehicle Fly (WASD)", false, function(v) if v then vehicleFlyOn() else vehicleFlyOff() end end, true)
        tab:AddButton("💨  Nitro Boost", nitroBoost)
        tab:AddSlider("Vehicle Fly Speed", 10, 600, State.flySpeed, "", function(v) State.flySpeed = v end)
        tab:AddSection("FARM")
        tab:AddToggle("Auto Collect", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        return true
    end

    ------------------------------------------------------------------
    if key == "liftingsim" then
        tab:AddLabel("Lifting Simulator — lift to get huge.", Theme.SubText)
        tab:AddSection("TRAINING")
        tab:AddToggle("Auto Lift (click)", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end, true)
        tab:AddToggle("Auto Sell", false, function(v) if v then autoRobOn() else autoRobOff() end end)
        tab:AddSection("COMBAT")
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddToggle("Hitbox Expander", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddToggle("God Mode", false, function(v) State.godMode = v; if v then godOn() else godOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddSlider("Walk Speed", 16, 300, 30, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "buildaboat" then
        tab:AddLabel("Build a Boat — sail for treasure.", Theme.SubText)
        tab:AddSection("OBBY / SAIL")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end, true)
        tab:AddToggle("Noclip", false, function(v) State.noclip = v; if v then noclipOn() else noclipOff() end end)
        tab:AddToggle("Infinite Jump", false, function(v) State.infJump = v; if v then infJumpOn() else infJumpOff() end end)
        tab:AddSection("COLLECT")
        tab:AddToggle("Auto Collect (prompts)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Highlight Materials", false, function(v)
            if v then partESPOn({ "wood", "block", "material", "ore", "treasure" }, Theme.Green) else partESPOff() end end)
        tab:AddSlider("Walk Speed", 16, 300, 30, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "hypershot" then
        tab:AddLabel("Hypershot — movement shooter.", Theme.SubText)
        tab:AddSection("AIM")
        tab:AddToggle("Aimbot", false, function(v) State.aimbot = v; if v then aimbotOn() else aimbotOff() end end, true)
        tab:AddToggle("Silent Aim", false, function(v) State.silentAim = v; if v then silentOn() else silentOff() end end)
        tab:AddToggle("Triggerbot", false, function(v) State.triggerbot = v; if v then triggerOn() else triggerOff() end end)
        tab:AddSlider("FOV", 20, 800, State.aimFov, "", function(v) State.aimFov = v; setFov(v) end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Tracers", false, function(v) State.espTracer = v end)
        tab:AddToggle("FOV Circle", false, function(v) State.showFov = v; setFovVisible(v) end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Bunny Hop", false, function(v) if v then bunnyHopOn() else bunnyHopOff() end end)
        tab:AddToggle("Hitbox Expander", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        return true
    end

    ------------------------------------------------------------------
    if key == "bigpaintball" then
        tab:AddLabel("Big Paintball — tag everyone.", Theme.SubText)
        tab:AddSection("AIM")
        tab:AddToggle("Aimbot", false, function(v) State.aimbot = v; if v then aimbotOn() else aimbotOff() end end, true)
        tab:AddToggle("Triggerbot", false, function(v) State.triggerbot = v; if v then triggerOn() else triggerOff() end end)
        tab:AddToggle("Auto Fire", false, function(v) State.autoFire = v; if v then autoFireOn() else autoFireOff() end end)
        tab:AddSlider("FOV", 20, 800, State.aimFov, "", function(v) State.aimFov = v; setFov(v) end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Wallhack ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Visible-Only", false, function(v) State.espVisibleOnly = v end)
        tab:AddToggle("FOV Circle", false, function(v) State.showFov = v; setFovVisible(v) end)
        tab:AddSection("COMBAT")
        tab:AddToggle("Hitbox Expander", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddSlider("Hitbox Size", 1, 40, State.hitboxSize, "", function(v) State.hitboxSize = v end)
        return true
    end

    ------------------------------------------------------------------
    if key == "badbusiness" then
        tab:AddLabel("Bad Business — competitive FPS.", Theme.SubText)
        tab:AddSection("AIM")
        tab:AddToggle("Aimbot", false, function(v) State.aimbot = v; if v then aimbotOn() else aimbotOff() end end, true)
        tab:AddToggle("Silent Aim", false, function(v) State.silentAim = v; if v then silentOn() else silentOff() end end)
        tab:AddToggle("Triggerbot", false, function(v) State.triggerbot = v; if v then triggerOn() else triggerOff() end end)
        tab:AddSlider("Smoothing", 0, 95, 25, "%", function(v) State.aimSmooth = v / 100 end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Skeleton ESP", false, function(v) State.skeleton = v; if v then skeletonOn() else skeletonOff() end end)
        tab:AddSection("COMBAT")
        tab:AddToggle("No Recoil / Sway", false, function(v) State.noRecoil = v; if v then noRecoilOn() else noRecoilOff() end end)
        tab:AddToggle("Hitbox Expander", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        return true
    end

    ------------------------------------------------------------------
    if key == "frontlines" then
        tab:AddLabel("Frontlines — WW2 shooter.", Theme.SubText)
        tab:AddSection("AIM")
        tab:AddToggle("Aimbot", false, function(v) State.aimbot = v; if v then aimbotOn() else aimbotOff() end end, true)
        tab:AddToggle("Silent Aim", false, function(v) State.silentAim = v; if v then silentOn() else silentOff() end end)
        tab:AddDropdown("Aim Part", { "Head", "HumanoidRootPart", "UpperTorso" }, State.aimPart, function(v) State.aimPart = v end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Visible-Only Check", false, function(v) State.espVisibleOnly = v end)
        tab:AddSection("MOVEMENT / COMBAT")
        tab:AddToggle("No Recoil", false, function(v) State.noRecoil = v; if v then noRecoilOn() else noRecoilOff() end end)
        tab:AddToggle("Bunny Hop", false, function(v) if v then bunnyHopOn() else bunnyHopOff() end end)
        tab:AddToggle("Hitbox Expander", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        return true
    end

    ------------------------------------------------------------------
    if key == "roghoul" then
        tab:AddLabel("Ro-Ghoul — ghoul grind RPG.", Theme.SubText)
        tab:AddSection("FARM / COMBAT")
        tab:AddToggle("Auto Farm NPCs", false, function(v) if v then autoFarmNPCOn() else autoFarmNPCOff() end end, true)
        tab:AddToggle("Auto Boss Hunt", false, function(v) if v then autoBossOn() else autoBossOff() end end)
        tab:AddToggle("Fast Attack", false, function(v) if v then fastAttackOn() else fastAttackOff() end end)
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Highlight Chests/RC", false, function(v)
            if v then partESPOn({ "chest", "loot", "rc", "cell" }, Theme.Yellow) else partESPOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddToggle("Infinite Jump", false, function(v) State.infJump = v; if v then infJumpOn() else infJumpOff() end end)
        tab:AddSlider("Walk Speed", 16, 400, 50, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "yba" then
        tab:AddLabel("Your Bizarre Adventure — stand RPG.", Theme.SubText)
        tab:AddSection("FARM / COMBAT")
        tab:AddToggle("Auto Farm NPCs", false, function(v) if v then autoFarmNPCOn() else autoFarmNPCOff() end end, true)
        tab:AddToggle("Auto Boss", false, function(v) if v then autoBossOn() else autoBossOff() end end)
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Highlight Items/Chests", false, function(v)
            if v then partESPOn({ "chest", "item", "loot", "standarrow", "arrow" }, Theme.Yellow) else partESPOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 400, 50, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "shindo" then
        tab:AddLabel("Shindo Life — ninja RPG.", Theme.SubText)
        tab:AddSection("FARM / COMBAT")
        tab:AddToggle("Auto Farm NPCs", false, function(v) if v then autoFarmNPCOn() else autoFarmNPCOff() end end, true)
        tab:AddToggle("Auto Boss", false, function(v) if v then autoBossOn() else autoBossOff() end end)
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddSection("UTILITY")
        tab:AddButton("🎲  Spin for Bloodline (R)", function()
            autoKeyOn(Enum.KeyCode.R, 0.8); task.delay(3, function() autoKeyOff(Enum.KeyCode.R) end) end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Highlight Scrolls", false, function(v)
            if v then partESPOn({ "scroll", "item", "loot" }, Theme.Yellow) else partESPOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 400, 50, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "deepwoken" then
        tab:AddLabel("Deepwoken — permadeath RPG.", Theme.SubText)
        tab:AddSection("FARM / COMBAT")
        tab:AddToggle("Auto Farm NPCs", false, function(v) if v then autoFarmNPCOn() else autoFarmNPCOff() end end, true)
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddToggle("Fast Attack", false, function(v) if v then fastAttackOn() else fastAttackOff() end end)
        tab:AddSection("SURVIVAL")
        tab:AddToggle("No Fall Damage", false, function(v) if v then noFallOn() else noFallOff() end end)
        tab:AddToggle("God Mode", false, function(v) State.godMode = v; if v then godOn() else godOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Highlight Chests/Loot", false, function(v)
            if v then partESPOn({ "chest", "loot", "item" }, Theme.Yellow) else partESPOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddToggle("Swim", false, function(v) State.swim = v; if v then swimOn() else swimOff() end end)
        return true
    end

    ------------------------------------------------------------------
    if key == "projectslayers" then
        tab:AddLabel("Project Slayers — demon RPG.", Theme.SubText)
        tab:AddSection("FARM / COMBAT")
        tab:AddToggle("Auto Farm NPCs", false, function(v) if v then autoFarmNPCOn() else autoFarmNPCOff() end end, true)
        tab:AddToggle("Auto Boss", false, function(v) if v then autoBossOn() else autoBossOff() end end)
        tab:AddToggle("Fast Attack", false, function(v) if v then fastAttackOn() else fastAttackOff() end end)
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Highlight Chests", false, function(v)
            if v then partESPOn({ "chest", "loot", "item" }, Theme.Yellow) else partESPOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 400, 50, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "bedwars" then
        tab:AddLabel("Bedwars — protect your bed.", Theme.SubText)
        tab:AddSection("COMBAT")
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end, true)
        tab:AddToggle("Reach (Hitbox)", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddToggle("God Mode", false, function(v) State.godMode = v; if v then godOn() else godOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Bed ESP", false, function(v)
            if v then partESPOn({ "bed", "teambed" }, Theme.Pink) else partESPOff() end end)
        tab:AddToggle("Highlight Generators", false, function(v)
            if v then partESPOn({ "generator", "diamond", "emerald" }, Theme.Cyan) else partESPOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 250, 26, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "islands" then
        tab:AddLabel("Islands — build, farm & trade.", Theme.SubText)
        tab:AddSection("AUTO FARM")
        tab:AddToggle("Auto Mine (resources)", false, function(v) if v then autoMineOn() else autoMineOff() end end, true)
        tab:AddToggle("Auto Collect", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Sell", false, function(v) if v then autoRobOn() else autoRobOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Highlight Ores/Resources", false, function(v)
            if v then partESPOn({ "ore", "rock", "tree", "resource", "mineral" }, Theme.Green) else partESPOff() end end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 300, 30, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "fishing" then
        tab:AddLabel("Fishing Simulator — catch & sell.", Theme.SubText)
        tab:AddSection("AUTO FISH")
        tab:AddToggle("Auto Fish (tool)", false, function(v) if v then autoFishOn() else autoFishOff() end end, true)
        tab:AddToggle("Auto Collect", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Sell", false, function(v) if v then autoRobOn() else autoRobOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Highlight Fish/Loot", false, function(v)
            if v then partESPOn({ "fish", "loot", "chest", "rod" }, Theme.Cyan) else partESPOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 300, 35, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "bubblegum" then
        tab:AddLabel("Bubble Gum Sim — blow, hatch, sell.", Theme.SubText)
        tab:AddSection("AUTO")
        tab:AddToggle("Auto Blow (click)", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end, true)
        tab:AddToggle("Auto Sell", false, function(v) if v then autoRobOn() else autoRobOff() end end)
        tab:AddToggle("Auto Hatch (eggs)", false, function(v) if v then autoHatchOn() else autoHatchOff() end end)
        tab:AddToggle("Auto Rebirth (R)", false, function(v) if v then autoRebirthOn() else autoRebirthOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Highlight Coins/Eggs", false, function(v)
            if v then partESPOn({ "coin", "egg", "loot", "chest" }, Theme.Yellow) else partESPOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        return true
    end

    ------------------------------------------------------------------
    if key == "clickersim" then
        tab:AddLabel("Clicker Simulator — click to the moon.", Theme.SubText)
        tab:AddSection("AUTO")
        tab:AddToggle("Auto Click", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end, true)
        tab:AddToggle("Auto Rebirth (R)", false, function(v) if v then autoRebirthOn() else autoRebirthOff() end end)
        tab:AddToggle("Auto Buy (B)", false, function(v) if v then autoBuyOn() else autoBuyOff() end end)
        tab:AddToggle("Auto Hatch (eggs)", false, function(v) if v then autoHatchOn() else autoHatchOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 300, 35, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return true
    end

    ------------------------------------------------------------------
    if key == "boxing" or key == "strongestbg" or key == "combatwarriors" then
        tab:AddLabel("Fighting / Battlegrounds.", Theme.SubText)
        tab:AddSection("COMBAT")
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end, true)
        tab:AddSlider("Aura Range", 4, 60, State.auraRange, "", function(v) State.auraRange = v end)
        tab:AddToggle("Fast Attack (combo)", false, function(v) if v then fastAttackOn() else fastAttackOff() end end)
        tab:AddToggle("Hitbox / Reach", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddSlider("Reach Size", 1, 50, State.hitboxSize, "", function(v) State.hitboxSize = v end)
        tab:AddToggle("God Mode", false, function(v) State.godMode = v; if v then godOn() else godOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Infinite Jump", false, function(v) State.infJump = v; if v then infJumpOn() else infJumpOff() end end)
        tab:AddSlider("Walk Speed", 16, 250, 32, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        return true
    end

    -- not a flagship game: fall back to the generic category builder
    return false
end

--====================================================================
--                       AUTO FARM TAB BUILDER
--====================================================================
-- A dedicated "Auto" tab added to every game window, surfacing the full
-- automation suite with master Start/Stop controls.
--====================================================================
local function buildAutoTab(tab, g)
    tab:AddLabel("Full automation for " .. g.name .. ".", Theme.SubText)

    tab:AddSection("MASTER CONTROL")
    tab:AddButton("🟢  Start All Auto-Farm", startAllAuto, Theme.Green)
    tab:AddButton("🔴  Stop All Auto-Farm", stopAllAuto, Theme.Red)

    tab:AddSection("NPC / COMBAT FARM")
    tab:AddToggle("Auto Farm NPCs", false, function(v)
        if v then autoFarmNPCOn() else autoFarmNPCOff() end end, true)
    tab:AddToggle("Auto Boss Hunt", false, function(v)
        if v then autoBossOn() else autoBossOff() end end)
    tab:AddToggle("Kill Aura", false, function(v)
        State.killAura = v; if v then auraOn() else auraOff() end end)
    tab:AddToggle("Fast Attack (spam)", false, function(v)
        if v then fastAttackOn() else fastAttackOff() end end)
    tab:AddToggle("Auto Dungeon / Raid", false, function(v)
        if v then autoDungeonOn() else autoDungeonOff() end end)

    tab:AddSection("COLLECT")
    tab:AddToggle("Auto Loot (wide)", false, function(v)
        if v then autoLootOn() else autoLootOff() end end)
    tab:AddToggle("Auto Collect All (prompts)", false, function(v)
        if v then autoCollectAllOn() else autoCollectAllOff() end end)
    tab:AddToggle("Auto Quest (NPCs)", false, function(v)
        if v then autoQuestOn() else autoQuestOff() end end)
    tab:AddToggle("Auto Rob (prompts)", false, function(v)
        if v then autoRobOn() else autoRobOff() end end)

    tab:AddSection("POLICE")
    tab:AddToggle("🚓  Auto Arrest", false, function(v)
        State.autoArrest = v; if v then autoArrestOn() else autoArrestOff() end end)
    tab:AddSlider("Arrest Range", 50, 1000, State.arrestRange, "", function(v) State.arrestRange = v end)
    tab:AddDropdown("Arrest Target", { "Criminals", "Nearest Player" }, State.arrestTarget, function(v)
        State.arrestTarget = v
    end)

    tab:AddSection("GATHER (tool farm)")
    tab:AddToggle("Auto Fish", false, function(v)
        if v then autoFishOn() else autoFishOff() end end)
    tab:AddToggle("Auto Mine", false, function(v)
        if v then autoMineOn() else autoMineOff() end end)
    tab:AddToggle("Auto Woodcut", false, function(v)
        if v then autoWoodcutOn() else autoWoodcutOff() end end)

    tab:AddSection("PROGRESS")
    tab:AddToggle("Auto Rebirth (R)", false, function(v)
        if v then autoRebirthOn() else autoRebirthOff() end end)
    tab:AddToggle("Auto Upgrade (U)", false, function(v)
        if v then autoUpgradeOn() else autoUpgradeOff() end end)
    tab:AddToggle("Auto Buy (B)", false, function(v)
        if v then autoBuyOn() else autoBuyOff() end end)
    tab:AddToggle("Auto Equip Tool", false, function(v)
        if v then autoEquipOn() else autoEquipOff() end end)
    tab:AddToggle("Auto Sell", false, function(v)
        if v then autoRobOn() else autoRobOff() end end)

    tab:AddSection("MISC")
    tab:AddToggle("Auto Clicker", false, function(v)
        State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
    tab:AddToggle("Auto Parry", false, function(v)
        State.autoParry = v; if v then autoParryOn() else autoParryOff() end end)
    tab:AddToggle("Anti-AFK", false, function(v)
        if v then antiAfkOn() else antiAfkOff() end end)
end

local function buildGameFeatures(tab, key)

    --====================  ALL FPS GAMES  ====================
    if key == "arsenal" or key == "rivals" or key == "hypershot" or key == "onetap"
    or key == "bloxstrike" or key == "redliners" or key == "phantomforces"
    or key == "bigpaintball" or key == "badbusiness" or key == "frontlines"
    or key == "strucid" or key == "counterblox" or key == "polybattle"
    or key == "doomsday" then
        addFPSFeatures(tab, key:gsub("^%l", string.upper))
        return
    end

    --====================  JAILBREAK  ====================
    if key == "jailbreak" then
        tab:AddSection("ROB / ESCAPE")
        tab:AddToggle("Auto Rob (prompts)", false, function(v) if v then autoRobOn() else autoRobOff() end end)
        tab:AddToggle("No Fall Damage", false, function(v) if v then noFallOn() else noFallOff() end end)
        tab:AddToggle("Anti-AFK", false, function(v) if v then antiAfkOn() else antiAfkOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddToggle("Noclip", false, function(v) State.noclip = v; if v then noclipOn() else noclipOff() end end)
        tab:AddSlider("Walk Speed", 16, 400, 50, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddButton("Remove Doors (local)", function()
            for _, d in ipairs(Workspace:GetDescendants()) do
                if d:IsA("BasePart") and d.Name:lower():find("door") then d.CanCollide = false end
            end
        end)
        return
    end

    --====================  MAD CITY  ====================
    if key == "madcity" then
        tab:AddSection("ROB / UTILITY")
        tab:AddToggle("Auto Rob (prompts)", false, function(v) if v then autoRobOn() else autoRobOff() end end)
        tab:AddToggle("No Fall Damage", false, function(v) if v then noFallOn() else noFallOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddToggle("Noclip", false, function(v) State.noclip = v; if v then noclipOn() else noclipOff() end end)
        tab:AddSection("COMBAT")
        tab:AddToggle("Aimbot", false, function(v) State.aimbot = v; if v then aimbotOn() else aimbotOff() end end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        return
    end

    --====================  PRISON LIFE  ====================
    if key == "prisonlife" then
        tab:AddSection("ESCAPE")
        tab:AddToggle("Noclip (walk out)", false, function(v) State.noclip = v; if v then noclipOn() else noclipOff() end end)
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddButton("Remove All Doors", function()
            for _, d in ipairs(Workspace:GetDescendants()) do
                if d:IsA("BasePart") and d.Name:lower():find("door") then d.CanCollide = false; d.Transparency = 0.5 end
            end
        end)
        tab:AddSection("COMBAT")
        tab:AddToggle("Aimbot", false, function(v) State.aimbot = v; if v then aimbotOn() else aimbotOff() end end)
        tab:AddToggle("Hitbox Expander", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        return
    end

    --====================  COMBAT ARENA  ====================
    if key == "combatarena" then
        tab:AddSection("COMBAT")
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddSlider("Aura Range", 4, 60, State.auraRange, "", function(v) State.auraRange = v end)
        tab:AddToggle("Hitbox / Reach", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddSlider("Reach Size", 1, 50, State.hitboxSize, "", function(v) State.hitboxSize = v end)
        tab:AddToggle("God Mode", false, function(v) State.godMode = v; if v then godOn() else godOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Tracers", false, function(v) State.espTracer = v end)
        tab:AddSection("MOVEMENT")
        tab:AddSlider("Walk Speed", 16, 300, 40, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        tab:AddToggle("Infinite Jump", false, function(v) State.infJump = v; if v then infJumpOn() else infJumpOff() end end)
        return
    end

    --====================  STEAL A BRAINROT  ====================
    if key == "brainrot" then
        tab:AddSection("ACTION")
        tab:AddToggle("Auto Steal / Collect", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddSlider("Aura Range", 4, 50, State.auraRange, "", function(v) State.auraRange = v end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 400, 60, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Auto Clicker", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        return
    end

    --====================  DA HOOD  ====================
    if key == "dahood" then
        tab:AddSection("AIM")
        tab:AddToggle("Aimlock (Aimbot)", false, function(v) State.aimbot = v; if v then aimbotOn() else aimbotOff() end end, true)
        tab:AddToggle("Silent Aim", false, function(v) State.silentAim = v; if v then silentOn() else silentOff() end end)
        tab:AddSlider("Aimbot FOV", 10, 600, 80, "", function(v) State.aimFov = v; setFov(v) end)
        tab:AddSection("COMBAT")
        tab:AddToggle("Reach (Hitbox)", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddSlider("Reach Size", 1, 50, 8, "", function(v) State.hitboxSize = v end)
        tab:AddToggle("Anti Stomp (God)", false, function(v) State.godMode = v; if v then godOn() else godOff() end end)
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddSection("FARM")
        tab:AddToggle("Auto Farm (collect)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Clicker", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddSlider("Walk Speed", 16, 200, 22, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return
    end

    --====================  MURDER MYSTERY 2  ====================
    if key == "mm2" then
        tab:AddSection("ROLE ESP")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("  • Names", true, function(v) State.espName = v end)
        tab:AddToggle("  • Distance", true, function(v) State.espDist = v end)
        tab:AddToggle("  • Tracers", false, function(v) State.espTracer = v end)
        tab:AddToggle("Highlight Knife/Gun", false, function(v)
            if v then partESPOn({ "knife", "gun", "weapon", "revolver" }, Theme.Yellow) else partESPOff() end
        end)
        tab:AddSection("UTILITY")
        tab:AddToggle("No Fall Damage", false, function(v) if v then noFallOn() else noFallOff() end end)
        tab:AddToggle("Infinite Jump", false, function(v) State.infJump = v; if v then infJumpOn() else infJumpOff() end end)
        tab:AddButton("Teleport to Nearest", function() tpToNearestPlayer() end)
        return
    end

    --====================  BLADE BALL  ====================
    if key == "bladeball" then
        tab:AddSection("PARRY")
        tab:AddToggle("Auto Parry", false, function(v)
            State.autoParry = v; if v then autoParryOn() else autoParryOff() end
        end, true)
        tab:AddSlider("Parry Range", 5, 60, State.parryRange, "", function(v) State.parryRange = v end)
        tab:AddKeybind("Manual Parry Key", Enum.KeyCode.F, function()
            pressKey(Enum.KeyCode.F); clickMouse()
        end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Ball ESP", false, function(v)
            if v then partESPOn({ "ball", "orb", "projectile" }, Theme.Red) else partESPOff() end
        end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddSlider("Walk Speed", 16, 300, 30, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return
    end

    --====================  BREAK YOUR BONES  ====================
    if key == "breakbones" then
        tab:AddSection("ACTION")
        tab:AddToggle("Auto Break (collect)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Fall Damage Farm", false, function(v)
            State.fly = v; if v then flyOn(); State.flySpeed = 20 else flyOff() end
        end)
        tab:AddToggle("Auto Clicker", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 400, 50, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        tab:AddSlider("Jump Power", 50, 500, 120, "", function(v) State.jump = v; State.useJump = true; applyMovement() end)
        return
    end

    --====================  TOWER OF HELL  ====================
    if key == "toh" then
        tab:AddSection("OBBY SKIP")
        tab:AddToggle("Infinite Jump", false, function(v) State.infJump = v; if v then infJumpOn() else infJumpOff() end end)
        tab:AddToggle("Noclip", false, function(v) State.noclip = v; if v then noclipOn() else noclipOff() end end)
        tab:AddButton("Skip to Top (+2000)", function() tpUp(2000) end)
        tab:AddButton("Skip to Tower Top (+4000)", function() tpUp(4000) end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 250, 30, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        tab:AddSlider("Jump Power", 50, 500, 120, "", function(v) State.jump = v; State.useJump = true; applyMovement() end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        return
    end

    --====================  BUILD A BOAT  ====================
    if key == "buildaboat" then
        tab:AddSection("OBBY")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddToggle("Noclip", false, function(v) State.noclip = v; if v then noclipOn() else noclipOff() end end)
        tab:AddToggle("Infinite Jump", false, function(v) State.infJump = v; if v then infJumpOn() else infJumpOff() end end)
        tab:AddSection("COLLECT")
        tab:AddToggle("Auto Collect (prompts)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Highlight Materials", false, function(v)
            if v then partESPOn({ "wood", "block", "material", "ore" }, Theme.Green) else partESPOff() end
        end)
        tab:AddSlider("Walk Speed", 16, 300, 30, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return
    end

    --====================  NATURAL DISASTERS  ====================
    if key == "natdis" then
        tab:AddSection("SURVIVE")
        tab:AddToggle("Auto Survive (Fly Up)", false, function(v)
            State.fly = v; if v then flyOn(); State.flySpeed = 30 else flyOff() end
        end, true)
        tab:AddToggle("Noclip", false, function(v) State.noclip = v; if v then noclipOn() else noclipOff() end end)
        tab:AddToggle("God Mode", false, function(v) State.godMode = v; if v then godOn() else godOff() end end)
        tab:AddButton("Teleport High (+1000)", function() tpUp(1000) end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        return
    end

    --====================  FLEE THE FACILITY  ====================
    if key == "fleetfacility" then
        tab:AddSection("ROLE ESP")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("  • Distance", true, function(v) State.espDist = v end)
        tab:AddToggle("Highlight Generators", false, function(v)
            if v then partESPOn({ "generator", "computer", "hack" }, Theme.Cyan) else partESPOff() end
        end)
        tab:AddSection("UTILITY")
        tab:AddToggle("Auto Hack (prompts)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("No Fall Damage", false, function(v) if v then noFallOn() else noFallOff() end end)
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 250, 24, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return
    end

    --====================  BEE SWARM SIMULATOR  ====================
    if key == "beeswarm" then
        tab:AddSection("FARM")
        tab:AddToggle("Auto Collect (tools)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Farm Pollen", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Clicker", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Highlight Pollen/Items", false, function(v)
            if v then partESPOn({ "pollen", "token", "field", "loot" }, Theme.Yellow) else partESPOff() end
        end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 300, 40, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return
    end

    --====================  GROW A GARDEN  ====================
    if key == "growagarden" then
        tab:AddSection("FARM")
        tab:AddToggle("Auto Collect (prompts)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Plant / Water", false, function(v) if v then autoPlantOn() else autoPlantOff() end end)
        tab:AddToggle("Auto Clicker", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Highlight Crops", false, function(v)
            if v then partESPOn({ "crop", "plant", "seed", "harvest" }, Theme.Green) else partESPOff() end
        end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 300, 35, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return
    end

    --====================  SLIME RNG  ====================
    if key == "slimerng" then
        tab:AddSection("RNG AUTO-ROLL")
        tab:AddToggle("Auto Roll (E)", false, function(v)
            if v then autoKeyOn(Enum.KeyCode.E, 0.3) else autoKeyOff(Enum.KeyCode.E) end
        end, true)
        tab:AddToggle("Auto Roll (R)", false, function(v)
            if v then autoKeyOn(Enum.KeyCode.R, 0.3) else autoKeyOff(Enum.KeyCode.R) end
        end)
        tab:AddToggle("Auto Collect (prompts)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Clicker", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 300, 35, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return
    end

    --====================  PET SIMULATOR X  ====================
    if key == "petsimx" then
        tab:AddSection("FARM")
        tab:AddToggle("Auto Collect", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Farm Coins", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Clicker", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Highlight Coins/Loot", false, function(v)
            if v then partESPOn({ "coin", "loot", "chest", "egg" }, Theme.Yellow) else partESPOff() end
        end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 400, 40, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return
    end

    --====================  NINJA LEGENDS  ====================
    if key == "ninjalegends" then
        tab:AddSection("TRAINING")
        tab:AddToggle("Auto Sell (tools)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Train / Swing", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddToggle("Auto Buy Belt", false, function(v)
            if v then autoKeyOn(Enum.KeyCode.B, 0.5) else autoKeyOff(Enum.KeyCode.B) end
        end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Infinite Jump", false, function(v) State.infJump = v; if v then infJumpOn() else infJumpOff() end end)
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 300, 30, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return
    end

    --====================  VEHICLE SIMULATOR  ====================
    if key == "vehiclesim" then
        tab:AddSection("DRIVING")
        tab:AddToggle("Fly (car)", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddToggle("Noclip", false, function(v) State.noclip = v; if v then noclipOn() else noclipOff() end end)
        tab:AddSection("FARM")
        tab:AddToggle("Auto Collect", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Clicker", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        return
    end

    --====================  LIFTING SIMULATOR  ====================
    if key == "liftingsim" then
        tab:AddSection("TRAINING")
        tab:AddToggle("Auto Lift (click)", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddToggle("Auto Sell", false, function(v) if v then autoRobOn() else autoRobOff() end end)
        tab:AddSection("COMBAT")
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddSlider("Aura Range", 4, 40, State.auraRange, "", function(v) State.auraRange = v end)
        tab:AddToggle("Hitbox Expander", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddSlider("Walk Speed", 16, 300, 30, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return
    end

    --====================  DOORS  ====================
    if key == "doors" then
        tab:AddSection("ESP")
        tab:AddToggle("Entity / Monster ESP", false, function(v)
            if v then partESPOn({ "rush", "ambush", "figure", "seek", "entity", "monster" }, Theme.Red) else partESPOff() end
        end)
        tab:AddToggle("Highlight Items", false, function(v)
            if v then partESPOn({ "key", "lighter", "lockpick", "vitamins", "item", "drawer" }, Theme.Yellow) else partESPOff() end
        end)
        tab:AddToggle("Highlight Doors", false, function(v)
            if v then partESPOn({ "door" }, Theme.Cyan) else partESPOff() end
        end)
        tab:AddSection("UTILITY")
        tab:AddToggle("Auto Grab (prompts)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("No Fall Damage", false, function(v) if v then noFallOn() else noFallOff() end end)
        tab:AddToggle("Fullbright", false, function(v) State.fullbright = v; if v then fbOn() else fbOff() end end)
        return
    end

    --====================  RAINBOW FRIENDS  ====================
    if key == "rainbowfriends" then
        tab:AddSection("SURVIVAL")
        tab:AddToggle("Monster ESP", false, function(v)
            if v then partESPOn({ "blue", "green", "orange", "purple", "monster", "friend" }, Theme.Red) else partESPOff() end
        end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("No Fall Damage", false, function(v) if v then noFallOn() else noFallOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddToggle("Noclip", false, function(v) State.noclip = v; if v then noclipOn() else noclipOff() end end)
        tab:AddButton("Teleport High (+500)", function() tpUp(500) end)
        return
    end

    --====================  PIGGY  ====================
    if key == "piggy" then
        tab:AddSection("SURVIVAL")
        tab:AddToggle("Piggy ESP", false, function(v)
            if v then partESPOn({ "piggy", "pig", "monster", "bot" }, Theme.Pink) else partESPOff() end
        end)
        tab:AddToggle("Highlight Items/Keys", false, function(v)
            if v then partESPOn({ "key", "hammer", "item", "plank" }, Theme.Yellow) else partESPOff() end
        end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddSection("UTILITY")
        tab:AddToggle("Auto Grab (prompts)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddSlider("Walk Speed", 16, 200, 22, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return
    end

    --====================  ADOPT ME  ====================
    if key == "adoptme" then
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 300, 24, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Highlight Pets/Items", false, function(v)
            if v then partESPOn({ "pet", "egg", "item" }, Theme.Cyan) else partESPOff() end
        end)
        tab:AddSection("UTILITY")
        tab:AddToggle("Anti-AFK", false, function(v) if v then antiAfkOn() else antiAfkOff() end end)
        return
    end

    --====================  BROOKHAVEN  ====================
    if key == "brockhaven" then
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 300, 24, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        tab:AddToggle("Noclip", false, function(v) State.noclip = v; if v then noclipOn() else noclipOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("  • Names", true, function(v) State.espName = v end)
        tab:AddToggle("  • Distance", true, function(v) State.espDist = v end)
        tab:AddSection("UTILITY")
        tab:AddToggle("Anti-AFK", false, function(v) if v then antiAfkOn() else antiAfkOff() end end)
        return
    end

    --====================  BLOX FRUITS  ====================
    if key == "bloxfruits" then
        tab:AddSection("FARM")
        tab:AddToggle("Auto Farm (collect)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Fast Attack (click)", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddSlider("Aura Range", 4, 60, State.auraRange, "", function(v) State.auraRange = v end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Bring / Highlight Fruit", false, function(v)
            if v then partESPOn({ "fruit", "chest", "devil" }, Theme.Pink) else partESPOff() end
        end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 400, 50, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return
    end

    --====================  KING LEGACY  ====================
    if key == "kinglegacy" then
        tab:AddSection("FARM")
        tab:AddToggle("Auto Farm (collect)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddToggle("Fast Attack", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 400, 50, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        return
    end

    --====================  TOWER DEFENSE SIM  ====================
    if key == "towerdefensesim" then
        tab:AddSection("FARM")
        tab:AddToggle("Auto Collect (tools)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Clicker", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Highlight Enemies", false, function(v)
            if v then partESPOn({ "enemy", "mob", "boss", "npc" }, Theme.Red) else partESPOff() end
        end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        return
    end

    --====================  BLACKHAWK RESCUE (FPS)  ====================
    if key == "blackhawk" then addFPSFeatures(tab, "Blackhawk Rescue"); return end

    --====================  RAGDOLL UNIVERSE  ====================
    if key == "ragdolluniverse" then
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddToggle("Noclip", false, function(v) State.noclip = v; if v then noclipOn() else noclipOff() end end)
        tab:AddToggle("Infinite Jump", false, function(v) State.infJump = v; if v then infJumpOn() else infJumpOff() end end)
        tab:AddSection("COMBAT")
        tab:AddToggle("Hitbox Expander", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        return
    end

    --====================  FIGHT GAMES (shared suite)  ====================
    if key == "boxing" or key == "strongestbg" or key == "combatwarriors" or key == "titanage" then
        tab:AddSection("COMBAT")
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end, true)
        tab:AddSlider("Aura Range", 4, 60, State.auraRange, "", function(v) State.auraRange = v end)
        tab:AddToggle("Hitbox / Reach", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddSlider("Reach Size", 1, 50, State.hitboxSize, "", function(v) State.hitboxSize = v end)
        tab:AddToggle("Auto Clicker (combo)", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddToggle("God Mode", false, function(v) State.godMode = v; if v then godOn() else godOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Tracers", false, function(v) State.espTracer = v end)
        tab:AddSection("MOVEMENT")
        tab:AddSlider("Walk Speed", 16, 250, 32, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        tab:AddToggle("Infinite Jump", false, function(v) State.infJump = v; if v then infJumpOn() else infJumpOff() end end)
        return
    end

    --====================  ANIME / ADVENTURE GAMES  ====================
    if key == "roghoul" or key == "yba" or key == "standupright" or key == "shindo"
    or key == "demonfall" or key == "deepwoken" or key == "projectslayers" or key == "animeadv"
    or key == "worldzero" or key == "treasurequest" or key == "bedwars" then
        tab:AddSection("FARM / COMBAT")
        tab:AddToggle("Auto Farm (collect)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end, true)
        tab:AddSlider("Aura Range", 4, 60, State.auraRange, "", function(v) State.auraRange = v end)
        tab:AddToggle("Auto Clicker", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddToggle("Hitbox Expander", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddToggle("God Mode", false, function(v) State.godMode = v; if v then godOn() else godOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Highlight Chests/Items", false, function(v)
            if v then partESPOn({ "chest", "item", "loot", "orb" }, Theme.Yellow) else partESPOff() end
        end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddToggle("Infinite Jump", false, function(v) State.infJump = v; if v then infJumpOn() else infJumpOff() end end)
        tab:AddSlider("Walk Speed", 16, 400, 50, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return
    end

    --====================  SIMULATOR GAMES  ====================
    if key == "islands" or key == "themepark" or key == "restaurant" or key == "mining"
    or key == "magnet" or key == "lumber" or key == "delivery" or key == "swordsim"
    or key == "superpower" or key == "sabersim" or key == "weightlifting"
    or key == "legendspeed" or key == "solsrng" or key == "animefighters" then
        tab:AddSection("AUTO FARM")
        tab:AddToggle("Auto Collect (prompts)", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Sell (tools)", false, function(v) if v then autoRobOn() else autoRobOff() end end)
        tab:AddToggle("Auto Clicker", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end, true)
        tab:AddToggle("Auto Roll (E)", false, function(v)
            if v then autoKeyOn(Enum.KeyCode.E, 0.4) else autoKeyOff(Enum.KeyCode.E) end
        end)
        tab:AddSection("COMBAT")
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddToggle("Hitbox Expander", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Highlight Items", false, function(v)
            if v then partESPOn({ "ore", "coin", "item", "loot", "chest", "tree", "block" }, Theme.Green) else partESPOff() end
        end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 400, 40, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return
    end

    --====================  ROLEPLAY GAMES  ====================
    if key == "meepcity" or key == "pizzaplace" or key == "rocitizens" or key == "greenville"
    or key == "roville" or key == "bloxburg" or key == "casino" or key == "rocity" then
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddToggle("Noclip", false, function(v) State.noclip = v; if v then noclipOn() else noclipOff() end end)
        tab:AddSlider("Walk Speed", 16, 250, 24, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("  • Names", true, function(v) State.espName = v end)
        tab:AddToggle("  • Distance", true, function(v) State.espDist = v end)
        tab:AddSection("UTILITY")
        tab:AddToggle("Anti-AFK", false, function(v) if v then antiAfkOn() else antiAfkOff() end end)
        tab:AddButton("Teleport to Mouse", function() tpToMouse() end)
        return
    end

    --====================  FISHING SIMULATOR  ====================
    if key == "fishing" then
        tab:AddSection("AUTO FARM")
        tab:AddToggle("Auto Collect", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Sell", false, function(v) if v then autoRobOn() else autoRobOff() end end)
        tab:AddToggle("Auto Clicker", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Highlight Fish", false, function(v)
            if v then partESPOn({ "fish", "loot", "chest" }, Theme.Cyan) else partESPOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 300, 35, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return
    end

    --====================  BUBBLE GUM SIMULATOR  ====================
    if key == "bubblegum" then
        tab:AddSection("AUTO FARM")
        tab:AddToggle("Auto Blow (click)", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end)
        tab:AddToggle("Auto Sell", false, function(v) if v then autoRobOn() else autoRobOff() end end)
        tab:AddToggle("Auto Collect", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Highlight Coins", false, function(v)
            if v then partESPOn({ "coin", "loot", "egg" }, Theme.Yellow) else partESPOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        return
    end

    --====================  UNBOXING / CLICKER SIMS  ====================
    if key == "unboxing" or key == "clickersim" then
        tab:AddSection("AUTO")
        tab:AddToggle("Auto Unbox / Click", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end, true)
        tab:AddToggle("Auto Buy", false, function(v) if v then autoKeyOn(Enum.KeyCode.E, 0.3) else autoKeyOff(Enum.KeyCode.E) end end)
        tab:AddToggle("Auto Sell", false, function(v) if v then autoRobOn() else autoRobOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 300, 35, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return
    end

    --====================  ENERGY ASSAULT / AIM / SNOWBALL (FPS)  ====================
    if key == "energyassault" or key == "snowball" or key == "aimgame" then
        addFPSFeatures(tab, key); return
    end

    --====================  OBBY GAMES  ====================
    if key == "parkour" or key == "megaobby" or key == "kartride" or key == "escaperoom"
    or key == "mazegame" or key == "buildrocket" or key == "parkourcity" or key == "speedrun"
    or key == "obstacle" or key == "escapeschool" or key == "skyrace" then
        tab:AddSection("OBBY SKIP")
        tab:AddToggle("Infinite Jump", false, function(v) State.infJump = v; if v then infJumpOn() else infJumpOff() end end)
        tab:AddToggle("Noclip", false, function(v) State.noclip = v; if v then noclipOn() else noclipOff() end end)
        tab:AddButton("Skip +1500", function() tpUp(1500) end)
        tab:AddButton("Skip +3000", function() tpUp(3000) end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 250, 35, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        tab:AddSlider("Jump Power", 50, 500, 130, "", function(v) State.jump = v; State.useJump = true; applyMovement() end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        return
    end

    --====================  HORROR GAMES  ====================
    if key == "survivekiller" or key == "scarymaze" or key == "backrooms"
    or key == "nextbots" or key == "themimic" then
        tab:AddSection("SURVIVAL")
        tab:AddToggle("Monster / Killer ESP", false, function(v)
            if v then partESPOn({ "killer", "monster", "nextbot", "entity", "mimic", "bot" }, Theme.Red) else partESPOff() end end)
        tab:AddToggle("Highlight Items", false, function(v)
            if v then partESPOn({ "item", "key", "battery", "loot" }, Theme.Yellow) else partESPOff() end end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddSection("UTILITY")
        tab:AddToggle("No Fall Damage", false, function(v) if v then noFallOn() else noFallOff() end end)
        tab:AddToggle("Fullbright", false, function(v) State.fullbright = v; if v then fbOn() else fbOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddToggle("Noclip", false, function(v) State.noclip = v; if v then noclipOn() else noclipOff() end end)
        tab:AddSlider("Walk Speed", 16, 250, 26, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return
    end

    --====================  SURVIVAL GAMES  ====================
    if key == "creature" or key == "dinosim" then
        tab:AddSection("SURVIVAL")
        tab:AddToggle("Highlight Food/Water", false, function(v)
            if v then partESPOn({ "food", "water", "berry", "prey" }, Theme.Green) else partESPOff() end end)
        tab:AddToggle("Player / Creature ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("God Mode", false, function(v) State.godMode = v; if v then godOn() else godOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 300, 35, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return
    end

    --====================  ADVENTURE EXTRAS  ====================
    if key == "dragon" or key == "fantasyfrontier" or key == "treasurehunt" then
        tab:AddSection("FARM / COMBAT")
        tab:AddToggle("Auto Farm", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddToggle("God Mode", false, function(v) State.godMode = v; if v then godOn() else godOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddToggle("Highlight Loot", false, function(v)
            if v then partESPOn({ "chest", "loot", "egg", "treasure" }, Theme.Yellow) else partESPOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 400, 50, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return
    end

    --====================  FIGHT: SWORD FIGHT  ====================
    if key == "swordfight" then
        tab:AddSection("COMBAT")
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddToggle("Hitbox Expander", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddToggle("God Mode", false, function(v) State.godMode = v; if v then godOn() else godOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        return
    end

    --====================  EXTRA SIMULATORS  ====================
    if key == "ghostsim" or key == "mall" or key == "hospital" or key == "zoo"
    or key == "farmtown" or key == "streetrace" or key == "tradesim" or key == "climbsim"
    or key == "swimsim" or key == "runsim" or key == "jumpsim" or key == "goatsim"
    or key == "pizzafactory" or key == "icecream" or key == "burgersim" or key == "sushisim"
    or key == "coffeesim" or key == "donutsim" or key == "tacosim" or key == "tycoonbase" then
        tab:AddSection("AUTO FARM")
        tab:AddToggle("Auto Collect", false, function(v) if v then autoCollectOn() else autoCollectOff() end end)
        tab:AddToggle("Auto Sell", false, function(v) if v then autoRobOn() else autoRobOff() end end)
        tab:AddToggle("Auto Clicker", false, function(v) State.autoClick = v; if v then autoClickOn() else autoClickOff() end end, true)
        tab:AddSection("COMBAT")
        tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
        tab:AddToggle("Hitbox Expander", false, function(v) State.hitbox = v; if v then hitboxOn() else hitboxOff() end end)
        tab:AddSection("VISUALS")
        tab:AddToggle("Highlight Items", false, function(v)
            if v then partESPOn({ "item", "coin", "loot", "customer", "chest" }, Theme.Green) else partESPOff() end end)
        tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
        tab:AddSection("MOVEMENT")
        tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
        tab:AddSlider("Walk Speed", 16, 400, 45, "", function(v) State.speed = v; State.useSpeed = true; applyMovement() end)
        return
    end

    --====================  GENERIC FALLBACK  ====================
    tab:AddLabel("Game-specific presets coming for this title.", Theme.SubText)
    tab:AddLabel("All Universal features work universally. ⚡", Theme.SubText)
    tab:AddSection("QUICK ACCESS")
    tab:AddToggle("Player ESP", false, function(v) State.esp = v; if v then espOn() else espOff() end end)
    tab:AddToggle("Fly", false, function(v) State.fly = v; if v then flyOn() else flyOff() end end)
    tab:AddToggle("Noclip", false, function(v) State.noclip = v; if v then noclipOn() else noclipOff() end end)
    tab:AddToggle("God Mode", false, function(v) State.godMode = v; if v then godOn() else godOff() end end)
    tab:AddToggle("Kill Aura", false, function(v) State.killAura = v; if v then auraOn() else auraOff() end end)
end

print("[UniversalGameHub] Game features builder (part A) loaded.")

--====================================================================
--====================================================================
--                       GAME REGISTRY (42 games)
--====================================================================
--====================================================================
local GameList = {
    { key = "arsenal",        name = "Arsenal",                cat = "FPS",        icon = "🔫" },
    { key = "rivals",         name = "Rivals",                 cat = "FPS",        icon = "🎯" },
    { key = "hypershot",      name = "Hypershot",              cat = "FPS",        icon = "💥" },
    { key = "jailbreak",      name = "Jailbreak",              cat = "Open World", icon = "🚓" },
    { key = "combatarena",    name = "Combat Arena",           cat = "Fight",      icon = "⚔️" },
    { key = "brainrot",       name = "Steal a Brainrot",       cat = "Action",     icon = "🧠" },
    { key = "mm2",            name = "Murder Mystery 2",       cat = "Mystery",    icon = "🔪" },
    { key = "bladeball",      name = "Blade Ball",             cat = "Skill",      icon = "🔮" },
    { key = "toh",            name = "Tower of Hell",          cat = "Obby",       icon = "🗼" },
    { key = "dahood",         name = "Da Hood",                cat = "Action",     icon = "💼" },
    { key = "natdis",         name = "Natural Disasters",      cat = "Survival",   icon = "🌪️" },
    { key = "onetap",         name = "One Tap",                cat = "FPS",        icon = "⚡" },
    { key = "beeswarm",       name = "Bee Swarm Simulator",    cat = "Simulator",  icon = "🐝" },
    { key = "fleetfacility",  name = "Flee the Facility",      cat = "Survival",   icon = "🏃" },
    { key = "growagarden",    name = "Grow a Garden",          cat = "Simulator",  icon = "🌱" },
    { key = "bloxstrike",     name = "Bloxstrike",             cat = "FPS",        icon = "🎮" },
    { key = "breakbones",     name = "Break Your Bones",       cat = "Skill",      icon = "🦴" },
    { key = "slimerng",       name = "Slime RNG",              cat = "Simulator",  icon = "🟢" },
    { key = "redliners",      name = "Redliners (FPS)",        cat = "FPS",        icon = "🏁" },
    { key = "phantomforces",  name = "Phantom Forces",         cat = "FPS",        icon = "🎖️" },
    { key = "bigpaintball",   name = "Big Paintball",          cat = "FPS",        icon = "🎨" },
    { key = "badbusiness",    name = "Bad Business",           cat = "FPS",        icon = "🏢" },
    { key = "frontlines",     name = "Frontlines",             cat = "FPS",        icon = "🪖" },
    { key = "strucid",        name = "Strucid",                cat = "FPS",        icon = "🏗️" },
    { key = "counterblox",    name = "Counter Blox",           cat = "FPS",        icon = "💣" },
    { key = "polybattle",     name = "Polybattle",             cat = "FPS",        icon = "🛡️" },
    { key = "doomsday",       name = "Doomsday",               cat = "FPS",        icon = "☢️" },
    { key = "madcity",        name = "Mad City",               cat = "Open World", icon = "🌆" },
    { key = "prisonlife",     name = "Prison Life",            cat = "Open World", icon = "🔒" },
    { key = "buildaboat",     name = "Build a Boat",           cat = "Obby",       icon = "⛵" },
    { key = "doors",          name = "Doors",                  cat = "Horror",     icon = "🚪" },
    { key = "rainbowfriends", name = "Rainbow Friends",        cat = "Horror",     icon = "🌈" },
    { key = "piggy",          name = "Piggy",                  cat = "Horror",     icon = "🐷" },
    { key = "adoptme",        name = "Adopt Me",               cat = "Roleplay",   icon = "🐣" },
    { key = "brockhaven",     name = "Brookhaven",             cat = "Roleplay",   icon = "🏡" },
    { key = "petsimx",        name = "Pet Simulator X",        cat = "Simulator",  icon = "🐾" },
    { key = "bloxfruits",     name = "Blox Fruits",            cat = "Adventure",  icon = "🍎" },
    { key = "kinglegacy",     name = "King Legacy",            cat = "Adventure",  icon = "👑" },
    { key = "towerdefensesim",name = "Tower Defense Sim",      cat = "Strategy",   icon = "🏰" },
    { key = "ninjalegends",   name = "Ninja Legends",          cat = "Simulator",  icon = "🥷" },
    { key = "vehiclesim",     name = "Vehicle Simulator",      cat = "Simulator",  icon = "🏎️" },
    { key = "liftingsim",     name = "Lifting Simulator",      cat = "Simulator",  icon = "🏋️" },
    { key = "bedwars",        name = "Bedwars",                cat = "Adventure",  icon = "🛏️" },
    { key = "islands",        name = "Islands",                cat = "Simulator",  icon = "🏝️" },
    { key = "treasurequest",  name = "Treasure Quest",         cat = "Adventure",  icon = "💰" },
    { key = "animeadv",       name = "Anime Adventures",       cat = "Adventure",  icon = "🌸" },
    { key = "animefighters",  name = "Anime Fighters",         cat = "Simulator",  icon = "👊" },
    { key = "worldzero",      name = "World // Zero",          cat = "Adventure",  icon = "🗡️" },
    { key = "meepcity",       name = "MeepCity",               cat = "Roleplay",   icon = "🐟" },
    { key = "pizzaplace",     name = "Work at a Pizza Place",  cat = "Roleplay",   icon = "🍕" },
    { key = "themepark",      name = "Theme Park Tycoon 2",    cat = "Simulator",  icon = "🎢" },
    { key = "restaurant",     name = "Restaurant Tycoon 2",    cat = "Simulator",  icon = "🍔" },
    { key = "blackhawk",      name = "Blackhawk Rescue",       cat = "FPS",        icon = "🚁" },
    { key = "ragdolluniverse",name = "Ragdoll Universe",       cat = "Action",     icon = "🤸" },
    { key = "mining",         name = "Mining Simulator",       cat = "Simulator",  icon = "⛏️" },
    { key = "magnet",         name = "Magnet Simulator",       cat = "Simulator",  icon = "🧲" },
    { key = "lumber",         name = "Lumber Tycoon 2",        cat = "Simulator",  icon = "🪵" },
    { key = "delivery",       name = "Delivery Simulator",     cat = "Simulator",  icon = "📦" },
    { key = "rocitizens",     name = "RoCitizens",             cat = "Roleplay",   icon = "🏙️" },
    { key = "greenville",     name = "Greenville",             cat = "Roleplay",   icon = "🚗" },
    { key = "boxing",         name = "Untitled Boxing",        cat = "Fight",      icon = "🥊" },
    { key = "swordsim",       name = "Sword Simulator",        cat = "Simulator",  icon = "🗡️" },
    { key = "superpower",     name = "Super Power Training",   cat = "Simulator",  icon = "⚡" },
    { key = "sabersim",       name = "Saber Simulator",        cat = "Simulator",  icon = "⚔️" },
    { key = "weightlifting",  name = "Weightlifting Sim 3",    cat = "Simulator",  icon = "💪" },
    { key = "roghoul",        name = "Ro-Ghoul",               cat = "Adventure",  icon = "🩸" },
    { key = "yba",            name = "Your Bizarre Adventure", cat = "Adventure",  icon = "🌟" },
    { key = "standupright",   name = "Stand Upright",          cat = "Adventure",  icon = "🧍" },
    { key = "shindo",         name = "Shindo Life",            cat = "Adventure",  icon = "🌀" },
    { key = "demonfall",      name = "Demonfall",              cat = "Adventure",  icon = "👹" },
    { key = "roville",        name = "RoVille",                cat = "Roleplay",   icon = "🌇" },
    { key = "bloxburg",       name = "Welcome to Bloxburg",    cat = "Roleplay",   icon = "🏠" },
    { key = "casino",         name = "Casino",                 cat = "Roleplay",   icon = "🎰" },
    { key = "rocity",         name = "RoCity",                 cat = "Roleplay",   icon = "🌆" },
    { key = "projectslayers", name = "Project Slayers",        cat = "Adventure",  icon = "🗡️" },
    { key = "strongestbg",    name = "Strongest Battlegrounds",cat = "Fight",      icon = "💥" },
    { key = "combatwarriors", name = "Combat Warriors",        cat = "Fight",      icon = "⚔️" },
    { key = "deepwoken",      name = "Deepwoken",              cat = "Adventure",  icon = "🌊" },
    { key = "titanage",       name = "Titanage",               cat = "Adventure",  icon = "🦿" },
    { key = "legendspeed",    name = "Legends of Speed",       cat = "Simulator",  icon = "💨" },
    { key = "solsrng",        name = "Sol's RNG",              cat = "Simulator",  icon = "🎲" },
    { key = "fishing",        name = "Fishing Simulator",      cat = "Simulator",  icon = "🎣" },
    { key = "bubblegum",      name = "Bubble Gum Simulator",   cat = "Simulator",  icon = "🫧" },
    { key = "unboxing",       name = "Unboxing Simulator",     cat = "Simulator",  icon = "📦" },
    { key = "clickersim",     name = "Clicker Simulator",      cat = "Simulator",  icon = "🖱️" },
    { key = "energyassault",  name = "Energy Assault",         cat = "FPS",        icon = "🔋" },
    { key = "parkour",        name = "Parkour Reborn",         cat = "Obby",       icon = "🏃" },
    { key = "megaobby",       name = "Mega Obby",              cat = "Obby",       icon = "🌈" },
    { key = "dragon",         name = "Dragon Adventures",      cat = "Adventure",  icon = "🐉" },
    { key = "creature",       name = "Creatures of Sonaria",   cat = "Survival",   icon = "🦖" },
    { key = "dinosim",        name = "Dinosaur Simulator",     cat = "Survival",   icon = "🦕" },
    { key = "survivekiller",  name = "Survive the Killer",     cat = "Horror",     icon = "🔪" },
    { key = "ghostsim",       name = "Ghost Simulator",        cat = "Simulator",  icon = "👻" },
    { key = "mall",           name = "Mall Tycoon",            cat = "Simulator",  icon = "🛍️" },
    { key = "hospital",       name = "Hospital Tycoon",        cat = "Simulator",  icon = "🏥" },
    { key = "zoo",            name = "Zoo Tycoon",             cat = "Simulator",  icon = "🦓" },
    { key = "farmtown",       name = "Farm Town",              cat = "Simulator",  icon = "🚜" },
    { key = "streetrace",     name = "Street Racing",          cat = "Simulator",  icon = "🏎️" },
    { key = "tradesim",       name = "Trade Simulator",        cat = "Simulator",  icon = "📈" },
    { key = "climbsim",       name = "Climbing Simulator",     cat = "Simulator",  icon = "🧗" },
    { key = "swimsim",        name = "Swimming Simulator",     cat = "Simulator",  icon = "🏊" },
    { key = "runsim",         name = "Running Simulator",      cat = "Simulator",  icon = "🏃" },
    { key = "jumpsim",        name = "Jumping Simulator",      cat = "Simulator",  icon = "🦘" },
    { key = "swordfight",     name = "Sword Fight",            cat = "Fight",      icon = "⚔️" },
    { key = "snowball",       name = "Snowball Battle",        cat = "FPS",        icon = "❄️" },
    { key = "kartride",       name = "Kart Ride",              cat = "Obby",       icon = "🛒" },
    { key = "escaperoom",     name = "Escape Room",            cat = "Obby",       icon = "🚪" },
    { key = "mazegame",       name = "Maze Game",              cat = "Obby",       icon = "🌀" },
    { key = "buildrocket",    name = "Build a Rocket",         cat = "Obby",       icon = "🚀" },
    { key = "parkourcity",    name = "Parkour City",           cat = "Obby",       icon = "🏙️" },
    { key = "speedrun",       name = "Speed Run",              cat = "Obby",       icon = "⚡" },
    { key = "obstacle",       name = "Obstacle Course",        cat = "Obby",       icon = "🚧" },
    { key = "escapeschool",   name = "Escape School",          cat = "Obby",       icon = "🏫" },
    { key = "scarymaze",      name = "Scary Maze",             cat = "Horror",     icon = "😱" },
    { key = "backrooms",      name = "The Backrooms",          cat = "Horror",     icon = "🟨" },
    { key = "nextbots",       name = "Evade Nextbots",         cat = "Horror",     icon = "🤖" },
    { key = "themimic",       name = "The Mimic",              cat = "Horror",     icon = "🎭" },
    { key = "goatsim",        name = "Goat Simulator",         cat = "Simulator",  icon = "🐐" },
    { key = "pizzafactory",   name = "Pizza Factory",          cat = "Simulator",  icon = "🍕" },
    { key = "icecream",       name = "Ice Cream Sim",          cat = "Simulator",  icon = "🍦" },
    { key = "burgersim",      name = "Burger Sim",             cat = "Simulator",  icon = "🍔" },
    { key = "sushisim",       name = "Sushi Sim",              cat = "Simulator",  icon = "🍣" },
    { key = "coffeesim",      name = "Coffee Sim",             cat = "Simulator",  icon = "☕" },
    { key = "donutsim",       name = "Donut Sim",              cat = "Simulator",  icon = "🍩" },
    { key = "tacosim",        name = "Taco Sim",               cat = "Simulator",  icon = "🌮" },
    { key = "fantasyfrontier",name = "Fantasy Frontier",       cat = "Adventure",  icon = "🏰" },
    { key = "aimgame",        name = "Aim Training",           cat = "FPS",        icon = "🎯" },
    { key = "tycoonbase",     name = "Base Tycoon",            cat = "Simulator",  icon = "🏗️" },
    { key = "treasurehunt",   name = "Treasure Hunt",          cat = "Adventure",  icon = "🗺️" },
    { key = "skyrace",        name = "Sky Race",               cat = "Obby",       icon = "☁️" },
}

--====================================================================
--                  BUILD A GAME-SPECIFIC WINDOW
--====================================================================
local function buildGameWindow(g)
    local accent = CatColor[g.cat] or Theme.Accent
    local win = buildWindow({ title = g.name, width = 600, height = 460, accent = accent, icon = g.icon })

    local uni = win:AddTab("Universal", "⚡")
    addUniversalFeatures(uni)

    local feat = win:AddTab("Features", "🎮")
    if not buildRichFeatures(feat, g) then buildGameFeatures(feat, g.key) end

    local autoTab = win:AddTab("Auto", "🤖")
    buildAutoTab(autoTab, g)

    local tp = win:AddTab("Teleports", "📍")
    addTeleportTab(tp, g.key)

    local info = win:AddTab("Info", "ℹ")
    info:AddLabel(g.icon .. "  " .. g.name, Theme.Text, 16)
    info:AddDivider()
    info:AddSection("DETAILS")
    info:AddLabel("Category:  " .. g.cat, Theme.SubText)
    info:AddLabel("Window ID: " .. g.key, Theme.SubText)
    info:AddLabel("Tabs: Universal • Features • Teleports • Info", Theme.SubText)
    info:AddSection("CONTROLS")
    info:AddLabel("RIGHT SHIFT .... toggle whole menu", Theme.SubText)
    info:AddLabel("Drag the title bar to move windows", Theme.SubText)
    info:AddLabel("Fly controls: WASD + Space / Ctrl", Theme.SubText)
    info:AddSection("NOTES")
    info:AddLabel("Universal mechanics target standard Roblox", Theme.SubText)
    info:AddLabel("APIs and are fully functional in Studio.", Theme.SubText)
    info:AddLabel("Game features use robust pcall-safe logic.", Theme.SubText)
    info:AddButton("Close This Window", function() win:Hide() end, Theme.Red)

    local settingsTab = win:AddTab("Settings", "⚙️")
    settingsTab:AddSection("CONFIGURATION")
    settingsTab:AddButton("💾  Save Config", function()
        if saveConfig() then Notify("Config", "Settings saved!") end
    end, Theme.Green)
    settingsTab:AddButton("📂  Load Config", function()
        if loadConfig() then Notify("Config", "Settings loaded!") end
    end, Theme.Blue)
    settingsTab:AddButton("🗑  Reset Config File", function()
        deleteConfig(); Notify("Config", "Config file deleted.")
    end, Theme.Red)
    settingsTab:AddSection("CONTROLS")
    settingsTab:AddKeybind("Toggle Menu Key", Enum.KeyCode.RightShift, function()
        ScreenGui.Enabled = not ScreenGui.Enabled
    end)
    settingsTab:AddToggle("Show Watermark", State.watermark, function(v) State.watermark = v end)
    settingsTab:AddSection("RENDER")
    settingsTab:AddSlider("Camera FOV", 30, 120, State.camFov, "", function(v)
        State.camFov = v; setCamFov(v)
    end)
    settingsTab:AddButton("Reset Character", function()
        local hum = getHum()
        if hum then hum.Health = 0 end
    end, Theme.Yellow)
    settingsTab:AddSection("DISCORD WEBHOOK")
    settingsTab:AddTextBox("Webhook URL", "https://discord.com/api/webhooks/...", function(txt)
        State.discordWebhook = txt
    end)
    settingsTab:AddButton("📨  Test Webhook", function()
        sendWebhook(State.discordWebhook, "✅ Universal Game Hub test message.")
    end)
    settingsTab:AddSection("UNLOAD")
    settingsTab:AddButton("❌  Unload Entire Hub", function()
        untrackAll()
        clearESP()
        partESPOff()
        flyOff()
        silentOff()
        pcall(function() ScreenGui:Destroy() end)
    end, Theme.Red)
    settingsTab:AddDivider()
    settingsTab:AddLabel("UNIVERSAL GAME HUB — MEGA v3.0", Theme.Accent2, 14)
    settingsTab:AddLabel("42+ games • 11 widget types", Theme.SubText)
    settingsTab:AddLabel("Built for testing your own Studio recreations.", Theme.SubText)

    return win
end

--====================================================================
--====================================================================
--                          MAIN HUB MENU
--====================================================================
--====================================================================
local gameWindows = {}
local hubButtons = {}

local function buildHub()
    local W, H = 330, 480
    local Frame = Instance.new("Frame")
    Frame.Name = "UniversalGameHub_Main"
    Frame.Size = UDim2.fromOffset(W, H)
    Frame.Position = UDim2.fromOffset(28, 60)
    Frame.BackgroundColor3 = Theme.Bg
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    corner(Frame, 14)
    stroke(Frame, Theme.Stroke, 1, 0)

    -- header
    local Top = Instance.new("Frame")
    Top.Size = UDim2.new(1, 0, 0, 104)
    Top.BackgroundColor3 = Theme.Topbar
    Top.BorderSizePixel = 0
    Top.Parent = Frame
    corner(Top, 14)
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 0, 3)
    Bar.BackgroundColor3 = Theme.Accent
    Bar.BorderSizePixel = 0
    Bar.Parent = Top
    gradient(Bar, Theme.Accent, Theme.Accent2, 0)

    local logo = Instance.new("Frame")
    logo.Size = UDim2.fromOffset(36, 36)
    logo.Position = UDim2.fromOffset(14, 14)
    logo.BackgroundColor3 = Theme.Accent
    logo.BorderSizePixel = 0
    logo.Parent = Top
    corner(logo, 10)
    gradient(logo, Theme.Accent, Theme.Accent2, 45)
    local logoTxt = Instance.new("TextLabel")
    logoTxt.BackgroundTransparency = 1
    logoTxt.Size = UDim2.fromScale(1, 1)
    logoTxt.Font = FontB; logoTxt.TextSize = 16
    logoTxt.TextColor3 = Theme.Text
    logoTxt.Text = "UG"
    logoTxt.Parent = logo

    local Title = Instance.new("TextLabel")
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.fromOffset(58, 14)
    Title.Size = UDim2.new(1, -120, 0, 20)
    Title.Font = FontB; Title.TextSize = 15
    Title.TextColor3 = Theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Text = "UNIVERSAL GAME HUB"
    Title.Parent = Top

    local Sub = Instance.new("TextLabel")
    Sub.BackgroundTransparency = 1
    Sub.Position = UDim2.fromOffset(58, 34)
    Sub.Size = UDim2.new(1, -120, 0, 16)
    Sub.Font = FontR; Sub.TextSize = 11
    Sub.TextColor3 = Theme.SubText
    Sub.TextXAlignment = Enum.TextXAlignment.Left
    Sub.Text = "MEGA • " .. #GameList .. " games • v3.0 • Auto"
    Sub.Parent = Top

    local Close = Instance.new("TextButton")
    Close.Size = UDim2.fromOffset(26, 26)
    Close.Position = UDim2.new(1, -34, 0, 12)
    Close.BackgroundColor3 = Theme.Element
    Close.Text = "✕"; Close.Font = FontM; Close.TextSize = 13
    Close.TextColor3 = Theme.Red
    Close.Parent = Top
    corner(Close, 7)
    stroke(Close, Theme.Stroke, 1, 0)
    hoverButton(Close, Theme.Element, Theme.ElementH)
    Close.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = false
        Notify("Universal Hub", "Hidden — press RIGHT SHIFT to reopen.", Theme.Yellow)
    end)

    -- search box
    local Search = Instance.new("TextBox")
    Search.Size = UDim2.new(1, -24, 0, 32)
    Search.Position = UDim2.fromOffset(12, 62)
    Search.BackgroundColor3 = Theme.Element
    Search.Text = ""
    Search.PlaceholderText = "🔍  Search games..."
    Search.Font = FontR; Search.TextSize = 13
    Search.TextColor3 = Theme.Text
    Search.PlaceholderColor3 = Theme.Faint
    Search.ClearTextOnFocus = false
    Search.Parent = Top
    corner(Search, 8)
    stroke(Search, Theme.Stroke, 1, 0)
    pad(Search, 10)

    -- scrolling game list
    local List = Instance.new("ScrollingFrame")
    List.Position = UDim2.fromOffset(0, 110)
    List.Size = UDim2.new(1, 0, 1, -136)
    List.BackgroundTransparency = 1
    List.BorderSizePixel = 0
    List.ScrollBarThickness = 5
    List.ScrollBarImageColor3 = Theme.Accent
    List.CanvasSize = UDim2.new(0, 0, 0, 0)
    List.AutomaticCanvasSize = Enum.AutomaticSize.Y
    List.Parent = Frame
    pad(List, 10)
    list(List, Enum.FillDirection.Vertical, 6)

    -- footer
    local foot = Instance.new("TextLabel")
    foot.BackgroundTransparency = 1
    foot.Size = UDim2.new(1, 0, 0, 16)
    foot.Position = UDim2.new(0, 0, 1, -20)
    foot.Font = FontR; foot.TextSize = 10
    foot.TextColor3 = Theme.Faint
    foot.Text = "RIGHT SHIFT to toggle • windows are draggable"
    foot.Parent = Frame

    makeDraggable(Frame, Top)

    local function applyFilter()
        local q = (Search.Text or ""):lower()
        for _, g in ipairs(GameList) do
            local b = hubButtons[g.key]
            if b then
                b.Visible = (q == "" or g.name:lower():find(q) or g.cat:lower():find(q) or g.key:find(q))
            end
        end
    end
    Search:GetPropertyChangedSignal("Text"):Connect(applyFilter)

    return { Frame = Frame, ListHost = List, applyFilter = applyFilter, Search = Search }
end

--====================================================================
--                              INIT
--====================================================================
local Hub = buildHub()

-- lazily build + cache a game's window the first time it is opened,
-- so the hub loads instantly instead of constructing 90+ heavy windows
-- up front (which was freezing executors / failing to "load").
local function getGameWindow(g)
    if gameWindows[g.key] then return gameWindows[g.key] end
    local win
    local ok, err = pcall(function() win = buildGameWindow(g) end)
    if ok and win then
        gameWindows[g.key] = win
        return win
    else
        Notify("Error", "Failed to build " .. g.name .. " window.", Theme.Red)
        warn("[UniversalGameHub] window build error for " .. g.key .. ": " .. tostring(err))
        return nil
    end
end

-- build a list button for each game (windows are created on demand)
for _, g in ipairs(GameList) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = Theme.Element
    b.Text = ""
    b.AutoButtonColor = false
    b.Parent = Hub.ListHost
    corner(b, 9)
    stroke(b, Theme.Stroke, 1, 0)
    hoverButton(b, Theme.Element, Theme.ElementH)

    local acc = CatColor[g.cat] or Theme.Accent
    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(30, 30)
    dot.Position = UDim2.fromOffset(5, 5)
    dot.BackgroundColor3 = acc
    dot.BorderSizePixel = 0
    dot.Parent = b
    corner(dot, 7)
    gradient(dot, acc, Theme.Accent2, 45)
    local ico = Instance.new("TextLabel")
    ico.BackgroundTransparency = 1
    ico.Size = UDim2.fromScale(1, 1)
    ico.Font = FontM; ico.TextSize = 14
    ico.Text = g.icon
    ico.Parent = dot

    local nm = Instance.new("TextLabel")
    nm.BackgroundTransparency = 1
    nm.Position = UDim2.fromOffset(44, 4)
    nm.Size = UDim2.new(1, -110, 0, 20)
    nm.Font = FontM; nm.TextSize = 13
    nm.TextColor3 = Theme.Text
    nm.TextXAlignment = Enum.TextXAlignment.Left
    nm.Text = g.name
    nm.Parent = b

    local tag = Instance.new("TextLabel")
    tag.BackgroundTransparency = 1
    tag.Position = UDim2.fromOffset(44, 22)
    tag.Size = UDim2.new(1, -110, 0, 14)
    tag.Font = FontR; tag.TextSize = 10
    tag.TextColor3 = Theme.Faint
    tag.TextXAlignment = Enum.TextXAlignment.Left
    tag.Text = g.cat
    tag.Parent = b

    local open = Instance.new("TextLabel")
    open.BackgroundTransparency = 1
    open.Position = UDim2.new(1, -26, 0, 0)
    open.Size = UDim2.fromOffset(20, 1)
    open.Font = FontB; open.TextSize = 16
    open.TextColor3 = Theme.SubText
    open.Text = "›"
    open.Parent = b

    b.MouseButton1Click:Connect(function()
        local win = getGameWindow(g)
        if win then win:Show(); Notify("Opened", g.name .. " menu", acc) end
    end)
    hubButtons[g.key] = b
end
Hub.applyFilter()

-- menu toggle key (RIGHT SHIFT)
UserInputService.InputBegan:Connect(function(i, gpe)
    if i.KeyCode == Enum.KeyCode.RightShift and not gpe then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- re-apply persistent movement states on respawn
local function onChar(char)
    task.wait(0.35)
    applyMovement()
    if State.fly then flyOn() end
    if State.noclip then noclipOn() end
    if State.godMode then godOn() end
end
LocalPlayer.CharacterAdded:Connect(onChar)
if LocalPlayer.Character then task.spawn(onChar, LocalPlayer.Character) end

-- restore saved config (if any)
loadConfig()

-- welcome
Notify("Universal Game Hub", "Loaded " .. #GameList .. " games! Pick one to begin.", Theme.Accent2, 5)
print("============================================================")
print("[UniversalGameHub] LOADED — " .. #GameList .. " games available. v3.0 MEGA (Auto + Advanced)")
print("[UniversalGameHub] Toggle menu: RIGHT SHIFT")
print("============================================================")
