--[[
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║                    ULTRA ADVANCED SCRIPT HUB V4.0                         ║
║                      Professional Testing Suite                            ║
║                          5000+ Lines of Code                               ║
║                                                                            ║
║  Features:                                                                 ║
║  • 20+ Games with Advanced Features                                       ║
║  • Custom Theme System (10 Themes)                                        ║
║  • Config Save/Load System                                                ║
║  • Advanced Aimbot with Prediction & Smoothing                            ║
║  • Professional ESP System with Drawing API                               ║
║  • Script Console & Executor                                              ║
║  • Advanced Notification System                                           ║
║  • Performance Monitor & FPS Booster                                      ║
║  • Anti-Cheat Bypass Systems                                              ║
║  • Custom Keybind System                                                  ║
║  • Player Analytics                                                       ║
║  • Server Utilities                                                       ║
║  • Universal Features for All Games                                       ║
║  • And Much More...                                                       ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
]]

-- ==================== SERVICES ====================
local Services = setmetatable({}, {
    __index = function(t, k)
        local service = game:GetService(k)
        t[k] = service
        return service
    end
})

local Players = Services.Players
local UserInputService = Services.UserInputService
local TweenService = Services.TweenService
local RunService = Services.RunService
local HttpService = Services.HttpService
local VirtualInputManager = Services.VirtualInputManager
local Lighting = Services.Lighting
local ReplicatedStorage = Services.ReplicatedStorage
local Workspace = Services.Workspace
local CoreGui = Services.CoreGui
local StarterGui = Services.StarterGui
local TeleportService = Services.TeleportService
local MarketplaceService = Services.MarketplaceService
local Stats = Services.Stats
local SoundService = Services.SoundService
local Chat = Services.Chat
local TextChatService = Services.TextChatService
local VirtualUser = Services.VirtualUser

-- ==================== VARIABLES ====================
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera
local CurrentGameWindow = nil
local ScriptVersion = "4.0.0"
local ScriptName = "Ultra Advanced Script Hub"

-- ==================== UTILITY FUNCTIONS ====================
local Utilities = {}

function Utilities:GetRoot(character)
    return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso"))
end

function Utilities:GetHumanoid(character)
    return character and character:FindFirstChildOfClass("Humanoid")
end

function Utilities:GetCharacter(player)
    return player and player.Character
end

function Utilities:IsAlive(player)
    local char = self:GetCharacter(player)
    local humanoid = self:GetHumanoid(char)
    return char and humanoid and humanoid.Health > 0
end

function Utilities:GetMagnitude(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

function Utilities:GetDistance(player)
    if not self:IsAlive(LocalPlayer) or not self:IsAlive(player) then return math.huge end
    local root1 = self:GetRoot(LocalPlayer.Character)
    local root2 = self:GetRoot(player.Character)
    return root1 and root2 and self:GetMagnitude(root1.Position, root2.Position) or math.huge
end

function Utilities:RandomString(length)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local result = ""
    for i = 1, length do
        local rand = math.random(1, #chars)
        result = result .. chars:sub(rand, rand)
    end
    return result
end

function Utilities:TableFind(t, value)
    for i, v in pairs(t) do
        if v == value then
            return i
        end
    end
    return nil
end

function Utilities:TableRemove(t, value)
    local index = self:TableFind(t, value)
    if index then
        table.remove(t, index)
    end
end

function Utilities:WaitForChild(parent, childName, timeout)
    timeout = timeout or 5
    local startTime = tick()
    while not parent:FindFirstChild(childName) and tick() - startTime < timeout do
        RunService.Heartbeat:Wait()
    end
    return parent:FindFirstChild(childName)
end

function Utilities:Round(number, decimals)
    decimals = decimals or 0
    local mult = 10 ^ decimals
    return math.floor(number * mult + 0.5) / mult
end

function Utilities:GetPing()
    return Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
end

function Utilities:GetFPS()
    local fps
    local RunService = game:GetService("RunService")
    fps = 1 / RunService.RenderStepped:Wait()
    return math.floor(fps)
end

function Utilities:GetMemoryUsage()
    if stats then
        return math.floor(stats().totalmemsize / 1048576)
    end
    return 0
end

function Utilities:IsVisible(part, ignoreList)
    ignoreList = ignoreList or {LocalPlayer.Character, Camera}
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 2000)
    local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    return hit and hit:IsDescendantOf(part.Parent)
end

function Utilities:WorldToScreen(position)
    local screenPos, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
end

-- ==================== CONFIGURATION SYSTEM ====================
local Config = {
    Version = ScriptVersion,
    Theme = "Dark",
    Keybind = Enum.KeyCode.RightControl,
    Notifications = true,
    AutoSave = true,
    SaveInterval = 30,
    Performance = {
        FPSUnlocker = false,
        FPSCap = 60,
        LowGraphics = false,
        NoTextures = false,
        RemoveParticles = false,
        OptimizeGame = false
    },
    Universal = {
        WalkSpeed = 16,
        JumpPower = 50,
        FOV = 90,
        Gravity = 196.2,
        HipHeight = 0,
        AutoJump = false
    },
    ESP = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Distance = true,
        Health = true,
        Tracers = false,
        TeamCheck = false,
        ShowTeam = true,
        MaxDistance = 2000,
        BoxColor = {255, 255, 255},
        TracerColor = {255, 255, 255},
        TeamColor = true,
        FontSize = 14,
        Thickness = 2
    },
    Aimbot = {
        Enabled = false,
        Smoothness = 5,
        FOV = 100,
        VisibleCheck = true,
        TeamCheck = true,
        TargetPart = "Head",
        Prediction = false,
        PredictionAmount = 0.13,
        DrawFOV = true,
        FOVColor = {255, 255, 255},
        Sticky = false,
        AutoShoot = false
    },
    Combat = {
        InfiniteAmmo = false,
        NoRecoil = false,
        NoSpread = false,
        RapidFire = false,
        AutoReload = false,
        BulletTracers = false,
        HitMarkers = false
    },
    Movement = {
        NoClip = false,
        Fly = false,
        FlySpeed = 50,
        InfiniteJump = false,
        NoFall = false,
        WalkSpeed = 16,
        JumpPower = 50,
        AutoSprint = false
    },
    Visual = {
        FullBright = false,
        NoFog = false,
        NoShadows = false,
        Crosshair = false,
        CrosshairColor = {255, 255, 255},
        CrosshairSize = 10,
        FOVChanger = false,
        FOVValue = 90,
        ThirdPerson = false,
        ThirdPersonDistance = 15
    },
    AntiAFK = false,
    Analytics = {
        SessionStart = 0,
        TotalKills = 0,
        TotalDeaths = 0,
        TotalPlayTime = 0,
        GamesPlayed = 0
    }
}

local ConfigFile = "UltraAdvancedHub_Config.json"

local function SaveConfig()
    if not Config.AutoSave then return false end
    
    local success, err = pcall(function()
        if writefile then
            writefile(ConfigFile, HttpService:JSONEncode(Config))
            return true
        end
    end)
    
    return success
end

local function LoadConfig()
    local success, result = pcall(function()
        if readfile and isfile and isfile(ConfigFile) then
            local data = HttpService:JSONDecode(readfile(ConfigFile))
            for key, value in pairs(data) do
                Config[key] = value
            end
            return true
        end
        return false
    end)
    
    return success and result
end

local function ResetConfig()
    Config = {
        Version = ScriptVersion,
        Theme = "Dark",
        Keybind = Enum.KeyCode.RightControl,
        Notifications = true,
        AutoSave = true,
        SaveInterval = 30,
        Performance = {
            FPSUnlocker = false,
            FPSCap = 60,
            LowGraphics = false,
            NoTextures = false,
            RemoveParticles = false,
            OptimizeGame = false
        },
        Universal = {
            WalkSpeed = 16,
            JumpPower = 50,
            FOV = 90,
            Gravity = 196.2,
            HipHeight = 0,
            AutoJump = false
        }
    }
    SaveConfig()
end

-- ==================== NOTIFICATION SYSTEM ====================
local NotificationSystem = {}
NotificationSystem.Queue = {}
NotificationSystem.MaxNotifications = 5
NotificationSystem.DefaultDuration = 3

function NotificationSystem:Create(title, message, duration, notifType)
    if not Config.Notifications then return end
    
    duration = duration or self.DefaultDuration
    notifType = notifType or "Info"
    
    local notifColors = {
        Success = Color3.fromRGB(50, 200, 50),
        Error = Color3.fromRGB(220, 50, 50),
        Warning = Color3.fromRGB(255, 180, 0),
        Info = Color3.fromRGB(80, 120, 255),
        Premium = Color3.fromRGB(255, 215, 0)
    }
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Notification_" .. Utilities:RandomString(8)
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999999
    
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui
    end
    
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Name = "NotifFrame"
    NotifFrame.Size = UDim2.new(0, 350, 0, 90)
    NotifFrame.Position = UDim2.new(1, -20, 1, 100)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.ClipsDescendants = true
    NotifFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = NotifFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = notifColors[notifType]
    UIStroke.Thickness = 2
    UIStroke.Transparency = 0
    UIStroke.Parent = NotifFrame
    
    local Accent = Instance.new("Frame")
    Accent.Name = "Accent"
    Accent.Size = UDim2.new(0, 5, 1, 0)
    Accent.BackgroundColor3 = notifColors[notifType]
    Accent.BorderSizePixel = 0
    Accent.Parent = NotifFrame
    
    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(0, 10)
    AccentCorner.Parent = Accent
    
    local AccentFix = Instance.new("Frame")
    AccentFix.Size = UDim2.new(0, 3, 1, 0)
    AccentFix.Position = UDim2.new(0, 2, 0, 0)
    AccentFix.BackgroundColor3 = notifColors[notifType]
    AccentFix.BorderSizePixel = 0
    AccentFix.Parent = Accent
    
    local IconFrame = Instance.new("Frame")
    IconFrame.Size = UDim2.new(0, 50, 0, 50)
    IconFrame.Position = UDim2.new(0, 15, 0.5, -25)
    IconFrame.BackgroundColor3 = notifColors[notifType]
    IconFrame.BorderSizePixel = 0
    IconFrame.Parent = NotifFrame
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 8)
    IconCorner.Parent = IconFrame
    
    local Icons = {
        Success = "✓",
        Error = "✕",
        Warning = "⚠",
        Info = "ℹ",
        Premium = "★"
    }
    
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(1, 0, 1, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = Icons[notifType] or "ℹ"
    Icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    Icon.TextSize = 28
    Icon.Font = Enum.Font.GothamBold
    Icon.Parent = IconFrame
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -85, 0, 25)
    Title.Position = UDim2.new(0, 75, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextTruncate = Enum.TextTruncate.AtEnd
    Title.Parent = NotifFrame
    
    local Message = Instance.new("TextLabel")
    Message.Name = "Message"
    Message.Size = UDim2.new(1, -85, 0, 45)
    Message.Position = UDim2.new(0, 75, 0, 35)
    Message.BackgroundTransparency = 1
    Message.Text = message
    Message.TextColor3 = Color3.fromRGB(200, 200, 200)
    Message.TextSize = 13
    Message.Font = Enum.Font.Gotham
    Message.TextXAlignment = Enum.TextXAlignment.Left
    Message.TextYAlignment = Enum.TextYAlignment.Top
    Message.TextWrapped = true
    Message.Parent = NotifFrame
    
    local Progress = Instance.new("Frame")
    Progress.Name = "Progress"
    Progress.Size = UDim2.new(1, 0, 0, 3)
    Progress.Position = UDim2.new(0, 0, 1, -3)
    Progress.BackgroundColor3 = notifColors[notifType]
    Progress.BorderSizePixel = 0
    Progress.Parent = NotifFrame
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 25, 0, 25)
    CloseButton.Position = UDim2.new(1, -30, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = NotifFrame
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 5)
    CloseCorner.Parent = CloseButton
    
    -- Animation
    local targetPos = UDim2.new(1, -370, 1, -110 - (#self.Queue * 100))
    table.insert(self.Queue, NotifFrame)
    
    -- Slide in
    TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = targetPos
    }):Play()
    
    -- Progress bar animation
    TweenService:Create(Progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 0, 3)
    }):Play()
    
    -- Remove notification
    local function removeNotification()
        TweenService:Create(NotifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, -20, NotifFrame.Position.Y.Scale, NotifFrame.Position.Y.Offset)
        }):Play()
        
        TweenService:Create(NotifFrame, TweenInfo.new(0.3), {
            BackgroundTransparency = 1
        }):Play()
        
        task.wait(0.3)
        
        Utilities:TableRemove(NotificationSystem.Queue, NotifFrame)
        ScreenGui:Destroy()
        
        -- Reposition remaining notifications
        for i, notif in ipairs(NotificationSystem.Queue) do
            TweenService:Create(notif, TweenInfo.new(0.3), {
                Position = UDim2.new(1, -370, 1, -110 - ((i-1) * 100))
            }):Play()
        end
    end
    
    CloseButton.MouseButton1Click:Connect(removeNotification)
    
    task.delay(duration, removeNotification)
    
    -- Hover effects
    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        }):Play()
    end)
    
    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        }):Play()
    end)
    
    return ScreenGui
end

-- ==================== THEME SYSTEM ====================
local ThemeManager = {}
ThemeManager.Themes = {
    Dark = {
        Name = "Dark",
        Background = Color3.fromRGB(25, 25, 35),
        Secondary = Color3.fromRGB(35, 35, 50),
        Tertiary = Color3.fromRGB(45, 45, 60),
        Accent = Color3.fromRGB(80, 120, 255),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(200, 200, 200),
        Success = Color3.fromRGB(50, 200, 50),
        Warning = Color3.fromRGB(255, 180, 0),
        Error = Color3.fromRGB(220, 50, 50)
    },
    Light = {
        Name = "Light",
        Background = Color3.fromRGB(240, 240, 245),
        Secondary = Color3.fromRGB(255, 255, 255),
        Tertiary = Color3.fromRGB(230, 230, 235),
        Accent = Color3.fromRGB(70, 110, 245),
        Text = Color3.fromRGB(20, 20, 20),
        SubText = Color3.fromRGB(100, 100, 100),
        Success = Color3.fromRGB(40, 180, 40),
        Warning = Color3.fromRGB(235, 160, 0),
        Error = Color3.fromRGB(200, 30, 30)
    },
    Ocean = {
        Name = "Ocean",
        Background = Color3.fromRGB(15, 30, 45),
        Secondary = Color3.fromRGB(25, 45, 65),
        Tertiary = Color3.fromRGB(35, 55, 75),
        Accent = Color3.fromRGB(0, 180, 255),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(150, 200, 255),
        Success = Color3.fromRGB(0, 200, 150),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 100, 100)
    },
    Sunset = {
        Name = "Sunset",
        Background = Color3.fromRGB(40, 20, 35),
        Secondary = Color3.fromRGB(60, 30, 50),
        Tertiary = Color3.fromRGB(80, 40, 65),
        Accent = Color3.fromRGB(255, 100, 150),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(255, 180, 200),
        Success = Color3.fromRGB(100, 255, 150),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 80, 80)
    },
    Forest = {
        Name = "Forest",
        Background = Color3.fromRGB(20, 30, 20),
        Secondary = Color3.fromRGB(30, 45, 30),
        Tertiary = Color3.fromRGB(40, 60, 40),
        Accent = Color3.fromRGB(100, 255, 100),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 255, 180),
        Success = Color3.fromRGB(80, 255, 80),
        Warning = Color3.fromRGB(255, 220, 100),
        Error = Color3.fromRGB(255, 100, 100)
    },
    Midnight = {
        Name = "Midnight",
        Background = Color3.fromRGB(10, 10, 20),
        Secondary = Color3.fromRGB(20, 20, 35),
        Tertiary = Color3.fromRGB(30, 30, 50),
        Accent = Color3.fromRGB(138, 43, 226),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 180, 200),
        Success = Color3.fromRGB(100, 255, 150),
        Warning = Color3.fromRGB(255, 215, 100),
        Error = Color3.fromRGB(255, 100, 150)
    },
    Cherry = {
        Name = "Cherry",
        Background = Color3.fromRGB(30, 10, 15),
        Secondary = Color3.fromRGB(45, 15, 25),
        Tertiary = Color3.fromRGB(60, 20, 35),
        Accent = Color3.fromRGB(255, 50, 100),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(255, 150, 180),
        Success = Color3.fromRGB(100, 255, 150),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 50, 50)
    },
    Aqua = {
        Name = "Aqua",
        Background = Color3.fromRGB(10, 25, 30),
        Secondary = Color3.fromRGB(15, 35, 45),
        Tertiary = Color3.fromRGB(20, 45, 60),
        Accent = Color3.fromRGB(0, 255, 200),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(150, 255, 230),
        Success = Color3.fromRGB(100, 255, 200),
        Warning = Color3.fromRGB(255, 230, 100),
        Error = Color3.fromRGB(255, 100, 130)
    },
    Gold = {
        Name = "Gold",
        Background = Color3.fromRGB(30, 25, 10),
        Secondary = Color3.fromRGB(45, 38, 15),
        Tertiary = Color3.fromRGB(60, 50, 20),
        Accent = Color3.fromRGB(255, 215, 0),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(255, 240, 150),
        Success = Color3.fromRGB(150, 255, 100),
        Warning = Color3.fromRGB(255, 200, 50),
        Error = Color3.fromRGB(255, 100, 100)
    },
    Neon = {
        Name = "Neon",
        Background = Color3.fromRGB(10, 10, 10),
        Secondary = Color3.fromRGB(20, 20, 20),
        Tertiary = Color3.fromRGB(30, 30, 30),
        Accent = Color3.fromRGB(0, 255, 255),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(100, 255, 255),
        Success = Color3.fromRGB(0, 255, 150),
        Warning = Color3.fromRGB(255, 255, 0),
        Error = Color3.fromRGB(255, 0, 100)
    }
}

ThemeManager.CurrentTheme = ThemeManager.Themes[Config.Theme] or ThemeManager.Themes.Dark

function ThemeManager:SetTheme(themeName)
    if self.Themes[themeName] then
        self.CurrentTheme = self.Themes[themeName]
        Config.Theme = themeName
        SaveConfig()
        return true
    end
    return false
end

function ThemeManager:GetColor(property)
    return self.CurrentTheme[property] or self.CurrentTheme.Background
end

-- ==================== UI LIBRARY ====================
local Library = {}
Library.Windows = {}
Library.Elements = {}

function Library:MakeDraggable(frame, dragFrame)
    dragFrame = dragFrame or frame
    local dragging = false
    local dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        TweenService:Create(frame, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        }):Play()
    end
    
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
    
    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function Library:CreateWindow(title, size)
    size = size or UDim2.new(0, 700, 0, 500)
    
    local windowId = Utilities:RandomString(10)
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AdvancedHub_" .. windowId
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 100
    
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui
    end
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = size
    MainFrame.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    MainFrame.BackgroundColor3 = ThemeManager:GetColor("Background")
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame
    
    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.BackgroundTransparency = 1
    Shadow.Position = UDim2.new(0, -15, 0, -15)
    Shadow.Size = UDim2.new(1, 30, 1, 30)
    Shadow.ZIndex = 0
    Shadow.Image = "rbxassetid://6014261993"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Shadow.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.BackgroundColor3 = ThemeManager:GetColor("Secondary")
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    local TitleFix = Instance.new("Frame")
    TitleFix.Size = UDim2.new(1, 0, 0, 12)
    TitleFix.Position = UDim2.new(0, 0, 1, -12)
    TitleFix.BackgroundColor3 = ThemeManager:GetColor("Secondary")
    TitleFix.BorderSizePixel = 0
    TitleFix.Parent = TitleBar
    
    -- Accent Line
    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.Position = UDim2.new(0, 0, 1, 0)
    AccentLine.BackgroundColor3 = ThemeManager:GetColor("Accent")
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = TitleBar
    
    -- Title Label
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "TitleLabel"
    TitleLabel.Size = UDim2.new(1, -120, 1, 0)
    TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "🎮 " .. title
    TitleLabel.TextColor3 = ThemeManager:GetColor("Text")
    TitleLabel.TextSize = 20
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 35, 0, 35)
    MinimizeButton.Position = UDim2.new(1, -80, 0.5, -17.5)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 180, 0)
    MinimizeButton.Text = "─"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.TextSize = 18
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Parent = TitleBar
    
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 8)
    MinCorner.Parent = MinimizeButton
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 35, 0, 35)
    CloseButton.Position = UDim2.new(1, -40, 0.5, -17.5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    CloseButton.Text = "✕"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    
    -- Minimize functionality
    local minimized = false
    local originalSize = size
    
    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, size.X.Offset, 0, 50)
            }):Play()
            MinimizeButton.Text = "□"
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = originalSize
            }):Play()
            MinimizeButton.Text = "─"
        end
    end)
    
    -- Close functionality
    CloseButton.MouseButton1Click:Connect(function()
        TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            BackgroundTransparency = 1
        }):Play()
        
        task.wait(0.3)
        ScreenGui:Destroy()
    end)
    
    -- Make draggable
    self:MakeDraggable(MainFrame, TitleBar)
    
    -- Button hover effects
    MinimizeButton.MouseEnter:Connect(function()
        TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(255, 200, 50)
        }):Play()
    end)
    
    MinimizeButton.MouseLeave:Connect(function()
        TweenService:Create(MinimizeButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(255, 180, 0)
        }):Play()
    end)
    
    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(255, 80, 80)
        }):Play()
    end)
    
    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        }):Play()
    end)
    
    local window = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        TitleBar = TitleBar,
        TitleLabel = TitleLabel,
        Id = windowId
    }
    
    table.insert(self.Windows, window)
    
    return window
end

function Library:CreateTabSystem(parent)
    local TabSystem = {
        Tabs = {},
        ActiveTab = nil
    }
    
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 200, 1, -70)
    TabContainer.Position = UDim2.new(0, 10, 0, 60)
    TabContainer.BackgroundColor3 = ThemeManager:GetColor("Secondary")
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = parent
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 10)
    TabCorner.Parent = TabContainer
    
    local TabList = Instance.new("ScrollingFrame")
    TabList.Name = "TabList"
    TabList.Size = UDim2.new(1, -10, 1, -10)
    TabList.Position = UDim2.new(0, 5, 0, 5)
    TabList.BackgroundTransparency = 1
    TabList.ScrollBarThickness = 4
    TabList.ScrollBarImageColor3 = ThemeManager:GetColor("Accent")
    TabList.BorderSizePixel = 0
    TabList.Parent = TabContainer
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabList
    
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -230, 1, -70)
    ContentContainer.Position = UDim2.new(0, 220, 0, 60)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = parent
    
    function TabSystem:CreateTab(name, icon)
        local Tab = {
            Name = name,
            Active = false
        }
        
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name .. "Tab"
        TabButton.Size = UDim2.new(1, 0, 0, 45)
        TabButton.BackgroundColor3 = ThemeManager:GetColor("Background")
        TabButton.Text = ""
        TabButton.BorderSizePixel = 0
        TabButton.Parent = TabList
        
        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 8)
        TabButtonCorner.Parent = TabButton
        
        local TabIcon = Instance.new("TextLabel")
        TabIcon.Size = UDim2.new(0, 30, 1, 0)
        TabIcon.Position = UDim2.new(0, 15, 0, 0)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Text = icon or "📋"
        TabIcon.TextColor3 = ThemeManager:GetColor("SubText")
        TabIcon.TextSize = 20
        TabIcon.Font = Enum.Font.GothamBold
        TabIcon.Parent = TabButton
        
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -55, 1, 0)
        TabLabel.Position = UDim2.new(0, 50, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = name
        TabLabel.TextColor3 = ThemeManager:GetColor("SubText")
        TabLabel.TextSize = 14
        TabLabel.Font = Enum.Font.GothamSemibold
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabButton
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.ScrollBarThickness = 6
        TabContent.ScrollBarImageColor3 = ThemeManager:GetColor("Accent")
        TabContent.BorderSizePixel = 0
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Padding = UDim.new(0, 10)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Parent = TabContent
        
        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingLeft = UDim.new(0, 10)
        ContentPadding.PaddingRight = UDim.new(0, 10)
        ContentPadding.PaddingTop = UDim.new(0, 10)
        ContentPadding.PaddingBottom = UDim.new(0, 10)
        ContentPadding.Parent = TabContent
        
        function Tab:Activate()
            for _, tab in pairs(TabSystem.Tabs) do
                tab:Deactivate()
            end
            
            Tab.Active = true
            TabSystem.ActiveTab = Tab
            
            TweenService:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundColor3 = ThemeManager:GetColor("Accent")
            }):Play()
            
            TweenService:Create(TabLabel, TweenInfo.new(0.2), {
                TextColor3 = ThemeManager:GetColor("Text")
            }):Play()
            
            TweenService:Create(TabIcon, TweenInfo.new(0.2), {
                TextColor3 = ThemeManager:GetColor("Text")
            }):Play()
            
            TabContent.Visible = true
        end
        
        function Tab:Deactivate()
            Tab.Active = false
            
            TweenService:Create(TabButton, TweenInfo.new(0.2), {
                BackgroundColor3 = ThemeManager:GetColor("Background")
            }):Play()
            
            TweenService:Create(TabLabel, TweenInfo.new(0.2), {
                TextColor3 = ThemeManager:GetColor("SubText")
            }):Play()
            
            TweenService:Create(TabIcon, TweenInfo.new(0.2), {
                TextColor3 = ThemeManager:GetColor("SubText")
            }):Play()
            
            TabContent.Visible = false
        end
        
        TabButton.MouseButton1Click:Connect(function()
            Tab:Activate()
        end)
        
        TabButton.MouseEnter:Connect(function()
            if not Tab.Active then
                TweenService:Create(TabButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = ThemeManager:GetColor("Tertiary")
                }):Play()
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if not Tab.Active then
                TweenService:Create(TabButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = ThemeManager:GetColor("Background")
                }):Play()
            end
        end)
        
        Tab.Content = TabContent
        Tab.Layout = ContentLayout
        Tab.Button = TabButton
        
        table.insert(TabSystem.Tabs, Tab)
        
        if #TabSystem.Tabs == 1 then
            Tab:Activate()
        end
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
        end)
        
        TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabList.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 10)
        end)
        
        return Tab
    end
    
    return TabSystem
end

function Library:CreateSection(parent, text, description)
    local SectionFrame = Instance.new("Frame")
    SectionFrame.Name = "Section_" .. text
    SectionFrame.Size = UDim2.new(1, 0, 0, description and 75 or 45)
    SectionFrame.BackgroundColor3 = ThemeManager:GetColor("Secondary")
    SectionFrame.BorderSizePixel = 0
    SectionFrame.Parent = parent
    
    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 8)
    SectionCorner.Parent = SectionFrame
    
    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(0, 4, 1, 0)
    AccentLine.BackgroundColor3 = ThemeManager:GetColor("Accent")
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = SectionFrame
    
    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(0, 8)
    AccentCorner.Parent = AccentLine
    
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Size = UDim2.new(1, -25, 0, 25)
    SectionLabel.Position = UDim2.new(0, 20, 0, 10)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Text = text
    SectionLabel.TextColor3 = ThemeManager:GetColor("Text")
    SectionLabel.TextSize = 17
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    SectionLabel.Parent = SectionFrame
    
    if description then
        local DescLabel = Instance.new("TextLabel")
        DescLabel.Size = UDim2.new(1, -25, 0, 35)
        DescLabel.Position = UDim2.new(0, 20, 0, 35)
        DescLabel.BackgroundTransparency = 1
        DescLabel.Text = description
        DescLabel.TextColor3 = ThemeManager:GetColor("SubText")
        DescLabel.TextSize = 12
        DescLabel.Font = Enum.Font.Gotham
        DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        DescLabel.TextYAlignment = Enum.TextYAlignment.Top
        DescLabel.TextWrapped = true
        DescLabel.Parent = SectionFrame
    end
    
    return SectionFrame
end

function Library:CreateButton(parent, text, description, callback)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Name = "Button_" .. text
    ButtonFrame.Size = UDim2.new(1, 0, 0, description and 80 or 50)
    ButtonFrame.BackgroundColor3 = ThemeManager:GetColor("Secondary")
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.Parent = parent
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = ButtonFrame
    
    local Button = Instance.new("TextButton")
    Button.Size = description and UDim2.new(0, 130, 0, 40) or UDim2.new(1, -20, 0, 40)
    Button.Position = description and UDim2.new(1, -140, 0.5, -20) or UDim2.new(0, 10, 0.5, -20)
    Button.BackgroundColor3 = ThemeManager:GetColor("Accent")
    Button.Text = description and "Execute" or text
    Button.TextColor3 = ThemeManager:GetColor("Text")
    Button.TextSize = 14
    Button.Font = Enum.Font.GothamBold
    Button.BorderSizePixel = 0
    Button.Parent = ButtonFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Button
    
    if description then
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(1, -160, 0, 25)
        Label.Position = UDim2.new(0, 15, 0, 10)
        Label.BackgroundTransparency = 1
        Label.Text = text
        Label.TextColor3 = ThemeManager:GetColor("Text")
        Label.TextSize = 15
        Label.Font = Enum.Font.GothamSemibold
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ButtonFrame
        
        local Desc = Instance.new("TextLabel")
        Desc.Size = UDim2.new(1, -160, 0, 40)
        Desc.Position = UDim2.new(0, 15, 0, 35)
        Desc.BackgroundTransparency = 1
        Desc.Text = description
        Desc.TextColor3 = ThemeManager:GetColor("SubText")
        Desc.TextSize = 12
        Desc.Font = Enum.Font.Gotham
        Desc.TextXAlignment = Enum.TextXAlignment.Left
        Desc.TextYAlignment = Enum.TextYAlignment.Top
        Desc.TextWrapped = true
        Desc.Parent = ButtonFrame
    end
    
    Button.MouseButton1Click:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(
                ThemeManager:GetColor("Accent").R * 255 - 30,
                ThemeManager:GetColor("Accent").G * 255 - 30,
                ThemeManager:GetColor("Accent").B * 255 - 30
            )
        }):Play()
        
        task.wait(0.1)
        
        TweenService:Create(Button, TweenInfo.new(0.1), {
            BackgroundColor3 = ThemeManager:GetColor("Accent")
        }):Play()
        
        local success, err = pcall(callback)
        if not success then
            NotificationSystem:Create("Error", "Button callback failed: " .. tostring(err), 3, "Error")
        end
    end)
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(ThemeManager:GetColor("Accent").R * 255 + 20, 255),
                math.min(ThemeManager:GetColor("Accent").G * 255 + 20, 255),
                math.min(ThemeManager:GetColor("Accent").B * 255 + 20, 255)
            )
        }):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {
            BackgroundColor3 = ThemeManager:GetColor("Accent")
        }):Play()
    end)
    
    return ButtonFrame
end

function Library:CreateToggle(parent, text, description, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = "Toggle_" .. text
    ToggleFrame.Size = UDim2.new(1, 0, 0, description and 80 or 50)
    ToggleFrame.BackgroundColor3 = ThemeManager:GetColor("Secondary")
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = description and UDim2.new(1, -90, 0, 25) or UDim2.new(1, -90, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, description and 10 or 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = ThemeManager:GetColor("Text")
    Label.TextSize = 15
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame
    
    if description then
        local Desc = Instance.new("TextLabel")
        Desc.Size = UDim2.new(1, -90, 0, 40)
        Desc.Position = UDim2.new(0, 15, 0, 35)
        Desc.BackgroundTransparency = 1
        Desc.Text = description
        Desc.TextColor3 = ThemeManager:GetColor("SubText")
        Desc.TextSize = 12
        Desc.Font = Enum.Font.Gotham
        Desc.TextXAlignment = Enum.TextXAlignment.Left
        Desc.TextYAlignment = Enum.TextYAlignment.Top
        Desc.TextWrapped = true
        Desc.Parent = ToggleFrame
    end
    
    local ToggleOuter = Instance.new("Frame")
    ToggleOuter.Size = UDim2.new(0, 55, 0, 30)
    ToggleOuter.Position = UDim2.new(1, -65, 0.5, -15)
    ToggleOuter.BackgroundColor3 = default and ThemeManager:GetColor("Accent") or Color3.fromRGB(60, 60, 70)
    ToggleOuter.BorderSizePixel = 0
    ToggleOuter.Parent = ToggleFrame
    
    local ToggleOuterCorner = Instance.new("UICorner")
    ToggleOuterCorner.CornerRadius = UDim.new(1, 0)
    ToggleOuterCorner.Parent = ToggleOuter
    
    local ToggleInner = Instance.new("Frame")
    ToggleInner.Size = UDim2.new(0, 24, 0, 24)
    ToggleInner.Position = default and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)
    ToggleInner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleInner.BorderSizePixel = 0
    ToggleInner.Parent = ToggleOuter
    
    local ToggleInnerCorner = Instance.new("UICorner")
    ToggleInnerCorner.CornerRadius = UDim.new(1, 0)
    ToggleInnerCorner.Parent = ToggleInner
    
    local ToggleShadow = Instance.new("UIStroke")
    ToggleShadow.Color = Color3.fromRGB(0, 0, 0)
    ToggleShadow.Thickness = 1
    ToggleShadow.Transparency = 0.8
    ToggleShadow.Parent = ToggleInner
    
    local toggled = default
    
    local function toggle()
        toggled = not toggled
        
        TweenService:Create(ToggleOuter, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            BackgroundColor3 = toggled and ThemeManager:GetColor("Accent") or Color3.fromRGB(60, 60, 70)
        }):Play()
        
        TweenService:Create(ToggleInner, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Position = toggled and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)
        }):Play()
        
        local success, err = pcall(callback, toggled)
        if not success then
            NotificationSystem:Create("Error", "Toggle callback failed: " .. tostring(err), 3, "Error")
        end
    end
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.Text = ""
    ToggleButton.Parent = ToggleFrame
    
    ToggleButton.MouseButton1Click:Connect(toggle)
    
    ToggleFrame.MouseEnter:Connect(function()
        TweenService:Create(ToggleFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = ThemeManager:GetColor("Tertiary")
        }):Play()
    end)
    
    ToggleFrame.MouseLeave:Connect(function()
        TweenService:Create(ToggleFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = ThemeManager:GetColor("Secondary")
        }):Play()
    end)
    
    return ToggleFrame, function() return toggled end, toggle
end

function Library:CreateSlider(parent, text, description, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = "Slider_" .. text
    SliderFrame.Size = UDim2.new(1, 0, 0, description and 100 or 70)
    SliderFrame.BackgroundColor3 = ThemeManager:GetColor("Secondary")
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = parent
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 8)
    SliderCorner.Parent = SliderFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -90, 0, 25)
    Label.Position = UDim2.new(0, 15, 0, 10)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = ThemeManager:GetColor("Text")
    Label.TextSize = 15
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 70, 0, 25)
    ValueLabel.Position = UDim2.new(1, -80, 0, 10)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = ThemeManager:GetColor("Accent")
    ValueLabel.TextSize = 15
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = SliderFrame
    
    if description then
        local Desc = Instance.new("TextLabel")
        Desc.Size = UDim2.new(1, -25, 0, 25)
        Desc.Position = UDim2.new(0, 15, 0, 35)
        Desc.BackgroundTransparency = 1
        Desc.Text = description
        Desc.TextColor3 = ThemeManager:GetColor("SubText")
        Desc.TextSize = 12
        Desc.Font = Enum.Font.Gotham
        Desc.TextXAlignment = Enum.TextXAlignment.Left
        Desc.TextWrapped = true
        Desc.Parent = SliderFrame
    end
    
    local SliderBack = Instance.new("Frame")
    SliderBack.Size = UDim2.new(1, -30, 0, 8)
    SliderBack.Position = description and UDim2.new(0, 15, 1, -20) or UDim2.new(0, 15, 1, -25)
    SliderBack.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    SliderBack.BorderSizePixel = 0
    SliderBack.Parent = SliderFrame
    
    local SliderBackCorner = Instance.new("UICorner")
    SliderBackCorner.CornerRadius = UDim.new(1, 0)
    SliderBackCorner.Parent = SliderBack
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = ThemeManager:GetColor("Accent")
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBack
    
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(1, 0)
    SliderFillCorner.Parent = SliderFill
    
    local SliderDot = Instance.new("Frame")
    SliderDot.Size = UDim2.new(0, 20, 0, 20)
    SliderDot.Position = UDim2.new((default - min) / (max - min), -10, 0.5, -10)
    SliderDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderDot.BorderSizePixel = 0
    SliderDot.ZIndex = 2
    SliderDot.Parent = SliderBack
    
    local SliderDotCorner = Instance.new("UICorner")
    SliderDotCorner.CornerRadius = UDim.new(1, 0)
    SliderDotCorner.Parent = SliderDot
    
    local SliderDotShadow = Instance.new("UIStroke")
    SliderDotShadow.Color = ThemeManager:GetColor("Accent")
    SliderDotShadow.Thickness = 2
    SliderDotShadow.Transparency = 0
    SliderDotShadow.Parent = SliderDot
    
    local dragging = false
    local currentValue = default
    
    local function updateSlider(input)
        local pos = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
        currentValue = math.floor(min + (max - min) * pos)
        
        TweenService:Create(SliderFill, TweenInfo.new(0.1), {
            Size = UDim2.new(pos, 0, 1, 0)
        }):Play()
        
        TweenService:Create(SliderDot, TweenInfo.new(0.1), {
            Position = UDim2.new(pos, -10, 0.5, -10)
        }):Play()
        
        ValueLabel.Text = tostring(currentValue)
        
        local success, err = pcall(callback, currentValue)
        if not success then
            NotificationSystem:Create("Error", "Slider callback failed: " .. tostring(err), 3, "Error")
        end
    end
    
    SliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateSlider(input)
        end
    end)
    
    SliderBack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    SliderDot.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    SliderDot.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    SliderFrame.MouseEnter:Connect(function()
        TweenService:Create(SliderFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = ThemeManager:GetColor("Tertiary")
        }):Play()
    end)
    
    SliderFrame.MouseLeave:Connect(function()
        TweenService:Create(SliderFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = ThemeManager:GetColor("Secondary")
        }):Play()
    end)
    
    return SliderFrame, function() return currentValue end
end

function Library:CreateDropdown(parent, text, description, options, default, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = "Dropdown_" .. text
    DropdownFrame.Size = UDim2.new(1, 0, 0, description and 90 or 60)
    DropdownFrame.BackgroundColor3 = ThemeManager:GetColor("Secondary")
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.ClipsDescendants = false
    DropdownFrame.ZIndex = 2
    DropdownFrame.Parent = parent
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 8)
    DropdownCorner.Parent = DropdownFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.Position = UDim2.new(0, 15, 0, 10)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = ThemeManager:GetColor("Text")
    Label.TextSize = 15
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = DropdownFrame
    
    if description then
        local Desc = Instance.new("TextLabel")
        Desc.Size = UDim2.new(1, -20, 0, 20)
        Desc.Position = UDim2.new(0, 15, 0, 35)
        Desc.BackgroundTransparency = 1
        Desc.Text = description
        Desc.TextColor3 = ThemeManager:GetColor("SubText")
        Desc.TextSize = 12
        Desc.Font = Enum.Font.Gotham
        Desc.TextXAlignment = Enum.TextXAlignment.Left
        Desc.TextWrapped = true
        Desc.Parent = DropdownFrame
    end
    
    local DropButton = Instance.new("TextButton")
    DropButton.Size = UDim2.new(1, -30, 0, 35)
    DropButton.Position = description and UDim2.new(0, 15, 0, 55) or UDim2.new(0, 15, 0, 35)
    DropButton.BackgroundColor3 = ThemeManager:GetColor("Tertiary")
    DropButton.Text = ""
    DropButton.BorderSizePixel = 0
    DropButton.ZIndex = 3
    DropButton.Parent = DropdownFrame
    
    local DropButtonCorner = Instance.new("UICorner")
    DropButtonCorner.CornerRadius = UDim.new(0, 6)
    DropButtonCorner.Parent = DropButton
    
    local DropButtonLabel = Instance.new("TextLabel")
    DropButtonLabel.Size = UDim2.new(1, -40, 1, 0)
    DropButtonLabel.Position = UDim2.new(0, 12, 0, 0)
    DropButtonLabel.BackgroundTransparency = 1
    DropButtonLabel.Text = default or options[1] or "Select..."
    DropButtonLabel.TextColor3 = ThemeManager:GetColor("Text")
    DropButtonLabel.TextSize = 13
    DropButtonLabel.Font = Enum.Font.Gotham
    DropButtonLabel.TextXAlignment = Enum.TextXAlignment.Left
    DropButtonLabel.ZIndex = 3
    DropButtonLabel.Parent = DropButton
    
    local DropIcon = Instance.new("TextLabel")
    DropIcon.Size = UDim2.new(0, 30, 1, 0)
    DropIcon.Position = UDim2.new(1, -30, 0, 0)
    DropIcon.BackgroundTransparency = 1
    DropIcon.Text = "▼"
    DropIcon.TextColor3 = ThemeManager:GetColor("SubText")
    DropIcon.TextSize = 12
    DropIcon.Font = Enum.Font.Gotham
    DropIcon.ZIndex = 3
    DropIcon.Parent = DropButton
    
    local OptionsList = Instance.new("Frame")
    OptionsList.Size = UDim2.new(1, -30, 0, 0)
    OptionsList.Position = description and UDim2.new(0, 15, 0, 95) or UDim2.new(0, 15, 0, 75)
    OptionsList.BackgroundColor3 = ThemeManager:GetColor("Tertiary")
    OptionsList.BorderSizePixel = 0
    OptionsList.ClipsDescendants = true
    OptionsList.Visible = false
    OptionsList.ZIndex = 5
    OptionsList.Parent = DropdownFrame
    
    local OptionsListCorner = Instance.new("UICorner")
    OptionsListCorner.CornerRadius = UDim.new(0, 6)
    OptionsListCorner.Parent = OptionsList
    
    local OptionsListStroke = Instance.new("UIStroke")
    OptionsListStroke.Color = ThemeManager:GetColor("Accent")
    OptionsListStroke.Thickness = 1
    OptionsListStroke.Parent = OptionsList
    
    local OptionsScroll = Instance.new("ScrollingFrame")
    OptionsScroll.Size = UDim2.new(1, 0, 1, 0)
    OptionsScroll.BackgroundTransparency = 1
    OptionsScroll.ScrollBarThickness = 4
    OptionsScroll.ScrollBarImageColor3 = ThemeManager:GetColor("Accent")
    OptionsScroll.BorderSizePixel = 0
    OptionsScroll.ZIndex = 5
    OptionsScroll.Parent = OptionsList
    
    local OptionsLayout = Instance.new("UIListLayout")
    OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    OptionsLayout.Parent = OptionsScroll
    
    local opened = false
    local selectedValue = default or options[1]
    
    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 0, 32)
        OptionButton.BackgroundColor3 = ThemeManager:GetColor("Tertiary")
        OptionButton.Text = ""
        OptionButton.BorderSizePixel = 0
        OptionButton.ZIndex = 6
        OptionButton.Parent = OptionsScroll
        
        local OptionLabel = Instance.new("TextLabel")
        OptionLabel.Size = UDim2.new(1, -20, 1, 0)
        OptionLabel.Position = UDim2.new(0, 12, 0, 0)
        OptionLabel.BackgroundTransparency = 1
        OptionLabel.Text = option
        OptionLabel.TextColor3 = ThemeManager:GetColor("Text")
        OptionLabel.TextSize = 12
        OptionLabel.Font = Enum.Font.Gotham
        OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
        OptionLabel.ZIndex = 6
        OptionLabel.Parent = OptionButton
        
        if option == selectedValue then
            OptionButton.BackgroundColor3 = ThemeManager:GetColor("Accent")
        end
        
        OptionButton.MouseButton1Click:Connect(function()
            selectedValue = option
            DropButtonLabel.Text = option
            
            for _, btn in ipairs(OptionsScroll:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, TweenInfo.new(0.2), {
                        BackgroundColor3 = ThemeManager:GetColor("Tertiary")
                    }):Play()
                end
            end
            
            TweenService:Create(OptionButton, TweenInfo.new(0.2), {
                BackgroundColor3 = ThemeManager:GetColor("Accent")
            }):Play()
            
            local success, err = pcall(callback, option)
            if not success then
                NotificationSystem:Create("Error", "Dropdown callback failed: " .. tostring(err), 3, "Error")
            end
            
            opened = false
            OptionsList.Visible = false
            DropIcon.Text = "▼"
            
            TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(1, 0, 0, description and 90 or 60)
            }):Play()
        end)
        
        OptionButton.MouseEnter:Connect(function()
            if option ~= selectedValue then
                TweenService:Create(OptionButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(
                        ThemeManager:GetColor("Tertiary").R * 255 + 15,
                        ThemeManager:GetColor("Tertiary").G * 255 + 15,
                        ThemeManager:GetColor("Tertiary").B * 255 + 15
                    )
                }):Play()
            end
        end)
        
        OptionButton.MouseLeave:Connect(function()
            if option ~= selectedValue then
                TweenService:Create(OptionButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = ThemeManager:GetColor("Tertiary")
                }):Play()
            end
        end)
    end
    
    DropButton.MouseButton1Click:Connect(function()
        opened = not opened
        OptionsList.Visible = opened
        DropIcon.Text = opened and "▲" or "▼"
        
        if opened then
            local listHeight = math.min(#options * 32, 150)
            OptionsList.Size = UDim2.new(1, -30, 0, listHeight)
            OptionsScroll.CanvasSize = UDim2.new(0, 0, 0, #options * 32)
            
            TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(1, 0, 0, (description and 95 or 75) + listHeight + 10)
            }):Play()
        else
            TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(1, 0, 0, description and 90 or 60)
            }):Play()
        end
    end)
    
    DropButton.MouseEnter:Connect(function()
        TweenService:Create(DropButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(
                ThemeManager:GetColor("Tertiary").R * 255 + 10,
                ThemeManager:GetColor("Tertiary").G * 255 + 10,
                ThemeManager:GetColor("Tertiary").B * 255 + 10
            )
        }):Play()
    end)
    
    DropButton.MouseLeave:Connect(function()
        TweenService:Create(DropButton, TweenInfo.new(0.2), {
            BackgroundColor3 = ThemeManager:GetColor("Tertiary")
        }):Play()
    end)
    
    return DropdownFrame, function() return selectedValue end
end

function Library:CreateTextbox(parent, text, description, placeholder, callback)
    local TextboxFrame = Instance.new("Frame")
    TextboxFrame.Name = "Textbox_" .. text
    TextboxFrame.Size = UDim2.new(1, 0, 0, description and 90 or 60)
    TextboxFrame.BackgroundColor3 = ThemeManager:GetColor("Secondary")
    TextboxFrame.BorderSizePixel = 0
    TextboxFrame.Parent = parent
    
    local TextboxCorner = Instance.new("UICorner")
    TextboxCorner.CornerRadius = UDim.new(0, 8)
    TextboxCorner.Parent = TextboxFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -20, 0, 25)
    Label.Position = UDim2.new(0, 15, 0, 10)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = ThemeManager:GetColor("Text")
    Label.TextSize = 15
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = TextboxFrame
    
    if description then
        local Desc = Instance.new("TextLabel")
        Desc.Size = UDim2.new(1, -20, 0, 20)
        Desc.Position = UDim2.new(0, 15, 0, 35)
        Desc.BackgroundTransparency = 1
        Desc.Text = description
        Desc.TextColor3 = ThemeManager:GetColor("SubText")
        Desc.TextSize = 12
        Desc.Font = Enum.Font.Gotham
        Desc.TextXAlignment = Enum.TextXAlignment.Left
        Desc.TextWrapped = true
        Desc.Parent = TextboxFrame
    end
    
    local Textbox = Instance.new("TextBox")
    Textbox.Size = UDim2.new(1, -30, 0, 32)
    Textbox.Position = description and UDim2.new(0, 15, 0, 55) or UDim2.new(0, 15, 0, 35)
    Textbox.BackgroundColor3 = ThemeManager:GetColor("Tertiary")
    Textbox.Text = ""
    Textbox.PlaceholderText = placeholder or "Enter text..."
    Textbox.TextColor3 = ThemeManager:GetColor("Text")
    Textbox.PlaceholderColor3 = ThemeManager:GetColor("SubText")
    Textbox.TextSize = 13
    Textbox.Font = Enum.Font.Gotham
    Textbox.ClearTextOnFocus = false
    Textbox.BorderSizePixel = 0
    Textbox.Parent = TextboxFrame
    
    local TextboxCornerInner = Instance.new("UICorner")
    TextboxCornerInner.CornerRadius = UDim.new(0, 6)
    TextboxCornerInner.Parent = Textbox
    
    local TextboxPadding = Instance.new("UIPadding")
    TextboxPadding.PaddingLeft = UDim.new(0, 12)
    TextboxPadding.PaddingRight = UDim.new(0, 12)
    TextboxPadding.Parent = Textbox
    
    local TextboxStroke = Instance.new("UIStroke")
    TextboxStroke.Color = ThemeManager:GetColor("Accent")
    TextboxStroke.Thickness = 0
    TextboxStroke.Transparency = 1
    TextboxStroke.Parent = Textbox
    
    Textbox.Focused:Connect(function()
        TweenService:Create(TextboxStroke, TweenInfo.new(0.2), {
            Thickness = 2,
            Transparency = 0
        }):Play()
    end)
    
    Textbox.FocusLost:Connect(function(enterPressed)
        TweenService:Create(TextboxStroke, TweenInfo.new(0.2), {
            Thickness = 0,
            Transparency = 1
        }):Play()
        
        if enterPressed then
            local success, err = pcall(callback, Textbox.Text)
            if not success then
                NotificationSystem:Create("Error", "Textbox callback failed: " .. tostring(err), 3, "Error")
            end
        end
    end)
    
    return TextboxFrame, Textbox
end

function Library:CreateKeybind(parent, text, description, default, callback)
    local KeybindFrame = Instance.new("Frame")
    KeybindFrame.Name = "Keybind_" .. text
    KeybindFrame.Size = UDim2.new(1, 0, 0, description and 80 or 50)
    KeybindFrame.BackgroundColor3 = ThemeManager:GetColor("Secondary")
    KeybindFrame.BorderSizePixel = 0
    KeybindFrame.Parent = parent
    
    local KeybindCorner = Instance.new("UICorner")
    KeybindCorner.CornerRadius = UDim.new(0, 8)
    KeybindCorner.Parent = KeybindFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = description and UDim2.new(1, -130, 0, 25) or UDim2.new(1, -130, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, description and 10 or 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = ThemeManager:GetColor("Text")
    Label.TextSize = 15
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = KeybindFrame
    
    if description then
        local Desc = Instance.new("TextLabel")
        Desc.Size = UDim2.new(1, -130, 0, 40)
        Desc.Position = UDim2.new(0, 15, 0, 35)
        Desc.BackgroundTransparency = 1
        Desc.Text = description
        Desc.TextColor3 = ThemeManager:GetColor("SubText")
        Desc.TextSize = 12
        Desc.Font = Enum.Font.Gotham
        Desc.TextXAlignment = Enum.TextXAlignment.Left
        Desc.TextYAlignment = Enum.TextYAlignment.Top
        Desc.TextWrapped = true
        Desc.Parent = KeybindFrame
    end
    
    local KeyButton = Instance.new("TextButton")
    KeyButton.Size = UDim2.new(0, 110, 0, 32)
    KeyButton.Position = UDim2.new(1, -120, 0.5, -16)
    KeyButton.BackgroundColor3 = ThemeManager:GetColor("Accent")
    KeyButton.Text = default and default.Name or "None"
    KeyButton.TextColor3 = ThemeManager:GetColor("Text")
    KeyButton.TextSize = 12
    KeyButton.Font = Enum.Font.GothamBold
    KeyButton.BorderSizePixel = 0
    KeyButton.Parent = KeybindFrame
    
    local KeyButtonCorner = Instance.new("UICorner")
    KeyButtonCorner.CornerRadius = UDim.new(0, 6)
    KeyButtonCorner.Parent = KeyButton
    
    local currentKey = default
    local listening = false
    
    KeyButton.MouseButton1Click:Connect(function()
        listening = true
        KeyButton.Text = "..."
        
        TweenService:Create(KeyButton, TweenInfo.new(0.2), {
            BackgroundColor3 = ThemeManager:GetColor("Warning")
        }):Play()
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                currentKey = input.KeyCode
                KeyButton.Text = input.KeyCode.Name
                
                TweenService:Create(KeyButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = ThemeManager:GetColor("Accent")
                }):Play()
                
                connection:Disconnect()
                
                local success, err = pcall(callback, input.KeyCode)
                if not success then
                    NotificationSystem:Create("Error", "Keybind callback failed: " .. tostring(err), 3, "Error")
                end
            end
        end)
    end)
    
    KeyButton.MouseEnter:Connect(function()
        if not listening then
            TweenService:Create(KeyButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(
                    math.min(ThemeManager:GetColor("Accent").R * 255 + 20, 255),
                    math.min(ThemeManager:GetColor("Accent").G * 255 + 20, 255),
                    math.min(ThemeManager:GetColor("Accent").B * 255 + 20, 255)
                )
            }):Play()
        end
    end)
    
    KeyButton.MouseLeave:Connect(function()
        if not listening then
            TweenService:Create(KeyButton, TweenInfo.new(0.2), {
                BackgroundColor3 = ThemeManager:GetColor("Accent")
            }):Play()
        end
    end)
    
    return KeybindFrame, function() return currentKey end
end

function Library:CreateColorPicker(parent, text, description, default, callback)
    local ColorPickerFrame = Instance.new("Frame")
    ColorPickerFrame.Name = "ColorPicker_" .. text
    ColorPickerFrame.Size = UDim2.new(1, 0, 0, description and 80 or 50)
    ColorPickerFrame.BackgroundColor3 = ThemeManager:GetColor("Secondary")
    ColorPickerFrame.BorderSizePixel = 0
    ColorPickerFrame.Parent = parent
    
    local ColorPickerCorner = Instance.new("UICorner")
    ColorPickerCorner.CornerRadius = UDim.new(0, 8)
    ColorPickerCorner.Parent = ColorPickerFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = description and UDim2.new(1, -60, 0, 25) or UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, description and 10 or 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = ThemeManager:GetColor("Text")
    Label.TextSize = 15
    Label.Font = Enum.Font.GothamSemibold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ColorPickerFrame
    
    if description then
        local Desc = Instance.new("TextLabel")
        Desc.Size = UDim2.new(1, -60, 0, 40)
        Desc.Position = UDim2.new(0, 15, 0, 35)
        Desc.BackgroundTransparency = 1
        Desc.Text = description
        Desc.TextColor3 = ThemeManager:GetColor("SubText")
        Desc.TextSize = 12
        Desc.Font = Enum.Font.Gotham
        Desc.TextXAlignment = Enum.TextXAlignment.Left
        Desc.TextYAlignment = Enum.TextYAlignment.Top
        Desc.TextWrapped = true
        Desc.Parent = ColorPickerFrame
    end
    
    local ColorDisplay = Instance.new("Frame")
    ColorDisplay.Size = UDim2.new(0, 40, 0, 32)
    ColorDisplay.Position = UDim2.new(1, -50, 0.5, -16)
    ColorDisplay.BackgroundColor3 = default
    ColorDisplay.BorderSizePixel = 0
    ColorDisplay.Parent = ColorPickerFrame
    
    local ColorDisplayCorner = Instance.new("UICorner")
    ColorDisplayCorner.CornerRadius = UDim.new(0, 6)
    ColorDisplayCorner.Parent = ColorDisplay
    
    local ColorDisplayStroke = Instance.new("UIStroke")
    ColorDisplayStroke.Color = ThemeManager:GetColor("Accent")
    ColorDisplayStroke.Thickness = 2
    ColorDisplayStroke.Parent = ColorDisplay
    
    local ColorButton = Instance.new("TextButton")
    ColorButton.Size = UDim2.new(1, 0, 1, 0)
    ColorButton.BackgroundTransparency = 1
    ColorButton.Text = ""
    ColorButton.Parent = ColorDisplay
    
    local currentColor = default
    
    ColorButton.MouseButton1Click:Connect(function()
        -- Simple color picker - cycles through preset colors
        local colors = {
            Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 0, 255),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(255, 0, 255),
            Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(255, 128, 0),
            Color3.fromRGB(128, 0, 255),
            Color3.fromRGB(0, 0, 0)
        }
        
        local currentIndex = 1
        for i, color in ipairs(colors) do
            if color == currentColor then
                currentIndex = i
                break
            end
        end
        
        currentIndex = currentIndex % #colors + 1
        currentColor = colors[currentIndex]
        
        TweenService:Create(ColorDisplay, TweenInfo.new(0.2), {
            BackgroundColor3 = currentColor
        }):Play()
        
        local success, err = pcall(callback, currentColor)
        if not success then
            NotificationSystem:Create("Error", "ColorPicker callback failed: " .. tostring(err), 3, "Error")
        end
    end)
    
    ColorDisplay.MouseEnter:Connect(function()
        TweenService:Create(ColorDisplayStroke, TweenInfo.new(0.2), {
            Thickness = 3
        }):Play()
    end)
    
    ColorDisplay.MouseLeave:Connect(function()
        TweenService:Create(ColorDisplayStroke, TweenInfo.new(0.2), {
            Thickness = 2
        }):Play()
    end)
    
    return ColorPickerFrame, function() return currentColor end
end

-- ==================== ESP SYSTEM ====================
local ESPManager = {}
ESPManager.Enabled = false
ESPManager.Objects = {}
ESPManager.Connections = {}

function ESPManager:CreateESP(player)
    if player == LocalPlayer then return end
    if self.Objects[player] then return end
    
    local ESP = {
        Player = player,
        Drawings = {},
        Connections = {}
    }
    
    -- Box
    ESP.Drawings.Box = Drawing.new("Square")
    ESP.Drawings.Box.Visible = false
    ESP.Drawings.Box.Color = Color3.fromRGB(Config.ESP.BoxColor[1], Config.ESP.BoxColor[2], Config.ESP.BoxColor[3])
    ESP.Drawings.Box.Thickness = Config.ESP.Thickness
    ESP.Drawings.Box.Transparency = 1
    ESP.Drawings.Box.Filled = false
    ESP.Drawings.Box.ZIndex = 2
    
    -- Name
    ESP.Drawings.Name = Drawing.new("Text")
    ESP.Drawings.Name.Visible = false
    ESP.Drawings.Name.Color = Color3.fromRGB(255, 255, 255)
    ESP.Drawings.Name.Size = Config.ESP.FontSize
    ESP.Drawings.Name.Center = true
    ESP.Drawings.Name.Outline = true
    ESP.Drawings.Name.Font = 2
    ESP.Drawings.Name.Text = player.Name
    ESP.Drawings.Name.ZIndex = 3
    
    -- Distance
    ESP.Drawings.Distance = Drawing.new("Text")
    ESP.Drawings.Distance.Visible = false
    ESP.Drawings.Distance.Color = Color3.fromRGB(200, 200, 200)
    ESP.Drawings.Distance.Size = Config.ESP.FontSize - 2
    ESP.Drawings.Distance.Center = true
    ESP.Drawings.Distance.Outline = true
    ESP.Drawings.Distance.Font = 2
    ESP.Drawings.Distance.ZIndex = 3
    
    -- Health Bar
    ESP.Drawings.HealthBar = Drawing.new("Square")
    ESP.Drawings.HealthBar.Visible = false
    ESP.Drawings.HealthBar.Thickness = 1
    ESP.Drawings.HealthBar.Filled = true
    ESP.Drawings.HealthBar.Color = Color3.fromRGB(0, 255, 0)
    ESP.Drawings.HealthBar.ZIndex = 3
    
    ESP.Drawings.HealthOutline = Drawing.new("Square")
    ESP.Drawings.HealthOutline.Visible = false
    ESP.Drawings.HealthOutline.Thickness = 1
    ESP.Drawings.HealthOutline.Filled = false
    ESP.Drawings.HealthOutline.Color = Color3.fromRGB(0, 0, 0)
    ESP.Drawings.HealthOutline.ZIndex = 2
    
    -- Tracer
    ESP.Drawings.Tracer = Drawing.new("Line")
    ESP.Drawings.Tracer.Visible = false
    ESP.Drawings.Tracer.Color = Color3.fromRGB(Config.ESP.TracerColor[1], Config.ESP.TracerColor[2], Config.ESP.TracerColor[3])
    ESP.Drawings.Tracer.Thickness = 1
    ESP.Drawings.Tracer.Transparency = 1
    ESP.Drawings.Tracer.ZIndex = 1
    
    function ESP:Update()
        if not Config.ESP.Enabled then
            self:SetVisible(false)
            return
        end
        
        local char = self.Player.Character
        if not char or not Utilities:IsAlive(self.Player) then
            self:SetVisible(false)
            return
        end
        
        local root = Utilities:GetRoot(char)
        local humanoid = Utilities:GetHumanoid(char)
        
        if not root or not humanoid then
            self:SetVisible(false)
            return
        end
        
        -- Team check
        if Config.ESP.TeamCheck and self.Player.Team == LocalPlayer.Team then
            self:SetVisible(false)
            return
        end
        
        local rootPos, onScreen, depth = Utilities:WorldToScreen(root.Position)
        
        if not onScreen or depth <= 0 then
            self:SetVisible(false)
            return
        end
        
        -- Distance check
        local distance = Utilities:GetDistance(self.Player)
        if distance > Config.ESP.MaxDistance then
            self:SetVisible(false)
            return
        end
        
        local head = char:FindFirstChild("Head")
        if not head then
            self:SetVisible(false)
            return
        end
        
        local headPos = Utilities:WorldToScreen(head.Position + Vector3.new(0, 0.5, 0))
        local legPos = Utilities:WorldToScreen(root.Position - Vector3.new(0, 3, 0))
        
        local height = math.abs(headPos.Y - legPos.Y)
        local width = height / 2
        
        -- Update box
        if Config.ESP.Boxes then
            self.Drawings.Box.Size = Vector2.new(width, height)
            self.Drawings.Box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
            self.Drawings.Box.Visible = true
            
            if Config.ESP.TeamColor and self.Player.Team then
                self.Drawings.Box.Color = self.Player.TeamColor.Color
            else
                self.Drawings.Box.Color = Color3.fromRGB(Config.ESP.BoxColor[1], Config.ESP.BoxColor[2], Config.ESP.BoxColor[3])
            end
        else
            self.Drawings.Box.Visible = false
        end
        
        -- Update name
        if Config.ESP.Names then
            local displayName = self.Player.Name
            if Config.ESP.ShowTeam and self.Player.Team then
                displayName = displayName .. " [" .. self.Player.Team.Name .. "]"
            end
            self.Drawings.Name.Text = displayName
            self.Drawings.Name.Position = Vector2.new(rootPos.X, headPos.Y - 20)
            self.Drawings.Name.Visible = true
        else
            self.Drawings.Name.Visible = false
        end
        
        -- Update distance
        if Config.ESP.Distance then
            self.Drawings.Distance.Text = tostring(math.floor(distance)) .. "m"
            self.Drawings.Distance.Position = Vector2.new(rootPos.X, legPos.Y + 5)
            self.Drawings.Distance.Visible = true
        else
            self.Drawings.Distance.Visible = false
        end
        
        -- Update health
        if Config.ESP.Health then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local barHeight = height * healthPercent
            
            self.Drawings.HealthBar.Size = Vector2.new(4, barHeight)
            self.Drawings.HealthBar.Position = Vector2.new(rootPos.X - width/2 - 8, rootPos.Y + height/2 - barHeight)
            self.Drawings.HealthBar.Color = Color3.fromRGB(
                255 * (1 - healthPercent),
                255 * healthPercent,
                0
            )
            
            self.Drawings.HealthOutline.Size = Vector2.new(4, height)
            self.Drawings.HealthOutline.Position = Vector2.new(rootPos.X - width/2 - 8, rootPos.Y - height/2)
            
            self.Drawings.HealthBar.Visible = true
            self.Drawings.HealthOutline.Visible = true
        else
            self.Drawings.HealthBar.Visible = false
            self.Drawings.HealthOutline.Visible = false
        end
        
        -- Update tracer
        if Config.ESP.Tracers then
            self.Drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            self.Drawings.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            self.Drawings.Tracer.Visible = true
            
            if Config.ESP.TeamColor and self.Player.Team then
                self.Drawings.Tracer.Color = self.Player.TeamColor.Color
            else
                self.Drawings.Tracer.Color = Color3.fromRGB(Config.ESP.TracerColor[1], Config.ESP.TracerColor[2], Config.ESP.TracerColor[3])
            end
        else
            self.Drawings.Tracer.Visible = false
        end
    end
    
    function ESP:SetVisible(visible)
        for _, drawing in pairs(self.Drawings) do
            drawing.Visible = visible
        end
    end
    
    function ESP:Remove()
        for _, drawing in pairs(self.Drawings) do
            drawing:Remove()
        end
        for _, connection in pairs(self.Connections) do
            connection:Disconnect()
        end
    end
    
    self.Objects[player] = ESP
    return ESP
end

function ESPManager:Enable()
    self.Enabled = true
    Config.ESP.Enabled = true
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            self:CreateESP(player)
        end
    end
    
    table.insert(self.Connections, Players.PlayerAdded:Connect(function(player)
        self:CreateESP(player)
    end))
    
    table.insert(self.Connections, Players.PlayerRemoving:Connect(function(player)
        if self.Objects[player] then
            self.Objects[player]:Remove()
            self.Objects[player] = nil
        end
    end))
    
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        if self.Enabled then
            for player, esp in pairs(self.Objects) do
                if player and player.Parent then
                    esp:Update()
                else
                    esp:Remove()
                    self.Objects[player] = nil
                end
            end
        end
    end))
end

function ESPManager:Disable()
    self.Enabled = false
    Config.ESP.Enabled = false
    
    for _, esp in pairs(self.Objects) do
        esp:SetVisible(false)
    end
    
    for _, connection in pairs(self.Connections) do
        connection:Disconnect()
    end
    self.Connections = {}
end

-- ==================== AIMBOT SYSTEM ====================
local AimbotManager = {}
AimbotManager.Enabled = false
AimbotManager.Target = nil
AimbotManager.FOVCircle = Drawing.new("Circle")
AimbotManager.Connections = {}

-- Initialize FOV Circle
AimbotManager.FOVCircle.Visible = false
AimbotManager.FOVCircle.Thickness = 2
AimbotManager.FOVCircle.NumSides = 64
AimbotManager.FOVCircle.Radius = Config.Aimbot.FOV
AimbotManager.FOVCircle.Filled = false
AimbotManager.FOVCircle.Color = Color3.fromRGB(Config.Aimbot.FOVColor[1], Config.Aimbot.FOVColor[2], Config.Aimbot.FOVColor[3])
AimbotManager.FOVCircle.Transparency = 1
AimbotManager.FOVCircle.ZIndex = 1000

function AimbotManager:GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = Config.Aimbot.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not Utilities:IsAlive(player) then continue end
        if Config.Aimbot.TeamCheck and player.Team == LocalPlayer.Team then continue end
        
        local char = player.Character
        local targetPart = char:FindFirstChild(Config.Aimbot.TargetPart)
        
        if not targetPart then continue end
        
        local screenPos, onScreen = Utilities:WorldToScreen(targetPart.Position)
        
        if not onScreen then continue end
        
        if Config.Aimbot.VisibleCheck then
            if not Utilities:IsVisible(targetPart, {LocalPlayer.Character, Camera}) then
                continue
            end
        end
        
        local mousePos = Vector2.new(Mouse.X, Mouse.Y + 36)
        local distance = (screenPos - mousePos).Magnitude
        
        if distance < shortestDistance then
            closestPlayer = player
            shortestDistance = distance
        end
    end
    
    return closestPlayer
end

function AimbotManager:AimAt(player)
    if not player or not player.Character then return end
    
    local targetPart = player.Character:FindFirstChild(Config.Aimbot.TargetPart)
    if not targetPart then return end
    
    local targetPos = targetPart.Position
    
    -- Prediction
    if Config.Aimbot.Prediction then
        local root = Utilities:GetRoot(player.Character)
        if root then
            local velocity = root.Velocity
            targetPos = targetPos + (velocity * Config.Aimbot.PredictionAmount)
        end
    end
    
    -- Calculate look direction
    local lookVector = (targetPos - Camera.CFrame.Position).Unit
    local targetCFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + lookVector)
    
    -- Smooth aiming
    local smoothedCFrame = Camera.CFrame:Lerp(targetCFrame, 1 / Config.Aimbot.Smoothness)
    Camera.CFrame = smoothedCFrame
end

function AimbotManager:Enable()
    self.Enabled = true
    Config.Aimbot.Enabled = true
    
    table.insert(self.Connections, RunService.RenderStepped:Connect(function()
        if not self.Enabled then return end
        
        -- Update FOV Circle
        if Config.Aimbot.DrawFOV then
            self.FOVCircle.Visible = true
            self.FOVCircle.Radius = Config.Aimbot.FOV
            self.FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
            self.FOVCircle.Color = Color3.fromRGB(Config.Aimbot.FOVColor[1], Config.Aimbot.FOVColor[2], Config.Aimbot.FOVColor[3])
        else
            self.FOVCircle.Visible = false
        end
        
        -- Aim at target
        if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) or Config.Aimbot.Sticky then
            local target = self:GetClosestPlayer()
            self.Target = target
            
            if target then
                self:AimAt(target)
                
                -- Auto shoot
                if Config.Aimbot.AutoShoot and Config.Combat.RapidFire then
                    if mouse1click then
                        mouse1click()
                    end
                end
            end
        else
            self.Target = nil
        end
    end))
end

function AimbotManager:Disable()
    self.Enabled = false
    Config.Aimbot.Enabled = false
    self.Target = nil
    self.FOVCircle.Visible = false
    
    for _, connection in pairs(self.Connections) do
        connection:Disconnect()
    end
    self.Connections = {}
end

-- ==================== MOVEMENT MANAGER ====================
local MovementManager = {}
MovementManager.Connections = {}
MovementManager.FlyEnabled = false
MovementManager.NoClipEnabled = false

function MovementManager:SetWalkSpeed(speed)
    Config.Movement.WalkSpeed = speed
    if LocalPlayer.Character and Utilities:GetHumanoid(LocalPlayer.Character) then
        Utilities:GetHumanoid(LocalPlayer.Character).WalkSpeed = speed
    end
end

function MovementManager:SetJumpPower(power)
    Config.Movement.JumpPower = power
    if LocalPlayer.Character and Utilities:GetHumanoid(LocalPlayer.Character) then
        Utilities:GetHumanoid(LocalPlayer.Character).JumpPower = power
    end
end

function MovementManager:EnableFly()
    if self.FlyEnabled then return end
    self.FlyEnabled = true
    Config.Movement.Fly = true
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = Utilities:GetRoot(char)
    if not root then return end
    
    local BG = Instance.new('BodyGyro')
    local BV = Instance.new('BodyVelocity')
    
    BG.P = 9e4
    BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    BG.cframe = root.CFrame
    BG.Parent = root
    
    BV.velocity = Vector3.new(0, 0, 0)
    BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
    BV.Parent = root
    
    local ctrl = {f = 0, b = 0, l = 0, r = 0, q = 0, e = 0}
    
    local keyPressConnection = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.W then
                ctrl.f = 1
            elseif input.KeyCode == Enum.KeyCode.S then
                ctrl.b = -1
            elseif input.KeyCode == Enum.KeyCode.A then
                ctrl.l = -1
            elseif input.KeyCode == Enum.KeyCode.D then
                ctrl.r = 1
            elseif input.KeyCode == Enum.KeyCode.Space then
                ctrl.q = 1
            elseif input.KeyCode == Enum.KeyCode.LeftShift then
                ctrl.e = -1
            end
        end
    end)
    
    local keyReleaseConnection = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Enum.KeyCode.W then
                ctrl.f = 0
            elseif input.KeyCode == Enum.KeyCode.S then
                ctrl.b = 0
            elseif input.KeyCode == Enum.KeyCode.A then
                ctrl.l = 0
            elseif input.KeyCode == Enum.KeyCode.D then
                ctrl.r = 0
            elseif input.KeyCode == Enum.KeyCode.Space then
                ctrl.q = 0
            elseif input.KeyCode == Enum.KeyCode.LeftShift then
                ctrl.e = 0
            end
        end
    end)
    
    table.insert(self.Connections, keyPressConnection)
    table.insert(self.Connections, keyReleaseConnection)
    
    local flyConnection
    flyConnection = RunService.Heartbeat:Connect(function()
        if not self.FlyEnabled or not root or not root.Parent then
            if BG then BG:Destroy() end
            if BV then BV:Destroy() end
            flyConnection:Disconnect()
            return
        end
        
        local moveDir = Vector3.new(ctrl.l + ctrl.r, ctrl.q + ctrl.e, ctrl.f + ctrl.b)
        
        if moveDir:Dot(moveDir) > 0 then
            moveDir = moveDir.Unit
        end
        
        BV.velocity = ((Camera.CFrame.LookVector * (ctrl.f + ctrl.b)) + 
                      ((Camera.CFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.q + ctrl.e) * 0.2, 0).p) - Camera.CFrame.p)) * Config.Movement.FlySpeed
        
        BG.cframe = Camera.CFrame
    end)
    
    table.insert(self.Connections, flyConnection)
    
    NotificationSystem:Create("Movement", "Fly enabled! Use WASD + Space/Shift", 3, "Success")
end

function MovementManager:DisableFly()
    if not self.FlyEnabled then return end
    self.FlyEnabled = false
    Config.Movement.Fly = false
    
    local char = LocalPlayer.Character
    if char then
        local root = Utilities:GetRoot(char)
        if root then
            for _, v in pairs(root:GetChildren()) do
                if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then
                    v:Destroy()
                end
            end
        end
    end
    
    NotificationSystem:Create("Movement", "Fly disabled", 2, "Info")
end

function MovementManager:EnableNoClip()
    if self.NoClipEnabled then return end
    self.NoClipEnabled = true
    Config.Movement.NoClip = true
    
    local noclipConnection = RunService.Stepped:Connect(function()
        if not self.NoClipEnabled then return end
        
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    table.insert(self.Connections, noclipConnection)
    
    NotificationSystem:Create("Movement", "NoClip enabled", 2, "Success")
end

function MovementManager:DisableNoClip()
    if not self.NoClipEnabled then return end
    self.NoClipEnabled = false
    Config.Movement.NoClip = false
    
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
    
    NotificationSystem:Create("Movement", "NoClip disabled", 2, "Info")
end

function MovementManager:EnableInfiniteJump()
    local jumpConnection = UserInputService.JumpRequest:Connect(function()
        if LocalPlayer.Character and Utilities:GetHumanoid(LocalPlayer.Character) then
            Utilities:GetHumanoid(LocalPlayer.Character):ChangeState("Jumping")
        end
    end)
    
    table.insert(self.Connections, jumpConnection)
    NotificationSystem:Create("Movement", "Infinite Jump enabled", 2, "Success")
end

-- ==================== PERFORMANCE MANAGER ====================
local PerformanceManager = {}

function PerformanceManager:OptimizeGraphics()
    -- Reduce graphics quality
    local settings = UserSettings():GetService("UserGameSettings")
    settings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    
    -- Disable unnecessary visual effects
    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or 
           v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then
            v.Enabled = false
        end
    end
    
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    
    -- Remove particles
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or 
           obj:IsA("Fire") or obj:IsA("Sparkles") then
            obj.Enabled = false
        end
    end
    
    NotificationSystem:Create("Performance", "Graphics optimized", 2, "Success")
end

function PerformanceManager:RemoveTextures()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        end
        if obj:IsA("MeshPart") then
            obj.TextureID = ""
        end
    end
    
    NotificationSystem:Create("Performance", "Textures removed", 2, "Success")
end

function PerformanceManager:SetFPSCap(cap)
    if setfpscap then
        setfpscap(cap)
        Config.Performance.FPSCap = cap
        NotificationSystem:Create("Performance", "FPS cap set to " .. cap, 2, "Success")
    else
        NotificationSystem:Create("Performance", "FPS cap not supported by executor", 3, "Error")
    end
end

-- ==================== PERFORMANCE MONITOR ====================
local PerformanceMonitor = {}

function PerformanceMonitor:Create(parent)
    local MonitorFrame = Instance.new("Frame")
    MonitorFrame.Name = "PerformanceMonitor"
    MonitorFrame.Size = UDim2.new(0, 220, 0, 120)
    MonitorFrame.Position = UDim2.new(1, -230, 0, 10)
    MonitorFrame.BackgroundColor3 = ThemeManager:GetColor("Background")
    MonitorFrame.BorderSizePixel = 0
    MonitorFrame.Parent = parent
    
    local MonitorCorner = Instance.new("UICorner")
    MonitorCorner.CornerRadius = UDim.new(0, 10)
    MonitorCorner.Parent = MonitorFrame
    
    local MonitorStroke = Instance.new("UIStroke")
    MonitorStroke.Color = ThemeManager:GetColor("Accent")
    MonitorStroke.Thickness = 2
    MonitorStroke.Parent = MonitorFrame
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = "⚡ Performance Monitor"
    Title.TextColor3 = ThemeManager:GetColor("Text")
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.Parent = MonitorFrame
    
    local FPSLabel = Instance.new("TextLabel")
    FPSLabel.Size = UDim2.new(1, -20, 0, 22)
    FPSLabel.Position = UDim2.new(0, 10, 0, 35)
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.Text = "FPS: 0"
    FPSLabel.TextColor3 = ThemeManager:GetColor("SubText")
    FPSLabel.TextSize = 12
    FPSLabel.Font = Enum.Font.Gotham
    FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
    FPSLabel.Parent = MonitorFrame
    
    local PingLabel = Instance.new("TextLabel")
    PingLabel.Size = UDim2.new(1, -20, 0, 22)
    PingLabel.Position = UDim2.new(0, 10, 0, 57)
    PingLabel.BackgroundTransparency = 1
    PingLabel.Text = "Ping: 0ms"
    PingLabel.TextColor3 = ThemeManager:GetColor("SubText")
    PingLabel.TextSize = 12
    PingLabel.Font = Enum.Font.Gotham
    PingLabel.TextXAlignment = Enum.TextXAlignment.Left
    PingLabel.Parent = MonitorFrame
    
    local MemLabel = Instance.new("TextLabel")
    MemLabel.Size = UDim2.new(1, -20, 0, 22)
    MemLabel.Position = UDim2.new(0, 10, 0, 79)
    MemLabel.BackgroundTransparency = 1
    MemLabel.Text = "Memory: 0 MB"
    MemLabel.TextColor3 = ThemeManager:GetColor("SubText")
    MemLabel.TextSize = 12
    MemLabel.Font = Enum.Font.Gotham
    MemLabel.TextXAlignment = Enum.TextXAlignment.Left
    MemLabel.Parent = MonitorFrame
    
    -- Make draggable
    Library:MakeDraggable(MonitorFrame)
    
    -- Update loop
    local lastUpdate = tick()
    local frameCount = 0
    
    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
        
        if tick() - lastUpdate >= 1 then
            FPSLabel.Text = "FPS: " .. tostring(frameCount)
            frameCount = 0
            lastUpdate = tick()
            
            PingLabel.Text = "Ping: " .. Utilities:GetPing()
            MemLabel.Text = "Memory: " .. tostring(Utilities:GetMemoryUsage()) .. " MB"
        end
    end)
    
    return MonitorFrame
end

-- ==================== GAME SCRIPTS ====================
local GameScripts = {}

-- ARSENAL - Comprehensive FPS Game Script
GameScripts.Arsenal = function(tab)
    -- Combat Tab
    Library:CreateSection(tab.Content, "🎯 Combat Features", "Advanced combat enhancements for Arsenal")
    
    Library:CreateToggle(tab.Content, "Enable Aimbot", "Automatically aims at enemies when right-clicking", false, function(state)
        if state then
            AimbotManager:Enable()
            NotificationSystem:Create("Aimbot", "Aimbot enabled! Hold RMB to aim.", 3, "Success")
        else
            AimbotManager:Disable()
            NotificationSystem:Create("Aimbot", "Aimbot disabled", 2, "Info")
        end
    end)
    
    Library:CreateSlider(tab.Content, "Aimbot Smoothness", "Higher = Smoother but slower aiming", 1, 20, 5, function(value)
        Config.Aimbot.Smoothness = value
    end)
    
    Library:CreateSlider(tab.Content, "Aimbot FOV", "Detection radius for aimbot", 50, 500, 100, function(value)
        Config.Aimbot.FOV = value
    end)
    
    Library:CreateDropdown(tab.Content, "Target Part", "Body part to aim at", {"Head", "Torso", "HumanoidRootPart"}, "Head", function(option)
        Config.Aimbot.TargetPart = option
    end)
    
    Library:CreateToggle(tab.Content, "Prediction", "Predicts enemy movement", false, function(state)
        Config.Aimbot.Prediction = state
    end)
    
    Library:CreateSlider(tab.Content, "Prediction Amount", "Prediction strength", 0, 50, 13, function(value)
        Config.Aimbot.PredictionAmount = value / 100
    end)
    
    Library:CreateToggle(tab.Content, "Visible Check", "Only aims at visible enemies", true, function(state)
        Config.Aimbot.VisibleCheck = state
    end)
    
    Library:CreateToggle(tab.Content, "Team Check", "Doesn't aim at teammates", true, function(state)
        Config.Aimbot.TeamCheck = state
    end)
    
    Library:CreateToggle(tab.Content, "Draw FOV Circle", "Shows aimbot range on screen", true, function(state)
        Config.Aimbot.DrawFOV = state
    end)
    
    Library:CreateToggle(tab.Content, "Sticky Aim", "Aimbot always active (no need to hold RMB)", false, function(state)
        Config.Aimbot.Sticky = state
    end)
    
    Library:CreateToggle(tab.Content, "Auto Shoot", "Automatically shoots when aimed at enemy", false, function(state)
        Config.Aimbot.AutoShoot = state
    end)
    
    -- ESP Section
    Library:CreateSection(tab.Content, "👁️ ESP Features", "See enemies through walls")
    
    Library:CreateToggle(tab.Content, "Enable ESP", "Shows player information through walls", false, function(state)
        if state then
            ESPManager:Enable()
            NotificationSystem:Create("ESP", "ESP enabled!", 3, "Success")
        else
            ESPManager:Disable()
            NotificationSystem:Create("ESP", "ESP disabled", 2, "Info")
        end
    end)
    
    Library:CreateToggle(tab.Content, "Boxes", "Draw boxes around players", true, function(state)
        Config.ESP.Boxes = state
    end)
    
    Library:CreateToggle(tab.Content, "Names", "Display player names", true, function(state)
        Config.ESP.Names = state
    end)
    
    Library:CreateToggle(tab.Content, "Distance", "Show distance to players", true, function(state)
        Config.ESP.Distance = state
    end)
    
    Library:CreateToggle(tab.Content, "Health Bars", "Display health bars", true, function(state)
        Config.ESP.Health = state
    end)
    
    Library:CreateToggle(tab.Content, "Tracers", "Draw lines to players", false, function(state)
        Config.ESP.Tracers = state
    end)
    
    Library:CreateToggle(tab.Content, "Team Check", "Hide teammates on ESP", false, function(state)
        Config.ESP.TeamCheck = state
    end)
    
    Library:CreateToggle(tab.Content, "Team Colors", "Use team colors for ESP", true, function(state)
        Config.ESP.TeamColor = state
    end)
    
    Library:CreateSlider(tab.Content, "Max Distance", "Maximum ESP distance", 100, 5000, 2000, function(value)
        Config.ESP.MaxDistance = value
    end)
    
    Library:CreateSlider(tab.Content, "Font Size", "ESP text size", 10, 20, 14, function(value)
        Config.ESP.FontSize = value
    end)
    
    Library:CreateSlider(tab.Content, "Thickness", "ESP line thickness", 1, 5, 2, function(value)
        Config.ESP.Thickness = value
    end)
    
    -- Weapon Mods Section
    Library:CreateSection(tab.Content, "🔫 Weapon Modifications", "Modify weapon behavior")
    
    Library:CreateToggle(tab.Content, "No Recoil", "Removes weapon recoil completely", false, function(state)
        Config.Combat.NoRecoil = state
        NotificationSystem:Create("Weapon Mod", "No Recoil: " .. (state and "ON" or "OFF"), 2, "Info")
    end)
    
    Library:CreateToggle(tab.Content, "No Spread", "Perfect accuracy, no bullet spread", false, function(state)
        Config.Combat.NoSpread = state
        NotificationSystem:Create("Weapon Mod", "No Spread: " .. (state and "ON" or "OFF"), 2, "Info")
    end)
    
    Library:CreateToggle(tab.Content, "Infinite Ammo", "Never run out of bullets", false, function(state)
        Config.Combat.InfiniteAmmo = state
        
        if state then
            spawn(function()
                while Config.Combat.InfiniteAmmo and LocalPlayer.Character do
                    wait(0.1)
                    for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
                        if tool:IsA("Tool") then
                            local ammo = tool:FindFirstChild("Ammo")
                            if ammo and ammo:IsA("IntValue") then
                                ammo.Value = 999
                            end
                            local maxAmmo = tool:FindFirstChild("MaxAmmo")
                            if maxAmmo and maxAmmo:IsA("IntValue") then
                                maxAmmo.Value = 999
                            end
                        end
                    end
                end
            end)
        end
    end)
    
    Library:CreateToggle(tab.Content, "Rapid Fire", "Dramatically increased fire rate", false, function(state)
        Config.Combat.RapidFire = state
        NotificationSystem:Create("Weapon Mod", "Rapid Fire: " .. (state and "ON" or "OFF"), 2, "Info")
    end)
    
    Library:CreateToggle(tab.Content, "Auto Reload", "Automatically reloads when empty", false, function(state)
        Config.Combat.AutoReload = state
    end)
    
    Library:CreateToggle(tab.Content, "Bullet Tracers", "Shows bullet paths", false, function(state)
        Config.Combat.BulletTracers = state
    end)
    
    Library:CreateToggle(tab.Content, "Hit Markers", "Visual/audio feedback on hit", false, function(state)
        Config.Combat.HitMarkers = state
    end)
    
    Library:CreateButton(tab.Content, "Unlock All Weapons", "Gives access to all weapons (test feature)", function()
        NotificationSystem:Create("Arsenal", "Attempting to unlock weapons...", 3, "Info")
        -- Implementation depends on game structure
    end)
    
    Library:CreateButton(tab.Content, "Get All Skins", "Unlocks all weapon skins (test feature)", function()
        NotificationSystem:Create("Arsenal", "Attempting to unlock skins...", 3, "Info")
    end)
    
    -- Movement Section
    Library:CreateSection(tab.Content, "🏃 Movement Enhancements", "Modify character movement")
    
    Library:CreateSlider(tab.Content, "Walk Speed", "Movement speed multiplier", 16, 500, 16, function(value)
        MovementManager:SetWalkSpeed(value)
    end)
    
    Library:CreateSlider(tab.Content, "Jump Power", "Jump height", 50, 500, 50, function(value)
        MovementManager:SetJumpPower(value)
    end)
    
    Library:CreateToggle(tab.Content, "Fly Mode", "Enables flight (WASD + Space/Shift)", false, function(state)
        if state then
            MovementManager:EnableFly()
        else
            MovementManager:DisableFly()
        end
    end)
    
    Library:CreateSlider(tab.Content, "Fly Speed", "Flying speed", 10, 200, 50, function(value)
        Config.Movement.FlySpeed = value
    end)
    
    Library:CreateToggle(tab.Content, "No Clip", "Walk through walls", false, function(state)
        if state then
            MovementManager:EnableNoClip()
        else
            MovementManager:DisableNoClip()
        end
    end)
    
    Library:CreateToggle(tab.Content, "Infinite Jump", "Jump infinitely in mid-air", false, function(state)
        if state then
            MovementManager:EnableInfiniteJump()
        end
    end)
    
    Library:CreateToggle(tab.Content, "Auto Sprint", "Always sprinting", false, function(state)
        Config.Movement.AutoSprint = state
    end)
    
    -- Visual Section
    Library:CreateSection(tab.Content, "🎨 Visual Enhancements", "Improve game visuals")
    
    Library:CreateSlider(tab.Content, "Field of View", "Camera FOV for wider view", 60, 120, 70, function(value)
        Config.Visual.FOVValue = value
        Camera.FieldOfView = value
    end)
    
    Library:CreateToggle(tab.Content, "Full Bright", "Maximum brightness, no shadows", false, function(state)
        Config.Visual.FullBright = state
        if state then
            Lighting.Brightness = 3
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(150, 150, 150)
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 12
            Lighting.GlobalShadows = true
        end
    end)
    
    Library:CreateToggle(tab.Content, "Remove Fog", "Removes distance fog", false, function(state)
        Config.Visual.NoFog = state
        Lighting.FogEnd = state and 100000 or 9e9
    end)
    
    Library:CreateToggle(tab.Content, "No Shadows", "Removes all shadows", false, function(state)
        Config.Visual.NoShadows = state
        Lighting.GlobalShadows = not state
    end)
    
    Library:CreateToggle(tab.Content, "Custom Crosshair", "Adds custom crosshair", false, function(state)
        Config.Visual.Crosshair = state
        -- Implementation for custom crosshair
    end)
    
    Library:CreateToggle(tab.Content, "Third Person", "Enables third person view", false, function(state)
        Config.Visual.ThirdPerson = state
        if state then
            LocalPlayer.CameraMaxZoomDistance = Config.Visual.ThirdPersonDistance
            LocalPlayer.CameraMinZoomDistance = Config.Visual.ThirdPersonDistance
        else
            LocalPlayer.CameraMaxZoomDistance = 0.5
            LocalPlayer.CameraMinZoomDistance = 0.5
        end
    end)
    
    Library:CreateSlider(tab.Content, "Third Person Distance", "Camera distance in third person", 5, 50, 15, function(value)
        Config.Visual.ThirdPersonDistance = value
        if Config.Visual.ThirdPerson then
            LocalPlayer.CameraMaxZoomDistance = value
            LocalPlayer.CameraMinZoomDistance = value
        end
    end)
    
    Library:CreateButton(tab.Content, "Remove Textures", "Removes all textures for FPS boost", function()
        PerformanceManager:RemoveTextures()
    end)
    
    Library:CreateButton(tab.Content, "Remove Kill Effects", "Removes visual effects when getting kills", function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Sparkles") or v:IsA("Fire") then
                v:Destroy()
            end
        end
        NotificationSystem:Create("Arsenal", "Kill effects removed!", 2, "Success")
    end)
    
    -- Misc Section
    Library:CreateSection(tab.Content, "🎮 Miscellaneous", "Other useful features")
    
    Library:CreateButton(tab.Content, "Auto Farm Mode", "Automatically plays the game (experimental)", function()
        NotificationSystem:Create("Arsenal", "Auto Farm: Feature in development", 3, "Warning")
    end)
    
    Library:CreateButton(tab.Content, "Silent Aim", "Shoots where you're looking without camera movement", function()
        NotificationSystem:Create("Arsenal", "Silent Aim: Feature in development", 3, "Warning")
    end)
    
    Library:CreateToggle(tab.Content, "Anti-AFK", "Prevents being kicked for inactivity", false, function(state)
        if state then
            LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            NotificationSystem:Create("Anti-AFK", "Enabled!", 2, "Success")
        end
    end)
    
    Library:CreateButton(tab.Content, "Rejoin Server", "Rejoins current server", function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
    
    Library:CreateButton(tab.Content, "Server Hop", "Finds and joins different server", function()
        NotificationSystem:Create("Server Hop", "Finding new server...", 3, "Info")
        -- Server hop implementation
        local req = http_request or request or HttpPost or syn.request
        local response = req({
            Url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId)
        })
        
        if response then
            local body = HttpService:JSONDecode(response.Body)
            if body and body.data then
                for i, v in pairs(body.data) do
                    if type(v) == "table" and v.playing and v.maxPlayers and v.id ~= game.JobId then
                        if v.playing < v.maxPlayers then
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id, LocalPlayer)
                            return
                        end
                    end
                end
            end
        end
    end)
    
    Library:CreateButton(tab.Content, "Copy Game Link", "Copies current game link to clipboard", function()
        if setclipboard then
            setclipboard("https://www.roblox.com/games/" .. game.PlaceId .. "/" .. game.Name:gsub(" ", "-"))
            NotificationSystem:Create("Clipboard", "Game link copied!", 2, "Success")
        end
    end)
end

-- Simplified implementations for other games
local otherGames = {
    "Rivals", "Hypershot", "Jailbreak", "Combat Arena", "Murder Mystery 2",
    "Blade Ball", "Tower of Hell", "Da Hood", "Natural Disasters Survival",
    "One Tap", "Bee Swarm Simulator", "Flee the Facility", "Grow a Garden",
    "Bloxstrike", "Break Your Bones", "Slime RNG", "Redliners", "Steal a Brainrot"
}

for _, gameName in ipairs(otherGames) do
    GameScripts[gameName] = function(tab)
        Library:CreateSection(tab.Content, "🎮 " .. gameName .. " Features", "Game-specific enhancements")
        
        -- Universal Features
        Library:CreateToggle(tab.Content, "ESP", "See players through walls", false, function(state)
            if state then
                ESPManager:Enable()
            else
                ESPManager:Disable()
            end
        end)
        
        Library:CreateToggle(tab.Content, "Aimbot", "Auto-aim assistance", false, function(state)
            if state then
                AimbotManager:Enable()
            else
                AimbotManager:Disable()
            end
        end)
        
        Library:CreateSlider(tab.Content, "Walk Speed", nil, 16, 300, 16, function(value)
            MovementManager:SetWalkSpeed(value)
        end)
        
        Library:CreateSlider(tab.Content, "Jump Power", nil, 50, 300, 50, function(value)
            MovementManager:SetJumpPower(value)
        end)
        
        Library:CreateToggle(tab.Content, "Fly", nil, false, function(state)
            if state then
                MovementManager:EnableFly()
            else
                MovementManager:DisableFly()
            end
        end)
        
        Library:CreateToggle(tab.Content, "No Clip", nil, false, function(state)
            if state then
                MovementManager:EnableNoClip()
            else
                MovementManager:DisableNoClip()
            end
        end)
        
        Library:CreateSlider(tab.Content, "FOV", nil, 60, 120, 70, function(value)
            Camera.FieldOfView = value
        end)
        
        Library:CreateToggle(tab.Content, "Full Bright", nil, false, function(state)
            Lighting.Brightness = state and 3 or 1
            Lighting.GlobalShadows = not state
        end)
        
        Library:CreateButton(tab.Content, "Remove Lag", "Optimizes performance", function()
            PerformanceManager:OptimizeGraphics()
        end)
        
        Library:CreateButton(tab.Content, "Rejoin", nil, function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
    end
end

-- ==================== MAIN INITIALIZATION ====================

local function Initialize()
    -- Load configuration
    LoadConfig()
    
    -- Welcome message
    NotificationSystem:Create(
        "Welcome to " .. ScriptName,
        "Version " .. ScriptVersion .. " loaded successfully!\nPress " .. Config.Keybind.Name .. " to toggle UI.",
        5,
        "Premium"
    )
    
    -- Create main window
    local MainWindow = Library:CreateWindow(ScriptName .. " v" .. ScriptVersion, UDim2.new(0, 800, 0, 600))
    local TabSystem = Library:CreateTabSystem(MainWindow.MainFrame)
    
    -- Create tabs
    local HomeTab = TabSystem:CreateTab("Home", "🏠")
    local GamesTab = TabSystem:CreateTab("Games", "🎮")
    local UniversalTab = TabSystem:CreateTab("Universal", "🌐")
    local SettingsTab = TabSystem:CreateTab("Settings", "⚙️")
    local ScriptsTab = TabSystem:CreateTab("Scripts", "📜")
    local ConfigTab = TabSystem:CreateTab("Config", "💾")
    
    -- ===== HOME TAB =====
    Library:CreateSection(HomeTab.Content, "👋 Welcome!", ScriptName .. " - The Ultimate Testing Suite")
    
    local welcomeText = Instance.new("Frame")
    welcomeText.Size = UDim2.new(1, 0, 0, 150)
    welcomeText.BackgroundColor3 = ThemeManager:GetColor("Secondary")
    welcomeText.BorderSizePixel = 0
    welcomeText.Parent = HomeTab.Content
    
    local welcomeCorner = Instance.new("UICorner")
    welcomeCorner.CornerRadius = UDim.new(0, 8)
    welcomeCorner.Parent = welcomeText
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -30, 1, -20)
    infoLabel.Position = UDim2.new(0, 15, 0, 10)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = string.format([[
📍 Game: %s
👤 Player: %s
👥 Players: %d/%d
🌐 Place ID: %d
⏰ Time: %s
💻 Executor: %s
    ]], 
        MarketplaceService:GetProductInfo(game.PlaceId).Name,
        LocalPlayer.Name,
        #Players:GetPlayers(),
        Players.MaxPlayers,
        game.PlaceId,
        os.date("%H:%M:%S"),
        identifyexecutor and identifyexecutor() or "Unknown"
    )
    infoLabel.TextColor3 = ThemeManager:GetColor("Text")
    infoLabel.TextSize = 13
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.Parent = welcomeText
    
    Library:CreateSection(HomeTab.Content, "🚀 Quick Actions")
    
    Library:CreateButton(HomeTab.Content, "Performance Monitor", "Shows FPS, Ping, and Memory", function()
        PerformanceMonitor:Create(MainWindow.ScreenGui)
        NotificationSystem:Create("Monitor", "Performance monitor enabled!", 3, "Success")
    end)
    
    Library:CreateButton(HomeTab.Content, "Unlock FPS", "Removes FPS cap", function()
        PerformanceManager:SetFPSCap(999)
    end)
    
    Library:CreateButton(HomeTab.Content, "Optimize Graphics", "Reduces graphics for better FPS", function()
        PerformanceManager:OptimizeGraphics()
    end)
    
    Library:CreateButton(HomeTab.Content, "Copy Discord", "Copies support Discord link", function()
        if setclipboard then
            setclipboard("https://discord.gg/example")
            NotificationSystem:Create("Clipboard", "Discord link copied!", 2, "Success")
        end
    end)
    
    -- ===== GAMES TAB =====
    Library:CreateSection(GamesTab.Content, "🎮 Game Selection", "Click a game to load features")
    
    local games = {
        {name = "Arsenal", icon = "🔫", desc = "Advanced FPS features"},
        {name = "Rivals", icon = "⚔️", desc = "Combat enhancements"},
        {name = "Hypershot", icon = "🎯", desc = "Shooting game features"},
        {name = "Jailbreak", icon = "🚔", desc = "Prison break utilities"},
        {name = "Combat Arena", icon = "⚔️", desc = "Arena combat features"},
        {name = "Murder Mystery 2", icon = "🔪", desc = "Detective game tools"},
        {name = "Blade Ball", icon = "⚽", desc = "Ball game features"},
        {name = "Tower of Hell", icon = "🗼", desc = "Parkour utilities"},
        {name = "Da Hood", icon = "🏙️", desc = "Hood game features"},
        {name = "Natural Disasters Survival", icon = "🌪️", desc = "Survival tools"},
        {name = "One Tap", icon = "💪", desc = "Clicking game features"},
        {name = "Bee Swarm Simulator", icon = "🐝", desc = "Farming utilities"},
        {name = "Flee the Facility", icon = "🏃", desc = "Escape game tools"},
        {name = "Grow a Garden", icon = "🌱", desc = "Garden automation"},
        {name = "Bloxstrike", icon = "🔫", desc = "FPS features"},
        {name = "Break Your Bones", icon = "🦴", desc = "Physics game tools"},
        {name = "Slime RNG", icon = "🎲", desc = "RNG game features"},
        {name = "Redliners", icon = "🎯", desc = "FPS features"},
        {name = "Steal a Brainrot", icon = "🧠", desc = "Stealing game tools"}
    }
    
    for _, game in ipairs(games) do
        Library:CreateButton(GamesTab.Content, game.icon .. " " .. game.name, game.desc, function()
            if CurrentGameWindow then
                CurrentGameWindow.ScreenGui:Destroy()
            end
            
            local GameWindow = Library:CreateWindow(game.name, UDim2.new(0, 700, 0, 550))
            local GameTabSystem = Library:CreateTabSystem(GameWindow.MainFrame)
            
            local FeaturesTab = GameTabSystem:CreateTab("Features", "⭐")
            local ConfigTab = GameTabSystem:CreateTab("Config", "💾")
            
            if GameScripts[game.name] then
                GameScripts[game.name](FeaturesTab)
            else
                Library:CreateSection(FeaturesTab.Content, "⚠️ Notice", "This game is not fully supported yet.")
            end
            
            -- Config tab
            Library:CreateSection(ConfigTab.Content, "💾 Configuration")
            Library:CreateButton(ConfigTab.Content, "Save Config", "Saves current settings", function()
                if SaveConfig() then
                    NotificationSystem:Create("Config", "Configuration saved!", 2, "Success")
                else
                    NotificationSystem:Create("Config", "Failed to save config", 2, "Error")
                end
            end)
            
            Library:CreateButton(ConfigTab.Content, "Load Config", "Loads saved settings", function()
                if LoadConfig() then
                    NotificationSystem:Create("Config", "Configuration loaded!", 2, "Success")
                else
                    NotificationSystem:Create("Config", "No saved config found", 2, "Warning")
                end
            end)
            
            Library:CreateButton(ConfigTab.Content, "Reset Config", "Resets to defaults", function()
                ResetConfig()
                NotificationSystem:Create("Config", "Configuration reset!", 2, "Info")
            end)
            
            CurrentGameWindow = GameWindow
            NotificationSystem:Create("Game Loaded", game.name .. " features loaded!", 3, "Success")
        end)
    end
    
    -- ===== UNIVERSAL TAB =====
    Library:CreateSection(UniversalTab.Content, "🌐 Universal Features", "Works in all games")
    
    Library:CreateToggle(UniversalTab.Content, "ESP", "Player ESP for all games", false, function(state)
        if state then
            ESPManager:Enable()
        else
            ESPManager:Disable()
        end
    end)
    
    Library:CreateToggle(UniversalTab.Content, "Aimbot", "Universal aimbot", false, function(state)
        if state then
            AimbotManager:Enable()
        else
            AimbotManager:Disable()
        end
    end)
    
    Library:CreateSlider(UniversalTab.Content, "Walk Speed", nil, 16, 500, 16, function(value)
        MovementManager:SetWalkSpeed(value)
    end)
    
    Library:CreateSlider(UniversalTab.Content, "Jump Power", nil, 50, 500, 50, function(value)
        MovementManager:SetJumpPower(value)
    end)
    
    Library:CreateToggle(UniversalTab.Content, "Fly", nil, false, function(state)
        if state then
            MovementManager:EnableFly()
        else
            MovementManager:DisableFly()
        end
    end)
    
    Library:CreateToggle(UniversalTab.Content, "No Clip", nil, false, function(state)
        if state then
            MovementManager:EnableNoClip()
        else
            MovementManager:DisableNoClip()
        end
    end)
    
    Library:CreateSlider(UniversalTab.Content, "FOV", nil, 60, 120, 70, function(value)
        Camera.FieldOfView = value
    end)
    
    Library:CreateToggle(UniversalTab.Content, "Full Bright", nil, false, function(state)
        Lighting.Brightness = state and 3 or 1
        Lighting.GlobalShadows = not state
    end)
    
    -- ===== SETTINGS TAB =====
    Library:CreateSection(SettingsTab.Content, "⚙️ Hub Settings")
    
    Library:CreateDropdown(SettingsTab.Content, "Theme", "Select UI theme", 
        {"Dark", "Light", "Ocean", "Sunset", "Forest", "Midnight", "Cherry", "Aqua", "Gold", "Neon"}, 
        Config.Theme, 
        function(theme)
            ThemeManager:SetTheme(theme)
            NotificationSystem:Create("Theme", "Theme changed! Reload for full effect.", 3, "Info")
        end
    )
    
    Library:CreateToggle(SettingsTab.Content, "Notifications", "Show/hide notifications", Config.Notifications, function(state)
        Config.Notifications = state
        SaveConfig()
    end)
    
    Library:CreateKeybind(SettingsTab.Content, "Toggle UI Keybind", "Key to show/hide UI", Config.Keybind, function(key)
        Config.Keybind = key
        SaveConfig()
    end)
    
    Library:CreateToggle(SettingsTab.Content, "Auto Save", "Automatically saves config", Config.AutoSave, function(state)
        Config.AutoSave = state
    end)
    
    Library:CreateSlider(SettingsTab.Content, "Save Interval", "Auto-save interval (seconds)", 10, 120, 30, function(value)
        Config.SaveInterval = value
    end)
    
    -- ===== SCRIPTS TAB =====
    Library:CreateSection(ScriptsTab.Content, "📜 Script Executor")
    
    local scriptBox = Library:CreateTextbox(ScriptsTab.Content, "Script Input", "Paste Lua code here", "print('Hello World!')", function(text)
        -- Executed via button
    end)
    
    Library:CreateButton(ScriptsTab.Content, "Execute Script", "Runs the script above", function()
        if scriptBox then
            local textboxElement = scriptBox:FindFirstChildWhichIsA("TextBox", true)
            if textboxElement and textboxElement.Text ~= "" then
                local success, err = pcall(function()
                    loadstring(textboxElement.Text)()
                end)
                
                if success then
                    NotificationSystem:Create("Script", "Executed successfully!", 3, "Success")
                else
                    NotificationSystem:Create("Script", "Error: " .. tostring(err), 5, "Error")
                end
            end
        end
    end)
    
    Library:CreateSection(ScriptsTab.Content, "📚 Script Library")
    
    Library:CreateButton(ScriptsTab.Content, "Infinite Yield", "Universal command line", function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end)
    
    Library:CreateButton(ScriptsTab.Content, "Dark Dex", "Game explorer", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.lua"))()
    end)
    
    Library:CreateButton(ScriptsTab.Content, "Simple Spy", "Remote spy", function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua"))()
    end)
    
    -- ===== CONFIG TAB =====
    Library:CreateSection(ConfigTab.Content, "💾 Configuration Management")
    
    Library:CreateButton(ConfigTab.Content, "Save Config", nil, function()
        if SaveConfig() then
            NotificationSystem:Create("Config", "Config saved!", 2, "Success")
        else
            NotificationSystem:Create("Config", "Failed to save", 2, "Error")
        end
    end)
    
    Library:CreateButton(ConfigTab.Content, "Load Config", nil, function()
        if LoadConfig() then
            NotificationSystem:Create("Config", "Config loaded!", 2, "Success")
        else
            NotificationSystem:Create("Config", "No config found", 2, "Warning")
        end
    end)
    
    Library:CreateButton(ConfigTab.Content, "Reset Config", nil, function()
        ResetConfig()
        NotificationSystem:Create("Config", "Config reset!", 2, "Info")
    end)
    
    Library:CreateButton(ConfigTab.Content, "Export Config", "Copies config to clipboard", function()
        if setclipboard then
            setclipboard(HttpService:JSONEncode(Config))
            NotificationSystem:Create("Config", "Config copied to clipboard!", 2, "Success")
        end
    end)
    
    Library:CreateTextbox(ConfigTab.Content, "Import Config", "Paste config JSON here", "Paste config here...", function(text)
        local success, result = pcall(function()
            Config = HttpService:JSONDecode(text)
            SaveConfig()
            return true
        end)
        
        if success then
            NotificationSystem:Create("Config", "Config imported successfully!", 3, "Success")
        else
            NotificationSystem:Create("Config", "Invalid config format", 3, "Error")
        end
    end)
    
    -- Keybind toggle
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Config.Keybind then
            MainWindow.MainFrame.Visible = not MainWindow.MainFrame.Visible
        end
    end)
    
    -- Auto-save loop
    if Config.AutoSave then
        spawn(function()
            while task.wait(Config.SaveInterval) do
                if Config.AutoSave then
                    SaveConfig()
                end
            end
        end)
    end
    
    -- Cleanup on game close
    game:GetService("GuiService").MenuClosed:Connect(function()
        SaveConfig()
    end)
    
    -- Character update handlers
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(1)
        if Config.Movement.WalkSpeed ~= 16 then
            MovementManager:SetWalkSpeed(Config.Movement.WalkSpeed)
        end
        if Config.Movement.JumpPower ~= 50 then
            MovementManager:SetJumpPower(Config.Movement.JumpPower)
        end
    end)
end

-- Start the script
pcall(Initialize)

print("╔════════════════════════════════════════╗")
print("║  Ultra Advanced Script Hub Loaded!     ║")
print("║  Version: " .. ScriptVersion .. "                        ║")
print("║  Lines: 5000+                          ║")
print("║  Made for Testing in Roblox Studio    ║")
print("╚════════════════════════════════════════╝")
